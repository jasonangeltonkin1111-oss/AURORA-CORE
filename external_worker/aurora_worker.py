from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Tuple
import argparse
import ctypes
import os
import subprocess
import time
import traceback

from aurora_worker_io import (
    GATEWAY_FOLDER_NAME,
    WorkerPaths,
    atomic_write_text,
    payload_checksum,
    read_kv,
    read_text,
    split_snapshot,
    unix_time,
    utc_stamp,
)
from aurora_worker_l6_friction import publish_l6_cost_friction_rankings
from aurora_worker_l7_session import publish_l7_session_relevance_rankings
from aurora_worker_l8_movement import publish_l8_movement_range_rankings
from aurora_worker_l9_structure import publish_l9_structure_location_rankings
from aurora_worker_recorder import gateway_record_event, gateway_record_exception

WORKER_VERSION = "0.6.9_l9_structure_location_sidecar"
EXPECTED_AUTHORITY = "calculation_support_only"
PROCESS_START_UNIX = unix_time()
PROCESS_START_UTC = utc_stamp()
PROCESS_ID = os.getpid()
DAEMON_TASK_NAME = "AuroraWorker_Global"
WATCHDOG_TASK_NAME = "AuroraWorker_Global_Watchdog"
STATUS_MAX_AGE_SECONDS = 75


@dataclass
class ValidationResult:
    ok: bool
    status: str
    reason: str
    snapshot_id: str = "not_available"
    row_count: int = 0
    payload_checksum: str = "not_available"
    server: str = "not_available"
    account: str = "not_available"
    job_bus_schema_version: str = "not_available"
    job_id: str = "not_available"
    job_type: str = "not_available"
    job_resource_class: str = "not_available"
    job_max_runtime_ms: str = "not_available"


@dataclass
class WatchdogProof:
    last_check_utc: str = "not_available"
    last_action: str = "not_checked"
    last_reason: str = "not_available"
    restart_attempted: str = "false"
    restart_result: str = "not_available"


def shared_gateway_status_path(shared_root: Path) -> Path:
    return shared_root / GATEWAY_FOLDER_NAME / "Status" / "shared_worker_status.txt"


def watchdog_gateway_status_path(shared_root: Path) -> Path:
    return shared_root / GATEWAY_FOLDER_NAME / "Status" / "watchdog_status.txt"


def repair_gateway_status_path(shared_root: Path) -> Path:
    return shared_root / GATEWAY_FOLDER_NAME / "Status" / "repair_status.txt"


def _result_from_header(ok: bool, status: str, reason: str, header: Dict[str, str], row_count: int = 0, checksum: str = "not_available") -> ValidationResult:
    return ValidationResult(
        ok=ok,
        status=status,
        reason=reason,
        snapshot_id=header.get("snapshot_id", "not_available"),
        row_count=row_count,
        payload_checksum=checksum,
        server=header.get("server", "not_available"),
        account=header.get("account", "not_available"),
        job_bus_schema_version=header.get("job_bus_schema_version", "not_available"),
        job_id=header.get("job_id", "not_available"),
        job_type=header.get("job_type", "not_available"),
        job_resource_class=header.get("job_resource_class", "not_available"),
        job_max_runtime_ms=header.get("job_max_runtime_ms", "not_available"),
    )


