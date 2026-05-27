# 30 L17-L23 LIQUIDITY / STRUCTURE EVIDENCE RESEARCH SPEC

## Purpose

This document captures the trading-guide-derived research ideas that may later support selected-symbol evidence, setup research, manual trader review, and trader-chat export without contaminating L12-L16 ranking/selection logic or creating fake trade permission.

Status: `EVIDENCE EXPORT DESIGN / SETUP RESEARCH UNTESTED / PERMISSION UNPROVEN`.

The concepts here are evidence and research fuel. They are allowed to be packaged as raw truth, partial truth, degraded truth, and manual-review context. They are not edge proof, not strategy validation, not an auto-trading owner, and not prop-firm permission.

---

## Hard Boundary

L12-L16 build group heat, selected groups, candidate pools, correlation/diversity, and the Global Top 10 inspection basket.

They must not implement:

```text
SMC setup confirmation
ICT buy/sell models
FVG = buy/sell
OB = buy/sell
liquidity sweep = reversal
Turtle Soup = entry
CRT = entry
candlestick pattern signal
AI trade picker
probability-marketing wording
trade permission
execution
```

All screenshot-derived structure/liquidity ideas belong no earlier than selected-symbol deep evidence and Layer 23 setup/trader-review export:

```text
L17 = choose which symbols deserve deep evidence
L18 = selected raw OHLC only
L19 = selected candle geometry only, no pattern folklore
L20 = selected rolling tick/spread proxy
L21 = selected indicator/reference context only
L22 = selected liquidity/structure/risk-geometry evidence only
L23 = setup research, manual-review state, trader-chat export state, and permission flags
```

Layer 23 must separate three states:

```text
raw_evidence_export_allowed=true when truth packet exists, even if partial/degraded
manual_trader_review_allowed=true when packet is labelled and risk/missing data are visible
trader_chat_export_allowed=true when packet can be consumed as truth context
trade_permission=false unless a later validation/permission owner explicitly upgrades it
auto_trade_allowed=false unless future auto-trading validation explicitly upgrades it
```

Incomplete L18-L22 evidence must not block raw truth export. It must only reduce completeness/confidence and keep permission false.

---

## Allowed Evidence Atoms

The following can be researched later as objective evidence fields, not trade signals:

```text
previous_day_high
previous_day_low
previous_week_high
previous_week_low
asian_session_high
asian_session_low
london_session_high
london_session_low
new_york_session_high
new_york_session_low
nearest_liquidity_high_distance_pips
nearest_liquidity_low_distance_pips
sweep_candidate
reclaim_candidate
break_and_hold_candidate
mechanical_swing_high
mechanical_swing_low
BOS_candidate
CHOCH_or_MSS_candidate
FVG_candidate
FVG_fill_percent
FVG_freshness_state
OB_candidate
CRT_range_high
CRT_range_low
CRT_midpoint
TBS_or_turtle_soup_candidate
risk_geometry_state
spread_to_stop_ratio
expected_r_after_cost
```

Each field must carry source timeframe, source bars, timestamp, confidence/degraded state, and explicit caveat text where applicable.

---

## Forbidden Claims

Forbidden before validation:

```text
directional certainty phrase
opposite-direction certainty phrase
probability-marketing setup
guaranteed continuation
institutional order-flow confirmed
smart money confirmed
best trade now
entry signal
trade permission
prop-rule cleared
auto-trade allowed
```

Allowed wording:

```text
evidence_candidate
structure_candidate
liquidity_reference
setup_research_candidate
inspection_only
manual_review_context
trader_chat_export_packet
validation_required_for_permission
trade_permission=false
auto_trade_allowed=false
```

---

## Layer Placement Map

### L12 — Ranking Group Heat / Quality

Allowed:

```text
group heat
group quality
group activity
group cost/movement/session/location aggregates
rank stability
backup depth
```

Forbidden:

```text
FVG
OB
BOS
CHOCH
sweep
setup
trade direction
```

### L13 — Dynamic Ranking Group Selection

Allowed:

```text
select ranking_groups based on L12 quality/heat and taxonomy/gate health
fallback only when explicitly allowed
```

Forbidden:

```text
select group because it has an SMC setup
```

### L14 — Ranking Group Leader Candidate Pool

Allowed:

```text
pull leaders/backups from selected groups
keep candidate source/reason
```

Forbidden:

```text
candidate enters because of buy/sell setup
```

### L15 — Correlation / Diversity Selection

Allowed:

```text
candidate-pool-only correlation
currency overlap
ranking_group overlap
max correlation threshold
replacement reasons
```

Default design threshold:

```text
max_allowed_pairwise_correlation_abs = 0.30
```

Forbidden:

```text
full-universe 1200x1200 matrix
correlation treated as edge
correlation override of L1 exposure safety
```

### L16 — Global Top 10 Builder

Allowed:

```text
build diversified Global Top 10 inspection basket
```

Required high-score-first greedy rule:

```text
1. Sort eligible candidate pool by inspection score descending.
2. Pick the highest-scoring valid candidate first.
3. For each next slot, scan remaining candidates by score order and choose the first candidate whose absolute pairwise correlation to every already-selected symbol is <= 0.30.
4. If no candidate passes the 0.30 cap, fill only with an explicitly flagged degraded/fallback candidate or leave the slot unfilled according to runtime config.
5. Record max_corr_to_selected, rejected_by_correlation, backup_fill_used, and fallback_reason.
```

Meaning law:

```text
Global Top 10 = inspect these first.
Global Top 10 != best trades.
Global Top 10 != buy/sell.
Global Top 10 != permission.
```

### L17-L22 — Selected Evidence

Allowed:

```text
collect evidence for selected symbols only
publish completeness/degraded states
prepare liquidity/structure evidence for L23 research and manual review export
```

Forbidden:

```text
all-symbol deep OHLC/tick/indicator sweep
setup confirmation
trade permission
```

### L23 — Setup / Strategy / Permission / Trader-Review Export State

Allowed as soon as source packets exist, even before strategy validation:

```text
manual_review_packet_available=true/false
trader_chat_export_available=true/false
evidence_completeness_pct
missing_evidence_list
degraded_evidence_list
setup_research_candidate=true/false
structure_context_summary
liquidity_context_summary
risk_geometry_context_summary
review_warnings
```

Allowed research candidate labels:

```text
SMC_STRUCTURE_RETEST_V1 candidate
HTF_POI_SWEEP_MSS_FVG_RETRACE candidate
CRT_TBS_RESEARCH candidate
```

Default permission state remains:

```text
trade_allowed=false
auto_trade_allowed=false
directional_alert_allowed=false
class_2_setup_alert_allowed=false
```

Manual review/export is not the same as permission:

```text
enabled manual review does not imply enabled trade authority
enabled trader-chat export does not imply enabled entry-signal authority
enabled setup research candidate state does not imply enabled expectancy validation
```

---

## Future Research Requirements Before Coding Permission Or Auto-Trading

Coding research required before runtime evidence layers and permission surfaces are promoted:

```text
MQL5 CopyRates and MqlRates behavior
bar completion handling
server time versus UTC labels
SymbolInfoSessionTrade and SymbolInfoSessionQuote session basis
CopyTicks and CopyTicksRange limits
MarketBookAdd and MarketBookGet broker availability
FileIO atomic writes and manifests
worker versus MT5 runtime authority
selected-symbol-only performance budget
```

Trading research required before Aurora grants strategy permission, directional alerts, or auto-trading:

```text
mechanical swing definition
BOS definition
CHOCH/MSS definition
sweep/reclaim definition
break-and-hold definition
FVG three-candle definition
FVG minimum size and fill state
OB candidate definition
CRT range definition
TBS/Turtle Soup definition
entry zone rule
invalidation rule
target rule
spread/slippage/commission model
prop-firm rule profile
kill condition
```

No exact definition, no permission code. Raw evidence export may still exist with explicit missing/degraded labels.

---

## First Candidate Setup Research Skeleton

Name:

```text
SMC_STRUCTURE_RETEST_V1
```

Status:

```text
IDEA / UNTESTED / UNPROVEN
```

Evidence chain for manual review context:

```text
HTF point of interest or liquidity reference
liquidity sweep or break-hold candidate
mechanical CHOCH/MSS candidate
mechanical BOS candidate
fresh FVG or OB candidate
retrace into defined zone
risk geometry context
spread_to_stop_ratio context
expected_r_after_cost context
L1 prop/account safety context
session and quote freshness context
```

Output wording must remain:

```text
setup_candidate=true/false
manual_review_allowed=true/false
trader_chat_export_allowed=true/false
trade_permission=false unless validation owner explicitly upgrades it
auto_trade_allowed=false unless future auto-trading validation explicitly upgrades it
```

---

## Cheapest Falsifier For Permission / Auto-Trading Promotion

These are not required for raw evidence export or manual trader-chat review. They are required before Aurora promotes a setup into validated permission, class-2 directional alerts, or auto-trading:

```text
1. Select one exact model only.
2. Define rules mechanically.
3. Mark at least 50 historical examples blind before looking right.
4. Record skipped setups and invalid setups, not only winners.
5. Include spread, commission, slippage, and missed-fill assumptions.
6. Run OOS split.
7. Forward/demo observe at least 50 trades or 4 weeks.
8. Kill if expectancy after costs is not positive or drawdown behavior violates prop-firm survival rules.
```

---

## Decision

Use this document as a guardrail for future L17-L23 work.

Current decision for selected evidence export and trader-chat review packets:

```text
PROCEED AS TRUTH EXPORT / TEST FIRST FOR RUNTIME IMPLEMENTATION
```

Current decision for Aurora-generated trade permission, class-2 directional alerts, or auto-trading:

```text
TEST FIRST
```
