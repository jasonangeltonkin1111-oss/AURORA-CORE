# 37 L20 SELECTED ROLLING TICK PACK CONTROL

## Purpose

Layer 20 owns selected-symbol rolling tick-window proxy metrics derived from MT5 tick history for already-selected symbols.

It is a selected evidence layer. It is not the source owner for current bid, ask, last, live spread, quote freshness, SymbolInfoTick surface truth, institutional order flow, buy/sell aggression proof, setup confirmation, trade permission, execution, or prop-firm readiness.

## Proof Status

```text
source_contract=true
design_control=true
runtime_implemented=false unless active MT5/source files prove selected tick-window capture and publication are wired
runtime_proven=false unless current MT5 runtime output proves selected tick-window packets are published
trade_permission=false
entry_signal=false
execution=false
merge_to_main_allowed=false_until_layers_1_to_19_stable_and_overseer_approved
```

## Source Owner Law

There must be one live quote source owner.

```text
current_bid_owner=L4_market_watch_quote_truth
current_ask_owner=L4_market_watch_quote_truth
current_last_owner=L4_market_watch_quote_truth
current_live_spread_owner=L4_market_watch_quote_truth
current_quote_freshness_owner=L4_market_watch_quote_truth
selected_tick_window_metric_owner=L20_selected_rolling_tick_pack
```

L4 owns live bid/ask/last/spread/freshness through the current Market Watch / SymbolInfoTick packet. L20 may read MT5 tick rows only to build selected-symbol rolling-window observations and derived metrics. L20 must not republish itself as the current quote authority and must not override L4 quote truth.

## Question Answered

```text
For the selected L17/L18/L19 evidence scope, what do the selected rolling MT5 tick-window observations show as broker tick/spread proxy context?
```

## Hard Boundary

L20 must remain selected-symbol only.

```text
all_symbol_tick_harvest=false
full_universe_CopyTicks=false
full_universe_CopyTicksRange=false
serial_10_minute_wait_per_symbol=false
institutional_order_flow_claim=false
buy_sell_aggression_claim=false
trade_permission=false
entry_signal=false
execution=false
current_quote_truth_owner=false
```

L20 must not become L4 or L22. L4 owns live Market Watch quote/spread truth. L22 may later synthesize tick-flow proxy context, DOM proxy context, liquidity map context, and risk geometry. L20 only prepares bounded selected rolling tick-window metrics.

## Source Inputs

Primary scope source:

```text
L17 deep evidence selected output
L18 selected raw OHLC selected-dossier scope
L19 selected candle geometry selected-dossier scope
```

Current live quote/freshness reference source:

```text
L4 Market Watch / quote truth packet
```

If L17-L19 are not fully wired or output is degraded, L20 may use the current canonical selected inspection scope only as a degraded fallback:

```text
Selection Desk/Global/current_deep_evidence_split.csv
Selection Desk/Global/current_top10.csv
canonical selected copied dossiers under the Selection Desk route
```

Fallback scope must be labelled as degraded. Fallback scope must not expand into all symbols.

## MT5 Data Boundary

L20 tick-window capture depends on MT5 tick-history access through the MT5 runtime, not Python broker polling.

Allowed MT5 API family when implemented by the proper MT5 owner path:

```text
CopyTicks
CopyTicksRange
MqlTick.time
MqlTick.time_msc
MqlTick.bid as historical tick-row observation only
MqlTick.ask as historical tick-row observation only
MqlTick.last as historical tick-row observation only
MqlTick.volume as historical tick-row observation only
MqlTick.volume_real as historical tick-row observation only
MqlTick.flags as historical tick-row observation only
SymbolInfoTick only for optional L4-aligned latest quote freshness cross-check; L4 remains the owner
```

Python worker code must not pretend to collect broker ticks directly. If Python participates later, it may only process files produced by the MT5 tick-capture owner or decorate selected dossiers from already exported tick-pack files.

## Owned Fields

L20 owns derived selected rolling tick-window metrics, not live quote truth:

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

L20 is stateful rolling evidence, not a cold refresh/recalculate layer.

