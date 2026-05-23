from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable, List

from aurora_worker_l9_boundary import L9BoundaryQuality
from aurora_worker_l9_room import L9RoomProfile
from aurora_worker_l9_tf_location import L9TfLocation


@dataclass(frozen=True)
class L9EventZone:
    dominant_event_zone: str
    watchlist_state: str
    watchlist: bool
    confluence_score: float
    risk_review: bool
    risk_review_reason: str
    high_event_zone_count: int
    low_event_zone_count: int
    boundary_event_count: int
    midrange_low_attention_count: int
    compression_at_boundary: bool
    event_zone_quality_score: float
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


def _weighted_event_zone(locations: List[L9TfLocation]) -> str:
    if not locations:
        return "structure_data_partial"
    scores: dict[str, float] = {}
    for loc in locations:
        scores[loc.event_zone] = scores.get(loc.event_zone, 0.0) + max(0.0, loc.weight)
    return max(scores.items(), key=lambda item: item[1])[0] if scores else "structure_data_partial"


def _weighted_location_confluence(locations: List[L9TfLocation]) -> float:
    if not locations:
        return 0.0
    total_weight = sum(max(0.0, loc.weight) for loc in locations)
    if total_weight <= 0.0:
        return 0.0
    dominant = _weighted_event_zone(locations)
    dominant_weight = sum(max(0.0, loc.weight) for loc in locations if loc.event_zone == dominant)
    event_weight = sum(max(0.0, loc.weight) for loc in locations if loc.event_zone in {
        "near_high_event_zone", "near_low_event_zone", "upper_range_watch", "lower_range_watch"
    })
    # Reward agreement around structure. Do not punish high/low proximity; it is
    # the event we want L9 to surface for watchlist attention.
    agreement_score = (dominant_weight / total_weight) * 70.0
    event_score = (event_weight / total_weight) * 30.0
    return _clamp(agreement_score + event_score)


def _weighted_boundary_score(boundaries: List[L9BoundaryQuality]) -> float:
    if not boundaries:
        return 0.0
    usable = [b for b in boundaries if b.bars_copied > 0]
    if not usable:
        return 0.0
    return _clamp(sum(b.boundary_quality_score for b in usable) / float(len(usable)))


def classify_l9_event_zone(locations: List[L9TfLocation], boundaries: List[L9BoundaryQuality], room: L9RoomProfile) -> L9EventZone:
    """Classify L9 structure event-zone confluence.

    This is still not the master ranker. It creates watchlist state and risk
    review context from independent modules. It must not output direction,
    entry, selection, or trade permission.
    """
    dominant = _weighted_event_zone(locations)
    location_confluence = _weighted_location_confluence(locations)
    boundary_score = _weighted_boundary_score(boundaries)
    room_score = room.room_quality_score

    high_count = sum(1 for loc in locations if loc.event_zone in {"near_high_event_zone", "upper_range_watch"})
    low_count = sum(1 for loc in locations if loc.event_zone in {"near_low_event_zone", "lower_range_watch"})
    boundary_event_count = high_count + low_count
    mid_count = sum(1 for loc in locations if loc.event_zone == "midrange_low_attention")
    compression = room.clean_room_state in {"boundary_event_room_compressed", "near_boundary_watch"}

    event_quality = _clamp(location_confluence * 0.50 + boundary_score * 0.25 + room_score * 0.25)

    risk_parts: List[str] = []
    if room.midrange_trap:
        risk_parts.append("midrange_trap")
    if compression:
        risk_parts.append("boundary_compression_requires_resolution")
    if boundary_score < 40.0 and boundary_event_count > 0:
        risk_parts.append("event_zone_boundary_quality_weak")
    if dominant == "structure_data_partial":
        risk_parts.append("structure_data_partial")

    risk_review = bool(risk_parts)

    if dominant in {"near_high_event_zone", "near_low_event_zone"} and event_quality >= 75.0:
        watch_state = "elite_boundary_event_watch"
        watchlist = True
    elif dominant in {"upper_range_watch", "lower_range_watch"} and event_quality >= 65.0:
        watch_state = "strong_range_edge_watch"
        watchlist = True
    elif compression and event_quality >= 55.0:
        watch_state = "compression_boundary_watch"
        watchlist = True
    elif room.midrange_trap:
        watch_state = "midrange_low_attention"
        watchlist = False
    elif event_quality >= 50.0 and boundary_event_count > 0:
        watch_state = "acceptable_structure_watch"
        watchlist = True
    else:
        watch_state = "low_attention_structure"
        watchlist = False

    reason = _join_reason([
        f"dominant_event_zone={dominant}",
        f"location_confluence_score={location_confluence:.2f}",
        f"boundary_quality_score={boundary_score:.2f}",
        f"room_quality_score={room_score:.2f}",
        f"event_zone_quality_score={event_quality:.2f}",
        f"high_event_zone_count={high_count}",
        f"low_event_zone_count={low_count}",
        f"midrange_low_attention_count={mid_count}",
        room.reason,
        "event_zone_is_watchlist_context_not_directional_signal",
    ])

    return L9EventZone(
        dominant_event_zone=dominant,
        watchlist_state=watch_state,
        watchlist=watchlist,
        confluence_score=location_confluence,
        risk_review=risk_review,
        risk_review_reason=_join_reason(risk_parts) if risk_parts else "none",
        high_event_zone_count=high_count,
        low_event_zone_count=low_count,
        boundary_event_count=boundary_event_count,
        midrange_low_attention_count=mid_count,
        compression_at_boundary=compression,
        event_zone_quality_score=event_quality,
        reason=reason,
    )
