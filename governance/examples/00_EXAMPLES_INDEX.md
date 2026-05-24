# 00 EXAMPLES INDEX

## Purpose
Examples index for non-runtime sample governance artifacts.

## What belongs here
- Index-level structure, boundaries, and ownership statements for this folder scope.
- References to active guidebooks in `docs/` as the current source for detailed doctrine.
- Short, enforceable scaffold notes only (no full guidebook migration content).
- Non-runtime templates that improve auditability and operator discipline.

## What must not belong here
- Full guidebook rewrites, duplicated doctrine, or long narrative copies from `docs/`.
- MT5 implementation code, EA files, `.mqh` logic, Python worker implementation, or execution logic.
- Any text that approves live trading, directional alerts, auto-trading, or prop-firm readiness.
- Runtime-generated outputs masquerading as proof.

## Current status
- Scaffold status: created in Post-Guidebook Phase 1 (index/control spine only).
- Guidebook tracker status: 16 / 16 complete in `docs/` and still active.
- External worker status: design-stage only; no production authority granted.
- Trade setup packet template status: static example only; not runtime proof, not permission, not execution.

## Source-of-truth relationship
- Active doctrinal source remains `docs/00` through `docs/15` guidebooks plus task-specific addenda such as `docs/26_TRADE_JOURNAL_SYSTEM.md`.
- MT5 remains owner of broker truth, publication, permission blocks, and validation of worker outputs.
- External worker may calculate/validate support envelopes only; it may not become broker truth, publication owner, permission owner, execution brain, or trade-history motive authority.
- Templates are examples. They do not prove runtime behavior.

## Next acceptable work
- Add concise folder-local indexes, schemas, templates, or checklists that reference `docs/` authority.
- Prepare migration plans and acceptance criteria without moving guidebook content in this run.
- Add non-runtime examples that improve auditability without creating live runtime outputs.

## No-go rules
- Do not move existing active guidebooks out of `docs/` without an explicit migration run.
- Do not duplicate guidebook content in this folder.
- Do not introduce implementation files, execution permissions, or runtime-output spam in Git.
- Do not use examples to certify edge, prop-firm safety, or trade permission.

## Scaffold notice
```text
This folder scaffold is now created.
Existing guidebooks remain in docs/ until an explicit migration run is approved.
Do not duplicate guidebook content here.
```

## Key files in this folder
- `governance/examples/TRADE_SETUP_PACKET_V1_TEMPLATE.txt` — static packet template for trader-chat setup notes; operator fills it and places the resulting file into the future Trade Journal Import Inbox.

## When to update this index
- When example/template files are added/retired.
- When example/source authority boundaries change.
