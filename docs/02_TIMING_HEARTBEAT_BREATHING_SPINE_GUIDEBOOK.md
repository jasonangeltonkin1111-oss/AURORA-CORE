# AURORA CORE — TIMING, HEARTBEAT & BREATHING SPINE GUIDEBOOK

**System:** AURORA CORE  
**Role:** Runtime pulse, scheduler survival model, event discipline, lane model, and fake-alive prevention guidebook.  
**Status:** Overview guidebook foundation. Details may be refined when source implementation begins.

---

## 0. Purpose

This guidebook defines how AURORA CORE stays alive under real MetaTrader 5 runtime constraints.

It is not a poetic heartbeat document.

It is the runtime survival book.

AURORA CORE does not fail only when it stops printing. AURORA CORE also fails when it keeps printing while important lanes silently starve.

The scheduler must optimize for truthful progress, not maximum work attempted.

This book exists to prevent:

```text
unbounded OnTimer work
silent Timer event loss
slow-lane starvation
deep-lane starvation
fake-alive runtime
retry storms
queue bloat
selection churn thrash
publication delay caused by deep work
false complete states
```

---

## 1. What This Guidebook Owns

This guidebook owns:

```text
heartbeat model
breathing spine model
nervous system model
runtime lane model
scheduler pressure rules
startup hydration rhythm
cadence families
task identity and coalescing
lane bulkheads
admission control
backpressure visibility
starvation detection
aging priority and fairness
over-budget detection
load shedding rules
retry and backoff policy
deterministic jitter policy
circuit breaker rules
deep evidence active set rules
selection churn control
publication-first scheduler order
atomic update overview timing
runtime telemetry fields
fake-alive failure detection
task outcome taxonomy
```

---

## 2. What This Guidebook Must Not Own

This guidebook must not own:

```text
final formulas
bucket taxonomy
Global Top 10 scoring formulas
indicator parameters
strategy validation
trade permission
Board layout details
Dossier layout details
FileIO implementation details
final cadence constants
```

It may define timing contracts and telemetry fields.

It must not become a hidden master owner for strategy, ranking, publication, or source implementation.

---

## 3. Official MT5 Event Constraints

Official MQL5 documentation creates the core runtime constraint.

### OnTimer constraint

The `OnTimer()` handler is called when the terminal generates Timer events for the EA.

Important MT5 constraints:

```text
Only one timer can be launched for each MQL5 program.
Each MQL5 application and chart has its own event queue.
If the queue already contains a Timer event, or the Timer event is being processed, the new Timer event is not added to the queue.
```

Official source:

```text
https://www.mql5.com/en/docs/event_handlers/ontimer
```

Aurora implication:

```text
OnTimer is not an infinite catch-up mechanism.
If OnTimer work runs too long, cadence is silently lost.
```

### OnTick constraint

The `OnTick()` handler is called when a NewTick event occurs for the chart symbol.

Important MT5 constraints:

```text
Events are handled one after another in order of receipt.
If the queue already contains a NewTick event, or the NewTick event is being processed, a new NewTick event is not added to the queue.
```

Official source:

```text
https://www.mql5.com/en/docs/event_handlers/ontick
```

Aurora implication:

```text
OnTick is not a complete tick recorder.
OnTick can be a lightweight trigger, but not the source of full tick truth.
```

---

## 4. Senior Runtime Design Principles

AURORA CORE must use mature runtime concepts adapted to MT5:

```text
Heartbeat       = pulse
Breathing Spine = rhythm
Nervous System  = event sensing
Runtime Lanes   = traffic control
Bulkheads       = lane isolation
Backpressure    = visible queue pressure
Admission Control = limit what enters a lane
Coalescing      = merge duplicate pending work
Load Shedding   = defer/drop low-value work under pressure
Retry Budgets   = prevent retry storms
Deterministic Jitter = spread periodic work without randomness chaos
Circuit Breakers = stop repeating poison tasks
Recovery Lane   = repair degraded truth
Publication Lane = always print state
```

These are not decorative patterns.

Each one prevents a known Aurora failure mode.

---

## 5. Heartbeat Definition

The heartbeat is the repeating runtime pulse.

It answers:

```text
Is Aurora alive?
What is due now?
What is safe to run now?
What must be deferred?
What is over budget?
What is starved?
What must still print even if incomplete?
```

The heartbeat does not mean:

```text
run all due work now
run every layer now
complete every symbol now
block publication until perfect
```

Correct heartbeat pattern:

```text
sense
update due map
select bounded work slice
execute slice
publish heartbeat / atomic update state if due or changed
log task outcome
exit cleanly
```

---


## 5A. Completed-Run Steady-State Refresh

```text
After a full successful run reaches runtime_normal / run_complete, AURORA CORE enters steady-state refresh mode.
run_complete ≠ system asleep.
```

## 5B. 30-Minute Full Refresh Cadence

```text
Completed-run full refresh = every 30 minutes.
Do not lock every lane sub-cadence here yet.
Lock only the high-level full-system refresh cadence and liveness law.
```

## 5C. Between-Refresh Liveness

Between full refreshes, the runtime must keep truth visible:

```text
heartbeat remains alive
Board still prints health
critical account/risk/terminal/file-write states still update
stale/degraded states remain visible
Recovery Lane may continue bounded retry work
Heartbeat / publication / critical risk checks continue between refreshes
```

## 5D. External Worker Health Monitoring (If Enabled)

```text
If external_worker_enabled = true, monitor worker heartbeat and output freshness between 30-minute full refresh cycles.
Worker health monitoring remains MT5-owned.
Worker calculation outputs remain optional unless a downstream owner marks them required.
```

Bridge guidance status:

```text
External calculation worker: PROCEED TO GUIDEBOOK DESIGN
Python worker + file snapshot bridge: BEST FIRST CANDIDATE
WebRequest bridge for main runtime bridge: HOLD
C/C++ worker: HOLD
Sockets bridge: CONSIDER
```

References:
- https://www.mql5.com/en/docs/event_handlers/ontimer
- https://www.mql5.com/en/docs/network/webrequest
- https://www.mql5.com/en/docs/python_metatrader5

## 6. Breathing Spine Model

AURORA CORE uses a breathing model for runtime rhythm.

```text
inhale  = sense / refresh / collect
hold    = rank / compare / decide
exhale  = publish / log / expose truth
recover = retry / fill / degrade / clear pressure
```

This model exists to prevent frantic loop design.

The breath phase should be visible as a runtime state:

```text
breath_phase = inhale | hold | exhale | recover
```

The Board should be able to show the current breath phase.

---

## 7. Nervous System Model

The nervous system is the event network.

```text
OnInit
OnTimer
OnDeinit
OnTick light trigger if used
OnBookEvent later
OnTradeTransaction later
manual operator flags
runtime pressure warnings
publication failures
stale-data warnings
```

Core rule:

```text
Events sense and route.
Events do not carry heavy work.
```

Allowed event behavior:

```text
mark due work
update tiny flags
capture minimal facts
request bounded scheduler slice
publish critical state if required
exit quickly
```

Forbidden event behavior:

```text
all-symbol deep scans
long classification loops
full OHLC loading
indicator handle spam
DOM collection for many symbols
complex correlation matrix building
unbounded file writing
```

---

## 8. Runtime Lane Model

AURORA CORE uses runtime lanes as traffic control.

Lanes:

```text
Fast Lane
Standard Lane
Slow Lane
Deep Lane
Publication Lane
Recovery Lane
Validation Lane
```

Each lane must define:

```text
purpose
allowed work
forbidden work
cadence family
budget contract
admission limits
starvation threshold
degradation behavior
telemetry fields
```

No lane may exist as a name only.

---

## 9. Lane Bulkhead Rules

Lanes are bulkheads.

A lane bulkhead isolates work so overload in one area does not cascade into all other areas.

AURORA CORE lane isolation rules:

```text
Fast Lane must not be drowned by Deep Lane.
Publication Lane must not wait for perfect truth.
Slow Lane must not starve forever behind cheap recurring work.
Recovery Lane must not become infinite retry poison.
Validation Lane must not block runtime publication.
Deep Lane must not accept all-symbol work.
```

Bulkheads may reduce theoretical maximum throughput, but they protect survival.

Aurora favors truthful progress over blind throughput.

---

## 10. Fast Lane

Purpose:

```text
Keep Aurora visibly alive and risk-aware.
```

Allowed work:

```text
heartbeat timestamp
runtime pressure state
terminal/account quick status
critical risk flags
publication age check
quote freshness summary
emergency file-write failure flag
manual emergency flag check
```

Forbidden work:

```text
classification work
full symbol loops
OHLC requests
tick windows
indicator handles
DOM work
correlation
deep evidence
```

Senior rule:

```text
Fast Lane must be boring, tiny, and reliable.
```

If Fast Lane becomes the “important work lane,” Aurora dies.

---

## 11. Standard Lane

Purpose:

```text
Run normal cheap broad truth and ranking.
```

Allowed work:

```text
Layer 1–5 refresh
surface scores
bucket summaries
candidate pool status
Global Top 10 refresh when due
```

Forbidden work:

```text
all-symbol OHLC
all-symbol tick capture
all-symbol indicators
DOM
deep evidence
```

Senior rule:

```text
Standard Lane may be broad, but only with cheap data.
```

---

## 12. Slow Lane

Purpose:

```text
Advance heavier background system completeness without blocking live truth.
```

Allowed work:

```text
taxonomy cache fill
classification review queue
registry consistency checks
folder/output reconciliation
schema example validation
stale unknown cleanup
```

Danger:

```text
Slow Lane is where work goes to die if starvation is not measured.
```

Senior rule:

```text
Slow Lane must receive guaranteed slices when starved.
```

---

## 13. Deep Lane

Purpose:

```text
Collect expensive evidence for selected symbols only.
```

Allowed work:

```text
selected OHLC
selected wick geometry
selected rolling tick pack
selected indicators
selected VWAP context
selected liquidity map
selected DOM proxy if available
```

Forbidden work:

```text
all-symbol deep evidence
unbounded history loading
DOM for every symbol
indicator handle spam
```

Senior rule:

```text
Deep Lane is selection-fed, not universe-fed.
```

---

## 14. Publication Lane

Purpose:

```text
Print truth and degradation.
```

Allowed work:

```text
Board
Atomic Update Overview
Dossier
Selection Desk
Governance files
Manifest
```

Forbidden work:

```text
waiting for perfect truth
deep computation
formula recalculation
hidden gating
```

Senior rule:

```text
Publication Lane outranks cleanliness.
```

If data is broken, publish the broken state.

---

## 15. Recovery Lane

Purpose:

```text
Repair, retry, degrade, and clear rot.
```

Allowed work:

```text
retry missing quote/spec/history
repair partial cache
mark unavailable sources
cleanup temp files
recover stale states
force starved tasks into slices
```

Forbidden work:

```text
infinite retries
retry storms
retrying unavailable features as critical
hiding failure by resetting counters
```

Senior rule:

```text
Recovery Lane must have retry budgets.
```

---

## 16. Validation Lane

Purpose:

```text
Test whether observations matter.
```

Allowed work:

```text
outcome ledger
experiment registry
null model comparison
Strategy Tester harness later
walk-forward later
```

Forbidden work:

```text
granting live permission
blocking publication
rewriting runtime ranking without evidence
```

Senior rule:

```text
Validation Lane measures edge; it does not create permission by opinion.
```

---

## 17. Task Identity and Coalescing

Duplicate queued work is a hidden runtime killer.

Bad pattern:

```text
quote refresh due
quote refresh due again
quote refresh due again
queue now contains many duplicate quote refresh tasks
```

Good pattern:

```text
quote refresh due = true
same task already pending
merge due reason / urgency
no duplicate task added
```

Canonical task key:

```text
task_key = owner + lane + layer + symbol_or_scope + task_type
```

If the same `task_key` is already pending:

```text
merge the task
update latest due reason
increase urgency if needed
preserve original due_since
avoid duplicate execution
```

Task coalescing result:

```text
cancelled_coalesced
```

---

## 18. Deadline Classes

Every task needs a deadline class.

```text
Class A — heartbeat critical
Class B — operator freshness
Class C — normal ranking
Class D — slow completeness
Class E — selected deep evidence
Class F — recovery / retry
Class G — validation / research
```

Examples:

```text
Class A: publication heartbeat, runtime alive, file write failure
Class B: account risk, quote freshness, Board update
Class C: surface ranking, bucket heat, Global Top 10
Class D: taxonomy enrichment, schema reconciliation
Class E: OHLC/tick/indicator for selected symbols
Class F: retry stale/missing/degraded work
Class G: outcome ledger / validation tests
```

Deadline class is not the same as priority.

Deadline class describes operational urgency.

Priority selects between due work.

---

## 19. Freshness Contracts

