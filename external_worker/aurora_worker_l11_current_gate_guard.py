from __future__ import annotations

from pathlib import Path
from typing import Dict, List, Sequence, Tuple
from collections import defaultdict
import csv
import io

from aurora_worker_io import atomic_write_text, read_text, unix_time, utc_stamp
from aurora_worker_l11 import L11PublishSummary, _publish

L11_LAYER_FOLDER = "Layer_11_Symbol_Ranking_Inside_Ranking_Group"
L11_OWNER = "Runtime 5 - Taxonomy / Ranking Group Owner"
L11_AUTHORITY = "intra_group_inspection_priority_only"

# Keep these field lists local to the guard so it can rewrite the existing L11
# packet without importing private internals from aurora_worker_l11.py. This is
# not a second ranking owner: it is a dispatch-time current-truth safety filter.
L11_INPUT_FIELDS = [
    "symbol", "canonical_symbol", "asset_class", "market_group", "market_segment", "ranking_group", "ranking_group_slug",
    "taxonomy_state", "review_state", "rank_allowed", "selection_allowed", "l5_gate_state", "l5_eligible_flag",
    "l6_available", "l6_rank_state", "l6_score_quality", "l6_raw_score", "l6_normalized_score", "l6_manifest_checksum", "l6_manifest_status", "l6_reason",
    "l7_available", "l7_rank_state", "l7_score_quality", "l7_raw_score", "l7_normalized_score", "l7_manifest_checksum", "l7_manifest_status", "l7_reason",
    "l8_available", "l8_rank_state", "l8_score_quality", "l8_raw_score", "l8_normalized_score", "l8_manifest_checksum", "l8_manifest_status", "l8_reason",
    "l9_available", "l9_rank_state", "l9_score_quality", "l9_raw_score", "l9_normalized_score", "l9_manifest_checksum", "l9_manifest_status", "l9_reason",
    "component_available_count", "component_missing_count", "input_quality_state", "rank_eligibility_state", "rank_eligibility_reason",
    "selection_runtime", "trade_permission", "entry_signal", "execution",
]

L11_RANKED_FIELDS = [
    "ranking_group", "ranking_group_slug", "ranking_group_symbol_count", "ranking_group_rankable_count", "ranking_group_not_rankable_count",
    "ranking_group_rank", "rankable_count", "symbol", "canonical_symbol", "asset_class", "market_group", "market_segment", "l5_gate_state",
    "l11_group_score", "ranking_group_rank_percentile", "rank_state", "leader_flag", "backup_flag", "backup_rank", "backup_reason", "in_top5_per_ranking_group",
    "risk_review_flag", "not_rankable_reason", "component_available_count", "component_missing_count", "missing_layer_count", "stale_layer_count",
    "weighted_available_average", "missing_layer_penalty", "stale_layer_penalty", "risk_review_penalty",
    "l6_score", "l6_weight", "l6_state", "l7_score", "l7_weight", "l7_state", "l8_score", "l8_weight", "l8_state", "l9_score", "l9_weight", "l9_state",
    "component_summary", "reason", "meaning", "directional_validity", "expectancy_validated", "selection_runtime", "trade_permission", "entry_signal", "execution", "source_checksum",
]

SAFE_L5_STATES = {"pass", "passed", "accepted", "open", "true", "ok"}
L5_LABELS = [
    "Layer 5 Gate Status", "Layer 5 Gate State", "Layer 5 Gate", "Layer 5 Status",
    "L5 Gate Status", "L5 Gate State", "L5 Status",
    "l5_gate_status", "l5_gate_state", "l5_status",
]
MARKET_STATE_LABELS = ["Market State", "market_state"]


def _csv_rows(path: Path) -> List[Dict[str, str]]:
    if not path.exists():
        return []
    text = read_text(path).replace("\r\n", "\n")
    if not text.strip():
        return []
    reader = csv.DictReader(io.StringIO(text))
    return [{str(k): ("" if v is None else str(v)) for k, v in row.items()} for row in reader]


def _sanitize(value: str) -> str:
    safe = str(value or "").strip() or "unknown"
    for ch in ['\\', '/', ':', '*', '?', '"', '<', '>', '|', ' ']:
        safe = safe.replace(ch, "_")
    return safe or "unknown"


