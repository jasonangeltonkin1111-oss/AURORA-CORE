# 39 L22 DYNAMIC PIPS / SPREAD / AREA MEASUREMENT LAW

## Status

Design/control only.

This document adds an overseer-visible measurement law for Layer 22 and future related layers.

It does not implement source code.

It does not patch main.

It does not merge Layer 22.

Decision default:

```text
TEST FIRST
```

---

## BIG NOTE FOR OVERSEER — SYSTEM-WIDE MEASUREMENT LAW CANDIDATE

Aurora should adopt this as a broader system law after overseer review:

```text
All pip/point/area/risk-distance measurements must be dynamic, symbol-aware, spread-aware, and source-labelled.
```

Reason:

```text
A raw pip distance without spread/cost context can become fake precision.
A liquidity area without zone width can become vague SMC theatre.
A distance that ignores symbol digits/point/tick size can be wrong across FX, metals, indices, crypto, CFDs, and stocks.
A target/room measurement that ignores current spread can overstate usable room.
```

Overseer should consider promoting this rule into shared architecture/control later, not just L22.

Candidate global law name:

```text
DYNAMIC SPREAD-AWARE MEASUREMENT LAW
```

Candidate global wording:

```text
Any Aurora layer that reports distance, room, stop, target, spread-to-range, spread-to-stop, liquidity proximity, session-high/low proximity, prior-day/week proximity, or expected R must expose the measurement basis, symbol point/digit handling, spread/cost inclusion state, and evidence freshness. Raw pips alone are not sufficient proof.
```

---

## L22 measurement purpose

Layer 22 must describe selected-symbol market evidence using two separate concepts:

```text
1. Exact distance — points / pips / ATR / range percentage.
2. Area context — zone width, position versus zone, touch state, reaction state.
```

Both are required.

Distance without area loses trading context.

Area without exact distance loses execution realism.

---

## Dynamic pip rule

L22 must calculate internally in points first.

Display pips only after symbol-aware conversion.

Required symbol metadata:

```text
symbol
SYMBOL_POINT
SYMBOL_DIGITS
SYMBOL_TRADE_TICK_SIZE where available
current_spread_points
spread_source
spread_age_seconds
```

Internal base fields:

```text
distance_points
zone_width_points
spread_points
```

Display fields:

```text
distance_pips
zone_width_pips
pip_display_status=standard_fx|points_only|custom_review_required
```

Conservative display conversion:

```text
if SYMBOL_DIGITS in {3,5}: pip_points=10
else: pip_points=1

distance_pips = distance_points / pip_points
zone_width_pips = zone_width_points / pip_points
```

For non-standard instruments, pips may be misleading. In those cases the Dossier should prefer points, ATR distance, and range percentage.

---

## Spread-aware distance law

Any distance-to-area or room-to-area field must expose both raw distance and spread-adjusted usable distance.

Required fields:

```text
raw_distance_to_area_points
raw_distance_to_area_pips
spread_points
spread_pips
spread_included_in_distance=true|false
usable_distance_to_area_points
usable_distance_to_area_pips
spread_to_area_distance_ratio
spread_to_area_range_ratio
cost_model_status=ready|partial|missing|stale
cost_model_source=broker_specs|live_spread|l6_cost_layer|mixed|unavailable
```

For non-directional L22 context, use neutral mid-price for raw location:

```text
mid_price = (bid + ask) / 2
raw_distance_to_reference_points = abs(mid_price - reference_price) / point
```

For usable execution room, spread must be included conservatively.

High-side area room examples:

```text
usable_room_to_high_area_points = max(0, raw_room_to_high_area_points - spread_points)
spread_to_high_area_ratio = spread_points / max(raw_room_to_high_area_points, 1)
```

Low-side area room examples:

```text
usable_room_to_low_area_points = max(0, raw_room_to_low_area_points - spread_points)
spread_to_low_area_ratio = spread_points / max(raw_room_to_low_area_points, 1)
```

If direction is unknown, L22 must label this as:

```text
usable_room_basis=non_directional_conservative_spread_adjusted
```

If a later setup layer supplies direction, L23 may calculate direction-specific execution geometry.

L22 must not claim direction-specific expected R.

---

## Area / zone model

For every important reference, L22 should prefer area-aware fields instead of only simple pip distance.

Reference examples:

```text
session_high
session_low
prior_day_high
prior_day_low
prior_week_high
prior_week_low
equal_high_cluster
equal_low_cluster
nearest_liquidity_high
nearest_liquidity_low
```

Required area fields:

```text
reference_name
reference_price
reference_source
liquidity_reference_source=l18_ohlc|l19_geometry|session_range|prior_day_week|mixed|unavailable
zone_low
zone_high
zone_half_width_points
zone_half_width_pips
zone_width_basis=spread_minimum|atr_fraction|wick_geometry|mixed|unavailable
position_vs_zone=below_zone|inside_zone|above_zone|unknown
touch_state=untouched|touched|pierced|closed_beyond|unknown
reaction_state=no_reaction|rejected|accepted_beyond|reclaimed|unknown
```

Base formula:

```text
zone_low = reference_price - zone_half_width_points * point
zone_high = reference_price + zone_half_width_points * point
```

Position formula:

```text
if mid_price < zone_low: position_vs_zone=below_zone
elif mid_price > zone_high: position_vs_zone=above_zone
else: position_vs_zone=inside_zone
```

Distance-to-zone formula:

```text
if below_zone: raw_distance_to_zone_points = (zone_low - mid_price) / point
elif above_zone: raw_distance_to_zone_points = (mid_price - zone_high) / point
else: raw_distance_to_zone_points = 0
```

---

## Zone width formula

First acceptable formula should be conservative and source-labelled.

Preferred initial formula:

```text
zone_half_width_points = max(
    spread_points * 2,
    atr_points * 0.03,
    minimum_zone_points
)
zone_width_basis=mixed
```

If ATR is unavailable:

```text
zone_half_width_points = max(spread_points * 2, minimum_zone_points)
zone_width_basis=spread_minimum
zone_confidence=low
```

If spread is stale or missing:

```text
zone_width_status=degraded
cost_model_status=missing|stale
usable_distance_to_area_points=not_available
```

No layer may fake usable distance when spread/cost data is unavailable.

---

## Area range geometry

L22 can describe price position between nearest high/low areas without L23.

Fields:

```text
nearest_high_area_name
nearest_high_area_price
nearest_low_area_name
nearest_low_area_price
area_range_width_points
area_range_width_pips
area_range_width_atr
position_between_areas_pct
spread_to_area_range_ratio
geometry_state=near_upper_area|near_lower_area|middle_area|inside_area_zone|outside_area_range|unknown
```

Formula:

```text
area_range_width_points = (nearest_high_area_price - nearest_low_area_price) / point
position_between_areas_pct = ((mid_price - nearest_low_area_price) / (nearest_high_area_price - nearest_low_area_price)) * 100
```

Guard:

```text
if nearest_high_area_price <= nearest_low_area_price:
    area_range_width_points=not_available
    position_between_areas_pct=not_available
    geometry_state=unknown
```

L22 may show area geometry.

L22 must not call it setup validation.

---

## Board display standard

Board should remain trading-useful and compact. It should not show source layer plumbing.

Recommended Board wording:

```text
LAYER 22 - DEEP MARKET EVIDENCE
--------------------------------------------------
Status:                    Partial
Mode:                      Degraded Reference
Selected Symbols:           10
Evidence Freshness:         Mixed
Worst Issue:                VWAP / tick proxy not ready

Liquidity Areas Ready:      8 / 10
Risk Geometry Ready:        4 / 10
Value Context Ready:        0 / 10
Tick/DOM Proxy Ready:       0 / 10

Closest Area:               EURUSD near session high area
Area State:                 below zone, not touched
Spread-Aware Room:          partial
Cost Model:                 partial
Trade Permission:           FALSE
```

Board should not show:

```text
source contract versions
source layer names
raw formulas
raw DOM ladders
raw tick rows
full symbol list
```

Those belong in Workbench.

---

## Dossier display standard

Dossier should show trading context, not internal plumbing.

Recommended selected Dossier wording:

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

Dossier should not say:

```text
source_l18_status
source_l21_contract_version
L20 consumed
L21 consumed
```

Those are Workbench internals.

---

## Workbench/internal standard

Workbench must prove the measurement basis.

Required Workbench fields:

```text
source_l17_contract_version
source_l18_contract_version
source_l19_contract_version
source_l20_contract_version
source_l21_contract_version

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

oldest_source_age_seconds
newest_source_age_seconds
evidence_age_state

institutional_order_flow_claim=false
smart_money_claim=false
setup_confirmation=false
directional_forecast=false
trade_permission=false
entry_signal=false
execution=false
```

---

## Coding acceptance checklist

Before runtime code is accepted:

```text
Distances use points internally.
Pip display is symbol-aware.
Spread-adjusted usable room is printed separately from raw distance.
Cost model status/source are printed.
Area/zone width is printed with basis.
Distance-to-zone and distance-to-reference are not confused.
Board hides internal source plumbing.
Dossier shows trading context only.
Workbench proves formula/source/age/contract details.
No L22 fallback CopyTicks.
No L22 fallback CopyRates.
No indicators added to L22.
No directional or setup claim.
No permission claim.
```

## Decision

```text
TEST FIRST
```
