# 29 L11 SYMBOL RANKING IMPLEMENTATION NOTE

## Purpose

Record the merged Layer 11 implementation contract, source wiring, and runtime proof gates.

Layer 11 ranks symbols inside their own already-classified `ranking_group` using L10 taxonomy truth and L6-L9 independent surface scores.

Layer 11 is not taxonomy authority, not ranking_group heat, not group selection, not Global Top 10, not a trade signal, not strategy validation, and not trade permission.

---

## Runtime Boundary

```text
Runtime owner: Runtime 5 - Taxonomy / Ranking Group Owner
Layer: 11 - Symbol Ranking Inside Ranking Group
Authority: intra_group_inspection_priority_only
```

Runtime support split:

```text
Runtime 3 / external_worker: calculates heavy L11 intra-group ranking outputs.
Runtime 7 publication renderers: render Board, Dossier, Workbench, and visible Selection Desk surfaces.
Existing FileIO/path owners: remain the only file/path owners.
```

No duplicate FileIO owner, route owner, taxonomy owner, selection owner, permission owner, or strategy owner is introduced.

---

## Merged Source Wiring

Merged by PR #38:

```text
external_worker/aurora_worker_l11.py
external_worker/aurora_worker_l11_dispatch.py
external_worker/aurora_worker_entrypoint.py
external_worker/AuroraWorker.spec
external_worker/aio_rebuild_install_l10_proof.sh
mt5/runtime_owners/runtime_7_publication_owner/publication_renderers/AC_Layer11SelectionGroupsRenderer.mqh
mt5/runtime_owners/runtime_7_publication_owner/publication_renderers/AC_MarketBoardRenderer.mqh
mt5/runtime_owners/runtime_7_publication_owner/publication_renderers/AC_PublicationRenderers.mqh
```

PR #37 was an earlier draft module-only PR and is superseded by PR #38 plus this implementation note.

---

## Inputs

L11 consumes:

```text
Workbench/Gateway/Outbox/Layers/Layer_10_Taxonomy_Classification/taxonomy_symbols.csv
Workbench/Gateway/Outbox/Layers/Layer_10_Taxonomy_Classification/ranking_groups.csv
Workbench/Gateway/Outbox/RenderIndex/render_index.manifest
Workbench/Gateway/Outbox/RenderIndex/l6_symbol_rank_index.csv
Workbench/Gateway/Outbox/RenderIndex/l7_symbol_rank_index.csv
Workbench/Gateway/Outbox/RenderIndex/l8_symbol_rank_index.csv
Workbench/Gateway/Outbox/RenderIndex/l9_symbol_rank_index.csv
```

Minimum meaning of consumed owner outputs:

```text
L10 owns asset_class, market_group, market_segment, ranking_group, taxonomy_state, and rank_allowed.
L6 owns cost/friction surface score.
L7 owns session relevance surface score.
L8 owns movement/range surface score.
L9 owns structure/location surface score.
L5 remains the only broad hard gate.
```

L11 must not infer or repair missing taxonomy. If L10 taxonomy is unknown, review-only, stale, conflicted, or missing, L11 must mark the symbol not rankable rather than reclassifying it.

---

## Rankable Rule

A symbol may be ranked inside its ranking_group only when:

```text
L10 ranking_group is known and accepted.
rank_allowed=true.
at least two of L6-L9 surface components are available.
no upstream permission violation exists.
```

Unknown or review-only taxonomy:

```text
rank_state=not_rankable_taxonomy
ranking_group_rank=not_available
selection_runtime=false
trade_permission=false
entry_signal=false
execution=false
```

---

## Score Model V1

Weights:

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

Rules:

```text
Missing scores are not zero.
Missing scores are explicit unavailable components with penalties.
Mostly unavailable symbols must not outrank cleaner symbols.
Risk-review symbols remain visible and flagged instead of hidden.
High L11 score never means permission, trade, signal, edge, expectancy, or entry.
```

---

## Worker Output Route

Stable Gateway route:

```text
Workbench/Gateway/Outbox/Layers/Layer_11_Symbol_Ranking_Inside_Ranking_Group/
    l11_input_surface_scores.csv
    l11_input_surface_scores.manifest
    ranked_symbols_by_group.csv
    ranked_symbols_by_group.manifest
    ranking_group_top5.csv
    ranking_group_top5.txt
    RankingGroups/
        <sanitized_ranking_group>.top5.txt
        <sanitized_ranking_group>.ranked_symbols.csv
    SymbolRanks/
        <symbol>__<checksum>.txt
    l11_summary.txt
```

