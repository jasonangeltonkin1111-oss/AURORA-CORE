# AURORA CORE — RUNTIME OWNER BLUEPRINT

**System:** AURORA CORE  
**Role:** Permanent Runtime Owner map, authority boundary, source-of-truth ownership, layer grouping, build sequence anchor, and anti-23-engine fragmentation contract.  
**Status:** DETAILED BLUEPRINT — required before MT5 source implementation starts.

---

## 0. Purpose

This blueprint defines the permanent Runtime Owner structure for AURORA CORE.

Runtime Owners are the top-level architecture headers.

Logical layers live under Runtime Owners.

The 23 logical layers are not 23 engines, not 23 schedulers, and not 23 independent source-of-truth systems.

Core law:

```text
Runtime Owners own truth domains.
Logical layers are ordered responsibilities inside those owners.
No shadow owner may calculate or publish truth that belongs to another owner.
```

---

## 1. Research Foundation

This blueprint converts the overview guidebooks into implementation-facing architecture.

Software architecture is the high-level structure of a system: elements, relationships, and properties needed to reason about behavior before building. Architecture decisions become costly to change after implementation, so Aurora must lock owner boundaries before source work.

Reference:

```text
https://en.wikipedia.org/wiki/Software_architecture
```

Single-source-of-truth practice means each data element should be mastered in only one place, with other views referencing or consuming it rather than becoming independent editors.

Reference:

```text
https://en.wikipedia.org/wiki/Single_source_of_truth
```

MQL5 `OnTimer()` documentation confirms a practical runtime constraint: each program has one timer, and if a Timer event is already queued or processing, a new Timer event is not added. That means Runtime Owners must be lane/budget aware; long owner work can silently destroy cadence.

Reference:

```text
https://www.mql5.com/en/docs/event_handlers/ontimer
```

Aurora translation:

```text
Owners must be bounded.
Owners must publish degraded state instead of blocking outputs.
Owners must not hide long work inside OnTimer.
```

---

## 2. What This Blueprint Owns

This blueprint owns:

```text
permanent Runtime Owner list
owner responsibilities
owner forbidden responsibilities
owner input/output contract shape
owner publication relationship
owner governance relationship
owner build order
owner failure/degraded state contract
owner interaction rules
foundation-first coding boundary
```

---

## 3. What This Blueprint Must Not Own

This blueprint must not own:

```text
full guidebook doctrine
exact MQL5 implementation code
formula math
final file paths
runtime-generated outputs
trading permission
strategy edge claims
external worker implementation
```

Detailed doctrine remains in `docs/`.

Source implementation comes later, layer by layer.

---

## 4. Permanent Runtime Owners

The permanent Runtime Owners are:

```text
1. Foundation Truth Owner
2. Surface Scoring Owner
3. Bucket Intelligence Owner
4. Basket Selection Owner
5. Selected Evidence Owner
6. Permission / Alert Owner
7. Publication Owner
8. Validation / Outcome Owner
```

These are the enduring top-level architecture headers.

They may be refined internally, but they must not be casually replaced or duplicated.

---

## 5. Owner 1 — Foundation Truth Owner

### Owns

```text
Layer 1 — Account / Portfolio / Prop Rule Truth
Layer 2 — Market Open / Closed Truth
Layer 3 — Symbol + Broker Specs Truth
Layer 4 — Market Watch Truth
Layer 5 — Basic System Gate
```

### Mission

Foundation Truth Owner answers:

```text
What account exists?
What broker/server/symbol universe exists?
What is open, closed, selected, synchronized, fresh, stale, missing, tradable, or blocked?
```

### MT5 source families later

```text
AccountInfoInteger / AccountInfoDouble / AccountInfoString
TerminalInfo*
SymbolsTotal / SymbolName / SymbolSelect / SymbolIsSynchronized
SymbolInfoInteger / SymbolInfoDouble / SymbolInfoString
SymbolInfoTick
SymbolInfoSessionTrade / SymbolInfoSessionQuote
SymbolInfoMarginRate
OrderCalcMargin / OrderCalcProfit later for margin/profit facts
```

