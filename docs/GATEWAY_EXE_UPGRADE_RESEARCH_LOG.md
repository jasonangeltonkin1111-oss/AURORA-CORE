# Gateway EXE Upgrade Research Log

Status: living research and upgrade ledger. Runtime code changes must remain small, measured, and reversible.

Last updated from runtime evidence bundle: 18503(26).7z plus EXE-003 instrumentation/proof-script runs.

## Purpose

This log is the slow, source-backed planning ledger for upgrading the packaged Gateway EXE without breaking the currently working background runtime.

The current Gateway is working. Therefore the default posture is: audit first, measure second, patch only when the upgrade has a small safe surface and a rollback path.

## Non-negotiable runtime laws

- The Gateway must remain a background EXE.
- No GUI, no tray, no browser, no console popup, no foreground fallback.
- One global Gateway daemon should serve many terminals/accounts.
- Do not launch one Gateway worker per EA.
- Do not launch one Gateway worker per layer.
- The EA/MT5 remains the source publisher and runtime truth owner.
- Gateway remains calculation_support_only unless a later explicit owner contract changes that.
- Gateway must never own trade permission, selection permission, broker truth, FileIO routes, or hidden execution.
- Every output must keep authority=calculation_support_only and trade_permission=false until future Runtime 8 explicitly proves permission ownership.

## Current runtime baseline from 18503(26).7z

### Gateway daemon health

Observed files:

- Workbench/Gateway/Status/worker_process_status.txt
- Workbench/Gateway/Status/worker_heartbeat.txt
- Workbench/Gateway/Outbox/result_latest.txt
- Workbench/Gateway/Outbox/result_latest.manifest
- Workbench/Gateway/Outbox/Layers/Layer_6_Cost_Friction_Ranking/ranked_symbols.manifest
- Workbench/Gateway/Outbox/Layers/Layer_6_Cost_Friction_Ranking/l6_input_primitives.manifest

Important observed values:

```text
worker_version=0.6.5_gateway_folder_alignment
mode=shared-daemon
process_id=8356
loop_count=680
last_run_exit_code=0
last_validation_status=accepted
result_status=complete
accepted_result=true
row_count=1199
payload_checksum=2098215731
authority=calculation_support_only
trade_permission=false
```

Interpretation:

- This is real daemon proof, not just a one-shot probe.
- The lifecycle proof hole seen in earlier bundles is closed in this run.
- Result/job/snapshot envelope is accepted.
- No permission leakage is visible.

### Layer 6 manifest-delta proof

Observed result values:

```text
l6_rank_status=complete
l6_rank_reason=skipped_unchanged_input_reused_existing_ranked_outputs;ranked all rows present in stable L6 input generation
l6_rank_input_count=835
l6_rank_row_count=835
```

Observed L6 input manifest values:

```text
row_count=835
l5_gate_pass=835
payload_checksum=642635880
authority=calculation_support_only
trade_permission=false
ranking_runtime=false
ranked_output_runtime=false
```

Observed ranked manifest values:

```text
schema_version=5
status=complete
source_input_manifest_present=true
source_input_manifest_row_count=835
source_l5_gate_pass=835
source_input_payload_checksum=642635880
input_payload_checksum=642635880
input_payload_checksum_after_rank=642635880
input_generation_stable=true
input_payload_checksum_matches_source_manifest=true
input_csv_count_matches_source_l5_gate_pass=true
symbol_rank_files_written=835
symbol_rank_files_actual=835
symbol_rank_file_count_ok=true
input_count=835
row_count=835
ranked_count=802
ranked_degraded_count=32
not_rankable_quality_count=1
cost_model_mismatch_count=23
payload_checksum=1421754062
authority=calculation_support_only
trade_permission=false
ranking_runtime=true
selection_runtime=false
```

Interpretation:

- Stage B manifest-delta reuse is active.
- Unchanged L6 input is not being rescored/written every loop.
- The ranked output contract is clean for this bundle.
- This is the current performance upgrade baseline.

### Remaining runtime pressure

Known current issue from latest audit:

```text
runtime_state=heartbeat_over_budget
timer_duration_ms=281
timer_budget_ms=250
over_budget_flag=true
```

Interpretation:

- This is an MT5 timer/rendering pressure issue, not a Gateway failure.
- Do not panic-patch the Gateway for a 31 ms MT5 over-budget signal.
- Future optimization should reduce MT5 reading/rendering load first, especially full board/dossier rendering and repeated file reads.

## Official research sources

### MQL5 OnTimer constraint

Official source: https://www.mql5.com/en/docs/event_handlers/ontimer

Relevant truth:

- Each MQL5 program has one timer.
- If a Timer event is already queued or processing, a new Timer event is not added.
- Reducing timer period increases testing/runtime work pressure.

System implication:

- MT5 must not do heavy full-universe calculations in OnTimer.
- MT5 should publish bounded snapshots and read compact manifests/sidecars.
- Gateway should absorb calculation, but only through bounded jobs and proof manifests.

### MQL5 FileOpen / FILE_COMMON constraint

Official source: https://www.mql5.com/en/docs/files/fileopen

Relevant truth:

- MQL5 file operations are sandboxed.
- FILE_COMMON opens files in the shared common folder for all client terminals.
- Shared file paths are valid for multi-terminal local cooperation when account/server scoping is correct.

System implication:

- Aurora Core/Gateway and per-account Workbench/Gateway are the right communication bridge.
- Account isolation must remain server/account scoped.
- No absolute external file path authority should bypass the route owner.

### PowerShell read-only proof commands

Official sources:

- https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/test-path
- https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-content
- https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/select-string

Relevant truth:

- `Test-Path` can verify whether a file/path exists.
- `Get-Content` can read existing file content.
- `Select-String` can search text/patterns.

System implication:

- A read-only proof script can validate output fields without starting/stopping/rebuilding/installing Gateway.
- Proof scripts must not become runtime owners.
- The script added in EXE-003B intentionally reads files only.

### Python perf counter timing

Official source: https://docs.python.org/3/library/time.html#time.perf_counter_ns

Relevant truth:

- `time.perf_counter_ns()` returns an integer nanosecond performance counter.
- It is intended for short-duration performance measurement and avoids float precision loss.

System implication:

- Gateway duration instrumentation should use `perf_counter_ns`, not wall-clock time.
- Duration fields should be proof/diagnostic only and must not drive permission.
- Timing measurement should stay low-cost and local to the layer call.

### Python CSV parsing

Official source: https://docs.python.org/3/library/csv.html#csv.DictReader

Relevant truth:

- `csv.DictReader` maps rows to dictionaries using the first row as field names by default.

System implication:

- CSV parsing remains acceptable for current L6 size, but future full-universe multi-layer work should avoid repeated parsing when the input manifest is unchanged.
- Manifest-delta skipping is safer than early process-pool optimization.

### Python dataclass use

Official source: https://docs.python.org/3/library/dataclasses.html

Relevant truth:

- `dataclass` is appropriate for compact structured state with default fields.

System implication:

- Layer summary objects are acceptable for proof packets, as long as they do not grow into hidden runtime authority.
- Future job registry state should remain explicit and serializable.

### Python concurrent futures constraints

Official source: https://docs.python.org/3/library/concurrent.futures.html

Relevant truth:

- ThreadPoolExecutor can deadlock when a task waits on another future.
- ThreadPoolExecutor is mainly useful for I/O overlap; CPU-heavy Python work should not be scaled by blindly adding threads.
- ProcessPoolExecutor can bypass the GIL but requires picklable tasks/args, importable main module, bounded workers, chunking, and no executor/future calls inside submitted callables.

System implication:

- No nested futures.
- No one future per symbol for thousands of symbols.
- No unbounded thread/process pools.
- Chunked jobs only.
- Process pools are not Stage 1; they are later after measurement.

### Python shared memory constraints

Official source: https://docs.python.org/3/library/multiprocessing.shared_memory.html

Relevant truth:

- Shared memory can allow direct data access across processes.
- SharedMemoryManager exists to manage lifecycle and cleanup.
- This is useful but adds lifecycle cleanup risk.

System implication:

- Shared memory is future-only.
- It must not replace file manifests as authority.
- Do not use shared memory until CSV parse/copy is proven as the bottleneck.
- Cleanup proof is mandatory before adoption.

### PyInstaller EXE packaging constraints

Official source: https://pyinstaller.org/en/stable/spec-files.html

Relevant truth:

- PyInstaller spec files control EXE build behavior.
- The current AuroraWorker.spec must preserve windowless/background behavior.

System implication:

- console=False or equivalent windowless build behavior is mandatory.
- Do not move back to loose Python as normal runtime authority.
- Do not add console/debug foreground defaults to the packaged EXE.

### Windows Task Scheduler constraints

Official source: https://learn.microsoft.com/en-us/windows/win32/taskschd/task-scheduler-start-page

Relevant truth:

- Task Scheduler is the right Windows service-like mechanism for running background tasks without manual command panels.

System implication:

- The Gateway daemon should stay scheduled-task controlled.
- The EA should trigger control contracts and observe proof, not spawn visible shells.
- Repair/watchdog lanes should remain background and bounded.

## Current EXE upgrade thesis

The next real upgrade should not be raw parallelism. The correct path is to make the EXE smarter about not doing work.

Priority order:

1. Skip unchanged work by manifest checksum.
2. Keep health/status proof fresh even when calculations are skipped.
3. Add per-layer duration and skip counters.
4. Introduce cooperative budget scheduling.
5. Add chunked medium-layer jobs.
6. Only then consider process pools or shared memory.

