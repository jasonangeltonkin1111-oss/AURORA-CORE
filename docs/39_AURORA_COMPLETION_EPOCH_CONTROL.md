# AURORA Completion Epoch Control

## Purpose

AURORA must not hang forever in `pending`, `partial`, or `degraded` states when the available evidence is complete enough for the layer's actual authority. It also must not stamp false accepted states.

This document records the completion rule that should be implemented in the existing worker cycle owner and relevant layer owners.

## Core law

Completion is not the same as perfect/full-history cleanliness.

A layer may complete when it has fulfilled its real source contract:

- required source files exist,
- files are readable/decodable,
- writes succeeded,
- upstream currentness is valid,
- freshness is fresh or aging,
- the layer has rendered/published the available truth.

A layer must not complete when there are:

- missing required source files,
- decode errors,
- write failures,
- stale or unknown freshness,
- invalid upstream currentness,
- empty required selection surfaces,
- source route contradiction.

## L18 / L19 history-limited completion rule

L18 and L19 read existing Runtime 1 Shared OHLC Store files. They must not fetch private OHLC, create private caches, or become a second OHLC owner.

Current problem:

- L18 marks itself `degraded` when source files are present but row count is less than the display cap.
- L19 marks itself `partial` when source files are present but fewer than requested rows exist.
- That can hang the full chain forever, especially on D1/W1 or broker-limited symbols.

Correct rule:

L18/L19 may be considered completion-ready when:

```text
source_files_expected > 0
source_files_found == source_files_expected
source_files_missing == 0
source_decode_errors == 0
write_failed_count == 0
selected_dossiers_decorated > 0
freshness_stale_count == 0
freshness_unknown_count == 0
```

This is not fake acceptance. It means:

```text
completion_state=completed_history_limited_all_sources_present_decodable_fresh_or_aging
```

The surface should still show:

```text
history_limited=true
source_files_partial=<count>
```

But it should not block the entire system forever just because a broker does not provide the full display cap of historical bars.

## L8 priority-window completion rule

L8 is different.

If L8 says priority-window files are missing or stale, that is not a harmless display-depth issue. L8 depends on M5/M15/H1/H4 priority windows for ranking quality.

L8 should complete only when:

```text
l8_rank_status=complete
```

If L8 remains `input_degraded`, the root fix is Runtime 1 priority-window seeding/top-up, not relaxing L8 completion.

## Cycle owner rule

The existing cycle owner should create a static completion epoch only when:

```text
L6 complete
L7 complete
L8 complete
L9 complete
L11 accepted
L12 accepted
L13 accepted
L14 accepted + current
L15 accepted + current
L16 accepted + current
L17 accepted
L18 accepted OR L18 history-limited-completion-ready
L19 accepted OR L19 history-limited-completion-ready
```

Then hold for five minutes:

```text
accepted_epoch_static_seconds=300
```

If not complete:

```text
cycle_completed_waiting_for_completion
```

and retry on bounded cadence, not every poll.

## Forbidden behavior

Do not create static accepted epochs from:

```text
missing
pending
write_degraded
stale
unknown freshness
source missing
decode error
invalid upstream currentness
```

Do not loosen correlation thresholds to force completion.

Do not add a new scheduler, new FileIO owner, new OHLC owner, or private OHLC cache.

## Runtime proof required

After implementation and live run, check:

```text
Workbench/Gateway/Status/gateway_cycle_status.txt
Workbench/Gateway/Outbox/surface_accepted_epoch.manifest
Workbench/Gateway/Outbox/result_latest.txt
Selection Desk/Groups/00_Correlation_Diversity_Diagnostics.txt
```

The accepted/completion epoch must show the exact completion state for L18/L19 so the operator knows whether it is full-history clean or history-limited complete.

## Decision

TEST FIRST.

Implement in the existing cycle owner and layer owners only. No shadow authority.
