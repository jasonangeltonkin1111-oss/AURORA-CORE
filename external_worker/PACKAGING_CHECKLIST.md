# External Worker Packaging Checklist

Current goal: prove the packaged `AuroraWorker.exe` works before wiring EA auto-launch.

## Build

From PowerShell:

```powershell
cd "C:\Users\Jason\AppData\Roaming\MetaQuotes\Terminal\43C1572456A3A33910D4FE26B1396DC3\MQL5\Include\AURORA-CORE\external_worker"
.\build_worker.ps1
```

Expected output:

```text
dist\AuroraWorker\AuroraWorker.exe
```

## Install for account 18503

```powershell
.\install_worker_for_18503.ps1
```

Expected installed paths:

```text
C:\Users\Jason\AppData\Roaming\MetaQuotes\Terminal\Common\Files\Aurora Core\Upcomers-Server\18503\Workbench\External Worker\AuroraWorker\AuroraWorker.exe
C:\Users\Jason\AppData\Roaming\MetaQuotes\Terminal\Common\Files\Aurora Core\Upcomers-Server\18503\Workbench\External Worker\AuroraWorker.exe
```

The folder copy is for execution. The flat copy is for the current EA detection check.

## Run packaged daemon manually

```powershell
.\run_worker_for_18503.ps1
```

The PowerShell window should stay open while daemon mode runs.

## Required MT5 Workbench proof

After the worker daemon is running and the EA has refreshed Runtime 3, Workbench should show:

```text
exe_present=true
heartbeat_present=true
heartbeat_validation_status=Fresh
heartbeat_age_seconds <= 15
result_present=true
result_manifest_present=true
result_status=Accepted
result_validation_status=Accepted
accepted_result=true
result_snapshot_id == snapshot_id
result_row_count == snapshot_rows
result_payload_checksum == snapshot_payload_checksum
trade_permission=false
```

## Forbidden claims before this proof

Do not claim:

```text
EA auto-launch works
packaged worker is proven
worker is production-ready
worker is trade-ready
```

Auto-launch comes only after packaged-worker proof.
