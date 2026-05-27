# AURORA CORE

**Native MT5 Market Intelligence, Runtime Ownership, Truth Publication, Manual Review, and Future Validation System**

AURORA CORE is a native MetaTrader 5 / MQL5 trading-system foundation built to observe broker truth, classify the market universe, route expensive evidence only where it matters, and publish operator truth without fake confidence.

It is not a finished trading edge.

It is not an auto-trading permission system.

It is not a signal seller.

AURORA CORE is the core runtime spine for building a disciplined market-intelligence engine that can later support validated strategy research, alerts, ranking, selection, and execution modules only after evidence proves they deserve permission.

---

## Mandatory Reading Spine

Scaffold control startup path (active):

```text
AGENTS.md
control/02_MASTER_REPO_FILE_INDEX.md
control/00_CONTROL_INDEX.md
control/01_CONTROL_GOVERNANCE.md
relevant folder index
relevant real content file
```

All future Aurora Core work must read these before assigning layers, patching source, updating docs, or changing worker branches:

```text
mt5/00_MT5_SOURCE_INDEX.md
mt5/runtime_owners/00_RUNTIME_OWNERS_SOURCE_INDEX.md
external_worker/00_EXTERNAL_WORKER_SOURCE_INDEX.md
blueprint/03_LOGICAL_LAYER_BLUEPRINT.md
blueprint/09_PARALLEL_WORK_AND_MERGE_CONTROL_BLUEPRINT.md
docs/22_AURORA_QUALITY_7S_LAW.md
docs/23_SYMBOL_OMIT_AND_CALC_MODE_CONTROL.md
docs/24_DOSSIER_SPECS_FUNDAMENTALS_DOM_CONTROL.md
docs/AURORA_LAYER_SURFACE_GUIDEBOOK.md
docs/AURORA_RUNTIME3D_CLOSEOUT_GUIDEBOOK.md
```

`blueprint/03_LOGICAL_LAYER_BLUEPRINT.md` is the 23-layer logical contract. `blueprint/09_PARALLEL_WORK_AND_MERGE_CONTROL_BLUEPRINT.md` is the parallel branch/worker/merge-control contract. Current source/config/index files decide the active implementation state when blueprint text and source disagree.

The control laws require the final product to be professional, readable, logically structured, easy to navigate, and cleanly organized. Stable truths become folders. Changing ranks, scores, cycle IDs, Top-N order, and metadata belong inside files, indexes, or reports. A patch is not clean if operators must hunt for the data or if source/docs/routes disagree.

`docs/AURORA_LAYER_SURFACE_GUIDEBOOK.md` is the active Board/Dossier/Workbench surface standard. It defines the no-repeat data law: later layers consume earlier owner gates and do not duplicate raw previous-layer truth.

`docs/AURORA_RUNTIME3D_CLOSEOUT_GUIDEBOOK.md` is the Runtime 3 Gateway/external-worker closeout standard. Runtime 3 is not fully closed until shared install, daemon, watchdog, per-account result acceptance, rejection-path proof, and MT5 Workbench readback are captured.

---

## Current System Shape

Aurora Core now has two active dimensions:

```text
1. Runtime/source system:
   MT5 EA + Runtime Owners + Runtime 3 external worker chain + publication/readback surfaces.

2. Parallel work system:
   Overseer + layer workers + design workers + specialist pressure-test lanes + merge-control queue.
```

Parallel work is allowed, but parallel ownership is not.

```text
Parallel work is useful.
Parallel ownership is dangerous.
Parallel merging without a control queue is forbidden.
```

