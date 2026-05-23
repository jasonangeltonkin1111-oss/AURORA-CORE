# 00 RUNTIME OWNERS SOURCE INDEX

## Purpose
MT5 planning index for runtime-owner source modules.

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
- Runtime 7 publication owner now includes Layer 7 Session Relevance placeholder renderer support (render-only; no scoring authority).
- Runtime 1 now includes a source-present Shared OHLC Raw Storage Owner scaffold under `runtime_1_foundation_truth_owner/shared_ohlc_raw_storage/`. It is raw `CopyRates`/`MqlRates` storage authority only. It is not a layer calculation owner, ranking owner, selection owner, permission owner, execution owner, FileIO owner, route owner, or Gateway owner.

## Source-of-truth relationship
- Active doctrinal source remains `docs/00` through `docs/15` guidebooks plus task-specific addenda such as `docs/25_SHARED_OHLC_RAW_STORAGE_OWNER.md`.
- MT5 remains owner of broker truth, publication, permission blocks, and validation of worker outputs.
- External worker may calculate only; it may not become broker truth, publication owner, permission owner, execution brain, or raw OHLC retrieval owner.
- Future layers must read raw bars from the Shared OHLC Raw Storage Owner and must not create private `CopyRates` owners or private candle caches.

## Next acceptable work
- Add concise folder-local indexes, schemas, templates, or checklists that reference `docs/` authority.
- Prepare migration plans and acceptance criteria without moving guidebook content in this run.
- Add non-runtime examples that improve auditability without creating live runtime outputs.
- Compile-test the Shared OHLC Raw Storage source scaffold before wiring an active all-symbol seed scheduler.
- After compile proof, activate boot-seed and append-only queue behavior in bounded timer slices with Workbench proof.

## No-go rules
- Do not move existing active guidebooks out of `docs/` without an explicit migration run.
- Do not duplicate guidebook content in this folder.
- Do not introduce execution permissions, trade permissions, or directional alerts in Git.
- Do not let any future layer call `CopyRates` directly for normal layer work; raw OHLC retrieval belongs to the shared storage owner only.
- Do not let Gateway/EXE fetch broker history directly; Gateway may calculate from shared raw files only.

## Scaffold notice
```text
This folder scaffold is now created.
Existing guidebooks remain in docs/ until an explicit migration run is approved.
Do not duplicate guidebook content here.
```
