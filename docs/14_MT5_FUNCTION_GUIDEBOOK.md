# AURORA CORE — MT5 FUNCTION GUIDEBOOK

**System:** AURORA CORE  
**Role:** Native MT5 / MQL5 function map, Runtime Owner assignment, lane/cadence discipline, official-doc reference, and function adoption boundary.  
**Status:** Overview guidebook foundation. Function-level wrappers and implementation details may be refined later.

---

## 0. Purpose

This guidebook maps native MT5/MQL5 function families into AURORA CORE Runtime Owners, lanes, cadence rules, failure states, and no-go boundaries.

It answers:

```text
Which MT5 function family is allowed?
Which Runtime Owner owns it?
Which lane may use it?
How expensive/dangerous is it?
What failure states must be labelled?
What does this function prove?
What does it not prove?
```

Core law:

```text
MT5 native first, but function existence does not equal adoption permission.
```

---

## 1. What This Guidebook Owns

This guidebook owns:

```text
MT5 function family map
owner assignment
lane assignment
safe usage rules
cadence rules
cache policy
failure labels
official doc references
accepted / considered / rejected registry
function no-go patterns
```

---

## 2. What This Guidebook Must Not Own

This guidebook must not own:

```text
specific score formulas
final layer implementation
external worker bridge protocol
permission approval
strategy validation
publication layout
```

Function availability does not grant architecture authority.

---

## 3. Official Documentation Principle

Where platform behavior matters, prefer official MQL5 / MetaQuotes documentation.

Function adoption must record:

```text
official_reference
owner
lane
cadence
cost_risk
failure_state
no-go_usage
```

---

## 4. Native-First Law

Aurora should use MT5 native capability before external dependencies when safe.

But:

```text
native availability ≠ safe adoption
native availability ≠ correct owner
native availability ≠ edge
native availability ≠ permission
```

Every adopted function family needs an owner and boundary.

---

## 5. Function Adoption Ladder

Adoption ladder:

```text
1. Identify official function family.
2. Assign Runtime Owner.
3. Assign lane/cadence.
4. Define input/output truth.
5. Define failure states.
6. Define degraded labels.
7. Define cache/retry policy.
8. Define tests/checks.
9. Add to accepted registry.
10. Reject or hold unsafe uses.
```

Do not call functions just because they exist.

---

## 6. Event Function Map

Functions/events:

```text
OnInit
OnTimer
OnDeinit
OnTick
OnBookEvent later
OnTradeTransaction later
OnTester later
```

Owner / lane:

```text
Timing / scheduler contract
Fast Lane
Recovery Lane
Validation Lane later for tester
```

Official references:

```text
https://www.mql5.com/en/docs/event_handlers/ontimer
https://www.mql5.com/en/docs/event_handlers/ontick
https://www.mql5.com/en/docs/event_handlers/onbookevent
https://www.mql5.com/en/docs/event_handlers/ontester
```

Key law:

```text
Events sense and route.
Events do not carry heavy work.
```

`OnTimer()` events are not stacked if one is already queued or processing.

`OnTick()` is not a complete tick recorder.

---

## 7. Account / Terminal Function Map

Function families:

```text
AccountInfoInteger
AccountInfoDouble
AccountInfoString
TerminalInfoInteger
TerminalInfoDouble
TerminalInfoString
```

Owner:

```text
Foundation Truth Owner
Permission / Alert Owner consumes risk state
```

Purpose:

```text
account/risk/environment truth
```

Official references:

```text
https://www.mql5.com/en/docs/account/accountinfodouble
https://www.mql5.com/en/docs/check/terminalinfointeger
```

No-go:

```text
do not infer prop-firm permission from account info alone
```

---

## 8. Symbol Universe / Broker Spec Function Map

Function families:

```text
SymbolsTotal
SymbolName
SymbolSelect
SymbolIsSynchronized
SymbolInfoInteger
SymbolInfoDouble
SymbolInfoString
SymbolInfoMarginRate
SymbolInfoSessionQuote
SymbolInfoSessionTrade
```

Owner:

```text
Foundation Truth Owner
Taxonomy / Ranking Group Owner consumes classification-related metadata
```

Purpose:

```text
symbol universe
broker specs
session state
classification hints
```

Official references:

```text
https://www.mql5.com/en/docs/marketinformation/symbolinfointeger
https://www.mql5.com/en/docs/marketinformation/symbolinfodouble
https://www.mql5.com/en/docs/marketinformation/symbolinfostring
https://www.mql5.com/en/docs/marketinformation/symbolinfomarginrate
https://www.mql5.com/en/docs/marketinformation/symbolinfosessiontrade
```

