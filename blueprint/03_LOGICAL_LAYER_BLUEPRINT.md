# 03 LOGICAL LAYER BLUEPRINT (ACTIVE AUTHORITATIVE 23-LAYER TRADING/SYSTEM BLUEPRINT)

## Purpose
Canonical trading/system layer spine for AURORA CORE. This file is the authoritative logical contract for layers 1-23 and their service boundaries.

This blueprint explains the trading system itself: foundation truth, ranking, taxonomy, selection, selected evidence, review/export, permission, and future validation. It is not a worker-process or overseer-process blueprint.

## System Service Split
- Runtime 0 internal control support
- Publication / FileIO / Route Service
- Board / Dossier Renderer Services
- Governance / Manifest / Telemetry Service
- Workbench / Diagnostics Service
- Runtime 3 calculation gateway support

Services support the chain. They do not own trading truth unless the relevant layer contract explicitly says so.

## Trading/System Truth Owners
1. Foundation Truth Owner — Layers 1-5
2. Surface Scoring Owner — Layers 6-9
3. Taxonomy / Ranking Group Owner — Layers 10-14
4. Basket Selection Owner — Layers 15-16
5. Selected Evidence Owner — Layers 17-22
6. Permission / Alert / Trader-Review Export Owner — Layer 23
7. Validation / Outcome Owner — outcome proof / experiment registry / future strategy tests

## Chain Flow Contract

```text
L1 Account / Prop Truth
-> L2 Market Open / Closed Truth
-> L3 Broker Specs / Value Truth
-> L4 Live Quote / Spread Truth
-> L5 Basic System Gate
-> L6-L9 Surface Scoring
-> L10-L14 Taxonomy / Ranking Groups / Candidate Pool
-> L15-L16 Correlation-Diversified Global Top 10
-> L17-L22 Selected Deep Evidence
-> L23 Review / Permission / Alert State
```

Layer order matters.

- Later layers consume earlier owner packets.
- Later layers must not recalculate, mirror, reopen, repair, or override upstream truth.
- L5 is the only broad all-symbol hard eligibility gate.
- L6-L16 rank/select attention only.
- L17-L22 collect selected evidence only.
- L23 may export manual review packets, but export is not trade permission.
- Static/settled/accepted wording must mean the current chain scope is truly accepted, not merely quiet.
- Incomplete/degraded/stale/unknown truth should be published honestly instead of hidden.

## Operating Laws
1. **One broad hard gate only:** Layer 5 is the only all-symbol hard eligibility gate. Post-L5 layers score, rank, select, label, degrade, publish, verify, alert, or permit only inside their explicit contracts. Not selected does not mean removed.
2. **Scores are descriptive unless validated:** `score_type`; `directional_validity=false`; `expectancy_validated=false`; `trade_permission=false`; high score means inspect-worthy, not profitable.
3. **Selected-evidence-only law:** no all-symbol OHLC/tick/indicators/DOM. Deep evidence is selected-symbol only for Global Top 10, ranking_group leaders, selected backups, manual watch later, and future alert candidates.
4. **Tick is selected and rolling:** 10-minute rolling window, selected symbols captured in parallel/batch, no 10-minute wait per symbol, tick flags matter.
5. **DOM is MT5 proxy-only:** MT5 internal first build only; external DOM/order-flow/liquidity APIs blocked; `MarketBookAdd/MarketBookGet` availability-gated and broker/symbol dependent; no institutional-order-flow claims.
6. **Alerts are rare:** no per-symbol progress spam; Class 1 system/risk/integrity only now. Class 2 setup/strategy alerts require validation, but raw evidence export and manual trader-review packets may exist earlier with clear missing/degraded truth labels.
7. **Runtime visibility law:** Board-only Atomic Update Overview, no artificial slow-drip, no blind unbounded loops, timer pressure must be visible.
8. **Export is not permission:** enabled manual review or trader-chat export never implies enabled trade, auto-trade, entry-signal, or expectancy-validation authority.

---

## Layer Blocks

### L1-L5 — Foundation Truth and Basic Gate
Owns account, prop-rule, market-session, broker-spec, live-quote, spread, and eligibility truth. L5 is the only broad hard gate. These layers decide whether a symbol is usable enough for downstream ranking, not whether it is a trade.

### L6-L9 — Surface Scoring and Attention Ranking
Owns cost/friction, session relevance, movement/range, and structure/location context. These layers decide what deserves attention. They do not imply edge, setup, direction, or permission.

