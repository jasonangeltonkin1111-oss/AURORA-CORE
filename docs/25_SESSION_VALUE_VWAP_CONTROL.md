# AURORA CORE - SESSION VALUE / VWAP / PRIOR SESSION CONTROL

**Status:** Mandatory future-layer design control.  
**Scope:** Later-layer market context, VWAP, session range, prior session high/low, and session value data.  
**Current implementation permission:** Design only. No active trading signal, no Layer 3 ownership, no trade permission.

---

## 0. Purpose

This document locks a later-layer requirement requested by Jason:

```text
AURORA must include current session, last session, and second-last session context.
Last session and second-last session must include session high and session low.
VWAP and related trade-value data belong in later selected-symbol evidence layers, not Layer 3 broker contract truth.
```

This is market-context evidence. It is not a setup, entry, reversal claim, or trade permission.

---

## 1. Correct Layer Placement

### Layer 7 — Session Relevance Ranking

Layer 7 owns session identity and lightweight session relevance:

```text
current_session_name
current_session_start_time
current_session_end_time
current_session_minutes_elapsed
current_session_minutes_remaining
last_session_name
second_last_session_name
session_schedule_source
session_schedule_status
```

Layer 7 may rank session relevance but must not compute deep VWAP, liquidity maps, or entries.

### Layer 9 — Surface Structure / Location Geometry

Layer 9 owns surface location against current and prior session ranges:

```text
current_session_open
current_session_high
current_session_low
current_session_mid
current_session_position_pct
current_session_range_points
current_session_range_atr_proxy
last_session_open
last_session_high
last_session_low
last_session_close
last_session_mid
last_session_range_points
second_last_session_open
second_last_session_high
second_last_session_low
second_last_session_close
second_last_session_mid
second_last_session_range_points
current_distance_to_last_session_high_points
current_distance_to_last_session_low_points
current_distance_to_second_last_session_high_points
current_distance_to_second_last_session_low_points
prior_session_breakout_state
prior_session_inside_outside_state
```

Layer 9 may describe location. It must not say a prior-session high/low break is a buy/sell signal.

### Layer 18 — Selected Raw OHLC Bar Pack

Layer 18 must provide the selected-symbol bar source used to build session values:

```text
session_bar_timeframe_source
session_bar_count_requested
session_bar_count_copied
session_bar_copy_status
session_bar_source_quality
current_session_bar_pack
last_session_bar_pack
second_last_session_bar_pack
```

This must remain selected-symbol only. No all-symbol OHLC harvesting.

### Layer 21 — Selected Indicator / Reference Pack

Layer 21 owns VWAP and reference calculations:

```text
current_session_vwap
last_session_vwap
second_last_session_vwap
current_session_twap_optional
last_session_twap_optional
second_last_session_twap_optional
current_distance_to_session_vwap_points
current_distance_to_session_vwap_atr_proxy
price_position_vs_current_session_vwap
vwap_slope_current_session
vwap_source
vwap_volume_source
vwap_confidence
vwap_bar_count
vwap_volume_sum
vwap_failure_reason
```

VWAP source labels:

```text
real_volume
real_volume_partial
tick_volume_proxy
tick_volume_proxy_partial
unavailable
```

For FX/CFD symbols where exchange real volume is unavailable, VWAP must be labelled as tick-volume proxy. It must not be presented as exchange-volume truth.

### Layer 22 — Deep Market Evidence / Liquidity / MT5 Order-Flow Proxy Pack

Layer 22 consumes prior-session and VWAP context for deeper selected-symbol evidence:

```text
nearest_prior_session_high_distance_points
nearest_prior_session_low_distance_points
last_session_high_distance_points
last_session_low_distance_points
second_last_session_high_distance_points
second_last_session_low_distance_points
prior_session_high_low_liquidity_map
vwap_context_state
vwap_distance_quality
session_value_confluence_score_descriptive
```

Layer 22 may say price is near VWAP or prior-session range. It may not say that creates edge or permission.

---

## 2. Session Definitions

The system must make session definitions explicit.

Minimum session model:

```text
Asia
London
New York
London/New York Overlap
Dead Time
Unknown
```

