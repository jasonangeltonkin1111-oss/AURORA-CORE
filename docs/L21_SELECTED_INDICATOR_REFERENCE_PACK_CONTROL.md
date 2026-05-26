# L21 SELECTED INDICATOR / REFERENCE PACK CONTROL

## Status
Design scaffold only. Do not merge L21 to main until L20 Selected Rolling Tick Pack is accepted and stable.

```text
l21_design_status=design_scaffold_only
l21_merge_allowed=false
l21_merge_blocker=L20_not_accepted_and_stable
l21_runtime_activation_allowed=false_until_L20_accepted_and_stable
trade_permission=false
entry_signal=false
execution=false
expectancy_validated=false
```

## Purpose
Layer 21 builds selected-symbol indicator/reference context only.

Indicators describe condition. They do not grant permission.

L21 may support manual review by explaining volatility, dispersion, range context, VWAP/fair-value distance, trend-strength context, momentum pressure, and execution-quality context.

L21 must never create buy/sell signals, trade permission, auto-trading permission, prop-firm readiness, or edge/expectancy claims.

## Hard upstream gate
L21 is blocked until L20 is accepted and stable.

Correct selected evidence chain:

```text
L17 selected scope
-> L18 selected raw OHLC
-> L19 selected candle geometry
-> L20 selected rolling tick pack
-> L21 selected indicator/reference pack
-> L22 deep evidence synthesis
-> L23 manual review/export/permission state
```

Runtime status logic:

```text
if L20 missing:
    l21_status=blocked_upstream_l20_missing
elif L20 not accepted/stable:
    l21_status=blocked_upstream_l20_not_accepted_and_stable
elif L18 OHLC missing:
    l21_status=blocked_upstream_l18_missing
elif selected_scope_empty:
    l21_status=pending_no_selected_symbols
elif insufficient bars:
    l21_status=partial_insufficient_bars
elif any source stale/degraded:
    l21_status=degraded_reference_pack_written
else:
    l21_status=reference_pack_ready
```

`reference_pack_ready` does not mean trade-ready.

## One-pack-one-module law
Every indicator pack must be its own module.

```text
one_indicator_pack=one_module
one_module=one_deep_research_run
one_deep_run=docs+formula+failure_states+tests+no_signal_audit+performance_proof
```

No monolithic indicator soup. No combined mega-pack that hides formula bugs, ownership drift, or signal language.

Recommended future source layout:

```text
external_worker/l21/
  __init__.py
  l21_contract.py
  l21_status.py
  l21_board.py
  l21_dossier.py
  l21_workbench.py
  l21_no_signal_audit.py
  packs/
    atr_pack.py
    range_percentile_pack.py
    ma_slope_pack.py
    stddev_pack.py
    bollinger_pack.py
    vwap_pack.py
    spread_to_range_pack.py
    rsi_pack.py
    adx_dmi_pack.py
    donchian_pack.py
    choppiness_pack.py
    volume_proxy_pack.py
    macd_pack.py
    stochastic_pack.py
    keltner_pack.py
    zscore_pack.py
    candle_pressure_reference_pack.py
```

## Universal packet guardrails
Every L21 output must print:

```text
layer_id=L21
layer_name=selected_indicator_reference_pack
selected_scope_only=true
upstream_required=L20
upstream_l20_status=missing|not_proven|partial|degraded|accepted|stable
indicator_meaning=reference_context_only_not_signal
trade_permission=false
entry_signal=false
execution=false
expectancy_validated=false
```

Pack-specific wording must remain descriptive:

```text
atr_meaning=volatility_reference_only_not_signal
ma_slope_meaning=directional_context_only_not_entry
bb_meaning=volatility_location_envelope_only_not_buy_sell
vwap_meaning=benchmark_context_only_not_entry
rsi_meaning=momentum_pressure_context_only_not_entry
macd_meaning=momentum_shift_reference_only_not_entry
adx_meaning=trend_strength_context_only_not_direction_permission
donchian_meaning=recent_boundary_context_only_not_breakout_permission
chop_meaning=market_condition_context_only_not_trade_filter_permission
volume_meaning=activity_proxy_only_not_institutional_confirmation
spread_to_range_meaning=execution_quality_context_only_not_edge
```

## Indicator build phases

### Phase 1 - core reference pack
```text
ATR
Range percentile
MA slope
Standard deviation
Bollinger Bands
VWAP
Spread-to-range
```

