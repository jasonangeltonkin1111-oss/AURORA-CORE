from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Tuple
import csv
import io
import math

from aurora_worker_io import atomic_write_text, payload_checksum, read_text, unix_time, utc_stamp

L16_LAYER_FOLDER = "Layer_16_Global_Top10_Builder"
L16_OWNER = "Runtime 5 - Taxonomy / Ranking Group Owner"
L16_AUTHORITY = "global_top10_inspection_basket_only"
L16_SCHEMA_NAME = "l16_global_top10_builder"
L16_MAX_CORR_ABS = 0.30
L16_TARGET_COUNT = 10

TOP10_FIELDS = [
    "global_top10_rank", "symbol", "canonical_symbol", "ranking_group", "asset_class", "market_group", "market_segment",
    "l16_primary_score", "l14_candidate_priority_score", "l15_diversity_score", "source_group_selection_score", "source_group_strength", "source_group_quality",
    "max_corr_to_selected", "max_corr_pair_symbol", "correlation_clean_flag", "correlation_state", "correlation_confidence",
    "currency_overlap_score", "ranking_group_overlap_score", "leader_or_backup", "candidate_source", "selection_reason",
    "selected_after_reject_count", "backup_fill_used", "fallback_reason", "meaning", "global_top10_runtime", "trade_permission", "entry_signal", "execution", "generated_utc",
]

REJECT_FIELDS = [
    "candidate_rank", "symbol", "ranking_group", "l16_primary_score", "reject_stage", "reject_reason", "conflicting_selected_symbol",
    "pairwise_corr_abs", "ranking_group_count_if_added", "currency_overlap_score", "fallback_eligible", "generated_utc",
]

FALLBACK_FIELDS = [
    "slot", "symbol", "ranking_group", "fallback_reason", "l16_primary_score", "max_corr_to_selected", "meaning", "trade_permission", "entry_signal", "execution", "generated_utc",
]


@dataclass(frozen=True)
class L16PublishSummary:
    status: str
    reason: str
    candidate_pool_size: int = 0
    l15_candidate_count: int = 0
    selected_count: int = 0
    unfilled_slots_count: int = 10
    reject_count: int = 0
    correlation_reject_count: int = 0
    group_cap_reject_count: int = 0
    fallback_count: int = 0
    group_count: int = 0
    write_failed_count: int = 0
    top_symbol: str = "not_available"
    output_path: str = "not_available"
    summary_path: str = "not_available"
    selection_desk_path: str = "not_available"


EMPTY_L16_SUMMARY = L16PublishSummary("pending", "l16_not_run")


def _text(row: Dict[str, str], key: str, default: str = "not_available") -> str:
    value = str(row.get(key, default) or "").strip()
    return value if value else default


def _num(value: str | None, default: float = 0.0) -> float:
    try:
        number = float(str(value or "").strip())
        return default if math.isnan(number) or math.isinf(number) else number
    except ValueError:
        return default


def _int(value: str | None, default: int = 0) -> int:
    try:
        return int(float(str(value or str(default)).strip()))
    except ValueError:
        return default


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


def _root_from_outbox(outbox: Path) -> Path:
    return outbox.parents[2]


def _global_dir(outbox: Path) -> Path:
    return _root_from_outbox(outbox) / "Selection Desk" / "Global"


def _write(path: Path, text: str, failed: List[Path]) -> None:
    if not atomic_write_text(path, text):
        failed.append(path)


def _score_candidate(row: Dict[str, str]) -> float:
    return max(0.0, min(100.0,
        _num(row.get("l14_candidate_priority_score")) * 0.55
        + _num(row.get("diversity_score")) * 0.20
        + _num(row.get("source_group_selection_score")) * 0.10
        + _num(row.get("source_group_strength")) * 0.10
        + _num(row.get("source_group_quality")) * 0.05
    ))


def _pair_key(a: str, b: str) -> Tuple[str, str]:
    return tuple(sorted((a, b)))


