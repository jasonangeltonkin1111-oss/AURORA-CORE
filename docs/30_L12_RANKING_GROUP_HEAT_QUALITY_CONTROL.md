# 30 L12 RANKING GROUP HEAT QUALITY CONTROL

## Purpose

Define Layer 12 as the active `ranking_group` heat / quality ranking layer for AURORA CORE.

Layer 12 answers:

```text
Which ranking_groups are currently strongest, healthiest, or most worth attention?
```

Layer 12 is group-level inspection context only. It is not symbol ranking authority, not dynamic group selection, not candidate-pool construction, not correlation/diversity, not Global Top 10, not a trade signal, not strategy validation, and not trade permission.

---

## Runtime Boundary

```text
Runtime owner: Runtime 5 - Taxonomy / Ranking Group Owner
Layer: 12 - Ranking Group Heat / Quality Ranking
Authority: ranking_group_attention_quality_only
```

Runtime support split:

```text
Runtime 3 / external_worker: calculates L12 group heat / quality outputs from L11 group ranking outputs.
Runtime 7 publication renderers: later render Board, Dossier, Workbench, and Selection Desk heat/quality surfaces.
Existing FileIO/path owners: remain the only file/path owners.
```

No duplicate FileIO owner, route owner, taxonomy owner, L11 ranking owner, L13 selection owner, L14 candidate owner, L15 diversity owner, L16 Global Top 10 owner, permission owner, strategy owner, or execution owner may be introduced.

---

## Inputs

Primary inputs:

```text
Workbench/Gateway/Outbox/Layers/Layer_11_Symbol_Ranking_Inside_Ranking_Group/l11_summary.txt
Workbench/Gateway/Outbox/Layers/Layer_11_Symbol_Ranking_Inside_Ranking_Group/ranked_symbols_by_group.csv
Workbench/Gateway/Outbox/Layers/Layer_11_Symbol_Ranking_Inside_Ranking_Group/ranked_symbols_by_group.manifest
Workbench/Gateway/Outbox/Layers/Layer_11_Symbol_Ranking_Inside_Ranking_Group/ranking_group_top5.csv
Workbench/Gateway/Outbox/Layers/Layer_11_Symbol_Ranking_Inside_Ranking_Group/l11_input_surface_scores.csv
```

Optional cross-check input:

```text
Workbench/Gateway/Outbox/Layers/Layer_10_Taxonomy_Classification/ranking_groups.csv
```

L12 must consume L11 output rather than re-ranking symbols from raw L6-L9 files. Raw L6-L9 may be represented only through L11 component columns already present in L11 outputs. If L12 reopens raw L6-L9 sidecars and creates its own Top-N ranking, it becomes a shadow L11 owner and must be killed.

---

## What L12 Owns

```text
ranking_group_heat
ranking_group_quality_score
ranking_group_strength
ranking_group_activity_score
ranking_group_cost_score
ranking_group_movement_score
ranking_group_clean_count
ranking_group_degraded_count
ranking_group_not_rankable_count
ranking_group_risk_review_count
ranking_group_top_symbol_score
ranking_group_top_n_avg_score
ranking_group_top_n_median_score
backup_depth
thin_group_flag
thin_group_reason
rank_stability
rank_change
churn_penalty
```

First-cycle truth:

```text
rank_stability=not_available_first_cycle
rank_change=not_available_first_cycle
churn_penalty=0_first_cycle_no_prior_snapshot
prior_cycle_available=false
```

Do not fake stability before prior-cycle state exists.

---

## What L12 Must Not Own

```text
asset_class / market_group / market_segment / ranking_group taxonomy classification
symbol rank inside ranking_group
selected ranking_group list
candidate pool construction
correlation / diversity selection
Global Top 10
deep evidence selection
strategy setup state
alert permission
trade permission
entry signal
execution
```

Layer boundaries:

```text
L10 = taxonomy classification
L11 = symbol ranking inside ranking_group
L12 = ranking_group heat / quality ranking
L13 = dynamic ranking_group selection
L14 = ranking_group leader candidate pool
L15 = correlation / diversity selection
L16 = Global Top 10 builder
L23 = setup / strategy / permission / alert state
```

---

## Meaning Law

High L12 heat means:

```text
This ranking_group currently deserves attention as a group.
```

High L12 quality means:

```text
This ranking_group has cleaner, more complete, more usable ranking data.
```

High L12 strength means:

```text
This ranking_group has strong ranked leaders/backups.
```

None of these mean:

```text
best trades
buy/sell
edge proven
expectancy validated
prop-firm safe
trade permission
entry permission
execution permission
```

Required flags:

```text
directional_validity=false
expectancy_validated=false
selection_runtime=false
trade_permission=false
entry_signal=false
execution=false
```

---

## Score Model V1

### ranking_group_quality_score

Purpose: group health and reliability.

Inputs:

```text
rankable_ratio
clean_ratio
component_completeness_avg
top5_available_factor
backup_depth_factor
risk_review_count
not_rankable_count
thin_group_flag
```

Formula:

```text
quality_score =
    rankable_ratio * 25
  + clean_ratio * 25
  + component_completeness_avg * 20
  + top5_available_factor * 10
  + backup_depth_factor * 10
  - risk_review_penalty
  - not_rankable_penalty
  - thin_group_penalty
```

### ranking_group_strength

Purpose: leader/back-up strength.

Inputs:

```text
top_symbol_score
top5_avg_score
top5_median_score
backup_depth_factor
clean_count_factor
degraded_penalty
```

Formula:

```text
strength =
    top_symbol_score * 0.35
  + top5_avg_score * 0.35
  + top5_median_score * 0.15
  + backup_depth_factor * 0.10
  + clean_count_factor * 0.05
  - degraded_penalty
```

### ranking_group_heat

Purpose: current attention pressure.

Inputs:

```text
top5_avg_score
percent_of_group_above_threshold
top_symbol_separation
session_relevance_avg
rank_stability
churn_penalty
```

Formula:

```text
heat =
    top5_avg_score * 0.30
  + percent_above_threshold * 0.20
  + top_symbol_separation * 0.15
  + session_relevance_avg * 0.20
  + rank_stability * 0.10
  - churn_penalty
```

In V1, `rank_stability` is unavailable until prior-cycle storage exists. V1 must mark it unavailable rather than inventing it.

---

## Group States

```text
ACCEPTED
ACCEPTED_WITH_REVIEW
THIN_GROUP
NO_TOP5
L11_PENDING
L11_DEGRADED
NO_RANKABLE_SYMBOLS
WRITE_DEGRADED
```

Meanings:

```text
ACCEPTED             = enough clean ranked symbols and valid Top 5 view
ACCEPTED_WITH_REVIEW = usable but risk-review/degraded symbols exist
THIN_GROUP           = too few rankable symbols for strong confidence
NO_TOP5              = group exists but no Top 5 rows are available
L11_PENDING          = required L11 source is not ready
L11_DEGRADED         = L11 source exists but is degraded/unaccepted
NO_RANKABLE_SYMBOLS  = group exists but has no rankable symbols
WRITE_DEGRADED       = calculation worked but one or more writes failed
```

---

## Worker Output Route

```text
Workbench/Gateway/Outbox/Layers/Layer_12_Ranking_Group_Heat_Quality/
    l12_group_heat_quality.csv
    l12_group_heat_quality.manifest
    l12_component_distribution_by_group.csv
    l12_thin_group_warnings.csv
    l12_group_heat_quality_summary.txt
    RankingGroups/
        <ranking_group_slug>.heat_quality.txt
```

Stable route only. Do not create parent folders named after heat rank, quality rank, Top Groups, Rank 1, cycle IDs, or Global Top 10.

---

## CSV Contract: l12_group_heat_quality.csv

Required columns:

```text
ranking_group
ranking_group_slug
asset_class
market_group
market_segment
group_state
ranking_group_heat_rank
ranking_group_quality_rank
ranking_group_strength_rank
ranking_group_heat
ranking_group_quality_score
ranking_group_strength
group_symbol_count
rankable_count
not_rankable_count
risk_review_count
top5_symbol_count
backup_depth
top_symbol
top_symbol_score
top5_avg_score
top5_median_score
top5_min_score
top5_max_score
top_symbol_separation
l6_avg_score
l7_avg_score
l8_avg_score
l9_avg_score
session_relevance_avg
component_completeness_avg
percent_group_above_70
percent_group_above_60
thin_group_flag
thin_group_reason
rank_stability
rank_change
churn_penalty
prior_cycle_available
meaning
directional_validity
expectancy_validated
selection_runtime
trade_permission
entry_signal
execution
reason
source_l11_checksum
generated_utc
```

---

## CSV Contract: l12_component_distribution_by_group.csv

