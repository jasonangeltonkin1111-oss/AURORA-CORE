from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Tuple
import csv
import io
import math

from aurora_worker_io import atomic_write_text, payload_checksum, read_text, unix_time, utc_stamp

L13_LAYER_FOLDER = "Layer_13_Dynamic_Ranking_Group_Selection"
L13_OWNER = "Runtime 5 - Taxonomy / Ranking Group Owner"
L13_SCHEMA_NAME = "l13_dynamic_ranking_group_selection"
L13_AUTHORITY = "ranking_group_selection_only"
L13_MIN_SELECTED_GROUPS = 3
L13_TARGET_SELECTED_GROUPS = 7
L13_MAX_SELECTED_GROUPS = 7

SELECTED_FIELDS = [
    "selection_rank","ranking_group","ranking_group_slug","asset_class","market_group","market_segment",
    "group_selection_state","selection_quality_tier","l13_group_selection_score","ranking_group_heat",
    "ranking_group_quality_score","ranking_group_strength","group_state","rankable_count","top5_symbol_count",
    "backup_depth","risk_review_count","risk_review_ratio","thin_group_flag","selected_flag","selected_reason",
    "fallback_used","fallback_reason","market_condition_note","source_l12_checksum","meaning","selection_runtime",
    "trade_permission","entry_signal","execution","generated_utc"
]

REJECTED_FIELDS = [
    "ranking_group","ranking_group_slug","asset_class","market_group","market_segment","l13_group_selection_score",
    "selection_quality_tier","group_selection_state","group_state","rejected_reason","rankable_count","top5_symbol_count",
    "risk_review_count","risk_review_ratio","thin_group_flag","ranking_group_heat","ranking_group_quality_score",
    "ranking_group_strength","source_l12_checksum","generated_utc"
]

FALLBACK_FIELDS = [
    "fallback_rank","fallback_scope","fallback_used","fallback_reason","selection_quality_tier","source_group_count",
    "selected_group_count_before_fallback","selected_group_count_after_fallback","market_condition_note","generated_utc"
]

@dataclass(frozen=True)
class L13PublishSummary:
    status: str
    reason: str
    valid_group_count: int = 0
    selected_ranking_group_count: int = 0
    rejected_ranking_group_count: int = 0
    fallback_used: bool = False
    fallback_reason: str = "not_required"
    selection_quality_tier: str = "not_available"
    market_condition_note: str = "not_available"
    top_selected_group: str = "not_available"
    write_failed_count: int = 0
    selected_path: str = "not_available"
    summary_path: str = "not_available"
    selection_desk_selected_path: str = "not_available"

EMPTY_L13_SUMMARY = L13PublishSummary("pending", "l13_not_run")


def _text(row: Dict[str, str], key: str, default: str = "not_available") -> str:
    value = str(row.get(key, default) or "").strip()
    return value if value else default


def _num(value: str | None) -> float:
    try:
        number = float(str(value or "").strip())
        return 0.0 if math.isnan(number) or math.isinf(number) else max(0.0, min(100.0, number))
    except ValueError:
        return 0.0


def _int(value: str | None) -> int:
    try:
        return int(float(str(value or "0").strip()))
    except ValueError:
        return 0


def _bool(value: str | None) -> bool:
    return str(value or "").strip().lower() == "true"


def _csv(path: Path) -> List[Dict[str, str]]:
    return [{str(k): "" if v is None else str(v) for k, v in row.items()} for row in csv.DictReader(io.StringIO(read_text(path).replace("\r\n", "\n")))]


def _csv_text(rows: List[Dict[str, str]], fields: List[str]) -> str:
    out = io.StringIO(newline="")
    writer = csv.DictWriter(out, fieldnames=fields, extrasaction="ignore", lineterminator="\n")
    writer.writeheader()
    for row in rows:
        writer.writerow({field: row.get(field, "not_available") for field in fields})
    return out.getvalue()


def _kv(path: Path) -> Dict[str, str]:
    data: Dict[str, str] = {}
    for raw in read_text(path).replace("\r\n", "\n").splitlines():
        if "=" in raw and not raw.strip().startswith("#"):
            k, v = raw.split("=", 1)
            data[k.strip()] = v.strip()
    return data


def _safe_slug(value: str) -> str:
    safe = value.strip() or "unknown"
    for ch in ['\\','/',':','*','?','"','<','>','|',' ']:
        safe = safe.replace(ch, "_")
    return safe or "unknown"


