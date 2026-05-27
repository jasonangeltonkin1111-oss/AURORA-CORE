# AURORA CORE - DOSSIER, FUNDAMENTAL LINKS, AND DOM PLACEMENT CONTROL

**System:** AURORA CORE  
**Status:** Mandatory design/control document.  
**Scope:** Future Dossiers, logical-layer placement, fundamental research links, broker metadata contradiction checks, and later Depth of Market evidence.

---

## 0. Purpose

This document corrects a previous architecture drift: Runtime Owner numbers and Logical Layer numbers must not be confused.

Canonical source:

```text
blueprint/03_LOGICAL_LAYER_BLUEPRINT.md
```

Core distinction:

```text
Runtime 7 = Publication Owner, allowed early as infrastructure.
Layer 7 = Session Relevance Ranking, not allowed before Layers 2–6.
```

Publication support being active does not mean Logical Layer 7 is complete.

---

## 1. Correct Placement From Logical Blueprint

The logical blueprint places the relevant ideas as follows:

```text
Layer 2 — Market Open / Closed Truth
Layer 3 — Symbol + Broker Specs Truth
Layer 4 — Market Watch Truth
Layer 22 — Deep Market Evidence / Liquidity / MT5 Order-Flow Proxy Pack
```

Placement decisions:

```text
fundamental links = Layer 2 support sidecar for symbol/market identity and bucket verification, printed in Dossiers where applicable
broker specs = Layer 3
calculation mode = Layer 3 spec truth / spec-validation gate; heavy calculations delegated to later calculation workers/owners
Market Watch / quote truth = Layer 4
DOM = Layer 22 later; bounded MT5 order-flow proxy evidence, not fundamentals
```

Runtime 2 remains the current compile-chain universe/taxonomy lookup skeleton. The broader blueprint says Surface Scoring owns Layers 6–9, but current source has not yet implemented those logical layers.

---

## 2. Dossier Role

Dossiers are future per-symbol truth pages.

They may display facts from multiple layer owners, but must not become a hidden owner of those facts.

Allowed future Dossier inputs after layer owners exist:

```text
Layer 1 account / portfolio / prop-rule truth
Layer 2 market open/closed truth and fundamental-link sidecar where applicable
Layer 3 symbol + broker specs truth, including calculation mode/spec-validation fields
Layer 4 Market Watch quote truth
Runtime 2 current universe/taxonomy lookup until broader layer ownership is implemented
Layer 22 DOM / order-flow proxy snapshot later, bounded and optional
Runtime 7 route/FileIO publication
```

Dossiers must not own:

```text
FileIO implementation
route construction
taxonomy authority
heavy calculations
ranking formulas
selection decisions
trade permission
execution
```

Heavy calculations should be delegated to the correct future worker/owner and consumed as published proof, not buried inside Dossier construction.

---

## 3. Fundamental Research Links — Layer 2 Support

Fundamental links are allowed in Dossiers where the instrument has a meaningful research identity.

Required future fields:

```text
fundamental_links_status=available|not_applicable|pending_canonical_symbol|operator_omitted
canonical_research_symbol=<value or blank>
research_links=<source=url list>
```

Purpose:

```text
support trader review
support taxonomy verification
support contradiction detection
support market/symbol identity checks
```

Fundamental links must not overwrite broker specs, quote truth, calculation mode, Runtime 2 taxonomy, or trade permission.

---

## 4. Broker Specs and Calculation Mode — Layer 3

Layer 3 owns Symbol + Broker Specs Truth.

Calculation mode belongs under Layer 3 spec truth / spec-validation gate before trusted value, margin, pip/tick, spread-cost, or profit/loss math.

Required future fields:

```text
SYMBOL_TRADE_CALC_MODE
calculation_mode_name
SYMBOL_TRADE_CONTRACT_SIZE
SYMBOL_TRADE_TICK_SIZE
SYMBOL_TRADE_TICK_VALUE
SYMBOL_TRADE_TICK_VALUE_PROFIT
SYMBOL_TRADE_TICK_VALUE_LOSS
SYMBOL_POINT
SYMBOL_DIGITS
SYMBOL_CURRENCY_BASE
SYMBOL_CURRENCY_PROFIT
SYMBOL_CURRENCY_MARGIN
SYMBOL_MARGIN_INITIAL
SYMBOL_MARGIN_MAINTENANCE
SYMBOL_MARGIN_HEDGED
SYMBOL_SPREAD_FLOAT
SYMBOL_TRADE_MODE
SYMBOL_TRADE_EXEMODE
SYMBOL_FILLING_MODE
SYMBOL_ORDER_MODE
```