def _account_root_from_outbox(outbox_root: Path) -> Path:
    return outbox_root.parents[2]


def _dossier_candidates(account_root: Path, symbol: str) -> List[Tuple[str, Path]]:
    clean = str(symbol or "").strip()
    safe = _sanitize(clean)
    names: List[str] = []
    for base in (clean, safe):
        if base:
            names.extend([base, f"{base}.txt"])
    unique_names: List[str] = []
    seen = set()
    for name in names:
        low = name.lower()
        if low not in seen:
            unique_names.append(name)
            seen.add(low)
    out: List[Tuple[str, Path]] = []
    for route in ("Open", "Closed", "Unknown"):
        for name in unique_names:
            out.append((route, account_root / "Dossiers" / route / name))
    return out


def _existing_dossiers(account_root: Path, symbol: str) -> List[Tuple[str, Path]]:
    return [(route, path) for route, path in _dossier_candidates(account_root, symbol) if path.exists() and path.is_file()]


def _extract_label(text: str, labels: Sequence[str]) -> str:
    for raw in text.replace("\r\n", "\n").splitlines():
        line = raw.strip()
        lower = line.lower()
        for label in labels:
            wanted = label.lower()
            if lower.startswith(wanted):
                value = line[len(label):].strip(" :=|\t")
                return value or "not_available"
    return "not_available"


def _current_gate_state(account_root: Path, symbol: str) -> Tuple[bool, str, str, str]:
    """Return (safe_to_rank, l5_state, eligible_flag, reason)."""
    matches = _existing_dossiers(account_root, symbol)
    if not matches:
        return False, "blocked_current_dossier_missing", "false", "current_dossier_missing"
    routes = sorted({route for route, _path in matches})
    if len(matches) > 1:
        return False, "blocked_current_duplicate_dossier_routes", "false", "current_dossier_duplicate_routes:" + ";".join(routes)

    route, path = matches[0]
    try:
        text = read_text(path)
    except OSError:
        return False, "blocked_current_dossier_unreadable", "false", f"current_dossier_unreadable:{path}"

    lower = text.lower()
    market_state = _extract_label(text, MARKET_STATE_LABELS).strip().lower()
    dossier_l5 = _extract_label(text, L5_LABELS).strip().lower()

    if route != "Open":
        return False, f"blocked_current_route_{route.lower()}", "false", f"current_dossier_route_{route.lower()}"
    if market_state in {"closed", "unknown"}:
        return False, f"blocked_current_market_{market_state}", "false", f"current_dossier_market_{market_state}"
    if "market state: closed" in lower or "market_state=closed" in lower:
        return False, "blocked_current_market_closed", "false", "current_dossier_market_closed"
    if "market state: unknown" in lower or "market_state=unknown" in lower:
        return False, "blocked_current_market_unknown", "false", "current_dossier_market_unknown"
    if "layer 5 gate status: blocked" in lower or "layer 5 gate state: blocked" in lower or "l5 gate status: blocked" in lower or "l5_gate_status=blocked" in lower or "l5 gate state: blocked" in lower or "market_not_open" in lower:
        return False, "blocked_current_l5", "false", "current_dossier_l5_blocked"
    if "stale_previous_generation" in lower or "dossier stale" in lower:
        return False, "blocked_current_dossier_stale", "false", "current_dossier_stale"
    if dossier_l5 != "not_available" and dossier_l5 not in SAFE_L5_STATES:
        return False, f"blocked_current_l5_{_sanitize(dossier_l5)}", "false", f"current_dossier_l5_not_pass:{dossier_l5}"

    return True, "pass", "true", f"current_dossier_open_l5_pass:{path}"


def _mark_not_rankable(row: Dict[str, str], l5_state: str, reason: str) -> Dict[str, str]:
    out = dict(row)
    out["l5_gate_state"] = l5_state
    out["l11_group_score"] = "0.00"
    out["ranking_group_rank"] = "not_available"
    out["ranking_group_rank_percentile"] = "not_available"
    out["rank_state"] = "not_rankable_current_l5_gate"
    out["leader_flag"] = "false"
    out["backup_flag"] = "false"
    out["backup_rank"] = "not_available"
    out["backup_reason"] = "not_rankable_current_l5_gate"
    out["in_top5_per_ranking_group"] = "false"
    out["risk_review_flag"] = "false"
    out["not_rankable_reason"] = reason
    out["reason"] = reason
    out["selection_runtime"] = "false"
    out["trade_permission"] = "false"
    out["entry_signal"] = "false"
    out["execution"] = "false"
    return out


