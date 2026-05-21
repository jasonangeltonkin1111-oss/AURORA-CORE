from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Tuple
import argparse
import os
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

WORKER_VERSION = "0.3.0"
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

    if snapshot_header.get("authority") != EXPECTED_AUTHORITY:
        return ValidationResult(False, "rejected", "snapshot authority is not calculation_support_only", snapshot_id, 0, "not_available", server, account), snapshot_header, snapshot_rows
    if manifest.get("authority") != EXPECTED_AUTHORITY:
        return ValidationResult(False, "rejected", "manifest authority is not calculation_support_only", snapshot_id, 0, "not_available", server, account), snapshot_header, snapshot_rows
    if snapshot_header.get("trade_permission") != "false" or manifest.get("trade_permission") != "false":
        return ValidationResult(False, "rejected", "trade_permission must remain false", snapshot_id, 0, "not_available", server, account), snapshot_header, snapshot_rows

    manifest_rows = int(manifest.get("row_count", "-1"))
    header_rows = int(snapshot_header.get("row_count", "-1"))
    data_rows = max(0, len(snapshot_rows) - 1)  # first row is column header
    if manifest_rows != data_rows or header_rows != data_rows:
        return ValidationResult(False, "rejected", f"row_count mismatch header={header_rows} manifest={manifest_rows} actual={data_rows}", snapshot_id, data_rows, "not_available", server, account), snapshot_header, snapshot_rows

    calculated_checksum = payload_checksum(snapshot_rows)
    expected_checksum = manifest.get("payload_checksum", snapshot_header.get("payload_checksum", ""))
    if calculated_checksum != expected_checksum:
        return ValidationResult(False, "rejected", f"payload checksum mismatch expected={expected_checksum} calculated={calculated_checksum}", snapshot_id, data_rows, calculated_checksum, server, account), snapshot_header, snapshot_rows

    return ValidationResult(True, "accepted", "snapshot accepted", snapshot_id, data_rows, calculated_checksum, server, account), snapshot_header, snapshot_rows


def build_heartbeat(result: ValidationResult, worker_mode: str) -> str:
    now_unix = unix_time()
    return "\n".join([
        "schema_name=aurora_worker_heartbeat",
        "schema_version=1",
        f"worker_version={WORKER_VERSION}",
        f"worker_mode={worker_mode}",
        f"worker_status={'alive' if result.ok else 'alive_degraded'}",
        f"last_validation_status={result.status}",
        f"last_validation_reason={result.reason}",
        f"last_snapshot_id={result.snapshot_id}",
        f"server={result.server}",
        f"account={result.account}",
        f"row_count={result.row_count}",
        f"payload_checksum={result.payload_checksum}",
        f"generated_utc={utc_stamp()}",
        f"generated_unix={now_unix}",
        "authority=calculation_support_only",
        "trade_permission=false",
        "",
    ])


def build_result(result: ValidationResult, rows: List[str], worker_mode: str) -> str:
    open_count = 0
    closed_count = 0
    l4_ready_count = 0
    stale_or_missing = 0
    if rows:
        for raw in rows[1:]:
            parts = raw.split("|")
            if len(parts) < 13:
                continue
            if parts[1] == "open":
                open_count += 1
            elif parts[1] == "closed":
                closed_count += 1
            if parts[3] == "true":
                l4_ready_count += 1
            if parts[4] in {"Missing Tick", "Stale", "not_available"}:
                stale_or_missing += 1

    now_unix = unix_time()
    return "\n".join([
        "schema_name=aurora_worker_result",
        "schema_version=1",
        f"worker_version={WORKER_VERSION}",
        f"worker_mode={worker_mode}",
        "authority=calculation_support_only",
        "trade_permission=false",
        f"source_snapshot_id={result.snapshot_id}",
        f"result_status={'complete' if result.ok else 'rejected'}",
        f"result_reason={result.reason}",
        f"row_count={result.row_count}",
        f"open_count={open_count}",
        f"closed_count={closed_count}",
        f"l4_ready_count={l4_ready_count}",
        f"stale_or_missing_quote_rows={stale_or_missing}",
        f"payload_checksum={result.payload_checksum}",
        f"generated_utc={utc_stamp()}",
        f"generated_unix={now_unix}",
        "notes=validator_skeleton_only_no_ranking_no_selection_no_permission_no_broker_polling",
        "",
    ])


