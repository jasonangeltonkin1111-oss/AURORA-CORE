from __future__ import annotations

from aurora_worker_l19 import _build_geometry


def _row(bar_time: str, open_i: int, high_i: int, low_i: int, close_i: int) -> list[str]:
    return [bar_time, str(open_i), str(high_i), str(low_i), str(close_i), "10", "2", "0"]


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
    _assert_equal("basic body", geo.body_text, "0.02")
    _assert_equal("basic upper wick", geo.upper_wick_text, "0.08")
    _assert_equal("basic lower wick", geo.lower_wick_text, "0.02")
    _assert_equal("basic body percent", geo.body_pct, "16.7%")
    _assert_equal("basic upper wick percent", geo.upper_wick_pct, "66.7%")
    _assert_equal("basic lower wick percent", geo.lower_wick_pct, "16.7%")
    _assert_equal("basic close position", geo.close_position_pct, "33.3%")
    _assert_equal("basic close vs open", geo.close_vs_open, "Up")
    _assert_equal("basic geometry state", geo.geometry_state, "Geometry Only")

    down = _build_geometry(1, _row("1001", 10200, 11000, 9800, 10000), point, digits)
    _assert_true("down candle valid", down.valid)
    _assert_equal("down close vs open", down.close_vs_open, "Down")
    _assert_equal("down body", down.body_text, "0.02")
    _assert_equal("down upper wick", down.upper_wick_text, "0.08")
    _assert_equal("down lower wick", down.lower_wick_text, "0.02")

    flat = _build_geometry(1, _row("1002", 10000, 11000, 9000, 10000), point, digits)
    _assert_true("flat candle valid", flat.valid)
    _assert_equal("flat close vs open", flat.close_vs_open, "Flat")
    _assert_equal("flat body percent", flat.body_pct, "0.0%")
    _assert_equal("flat close position", flat.close_position_pct, "50.0%")

    zero = _build_geometry(1, _row("1003", 10000, 10000, 10000, 10000), point, digits)
    _assert_true("zero range detected", zero.zero_range)
    _assert_true("zero range not valid geometry", not zero.valid)
    _assert_equal("zero range pct unavailable", zero.body_pct, "n/a")
    _assert_equal("zero range state", zero.geometry_state, "Zero Range")

    invalid_high_low = _build_geometry(1, _row("1004", 10000, 9900, 10000, 10000), point, digits)
    _assert_true("high below low invalid", not invalid_high_low.valid)
    _assert_equal("high below low reason", invalid_high_low.invalid_reason, "high below low")

    invalid_open = _build_geometry(1, _row("1005", 12000, 11000, 9000, 10000), point, digits)
    _assert_true("open outside range invalid", not invalid_open.valid)
    _assert_equal("open outside range reason", invalid_open.invalid_reason, "open outside high low range")

    invalid_close = _build_geometry(1, _row("1006", 10000, 11000, 9000, 12000), point, digits)
    _assert_true("close outside range invalid", not invalid_close.valid)
    _assert_equal("close outside range reason", invalid_close.invalid_reason, "close outside high low range")


if __name__ == "__main__":
    run_selftest()
    print("L19 wick/candle geometry self-test OK")
