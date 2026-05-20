# AURORA CORE - SYMBOL UNIVERSE IMPORT CONTRACT

**System:** AURORA CORE  
**Owner direction:** Runtime 2 - Market Universe / Taxonomy Lookup Owner  
**Source workbook:** `Aurora_Bucket_System_Hierarchy_EA_READY_PUBLIC_RESEARCH_FIXED.xlsx`  
**Source sheet:** `EA Export Safe`  
**Status:** Import contract only. No symbol-universe runtime owner, generated EA copy, ranking logic, strategy, trade permission, or prop-firm readiness exists yet.

---

## 0. Purpose

This document defines how the broker symbol universe must be transferred from the workbook into the EA without reintroducing old bucket language, duplicate route owners, heavy timer work, or fake trade permission.

The future EA universe copy is a cached lookup surface.

It is not a strategy.

It is not a signal source.

It is not trade permission.

It is not prop-firm readiness.

---

## 1. Source Truth Order

Source truth order for the universe import:

```text
1. Current workbook sheet: EA Export Safe
2. Generated EA universe include / data file
3. MetaEditor compile output
4. MT5 runtime load diagnostics
5. MT5 file-output smoke proof
```

The workbook may classify symbols for lookup, but live tradability still requires runtime checks such as symbol availability, quote freshness, spread, margin, session state, risk rules, and prop-firm profile.

---

## 2. Professional Taxonomy Contract

The EA copy must use the active professional taxonomy names:

```text
asset_class
market_group
market_segment
ranking_group
symbol
```

Required meaning:

```text
asset_class    = broad universe lane, e.g. FX, Equities, Commodities, Indices, Crypto, Rates
market_group   = main market family or sector-style group
market_segment = precise classification detail
ranking_group  = EA-safe grouping used for ranking, caps, diversification, Top 5, and Global Top 10 logic
symbol         = canonical display symbol or canonical symbol identity
```

Retired active names:

```text
major_bucket
minor_bucket
aggregation_group
bucket_top5
sub_bucket_top5
```

These retired names may appear only as historical references or workbook legacy trace fields. They must not be generated as active EA-facing taxonomy field names, route names, or operator-facing publication labels.

---

## 3. Workbook Translation Rule

If the workbook contains legacy-style columns, the generated EA-facing copy must translate them into the professional contract.

Expected translation direction:

```text
broker_group / broad workbook grouping       -> asset_class or market_group, depending on row context
broker_subgroup / finer workbook grouping    -> market_segment, depending on row context
aggregation_group / old grouping field       -> ranking_group
broker_symbol                                -> broker_symbol
canonical_symbol                             -> canonical_symbol
```

No translation is allowed to silently erase the original source fields. If source fields are preserved for audit, they must be clearly labelled as source/legacy fields, not active runtime authority.

---

## 4. Broker-Safe Lookup Fields

Every imported row must preserve enough source identity to avoid symbol mixing across servers, accounts, exports, or broker naming variants.

Required broker/source fields:

```text
server
broker_file
broker_symbol
canonical_symbol
ea_lookup_key
```

The safest lookup key is:

```text
server|broker_file|broker_symbol
```

Never use `broker_symbol` alone as a global key.

If account is available in a later workbook/source, prefer:

```text
server|account|broker_file|broker_symbol
```

---

## 5. Permission and Evidence Gates

Every imported row must preserve ranking gate state.

Required gate/evidence fields:

```text
strict_rank_allowed
public_research_rank_allowed
review_lane
classification_confidence
evidence_rank
runtime_permission
block_reason
```

Gate meaning:

```text
strict_rank_allowed=YES
  Broker-confirmed or native workbook group lookup may feed strict ranking lookup.

public_research_rank_allowed=YES
  Public research classification may feed review/ranking candidate views only.
  It must not be treated as broker-confirmed truth.

review_lane=REVIEW_ONLY_* or BLOCKED_NOT_RANKABLE
  Must not enter strict ranking.
```

