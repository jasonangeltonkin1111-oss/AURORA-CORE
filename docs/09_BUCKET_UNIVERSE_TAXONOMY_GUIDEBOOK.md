# AURORA CORE — BUCKET UNIVERSE & TAXONOMY GUIDEBOOK

**System:** AURORA CORE  
**Role:** Symbol universe model, broker bucket hierarchy, taxonomy cache, classification source discipline, unknown handling, and anti-random-bucket law.  
**Status:** Overview guidebook foundation. Exact taxonomy maps may be refined later.

---

## 0. Purpose

This guidebook prevents symbol-universe chaos.

It answers:

```text
What is this symbol?
What broker group does it belong to?
What subgroup?
What aggregation group?
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

## 1. What This Guidebook Owns

This guidebook owns:

```text
symbol universe model
broker group
broker subgroup
aggregation group
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
asset class hierarchy
forex major/cross/exotic rules
metals rules
indices rules
commodities rules
crypto rules
stock/sector/theme rules
```

---

## 2. What This Guidebook Must Not Own

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

It does not say whether to trade it.

---

## 3. Research Foundation

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

GICS and ICB show that serious financial classification is hierarchical and versioned, but they are equity/company classification frameworks and must not be blindly applied to forex, metals, indices, crypto, or broker CFDs.

Reference:

```text
https://www.investopedia.com/articles/stocks/08/global-industry-classification-industrial-classification-benchmark.asp
```

ISO 10962 CFI is an instrument classification standard, showing the importance of instrument-type classification, but Aurora cannot assume MT5 brokers expose CFI.

Reference:

```text
https://en.wikipedia.org/wiki/ISO_10962
```

---

## 4. Core Taxonomy Law

```text
Raw symbol is broker truth.
Normalized symbol is derived truth.
Unknown is honest.
Fake Other is corruption.
```

No symbol should vanish because classification is incomplete.

Unknown classification should print and be tracked.

---

## 5. Symbol Universe Model

Symbol universe state should include:

```text
server
account
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

## 6. Broker Group / Subgroup / Aggregation Group

Base hierarchy:

```text
broker_group
broker_subgroup
aggregation_group
```

Examples:

```text
Currency
  forex.major
  forex.cross
  forex.exotic

Metals
  precious.metals
  industrial.metals

Indices
  us.indices
  eu.indices
  asia.indices

Energy
  oil
  gas

Crypto
  crypto.major
  crypto.alt

Stocks
  stock.us
  stock.eu
  stock.other
```

Optional fields for stocks:

```text
sector
industry
theme
```

Do not force every symbol to have sector/theme.

---

## 7. Classification Source Ladder

Classification sources:

```text
broker_metadata
symbol_path
symbol_description
symbol_name_parser
known_symbol_map
external_reference_later
manual_review
unknown
```

General source priority:

```text
broker metadata may outrank parser
manual review may outrank parser if recorded
known symbol map may outrank fuzzy description
external reference only if provenance recorded
unknown is allowed when evidence is insufficient
```

Every classification needs:

```text
classification_source
classification_confidence
classification_version
review_status
```

---

## 8. Evidence and Confidence Labels

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

