# AURORA CORE - MARKET UNIVERSE GENERATION RUNBOOK

**System:** AURORA CORE  
**Purpose:** Generate and commit the Runtime 2 symbol-universe row include from the workbook using direct Git/filesystem access.  
**Status:** Runbook only. No generated universe rows are committed by this document.

---

## 0. Current State

Current repo has the Runtime 2 skeleton and generator, but does **not** yet have:

```text
mt5/runtime_owners/runtime_2_market_universe_taxonomy_lookup/AC_MarketUniverseRows.mqh
```

Runtime 2 currently reports:

```text
loaded_row_count=0
translation_contract_status=skeleton_only_rows_not_imported
runtime_permission=LOOKUP_ONLY_NOT_TRADE_PERMISSION
ranking_group_runtime=false
selection_logic_runtime=false
trade_permission=false
```

Selection Desk route contract remains stable:

```text
Selection Desk/Groups/
Selection Desk/Global/
Selection Desk/Selection Index.txt
```

Rank numbers, Top-N labels, cycle IDs, and selection metadata belong inside child files or `Selection Index.txt`, not in parent folder names.

---

## 1. Required Source Workbook

Use:

```text
Aurora_Bucket_System_Hierarchy_EA_READY_PUBLIC_RESEARCH_FIXED.xlsx
EA Export Safe
```

Do not use an older workbook, temporary export, renamed run file, or sheet with old bucket-only labels unless it has been audited and intentionally promoted.

---

## 2. Generation Command

From repository root:

```bash
python tools/generate_market_universe_rows.py \
  "local_inputs/Aurora_Bucket_System_Hierarchy_EA_READY_PUBLIC_RESEARCH_FIXED.xlsx"
```

Expected generated files:

```text
mt5/runtime_owners/runtime_2_market_universe_taxonomy_lookup/AC_MarketUniverseRows.mqh
docs/market_universe_generation_audit.json
```

---

## 3. Hard Count Acceptance Gate

The generator must fail if source counts before operator omit do not match:

```text
source_row_count=1703
source_strict_rank_allowed_rows=1294
source_public_research_rank_allowed_rows=224
source_review_only_rows=184
source_blocked_rows=1
source_review_or_blocked_rows=185
source_duplicate_primary_key_count=0
```

The generator must fail if generated counts after operator omit do not match:

```text
generated_row_count=1649
operator_omit_count=54
generated_strict_rank_allowed_rows=1261
generated_public_research_rank_allowed_rows=211
generated_review_only_rows=176
generated_blocked_rows=1
generated_review_or_blocked_rows=177
generated_duplicate_primary_key_count=0
```

Definitions:

```text
review_only_rows = rows where review_lane starts with REVIEW_ONLY
blocked_rows = rows where review_lane equals BLOCKED_NOT_RANKABLE
review_or_blocked_rows = review_only_rows + blocked_rows
primary_key = server|broker_file|broker_symbol
operator_omit_set = visible dead/unusable symbols from MT5 screenshot evidence
```

If any count differs, stop and audit the workbook identity, source sheet, header row, omit set, rank gates, review lanes, primary keys, and blocked row identity.

---

## 4. Required Generated Include Properties

The generated include must contain:

```text
AC_UNIVERSE_GENERATED_SCHEMA_VERSION
AC_UNIVERSE_ROW_SCHEMA
AC_UNIVERSE_SOURCE_FILE_SHA256
AC_UNIVERSE_HEADER_SHA256
AC_UNIVERSE_ROW_SCHEMA_SHA256
AC_UNIVERSE_OPERATOR_OMIT_SET_SHA256
AC_UNIVERSE_LOOKUP_KEY_SCHEMA
AC_UNIVERSE_SOURCE_ROW_COUNT = 1703
AC_UNIVERSE_GENERATED_ROW_COUNT = 1649
AC_UNIVERSE_OPERATOR_OMIT_COUNT = 54
AC_UNIVERSE_GENERATED_STRICT_RANK_ALLOWED = 1261
AC_UNIVERSE_GENERATED_PUBLIC_RESEARCH_RANK_ALLOWED = 211
AC_UNIVERSE_GENERATED_REVIEW_ONLY = 176
AC_UNIVERSE_GENERATED_BLOCKED = 1
AC_UNIVERSE_GENERATED_REVIEW_OR_BLOCKED = 177
AC_UNIVERSE_GENERATED_DUPLICATE_PRIMARY_KEYS = 0
AC_UniverseGeneratedRow(index)
```

It must remain lookup-only:

```text
not ranking runtime
not selection runtime
not trade permission
not edge proof
not prop-firm readiness
```

---

## 5. Required Audit JSON Properties

`docs/market_universe_generation_audit.json` must contain:

```text
source_counts.source_row_count=1703
generated_counts.generated_row_count=1649
generated_counts.operator_omit_count=54
source_file_sha256
header_sha256
row_schema_sha256
operator_omit_set_sha256
lookup_key_schema=server|broker_file|broker_symbol
first_generated_broker_symbol
last_generated_broker_symbol
runtime_permission=LOOKUP_ONLY_NOT_TRADE_PERMISSION
ranking_runtime=false
selection_runtime=false
trade_permission=false
prop_firm_readiness=false
```

This audit JSON is not compile proof or runtime proof. It only proves the generator completed against the local workbook source and wrote expected files.

---

## 6. Required Runtime 2 Follow-Up Patch After Rows Land

After `AC_MarketUniverseRows.mqh` is committed, patch `AC_MarketUniverse.mqh` to include it and switch diagnostics from skeleton-only to generated-copy mode.

Expected direction:

```mql5
#include "AC_MarketUniverseRows.mqh"
```

Then Runtime 2 count functions must return generated constants:

```text
AC_UniverseLoadedRowCount() -> AC_UNIVERSE_GENERATED_ROW_COUNT
AC_UniverseStrictRankAllowedCount() -> AC_UNIVERSE_GENERATED_STRICT_RANK_ALLOWED
AC_UniversePublicResearchRankAllowedCount() -> AC_UNIVERSE_GENERATED_PUBLIC_RESEARCH_RANK_ALLOWED
AC_UniverseReviewOnlyCount() -> AC_UNIVERSE_GENERATED_REVIEW_ONLY
AC_UniverseBlockedCount() -> AC_UNIVERSE_GENERATED_BLOCKED
AC_UniverseRowsGenerated() -> true
```

Runtime 2 diagnostics must expose:

```text
source_file_sha256
header_sha256
row_schema_sha256
operator_omit_set_sha256
lookup_key_schema
source_row_count=1703
loaded_row_count=1649
operator_omit_count=54
review_or_blocked_count=177
duplicate_primary_key_count=0
```

Do not change Selection Desk routes. Do not add FileIO ownership to Runtime 2. Do not add ranking, scoring, selection, signal, alert, strategy, or execution logic.

---

## 7. Compile and Runtime Proof Gates

Before compiling, inspect for:

```text
include path typo
missing AC_MarketUniverseRows.mqh
function name collision
string literal too long risk
switch body size risk
MQL5 compile memory/size limits
old field names becoming active authority
FileIO/path ownership drift
Selection Desk route drift
```

Compile target:

```text
mt5/AuroraCore.mq5
```

Compile success proves build compatibility only.

Runtime smoke must verify expected files physically publish and Workbench diagnostics show:

```text
source_row_count=1703
loaded_row_count=1649
operator_omit_count=54
strict_rank_allowed_count=1261
public_research_rank_allowed_count=211
review_only_count=176
blocked_count=1
review_or_blocked_count=177
duplicate_primary_key_count=0
old_field_names_active=false
runtime_permission=LOOKUP_ONLY_NOT_TRADE_PERMISSION
ranking_group_runtime=false
selection_logic_runtime=false
trade_permission=false
```

---

## 8. Rollback Plan

If generation is bad:

```text
delete AC_MarketUniverseRows.mqh
revert Runtime 2 include/count patch
restore AC_MarketUniverse.mqh to skeleton-only loaded_row_count=0
update docs/market_universe_generation_audit.json with failure reason
```

If compile fails because generated include is too large:

```text
keep generator script
remove generated include from active compile path
record compile failure
create chunked-generation plan
no runtime/trading claims
```

---

## 9. Forbidden Outcomes

Do not allow:

```text
broker_symbol alone as global lookup key
public_research_rank_allowed treated as strict broker truth
old major_bucket/minor_bucket/aggregation_group as active EA-facing authority
Runtime 2 owning FileIO or routes
Selection Desk folder renamed away from Groups / Global / Selection Index.txt
rank numbers, Top-N labels, or cycle IDs becoming parent folder names
row count mismatch hidden or patched around
source/header/schema/operator-omit hashes missing from audit
compile success sold as runtime proof
runtime placeholder sold as ranking/selection proof
trade permission or prop-firm readiness claimed
```

---

## 10. Decision Gate

Current state before running this runbook:

```text
generator_script_landed
operator_omit_control_landed_54
runtime2_skeleton_landed
rows_not_committed
not_compiler_passed
not_runtime_smoked
```

After running this runbook successfully, the next valid state is only:

```text
generated_rows_committed_1649
runtime2_counts_wired
compiler_pending
runtime_smoke_pending
trade_permission=false
```

Decision remains:

```text
TEST FIRST
```
