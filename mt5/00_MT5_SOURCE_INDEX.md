# 00 MT5 SOURCE INDEX

## Purpose
MT5 source index for active source-tree ownership and implementation-scope guardrails.

## Current status
- MT5 source exists and is active in limited scope (Runtime 0 orchestrator + identity/heartbeat/governance rows, Runtime 1 Layer 1 account snapshot, Runtime 2 generated-row lookup-only source, and Publication/FileIO/Route Service source under inherited `runtime_7_publication_owner` folder naming).
- Publication/status/manifest truth repair is source-present, including late-write surfacing intent in final status publication.
- Placeholder Dossiers and Selection Desk parent-route files are structure-only route shells; they are physical publication surfaces, not ranking/selection/trading truth.
- Compile/runtime proof is still required after source edits.

## Key files in this folder
- `mt5/AuroraCore.mq5`
- `mt5/core/AC_Config.mqh`
- `mt5/runtime_owners/00_RUNTIME_OWNERS_SOURCE_INDEX.md`
- `mt5/00_RUNTIME0_GOVERNANCE_INTERNAL_CONTROL_SOURCE_PLAN_AND_TESTS.md`
- `mt5/01_LAYER1_ACCOUNT_PORTFOLIO_PROP_RULE_TRUTH_SOURCE_PLAN_AND_TESTS.md`

## Folder Governance
- **Purpose:** index MT5 implementation ownership and source placement.
- **What belongs here:** MT5 source, MT5 source indexes, source plans/tests.
- **What must not belong here:** duplicate control doctrine or fake readiness claims.
- **Authority boundary:** MT5 source files are implementation truth.
- **Update rules:** update this index when source owners/files change.
- **No-go rules:** do not claim compile/runtime/trading readiness without explicit evidence.
- **Relationship to master index:** this folder is mapped in `control/02_MASTER_REPO_FILE_INDEX.md`.

## When to update this index
- When active owner scope changes.
- When new MT5 source index/planning files are added.
- When startup routing or source-truth hierarchy changes.