The overseer owns integration sequencing, collision resolution, shared-file decisions, final merge queue, and main protection. Layer workers own their assigned layer only. Specialist workers pressure-test assigned risk areas and do not become mini-overseers.

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
Runtime 3 - Calculation Gateway Owner
Runtime 3 worker chain - L6 through L19 calculation/file-decoration support
Runtime 4 - Surface Scoring Owner contracts where source-present
Publication / FileIO / Route Service support (implementation inheritance may still use runtime_7_publication_owner folder naming)
Runtime 7 render/readback surfaces for Board/Dossier/Workbench; not calculation or trading authority
```

Do not confuse active source owners with complete logical layers.

Publication/FileIO/Route support may exist early only as infrastructure service support. It does not make publication a trading truth owner.

Layer 3 is the current broker/spec/value foundation layer. It scans Layer 2 known open and closed symbols, skips unknown symbols, prints literal fundamental lookup links where available, and must never show failed value or margin calculations as fake `0.00`. Layer 4 is the first open-symbol-only cutoff layer and owns live quote, tick, and spread truth.

Layer 5 is the Basic System Gate. It consumes L2/L3/L4 owner packets and outputs pass/blocked eligibility only. It is not Runtime 5, not advisory scoring, not ranking, not selection, not permission, and not execution.

Runtime 3 owns the Gateway/external-worker relationship, job-bus contract, daemon/watchdog status, and worker-result acceptance/rejection. Runtime 3 is calculation support only and must not own broker truth, ranking truth, selection truth, trade permission, execution, FileIO, or Board/Dossier rendering.

`mt5/runtime_owners/runtime_5_deep_inspection_advisory_owner/AC_DeepInspectionOwner.mqh` is a retired compatibility wrapper only. It must not be treated as active Runtime 5 authority.

Broker specs, Market Watch quote truth, calculation mode/spec validation, fundamental links, and DOM must follow current source truth and the control details in `docs/24_DOSSIER_SPECS_FUNDAMENTALS_DOM_CONTROL.md`.

---

## Current Runtime 3 Worker Chain

The source-indexed Runtime 3 calculation/file-decoration chain is:

```text
core snapshot validation
-> L6 cost / friction ranking
-> L7 session relevance ranking
-> L8 movement / range ranking
-> L9 structure / location geometry
-> L10 taxonomy / ranking_group classification
-> render index
-> L11 symbol ranking inside ranking_group
-> L12 ranking_group heat / quality
-> L13 dynamic ranking_group selection
-> L14 ranking_group leader candidate pool
-> L15 correlation / diversity scoring
-> L16 Global Top 10 held visible inspection basket
-> L17 Deep Evidence Selection Split
-> L18 Selected Raw OHLC Bar Pack dossier decoration
-> L19 Candle Geometry and Structure dossier decoration
```

This chain remains calculation/file-decoration support. It is not trading runtime authority.

L20-L23 are design/dependency-gated until upstream runtime proof supports them. They must not grant setup permission, trade permission, execution, prop-firm readiness, or edge validation.

---

## Core Mission

AURORA CORE exists to answer:

```text
What does the broker/account/market actually say?
Which symbols are usable right now?
Which symbols deserve attention later when ranking exists?
Which groups are strongest later when ranking exists?
Which candidates form a diversified inspection basket later when selection exists?
Which selected symbols deserve deep evidence later when that layer exists?
What is complete, degraded, stale, blocked, or still filling?
What is allowed, and what is not allowed?
```

---

## Current Selection Desk Contract

The current stable parent-folder contract is:

```text
Aurora Core/<server>/<account>/Selection Desk/Groups/
Aurora Core/<server>/<account>/Selection Desk/Global/
Aurora Core/<server>/<account>/Selection Index.txt
```

Ranking numbers, Top-N order, cycle IDs, and selection metadata belong inside child files and sibling index/metadata files, not in parent folder names.

Top-N was not removed.

The planned output views are preserved as child files/content:

```text
Selection Desk/Groups/_INDEX.txt
Selection Desk/Groups/<ranking_group>.txt        # later contains group_top_n=5 and rank_1..rank_5
Selection Desk/Global/_INDEX.txt
Selection Desk/Global/Global Top 10.txt          # later contains global_top_n=10 and rank_1..rank_10
Selection Desk/Selection Index.txt               # sidecar overview of group/symbol order and metadata
```

The Dossiers contract remains separate and must not be renamed by Selection Desk work:

```text
Aurora Core/<server>/<account>/Dossiers/
Aurora Core/<server>/<account>/Dossiers/Open/
Aurora Core/<server>/<account>/Dossiers/Closed/
Aurora Core/<server>/<account>/Dossiers/Unknown/
```

Current Selection Desk files are structure placeholders or worker-output readback surfaces only until the relevant selection owner has source/runtime proof. Placeholder publication must not imply ranked symbols, selected candidates, trade permission, edge, or prop-firm readiness.

---

## Layer Placement For New Evidence Sources

Current implementation placement:

```text
Layer 2 = Market Open / Closed Truth
Layer 3 = Symbol + Broker Specs Truth, including calculation mode/spec-validation direction
Layer 4 = Market Watch Truth
Layer 5 = Basic System Gate
Layer 6-L10 = active Runtime 3 external-worker calculation-support outputs; inspection/scoring/classification only, not permission
Layer 11-L19 = active external-worker calculation/file-decoration support chain by current source index; not permission
Layer 20-L23 = design/dependency-gated future layers unless current source and runtime proof explicitly upgrade them
Layer 22 = future Deep Market Evidence / Liquidity / MT5 Order-Flow Proxy Pack, where DOM belongs later
```

DOM is not fundamentals. DOM is not current Runtime 2 taxonomy. DOM must be bounded, availability-gated, labelled proxy evidence later.

---

## Current Runtime 2 Universe Status

Current runtime-2 source state is treated as source-inspection truth only:

```text
generated row include presence: present (mt5/runtime_owners/runtime_2_market_universe_taxonomy_lookup/AC_MarketUniverseRows.mqh exists and is included)
AC_UniverseRowsGenerated()=true; AC_UniverseLoadedRowCount() maps to AC_UNIVERSE_GENERATED_ROW_COUNT
contract_status=generated_copy_present_lookup_only
runtime permission: lookup-only; ranking_group_runtime=false; selection_logic_runtime=false; trade_permission=false
compile proof: unavailable unless explicit MetaEditor compile output exists
runtime loaded proof: unavailable unless explicit MT5 runtime output exists
```

Generated row include presence alone does not prove runtime loading, ranking completion, or permission state.

---

## Taxonomy Naming Contract

Use the professional hierarchy:

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
```

