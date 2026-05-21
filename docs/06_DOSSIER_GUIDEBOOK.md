# AURORA CORE — DOSSIER GUIDEBOOK

**System:** AURORA CORE  
**Role:** Per-symbol truth file, white-box case file, selection explanation surface, degradation record, and future validation support.  
**Status:** Overview guidebook foundation. Field-level schema may be refined later.

---

## 0. Purpose

This guidebook defines the AURORA CORE Dossier.

The Dossier is the per-symbol truth file.

It tells the honest story of one symbol.

It answers:

```text
What is this symbol?
Which asset_class / market_group / market_segment / ranking_group describes it?
Is it open?
Are broker specs valid?
Is the quote fresh?
Is it eligible?
How did it rank?
Was it selected?
Does it have deep evidence?
What is missing?
What is stale?
What is blocked?
What is allowed?
```

The Dossier is richer than the Board.

The Dossier is not Governance.

The Dossier is not strategy proof.

---

## 1. What This Guidebook Owns

This guidebook owns:

```text
per-symbol truth layout
Dossier shell rule
selected vs non-selected symbol rule
symbol header contract
runtime owner summary contract
foundation truth sections
surface score sections
taxonomy and ranking_group identity/rank sections
basket / Global Top 10 sections
selected evidence sections
permission / alert sections
degraded / missing / stale reason contract
machine-readable block contract
Dossier freshness rules
Dossier history snapshot
Dossier no-go language
```

---

## 2. What This Guidebook Must Not Own

This guidebook must not own:

```text
final publication routes
atomic write implementation
Board layout
Governance schemas
account truth computation
surface score computation
taxonomy / ranking_group classification computation
Global Top 10 computation
selected evidence computation
permission decisions
edge validation
```

Dossier displays owner truth.

Dossier does not recompute owner truth.

---

## 3. White-Box / Case-File Research Foundation

Operational systems need both summary dashboards and deeper per-object state visibility.

Google SRE describes white-box monitoring as internal-state visibility that can detect imminent problems or issues masked by retries.

Reference:

```text
https://sre.google/sre-book/monitoring-distributed-systems/
```

Aurora translation:

```text
Dossier = per-symbol white-box truth.
It exposes symbol internals, degradation, stale states, dependency waits, and selection reasons.
```

Postmortem practice also shows the value of written records explaining impact, actions, causes, and follow-up work.

Reference:

```text
https://sre.google/sre-book/postmortem-culture/
```

Aurora translation:

```text
Dossier preserves enough per-symbol state to explain why a symbol was selected, rejected, degraded, blocked, or ignored.
```

---

## 4. Dossier Role in Aurora

The Dossier is symbol-level.

It should show:

```text
symbol identity
taxonomy / ranking_group identity
account context
market/session state
broker specs
quote truth
basic gate result
surface scores
ranking_group rank
basket state
selected evidence state
permission state
degraded reasons
missing reasons
stale reasons
```

It should not show:

```text
full Board cockpit
full Governance ledgers
strategy hype
trade recommendations
raw data overload for non-selected symbols
```

---

## 5. Dossier vs Board vs Governance

Surface boundary:

```text
Publication prints.
Board summarizes.
Dossier explains per symbol.
Governance proves.
Trading/System Truth Owners own truth; System Services publish/render/prove truth.
```

Board answers:

```text
What is the system doing?
```

Dossier answers:

```text
What is this symbol's truth?
```

Governance answers:

```text
What proof/ledger record exists?
```

---

## 6. Dossier Shell Rule

Every symbol may have a useful Dossier shell.

A Dossier must not go blank because the symbol is not selected for deep evidence.

Minimum Dossier shell:

```text
symbol
server/account context
taxonomy / ranking_group identity or unknown state
market open/closed state
broker spec summary
quote freshness summary
basic gate state
surface rank state if available
selection state
deep evidence state
permission state
degraded/missing/stale reasons
```

Correct:

```text
Dossier printed.
Deep evidence not selected this cycle.
Reason displayed.
```

Wrong:

```text
No Dossier because symbol is not Global Top 10.
```

---

## 7. Selected vs Non-Selected Symbol Rule

For non-selected symbols:

```text
deep_evidence_status = not_selected_this_cycle
reason = not_global_top10 / not_ranking_group_leader / not_backup / not_manual_watch
```

For selected symbols:

```text
deep_evidence_status = filling / partial / complete / complete_with_degraded / stale / failed
```

Selected symbols may show deeper evidence sections.

Non-selected symbols show why deep evidence is absent.

No silent blankness.

---

## 8. Symbol Header Contract

