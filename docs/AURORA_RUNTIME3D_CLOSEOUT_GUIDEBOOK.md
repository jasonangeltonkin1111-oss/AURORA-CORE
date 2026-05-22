# AURORA RUNTIME 3D CLOSEOUT GUIDEBOOK

Runtime 3D is the closeout and regression proof gate for the external calculation worker. It is not a new feature layer.

## Runtime 3 authority

Runtime 3 owns:

- External worker relationship.
- Shared global daemon status.
- Packaged watchdog status.
- Worker-required control file.
- Snapshot/job request export.
- Job-bus schema, job id, job type, resource class, and max runtime contract.
- Heartbeat/result/manifest path contracts.
- Acceptance/rejection of worker results.
- Rejection of stale, mismatched, incomplete, or non-authorized worker outputs.

Runtime 3 does not own L1-L4 source truth, Layer 5 advisory interpretation, FileIO/routes, Board/Dossier rendering, ranking, selection, or execution.

## Runtime 3D acceptance proof

Runtime 3D can close only when runtime evidence shows all required proofs for the active account root.

### Shared install proof

```text
worker_version=0.6.0_3c_job_bus_no_powershell_daemon
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
worker_version=0.6.0_3c_job_bus_no_powershell_daemon
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

A degraded second account root is allowed if that account has not been upgraded to the 3C snapshot/job envelope. It must not block closure for the active account, but it must be reported honestly.

### Per-account heartbeat/result proof

```text
schema_version=2
worker_version=0.6.0_3c_job_bus_no_powershell_daemon
last_job_bus_schema_version=job_bus_v1
last_job_id present
last_job_type=L5_DEEP_READINESS_SHELL
authority=calculation_support_only
trade_permission=false
```

```text
schema_version=2
source_snapshot_id matches MT5 latest snapshot
job_bus_schema_version=job_bus_v1
job_id matches MT5 latest job envelope
job_type=L5_DEEP_READINESS_SHELL
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

## Layer 5 handoff gate

Runtime 5 may consume deep calculation results only after Runtime 3D is accepted for the active account.

Until then, Runtime 5 may publish degraded advisory shell truth only.

Runtime 5 must consume L1/L2/L3/L4 owner gates and Runtime 3 accepted worker results. It must not create its own worker transport, result validator, FileIO route, ranking owner, selection owner, or execution owner.
