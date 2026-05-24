from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List
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

SPLIT_FIELDS = [
    "deep_evidence_rank", "symbol", "canonical_symbol", "global_top10_rank", "ranking_group", "asset_class", "market_group", "market_segment",
    "l16_primary_score", "max_corr_to_selected", "correlation_state", "correlation_clean_flag", "leader_or_backup", "candidate_source",
    "deep_evidence_selected", "visible_only", "alert_eligible_candidate", "depth_assignment", "ohlc_depth", "tick_depth", "indicator_depth", "liquidity_depth",
    "selection_reason", "selection_source", "evidence_collection_scope", "heavy_data_allowed", "meaning", "deep_evidence_runtime", "trade_permission", "entry_signal", "execution", "generated_utc",
]

SUMMARY_FIELDS = [
    "depth_assignment", "count", "meaning", "generated_utc",
]


@dataclass(frozen=True)
class L17PublishSummary:
    status: str
    reason: str
    visible_candidate_count: int = 0
    deep_selected_count: int = 0
    full_depth_count: int = 0
    standard_depth_count: int = 0
    watch_only_count: int = 0
    alert_eligible_candidate_count: int = 0
    write_failed_count: int = 0
    top_symbol: str = "not_available"
    output_path: str = "not_available"
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


def _assignment(rank: int, row: Dict[str, str]) -> Dict[str, str]:
    corr_clean = _text(row, "correlation_clean_flag", "false").lower() == "true"
    corr_state = _text(row, "correlation_state")
    degraded = (not corr_clean) or corr_state.startswith("DEGRADED")
    selected = rank <= L17_MAX_DEEP_SELECTED
    if rank <= L17_FULL_DEPTH_LIMIT and selected:
        depth = "full_deep_pack_request"
        ohlc = "selected_deep"
        tick = "selected_deep"
        indicator = "selected_deep"
        liquidity = "selected_deep_proxy_only"
        reason = "top_l16_rank_full_depth_budget"
    elif selected:
        depth = "standard_deep_pack_request"
        ohlc = "selected_standard"
        tick = "deferred_unless_needed"
        indicator = "selected_standard"
        liquidity = "deferred_proxy_only"
        reason = "top_l16_rank_standard_depth_budget"
    else:
        depth = "visible_watch_only_no_expensive_collection"
        ohlc = "watch_light_or_none"
        tick = "none"
        indicator = "none"
        liquidity = "none"
        reason = "visible_l16_candidate_but_outside_l17_deep_budget"
    if degraded and selected:
        reason += ";correlation_or_source_degraded_keep_truth_label"
    alert_eligible = "true" if selected and rank <= L17_FULL_DEPTH_LIMIT and not degraded else "false"
    return {
        "deep_evidence_selected": "true" if selected else "false",
        "visible_only": "true",
        "alert_eligible_candidate": alert_eligible,
        "depth_assignment": depth,
        "ohlc_depth": ohlc,
        "tick_depth": tick,
        "indicator_depth": indicator,
        "liquidity_depth": liquidity,
        "selection_reason": reason,
        "evidence_collection_scope": "selected_visible_candidates_only_no_all_symbol_scan",
        "heavy_data_allowed": "true" if selected else "false",
    }


def _build_split(rows: List[Dict[str, str]]) -> List[Dict[str, str]]:
    ordered = sorted(rows, key=lambda r: (_int(r.get("global_top10_rank"), 999), -_num(r.get("l16_primary_score")), _text(r, "symbol")))
    out: List[Dict[str, str]] = []
    for idx, row in enumerate(ordered, start=1):
        rank = _int(row.get("global_top10_rank"), idx)
        assigned = _assignment(rank, row)
        out.append({
            "deep_evidence_rank": str(idx),
            "symbol": _text(row, "symbol"),
            "canonical_symbol": _text(row, "canonical_symbol", _text(row, "symbol")),
            "global_top10_rank": str(rank),
            "ranking_group": _text(row, "ranking_group"),
            "asset_class": _text(row, "asset_class"),
            "market_group": _text(row, "market_group"),
            "market_segment": _text(row, "market_segment"),
            "l16_primary_score": _text(row, "l16_primary_score"),
            "max_corr_to_selected": _text(row, "max_corr_to_selected"),
            "correlation_state": _text(row, "correlation_state"),
            "correlation_clean_flag": _text(row, "correlation_clean_flag", "false"),
            "leader_or_backup": _text(row, "leader_or_backup"),
            "candidate_source": _text(row, "candidate_source"),
            **assigned,
            "selection_source": "l16_global_top10_visible_basket",
            "meaning": "deep_evidence_selection_split_only_not_evidence_collection_not_trade_permission",
            "deep_evidence_runtime": "false",
            "trade_permission": "false",
            "entry_signal": "false",
            "execution": "false",
            "generated_utc": utc_stamp(),
        })
    return out


