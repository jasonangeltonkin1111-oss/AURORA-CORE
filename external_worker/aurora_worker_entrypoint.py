from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Tuple
import argparse
import time

import aurora_worker as core
from aurora_worker_io import WorkerPaths, atomic_write_text, atomic_write_text_fast, read_kv, unix_time, utc_stamp
from aurora_worker_l11_dispatch import run_l11_after_render_index
from aurora_worker_l12_dispatch import run_l12_after_l11
from aurora_worker_l13_dispatch import run_l13_after_l12
from aurora_worker_l14_dispatch import run_l14_after_l13
from aurora_worker_l15_dispatch import run_l15_after_l14
from aurora_worker_l16_dispatch import run_l16_after_l15
from aurora_worker_l17_dispatch import run_l17_after_l16
from aurora_worker_l18_dispatch import run_l18_after_l17

# Runtime flow law:
# - Debounce Runtime 1 snapshots before a calculation cycle starts.
# - Retry unfinished/non-accepted cycles on a bounded cadence, not every poll.
# - Once the full layer chain reaches strict accepted truth, keep that accepted
#   surface static for five minutes before another recalculation can start.
SNAPSHOT_STABLE_REQUIRED_SECONDS = 10
CALCULATION_CYCLE_SECONDS = 60
ACCEPTED_EPOCH_TTL_SECONDS = 300
ENABLE_L13_RUNTIME = True
ENABLE_L14_RUNTIME = True
ENABLE_L15_RUNTIME = True
ENABLE_L16_RUNTIME = True
ENABLE_L17_RUNTIME = True
ENABLE_L18_RUNTIME = True
ENABLE_L19_RUNTIME = True


@dataclass
class SnapshotCycleState:
    identity: str = "not_available"
    first_seen_unix: int = 0
    last_calculation_unix: int = 0
    last_exit_code: int = 2
    last_result: core.ValidationResult | None = None
    last_action: str = "not_started"
    last_reason: str = "not_available"
    retry_cycle_count: int = 0
    retry_cycle_limit: int = 5
    last_successful_core_epoch_id: str = "none"


def _snapshot_identity(result: core.ValidationResult) -> str:
    return "|".join([result.server, result.account, result.snapshot_id, result.job_id, result.payload_checksum, str(result.row_count)])


def _surface_epoch_manifest_path(root: Path) -> Path:
    return WorkerPaths.from_root(root).outbox / "surface_accepted_epoch.manifest"


def _cycle_status_path(root: Path) -> Path:
    return WorkerPaths.from_root(root).status / "gateway_cycle_status.txt"


def _result_latest_path(root: Path) -> Path:
    return WorkerPaths.from_root(root).outbox / "result_latest.txt"


def _manifest_true(data: Dict[str, str], key: str) -> bool:
    return str(data.get(key, "false")).strip().lower() == "true"


def _strict_epoch_manifest_ok(data: Dict[str, str]) -> Tuple[bool, str]:
    if data.get("schema_name") != "aurora_gateway_surface_accepted_epoch":
        return False, "accepted_epoch_missing_or_wrong_schema_name"
    try:
        schema_version = int(float(data.get("schema_version", "0")))
    except ValueError:
        schema_version = 0
    if schema_version < 12:
        return False, "accepted_epoch_legacy_schema_version"
    if data.get("display_epoch_status") != "strict_accepted_static":
        return False, "accepted_epoch_missing_strict_display_status"
    if data.get("static_policy") != "hold_strict_accepted_surface_for_5_minutes_before_recalculation":
        return False, "accepted_epoch_missing_chain11_static_policy"
    if data.get("false_accept_policy") != "degraded_pending_partial_write_degraded_do_not_create_static_epoch":
        return False, "accepted_epoch_missing_false_accept_policy"

    required_statuses = {
        "l6_status": "complete",
        "l7_status": "complete",
        "l8_status": "complete",
        "l9_status": "complete",
        "l11_symbol_ranking_status": "accepted",
        "l12_group_heat_quality_status": "accepted",
        "l13_dynamic_group_selection_status": "accepted",
        "l14_candidate_pool_status": "accepted",
        "l15_correlation_diversity_status": "accepted",
        "l16_global_top10_status": "accepted",
        "l17_deep_evidence_selection_status": "accepted",
    }
    for key, expected in required_statuses.items():
        if data.get(key) != expected:
            return False, f"accepted_epoch_status_not_strict:{key}={data.get(key, 'missing')}"

    for layer in ("l14", "l15", "l16", "l17", "l18", "l19"):
        if not _manifest_true(data, f"{layer}_current_chain_valid"):
            return False, f"accepted_epoch_currentness_not_true:{layer}"
        if not _manifest_true(data, f"{layer}_downstream_allowed"):
            return False, f"accepted_epoch_downstream_not_true:{layer}"

    if data.get("l18_selected_raw_ohlc_status") not in {"accepted", "complete_history_limited"}:
        return False, f"accepted_epoch_l18_not_complete:{data.get('l18_selected_raw_ohlc_status', 'missing')}"
    if data.get("l19_candle_geometry_status") not in {"accepted", "complete_history_limited"}:
        return False, f"accepted_epoch_l19_not_complete:{data.get('l19_candle_geometry_status', 'missing')}"
    return True, "strict_accepted_epoch_manifest_verified"


