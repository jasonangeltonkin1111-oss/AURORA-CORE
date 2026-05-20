# AURORA CORE - DOSSIER, FUNDAMENTAL LINKS, AND DOM PLACEMENT CONTROL

**System:** AURORA CORE  
**Status:** Mandatory design/control document.  
**Scope:** Future Dossiers, logical-layer placement, fundamental research links, broker metadata contradiction checks, and later Depth of Market evidence.

---

## 0. Purpose

This document corrects a previous architecture drift: Runtime Owner numbers and Logical Layer numbers must not be confused.

Canonical source:

```text
docs/01_LOGICAL_LAYER_BLUEPRINT.md
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

## 8. Dossier Output Order After Layer Owners Exist

Future Dossier files should be assembled from layer/owner outputs in this order:

```text
1. Header / symbol identity / generated time
2. Current status: placeholder, partial, complete, degraded, omitted
3. Runtime 2 taxonomy / lookup lane while current skeleton exists
4. Operator omit status
5. Layer 1 account/broker context reference
6. Layer 2 market open/closed truth and fundamental links where applicable
7. Layer 3 broker specs and calculation mode/spec-validation output
8. Layer 4 Market Watch / quote-truth output
9. Broker metadata, advisory only
10. Layer 22 DOM snapshot summary later, only when deliberately sampled
11. Contradiction ledger
12. Ranking/selection eligibility later
13. trade_permission=false
```

This order is a display contract only. It does not move later logical layers earlier.

---

## 9. Falsifiers

Hold or kill a patch if:

```text
Dossiers become random raw dumps
Runtime Owner numbers are confused with Logical Layer numbers
Layer 7 is treated as complete because Runtime 7 publication exists
fundamental links appear as trade permission
forex symbols are forced to have stock links
broker Sector/Industry overwrites Runtime 2 taxonomy
calculation mode is placed outside Layer 3 without explicit blueprint revision
heavy calculations are buried inside Dossier publication
DOM is called fundamentals
DOM is implemented before Layer 22 prerequisites
DOM subscriptions are full-universe or unbounded
OnBookEvent becomes a heavy processing path
DOM missing state blocks normal Dossier publication
```

---

## 10. Current Decision State

```text
control_doc_corrected_against_original_logical_blueprint
Runtime7_vs_Layer7_distinction_landed
Layer2_fundamental_link_support_direction_recorded
Layer3_broker_specs_and_calculation_mode_direction_recorded
Layer4_market_watch_direction_recorded
Layer22_DOM_direction_recorded
Dossier_content_not_yet_rich
fundamental_links_not_yet_printed
DOM_not_yet_sampled
trade_permission=false
```

Decision:

```text
TEST FIRST
```
