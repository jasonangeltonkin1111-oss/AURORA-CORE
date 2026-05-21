# AURORA CORE — VALIDATION & OUTCOME GUIDEBOOK

**System:** AURORA CORE  
**Role:** Edge falsification, outcome ledger, experiment registry, null-model testing, cost/slippage validation, regime/session tagging, and promotion/kill authority.  
**Status:** Overview guidebook foundation. Experiment thresholds and tester harness details may be refined later.

---

## 0. Purpose

This guidebook defines how AURORA CORE proves or kills edge claims.

It answers:

```text
What hypothesis is being tested?
What is the null model?
What data is required?
What costs/slippage/spread assumptions are used?
What sample size exists?
Which sessions/regimes were tested?
What outcome occurred?
What falsifies the claim?
What evidence rank was achieved?
```

Core law:

```text
Architecture is not edge.
Outcome evidence begins edge validation.
```

The enemy:

```text
Architecture-as-proof.
```

---

## 1. What This Guidebook Owns

This guidebook owns:

```text
outcome ledger
experiment registry
hypothesis registry
null model comparison
ranking validation
setup validation
score validation
cost-adjusted expectancy
slippage-adjusted expectancy
regime/session tagging
sample-size status
walk-forward later
Strategy Tester harness later
forward demo proof later
kill conditions
promotion rules
evidence ranking
```

---

## 2. What This Guidebook Must Not Own

This guidebook must not own:

```text
live permission by itself
auto-trade approval
runtime ranking source truth
publication routes
broker truth
raw evidence computation
```

Validation measures.

Permission decides.

---

## 3. Research Foundation

NIST AI RMF emphasizes governance, mapping, measurement, management, validity, reliability, safety, accountability, transparency, and risk management.

Reference:

```text
https://nvlpubs.nist.gov/nistpubs/ai/NIST.AI.100-1.pdf
```

Aurora translation:

```text
Every edge claim needs hypothesis, measurement, risk context, evidence rank, and kill conditions.
```

MQL5 provides Strategy Tester-related hooks such as `OnTester()` and tester statistics. These can support structured experiments later, but tester proof is not live proof.

Reference:

```text
https://www.mql5.com/en/docs/event_handlers/ontester
```

MQL5 `SendNotification()` and `WebRequest()` do not work in Strategy Tester, so validation harnesses must not rely on these runtime features inside tests.

References:

```text
https://www.mql5.com/en/docs/network/sendnotification
https://www.mql5.com/en/docs/network/webrequest
```

MQL5 `OrderCalcMargin()` calculates required margin for a planned trade operation in account currency, but does not include current pending/open positions.

Reference:

```text
https://www.mql5.com/en/docs/trading/ordercalcmargin
```

Aurora translation:

```text
Validation and safety must include actual exposure separately from planned-order margin estimates.
```

---

## 4. Core Validation Law

```text
No null model, no validation.
No cost model, no validation.
No kill condition, no experiment.
No outcome evidence, no edge claim.
```

Validation may recommend further testing.

Validation may not bypass Permission / Alert Owner.

---

## 5. Hypothesis Registry

Every tested idea needs a hypothesis.

Fields:

```text
hypothesis_id
hypothesis_name
claim
owner
score_or_setup
expected_effect
intended_use
out_of_scope_use
required_data
required_cost_model
required_null_model
kill_condition
promotion_condition
status
```

Vague idea is not a hypothesis.

---

## 6. Experiment Registry

Experiment Registry fields:

```text
experiment_id
hypothesis_name
owner
score_or_setup
intended_use
out_of_scope_use
data_requirement
symbols
sessions
regimes
time_range
cost_model
slippage_model
spread_model
null_model
kill_condition
promotion_condition
status
```

Every experiment must be reproducible enough to inspect.

---

## 7. Outcome Ledger

Outcome Ledger fields:

```text
cycle_id
experiment_id
symbol
bucket
rank_at_time
global_top10_flag
evidence_complete_flag
setup_candidate_flag
direction_if_any
entry_time_if_simulated
entry_price_if_simulated
stop_model
target_model
spread_at_signal
slippage_model
session
regime_label
mfe
mae
time_to_mfe
time_to_mae
target_hit
stop_hit
expired
net_r_after_cost
null_model_result
notes
```

Outcome Ledger begins edge validation.

It does not grant live permission alone.

---

## 8. Null Model Requirement

Every validation claim needs a null model.

Possible nulls:

```text
random symbol from same bucket
random time same symbol
random direction
top-ranked vs shuffled rank
same session random candidate
cost-only baseline
do-nothing baseline
```

If Aurora cannot beat a cheap null after costs, kill the claim.

---

## 9. Cost / Spread / Slippage Model

Minimum cost model:

```text
spread_at_signal
commission_if_known
slippage_assumption
swap_if_holding
fill_model
execution_delay_assumption
```

If cost is unknown:

```text
expectancy_status = incomplete
promotion_allowed = false
```

Backtests or simulations without realistic costs must be labelled weak.

---

## 10. Session and Regime Tagging

Outcome records should include:

```text
session
volatility_regime
spread_regime
trend_or_range_proxy
news_state
liquidity_state
market_open_state
```

A result without regime/session tags is weaker.

Do not generalize beyond observed regimes.

---

## 11. Sample-Size Discipline

Sample status values:

```text
sample_insufficient
sample_weak
sample_moderate
sample_strong
```

Do not lock universal thresholds too early.

Each experiment should define its own sample requirements.

