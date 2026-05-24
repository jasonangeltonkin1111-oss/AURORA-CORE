from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Sequence, Tuple
from collections import defaultdict
import csv
import io
import math

from aurora_worker_io import atomic_write_text, payload_checksum, read_text, unix_time, utc_stamp

L11_LAYER_FOLDER = "Layer_11_Symbol_Ranking_Inside_Ranking_Group"
L11_LAYER_ID = "11"
L11_LAYER_NAME = "Layer 11 - Symbol Ranking Inside Ranking Group"
L11_OWNER = "Runtime 5 - Taxonomy / Ranking Group Owner"
L11_SCHEMA_VERSION = "1"
L11_SCHEMA_NAME = "l11_symbol_ranking_inside_group"
L11_AUTHORITY = "intra_group_inspection_priority_only"
L11_COMPONENT_WEIGHTS = {"l6": 25.0, "l7": 20.0, "l8": 25.0, "l9": 30.0}
L11_RANKABLE_TAXONOMY_STATES = {"ACCEPTED_STRICT", "ACCEPTED_PUBLIC_RESEARCH"}
L11_MIN_AVAILABLE_COMPONENTS = 2

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

L11_TOP5_FIELDS = [
    "ranking_group", "ranking_group_slug", "group_state", "rankable_count", "top_rank", "symbol", "l11_group_score", "rank_state",
    "leader_flag", "backup_flag", "component_summary", "risk_review_flag", "reason", "source_ranked_symbols_checksum", "selection_runtime", "trade_permission", "entry_signal", "execution",
]

L11_GROUP_INDEX_FIELDS = [
    "ranking_group", "asset_class", "market_group", "market_segment", "group_symbol_count", "rankable_count", "not_rankable_count",
    "top5_available", "leader_symbol", "leader_score", "risk_review_count", "file_txt", "file_csv", "selection_runtime", "trade_permission", "entry_signal", "execution",
]

@dataclass(frozen=True)
class L11PublishSummary:
    status: str
    reason: str
    input_symbol_count: int = 0
    ranking_group_count: int = 0
    ranked_symbol_count: int = 0
    ranked_partial_count: int = 0
    risk_review_count: int = 0
    not_rankable_taxonomy_count: int = 0
    not_rankable_quality_count: int = 0
    unknown_ranking_group_count: int = 0
    top5_group_count: int = 0
    top5_symbol_count: int = 0
    visible_selection_desk_groups_written: int = 0
    visible_selection_desk_groups_expected: int = 0
    visible_group_files_written: int = 0
    visible_group_files_expected: int = 0
    symbol_rank_files_written: int = 0
    symbol_rank_files_actual: int = 0
    write_failed_count: int = 0
    ranked_symbols_by_group_path: str = "not_available"
    ranking_group_top5_path: str = "not_available"
    visible_group_index_path: str = "not_available"
    summary_path: str = "not_available"

EMPTY_L11_SUMMARY = L11PublishSummary("pending", "l11_not_run")

def _safe_text(row: Dict[str, str], key: str, default: str = "not_available") -> str:
    value = row.get(key, default)
    text = "" if value is None else str(value).strip()
    return text if text else default

def _safe_bool(value: str | None) -> bool:
    return str(value or "").strip().lower() == "true"

def _safe_float(value: str | None) -> Tuple[bool, float]:
    text = str(value or "").strip()
    if text == "" or text.lower() in {"nan", "inf", "-inf", "not_available", "pending", "partial"}:
        return False, 0.0
    try:
        number = float(text)
        return (False, 0.0) if math.isnan(number) or math.isinf(number) else (True, max(0.0, min(100.0, number)))
    except ValueError:
        return False, 0.0

def _parse_kv(text: str) -> Dict[str, str]:
    data: Dict[str, str] = {}
    for raw in text.replace("\r\n", "\n").splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        data[key.strip()] = value.strip()
    return data

def _read_csv(path: Path) -> List[Dict[str, str]]:
    reader = csv.DictReader(io.StringIO(read_text(path).replace("\r\n", "\n")))
    return [{str(k): ("" if v is None else str(v)) for k, v in row.items()} for row in reader]

def _csv_text(rows: Sequence[Dict[str, str]], fields: Sequence[str]) -> str:
    buffer = io.StringIO(newline="")
    writer = csv.DictWriter(buffer, fieldnames=list(fields), extrasaction="ignore", lineterminator="\n")
    writer.writeheader()
    for row in rows:
        writer.writerow({field: str(row.get(field, "not_available")) for field in fields})
    return buffer.getvalue()