```text
startup_bootstrap_allowed=true
normal_refresh_cold_rebuild=false
normal_publish_resets_buffer=false
rolling_buffer_owner=L20_selected_tick_window_metric_owner_only
rolling_window_seconds=600
selected_capture_parallel=true
max_selected_symbols_from_L17_budget=true
partial_capture_allowed=true
```

Allowed behavior:

```text
EA startup: bootstrap last 10 minutes of tick rows per selected symbol when selected scope exists
runtime update: append only tick rows newer than last_tick_msc
runtime maintenance: prune tick rows older than rolling_window_seconds
runtime summary: recompute metrics from the current rolling buffer
publication: print current rolling-window metric state without resetting the buffer
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

A spread spike is evidence. Do not reset it away.

## Selected-Set Change Law

Same selected set:

```text
keep_existing_buffers=true
reset_existing_buffers=false
```

New selected symbol:

```text
bootstrap_new_symbol_only=true
new_symbol_initial_status=BOOTSTRAPPING
```

Symbol leaves selected set:

```text
status=RETIRED_GRACE
retire_after_minutes=15
restore_if_reentered_during_grace=true
purge_after_grace=true
```

Allowed reset reasons:

```text
ea_restart
symbol_newly_enters_selected_set
server_or_account_changed
symbol_point_or_digits_invalid_or_materially_changed
buffer_corruption_detected
last_tick_msc_went_backwards
copyticks_returned_impossible_order_or_time
manual_operator_reset
```

## Cadence Contract

Default cadence:

```text
internal_tick_update_seconds=10
board_publish_seconds=60
dossier_publish_seconds=60
workbench_proof_seconds=60_or_on_state_change
archive_snapshot_seconds=300
```

L20 must respect the EA timer budget. If budget is exceeded, it must publish partial/degraded proof rather than stretching OnTimer into a silent cadence-drop risk.

## Freshness and Failure States

Required status vocabulary:

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

Required visible failure fields:

```text
selected_symbols_expected
selected_symbols_seen
selected_symbols_with_ticks
selected_symbols_missing_ticks
copyticks_call_count
copyticksrange_call_count
max_ticks_per_symbol
rolling_window_seconds
tick_window_oldest_time
tick_window_latest_time
tick_window_age_seconds
tick_gap_max_seconds
l4_quote_reference_status
partial_reason
not_wired_reason
reset_count
reset_reasons
budget_status
```

## Output Contract

Future source may publish L20 outputs only under a clear L20 owner route such as:

```text
Workbench/Gateway/Outbox/Layers/Layer_20_Selected_Rolling_Tick_Pack/l20_selected_rolling_tick_pack.csv
Workbench/Gateway/Outbox/Layers/Layer_20_Selected_Rolling_Tick_Pack/l20_selected_rolling_tick_summary.txt
Workbench/Gateway/Outbox/Layers/Layer_20_Selected_Rolling_Tick_Pack/l20_selected_rolling_tick.manifest
Workbench/Gateway/Outbox/Layers/Layer_20_Selected_Rolling_Tick_Pack/l20_selected_rolling_tick_errors.csv
Workbench/Gateway/Outbox/Layers/Layer_20_Selected_Rolling_Tick_Pack/l20_selected_rolling_tick_perf.txt
Selection Desk/Global/current_selected_rolling_tick_pack.csv
Selection Desk/Global/Selected Rolling Tick Pack.txt
```

Do not add these runtime files as static repo artifacts. They are runtime outputs, not source.

## Board Surface Law

Board is cockpit only. It may show compact aggregate truth:

```text
L20 Tick Window: selected=10 active=9 degraded=1 spikes=4 gappy=1 missing=0
```

Per selected row, Board may show only a compact line:

```text
SYMBOL | TickRows10m <count> | SprObsAvg <points> | SprObsMax <points> | Spike <count> | GapMax <seconds> | <status>
```

Board must not print raw tick dumps or present L20 bid/ask observations as current quote truth.

## Dossier Surface Law

Selected copied Dossiers may show a rich L20 section:

```text
L20 SELECTED ROLLING TICK WINDOW PACK
Status: ACTIVE_ROLLING
Window: 10m rolling
Source: MT5 historical tick rows; current quote truth remains L4
Tick Activity: 1m / 5m / 10m row counts
Observed Spread: min / avg / max / stddev / spikes
Gaps: avg / max
Observed Quote-Row Changes: bid / ask / last / volume
Truth Labels: current_quote_owner=L4; directional_validity=false; institutional_order_flow_claim=false; trade_permission=false
```

Dossier may show a very small latest-tick sample only if bounded and clearly labelled as tick-row observation, not current quote authority. It must not become a tick archive.

## Workbench Surface Law

Workbench owns proof-heavy display:

```text
cycle_id
selected_symbols_count
symbols_attempted
symbols_active
symbols_degraded
symbols_unavailable
update_cadence_seconds
publish_cadence_seconds
archive_cadence_seconds
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

