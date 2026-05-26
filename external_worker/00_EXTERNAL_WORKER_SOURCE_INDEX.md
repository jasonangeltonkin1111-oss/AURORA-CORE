# External Worker Source Index

## Purpose
This folder contains Runtime 3 / Calculation Gateway support files for Aurora Core.

Runtime 3 is calculation support only. It must not become broker truth, ranking truth, selection truth, trade permission, execution, FileIO owner, route owner, raw OHLC owner, or Board/Dossier renderer owner.

## Active files

- `aurora_worker.py` — active Python worker source. Owns snapshot validation, shared daemon loop, watchdog/repair probe modes, heartbeat/result writing, and calculation-support-only result envelopes. It invokes L6, L7, L8, L9, L10, and render-index support during the core worker pass.
- `aurora_worker_io.py` — active worker-side IO helper source used by worker modules. Owns bounded read retry and durable atomic text writes for worker outputs only.
- `aurora_worker_entrypoint.py` — daemon/once/shared-daemon entrypoint. Chains core validation then L11, L12, L13, L14, L15, L16, L17, and L18 calculation-support modules. L19 is invoked by the L18 dispatch after L18 completes.
- `aurora_worker_l6_friction.py` — Layer 6 cost / friction ranking support. Must consume exported L6 primitives only and must not own trade permission, selection, execution, or broker truth.
- `aurora_worker_l7_session.py` — Layer 7 session relevance ranking support. Must consume exported L7 primitives only and must not decide open/closed truth, hard-gate symbols, select candidates, permit, alert, or execute.
- `aurora_worker_l8_movement.py` — Layer 8 movement / range ranking support. Must consume Layer 5 pass-set metadata plus Runtime 1 Shared OHLC Priority Window files only. Must not call MT5, call `CopyRates`, poll brokers, create a private OHLC cache, infer direction, select candidates, permit, alert, or execute. OHLC window freshness must be proved or visibly degraded before L8 movement scores are accepted.
- `aurora_worker_l9_structure.py` — Layer 9 structure / location geometry support. Must consume exported L9 primitives and shared surface context only. Must not create direction, entries, selection, permission, or deep evidence authority.
- `aurora_worker_l10.py` / `aurora_worker_l10_source.py` — Layer 10 taxonomy / ranking_group classification support. Must not convert taxonomy into trade permission, selection, execution, or signal authority.
- `aurora_worker_render_index.py` — render-index support for worker outputs. Must index/read worker sidecars for render surfaces only and must not calculate layer scores, rank, select, permit, alert, or execute.
- `aurora_worker_l11.py` / `aurora_worker_l11_dispatch.py` — Layer 11 symbol ranking inside ranking_group support. Must not own taxonomy, group heat, group selection, candidate pool, correlation, Global Top 10, permission, or execution.
- `aurora_worker_l12.py` / `aurora_worker_l12_dispatch.py` — Layer 12 ranking_group heat / quality support. Must consume L11 outputs and must not build selected groups, candidate pools, correlation, Global Top 10, permission, or execution.
- `aurora_worker_l13.py` / `aurora_worker_l13_dispatch.py` — Layer 13 dynamic ranking_group selection support. Must consume L12 group outputs and must not build symbol candidates, correlation, Global Top 10, permission, or execution.
- `aurora_worker_l14.py` / `aurora_worker_l14_dispatch.py` — Layer 14 ranking_group leader candidate-pool support. Must consume L13 selected groups and L11 Top 5, preserving L12/L13 context. Must not run correlation, build Global Top 10, permit, alert, or execute.
- `aurora_worker_l15.py` / `aurora_worker_l15_dispatch.py` — Layer 15 correlation / diversity scoring support. Must consume the L14 candidate pool and may read Shared OHLC Store when available. Must not call MT5, poll brokers, create private OHLC caches, scan the full universe, build Global Top 10, permit, alert, or execute.
- `aurora_worker_l16.py` / `aurora_worker_l16_safe.py` / `aurora_worker_l16_dispatch.py` — Layer 16 Global Top 10 builder support. `aurora_worker_l16.py` is a compatibility shim; `aurora_worker_l16_safe.py` is the active L16 implementation source. L16 must consume L14/L15 outputs only, build a held visible inspection basket, record clean/fallback display slots, preserve hold truth, and must not permit, alert, execute, or validate an edge.
- `aurora_worker_l17.py` / `aurora_worker_l17_dispatch.py` — Layer 17 Deep Evidence Selection Split support. Must consume L16 held visible display rows only, prefer CLEAN/CLEAN_DEGRADED rows, preserve fallback labels, cap deep evidence requests, publish selected/rejected split outputs, and must not collect OHLC/ticks/indicators/liquidity, poll brokers, create private OHLC caches, permit, alert, execute, or validate an edge.
- `aurora_worker_l18.py` / `aurora_worker_l18_dispatch.py` — Layer 18 Selected Raw OHLC Bar Pack support. Must read existing Shared OHLC Store seed files only, decorate canonical Selection Desk copied dossiers only, publish L18 status/Board overview counts, and must not call `CopyRates`, poll brokers, create private OHLC caches, write base Dossiers, calculate signals/patterns, permit, alert, or execute. L18 dispatch invokes L19 after L18 publication.
- `aurora_worker_l19.py` / `aurora_worker_l19_dispatch.py` — Layer 19 Candle Geometry and Structure support. Must read existing Shared OHLC Store seed files using the L18 selected-dossier scope, render latest 5 candles per timeframe into canonical selected copied dossiers, publish L19 status/Board overview counts, and must not call `CopyRates`, poll brokers, write Shared OHLC Store, create private OHLC caches, write base Dossiers, create trade signals, permit, alert, or execute. Current scope is Wave 1 single-candle structure only.
- `AuroraWorker.spec` — PyInstaller packaging spec for the worker executable.
- `install_worker_global.ps1` — Windows install/register script for the shared global scheduled-task daemon/watchdog path.
- `register_watchdog_safe.ps1` — Windows watchdog registration/support script.

