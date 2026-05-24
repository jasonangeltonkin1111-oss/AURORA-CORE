# L6 Runtime Freshness Repair Notes

Runtime proof showed L6 sidecars are generated, but MT5 correctly rejected stale ranked output when the latest L5/input primitive count moved ahead of the Gateway result.

Required fixes before Layer 7:

1. Gateway daemon must be running as shared-daemon after install, not only watchdog_probe / repair_probe.
2. Gateway package must be rebuilt after source changes; source patch alone is not runtime proof.
3. L6 publisher should clear old SymbolRanks/*.txt before writing current ranks, so stale symbol rank files cannot survive universe/L5 count changes.
4. If l6_input_primitives.csv is missing, stale ranked_symbols.csv and ranked_symbols_top20.txt must not be treated as current proof.
5. MT5 snapshot metadata must stop saying no_l6_ranking / future_L6D.

Acceptance target:

- worker_mode proves shared-daemon/shared_validator_daemon freshness.
- latest snapshot id equals result snapshot id.
- L5 pass count equals l6 input row_count equals ranked manifest input_count equals ranked manifest row_count.
- Gateway Result Accepted is TRUE.
- Dossier shows actual rank index, friction score, and friction bucket.

Layer 7 remains HOLD until this is proven.

## L6 cost/friction scope guardrail

L6 must remain a cost and friction layer only. It must not absorb setup logic, SMC concepts, candle patterns, liquidity narratives, trade direction, entry timing, signal confidence, or permission logic.

Allowed L6 primitives and outputs:

- spread
- spread points
- spread bps
- spread cost via MT5 `OrderCalcProfit` primitives
- effective minimum-lot cost
- cost model comparison and mismatch flags
- commission unknown penalty
- slippage unknown penalty
- tick age / quote quality penalty
- friction score and friction bucket

L6 may later feed L22/L23 risk geometry, but it must not calculate L22/L23 trade geometry itself.

Future downstream fields reserved for L22/L23 consumers:

- `spread_to_stop_ratio`
- `expected_r_after_cost`

Reserved means: future layers may consume L6 spread/cost primitives to calculate those values after a real stop distance, target model, setup context, broker cost model, and prop-risk profile exist. L6 must not invent stop distance, target distance, trade direction, R expectation, setup validity, or trade permission.

Decision rule: if a proposed L6 change needs candle interpretation, liquidity interpretation, stop placement, target placement, setup classification, or directional bias, reject it from L6 and move it to the correct later layer.
