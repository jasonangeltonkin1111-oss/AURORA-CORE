# AURORA RUNTIME 3D CLOSEOUT GUIDEBOOK

Runtime 3D is the closeout and regression proof gate for the Calculation Gateway / external worker. It is not a new feature layer.

## Runtime 3 authority

Runtime 3 owns:

- Gateway / external-worker relationship.
- Shared global daemon status.
- Packaged watchdog status.
- Worker-required control file.
- Snapshot/job request export.
- Job-bus schema, job id, job type, resource class, and max runtime contract.
- Heartbeat/result/manifest path contracts.
- Acceptance/rejection of worker results.
- Rejection of stale, mismatched, incomplete, or non-authorized worker outputs.

Runtime 3 does not own L1-L5 source truth, Layer 5 gate interpretation, Layer 6 ranking/scoring truth, FileIO/routes, Board/Dossier rendering, selection, permission, or execution.

## Current source contract

Current source contract is:

```text
Layer 5 = Basic System Gate owned by Runtime 1
Runtime 3 = Gateway / calculation support only
Runtime 3 default job type = R3_SNAPSHOT_VALIDATION_V1
Layer 6+ = future cost/friction/scoring/ranking once explicitly implemented
trade_permission=false
```

Any old reference to `L5_DEEP_READINESS_SHELL`, Runtime 5 advisory truth, or Layer 5 deep inspection is stale unless current source reintroduces it explicitly. Do not use old Runtime 5 wording to justify new Runtime 5 authority.

## Runtime 3D acceptance proof

Runtime 3D can close only when runtime evidence shows all required proofs for the active account root.

### Shared install proof

```text
worker_version=current active worker version
packaged_internal_python_dll_present=true
flat_exe_runtime_authority=false
packaged_exe_runtime_authority=true
daemon_runtime_exe=...External Worker\AuroraWorker\AuroraWorker.exe
daemon_runtime_working_directory=...External Worker\AuroraWorker
watchdog_task_registered=true
watchdog_task_error=none
auto_start_configured=true
operator_cmd_required=false
authority=calculation_support_only
trade_permission=false
```

### Shared daemon proof

```text
worker_version=current active worker version
mode=shared-daemon
loop_count increasing
accepted_root_count >= 1
daemon_task_registered=not_checked_by_daemon
watchdog_task_registered=not_checked_by_daemon
terminal_process_count=not_checked_by_daemon
aurora_worker_process_count=not_checked_by_daemon
authority=calculation_support_only
trade_permission=false
root|exit_code|status|reason|snapshot_id|job_id|job_type|payload_checksum
```

A degraded second account root is allowed if that account has not been upgraded to the current snapshot/job envelope. It must not block closure for the active account, but it must be reported honestly.

### Per-account heartbeat/result proof

```text
schema_version=2
worker_version=current active worker version
last_job_bus_schema_version=job_bus_v1
last_job_id present
last_job_type=R3_SNAPSHOT_VALIDATION_V1
authority=calculation_support_only
trade_permission=false
```

```text
schema_version=2
source_snapshot_id matches MT5 latest snapshot
job_bus_schema_version=job_bus_v1
job_id matches MT5 latest job envelope
job_type=R3_SNAPSHOT_VALIDATION_V1
job_resource_class=light_serial
job_max_runtime_ms=3000
job_status=complete
result_status=complete
row_count matches snapshot
payload_checksum matches snapshot/manifest
authority=calculation_support_only
trade_permission=false
```

### MT5 Workbench proof

```text
accepted_result=true
result_validation_status=Accepted
job_bus_status=Accepted
job_bus_validation_status=Accepted
job_bus_expected_job_id equals job_bus_result_job_id
job_bus_expected_schema_version equals job_bus_result_schema_version
result_job_status=complete
install_flat_exe_runtime_authority=false
install_packaged_exe_runtime_authority=true
install_packaged_internal_python_dll_present=true
authority=calculation_support_only
trade_permission=false
```

## Runtime 3D falsifier tests

Required rejection tests:

- Missing job id rejected.
- Mismatched job id rejected.
- Mismatched job type rejected.
- Mismatched job-bus schema version rejected.
- Stale heartbeat rejected.
- Stale result rejected.
- Snapshot id mismatch rejected.
- Payload checksum mismatch rejected.
- Authority mismatch rejected.
- Any non-false trade permission value rejected.
- Flat EXE is never task runtime authority.
- Packaged EXE path and WorkingDirectory stay preserved.
- No popup storm returns.
- Daemon hot-loop does not call PowerShell or process/task inspection.

## Layer 6+ handoff gate

Layer 6+ may consume Gateway calculation support only after Runtime 3D is accepted for the active account and the relevant Layer 6+ job/result schema exists.

Until then, Layer 6+ may publish degraded/skeleton/input-primitive truth only.

Layer 6+ must consume L5 pass-set truth and accepted Runtime 3 Gateway outputs. It must not create its own worker transport, result validator, FileIO route, selection owner, permission owner, or execution owner.

## Proof limits

Source wired is not runtime closed.

Python syntax passed is not daemon running.

Scheduled task registered is not watchdog recovery proof.

Daemon running is not MT5 accepted-result proof.

MT5 accepted-result proof is not ranking, selection, edge, permission, or prop-firm readiness.