### L10-L14 — Taxonomy, Ranking Groups, and Candidate Sourcing
Owns classification, ranking_group organization, symbol ranking inside groups, group heat/quality, adaptive group selection, and leader candidate pool. This block organizes the universe and sources candidates without claiming trades.

### L15-L16 — Correlation/Diversity and Global Top 10
Owns candidate-pool diversification and the Global Top 10 inspection basket. Global Top 10 means inspect first, not best trades.

### L17-L22 — Selected Deep Evidence
Owns selected-symbol-only OHLC, candle geometry, rolling tick, indicators/reference context, liquidity/risk geometry, and MT5 order-flow proxy evidence. No all-symbol deep evidence collection.

### L23 — Review / Permission / Alert State
Owns manual review packet availability, trader-chat export availability, evidence completeness, missing/degraded evidence lists, setup research candidate state, alert flags, and permission flags. Default trade permission remains false.

---

## Layer Contracts (1-23)

### L1 — Account / Portfolio / Prop Rule Truth
- **Purpose:** Account/portfolio/prop-rule baseline truth.
- **Owns:** balance, equity, margin, free_margin, margin_level_pct, floating_pl, floating_pl_pct, daily_pl, daily_loss_buffer, max_loss_buffer, open_positions_count, pending_orders_count, currency_exposure, symbol_exposure, ranking_group_exposure, correlation_exposure, portfolio_heat, prop_rule_profile_id, prop_rule_status, news_restriction_state.
- **Prop profile fields:** firm_name, account_phase, daily_loss_formula, max_loss_formula, equity_vs_balance_basis, trailing_drawdown_type, static_drawdown_limit, news_restriction_window, max_lots, max_positions, max_daily_trades, weekend_holding_allowed, overnight_holding_allowed, copy_trading_restriction, hedging_restriction, martingale_grid_policy, consistency_rule, rule_last_verified_date.
- **Inputs / MT5 family:** AccountInfo*, Position*/Order* snapshots.
- **Outputs:** portfolio/prop-rule truth rows.
- **Forbidden ownership:** ranking, selection, strategy claims.
- **Publication surface:** Board risk panel, Dossier risk section.
- **Validation/permission rule:** downstream permission must consume, not override.

### L2 — Market Open / Closed Truth
- **Purpose:** session-open availability truth.
- **Owns:** symbols_total, symbols_open, symbols_closed, symbols_unknown, open_pct, closed_pct, unknown_pct, session_known_pct, quote_session_status, trade_session_status, minutes_since_session_open, minutes_until_session_close.
- **Inputs / MT5 family:** SymbolInfoSessionTrade, SymbolInfoSessionQuote.
- **Outputs:** open/closed/unknown session truth.
- **Forbidden ownership:** scoring/selection.
- **Publication surface:** Board market-state + Dossiers.

### L3 — Symbol + Broker Specs Truth
- **Purpose:** spec-calculation and tradeability baseline.
- **Owns:** digits, point, tick_size, tick_value, contract_size, min_lot, lot_step, max_lot, stops_level_points, freeze_level_points, trade_mode, margin_mode, filling_mode, swap_mode, spec_completeness_pct, margin_per_lot, profit_per_point, calculation_mode.
- **Inputs / MT5 family:** SymbolInfoInteger/Double/String, SymbolInfoMarginRate, OrderCalcMargin, OrderCalcProfit.
- **Outputs:** spec truth + completeness/degrade flags.
- **Forbidden ownership:** directional signal.
- **Publication surface:** Dossier specs + governance rows.

### L4 — Market Watch Truth
- **Purpose:** live quote freshness and spread truth.
- **Owns:** bid, ask, last, spread_points, spread_pips, spread_pct, tick_time, tick_age_seconds, quote_freshness_score, daily_open, daily_high, daily_low, daily_close_if_available, quote_valid_flag.
- **Inputs / MT5 family:** SymbolInfoTick.
- **Outputs:** quote freshness + spread state.
- **Forbidden ownership:** ranking_group classification.
- **Publication surface:** Board atomic summary + Dossiers.

### L5 — Basic System Gate
- **Purpose:** single all-symbol hard garbage gate.
- **Blocks:** closed, invalid_bid_ask, stale_quote, essential_specs_missing, trade_mode_disabled, unresolved_classification_review, absurd_spread.
- **Outputs:** eligible_clean_count, eligible_degraded_count, blocked_count, eligible_flag, eligibility_score, block_reason, degraded_reason.
- **Forbidden ownership:** strategy claims.
- **Publication surface:** Board gate summary.

