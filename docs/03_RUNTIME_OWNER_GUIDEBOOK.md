# AURORA CORE — RUNTIME OWNER GUIDEBOOK

**System:** AURORA CORE  
**Role:** Runtime ownership boundaries, authority map, layer grouping, interface contracts, failure states, telemetry, and anti-shadow-owner law.  
**Status:** Overview guidebook foundation. Details may be refined owner-by-owner during implementation.

---

## 0. Purpose

Runtime Owners are the permanent top-level architecture headers inside AURORA CORE.

Logical layers live under Runtime Owners.

AURORA CORE must not become 23 separate engines.

This guidebook defines each Runtime Owner as a bounded authority area with:

```text
purpose
owned layers
source-of-truth authority
inputs
outputs
forbidden ownership
lane usage
publication contract
failure states
telemetry
acceptance criteria
```

Runtime Owners are not just labels.

They are the system's organs.

---

## 1. Research Foundation

This guidebook is based on senior architecture principles adapted to AURORA CORE.

### Bounded context principle

Complex systems need explicit boundaries where a model is consistent and authority is clear.

Aurora translation:

```text
Each Runtime Owner is a bounded context.
Each owner has one authority domain.
No owner may silently compute or publish another owner's truth.
```

### Modular monolith discipline

AURORA CORE should begin as a disciplined modular MT5 system, not a distributed service zoo.

Aurora translation:

```text
Keep one MT5 EA runtime.
Use owner boundaries internally.
Avoid duplicate modules and shadow owners.
Do not split implementation merely because the blueprint has many layers.
```

### Operational ownership principle

An owner is not real unless it has operational responsibility.

Aurora translation:

```text
Each Runtime Owner must expose status, failures, stale state, and proof fields.
If an owner cannot publish its health, it is not a valid owner.
```

### Resilience boundary principle

Bulkheads, retries, circuit breakers, and backpressure are useful only when ownership and failure boundaries are clear.

Aurora translation:

```text
Runtime Owners must declare lane usage and failure behavior.
Timing controls protect owners from starving each other.
Publication exposes each owner's state.
```

---

## 2. Permanent Runtime Owners

AURORA CORE has 8 Runtime Owners:

```text
1. Foundation Truth Owner
2. Surface Scoring Owner
3. Bucket Intelligence Owner
4. Basket Selection Owner
5. Selected Evidence Owner
6. Permission / Alert Owner
7. Publication Owner
8. Validation / Outcome Owner
```

These are permanent overview headers.

Layer details may evolve.

Owner boundaries must not drift without explicit architecture revision.

---

## 3. Global Runtime Owner Laws

### Law 1 — Existing owner first

Before adding any module, helper, field, file, formula, cache, or route:

```text
find the current Runtime Owner
inspect what it already owns
patch that owner if possible
avoid duplicate authority
```

New ownership is allowed only if the current owner is proven insufficient and a migration/delete/demote plan exists.

---

### Law 2 — No shadow owners

A shadow owner is any module, helper, file, prompt, or guidebook section that secretly owns truth that belongs elsewhere.

Forbidden examples:

```text
Selection Desk recomputes Global Top 10 independently.
Dossier recalculates bucket rank instead of consuming bucket truth.
Board decides permission instead of displaying Permission Owner state.
Indicator helper silently creates setup signals.
File writer creates final output paths outside Publication Owner.
Validation ledger changes live permission without Permission Owner state.
```

Shadow owners are architecture infection.

Kill them early.

---

### Law 3 — One source of truth per truth type

Each truth type must have one owner.

Examples:

```text
account state                 = Foundation Truth Owner
surface score                 = Surface Scoring Owner
bucket taxonomy               = Bucket Intelligence Owner
Global Top 10                 = Basket Selection Owner
OHLC / wick / tick evidence    = Selected Evidence Owner
permission state              = Permission / Alert Owner
file publication state         = Publication Owner
edge validation state          = Validation / Outcome Owner
```