def _pair_corr(pair_rows: List[Dict[str, str]]) -> Dict[Tuple[str, str], Tuple[float | None, str]]:
    out: Dict[Tuple[str, str], Tuple[float | None, str]] = {}
    for row in pair_rows:
        a = _text(row, "symbol_a", "")
        b = _text(row, "symbol_b", "")
        if not a or not b:
            continue
        corr_text = _text(row, "correlation_abs", "not_available")
        state = _text(row, "correlation_state", "CORRELATION_UNAVAILABLE")
        corr = None if corr_text == "not_available" else _num(corr_text, default=float("nan"))
        if corr is not None and (math.isnan(corr) or math.isinf(corr)):
            corr = None
        out[_pair_key(a, b)] = (corr, state)
    return out


def _group_cap(group_count: int, pool_size: int) -> int:
    if pool_size <= L16_TARGET_COUNT:
        return 3
    if group_count <= 2:
        return 99
    if group_count <= 4:
        return 3
    return 2


def _join_candidates(l14_rows: List[Dict[str, str]], l15_rows: List[Dict[str, str]]) -> List[Dict[str, str]]:
    l15_by_symbol = {_text(r, "symbol", ""): r for r in l15_rows}
    rows: List[Dict[str, str]] = []
    for l14 in l14_rows:
        symbol = _text(l14, "symbol", "")
        if not symbol:
            continue
        l15 = l15_by_symbol.get(symbol, {})
        row = dict(l14)
        for key in ["diversity_score", "correlation_confidence", "correlation_state", "corr_to_pool_max_abs", "corr_pair_max_symbol", "currency_overlap_score", "ranking_group_overlap_score", "l16_constraint_hint"]:
            row[key] = _text(l15, key, "not_available")
        row["l16_primary_score"] = f"{_score_candidate(row):.2f}"
        rows.append(row)
    rows.sort(key=lambda r: (-_num(r.get("l16_primary_score")), _int(r.get("candidate_pool_rank"), 999), _text(r, "symbol")))
    return rows


