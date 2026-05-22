from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Tuple
import argparse
import os
import subprocess
import time
import traceback

from aurora_worker_io import (
    WorkerPaths,
    atomic_write_text,
    payload_checksum,
    read_kv,
    read_text,
    split_snapshot,
    unix_time,
    utc_stamp,
)

WORKER_VERSION = "0.4.0"
EXPECTED_AUTHORITY = "calculation_support_only"
PROCESS_START_UNIX = unix_time()
PROCESS_START_UTC = utc_stamp()
PROCESS_ID = os.getpid()


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

# ... keep prior logic unchanged below

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
    server = snapshot_header.get("server", "not_available")
    account = snapshot_header.get("account", "not_available")
    expected_server = required.get("server", "")
    expected_account = required.get("account", "")
    if expected_server and server != expected_server:
        return ValidationResult(False, "rejected", f"server mismatch snapshot={server} required={expected_server}", snapshot_id, 0, "not_available", server, account), snapshot_header, snapshot_rows
    if expected_account and account != expected_account:
        return ValidationResult(False, "rejected", f"account mismatch snapshot={account} required={expected_account}", snapshot_id, 0, "not_available", server, account), snapshot_header, snapshot_rows
    if snapshot_header.get("authority") != EXPECTED_AUTHORITY or manifest.get("authority") != EXPECTED_AUTHORITY:
        return ValidationResult(False, "rejected", "authority is not calculation_support_only", snapshot_id, 0, "not_available", server, account), snapshot_header, snapshot_rows
    if snapshot_header.get("trade_permission") != "false" or manifest.get("trade_permission") != "false":
        return ValidationResult(False, "rejected", "trade_permission must remain false", snapshot_id, 0, "not_available", server, account), snapshot_header, snapshot_rows
    manifest_rows = int(manifest.get("row_count", "-1"))
    header_rows = int(snapshot_header.get("row_count", "-1"))
    data_rows = max(0, len(snapshot_rows) - 1)
    if manifest_rows != data_rows or header_rows != data_rows:
        return ValidationResult(False, "rejected", f"row_count mismatch header={header_rows} manifest={manifest_rows} actual={data_rows}", snapshot_id, data_rows, "not_available", server, account), snapshot_header, snapshot_rows
    calculated_checksum = payload_checksum(snapshot_rows)
    expected_checksum = manifest.get("payload_checksum", snapshot_header.get("payload_checksum", ""))
    if calculated_checksum != expected_checksum:
        return ValidationResult(False, "rejected", f"payload checksum mismatch expected={expected_checksum} calculated={calculated_checksum}", snapshot_id, data_rows, calculated_checksum, server, account), snapshot_header, snapshot_rows
    return ValidationResult(True, "accepted", "snapshot accepted", snapshot_id, data_rows, calculated_checksum, server, account), snapshot_header, snapshot_rows

def build_heartbeat(result: ValidationResult, worker_mode: str) -> str:
    now_unix = unix_time()
    return "\n".join(["schema_name=aurora_worker_heartbeat","schema_version=1",f"worker_version={WORKER_VERSION}",f"worker_mode={worker_mode}",f"worker_status={'alive' if result.ok else 'alive_degraded'}",f"last_validation_status={result.status}",f"last_validation_reason={result.reason}",f"last_snapshot_id={result.snapshot_id}",f"server={result.server}",f"account={result.account}",f"row_count={result.row_count}",f"payload_checksum={result.payload_checksum}",f"generated_utc={utc_stamp()}",f"generated_unix={now_unix}","authority=calculation_support_only","trade_permission=false",""])

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
    return "\n".join(["schema_name=aurora_worker_result","schema_version=1",f"worker_version={WORKER_VERSION}",f"worker_mode={worker_mode}","authority=calculation_support_only","trade_permission=false",f"source_snapshot_id={result.snapshot_id}",f"result_status={'complete' if result.ok else 'rejected'}",f"result_reason={result.reason}",f"row_count={result.row_count}",f"open_count={open_count}",f"closed_count={closed_count}",f"l4_ready_count={l4_ready_count}",f"stale_or_missing_quote_rows={stale_or_missing}",f"payload_checksum={result.payload_checksum}",f"generated_utc={utc_stamp()}",f"generated_unix={unix_time()}","notes=validator_skeleton_only_no_ranking_no_selection_no_permission_no_broker_polling",""])

def build_result_manifest(result: ValidationResult, result_text: str) -> str:
    return "\n".join(["schema_name=aurora_worker_result_manifest","schema_version=1",f"worker_version={WORKER_VERSION}",f"source_snapshot_id={result.snapshot_id}",f"result_status={'complete' if result.ok else 'rejected'}",f"result_reason={result.reason}",f"row_count={result.row_count}",f"payload_checksum={result.payload_checksum}",f"result_size={len(result_text.encode('utf-8'))}","authority=calculation_support_only","trade_permission=false",f"generated_utc={utc_stamp()}",f"generated_unix={unix_time()}",""])