Consumers may display truth.

Consumers may not secretly own truth.

---

### Law 4 — Owner output contracts are mandatory

Every Runtime Owner must publish machine-readable and/or human-readable state sufficient for:

```text
Board display
Dossier display where relevant
Governance ledgers
Atomic Update Overview
Debugging
future worker continuation
```

If output cannot be inspected, the owner is not operationally real.

---

### Law 5 — Fail degraded, not invisible

If an owner cannot complete its work:

```text
publish partial state
publish degraded reason
publish dependency wait
publish stale state
publish unavailable state
```

Do not disappear.

Do not fake complete.

---

### Law 6 — Owner boundaries outrank convenience

Convenience cannot justify ownership leaks.

Wrong:

```text
The Board already has all fields, so let it compute the final score.
```

Correct:

```text
The Board displays the score produced by the rightful owner.
```

---

### Law 7 — Runtime Owners map to lanes, not to separate engines

A Runtime Owner may use multiple runtime lanes.

A runtime lane may serve multiple owners.

Do not confuse owners with lanes.

```text
Owner = authority domain.
Lane  = timing/scheduler traffic class.
Layer = logical truth section.
```

---

## 4. Runtime Owner Contract Template

Every Runtime Owner must eventually define:

```text
owner_id
owner_name
purpose
owned_layers
truth_authority
allowed_inputs
owned_outputs
consumers
forbidden_ownership
runtime_lanes_used
cadence_family
cache_policy
stale_policy
failure_states
publication_contract
governance_contract
telemetry_fields
acceptance_criteria
kill_conditions
```

This template is mandatory for owner-level implementation design.

---

# Runtime Owner 1 — Foundation Truth Owner

## Purpose

Answer:

```text
What exists?
What is open?
What is tradable?
What is fresh?
What is blocked?
```

The Foundation Truth Owner is the base truth provider for broker/account/market availability.

No later owner may invent account, broker, spec, quote, or basic eligibility truth.

---

## Owned Layers

```text
Layer 1  Account / Portfolio / Prop Rule Truth
Layer 2  Market Open / Closed Truth
Layer 3  Symbol + Broker Specs Truth
Layer 4  Market Watch Truth
Layer 5  Basic System Gate
```

---

## Truth Authority

Owns:

```text
account snapshot
portfolio exposure snapshot
prop rule status input state
symbol universe list
market open / closed / unknown state
broker symbol specs
quote packet state
quote freshness
basic eligibility gate
blocked / degraded reasons for foundation truth
```

---

## Inputs

Allowed inputs:

```text
AccountInfo*
TerminalInfo*
SymbolsTotal
SymbolName
SymbolSelect
SymbolIsSynchronized
SymbolInfoInteger
SymbolInfoDouble
SymbolInfoString
SymbolInfoTick
SymbolInfoSessionQuote
SymbolInfoSessionTrade
SymbolInfoMarginRate
OrderCalcMargin
OrderCalcProfit
Calendar* later for news risk metadata
configured prop rule profile
```

---

## Outputs

Owned outputs:

```text
account_truth
portfolio_truth
symbol_universe_state
session_state
broker_spec_state
market_watch_state
basic_gate_state
foundation_degraded_reasons
foundation_block_reasons
```

---

## Consumers

Consumers:

```text
Surface Scoring Owner
Bucket Intelligence Owner
Basket Selection Owner
Selected Evidence Owner
Permission / Alert Owner
Publication Owner
Validation / Outcome Owner
```

---

## Forbidden Ownership

Must not own:

```text
surface score formulas
bucket taxonomy
Global Top 10
selected deep evidence
strategy setup logic
alert permission decisions
final publication routing
edge validation
```

---

## Lane Usage

Uses:

```text
Fast Lane       = heartbeat-critical account/quote freshness/risk flags
Standard Lane   = Layer 1–5 normal refresh
Recovery Lane   = missing specs, stale quote, sync retry, unavailable marking
Publication Lane = publish foundation state through Publication Owner only
```

