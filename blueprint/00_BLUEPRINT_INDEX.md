# 00 BLUEPRINT INDEX

## Purpose
Blueprint index for system-level blueprint placeholders and control references.

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

## Next blueprint detailing order
1. Runtime Owner Blueprint
2. Logical Layer Blueprint
3. Build Phase Blueprint
4. Publication Surface Blueprint
5. Permission and Validation Blueprint

## Source-of-truth relationship
- Active doctrinal source remains `docs/00` through `docs/15` guidebooks.
- Blueprint files must stay structural.
- Detailed doctrine remains in `docs/`.
- No source implementation is allowed from blueprint alone.

## Next acceptable work
- Add concise structural detail to `blueprint/01` through `blueprint/06` in the order listed above.
- Keep blueprint content enforceable, short, and non-duplicative.
- Keep implementation gating tied to control/governance evidence, not blueprint prose.

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
