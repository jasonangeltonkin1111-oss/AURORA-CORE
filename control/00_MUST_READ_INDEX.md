# 00 MUST READ INDEX

## Purpose
Control index for mandatory worker reading order and startup law.

This file is the first mandatory navigation gate for serious Aurora Core work. It must prevent a new unrelated chat from missing active source files, current blueprints, current route contracts, or the latest taxonomy/selection naming contract.

---

## What belongs here

- Mandatory pre-read list for serious worker runs.
- Current source-truth navigation references.
- References to active guidebooks in `docs/` as detailed doctrine.
- References to current `control/`, `blueprint/`, `governance/`, `research/`, and `mt5/` contracts.
- Short, enforceable scaffold notes only.

## What must not belong here

- Full guidebook rewrites, duplicated doctrine, or long narrative copies from `docs/`.
- MT5 implementation code, EA files, `.mqh` logic, Python worker implementation, or execution logic.
- Any text that approves live trading, directional alerts, auto-trading, prop-firm readiness, or edge.

---

## Current status

```text
README.md = current repo-level direction
control/01_CURRENT_SOURCE_TRUTH_MAP.md = current navigation and contradiction-prevention bridge
Super Index = routing authority but must be read with the current truth map
Guidebooks = active doctrine, but older bucket/implementation-HOLD language may need sync patches
MT5 source implementation = active source exists, limited scope only
Runtime 0 = governance/status/manifest/diagnostics/micro-log support exists
Runtime 1 Layer 1 = account truth snapshot exists
Runtime 2 = taxonomy/universe lookup skeleton or contract only unless generated rows are committed
Runtime 7 = FileIO/routes owner exists
Selection Desk = structure placeholders only
Dossiers = Open/Closed/Unknown structure preserved
External worker = design-stage only; no production authority granted
Trading edge = UNPROVEN
Auto-trading / trade permission = BLOCKED
```

---

## Mandatory reading order for serious workers

Every serious run must read, in this order:

```text
README.md
control/01_CURRENT_SOURCE_TRUTH_MAP.md
control/00_MUST_READ_INDEX.md
control/00_SUPER_INDEX_RUN_ROUTER.md
control/05_DECISION_STATE_REGISTER.md
docs/15_ANTI_DRIFT_SOURCE_OF_TRUTH_GUIDEBOOK.md
```

Then read the relevant guidebook(s), blueprint(s), governance contracts, research docs, and active MT5 source owner files for the task.

No serious run may proceed from memory alone.

---

## Current source-of-truth relationship

Default hierarchy:

```text
1. Current active MT5 source files for implementation truth
2. Runtime/generated file evidence supplied by the user for observed behavior
3. README.md for current repo-level direction
4. control/01_CURRENT_SOURCE_TRUTH_MAP.md for current navigation and contradiction prevention
5. control/00_SUPER_INDEX_RUN_ROUTER.md for work routing
6. control/05_DECISION_STATE_REGISTER.md for decision/evidence gates
7. Active docs/ guidebooks for doctrine
8. Active blueprint/ contracts for structure
9. governance/ schemas and ledgers
10. research/ primary-source constraints
11. Old guidebooks/reports/prompts/chats/history as background only
```

If source, README, control files, guidebooks, or old chat memory conflict, log the contradiction explicitly before editing.

---

## Current naming and route locks

Taxonomy field names:

```text
asset_class
market_group
market_segment
ranking_group
symbol
```

Dossier folders stay:

```text
Dossiers/
Dossiers/Open/
Dossiers/Closed/
Dossiers/Unknown/
```

Selection Desk parent folders are stable:

```text
Selection Desk/
Selection Desk/Groups/
Selection Desk/Global/
Selection Desk/Selection Index.txt
```

Do not create parent folders named after changing ranks or Top-N values.

Top-N belongs inside future child files or indexes, not route ownership.

Dead active names:

```text
major_bucket
minor_bucket
aggregation_group
bucket_top5
sub_bucket_top5
Top 5 Per Bucket
```

These may appear only in historical notes or contradiction ledgers, not active routes, source fields, or operator-facing output labels.

---

## Required active-source audit targets by task

For route/FileIO/publication changes, inspect:

```text
mt5/AuroraCore.mq5
mt5/runtime_owners/runtime_7_publication_owner/publication_routes/AC_ServerPaths.mqh
mt5/runtime_owners/runtime_7_publication_owner/publication_fileio/AC_FileIO.mqh
```

For Runtime 0 governance/logging changes, inspect:

```text
mt5/AuroraCore.mq5
mt5/core/AC_Config.mqh
mt5/core/AC_CommonTypes.mqh
mt5/runtime_owners/runtime_0_governance_internal_control/
```

For Runtime 1 account truth changes, inspect:

```text
mt5/runtime_owners/runtime_1_foundation_truth_owner/layer_1_account_portfolio_prop_rule_truth/AC_AccountTruth.mqh
mt5/AuroraCore.mq5
```

For Runtime 2 taxonomy/selection naming changes, inspect:

```text
docs/10_SELECTION_BASKET_CONSTRUCTION_GUIDEBOOK.md
mt5/runtime_owners/runtime_2_market_universe_taxonomy_lookup/AC_MarketUniverse.mqh
mt5/AuroraCore.mq5
mt5/core/AC_Config.mqh
```

---

## Next acceptable work

- Keep control/index/router files synced with current source truth.
- Patch stale guidebook wording where it would misroute future workers.
- Continue source implementation only layer-by-layer after audit and compile/runtime evidence.
- Keep every upgrade logged through Workbench bounded snapshot/addendum style.

---

## No-go rules

- Do not work from old memory or a single guidebook.
- Do not invent layer placement without reading current owner/source contracts.
- Do not rename Dossier folders because taxonomy fields changed.
- Do not create Selection Desk parent folders named after Top-N ranks.
- Do not add Runtime 2/selection/ranking behavior just because placeholder routes exist.
- Do not approve live trading, trade permission, edge, prop-firm readiness, or execution.
- Do not create duplicate FileIO/path/logging/timer/publication owners.

## Decision default after source edits

```text
TEST FIRST
```
