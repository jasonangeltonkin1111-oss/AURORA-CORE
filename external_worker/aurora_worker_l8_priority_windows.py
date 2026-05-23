from __future__ import annotations

from pathlib import Path

import aurora_worker_l8_movement as _l8

# Gateway compatibility adapter for the Runtime 1 active Shared OHLC owner.
# Source truth: Runtime 1 writes L8 OHLC priority windows under:
#   <server>/Shared Market Data/OHLC Store/Symbols/<symbol>/Priority Windows/<TF>.window.csv
# This adapter does not calculate a second model and does not fetch broker history.
# It only redirects the existing L8 movement/range worker away from the deprecated
# OHLC Store/Fast Windows root and into the active Runtime 1 priority-window route.


def _shared_ohlc_priority_window_root(outbox: Path) -> Path:
    account_root = outbox.parents[2]
    server_root = account_root.parent
    return server_root / "Shared Market Data" / "OHLC Store" / "Symbols"


def _score_row_priority_windows(row, symbols_root: Path):
    symbol = _l8._safe_text(row, "symbol")
    symbol_dir = symbols_root / _l8._sanitize_path_part(symbol) / "Priority Windows"
    checksums = _l8._ohlc_window_checksum_packet(symbol_dir)
    m5 = _l8._tf_metrics(_l8._read_ohlc_window(symbol_dir / "M5.window.csv"), 12, 48)
    m15 = _l8._tf_metrics(_l8._read_ohlc_window(symbol_dir / "M15.window.csv"), 16, 64)
    h1 = _l8._tf_metrics(_l8._read_ohlc_window(symbol_dir / "H1.window.csv"), 24, 72)
    h4 = _l8._tf_metrics(_l8._read_ohlc_window(symbol_dir / "H4.window.csv"), 6, 30)

    market_state = _l8._safe_text(row, "market_state")
    quote_quality = _l8._safe_text(row, "quote_quality")
    surface_quality = _l8._safe_text(row, "surface_quality")
    spread_bps = _l8._safe_float(row.get("spread_bps"))
    tick_age = _l8._safe_float(row.get("tick_age_seconds"))

    availability_score, availability_state, availability_reason = _l8._score_availability(int(m5["bars_copied"]), int(m15["bars_copied"]), int(h1["bars_copied"]), int(h4["bars_copied"]))
    exp_scores = [_l8._expansion_score(float(m5["expansion_ratio"])), _l8._expansion_score(float(m15["expansion_ratio"])), _l8._expansion_score(float(h1["expansion_ratio"]))]
    expansion_score = sum(score for score, _reason in exp_scores) / 3.0
    expansion_reasons = ";".join(reason for _score, reason in exp_scores)

    movement_presence = min(100.0, ((float(m5["avg_true_baseline"]) > 0) * 28.0) + ((float(m15["avg_true_baseline"]) > 0) * 32.0) + ((float(h1["avg_true_baseline"]) > 0) * 32.0) + ((float(h4["avg_true_baseline"]) > 0) * 8.0))
    agreement_values = [float(m5["expansion_ratio"]), float(m15["expansion_ratio"]), float(h1["expansion_ratio"])]
    expanding = sum(1 for x in agreement_values if x >= 1.05)
    compressed = sum(1 for x in agreement_values if 0 < x < 0.75)
    violent = sum(1 for x in agreement_values if x > 3.0)
    agreement_score = max(0.0, min(100.0, 80.0 + expanding * 6.0 - compressed * 18.0 - violent * 30.0))

    avg_chop = (float(m5["chop_proxy"]) + float(m15["chop_proxy"]) + float(h1["chop_proxy"])) / 3.0
    cleanliness_score = max(0.0, min(100.0, 100.0 - max(0.0, avg_chop - 1.0) * 18.0))
    positions = [float(m5["close_position_pct"]), float(m15["close_position_pct"]), float(h1["close_position_pct"])]
    extreme_count = sum(1 for x in positions if x < 5.0 or x > 95.0)
    edge_count = sum(1 for x in positions if 5.0 <= x < 20.0 or 80.0 < x <= 95.0)
    range_position_score = max(0.0, 90.0 - extreme_count * 35.0 - edge_count * 12.0)
    quote_score, quote_reason = _l8._quote_surface_score(quote_quality, surface_quality, spread_bps, tick_age)
    spike_risk = any(float(tf["spike_ratio"]) > 4.0 for tf in (m5, m15, h1)) or violent > 0

    movement_score = max(0.0, min(100.0, availability_score * 0.20 + movement_presence * 0.20 + expansion_score * 0.25 + agreement_score * 0.15 + cleanliness_score * 0.10 + range_position_score * 0.05 + quote_score * 0.05))

    rank_state = "ranked"
    score_quality = "usable_true_range_movement_range_model"
    if availability_state == "missing":
        rank_state = "not_rankable_quality"
        score_quality = "not_rankable_ohlc_priority_windows_missing"
    elif availability_state == "degraded":
        rank_state = "ranked_degraded"
        score_quality = "degraded_ohlc_priority_windows_partial"
    elif int(h4["bars_copied"]) < 30:
        rank_state = "ranked_partial"
        score_quality = "usable_core_windows_h4_context_partial"
    if market_state != "open":
        rank_state = "not_rankable_quality"
        score_quality = "not_rankable_market_not_open"
    elif spike_risk and rank_state == "ranked":
        rank_state = "ranked_degraded"
        score_quality = "degraded_single_bar_true_range_spike_or_violent_expansion_risk"
    elif quote_score < 45 and rank_state == "ranked":
        rank_state = "ranked_degraded"
        score_quality = "degraded_quote_surface_quality"

    if spike_risk:
        regime = "violent_spike_risk"
    elif avg_chop > 4.0:
        regime = "choppy_range"
    elif compressed >= 2:
        regime = "compressed"
    elif expanding >= 2:
        regime = "clean_expansion"
    else:
        regime = "normal"
    h4_context = "unavailable" if int(h4["bars_copied"]) <= 0 else ("confirms" if float(h4["expansion_ratio"]) >= 1.05 else ("contradicts_short_term" if expanding >= 2 and float(h4["expansion_ratio"]) < 0.75 else "neutral"))

    reasons = ["ok_L5Pass", availability_reason, expansion_reasons, quote_reason, f"regime={regime}", f"model={_l8.L8_MODEL_VERSION}", "source=Runtime_1_Shared_OHLC_Priority_Windows", "ranking_only_no_direction_no_entry"]
    if spike_risk:
        reasons.append("single_bar_true_range_spike_or_violent_expansion_risk")
    if extreme_count > 0:
        reasons.append("range_position_extreme")
    if avg_chop > 4.0:
        reasons.append("true_range_chop_proxy_high")

    return {
        "symbol": symbol, "l8_model_version": _l8.L8_MODEL_VERSION, "movement_score": movement_score, "movement_bucket": _l8._bucket_from_score(movement_score), "rank_state": rank_state, "score_quality": score_quality, "movement_regime": regime,
        "asset_class": _l8._safe_text(row, "asset_class"), "ranking_group": _l8._safe_text(row, "ranking_group"), "market_state": market_state, "quote_quality": quote_quality, "surface_quality": surface_quality,
        "tick_age_seconds": tick_age, "spread_bps": spread_bps, "range_availability_score": availability_score, "movement_quality_score": movement_presence, "expansion_compression_score": expansion_score,
        "multi_timeframe_agreement_score": agreement_score, "movement_cleanliness_score": cleanliness_score, "range_position_quality_score": range_position_score, "quote_surface_quality_score": quote_score,
        "m5_bars_copied": int(m5["bars_copied"]), "m15_bars_copied": int(m15["bars_copied"]), "h1_bars_copied": int(h1["bars_copied"]), "h4_bars_copied": int(h4["bars_copied"]),
        "ohlc_fast_window_checksum": checksums["ohlc_fast_window_checksum"], "ohlc_window_files_seen": int(checksums["ohlc_window_files_seen"]), "ohlc_window_files_missing": int(checksums["ohlc_window_files_missing"]),
        "m5_window_checksum": checksums["m5_window_checksum"], "m15_window_checksum": checksums["m15_window_checksum"], "h1_window_checksum": checksums["h1_window_checksum"], "h4_window_checksum": checksums["h4_window_checksum"],
        "m5_range_points_12": float(m5["range_recent"]), "m5_range_points_48": float(m5["range_baseline"]), "m5_avg_true_range_12": float(m5["avg_true_recent"]), "m5_avg_true_range_48": float(m5["avg_true_baseline"]), "m5_expansion_ratio": float(m5["expansion_ratio"]), "m5_chop_proxy": float(m5["chop_proxy"]), "m5_spike_ratio": float(m5["spike_ratio"]), "m5_close_position_pct": float(m5["close_position_pct"]),
        "m15_range_points_16": float(m15["range_recent"]), "m15_range_points_64": float(m15["range_baseline"]), "m15_avg_true_range_16": float(m15["avg_true_recent"]), "m15_avg_true_range_64": float(m15["avg_true_baseline"]), "m15_expansion_ratio": float(m15["expansion_ratio"]), "m15_chop_proxy": float(m15["chop_proxy"]), "m15_spike_ratio": float(m15["spike_ratio"]), "m15_close_position_pct": float(m15["close_position_pct"]),
        "h1_range_points_24": float(h1["range_recent"]), "h1_range_points_72": float(h1["range_baseline"]), "h1_avg_true_range_24": float(h1["avg_true_recent"]), "h1_avg_true_range_72": float(h1["avg_true_baseline"]), "h1_expansion_ratio": float(h1["expansion_ratio"]), "h1_chop_proxy": float(h1["chop_proxy"]), "h1_spike_ratio": float(h1["spike_ratio"]), "h1_close_position_pct": float(h1["close_position_pct"]),
        "h4_range_points_6": float(h4["range_recent"]), "h4_range_points_30": float(h4["range_baseline"]), "h4_avg_true_range_6": float(h4["avg_true_recent"]), "h4_avg_true_range_30": float(h4["avg_true_baseline"]), "h4_expansion_ratio": float(h4["expansion_ratio"]), "h4_context": h4_context,
        "single_bar_spike_risk": spike_risk, "range_position_extreme": extreme_count > 0, "reason": _l8._bounded_reason(";".join(reasons)), "trade_permission": "false", "selection_runtime": "false",
    }


def publish_l8_movement_range_rankings(outbox: Path):
    old_root = _l8._shared_ohlc_fast_window_root
    old_score = _l8._score_row
    old_source = _l8.L8_SOURCE_OWNER
    try:
        _l8.L8_SOURCE_OWNER = "Runtime_1_Shared_OHLC_Priority_Windows"
        _l8._shared_ohlc_fast_window_root = _shared_ohlc_priority_window_root
        _l8._score_row = _score_row_priority_windows
        return _l8.publish_l8_movement_range_rankings(outbox)
    finally:
        _l8._shared_ohlc_fast_window_root = old_root
        _l8._score_row = old_score
        _l8.L8_SOURCE_OWNER = old_source
