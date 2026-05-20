# 00 ARCHIVE INDEX

## Purpose
Archive index for superseded evidence storage with authority limits.

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


## Historical authority warning
- Archive content is historical only.
- Archive content is not active authority.
- Do not use archive content without comparing against current source and `control/01_CURRENT_SOURCE_TRUTH_MAP.md`.
- Current source truth map outranks all archive content.

## Key files in this folder
- `archive/old_blueprints/00_OLD_BLUEPRINTS_INDEX.md`
- `archive/old_guidebook_drafts/00_OLD_GUIDEBOOK_DRAFTS_INDEX.md`
- `archive/superseded_prompts/00_SUPERSEDED_PROMPTS_INDEX.md`

## When to update this index
- When new archive sub-indexes are created.
- When archive authority warnings need strengthening after drift incidents.