def _manifest_text(name: str, row_count: int, payload_text: str, reason: str) -> str:
    return "\n".join([
        f"schema_name={name}_manifest", f"schema_version={L11_SCHEMA_VERSION}", f"layer_id={L11_LAYER_ID}", f"layer_name={L11_LAYER_NAME}",
        f"owner={L11_OWNER}", f"authority={L11_AUTHORITY}", f"row_count={row_count}", f"payload_checksum={payload_checksum(payload_text.splitlines())}",
        f"payload_size_bytes={len(payload_text.encode('utf-8'))}", f"reason={reason}", "directional_validity=false", "expectancy_validated=false",
        "selection_runtime=false", "trade_permission=false", "entry_signal=false", "execution=false", f"generated_utc={utc_stamp()}", f"generated_unix={unix_time()}", "",
    ])

def _sanitize(value: str) -> str:
    safe = str(value).strip() or "unknown"
    for ch in ['\\', '/', ':', '*', '?', '"', '<', '>', '|', ' ']:
        safe = safe.replace(ch, '_')
    return safe

def _write(path: Path, text: str, failed: List[Path]) -> None:
    if not atomic_write_text(path, text):
        failed.append(path)

def _render_index_path(outbox_root: Path, layer_key: str) -> Path:
    return outbox_root / "RenderIndex" / f"{layer_key}_symbol_rank_index.csv"

def _selection_groups_dir(outbox_root: Path) -> Path:
    # outbox = <account>/Workbench/Gateway/Outbox
    account_root = outbox_root.parents[2]
    return account_root / "Selection Desk" / "Groups"

def _component(layer_key: str, symbol: str, render_rows: Dict[str, Dict[str, Dict[str, str]]], render_manifest: Dict[str, str]) -> Dict[str, str]:
    row = render_rows.get(layer_key, {}).get(symbol, {})
    ok, score = _safe_float(row.get("score"))
    rank_state = _safe_text(row, "rank_state", "missing") if row else "missing"
    manifest_status = _safe_text(row, "source_ranked_manifest_status", render_manifest.get(f"{layer_key}_source_manifest_status", "not_available"))
    manifest_checksum = _safe_text(row, "source_ranked_manifest_checksum", render_manifest.get(f"{layer_key}_source_manifest_checksum", "not_available"))
    available = ok and rank_state not in {"missing", "not_available", "not_rankable_quality"}
    stale = manifest_status not in {"complete", "accepted"}
    risk_review = "risk_review" in rank_state or "risk" in _safe_text(row, "bucket", "").lower()
    return {
        "available": "true" if available else "false", "rank_state": rank_state, "score_quality": _safe_text(row, "score_quality", "not_available"),
        "raw_score": f"{score:.2f}" if ok else "not_available", "normalized_score": f"{score:.2f}" if ok else "not_available",
        "manifest_checksum": manifest_checksum, "manifest_status": manifest_status, "stale": "true" if stale else "false", "risk_review": "true" if risk_review else "false",
        "reason": "available" if available else "missing_or_unusable_score", "weight": str(int(L11_COMPONENT_WEIGHTS[layer_key])),
    }

def _eligibility(tax: Dict[str, str], components: Dict[str, Dict[str, str]]) -> Tuple[str, str]:
    taxonomy_state = _safe_text(tax, "taxonomy_state", "UNKNOWN")
    ranking_group = _safe_text(tax, "ranking_group", "Unknown")
    rank_allowed = _safe_bool(tax.get("rank_allowed"))
    if ranking_group in {"", "Unknown", "not_available"} or taxonomy_state not in L11_RANKABLE_TAXONOMY_STATES or not rank_allowed:
        return "not_rankable_taxonomy", f"taxonomy_state={taxonomy_state};ranking_group={ranking_group};rank_allowed={str(rank_allowed).lower()}"
    available_count = sum(1 for item in components.values() if item.get("available") == "true")
    if available_count < L11_MIN_AVAILABLE_COMPONENTS:
        return "not_rankable_quality", f"available_components={available_count};minimum_required={L11_MIN_AVAILABLE_COMPONENTS}"
    if any(item.get("risk_review") == "true" for item in components.values()):
        return "risk_review", "rankable_with_risk_review_component"
    return ("ranked_partial", f"rankable_partial_components={available_count}") if available_count < 4 else ("ranked", "rankable_clean_all_components_available")

