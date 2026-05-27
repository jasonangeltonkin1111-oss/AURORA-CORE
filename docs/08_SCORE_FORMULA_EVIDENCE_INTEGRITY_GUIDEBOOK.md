# AURORA CORE — SCORE, FORMULA & EVIDENCE INTEGRITY GUIDEBOOK

**System:** AURORA CORE  
**Role:** Score discipline, formula ownership, evidence completeness, calculation verification, confidence labels, and anti-fake-number law.  
**Status:** Overview guidebook foundation. Formula-level details may be refined later.

---

## 0. Purpose

This guidebook prevents beautiful fake numbers.

It answers:

```text
What does this score mean?
Who owns the formula?
What inputs were used?
What version created it?
Is it descriptive or predictive?
Is directional validity proven?
Is expectancy validated?
Is the evidence complete enough to use?
What test verified the formula?
```

Core law:

```text
Correct formula does not prove profitable edge.
```

---

## 1. What This Guidebook Owns

This guidebook owns:

```text
score labels
score classes
formula ownership
formula versioning
input/output field contracts
normalization basis
sample windows
confidence labels
evidence completeness
calculation verification
synthetic tests
manual checks
runtime checks
descriptive vs predictive separation
score-card template
formula registry contract
evidence integrity contract
```

---

## 2. What This Guidebook Must Not Own

This guidebook must not own:

```text
final taxonomy / ranking_group model
Global Top 10 final construction
trade permission
strategy validation outcome
publication routes
external worker bridge protocol
```

This guidebook defines calculation integrity.

It does not grant trading permission.

---

## 3. Research Foundation

NIST AI RMF treats validity and reliability as central trustworthiness characteristics and emphasizes testing, evaluation, verification, validation, governance, measurement, and management.

Reference:

```text
https://nvlpubs.nist.gov/nistpubs/ai/NIST.AI.100-1.pdf
```

Aurora translation:

```text
Calculation correctness must be separated from trading usefulness.
```

ISO 8000 is a data quality standard family focused on data quality and master data discipline.

Reference:

```text
https://en.wikipedia.org/wiki/ISO_8000
```

Aurora translation:

```text
Scores must declare data quality, completeness, timeliness, consistency, and fitness for use.
```

Model-card practice documents intended use, limitations, risks, and performance characteristics.

Reference:

```text
https://en.wikipedia.org/wiki/Model_card
```

Aurora translation:

```text
Each score needs a score card: intended use, out-of-scope use, limitations, evidence rank, and validation status.
```

---

## 4. Core Score Law

```text
A score is not a signal unless validation proves it.
A score is not permission unless Permission Owner allows it.
A correct formula is not edge.
A clean output is not expectancy.
```

Default for ranking scores:

```text
score_type = descriptive
directional_validity = false
expectancy_validated = false
trade_permission = false
```

---

## 5. Score Classes

Allowed score classes:

```text
descriptive
predictive_unvalidated
predictive_validated
execution_risk
portfolio_risk
data_quality
operator_attention
```

### Descriptive

Means:

```text
Useful for observation, ranking, or attention.
```

Does not mean:

```text
profitable
buy/sell
setup confirmed
```

### Predictive unvalidated

Means:

```text
Hypothesis claims future relevance but is not proven.
```

Status:

```text
QUARANTINE / TEST FIRST
```

### Predictive validated

Allowed only after outcome validation.

### Execution risk

Measures trading/execution danger, not opportunity.

### Data quality

Measures whether inputs are usable.

### Operator attention

Helps prioritize human review.

---

## 6. Score-Card Template

Every score needs:

```text
score_name
score_owner
score_type
formula_name
formula_version
input_fields
output_fields
normalization_basis
sample_window
freshness_requirement
confidence_basis
known_limitations
intended_use
out_of_scope_use
directional_validity
expectancy_validated
trade_permission
validation_status
```

Example:

```text
score_name = surface_cost_score
intended_use = rank symbols by relative cost/friction
out_of_scope_use = buy/sell signal
directional_validity = false
trade_permission = false
```

---

## 7. Formula Contract

Each formula must define:

```text
formula_name
formula_version
owner
inputs
outputs
units
rounding_policy
missing_input_behavior
zero_division_behavior
normalization_behavior
stale_input_behavior
dependency_behavior
synthetic_test_cases
manual_check_method
runtime_check_method
```

No formula is allowed to operate as hidden magic.

---

## 8. Formula Versioning

Formula version changes are required when:

```text
input fields change
output fields change
normalization changes
rounding changes
missing-data behavior changes
stale-data behavior changes
zero-division behavior changes
formula math changes
score meaning changes
```

Formula version changes must update the Formula Registry.

---

## 9. Input / Output Field Rules

Every field must know:

```text
field_name
source_owner
unit
type
required_flag
missing_behavior
stale_behavior
valid_range
```

Do not use unnamed intermediate values as final truth.

---

## 10. Units and Normalization Rules

Every formula must state units.

Examples:

```text
points
pips
percent
ratio
bps
seconds
bars
currency
```

Every normalized score must state:

```text
normalization_basis
normalization_population
normalization_window
outlier_policy
```

Normalization changes can change meaning.

They require version changes.

---

## 11. Missing / Stale / Zero-Division Behavior

Bad pattern:

```text
if range == 0, set score = 0 silently
```

Good pattern:

```text
range = 0
score_status = unavailable
zero_range_flag = true
reason = zero_division_guard
```

