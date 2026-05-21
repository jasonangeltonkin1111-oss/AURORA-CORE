# AURORA CORE — LOGICAL LAYER BLUEPRINT

**System:** AURORA CORE  
**Role:** Active logical layer map and dependency order.  
**Status:** DETAILED BLUEPRINT — consistency-repaired.

## 0. Purpose
Defines logical layers under Trading/System Truth Owners, plus required System Service support boundaries.

## 1. Layer State Vocabulary
- not_started
- shell_printed
- filling
- partial
- complete
- complete_with_degraded
- stale
- blocked
- failed
- unavailable

## 2. System Service Support (non-trading truth)
- Runtime 0 internal control support: startup identity, heartbeat, scheduler health, diagnostics.
- Publication / FileIO / Route Service support: physical writes and route verification.
- Render/proof services (Board/Dossier/Governance/Workbench) consume truth; they do not compute owner truth.

Implementation-state note:
- Current source may still use folder name `runtime_7_publication_owner`.
- This is source inheritance, not logical architecture ownership.

## 3. Trading/System Truth Layers
### Runtime 1 — Foundation Truth Owner
- Layer 1 — Account / Portfolio / Prop Rule Truth
- Layer 2 — Market Open / Closed Truth
- Layer 3 — Symbol + Broker Specs Truth
- Layer 4 — Market Watch Truth
- Layer 5 — Basic System Gate

### Runtime 2 — Surface Scoring Owner
- Layer 6 — Surface Cost / Friction Ranking
- Layer 7 — Session Relevance Ranking
- Layer 8 — Surface Movement / Range Ranking
- Layer 9 — Surface Structure / Location Geometry

### Runtime 3 — Taxonomy / Ranking Group Owner Layers
- Layer 10 — Taxonomy Classification
- Layer 11 — Symbol Ranking Inside Ranking Group
- Layer 12 — Ranking Group Heat / Quality Ranking
- Layer 13 — Dynamic Ranking Group Selection
- Layer 14 — Ranking Group Leader Candidate Pool

Mission focus:
- Which `asset_class`, `market_group`, `market_segment`, and `ranking_group` describe each symbol?
- Which ranking_group leaders deserve inspection attention?

### Runtime 4 — Basket Selection Owner
- Layer 15 — Correlation / Diversity Selection
- Layer 16 — Global Top 10 Builder (diversified inspection basket, not trade list)

Mission focus:
- Which ranking_group leaders form a diversified inspection basket?

### Runtime 5 — Selected Evidence Owner
- Layer 17 — Deep Evidence Selection Split
- Layer 18 — Selected Raw OHLC Bar Pack
- Layer 19 — Selected Wick / Candle Geometry Pack
- Layer 20 — Selected Rolling Tick Pack
- Layer 21 — Selected Indicator / Reference Pack
- Layer 22 — Deep Market Evidence / Liquidity / MT5 Order-Flow Proxy Pack

### Runtime 6 — Permission / Alert Owner
- Layer 23 — Setup / Strategy / Permission / Alert State

### Runtime 7 — Validation / Outcome Owner
- Outcome and falsification tracking across experiments, regimes, and cost-aware comparisons.

## 4. Dependency Direction
Runtime 0 internal control
→ Publication / FileIO / Route Service support
→ Runtime 1 Foundation Truth
→ Runtime 2 Surface Scoring
→ Runtime 3 Taxonomy / Ranking Group
→ Runtime 4 Basket Selection
→ Runtime 5 Selected Evidence
→ Runtime 6 Permission / Alert
→ Runtime 7 Validation / Outcome

## 5. First Source Slice Boundary
First slice:
- Runtime 0 internal control support
- Support: Publication / FileIO / Route Service only
- Goal: prove startup, heartbeat, file publication paths, and status visibility

First slice must not imply ranking/selection/permission truth completion.

## 6. No-Go Rules
- Do not treat Board/Dossier/Publication/Governance/Workbench as trading truth owners.
- Do not convert descriptive ranking outputs into trade permission.
- Do not claim runtime or trading proof from architecture text alone.

## 7. Acceptance Criteria
Acceptable if:
- Runtime 3 uses taxonomy/ranking_group naming.
- Dependency chain uses Publication / FileIO / Route Service support wording.
- First source slice does not label publication as trading owner.