def _score(components: Dict[str, Dict[str, str]], rank_state: str) -> Tuple[float, float, float, float, float, str, int, int]:
    weighted_sum = weight_sum = missing_penalty = stale_penalty = risk_penalty = 0.0
    missing_count = stale_count = 0
    parts: List[str] = []
    for key in ("l6", "l7", "l8", "l9"):
        item = components[key]
        ok, score = _safe_float(item.get("normalized_score"))
        weight = L11_COMPONENT_WEIGHTS[key]
        if item.get("available") == "true" and ok:
            weighted_sum += score * weight
            weight_sum += weight
            parts.append(f"{key.upper()}={score:.1f}")
        else:
            missing_count += 1
            missing_penalty += -12.0 if key in {"l8", "l9"} else -5.0
            parts.append(f"{key.upper()}=missing")
        if item.get("stale") == "true":
            stale_count += 1
            stale_penalty -= 8.0
        if item.get("risk_review") == "true":
            risk_penalty -= 5.0
    average = weighted_sum / weight_sum if weight_sum > 0 else 0.0
    final_score = 0.0 if rank_state.startswith("not_rankable") else max(0.0, min(100.0, average + missing_penalty + stale_penalty + risk_penalty))
    return final_score, average, missing_penalty, stale_penalty, risk_penalty, ";".join(parts), missing_count, stale_count

def _rank_rows(rows: List[Dict[str, str]]) -> List[Dict[str, str]]:
    state_order = {"ranked": 0, "ranked_partial": 1, "risk_review": 2, "not_rankable_quality": 3, "not_rankable_taxonomy": 4}
    groups: Dict[str, List[Dict[str, str]]] = defaultdict(list)
    for row in rows:
        groups[row.get("ranking_group", "Unknown")].append(row)
    ranked: List[Dict[str, str]] = []
    for _group, members in sorted(groups.items()):
        rankable = [r for r in members if not str(r.get("rank_state", "")).startswith("not_rankable")]
        not_rankable_count = len(members) - len(rankable)
        rankable.sort(key=lambda r: (state_order.get(r.get("rank_state", "not_rankable_quality"), 9), -float(r.get("l11_group_score", "0") or 0), -int(r.get("component_available_count", "0") or 0), r.get("symbol", "")))
        rankable_count = len(rankable)
        for idx, row in enumerate(rankable, start=1):
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
            ranked.append(row)
        for row in members:
            if str(row.get("rank_state", "")).startswith("not_rankable"):
                row.update({"ranking_group_rank":"not_available", "rankable_count":str(rankable_count), "ranking_group_rankable_count":str(rankable_count), "ranking_group_not_rankable_count":str(not_rankable_count), "ranking_group_symbol_count":str(len(members)), "ranking_group_rank_percentile":"not_available", "in_top5_per_ranking_group":"false", "leader_flag":"false", "backup_flag":"false", "backup_rank":"not_available", "backup_reason":"not_rankable"})
                ranked.append(row)
    return ranked

def _summary_text(summary: L11PublishSummary) -> str:
    return "\n".join([
        f"schema_name={L11_SCHEMA_NAME}", f"schema_version={L11_SCHEMA_VERSION}", f"owner_name={L11_OWNER}", f"layer_id={L11_LAYER_ID}", f"layer_name={L11_LAYER_NAME}",
        f"status={summary.status}", f"reason={summary.reason}", "input_taxonomy_source=L10", "input_surface_layers=L6,L7,L8,L9", "component_weights=L6:25,L7:20,L8:25,L9:30",
        f"input_symbol_count={summary.input_symbol_count}", f"ranking_group_count={summary.ranking_group_count}", f"ranked_symbol_count={summary.ranked_symbol_count}",
        f"ranked_partial_count={summary.ranked_partial_count}", f"not_rankable_taxonomy_count={summary.not_rankable_taxonomy_count}", f"not_rankable_quality_count={summary.not_rankable_quality_count}",
        f"unknown_ranking_group_count={summary.unknown_ranking_group_count}", f"risk_review_count={summary.risk_review_count}", f"top5_group_count={summary.top5_group_count}", f"top5_symbol_count={summary.top5_symbol_count}",
        f"visible_selection_desk_groups_written={summary.visible_selection_desk_groups_written}", f"visible_selection_desk_groups_expected={summary.visible_selection_desk_groups_expected}",
        f"visible_group_files_written={summary.visible_group_files_written}", f"visible_group_files_expected={summary.visible_group_files_expected}", f"symbol_rank_files_written={summary.symbol_rank_files_written}",
        f"symbol_rank_files_actual={summary.symbol_rank_files_actual}", f"write_failed_count={summary.write_failed_count}", "meaning=intra_group_inspection_priority_only", "directional_validity=false",
        "expectancy_validated=false", "selection_runtime=false", "trade_permission=false", "entry_signal=false", "execution=false", f"ranked_symbols_by_group_path={summary.ranked_symbols_by_group_path}",
        f"ranking_group_top5_path={summary.ranking_group_top5_path}", f"visible_group_index_path={summary.visible_group_index_path}", f"generated_utc={utc_stamp()}", f"generated_unix={unix_time()}", "",
    ])