Symbol Header should show:

```text
symbol
server
account
broker_company
account_currency
generated_time
cycle_id
heartbeat_id
dossier_status
freshness_state
```

Header must not include trade recommendations.

---

## 9. Runtime Owner Summary Contract

Dossier should summarize owner state for the symbol:

```text
Foundation Truth Owner status
Surface Scoring Owner status
Taxonomy / Ranking Group Owner status
Basket Selection Owner status
Selected Evidence Owner status
Permission / Alert Owner status
Publication / FileIO / Route Service status
Validation / Outcome Owner status later
```

Each owner summary should include:

```text
status
freshness_state
last_success_at
degraded_reason
blocked_reason
```

---

## 10. Foundation Truth Sections

Foundation sections include:

```text
market/session state
broker specs
market watch quote truth
basic gate result
```

Should show:

```text
open_closed_unknown
session_known
trade_mode
spec_completeness
bid
ask
spread
tick_age_seconds
quote_freshness
basic_gate_result
block_reason
degraded_reason
```

Foundation truth comes from Foundation Truth Owner.

Dossier must not recalculate it.

---

## 11. Surface Score Sections

Surface score sections include:

```text
cost/friction score
session relevance score
movement/range score
surface structure/location score
combined surface score if defined
```

Required labels:

```text
score_type = descriptive
directional_validity = false
expectancy_validated = false
trade_permission = false
```

Dossier must not imply that a high score means buy/sell.

---

## 12. Taxonomy and Ranking Group Identity / Rank Sections

Taxonomy / ranking_group sections include:

```text
market_group
market_segment
ranking_group
classification_source
classification_confidence
ranking_group_rank
market_segment_rank
asset_class_rank
ranking_group_top_n_visible_flag
backup_rank
ranking_group_degraded_reason
```

If classification is unknown:

```text
classification_status = unknown / pending_review / degraded
```

Unknown must be visible.

Unknown must not be hidden as Other unless the taxonomy owner explicitly says so.

---

## 13. Basket / Global Top 10 Sections

Basket section includes:

```text
global_top10_flag
global_rank
candidate_pool_member_flag
candidate_reason
correlation_reject_flag
correlation_reject_reason
backup_fill_flag
basket_selection_reason
```

Required language:

```text
Global Top 10 = diversified inspection basket
```

Forbidden language:

```text
best trade
trade list
high probability setup
```

---

## 14. Selected Evidence Sections

Selected evidence sections may include:

```text
Deep Evidence Selection State
OHLC Pack Summary
Wick Pack Summary
Rolling Tick Pack Summary
Indicator / Reference Pack Summary
VWAP Context Summary
Liquidity / MT5 Order-Flow Proxy Summary
Evidence Integrity Summary
```

For non-selected symbols, show compact absence reason.

For selected symbols, show completeness state.

---

## 15. OHLC Pack Summary

Selected symbols may show:

```text
OHLC_status
timeframes_available
bars_requested
bars_loaded
oldest_bar_time
newest_bar_time
history_sync_state
OHLC_degraded_reason
```

Dossier should not dump all OHLC rows unless explicitly designed for a machine block later.

---

## 16. Wick Pack Summary

Selected symbols may show:

```text
wick_status
source_OHLC_status
timeframes_complete
zero_range_count
wick_degraded_reason
```

Wick truth depends on OHLC truth.

If OHLC is missing:

```text
wick_status = waiting_on_OHLC
```

---

## 17. Rolling Tick Pack Summary

Selected symbols may show:

```text
tick_status
tick_window_progress_pct
tick_count_1m
tick_count_5m
tick_count_10m
spread_min
spread_max
spread_avg
spread_spike_count
tick_gap_max_seconds
tick_degraded_reason
```

Tick data is proxy evidence.

Do not imply full tick capture from OnTick.

---

## 18. Indicator / Reference Pack Summary

Selected symbols may show:

```text
indicator_status
ATR_status
Bollinger_status
MA_slope_status
StdDev_status
VWAP_status
CopyBuffer_status
indicator_degraded_reason
```

Indicators are reference/context until validated.

Forbidden:

```text
VWAP touch = entry
Bollinger lower = buy
ATR expansion = breakout confirmation
```

---

## 19. Liquidity / MT5 Order-Flow Proxy Summary

Selected symbols may show:

```text
liquidity_context_status
nearest_liquidity_high_distance
nearest_liquidity_low_distance
session_high_distance
session_low_distance
DOM_available_flag
DOM_subscription_status
DOM_bid_levels
DOM_ask_levels
DOM_imbalance_ratio
order_flow_source
order_flow_confidence
```

