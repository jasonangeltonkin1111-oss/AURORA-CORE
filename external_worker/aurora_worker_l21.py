from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Sequence, Tuple
import math
import re

from aurora_worker_io import WorkerPaths, atomic_write_text, read_text, unix_time, utc_stamp

SELECTION_DEEP_START = "========== SELECTION-ONLY DEEP EVIDENCE START =========="
SELECTION_DEEP_END = "========== SELECTION-ONLY DEEP EVIDENCE END =========="
L21_START = "----- L21 INDICATOR REFERENCE PACK START -----"
L21_END = "----- L21 INDICATOR REFERENCE PACK END -----"

RANKED_DOSSIER_RE = re.compile(r"^\d{2}_(.+)\.txt$")

REFERENCE_TIMEFRAMES: Dict[str, int] = {"M5": 220, "M15": 220, "H1": 220, "H4": 200, "D1": 200}
ATR_PERIOD = 14
BB_PERIOD = 20
BB_DEVIATION = 2.0
MA_PERIOD = 20
MA_SLOPE_LOOKBACK = 5
STDDEV_PERIOD = 20
VWAP_MAX_ROWS = 200


@dataclass(frozen=True)
class TimeframeReference:
    timeframe: str
    status: str
    reason: str
    source_rows_available: int = 0
    source_rows_used: int = 0
    latest_bar_time: str = "not_available"
    latest_close: str = "not_available"
    atr_period: int = ATR_PERIOD
    atr_value: str = "not_available"
    range_percentile_period: int = 100
    range_percentile_pct: str = "not_available"
    ma_period: int = MA_PERIOD
    ma_value: str = "not_available"
    ma_slope_lookback: int = MA_SLOPE_LOOKBACK
    ma_slope_points: str = "not_available"
    stddev_period: int = STDDEV_PERIOD
    stddev_value: str = "not_available"
    bb_period: int = BB_PERIOD
    bb_deviation: float = BB_DEVIATION
    bb_middle: str = "not_available"
    bb_upper: str = "not_available"
    bb_lower: str = "not_available"
    bb_width: str = "not_available"
    bb_width_pct: str = "not_available"
    bb_position_pct: str = "not_available"
    bb_squeeze_score: str = "not_available"
    bb_expansion_score: str = "not_available"
    vwap_value: str = "not_available"
    distance_to_vwap_points: str = "not_available"
    price_position_vs_vwap: str = "not_available"
    vwap_source: str = "unavailable"
    vwap_confidence: str = "unavailable"
    vwap_volume_sum: str = "0"
    spread_to_range_pct: str = "not_available"
    failure_reason: str = "none"


@dataclass(frozen=True)
class L21PublishSummary:
    status: str
    reason: str
    selected_dossiers_seen: int = 0
    selected_dossiers_decorated: int = 0
    selected_dossiers_missing_symbol: int = 0
    selected_route_dossiers_seen: int = 0
    selected_route_dossiers_decorated: int = 0
    selected_unique_symbols_seen: int = 0
    selected_duplicate_route_copies: int = 0
    source_files_expected: int = 0
    source_files_found: int = 0
    source_files_missing: int = 0
    source_files_partial: int = 0
    source_decode_errors: int = 0
    timeframe_packets_rendered: int = 0
    indicator_complete_packets: int = 0
    indicator_degraded_packets: int = 0
    indicator_missing_packets: int = 0
    vwap_real_volume_packets: int = 0
    vwap_tick_volume_proxy_packets: int = 0
    vwap_unavailable_packets: int = 0
    write_failed_count: int = 0
    latest_bar_age_max_seconds: int = -1
    freshness_status: str = "unknown"
    status_path: str = "not_available"
    board_path: str = "not_available"
    layer_folder: str = "not_available"


EMPTY_L21_SUMMARY = L21PublishSummary("pending", "l21_not_run")


def _account_root(root: Path) -> Path:
    return WorkerPaths.from_root(root).outbox.parents[2]


def _selection_desk(root: Path) -> Path:
    return _account_root(root) / "Selection Desk"