Must not use:

```text
Deep Lane for all-symbol work
Validation Lane for permission upgrades
```

---

## Failure States

```text
account_unavailable
terminal_disconnected
symbol_universe_partial
session_unknown
spec_missing
quote_stale
quote_invalid
basic_gate_blocked
foundation_degraded
```

---

## Telemetry Fields

```text
account_snapshot_age_seconds
symbols_total
symbols_open
symbols_closed
symbols_unknown
specs_complete_count
specs_degraded_count
quotes_fresh_count
quotes_stale_count
basic_gate_eligible_count
basic_gate_blocked_count
foundation_owner_status
```

---

## Acceptance Criteria

```text
Layer 1–5 truth is published.
Missing data is labelled, not hidden.
One broad Basic System Gate exists.
No strategy logic appears in foundation truth.
No later owner recalculates foundation truth privately.
```

---

# Runtime Owner 2 — Surface Scoring Owner

## Purpose

Answer:

```text
Which symbols are cheap, active, moving, and positioned enough to inspect?
```

Surface Scoring creates descriptive broad rankings after the Foundation Truth Owner says symbols are eligible.

---

## Owned Layers

```text
Layer 6  Surface Cost / Friction Ranking
Layer 7  Session Relevance Ranking
Layer 8  Surface Movement / Range Ranking
Layer 9  Surface Structure / Location Geometry
```

---

## Truth Authority

Owns:

```text
surface cost score
friction score
session relevance score
surface movement score
surface structure/location score
surface score metadata
surface degraded reasons
```

Default score metadata:

```text
score_type = descriptive
directional_validity = false
expectancy_validated = false
trade_permission = false
```

---

## Inputs

Allowed inputs:

```text
foundation account context if needed
eligible symbol list
broker specs
quote packet
spread
surface ranges from cheap/current data
session state
safe high/low/open/close references where available
```

---

## Outputs

Owned outputs:

```text
surface_cost_rank
session_relevance_rank
surface_movement_rank
surface_structure_rank
combined_surface_score
surface_score_confidence
surface_score_degraded_reason
```

---

## Consumers

Consumers:

```text
Bucket Intelligence Owner
Basket Selection Owner
Publication Owner
Validation / Outcome Owner later
```

---

## Forbidden Ownership

Must not own:

```text
trade direction
setup confirmation
bucket classification
Global Top 10 final selection
raw OHLC packs
tick packs
indicator packs
liquidity maps
permission decisions
edge validation
```

---

## Lane Usage

Uses:

```text
Standard Lane = broad cheap scoring
Recovery Lane = stale/missing score repair
Publication Lane = displayed through Board/Dossier by Publication Owner
Validation Lane later = outcome evaluation of surface score usefulness
```

Must not use:

```text
Deep Lane for all-symbol score computation
Fast Lane for normal scoring
```

---

## Failure States

```text
surface_input_missing
surface_score_partial
surface_score_stale
surface_score_degraded
normalization_unavailable
sample_window_insufficient
```

---

## Telemetry Fields

```text
surface_symbols_scored
surface_symbols_degraded
surface_score_version
surface_score_age_seconds
surface_score_partial_count
surface_owner_status
```

---

## Acceptance Criteria

```text
Scores are labelled descriptive.
No buy/sell or setup language appears.
Score formulas are versioned or routed to formula registry.
Scores consume Foundation truth instead of recalculating it.
Scores can degrade without blocking publication.
```

---

# Runtime Owner 3 — Bucket Intelligence Owner

## Purpose

Answer:

```text
Where does each symbol belong?
Which buckets are strongest?
Which bucket leaders should enter the candidate pool?
```

Bucket Intelligence prevents AURORA CORE from becoming a random global ranking soup.

---

## Owned Layers

```text
Layer 10 Broker Bucket Classification
Layer 11 Symbol Ranking Inside Buckets
Layer 12 Bucket Heat / Bucket Quality Ranking
Layer 13 Dynamic Top Bucket Selection
Layer 14 Bucket Leader Candidate Pool
```

