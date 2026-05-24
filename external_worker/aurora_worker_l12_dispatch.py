from __future__ import annotations

from pathlib import Path
import time

from aurora_worker_io import WorkerPaths, atomic_write_text, payload_checksum, read_text, unix_time, utc_stamp
from aurora_worker_l12 import L12PublishSummary, publish_l12_ranking_group_heat_quality


def l12_result_lines(summary: L12PublishSummary, duration_ms: int) -> str:
    return "\n".join([
        f"l12_group_heat_quality_status={summary.status}",
        f"l12_group_heat_quality_reason={summary.reason}",
        f"l12_group_heat_quality_duration_ms={duration_ms}",
        f"l12_ranking_group_count={summary.ranking_group_count}",
        f"l12_accepted_group_count={summary.accepted_group_count}",
        f"l12_thin_group_count={summary.thin_group_count}",
        f"l12_risk_review_group_count={summary.risk_review_group_count}",
        f"l12_write_failed_count={summary.write_failed_count}",
        f"l12_top_heat_group={summary.top_heat_group}",
        f"l12_top_quality_group={summary.top_quality_group}",
        f"l12_top_strength_group={summary.top_strength_group}",
        f"l12_heat_quality_path={summary.heat_quality_path}",
        f"l12_summary_path={summary.summary_path}",
        f"l12_selection_desk_heat_index_path={summary.selection_desk_heat_index_path}",
        "l12_meaning=ranking_group_attention_quality_only",
        "l12_directional_validity=false",
        "l12_expectancy_validated=false",
        "l12_selection_runtime=false",
        "l12_trade_permission=false",
        "l12_entry_signal=false",
        "l12_execution=false",
        "",
    ])


def _replace_or_append_l12_block(result_text: str, lines: str) -> str:
    marker = "l12_group_heat_quality_status="
    normalized = result_text.replace("\r\n", "\n")
    if marker not in normalized:
        return normalized.rstrip() + "\n" + lines
    before, _sep, tail = normalized.partition(marker)
    kept_tail = []
    for line in tail.splitlines():
        if line.startswith("l12_"):
            continue
        kept_tail.append(line)
    suffix = "\n".join(kept_tail).strip()
    return before.rstrip() + "\n" + lines + (suffix + "\n" if suffix else "")


def run_l12_after_l11(root: Path) -> L12PublishSummary:
    paths = WorkerPaths.from_root(root)
    paths.ensure()
    start_ns = time.perf_counter_ns()
    summary = publish_l12_ranking_group_heat_quality(paths.outbox)
    duration_ms = max(0, (time.perf_counter_ns() - start_ns) // 1_000_000)
    result_path = paths.outbox / "result_latest.txt"
    if result_path.exists():
        text = read_text(result_path)
        updated = _replace_or_append_l12_block(text, l12_result_lines(summary, duration_ms))
        atomic_write_text(result_path, updated)
        manifest_path = paths.outbox / "result_latest.manifest"
        manifest = "\n".join([
            "schema_name=aurora_worker_result_manifest",
            "schema_version=8",
            "worker_l12_append_status=appended_by_l12_dispatch",
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
