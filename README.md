# AURORA CORE

**Native MT5 Market Intelligence, Runtime Ownership, and Truth Publication System**

AURORA CORE is a native MetaTrader 5 / MQL5 trading-system foundation built to observe broker truth, classify the market universe, rank symbols intelligently, route expensive evidence only where it matters, and publish operator truth without fake confidence.

It is not a finished trading edge.

It is not an auto-trading permission system.

It is not a signal seller.

AURORA CORE is the core runtime spine for building a disciplined market-intelligence engine that can later support validated strategy research, alerts, and execution modules only after evidence proves they deserve permission.

---

## Mandatory Reading Spine

Scaffold control startup path (active):

```text
control/02_MASTER_REPO_FILE_INDEX.md
control/00_CONTROL_INDEX.md
control/01_CONTROL_GOVERNANCE.md
relevant folder index
relevant real content file
```



All future Aurora Core work must read these before assigning layers, patching source, or updating docs:

```text
blueprint/03_LOGICAL_LAYER_BLUEPRINT.md
docs/22_AURORA_QUALITY_7S_LAW.md
docs/23_SYMBOL_OMIT_AND_CALC_MODE_CONTROL.md
docs/24_DOSSIER_SPECS_FUNDAMENTALS_DOM_CONTROL.md
```

`blueprint/03_LOGICAL_LAYER_BLUEPRINT.md` is the active blueprint layer map for runtime/layer architecture. Any `docs/01_LOGICAL_LAYER_BLUEPRINT.md` references are secondary guidebook context, not canonical architecture authority.

The control laws require the final product to be professional, readable, logically structured, easy to navigate, and cleanly organized. Stable truths become folders. Changing ranks, scores, cycle IDs, Top-N order, and metadata belong inside files, indexes, or reports. A patch is not clean if operators must hunt for the data or if source/docs/routes disagree.

---

## Active Runtime Owner Truth

Current compile-chain source truth declares these active owners:

```text
Runtime 0 - Governance / Internal Control
Layer 0.1 - Startup / Runtime Identity
Layer 0.2 - Scheduler / Heartbeat / Breathing Spine
Layer 0.4 - Governance / Manifest / Telemetry
Runtime 1 - Foundation Truth Owner
Layer 1 - Account / Portfolio / Prop Rule Truth
Runtime 2 - Market Universe / Taxonomy Lookup generated-row lookup source present in current source
Publication / FileIO / Route Service support (implementation inheritance may still use runtime_7_publication_owner folder naming)
```

Do not confuse active source owners with complete logical layers.

Publication/FileIO/Route support may exist early only as infrastructure service support. It does not make publication a trading truth owner.

Broker specs, Market Watch quote truth, calculation mode/spec validation, fundamental links, and DOM must follow the logical placement in `blueprint/03_LOGICAL_LAYER_BLUEPRINT.md` and the control details in `docs/24_DOSSIER_SPECS_FUNDAMENTALS_DOM_CONTROL.md`.

---

## Core Mission

AURORA CORE exists to answer:

```text
What does the broker/account/market actually say?
Which symbols are usable right now?
Which symbols deserve attention?
Which groups are strongest?
Which candidates form a diversified inspection basket?
Which selected symbols deserve deep evidence?
What is complete, degraded, stale, blocked, or still filling?
What is allowed, and what is not allowed?
```

---

## Current Selection Desk Contract

The current stable parent-folder contract is:

```text
Aurora Core/<server>/<account>/Selection Desk/Groups/
Aurora Core/<server>/<account>/Selection Desk/Global/
Aurora Core/<server>/<account>/Selection Desk/Selection Index.txt
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

Current Selection Desk files are structure placeholders only until a later selection owner exists. Placeholder publication must not imply ranked symbols, selected candidates, trade permission, edge, or prop-firm readiness.

---

## Layer Placement For New Evidence Sources

From the canonical logical layer blueprint:

```text
Layer 2 = Market Open / Closed Truth, with fundamental links as support sidecar for symbol/market identity and bucket verification where applicable
Layer 3 = Symbol + Broker Specs Truth, including calculation mode/spec-validation direction
Layer 4 = Market Watch Truth
Layer 22 = Deep Market Evidence / Liquidity / MT5 Order-Flow Proxy Pack, where DOM belongs later
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

## Proof Discipline

Compile success proves build compatibility only.

Runtime file output proves only observed publication behavior under the observed terminal/account/server conditions.

Selection is attention, not permission.

No live trading, prop-firm readiness, strategy edge, or execution approval exists in this repository until evidence specifically proves it.
