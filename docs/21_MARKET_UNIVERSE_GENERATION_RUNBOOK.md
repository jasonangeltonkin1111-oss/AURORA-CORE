# AURORA CORE - MARKET UNIVERSE GENERATION RUNBOOK

**System:** AURORA CORE  
**Purpose:** Generate and commit the Runtime 2 symbol-universe row include from the workbook using direct Git/filesystem access.  
**Status:** Runbook only. No generated universe rows are committed by this document.

---

## 0. Current State

The repo currently has:

```text
docs/20_SYMBOL_UNIVERSE_IMPORT_CONTRACT.md
tools/generate_market_universe_rows.py
mt5/runtime_owners/runtime_2_market_universe_taxonomy_lookup/AC_MarketUniverse.mqh
docs/market_universe_generation_audit.json
```

The repo does not yet have:

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

Selection Desk route contract is stable:

```text
Selection Desk/Groups/
Selection Desk/Global/
Selection Desk/Selection Index.txt
```

Rank numbers, Top-N labels, cycle IDs, and selection metadata belong inside child files or `Selection Index.txt`, not in parent folder names.

---

## 1. Required Source Workbook

Use this workbook:

```text
Aurora_Bucket_System_Hierarchy_EA_READY_PUBLIC_RESEARCH_FIXED.xlsx
```

Required sheet:

```text
EA Export Safe
```

The workbook must be the same source referenced by:

```text
docs/20_SYMBOL_UNIVERSE_IMPORT_CONTRACT.md
docs/market_universe_generation_audit.json
```

Do not use an older workbook, temporary export, renamed run file, or sheet with old bucket-only labels unless it has been audited and intentionally promoted.

---

## 2. Generation Command

From the repository root, place the workbook at a known local path outside or inside the repo.

Example if the workbook is outside the repo:

```bash
python tools/generate_market_universe_rows.py \
  "/path/to/Aurora_Bucket_System_Hierarchy_EA_READY_PUBLIC_RESEARCH_FIXED.xlsx"
```

Example if the workbook is placed under a local-only input folder:

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

The generator must fail if counts do not match:

```text
total_rows=1703
strict_rank_allowed_rows=1294
public_research_rank_allowed_rows=224
review_only_rows=184
blocked_rows=1
```

If any count differs, do not patch around it.

Instead, stop and audit:

```text
source workbook identity
source sheet name
header row
blank/duplicate broker_symbol rows
strict_rank_allowed/public_research_rank_allowed fields
review_lane values
blocked row identity
```

---

## 4. Required Generated Include Properties

The generated include must be:

```text
mt5/runtime_owners/runtime_2_market_universe_taxonomy_lookup/AC_MarketUniverseRows.mqh
```

It must contain:

```text
AC_UNIVERSE_GENERATED_ROW_COUNT = 1703
AC_UNIVERSE_GENERATED_STRICT_RANK_ALLOWED = 1294
AC_UNIVERSE_GENERATED_PUBLIC_RESEARCH_RANK_ALLOWED = 224
AC_UNIVERSE_GENERATED_REVIEW_ONLY = 184
AC_UNIVERSE_GENERATED_BLOCKED = 1
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

## 5. Required Runtime 2 Follow-Up Patch After Rows Land

After `AC_MarketUniverseRows.mqh` is committed, patch `AC_MarketUniverse.mqh` to include it and switch diagnostics from skeleton-only to generated-copy mode.

Expected direction:

```mql5
#include "AC_MarketUniverseRows.mqh"
```

Then update the Runtime 2 count functions so they return generated constants:

```mql5
AC_UniverseLoadedRowCount() -> AC_UNIVERSE_GENERATED_ROW_COUNT
AC_UniverseStrictRankAllowedCount() -> AC_UNIVERSE_GENERATED_STRICT_RANK_ALLOWED
AC_UniversePublicResearchRankAllowedCount() -> AC_UNIVERSE_GENERATED_PUBLIC_RESEARCH_RANK_ALLOWED
AC_UniverseReviewOnlyCount() -> AC_UNIVERSE_GENERATED_REVIEW_ONLY
AC_UniverseBlockedCount() -> AC_UNIVERSE_GENERATED_BLOCKED
AC_UniverseRowsGenerated() -> true
```

Do not change Selection Desk routes.

Do not add FileIO ownership to Runtime 2.

Do not add ranking, scoring, selection, signal, alert, strategy, or execution logic.

---

## 6. Compile Risk Sniff Before MetaEditor

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

The generated file is expected to be large. If MetaEditor rejects the switch/string layout, do not force it.

Fallback design must preserve one Runtime 2 owner and may use smaller chunked include files only if source inspection proves the single include is not compile-safe.

---

## 7. MetaEditor Compile Acceptance

Compile target:

```text
mt5/AuroraCore.mq5
```

Required claim after compile:

```text
compiler-passed or compiler-failed
```

Do not claim:

```text
runtime working
file-output observed
EA ready
trade ready
prop-firm ready
edge proven
```

Compile success proves only build compatibility.

---

## 8. Runtime Smoke Acceptance

After compile, attach/run in MT5 and verify output files publish.

Required smoke observations:

```text
Runtime Status.txt exists
Workbench/Status.txt exists
Workbench/Diagnostics.txt exists
Workbench/Manifest.txt exists
Selection Desk/Groups/_PLACEHOLDER.txt exists
Selection Desk/Global/_PLACEHOLDER.txt exists
Selection Desk/Selection Index.txt exists
```

Diagnostics must show:

```text
source_row_count_expected=1703
loaded_row_count=1703
strict_rank_allowed_count=1294
public_research_rank_allowed_count=224
review_only_count=184
blocked_count=1
old_field_names_active=false
runtime_permission=LOOKUP_ONLY_NOT_TRADE_PERMISSION
ranking_group_runtime=false
selection_logic_runtime=false
trade_permission=false
```

---

## 9. Rollback Plan

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

## 10. Forbidden Outcomes

Do not allow:

```text
broker_symbol alone as global lookup key
public_research_rank_allowed treated as strict broker truth
old major_bucket/minor_bucket/aggregation_group as active EA-facing authority
Runtime 2 owning FileIO or routes
Selection Desk folder renamed away from Groups / Global / Selection Index.txt
rank numbers, Top-N labels, or cycle IDs becoming parent folder names
row count mismatch hidden or patched around
compile success sold as runtime proof
runtime placeholder sold as ranking/selection proof
trade permission or prop-firm readiness claimed
```

---

## 11. Decision Gate

Current state before running this runbook:

```text
generator_script_landed
runtime2_skeleton_landed
rows_not_committed
not_compiler_passed
not_runtime_smoked
```

After running this runbook successfully, the next valid state is only:

```text
generated_rows_committed
runtime2_counts_wired
compiler_pending
runtime_smoke_pending
trade_permission=false
```

Decision remains:

```text
TEST FIRST
```
