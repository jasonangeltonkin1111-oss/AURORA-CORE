# 39 L20 CODEX FINISH README

## Branch

```text
branch=worker/layer-20-selected-rolling-tick-pack
base_main_at_rebuild=4c86ad8a0a43c9b6809b6cbdec4b94ca455d1c2c
mode=DESIGN_ONLY_HOLD_MAIN
layer=L20_SELECTED_ROLLING_TICK_PACK
```

This branch was reset/rebuilt on current `main` after the older PR branch became stale. Do not recover stale code from the old branch unless you compare it against current source truth first.

A backup of the old pre-rebuild branch exists:

```text
backup/layer-20-before-main-rebuild-20260527
```

## Current Landed Files On This Branch

As of this README, only these L20 files are confirmed landed on the rebuilt branch:

```text
docs/37_L20_SELECTED_ROLLING_TICK_PACK_CONTROL.md
docs/38_L20_IMPLEMENTATION_DESIGN_AND_ACCEPTANCE_PLAN.md
mt5/runtime_owners/runtime_5_selected_evidence_owner/layer_20_selected_rolling_tick_pack/AC_SelectedRollingTickPack.mqh
docs/39_L20_CODEX_FINISH_README.md
```

Do not assume other L20 files exist until Git proves them.

## Current Proof Level

```text
DESIGN_ONLY=true
SOURCE_SCAFFOLD_PRESENT=true
SOURCE_WIRED_IN_AURORACORE=false
STATIC_SNIFF=partial
METAEDITOR_COMPILE_PROVEN=false
RUNTIME_PROVEN=false
MAIN_MERGE_ALLOWED=false
```

Do not claim compile, runtime, live, prop-firm, execution, signal, or edge proof.

## Absolute Ownership Law

L20 must preserve the single source owner map:

```text
current_bid_owner=L4_market_watch_quote_truth
current_ask_owner=L4_market_watch_quote_truth
current_last_owner=L4_market_watch_quote_truth
current_live_spread_owner=L4_market_watch_quote_truth
current_quote_freshness_owner=L4_market_watch_quote_truth
selected_tick_window_metric_owner=L20_selected_rolling_tick_pack
```

L20 may store `MqlTick` bid/ask/last values only as historical tick-row observations inside a selected rolling window. It must not publish or imply current quote truth.

Correct wording:

```text
observed_bid
observed_ask
observed_last
observed_spread_points
historical_tick_row_observation
selected_tick_window_metric
current_quote_owner=L4
```

Forbidden wording:

```text
L20 current bid
L20 current ask
L20 live spread authority
institutional order flow
confirmed buying pressure
confirmed selling pressure
CVD
footprint
entry signal
trade allowed
execution ready
prop-firm safe
```

## Current L20 Role

L20 is:

```text
selected-symbol live tick/spread behavior proxy
execution-risk proxy
feed-quality proxy
```

But the word `execution-risk` here means inspection context only. It does not mean execution permission, order placement, fill simulation, slippage proof, or trade readiness.

## Realistic Fields To Support

Use these names/ideas, while preserving L4 quote ownership:

```text
tick_pack_status
last_tick_time_server
quote_age_seconds
l4_bid_reference
l4_ask_reference
l4_spread_points_reference
spread_observed_avg_window
spread_observed_max_window
spread_spike_flag
tick_count_window
tick_activity_state
feed_gap_flag
broker_feed_dependency_flag
mt5_proxy_caveat
rollover_danger_flag
spread_instability_flag
quote_freshness_state
feed_stability_state
liquidity_degradation_proxy
```

Do not add fake CVD, fake footprint logic, or institutional-flow claims.

## What Codex Must Finish Next

### Step 1 — Re-check Git Truth

Before patching:

```text
git status
git branch --show-current
git log --oneline -5
git diff --name-status main...HEAD
```

Confirm branch is:

```text
worker/layer-20-selected-rolling-tick-pack
```

Confirm only branch is patched. Do not patch `main` directly.

### Step 2 — Read Mandatory Context

Read current source truth, not memory:

```text
README.md
control/02_MASTER_REPO_FILE_INDEX.md
control/00_CONTROL_INDEX.md
control/01_CONTROL_GOVERNANCE.md
mt5/00_MT5_SOURCE_INDEX.md
mt5/runtime_owners/00_RUNTIME_OWNERS_SOURCE_INDEX.md
blueprint/03_LOGICAL_LAYER_BLUEPRINT.md
docs/37_L20_SELECTED_ROLLING_TICK_PACK_CONTROL.md
docs/38_L20_IMPLEMENTATION_DESIGN_AND_ACCEPTANCE_PLAN.md
mt5/runtime_owners/runtime_1_foundation_truth_owner/layer_4_market_watch_truth/AC_L4_Scan.mqh
mt5/runtime_owners/runtime_5_selected_evidence_owner/layer_20_selected_rolling_tick_pack/AC_SelectedRollingTickPack.mqh
```