### L6 — Surface Cost / Friction Ranking
- **Purpose:** transaction-friction awareness.
- **Owns:** spread_points, spread_pips, spread_to_recent_range_pct, spread_to_atr_proxy_pct, spread_bps, round_trip_cost_estimate, cost_score, friction_penalty, cost_score_confidence.
- **Outputs:** cost/friction score family.
- **Forbidden ownership:** trade permission.

### L7 — Session Relevance Ranking
- **Purpose:** session-context ranking.
- **Sessions:** Asia, London, New York, London/New York Overlap, Dead Time, Unknown.
- **Owns:** current_session_name, session_minutes_elapsed, session_minutes_remaining, symbol_session_spread_score, symbol_session_activity_score, symbol_session_range_score, symbol_session_tick_flow_score, historical_session_relevance_score, current_session_relevance_score, session_relevance_rank, session_relevance_confidence.
- **Forbidden ownership:** trade permission.

### L8 — Surface Movement / Range Ranking
- **Purpose:** movement and range quality ranking.
- **Owns:** range_5m, range_15m, range_60m, range_day, movement_score, compression_score, expansion_score, movement_quality_score, range_stability_score.
- **Forbidden ownership:** trade permission.

### L9 — Surface Structure / Location Geometry
- **Purpose:** relative location context.
- **Owns:** daily_high, daily_low, daily_open, daily_close_if_available, position_in_daily_range_pct, distance_to_daily_high_pips, distance_to_daily_low_pips, distance_to_daily_high_atr_proxy, distance_to_daily_low_atr_proxy, session_high, session_low, session_open, position_in_session_range_pct, distance_to_session_high_pips, distance_to_session_low_pips, weekly_high, weekly_low, position_in_weekly_range_pct, distance_to_weekly_high_pips, distance_to_weekly_low_pips, nearest_surface_obstacle_distance_pips, available_surface_room_pips, surface_location_score, surface_structure_score.
- **Forbidden ownership:** direction or setup claim.

### L10 — Taxonomy / Ranking Group Classification
- **Purpose:** active taxonomy truth.
- **Owns:** asset_class, market_group, market_segment, ranking_group, classification_source, review_status, ranking_group_symbol_count, ranking_group_open_count, ranking_group_clean_count, ranking_group_degraded_count, standalone_group_allowed.
- **Forbidden ownership:** direct trade calls.

### L11 — Symbol Ranking Inside Ranking Group
- **Purpose:** intra-group ordering.
- **Owns:** ranking_group_rank, market_segment_rank if useful, asset_class_rank if useful, ranking_group_score, ranking_group_rank_percentile, ranking_group_top_n_visible_flag, backup_rank, backup_score, backup_reason.
- **Forbidden ownership:** direct trade calls.

### L12 — Ranking Group Heat / Quality Ranking
- **Purpose:** group-level quality/heat ranking.
- **Owns:** ranking_group_strength, ranking_group_heat, ranking_group_quality_score, ranking_group_activity_score, ranking_group_cost_score, ranking_group_movement_score, ranking_group_clean_count, ranking_group_degraded_count, ranking_group_top_symbol_score, ranking_group_top_n_avg_score, ranking_group_top_n_median_score, backup_depth, rank_stability, rank_change, session_relevance_avg.
- **Two-score model:**
  - `ranking_group_strength = top_n_avg_score + top_symbol_score + clean_count_factor + backup_depth_factor - degraded_penalty`
  - `ranking_group_heat = top_n_avg_score + percent_of_group_above_threshold + top_symbol_separation + rank_stability + session_relevance_avg - churn_penalty`
- **Forbidden ownership:** direct trade calls.

### L13 — Dynamic Ranking Group Selection
- **Purpose:** adaptive group-count selection.
- **Owns:** max selected ranking_groups, min selected ranking_groups, fallback_to_market_segment, fallback_reason, selected_ranking_group_count, selected_market_segment_count, selected_group_list.
- **Logic:** valid groups >=7 => top 7; 3-6 => all valid; <=2 => market_segment fallback.
- **Forbidden ownership:** direct trade calls.

### L14 — Ranking Group Leader Candidate Pool
- **Purpose:** candidate sourcing.
- **Sources:** Top-N from selected ranking_groups, important market_segment leaders, ranking_group heat leaders, backup leaders, raw global leaders if allowed, manual pinned symbols later.
- **Outputs:** candidate_pool_size, candidate_pool_members, candidate_source, candidate_reason, backup_included_flag.
- **Law:** Global Top 10 built from ranking_group leaders, not all symbols directly.
- **Forbidden ownership:** direct trade calls.

