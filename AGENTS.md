# Aurora Core Agent Law

This repo is an MQL5 / MT5 trading-system codebase. Current source files outrank memory, screenshots, reports, prompts, and AI reasoning.

## Required repo flow

1. Fetch current branch, current commit, and target file SHA before editing.
2. Read this file before touching code.
3. Inspect the active Runtime Owner before changing behavior.
4. Patch the existing owner only. No duplicate owners, no V2 helpers, no shadow systems, no broad rewrites.
5. Preserve routes, filenames, and account-safe paths unless current source proves a change is required.
6. Keep trade permission false unless a later explicit trading-permission task provides sufficient evidence and firm rules.
7. Do not claim compile, runtime, live, edge, or prop-firm readiness without actual evidence.

If a connector only supports unsafe full-file replacement for a large owner file, stop and report:

`HOLD — use repo-native patch/Codex hunk editor. I inspected the owner but did not safely patch.`

## Runtime Owner boundaries

- Runtime 2 taxonomy authority lives in `mt5/runtime_owners/runtime_2_market_universe_taxonomy_lookup/AC_MarketUniverse*.mqh`.
- Runtime 1 Layer 3 broker symbol/spec metadata lives in `mt5/runtime_owners/runtime_1_foundation_truth_owner/layer_3_broker_symbol_specs_truth/AC_L3_*.mqh`.
- Runtime 7 publication wrappers live in `mt5/runtime_owners/runtime_7_publication_owner/publication_renderers/`.
- FileIO/path owners must stay single-owner systems.
- Dossiers display upstream truth; they must not become hidden truth owners.
- Broker metadata is advisory evidence only. Broker Country, Exchange, Sector, or Industry must not overwrite final bucket/ranking truth.

## Bucket research law

Online research is required when completing or repairing symbol buckets because corporate symbols, listings, sectors, and lifecycle states change. Use source tiers:

1. Official issuer pages, exchange pages, SEC filings, and primary company releases.
2. Reputable financial news/filing summaries for mergers, delistings, and ticker lifecycle changes.
3. Finance profiles only as cross-checks, not sole authority.
4. Broker metadata is advisory only and may be poisoned.

Every researched symbol row should capture:

- broker server
- broker file/export name
- broker symbol
- canonical ticker
- exchange/listing if known
- lifecycle state: active / acquired / delisted / renamed / stale-broker-symbol / unknown
- final broker group
- final aggregation group
- confidence
- evidence source note
- trade permission false

## Current researched symbol notes

Use these as prompts for verification, not as blind patch authority. Patch only after inspecting current rows.

- `BA` / `BA.x`: Boeing. Bucket target: `Industrials / Aerospace & Defense`. Boeing is an aerospace company with commercial airplanes, defense/space/security, and services segments. Current patched row should remain Industrials / Aerospace & Defense.
- `JPM` / `JPM.x`: JPMorgan Chase. Bucket target: `Financial / Banks - Diversified` unless the project standard uses a more precise major-bank aggregation group.
- `UNH` / `UNH.x`: UnitedHealth Group. Bucket target: `Healthcare / Healthcare Plans` unless the project standard uses managed healthcare.
- `HOLX`: Hologic. Bucket target: `Healthcare / Medical Devices` or `Healthcare / Diagnostics & Research` depending on existing taxonomy vocabulary. It is a women’s health medical technology/diagnostics company; do not classify as entertainment, consumer electronics, or generic unknown.
- `TPH`: Tri Pointe Homes. Bucket target: `Consumer Cyclical / Residential Construction` or existing equivalent. It is a U.S. homebuilder. If Sumitomo Forestry acquisition completion is confirmed in runtime date context, lifecycle may become acquired/delisted/stale-broker-symbol.
- `CTRA`: Coterra Energy. Historical bucket target: `Energy / Oil & Gas E&P` or equivalent. Current lifecycle must be checked: Devon/Coterra merger news indicates the symbol may become acquired/merged/stale. Do not treat missing CTRA as automatically a publication bug if the symbol lifecycle is no longer active.
- `.xhkg` numeric HK symbols: broker Country `USA` / `United States` and Exchange `XNYM` are poisoned for trader-facing Dossiers. Hide from Dossier, count in Workbench diagnostics, and build external Yahoo symbol as zero-padded `.HK` where applicable: `1.xhkg -> 0001.HK`, `23.xhkg -> 0023.HK`, `27.xhkg -> 0027.HK`, `101.xhkg -> 0101.HK`, `1024.xhkg -> 1024.HK`.

## Bucket-system acceptance checks

Before claiming bucket completion, verify or explicitly report missing proof for:

- current generated row count and runtime Dossier count
- missing symbols and explicit lifecycle/source reason for each
- extra symbols count
- Unknown bucket count and reason for every unknown
- Ranking Group mismatch vs taxonomy authority count
- JPM, UNH, BA regression probes
- HOLX, TPH, CTRA lifecycle/bucket probes
- `.xhkg` Country USA / Exchange XNYM hidden from trader-facing Dossiers
- `.xhkg` zero-padded `.HK` external links
- no ISIN display in trader-facing Dossiers
- no `Not available` metadata filler in trader-facing Dossiers
- closed-symbol wording separates static specs from live quote/tick truth
- trade permission remains false

## Required final report

Every serious repo run must report:

- branch and current commit
- files inspected
- files changed
- active owner map
- what changed and why
- verification performed
- verification missing
- duplicate-owner / V2 / shadow-system scan result
- regression risk
- rollback path
- final decision: `PROCEED`, `HOLD`, `KILL`, or `TEST FIRST`
