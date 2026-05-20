# AURORA CORE — LOGICAL LAYER BLUEPRINT

**System:** AURORA CORE  
**Role:** Logical layer map under Runtime Owners, Runtime 0 internal layer map, layer sequencing, layer contracts, build dependencies, and anti-fragmentation structure.  
**Status:** DETAILED BLUEPRINT — Runtime 0 first.

---

## 0. Purpose

This blueprint defines the logical layer structure of AURORA CORE.

It now separates:

```text
Runtime 0 internal-control layers
Runtime 1–8 market/system truth layers
```

Core law:

```text
Runtime 0 — Governance / Internal Control Owner comes before Layer 1 — Account / Portfolio / Prop Rule Truth.
Before Aurora knows the account or market, Aurora must prove it can start, breathe, create folders, write files, publish governance proof, and report failure.
```

---

## 1. Research Foundation

Layered architecture separates responsibilities so each layer has a defined role and dependency direction.

MQL5 runtime constraints make this practical, not decorative. `OnTimer()` events are not queued if a previous Timer event is already queued or processing, so heavy or poorly ordered layer work can silently drop cadence.

Reference:

```text
https://www.mql5.com/en/docs/event_handlers/ontimer
```

MQL5 FileIO is sandboxed and failure-prone enough that folder creation, temp/final writes, and proof rows must be proven before market/account truth layers depend on them.

References:

```text
https://www.mql5.com/en/docs/files/fileopen
https://www.mql5.com/en/docs/files/foldercreate
https://www.mql5.com/en/docs/files/filemove
https://www.mql5.com/en/docs/files/fileflush
```

Aurora translation:

```text
Runtime 0 must prove the EA body works before Runtime 1 starts proving account truth.
```

---

## 2. What This Blueprint Owns

This blueprint owns:

```text
Runtime 0 internal layer map
23 market/system logical layer map
Runtime Owner to layer mapping
layer purpose
layer inputs
layer outputs
layer dependencies
layer degraded states
layer build order
Runtime 0 first-source boundary
Layer 1 later-source boundary
```

---

## 3. Layer State Vocabulary

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

## 4. Runtime 0 — Governance / Internal Control Owner Layers

These are internal EA layers.

They are not trader-facing market layers.

### Layer 0.1 — Startup / Runtime Identity

Purpose:

```text
Prove the EA can initialize, name itself, expose build/runtime identity, and prepare the root runtime state.
```

Primary outputs:

```text
system_name
runtime_owner
build_phase
runtime_state
generated_at
terminal_context_state
route_label_state
```

Must not own:

```text
account truth beyond route labels
market truth
strategy logic
```

### Layer 0.2 — Scheduler / Heartbeat / Breathing Spine

Purpose:

```text
Prove timer setup, heartbeat count, timer duration, over-budget state, and basic breathing cadence.
```

Primary outputs:

```text
heartbeat_id
timer_started_at
timer_finished_at
timer_duration_ms
timer_budget_ms
over_budget_flag
breath_phase
```

Must not own:

```text
symbol scanning
ranking
heavy loops
```

### Layer 0.3 — Decision State and Runtime Modes

Purpose:

```text
Mirror runtime decision states and build modes inside the EA once needed.
```

First source note:

```text
Layer 0.3 may wait if the first source proof does not need a full decision-state mirror.
```

### Layer 0.4 — Governance / Manifest / Telemetry

Purpose:

```text
Prove that the EA can publish manifest rows, runtime telemetry rows, owner status rows, and layer status rows.
```

Primary outputs:

```text
manifest row
runtime telemetry row
Runtime 0 owner status row
Runtime 0 layer status rows
```

### Layer 0.5 — Diagnostics / Errors / Recovery

Purpose:

```text
Capture FileIO, folder, heartbeat, and runtime failures honestly.
```

First source note:

```text
Layer 0.5 may begin as simple Diagnostics.txt output rather than a full recovery engine.
```

---

## 5. Runtime 1 — Foundation Truth Owner Layers

Runtime 1 begins only after Runtime 0 proves startup, folder creation, FileIO, heartbeat, governance rows, and diagnostics.

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

Layer 1 — Account / Portfolio / Prop Rule Truth is the first Runtime 1 coding target, not the first overall EA source target.

### Layer 2 — Market Open / Closed Truth

Purpose:

```text
Classify symbols as open, closed, unknown, or unavailable using broker/session data and quote freshness.
```

### Layer 3 — Symbol + Broker Specs Truth

Purpose:

```text
Expose symbol contract/specification truth required for later filtering, scoring, and safety.
```