Reason:

- The fastest calculation is the one that is correctly skipped.
- The lowest-risk CPU upgrade is manifest-delta scheduling.
- Process pools/shared memory add packaging, lifecycle, and debugging risk.

## Completed upgrade log

### 2026-05-22: EXE-003A L6 result-level instrumentation

Runtime file patched:

```text
external_worker/aurora_worker.py
```

Reason:

- Stage B skip proof existed, but result output did not show how long the L6 call took or whether the current call reused existing outputs as a separate boolean.
- The safest surface is the already-existing `result_latest.txt` append block in `run_once`, not the L6 math module and not the daemon scheduler.

Added result fields:

```text
l6_rank_duration_ms=<integer>
l6_rank_reused_existing_outputs=true|false
l6_rank_instrumentation_schema=1
```

Implementation notes:

- Uses `time.perf_counter_ns()` around `publish_l6_cost_friction_rankings(...)`.
- Reuse detection is based on the existing reason prefix `skipped_unchanged_input_reused_existing_ranked_outputs;`.
- Does not change L6 scoring, output manifests, scheduler behavior, daemon launch, FileIO routes, permissions, or selection.

Acceptance proof required in next runtime bundle:

```text
result_latest.txt contains l6_rank_duration_ms
result_latest.txt contains l6_rank_reused_existing_outputs
result_latest.txt contains l6_rank_instrumentation_schema=1
L6 remains complete or truthfully degraded
Gateway result remains accepted
No popup/window
Daemon loop continues rising
trade_permission=false
selection_runtime=false
```

Rollback:

- Remove the three appended fields and the two local timing/reuse variables in `run_once`.

### 2026-05-22: EXE-003B read-only proof script

Script added:

```text
external_worker/proof_gateway_l6_instrumentation.ps1
```

Reason:

- After EXE-003A, the next safest job is not another runtime patch. It is a repeatable read-only verifier.
- The script proves whether the packaged EXE is emitting the new fields after rebuild/install and whether core Gateway safety fields remain intact.

Script guarantees:

- Does not start Gateway.
- Does not stop Gateway.
- Does not repair Gateway.
- Does not install or rebuild Gateway.
- Does not launch the EXE.
- Reads Common Files proof only.

Proof fields checked:

```text
l6_rank_duration_ms
l6_rank_reused_existing_outputs
l6_rank_instrumentation_schema
result_status
authority
trade_permission
l6_rank_status
worker_process_status.txt
worker_heartbeat.txt
shared_worker_status.txt
ranked_symbols.manifest
```

Acceptance proof required:

- Script prints PASS for duration integer, reuse flag, schema 1, result complete, authority safe, trade permission false.
- Script does not produce popups or modify runtime files.

Rollback:

- Delete `external_worker/proof_gateway_l6_instrumentation.ps1`.

## Upgrade backlog

### EXE-001: Layer job registry

Goal:

Create an internal registry for Gateway-supported jobs without changing output math.

Candidate fields:

```text
layer_id
job_type
input_manifest_path
input_payload_checksum
output_manifest_path
output_contract_version
estimated_cost_class
max_runtime_ms
last_run_status
last_run_reason
last_run_duration_ms
last_skipped_reason
```

Safe implementation rule:

- Start with L6 only.
- Do not generalize to all layers until L6 registry proof is stable.

Acceptance proof:

- L6 still completes or reuses unchanged output.
- No daemon popup/window.
- Result manifest still accepted.
- Shared daemon loop remains fresh.

### EXE-002: General manifest-delta helper

Goal:

Move the L6-specific skip pattern into a reusable helper that future layers can use.

Risks:

- A too-generic helper can hide layer-specific contracts.
- A wrong checksum key can reuse stale outputs.

Safe implementation rule:

- Helper must accept layer-specific validators.
- The helper cannot decide correctness alone.
- Each layer owns its output contract.

Acceptance proof:

- L6 behavior unchanged.
- The helper prints reason=skipped_unchanged_input only when output manifest validates against current input manifest.

### EXE-003: Job duration and skip counters

Goal:

Add low-cost metrics to Gateway shared status and account process status.

Candidate fields:

```text
jobs_seen_total
jobs_run_total
jobs_skipped_unchanged_total
jobs_write_degraded_total
l6_last_duration_ms
l6_last_skip_status
l6_last_input_checksum
l6_last_output_checksum
```

Current status:

- Partially started through EXE-003A.
- Current implementation adds result-level L6 duration/reuse fields only.
- EXE-003B added a read-only proof script.
- Shared/account process aggregate counters are still pending.

Safe implementation rule:

- Metrics must not require parsing large CSVs.
- Metrics must not increase MT5 board read cost unless displayed compactly.

Acceptance proof:

- Shared status fresh.
- Account status fresh.
- No output schema consumer breaks.

