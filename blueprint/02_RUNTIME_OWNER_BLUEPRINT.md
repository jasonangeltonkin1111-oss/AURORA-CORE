# AURORA CORE — RUNTIME OWNER BLUEPRINT

**System:** AURORA CORE  
**Role:** Permanent Runtime Owner map, authority boundary, source-of-truth ownership, layer grouping, build sequence anchor, and anti-fragmentation contract.  
**Status:** DETAILED BLUEPRINT — Runtime 0 first.

---

## 0. Purpose

This blueprint defines the permanent Runtime Owner structure for AURORA CORE.

Runtime Owners are the top-level architecture headers.

Logical layers live under Runtime Owners.

Core law:

```text
Runtime Owners own truth domains and internal runtime domains.
Logical layers are ordered responsibilities inside those owners.
Runtime 0 — Governance / Internal Control Owner comes before market/account truth layers.
No shadow owner may calculate or publish truth that belongs to another owner.
```

---

## 1. Research Foundation

Software architecture is the high-level structure of a system: elements, relationships, and properties needed to reason about behavior before building.

Single-source-of-truth practice means each data element should be mastered in only one place, with other views referencing or consuming it rather than becoming independent editors.

MQL5 `OnTimer()` documentation confirms a practical runtime constraint: each program has one timer, and if a Timer event is already queued or processing, a new Timer event is not added. Runtime 0 must therefore prove heartbeat/breathing behavior before heavier owners are added.

Reference:

```text
https://www.mql5.com/en/docs/event_handlers/ontimer
```

MQL5 file operations are sandboxed, folder creation and file writing can fail, and publication must therefore be proven before downstream truth layers rely on it.

References:

```text
https://www.mql5.com/en/docs/files/fileopen
https://www.mql5.com/en/docs/files/foldercreate
https://www.mql5.com/en/docs/files/filemove
https://www.mql5.com/en/docs/files/fileflush
```

Aurora translation:

```text
Before Aurora knows the account or market, Aurora must prove it can create its home, breathe, write files, and report failure.
```

---

## 2. What This Blueprint Owns

This blueprint owns:

```text
permanent Runtime Owner list
Runtime 0 internal-control ownership
owner responsibilities
owner forbidden responsibilities
owner input/output contract shape
owner publication relationship
owner governance relationship
owner build order
owner failure/degraded state contract
owner interaction rules
Runtime 0 first-source boundary
Runtime 1 Layer 1 later-source boundary
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

Source implementation comes later, Runtime Owner by Runtime Owner.

---

## 4. Permanent Runtime Owners

The permanent Runtime Owners are:

```text
0. Governance / Internal Control Owner
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

## 5. Runtime 0 — Governance / Internal Control Owner

### Owns

```text
Layer 0.1 — Startup / Runtime Identity
Layer 0.2 — Scheduler / Heartbeat / Breathing Spine
Layer 0.3 — Decision State and Runtime Modes
Layer 0.4 — Governance / Manifest / Telemetry
Layer 0.5 — Diagnostics / Errors / Recovery
```

### Mission

Runtime 0 answers:

```text
Can the EA start, identify itself, create its account-safe home, heartbeat, publish internal proof, write diagnostics, and report failure honestly?
```

### May own

```text
startup identity
runtime mode
scheduler / heartbeat / breathing spine
decision-state mirror
governance row helpers
manifest row helpers
runtime telemetry helpers
diagnostics / error capture
schema/version constants
internal recovery state
source-start proof controls
```

### Must not own

```text
account truth
symbol truth
quote truth
score truth
bucket truth
selection truth
deep evidence truth
permission truth
trade execution
strategy logic
operator-facing market meaning
```

### Runtime 0 coding rule

Runtime 0 is the first real coding target.

Runtime 0 must prove folder creation, FileIO, heartbeat, manifest, telemetry, Runtime 0 owner status, Runtime 0 layer status, and diagnostics before Runtime 1 source begins.