def _build_top10(candidates: List[Dict[str, str]], pair_corr: Dict[Tuple[str, str], Tuple[float | None, str]], group_count: int) -> Tuple[List[Dict[str, str]], List[Dict[str, str]], List[Dict[str, str]]]:
    selected: List[Dict[str, str]] = []
    rejects: List[Dict[str, str]] = []
    fallbacks: List[Dict[str, str]] = []
    group_limit = _group_cap(group_count, len(candidates))
    group_counts: Dict[str, int] = {}
    reject_seen = 0

    for cand in candidates:
        if len(selected) >= L16_TARGET_COUNT:
            break
        symbol = _text(cand, "symbol")
        group = _text(cand, "ranking_group")
        group_after = group_counts.get(group, 0) + 1
        if group_after > group_limit:
            rejects.append({
                "candidate_rank": _text(cand, "candidate_pool_rank"), "symbol": symbol, "ranking_group": group,
                "l16_primary_score": _text(cand, "l16_primary_score"), "reject_stage": "group_cap", "reject_reason": "ranking_group_cap_exceeded",
                "conflicting_selected_symbol": "not_available", "pairwise_corr_abs": "not_available", "ranking_group_count_if_added": str(group_after),
                "currency_overlap_score": _text(cand, "currency_overlap_score"), "fallback_eligible": "true", "generated_utc": utc_stamp(),
            })
            reject_seen += 1
            continue
        max_corr = 0.0
        max_pair = "none"
        corr_state = "LOW_CORRELATION"
        blocked = False
        unavailable = False
        for sel in selected:
            sel_symbol = _text(sel, "symbol")
            corr, state = pair_corr.get(_pair_key(symbol, sel_symbol), (None, "CORRELATION_UNAVAILABLE"))
            if corr is None:
                unavailable = True
                corr_state = state
                continue
            if corr > max_corr:
                max_corr = corr
                max_pair = sel_symbol
                corr_state = state
            if corr > L16_MAX_CORR_ABS:
                rejects.append({
                    "candidate_rank": _text(cand, "candidate_pool_rank"), "symbol": symbol, "ranking_group": group,
                    "l16_primary_score": _text(cand, "l16_primary_score"), "reject_stage": "correlation_cap", "reject_reason": "pairwise_correlation_above_0_30",
                    "conflicting_selected_symbol": sel_symbol, "pairwise_corr_abs": f"{corr:.6f}", "ranking_group_count_if_added": str(group_after),
                    "currency_overlap_score": _text(cand, "currency_overlap_score"), "fallback_eligible": "false", "generated_utc": utc_stamp(),
                })
                reject_seen += 1
                blocked = True
                break
        if blocked:
            continue
        reason = "highest_score_seed" if not selected else "score_order_passed_correlation_and_group_caps"
        if unavailable:
            reason += ";some_pair_correlation_unavailable_degraded_visible"
        rank = len(selected) + 1
        out = {
            "global_top10_rank": str(rank), "symbol": symbol, "canonical_symbol": _text(cand, "canonical_symbol", symbol),
            "ranking_group": group, "asset_class": _text(cand, "asset_class"), "market_group": _text(cand, "market_group"), "market_segment": _text(cand, "market_segment"),
            "l16_primary_score": _text(cand, "l16_primary_score"), "l14_candidate_priority_score": _text(cand, "l14_candidate_priority_score"),
            "l15_diversity_score": _text(cand, "diversity_score"), "source_group_selection_score": _text(cand, "source_group_selection_score"),
            "source_group_strength": _text(cand, "source_group_strength"), "source_group_quality": _text(cand, "source_group_quality"),
            "max_corr_to_selected": f"{max_corr:.6f}" if selected else "0.000000", "max_corr_pair_symbol": max_pair,
            "correlation_clean_flag": "false" if unavailable else "true", "correlation_state": "DEGRADED_UNAVAILABLE" if unavailable else corr_state,
            "correlation_confidence": _text(cand, "correlation_confidence"), "currency_overlap_score": _text(cand, "currency_overlap_score"),
            "ranking_group_overlap_score": _text(cand, "ranking_group_overlap_score"), "leader_or_backup": _text(cand, "leader_or_backup"),
            "candidate_source": _text(cand, "candidate_source"), "selection_reason": reason, "selected_after_reject_count": str(reject_seen),
            "backup_fill_used": "false", "fallback_reason": "not_required", "meaning": "global_top10_inspection_basket_only_not_trade_permission",
            "global_top10_runtime": "false", "trade_permission": "false", "entry_signal": "false", "execution": "false", "generated_utc": utc_stamp(),
        }
        selected.append(out)
        group_counts[group] = group_after
    return selected, rejects, fallbacks


def _manifest(payload: str, selected_count: int) -> str:
    return "\n".join([
        "schema_name=l16_global_top10_manifest", "schema_version=1", "layer_id=16", "layer_name=Layer 16 - Global Top 10 Builder",
        f"owner={L16_OWNER}", f"authority={L16_AUTHORITY}", f"selected_count={selected_count}", f"payload_checksum={payload_checksum(payload.splitlines())}",
        f"max_allowed_pairwise_correlation_abs={L16_MAX_CORR_ABS:.2f}", "threshold_status=untested_default_not_holy_law",
        "global_top10_runtime=false", "trade_permission=false", "entry_signal=false", "execution=false", f"generated_utc={utc_stamp()}", f"generated_unix={unix_time()}", "",
    ])