Per-symbol proof:

```text
symbol
status
last_tick_msc
new_ticks_appended
ticks_pruned
buffer_count
oldest_tick_msc
newest_tick_msc
copyticks_error
l4_quote_reference_status
```

## Renderer Law

Renderers may display L20 outputs only. Renderers must not calculate tick metrics, call CopyTicks, reconstruct tick windows, infer order flow, create entry signals, override L4 quote truth, or hide partial/stale states.

If no L20 output exists, renderer text must say `not_wired` or `missing_output`, not `accepted`.

## Performance Law

L20 must be budgeted and bounded:

```text
selected_scope_only=true
max_selected_symbols_bounded=true
max_ticks_per_symbol_bounded=true
no_per_tick_file_writes=true
no_per_tick_flush=true
no_per_tick_log_spam=true
no_unbounded_tick_arrays=true
summary_write_once_per_cycle=true
result_latest_append_once_per_cycle=true
```

Tick flags matter. If flags are unavailable, ignored, or undecoded, the packet must label that degradation.

## Spread Spike Law

First implementation may use observed spread from selected tick rows:

```text
spread_observed_spike = spread_observed_points >= max(symbol_min_spike_points, rolling_spread_observed_avg_points * 2.5)
```

Severity guidance:

```text
minor = observed spread >= 2.0x rolling observed average
major = observed spread >= 2.5x rolling observed average
severe = observed spread >= 4.0x rolling observed average or broker-specific danger threshold
```

Later L20 may consume an L6 normal-friction baseline and L4 current spread reference, but L20 must not become L4 quote truth or L6 friction scoring.

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

Allowed wording:

```text
mt5_tick_window_proxy_truth
rolling_tick_spread_proxy
historical_tick_row_observation
selected_symbol_tick_context
degraded_tick_capture
inspection_only
manual_review_context_later
current_quote_owner_L4
validation_required_for_permission
```

## Acceptance Checks

```text
L20 consumes selected scope only
L20 references L4 as current quote/spread/freshness owner
L20 never claims current bid/ask/live spread ownership
L20 never scans the broker universe for ticks
L20 does not wait 10 minutes per symbol
L20 bootstraps once then appends/prunes rolling buffers
L20 does not cold-rebuild on normal Board/Dossier publish
L20 retains symbols in RETIRED_GRACE when they leave selected scope
L20 bounds tick arrays and writes once per cycle
L20 stores tick flags or visibly degrades if flags are missing/unread
L20 exposes stale/partial/no-tick states
L20 appends l20_* result_latest fields only after source wiring exists
L20 does not call DOM APIs
L20 does not calculate L22 liquidity/order-flow synthesis
L20 does not grant permission, alert, signal, or execution
```

## Current Implementation Decision

```text
TEST_FIRST
```

No active runtime worker is added by this control document. The next implementation step must first prove the MT5 tick-window metric owner route, selected-scope contract, and L4 quote reference contract, then add the smallest source patch that publishes degraded truth safely.

## Merge Gate

```text
merge_to_main=false_until_layers_1_to_19_stable
final_merge_owner=overseer
```
