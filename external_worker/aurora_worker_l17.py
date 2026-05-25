from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Tuple
import csv
import io
import math

from aurora_worker_io import atomic_write_text, payload_checksum, read_text, unix_time, utc_stamp

L17_LAYER_FOLDER = "Layer_17_Deep_Evidence_Selection_Split"
L17_OWNER = "Runtime 4 - Surface Scoring / Deep Evidence Selection Support"
L17_AUTHORITY = "deep_evidence_selection_split_only"
L17_SCHEMA_NAME = "l17_deep_evidence_selection_split"
L17_MAX_DEEP_SELECTED = 5
L17_FULL_DEPTH_LIMIT = 3

SELECTED_FIELDS = [
    "deep_evidence_rank", "symbol", "canonical_symbol", "source_l16_display_rank", "source_l16_global_rank",
    "source_l16_selection_tier", "source_l16_clean_diversified", "source_l16_fallback_fill_used", "source_l16_fallback_reason",
    "source_l16_hold_state", "source_l16_hold_visible", "source_l16_visible_surface_state", "ranking_group", "asset_class", "market_group", "market_segment",
    "l16_primary_score", "max_corr_to_selected", "max_corr_pair_symbol", "correlation_state", "correlation_clean_flag",
    "deep_evidence_selected", "visible_only", "alert_eligible_candidate", "depth_assignment", "evidence_budget_class",
    "ohlc_depth", "tick_depth", "indicator_depth", "liquidity_depth", "selection_reason", "selection_source",
    "evidence_collection_scope", "heavy_data_allowed", "meaning", "deep_evidence_runtime", "trade_permission", "entry_signal", "execution", "generated_utc",
]

REJECTED_FIELDS = [
    "visible_rank", "symbol", "canonical_symbol", "source_l16_selection_tier", "source_l16_clean_diversified", "source_l16_fallback_fill_used",
    "ranking_group", "l16_primary_score", "reject_reason", "would_have_depth", "visible_only", "deep_evidence_selected",
    "heavy_data_allowed", "trade_permission", "entry_signal", "execution", "generated_utc",
]

DEPTH_SUMMARY_FIELDS = ["depth_assignment", "count", "meaning", "generated_utc"]


@dataclass(frozen=True)
class L17PublishSummary:
    status: str
    reason: str
    visible_candidate_count: int = 0
    deep_selected_count: int = 0
    rejected_candidate_count: int = 0
    clean_selected_count: int = 0
    fallback_selected_count: int = 0
    full_depth_count: int = 0
    standard_depth_count: int = 0
    fallback_limited_depth_count: int = 0
    watch_only_count: int = 0
    alert_eligible_candidate_count: int = 0
    write_failed_count: int = 0
    source_path: str = "not_available"
    source_l16_status: str = "not_available"
    source_l16_hold_state: str = "not_available"
    source_l16_visible_surface_state: str = "not_available"
    top_symbol: str = "not_available"
    output_path: str = "not_available"
    rejected_path: str = "not_available"
    summary_path: str = "not_available"
    selection_desk_path: str = "not_available"


EMPTY_L17_SUMMARY = L17PublishSummary("pending", "l17_not_run")


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


def _bool_text(row: Dict[str, str], key: str) -> str:
    return "true" if _text(row, key, "false").lower() == "true" else "false"


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
    return outbox.parents[2]


def _global_dir(outbox: Path) -> Path:
    return _root_from_outbox(outbox) / "Selection Desk" / "Global"


def _write(path: Path, text: str, failed: List[Path]) -> None:
    if not atomic_write_text(path, text):
        failed.append(path)