---

## Truth Authority

Owns:

```text
broker_group
broker_subgroup
aggregation_group
classification_source
classification_confidence
classification_cache_status
bucket_symbol_count
bucket_open_count
bucket_clean_count
bucket_degraded_count
bucket Top 5
sub-bucket Top 5
bucket heat
bucket strength
selected bucket list
candidate pool
```

---

## Inputs

Allowed inputs:

```text
symbol universe
foundation eligibility state
surface scores
broker symbol names
classification cache
manual review status later
```

---

## Outputs

Owned outputs:

```text
symbol_taxonomy
bucket_rankings
bucket_top5_lists
sub_bucket_top5_lists
bucket_heat_state
bucket_strength_state
selected_buckets
candidate_pool
bucket_degraded_reasons
```

---

## Consumers

Consumers:

```text
Basket Selection Owner
Selected Evidence Owner
Publication Owner
Validation / Outcome Owner later
```

---

## Forbidden Ownership

Must not own:

```text
correlation rejection final basket logic
Global Top 10 final output
selected OHLC/tick/indicator evidence
trade permission
strategy setup logic
foundation broker spec truth
```

---

## Lane Usage

Uses:

```text
Standard Lane = normal bucket rankings and candidate pool refresh
Slow Lane = taxonomy cache fill and classification review
Recovery Lane = unknown/partial classification repair
Publication Lane = Board/Dossier/Selection Desk display through Publication Owner
```

---

## Failure States

```text
classification_unknown
classification_partial
classification_cache_stale
bucket_empty
bucket_degraded
candidate_pool_partial
selected_bucket_fallback_active
```

---

## Telemetry Fields

```text
symbols_classified_count
symbols_unknown_count
classification_cache_age_seconds
bucket_count
selected_bucket_count
bucket_top5_count
candidate_pool_size
bucket_owner_status
```

---

## Acceptance Criteria

```text
Every eligible symbol has a bucket state or honest unknown state.
Unknowns are tracked and reduced over time.
Bucket Top 5 remains visible even if correlation rejects symbols from Global Top 10.
Candidate pool is built from bucket leaders, not random all-symbol soup.
No trade permission appears in bucket logic.
```

---

# Runtime Owner 4 — Basket Selection Owner

## Purpose

Answer:

```text
Which candidates form the best diversified inspection basket?
```

Basket Selection converts candidate pool into correlation-aware Global Top 10.

---

## Owned Layers

```text
Layer 15 Correlation / Diversity Selection
Layer 16 Global Top 10 Builder
```

---

## Truth Authority

Owns:

```text
correlation metrics for candidate pool
currency overlap score
bucket overlap score
diversity score
correlation rejects
backup fill logic
Global Top 10
Global Top 10 reasons
basket degraded reasons
```

---

## Inputs

Allowed inputs:

```text
candidate pool from Bucket Intelligence Owner
surface score metadata
bucket score metadata
cheap correlation inputs
symbol relationship inputs
manual pins later if defined
```

---

## Outputs

Owned outputs:

```text
global_top10
global_top10_rank
global_top10_reason
correlation_rejects
backup_fill_used
backup_fill_reason
basket_diversity_state
```

---

## Consumers

Consumers:

```text
Selected Evidence Owner
Publication Owner
Validation / Outcome Owner later
```

---

## Forbidden Ownership

Must not own:

```text
bucket Top 5 authority
symbol taxonomy
selected OHLC/tick/indicator evidence
trade direction
permission state
edge validation
```

---

## Lane Usage

Uses:

```text
Standard Lane = basket refresh
Slow Lane = less frequent correlation support where needed
Recovery Lane = degraded/insufficient correlation repair
Publication Lane = display through Board/Selection Desk by Publication Owner
Validation Lane later = outcome tests of basket utility
```

Must not use:

```text
Deep Lane for all-candidate expensive evidence
```

