from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Tuple
import argparse
import time

import aurora_worker as core
from aurora_worker_io import WorkerPaths, atomic_write_text, read_kv, unix_time, utc_stamp
from aurora_worker_l11_dispatch import run_l11_after_core
from aurora_worker_l12_dispatch import run_l12_after_l11

SNAPSHOT_STABLE_REQUIRED_SECONDS = 2
CALCULATION_CYCLE_SECONDS = 30
ACCEPTED_EPOCH_TTL_SECONDS = 120


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
        "schema_name=aurora_gateway_cycle_status",
        "schema_version=1",
        f"worker_version={core.WORKER_VERSION}",
        "mode=shared-daemon-cycle-controller",
        f"root={root}",
        f"loop_count={loop}",
        "poll_seconds=1",
        f"snapshot_stable_required_seconds={SNAPSHOT_STABLE_REQUIRED_SECONDS}",
        f"calculation_cycle_seconds={CALCULATION_CYCLE_SECONDS}",
        f"accepted_epoch_ttl_seconds={ACCEPTED_EPOCH_TTL_SECONDS}",
        f"snapshot_identity={state.identity}",
        f"snapshot_first_seen_unix={state.first_seen_unix}",
        f"snapshot_stable_age_seconds={stable_age}",
        f"last_calculation_unix={state.last_calculation_unix}",
        f"last_calculation_age_seconds={cycle_age}",
        f"last_exit_code={state.last_exit_code}",
        f"last_action={action}",
        f"last_reason={reason}",
        f"last_validation_status={result.status}",
        f"last_validation_reason={result.reason}",
        f"source_snapshot_id={result.snapshot_id}",
        f"source_payload_checksum={result.payload_checksum}",
        f"row_count={result.row_count}",
        f"generated_utc={utc_stamp()}",
        f"generated_unix={now}",
        "authority=calculation_support_only",
        "trade_permission=false",
        "selection_runtime=false",
        "entry_signal=false",
        "execution=false",
        "",
    ])


def _write_cycle_status(root: Path, loop: int, state: SnapshotCycleState, result: core.ValidationResult, action: str, reason: str) -> bool:
    return atomic_write_text(_cycle_status_path(root), _build_cycle_status(root, loop, state, result, action, reason))


def _write_surface_epoch_if_accepted(root: Path, result: core.ValidationResult) -> bool:
    latest_path = _result_latest_path(root)
    latest = read_kv(latest_path) if latest_path.exists() else {}
    l6_status = latest.get("l6_rank_status", "missing")
    l7_status = latest.get("l7_rank_status", "missing")
    l8_status = latest.get("l8_rank_status", "missing")
    l9_status = latest.get("l9_rank_status", "missing")
    l11_status = latest.get("l11_symbol_ranking_status", "missing")
    l12_status = latest.get("l12_group_heat_quality_status", "missing")
    all_complete = (
        result.ok
        and l6_status == "complete"
        and l7_status == "complete"
        and l8_status == "complete"
        and l9_status == "complete"
        and l11_status in {"accepted", "write_degraded"}
        and l12_status in {"accepted", "write_degraded"}
    )
    if not all_complete:
        return False
    accepted_unix = unix_time()
    epoch_id = "|".join([result.snapshot_id, result.payload_checksum, l6_status, l7_status, l8_status, l9_status, l11_status, l12_status])
    text = "\n".join([
        "schema_name=aurora_gateway_surface_accepted_epoch",
        "schema_version=3",
        f"worker_version={core.WORKER_VERSION}",
        "status=accepted",
        "epoch_status=accepted",
        "display_epoch_status=accepted_current",
        f"epoch_id={epoch_id}",
        f"source_snapshot_id={result.snapshot_id}",
        f"source_payload_checksum={result.payload_checksum}",
        f"source_job_id={result.job_id}",
        f"row_count={result.row_count}",
        f"accepted_unix={accepted_unix}",
        f"accepted_utc={utc_stamp()}",
        f"valid_until_unix={accepted_unix + ACCEPTED_EPOCH_TTL_SECONDS}",
        f"accepted_epoch_ttl_seconds={ACCEPTED_EPOCH_TTL_SECONDS}",
        f"l6_status={l6_status}",
        f"l7_status={l7_status}",
        f"l8_status={l8_status}",
        f"l9_status={l9_status}",
        f"l11_symbol_ranking_status={l11_status}",
        f"l12_group_heat_quality_status={l12_status}",
        f"result_latest_path={latest_path}",
        "authority=calculation_support_only",
        "trade_permission=false",
        "selection_runtime=false",
        "entry_signal=false",
        "execution=false",
        "",
    ])
    return atomic_write_text(_surface_epoch_manifest_path(root), text)


def _poll_snapshot(root: Path) -> Tuple[core.ValidationResult, Dict[str, str], List[str]]:
    return core.validate_snapshot(WorkerPaths.from_root(root))


def _run_core_once_with_l11_l12(root: Path, worker_mode: str) -> Tuple[int, core.ValidationResult]:
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
                    state.last_action = "snapshot_identity_changed_waiting_for_debounce"
                    state.last_reason = "runtime1_snapshot_identity_changed"
                stable_age = max(0, now - state.first_seen_unix) if state.first_seen_unix > 0 else 0
                cycle_due = state.last_calculation_unix <= 0 or (now - state.last_calculation_unix) >= CALCULATION_CYCLE_SECONDS
                snapshot_stable = polled_result.ok and stable_age >= SNAPSHOT_STABLE_REQUIRED_SECONDS
                if snapshot_stable and cycle_due:
                    code, res = _run_core_once_with_l11_l12(root, "shared_validator_daemon_cycle_controlled")
                    state.last_calculation_unix = now
                    state.last_exit_code = code
                    state.last_result = res
                    state.last_action = "calculation_cycle_ran"
                    state.last_reason = "snapshot_stable_and_cycle_due"
                    _write_surface_epoch_if_accepted(root, res)
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
    args, _unknown = parser.parse_known_args(argv)
    if args.install_global or args.watchdog or args.repair or args.status:
        return core.main(argv)
    if args.mode == "shared-daemon" and args.shared_root:
        return run_shared_daemon_with_cycle_control(Path(args.shared_root), args.poll_seconds)
    if args.root and args.mode == "once":
        root = Path(args.root)
        code, res = _run_core_once_with_l11_l12(root, "validator_daemon_capable")
        process_ok = core.write_process_status(root, "once", 1, code, res)
        return code if process_ok else 3
    if args.root and args.mode == "daemon":
        root = Path(args.root)
        loop = 0
        while True:
            loop += 1
            code, res = _run_core_once_with_l11_l12(root, "validator_daemon_capable")
            process_ok = core.write_process_status(root, "daemon", loop, code, res)
            if not process_ok:
                code = 3
            time.sleep(max(0.25, args.poll_seconds))
    return core.main(argv)


if __name__ == "__main__":
    raise SystemExit(main())