### Phase 2 - high-value extra context
```text
RSI
ADX / DMI
Donchian Channel
Choppiness Index
Volume / tick-volume MA
```

### Phase 3 - optional advanced context
```text
MACD
Stochastic
Keltner Channel
Z-score
L19 candle-pressure reference only
```

Candle pressure is L19-owned. L21 may reference L19 geometry but must not recalculate or own it.

## Board surface
Board is compact cockpit only.

Route:

```text
Selection Desk/91_Layer_Summaries/L21_Selected_Indicator_Reference_Pack/00_L21_Board_Overview.txt
```

Board may show:

```text
L21 status
L20 gate status
selected symbols seen
selected symbols decorated
indicator complete/partial/missing counts
VWAP real/tick_proxy/unavailable counts
top blocking reasons
no_signal_audit_status
trade_permission=false
entry_signal=false
execution=false
```

Board must not dump full per-symbol indicator rows or raw calculations.

## Dossier surface
Dossier carries per-symbol selected evidence truth.

L21 block lives inside selected deep evidence section:

```text
========== SELECTION-ONLY DEEP EVIDENCE START ==========
----- L21 INDICATOR REFERENCE PACK START -----
...
----- L21 INDICATOR REFERENCE PACK END -----
========== SELECTION-ONLY DEEP EVIDENCE END ==========
```

Before L20 acceptance/stability, Dossier should print blocked truth only, not calculated indicator values.

## Workbench surface
Workbench owns proof and diagnostics.

Suggested files:

```text
Workbench/Gateway/Outbox/Layers/Layer_21_Selected_Indicator_Reference_Pack/l21_status.txt
Workbench/Gateway/Outbox/Layers/Layer_21_Selected_Indicator_Reference_Pack/l21_manifest.txt
Workbench/Gateway/Outbox/Layers/Layer_21_Selected_Indicator_Reference_Pack/l21_schema.txt
Workbench/Gateway/Outbox/Layers/Layer_21_Selected_Indicator_Reference_Pack/l21_failures.csv
Workbench/Gateway/Outbox/Layers/Layer_21_Selected_Indicator_Reference_Pack/l21_perf.txt
Workbench/Gateway/Outbox/Layers/Layer_21_Selected_Indicator_Reference_Pack/l21_no_signal_audit.txt
```

## Source ownership
L21 may consume:

```text
L18 selected OHLC
L19 candle geometry references
L20 selected rolling tick status/context once accepted and stable
Shared OHLC Raw Storage Owner outputs
```

L21 must not own:

```text
CopyRates
private OHLC cache
CopyTicks
DOM
execution
trade permission
```

## Per-module research requirements
Each indicator module deep run must document:

```text
official/platform basis
formula
input source owner
output schema
minimum bars
current-forming-bar vs closed-bar policy
failure states
no-signal wording
synthetic tests
performance risk
rollback path
```

If MT5 indicator handles are used later, the module must check:

```text
INVALID_HANDLE
BarsCalculated
CopyBuffer return count
GetLastError where relevant
IndicatorRelease lifecycle
```

## Forbidden interpretations
Never allow these in runtime packets:

```text
ATR expansion = signal
MA slope up = buy
MA slope down = sell
BB lower = buy
BB upper = sell
BB squeeze = guaranteed breakout
VWAP touch = entry
VWAP reclaim = confirmed buy
RSI oversold = buy
RSI overbought = sell
MACD cross = automatic entry
ADX high = buy
ADX high = sell
Donchian break = confirmed breakout
Keltner upper = buy
Stochastic oversold = buy
High tick volume = institutional confirmation
Low spread = edge
```

## Synthetic test plan
Every pack must pass synthetic tests for:

```text
flat data
rising data
falling data
zero range
missing bars
insufficient bars
stale timestamp
zero volume
tick-volume-only
duplicate selected route copies
forbidden wording scan
L20 missing block
L20 not accepted/stable block
```

## Merge gate
L21 may not merge to main until:

```text
L20 source exists
L20 selected-only runtime proof exists
L20 status is accepted/stable
L20 is included in accepted epoch proof
L21 branch is rebased/current with main
L21 runtime gate blocks when L20 is missing/not stable
L21 no-signal audit passes
L21 synthetic tests pass
L21 performance proof exists
source indexes are updated
```

## Decision
TEST FIRST.