def _select_dir(outbox: Path) -> Path:
    return outbox.parents[2] / "Selection Desk" / "Groups"


def _write(path: Path, text: str, failed: List[Path]) -> None:
    if not atomic_write_text(path, text):
        failed.append(path)


def _score(row: Dict[str, str]) -> float:
    strength = _num(row.get("ranking_group_strength"))
    quality = _num(row.get("ranking_group_quality_score"))
    heat = _num(row.get("ranking_group_heat"))
    backup_depth = _int(row.get("backup_depth"))
    risk_count = _int(row.get("risk_review_count"))
    rankable_count = max(1, _int(row.get("rankable_count")))
    backup_depth_factor = min(100.0, backup_depth * 25.0)
    risk_review_ratio = max(0.0, min(1.0, risk_count / rankable_count))
    risk_review_penalty = min(100.0, risk_review_ratio * 100.0)
    return max(0.0, min(100.0, strength * 0.35 + quality * 0.30 + heat * 0.20 + backup_depth_factor * 0.10 - risk_review_penalty * 0.05))


def _risk_ratio(row: Dict[str, str]) -> float:
    rankable_count = max(1, _int(row.get("rankable_count")))
    return max(0.0, min(1.0, _int(row.get("risk_review_count")) / rankable_count))


def _tier(row: Dict[str, str]) -> Tuple[int, str, str, str]:
    state = _text(row, "group_state", "").upper()
    thin = _bool(row.get("thin_group_flag"))
    rankable = _int(row.get("rankable_count"))
    top5 = _int(row.get("top5_symbol_count"))
    quality = _num(row.get("ranking_group_quality_score"))
    strength = _num(row.get("ranking_group_strength"))
    risk_ratio = _risk_ratio(row)
    if state == "ACCEPTED" and not thin and rankable >= 5 and top5 >= 3 and risk_ratio <= 0.25 and quality >= 60.0 and strength >= 60.0:
        return (1, "SELECTED_STRONG", "strong", "strong_clean_group")
    if state in {"ACCEPTED", "ACCEPTED_WITH_REVIEW"} and not thin and rankable >= 3 and top5 >= 1:
        return (2, "SELECTED_WITH_REVIEW", "usable_review", "best_available_non_thin_review_group")
    if thin and rankable >= 1:
        return (4, "SELECTED_THIN_FALLBACK", "thin_fallback", "last_resort_thin_group")
    if rankable >= 2 and top5 >= 1:
        return (3, "SELECTED_WEAK_FALLBACK", "weak_fallback", "best_available_weak_group")
    if rankable >= 1:
        return (4, "SELECTED_THIN_FALLBACK", "thin_fallback", "last_resort_thin_group")
    return (99, "NOT_SELECTED_NO_RANKABLE_SYMBOLS", "source_degraded", "no_rankable_symbols")


def _base_row(row: Dict[str, str], checksum: str) -> Dict[str, str]:
    score = _score(row)
    ratio = _risk_ratio(row)
    return {
        "ranking_group": _text(row, "ranking_group", "Unknown"),
        "ranking_group_slug": _text(row, "ranking_group_slug", _safe_slug(_text(row, "ranking_group", "Unknown"))),
        "asset_class": _text(row, "asset_class", "Unknown"),
        "market_group": _text(row, "market_group", "Unknown"),
        "market_segment": _text(row, "market_segment", "Unknown"),
        "l13_group_selection_score": f"{score:.2f}",
        "ranking_group_heat": f"{_num(row.get('ranking_group_heat')):.2f}",
        "ranking_group_quality_score": f"{_num(row.get('ranking_group_quality_score')):.2f}",
        "ranking_group_strength": f"{_num(row.get('ranking_group_strength')):.2f}",
        "group_state": _text(row, "group_state", "not_available"),
        "rankable_count": str(_int(row.get("rankable_count"))),
        "top5_symbol_count": str(_int(row.get("top5_symbol_count"))),
        "backup_depth": str(_int(row.get("backup_depth"))),
        "risk_review_count": str(_int(row.get("risk_review_count"))),
        "risk_review_ratio": f"{ratio:.4f}",
        "thin_group_flag": "true" if _bool(row.get("thin_group_flag")) else "false",
        "source_l12_checksum": checksum,
        "generated_utc": utc_stamp(),
    }


