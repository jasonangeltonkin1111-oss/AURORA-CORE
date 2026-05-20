# AURORA CORE — LOGICAL LAYER BLUEPRINT

**System:** AURORA CORE  
**Status:** Canonical logical-layer map.  
**Purpose:** Prevent Runtime Owner numbers from being confused with Logical Layer numbers.

---

## 0. Core distinction

Aurora has two numbering systems:

```text
Runtime Owner numbers = ownership / module domains.
Logical Layer numbers = market/system build sequence.
```

These are not interchangeable.

Example:

```text
Runtime 7 = Publication Owner.
Layer 7 = Session Relevance Ranking.
```

Runtime 7 may exist early as support for Runtime 0 because files/routes/publication are needed before any market truth can be printed.

Layer 7 must not be built before Layers 2–6 are built and proven.

---

## 1. Runtime 0 internal-control layers

Runtime 0 builds the EA body first.

```text
Layer 0.1 — Startup / Runtime Identity
Layer 0.2 — Scheduler / Heartbeat / Breathing Spine
Layer 0.3 — Decision State and Runtime Modes
Layer 0.4 — Governance / Manifest / Telemetry
Layer 0.5 — Diagnostics / Errors / Recovery
```

Runtime 0 comes before market/account truth because the EA must prove it can start, breathe, create folders, write files, publish governance proof, and report failure.

---

## 2. Runtime 1 — Foundation Truth Owner

```text
Layer 1 — Account / Portfolio / Prop Rule Truth
Layer 2 — Market Open / Closed Truth
Layer 3 — Symbol + Broker Specs Truth
Layer 4 — Market Watch Truth
Layer 5 — Basic System Gate
```

Layer meanings:

```text
Layer 1 = account identity, balance/equity/margin, exposure, prop-rule status
Layer 2 = classify symbols open/closed/unknown/unavailable using broker/session data and quote freshness
Layer 3 = symbol contract/specification truth required for filtering, scoring, and safety
Layer 4 = bid/ask/last/spread/tick-time Market Watch truth
Layer 5 = simple eligibility/degradation gate from Foundation truth
```

Important placement:

```text
Fundamental research links belong with the Layer 2 direction because they help verify market/symbol identity and bucket truth, but they do not overwrite broker/session truth.
Broker specs belong to Layer 3.
Market Watch belongs to Layer 4.
Calculation mode belongs inside or under Layer 3 spec truth / spec-validation, with heavy calculations delegated to the proper calculation worker/owner.
```

---

## 3. Runtime 2 — Surface Scoring Owner

```text
Layer 6 — Surface Cost / Friction Ranking
Layer 7 — Session Relevance Ranking
Layer 8 — Surface Movement / Range Ranking
Layer 9 — Surface Structure / Location Geometry
```

These layers must not be built before Runtime 1 Foundation Truth layers are ready enough to feed them.

Layer 7 is not Runtime 7.

---

## 4. Runtime 3 — Bucket Intelligence Owner

```text
Layer 10 — Broker Bucket Classification
Layer 11 — Symbol Ranking Inside Buckets
Layer 12 — Bucket Heat / Bucket Quality Ranking
Layer 13 — Dynamic Top Bucket Selection
Layer 14 — Bucket Leader Candidate Pool
```

Bucket work depends on earlier account/session/spec/Market Watch/eligibility truth.

---

## 5. Runtime 4 — Basket Selection Owner

```text
Layer 15 — Correlation / Diversity Selection
Layer 16 — Global Top 10 Builder
```

Global Top 10 is an inspection basket, not a trade list.

---

## 6. Runtime 5 — Selected Evidence Owner

```text
Layer 17 — Deep Evidence Selection Split
Layer 18 — Selected Raw OHLC Bar Pack
Layer 19 — Selected Wick / Candle Geometry Pack
Layer 20 — Selected Rolling Tick Pack
Layer 21 — Selected Indicator / Reference Pack
Layer 22 — Deep Market Evidence / Liquidity / MT5 Order-Flow Proxy Pack
```

DOM / Depth of Market belongs here later as bounded MT5 order-flow proxy evidence.

DOM must be availability-gated, labelled proxy, and never full-universe event spam.

---

## 7. Runtime 6 — Permission / Alert Owner

```text
Layer 23 — Setup / Strategy / Permission / Alert State
```

Default:

```text
setup_strategy=QUARANTINE
directional_alerts=HOLD
auto_trading=BLOCKED
trade_permission=false
```

Layer 23 may not activate trading from ranking/evidence alone.

---

## 8. Runtime 7 — Publication support

Runtime 7 owns publication support:

```text
routes
folder creation
FileIO
manifest/status publication support
```

Runtime 7 is allowed early because Runtime 0 needs publication support to prove files and diagnostics.

Runtime 7 does not mean Logical Layer 7 is complete.

Publication consumes layer outputs. It does not secretly own layer truth.

---

## 9. Dependency direction

Correct dependency chain:

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

Runtime 7 publication support appears early only as infrastructure.

Logical market/system layers must still be built in order.

---

## 10. Layer state vocabulary

Every layer should eventually use common states:

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

## 11. Final law

```text
Runtime 0 builds the EA body.
Runtime 7 supports publication early.
Runtime 1 starts account and foundation truth after the body breathes and writes.
Logical Layers 1–23 still move in order.
Runtime Owner numbers are not Logical Layer numbers.
```