def _depth_summary(rows: List[Dict[str, str]]) -> List[Dict[str, str]]:
    counts: Dict[str, int] = {}
    for row in rows:
        key = row.get("depth_assignment", "not_available")
        counts[key] = counts.get(key, 0) + 1
    return [{"depth_assignment": key, "count": str(count), "meaning": "attention_budget_split_not_trade_permission", "generated_utc": utc_stamp()} for key, count in sorted(counts.items())]


def _manifest(payload: str, selected_count: int, visible_count: int) -> str:
    return "\n".join([
        "schema_name=l17_deep_evidence_selection_split_manifest", "schema_version=1", "layer_id=17", "layer_name=Layer 17 - Deep Evidence Selection Split",
        f"owner={L17_OWNER}", f"authority={L17_AUTHORITY}", f"visible_candidate_count={visible_count}", f"deep_selected_count={selected_count}",
        f"max_deep_selected={L17_MAX_DEEP_SELECTED}", "input_source=L16_global_top10_visible_basket_only",
        "collects_ohlc=false", "collects_ticks=false", "collects_indicators=false", "collects_liquidity=false", "all_symbol_scan=false",
        f"payload_checksum={payload_checksum(payload.splitlines())}", "deep_evidence_runtime=false", "trade_permission=false", "entry_signal=false", "execution=false",
        f"generated_utc={utc_stamp()}", f"generated_unix={unix_time()}", "",
    ])


def _summary_text(summary: L17PublishSummary) -> str:
    return "\n".join([
        f"schema_name={L17_SCHEMA_NAME}", "schema_version=1", f"owner_name={L17_OWNER}", "layer_id=17", "layer_name=Layer 17 - Deep Evidence Selection Split",
        f"status={summary.status}", f"reason={summary.reason}", "input_source=L16_global_top10_visible_basket_only",
        f"visible_candidate_count={summary.visible_candidate_count}", f"deep_selected_count={summary.deep_selected_count}",
        f"full_depth_count={summary.full_depth_count}", f"standard_depth_count={summary.standard_depth_count}", f"watch_only_count={summary.watch_only_count}",
        f"alert_eligible_candidate_count={summary.alert_eligible_candidate_count}", f"top_symbol={summary.top_symbol}", f"write_failed_count={summary.write_failed_count}",
        f"output_path={summary.output_path}", f"summary_path={summary.summary_path}", f"selection_desk_path={summary.selection_desk_path}",
        f"max_deep_selected={L17_MAX_DEEP_SELECTED}", "collects_ohlc=false", "collects_ticks=false", "collects_indicators=false", "collects_liquidity=false", "all_symbol_scan=false",
        "meaning=deep_evidence_selection_split_only_not_evidence_collection_not_trade_permission", "deep_evidence_runtime=false", "trade_permission=false", "entry_signal=false", "execution=false",
        f"generated_utc={utc_stamp()}", f"generated_unix={unix_time()}", "",
    ])


def _selection_text(rows: List[Dict[str, str]], summary: L17PublishSummary) -> str:
    lines = [
        "L17 DEEP EVIDENCE SELECTION SPLIT",
        "----------------------------------",
        f"status={summary.status}",
        f"reason={summary.reason}",
        f"visible_candidate_count={summary.visible_candidate_count}",
        f"deep_selected_count={summary.deep_selected_count}",
        f"full_depth_count={summary.full_depth_count}",
        f"standard_depth_count={summary.standard_depth_count}",
        f"watch_only_count={summary.watch_only_count}",
        "collects_ohlc=false",
        "collects_ticks=false",
        "collects_indicators=false",
        "collects_liquidity=false",
        "all_symbol_scan=false",
        "",
        "SPLIT",
    ]
    for row in rows:
        lines.append(
            f"#{row['deep_evidence_rank']} {row['symbol']} l16_rank={row['global_top10_rank']} depth={row['depth_assignment']} "
            f"deep_selected={row['deep_evidence_selected']} alert_candidate={row['alert_eligible_candidate']} reason={row['selection_reason']}"
        )
    lines.extend(["", "meaning=deep_evidence_selection_split_only_not_trade_permission", "deep_evidence_runtime=false", "trade_permission=false", "entry_signal=false", "execution=false", ""])
    return "\n".join(lines)


