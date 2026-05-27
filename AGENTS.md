# Aurora Core Agent Law

This repo is an MQL5 / MT5 trading-system codebase. Current source files outrank memory, screenshots, reports, prompts, and AI reasoning.

This is the single canonical agent instruction file for Aurora Core. Do not create duplicate AGENTS files, duplicate repo-law files, or competing instruction systems unless the user explicitly asks.

## Agent use policy

ChatGPT should attempt repo/audit/patch work first when connected tools allow it. Use Codex only when ChatGPT is blocked, lacks the required execution environment, struggles with the task, or the user explicitly asks for Codex. Codex must still obey this file.

If a connector blocks writes or cannot safely patch a file, report `BLOCKED` or `HOLD` honestly. Do not pretend files were updated.

## Required repo flow

1. Fetch current branch, current commit, and target file SHA before editing.
2. Read this file before touching code.
3. Read `README.md`, `control/02_MASTER_REPO_FILE_INDEX.md`, `control/00_CONTROL_INDEX.md`, and `control/01_CONTROL_GOVERNANCE.md` before serious source/layer work.
4. Inspect the active Runtime Owner before changing behavior.
5. Patch the existing owner only. No duplicate owners, no V2 helpers, no shadow systems, no broad rewrites.
6. Preserve routes, filenames, and account-safe paths unless current source proves a change is required.
7. Keep trade permission false unless a later explicit trading-permission task provides sufficient evidence and firm rules.
8. Do not claim compile, runtime, live, edge, or prop-firm readiness without actual evidence.
9. For parallel worker/merge work, read `blueprint/09_PARALLEL_WORK_AND_MERGE_CONTROL_BLUEPRINT.md` before commenting, rebasing, integrating, or merging.

If a connector only supports unsafe full-file replacement for a large owner file, stop and report:

`HOLD — use repo-native patch/Codex hunk editor. I inspected the owner but did not safely patch.`

## Parallel work law

Aurora may run many workers in parallel, but main remains conservative.

```text
Parallel work is useful.
Parallel ownership is dangerous.
Parallel merging without a control queue is forbidden.
```

Layer workers, specialist workers, design workers, and overseer/integration work have different authorities.

- Layer workers may patch only inside their assigned layer owner unless explicitly scoped otherwise.
- Specialist workers pressure-test and report/fix inside assigned specialist scope; they do not become mini-overseers.
- The overseer owns integration sequencing, collision resolution, shared-file decisions, final merge queue, and main protection.
- L20-L23 are design-stage/draft until the upstream dependency chain is source-integrated and runtime-proven.

Every worker branch must report:

```text
actual branch
current main SHA checked
head SHA
changed files
owner class for each changed file
shared-file collision risk
proof level
rollback path
current decision
```

Commit SHA is required. If there is no commit SHA or Git branch proof, the work is not eligible for merge review.

## Shared-file control law

These files are overseer-controlled during merge review:

```text
README.md
AGENTS.md
control/*
blueprint/*
mt5/00_MT5_SOURCE_INDEX.md
mt5/runtime_owners/00_RUNTIME_OWNERS_SOURCE_INDEX.md
external_worker/00_EXTERNAL_WORKER_SOURCE_INDEX.md
mt5/AuroraCore.mq5
mt5/core/AC_Config.mqh
FileIO owner files
route owner files
scheduler/timer/heartbeat files
external_worker/aurora_worker_entrypoint.py
external_worker/aurora_worker_io.py
publication renderer composition files
Board/Dossier/Workbench composition files
```

Changed files must be classified as:

```text
LAYER_OWNED
SHARED_SUPPORT
UPSTREAM_DOWNSTREAM
LOCKED_GOVERNANCE
GENERATED_ARTIFACT
UNKNOWN_RISK
```

Do not patch shared files casually from a layer branch. If a shared-file change is needed, state the collision and route it through overseer review.

## Runtime Owner boundaries

