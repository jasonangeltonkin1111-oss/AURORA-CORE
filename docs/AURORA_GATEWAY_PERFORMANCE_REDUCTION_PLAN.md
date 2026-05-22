# Aurora Gateway Performance Reduction Plan

## Status

Planning / execution guide. This document tracks the current Runtime 3 Gateway performance problem and the small-patch sequence for fixing it safely across several runs.

This is not trading permission. This is not selection runtime. This is not a Layer 7 promotion. The goal is to keep MT5 timer work bounded while preserving source-truth publication and Gateway proof.

## Current runtime evidence

Latest runtime archive reviewed in chat: `18503(26).7z`.

Important confirmed state:

- Build `1.053` compiled and ran.
- Gateway result validation was accepted.
- Worker lifecycle proof existed and was fresh.
- L6 ranked sidecar was accepted.
- L7 remained placeholder-only with `ranking_runtime=false`, `selection_runtime=false`, and `trade_permission=false`.
- Remaining runtime problem: `timer_duration_ms=281` against `timer_budget_ms=250`.
- Micro log offender: `gateway_status_and_required duration_ms=281`.

Immediate patch already made after that archive:

- Build `1.054`: `STABLE_GATEWAY_REQUIRED_CONTROL_WRITES`.
- Removed volatile `generated_at` from `worker_required.txt`.
- Changed `AC_WriteExternalWorkerRequired()` to `AC_WriteTextFileIfChanged()`.
- Expected proof after first write: Gateway Required should become `unchanged_no_write` or equivalent unchanged status.

## Official documentation anchors

### Timer pressure

MetaQuotes documents that each MQL5 application has its own event queue, and if a Timer event is already queued or being processed, a new Timer event is not added. Therefore, over-budget `OnTimer()` work can silently drop cadence.

Source: MQL5 `OnTimer` docs: https://www.mql5.com/en/docs/event_handlers/ontimer

MetaQuotes also documents that reducing timer period increases handler call frequency and that real-time millisecond timers are limited by hardware timing. Aurora's 250 ms timer therefore requires bounded work and must not perform heavy repeated exports in the hot lane.

Source: MQL5 `EventSetMillisecondTimer` docs: https://www.mql5.com/en/docs/eventfunctions/eventsetmillisecondtimer

### FileIO pressure

MetaQuotes documents that `FileFlush()` forces buffered data to disk and that frequent calls may affect program speed. Aurora needs atomic/truth publication, but repeated unchanged writes and flush/move cycles in the timer lane are performance risks.

Source: MQL5 `FileFlush` docs: https://www.mql5.com/en/docs/files/fileflush

### Cost primitive pressure

MetaQuotes documents that `OrderCalcProfit()` calculates profit for the current account in current market conditions and returns the estimated value in account currency. This is correct for cost primitives, but it is not free work and should not be repeated for hundreds of symbols when upstream truth has not changed.

Source: MQL5 `OrderCalcProfit` docs: https://www.mql5.com/en/docs/trading/ordercalcprofit

## Active source owner map

Runtime 3 / Calculation Gateway Owner:

- `mt5/runtime_owners/runtime_3_external_calculation_worker_owner/AC_ExternalWorkerOwner.mqh`
- `AC_ExternalWorkerControl.mqh`
- `AC_ExternalWorkerResult.mqh`
- `AC_ExternalWorkerResultEnvelope.mqh`
- `AC_ExternalWorkerSnapshot.mqh`
- `AC_ExternalWorkerSnapshotIdentity.mqh`
- `AC_ExternalWorkerSnapshotExport.mqh`
- `AC_ExternalWorkerL6InputPrimitives.mqh`
- `AC_ExternalWorkerRender.mqh`
- `AC_ExternalWorkerSharedRender.mqh`

Publication/FileIO/route owner must remain separate. Do not create duplicate FileIO, route, Gateway, L6, or L7 authority.

## Root performance diagnosis

### Problem A: Stable control contract was volatile

Before build `1.054`, `worker_required.txt` contained a generated time field, so the required-control text changed every Gateway check. That forced physical file writes even when the contract did not change.

Status: patched in build `1.054`.

Proof required:

- `worker_required.txt` contains `schema_version=3`.
- `worker_required.txt` contains `contract_timing=stable_control_contract_written_only_when_changed`.
- Manifest shows Gateway Required unchanged after first write.
- `gateway_status_and_required` duration drops materially from the previous ~281 ms.

### Problem B: L6 input primitive export is too heavy for hot path

Current active source pattern:

- `AC_ExportExternalWorkerSnapshot()` calls `AC_ExportLayer6CostFrictionInputPrimitives()`.
- `AC_ExportLayer6CostFrictionInputPrimitives()` builds rows for every L5-pass symbol.
- For each passing symbol, it can call `OrderCalcProfit()` up to four times:
  - Buy 1 lot
  - Sell 1 lot
  - Buy min lot
  - Sell min lot
- With about 835 L5-pass symbols, that can be up to ~3,340 `OrderCalcProfit()` calls in one Gateway check.
- It then builds a large CSV and writes manifest proof.

This is likely the main remaining cost if build `1.054` still shows `gateway_status_and_required` near the old 281 ms.

Required fix:

- Add an upstream key to `AC_ExternalWorkerL6InputPrimitives.mqh`.
- Skip rebuilding L6 cost primitives when upstream truth is unchanged.
- Upstream key should include, at minimum:
  - `AC_L5UpstreamKey()`
  - `AC_L5_GATE_PASS`
  - `AC_L3_CACHE_KEY`
  - `AC_L4_CACHE_KEY`
  - `AC_L4_REFRESH_KEY`
