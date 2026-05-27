# 00 L20 SELECTED ROLLING TICK PACK SOURCE INDEX

## Purpose

Source index for Layer 20 selected-symbol rolling tick-window proxy metrics.

L20 is selected evidence only. It is not the source owner for current bid, current ask, current last, live spread, quote freshness, institutional order flow, buy/sell pressure, setup confirmation, trade permission, execution, DOM, ATR, VWAP, or indicator ownership.

## Current Status

```text
source_present=true
runtime_included_in_AuroraCore=false
runtime_activated=false
compile_proven=false
runtime_proven=false
merge_to_main_allowed=false_until_L19_confirmed_running_on_main_and_overseer_approved
```

## Source Owner Split

```text
current_bid_owner=L4_market_watch_quote_truth
current_ask_owner=L4_market_watch_quote_truth
current_last_owner=L4_market_watch_quote_truth
current_live_spread_owner=L4_market_watch_quote_truth
current_quote_freshness_owner=L4_market_watch_quote_truth
selected_tick_window_metric_owner=L20_selected_rolling_tick_pack
```

L20 may store historical `MqlTick` row observations internally to calculate selected rolling-window metrics. Those observed tick-row values are not current quote authority and must not override L4 packets.

## Source Files

| File | Status | Role |
|---|---|---|
| `AC_SelectedRollingTickPack.mqh` | Source-present scaffold | Selected rolling tick-row buffer, CopyTicksRange update helper, derived metrics, compact Board row, Dossier section. Not included by `mt5/AuroraCore.mq5`. |
| `AC_SelectedRollingTickPackPublication.mqh` | Source-present scaffold | L20 output text/CSV/manifest builders and FileIO-delegating publication helper. Not included by `mt5/AuroraCore.mq5`. |
| `AC_SelectedRollingTickPackHarness.mqh` | Disabled harness scaffold | Compile-touch/status helpers and disabled activation macro. Does not call `OnTimer` or runtime tick capture. |

## Owns

```text
selected-symbol rolling MT5 tick-row proxy metrics
tick row counts 1m/5m/10m
observed spread min/avg/max/stddev/spikes
tick gaps
observed bid/ask/last/volume change counts
observed mid proxy range/change counts
sample quality
proxy confidence
L20 output text/CSV/manifest shape
compile-touch harness status shape
```

## Must Not Own

```text
current bid
current ask
current last
current live spread
current quote freshness
SymbolInfoTick live quote surface truth
raw OHLC
candle geometry
ATR
VWAP
indicators
DOM
liquidity map
risk geometry
setup confirmation
entry signal
trade permission
execution
institutional order-flow claim
full-universe tick harvest
FileIO owner
route owner
scheduler/timer owner
```

## Activation Gate

Do not include these files in `mt5/AuroraCore.mq5` until:

```text
L19 is confirmed running on main
selected-scope source path is confirmed
L4 quote-reference path is confirmed
route/output contract is confirmed
MetaEditor compile plan is ready
runtime budget plan is ready
Overseer approves active wiring
```

## Required Proof Before Promotion

```text
MetaEditor compile passed
MT5 runtime output written
selected_scope_source visible
l4_quote_reference_status visible
copyticksrange calls bounded
no all-symbol scan
no normal-refresh cold rebuild
Board compact summary visible
Dossier L20 section visible
Workbench proof visible
current_quote_owner=L4
trade_permission=false
entry_signal=false
execution=false
institutional_order_flow_claim=false
```

## Decision

```text
TEST_FIRST
```