### L15 — Correlation / Diversity Selection
- **Purpose:** diversify candidate basket.
- **Scope law:** candidate pool only; no full-universe 1200x1200 matrix.
- **Owns:** corr_to_selected_max, corr_to_selected_avg, correlation_sample_count, correlation_confidence, currency_overlap_score, ranking_group_overlap_score, diversity_score, selection_utility, correlation_reject_reason.
- **Currentness law:** consumes latest-current L14 only. Held or write-degraded candidate pools are operator-visible history, not current downstream truth.
- **Recent window law:** primary correlation timeframe is M15; secondary recent timeframe is M5; H1 is optional reference only. Minimum aligned returns = 64, deep target returns = 350.
- **Heatmap:** Global Top 10 Correlation Heatmap.
- **Forbidden ownership:** direct trade calls.

### L16 — Global Top 10 Builder
- **Purpose:** diversified attention basket builder.
- **Owns:** global_top10, global_top10_rank, global_top10_reason, backup_fill_used, backup_fill_reason, correlation_rejects, fallback_reason.
- **Meaning law:** Global Top 10 is not best 10 trades.
- **Currentness law:** consumes latest-current accepted L15 only. Fallback/held displays must be labelled and must not silently become clean current truth.
- **Forbidden ownership:** direct trade calls.

### L17 — Deep Evidence Selection Split
- **Purpose:** visible-vs-deep split control.
- **Owns:** visible_top_n_only, deep_evidence_selected, alert_eligible_candidate, deep_selected_total, visible_only_total, alert_eligible_total, selection_reason, depth_assignment.
- **Law:** Visible Top-N does not equal deep evidence selected.
- **Currentness law:** consumes latest-current L16 only. Selection Desk visible rows are navigation/readback surfaces, not a fallback source for current downstream truth.
- **Forbidden ownership:** evidence collection and trade permission.

### L18 — Selected Raw OHLC Bar Pack
- **Purpose:** selected-symbol raw bar pack.
- **Selected-symbol only law:** no all-symbol OHLC.
- **Timeframes:** M1/M5/M15/M30/H1/H4/D1/W1.
- **Bar counts:** M1 300, M5 300, M15 350, M30 250, H1 300, H4 200, D1 250, W1 104.
- **Fields:** time, open, high, low, close, tick_volume, spread, real_volume_if_available, bar_complete_flag.
- **Inputs / MT5 family:** CopyRates, MqlRates, CopyTime/Open/High/Low/Close/TickVolume/Spread/RealVolume.
- **Outputs:** selected OHLC pack completeness.
- **Currentness law:** consumes latest-current L17 only. Fresh/aging but shallow history may be `complete_history_limited`; missing, stale, decode_error, or write_failed remains non-current.
- **Forbidden ownership:** candle interpretation, signal, permission.

### L19 — Selected Wick / Candle Geometry Pack
- **Purpose:** one-to-one geometric derivative of L18.
- **Fields:** bar_time, open, high, low, close, range, body, upper_wick, lower_wick, upper_wick_pct, lower_wick_pct, body_pct, close_position_pct, zero_range_flag, bar_complete_flag.
- **Formulas:** range=high-low; body=abs(close-open); upper_wick=high-max(open,close); lower_wick=min(open,close)-low; percentages/close_position as defined.
- **Zero-range rule:** if range==0 => pct fields unavailable; zero_range_flag=true.
- **Currentness law:** consumes latest-current L17 and L18 only. Geometry from stale or blocked upstream is not downstream-allowed.
- **Verification:** synthetic candle tests, manual chart cross-check, live MT5 verification later.
- **Forbidden ownership:** signal, permission.

### L20 — Selected Rolling Tick Pack
- **Purpose:** selected-symbol rolling microstructure proxy.
- **Rules:** 10-minute rolling window; selected batch capture; no waiting 10 minutes per symbol.
- **Fields:** tick_time, bid, ask, last, volume, flags, spread, tick_count_1m/5m/10m, spread_min/max/avg/stddev_10m, tick_gap_max/avg_seconds, bid_change_count_10m, ask_change_count_10m, spread_spike_count_10m.
- **Inputs / MT5 family:** CopyTicks, CopyTicksRange.
- **Law:** tick proxy truth; flags matter.
- **Forbidden ownership:** order-flow certainty, signal, permission.