def _selection_quality(selected: List[Dict[str, str]]) -> str:
    if not selected:
        return "source_degraded"
    tiers = {row.get("selection_quality_tier", "source_degraded") for row in selected}
    if tiers == {"strong"}:
        return "strong"
    if "thin_fallback" in tiers:
        return "thin_fallback"
    if "weak_fallback" in tiers:
        return "weak_fallback"
    if "market_segment_fallback" in tiers:
        return "market_segment_fallback"
    if "usable_review" in tiers:
        return "usable_review"
    return sorted(tiers)[0]


def _market_note(selection_quality_tier: str, fallback_used: bool) -> str:
    if selection_quality_tier == "strong":
        return "strong_groups_available_selected_best_of_best"
    if selection_quality_tier == "usable_review":
        return "selected_best_available_groups_because_strong_groups_unavailable_or_review_heavy"
    if selection_quality_tier == "weak_fallback":
        return "selected_best_available_weak_groups_for_inspection_only"
    if selection_quality_tier == "thin_fallback":
        return "selected_thin_fallback_groups_included_for_inspection_pipeline_truth"
    if fallback_used:
        return "fallback_used_to_avoid_empty_group_selection"
    return "source_degraded_no_safe_group_selection"


def _build(rows: List[Dict[str, str]], checksum: str) -> Tuple[List[Dict[str, str]], List[Dict[str, str]], List[Dict[str, str]], L13PublishSummary]:
    candidates: List[Tuple[int, float, Dict[str, str], str, str, str]] = []
    for row in rows:
        tier, state, quality_tier, reason = _tier(row)
        base = _base_row(row, checksum)
        candidates.append((tier, -float(base["l13_group_selection_score"]), base, state, quality_tier, reason))

    selected: List[Dict[str, str]] = []
    selected_keys: set[str] = set()
    fallback_used = False
    fallback_reasons: List[str] = []

    # Fill best-of-best first, then progressively loosen. Target is 7, max is 7.
    for allowed_tier in (1, 2, 3, 4):
        tier_rows = [c for c in candidates if c[0] == allowed_tier and c[2]["ranking_group"] not in selected_keys]
        tier_rows.sort(key=lambda item: (item[0], item[1], item[2]["ranking_group"]))
        for _tier_no, _neg_score, base, state, quality_tier, reason in tier_rows:
            if len(selected) >= L13_MAX_SELECTED_GROUPS:
                break
            selected_keys.add(base["ranking_group"])
            row = dict(base)
            row.update({
                "selection_rank": str(len(selected) + 1),
                "group_selection_state": state,
                "selection_quality_tier": quality_tier,
                "selected_flag": "true",
                "selected_reason": reason,
                "fallback_used": "false",
                "fallback_reason": "not_required",
                "market_condition_note": "pending_final_selection_quality",
                "meaning": "ranking_group_selected_for_candidate_sourcing_attention_only",
                "selection_runtime": "false",
                "trade_permission": "false",
                "entry_signal": "false",
                "execution": "false",
            })
            selected.append(row)
        if len(selected) >= L13_TARGET_SELECTED_GROUPS:
            break

    strong_candidate_count = sum(1 for c in candidates if c[0] == 1)
    non_strong_selected_count = sum(1 for row in selected if row["selection_quality_tier"] != "strong")
    if non_strong_selected_count > 0:
        fallback_used = True
        if strong_candidate_count <= 0:
            fallback_reasons.append("strong_clean_group_count_zero_selected_best_available_non_strong_groups")
        else:
            fallback_reasons.append("strong_clean_group_count_below_target_filled_with_best_available_non_strong_groups")
    if len(selected) < L13_MIN_SELECTED_GROUPS and selected:
        fallback_used = True
        fallback_reasons.append("selected_group_count_below_minimum_after_group_ladder")
    if not selected:
        fallback_reasons.append("no_rankable_l13_group_rows_available")

    quality = _selection_quality(selected)
    note = _market_note(quality, fallback_used)
    fallback_reason = ";".join(fallback_reasons) if fallback_reasons else "not_required"

    for idx, row in enumerate(selected, 1):
        row["selection_rank"] = str(idx)
        row["fallback_used"] = "true" if fallback_used else "false"
        row["fallback_reason"] = fallback_reason
        row["market_condition_note"] = note

    rejected: List[Dict[str, str]] = []
    for tier_no, _neg_score, base, state, quality_tier, reason in candidates:
        if base["ranking_group"] in selected_keys:
            continue
        rejected_reason = reason if tier_no == 99 else "not_selected_below_selected_cutoff"
        # Preserve the true no-rankable failure reason. A group with rankable_count=0 is not a
        # thin-but-usable group; labeling it as thin_group_below_preferred_depth hides the source
        # degradation and makes L13 rejection proof dishonest.
        if base["thin_group_flag"] == "true" and tier_no >= 3 and _int(base.get("rankable_count")) > 0:
            rejected_reason = "thin_group_below_preferred_depth"
        row = dict(base)
        row.update({
            "selection_quality_tier": quality_tier,
            "group_selection_state": state if tier_no == 99 else "NOT_SELECTED_LOWER_PRIORITY",
            "rejected_reason": rejected_reason,
        })
        rejected.append(row)
    rejected.sort(key=lambda r: (-float(r["l13_group_selection_score"]), r["ranking_group"]))

    fallback_rows = [{
        "fallback_rank": "1",
        "fallback_scope": "ranking_group_ladder",
        "fallback_used": "true" if fallback_used else "false",
        "fallback_reason": fallback_reason,
        "selection_quality_tier": quality,
        "source_group_count": str(len(rows)),
        "selected_group_count_before_fallback": str(strong_candidate_count),
        "selected_group_count_after_fallback": str(len(selected)),
        "market_condition_note": note,
        "generated_utc": utc_stamp(),
    }]

    summary = L13PublishSummary(
        status="accepted" if selected else "pending",
        reason="l13_dynamic_group_selection_published" if selected else "no_l13_groups_selected_from_l12_source",
        valid_group_count=sum(1 for c in candidates if c[0] < 99),
        selected_ranking_group_count=len(selected),
        rejected_ranking_group_count=len(rejected),
        fallback_used=fallback_used,
        fallback_reason=fallback_reason,
        selection_quality_tier=quality,
        market_condition_note=note,
        top_selected_group=selected[0]["ranking_group"] if selected else "not_available",
    )
    return selected, rejected, fallback_rows, summary


