# 34 L15 CORRELATION DIVERSITY SELECTION CONTROL

## Purpose

Layer 15 owns proof-only correlation / diversity scoring for the L14 candidate pool and selected ranking-group context.

L15 answers:

```text
How correlated, overlapping, concentrated, or diversity-constrained is the current L14 candidate pool?
```

L15 does not answer:

```text
Which symbols enter Global Top 10?
Which symbols are trades?
Which setup is valid?
Which direction should be traded?
```

L15 is evidence and constraint context only.

---

## Runtime Boundary

```text
Runtime owner: Runtime 5 - Taxonomy / Ranking Group Owner
Layer: 15 - Correlation / Diversity Selection
Authority: correlation_diversity_scoring_only
```

Runtime support split:

```text
Runtime 3 / external_worker = calculation support for L15 correlation/diversity files.
Runtime 1 Shared OHLC Raw Storage Owner = raw OHLC source only.
Runtime 7 publication renderer = render-only Board, Dossier, Workbench surface.
Existing FileIO/path owners remain the only file/path owners.
```

No duplicate FileIO owner, route owner, raw OHLC owner, L14 candidate-pool owner, L16 Global Top 10 owner, strategy owner, permission owner, or execution owner may be introduced.

---

## Inputs

Required inputs:

```text
Workbench/Gateway/Outbox/Layers/Layer_14_Ranking_Group_Leader_Candidate_Pool/l14_candidate_pool.csv
Workbench/Gateway/Outbox/Layers/Layer_14_Ranking_Group_Leader_Candidate_Pool/l14_candidate_pool_summary.txt
Workbench/Gateway/Outbox/Layers/Layer_14_Ranking_Group_Leader_Candidate_Pool/l14_candidate_pool.manifest
Workbench/Gateway/Outbox/Layers/Layer_13_Dynamic_Ranking_Group_Selection/l13_selected_ranking_groups.csv
```

Optional calculation input:

```text
Aurora Core/<server>/Shared Market Data/OHLC Store/
```

L15 may read Shared OHLC Store to calculate candidate-pair correlation. It must not call MT5, poll the broker, create private OHLC caches, or request all-symbol deep OHLC.

---

## Scope Law

L15 is bounded to the L14 candidate pool.

Allowed:

```text
candidate-to-candidate pair context within L14 pool
candidate ranking_group overlap
candidate base/quote overlap
candidate diversity score
ranking_group diversity summary for groups represented inside L14
```

Forbidden:

```text
full 1200x1200 universe matrix
all-symbol deep OHLC scan for non-candidates
private OHLC cache
MT5 broker polling from Python
trade history consumption
setup logic
L23 permission logic
Global Top 10 final selection
trade permission
entry signal
execution
```

---

## Default Threshold

```text
max_allowed_pairwise_correlation_abs = 0.30
```

This is an untested default threshold, not a holy law.

L15 must label threshold use as:

```text
threshold_status=untested_default_not_holy_law
```

Correlation above the threshold creates a constraint / warning / rejection reason for L16 consideration. L15 itself must not build the final basket.

---

## Owned Fields

Candidate-level fields:

```text
corr_to_pool_max_abs
corr_to_pool_avg_abs
corr_pair_max_symbol
correlation_state
correlation_reject_reason
currency_overlap_score
ranking_group_overlap_score
asset_concentration_score
diversity_score
diversity_state
correlation_method
correlation_timeframe
correlation_lookback_bars
correlation_sample_count
correlation_confidence
l16_constraint_hint
```

Pair-level fields:

```text
symbol_a
symbol_b
ranking_group_a
ranking_group_b
base_currency_a
quote_currency_a
base_currency_b
quote_currency_b
same_ranking_group
shared_currency_count
shared_currency_reason
correlation_value
correlation_abs
correlation_state
correlation_sample_count
data_quality_reason
pair_diversity_risk_score
```

Group-level fields:

```text
ranking_group
candidate_count
leader_count
backup_count
max_pair_corr_abs
avg_pair_corr_abs
high_corr_pair_count
correlation_unavailable_pair_count
currency_overlap_pair_count
group_diversity_score
group_diversity_state
top_candidate
```

---

## Correlation Method V1

When Shared OHLC Store data is discoverable:

```text
timeframe=H1
lookback_bars=168
minimum_aligned_returns=80
method=Pearson correlation on log returns
```

Return calculation:

```text
return[t] = ln(close[t] / close[t-1])
```

If OHLC data is missing, stale, schema-unreadable, zero-variance, or insufficiently aligned, L15 must publish degraded proof instead of inventing correlation.

Required degraded states:

```text
missing_ohlc
insufficient_aligned_returns
zero_variance_returns
correlation_unavailable
```

---

## Output Route

Worker output route:

```text
Workbench/Gateway/Outbox/Layers/Layer_15_Correlation_Diversity_Selection/
    l15_candidate_correlation_matrix.csv
    l15_candidate_diversity_scores.csv
    l15_group_diversity_summary.csv
    l15_correlation_diversity_summary.txt
    l15_correlation_diversity.manifest
    RankingGroups/
        <ranking_group_slug>.correlation.txt
```

Stable Selection Desk output:

```text
Selection Desk/Groups/
    00_Correlation_Diversity_Summary.txt
    00_Correlation_Diversity_Summary.csv
```

Stable route only. Do not create parent folders named after changing rank, low correlation, high correlation, Top 10, Rank 1, cycle IDs, or strategy labels.

---

## Board Contract

```text
LAYER 15 - CORRELATION / DIVERSITY SELECTION
Status
Owner
Input Source
Candidate Pool Size
Candidates Scored
Pairwise Pairs
Correlation Pairs
High Correlation Pairs
Correlation Unavailable Pairs
Groups Represented
Max Pair Corr Abs
Top Diversity Candidate
Threshold Status
Selection Runtime: FALSE
Trade Permission: FALSE
Entry Signal: FALSE
Execution: FALSE
Main Blocker
```

---

## Dossier Contract

Per symbol:

```text
LAYER 15 - CORRELATION / DIVERSITY SELECTION
Status
Candidate Pool Member
Corr To Pool Max Abs
Corr To Pool Avg Abs
Corr Pair Max Symbol
Correlation State
Correlation Reject Reason
Currency Overlap Score
Ranking Group Overlap Score
Diversity Score
Diversity State
Correlation Confidence
L16 Constraint Hint
Meaning: correlation_diversity_scoring_only
Selection Runtime: FALSE
Trade Permission: FALSE
Entry Signal: FALSE
Execution: FALSE
```

Dossier must not say direction, setup, probability marketing, signal, permission, execution, or prop-rule clearance.

---

## L16 Handoff

L16 consumes L15 context.

L16 may use:

```text
l15_candidate_diversity_scores.csv
l15_candidate_correlation_matrix.csv
l15_group_diversity_summary.csv
```

L16 must remain the owner of Global Top 10 construction.

L15 must not create:

```text
global_top10
global_top10_rank
final_basket
selected_symbol
trade_candidate
```

---

## Acceptance Tests

L15 is acceptable only when runtime proves:

```text
L15 consumes L14 candidate pool only.
L15 consumes L13 selected groups as context.
L15 does not scan full universe for correlation.
L15 does not call MT5 or poll broker data from Python.
L15 reads Shared OHLC Store only when available.
L15 publishes degraded truth if OHLC is missing/insufficient.
L15 records max_allowed_pairwise_correlation_abs=0.30 and threshold_status=untested_default_not_holy_law.
L15 records candidate pair rows, candidate diversity rows, group summary rows, summary txt, and manifest.
L15 updates result_latest with l15_* fields.
L15 does not produce Global Top 10.
L15 does not claim strategy edge.
L15 does not claim trade permission.
trade_permission=false
entry_signal=false
execution=false
```

---

## Decision

TEST FIRST.

First implementation is proof-only correlation/diversity output. L16 remains the intelligent Global Top 10 builder.
