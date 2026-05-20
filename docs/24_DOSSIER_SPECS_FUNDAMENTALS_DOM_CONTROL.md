# AURORA CORE - DOSSIER SPECS, FUNDAMENTALS, AND DOM CONTROL

**System:** AURORA CORE  
**Status:** Mandatory design/control document.  
**Scope:** Future Dossiers, Layer 1 account context, Layer 2 broker specs / Market Watch truth, fundamental research links, and Depth of Market evidence.

---

## 0. Purpose

Aurora must start making the Dossier folder useful soon, but Dossiers must not become random dumps.

A symbol Dossier is the professional per-symbol truth page.

It should collect the right evidence in the right order:

```text
symbol identity
availability state
operator omit status
broker specs
calculation mode
Market Watch quote truth
Depth of Market snapshot where useful
fundamental research links where applicable
Runtime 2 taxonomy
contradiction warnings
ranking/selection eligibility later
trade_permission=false until separately proven
```

---

## 1. Dossier Owner Boundary

Dossiers may display facts from multiple owners, but they must not become a hidden owner of those facts.

Allowed Dossier inputs:

```text
Runtime 1 account/broker context
Runtime 2 universe/taxonomy lookup
Layer 2 broker specs and Market Watch truth
Runtime 7 route/FileIO publication
fundamental research link templates
bounded DOM snapshots
```

Dossiers must not own:

```text
FileIO implementation
route construction
taxonomy authority
calculation formulas without Layer 2 proof
ranking formulas
selection decisions
trade permission
execution
```

---

## 2. Layer 1 Before Dossiers

Layer 1 should establish account/broker context before rich symbol Dossiers expand.

Layer 1 should publish:

```text
account number
server
currency
balance/equity/margin/free margin
account trade mode
leverage
broker/account route root
prop rule profile status when available
trade_permission=false
```

Dossiers can reference Layer 1 context, but must not duplicate it into a second hidden account owner.

---

## 3. Layer 2 Broker Specs Must Come Early

Layer 2 is the first major content layer that makes Dossiers useful.

Every symbol Dossier should eventually expose:

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
session windows
quote freshness
bid/ask/last/time/spread
```

Calculation mode is mandatory before true value, risk, margin, pip/tick, spread-cost, or profit/loss math is trusted.

---

## 4. Broker Sector / Industry Is Advisory Only

MT5 broker specs may expose sector, industry, country, exchange, and ISIN-style metadata.

These fields may be printed, but they are advisory metadata only.

They must not overwrite Runtime 2 taxonomy by themselves.

Known screenshot falsifier:

```text
AEM / Agnico Eagle Mines Ltd shown as Technology / Consumer Electronics
EGO / Eldorado Gold Corp shown as Technology / Consumer Electronics
ATI / Allegheny Technologies Inc shown as Technology / Consumer Electronics
Eagle Materials Inc shown as Technology / Consumer Electronics
```

Future Dossiers should display broker sector/industry only with status:

```text
broker_metadata_status=advisory_only
broker_metadata_can_contradict_taxonomy=true
```

---

## 5. Fundamental Research Links

Fundamental links are allowed in Dossiers where the instrument has a meaningful research identity.

Examples:

```text
stocks / stock CFDs
listed ETFs where relevant
indices where a stable public page exists
commodities where a stable public page exists
crypto where a stable public page exists
```

Some symbols do not need or may not have useful fundamental links.

Examples:

```text
many forex pairs
broker synthetic symbols
operator-omitted/dead symbols
symbols without a verified canonical research symbol
```

Required Dossier fields:

```text
fundamental_links_status=available|not_applicable|pending_canonical_symbol|operator_omitted
canonical_research_symbol=<value or blank>
research_links=<source=url list>
```

These links are for trader review and taxonomy verification support.

They are not broker execution truth and do not grant trade permission.

---

## 6. Depth of Market Control

The extended book shown in the operator screenshot is Depth of Market.

DOM is broker/order-book evidence, not fundamentals.

MQL5 support:

```text
MarketBookAdd(symbol) subscribes to Depth of Market changes.
MarketBookGet(symbol, book[]) reads MqlBookInfo rows.
OnBookEvent(symbol) receives DOM change events after subscription.
MarketBookRelease(symbol) unsubscribes.
```

Official MQL5 warning translated into Aurora law:

```text
subscribe deliberately
release subscriptions deliberately
filter OnBookEvent by symbol
never subscribe to the full universe
never process heavy DOM logic inside every event
```

DOM can be useful for:

```text
confirming market depth exists
best bid/ask depth snapshot
top-of-book volume
spread/depth quality warning
illiquidity warning
large visible order levels
execution-friction context
```

DOM must not be used as:

```text
taxonomy authority
fundamental identity proof
trade permission
edge proof
prop-firm readiness
heavy ranking engine before controlled tests
```

---

## 7. DOM Sampling Rule

DOM must be bounded.

Allowed first implementation:

```text
manual/diagnostic only
watchlist-only
small symbol set only
one-shot snapshot or short sampled window
write summary to Dossier/Workbench
no per-tick/event spam
no full-universe subscription
```

Required DOM diagnostics:

```text
dom_subscription_status
dom_snapshot_status
dom_level_count
best_bid_depth_volume
best_ask_depth_volume
depth_spread
snapshot_time
last_error
```

If DOM is unavailable, the Dossier should say:

```text
dom_status=not_available_or_not_subscribed
```

and continue publishing other truth.

---

## 8. Dossier Output Order

Future Dossier files should follow this order:

```text
1. Header / symbol identity / generated time
2. Current status: placeholder, partial, complete, degraded, omitted
3. Runtime 2 taxonomy and lookup lane
4. Operator omit status
5. Layer 1 account/broker context reference
6. Layer 2 calculation mode and broker specs
7. Market Watch quote freshness
8. DOM snapshot summary, if sampled
9. Broker metadata, advisory only
10. Fundamental research links, if applicable
11. Contradiction ledger
12. Ranking/selection eligibility later
13. trade_permission=false
```

This order keeps the Dossier readable and professional.

---

## 9. Falsifiers

Hold or kill a patch if:

```text
Dossiers become random raw dumps
fundamental links appear as trade permission
forex symbols are forced to have stock links
broker Sector/Industry overwrites Runtime 2 taxonomy
DOM is called fundamentals
DOM subscriptions are full-universe or unbounded
OnBookEvent becomes a heavy processing path
DOM missing state blocks normal Dossier publication
calculation mode is missing before value/risk math
```

---

## 10. Current Decision State

```text
dossier_specs_fundamentals_dom_control_created
Layer1_account_context_exists_as_basic_account_status
Layer2_specs_not_yet_implemented
Dossier_content_not_yet_rich
fundamental_links_not_yet_printed
DOM_not_yet_sampled
trade_permission=false
```

Decision:

```text
TEST FIRST
```
