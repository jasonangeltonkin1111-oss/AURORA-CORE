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
- Runtime 5 selected evidence owner now includes a source-present Layer 20 Selected Rolling Tick Pack scaffold under `runtime_5_selected_evidence_owner/layer_20_selected_rolling_tick_pack/`. It is not included by `mt5/AuroraCore.mq5`, not compile-proven, not runtime-proven, and must not be activated until L1-L19 selected-scope truth is stable and overseer approves active wiring.

## Source-of-truth relationship
- Active doctrinal source remains `docs/00` through `docs/15` guidebooks plus task-specific addenda such as `docs/25_SHARED_OHLC_RAW_STORAGE_OWNER.md`, `docs/37_L20_SELECTED_ROLLING_TICK_PACK_CONTROL.md`, and `docs/38_L20_IMPLEMENTATION_DESIGN_AND_ACCEPTANCE_PLAN.md`.
- MT5 remains owner of broker truth, publication, permission blocks, and validation of worker outputs.
- External worker may calculate only; it may not become broker truth, publication owner, permission owner, execution brain, raw OHLC retrieval owner, or broker tick owner.
- Future layers must read raw bars from the Shared OHLC Raw Storage Owner and must not create private `CopyRates` owners or private candle caches.
- L20 tick capture, when activated, must remain selected-symbol MT5 tick proxy evidence only. It must not perform full-universe tick harvesting, institutional order-flow claims, setup confirmation, trade permission, or execution.

## Source-present selected evidence scaffolds

| Path | Status | Boundary |
|---|---|---|
| `runtime_5_selected_evidence_owner/layer_20_selected_rolling_tick_pack/00_L20_SELECTED_ROLLING_TICK_PACK_SOURCE_INDEX.md` | Source-present index | L20 source-local index; no runtime activation. |
| `runtime_5_selected_evidence_owner/layer_20_selected_rolling_tick_pack/AC_SelectedRollingTickPack.mqh` | Source-present scaffold | Selected-symbol rolling tick/spread proxy helper only; not included by active EA yet. |

## Next acceptable work
- Add concise folder-local indexes, schemas, templates, or checklists that reference `docs/` authority.
- Prepare migration plans and acceptance criteria without moving guidebook content in this run.
- Add non-runtime examples that improve auditability without creating live runtime outputs.
- Compile-test the Shared OHLC Raw Storage source scaffold before wiring an active all-symbol seed scheduler.
- After compile proof, activate boot-seed and append-only queue behavior in bounded timer slices with Workbench proof.
- For L20, first confirm L1-L19 selected-scope stability, then include the L20 scaffold behind deliberate activation only after MetaEditor compile and runtime budget plan are ready.

## No-go rules
- Do not move existing active guidebooks out of `docs/` without an explicit migration run.
- Do not duplicate guidebook content in this folder.
- Do not introduce execution permissions, trade permissions, or directional alerts in Git.
- Do not let any future layer call `CopyRates` directly for normal layer work; raw OHLC retrieval belongs to the shared storage owner only.
- Do not let Gateway/EXE fetch broker history directly; Gateway may calculate from shared raw files only.
- Do not let Python or external worker become broker tick owner for L20.
- Do not activate L20 as full-universe `CopyTicks`/`CopyTicksRange` harvesting.

## Scaffold notice
```text
This folder scaffold is now created.
Existing guidebooks remain in docs/ until an explicit migration run is approved.
Do not duplicate guidebook content here.
L20 is source-present only and not active runtime proof.
```