def _summary_text(summary: L16PublishSummary) -> str:
    return "\n".join([
        f"schema_name={L16_SCHEMA_NAME}", "schema_version=1", f"owner_name={L16_OWNER}", "layer_id=16", "layer_name=Layer 16 - Global Top 10 Builder",
        f"status={summary.status}", f"reason={summary.reason}", "input_source=L14_candidate_pool+L15_correlation_diversity_outputs",
        f"candidate_pool_size={summary.candidate_pool_size}", f"l15_candidate_count={summary.l15_candidate_count}", f"selected_count={summary.selected_count}",
        f"unfilled_slots_count={summary.unfilled_slots_count}", f"reject_count={summary.reject_count}", f"correlation_reject_count={summary.correlation_reject_count}",
        f"group_cap_reject_count={summary.group_cap_reject_count}", f"fallback_count={summary.fallback_count}", f"group_count={summary.group_count}",
        f"top_symbol={summary.top_symbol}", f"write_failed_count={summary.write_failed_count}", f"output_path={summary.output_path}", f"selection_desk_path={summary.selection_desk_path}",
        f"max_allowed_pairwise_correlation_abs={L16_MAX_CORR_ABS:.2f}", "threshold_status=untested_default_not_holy_law",
        "meaning=global_top10_inspection_basket_only_not_trade_permission", "global_top10_runtime=false", "trade_permission=false", "entry_signal=false", "execution=false",
        f"generated_utc={utc_stamp()}", f"generated_unix={unix_time()}", "",
    ])


def _selection_text(rows: List[Dict[str, str]], rejects: List[Dict[str, str]], summary: L16PublishSummary) -> str:
    lines = ["L16 GLOBAL TOP 10 INSPECTION BASKET", "----------------------------------------", f"status={summary.status}", f"reason={summary.reason}", f"selected_count={summary.selected_count}", f"unfilled_slots_count={summary.unfilled_slots_count}", f"correlation_reject_count={summary.correlation_reject_count}", f"group_cap_reject_count={summary.group_cap_reject_count}", f"max_allowed_pairwise_correlation_abs={L16_MAX_CORR_ABS:.2f}", "threshold_status=untested_default_not_holy_law", "", "TOP 10"]
    for row in rows:
        lines.append(f"#{row['global_top10_rank']} {row['symbol']} group={row['ranking_group']} score={row['l16_primary_score']} max_corr={row['max_corr_to_selected']} pair={row['max_corr_pair_symbol']} state={row['correlation_state']} reason={row['selection_reason']}")
    if summary.unfilled_slots_count > 0:
        lines.append("")
        lines.append(f"UNFILLED_SLOTS={summary.unfilled_slots_count}")
        lines.append("unfilled_reason=strict_correlation_or_group_caps_prevented_clean_fill")
    lines.append("")
    lines.append("REJECT SNAPSHOT")
    for row in rejects[:20]:
        lines.append(f"{row['symbol']} reject={row['reject_reason']} conflict={row['conflicting_selected_symbol']} corr={row['pairwise_corr_abs']} group_if_added={row['ranking_group_count_if_added']}")
    lines.extend(["", "global_top10_runtime=false", "trade_permission=false", "entry_signal=false", "execution=false", ""])
    return "\n".join(lines)