No small handful of good examples proves edge.

---

## 12. Falsifier Requirement

Every hypothesis needs falsifiers.

Examples:

```text
underperforms null after costs
performance concentrated in one symbol only
performance disappears out-of-sample
large MAE before MFE makes prop risk unsafe
win rate survives but expectancy negative after costs
edge appears only in one spread regime
selection churn invalidates execution practicality
```

If there is no falsifier, the claim is not ready for validation.

---

## 13. Ranking Validation

Ranking validation asks:

```text
Did higher-ranked symbols outperform lower-ranked or random alternatives after costs?
```

Required comparisons:

```text
top-ranked vs random same bucket
top-ranked vs shuffled rank
top-ranked vs next-best rejected candidate
Global Top 10 vs bucket alternatives
```

Ranking validation does not imply trade permission.

---

## 14. Score Validation

Score validation asks:

```text
Did this score improve future outcomes or decision quality versus a null?
```

Required fields:

```text
score_name
formula_version
score_at_time
future_outcome_window
null_model
cost_model
result
```

A descriptive score remains descriptive until this validation passes.

---

## 15. Setup Validation

Setup validation asks:

```text
Does a setup rule produce positive expected value after costs and risk constraints?
```

Required before setup alert promotion:

```text
setup formula defined
evidence required defined
entry/exit/stop/target model defined
cost model defined
null model defined
sample requirement defined
kill condition defined
outcome reviewed
```

Setup validation is future work.

Current setup status remains:

```text
QUARANTINE
```

---

## 16. Basket Selection Validation

Basket validation asks:

```text
Did Global Top 10 inspection basket improve attention quality versus alternatives?
```

Possible tests:

```text
Global Top 10 vs random eligible symbols
Global Top 10 vs bucket-only Top 5 alternatives
correlation-filtered basket vs unfiltered basket
backup fill impact analysis
```

Global Top 10 remains an inspection basket unless validation says otherwise.

---

## 17. External Worker Output Validation Later

External worker outputs must be validated before use.

Future required fields:

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

## 18. Strategy Tester Harness Later

Strategy Tester may support structured falsification.

But:

```text
Strategy Tester proof is not live proof.
WebRequest and SendNotification are unavailable in Strategy Tester.
Tester conditions may not match broker/live execution.
```

Tester harness must record:

```text
symbol set
broker/model assumptions
time range
spread/slippage assumptions
cost assumptions
setup/formula versions
input data quality
```

---

## 19. Walk-Forward Later

Walk-forward validation should test whether a concept survives changing periods.

Fields later:

```text
train_period
test_period
walk_index
parameters_fixed_or_adapted
out_of_sample_result
degradation_reason
```

Walk-forward does not prove permanence.

It only improves evidence quality.

---

## 20. Forward Demo Later

Forward demo is stronger than backtest but still bounded.

Fields later:

```text
demo_account
broker
server
symbol_set
start_time
end_time
rule_version
execution_assumptions
observed_result
failure_logs
```

Forward demo still does not automatically grant live permission.

---

## 21. Evidence Rank and Promotion Rules

Evidence rank discipline:

```text
AI reasoning = no proof
source inspection = source state
static/compile validation = syntax/basic compatibility only
backtest = historical tested conditions only
out-of-sample / walk-forward = stronger but bounded
forward demo = observed demo conditions
small live = observed small live conditions
multi-broker multi-regime live = stronger but still bounded
```

Promotion requires:

```text
hypothesis defined
data requirement defined
cost model defined
null model defined
sample requirement defined
kill condition defined
outcome evidence reviewed
permission implications reviewed
```

Promotion means further testing unless Permission Owner explicitly changes permission state.

---

## 22. Kill Conditions

Kill conditions should be explicit.

Examples:

```text
underperforms null after costs
cost model invalidates expectancy
sample requirement not met
result is concentrated in one symbol/session only
out-of-sample failure
prop-firm risk unacceptable
execution assumptions unrealistic
```

A killed idea should not remain alive as vague roadmap hope.

---

## 23. No-Go Patterns

Do not allow:

```text
backtest profit called proof
Top 10 performance inferred without null model
spread ignored
slippage ignored
session/regime ignored
sample size too small
outcome cherry-picked
validation upgrades permission directly
synthetic test treated as live evidence
prop-firm risk ignored
external worker calculation treated as validation
```

---

## 24. Acceptance Criteria

This guidebook is acceptable if edge claims can be falsified.

Acceptance criteria:

```text
Every edge claim has a hypothesis.
Every hypothesis has null model, cost model, data requirement, sample requirement, and kill condition.
Outcome ledger captures MFE/MAE, cost, session, regime, and result.
Backtest is not live proof.
Validation does not directly grant permission.
Small sample does not prove edge.
External worker calculations later must be validated before use.
Claims can be killed explicitly.
```

---

## 25. Final Validation Law

```text
AURORA CORE does not earn belief by looking intelligent.
It earns belief by surviving falsification.
```

## Restoration Addendum — Validation Field Completeness
Validation/outcome datasets must include:
- sample_count_by_symbol
- sample_count_by_session
- sample_count_by_regime
- in_sample_expectancy
- out_of_sample_expectancy
- walk_forward_result
- cost_adjusted_expectancy
- slippage_adjusted_expectancy
- MAE
- MFE
- time_to_target_distribution
- false_positive_rate
- setup_decay_time
- regime_dependency
- broker_dependency
- null_model_comparison

Clarification law: calculation verification is not edge validation.
