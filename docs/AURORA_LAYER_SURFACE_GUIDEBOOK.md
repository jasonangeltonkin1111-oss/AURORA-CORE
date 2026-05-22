# AURORA LAYER SURFACE GUIDEBOOK

This guidebook is the repo standard for Board, Dossier, Workbench, Runtime-owner, Gateway, and later-layer surface work.

Start here before any Board, Dossier, Workbench, Runtime owner, or later-layer design work.

## Source-truth order

1. Current repo/source/config.
2. Runtime outputs from Common\\Files and Workbench.
3. Compile/runtime logs.
4. Official platform/API docs.
5. Reports, screenshots, prompts, memory, and AI reasoning.

Do not claim a layer is complete, safe, accepted, or ready for the next runtime unless source and runtime evidence prove it.

## Single-owner law

Every fact has one source owner.

- Layer 1 owns account, portfolio, history, exposure, and risk-envelope truth.
- Layer 2 owns market open/closed/session truth and deeper-layer cutoff truth.
- Layer 3 owns broker specs, contract/value/margin primitives, classification/fundamental-link support, and broker metadata warnings.
- Layer 4 owns live quote, tick freshness, bid/ask/last, spread, live MarketWatch activity, and open-symbol quote truth.
- Layer 5 is owned by Runtime 1 and owns only the Basic System Gate: first all-symbol pass/blocked eligibility from L2/L3/L4 owner packets.
- Layer 6+ owns later cost/friction/scoring/ranking work when implemented.
- Runtime 3 owns Gateway/external-worker relationship, snapshot/job request export, job-bus binding, worker heartbeat/result/manifest acceptance, and rejection of stale/mismatched worker results.
- Publication/FileIO/Route Service owns file paths and atomic writes.
- Board/Dossier Renderer Service renders prepared owner packets; it must not compute owner truth.

Later layers must consume earlier owner packets. They must not recalculate, mirror, backfill, correct, or override previous-layer truth.

## No-repeat data law

Do not repeat raw layer-owned data in later layers.

Examples:

- Layer 5 must not restate the Layer 2 market state as if it owns market open/closed truth.
- Layer 5 may say `L2 Gate: open/closed/not_ready` or `blocked_by_layer2_closed`, but the detailed market-state truth remains in Layer 2.
- Layer 5 must not repeat Layer 4 bid/ask/spread/tick details. It may say `L4 Gate: pass/fail/blocked`.
- Layer 5 must not repeat Layer 3 contract/value/margin primitives. It may say `L3 Gate: pass/fail/blocked`.
- Workbench may include references, IDs, gates, and owner links, but not duplicate full raw owner packets.

If a later layer needs an earlier-layer fact, use a compact reference/gate status and point the reader back to the owning layer section.

## Surface split

Aurora uses three main truth surfaces. Do not mix their jobs.

### Market Board

The Board is the operator cockpit. It must be compact, aligned, and readable.

Board sections should use the existing style:

```text
LAYER N - NAME
----------------------------------------
Status:                     ...
Key Count:                   ...
Key Readiness:               ...
Worst Blocker:               ...
Trade Permission:            FALSE
```

Board may show aggregate counts, readiness, worst blocker, permission state, and one-line next action. Board must not dump machine metadata, long ledgers, raw job IDs, full symbol lists, source ledgers, or deep audit prose.

### Dossier

Dossier is rich per-symbol truth. It may be verbose when that truth belongs to the current symbol.

Dossier sections should use readable headings:

```text
LAYER N - NAME
----------------------------------------
Status: ...
Source: ...
Quality: ...

Subsection
----------------------------------------
Field: value
```

Dossier may show per-symbol owner truth, source quality, readiness, blocker, and degraded truth. It must not become Workbench machine metadata, and it must not duplicate previous-layer raw data. Use gate references for earlier layers.

### Workbench

Workbench is developer/operator proof. It is where meta non-trading data belongs.

Workbench sections should use machine-style rows:

```text
L5_BASIC_SYSTEM_GATE
----------------------------------------
owner_name=...
status=...
scan_duration_ms=...
source_truth_owner=...
```

Workbench may contain job IDs, snapshot IDs, checksums, owner contracts, counters, timings, rejection reasons, accepted/rejected status, source-quality ledgers, packet fields, and no-duplicate-owner proof. Even here, avoid copying whole earlier-layer raw packets; reference their owner/gate/status.

## Layer 5 design law

Layer 5 is Basic System Gate. It is not Runtime 5. It is not deep inspection advisory. It is not cost/friction scoring. It is not selection. It is not permission.

Layer 5 may:

- Consume Layer 2 market-state gate truth.
- Consume Layer 3 specs/classification gate truth.
- Consume Layer 4 quote/spread-quality gate truth.
- Produce pass/blocked eligibility.
- Publish compact Board counts.
- Publish per-symbol Dossier gate status and gate reason.
- Publish Workbench counters and gate policy.
- Publish degraded truth when upstream layers are not ready.

Layer 5 must not:

- Own account, portfolio, prop-rule, or risk-envelope truth.
- Own market open/closed truth.
- Own broker specs/value/margin truth.
- Own live quotes/spread/tick freshness.
- Own Runtime 3 Gateway transport, job-bus binding, or result acceptance.
- Own FileIO or routes.
- Own friction/cost ranking, selection, trade permission, execution, or strategy.
- Run heavy/deep calculation directly inside MT5.
- Repeat earlier-layer raw data in its Board, Dossier, or Workbench surfaces.

