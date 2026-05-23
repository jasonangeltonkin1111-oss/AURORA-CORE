from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Iterable, List

from aurora_worker_io import payload_checksum, read_text
from aurora_worker_l9_contract import L9_TF_WEIGHTS


@dataclass(frozen=True)
class L9OhlcBar:
    bar_time: int
    open_i: int
    high_i: int
    low_i: int
    close_i: int
    tick_volume: int
    spread: int
    real_volume: int


@dataclass(frozen=True)
class L9WindowPacket:
    symbol: str
    symbol_dir: Path
    windows: Dict[str, List[L9OhlcBar]]
    window_checksums: Dict[str, str]
    files_seen: int
    files_missing: int
    required_seen: int
    required_missing: int
    aggregate_checksum: str
    latest_close_i: int
    status: str
    reason: str


def sanitize_path_part(value: str) -> str:
    safe = str(value).strip() or "unknown"
    for ch in ['\\', '/', ':', '*', '?', '"', '<', '>', '|', ' ']:
        safe = safe.replace(ch, "_")
    return safe


def shared_ohlc_store_root(outbox: Path) -> Path:
    # outbox = <server>/<account>/Workbench/Gateway/Outbox
    account_root = outbox.parents[2]
    server_root = account_root.parent
    return server_root / "Shared Market Data" / "OHLC Store"


def symbol_priority_window_dir(outbox: Path, symbol: str) -> Path:
    return shared_ohlc_store_root(outbox) / "Symbols" / sanitize_path_part(symbol) / "Priority Windows"


def _file_payload_checksum(path: Path) -> str:
    if not path.exists():
        return "missing"
    rows = [line for line in read_text(path).replace("\r\n", "\n").splitlines() if line.strip()]
    return payload_checksum(rows)


def _parse_int(value: str, default: int = 0) -> int:
    try:
        return int(float(str(value).strip()))
    except (TypeError, ValueError):
        return default


def read_priority_window(path: Path) -> List[L9OhlcBar]:
    """Read a Runtime 1 OHLC priority-window CSV.

    This module only reads existing files. It does not call MT5, does not fetch
    broker history, does not create a second OHLC route, and does not repair or
    backfill missing bars. Missing or malformed data must be reported upward as
    degraded structure-location truth.
    """
    if not path.exists():
        return []
    rows: List[L9OhlcBar] = []
    for raw in read_text(path).replace("\r\n", "\n").splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or line.startswith("bar_time"):
            continue
        parts = [part.strip() for part in line.split(",")]
        if len(parts) < 8:
            continue
        rows.append(
            L9OhlcBar(
                bar_time=_parse_int(parts[0]),
                open_i=_parse_int(parts[1]),
                high_i=_parse_int(parts[2]),
                low_i=_parse_int(parts[3]),
                close_i=_parse_int(parts[4]),
                tick_volume=_parse_int(parts[5]),
                spread=_parse_int(parts[6]),
                real_volume=_parse_int(parts[7]),
            )
        )
    rows.sort(key=lambda row: row.bar_time, reverse=True)
    return rows


def required_timeframes() -> List[str]:
    return list(L9_TF_WEIGHTS.keys())


def load_l9_window_packet(outbox: Path, symbol: str, extra_timeframes: Iterable[str] = ()) -> L9WindowPacket:
    symbol_dir = symbol_priority_window_dir(outbox, symbol)
    tfs: List[str] = []
    for tf in list(required_timeframes()) + [str(tf).upper() for tf in extra_timeframes]:
        if tf and tf not in tfs:
            tfs.append(tf)

    windows: Dict[str, List[L9OhlcBar]] = {}
    checksums: Dict[str, str] = {}
    files_seen = 0
    files_missing = 0
    required_seen = 0
    required_missing = 0
    aggregate_parts: List[str] = []
    latest_close_i = 0

    required = set(required_timeframes())
    for tf in tfs:
        path = symbol_dir / f"{tf}.window.csv"
        checksum = _file_payload_checksum(path)
        bars = read_priority_window(path)
        windows[tf] = bars
        checksums[f"{tf.lower()}_window_checksum"] = checksum
        aggregate_parts.append(f"{tf}={checksum}")
        if checksum == "missing":
            files_missing += 1
            if tf in required:
                required_missing += 1
        else:
            files_seen += 1
            if tf in required:
                required_seen += 1
            if latest_close_i <= 0 and bars:
                latest_close_i = bars[0].close_i

    aggregate_checksum = payload_checksum(aggregate_parts)
    if required_missing == 0 and required_seen == len(required):
        status = "ready"
        reason = "all_required_l9_priority_windows_present"
    elif required_seen > 0:
        status = "partial"
        reason = "some_required_l9_priority_windows_missing"
    else:
        status = "missing"
        reason = "all_required_l9_priority_windows_missing"

    return L9WindowPacket(
        symbol=str(symbol).strip(),
        symbol_dir=symbol_dir,
        windows=windows,
        window_checksums=checksums,
        files_seen=files_seen,
        files_missing=files_missing,
        required_seen=required_seen,
        required_missing=required_missing,
        aggregate_checksum=aggregate_checksum,
        latest_close_i=latest_close_i,
        status=status,
        reason=reason,
    )


def range_points(bars: List[L9OhlcBar], count: int) -> float:
    subset = bars[: max(0, count)]
    if not subset:
        return 0.0
    return float(max(bar.high_i for bar in subset) - min(bar.low_i for bar in subset))


def true_ranges(bars: List[L9OhlcBar], count: int) -> List[float]:
    subset = bars[: max(0, count)]
    values: List[float] = []
    for index, bar in enumerate(subset):
        high_low = max(0, bar.high_i - bar.low_i)
        if index + 1 < len(bars):
            prev_close = bars[index + 1].close_i
            tr = max(high_low, abs(bar.high_i - prev_close), abs(bar.low_i - prev_close))
        else:
            tr = high_low
        values.append(float(max(0, tr)))
    return values


def avg_true_range(bars: List[L9OhlcBar], count: int) -> float:
    values = true_ranges(bars, count)
    return 0.0 if not values else sum(values) / float(len(values))
