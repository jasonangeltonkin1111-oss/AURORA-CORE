# 38 L22 SURFACE DESIGN — BOARD / DOSSIER / WORKBENCH

## Status

Design/control only.

This document defines how Layer 22 — Deep Market Evidence / Liquidity / MT5 Order-Flow Proxy Pack should appear on Aurora surfaces after the upstream selected-evidence chain exists.

It does not implement runtime source.

It does not wire L22 into the worker chain.

It does not add MT5 DOM subscriptions.

It does not request or permit main merge.

Decision default:

```text
TEST FIRST
```

---

## Dependency and merge lock

Layer 22 must remain DESIGN ONLY / HOLD MAIN until Layer 21 — Selected Indicator / Reference Pack is confirmed running on main and stable.

```text
L20 cannot merge until L19 is confirmed running on main.
L21 cannot merge until L20 is confirmed running on main.
L22 cannot merge until L21 is confirmed running on main.
L23 cannot merge until L22 is confirmed running on main.
```

L22 comes before L23. L22 must not depend on L23 for basic evidence. L22 may expose area geometry, liquidity references, value context, tick proxy context, DOM proxy context, evidence freshness, and completeness. L23 may later consume L22 evidence for manual review/export/setup research.

---

## L22 purpose

L22 answers selected-symbol questions:

```text
Where is price relative to important areas?
How much raw and spread-adjusted room exists to nearby areas?
Is the current area context fresh, stale, partial, or missing?
Is value/VWAP context available?
Is tick/DOM proxy context available?
What is the evidence completeness state?
```

L22 must not answer:

```text
Should I buy?
Should I sell?
Is this high probability?
Is this institutional order flow?
Is this prop-firm safe?
Can Aurora execute?
```

---

## Surface split law

```text
Board = compact trading cockpit.
Dossier = deeper per-symbol trading/evidence context.
Workbench = internals, source contracts, schema proof, formula basis, timings, write proof, and failure reasons.
```

Board and Dossier must not display upstream source plumbing such as `source_l18_status`, contract versions, worker paths, schema internals, job ids, checksums, or architecture lectures.

Workbench must carry those internals.

---

## Evidence blocks

L22 surface evidence should be organized into these blocks:

```text
1. Evidence state and freshness
2. Liquidity / area map
3. Area geometry and spread-aware room
4. Value context
5. Tick / DOM proxy context
6. No-permission boundary
```

Internal-only blocks:

```text
source contract versions
upstream packet statuses
source ages
formula basis
cost model source
DOM subscription ledger
write/timing proof
schema rows
```

---

## Board design

### Board purpose

The Board should answer quickly:

```text
Is L22 usable?
What is the selected evidence state?
What is the nearest important area context?
Is spread-aware room usable, partial, or unavailable?
Is tick/DOM proxy context available?
Is trade permission false?
```

### Board standard

```text
LAYER 22 - DEEP MARKET EVIDENCE
--------------------------------------------------
Status:                    Partial
Mode:                      Degraded Reference
Selected Symbols:           10
Evidence Freshness:         Mixed
Worst Issue:                VWAP / tick proxy not ready

Liquidity Areas Ready:      8 / 10
Area Geometry Ready:        7 / 10
Value Context Ready:        0 / 10
Tick/DOM Proxy Ready:       0 / 10

Closest Area:               EURUSD near session high area
Area State:                 below zone, not touched
Spread-Aware Room:          partial
Cost Model:                 partial
Trade Permission:           FALSE
```

### Optional compact Board table

Only show a tiny top sample if useful. Do not dump the full selected set.

```text
Rank | Symbol | Area State       | Room    | Value | Tick/DOM | Status
01   | EURUSD | near upper area  | partial | miss  | miss     | partial
02   | XAUUSD | inside zone      | stale   | miss  | off      | degraded
03   | GBPJPY | middle area      | ready   | miss  | miss     | partial
```

### Board forbidden content

```text
source layer names
source contract versions
worker paths
raw formula rows
raw OHLC rows
raw tick rows
raw DOM ladders
full symbol lists
SMC story text
setup wording
entry wording
edge wording
permission wording beyond Trade Permission: FALSE
```

---

## Dossier design

### Dossier purpose

The selected copied Dossier should show rich per-symbol L22 evidence context without turning into Workbench.

Dossier shows what the trader/operator can inspect.

It does not show source-contract plumbing.

### Main Dossier section

```text
LAYER 22 - DEEP MARKET EVIDENCE
--------------------------------------------------
Status:                    Partial
Evidence Freshness:         Mixed
Evidence Mode:              Degraded Reference
Trade Permission:           FALSE

Liquidity / Area Map
--------------------------------------------------
Nearest High Area:          Current Session High
Reference Price:            1.08750
Raw Distance:               11.6 pips
Spread-Adjusted Room:       10.2 pips
Distance ATR:               0.42
Distance % Session Range:   8.4%
Area Width:                 3.0 pips
Position vs Area:           Below Zone
Touch State:                Untouched
Reaction State:             Unknown

Nearest Low Area:           Prior Day Low
Reference Price:            1.08120
Raw Distance:               51.4 pips
Spread-Adjusted Room:       50.0 pips
Distance ATR:               1.86
Distance % Day Range:       41.2%
Area Width:                 4.0 pips
Position vs Area:           Above Zone
Touch State:                Untouched
Reaction State:             Unknown
```