def _symbol_rank_text(row: Dict[str, str]) -> str:
    keys = ["symbol", "ranking_group", "ranking_group_rank", "rankable_count", "ranking_group_rank_percentile", "in_top5_per_ranking_group", "leader_flag", "backup_flag", "l11_group_score", "rank_state", "l6_score", "l6_state", "l7_score", "l7_state", "l8_score", "l8_state", "l9_score", "l9_state", "reason", "meaning", "selection_runtime", "trade_permission", "entry_signal", "execution"]
    return "\n".join([f"schema_name=l11_symbol_rank_sidecar", f"schema_version={L11_SCHEMA_VERSION}", f"owner={L11_OWNER}", f"layer_id={L11_LAYER_ID}", f"layer_name={L11_LAYER_NAME}"] + [f"{key}={row.get(key, 'not_available')}" for key in keys] + [f"generated_utc={utc_stamp()}", f"generated_unix={unix_time()}", ""])

def _group_txt(group: str, rows: List[Dict[str, str]], top5: List[Dict[str, str]], main_blocker: str) -> str:
    asset_class = sorted({r.get("asset_class", "Unknown") for r in rows})
    market_group = sorted({r.get("market_group", "Unknown") for r in rows})
    market_segment = sorted({r.get("market_segment", "Unknown") for r in rows})
    lines = [
        "L11 - SYMBOL RANKING INSIDE RANKING GROUP", "----------------------------------------", f"Ranking Group: {group}",
        f"Asset Class: {asset_class[0] if len(asset_class)==1 else 'mixed'}", f"Market Group: {market_group[0] if len(market_group)==1 else 'mixed'}", f"Market Segment: {market_segment[0] if len(market_segment)==1 else 'mixed'}",
        f"Group Symbol Count: {len(rows)}", f"Rankable Symbols: {sum(1 for r in rows if not r.get('rank_state','').startswith('not_rankable'))}", f"Not Rankable: {sum(1 for r in rows if r.get('rank_state','').startswith('not_rankable'))}",
        "Top 5 per ranking_group:",
    ]
    for r in top5:
        lines.append(f"#{r.get('ranking_group_rank')} {r.get('symbol')} score={r.get('l11_group_score')} state={r.get('rank_state')} leader={r.get('leader_flag')} backup={r.get('backup_flag')}")
    lines += ["Policy: intra_group_inspection_priority_only", "Selection Runtime: FALSE", "Trade Permission: FALSE", "Entry Signal: FALSE", "Execution: FALSE", "Source: L10 + L6-L9", f"Generated UTC: {utc_stamp()}", f"Main Blocker: {main_blocker}", ""]
    return "\n".join(lines)

def _group_index_text(summary: L11PublishSummary) -> str:
    return "\n".join([
        "L11 SELECTION DESK GROUPS INDEX", "----------------------------------------", f"L11 Status: {summary.status}", f"Ranking Groups: {summary.ranking_group_count}", f"Groups With Top 5: {summary.top5_group_count}",
        f"Ranked Symbols: {summary.ranked_symbol_count}", f"Not Rankable Taxonomy: {summary.not_rankable_taxonomy_count}", f"Risk Review Symbols: {summary.risk_review_count}",
        f"Visible Group Files Written: {summary.visible_group_files_written}", f"Visible Group Files Expected: {summary.visible_group_files_expected}", "selection_runtime=false", "trade_permission=false", "entry_signal=false", "execution=false", f"main_blocker={summary.reason if summary.status != 'accepted' else 'none'}", f"generated_utc={utc_stamp()}", "",
    ])

