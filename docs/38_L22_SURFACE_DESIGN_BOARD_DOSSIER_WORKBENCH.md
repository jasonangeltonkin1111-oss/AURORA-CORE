# 38 L22 SURFACE DESIGN — BOARD / DOSSIER / WORKBENCH

## Status

Planning/design control only.

This document does not prove L22 runtime, does not wire L22 into the worker chain, does not add MT5 DOM subscriptions, and does not grant trade permission.

Decision default:

```text
TEST FIRST
```

---

## Purpose

Define how Layer 22 — Deep Market Evidence / Liquidity / MT5 Order-Flow Proxy Pack should appear on Aurora surfaces once upstream selected evidence packets exist.

L22 is a selected-symbol evidence synthesis layer. It prepares context for manual review and future Layer 23 setup research. It is not a buy/sell system, not a signal seller, not a finished edge, not a permission layer, and not execution authority.

---

## Core surface law

L22 must preserve the Aurora surface split:

```text
Board = compact operator cockpit
Dossier = rich per-symbol evidence context
Workbench = machine proof, status, timing, counters, and failure reasons
```

L22 must not use the Board as a dumping ground for raw ticks, raw OHLC, raw DOM ladders, or long SMC/liquidity narratives.

L22 must not use Dossiers as hidden calculation owners.

L22 must not use Workbench proof fields as trading claims.

---

## L22 evidence spine

L22 surfaces should be built around six evidence blocks:

```text
A. Source readiness
B. Risk geometry context
C. Liquidity reference map
D. VWAP / value context consumed from L21
E. Tick-flow proxy consumed from L20
F. Optional MT5 DOM proxy status
```

Every block must carry status and failure reason.

Allowed statuses:

```text
accepted
partial
degraded
missing
not_implemented
unavailable
disabled
blocked_missing_upstream
```

L22 must show degraded truth instead of hiding files when evidence is partial, stale, missing, unavailable, or not implemented.

Physical publication may only be blocked by path/FileIO/write failure.

---

## Board design

### Board purpose

The Board answers:

```text
Is L22 present?
How many selected symbols have usable L22 evidence?
What is the worst blocker?
Is DOM enabled or disabled?
Is any permission accidentally implied?
```

The Board must stay compact and aligned.

### Board section format

```text
LAYER 22 - DEEP MARKET EVIDENCE / LIQUIDITY / MT5 ORDER-FLOW PROXY
------------------------------------------------------------------
Status:                       Partial / Blocked / Accepted
Scope:                        Selected Symbols Only
Selected Symbols Seen:         10
Symbols Published:             8
Worst Blocker:                 upstream_l21_not_implemented
Evidence Completeness:         62%
Risk Geometry Ready:           6 / 10
Liquidity Map Ready:           8 / 10
VWAP Context Ready:            0 / 10
Tick Proxy Ready:              0 / 10
DOM Runtime:                   Disabled
DOM Subscriptions:             0 / 0
Order Flow Source:             unavailable
Trade Permission:              FALSE
Entry Signal:                  FALSE
Execution:                     FALSE
Next Action:                   Implement/prove L20 and L21 before L22 runtime
```

### Optional compact Board overview table

This table is allowed only if it stays short and operator-readable.

```text
L22 SELECTED EVIDENCE OVERVIEW
------------------------------------------------------------------
Rank | Symbol | Risk Geometry | Liquidity | VWAP | Tick Proxy | DOM | Status
01   | EURUSD | ready         | ready     | miss | miss       | off | partial
02   | XAUUSD | partial       | ready     | miss | miss       | off | partial
03   | GBPJPY | missing       | partial   | miss | miss       | off | degraded
```

### Board must not show

```text
full OHLC rows
full tick list
full DOM book ladder
full VWAP calculation rows
full liquidity cluster ledger
full sweep/reclaim/FVG prose
job ids
checksums
long proof ledgers
trade suggestions
```

---

## Dossier design

### Dossier purpose

The selected copied Dossier answers:

```text
For this selected symbol, what L22 evidence is available, missing, degraded, or only proxy context?
```

L22 should decorate selected copied dossiers only. It must not touch base Dossiers unless a future source contract explicitly changes this.

### Main Dossier block

```text
LAYER 22 - DEEP MARKET EVIDENCE / LIQUIDITY / MT5 ORDER-FLOW PROXY
------------------------------------------------------------------
Status:                  Partial
Scope:                   Selected-symbol evidence only
Authority:               Evidence proxy context only
Trade Permission:         FALSE
Entry Signal:             FALSE
Execution:                FALSE

Source Inputs
------------------------------------------------------------------
L17 Selected Scope:        accepted
L18 Raw OHLC Pack:         accepted
L19 Candle Geometry:       accepted
L20 Tick Proxy:            not_implemented
L21 VWAP Reference:        not_implemented
DOM Runtime:              disabled
Main Failure Reason:       upstream_l20_l21_not_implemented
```

### Risk geometry subsection

Risk geometry is descriptive. It is not risk approval and not edge validation.

If L23 has not supplied a mechanical setup candidate with invalidation/target, L22 must say so.

