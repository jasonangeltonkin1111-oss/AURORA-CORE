from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Sequence, Tuple
import math
import re
import time

from aurora_worker_io import WorkerPaths, atomic_write_text, read_kv, read_text, unix_time, utc_stamp

SELECTION_DEEP_START = "========== SELECTION-ONLY DEEP EVIDENCE START =========="
SELECTION_DEEP_END = "========== SELECTION-ONLY DEEP EVIDENCE END =========="
L19_START = "----- L19 WICK CANDLE GEOMETRY PACK START -----"
L19_END = "----- L19 WICK CANDLE GEOMETRY PACK END -----"

DISPLAY_BARS: Dict[str, int] = {"M5": 5, "M15": 5, "H1": 5, "H4": 5, "D1": 5}
RANKED_DOSSIER_RE = re.compile(r"^\d{2}_(.+)\.txt$")
L19_SOURCE_CONTRACT_ACTIVE = "l19_selected_wick_candle_geometry_only_from_l18_selected_raw_ohlc"


@dataclass(frozen=True)
class CandleGeometry:
    index: int
    bar_time: str
    bar_time_readable: str
    bar_state: str
    open_price: str
    high_price: str
    low_price: str
    close_price: str
    range_text: str
    body_text: str
    upper_wick_text: str
    lower_wick_text: str
    body_pct: str
    upper_wick_pct: str
    lower_wick_pct: str
    close_position_pct: str
    close_vs_open: str
    geometry_state: str
    valid: bool
    zero_range: bool
    invalid_reason: str = ""
    open_i: int = 0
    high_i: int = 0
    low_i: int = 0
    close_i: int = 0
    range_i: int = 0
    body_i: int = 0
    upper_wick_i: int = 0
    lower_wick_i: int = 0


@dataclass(frozen=True)
class TimeframeGeometrySummary:
    timeframe: str
    status: str
    rows_requested: int
    rows_available: int
    rows_valid: int
    zero_range_rows: int
    invalid_rows: int
    latest_time: str
    latest_geometry_state: str
    rendered_rows: Tuple[CandleGeometry, ...]


@dataclass(frozen=True)
class L19PublishSummary:
    status: str
    reason: str
    selected_dossiers_seen: int = 0
    selected_dossiers_decorated: int = 0
    selected_dossiers_missing_symbol: int = 0
    source_files_expected: int = 0
    source_files_found: int = 0
    source_files_missing: int = 0
    source_files_partial: int = 0
    source_decode_errors: int = 0
    rows_rendered_to_dossiers: int = 0
    valid_geometry_rows: int = 0
    zero_range_rows: int = 0
    invalid_geometry_rows: int = 0
    wave2_rows_tagged: int = 0  # retained as backward-compatible status field; L19 geometry-only always leaves this 0
    wave3_rows_tagged: int = 0  # retained as backward-compatible status field; L19 geometry-only always leaves this 0
    topview_cleanup_count: int = 0
    write_failed_count: int = 0
    m5_completed_symbols: int = 0
    m5_partial_symbols: int = 0
    m5_missing_symbols: int = 0
    m15_completed_symbols: int = 0
    m15_partial_symbols: int = 0
    m15_missing_symbols: int = 0
    h1_completed_symbols: int = 0
    h1_partial_symbols: int = 0
    h1_missing_symbols: int = 0
    h4_completed_symbols: int = 0
    h4_partial_symbols: int = 0
    h4_missing_symbols: int = 0
    d1_completed_symbols: int = 0
    d1_partial_symbols: int = 0
    d1_missing_symbols: int = 0
    selected_route_dossiers_seen: int = 0
    selected_route_dossiers_decorated: int = 0
    selected_unique_symbols_seen: int = 0
    selected_duplicate_route_copies: int = 0
    latest_bar_age_max_seconds: int = -1
    freshness_fresh_count: int = 0
    freshness_aging_count: int = 0
    freshness_stale_count: int = 0
    freshness_unknown_count: int = 0
    freshness_status: str = "unknown"
    freshness_policy: str = "derived_from_existing_shared_ohlc_seed_latest_bar_time"
    upstream_l17_status: str = "unknown"
    upstream_l17_current_chain_valid: str = "false"
    upstream_l18_status: str = "unknown"
    upstream_l18_current_chain_valid: str = "false"
    latest_current: str = "false"
    downstream_allowed: str = "false"
    visible_output_source: str = "none"
    currentness_reason: str = "not_run"
    status_path: str = "not_available"
    board_path: str = "not_available"
    layer_folder: str = "not_available"


EMPTY_L19_SUMMARY = L19PublishSummary("pending", "l19_not_run")


def _account_root(root: Path) -> Path:
    return WorkerPaths.from_root(root).root


def _selection_desk(root: Path) -> Path:
    return _account_root(root) / "Selection Desk"


def _shared_ohlc_symbols(root: Path) -> Path:
    return _account_root(root).parent / "Shared Market Data" / "OHLC Store" / "Symbols"


def _layer_folder(root: Path) -> Path:
    return WorkerPaths.from_root(root).outbox / "Layers" / "Layer_19_Wick_Candle_Geometry_Pack"


