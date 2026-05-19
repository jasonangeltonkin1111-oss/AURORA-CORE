# 00 GOVERNANCE INDEX

## Purpose
Governance index for schemas, registries, and examples structure.

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

## Source-of-truth relationship
- Active doctrinal source remains `docs/00` through `docs/15` guidebooks.
- MT5 remains owner of broker truth, publication, permission blocks, and validation of worker outputs.
- External worker may calculate only; it may not become broker truth, publication owner, permission owner, or execution brain.

## Next acceptable work
- Add concise folder-local indexes, schemas, templates, or checklists that reference `docs/` authority.
- Prepare migration plans and acceptance criteria without moving guidebook content in this run.
- Add non-runtime examples that improve auditability without creating live runtime outputs.

## No-go rules
- Do not move existing active guidebooks out of `docs/` without an explicit migration run.
- Do not duplicate guidebook content in this folder.
- Do not introduce implementation files, execution permissions, or runtime-output spam in Git.

## Scaffold notice
```text
This folder scaffold is now created.
Existing guidebooks remain in docs/ until an explicit migration run is approved.
Do not duplicate guidebook content here.
```