```text
ranking_group
rankable_count
l6_available_count
l7_available_count
l8_available_count
l9_available_count
l6_avg
l7_avg
l8_avg
l9_avg
l6_missing_count
l7_missing_count
l8_missing_count
l9_missing_count
risk_review_count
not_rankable_quality_count
not_rankable_taxonomy_count
```

---

## CSV Contract: l12_thin_group_warnings.csv

```text
ranking_group
group_symbol_count
rankable_count
top5_symbol_count
thin_group_flag
thin_group_reason
selection_runtime
trade_permission
```

---

## Selection Desk Relationship

L12 may publish a top-level heat/quality index:

```text
Aurora Core/<server>/<account>/Selection Desk/Groups/00_Group_Heat_Quality_Index.txt
Aurora Core/<server>/<account>/Selection Desk/Groups/00_Group_Heat_Quality_Index.csv
```

If L11 has created the nested taxonomy group tree, L12 may also place group heat files inside the existing group folders:

```text
Selection Desk/Groups/<asset_class>/<market_group>/<market_segment>/<ranking_group>/00_Group_Heat_Quality.txt
Selection Desk/Groups/<asset_class>/<market_group>/<market_segment>/<ranking_group>/00_Group_Heat_Quality.csv
```

If the L11 group tree is not proven, L12 must not fake nested writes. It should publish outbox outputs and mark:

```text
selection_desk_group_tree_state=pending_l11_tree_layout
```

L12 must not copy or render Dossiers.

---

## Market Board Contract

Compact only:

```text
LAYER 12 - RANKING GROUP HEAT / QUALITY
----------------------------------------
Status:                     accepted / pending / degraded
Owner:                      Runtime 5 - Taxonomy / Ranking Group Owner
Input Source:               L11 ranked groups + Top 5 per ranking_group
Ranking Groups Scored:      <n>
Accepted Groups:            <n>
Thin Groups:                <n>
Risk Review Groups:         <n>
Top Heat Group:             <group> heat=<score>
Top Quality Group:          <group> quality=<score>
Top Strength Group:         <group> strength=<score>
Selection Runtime:          FALSE
Trade Permission:           FALSE
Entry Signal:               FALSE
Execution:                  FALSE
Main Blocker:               <reason>
```

Board must not print full ledgers.

---

## Dossier Contract

Per symbol:

```text
LAYER 12 - RANKING GROUP HEAT / QUALITY
----------------------------------------
Ranking Group:               <ranking_group>
Group Heat Rank:             #<rank> / <group_count>
Group Quality Rank:          #<rank> / <group_count>
Group Strength Rank:         #<rank> / <group_count>
Group Heat:                  <score>
Group Quality:               <score>
Group Strength:              <score>
Group State:                 <state>
Top Symbol:                  <symbol>
Top Symbol Score:            <score>
Top 5 Avg Score:             <score>
Backup Depth:                <n>
Thin Group:                  TRUE/FALSE
Risk Review Count:           <n>
Meaning:                     group_attention_quality_only
Selection Runtime:           FALSE
Trade Permission:            FALSE
```

---

## Workbench Contract

```text
L12_RANKING_GROUP_HEAT_QUALITY
----------------------------------------
schema_name=l12_ranking_group_heat_quality
schema_version=1
owner_name=Runtime 5 - Taxonomy / Ranking Group Owner
layer_id=12
input_source=L11
input_files=ranked_symbols_by_group.csv,ranking_group_top5.csv,l11_summary.txt
ranking_group_count=<n>
accepted_group_count=<n>
thin_group_count=<n>
risk_review_group_count=<n>
write_failed_count=<n>
selection_runtime=false
trade_permission=false
entry_signal=false
execution=false
```

---

## Acceptance Tests

L12 is acceptable only when:

```text
L12 consumes L11 outputs and does not re-rank symbols from raw L6-L9 sidecars.
L12 does not create symbol ranks.
L12 does not select active groups.
L12 does not build a candidate pool.
L12 does not build Global Top 10.
L12 does not copy or render Dossiers.
L12 publishes group heat/quality outputs.
L12 degrades honestly if L11 is pending/degraded.
L12 does not fake rank stability before prior-cycle history exists.
L12 keeps directional_validity=false.
L12 keeps expectancy_validated=false.
L12 keeps selection_runtime=false.
L12 keeps trade_permission=false.
L12 keeps entry_signal=false.
L12 keeps execution=false.
```

---

## Decision

PROCEED with L12 source design and worker calculation scaffold after L11 source outputs exist.

TEST FIRST before runtime promotion, renderer wiring, package rebuild, or MT5 visual acceptance.
