# 32 L13 DYNAMIC RANKING GROUP SELECTION CONTROL

## Purpose

Layer 13 owns dynamic `ranking_group` selection for deeper candidate-sourcing attention.

L13 answers:

```text
Which ranking_groups should move forward for candidate sourcing attention this cycle?
```

L13 is inspection-routing only. It is not symbol candidate-pool authority, not correlation/diversity authority, not Global Top 10, not strategy, not alert permission, not trade permission, and not execution.

---

## Runtime Boundary

```text
Runtime owner: Runtime 5 - Taxonomy / Ranking Group Owner
Layer: 13 - Dynamic Ranking Group Selection
Authority: ranking_group_selection_only
```

Runtime support split:

```text
Runtime 3 / external_worker = calculation support for L13 selected/rejected/fallback group outputs.
Runtime 7 publication renderer = render-only Board, Dossier, Workbench surface.
Existing FileIO/path owners remain the only file/path owners.
```

No duplicate FileIO owner, route owner, taxonomy owner, L11 rank owner, L12 heat/quality owner, L14 candidate-pool owner, L15 diversity owner, L16 Global Top 10 owner, strategy owner, permission owner, or execution owner may be introduced.

---

## Inputs

Primary inputs:

```text
Workbench/Gateway/Outbox/Layers/Layer_12_Ranking_Group_Heat_Quality/l12_group_heat_quality.csv
Workbench/Gateway/Outbox/Layers/Layer_12_Ranking_Group_Heat_Quality/l12_group_heat_quality.manifest
Workbench/Gateway/Outbox/Layers/Layer_12_Ranking_Group_Heat_Quality/l12_group_heat_quality_summary.txt
Workbench/Gateway/Outbox/Layers/Layer_12_Ranking_Group_Heat_Quality/l12_thin_group_warnings.csv
Workbench/Gateway/Outbox/Layers/Layer_12_Ranking_Group_Heat_Quality/l12_component_distribution_by_group.csv
```

Optional fallback reference:

```text
Workbench/Gateway/Outbox/Layers/Layer_10_Taxonomy_Classification/ranking_groups.csv
```

L13 must consume L12 group-level outputs. It must not reopen raw L6-L9 sidecars to build its own group quality. If L13 re-scores L6-L9, re-ranks symbols, or builds symbol candidates, it becomes a shadow L12/L14 owner and the patch must be killed.

---

## Owned Fields

```text
selected_ranking_group_count
selected_group_list
selected_group_slugs
rejected_ranking_group_count
fallback_used
fallback_scope
fallback_reason
selection_quality_tier
market_condition_note
l13_group_selection_score
selected_reason
rejected_reason
risk_review_ratio
```

---

## Selection Ladder

L13 must start strict, then loosen only as needed to keep inspection flow alive.

```text
Tier 1: SELECTED_STRONG
Tier 2: SELECTED_WITH_REVIEW
Tier 3: SELECTED_WEAK_FALLBACK
Tier 4: SELECTED_THIN_FALLBACK
Tier 5: FALLBACK_SELECTED_MARKET_SEGMENT
```

Default constants:

```text
L13_MIN_SELECTED_GROUPS=3
L13_TARGET_SELECTED_GROUPS=7
L13_MAX_SELECTED_GROUPS=7
L13_MIN_RANKABLE_PREFERRED=3
L13_MIN_TOP5_PREFERRED=1
```

Core rule:

```text
L13 must not select zero merely because market quality is weak.
L13 may select weak groups for inspection.
L13 must label weak/fallback selection honestly.
L13 must never convert weak selection into trade permission.
```

If L12 source truth is missing, unreadable, or empty, L13 must publish pending/degraded truth and must not fake selected groups.

---

## Tier Definitions

### Tier 1 - Strong Clean Groups

```text
group_state=ACCEPTED
thin_group_flag=false
rankable_count>=5
top5_symbol_count>=3
risk_review_ratio<=0.25
ranking_group_quality_score>=60
ranking_group_strength>=60
```

Selection state:

```text
SELECTED_STRONG
```

### Tier 2 - Usable Review Groups