### Research anchors

`SymbolInfoTick()` returns current prices in `MqlTick`, including time of the last price update. This supports quote freshness, but it does not prove full tick history.

```text
https://www.mql5.com/en/docs/marketinformation/symbolinfotick
```

`SymbolInfoSessionTrade()` returns beginning/end times for symbol sessions, with the returned date ignored because the values are seconds from midnight. This means Aurora must label session time basis honestly.

```text
https://www.mql5.com/en/docs/marketinformation/symbolinfosessiontrade
```

`SymbolInfoInteger()` returns symbol properties and exposes errors such as unknown symbol, not selected in Market Watch, and invalid property id. This creates explicit failure states.

```text
https://www.mql5.com/en/docs/marketinformation/symbolinfointeger
```

### Must not own

```text
surface ranking formulas
bucket selection
deep evidence
publication routes
trade permission
strategy signals
```

### Foundation coding rule

Foundation is the first real coding target after the planned-system contract gate.

But Foundation must start with Layer 1 only.

Layer 1 does not mean all Foundation layers at once.

---

## 6. Owner 2 — Surface Scoring Owner

### Owns

```text
Layer 6 — Surface Cost / Friction Ranking
Layer 7 — Session Relevance Ranking
Layer 8 — Surface Movement / Range Ranking
Layer 9 — Surface Structure / Location Geometry
```

### Mission

Surface Scoring Owner answers:

```text
Which eligible symbols are relatively cheaper, more active, more relevant, and more worth inspection?
```

### Must not claim

```text
direction
expectancy
edge
setup validity
trade permission
```

All scores are descriptive until Validation / Outcome evidence proves otherwise.

---

## 7. Owner 3 — Bucket Intelligence Owner

### Owns

```text
Layer 10 — Broker Bucket Classification
Layer 11 — Symbol Ranking Inside Buckets
Layer 12 — Bucket Heat / Bucket Quality Ranking
Layer 13 — Dynamic Top Bucket Selection
Layer 14 — Bucket Leader Candidate Pool
```

### Mission

Bucket Intelligence Owner answers:

```text
What kind of symbol is this?
Which bucket/sub-bucket/aggregation group owns it?
Which symbols lead inside their own categories?
Which buckets deserve attention now?
```

### Must not own

```text
Global Top 10 final basket
trade permission
deep evidence
strategy setup
```

Taxonomy unknowns must remain honest unknowns, not fake `Other`.

---

## 8. Owner 4 — Basket Selection Owner

### Owns

```text
Layer 15 — Correlation / Diversity Selection
Layer 16 — Global Top 10 Builder
```

### Mission

Basket Selection Owner answers:

```text
Which bucket leaders form a diversified inspection basket?
Which candidates were rejected due to overlap/correlation?
Which backup fills were used?
```

### Must not claim

```text
best trades
buy/sell list
edge
permission
```

Global Top 10 is an inspection basket only.

---

## 9. Owner 5 — Selected Evidence Owner

### Owns

```text
Layer 17 — Deep Evidence Selection Split
Layer 18 — Selected Raw OHLC Bar Pack
Layer 19 — Selected Wick / Candle Geometry Pack
Layer 20 — Selected Rolling Tick Pack
Layer 21 — Selected Indicator / Reference Pack
Layer 22 — Deep Market Evidence / Liquidity / MT5 Order-Flow Proxy Pack
```

### Mission

Selected Evidence Owner answers:

```text
What deeper evidence exists for selected symbols only?
What is complete, partial, stale, unavailable, failed, or waiting on dependency?
```

### Must not own

```text
all-symbol deep evidence
strategy confirmation
trade permission
true order-flow claims
```

Selected evidence is expensive and must stay selected-only.

---

## 10. Owner 6 — Permission / Alert Owner

### Owns

```text
Layer 23 — Setup / Strategy / Permission / Alert State
```

### Mission

Permission / Alert Owner answers:

```text
What is allowed?
What is blocked?
What alert class may fire?
What must stay suppressed?
What prop/risk/news states block permission?
```

### Default state