## Layer 5 internals

Layer 5 is a small owner that consumes already-owned L2/L3/L4 packets and produces gate surfaces.

Current active owner states include:

- `AC_L5_READY`
- `AC_L5_STATUS`
- `AC_L5_TRUST_STATE`
- `AC_L5_MAIN_BLOCKER`
- `AC_L5_SCANNED`
- `AC_L5_GATE_PASS`
- `AC_L5_GATE_BLOCKED`
- `AC_L5_BLOCK_CLOSED_MARKET`
- `AC_L5_BLOCK_STALE_QUOTE`
- `AC_L5_BLOCK_MISSING_TICK`
- `AC_L5_BLOCK_INVALID_BIDASK`
- `AC_L5_BLOCK_MISSING_SPECS`
- `AC_L5_BLOCK_TRADE_MODE`
- `AC_L5_BLOCK_ABSURD_SPREAD`
- `AC_L5_BLOCK_CLASSIFICATION_REVIEW`
- `AC_L5_BLOCK_L2_NOT_READY`
- `AC_L5_BLOCK_L3_NOT_READY`
- `AC_L5_BLOCK_L4_NOT_READY`
- `AC_L5_LAST_UPSTREAM_KEY`
- `AC_L5_REFRESH_DURATION_MS`

Compatibility advisory field names may exist in source while older surfaces are renamed away, but they must map to Basic System Gate state only. They must not re-promote Layer 5 into advisory/scoring/ranking.

## Layer 5 Board standard

L5 Board section should stay compact:

```text
LAYER 5 - BASIC SYSTEM GATE
----------------------------------------
Status:                     Complete
Trust:                      Gate Ready
Scanned Symbols:            1200
Gate Pass:                  172
Gate Blocked:               1028
Closed / Not Open:          800
Stale Quote:                12
Missing Tick:               3
Invalid Bid/Ask:            1
Missing Specs:              7
Trade Mode Blocked:         0
Absurd Spread:              0
Classification Review:      205
Worst Blocker:              market_not_open
Scan Duration:              80 ms
Trade Permission:           FALSE
Ranking Runtime:            FALSE
Selection Runtime:          FALSE
```

No job IDs, checksums, snapshot hashes, long source-owner prose, symbol lists, or repeated L2/L3/L4 raw data on the Board.

## Layer 5 Dossier standard

L5 Dossier should be symbol-focused:

```text
LAYER 5 - BASIC SYSTEM GATE
----------------------------------------
Status: Complete
Trust: Gate Ready
Gate Purpose: First all-symbol hard eligibility gate; blocks garbage symbols before scoring/ranking layers.
Source Inputs: Layer 2 market state, Layer 3 specs/classification, Layer 4 quote/spread quality.
Gate Status: pass
Gate Reason: eligible_basic_system_gate
L2 Gate: open
L3 Gate: ready
L4 Gate: fresh
Blocked Closed / Not Open: FALSE
Blocked Stale Quote: FALSE
Blocked Missing Tick: FALSE
Blocked Invalid Bid/Ask: FALSE
Blocked Missing Specs: FALSE
Blocked Trade Mode: FALSE
Blocked Absurd Spread: FALSE
Blocked Classification Review: FALSE

Boundary
----------------------------------------
Calculation Owner: none; basic gate only
Gateway Required: FALSE
Ranking Runtime: FALSE
Selection Runtime: FALSE
Trade Permission: FALSE
Next Layer: Layer 6 Cost / Friction Ranking consumes L5 pass set only.
```

## Layer 6+ design law

Layer 6+ owns later scoring/ranking once implemented. Current Layer 6 is a skeleton surface only unless current source/runtime proves otherwise.

Layer 6 may later:

- Consume the Layer 5 pass set.
- Consume Layer 3/4 cost primitives or future MT5 cost snapshots.
- Use Runtime 3 Gateway calculation support.
- Produce ranked cost/friction outputs.

Layer 6 must not:

- Reopen symbols blocked by Layer 5.
- Own trade permission or execution.
- Override L2/L3/L4/L5 truth.
- Pretend Gateway results are accepted without Runtime 3 validation.

## Gateway / Runtime 3 surface law

Runtime 3 is calculation support only. It owns Gateway relationship/control/status/snapshot/result validation.

Runtime 3 surfaces may show:

- install status
- shared daemon status
- watchdog proof fields
- heartbeat freshness
- result acceptance/rejection
- job id, schema, checksum, row count, timestamp, and authority checks

Runtime 3 surfaces must not:

- Own broker truth.
- Own Board/Dossier rendering authority.
- Own ranking/scoring truth.
- Own trade permission or execution.
- Hide missing/stale/mismatched worker state.

Do not claim Runtime 3B complete from source alone. Keep evidence classes separate: source wired, Python syntax, PowerShell parse, package rebuild, scheduled task registration, daemon running, watchdog stale/missing recovery, and MT5 Workbench readback.

## Naming cleanup rule

Avoid mixing `Runtime 5`, `Layer 5`, and `L5 advisory` wording unless current source actually promotes that architecture. Current source contract is:

- Runtime 1 owns Layer 1 through Layer 5 foundation truth.
- Layer 5 is Basic System Gate.
- Runtime 3 is Gateway/calculation support.
- Layer 6+ owns future cost/friction/scoring/ranking.
- Trade permission remains false.
