# AURORA CORE - UNIVERSE TAXONOMY GUIDEBOOK

**System:** AURORA CORE  
**Role:** symbol universe model, taxonomy hierarchy, ranking_group contract, classification source discipline, unknown handling, and anti-random-classification law.  
**Status:** RUN020 current naming contract. Old broker-group/subgroup/aggregation wording is retired for active work.

---

## 0. Purpose

This guidebook prevents symbol-universe chaos.

It answers:

```text
What is this symbol?
What asset_class does it belong to?
What market_group does it belong to?
What market_segment does it belong to?
What ranking_group should the EA use for selection/caps/diversification later?
Is classification known, inferred, broker-provided, manual, cached, or unknown?
Is taxonomy stale?
What version classified it?
What universe hash was used?
```

Core law:

```text
Every symbol needs honest classification or honest unknown state.
```

---

## 1. Active Naming Contract

Use these exact active field names:

```text
asset_class
market_group
market_segment
ranking_group
symbol
```

Meaning:

```text
Asset Class -> Market Group -> Market Segment -> Symbol
Ranking Group = EA-safe selection/cap/diversification grouping field
```

Dead active names:

```text
major_bucket
minor_bucket
broker_group
broker_subgroup
aggregation_group
bucket_top5
sub_bucket_top5
Top 5 Per Bucket
```

These may appear only in historical notes or contradiction ledgers. They must not be used as active source fields, route names, operator-facing labels, or new workbook headers.

---

## 2. What This Guidebook Owns

This guidebook owns:

```text
symbol universe model
asset_class
market_group
market_segment
ranking_group
classification source
classification confidence
classification cache
taxonomy version
taxonomy engine version
universe hash
unknown handling
manual review state
classification freshness
symbol naming normalization
suffix/prefix handling
forex major/cross/exotic rules
metals rules
indices rules
commodities rules
crypto rules
stock/sector/theme support where relevant
```

---

## 3. What This Guidebook Must Not Own

This guidebook must not own:

```text
Global Top 10 final selection
correlation filtering
trade permission
surface scoring formulas
selected evidence collection
publication routes
strategy logic
```

Taxonomy tells what the symbol is.

Ranking Group tells how it should be grouped for later selection/cap/diversification logic.

Neither says whether to trade it.

---

## 4. Research Foundation

MQL5 exposes broker-side symbol metadata through `SymbolInfoInteger`, `SymbolInfoDouble`, and `SymbolInfoString`.

Official symbol properties include sector, industry, custom symbol flags, visibility, tick time, spread, trade calculation mode, trade mode, stops/freeze levels, volume min/max/step, contract size, tick values, and more.

Reference:

```text
https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants
```

MQL5 `SymbolInfoString()` retrieves symbol string properties such as base currency, profit currency, margin currency, description, path, and other broker-provided strings.

Reference:

```text
https://www.mql5.com/en/docs/marketinformation/symbolinfostring
```

Aurora translation:

```text
Broker metadata should be used when available.
Broker metadata is still broker-provided and may be incomplete or inconsistent.
Parser-derived taxonomy must be labelled as derived truth.
```

Professional equity frameworks such as GICS show that serious classification is hierarchical and versioned, but they are equity/company classification frameworks and must not be blindly applied to forex, metals, indices, crypto, or broker CFDs.

Aurora translation:

```text
Use hierarchy.
Do not force equity sector logic onto every asset class.
```

---

## 5. Core Taxonomy Law

```text
Raw symbol is broker truth.
Canonical symbol is derived truth.
Unknown is honest.
Fake Other is corruption.
```

No symbol should vanish because classification is incomplete.

Unknown classification should print and be tracked.

---

## 6. Symbol Universe Model

Symbol universe state should include:

```text
server
account
broker_file
broker_symbol
canonical_symbol
ea_lookup_key
taxonomy_lookup_key
symbols_total
symbols_seen
symbols_open
symbols_closed
symbols_unknown
symbol_universe_hash
taxonomy_engine_version
taxonomy_schema_version
classification_cache_status
```

The universe is broker/account-specific.

A classification cache from one broker/account must not silently apply to another.

---

## 7. Taxonomy Hierarchy

Base hierarchy:

```text
asset_class
  market_group
    market_segment
      symbol
```