def _upstream_currentness_gate(root: Path) -> Tuple[bool, Dict[str, str], str]:
    result_path = WorkerPaths.from_root(root).outbox / "result_latest.txt"
    if not result_path.exists():
        return False, {}, "result_latest_missing_l17_l18_currentness_unknown"
    kv = read_kv(result_path)
    l17_status = kv.get("l17_deep_evidence_selection_status", "unknown")
    l17_current = kv.get("l17_current_chain_valid", "false").strip().lower()
    l17_downstream = kv.get("l17_downstream_allowed", "false").strip().lower()
    l18_status = kv.get("l18_selected_raw_ohlc_status", "unknown")
    l18_current = kv.get("l18_current_chain_valid", "false").strip().lower()
    l18_downstream = kv.get("l18_downstream_allowed", "false").strip().lower()
    l18_current_status_ok = l18_status in {"accepted", "complete_history_limited"}
    if l17_status == "accepted" and l17_current == "true" and l17_downstream == "true" and l18_current_status_ok and l18_current == "true" and l18_downstream == "true":
        return True, kv, f"l17_current=true;l18_current=true;l18_status={l18_status}"
    return False, kv, (
        f"l17_status={l17_status};l17_current={l17_current};l17_downstream_allowed={l17_downstream};"
        f"l18_status={l18_status};l18_current={l18_current};l18_downstream_allowed={l18_downstream}"
    )


def _write(path: Path, text: str, failed: List[Path]) -> bool:
    ok = atomic_write_text(path, text)
    if not ok:
        failed.append(path)
    return ok


def _selected_dossier_paths(root: Path) -> List[Path]:
    desk = _selection_desk(root)
    candidates: List[Path] = []
    candidates.extend((desk / "01_Global" / "Top_10").glob("*.txt"))
    candidates.extend((desk / "02_Asset_Classes").glob("*/01_Top_5_All_*/*.txt"))
    candidates.extend((desk / "02_Asset_Classes").glob("*/02_Groups/*/*.txt"))
    unique: List[Path] = []
    seen = set()
    for path in candidates:
        if path.name.startswith("00_") or not RANKED_DOSSIER_RE.match(path.name):
            continue
        key = str(path)
        if key in seen:
            continue
        seen.add(key)
        unique.append(path)
    return sorted(unique)


def _symbol_from_dossier(path: Path) -> str:
    match = RANKED_DOSSIER_RE.match(path.name)
    return match.group(1) if match else ""


def _ohlc_path(root: Path, symbol: str, timeframe: str) -> Path:
    return _shared_ohlc_symbols(root) / symbol / f"{timeframe}.seed.csv"


def _parse_header_and_rows(text: str) -> Tuple[Dict[str, str], List[List[str]]]:
    meta: Dict[str, str] = {}
    rows: List[List[str]] = []
    for raw in text.replace("\r\n", "\n").splitlines():
        line = raw.strip()
        if not line:
            continue
        if line.startswith("#"):
            payload = line[1:]
            if "=" in payload:
                key, value = payload.split("=", 1)
                meta[key.strip()] = value.strip()
            continue
        if line.startswith("bar_time,"):
            continue
        parts = [p.strip() for p in line.split(",")]
        if len(parts) >= 8:
            rows.append(parts[:8])
    return meta, rows


def _format_price(value_i: int, point: float | None, digits: int | None) -> str:
    if point is None or point <= 0:
        return str(value_i)
    value = value_i * point
    if digits is not None and digits >= 0:
        return f"{value:.{digits}f}"
    return f"{value:.8f}".rstrip("0").rstrip(".")


def _format_scaled(value_i: int, point: float | None, digits: int | None) -> str:
    scale = point if point is not None and point > 0 else 1.0
    value = value_i * scale
    if not math.isfinite(value):
        return "n/a"
    precision = digits if digits is not None and 0 <= digits <= 8 else 8
    return f"{value:.{precision}f}".rstrip("0").rstrip(".")


def _format_bar_time(raw_value: str) -> str:
    try:
        ts = int(float(raw_value))
        if ts <= 0:
            return "not_available"
        return time.strftime("%Y.%m.%d %H:%M:%S", time.gmtime(ts))
    except Exception:
        return "not_available"


def _pct(value: float) -> str:
    return "n/a" if not math.isfinite(value) else f"{value:.1f}%"


def _invalid_geometry(
    idx: int,
    bar_time: str,
    bar_state: str,
    open_text: str,
    high_text: str,
    low_text: str,
    close_text: str,
    reason: str,
    open_i: int = 0,
    high_i: int = 0,
    low_i: int = 0,
    close_i: int = 0,
) -> CandleGeometry:
    return CandleGeometry(
        idx,
        bar_time or "missing",
        _format_bar_time(bar_time or "0"),
        bar_state,
        open_text,
        high_text,
        low_text,
        close_text,
        "n/a",
        "n/a",
        "n/a",
        "n/a",
        "n/a",
        "n/a",
        "n/a",
        "n/a",
        "Unknown",
        "Invalid",
        False,
        False,
        reason,
        open_i,
        high_i,
        low_i,
        close_i,
    )


