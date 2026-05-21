# AURORA CORE — RUNTIME OWNER BLUEPRINT

**System:** AURORA CORE  
**Role:** Runtime Owner and System Service boundary map for architecture ownership.  
**Status:** DETAILED BLUEPRINT — consistency-repaired.

## 0. Purpose
This blueprint defines permanent ownership boundaries between:
- Trading/System Truth Owners (operator-facing truth domains), and
- System Services (publication/render/proof support domains).

Core law:
- Truth Owners produce truth.
- System Services publish, render, or prove truth.
- System Services must not become shadow truth owners.

## 1. What This Blueprint Owns
- permanent owner/service boundary map,
- trading/system truth owner list,
- system service list,
- owner/service responsibilities and no-go boundaries,
- first-build dependency guardrails,
- source-reality note for inherited folder naming.

## 2. What This Blueprint Must Not Own
- MT5 implementation code,
- formula derivations,
- execution logic,
- live/funded/prop permission claims,
- runtime proof claims without runtime evidence.

## 3. Permanent Architecture Shape
### System Services
0. Governance / Internal Control Owner  
S1. Publication / FileIO / Route Service  
S2. Board / Dossier Renderer Services  
S3. Governance / Manifest / Telemetry Service  
S4. Workbench / Diagnostics Service

### Trading/System Truth Owners
1. Foundation Truth Owner  
2. Surface Scoring Owner  
3. Taxonomy / Ranking Group Owner  
4. Basket Selection Owner  
5. Selected Evidence Owner  
6. Permission / Alert Owner  
7. Validation / Outcome Owner

## 4. System Services
### 4.1 Runtime 0 — Governance / Internal Control Owner
Owns startup identity, heartbeat/scheduler support, diagnostics hooks, runtime status plumbing, and manifest/telemetry helpers.

Must not own market/account scoring/selection/permission/validation truth.

### 4.2 Publication / FileIO / Route Service
Owns:
- FileIO,
- physical routes,
- temp/final writes,
- manifest proof,
- route verification,
- atomic publication support.

Must not own:
- account truth,
- symbol truth,
- taxonomy truth,
- score truth,
- selection truth,
- selected evidence truth,
- permission truth,
- validation truth,
- strategy logic.

Why early: Runtime 0 needs file publication support for proof outputs.

Important source-reality note:
- Current source still contains `mt5/runtime_owners/runtime_7_publication_owner/` naming.
- That is implementation-support inheritance and does **not** make publication a trading truth owner.
- Source-folder rename/migration is out of scope for this run.

### 4.3 Board / Dossier Renderer Services
Own compact board and per-symbol dossier rendering surfaces.

Must not compute hidden owner truth.

### 4.4 Governance / Manifest / Telemetry Service
Owns proof-row publication and status ledgers.

Must not approve trading or invent truth.

### 4.5 Workbench / Diagnostics Service
Owns deep runtime diagnostics, failure detail, and back-pressure visibility.

Must not become scoring/strategy/permission owner.

## 5. Trading/System Truth Owners
### 5.1 Foundation Truth Owner
Owns:
- Layer 1 — Account / Portfolio / Prop Rule Truth
- Layer 2 — Market Open / Closed Truth
- Layer 3 — Symbol + Broker Specs Truth
- Layer 4 — Market Watch Truth
- Layer 5 — Basic System Gate

### 5.2 Surface Scoring Owner
Owns:
- Layer 6 — Surface Cost / Friction Ranking
- Layer 7 — Session Relevance Ranking
- Layer 8 — Surface Movement / Range Ranking
- Layer 9 — Surface Structure / Location Geometry

### 5.3 Taxonomy / Ranking Group Owner
Owns:
- Layer 10 — Taxonomy Classification
- Layer 11 — Symbol Ranking Inside Ranking Group
- Layer 12 — Ranking Group Heat / Quality Ranking
- Layer 13 — Dynamic Ranking Group Selection
- Layer 14 — Ranking Group Leader Candidate Pool

Mission:
- classify symbols via `asset_class`, `market_group`, `market_segment`, `ranking_group`,
- rank symbols within ranking_group,
- identify ranking_group leaders for inspection.

### 5.4 Basket Selection Owner
Owns:
- Layer 15 — Correlation / Diversity Selection
- Layer 16 — Global Top 10 Builder (inspection basket only; not trade list)

### 5.5 Selected Evidence Owner
Owns:
- Layers 17–22 selected-symbol evidence packs, including MT5 order-flow proxy labeling where available.

### 5.6 Permission / Alert Owner
Owns Layer 23 permission and alert state boundaries.

Default safety state includes blocked trading and blocked auto-trading until required evidence gates pass.

### 5.7 Validation / Outcome Owner
Owns hypothesis/experiment/outcome validation records and promotion/kill recommendations.

Validation may recommend; permission decides.

## 6. Dependency Direction
1. Runtime 0 internal control support
2. Publication / FileIO / Route Service support
3. Foundation Truth Owner
4. Surface Scoring Owner
5. Taxonomy / Ranking Group Owner
6. Basket Selection Owner
7. Selected Evidence Owner
8. Permission / Alert Owner
9. Validation / Outcome Owner

## 7. No-Go Rules
- Do not treat publication/render services as trading truth owners.
- Do not let renderers recompute owner truth.
- Do not promote selection/ranking into trade permission by naming drift.
- Do not claim live/funded/prop permission from architecture text.

## 8. Acceptance Criteria
This blueprint is acceptable if:
- Publication is a System Service, not permanent trading owner.
- Taxonomy/ranking_group naming replaces active bucket-era architecture terms.
- Owner/service boundaries are explicit and enforceable.
- Runtime 7 source-folder inheritance is explained without architectural drift.
