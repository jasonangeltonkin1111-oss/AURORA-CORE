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

## Active bridge truth

Current active render/source path is:

```text
mt5/AuroraCore.mq5
-> runtime_owners/runtime_7_publication_owner/publication_renderers/AC_PublicationRenderers.mqh
-> runtime_owners/runtime_1_foundation_truth_owner/shared_ohlc_raw_storage/AC_SharedOhlcActiveBridge.mqh
```

`AC_SharedOhlcPublicationContract.mqh` and the truncated compatibility shim `AC_SharedOhlcPubli` must delegate to the same active bridge. They must not promote V6/V7 or another bridge without an explicit migration, MetaEditor compile proof, and MT5 runtime proof.

## Source files

| file | role | status | notes |
|---|---|---|---|
| `AC_SharedOhlcContracts.mqh` | contracts/constants/timeframe set/status structs | source-present | Defines raw-storage boundaries and priority classes. |
| `AC_SharedOhlcState.mqh` | owner state/counters/status rows | source-present | Tracks seed/append status only; no calculations. |
| `AC_SharedOhlcCodec.mqh` | compact lossless row encoding | source-present | Encodes price as integer points for storage; no market features. |
| `AC_SharedOhlcOwner.mqh` | modular owner API for init, priority, seed helper, board/dossier/workbench sections | source-present-scaffold | Contains CopyRates access for raw storage; not the active render bridge unless explicitly wired and compile-proven. |
| `AC_SharedOhlcQueues.mqh` | seed/append queue cursor policy | source-present-scaffold | Queue order only; no ranking, scoring, selection, or permission. |
| `AC_SharedOhlcManifest.mqh` | status/manifest file text and writes | source-present-scaffold | Storage-owner proof only. |
| `AC_SharedOhlcRawStorage.mqh` | dispatcher include for modular owner modules | source-present-scaffold | Include after routes/FileIO/L5 state are available; do not assume active runtime path without compile/include proof. |
| `AC_SharedOhlcActiveBridge.mqh` | current active Shared OHLC bridge | active-source | Owns current active raw CopyRates/MqlRates storage service, priority-window/status surfaces, and Board/Dossier/Workbench render sections. No calculations, scoring, selection, permission, or execution. |
| `AC_SharedOhlcPublicationContract.mqh` | stable publication/compatibility compile-read contract | active-contract | Must delegate to `AC_SharedOhlcActiveBridge.mqh`; no CopyRates or storage scheduling logic belongs in the contract. |
| `AC_SharedOhlcLegacyAliases.mqh` | compatibility aliases for renamed L8 fast-window counters | source-present | Alias only; no state ownership. |
| `AC_SharedOhlcSurface.mqh` | modular lazy surface wrappers | source-present-scaffold | Not the active bridge path unless explicitly wired and compile-proven. |
| `AC_SharedOhlcPubli` | truncated-include compatibility shim | active-compatibility-shim | Delegates to `AC_SharedOhlcPublicationContract.mqh`; exists only because a compile path referenced the truncated name. Must not gain logic. |

## Route dependency

Shared OHLC server-level routes live in:

```text
mt5/runtime_owners/runtime_7_publication_owner/publication_routes/AC_SharedOhlcRoutes.mqh
```

The route module is only a Publication/FileIO/Route Service extension. It does not own OHLC truth.

## Publication dependency

Runtime 7 renderers and compatibility shims must resolve to the active Shared OHLC bridge through:

```text
mt5/runtime_owners/runtime_1_foundation_truth_owner/shared_ohlc_raw_storage/AC_SharedOhlcPublicationContract.mqh
```

`AC_SharedOhlcPubli` is a compatibility shim only. It must not gain logic.

## Future-layer law

Future layers must consume this owner. They must not create private OHLC retrieval/caches.

```text
Layer 18 = selected OHLC bar display/pack later, not raw source authority.
Layer 19 = candle geometry calculations later, not raw source authority.
Layer 21 = indicator/reference calculations later, not raw source authority.
Gateway/EXE = calculation support only; may read shared raw files but may not fetch broker history directly.
```

## Current implementation gate

This source set does not claim MetaEditor compile proof, runtime proof, complete all-symbol seed, append-only runtime proof, or performance proof.

Next validation must compile first, then use runtime output to prove whether the active bridge contract/shim is sufficient or whether another real include-order issue remains.
