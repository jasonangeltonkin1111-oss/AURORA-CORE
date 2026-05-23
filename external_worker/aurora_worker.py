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
from aurora_worker_render_index import publish_render_index
from aurora_worker_recorder import gateway_record_event, gateway_record_exception

WORKER_VERSION = "0.6.10_render_index_l6_l9"
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


def _record_gateway_result(root: Path, result: ValidationResult, worker_mode: str, exit_code: int, l6_summary, l6_duration_ms: int, l6_reused_existing_outputs: bool, l7_summary, l7_duration_ms: int, l8_summary, l8_duration_ms: int, l9_summary, l9_duration_ms: int, render_index_summary, render_index_duration_ms: int, event_status: str) -> None:
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
            "render_index_status": render_index_summary.status,
            "render_index_reason": render_index_summary.reason,
            "render_index_duration_ms": render_index_duration_ms,
        },
        signature_fields=("event_status", "snapshot_id", "job_id", "result_status", "l6_rank_status", "l6_rank_reused_existing_outputs", "l7_rank_status", "l8_rank_status", "l9_rank_status", "render_index_status"),
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
        "schema_name=aurora_worker_result", "schema_version=6", f"worker_version={WORKER_VERSION}",
        f"worker_mode={worker_mode}", "authority=calculation_support_only", "trade_permission=false",
        f"source_snapshot_id={result.snapshot_id}", f"job_bus_schema_version={result.job_bus_schema_version}",
        f"job_id={result.job_id}", f"job_type={result.job_type}", f"job_resource_class={result.job_resource_class}",
        f"job_max_runtime_ms={result.job_max_runtime_ms}", f"job_status={job_status}",
        f"result_status={'complete' if result.ok else 'rejected'}", f"result_reason={result.reason}",
        f"row_count={result.row_count}", f"open_count={open_count}", f"closed_count={closed_count}",
        f"l4_ready_count={l4_ready_count}", f"stale_or_missing_quote_rows={stale_or_missing}",
        f"payload_checksum={result.payload_checksum}", f"generated_utc={utc_stamp()}", f"generated_unix={unix_time()}",
        "notes=r3_snapshot_validation_plus_l6_l7_l8_l9_surface_rankings_plus_render_index_no_layer5_advisory_no_selection_no_permission_no_broker_polling", ""
    ])


def build_result_manifest(result: ValidationResult, result_text: str) -> str:
    job_status = "complete" if result.ok else "rejected"
    return "\n".join([
        "schema_name=aurora_worker_result_manifest", "schema_version=6", f"worker_version={WORKER_VERSION}",
        f"source_snapshot_id={result.snapshot_id}", f"job_bus_schema_version={result.job_bus_schema_version}",
        f"job_id={result.job_id}", f"job_type={result.job_type}", f"job_resource_class={result.job_resource_class}",
        f"job_max_runtime_ms={result.job_max_runtime_ms}", f"job_status={job_status}",
        f"result_status={'complete' if result.ok else 'rejected'}", f"result_reason={result.reason}",
        f"row_count={result.row_count}", f"payload_checksum={result.payload_checksum}",
        f"result_size={len(result_text.encode('utf-8'))}", "authority=calculation_support_only", "trade_permission=false",
        "result_scope=r3_snapshot_validation_plus_l6_l7_l8_l9_surface_rankings_plus_render_index_no_layer5_advisory_no_selection_no_permission", f"generated_utc={utc_stamp()}", f"generated_unix={unix_time()}", ""
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


def _append_render_index_lines(result_text: str, summary, duration_ms: int) -> str:
    result_text += "render_index_status=" + summary.status + "\n"
    result_text += "render_index_reason=" + summary.reason + "\n"
    result_text += "render_index_duration_ms=" + str(duration_ms) + "\n"
    result_text += "render_index_manifest_path=" + summary.manifest_path + "\n"
    result_text += "render_index_ohlc_row_count=" + str(summary.ohlc_row_count) + "\n"
    result_text += "render_index_ohlc_checksum=" + summary.ohlc_index_checksum + "\n"
    for layer_summary in summary.layer_summaries:
        prefix = layer_summary.layer_key
        result_text += f"render_index_{prefix}_status=" + layer_summary.status + "\n"
        result_text += f"render_index_{prefix}_row_count=" + str(layer_summary.row_count) + "\n"
        result_text += f"render_index_{prefix}_checksum=" + layer_summary.output_checksum + "\n"
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
        render_index_start_ns = time.perf_counter_ns()
        render_index_summary = publish_render_index(p.outbox, WORKER_VERSION)
        render_index_duration_ms = max(0, (time.perf_counter_ns() - render_index_start_ns) // 1_000_000)
        result_text = build_result(result, rows, worker_mode)
        result_text = _append_rank_lines(result_text, "l6", l6_summary, l6_duration_ms, [("l6_rank_reused_existing_outputs", "true" if l6_reused_existing_outputs else "false")])
        result_text = _append_rank_lines(result_text, "l7", l7_summary, l7_duration_ms)
        result_text = _append_rank_lines(result_text, "l8", l8_summary, l8_duration_ms)
        result_text = _append_rank_lines(result_text, "l9", l9_summary, l9_duration_ms)
        result_text = _append_render_index_lines(result_text, render_index_summary, render_index_duration_ms)
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
            _record_gateway_result(root, degraded, worker_mode, 3, l6_summary, l6_duration_ms, l6_reused_existing_outputs, l7_summary, l7_duration_ms, l8_summary, l8_duration_ms, l9_summary, l9_duration_ms, render_index_summary, render_index_duration_ms, "write_degraded")
            return 3, degraded
        exit_code = 0 if result.ok else 2
        _record_gateway_result(root, result, worker_mode, exit_code, l6_summary, l6_duration_ms, l6_reused_existing_outputs, l7_summary, l7_duration_ms, l8_summary, l8_duration_ms, l9_summary, l9_duration_ms, render_index_summary, render_index_duration_ms, "published")
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
                    if (account / "Workbench" / GATEWAY_FOLDER_NAME).exists():
                        roots.append(account)
    return roots


def _trigger_repair_script(shared_root: Path, reason: str) -> Tuple[bool, str]:
    script = shared_root / GATEWAY_FOLDER_NAME / "Control" / "repair_worker_tasks.ps1"
    if not script.exists():
        return False, f"repair script missing: {script}"
    try:
        subprocess.run(
            ["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", str(script), "-Reason", reason],
            timeout=45,
            check=False,
            creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0),
        )
        return True, "repair script launched"
    except Exception as exc:  # pragma: no cover - Windows repair path
        return False, f"repair launch failed: {type(exc).__name__}: {exc}"
