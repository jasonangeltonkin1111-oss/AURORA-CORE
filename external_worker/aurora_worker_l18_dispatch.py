from __future__ import annotations

from pathlib import Path
import time

from aurora_worker_io import WorkerPaths, atomic_write_text, payload_checksum, read_text, unix_time, utc_stamp
from aurora_worker_l18 import DISPLAY_BARS, L18PublishSummary, publish_l18_selected_raw_ohlc_bar_pack
from aurora_worker_l19_dispatch import run_l19_after_l18


def _display_profile() -> str:
    return ",".join(f"{tf}={bars}" for tf, bars in DISPLAY_BARS.items())


def _tf_counter_lines(summary: L18PublishSummary) -> list[str]:
    lines: list[str] = []
    for tf in DISPLAY_BARS:
        prefix = tf.lower()
        lines.extend([
            f"l18_{prefix}_completed_symbols={getattr(summary, prefix + '_completed_symbols')}",
            f"l18_{prefix}_partial_symbols={getattr(summary, prefix + '_partial_symbols')}",
            f"l18_{prefix}_missing_symbols={getattr(summary, prefix + '_missing_symbols')}",
        ])
    return lines


def l18_result_lines(summary: L18PublishSummary, duration_ms: int) -> str:
    lines = [
        f"l18_selected_raw_ohlc_status={summary.status}",
        f"l18_selected_raw_ohlc_reason={summary.reason}",
        f"l18_selected_raw_ohlc_duration_ms={duration_ms}",
        f"l18_display_profile={_display_profile()}",
        f"l18_selected_dossiers_seen={summary.selected_dossiers_seen}",
        f"l18_selected_route_dossiers_seen={summary.selected_route_dossiers_seen}",
        f"l18_selected_route_dossiers_decorated={summary.selected_route_dossiers_decorated}",
        f"l18_selected_unique_symbols_seen={summary.selected_unique_symbols_seen}",
        f"l18_selected_duplicate_route_copies={summary.selected_duplicate_route_copies}",
        f"l18_selected_dossiers_decorated={summary.selected_dossiers_decorated}",
        f"l18_selected_dossiers_missing_symbol={summary.selected_dossiers_missing_symbol}",
        f"l18_source_files_expected={summary.source_files_expected}",
        f"l18_source_files_found={summary.source_files_found}",
        f"l18_source_files_missing={summary.source_files_missing}",
        f"l18_source_files_partial={summary.source_files_partial}",
        f"l18_source_decode_errors={summary.source_decode_errors}",
        f"l18_rows_printed_to_dossiers={summary.rows_printed_to_dossiers}",
        f"l18_write_failed_count={summary.write_failed_count}",
        f"l18_latest_bar_age_max_seconds={summary.latest_bar_age_max_seconds}",
        f"l18_freshness_fresh_count={summary.freshness_fresh_count}",
        f"l18_freshness_aging_count={summary.freshness_aging_count}",
        f"l18_freshness_stale_count={summary.freshness_stale_count}",
        f"l18_freshness_unknown_count={summary.freshness_unknown_count}",
        f"l18_freshness_status={summary.freshness_status}",
        f"l18_freshness_policy={summary.freshness_policy}",
    ]
    lines.extend(_tf_counter_lines(summary))
    lines.extend([
        f"l18_status_path={summary.status_path}",
        f"l18_board_path={summary.board_path}",
        f"l18_layer_folder={summary.layer_folder}",
        "l18_next_layer=L19_candle_geometry_and_structure_dispatch_owned",
        "l18_scope=canonical_selection_shortcut_dossiers_only",
        "l18_source_owner=Runtime_1_Shared_OHLC_Raw_Storage_Owner",
        "l18_source_policy=read_existing_shared_ohlc_seed_files_only",
        "l18_copyrates_calls=0",
        "l18_private_ohlc_cache=false",
        "l18_base_dossiers_touched=false",
        "l18_all_symbol_scan=false",
        "l18_collects_ohlc=false",
        "l18_meaning=selected_raw_ohlc_display_only_not_signal_not_trade_permission",
        "l18_trade_permission=false",
        "l18_entry_signal=false",
        "l18_execution=false",
        "",
    ])
    return "\n".join(lines)


def _replace_or_append_l18_block(result_text: str, lines: str) -> str:
    marker = "l18_selected_raw_ohlc_status="
    normalized = result_text.replace("\r\n", "\n")
    if marker not in normalized:
        return normalized.rstrip() + "\n" + lines
    before, _sep, tail = normalized.partition(marker)
    kept_tail = []
    for line in tail.splitlines():
        if line.startswith("l18_"):
            continue
        kept_tail.append(line)
    suffix = "\n".join(kept_tail).strip()
    return before.rstrip() + "\n" + lines + (suffix + "\n" if suffix else "")


def run_l18_after_l17(root: Path) -> L18PublishSummary:
    paths = WorkerPaths.from_root(root)
    paths.ensure()
    start_ns = time.perf_counter_ns()
    summary = publish_l18_selected_raw_ohlc_bar_pack(root)
    duration_ms = max(0, (time.perf_counter_ns() - start_ns) // 1_000_000)
    result_path = paths.outbox / "result_latest.txt"
    if result_path.exists():
        text = read_text(result_path)
        updated = _replace_or_append_l18_block(text, l18_result_lines(summary, duration_ms))
        atomic_write_text(result_path, updated)
        manifest_path = paths.outbox / "result_latest.manifest"
        manifest = "\n".join([
            "schema_name=aurora_worker_result_manifest",
            "schema_version=19",
            "worker_l18_append_status=appended_by_l18_dispatch",
            "worker_l19_dispatch_policy=l18_dispatch_runs_l19_after_l18",
            f"l18_status={summary.status}",
            f"l18_display_profile={_display_profile()}",
            f"l18_selected_dossiers_decorated={summary.selected_dossiers_decorated}",
            f"l18_source_files_found={summary.source_files_found}",
            f"l18_source_files_expected={summary.source_files_expected}",
            f"l18_selected_unique_symbols_seen={summary.selected_unique_symbols_seen}",
            f"l18_freshness_status={summary.freshness_status}",
            f"l18_status_path={summary.status_path}",
            f"l18_board_path={summary.board_path}",
            f"result_size={len(updated.encode('utf-8'))}",
            f"payload_checksum={payload_checksum(updated.splitlines())}",
            "authority=calculation_support_only",
            "l18_copyrates_calls=0",
            "l18_private_ohlc_cache=false",
            "l18_base_dossiers_touched=false",
            "selection_runtime=false",
            "trade_permission=false",
            "entry_signal=false",
            "execution=false",
            f"generated_utc={utc_stamp()}",
            f"generated_unix={unix_time()}",
            "",
        ])
        atomic_write_text(manifest_path, manifest)
    run_l19_after_l18(root)
    return summary