def _publish(outbox_root: Path, input_rows: List[Dict[str, str]], ranked_rows: List[Dict[str, str]]) -> L11PublishSummary:
    layer_dir = outbox_root / "Layers" / L11_LAYER_FOLDER
    group_dir = layer_dir / "RankingGroups"
    symbol_dir = layer_dir / "SymbolRanks"
    visible_dir = _selection_groups_dir(outbox_root)
    for d in (layer_dir, group_dir, symbol_dir, visible_dir): d.mkdir(parents=True, exist_ok=True)
    failed: List[Path] = []
    input_csv = _csv_text(input_rows, L11_INPUT_FIELDS)
    ranked_csv = _csv_text(ranked_rows, L11_RANKED_FIELDS)
    ranked_checksum = payload_checksum(ranked_csv.splitlines())
    top5_rows = [dict(row, top_rank=row.get("ranking_group_rank", "not_available"), group_state="l11_ranked_view", source_ranked_symbols_checksum=ranked_checksum) for row in ranked_rows if row.get("in_top5_per_ranking_group") == "true"]
    top5_csv = _csv_text(top5_rows, L11_TOP5_FIELDS)
    top5_text = "\n".join(["LAYER 11 - TOP 5 PER RANKING_GROUP", "----------------------------------------"] + [f"{r.get('ranking_group')} | #{r.get('ranking_group_rank')} {r.get('symbol')} | L11 {r.get('l11_group_score')} | {r.get('rank_state')} | trade_permission=false" for r in top5_rows] + [""])
    _write(layer_dir / "l11_input_surface_scores.csv", input_csv, failed)
    _write(layer_dir / "l11_input_surface_scores.manifest", _manifest_text("l11_input_surface_scores", len(input_rows), input_csv, "l11_input_surface_scores_published"), failed)
    _write(layer_dir / "ranked_symbols_by_group.csv", ranked_csv, failed)
    _write(layer_dir / "ranked_symbols_by_group.manifest", _manifest_text("l11_ranked_symbols_by_group", len(ranked_rows), ranked_csv, "l11_ranked_symbols_by_group_published"), failed)
    _write(layer_dir / "ranking_group_top5.csv", top5_csv, failed)
    _write(layer_dir / "ranking_group_top5.txt", top5_text, failed)
    group_index_rows: List[Dict[str, str]] = []
    visible_written = 0
    for group in sorted(set(row.get("ranking_group", "Unknown") for row in ranked_rows)):
        slug = _sanitize(group)
        group_rows = [row for row in ranked_rows if row.get("ranking_group") == group]
        group_top5 = [row for row in group_rows if row.get("in_top5_per_ranking_group") == "true"]
        group_csv = _csv_text(group_rows, L11_RANKED_FIELDS)
        group_text = _group_txt(group, group_rows, group_top5, "none" if group_top5 else "no_rankable_top5_rows")
        _write(group_dir / f"{slug}.ranked_symbols.csv", group_csv, failed)
        _write(group_dir / f"{slug}.top5.txt", group_text, failed)
        before = len(failed)
        _write(visible_dir / f"{slug}.txt", group_text, failed)
        _write(visible_dir / f"{slug}.csv", group_csv, failed)
        if len(failed) == before: visible_written += 2
        leader = group_top5[0] if group_top5 else {}
        group_index_rows.append({"ranking_group": group, "asset_class": leader.get("asset_class", "mixed_or_not_available"), "market_group": leader.get("market_group", "mixed_or_not_available"), "market_segment": leader.get("market_segment", "mixed_or_not_available"), "group_symbol_count": str(len(group_rows)), "rankable_count": str(sum(1 for r in group_rows if not r.get('rank_state','').startswith('not_rankable'))), "not_rankable_count": str(sum(1 for r in group_rows if r.get('rank_state','').startswith('not_rankable'))), "top5_available": "true" if group_top5 else "false", "leader_symbol": leader.get("symbol", "not_available"), "leader_score": leader.get("l11_group_score", "not_available"), "risk_review_count": str(sum(1 for r in group_rows if r.get("risk_review_flag") == "true")), "file_txt": str(visible_dir / f"{slug}.txt"), "file_csv": str(visible_dir / f"{slug}.csv"), "selection_runtime": "false", "trade_permission": "false", "entry_signal": "false", "execution": "false"})
    group_index_csv = _csv_text(group_index_rows, L11_GROUP_INDEX_FIELDS)
    symbol_written = 0
    for row in ranked_rows:
        symbol = row.get("symbol", "unknown")
        _write(symbol_dir / f"{_sanitize(symbol)}__{payload_checksum([symbol])}.txt", _symbol_rank_text(row), failed)
        symbol_written += 1
    symbol_actual = sum(1 for path in symbol_dir.glob("*.txt") if path.is_file())
    ranked_count = sum(1 for row in ranked_rows if row.get("rank_state") in {"ranked", "ranked_partial", "risk_review"})
    visible_expected = len(group_index_rows) * 2
    summary = L11PublishSummary("accepted" if not failed and symbol_actual == symbol_written else "write_degraded", "l11_symbol_ranking_and_selection_desk_groups_published" if not failed and symbol_actual == symbol_written else "one_or_more_l11_outputs_failed_or_symbol_sidecar_count_mismatch", len(input_rows), len(group_index_rows), ranked_count, sum(1 for r in ranked_rows if r.get("rank_state") == "ranked_partial"), sum(1 for r in ranked_rows if r.get("rank_state") == "risk_review"), sum(1 for r in ranked_rows if r.get("rank_state") == "not_rankable_taxonomy"), sum(1 for r in ranked_rows if r.get("rank_state") == "not_rankable_quality"), sum(1 for r in ranked_rows if r.get("ranking_group") in {"Unknown", "not_available"}), len(set(r.get("ranking_group", "Unknown") for r in top5_rows)), len(top5_rows), len(group_index_rows), len(group_index_rows), visible_written, visible_expected, symbol_written, symbol_actual, len(failed), str(layer_dir / "ranked_symbols_by_group.csv"), str(layer_dir / "ranking_group_top5.csv"), str(visible_dir / "00_Group_Index.txt"), str(layer_dir / "l11_summary.txt"))
    _write(layer_dir / "l11_summary.txt", _summary_text(summary), failed)
    _write(visible_dir / "00_Group_Index.txt", _group_index_text(summary), failed)
    _write(visible_dir / "00_Group_Index.csv", group_index_csv, failed)
    return summary

