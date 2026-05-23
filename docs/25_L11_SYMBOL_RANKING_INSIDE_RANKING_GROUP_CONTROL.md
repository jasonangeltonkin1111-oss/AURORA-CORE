# 25 L11 SYMBOL RANKING INSIDE RANKING GROUP CONTROL

## Purpose

Define how Layer 11 uses independent surface scores from L6-L9 to rank symbols **inside their own `ranking_group`**.

L11 is not a master ranker, not Global Top 10, not a basket selector, not a trade signal, and not taxonomy authority.

L11 answers:

```text
Inside each already-classified ranking_group, which symbols deserve inspection first?
```

---

## Owner Boundary

```text
Runtime owner: Runtime 5 - Taxonomy / Ranking Group Owner
Layer: 11 - Symbol Ranking Inside Ranking Group
```

L11 may consume:

```text
L10 taxonomy classification truth
L6 cost/friction score
L7 session relevance score
L8 movement/range score
L9 structure/location score
Layer 5 pass/degraded/block state
```

L11 must not own:

```text
asset_class / market_group / market_segment / ranking_group classification
ranking_group heat / quality
selected ranking_group list
candidate pool construction
correlation / diversity selection
Global Top 10
trade permission
entry signals
strategy validation
```

Those belong later:

```text
L10 = taxonomy classification
L12 = ranking_group heat / quality
L13 = dynamic ranking_group selection
L14 = ranking_group leader candidate pool
L15 = correlation / diversity selection
L16 = Global Top 10 builder
L23 = setup / strategy / permission / alert state
```

---

## Naming Law

Active naming uses:

```text
asset_class
market_group
market_segment
ranking_group
symbol
```

Do not use active output names such as:

```text
bucket
bucket_top5
sub_bucket_top5
Top 5 Per Bucket
```

Correct operator wording:

```text
Top 5 per ranking_group
ranking_group rank
ranking_group leader
ranking_group backup
```

---

## L11 Meaning

L11 produces intra-group inspection rank only.

High L11 rank means:

```text
This symbol is one of the strongest current inspection candidates inside its own ranking_group.
```

High L11 rank does not mean:

```text
best trade
buy/sell
entry permission
trade permission
basket selection
Global Top 10 inclusion
```

Required flags:

```text
directional_validity=false
expectancy_validated=false
selection_runtime=false
trade_permission=false
entry_signal=false
```

---

## Input Requirements

Minimum required inputs:

```text
symbol
asset_class
market_group
market_segment
ranking_group
l5_gate_state
l6_cost_score
l7_session_relevance_score
l8_movement_score
l9_structure_watchlist_score
score_state per layer
```

A symbol may be ranked inside its group only when:

```text
L10 ranking_group is known and review-accepted
L5 is pass or explicitly score-eligible degraded
at least two of L6-L9 are available
no upstream permission violation exists
```

If `ranking_group` is unknown, review-only, or stale:

```text
L11 rank_state=not_rankable_taxonomy
ranking_group_rank=not_available
trade_permission=false
```

---

## Score Model V1

L11 does not create new market facts. It normalizes and combines independent surface scores for intra-group ordering.

Default component weights:

```text
L6 cost/friction:              25
L7 session relevance:          20
L8 movement/range:             25
L9 structure/location watch:   30
```

Formula:

```text
l11_group_score = weighted_available_average(L6,L7,L8,L9) - missing_layer_penalty - stale_layer_penalty - risk_review_penalty
```

Rules:

```text
Do not silently average missing layers.
Do not use zero as a fake score for missing layers.
Do not promote a symbol above clean symbols if its score is mostly unavailable.
Do not turn a high score into permission.
```

Suggested penalties:

```text
missing non-critical layer:       -5
missing L8 movement:             -12
missing L9 structure/location:   -12
stale surface layer:              -8
risk_review from L9 or L8:        -5, but keep visible
not_rankable_quality:             rank_state=not_rankable_quality
```

Risk-review symbols are not discarded. They remain visible because they may be important watchlist events.

---

## Normalization Law

Scores must be comparable on a 0-100 scale before L11 combines them.

Required per component:

```text
component_name
raw_score
normalized_score
weight
available
stale
risk_review
reason
source_layer
source_manifest_checksum
```

