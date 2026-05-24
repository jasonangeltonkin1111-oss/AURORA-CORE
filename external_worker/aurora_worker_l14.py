from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Tuple
import csv
import io
import math

from aurora_worker_io import atomic_write_text, payload_checksum, read_text, unix_time, utc_stamp

L14_LAYER_FOLDER = "Layer_14_Ranking_Group_Leader_Candidate_Pool"
L14_OWNER = "Runtime 5 - Taxonomy / Ranking Group Owner"
L14_SCHEMA_NAME = "l14_ranking_group_leader_candidate_pool"
L14_AUTHORITY = "candidate_pool_sourcing_only"

CANDIDATE_FIELDS = [
    "candidate_pool_rank","symbol","canonical_symbol","ranking_group","ranking_group_slug","asset_class","market_group","market_segment",
    "candidate_source","leader_or_backup","backup_included_flag","candidate_reason","review_excluded_flag",
    "l14_candidate_priority_score","l11_group_score","l11_top_rank","l11_rank_state","risk_review_flag",
    "source_group_selection_rank","source_group_selection_state","source_group_selection_tier","source_group_fallback_used",
    "source_group_fallback_reason","source_group_selection_score","source_group_strength","source_group_heat","source_group_quality",
    "source_l11_checksum","source_l12_checksum","source_l13_checksum","meaning","candidate_pool_runtime","trade_permission",
    "entry_signal","execution","generated_utc"
]

@dataclass(frozen=True)
class L14PublishSummary:
    status: str
    reason: str
    selected_group_count: int = 0
    candidate_pool_size: int = 0
    leader_candidate_count: int = 0
    backup_candidate_count: int = 0
    review_candidate_count: int = 0
    thin_fallback_candidate_count: int = 0
    write_failed_count: int = 0
    top_candidate: str = "not_available"
    candidate_pool_path: str = "not_available"
    summary_path: str = "not_available"
    selection_desk_candidate_pool_path: str = "not_available"

EMPTY_L14_SUMMARY = L14PublishSummary("pending", "l14_not_run")


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


def _manifest(name: str, rows: List[Dict[str, str]], payload: str) -> str:
    return "\n".join([
        f"schema_name={name}_manifest",
        "schema_version=1",
        "layer_id=14",
        "layer_name=Layer 14 - Ranking Group Leader Candidate Pool",
        f"owner={L14_OWNER}",
        f"authority={L14_AUTHORITY}",
        f"row_count={len(rows)}",
        f"payload_checksum={payload_checksum(payload.splitlines())}",
        "candidate_pool_runtime=false",
        "trade_permission=false",
        "entry_signal=false",
        "execution=false",
        f"generated_utc={utc_stamp()}",
        f"generated_unix={unix_time()}",
        "",
    ])


def _summary(summary: L14PublishSummary) -> str:
    return "\n".join([
        f"schema_name={L14_SCHEMA_NAME}",
        "schema_version=1",
        f"owner_name={L14_OWNER}",
        "layer_id=14",
        "layer_name=Layer 14 - Ranking Group Leader Candidate Pool",
        f"status={summary.status}",
        f"reason={summary.reason}",
        "input_source=L13_selected_groups+L11_top5+L12_group_heat_quality",
        f"selected_group_count={summary.selected_group_count}",
        f"candidate_pool_size={summary.candidate_pool_size}",
        f"leader_candidate_count={summary.leader_candidate_count}",
        f"backup_candidate_count={summary.backup_candidate_count}",
        f"review_candidate_count={summary.review_candidate_count}",
        f"thin_fallback_candidate_count={summary.thin_fallback_candidate_count}",
        f"top_candidate={summary.top_candidate}",
        f"write_failed_count={summary.write_failed_count}",
        f"candidate_pool_path={summary.candidate_pool_path}",
        f"selection_desk_candidate_pool_path={summary.selection_desk_candidate_pool_path}",
        "meaning=raw_candidate_pool_only_not_diversified_not_global_top10",
        "candidate_pool_runtime=false",
        "trade_permission=false",
        "entry_signal=false",
        "execution=false",
        f"generated_utc={utc_stamp()}",
        f"generated_unix={unix_time()}",
        "",
    ])


def _candidate_score(l11_score: float, l13_score: float, l12_strength: float, top_rank: int) -> float:
    if top_rank <= 1:
        rank_adjust = 5.0
    else:
        rank_adjust = -2.0 * min(4, top_rank - 1)
    return max(0.0, min(100.0, l11_score * 0.60 + l13_score * 0.25 + l12_strength * 0.10 + rank_adjust))