def _manifest(name: str, rows: List[Dict[str, str]], payload: str) -> str:
    return "\n".join([
        f"schema_name={name}_manifest",
        "schema_version=1",
        "layer_id=13",
        "layer_name=Layer 13 - Dynamic Ranking Group Selection",
        f"owner={L13_OWNER}",
        f"authority={L13_AUTHORITY}",
        f"row_count={len(rows)}",
        f"payload_checksum={payload_checksum(payload.splitlines())}",
        "selection_runtime=false",
        "trade_permission=false",
        "entry_signal=false",
        "execution=false",
        f"generated_utc={utc_stamp()}",
        f"generated_unix={unix_time()}",
        "",
    ])


def _summary(summary: L13PublishSummary) -> str:
    return "\n".join([
        f"schema_name={L13_SCHEMA_NAME}",
        "schema_version=1",
        f"owner_name={L13_OWNER}",
        "layer_id=13",
        "layer_name=Layer 13 - Dynamic Ranking Group Selection",
        f"status={summary.status}",
        f"reason={summary.reason}",
        "input_source=L12",
        f"valid_group_count={summary.valid_group_count}",
        f"selected_ranking_group_count={summary.selected_ranking_group_count}",
        f"rejected_ranking_group_count={summary.rejected_ranking_group_count}",
        f"fallback_used={'true' if summary.fallback_used else 'false'}",
        f"fallback_reason={summary.fallback_reason}",
        f"selection_quality_tier={summary.selection_quality_tier}",
        f"market_condition_note={summary.market_condition_note}",
        f"top_selected_group={summary.top_selected_group}",
        f"write_failed_count={summary.write_failed_count}",
        f"selected_path={summary.selected_path}",
        f"selection_desk_selected_path={summary.selection_desk_selected_path}",
        "meaning=ranking_group_selected_for_candidate_sourcing_attention_only",
        "selection_runtime=false",
        "trade_permission=false",
        "entry_signal=false",
        "execution=false",
        f"generated_utc={utc_stamp()}",
        f"generated_unix={unix_time()}",
        "",
    ])


def _selection_desk_text(selected: List[Dict[str, str]], summary: L13PublishSummary) -> str:
    lines = [
        "L13 SELECTED RANKING GROUPS",
        "----------------------------------------",
        f"status={summary.status}",
        f"selected_ranking_group_count={summary.selected_ranking_group_count}",
        f"selection_quality_tier={summary.selection_quality_tier}",
        f"fallback_used={'true' if summary.fallback_used else 'false'}",
        f"fallback_reason={summary.fallback_reason}",
        f"market_condition_note={summary.market_condition_note}",
    ]
    for row in selected:
        lines.append(f"#{row['selection_rank']} {row['ranking_group']} score={row['l13_group_selection_score']} state={row['group_selection_state']} tier={row['selection_quality_tier']} reason={row['selected_reason']}")
    lines.extend(["selection_runtime=false", "trade_permission=false", "entry_signal=false", "execution=false", ""])
    return "\n".join(lines)