def _build_geometry(idx: int, row: Sequence[str], point: float | None, digits: int | None) -> CandleGeometry:
    try:
        bar_time, open_raw, high_raw, low_raw, close_raw, _tick_volume, _spread, _real_volume = row[:8]
        open_i = int(float(open_raw))
        high_i = int(float(high_raw))
        low_i = int(float(low_raw))
        close_i = int(float(close_raw))
    except Exception as exc:
        return _invalid_geometry(idx, "decode_error", "Unknown", "n/a", "n/a", "n/a", "n/a", f"decode error {type(exc).__name__}")

    bar_state = "Current Possible" if idx == 0 else "Closed Assumed"
    open_text = _format_price(open_i, point, digits)
    high_text = _format_price(high_i, point, digits)
    low_text = _format_price(low_i, point, digits)
    close_text = _format_price(close_i, point, digits)

    if not bar_time or bar_time == "0":
        return _invalid_geometry(idx, bar_time or "missing", bar_state, open_text, high_text, low_text, close_text, "missing bar time", open_i, high_i, low_i, close_i)
    if high_i < low_i:
        return _invalid_geometry(idx, bar_time, bar_state, open_text, high_text, low_text, close_text, "high below low", open_i, high_i, low_i, close_i)
    if open_i < low_i or open_i > high_i:
        return _invalid_geometry(idx, bar_time, bar_state, open_text, high_text, low_text, close_text, "open outside high low range", open_i, high_i, low_i, close_i)
    if close_i < low_i or close_i > high_i:
        return _invalid_geometry(idx, bar_time, bar_state, open_text, high_text, low_text, close_text, "close outside high low range", open_i, high_i, low_i, close_i)

    range_i = high_i - low_i
    if range_i == 0:
        close_vs_open = "Flat" if close_i == open_i else "Invalid"
        return CandleGeometry(
            idx,
            bar_time,
            _format_bar_time(bar_time),
            bar_state,
            open_text,
            high_text,
            low_text,
            close_text,
            "0",
            "0",
            "0",
            "0",
            "n/a",
            "n/a",
            "n/a",
            "n/a",
            close_vs_open,
            "Zero Range",
            False,
            True,
            "zero range",
            open_i,
            high_i,
            low_i,
            close_i,
            0,
            0,
            0,
            0,
        )

    body_i = abs(close_i - open_i)
    upper_i = high_i - max(open_i, close_i)
    lower_i = min(open_i, close_i) - low_i
    body_pct = body_i / range_i * 100.0
    upper_pct = upper_i / range_i * 100.0
    lower_pct = lower_i / range_i * 100.0
    close_pos = (close_i - low_i) / range_i * 100.0
    close_vs_open = "Up" if close_i > open_i else ("Down" if close_i < open_i else "Flat")

    return CandleGeometry(
        idx,
        bar_time,
        _format_bar_time(bar_time),
        bar_state,
        open_text,
        high_text,
        low_text,
        close_text,
        _format_scaled(range_i, point, digits),
        _format_scaled(body_i, point, digits),
        _format_scaled(upper_i, point, digits),
        _format_scaled(lower_i, point, digits),
        _pct(body_pct),
        _pct(upper_pct),
        _pct(lower_pct),
        _pct(close_pos),
        close_vs_open,
        "Geometry Only",
        True,
        False,
        "",
        open_i,
        high_i,
        low_i,
        close_i,
        range_i,
        body_i,
        upper_i,
        lower_i,
    )


def _render_timeframe(root: Path, symbol: str, timeframe: str, requested: int) -> Tuple[TimeframeGeometrySummary, str, bool, int, int]:
    path = _ohlc_path(root, symbol, timeframe)
    if not path.exists():
        summary = TimeframeGeometrySummary(timeframe, "missing", requested, 0, 0, 0, 0, "not_available", "None", tuple())
        return summary, f"[{timeframe}] source_status=missing path={path}\n", False, 0, 0
    try:
        meta, rows = _parse_header_and_rows(read_text(path))
        point = float(meta.get("point", "")) if meta.get("point", "") else None
        digits = int(float(meta.get("digits", ""))) if meta.get("digits", "") else None
        selected = list(reversed(rows[-requested:] if len(rows) > requested else rows))
        geometries = tuple(_build_geometry(idx, row, point, digits) for idx, row in enumerate(selected))
        valid_rows = sum(1 for geo in geometries if geo.valid)
        zero_rows = sum(1 for geo in geometries if geo.zero_range)
        invalid_rows = sum(1 for geo in geometries if not geo.valid and not geo.zero_range)
        status = "complete" if len(geometries) >= requested and invalid_rows == 0 else "partial"
        latest_time = geometries[0].bar_time_readable if geometries else "not_available"
        latest_state = geometries[0].geometry_state if geometries else "None"
        lines = [
            f"[{timeframe}] source_status={status} rows_shown={len(geometries)} requested_display_bars={requested} source_rows_available={len(rows)} time_basis=OHLC_Store_Unix_Time source_path={path}",
            "# | State | Time | Time Unix | O | H | L | C | Range | Body | Upper Wick | Lower Wick | Body % | Upper Wick % | Lower Wick % | Close Position % | Close vs Open | Geometry State",
        ]
        for geo in geometries:
            if geo.valid or geo.zero_range:
                lines.append(f"{geo.index} | {geo.bar_state} | {geo.bar_time_readable} | {geo.bar_time} | {geo.open_price} | {geo.high_price} | {geo.low_price} | {geo.close_price} | {geo.range_text} | {geo.body_text} | {geo.upper_wick_text} | {geo.lower_wick_text} | {geo.body_pct} | {geo.upper_wick_pct} | {geo.lower_wick_pct} | {geo.close_position_pct} | {geo.close_vs_open} | {geo.geometry_state}")
            else:
                lines.append(f"{geo.index} | {geo.bar_state} | {geo.bar_time_readable} | {geo.bar_time} | {geo.open_price} | {geo.high_price} | {geo.low_price} | {geo.close_price} | n/a | n/a | n/a | n/a | n/a | n/a | n/a | n/a | Unknown | Invalid: {geo.invalid_reason}")
        lines.append("")
        summary = TimeframeGeometrySummary(timeframe, status, requested, len(geometries), valid_rows, zero_rows, invalid_rows, latest_time, latest_state, geometries)
        return summary, "\n".join(lines), invalid_rows > 0, 0, 0
    except Exception as exc:
        safe_error = str(exc).replace(chr(10), " ").replace(chr(13), " ")
        summary = TimeframeGeometrySummary(timeframe, "decode_error", requested, 0, 0, 0, 1, "not_available", "None", tuple())
        return summary, f"[{timeframe}] source_status=decode_error error={type(exc).__name__}:{safe_error} path={path}\n", True, 0, 0


