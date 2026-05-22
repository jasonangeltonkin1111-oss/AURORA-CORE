from __future__ import annotations

from logging import Formatter, LogRecord, getLogger
from logging.handlers import RotatingFileHandler
from pathlib import Path
from typing import Dict, Iterable, Mapping
import logging
import time

RECORDER_SCHEMA_VERSION = "1"
RECORDER_LOG_NAME = "gateway_addendum.log"
RECORDER_MAX_BYTES = 262_144
RECORDER_BACKUP_COUNT = 4

_LAST_SIGNATURES: Dict[str, str] = {}


def unix_time() -> int:
    return int(time.time())


def utc_stamp() -> str:
    return time.strftime("%Y-%m-%d %H:%M:%S UTC", time.gmtime())


def _safe_text(value: object) -> str:
    text = str(value)
    for old, new in (("\r", " "), ("\n", " "), ("|", "/")):
        text = text.replace(old, new)
    return text.strip()


def _signature(event_name: str, fields: Mapping[str, object], signature_fields: Iterable[str] | None) -> str:
    if signature_fields is None:
        signature_fields = ("event_status", "snapshot_id", "job_id", "result_status", "l6_rank_status", "l6_rank_reused_existing_outputs")
    parts = [event_name]
    for field in signature_fields:
        parts.append(f"{field}={_safe_text(fields.get(field, ''))}")
    return "|".join(parts)


def _write_rotating_line(log_dir: Path, line: str) -> bool:
    """Write one bounded Gateway recorder line and release the file handle immediately.

    Windows keeps active Python logging files locked while the handler stream is open.
    REC-001 is event-boundary and duplicate-throttled, not per-tick, so a transient
    RotatingFileHandler is safer than a cached long-lived handler. This preserves
    rotation while avoiding a persistent log-file handle that can block operator
    copy/zip workflows.
    """
    handler: RotatingFileHandler | None = None
    try:
        log_dir.mkdir(parents=True, exist_ok=True)
        handler = RotatingFileHandler(
            log_dir / RECORDER_LOG_NAME,
            maxBytes=RECORDER_MAX_BYTES,
            backupCount=RECORDER_BACKUP_COUNT,
            encoding="utf-8",
            delay=True,
        )
        handler.setFormatter(Formatter("%(message)s"))
        record = LogRecord(
            name="aurora.gateway.recorder.transient",
            level=logging.INFO,
            pathname=__file__,
            lineno=0,
            msg=line,
            args=(),
            exc_info=None,
        )
        handler.emit(record)
        handler.flush()
        return True
    except Exception:
        return False
    finally:
        if handler is not None:
            try:
                handler.close()
            except Exception:
                pass


def gateway_record_event_to_log_dir(
    log_dir: Path,
    event_name: str,
    fields: Mapping[str, object],
    *,
    signature_fields: Iterable[str] | None = None,
    force: bool = False,
) -> bool:
    """Write a bounded EXE-side Gateway addendum event to an explicit log directory.

    The recorder is intentionally best-effort. It never raises into Gateway runtime.
    Duplicate event signatures are skipped unless force=True. The active log handle
    is released immediately after each accepted event line.
    """
    try:
        sig = _signature(event_name, fields, signature_fields)
        sig_key = str(log_dir.resolve()) + "|" + event_name
        if not force and _LAST_SIGNATURES.get(sig_key) == sig:
            return False
        _LAST_SIGNATURES[sig_key] = sig

        record: Dict[str, object] = {
            "schema_name": "aurora_gateway_addendum_log",
            "schema_version": RECORDER_SCHEMA_VERSION,
            "event": event_name,
            "generated_utc": utc_stamp(),
            "generated_unix": unix_time(),
            "process_unix": int(time.time()),
        }
        record.update(fields)
        record.setdefault("authority", "calculation_support_only")
        record.setdefault("trade_permission", "false")
        record.setdefault("log_handle_policy", "open_emit_close")

        line = "|".join(f"{_safe_text(k)}={_safe_text(v)}" for k, v in record.items())
        return _write_rotating_line(log_dir, line)
    except Exception:
        return False


def gateway_record_event(
    root: Path,
    event_name: str,
    fields: Mapping[str, object],
    *,
    signature_fields: Iterable[str] | None = None,
    force: bool = False,
) -> bool:
    """Write a bounded EXE-side Gateway addendum event.

    This recorder is deliberately not an EA/MT5 logger. It writes from the packaged
    Gateway process into the account-local Workbench/Gateway/Logs folder.

    It is event-boundary and duplicate-throttled by default. If the same event
    signature repeats, it is skipped to avoid per-heartbeat log spam. It never
    raises into the daemon path; logging failure must not break Gateway calculation.
    """
    log_dir = root / "Workbench" / "Gateway" / "Logs"
    return gateway_record_event_to_log_dir(log_dir, event_name, fields, signature_fields=signature_fields, force=force)


def gateway_record_exception(root: Path, event_name: str, exc: BaseException, fields: Mapping[str, object] | None = None) -> bool:
    data: Dict[str, object] = dict(fields or {})
    data["event_status"] = "exception"
    data["exception_type"] = type(exc).__name__
    data["exception"] = str(exc)
    return gateway_record_event(root, event_name, data, force=True)