def _shared_ohlc_symbols(root: Path) -> Path:
    return _account_root(root).parent / "Shared Market Data" / "OHLC Store" / "Symbols"


def _layer_folder(root: Path) -> Path:
    return WorkerPaths.from_root(root).outbox / "Layers" / "Layer_21_Selected_Indicator_Reference_Pack"


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
        if key not in seen:
            seen.add(key)
            unique.append(path)
    return sorted(unique)


def _symbol_from_dossier(path: Path) -> str:
    match = RANKED_DOSSIER_RE.match(path.name)
    return match.group(1) if match else ""


def _ohlc_path(root: Path, symbol: str, timeframe: str) -> Path:
    return _shared_ohlc_symbols(root) / symbol / f"{timeframe}.seed.csv"


def _write(path: Path, text: str, failed: List[Path]) -> bool:
    ok = atomic_write_text(path, text)
    if not ok:
        failed.append(path)
    return ok


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


def _decode_rows(meta: Dict[str, str], rows: Sequence[List[str]]) -> Tuple[float | None, int | None, List[Dict[str, float]]]:
    point = float(meta.get("point", "0") or "0")
    digits_raw = meta.get("digits", "")
    digits = int(float(digits_raw)) if digits_raw else None
    if point <= 0:
        point = None

    decoded: List[Dict[str, float]] = []
    for row in rows:
        bar_time, open_i, high_i, low_i, close_i, tick_volume, spread, real_volume = row
        oi = int(float(open_i)); hi = int(float(high_i)); li = int(float(low_i)); ci = int(float(close_i))
        decoded.append({
            "bar_time": float(bar_time),
            "open_i": float(oi),
            "high_i": float(hi),
            "low_i": float(li),
            "close_i": float(ci),
            "open": oi * point if point else float(oi),
            "high": hi * point if point else float(hi),
            "low": li * point if point else float(li),
            "close": ci * point if point else float(ci),
            "tick_volume": float(tick_volume),
            "spread": float(spread),
            "real_volume": float(real_volume),
        })
    return point, digits, decoded


def _fmt_price(value: float, digits: int | None, point: float | None) -> str:
    if not math.isfinite(value):
        return "not_available"
    if point is not None and digits is not None and digits >= 0:
        return f"{value:.{digits}f}"
    if point is not None:
        return f"{value:.8f}".rstrip("0").rstrip(".")
    return str(int(round(value)))


def _fmt_points(value: float) -> str:
    return "not_available" if not math.isfinite(value) else str(int(round(value)))


def _fmt_pct(value: float) -> str:
    return "not_available" if not math.isfinite(value) else f"{value:.2f}"


def _mean(values: Sequence[float]) -> float:
    return sum(values) / len(values) if values else math.nan


def _stddev(values: Sequence[float]) -> float:
    if not values:
        return math.nan
    avg = _mean(values)
    return math.sqrt(sum((v - avg) ** 2 for v in values) / len(values))


def _true_ranges(rows: Sequence[Dict[str, float]]) -> List[float]:
    ranges: List[float] = []
    prev_close = math.nan
    for row in rows:
        high_i = row["high_i"]
        low_i = row["low_i"]
        close_i = row["close_i"]
        if math.isfinite(prev_close):
            ranges.append(max(high_i - low_i, abs(high_i - prev_close), abs(low_i - prev_close)))
        else:
            ranges.append(high_i - low_i)
        prev_close = close_i
    return ranges


def _classify_vwap_volume(rows: Sequence[Dict[str, float]]) -> Tuple[str, float, List[float]]:
    real_values = [row["real_volume"] for row in rows]
    tick_values = [row["tick_volume"] for row in rows]
    real_sum = sum(v for v in real_values if v > 0)
    tick_sum = sum(v for v in tick_values if v > 0)
    if real_sum > 0 and real_sum >= tick_sum * 0.50:
        return "real_volume", real_sum, [max(0.0, row["real_volume"]) for row in rows]
    if tick_sum > 0:
        return "tick_volume_proxy", tick_sum, [max(0.0, row["tick_volume"]) for row in rows]
    return "unavailable", 0.0, []


