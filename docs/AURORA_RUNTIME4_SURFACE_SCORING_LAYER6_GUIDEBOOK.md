# AURORA RUNTIME 4 / LAYER 6 GUIDEBOOK

## Runtime 4 identity

Runtime 4 is the Surface Scoring Owner.

Runtime 4 is planned to own the ranking/scoring layers after the Layer 5 Basic System Gate:

```text
Layer 6 - Cost / Friction Ranking
Layer 7 - Session Relevance Ranking
Layer 8 - Movement / Range Ranking
Layer 9 - Structure / Location Geometry
```

Runtime 4 is not Runtime 3. Runtime 3 is the Calculation Gateway transport/support owner.

Runtime 4 is not Runtime 1. Runtime 1 owns foundation truth and the Layer 5 Basic System Gate.

Runtime 4 is not the Publication/FileIO/Route owner.

## Non-negotiable ranking law

Layer 5 is the only hard eligibility gate.

Layers 6 through 9 are ranking/scoring layers. They must not hard-block symbols that passed Layer 5.

For Layer 6, every Layer 5 pass symbol must appear in the Layer 6 ranked CSV/list.

Poor symbols get poor scores, degraded quality, or not-rankable-quality states. They do not disappear.

Use:

```text
ranked
ranked_degraded
not_rankable_quality
low_score
hostile_friction
```

Avoid for Layer 6-9 pass-set symbols:

```text
blocked
excluded
rejected
removed
trade_permission
```

Exception: a symbol that failed Layer 5 is not part of the Layer 6 input set. Its Dossier can say `not_ranked_l5_gate_failed`, but Layer 6 does not re-block it.

## Layer 6 purpose

Layer 6 answers:

```text
Of the symbols that passed Layer 5, which have the cleanest cost / friction profile?
```

Layer 6 does not answer:

```text
buy or sell
trade now
strategy edge
basket selection
permission
execution
```

Layer 6 is a cost/friction ranking layer only.

## Correct MT5/Python split

MT5 owns broker/account/source truth.

Python/Gateway owns scoring, sorting, summaries, and ranked CSV/list output.

MT5 owns final validation, acceptance, Board/Dossier/Workbench publication, and truth display.

Pipeline:

```text
Layer 3 / Layer 4 / Layer 5 source truth
        ↓
MT5 builds Layer 6 input from Layer 5 pass symbols
        ↓
MT5 calculates broker/account cost primitives with OrderCalcProfit
        ↓
MT5 writes Gateway job snapshot
        ↓
Gateway validates envelope and payload checksum
        ↓
Python calculates score, rank, bucket, summary, CSV/list
        ↓
Gateway writes result + manifest + ranked_symbols.csv
        ↓
MT5 validates job/snapshot/checksum/authority/staleness
        ↓
MT5 renders Board, Dossier, Workbench
```

Python does not call broker APIs and does not invent broker-real account-currency costs.

## Official MQL5 basis

Layer 4 should own quote truth through `SymbolInfoTick`, which returns current prices and last price update time in an MqlTick structure.

Layer 6 may consume Layer 4 quote packets, but should not duplicate Layer 4 quote ownership.

MT5 should calculate account-currency spread-cost primitives through `OrderCalcProfit`, because the function calculates estimated profit/loss for the current account and returns the value in account currency.

Timer work must remain bounded because MQL5 does not add a new Timer event if one is already queued or processing.

## Layer 6 input set

Input set:

```text
Layer 5 pass symbols only
```

Do not send all broker symbols to Layer 6.

Do not send Layer 5 failed symbols into the Layer 6 ranking job.

## MT5 input fields to Gateway

Per Layer 5 pass symbol, MT5 sends:

```text
symbol
l5_gate_status
l5_gate_reason
asset_class
ranking_group
digits
point
contract_size
volume_min
volume_step
volume_max
value_quality
margin_quality
quote_quality
surface_quality
bid
ask
mid
spread_points
spread_bps
tick_age_seconds
zero_spread_state
spread_cost_buy_1lot_account
spread_cost_sell_1lot_account
spread_cost_worst_1lot_account
spread_cost_buy_minlot_account
spread_cost_sell_minlot_account
spread_cost_worst_minlot_account
ordercalcprofit_buy_status
ordercalcprofit_sell_status
ordercalcprofit_minlot_status
ordercalcprofit_error_code
commission_status
slippage_status
```

## MT5 cost primitive calculations

