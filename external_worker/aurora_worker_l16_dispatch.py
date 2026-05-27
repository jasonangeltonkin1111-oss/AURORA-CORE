from __future__ import annotations

from pathlib import Path
import time

from aurora_worker_io import WorkerPaths, atomic_write_text, payload_checksum, read_text, read_kv, unix_time, utc_stamp
from aurora_worker_l16 import L16PublishSummary, publish_l16_global_top10_builder
from aurora_worker_selection_surface_shortcuts import EMPTY_SELECTION_SHORTCUT_SUMMARY, SelectionShortcutSummary, publish_l16_global_top10_shortcuts
from aurora_worker_selection_surface_root_index import EMPTY_SELECTION_ROOT_INDEX_SUMMARY, SelectionRootIndexSummary, publish_selection_desk_root_operator_index


def _l15_current_chain_valid(outbox: Path) -> tuple[bool, str]:
    result_path = outbox / "result_latest.txt"
    if not result_path.exists():
        return False, "result_latest_missing_l15_currentness_unknown"
    kv = read_kv(result_path)
    value = str(kv.get("l15_current_chain_valid", "unknown")).strip().lower()
    status = str(kv.get("l15_correlation_diversity_status", "unknown")).strip()
    reason = str(kv.get("l15_currentness_reason", kv.get("l15_correlation_diversity_reason", "not_available"))).strip()
    if value == "true":
        return True, f"l15_current_chain_valid=true;status={status};reason={reason}"
    if value == "unknown" and status in {"accepted", "write_degraded"}:
        return True, f"legacy_l15_status_allowed;status={status};reason={reason}"
    return False, f"l15_current_chain_valid={value};status={status};reason={reason}"


def _blocked_l16_summary(reason: str) -> L16PublishSummary:
    return L16PublishSummary(
        status="blocked_upstream_currentness",
        reason=reason,
        candidate_pool_size=0,
        l15_candidate_count=0,
        selected_count=0,
        unfilled_slots_count=10,
        reject_count=0,
        correlation_reject_count=0,
        group_cap_reject_count=0,
        fallback_count=0,
        group_count=0,
        write_failed_count=0,
        top_symbol="not_available",
        output_path="not_written_latest_l15_invalid",
        summary_path="not_written_latest_l15_invalid",
        selection_desk_path="not_written_latest_l15_invalid",
        clean_selected_count=0,
        fallback_selected_count=0,
        display_slot_count=0,
        strict_clean_unfilled_slots_count=10,
        hold_enabled="true",
        hold_seconds=300,
        hold_state="blocked_latest_l15_invalid",
        visible_surface_state="blocked_not_current",
    )


def _l16_currentness_fields(summary: L16PublishSummary, l15_gate_valid: bool, l15_gate_reason: str) -> list[str]:
    current = "true" if summary.status in {"accepted", "degraded", "write_degraded"} and l15_gate_valid and summary.display_slot_count > 0 else "false"
    if not l15_gate_valid:
        visible_source = "blocked_latest_l15_invalid"
        reason = "latest_l15_invalid_do_not_consume_held_l15_or_l16_outputs"
    elif current == "true":
        visible_source = "latest_calculation"
        reason = "latest_l16_built_from_current_l15"
    else:
        visible_source = "latest_l16_not_current"
        reason = "latest_l16_failed_or_empty"
    return [
        f"l16_current_chain_valid={current}",
        f"l16_visible_output_source={visible_source}",
        f"l16_currentness_reason={reason}",
        f"l16_upstream_l15_gate={l15_gate_reason}",
    ]


