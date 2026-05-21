# AURORA CORE - HANDOFF AND CONTINUITY GUIDEBOOK

**System:** AURORA CORE  
**Role:** continuity spine, restart protocol, current decision snapshot, source-state handoff, compile/debug ledger, and next-chat guide.  
**Status:** ACTIVE HANDOFF - must be read at the start of any new Aurora Core chat after README and the current source truth map.

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
control/01_CONTROL_GOVERNANCE.md is the current navigation bridge.
Runtime-generated MT5 output files do not belong in Git unless explicitly provided as evidence samples.
```

---

## 2. Mandatory First Read for a New Chat

A new chat must read these first, in order:

```text
README.md
control/01_CONTROL_GOVERNANCE.md
control/01_CONTROL_GOVERNANCE.md
control/01_CONTROL_GOVERNANCE.md
control/01_CONTROL_GOVERNANCE.md
docs/15_ANTI_DRIFT_SOURCE_OF_TRUTH_GUIDEBOOK.md
docs/00_AURORA_CORE_MAIN_PAGE_GUIDEBOOK.md
docs/01_AURORA_CORE_HANDOFF_CONTINUITY_GUIDEBOOK.md
```

Then read the relevant guidebook, blueprint, governance contract, research doc, and active MT5 source owner files for the task.

No serious run may proceed from memory alone.

---

## 3. Current Locked Decision State

```text
README.md: current repo-level direction
control/01_CONTROL_GOVERNANCE.md: current navigation and contradiction-prevention bridge
Super Index / Run Router: CURRENT ROUTER, must be read with current truth map
Decision State Register: operational but may still need status sync after source changes
Runtime 0: source exists, governance/status/manifest/diagnostics/micro-log support
Runtime 1 Layer 1: source exists, account truth snapshot only
Runtime 2: taxonomy/universe lookup skeleton or contract only unless generated row include exists
Runtime 7: source exists, FileIO/routes owner
Selection Desk: structure placeholders only, no selection runtime
Dossiers: Open/Closed/Unknown structure preserved
External worker implementation: HOLD / design-stage only
Directional alerts: HOLD
Setup strategy layer: QUARANTINE
Auto-trading: BLOCKED
Trading edge claim: UNPROVEN
```

No future chat may upgrade HOLD / QUARANTINE / BLOCKED / UNPROVEN states without evidence.

---

## 4. Current Source Truth Snapshot

Current active source files include:

```text
mt5/AuroraCore.mq5
mt5/core/AC_Config.mqh
mt5/core/AC_CommonTypes.mqh

mt5/runtime_owners/runtime_0_governance_internal_control/
  layer_0_1_startup_runtime_identity/AC_RuntimeIdentity.mqh
  layer_0_2_scheduler_heartbeat_breathing/AC_Heartbeat.mqh
  layer_0_4_governance_manifest_telemetry/AC_GovernanceRows.mqh

mt5/runtime_owners/runtime_1_foundation_truth_owner/
  layer_1_account_portfolio_prop_rule_truth/AC_AccountTruth.mqh

mt5/runtime_owners/runtime_2_market_universe_taxonomy_lookup/
  AC_MarketUniverse.mqh

mt5/runtime_owners/runtime_7_publication_owner/
  publication_routes/AC_ServerPaths.mqh
  publication_fileio/AC_FileIO.mqh
