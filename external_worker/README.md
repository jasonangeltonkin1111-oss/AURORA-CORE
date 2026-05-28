# Aurora Gateway

This folder contains the Python implementation for Aurora Core Runtime 3 Calculation Gateway.

Internal file names may still use worker / AuroraWorker compatibility naming. Operator-facing folders and runtime proof surfaces use Gateway.

Current Gateway mode:

```text
r3_gateway_snapshot_validation_and_calculation_support_only
```

Shared package and status folder:

```text
Aurora Core/Gateway/
Aurora Core/Gateway/AuroraWorker/AuroraWorker.exe
Aurora Core/Gateway/Status/shared_worker_status.txt
Aurora Core/Gateway/Status/shared_worker_install_status.txt
```

Per-account Gateway IO folder:

```text
Aurora Core/<SERVER>/<ACCOUNT>/Workbench/Gateway/Control/worker_required.txt
Aurora Core/<SERVER>/<ACCOUNT>/Workbench/Gateway/Inbox/snapshot_latest.txt
Aurora Core/<SERVER>/<ACCOUNT>/Workbench/Gateway/Inbox/snapshot_latest.manifest
Aurora Core/<SERVER>/<ACCOUNT>/Workbench/Gateway/Status/worker_heartbeat.txt
Aurora Core/<SERVER>/<ACCOUNT>/Workbench/Gateway/Outbox/result_latest.txt
Aurora Core/<SERVER>/<ACCOUNT>/Workbench/Gateway/Outbox/result_latest.manifest
```

Run once:

```text
python external_worker/aurora_worker.py --root "<Aurora account root>"
```

Install and start the shared Gateway with the existing scripts:

```text
build_worker.ps1
install_worker_global.ps1
start_worker_global.ps1
status_worker_global.ps1
```

Example account root shape:

```text
Aurora Core/<SERVER>/<ACCOUNT>
```

Current checks:

- control file exists
- snapshot file exists
- manifest file exists
- server/account match the control file
- authority is calculation_support_only
- trade permission remains false
- row counts match
- payload checksum matches

Runtime authority boundary:

```text
authority=calculation_support_only
trade_permission=false
ranking_runtime=false unless a later approved layer explicitly owns ranking
selection_runtime=false unless a later approved layer explicitly owns selection
```

Packaging target remains:

```text
AuroraWorker.exe
```

That executable name is internal compatibility. The runtime folder and operator-facing surface are Gateway.
