# AURORA CORE — HANDOFF & CONTINUITY GUIDEBOOK

**System:** AURORA CORE  
**Role:** Continuity spine, restart protocol, current decision snapshot, source-state handoff, compile/debug ledger, and next-chat guide.  
**Status:** ACTIVE HANDOFF — must be read at the start of any new Aurora Core chat.

---

## 0. Purpose

This guidebook lets a new chat continue AURORA CORE without relying on chat memory.

It records:

```text
current repo truth
active control files
current source files
what is locked
what is stale/held
what failed recently
what was patched
what must be tested next
what must not be built yet
how future runs must operate
```

A new chat must restart from Git and this handoff, not from memory.

---

## 1. Repository

```text
https://github.com/jasonangeltonkin1111-oss/AURORA-CORE
```

Active location rules:

```text
docs/ remains the active guidebook folder.
Guidebook migration to guidebooks/ is HOLD unless explicitly approved.
Runtime-generated MT5 output files do not belong in Git unless explicitly provided as evidence samples.
```

---

## 2. Mandatory First Read for a New Chat

A new chat must read these first:

```text
README.md
control/00_SUPER_INDEX_RUN_ROUTER.md
control/00_MUST_READ_INDEX.md
control/05_DECISION_STATE_REGISTER.md
docs/00_AURORA_CORE_MAIN_PAGE_GUIDEBOOK.md
docs/01_AURORA_CORE_HANDOFF_CONTINUITY_GUIDEBOOK.md
docs/15_ANTI_DRIFT_SOURCE_OF_TRUTH_GUIDEBOOK.md
prompts/workers/00_WORKER_PROMPTS_INDEX.md
```

Then, for the current source/debug lane, read:

```text
blueprint/02_RUNTIME_OWNER_BLUEPRINT.md
blueprint/03_LOGICAL_LAYER_BLUEPRINT.md
blueprint/04_BUILD_PHASE_BLUEPRINT.md
blueprint/07_FILEIO_ROUTE_OWNERSHIP_CONTRACT.md
blueprint/08_MT5_SOURCE_FOLDER_CONTRACT.md
governance/schemas/01_MINIMUM_GOVERNANCE_SCHEMA_CONTRACTS.md
research/mt5_official_docs/00_MT5_OFFICIAL_DOCS_INDEX.md
research/validation_methods/00_VALIDATION_METHODS_INDEX.md
mt5/00_RUNTIME0_GOVERNANCE_INTERNAL_CONTROL_SOURCE_PLAN_AND_TESTS.md
mt5/02_SEED_SENTINEL_INHERITANCE_AUDIT.md
```

Then inspect current MT5 source files listed below.

---

## 3. Current Locked Decision State

```text
Guidebook overview set: COMPLETE — 16 / 16
Super Index / Run Router: ACTIVE DRAFT AUTHORITY
Decision State Register: OPERATIONAL BUT MAY NEED STATUS SYNC
Runtime 0 — Governance / Internal Control Owner: FIRST SOURCE TARGET
Runtime 7 — Publication Owner: allowed only as FileIO/routes support for Runtime 0
Runtime 1 — Foundation Truth Owner: HOLD UNTIL RUNTIME 0 COMPILES AND RUNTIME-SMOKES
Layer 1 — Account / Portfolio / Prop Rule Truth: HOLD UNTIL RUNTIME 0 PASSES
External worker implementation: HOLD
Directional alerts: HOLD
Setup strategy layer: QUARANTINE
Auto-trading: BLOCKED
Trading edge claim: UNPROVEN
```

No future chat may upgrade HOLD / QUARANTINE / BLOCKED / UNPROVEN states without evidence.

---

## 4. Permanent Runtime Owner Structure

Runtime Owners are permanent top-level architecture/source headers.

```text
Runtime 0 — Governance / Internal Control Owner
Runtime 1 — Foundation Truth Owner
Runtime 2 — Surface Scoring Owner
Runtime 3 — Bucket Intelligence Owner
Runtime 4 — Basket Selection Owner
Runtime 5 — Selected Evidence Owner
Runtime 6 — Permission / Alert Owner
Runtime 7 — Publication Owner
Runtime 8 — Validation / Outcome Owner
```

Important correction:

```text
Runtime 0 comes before Runtime 1.
Layer 1 — Account / Portfolio / Prop Rule Truth is not the first EA source target.
Runtime 0 must first prove folder creation, FileIO, heartbeat, manifest, telemetry, owner status, layer status, and diagnostics.
```

---

## 5. Runtime 0 Internal Layers

Runtime 0 — Governance / Internal Control Owner owns:

```text
Layer 0.1 — Startup / Runtime Identity
Layer 0.2 — Scheduler / Heartbeat / Breathing Spine
Layer 0.3 — Decision State and Runtime Modes
Layer 0.4 — Governance / Manifest / Telemetry
Layer 0.5 — Diagnostics / Errors / Recovery
```

Current first implementation uses only:

```text
Layer 0.1 — Startup / Runtime Identity
Layer 0.2 — Scheduler / Heartbeat / Breathing Spine
Layer 0.4 — Governance / Manifest / Telemetry
Runtime 7 — Publication Owner support for FileIO/routes
```

---

## 6. Current MT5 Source Files

Current Runtime 0 source files exist in Git:

```text
mt5/AuroraCore.mq5
mt5/core/AC_Config.mqh
mt5/core/AC_CommonTypes.mqh

mt5/runtime_owners/runtime_0_governance_internal_control/
  layer_0_1_startup_runtime_identity/AC_RuntimeIdentity.mqh
  layer_0_2_scheduler_heartbeat_breathing/AC_Heartbeat.mqh
  layer_0_4_governance_manifest_telemetry/AC_GovernanceRows.mqh

mt5/runtime_owners/runtime_7_publication_owner/
  publication_routes/AC_ServerPaths.mqh
  publication_fileio/AC_FileIO.mqh
```

Current source intent:

```text
EA OnInit / OnTimer / OnDeinit shell
EventSetTimer / EventKillTimer
Runtime Status.txt
Workbench/Manifest.txt
Workbench/Status.txt
Workbench/Diagnostics.txt
account-safe route attempt
heartbeat duration / over-budget flag
manifest row
runtime telemetry row
Runtime 0 owner status row
Runtime 0 layer status rows
FileIO temp-to-final publication
```

Current forbidden source scope:

```text
Runtime 1 — Foundation Truth Owner
Layer 1 — Account / Portfolio / Prop Rule Truth
symbols
sessions
quotes
ranking
buckets
selection
deep evidence
alerts
strategy
external worker
trade execution
```

---

## 7. Current Compile / Debug State

Runtime 0 source has been created but is not accepted yet.

Evidence state:

```text
Source exists in Git: YES
Compile proof: PENDING
Runtime proof: PENDING
File output proof: PENDING
Manifest proof: PENDING
```

Recent compile failures provided by Jason showed:

```text
missing include files from AuroraCore.mq5
version format warning
undeclared identifier cascade caused by missing includes
```

Root cause found:

```text
The root include style <AURORA-CORE/mt5/...> was wrong for the actual terminal layout.
Jason's compiler was already inside MQL5/Include/AURORA-CORE/mt5/.
```

Latest patch changed `mt5/AuroraCore.mq5` back to main-file relative quoted includes:

```text
#include "core/AC_Config.mqh"
#include "core/AC_CommonTypes.mqh"
#include "runtime_owners/runtime_7_publication_owner/publication_routes/AC_ServerPaths.mqh"
#include "runtime_owners/runtime_7_publication_owner/publication_fileio/AC_FileIO.mqh"
#include "runtime_owners/runtime_0_governance_internal_control/layer_0_1_startup_runtime_identity/AC_RuntimeIdentity.mqh"
#include "runtime_owners/runtime_0_governance_internal_control/layer_0_2_scheduler_heartbeat_breathing/AC_Heartbeat.mqh"
#include "runtime_owners/runtime_0_governance_internal_control/layer_0_4_governance_manifest_telemetry/AC_GovernanceRows.mqh"
```

Latest version string:

```text
#property version "000.010"
```

Next required action:

```text
Recompile mt5/AuroraCore.mq5 after the latest include/version patch.
```

If compile still fails, treat new compiler output as highest evidence.

---

## 8. Official Research Anchors for Current Debug Lane