def _cleanup_selected_dossier_topview(existing_text: str) -> Tuple[str, int]:
    replacements = {
        "dossier_topview_v2_l15": "dossier_topview_v4_l19_geometry_selected_evidence",
        "dossier_topview_v3_l19_selected_evidence": "dossier_topview_v4_l19_geometry_selected_evidence",
        "dossier_topview_v4_l19_wave3_selected_evidence": "dossier_topview_v4_l19_geometry_selected_evidence",
        "Pipeline Position:   L15 correlation/diversity scored": "Pipeline Position:   L19 candle geometry available on selected copied dossier",
        "Pipeline Position:   L19 candle geometry and structure available on selected copied dossier": "Pipeline Position:   L19 wick/candle geometry available on selected copied dossier",
        "Pipeline Position:   L19 candle geometry available on selected copied dossier": "Pipeline Position:   L19 wick/candle geometry available on selected copied dossier",
        "L16 Global Top 10:            not_built_or_not_active_here": "L16 Global Top 10:            selected copied dossier when present in Selection Desk output",
        "Selection Active: L15 scoring only; no Global Top 10 or trade permission": "Selection Active: L16-L19 selected inspection evidence; no trade permission",
        "Next step: Layer 16 Global Top 10 builder after L15 correlation/diversity output is accepted.": "Next step: Layer 20 rolling tick pack after L19 candle geometry is accepted.",
        "Layer 11-15 are inspection/selection-scoring surfaces only; no Global Top 10, alert, or trade permission exists here.": "Layer 11-19 are inspection/evidence surfaces only; no setup alert or trade permission exists here.",
    }
    updated = existing_text
    count = 0
    for old, new in replacements.items():
        if old in updated:
            count += updated.count(old)
            updated = updated.replace(old, new)
    return updated, count


def _extract_block(text: str, start_marker: str, end_marker: str) -> str:
    normalized = (text or "").replace("\r\n", "\n")
    start = normalized.find(start_marker)
    if start < 0:
        return ""
    end = normalized.find(end_marker, start)
    if end < 0:
        return ""
    end += len(end_marker)
    return normalized[start:end].strip() + "\n"


def _replace_l19_in_deep_section(existing_text: str, l19_block: str) -> str:
    normalized = (existing_text or "").replace("\r\n", "\n").rstrip()
    normalized, _count = _cleanup_selected_dossier_topview(normalized)
    deep = _extract_block(normalized, SELECTION_DEEP_START, SELECTION_DEEP_END)
    if not deep:
        deep = "\n".join([SELECTION_DEEP_START, SELECTION_DEEP_END]) + "\n"
        base = normalized
    else:
        base = normalized.replace(deep.strip(), "").rstrip()
    old_l19_new = _extract_block(deep, L19_START, L19_END)
    old_l19_legacy = _extract_block(deep, "----- L19 CANDLE GEOMETRY AND STRUCTURE START -----", "----- L19 CANDLE GEOMETRY AND STRUCTURE END -----")
    old_l19 = old_l19_new or old_l19_legacy
    if old_l19:
        deep = deep.replace(old_l19.strip(), l19_block.strip())
    else:
        deep = deep.replace(SELECTION_DEEP_END, l19_block.strip() + "\n\n" + SELECTION_DEEP_END)
    return base.rstrip() + "\n\n" + deep.strip() + "\n"


def _empty_tf_counts() -> Dict[str, Dict[str, int]]:
    return {tf: {"complete": 0, "partial": 0, "missing": 0, "decode_error": 0} for tf in DISPLAY_BARS}


