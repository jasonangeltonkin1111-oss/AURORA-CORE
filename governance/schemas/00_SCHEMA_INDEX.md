# 00 SCHEMA INDEX

## Purpose
Schema index for static governance schema artifacts only.

## What belongs here
- Index-level structure, boundaries, and ownership statements for this folder scope.
- References to active guidebooks in `docs/` as the current source for detailed doctrine.
- Short, enforceable scaffold notes only (no full guidebook migration content).
- Static schemas for governance/import/review artifacts.

## What must not belong here
- Full guidebook rewrites, duplicated doctrine, or long narrative copies from `docs/`.
- MT5 implementation code, EA files, `.mqh` logic, Python worker implementation, or execution logic.
- Any text that approves live trading, directional alerts, auto-trading, or prop-firm readiness.
- Any schema that grants trade permission or overrides MT5 broker truth.

## Mandatory first read
- README.md
- control/01_CONTROL_GOVERNANCE.md
- control/01_CONTROL_GOVERNANCE.md
- control/01_CONTROL_GOVERNANCE.md
- control/02_MASTER_REPO_FILE_INDEX.md

## Current status
- Scaffold status: created in Post-Guidebook Phase 1 (index/control spine only).
- Guidebook tracker status: 16 / 16 complete in `docs/` and still active.
- External worker status: design-stage only; no production authority granted.
- Trade setup packet schema status: added for Trade Journal import design; runtime import/matching still requires source patch, compile proof, and runtime proof.

## Source-of-truth relationship
- Active doctrinal source remains `docs/00` through `docs/15` guidebooks plus task-specific addenda such as `docs/26_TRADE_JOURNAL_SYSTEM.md`.
- MT5 remains owner of broker truth, publication, permission blocks, and validation of worker outputs.
- External worker may calculate or validate support envelopes only; it may not become broker truth, publication owner, permission owner, execution brain, or trade-history motive authority.
- Setup packets are user/chat intent evidence only. They cannot override MT5 facts and cannot grant permission.

## Next acceptable work
- Add concise folder-local indexes, schemas, templates, or checklists that reference `docs/` authority.
- Prepare migration plans and acceptance criteria without moving guidebook content in this run.
- Add non-runtime examples that improve auditability without creating live runtime outputs.

## No-go rules
- Do not move existing active guidebooks out of `docs/` without an explicit migration run.
- Do not duplicate guidebook content in this folder.
- Do not introduce implementation files, execution permissions, or runtime-output spam in Git.
- Do not use a setup packet schema to certify edge, prop-firm safety, or trade permission.

## Scaffold notice
```text
This folder scaffold is now created.
Existing guidebooks remain in docs/ until an explicit migration run is approved.
Do not duplicate guidebook content here.
```

## Key files in this folder
- `governance/schemas/01_MINIMUM_GOVERNANCE_SCHEMA_CONTRACTS.md`
- `governance/schemas/02_TRADE_SETUP_PACKET_SCHEMA.md` — static schema for trader-chat setup packets imported into Trade Journal bookkeeping; not permission and not execution.

## When to update this index
- When schema files are added/retired.
- When schema/source authority boundaries change.
