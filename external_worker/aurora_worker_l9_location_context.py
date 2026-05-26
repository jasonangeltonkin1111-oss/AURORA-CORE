from __future__ import annotations

from datetime import datetime
from typing import Dict, Iterable, List, Optional, Tuple

from aurora_worker_l9_windows import L9OhlcBar, L9WindowPacket

# L9 context-only reference windows. These are not setup logic, not sweep
# confirmation, not direction, and not trade permission. Session hours are read
# from bar_time hour as provided by the Runtime 1 priority-window packets.
ASIAN_SESSION_HOURS = range(0, 8)
LONDON_SESSION_HOURS = range(8, 16)
NEW_YORK_SESSION_HOURS = range(13, 22)
LOCATION_CONTEXT_TIME_BASIS = "broker_server_bar_time_hour_heuristic_from_priority_windows"


def _not_available_context(reason: str = "missing_price_or_point_or_surface_windows") -> Dict[str, object]:
    return {
        "location_context_time_basis": LOCATION_CONTEXT_TIME_BASIS,
        "distance_to_previous_day_high": "not_available",
        "distance_to_previous_day_low": "not_available",
        "distance_to_asian_high": "not_available",
        "distance_to_asian_low": "not_available",
        "distance_to_london_high": "not_available",
        "distance_to_london_low": "not_available",
        "position_in_session_range_pct": "not_available",
        "position_in_daily_range_pct": "not_available",
        "nearest_surface_reference": "not_available",
        "nearest_surface_obstacle_distance_pips": "not_available",
        "available_surface_room_pips": "not_available",
        "surface_geometry_confidence": 0.0,
        "surface_geometry_confidence_reason": reason,
    }


def _pip_points(point: float) -> float:
    # FX 5/3-digit symbols normally need 10 points per pip. Metals, indices,
    # crypto, and CFDs vary by broker, so use the point as the minimum honest
    # distance unit when point is already coarser. This remains context-only.
    if point <= 0.0:
        return 0.0
    return 10.0 if point < 0.01 else 1.0


def _distance_pips(price_i: int, level_i: int, point: float) -> object:
    points_per_pip = _pip_points(point)
    if price_i <= 0 or level_i <= 0 or points_per_pip <= 0.0:
        return "not_available"
    return abs(float(level_i - price_i)) / points_per_pip


def _position_pct(price_i: int, low_i: int, high_i: int) -> object:
    if price_i <= 0 or low_i <= 0 or high_i <= low_i:
        return "not_available"
    return max(0.0, min(100.0, ((float(price_i - low_i) / float(high_i - low_i)) * 100.0)))


def _latest_trade_day(bars: Iterable[L9OhlcBar]) -> Optional[str]:
    for bar in bars:
        if bar.bar_time > 0:
            return datetime.utcfromtimestamp(bar.bar_time).strftime("%Y%m%d")
    return None


def _bars_for_day_and_hours(bars: Iterable[L9OhlcBar], day_key: str, hours: range) -> List[L9OhlcBar]:
    selected: List[L9OhlcBar] = []
    allowed = set(hours)
    for bar in bars:
        if bar.bar_time <= 0:
            continue
        stamp = datetime.utcfromtimestamp(bar.bar_time)
        if stamp.strftime("%Y%m%d") == day_key and stamp.hour in allowed:
            selected.append(bar)
    return selected


def _range_high_low(bars: Iterable[L9OhlcBar]) -> Tuple[int, int]:
    usable = [bar for bar in bars if bar.high_i > 0 and bar.low_i > 0 and bar.high_i >= bar.low_i]
    if not usable:
        return 0, 0
    return max(bar.high_i for bar in usable), min(bar.low_i for bar in usable)


def _current_session_bars(m15_bars: List[L9OhlcBar], day_key: str) -> List[L9OhlcBar]:
    if not m15_bars or m15_bars[0].bar_time <= 0:
        return []
    latest_hour = datetime.utcfromtimestamp(m15_bars[0].bar_time).hour
    if latest_hour in set(ASIAN_SESSION_HOURS):
        return _bars_for_day_and_hours(m15_bars, day_key, ASIAN_SESSION_HOURS)
    if latest_hour in set(LONDON_SESSION_HOURS):
        return _bars_for_day_and_hours(m15_bars, day_key, LONDON_SESSION_HOURS)
    if latest_hour in set(NEW_YORK_SESSION_HOURS):
        return _bars_for_day_and_hours(m15_bars, day_key, NEW_YORK_SESSION_HOURS)
    return []


