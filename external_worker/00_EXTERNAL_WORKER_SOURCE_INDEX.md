# External Worker Source Index

## Purpose
This folder contains Runtime 3 / Calculation Gateway support files for Aurora Core.

Runtime 3 is calculation support only. It must not become broker truth, ranking truth, selection truth, trade permission, execution, FileIO owner, route owner, or Board/Dossier renderer owner.

## Active files

- `aurora_worker.py` — active Python worker source. Owns snapshot validation, shared daemon loop, watchdog/repair probe modes, heartbeat/result writing, and calculation-support-only result envelopes.
- `aurora_worker_io.py` — active worker-side IO helper source used by `aurora_worker.py`.
- `AuroraWorker.spec` — PyInstaller packaging spec for the worker executable.
- `install_worker_global.ps1` — Windows install/register script for the shared global scheduled-task daemon/watchdog path.
- `register_watchdog_safe.ps1` — Windows watchdog registration/support script.

## Generated or packaged artifacts

Generated build/package/dist artifacts are not source authority. They are deployment artifacts and must not be patched as logic owners before the source files above are inspected.

After `aurora_worker.py` or `aurora_worker_io.py` changes, any previously committed or local `AuroraWorker.exe`, `build/`, `dist/`, `.pkg`, `.pyz`, `.toc`, DLL, or zipped package must be treated as stale until rebuilt and runtime-proven.

`.gitignore` now blocks future PyInstaller/generated worker artifacts. If generated artifacts are already tracked from older commits, do not treat them as current runtime proof. Remove tracked generated artifacts only after reference checks prove deployment/install scripts no longer require the repo copy.

## Removed unsafe repair scripts

The following one-shot repair scripts were removed from active `main` because they could rewrite active worker/source files, restore stale backups, stop/unregister scheduled tasks, or create new backup folders from inside the repo:

- `external_worker/aurora_recovery_hotfix_v2.py`
- `external_worker/aurora_full_repair_no_install.py`

Do not recreate one-shot repair scripts in this folder unless the task explicitly scopes them, they are clearly marked non-runtime, and they cannot masquerade as active Runtime 3 authority.

## Backup folder policy

Backup folders such as `_aurora_*_backup_*` are not active source authority. They must not be used for patching, packaging, or worker deployment. If retained temporarily, they are evidence only. Prefer deleting or moving backup snapshots out of active source after reference checks prove they are unused.

## Proof limits

Do not claim Runtime 3B complete from source alone. Evidence must stay separated:

- source wired
- Python syntax passed
- PowerShell parse passed
- packaged executable rebuilt
- scheduled task registered
- daemon running
- watchdog recovered stale/missing daemon
- MT5 Workbench readback observed

A scheduled task existing is not proof of watchdog recovery. `operator_cmd_required=false` may be claimed only after source and runtime output prove the daemon/watchdog path works.

## No-go rules

- No duplicate worker owners.
- No V2/shadow repair scripts.
- No Git-tracked emergency backups treated as source.
- No generated build/dist/package artifact treated as source truth.
- No packaged executable readiness claim after source changes unless package rebuild and runtime proof exist.
- No PowerShell calls inside the hot shared-daemon loop.
- No trade permission or execution authority.
- No broker polling from Python unless explicitly scoped later and still validated by MT5.