```

Current expected version/source identity should be checked in:

```text
mt5/AuroraCore.mq5
mt5/core/AC_Config.mqh
```

At the last continuity sync, the source direction was:

```text
Selection Desk stable parent routes
Dossiers Open/Closed/Unknown preserved
Taxonomy naming locked to asset_class / market_group / market_segment / ranking_group / symbol
```

Always inspect active source before trusting this prose.

---

## 5. Active Route Contracts

Dossiers stay:

```text
Dossiers/
Dossiers/Open/
Dossiers/Closed/
Dossiers/Unknown/
```

Do not replace Dossier folders with taxonomy folders.

Taxonomy fields belong inside Dossier content, lookup rows, indexes, and metadata.

Selection Desk stable parent routes:

```text
Selection Desk/
Selection Desk/Groups/
Selection Desk/Global/
Selection Desk/Selection Index.txt
```

Do not create Selection Desk parent folders named after Top-N ranks.

Future Top-N views belong inside child files/indexes, for example:

```text
Selection Desk/Groups/<ranking_group>.txt
Selection Desk/Global/Global Top 10.txt
Selection Desk/Selection Index.txt
```

Current Selection Desk state:

```text
structure placeholders only
ranking_group_runtime=false
selection_logic_runtime=false
trade_permission=false
```

---

## 6. Active Taxonomy Contract

Use these exact active names:

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
Ranking Group = EA selection/cap/diversification grouping field
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

These may appear only as historical notes or contradiction-ledger terms.

---

## 7. Runtime Owner Structure

Runtime Owners are permanent top-level architecture/source headers.

Current overview:

```text
Runtime 0 - Governance / Internal Control Owner
Runtime 1 - Foundation Truth Owner
Runtime 2 - Market Universe / Taxonomy Lookup Owner
Runtime 3 - Surface Scoring Owner
Runtime 4 - Selection / Basket Owner
Runtime 5 - Selected Evidence Owner
Runtime 6 - Permission / Alert Owner
Runtime 7 - Publication Owner
Runtime 8 - Validation / Outcome Owner
```

Runtime 0 currently owns:

```text
Layer 0.1 - Startup / Runtime Identity
Layer 0.2 - Scheduler / Heartbeat / Breathing Spine
Layer 0.4 - Governance / Manifest / Telemetry
```

Runtime 1 current source slice:

```text
Layer 1 - Account / Portfolio / Prop Rule Truth
read-only account status snapshot
trade_permission=blocked
prop_rule_status=not_configured
```

Runtime 2 current state:

```text
taxonomy/universe lookup skeleton or contract only unless generated rows are committed
```

Runtime 7 owns:

```text
folder routes
FileIO temp-to-final writes
account-safe root path support
publication support surfaces
```

---

## 8. Current Evidence State

Evidence must be rechecked every run.

General rules:

```text
Source inspection proves implementation shape only.
Compile proof requires MetaEditor output.
Runtime proof requires generated MT5 files/logs.
Placeholder files prove only structure publication.
Selection is attention, not permission.
```

After any source edit, the default decision is:

```text
TEST FIRST
```

---

## 9. Official Research Anchors

Use official MQL5 references where platform behavior matters:

```text
OnTimer / EventSetTimer / EventKillTimer
FileOpen / FileWriteString / FileFlush / FileClose / FileMove / FileIsExist / FileSize / FolderCreate
GetLastError / ResetLastError
TimeCurrent / GetTickCount
TerminalInfoInteger / TerminalInfoString
AccountInfoInteger / AccountInfoDouble / AccountInfoString
SymbolInfoInteger / SymbolInfoDouble / SymbolInfoString when Runtime 2+ source touches broker symbol truth
```

Runtime conclusions:

```text
Timer work must be bounded because timer events can be skipped if already queued/processing.
FileIO must be sandbox-aware.
Folder creation and FileIO cannot be assumed; they must be compiled, run, and verified.
FileFlush belongs at controlled publication boundaries, not hot loops.
FileMove must respect temp/final and overwrite behavior.
```

---

## 10. Worker Runtime Chain / GPT Work Chain

Every serious run must follow:

```text
1. READ
2. RESEARCH if facts/platform behavior may have changed or source docs are needed
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

## 11. Seed / Sentinel Inheritance Posture

Seed and Sentinel are evidence, not authority.

Adopt only with current-source compatibility proof.

Do not import Sentinel/Seed architecture blindly.

Do not use Seed naming as authority over current AURORA CORE contracts.

Current AURORA CORE contracts are held in:

```text
README.md
control/01_CONTROL_GOVERNANCE.md
control/01_CONTROL_GOVERNANCE.md
control/01_CONTROL_GOVERNANCE.md
docs/00_AURORA_CORE_MAIN_PAGE_GUIDEBOOK.md
docs/09_BUCKET_UNIVERSE_TAXONOMY_GUIDEBOOK.md
docs/10_SELECTION_BASKET_CONSTRUCTION_GUIDEBOOK.md
mt5/core/AC_Config.mqh
mt5/runtime_owners/runtime_7_publication_owner/publication_routes/AC_ServerPaths.mqh
```

---

## 12. Current No-Go Rules

Do not build or claim:

```text
real selection runtime
real Ranking Group Top-N output
real Global Top 10 output
strategy
alerts
external worker runtime
trade execution
prop-firm permission
edge
live readiness
```

Do not change:

```text
Dossiers/Open/Closed/Unknown layout
Selection Desk stable parent route model
FileIO owner boundary
route owner boundary
bounded logging policy
```

unless the user explicitly scopes that change and the contradiction is logged.

---

## 13. Next Run Seed

Next serious run should start by checking:

```text
README.md
control/01_CONTROL_GOVERNANCE.md
control/01_CONTROL_GOVERNANCE.md
control/01_CONTROL_GOVERNANCE.md
docs/00_AURORA_CORE_MAIN_PAGE_GUIDEBOOK.md
docs/09_BUCKET_UNIVERSE_TAXONOMY_GUIDEBOOK.md
docs/10_SELECTION_BASKET_CONSTRUCTION_GUIDEBOOK.md
mt5/AuroraCore.mq5
mt5/core/AC_Config.mqh
mt5/runtime_owners/runtime_7_publication_owner/publication_routes/AC_ServerPaths.mqh
```

Then run a stale-term scan for:

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

Decision default:

```text
TEST FIRST
```