def _build_reference(root: Path, symbol: str, timeframe: str, requested: int) -> TimeframeReference:
    path = _ohlc_path(root, symbol, timeframe)
    if not path.exists():
        return TimeframeReference(timeframe, "missing", "shared_ohlc_seed_file_missing", failure_reason="shared_ohlc_seed_file_missing")
    try:
        meta, rows = _parse_header_and_rows(read_text(path))
        if not rows:
            return TimeframeReference(timeframe, "missing", "shared_ohlc_seed_file_empty", failure_reason="shared_ohlc_seed_file_empty")
        selected = rows[-requested:] if len(rows) > requested else rows
        point, digits, decoded = _decode_rows(meta, selected)
        used = len(decoded)
        minimum_required = max(BB_PERIOD + MA_SLOPE_LOOKBACK, ATR_PERIOD + 1, STDDEV_PERIOD)
        if used < minimum_required:
            status = "partial"
            reason = "insufficient_bars_for_full_indicator_reference"
        else:
            status = "complete"
            reason = "indicator_reference_calculated_from_shared_ohlc"

        closes_i = [row["close_i"] for row in decoded]
        ranges_i = [row["high_i"] - row["low_i"] for row in decoded]
        latest = decoded[-1]
        atr_values = _true_ranges(decoded)
        atr = _mean(atr_values[-ATR_PERIOD:]) if len(atr_values) >= ATR_PERIOD else math.nan
        range_window = ranges_i[-100:] if len(ranges_i) >= 1 else []
        latest_range = ranges_i[-1] if ranges_i else math.nan
        range_percentile = (sum(1 for r in range_window if r <= latest_range) / len(range_window) * 100.0) if range_window and math.isfinite(latest_range) else math.nan

        ma_window = closes_i[-MA_PERIOD:] if len(closes_i) >= MA_PERIOD else []
        ma_value_i = _mean(ma_window)
        prior_end = len(closes_i) - MA_SLOPE_LOOKBACK
        prior_window = closes_i[max(0, prior_end - MA_PERIOD):prior_end] if prior_end >= MA_PERIOD else []
        prior_ma_i = _mean(prior_window)
        ma_slope = ma_value_i - prior_ma_i if math.isfinite(ma_value_i) and math.isfinite(prior_ma_i) else math.nan

        stddev_i = _stddev(closes_i[-STDDEV_PERIOD:]) if len(closes_i) >= STDDEV_PERIOD else math.nan
        bb_mid_i = _mean(closes_i[-BB_PERIOD:]) if len(closes_i) >= BB_PERIOD else math.nan
        bb_std_i = _stddev(closes_i[-BB_PERIOD:]) if len(closes_i) >= BB_PERIOD else math.nan
        bb_upper_i = bb_mid_i + (BB_DEVIATION * bb_std_i) if math.isfinite(bb_mid_i) and math.isfinite(bb_std_i) else math.nan
        bb_lower_i = bb_mid_i - (BB_DEVIATION * bb_std_i) if math.isfinite(bb_mid_i) and math.isfinite(bb_std_i) else math.nan
        bb_width_i = bb_upper_i - bb_lower_i if math.isfinite(bb_upper_i) and math.isfinite(bb_lower_i) else math.nan
        latest_close_i = latest["close_i"]
        bb_position = ((latest_close_i - bb_lower_i) / bb_width_i * 100.0) if math.isfinite(bb_width_i) and bb_width_i > 0 else math.nan
        avg_width_window = []
        if len(closes_i) >= BB_PERIOD + 19:
            for end in range(BB_PERIOD, len(closes_i) + 1):
                window = closes_i[end - BB_PERIOD:end]
                avg_width_window.append(BB_DEVIATION * 2.0 * _stddev(window))
        avg_width = _mean(avg_width_window[-20:]) if avg_width_window else math.nan
        squeeze_score = max(0.0, min(100.0, (1.0 - (bb_width_i / avg_width)) * 100.0)) if math.isfinite(bb_width_i) and math.isfinite(avg_width) and avg_width > 0 else math.nan
        expansion_score = max(0.0, min(100.0, ((bb_width_i / avg_width) - 1.0) * 100.0)) if math.isfinite(bb_width_i) and math.isfinite(avg_width) and avg_width > 0 else math.nan

        vwap_rows = decoded[-VWAP_MAX_ROWS:]
        volume_source, volume_sum, volumes = _classify_vwap_volume(vwap_rows)
        if volume_source == "unavailable" or volume_sum <= 0:
            vwap_i = math.nan
            distance_i = math.nan
            vwap_confidence = "unavailable"
            price_position = "not_available"
        else:
            weighted_sum = 0.0
            for row, volume in zip(vwap_rows, volumes):
                typical_i = (row["high_i"] + row["low_i"] + row["close_i"]) / 3.0
                weighted_sum += typical_i * volume
            vwap_i = weighted_sum / volume_sum
            distance_i = latest_close_i - vwap_i
            vwap_confidence = "medium_tick_volume_proxy" if volume_source == "tick_volume_proxy" else "medium_real_volume"
            price_position = "above_vwap" if distance_i > 0 else "below_vwap" if distance_i < 0 else "at_vwap"

        latest_spread = latest["spread"]
        latest_range_for_spread = latest_range if latest_range > 0 else math.nan
        spread_to_range_pct = (latest_spread / latest_range_for_spread * 100.0) if math.isfinite(latest_range_for_spread) else math.nan

        price_scale = point if point is not None else 1.0
        return TimeframeReference(
            timeframe=timeframe,
            status=status,
            reason=reason,
            source_rows_available=len(rows),
            source_rows_used=used,
            latest_bar_time=str(int(latest["bar_time"])) if latest["bar_time"] > 0 else "not_available",
            latest_close=_fmt_price(latest["close"], digits, point),
            atr_value=_fmt_price(atr * price_scale, digits, point),
            range_percentile_pct=_fmt_pct(range_percentile),
            ma_value=_fmt_price(ma_value_i * price_scale, digits, point),
            ma_slope_points=_fmt_points(ma_slope),
            stddev_value=_fmt_price(stddev_i * price_scale, digits, point),
            bb_middle=_fmt_price(bb_mid_i * price_scale, digits, point),
            bb_upper=_fmt_price(bb_upper_i * price_scale, digits, point),
            bb_lower=_fmt_price(bb_lower_i * price_scale, digits, point),
            bb_width=_fmt_price(bb_width_i * price_scale, digits, point),
            bb_width_pct=_fmt_pct((bb_width_i / latest_close_i) * 100.0 if latest_close_i else math.nan),
            bb_position_pct=_fmt_pct(bb_position),
            bb_squeeze_score=_fmt_pct(squeeze_score),
            bb_expansion_score=_fmt_pct(expansion_score),
            vwap_value=_fmt_price(vwap_i * price_scale, digits, point),
            distance_to_vwap_points=_fmt_points(distance_i),
            price_position_vs_vwap=price_position,
            vwap_source=volume_source,
            vwap_confidence=vwap_confidence,
            vwap_volume_sum=str(int(round(volume_sum))),
            spread_to_range_pct=_fmt_pct(spread_to_range_pct),
            failure_reason="none" if status == "complete" else reason,
        )
    except Exception as exc:
        safe_error = str(exc).replace(chr(10), " ").replace(chr(13), " ")
        return TimeframeReference(timeframe, "decode_error", f"{type(exc).__name__}:{safe_error}", failure_reason=f"{type(exc).__name__}:{safe_error}")


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