Each lane/output needs a freshness contract.

Fields:

```text
freshness_target
freshness_warn_after
freshness_stale_after
freshness_failed_after
last_success_at
last_attempt_at
age_seconds
freshness_state
```

Freshness states:

```text
fresh
aging
stale
expired
unavailable
unknown
```

Rule:

```text
A stale output may still print.
It must print as stale.
```

---

## 20. Budget Contracts

Every lane needs budget fields before final numeric tuning.

```text
target_slice_ms
max_slice_ms
target_symbols_per_slice
max_symbols_per_slice
max_pending_tasks
starvation_warn_after
starvation_force_after
```

Do not lock exact milliseconds too early.

Exact budgets must be tuned from runtime evidence.

False precision is a source of drift.

---

## 21. Startup Hydration Model

Startup is dangerous because everything is empty.

Bad startup pattern:

```text
wait until everything is complete before printing
```

Correct startup pattern:

```text
print shell
hydrate truth
publish partial status
fill missing data
upgrade statuses as data arrives
```

Startup states:

```text
booting
shell_printing
shell_printed
hydrating_foundation
hydrating_surface
hydrating_buckets
selection_ready
deep_evidence_filling
runtime_normal
```

Publication rule:

```text
Startup incompleteness may block review/trading.
Startup incompleteness must not block truthful shell publication.
```

---

## 22. Cadence Families

Cadence families are locked before exact cadence numbers.

### Immediate / heartbeat-level

```text
runtime alive state
timer duration
over-budget flag
publication heartbeat
critical risk state
```

### Frequent

```text
quote freshness
account/risk snapshot
Layer 1–5 summary
Board update
```

### Standard

```text
surface ranking
bucket rankings
candidate pool
Global Top 10
```

### Slow

```text
taxonomy cache fill
classification review
registry consistency
folder/output reconciliation
```

### Deep selected

```text
OHLC
wick
tick window
indicator pack
liquidity context
DOM proxy
```

### Validation

```text
outcome ledger updates
experiment review
null model comparison
```

Rule:

```text
Cadence families are architecture.
Exact seconds/minutes are implementation tuning.
```

---

## 23. Scheduler State Machine

Heartbeat runtime state:

```text
booting
shell_printing
hydrating
normal
under_pressure
degraded
recovery
critical
shutdown
```

Breath phase:

```text
inhale
hold
exhale
recover
```

Lane state:

```text
idle
due
running
deferred
starved
backing_off
blocked_by_dependency
degraded
complete
```

These states should be visible to Board / Atomic Update Overview.

---

## 24. Admission Control

Aurora must not accept infinite work into a lane.

Lane limits:

```text
max_pending_tasks
max_symbols_per_cycle
max_ms_per_slice
max_retries_per_cycle
max_deep_symbols_active
```

If a lane is full:

```text
new low-priority work is deferred
duplicate work is merged
stale tasks are coalesced
critical tasks are allowed through
```

Admission control prevents queue bloat.

---

## 25. Backpressure and Queue Pressure

Backpressure means Aurora sees backlog pressure and changes behavior.

Telemetry fields:

```text
lane_queue_depth
due_task_count
deferred_task_count
oldest_due_age_seconds
starved_task_count
lane_pressure_state
forced_slice_due
load_shed_count
```

Pressure states:

```text
normal
warm
over_budget
starved
degraded
critical
```

Senior rule:

```text
A task being overdue is not enough.
A task being overdue and aging across heartbeats is pressure.
```

---

## 26. Starvation Detection

A task is starved when:

```text
it is due,
it remains due across multiple heartbeats,
and higher-priority lanes keep preventing it from running.
```

Starvation fields:

```text
task_id
owner
lane
due_since
heartbeats_waiting
last_executed_at
starvation_reason
forced_slice_due
```

Rule:

```text
No lane may starve silently.
```

If Deep Lane is far behind, Board must show it.

If Slow Lane never receives slices, Board must show it.

---

## 27. Aging Priority and Fairness

Priority must not be static.

Suggested priority model:

```text
effective_priority =
base_priority
+ age_boost
+ starvation_boost
+ dependency_boost
+ operator_visibility_boost
- retry_backoff_penalty
- optional_work_penalty
```

Fairness rule:

```text
Every heartbeat must reserve a minimum chance for starved lanes unless a critical Fast Lane failure exists.
```

Possible policy:

```text
If oldest_starved_task_age > threshold:
    force one bounded slice from the starved lane before optional Standard Lane work
```

This prevents Slow Lane and Deep Lane from never finishing.

---

## 28. Over-Budget Detection

Every heartbeat must know:

```text
expected budget
actual duration
overage
owner responsible
lane responsible
tasks executed
tasks deferred
```

Rule:

```text
Over-budget is not automatically failure.
Silent over-budget is failure.
```

Heavy work can be acceptable if it is bounded, labelled, and visible.

---

## 29. Load Shedding Rules

Under pressure, Aurora may intentionally defer low-value work.

Allowed shedding examples:

```text
skip optional heatmap refresh
delay slow taxonomy enrichment
defer non-critical registry checks
reduce deep evidence batch size
publish Board summary without full secondary sections
delay DOM retry
```

Forbidden shedding:

```text
do not drop publication heartbeat
do not hide file write failure
do not hide prop/risk danger
do not hide stale/degraded status
do not fake complete state
```

Required fields:

```text
load_shed_reason
load_shed_task_count
load_shed_lane
next_retry_after
```

Rule:

```text
Load shedding is allowed only if the shed work is logged.
```

---

## 30. Retry, Backoff, and Deterministic Jitter

Retries are dangerous medicine.

Retries can amplify overload if every layer retries independently or every failed task retries at the same time.

Reference:

```text
AWS Builders Library — Timeouts, retries, and backoff with jitter
https://aws.amazon.com/builders-library/timeouts-retries-and-backoff-with-jitter/
```

Aurora retry laws:

```text
Do not retry every missing field every heartbeat.
Do not retry all failed symbols at the same time.
Do not let retries compete equally with fresh truth.
Do not retry unavailable DOM like it is critical quote truth.
```

Failure-specific retry classes:

```text
quote_missing           = short retry
symbol_spec_missing     = medium retry
classification_unknown  = slow fill/review
DOM_unavailable         = mark unavailable, slow retry
file_write_failure      = immediate critical retry
indicator_not_ready     = selected-symbol retry with cap
history_sync_pending    = slow/deep retry with visibility
```

Retry states:

```text
not_attempted
attempted
retry_scheduled
retrying
partial
complete
failed_soft
failed_hard
degraded_until_next_cycle
```

Deterministic jitter:

```text
jitter_seed = hash(server + account + symbol + task_type)
jitter_offset_seconds = jitter_seed % max_jitter_seconds
```

Do not jitter:

```text
critical risk flags
file write failure checks
manual emergency flags
heartbeat alive state
```

Can jitter:

```text
taxonomy fills
registry checks
symbol evidence refresh
DOM retries
heatmap refresh
folder reconciliation
```

---

## 31. Circuit Breaker Rules

Some tasks repeatedly fail and waste runtime.

Examples:

```text
DOM not available for broker/symbol
history sync repeatedly failing
symbol spec unavailable
file path write failure
indicator handle invalid
```

Circuit breaker states:

```text
closed    = normal
open      = blocked temporarily
half_open = test one retry
disabled  = unavailable until major refresh/manual reset
```

Rule:

```text
Circuit breakers may stop repeated waste.
They may not hide failure.
They must publish state.
```

Circuit breakers must be visible in Board / Atomic Update Overview / governance where relevant.

---

## 32. Dependency Gates Without Publication Gates

Some work requires dependencies.

Examples:

```text
wick geometry requires OHLC
indicator pack requires selected bars/history
DOM proxy requires MarketBook subscription availability
Global Top 10 requires candidate pool
```

Correct behavior:

```text
Layer 19 status = waiting_on_layer_18
Dossier prints status
Board prints partial
evidence_integrity logs dependency_wait
```

Wrong behavior:

```text
do not print Dossier until wick complete
do not print Board until deep evidence complete
```

Rule:

```text
Dependencies may block downstream computation.
Dependencies may not block truth publication.
```

---

## 33. Deep Evidence Active Set

Deep Lane needs an active set.

Fields:

```text
deep_active_set
deep_pending_set
deep_completed_set
deep_degraded_set
deep_max_active_symbols
deep_batch_id
deep_batch_started_at
deep_batch_progress_pct
```

Rule:

```text
Deep Lane works in batches.
Global Top 10 selection may change, but active deep batch must finish, expire, or be explicitly replaced.
```

