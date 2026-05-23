# 00 SHARED OHLC RAW STORAGE SOURCE INDEX

## Purpose
Source-local index for the Shared OHLC Raw Storage Owner modules.

## Owner

```text
Runtime 1 support service: Shared OHLC Raw Storage Owner
Authority: raw MT5 MqlRates / OHLCV storage only
Route scope: Aurora Core/<server>/Shared Market Data/OHLC Store/
```

This folder is not a ranking, scoring, indicator, strategy, permission, or execution owner.

## Source files

| file | role | status | notes |
|---|---|---|---|
| `AC_SharedOhlcContracts.mqh` | contracts/constants/timeframe set/status structs | source-present | Defines raw-storage boundaries and priority classes. |
| `AC_SharedOhlcState.mqh` | owner state/counters/status rows | source-present | Tracks seed/append status only; no calculations. |
| `AC_SharedOhlcCodec.mqh` | compact lossless row encoding | source-present | Encodes price as integer points for storage; no market features. |
| `AC_SharedOhlcOwner.mqh` | owner API for init, priority, seed helper, workbench section | source-present | Contains CopyRates access for raw storage; not yet scheduler-activated for full universe seed. |

## Route dependency

Shared OHLC server-level routes live in:

```text
mt5/runtime_owners/runtime_7_publication_owner/publication_routes/AC_SharedOhlcRoutes.mqh
```

The route module is only a Publication/FileIO/Route Service extension. It does not own OHLC truth.

## Future-layer law

Future layers must consume this owner. They must not create private OHLC retrieval/caches.

```text
Layer 18 = selected OHLC bar display/pack later, not raw source authority.
Layer 19 = candle geometry calculations later, not raw source authority.
Layer 21 = indicator/reference calculations later, not raw source authority.
Gateway/EXE = calculation support only; may read shared raw files but may not fetch broker history directly.
```

## Current implementation gate

This run creates source modules and route contracts. It does not claim MetaEditor compile proof, runtime proof, complete all-symbol seed, append-only runtime proof, or performance proof.

Next run must compile first, then activate a bounded seed scheduler slice only after compile success.