def _replace_l21_in_deep_section(existing_text: str, l21_block: str) -> str:
    normalized = (existing_text or "").replace("\r\n", "\n").rstrip()
    deep = _extract_block(normalized, SELECTION_DEEP_START, SELECTION_DEEP_END)
    if not deep:
        deep = "\n".join([SELECTION_DEEP_START, SELECTION_DEEP_END]) + "\n"
        base = normalized
    else:
        base = normalized.replace(deep.strip(), "").rstrip()
    old_l21 = _extract_block(deep, L21_START, L21_END)
    if old_l21:
        deep = deep.replace(old_l21.strip(), l21_block.strip())
    else:
        deep = deep.replace(SELECTION_DEEP_END, l21_block.strip() + "\n\n" + SELECTION_DEEP_END)
    return base.rstrip() + "\n\n" + deep.strip() + "\n"


def _build_l21_block(symbol: str, refs: Sequence[TimeframeReference]) -> str:
    lines = [
        L21_START,
        "Layer:                  L21 Selected Indicator / Reference Pack",
        "Scope:                  Selection copied dossier only",
        "Source Owner:           Runtime 1 Shared OHLC Raw Storage Owner",
        "Source Policy:          read_existing_shared_ohlc_seed_files_only",
        "Calculation Authority:  Runtime 3 calculation support, L21 only",
        "CopyRates By L21:       false",
        "Private OHLC Cache:     false",
        "Base Dossier Touched:   false",
        "Indicator Meaning:      reference_context_only_not_signal",
        "VWAP Meaning:           benchmark_context_only_not_entry",
        "Bollinger Meaning:      volatility_context_only_not_buy_sell",
        "Trade Permission:       false",
        "Entry Signal:           false",
        "Execution:              false",
        f"Symbol:                 {symbol}",
        "",
        "VWAP Source Law",
        "real_volume means positive real_volume existed in the selected raw store rows.",
        "tick_volume_proxy means real volume was unavailable or insufficient and tick volume was used.",
        "unavailable means no positive volume was available; VWAP is not printed as truth.",
        "",
        "Reference Rows",
        "tf | status | rows_used | latest_time | close | atr14 | range_pctile | ma20 | ma_slope_pts | stddev20 | bb_mid | bb_upper | bb_lower | bb_width | bb_width_pct | bb_position_pct | bb_squeeze | bb_expansion | vwap | dist_vwap_pts | pos_vs_vwap | vwap_source | vwap_confidence | spread_to_range_pct | failure_reason",
    ]
    for ref in refs:
        lines.append(
            f"{ref.timeframe} | {ref.status} | {ref.source_rows_used} | {ref.latest_bar_time} | {ref.latest_close} | "
            f"{ref.atr_value} | {ref.range_percentile_pct} | {ref.ma_value} | {ref.ma_slope_points} | {ref.stddev_value} | "
            f"{ref.bb_middle} | {ref.bb_upper} | {ref.bb_lower} | {ref.bb_width} | {ref.bb_width_pct} | {ref.bb_position_pct} | "
            f"{ref.bb_squeeze_score} | {ref.bb_expansion_score} | {ref.vwap_value} | {ref.distance_to_vwap_points} | "
            f"{ref.price_position_vs_vwap} | {ref.vwap_source} | {ref.vwap_confidence} | {ref.spread_to_range_pct} | {ref.failure_reason}"
        )
    lines.extend([
        "",
        "Session VWAP Status:    not_wired",
        "Session VWAP Reason:    session definition/current-last-second-last session packet not yet source-wired to L21",
        "Current Session VWAP:   not_available",
        "Last Session VWAP:      not_available",
        "Second Last VWAP:       not_available",
        "Permission Caveat:      indicator reference context requires L22/L23 validation before any setup research wording; trade_permission=false",
        L21_END,
    ])
    return "\n".join(lines) + "\n"


