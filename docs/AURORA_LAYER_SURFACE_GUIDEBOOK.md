# AURORA LAYER SURFACE GUIDEBOOK

This guidebook is the repo standard for future layer work. It exists to stop drift between Board, Dossier, Workbench, Runtime owners, and external-worker calculation ownership.

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
- Runtime 3 owns external-worker relationship, snapshot/job request export, job-bus binding, worker heartbeat/result/manifest acceptance, and rejection of stale/mismatched worker results.
- Runtime 5 owns deep-inspection advisory interpretation and presentation only.
- Publication/FileIO/Route Service owns file paths and atomic writes.
- Board/Dossier Renderer Service renders prepared owner packets; it must not compute owner truth.

Later layers must consume earlier owner packets. They must not recalculate, mirror, backfill, correct, or override previous-layer truth.

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

Dossier may show per-symbol broker specs, market state, quote packet, advisory packet, readiness, blocker, source quality, and degraded truth. It must not become Workbench machine metadata.

### Workbench

Workbench is developer/operator proof. It is where meta non-trading data belongs.

Workbench sections should use machine-style rows:

```text
L5_DEEP_INSPECTION_ADVISORY
----------------------------------------
owner_name=...
status=...
scan_duration_ms=...
calculation_lane=...
source_truth_owner=...
```

Workbench may contain job IDs, snapshot IDs, checksums, owner contracts, counters, timings, rejection reasons, accepted/rejected status, source-quality ledgers, and no-duplicate-owner proof.

## Runtime 5 design law

Runtime 5 / Layer 5 is Deep Inspection Advisory Truth.

Runtime 5 may:

- Consume L1/L2/L3/L4 owner packets.
- Consume Runtime 3 accepted external-worker results.
- Interpret accepted deep-inspection result packets into advisory truth.
- Publish compact Board aggregates.
- Publish rich per-symbol Dossier advisory sections.
- Publish machine/meta Workbench proof.
- Publish degraded shell truth when not ready.

Runtime 5 must not:

- Own account, portfolio, prop-rule, or risk-envelope truth.
- Own market open/closed truth.
- Own broker specs/value/margin truth.
- Own live quotes/spread/tick freshness.
- Own Runtime 3 worker transport, job-bus binding, or result acceptance.
- Own FileIO or routes.
- Own ranking, selection, trade permission, execution, or strategy.
- Run heavy/deep calculation directly inside MT5 when the design requires external-worker calculation.

## Runtime 5 internals

Runtime 5 should be structured as a small owner that consumes already-owned truth and produces advisory surfaces.

Recommended internal states:

- `AC_L5_STATUS`
- `AC_L5_TRUST_STATE`
- `AC_L5_MAIN_BLOCKER`
- `AC_L5_ELIGIBLE_OPEN`
- `AC_L5_READY_SYMBOLS`
- `AC_L5_PENDING_SYMBOLS`
- `AC_L5_REFRESH_DURATION_MS`
- `AC_L5_CALCULATION_LANE`
- `AC_L5_EXECUTION_OWNER`
- `AC_L5_SOURCE_TRUTH_OWNER`
- `AC_L5_SURFACE_OWNER`

Recommended future per-symbol packet shape:

```text
symbol
market_state_from_l2
l3_specs_ready
l4_quote_ready
runtime3_result_accepted
runtime3_job_id
runtime3_job_type
readiness_state
readiness_reason
friction_advisory
volatility_advisory
structure_advisory
session_advisory
risk_advisory
kill_reason
quality_state
```

This packet must not duplicate raw L1-L4 data. It references owner state and explains advisory readiness.

## Runtime 5 Board standard

L5 Board section should stay compact:

```text
LAYER 5 - DEEP INSPECTION ADVISORY
----------------------------------------
Status:                     Shell only
Trust:                      Advisory Not Ready
Calculation Lane:           External Worker via Runtime 3
Runtime 3 Result Accepted:  FALSE
Eligible Open Symbols:      172
Ready Advisory Packets:     0
Pending Advisory Packets:   172
Readiness:                  Waiting for Runtime 3 worker
Scan Duration:              0 ms
Worst Blocker:              Waiting for Runtime 3 accepted external-worker job result before deep advisory calculations
Trade Permission:           FALSE
Ranking Runtime:            FALSE
Selection Runtime:          FALSE
```

No job IDs, checksums, snapshot hashes, long source-owner prose, or symbol lists on the Board.

