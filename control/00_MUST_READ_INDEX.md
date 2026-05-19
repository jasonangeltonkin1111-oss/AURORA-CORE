# 00 MUST READ INDEX

## Purpose
Control index for mandatory worker reading order and startup law.

## What belongs here
- Mandatory pre-read list for serious worker runs.
- References to active guidebooks in `docs/` as the current source for detailed doctrine.
- The Super Index / Run Router as the current task-routing authority.
- Short, enforceable scaffold notes only (no full guidebook migration content).

## What must not belong here
- Full guidebook rewrites, duplicated doctrine, or long narrative copies from `docs/`.
- MT5 implementation code, EA files, `.mqh` logic, Python worker implementation, or execution logic.
- Any text that approves live trading, directional alerts, auto-trading, or prop-firm readiness.

## Current status
- Scaffold status: created in Post-Guidebook Phase 1 (index/control spine only).
- Guidebook tracker status: 16 / 16 complete in `docs/` and still active.
- Super Index status: DRAFT AUTHORITY for routing serious runs.
- External worker status: design-stage only; no production authority granted.
- MT5 source implementation: HOLD until structure, contracts, schemas, and layer tests are ready.

## Mandatory reading order for serious workers
- `README.md`
- `docs/00_AURORA_CORE_MAIN_PAGE_GUIDEBOOK.md`
- `docs/01_AURORA_CORE_HANDOFF_CONTINUITY_GUIDEBOOK.md`
- `control/00_SUPER_INDEX_RUN_ROUTER.md`
- `control/05_DECISION_STATE_REGISTER.md`
- `docs/15_ANTI_DRIFT_SOURCE_OF_TRUTH_GUIDEBOOK.md`
- The relevant guidebook for the task under `docs/`.
- Relevant `blueprint/`, `control/`, and `governance/` files if the task touches those areas.

## Source-of-truth relationship
- Active doctrinal source remains `docs/00` through `docs/15` guidebooks.
- `control/00_SUPER_INDEX_RUN_ROUTER.md` routes serious runs to the correct books and work mode.
- `control/05_DECISION_STATE_REGISTER.md` controls baseline decision states and evidence-gated upgrades.
- MT5 remains owner of broker truth, publication, permission blocks, and validation of worker outputs.
- External worker may calculate only; it may not become broker truth, publication owner, permission owner, or execution brain.

## Next acceptable work
- Audit the Super Index against the 16 guidebooks when needed.
- Detail the Runtime Owner Blueprint and Logical Layer Blueprint before source implementation.
- Create governance schema contracts before runtime-output claims.
- Prepare source implementation only layer by layer, with tests and evidence gates.

## No-go rules
- Do not move existing active guidebooks out of `docs/` without an explicit migration run.
- Do not duplicate guidebook content in this folder.
- Do not introduce implementation files, execution permissions, or runtime-output spam in Git.
- Do not let Codex replace GPT-led research, audit, and layer-by-layer testing.
- Do not start broad MT5 source scaffolding before contracts are ready.

## Scaffold notice
```text
This folder scaffold is now created.
Existing guidebooks remain in docs/ until an explicit migration run is approved.
Do not duplicate guidebook content here.
```