```text
Class 1 system/risk/integrity alerts: allowed when actionable
Class 2 setup alerts: HOLD
Directional alerts: HOLD
Auto-trading: BLOCKED
Trade permission: false
```

Permission consumes proof.

Permission does not create proof.

---

## 11. Owner 7 — Publication Owner

### Owns

```text
Board publication
Dossier publication
Selection Desk publication later
Governance publication
Manifest proof
Atomic Update Overview
FileIO route ownership later
```

### Mission

Publication Owner answers:

```text
What was physically printed?
Where was it printed?
Was it clean, partial, degraded, stale, or failed?
```

Core law:

```text
Broken truth may block review/trading.
Broken truth must not block printing.
```

### MT5 file research anchors

`FileOpen()` is sandboxed; MQL5 file operations cannot write outside the file sandbox, and `FILE_COMMON` places files in the shared terminal common folder.

```text
https://www.mql5.com/en/docs/files/fileopen
```

`FileMove()` needs `FILE_REWRITE` if the destination already exists; otherwise the move fails.

```text
https://www.mql5.com/en/docs/files/filemove
```

`FileFlush()` forces buffered data to disk, but frequent calls can affect program speed.

```text
https://www.mql5.com/en/docs/files/fileflush
```

---

## 12. Owner 8 — Validation / Outcome Owner

### Owns

```text
hypothesis registry
experiment registry
outcome ledger
null model comparison
cost/spread/slippage model
regime/session tagging
promotion/kill conditions
```

### Mission

Validation / Outcome Owner answers:

```text
Did any score, selection rule, setup, or evidence pack survive falsification after costs and null comparison?
```

Core law:

```text
Architecture is not edge.
No null model, no validation.
No cost model, no validation.
```

Validation may recommend.

Permission decides.

---

## 13. Runtime Owner Interaction Rules

Owners may consume upstream truth.

Owners may not secretly recreate upstream truth.

Allowed pattern:

```text
Foundation Truth Owner publishes quote freshness.
Surface Scoring Owner consumes quote freshness.
Basket Selection Owner consumes bucket leaders.
Selected Evidence Owner consumes Global Top 10 feed.
Publication Owner prints owner outputs.
Governance records proof.
```

Forbidden pattern:

```text
Board computes Global Top 10.
Dossier recalculates scores.
External worker decides permission.
Publication Owner invents source truth.
Validation Owner grants trade permission directly.
```

---

## 14. Owner Output Contract Shape

Every owner output should eventually expose:

```text
owner_id
owner_name
cycle_id
heartbeat_id
status
freshness_state
last_success_at
complete_count
partial_count
degraded_count
blocked_count
failed_count
primary_output_available
publication_allowed
review_allowed_if_relevant
trade_allowed_if_relevant
source_snapshot_hash_if_relevant
degraded_reasons
blocked_reasons
```

---

## 15. Owner Failure States

Common owner states:

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

A failed owner must not make expected files disappear unless physical FileIO/route/source-object failure is proven.

---

## 16. Foundation-First Build Rule

The first source implementation must begin under Foundation Truth Owner.

Foundation build sequence:

```text
Layer 1 first: Account / Portfolio / Prop Rule Truth shell
then Layer 2: Market Open / Closed Truth
then Layer 3: Symbol + Broker Specs Truth
then Layer 4: Market Watch Truth
then Layer 5: Basic System Gate
```

Do not build all five Foundation layers at once.

Do not build scoring, buckets, selection, alerts, external worker, or strategy before Foundation truth exists.

---

## 17. Acceptance Criteria

This blueprint is acceptable if:

```text
All 8 Runtime Owners are defined.
Each owner has owned layers.
Each owner has forbidden responsibilities.
Foundation is clearly first coding target.
Layer 1 is clearly first source slice.
Publication is separated from permission.
Validation is separated from permission.
External worker cannot become an owner of broker truth.
No owner can become a shadow owner.
```

---

## 18. Final Runtime Owner Law

```text
One truth spine.
Eight owners.
Twenty-three logical layers.
Build Foundation first.
No shadow owners.
```