def _build(selected: List[Dict[str, str]], top5: List[Dict[str, str]], heat: List[Dict[str, str]], checksums: Dict[str, str]) -> List[Dict[str, str]]:
    selected_by_group = {_text(row, "ranking_group", "Unknown"): row for row in selected}
    heat_by_group = {_text(row, "ranking_group", "Unknown"): row for row in heat}
    out: List[Dict[str, str]] = []
    for row in top5:
        group = _text(row, "ranking_group", "Unknown")
        selected_row = selected_by_group.get(group)
        if selected_row is None:
            continue
        heat_row = heat_by_group.get(group, {})
        top_rank = _int(row.get("top_rank"))
        l11_score = _num(row.get("l11_group_score"))
        l13_score = _num(selected_row.get("l13_group_selection_score"))
        l12_strength = _num(heat_row.get("ranking_group_strength"))
        leader = top_rank == 1 or _text(row, "leader_flag", "false").lower() == "true"
        risk_review = _text(row, "risk_review_flag", "false").lower() == "true"
        tier = _text(selected_row, "selection_quality_tier", "not_available")
        state = _text(selected_row, "group_selection_state", "not_available")
        candidate_source = "ranking_group_leader" if leader else "ranking_group_backup"
        reason_parts = ["from_l13_selected_group", f"group_state={state}", f"tier={tier}", f"top_rank={top_rank}"]
        if risk_review:
            reason_parts.append("risk_review_visible_not_excluded")
        if "thin" in tier or "THIN" in state:
            reason_parts.append("thin_fallback_context_preserved")
        out.append({
            "candidate_pool_rank": "0",
            "symbol": _text(row, "symbol"),
            "canonical_symbol": _text(row, "canonical_symbol", _text(row, "symbol")),
            "ranking_group": group,
            "ranking_group_slug": _text(row, "ranking_group_slug", _safe_slug(group)),
            "asset_class": _text(selected_row, "asset_class", _text(heat_row, "asset_class", "Unknown")),
            "market_group": _text(selected_row, "market_group", _text(heat_row, "market_group", "Unknown")),
            "market_segment": _text(selected_row, "market_segment", _text(heat_row, "market_segment", "Unknown")),
            "candidate_source": candidate_source,
            "leader_or_backup": "leader" if leader else "backup",
            "backup_included_flag": "false" if leader else "true",
            "candidate_reason": ";".join(reason_parts),
            "review_excluded_flag": "false",
            "l14_candidate_priority_score": f"{_candidate_score(l11_score, l13_score, l12_strength, top_rank):.2f}",
            "l11_group_score": f"{l11_score:.2f}",
            "l11_top_rank": str(top_rank),
            "l11_rank_state": _text(row, "rank_state"),
            "risk_review_flag": "true" if risk_review else "false",
            "source_group_selection_rank": _text(selected_row, "selection_rank"),
            "source_group_selection_state": state,
            "source_group_selection_tier": tier,
            "source_group_fallback_used": _text(selected_row, "fallback_used", "false"),
            "source_group_fallback_reason": _text(selected_row, "fallback_reason", "not_required"),
            "source_group_selection_score": f"{l13_score:.2f}",
            "source_group_strength": f"{l12_strength:.2f}",
            "source_group_heat": f"{_num(heat_row.get('ranking_group_heat')):.2f}",
            "source_group_quality": f"{_num(heat_row.get('ranking_group_quality_score')):.2f}",
            "source_l11_checksum": checksums.get("l11", "not_available"),
            "source_l12_checksum": checksums.get("l12", "not_available"),
            "source_l13_checksum": checksums.get("l13", "not_available"),
            "meaning": "raw_candidate_pool_only_not_diversified_not_global_top10",
            "candidate_pool_runtime": "false",
            "trade_permission": "false",
            "entry_signal": "false",
            "execution": "false",
            "generated_utc": utc_stamp(),
        })
    out.sort(key=lambda r: (-float(r["l14_candidate_priority_score"]), int(r["source_group_selection_rank"] or "999"), int(r["l11_top_rank"] or "999"), r["symbol"]))
    for idx, row in enumerate(out, 1):
        row["candidate_pool_rank"] = str(idx)
    return out


def _selection_desk_text(rows: List[Dict[str, str]], summary: L14PublishSummary) -> str:
    lines = [
        "L14 RANKING GROUP LEADER CANDIDATE POOL",
        "----------------------------------------",
        f"status={summary.status}",
        f"candidate_pool_size={summary.candidate_pool_size}",
        f"leader_candidate_count={summary.leader_candidate_count}",
        f"backup_candidate_count={summary.backup_candidate_count}",
        f"thin_fallback_candidate_count={summary.thin_fallback_candidate_count}",
    ]
    for row in rows:
        lines.append(f"#{row['candidate_pool_rank']} {row['symbol']} group={row['ranking_group']} source={row['candidate_source']} score={row['l14_candidate_priority_score']} reason={row['candidate_reason']}")
    lines.extend(["candidate_pool_runtime=false", "trade_permission=false", "entry_signal=false", "execution=false", ""])
    return "\n".join(lines)


