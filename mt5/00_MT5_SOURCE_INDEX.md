# 00 MT5 SOURCE INDEX

## Purpose
MT5 source index for active source-tree ownership, planning references, and implementation-scope guardrails.

## What belongs here
- Index-level structure, boundaries, and ownership statements for this folder scope.
- References to active guidebooks in `docs/` as the current source for detailed doctrine.
- Short, enforceable scaffold notes only (no full guidebook migration content).

## What must not belong here
- Full guidebook rewrites, duplicated doctrine, or long narrative copies from `docs/`.
- MT5 implementation code, EA files, `.mqh` logic, Python worker implementation, or execution logic.
- Any text that approves live trading, directional alerts, auto-trading, or prop-firm readiness.

## Current status
- MT5 source exists and is active in limited scope (Runtime 0, Runtime 1 Layer 1 snapshot, Runtime 2 skeleton/contract, Runtime 7 routes/FileIO).
- Compile/runtime proof is still required after any source edits.
- External worker status: design-stage only; no production authority granted.

## Mandatory first read before MT5 edits
- README.md
- control/01_CURRENT_SOURCE_TRUTH_MAP.md
- control/00_MUST_READ_INDEX.md
- control/00_SUPER_INDEX_RUN_ROUTER.md
- control/05_DECISION_STATE_REGISTER.md
- control/02_MASTER_REPO_FILE_INDEX.md
- docs/15_ANTI_DRIFT_SOURCE_OF_TRUTH_GUIDEBOOK.md

Then inspect the relevant active owner source files before patching.

## Source-of-truth relationship
- Active doctrinal source remains `docs/00` through `docs/15` guidebooks.
- MT5 remains owner of broker truth, publication, permission blocks, and validation of worker outputs.
- External worker may calculate only; it may not become broker truth, publication owner, permission owner, or execution brain.

## Next acceptable work
- Keep this index synchronized to active MT5 owner files and real implementation scope.
- Patch owner indexes under `mt5/runtime_owners`, `mt5/io`, `mt5/shared`, and `mt5/config` as source evolves.
- Do not claim compile/runtime proof without explicit evidence outputs.

## No-go rules
- Do not move existing active guidebooks out of `docs/` without an explicit migration run.
- Do not introduce duplicate owners or broad unscoped rewrites during index/planning runs; patch existing active MT5 owners only when task-scoped.
- Do not introduce implementation files, execution permissions, or runtime-output spam in Git.

## Scaffold notice
```text
This folder scaffold is now created.
Existing guidebooks remain in docs/ until an explicit migration run is approved.
Do not duplicate guidebook content here.
```


## Key files in this folder
- `mt5/AuroraCore.mq5`
- `mt5/core/AC_Config.mqh`
- `mt5/runtime_owners/00_RUNTIME_OWNERS_SOURCE_INDEX.md`
- `mt5/00_RUNTIME0_GOVERNANCE_INTERNAL_CONTROL_SOURCE_PLAN_AND_TESTS.md`
- `mt5/01_LAYER1_ACCOUNT_PORTFOLIO_PROP_RULE_TRUTH_SOURCE_PLAN_AND_TESTS.md`

## When to update this index
- When active owner scope changes.
- When new MT5 source index/planning files are added.
- When startup routing or source-truth hierarchy changes.