For spread-cost simulation:

Buy spread cost:

```text
OrderCalcProfit(ORDER_TYPE_BUY, symbol, volume, ask, bid, profit)
```

Sell spread cost:

```text
OrderCalcProfit(ORDER_TYPE_SELL, symbol, volume, bid, ask, profit)
```

Use absolute value of the resulting loss as cost.

Calculate for:

```text
1.0 lot when valid for the symbol
volume_min
```

Do not assume min-lot cost scales linearly from 1-lot cost. Calculate min lot directly.

If 1.0 lot is outside the broker's valid volume range, mark 1-lot cost unavailable and continue with min-lot cost.

If buy and sell cost differ, use the worse value and set:

```text
cost_asymmetry_detected=true
```

## Gateway job envelope

Layer 6 job:

```text
job_bus_schema_version=job_bus_v1
job_requested_layer=L6
job_type=L6_COST_FRICTION_RANKING_V1
job_resource_class=light_serial
job_max_runtime_ms=3000
job_expected_output=l6_cost_friction_ranking_v1
source_truth_owner=Runtime4_Surface_Scoring_Owner_consuming_L5_pass_set_plus_L3_L4_packets_plus_MT5_cost_primitives
authority=calculation_support_only
trade_permission=false
ranking_runtime=true
selection_runtime=false
```

## Gateway validation before scoring

Gateway must reject the job without scoring if:

```text
job_id missing
snapshot_id missing
job_type mismatch
payload_checksum mismatch
authority != calculation_support_only
trade_permission != false
selection_runtime != false
```

If rejected, Gateway writes proof of rejection and does not crash.

## Python scoring output

Every Layer 5 pass symbol receives one ranked CSV row.

Rank states:

```text
ranked
ranked_degraded
not_rankable_quality
```

Score range:

```text
100 = cleanest cost/friction profile
0 = worst quality or not rankable quality
```

Penalties:

```text
spread_bps_penalty
account_cost_penalty
tick_age_penalty
quote_quality_penalty
surface_quality_penalty
value_quality_penalty
margin_quality_penalty
commission_unknown_penalty
slippage_unknown_penalty
cost_asymmetry_penalty
raw_data_quality_penalty
```

Buckets:

```text
elite_friction      score >= 90 and quality sufficient
good_friction       score >= 75
acceptable_friction score >= 60
expensive_friction  score >= 40
hostile_friction    score < 40
not_rankable_quality severe primitive failure / score floor
```

If commission is unknown, do not allow `elite_friction`; cap at `good_friction`.

Ranking order:

```text
friction_score descending
bucket quality
spread_bps ascending
spread_cost_worst_minlot_account ascending
tick_age_seconds ascending
symbol ascending
```

## Per-layer ranked CSV/list output

From Layer 6 onward, each Runtime 4 scoring layer must publish its ranked symbol list in a per-layer Gateway outbox folder.

Current legacy compatibility folder:

```text
Aurora Core\<SERVER>\<ACCOUNT>\Workbench\External Worker\Outbox\Layers\Layer_6_Cost_Friction_Ranking\
```

Future Gateway path after migration proof:

```text
Aurora Core\<SERVER>\<ACCOUNT>\Workbench\Gateway\Outbox\Layers\Layer_6_Cost_Friction_Ranking\
```

Required files:

```text
ranked_symbols.csv
ranked_symbols.manifest
ranked_symbols_top20.txt
```

CSV header v1:

```text
rank_index,symbol,layer_id,layer_name,friction_score,friction_bucket,rank_state,score_quality,calculation_quality,spread_bps,spread_points,spread_cost_worst_1lot_account,spread_cost_worst_minlot_account,round_trip_cost_estimate_1lot_ex_commission,round_trip_cost_estimate_minlot_ex_commission,tick_age_seconds,quote_quality,surface_quality,value_quality,margin_quality,commission_status,slippage_status,spread_bps_penalty,account_cost_penalty,tick_age_penalty,quote_quality_penalty,value_quality_penalty,margin_quality_penalty,commission_unknown_penalty,slippage_unknown_penalty,cost_asymmetry_penalty,reason
```

Manifest fields:

```text
schema_name=layer_ranked_symbols_manifest
schema_version=1
layer_id=6
layer_name=Layer 6 - Cost / Friction Ranking
owner_name=Runtime 4 - Surface Scoring Owner
job_type=L6_COST_FRICTION_RANKING_V1
source_snapshot_id=...
job_id=...
row_count=...
ranked_count=...
ranked_degraded_count=...
not_rankable_quality_count=...
payload_checksum=...
authority=calculation_support_only
trade_permission=false
ranking_runtime=true
selection_runtime=false
```

The top20 text file is human-readable only. It is not source authority.

## Standard result package

Gateway also writes the standard result pair:

```text
result_latest.txt
result_latest.manifest
```

Layer 6 result header includes:

```text
schema_name=l6_cost_friction_ranking_result
schema_version=1
source_snapshot_id=...
job_bus_schema_version=job_bus_v1
job_id=...
job_type=L6_COST_FRICTION_RANKING_V1
job_status=complete
result_status=complete
row_count=...
payload_checksum=...
authority=calculation_support_only
trade_permission=false
ranking_runtime=true
selection_runtime=false
ranked_csv_path=Outbox\Layers\Layer_6_Cost_Friction_Ranking\ranked_symbols.csv
```

## Board design

```text
LAYER 6 - COST / FRICTION RANKING
----------------------------------------
Status:                     Complete / Pending / Degraded
Trust:                      Ranking Ready / Gateway Pending / Degraded
Owner:                      Runtime 4 - Surface Scoring Owner
Gateway Required:           TRUE
Gateway Result Accepted:    TRUE/FALSE
Input Source:               Layer 5 pass set only
L5 Pass Symbols:            ...
Ranked Symbols:             ...
Ranked Degraded:            ...
Not Rankable Quality:       ...
Elite Friction:             ...
Good Friction:              ...
Acceptable Friction:        ...
Expensive Friction:         ...
Hostile Friction:           ...
Best Friction Symbol:       ...
Best Score:                 ...
Worst Ranked Symbol:        ...
Worst Score:                ...
CSV Output:                 Outbox\Layers\Layer_6_Cost_Friction_Ranking\ranked_symbols.csv
Main Blocker:               ...
Gateway Job:                L6_COST_FRICTION_RANKING_V1
Calculation Duration:       ... ms
Ranking Runtime:            TRUE
Selection Runtime:          FALSE
Trade Permission:           FALSE
```

Board must not dump the full ranked symbol list.

## Dossier design

For Layer 5 pass symbols:

```text
LAYER 6 - COST / FRICTION RANKING
----------------------------------------
Status: Complete / Degraded
Owner: Runtime 4 - Surface Scoring Owner
Gateway Required: TRUE
Gateway Result Accepted: TRUE
L5 Gate Status: pass
Rank Index: ... / ...
Friction Score: ... / 100
Friction Bucket: ...
Rank State: ranked / ranked_degraded / not_rankable_quality
CSV Source: Outbox\Layers\Layer_6_Cost_Friction_Ranking\ranked_symbols.csv

Cost Snapshot
----------------------------------------
Spread Points: ...
Spread BPS: ...
Worst Spread Cost 1 Lot: ...
Worst Spread Cost Min Lot: ...
Round Trip Estimate 1 Lot Ex Commission: ...
Round Trip Estimate Min Lot Ex Commission: ...

Quality
----------------------------------------
Quote Quality: ...
Tick Age Seconds: ...
Value Quality: ...
Margin Quality: ...
Commission Status: ...
Slippage Status: ...
Calculation Quality: ...

Penalties
----------------------------------------
Spread BPS Penalty: ...
Account Cost Penalty: ...
Tick Age Penalty: ...
Quote Quality Penalty: ...
Value Quality Penalty: ...
Margin Quality Penalty: ...
Commission Unknown Penalty: ...
Slippage Unknown Penalty: ...
Cost Asymmetry Penalty: ...
Reason: ...

Boundary
----------------------------------------
Source Owner: Layer 5 pass set + Layer 3/4 packets + MT5 cost primitives
Scoring Owner: Runtime 4 - Surface Scoring Owner
Calculation Support: Runtime 3 Gateway
Selection Runtime: FALSE
Trade Permission: FALSE
Execution: FALSE
```

For Layer 5 failed symbols:

```text
LAYER 6 - COST / FRICTION RANKING
----------------------------------------
Status: Not Ranked
Owner: Runtime 4 - Surface Scoring Owner
L5 Gate Status: failed
Rank State: not_ranked_l5_gate_failed
Selection Runtime: FALSE
Trade Permission: FALSE
```

## Workbench design