def _score_sort_value(row: Dict[str, str]) -> float:
    try:
        return float(str(row.get("l11_group_score", "0") or "0"))
    except ValueError:
        return 0.0


def _rerank(rows: List[Dict[str, str]]) -> List[Dict[str, str]]:
    groups: Dict[str, List[Dict[str, str]]] = defaultdict(list)
    for row in rows:
        groups[row.get("ranking_group", "Unknown")].append(dict(row))
    out: List[Dict[str, str]] = []
    for _group, members in sorted(groups.items()):
        rankable = [r for r in members if r.get("rank_state") in {"ranked", "ranked_partial", "risk_review"}]
        not_rankable_count = len(members) - len(rankable)
        rankable.sort(key=lambda r: (-_score_sort_value(r), r.get("symbol", "")))
        rankable_count = len(rankable)
        for idx, row in enumerate(rankable, 1):
            row["ranking_group_rank"] = str(idx)
            row["rankable_count"] = str(rankable_count)
            row["ranking_group_rankable_count"] = str(rankable_count)
            row["ranking_group_not_rankable_count"] = str(not_rankable_count)
            row["ranking_group_symbol_count"] = str(len(members))
            row["ranking_group_rank_percentile"] = "100.0" if rankable_count <= 1 else f"{100.0 * (1.0 - ((idx - 1) / max(1, rankable_count - 1))):.1f}"
            row["in_top5_per_ranking_group"] = "true" if idx <= 5 else "false"
            row["leader_flag"] = "true" if idx == 1 else "false"
            row["backup_flag"] = "true" if 1 < idx <= 5 else "false"
            row["backup_rank"] = str(idx - 1) if idx > 1 else "not_available"
            row["backup_reason"] = "top5_ranking_group_backup" if 1 < idx <= 5 else "not_backup"
            out.append(row)
        for row in members:
            if row.get("rank_state") not in {"ranked", "ranked_partial", "risk_review"}:
                row["rankable_count"] = str(rankable_count)
                row["ranking_group_rankable_count"] = str(rankable_count)
                row["ranking_group_not_rankable_count"] = str(not_rankable_count)
                row["ranking_group_symbol_count"] = str(len(members))
                out.append(row)
    return out


def _summary_text(summary: L11PublishSummary, guard_blocked: int, guard_passed: int) -> str:
    return "\n".join([
        "schema_name=l11_symbol_ranking_inside_group",
        "schema_version=1",
        f"owner_name={L11_OWNER}",
        "layer_id=11",
        "layer_name=Layer 11 - Symbol Ranking Inside Ranking Group",
        f"status={summary.status}",
        f"reason={summary.reason}",
        "input_taxonomy_source=L10",
        "input_surface_layers=L6,L7,L8,L9",
        "input_current_gate_source=published_current_dossier_route_and_l5_status_guard",
        "component_weights=L6:25,L7:20,L8:25,L9:30",
        f"input_symbol_count={summary.input_symbol_count}",
        f"ranking_group_count={summary.ranking_group_count}",
        f"ranked_symbol_count={summary.ranked_symbol_count}",
        f"ranked_partial_count={summary.ranked_partial_count}",
        f"not_rankable_taxonomy_count={summary.not_rankable_taxonomy_count}",
        f"not_rankable_quality_count={summary.not_rankable_quality_count}",
        f"not_rankable_current_l5_gate_count={guard_blocked}",
        f"current_l5_gate_pass_count={guard_passed}",
        f"unknown_ranking_group_count={summary.unknown_ranking_group_count}",
        f"risk_review_count={summary.risk_review_count}",
        f"top5_group_count={summary.top5_group_count}",
        f"top5_symbol_count={summary.top5_symbol_count}",
        f"visible_selection_desk_groups_written={summary.visible_selection_desk_groups_written}",
        f"visible_selection_desk_groups_expected={summary.visible_selection_desk_groups_expected}",
        f"visible_group_files_written={summary.visible_group_files_written}",
        f"visible_group_files_expected={summary.visible_group_files_expected}",
        f"symbol_rank_files_written={summary.symbol_rank_files_written}",
        f"symbol_rank_files_actual={summary.symbol_rank_files_actual}",
        f"write_failed_count={summary.write_failed_count}",
        "meaning=intra_group_inspection_priority_only_current_l5_guarded",
        "directional_validity=false",
        "expectancy_validated=false",
        "selection_runtime=false",
        "trade_permission=false",
        "entry_signal=false",
        "execution=false",
        f"ranked_symbols_by_group_path={summary.ranked_symbols_by_group_path}",
        f"ranking_group_top5_path={summary.ranking_group_top5_path}",
        f"visible_group_index_path={summary.visible_group_index_path}",
        f"generated_utc={utc_stamp()}",
        f"generated_unix={unix_time()}",
        "",
    ])