### Area geometry section

```text
Area Geometry
--------------------------------------------------
Nearest High Area:          Session High
Nearest Low Area:           Prior Day Low
Area Range Width:           63.0 pips
Price Position In Area:     81%
Spread To Nearest Area:     0.08
Geometry State:             Near upper area
Interpretation:             Context only
```

### Value context section

```text
Value Context
--------------------------------------------------
VWAP State:                 Not Available
Price vs VWAP:              Not Available
Value Confidence:           Unavailable
Interpretation:             Reference only
```

If value context is available later:

```text
Value Context
--------------------------------------------------
VWAP State:                 Available
Price vs VWAP:              Above VWAP
Distance to VWAP:           9.2 pips
Distance to VWAP ATR:       0.34
Value Confidence:           Medium
Interpretation:             Reference only
```

### Tick / DOM proxy section

```text
Tick / DOM Proxy Context
--------------------------------------------------
Tick Proxy:                 Not Available
DOM Proxy:                  Disabled
Visible Book Imbalance:     Not Available
Order Flow Source:          Unavailable
Interpretation:             No institutional order-flow claim
```

If DOM proxy is later approved and proven:

```text
Tick / DOM Proxy Context
--------------------------------------------------
Tick Proxy:                 Available
DOM Proxy:                  Available
Visible Book Imbalance:     1.26
Order Flow Source:          MT5 DOM proxy
Order Flow Confidence:      Low
Interpretation:             Visible broker book proxy only
```

### Dossier forbidden content

```text
source_l18_status
source_l21_contract_version
worker result paths
schema ids
job ids
checksums
upstream source lectures
confirmed buy
confirmed sell
high probability
smart money confirmed
institutional order flow confirmed
setup confirmation
entry signal
prop-firm safe
```

---

## Workbench / internals design

Workbench proves the packet. It may be verbose.

### Required Workbench summary

```text
L22_DEEP_MARKET_EVIDENCE
--------------------------------------------------
schema_name=aurora_l22_deep_market_evidence_liquidity_proxy
schema_version=1
layer=L22
authority=evidence_proxy_context_only
scope=selected_symbols_only

source_l17_status=<status>
source_l17_contract_version=<version>
source_l18_status=<status>
source_l18_contract_version=<version>
source_l19_status=<status>
source_l19_contract_version=<version>
source_l20_status=<status>
source_l20_contract_version=<version>
source_l21_status=<status>
source_l21_contract_version=<version>

synthesis_mode=blocked_placeholder|degraded_partial|normal_reference|dom_proxy_enabled
l22_status=<status>
l22_failure_reason=<reason>

oldest_source_age_seconds=<n|unknown>
newest_source_age_seconds=<n|unknown>
evidence_age_state=fresh|mixed|stale|unknown

selected_symbols_seen=<n>
selected_symbols_published=<n>
liquidity_areas_ready_count=<n>
area_geometry_ready_count=<n>
value_context_ready_count=<n>
tick_dom_proxy_ready_count=<n>

trade_permission=false
entry_signal=false
execution=false
```

### Measurement proof fields

```text
SYMBOL_POINT
SYMBOL_DIGITS
pip_points
pip_display_status
spread_points
spread_source
spread_age_seconds
spread_included_in_distance
cost_model_status
cost_model_source

liquidity_reference_source
zone_width_basis
zone_half_width_points
raw_distance_to_area_points
usable_distance_to_area_points
spread_to_area_distance_ratio
spread_to_area_range_ratio
```

### DOM proof fields

```text
dom_scope_guard=selected_symbols_only
dom_symbol_limit=<n>
dom_heavy_work_allowed=false
dom_file_write_inside_onbookevent=false
dom_subscription_status=<status>
dom_book_get_status=<status>
dom_release_status=<status>
onbookevent_heavy_work=false
```

### Anti-claim proof fields

```text
institutional_order_flow_claim=false
smart_money_claim=false
setup_confirmation=false
directional_forecast=false
trade_permission=false
entry_signal=false
execution=false
```

---

## Output design

Suggested worker output folder, if source is later approved:

```text
Gateway/Outbox/Layers/Layer_22_Deep_Market_Evidence_Liquidity_Proxy/
```

Suggested files:

```text
l22_status.txt
l22_selected_symbols.csv
l22_liquidity_area_summary.csv
l22_dom_status.txt
```

Dossier decoration target:

```text
selected copied Dossiers only
```

L22 must not write base Dossiers unless a future owner contract explicitly changes that.

L22 must not create changing-rank parent folders.

---

## Runtime scaffold constraints

First acceptable future source scaffold may:

```text
read selected scope
read upstream packet statuses
mark missing L20/L21 as not_implemented
publish degraded truth
write compact Board summary fields
append L22 context to selected copied Dossiers
write Workbench/internal proof
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
claim runtime accepted without output proof
claim edge or permission
```

---

## Debloat acceptance checklist

Before design is accepted:

```text
Board is compact.
Board contains no source plumbing.
Dossier contains trading context only.
Dossier contains no source plumbing.
Workbench contains internals/proof/schema/timing/source contracts.
No repeated architecture lecture on Board/Dossier.
No all-symbol deep evidence collection.
No duplicate owner/cache.
No permission/edge/execution wording.
No L23-before-L22 dependency language.
L22 merge remains blocked until L21 is confirmed running on main.
```

## Decision

```text
TEST FIRST
```
