# 33 L14 RANKING GROUP LEADER CANDIDATE POOL CONTROL

## Purpose

Layer 14 owns the raw candidate pool built from selected ranking_groups.

L14 answers:

```text
Which leader and backup symbols from selected ranking_groups should enter the candidate pool for later diversification?
```

L14 is candidate sourcing only. It is not correlation filtering, not the Global Top 10 builder, not a strategy layer, not alert permission, not trade permission, and not execution.

---

## Runtime Boundary

```text
Runtime owner: Runtime 5 - Taxonomy / Ranking Group Owner
Layer: 14 - Ranking Group Leader Candidate Pool
Authority: candidate_pool_sourcing_only
```

Runtime support split:

```text
Runtime 3 / external_worker = calculation support for L14 candidate pool files.
Runtime 7 publication renderer = render-only Board, Dossier, Workbench surface.
Existing FileIO/path owners remain the only file/path owners.
```

No duplicate FileIO owner, route owner, L11 rank owner, L12 heat/quality owner, L13 group-selection owner, L15 diversity owner, L16 Global Top 10 owner, strategy owner, permission owner, or execution owner may be introduced.

---

## Inputs

Required inputs:

```text
Workbench/Gateway/Outbox/Layers/Layer_13_Dynamic_Ranking_Group_Selection/l13_group_selection_summary.txt
Workbench/Gateway/Outbox/Layers/Layer_13_Dynamic_Ranking_Group_Selection/l13_selected_ranking_groups.csv
Workbench/Gateway/Outbox/Layers/Layer_11_Symbol_Ranking_Inside_Ranking_Group/ranking_group_top5.csv
Workbench/Gateway/Outbox/Layers/Layer_11_Symbol_Ranking_Inside_Ranking_Group/ranked_symbols_by_group.manifest
Workbench/Gateway/Outbox/Layers/Layer_12_Ranking_Group_Heat_Quality/l12_group_heat_quality.csv
```

L14 must consume L13 selected groups and L11 top-ranked symbols. It may use L12 heat/quality as context only. It must not reopen L6-L9 sidecars to re-score symbols and must not build a global basket.

---

## Owned Fields

```text
candidate_pool_size
candidate_pool_members
candidate_pool_rank
candidate_source
candidate_reason
leader_or_backup
backup_included_flag
review_excluded_flag
source_ranking_group
source_group_selection_state
source_group_selection_rank
source_group_selection_tier
source_group_strength
source_group_heat
source_group_quality
l11_group_score
l11_top_rank
```

---

## Candidate Rules

Default rules:

```text
For each L13 selected ranking_group:
  include top_rank 1 as ranking_group_leader
  include top_rank 2-5 as ranking_group_backup when available
  preserve selected group state and thin/weak fallback context
  preserve risk_review_flag from L11
  do not exclude merely because the group is weak/thin; label honestly
```

L14 may include weak/thin fallback candidates because the purpose is inspection continuity. It must label the inherited weakness so L15/L16 can reject, diversify, or degrade later.

---

## Candidate Score

L14 ordering is inspection priority only:

```text
l14_candidate_priority_score =
    l11_group_score * 0.60
  + l13_group_selection_score * 0.25
  + l12_ranking_group_strength * 0.10
  + leader_bonus_or_backup_penalty
```

Where:

```text
leader_bonus_or_backup_penalty:
  leader/top_rank=1 => +5
  backup/top_rank=2 => -2
  backup/top_rank=3 => -4
  backup/top_rank=4 => -6
  backup/top_rank=5 => -8
```

This score is not directional, not expectancy-validated, not edge proof, and not trade permission.

---

## Worker Output Route

```text
Workbench/Gateway/Outbox/Layers/Layer_14_Ranking_Group_Leader_Candidate_Pool/
    l14_candidate_pool.csv
    l14_candidate_pool.manifest
    l14_candidate_pool_summary.txt
    RankingGroups/
        <ranking_group_slug>.candidate_pool.txt
```

Stable Selection Desk output:

```text
Selection Desk/Groups/00_Ranking_Group_Leader_Candidate_Pool.txt
Selection Desk/Groups/00_Ranking_Group_Leader_Candidate_Pool.csv
```

Stable route only. Do not create parent folders named after changing ranks, Top 10, Rank 1, cycle IDs, or strategy labels.

---

## Board Contract

```text
LAYER 14 - RANKING GROUP LEADER CANDIDATE POOL
Status
Owner
Input Source
Selected Groups Consumed
Candidate Pool Size
Leader Candidates
Backup Candidates
Review Candidates
Thin Fallback Candidates
Top Candidate
Candidate Pool Runtime: FALSE
Trade Permission: FALSE
Entry Signal: FALSE
Execution: FALSE
Main Blocker
```

---

## Dossier Contract

Per symbol:

```text
LAYER 14 - RANKING GROUP LEADER CANDIDATE POOL
Status
Candidate Pool Member: TRUE/FALSE
Candidate Pool Rank
Candidate Source
Candidate Reason
Leader Or Backup
Backup Included Flag
Source Ranking Group
Source Group Selection State
Source Group Selection Tier
Candidate Priority Score
Meaning: raw_candidate_pool_only
Candidate Pool Runtime: FALSE
Trade Permission: FALSE
```

---

## Acceptance Tests

L14 is acceptable only when:

```text
L14 consumes L13 selected groups, not all groups.
L14 consumes L11 Top 5 per ranking_group, not full-universe symbols.
L14 includes leaders and explicit backups only.
L14 preserves weak/thin/review context from L13 and L11.
L14 does not run correlation/diversity.
L14 does not produce Global Top 10.
L14 does not claim buy/sell/setup/edge/trade permission.
Board, Dossier, Workbench, and Selection Desk render L14 truth.
trade_permission=false
entry_signal=false
execution=false
```

---

## Decision

TEST FIRST after rebuild/runtime proof.