def _fallback_summary(layer_dir: Path, ranked_path: Path, ranked: List[Dict[str, str]], inputs: List[Dict[str, str]]) -> L11PublishSummary:
    top5_rows = [row for row in ranked if row.get("in_top5_per_ranking_group") == "true"]
    ranked_count = sum(1 for row in ranked if row.get("rank_state") in {"ranked", "ranked_partial", "risk_review"})
    return L11PublishSummary(
        "accepted",
        "l11_current_gate_guard_legacy_summary_reconstructed",
        len(inputs),
        len(set(row.get("ranking_group", "Unknown") for row in ranked)),
        ranked_count,
        sum(1 for row in ranked if row.get("rank_state") == "ranked_partial"),
        sum(1 for row in ranked if row.get("rank_state") == "risk_review" or row.get("risk_review_flag") == "true"),
        sum(1 for row in ranked if row.get("rank_state") == "not_rankable_taxonomy"),
        sum(1 for row in ranked if row.get("rank_state") == "not_rankable_quality"),
        sum(1 for row in ranked if row.get("ranking_group") in {"Unknown", "not_available"}),
        len(set(row.get("ranking_group", "Unknown") for row in top5_rows)),
        len(top5_rows),
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        str(ranked_path),
        str(layer_dir / "ranking_group_top5.csv"),
        str(_account_root_from_outbox(layer_dir.parents[2]) / "Selection Desk" / "Groups" / "00_Group_Index.txt") if len(layer_dir.parents) >= 3 else "not_available",
        str(layer_dir / "l11_summary.txt"),
    )