```text
L6_COST_FRICTION_RANKING
----------------------------------------
owner_name=Runtime 4 - Surface Scoring Owner
layer_name=Layer 6 - Cost / Friction Ranking
status=Complete / Pending / Degraded
trust_state=Ranking Ready / Gateway Pending / Degraded
gateway_required=true
gateway_result_accepted=true/false
source_truth_owner=L5_pass_set_plus_L3_L4_owner_packets_plus_mt5_ordercalcprofit_primitives
calculation_support_owner=Runtime3_Calculation_Gateway
job_bus_schema_version=job_bus_v1
job_type=L6_COST_FRICTION_RANKING_V1
job_id=...
snapshot_id=...
payload_checksum=...
input_l5_pass_symbols=...
ranked_symbols=...
ranked_degraded_symbols=...
not_rankable_quality_symbols=...
elite_friction_count=...
good_friction_count=...
acceptable_friction_count=...
expensive_friction_count=...
hostile_friction_count=...
best_symbol=...
best_score=...
median_spread_bps=...
median_min_lot_cost=...
ranked_csv_path=Outbox\Layers\Layer_6_Cost_Friction_Ranking\ranked_symbols.csv
ranked_manifest_path=Outbox\Layers\Layer_6_Cost_Friction_Ranking\ranked_symbols.manifest
commission_known_count=...
commission_unknown_count=...
slippage_model=not_modelled_v1
calculation_quality=...
main_blocker=...
gateway_result_age_seconds=...
calculation_duration_ms=...
ranking_runtime=true
selection_runtime=false
trade_permission=false
```

## Refresh policy

Layer 6 should run only when stable input changes.

Refresh key:

```text
build_version
job_type_version
account_number
server
account_currency
L5 pass set hash
L3 cache key
L4 stable refresh generation
```

Do not refresh on every board tick.

Minimum interval for first implementation:

```text
30 seconds
```

## Acceptance tests

Layer 6 is accepted only when:

```text
MetaEditor compile clean
Gateway job_type=L6_COST_FRICTION_RANKING_V1
Gateway result accepted
ranked_symbols.csv exists
ranked_symbols.manifest exists
ranked_symbols_top20.txt exists
CSV row_count equals Layer 5 pass count
not_rankable_quality symbols are present, not removed
authority=calculation_support_only
trade_permission=false
ranking_runtime=true
selection_runtime=false
Board summary compact
Dossier per-symbol detail present
Workbench machine proof present
no timer overload
no popup
```

## Kill conditions

Hold or kill the implementation if:

```text
Layer 6 hard-blocks Layer 5 pass symbols
Layer 6 ranks symbols that failed Layer 5 as normal candidates
Python owns broker/account truth
Gateway grants permission
selection appears in Layer 6
trade permission appears in Layer 6
Board becomes a full CSV dump
L6 recalculates L2/L3/L4 ownership
stale or mismatched Gateway result is accepted
checksum mismatch is accepted
job_id mismatch is accepted
OnTimer overload appears
```

## Implementation sequence

L6-A:

```text
Guidebook and contract only
```

L6-B:

```text
MT5 Runtime 4 / Layer 6 skeleton surfaces with pending Gateway state
```

L6-C:

```text
MT5 snapshot export from L5 pass set with OrderCalcProfit primitives
```

L6-D:

```text
Gateway Python handler for L6_COST_FRICTION_RANKING_V1 and ranked CSV/list output
```

L6-E:

```text
MT5 result validation and Board/Dossier/Workbench rendering
```

L6-F:

```text
Regression tests: stale result, job mismatch, checksum mismatch, no hard-blocking, no permission
```

## Runtime 4 future layer symmetry

The per-layer ranked CSV/list rule applies from Layer 6 onward:

```text
Layer_6_Cost_Friction_Ranking/ranked_symbols.csv
Layer_7_Session_Relevance_Ranking/ranked_symbols.csv
Layer_8_Movement_Range_Ranking/ranked_symbols.csv
Layer_9_Structure_Location_Geometry/ranked_symbols.csv
```

Each layer must include the real layer name in folder names, manifests, Board, Dossier, and Workbench.

Each layer consumes previous ranked lists but must not duplicate earlier owners.

Layer 7 consumes Layer 6 ranking output plus session data.
Layer 8 consumes Layer 7 ranking output plus range/movement data.
Layer 9 consumes Layer 8 ranking output plus structure/location geometry.

No layer grants trade permission.
