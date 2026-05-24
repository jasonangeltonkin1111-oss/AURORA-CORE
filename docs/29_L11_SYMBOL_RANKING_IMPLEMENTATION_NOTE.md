# 29 L11 SYMBOL RANKING IMPLEMENTATION NOTE

## Purpose

Record the Layer 11 implementation plan and proof gate for `external_worker/aurora_worker_l11.py`.

Layer 11 ranks symbols inside their own already-classified `ranking_group` using L10 taxonomy truth and L6-L9 independent surface scores.

It is not taxonomy authority, not group heat, not group selection, not Global Top 10, not a trade signal, and not trade permission.

---

## Runtime Boundary

```text
Runtime owner: Runtime 5 - Taxonomy / Ranking Group Owner
Layer: 11 - Symbol Ranking Inside Ranking Group
Authority: intra_group_inspection_priority_only
```

Consumes:

```text
L10 taxonomy_symbols.csv
L10 ranking_groups.csv
RenderIndex/l6_symbol_rank_index.csv
RenderIndex/l7_symbol_rank_index.csv
RenderIndex/l8_symbol_rank_index.csv
RenderIndex/l9_symbol_rank_index.csv
RenderIndex/render_index.manifest
```

Produces:

```text
Workbench/Gateway/Outbox/Layers/Layer_11_Symbol_Ranking_Inside_Ranking_Group/
    l11_input_surface_scores.csv
    l11_input_surface_scores.manifest
    ranked_symbols_by_group.csv
    ranked_symbols_by_group.manifest
    ranking_group_top5.csv
    ranking_group_top5.txt
    l11_symbol_ranking_summary.txt
    RankingGroups/<ranking_group>.ranked_symbols.csv
    RankingGroups/<ranking_group>.top5.txt
    SymbolRanks/<symbol>__<checksum>.txt
```

---

## Score Model

```text
L6 cost/friction: 25
L7 session relevance: 20
L8 movement/range: 25
L9 structure/location watch: 30
```

Formula:

```text
l11_group_score = weighted_available_average(L6,L7,L8,L9)
                  - missing_layer_penalty
                  - stale_layer_penalty
                  - risk_review_penalty
```

Missing scores are not zero. Missing scores are explicit unavailable components with penalties.

---

## Runtime Safety Flags

Every L11 file must keep:

```text
directional_validity=false
expectancy_validated=false
selection_runtime=false
trade_permission=false
entry_signal=false
```

---

## Local Proof From Runtime Package 18503(55).7z

Local dry-run against the uploaded runtime package produced:

```text
status=accepted
input_symbol_count=24
ranking_group_count=5
ranked_symbol_count=24
ranked_partial_count=0
risk_review_count=22
not_rankable_taxonomy_count=0
not_rankable_quality_count=0
top5_group_count=5
top5_symbol_count=18
symbol_rank_files_written=24
symbol_rank_files_actual=24
write_failed_count=0
trade_permission=false
selection_runtime=false
entry_signal=false
```

This proves the L11 module can consume current L10 + RenderIndex outputs and generate accepted Layer 11 files offline.

It does not yet prove packaged EXE runtime wiring until `aurora_worker.py`, PyInstaller metadata, installer expected version, and MT5 visual render hooks are wired and rebuilt.

---

## Remaining Wiring Gate

Before claiming L11 fully live:

```text
1. Wire aurora_worker.py to import and call publish_l11_symbol_ranking_inside_group after render index.
2. Append l11_* result_latest.txt lines.
3. Include aurora_worker_l11.py in PyInstaller/package metadata.
4. Add L11 visual renderer to Market Board, Dossier, and Workbench.
5. Rebuild AuroraWorker.exe.
6. Run MT5 runtime and prove result_latest.txt shows l11_symbol_ranking_status=accepted.
7. Prove Market Board and Dossiers render Layer 11.
```

---

## Decision

TEST FIRST for full runtime promotion.

The source module is ready. Full live-ready status requires worker wiring, packaging, and MT5 visual proof.