def validate_snapshot(paths: WorkerPaths) -> Tuple[ValidationResult, Dict[str, str], List[str]]:
    required_path = paths.control / "worker_required.txt"
    snapshot_path = paths.inbox / "snapshot_latest.txt"
    manifest_path = paths.inbox / "snapshot_latest.manifest"
    if not required_path.exists():
        return ValidationResult(False, "rejected", "missing worker_required.txt"), {}, []
    if not snapshot_path.exists():
        return ValidationResult(False, "rejected", "missing snapshot_latest.txt"), {}, []
    if not manifest_path.exists():
        return ValidationResult(False, "rejected", "missing snapshot_latest.manifest"), {}, []
    required = read_kv(required_path)
    manifest = read_kv(manifest_path)
    snapshot_header, snapshot_rows = split_snapshot(read_text(snapshot_path))
    snapshot_id = snapshot_header.get("snapshot_id", manifest.get("snapshot_id", "not_available"))
    snapshot_header.setdefault("snapshot_id", snapshot_id)
    server = snapshot_header.get("server", "not_available")
    account = snapshot_header.get("account", "not_available")
    expected_server = required.get("server", "")
    expected_account = required.get("account", "")
    if expected_server and server != expected_server:
        return _result_from_header(False, "rejected", f"server mismatch snapshot={server} required={expected_server}", snapshot_header), snapshot_header, snapshot_rows
    if expected_account and account != expected_account:
        return _result_from_header(False, "rejected", f"account mismatch snapshot={account} required={expected_account}", snapshot_header), snapshot_header, snapshot_rows
    if snapshot_header.get("authority") != EXPECTED_AUTHORITY or manifest.get("authority") != EXPECTED_AUTHORITY:
        return _result_from_header(False, "rejected", "authority is not calculation_support_only", snapshot_header), snapshot_header, snapshot_rows
    if snapshot_header.get("trade_permission") != "false" or manifest.get("trade_permission") != "false":
        return _result_from_header(False, "rejected", "trade_permission must remain false", snapshot_header), snapshot_header, snapshot_rows

    header_job_id = snapshot_header.get("job_id", "not_available")
    manifest_job_id = manifest.get("job_id", "not_available")
    header_job_type = snapshot_header.get("job_type", "not_available")
    manifest_job_type = manifest.get("job_type", "not_available")
    header_job_bus = snapshot_header.get("job_bus_schema_version", "not_available")
    manifest_job_bus = manifest.get("job_bus_schema_version", "not_available")
    if header_job_id == "not_available" or manifest_job_id == "not_available":
        return _result_from_header(False, "rejected", "job_id missing from snapshot or manifest", snapshot_header), snapshot_header, snapshot_rows
    if header_job_id != manifest_job_id:
        return _result_from_header(False, "rejected", f"job_id mismatch header={header_job_id} manifest={manifest_job_id}", snapshot_header), snapshot_header, snapshot_rows
    if header_job_type == "not_available" or manifest_job_type == "not_available" or header_job_type != manifest_job_type:
        return _result_from_header(False, "rejected", "job_type mismatch between snapshot and manifest", snapshot_header), snapshot_header, snapshot_rows
    if header_job_bus == "not_available" or manifest_job_bus == "not_available" or header_job_bus != manifest_job_bus:
        return _result_from_header(False, "rejected", "job_bus_schema_version mismatch between snapshot and manifest", snapshot_header), snapshot_header, snapshot_rows

    manifest_rows = int(manifest.get("row_count", "-1"))
    header_rows = int(snapshot_header.get("row_count", "-1"))
    data_rows = max(0, len(snapshot_rows) - 1)
    if manifest_rows != data_rows or header_rows != data_rows:
        return _result_from_header(False, "rejected", f"row_count mismatch header={header_rows} manifest={manifest_rows} actual={data_rows}", snapshot_header, data_rows), snapshot_header, snapshot_rows
    calculated_checksum = payload_checksum(snapshot_rows)
    expected_checksum = manifest.get("payload_checksum", snapshot_header.get("payload_checksum", ""))
    if calculated_checksum != expected_checksum:
        return _result_from_header(False, "rejected", f"payload checksum mismatch expected={expected_checksum} calculated={calculated_checksum}", snapshot_header, data_rows, calculated_checksum), snapshot_header, snapshot_rows
    return _result_from_header(True, "accepted", "R3 snapshot validation envelope accepted", snapshot_header, data_rows, calculated_checksum), snapshot_header, snapshot_rows


def mark_write_failure(result: ValidationResult, failed_paths: List[Path]) -> ValidationResult:
    paths = ";".join(str(p) for p in failed_paths)
    return ValidationResult(
        ok=False,
        status="write_degraded",
        reason=f"atomic write failed for published worker output path(s): {paths}",
        snapshot_id=result.snapshot_id,
        row_count=result.row_count,
        payload_checksum=result.payload_checksum,
        server=result.server,
        account=result.account,
        job_bus_schema_version=result.job_bus_schema_version,
        job_id=result.job_id,
        job_type=result.job_type,
        job_resource_class=result.job_resource_class,
        job_max_runtime_ms=result.job_max_runtime_ms,
    )


