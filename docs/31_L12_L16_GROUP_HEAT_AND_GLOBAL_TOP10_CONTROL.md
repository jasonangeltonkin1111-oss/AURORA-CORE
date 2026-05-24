# 31 L12-L16 GROUP HEAT AND GLOBAL TOP 10 CONTROL

## Purpose

This document locks the L12+ ranking-group and basket-selection rules before runtime implementation so future chats do not drift into fake signal authority, duplicate selection owners, or high-correlation Global Top 10 baskets.

This is a design/control document. It is not runtime proof.

---

## Proof Status

```text
source_contract=true
design_control=true
runtime_implemented=false unless active source proves otherwise
runtime_proven=false unless MT5/worker outputs prove otherwise
trade_permission=false
entry_signal=false
execution=false
```

---

## Absolute Laws

1. L12-L16 are inspection and selection layers only.
2. L12-L16 do not create setup logic, edge proof, buy/sell calls, alerts, or trade permission.
3. High score means inspection priority, not profitability.
4. Low correlation means diversification, not edge.
5. Global Top 10 means `inspect these first`, not `trade these`.
6. Layer 5 remains the only broad all-symbol hard gate.
7. L1 prop/account safety outranks every ranking/selection layer.
8. No full-universe 1200x1200 correlation matrix in L15; correlation is candidate-pool scoped.
9. No duplicate FileIO, route, selection, or Dossier rendering owner.
10. Selection Desk folders stay stable; changing ranks and cycle metadata belong inside files/manifests.

---

## L12 — Ranking Group Heat / Quality

### Question Answered

```text
Which ranking_groups are currently strongest, healthiest, or most worth attention?
```

### Inputs

```text
L10 ranking_group membership
L11 symbol ranks inside ranking_group
L6 cost/friction component distribution
L7 session relevance component distribution
L8 movement/range component distribution
L9 structure/location component distribution
L5 clean/degraded/blocked counts
review/unknown/conflict counts
```

### Outputs

```text
ranking_group_strength
ranking_group_heat
ranking_group_quality_score
ranking_group_activity_score
ranking_group_cost_score
ranking_group_movement_score
ranking_group_clean_count
ranking_group_degraded_count
ranking_group_review_count
ranking_group_unknown_count
ranking_group_top_symbol_score
ranking_group_top_n_avg_score
ranking_group_top_n_median_score
backup_depth
rank_stability
rank_change
session_relevance_avg
thin_group_warning
churn_warning
```

### Scoring Meaning

```text
ranking_group_strength = quality/usable-depth view
ranking_group_heat = current activity/attention view
ranking_group_quality_score = broad group health view
```

No L12 score is directional or trade-valid.

### Forbidden

```text
No Global Top 10.
No selected groups.
No candidate pool.
No correlation/diversity.
No setup logic.
No FVG/BOS/CHOCH/OB/sweep logic.
No trade permission.
```

---

## L13 — Dynamic Ranking Group Selection

### Question Answered

```text
Which ranking_groups deserve attention this cycle?
```

### Inputs

```text
L12 group heat/quality
L10 taxonomy state
L5 pass/degraded count per group
review/unknown/conflict state
minimum usable symbols per group
```

### Selection Frame

```text
valid_groups >= 7  => select top 7 groups by L12 quality/heat rules
valid_groups 3..6  => select all valid groups
valid_groups <= 2  => fallback to market_segment only when explicitly allowed and logged
```

### Outputs

```text
selected_ranking_groups
selected_ranking_group_count
rejected_ranking_groups
rejected_group_count
fallback_used
fallback_reason
group_selection_reason
selection_runtime=false
trade_permission=false
```

### Forbidden

```text
No symbol-level final basket.
No correlation/diversity.
No setup logic.
No trade permission.
```

---

## L14 — Ranking Group Leader Candidate Pool

### Question Answered

```text
From selected ranking_groups, which leaders/backups should enter the candidate pool?
```

### Inputs

```text
L13 selected groups
L11 top ranked symbols inside selected groups
L12 group heat/quality
L10 taxonomy state
L5 gate state
```

### Candidate Sources

```text
ranking_group_top_n_leaders
ranking_group_backups
important_market_segment_leaders
ranking_group_heat_leaders
manual_pinned_symbols_later_if_allowed
```

### Outputs

```text
candidate_pool_members
candidate_pool_size
candidate_source
leader_or_backup
candidate_reason
backup_included_flag
review_excluded_flag
candidate_pool_runtime=false
trade_permission=false
```

### Forbidden

```text
No final Global Top 10.
No correlation/diversity final filter.
No setup logic.
No trade permission.
```

---

## L15 — Correlation / Diversity Selection

### Question Answered

```text
Which candidate symbols should be accepted, rejected, or replaced because they are too correlated, overlapping, or exposure-clustered?
```