Examples:

```text
asset_class=FX
market_group=Majors
market_segment=USD Cross
symbol=EURUSD
ranking_group=FX Majors / USD Crosses
```

```text
asset_class=Commodities
market_group=Metals
market_segment=Gold
symbol=XAUUSD
ranking_group=Metals / Gold
```

```text
asset_class=Crypto
market_group=Major Crypto
market_segment=Bitcoin
symbol=BTCUSD
ranking_group=Major Crypto / Bitcoin
```

```text
asset_class=Equities
market_group=Information Technology
market_segment=Semiconductors
symbol=NVDA
ranking_group=Information Technology / Semiconductors
```

Do not force every symbol to have equity sector/theme fields.

Non-equity symbols should use market-native groups and segments.

---

## 8. Ranking Group Contract

`ranking_group` is separate from `market_segment`.

It answers:

```text
Which EA-safe aggregation group should this symbol use for later ranking, caps, diversification, and selection controls?
```

Why separate it:

```text
Some market segments only contain 1-2 symbols.
Ranking every tiny segment separately creates fake diversification and unstable selection.
```

Rule:

```text
Store asset_class, market_group, and market_segment for classification truth.
Use ranking_group for selection/cap/diversification rules unless a later owner proves a narrower grouping is safe.
```

---

## 9. Classification Source Ladder

Classification sources:

```text
broker_metadata
symbol_path
symbol_description
symbol_name_parser
known_symbol_map
public_research_later
manual_review
unknown
```

General source priority:

```text
broker metadata may outrank parser
manual review may outrank parser if recorded
known symbol map may outrank fuzzy description
public research only if provenance recorded
unknown is allowed when evidence is insufficient
```

Every classification needs:

```text
classification_source
classification_confidence
classification_version
review_status
evidence_status
strict_rank_allowed
public_research_rank_allowed
review_lane
block_reason
```

---

## 10. Evidence and Confidence Labels

Classification confidence labels:

```text
unknown
low
medium
high
manual_verified
broker_verified
```

Do not use:

```text
guaranteed
perfect
certain
```

A parser-derived classification should not claim broker-verified status.

---

## 11. Raw Symbol vs Canonical Symbol

Symbol names are often polluted by broker suffixes/prefixes.

Examples:

```text
EURUSD
EURUSD.a
EURUSDm
EURUSD_pro
XAUUSD#
US30.cash
DE40
BTCUSD.r
```

Required fields:

```text
broker_symbol
canonical_symbol
ea_lookup_key
taxonomy_lookup_key
normalization_method
normalization_confidence
```

Normalization is derived truth.

Never hide the broker symbol.

---

## 12. Unknown Handling

Unknown is allowed.

Unknown must be visible.

Required unknown fields:

```text
classification_status=unknown
classification_confidence=unknown
unknown_reason
review_required=true
strict_rank_allowed=false
public_research_rank_allowed=false unless explicitly proven
```

No symbol may disappear merely because classification is incomplete.

---

## 13. Runtime Constraint

Taxonomy lookup must stay lightweight.

Do not rebuild taxonomy inside `OnTimer`.

Expected later design:

```text
prebuilt generated lookup rows
cache/version/hash checks
bounded runtime lookup
honest degraded state when lookup is missing or stale
```

Current status:

```text
Runtime 2 is skeleton / contract only unless generated rows are committed and compiled.
```

---

## 14. Selection Desk Relationship

Taxonomy does not own Selection Desk routes.

Selection Desk parent routes are:

```text
Selection Desk/Groups/
Selection Desk/Global/
Selection Desk/Selection Index.txt
```

Ranking Group Top-N content belongs later inside child files/indexes, not parent folder names.

---

## 15. Dossier Relationship

Dossiers keep stable status folders:

```text
Dossiers/
Dossiers/Open/
Dossiers/Closed/
Dossiers/Unknown/
```

Do not replace Dossier folders with taxonomy folders.

Taxonomy fields belong inside Dossier content, lookup rows, indexes, and metadata.

---

## 16. Decision

Use:

```text
asset_class -> market_group -> market_segment -> symbol
ranking_group = EA selection/cap/diversification grouping field
```

Do not revive old active names.

Decision default after taxonomy/source edits:

```text
TEST FIRST
```
