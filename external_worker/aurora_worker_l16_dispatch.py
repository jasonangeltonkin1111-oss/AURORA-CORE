from __future__ import annotations

from pathlib import Path
import time

from aurora_worker_io import WorkerPaths, atomic_write_text, payload_checksum, read_text, unix_time, utc_stamp
from aurora_worker_l16 import L16PublishSummary, publish_l16_global_top10_builder


def l16_result_lines(summary: L16PublishSummary, duration_ms: int) -> str:
    return "\n".join([
        f"l16_global_top10_status={summary.status}",
        f"l16_global_top10_reason={summary.reason}",
        f"l16_global_top10_duration_ms={duration_ms}",
        f"l16_candidate_pool_size={summary.candidate_pool_size}",
        f"l16_l15_candidate_count={summary.l15_candidate_count}",
        f"l16_selected_count={summary.selected_count}",
        f"l16_unfilled_slots_count={summary.unfilled_slots_count}",
        f"l16_reject_count={summary.reject_count}",
        f"l16_correlation_reject_count={summary.correlation_reject_count}",
        f"l16_group_cap_reject_count={summary.group_cap_reject_count}",
        f"l16_fallback_count={summary.fallback_count}",
        f"l16_group_count={summary.group_count}",
        f"l16_top_symbol={summary.top_symbol}",
        f"l16_write_failed_count={summary.write_failed_count}",
        f"l16_output_path={summary.output_path}",
        f"l16_summary_path={summary.summary_path}",
        f"l16_selection_desk_path={summary.selection_desk_path}",
        "l16_max_allowed_pairwise_correlation_abs=0.30",
        "l16_threshold_status=untested_default_not_holy_law",
        "l16_meaning=global_top10_inspection_basket_only_not_trade_permission",
        "l16_global_top10_runtime=false",
        "l16_trade_permission=false",
        "l16_entry_signal=false",
        "l16_execution=false",
        "",
    ])


def _replace_or_append_l16_block(result_text: str, lines: str) -> str:
    marker = "l16_global_top10_status="
    normalized = result_text.replace("\r\n", "\n")
    if marker not in normalized:
        return normalized.rstrip() + "\n" + lines
    before, _sep, tail = normalized.partition(marker)
    kept_tail = []
    for line in tail.splitlines():
        if line.startswith("l16_"):
            continue
        kept_tail.append(line)
    suffix = "\n".join(kept_tail).strip()
    return before.rstrip() + "\n" + lines + (suffix + "\n" if suffix else "")


def run_l16_after_l15(root: Path) -> L16PublishSummary:
    paths = WorkerPaths.from_root(root)
    paths.ensure()
    start_ns = time.perf_counter_ns()
    summary = publish_l16_global_top10_builder(paths.outbox)
    duration_ms = max(0, (time.perf_counter_ns() - start_ns) // 1_000_000)
    result_path = paths.outbox / "result_latest.txt"
    if result_path.exists():
        text = read_text(result_path)
        updated = _replace_or_append_l16_block(text, l16_result_lines(summary, duration_ms))
        atomic_write_text(result_path, updated)
        manifest_path = paths.outbox / "result_latest.manifest"
        manifest = "\n".join([
            "schema_name=aurora_worker_result_manifest",
            "schema_version=12",
            "worker_l16_append_status=appended_by_l16_dispatch",
            f"result_size={len(updated.encode('utf-8'))}",
            f"payload_checksum={payload_checksum(updated.splitlines())}",
            "authority=calculation_support_only",
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
