# AURORA CORE - DOSSIER, FUNDAMENTAL LINKS, AND DOM PLACEMENT CONTROL

**System:** AURORA CORE  
**Status:** Mandatory design/control document.  
**Scope:** Future Dossiers, existing Runtime Owner boundaries, fundamental research links, broker metadata contradiction checks, and later Depth of Market evidence.

---

## 0. Purpose

This document corrects a previous architecture drift: broker specs, Market Watch, calculation mode, fundamentals, and DOM must not be forced into a guessed layer model.

Current source truth proves the active compile chain only includes:

```text
Runtime 0 - Governance / Internal Control
Layer 0.1 - Startup / Runtime Identity
Layer 0.2 - Scheduler / Heartbeat / Breathing Spine
Layer 0.4 - Governance / Manifest / Telemetry
Runtime 1 - Foundation Truth Owner
Layer 1 - Account / Portfolio / Prop Rule Truth
Runtime 2 - Market Universe / Taxonomy Lookup
Runtime 7 - Publication Owner
```

Therefore any new material must be placed as a candidate future owner/lane until the roadmap/source defines the exact layer.

No document may claim that broker specs, Market Watch, calculation mode, or DOM are Layer 2 just because they sound related.

---

## 1. Current Proven Layer Truth

Current active include/source truth:

```text
Runtime 1 currently owns account / portfolio / prop-rule truth.
Runtime 2 currently owns market universe / taxonomy lookup.
Runtime 7 currently owns routes and FileIO publication.
```

Runtime 2 does not currently own broker specs, Market Watch, calculation mode, DOM, or fundamental links.

Any future placement must be done after an owner-map audit.

---

## 2. Dossier Role

Dossiers are future per-symbol truth pages.

They may display facts from multiple owners, but must not become a hidden owner of those facts.

Allowed future Dossier inputs after owner assignment:

```text
Runtime 1 account/broker context reference
Runtime 2 universe/taxonomy lookup
future broker-spec owner output
future Market Watch / quote-truth owner output
future calculation-mode/spec-validation owner output
future fundamental-link owner output
future bounded DOM owner output
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

## 3. Placement Rules For New Material

Until exact future layer ownership is confirmed:

```text
fundamental links = candidate fundamental-link sidecar for Dossiers; user says this belongs with the future Layer 2 direction, but final owner must be confirmed by source/roadmap before implementation
broker specs = candidate broker-spec truth owner, not automatically Runtime 2
Market Watch / quote truth = candidate quote-truth owner, separate from broker specs unless source later merges them deliberately
calculation mode = candidate spec-validation / value-math gate, not automatically broker specs or Market Watch
DOM = later microstructure / depth-evidence owner, not fundamentals and not current Runtime 2
```

A future patch must name the owner file/module before implementing any of these.

---

## 4. Fundamental Research Links

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
```

Fundamental links must not overwrite broker specs, quote truth, calculation mode, Runtime 2 taxonomy, or trade permission.

---

## 5. Broker Metadata Control

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

## 6. Calculation Mode Placement

Calculation mode is mandatory before trusted value, margin, pip/tick, spread-cost, or profit/loss math.

But calculation mode placement must be audited before implementation.

It may belong under a future broker-spec owner, a future value-math gate, or a dedicated spec-validation owner. It must not be guessed.

Required future fields, wherever the owner lands:

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

## 7. DOM Placement

Depth of Market is broker order-book / microstructure evidence.

It is not fundamentals.

It is not current Runtime 2 taxonomy.

It is likely a later-layer evidence source after basic universe, Dossier, broker-spec, quote-truth, and calculation-mode foundations exist.

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

## 8. Dossier Output Order After Owner Assignment

Future Dossier files should be assembled from owner outputs in this order:

```text
1. Header / symbol identity / generated time
2. Current status: placeholder, partial, complete, degraded, omitted
3. Runtime 2 taxonomy and lookup lane
4. Operator omit status
5. Runtime 1 account/broker context reference
6. Broker-spec owner output when available
7. Market Watch / quote-truth owner output when available
8. Calculation-mode/spec-validation output when available
9. Broker metadata, advisory only
10. Fundamental links where applicable
11. DOM snapshot summary only when deliberately sampled by its owner
12. Contradiction ledger
13. Ranking/selection eligibility later
14. trade_permission=false
```

This order is a display contract only. It does not assign source ownership by itself.

---

## 9. Falsifiers

Hold or kill a patch if:

```text
Dossiers become random raw dumps
new material is forced into a guessed layer without owner-map audit
fundamental links appear as trade permission
forex symbols are forced to have stock links
broker Sector/Industry overwrites Runtime 2 taxonomy
calculation mode owner is guessed instead of assigned
heavy calculations are buried inside Dossier publication
DOM is called fundamentals
DOM subscriptions are full-universe or unbounded
OnBookEvent becomes a heavy processing path
DOM missing state blocks normal Dossier publication
```

---

## 10. Current Decision State

```text
control_doc_corrected_after_layer_audit
active_layer_truth_checked_from_compile_chain
future_owner_assignment_required_before_implementation
Dossier_content_not_yet_rich
fundamental_links_not_yet_printed
DOM_not_yet_sampled
trade_permission=false
```

Decision:

```text
TEST FIRST
```
