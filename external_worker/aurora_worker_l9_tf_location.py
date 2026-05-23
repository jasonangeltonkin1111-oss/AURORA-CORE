from __future__ import annotations

from dataclasses import dataclass
from typing import List

from aurora_worker_l9_windows import L9OhlcBar, avg_true_range


@dataclass(frozen=True)
class L9TfLocation:
    timeframe: str
    weight: float
    bars_copied: int
    range_high_i: int
    range_low_i: int
    price_i: int
    position_pct: float
    distance_to_high_points: float
    distance_to_low_points: float
    atr_points: float
    distance_to_high_atr: float
    distance_to_low_atr: float
    nearest_boundary: str
    nearest_boundary_distance_atr: float
    zone_state: str
    event_zone: str
    component_score: float
    reason: str


def _clamp(value: float, low: float = 0.0, high: float = 100.0) -> float:
    return max(low, min(high, value))


def _join_reason(parts: List[str]) -> str:
    clean: List[str] = []
    seen = set()
    for raw in parts:
        part = str(raw or "").replace("\r", " ").replace("\n", " ").strip()
        if not part or part in seen:
            continue
        clean.append(part)
        seen.add(part)
    return ";".join(clean) if clean else "not_available"


def _zone_from_position(position_pct: float, distance_to_high_atr: float, distance_to_low_atr: float) -> tuple[str, str, float, str]:
    """Classify location as watchlist geometry, not direction.

    Near highs/lows are intentionally high-attention zones. This function must
    not treat high/low proximity as a dumb penalty. Middle of range is the lower
    attention state unless later modules prove compression/build-up.
    """
    reasons: List[str] = []
    nearest = min(distance_to_high_atr, distance_to_low_atr)

    if position_pct >= 92.0 or distance_to_high_atr <= 0.35:
        reasons.append("price_at_or_near_high_event_zone")
        score = 100.0 if nearest <= 0.20 else 92.0
        return "near_high_event_zone", "near_high_event_zone", score, _join_reason(reasons)
    if position_pct <= 8.0 or distance_to_low_atr <= 0.35:
        reasons.append("price_at_or_near_low_event_zone")
        score = 100.0 if nearest <= 0.20 else 92.0
        return "near_low_event_zone", "near_low_event_zone", score, _join_reason(reasons)
    if position_pct >= 80.0 or distance_to_high_atr <= 0.75:
        reasons.append("price_in_upper_range_watch_zone")
        return "upper_range_watch", "upper_range_watch", 82.0, _join_reason(reasons)
    if position_pct <= 20.0 or distance_to_low_atr <= 0.75:
        reasons.append("price_in_lower_range_watch_zone")
        return "lower_range_watch", "lower_range_watch", 82.0, _join_reason(reasons)
    if 40.0 <= position_pct <= 60.0:
        reasons.append("price_in_midrange_low_attention_zone")
        return "midrange_low_attention", "midrange_low_attention", 32.0, _join_reason(reasons)

    reasons.append("price_between_midrange_and_boundary")
    return "neutral_location", "neutral_location", 55.0, _join_reason(reasons)


def calculate_tf_location(timeframe: str, bars: List[L9OhlcBar], price_i: int, weight: float, lookback_bars: int, atr_bars: int | None = None) -> L9TfLocation:
    tf = str(timeframe).upper()
    copied = len(bars)
    atr_count = atr_bars if atr_bars is not None else lookback_bars

    if copied <= 0 or price_i <= 0:
        return L9TfLocation(
            timeframe=tf,
            weight=weight,
            bars_copied=copied,
            range_high_i=0,
            range_low_i=0,
            price_i=max(0, price_i),
            position_pct=50.0,
            distance_to_high_points=0.0,
            distance_to_low_points=0.0,
            atr_points=0.0,
            distance_to_high_atr=0.0,
            distance_to_low_atr=0.0,
            nearest_boundary="not_available",
            nearest_boundary_distance_atr=0.0,
            zone_state="structure_data_partial",
            event_zone="structure_data_partial",
            component_score=0.0,
            reason="missing_bars_or_price_basis",
        )

    subset = bars[: max(1, min(copied, lookback_bars))]
    high_i = max(bar.high_i for bar in subset)
    low_i = min(bar.low_i for bar in subset)
    range_points = max(0, high_i - low_i)
    atr = avg_true_range(bars, max(1, min(copied, atr_count)))

    if range_points <= 0:
        return L9TfLocation(
            timeframe=tf,
            weight=weight,
            bars_copied=copied,
            range_high_i=high_i,
            range_low_i=low_i,
            price_i=price_i,
            position_pct=50.0,
            distance_to_high_points=0.0,
            distance_to_low_points=0.0,
            atr_points=atr,
            distance_to_high_atr=0.0,
            distance_to_low_atr=0.0,
            nearest_boundary="flat_range",
            nearest_boundary_distance_atr=0.0,
            zone_state="structure_data_partial",
            event_zone="structure_data_partial",
            component_score=0.0,
            reason="flat_or_invalid_range",
        )

    position = _clamp(((price_i - low_i) / float(range_points)) * 100.0)
    distance_high = float(max(0, high_i - price_i))
    distance_low = float(max(0, price_i - low_i))
    atr_safe = atr if atr > 0.0 else float(range_points)
    high_atr = distance_high / atr_safe if atr_safe > 0.0 else 0.0
    low_atr = distance_low / atr_safe if atr_safe > 0.0 else 0.0
    if high_atr <= low_atr:
        nearest_boundary = "range_high"
        nearest_distance = high_atr
    else:
        nearest_boundary = "range_low"
        nearest_distance = low_atr

    zone_state, event_zone, base_score, zone_reason = _zone_from_position(position, high_atr, low_atr)
    availability_ratio = min(1.0, copied / float(max(1, lookback_bars)))
    component_score = _clamp(base_score * availability_ratio)
    reason = _join_reason([
        zone_reason,
        f"tf={tf}",
        f"lookback_bars={lookback_bars}",
        f"bars_copied={copied}",
        f"availability_ratio={availability_ratio:.3f}",
        "watchlist_location_not_directional_signal",
    ])

    return L9TfLocation(
        timeframe=tf,
        weight=weight,
        bars_copied=copied,
        range_high_i=high_i,
        range_low_i=low_i,
        price_i=price_i,
        position_pct=position,
        distance_to_high_points=distance_high,
        distance_to_low_points=distance_low,
        atr_points=atr,
        distance_to_high_atr=high_atr,
        distance_to_low_atr=low_atr,
        nearest_boundary=nearest_boundary,
        nearest_boundary_distance_atr=nearest_distance,
        zone_state=zone_state,
        event_zone=event_zone,
        component_score=component_score,
        reason=reason,
    )


def weighted_location_score(locations: List[L9TfLocation]) -> float:
    total_weight = sum(max(0.0, loc.weight) for loc in locations)
    if total_weight <= 0.0:
        return 0.0
    score = sum(max(0.0, loc.weight) * loc.component_score for loc in locations) / total_weight
    return _clamp(score)


def dominant_event_zone(locations: List[L9TfLocation]) -> str:
    if not locations:
        return "structure_data_partial"
    weighted: dict[str, float] = {}
    for loc in locations:
        weighted[loc.event_zone] = weighted.get(loc.event_zone, 0.0) + max(0.0, loc.weight)
    return max(weighted.items(), key=lambda item: item[1])[0] if weighted else "structure_data_partial"
