from __future__ import annotations

from pathlib import Path
import time

from aurora_worker_io import WorkerPaths, atomic_write_text, payload_checksum, read_text, unix_time, utc_stamp
from aurora_worker_l17 import L17PublishSummary, publish_l17_deep_evidence_selection_split


def l17_result_lines(summary: L17PublishSummary, duration_ms: int) -> str:
    return "\n".join([
        f"l17_deep_evidence_selection_status={summary.status}",
        f"l17_deep_evidence_selection_reason={summary.reason}",
        f"l17_deep_evidence_selection_duration_ms={duration_ms}",
        f"l17_source_path={summary.source_path}",
        f"l17_source_l16_status={summary.source_l16_status}",
        f"l17_source_l16_hold_state={summary.source_l16_hold_state}",
        f"l17_source_l16_visible_surface_state={summary.source_l16_visible_surface_state}",
        f"l17_visible_candidate_count={summary.visible_candidate_count}",
        f"l17_deep_selected_count={summary.deep_selected_count}",
        f"l17_rejected_candidate_count={summary.rejected_candidate_count}",
        f"l17_clean_selected_count={summary.clean_selected_count}",
        f"l17_fallback_selected_count={summary.fallback_selected_count}",
        f"l17_full_depth_count={summary.full_depth_count}",
        f"l17_standard_depth_count={summary.standard_depth_count}",
        f"l17_fallback_limited_depth_count={summary.fallback_limited_depth_count}",
        f"l17_watch_only_count={summary.watch_only_count}",
        f"l17_alert_eligible_candidate_count={summary.alert_eligible_candidate_count}",
        f"l17_top_symbol={summary.top_symbol}",
        f"l17_write_failed_count={summary.write_failed_count}",
        f"l17_output_path={summary.output_path}",
        f"l17_rejected_path={summary.rejected_path}",
        f"l17_summary_path={summary.summary_path}",
        f"l17_selection_desk_path={summary.selection_desk_path}",
        "l17_max_deep_selected=5",
        "l17_collects_ohlc=false",
        "l17_collects_ticks=false",
        "l17_collects_indicators=false",
        "l17_collects_liquidity=false",
        "l17_all_symbol_scan=false",
        "l17_broker_polling=false",
        "l17_private_ohlc_cache=false",
        "l17_meaning=deep_evidence_selection_split_only_not_evidence_collection_not_trade_permission",
        "l17_deep_evidence_runtime=false",
        "l17_trade_permission=false",
        "l17_entry_signal=false",
        "l17_execution=false",
        "",
    ])


def _replace_or_append_l17_block(result_text: str, lines: str) -> str:
    marker = "l17_deep_evidence_selection_status="
    normalized = result_text.replace("\r\n", "\n")
    if marker not in normalized:
        return normalized.rstrip() + "\n" + lines
    before, _sep, tail = normalized.partition(marker)
    kept_tail = []
    for line in tail.splitlines():
        if line.startswith("l17_"):
            continue
        kept_tail.append(line)
    suffix = "\n".join(kept_tail).strip()
    return before.rstrip() + "\n" + lines + (suffix + "\n" if suffix else "")


def run_l17_after_l16(root: Path) -> L17PublishSummary:
    paths = WorkerPaths.from_root(root)
    paths.ensure()
    start_ns = time.perf_counter_ns()
    summary = publish_l17_deep_evidence_selection_split(paths.outbox)
    duration_ms = max(0, (time.perf_counter_ns() - start_ns) // 1_000_000)
    result_path = paths.outbox / "result_latest.txt"
    if result_path.exists():
        text = read_text(result_path)
        updated = _replace_or_append_l17_block(text, l17_result_lines(summary, duration_ms))
        atomic_write_text(result_path, updated)
        manifest_path = paths.outbox / "result_latest.manifest"
        manifest = "\n".join([
            "schema_name=aurora_worker_result_manifest",
            "schema_version=14",
            "worker_l17_append_status=appended_by_l17_dispatch",
            f"result_size={len(updated.encode('utf-8'))}",
            f"payload_checksum={payload_checksum(updated.splitlines())}",
            "authority=calculation_support_only",
            "deep_evidence_runtime=false",
            "global_top10_runtime=false",
            "selection_runtime=false",
            "trade_permission=false",
            "entry_signal=false",
            "execution=false",
            f"generated_utc={utc_stamp()}",
            f"generated_unix={unix_time()}",
            "",
        ])
        atomic_write_text(manifest_path, manifest)
    return summary