def build_result_manifest(result: ValidationResult, result_text: str) -> str:
    now_unix = unix_time()
    return "\n".join([
        "schema_name=aurora_worker_result_manifest",
        "schema_version=1",
        f"worker_version={WORKER_VERSION}",
        f"source_snapshot_id={result.snapshot_id}",
        f"result_status={'complete' if result.ok else 'rejected'}",
        f"result_reason={result.reason}",
        f"row_count={result.row_count}",
        f"payload_checksum={result.payload_checksum}",
        f"result_size={len(result_text.encode('utf-8'))}",
        "authority=calculation_support_only",
        "trade_permission=false",
        f"generated_utc={utc_stamp()}",
        f"generated_unix={now_unix}",
        "",
    ])


def build_process_status(root: Path, mode: str, loop_count: int, last_run_exit_code: int, result: ValidationResult | None, root_count: int = 1, active_root_index: int = 0) -> str:
    now_unix = unix_time()
    if result is None:
        result = ValidationResult(False, "not_available", "no validation result yet")
    return "\n".join([
        "schema_name=aurora_worker_process_status",
        "schema_version=2",
        f"worker_version={WORKER_VERSION}",
        f"process_id={PROCESS_ID}",
        f"mode={mode}",
        f"root={root}",
        f"root_count={root_count}",
        f"active_root_index={active_root_index}",
        f"process_start_utc={PROCESS_START_UTC}",
        f"process_start_unix={PROCESS_START_UNIX}",
        f"last_loop_utc={utc_stamp()}",
        f"last_loop_unix={now_unix}",
        f"loop_count={loop_count}",
        f"last_run_exit_code={last_run_exit_code}",
        f"last_validation_status={result.status}",
        f"last_validation_reason={result.reason}",
        f"last_snapshot_id={result.snapshot_id}",
        f"row_count={result.row_count}",
        f"payload_checksum={result.payload_checksum}",
        "last_exception_type=none",
        "last_exception=none",
        "authority=calculation_support_only",
        "trade_permission=false",
        f"generated_utc={utc_stamp()}",
        f"generated_unix={now_unix}",
        "",
    ])


def write_process_status(root: Path, mode: str, loop_count: int, last_run_exit_code: int, result: ValidationResult | None, root_count: int = 1, active_root_index: int = 0) -> None:
    paths = WorkerPaths.from_root(root)
    paths.ensure()
    atomic_write_text(paths.status / "worker_process_status.txt", build_process_status(root, mode, loop_count, last_run_exit_code, result, root_count, active_root_index))


def run_once(root: Path, worker_mode: str = "validator_daemon_capable") -> Tuple[int, ValidationResult]:
    paths = WorkerPaths.from_root(root)
    paths.ensure()
    try:
        result, _header, rows = validate_snapshot(paths)
        heartbeat = build_heartbeat(result, worker_mode)
        result_text = build_result(result, rows, worker_mode)
        result_manifest = build_result_manifest(result, result_text)
        atomic_write_text(paths.status / "worker_heartbeat.txt", heartbeat)
        atomic_write_text(paths.outbox / "result_latest.txt", result_text)
        atomic_write_text(paths.outbox / "result_latest.manifest", result_manifest)
        return (0 if result.ok else 2), result
    except Exception as exc:  # keep worker failure visible, not silent
        error_text = "\n".join([
            "schema_name=aurora_worker_error",
            "schema_version=1",
            f"worker_version={WORKER_VERSION}",
            f"error={type(exc).__name__}: {exc}",
            "traceback=",
            traceback.format_exc(),
            f"generated_utc={utc_stamp()}",
            f"generated_unix={unix_time()}",
            "authority=calculation_support_only",
            "trade_permission=false",
            "",
        ])
        paths.ensure()
        atomic_write_text(paths.logs / "worker_errors.txt", error_text)
        atomic_write_text(paths.status / "worker_heartbeat.txt", error_text)
        failed = ValidationResult(False, "exception", f"{type(exc).__name__}: {exc}")
        return 1, failed