def _source_rows(outbox_root: Path) -> Tuple[List[Dict[str, str]], Path, str]:
    layer_csv = outbox_root / "Layers" / "Layer_16_Global_Top10_Builder" / "l16_global_top10.csv"
    rows = _csv(layer_csv)
    if rows:
        return rows, layer_csv, "l16_layer_visible_held_global_top10"
    visible_csv = _global_dir(outbox_root) / "current_top10.csv"
    rows = _csv(visible_csv)
    if rows:
        return rows, visible_csv, "selection_desk_visible_current_top10_fallback"
    return [], layer_csv, "missing_l16_visible_candidates"


def _tier_weight(row: Dict[str, str]) -> int:
    tier = _text(row, "selection_tier", "not_available")
    if tier == "CLEAN":
        return 0
    if tier == "CLEAN_DEGRADED":
        return 1
    if tier == "FALLBACK_SOFT_CORR":
        return 3
    if tier == "FALLBACK_MEDIUM_CORR":
        return 4
    if tier == "FALLBACK_NEXT_BEST_UNCLEAN":
        return 5
    return 6


def _visible_rank(row: Dict[str, str], default: int) -> int:
    return _int(row.get("display_slot_rank"), _int(row.get("global_top10_rank"), default))


def _ordered_visible_rows(rows: List[Dict[str, str]]) -> List[Dict[str, str]]:
    return sorted(rows, key=lambda r: (_tier_weight(r), _visible_rank(r, 999), -_num(r.get("l16_primary_score")), _text(r, "symbol")))


def _depth_for_selected(deep_rank: int, row: Dict[str, str]) -> Dict[str, str]:
    tier = _text(row, "selection_tier")
    clean = _bool_text(row, "clean_diversified") == "true"
    fallback = _bool_text(row, "fallback_fill_used") == "true" or tier.startswith("FALLBACK")
    if clean and deep_rank <= L17_FULL_DEPTH_LIMIT:
        return {
            "depth_assignment": "full_deep_pack_request",
            "evidence_budget_class": "full_clean_budget",
            "ohlc_depth": "selected_deep",
            "tick_depth": "selected_deep",
            "indicator_depth": "selected_deep",
            "liquidity_depth": "selected_deep_proxy_only",
            "selection_reason": "clean_l16_visible_candidate_inside_full_depth_budget",
        }
    if clean:
        return {
            "depth_assignment": "standard_deep_pack_request",
            "evidence_budget_class": "standard_clean_budget",
            "ohlc_depth": "selected_standard",
            "tick_depth": "deferred_unless_needed",
            "indicator_depth": "selected_standard",
            "liquidity_depth": "deferred_proxy_only",
            "selection_reason": "clean_l16_visible_candidate_inside_standard_depth_budget",
        }
    if fallback:
        return {
            "depth_assignment": "fallback_limited_review_request",
            "evidence_budget_class": "fallback_limited_budget",
            "ohlc_depth": "selected_light_or_standard_only",
            "tick_depth": "deferred_unless_later_layer_requires",
            "indicator_depth": "selected_light_or_standard_only",
            "liquidity_depth": "none_until_repromoted",
            "selection_reason": "fallback_l16_visible_candidate_selected_only_because_clean_budget_not_filled;truth_labels_preserved",
        }
    return {
        "depth_assignment": "standard_deep_pack_request",
        "evidence_budget_class": "standard_unknown_budget",
        "ohlc_depth": "selected_standard",
        "tick_depth": "deferred_unless_needed",
        "indicator_depth": "selected_standard",
        "liquidity_depth": "deferred_proxy_only",
        "selection_reason": "visible_l16_candidate_selected_with_unknown_tier_degraded",
    }


def _watch_depth(row: Dict[str, str]) -> Dict[str, str]:
    return {
        "depth_assignment": "visible_watch_only_no_expensive_collection",
        "evidence_budget_class": "watch_only_no_heavy_budget",
        "ohlc_depth": "watch_light_or_none",
        "tick_depth": "none",
        "indicator_depth": "none",
        "liquidity_depth": "none",
        "selection_reason": "visible_l16_candidate_outside_l17_deep_budget",
    }


