# 37 L23 Trader Review Export / Permission State Control

## Status

`DESIGN ONLY / HOLD MAIN`

Layer 23 code must remain branch-local until Layer 22 is accepted and stable on `main`.

Dependency lock:

```text
L20 cannot merge until L19 is confirmed running on main.
L21 cannot merge until L20 is confirmed running on main.
L22 cannot merge until L21 is confirmed running on main.
L23 cannot merge until L22 is confirmed running on main.
```

This file is design/control only. It does not wire runtime source, create FileIO routes, create packet builders, enable alerts, grant permission, validate edge, or approve execution.

---

## Core Role

Layer 23 is the first valid setup-candidate, validation-discussion, permission-discussion, alert-discussion, and trader-review export layer.

It may package selected-symbol evidence into candidate/review form.

It must keep the default law:

```text
trade_permission=false
trade_allowed=false
auto_trade_allowed=false
entry_signal=false
directional_alert_allowed=false
class_2_setup_alert_allowed=false
edge_validated=false
prop_firm_ready=false
```

L23 is not a finished trading edge, not an auto-trading owner, not a signal seller, and not prop-firm readiness proof.

---

## Purpose

Layer 23 answers:

```text
What does Aurora know?
What is missing?
What is degraded?
What is stale?
Can this be exported for manual human review?
Is there a setup-candidate family worth researching?
What validation state applies?
What must remain blocked?
```

Layer 23 must not answer:

```text
Should Aurora buy?
Should Aurora sell?
Is this high probability?
Is this prop-firm safe?
Is this validated edge?
Should Aurora execute?
```

---

## Owns

```text
manual_review_packet_available
trader_chat_export_available
evidence_completeness_pct
missing_evidence_list
degraded_evidence_list
stale_evidence_list
setup_candidate_family
setup_candidate_state
setup_direction
evidence_chain_complete
setup_research_candidate
setup_research_label
setup_proof_level
structure_context_summary
liquidity_context_summary
risk_geometry_context_summary
risk_geometry_pass
spread_to_stop_pass
expected_r_after_cost
prop_rule_state
validation_status
kill_condition_state
review_warnings
validation_required_reason
permission_block_reason
class_1_system_alert_allowed
class_2_setup_alert_allowed
directional_alert_allowed
alert_allowed
entry_signal
trade_permission
trade_allowed
auto_trade_allowed
live_allowed
prop_firm_ready
edge_validated
```

---

## Must Not Own

```text
L17 selection split calculation
L18 raw OHLC collection
L19 candle geometry calculation
L20 rolling tick capture
L21 indicator/VWAP/reference calculation
L22 liquidity/risk geometry/DOM synthesis
FileIO
route construction
Board rendering authority
Dossier rendering authority
Workbench rendering authority
order placement
execution
strategy validation runtime
prop-firm readiness
final human decision
AI trade picker
webhook auto execution
```

Renderers may display L23 packet fields. They must not calculate L23 permission or invent missing/degraded/stale evidence.

---

## Export vs Permission Doctrine

Allowed before strategy validation:

```text
raw_evidence_export_allowed=true when a labelled truth packet exists
manual_review_packet_available=true when source/missing/degraded/stale truth is visible
trader_chat_export_available=true when a packet can be copied as context
setup_candidate_family may be labelled for research
partial/degraded export allowed
```

Blocked by default:

```text
trade_permission=false
entry_signal=false
trade_allowed=false
auto_trade_allowed=false
live_allowed=false
prop_firm_ready=false
edge_validated=false
directional_alert_allowed=false
alert_allowed=false
class_2_setup_alert_allowed=false
```

Meaning law:

```text
setup candidate != trade
evidence != permission
backtest != proof
GPT != runtime authority
manual_review_packet_available=true does not imply trade_allowed=true
trader_chat_export_available=true does not imply entry_signal=true
setup_research_candidate=true does not imply expectancy_validated=true
evidence_completeness_pct=100 does not imply permission
```

---

## Future Candidate Models

Candidate families are research labels only. They may help organize manual review and validation planning. They must not create buy/sell calls, class-2 alerts, trade permission, auto-trading, or prop-firm claims.

### 1. ORB_BREAK_RETEST_PDH_PDL

Purpose:

```text
opening range break
retest
target PDH/PDL
```

Minimum evidence before candidate label is useful:

```text
opening_range_session
opening_range_high
opening_range_low
break_direction
retest_detected
retest_hold_state
PDH_or_PDL_target_distance
target_room_pips
spread_to_stop_ratio
expected_r_after_cost
```

### 2. RANGE_REACTION_OR_BREAKHOLD

Purpose:

```text
objective level reaction
rejection versus continuation
```

Minimum evidence before candidate label is useful:

```text
objective_level_id
level_source_timeframe
level_touch_time
reaction_state
break_hold_candidate
failed_break_candidate
room_to_next_level
risk_geometry_state
```

### 3. HTF_POI_SWEEP_STRUCTURE_FVG_RETEST

Purpose:

```text
HTF location
liquidity sweep
structure shift
FVG retest
```

Minimum evidence before candidate label is useful:

```text
htf_poi_id
htf_poi_timeframe
liquidity_sweep_candidate
structure_shift_candidate
fvg_id
fvg_fill_percent
fvg_retest_state
missing_ltf_confirmation
risk_geometry_state
```

### 4. DEEPER_POI_LTF_BOS_CONFIRMATION

Purpose:

```text
deeper POI
lower timeframe BOS after touch
```

Minimum evidence before candidate label is useful:

```text
deeper_poi_id
poi_touch_state
ltf_bos_candidate
ltf_confirmation_state
invalidation_anchor
spread_to_stop_ratio
expected_r_after_cost
```

---

## Candidate State Model

```text
not_applicable
candidate_partial
candidate_watch_only
candidate_research_ready
candidate_invalidated
candidate_validation_pending
candidate_validation_failed
candidate_validated_for_research_only
```

Forbidden state before validation and permission owner upgrade:

```text
candidate_trade_ready
confirmed_entry
permission_granted
```

---

## Validation States

```text
untested
backtest_only
oos_pass
forward_pass
live_proven
```

Validation meaning:

```text
untested = idea/candidate only
backtest_only = historical in-sample evidence only; not proof
oos_pass = out-of-sample pass exists; still not live proof
forward_pass = demo/forward observation passed defined criteria
live_proven = live evidence exists, costs/slippage/prop constraints considered, and kill conditions tracked
```

Even `live_proven` does not automatically mean auto-trading or prop-firm readiness. Permission remains a separate explicit state and must consume L1 prop-rule truth, L5 gate truth, execution realism, and validation owner evidence.

---

## State Machine

```text
NO_CURRENT_EXPORT
WATCH_ONLY_EXPORT
PARTIAL_REVIEW_EXPORT
READY_FOR_MANUAL_REVIEW_EXPORT
BLOCKED_FOR_PERMISSION
VALIDATION_PENDING
VALIDATION_FAILED
FUTURE_PERMISSION_ELIGIBLE
```

Current allowed runtime/design states before L22 is stable:

```text
NO_CURRENT_EXPORT
WATCH_ONLY_EXPORT
PARTIAL_REVIEW_EXPORT
READY_FOR_MANUAL_REVIEW_EXPORT
BLOCKED_FOR_PERMISSION
VALIDATION_PENDING
VALIDATION_FAILED
```

Future-only state:

```text
FUTURE_PERMISSION_ELIGIBLE
```

`FUTURE_PERMISSION_ELIGIBLE` may not appear on `main` until L22 is stable and validation/permission evidence exists.

---

## Evidence Completeness Model

Initial design weights:

```text
L1 account / prop context          10
L5 system gate                     10
L16 Global Top 10 context          10
L17 evidence selection split       10
L18 OHLC pack                      15
L19 candle geometry                10
L20 rolling tick pack              10
L21 indicator/reference pack       10
L22 liquidity/risk geometry        15
```

Bands:

```text
0-24   insufficient_context
25-49  watch_only_export
50-74  partial_review_export
75-94  review_ready_export
95-100 complete_review_export
```

Completeness is review/export context only. It is not edge proof, class-2 alert permission, trade permission, or prop-firm readiness.

---

## Board Contract

Board is compact overview only.

Board L23 section should show:

```text
L23 REVIEW / CANDIDATE / PERMISSION
export_state
manual_review_packet_available
trader_chat_export_available
evidence_completeness_pct
setup_candidate_family
setup_candidate_state
validation_status
missing_evidence_count
degraded_evidence_count
stale_evidence_count
risk_geometry_pass
spread_to_stop_pass
prop_rule_state
kill_condition_state
class_1_system_alert_allowed
class_2_setup_alert_allowed
directional_alert_allowed
entry_signal
trade_permission
trade_allowed
auto_trade_allowed
live_allowed
prop_firm_ready
edge_validated
permission_block_reason
next_required_dependency
```

Board must not show:

```text
full L18 OHLC tables
full L20 tick dumps
full L22 DOM ladder
full setup essays
full packet schema
long repeated warnings
architecture lectures
trade recommendations
auto-trade instructions
```

Recommended compact Board text:

```text
L23: family=HTF_POI_SWEEP_STRUCTURE_FVG_RETEST | state=candidate_partial | validation=untested | evidence=62% | missing=4 | class2=false | signal=false | trade=false | auto=false | block=validation_missing;L22_not_stable
```

---

## Dossier Contract

Dossier is per-symbol white-box truth.

Dossier L23 section should show:

```text
packet_id
schema_version
symbol
cycle_id
source_layers_present
source_layers_missing
source_layers_degraded
source_layers_stale
evidence_completeness_pct
setup_candidate_family
setup_candidate_state
setup_direction
setup_research_candidate
setup_research_label
setup_proof_level
validation_status
evidence_chain_complete
risk_geometry_pass
spread_to_stop_pass
expected_r_after_cost
prop_rule_state
kill_condition_state
structure_context_summary
liquidity_context_summary
risk_geometry_context_summary
review_warnings
manual_review_packet_available
trader_chat_export_available
class_1_system_alert_allowed
class_2_setup_alert_allowed
directional_alert_allowed
alert_allowed
entry_signal
trade_permission
trade_allowed
auto_trade_allowed
live_allowed
prop_firm_ready
edge_validated
validation_required_reason
permission_block_reason
```

Dossier must not recompute upstream evidence, ranking, selection, risk geometry, liquidity, or permission. It displays the L23 packet and upstream owner truth only.

---

## Workbench / Bench Contract

Workbench contains internal proof and diagnostics.

Recommended files after runtime implementation is allowed:

```text
Workbench/L23/L23_ReviewExport_Status.txt
Workbench/L23/L23_ReviewExport_Index.csv
Workbench/L23/L23_SetupCandidate_Index.csv
Workbench/L23/L23_Validation_Status_Index.csv
Workbench/L23/L23_Missing_Evidence_Index.csv
Workbench/L23/L23_Degraded_Evidence_Index.csv
Workbench/L23/L23_Stale_Evidence_Index.csv
Workbench/L23/L23_Permission_Block_Reasons.csv
Workbench/L23/L23_Forbidden_Wording_Scan.txt
Workbench/L23/L23_Runtime_Proof.txt
```

Required proof counters:

```text
l23_packets_total
l23_packets_ready_for_manual_review
l23_packets_watch_only
l23_packets_partial
l23_packets_stale
l23_packets_degraded
l23_packets_missing_l20
l23_packets_missing_l21
l23_packets_missing_l22
candidate_family_count_by_type
validation_status_count_by_type
risk_geometry_fail_count
spread_to_stop_fail_count
prop_rule_block_count
kill_condition_active_count
trade_permission_true_count
trade_allowed_true_count
auto_trade_allowed_true_count
entry_signal_true_count
alert_allowed_true_count
directional_alert_allowed_true_count
class_2_setup_alert_allowed_true_count
forbidden_wording_hit_count
oldest_l23_packet_age_seconds
l23_packet_build_duration_ms
```

Kill counters before validation:

```text
trade_permission_true_count must equal 0
trade_allowed_true_count must equal 0
auto_trade_allowed_true_count must equal 0
entry_signal_true_count must equal 0
alert_allowed_true_count must equal 0
directional_alert_allowed_true_count must equal 0
class_2_setup_alert_allowed_true_count must equal 0
```

---

## Internals Contract

Future L23 internals may exist only after L22 is stable and accepted.

Allowed future module roles:

```text
AC_L23ReviewExportTypes.mqh       type definitions only
AC_L23ReviewExportOwner.mqh       consumes upstream packets, builds L23 packet
AC_L23CandidateState.mqh          candidate family/state mapping only
AC_L23ValidationState.mqh         validation-state labels only; no proof generation
AC_L23PermissionState.mqh         default-false permission state and block reasons
AC_L23ForbiddenWordingScan.mqh    scans L23 output text for forbidden claims
AC_L23WorkbenchRows.mqh           proof rows only
```