### Scope Law

L15 operates on the L14 candidate pool only.

Forbidden:

```text
full universe correlation matrix
1200x1200 correlation scan
correlation over L5-blocked symbols
correlation used as edge proof
correlation used to override L1 risk safety
```

### Default Correlation Cap

```text
max_allowed_pairwise_correlation_abs = 0.30
```

Meaning:

```text
A candidate is correlation-clean only when abs(correlation(candidate, every already-selected symbol)) <= 0.30.
```

### Correlation Fields

```text
corr_to_selected_max
corr_to_selected_avg
corr_pair_max_symbol
correlation_sample_count
correlation_lookback_bars
correlation_timeframe
correlation_method
correlation_confidence
candidate_accept
candidate_reject_reason
replacement_candidate
currency_overlap_score
ranking_group_overlap_score
diversity_score
selection_utility
```

### Required Degraded States

```text
correlation_unavailable
insufficient_sample
mismatched_timeframes
missing_ohlc
candidate_pool_too_small
fallback_fill_required
```

### Forbidden

```text
No trade permission.
No strategy edge claim.
No hidden full-universe deep evidence collection.
```

---

## L16 — Global Top 10 Builder

### Question Answered

```text
What is the diversified Global Top 10 inspection basket for this cycle?
```

### Inputs

```text
L15 accepted/replaced candidates
L14 candidate pool
L11 intra-group symbol ranks
L12 group quality/heat
L10 taxonomy
L1 exposure context where available
```

### Core Law

Global Top 10 is built from high-score candidates first, then diversified by greedy low-correlation selection.

It is not built by simply choosing the lowest-correlation symbols. A low-correlation weak symbol must not beat a much stronger high-score symbol unless correlation constraints force replacement.

### Required Greedy Selection Rule

```text
1. Build eligible candidate list from L14/L15-safe candidates only.
2. Sort candidates by primary inspection score descending.
3. Pick the highest-scoring valid candidate first.
4. For each next slot, scan remaining candidates in score order.
5. Accept the first candidate whose absolute pairwise correlation to every already-selected symbol is <= 0.30.
6. Continue until 10 symbols are selected or no valid candidates remain.
7. If no remaining candidate passes the 0.30 correlation cap, do not silently break the rule.
8. Either leave the slot unfilled or use an explicitly logged degraded/fallback fill according to config.
9. Record every correlation rejection and fallback decision.
```

### Primary Inspection Score

The L16 primary score should be derived from existing inspection-priority evidence, not from strategy logic:

```text
L11 group score
L12 group quality/heat context
L6 cost/friction state
L7 session relevance state
L8 movement/range state
L9 structure/location state
L5 clean/degraded status
```

Forbidden score ingredients:

```text
buy/sell setup
FVG confirmation
OB confirmation
CHOCH confirmation
AI confidence
high probability label
```

### Global Top 10 Outputs

```text
global_top10
global_top10_rank
global_top10_reason
primary_inspection_score
max_corr_to_selected
correlation_clean_flag
correlation_rejects
backup_fill_used
backup_fill_reason
fallback_reason
unfilled_slots_count
diversity_state
trade_permission=false
entry_signal=false
execution=false
```

### Selection Desk Output

Stable route only:

```text
Selection Desk/Global/
    current_top10_manifest.txt
    current_top10.csv
    Global Top 10.txt
```

If Dossiers are copied into the Global view, they must be byte-copied from the Dossier owner and checked by size/checksum. L16 must not render modified Dossier content.

### Board Output

Compact row view:

```text
Rank | Symbol | ranking_group | Score | Max Corr | Corr State | L6 | L7 | L8 | L9 | Reason | Copy State
```

### Meaning Law

```text
Global Top 10 = diversified inspection basket.
Global Top 10 != best trades.
Global Top 10 != entry list.
Global Top 10 != validated edge.
Global Top 10 != prop-firm permission.
```

---

## L12-L16 Runtime Acceptance Gate

A future L12-L16 implementation is not accepted until runtime proves:

```text
L12 group heat/quality outputs exist and are current
L13 selected groups exist and are current
L14 candidate pool exists and is sourced from selected groups/leaders/backups
L15 correlation/diversity runs on candidate pool only
L15 records max_allowed_pairwise_correlation_abs=0.30
L16 picks highest score first
L16 greedily accepts next candidates only when abs(pairwise correlation) <= 0.30 to all already selected
L16 records rejects and fallback fills
Selection Desk/Global is populated through stable routes
Market Board shows compact Global Top 10 reasons
Dossiers are not modified by Selection Desk copy logic
trade_permission=false
entry_signal=false
execution=false
```

---

## Decision

Use this document as the L12-L16 control contract for future implementation.

Current decision for runtime implementation:

```text
TEST FIRST
```