def _selected_row(row: Dict[str, str], deep_rank: int, assignment: Dict[str, str], source_kind: str, summary_kv: Dict[str, str]) -> Dict[str, str]:
    visible_rank = _visible_rank(row, deep_rank)
    fallback = _bool_text(row, "fallback_fill_used")
    return {
        "deep_evidence_rank": str(deep_rank),
        "symbol": _text(row, "symbol"),
        "canonical_symbol": _text(row, "canonical_symbol", _text(row, "symbol")),
        "source_l16_display_rank": str(visible_rank),
        "source_l16_global_rank": _text(row, "global_top10_rank", str(visible_rank)),
        "source_l16_selection_tier": _text(row, "selection_tier"),
        "source_l16_clean_diversified": _bool_text(row, "clean_diversified"),
        "source_l16_fallback_fill_used": fallback,
        "source_l16_fallback_reason": _text(row, "fallback_reason", "not_required"),
        "source_l16_hold_state": _text(row, "hold_state", summary_kv.get("l16_hold_state", "not_available")),
        "source_l16_hold_visible": _bool_text(row, "hold_visible"),
        "source_l16_visible_surface_state": summary_kv.get("l16_visible_surface_state", "not_available"),
        "ranking_group": _text(row, "ranking_group"),
        "asset_class": _text(row, "asset_class"),
        "market_group": _text(row, "market_group"),
        "market_segment": _text(row, "market_segment"),
        "l16_primary_score": _text(row, "l16_primary_score"),
        "max_corr_to_selected": _text(row, "max_corr_to_selected"),
        "max_corr_pair_symbol": _text(row, "max_corr_pair_symbol"),
        "correlation_state": _text(row, "correlation_state"),
        "correlation_clean_flag": _text(row, "correlation_clean_flag", "false"),
        "deep_evidence_selected": "true",
        "visible_only": "false",
        "alert_eligible_candidate": "false",
        **assignment,
        "selection_source": source_kind,
        "evidence_collection_scope": "selected_visible_l16_display_rows_only_no_all_symbol_scan",
        "heavy_data_allowed": "true",
        "meaning": "l17_evidence_budget_queue_split_only_not_evidence_collection_not_trade_permission",
        "deep_evidence_runtime": "false",
        "trade_permission": "false",
        "entry_signal": "false",
        "execution": "false",
        "generated_utc": utc_stamp(),
    }


def _rejected_row(row: Dict[str, str], assignment: Dict[str, str], reason: str) -> Dict[str, str]:
    visible_rank = _visible_rank(row, 999)
    return {
        "visible_rank": str(visible_rank),
        "symbol": _text(row, "symbol"),
        "canonical_symbol": _text(row, "canonical_symbol", _text(row, "symbol")),
        "source_l16_selection_tier": _text(row, "selection_tier"),
        "source_l16_clean_diversified": _bool_text(row, "clean_diversified"),
        "source_l16_fallback_fill_used": _bool_text(row, "fallback_fill_used"),
        "ranking_group": _text(row, "ranking_group"),
        "l16_primary_score": _text(row, "l16_primary_score"),
        "reject_reason": reason,
        "would_have_depth": assignment.get("depth_assignment", "visible_watch_only_no_expensive_collection"),
        "visible_only": "true",
        "deep_evidence_selected": "false",
        "heavy_data_allowed": "false",
        "trade_permission": "false",
        "entry_signal": "false",
        "execution": "false",
        "generated_utc": utc_stamp(),
    }


