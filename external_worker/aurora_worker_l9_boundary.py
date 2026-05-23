from __future__ import annotations

from dataclasses import dataclass
from typing import List

from aurora_worker_l9_windows import L9OhlcBar, avg_true_range


@dataclass(frozen=True)
class L9BoundaryQuality:
    timeframe: str
    bars_copied: int
    range_high_i: int
    range_low_i: int
    atr_points: float
    high_touch_count: int
    low_touch_count: int
    high_age_bars: int
    low_age_bars: int
    nearest_boundary: str
    nearest_touch_count: int
    nearest_age_bars: int
    boundary_cleanliness_score: float
    boundary_quality_score: float
    boundary_state: str
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


def _touch_count_high(bars: List[L9OhlcBar], range_high_i: int, tolerance_points: float) -> int:
    if not bars or range_high_i <= 0:
        return 0
    return sum(1 for bar in bars if abs(float(bar.high_i - range_high_i)) <= tolerance_points)


def _touch_count_low(bars: List[L9OhlcBar], range_low_i: int, tolerance_points: float) -> int:
    if not bars or range_low_i <= 0:
        return 0
    return sum(1 for bar in bars if abs(float(bar.low_i - range_low_i)) <= tolerance_points)


def _age_to_high(bars: List[L9OhlcBar], range_high_i: int, tolerance_points: float) -> int:
    if not bars or range_high_i <= 0:
        return -1
    for index, bar in enumerate(bars):
        if abs(float(bar.high_i - range_high_i)) <= tolerance_points:
            return index
    return -1


def _age_to_low(bars: List[L9OhlcBar], range_low_i: int, tolerance_points: float) -> int:
    if not bars or range_low_i <= 0:
        return -1
    for index, bar in enumerate(bars):
        if abs(float(bar.low_i - range_low_i)) <= tolerance_points:
            return index
    return -1


