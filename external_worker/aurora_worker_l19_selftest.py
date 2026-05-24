from __future__ import annotations

from aurora_worker_l19 import _apply_wave2_structures, _apply_wave3_structures, _build_geometry


def _row(bar_time: str, open_i: int, high_i: int, low_i: int, close_i: int) -> list[str]:
    return [bar_time, str(open_i), str(high_i), str(low_i), str(close_i), "10", "2", "0"]


def _geo(index: int, bar_time: str, open_i: int, high_i: int, low_i: int, close_i: int):
    return _build_geometry(index, _row(bar_time, open_i, high_i, low_i, close_i), 0.0001, 4)


def _assert_equal(label: str, actual: str, expected: str) -> None:
    if actual != expected:
        raise AssertionError(f"{label}: expected {expected!r}, got {actual!r}")


def _assert_true(label: str, condition: bool) -> None:
    if not condition:
        raise AssertionError(label)


def run_selftest() -> None:
    point = 0.0001
    digits = 4

    geo = _build_geometry(1, _row("1000", 10000, 11000, 9800, 10200), point, digits)
    _assert_true("basic candle valid", geo.valid)
    _assert_equal("basic range", geo.range_text, "0.12")
    _assert_equal("basic body percent", geo.body_pct, "16.7%")
    _assert_equal("basic upper wick percent", geo.upper_wick_pct, "66.7%")
    _assert_equal("basic lower wick percent", geo.lower_wick_pct, "16.7%")
    _assert_equal("basic close position", geo.close_position_pct, "33.3%")
    _assert_equal("basic close vs open", geo.close_vs_open, "Up")
    _assert_true("basic candle long upper wick", "Long Upper Wick" in geo.structure)

    doji = _build_geometry(1, _row("1001", 10000, 11000, 9000, 10010), point, digits)
    _assert_true("doji valid", doji.valid)
    _assert_true("doji structure", "Doji" in doji.structure)

    dragonfly = _build_geometry(1, _row("1002", 10980, 11000, 9000, 11000), point, digits)
    _assert_true("dragonfly valid", dragonfly.valid)
    _assert_true("dragonfly structure", "Dragonfly Doji" in dragonfly.structure)

    gravestone = _build_geometry(1, _row("1003", 9020, 11000, 9000, 9000), point, digits)
    _assert_true("gravestone valid", gravestone.valid)
    _assert_true("gravestone structure", "Gravestone Doji" in gravestone.structure)

    marubozu = _build_geometry(1, _row("1004", 9000, 10050, 8950, 10000), point, digits)
    _assert_true("marubozu valid", marubozu.valid)
    _assert_true("marubozu structure", "Marubozu" in marubozu.structure)

    zero = _build_geometry(1, _row("1005", 10000, 10000, 10000, 10000), point, digits)
    _assert_true("zero range detected", zero.zero_range)
    _assert_true("zero range not valid geometry", not zero.valid)

    invalid_high_low = _build_geometry(1, _row("1006", 10000, 9900, 10000, 10000), point, digits)
    _assert_true("high below low invalid", not invalid_high_low.valid)
    _assert_equal("high below low reason", invalid_high_low.invalid_reason, "high below low")

    invalid_open = _build_geometry(1, _row("1007", 12000, 11000, 9000, 10000), point, digits)
    _assert_true("open outside range invalid", not invalid_open.valid)
    _assert_equal("open outside range reason", invalid_open.invalid_reason, "open outside high low range")

    invalid_close = _build_geometry(1, _row("1008", 10000, 11000, 9000, 12000), point, digits)
    _assert_true("close outside range invalid", not invalid_close.valid)
    _assert_equal("close outside range reason", invalid_close.invalid_reason, "close outside high low range")

    current_possible = _geo(0, "2120", 10700, 10900, 10600, 10800)

    previous_down = _geo(2, "2000", 10500, 10600, 9900, 10000)
    bullish_engulfing = _geo(1, "2060", 9950, 10800, 9900, 10700)
    wave2, tagged = _apply_wave2_structures((current_possible, bullish_engulfing, previous_down))
    _assert_equal("wave2 tagged count bullish", str(tagged), "1")
    _assert_true("current possible not wave2 tagged", "Bullish Engulfing" not in wave2[0].structure)
    _assert_true("bullish engulfing tagged", "Bullish Engulfing" in wave2[1].structure)

    previous_up = _geo(2, "3000", 10000, 10600, 9900, 10500)
    bearish_engulfing = _geo(1, "3060", 10550, 10600, 9700, 9800)
    wave2_bear, tagged_bear = _apply_wave2_structures((current_possible, bearish_engulfing, previous_up))
    _assert_equal("wave2 tagged count bearish", str(tagged_bear), "1")
    _assert_true("bearish engulfing tagged", "Bearish Engulfing" in wave2_bear[1].structure)

    previous_range = _geo(2, "4000", 10000, 11000, 9000, 10500)
    inside_bar = _geo(1, "4060", 10100, 10800, 9300, 10600)
    wave2_inside, tagged_inside = _apply_wave2_structures((current_possible, inside_bar, previous_range))
    _assert_equal("wave2 tagged count inside", str(tagged_inside), "1")
    _assert_true("inside bar tagged", "Inside Bar" in wave2_inside[1].structure)

    previous_small = _geo(2, "5000", 10000, 10500, 9500, 10200)
    outside_bar = _geo(1, "5060", 10100, 10600, 9400, 10300)
    wave2_outside, tagged_outside = _apply_wave2_structures((current_possible, outside_bar, previous_small))
    _assert_equal("wave2 tagged count outside", str(tagged_outside), "1")
    _assert_true("outside bar tagged", "Outside Bar" in wave2_outside[1].structure)

    # Wave 3 policy: index 0 is current possible and must not receive confirmed three-candle tags.
    oldest_down = _geo(3, "6000", 11000, 11100, 9900, 10000)
    middle_small = _geo(2, "6060", 9950, 10100, 9800, 10000)
    morning_star = _geo(1, "6120", 10050, 10800, 10000, 10700)
    wave3, tagged3 = _apply_wave3_structures((current_possible, morning_star, middle_small, oldest_down))
    _assert_equal("wave3 tagged count morning", str(tagged3), "1")
    _assert_true("current possible not wave3 tagged", "Morning Star" not in wave3[0].structure)
    _assert_true("morning star tagged", "Morning Star" in wave3[1].structure)

    oldest_up = _geo(3, "7000", 10000, 11100, 9900, 11000)
    middle_small2 = _geo(2, "7060", 11000, 11200, 10900, 10950)
    evening_star = _geo(1, "7120", 10900, 10950, 10100, 10200)
    wave3_evening, tagged_evening = _apply_wave3_structures((current_possible, evening_star, middle_small2, oldest_up))
    _assert_equal("wave3 tagged count evening", str(tagged_evening), "1")
    _assert_true("evening star tagged", "Evening Star" in wave3_evening[1].structure)

    soldier_old = _geo(3, "8000", 10000, 10400, 9900, 10300)
    soldier_mid = _geo(2, "8060", 10200, 10700, 10100, 10600)
    soldier_cur = _geo(1, "8120", 10500, 11000, 10400, 10900)
    wave3_soldiers, tagged_soldiers = _apply_wave3_structures((current_possible, soldier_cur, soldier_mid, soldier_old))
    _assert_equal("wave3 tagged count soldiers", str(tagged_soldiers), "1")
    _assert_true("three white soldiers tagged", "Three White Soldiers" in wave3_soldiers[1].structure)

    crow_old = _geo(3, "9000", 11000, 11100, 10600, 10700)
    crow_mid = _geo(2, "9060", 10800, 10900, 10300, 10400)
    crow_cur = _geo(1, "9120", 10500, 10600, 10000, 10100)
    wave3_crows, tagged_crows = _apply_wave3_structures((current_possible, crow_cur, crow_mid, crow_old))
    _assert_equal("wave3 tagged count crows", str(tagged_crows), "1")
    _assert_true("three black crows tagged", "Three Black Crows" in wave3_crows[1].structure)


if __name__ == "__main__":
    run_selftest()
    print("L19 geometry wave 1, wave 2, and wave 3 self-test OK")
