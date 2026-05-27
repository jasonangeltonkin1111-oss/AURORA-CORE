from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, List, Tuple
import csv
import io
import math

from aurora_worker_io import account_root_from_outbox, atomic_write_text, payload_checksum, read_text, unix_time, utc_stamp

L16_LAYER_FOLDER = "Layer_16_Global_Top10_Builder"
L16_OWNER = "Runtime 5 - Taxonomy / Ranking Group Owner"
L16_AUTHORITY = "global_top10_inspection_basket_only"
L16_SCHEMA_NAME = "l16_global_top10_builder"
L16_MAX_CORR_ABS = 0.30
L16_FALLBACK_SOFT_CORR_ABS = 0.40
L16_FALLBACK_MEDIUM_CORR_ABS = 0.60
L16_TARGET_COUNT = 10
L16_HOLD_SECONDS = 300

TOP10_FIELDS = [
    "global_top10_rank", "symbol", "canonical_symbol", "ranking_group", "asset_class", "market_group", "market_segment",
    "l16_primary_score", "l14_candidate_priority_score", "l15_diversity_score", "source_group_selection_score", "source_group_strength", "source_group_quality",
    "max_corr_to_selected", "max_corr_pair_symbol", "correlation_clean_flag", "correlation_state", "correlation_confidence",
    "currency_overlap_score", "ranking_group_overlap_score", "leader_or_backup", "candidate_source", "selection_reason",
    "selected_after_reject_count", "backup_fill_used", "fallback_reason", "meaning", "global_top10_runtime", "trade_permission", "entry_signal", "execution", "generated_utc",
    "display_slot_rank", "clean_rank", "selection_tier", "clean_diversified", "fallback_fill_used", "corr_breach_amount", "hold_visible", "hold_state",
]

REJECT_FIELDS = [
    "candidate_rank", "symbol", "ranking_group", "l16_primary_score", "reject_stage", "reject_reason", "conflicting_selected_symbol",
    "pairwise_corr_abs", "ranking_group_count_if_added", "currency_overlap_score", "fallback_eligible", "generated_utc",
]

