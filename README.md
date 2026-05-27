# AURORA CORE

**Native MT5 Market Intelligence, Truth Publication, Selection, Deep Evidence, Manual Review, and Future Validation System**

AURORA CORE is a native MetaTrader 5 / MQL5 trading-system foundation built to observe broker/account truth, classify the market universe, rank attention-worthy symbols, build a diversified inspection basket, collect selected deep evidence, and publish operator truth without fake confidence.

It is not a finished trading edge.

It is not an auto-trading permission system.

It is not a signal seller.

AURORA CORE is the runtime spine for disciplined market intelligence. It can later support validated strategy research, alerts, review exports, and execution modules only after source, compile, runtime, broker, prop-firm, and validation evidence prove those permissions are deserved.

---

## Mandatory Reading Spine

Scaffold startup path:

```text
AGENTS.md
README.md
control/02_MASTER_REPO_FILE_INDEX.md
control/00_CONTROL_INDEX.md
control/01_CONTROL_GOVERNANCE.md
relevant folder index
relevant real content file
```

Core system blueprints and guidebooks:

```text
mt5/00_MT5_SOURCE_INDEX.md
mt5/runtime_owners/00_RUNTIME_OWNERS_SOURCE_INDEX.md
external_worker/00_EXTERNAL_WORKER_SOURCE_INDEX.md
blueprint/00_BLUEPRINT_INDEX.md
blueprint/03_LOGICAL_LAYER_BLUEPRINT.md
blueprint/05_PUBLICATION_SURFACE_BLUEPRINT.md
blueprint/06_PERMISSION_AND_VALIDATION_BLUEPRINT.md
docs/22_AURORA_QUALITY_7S_LAW.md
docs/23_SYMBOL_OMIT_AND_CALC_MODE_CONTROL.md
docs/24_DOSSIER_SPECS_FUNDAMENTALS_DOM_CONTROL.md
docs/AURORA_LAYER_SURFACE_GUIDEBOOK.md
docs/AURORA_RUNTIME3D_CLOSEOUT_GUIDEBOOK.md
```

`blueprint/03_LOGICAL_LAYER_BLUEPRINT.md` is the 23-layer trading/system contract. Current source/config/index files decide active implementation truth when blueprint text and source disagree.

---

## Current System Shape

Aurora Core has one product identity:

```text
MT5 EA + Runtime Owners + Calculation Gateway support + truth-publication surfaces
```

The system itself is the important object, not branch process, overseer process, or worker-management language. External worker files are calculation-support implementation details. They do not change the system mission and they do not become trading authority.

Aurora Core’s runtime chain is:

```text
L1-L5   Foundation Truth and Basic Gate
L6-L9   Surface Scoring and Attention Ranking
L10-L14 Taxonomy, Ranking Groups, and Candidate Sourcing
L15-L16 Correlation/Diversity Selection and Global Top 10 Attention Basket
L17-L22 Selected Deep Evidence Packs
L23     Setup/Strategy/Permission/Manual Review Export State
```

Layer order matters. Later layers consume earlier owner packets. Later layers do not reopen blocked symbols, recalculate upstream truth, or create hidden authority.

---

## System Flow Law

Aurora must flow, not freeze.

```text
Publish truth early.
Label incomplete/degraded/stale states honestly.
Wait for upstream acceptance before pretending downstream stability.
Do not print false ACCEPTED/static/done states.
Do not recalculate downstream layers aggressively while upstream chains are still filling.
```

The desired cadence is chain-aware:

1. Foundation truth starts first and keeps publishing real status.
2. L5 is the only broad all-symbol hard eligibility gate.
3. L6-L16 may rank/select only from valid upstream packets.
4. L17-L22 collect selected evidence only after selection is stable enough to avoid thrash.
5. L23 may package review/export state, but permission remains false unless validation explicitly upgrades it.
6. A static/settled state should mean the current chain is actually clean/accepted/done for that scope, not merely quiet.

---

## Active Runtime Owner Truth

Current source truth declares these active owners and boundaries:

```text
Runtime 0 - Governance / Internal Control
Layer 0.1 - Startup / Runtime Identity
Layer 0.2 - Scheduler / Heartbeat / Breathing Spine
Layer 0.4 - Governance / Manifest / Telemetry
Runtime 1 - Foundation Truth Owner
Layer 1 - Account / Portfolio / Prop Rule Truth
Layer 2 - Market Open / Closed Truth
Layer 3 - Broker Specs and Value Truth
Layer 4 - Live Quote and Spread Truth
Layer 5 - Basic System Gate
Runtime 1 - Shared OHLC Raw Storage support service
Runtime 2 - Market Universe / Taxonomy Lookup generated-row lookup source
Runtime 3 - Calculation Gateway support
Runtime 3 support chain - L6 through L19 calculation/file-decoration support where source-present
Runtime 4 - Surface Scoring contracts where source-present
Publication / FileIO / Route Service support
Board / Dossier / Workbench render/readback surfaces
```

Do not confuse source-folder names with trading authority. Publication/FileIO/Route support owns writing and route boundaries; it does not own broker truth, ranking truth, selection truth, or permission truth.

Runtime 3 owns the MT5-to-external-calculation support relationship, job-bus contract, daemon/watchdog status, and worker-result acceptance/rejection. Runtime 3 must not own broker truth, ranking authority, selection authority, trade permission, execution, FileIO, or Board/Dossier rendering.