```text
group_state in ACCEPTED, ACCEPTED_WITH_REVIEW
thin_group_flag=false
rankable_count>=3
top5_symbol_count>=1
```

Selection state:

```text
SELECTED_WITH_REVIEW
```

### Tier 3 - Weak But Usable Groups

```text
rankable_count>=2
top5_symbol_count>=1
```

Selection state:

```text
SELECTED_WEAK_FALLBACK
```

### Tier 4 - Thin Fallback Groups

```text
rankable_count>=1
```

Selection state:

```text
SELECTED_THIN_FALLBACK
```

### Tier 5 - Market Segment Fallback

Use only when ranking_group-level selection cannot fill the minimum selected group count and a market_segment fallback source is available.

```text
fallback_scope=market_segment
fallback_reason=ranking_group_selected_count_below_minimum
```

Selection state:

```text
FALLBACK_SELECTED_MARKET_SEGMENT
```

---

## Selection Score

L13 score orders groups inside each tier. It is not trade permission.

```text
l13_group_selection_score =
    ranking_group_strength      * 0.35
  + ranking_group_quality_score * 0.30
  + ranking_group_heat          * 0.20
  + backup_depth_factor         * 0.10
  - risk_review_penalty         * 0.05
```

Heat must not dominate. Hot trash is still trash.

---

## Worker Output Route

```text
Workbench/Gateway/Outbox/Layers/Layer_13_Dynamic_Ranking_Group_Selection/
    l13_selected_ranking_groups.csv
    l13_rejected_ranking_groups.csv
    l13_fallback_decisions.csv
    l13_group_selection_summary.txt
    l13_selected_ranking_groups.manifest
    RankingGroups/
        <ranking_group_slug>.selection.txt
```

Stable route only. Do not create parent folders named after selected rank, Top Groups, Rank 1, cycle IDs, or Global Top 10.

---

## Selection Desk Relationship

L13 may publish:

```text
Selection Desk/Groups/00_Selected_Ranking_Groups.txt
Selection Desk/Groups/00_Selected_Ranking_Groups.csv
```

L13 must not copy/render Dossiers and must not create symbol candidate folders.

---

## Board Contract

```text
LAYER 13 - DYNAMIC RANKING GROUP SELECTION
Status
Owner
Input Source
Valid Groups
Selected Groups
Rejected Groups
Selection Quality
Fallback Used
Fallback Reason
Top Selected Group
Selection Runtime: FALSE
Trade Permission: FALSE
Entry Signal: FALSE
Execution: FALSE
Main Blocker
```

---

## Dossier Contract

Per symbol, L13 shows the symbol's group selection context only:

```text
LAYER 13 - DYNAMIC RANKING GROUP SELECTION
Ranking Group
Group Selection State
Group Selection Rank
Selection Quality Tier
Group Selection Score
Selected/Rejected Reason
Fallback Used
Fallback Reason
Meaning: group_selected_for_candidate_sourcing_attention_only
Selection Runtime: FALSE
Trade Permission: FALSE
```

---

## Workbench Contract

```text
schema_name=l13_dynamic_ranking_group_selection
schema_version=1
owner_name=Runtime 5 - Taxonomy / Ranking Group Owner
layer_id=13
input_source=L12
source_l12_checksum
l12_status
valid_group_count
selected_ranking_group_count
rejected_group_count
selection_quality_tier
fallback_used
fallback_reason
market_condition_note
selected_group_list
selection_runtime=false
trade_permission=false
entry_signal=false
execution=false
```

---

## Acceptance Tests

L13 is acceptable only when:

```text
L13 consumes L12 outputs only.
L13 does not read L6-L9 raw sidecars.
L13 does not re-rank symbols.
L13 does not build candidate pool.
L13 does not run correlation.
L13 does not build Global Top 10.
L13 selects best available groups even when all strong groups fail.
L13 labels weak/review/fallback selection honestly.
L13 outputs selected/rejected/fallback CSVs.
Selection Desk/Groups contains selected group index.
Market Board contains L13 section.
Dossiers contain per-symbol group selection context.
Workbench contains L13 proof.
All permission/execution flags remain false.
```

---

## Decision

PROCEED with source wiring.

TEST FIRST before runtime acceptance.