Missing and stale data must produce explicit states:

```text
missing_input
stale_input
dependency_wait
unavailable
partial
```

Never convert missing truth into fake zero.

---

## 12. Evidence Integrity Model

Evidence states:

```text
not_started
pending
partial
complete
complete_with_degraded
stale
failed
unavailable
dependency_wait
```

Evidence dimensions:

```text
freshness
completeness
source_owner
schema_version
sample_count
time_window
symbol_scope
broker_scope
confidence
```

A score cannot be cleaner than its evidence.

---

## 13. Data Quality Dimensions for Aurora

General dimensions:

```text
accuracy
completeness
consistency
timeliness
validity
uniqueness
lineage
availability
fitness_for_use
```

Trading-specific dimensions:

```text
quote_freshness
spread_validity
broker_spec_completeness
bar_count_sufficiency
tick_window_sufficiency
symbol_scope_correctness
session_scope_correctness
cost_model_presence
```

---

## 14. Formula Verification Ladder

Formula verification ladder:

```text
0. Formula written
1. Inputs/outputs defined
2. Units defined
3. Missing/stale behavior defined
4. Synthetic tests pass
5. Manual chart/sample check passes
6. Runtime sample check passes
7. Cross-broker sanity check passes later
8. Outcome usefulness validated later
```

Important distinction:

```text
Level 6 proves calculation behavior.
Level 8 begins usefulness evidence.
```

No formula can jump from definition to edge.

---

## 15. Calculation Correctness vs Trading Usefulness

Calculation correctness means:

```text
formula is implemented as intended
inputs/outputs behave correctly
edge cases are handled
runtime samples match expectations
```

Trading usefulness means:

```text
score improves decisions after cost, spread, slippage, session, regime, and null-model comparison
```

These are different.

A formula can be mathematically correct and financially useless.

---

## 16. Confidence Labels

Allowed confidence labels:

```text
unknown
low
medium
high
verified_calculation
validated_outcome
```

Do not use:

```text
guaranteed
certain
confirmed profitable
institutional grade
prop-rule cleared
```

---

## 17. Formula Registry Contract

Formula Registry must record:

```text
formula_name
formula_version
owner
input_fields
output_fields
units
rounding_policy
missing_input_behavior
zero_division_behavior
normalization_behavior
stale_input_behavior
verification_status
synthetic_test_status
manual_check_status
runtime_check_status
```

No published formula without registry entry.

---

## 18. Evidence Integrity Ledger Contract

Evidence Integrity Ledger must record:

```text
symbol
owner
evidence_type
status
freshness_state
sample_count
time_window
schema_version
source_snapshot_hash
dependency_wait_reason
degraded_reason
```

No deep evidence claim without integrity state.

---

## 19. External Worker Calculation Output Rules Later

External worker outputs must be validated before use.

Required future fields:

```text
request_id
cycle_id
worker_id
worker_version
schema_version
input_hash_seen
result_hash
calculation_status
freshness_state
```

External worker may calculate.

External worker may not become broker truth, publication owner, or permission owner.

---

## 20. Evidence Rank Mapping

Score claims must respect evidence rank.

```text
AI reasoning proves nothing by itself.
Source inspection proves source state.
Static validation proves structure/syntax only.
Runtime logs prove observed runtime behavior.
Backtest proves tested historical conditions only.
Forward demo/live evidence is stronger but bounded.
```

A score may only claim what its evidence supports.

---

## 21. No-Go Patterns

Do not allow:

```text
score appears without formula version
score appears without input fields
score uses stale quote silently
formula handles missing input with fake zero
normalized score changes without version update
indicator context becomes strategy signal
correlation score becomes trade permission
ranking_group heat becomes trade conviction
external worker result used without freshness/hash/schema validation
```

---

## 22. Acceptance Criteria

This guidebook is acceptable if it blocks fake numbers.

Acceptance criteria:

```text
Every score has type, owner, formula version, intended use, out-of-scope use.
Every formula has input/output/units/missing behavior.
Every score defaults to descriptive unless validated.
No score implies direction or edge by default.
Evidence completeness is checked before score use.
Formula correctness is separated from trading usefulness.
All formula changes require registry update.
External worker outputs later must be schema/freshness/hash validated before use.
```

---

## 23. Final Score Law

```text
AURORA CORE may calculate beautiful numbers.
It may not believe them until evidence earns that belief.
```

## Restoration Addendum — Score / Formula / Evidence Integrity Expansion
### Score families in scope
- L6 cost/friction score
- L7 session relevance score
- L8 movement/range score
- L9 structure/location score
- L11 ranking_group rank score
- L12 ranking_group heat/quality score
- L15 diversity/correlation utility
- L16 global basket utility
- heatmap metrics and stability/change signals

### Evidence integrity families
- OHLC completeness
- Wick one-to-one parity with OHLC
- Rolling tick window sufficiency
- Indicator/reference readiness
- VWAP source confidence (`real_volume`, `tick_volume_proxy`, `unavailable`)
- Bollinger fields completeness
- Liquidity map confidence
- DOM/order-flow proxy availability
- Selected evidence integrity passed/failed

### Formula verification requirements
- synthetic_verified
- manual_chart_verified
- source_inspected
- compile_verified (later)
- runtime_observed (later)
- live_verified (later, if ever)

No formula may be declared correct without corresponding evidence state.