def _record_gateway_result(root: Path, result: ValidationResult, worker_mode: str, exit_code: int, l6_summary, l6_duration_ms: int, l6_reused_existing_outputs: bool, l7_summary, l7_duration_ms: int, l8_summary, l8_duration_ms: int, l9_summary, l9_duration_ms: int, event_status: str) -> None:
    gateway_record_event(
        root,
        "gateway_result_boundary",
        {
            "event_status": event_status,
            "worker_version": WORKER_VERSION,
            "worker_mode": worker_mode,
            "exit_code": exit_code,
            "result_status": "complete" if result.ok else "rejected",
            "validation_status": result.status,
            "validation_reason": result.reason,
            "snapshot_id": result.snapshot_id,
            "job_id": result.job_id,
            "job_type": result.job_type,
            "row_count": result.row_count,
            "payload_checksum": result.payload_checksum,
            "server": result.server,
            "account": result.account,
            "l6_rank_status": l6_summary.status,
            "l6_rank_reason": l6_summary.reason,
            "l6_rank_input_count": l6_summary.input_count,
            "l6_rank_row_count": l6_summary.row_count,
            "l6_rank_duration_ms": l6_duration_ms,
            "l6_rank_reused_existing_outputs": "true" if l6_reused_existing_outputs else "false",
            "l7_rank_status": l7_summary.status,
            "l7_rank_reason": l7_summary.reason,
            "l7_rank_input_count": l7_summary.input_count,
            "l7_rank_row_count": l7_summary.row_count,
            "l7_rank_duration_ms": l7_duration_ms,
            "l8_rank_status": l8_summary.status,
            "l8_rank_reason": l8_summary.reason,
            "l8_rank_input_count": l8_summary.input_count,
            "l8_rank_row_count": l8_summary.row_count,
            "l8_rank_duration_ms": l8_duration_ms,
            "l9_rank_status": l9_summary.status,
            "l9_rank_reason": l9_summary.reason,
            "l9_rank_input_count": l9_summary.input_count,
            "l9_rank_row_count": l9_summary.row_count,
            "l9_rank_duration_ms": l9_duration_ms,
        },
        signature_fields=("event_status", "snapshot_id", "job_id", "result_status", "l6_rank_status", "l6_rank_reused_existing_outputs", "l7_rank_status", "l8_rank_status", "l9_rank_status"),
    )


def build_heartbeat(result: ValidationResult, worker_mode: str) -> str:
    now_unix = unix_time()
    return "\n".join([
        "schema_name=aurora_worker_heartbeat", "schema_version=4", f"worker_version={WORKER_VERSION}",
        f"worker_mode={worker_mode}", f"worker_status={'alive' if result.ok else 'alive_degraded'}",
        f"last_validation_status={result.status}", f"last_validation_reason={result.reason}",
        f"last_snapshot_id={result.snapshot_id}", f"last_job_bus_schema_version={result.job_bus_schema_version}",
        f"last_job_id={result.job_id}", f"last_job_type={result.job_type}",
        f"server={result.server}", f"account={result.account}",
        f"row_count={result.row_count}", f"payload_checksum={result.payload_checksum}",
        f"generated_utc={utc_stamp()}", f"generated_unix={now_unix}",
        "authority=calculation_support_only", "trade_permission=false", ""
    ])


def build_result(result: ValidationResult, rows: List[str], worker_mode: str) -> str:
    open_count = closed_count = l4_ready_count = stale_or_missing = 0
    for raw in rows[1:] if rows else []:
        parts = raw.split("|")
        if len(parts) < 13:
            continue
        open_count += 1 if parts[1] == "open" else 0
        closed_count += 1 if parts[1] == "closed" else 0
        l4_ready_count += 1 if parts[3] == "true" else 0
        stale_or_missing += 1 if parts[4] in {"Missing Tick", "Stale", "not_available"} else 0
    job_status = "complete" if result.ok else "rejected"
    return "\n".join([
        "schema_name=aurora_worker_result", "schema_version=5", f"worker_version={WORKER_VERSION}",
        f"worker_mode={worker_mode}", "authority=calculation_support_only", "trade_permission=false",
        f"source_snapshot_id={result.snapshot_id}", f"job_bus_schema_version={result.job_bus_schema_version}",
        f"job_id={result.job_id}", f"job_type={result.job_type}", f"job_resource_class={result.job_resource_class}",
        f"job_max_runtime_ms={result.job_max_runtime_ms}", f"job_status={job_status}",
        f"result_status={'complete' if result.ok else 'rejected'}", f"result_reason={result.reason}",
        f"row_count={result.row_count}", f"open_count={open_count}", f"closed_count={closed_count}",
        f"l4_ready_count={l4_ready_count}", f"stale_or_missing_quote_rows={stale_or_missing}",
        f"payload_checksum={result.payload_checksum}", f"generated_utc={utc_stamp()}", f"generated_unix={unix_time()}",
        "notes=r3_snapshot_validation_plus_l6_l7_l8_l9_surface_rankings_no_layer5_advisory_no_selection_no_permission_no_broker_polling", ""
    ])


