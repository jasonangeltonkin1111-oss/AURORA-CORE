# 37 L22 DEEP MARKET EVIDENCE / LIQUIDITY / MT5 ORDER-FLOW PROXY CONTROL

## Status

Planning/control only.

L22 is not runtime-proven by this document.

L22 must remain selected-symbol-only evidence synthesis until source, syntax/import, dispatch, MT5 readback, and runtime output prove otherwise.

Default decision before runtime implementation:

```text
TEST FIRST
```

---

## Purpose

Layer 22 — Deep Market Evidence / Liquidity / MT5 Order-Flow Proxy Pack synthesizes selected-symbol context from risk geometry, liquidity references, VWAP context, tick-flow proxy, and optional MT5 Depth of Market proxy evidence.

It prepares manual-review evidence for Layer 23 — Setup / Strategy / Permission / Alert State.

It does not grant setup confirmation, trade permission, auto-trading permission, prop-firm readiness, edge validation, or execution.

---

## Current source-owner state

Current repo source/index truth shows the active external-worker chain reaches Layer 19 — Selected Wick / Candle Geometry Pack.

There is no active L20, L21, or L22 runtime module proven by current source inspection in this branch.

Therefore L22 implementation is blocked until upstream selected evidence packets exist:

```text
L20 selected rolling tick proxy packet
L21 selected indicator / VWAP / reference packet
L22 source-owner path and dispatch contract
MT5 readback surface contract
```

No worker or MT5 runtime wiring may be added from this document alone.

---

## Owns

L22 may own these fields after upstream packets and source ownership are explicit:

```text
risk_geometry_status
invalidation_distance_pips
invalidation_distance_atr
target_room_pips
target_room_atr
spread_to_stop_ratio
expected_r_after_cost
risk_geometry_confidence
nearest_liquidity_high_distance_pips
nearest_liquidity_low_distance_pips
equal_high_cluster_count
equal_low_cluster_count
session_high_distance_pips
session_low_distance_pips
prior_day_high_distance_pips
prior_day_low_distance_pips
prior_week_high_distance_pips
prior_week_low_distance_pips
liquidity_map_confidence
vwap_context_state
vwap_distance_quality
tick_flow_proxy_available
tick_count_10m
bid_change_count_10m
ask_change_count_10m
spread_spike_count_10m
dom_available_flag
dom_subscription_status
dom_bid_levels_count
dom_ask_levels_count
dom_bid_visible_volume_total
dom_ask_visible_volume_total
dom_imbalance_ratio
order_flow_source
order_flow_confidence
evidence_synthesis_completeness
evidence_synthesis_failure_reason
```

---

## Must not own

L22 must not own:

```text
L20 rolling tick capture
L21 indicator / VWAP calculation
raw OHLC retrieval
Shared OHLC Store writes
private OHLC caches
full-universe DOM subscriptions
unbounded OnBookEvent processing
setup confirmation
entry signals
trade permission
execution
prop-firm readiness
institutional order-flow claims
```

---

## Upstream contract

L22 consumes only selected-symbol packets:

```text
L17 selected scope
L18 selected raw OHLC bar pack
L19 selected candle geometry pack
L20 selected rolling tick proxy packet
L21 selected indicator / VWAP / reference packet
L1 account/prop safety state as context only
L5 basic system gate state as context only
```

L22 must not reopen L5-blocked symbols.

L22 must not use L1/L5 context as override authority.

L22 must not recollect upstream data privately when an upstream owner packet is missing. Missing upstream input is degraded truth, not permission to create a shadow owner.

---

## Downstream contract

L22 feeds:

```text
Layer 23 manual review / trader-chat export / setup research
future validation / outcome owner
```

L22 does not feed direct execution.

Layer 23 must continue to default to:

```text
trade_allowed=false
auto_trade_allowed=false
directional_alert_allowed=false
class_2_setup_alert_allowed=false
```

---

## Official MQL5 constraints to preserve

### DOM subscription

Official MQL5 documentation states that `MarketBookAdd(symbol)` opens Depth of Market for a selected symbol and subscribes for DOM change notifications. It normally belongs in `OnInit()` or a constructor, and handling requires `OnBookEvent(string& symbol)`.

Aurora rule:

```text
No casual all-symbol MarketBookAdd.
Subscribe only to bounded selected symbols.
Record dom_subscription_status.
Release every successful subscription.
```

Official MQL5 documentation states that `MarketBookGet(symbol, book[])` returns an `MqlBookInfo` array and requires DOM to be pre-opened by `MarketBookAdd()`.

Aurora rule:

```text
MarketBookGet failure is degraded DOM truth.
It is not a failed trading system.
It is not permission to fake depth.
```

Official MQL5 documentation states that BookEvent events are broadcast within the chart, subscription counters are per symbol within a chart, and `MarketBookAdd()` / `MarketBookRelease()` calls should be balanced for each symbol during program lifetime.

Aurora rule:

```text
Use explicit subscription bookkeeping.
OnBookEvent must filter by symbol.
OnBookEvent must do minimal work only.
Heavy synthesis belongs in bounded cycle work, not the event handler.
```

Official MQL5 documentation also states BookEvent events are queued and not skipped.

