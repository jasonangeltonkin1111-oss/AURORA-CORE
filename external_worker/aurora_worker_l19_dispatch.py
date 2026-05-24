from __future__ import annotations

from pathlib import Path
import time

from aurora_worker_io import WorkerPaths, atomic_write_text, payload_checksum, read_text, unix_time, utc_stamp
from aurora_worker_l19 import L19PublishSummary, publish_l19_candle_geometry_and_structure
from aurora_worker_selection_surface_cleanup import EMPTY_SELECTION_SURFACE_CLEANUP_SUMMARY, SelectionSurfaceCleanupSummary, cleanup_legacy_selection_surface_paths
from aurora_worker_selection_root_index import EMPTY_SELECTION_ROOT_INDEX_SUMMARY, SelectionRootIndexSummary, publish_selection_root_index


def l19_result_lines(summary: L19PublishSummary, duration_ms: int, cleanup: SelectionSurfaceCleanupSummary = EMPTY_SELECTION_SURFACE_CLEANUP_SUMMARY, root_index: SelectionRootIndexSummary = EMPTY_SELECTION_ROOT_INDEX_SUMMARY) -> str:
    return "\n".join([
        f"l19_candle_geometry_status={summary.status}",
        f"l19_candle_geometry_reason={summary.reason}",
        f"l19_candle_geometry_duration_ms={duration_ms}",
        f"l19_selected_dossiers_seen={summary.selected_dossiers_seen}",
        f"l19_selected_dossiers_decorated={summary.selected_dossiers_decorated}",
        f"l19_selected_dossiers_missing_symbol={summary.selected_dossiers_missing_symbol}",
        f"l19_source_files_expected={summary.source_files_expected}",
        f"l19_source_files_found={summary.source_files_found}",
        f"l19_source_files_missing={summary.source_files_missing}",
        f"l19_source_files_partial={summary.source_files_partial}",
        f"l19_source_decode_errors={summary.source_decode_errors}",
        f"l19_rows_rendered_to_dossiers={summary.rows_rendered_to_dossiers}",
        f"l19_valid_geometry_rows={summary.valid_geometry_rows}",
        f"l19_zero_range_rows={summary.zero_range_rows}",
        f"l19_invalid_geometry_rows={summary.invalid_geometry_rows}",
        f"l19_wave2_rows_tagged={summary.wave2_rows_tagged}",
        f"l19_topview_cleanup_count={summary.topview_cleanup_count}",
        f"l19_write_failed_count={summary.write_failed_count}",
        f"l19_m5_completed_symbols={summary.m5_completed_symbols}",
        f"l19_m5_partial_symbols={summary.m5_partial_symbols}",
        f"l19_m5_missing_symbols={summary.m5_missing_symbols}",
        f"l19_m15_completed_symbols={summary.m15_completed_symbols}",
        f"l19_m15_partial_symbols={summary.m15_partial_symbols}",
        f"l19_m15_missing_symbols={summary.m15_missing_symbols}",
        f"l19_h1_completed_symbols={summary.h1_completed_symbols}",
        f"l19_h1_partial_symbols={summary.h1_partial_symbols}",
        f"l19_h1_missing_symbols={summary.h1_missing_symbols}",
        f"l19_h4_completed_symbols={summary.h4_completed_symbols}",
        f"l19_h4_partial_symbols={summary.h4_partial_symbols}",
        f"l19_h4_missing_symbols={summary.h4_missing_symbols}",
        f"l19_d1_completed_symbols={summary.d1_completed_symbols}",
        f"l19_d1_partial_symbols={summary.d1_partial_symbols}",
        f"l19_d1_missing_symbols={summary.d1_missing_symbols}",
        f"l19_status_path={summary.status_path}",
        f"l19_board_path={summary.board_path}",
        f"l19_layer_folder={summary.layer_folder}",
        f"l19_final_cleanup_status={cleanup.status}",
        f"l19_final_cleanup_reason={cleanup.reason}",
        f"l19_final_cleanup_legacy_groups_removed={cleanup.legacy_groups_removed}",
        f"l19_final_cleanup_legacy_global_removed={cleanup.legacy_global_removed}",
        f"l19_final_cleanup_status_path={cleanup.status_path}",
        f"l19_root_index_status={root_index.status}",
        f"l19_root_index_reason={root_index.reason}",
        f"l19_root_index_path={root_index.root_index_path}",
        "l19_scope=canonical_selection_shortcut_dossiers_only",
        "l19_source_contract=l18_selected_raw_ohlc_scope_using_existing_shared_ohlc_seed_files",
        "l19_rows_shown_per_tf=5",
        "l19_structure_wave=wave_1_single_candle_plus_wave_2_closed_assumed_two_candle_structures",
        "l19_wave2_current_possible_confirmed=false",
        "l19_time_basis=OHLC_Store_Unix_Time",
        "l19_copyrates_calls=0",
        "l19_private_ohlc_cache=false",
        "l19_raw_ohlc_store_writes=false",
        "l19_base_dossiers_touched=false",
        "l19_all_symbol_scan=false",
        "l19_meaning=candle_geometry_and_structure_only_not_signal_not_trade_permission",
        "l19_trade_permission=false",
        "l19_entry_signal=false",
        "l19_execution=false",
        "",
    ])