---

## Visible Selection Desk Route

L11 fills the first real visible Selection Desk Groups surface:

```text
Aurora Core/<server>/<account>/Selection Desk/Groups/
    00_Group_Index.txt
    00_Group_Index.csv
    <sanitized_ranking_group>.txt
    <sanitized_ranking_group>.csv
```

Forbidden route patterns:

```text
Selection Desk/Groups/Top 5/
Selection Desk/Groups/Rank 1/
Selection Desk/Groups/Global Top 10/
Selection Desk/Groups/<changing cycle id>/
```

Changing ranks belong inside files, not folder names.

---

## Visual Surfaces

Market Board must show compact L11 status:

```text
LAYER 11 - SYMBOL RANKING INSIDE RANKING GROUP
Status
Owner
Input Source
Ranking Groups
Rankable Symbols
Top 5 per ranking_group
Selection Desk Groups
Visible Group Files
Unknown ranking_group
Risk Review Symbols
Main Blocker
Selection Runtime: FALSE
Trade Permission: FALSE
Entry Signal: FALSE
Execution: FALSE
```

Dossier must show per-symbol L11 status:

```text
LAYER 11 - SYMBOL RANKING INSIDE RANKING GROUP
Ranking Group
Ranking Group Rank
Group Percentile
In Top 5 per ranking_group
Leader Flag
Backup Flag
L11 Group Score
Rank State
L6/L7/L8/L9 component states
Meaning: intra_group_inspection_priority_only
Selection Runtime: FALSE
Trade Permission: FALSE
Entry Signal: FALSE
Execution: FALSE
```

Workbench must show proof:

```text
schema_name=l11_symbol_ranking_inside_group
schema_version=1
owner_name=Runtime 5 - Taxonomy / Ranking Group Owner
layer_id=11
input_taxonomy_source=L10
input_surface_layers=L6,L7,L8,L9
component_weights=L6:25,L7:20,L8:25,L9:30
selection_runtime=false
trade_permission=false
entry_signal=false
execution=false
```

---

## Runtime Safety Flags

Every L11 output must keep:

```text
directional_validity=false
expectancy_validated=false
selection_runtime=false
trade_permission=false
entry_signal=false
execution=false
```

---

## Explicit Non-Goals

Do not implement in L11:

```text
L12 ranking_group heat / quality ranking
L13 dynamic ranking_group selection
L14 ranking_group leader candidate pool
L15 correlation / diversity
L16 Global Top 10
L23 setup / strategy / permission / alerts
trade signals
entries
execution
```

Do not use active output names:

```text
bucket
major_bucket
minor_bucket
aggregation_group
bucket_top5
sub_bucket_top5
Top 5 Per Bucket
```

Correct wording:

```text
Top 5 per ranking_group
ranking_group leader
ranking_group backup
intra-group inspection priority
```

---

## Validation Commands

Run from repo root after pulling main:

```bash
python -m py_compile external_worker/*.py
bash external_worker/aio_rebuild_install_l10_proof.sh
rg "Layer_11_Symbol_Ranking_Inside_Ranking_Group|LAYER 11 - SYMBOL RANKING INSIDE RANKING GROUP|Selection Desk.*Groups|Top 5 per ranking_group"
rg "bucket_top5|sub_bucket_top5|Top 5 Per Bucket|major_bucket|minor_bucket|aggregation_group"
```

MQL compile must be run in MetaEditor before claiming compile proof.

---

## Runtime Acceptance Gate

L11 is accepted only when local runtime proves:

```text
1. L10 accepted/current taxonomy is consumed, not reclassified.
2. L6-L9 surface scores are consumed with visible component state.
3. Symbols are ranked only inside their own ranking_group.
4. Top 5 per ranking_group files are produced as files, not changing folders.
5. Selection Desk/Groups is populated with group index and group files.
6. Market Board shows L11 summary.
7. Dossier shows per-symbol L11 section.
8. Workbench shows full L11 proof.
9. selection_runtime=false.
10. trade_permission=false.
11. entry_signal=false.
12. execution=false.
13. no L12-L16 work exists.
```

---

## Current Proof Level

```text
Source merged: yes
Package metadata wired: yes
Runtime rebuild: not proven here
MetaEditor compile: not proven here
MT5 runtime visual proof: not proven here
Selection Desk/Groups runtime population: not proven here
```

Decision until local rebuild/runtime proof passes:

```text
TEST FIRST
```
