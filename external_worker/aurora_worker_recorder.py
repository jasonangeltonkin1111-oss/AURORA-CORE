from __future__ import annotations

from logging import Formatter, getLogger
from logging.handlers import RotatingFileHandler
from pathlib import Path
from typing import Dict, Iterable, Mapping
import logging
import time

RECORDER_SCHEMA_VERSION = "1"
RECORDER_LOG_NAME = "gateway_addendum.log"
RECORDER_MAX_BYTES = 262_144
RECORDER_BACKUP_COUNT = 4

_LOGGERS: Dict[str, logging.Logger] = {}
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


def _logger_for(log_dir: Path) -> logging.Logger:
    key = str(log_dir.resolve())
    if key in _LOGGERS:
        return _LOGGERS[key]

    log_dir.mkdir(parents=True, exist_ok=True)
    logger = getLogger(f"aurora.gateway.recorder.{abs(hash(key))}")
    logger.setLevel(logging.INFO)
    logger.propagate = False

    if not logger.handlers:
        handler = RotatingFileHandler(
            log_dir / RECORDER_LOG_NAME,
            maxBytes=RECORDER_MAX_BYTES,
            backupCount=RECORDER_BACKUP_COUNT,
            encoding="utf-8",
            delay=True,
        )
        handler.setFormatter(Formatter("%(message)s"))
        logger.addHandler(handler)

    _LOGGERS[key] = logger
    return logger


def _signature(event_name: str, fields: Mapping[str, object], signature_fields: Iterable[str] | None) -> str:
    if signature_fields is None:
        signature_fields = ("event_status", "snapshot_id", "job_id", "result_status", "l6_rank_status", "l6_rank_reused_existing_outputs")
    parts = [event_name]
    for field in signature_fields:
        parts.append(f"{field}={_safe_text(fields.get(field, ''))}")
    return "|".join(parts)


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
    Duplicate event signatures are skipped unless force=True.
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

        line = "|".join(f"{_safe_text(k)}={_safe_text(v)}" for k, v in record.items())
        _logger_for(log_dir).info(line)
        return True
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
