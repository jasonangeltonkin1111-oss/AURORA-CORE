# 26 TRADE JOURNAL SYSTEM

## Purpose

Define the Aurora Core Trade Journal System: a one-file-per-trade forensic record that joins MT5 trade facts, Aurora live capture evidence, and optional imported trader-chat setup packets without pretending that unknown motives are known.

This system exists for bookkeeping, review, process grading, and future setup validation. It is not a strategy, signal, permission, execution, ranking, or prop-firm approval owner.

## Decision

```text
PROCEED as design/source contract.
Runtime implementation still requires MT5 source patch, compile proof, and runtime proof.
```

## Core law

```text
One trade = one final forensic journal file.
Old trades = reconstructed history only.
New trades = live captured evidence when Aurora was running.
Setup reason exists only when a setup packet, magic/comment tag, or Aurora reason packet proves it.
```

## Source authority

Trade Journal source truth order:

1. MT5 orders/deals/positions and account/symbol functions.
2. Aurora live event snapshots captured at/near trade events.
3. Imported setup packet files that pass schema validation.
4. Existing Aurora layer outputs/snapshots when timestamped and matched.
5. User/chat notes.
6. AI reconstruction.

AI reconstruction is never proof of trade motive.

## Official MT5 anchors

The implementation must be checked against official MetaQuotes/MQL5 documentation before runtime patching:

- `OnTradeTransaction` for live trade event capture.
- `MqlTradeTransaction`, `MqlTradeRequest`, and `MqlTradeResult` for transaction/request/result boundary handling.
- `HistorySelectByPosition` for grouping orders and deals by position identifier.
- `POSITION_IDENTIFIER`, `ORDER_POSITION_ID`, and `DEAL_POSITION_ID` for stable position grouping.
- `HistoryDealGet*` and `HistoryOrderGet*` properties for deal/order facts.
- `DEAL_ENTRY` values for in/out/inout/out-by interpretation.
- `CopyRates` only through the existing Shared OHLC Raw Storage owner when future bar-window context is needed.

## Owner placement

The Trade Journal System is a bounded support owner, not a numbered selection/scoring layer.

Recommended owner name:

```text
Trade Forensics / Trade Journal Owner
```

It consumes:

```text
MT5 trade transactions
MT5 selected order/deal/position history
Layer 1 account/risk snapshots
Layer 2-5 foundation truth when available
Layer 6-16 ranking/selection snapshots when available
L17-L23 future evidence/permission snapshots when available
Imported setup packets
```

It owns:

```text
Trade Journal Import route contract
setup packet validation state
one final forensic journal file per trade
before/after Aurora cutoff classification
match-confidence labels
post-trade process review fields
```

It must not own:

```text
trade permission
risk permission
execution
symbol ranking
group selection
setup strategy logic
L23 permission
FileIO route authority outside the existing route/FileIO owner
external worker trade authority
```

## Runtime Owner boundary

MT5 remains the broker-truth and final-publication authority.

The external worker/EXE may help validate setup packets and produce calculation-support envelopes only when explicitly scoped. It must not silently become the final trade-history writer, broker-history poller, trade-permission owner, or execution authority.

Preferred safe flow:

```text
Trader Chat -> Setup Packet file -> Import Inbox
EXE/worker optional validation -> validation envelope
MT5 Trade Journal owner consumes validated packet + MT5 history/live events
MT5 FileIO/Route owner publishes final one-file trade journal
```

If a later implementation lets the EXE move files between Import states, it must still label itself support-only and must not become final trade-history truth without an explicit owner change.

## Folder contract

Stable folders:

```text
Aurora Core/<server>/<account>/Trade Journal Import/Inbox/
Aurora Core/<server>/<account>/Trade Journal Import/Accepted/
Aurora Core/<server>/<account>/Trade Journal Import/Rejected/
Aurora Core/<server>/<account>/Trade Journal Import/Orphaned/

Aurora Core/<server>/<account>/Trade History/Before Aurora/
Aurora Core/<server>/<account>/Trade History/Aurora Captured/
```