def _build_l19_block(symbol: str, rendered_sections: Sequence[str], tf_summaries: Dict[str, TimeframeGeometrySummary], wave2_tagged: int, wave3_tagged: int) -> str:
    rows_total = sum(summary.rows_available for summary in tf_summaries.values())
    valid_total = sum(summary.rows_valid for summary in tf_summaries.values())
    zero_total = sum(summary.zero_range_rows for summary in tf_summaries.values())
    invalid_total = sum(summary.invalid_rows for summary in tf_summaries.values())
    lines = [
        L19_START,
        "Layer:                  L19 Wick / Candle Geometry Pack",
        "Scope:                  Selection copied dossier only",
        "Source Contract:        L18 selected raw OHLC scope using existing Shared OHLC seed files",
        f"Source Contract Active: {L19_SOURCE_CONTRACT_ACTIVE}",
        "Rows Shown Per TF:      5",
        "Geometry Policy:        one-to-one candle geometry only; no pattern, setup, signal, or permission claim",
        "Time Basis:             OHLC Store Unix time rendered as readable store time plus raw Unix",
        "CopyRates By L19:       false",
        "Private OHLC Cache:     false",
        "Raw OHLC Store Writes:  false",
        "Trade Permission:       false",
        "Entry Signal:           false",
        "Execution:              false",
        f"Symbol:                 {symbol}",
        f"Rows Rendered:          {rows_total}",
        f"Valid Geometry Rows:    {valid_total}",
        f"Zero Range Rows:        {zero_total}",
        f"Invalid Rows:           {invalid_total}",
        "Pattern Rows Tagged:    0",
        "Meaning:                wick/body/range/close-position geometry only, not setup/signal/trade permission",
        "",
        "Mini Overview",
        "TF | Rows | Valid | Zero Range | Invalid | Latest Time | Latest Geometry State",
    ]
    for tf in DISPLAY_BARS:
        summary = tf_summaries.get(tf, TimeframeGeometrySummary(tf, "missing", DISPLAY_BARS[tf], 0, 0, 0, 0, "not_available", "None", tuple()))
        lines.append(f"{tf} | {summary.rows_available} | {summary.rows_valid} | {summary.zero_range_rows} | {summary.invalid_rows} | {summary.latest_time} | {summary.latest_geometry_state}")
    lines.extend(["", "LATEST WICK / CANDLE GEOMETRY"])
    lines.extend(rendered_sections)
    lines.append(L19_END)
    return "\n".join(lines) + "\n"


def _board_text(summary: L19PublishSummary) -> str:
    return "\n".join([
        "L19 - WICK / CANDLE GEOMETRY PACK",
        "--------------------------------------------------",
        "Purpose:                Calculate one-to-one candle geometry from selected L18 raw OHLC",
        "Scope:                  Canonical Selection Desk copied dossiers only",
        "Rows Shown Per TF:      5",
        f"Source Contract Active: {L19_SOURCE_CONTRACT_ACTIVE}",
        "Geometry Policy:        body/range/wicks/percentages/close-position/zero-range only",
        "Pattern Detection:      FALSE",
        "Setup Detection:        FALSE",
        "Time Basis:             OHLC Store Unix time rendered as readable store time plus raw Unix",
        "Source Contract:        L18 selected raw OHLC scope using existing Shared OHLC seed files",
        "CopyRates By L19:       FALSE",
        "Private OHLC Cache:     FALSE",
        "Raw OHLC Store Writes:  FALSE",
        "Trade Permission:       FALSE",
        "Entry Signal:           FALSE",
        "Execution:              FALSE",
        "",
        "Selection Coverage",
        f"Selected Dossiers Seen:       {summary.selected_dossiers_seen}",
        f"Selected Dossiers Decorated:  {summary.selected_dossiers_decorated}",
        f"Selected Missing Symbol:      {summary.selected_dossiers_missing_symbol}",
        f"Top View Cleanup Replacements:{summary.topview_cleanup_count}",
        f"Route Dossiers Seen:          {summary.selected_route_dossiers_seen}",
        f"Route Dossiers Decorated:     {summary.selected_route_dossiers_decorated}",
        f"Unique Symbols Seen:          {summary.selected_unique_symbols_seen}",
        f"Duplicate Route Copies:       {summary.selected_duplicate_route_copies}",
        "",
        "Geometry Coverage",
        f"M5:   completed_symbols={summary.m5_completed_symbols}/{summary.selected_dossiers_seen} partial_symbols={summary.m5_partial_symbols} missing_symbols={summary.m5_missing_symbols}",
        f"M15:  completed_symbols={summary.m15_completed_symbols}/{summary.selected_dossiers_seen} partial_symbols={summary.m15_partial_symbols} missing_symbols={summary.m15_missing_symbols}",
        f"H1:   completed_symbols={summary.h1_completed_symbols}/{summary.selected_dossiers_seen} partial_symbols={summary.h1_partial_symbols} missing_symbols={summary.h1_missing_symbols}",
        f"H4:   completed_symbols={summary.h4_completed_symbols}/{summary.selected_dossiers_seen} partial_symbols={summary.h4_partial_symbols} missing_symbols={summary.h4_missing_symbols}",
        f"D1:   completed_symbols={summary.d1_completed_symbols}/{summary.selected_dossiers_seen} partial_symbols={summary.d1_partial_symbols} missing_symbols={summary.d1_missing_symbols}",
        "",
        "Latest L19 Update",
        f"Status:                       {summary.status}",
        f"Reason:                       {summary.reason}",
        f"Source Files Found:           {summary.source_files_found} / {summary.source_files_expected}",
        f"Source Files Missing:         {summary.source_files_missing}",
        f"Source Files Partial:         {summary.source_files_partial}",
        f"Source Decode Errors:         {summary.source_decode_errors}",
        f"Rows Rendered To Dossiers:    {summary.rows_rendered_to_dossiers}",
        f"Valid Geometry Rows:          {summary.valid_geometry_rows}",
        f"Zero Range Rows:              {summary.zero_range_rows}",
        f"Invalid Geometry Rows:        {summary.invalid_geometry_rows}",
        f"Pattern Rows Tagged:          0",
        f"Write Failed Count:           {summary.write_failed_count}",
        f"Freshness Status:             {summary.freshness_status}",
        f"Latest Bar Age Max Seconds:   {summary.latest_bar_age_max_seconds}",
        f"Freshness Counts:             fresh={summary.freshness_fresh_count} aging={summary.freshness_aging_count} stale={summary.freshness_stale_count} unknown={summary.freshness_unknown_count}",
        f"Generated UTC:                {utc_stamp()}",
        "",
    ])


