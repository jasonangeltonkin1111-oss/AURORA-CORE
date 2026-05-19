# 00 MT5 SOURCE INDEX

## Purpose
MT5 planning index for future source tree ownership only.

## What belongs here
- Index-level structure, boundaries, and ownership statements for this folder scope.
- References to active guidebooks in `docs/` as the current source for detailed doctrine.
- Short, enforceable scaffold notes only (no full guidebook migration content).

## What must not belong here
- Full guidebook rewrites, duplicated doctrine, or long narrative copies from `docs/`.
- MT5 implementation code, EA files, `.mqh` logic, Python worker implementation, or execution logic.
- Any text that approves live trading, directional alerts, auto-trading, or prop-firm readiness.

## Current status
- Scaffold status: created in Post-Guidebook Phase 1 (index/control spine only).
- Guidebook tracker status: 16 / 16 complete in `docs/` and still active.
- External worker status: design-stage only; no production authority granted.

## Before source implementation can start
- Runtime Owner Blueprint detailed.
- Logical Layer Blueprint detailed.
- FileIO / route ownership contract drafted.
- governance schemas for manifest/runtime/owner status drafted.
- MT5 Function Guidebook consulted.
- External Worker boundary respected.
- no compile/runtime/readiness claims without proof.

## Source-of-truth relationship
- Active doctrinal source remains `docs/00` through `docs/15` guidebooks.
- MT5 remains owner of broker truth, publication, permission blocks, and validation of worker outputs.
- External worker may calculate only; it may not become broker truth, publication owner, permission owner, or execution brain.

## Next acceptable work
- Keep this folder planning-only until checklist items are evidenced.
- Prepare source ownership maps under `mt5/runtime_owners`, `mt5/io`, `mt5/shared`, and `mt5/config`.
- Draft contracts first; implementation remains blocked in this scaffold phase.

## No-go rules
- Do not move existing active guidebooks out of `docs/` without an explicit migration run.
- Do not introduce MT5 implementation files in this scaffold run.
- Do not introduce implementation files, execution permissions, or runtime-output spam in Git.

## Scaffold notice
```text
This folder scaffold is now created.
Existing guidebooks remain in docs/ until an explicit migration run is approved.
Do not duplicate guidebook content here.
```