def l16_result_lines(summary: L16PublishSummary, duration_ms: int, global_shortcuts: SelectionShortcutSummary = EMPTY_SELECTION_SHORTCUT_SUMMARY, root_index: SelectionRootIndexSummary = EMPTY_SELECTION_ROOT_INDEX_SUMMARY, l15_gate_valid: bool = True, l15_gate_reason: str = "not_checked") -> str:
    return "\n".join([
        f"l16_global_top10_status={summary.status}",
        f"l16_global_top10_reason={summary.reason}",
        f"l16_global_top10_duration_ms={duration_ms}",
        *_l16_currentness_fields(summary, l15_gate_valid, l15_gate_reason),
        f"l16_candidate_pool_size={summary.candidate_pool_size}",
        f"l16_l15_candidate_count={summary.l15_candidate_count}",
        f"l16_selected_count={summary.selected_count}",
        f"l16_selected_count_meaning=strict_clean_diversified_count_excludes_fallback_display",
        f"l16_display_slot_count={summary.display_slot_count}",
        f"l16_clean_selected_count={summary.clean_selected_count}",
        f"l16_fallback_selected_count={summary.fallback_selected_count}",
        f"l16_strict_clean_unfilled_slots_count={summary.strict_clean_unfilled_slots_count}",
        f"l16_unfilled_slots_count={summary.unfilled_slots_count}",
        f"l16_reject_count={summary.reject_count}",
        f"l16_correlation_reject_count={summary.correlation_reject_count}",
        f"l16_group_cap_reject_count={summary.group_cap_reject_count}",
        f"l16_fallback_count={summary.fallback_count}",
        f"l16_group_count={summary.group_count}",
        f"l16_top_symbol={summary.top_symbol}",
        f"l16_write_failed_count={summary.write_failed_count}",
        f"l16_hold_enabled={summary.hold_enabled}",
        f"l16_hold_seconds={summary.hold_seconds}",
        f"l16_hold_state={summary.hold_state}",
        f"l16_hold_started_unix={summary.hold_started_unix}",
        f"l16_hold_valid_until_unix={summary.hold_valid_until_unix}",
        f"l16_hold_age_seconds={summary.hold_age_seconds}",
        f"l16_hold_valid_until_utc={summary.hold_valid_until_utc}",
        f"l16_visible_surface_state={summary.visible_surface_state}",
        f"l16_output_path={summary.output_path}",
        f"l16_summary_path={summary.summary_path}",
        f"l16_selection_desk_path={summary.selection_desk_path}",
        f"l16_global_shortcut_status={global_shortcuts.status}",
        f"l16_global_shortcut_reason={global_shortcuts.reason}",
        f"l16_global_shortcut_files_written={global_shortcuts.files_written}",
        f"l16_global_shortcut_files_expected={global_shortcuts.files_expected}",
        f"l16_global_shortcut_dossier_copies_written={global_shortcuts.dossier_copies_written}",
        f"l16_global_shortcut_dossier_copies_expected={global_shortcuts.dossier_copies_expected}",
        f"l16_global_shortcut_sources_missing={global_shortcuts.dossier_sources_missing}",
        f"l16_global_shortcut_status_path={global_shortcuts.status_path}",
        f"l16_selection_root_index_status={root_index.status}",
        f"l16_selection_root_index_reason={root_index.reason}",
        f"l16_selection_root_index_files_written={root_index.files_written}",
        f"l16_selection_root_index_files_expected={root_index.files_expected}",
        f"l16_selection_root_index_path={root_index.index_path}",
        "l16_max_allowed_pairwise_correlation_abs=0.30",
        "l16_threshold_status=untested_default_not_holy_law",
        "l16_meaning=global_top10_inspection_basket_only_not_trade_permission",
        "l16_global_shortcut_meaning=global_top10_dossier_shortcuts_only_not_trade_permission",
        "l16_selection_root_index_meaning=operator_navigation_index_only_no_scoring_authority",
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
    l15_gate_valid, l15_gate_reason = _l15_current_chain_valid(paths.outbox)
    if l15_gate_valid:
        summary = publish_l16_global_top10_builder(paths.outbox)
        global_shortcuts_summary = publish_l16_global_top10_shortcuts(root)
    else:
        summary = _blocked_l16_summary("l16_blocked_because_latest_l15_current_chain_invalid;" + l15_gate_reason)
        global_shortcuts_summary = EMPTY_SELECTION_SHORTCUT_SUMMARY
    root_index_summary = publish_selection_desk_root_operator_index(root)
    duration_ms = max(0, (time.perf_counter_ns() - start_ns) // 1_000_000)
    result_path = paths.outbox / "result_latest.txt"
    if result_path.exists():
        text = read_text(result_path)
        updated = _replace_or_append_l16_block(text, l16_result_lines(summary, duration_ms, global_shortcuts_summary, root_index_summary, l15_gate_valid, l15_gate_reason))
        atomic_write_text(result_path, updated)
        manifest_path = paths.outbox / "result_latest.manifest"
        manifest = "\n".join([
            "schema_name=aurora_worker_result_manifest",
            "schema_version=15",
            "worker_l16_append_status=appended_by_l16_dispatch",
            *_l16_currentness_fields(summary, l15_gate_valid, l15_gate_reason),
            f"l16_display_slot_count={summary.display_slot_count}",
            f"l16_clean_selected_count={summary.clean_selected_count}",
            f"l16_fallback_selected_count={summary.fallback_selected_count}",
            f"l16_hold_state={summary.hold_state}",
            f"l16_visible_surface_state={summary.visible_surface_state}",
            f"l16_global_shortcut_status={global_shortcuts_summary.status}",
            f"l16_global_shortcut_files_written={global_shortcuts_summary.files_written}",
            f"l16_global_shortcut_files_expected={global_shortcuts_summary.files_expected}",
            f"l16_global_shortcut_status_path={global_shortcuts_summary.status_path}",
            f"l16_selection_root_index_status={root_index_summary.status}",
            f"l16_selection_root_index_path={root_index_summary.index_path}",
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