def _build_split(rows: List[Dict[str, str]], source_kind: str, summary_kv: Dict[str, str]) -> Tuple[List[Dict[str, str]], List[Dict[str, str]]]:
    selected: List[Dict[str, str]] = []
    rejected: List[Dict[str, str]] = []
    seen: set[str] = set()
    for row in _ordered_visible_rows(rows):
        symbol = _text(row, "symbol", "")
        if not symbol or symbol in seen:
            continue
        seen.add(symbol)
        if len(selected) < L17_MAX_DEEP_SELECTED:
            deep_rank = len(selected) + 1
            assignment = _depth_for_selected(deep_rank, row)
            selected.append(_selected_row(row, deep_rank, assignment, source_kind, summary_kv))
        else:
            assignment = _watch_depth(row)
            rejected.append(_rejected_row(row, assignment, "outside_l17_max_deep_selected_budget"))
    return selected, rejected


def _depth_summary(rows: List[Dict[str, str]], rejected: List[Dict[str, str]]) -> List[Dict[str, str]]:
    counts: Dict[str, int] = {}
    for row in rows:
        key = row.get("depth_assignment", "not_available")
        counts[key] = counts.get(key, 0) + 1
    for row in rejected:
        key = row.get("would_have_depth", "visible_watch_only_no_expensive_collection")
        counts[key] = counts.get(key, 0) + 1
    return [{"depth_assignment": key, "count": str(count), "meaning": "attention_budget_split_not_trade_permission", "generated_utc": utc_stamp()} for key, count in sorted(counts.items())]


def _manifest(payload: str, summary: L17PublishSummary) -> str:
    return "\n".join([
        "schema_name=l17_deep_evidence_manifest", "schema_version=2", "layer_id=17", "layer_name=Layer 17 - Deep Evidence Selection Split",
        f"owner={L17_OWNER}", f"authority={L17_AUTHORITY}", f"visible_candidate_count={summary.visible_candidate_count}",
        f"deep_selected_count={summary.deep_selected_count}", f"rejected_candidate_count={summary.rejected_candidate_count}",
        f"clean_selected_count={summary.clean_selected_count}", f"fallback_selected_count={summary.fallback_selected_count}",
        f"max_deep_selected={L17_MAX_DEEP_SELECTED}", f"source_path={summary.source_path}", f"source_l16_status={summary.source_l16_status}",
        f"source_l16_hold_state={summary.source_l16_hold_state}", f"source_l16_visible_surface_state={summary.source_l16_visible_surface_state}",
        "input_source=L16_held_visible_display_rows_only", "collects_ohlc=false", "collects_ticks=false", "collects_indicators=false",
        "collects_liquidity=false", "all_symbol_scan=false", "broker_polling=false", "private_ohlc_cache=false",
        f"payload_checksum={payload_checksum(payload.splitlines())}", "deep_evidence_runtime=false", "trade_permission=false", "entry_signal=false", "execution=false",
        f"generated_utc={utc_stamp()}", f"generated_unix={unix_time()}", "",
    ])


def _summary_text(summary: L17PublishSummary) -> str:
    return "\n".join([
        f"schema_name={L17_SCHEMA_NAME}", "schema_version=2", f"owner_name={L17_OWNER}", "layer_id=17", "layer_name=Layer 17 - Deep Evidence Selection Split",
        f"status={summary.status}", f"reason={summary.reason}", "input_source=L16_held_visible_display_rows_only",
        f"source_path={summary.source_path}", f"source_l16_status={summary.source_l16_status}",
        f"source_l16_hold_state={summary.source_l16_hold_state}", f"source_l16_visible_surface_state={summary.source_l16_visible_surface_state}",
        f"visible_candidate_count={summary.visible_candidate_count}", f"deep_selected_count={summary.deep_selected_count}",
        f"rejected_candidate_count={summary.rejected_candidate_count}", f"clean_selected_count={summary.clean_selected_count}",
        f"fallback_selected_count={summary.fallback_selected_count}", f"full_depth_count={summary.full_depth_count}",
        f"standard_depth_count={summary.standard_depth_count}", f"fallback_limited_depth_count={summary.fallback_limited_depth_count}",
        f"watch_only_count={summary.watch_only_count}", f"alert_eligible_candidate_count={summary.alert_eligible_candidate_count}",
        f"top_symbol={summary.top_symbol}", f"write_failed_count={summary.write_failed_count}", f"output_path={summary.output_path}",
        f"rejected_path={summary.rejected_path}", f"summary_path={summary.summary_path}", f"selection_desk_path={summary.selection_desk_path}",
        f"max_deep_selected={L17_MAX_DEEP_SELECTED}", f"full_depth_limit={L17_FULL_DEPTH_LIMIT}",
        "collects_ohlc=false", "collects_ticks=false", "collects_indicators=false", "collects_liquidity=false", "all_symbol_scan=false",
        "broker_polling=false", "private_ohlc_cache=false", "meaning=deep_evidence_selection_split_only_not_evidence_collection_not_trade_permission",
        "deep_evidence_runtime=false", "trade_permission=false", "entry_signal=false", "execution=false", f"generated_utc={utc_stamp()}", f"generated_unix={unix_time()}", "",
    ])