Final trade files use one file per trade:

```text
Trade History/<class>/<yyyy>/<mm>/<symbol>/<yyyy-mm-dd>_<hhmm>_<symbol>_<side>_POS-<position_id>.txt
```

Fallback if position ID is unavailable:

```text
<yyyy-mm-dd>_<hhmm>_<symbol>_<side>_DEAL-<primary_deal_ticket>.txt
```

No sidecar manifest, CSV, or JSON is required for the final trade file in MVP. Any proof state belongs inside the one file.

## Cutoff classes

Every final file must declare exactly one forensic class:

```text
BEFORE_AURORA_RECONSTRUCTED
AURORA_CAPTURED_NO_REASON
AURORA_CAPTURED_WITH_REASON
AURORA_MANUAL_CAPTURED
AURORA_EA_CAPTURED
ORPHANED_HISTORY_ROW
```

### BEFORE_AURORA_RECONSTRUCTED

Use for trades that happened before Aurora Trade Journal capture existed or before live capture was available.

Allowed:

```text
entry/exit facts
costs
SL/TP when present
risk/R estimates when SL geometry is valid
symbol/time-window/holding-time diagnostics
selected-history context
```

Forbidden:

```text
claiming true setup reason
claiming declared timeframe
claiming live layer state at entry
claiming L23 permission
claiming the trade was valid by future Aurora logic
```

### AURORA_CAPTURED_NO_REASON

Use when Aurora captured live trade facts/context, but no setup packet/reason packet/tag proves why the trade was taken.

### AURORA_CAPTURED_WITH_REASON

Use when Aurora captured live trade context and a structured setup/reason packet was linked.

### AURORA_MANUAL_CAPTURED

Use when a manual trade was captured live. Reason remains unknown unless a setup packet or manual reason tag exists.

### AURORA_EA_CAPTURED

Use when EA magic/comment/reason packet proves EA identity and setup linkage.

### ORPHANED_HISTORY_ROW

Use when a trade/deal cannot be safely grouped into a clean position-level forensic record.

## One-file journal format

Each final trade file must use this high-level section order:

```text
AURORA TRADE FORENSIC JOURNAL
IDENTITY
FORENSIC CLASS AND CONFIDENCE
TRADE FACTS
ORDER/DEAL/POSITION GROUPING
COSTS AND EXECUTION REALITY
RISK AND R-MULTIPLE
ACCOUNT/RULE CONTEXT
AURORA LIVE CAPTURE
IMPORTED SETUP PACKET
RECONSTRUCTED CONTEXT
POST-TRADE REVIEW
WHAT AURORA CAN HONESTLY SAY
WHAT AURORA CANNOT CLAIM
PROOF / QUALITY LEDGER
END
```

For old trades, unavailable live sections must still appear but say `unavailable_before_Aurora` rather than being omitted.

## Setup packet bridge

A setup packet is a user-created import file from trader-chat analysis. It is not a trade, not broker truth, and not permission.

The packet allows Aurora to link planned context to an eventual trade.

Required packet fields:

```text
schema_name=aurora_trade_setup_packet
schema_version=1
packet_type=trade_setup
reason_id=<stable RID>
created_utc=<yyyy-mm-dd hh:mm:ss UTC>
created_source=<chatgpt_trader_chat/manual/other>
account=<account or unknown>
server=<server or unknown>
symbol=<symbol>
side=<buy/sell>
declared_timeframe=<M1/M5/M15/M30/H1/H4/D1/unknown>
planned_entry=<price/zone/unknown>
planned_sl=<price/unknown>
planned_tp=<price/logic/unknown>
planned_risk_pct=<number/unknown>
setup_name=<short safe label>
setup_proof_level=<IDEA|UNTESTED|UNPROVEN|TESTING|VALIDATED_DEMO|LIVE_PROVEN|REJECTED>
trade_permission=false
prop_firm_safe=false
```