---

## Failure States

```text
candidate_pool_missing
candidate_pool_partial
correlation_input_insufficient
basket_partial
backup_fill_active
correlation_confidence_low
```

---

## Telemetry Fields

```text
candidate_pool_size
global_top10_count
correlation_reject_count
backup_fill_count
basket_refresh_age_seconds
basket_diversity_score
basket_owner_status
```

---

## Acceptance Criteria

```text
Global Top 10 is built from candidate pool.
Global Top 10 is labelled as inspection basket, not trade list.
Correlation rejects remain visible, not erased.
Backup fill is labelled.
No trade permission appears in basket selection.
```

---

# Runtime Owner 5 — Selected Evidence Owner

## Purpose

Answer:

```text
Which selected symbols deserve expensive evidence?
What deeper evidence exists for those symbols?
Is that evidence complete, partial, stale, degraded, or unavailable?
```

Selected Evidence collects expensive data only after selection.

---

## Owned Layers

```text
Layer 17 Deep Evidence Selection Split
Layer 18 Selected Raw OHLC Bar Pack
Layer 19 Selected Wick / Candle Geometry Pack
Layer 20 Selected Rolling Tick Pack
Layer 21 Selected Indicator / Reference Pack
Layer 22 Deep Market Evidence / Liquidity / MT5 Order-Flow Proxy Pack
```

---

## Truth Authority

Owns:

```text
deep selected set
visible-only set
alert candidate set later
selected OHLC evidence
selected wick evidence
selected tick evidence
selected indicator/reference evidence
selected VWAP context
selected liquidity map
MT5 tick-flow proxy
MT5 DOM proxy availability and evidence
selected evidence completeness
```

---

## Inputs

Allowed inputs:

```text
Global Top 10
selected bucket leaders
backup candidates
manual watch symbols later
foundation quote/spec truth
MT5 CopyRates / MqlRates
MT5 CopyTicks / CopyTicksRange
MT5 indicator handles / CopyBuffer
MT5 MarketBook* if available
```

---

## Outputs

Owned outputs:

```text
deep_selection_state
OHLC_pack_state
wick_pack_state
tick_pack_state
indicator_pack_state
VWAP_context_state
liquidity_context_state
order_flow_proxy_state
evidence_integrity_state
selected_evidence_degraded_reasons
```

---

## Consumers

Consumers:

```text
Permission / Alert Owner
Publication Owner
Validation / Outcome Owner later
```

---

## Forbidden Ownership

Must not own:

```text
all-symbol deep evidence
Global Top 10 final selection
bucket ranking
trade permission
setup validation
true institutional order-flow claims
```

---

## Lane Usage

Uses:

```text
Deep Lane = selected evidence collection
Recovery Lane = missing/stale/degraded selected evidence repair
Publication Lane = display through Board/Dossier/Governance by Publication Owner
Validation Lane later = evidence usefulness tests
```

Must not use:

```text
Standard Lane for expensive evidence across all symbols
Fast Lane for deep evidence
```

---

## Failure States

```text
deep_selection_empty
OHLC_pending
OHLC_partial
wick_waiting_on_OHLC
tick_window_recording
tick_window_insufficient
indicator_not_ready
VWAP_unavailable
DOM_unavailable
order_flow_proxy_unavailable
evidence_integrity_partial
evidence_degraded
```

---

## Telemetry Fields

```text
deep_active_set_count
deep_pending_count
deep_completed_count
deep_degraded_count
deep_batch_id
deep_batch_progress_pct
OHLC_complete_count
wick_complete_count
tick_window_progress_pct
indicator_complete_count
DOM_available_count
selected_evidence_owner_status
```

---

## Acceptance Criteria

```text
Deep evidence only runs for selected symbols.
Evidence dependency waits are labelled.
MT5 DOM is labelled proxy-only.
No true order-flow claim appears.
Evidence completeness is published.
Deep evidence does not grant permission by itself.
```

---

