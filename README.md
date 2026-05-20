# AURORA CORE

**Native MT5 Market Intelligence, Runtime Ownership, and Truth Publication System**

AURORA CORE is a native MetaTrader 5 / MQL5 trading-system foundation built to observe broker truth, classify the market universe, rank symbols intelligently, route expensive evidence only where it matters, and publish operator truth without fake confidence.

It is not a finished trading edge.

It is not an auto-trading permission system.

It is not a signal seller.

AURORA CORE is the core runtime spine for building a disciplined market-intelligence engine that can later support validated strategy research, alerts, and execution modules only after evidence proves they deserve permission.

---

## Mandatory Quality Law

All future Aurora Core work must obey:

```text
docs/22_AURORA_QUALITY_7S_LAW.md
```

This law requires the final product to be professional, readable, logically structured, easy to navigate, and cleanly organized. Stable truths become folders. Changing ranks, scores, cycle IDs, Top-N order, and metadata belong inside files, indexes, or reports. A patch is not clean if operators must hunt for the data or if source/docs/routes disagree.

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

## Current Runtime 2 Universe Status

The bucket/symbol universe exists in the source workbook contract, not yet as loaded EA runtime truth.

Current source state:

```text
source_workbook=Aurora_Bucket_System_Hierarchy_EA_READY_PUBLIC_RESEARCH_FIXED.xlsx
source_sheet=EA Export Safe
expected_rows=1703
Runtime 2 loaded_row_count=0
AC_MarketUniverseRows.mqh=not committed
```

So the workbook contains literal symbol rows, but the EA still has only the Runtime 2 lookup skeleton until the generated row include is committed and compiled.

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

- Runtime 7 Publication Owner owns folder routes and FileIO boundaries.
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
