# 28 L10 WORKER WIRING PATCH GUIDE

## Purpose

This document records the exact safe wiring plan for enabling Python Layer 10 in `external_worker/aurora_worker.py` after the Runtime 2 taxonomy export bridge exists.

This exists because `aurora_worker.py` is a large daemon file and must not be partially overwritten or patched blindly.

---

## Current State

L10 source modules exist:

```text
external_worker/aurora_worker_l10_schema.py
external_worker/aurora_worker_l10_normalize.py
external_worker/aurora_worker_l10_universe_parser.py
external_worker/aurora_worker_l10_matcher.py
external_worker/aurora_worker_l10_quality.py
external_worker/aurora_worker_l10_group_builder.py
external_worker/aurora_worker_l10_path_planner.py
external_worker/aurora_worker_l10_publisher.py
external_worker/aurora_worker_l10.py
external_worker/aurora_worker_l10_source.py
```

MT5 now exports the Runtime 2 taxonomy lookup rows for Python L10:

```text
Workbench/Gateway/Outbox/Layers/Layer_10_Taxonomy_Classification/l10_runtime2_universe_rows.psv
Workbench/Gateway/Outbox/Layers/Layer_10_Taxonomy_Classification/l10_runtime2_universe_rows.manifest
```

The Python helper `l10_build_source_bundle(p.outbox, rows)` expects exactly that path.

---

## Absolute Wiring Rules

1. Keep L6-L9 behavior untouched.
2. L10 must run after snapshot validation and before `result_latest.txt` is written.
3. L10 must be pending-safe if Runtime 2 input is missing.
4. L10 must not block L6-L9 publication.
5. L10 must not create Top 5, Top 10, or copied Dossiers.
6. L10 must keep:

```text
selection_runtime=false
trade_permission=false
```

7. Do not add L10 to trade permission, ranking permission, or selection permission.
8. Do not modify `validate_snapshot()` envelope rules unless proven needed.

---

## Required Imports

Add near the other layer imports:

```python
from aurora_worker_l10 import EMPTY_L10_SUMMARY, publish_l10_taxonomy_classification
from aurora_worker_l10_source import l10_build_source_bundle
```

---

## Worker Version Update

Change:

```python
WORKER_VERSION = "0.6.10_render_index_l6_l9"
```

To:

```python
WORKER_VERSION = "0.6.11_l10_taxonomy"
```

---

## Add Result Line Helper

Add after `_append_render_index_lines()`:

```python
def _append_l10_lines(result_text: str, source_bundle, l10_summary, duration_ms: int) -> str:
    result_text += "l10_taxonomy_status=" + l10_summary.status + "\n"
    result_text += "l10_taxonomy_reason=" + l10_summary.reason + "\n"
    result_text += "l10_taxonomy_duration_ms=" + str(duration_ms) + "\n"
    result_text += "l10_source_status=" + source_bundle.status + "\n"
    result_text += "l10_source_reason=" + source_bundle.reason + "\n"
    result_text += "l10_broker_symbol_count=" + str(len(source_bundle.broker_symbols)) + "\n"
    result_text += "l10_runtime2_row_count=" + str(len(source_bundle.runtime2_rows)) + "\n"
    result_text += "l10_runtime2_input_path=" + source_bundle.runtime2_input_path + "\n"
    result_text += "l10_symbol_count=" + str(l10_summary.symbol_count) + "\n"
    result_text += "l10_ranking_group_count=" + str(l10_summary.ranking_group_count) + "\n"
    result_text += "l10_symbol_path_index_count=" + str(l10_summary.symbol_path_index_count) + "\n"
    result_text += "l10_accepted_strict_count=" + str(l10_summary.accepted_strict_count) + "\n"
    result_text += "l10_accepted_public_research_count=" + str(l10_summary.accepted_public_research_count) + "\n"
    result_text += "l10_review_required_count=" + str(l10_summary.review_required_count) + "\n"
    result_text += "l10_unknown_count=" + str(l10_summary.unknown_count) + "\n"
    result_text += "l10_omitted_count=" + str(l10_summary.omitted_count) + "\n"
    result_text += "l10_blocked_count=" + str(l10_summary.blocked_count) + "\n"
    result_text += "l10_conflict_count=" + str(l10_summary.conflict_count) + "\n"
    result_text += "l10_rank_allowed_count=" + str(l10_summary.rank_allowed_count) + "\n"
    result_text += "l10_selection_allowed_count=" + str(l10_summary.selection_allowed_count) + "\n"
    result_text += "l10_taxonomy_symbols_path=" + l10_summary.taxonomy_symbols_path + "\n"
    result_text += "l10_ranking_groups_path=" + l10_summary.ranking_groups_path + "\n"
    result_text += "l10_symbol_path_index_path=" + l10_summary.symbol_path_index_path + "\n"
    result_text += "l10_selection_runtime=false\n"
    result_text += "l10_trade_permission=false\n"
    return result_text
```