- If the upstream key is unchanged and a previous export exists, return a synthetic `unchanged_cached` result.
- Do not call `OrderCalcProfit()` on unchanged keys.
- Do not rewrite CSV on unchanged keys.
- Preserve manifest truth when export runs.

Acceptance proof:

- Workbench/manifest shows L6 input upstream key.
- On unchanged runs, L6 input export reports `unchanged_cached` or equivalent.
- `gateway_status_and_required` duration drops materially.
- L6 ranked sidecar remains accepted when current result proof matches.
- No trade permission, no selection runtime.

### Problem C: Snapshot cache is late

Current active source pattern:

- `AC_ExportExternalWorkerSnapshot()` builds full 1,199-row snapshot text.
- It then calculates payload checksum.
- Only after building/checksum does it decide whether payload is unchanged.

This avoids file rewrite but still pays the row-build and checksum cost. The cache is too late.

Required fix:

- Add a cheap snapshot upstream key before row construction.
- The key should represent relevant upstream state, for example:
  - symbol universe count or generation marker
  - `AC_L2_ROUTE_GENERATION_KEY`
  - `AC_L3_CACHE_KEY`
  - `AC_L4_CACHE_KEY`
  - `AC_L4_REFRESH_KEY`
  - `AC_L5_LAST_UPSTREAM_KEY` or `AC_L5UpstreamKey()`
  - L6 input upstream key/status if needed
- If the key is unchanged and a previous snapshot id/checksum exists, return synthetic `unchanged_cached` without building rows.
- Do not update `AC_EXTERNAL_WORKER_LAST_SNAPSHOT_ID` on skipped export.

Acceptance proof:

- Snapshot export reports upstream-key cached skip on unchanged runs.
- No full row build on unchanged runs.
- Accepted result is not broken by skipped snapshot export.
- Job envelope remains honest.

### Problem D: Gateway status path mixes fast and slow lanes

Current `AC_RefreshExternalWorkerStatus()` performs all of these together:

- EXE existence checks
- install proof validation
- shared daemon/supervisor status read
- lifecycle proof read
- heartbeat read
- result/manifest read
- result validation
- result envelope validation
- snapshot export
- render text rebuild
- shared supervisor render append

Correct truth, but too much for one timer lane.

Required future split:

Fast lane, every Gateway health check:

- heartbeat/result presence
- heartbeat freshness
- result/manifest validation
- job envelope validation
- snapshot export only if upstream key changed or required

Slow lane, every 60-300 seconds or on degraded/missing state:

- install proof
- shared supervisor proof
- EXE presence
- packaged EXE path checks
- watchdog/task metadata
- full lifecycle metadata

Acceptance proof:

- Hot Gateway path duration below budget.
- Slow lane still surfaces stale/missing/degraded truth.
- No stale worker is accepted as fresh.
- No hidden install failure is masked.

## Execution sequence

### Run 1: Verify build 1.054

Goal: prove whether stable required-control write lowered cost.

Do not add new features. Compile/run and inspect:

- `build_version=1.054`
- `worker_required.txt schema_version=3`
- `contract_timing=stable_control_contract_written_only_when_changed`
- Gateway Required manifest status after first cycle
- `gateway_status_and_required duration_ms`
- `timer_duration_ms`
- `accepted_result=true`
- `L6 validation_status=Accepted`
- `L7 ranking_runtime=false`, `selection_runtime=false`, `trade_permission=false`

Decision:

- If duration is now under/near 250 ms, hold further performance surgery and observe.
- If duration remains high, proceed to Run 2.

### Run 2: Patch L6 input primitive upstream-key cache

Target file:

- `mt5/runtime_owners/runtime_3_external_calculation_worker_owner/AC_ExternalWorkerL6InputPrimitives.mqh`

Patch rules:

- Existing owner only.
- No new file owner.
- No ranking math change.
- No selection/trading permission.
- No change to L6 ranked sidecar acceptance logic.
- Add upstream key and skip unchanged rebuilds.

Expected proof:

- Unchanged L6 input export does not run `OrderCalcProfit()` loop.
- `gateway_status_and_required` drops materially.
- L6 sidecar stays accepted.

### Run 3: Patch snapshot pre-build upstream-key cache

Target files:

- `AC_ExternalWorkerSnapshotIdentity.mqh`
- `AC_ExternalWorkerSnapshotExport.mqh`

Patch rules:

- Add source key before row build.
- Skip 1,199-row snapshot build if unchanged.
- Preserve current result validation ordering.
- Do not break worker job binding.

Expected proof:

- Snapshot export skipped before row build on unchanged state.
- Accepted result remains true.
- Timer pressure drops further.

### Run 4: Split Gateway fast/slow status lanes

Target files:

- `AC_ExternalWorkerState.mqh`
- `AC_ExternalWorkerControl.mqh`
- possibly render files only if status fields are needed

Patch rules:

- Slow install/supervisor proof must not vanish.
- Stale or missing proof must still surface truth.
- Fast lane must not accept stale worker/result.
- No hidden authority.

Expected proof:

- Gateway status path stable under budget.
- Full slow proof still visible in Workbench.

## No-go rules

- Do not increase timer budget as a fake fix.
- Do not hide over-budget state.
- Do not remove Gateway proof to improve speed.
- Do not skip stale checks without replacement proof.
- Do not accept stale worker output.
- Do not move trade permission, selection, execution, or risk authority into Gateway.
- Do not create `V2` owners, duplicate FileIO, duplicate path logic, or shadow schedulers.
- Do not parse the full ranked CSV inside MT5 hot loops.
- Do not rewrite L6 ranking math during performance cleanup.

## Decision gate

Current decision: TEST FIRST.

Next strongest action: compile/run build `1.054` and inspect whether stable required-control writes materially reduce `gateway_status_and_required`. If not, Run 2 is mandatory: upstream-key cache for L6 input primitives.