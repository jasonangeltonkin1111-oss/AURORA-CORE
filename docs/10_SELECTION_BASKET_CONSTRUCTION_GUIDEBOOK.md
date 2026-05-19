# AURORA CORE — SELECTION & BASKET CONSTRUCTION GUIDEBOOK

**System:** AURORA CORE  
**Role:** Bucket leader selection, candidate-pool construction, diversity/correlation control, Global Top 10 inspection basket, backup fill, and selection-ledger authority.  
**Status:** Overview guidebook foundation. Exact formulas and thresholds may be refined later.

---

## 0. Purpose

This guidebook defines how AURORA CORE turns bucket leaders into a diversified inspection basket.

It answers:

```text
Which buckets are active?
Which symbols lead each bucket?
Which symbols enter the candidate pool?
Which candidates are too correlated / too overlapping?
Which symbols become Global Top 10?
Which strong candidates were rejected and why?
Which backup fills were used?
Which selected symbols feed Deep Evidence?
```

Core law:

```text
Selection is attention.
Selection is not permission.
```

The enemy:

```text
Global Top 10 becomes “best trades.”
```

Kill that language immediately.

---

## 1. What This Guidebook Owns

This guidebook owns:

```text
bucket Top 5
sub-bucket Top 5
candidate pool
dynamic bucket selection
correlation / overlap filtering
diversity scoring
backup fill
Global Top 10
correlation rejects
selection hysteresis
selection churn control
manual pins later
selected-deep-evidence feed
selection ledger requirements
```

---

## 2. What This Guidebook Must Not Own

This guidebook must not own:

```text
bucket taxonomy rules
surface score formulas
deep evidence computation
trade permission
setup validation
alerts
outcome edge claims
publication routes
```

Selection chooses attention.

Selection does not approve trading.

---

## 3. Research Foundation

Modern Portfolio Theory's core insight is that portfolio risk depends on how assets combine, including covariance/correlation, not only individual risk/return.

Reference:

```text
https://www.investopedia.com/terms/m/modernportfoliotheory.asp
```

Aurora translation:

```text
Correlation and overlap controls are useful for basket concentration risk.
They do not prove trading edge.
```

Diversification research also shows limits: correlations may rise in stress and diversification can become less effective during regime changes.

Reference:

```text
https://arxiv.org/abs/2202.10623
```

Aurora translation:

```text
Correlation filter = basket concentration control.
Correlation filter ≠ edge.
Correlation filter ≠ safety guarantee.
```

---

## 4. Core Selection Law

```text
Bucket Top 5 = alternatives.
Global Top 10 = diversified inspection basket.
Neither means trade permission.
```

Selection output default metadata:

```text
selection_type = inspection
trade_permission = false
directional_validity = false
expectancy_validated = false
```

---

## 5. Bucket Top 5 vs Global Top 10

Bucket Top 5 answers:

```text
Which symbols are strongest alternatives inside this bucket?
```

Global Top 10 answers:

```text
Which selected candidates form the best diversified inspection basket right now?
```

Bucket Top 5 must remain visible even if a symbol is not in Global Top 10.

Correlation rejection from Global Top 10 must not erase the symbol from its bucket list.

---

## 6. Candidate Pool Contract

Candidate pool should be built from bucket leaders.

Wrong:

```text
sort all eligible symbols globally and pick top 10
```

Correct:

```text
rank inside buckets
select active/valid buckets
build candidate pool from bucket leaders
apply diversity/correlation controls
build Global Top 10
publish rejects/backups
```

Candidate pool fields:

```text
cycle_id
symbol
bucket
sub_bucket
bucket_rank
surface_score_summary
bucket_heat_score
candidate_reason
candidate_status
data_quality_status
```

---

## 7. Dynamic Bucket Selection Contract

Dynamic bucket selection should consider:

```text
bucket_heat
bucket_strength
bucket_quality
bucket_activity
bucket_cost
bucket_movement
bucket_degraded_count
bucket_backup_depth
```

Dynamic buckets are selected for inspection coverage.

They are not trading sectors.

They are not permission groups.

---

## 8. Correlation / Overlap Control

Correlation and overlap controls help avoid picking many versions of the same exposure.

Fields:

```text
correlation_sample_count
correlation_window
correlation_to_selected
currency_overlap
bucket_overlap
asset_class_overlap
diversity_score
correlation_confidence
reject_reason
```

No naked correlation numbers.

Every correlation value needs:

```text
window
sample_count
confidence
source
```

---

## 9. Diversity Score Contract

Diversity score may use:

```text
correlation_to_selected
currency_overlap
bucket_overlap
asset_class_overlap
instrument_type_overlap
session_overlap
```

Diversity score means:

```text
concentration control
```

It does not mean:

```text
edge
lower guaranteed risk
prop-firm safety
```

---

## 10. Correlation Confidence and Sample Rules

Correlation confidence states:

```text
unknown
low
medium
high
```

Weak sample count must reduce confidence.

If correlation input is insufficient:

```text
correlation_status = insufficient_sample
selection_may_continue = true if labelled
confidence = low / unknown
```

Do not block all publication because correlation is weak.

Publish weak correlation as weak.

---

## 11. Backup Fill Rules

Backup fill is used when Global Top 10 cannot be filled cleanly from primary candidates.

Backup fill must record:

```text
backup_fill_used
backup_symbol
backup_source_bucket
backup_reason
backup_rank
backup_degraded_state
```

Allowed backup reasons:

```text
correlation_reject_removed_primary
candidate_pool_too_small
selected_bucket_shortfall
symbol_became_unavailable
data_quality_degraded
```

Backup fill must not hide weak inputs.

---

## 12. Correlation Reject Visibility

Rejected candidates remain visible.

Required fields:

```text
correlation_reject = true
rejected_symbol
reject_reason
conflicting_selected_symbol
correlation_value
correlation_confidence
alternative_status
```

Example:

```text
correlation_reject = true
reject_reason = too_correlated_with_EURUSD
alternative_status = still_visible_in_bucket_top5
```

Do not erase useful alternatives.

---

## 13. Global Top 10 Contract

Global Top 10 fields:

```text
global_rank
symbol
bucket
selection_reason
score_summary
correlation_note
backup_fill_flag
deep_evidence_feed_flag
permission_state
```

Required label:

```text
Global Top 10 = diversified inspection basket
```

Forbidden label:

```text
best 10 trades
```

---

## 14. Selection Hysteresis and Churn Control

If Global Top 10 changes every heartbeat, Deep Lane can thrash.

Required concepts:

```text
minimum_hold_cycles
replacement_reason
selection_hysteresis
churn_warning
deep_batch_replace_allowed
```

Rule:

```text
Do not replace selected deep symbols every heartbeat unless risk, market availability, or explicit selection invalidation forces it.
```

Selection churn must be visible.

---

## 15. Deep Evidence Feed Contract

Selection feeds Selected Evidence Owner.

Selection does not compute evidence.

Feed fields:

```text
selected_symbol
selection_cycle_id
deep_evidence_feed_flag
selection_reason
deep_batch_priority
replacement_allowed
```

Selected Evidence Owner decides evidence collection state.

---

## 16. Manual Pins Later

Manual pins may exist later, but must be ledgered.

Manual pin fields:

```text
manual_pin_flag
pinned_symbol
pin_reason
pin_created_at
pin_expires_at
operator_id_optional
selection_override_status
```

Manual pins must not bypass:

```text
Foundation Truth Owner
Permission / Alert Owner
Publication Owner
Selection Ledger
```

Manual pin means attention, not permission.

---

## 17. Selection Ledger Contract

Selection Ledger must record:

```text
cycle_id
selection_id
bucket_selected
candidate_pool_size
global_top10_symbols
correlation_rejects
backup_fill_used
backup_fill_reason
selection_reason
source_owner
selection_status
```

Selection Ledger proves how the basket was built.

It does not prove edge.

---

## 18. Failure States

Selection failure/degraded states:

```text
candidate_pool_missing
candidate_pool_partial
selected_bucket_shortfall
correlation_input_insufficient
correlation_confidence_low
backup_fill_active
basket_partial
selection_churn_warning
deep_batch_replace_blocked
```

Failure states must print.

They must not silently hide candidates.

---

## 19. No-Go Patterns

Do not allow:

```text
Global Top 10 treated as trade list
Correlation reject hides good alternatives
Bucket Top 5 disappears after Global Top 10 built
Candidate pool built from all-symbol soup
Selection churn resets deep evidence forever
Manual pin bypasses selection ledger
Backup fill not labelled
Correlation computed on too few samples but shown as strong proof
Selection grants trade permission
```

---

## 20. Acceptance Criteria

This guidebook is acceptable if selection remains attention-only and auditable.

Acceptance criteria:

```text
Global Top 10 is labelled inspection basket.
Bucket Top 5 remains visible.
Candidate pool comes from bucket leaders.
Correlation rejects remain visible.
Backup fill is labelled.
Selection hysteresis prevents deep evidence thrash.
Correlation confidence/sample/window are recorded.
Selection does not imply trade permission.
Selection feeds Selected Evidence Owner only after valid selection state.
```

---

## 21. Final Selection Law

```text
AURORA CORE may select what deserves attention.
It may not pretend attention is edge.
```
