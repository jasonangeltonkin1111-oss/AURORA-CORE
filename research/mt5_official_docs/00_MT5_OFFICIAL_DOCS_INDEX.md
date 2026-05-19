# AURORA CORE — MT5 OFFICIAL DOCS INDEX

**System:** AURORA CORE  
**Role:** Official MetaQuotes/MQL5 source map for platform behavior, allowed function families, implementation constraints, and Layer 1 — Account / Portfolio / Prop Rule Truth source anchors.  
**Status:** ACTIVE RESEARCH INDEX — not implementation code.

---

## 0. Purpose

This index records the official MT5/MQL5 documentation anchors that future Aurora work must use before designing, patching, or implementing MT5 source behavior.

Core law:

```text
When MT5 behavior matters, official MQL5 documentation outranks memory, old reports, forum fragments, and AI guesses.
```

---

## 1. What Belongs Here

```text
official MQL5 / MetaQuotes documentation links
function-family ownership notes
platform constraints converted into Aurora rules
Layer 1 — Account / Portfolio / Prop Rule Truth function anchors
FileIO / route ownership anchors
timer / heartbeat anchors
future layer anchors for symbols, quotes, sessions, ticks, DOM, indicators, notifications, network, and Python integration
```

---

## 2. What Must Not Belong Here

```text
MT5 implementation code
.mq5 or .mqh source
Python worker implementation
forum-only claims treated as truth
trading edge claims
permission upgrades
full copied guidebook content
runtime-generated outputs
```

This is a research index, not source code.

---

## 3. Naming Law

Every layer reference must include the layer number and proper name.

Correct:

```text
Layer 1 — Account / Portfolio / Prop Rule Truth
Layer 2 — Market Open / Closed Truth
Layer 4 — Market Watch Truth
```

Incorrect:

```text
Layer 1
L1
that first layer
```

Short codes may appear only after the full name is stated in the same section.

---

## 4. Mandatory Layer 1 — Account / Portfolio / Prop Rule Truth Anchors

Layer 1 — Account / Portfolio / Prop Rule Truth may use only account, terminal, publication, telemetry, and governance-proof functions.

It must not scan symbols, rank markets, build buckets, create selections, run indicators, create alerts, or touch external worker logic.

### 4.1 AccountInfoDouble

Official reference:

```text
https://www.mql5.com/en/docs/account/accountinfodouble
```

Official behavior:

```text
Returns the value of the appropriate account property as double.
```

Layer 1 use:

```text
ACCOUNT_BALANCE
ACCOUNT_EQUITY
ACCOUNT_MARGIN
ACCOUNT_MARGIN_FREE
ACCOUNT_MARGIN_LEVEL
ACCOUNT_PROFIT
ACCOUNT_CREDIT
ACCOUNT_MARGIN_SO_CALL
ACCOUNT_MARGIN_SO_SO
```

Aurora rule:

```text
These fields describe account state.
They do not approve setup signals, execution, edge, or prop-firm readiness.
```

### 4.2 AccountInfoInteger

Official reference:

```text
https://www.mql5.com/en/docs/account/accountinfointeger
```

Official behavior:

```text
Returns the value of an integer/long/bool account property.
```

Layer 1 use:

```text
ACCOUNT_LOGIN
ACCOUNT_LEVERAGE
ACCOUNT_TRADE_ALLOWED
ACCOUNT_TRADE_EXPERT
ACCOUNT_TRADE_MODE
ACCOUNT_MARGIN_SO_MODE
```

Aurora rule:

```text
ACCOUNT_TRADE_ALLOWED and ACCOUNT_TRADE_EXPERT are platform/account flags.
They are not Aurora trade permission.
Aurora permission remains blocked until later validation and safety gates exist.
```

### 4.3 AccountInfoString

Official reference:

```text
https://www.mql5.com/en/docs/account/accountinfostring
```

Layer 1 use:

```text
ACCOUNT_NAME
ACCOUNT_SERVER
ACCOUNT_COMPANY
ACCOUNT_CURRENCY
```

Aurora rule:

```text
Server/account/currency fields support account-safe routing and operator truth.
They do not prove runtime publication or edge.
```

---

## 5. Timer / Heartbeat Anchors

### 5.1 OnTimer

Official reference:

```text
https://www.mql5.com/en/docs/event_handlers/ontimer
```

Critical official behavior:

```text
Only one timer can be launched for each program.
If the queue already contains a Timer event or a Timer event is processing, the new Timer event is not added.
```

Aurora rule:

```text
Runtime telemetry is mandatory.
Long OnTimer work can silently drop cadence.
Layer 1 — Account / Portfolio / Prop Rule Truth must record heartbeat/timer duration and publication attempt state once runtime exists.
```

### 5.2 EventSetTimer / EventKillTimer

Official references:

```text
https://www.mql5.com/en/docs/eventfunctions/eventsettimer
https://www.mql5.com/en/docs/eventfunctions/eventkilltimer
```

Aurora rule:

```text
Timer setup/teardown belongs to the runtime/scheduler shell.
Layer work must remain bounded and observable.
```

---

## 6. FileIO / Publication Anchors

### 6.1 FileOpen

Official reference:

```text
https://www.mql5.com/en/docs/files/fileopen
```

Key official constraints:

```text
File operations are controlled inside the MQL5 sandbox.
FILE_COMMON can use the shared terminal common folder.
FileOpen returns INVALID_HANDLE on failure.
```

Aurora rule:

```text
Publication Owner owns final FileIO.
Runtime Owners may not open final output files directly.
Layer 1 — Account / Portfolio / Prop Rule Truth must use the approved FileIO route contract later.
```

### 6.2 FileWrite

Official reference:

```text
https://www.mql5.com/en/docs/files/filewrite
```

Aurora rule:

```text
First runtime proof rows should use simple, stable, human-auditable row formats.
Do not dynamically create columns by symbol/owner/layer.
```

### 6.3 FileFlush

Official reference:

```text
https://www.mql5.com/en/docs/files/fileflush
```

Aurora rule:

```text
Flush at controlled publication boundaries.
Do not flush inside symbol loops or hot paths.
```

### 6.4 FileMove

Official reference:

```text
https://www.mql5.com/en/docs/files/filemove
```

Aurora rule:

```text
Temp-to-final publication must account for rewrite behavior.
Move failure is a physical publication blocker and must be manifest-visible.
```

### 6.5 FileIsExist / FileSize

Official references:

```text
https://www.mql5.com/en/docs/files/fileisexist
https://www.mql5.com/en/docs/files/filesize
```

Aurora rule:

```text
Final existence and size are verification fields.
They are not proof of data correctness by themselves.
```

---

## 7. Later Foundation Anchors — Not Layer 1 Source Yet

These functions are important later, but are forbidden in Layer 1 — Account / Portfolio / Prop Rule Truth source.

### 7.1 SymbolInfoInteger / SymbolInfoDouble / SymbolInfoString

Official references:

```text
https://www.mql5.com/en/docs/marketinformation/symbolinfointeger
https://www.mql5.com/en/docs/marketinformation/symbolinfodouble
https://www.mql5.com/en/docs/marketinformation/symbolinfostring
```

Later owner:

```text
Foundation Truth Owner — Layer 3 — Symbol + Broker Specs Truth
```

### 7.2 SymbolInfoTick

Official reference:

```text
https://www.mql5.com/en/docs/marketinformation/symbolinfotick
```

Later owner:

```text
Foundation Truth Owner — Layer 4 — Market Watch Truth
```

### 7.3 SymbolInfoSessionTrade / SymbolInfoSessionQuote

Official references:

```text
https://www.mql5.com/en/docs/marketinformation/symbolinfosessiontrade
https://www.mql5.com/en/docs/marketinformation/symbolinfosessionquote
```

Later owner:

```text
Foundation Truth Owner — Layer 2 — Market Open / Closed Truth
```

### 7.4 CopyRates / CopyTicks / MarketBookGet

Official references:

```text
https://www.mql5.com/en/docs/series/copyrates
https://www.mql5.com/en/docs/series/copyticks
https://www.mql5.com/en/docs/marketinformation/marketbookget
```

Later owner:

```text
Selected Evidence Owner — Layers 18–22
```

Aurora rule:

```text
These are not Layer 1 functions.
Do not pull tick/OHLC/DOM work into the first source slice.
```

---

## 8. Notification / Network Anchors — Later Only

### 8.1 SendNotification

Official reference:

```text
https://www.mql5.com/en/docs/network/sendnotification
```

Later owner:

```text
Permission / Alert Owner — Layer 23 — Setup / Strategy / Permission / Alert State
```

Aurora rule:

```text
No setup/directional alerts in Layer 1 — Account / Portfolio / Prop Rule Truth.
```

### 8.2 WebRequest

Official reference:

```text
https://www.mql5.com/en/docs/network/webrequest
```

Aurora rule:

```text
WebRequest main runtime bridge remains HOLD.
It is not a Layer 1 function.
```

---

## 9. External Worker / Python Anchor — Later Only

Official reference:

```text
https://www.mql5.com/en/docs/python_metatrader5
```

Aurora rule:

```text
Python + file snapshot bridge remains BEST FIRST CANDIDATE for external calculation design.
External worker implementation is not part of Layer 1 — Account / Portfolio / Prop Rule Truth.
```

---

## 10. Next Acceptable Work

```text
Use this index to support mt5/01_LAYER1_ACCOUNT_PORTFOLIO_PROP_RULE_TRUTH_SOURCE_PLAN_AND_TESTS.md.
Do not create MT5 source until Layer 1 — Account / Portfolio / Prop Rule Truth plan and tests exist.
Keep all future layer references fully named.
```

---

## 11. Final MT5 Research Law

```text
Official docs define platform behavior.
Aurora contracts define ownership.
Runtime proof defines what actually happened.
```