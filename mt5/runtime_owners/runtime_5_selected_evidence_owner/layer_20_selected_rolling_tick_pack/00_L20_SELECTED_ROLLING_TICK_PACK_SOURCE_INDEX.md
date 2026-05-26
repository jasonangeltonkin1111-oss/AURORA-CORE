# 00 L20 SELECTED ROLLING TICK PACK SOURCE INDEX

## Purpose

Source index for Layer 20 selected-symbol rolling tick/spread proxy truth.

L20 is selected evidence only. It is not institutional order flow, buy/sell pressure, setup confirmation, trade permission, execution, DOM, ATR, VWAP, or indicator ownership.

## Current Status

```text
source_present=true
runtime_included_in_AuroraCore=false
runtime_activated=false
compile_proven=false
runtime_proven=false
merge_to_main_allowed=false_until_L1_to_L19_stable_and_overseer_approved
```

## Active Source Files

| File | Status | Role |
|---|---|---|
| `AC_SelectedRollingTickPack.mqh` | Source-present scaffold | Defines selected-symbol rolling tick buffer, CopyTicksRange update helper, summary metrics, CSV row helper, Dossier section helper, and compact Board row helper. Not included by `mt5/AuroraCore.mq5` yet. |

## Authority Boundary

Owns:

```text
selected-symbol rolling MT5 tick/spread proxy metrics
tick_count_1m/5m/10m
spread min/avg/max/stddev/spikes
tick gaps
bid/ask/last/volume change counts
mid proxy range/change counts
sample quality
proxy confidence
```

Must not own:

```text
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
```

## Activation Gate

Do not include this file in `mt5/AuroraCore.mq5` until:

```text
L1-L19 selected-scope chain is stable enough for L20 scope truth
selected-scope source path is confirmed
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
copyticksrange calls bounded
no all-symbol scan
no normal-refresh cold rebuild
Board compact summary visible
Dossier L20 section visible
Workbench proof visible
trade_permission=false
entry_signal=false
execution=false
institutional_order_flow_claim=false
```

## Decision

```text
TEST_FIRST
```
