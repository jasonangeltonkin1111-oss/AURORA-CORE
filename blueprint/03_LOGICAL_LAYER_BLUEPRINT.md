# AURORA CORE — LOGICAL LAYER BLUEPRINT

**System:** AURORA CORE  
**Role:** Logical layer map under Runtime Owners, layer sequencing, layer contracts, build dependencies, and anti-fragmentation structure.  
**Status:** DETAILED BLUEPRINT — required before MT5 source implementation starts.

---

## 0. Purpose

This blueprint defines the 23 logical layers of AURORA CORE and maps them under the permanent Runtime Owners.

Logical layers are responsibilities, not independent engines.

Core law:

```text
Layers organize truth.
Runtime Owners own truth.
Source implementation must build the smallest layer slice that can be tested.
```

---

## 1. Research Foundation

Layered architecture separates responsibilities so each layer has a defined role and dependency direction. This reduces uncontrolled coupling, but layered systems can also become slow or bloated if every layer becomes a heavy runtime component.

Reference:

```text
https://en.wikipedia.org/wiki/Multitier_architecture
```

MQL5 runtime constraints make this practical, not decorative. `OnTimer()` events are not queued if a previous Timer event is already queued or processing, so heavy or poorly ordered layer work can silently drop cadence.

Reference:

```text
https://www.mql5.com/en/docs/event_handlers/ontimer
```

Aurora translation:

```text
Layers must be lane-aware.
Layers must expose partial/degraded states.
Layers must not become blocking monoliths inside OnTimer.
```

---

## 2. What This Blueprint Owns

This blueprint owns:

```text
23 logical layer map
Runtime Owner to layer mapping
layer purpose
layer inputs
layer outputs
layer dependencies
layer degraded states
layer build order
foundation-first layer sequence
source-start boundary
```

---

## 3. What This Blueprint Must Not Own

This blueprint must not own:

```text
full guidebook doctrine
formula math
final MQL5 code
final file routes
trading permission
edge validation results
```

---

## 4. Layer State Vocabulary

Every layer should use common states:

```text
not_started
shell_printed
filling
partial
complete
complete_with_degraded
stale
blocked
failed
unavailable
```

Layer state must distinguish:

```text
physical publication state
review permission state
trade permission state
evidence completeness state
```

---

## 5. Foundation Truth Owner Layers

### Layer 1 — Account / Portfolio / Prop Rule Truth

Purpose:

```text
Expose account identity, balance/equity/margin context, open/pending exposure summary, and prop-rule profile status.
```

Primary inputs later:

```text
AccountInfoInteger / AccountInfoDouble / AccountInfoString
PositionsTotal / OrdersTotal later if exposure is included
manual or configured prop-rule profile later
```

Primary outputs:

```text
account_status
account_currency
balance
equity
margin
free_margin
margin_level
open_position_count
pending_order_count
prop_rule_status
risk_state
```

Degraded states:

```text
account_unavailable
terminal_disconnected
prop_rule_unknown
exposure_partial
```

Layer 1 is the first coding target.

### Layer 2 — Market Open / Closed Truth

Purpose:

```text
Classify symbols as open, closed, unknown, or unavailable using broker/session data and quote freshness.
```

Inputs later:

```text
SymbolInfoSessionTrade / SymbolInfoSessionQuote
SymbolInfoInteger trade mode
SymbolInfoTick time
symbol selected/synchronized state
```

Outputs:

```text
symbol_market_state
session_known
session_time_basis
open_closed_unknown
market_state_reason
```

Degraded states:

```text
session_unknown
trade_mode_unknown
quote_stale
symbol_not_synchronized
```

### Layer 3 — Symbol + Broker Specs Truth

Purpose:

```text
Expose symbol contract/specification truth required for later filtering, scoring, and safety.
```

Inputs later:

```text
SymbolInfoInteger
SymbolInfoDouble
SymbolInfoString
SymbolInfoMarginRate
```

Outputs:

```text
digits
point
contract_size
volume_min
volume_max
volume_step
spread_float
trade_mode
calc_mode
margin_initial_or_rate_status
spec_complete_state
```

Degraded states:

```text
spec_missing
property_unavailable
symbol_not_selected
symbol_unknown
```

### Layer 4 — Market Watch Truth

Purpose:

```text
Expose current bid/ask/last/spread/tick-time truth for broad symbols.
```

Inputs later:

```text
SymbolInfoTick
```

Outputs:

```text
bid
ask
last
spread_points
spread_zero_flag
tick_time
tick_age_seconds
quote_freshness_state
```

Degraded states:

```text
quote_missing
quote_stale
zero_spread_fresh
zero_spread_stale
```

Zero spread is not automatically invalid.

### Layer 5 — Basic System Gate

Purpose:

```text
Create one simple eligibility/degradation gate from Foundation truth.
```

Inputs:

```text
Layer 1 account/risk state
Layer 2 market state
Layer 3 broker specs
Layer 4 quote truth
```

Outputs:

```text
basic_gate_status
eligible_for_ranking
foundation_block_reasons
foundation_degraded_reasons
```

Must not own:

```text
strategy filters
indicator rules
edge claims
```

---

## 6. Surface Scoring Owner Layers

### Layer 6 — Surface Cost / Friction Ranking

Ranks eligible symbols by relative cost/friction.

Must remain descriptive.

### Layer 7 — Session Relevance Ranking

Ranks symbols by session relevance and availability context.

Must label session time basis honestly.

### Layer 8 — Surface Movement / Range Ranking

Ranks symbols by broad movement/range context.

Must not imply breakout or direction.

### Layer 9 — Surface Structure / Location Geometry

Captures simple structural/location context.

Must not become setup logic.

---

## 7. Bucket Intelligence Owner Layers

### Layer 10 — Broker Bucket Classification

Maps symbols into honest broker group/subgroup/aggregation groups.

Unknown is allowed.

Fake Other is corruption.

### Layer 11 — Symbol Ranking Inside Buckets

Ranks alternatives inside their own bucket.

### Layer 12 — Bucket Heat / Bucket Quality Ranking

Ranks bucket-level quality/heat.

### Layer 13 — Dynamic Top Bucket Selection

Selects buckets worth attention.

### Layer 14 — Bucket Leader Candidate Pool

Builds candidate pool from bucket leaders.

Must not skip bucket structure and sort all symbols blindly.

---

## 8. Basket Selection Owner Layers

### Layer 15 — Correlation / Diversity Selection

Controls concentration and overlap.

Correlation requires sample/window/confidence labels.

### Layer 16 — Global Top 10 Builder

Builds diversified inspection basket.

Global Top 10 is not a trade list.

---

## 9. Selected Evidence Owner Layers

### Layer 17 — Deep Evidence Selection Split

Determines which selected symbols receive expensive evidence.

### Layer 18 — Selected Raw OHLC Bar Pack

Collects selected-symbol OHLC data only.

### Layer 19 — Selected Wick / Candle Geometry Pack

Derives candle geometry from OHLC truth.

### Layer 20 — Selected Rolling Tick Pack

Collects or summarizes selected-symbol rolling tick evidence.

`CopyTicks()` can trigger local tick database synchronization and download missing ticks; it must be selected/deep lane only.

Reference:

```text
https://www.mql5.com/en/docs/series/copyticks
```

### Layer 21 — Selected Indicator / Reference Pack

Collects indicator/reference context.

Indicator context is not signal permission.

### Layer 22 — Deep Market Evidence / Liquidity / MT5 Order-Flow Proxy Pack

Uses MT5 tick/DOM proxy evidence when available.

DOM must be availability-gated and labelled proxy.

---

## 10. Permission / Alert Owner Layer

### Layer 23 — Setup / Strategy / Permission / Alert State

Purpose:

```text
Expose what is allowed, blocked, quarantined, suppressed, or unavailable.
```

Default:

```text
setup strategy = QUARANTINE
directional alerts = HOLD
auto-trading = BLOCKED
trade permission = false
```

Layer 23 may not activate trading from ranking/evidence alone.

---

## 11. Layer Dependency Direction

Dependency direction:

```text
Foundation → Surface Scoring → Bucket Intelligence → Basket Selection → Selected Evidence → Permission / Alert → Publication / Governance
```

Publication and Governance consume outputs across layers.

They do not secretly own layer truth.

Validation consumes outcomes later.

It does not grant permission directly.

---

## 12. Layer Output Contract Shape

Every layer should eventually expose:

```text
layer_id
layer_name
owner_id
cycle_id
heartbeat_id
status
freshness_state
complete_count
partial_count
degraded_count
blocked_count
failed_count
primary_output_available
source_owner
source_snapshot_hash_if_relevant
degraded_reasons
blocked_reasons
```

---

## 13. First Source Slice Boundary

First source slice:

```text
Runtime Owner: Foundation Truth Owner
Layer: Layer 1 — Account / Portfolio / Prop Rule Truth
Goal: publish account truth shell + degraded states + minimum governance proof
```

Layer 1 source must not include:

```text
symbol universe scanning
ranking
buckets
selection
deep evidence
alerts
strategy
external worker
```

---

## 14. Acceptance Criteria

This blueprint is acceptable if:

```text
All 23 logical layers are mapped.
Each layer belongs to one Runtime Owner.
Layer 1 is clear first source target.
Layer boundaries prevent 23-engine fragmentation.
Layer outputs use common status/freshness/degraded language.
Permission remains separate from ranking/evidence.
Publication remains separate from truth computation.
```

---

## 15. Final Logical Layer Law

```text
Twenty-three layers organize the river.
They do not become twenty-three boats.
Build Layer 1 first.
```