### EXE-004: Cooperative scheduler skeleton

Goal:

Replace direct sequential per-account layer calls with a tiny cooperative scheduler.

Initial lanes:

1. health lane
2. input freshness lane
3. light layer lane

Do not add process pools yet.

Safe implementation rule:

- One daemon process remains.
- Single-threaded first.
- Health lane always runs before calculation lane.
- Loop budget is measured first, enforced second.

Acceptance proof:

- loop_count rises normally.
- shared status fresh.
- worker_process_status fresh.
- L6 still accepted.
- no popup/window.

### EXE-005: Medium-layer chunk contract

Goal:

Prepare Layer 8/9/11/12 style calculations to run in chunks.

Chunk fields:

```text
chunk_id
chunk_index
chunk_count
source_snapshot_id
source_payload_checksum
symbols_in_chunk
chunk_status
chunk_duration_ms
chunk_output_checksum
```

Safe implementation rule:

- Partial chunks may publish progress truth.
- Final manifest only becomes complete when all chunks match the same source snapshot/checksum.
- MT5 must treat partial as pending/degraded, not accepted.

Acceptance proof:

- No mixed-generation final output.
- No stale chunks counted as current.

### EXE-006: Selected-symbol heavy evidence lane

Goal:

Prepare future L18-L22 evidence packs without full-universe overload.

Rule:

- Heavy OHLC/tick/indicator/liquidity evidence runs only after candidate selection narrows the symbol set.
- Full universe heavy evidence is forbidden by default.

Acceptance proof:

- Candidate list count is bounded.
- Evidence request manifest contains selected symbols only.
- Raw evidence source remains MT5-owned.

### EXE-007: Optional process pool proof harness

Goal:

Test process-pool speedup safely outside production runtime.

Safe implementation rule:

- Harness only, not daemon default.
- Chunk-level tasks only.
- No futures inside submitted callables.
- Explicit timeout/cancel path.
- Max workers conservative.

Acceptance proof:

- Packaged EXE still builds.
- No child process popup.
- No orphan worker processes.
- No output authority change.

### EXE-008: Optional shared-memory proof harness

Goal:

Test shared memory/mmap only if CSV parse/copy becomes a measured bottleneck.

Safe implementation rule:

- Harness only.
- Shared memory manager or explicit unlink cleanup required.
- File manifest remains source authority.
- No live daemon dependency until cleanup proof is reliable.

Acceptance proof:

- No leaked shared memory segments.
- No stale memory read as current truth.
- No packaging regression.

## Risk register

### Risk: invisible duplicate authority

Cause:

Adding a scheduler, process pool, or shared memory cache can accidentally make Gateway own truth instead of support calculations.

Mitigation:

Every job output must include authority=calculation_support_only and source_snapshot_id/source_payload_checksum.

### Risk: CPU optimization breaks correctness

Cause:

Skipping unchanged input using the wrong checksum or stale manifest.

Mitigation:

Only skip when current input manifest, input CSV checksum, existing output manifest, output row count, and sidecar count all agree.

### Risk: process pool creates popups or orphan processes

Cause:

PyInstaller + Windows multiprocessing can be fragile if not tested in packaged form.

Mitigation:

No process pool in daemon until separate packaged harness proves no popup and no orphan workers.

### Risk: MT5 timer still over budget

Cause:

Board/Dossier rendering may still read too much or rewrite too much.

Mitigation:

First optimize MT5 manifest reads and renderer cache invalidation. Do not blame Gateway if Gateway proof is fresh and accepted.

### Risk: full-universe heavy evidence overload

Cause:

Future L18-L22 could try OHLC/tick/indicator packs for hundreds/thousands of symbols.

Mitigation:

Heavy evidence layers run only after candidate selection. Default full-universe heavy evidence is forbidden.

## Recommended next safe work

Next audit/research step:

1. Rebuild/install the packaged Gateway EXE.
2. Run at least 2-3 daemon cycles.
3. Run `external_worker/proof_gateway_l6_instrumentation.ps1`.
4. Confirm EXE-003A instrumentation fields appear in `result_latest.txt`.
5. Compare skip duration vs rerank duration across a changed-input and unchanged-input run.
6. Only then consider account/shared aggregate counters.

Next EXE implementation step when ready:

1. Add low-cost L6 aggregate counters to account process status or shared status.
2. Do not change L6 math.
3. Do not change daemon launch behavior.
4. Do not add threads/processes.

## Decision gate

Current decision: TEST FIRST.

Reason:

EXE-003A is intentionally tiny, but it still changes runtime output fields. EXE-003B only adds a read-only proof script. Runtime proof must come before any broader scheduler or counter work.

Next likely implementation decision: after proof, add aggregate counters only if `result_latest.txt` fields are stable, the proof script passes, and no MT5 consumer breaks.