def publish_l16_global_top10_builder(outbox_root: Path) -> L16PublishSummary:
    l14 = outbox_root / "Layers" / "Layer_14_Ranking_Group_Leader_Candidate_Pool"
    l15 = outbox_root / "Layers" / "Layer_15_Correlation_Diversity_Selection"
    needed = [
        l14 / "l14_candidate_pool.csv",
        l14 / "l14_candidate_pool_summary.txt",
        l15 / "l15_candidate_diversity_scores.csv",
        l15 / "l15_candidate_correlation_matrix.csv",
        l15 / "l15_group_diversity_summary.csv",
        l15 / "l15_correlation_diversity_summary.txt",
    ]
    missing = [str(p) for p in needed if not p.exists()]
    if missing:
        return L16PublishSummary("pending", "missing_required_l16_source: " + ";".join(missing))
    try:
        l14_status = _kv(l14 / "l14_candidate_pool_summary.txt").get("status", "pending")
        l15_status = _kv(l15 / "l15_correlation_diversity_summary.txt").get("status", "pending")
        if l14_status not in {"accepted", "write_degraded"}:
            return L16PublishSummary("pending", "l14_not_accepted_status=" + l14_status)
        if l15_status not in {"accepted", "degraded", "write_degraded"}:
            return L16PublishSummary("pending", "l15_not_accepted_status=" + l15_status)
        l14_rows = _csv(l14 / "l14_candidate_pool.csv")
        l15_rows = _csv(l15 / "l15_candidate_diversity_scores.csv")
        pair_rows = _csv(l15 / "l15_candidate_correlation_matrix.csv")
        group_rows = _csv(l15 / "l15_group_diversity_summary.csv")
        candidates = _join_candidates(l14_rows, l15_rows)
        if not candidates:
            return L16PublishSummary("pending", "no_joined_l14_l15_candidates")
        selected, rejects, fallbacks = _build_top10(candidates, _pair_corr(pair_rows), len(group_rows))
        layer = outbox_root / "Layers" / L16_LAYER_FOLDER
        visible = _global_dir(outbox_root)
        for folder in (layer, visible):
            folder.mkdir(parents=True, exist_ok=True)
        failed: List[Path] = []
        top_text = _csv_text(selected, TOP10_FIELDS)
        reject_text = _csv_text(rejects, REJECT_FIELDS)
        fallback_text = _csv_text(fallbacks, FALLBACK_FIELDS)
        unfilled = max(0, L16_TARGET_COUNT - len(selected))
        corr_rejects = sum(1 for r in rejects if r.get("reject_stage") == "correlation_cap")
        group_rejects = sum(1 for r in rejects if r.get("reject_stage") == "group_cap")
        status = "accepted" if len(selected) == L16_TARGET_COUNT else "degraded"
        reason = "l16_global_top10_published" if status == "accepted" else "l16_published_with_unfilled_slots_due_to_constraints"
        summary = L16PublishSummary(status=status, reason=reason, candidate_pool_size=len(l14_rows), l15_candidate_count=len(l15_rows), selected_count=len(selected), unfilled_slots_count=unfilled, reject_count=len(rejects), correlation_reject_count=corr_rejects, group_cap_reject_count=group_rejects, fallback_count=len(fallbacks), group_count=len(group_rows), top_symbol=selected[0]["symbol"] if selected else "not_available", output_path=str(layer / "l16_global_top10.csv"), summary_path=str(layer / "l16_global_top10_summary.txt"), selection_desk_path=str(visible / "Global Top 10.txt"))
        summary_text = _summary_text(summary)
        manifest_text = _manifest(top_text + reject_text + fallback_text + summary_text, len(selected))
        _write(layer / "l16_global_top10.csv", top_text, failed)
        _write(layer / "l16_global_top10_rejects.csv", reject_text, failed)
        _write(layer / "l16_global_top10_fallbacks.csv", fallback_text, failed)
        _write(layer / "l16_global_top10_summary.txt", summary_text, failed)
        _write(layer / "l16_global_top10.manifest", manifest_text, failed)
        _write(visible / "current_top10.csv", top_text, failed)
        _write(visible / "current_top10_manifest.txt", manifest_text, failed)
        _write(visible / "Global Top 10.txt", _selection_text(selected, rejects, summary), failed)
        if failed:
            return L16PublishSummary(status="write_degraded", reason="one_or_more_l16_outputs_failed", candidate_pool_size=summary.candidate_pool_size, l15_candidate_count=summary.l15_candidate_count, selected_count=summary.selected_count, unfilled_slots_count=summary.unfilled_slots_count, reject_count=summary.reject_count, correlation_reject_count=summary.correlation_reject_count, group_cap_reject_count=summary.group_cap_reject_count, fallback_count=summary.fallback_count, group_count=summary.group_count, write_failed_count=len(failed), top_symbol=summary.top_symbol, output_path=summary.output_path, summary_path=summary.summary_path, selection_desk_path=summary.selection_desk_path)
        return summary
    except Exception as exc:
        return L16PublishSummary("exception", f"{type(exc).__name__}: {exc}")
