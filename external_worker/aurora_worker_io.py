from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Iterable, List, Tuple
import os
import time


READ_RETRY_ATTEMPTS = 12
READ_RETRY_BACKOFF_SECONDS = 0.08
WRITE_REPLACE_RETRY_ATTEMPTS = 30
WRITE_REPLACE_RETRY_BACKOFF_SECONDS = 0.08
GATEWAY_FOLDER_NAME = "Gateway"
VOLATILE_COMPARE_PREFIXES = (
    "generated_utc=",
    "generated_unix=",
    "shortcut_generated_utc=",
    "shortcut_generated_unix=",
    "Generated UTC:",
    "Generated:",
)


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
        """Return the account-local Gateway folders written by MT5.

        MT5 route authority writes the calculation Gateway under:
            <account root>/Gateway/{Control,Inbox,Outbox,Status,Logs,Quarantine}

        Older worker code looked under <account root>/Workbench/Gateway, which made
        the daemon blind to the real MT5 snapshot/input files and left Layer 6 stuck
        pending/degraded. Keep all worker outputs account-local and do not create a
        second Workbench/Gateway authority.
        """
        gateway = root / GATEWAY_FOLDER_NAME
        return cls(
            root=root,
            control=gateway / "Control",
            inbox=gateway / "Inbox",
            outbox=gateway / "Outbox",
            status=gateway / "Status",
            logs=gateway / "Logs",
            quarantine=gateway / "Quarantine",
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


def _retry_sleep(attempt: int, base_seconds: float) -> None:
    time.sleep(base_seconds * (attempt + 1))


def dependency_lock_reason(path: Path, exc: BaseException) -> str:
    return f"dependency_file_locked_or_unreadable:path={path};error_type={type(exc).__name__};error={str(exc).replace(chr(13), ' ').replace(chr(10), ' ')}"


def read_text(path: Path) -> str:
    last_error: PermissionError | OSError | None = None
    for attempt in range(READ_RETRY_ATTEMPTS):
        try:
            return path.read_text(encoding="utf-8", errors="replace")
        except (PermissionError, OSError) as exc:
            last_error = exc
            if attempt + 1 >= READ_RETRY_ATTEMPTS:
                break
            _retry_sleep(attempt, READ_RETRY_BACKOFF_SECONDS)
    assert last_error is not None
    raise last_error


def read_kv(path: Path) -> Dict[str, str]:
    return parse_kv_text(read_text(path))


def split_snapshot(text: str) -> Tuple[Dict[str, str], List[str]]:
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


def _write_text_file_fast(path: Path, text: str) -> None:
    with path.open("w", encoding="utf-8", newline="") as handle:
        handle.write(text)
        handle.flush()


def _cleanup_stale_tmp(path: Path) -> None:
    try:
        if path.exists():
            path.unlink()
    except OSError:
        pass


def _clear_write_failure_sidecar(path: Path) -> None:
    sidecar = path.with_name(path.name + ".write_failed.txt")
    try:
        if sidecar.exists():
            sidecar.unlink()
    except OSError:
        pass


def _strip_volatile_lines_for_compare(text: str) -> str:
    normalized = text.replace("\r\n", "\n")
    kept: List[str] = []
    for raw in normalized.splitlines():
        stripped = raw.strip()
        if any(stripped.startswith(prefix) for prefix in VOLATILE_COMPARE_PREFIXES):
            continue
        kept.append(raw.rstrip())
    return "\n".join(kept).rstrip()


def _same_effective_text(path: Path, text: str, ignore_volatile_lines: bool) -> bool:
    if not path.exists() or not path.is_file():
        return False
    try:
        existing = read_text(path)
    except (PermissionError, OSError):
        return False
    if existing == text:
        return True
    if ignore_volatile_lines:
        return _strip_volatile_lines_for_compare(existing) == _strip_volatile_lines_for_compare(text)
    return False


def _write_atomic_failure_sidecar(path: Path, exc: BaseException) -> None:
    try:
        sidecar = path.with_name(path.name + ".write_failed.txt")
        text = "\n".join([
            "schema_name=aurora_gateway_write_failure",
            "schema_version=3",
            f"target_path={path}",
            "write_status=failed",
            "write_ok=false",
            f"retry_attempts={WRITE_REPLACE_RETRY_ATTEMPTS}",
            f"retry_backoff_seconds={WRITE_REPLACE_RETRY_BACKOFF_SECONDS}",
            f"error_type={type(exc).__name__}",
            f"error={str(exc).replace(chr(13), ' ').replace(chr(10), ' ')}",
            "failure_meaning=latest_write_failed_target_may_be_locked_or_permission_blocked",
            "currentness=false",
            f"generated_utc={utc_stamp()}",
            f"generated_unix={unix_time()}",
            "authority=calculation_support_only",
            "trade_permission=false",
            "",
        ])
        tmp = sidecar.with_name(f".aurora_fail_{os.getpid()}_{time.time_ns() & 0xffffffff:x}.tmp")
        _write_text_file_durable(tmp, text)
        try:
            os.replace(tmp, sidecar)
        except OSError:
            _cleanup_stale_tmp(tmp)
    except OSError:
        pass


def _atomic_write_text(path: Path, text: str, durable: bool) -> bool:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_name(f".aurora_tmp_{os.getpid()}_{time.time_ns() & 0xffffffff:x}.tmp")
    last_error: PermissionError | OSError | None = None
    try:
        if durable:
            _write_text_file_durable(tmp, text)
        else:
            _write_text_file_fast(tmp, text)
        for attempt in range(WRITE_REPLACE_RETRY_ATTEMPTS):
            try:
                os.replace(tmp, path)
                _clear_write_failure_sidecar(path)
                return True
            except (PermissionError, OSError) as exc:
                last_error = exc
                if attempt + 1 >= WRITE_REPLACE_RETRY_ATTEMPTS:
                    break
                _retry_sleep(attempt, WRITE_REPLACE_RETRY_BACKOFF_SECONDS)
        assert last_error is not None
        _write_atomic_failure_sidecar(path, last_error)
        return False
    finally:
        _cleanup_stale_tmp(tmp)


def atomic_write_text(path: Path, text: str) -> bool:
    return _atomic_write_text(path, text, durable=True)


def atomic_write_text_fast(path: Path, text: str) -> bool:
    return _atomic_write_text(path, text, durable=False)


def atomic_write_text_if_changed(path: Path, text: str, *, durable: bool = True, ignore_volatile_lines: bool = True) -> bool:
    if _same_effective_text(path, text, ignore_volatile_lines):
        _clear_write_failure_sidecar(path)
        return True
    return _atomic_write_text(path, text, durable=durable)


def unix_time() -> int:
    return int(time.time())


def utc_stamp() -> str:
    return time.strftime("%Y-%m-%d %H:%M:%S UTC", time.gmtime())