def _replace_or_append_l19_block(result_text: str, lines: str) -> str:
    marker = "l19_candle_geometry_status="
    normalized = result_text.replace("\r\n", "\n")
    if marker not in normalized:
        return normalized.rstrip() + "\n" + lines
    before, _sep, tail = normalized.partition(marker)
    kept_tail = []
    for line in tail.splitlines():
        if line.startswith("l19_"):
            continue
        kept_tail.append(line)
    suffix = "\n".join(kept_tail).strip()
    return before.rstrip() + "\n" + lines + (suffix + "\n" if suffix else "")


def run_l19_after_l18(root: Path) -> L19PublishSummary:
    paths = WorkerPaths.from_root(root)
    paths.ensure()
    start_ns = time.perf_counter_ns()
    summary = publish_l19_candle_geometry_and_structure(root)
    cleanup_summary = cleanup_legacy_selection_surface_paths(root)
    root_index_summary = publish_selection_root_index(root)
    duration_ms = max(0, (time.perf_counter_ns() - start_ns) // 1_000_000)
    result_path = paths.outbox / "result_latest.txt"
    if result_path.exists():
        text = read_text(result_path)
        updated = _replace_or_append_l19_block(text, l19_result_lines(summary, duration_ms, cleanup_summary, root_index_summary))
        atomic_write_text(result_path, updated)
        manifest_path = paths.outbox / "result_latest.manifest"
        manifest = "\n".join([
            "schema_name=aurora_worker_result_manifest",
            "schema_version=21",
            "worker_l19_append_status=appended_by_l19_dispatch",
            f"l19_status={summary.status}",
            f"l19_selected_dossiers_decorated={summary.selected_dossiers_decorated}",
            f"l19_source_files_found={summary.source_files_found}",
            f"l19_source_files_expected={summary.source_files_expected}",
            f"l19_valid_geometry_rows={summary.valid_geometry_rows}",
            f"l19_zero_range_rows={summary.zero_range_rows}",
            f"l19_invalid_geometry_rows={summary.invalid_geometry_rows}",
            f"l19_wave2_rows_tagged={summary.wave2_rows_tagged}",
            f"l19_topview_cleanup_count={summary.topview_cleanup_count}",
            f"l19_status_path={summary.status_path}",
            f"l19_board_path={summary.board_path}",
            f"l19_final_cleanup_status={cleanup_summary.status}",
            f"l19_root_index_status={root_index_summary.status}",
            f"result_size={len(updated.encode('utf-8'))}",
            f"payload_checksum={payload_checksum(updated.splitlines())}",
            "authority=calculation_support_only",
            "l19_structure_wave=wave_1_single_candle_plus_wave_2_closed_assumed_two_candle_structures",
            "l19_wave2_current_possible_confirmed=false",
            "l19_time_basis=OHLC_Store_Unix_Time",
            "l19_copyrates_calls=0",
            "l19_private_ohlc_cache=false",
            "l19_raw_ohlc_store_writes=false",
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