Required future checks:

```text
OrderCalcMargin check
OrderCalcProfit check
SymbolInfoMarginRate check where available
calculation_mode_missing warning
unsupported_calculation_mode warning
missing_tick_value warning
invalid_contract_size warning
currency_conversion_needed warning
```

Heavy value/risk calculations should be performed by the proper future calculation worker/owner and published back as proof.

---

## 5. Market Watch Truth — Layer 4

Layer 4 owns current Market Watch truth.

Expected future fields:

```text
bid
ask
last
spread
tick_time
quote_freshness
bid_high
bid_low
ask_high
ask_low
open_price
close_price
daily_change
```

Zero spread is not automatically invalid.

Layer 4 must not overwrite Layer 3 broker specs or Runtime 2 taxonomy.

---

## 6. Broker Metadata Control

MT5 broker specs may expose sector, industry, country, exchange, and ISIN-style metadata.

These fields may be printed, but they are advisory metadata only.

Known screenshot falsifier:

```text
AEM / Agnico Eagle Mines Ltd shown as Technology / Consumer Electronics
EGO / Eldorado Gold Corp shown as Technology / Consumer Electronics
ATI / Allegheny Technologies Inc shown as Technology / Consumer Electronics
Eagle Materials Inc shown as Technology / Consumer Electronics
```

Required future handling:

```text
broker_metadata_status=advisory_only
broker_metadata_can_contradict_taxonomy=true
broker_metadata_must_not_overwrite_runtime2_taxonomy=true
```

---

## 7. DOM Placement — Layer 22 Later

Depth of Market is broker order-book / microstructure evidence.

It belongs later under:

```text
Layer 22 — Deep Market Evidence / Liquidity / MT5 Order-Flow Proxy Pack
```

DOM is not fundamentals.

DOM is not current Runtime 2 taxonomy.

Potential use later:

```text
DOM availability
best bid/ask depth snapshot
top-of-book volume
depth spread
visible size near price
illiquidity warning
execution-friction context
```

MQL5 implementation must remain bounded:

```text
MarketBookAdd(symbol)
MarketBookGet(symbol, book[])
OnBookEvent(symbol)
MarketBookRelease(symbol)
```

Forbidden:

```text
full-universe DOM subscription
unbounded OnBookEvent processing
DOM called fundamentals
DOM used as taxonomy authority
DOM used as trade permission
```

---

## 8. Future Layer Chain For Flow / Liquidity / Structure

Order-flow style evidence must move through the later-layer chain instead of being forced into early surface ranking.

Correct chain:

```text
L8  = surface movement/range ranking from bounded OHLC primitives
L9  = surface structure/location geometry from existing OHLC-derived high/low/open/close context
L18 = selected raw OHLC bar pack for deep selected symbols only
L19 = selected wick/candle geometry derived one-to-one from L18
L20 = selected rolling tick pack using CopyTicks/CopyTicksRange for selected symbols only
L21 = selected indicator/reference pack
L22 = selected deep market evidence, liquidity map, tick-flow proxy, and MT5 DOM proxy
L23 = permission/alert state; consumes proof, does not invent edge
```

Meaning:

```text
L8/L9 may rank attention using surface primitives.
L18-L22 gather deeper evidence only after selection.
L22 is where order-flow proxy belongs.
L23 is where alerts/permission are decided later, after validation.
```

No layer before L22 may claim institution-grade flow certainty, buyer/seller aggression certainty, or hidden liquidity truth.

---

## 9. L8 / L9 Boundary For Current And Future Work

Layer 8 current implementation uses M5/M15/H1 movement/range primitives and is surface ranking only.

Layer 8 may use:

```text
range_5m
range_15m
range_60m
range_day later only if sourced cleanly
movement_score
compression_score
expansion_score
movement_quality_score
range_stability_score
```

Layer 9 may use:

```text
daily/session/weekly high-low-open-close context
position_in_range_pct
distance_to_high/low
available_surface_room
surface_obstacle_distance
surface_location_score
surface_structure_score
```

Layer 8 must not own:

```text
DOM
tick-flow capture
liquidity map
candle/wick deep geometry
setup validation
trade permission
```

Layer 9 must not own:

```text
DOM
tick-flow capture
selected raw OHLC packs
indicator packs
liquidity map synthesis
trade permission
```

L8 and L9 are surface attention layers. They decide what is worth inspecting, not what is worth trading.

---

## 10. L20 Tick-Flow Proxy Control

Layer 20 is the selected rolling tick pack.

