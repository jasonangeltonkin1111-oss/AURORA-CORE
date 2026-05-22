from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Iterable, List, Tuple
import os
import time


READ_RETRY_ATTEMPTS = 4
READ_RETRY_BACKOFF_SECONDS = 0.05
WRITE_REPLACE_RETRY_ATTEMPTS = 12
WRITE_REPLACE_RETRY_BACKOFF_SECONDS = 0.05


@dataclass(frozen=True)
class WorkerPaths:
    root: Path
    control: Path
    inbox: Path
    outbox: Path
    status: Path
    logs: Path
    quarantine: Path

    @classmethod
    def from_root(cls, root: Path) -> "WorkerPaths":
        external = root / "Workbench" / "External Worker"
        return cls(
            root=root,
            control=external / "Control",
            inbox=external / "Inbox",
            outbox=external / "Outbox",
            status=external / "Status",
            logs=external / "Logs",
            quarantine=external / "Quarantine",
        )

    def ensure(self) -> None:
        for folder in (self.control, self.inbox, self.outbox, self.status, self.logs, self.quarantine):
            folder.mkdir(parents=True, exist_ok=True)


def parse_kv_text(text: str) -> Dict[str, str]:
    data: Dict[str, str] = {}
    for raw_line in text.splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        data[key.strip()] = value.strip()
    return data


def read_text(path: Path) -> str:
    last_error: PermissionError | OSError | None = None
    for attempt in range(READ_RETRY_ATTEMPTS):
        try:
            return path.read_text(encoding="utf-8", errors="replace")
        except (PermissionError, OSError) as exc:
            # MT5 may briefly hold files while publishing. Retry boundedly, then let
            # the caller record the final failure instead of poisoning daemon state.
            last_error = exc
            if attempt + 1 >= READ_RETRY_ATTEMPTS:
                break
            time.sleep(READ_RETRY_BACKOFF_SECONDS * (attempt + 1))
    assert last_error is not None
    raise last_error


def read_kv(path: Path) -> Dict[str, str]:
    return parse_kv_text(read_text(path))


def split_snapshot(text: str) -> Tuple[Dict[str, str], List[str]]:
    # Snapshot format is header key=value lines, blank line, then pipe-delimited rows.
    normalized = text.replace("\r\n", "\n")
    header_text, sep, rows_text = normalized.partition("\n\n")
    if not sep:
        return parse_kv_text(header_text), []
    rows = [line for line in rows_text.splitlines() if line.strip()]
    return parse_kv_text(header_text), rows


def payload_checksum(payload_rows: Iterable[str]) -> str:
    payload = "\r\n".join(payload_rows)
    if payload:
        payload += "\r\n"
    checksum = 0
    for index, ch in enumerate(payload):
        checksum = (checksum + (ord(ch) * (index + 1))) % 2147483647
    return str(checksum)


def _write_text_file_durable(path: Path, text: str) -> None:
    with path.open("w", encoding="utf-8", newline="") as handle:
        handle.write(text)
        handle.flush()
        os.fsync(handle.fileno())


def _cleanup_stale_tmp(path: Path) -> None:
    try:
        if path.exists():
            path.unlink()
    except OSError:
        pass


def _write_atomic_failure_sidecar(path: Path, exc: BaseException) -> None:
    # Best-effort only. Never let failed proof writing crash the Gateway daemon.
    try:
        sidecar = path.with_name(path.name + ".write_failed.txt")
        text = "\n".join([
            "schema_name=aurora_gateway_write_failure",
            "schema_version=2",
            f"target_path={path}",
            "write_status=failed",
            "write_ok=false",
            f"error_type={type(exc).__name__}",
            f"error={str(exc).replace(chr(13), ' ').replace(chr(10), ' ')}",
            f"generated_utc={utc_stamp()}",
            f"generated_unix={unix_time()}",
            "authority=calculation_support_only",
            "trade_permission=false",
            "",
        ])
        tmp = sidecar.with_name(f"{sidecar.name}.{os.getpid()}.{unix_time()}.tmp")
        _write_text_file_durable(tmp, text)
        try:
            os.replace(tmp, sidecar)
        except OSError:
            _cleanup_stale_tmp(tmp)
    except OSError:
        pass


def atomic_write_text(path: Path, text: str) -> bool:
    """Durable best-effort atomic text write for Windows/MT5 shared files.

    Windows can briefly lock the final status file while MT5, Explorer, antivirus,
    or another reader opens it. A transient WinError 32 must not kill the packaged
    Gateway daemon or create popup storms. Use a unique tmp per process/write,
    retry boundedly, and degrade with a sidecar proof if replacement stays locked.

    Returns True only when the final replace succeeded. Returns False after a
    bounded replace failure and best-effort sidecar proof. Callers that publish
    heartbeat/result/status files must propagate False as degraded write truth.
    """
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_name(f"{path.name}.{os.getpid()}.{time.time_ns()}.tmp")
    last_error: PermissionError | OSError | None = None
    try:
        _write_text_file_durable(tmp, text)
        for attempt in range(WRITE_REPLACE_RETRY_ATTEMPTS):
            try:
                os.replace(tmp, path)
                return True
            except (PermissionError, OSError) as exc:
                last_error = exc
                if attempt + 1 >= WRITE_REPLACE_RETRY_ATTEMPTS:
                    break
                time.sleep(WRITE_REPLACE_RETRY_BACKOFF_SECONDS * (attempt + 1))
        assert last_error is not None
        _write_atomic_failure_sidecar(path, last_error)
        return False
    finally:
        _cleanup_stale_tmp(tmp)


def unix_time() -> int:
    return int(time.time())


def utc_stamp() -> str:
    return time.strftime("%Y-%m-%d %H:%M:%S UTC", time.gmtime())