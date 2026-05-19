# AURORA CORE — GOVERNANCE & LEDGER GUIDEBOOK

**System:** AURORA CORE  
**Role:** Proof spine, ledger authority, registry discipline, contradiction tracking, version evidence, and operational audit structure.  
**Status:** Overview guidebook foundation. Schema details may be refined later.

---

## 0. Purpose

This guidebook defines the governance and ledger spine for AURORA CORE.

It answers:

```text
What happened?
When did it happen?
Which owner produced it?
Which source was used?
What version/formula/schema created it?
Was it clean, partial, stale, degraded, failed, or blocked?
What evidence supports the claim?
```

Governance prevents trust-me-bro architecture.

Main law:

```text
No ledger, no proof.
```

---

## 1. What This Guidebook Owns

This guidebook owns:

```text
manifest ledger
runtime telemetry ledger
owner status ledger
layer status ledger
score registry
formula registry
selection ledger
evidence integrity ledger
alert ledger
prop rule profile ledger
outcome ledger
heatmap registry
order-flow availability ledger
contradiction ledger
external worker status ledger later
schema registry
schema/version discipline
ledger freshness rules
ledger failure states
```

---

## 2. What This Guidebook Must Not Own

This guidebook must not own:

```text
Board layout
Dossier layout
runtime calculation formulas
bucket taxonomy rules
trade permission decisions
edge claims
publication routes
MT5 FileIO implementation
```

Governance records proof.

Governance does not create trading truth.

---

## 3. Research Foundation

AURORA CORE adapts proven operational observability concepts.

Google SRE defines monitoring as collecting, processing, aggregating, and displaying quantitative system data, and distinguishes dashboards, alerts, white-box monitoring, black-box monitoring, symptoms, and causes.

Reference:

```text
https://sre.google/sre-book/monitoring-distributed-systems/
```

Aurora translation:

```text
Board summarizes.
Dossier explains.
Governance proves.
```

OpenTelemetry separates observability signals such as traces, metrics, logs, baggage, and profiles.

Reference:

```text
https://opentelemetry.io/docs/concepts/signals/
```

Aurora translation:

```text
Metrics = counts, durations, ages, pressure values, score values
Logs = event records, task outcomes, errors, warnings
Traces = cycle_id / request_id / owner path / worker request path
Context = server, account, cycle_id, heartbeat_id, owner_id, symbol
Profiles later = performance hotspots if needed
```

Prometheus instrumentation guidance favors stable metric names with labels rather than procedurally generated metric names.

Reference:

```text
https://prometheus.io/docs/practices/instrumentation/
```

Aurora translation:

```text
Use stable schemas and label fields.
Do not generate one column/file name per symbol when rows with labels are safer.
```

NIST AI RMF emphasizes governance, measurement, management, versioning, and trustworthiness.

Reference:

```text
https://nvlpubs.nist.gov/nistpubs/ai/NIST.AI.100-1.pdf
```

Aurora translation:

```text
Formulas, schemas, taxonomy engines, worker versions, and owner outputs need version and evidence status.
```

---

## 4. Governance Law

Every serious claim needs a ledger home.

Claims requiring a ledger:

```text
symbol eligible
score calculated
formula version changed
bucket classified
bucket selected
Global Top 10 built
correlation reject applied
backup fill used
deep evidence complete
evidence dependency waiting
permission blocked
alert suppressed
worker output stale later
publication written
publication failed
contradiction found
```

No ledger means no operational proof.

---

## 5. Ledger vs Board vs Dossier

Surface boundaries:

```text
Board summarizes system-level truth.
Dossier explains per-symbol truth.
Governance proves what happened.
Manifest records physical publication proof.
Runtime Owners own truth.
```

Governance must not become the Board.

Board must not become Governance.

Dossier must not become Governance.

---

## 6. Signal Types

Aurora governance separates signal types.

### Metrics

```text
heartbeat duration
publication age
lane queue depth
score value
symbol counts
stale counts
error counts
```

### Logs

```text
task outcome
write failure
retry event
alert suppression
permission block
contradiction entry
```

### Traces

```text
cycle_id
heartbeat_id
request_id
owner path
worker request path later
```

### Context

```text
server
account
symbol
owner_id
layer_id
schema_version
formula_version
```

Rule:

```text
Do not dump every proof type into one mega-log.
Use the right ledger for the right claim.
```

---

## 7. Schema and Version Discipline

Every ledger should define:

```text
schema_name
schema_version
owner
purpose
required_fields
optional_fields
status_values
freshness_fields
version_fields
```

Version fields may include:

```text
schema_version
formula_version
taxonomy_engine_version
score_registry_version
worker_version later
runtime_owner_version later
guidebook_version later
source_snapshot_hash
```

Rule:

```text
If the meaning of a field changes, the schema version must change.
```

---

## 8. Stable Names and Label Discipline

Bad pattern:

```text
EURUSD_score
GBPUSD_score
XAUUSD_score
```

Good pattern:

```text
symbol,score_name,formula_version,value,status
EURUSD,surface_cost,v1,82.4,complete
GBPUSD,surface_cost,v1,77.1,complete
XAUUSD,surface_cost,v1,,unavailable
```

Rule:

```text
Ledger schemas must use stable columns and value labels.
Avoid generated column names per symbol.
```

---

## 9. Manifest Ledger

Owns physical publication proof.

Fields:

```text
file_id
surface
route
final_path
temp_path
write_started_at
write_finished_at
bytes_written
final_exists
final_size
write_status
degraded_state
source_owner_versions
cycle_id
heartbeat_id
publication_owner_status
```

Statuses:

```text
file_written_clean
file_written_degraded
file_written_partial
physical_write_failed
verify_failed
route_missing
```

---

## 10. Runtime Telemetry Ledger

Owns runtime pulse proof.

Fields:

```text
cycle_id
heartbeat_id
timer_started_at
timer_finished_at
timer_duration_ms
timer_budget_ms
over_budget_flag
runtime_state
breath_phase
owner_executed
lane_executed
tasks_due_count
tasks_executed_count
tasks_deferred_count
starved_task_count
oldest_starved_task_age_seconds
publication_completed_flag
board_write_age_seconds
deep_lane_progress_pct
recovery_lane_pending_count
lane_queue_depth
load_shed_count
retry_count
retry_success_count
circuit_breaker_open_count
fake_alive_risk_flag
```

---

## 11. Owner Status Ledger

Owns Runtime Owner health proof.

Fields:

```text
owner_id
owner_name
owner_status
last_attempt_at
last_success_at
freshness_state
pending_count
partial_count
degraded_count
blocked_count
failed_count
starved_task_count
oldest_starved_task_age_seconds
last_publication_state
```

Status values:

```text
not_started
shell_printed
filling
partial
complete
complete_with_degraded
blocked
stale
failed
```

---

## 12. Layer Status Ledger

Owns logical layer progress proof.

Fields:

```text
layer_id
layer_name
source_owner
cycle_id
complete_count
partial_count
stale_count
blocked_count
degraded_count
unknown_count
last_success_at
freshness_state
degraded_reason
blocked_reason
```

---

## 13. Score Registry

Owns score metadata proof.

Fields:

```text
score_name
score_type
formula_version
owner
directional_validity
expectancy_validated
trade_permission
normalization_basis
sample_window
intended_use
out_of_scope_use
validation_status
```

Default for ranking scores:

```text
score_type = descriptive
directional_validity = false
expectancy_validated = false
trade_permission = false
```

---

## 14. Formula Registry

Owns formula definition proof.

Fields:

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

Formula changes must update the registry.

---

## 15. Selection Ledger

Owns selection proof.

Fields:

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

The selection ledger records inspection baskets.

It does not imply trades.

---

## 16. Evidence Integrity Ledger

Owns selected evidence completeness proof.

Fields:

```text
cycle_id
symbol
deep_selected_flag
OHLC_status
wick_status
tick_window_status
indicator_status
VWAP_status
liquidity_status
DOM_proxy_status
dependency_wait_reason
evidence_freshness_state
evidence_degraded_reason
```

---

## 17. Alert Ledger

Owns alert proof.

Fields:

```text
alert_id
cycle_id
alert_class
alert_type
owner
symbol_if_any
fired_flag
suppressed_flag
suppression_reason
cooldown_state
permission_state
created_at
```

Alerts must remain rare.

Progress events are not alerts.

---

## 18. Prop Rule Profile Ledger

Owns prop-firm rule profile state.

Fields:

```text
profile_id
firm_name
account_phase
daily_loss_formula
max_loss_formula
equity_vs_balance_basis
trailing_drawdown_type
news_restriction_window
max_lots
max_positions
consistency_rule
rule_last_verified_date
profile_status
```

If prop rules are unknown:

```text
prop_rule_status = unknown
trade_allowed = false
```

---

## 19. Outcome Ledger

Owns future validation records.

Fields:

```text
cycle_id
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

Outcome ledger begins edge validation.

It does not prove live permission alone.

---

## 20. Heatmap Registry

Owns heatmap proof.

Fields:

```text
heatmap_name
heatmap_type
source_owner
cycle_id
status
last_updated
input_snapshot_hash
degraded_reason
rows_count
columns_count
```

Core heatmaps:

```text
Global Top 10 Correlation Heatmap
Bucket Strength / Heat Heatmap
Session Relevance Heatmap
Cost vs Movement Heatmap
Evidence Completeness Heatmap
```

---

## 21. Order-Flow Availability Ledger

Owns MT5 order-flow proxy availability proof.

Fields:

```text
symbol
order_flow_source
mt5_tick_proxy_available
mt5_dom_proxy_available
DOM_subscription_status
last_checked_at
availability_status
degraded_reason
```

Allowed source labels:

```text
mt5_tick_proxy
mt5_dom_proxy
unavailable
```

Forbidden:

```text
true_order_flow
institutional_order_flow
smart_money_confirmed
```

---

## 22. External Worker Status Ledger Later

Future ledger for External Worker & Calculation Bridge.

Fields may include:

```text
external_worker_enabled
worker_id
worker_version
worker_status
last_worker_seen
last_request_id
last_completed_request_id
input_hash_seen
result_hash
schema_version
calculation_status
calculation_duration_ms
worker_degraded_reason
```

External Worker may calculate.

External Worker may not become broker truth, publication owner, or permission owner.

---

## 23. Contradiction Ledger

Owns conflicts between claims/sources/owners.

Fields:

```text
contradiction_id
claim_a
claim_b
source_a
source_b
owner_a
owner_b
evidence_rank_a
evidence_rank_b
which_owner_should_own_truth
resolution_test
pause_required
status
```

Default:

```text
If contradiction affects publication, permission, source truth, ranking, evidence integrity, or external worker results: HOLD until resolved.
```

Contradictions must not be solved by vague prose.

---

## 24. Schema Registry

Owns schema version proof.

Fields:

```text
schema_name
schema_version
owner
ledger_file
required_fields
optional_fields
status_values
created_at
updated_at
change_reason
```

---

## 25. Ledger Freshness Rules

Each ledger should expose:

```text
last_written_at
age_seconds
freshness_state
source_cycle_id
source_heartbeat_id
```

Freshness states:

```text
fresh
aging
stale
expired
unknown
```

A stale ledger may still exist.

It must be labelled stale.

---

## 26. Ledger Failure States

Ledger failure states:

```text
not_started
partial
complete
complete_with_degraded
stale
write_failed
schema_mismatch
source_missing
owner_missing
contradiction_found
```

---

## 27. No-Go Patterns

Do not allow:

```text
Board says complete but manifest says write failed.
Dossier says evidence complete but evidence_integrity says pending.
Formula changed but formula_registry not updated.
Global Top 10 changed but selection_ledger missing.
Worker output used but worker_status stale later.
Scores published without formula version.
Taxonomy unknowns hidden as Other.
Contradiction resolved by prose instead of ledger.
Generated symbol-specific columns that break schema stability.
Governance granting trade permission.
```

---

## 28. Acceptance Criteria

This guidebook is acceptable if governance can prove Aurora state.

Acceptance criteria:

```text
Every serious claim has a ledger home.
Ledgers use stable schemas.
Ledgers record owner, version, cycle_id, heartbeat_id, freshness, and status.
Scores and formulas are versioned.
Selection changes are logged.
Evidence completeness is logged.
Publication proof is logged.
Contradictions are logged explicitly.
Governance does not become Board/Dossier.
Governance does not create permission or edge claims.
```

---

## 29. Final Governance Law

```text
Governance proves what happened.
It does not make the trade.
It does not sell the signal.
It records the truth so Aurora cannot lie to itself.
```
