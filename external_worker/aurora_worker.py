from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Tuple
import argparse
import sys
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

WORKER_VERSION = "0.1.0"
EXPECTED_AUTHORITY = "calculation_support_only"


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


def build_heartbeat(result: ValidationResult) -> str:
    return "\n".join([
        "schema_name=aurora_worker_heartbeat",
        "schema_version=1",
        f"worker_version={WORKER_VERSION}",
        "worker_mode=validator_skeleton",
        f"worker_status={'alive' if result.ok else 'alive_degraded'}",
        f"last_validation_status={result.status}",
        f"last_validation_reason={result.reason}",
        f"last_snapshot_id={result.snapshot_id}",
        f"server={result.server}",
        f"account={result.account}",
        f"row_count={result.row_count}",
        f"payload_checksum={result.payload_checksum}",
        f"generated_utc={utc_stamp()}",
        f"generated_unix={unix_time()}",
        "authority=calculation_support_only",
        "trade_permission=false",
        "",
    ])


def build_result(result: ValidationResult, rows: List[str]) -> str:
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

    return "\n".join([
        "schema_name=aurora_worker_result",
        "schema_version=1",
        f"worker_version={WORKER_VERSION}",
        "worker_mode=validator_skeleton",
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
        "notes=validator_skeleton_only_no_ranking_no_selection_no_permission_no_broker_polling",
        "",
    ])


def build_result_manifest(result: ValidationResult, result_text: str) -> str:
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
        "",
    ])


def run_once(root: Path) -> int:
    paths = WorkerPaths.from_root(root)
    paths.ensure()
    try:
        result, _header, rows = validate_snapshot(paths)
        heartbeat = build_heartbeat(result)
        result_text = build_result(result, rows)
        result_manifest = build_result_manifest(result, result_text)
        atomic_write_text(paths.status / "worker_heartbeat.txt", heartbeat)
        atomic_write_text(paths.outbox / "result_latest.txt", result_text)
        atomic_write_text(paths.outbox / "result_latest.manifest", result_manifest)
        return 0 if result.ok else 2
    except Exception as exc:  # keep worker failure visible, not silent
        error_text = "\n".join([
            "schema_name=aurora_worker_error",
            "schema_version=1",
            f"worker_version={WORKER_VERSION}",
            f"error={type(exc).__name__}: {exc}",
            "traceback=",
            traceback.format_exc(),
            f"generated_utc={utc_stamp()}",
            "trade_permission=false",
            "",
        ])
        paths.ensure()
        atomic_write_text(paths.logs / "worker_errors.txt", error_text)
        atomic_write_text(paths.status / "worker_heartbeat.txt", error_text)
        return 1


def main(argv: List[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Aurora external worker validator skeleton")
    parser.add_argument("--root", required=True, help="Aurora account root folder, e.g. Common Files/Aurora Core/Server/Account")
    args = parser.parse_args(argv)
    return run_once(Path(args.root))


if __name__ == "__main__":
    raise SystemExit(main())
