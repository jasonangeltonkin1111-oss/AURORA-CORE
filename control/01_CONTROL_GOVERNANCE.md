# 01 CONTROL GOVERNANCE

## Purpose
Single active governance/control law for repository work discipline.

## Source truth order
1. Active MT5 source files for implementation truth.
2. `README.md`.
3. `control/02_MASTER_REPO_FILE_INDEX.md`.
4. This file (`control/01_CONTROL_GOVERNANCE.md`).
5. Relevant folder index file.
6. Relevant docs/blueprint/governance contracts.
7. Archive and historical files (background only).

## Mandatory read discipline
- Do not work from memory.
- Read the master index and relevant folder index before patching.
- If files disagree, log contradiction and patch scaffold before deep edits.

## Run modes and gates
- PATCH mode: smallest safe patch surface.
- No fake proof claims.
- Do not claim compile/runtime/trading/edge/live/prop readiness without direct evidence.

## Decision and proof gates
- Compile proof != runtime proof.
- Runtime output proof != trading permission.
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
- Active source owners include Runtime 0, Runtime 1 (Layer 1), Runtime 2 skeleton, Runtime 7 publication support.
- Publication/FileIO/Routes currently operate as source support owners.
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
