# AURORA RUNTIME 4 / LAYER 8 GUIDEBOOK

## Runtime 4 identity

Runtime 4 is the Surface Scoring Owner.

Runtime 4 owns:

```text
Layer 6 - Cost / Friction Ranking
Layer 7 - Session Relevance Ranking
Layer 8 - Movement / Range Ranking
Layer 9 - Structure / Location Geometry
```

Runtime 4 is not Runtime 1. Runtime 1 owns foundation truth and Layer 5 eligibility.

Runtime 4 is not Runtime 3. Runtime 3 is Gateway transport/support.

Runtime 4 is not the Publication/FileIO/Route owner.

## Layer 8 purpose

Layer 8 answers:

```text
Of the symbols that passed Layer 5, which symbols currently have useful movement/range quality?
```

Layer 8 does not answer:

```text
buy or sell
trade now
trend direction
breakout confirmed
strategy edge
permission
execution
```

High movement score means inspect-worthy surface behavior. It does not mean profitable, validated, or tradeable.

## Future liquidity-room support note

Layer 8 movement/range output may later support deeper liquidity and risk-geometry layers by helping them judge whether a mapped liquidity level has enough movement room to matter.

Allowed future support examples:

```text
current range expansion
compression
range stability
recent movement quality
```

This future support remains descriptive context only. It must not become setup logic.

Layer 8 may help later layers ask:

```text
Does this symbol currently have enough movement/range quality for a liquidity level to be worth inspecting?
```

Layer 8 must not answer:

```text
liquidity swept, sell now
Asian high swept, buy/sell now
breakout confirmed
reversal confirmed
continuation confirmed
entry valid
```

Liquidity mapping, risk geometry, target room, invalidation distance, spread-to-stop ratio, and expected R after cost belong later to selected deep evidence / permission layers, not to Layer 8.

## Non-negotiable ranking law

Layer 5 is the only broad all-symbol hard gate.

Layer 8 must not re-block Layer 5 pass symbols.

Every Layer 5 pass symbol should appear in Layer 8 output as one of:

```text
ranked
ranked_degraded
not_rankable_quality
insufficient_history
flat_or_compressed
```

Avoid for Layer 8 pass-set symbols:

```text
blocked
excluded
rejected
removed
trade_permission
signal
entry
```

Symbols that failed Layer 5 can display `not_ranked_l5_gate_failed` in Dossiers, but Layer 8 does not own that block.

## Layer 8 source inputs

Layer 8 consumes existing upstream truth:

```text
Layer 2 market state
Layer 3 symbol specs
Layer 4 quote freshness/spread truth
Layer 5 gate result
Layer 6 friction/cost score
Layer 7 session context
```

Layer 8 may request small, bounded history windows from MT5, but it must not become an all-symbol deep evidence layer.

Deep selected OHLC evidence belongs later to Layer 18.

## Official MT5 basis

MT5 source side may use:

```text
CopyRates
MqlRates
CopyHigh / CopyLow / CopyClose if needed later
iATR + CopyBuffer only if bounded and released safely
```

CopyRates returns historical MqlRates bars for a symbol/timeframe/count request and may return partial data or -1 while history is downloading/building.

Indicator handles such as iATR must be treated as resources: failed handles are invalid, buffers must be copied through CopyBuffer, and handles should be released when no longer needed.

## First-build scope

First build must be intentionally small.

Preferred first Layer 8 implementation:

```text
Input set: Layer 5 pass symbols only
Timeframes: M5, M15, H1
Bar windows: small bounded fixed counts
Output: movement/range ranking sidecar only
No strategy claims
No trade permission
No deep all-symbol OHLC packs
```

Do not start with M1/M5/M15/M30/H1/H4/D1/W1 full packs. That belongs to selected evidence later.

## Core metrics

Layer 8 owns:

```text
range_5m
range_15m
range_60m
range_day
movement_score
compression_score
expansion_score
movement_quality_score
range_stability_score
history_quality
movement_rank
movement_rank_confidence
```