## Runtime 5 Dossier standard

L5 Dossier should be rich but symbol-focused:

```text
LAYER 5 - DEEP INSPECTION ADVISORY
----------------------------------------
Status: Shell only
Trust: Advisory Not Ready
Market State Source: Layer 2
Market State: open
Calculation Lane: Runtime 3 external worker
Runtime 3 Result Accepted: FALSE
Readiness: Waiting for Runtime 3 worker
Blocker: Waiting for Runtime 3 accepted external-worker job result before deep advisory calculations

Advisory Packet
----------------------------------------
Friction Advisory: not_implemented
Volatility Advisory: not_implemented
Structure Advisory: not_implemented
Session Advisory: not_implemented
Risk Advisory: not_implemented
Invalidation / Kill Reason: not_implemented

Quality
----------------------------------------
Deep Calculations Active: FALSE
MT5 Heavy Calculation Active: FALSE
Degraded Publication: TRUE
Trade Permission: FALSE
Ranking Runtime: FALSE
Selection Runtime: FALSE
Owner Boundary: Consumes L1-L4 owner packets and Runtime 3 accepted worker result only; does not recalculate earlier-layer truth.
```

Dossier may include symbol-level advisory facts once Runtime 3 returns accepted deep results. It must not include full Runtime 3 machine proof unless needed as a short readiness line.

## Runtime 5 Workbench standard

Workbench carries the heavy meta and proof:

```text
L5_DEEP_INSPECTION_ADVISORY
----------------------------------------
owner_name=Runtime 5 - Deep Inspection Advisory Owner
layer_name=Layer 5 - Deep Inspection Advisory Truth
status=Shell only
trust_state=Advisory Not Ready
calculation_lane=Runtime3_external_worker_job_bus_required_for_deep_calculation
execution_owner=Runtime_3_external_worker_job_bus_and_result_acceptance
source_truth_owner=L1_L2_L3_L4_existing_owner_packets_only
surface_owner=Runtime_5_advisory_interpretation_shell_only
duplicate_owner_contract=no_duplicate_L1_L2_L3_L4_Runtime3_FileIO_route_board_dossier_ranking_selection_permission_execution_owner
board_layout_contract=compact_operator_summary_same_style_as_L1_L2_L3_L4
dossier_layout_contract=rich_per_symbol_advisory_packet_same_style_as_L3_L4_dossier_sections
workbench_layout_contract=machine_meta_diagnostics_same_style_as_L1_L2_L3_L4_workbench_sections
mt5_heavy_calculation_allowed=false
runtime3_worker_required_for_deep_calculation=true
runtime3_result_accepted=false
runtime3_job_bus_status=...
runtime3_job_bus_validation_status=...
runtime3_result_job_id=...
runtime3_result_job_type=...
runtime3_result_job_status=...
eligible_open=...
ready_symbols=...
pending_symbols=...
readiness=...
main_blocker=...
inputs_consumed=L1_L2_L3_L4_owner_packets_plus_Runtime3_accepted_worker_result_only
outputs_published=board_summary_dossier_advisory_section_workbench_machine_meta_status_row
permission=false
ranking_runtime=false
selection_runtime=false
fileio_owner=Publication_FileIO_Route_Service_only
publication_policy=print_degraded_truth_do_not_block_files
refresh_duration_ms=...
```

## Layer promotion gates

A layer can move forward only after:

1. Current repo source compiles.
2. Runtime evidence shows the intended surface output.
3. No previous-layer ownership was duplicated.
4. Board remains readable.
5. Dossier contains symbol truth without Workbench bloat.
6. Workbench contains the meta/debug/proof details.
7. Trade permission, ranking, selection, and execution remain false unless a later explicit owner is created and proven.
8. Rollback path is known.

## Runtime 3 before Runtime 5

Runtime 3C must be accepted before Runtime 5 can consume deep calculation results. Runtime 5 may publish degraded shell truth while Runtime 3 is pending, rejected, stale, mismatched, or absent.

Runtime 3 accepted proof must include at minimum:

```text
worker_version=0.6.0_3c_job_bus_no_powershell_daemon
schema_version=2
accepted_result=true
job_bus_status=Accepted
job_bus_validation_status=Accepted
authority=calculation_support_only
trade_permission=false
```

If Runtime 3 is not accepted, Runtime 5 must remain advisory-not-ready and degraded, but publication must continue.