These old names may appear only as historical references. They must not be used as active source fields, route names, or operator-facing publication labels.

---

## Runtime Ownership Rules

- Publication / FileIO / Route Service support owns folder routes and FileIO boundaries (current source uses inherited `runtime_7_publication_owner` folder naming as implementation inheritance only; do not infer trading Runtime Owner status from folder name; no source-folder rename performed in this run).
- Placeholder route shells (Dossiers and Selection Desk stable parent routes) are structure-only publication surfaces; they do not prove Board/Dossier/Selection runtime truth.
- Publication/status/manifest truth repair is source-present; late write failures are intended to surface in final status outputs.
- Physical publication success proves file publication behavior only; it does not prove trading truth, ranking truth, or selection truth.
- Selection Desk parent folders must be stable: `Groups` and `Global`.
- Do not create route folders named after changing ranks such as Top 5, Top 10, Rank 1, or active cycle numbers.
- Top 5 per group and Global Top 10 are planned child output views, not parent folder owners.
- Do not create duplicate route owners or shadow writers.
- Do not block physical publication just because truth is partial, stale, degraded, or review-unsafe.
- Broken truth may block review, ranking, selection, trading, and permission; it must not hide expected files.
- Every placeholder must be honest: structure-only means no runtime truth yet.

---

## Parallel Worker / Merge Control Rules

- Workers may develop in parallel only when they preserve owner boundaries.
- Main must be protected by dependency-ordered merge waves.
- Duplicate layer branches must be reconciled before merge.
- Shared files are overseer-controlled during merge review.
- L20-L23 must remain draft/design until dependency proof allows promotion.
- Any branch without a current head SHA, current-main comparison, changed-file list, owner classification, rollback path, and proof statement is not eligible for merge.

See `blueprint/09_PARALLEL_WORK_AND_MERGE_CONTROL_BLUEPRINT.md` for the active control matrix and merge wave contract.

---

## External Worker Source Hygiene

Active Runtime 3 worker source authority is listed in:

```text
external_worker/00_EXTERNAL_WORKER_SOURCE_INDEX.md
```

One-shot emergency repair scripts, stale backup folders, generated build artifacts, and packaged executables are not source authority. Patch source first; rebuild packages only after source is intentionally changed and runtime proof is required.

---

## Proof Discipline

Source presence proves source presence only.

Compile success proves build compatibility only.

Runtime file output proves only observed publication behavior under the observed terminal/account/server conditions.

Selection is attention, not permission.

No live trading, prop-firm readiness, strategy edge, or execution approval exists in this repository until evidence specifically proves it.