def publish_l13_dynamic_ranking_group_selection(outbox_root: Path) -> L13PublishSummary:
    l12 = outbox_root / "Layers" / "Layer_12_Ranking_Group_Heat_Quality"
    needed = [l12 / "l12_group_heat_quality_summary.txt", l12 / "l12_group_heat_quality.csv", l12 / "l12_group_heat_quality.manifest"]
    missing = [str(p) for p in needed if not p.exists()]
    if missing:
        return L13PublishSummary("pending", "missing_required_l13_source: " + ";".join(missing))
    try:
        l12_summary = _kv(l12 / "l12_group_heat_quality_summary.txt")
        l12_status = l12_summary.get("status", "pending")
        if l12_status not in {"accepted", "write_degraded"}:
            return L13PublishSummary("pending" if l12_status == "pending" else "degraded", "l12_not_accepted_status=" + l12_status)
        source_text = read_text(l12 / "l12_group_heat_quality.csv")
        source_checksum = payload_checksum(source_text.splitlines())
        rows = _csv(l12 / "l12_group_heat_quality.csv")
        if not rows:
            return L13PublishSummary("pending", "no_l12_groups_available_for_l13_selection")
        selected, rejected, fallback_rows, base_summary = _build(rows, source_checksum)
        layer = outbox_root / "Layers" / L13_LAYER_FOLDER
        groups = layer / "RankingGroups"
        visible = _select_dir(outbox_root)
        for d in (layer, groups, visible):
            d.mkdir(parents=True, exist_ok=True)
        failed: List[Path] = []
        selected_csv = _csv_text(selected, SELECTED_FIELDS)
        rejected_csv = _csv_text(rejected, REJECTED_FIELDS)
        fallback_csv = _csv_text(fallback_rows, FALLBACK_FIELDS)
        _write(layer / "l13_selected_ranking_groups.csv", selected_csv, failed)
        _write(layer / "l13_rejected_ranking_groups.csv", rejected_csv, failed)
        _write(layer / "l13_fallback_decisions.csv", fallback_csv, failed)
        _write(layer / "l13_selected_ranking_groups.manifest", _manifest("l13_selected_ranking_groups", selected, selected_csv), failed)
        for row in selected:
            _write(groups / (row["ranking_group_slug"] + ".selection.txt"), "\n".join([f"{k}={row.get(k, 'not_available')}" for k in SELECTED_FIELDS] + [""]), failed)
        for row in rejected:
            _write(groups / (row["ranking_group_slug"] + ".selection.txt"), "\n".join([f"{k}={row.get(k, 'not_available')}" for k in REJECTED_FIELDS] + ["selected_flag=false", "selection_runtime=false", "trade_permission=false", "entry_signal=false", "execution=false", ""]), failed)
        summary = L13PublishSummary(
            status=base_summary.status if not failed else "write_degraded",
            reason=base_summary.reason if not failed else "one_or_more_l13_outputs_failed",
            valid_group_count=base_summary.valid_group_count,
            selected_ranking_group_count=base_summary.selected_ranking_group_count,
            rejected_ranking_group_count=base_summary.rejected_ranking_group_count,
            fallback_used=base_summary.fallback_used,
            fallback_reason=base_summary.fallback_reason,
            selection_quality_tier=base_summary.selection_quality_tier,
            market_condition_note=base_summary.market_condition_note,
            top_selected_group=base_summary.top_selected_group,
            write_failed_count=len(failed),
            selected_path=str(layer / "l13_selected_ranking_groups.csv"),
            summary_path=str(layer / "l13_group_selection_summary.txt"),
            selection_desk_selected_path=str(visible / "00_Selected_Ranking_Groups.txt"),
        )
        _write(layer / "l13_group_selection_summary.txt", _summary(summary), failed)
        _write(visible / "00_Selected_Ranking_Groups.csv", selected_csv, failed)
        _write(visible / "00_Selected_Ranking_Groups.txt", _selection_desk_text(selected, summary), failed)
        return summary
    except Exception as exc:
        return L13PublishSummary("exception", f"{type(exc).__name__}: {exc}")