### L21 — Selected Indicator / Reference Pack
- **Purpose:** selected-symbol indicator/reference context.
- **Initial indicators:** ATR, range percentile, MA slope, stddev, Bollinger Bands, VWAP, spread-to-range.
- **Bollinger fields:** bb_period, bb_deviation, bb_middle, bb_upper, bb_lower, bb_width, bb_width_pct, bb_position_pct, bb_squeeze_score, bb_expansion_score.
- **VWAP fields:** vwap_session, vwap_day, vwap_week_optional, vwap_value, distance_to_vwap_pips, distance_to_vwap_atr, price_position_vs_vwap, vwap_slope, vwap_source, vwap_confidence.
- **VWAP source labels:** real_volume | tick_volume_proxy | unavailable.
- **Inputs / MT5 family:** iATR, iBands, iMA, iStdDev, CopyBuffer, BarsCalculated, IndicatorRelease, custom VWAP.
- **Forbidden claims:** VWAP touch=entry, BB lower band=buy, RSI divergence=signal.

### L22 — Deep Market Evidence / Liquidity / MT5 Order-Flow Proxy Pack
- **Purpose:** deep selected evidence synthesis.
- **Build order:** risk geometry -> liquidity distance map -> VWAP context -> tick-flow proxy -> MT5 DOM proxy if available -> FVG/sweep/reclaim later.
- **Risk geometry fields:** invalidation_distance_pips, invalidation_distance_atr, target_room_pips, target_room_atr, spread_to_stop_ratio, expected_r_after_cost, risk_geometry_score.
- **Liquidity fields:** nearest_liquidity_high_distance_pips, nearest_liquidity_low_distance_pips, equal_high_cluster_count, equal_low_cluster_count, session_high_distance, session_low_distance, prior_day_high_distance, prior_day_low_distance, liquidity_map_confidence.
- **MT5 order-flow proxy fields:** order_flow_source (mt5_tick_proxy|mt5_dom_proxy|unavailable), dom_available_flag, dom_subscription_status, dom_bid_levels_count, dom_ask_levels_count, dom_bid_volume_total, dom_ask_volume_total, dom_imbalance_ratio, tick_flow_proxy_available, tick_count_10m, bid_change_count_10m, ask_change_count_10m, spread_spike_count_10m, order_flow_confidence.
- **Inputs / MT5 family:** MarketBookAdd, MarketBookGet, MarketBookRelease, OnBookEvent, CopyTicks.
- **Forbidden claims:** institutional-flow certainty, touch-equals-direction claims, sweep-equals-reversal claims, or FVG-equals-continuation claims.

### L23 — Setup / Strategy / Permission / Trader-Review Export State
- **Purpose:** package selected-symbol evidence into manual review, trader-chat export, setup research, permission, and alert state without confusing export with permission.
- **Owns:** manual_review_packet_available, trader_chat_export_available, evidence_completeness_pct, missing_evidence_list, degraded_evidence_list, setup_research_candidate, structure_context_summary, liquidity_context_summary, risk_geometry_context_summary, review_warnings, trade_allowed, auto_trade_allowed, directional_alert_allowed, class_1_system_alert_allowed, class_2_setup_alert_allowed.
- **Export defaults:** manual review and trader-chat export may be true when a labelled truth packet exists, even if partial/degraded. Missing L18-L22 evidence reduces completeness/confidence; it does not block export.
- **Permission defaults:** rare system-integrity alerts may be allowed; setup, directional, auto-trade, live, and trade authority remain disabled by default.
- **Class 1 allowed:** session changed, atomic overview stale, cycle failed, critical governance write failure, terminal disconnected, prop rule danger, tick capture failed for selected batch.
- **Class 2 / permission future requires:** exact strategy rules, validated permission standard, Layer 1 pass, cooldown pass, and explicit validation/permission upgrade. Backtesting/OOS/forward proof is required for Aurora-generated permission or auto-trading, not for raw evidence export.
- **Forbidden phrases:** directional certainty, guarantee language, probability marketing, or best-now phrasing.
- **Meaning law:** enabled manual review or trader-chat export does not imply enabled trade, entry-signal, auto-trade, or expectancy-validation authority.

## Heatmap Publication Set
1. Ranking Group Strength Heatmap
2. Ranking Group Heat / Quality Heatmap
3. Global Top 10 Correlation Heatmap
4. Session Relevance Heatmap
5. Selected Evidence Completeness Heatmap

## Global No-Go Summary
- No all-symbol deep evidence collection.
- No strategy/edge/live/readiness claims from architecture.
- No auto-trade permission by score alone.
- No confusion between trader-review export and Aurora trade permission.