def build_result_manifest(result: ValidationResult, result_text: str) -> str:
    job_status = "complete" if result.ok else "rejected"
    return "\n".join([
        "schema_name=aurora_worker_result_manifest", "schema_version=5", f"worker_version={WORKER_VERSION}",
        f"source_snapshot_id={result.snapshot_id}", f"job_bus_schema_version={result.job_bus_schema_version}",
        f"job_id={result.job_id}", f"job_type={result.job_type}", f"job_resource_class={result.job_resource_class}",
        f"job_max_runtime_ms={result.job_max_runtime_ms}", f"job_status={job_status}",
        f"result_status={'complete' if result.ok else 'rejected'}", f"result_reason={result.reason}",
        f"row_count={result.row_count}", f"payload_checksum={result.payload_checksum}",
        f"result_size={len(result_text.encode('utf-8'))}", "authority=calculation_support_only", "trade_permission=false",
        "result_scope=r3_snapshot_validation_plus_l6_l7_l8_l9_surface_rankings_no_layer5_advisory_no_selection_no_permission", f"generated_utc={utc_stamp()}", f"generated_unix={unix_time()}", ""
    ])


def build_process_status(root: Path, mode: str, loop_count: int, last_run_exit_code: int, result: ValidationResult | None, root_count: int = 1, active_root_index: int = 0) -> str:
    r = result or ValidationResult(False, "not_available", "no validation result yet")
    now = unix_time()
    return "\n".join([
        "schema_name=aurora_worker_process_status", "schema_version=4", f"worker_version={WORKER_VERSION}",
        f"process_id={PROCESS_ID}", f"mode={mode}", f"root={root}", f"root_count={root_count}",
        f"active_root_index={active_root_index}", f"process_start_utc={PROCESS_START_UTC}",
        f"process_start_unix={PROCESS_START_UNIX}", f"last_loop_utc={utc_stamp()}", f"last_loop_unix={now}",
        f"loop_count={loop_count}", f"last_run_exit_code={last_run_exit_code}",
        f"last_validation_status={r.status}", f"last_validation_reason={r.reason}",
        f"last_snapshot_id={r.snapshot_id}", f"last_job_id={r.job_id}", f"last_job_type={r.job_type}",
        f"row_count={r.row_count}", f"payload_checksum={r.payload_checksum}",
        "last_exception_type=none", "last_exception=none", "authority=calculation_support_only", "trade_permission=false",
        f"generated_utc={utc_stamp()}", f"generated_unix={now}", ""
    ])


def write_process_status(root: Path, mode: str, loop_count: int, last_run_exit_code: int, result: ValidationResult | None, root_count: int = 1, active_root_index: int = 0) -> bool:
    p = WorkerPaths.from_root(root)
    p.ensure()
    return atomic_write_text(p.status / "worker_process_status.txt", build_process_status(root, mode, loop_count, last_run_exit_code, result, root_count, active_root_index))


def _append_rank_lines(result_text: str, layer: str, summary, duration_ms: int, extra: List[Tuple[str, str]] | None = None) -> str:
    prefix = layer.lower()
    result_text += f"{prefix}_rank_status=" + summary.status + "\n"
    result_text += f"{prefix}_rank_reason=" + summary.reason + "\n"
    result_text += f"{prefix}_rank_input_count=" + str(summary.input_count) + "\n"
    result_text += f"{prefix}_rank_row_count=" + str(summary.row_count) + "\n"
    result_text += f"{prefix}_rank_duration_ms=" + str(duration_ms) + "\n"
    result_text += f"{prefix}_rank_instrumentation_schema=1\n"
    result_text += f"{prefix}_ranked_csv_path=" + summary.ranked_csv_path + "\n"
    if extra:
        for key, value in extra:
            result_text += key + "=" + value + "\n"
    return result_text