All imported rows remain lookup-only until later runtime owners prove more:

```text
runtime_permission=LOOKUP_ONLY_NOT_TRADE_PERMISSION
```

---

## 6. Expected Import Counts

Current expected counts from the source workbook sheet:

```text
total_rows=1703
strict_rank_allowed_rows=1294
public_research_rank_allowed_rows=224
review_only_rows=184
blocked_rows=1
```

These counts must be treated as acceptance targets for the generated EA copy.

If the generated EA copy does not match these counts, the import is degraded or failed until explained.

---

## 7. Future Runtime Owner Boundary

Runtime 2 Market Universe / Taxonomy Lookup Owner may own:

```text
cached symbol universe rows
row-count diagnostics
schema version
source workbook/sheet identity
lookup key schema
taxonomy naming translation proof
ranking gate metadata
lookup-only access helpers
```

Runtime 2 must not own:

```text
FileIO implementation
Selection Desk routes
Dossier routes
score formulas
Ranking Group Top 5 construction
Global Top 10 construction
trade permission
execution
prop-firm approval
```

Runtime 7 remains the route/FileIO owner.

Selection Desk remains:

```text
Selection Desk/Ranking Group Top 5/
Selection Desk/Global Top 10/
```

---

## 8. Lightweight Runtime Rule

The EA must not rebuild, research, or reclassify the symbol universe on every timer event.

Correct:

```text
load or compile cached lookup data
publish schema/count diagnostics
use lookup only when later ranking owners exist
```

Wrong:

```text
parse large workbook-style data inside OnTimer
research/reclassify symbols inside OnTimer
scan large files every heartbeat
turn public research rows into broker truth
```

---

## 9. Publication Law

Broken or incomplete taxonomy truth may block ranking, review, selection, trading, and permission.

It must not block physical publication if the route/FileIO/source object exists.

Expected behavior:

```text
publish diagnostics even when universe import is partial
label partial/degraded state honestly
include row counts and mismatch reasons
keep trade_permission=false
keep selection_logic_runtime=false until later owners exist
```

---

## 10. Import Acceptance Criteria

The import is acceptable only when all are true:

```text
EA copy contains 1703 rows.
EA copy exposes source_workbook and source_sheet identity.
EA diagnostics report row_count=1703.
Strict/public/review/blocked counts match source expectations.
Old major/minor/bucket naming is not used as active EA-facing taxonomy.
Selection Desk folder names remain Ranking Group Top 5 and Global Top 10.
No trade permission, edge, or prop-firm readiness is claimed.
MetaEditor compile proof is captured after import.
MT5 runtime smoke proves diagnostics/file publication after import.
```

---

## 11. Required Diagnostics After Import

The future Runtime 2 diagnostics should expose at minimum:

```text
universe_schema_version
source_workbook
source_sheet
source_row_count
loaded_row_count
strict_rank_allowed_count
public_research_rank_allowed_count
review_only_count
blocked_count
lookup_key_schema
translation_contract_status
old_field_names_active=false
runtime_permission=LOOKUP_ONLY_NOT_TRADE_PERMISSION
```

---

## 12. Falsifiers

Kill or hold the import if any of these happen:

```text
row_count does not match 1703 and no reason is logged
broker_symbol alone becomes the lookup key
old major_bucket/minor_bucket/aggregation_group becomes active EA-facing authority
public_research_rank_allowed rows are treated as broker-confirmed strict rows
Selection Desk routes are renamed away from Ranking Group Top 5 / Global Top 10
import adds FileIO or route ownership outside Runtime 7
import claims trading edge, execution permission, or prop-firm readiness
OnTimer does heavy universe parsing or classification
```

---

## 13. Current Decision State

Until the actual EA copy is generated, compiled, and runtime-smoked, the universe import status is:

```text
contract_created
source_workbook_identified
source_sheet_identified
not_generated_into_ea
not_compiler_passed
not_runtime_observed
not_selection_active
not_trade_permission
```

Decision:

```text
TEST FIRST
```