The setup packet may contain longer notes, but forbidden certainty phrases remain blocked:

```text
confirmed buy
confirmed sell
guaranteed
safe trade
prop firm safe
high probability winner
proven edge
```

Unless proof level and validation records genuinely support stronger wording, default proof is `UNTESTED` or `UNPROVEN`.

## Matching rules

### Exact match

Best match:

```text
reason_id appears in MT5 order/deal/position comment or Aurora reason packet mapping.
```

Label:

```text
packet_match=exact_by_reason_id
match_confidence=exact
```

### Strong probable match

Use only when no exact RID exists:

```text
same symbol
same side
trade open time inside packet match window
entry near planned entry/zone
SL near planned SL when available
TP near planned TP when available
```

Label:

```text
packet_match=probable_by_symbol_side_time_price
match_confidence=probable
```

### Weak or no match

If confidence is weak, do not attach as truth. Keep packet orphaned.

```text
packet_match=orphaned_no_safe_trade_match
match_confidence=none
```

## Import states

```text
Inbox    = packet awaiting validation/import
Accepted = valid packet linked or staged for safe link
Rejected = invalid schema, dangerous wording, mismatched account/server, or malformed field
Orphaned = valid packet but no safe trade match yet
```

Rejected and orphaned states must include a reason inside the final status/output, not silent failure.

## Live capture requirements

Future MT5 implementation should capture at least:

```text
transaction event type
request/result boundary where available
symbol
side
volume
position identifier
deal ticket
order ticket
entry/exit classification
price
time
SL/TP at event
account balance/equity/margin/free margin
daily risk/drawdown context when available
spread/tick context when available
magic/comment/reason_id when available
current layer state references when available
```

The event handler must remain bounded. Heavy final file reconstruction can be deferred to a timer/slow-lane task. `OnTradeTransaction` should capture minimal event facts and queue work, not perform heavy scans or full report rendering.

## Historical reconstruction requirements

Historical scanning must be bounded and must not reintroduce heavy all-time scans into the normal heartbeat.

Use the existing selected-history policy unless explicitly building a slow-lane report:

```text
all closed rows inside last 90 days;
if fewer than 100 closed rows exist, fill older closed rows up to 100 when available.
```

Old trades must carry:

```text
live_entry_snapshot=unavailable_before_Aurora
setup_reason=unknown_unless_packet_or_tagged
timeframe_source=unknown_unless_tagged
layer_snapshot_at_entry=unavailable_unless_archived
```

## Quality ledger

Each journal file must include a proof ledger:

```text
MT5 facts: fact / partial / unavailable
History grouping: position_id / deal_ticket / orphaned
Live capture: captured / unavailable_before_Aurora / missing
Setup packet: exact / probable / orphaned / unavailable
Layer snapshot: captured / archived / unavailable
Timeframe: declared / chart_state / inferred / unknown
Risk estimate: calculated / blocked / unavailable
Decision reason: captured / inferred / unknown
```

## Acceptance criteria for MVP implementation

MVP may proceed only when all are true:

1. Route contract exists for Trade Journal Import and Trade History.
2. Packet schema and template exist.
3. Historical trade journal file format is implemented as one file per trade.
4. Before/Aurora cutoff is explicit in every file.
5. Old trades never claim setup reason, timeframe, or layer-at-entry without proof.
6. Runtime writes use existing FileIO/Route owner boundaries.
7. The implementation compiles.
8. Runtime output proves at least one historical trade journal file was printed.

## Rollback

If the journal system overloads MT5, creates wrong matches, or writes misleading files:

```text
Disable Trade Journal task scheduling.
Keep Account Status and existing layers unchanged.
Leave imported packets untouched in Inbox/Orphaned.
Do not delete existing trade facts.
```

## Decision gate

```text
TEST FIRST
```

Next implementation move:

```text
Add schema/template and route/source contracts first.
Then implement a bounded historical one-file-per-trade generator.
Then add live OnTradeTransaction capture.
Then add setup packet import/matching.
```