### Step 3 — Add Missing L20 Source Files

The interrupted prior pass did not land these files on the rebuilt branch. Add them only if still absent:

```text
mt5/runtime_owners/runtime_5_selected_evidence_owner/layer_20_selected_rolling_tick_pack/AC_SelectedRollingTickPackPublication.mqh
mt5/runtime_owners/runtime_5_selected_evidence_owner/layer_20_selected_rolling_tick_pack/AC_SelectedRollingTickPackHarness.mqh
mt5/runtime_owners/runtime_5_selected_evidence_owner/layer_20_selected_rolling_tick_pack/00_L20_SELECTED_ROLLING_TICK_PACK_SOURCE_INDEX.md
```

Publication scaffold rules:

```text
- May build L20 paths/text/CSV/manifest only.
- Must delegate physical writes to existing FileIO owner.
- Must not create FileIO owner.
- Must not create route owner.
- Must not publish current bid/ask/live spread as L20 authority.
```

Harness scaffold rules:

```text
- Must default disabled.
- Must not be called from OnTimer.
- Must not call CopyTicksRange in compile-touch mode.
- May expose compile-touch helper and disabled status text.
```

Suggested macro:

```text
AC_L20_RUNTIME_ACTIVATION_ENABLED=false
```

### Step 4 — Update Indexes Only After Files Exist

After the missing files are added, update:

```text
mt5/00_MT5_SOURCE_INDEX.md
mt5/runtime_owners/00_RUNTIME_OWNERS_SOURCE_INDEX.md
```

Index text must say:

```text
L20 is source-present only.
L20 is not included by AuroraCore.mq5.
L20 is not compile-proven.
L20 is not runtime-proven.
L4 remains current quote owner.
L20 owns selected rolling tick-window metrics only.
```

### Step 5 — Optional Premerge Wiring Plan

Add only if useful:

```text
docs/40_L20_PREMERGE_RUNTIME_WIRING_PLAN.md
```

It should describe, not activate:

```text
selected-scope reader plan
L4 quote-reference reader plan
disabled harness include plan
MetaEditor compile checklist
runtime proof checklist
Board/Dossier/Workbench acceptance
rollback path
```

### Step 6 — Do Not Wire Runtime Yet

Do not modify `mt5/AuroraCore.mq5` unless Jason/overseer explicitly asks for compile-only include work.

Do not add OnTimer calls.
Do not activate CopyTicksRange in normal runtime.
Do not merge to main.

## Surface Design To Preserve

### Board

Compact only:

```text
L20 Tick Window: selected=10 active=9 degraded=1 spikes=4 gappy=1 missing=0
SYMBOL | TickRows10m | SprObsAvg | SprObsMax | Spike | GapMax | Status
```

### Dossier

Per-symbol evidence only:

```text
L20 SELECTED ROLLING TICK WINDOW PACK
Status / Reason
Source: MT5 historical tick rows; current quote owner=L4
L4 Reference
tick rows 1m/5m/10m
observed spread min/avg/max/stddev/spikes
gap avg/max
observed quote-row changes
observed mid proxy
sample quality / confidence / flags
Boundary: review-only; no signal or permission
```

### Workbench

Proof-heavy:

```text
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

## Required Bug Hunt Before Final Handoff

Check for:

```text
L20 claiming current bid/ask/spread ownership
all-symbol CopyTicks/CopyTicksRange risk
unbounded tick arrays
per-tick file writes
per-tick flush
per-tick log spam
fake CVD/footprint/order-flow language
permission/signal/execution wording
renderer calculating instead of rendering
private duplicate caches
FileIO/route/scheduler duplicate owner
```

## Final Handoff Format

End the Codex run with:

```text
Decision: DESIGN READY / NEEDS FIX / KILL
Branch head SHA:
Files changed:
Proof level:
Compile proof: yes/no
Runtime proof: yes/no
Dependency gate: L20 cannot merge until L19 is confirmed running on main
Rollback path:
```

Expected current decision if source stays design-only and clean:

```text
DESIGN READY / HOLD MAIN / TEST FIRST
```