def _status_text(summary: L21PublishSummary) -> str:
    return "\n".join([
        "schema_name=l21_selected_indicator_reference_pack_status",
        "schema_version=1",
        f"status={summary.status}",
        f"reason={summary.reason}",
        "scope=canonical_selection_shortcut_dossiers_only",
        "source_owner=Runtime 1 Shared OHLC Raw Storage Owner",
        "source_policy=read_existing_shared_ohlc_seed_files_only",
        "copyrates_by_l21=false",
        "private_ohlc_cache=false",
        "base_dossiers_touched=false",
        "indicator_meaning=reference_context_only_not_signal",
        "vwap_meaning=benchmark_context_only_not_entry",
        "bb_meaning=volatility_context_only_not_buy_sell",
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
        f"timeframe_packets_rendered={summary.timeframe_packets_rendered}",
        f"indicator_complete_packets={summary.indicator_complete_packets}",
        f"indicator_degraded_packets={summary.indicator_degraded_packets}",
        f"indicator_missing_packets={summary.indicator_missing_packets}",
        f"vwap_real_volume_packets={summary.vwap_real_volume_packets}",
        f"vwap_tick_volume_proxy_packets={summary.vwap_tick_volume_proxy_packets}",
        f"vwap_unavailable_packets={summary.vwap_unavailable_packets}",
        f"write_failed_count={summary.write_failed_count}",
        f"latest_bar_age_max_seconds={summary.latest_bar_age_max_seconds}",
        f"freshness_status={summary.freshness_status}",
        f"status_path={summary.status_path}",
        f"board_path={summary.board_path}",
        "trade_permission=false",
        "entry_signal=false",
        "execution=false",
        f"generated_utc={utc_stamp()}",
        f"generated_unix={unix_time()}",
        "",
    ])