def _status_text(summary: L19PublishSummary) -> str:
    return "\n".join([
        "schema_name=l19_wick_candle_geometry_status",
        "schema_version=4",
        f"status={summary.status}",
        f"reason={summary.reason}",
        "scope=canonical_selection_shortcut_dossiers_only",
        "source_contract=l18_selected_raw_ohlc_scope_using_existing_shared_ohlc_seed_files",
        f"source_contract_active={L19_SOURCE_CONTRACT_ACTIVE}",
        "rows_shown_per_tf=5",
        "geometry_policy=one_to_one_body_range_wicks_percentages_close_position_zero_range_only",
        "pattern_detection=false",
        "setup_detection=false",
        "time_basis=OHLC_Store_Unix_Time",
        "copyrates_by_l19=false",
        "private_ohlc_cache=false",
        "raw_ohlc_store_writes=false",
        f"selected_dossiers_seen={summary.selected_dossiers_seen}",
        f"selected_route_dossiers_seen={summary.selected_route_dossiers_seen}",
        f"selected_route_dossiers_decorated={summary.selected_route_dossiers_decorated}",
        f"selected_unique_symbols_seen={summary.selected_unique_symbols_seen}",
        f"selected_duplicate_route_copies={summary.selected_duplicate_route_copies}",
        f"selected_dossiers_decorated={summary.selected_dossiers_decorated}",
        f"selected_dossiers_missing_symbol={summary.selected_dossiers_missing_symbol}",
        f"source_files_expected={summary.source_files_expected}",
        f"source_files_found={summary.source_files_found}",
        f"source_files_missing={summary.source_files_missing}",
        f"source_files_partial={summary.source_files_partial}",
        f"source_decode_errors={summary.source_decode_errors}",
        f"rows_rendered_to_dossiers={summary.rows_rendered_to_dossiers}",
        f"valid_geometry_rows={summary.valid_geometry_rows}",
        f"zero_range_rows={summary.zero_range_rows}",
        f"invalid_geometry_rows={summary.invalid_geometry_rows}",
        "wave2_rows_tagged=0",
        "wave3_rows_tagged=0",
        f"topview_cleanup_count={summary.topview_cleanup_count}",
        f"write_failed_count={summary.write_failed_count}",
        f"latest_bar_age_max_seconds={summary.latest_bar_age_max_seconds}",
        f"freshness_fresh_count={summary.freshness_fresh_count}",
        f"freshness_aging_count={summary.freshness_aging_count}",
        f"freshness_stale_count={summary.freshness_stale_count}",
        f"freshness_unknown_count={summary.freshness_unknown_count}",
        f"freshness_status={summary.freshness_status}",
        f"freshness_policy={summary.freshness_policy}",
        f"upstream_l17_status={summary.upstream_l17_status}",
        f"upstream_l17_current_chain_valid={summary.upstream_l17_current_chain_valid}",
        f"upstream_l18_status={summary.upstream_l18_status}",
        f"upstream_l18_current_chain_valid={summary.upstream_l18_current_chain_valid}",
        f"latest_current={summary.latest_current}",
        f"downstream_allowed={summary.downstream_allowed}",
        f"visible_output_source={summary.visible_output_source}",
        f"currentness_reason={summary.currentness_reason}",
        f"m5_completed_symbols={summary.m5_completed_symbols}",
        f"m5_partial_symbols={summary.m5_partial_symbols}",
        f"m5_missing_symbols={summary.m5_missing_symbols}",
        f"m15_completed_symbols={summary.m15_completed_symbols}",
        f"m15_partial_symbols={summary.m15_partial_symbols}",
        f"m15_missing_symbols={summary.m15_missing_symbols}",
        f"h1_completed_symbols={summary.h1_completed_symbols}",
        f"h1_partial_symbols={summary.h1_partial_symbols}",
        f"h1_missing_symbols={summary.h1_missing_symbols}",
        f"h4_completed_symbols={summary.h4_completed_symbols}",
        f"h4_partial_symbols={summary.h4_partial_symbols}",
        f"h4_missing_symbols={summary.h4_missing_symbols}",
        f"d1_completed_symbols={summary.d1_completed_symbols}",
        f"d1_partial_symbols={summary.d1_partial_symbols}",
        f"d1_missing_symbols={summary.d1_missing_symbols}",
        f"status_path={summary.status_path}",
        f"board_path={summary.board_path}",
        "trade_permission=false",
        "entry_signal=false",
        "execution=false",
        f"generated_utc={utc_stamp()}",
        f"generated_unix={unix_time()}",
        "",
    ])