`mt5/runtime_owners/runtime_5_deep_inspection_advisory_owner/AC_DeepInspectionOwner.mqh` is a retired compatibility wrapper only. It must not be treated as active Runtime 5 authority.

---

## Layer Chain Overview

### L1-L5 — Foundation Truth and Basic Gate

```text
L1 Account / Portfolio / Prop Rule Truth
L2 Market Open / Closed Truth
L3 Symbol + Broker Specs Truth
L4 Market Watch / Quote / Spread Truth
L5 Basic System Gate
```

This block answers whether the account, broker, session, symbol specs, live quote, spread, and basic eligibility are usable. L5 is the only broad all-symbol hard gate. Broken/stale/unknown truth may block ranking, selection, review, or permission, but it should not hide publication surfaces.

### L6-L9 — Surface Ranking

```text
L6 Surface Cost / Friction Ranking
L7 Session Relevance Ranking
L8 Surface Movement / Range Ranking
L9 Surface Structure / Location Geometry
```

This block ranks attention quality. It does not create trade permission. Low spread is not edge. Movement is not edge. Location near a high/low is structure context, not direction.

### L10-L14 — Taxonomy, Groups, and Candidate Sourcing

```text
L10 Taxonomy / Ranking Group Classification
L11 Symbol Ranking Inside Ranking Group
L12 Ranking Group Heat / Quality
L13 Dynamic Ranking Group Selection
L14 Ranking Group Leader Candidate Pool
```

This block turns a large market universe into organized ranking groups and candidate pools. `ranking_group` is the selection/cap/diversification field. It replaces older active wording such as `major_bucket`, `minor_bucket`, `aggregation_group`, `bucket_top5`, and `sub_bucket_top5`.

### L15-L16 — Basket Selection

```text
L15 Correlation / Diversity Selection
L16 Global Top 10 Builder
```

This block builds a diversified inspection basket. Global Top 10 means “inspect these first,” not “best 10 trades.” Correlation/diversity operates on the candidate pool only, not a full-universe 1200x1200 matrix.

### L17-L22 — Selected Evidence Only

```text
L17 Deep Evidence Selection Split
L18 Selected Raw OHLC Bar Pack
L19 Selected Wick / Candle Geometry Pack
L20 Selected Rolling Tick Pack
L21 Selected Indicator / Reference Pack
L22 Deep Market Evidence / Liquidity / MT5 Order-Flow Proxy Pack
```

Deep evidence is selected-symbol only. No all-symbol OHLC/tick/indicator/DOM collection. DOM/order-flow is MT5 proxy-only, broker/symbol dependent, and must never be labelled institutional order-flow proof.

### L23 — Permission / Review / Alert State

```text
L23 Setup / Strategy / Permission / Trader-Review Export State
```

L23 packages selected-symbol evidence into manual review, trader-chat export, setup research, permission, and alert state. Export is not permission. Manual review packets may exist while trade permission remains false.

Default permission state:

```text
trade_permission=false
auto_trade_allowed=false
entry_signal=false
prop_firm_ready=false
edge_validated=false
```

---

## Current Selection Desk Contract

Stable parent routes:

```text
Aurora Core/<server>/<account>/Selection Desk/Groups/
Aurora Core/<server>/<account>/Selection Desk/Global/
Aurora Core/<server>/<account>/Selection Index.txt
```

Changing ranks, Top-N order, scores, cycle IDs, and metadata belong inside files/indexes/reports, not parent folder names.

Preserved child output views:

```text
Selection Desk/Groups/_INDEX.txt
Selection Desk/Groups/<ranking_group>.txt
Selection Desk/Global/_INDEX.txt
Selection Desk/Global/Global Top 10.txt
Selection Desk/Selection Index.txt
```

Dossier routes remain separate:

```text
Aurora Core/<server>/<account>/Dossiers/Open/
Aurora Core/<server>/<account>/Dossiers/Closed/
Aurora Core/<server>/<account>/Dossiers/Unknown/
```

---

## Taxonomy Naming Contract

Active hierarchy:

```text
asset_class -> market_group -> market_segment -> symbol
ranking_group = EA selection/cap/diversification group field
```

Retired active names:

```text
major_bucket
minor_bucket
aggregation_group
bucket_top5
sub_bucket_top5
Top 5 Per Bucket
```

These old names may appear only as historical/source-input references or contradiction-ledger context. They must not be used as active EA-facing fields, route names, or operator-facing labels.

---

## Publication Surface Contract

Board = compact operator cockpit.

Dossier = rich per-symbol truth.

Selection Desk = group/global attention and selection surfaces.

Workbench/Diagnostics = developer/operator proof, timing, failures, manifests, and readback evidence.

A clean surface must show what is complete, stale, degraded, blocked, pending, unknown, or review-unsafe. It must not hide missing layers, stale snapshots, failed worker reads, incomplete OHLC, empty groups, or false accepted states.

---

## External Worker Source Hygiene

Active calculation-support source authority is listed in:

```text
external_worker/00_EXTERNAL_WORKER_SOURCE_INDEX.md
```

One-shot emergency repair scripts, backup folders, generated build artifacts, and packaged executables are not source authority. Patch source first. Rebuild packages only after source changes are intentional and runtime proof is required.

---

## Proof Discipline

Source presence proves source presence only.

Compile success proves build compatibility only.

Runtime file output proves only observed publication behavior under the observed terminal/account/server conditions.

Selection is attention, not permission.

No live trading, prop-firm readiness, strategy edge, or execution approval exists in this repository until direct evidence proves it.
