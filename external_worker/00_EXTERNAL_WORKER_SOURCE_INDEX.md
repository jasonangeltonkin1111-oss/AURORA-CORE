# External Worker Source Index

## Purpose
This folder contains Runtime 3 / Calculation Gateway support files for Aurora Core.

Runtime 3 is calculation support only. It must not become broker truth, ranking truth, selection truth, trade permission, execution, FileIO owner, route owner, raw OHLC owner, or Board/Dossier renderer owner.

## Active files

- `aurora_worker.py` — active Python worker source. Owns snapshot validation, shared daemon loop, watchdog/repair probe modes, heartbeat/result writing, and calculation-support-only result envelopes.
- `aurora_worker_io.py` — active worker-side IO helper source used by worker modules. Owns bounded read retry and durable atomic text writes for worker outputs only.
- `aurora_worker_entrypoint.py` — daemon/once/shared-daemon entrypoint. Chains core validation then L11, L12, L13, L14, L15, and L16 calculation-support modules.
- `aurora_worker_l11.py` / `aurora_worker_l11_dispatch.py` — Layer 11 symbol ranking inside ranking_group support. Must not own taxonomy, group heat, group selection, candidate pool, correlation, Global Top 10, permission, or execution.
- `aurora_worker_l12.py` / `aurora_worker_l12_dispatch.py` — Layer 12 ranking_group heat / quality support. Must consume L11 outputs and must not build selected groups, candidate pools, correlation, Global Top 10, permission, or execution.
- `aurora_worker_l13.py` / `aurora_worker_l13_dispatch.py` — Layer 13 dynamic ranking_group selection support. Must consume L12 group outputs and must not build symbol candidates, correlation, Global Top 10, permission, or execution.
- `aurora_worker_l14.py` / `aurora_worker_l14_dispatch.py` — Layer 14 ranking_group leader candidate-pool support. Must consume L13 selected groups and L11 Top 5, preserving L12/L13 context. Must not run correlation, build Global Top 10, permit, alert, or execute.
- `aurora_worker_l15.py` / `aurora_worker_l15_dispatch.py` — Layer 15 correlation / diversity scoring support. Must consume the L14 candidate pool and may read Shared OHLC Store when available. Must not call MT5, poll brokers, create private OHLC caches, scan the full universe, build Global Top 10, permit, alert, or execute.
- `aurora_worker_l16.py` / `aurora_worker_l16_dispatch.py` — Layer 16 Global Top 10 builder support. Must consume L14/L15 outputs only, build an inspection basket, record rejects/unfilled slots, and must not permit, alert, execute, or validate an edge.
- `AuroraWorker.spec` — PyInstaller packaging spec for the worker executable.
- `install_worker_global.ps1` — Windows install/register script for the shared global scheduled-task daemon/watchdog path.
- `register_watchdog_safe.ps1` — Windows watchdog registration/support script.

## Runtime chain boundary

Current source chain:

```text
core snapshot validation
-> L11 symbol ranking inside ranking_group
-> L12 ranking_group heat / quality
-> L13 dynamic ranking_group selection
-> L14 ranking_group leader candidate pool
-> L15 correlation / diversity scoring
-> L16 Global Top 10 inspection basket
```

This chain remains calculation support. It is not trading runtime authority.

## Shared OHLC rule for L15+

Shared OHLC Raw Storage belongs to Runtime 1. Worker modules may read shared raw OHLC files only when a layer owns that calculation request. They must not call MT5, fetch broker history, or create private OHLC caches.

If Shared OHLC data is missing, stale, unreadable, or insufficient, the worker must publish degraded proof rather than fake accepted correlation.

L16 must not read raw OHLC or recompute correlation. L16 consumes L15 correlation/diversity outputs.

## Generated or packaged artifacts

Generated build/package/dist artifacts are not source authority. They are deployment artifacts and must not be patched as logic owners before the source files above are inspected.

After any active worker source change, any previously committed or local `AuroraWorker.exe`, `build/`, `dist/`, `.pkg`, `.pyz`, `.toc`, DLL, or zipped package must be treated as stale until rebuilt and runtime-proven.

`.gitignore` blocks future PyInstaller/generated worker artifacts. If generated artifacts are already tracked from older commits, do not treat them as current runtime proof. Remove tracked generated artifacts only after reference checks prove deployment/install scripts no longer require the repo copy.

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
- layer output files published
- Board/Dossier surfaces read those outputs

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
- No private OHLC caches.
- No full-universe correlation matrix unless a future control doc explicitly scopes and proves it.