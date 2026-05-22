# AURORA LAYER 5 BASIC SYSTEM GATE GUIDEBOOK

Layer 5 is the Basic System Gate. It is not a deep advisory layer, not a scoring layer, and not a Gateway calculation layer.

This document is the Layer 5 source contract after the architecture correction.

## Owner

Layer 5 belongs to Runtime 1 / Foundation Truth Owner.

```text
Runtime 1 - Foundation Truth Owner
Layer 5 - Basic System Gate
```

The previous Runtime 5 / Deep Inspection Advisory interpretation was wrong for the original layer system and is retired.

## Purpose

Layer 5 is the first real all-symbol hard eligibility gate.

It blocks garbage symbols before the scoring/ranking stack starts.

Layer 5 answers:

```text
Is this symbol basically eligible to move into Layer 6+ scoring/ranking work?
```

It does not answer:

```text
Is this a good trade?
Is this a ranked symbol?
Is friction low?
Is volatility good?
Is structure clean?
Is session quality good?
Should we select this symbol?
Should we execute?
```

Those belong to later layers.

## Inputs

Layer 5 consumes owner truth from:

```text
Layer 2 - Market Open / Closed Truth
Layer 3 - Broker Specs and Value Truth
Layer 4 - Live Quote and Spread Truth
```

Layer 5 does not recalculate those facts.

It consumes existing owner packets/gates and produces pass/block status.

## Blocks

Layer 5 blocks symbols for:

```text
closed_or_not_open_market
stale_quote
missing_tick
invalid_bid_ask
missing_essential_specs
disabled_trade_mode
absurd_spread
unresolved_classification_review
l2_not_ready
l3_not_ready
l4_not_ready
```

## Does not own

Layer 5 does not own:

```text
friction ranking
volatility ranking
session ranking
movement/range ranking
structure/location scoring
correlation
basket selection
Gateway transport
Gateway job bus
Gateway result acceptance
trade permission
execution
FileIO
routes
Board/Dossier renderer authority
```

## Future layer placement

The corrected future direction is:

```text
Layer 5  = Basic System Gate
Layer 6  = Cost / Friction Ranking
Layer 7  = Session Relevance Ranking
Layer 8  = Movement / Range Ranking
Layer 9  = Structure / Location Geometry
```

Friction, volatility, session quality, and structure must not be implemented inside Layer 5.

## Current source implementation

Active Layer 5 owner source:

```text
mt5/runtime_owners/runtime_1_foundation_truth_owner/layer_5_basic_system_gate/AC_BasicSystemGate.mqh
```

Retired compatibility wrapper:

```text
mt5/runtime_owners/runtime_5_deep_inspection_advisory_owner/AC_DeepInspectionOwner.mqh
```

The wrapper exists only to prevent include-path breakage while the EA is migrated. It must not become a second Layer 5 owner.

## Board output standard

Market Board should show compact all-symbol gate counts:

```text
LAYER 5 - BASIC SYSTEM GATE
----------------------------------------
Status:                     Complete
Trust:                      Gate Ready
Scanned Symbols:            ...
Gate Pass:                  ...
Gate Blocked:               ...
Closed / Not Open:          ...
Stale Quote:                ...
Missing Tick:               ...
Invalid Bid/Ask:            ...
Missing Specs:              ...
Trade Mode Blocked:         ...
Absurd Spread:              ...
Classification Review:      ...
Worst Blocker:              ...
Scan Duration:              ... ms
Ranking Runtime:            FALSE
Selection Runtime:          FALSE
Trade Permission:           FALSE
```

## Dossier output standard

Dossier should show per-symbol gate truth:

```text
LAYER 5 - BASIC SYSTEM GATE
----------------------------------------
Status: Complete
Trust: Gate Ready
Gate Purpose: First all-symbol hard eligibility gate; blocks garbage symbols before scoring/ranking layers.
Source Inputs: Layer 2 market state, Layer 3 specs/classification, Layer 4 quote/spread quality.
Gate Status: pass / blocked
Gate Reason: ...
L2 Gate: ...
L3 Gate: ...
L4 Gate: ...
Blocked Closed / Not Open: TRUE/FALSE
Blocked Stale Quote: TRUE/FALSE
Blocked Missing Tick: TRUE/FALSE
Blocked Invalid Bid/Ask: TRUE/FALSE
Blocked Missing Specs: TRUE/FALSE
Blocked Trade Mode: TRUE/FALSE
Blocked Absurd Spread: TRUE/FALSE
Blocked Classification Review: TRUE/FALSE

Boundary
----------------------------------------
Calculation Owner: none; basic gate only
Gateway Required: FALSE
Ranking Runtime: FALSE
Selection Runtime: FALSE
Trade Permission: FALSE
Next Layer: Layer 6 Cost / Friction Ranking consumes L5 pass set only.
```

## Workbench output standard

Workbench should show machine/meta counts:

```text
L5_BASIC_SYSTEM_GATE
----------------------------------------
owner_name=Runtime 1 - Foundation Truth Owner
layer_name=Layer 5 - Basic System Gate
status=Complete
trust_state=Gate Ready
gate_policy=closed_market_or_stale_quote_or_invalid_bidask_or_missing_specs_or_disabled_trade_mode_or_absurd_spread_or_unresolved_classification_review_blocks
source_truth_owner=L2_L3_L4_existing_owner_packets_only
calculation_owner=none_basic_gate_only
gateway_required=false
scanned_symbols=...
gate_pass=...
gate_blocked=...
blocked_closed_market=...
blocked_stale_quote=...
blocked_missing_tick=...
blocked_invalid_bidask=...
blocked_missing_specs=...
blocked_trade_mode=...
blocked_absurd_spread=...
blocked_classification_review=...
blocked_l2_not_ready=...
blocked_l3_not_ready=...
blocked_l4_not_ready=...
absurd_spread_bps_limit=250.00
main_blocker=...
ranking_runtime=false
selection_runtime=false
trade_permission=false
refresh_duration_ms=...
```

## Gateway relationship

Layer 5 does not require Gateway.

```text
gateway_required=false
calculation_owner=none_basic_gate_only
```

Gateway belongs to Runtime 3 and is reserved for calculation support. Layer 5 is a local MT5 foundation gate consuming L2-L4 owner packets.

## Closeout acceptance

Layer 5 source is acceptable only when:

```text
AC_Config.mqh build phase says runtime1_layer5_basic_system_gate or later
AC_LAYER_5_NAME says Layer 5 - Basic System Gate
AC_BasicSystemGate.mqh is active
old Runtime 5 advisory owner is retired or compatibility-only
Market Board prints BASIC SYSTEM GATE
Dossier prints per-symbol gate_status and gate_reason
Workbench prints L5_BASIC_SYSTEM_GATE
Diagnostics no longer presents Layer 5 as advisory/friction/volatility/session/structure
Runtime 3 remains Gateway/calculation support only
```

Operational acceptance still requires MetaEditor compile and live output proof.