def _freshness_bucket(tf: str, age_seconds: int) -> str:
    caps = {"M5": (900, 1800), "M15": (1800, 3600), "H1": (7200, 14400), "H4": (21600, 43200), "D1": (172800, 345600)}
    fresh_cap, aging_cap = caps.get(tf, (1800, 3600))
    if age_seconds < 0:
        return "unknown"
    if age_seconds <= fresh_cap:
        return "fresh"
    if age_seconds <= aging_cap:
        return "aging"
    return "stale"


def _latest_age_seconds(root: Path, symbol: str, timeframe: str) -> int:
    path = _ohlc_path(root, symbol, timeframe)
    if not path.exists():
        return -1
    try:
        _meta, rows = _parse_header_and_rows(read_text(path))
        if not rows:
            return -1
        bar_time = int(float(rows[-1][0]))
        if bar_time <= 0:
            return -1
        return max(0, unix_time() - bar_time)
    except Exception:
        return -1


def publish_l19_candle_geometry_and_structure(root: Path) -> L19PublishSummary:
    failed: List[Path] = []
    layer_dir = _layer_folder(root)
    layer_dir.mkdir(parents=True, exist_ok=True)
    status_path = layer_dir / "l19_status.txt"
    board_path = _selection_desk(root) / "91_Layer_Summaries" / "L19_Wick_Candle_Geometry_Pack" / "00_L19_Board_Overview.txt"
    upstream_valid, upstream_kv, upstream_reason = _upstream_currentness_gate(root)
    if not upstream_valid:
        summary = L19PublishSummary(
            status="pending",
            reason="waiting_upstream_l17_l18_current;" + upstream_reason,
            upstream_l17_status=upstream_kv.get("l17_deep_evidence_selection_status", "unknown"),
            upstream_l17_current_chain_valid=upstream_kv.get("l17_current_chain_valid", "false"),
            upstream_l18_status=upstream_kv.get("l18_selected_raw_ohlc_status", "unknown"),
            upstream_l18_current_chain_valid=upstream_kv.get("l18_current_chain_valid", "false"),
            latest_current="false",
            downstream_allowed="false",
            visible_output_source="blocked",
            currentness_reason="waiting_upstream_l17_l18_current",
            status_path=str(status_path),
            board_path=str(board_path),
            layer_folder=str(layer_dir),
        )
        _write(status_path, _status_text(summary), failed)
        _write(board_path, _board_text(summary), failed)
        if failed:
            return L19PublishSummary(**{**summary.__dict__, "status": "write_degraded", "reason": "one_or_more_l19_waiting_outputs_failed", "write_failed_count": len(failed)})
        return summary
    dossiers = _selected_dossier_paths(root)
    tf_counts = _empty_tf_counts()
    decorated = missing_symbol = source_found = source_missing = source_partial = decode_errors = 0
    rows_total = valid_total = zero_total = invalid_total = topview_cleanup_total = 0
    source_expected = len(dossiers) * len(DISPLAY_BARS)
    route_seen = len(dossiers)
    route_decorated = 0
    unique_symbols = set()
    freshness = {"fresh": 0, "aging": 0, "stale": 0, "unknown": 0}
    latest_max_age = -1

    for dossier in dossiers:
        symbol = _symbol_from_dossier(dossier)
        if not symbol:
            missing_symbol += 1
            continue
        unique_symbols.add(symbol)
        rendered: List[str] = []
        tf_summaries: Dict[str, TimeframeGeometrySummary] = {}
        for tf, requested in DISPLAY_BARS.items():
            summary, section, had_decode_or_invalid, _wave2_tagged, _wave3_tagged = _render_timeframe(root, symbol, tf, requested)
            rendered.append(section)
            tf_summaries[tf] = summary
            rows_total += summary.rows_available
            valid_total += summary.rows_valid
            zero_total += summary.zero_range_rows
            invalid_total += summary.invalid_rows
            if summary.status == "missing":
                source_missing += 1
                tf_counts[tf]["missing"] += 1
            else:
                source_found += 1
                if summary.status == "complete":
                    tf_counts[tf]["complete"] += 1
                elif summary.status == "partial":
                    source_partial += 1
                    tf_counts[tf]["partial"] += 1
                else:
                    tf_counts[tf]["decode_error"] += 1
            if summary.status == "decode_error" or had_decode_or_invalid:
                decode_errors += 1
            age = _latest_age_seconds(root, symbol, tf)
            bucket = _freshness_bucket(tf, age)
            freshness[bucket] += 1
            if age > latest_max_age:
                latest_max_age = age
        try:
            existing = read_text(dossier)
            _cleaned, cleanup_count = _cleanup_selected_dossier_topview(existing)
            topview_cleanup_total += cleanup_count
            updated = _replace_l19_in_deep_section(existing, _build_l19_block(symbol, rendered, tf_summaries, 0, 0))
            if _write(dossier, updated, failed):
                decorated += 1
                route_decorated += 1
        except Exception:
            failed.append(dossier)

    has_errors = bool(failed) or source_missing > 0 or decode_errors > 0 or decorated == 0
    history_limited = source_partial > 0
    freshness_bad = freshness["stale"] > 0 or freshness["unknown"] > 0
    if not dossiers:
        status = "pending"
    elif has_errors:
        status = "partial"
    elif freshness_bad:
        status = "degraded"
    elif history_limited:
        status = "complete_history_limited"
    else:
        status = "accepted"
    reason = (
        "selected_dossiers_decorated_with_freshness_proof"
        if status == "accepted"
        else (
            "selected_dossiers_decorated_with_fresh_or_aging_limited_history"
            if status == "complete_history_limited"
            else "selected_dossiers_decorated_with_stale_or_unknown_freshness"
            if status == "degraded"
            else ("no_canonical_selected_dossiers_found" if not dossiers else "one_or_more_sources_missing_partial_invalid_or_write_failed")
        )
    )

    if freshness["unknown"] and not (freshness["fresh"] or freshness["aging"] or freshness["stale"]):
        freshness_status = "unknown"
    elif freshness["stale"] and not (freshness["fresh"] or freshness["aging"]):
        freshness_status = "stale"
    elif sum(1 for v in freshness.values() if v > 0) > 1:
        freshness_status = "mixed"
    elif freshness["fresh"] > 0:
        freshness_status = "fresh"
    else:
        freshness_status = "aging"

    summary = L19PublishSummary(
        status=status,
        reason=reason,
        selected_dossiers_seen=len(dossiers),
        selected_dossiers_decorated=decorated,
        selected_dossiers_missing_symbol=missing_symbol,
        source_files_expected=source_expected,
        source_files_found=source_found,
        source_files_missing=source_missing,
        source_files_partial=source_partial,
        source_decode_errors=decode_errors,
        rows_rendered_to_dossiers=rows_total,
        valid_geometry_rows=valid_total,
        zero_range_rows=zero_total,
        invalid_geometry_rows=invalid_total,
        wave2_rows_tagged=0,
        wave3_rows_tagged=0,
        topview_cleanup_count=topview_cleanup_total,
        write_failed_count=len(failed),
        m5_completed_symbols=tf_counts["M5"]["complete"],
        m5_partial_symbols=tf_counts["M5"]["partial"] + tf_counts["M5"]["decode_error"],
        m5_missing_symbols=tf_counts["M5"]["missing"],
        m15_completed_symbols=tf_counts["M15"]["complete"],
        m15_partial_symbols=tf_counts["M15"]["partial"] + tf_counts["M15"]["decode_error"],
        m15_missing_symbols=tf_counts["M15"]["missing"],
        h1_completed_symbols=tf_counts["H1"]["complete"],
        h1_partial_symbols=tf_counts["H1"]["partial"] + tf_counts["H1"]["decode_error"],
        h1_missing_symbols=tf_counts["H1"]["missing"],
        h4_completed_symbols=tf_counts["H4"]["complete"],
        h4_partial_symbols=tf_counts["H4"]["partial"] + tf_counts["H4"]["decode_error"],
        h4_missing_symbols=tf_counts["H4"]["missing"],
        d1_completed_symbols=tf_counts["D1"]["complete"],
        d1_partial_symbols=tf_counts["D1"]["partial"] + tf_counts["D1"]["decode_error"],
        d1_missing_symbols=tf_counts["D1"]["missing"],
        selected_route_dossiers_seen=route_seen,
        selected_route_dossiers_decorated=route_decorated,
        selected_unique_symbols_seen=len(unique_symbols),
        selected_duplicate_route_copies=max(0, route_seen - len(unique_symbols)),
        latest_bar_age_max_seconds=latest_max_age,
        freshness_fresh_count=freshness["fresh"],
        freshness_aging_count=freshness["aging"],
        freshness_stale_count=freshness["stale"],
        freshness_unknown_count=freshness["unknown"],
        freshness_status=freshness_status,
        freshness_policy="derived_from_existing_shared_ohlc_seed_latest_bar_time",
        upstream_l17_status=upstream_kv.get("l17_deep_evidence_selection_status", "accepted"),
        upstream_l17_current_chain_valid=upstream_kv.get("l17_current_chain_valid", "true"),
        upstream_l18_status=upstream_kv.get("l18_selected_raw_ohlc_status", "accepted"),
        upstream_l18_current_chain_valid=upstream_kv.get("l18_current_chain_valid", "true"),
        latest_current="true" if status in {"accepted", "complete_history_limited"} else "false",
        downstream_allowed="true" if status in {"accepted", "complete_history_limited"} else "false",
        visible_output_source="latest" if status in {"accepted", "complete_history_limited"} else "blocked",
        currentness_reason="latest_l19_built_from_current_l17_l18" if status in {"accepted", "complete_history_limited"} else "latest_l19_not_current",
        status_path=str(status_path),
        board_path=str(board_path),
        layer_folder=str(layer_dir),
    )
    _write(status_path, _status_text(summary), failed)
    _write(board_path, _board_text(summary), failed)
    return summary
