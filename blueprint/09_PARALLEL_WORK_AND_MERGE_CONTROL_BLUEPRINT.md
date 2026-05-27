# 09 PARALLEL WORK AND MERGE CONTROL BLUEPRINT

## Purpose

This blueprint explains how Aurora Core is allowed to run many worker branches without creating duplicate authority, stale-branch merge damage, runtime-owner collisions, or trading-permission lies.

It is an architecture/control blueprint only. It does not prove compile success, runtime success, worker package readiness, MT5 output, trading edge, or prop-firm readiness.

## System identity lock

Aurora Core is a native MT5 / MQL5 market-intelligence, runtime-ownership, truth-publication, manual-review/trader-chat-export, and future-validation system.

It is not a finished trading edge.
It is not an auto-trading permission system.
It is not a signal seller.

Default safety state:

```text
trade_permission=false
auto_trade_allowed=false
entry_signal=false
prop_firm_ready=false
edge_validated=false
```

Raw truth export is allowed.
Partial/degraded truth export is allowed when labelled.
Manual trader review is allowed.
Trader-chat export is allowed when it preserves false permission state.

## Core rule

```text
Parallel work is useful.
Parallel ownership is dangerous.
Parallel merging without a control queue is forbidden.
```

Workers may develop in parallel on isolated branches. Main merges must be sequenced by the overseer after source, collision, proof, and dependency review.

## Lane model

### Lane 0 — Overseer / Control Tower

Owns integration control, not every layer implementation.

Responsibilities:

```text
current-main SHA tracking
branch and PR inventory
worker-roster mapping
shared-file collision table
duplicate branch resolution
merge queue
final direct fixes where scoped
main protection
landing proof
rollback plan
```

The overseer may comment, hold, kill-candidate, test-first, or merge when explicitly in merge mode. In audit-only mode it must not merge.

### Lane 1 — L1-L19 implementation workers

These workers can run in parallel, but they must stay inside their assigned layer boundary.

Merge dependency stages:

```text
Stage 1: L1-L5 foundation truth
Stage 2: L6-L9 surface scoring/context
Stage 3: L10-L16 taxonomy/selection scaffolding
Stage 4: L17-L19 selected evidence packs
```

Layer workers must not patch FileIO, route owners, scheduler, shared governance, source indexes, or other layer owner files unless the task explicitly scopes that change and the overseer accepts the collision.

### Lane 2 — L20-L23 design-stage workers

L20-L23 are future/deep/review/permission-adjacent layers. They may run in parallel as design-stage branches.

Allowed before upstream main proof:

```text
contracts
schemas
field lists
acceptance tests
draft scaffolds
surface design
manual-review export design
```

Forbidden before dependency proof:

```text
main merge
runtime authority
trade permission
entry signal
execution
prop-firm readiness
edge claims
```

Hard sequence:

```text
L20 can merge only after L19 runs on main.
L21 can merge only after L20 runs on main.
L22 can merge only after L21 runs on main.
L23 can merge only after L22 runs on main.
```

### Lane 3 — Specialist pressure-test workers

Specialists inspect, stress-test, and patch only inside assigned scope. They are not substitute overseers.

Core specialist lanes:

```text
code fixing / bug hunting
trading logic / risk
consistency conflict
runtime flow / contract
performance / budget
dossier visual truth surface
market board visual cockpit
workbench diagnostics proof
shared OHLC store audit
trading journal / account report
workflow / operator UX
```

Specialists classify findings as:

```text
INLINE FIX
SPECIALIST FIX
OVERSEER FIX
WORKER FIX
POST-MAIN FIX
KILL
```

They must state who owns the fix. They must not silently patch another owner's authority.

### Lane 4 — Post-main polish specialists

These run after integration batches because they depend on stable main truth:

```text
operator UX / workflow
market board visual polish
dossier visual polish
trading journal/account report
final report ledger cleanup
```

Surface polish before source stability is moving-target polish and should be held.

## Required control matrix

Every active worker branch should be tracked with this matrix:

```text
Worker:
Actual branch:
Expected roster branch:
Lane:
Layer / Specialist:
Primary focus:
Allowed files:
Forbidden files:
Runtime Owner:
Dependencies:
Open PR:
Current main SHA checked:
Head SHA:
Ahead/behind vs main:
Changed files:
Owner class:
Shared-file collision risk:
Duplicate branch risk:
Performance risk:
Trading-permission risk:
Evidence-contract risk:
Proof level:
Can work in parallel: Yes / No
Can merge now: Yes / No
Must remain draft: Yes / No
Current decision: CONTINUE / HOLD / KILL CANDIDATE / TEST FIRST / PROCEED
Next action:
Rollback path:
```

Commit SHA is required. If the worker cannot provide a commit SHA or Git branch proof, the work is not eligible for merge review.

## File classification

Every changed file must be classified:

```text
LAYER_OWNED
SHARED_SUPPORT
UPSTREAM_DOWNSTREAM
LOCKED_GOVERNANCE
GENERATED_ARTIFACT
UNKNOWN_RISK
```

Shared-support files are overseer-controlled during merge review, including:

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

## Collision policy

Collision risk categories:

```text
NONE
LOW_APPEND_ONLY
MEDIUM_SCHEMA_RISK
HIGH_SAME_FUNCTION
HIGH_OWNER_CONFLICT
KILL_DUPLICATE_AUTHORITY
```

Duplicate layer branches must be resolved before merge. The overseer chooses one source branch, salvages unique safe deltas if needed, and marks the others stale/held/kill-candidate. Duplicate owners must not land on main.

## Performance law

Speed means maximum truthful throughput without starving MT5 or hiding degraded states.

Forbidden unless explicitly scoped and proven:

```text
full-folder scans on hot cadence
per-symbol file open/write/flush loops
repeated CSV parse per symbol
per-tick logging spam
unbounded loops in OnTimer path
all-symbol deep evidence collection
full-universe correlation matrix
worker startup per symbol
renderer calculations that become owner logic
private OHLC/tick/cache owners
```

Preferred patterns:

```text
cached owner packets
append-only compatible schemas
bounded drains
changed-state logging
batch file writes
read-once/write-once per cycle where safe
selected-only deep evidence
worker-side heavy calculations only where owner law allows
explicit budget telemetry
degraded output instead of fake clean output
```

## Evidence and proof gates

Evidence classes stay separate:

```text
source wired
Python syntax/import passed
PowerShell parse passed
MQL5 static compile-risk sniff passed
MetaEditor compile passed
worker package rebuilt
scheduled task registered
daemon running
watchdog recovered stale/missing daemon
MT5 Workbench readback observed
Board/Dossier/Selection Desk runtime output observed
performance/starvation telemetry observed
```

Do not collapse these into `done`.

Source-present is not runtime-proven.
Compile proof is not runtime proof.
Runtime output is not trading permission.
Ranking/selection output is inspection only unless future validation explicitly upgrades it.

## Merge wave order

Default merge wave:

```text
1. Audit current main and branch heads.
2. Close or hold stale duplicates only after proof.
3. Merge/reconcile L1-L5.
4. Compile/test gate.
5. Merge/reconcile L6-L9.
6. Python/import + MT5 readback gate.
7. Merge/reconcile L10-L16.
8. Worker output/schema/readback gate.
9. Merge/reconcile L17-L19.
10. Selected-evidence output gate.
11. Keep L20-L23 draft until dependency chain is proven.
12. Run post-main visual/UX/report polish.
```

## Decision meanings

```text
CONTINUE = worker may keep working inside scope.
HOLD = stop and fix/report blocker before continuing.
KILL CANDIDATE = branch appears structurally unsafe; do not delete unless instructed.
TEST FIRST = source may be valid but needs proof before dependency or merge.
PROCEED = safe for the next explicitly scoped step; not a blanket live/trading approval.
```

## Final warning

The purpose of this blueprint is not to slow Aurora down. It is to prevent integration hell, duplicate authority, and false proof while preserving maximum safe parallel development.
