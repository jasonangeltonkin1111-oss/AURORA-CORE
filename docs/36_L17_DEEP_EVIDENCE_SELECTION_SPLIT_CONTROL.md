# 36 L17 DEEP EVIDENCE SELECTION SPLIT CONTROL

## Purpose

Layer 17 decides which already-visible Layer 16 display rows deserve future expensive evidence.

It is an attention-budget and depth-assignment layer. It is not an OHLC collector, tick collector, indicator collector, liquidity collector, setup detector, signal engine, trade permission layer, or execution layer.

## Proof Status

```text
source_contract=true
design_control=true
runtime_implemented=true only when active source proves L17 files are wired
runtime_proven=false unless rebuilt worker outputs prove current files are publishing
trade_permission=false
entry_signal=false
execution=false
```

## Question Answered

```text
Which visible L16 candidates should get future deep OHLC/tick/indicator/liquidity evidence?
```

## Source Inputs

L17 must consume visible L16 display rows only:

```text
Workbench/Gateway/Outbox/Layers/Layer_16_Global_Top10_Builder/l16_global_top10.csv
Workbench/Gateway/Outbox/Layers/Layer_16_Global_Top10_Builder/l16_global_top10_summary.txt
```

If the layer file is unavailable, L17 may use this degraded visible fallback:

```text
Selection Desk/Global/current_top10.csv
```

L17 must respect these L16 fields:

```text
display_slot_rank
global_top10_rank
selection_tier
clean_diversified
fallback_fill_used
fallback_reason
hold_visible
hold_state
l16_visible_surface_state
```

## Owned Outputs

```text
deep_evidence_selected
visible_only
alert_eligible_candidate=false by default
depth_assignment
evidence_budget_class
ohlc_depth
tick_depth
indicator_depth
liquidity_depth
selection_reason
selection_source
evidence_collection_scope
heavy_data_allowed
```

## Files Owned

```text
Workbench/Gateway/Outbox/Layers/Layer_17_Deep_Evidence_Selection_Split/l17_deep_evidence_selected.csv
Workbench/Gateway/Outbox/Layers/Layer_17_Deep_Evidence_Selection_Split/l17_deep_evidence_rejected.csv
Workbench/Gateway/Outbox/Layers/Layer_17_Deep_Evidence_Selection_Split/l17_depth_assignment_summary.csv
Workbench/Gateway/Outbox/Layers/Layer_17_Deep_Evidence_Selection_Split/l17_deep_evidence_summary.txt
Workbench/Gateway/Outbox/Layers/Layer_17_Deep_Evidence_Selection_Split/l17_deep_evidence.manifest
Selection Desk/Global/current_deep_evidence_split.csv
Selection Desk/Global/current_deep_evidence_split_manifest.txt
Selection Desk/Global/Deep Evidence Split.txt
```

Backward-compatible aliases may exist temporarily:

```text
l17_deep_evidence_selection_split.csv
l17_deep_evidence_selection_split_summary.txt
l17_deep_evidence_selection_split.manifest
```

## Selection Order

L17 must prioritize by L16 truth tier:

```text
1. CLEAN
2. CLEAN_DEGRADED
3. FALLBACK_SOFT_CORR
4. FALLBACK_MEDIUM_CORR
5. FALLBACK_NEXT_BEST_UNCLEAN
6. unknown/degraded tier
```

Fallback rows may be selected only when the clean/CLEAN_DEGRADED rows do not fill the capped evidence budget. Fallback rows must preserve fallback labels and must not be treated as clean diversified candidates.

## Depth Assignment Contract

Default source constants:

```text
L17_MAX_DEEP_SELECTED = 5
L17_FULL_DEPTH_LIMIT = 3
```

Clean rows inside full-depth limit:

```text
depth_assignment=full_deep_pack_request
evidence_budget_class=full_clean_budget
```

Clean rows after full-depth limit but still inside max budget:

```text
depth_assignment=standard_deep_pack_request
evidence_budget_class=standard_clean_budget
```

Fallback rows selected because clean rows did not fill budget:

```text
depth_assignment=fallback_limited_review_request
evidence_budget_class=fallback_limited_budget
```

Rows outside L17 budget:

```text
depth_assignment=visible_watch_only_no_expensive_collection
heavy_data_allowed=false
```

## Absolute Scope Law

```text
collects_ohlc=false
collects_ticks=false
collects_indicators=false
collects_liquidity=false
all_symbol_scan=false
broker_polling=false
private_ohlc_cache=false
trade_permission=false
entry_signal=false
execution=false
```

L17 may request later evidence by assigning depth. It must not physically collect the evidence.

## Forbidden

```text
No all-symbol deep OHLC collection.
No all-symbol tick collection.
No all-symbol indicator collection.
No all-symbol liquidity/DOM collection.
No MT5 broker polling from Python.
No private OHLC cache.
No correlation recalculation.
No L16 ranking override.
No trade permission.
No setup logic.
No buy/sell wording.
No CHOCH/BOS/FVG/OB/sweep confirmation.
No edge proof claim.
No alert wording that implies trade direction.
```

## Trading Meaning

```text
full_deep_pack_request = inspect deeply later, not trade
standard_deep_pack_request = gather moderate evidence later, not trade
fallback_limited_review_request = fallback visible row may get limited review only, not clean confidence
visible_watch_only_no_expensive_collection = visible but no heavy evidence budget
alert_eligible_candidate=false = no alert permission yet
```

L17 is still UNPROVEN for trading edge. It only protects compute budget and organizes future selected-symbol evidence collection.

## Acceptance Checks

```text
L17 consumes L16 held visible display rows only
L17 publishes selected and rejected CSVs
L17 output count never exceeds L16 visible candidate count
L17 selected count <= L17_MAX_DEEP_SELECTED
Fallback rows remain labelled fallback_limited, not clean
L17 manifest states no evidence collection and no all-symbol scan
L17 appends result_latest l17_* fields
L17 is wired after L16 in worker entrypoint
Surface accepted epoch includes L17 status
L17 does not alter L16 basket
L17 does not alter Dossiers
trade_permission=false
entry_signal=false
execution=false
```

## Decision

```text
TEST FIRST
```

Runtime proof required before calling L17 accepted/live-ready:

```text
python syntax passes
worker rebuild succeeds
worker status probe runs
L17 layer outputs appear
Selection Desk/Global L17 files appear
result_latest includes l17_* fields
surface_accepted_epoch includes l17 status
MT5 readback shows no timer/starvation regression
```