FALLBACK_FIELDS = [
    "slot", "symbol", "ranking_group", "fallback_reason", "l16_primary_score", "max_corr_to_selected", "conflicting_selected_symbol",
    "selection_tier", "meaning", "trade_permission", "entry_signal", "execution", "generated_utc",
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
    clean_selected_count: int = 0
    fallback_selected_count: int = 0
    display_slot_count: int = 0
    strict_clean_unfilled_slots_count: int = 10
    hold_enabled: str = "true"
    hold_seconds: int = L16_HOLD_SECONDS
    hold_state: str = "not_available"
    hold_started_unix: int = 0
    hold_valid_until_unix: int = 0
    hold_age_seconds: int = 0
    hold_valid_until_utc: str = "not_available"
    visible_surface_state: str = "not_available"


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


def _utc_from_unix(value: int) -> str:
    if value <= 0:
        return "not_available"
    return datetime.fromtimestamp(value, tz=timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC")


def _csv(path: Path) -> List[Dict[str, str]]:
    if not path.exists():
        return []
    text = read_text(path).replace("\r\n", "\n")
    if not text.strip():
        return []
    return [{str(k): "" if v is None else str(v) for k, v in row.items()} for row in csv.DictReader(io.StringIO(text))]


def _csv_text(rows: List[Dict[str, str]], fields: List[str]) -> str:
    out = io.StringIO(newline="")
    writer = csv.DictWriter(out, fieldnames=fields, extrasaction="ignore", lineterminator="\n")
    writer.writeheader()
    for row in rows:
        writer.writerow({field: row.get(field, "not_available") for field in fields})
    return out.getvalue()


def _kv(path: Path) -> Dict[str, str]:
    data: Dict[str, str] = {}
    if not path.exists():
        return data
    for raw in read_text(path).replace("\r\n", "\n").splitlines():
        if "=" in raw and not raw.strip().startswith("#"):
            k, v = raw.split("=", 1)
            data[k.strip()] = v.strip()
    return data


def _root_from_outbox(outbox: Path) -> Path:
    return account_root_from_outbox(outbox)


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


def _is_deferred_l15(row: Dict[str, str]) -> bool:
    correlation_state = _text(row, "correlation_state", "").upper()
    constraint_hint = _text(row, "l16_constraint_hint", "").lower()
    confidence = _text(row, "correlation_confidence", "").lower()
    return (
        correlation_state == "DEFERRED_SOFT_CAP_SLOW_LANE"
        or "constrained_deferred_slow_lane" in constraint_hint
        or confidence == "deferred_not_scored_yet"
    )


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


def _max_corr_to_selected(symbol: str, selected: List[Dict[str, str]], pair_corr: Dict[Tuple[str, str], Tuple[float | None, str]]) -> Tuple[float, str, str, bool]:
    max_corr = 0.0
    max_pair = "none"
    corr_state = "LOW_CORRELATION"
    unavailable = False
    for sel in selected:
        sel_symbol = _text(sel, "symbol")
        corr, state = pair_corr.get(_pair_key(symbol, sel_symbol), (None, "CORRELATION_UNAVAILABLE"))
        if corr is None:
            unavailable = True
            corr_state = state
            if max_pair == "none":
                max_pair = sel_symbol
            continue
        if corr > max_corr:
            max_corr = corr
            max_pair = sel_symbol
            corr_state = state
    return max_corr, max_pair, corr_state, unavailable


def _make_display_row(cand: Dict[str, str], rank: int, clean_rank: str, max_corr: float, max_pair: str, corr_state: str, unavailable: bool, reason: str, reject_seen: int, selection_tier: str, clean: bool, fallback_reason: str = "not_required") -> Dict[str, str]:
    corr_breach = max(0.0, max_corr - L16_MAX_CORR_ABS)
    return {
        "global_top10_rank": str(rank), "display_slot_rank": str(rank), "clean_rank": clean_rank,
        "symbol": _text(cand, "symbol"), "canonical_symbol": _text(cand, "canonical_symbol", _text(cand, "symbol")),
        "ranking_group": _text(cand, "ranking_group"), "asset_class": _text(cand, "asset_class"),
        "market_group": _text(cand, "market_group"), "market_segment": _text(cand, "market_segment"),
        "l16_primary_score": _text(cand, "l16_primary_score"), "l14_candidate_priority_score": _text(cand, "l14_candidate_priority_score"),
        "l15_diversity_score": _text(cand, "diversity_score"), "source_group_selection_score": _text(cand, "source_group_selection_score"),
        "source_group_strength": _text(cand, "source_group_strength"), "source_group_quality": _text(cand, "source_group_quality"),
        "max_corr_to_selected": f"{max_corr:.6f}", "max_corr_pair_symbol": max_pair,
        "correlation_clean_flag": "false" if unavailable or not clean else "true",
        "correlation_state": "DEGRADED_UNAVAILABLE" if unavailable and clean else corr_state,
        "correlation_confidence": _text(cand, "correlation_confidence"), "currency_overlap_score": _text(cand, "currency_overlap_score"),
        "ranking_group_overlap_score": _text(cand, "ranking_group_overlap_score"), "leader_or_backup": _text(cand, "leader_or_backup"),
        "candidate_source": _text(cand, "candidate_source"), "selection_reason": reason,
        "selected_after_reject_count": str(reject_seen), "backup_fill_used": "true" if not clean else "false",
        "fallback_fill_used": "true" if not clean else "false", "fallback_reason": fallback_reason,
        "selection_tier": selection_tier, "clean_diversified": "true" if clean else "false", "corr_breach_amount": f"{corr_breach:.6f}",
        "meaning": "global_top10_inspection_basket_only_not_trade_permission",
        "global_top10_runtime": "false", "trade_permission": "false", "entry_signal": "false", "execution": "false", "generated_utc": utc_stamp(),
        "hold_visible": "false", "hold_state": "latest_calculation",
    }


def _build_top10(candidates: List[Dict[str, str]], pair_corr: Dict[Tuple[str, str], Tuple[float | None, str]], group_count: int) -> Tuple[List[Dict[str, str]], List[Dict[str, str]], List[Dict[str, str]]]:
    clean_rows: List[Dict[str, str]] = []
    rejects: List[Dict[str, str]] = []
    fallbacks: List[Dict[str, str]] = []
    group_limit = _group_cap(group_count, len(candidates))
    group_counts: Dict[str, int] = {}
    reject_seen = 0
    clean_symbols: set[str] = set()

    for cand in candidates:
        symbol = _text(cand, "symbol")
        if len(clean_rows) >= L16_TARGET_COUNT or symbol in clean_symbols:
            continue
        group = _text(cand, "ranking_group")
        group_after = group_counts.get(group, 0) + 1
        if _is_deferred_l15(cand):
            rejects.append({
                "candidate_rank": _text(cand, "candidate_pool_rank"), "symbol": symbol, "ranking_group": group,
                "l16_primary_score": _text(cand, "l16_primary_score"), "reject_stage": "deferred_soft_cap", "reject_reason": "l15_deferred_soft_cap_slow_lane_not_strict_clean",
                "conflicting_selected_symbol": "not_available", "pairwise_corr_abs": "not_available", "ranking_group_count_if_added": str(group_after),
                "currency_overlap_score": _text(cand, "currency_overlap_score"), "fallback_eligible": "true", "generated_utc": utc_stamp(),
            })
            reject_seen += 1
            continue
        if group_after > group_limit:
            rejects.append({
                "candidate_rank": _text(cand, "candidate_pool_rank"), "symbol": symbol, "ranking_group": group,
                "l16_primary_score": _text(cand, "l16_primary_score"), "reject_stage": "group_cap", "reject_reason": "ranking_group_cap_exceeded",
                "conflicting_selected_symbol": "not_available", "pairwise_corr_abs": "not_available", "ranking_group_count_if_added": str(group_after),
                "currency_overlap_score": _text(cand, "currency_overlap_score"), "fallback_eligible": "true", "generated_utc": utc_stamp(),
            })
            reject_seen += 1
            continue
        max_corr, max_pair, corr_state, unavailable = _max_corr_to_selected(symbol, clean_rows, pair_corr)
        if clean_rows and max_corr > L16_MAX_CORR_ABS:
            rejects.append({
                "candidate_rank": _text(cand, "candidate_pool_rank"), "symbol": symbol, "ranking_group": group,
                "l16_primary_score": _text(cand, "l16_primary_score"), "reject_stage": "correlation_cap", "reject_reason": "pairwise_correlation_above_0_30",
                "conflicting_selected_symbol": max_pair, "pairwise_corr_abs": f"{max_corr:.6f}", "ranking_group_count_if_added": str(group_after),
                "currency_overlap_score": _text(cand, "currency_overlap_score"), "fallback_eligible": "true", "generated_utc": utc_stamp(),
            })
            reject_seen += 1
            continue
        if clean_rows and unavailable:
            rejects.append({
                "candidate_rank": _text(cand, "candidate_pool_rank"), "symbol": symbol, "ranking_group": group,
                "l16_primary_score": _text(cand, "l16_primary_score"), "reject_stage": "correlation_unavailable", "reject_reason": "pairwise_correlation_unavailable_not_strict_clean",
                "conflicting_selected_symbol": max_pair, "pairwise_corr_abs": "not_available", "ranking_group_count_if_added": str(group_after),
                "currency_overlap_score": _text(cand, "currency_overlap_score"), "fallback_eligible": "true", "generated_utc": utc_stamp(),
            })
            reject_seen += 1
            continue

        reason = "highest_score_seed" if not clean_rows else "score_order_passed_correlation_and_group_caps"
        rank = len(clean_rows) + 1
        row = _make_display_row(cand, rank, str(rank), max_corr if clean_rows else 0.0, max_pair, corr_state, False, reason, reject_seen, "CLEAN", True)
        clean_rows.append(row)
        clean_symbols.add(symbol)
        group_counts[group] = group_after

    display_rows = list(clean_rows)
    for cand in candidates:
        if len(display_rows) >= L16_TARGET_COUNT:
            break
        symbol = _text(cand, "symbol")
        if symbol in {_text(r, "symbol") for r in display_rows}:
            continue
        max_corr, max_pair, corr_state, unavailable = _max_corr_to_selected(symbol, display_rows, pair_corr)
        deferred_l15 = _is_deferred_l15(cand)
        if deferred_l15:
            tier = "FALLBACK_DEFERRED_SOFT_CAP"
            reason = "fallback_fill_l15_deferred_soft_cap_slow_lane_not_strict_clean"
        elif unavailable:
            tier = "FALLBACK_UNAVAILABLE_CORRELATION"
            reason = "fallback_fill_correlation_unavailable_not_strict_clean"
        elif max_corr <= L16_FALLBACK_SOFT_CORR_ABS:
            tier = "FALLBACK_SOFT_CORR"
            reason = "fallback_fill_soft_correlation_breach_or_next_best"
        elif max_corr <= L16_FALLBACK_MEDIUM_CORR_ABS:
            tier = "FALLBACK_MEDIUM_CORR"
            reason = "fallback_fill_medium_correlation_breach"
        else:
            tier = "FALLBACK_NEXT_BEST_UNCLEAN"
            reason = "fallback_fill_next_best_unclean_correlation"
        rank = len(display_rows) + 1
        fallback_reason = f"fill_display_slot_not_clean_diversification;reason={reason};max_corr={max_corr:.6f};pair={max_pair};threshold={L16_MAX_CORR_ABS:.2f}"
        row = _make_display_row(cand, rank, "not_clean", max_corr, max_pair, corr_state, unavailable or deferred_l15, reason, reject_seen, tier, False, fallback_reason)
        display_rows.append(row)
        fallbacks.append({
            "slot": str(rank), "symbol": symbol, "ranking_group": _text(cand, "ranking_group"),
            "fallback_reason": fallback_reason, "l16_primary_score": _text(cand, "l16_primary_score"),
            "max_corr_to_selected": f"{max_corr:.6f}", "conflicting_selected_symbol": max_pair,
            "selection_tier": tier, "meaning": "fallback_display_slot_only_not_clean_diversification_not_trade_permission",
            "trade_permission": "false", "entry_signal": "false", "execution": "false", "generated_utc": utc_stamp(),
        })

    return display_rows, rejects, fallbacks


def _manifest(payload: str, selected_count: int, clean_count: int, fallback_count: int, hold_state: str) -> str:
    return "\n".join([
        "schema_name=l16_global_top10_manifest", "schema_version=2", "layer_id=16", "layer_name=Layer 16 - Global Top 10 Builder",
        f"owner={L16_OWNER}", f"authority={L16_AUTHORITY}", f"selected_count={selected_count}", f"clean_selected_count={clean_count}", f"fallback_selected_count={fallback_count}",
        f"payload_checksum={payload_checksum(payload.splitlines())}", f"max_allowed_pairwise_correlation_abs={L16_MAX_CORR_ABS:.2f}",
        f"fallback_soft_correlation_abs={L16_FALLBACK_SOFT_CORR_ABS:.2f}", f"fallback_medium_correlation_abs={L16_FALLBACK_MEDIUM_CORR_ABS:.2f}",
        "threshold_status=untested_default_not_holy_law", "l15_deferred_soft_cap_policy=deferred_rows_never_strict_clean_may_display_as_fallback_only", "l16_hold_enabled=true", f"l16_hold_seconds={L16_HOLD_SECONDS}", f"l16_hold_state={hold_state}",
        "global_top10_runtime=false", "trade_permission=false", "entry_signal=false", "execution=false", f"generated_utc={utc_stamp()}", f"generated_unix={unix_time()}", "",
    ])


def _summary_text(summary: L16PublishSummary) -> str:
    return "\n".join([
        f"schema_name={L16_SCHEMA_NAME}", "schema_version=2", f"owner_name={L16_OWNER}", "layer_id=16", "layer_name=Layer 16 - Global Top 10 Builder",
        f"status={summary.status}", f"reason={summary.reason}", "input_source=L14_candidate_pool+L15_correlation_diversity_outputs",
        f"candidate_pool_size={summary.candidate_pool_size}", f"l15_candidate_count={summary.l15_candidate_count}", f"selected_count={summary.selected_count}",
        f"selected_count_meaning=strict_clean_diversified_count_excludes_fallback_display",
        f"display_slot_count={summary.display_slot_count}", f"clean_selected_count={summary.clean_selected_count}", f"fallback_selected_count={summary.fallback_selected_count}",
        f"unfilled_slots_count={summary.unfilled_slots_count}", f"strict_clean_unfilled_slots_count={summary.strict_clean_unfilled_slots_count}",
        f"reject_count={summary.reject_count}", f"correlation_reject_count={summary.correlation_reject_count}", f"group_cap_reject_count={summary.group_cap_reject_count}",
        f"fallback_count={summary.fallback_count}", f"group_count={summary.group_count}", f"top_symbol={summary.top_symbol}", f"write_failed_count={summary.write_failed_count}",
        f"output_path={summary.output_path}", f"summary_path={summary.summary_path}", f"selection_desk_path={summary.selection_desk_path}",
        f"max_allowed_pairwise_correlation_abs={L16_MAX_CORR_ABS:.2f}", f"fallback_soft_correlation_abs={L16_FALLBACK_SOFT_CORR_ABS:.2f}",
        f"fallback_medium_correlation_abs={L16_FALLBACK_MEDIUM_CORR_ABS:.2f}", "threshold_status=untested_default_not_holy_law",
        "l15_deferred_soft_cap_policy=deferred_rows_never_strict_clean_may_display_as_fallback_only",
        f"l16_hold_enabled={summary.hold_enabled}", f"l16_hold_seconds={summary.hold_seconds}", f"l16_hold_state={summary.hold_state}",
        f"l16_hold_started_unix={summary.hold_started_unix}", f"l16_hold_valid_until_unix={summary.hold_valid_until_unix}",
        f"l16_hold_age_seconds={summary.hold_age_seconds}", f"l16_hold_valid_until_utc={summary.hold_valid_until_utc}",
        f"l16_visible_surface_state={summary.visible_surface_state}",
        "meaning=global_top10_inspection_basket_only_not_trade_permission", "global_top10_runtime=false", "trade_permission=false", "entry_signal=false", "execution=false",
        f"generated_utc={utc_stamp()}", f"generated_unix={unix_time()}", "",
    ])


def _selection_text(rows: List[Dict[str, str]], rejects: List[Dict[str, str]], summary: L16PublishSummary) -> str:
    lines = [
        "L16 GLOBAL TOP 10 INSPECTION BASKET", "----------------------------------------",
        f"status={summary.status}", f"reason={summary.reason}", f"strict_clean_selected_count={summary.clean_selected_count}", f"display_slot_count={summary.display_slot_count}",
        f"clean_selected_count={summary.clean_selected_count}", f"fallback_selected_count={summary.fallback_selected_count}",
        f"unfilled_slots_count={summary.unfilled_slots_count}", f"strict_clean_unfilled_slots_count={summary.strict_clean_unfilled_slots_count}",
        f"correlation_reject_count={summary.correlation_reject_count}", f"group_cap_reject_count={summary.group_cap_reject_count}",
        f"max_allowed_pairwise_correlation_abs={L16_MAX_CORR_ABS:.2f}", "threshold_status=untested_default_not_holy_law",
        "l15_deferred_soft_cap_policy=deferred_rows_never_strict_clean_may_display_as_fallback_only",
        f"hold_state={summary.hold_state}", f"hold_valid_until_utc={summary.hold_valid_until_utc}", "", "TOP 10 DISPLAY SLOTS",
    ]
    for row in rows:
        lines.append(
            f"#{row['global_top10_rank']} {row['symbol']} tier={row.get('selection_tier','not_available')} clean={row.get('clean_diversified','false')} "
            f"group={row['ranking_group']} score={row['l16_primary_score']} max_corr={row['max_corr_to_selected']} pair={row['max_corr_pair_symbol']} "
            f"state={row['correlation_state']} fallback={row.get('fallback_reason','not_required')} reason={row['selection_reason']}"
        )
    if summary.unfilled_slots_count > 0:
        lines.append("")
        lines.append(f"UNFILLED_DISPLAY_SLOTS={summary.unfilled_slots_count}")
        lines.append("unfilled_reason=strict_clean_slots_unfilled_due_to_correlation_cap_group_cap_or_unavailable_correlation_or_deferred_soft_cap")
    lines.append("")
    lines.append("REJECT SNAPSHOT")
    for row in rejects[:20]:
        lines.append(f"{row['symbol']} reject={row['reject_reason']} conflict={row['conflicting_selected_symbol']} corr={row['pairwise_corr_abs']} group_if_added={row['ranking_group_count_if_added']}")
    lines.extend(["", "global_top10_runtime=false", "trade_permission=false", "entry_signal=false", "execution=false", ""])
    return "\n".join(lines)


def _counts(rows: List[Dict[str, str]]) -> Tuple[int, int, int]:
    display = len(rows)
    clean = sum(1 for row in rows if row.get("clean_diversified") == "true")
    fallback = sum(1 for row in rows if row.get("fallback_fill_used") == "true")
    return display, clean, fallback


def _read_held_rows(layer: Path) -> List[Dict[str, str]]:
    return _csv(layer / "l16_held_visible_top10.csv")


def _hold_state(layer: Path) -> Dict[str, str]:
    return _kv(layer / "l16_hold_state.txt")


def _write_hold_state(layer: Path, state: str, started_unix: int, valid_until_unix: int, rows: List[Dict[str, str]], failed: List[Path]) -> None:
    text = "\n".join([
        "schema_name=l16_hold_state", "schema_version=1", "hold_enabled=true", f"hold_seconds={L16_HOLD_SECONDS}",
        f"hold_state={state}", f"hold_started_unix={started_unix}", f"hold_started_utc={_utc_from_unix(started_unix)}",
        f"hold_valid_until_unix={valid_until_unix}", f"hold_valid_until_utc={_utc_from_unix(valid_until_unix)}",
        f"display_slot_count={len(rows)}", f"clean_selected_count={sum(1 for r in rows if r.get('clean_diversified') == 'true')}",
        f"fallback_selected_count={sum(1 for r in rows if r.get('fallback_fill_used') == 'true')}",
        "trade_permission=false", "entry_signal=false", "execution=false", f"generated_utc={utc_stamp()}", f"generated_unix={unix_time()}", "",
    ])
    _write(layer / "l16_hold_state.txt", text, failed)


def _held_summary(layer: Path, visible: Path, reason: str, source_summary: L16PublishSummary | None = None) -> L16PublishSummary | None:
    rows = _read_held_rows(layer)
    state = _hold_state(layer)
    if not rows:
        return None
    now = unix_time()
    started = _int(state.get("hold_started_unix"), now)
    valid_until = _int(state.get("hold_valid_until_unix"), now + L16_HOLD_SECONDS)
    display, clean, fallback = _counts(rows)
    base = source_summary or EMPTY_L16_SUMMARY
    return L16PublishSummary(
        status="degraded", reason=reason, candidate_pool_size=base.candidate_pool_size, l15_candidate_count=base.l15_candidate_count,
        selected_count=clean, unfilled_slots_count=max(0, L16_TARGET_COUNT - clean), reject_count=base.reject_count,
        correlation_reject_count=base.correlation_reject_count, group_cap_reject_count=base.group_cap_reject_count,
        fallback_count=fallback, group_count=base.group_count, write_failed_count=base.write_failed_count,
        top_symbol=rows[0].get("symbol", "not_available"), output_path=str(layer / "l16_global_top10.csv"),
        summary_path=str(layer / "l16_global_top10_summary.txt"), selection_desk_path=str(visible / "Global Top 10.txt"),
        clean_selected_count=clean, fallback_selected_count=fallback, display_slot_count=display,
        strict_clean_unfilled_slots_count=max(0, L16_TARGET_COUNT - clean), hold_state="upstream_incomplete_holding_prior" if "upstream" in reason else "holding_current_basket",
        hold_started_unix=started, hold_valid_until_unix=valid_until, hold_age_seconds=max(0, now - started),
        hold_valid_until_utc=_utc_from_unix(valid_until), visible_surface_state="static_held",
    )


def _publish_visible(layer: Path, visible: Path, rows: List[Dict[str, str]], rejects: List[Dict[str, str]], fallbacks: List[Dict[str, str]], summary: L16PublishSummary, failed: List[Path]) -> None:
    rows = [dict(row, hold_visible="true", hold_state=summary.hold_state) for row in rows]
    top_text = _csv_text(rows, TOP10_FIELDS)
    reject_text = _csv_text(rejects, REJECT_FIELDS)
    fallback_text = _csv_text(fallbacks, FALLBACK_FIELDS)
    summary_text = _summary_text(summary)
    manifest_text = _manifest(top_text + reject_text + fallback_text + summary_text, len(rows), summary.clean_selected_count, summary.fallback_selected_count, summary.hold_state)
    _write(layer / "l16_global_top10.csv", top_text, failed)
    _write(layer / "l16_global_top10_rejects.csv", reject_text, failed)
    _write(layer / "l16_global_top10_fallbacks.csv", fallback_text, failed)
    _write(layer / "l16_global_top10_summary.txt", summary_text, failed)
    _write(layer / "l16_global_top10.manifest", manifest_text, failed)
    _write(visible / "current_top10.csv", top_text, failed)
    _write(visible / "current_top10_manifest.txt", manifest_text, failed)
    _write(visible / "Global Top 10.txt", _selection_text(rows, rejects, summary), failed)


def publish_l16_global_top10_builder(outbox_root: Path) -> L16PublishSummary:
    layer = outbox_root / "Layers" / L16_LAYER_FOLDER
    visible = _global_dir(outbox_root)
    for folder in (layer, visible):
        folder.mkdir(parents=True, exist_ok=True)

    l14 = outbox_root / "Layers" / "Layer_14_Ranking_Group_Leader_Candidate_Pool"
    l15 = outbox_root / "Layers" / "Layer_15_Correlation_Diversity_Selection"
    needed = [
        l14 / "l14_candidate_pool.csv", l14 / "l14_candidate_pool_summary.txt",
        l15 / "l15_candidate_diversity_scores.csv", l15 / "l15_candidate_correlation_matrix.csv",
        l15 / "l15_group_diversity_summary.csv", l15 / "l15_correlation_diversity_summary.txt",
    ]
    missing = [str(p) for p in needed if not p.exists()]
    if missing:
        held = _held_summary(layer, visible, "missing_required_l16_source_holding_prior: " + ";".join(missing))
        return held if held is not None else L16PublishSummary("pending", "missing_required_l16_source: " + ";".join(missing))
    try:
        l14_status = _kv(l14 / "l14_candidate_pool_summary.txt").get("status", "pending")
        l15_status = _kv(l15 / "l15_correlation_diversity_summary.txt").get("status", "pending")
        if l14_status != "accepted":
            held = _held_summary(layer, visible, "l14_not_accepted_holding_prior_status=" + l14_status)
            return held if held is not None else L16PublishSummary("pending", "l14_not_accepted_status=" + l14_status)
        if l15_status != "accepted":
            held = _held_summary(layer, visible, "l15_not_accepted_holding_prior_status=" + l15_status)
            return held if held is not None else L16PublishSummary("pending", "l15_not_accepted_status=" + l15_status)

        l14_rows = _csv(l14 / "l14_candidate_pool.csv")
        l15_rows = _csv(l15 / "l15_candidate_diversity_scores.csv")
        pair_rows = _csv(l15 / "l15_candidate_correlation_matrix.csv")
        group_rows = _csv(l15 / "l15_group_diversity_summary.csv")
        candidates = _join_candidates(l14_rows, l15_rows)
        if not candidates:
            held = _held_summary(layer, visible, "no_joined_l14_l15_candidates_holding_prior")
            return held if held is not None else L16PublishSummary("pending", "no_joined_l14_l15_candidates")

        latest_rows, rejects, fallbacks = _build_top10(candidates, _pair_corr(pair_rows), len(group_rows))
        latest_display, latest_clean, latest_fallback = _counts(latest_rows)
        latest_text = _csv_text(latest_rows, TOP10_FIELDS)
        reject_text = _csv_text(rejects, REJECT_FIELDS)
        fallback_text = _csv_text(fallbacks, FALLBACK_FIELDS)
        failed: List[Path] = []
        _write(layer / "l16_latest_calculation_top10.csv", latest_text, failed)
        _write(layer / "l16_latest_calculation_rejects.csv", reject_text, failed)
        _write(layer / "l16_latest_calculation_fallbacks.csv", fallback_text, failed)

        corr_rejects = sum(1 for r in rejects if r.get("reject_stage") in {"correlation_cap", "correlation_unavailable"})
        group_rejects = sum(1 for r in rejects if r.get("reject_stage") == "group_cap")
        base = L16PublishSummary(
            status="accepted" if latest_clean == L16_TARGET_COUNT else "degraded",
            reason="l16_strict_clean_global_top10_published" if latest_clean == L16_TARGET_COUNT else "l16_partial_strict_clean_global_top10_with_fallback_display",
            candidate_pool_size=len(l14_rows), l15_candidate_count=len(l15_rows), selected_count=latest_clean,
            unfilled_slots_count=max(0, L16_TARGET_COUNT - latest_clean), reject_count=len(rejects),
            correlation_reject_count=corr_rejects, group_cap_reject_count=group_rejects, fallback_count=latest_fallback,
            group_count=len(group_rows), top_symbol=latest_rows[0]["symbol"] if latest_rows else "not_available",
            output_path=str(layer / "l16_global_top10.csv"), summary_path=str(layer / "l16_global_top10_summary.txt"),
            selection_desk_path=str(visible / "Global Top 10.txt"), clean_selected_count=latest_clean,
            fallback_selected_count=latest_fallback, display_slot_count=latest_display,
            strict_clean_unfilled_slots_count=max(0, L16_TARGET_COUNT - latest_clean),
        )

        now = unix_time()
        state = _hold_state(layer)
        held_rows = _read_held_rows(layer)
        valid_until = _int(state.get("hold_valid_until_unix"), 0)
        started = _int(state.get("hold_started_unix"), 0)
        hold_active = bool(held_rows) and valid_until > now
        if hold_active:
            display_rows = held_rows
            display, clean, fallback = _counts(display_rows)
            summary = L16PublishSummary(
                **{**base.__dict__, "status": "accepted" if clean == L16_TARGET_COUNT else "degraded", "reason": "holding_current_visible_global_top10_until_hold_expiry", "selected_count": clean,
                   "unfilled_slots_count": max(0, L16_TARGET_COUNT - clean), "fallback_count": fallback, "top_symbol": display_rows[0].get("symbol", "not_available") if display_rows else "not_available",
                   "clean_selected_count": clean, "fallback_selected_count": fallback, "display_slot_count": display, "strict_clean_unfilled_slots_count": max(0, L16_TARGET_COUNT - clean),
                   "hold_state": "holding_current_basket", "hold_started_unix": started, "hold_valid_until_unix": valid_until, "hold_age_seconds": max(0, now - started),
                   "hold_valid_until_utc": _utc_from_unix(valid_until), "visible_surface_state": "static_held"}
            )
            _publish_visible(layer, visible, display_rows, rejects, fallbacks, summary, failed)
        else:
            started = now
            valid_until = now + L16_HOLD_SECONDS
            display_rows = latest_rows
            summary = L16PublishSummary(
                **{**base.__dict__, "hold_state": "hold_expired_rebuilt" if held_rows else "new_hold_started", "hold_started_unix": started,
                   "hold_valid_until_unix": valid_until, "hold_age_seconds": 0, "hold_valid_until_utc": _utc_from_unix(valid_until), "visible_surface_state": "static_held"}
            )
            _write(layer / "l16_held_visible_top10.csv", _csv_text(display_rows, TOP10_FIELDS), failed)
            _write_hold_state(layer, summary.hold_state, started, valid_until, display_rows, failed)
            _publish_visible(layer, visible, display_rows, rejects, fallbacks, summary, failed)

        if failed:
            return L16PublishSummary(
                **{**summary.__dict__, "status": "write_degraded", "reason": "one_or_more_l16_outputs_failed", "write_failed_count": len(failed)}
            )
        return summary
    except Exception as exc:
        held = _held_summary(layer, visible, f"exception_holding_prior:{type(exc).__name__}:{exc}")
        return held if held is not None else L16PublishSummary("exception", f"{type(exc).__name__}: {exc}")
