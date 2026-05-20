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


## Mandatory first read
- README.md
- control/01_CURRENT_SOURCE_TRUTH_MAP.md
- control/00_MUST_READ_INDEX.md
- control/00_SUPER_INDEX_RUN_ROUTER.md
- control/05_DECISION_STATE_REGISTER.md
- control/02_MASTER_REPO_FILE_INDEX.md

## Current status
- Scaffold status: created in Post-Guidebook Phase 1 (index/control spine only).
- Guidebook tracker status: 16 / 16 complete in `docs/` and still active.
- External worker status: design-stage only; no production authority granted.

## Next schema creation order
1. schema registry
2. manifest
3. runtime telemetry
4. owner status
5. layer status
6. score registry
7. formula registry
8. selection ledger
9. evidence integrity
10. alert ledger
11. outcome ledger
12. external worker status
13. contradiction ledger

## Source-of-truth relationship
- Active doctrinal source remains `docs/00` through `docs/15` guidebooks.
- Repo stores schemas/examples only.
- Runtime outputs do not belong in Git unless explicitly added as evidence samples.

## Next acceptable work
- Create schema stubs in `governance/schemas/` following the ordered list.
- Add registry templates and examples that map cleanly to schema versions.
- Keep runtime-generated outputs out of Git except explicit, bounded evidence samples.

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
