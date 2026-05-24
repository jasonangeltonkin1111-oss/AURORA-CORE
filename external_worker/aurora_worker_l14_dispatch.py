from __future__ import annotations

from pathlib import Path
import time

from aurora_worker_io import WorkerPaths, atomic_write_text, payload_checksum, read_text, unix_time, utc_stamp
from aurora_worker_l14 import L14PublishSummary, publish_l14_ranking_group_leader_candidate_pool


def l14_result_lines(summary: L14PublishSummary, duration_ms: int) -> str:
    return "\n".join([
        f"l14_candidate_pool_status={summary.status}",
        f"l14_candidate_pool_reason={summary.reason}",
        f"l14_candidate_pool_duration_ms={duration_ms}",
        f"l14_selected_group_count={summary.selected_group_count}",
        f"l14_candidate_pool_size={summary.candidate_pool_size}",
        f"l14_leader_candidate_count={summary.leader_candidate_count}",
        f"l14_backup_candidate_count={summary.backup_candidate_count}",
        f"l14_review_candidate_count={summary.review_candidate_count}",
        f"l14_thin_fallback_candidate_count={summary.thin_fallback_candidate_count}",
        f"l14_top_candidate={summary.top_candidate}",
        f"l14_write_failed_count={summary.write_failed_count}",
        f"l14_candidate_pool_path={summary.candidate_pool_path}",
        f"l14_summary_path={summary.summary_path}",
        f"l14_selection_desk_candidate_pool_path={summary.selection_desk_candidate_pool_path}",
        "l14_meaning=raw_candidate_pool_only_not_diversified_not_global_top10",
        "l14_candidate_pool_runtime=false",
        "l14_trade_permission=false",
        "l14_entry_signal=false",
        "l14_execution=false",
        "",
    ])


def _replace_or_append_l14_block(result_text: str, lines: str) -> str:
    marker = "l14_candidate_pool_status="
    normalized = result_text.replace("\r\n", "\n")
    if marker not in normalized:
        return normalized.rstrip() + "\n" + lines
    before, _sep, tail = normalized.partition(marker)
    kept_tail = []
    for line in tail.splitlines():
        if line.startswith("l14_"):
            continue
        kept_tail.append(line)
    suffix = "\n".join(kept_tail).strip()
    return before.rstrip() + "\n" + lines + (suffix + "\n" if suffix else "")


def run_l14_after_l13(root: Path) -> L14PublishSummary:
    paths = WorkerPaths.from_root(root)
    paths.ensure()
    start_ns = time.perf_counter_ns()
    summary = publish_l14_ranking_group_leader_candidate_pool(paths.outbox)
    duration_ms = max(0, (time.perf_counter_ns() - start_ns) // 1_000_000)
    result_path = paths.outbox / "result_latest.txt"
    if result_path.exists():
        text = read_text(result_path)
        updated = _replace_or_append_l14_block(text, l14_result_lines(summary, duration_ms))
        atomic_write_text(result_path, updated)
        manifest_path = paths.outbox / "result_latest.manifest"
        manifest = "\n".join([
            "schema_name=aurora_worker_result_manifest",
            "schema_version=10",
            "worker_l14_append_status=appended_by_l14_dispatch",
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