def publish_l11_symbol_ranking_inside_group(outbox_root: Path) -> L11PublishSummary:
    l10_dir = outbox_root / "Layers" / "Layer_10_Taxonomy_Classification"
    required = [l10_dir / "taxonomy_symbols.csv", l10_dir / "ranking_groups.csv", outbox_root / "RenderIndex" / "render_index.manifest"] + [_render_index_path(outbox_root, key) for key in ("l6", "l7", "l8", "l9")]
    missing = [str(path) for path in required if not path.exists()]
    if missing:
        return L11PublishSummary("pending", "missing_required_l11_source: " + ";".join(missing))
    try:
        taxonomy_rows = _read_csv(l10_dir / "taxonomy_symbols.csv")
        group_rows = _read_csv(l10_dir / "ranking_groups.csv")
        render_manifest = _parse_kv(read_text(outbox_root / "RenderIndex" / "render_index.manifest"))
        if render_manifest.get("status", "") not in {"complete", "accepted"}:
            return L11PublishSummary("degraded", "render_index_not_complete_status=" + render_manifest.get("status", "not_available"))
        render_rows: Dict[str, Dict[str, Dict[str, str]]] = {key: {_safe_text(row, "symbol", ""): row for row in _read_csv(_render_index_path(outbox_root, key)) if _safe_text(row, "symbol", "")} for key in ("l6", "l7", "l8", "l9")}
        taxonomy = {_safe_text(row, "symbol", ""): row for row in taxonomy_rows if _safe_text(row, "symbol", "")}
        group_slugs = {_safe_text(row, "ranking_group", "Unknown"): _safe_text(row, "ranking_group_slug", "Unknown") for row in group_rows}
        symbols = sorted(set(taxonomy.keys()).intersection(set().union(*(set(layer.keys()) for layer in render_rows.values()))))
        input_rows: List[Dict[str, str]] = []
        base_rows: List[Dict[str, str]] = []
        for symbol in symbols:
            tax = taxonomy[symbol]
            components = {key: _component(key, symbol, render_rows, render_manifest) for key in ("l6", "l7", "l8", "l9")}
            available_count = sum(1 for item in components.values() if item["available"] == "true")
            rank_state, reason = _eligibility(tax, components)
            score, average, missing_penalty, stale_penalty, risk_penalty, component_summary, missing_count, stale_count = _score(components, rank_state)
            ranking_group = _safe_text(tax, "ranking_group", "Unknown")
            l5_gate_state = _safe_text(tax, "l5_gate_state", "not_available")
            input_row = {"symbol": symbol, "canonical_symbol": _safe_text(tax, "canonical_symbol", symbol), "asset_class": _safe_text(tax, "asset_class", "Unknown"), "market_group": _safe_text(tax, "market_group", "Unknown"), "market_segment": _safe_text(tax, "market_segment", "Unknown"), "ranking_group": ranking_group, "ranking_group_slug": group_slugs.get(ranking_group, _sanitize(ranking_group)), "taxonomy_state": _safe_text(tax, "taxonomy_state", "UNKNOWN"), "review_state": _safe_text(tax, "review_state", "not_available"), "rank_allowed": _safe_text(tax, "rank_allowed", "false"), "selection_allowed": _safe_text(tax, "selection_allowed", "false"), "l5_gate_state": l5_gate_state, "l5_eligible_flag": _safe_text(tax, "l5_eligible_flag", "not_available"), "component_available_count": str(available_count), "component_missing_count": str(4 - available_count), "input_quality_state": "complete" if available_count == 4 else ("partial" if available_count >= 2 else "degraded"), "rank_eligibility_state": rank_state, "rank_eligibility_reason": reason, "selection_runtime": "false", "trade_permission": "false", "entry_signal": "false", "execution": "false"}
            for key in ("l6", "l7", "l8", "l9"):
                item = components[key]
                input_row[f"{key}_available"] = item["available"]; input_row[f"{key}_rank_state"] = item["rank_state"]; input_row[f"{key}_score_quality"] = item["score_quality"]; input_row[f"{key}_raw_score"] = item["raw_score"]; input_row[f"{key}_normalized_score"] = item["normalized_score"]; input_row[f"{key}_manifest_checksum"] = item["manifest_checksum"]; input_row[f"{key}_manifest_status"] = item["manifest_status"]; input_row[f"{key}_reason"] = item["reason"]
            input_rows.append(input_row)
            source_checksum = payload_checksum([symbol, ranking_group, component_summary])
            base_rows.append({"ranking_group": ranking_group, "ranking_group_slug": input_row["ranking_group_slug"], "symbol": symbol, "canonical_symbol": input_row["canonical_symbol"], "asset_class": input_row["asset_class"], "market_group": input_row["market_group"], "market_segment": input_row["market_segment"], "l5_gate_state": l5_gate_state, "l11_group_score": f"{score:.2f}", "rank_state": rank_state, "risk_review_flag": "true" if rank_state == "risk_review" else "false", "not_rankable_reason": reason if rank_state.startswith("not_rankable") else "not_applicable", "component_available_count": str(available_count), "component_missing_count": str(4 - available_count), "missing_layer_count": str(missing_count), "stale_layer_count": str(stale_count), "weighted_available_average": f"{average:.2f}", "missing_layer_penalty": f"{missing_penalty:.2f}", "stale_layer_penalty": f"{stale_penalty:.2f}", "risk_review_penalty": f"{risk_penalty:.2f}", "l6_score": components["l6"]["normalized_score"], "l6_weight": components["l6"]["weight"], "l6_state": components["l6"]["rank_state"], "l7_score": components["l7"]["normalized_score"], "l7_weight": components["l7"]["weight"], "l7_state": components["l7"]["rank_state"], "l8_score": components["l8"]["normalized_score"], "l8_weight": components["l8"]["weight"], "l8_state": components["l8"]["rank_state"], "l9_score": components["l9"]["normalized_score"], "l9_weight": components["l9"]["weight"], "l9_state": components["l9"]["rank_state"], "component_summary": component_summary, "reason": reason, "meaning": "intra_group_inspection_priority_only", "directional_validity": "false", "expectancy_validated": "false", "selection_runtime": "false", "trade_permission": "false", "entry_signal": "false", "execution": "false", "source_checksum": source_checksum})
        return _publish(outbox_root, input_rows, _rank_rows(base_rows))
    except Exception as exc:
        return L11PublishSummary("exception", f"{type(exc).__name__}: {exc}")
