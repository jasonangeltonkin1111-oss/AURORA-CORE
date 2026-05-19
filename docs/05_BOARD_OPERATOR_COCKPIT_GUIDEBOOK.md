# AURORA CORE — BOARD & OPERATOR COCKPIT GUIDEBOOK

**System:** AURORA CORE  
**Role:** Human cockpit, system-level visibility, runtime health summary, selection summary, degradation summary, and operator attention surface.  
**Status:** Overview guidebook foundation. Layout details may be refined later.

---

## 0. Purpose

This guidebook defines the AURORA CORE Board.

The Board is the operator cockpit.

It is the first human-readable surface for system health, selection state, degradation, blockers, and action needed.

It is not a raw data dump.

It is not a Dossier.

It is not Governance.

It is not strategy proof.

The Board answers:

```text
Is Aurora alive?
Is Aurora healthy?
What is selected?
What is stale?
What is blocked?
What is degraded?
What needs human attention?
```

---

## 1. What This Guidebook Owns

This guidebook owns:

```text
Board role
Board section map
operator cockpit principles
system-level health display
Atomic Update Overview display
account/risk summary display
foundation truth summary display
bucket summary display
Global Top 10 display
selected evidence progress display
heatmap status display
publication status display
permission/alert state display
warnings/action-needed section
Board freshness rules
Board degraded state rules
Board no-go language
Board clutter rules
```

---

## 2. What This Guidebook Must Not Own

This guidebook must not own:

```text
file route ownership
atomic write implementation
Dossier section details
Governance ledger schemas
rank computation
score computation
bucket classification
Global Top 10 computation
selected evidence computation
permission decisions
edge validation
```

Board displays owner truth.

Board does not secretly compute owner truth.

---

## 3. Dashboard Research Foundation

A useful operations dashboard exposes the core metrics most important to users.

Google SRE describes dashboards as summary views of the most important service metrics and warns that monitoring must remain simple and comprehensible during problems.

Reference:

```text
https://sre.google/sre-book/monitoring-distributed-systems/
```

Aurora translation:

```text
Board = summary cockpit.
Board is not raw data storage.
Board must answer what is broken, what is selected, what is stale, what is blocked, and what needs attention.
```

SRE also describes the four golden signals: latency, traffic, errors, and saturation.

Aurora adapts them for MT5 runtime visibility.

---

## 4. Board Role in Aurora

The Board is system-level.

It should show:

```text
system identity
runtime health
heartbeat state
breath phase
lane pressure
account/risk summary
foundation truth summary
bucket state
Global Top 10
selected evidence progress
heatmap status
publication status
permission/alert state
warnings/action needed
```

It should not show:

```text
raw OHLC rows
raw tick rows
full symbol universe dump
full governance ledgers
full Dossier internals
all formula details
strategy fantasy
```

---

## 5. Board Golden Signals

Aurora Board adapts SRE golden signals.

### Latency

```text
heartbeat duration
Board write age
Dossier write age
publication age
quote stale age
oldest starved task age
deep evidence age
```

### Traffic

```text
tasks due
tasks executed
tasks deferred
symbols processed
selected symbols
publication writes
retry attempts
```

### Errors

```text
file write failures
stale quotes
missing specs
failed evidence packs
failed route verification
failed retries
```

### Saturation

```text
lane queue depth
oldest starved task
over-budget count
deep batch backlog
recovery queue size
load shed count
```

These are Board-worthy because they tell the operator whether Aurora is healthy or fake-alive.

---

## 6. Board Section Map

Standard Board sections:

```text
1. Header / System Identity
2. Runtime Health
3. Atomic Update Overview
4. Account / Risk Snapshot
5. Foundation Truth Summary
6. Bucket Summary
7. Global Top 10
8. Selected Evidence Progress
9. Heatmap Status
10. Publication Status
11. Permission / Alert State
12. Warnings / Action Needed
```

Keep this compact.

The Board is a cockpit, not a warehouse.

---

## 7. Header / System Identity Section

Should show:

```text
system_name
system_version later
server
account
cycle_id
heartbeat_id
generated_time
runtime_state
breath_phase
```

Must not show:

```text
long explanation text
full repo doctrine
full guidebook summaries
```

---

## 8. Runtime Health Section

Should show:

```text
runtime_state
pressure_state
heartbeat_age_seconds
timer_duration_ms
timer_budget_ms
over_budget_flag
oldest_starved_task
oldest_starved_task_age_seconds
fake_alive_risk_flag
```

Health states:

```text
normal
warm
over_budget
starved
degraded
critical
```

If fake-alive risk is detected, Board must show it.

---

## 9. Atomic Update Overview Section

Should show:

```text
current owner
current lane
current layer
cycle state
last successful publication
next scheduled owner
deep evidence progress
recovery queue size
publication state
```

This section exists to answer:

```text
What is Aurora doing right now?
```

---

## 10. Account / Risk Snapshot Section

Should show compact Layer 1 truth:

```text
balance
equity
margin
free_margin
margin_level
floating_pl
open_positions
pending_orders
daily_loss_buffer
max_loss_buffer
prop_rule_status
```

Must not show:

```text
full account history
trade recommendation
risk permission without Permission Owner state
```

---

## 11. Foundation Truth Summary Section

Should show Layers 2–5 summary:

```text
symbols_total
symbols_open
symbols_closed
symbols_unknown
specs_complete
specs_degraded
quotes_fresh
quotes_stale
eligible_clean
eligible_degraded
blocked_count
```

This section must expose the real state of the broker universe.

---

## 12. Bucket Summary Section

Should show:

```text
bucket_count
selected_bucket_count
classification_complete_count
classification_unknown_count
top_buckets
bucket_heat_summary
bucket_degraded_count
```

It must not dump every symbol.

Full per-symbol bucket truth belongs in Dossier / Selection Desk / Governance.

---

## 13. Global Top 10 Section

Should show:

```text
global_rank
symbol
bucket
reason
score_summary
correlation_note
deep_evidence_status
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

## 14. Selected Evidence Progress Section

Should show:

```text
deep_active_set_count
deep_completed_count
deep_pending_count
deep_degraded_count
OHLC_progress
wick_progress
tick_window_progress
indicator_progress
DOM_proxy_available_count
```

This section must make incomplete deep evidence visible.

---

## 15. Heatmap Status Section

Should show only heatmap status, not giant matrices.

Core heatmaps:

```text
Global Top 10 Correlation Heatmap
Bucket Strength / Heat Heatmap
Session Relevance Heatmap
Cost vs Movement Heatmap
Evidence Completeness Heatmap
```

Fields:

```text
heatmap_name
status
last_updated
source_owner
degraded_reason
```

---

## 16. Publication Status Section

Should show:

```text
last_board_write_time
last_dossier_write_time
last_selection_desk_write_time
last_governance_write_time
manifest_status
file_write_fail_count
publication_degraded_count
```

This section must distinguish:

```text
truth degraded
physical publication failed
```

---

## 17. Permission / Alert State Section

Should show:

```text
class_1_alert_allowed
class_2_setup_alert_allowed
directional_alert_allowed
auto_trade_allowed
live_allowed
review_allowed
trade_allowed
permission_block_reasons
alert_suppression_reasons
```

Default must remain:

```text
class_2_setup_alert_allowed = false
directional_alert_allowed = false
auto_trade_allowed = false
live_allowed = false
```

---

## 18. Warnings / Action Needed Section

Should show only actionable or high-importance warnings.

Allowed warning examples:

```text
terminal disconnected
publication failed
fake-alive risk
oldest starved task critical
prop rule danger
quotes stale across universe
selected evidence stuck
manifest failed
route missing
```

Forbidden noise:

```text
symbol rank changed
symbol passed layer
data complete
normal heartbeat
minor score movement
```

Board warnings are not the same as push alerts.

Alerts must remain rarer.

---

## 19. Human-Readable vs Machine-Readable Board Content

Board should prioritize human readability.

Allowed:

```text
compact tables
status labels
short reasons
counts
ages
progress percentages
```

Machine-readable blocks may exist only if compact.

Large machine ledgers belong in Governance.

---

## 20. Board Refresh / Freshness Rules

Board must show its own freshness.

Fields:

```text
board_generated_at
board_age_seconds
source_snapshot_cycle_id
source_snapshot_heartbeat_id
freshness_state
```

Freshness states:

```text
fresh
aging
stale
expired
unknown
```

A stale Board may still print.

It must print as stale.

---

## 21. Board Degraded State Rules

Board status values:

```text
shell_printed
partial
complete
complete_with_degraded
stale
failed
```

If sections are missing:

```text
board_status = partial
missing_sections listed
publication_blocked = false unless physical publication failed
```

If physical write failed:

```text
board_status = failed
publication_blocked = true
```

---

## 22. Board No-Go Language

Allowed language:

```text
selected for inspection
deep evidence filling
quote stale
publication degraded
review blocked
trade blocked
Global Top 10 basket
correlation reject
backup fill used
```

Forbidden language:

```text
best trade
confirmed setup
high probability
buy now
sell now
institutional order flow confirmed
smart money confirmed
guaranteed liquidity
```

---

## 23. Board Clutter Rules

Board must not show everything.

Move to Dossier:

```text
per-symbol detail
symbol evidence sections
symbol degraded reasons
symbol selection explanation
```

Move to Governance:

```text
full ledgers
CSV-like audit detail
historical outcome records
formula registry details
```

Move to Selection Desk:

```text
full bucket Top 5 lists
correlation rejects
candidate pool detail
backup fill detail
```

Board shows summaries and links/paths/statuses.

---

## 24. Board Surface Boundary

Surface boundary rule:

```text
Publication prints.
Board summarizes.
Dossier explains per symbol.
Governance proves.
Runtime Owners own truth.
```

The Board may consume truth from all Runtime Owners.

The Board may not become a Runtime Owner.

---

## 25. Acceptance Criteria

This guidebook is acceptable if Board remains useful under pressure.

Acceptance criteria:

```text
Board answers operator questions quickly.
Board exposes health, selection, degradation, blockers, and action needed.
Board adapts golden-signal telemetry to Aurora.
Board stays compact.
Board does not dump raw data.
Board does not recompute owner truth.
Board never implies trade permission.
Board shows fake-alive risks.
Board shows publication age and starvation state.
```

---

## 26. Final Board Law

```text
The Board is the cockpit, not the engine.
It must show what matters first, expose degraded truth, and never pretend inspection means permission.
```