def run_daemon(root: Path, poll_seconds: float) -> int:
    if poll_seconds < 0.25:
        poll_seconds = 0.25
    loop_count = 0
    write_process_status(root, "daemon", loop_count, -1, None)
    while True:
        loop_count += 1
        exit_code, result = run_once(root, "validator_daemon_capable")
        write_process_status(root, "daemon", loop_count, exit_code, result)
        time.sleep(poll_seconds)


def discover_roots(shared_root: Path) -> List[Path]:
    roots: List[Path] = []
    if not shared_root.exists():
        return roots
    for server_dir in sorted(shared_root.iterdir()):
        if not server_dir.is_dir() or server_dir.name == "External Worker":
            continue
        for account_dir in sorted(server_dir.iterdir()):
            if not account_dir.is_dir():
                continue
            required = account_dir / "Workbench" / "External Worker" / "Control" / "worker_required.txt"
            if required.exists():
                roots.append(account_dir)
    return roots


def build_shared_status(shared_root: Path, loop_count: int, roots: List[Path], results: List[Tuple[Path, int, ValidationResult]]) -> str:
    accepted = sum(1 for _root, exit_code, result in results if exit_code == 0 and result.ok)
    degraded = len(results) - accepted
    lines = [
        "schema_name=aurora_shared_worker_status",
        "schema_version=1",
        f"worker_version={WORKER_VERSION}",
        f"process_id={PROCESS_ID}",
        "mode=shared-daemon",
        f"shared_root={shared_root}",
        f"process_start_utc={PROCESS_START_UTC}",
        f"process_start_unix={PROCESS_START_UNIX}",
        f"last_loop_utc={utc_stamp()}",
        f"last_loop_unix={unix_time()}",
        f"loop_count={loop_count}",
        f"discovered_root_count={len(roots)}",
        f"processed_root_count={len(results)}",
        f"accepted_root_count={accepted}",
        f"degraded_root_count={degraded}",
        "authority=calculation_support_only",
        "trade_permission=false",
        "",
        "root|exit_code|status|reason|snapshot_id|payload_checksum",
    ]
    for root, exit_code, result in results:
        lines.append(f"{root}|{exit_code}|{result.status}|{result.reason}|{result.snapshot_id}|{result.payload_checksum}")
    lines.append("")
    return "\n".join(lines)


def write_shared_status(shared_root: Path, loop_count: int, roots: List[Path], results: List[Tuple[Path, int, ValidationResult]]) -> None:
    status_path = shared_root / "External Worker" / "Status" / "shared_worker_status.txt"
    atomic_write_text(status_path, build_shared_status(shared_root, loop_count, roots, results))


def run_shared_daemon(shared_root: Path, poll_seconds: float) -> int:
    if poll_seconds < 0.25:
        poll_seconds = 0.25
    loop_count = 0
    while True:
        loop_count += 1
        roots = discover_roots(shared_root)
        results: List[Tuple[Path, int, ValidationResult]] = []
        root_count = len(roots)
        for index, root in enumerate(roots):
            exit_code, result = run_once(root, "shared_validator_daemon")
            write_process_status(root, "shared-daemon", loop_count, exit_code, result, root_count, index)
            results.append((root, exit_code, result))
        write_shared_status(shared_root, loop_count, roots, results)
        time.sleep(poll_seconds)


def main(argv: List[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Aurora external worker validator")
    parser.add_argument("--root", help="Aurora account root folder, e.g. Common Files/Aurora Core/Server/Account")
    parser.add_argument("--shared-root", help="Shared Aurora Core root folder containing server/account roots")
    parser.add_argument("--mode", choices=("once", "daemon", "shared-daemon"), default="once")
    parser.add_argument("--poll-seconds", type=float, default=1.0)
    args = parser.parse_args(argv)
    if args.mode == "shared-daemon":
        if not args.shared_root:
            raise SystemExit("--shared-root is required for shared-daemon mode")
        return run_shared_daemon(Path(args.shared_root), args.poll_seconds)
    if not args.root:
        raise SystemExit("--root is required for once/daemon mode")
    root = Path(args.root)
    if args.mode == "daemon":
        return run_daemon(root, args.poll_seconds)
    exit_code, result = run_once(root)
    write_process_status(root, "once", 1, exit_code, result)
    return exit_code


if __name__ == "__main__":
    raise SystemExit(main())
