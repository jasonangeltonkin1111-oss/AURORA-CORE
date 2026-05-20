# AURORA CORE — RUNTIME 0 — GOVERNANCE / INTERNAL CONTROL OWNER SOURCE PLAN AND TESTS

**System:** AURORA CORE  
**Runtime Owner:** Runtime 0 — Governance / Internal Control Owner  
**Status:** FIRST SOURCE PLANNING GATE — no `.mq5` or `.mqh` implementation yet.

---

## 0. Purpose

This file defines the real first MT5 source slice for AURORA CORE.

Before Aurora collects account truth, scans symbols, ranks markets, or builds any layer under Runtime 1–8, it must prove that the EA can:

```text
start
create the account-safe folder tree
write files through the approved publication owner
publish manifest / telemetry / status proof
heartbeat safely
report failure honestly
```

Core law:

```text
Runtime 0 — Governance / Internal Control Owner comes before Layer 1 — Account / Portfolio / Prop Rule Truth.
The first coding slice proves the EA can create folders and write truthful files.
Only after Runtime 0 prints and proves itself may Runtime 1 Layer 1 begin.
```

---

## 1. Why Runtime 0 Must Come First

Layer 1 — Account / Portfolio / Prop Rule Truth depends on file writing, folder routing, heartbeat, telemetry, manifest proof, and diagnostics.

Those are not Layer 1 responsibilities.

They belong to Runtime 0 — Governance / Internal Control Owner and Runtime 7 — Publication Owner.

Therefore:

```text
Do not start Layer 1 — Account / Portfolio / Prop Rule Truth until Runtime 0 proves folder creation and FileIO publication.
```

---

## 2. Mandatory Reads Before Coding Runtime 0

Before implementing Runtime 0 — Governance / Internal Control Owner, read:

```text
README.md
control/00_SUPER_INDEX_RUN_ROUTER.md
control/00_MUST_READ_INDEX.md
control/05_DECISION_STATE_REGISTER.md
docs/15_ANTI_DRIFT_SOURCE_OF_TRUTH_GUIDEBOOK.md
blueprint/04_BUILD_PHASE_BLUEPRINT.md
blueprint/07_FILEIO_ROUTE_OWNERSHIP_CONTRACT.md
blueprint/08_MT5_SOURCE_FOLDER_CONTRACT.md
governance/schemas/01_MINIMUM_GOVERNANCE_SCHEMA_CONTRACTS.md
research/mt5_official_docs/00_MT5_OFFICIAL_DOCS_INDEX.md
research/validation_methods/00_VALIDATION_METHODS_INDEX.md
mt5/02_SEED_SENTINEL_INHERITANCE_AUDIT.md
```

No Runtime 0 worker may start from memory alone.

---

## 3. Runtime 0 Layer Set

Runtime 0 — Governance / Internal Control Owner owns:

```text
Layer 0.1 — Startup / Runtime Identity
Layer 0.2 — Scheduler / Heartbeat / Breathing Spine
Layer 0.3 — Decision State and Runtime Modes
Layer 0.4 — Governance / Manifest / Telemetry
Layer 0.5 — Diagnostics / Errors / Recovery
```

These are internal EA layers.

They are not trader-facing market layers.

---

## 4. First Runtime 0 Source Slice

The first source slice may include only:

```text
mt5/AuroraCore.mq5
mt5/core/AC_Config.mqh
mt5/core/AC_CommonTypes.mqh

mt5/runtime_owners/runtime_0_governance_internal_control/
  layer_0_1_startup_runtime_identity/AC_RuntimeIdentity.mqh
  layer_0_2_scheduler_heartbeat_breathing/AC_Heartbeat.mqh
  layer_0_4_governance_manifest_telemetry/AC_GovernanceRows.mqh

mt5/runtime_owners/runtime_7_publication_owner/
  publication_fileio/AC_FileIO.mqh
  publication_routes/AC_ServerPaths.mqh
```

Layer 0.3 and Layer 0.5 folders/files may wait unless the first implementation truly needs them.

Do not create future Runtime Owner folders just to show the full tree.

---

## 5. Allowed Scope

Runtime 0 first source may include:

```text
EA OnInit / OnTimer / OnDeinit shell
EventSetTimer / EventKillTimer setup and teardown
runtime identity fields
heartbeat counter
timer started/finished timestamps
timer duration measurement
account-safe root path builder using server/account labels when available
folder creation for root and Workbench
test write to Account Status or Runtime Status surface
manifest row builder
runtime telemetry row builder
owner status row builder for Runtime 0
layer status rows for Runtime 0 layers
FileIO temp-to-final or verified-write pattern
diagnostics text for FileIO failures
```

---

## 6. Forbidden Scope

Runtime 0 first source must not include:

```text
Layer 1 — Account / Portfolio / Prop Rule Truth account capture beyond minimal route labels needed for folder safety
Layer 2 — Market Open / Closed Truth
Layer 3 — Symbol + Broker Specs Truth
Layer 4 — Market Watch Truth
Layer 5 — Basic System Gate
symbol universe scanning
ranking
bucket logic
selection
selected evidence
alerts
strategy
trade execution
external worker implementation
```

If any of these appear, the run defaults to HOLD / TEST FIRST.

---

## 7. Allowed MQL5 Function Families

Runtime 0 first source may use:

```text
OnInit
OnTimer
OnDeinit
EventSetTimer
EventKillTimer
GetTickCount / GetMicrosecondCount if used for duration
TimeCurrent / TimeLocal / TimeGMT with honest labels
TerminalInfoString / TerminalInfoInteger for terminal path/connection/context
AccountInfoInteger / AccountInfoString only for route labels such as login/server/currency/company where needed
FileOpen
FileWrite / FileWriteString
FileFlush
FileClose
FileMove
FileIsExist
FileSize
FolderCreate
GetLastError
ResetLastError
```

AccountInfo* use in Runtime 0 must stay limited to identity/routing support.

Full account truth belongs later to Layer 1 — Account / Portfolio / Prop Rule Truth.

---

## 8. Output Route Goal

The first source slice should prove this shape:

```text
Aurora Core/<SERVER>/<ACCOUNT_NUMBER>/
  Runtime Status.txt
  Workbench/Manifest.txt
  Workbench/Status.txt
  Workbench/Diagnostics.txt
```

This route shape is inherited conceptually from Seed's account-safe routing, but Core uses its own names and contract.

If server/account labels are unavailable, print honest degraded labels rather than hiding output.

---

## 9. Minimum Runtime 0 Proof Rows

Runtime 0 first source must write or prepare:

```text
manifest row for Runtime Status.txt
runtime telemetry row
Runtime 0 owner status row
Layer 0.1 — Startup / Runtime Identity status row
Layer 0.2 — Scheduler / Heartbeat / Breathing Spine status row
Layer 0.4 — Governance / Manifest / Telemetry status row
```

Layer status rows must use full semantic names.

Do not write only `Layer 0.1` without the proper name.

---

## 10. Runtime Status Fields

Minimum `Runtime Status.txt` content:

```text
system_name
runtime_owner = Runtime 0 — Governance / Internal Control Owner
runtime_state
build_phase
heartbeat_id
generated_at
terminal_connected
route_root
folder_create_status
fileio_status
manifest_status
telemetry_status
owner_status
layer_0_1_startup_runtime_identity_status
layer_0_2_scheduler_heartbeat_breathing_status
layer_0_4_governance_manifest_telemetry_status
file_publication_blocked
degraded_reason
blocked_reason
next_allowed_step
```

`next_allowed_step` after Runtime 0 passes should be:

```text
Layer 1 — Account / Portfolio / Prop Rule Truth source planning / implementation
```

---

## 11. Failure / Degraded States

Required states:

```text
runtime_identity_missing
terminal_context_unavailable
account_route_label_unavailable
folder_create_failed
temp_file_open_failed
temp_write_failed
flush_failed
move_to_final_failed
final_verify_failed
manifest_write_failed
telemetry_write_failed
owner_status_write_failed
layer_status_write_failed
heartbeat_over_budget
runtime_status_partial
runtime_status_printed_degraded
```

Failure must print if physically possible.

Do not hide broken Runtime 0 truth by making expected files disappear.

---

## 12. Compile Test

After Runtime 0 source is created or changed, compile proof requires:

```text
compiled file path
MetaEditor/compiler output
error count
warning count
timestamp
```

Compile success proves syntax/basic build compatibility only.

It does not prove runtime publication.

---

## 13. Runtime Smoke Test

Runtime smoke proof requires generated outputs/logs showing:

```text
EA initialized
Timer heartbeat executed
account-safe folder root attempted
Runtime Status.txt attempted
Workbench/Manifest.txt attempted
Workbench/Status.txt attempted
Workbench/Diagnostics.txt attempted
manifest row produced
runtime telemetry produced
Runtime 0 owner status produced
Runtime 0 layer status rows produced
no Layer 1 — Account / Portfolio / Prop Rule Truth account capture beyond route labels
no symbols/ranking/buckets/alerts/strategy/external-worker logic
```

No generated files/logs = no runtime proof.

---

## 14. Negative Tests

Minimum negative cases:

```text
folder creation failure path is visible
FileOpen invalid handle is visible
FileMove/final verification failure is visible
manifest write failure is visible
telemetry write failure is visible
heartbeat over-budget state is visible
route label unavailable state is visible
```

Expected result:

```text
failure state prints where physically possible
file_publication_blocked true only for physical FileIO/route failures
review/trading remains blocked
no fake clean state
```

---

## 15. Acceptance Criteria

Runtime 0 — Governance / Internal Control Owner first source implementation may be accepted only if:

```text
source scope stays inside Runtime 0 and Runtime 7 publication support
proper folder structure is used
Runtime Status.txt prints or failure is visibly reported
Workbench/Manifest.txt prints or failure is visibly reported
Workbench/Status.txt prints or failure is visibly reported
Workbench/Diagnostics.txt prints or failure is visibly reported
runtime telemetry exists
owner/layer status rows exist
FileIO follows approved route owner pattern
compile proof exists after source creation
runtime smoke proof exists before runtime readiness is claimed
no Layer 1+ market/account truth logic appears beyond routing labels
```

---

## 16. Next Step After Runtime 0 Passes

Only after Runtime 0 — Governance / Internal Control Owner compiles, runs, creates folders, prints files, and proves its own status may the system proceed to:

```text
Layer 1 — Account / Portfolio / Prop Rule Truth
```

---

## 17. Final Runtime 0 Law

```text
Before Aurora knows the market, Aurora must prove it can breathe, create its home, write its truth, and report its own failures.
```