def build_process_status(root: Path, mode: str, loop_count: int, last_run_exit_code: int, result: ValidationResult | None, root_count: int = 1, active_root_index: int = 0) -> str:
    r = result or ValidationResult(False, "not_available", "no validation result yet")
    now = unix_time()
    return "\n".join(["schema_name=aurora_worker_process_status","schema_version=2",f"worker_version={WORKER_VERSION}",f"process_id={PROCESS_ID}",f"mode={mode}",f"root={root}",f"root_count={root_count}",f"active_root_index={active_root_index}",f"process_start_utc={PROCESS_START_UTC}",f"process_start_unix={PROCESS_START_UNIX}",f"last_loop_utc={utc_stamp()}",f"last_loop_unix={now}",f"loop_count={loop_count}",f"last_run_exit_code={last_run_exit_code}",f"last_validation_status={r.status}",f"last_validation_reason={r.reason}",f"last_snapshot_id={r.snapshot_id}",f"row_count={r.row_count}",f"payload_checksum={r.payload_checksum}","last_exception_type=none","last_exception=none","authority=calculation_support_only","trade_permission=false",f"generated_utc={utc_stamp()}",f"generated_unix={now}",""])

def write_process_status(root: Path, mode: str, loop_count: int, last_run_exit_code: int, result: ValidationResult | None, root_count: int = 1, active_root_index: int = 0) -> None:
    p = WorkerPaths.from_root(root); p.ensure(); atomic_write_text(p.status / "worker_process_status.txt", build_process_status(root, mode, loop_count, last_run_exit_code, result, root_count, active_root_index))

def run_once(root: Path, worker_mode: str = "validator_daemon_capable") -> Tuple[int, ValidationResult]:
    p = WorkerPaths.from_root(root); p.ensure()
    try:
        result, _h, rows = validate_snapshot(p)
        atomic_write_text(p.status / "worker_heartbeat.txt", build_heartbeat(result, worker_mode))
        result_text = build_result(result, rows, worker_mode)
        atomic_write_text(p.outbox / "result_latest.txt", result_text)
        atomic_write_text(p.outbox / "result_latest.manifest", build_result_manifest(result, result_text))
        return (0 if result.ok else 2), result
    except Exception as exc:
        error_text = "\n".join(["schema_name=aurora_worker_error","schema_version=1",f"worker_version={WORKER_VERSION}",f"error={type(exc).__name__}: {exc}","traceback=",traceback.format_exc(),f"generated_utc={utc_stamp()}",f"generated_unix={unix_time()}","authority=calculation_support_only","trade_permission=false",""])
        atomic_write_text(p.logs / "worker_errors.txt", error_text); atomic_write_text(p.status / "worker_heartbeat.txt", error_text)
        return 1, ValidationResult(False, "exception", f"{type(exc).__name__}: {exc}")

def discover_roots(shared_root: Path) -> List[Path]:
    roots=[]
    if shared_root.exists():
        for s in sorted(shared_root.iterdir()):
            if s.is_dir() and s.name != "External Worker":
                for a in sorted(s.iterdir()):
                    if a.is_dir() and (a / "Workbench/External Worker/Control/worker_required.txt").exists():
                        roots.append(a)
    return roots

def _get_task_state(task_name: str) -> Tuple[str, str]:
    try:
        o = subprocess.check_output(["powershell","-NoProfile","-Command",f"(Get-ScheduledTask -TaskName '{task_name}' -ErrorAction Stop).State.ToString()"], text=True, timeout=5).strip()
        return "true", (o or "unknown")
    except Exception:
        return "false", "not_registered"

def _proc_count(name: str) -> str:
    try:
        return subprocess.check_output(["powershell","-NoProfile","-Command",f"@(Get-Process -Name '{name}' -ErrorAction SilentlyContinue).Count"], text=True, timeout=5).strip() or "0"
    except Exception:
        return "not_available"