# Runtime Owner 6 — Permission / Alert Owner

## Purpose

Answer:

```text
What is allowed?
What is blocked?
What alert class is permitted?
What requires proof first?
```

Permission / Alert Owner is the safety gate for alerts, review, strategy candidates, and future execution permission.

---

## Owned Layer

```text
Layer 23 Setup / Strategy / Permission / Alert State
```

---

## Truth Authority

Owns:

```text
class_1_system_alert_allowed
class_2_setup_alert_allowed
directional_alert_allowed
auto_trade_allowed
live_allowed
review_allowed
permission_block_reasons
alert_suppression_reasons
cooldown state
prop/news/risk permission state
```

Default state:

```text
class_1_system_alert_allowed = true
class_2_setup_alert_allowed = false
directional_alert_allowed = false
auto_trade_allowed = false
live_allowed = false
setup_edge_status = unproven
```

---

## Inputs

Allowed inputs:

```text
foundation risk/account state
selected evidence integrity
publication health
validation/outcome status later
prop rule profile
news risk metadata
manual operator flags later
```

---

## Outputs

Owned outputs:

```text
permission_state
alert_state
alert_cooldown_state
alert_suppression_reasons
review_block_reasons
trading_block_reasons
permission_degraded_reasons
```

---

## Consumers

Consumers:

```text
Publication Owner
Validation / Outcome Owner
future execution system only after proof
```

---

## Forbidden Ownership

Must not own:

```text
raw evidence computation
bucket ranking
Global Top 10 construction
formula validation results
outcome proof generation
file route ownership
```

---

## Lane Usage

Uses:

```text
Fast Lane = critical permission/risk flags
Standard Lane = normal permission state refresh
Recovery Lane = permission state repair when dependencies stale
Publication Lane = display through Board/Dossier/Governance by Publication Owner
Validation Lane = consumes validation outcome, does not create it
```

---

## Failure States

```text
permission_dependency_missing
risk_state_unknown
prop_rule_unknown
news_state_unknown
alert_suppressed
cooldown_active
review_blocked
trading_blocked
permission_degraded
```

---

## Telemetry Fields

```text
class_1_alerts_allowed
class_1_alerts_suppressed
class_2_alerts_allowed
class_2_alerts_blocked
directional_alert_allowed
auto_trade_allowed
live_allowed
permission_block_count
permission_owner_status
```

---

## Acceptance Criteria

```text
Class 1 alerts can exist for system/risk/integrity only.
Class 2 setup alerts remain blocked until validation.
Directional alerts remain false until proof.
Auto-trading remains blocked.
Permission state is visible and reasoned.
No owner bypasses Permission / Alert Owner.
```

---

# Runtime Owner 7 — Publication Owner

## Purpose

Answer:

```text
What must print?
Where does it print?
What is degraded?
What is missing?
What was written successfully?
```

Publication Owner is the output authority.

It prints truth.

It does not create hidden trading truth.

---

## Owned Surfaces

```text
Board
Dossier
Selection Desk
Governance Files
Manifest
Atomic Write Pipeline
Atomic Update Overview
```

---

## Truth Authority

Owns:

```text
publication route contracts
file write status
manifest state
Board publication state
Dossier publication state
Selection Desk publication state
Governance publication state
Atomic Update Overview publication state
physical publication failure state
```

---

## Inputs

Allowed inputs:

```text
all owner output states
runtime telemetry
file route configuration
atomic write owner / FileIO owner later
```

---

## Outputs

Owned outputs:

```text
Board files
Dossier files
Selection Desk files
Governance files
Manifest files
publication status
file write proof
publication degraded reasons
```

---

## Consumers

Consumers:

```text
operator
future workers
governance review
Validation / Outcome Owner later
```

---

## Forbidden Ownership

Must not own:

```text
rank recomputation
formula recomputation
permission decision creation
edge validation
bucket classification
selected evidence computation
```

Publication displays and records owner truth.

It does not secretly compute owner truth.

