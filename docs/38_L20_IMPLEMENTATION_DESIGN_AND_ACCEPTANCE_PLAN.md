# 38 L20 IMPLEMENTATION DESIGN AND ACCEPTANCE PLAN

## Purpose

This document converts the L20 control contract into an implementation plan without activating runtime code prematurely.

Layer 20 is selected-symbol rolling MT5 tick-window/spread-observation proxy evidence. It is not the source owner for current bid, ask, last, live spread, quote freshness, institutional order flow, buy/sell pressure, setup confirmation, trade permission, execution, or prop-firm readiness.

## Current Decision

```text
implementation_mode=planning_first
runtime_activation=blocked_until_L19_confirmed_running_on_main
merge_to_main=false_until_L19_confirmed_running_on_main
final_merge_owner=overseer
```

## Source Truth Anchors

```text
primary_control=docs/37_L20_SELECTED_ROLLING_TICK_PACK_CONTROL.md
logical_blueprint=blueprint/03_LOGICAL_LAYER_BLUEPRINT.md
upstream_scope=L17/L18/L19 selected evidence scope
current_quote_truth=L4_market_watch_quote_truth
```

## Source Owner Split

```text
L4 owns current bid/ask/last/live spread/quote freshness.
L20 owns selected rolling tick-window derived metrics.
```

L20 may store bid/ask/last values from historical `MqlTick` rows only as internal tick-row observations needed to calculate rolling-window metrics. L20 must not publish those values as current quote truth and must not override L4 quote packets.

## Owner Placement

Candidate MT5 source placement:

```text
mt5/runtime_owners/runtime_5_selected_evidence_owner/layer_20_selected_rolling_tick_pack/
```

Python may later read L20 output packets and decorate downstream result surfaces, but it must not call broker APIs, poll MT5, invent ticks, or become current quote authority.

## Implementation Phases

### Phase 1 — Selected Scope Readback

Goal: identify selected symbols without expanding scope.

Allowed selected inputs:

```text
L17 deep evidence selected output
L18 selected raw OHLC selected-dossier scope
L19 selected candle geometry selected-dossier scope
Selection Desk degraded fallback only when upstream selected files are missing/degraded
```

Acceptance:

```text
selected_symbols_count > 0 or status=missing_scope
selected_scope_source visible
fallback_scope_degraded=true when fallback used
all_symbol_scan=false
```

### Phase 2 — L4 Quote Reference Readback

Goal: reference current quote truth without owning it.

Allowed source:

```text
L4 Market Watch / quote truth packet
```

Acceptance:

```text
l4_quote_reference_status visible
current_bid_owner=L4
current_ask_owner=L4
current_live_spread_owner=L4
L20_current_quote_owner=false
```

L20 may compare its latest tick-row timestamp or observed spread context against L4 freshness/spread state, but L4 remains the source owner.

### Phase 3 — Rolling Buffer Scaffold

Goal: create in-memory rolling buffers for selected symbols only.

Per-symbol buffer state:

```text
symbol
status
last_tick_msc
oldest_tick_msc
newest_tick_msc
rolling_window_seconds=600
buffer_count
reset_count
reset_reasons
retired_grace_until
l4_quote_reference_status
```

Per-tick-row observation fields:

```text
time_msc
observed_bid
observed_ask
observed_last
observed_volume
observed_volume_real
flags
observed_spread_points
```

### Phase 4 — Tick Acquisition

Startup bootstrap:

```text
CopyTicksRange(symbol, from=now_msc-600000, to=now_msc)
status=BOOTSTRAPPING until enough sample exists
```

Runtime update:

```text
CopyTicksRange(symbol, from=last_tick_msc+1, to=now_msc)
append returned tick rows
prune old tick rows
recompute summary metrics
```

Acceptance:

```text
copyticksrange_call_count bounded
max_ticks_per_symbol bounded
copyticks_error recorded
sync_delay_or_timeout degrades status, not hidden
```

### Phase 5 — Metrics

Required metrics:

```text
tick_row_count_1m/5m/10m
spread_observed_min/max/avg/stddev_points_10m
spread_observed_spike_count_10m
tick_gap_avg/max_seconds
observed_bid/ask/last/volume_change_count_10m
observed_bid/ask_up_down_count_10m
observed_mid_change_count_10m
observed_mid_range_points_10m
latest_tick_row_age_seconds
sample_quality
proxy_confidence
l4_quote_reference_status
```