def build_shared_status(shared_root: Path, loop_count: int, roots: List[Path], results: List[Tuple[Path, int, ValidationResult]]) -> str:
    accepted = sum(1 for _r, c, rr in results if c == 0 and rr.ok)
    degraded = len(results) - accepted
    cpu = os.cpu_count() or 1
    mem_total = mem_avail = mem_used = 0
    if hasattr(os, "sysconf"):
        try:
            page = os.sysconf("SC_PAGE_SIZE")
            mem_total = max(1, int((page * os.sysconf("SC_PHYS_PAGES")) / (1024 * 1024)))
            mem_avail = max(0, int((page * os.sysconf("SC_AVPHYS_PAGES")) / (1024 * 1024)))
            mem_used = int(((mem_total - mem_avail) / mem_total) * 100)
        except Exception:
            pass
    dr, ds = _get_task_state("AuroraWorker_Global"); wr, ws = _get_task_state("AuroraWorker_Global_Watchdog")
    throttle = "true" if mem_used >= 80 else "false"
    lines=["schema_name=aurora_shared_worker_status","schema_version=2",f"worker_version={WORKER_VERSION}",f"process_id={PROCESS_ID}","mode=shared-daemon",f"shared_root={shared_root}",f"process_start_utc={PROCESS_START_UTC}",f"process_start_unix={PROCESS_START_UNIX}",f"last_loop_utc={utc_stamp()}",f"last_loop_unix={unix_time()}",f"loop_count={loop_count}",f"discovered_root_count={len(roots)}",f"processed_root_count={len(results)}",f"accepted_root_count={accepted}",f"degraded_root_count={degraded}",f"daemon_task_registered={dr}",f"daemon_task_state={ds}",f"watchdog_task_registered={wr}",f"watchdog_task_state={ws}",f"watchdog_last_check_utc={utc_stamp()}","watchdog_last_action=status_update_only","operator_cmd_required=true",f"cpu_logical_count={cpu}",f"memory_total_mb={mem_total}",f"memory_available_mb={mem_avail}",f"memory_used_percent={mem_used}","memory_limit_percent=80","cpu_limit_percent=80",f"terminal_process_count={_proc_count('terminal64')}",f"aurora_worker_process_count={_proc_count('AuroraWorker')}",f"registered_root_count={len(roots)}",f"resource_throttle_active={throttle}",f"resource_throttle_reason={'memory_above_limit' if throttle=='true' else 'none'}","recommended_parallel_jobs=1","authority=calculation_support_only","trade_permission=false","","root|exit_code|status|reason|snapshot_id|payload_checksum"]
    lines += [f"{r}|{c}|{res.status}|{res.reason}|{res.snapshot_id}|{res.payload_checksum}" for r,c,res in results]
    lines.append("")
    return "\n".join(lines)

def write_shared_status(shared_root: Path, loop_count: int, roots: List[Path], results: List[Tuple[Path, int, ValidationResult]]) -> None:
    atomic_write_text(shared_root / "External Worker/Status/shared_worker_status.txt", build_shared_status(shared_root, loop_count, roots, results))

def run_shared_daemon(shared_root: Path, poll_seconds: float) -> int:
    poll_seconds = max(0.25, poll_seconds); loop=0
    while True:
        loop += 1
        roots = discover_roots(shared_root); results=[]
        for idx, root in enumerate(roots):
            code, res = run_once(root, "shared_validator_daemon")
            write_process_status(root, "shared-daemon", loop, code, res, len(roots), idx)
            results.append((root, code, res))
        write_shared_status(shared_root, loop, roots, results); time.sleep(poll_seconds)

def main(argv: List[str] | None = None) -> int:
    p = argparse.ArgumentParser(description="Aurora external worker validator")
    p.add_argument("--root"); p.add_argument("--shared-root")
    p.add_argument("--mode", choices=("once","daemon","shared-daemon"), default="once")
    p.add_argument("--poll-seconds", type=float, default=1.0)
    p.add_argument("--status", action="store_true"); p.add_argument("--repair", action="store_true"); p.add_argument("--watchdog", action="store_true"); p.add_argument("--install-global", action="store_true")
    a = p.parse_args(argv)
    if a.install_global:
        print("install-global is PowerShell-owned. Run install_worker_global.ps1."); return 0
    if a.watchdog or a.repair:
        if not a.shared_root: raise SystemExit("--shared-root is required for watchdog/repair mode")
        roots=discover_roots(Path(a.shared_root)); results=[]
        for r in roots: results.append((r,*run_once(r,"watchdog_probe")))
        write_shared_status(Path(a.shared_root),1,roots,[(r,c,res) for r,c,res in results]); return 0
    if a.status:
        if not a.shared_root: raise SystemExit("--shared-root is required for --status")
        roots=discover_roots(Path(a.shared_root)); results=[]
        for r in roots:
            c,res = run_once(r,"shared_status_probe"); results.append((r,c,res))
        write_shared_status(Path(a.shared_root),1,roots,results); return 0
    if a.mode == "shared-daemon":
        if not a.shared_root: raise SystemExit("--shared-root is required for shared-daemon mode")
        return run_shared_daemon(Path(a.shared_root), a.poll_seconds)
    if not a.root: raise SystemExit("--root is required for once/daemon mode")
    root=Path(a.root)
    if a.mode == "daemon":
        loop=0
        while True:
            loop += 1
            code,res = run_once(root,"validator_daemon_capable"); write_process_status(root,"daemon",loop,code,res); time.sleep(max(0.25,a.poll_seconds))
    code,res=run_once(root); write_process_status(root,"once",1,code,res); return code

if __name__ == "__main__":
    raise SystemExit(main())