- Runtime 2 taxonomy authority lives in `mt5/runtime_owners/runtime_2_market_universe_taxonomy_lookup/AC_MarketUniverse*.mqh`.
- Runtime 1 Layer 3 broker symbol/spec metadata lives in `mt5/runtime_owners/runtime_1_foundation_truth_owner/layer_3_broker_symbol_specs_truth/AC_L3_*.mqh`.
- Runtime 1 Layer 5 Basic System Gate authority lives in `mt5/runtime_owners/runtime_1_foundation_truth_owner/layer_5_basic_system_gate/AC_BasicSystemGate.mqh`.
- Runtime 3 external calculation worker authority lives in `mt5/runtime_owners/runtime_3_external_calculation_worker_owner/` plus the active files indexed in `external_worker/00_EXTERNAL_WORKER_SOURCE_INDEX.md`.
- Runtime 7 publication wrappers live in `mt5/runtime_owners/runtime_7_publication_owner/publication_renderers/` as render/readback support, not calculation or trade authority.
- FileIO/path owners must stay single-owner systems.
- Dossiers display upstream truth; they must not become hidden truth owners.
- Broker metadata is advisory evidence only. Broker Country, Exchange, Sector, or Industry must not overwrite final taxonomy/ranking truth.

## Runtime 3 external worker law

Runtime 3 owns worker relationship, install/status detection, snapshot export, heartbeat/result validation, shared daemon/watchdog status truth, and Workbench diagnostics.

Runtime 3 must keep:

- `authority=calculation_support_only`
- `trade_permission=false`

Runtime 3 must not own broker truth, FileIO internals, Board/Dossier rendering authority, ranking truth, selection truth, strategy, execution, WebRequest, ML, or L5 heavy calculations unless explicitly scoped later.

When working on Runtime 3B autonomy, do not fake watchdog proof. A scheduled task existing is not proof that stale/missing daemon recovery works. `operator_cmd_required=false` may be claimed only after source and runtime output prove the daemon/watchdog path works.

## External worker source hygiene law

Active external-worker source authority is listed in `external_worker/00_EXTERNAL_WORKER_SOURCE_INDEX.md`.

Do not recreate or patch from one-shot emergency repair scripts that can rewrite active source, restore stale backups, stop/unregister scheduled tasks, or create `_aurora_*_backup_*` folders inside the repo. Such scripts are shadow authority unless explicitly scoped and quarantined.

Backup folders and packaged artifacts are not source truth. Before touching worker logic, inspect the active source files first:

1. `external_worker/aurora_worker.py`
2. `external_worker/aurora_worker_io.py`
3. `external_worker/aurora_worker_entrypoint.py`
4. `external_worker/install_worker_global.ps1`
5. `external_worker/register_watchdog_safe.ps1`
6. `external_worker/AuroraWorker.spec`

Patch source before rebuild artifacts. Do not claim packaged executable readiness unless the package was actually rebuilt and runtime-tested.

## File removal law

Do not remove files casually. Before removing any file, prove from source inspection that it is obsolete, duplicate, generated, harmful, or replaced by a verified path.

Before removal, report:

- file path
- references/imports/includes/tasks/scripts using it
- whether it is active, compatibility wrapper, stale, duplicate, generated artifact, or archive
- why removal is safer than keeping or demoting
- regression risk
- rollback path

Preserve compatibility wrappers unless replacement paths are proven and documented. If evidence is incomplete, keep the file and mark it for later cleanup.

## Performance law

Speed means maximum truthful throughput without starving MT5 or hiding degraded states.

Do not add or reintroduce without explicit proof:

- full-folder scans on hot cadence
- per-symbol file open/write/flush loops
- repeated CSV parse per symbol
- per-tick logging spam
- unbounded loops in OnTimer path
- all-symbol deep evidence collection
- full-universe correlation matrices
- worker startup per symbol
- renderer calculations that become owner logic
- private OHLC/tick/cache owners

Prefer cached owner packets, bounded drains, changed-state logging, batch writes, read-once/write-once per cycle where safe, selected-only deep evidence, explicit budget telemetry, and visible degraded states.

## Trading and permission law

Manual review/export is allowed.
Raw truth export is allowed.
Partial/degraded truth export is allowed when labelled.

But default state remains:

```text
trade_permission=false
auto_trade_allowed=false
entry_signal=false
prop_firm_ready=false
edge_validated=false
```

Forbidden unless future validation explicitly proves otherwise:

```text
best trade
confirmed buy
confirmed sell
high probability setup
safe setup
prop-ready
edge proven
```

Scores, ranks, candidate pools, heat values, candle geometry, Global Top 10, trader-chat export, and manual-review packets are not permission.

## Bucket research law

Online research is required when completing or repairing symbol buckets because corporate symbols, listings, sectors, and lifecycle states change. Use source tiers:

1. Official issuer pages, exchange pages, SEC filings, and primary company releases.
2. Reputable financial news/filing summaries for mergers, delistings, and ticker lifecycle changes.
3. Finance profiles only as cross-checks, not sole authority.
4. Broker metadata is advisory only and may be poisoned.

Every researched symbol row should capture:

- broker server
- broker file/export name
- broker symbol
- canonical ticker
- exchange/listing if known
- lifecycle state: active / acquired / delisted / renamed / stale-broker-symbol / unknown
- final broker group
- final aggregation group
- confidence
- evidence source note
- trade permission false

## Current researched symbol notes

Use these as prompts for verification, not as blind patch authority. Patch only after inspecting current rows.

- `BA` / `BA.x`: Boeing. Bucket target: `Industrials / Aerospace & Defense`.
- `JPM` / `JPM.x`: JPMorgan Chase. Bucket target: `Financial / Banks - Diversified` unless the project standard uses a more precise major-bank aggregation group.
- `UNH` / `UNH.x`: UnitedHealth Group. Bucket target: `Healthcare / Healthcare Plans` unless the project standard uses managed healthcare.
- `HOLX`: Hologic. Bucket target: `Healthcare / Medical Devices` or `Healthcare / Diagnostics & Research` depending on existing taxonomy vocabulary.
- `TPH`: Tri Pointe Homes. Bucket target: `Consumer Cyclical / Residential Construction` or existing equivalent.
- `CTRA`: Coterra Energy. Historical bucket target: `Energy / Oil & Gas E&P` or equivalent. Current lifecycle must be checked.
- `.xhkg` numeric HK symbols: broker Country `USA` / `United States` and Exchange `XNYM` are poisoned for trader-facing Dossiers. Hide from Dossier, count in Workbench diagnostics, and build external Yahoo symbol as zero-padded `.HK` where applicable.

## Bucket-system acceptance checks

Before claiming bucket completion, verify or explicitly report missing proof for:

- current generated row count and runtime Dossier count
- missing symbols and explicit lifecycle/source reason for each
- extra symbols count
- Unknown bucket count and reason for every unknown
- Ranking Group mismatch vs taxonomy authority count
- JPM, UNH, BA regression probes
- HOLX, TPH, CTRA lifecycle/bucket probes
- `.xhkg` Country USA / Exchange XNYM hidden from trader-facing Dossiers
- `.xhkg` zero-padded `.HK` external links
- no ISIN display in trader-facing Dossiers
- no `Not available` metadata filler in trader-facing Dossiers
- closed-symbol wording separates static specs from live quote/tick truth
- trade permission remains false

## Required final report

Every serious repo run must report:

- branch and current commit
- files inspected
- files changed
- active owner map
- what changed and why
- verification performed
- verification missing
- duplicate-owner / V2 / shadow-system scan result
- regression risk
- rollback path
- final decision: `PROCEED`, `HOLD`, `KILL`, or `TEST FIRST`

## Runtime 3B Windows autonomy evidence law

Runtime 3B Windows-side autonomy must separate evidence classes:

- source wired
- Python syntax passed
- PowerShell parse passed
- MetaEditor compile passed
- scheduled task registered
- daemon running
- watchdog recovered stale/missing daemon
- MT5 Workbench readback observed

Do not collapse these into one generic `done` claim.

A scheduled task existing is not proof that stale/missing daemon recovery works. `operator_cmd_required=false` may be claimed only after source and runtime output prove the daemon/watchdog path works.

## Codex/local branch intake law

When Codex reports work on a local branch or a branch name that is not the requested target branch, first prove where the work lives before continuing.

Required checks:

1. `git status -sb`
2. `git branch --show-current`
3. `git log --oneline --decorate --graph --all -20`
4. `git show --stat --oneline <reported_commit>` if a commit was reported
5. `git branch --contains <reported_commit>` if a commit was reported
6. `git diff --stat origin/main...HEAD`
7. `git diff --stat main...HEAD` when local main exists
8. `git branch -a --contains <reported_commit>` if a commit was reported

If reported work exists only locally, either push the branch or clearly report it as local-only. Do not redo the same patch on another branch until the existing work is located and audited.

If a PR branch is behind `main`, rebase or merge `main` only after inspecting conflicts. Do not overwrite `main` or force-push unless explicitly instructed.
