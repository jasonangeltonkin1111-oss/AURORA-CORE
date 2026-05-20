# AURORA CORE - CURRENT SOURCE TRUTH MAP

**Purpose:** give any new unrelated chat a short, current navigation map before it touches Aurora Core.

This file exists because old guidebook-era language and newer source/runtime contracts can confuse workers. It is the first control bridge between README, control router, guidebooks, blueprint files, and current MT5 source.

---

## 0. First Law

Do not work from memory.

Current source truth order:

```text
1. Current active MT5 source files for implementation truth
2. README.md for current repo-level direction
3. This file for current navigation and contradiction prevention
4. control/00_MUST_READ_INDEX.md
5. control/00_SUPER_INDEX_RUN_ROUTER.md
6. control/05_DECISION_STATE_REGISTER.md
7. Relevant docs/ guidebook
8. Relevant blueprint/ contract
9. Runtime/output evidence supplied by the user
10. Old guidebooks/history/chats only as background
```

If any guidebook conflicts with current source or README, do not guess. Log the contradiction and patch the guidebook/control spine before continuing.

---

## 1. Current Active MT5 Source State

Current source is no longer planning-only.

Active implementation exists under:

```text
mt5/AuroraCore.mq5
mt5/core/AC_Config.mqh
mt5/core/AC_CommonTypes.mqh
mt5/runtime_owners/runtime_0_governance_internal_control/
mt5/runtime_owners/runtime_1_foundation_truth_owner/
mt5/runtime_owners/runtime_2_market_universe_taxonomy_lookup/
mt5/runtime_owners/runtime_7_publication_owner/
```

Current implemented scope is still limited:

```text
Runtime 0 governance/status/manifest/diagnostics/micro-log support
Runtime 1 Layer 1 account truth snapshot
Runtime 2 taxonomy/universe lookup skeleton or contract only unless generated rows are present
Runtime 7 route and FileIO support
Selection Desk structure placeholders only
Dossier folder placeholders only
```

Not implemented / not allowed yet:

```text
symbol scan runtime
market ranking runtime
selection logic runtime
real Ranking Group Top 5 output
real Global Top 10 output
strategy
alerts
external worker runtime
trade execution
prop-firm permission
```

---

## 2. Dossier Folder Contract

Dossiers keep the stable status folders:

```text
Dossiers/
Dossiers/Open/
Dossiers/Closed/
Dossiers/Unknown/
```

Do not replace Dossier folders with taxonomy folders.

Taxonomy fields belong inside Dossier content, lookup rows, indexes, and selection metadata, not as the Dossier parent-folder layout.

---

## 3. Taxonomy Naming Contract

Use the new active taxonomy names:

```text
asset_class
market_group
market_segment
ranking_group
symbol
```

Meaning:

```text
Asset Class -> Market Group -> Market Segment -> Symbol
Ranking Group = EA-safe grouping field for caps, selection, diversification, and Top-N logic
```

Dead active names:

```text
major_bucket
minor_bucket
aggregation_group
bucket_top5
sub_bucket_top5
```

Old terms may exist only as historical notes. They must not appear in active route names, source fields, operator-facing output labels, or new guidebook contracts.

---

## 4. Selection Desk Contract

Stable parent folder contract:

```text
Selection Desk/
Selection Desk/Groups/
Selection Desk/Global/
Selection Desk/Selection Index.txt
```

Top-N numbers and rank order belong inside child files and index metadata, not parent folder names.

Future planned views:

```text
Selection Desk/Groups/_INDEX.txt
Selection Desk/Groups/<ranking_group>.txt        # later contains group_top_n=5 and rank_1..rank_5
Selection Desk/Global/_INDEX.txt
Selection Desk/Global/Global Top 10.txt          # later contains global_top_n=10 and rank_1..rank_10
Selection Desk/Selection Index.txt
```

Current Selection Desk state:

```text
structure placeholders only
no runtime selection truth yet
ranking_group_runtime=false
selection_logic_runtime=false
trade_permission=false
```

---

## 5. Mandatory Audit Before Patching

Before any patch:

```text
1. Read README.md.
2. Read this file.
3. Read control/00_MUST_READ_INDEX.md.
4. Read control/00_SUPER_INDEX_RUN_ROUTER.md.
5. Read the relevant docs guidebook.
6. Read the relevant active source owner files.
7. State contradictions before editing.
8. Patch the smallest owner-safe surface.
```

For route changes, inspect:

```text
mt5/runtime_owners/runtime_7_publication_owner/publication_routes/AC_ServerPaths.mqh
mt5/runtime_owners/runtime_7_publication_owner/publication_fileio/AC_FileIO.mqh
mt5/AuroraCore.mq5
```

For taxonomy/selection naming, inspect:

```text
docs/10_SELECTION_BASKET_CONSTRUCTION_GUIDEBOOK.md
mt5/runtime_owners/runtime_2_market_universe_taxonomy_lookup/AC_MarketUniverse.mqh
mt5/AuroraCore.mq5
mt5/core/AC_Config.mqh
```

---

## 6. Proof and Permission

Compile proof is still required after source edits.

Runtime file-output proof is required before accepting publication behavior.

No selection, ranking, edge, signal, strategy, live, funded, or prop-firm readiness claim exists from placeholder files.

Decision default after source edits:

```text
TEST FIRST
```