## 9. Raw Symbol vs Normalized Symbol

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
raw_symbol
normalized_symbol
detected_prefix
detected_suffix
base_asset
quote_asset
contract_hint
broker_path
description
```

Rule:

```text
raw_symbol is always preserved.
normalized_symbol is derived.
derived classification must cite source and confidence.
```

---

## 10. Prefix / Suffix Handling

Prefix/suffix handling must be conservative.

Wrong:

```text
strip all non-letters and assume result is correct
```

Correct:

```text
preserve raw_symbol
derive normalized_symbol
record detected suffix/prefix
record parser confidence
fall back to unknown if uncertain
```

No parser may destroy broker truth.

---

## 11. Forex Classification Rules

Forex classification must be pair-structure based.

Fields:

```text
base_currency
quote_currency
currency_pair_type
major_currency_involved
is_usd_pair
is_cross
is_exotic
region_tags
```

Common major currencies:

```text
USD
EUR
GBP
JPY
CHF
CAD
AUD
NZD
```

Taxonomy versions must define exact major/cross/exotic rules.

Rule:

```text
Forex classification must be pair-structure based, not GICS-based.
```

---

## 12. Metals Classification Rules

Common metal hints:

```text
XAU
gold
XAG
silver
XPT
platinum
XPD
palladium
```

Group examples:

```text
Metals / precious.metals
Metals / industrial.metals
```

Do not classify metals as Currency merely because they are quoted against USD.

---

## 13. Indices Classification Rules

Common index hints:

```text
US30
DJ30
NAS100
US100
SPX500
US500
GER40
DE40
DAX
UK100
JP225
HK50
```

Group examples:

```text
Indices / us.indices
Indices / eu.indices
Indices / asia.indices
```

Broker path/description should be used when available.

---

## 14. Commodities Classification Rules

Commodity groups may include:

```text
Energy
Agriculture
Softs
Industrial Metals
Precious Metals
```

Energy hints:

```text
WTI
BRENT
UKOIL
USOIL
NGAS
```

Do not classify commodities by loose substring alone if broker metadata/path contradicts it.

---

## 15. Crypto Classification Rules

Crypto classification fields:

```text
crypto_base
quote_asset
crypto_pair_type
crypto_major_flag
crypto_alt_flag
```

Common crypto hints:

```text
BTC
ETH
SOL
XRP
BNB
ADA
DOGE
```

Rule:

```text
Crypto pair quoted in USD is not Forex.
```

---

## 16. Stocks / Sector / Industry / Theme Rules

Stocks may use:

```text
broker metadata sector
broker metadata industry
symbol path
description
external reference later
manual review
```

Optional classification:

```text
sector
industry
theme
```

Do not force sector/theme on non-stock instruments.

GICS/ICB may inform structure for equities, but they must not override broker truth without source/provenance.

---

## 17. Unknown / Other / Unsupported Distinction

States:

```text
classified
classified_degraded
unknown_pending
manual_review_required
unsupported_instrument
excluded_by_policy
```

Definitions:

```text
Unknown = classification not yet known.
Other = taxonomy intentionally defines a catch-all bucket.
Unsupported = instrument recognized but not handled.
```

Forbidden:

```text
silently assign Other
silently exclude unknown
pretend unknown is classified
```

Unknown is not failure if honest.

Fake classification is failure.

---

## 18. Classification Cache Contract

Taxonomy must not rebuild every heartbeat.

Cache key:

```text
server
account
taxonomy_engine_version
symbol_universe_hash
symbol_count
first_symbol
last_symbol
symbol_list_checksum
```

Cache row:

```text
raw_symbol
normalized_symbol
broker_group
broker_subgroup
aggregation_group
classification_source
classification_confidence
review_status
taxonomy_engine_version
classified_at
last_seen_at
```

---

## 19. Universe Hash Contract

Universe hash should represent the broker/account symbol universe.

Possible ingredients:

```text
server
account
symbol_count
first_symbol
last_symbol
sorted_symbol_list_checksum
taxonomy_schema_version
```

Universe hash is used to detect when classification cache may be stale.

---

## 20. Cache Invalidation Rules

Invalidate cache when:

```text
server changes
account changes
symbol universe hash changes
taxonomy engine version changes
manual cache clear
schema version changes
major symbol count/list change
```

Do not invalidate cache for:

```text
tick changes
quote changes
rank changes
spread changes
selection changes
heartbeat changes
```

Cache churn is runtime poison.

---

## 21. Manual Review State

Manual review fields:

```text
review_status
review_reason
reviewed_by
reviewed_at
manual_classification
manual_confidence
manual_notes
```

Manual review must be recorded.

Manual review must not become invisible memory.

---

## 22. Taxonomy Governance Contract

Governance should record:

```text
taxonomy_engine_version
taxonomy_schema_version
symbol_universe_hash
classified_count
unknown_count
manual_review_count
classification_cache_status
classification_degraded_count
```

Classification changes should be traceable.

---

## 23. No-Go Patterns

Do not allow:

```text
every unknown becomes Other
classification recalculates every heartbeat
broker suffix breaks forex detection
stocks get Forex bucket
metals get Currency bucket
crypto pair treated as forex
broker path ignored
manual review not recorded
taxonomy version changes without cache invalidation
raw symbol overwritten by normalized symbol
classification grants trade permission
```

---

## 24. Acceptance Criteria

This guidebook is acceptable if symbol universe truth becomes structured and auditable.

Acceptance criteria:

```text
Every symbol has classification or honest unknown state.
Raw broker symbol is preserved.
Normalized symbol is derived and labelled.
Classification source and confidence are recorded.
Taxonomy version is recorded.
Universe hash is recorded.
Cache does not rebuild every heartbeat.
Unknown is not silently converted to Other.
Broker metadata/path/description are used when available.
GICS/ICB/ISO patterns inform taxonomy but do not override broker truth.
No taxonomy state grants trade permission.
```

---

## 25. Final Taxonomy Law

```text
AURORA CORE must know what a symbol is before it ranks the symbol.
If it does not know, it must say unknown, not invent certainty.
```
