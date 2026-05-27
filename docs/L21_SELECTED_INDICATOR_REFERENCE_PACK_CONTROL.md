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

## Current core role
Layer 21 is the selected-symbol reference context owner.

It gives neutral technical reference values.

It does not create signals.

Core law:

```text
Indicators describe condition.
They do not grant permission.
```

## What L21 should answer
1. What is normal range/volatility?
2. Where is price relative to simple reference tools?
3. Is price extended, compressed, or near a reference boundary?
4. Do reference indicators provide context for L22/L23 risk geometry?

## Inputs
L21 may consume:

```text
selected-symbol OHLC from L18
optional tick/spread context from L20 once accepted and stable
timeframe role definitions
```

L21 must not own the source packets it consumes.

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
Every indicator group must be its own module.

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
    atr_range_context_pack.py
    sma_context_pack.py
    donchian_pack.py
    bollinger_context_pack.py
    vwap_context_pack.py
    volume_label_pack.py
```

## Final L21 reference tools and fields
Keep L21 simple, objective, and explainable.

### 1. ATR / range context
```text
atr_value
atr_percentile
range_percentile
movement_context_state
```

Meaning:

```text
atr_value=volatility reference
atr_percentile=relative ATR context
range_percentile=recent range context
movement_context_state=normal|quiet|expanded|compressed|unavailable
```

### 2. SMA 50 / SMA 200
```text
sma_50_value
sma_200_value
price_vs_sma50
price_vs_sma200
sma_context_state=above|below|between|unavailable
```

Meaning:

```text
sma_50_value=medium reference line
sma_200_value=longer reference line
price_vs_sma50=price location relative to SMA50
price_vs_sma200=price location relative to SMA200
sma_context_state=simple trend/location context only
```

### 3. Donchian channel
```text
donchian_period
donchian_high
donchian_low
donchian_position_percent
donchian_breakout_candidate
```

Meaning:

```text
donchian_high=recent upper boundary
donchian_low=recent lower boundary
donchian_position_percent=location inside recent boundary range
donchian_breakout_candidate=boundary-proximity context only, not breakout permission
```

### 4. Bollinger context
```text
bollinger_width
bollinger_position
compression_state
expansion_state
```

Meaning:

```text
bollinger_width=volatility envelope width
bollinger_position=location inside volatility envelope
compression_state=compressed|normal|not_compressed|unavailable
expansion_state=expanded|normal|not_expanded|unavailable
```

### 5. VWAP context
VWAP may be used only if time/source basis is correct.

```text
vwap_value
vwap_session_basis
vwap_distance_pips
vwap_data_status
```

Meaning:

```text
vwap_value=benchmark/fair-value reference
vwap_session_basis=session|day|week|rolling|unavailable
vwap_distance_pips=distance from VWAP reference
vwap_data_status=real_volume|tick_volume_proxy|partial|unavailable|not_wired
```

### 6. Volume label only
```text
volume_source_type=real_volume|tick_volume_proxy|unavailable
volume_context_state
```

Meaning:

```text
volume_source_type=data source truth only
volume_context_state=normal|elevated|thin|unavailable
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
atr_range_meaning=volatility_and_range_reference_only_not_signal
sma_context_meaning=simple_reference_location_only_not_entry
donchian_meaning=recent_boundary_context_only_not_breakout_permission
bollinger_meaning=volatility_location_envelope_only_not_buy_sell
vwap_meaning=benchmark_context_only_not_entry
volume_label_meaning=source_truth_only_not_institutional_confirmation
```

## How L21 output may be used
L22 may use ATR/range/VWAP/Donchian context for target room and level quality.

L23 may use reference values as filters only after validation.

Dossier may show compact reference context.

These downstream uses do not upgrade L21 into signal authority.

## Do not add
Do not add RSI/MACD strategy by default.

Do not add indicator stacking.

Do not add indicator-only permission.

Do not add an expanded indicator menu without a new control decision.

Forbidden interpretations:

```text
ATR expansion = signal
SMA 50 above SMA 200 = buy
SMA 50 below SMA 200 = sell
Donchian high break = confirmed buy
Donchian low break = confirmed sell
Donchian breakout candidate = setup permission
BB lower = buy
BB upper = sell
BB squeeze = guaranteed breakout
VWAP touch = entry
VWAP reclaim = confirmed buy
VWAP institutional reaction claim
High tick volume = institutional confirmation
Low spread = edge
indicator-only setup candidate
```

Correct wording:

```text
ATR/range = volatility and movement context
SMA context = simple reference location
Donchian = recent boundary context
Bollinger = volatility/location envelope
VWAP = benchmark/fair-value reference when basis is valid
Volume label = data-source truth
```

## Acceptance checks
```text
every indicator has timeframe label
every indicator has data-status label
indicator output says context only
missing data degrades honestly
no indicator-only setup candidate
```

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
reference fields complete/partial/missing counts
VWAP data-status counts
volume-source counts
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

Future Dossier rows should stay compact:

```text
tf | status | data_status | atr | atr_pctile | range_pctile | movement_state | sma50 | sma200 | price_vs_sma50 | price_vs_sma200 | sma_state | donchian_high | donchian_low | donchian_pos_pct | donchian_candidate | bb_width | bb_position | compression | expansion | vwap | vwap_basis | vwap_distance_pips | vwap_status | volume_source | volume_state | failures
```

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
L20 selected rolling tick/spread context once accepted and stable
timeframe role definitions
Shared OHLC Raw Storage Owner outputs through L18 contract
```

L21 must not own:

```text
CopyRates
private OHLC cache
CopyTicks
DOM
execution
trade permission
raw OHLC source truth
candle geometry source truth
rolling tick source truth
```

## Per-module research requirements
Each indicator module deep run must document:

```text
official/platform basis
formula
input source owner
output schema
minimum bars
timeframe label policy
data-status label policy
current-forming-bar vs closed-bar policy
failure states
no-signal wording
synthetic tests
performance risk
rollback path
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