def _selection_text(selected: List[Dict[str, str]], rejected: List[Dict[str, str]], summary: L17PublishSummary) -> str:
    lines = [
        "L17 DEEP EVIDENCE SELECTION SPLIT", "----------------------------------", f"status={summary.status}", f"reason={summary.reason}",
        f"source_l16_status={summary.source_l16_status}", f"source_l16_hold_state={summary.source_l16_hold_state}",
        f"visible_candidate_count={summary.visible_candidate_count}", f"deep_selected_count={summary.deep_selected_count}",
        f"clean_selected_count={summary.clean_selected_count}", f"fallback_selected_count={summary.fallback_selected_count}",
        "collects_ohlc=false", "collects_ticks=false", "collects_indicators=false", "collects_liquidity=false", "all_symbol_scan=false", "",
        "SELECTED FOR FUTURE DEEP EVIDENCE",
    ]
    for row in selected:
        lines.append(
            f"#{row['deep_evidence_rank']} {row['symbol']} l16_slot={row['source_l16_display_rank']} tier={row['source_l16_selection_tier']} "
            f"clean={row['source_l16_clean_diversified']} fallback={row['source_l16_fallback_fill_used']} depth={row['depth_assignment']} budget={row['evidence_budget_class']} reason={row['selection_reason']}"
        )
    lines.append("")
    lines.append("VISIBLE BUT NOT DEEP-SELECTED")
    for row in rejected:
        lines.append(f"slot={row['visible_rank']} {row['symbol']} tier={row['source_l16_selection_tier']} reason={row['reject_reason']}")
    lines.extend(["", "meaning=deep_evidence_selection_split_only_not_trade_permission", "deep_evidence_runtime=false", "trade_permission=false", "entry_signal=false", "execution=false", ""])
    return "\n".join(lines)