```text
Risk Geometry Context
------------------------------------------------------------------
Status:                   partial
Invalidation Source:       not_defined_by_L23
Invalidation Distance:     not_available
Target Room Source:        nearest_liquidity_reference
Target Room Pips:          42.3
Target Room ATR:           1.18
Spread To Stop Ratio:      not_available
Expected R After Cost:     not_available
Confidence:                low
Note:                      Risk geometry is descriptive only until L23 defines setup/invalidation/target rules.
```

Future candidate-aware version:

```text
Risk Geometry Context
------------------------------------------------------------------
Setup Candidate ID:        SMC_STRUCTURE_RETEST_V1_RESEARCH
Invalidation Source:       candidate_zone_low
Invalidation Distance:     12.1 pips
Target Source:             prior_day_high
Target Room:               36.4 pips
Spread To Stop Ratio:      0.08
Expected R After Cost:     2.64
Confidence:                medium
Trade Permission:          FALSE
```

Forbidden upgrade:

```text
risk_pass=true
trade_valid=true
entry_quality=high
```

### Liquidity reference subsection

Liquidity references are map context only.

```text
Liquidity Reference Map
------------------------------------------------------------------
Status:                         ready
Nearest High Reference:          prior_day_high
Nearest High Distance:           18.4 pips
Nearest Low Reference:           session_low
Nearest Low Distance:            27.9 pips
Equal High Cluster Count:        2
Equal Low Cluster Count:         0
Session High Distance:           11.6 pips
Session Low Distance:            27.9 pips
Prior Day High Distance:         18.4 pips
Prior Day Low Distance:          64.2 pips
Prior Week High Distance:        91.8 pips
Prior Week Low Distance:         143.5 pips
Liquidity Map Confidence:        medium
Interpretation:                  liquidity_reference_only
```

Allowed note:

```text
Price is closer to the current session high than to the current session low.
```

Forbidden note:

```text
Session high likely gets swept; prepare sell.
```

### VWAP / value context subsection

L22 consumes VWAP context from L21. L22 must not calculate VWAP.

Missing/upstream-not-implemented version:

```text
VWAP / Value Context
------------------------------------------------------------------
Status:                   missing
Source Owner:              L21 Selected Indicator / Reference Pack
VWAP Source:               not_available
Price vs VWAP:             not_available
Distance to VWAP:          not_available
Confidence:                unavailable
Failure Reason:            upstream_l21_not_implemented
```

Future available version:

```text
VWAP / Value Context
------------------------------------------------------------------
Status:                   ready
Source Owner:              L21
VWAP Source:               tick_volume_proxy
Session VWAP:              1.08432
Price vs VWAP:             above_vwap
Distance to VWAP:          9.2 pips
Distance to VWAP ATR:      0.34
VWAP Confidence:           medium
Interpretation:            reference_context_only
```

Forbidden upgrades:

```text
above_vwap_buy
vwap_touch_entry
below_vwap_sell
```

### Tick-flow proxy subsection

L22 consumes selected rolling tick proxy from L20. L22 must not call fresh broad CopyTicks.

Missing/upstream-not-implemented version:

```text
Tick-Flow Proxy
------------------------------------------------------------------
Status:                   missing
Source Owner:              L20 Selected Rolling Tick Pack
Tick Count 10m:            not_available
Bid Change Count 10m:      not_available
Ask Change Count 10m:      not_available
Spread Spike Count 10m:    not_available
Confidence:                unavailable
Failure Reason:            upstream_l20_not_implemented
```

Future available version:

```text
Tick-Flow Proxy
------------------------------------------------------------------
Status:                   ready
Source Owner:              L20
Tick Count 10m:            183
Bid Change Count 10m:      74
Ask Change Count 10m:      79
Spread Spike Count 10m:    2
Max Tick Gap:              14.2 sec
Confidence:                medium
Interpretation:            mt5_tick_proxy_only
```

Forbidden upgrade:

```text
real_order_flow_confirmed=true
```

### MT5 DOM proxy subsection

DOM starts disabled until a later TEST FIRST implementation proves selected-symbol subscription bookkeeping, bounded OnBookEvent behavior, MarketBookGet summary, and MarketBookRelease cleanup.

Initial placeholder version:

```text
MT5 DOM Proxy
------------------------------------------------------------------
Status:                   disabled
DOM Runtime Enabled:       false
DOM Available Flag:        false
Subscription Status:       not_wired
Bid Levels Count:          not_available
Ask Levels Count:          not_available
Bid Visible Volume Total:  not_available
Ask Visible Volume Total:  not_available
DOM Imbalance Ratio:       not_available
Order Flow Source:         unavailable
Order Flow Confidence:     unavailable
Interpretation:            no_institutional_order_flow_claim
```

Future bounded implementation version:

```text
MT5 DOM Proxy
------------------------------------------------------------------
Status:                   partial
DOM Runtime Enabled:       true
DOM Available Flag:        true
Subscription Status:       subscribed
Bid Levels Count:          5
Ask Levels Count:          4
Bid Visible Volume Total:  118.4
Ask Visible Volume Total:  94.1
DOM Imbalance Ratio:       1.26
Order Flow Source:         mt5_dom_proxy
Order Flow Confidence:     low
Interpretation:            visible_book_depth_proxy_only
```