def publish_l14_ranking_group_leader_candidate_pool(outbox_root: Path) -> L14PublishSummary:
    l11 = outbox_root / "Layers" / "Layer_11_Symbol_Ranking_Inside_Ranking_Group"
    l12 = outbox_root / "Layers" / "Layer_12_Ranking_Group_Heat_Quality"
    l13 = outbox_root / "Layers" / "Layer_13_Dynamic_Ranking_Group_Selection"
    needed = [
        l13 / "l13_group_selection_summary.txt",
        l13 / "l13_selected_ranking_groups.csv",
        l13 / "l13_selected_ranking_groups.manifest",
        l11 / "ranking_group_top5.csv",
        l11 / "ranked_symbols_by_group.manifest",
        l12 / "l12_group_heat_quality.csv",
        l12 / "l12_group_heat_quality.manifest",
    ]
    missing = [str(p) for p in needed if not p.exists()]
    if missing:
        return L14PublishSummary("pending", "missing_required_l14_source: " + ";".join(missing))
    try:
        l13_summary = _kv(l13 / "l13_group_selection_summary.txt")
        l13_status = l13_summary.get("status", "pending")
        if l13_status not in {"accepted", "write_degraded"}:
            return L14PublishSummary("pending" if l13_status == "pending" else "degraded", "l13_not_accepted_status=" + l13_status)
        selected_text = read_text(l13 / "l13_selected_ranking_groups.csv")
        top5_text = read_text(l11 / "ranking_group_top5.csv")
        heat_text = read_text(l12 / "l12_group_heat_quality.csv")
        rows = _build(
            _csv(l13 / "l13_selected_ranking_groups.csv"),
            _csv(l11 / "ranking_group_top5.csv"),
            _csv(l12 / "l12_group_heat_quality.csv"),
            {
                "l13": payload_checksum(selected_text.splitlines()),
                "l11": payload_checksum(top5_text.splitlines()),
                "l12": payload_checksum(heat_text.splitlines()),
            },
        )
        if not rows:
            return L14PublishSummary("pending", "no_l14_candidates_from_l13_selected_groups_and_l11_top5")
        layer = outbox_root / "Layers" / L14_LAYER_FOLDER
        groups = layer / "RankingGroups"
        visible = _select_dir(outbox_root)
        for d in (layer, groups, visible):
            d.mkdir(parents=True, exist_ok=True)
        failed: List[Path] = []
        csv_text = _csv_text(rows, CANDIDATE_FIELDS)
        _write(layer / "l14_candidate_pool.csv", csv_text, failed)
        _write(layer / "l14_candidate_pool.manifest", _manifest("l14_candidate_pool", rows, csv_text), failed)
        grouped: Dict[str, List[Dict[str, str]]] = {}
        for row in rows:
            grouped.setdefault(row["ranking_group"], []).append(row)
        for group, members in grouped.items():
            slug = _safe_slug(group)
            text = "\n".join(["L14 CANDIDATE POOL BY RANKING GROUP", "----------------------------------------", f"ranking_group={group}"] + [f"#{m['candidate_pool_rank']} {m['symbol']} source={m['candidate_source']} score={m['l14_candidate_priority_score']} reason={m['candidate_reason']}" for m in members] + ["candidate_pool_runtime=false", "trade_permission=false", "entry_signal=false", "execution=false", ""])
            _write(groups / (slug + ".candidate_pool.txt"), text, failed)
        leader_count = sum(1 for r in rows if r["leader_or_backup"] == "leader")
        backup_count = sum(1 for r in rows if r["backup_included_flag"] == "true")
        review_count = sum(1 for r in rows if r["risk_review_flag"] == "true")
        thin_count = sum(1 for r in rows if "thin" in r["source_group_selection_tier"].lower() or "THIN" in r["source_group_selection_state"])
        summary = L14PublishSummary(
            status="accepted" if not failed else "write_degraded",
            reason="l14_candidate_pool_published" if not failed else "one_or_more_l14_outputs_failed",
            selected_group_count=len({_text(r, "ranking_group") for r in _csv(l13 / "l13_selected_ranking_groups.csv")}),
            candidate_pool_size=len(rows),
            leader_candidate_count=leader_count,
            backup_candidate_count=backup_count,
            review_candidate_count=review_count,
            thin_fallback_candidate_count=thin_count,
            write_failed_count=len(failed),
            top_candidate=rows[0]["symbol"],
            candidate_pool_path=str(layer / "l14_candidate_pool.csv"),
            summary_path=str(layer / "l14_candidate_pool_summary.txt"),
            selection_desk_candidate_pool_path=str(visible / "00_Ranking_Group_Leader_Candidate_Pool.txt"),
        )
        _write(layer / "l14_candidate_pool_summary.txt", _summary(summary), failed)
        _write(visible / "00_Ranking_Group_Leader_Candidate_Pool.csv", csv_text, failed)
        _write(visible / "00_Ranking_Group_Leader_Candidate_Pool.txt", _selection_desk_text(rows, summary), failed)
        return summary
    except Exception as exc:
        return L14PublishSummary("exception", f"{type(exc).__name__}: {exc}")
