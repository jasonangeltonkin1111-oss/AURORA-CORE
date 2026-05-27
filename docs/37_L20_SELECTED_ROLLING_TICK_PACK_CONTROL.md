# 37 L20 SELECTED ROLLING TICK PACK CONTROL

## Purpose

Layer 20 owns selected-symbol rolling tick-window proxy metrics derived from MT5 tick-history rows for already-selected symbols.

It is not the source owner for current bid, current ask, current last, live spread, quote freshness, institutional order flow, buy/sell pressure, setup confirmation, trade permission, execution, or prop-firm readiness.

## Source Owner Law

```text
current_bid_owner=L4_market_watch_quote_truth
current_ask_owner=L4_market_watch_quote_truth
current_last_owner=L4_market_watch_quote_truth
current_live_spread_owner=L4_market_watch_quote_truth
current_quote_freshness_owner=L4_market_watch_quote_truth
selected_tick_window_metric_owner=L20_selected_rolling_tick_pack
```

L4 owns current Market Watch quote truth. L20 may store historical `MqlTick` row observations internally only to derive selected rolling-window metrics. L20 must not republish those observations as current quote authority and must not override L4 packets.

## Question Answered

```text
For the selected L17/L18/L19 evidence scope, what do the selected rolling MT5 tick-window observations show as broker tick/spread proxy context?
```

## Hard Boundary

```text
selected_symbols_only=true
all_symbol_tick_harvest=false
full_universe_CopyTicks=false
full_universe_CopyTicksRange=false
serial_10_minute_wait_per_symbol=false
current_quote_truth_owner=false
institutional_order_flow_claim=false
buy_sell_aggression_claim=false
trade_permission=false
entry_signal=false
execution=false
```

L20 must not become L4 or L22. L4 owns live quote/spread/freshness truth. L22 may later synthesize tick-flow proxy context, DOM proxy context, liquidity map context, and risk geometry. L20 only prepares bounded selected rolling tick-window metrics.

## Inputs

Primary selected scope:

```text
L17 deep evidence selected output
L18 selected raw OHLC selected-dossier scope
L19 selected candle geometry selected-dossier scope
```

Current quote reference:

```text
L4 Market Watch / quote truth packet
```

Fallback scope may use Selection Desk selected/global rows only when labelled degraded. It must not expand to all symbols.

## Allowed MT5 Data Boundary

```text
CopyTicks
CopyTicksRange
MqlTick.time_msc
MqlTick.bid as historical tick-row observation only
MqlTick.ask as historical tick-row observation only
MqlTick.last as historical tick-row observation only
MqlTick.volume as historical tick-row observation only
MqlTick.volume_real as historical tick-row observation only
MqlTick.flags as historical tick-row observation only
SymbolInfoTick only through/against L4 quote reference; L4 remains owner
```

Python/external worker must not collect broker ticks directly.

## Owned Metrics

```text
tick_window_oldest_time
tick_window_latest_time
tick_window_age_seconds
tick_row_count_1m
tick_row_count_5m
tick_row_count_10m
tick_observed_bid_change_count_10m
tick_observed_ask_change_count_10m
tick_observed_last_change_count_10m
tick_observed_volume_change_count_10m
tick_observed_bid_up_count_10m
tick_observed_bid_down_count_10m
tick_observed_ask_up_count_10m
tick_observed_ask_down_count_10m
spread_observed_min_10m
spread_observed_max_10m
spread_observed_avg_10m
spread_observed_stddev_10m
spread_observed_spike_count_10m
tick_gap_max_seconds
tick_gap_avg_seconds
mid_observed_change_count_10m
mid_observed_range_points_10m
tick_pack_status
tick_capture_confidence
tick_proxy_boundary_text
l4_quote_reference_status
```

## Must Not Own

```text
current_bid
current_ask
current_last
current_live_spread
current_quote_freshness
SymbolInfoTick live quote surface truth
raw_ohlc_source
candle_geometry
indicators
ATR
VWAP
DOM
liquidity_map
risk_geometry
setup_confirmation
entry_signal
trade_permission
execution
full_universe_tick_history
private_tick_cache_outside_owner_contract
```

## Rolling Buffer Law

