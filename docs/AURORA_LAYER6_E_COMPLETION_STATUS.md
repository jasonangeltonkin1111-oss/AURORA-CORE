# AURORA LAYER 6-E COMPLETION STATUS

## Current completion target

Layer 6 is Cost / Friction Ranking.

Layer 6 is complete only when this chain is true:

```text
Layer 5 pass set
  -> MT5 L6 input primitives
  -> Gateway/Python ranked_symbols.csv
  -> Gateway/Python ranked_symbols.manifest
  -> Gateway/Python ranked_symbols_top20.txt
  -> Gateway/Python SymbolRanks/<symbol>.txt
  -> MT5 Board/Workbench/Dossier renderer accepts the ranked sidecar
```

## Ownership boundary

```text
Layer 5 = only hard eligibility gate
Layer 6 = ranking/scoring only
Runtime 3 Gateway = calculation transport/support
Runtime 4 Surface Scoring Owner = Layer 6 scoring ownership
Runtime 7 Publication Owner = render/read proof files only
```

Layer 6 must not:

```text
trade
select baskets
grant permission
block Layer 5 pass symbols
own FileIO/path/timer authority
recalculate Layer 1-5 truth
parse full ranked_symbols.csv every heartbeat
parse full ranked_symbols.csv once per Dossier
```

## L6-E implementation contract

Gateway/Python writes:

```text
Outbox/Layers/Layer_6_Cost_Friction_Ranking/ranked_symbols.csv
Outbox/Layers/Layer_6_Cost_Friction_Ranking/ranked_symbols.manifest
Outbox/Layers/Layer_6_Cost_Friction_Ranking/ranked_symbols_top20.txt
Outbox/Layers/Layer_6_Cost_Friction_Ranking/SymbolRanks/<symbol>.txt
```

MT5 reads only:

```text
ranked_symbols.manifest
ranked_symbols_top20.txt
one SymbolRanks/<symbol>.txt while rendering that symbol Dossier
```

MT5 must not scan the full ranked CSV in the timer/Dossier loop.

## Acceptance rules

MT5 may show `Gateway Result Accepted: TRUE` only if:

```text
manifest status=complete
manifest input_count == row_count
row_count == AC_L5_GATE_PASS
authority=calculation_support_only
trade_permission=false
selection_runtime=false
ranking_runtime=true
ranked_symbols.csv exists
ranked_symbols_top20.txt exists
symbol_rank_files_written == row_count
```

If any rule fails, MT5 still publishes Board/Dossier/Workbench truth, but Layer 6 status is degraded/pending and trade/selection remain false.

## Dossier rule

For symbols that failed Layer 5:

```text
Rank State: not_ranked_l5_gate_failed
```

For Layer 5 pass symbols with accepted sidecar:

```text
Read only SymbolRanks/<symbol>.txt
Show rank_index, score, bucket, rank_state, score_quality, calculation_quality, spread_bps, effective cost, cost model state, commission model, and reason.
```

## Proof still required

The source patch must be proven by Jason with:

```text
MetaEditor compile result
Market Board.txt
Workbench/Status.txt
one L5-pass Dossier
one L5-failed Dossier
ranked_symbols.manifest
ranked_symbols_top20.txt
one SymbolRanks/<symbol>.txt
shared_worker_status.txt
```

Decision before proof: TEST FIRST.