def _board_text(summary: L21PublishSummary) -> str:
    return "\n".join([
        "L21 — SELECTED INDICATOR / REFERENCE PACK",
        "--------------------------------------------------",
        "Purpose:                Selected-symbol indicator/reference context",
        "Scope:                  Canonical Selection Desk copied dossiers only",
        "Source Owner:           Runtime 1 Shared OHLC Raw Storage Owner",
        "Source Policy:          read_existing_shared_ohlc_seed_files_only",
        "CopyRates By L21:       FALSE",
        "Private OHLC Cache:     FALSE",
        "Base Dossiers Touched:  FALSE",
        "Indicator Meaning:      REFERENCE CONTEXT ONLY",
        "VWAP Meaning:           BENCHMARK CONTEXT ONLY, NOT ENTRY",
        "Bollinger Meaning:      VOLATILITY CONTEXT ONLY, NOT BUY/SELL",
        "Trade Permission:       FALSE",
        "Entry Signal:           FALSE",
        "Execution:              FALSE",
        "",
        "Selection Coverage",
        f"Selected Dossiers Seen:       {summary.selected_dossiers_seen}",
        f"Selected Dossiers Decorated:  {summary.selected_dossiers_decorated}",
        f"Unique Symbols Seen:          {summary.selected_unique_symbols_seen}",
        f"Duplicate Route Copies:       {summary.selected_duplicate_route_copies}",
        "",
        "Reference Coverage",
        f"Status:                       {summary.status}",
        f"Reason:                       {summary.reason}",
        f"Source Files Found:           {summary.source_files_found} / {summary.source_files_expected}",
        f"Source Files Missing:         {summary.source_files_missing}",
        f"Source Files Partial:         {summary.source_files_partial}",
        f"Source Decode Errors:         {summary.source_decode_errors}",
        f"Indicator Complete Packets:   {summary.indicator_complete_packets}",
        f"Indicator Degraded Packets:   {summary.indicator_degraded_packets}",
        f"Indicator Missing Packets:    {summary.indicator_missing_packets}",
        f"VWAP Real Volume Packets:     {summary.vwap_real_volume_packets}",
        f"VWAP Tick Proxy Packets:      {summary.vwap_tick_volume_proxy_packets}",
        f"VWAP Unavailable Packets:     {summary.vwap_unavailable_packets}",
        f"Write Failed Count:           {summary.write_failed_count}",
        f"Latest Bar Age Max Seconds:   {summary.latest_bar_age_max_seconds}",
        f"Generated UTC:                {utc_stamp()}",
        "",
    ])


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


