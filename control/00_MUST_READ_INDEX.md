# 00 MUST READ INDEX

## Purpose
Control index for mandatory worker reading order and startup law.

## What belongs here
- Mandatory pre-read list for serious worker runs.
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

## Mandatory reading order for serious workers
- `README.md`
- `docs/00_AURORA_CORE_MAIN_PAGE_GUIDEBOOK.md`
- `docs/01_AURORA_CORE_HANDOFF_CONTINUITY_GUIDEBOOK.md`
- `control/05_DECISION_STATE_REGISTER.md`
- `docs/15_ANTI_DRIFT_SOURCE_OF_TRUTH_GUIDEBOOK.md`
- The relevant guidebook for the task under `docs/`.
- Relevant `blueprint/`, `control/`, and `governance/` files if the task touches those areas.

## Source-of-truth relationship
- Active doctrinal source remains `docs/00` through `docs/15` guidebooks.
- MT5 remains owner of broker truth, publication, permission blocks, and validation of worker outputs.
- External worker may calculate only; it may not become broker truth, publication owner, permission owner, or execution brain.

## Next acceptable work
- Add concise folder-local checklists that reinforce this must-read order.
- Keep task-specific read requirements explicit when new scaffold indexes are added.
- Prepare migration criteria without moving guidebook content in this run.

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