def publish_l17_deep_evidence_selection_split(outbox_root: Path) -> L17PublishSummary:
    l16 = outbox_root / "Layers" / "Layer_16_Global_Top10_Builder"
    layer = outbox_root / "Layers" / L17_LAYER_FOLDER
    visible = _global_dir(outbox_root)
    for folder in (layer, visible):
        folder.mkdir(parents=True, exist_ok=True)
    try:
        summary_kv = _kv(l16 / "l16_global_top10_summary.txt")
        l16_status = summary_kv.get("status", "not_available")
        rows, source_path, source_kind = _source_rows(outbox_root)
        if not rows:
            return L17PublishSummary("pending", "missing_l16_visible_candidates")
        if source_kind == "l16_layer_visible_held_global_top10" and l16_status not in {"accepted", "degraded", "write_degraded"}:
            return L17PublishSummary("pending", "l16_not_accepted_status=" + l16_status)
        selected, rejected = _build_split(rows, source_kind, summary_kv)
        failed: List[Path] = []
        selected_text = _csv_text(selected, SELECTED_FIELDS)
        rejected_text = _csv_text(rejected, REJECTED_FIELDS)
        depth_text = _csv_text(_depth_summary(selected, rejected), DEPTH_SUMMARY_FIELDS)
        deep_count = len(selected)
        clean_selected = sum(1 for r in selected if r.get("source_l16_clean_diversified") == "true")
        fallback_selected = sum(1 for r in selected if r.get("source_l16_fallback_fill_used") == "true" or r.get("source_l16_selection_tier", "").startswith("FALLBACK"))
        full_count = sum(1 for r in selected if r.get("depth_assignment") == "full_deep_pack_request")
        standard_count = sum(1 for r in selected if r.get("depth_assignment") == "standard_deep_pack_request")
        fallback_limited_count = sum(1 for r in selected if r.get("depth_assignment") == "fallback_limited_review_request")
        watch_count = len(rejected)
        alert_count = sum(1 for r in selected if r.get("alert_eligible_candidate") == "true")
        status = "accepted" if deep_count > 0 else "degraded"
        reason = "l17_deep_evidence_budget_split_published" if status == "accepted" else "l17_published_without_deep_selected_candidates"
        if fallback_selected > 0:
            reason += ";fallback_rows_selected_only_after_clean_budget_gap"
        if source_kind != "l16_layer_visible_held_global_top10":
            reason += ";used_selection_desk_visible_source_degraded"
        summary = L17PublishSummary(
            status=status, reason=reason, visible_candidate_count=len(rows), deep_selected_count=deep_count,
            rejected_candidate_count=len(rejected), clean_selected_count=clean_selected, fallback_selected_count=fallback_selected,
            full_depth_count=full_count, standard_depth_count=standard_count, fallback_limited_depth_count=fallback_limited_count,
            watch_only_count=watch_count, alert_eligible_candidate_count=alert_count, source_path=str(source_path), source_l16_status=l16_status,
            source_l16_hold_state=summary_kv.get("l16_hold_state", "not_available"), source_l16_visible_surface_state=summary_kv.get("l16_visible_surface_state", "not_available"),
            top_symbol=selected[0]["symbol"] if selected else "not_available", output_path=str(layer / "l17_deep_evidence_selected.csv"),
            rejected_path=str(layer / "l17_deep_evidence_rejected.csv"), summary_path=str(layer / "l17_deep_evidence_summary.txt"),
            selection_desk_path=str(visible / "Deep Evidence Split.txt"),
        )
        summary_text = _summary_text(summary)
        manifest_text = _manifest(selected_text + rejected_text + depth_text + summary_text, summary)
        _write(layer / "l17_deep_evidence_selected.csv", selected_text, failed)
        _write(layer / "l17_deep_evidence_rejected.csv", rejected_text, failed)
        _write(layer / "l17_depth_assignment_summary.csv", depth_text, failed)
        _write(layer / "l17_deep_evidence_summary.txt", summary_text, failed)
        _write(layer / "l17_deep_evidence.manifest", manifest_text, failed)
        # Backward-compatible aliases for earlier L17 scaffold readers.
        _write(layer / "l17_deep_evidence_selection_split.csv", selected_text, failed)
        _write(layer / "l17_deep_evidence_selection_split_summary.txt", summary_text, failed)
        _write(layer / "l17_deep_evidence_selection_split.manifest", manifest_text, failed)
        _write(visible / "current_deep_evidence_split.csv", selected_text, failed)
        _write(visible / "current_deep_evidence_split_manifest.txt", manifest_text, failed)
        _write(visible / "Deep Evidence Split.txt", _selection_text(selected, rejected, summary), failed)
        if failed:
            return L17PublishSummary(**{**summary.__dict__, "status": "write_degraded", "reason": "one_or_more_l17_outputs_failed", "write_failed_count": len(failed)})
        return summary
    except Exception as exc:
        return L17PublishSummary("exception", f"{type(exc).__name__}: {exc}")