def guard_l11_with_current_dossier_gate(outbox_root: Path, summary: L11PublishSummary | None = None) -> L11PublishSummary:
    layer_dir = outbox_root / "Layers" / L11_LAYER_FOLDER
    ranked_path = layer_dir / "ranked_symbols_by_group.csv"
    input_path = layer_dir / "l11_input_surface_scores.csv"
    summary_path = layer_dir / "l11_summary.txt"
    if not ranked_path.exists() or not input_path.exists():
        return summary if summary is not None else L11PublishSummary(
            "pending",
            "l11_current_gate_guard_skipped_missing_l11_payloads",
            summary_path=str(summary_path),
        )

    account_root = _account_root_from_outbox(outbox_root)
    ranked = _csv_rows(ranked_path)
    inputs = _csv_rows(input_path)
    if not ranked:
        return summary if summary is not None else L11PublishSummary(
            "pending",
            "l11_current_gate_guard_skipped_empty_ranked_payload",
            summary_path=str(summary_path),
        )
    if summary is None:
        summary = _fallback_summary(layer_dir, ranked_path, ranked, inputs)

    gate_by_symbol: Dict[str, Tuple[bool, str, str, str]] = {}
    for row in ranked:
        symbol = str(row.get("symbol", "")).strip()
        if symbol and symbol not in gate_by_symbol:
            gate_by_symbol[symbol] = _current_gate_state(account_root, symbol)

    guarded_ranked: List[Dict[str, str]] = []
    guard_blocked = 0
    guard_passed = 0
    for row in ranked:
        symbol = str(row.get("symbol", "")).strip()
        ok, l5_state, _eligible, reason = gate_by_symbol.get(symbol, (False, "blocked_current_gate_missing_symbol", "false", "current_gate_missing_symbol"))
        if ok:
            guard_passed += 1
            new_row = dict(row)
            new_row["l5_gate_state"] = "pass"
            guarded_ranked.append(new_row)
        else:
            guard_blocked += 1
            guarded_ranked.append(_mark_not_rankable(row, l5_state, reason))

    guarded_inputs: List[Dict[str, str]] = []
    for row in inputs:
        symbol = str(row.get("symbol", "")).strip()
        ok, l5_state, eligible, reason = gate_by_symbol.get(symbol, _current_gate_state(account_root, symbol) if symbol else (False, "blocked_current_gate_missing_symbol", "false", "current_gate_missing_symbol"))
        new_row = dict(row)
        new_row["l5_gate_state"] = "pass" if ok else l5_state
        new_row["l5_eligible_flag"] = "true" if ok else eligible
        if not ok:
            new_row["rank_eligibility_state"] = "not_rankable_current_l5_gate"
            new_row["rank_eligibility_reason"] = reason
        guarded_inputs.append(new_row)

    reranked = _rerank(guarded_ranked)

    # Re-publish the guarded packet through the real L11 publication owner.
    # This prevents stale pre-guard Selection Desk group files/indexes from surviving
    # after the current dossier/L5 guard changes rankability.
    republished = _publish(outbox_root, guarded_inputs, reranked)

    ranked_count = sum(1 for row in reranked if row.get("rank_state") in {"ranked", "ranked_partial", "risk_review"})
    ranking_group_count = len(set(row.get("ranking_group", "Unknown") for row in reranked))
    top5_rows = [row for row in reranked if row.get("in_top5_per_ranking_group") == "true"]
    top5_group_count = len(set(row.get("ranking_group", "Unknown") for row in top5_rows))
    risk_review_count = sum(1 for row in reranked if row.get("rank_state") == "risk_review" or row.get("risk_review_flag") == "true")

    guarded_summary = L11PublishSummary(
        "accepted" if republished.status == "accepted" else "write_degraded",
        "l11_current_l5_guard_applied" if republished.status == "accepted" else "l11_current_l5_guard_write_degraded",
        len(guarded_inputs),
        ranking_group_count,
        ranked_count,
        sum(1 for row in reranked if row.get("rank_state") == "ranked_partial"),
        risk_review_count,
        summary.not_rankable_taxonomy_count,
        sum(1 for row in reranked if row.get("rank_state") == "not_rankable_quality"),
        sum(1 for row in reranked if row.get("ranking_group") in {"Unknown", "not_available"}),
        top5_group_count,
        len(top5_rows),
        republished.visible_selection_desk_groups_written,
        republished.visible_selection_desk_groups_expected,
        republished.visible_group_files_written,
        republished.visible_group_files_expected,
        republished.symbol_rank_files_written,
        republished.symbol_rank_files_actual,
        republished.write_failed_count,
        str(ranked_path),
        str(layer_dir / "ranking_group_top5.csv"),
        republished.visible_group_index_path,
        str(summary_path),
    )
    atomic_write_text(summary_path, _summary_text(guarded_summary, guard_blocked, guard_passed))
    report = "\n".join([
        "schema_name=l11_current_dossier_gate_guard",
        "schema_version=2",
        "status=applied" if guarded_summary.status == "accepted" else "status=write_degraded",
        f"input_symbols={len(gate_by_symbol)}",
        f"current_l5_gate_pass_count={guard_passed}",
        f"not_rankable_current_l5_gate_count={guard_blocked}",
        f"legacy_one_argument_compatible={'true' if summary.reason == 'l11_current_gate_guard_legacy_summary_reconstructed' else 'false'}",
        "rule=only_symbols_with_current_open_nonblocked_nonstale_dossier_remain_rankable",
        "authority=safety_filter_inside_l11_dispatch_not_trade_permission",
        "duplicate_dossier_policy=fail_closed_for_rankability",
        "selection_runtime=false",
        "trade_permission=false",
        "entry_signal=false",
        "execution=false",
        f"generated_utc={utc_stamp()}",
        f"generated_unix={unix_time()}",
        "",
    ])
    atomic_write_text(layer_dir / "l11_current_gate_guard_report.txt", report)
    return guarded_summary
