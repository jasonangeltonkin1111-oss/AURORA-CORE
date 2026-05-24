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


if __name__ == "__main__":
    run_selftest()
    print("L19 geometry self-test OK")