L11 must show component proof in Workbench and concise component summary in Dossier.

---

## Ranking Group Output

For each `ranking_group`, L11 publishes:

```text
ranking_group
ranking_group_symbol_count
ranking_group_rankable_count
ranking_group_not_rankable_count
ranking_group_rank
symbol
l11_group_score
ranking_group_rank_percentile
rank_state
backup_rank
backup_reason
leader_flag
backup_flag
component_summary
reason
```

Top 5 per ranking_group is a view inside L11:

```text
top5_per_ranking_group=true
```

But wording must be:

```text
Top 5 per ranking_group
```

Not:

```text
Top 5 per bucket
```

---

## Output Routes

Stable route design:

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
```

Do not create folders named after changing ranks such as:

```text
Top 5
Rank 1
Global Top 10
```

Changing ranks belong inside files.

---

## Board Display Contract

Board should show compact summary only:

```text
LAYER 11 - SYMBOL RANKING INSIDE RANKING GROUP
----------------------------------------
Status: accepted / partial / pending / degraded
Owner: Runtime 5 - Taxonomy / Ranking Group Owner
Input Source: L10 taxonomy + L6-L9 surface scores
Ranking Groups: <count>
Rankable Symbols: <count>
Top 5 per ranking_group: available/partial/pending
Unknown ranking_group: <count>
Risk Review Symbols: <count>
Selection Runtime: FALSE
Trade Permission: FALSE
Main Blocker: <reason>
```

Board must not print full group ledgers.

---

## Dossier Display Contract

Per symbol:

```text
LAYER 11 - SYMBOL RANKING INSIDE RANKING GROUP
----------------------------------------
Ranking Group: <ranking_group>
Ranking Group Rank: #<rank> / <rankable_count>
Group Percentile: <pct>
In Top 5 per ranking_group: TRUE/FALSE
Leader Flag: TRUE/FALSE
Backup Flag: TRUE/FALSE
L11 Group Score: <score>
Rank State: ranked / ranked_partial / risk_review / not_rankable_taxonomy
Components:
  L6 Cost/Friction: <score> weight 25 available/stale
  L7 Session: <score> weight 20 available/stale
  L8 Movement: <score> weight 25 available/stale
  L9 Structure: <score> weight 30 available/stale
Meaning: intra_group_inspection_priority_only
Selection Runtime: FALSE
Trade Permission: FALSE
```

---

## Workbench Contract

Workbench must provide full proof:

```text
schema_name=l11_symbol_ranking_inside_group
schema_version=1
owner_name=Runtime 5 - Taxonomy / Ranking Group Owner
layer_id=11
input_taxonomy_source=L10
input_surface_layers=L6,L7,L8,L9
component_weights=L6:25,L7:20,L8:25,L9:30
ranking_group_count=<n>
ranked_symbol_count=<n>
not_rankable_taxonomy_count=<n>
risk_review_count=<n>
top5_group_count=<n>
selection_runtime=false
trade_permission=false
```

---

## Relationship To Later Layers

L11 output feeds:

```text
L12 ranking_group heat / quality
L14 ranking_group leader candidate pool
```

L11 does not feed L16 directly as final authority.

The intended flow:

```text
L10 classify symbol
L11 rank symbols inside each ranking_group
L12 score ranking_group heat / quality
L13 choose ranking_groups deserving attention
L14 pull leaders/backups from selected groups
L15 apply correlation/diversity
L16 build Global Top 10 inspection basket
```

---

## Acceptance Tests

L11 is acceptable only when:

```text
No use of bucket_top5 / sub_bucket_top5 / Top 5 Per Bucket wording
Every symbol rank is inside its own ranking_group
Unknown ranking_group symbols are review-only, not silently grouped
Missing L6-L9 layer inputs are visible, not averaged away
Top 5 per ranking_group files match ranked_symbols_by_group.csv
SymbolRank file count equals ranked symbol count
No global top10 output is produced by L11
selection_runtime=false
trade_permission=false
entry_signal=false
```

---

## Decision

PROCEED with L11 design after L9 score output exists and L10 taxonomy authority is explicit.

HOLD runtime implementation until L10/L9 source outputs are stable enough to feed L11 without fallback taxonomy authority.