---

## Patch `run_once()`

Inside `run_once()`, after L9 publishes and before render index is okay.

Recommended placement: after L9 summary calculation and before render index:

```python
        l10_start_ns = time.perf_counter_ns()
        l10_source_bundle = l10_build_source_bundle(p.outbox, rows)
        if l10_source_bundle.status == "available":
            l10_summary = publish_l10_taxonomy_classification(
                outbox_root=p.outbox,
                broker_symbols=l10_source_bundle.broker_symbols,
                runtime2_universe_rows=l10_source_bundle.runtime2_rows,
                server=result.server,
            )
        else:
            l10_summary = EMPTY_L10_SUMMARY
        l10_duration_ms = max(0, (time.perf_counter_ns() - l10_start_ns) // 1_000_000)
```

Then after `_append_render_index_lines(...)`:

```python
        result_text = _append_l10_lines(result_text, l10_source_bundle, l10_summary, l10_duration_ms)
```

Do not change existing L6-L9 append lines.

---

## Optional Gateway Event Recording

Do not change `_record_gateway_result()` in the first wiring patch unless necessary. It has a wide signature used in multiple paths. First patch should prove result file lines and L10 output files before adding event recorder fields.

A later patch may add:

```text
l10_taxonomy_status
l10_taxonomy_reason
l10_symbol_count
l10_ranking_group_count
```

to `gateway_result_boundary` after runtime proof.

---

## Expected `result_latest.txt` Lines

After wiring, `result_latest.txt` should include:

```text
l10_taxonomy_status=accepted|pending|write_degraded
l10_taxonomy_reason=<reason>
l10_source_status=available|pending
l10_source_reason=<reason>
l10_broker_symbol_count=<n>
l10_runtime2_row_count=<n>
l10_symbol_count=<n>
l10_ranking_group_count=<n>
l10_symbol_path_index_count=<n>
l10_selection_runtime=false
l10_trade_permission=false
```

---

## Verification Required

Run locally after patch:

```powershell
python -m py_compile external_worker/aurora_worker.py external_worker/aurora_worker_l10*.py
```

Then rebuild/package worker and run the MT5 runtime.

Proof needed:

```text
l10_runtime2_universe_rows.psv exists
l10_runtime2_universe_rows.manifest exists
result_latest.txt shows l10_source_status=available
result_latest.txt shows l10_taxonomy_status=accepted or write_degraded, not exception
Layer_10_Taxonomy_Classification/taxonomy_symbols.csv exists
Layer_10_Taxonomy_Classification/ranking_groups.csv exists
Layer_10_Taxonomy_Classification/symbol_path_index.csv exists
Layer_10_Taxonomy_Classification/taxonomy_summary.txt exists
trade_permission=false everywhere
selection_runtime=false everywhere
```

---

## Failure Rules

If L10 source is missing:

```text
l10_source_status=pending
l10_source_reason=missing_l10_runtime2_universe_rows_input
l10_taxonomy_status=pending
```

L6-L9 must still publish.

If L10 throws an exception during local runtime, revert the worker wiring patch only. Keep the L10 source modules and MT5 Runtime2 export bridge for inspection unless they are proven to be the exception source.

---

## Decision

Do not wire blindly. Apply this exact patch locally or in a full-file-safe GitHub editing context, then syntax-test before rebuild.
