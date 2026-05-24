# L16 Safe Source Lock

## Active source

The active Layer 16 implementation is:

```text
external_worker/aurora_worker_l16_safe.py
```

The compatibility file is:

```text
external_worker/aurora_worker_l16.py
```

`aurora_worker_l16.py` must stay a small import shim that re-exports the safe implementation for older imports.

## Rebuild checks

Before packaging the worker, these imports must pass:

```text
python -c "import aurora_worker_l16_safe; print('import_l16_safe=PASS')"
python -c "import aurora_worker_l16; print('import_l16_shim=PASS')"
python -c "import aurora_worker_l16_dispatch; print('import_l16_dispatch=PASS')"
python -c "import aurora_worker_entrypoint; print('import_entrypoint=PASS')"
```

`AuroraWorker.spec` must include:

```text
aurora_worker_l16_safe
aurora_worker_l16
aurora_worker_l16_dispatch
```

## Layer 16 boundary

L16 consumes L14 and L15 worker outputs only. It builds a held visible Global Top 10 inspection basket with clean and fallback display slots.

L16 must keep its safety fields false and must not become a strategy, signal, order, broker polling, or raw OHLC collector layer.

## Acceptance proof

Git source proof is not enough by itself. Close L16 only when runtime proof shows:

```text
worker_version=0.6.17_l17_deep_evidence_selection_split
l16_global_top10_status=accepted or degraded or write_degraded
l16_display_slot_count is present
l16_clean_selected_count is present
l16_fallback_selected_count is present
l16_hold_seconds=300
l16_visible_surface_state=static_held
```

If a diagnostic checks too early and returns missing L16 fields, wait for the daemon cycle and read `result_latest.txt` again before declaring failure.
