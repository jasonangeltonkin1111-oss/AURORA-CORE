# MT5 Index

This folder is the Atlas Terminal source area for VERITAS ATLAS.

## Purpose

MT5 owns live broker/account/terminal truth, lightweight packet publication, Gateway handoff/acceptance, and foundation surface rendering.

## Folder rules

This folder may contain only:

```text
INDEX.md
GUIDELINES.md
MQL5 source/code files
source subfolders with their own INDEX.md and GUIDELINES.md
```

No reports, long plans, prompts, handoffs, screenshots, or extra markdown files belong here.

## Runtime owner scope

MT5 / Atlas Terminal owns:

```text
L0 Atlas Bench
L1 Atlas Surfaces
L2 Broker Account
L3 Symbol Universe
L4 Symbol Specs
L5 Market Watch
L6 OHLC Tick Feed
L7 Gateway Link
Atlas Vault final fail-closed state
```

## Must not own

MT5 must not own heavy Gateway analysis:

```text
friction/session/movement/structure/taxonomy/ranking/selection/deep evidence calculations
```

MT5 must not repeatedly read back every file, rewrite every layer, scan folders on the hot path, or recalculate Gateway intelligence.

## Required source subfolders

Create these only when implementation begins:

```text
l00_atlas_bench/
l01_atlas_surfaces/
l02_broker_account/
l03_symbol_universe/
l04_symbol_specs/
l05_market_watch/
l06_ohlc_tick_feed/
l07_gateway_link/
common/
io/
runtime/
vault/
```

Each subfolder must have exactly one `INDEX.md`, one `GUIDELINES.md`, and code/source files only.

## Current implementation truth

Blueprint only until source, compile, and runtime output prove implementation.
