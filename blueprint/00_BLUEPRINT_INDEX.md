# 00 BLUEPRINT INDEX

## Purpose

Blueprint index for system-level blueprint files, active structural contracts, and source-owner navigation.

This file must help a new unrelated chat find the right blueprint book quickly. It is not a dumping ground for full doctrine.

---

## First read before using any blueprint

Read these first:

```text
README.md
control/01_CURRENT_SOURCE_TRUTH_MAP.md
control/00_MUST_READ_INDEX.md
control/00_SUPER_INDEX_RUN_ROUTER.md
```

Then read the blueprint relevant to the task.

If a blueprint conflicts with current MT5 source, README, or the current source truth map, pause and log the contradiction before editing.

---

## Current status

```text
Blueprint folder = active structural contracts, not implementation authority by itself
MT5 source exists = yes, limited Runtime 0 / Runtime 1 / Runtime 2 skeleton / Runtime 7 support
Guidebooks = active doctrine, but some old bucket-era wording may be historical or stale
External worker = design-stage only
Trading permission = blocked
Selection/ranking runtime = not implemented
```

---

## Active blueprint navigation

Use this router:

```text
blueprint/00_BLUEPRINT_INDEX.md
  Front door to blueprint folder.

blueprint/02_RUNTIME_OWNER_BLUEPRINT.md
  Runtime owner overview and owner boundaries.

blueprint/03_LOGICAL_LAYER_BLUEPRINT.md
  Logical layers under runtime owners.

blueprint/04_BUILD_PHASE_BLUEPRINT.md
  Build/run phasing and evidence gates.

blueprint/07_FILEIO_ROUTE_OWNERSHIP_CONTRACT.md
  Runtime 7 route/FileIO ownership contract.

blueprint/08_MT5_SOURCE_FOLDER_CONTRACT.md
  MT5 source folder layout and source-owner placement.
```

If additional blueprint files exist, inspect them by name and update this index if they become active.

---

## Current route and folder locks

Dossiers stay:

```text
Dossiers/
Dossiers/Open/
Dossiers/Closed/
Dossiers/Unknown/
```

Selection Desk stable parent routes:

```text
Selection Desk/
Selection Desk/Groups/
Selection Desk/Global/
Selection Desk/Selection Index.txt
```

Do not create parent folders named after changing ranks, Top-N values, cycles, or active leader names.

Top-N belongs inside future child files or indexes, not parent folder routes.

---

## Current taxonomy contract

Use active field names:

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
Ranking Group = EA selection/cap/diversification grouping field
```

Dead active names:

```text
major_bucket
minor_bucket
aggregation_group
bucket_top5
sub_bucket_top5
Top 5 Per Bucket
```

These may appear only in historical notes or contradiction ledgers.

---

## Source-of-truth relationship

```text
1. Current active MT5 source files define implementation truth.
2. Runtime/generated files supplied by the user define observed behavior.
3. README.md and control/01_CURRENT_SOURCE_TRUTH_MAP.md define current navigation truth.
4. Blueprint files define structural contracts.
5. Docs guidebooks define doctrine.
6. Old guidebook-era terms do not override current source or current truth map.
```

Blueprint prose alone cannot approve implementation, ranking, selection, trading, alerts, execution, or prop-firm readiness.

---

## No-go rules

- Do not add implementation code to blueprint files.
- Do not duplicate full guidebooks here.
- Do not use blueprints to bypass source-owner inspection.
- Do not revive old bucket/major/minor/aggregation wording as active route/source terms.
- Do not rename Dossier folders because taxonomy fields changed.
- Do not create Selection Desk parent folders named after Top-N ranks.
- Do not approve live trading, strategy edge, alerts, execution, or prop-firm readiness.

---

## Decision default after blueprint/source edits

```text
TEST FIRST
```