Metric laws:

```text
change_count_source=flags_preferred
value_delta_fallback_must_be_labelled=true
invalid_observed_bid_ask_degrades_symbol=true
point_invalid_degrades_symbol=true
L20_observed_bid_ask_not_current_quote_truth=true
```

### Phase 6 — Output Files

Runtime outputs only, not repo artifacts:

```text
Workbench/Gateway/Outbox/Layers/Layer_20_Selected_Rolling_Tick_Pack/l20_selected_rolling_tick_pack.csv
Workbench/Gateway/Outbox/Layers/Layer_20_Selected_Rolling_Tick_Pack/l20_selected_rolling_tick_summary.txt
Workbench/Gateway/Outbox/Layers/Layer_20_Selected_Rolling_Tick_Pack/l20_selected_rolling_tick.manifest
Selection Desk/Global/current_selected_rolling_tick_pack.csv
Selection Desk/Global/Selected Rolling Tick Pack.txt
```

All writes must go through the existing FileIO owner. Do not create duplicate FileIO or route owners.

### Phase 7 — Render Surfaces

Board:

```text
compact aggregate only
no raw tick dump
no signal wording
no current quote authority wording
```

Dossier:

```text
per-symbol L20 selected rolling tick-window section
small bounded latest tick-row sample only if needed and labelled observed
truth labels visible: current_quote_owner=L4
```

Workbench:

```text
full proof counters
copyticks calls/errors
budget status
reset reasons
selected scope source
l4 quote reference status
```

Renderers must not calculate L20 metrics, call tick APIs, or treat L20 observed tick rows as current quote truth. They render published L20 packets only.

## Acceptance Test Matrix

| Test ID | Test | Expected |
|---|---|---|
| L20-T01 | No selected scope | status=missing_scope; no all-symbol scan |
| L20-T02 | New selected symbol | status=BOOTSTRAPPING; only new symbol bootstraps |
| L20-T03 | Same selected set reprinted | buffers continue; reset_count unchanged |
| L20-T04 | Symbol leaves selected set | status=RETIRED_GRACE; buffer retained 15 minutes |
| L20-T05 | Zero ticks returned | status=UNAVAILABLE_NO_TICKS or no_ticks_returned |
| L20-T06 | Latest tick row too old | status=DEGRADED_STALE_TICKS |
| L20-T07 | Huge tick gap | status=DEGRADED_GAPPY_FEED |
| L20-T08 | Observed spread unstable | status=DEGRADED_SPREAD_UNSTABLE; spike count visible |
| L20-T09 | Invalid observed bid/ask row | symbol degraded; invalid observation visible |
| L20-T10 | Flags missing/unclear | flags_decode_status degraded |
| L20-T11 | Renderer sees missing output | renderer says not_wired/missing_output, not accepted |
| L20-T12 | L4 reference absent/stale | l4_quote_reference_status degrades; L20 does not replace L4 |

## Static Review Checklist

```text
no duplicate Runtime Owner
no duplicate FileIO owner
no duplicate route owner
no duplicate scheduler/timer owner
no duplicate current quote owner
no full-universe CopyTicks/CopyTicksRange
no OnTick perfect-capture assumption
no per-tick file writes
no per-tick flush
no per-tick logging spam
no unbounded arrays
no Python broker polling
no DOM calls
no L22 synthesis
no ATR/VWAP/indicator ownership
no permission/signal language
```

## Runtime Proof Required Before Status Upgrade

```text
MetaEditor_compile_passed
MT5_runtime_output_seen
L20_output_files_written
selected_scope_source_visible
l4_quote_reference_status_visible
copyticks_calls_bounded
buffer_reset_rules_observed
Board_compact_summary_visible
Dossier_L20_section_visible
Workbench_L20_proof_visible
trade_permission=false
entry_signal=false
execution=false
institutional_order_flow_claim=false
current_quote_owner=L4
```

## Decision

```text
TEST_FIRST
```

L20 is valid only as bounded selected rolling MT5 tick-window proxy evidence. It should proceed after L19 is confirmed running on main and after L4 quote ownership remains preserved.
