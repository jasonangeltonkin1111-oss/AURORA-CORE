# 25 SHARED OHLC RAW STORAGE OWNER

## Purpose
Define the single raw OHLC storage source owner used by all future Aurora layers.

This owner is a raw market-history warehouse. It stores broker/server symbol-timeframe bars from MT5 and publishes storage availability truth. It does not calculate, score, rank, select, permit, execute, or interpret.

## Source owner

```text
Owner: Runtime 1 support service - Shared OHLC Raw Storage Owner
Scope: server-level raw OHLC storage
Route scope: Aurora Core/<server>/Shared Market Data/OHLC Store/
Account scope: none for raw bars
```

OHLC belongs to broker/server/symbol/timeframe truth. Account-level layers may consume it, but they do not own it.

## Official MQL5 basis

The MT5-side raw source is `CopyRates()` returning `MqlRates` rows. `MqlRates` contains period start time, open, high, low, close, tick volume, spread, and real volume. `CopyRates()` may return fewer bars while history is still downloading/building, so the owner must publish partial/pending/unavailable truth instead of claiming fake completion.

## Owns

- `CopyRates()` access for Aurora raw OHLC storage.
- Raw `MqlRates` capture only.
- Symbol + timeframe + bar-open-time identity.
- Server-level raw history cache.
- Initial all-symbol/all-configured-timeframe seed.
- Post-seed append-only refresh queue.
- Storage manifest, status, and indexes.
- Partial/pending/unavailable/error status.
- Machine-readable compact lossless row format.

## Does not own

- Range calculations.
- Wick/body calculations.
- ATR, moving averages, VWAP, indicators, or reference packs.
- Trend, volatility, structure, session, liquidity, or scoring.
- Ranking, selection, baskets, alerts, permission, execution, or prop-rule clearance.
- Gateway result acceptance.
- Board/Dossier rendering authority.
- FileIO authority.

## Future-layer law

```text
Layers must not call CopyRates for normal layer work.
Layers must not create private OHLC caches.
Layers must read raw OHLC through Shared OHLC Raw Storage Owner contracts.
Heavy calculations from OHLC may be done by Gateway/EXE only when a layer owns that calculation request.
Layer outputs may print only fields owned by that layer.
```

Layer 18 may later display selected OHLC bar packs, but it still consumes the shared raw store. Layer 19 may calculate candle geometry from shared raw bars. Layer 21 may calculate indicator/reference packs from shared raw bars. None of those layers becomes the raw OHLC source owner.

## Storage lifecycle

### Phase 1 - initial seed

On EA boot, the owner builds the raw warehouse by filling all symbols and configured timeframes in bounded slices. It publishes seed progress while filling. Initial seed must not block unrelated publication forever.

### Phase 2 - append-only mode

After seed completion, the owner appends only new closed bars. The current forming bar may be written separately because it mutates. Closed-bar history is permanent storage and should not be deleted by normal runtime.

## Refresh priority after seed

Priority controls update order only. It is not symbol filtering, scoring, or permission.

```text
P1 - symbols with open positions or pending orders
P2 - Layer 5 pass symbols
P3 - later candidate/ranked/selected symbols when they exist
P4 - other open symbols
P5 - closed, blocked, unknown, or low-priority symbols
```

All symbols remain eligible for long-term storage. Layer 5 pass/blocked state affects priority only.

## Raw format policy

Start with compact lossless text rows for auditability:

```text
bar_time,open_i,high_i,low_i,close_i,tick_volume,spread,real_volume
```

Prices are stored as integer points using the symbol point size. This is storage normalization, not trading calculation. Symbol metadata sidecars must include digits, point, and price scale so rows can be decoded exactly.

## Surface policy

Board may show only OHLC store overview: seed status, symbols tracked, pending backlog, append mode, and blocked=false publication truth.

Dossier may show only symbol OHLC availability/counts until a dedicated future layer owns raw bar display.

Workbench may show owner proof, paths, counters, timings, status, and queue/backlog details.

Raw bar files live only in the server-level shared OHLC folder.

## Acceptance checks

- No layer-owned private `CopyRates()` calls.
- No duplicate OHLC cache owners.
- No OHLC calculations inside the storage owner.
- Server-level storage route exists.
- Initial seed progress is status-visible.
- Append-only mode is separated from seed mode.
- Layer 5 affects refresh priority only.
- Board/Dossier do not dump raw bars.
- Gateway/EXE may calculate from raw files but may not own raw history retrieval.

## Decision gate

Implementation must start as TEST FIRST: compile-safe modules, no trading permission, no hidden scheduler overload, no broad rewrite, and no runtime completion claim without MT5 proof.