---

## 6. Runtime 1 — Foundation Truth Owner

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

### Must not own

```text
surface ranking formulas
bucket selection
deep evidence
publication routes
trade permission
strategy signals
Runtime 0 heartbeat/FileIO/governance proof
```

### Foundation coding rule

Runtime 1 starts only after Runtime 0 passes compile and runtime smoke.

First Runtime 1 target later:

```text
Layer 1 — Account / Portfolio / Prop Rule Truth
```

Layer 1 does not mean all Runtime 1 layers at once.

---

## 7. Runtime 2 — Surface Scoring Owner

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

## 8. Runtime 3 — Bucket Intelligence Owner

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

Taxonomy unknowns must remain honest unknowns, not fake `Other`.

---

## 9. Runtime 4 — Basket Selection Owner

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

Global Top 10 is an inspection basket only.

---

## 10. Runtime 5 — Selected Evidence Owner

### Owns

```text
Layer 17 — Deep Evidence Selection Split
Layer 18 — Selected Raw OHLC Bar Pack
Layer 19 — Selected Wick / Candle Geometry Pack
Layer 20 — Selected Rolling Tick Pack
Layer 21 — Selected Indicator / Reference Pack
Layer 22 — Deep Market Evidence / Liquidity / MT5 Order-Flow Proxy Pack
```

Selected evidence is expensive and must stay selected-only.

---

## 11. Runtime 6 — Permission / Alert Owner

### Owns

```text
Layer 23 — Setup / Strategy / Permission / Alert State
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

## 12. Runtime 7 — Publication Owner

### Owns

```text
physical publication
FileIO
routes
surfaces
manifest proof
atomic update overview later
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

Runtime 7 support is allowed in the first source slice because Runtime 0 cannot prove folder creation or file writing without Publication Owner support.

Runtime 7 must not compute source truth.

---

## 13. Runtime 8 — Validation / Outcome Owner

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

Validation may recommend.

Permission decides.

---

## 14. Runtime Owner Interaction Rules

Owners may consume upstream truth.

Owners may not secretly recreate upstream truth.

Allowed pattern:

```text
Runtime 0 publishes runtime heartbeat and governance proof.
Runtime 7 physically writes and proves outputs.
Runtime 1 consumes working Runtime 0 / Runtime 7 publication support before account truth begins.
Surface Scoring consumes Foundation truth later.
Publication prints owner outputs.
Governance records proof.
```

Forbidden pattern:

```text
Runtime 1 recreates FileIO ownership.
Board computes Global Top 10.
Dossier recalculates scores.
External worker decides permission.
Publication Owner invents source truth.
Validation Owner grants trade permission directly.
```

---

## 15. Owner Output Contract Shape

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

## 16. Owner Failure States

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

## 17. Build Order

Correct build order:

```text
1. Runtime 0 — Governance / Internal Control Owner
2. Runtime 7 — Publication Owner support needed by Runtime 0
3. Runtime 1 — Foundation Truth Owner / Layer 1 — Account / Portfolio / Prop Rule Truth
4. Runtime 1 — Foundation Truth Owner / Layers 2–5 one by one
5. Runtime 2 onward only after Foundation truth works
```

Do not build all owners at once.

Do not build all Runtime 0 layers if not needed for the first proof.

---

## 18. Acceptance Criteria

This blueprint is acceptable if:

```text
Runtime 0 is defined.
All Runtime Owners 0–8 are defined.
Runtime 0 is clearly first source target.
Runtime 7 publication support is allowed only for FileIO/route proof.
Runtime 1 Layer 1 is held until Runtime 0 passes.
Each owner has forbidden responsibilities.
No owner can become a shadow owner.
```

---

## 19. Final Runtime Owner Law

```text
Before Aurora knows the account or market, Aurora must prove it can breathe, create its home, write, and report failure.
Runtime 0 first. Runtime 1 second.
No shadow owners.
```