Aurora rule:

```text
Unbounded OnBookEvent processing can backlog the EA.
Never calculate full evidence inside OnBookEvent.
```

### Tick proxy

Official MQL5 documentation states `CopyTicks()` receives `MqlTick` rows, oldest-to-newest, and flags show what changed in each tick.

Official MQL5 documentation also warns that first tick requests can synchronize local tick history, EA/script requests can wait up to 45 seconds, and requests outside fast cache or for other days can be slower.

Aurora rule:

```text
L22 must consume L20 tick proxy packets when available.
L22 must not start fresh broad CopyTicks pulls.
Tick evidence is proxy context, not real institutional order flow.
```

### OHLC dependency

Official MQL5 documentation states `CopyRates()` returns `MqlRates` history rows and may return fewer rows while history is downloading or building.

Aurora rule:

```text
L22 consumes L18/L19/L21 outputs.
It must not call CopyRates or create private OHLC files.
Partial history remains visible degraded truth.
```

---

## Selected-only scope definition

Allowed L22 scope:

```text
symbols selected by L17 deep evidence split
symbols with canonical selected copied dossiers
symbols with upstream L18/L19/L20/L21 packets available or visibly missing
```

Forbidden L22 scope:

```text
all Market Watch symbols
all Layer 5 pass symbols
all ranking_group leaders without L17 selection
all-symbol DOM
a private watchlist hidden outside selection contracts
```

---

## Proposed output schema

Machine summary fields:

```text
schema_name=aurora_l22_deep_market_evidence_liquidity_proxy
schema_version=1
layer=L22
scope=selected_symbols_only
authority=evidence_proxy_context_only
source_l17_status=<accepted|degraded|missing>
source_l18_status=<accepted|partial|missing>
source_l19_status=<accepted|partial|missing>
source_l20_status=<accepted|partial|missing|not_implemented>
source_l21_status=<accepted|partial|missing|not_implemented>
l22_status=<accepted|partial|degraded|blocked_missing_upstream|not_implemented>
l22_failure_reason=<reason>
selected_symbols_seen=<n>
selected_symbols_published=<n>
dom_runtime_enabled=false
dom_subscription_count=<n>
dom_subscription_limit=<n>
trade_permission=false
entry_signal=false
execution=false
```

Per-symbol evidence fields:

```text
symbol
l22_symbol_status
risk_geometry_status
liquidity_map_status
vwap_context_status
tick_flow_proxy_status
dom_proxy_status
order_flow_source
order_flow_confidence
evidence_synthesis_completeness
failure_reason
```

---

## Failure states

L22 must print degraded/partial truth for:

```text
upstream_l17_missing
upstream_l18_missing_or_partial
upstream_l19_missing_or_partial
upstream_l20_not_implemented
upstream_l20_stale_or_missing
upstream_l21_not_implemented
upstream_l21_stale_or_missing
dom_not_enabled
dom_subscription_failed
dom_book_empty
dom_book_get_failed
dom_release_pending
tick_proxy_unavailable
vwap_unavailable
liquidity_map_insufficient_bars
risk_geometry_missing_invalidation_or_target
```

None of these states may block physical publication unless FileIO/path/write failure occurs.

---

## Performance budget plan

Initial implementation must obey:

```text
selected-symbol-only input set
bounded selected symbol cap inherited from L17
no all-symbol DOM subscriptions
no DOM subscribe/release churn every heartbeat
no heavy work inside OnBookEvent
no repeated CSV parse per symbol if one upstream packet can be read once per cycle
no per-symbol flush
no Board verbose dump
Dossier/Workbench split: compact Board overview, richer selected Dossier block, proof in Workbench
```

DOM implementation, when approved, should begin as status placeholders:

```text
dom_runtime_enabled=false
dom_subscription_status=not_wired
dom_available_flag=false
order_flow_source=mt5_tick_proxy|unavailable
order_flow_confidence=low|unavailable
```

Live DOM subscription is a later TEST FIRST patch requiring explicit subscription bookkeeping and release proof.

---

## Wording boundaries

Allowed wording:

```text
liquidity_reference
liquidity_distance
sweep_candidate_descriptive
reclaim_candidate_descriptive
risk_geometry_context
mt5_tick_proxy
mt5_dom_proxy
visible_book_depth_proxy
inspection_only
validation_required
trade_permission=false
```

Forbidden wording:

```text
institutional order flow confirmed
smart money confirmed
confirmed buy
confirmed sell
high probability setup
guaranteed continuation
best trade now
entry signal
prop-firm safe
```

---

## Acceptance checks before source implementation

Do not implement runtime L22 until these are true:

```text
L20 owner/source/dispatch exists or L22 explicitly handles L20_not_implemented
L21 owner/source/dispatch exists or L22 explicitly handles L21_not_implemented
selected scope comes from L17 only
output path is owned by existing worker output/FileIO contracts
MT5 renderer is readback-only if added
DOM is placeholder-only unless subscription bookkeeping is implemented
Python syntax/import proof is captured after worker changes
MetaEditor compile proof is captured after MT5 source changes
runtime output proof is captured before claiming accepted runtime
```

## Decision

```text
TEST FIRST
```
