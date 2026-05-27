# 30 L12 RANKING GROUP HEAT QUALITY CONTROL

## Purpose

Layer 12 owns group-level heat / quality ranking for already-classified `ranking_group` values.

L12 answers:

```text
Which ranking_groups are currently strongest, healthiest, or most worth attention?
```

L12 is inspection context only. It is not symbol ranking authority, not selected group authority, not candidate-pool authority, not Global Top 10, not strategy, not alert permission, not trade permission, and not execution.

---

## Runtime Boundary

```text
Runtime owner: Runtime 5 - Taxonomy / Ranking Group Owner
Layer: 12 - Ranking Group Heat / Quality Ranking
Authority: ranking_group_attention_quality_only
```

Runtime support split:

```text
Runtime 3 / external_worker = calculation support for L12 group heat / quality outputs.
Runtime 7 publication renderer = render-only Board, Dossier, Workbench surface.
Existing FileIO/path owners remain the only file/path owners.
```

No duplicate FileIO owner, route owner, taxonomy owner, L11 rank owner, L13 group-selection owner, L14 candidate-pool owner, L15 diversity owner, L16 Global Top 10 owner, strategy owner, permission owner, or execution owner may be introduced.

---

## Inputs

Primary inputs:

```text
Workbench/Gateway/Outbox/Layers/Layer_11_Symbol_Ranking_Inside_Ranking_Group/l11_summary.txt
Workbench/Gateway/Outbox/Layers/Layer_11_Symbol_Ranking_Inside_Ranking_Group/ranked_symbols_by_group.csv
Workbench/Gateway/Outbox/Layers/Layer_11_Symbol_Ranking_Inside_Ranking_Group/ranked_symbols_by_group.manifest
Workbench/Gateway/Outbox/Layers/Layer_11_Symbol_Ranking_Inside_Ranking_Group/ranking_group_top5.csv
```

Optional reference input:

```text
Workbench/Gateway/Outbox/Layers/Layer_10_Taxonomy_Classification/ranking_groups.csv
```

L12 must consume L11 outputs. It must not reopen raw L6-L9 sidecars to build its own symbol ranking. If L12 re-ranks symbols, it becomes a shadow L11 owner and the patch must be killed.

---

## Owned Fields

```text
ranking_group_heat
ranking_group_quality_score
ranking_group_strength
ranking_group_heat_rank
ranking_group_quality_rank
ranking_group_strength_rank
group_state
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
top_symbol_separation
l6_avg_score
l7_avg_score
l8_avg_score
l9_avg_score
session_relevance_avg
component_completeness_avg
thin_group_flag
thin_group_reason
```

First-cycle stability fields must stay honest:

```text
rank_stability=not_available_first_cycle
rank_change=not_available_first_cycle
churn_penalty=0_first_cycle_no_prior_snapshot
prior_cycle_available=false
```

---

## Forbidden Ownership

```text
No taxonomy classification.
No symbol ranking inside ranking_group.
No selected ranking_group list.
No candidate-pool construction.
No correlation/diversity.
No Global Top 10.
No Dossier rendering/copying.
No strategy setup state.
No alert permission.
No trade permission.
No entry signal.
No execution.
```

Layer order stays:

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

High L12 heat means the group currently deserves attention as a group.

High L12 quality means the group has cleaner and more complete ranking data.

High L12 strength means the group has strong leaders and backup depth.

None of these mean direction, best-now status, edge proof, expectancy validation, prop-rule clearance, trade permission, entry permission, or execution permission.

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

### Quality

```text
quality_score =
    rankable_ratio * 0.25
  + clean_ratio * 0.25
  + component_completeness_avg * 0.20
  + top5_available_factor * 0.10
  + backup_depth_factor * 0.10
  - risk_review_penalty
  - not_rankable_penalty
  - thin_group_penalty
```

### Strength

```text
strength =
    top_symbol_score * 0.35
  + top5_avg_score * 0.35
  + top5_median_score * 0.15
  + backup_depth_factor * 0.10
  + clean_count_factor * 0.05
  - degraded_penalty
```

### Heat

```text
heat =
    top5_avg_score * 0.30
  + percent_group_above_70 * 0.20
  + top_symbol_separation * 0.15
  + session_relevance_avg * 0.20
  + rank_stability * 0.10
  - churn_penalty
```

In V1, rank stability is not available and must not be faked.

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

## Selection Desk Relationship

L12 may publish:

```text
Selection Desk/Groups/00_Group_Heat_Quality_Index.txt
Selection Desk/Groups/00_Group_Heat_Quality_Index.csv
```

If L11 has created nested taxonomy group folders, L12 may later add group heat files there. L12 must not create changing rank parent folders and must not copy/render Dossiers.

---

## Board Contract

```text
LAYER 12 - RANKING GROUP HEAT / QUALITY
Status
Owner
Input Source
Ranking Groups Scored
Accepted Groups
Thin Groups
Risk Review Groups
Top Heat Group
Top Quality Group
Top Strength Group
Selection Runtime: FALSE
Trade Permission: FALSE
Entry Signal: FALSE
Execution: FALSE
Main Blocker
```

---

## Dossier Contract

Per symbol, L12 shows the symbol's group-level context only:

```text
LAYER 12 - RANKING GROUP HEAT / QUALITY
Ranking Group
Group Heat Rank
Group Quality Rank
Group Strength Rank
Group Heat
Group Quality
Group Strength
Group State
Top Symbol
Top Symbol Score
Top 5 Avg Score
Backup Depth
Thin Group
Risk Review Count
Meaning: group_attention_quality_only
Selection Runtime: FALSE
Trade Permission: FALSE
```

---

## Workbench Contract

```text
schema_name=l12_ranking_group_heat_quality
schema_version=1
owner_name=Runtime 5 - Taxonomy / Ranking Group Owner
layer_id=12
input_source=L11
ranking_group_count
accepted_group_count
thin_group_count
risk_review_group_count
write_failed_count
selection_runtime=false
trade_permission=false
entry_signal=false
execution=false
```

---

## Acceptance Tests

L12 is acceptable only when:

```text
L12 consumes L11 outputs.
L12 does not re-rank symbols.
L12 does not select active groups.
L12 does not build candidate pool.
L12 does not build Global Top 10.
L12 does not copy or render Dossiers.
L12 publishes heat/quality outputs.
L12 degrades honestly if L11 is pending/degraded.
L12 does not fake rank stability before prior-cycle history exists.
L12 keeps all permission/execution flags false.
```

---

## Decision

PROCEED with source wiring.

TEST FIRST before runtime acceptance.
