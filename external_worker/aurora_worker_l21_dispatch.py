from __future__ import annotations

from pathlib import Path
import time

from aurora_worker_io import WorkerPaths, atomic_write_text, payload_checksum, read_text, unix_time, utc_stamp
from aurora_worker_l21 import L21PublishSummary, publish_l21_indicator_reference_pack


def l21_result_lines(summary: L21PublishSummary, duration_ms: int) -> str:
    return "\n".join([
        f"l21_indicator_reference_status={summary.status}",
        f"l21_indicator_reference_reason={summary.reason}",
        f"l21_indicator_reference_duration_ms={duration_ms}",
        f"l21_selected_dossiers_seen={summary.selected_dossiers_seen}",
        f"l21_selected_route_dossiers_seen={summary.selected_route_dossiers_seen}",
        f"l21_selected_route_dossiers_decorated={summary.selected_route_dossiers_decorated}",
        f"l21_selected_unique_symbols_seen={summary.selected_unique_symbols_seen}",
        f"l21_selected_duplicate_route_copies={summary.selected_duplicate_route_copies}",
        f"l21_selected_dossiers_decorated={summary.selected_dossiers_decorated}",
        f"l21_selected_dossiers_missing_symbol={summary.selected_dossiers_missing_symbol}",
        f"l21_source_files_expected={summary.source_files_expected}",
        f"l21_source_files_found={summary.source_files_found}",
        f"l21_source_files_missing={summary.source_files_missing}",
        f"l21_source_files_partial={summary.source_files_partial}",
        f"l21_source_decode_errors={summary.source_decode_errors}",
        f"l21_timeframe_packets_rendered={summary.timeframe_packets_rendered}",
        f"l21_indicator_complete_packets={summary.indicator_complete_packets}",
        f"l21_indicator_degraded_packets={summary.indicator_degraded_packets}",
        f"l21_indicator_missing_packets={summary.indicator_missing_packets}",
        f"l21_vwap_real_volume_packets={summary.vwap_real_volume_packets}",
        f"l21_vwap_tick_volume_proxy_packets={summary.vwap_tick_volume_proxy_packets}",
        f"l21_vwap_unavailable_packets={summary.vwap_unavailable_packets}",
        f"l21_write_failed_count={summary.write_failed_count}",
        f"l21_latest_bar_age_max_seconds={summary.latest_bar_age_max_seconds}",
        f"l21_freshness_status={summary.freshness_status}",
        f"l21_status_path={summary.status_path}",
        f"l21_board_path={summary.board_path}",
        f"l21_layer_folder={summary.layer_folder}",
        "l21_scope=canonical_selection_shortcut_dossiers_only",
        "l21_source_contract=l18_selected_raw_ohlc_scope_using_existing_shared_ohlc_seed_files",
        "l21_source_owner=Runtime_1_Shared_OHLC_Raw_Storage_Owner",
        "l21_calculation_authority=Runtime_3_calculation_support_L21_only",
        "l21_copyrates_calls=0",
        "l21_private_ohlc_cache=false",
        "l21_raw_ohlc_store_writes=false",
        "l21_base_dossiers_touched=false",
        "l21_all_symbol_scan=false",
        "l21_vwap_source_law=real_volume_or_tick_volume_proxy_or_unavailable_must_be_labelled",
        "l21_session_vwap_status=not_wired",
        "l21_meaning=indicator_reference_context_only_not_signal_not_trade_permission",
        "l21_trade_permission=false",
        "l21_entry_signal=false",
        "l21_execution=false",
        "",
    ])


def _replace_or_append_l21_block(result_text: str, lines: str) -> str:
    marker = "l21_indicator_reference_status="
    normalized = result_text.replace("\r\n", "\n")
    if marker not in normalized:
        return normalized.rstrip() + "\n" + lines
    before, _sep, tail = normalized.partition(marker)
    kept_tail = []
    for line in tail.splitlines():
        if line.startswith("l21_"):
            continue
        kept_tail.append(line)
    suffix = "\n".join(kept_tail).strip()
    return before.rstrip() + "\n" + lines + (suffix + "\n" if suffix else "")


def run_l21_after_l19(root: Path) -> L21PublishSummary:
    paths = WorkerPaths.from_root(root)
    paths.ensure()
    start_ns = time.perf_counter_ns()
    summary = publish_l21_indicator_reference_pack(root)
    duration_ms = max(0, (time.perf_counter_ns() - start_ns) // 1_000_000)
    result_path = paths.outbox / "result_latest.txt"
    if result_path.exists():
        text = read_text(result_path)
        updated = _replace_or_append_l21_block(text, l21_result_lines(summary, duration_ms))
        atomic_write_text(result_path, updated)
        manifest_path = paths.outbox / "result_latest.manifest"
        manifest = "\n".join([
            "schema_name=aurora_worker_result_manifest",
            "schema_version=23",
            "worker_l21_append_status=appended_by_l21_dispatch",
            f"l21_status={summary.status}",
            f"l21_selected_dossiers_decorated={summary.selected_dossiers_decorated}",
            f"l21_source_files_found={summary.source_files_found}",
            f"l21_source_files_expected={summary.source_files_expected}",
            f"l21_selected_unique_symbols_seen={summary.selected_unique_symbols_seen}",
            f"l21_freshness_status={summary.freshness_status}",
            f"l21_indicator_complete_packets={summary.indicator_complete_packets}",
            f"l21_indicator_degraded_packets={summary.indicator_degraded_packets}",
            f"l21_indicator_missing_packets={summary.indicator_missing_packets}",
            f"l21_vwap_real_volume_packets={summary.vwap_real_volume_packets}",
            f"l21_vwap_tick_volume_proxy_packets={summary.vwap_tick_volume_proxy_packets}",
            f"l21_vwap_unavailable_packets={summary.vwap_unavailable_packets}",
            f"l21_status_path={summary.status_path}",
            f"l21_board_path={summary.board_path}",
            f"result_size={len(updated.encode('utf-8'))}",
            f"payload_checksum={payload_checksum(updated.splitlines())}",
            "authority=calculation_support_only",
            "l21_copyrates_calls=0",
            "l21_private_ohlc_cache=false",
            "l21_raw_ohlc_store_writes=false",
            "l21_session_vwap_status=not_wired",
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