def _accepted_epoch_static_state(root: Path, result: core.ValidationResult, now: int) -> Tuple[bool, str, int]:
    path = _surface_epoch_manifest_path(root)
    if not path.exists():
        return False, "accepted_epoch_missing", 0
    try:
        data = read_kv(path)
    except OSError as exc:
        return False, f"accepted_epoch_unreadable:{type(exc).__name__}", 0
    status_ok = data.get("status") == "accepted" and data.get("epoch_status") == "accepted"
    if not status_ok:
        return False, "accepted_epoch_not_strict_accepted", 0
    manifest_ok, manifest_reason = _strict_epoch_manifest_ok(data)
    if not manifest_ok:
        return False, manifest_reason, 0
    same_snapshot = data.get("source_snapshot_id") == result.snapshot_id and data.get("source_payload_checksum") == result.payload_checksum
    try:
        valid_until = int(float(data.get("valid_until_unix", "0")))
    except ValueError:
        valid_until = 0
    remaining = max(0, valid_until - now)
    if same_snapshot and remaining > 0:
        return True, "strict_accepted_epoch_static_hold_active", remaining
    if not same_snapshot:
        return False, "accepted_epoch_snapshot_changed", 0
    return False, "accepted_epoch_static_hold_expired", 0


def _build_cycle_status(root: Path, loop: int, state: SnapshotCycleState, result: core.ValidationResult, action: str, reason: str) -> str:
    now = unix_time()
    stable_age = max(0, now - state.first_seen_unix) if state.first_seen_unix > 0 else 0
    cycle_age = max(0, now - state.last_calculation_unix) if state.last_calculation_unix > 0 else -1
    static_ok, static_reason, static_remaining = _accepted_epoch_static_state(root, result, now)
    latest_path = _result_latest_path(root)
    latest = read_kv(latest_path) if latest_path.exists() else {}
    l8_state = latest.get("l8_rank_status", "missing")
    l14_state = latest.get("l14_candidate_pool_status", "missing")
    l15_state = latest.get("l15_correlation_diversity_status", "missing")
    l16_state = latest.get("l16_global_top10_status", "missing")
    l14_current = latest.get("l14_current_chain_valid", "false")
    l15_current = latest.get("l15_current_chain_valid", "false")
    l16_current = latest.get("l16_current_chain_valid", "false")
    l17_current = latest.get("l17_current_chain_valid", "false")
    l14_downstream = latest.get("l14_downstream_allowed", "false")
    l15_downstream = latest.get("l15_downstream_allowed", "false")
    l16_downstream = latest.get("l16_downstream_allowed", "false")
    l17_downstream = latest.get("l17_downstream_allowed", "false")
    l18_state = latest.get("l18_selected_raw_ohlc_status", "missing")
    l19_state = latest.get("l19_candle_geometry_status", latest.get("l19_wick_candle_geometry_status", "missing"))
    l18_downstream = latest.get("l18_downstream_allowed", "false")
    l19_downstream = latest.get("l19_downstream_allowed", "false")
    core_complete = (
        result.ok
        and latest.get("l6_rank_status") == "complete"
        and latest.get("l7_rank_status") == "complete"
        and l8_state == "complete"
        and latest.get("l9_rank_status") == "complete"
        and latest.get("l11_symbol_ranking_status") == "accepted"
        and latest.get("l12_group_heat_quality_status") == "accepted"
        and latest.get("l13_dynamic_group_selection_status") == "accepted"
        and l14_state == "accepted"
        and l14_current == "true"
        and l14_downstream == "true"
        and l15_state == "accepted"
        and l15_current == "true"
        and l15_downstream == "true"
        and l16_state == "accepted"
        and l16_current == "true"
        and l16_downstream == "true"
        and latest.get("l17_deep_evidence_selection_status") == "accepted"
        and l17_current == "true"
        and l17_downstream == "true"
        and l18_state in {"accepted", "complete_history_limited"}
        and latest.get("l18_current_chain_valid") == "true"
        and l18_downstream == "true"
        and l19_state in {"accepted", "complete_history_limited"}
        and latest.get("l19_current_chain_valid") == "true"
        and l19_downstream == "true"
    )
    core_completion_state = "complete" if core_complete else "incomplete"
    deep_completion_state = "deep_complete" if l18_state == "accepted" and l19_state == "accepted" else ("deep_complete_history_limited" if l18_state == "complete_history_limited" or l19_state == "complete_history_limited" else "deep_filling")
    chain_state = "core_complete" if core_complete and deep_completion_state == "deep_complete" else ("deep_filling" if core_complete else ("calculating" if action == "calculation_cycle_ran" else "waiting"))
    if core_complete:
        main_blocker_owner = "none"
        main_blocker_reason = "none"
    elif l8_state != "complete":
        main_blocker_owner = "Runtime3/L8"
        main_blocker_reason = latest.get("l8_rank_reason", result.reason)
    elif l14_state != "accepted" or l14_current != "true" or l14_downstream != "true":
        main_blocker_owner = "Runtime3/L14"
        main_blocker_reason = latest.get("l14_currentness_reason", latest.get("l14_candidate_pool_reason", result.reason))
    elif l15_state != "accepted" or l15_current != "true" or l15_downstream != "true":
        main_blocker_owner = "Runtime3/L15"
        main_blocker_reason = latest.get("l15_currentness_reason", latest.get("l15_correlation_diversity_reason", result.reason))
    elif l16_state != "accepted" or l16_current != "true" or l16_downstream != "true":
        main_blocker_owner = "Runtime3/L16"
        main_blocker_reason = latest.get("l16_currentness_reason", latest.get("l16_global_top10_reason", result.reason))
    elif latest.get("l17_deep_evidence_selection_status") != "accepted" or l17_current != "true" or l17_downstream != "true":
        main_blocker_owner = "Runtime3/L17"
        main_blocker_reason = latest.get("l17_currentness_reason", latest.get("l17_deep_evidence_selection_reason", result.reason))
    elif l18_state not in {"accepted", "complete_history_limited"} or latest.get("l18_current_chain_valid") != "true" or l18_downstream != "true":
        main_blocker_owner = "Runtime3/L18"
        main_blocker_reason = latest.get("l18_currentness_reason", latest.get("l18_selected_raw_ohlc_reason", result.reason))
    else:
        main_blocker_owner = "Runtime3/L19"
        main_blocker_reason = latest.get("l19_currentness_reason", latest.get("l19_candle_geometry_reason", result.reason))
    return "\n".join([
        "schema_name=aurora_gateway_cycle_status", "schema_version=4", f"worker_version={core.WORKER_VERSION}",
        "mode=shared-daemon-cycle-controller", f"root={root}", f"loop_count={loop}", "poll_seconds=1",
        f"chain_state={chain_state}", f"core_completion_state={core_completion_state}", f"deep_completion_state={deep_completion_state}",
        f"snapshot_stable_required_seconds={SNAPSHOT_STABLE_REQUIRED_SECONDS}", f"calculation_retry_seconds={CALCULATION_CYCLE_SECONDS}",
        f"accepted_epoch_static_seconds={ACCEPTED_EPOCH_TTL_SECONDS}", f"accepted_epoch_ttl_seconds={ACCEPTED_EPOCH_TTL_SECONDS}",
        f"accepted_epoch_static_hold_active={'true' if static_ok else 'false'}", f"accepted_epoch_static_hold_reason={static_reason}",
        f"accepted_epoch_static_remaining_seconds={static_remaining}", f"snapshot_identity={state.identity}",
        f"snapshot_first_seen_unix={state.first_seen_unix}", f"snapshot_stable_age_seconds={stable_age}",
        f"last_calculation_unix={state.last_calculation_unix}", f"last_calculation_age_seconds={cycle_age}",
        f"last_exit_code={state.last_exit_code}", f"last_action={action}", f"last_reason={reason}",
        f"retry_cycle_limit={state.retry_cycle_limit}", f"retry_cycle_count={state.retry_cycle_count}",
        f"main_blocker_owner={main_blocker_owner}", f"main_blocker_reason={main_blocker_reason}",
        f"source_snapshot_changed={'true' if action == 'snapshot_identity_changed_waiting_for_debounce' else 'false'}",
        f"last_successful_core_epoch_id={state.last_successful_core_epoch_id}",
        f"last_validation_status={result.status}", f"last_validation_reason={result.reason}",
        f"source_snapshot_id={result.snapshot_id}", f"source_payload_checksum={result.payload_checksum}", f"row_count={result.row_count}",
        f"l14_current_chain_valid={l14_current}", f"l14_downstream_allowed={l14_downstream}",
        f"l15_current_chain_valid={l15_current}", f"l15_downstream_allowed={l15_downstream}",
        f"l16_current_chain_valid={l16_current}", f"l16_downstream_allowed={l16_downstream}",
        f"l17_current_chain_valid={l17_current}", f"l17_downstream_allowed={l17_downstream}",
        f"l18_current_chain_valid={latest.get('l18_current_chain_valid', 'false')}", f"l18_downstream_allowed={l18_downstream}",
        f"l19_current_chain_valid={latest.get('l19_current_chain_valid', 'false')}", f"l19_downstream_allowed={l19_downstream}",
        f"l18_runtime_enabled={'true' if ENABLE_L18_RUNTIME else 'false'}",
        f"l19_runtime_enabled={'true' if ENABLE_L19_RUNTIME else 'false'}",
        f"generated_utc={utc_stamp()}", f"generated_unix={now}", "authority=calculation_support_only",
        "trade_permission=false", "selection_runtime=false", "entry_signal=false", "execution=false", "",
    ])


