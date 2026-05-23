from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable, List

from aurora_worker_l9_tf_location import L9TfLocation


@dataclass(frozen=True)
class L9RoomProfile:
    room_up_atr: float
    room_down_atr: float
    nearest_boundary: str
    nearest_boundary_distance_atr: float
    farthest_boundary: str
    farthest_boundary_distance_atr: float
    room_asymmetry_ratio: float
    room_profile: str
    clean_room_state: str
    midrange_trap: bool
    room_quality_score: float
    reason: str


def _clamp(value: float, low: float = 0.0, high: float = 100.0) -> float:
    return max(low, min(high, value))


def _join_reason(parts: Iterable[str]) -> str:
    clean: List[str] = []
    seen = set()
    for raw in parts:
        part = str(raw or "").replace("\r", " ").replace("\n", " ").strip()
        if not part or part in seen:
            continue
        seen.add(part)
        clean.append(part)
    return ";".join(clean) if clean else "not_available"


def _weighted_average(values: List[tuple[float, float]]) -> float:
    total_weight = sum(max(0.0, weight) for _value, weight in values)
    if total_weight <= 0.0:
        return 0.0
    return sum(value * max(0.0, weight) for value, weight in values) / total_weight


def _classify_room(room_up_atr: float, room_down_atr: float, midrange_trap: bool) -> tuple[str, str, float, str]:
    reasons: List[str] = []
    nearest = min(room_up_atr, room_down_atr)
    farthest = max(room_up_atr, room_down_atr)
    asymmetry = farthest / max(0.01, nearest)

    if midrange_trap:
        reasons.append("midrange_trap_limits_watchlist_quality")
        return "balanced_midrange_trap", "midrange_trap", 35.0, _join_reason(reasons)

    if nearest <= 0.20:
        # This is not bad: it means price is sitting on the event boundary. The
        # profile is high-attention but risk-review because room on one side is
        # compressed until a break/rejection/sweep resolves.
        if room_up_atr <= room_down_atr:
            reasons.append("price_on_or_near_upper_boundary")
            profile = "boundary_event_downside_room_dominant" if asymmetry >= 2.0 else "upper_boundary_event_balanced_room"
        else:
            reasons.append("price_on_or_near_lower_boundary")
            profile = "boundary_event_upside_room_dominant" if asymmetry >= 2.0 else "lower_boundary_event_balanced_room"
        return profile, "boundary_event_room_compressed", 82.0, _join_reason(reasons)

    if nearest <= 0.75:
        if room_up_atr <= room_down_atr:
            reasons.append("near_upper_boundary_with_downside_room")
            profile = "near_upper_boundary_downside_room_dominant" if asymmetry >= 2.0 else "near_upper_boundary_balanced_room"
        else:
            reasons.append("near_lower_boundary_with_upside_room")
            profile = "near_lower_boundary_upside_room_dominant" if asymmetry >= 2.0 else "near_lower_boundary_balanced_room"
        return profile, "near_boundary_watch", 78.0, _join_reason(reasons)

    if asymmetry >= 3.0:
        reasons.append("strong_room_asymmetry")
        profile = "upside_room_dominant" if room_up_atr > room_down_atr else "downside_room_dominant"
        return profile, "asymmetric_clean_room", 72.0, _join_reason(reasons)

    if room_up_atr >= 1.25 and room_down_atr >= 1.25:
        reasons.append("clean_room_both_sides")
        return "balanced_clean_room", "clean_room_available", 68.0, _join_reason(reasons)

    reasons.append("limited_room_without_boundary_event")
    return "limited_room", "limited_room", 48.0, _join_reason(reasons)


def calculate_room_profile(locations: List[L9TfLocation], midrange_trap_min_weight_ratio: float = 0.55) -> L9RoomProfile:
    """Summarize room to high/low boundaries across TF locations.

    This module intentionally does not decide direction. It exposes whether price
    has room up, room down, asymmetric room, or boundary compression. A near high
    or low remains a watchlist event, not an automatic rejection or breakout call.
    """
    valid = [loc for loc in locations if loc.bars_copied > 0 and loc.atr_points > 0.0]
    if not valid:
        return L9RoomProfile(
            room_up_atr=0.0,
            room_down_atr=0.0,
            nearest_boundary="not_available",
            nearest_boundary_distance_atr=0.0,
            farthest_boundary="not_available",
            farthest_boundary_distance_atr=0.0,
            room_asymmetry_ratio=0.0,
            room_profile="room_data_missing",
            clean_room_state="room_data_missing",
            midrange_trap=False,
            room_quality_score=0.0,
            reason="no_valid_tf_locations_for_room_profile",
        )

    up_room = _weighted_average([(loc.distance_to_high_atr, loc.weight) for loc in valid])
    down_room = _weighted_average([(loc.distance_to_low_atr, loc.weight) for loc in valid])
    nearest_boundary = "range_high" if up_room <= down_room else "range_low"
    nearest_distance = min(up_room, down_room)
    farthest_boundary = "range_low" if nearest_boundary == "range_high" else "range_high"
    farthest_distance = max(up_room, down_room)
    asymmetry = farthest_distance / max(0.01, nearest_distance)

    total_weight = sum(max(0.0, loc.weight) for loc in valid)
    mid_weight = sum(max(0.0, loc.weight) for loc in valid if loc.event_zone == "midrange_low_attention")
    midrange_trap = total_weight > 0.0 and (mid_weight / total_weight) >= midrange_trap_min_weight_ratio

    room_profile, clean_room_state, score, classify_reason = _classify_room(up_room, down_room, midrange_trap)
    reason = _join_reason([
        classify_reason,
        f"weighted_room_up_atr={up_room:.3f}",
        f"weighted_room_down_atr={down_room:.3f}",
        f"room_asymmetry_ratio={asymmetry:.3f}",
        f"midrange_weight_ratio={(mid_weight / total_weight) if total_weight > 0 else 0.0:.3f}",
        "room_profile_is_watchlist_context_not_directional_signal",
    ])

    return L9RoomProfile(
        room_up_atr=up_room,
        room_down_atr=down_room,
        nearest_boundary=nearest_boundary,
        nearest_boundary_distance_atr=nearest_distance,
        farthest_boundary=farthest_boundary,
        farthest_boundary_distance_atr=farthest_distance,
        room_asymmetry_ratio=asymmetry,
        room_profile=room_profile,
        clean_room_state=clean_room_state,
        midrange_trap=midrange_trap,
        room_quality_score=_clamp(score),
        reason=reason,
    )