No-go:

```text
do not assume all broker metadata is complete or taxonomy-clean
```

---

## 9. Quote Function Map

Function:

```text
SymbolInfoTick
```

Owner:

```text
Foundation Truth Owner
```

Official reference:

```text
https://www.mql5.com/en/docs/marketinformation/symbolinfotick
```

Purpose:

```text
current quote packet
quote freshness
bid/ask/last/time/flags
```

No-go:

```text
current tick ≠ full tick history
zero spread ≠ invalid by itself
fresh quote must be labelled with tick time
```

---

## 10. Bars / Rates Function Map

Function families:

```text
CopyRates
MqlRates
CopyOpen
CopyHigh
CopyLow
CopyClose
CopyTime
```

Owner:

```text
Selected Evidence Owner
```

Purpose:

```text
selected-symbol OHLC evidence
```

Official reference:

```text
https://www.mql5.com/en/docs/series/copyrates
```

No-go:

```text
no full-universe OHLC in broad lanes
no hidden strategy signal from bar access alone
```

---

## 11. Tick History Function Map

Function families:

```text
CopyTicks
CopyTicksRange
MqlTick
```

Owner:

```text
Selected Evidence Owner
Deep Lane only
```

Official reference:

```text
https://www.mql5.com/en/docs/series/copyticks
```

Important behavior:

```text
CopyTicks may initiate synchronization of the local tick database and download missing ticks from the trade server.
```

No-go:

```text
no full-universe tick capture
no OnTick-as-complete-tick-database claim
tick sync must be visible/degraded if pending
```

---

## 12. Market Depth / DOM Function Map

Function families:

```text
MarketBookAdd
MarketBookGet
MarketBookRelease
OnBookEvent
MqlBookInfo
```

Owner:

```text
Selected Evidence Owner
```

Official references:

```text
https://www.mql5.com/en/docs/marketinformation/marketbookadd
https://www.mql5.com/en/docs/marketinformation/marketbookget
https://www.mql5.com/en/docs/marketinformation/marketbookrelease
https://www.mql5.com/en/docs/event_handlers/onbookevent
```

Important behavior:

```text
Depth of Market must be pre-opened with MarketBookAdd before MarketBookGet.
```

Allowed labels:

```text
mt5_dom_proxy
mt5_tick_proxy
unavailable
```

Forbidden:

```text
true_order_flow
institutional_order_flow
smart_money_confirmed
```

---

## 13. Indicator Function Map

Function families:

```text
iATR
iBands
iMA
iStdDev
CopyBuffer
IndicatorRelease
```

Owner:

```text
Selected Evidence Owner
Score/Formula guidebook owns formula labels
```

Official references:

```text
https://www.mql5.com/en/docs/indicators/iatr
https://www.mql5.com/en/docs/indicators/ibands
https://www.mql5.com/en/docs/indicators/ima
https://www.mql5.com/en/docs/indicators/istddev
https://www.mql5.com/en/docs/series/copybuffer
```

No-go:

```text
indicator context ≠ signal
VWAP touch ≠ entry
Bollinger lower ≠ buy
ATR expansion ≠ breakout proof
```

---

## 14. Margin / Profit / Risk Function Map

Function families:

```text
OrderCalcMargin
OrderCalcProfit
OrderCheck later
```

Owner:

```text
Foundation Truth Owner for margin/profit facts
Permission / Alert Owner consumes risk state
Validation / Outcome consumes cost model later
```

Official references:

```text
https://www.mql5.com/en/docs/trading/ordercalcmargin
https://www.mql5.com/en/docs/trading/ordercalcprofit
https://www.mql5.com/en/docs/trading/ordercheck
```

Important behavior:

```text
OrderCalcMargin calculates required margin for a specified trade operation in current market conditions/account currency and does not consider current pending orders/open positions.
```

No-go:

```text
margin estimate ≠ full portfolio safety
OrderCalcMargin alone ≠ permission
```

---

## 15. File Function Map

Function families:

```text
FileOpen
FileWrite
FileFlush
FileClose
FileMove
FileIsExist
FileSize
FolderCreate
```

Owner:

```text
Publication Owner / FileIO owner later
```

Official references:

```text
https://www.mql5.com/en/docs/files/fileopen
https://www.mql5.com/en/docs/files/filewrite
https://www.mql5.com/en/docs/files/fileflush
https://www.mql5.com/en/docs/files/filemove
https://www.mql5.com/en/docs/files/fileisexist
```

No-go:

```text
no scattered FileOpen/FileWrite
no final path invention outside Publication Owner
no FileFlush spam inside loops
```

---

## 16. Notification / Network Function Map

Function families:

```text
SendNotification
WebRequest
Sockets
```

Owner:

```text
Permission / Alert Owner for notifications
External Worker Guidebook for bridge decisions
```

Official references:

```text
https://www.mql5.com/en/docs/network/sendnotification
https://www.mql5.com/en/docs/network/webrequest
https://www.mql5.com/en/docs/network/socketcreate
```

SendNotification constraints:

```text
max 255 chars
max 2 calls per second
max 10 calls per minute
not available in Strategy Tester
```

WebRequest constraints:

```text
synchronous
blocks program execution while waiting
requires allowed URLs
not available in Strategy Tester
```

No-go:

```text
no alert spam
no WebRequest heartbeat bridge
no unbounded socket protocol without contract
```

---

## 17. Python Integration Cross-Reference

Official reference:

```text
https://www.mql5.com/en/docs/python_metatrader5
```

Owner:

```text
External Worker & Calculation Bridge Guidebook
MT5 Function Guidebook cross-references only
```

No-go:

```text
Python integration ≠ permission to move broker truth outside MT5
```

---

## 18. Accepted / Considered / Rejected Registry

Function adoption registry fields:

```text
function_family
status
owner
lane
cadence_family
cache_policy
failure_state
official_reference
reason
no_go_usage
```

Status values:

```text
accepted
considered
hold
rejected
future
```

---

## 19. Lane / Cadence / Cache Rules

Every function family must define:

```text
lane
cadence_family
cache_policy
retry_policy
stale_policy
```

Heavy functions must not run broadly.

Deep evidence functions must remain selected-symbol only.

---

## 20. Failure State Rules

Every function family needs failure labels.

Examples:

```text
account_unavailable
terminal_disconnected
symbol_not_synchronized
spec_missing
quote_stale
history_sync_pending
tick_window_insufficient
DOM_unavailable
indicator_not_ready
file_write_failed
notification_suppressed
webrequest_blocked
socket_unavailable
```

Failure states must print.

---

## 21. No-Go Patterns

Do not allow:

```text
function used without owner
function used without lane
heavy function in Fast Lane
CopyTicks for all symbols
CopyRates for full universe
DOM for every symbol
SendNotification spam
WebRequest main runtime calculation bridge
scattered FileOpen/FileWrite
OrderCalcMargin treated as full risk permission
indicator function treated as signal
```

---

## 22. Acceptance Criteria

This guidebook is acceptable if native MT5 use becomes disciplined.

Acceptance criteria:

```text
Every major MT5 function family has an owner.
Every function family has allowed lane/cadence.
Heavy functions are not broad-lane by default.
File functions are owned by Publication/FileIO only.
WebRequest is HOLD for main bridge.
Sockets are CONSIDER later.
SendNotification limits are documented.
DOM is proxy-only.
CopyTicks is selected/deep only.
Function existence does not equal adoption permission.
```

---

## 23. Final MT5 Function Law

```text
MT5 gives Aurora power.
Owners, lanes, and evidence decide whether that power is safe to use.
```

## Restoration Addendum — Required MT5 Function Family Coverage
- OHLC/bar pack: `CopyRates`, `MqlRates` (+ CopyOpen/High/Low/Close family where used).
- Rolling ticks: `CopyTicks`, `CopyTicksRange`.
- DOM proxy: `MarketBookAdd`, `MarketBookGet`, `MarketBookRelease`, `OnBookEvent`.
- Indicators: `iATR`, `iBands`, `iMA`, `iStdDev`, `CopyBuffer`, `BarsCalculated`, `IndicatorRelease`.
- Quote freshness: `SymbolInfoTick`.
- Session truth: `SymbolInfoSessionTrade`, `SymbolInfoSessionQuote`.
- Publication/FileIO: `FileOpen`, `FileWrite`, `FileFlush`, `FileMove`, `FileIsExist`, `FolderCreate`.
- Alerts transport constraints: `SendNotification` limitations where applicable.
- Validation-later hooks: Strategy Tester / `OnTester` / `TesterStatistics`.
- Custom symbol/replay functions are future research scope only, not base build scope.