---

## Lane Usage

Uses:

```text
Publication Lane = normal writes
Fast Lane = publication heartbeat / critical write failure visibility
Recovery Lane = temp-file cleanup, failed write retry, stale publication repair
```

Must not use:

```text
Deep Lane for output generation
Validation Lane for permission upgrades
```

---

## Failure States

```text
route_missing
write_failed
temp_write_failed
move_failed
verify_failed
manifest_missing
publication_stale
publication_partial
publication_degraded
```

---

## Telemetry Fields

```text
last_board_write_time
last_dossier_write_time
last_selection_desk_write_time
last_governance_write_time
manifest_write_status
file_write_fail_count
publication_age_seconds
publication_owner_status
```

---

## Acceptance Criteria

```text
Broken truth does not block file printing.
Physical FileIO/route failure is the only valid physical publication blocker.
Board shows system-level truth.
Dossier shows symbol-level truth.
Selection Desk shows selection truth without recomputation.
Governance files expose proof and ledgers.
Publication Owner never becomes a hidden calculator.
```

---

# Runtime Owner 8 — Validation / Outcome Owner

## Purpose

Answer:

```text
Did any score, setup, ranking, or evidence concept actually matter after costs and risk?
```

Validation / Outcome Owner separates architecture from edge.

---

## Owned Validation Areas

```text
Outcome Ledger
Experiment Registry
Setup Validation
Score Validation
Null Model Comparison
Strategy Tester Harness Later
Walk-Forward Proof Later
Forward Demo Proof Later
```

---

## Truth Authority

Owns:

```text
outcome records
experiment definitions
null model comparisons
score usefulness tests
setup validation status
cost-adjusted expectancy state
slippage-adjusted expectancy state
walk-forward status later
forward demo evidence status later
edge classification state
```

---

## Inputs

Allowed inputs:

```text
historical owner outputs
selection ledger
score registry
formula registry
selected evidence snapshots
permission state snapshots
market outcome data
cost/slippage assumptions
strategy tester outputs later
forward demo records later
```

---

## Outputs

Owned outputs:

```text
outcome_ledger
experiment_registry
validation_report_state
score_validation_state
setup_validation_state
null_model_result
edge_status
kill_conditions_triggered
```

---

## Consumers

Consumers:

```text
Permission / Alert Owner
Publication Owner
future strategy research
future build roadmap
```

---

## Forbidden Ownership

Must not own:

```text
live permission by itself
auto-trading approval by itself
runtime ranking source truth
publication route ownership
foundation truth
bucket taxonomy
selected evidence computation
```

Validation measures.

Permission decides using validation and risk state.

---

## Lane Usage

Uses:

```text
Validation Lane = experiment/outcome work
Slow Lane = non-critical validation summaries where needed
Publication Lane = reports displayed through Publication Owner
```

Must not use:

```text
Fast Lane for research work
Deep Lane unless consuming stored selected evidence
```

---

## Failure States

```text
outcome_data_missing
sample_count_insufficient
cost_model_missing
slippage_model_missing
null_model_missing
validation_incomplete
edge_unproven
edge_failed
```

---

## Telemetry Fields

```text
experiments_active_count
outcome_records_count
sample_count_by_setup
null_model_completed_count
validation_pass_count
validation_fail_count
edge_status
validation_owner_status
```

---

## Acceptance Criteria

```text
No edge claim exists without outcome evidence.
Validation distinguishes calculation correctness from trading usefulness.
Null model comparison is required before promotion.
Costs and slippage must be included before strategy confidence.
Validation may recommend permission upgrade but does not bypass Permission Owner.
```

---

## 12. Cross-Owner Interface Rules

Every cross-owner exchange must define:

```text
producer owner
consumer owner
fields passed
field version
freshness state
degraded state
missing behavior
forbidden reverse ownership
```

Example:

```text
Producer: Bucket Intelligence Owner
Consumer: Basket Selection Owner
Payload: candidate_pool
Forbidden: Basket Selection Owner may not recalculate bucket classification.
```

