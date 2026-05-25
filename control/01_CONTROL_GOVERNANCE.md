# 01 CONTROL GOVERNANCE

## Purpose
Single active governance/control law for repository work discipline.

## Startup read order
Use this order before assigning ownership, patching source, or updating docs:
1. `README.md`.
2. `control/02_MASTER_REPO_FILE_INDEX.md`.
3. `control/00_CONTROL_INDEX.md`.
4. This file (`control/01_CONTROL_GOVERNANCE.md`).
5. Relevant top-level folder index.
6. Relevant real content/source file.

This startup order is a work-discipline gate. It does not make documentation outrank active implementation source for observed behavior.

## Source truth order
1. Active MT5 source files and active external-worker source files for implementation truth.
2. Compile/import/test/runtime/output evidence for observed behavior.
3. `README.md`.
4. `control/02_MASTER_REPO_FILE_INDEX.md`.
5. This file (`control/01_CONTROL_GOVERNANCE.md`).
6. Relevant folder index file.
7. Relevant docs/blueprint/governance contracts.
8. Archive and historical files (background only).

## Mandatory read discipline
- Do not work from memory.
- Read the startup path above before patching.
- Read the relevant folder index before patching files inside that folder.
- If files disagree, log the contradiction and patch the scaffold before deep edits.
- If source and docs disagree about observed behavior, active source wins until docs are corrected.

## Run modes and gates
- PATCH mode: smallest safe patch surface.
- No fake proof claims.
- Do not claim compile/runtime/live readiness without direct evidence.

## Decision and proof gates
- Compile proof != runtime proof.
- Runtime output proof != permission.
- Selection/ranking outputs remain inspection-only unless explicit evidence says otherwise.

## Contradiction and clarity handling
- Contradictions must be logged in patch notes before continuing.
- Clarity repairs must preserve source authority order.

## Active taxonomy naming locks
Active names:
- `asset_class`
- `market_group`
- `market_segment`
- `ranking_group`
- `symbol`

Retired names (historical-only):
- bucket, major_bucket, minor_bucket
- broker_group, broker_subgroup, aggregation_group
- bucket_top5, sub_bucket_top5, Top 5 Per Bucket

## Route locks
- Stable parent selection routes remain `Groups` and `Global`.
- Rank/order metadata belongs inside child files, not route folder names.

## Current source-state summary
- Active source owners include Runtime 0, Runtime 1 foundation truth layers, Runtime 2 lookup-only generated-row source, Runtime 3 calculation-support worker chain, Runtime 4 surface-scoring contracts where source-present, and Runtime 7-named Publication/FileIO/Route Service support.
- Publication/FileIO/Routes currently operate as source support owners.
- Source-present worker layers do not prove runtime output or MT5 readback.
- TODO next architecture pass: separate operator-facing Runtime Owners from System Services more explicitly.

## Update rules
Update `control/02_MASTER_REPO_FILE_INDEX.md` when:
- top-level folder/file map changes,
- active authority files change,
- mandatory startup path changes.

Update folder indexes when:
- folder scope or authority boundary changes,
- prohibited content boundaries change,
- folder governance sections drift.