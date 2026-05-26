from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Tuple
import argparse
import time

import aurora_worker as core
from aurora_worker_io import WorkerPaths, atomic_write_text, atomic_write_text_fast, read_kv, unix_time, utc_stamp
from aurora_worker_l11_dispatch import run_l11_after_core
from aurora_worker_l12_dispatch import run_l12_after_l11
from aurora_worker_l13_dispatch import run_l13_after_l12
from aurora_worker_l14_dispatch import run_l14_after_l13
from aurora_worker_l15_dispatch import run_l15_after_l14
from aurora_worker_l16_dispatch import run_l16_after_l15
from aurora_worker_l17_dispatch import run_l17_after_l16
from aurora_worker_l18_dispatch import run_l18_after_l17

SNAPSHOT_STABLE_REQUIRED_SECONDS = 0
CALCULATION_CYCLE_SECONDS = 0
ACCEPTED_EPOCH_TTL_SECONDS = 120
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


def _snapshot_identity(result: core.ValidationResult) -> str:
    return "|".join([result.server, result.account, result.snapshot_id, result.job_id, result.payload_checksum, str(result.row_count)])


def _surface_epoch_manifest_path(root: Path) -> Path:
    return WorkerPaths.from_root(root).outbox / "surface_accepted_epoch.manifest"


def _cycle_status_path(root: Path) -> Path:
    return WorkerPaths.from_root(root).status / "gateway_cycle_status.txt"


def _result_latest_path(root: Path) -> Path:
    return WorkerPaths.from_root(root).outbox / "result_latest.txt"