Forbidden internals:

```text
CopyRates calls
CopyTicks calls
MarketBookAdd calls
MarketBookGet calls
private OHLC cache
private tick cache
private DOM cache
strategy validator runtime
order sender
risk override
route writer
FileIO owner
AI trade picker
webhook auto execution
```

---

## Trader-Chat Export Packet Schema

```text
AURORA_L23_TRADER_REVIEW_EXPORT_PACKET
schema_version=
packet_id=
packet_created_utc=
cycle_id=
symbol=
server=
account_number=
upstream_l1_status=
upstream_l5_status=
upstream_l16_status=
upstream_l17_status=
upstream_l18_status=
upstream_l19_status=
upstream_l20_status=
upstream_l21_status=
upstream_l22_status=
manual_review_packet_available=
trader_chat_export_available=
export_state=
evidence_completeness_pct=
missing_evidence_list=
degraded_evidence_list=
stale_evidence_list=
review_warnings=
setup_candidate_family=
setup_candidate_state=
setup_direction=
evidence_chain_complete=
setup_research_candidate=
setup_research_label=
setup_proof_level=
validation_status=
hypothesis_id=
evidence_rank=
risk_geometry_pass=
spread_to_stop_pass=
expected_r_after_cost=
prop_rule_state=
kill_condition_state=
structure_context_summary=
liquidity_context_summary=
risk_geometry_context_summary=
class_1_system_alert_allowed=true
class_2_setup_alert_allowed=false
directional_alert_allowed=false
alert_allowed=false
entry_signal=false
trade_permission=false
trade_allowed=false
auto_trade_allowed=false
live_allowed=false
prop_firm_ready=false
edge_validated=false
validation_required_reason=
permission_block_reason=
forbidden_claims_scan_status=
```

---

## Forbidden Wording

Forbidden before validation:

```text
confirmed buy
confirmed sell
high probability setup
guaranteed setup
guaranteed continuation
best trade now
entry signal
trade permission
prop-firm safe
prop firm ready
auto-trade allowed
institutional order-flow confirmed
smart money confirmed
AI trade picker
webhook execution
```

Allowed wording:

```text
manual_review_context
trader_chat_export_packet
setup_candidate_family
setup_research_candidate
inspection_only
validation_required
permission_blocked
partial_truth
degraded_truth
stale_truth
missing_evidence
```

---

## Performance / Debloat Law

L23 must not add heavy work to the hot timer path.

Forbidden performance patterns:

```text
all-symbol L23 packet building
full-folder scans
repeated CSV parse per rendered row
per-symbol FileFlush
per-tick logging
long architecture lectures in Board
repeated warning blocks in every surface
renderer-side calculations
output rereads to prove own writes
unbounded loops
```

Preferred runtime shape after L22 is stable:

```text
consume compact upstream packets
build L23 only for selected/deep-evidence symbols
cache summaries per cycle
Board prints compact counts
Dossier prints symbol detail
Workbench prints proof/counters
```

---

## Acceptance Checks Before Future Main Merge

```text
L20 accepted/stable on main
L21 accepted/stable on main
L22 accepted/stable on main
branch updated against current main
no duplicate owner/cache
no CopyRates/CopyTicks/MarketBook calls in L23
no FileIO/route ownership in L23
Board compact
Dossier detailed but not bloated
Workbench proof-heavy
forbidden wording scan clean
trade_permission=false
trade_allowed=false
auto_trade_allowed=false
entry_signal=false
alert_allowed=false
class_2_setup_alert_allowed=false
MetaEditor compile proven
runtime output inspected
MT5 visual proof inspected
overseer explicitly approves sequencing
```

---

## Rollback Path

Until L22 is stable, L23 runtime/source changes remain branch-only and may be dropped by deleting the branch or reverting branch commits.

Doc-only rollback:

```text
git revert <commit_that_changed_this_doc>
```

No `main` rollback should be needed because this document must not merge to `main` until the dependency gate allows the L23 package.

---

## Decision

```text
DESIGN READY FOR BRANCH DISCUSSION
HOLD MAIN
HOLD L23 CODE MERGE
DEPENDENCY REQUIRED: L22 accepted and stable on main
```