Example:

```text
Producer: Basket Selection Owner
Consumer: Selected Evidence Owner
Payload: global_top10 + selected backups
Forbidden: Selected Evidence Owner may not decide Global Top 10.
```

Example:

```text
Producer: Selected Evidence Owner
Consumer: Permission / Alert Owner
Payload: evidence_integrity_state
Forbidden: Permission Owner may not compute OHLC/tick/indicator evidence.
```

---

## 13. Owner Contradiction Rules

If two owners claim the same truth, create a contradiction entry.

Contradiction ledger fields:

```text
claim_a
claim_b
owner_a
owner_b
source_a
source_b
evidence_rank_a
evidence_rank_b
which_owner_should_own_truth
resolution_test
pause_required
```

Default decision:

```text
If ownership conflict affects publication, permission, source truth, ranking, or evidence integrity: HOLD until resolved.
```

---

## 14. Owner Telemetry Summary

Each owner must expose:

```text
owner_status
last_success_at
last_attempt_at
freshness_state
degraded_count
blocked_count
pending_count
failed_count
starved_task_count
oldest_starved_task_age_seconds
last_publication_state
```

Owner status values:

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

These should align with Atomic Update Overview status language.

---


## 14A. External Worker Boundary (Design-Stage)

```text
External Worker is not a Runtime Owner yet.
It is a future bridge/calculation component governed by the future External Worker & Calculation Bridge Guidebook.
```

It may provide calculation outputs to existing Runtime Owners through validated snapshot contracts.

MT5 remains owner of broker truth, publication, permission authority, and final source-of-truth validation.

Publication Owner remains final output writer.
Permission / Alert Owner remains permission authority.
Foundation Truth Owner remains broker/account/source truth authority.

```text
External worker may calculate.
External worker may not become broker truth, publication owner, or permission owner.
```

Snapshot bridge minimum validation by MT5 before consuming worker output:

```text
request_id
cycle_id
schema_version
input_hash_seen
freshness
worker heartbeat
```

Decision state:

```text
External calculation worker: PROCEED TO GUIDEBOOK DESIGN
Python worker + file snapshot bridge: BEST FIRST CANDIDATE
WebRequest bridge: HOLD for main runtime bridge
C/C++ worker: HOLD as later optimization
Sockets bridge: CONSIDER later
MT5-only heavy calculations: HOLD as fallback
```

## 15. No-Go Patterns

Do not allow:

```text
23 runtime engines
shadow FileIO owner
Board recomputing selection
Dossier recomputing scores
Selection Desk recomputing ranks
Permission hidden inside score formulas
Validation granting live permission alone
indicator helper creating signals
external API becoming source truth without owner contract
owner output with no freshness state
owner failure hidden from Board
```

---

## 16. Open Questions

These remain open for later detailed guidebooks or implementation:

```text
final owner output schemas
exact owner file names
exact MT5 include/module layout
exact owner cadence numbers
exact owner telemetry CSV fields
exact governance schema files
exact Board/Dossier section rendering
```

Do not invent false precision before implementation design.

---

## 17. Acceptance Criteria for This Guidebook

This guidebook is acceptable if it prevents Runtime Owners from becoming vague labels.

Acceptance criteria:

```text
Defines all 8 Runtime Owners.
Maps layers to owners.
Defines each owner's authority.
Defines each owner's forbidden ownership.
Defines consumers and outputs.
Defines lane usage.
Defines failure states.
Defines telemetry expectations.
Defines cross-owner interface rules.
Defines contradiction handling.
Blocks shadow owners.
Does not create trade permission.
Does not claim edge.
```

---

## 18. Final Runtime Owner Law

```text
Runtime Owners hold authority.
Layers explain truth.
Lanes schedule work.
Publication displays state.
Validation earns confidence.
Permission blocks danger.
No owner may secretly become another owner.
```

AURORA CORE survives by clear ownership.
