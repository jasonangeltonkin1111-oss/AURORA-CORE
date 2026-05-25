from __future__ import annotations

from pathlib import Path
import time

from aurora_worker_io import WorkerPaths, atomic_write_text, payload_checksum, read_text, unix_time, utc_stamp
from aurora_worker_l15 import L15PublishSummary, publish_l15_correlation_diversity_selection


def l15_result_lines(summary: L15PublishSummary, duration_ms: int) -> str:
    return "\n".join([
        f"l15_correlation_diversity_status={summary.status}",
        f"l15_correlation_diversity_reason={summary.reason}",
        f"l15_correlation_diversity_duration_ms={duration_ms}",
        f"l15_candidate_input_count={summary.candidate_input_count}",
        f"l15_candidate_pool_size={summary.candidate_pool_size}",
        f"l15_candidate_scored_count={summary.candidate_scored_count}",
        f"l15_candidate_pool_capped={summary.candidate_pool_capped}",
        f"l15_candidate_pool_cap={summary.candidate_pool_cap}",
        f"l15_pairwise_pair_count={summary.pairwise_pair_count}",
        f"l15_corr_pair_count={summary.corr_pair_count}",
        f"l15_high_corr_pair_count={summary.high_corr_pair_count}",
        f"l15_corr_unavailable_count={summary.corr_unavailable_count}",
        f"l15_group_count={summary.group_count}",
        f"l15_top_diversity_candidate={summary.top_diversity_candidate}",
        f"l15_max_pair_corr_abs={summary.max_pair_corr_abs}",
        f"l15_ohlc_scan_file_limit={summary.ohlc_scan_file_limit}",
        f"l15_ohlc_scan_file_count={summary.ohlc_scan_file_count}",
        f"l15_write_failed_count={summary.write_failed_count}",
        f"l15_output_path={summary.output_path}",
        f"l15_summary_path={summary.summary_path}",
        f"l15_selection_desk_summary_path={summary.selection_desk_summary_path}",
        f"l15_max_allowed_pairwise_correlation_abs={summary.max_allowed_pairwise_correlation_abs}",
        "l15_threshold_status=untested_default_not_holy_law",
        f"l15_threshold_source={summary.threshold_source}",
        "l15_meaning=correlation_diversity_scoring_only_not_global_top10",
        "l15_selection_runtime=false",
        "l15_trade_permission=false",
        "l15_entry_signal=false",
        "l15_execution=false",
        "",
    ])


def _replace_or_append_l15_block(result_text: str, lines: str) -> str:
    marker = "l15_correlation_diversity_status="
    normalized = result_text.replace("\r\n", "\n")
    if marker not in normalized:
        return normalized.rstrip() + "\n" + lines
    before, _sep, tail = normalized.partition(marker)
    kept_tail = []
    for line in tail.splitlines():
        if line.startswith("l15_"):
            continue
        kept_tail.append(line)
    suffix = "\n".join(kept_tail).strip()
    return before.rstrip() + "\n" + lines + (suffix + "\n" if suffix else "")


def run_l15_after_l14(root: Path) -> L15PublishSummary:
    paths = WorkerPaths.from_root(root)
    paths.ensure()
    start_ns = time.perf_counter_ns()
    summary = publish_l15_correlation_diversity_selection(paths.outbox)
    duration_ms = max(0, (time.perf_counter_ns() - start_ns) // 1_000_000)
    result_path = paths.outbox / "result_latest.txt"
    if result_path.exists():
        text = read_text(result_path)
        updated = _replace_or_append_l15_block(text, l15_result_lines(summary, duration_ms))
        atomic_write_text(result_path, updated)
        manifest_path = paths.outbox / "result_latest.manifest"
        manifest = "\n".join([
            "schema_name=aurora_worker_result_manifest",
            "schema_version=12",
            "worker_l15_append_status=appended_by_l15_dispatch",
            f"result_size={len(updated.encode('utf-8'))}",
            f"payload_checksum={payload_checksum(updated.splitlines())}",
            "authority=calculation_support_only",
            "candidate_pool_runtime=false",
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
