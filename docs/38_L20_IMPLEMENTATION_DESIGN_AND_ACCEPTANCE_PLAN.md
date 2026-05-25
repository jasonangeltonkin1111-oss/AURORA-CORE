# 38 L20 IMPLEMENTATION DESIGN AND ACCEPTANCE PLAN

## Purpose

This document converts the L20 control contract into an implementation plan without activating runtime code prematurely.

Layer 20 is selected-symbol rolling MT5 tick/spread proxy evidence. It is not institutional order flow, buy/sell pressure, setup confirmation, trade permission, execution, or prop-firm readiness.

## Current Decision

```text
implementation_mode=planning_first
runtime_activation=blocked_until_L1_to_L19_stable_and_owner_route_confirmed
merge_to_main=false_until_layers_1_to_19_stable
final_merge_owner=overseer
```

## Source Truth Anchors

```text
primary_control=docs/37_L20_SELECTED_ROLLING_TICK_PACK_CONTROL.md
logical_blueprint=blueprint/03_LOGICAL_LAYER_BLUEPRINT.md
upstream_scope=L17/L18/L19 selected evidence scope
current_chain_status=L18_dispatch_invokes_L19; L20_not_active_yet
```

## Owner Placement Decision

L20 tick capture must be owned by MT5-side selected evidence source when implemented. Python must not become a broker tick owner.

Candidate MT5 source placement, pending overseer approval:

```text
mt5/runtime_owners/runtime_5_selected_evidence_owner/layer_20_selected_rolling_tick_pack/AC_SelectedRollingTickPack.mqh
```

If current repo owner naming changes before implementation, obey the active runtime owner/source index instead of this candidate path.

Python may later have a dispatch/decorator only after MT5-produced L20 packets exist:

```text
external_worker/aurora_worker_l20_dispatch.py
```

That Python file may read L20 output packets and append `l20_*` fields to result surfaces. It must not call broker APIs, poll MT5, or invent ticks.

## Implementation Phases

### Phase 0 — Contract Complete

```text
status=source_contract_complete
files=docs/37_L20_SELECTED_ROLLING_TICK_PACK_CONTROL.md; docs/38_L20_IMPLEMENTATION_DESIGN_AND_ACCEPTANCE_PLAN.md
runtime_code_added=false
```

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

### Phase 2 — MT5 Rolling Buffer Scaffold

Goal: create in-memory rolling buffers for selected symbols only.

Per-symbol buffer state:

```text
symbol
point
digits
status
last_tick_msc
oldest_tick_msc
newest_tick_msc
rolling_window_seconds=600
buffer_count
reset_count
reset_reasons
retired_grace_until
```

Per-tick fields:

```text
time_msc
bid
ask
last
volume
volume_real
flags
spread_points
```

Acceptance:

```text
normal_publish_resets_buffer=false
normal_refresh_cold_rebuild=false
append_new_ticks_only=true
prune_older_than_rolling_window=true
```

### Phase 3 — Tick Acquisition

Goal: bootstrap and update selected symbols using MT5 tick APIs within strict budget.

Startup bootstrap:

```text
CopyTicksRange(symbol, from=now_msc-600000, to=now_msc)
status=BOOTSTRAPPING until enough sample exists
```

Runtime update:

```text
CopyTicksRange(symbol, from=last_tick_msc+1, to=now_msc)
append returned ticks
prune old ticks
recompute summary
```

Fallback option only if range call is unsuitable after proof:

```text
CopyTicks(symbol, COPY_TICKS_ALL, from_msc, max_ticks)
```

Acceptance:

```text
copyticks_call_count bounded
copyticksrange_call_count bounded
max_ticks_per_symbol bounded
copyticks_error recorded
sync_delay_or_timeout degrades status, not hidden
```

### Phase 4 — Metrics

Required metrics:

```text
tick_count_1m
tick_count_5m
tick_count_10m
spread_min_points_10m
spread_max_points_10m
spread_avg_points_10m
spread_stddev_points_10m
spread_spike_count_10m
tick_gap_avg_seconds
tick_gap_max_seconds
bid_change_count_10m
ask_change_count_10m
last_change_count_10m
volume_change_count_10m
bid_up_count_10m
bid_down_count_10m
ask_up_count_10m
ask_down_count_10m
mid_change_count_10m
mid_range_points_10m
latest_tick_age_seconds
sample_quality
proxy_confidence
```

Metric laws:

```text
change_count_source=flags_preferred
value_delta_fallback_must_be_labelled=true
invalid_bid_ask_degrades_symbol=true
ask_less_than_bid_degrades_symbol=true
point_invalid_degrades_symbol=true
```

### Phase 5 — Output Files

Runtime outputs only, not repo artifacts:

```text
Workbench/Gateway/Outbox/Layers/Layer_20_Selected_Rolling_Tick_Pack/l20_selected_rolling_tick_pack.csv
Workbench/Gateway/Outbox/Layers/Layer_20_Selected_Rolling_Tick_Pack/l20_selected_rolling_tick_summary.txt
Workbench/Gateway/Outbox/Layers/Layer_20_Selected_Rolling_Tick_Pack/l20_selected_rolling_tick.manifest
Workbench/Gateway/Outbox/Layers/Layer_20_Selected_Rolling_Tick_Pack/l20_selected_rolling_tick_errors.csv
Workbench/Gateway/Outbox/Layers/Layer_20_Selected_Rolling_Tick_Pack/l20_selected_rolling_tick_perf.txt
Selection Desk/Global/current_selected_rolling_tick_pack.csv
Selection Desk/Global/Selected Rolling Tick Pack.txt
```

All writes must go through the existing FileIO owner. Do not create duplicate FileIO or route owners.

### Phase 6 — Render Surfaces

Board:

```text
compact aggregate only
no raw tick dump
no signal wording
```

Dossier:

```text
per-symbol L20 selected rolling tick section
small bounded latest-tick sample only if needed
truth labels visible
```

Workbench:

```text
full proof counters
copyticks calls/errors
budget status
reset reasons
selected scope source
```

Renderers must not calculate L20 metrics or call tick APIs. They render published L20 packets only.

## Cadence

```text
internal_tick_update_seconds=10
board_publish_seconds=60
dossier_publish_seconds=60
workbench_proof_seconds=60_or_on_state_change
archive_snapshot_seconds=300
```

If timer budget pressure exists, L20 must degrade and skip lower-priority publication before risking OnTimer starvation.

## Acceptance Test Matrix

| Test ID | Test | Expected |
|---|---|---|
| L20-T01 | No selected scope | status=missing_scope; no all-symbol scan |
| L20-T02 | New selected symbol | status=BOOTSTRAPPING; only new symbol bootstraps |
| L20-T03 | Same selected set reprinted | buffers continue; reset_count unchanged |
| L20-T04 | Symbol leaves selected set | status=RETIRED_GRACE; buffer retained 15 minutes |
| L20-T05 | Symbol re-enters within grace | buffer restored; no cold rebuild unless stale/corrupt |
| L20-T06 | Zero ticks returned | status=UNAVAILABLE_NO_TICKS or no_ticks_returned |
| L20-T07 | Latest tick too old | status=DEGRADED_STALE_TICKS |
| L20-T08 | Huge tick gap | status=DEGRADED_GAPPY_FEED |
| L20-T09 | Spread unstable | status=DEGRADED_SPREAD_UNSTABLE; spike count visible |
| L20-T10 | Invalid bid/ask | symbol degraded; invalid source visible |
| L20-T11 | Flags missing/unclear | flags_decode_status degraded |
| L20-T12 | Timer budget exceeded | partial_budget_limited; truth still prints |
| L20-T13 | Renderer sees missing output | renderer says not_wired/missing_output, not accepted |
| L20-T14 | Result_latest append | only after real L20 output exists |
| L20-T15 | Forbidden wording grep | no institutional/order-flow/signal/permission wording |

## Static Review Checklist

```text
no duplicate Runtime Owner
no duplicate FileIO owner
no duplicate route owner
no duplicate scheduler/timer owner
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
copyticks_calls_bounded
buffer_reset_rules_observed
Board_compact_summary_visible
Dossier_L20_section_visible
Workbench_L20_proof_visible
result_latest_l20_fields_visible_if_dispatch_added
trade_permission=false
entry_signal=false
execution=false
institutional_order_flow_claim=false
```

## Rollback Plan

If the implementation later harms runtime stability, rollback in this order:

```text
1. disable L20 runtime activation flag
2. stop L20 scheduler/update call
3. keep renderer showing not_wired/missing_output
4. remove L20 source include if compile risk exists
5. keep docs as design context unless overseer withdraws the layer
```

## Decision

```text
TEST_FIRST
```

L20 is valid only as bounded selected rolling MT5 tick proxy evidence. It should proceed after L1-L19 are stable enough for selected scope truth to be trusted.