Recommended first-build fields:

```text
symbol
upstream_key
l5_gate_status
l6_cost_score
l7_session_relevance_score
m5_bars_requested
m5_bars_copied
m15_bars_requested
m15_bars_copied
h1_bars_requested
h1_bars_copied
range_m5_points
range_m15_points
range_h1_points
range_day_points
range_m5_to_spread_ratio
range_m15_to_spread_ratio
range_h1_to_spread_ratio
compression_score
expansion_score
range_stability_score
movement_quality_score
movement_rank
rank_state
confidence
reason
```

## Range formula primitives

For a window of bars:

```text
window_high = max(high)
window_low = min(low)
range_points = (window_high - window_low) / point
```

Spread-normalized movement:

```text
range_to_spread_ratio = range_points / max(spread_points, 1 safe unit)
```

Use zero-spread carefully:

```text
zero spread can be valid if quote freshness supports it
zero spread must not auto-reject and must not auto-grant quality
```

If spread is zero and fresh, use a documented safe denominator and set a zero_spread_state field.

## Compression / expansion model

First-build compression should be descriptive, not predictive.

Possible simple model:

```text
short_range = range_m5_points or range_m15_points
medium_range = range_h1_points
compression_ratio = short_range / max(medium_range, safe denominator)
```

Expansion can compare current short range to a recent average short range if enough bars are present.

Do not claim:

```text
compression will break out
expansion confirms direction
low compression means buy/sell soon
```

## Quality rules

A symbol can rank degraded when:

```text
bars copied below minimum
history returned partial data
point <= 0
spread missing or stale
range is zero
range denominator degraded
session relevance unavailable
```

Degraded does not mean hidden. It means visible with reason.

## MT5 / Gateway split

Preferred split:

```text
MT5 owns upstream truth and history collection limits
MT5 writes Layer 8 input snapshot for Layer 5 pass symbols
Gateway validates snapshot identity/checksum
Gateway calculates ranking/sorting/scoring
Gateway writes ranked output + manifest
MT5 validates result identity/staleness/checksum
MT5 renders Board/Dossier/Workbench sections
```

Python/Gateway must not call broker APIs and must not invent history that MT5 did not supply.

## Performance law

Layer 8 must not overload OnTimer.

Rules:

```text
bounded symbols per pass
bounded bars per symbol
no unbounded CopyRates loops
no full-universe deep OHLC packs
no per-tick recalculation
no blocking waits for history downloads
publish degraded states when data is not ready
```

If history is missing/downloading, mark `insufficient_history` and retry later. Do not stall the heartbeat.

## Publication surfaces

Board should show compact summary only:

```text
Layer 8 status
input symbols
ranked symbols
ranked_degraded
insufficient_history
best movement quality symbols count
worst blocker/reason
manifest/result age
```

Dossier should show per-symbol detail:

```text
movement rank
rank state
movement quality score
range M5/M15/H1/day
range-to-spread ratios
compression/expansion/range stability
history quality
reason
trade permission false
```

Workbench/Diagnostics should show deep counters and failures.

## Validation and falsifiers

Layer 8 is accepted only when:

```text
compile passes
Layer 5 pass count equals Layer 8 input count
all Layer 5 pass symbols appear in Layer 8 output
closed symbols remain not-ranked because L5 failed, not because L8 blocked them
history failures are visible and bounded
no trade permission fields become true
runtime does not overload heartbeat
```

Cheapest falsifier:

```text
Run during weekend crypto-only session.
Layer 8 input should be the Layer 5 pass crypto set only.
Forex/stocks must not enter Layer 8 because Layer 5 blocks closed market.
Every eligible crypto must either rank or show insufficient_history/degraded with reason.
```

## Decision law

Layer 8 can proceed to first implementation only after this guidebook is accepted and the current Layer 6/Layer 7 contracts are not broken.

Default decision before runtime proof:

```text
TEST FIRST
```