def _write_cycle_status(root: Path, loop: int, state: SnapshotCycleState, result: core.ValidationResult, action: str, reason: str) -> bool:
    return atomic_write_text_fast(_cycle_status_path(root), _build_cycle_status(root, loop, state, result, action, reason))


def _write_surface_epoch_if_accepted(root: Path, result: core.ValidationResult, enable_l13_runtime: bool, enable_l14_runtime: bool, enable_l15_runtime: bool, enable_l16_runtime: bool, enable_l17_runtime: bool, enable_l18_runtime: bool, enable_l19_runtime: bool) -> bool:
    latest_path = _result_latest_path(root)
    latest = read_kv(latest_path) if latest_path.exists() else {}
    l6_status = latest.get("l6_rank_status", "missing")
    l7_status = latest.get("l7_rank_status", "missing")
    l8_status = latest.get("l8_rank_status", "missing")
    l9_status = latest.get("l9_rank_status", "missing")
    l11_status = latest.get("l11_symbol_ranking_status", "missing")
    l12_status = latest.get("l12_group_heat_quality_status", "missing")
    l13_status = latest.get("l13_dynamic_group_selection_status", "missing") if enable_l13_runtime else "disabled"
    l14_status = latest.get("l14_candidate_pool_status", "missing") if enable_l14_runtime else "disabled"
    l15_status = latest.get("l15_correlation_diversity_status", "missing") if enable_l15_runtime else "disabled"
    l16_status = latest.get("l16_global_top10_status", "missing") if enable_l16_runtime else "disabled"
    l17_status = latest.get("l17_deep_evidence_selection_status", "missing") if enable_l17_runtime else "disabled"
    l18_status = latest.get("l18_selected_raw_ohlc_status", "missing") if enable_l18_runtime else "disabled"
    l19_status = latest.get("l19_candle_geometry_status", "missing") if enable_l19_runtime else "disabled"
    l14_current = latest.get("l14_current_chain_valid", "true") if enable_l14_runtime else "disabled"
    l15_current = latest.get("l15_current_chain_valid", "true") if enable_l15_runtime else "disabled"
    l16_current = latest.get("l16_current_chain_valid", "true") if enable_l16_runtime else "disabled"
    l17_current = latest.get("l17_current_chain_valid", "false") if enable_l17_runtime else "disabled"
    l18_current = latest.get("l18_current_chain_valid", "false") if enable_l18_runtime else "disabled"
    l19_current = latest.get("l19_current_chain_valid", "false") if enable_l19_runtime else "disabled"
    l14_downstream = latest.get("l14_downstream_allowed", "false") if enable_l14_runtime else "disabled"
    l15_downstream = latest.get("l15_downstream_allowed", "false") if enable_l15_runtime else "disabled"
    l16_downstream = latest.get("l16_downstream_allowed", "false") if enable_l16_runtime else "disabled"
    l17_downstream = latest.get("l17_downstream_allowed", "false") if enable_l17_runtime else "disabled"
    l18_downstream = latest.get("l18_downstream_allowed", "false") if enable_l18_runtime else "disabled"
    l19_downstream = latest.get("l19_downstream_allowed", "false") if enable_l19_runtime else "disabled"
    all_complete = (
        result.ok and l6_status == "complete" and l7_status == "complete" and l8_status == "complete" and l9_status == "complete"
        and l11_status == "accepted"
        and l12_status == "accepted"
        and ((l13_status == "accepted") if enable_l13_runtime else True)
        and ((l14_status == "accepted" and l14_current == "true" and l14_downstream == "true") if enable_l14_runtime else True)
        and ((l15_status == "accepted" and l15_current == "true" and l15_downstream == "true") if enable_l15_runtime else True)
        and ((l16_status == "accepted" and l16_current == "true" and l16_downstream == "true") if enable_l16_runtime else True)
        and ((l17_status == "accepted" and l17_current == "true" and l17_downstream == "true") if enable_l17_runtime else True)
        and ((l18_status in {"accepted", "complete_history_limited"} and l18_current == "true" and l18_downstream == "true") if enable_l18_runtime else True)
        and ((l19_status in {"accepted", "complete_history_limited"} and l19_current == "true" and l19_downstream == "true") if enable_l19_runtime else True)
    )
    if not all_complete:
        return False
    accepted_unix = unix_time()
    epoch_id = "|".join([result.snapshot_id, result.payload_checksum, l6_status, l7_status, l8_status, l9_status, l11_status, l12_status, l13_status, l14_status, l15_status, l16_status, l17_status, l18_status, l19_status])
    text = "\n".join([
        "schema_name=aurora_gateway_surface_accepted_epoch", "schema_version=12", f"worker_version={core.WORKER_VERSION}",
        "status=accepted", "epoch_status=accepted", "display_epoch_status=strict_accepted_static", f"epoch_id={epoch_id}",
        "static_policy=hold_strict_accepted_surface_for_5_minutes_before_recalculation", "false_accept_policy=degraded_pending_partial_write_degraded_do_not_create_static_epoch",
        f"source_snapshot_id={result.snapshot_id}", f"source_payload_checksum={result.payload_checksum}", f"source_job_id={result.job_id}",
        f"row_count={result.row_count}", f"accepted_unix={accepted_unix}", f"accepted_utc={utc_stamp()}",
        f"valid_until_unix={accepted_unix + ACCEPTED_EPOCH_TTL_SECONDS}", f"accepted_epoch_ttl_seconds={ACCEPTED_EPOCH_TTL_SECONDS}",
        f"l6_status={l6_status}", f"l7_status={l7_status}", f"l8_status={l8_status}", f"l9_status={l9_status}",
        f"l11_symbol_ranking_status={l11_status}", f"l12_group_heat_quality_status={l12_status}",
        f"l13_dynamic_group_selection_status={l13_status}", f"l14_candidate_pool_status={l14_status}", f"l14_current_chain_valid={l14_current}", f"l14_downstream_allowed={l14_downstream}",
        f"l15_correlation_diversity_status={l15_status}", f"l15_current_chain_valid={l15_current}",
        f"l15_downstream_allowed={l15_downstream}",
        f"l16_global_top10_status={l16_status}", f"l16_current_chain_valid={l16_current}", f"l16_downstream_allowed={l16_downstream}",
        f"l17_deep_evidence_selection_status={l17_status}", f"l17_current_chain_valid={l17_current}", f"l17_downstream_allowed={l17_downstream}",
        f"l18_selected_raw_ohlc_status={l18_status}", f"l18_current_chain_valid={l18_current}", f"l18_downstream_allowed={l18_downstream}",
        f"l19_candle_geometry_status={l19_status}", f"l19_current_chain_valid={l19_current}", f"l19_downstream_allowed={l19_downstream}",
        f"l13_runtime_enabled={'true' if enable_l13_runtime else 'false'}", f"l14_runtime_enabled={'true' if enable_l14_runtime else 'false'}",
        f"l15_runtime_enabled={'true' if enable_l15_runtime else 'false'}", f"l16_runtime_enabled={'true' if enable_l16_runtime else 'false'}",
        f"l17_runtime_enabled={'true' if enable_l17_runtime else 'false'}", f"l18_runtime_enabled={'true' if enable_l18_runtime else 'false'}",
        f"l19_runtime_enabled={'true' if enable_l19_runtime else 'false'}",
        f"result_latest_path={latest_path}", "authority=calculation_support_only", "candidate_pool_runtime=false",
        "deep_evidence_runtime=false", "global_top10_runtime=false", "selection_runtime=false", "trade_permission=false", "entry_signal=false", "execution=false", "",
    ])
    return atomic_write_text(_surface_epoch_manifest_path(root), text)