def publish_l17_deep_evidence_selection_split(outbox_root: Path) -> L17PublishSummary:
    l16 = outbox_root / "Layers" / "Layer_16_Global_Top10_Builder"
    needed = [l16 / "l16_global_top10.csv", l16 / "l16_global_top10_summary.txt"]
    missing = [str(p) for p in needed if not p.exists()]
    if missing:
        return L17PublishSummary("pending", "missing_required_l17_source: " + ";".join(missing))
    try:
        l16_status = _kv(l16 / "l16_global_top10_summary.txt").get("status", "pending")
        if l16_status not in {"accepted", "degraded", "write_degraded"}:
            return L17PublishSummary("pending", "l16_not_accepted_status=" + l16_status)
        source_rows = _csv(l16 / "l16_global_top10.csv")
        if not source_rows:
            return L17PublishSummary("pending", "no_l16_visible_candidates")
        split_rows = _build_split(source_rows)
        layer = outbox_root / "Layers" / L17_LAYER_FOLDER
        visible = _global_dir(outbox_root)
        for folder in (layer, visible):
            folder.mkdir(parents=True, exist_ok=True)
        failed: List[Path] = []
        split_text = _csv_text(split_rows, SPLIT_FIELDS)
        depth_text = _csv_text(_depth_summary(split_rows), SUMMARY_FIELDS)
        deep_count = sum(1 for r in split_rows if r.get("deep_evidence_selected") == "true")
        full_count = sum(1 for r in split_rows if r.get("depth_assignment") == "full_deep_pack_request")
        standard_count = sum(1 for r in split_rows if r.get("depth_assignment") == "standard_deep_pack_request")
        watch_count = sum(1 for r in split_rows if r.get("depth_assignment") == "visible_watch_only_no_expensive_collection")
        alert_count = sum(1 for r in split_rows if r.get("alert_eligible_candidate") == "true")
        status = "accepted" if deep_count > 0 else "degraded"
        reason = "l17_deep_evidence_split_published" if status == "accepted" else "l17_published_without_deep_selected_candidates"
        summary = L17PublishSummary(status=status, reason=reason, visible_candidate_count=len(split_rows), deep_selected_count=deep_count, full_depth_count=full_count, standard_depth_count=standard_count, watch_only_count=watch_count, alert_eligible_candidate_count=alert_count, top_symbol=split_rows[0]["symbol"] if split_rows else "not_available", output_path=str(layer / "l17_deep_evidence_selection_split.csv"), summary_path=str(layer / "l17_deep_evidence_selection_split_summary.txt"), selection_desk_path=str(visible / "Deep Evidence Split.txt"))
        summary_text = _summary_text(summary)
        manifest_text = _manifest(split_text + depth_text + summary_text, deep_count, len(split_rows))
        _write(layer / "l17_deep_evidence_selection_split.csv", split_text, failed)
        _write(layer / "l17_depth_assignment_summary.csv", depth_text, failed)
        _write(layer / "l17_deep_evidence_selection_split_summary.txt", summary_text, failed)
        _write(layer / "l17_deep_evidence_selection_split.manifest", manifest_text, failed)
        _write(visible / "current_deep_evidence_split.csv", split_text, failed)
        _write(visible / "current_deep_evidence_split_manifest.txt", manifest_text, failed)
        _write(visible / "Deep Evidence Split.txt", _selection_text(split_rows, summary), failed)
        if failed:
            return L17PublishSummary(status="write_degraded", reason="one_or_more_l17_outputs_failed", visible_candidate_count=summary.visible_candidate_count, deep_selected_count=summary.deep_selected_count, full_depth_count=summary.full_depth_count, standard_depth_count=summary.standard_depth_count, watch_only_count=summary.watch_only_count, alert_eligible_candidate_count=summary.alert_eligible_candidate_count, write_failed_count=len(failed), top_symbol=summary.top_symbol, output_path=summary.output_path, summary_path=summary.summary_path, selection_desk_path=summary.selection_desk_path)
        return summary
    except Exception as exc:
        return L17PublishSummary("exception", f"{type(exc).__name__}: {exc}")
