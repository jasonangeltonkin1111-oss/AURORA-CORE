# 02 TRADE SETUP PACKET SCHEMA

## Purpose

Define the static import schema for one trade setup packet file that can be created from trader-chat analysis and later imported into Aurora Trade Journal.

A setup packet is journal evidence only. It is not trade permission, not edge proof, not broker truth, and not execution authority.

## File type

Plain UTF-8 text using `key=value` header fields plus optional free-text notes.

Recommended filename:

```text
RID_<yyyymmdd>_<hhmmss>_<symbol>_<side>.txt
```

Example:

```text
RID_20260524_101422_EURUSD_BUY.txt
```

## Required header

```text
schema_name=aurora_trade_setup_packet
schema_version=1
packet_type=trade_setup
reason_id=RID_yyyymmdd_hhmmss_symbol_side
created_utc=yyyy-mm-dd hh:mm:ss UTC
created_source=chatgpt_trader_chat
account=18503
server=Upcomers-Server
symbol=EURUSD
side=buy
declared_timeframe=M15
planned_entry=1.08432
planned_sl=1.08320
planned_tp=1.08650
planned_risk_pct=0.20
planned_risk_money=9.82
setup_name=manual_review_breakout_retest
setup_proof_level=UNTESTED
trade_permission=false
prop_firm_safe=false
requires_manual_confirmation=true
```

## Allowed values

### side

```text
buy
sell
unknown
```

`unknown` is allowed only for watchlist/setup tracking packets and cannot be exact-matched to a trade until updated or manually reviewed.

### declared_timeframe

```text
M1
M2
M3
M4
M5
M6
M10
M12
M15
M20
M30
H1
H2
H3
H4
H6
H8
H12
D1
W1
MN1
unknown
multi
```

### setup_proof_level

```text
IDEA
UNTESTED
UNPROVEN
TESTING
VALIDATED_DEMO
LIVE_PROVEN
REJECTED
```

Default for trader-chat analysis is `UNTESTED` or `UNPROVEN` unless validation evidence exists.

### trade_permission

Must be:

```text
false
```

No setup packet may grant permission.

### prop_firm_safe

Must be:

```text
false
```

A setup packet may discuss prop-firm risk, but cannot certify safety.

## Optional fields

```text
entry_zone_low=
entry_zone_high=
invalidation_price=
target_logic=
expected_r=
max_loss_money=
max_loss_pct=
account_equity_at_review=
source_market_board=
source_account_status=
source_dossier_symbol=
source_dossier_generated_time=
layer_context=L5,L6,L7,L8,L9,L10,L11,L12,L13
main_risk=
decision_summary=
reviewer=
chat_reference=
```

## Notes block

A packet may include free text after this marker:

```text
[NOTES]
...
[/NOTES]
```

The notes block may include the trader-chat reasoning, but it must not override header truth.

## Forbidden claims

Reject or quarantine packets containing these phrases unless an explicit governance-approved validation record exists:

```text
confirmed buy
confirmed sell
guaranteed
safe trade
prop firm safe
high probability winner
proven edge
sure win
cannot lose
```

## Validation checklist

A valid trade-intent packet requires:

```text
schema_name present and equals aurora_trade_setup_packet
schema_version present and supported
packet_type present and equals trade_setup
reason_id present and unique enough
created_utc present
symbol present
side present
setup_proof_level present
trade_permission=false
prop_firm_safe=false
```

A tradeable-intent packet additionally requires:

```text
side is buy or sell
declared_timeframe is not unknown unless manually reviewed
planned_sl or invalidation_price is present
planned_risk_pct or planned_risk_money is present
```

## Matching output fields

When imported into a final journal file, matching must be labelled as one of:

```text
packet_match=exact_by_reason_id
packet_match=probable_by_symbol_side_time_price
packet_match=orphaned_no_safe_trade_match
packet_match=rejected_invalid_schema
```

Match confidence values:

```text
exact
probable
none
rejected
```

## Security and safety rules

- Do not execute packet contents.
- Do not interpret packet notes as code.
- Do not allow packet content to override MT5 facts.
- Do not allow packet content to grant trade permission.
- Do not allow packet content to change risk limits.
- Do not allow packet content to become a source of broker truth.

## Decision

```text
PROCEED for schema/template use.
TEST FIRST for runtime import/matching.
```