def _build_cycle_status(root: Path, loop: int, state: SnapshotCycleState, result: core.ValidationResult, action: str, reason: str) -> str:
    now = unix_time()
    stable_age = max(0, now - state.first_seen_unix) if state.first_seen_unix > 0 else 0
    cycle_age = max(0, now - state.last_calculation_unix) if state.last_calculation_unix > 0 else -1
    return "\n".join([
        "schema_name=aurora_gateway_cycle_status", "schema_version=2", f"worker_version={core.WORKER_VERSION}",
        "mode=shared-daemon-cycle-controller", f"root={root}", f"loop_count={loop}", "poll_seconds=1",
        f"snapshot_stable_required_seconds={SNAPSHOT_STABLE_REQUIRED_SECONDS}", f"calculation_cycle_seconds={CALCULATION_CYCLE_SECONDS}",
        f"accepted_epoch_ttl_seconds={ACCEPTED_EPOCH_TTL_SECONDS}", f"snapshot_identity={state.identity}",
        f"snapshot_first_seen_unix={state.first_seen_unix}", f"snapshot_stable_age_seconds={stable_age}",
        f"last_calculation_unix={state.last_calculation_unix}", f"last_calculation_age_seconds={cycle_age}",
        f"last_exit_code={state.last_exit_code}", f"last_action={action}", f"last_reason={reason}",
        f"last_validation_status={result.status}", f"last_validation_reason={result.reason}",
        f"source_snapshot_id={result.snapshot_id}", f"source_payload_checksum={result.payload_checksum}", f"row_count={result.row_count}",
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
    all_complete = (
        result.ok and l6_status == "complete" and l7_status == "complete" and l8_status == "complete" and l9_status == "complete"
        and l11_status in {"accepted", "write_degraded"}
        and l12_status in {"accepted", "write_degraded"}
        and ((l13_status in {"accepted", "write_degraded"}) if enable_l13_runtime else True)
        and ((l14_status in {"accepted", "write_degraded"}) if enable_l14_runtime else True)
        and ((l15_status in {"accepted", "degraded", "write_degraded"}) if enable_l15_runtime else True)
        and ((l16_status in {"accepted", "degraded", "write_degraded"}) if enable_l16_runtime else True)
        and ((l17_status in {"accepted", "degraded", "write_degraded"}) if enable_l17_runtime else True)
        and ((l18_status in {"accepted", "degraded", "partial", "write_degraded"}) if enable_l18_runtime else True)
        and ((l19_status in {"accepted", "degraded", "partial", "write_degraded"}) if enable_l19_runtime else True)
    )
    if not all_complete:
        return False
    accepted_unix = unix_time()
    epoch_id = "|".join([result.snapshot_id, result.payload_checksum, l6_status, l7_status, l8_status, l9_status, l11_status, l12_status, l13_status, l14_status, l15_status, l16_status, l17_status, l18_status, l19_status])
    text = "\n".join([
        "schema_name=aurora_gateway_surface_accepted_epoch", "schema_version=10", f"worker_version={core.WORKER_VERSION}",
        "status=accepted", "epoch_status=accepted", "display_epoch_status=accepted_current", f"epoch_id={epoch_id}",
        f"source_snapshot_id={result.snapshot_id}", f"source_payload_checksum={result.payload_checksum}", f"source_job_id={result.job_id}",
        f"row_count={result.row_count}", f"accepted_unix={accepted_unix}", f"accepted_utc={utc_stamp()}",
        f"valid_until_unix={accepted_unix + ACCEPTED_EPOCH_TTL_SECONDS}", f"accepted_epoch_ttl_seconds={ACCEPTED_EPOCH_TTL_SECONDS}",
        f"l6_status={l6_status}", f"l7_status={l7_status}", f"l8_status={l8_status}", f"l9_status={l9_status}",
        f"l11_symbol_ranking_status={l11_status}", f"l12_group_heat_quality_status={l12_status}",
        f"l13_dynamic_group_selection_status={l13_status}", f"l14_candidate_pool_status={l14_status}",
        f"l15_correlation_diversity_status={l15_status}", f"l16_global_top10_status={l16_status}",
        f"l17_deep_evidence_selection_status={l17_status}", f"l18_selected_raw_ohlc_status={l18_status}",
        f"l19_candle_geometry_status={l19_status}",
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


def _run_core_once_with_l11_l12_l13_l14_l15_l16_l17_l18(root: Path, worker_mode: str, enable_l13_runtime: bool = ENABLE_L13_RUNTIME, enable_l14_runtime: bool = ENABLE_L14_RUNTIME, enable_l15_runtime: bool = ENABLE_L15_RUNTIME, enable_l16_runtime: bool = ENABLE_L16_RUNTIME, enable_l17_runtime: bool = ENABLE_L17_RUNTIME, enable_l18_runtime: bool = ENABLE_L18_RUNTIME, enable_l19_runtime: bool = ENABLE_L19_RUNTIME) -> Tuple[int, core.ValidationResult]:
    start_ns = time.perf_counter_ns()
    code, res = core.run_once(root, worker_mode)
    duration_ms = max(0, (time.perf_counter_ns() - start_ns) // 1_000_000)
    try:
        run_l11_after_core(root, duration_ms)
    except Exception as exc:
        core.gateway_record_exception(root, "l11_dispatch_exception", exc, {"worker_mode": worker_mode, "worker_version": core.WORKER_VERSION})
    try:
        run_l12_after_l11(root)
    except Exception as exc:
        core.gateway_record_exception(root, "l12_dispatch_exception", exc, {"worker_mode": worker_mode, "worker_version": core.WORKER_VERSION})
    if enable_l13_runtime:
        try:
            run_l13_after_l12(root)
        except Exception as exc:
            core.gateway_record_exception(root, "l13_dispatch_exception", exc, {"worker_mode": worker_mode, "worker_version": core.WORKER_VERSION})
    if enable_l13_runtime and enable_l14_runtime:
        try:
            run_l14_after_l13(root)
        except Exception as exc:
            core.gateway_record_exception(root, "l14_dispatch_exception", exc, {"worker_mode": worker_mode, "worker_version": core.WORKER_VERSION})
    if enable_l13_runtime and enable_l14_runtime and enable_l15_runtime:
        try:
            run_l15_after_l14(root)
        except Exception as exc:
            core.gateway_record_exception(root, "l15_dispatch_exception", exc, {"worker_mode": worker_mode, "worker_version": core.WORKER_VERSION})
    if enable_l13_runtime and enable_l14_runtime and enable_l15_runtime and enable_l16_runtime:
        try:
            run_l16_after_l15(root)
        except Exception as exc:
            core.gateway_record_exception(root, "l16_dispatch_exception", exc, {"worker_mode": worker_mode, "worker_version": core.WORKER_VERSION})
    if enable_l13_runtime and enable_l14_runtime and enable_l15_runtime and enable_l16_runtime and enable_l17_runtime:
        try:
            run_l17_after_l16(root)
        except Exception as exc:
            core.gateway_record_exception(root, "l17_dispatch_exception", exc, {"worker_mode": worker_mode, "worker_version": core.WORKER_VERSION})
    if enable_l13_runtime and enable_l14_runtime and enable_l15_runtime and enable_l16_runtime and enable_l17_runtime and enable_l18_runtime:
        try:
            run_l18_after_l17(root, run_l19=enable_l19_runtime)
        except Exception as exc:
            core.gateway_record_exception(root, "l18_dispatch_exception", exc, {"worker_mode": worker_mode, "worker_version": core.WORKER_VERSION})
    return code, res


def _run_core_once_with_l11_l12_l13_l14_l15_l16_l17(root: Path, worker_mode: str, enable_l13_runtime: bool = ENABLE_L13_RUNTIME, enable_l14_runtime: bool = ENABLE_L14_RUNTIME, enable_l15_runtime: bool = ENABLE_L15_RUNTIME, enable_l16_runtime: bool = ENABLE_L16_RUNTIME, enable_l17_runtime: bool = ENABLE_L17_RUNTIME) -> Tuple[int, core.ValidationResult]:
    return _run_core_once_with_l11_l12_l13_l14_l15_l16_l17_l18(root, worker_mode, enable_l13_runtime, enable_l14_runtime, enable_l15_runtime, enable_l16_runtime, enable_l17_runtime, ENABLE_L18_RUNTIME, ENABLE_L19_RUNTIME)


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
                    state.last_action = "snapshot_identity_changed_waiting_for_debounce"
                    state.last_reason = "runtime1_snapshot_identity_changed"
                stable_age = max(0, now - state.first_seen_unix) if state.first_seen_unix > 0 else 0
                cycle_due = state.last_calculation_unix <= 0 or (now - state.last_calculation_unix) >= CALCULATION_CYCLE_SECONDS
                snapshot_stable = polled_result.ok and stable_age >= SNAPSHOT_STABLE_REQUIRED_SECONDS
                if snapshot_stable and cycle_due:
                    code, res = _run_core_once_with_l11_l12_l13_l14_l15_l16_l17_l18(root, "shared_validator_daemon_cycle_controlled")
                    state.last_calculation_unix = now
                    state.last_exit_code = code
                    state.last_result = res
                    state.last_action = "calculation_cycle_ran"
                    state.last_reason = "snapshot_stable_and_cycle_due"
                    _write_surface_epoch_if_accepted(root, res, ENABLE_L13_RUNTIME, ENABLE_L14_RUNTIME, ENABLE_L15_RUNTIME, ENABLE_L16_RUNTIME, ENABLE_L17_RUNTIME, ENABLE_L18_RUNTIME, ENABLE_L19_RUNTIME)
                elif snapshot_stable:
                    code = state.last_exit_code if state.last_result is not None else 0
                    res = state.last_result if state.last_result is not None else polled_result
                    state.last_action = "calculation_cycle_skipped_waiting_for_timer"
                    state.last_reason = "snapshot_stable_but_cycle_not_due"
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


def run_status_probe_with_layers(shared_root: Path) -> int:
    roots = core.discover_roots(shared_root)
    results: List[Tuple[Path, int, core.ValidationResult]] = []
    write_failed = False
    for idx, root in enumerate(roots):
        code, res = _run_core_once_with_l11_l12_l13_l14_l15_l16_l17_l18(root, "shared_status_probe")
        process_ok = core.write_process_status(root, "shared-status-probe", 1, code, res, len(roots), idx)
        if not process_ok:
            res = core.mark_write_failure(res, [WorkerPaths.from_root(root).status / "worker_process_status.txt"])
            code = 3
            write_failed = True
        results.append((root, code, res))
    ok = core.write_shared_status(shared_root, 1, roots, results, status_mode="shared_status_probe")
    return 0 if ok and not write_failed else 3


def run_repair_with_layers(shared_root: Path, watchdog_mode: bool) -> int:
    roots = core.discover_roots(shared_root)
    results: List[Tuple[Path, int, core.ValidationResult]] = []
    write_failed = False
    for idx, root in enumerate(roots):
        mode = "watchdog_probe" if watchdog_mode else "repair_probe"
        code, res = _run_core_once_with_l11_l12_l13_l14_l15_l16_l17_l18(root, mode)
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
    probe_mode = "watchdog_probe" if watchdog_mode else "repair_probe"
    probe_ok = core.write_probe_status(shared_root, 1, roots, results, proof, repair_success, probe_mode)
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
        return run_repair_with_layers(Path(args.shared_root), args.watchdog)
    if args.status:
        if not args.shared_root:
            raise SystemExit("--shared-root is required for --status")
        return run_status_probe_with_layers(Path(args.shared_root))
    if args.mode == "shared-daemon" and args.shared_root:
        return run_shared_daemon_with_cycle_control(Path(args.shared_root), args.poll_seconds)
    if args.root and args.mode == "once":
        root = Path(args.root)
        code, res = _run_core_once_with_l11_l12_l13_l14_l15_l16_l17_l18(root, "validator_daemon_capable")
        process_ok = core.write_process_status(root, "once", 1, code, res)
        return code if process_ok else 3
    if args.root and args.mode == "daemon":
        root = Path(args.root)
        loop = 0
        while True:
            loop += 1
            code, res = _run_core_once_with_l11_l12_l13_l14_l15_l16_l17_l18(root, "validator_daemon_capable")
            process_ok = core.write_process_status(root, "daemon", loop, code, res)
            if not process_ok:
                code = 3
            time.sleep(max(0.25, args.poll_seconds))
    return core.main(argv)


if __name__ == "__main__":
    raise SystemExit(main())
