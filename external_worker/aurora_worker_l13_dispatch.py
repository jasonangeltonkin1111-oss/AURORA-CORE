from __future__ import annotations

from pathlib import Path
import time

from aurora_worker_io import WorkerPaths, atomic_write_text, payload_checksum, read_text, unix_time, utc_stamp
from aurora_worker_l13 import L13PublishSummary, publish_l13_dynamic_ranking_group_selection


def l13_result_lines(summary: L13PublishSummary, duration_ms: int) -> str:
    return "\n".join([
        f"l13_dynamic_group_selection_status={summary.status}",
        f"l13_dynamic_group_selection_reason={summary.reason}",
        f"l13_dynamic_group_selection_duration_ms={duration_ms}",
        f"l13_valid_group_count={summary.valid_group_count}",
        f"l13_selected_ranking_group_count={summary.selected_ranking_group_count}",
        f"l13_rejected_ranking_group_count={summary.rejected_ranking_group_count}",
        f"l13_fallback_used={'true' if summary.fallback_used else 'false'}",
        f"l13_fallback_reason={summary.fallback_reason}",
        f"l13_selection_quality_tier={summary.selection_quality_tier}",
        f"l13_market_condition_note={summary.market_condition_note}",
        f"l13_top_selected_group={summary.top_selected_group}",
        f"l13_write_failed_count={summary.write_failed_count}",
        f"l13_selected_path={summary.selected_path}",
        f"l13_summary_path={summary.summary_path}",
        f"l13_selection_desk_selected_path={summary.selection_desk_selected_path}",
        "l13_meaning=ranking_group_selected_for_candidate_sourcing_attention_only",
        "l13_selection_runtime=false",
        "l13_trade_permission=false",
        "l13_entry_signal=false",
        "l13_execution=false",
        "",
    ])


def _replace_or_append_l13_block(result_text: str, lines: str) -> str:
    marker = "l13_dynamic_group_selection_status="
    normalized = result_text.replace("\r\n", "\n")
    if marker not in normalized:
        return normalized.rstrip() + "\n" + lines
    before, _sep, tail = normalized.partition(marker)
    kept_tail = []
    for line in tail.splitlines():
        if line.startswith("l13_"):
            continue
        kept_tail.append(line)
    suffix = "\n".join(kept_tail).strip()
    return before.rstrip() + "\n" + lines + (suffix + "\n" if suffix else "")


def run_l13_after_l12(root: Path) -> L13PublishSummary:
    paths = WorkerPaths.from_root(root)
    paths.ensure()
    start_ns = time.perf_counter_ns()
    summary = publish_l13_dynamic_ranking_group_selection(paths.outbox)
    duration_ms = max(0, (time.perf_counter_ns() - start_ns) // 1_000_000)
    result_path = paths.outbox / "result_latest.txt"
    if result_path.exists():
        text = read_text(result_path)
        updated = _replace_or_append_l13_block(text, l13_result_lines(summary, duration_ms))
        atomic_write_text(result_path, updated)
        manifest_path = paths.outbox / "result_latest.manifest"
        manifest = "\n".join([
            "schema_name=aurora_worker_result_manifest",
            "schema_version=9",
            "worker_l13_append_status=appended_by_l13_dispatch",
            f"result_size={len(updated.encode('utf-8'))}",
            f"payload_checksum={payload_checksum(updated.splitlines())}",
            "authority=calculation_support_only",
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