It may use MQL5 tick history functions only for selected symbols, not the full broker universe.

Required future fields:

```text
tick_pack_status=available|partial|unavailable|sync_pending|error
tick_window_seconds=600
tick_count_1m
tick_count_5m
tick_count_10m
bid_change_count_10m
ask_change_count_10m
last_change_count_10m
volume_change_count_10m
spread_min_10m
spread_max_10m
spread_avg_10m
spread_stddev_10m
spread_spike_count_10m
tick_gap_max_seconds
tick_gap_avg_seconds
tick_flags_observed
```

Implementation constraints:

```text
CopyTicks / CopyTicksRange only on selected symbols.
Do not request deep multi-day tick history inside heartbeat loops.
Cache/snapshot results so repeated calls do not starve OnTimer.
If synchronization is pending or partial, publish partial truth instead of fake completeness.
```

Tick-flow proxy wording must remain honest:

```text
allowed: tick_flow_proxy_up|down|mixed|flat|unavailable
allowed: quote_pressure_proxy
forbidden: real institution-grade flow certainty
forbidden: guaranteed market-buy/sell aggression
```

---

## 11. L22 DOM / Liquidity Proxy Control

Layer 22 owns selected deep market evidence and MT5 order-flow proxy.

Required future fields:

```text
order_flow_source=mt5_tick_proxy|mt5_dom_proxy|combined_proxy|unavailable
dom_available_flag
dom_subscription_status=not_attempted|subscribed|unavailable|release_failed|error
dom_last_update_time
dom_bid_levels_count
dom_ask_levels_count
dom_bid_volume_total
dom_ask_volume_total
dom_top_bid_volume
dom_top_ask_volume
dom_imbalance_ratio
dom_depth_gap_points_bid
dom_depth_gap_points_ask
tick_flow_proxy_available
tick_count_10m
bid_change_count_10m
ask_change_count_10m
spread_spike_count_10m
order_flow_confidence
```

Implementation constraints:

```text
Subscribe only selected symbols: Global Top 10, selected evidence basket, open positions, pending orders, manual watch later.
Keep MarketBookAdd and MarketBookRelease balanced per symbol.
OnBookEvent must filter by symbol and do bounded work only.
DOM snapshots may be unavailable, empty, synthetic, stale, or broker-specific.
DOM output must include source/proxy/confidence labels.
```

Use of L22 results:

```text
Can inform execution-friction caution.
Can inform liquidity-risk caution.
Can support later setup-review evidence.
Cannot override L1 prop/risk controls.
Cannot reopen L5-blocked symbols.
Cannot grant trade permission.
Cannot claim exchange-wide or institution-grade flow authority.
```

---

## 12. Board / Dossier / Workbench Surface Standard For Future Flow

Board surface must stay compact:

```text
LAYER 22 - DEEP MARKET EVIDENCE / LIQUIDITY
----------------------------------------
Status:                     Partial
Selected Symbols:           10
Tick Pack Ready:            8
DOM Available:              2
Worst Blocker:              dom_unavailable_or_tick_sync_pending
Trade Permission:           FALSE
```

Dossier may show per-symbol selected evidence:

```text
LAYER 22 - DEEP MARKET EVIDENCE / LIQUIDITY
----------------------------------------
Status: Partial
Source: MT5 tick proxy + MT5 DOM proxy where available
Order Flow Source: mt5_tick_proxy
DOM Status: unavailable
Tick Flow Proxy: available
Spread Spike Count 10m: 2
Order Flow Confidence: low
Boundary: proxy evidence only; no institutional order-flow claim; no trade permission
```

Workbench may show machine proof:

```text
selected_symbol_count=10
tick_copy_status=partial
dom_subscribe_attempted=2
dom_subscribe_ok=1
dom_release_ok=1
onbookevent_filtered=true
payload_checksum=<value>
accepted_by_runtime3=<true|false>
```

---

## 13. Research-Backed MQL5 Constraints

The official MQL5 documentation constrains the design:

```text
MarketBookAdd opens Depth of Market and subscribes for DOM change notifications.
MarketBookGet returns an MqlBookInfo array and requires Depth of Market to be opened first.
OnBookEvent receives the symbol and subscriptions must be filtered and released correctly.
CopyTicks returns MqlTick records, flags show what changed, and requests may trigger tick database synchronization.
```

Architectural consequence:

```text
DOM and tick-flow work must be selected-symbol, bounded, cached, and honestly degraded.
Full-universe DOM/tick deep collection is forbidden because it breaks performance and creates fake source authority.
```