## Runtime chain boundary

Current source chain:

```text
core snapshot validation
-> L6 cost / friction ranking
-> L7 session relevance ranking
-> L8 movement / range ranking
-> L9 structure / location geometry
-> L10 taxonomy / ranking_group classification
-> render index
-> L11 symbol ranking inside ranking_group
-> L12 ranking_group heat / quality
-> L13 dynamic ranking_group selection
-> L14 ranking_group leader candidate pool
-> L15 correlation / diversity scoring
-> L16 Global Top 10 held visible inspection basket
-> L17 Deep Evidence Selection Split
-> L18 Selected Raw OHLC Bar Pack dossier decoration
-> L19 Candle Geometry and Structure dossier decoration
```

This chain remains calculation/file-decoration support. It is not trading runtime authority.

## Shared OHLC rule for L8+

Shared OHLC Raw Storage belongs to Runtime 1. Worker modules may read shared raw OHLC files only when a layer owns that calculation/display request. They must not call MT5, fetch broker history, or create private OHLC caches.

L8 may read Runtime 1 Shared OHLC Priority Window files for movement/range ranking only. Missing, stale, unreadable, or insufficient OHLC must degrade visibly rather than fake accepted movement quality.

If Shared OHLC data is missing, stale, unreadable, or insufficient, the worker must publish degraded proof rather than fake accepted movement, fake correlation, fake L18 completion, or fake L19 structure completion.

L15 may read shared OHLC for candidate-pool correlation/diversity only.

L16 must not read raw OHLC or recompute correlation. L16 consumes L15 correlation/diversity outputs.

L17 must not collect raw OHLC, ticks, indicators, or liquidity. It only assigns later evidence budget for selected visible L16 display rows.

L18 may read existing Shared OHLC Store seed files and copy/render selected raw OHLC rows into canonical selected copied dossiers only. L18 must not call `CopyRates`, change Shared OHLC Store contracts, create new OHLC files/caches, touch base Dossiers, or infer trade signals.

L19 may read existing Shared OHLC Store seed files using the same selected copied dossier scope to calculate candle geometry and Wave 1 single-candle structure display. L19 must not call `CopyRates`, change Shared OHLC Store contracts, create new OHLC files/caches, touch base Dossiers, or infer trade signals.

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
- No packaged executable readiness claim after source changes unless package rebuild and runtime proof exists.
- No PowerShell calls inside the hot shared-daemon loop.
- No trade permission or execution authority.
- No broker polling from Python unless explicitly scoped later and still validated by MT5.
- No private OHLC caches.
- No full-universe correlation matrix unless a future control doc explicitly scopes and proves it.
- No all-symbol deep evidence collection.