def _nearest_reference(price_i: int, point: float, references: Dict[str, int]) -> Tuple[str, object]:
    best_name = "not_available"
    best_distance: object = "not_available"
    best_raw: Optional[float] = None
    for name, level_i in references.items():
        distance = _distance_pips(price_i, level_i, point)
        if isinstance(distance, str):
            continue
        raw = float(distance)
        if best_raw is None or raw < best_raw:
            best_name = name
            best_distance = raw
            best_raw = raw
    return best_name, best_distance


def _available_room_pips(price_i: int, point: float, references: Dict[str, int]) -> object:
    distances: List[float] = []
    for level_i in references.values():
        distance = _distance_pips(price_i, level_i, point)
        if not isinstance(distance, str):
            distances.append(float(distance))
    return max(distances) if distances else "not_available"


def _surface_confidence(packet: L9WindowPacket, reference_count: int) -> Tuple[float, str]:
    total_required = max(1, packet.required_seen + packet.required_missing)
    required_ratio = max(0.0, min(1.0, packet.required_seen / float(total_required)))
    reference_ratio = max(0.0, min(1.0, reference_count / 6.0))
    confidence = max(0.0, min(1.0, required_ratio * 0.70 + reference_ratio * 0.30))
    reason = (
        f"required_windows_seen={packet.required_seen};"
        f"required_windows_missing={packet.required_missing};"
        f"surface_reference_count={reference_count};"
        "confidence_is_geometry_data_quality_not_trade_probability"
    )
    return confidence, reason


def calculate_l9_location_context(packet: L9WindowPacket, price_i: int, point: float) -> Dict[str, object]:
    """Return plain L9 location context fields.

    This deliberately reports distance/range context only. It must not infer
    sweep confirmation, CHOCH, BOS, FVG, order blocks, setup candidates,
    direction, selection, trade permission, execution permission, or a liquidity map.
    """
    context = _not_available_context()
    if price_i <= 0 or point <= 0.0:
        return context

    d1_bars = packet.windows.get("D1", [])
    m15_bars = packet.windows.get("M15", [])
    references: Dict[str, int] = {}

    if len(d1_bars) >= 2:
        previous_day = d1_bars[1]
        if previous_day.high_i > 0:
            context["distance_to_previous_day_high"] = _distance_pips(price_i, previous_day.high_i, point)
            references["previous_day_high"] = previous_day.high_i
        if previous_day.low_i > 0:
            context["distance_to_previous_day_low"] = _distance_pips(price_i, previous_day.low_i, point)
            references["previous_day_low"] = previous_day.low_i
        context["position_in_daily_range_pct"] = _position_pct(price_i, previous_day.low_i, previous_day.high_i)

    day_key = _latest_trade_day(m15_bars)
    if day_key:
        asian_high, asian_low = _range_high_low(_bars_for_day_and_hours(m15_bars, day_key, ASIAN_SESSION_HOURS))
        london_high, london_low = _range_high_low(_bars_for_day_and_hours(m15_bars, day_key, LONDON_SESSION_HOURS))
        session_high, session_low = _range_high_low(_current_session_bars(m15_bars, day_key))

        if asian_high > 0:
            context["distance_to_asian_high"] = _distance_pips(price_i, asian_high, point)
            references["asian_high"] = asian_high
        if asian_low > 0:
            context["distance_to_asian_low"] = _distance_pips(price_i, asian_low, point)
            references["asian_low"] = asian_low
        if london_high > 0:
            context["distance_to_london_high"] = _distance_pips(price_i, london_high, point)
            references["london_high"] = london_high
        if london_low > 0:
            context["distance_to_london_low"] = _distance_pips(price_i, london_low, point)
            references["london_low"] = london_low
        if session_high > 0 and session_low > 0:
            context["position_in_session_range_pct"] = _position_pct(price_i, session_low, session_high)

    nearest_name, nearest_distance = _nearest_reference(price_i, point, references)
    available_room = _available_room_pips(price_i, point, references)
    confidence, confidence_reason = _surface_confidence(packet, len(references))

    context["nearest_surface_reference"] = nearest_name
    context["nearest_surface_obstacle_distance_pips"] = nearest_distance
    context["available_surface_room_pips"] = available_room
    context["surface_geometry_confidence"] = confidence
    context["surface_geometry_confidence_reason"] = confidence_reason
    return context