Each session packet should include:

```text
session_name
session_start_broker_time
session_end_broker_time
session_time_basis
session_definition_source
session_status
```

Acceptable session definition sources:

```text
broker_session_schedule
aurora_static_fx_session_profile
manual_profile_later
unknown
```

Important: MT5 SymbolInfoSessionTrade and SymbolInfoSessionQuote return session times as seconds from 00:00; the date part must be ignored. Aurora must not render fake full UTC datestamps from these values.

---

## 3. Current / Last / Second-Last Session Contract

Every selected symbol packet should eventually expose:

```text
current_session = active session containing current broker/server time
last_session = most recently completed named session before current_session
second_last_session = completed session before last_session
```

Required high/low fields:

```text
last_session_high
last_session_low
second_last_session_high
second_last_session_low
```

Recommended additional fields:

```text
current_session_high
current_session_low
current_session_open
last_session_close
second_last_session_close
session_high_low_source
session_high_low_status
session_high_low_failure_reason
```

If a session has no complete bars, do not fake values. Print status:

```text
unavailable_no_bars
partial_current_session
history_not_ready
broker_session_unknown
symbol_closed
```

---

## 4. VWAP Calculation Contract

VWAP is a reference benchmark, not a signal.

Formula:

```text
vwap = sum(price_i * volume_i) / sum(volume_i)
```

Price input should be explicitly labelled:

```text
typical_price_hlc3
close_price
mid_price_from_ticks_later
```

Default Aurora selected-bar VWAP:

```text
price_i = (high_i + low_i + close_i) / 3
volume_i = real_volume if reliable and positive else tick_volume proxy
```

Failure rules:

```text
if volume_sum <= 0 -> VWAP unavailable
if copied_bars <= minimum_required -> VWAP partial/unavailable
if only tick_volume exists -> label tick_volume_proxy
if current session incomplete -> label partial_current_session
```

---

## 5. Useful Additions Around This Area

Add these later only if bounded and selected-symbol only:

```text
opening_range_high
opening_range_low
opening_range_minutes
initial_balance_high
initial_balance_low
session_midpoint
session_range_expansion_pct
session_range_compression_state
prior_session_high_sweep_flag_descriptive
prior_session_low_sweep_flag_descriptive
reclaim_state_descriptive
session_close_location_pct
vwap_standard_deviation_bands_optional
anchored_vwap_from_session_open
anchored_vwap_from_last_session_high_low_optional
prior_session_poc_proxy_optional
```

All sweep/reclaim/FVG/liquidity wording must stay descriptive until separately validated.

---

## 6. MQL5 Implementation Boundaries

Allowed future APIs:

```text
SymbolInfoSessionTrade
SymbolInfoSessionQuote
CopyRates
MqlRates
CopyTickVolume
CopyRealVolume
CopyTicks / CopyTicksRange for later selected tick context
```

Rules:

```text
no all-symbol OHLC/tick harvesting
selected symbols only after selection/deep-evidence split
bounded bar counts
cache per selected symbol/session window
do not run heavy session scans inside every OnTimer heartbeat
publish partial/degraded truth instead of hiding files
```

---

## 7. No-Go Rules

Forbidden:

```text
VWAP touch = entry
price above VWAP = buy permission
price below VWAP = sell permission
prior session high break = breakout edge
prior session low sweep = reversal edge
session high/low proximity = trade signal
unlabelled tick-volume VWAP pretending to be real-volume VWAP
using current-session partial data as completed-session proof
```

Allowed:

```text
price is above/below VWAP
price is near prior session high/low
current session range is expanded/compressed
VWAP is real-volume/tick-volume proxy/unavailable
session high/low source is complete/partial/unavailable
```

---

## 8. Promotion Requirement

This feature remains UNTESTED design until:

```text
bar source exists
session windows are explicit
current/last/second-last session boundaries are resolved
high/low calculations are verified against chart history
VWAP source is labelled
zero/empty volume cases are tested
partial-current-session behavior is tested
runtime output proves Dossier/Workbench rendering
```

Decision default before implementation: TEST FIRST.