```text
startup_bootstrap_allowed=true
normal_refresh_cold_rebuild=false
normal_publish_resets_buffer=false
rolling_buffer_owner=L20_selected_tick_window_metric_owner_only
rolling_window_seconds=600
selected_capture_parallel=true
partial_capture_allowed=true
```

Allowed behavior:

```text
EA startup/new selected symbol: bootstrap last 10 minutes of tick rows
runtime update: append only tick rows newer than last_tick_msc
runtime maintenance: prune tick rows older than rolling window
runtime summary: recompute metrics from current buffer
publication: print state without resetting buffer
```

Forbidden behavior:

```text
re-fetch_full_10m_window_every_publish=false
rebuild_all_symbol_tick_history=false
reset_on_board_refresh=false
reset_on_dossier_refresh=false
reset_on_same_selected_set_reprint=false
reset_on_spread_spike=false
reset_on_short_tick_drought=false
```

## Selected-Set Change Law

```text
same_selected_set=keep_buffers
new_symbol=bootstrap_new_symbol_only
symbol_leaves=RETIRED_GRACE
retire_after_minutes=15
restore_if_reentered_during_grace=true
purge_after_grace=true
```

## Status Vocabulary

```text
not_wired
missing_scope
BOOTSTRAPPING
ACTIVE_ROLLING
accepted
degraded
partial
DEGRADED_LOW_SAMPLE
DEGRADED_STALE_TICKS
DEGRADED_GAPPY_FEED
DEGRADED_SPREAD_UNSTABLE
UNAVAILABLE_NO_TICKS
RETIRED_GRACE
RESET_REQUIRED
no_ticks_returned
stale_tick_window
insufficient_tick_window
copyticks_failed
l4_quote_reference_missing
l4_quote_reference_stale
write_degraded
write_failed
```

## Board Surface Law

Board is cockpit only:

```text
L20 Tick Window: selected=10 active=9 degraded=1 spikes=4 gappy=1 missing=0
SYMBOL | TickRows10m <count> | SprObsAvg <points> | SprObsMax <points> | Spike <count> | GapMax <seconds> | <status>
```

Board must not print raw tick dumps or present L20 observations as current quote truth.

## Dossier Surface Law

Dossier may show deeper per-symbol evidence:

```text
L20 SELECTED ROLLING TICK WINDOW PACK
Status
Window
Source: MT5 historical tick rows; current quote owner=L4
L4 Reference
Tick row activity 1m/5m/10m
Observed spread min/avg/max/stddev/spikes
Gap avg/max
Observed quote-row changes bid/ask/last/volume
Observed mid proxy changes/range
Quality/confidence/flags
Boundary: review-only; no signal or permission
```

## Workbench Surface Law

Workbench owns proof-heavy detail:

```text
cycle_id
selected_symbols_count
symbols_attempted
symbols_active
symbols_degraded
symbols_unavailable
rolling_window_seconds
copyticks_calls
copyticks_total_returned
update_duration_ms
publish_duration_ms
budget_status
reset_count
reset_reasons
l4_quote_reference_status
```

## Performance Law

```text
selected_scope_only=true
max_selected_symbols_bounded=true
max_ticks_per_symbol_bounded=true
no_per_tick_file_writes=true
no_per_tick_flush=true
no_per_tick_log_spam=true
no_unbounded_arrays=true
summary_write_once_per_cycle=true
result_latest_append_once_per_cycle=true
```

## Forbidden Wording

```text
institutional order flow
confirmed buying pressure
confirmed selling pressure
smart money confirmed
aggression confirmed
high probability buy
high probability sell
entry signal
trade allowed
prop-firm safe
L20 current bid
L20 current ask
L20 live spread authority
```

## Acceptance Checks

```text
L20 consumes selected scope only
L20 references L4 as current quote/spread/freshness owner
L20 never claims current bid/ask/live spread ownership
L20 never scans the broker universe for ticks
L20 does not wait 10 minutes per symbol
L20 bootstraps once then appends/prunes rolling buffers
L20 bounds tick arrays and writes once per cycle
L20 exposes stale/partial/no-tick states
L20 does not call DOM APIs
L20 does not calculate L22 liquidity/order-flow synthesis
L20 does not grant permission, alert, signal, or execution
```

## Merge Gate

```text
merge_to_main=false_until_L19_confirmed_running_on_main
final_merge_owner=overseer
proof_level=DESIGN_ONLY_until_compile_and_runtime_evidence
```