### Layer 4 — Market Watch Truth

Purpose:

```text
Expose current bid/ask/last/spread/tick-time truth for broad symbols.
```

Zero spread is not automatically invalid.

### Layer 5 — Basic System Gate

Purpose:

```text
Create one simple eligibility/degradation gate from Foundation truth.
```

---

## 6. Runtime 2 — Surface Scoring Owner Layers

### Layer 6 — Surface Cost / Friction Ranking
Ranks eligible symbols by relative cost/friction. Must remain descriptive.

### Layer 7 — Session Relevance Ranking
Ranks symbols by session relevance and availability context. Must label session time basis honestly.

### Layer 8 — Surface Movement / Range Ranking
Ranks symbols by broad movement/range context. Must not imply breakout or direction.

### Layer 9 — Surface Structure / Location Geometry
Captures simple structural/location context. Must not become setup logic.

---

## 7. Runtime 3 — Bucket Intelligence Owner Layers

### Layer 10 — Broker Bucket Classification
Maps symbols into honest broker group/subgroup/aggregation groups. Unknown is allowed.

### Layer 11 — Symbol Ranking Inside Buckets
Ranks alternatives inside their own bucket.

### Layer 12 — Bucket Heat / Bucket Quality Ranking
Ranks bucket-level quality/heat.

### Layer 13 — Dynamic Top Bucket Selection
Selects buckets worth attention.

### Layer 14 — Bucket Leader Candidate Pool
Builds candidate pool from bucket leaders.

---

## 8. Runtime 4 — Basket Selection Owner Layers

### Layer 15 — Correlation / Diversity Selection
Controls concentration and overlap.

### Layer 16 — Global Top 10 Builder
Builds diversified inspection basket. Global Top 10 is not a trade list.

---

## 9. Runtime 5 — Selected Evidence Owner Layers

### Layer 17 — Deep Evidence Selection Split
Determines which selected symbols receive expensive evidence.

### Layer 18 — Selected Raw OHLC Bar Pack
Collects selected-symbol OHLC data only.

### Layer 19 — Selected Wick / Candle Geometry Pack
Derives candle geometry from OHLC truth.

### Layer 20 — Selected Rolling Tick Pack
Collects or summarizes selected-symbol rolling tick evidence.

### Layer 21 — Selected Indicator / Reference Pack
Collects indicator/reference context.

### Layer 22 — Deep Market Evidence / Liquidity / MT5 Order-Flow Proxy Pack
Uses MT5 tick/DOM proxy evidence when available. DOM must be availability-gated and labelled proxy.

---

## 10. Runtime 6 — Permission / Alert Owner Layer

### Layer 23 — Setup / Strategy / Permission / Alert State

Default:

```text
setup strategy = QUARANTINE
directional alerts = HOLD
auto-trading = BLOCKED
trade permission = false
```

Layer 23 may not activate trading from ranking/evidence alone.

---

## 11. Dependency Direction

Correct first dependency chain:

```text
Runtime 0 internal control
→ Runtime 7 publication support
→ Runtime 1 Foundation Truth
→ Runtime 2 Surface Scoring
→ Runtime 3 Bucket Intelligence
→ Runtime 4 Basket Selection
→ Runtime 5 Selected Evidence
→ Runtime 6 Permission / Alert
→ Runtime 8 Validation / Outcome
```

Publication and Governance consume outputs across layers.

They do not secretly own layer truth.

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
Runtime Owner: Runtime 0 — Governance / Internal Control Owner
Internal Layers:
Layer 0.1 — Startup / Runtime Identity
Layer 0.2 — Scheduler / Heartbeat / Breathing Spine
Layer 0.4 — Governance / Manifest / Telemetry
Support: Runtime 7 — Publication Owner FileIO/routes only
Goal: prove folder creation, file writing, heartbeat, manifest, telemetry, status rows, and diagnostics
```

First source slice must not include:

```text
Layer 1 — Account / Portfolio / Prop Rule Truth except minimal account/server labels needed for account-safe routing
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
Runtime 0 internal layers are mapped.
Runtime 0 is the first source target.
Runtime 1 Layer 1 is held until Runtime 0 passes.
All 23 Runtime 1–8 logical layers are mapped.
Layer outputs use common status/freshness/degraded language.
Permission remains separate from ranking/evidence.
Publication remains separate from truth computation.
```

---

## 15. Final Logical Layer Law

```text
Runtime 0 builds the EA body.
Runtime 1 starts account truth after the body breathes and writes.
Twenty-three market/system layers organize the river after the internal spine exists.
```