Current source/debug lane must use official MQL5 references where platform behavior matters:

```text
OnTimer / EventSetTimer / EventKillTimer
FileOpen / FileWriteString / FileFlush / FileClose / FileMove / FileIsExist / FileSize / FolderCreate
GetLastError / ResetLastError
TimeCurrent / GetTickCount
TerminalInfoInteger / TerminalInfoString
AccountInfoInteger / AccountInfoString only for route labels in Runtime 0
```

Runtime 0 research conclusions:

```text
Timer work must be bounded because timer events can be skipped if already queued/processing.
FileIO must be sandbox-aware.
Folder creation and FileIO cannot be assumed; they must be compiled, run, and verified.
FileFlush belongs at controlled publication boundaries, not hot loops.
FileMove must respect temp/final and overwrite behavior.
```

---

## 9. Worker Runtime Chain / GPT Work Chain

Every serious run must follow:

```text
1. READ
2. RESEARCH
3. TRANSLATE RESEARCH INTO CONSTRAINTS
4. INSPECT CURRENT SOURCE / FILES
5. PATCH / CREATE ONLY WHAT EARNS ITS PLACE
6. DEBUG / STATIC AUDIT AFTER CHANGES
7. REPORT WITH EVIDENCE, UNPROVEN ITEMS, AND NEXT STEP
```

Research that does not change constraints/tests/no-go rules is decoration.

A run is not complete at file creation.

A run is complete only after post-change audit.

---

## 10. Seed / Sentinel Inheritance Posture

Seed and Sentinel are evidence, not authority.

Adopt from Seed now:

```text
account-safe routing concept
central path owner pattern
verified FileIO / last-good concept
print-truth / degraded-publication law
```

Adopt from Sentinel now:

```text
heartbeat / breathing / lane law
no hidden ownership law
source-of-truth hierarchy once source exists
failure honesty law
```

Do not copy now:

```text
Seed broad include graph
Seed symbol universe
Seed account probe into Runtime 0
Seed Candidate Board
Seed Dossier bootstrap
Seed Selection Desk
Seed external worker bridge
Seed Layer 2/3/4 logic
Sentinel full complexity
```

Core is the new designed system.

---

## 11. Current Next Step

Immediate next step:

```text
Compile mt5/AuroraCore.mq5 in MetaEditor after latest patch.
```

Then:

```text
If compile fails: debug only the compiler-reported errors.
If compile passes: runtime-smoke Runtime 0 only.
```

Runtime smoke must verify these generated files physically exist under the MT5 Files/Common Files location used by the EA:

```text
Aurora Core/<SERVER>/<ACCOUNT_NUMBER>/Runtime Status.txt
Aurora Core/<SERVER>/<ACCOUNT_NUMBER>/Workbench/Manifest.txt
Aurora Core/<SERVER>/<ACCOUNT_NUMBER>/Workbench/Status.txt
Aurora Core/<SERVER>/<ACCOUNT_NUMBER>/Workbench/Diagnostics.txt
```

Only after Runtime 0 compiles, runs, prints, and is audited may work move to:

```text
Runtime 1 — Foundation Truth Owner / Layer 1 — Account / Portfolio / Prop Rule Truth
```

---

## 12. Critical No-Go Rules

Do not:

```text
claim compile proof without compiler output
claim runtime proof without generated files/logs
move to Runtime 1 before Runtime 0 passes
add symbols, quotes, ranking, buckets, alerts, strategy, external worker, or trade execution during Runtime 0
create duplicate FileIO or route owners
create broad source scaffolds for future Runtime Owners
create empty-folder spam
use generic memory instead of official docs/current source
invent a helper when an existing owner exists
```

---

## 13. Restart Prompt Pointer

For a copy/paste prompt, use:

```text
prompts/universal/01_AURORA_CORE_NEXT_CHAT_HANDOVER_PROMPT.md
```

If that prompt conflicts with this handoff guidebook, this handoff guidebook and current source files outrank the prompt.

---

## 14. Final Handoff Law

```text
Restart from Git, not memory.
Runtime 0 first.
Compile evidence outranks source intention.
Runtime output evidence outranks compile success.
No fake proof.
No duplicate owners.
No broad scaffold.
Print truth before market truth.
```