def _poll_snapshot(root: Path) -> Tuple[core.ValidationResult, Dict[str, str], List[str]]:
    return core.validate_snapshot(WorkerPaths.from_root(root))


def _run_core_once_with_layers(root: Path, worker_mode: str, enable_l13_runtime: bool = ENABLE_L13_RUNTIME, enable_l14_runtime: bool = ENABLE_L14_RUNTIME, enable_l15_runtime: bool = ENABLE_L15_RUNTIME, enable_l16_runtime: bool = ENABLE_L16_RUNTIME, enable_l17_runtime: bool = ENABLE_L17_RUNTIME, enable_l18_runtime: bool = ENABLE_L18_RUNTIME, enable_l19_runtime: bool = ENABLE_L19_RUNTIME) -> Tuple[int, core.ValidationResult]:
    start_ns = time.perf_counter_ns()
    code, res = core.run_once(root, worker_mode)
    duration_ms = max(0, (time.perf_counter_ns() - start_ns) // 1_000_000)
    dispatches = [
        ("l11", lambda: run_l11_after_render_index(root), True),
        ("l12", lambda: run_l12_after_l11(root), True),
        ("l13", lambda: run_l13_after_l12(root), enable_l13_runtime),
        ("l14", lambda: run_l14_after_l13(root), enable_l13_runtime and enable_l14_runtime),
        ("l15", lambda: run_l15_after_l14(root), enable_l13_runtime and enable_l14_runtime and enable_l15_runtime),
        ("l16", lambda: run_l16_after_l15(root), enable_l13_runtime and enable_l14_runtime and enable_l15_runtime and enable_l16_runtime),
        ("l17", lambda: run_l17_after_l16(root), enable_l13_runtime and enable_l14_runtime and enable_l15_runtime and enable_l16_runtime and enable_l17_runtime),
        ("l18", lambda: run_l18_after_l17(root, run_l19=enable_l19_runtime), enable_l13_runtime and enable_l14_runtime and enable_l15_runtime and enable_l16_runtime and enable_l17_runtime and enable_l18_runtime),
    ]
    for name, fn, enabled in dispatches:
        if not enabled:
            continue
        try:
            fn()
        except Exception as exc:
            core.gateway_record_exception(root, f"{name}_dispatch_exception", exc, {"worker_mode": worker_mode, "worker_version": core.WORKER_VERSION})
    return code, res


def run_shared_daemon_with_cycle_control(shared_root: Path, poll_seconds: float) -> int:
    poll_seconds = max(0.25, poll_seconds)
    loop = 0
    states: Dict[str, SnapshotCycleState] = {}
    while True:
        loop += 1
        roots = core.discover_roots(shared_root)
        results: List[Tuple[Path, int, core.ValidationResult]] = []
        now = unix_time()
        for idx, root in enumerate(roots):
            key = str(root)
            state = states.setdefault(key, SnapshotCycleState())
            try:
                polled_result, _header, _rows = _poll_snapshot(root)
                identity = _snapshot_identity(polled_result)
                if identity != state.identity:
                    state.identity = identity
                    state.first_seen_unix = now
                    state.retry_cycle_count = 0
                    state.last_action = "snapshot_identity_changed_waiting_for_debounce"
                    state.last_reason = "runtime1_snapshot_identity_changed"
                stable_age = max(0, now - state.first_seen_unix) if state.first_seen_unix > 0 else 0
                cycle_due = state.last_calculation_unix <= 0 or (now - state.last_calculation_unix) >= CALCULATION_CYCLE_SECONDS
                snapshot_stable = polled_result.ok and stable_age >= SNAPSHOT_STABLE_REQUIRED_SECONDS
                static_ok, static_reason, static_remaining = _accepted_epoch_static_state(root, polled_result, now)
                if snapshot_stable and static_ok:
                    code = state.last_exit_code if state.last_result is not None else 0
                    res = state.last_result if state.last_result is not None else polled_result
                    state.last_action = "calculation_cycle_skipped_static_accepted_epoch"
                    state.last_reason = f"{static_reason};remaining_seconds={static_remaining}"
                elif snapshot_stable and cycle_due:
                    code, res = _run_core_once_with_layers(root, "shared_validator_daemon_cycle_controlled")
                    state.last_calculation_unix = now
                    state.last_exit_code = code
                    state.last_result = res
                    accepted_written = _write_surface_epoch_if_accepted(root, res, ENABLE_L13_RUNTIME, ENABLE_L14_RUNTIME, ENABLE_L15_RUNTIME, ENABLE_L16_RUNTIME, ENABLE_L17_RUNTIME, ENABLE_L18_RUNTIME, ENABLE_L19_RUNTIME)
                    if accepted_written:
                        state.retry_cycle_count = 0
                        state.last_successful_core_epoch_id = f"{res.snapshot_id}|{res.payload_checksum}"
                    else:
                        state.retry_cycle_count = min(state.retry_cycle_limit, state.retry_cycle_count + 1)
                    state.last_action = "calculation_cycle_ran"
                    state.last_reason = "strict_accepted_epoch_created" if accepted_written else "cycle_completed_waiting_for_full_chain_accepted"
                elif snapshot_stable:
                    code = state.last_exit_code if state.last_result is not None else 0
                    res = state.last_result if state.last_result is not None else polled_result
                    state.last_action = "calculation_cycle_skipped_waiting_for_retry_timer"
                    state.last_reason = "snapshot_stable_but_retry_cycle_not_due"
                else:
                    code = state.last_exit_code if state.last_result is not None else 2
                    res = state.last_result if state.last_result is not None else polled_result
                    state.last_action = "calculation_cycle_skipped_waiting_for_snapshot_stability"
                    state.last_reason = "snapshot_not_stable_or_not_accepted"
                process_ok = core.write_process_status(root, "shared-daemon-cycle-controlled", loop, code, res, len(roots), idx)
                cycle_ok = _write_cycle_status(root, loop, state, res, state.last_action, state.last_reason)
                if not process_ok:
                    res = core.mark_write_failure(res, [WorkerPaths.from_root(root).status / "worker_process_status.txt"])
                    code = 3
                if not cycle_ok and code == 0:
                    res = core.mark_write_failure(res, [_cycle_status_path(root)])
                    code = 3
                results.append((root, code, res))
            except Exception as exc:
                core.gateway_record_exception(root, "gateway_cycle_control_exception", exc, {"worker_mode": "shared-daemon-cycle-controlled", "worker_version": core.WORKER_VERSION})
                res = core.ValidationResult(False, "exception", f"{type(exc).__name__}: {exc}")
                results.append((root, 1, res))
        core.write_shared_status(shared_root, loop, roots, results, status_mode="shared-daemon")
        time.sleep(poll_seconds)


def run_status_probe_light(shared_root: Path) -> int:
    roots = core.discover_roots(shared_root)
    results: List[Tuple[Path, int, core.ValidationResult]] = []
    write_failed = False
    for idx, root in enumerate(roots):
        res, _header, _rows = _poll_snapshot(root)
        code = 0 if res.ok else 2
        process_ok = core.write_process_status(root, "shared-status-probe-light", 1, code, res, len(roots), idx)
        if not process_ok:
            res = core.mark_write_failure(res, [WorkerPaths.from_root(root).status / "worker_process_status.txt"])
            code = 3
            write_failed = True
        results.append((root, code, res))
    ok = core.write_shared_status(shared_root, 1, roots, results, status_mode="shared_status_probe_light")
    return 0 if ok and not write_failed else 3


def run_repair_light(shared_root: Path, watchdog_mode: bool) -> int:
    roots = core.discover_roots(shared_root)
    results: List[Tuple[Path, int, core.ValidationResult]] = []
    write_failed = False
    for idx, root in enumerate(roots):
        res, _header, _rows = _poll_snapshot(root)
        code = 0 if res.ok else 2
        mode = "watchdog_probe" if watchdog_mode else "repair_probe"
        process_ok = core.write_process_status(root, mode, 1, code, res, len(roots), idx)
        if not process_ok:
            res = core.mark_write_failure(res, [WorkerPaths.from_root(root).status / "worker_process_status.txt"])
            code = 3
            write_failed = True
        results.append((root, code, res))
    daemon_registered, daemon_state = core._get_task_state(core.DAEMON_TASK_NAME)
    status_present, age = core._status_age(shared_root)
    worker_processes = core._proc_count("AuroraWorker")
    stale = (not status_present) or age < 0 or age > core.STATUS_MAX_AGE_SECONDS
    process_missing = worker_processes == "0"
    should_start = daemon_registered == "true" and (stale or process_missing or daemon_state.lower() != "running")
    reason_bits: List[str] = []
    if daemon_registered != "true": reason_bits.append("daemon_task_missing")
    if stale: reason_bits.append("shared_gateway_status_missing_or_stale")
    if process_missing: reason_bits.append("aurora_worker_process_missing")
    if daemon_state.lower() != "running": reason_bits.append("daemon_task_state_not_running")
    if write_failed: reason_bits.append("account_lifecycle_process_status_write_failed")
    if not reason_bits: reason_bits.append("daemon_status_fresh")
    attempted = "false"
    restart_result = "not_needed"
    action = "checked_no_restart_needed"
    repair_success = False
    if should_start:
        attempted = "true"
        ok, out = core._start_task(core.DAEMON_TASK_NAME)
        action = "start_daemon_task"
        restart_result = ("started_" + out) if ok else ("failed_" + out)
        time.sleep(3)
        status_present_after, age_after = core._status_age(shared_root)
        process_count_after = core._proc_count("AuroraWorker")
        repair_success = ok and (status_present_after and age_after >= 0 and age_after <= core.STATUS_MAX_AGE_SECONDS or process_count_after != "0")
    elif daemon_registered != "true":
        action = "cannot_repair_missing_daemon_task"
        restart_result = "failed_daemon_task_missing"
    proof = core.WatchdogProof(utc_stamp(), action, ";".join(reason_bits), attempted, restart_result)
    status_mode = "watchdog_probe" if watchdog_mode else "repair_probe"
    probe_ok = core.write_probe_status(shared_root, 1, roots, results, proof, repair_success, status_mode)
    return 0 if probe_ok and not write_failed and (restart_result.startswith("not_needed") or repair_success) else 2


def main(argv: List[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Aurora Gateway validator entrypoint")
    parser.add_argument("--root")
    parser.add_argument("--shared-root")
    parser.add_argument("--mode", choices=("once", "daemon", "shared-daemon"), default="once")
    parser.add_argument("--poll-seconds", type=float, default=1.0)
    parser.add_argument("--status", action="store_true")
    parser.add_argument("--repair", action="store_true")
    parser.add_argument("--watchdog", action="store_true")
    parser.add_argument("--install-global", action="store_true")
    parser.add_argument("--version", action="store_true")
    args, _unknown = parser.parse_known_args(argv)
    if args.version:
        print(core.WORKER_VERSION)
        return 0
    if args.install_global:
        return core.main(argv)
    if args.watchdog or args.repair:
        if not args.shared_root:
            raise SystemExit("--shared-root is required for watchdog/repair mode")
        return run_repair_light(Path(args.shared_root), args.watchdog)
    if args.status:
        if not args.shared_root:
            raise SystemExit("--shared-root is required for --status")
        return run_status_probe_light(Path(args.shared_root))
    if args.mode == "shared-daemon" and args.shared_root:
        return run_shared_daemon_with_cycle_control(Path(args.shared_root), args.poll_seconds)
    if args.root and args.mode == "once":
        root = Path(args.root)
        code, res = _run_core_once_with_layers(root, "validator_daemon_capable")
        process_ok = core.write_process_status(root, "once", 1, code, res)
        return code if process_ok else 3
    if args.root and args.mode == "daemon":
        root = Path(args.root)
        loop = 0
        while True:
            loop += 1
            code, res = _run_core_once_with_layers(root, "validator_daemon_capable")
            process_ok = core.write_process_status(root, "daemon", loop, code, res)
            if not process_ok:
                code = 3
            time.sleep(max(0.25, args.poll_seconds))
    return core.main(argv)


if __name__ == "__main__":
    raise SystemExit(main())
