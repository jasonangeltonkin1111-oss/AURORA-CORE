from __future__ import annotations

# Layer 9 — Structure / Location Geometry contract.
# This file is intentionally constants-only. It creates no runtime authority,
# no OHLC route, no trade permission, and no entry signal.

L9_LAYER_FOLDER = "Layer_9_Structure_Location_Geometry"
L9_INPUT_NAME = "l9_input_primitives.csv"
L9_INPUT_MANIFEST_NAME = "l9_input_primitives.manifest"
L9_RANKED_NAME = "ranked_symbols.csv"
L9_MANIFEST_NAME = "ranked_symbols.manifest"
L9_TOP20_NAME = "ranked_symbols_top20.txt"
L9_SYMBOL_RANK_FOLDER = "SymbolRanks"
L9_SYMBOL_RANK_FILENAME_MODE = "sanitized_symbol__payload_checksum"
L9_JOB_TYPE = "L9_STRUCTURE_LOCATION_GEOMETRY_V1"
L9_MODEL_VERSION = "structure_location_geometry_v1_priority_windows"
L9_LAYER_NAME = "Layer 9 - Structure / Location Geometry"
L9_OWNER = "Runtime 4 - Surface Scoring Owner"
L9_SOURCE_OWNER = "Runtime_1_Shared_OHLC_Priority_Windows"
L9_AUTHORITY = "calculation_support_only"
L9_POLICY = "watchlist_only_surface_context"

# Required v1 windows. They must be produced by Runtime 1. L9 only reads them.
L9_TF_WEIGHTS = {
    "M15": 15.0,
    "H1": 25.0,
    "H4": 25.0,
    "D1": 35.0,
}

L9_SCORE_WEIGHTS = {
    "structure_proximity": 25.0,
    "multi_timeframe_confluence": 20.0,
    "available_room_asymmetry": 15.0,
    "boundary_quality": 15.0,
    "location_clarity": 10.0,
    "trigger_zone_freshness": 10.0,
    "quote_data_quality": 5.0,
}

L9_BUCKETS = (
    "elite_structure_watch",
    "strong_structure_watch",
    "acceptable_structure_watch",
    "weak_structure_watch",
    "low_attention_structure",
)

L9_RANK_STATES = (
    "ranked",
    "ranked_partial",
    "ranked_risk_review",
    "not_rankable_quality",
)

L9_EVENT_ZONES = (
    "near_high_event_zone",
    "near_low_event_zone",
    "upper_range_watch",
    "lower_range_watch",
    "midrange_low_attention",
    "compression_at_boundary",
    "structure_data_partial",
)

L9_LOCATION_CONTEXT_FIELDS = [
    "location_context_time_basis",
    "distance_to_previous_day_high",
    "distance_to_previous_day_low",
    "distance_to_asian_high",
    "distance_to_asian_low",
    "distance_to_london_high",
    "distance_to_london_low",
    "position_in_session_range_pct",
    "position_in_daily_range_pct",
    "nearest_surface_reference",
    "nearest_surface_obstacle_distance_pips",
    "available_surface_room_pips",
    "surface_geometry_confidence",
    "surface_geometry_confidence_reason",
]

L9_OUTPUT_FIELDS = [
    "rank_index", "symbol", "layer_id", "layer_name", "l9_model_version",
    "structure_watchlist_score", "structure_bucket", "rank_state", "score_quality",
    "geometry_regime", "event_zone", "watchlist",
    "asset_class", "ranking_group", "market_state", "quote_quality", "surface_quality",
    "tick_age_seconds", "spread_bps", "price_basis", "price_basis_quality", "price_used",
    *L9_LOCATION_CONTEXT_FIELDS,
    "structure_proximity_score", "multi_timeframe_confluence_score", "available_room_asymmetry_score",
    "boundary_quality_score", "location_clarity_score", "trigger_zone_freshness_score", "quote_data_quality_score",
    "m15_position_pct", "m15_zone_state", "m15_distance_to_high_atr", "m15_distance_to_low_atr", "m15_score_component",
    "h1_position_pct", "h1_zone_state", "h1_distance_to_high_atr", "h1_distance_to_low_atr", "h1_score_component",
    "h4_position_pct", "h4_zone_state", "h4_distance_to_high_atr", "h4_distance_to_low_atr", "h4_score_component",
    "d1_position_pct", "d1_zone_state", "d1_distance_to_high_atr", "d1_distance_to_low_atr", "d1_score_component",
    "nearest_boundary", "nearest_boundary_distance_atr", "room_up_atr", "room_down_atr", "room_profile",
    "near_high_event_zone", "near_low_event_zone", "midrange_trap", "compression_at_boundary",
    "boundary_touch_count", "boundary_age_bars", "boundary_cleanliness_state",
    "ohlc_priority_window_checksum", "ohlc_window_files_seen", "ohlc_window_files_missing", "reason",
]