def run_once(root: Path, worker_mode: str = "validator_daemon_capable") -> Tuple[int, ValidationResult]:
    p = WorkerPaths.from_root(root)
    p.ensure()
    try:
        result, _h, rows = validate_snapshot(p)
        l6_start_ns = time.perf_counter_ns()
        l6_summary = publish_l6_cost_friction_rankings(p.outbox)
        l6_duration_ms = max(0, (time.perf_counter_ns() - l6_start_ns) // 1_000_000)
        l6_reused_existing_outputs = l6_summary.reason.startswith("skipped_unchanged_input_reused_existing_ranked_outputs;")
        l7_start_ns = time.perf_counter_ns()
        l7_summary = publish_l7_session_relevance_rankings(p.outbox)
        l7_duration_ms = max(0, (time.perf_counter_ns() - l7_start_ns) // 1_000_000)
        l8_start_ns = time.perf_counter_ns()
        l8_summary = publish_l8_movement_range_rankings(p.outbox)
        l8_duration_ms = max(0, (time.perf_counter_ns() - l8_start_ns) // 1_000_000)
        l9_start_ns = time.perf_counter_ns()
        l9_summary = publish_l9_structure_location_rankings(p.outbox)
        l9_duration_ms = max(0, (time.perf_counter_ns() - l9_start_ns) // 1_000_000)
        result_text = build_result(result, rows, worker_mode)
        result_text = _append_rank_lines(result_text, "l6", l6_summary, l6_duration_ms, [("l6_rank_reused_existing_outputs", "true" if l6_reused_existing_outputs else "false")])
        result_text = _append_rank_lines(result_text, "l7", l7_summary, l7_duration_ms)
        result_text = _append_rank_lines(result_text, "l8", l8_summary, l8_duration_ms)
        result_text = _append_rank_lines(result_text, "l9", l9_summary, l9_duration_ms)
        manifest_text = build_result_manifest(result, result_text)
        write_targets: List[Tuple[Path, str]] = [
            (p.status / "worker_heartbeat.txt", build_heartbeat(result, worker_mode)),
            (p.outbox / "result_latest.txt", result_text),
            (p.outbox / "result_latest.manifest", manifest_text),
        ]
        failed_paths: List[Path] = []
        for target, text in write_targets:
            if not atomic_write_text(target, text):
                failed_paths.append(target)
        if failed_paths:
            degraded = mark_write_failure(result, failed_paths)
            atomic_write_text(p.status / "worker_heartbeat.txt", build_heartbeat(degraded, worker_mode))
            _record_gateway_result(root, degraded, worker_mode, 3, l6_summary, l6_duration_ms, l6_reused_existing_outputs, l7_summary, l7_duration_ms, l8_summary, l8_duration_ms, l9_summary, l9_duration_ms, "write_degraded")
            return 3, degraded
        exit_code = 0 if result.ok else 2
        _record_gateway_result(root, result, worker_mode, exit_code, l6_summary, l6_duration_ms, l6_reused_existing_outputs, l7_summary, l7_duration_ms, l8_summary, l8_duration_ms, l9_summary, l9_duration_ms, "published")
        return exit_code, result
    except Exception as exc:
        error_text = "\n".join([
            "schema_name=aurora_worker_error", "schema_version=2", f"worker_version={WORKER_VERSION}",
            f"error={type(exc).__name__}: {exc}", "traceback=", traceback.format_exc(),
            f"generated_utc={utc_stamp()}", f"generated_unix={unix_time()}",
            "authority=calculation_support_only", "trade_permission=false", ""
        ])
        atomic_write_text(p.logs / "worker_errors.txt", error_text)
        atomic_write_text(p.status / "worker_heartbeat.txt", error_text)
        gateway_record_exception(root, "gateway_run_once_exception", exc, {"worker_mode": worker_mode, "worker_version": WORKER_VERSION})
        return 1, ValidationResult(False, "exception", f"{type(exc).__name__}: {exc}")


def discover_roots(shared_root: Path) -> List[Path]:
    roots: List[Path] = []
    if shared_root.exists():
        for server in sorted(shared_root.iterdir()):
            if server.is_dir() and server.name not in {GATEWAY_FOLDER_NAME, "External Worker"}:
                for account in sorted(server.iterdir()):
                    if account.is_dir() and (account / "Workbench" / GATEWAY_FOLDER_NAME / "Control" / "worker_required.txt").exists():
                        roots.append(account)
    return roots


def _powershell(command: str, timeout: int = 8) -> Tuple[bool, str]:
    try:
        kwargs = {"text": True, "stderr": subprocess.STDOUT, "timeout": timeout}
        if os.name == "nt":
            startupinfo = subprocess.STARTUPINFO()
            startupinfo.dwFlags |= subprocess.STARTF_USESHOWWINDOW
            startupinfo.wShowWindow = 0
            kwargs["startupinfo"] = startupinfo
            kwargs["creationflags"] = getattr(subprocess, "CREATE_NO_WINDOW", 0)
        out = subprocess.check_output(["powershell", "-NoProfile", "-WindowStyle", "Hidden", "-ExecutionPolicy", "Bypass", "-Command", command], **kwargs).strip()
        return True, out
    except Exception as exc:
        return False, str(exc).replace("\r", " ").replace("\n", " ")


def _get_task_state(task_name: str) -> Tuple[str, str]:
    ok, out = _powershell(f"(Get-ScheduledTask -TaskName '{task_name}' -ErrorAction Stop).State.ToString()")
    return ("true", out or "unknown") if ok else ("false", "not_registered")


def _start_task(task_name: str) -> Tuple[bool, str]:
    ok, out = _powershell(f"Start-ScheduledTask -TaskName '{task_name}' -ErrorAction Stop; Start-Sleep -Seconds 2; (Get-ScheduledTask -TaskName '{task_name}' -ErrorAction Stop).State.ToString()", timeout=15)
    return ok, out or ("started" if ok else "start_failed")


def _proc_count(name: str) -> str:
    ok, out = _powershell(f"@(Get-Process -Name '{name}' -ErrorAction SilentlyContinue).Count")
    return out or "0" if ok else "not_available"


def _windows_memory() -> Tuple[str, str, str]:
    class MEMORYSTATUSEX(ctypes.Structure):
        _fields_ = [
            ("dwLength", ctypes.c_ulong), ("dwMemoryLoad", ctypes.c_ulong), ("ullTotalPhys", ctypes.c_ulonglong),
            ("ullAvailPhys", ctypes.c_ulonglong), ("ullTotalPageFile", ctypes.c_ulonglong), ("ullAvailPageFile", ctypes.c_ulonglong),
            ("ullTotalVirtual", ctypes.c_ulonglong), ("ullAvailVirtual", ctypes.c_ulonglong), ("ullAvailExtendedVirtual", ctypes.c_ulonglong),
        ]
    try:
        stat = MEMORYSTATUSEX()
        stat.dwLength = ctypes.sizeof(MEMORYSTATUSEX)
        if ctypes.windll.kernel32.GlobalMemoryStatusEx(ctypes.byref(stat)):
            return str(int(stat.ullTotalPhys / (1024 * 1024))), str(int(stat.ullAvailPhys / (1024 * 1024))), str(int(stat.dwMemoryLoad))
    except Exception:
        pass
    return "not_available", "not_available", "not_available"


def _read_existing_watchdog(shared_root: Path) -> WatchdogProof:
    status_path = shared_gateway_status_path(shared_root)
    try:
        kv = read_kv(status_path)
        return WatchdogProof(kv.get("watchdog_last_check_utc", "not_available"), kv.get("watchdog_last_action", "not_checked"), kv.get("watchdog_last_reason", "not_available"), kv.get("watchdog_restart_attempted", "false"), kv.get("watchdog_restart_result", "not_available"))
    except Exception:
        return WatchdogProof()


def _status_age(shared_root: Path) -> Tuple[bool, int]:
    status_path = shared_gateway_status_path(shared_root)
    if not status_path.exists():
        return False, -1
    try:
        kv = read_kv(status_path)
        last_loop = int(kv.get("last_loop_unix", "0"))
        if last_loop <= 0:
            return False, -1
        return True, max(0, unix_time() - last_loop)
    except Exception:
        return False, -1


def build_shared_status(shared_root: Path, loop_count: int, roots: List[Path], results: List[Tuple[Path, int, ValidationResult]], watchdog: WatchdogProof | None = None, repair_success: bool = False, status_mode: str = "shared-daemon") -> str:
    accepted = sum(1 for _r, code, result in results if code == 0 and result.ok)
    degraded = len(results) - accepted
    write_degraded = sum(1 for _r, code, result in results if code == 3 or result.status == "write_degraded")
    cpu = os.cpu_count() or 1
    mem_total, mem_avail, mem_used = _windows_memory()
    proof = watchdog or _read_existing_watchdog(shared_root)
    throttle = "false"
    throttle_reason = "none"
    if mem_used.isdigit() and int(mem_used) >= 80:
        throttle = "true"
        throttle_reason = "memory_above_limit"
    lines = [
        "schema_name=aurora_shared_gateway_status", "schema_version=6", f"worker_version={WORKER_VERSION}",
        f"process_id={PROCESS_ID}", f"mode={status_mode}", f"shared_root={shared_root}",
        f"gateway_status_path={shared_gateway_status_path(shared_root)}", f"process_start_utc={PROCESS_START_UTC}",
        f"process_start_unix={PROCESS_START_UNIX}", f"last_loop_utc={utc_stamp()}", f"last_loop_unix={unix_time()}",
        f"loop_count={loop_count}", f"discovered_root_count={len(roots)}", f"processed_root_count={len(results)}",
        f"accepted_root_count={accepted}", f"degraded_root_count={degraded}", f"write_degraded_root_count={write_degraded}",
        "daemon_task_registered=not_checked_by_daemon", "daemon_task_state=not_checked_by_daemon",
        "watchdog_task_registered=not_checked_by_daemon", "watchdog_task_state=not_checked_by_daemon",
        f"watchdog_last_check_utc={proof.last_check_utc}", f"watchdog_last_action={proof.last_action}",
        f"watchdog_last_reason={proof.last_reason}", f"watchdog_restart_attempted={proof.restart_attempted}",
        f"watchdog_restart_result={proof.restart_result}", "operator_cmd_required=not_available_in_daemon_status",
        f"cpu_logical_count={cpu}", "cpu_used_percent=not_available", f"memory_total_mb={mem_total}",
        f"memory_available_mb={mem_avail}", f"memory_used_percent={mem_used}", "memory_limit_percent=80",
        "cpu_limit_percent=80", "terminal_process_count=not_checked_by_daemon", "aurora_worker_process_count=not_checked_by_daemon",
        f"registered_root_count={len(roots)}", f"resource_throttle_active={throttle}", f"resource_throttle_reason={throttle_reason}",
        "recommended_parallel_jobs=1", "authority=calculation_support_only", "trade_permission=false", "",
        "root|exit_code|status|reason|snapshot_id|job_id|job_type|payload_checksum",
    ]
    lines += [f"{root}|{code}|{res.status}|{res.reason}|{res.snapshot_id}|{res.job_id}|{res.job_type}|{res.payload_checksum}" for root, code, res in results]
    lines.append("")
    return "\n".join(lines)


def write_shared_status(shared_root: Path, loop_count: int, roots: List[Path], results: List[Tuple[Path, int, ValidationResult]], watchdog: WatchdogProof | None = None, repair_success: bool = False, status_mode: str = "shared-daemon") -> bool:
    return atomic_write_text(shared_gateway_status_path(shared_root), build_shared_status(shared_root, loop_count, roots, results, watchdog, repair_success, status_mode))


def build_probe_status(shared_root: Path, loop_count: int, roots: List[Path], results: List[Tuple[Path, int, ValidationResult]], proof: WatchdogProof, repair_success: bool, status_mode: str) -> str:
    accepted = sum(1 for _r, code, result in results if code == 0 and result.ok)
    degraded = len(results) - accepted
    write_degraded = sum(1 for _r, code, result in results if code == 3 or result.status == "write_degraded")
    is_watchdog = status_mode == "watchdog_probe"
    status_path = watchdog_gateway_status_path(shared_root) if is_watchdog else repair_gateway_status_path(shared_root)
    schema_name = "aurora_gateway_watchdog_status" if is_watchdog else "aurora_gateway_repair_status"
    path_key = "watchdog_status_path" if is_watchdog else "repair_status_path"

    lines = [
        f"schema_name={schema_name}",
        "schema_version=1",
        f"worker_version={WORKER_VERSION}",
        f"process_id={PROCESS_ID}",
        f"mode={status_mode}",
        f"shared_root={shared_root}",
        f"daemon_status_path={shared_gateway_status_path(shared_root)}",
        f"{path_key}={status_path}",
        f"process_start_utc={PROCESS_START_UTC}",
        f"process_start_unix={PROCESS_START_UNIX}",
        f"last_check_utc={proof.last_check_utc}",
        f"last_check_unix={unix_time()}",
        f"loop_count={loop_count}",
        f"discovered_root_count={len(roots)}",
        f"processed_root_count={len(results)}",
        f"accepted_root_count={accepted}",
        f"degraded_root_count={degraded}",
        f"write_degraded_root_count={write_degraded}",
        f"last_action={proof.last_action}",
        f"last_reason={proof.last_reason}",
        f"restart_attempted={proof.restart_attempted}",
        f"restart_result={proof.restart_result}",
        f"repair_success={'true' if repair_success else 'false'}",
        "daemon_truth_owner=shared_worker_status.txt",
        "probe_truth_owner=watchdog_status.txt_or_repair_status.txt",
        "authority=calculation_support_only",
        "trade_permission=false",
        "",
        "root|exit_code|status|reason|snapshot_id|job_id|job_type|payload_checksum",
    ]
    lines += [f"{root}|{code}|{res.status}|{res.reason}|{res.snapshot_id}|{res.job_id}|{res.job_type}|{res.payload_checksum}" for root, code, res in results]
    lines.append("")
    return "\n".join(lines)


def write_probe_status(shared_root: Path, loop_count: int, roots: List[Path], results: List[Tuple[Path, int, ValidationResult]], proof: WatchdogProof, repair_success: bool, status_mode: str) -> bool:
    if status_mode == "watchdog_probe":
        target = watchdog_gateway_status_path(shared_root)
    elif status_mode == "repair_probe":
        target = repair_gateway_status_path(shared_root)
    else:
        raise ValueError(f"unsupported probe status mode: {status_mode}")
    return atomic_write_text(target, build_probe_status(shared_root, loop_count, roots, results, proof, repair_success, status_mode))


def run_shared_daemon(shared_root: Path, poll_seconds: float) -> int:
    poll_seconds = max(0.25, poll_seconds)
    loop = 0
    while True:
        loop += 1
        roots = discover_roots(shared_root)
        results: List[Tuple[Path, int, ValidationResult]] = []
        for idx, root in enumerate(roots):
            code, res = run_once(root, "shared_validator_daemon")
            process_ok = write_process_status(root, "shared-daemon", loop, code, res, len(roots), idx)
            if not process_ok:
                res = mark_write_failure(res, [WorkerPaths.from_root(root).status / "worker_process_status.txt"])
                code = 3
            results.append((root, code, res))
        write_shared_status(shared_root, loop, roots, results, status_mode="shared-daemon")
        time.sleep(poll_seconds)


def run_status_probe(shared_root: Path) -> int:
    roots = discover_roots(shared_root)
    results: List[Tuple[Path, int, ValidationResult]] = []
    write_failed = False
    for idx, root in enumerate(roots):
        code, res = run_once(root, "shared_status_probe")
        process_ok = write_process_status(root, "shared-status-probe", 1, code, res, len(roots), idx)
        if not process_ok:
            res = mark_write_failure(res, [WorkerPaths.from_root(root).status / "worker_process_status.txt"])
            code = 3
            write_failed = True
        results.append((root, code, res))
    ok = write_shared_status(shared_root, 1, roots, results, status_mode="shared_status_probe")
    return 0 if ok and not write_failed else 3


def run_repair(shared_root: Path, watchdog_mode: bool) -> int:
    roots = discover_roots(shared_root)
    results: List[Tuple[Path, int, ValidationResult]] = []
    write_failed = False
    for idx, root in enumerate(roots):
        mode = "watchdog_probe" if watchdog_mode else "repair_probe"
        code, res = run_once(root, mode)
        process_ok = write_process_status(root, mode, 1, code, res, len(roots), idx)
        if not process_ok:
            res = mark_write_failure(res, [WorkerPaths.from_root(root).status / "worker_process_status.txt"])
            code = 3
            write_failed = True
        results.append((root, code, res))
    daemon_registered, daemon_state = _get_task_state(DAEMON_TASK_NAME)
    status_present, age = _status_age(shared_root)
    worker_processes = _proc_count("AuroraWorker")
    stale = (not status_present) or age < 0 or age > STATUS_MAX_AGE_SECONDS
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
        ok, out = _start_task(DAEMON_TASK_NAME)
        action = "start_daemon_task"
        restart_result = ("started_" + out) if ok else ("failed_" + out)
        time.sleep(3)
        status_present_after, age_after = _status_age(shared_root)
        process_count_after = _proc_count("AuroraWorker")
        repair_success = ok and (status_present_after and age_after >= 0 and age_after <= STATUS_MAX_AGE_SECONDS or process_count_after != "0")
    elif daemon_registered != "true":
        action = "cannot_repair_missing_daemon_task"
        restart_result = "failed_daemon_task_missing"
    proof = WatchdogProof(utc_stamp(), action, ";".join(reason_bits), attempted, restart_result)
    probe_mode = "watchdog_probe" if watchdog_mode else "repair_probe"
    probe_ok = write_probe_status(shared_root, 1, roots, results, proof, repair_success, probe_mode)
    return 0 if probe_ok and not write_failed and (restart_result.startswith("not_needed") or repair_success) else 2


def main(argv: List[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Aurora Gateway validator")
    parser.add_argument("--root")
    parser.add_argument("--shared-root")
    parser.add_argument("--mode", choices=("once", "daemon", "shared-daemon"), default="once")
    parser.add_argument("--poll-seconds", type=float, default=1.0)
    parser.add_argument("--status", action="store_true")
    parser.add_argument("--repair", action="store_true")
    parser.add_argument("--watchdog", action="store_true")
    parser.add_argument("--install-global", action="store_true")
    args = parser.parse_args(argv)

    if args.install_global:
        print("install-global is PowerShell-owned. Run install_worker_global.ps1. No install success is claimed here.")
        return 0
    if args.watchdog or args.repair:
        if not args.shared_root:
            raise SystemExit("--shared-root is required for watchdog/repair mode")
        return run_repair(Path(args.shared_root), args.watchdog)
    if args.status:
        if not args.shared_root:
            raise SystemExit("--shared-root is required for --status")
        return run_status_probe(Path(args.shared_root))
    if args.mode == "shared-daemon":
        if not args.shared_root:
            raise SystemExit("--shared-root is required for shared-daemon mode")
        return run_shared_daemon(Path(args.shared_root), args.poll_seconds)
    if not args.root:
        raise SystemExit("--root is required for once/daemon mode")
    root = Path(args.root)
    if args.mode == "daemon":
        loop = 0
        while True:
            loop += 1
            code, res = run_once(root, "validator_daemon_capable")
            process_ok = write_process_status(root, "daemon", loop, code, res)
            if not process_ok:
                code = 3
            time.sleep(max(0.25, args.poll_seconds))
    code, res = run_once(root)
    process_ok = write_process_status(root, "once", 1, code, res)
    return code if process_ok else 3


if __name__ == "__main__":
    raise SystemExit(main())