Forbidden upgrades:

```text
institutional_order_flow_confirmed=true
smart_money_buying=true
confirmed_buy=true
confirmed_sell=true
```

---

## Workbench design

### Workbench purpose

Workbench carries proof and failure reasons. It is the correct place for machine fields, timing, source checks, DOM bookkeeping, and rejection reasons.

### Main Workbench block

```text
L22_DEEP_MARKET_EVIDENCE_LIQUIDITY_PROXY
------------------------------------------------------------------
schema_name=aurora_l22_deep_market_evidence_liquidity_proxy
schema_version=1
layer=L22
authority=evidence_proxy_context_only
scope=selected_symbols_only
source_l17_status=accepted
source_l18_status=accepted
source_l19_status=accepted
source_l20_status=not_implemented
source_l21_status=not_implemented
l22_status=blocked_missing_upstream
l22_failure_reason=upstream_l20_l21_not_implemented
selected_symbols_seen=10
selected_symbols_published=10
risk_geometry_ready_count=0
liquidity_map_ready_count=8
vwap_context_ready_count=0
tick_proxy_ready_count=0
dom_runtime_enabled=false
dom_subscription_count=0
dom_subscription_limit=0
dom_release_pending_count=0
dom_book_get_failed_count=0
trade_permission=false
entry_signal=false
execution=false
generated_utc=<timestamp>
```

### Future DOM proof block

Only allowed after real DOM implementation exists.

```text
L22_DOM_SUBSCRIPTION_PROOF
------------------------------------------------------------------
dom_runtime_enabled=true
subscription_scope=l17_selected_symbols_only
subscription_limit=10
marketbook_add_attempted=10
marketbook_add_success=6
marketbook_add_failed=4
marketbook_release_attempted=6
marketbook_release_success=6
marketbook_release_failed=0
onbookevent_seen_count=214
onbookevent_ignored_other_symbol_count=37
onbookevent_heavy_work=false
max_onbookevent_duration_ms=1
last_dom_cycle_duration_ms=18
```

### Workbench must not show

```text
trade recommendations
prop-firm-safe claims
confirmed buy/sell claims
institutional order-flow claims
edge validation claims
```

---

## Output file design

Suggested worker output folder:

```text
Gateway/Outbox/Layers/Layer_22_Deep_Market_Evidence_Liquidity_Proxy/
```

Suggested files:

```text
l22_status.txt
l22_selected_symbols.csv
l22_dom_status.txt
l22_liquidity_map_summary.csv
```

Suggested Dossier decoration target:

```text
Selection Desk/01_Global/Top_10/<rank>_<symbol>.txt
Selection Desk/02_Asset_Classes/.../<rank>_<symbol>.txt
```

L22 must not create changing-rank parent folders. Rank, order, scores, cycle id, and selected status belong inside files.

---

## CSV schema candidate

```csv
symbol,l22_symbol_status,risk_geometry_status,liquidity_map_status,vwap_context_status,tick_flow_proxy_status,dom_proxy_status,order_flow_source,order_flow_confidence,evidence_synthesis_completeness,failure_reason
EURUSD,partial,missing,ready,missing,missing,disabled,unavailable,unavailable,35,upstream_l20_l21_not_implemented
XAUUSD,partial,missing,partial,missing,missing,disabled,unavailable,unavailable,25,liquidity_map_insufficient_bars
```

---

## First runtime scaffold design

The first acceptable L22 source scaffold, when approved, is not a full implementation.

It may:

```text
read L17 selected scope
read L18/L19 status
mark L20 and L21 as not_implemented when absent
publish l22_status.txt
publish l22_selected_symbols.csv with degraded truth
append compact L22 blocks to selected copied dossiers
publish Board summary and Workbench proof
```

It must not:

```text
subscribe DOM
call CopyTicks
call CopyRates
calculate VWAP
calculate indicators
create private OHLC files
write base Dossiers
claim accepted runtime without output proof
```

---

## Later DOM implementation gates

Live DOM subscription is blocked until a separate TEST FIRST patch proves:

```text
selected-symbol-only subscription set
subscription cap
MarketBookAdd success/fail count
MarketBookGet success/fail count
MarketBookRelease success/fail count
release-pending visibility
OnBookEvent symbol filter
OnBookEvent minimal-work proof
no file writes inside OnBookEvent
bounded cycle synthesis
Workbench timing proof
MetaEditor compile proof
runtime output proof
```

---

## Strong decision

The correct L22 design is:

```text
selected list first
read upstream packets once
synthesize compact fields
decorate selected copied dossiers
publish compact Board summary
publish Workbench proof
feed L23 with evidence context only
```

The incorrect L22 design is:

```text
one symbol through all layers before next symbol
all-symbol DOM
all-symbol tick pulls
renderer-side synthesis
trade wording
permission wording
```

## Decision

```text
TEST FIRST
```
