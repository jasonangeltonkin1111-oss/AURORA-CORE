# 30 L17-L23 LIQUIDITY / STRUCTURE EVIDENCE RESEARCH SPEC

## Purpose

This document captures the trading-guide-derived research ideas that may later support selected-symbol evidence and setup research without contaminating L12-L16 ranking/selection logic or creating fake trade permission.

Status: `IDEA / UNTESTED / UNPROVEN`.

The concepts here are education and research fuel only. They are not edge proof, not strategy validation, not a signal owner, and not prop-firm permission.

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
high probability wording
trade permission
execution
```

All screenshot-derived structure/liquidity ideas belong no earlier than selected-symbol deep evidence and Layer 23 setup research:

```text
L17 = choose which symbols deserve deep evidence
L18 = selected raw OHLC only
L19 = selected candle geometry only, no pattern folklore
L20 = selected rolling tick/spread proxy
L21 = selected indicator/reference context only
L22 = selected liquidity/structure/risk-geometry evidence only
L23 = setup/strategy/permission research, blocked by default until validated
```

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
confirmed buy
confirmed sell
high probability setup
guaranteed continuation
institutional order-flow confirmed
smart money confirmed
best trade now
entry signal
trade permission
prop-firm safe
```

Allowed wording:

```text
evidence_candidate
structure_candidate
liquidity_reference
setup_research_candidate
inspection_only
validation_required
trade_permission=false
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
prepare liquidity/structure evidence for L23 research
```

Forbidden:

```text
all-symbol deep OHLC/tick/indicator sweep
setup confirmation
trade permission
```

### L23 — Setup / Strategy / Permission / Alert State

Allowed later only after research and proof:

```text
SMC_STRUCTURE_RETEST_V1 candidate
HTF_POI_SWEEP_MSS_FVG_RETRACE candidate
CRT_TBS_RESEARCH candidate
```

Default state:

```text
trade_allowed=false
auto_trade_allowed=false
directional_alert_allowed=false
class_2_setup_alert_allowed=false
```

---

## Future Research Requirements Before Coding L22/L23 SMC Evidence

Coding research required:

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

Trading research required:

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

No exact definition, no code.

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

Required evidence chain:

```text
HTF point of interest or liquidity reference
liquidity sweep or break-hold candidate
mechanical CHOCH/MSS candidate
mechanical BOS candidate
fresh FVG or OB candidate
retrace into defined zone
risk geometry pass
spread_to_stop_ratio pass
expected_r_after_cost pass
L1 prop/account safety pass
session and quote freshness pass
```

Output wording must remain:

```text
setup_candidate=true/false
trade_permission=false unless validation owner explicitly upgrades it
```

---

## Cheapest Falsifier

Before any L23 promotion:

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

Current decision for screenshot-derived trading logic:

```text
TEST FIRST
```
