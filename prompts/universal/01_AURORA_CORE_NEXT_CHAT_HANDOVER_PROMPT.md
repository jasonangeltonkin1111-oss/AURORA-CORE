# AURORA CORE — NEXT CHAT HANDOVER PROMPT

Copy this into a fresh chat when this chat becomes too full.

---

```text
AURORA CORE — CONTINUE FROM GIT, NOT MEMORY

You are continuing AURORA CORE from the GitHub repository:
https://github.com/jasonangeltonkin1111-oss/AURORA-CORE

RUN MODE
Start in AUDIT / DEBUG / PATCH mode unless the user explicitly changes scope.

MANDATORY FIRST READ
Read these first from Git:
- README.md
- control/01_CURRENT_SOURCE_TRUTH_MAP.md
- control/00_MUST_READ_INDEX.md
- control/00_SUPER_INDEX_RUN_ROUTER.md
- control/05_DECISION_STATE_REGISTER.md
- control/02_MASTER_REPO_FILE_INDEX.md
- docs/00_AURORA_CORE_MAIN_PAGE_GUIDEBOOK.md
- docs/01_AURORA_CORE_HANDOFF_CONTINUITY_GUIDEBOOK.md
- docs/15_ANTI_DRIFT_SOURCE_OF_TRUTH_GUIDEBOOK.md
- prompts/workers/00_WORKER_PROMPTS_INDEX.md

For the current Runtime 0 source/debug lane, also read:
- blueprint/02_RUNTIME_OWNER_BLUEPRINT.md
- blueprint/03_LOGICAL_LAYER_BLUEPRINT.md
- blueprint/04_BUILD_PHASE_BLUEPRINT.md
- blueprint/07_FILEIO_ROUTE_OWNERSHIP_CONTRACT.md
- blueprint/08_MT5_SOURCE_FOLDER_CONTRACT.md
- governance/schemas/01_MINIMUM_GOVERNANCE_SCHEMA_CONTRACTS.md
- research/mt5_official_docs/00_MT5_OFFICIAL_DOCS_INDEX.md
- research/validation_methods/00_VALIDATION_METHODS_INDEX.md
- mt5/00_RUNTIME0_GOVERNANCE_INTERNAL_CONTROL_SOURCE_PLAN_AND_TESTS.md
- mt5/02_SEED_SENTINEL_INHERITANCE_AUDIT.md

Then inspect current source files:
- mt5/AuroraCore.mq5
- mt5/core/AC_Config.mqh
- mt5/core/AC_CommonTypes.mqh
- mt5/runtime_owners/runtime_0_governance_internal_control/layer_0_1_startup_runtime_identity/AC_RuntimeIdentity.mqh
- mt5/runtime_owners/runtime_0_governance_internal_control/layer_0_2_scheduler_heartbeat_breathing/AC_Heartbeat.mqh
- mt5/runtime_owners/runtime_0_governance_internal_control/layer_0_4_governance_manifest_telemetry/AC_GovernanceRows.mqh
- mt5/runtime_owners/runtime_7_publication_owner/publication_routes/AC_ServerPaths.mqh
- mt5/runtime_owners/runtime_7_publication_owner/publication_fileio/AC_FileIO.mqh

CURRENT LOCKED TRUTH
- Guidebooks: COMPLETE — 16 / 16
- Runtime 0 — Governance / Internal Control Owner is the first source target.
- Runtime 7 — Publication Owner is allowed only as FileIO/routes support for Runtime 0.
- Runtime 1 Layer 1 account truth source exists (read-only snapshot); no trading permission.
- External worker implementation is HOLD.
- Directional alerts are HOLD.
- Setup strategy layer is QUARANTINE.
- Auto-trading is BLOCKED.
- Trading edge claim is UNPROVEN.

CURRENT SOURCE STATE
Source exists in active MT5 owners with limited scope; acceptance still requires compile/runtime evidence for new source edits.

Evidence state:
- Source exists in Git: YES
- Compile proof: PENDING
- Runtime proof: PENDING
- File output proof: PENDING
- Manifest proof: PENDING

LATEST COMPILE/DEBUG HISTORY
Jason compiled and showed missing include failures from AuroraCore.mq5.
The root include style <AURORA-CORE/mt5/...> was wrong for his terminal layout because MetaEditor was already compiling from inside:
MQL5/Include/AURORA-CORE/mt5/

Latest patch changed mt5/AuroraCore.mq5 back to main-file relative quoted includes:
#include "core/AC_Config.mqh"
#include "core/AC_CommonTypes.mqh"
#include "runtime_owners/runtime_7_publication_owner/publication_routes/AC_ServerPaths.mqh"
#include "runtime_owners/runtime_7_publication_owner/publication_fileio/AC_FileIO.mqh"
#include "runtime_owners/runtime_0_governance_internal_control/layer_0_1_startup_runtime_identity/AC_RuntimeIdentity.mqh"
#include "runtime_owners/runtime_0_governance_internal_control/layer_0_2_scheduler_heartbeat_breathing/AC_Heartbeat.mqh"
#include "runtime_owners/runtime_0_governance_internal_control/layer_0_4_governance_manifest_telemetry/AC_GovernanceRows.mqh"

Latest version string (check source, do not trust prompt memory):
#property version "0.019"

NEXT REQUIRED ACTION
Ask the user for the next compile output after the latest patch, or if they already provided it, debug only those compiler-reported errors.

If compile passes, do Runtime 0 runtime smoke only:
Verify files print under the MT5 Files/Common Files location used by the EA:
- Aurora Core/<SERVER>/<ACCOUNT_NUMBER>/Runtime Status.txt
- Aurora Core/<SERVER>/<ACCOUNT_NUMBER>/Workbench/Manifest.txt
- Aurora Core/<SERVER>/<ACCOUNT_NUMBER>/Workbench/Status.txt
- Aurora Core/<SERVER>/<ACCOUNT_NUMBER>/Workbench/Diagnostics.txt

WORKER CHAIN LAW
Every serious run must follow:
1. READ
2. RESEARCH using official/current sources where facts matter
3. TRANSLATE RESEARCH into constraints/tests/no-go rules
4. INSPECT CURRENT SOURCE / FILES
5. PATCH / CREATE only what earns its place
6. DEBUG / STATIC AUDIT after changes
7. REPORT with evidence, unproven items, and next step

Research that does not change constraints/tests/no-go rules is decoration.
A run is not complete at file creation.
A run is complete only after post-change audit.

NO-GO RULES
Do not:
- claim compile proof without compiler output
- claim runtime proof without generated files/logs
- move to Runtime 1 before Runtime 0 passes
- add symbols, quotes, ranking, buckets, alerts, strategy, external worker, or trade execution during Runtime 0
- create duplicate FileIO or route owners
- create broad source scaffolds for future Runtime Owners
- create empty-folder spam
- use generic memory instead of official docs/current source
- invent a helper when an existing owner exists

SEED / SENTINEL INHERITANCE
Seed and Sentinel are evidence, not authority.
Adopt from Seed only the proven useful patterns: account-safe routing concept, central path owner, verified FileIO / last-good concept, print-truth / degraded-publication law.
Adopt from Sentinel only runtime-law scars: heartbeat/breathing/lane law, no hidden ownership, source-of-truth hierarchy, failure honesty.
Do not copy Seed/Sentinel bloat.

FINAL DECISION STATE
TEST FIRST.
Runtime 0 source exists but must compile and runtime-smoke before acceptance.
```