Without this rule, selection churn can constantly reset deep evidence and nothing completes.

---

## 34. Selection Churn Control

If Global Top 10 changes every heartbeat, Deep Lane can thrash.

Required concepts:

```text
selection_hysteresis
minimum_hold_cycles
replacement_reason
deep_batch_replace_allowed
```

Rule:

```text
Do not replace selected deep symbols every heartbeat unless risk, market availability, or explicit selection invalidation forces it.
```

This book owns the timing stability rule.

The Selection & Basket Construction Guidebook will later own the ranking-side policy.

---

## 35. Publication-First Scheduler Order

Recommended heartbeat order:

```text
1. Sense time / pressure / critical flags.
2. Update due map.
3. Coalesce duplicate tasks.
4. Select one bounded work slice.
5. Execute bounded work slice.
6. Publish heartbeat / Atomic Update Overview if due or state changed.
7. Log task outcome.
8. Exit cleanly.
```

Forbidden pattern:

```text
run all due work, then maybe publish
```

Publication must be interleaved with runtime progress.

---

## 36. Atomic Update Overview Timing

The Atomic Update Overview must update even when deep work is incomplete.

It should expose:

```text
current owner
current lane
current layer
cycle state
last successful publication
oldest starved task
deep evidence progress
recovery queue size
next scheduled owner
pressure state
breath phase
```

This prevents the operator from staring at a quiet file wondering whether Aurora is alive.

---

## 37. Telemetry Fields

Minimum telemetry fields:

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

Telemetry must support both human Board display and machine governance ledgers.

---

## 38. Fake-Alive Failure Modes

AURORA CORE must detect when it looks alive but is functionally stuck.

Fake-alive detectors:

```text
Board prints but layer_status is not changing.
Heartbeat is fresh but oldest_starved_task_age is increasing.
Global Top 10 is fresh but deep evidence is stale.
Dossiers exist but quote age exceeds stale threshold.
Publication succeeds but evidence_integrity stays pending.
Fast Lane is healthy but Slow Lane never receives slices.
OnTimer duration rises while completed task count falls.
Retry count rises but retry success count stays flat.
Selection changes repeatedly but deep_batch_progress_pct resets.
```

When detected:

```text
runtime_health = fake_alive_risk
pressure_state = degraded or critical
Board must show exact reason
```

Core law:

```text
Fake-alive runtime is worse than visible degradation.
```

---

## 39. Task Outcome Taxonomy

Every task should finish with one of:

```text
success
success_degraded
partial
deferred_budget
deferred_dependency
deferred_backoff
deferred_lane_pressure
failed_soft
failed_hard
unavailable
cancelled_coalesced
```

Avoid binary pass/fail when truth is partial.

Partial truth must remain visible.

---

## 40. No-Go Patterns

Do not build:

```text
unbounded OnTimer work
heavy OnTick brain
all-symbol deep evidence
all-symbol indicators
all-symbol tick capture
all-symbol DOM
retry every failure every heartbeat
random jitter that cannot be reproduced
silent circuit breakers
hidden task dropping
Board complete labels without evidence
publication blocked by dirty truth
selection churn that resets deep evidence forever
```

---

## 41. Open Questions

These remain open until implementation design:

```text
exact heartbeat period
exact lane slice budgets
exact starvation thresholds
exact deep active set size
exact cadence numbers per lane
exact retry backoff constants
exact deterministic jitter max offset
exact Board display layout for pressure state
```

Do not invent false precision before runtime evidence exists.

---

## 42. Acceptance Criteria

This guidebook is acceptable if a future coder can implement the scheduler without guessing the survival model.

Acceptance criteria:

```text
Defines all runtime lanes.
Defines what each lane may and may not do.
Defines event-handler constraints from MT5.
Defines heartbeat and breath phase fields.
Defines task identity/coalescing rules.
Defines queue pressure and starvation fields.
Defines retry/backoff/jitter rules.
Defines load shedding rules.
Defines circuit breaker states.
Defines fake-alive detection.
Defines publication-first order.
Does not define strategy edge.
Does not create trade permission.
Does not lock false-precision cadence numbers too early.
```

---

## 43. Final Timing Law

```text
Aurora must not try to do the most work per heartbeat.
Aurora must do the right bounded work, expose what was deferred, print truth, and never let important lanes starve silently.
```

Truthful progress beats frantic activity.