Allowed order-flow labels:

```text
mt5_tick_proxy
mt5_dom_proxy
unavailable
```

Forbidden labels:

```text
true_order_flow
institutional_order_flow
smart_money_confirmed
guaranteed_liquidity
```

---

## 20. Permission / Alert Sections

Dossier should show symbol-relevant permission state:

```text
review_allowed
trade_allowed
directional_alert_allowed
auto_trade_allowed
class_1_alert_state
class_2_setup_alert_state
permission_block_reasons
alert_suppression_reasons
```

Default:

```text
directional_alert_allowed = false
auto_trade_allowed = false
trade_allowed = false
```

No Dossier may imply live permission without Permission / Alert Owner state.

---

## 21. Degraded / Missing / Stale Reason Contract

Each major Dossier section should include:

```text
status
freshness_state
last_success_at
source_owner
degraded_reason
blocked_reason
missing_reason
review_allowed
trade_allowed
```

Common reasons:

```text
quote_stale
spec_missing
classification_unknown
surface_score_partial
not_selected_this_cycle
waiting_on_OHLC
tick_window_insufficient
indicator_not_ready
DOM_unavailable
permission_blocked
validation_missing
```

---

## 22. Machine-Readable Block Contract

Dossier may include a compact machine-readable block.

Allowed:

```text
symbol_status_json_like_block
section_statuses
owner_statuses
selection_state
evidence_state
permission_state
```

Forbidden:

```text
massive raw OHLC dump
massive raw tick dump
full governance ledger copy
```

Large data belongs in Governance or selected evidence files if later designed.

---

## 23. Dossier History Snapshot

Dossier may include short recent history:

```text
last_selected_time
last_global_rank
last_ranking_group_rank
last_degraded_reason
last_permission_state
last_deep_evidence_status
```

Purpose:

```text
explain why the symbol changed state
support future debugging
support validation review
```

It must not become a full outcome ledger.

Outcome history belongs to Validation / Governance.

---

## 24. Dossier Freshness Rules

Dossier must show its own freshness.

Fields:

```text
dossier_generated_at
dossier_age_seconds
source_snapshot_cycle_id
source_snapshot_heartbeat_id
freshness_state
```

A stale Dossier may still print.

It must print as stale.

---

## 25. Dossier No-Go Language

Allowed language:

```text
selected for inspection
not selected this cycle
deep evidence filling
quote stale
review blocked
trade blocked
MT5 DOM proxy unavailable
indicator context incomplete
```

Forbidden language:

```text
buy now
sell now
confirmed setup
high probability trade
institutional order flow confirmed
smart money confirmed
prop-firm safe
```

---

## 26. Dossier Surface Boundary

The Dossier consumes truth from Trading/System Truth Owners and System Services.

It may not recompute:

```text
account state
surface score
ranking_group rank
Global Top 10
OHLC evidence
permission state
edge validation
```

If a required truth is missing:

```text
show missing/degraded state
show source owner/service
show dependency
```

Do not silently fill with guessed values.

---

## 27. Acceptance Criteria

This guidebook is acceptable if Dossiers become useful case files.

Acceptance criteria:

```text
Every symbol can print a useful Dossier shell.
Non-selected symbols explain why deep evidence is absent.
Selected symbols expose deep evidence state.
Dossier displays owner truth, not recomputed truth.
Dossier shows freshness, degradation, blockers, and permission state.
Dossier does not imply setup or trade edge.
Dossier supports future validation and debugging.
Dossier is richer than Board but not a raw ledger dump.
```

---

## 28. Final Dossier Law

```text
A Dossier is the symbol's honest case file.
It must explain the symbol's state, not sell a trade idea.
```

## Restoration Addendum — Full 23-Layer Dossier Story
- Dossier story follows L1-L23 ownership chain and asks: identity/truth, gate status, scoring context, ranking_group position, basket status, selected evidence readiness, permission state.
- Taxonomy question is: which `asset_class`, `market_group`, `market_segment`, and `ranking_group` describe this symbol.
- Deep evidence sections cover L18-L22 only when symbol is selected for evidence depth.
- Display policy:
  - raw OHLC = ML_JSON only
  - wick geometry = ML_JSON only
  - rolling tick = ML_JSON only (compressed)
  - indicator/reference summary = HR + ML_JSON
  - deep evidence/risk geometry/liquidity/order-flow proxy = HR + ML_JSON
  - permission/alerts = HR + ML_JSON
- Dossier must not imply strategy edge, trade approval, or live readiness.
- Selected evidence only law applies: no all-symbol OHLC/tick/indicator/DOM dumps.
