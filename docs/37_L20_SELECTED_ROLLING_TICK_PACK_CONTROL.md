# 37 L20 SELECTED ROLLING TICK PACK CONTROL

## Purpose

Layer 20 owns selected-symbol rolling tick and spread proxy truth.

It is a selected evidence layer. It is not institutional order flow, buy/sell aggression proof, setup confirmation, trade permission, execution, or prop-firm readiness.

## Proof Status

```text
source_contract=true
design_control=true
runtime_implemented=false unless active MT5/source files prove tick capture and publication are wired
runtime_proven=false unless current MT5 runtime output proves selected tick packets are published
trade_permission=false
entry_signal=false
execution=false
```

## Question Answered

```text
For the selected L17/L18/L19 evidence scope, what does the last rolling tick/spread window show as broker tick proxy truth?
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
```

L20 must not become L22. L22 may later synthesize tick-flow proxy context, DOM proxy context, liquidity map context, and risk geometry. L20 only prepares bounded rolling tick/spread facts.

## Source Inputs

Primary scope source:

```text
L17 deep evidence selected output
L18 selected raw OHLC selected-dossier scope
L19 selected candle geometry selected-dossier scope
```

If L17-L19 are not fully wired or output is degraded, L20 may use the current canonical selected inspection scope only as a degraded fallback:

```text
Selection Desk/Global/current_deep_evidence_split.csv
Selection Desk/Global/current_top10.csv
canonical selected copied dossiers under the Selection Desk route
```

Fallback scope must be labelled as degraded. Fallback scope must not expand into all symbols.

## MT5 Data Boundary

L20 tick capture depends on MT5 tick data access through the MT5 runtime, not Python broker polling.

Allowed MT5 API family when implemented by the proper MT5 owner path:

```text
CopyTicks
CopyTicksRange
MqlTick.time
MqlTick.time_msc
MqlTick.bid
MqlTick.ask
MqlTick.last
MqlTick.volume
MqlTick.volume_real
MqlTick.flags
```

Python worker code must not pretend to collect broker ticks directly. If Python participates later, it may only process files produced by the MT5 tick-capture owner or decorate selected dossiers from already exported tick-pack files.

## Owned Fields

```text
tick_time
bid
ask
last
tick_volume
tick_flags
spread
tick_count_1m
tick_count_5m
tick_count_10m
spread_min_10m
spread_max_10m
spread_avg_10m
spread_stddev_10m
tick_gap_max_seconds
tick_gap_avg_seconds
bid_change_count_10m
ask_change_count_10m
last_change_count_10m
spread_spike_count_10m
tick_pack_status
tick_capture_confidence
tick_proxy_boundary_text
```

## Must Not Own

```text
raw_ohlc_source
candle_geometry
indicators
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

## Rolling Window Contract

Default design:

```text
rolling_window_seconds=600
selected_capture_parallel=true
max_selected_symbols_from_L17_budget=true
capture_cycle_status=visible
partial_capture_allowed=true
```

L20 must not wait ten minutes per symbol. The rolling window is accumulated/captured across selected symbols in parallel and then summarized. Missing or insufficient ticks produce degraded truth, not fake freshness.

## Freshness and Failure States

Required status vocabulary:

```text
accepted
degraded
partial
missing_scope
no_ticks_returned
stale_tick_window
insufficient_tick_window
copyticks_failed
write_degraded
write_failed
not_wired
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
partial_reason
not_wired_reason
```

## Output Contract

Future source may publish L20 outputs only under a clear L20 owner route such as:

```text
Workbench/Gateway/Outbox/Layers/Layer_20_Selected_Rolling_Tick_Pack/l20_selected_rolling_tick_pack.csv
Workbench/Gateway/Outbox/Layers/Layer_20_Selected_Rolling_Tick_Pack/l20_selected_rolling_tick_summary.txt
Workbench/Gateway/Outbox/Layers/Layer_20_Selected_Rolling_Tick_Pack/l20_selected_rolling_tick.manifest
Selection Desk/Global/current_selected_rolling_tick_pack.csv
Selection Desk/Global/Selected Rolling Tick Pack.txt
```

Do not add these runtime files as static repo artifacts. They are runtime outputs, not source.

## Renderer Law

Renderers may display L20 outputs only. Renderers must not calculate tick metrics, call CopyTicks, reconstruct tick windows, infer order flow, create entry signals, or hide partial/stale states.

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
```

Allowed wording:

```text
mt5_tick_proxy_truth
rolling_tick_spread_proxy
broker_tick_window
selected_symbol_tick_context
degraded_tick_capture
inspection_only
manual_review_context_later
validation_required_for_permission
```

## Acceptance Checks

```text
L20 consumes selected scope only
L20 never scans the broker universe for ticks
L20 does not wait 10 minutes per symbol
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
TEST FIRST
```

No runtime worker is added by this control document. The next implementation step must first prove the MT5 tick-capture owner route and selected-scope contract, then add the smallest source patch that publishes degraded truth safely.