def publish_l21_indicator_reference_pack(root: Path) -> L21PublishSummary:
    failed: List[Path] = []
    layer_dir = _layer_folder(root)
    layer_dir.mkdir(parents=True, exist_ok=True)
    status_path = layer_dir / "l21_status.txt"
    board_path = _selection_desk(root) / "91_Layer_Summaries" / "L21_Selected_Indicator_Reference_Pack" / "00_L21_Board_Overview.txt"

    dossiers = _selected_dossier_paths(root)
    decorated = 0
    missing_symbol = 0
    unique_symbols = set()
    source_expected = len(dossiers) * len(REFERENCE_TIMEFRAMES)
    source_found = 0
    source_missing = 0
    source_partial = 0
    decode_errors = 0
    packets = 0
    complete_packets = 0
    degraded_packets = 0
    missing_packets = 0
    vwap_real = 0
    vwap_tick = 0
    vwap_unavailable = 0
    latest_max_age = -1

    for dossier in dossiers:
        symbol = _symbol_from_dossier(dossier)
        if not symbol:
            missing_symbol += 1
            continue
        unique_symbols.add(symbol)
        refs: List[TimeframeReference] = []
        for timeframe, requested in REFERENCE_TIMEFRAMES.items():
            ref = _build_reference(root, symbol, timeframe, requested)
            refs.append(ref)
            packets += 1
            if ref.status == "missing":
                source_missing += 1
                missing_packets += 1
            elif ref.status == "decode_error":
                source_found += 1
                decode_errors += 1
                degraded_packets += 1
            else:
                source_found += 1
                if ref.status == "complete":
                    complete_packets += 1
                else:
                    source_partial += 1
                    degraded_packets += 1
            if ref.vwap_source == "real_volume":
                vwap_real += 1
            elif ref.vwap_source == "tick_volume_proxy":
                vwap_tick += 1
            else:
                vwap_unavailable += 1
            age = _latest_age_seconds(root, symbol, timeframe)
            if age > latest_max_age:
                latest_max_age = age
        try:
            existing = read_text(dossier)
            updated = _replace_l21_in_deep_section(existing, _build_l21_block(symbol, refs))
            if _write(dossier, updated, failed):
                decorated += 1
        except Exception:
            failed.append(dossier)

    if not dossiers:
        status = "pending"
        reason = "no_canonical_selected_dossiers_found"
    elif failed or source_missing > 0 or decode_errors > 0 or decorated == 0:
        status = "partial"
        reason = "one_or_more_indicator_sources_missing_invalid_or_write_failed"
    elif source_partial > 0:
        status = "degraded"
        reason = "indicator_reference_written_with_insufficient_bars_for_some_packets"
    else:
        status = "accepted"
        reason = "indicator_reference_pack_written_from_shared_ohlc"

    if latest_max_age < 0:
        freshness_status = "unknown"
    elif latest_max_age <= 7200:
        freshness_status = "fresh_or_recent"
    elif latest_max_age <= 43200:
        freshness_status = "aging"
    else:
        freshness_status = "stale"

    summary = L21PublishSummary(
        status=status,
        reason=reason,
        selected_dossiers_seen=len(dossiers),
        selected_dossiers_decorated=decorated,
        selected_dossiers_missing_symbol=missing_symbol,
        selected_route_dossiers_seen=len(dossiers),
        selected_route_dossiers_decorated=decorated,
        selected_unique_symbols_seen=len(unique_symbols),
        selected_duplicate_route_copies=max(0, len(dossiers) - len(unique_symbols)),
        source_files_expected=source_expected,
        source_files_found=source_found,
        source_files_missing=source_missing,
        source_files_partial=source_partial,
        source_decode_errors=decode_errors,
        timeframe_packets_rendered=packets,
        indicator_complete_packets=complete_packets,
        indicator_degraded_packets=degraded_packets,
        indicator_missing_packets=missing_packets,
        vwap_real_volume_packets=vwap_real,
        vwap_tick_volume_proxy_packets=vwap_tick,
        vwap_unavailable_packets=vwap_unavailable,
        write_failed_count=len(failed),
        latest_bar_age_max_seconds=latest_max_age,
        freshness_status=freshness_status,
        status_path=str(status_path),
        board_path=str(board_path),
        layer_folder=str(layer_dir),
    )
    _write(status_path, _status_text(summary), failed)
    _write(board_path, _board_text(summary), failed)
    return summary