def _cleanliness_score(high_touch_count: int, low_touch_count: int, high_age_bars: int, low_age_bars: int, lookback_bars: int) -> tuple[float, str]:
    # A boundary is useful when it has some evidence, is not ancient, and is not
    # so over-tested that it likely became noisy. This is watchlist quality, not
    # a prediction that the boundary must hold or break.
    strongest_touches = max(high_touch_count, low_touch_count)
    freshest_age = min(age for age in (high_age_bars, low_age_bars) if age >= 0) if high_age_bars >= 0 or low_age_bars >= 0 else lookback_bars + 1

    score = 45.0
    reasons: List[str] = []

    if strongest_touches <= 0:
        score -= 25.0
        reasons.append("no_boundary_touch_evidence")
    elif strongest_touches == 1:
        score += 8.0
        reasons.append("single_boundary_touch")
    elif 2 <= strongest_touches <= 4:
        score += 28.0
        reasons.append("repeated_boundary_touches")
    elif 5 <= strongest_touches <= 7:
        score += 15.0
        reasons.append("many_boundary_touches_review")
    else:
        score -= 10.0
        reasons.append("over_touched_boundary_noise_risk")

    if freshest_age <= 2:
        score += 18.0
        reasons.append("boundary_very_recent")
    elif freshest_age <= max(4, lookback_bars // 4):
        score += 12.0
        reasons.append("boundary_recent")
    elif freshest_age <= max(8, lookback_bars // 2):
        score += 4.0
        reasons.append("boundary_mid_age")
    else:
        score -= 12.0
        reasons.append("boundary_stale")

    return _clamp(score), _join_reason(reasons)


def calculate_boundary_quality(timeframe: str, bars: List[L9OhlcBar], nearest_boundary: str, lookback_bars: int, touch_tolerance_atr: float = 0.20) -> L9BoundaryQuality:
    tf = str(timeframe).upper()
    copied = len(bars)
    subset = bars[: max(1, min(copied, lookback_bars))]

    if copied <= 0 or not subset:
        return L9BoundaryQuality(
            timeframe=tf,
            bars_copied=copied,
            range_high_i=0,
            range_low_i=0,
            atr_points=0.0,
            high_touch_count=0,
            low_touch_count=0,
            high_age_bars=-1,
            low_age_bars=-1,
            nearest_boundary="not_available",
            nearest_touch_count=0,
            nearest_age_bars=-1,
            boundary_cleanliness_score=0.0,
            boundary_quality_score=0.0,
            boundary_state="boundary_data_missing",
            reason="missing_bars_for_boundary_quality",
        )

    range_high_i = max(bar.high_i for bar in subset)
    range_low_i = min(bar.low_i for bar in subset)
    atr = avg_true_range(bars, max(1, min(copied, lookback_bars)))
    tolerance_points = max(1.0, atr * touch_tolerance_atr)

    high_touches = _touch_count_high(subset, range_high_i, tolerance_points)
    low_touches = _touch_count_low(subset, range_low_i, tolerance_points)
    high_age = _age_to_high(subset, range_high_i, tolerance_points)
    low_age = _age_to_low(subset, range_low_i, tolerance_points)
    cleanliness, cleanliness_reason = _cleanliness_score(high_touches, low_touches, high_age, low_age, lookback_bars)

    boundary = str(nearest_boundary or "").lower()
    if "high" in boundary:
        nearest_name = "range_high"
        nearest_touches = high_touches
        nearest_age = high_age
    elif "low" in boundary:
        nearest_name = "range_low"
        nearest_touches = low_touches
        nearest_age = low_age
    else:
        nearest_name = "not_available"
        nearest_touches = max(high_touches, low_touches)
        nearest_age = min(age for age in (high_age, low_age) if age >= 0) if high_age >= 0 or low_age >= 0 else -1

    evidence_score = 0.0
    if nearest_touches <= 0:
        evidence_score = 20.0
    elif nearest_touches == 1:
        evidence_score = 55.0
    elif 2 <= nearest_touches <= 4:
        evidence_score = 88.0
    elif 5 <= nearest_touches <= 7:
        evidence_score = 72.0
    else:
        evidence_score = 45.0

    age_score = 35.0
    if nearest_age >= 0:
        if nearest_age <= 2:
            age_score = 95.0
        elif nearest_age <= max(4, lookback_bars // 4):
            age_score = 82.0
        elif nearest_age <= max(8, lookback_bars // 2):
            age_score = 62.0
        else:
            age_score = 38.0

    boundary_quality = _clamp(evidence_score * 0.45 + age_score * 0.30 + cleanliness * 0.25)

    if boundary_quality >= 80.0:
        state = "strong_boundary_watch"
    elif boundary_quality >= 60.0:
        state = "usable_boundary_watch"
    elif boundary_quality >= 40.0:
        state = "weak_boundary_watch"
    else:
        state = "low_quality_boundary"

    reason = _join_reason([
        cleanliness_reason,
        f"tf={tf}",
        f"touch_tolerance_atr={touch_tolerance_atr:.2f}",
        f"nearest_boundary={nearest_name}",
        f"nearest_touch_count={nearest_touches}",
        f"nearest_age_bars={nearest_age}",
        "boundary_quality_is_watchlist_evidence_not_directional_signal",
    ])

    return L9BoundaryQuality(
        timeframe=tf,
        bars_copied=copied,
        range_high_i=range_high_i,
        range_low_i=range_low_i,
        atr_points=atr,
        high_touch_count=high_touches,
        low_touch_count=low_touches,
        high_age_bars=high_age,
        low_age_bars=low_age,
        nearest_boundary=nearest_name,
        nearest_touch_count=nearest_touches,
        nearest_age_bars=nearest_age,
        boundary_cleanliness_score=cleanliness,
        boundary_quality_score=boundary_quality,
        boundary_state=state,
        reason=reason,
    )


def weighted_boundary_quality(boundaries: List[L9BoundaryQuality], weights: dict[str, float]) -> float:
    total_weight = 0.0
    total = 0.0
    for boundary in boundaries:
        weight = max(0.0, float(weights.get(boundary.timeframe, 0.0)))
        total_weight += weight
        total += boundary.boundary_quality_score * weight
    if total_weight <= 0.0:
        return 0.0
    return _clamp(total / total_weight)
