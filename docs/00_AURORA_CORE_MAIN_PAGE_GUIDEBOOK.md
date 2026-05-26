# AURORA CORE - MAIN PAGE GUIDEBOOK

**Guidebook to the Guidebooks**  
**System Identity:** AURORA CORE  
**Role:** master overview, documentation spine, current navigation map, and anti-drift front door.

---

## 0. Purpose

This document is the front door to the AURORA CORE documentation system.

It does not replace:

```text
README.md
control/01_CONTROL_GOVERNANCE.md
control/01_CONTROL_GOVERNANCE.md
control/01_CONTROL_GOVERNANCE.md
```

A new worker must read those files before acting.

This guidebook explains the system shape, active naming contracts, and what must not drift.

AURORA CORE is not a finished trading edge.

AURORA CORE is a native MT5 market-intelligence, runtime-ownership, truth-publication, and future-validation system.

Permanent overview principle:

```text
Runtime Owners are the top-level system headers.
Logical layers live under Runtime Owners.
Guidebooks explain owners, surfaces, timing, proofs, and laws.
Current source files define implementation truth.
```

---

## 1. Current Truth Status

```text
Architecture planning: PROCEED
Runtime Owner structure: PROCEED
MT5 native-first direction: PROCEED
Publication-first law: PROCEED
Runtime 0 source: EXISTS, compile/runtime proof required after each patch
Runtime 1 Layer 1 account truth: EXISTS, read-only snapshot only
Runtime 2 taxonomy/universe lookup: SKELETON / CONTRACT ONLY unless generated rows are committed
Runtime 7 publication/FileIO routes: EXISTS
Selection Desk: STRUCTURE PLACEHOLDERS ONLY
Dossiers: STRUCTURE PLACEHOLDERS ONLY
Trade Journal System: DESIGN CONTRACT ADDED; runtime implementation pending compile/runtime proof
External calculation worker architecture: DESIGN-STAGE ONLY
Python worker + file snapshot bridge: BEST FIRST CANDIDATE, not production authority
C/C++ worker: HOLD as later optimization
WebRequest bridge for main runtime bridge: HOLD
Sockets bridge for main runtime bridge: CONSIDER later after file bridge proves insufficient
MT5-only heavy calculations: HOLD as fallback, not preferred long-term
Selected evidence only: PROCEED AS ARCHITECTURE, not runtime proof

External DOM/API: HOLD
Directional alerts: HOLD
Setup strategy layer: QUARANTINE
Auto-trading: BLOCKED
Trading edge claim: UNPROVEN
```

No guidebook may upgrade trading permission, setup alerts, external feeds, auto-trading, or trade-journal reason certainty without explicit evidence upgrade through validation/outcome proof.

---

## 2. Current Mandatory Navigation

Every serious run must first read:

```text
README.md
control/01_CONTROL_GOVERNANCE.md
control/01_CONTROL_GOVERNANCE.md
control/01_CONTROL_GOVERNANCE.md
control/01_CONTROL_GOVERNANCE.md
docs/15_ANTI_DRIFT_SOURCE_OF_TRUTH_GUIDEBOOK.md
```

Then read the relevant guidebook, blueprint, governance contract, research file, and active MT5 source owner files.

No serious run may proceed from memory alone.

---

## 3. Current Source-of-Truth Order

```text
1. Current active MT5 source files for implementation truth
2. Runtime/generated file evidence supplied by the user for observed behavior
3. README.md for current repo-level direction
4. control/01_CONTROL_GOVERNANCE.md for current navigation and contradiction prevention
5. control/01_CONTROL_GOVERNANCE.md for work routing
6. control/01_CONTROL_GOVERNANCE.md for decision/evidence gates
7. Active docs/ guidebooks for doctrine
8. Active blueprint/ contracts for structure
9. governance/ schemas and ledgers
10. research/ primary-source constraints
11. Old guidebooks/reports/prompts/chats/history as background only
```

If files conflict, log a contradiction before editing.

---

## 4. Permanent System Spine

The system spine is:

```text
Account + Broker Truth
-> Market Availability
-> One Basic Gate
-> Cheap Broad Ranking
-> Taxonomy Classification
-> Ranking Group Selection Controls
-> Correlation-Aware Global Inspection Basket
-> Selected Deep Evidence
-> Integrity / Permission / Alert State
-> Outcome Validation Later
-> Trade Journal Forensics / Bookkeeping Later
```

Meaning:

```text
wide cheap truth
-> one hard eligibility gate
-> descriptive ranking
-> taxonomy fields
-> ranking_group selection/cap/diversification controls
-> diversified attention
-> selected-symbol evidence
-> permission blocked unless validated
-> one-file-per-trade forensic record when implemented
```

Forbidden interpretation:

```text
ranking = signal
Global Top 10 = trade list
deep evidence = confirmation
trade journal note = proven motive
architecture = edge proof
placeholder file = runtime truth
```

---

## 5. Active Taxonomy Naming Contract

Use these active field names:

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
aggregation_group
bucket_top5
sub_bucket_top5
Top 5 Per Bucket
```

These may appear only in historical notes or contradiction ledgers.

---

## 6. Active Route Contracts

Dossiers stay:

```text
Dossiers/
Dossiers/Open/
Dossiers/Closed/
Dossiers/Unknown/
```

Do not replace Dossier folders with taxonomy folders.

Taxonomy belongs inside Dossier content, lookup rows, indexes, and metadata, not in the Dossier parent-folder layout.

Selection Desk stable parent routes:

```text
Selection Desk/
Selection Desk/Groups/
Selection Desk/Global/
Selection Desk/Selection Index.txt
```

Top-N and rank order belong inside future child files or indexes, not parent folder names.

Future views may include:

```text
Selection Desk/Groups/_INDEX.txt
Selection Desk/Groups/<ranking_group>.txt
Selection Desk/Global/_INDEX.txt
Selection Desk/Global/Global Top 10.txt
Selection Desk/Selection Index.txt
```

Trade Journal stable parent routes are design-contract only until runtime source and proof exist:

```text
Trade Journal Import/Inbox/
Trade Journal Import/Accepted/
Trade Journal Import/Rejected/
Trade Journal Import/Orphaned/
Trade History/Before Aurora/
Trade History/Aurora Captured/
```

Trade Journal final records must be one file per trade. Setup packet imports and final trade history must not grant trade permission.

Current Selection Desk status:

```text
structure placeholders only
ranking_group_runtime=false
selection_logic_runtime=false
trade_permission=false
```

---

## 7. Runtime Owner Headers

Runtime Owners remain the permanent top-level overview structure.

### Runtime Owner 0 - Governance / Internal Control Owner

Owns current internal-control source slices:

```text
Layer 0.1 Startup / Runtime Identity
Layer 0.2 Scheduler / Heartbeat / Breathing Spine
Layer 0.4 Governance / Manifest / Telemetry
```

Must preserve:

```text
bounded timer work
honest status
manifest proof
micro-log/addendum proof
no hidden permission grants
```

---

### Runtime Owner 1 - Foundation Truth Owner

Owns planned/current foundation truth:

```text
Layer 1 Account / Portfolio / Prop Rule Truth
Layer 2 Market Open / Closed Truth
Layer 3 Symbol + Broker Specs Truth
Layer 4 Market Watch Truth
Layer 5 Basic System Gate
```

Current implemented slice:

```text
Layer 1 account truth snapshot only
trade_permission=blocked
prop_rule_status=not_configured
```

Must not own:

```text
strategy edge
indicator signals
selection logic
trade permission grant
```

---

### Runtime Owner 2 - Market Universe / Taxonomy Lookup Owner

Owns taxonomy/universe lookup direction:

```text
asset_class
market_group
market_segment
ranking_group
symbol
lookup keys
classification confidence
evidence status
rank/review gates
```

Current state:

```text
skeleton / contract only unless generated rows are committed and compiled
```

Must not become:

```text
heavy OnTimer classifier
random Other dump
selection engine
trade permission owner
```

---

### Runtime Owner 3 - Surface Scoring Owner

Owns later descriptive surface scoring:

```text
cost / friction
session relevance
movement / range
structure / location geometry
```

All surface scores are descriptive unless later outcome evidence proves predictive value.

---

### Runtime Owner 4 - Selection / Basket Owner

Owns later selection logic:

```text
Ranking Group Top-N content inside Selection Desk/Groups child files
Global Top 10 content inside Selection Desk/Global child files
Selection Index metadata
correlation / diversity selection
candidate rejects and backups
```

Core law:

```text
Selection is attention.
Selection is not permission.
Ranking Group is the selection/cap/diversification grouping field.
```

---

### Runtime Owner 5 - Selected Evidence Owner

Owns later expensive selected-symbol evidence:

```text
selected raw OHLC packs
selected wick/candle geometry packs
selected rolling tick packs
selected indicator/reference packs
selected deep market evidence / liquidity / MT5 order-flow proxy packs
```

Core law:

```text
Deep evidence is selected-symbol only.
```

---

### Runtime Owner 6 - Permission / Alert Owner

Owns later setup/permission/alert state.

Default status:

```text
class_1_system_alert_allowed=true
class_2_setup_alert_allowed=false
directional_alert_allowed=false
auto_trade_allowed=false
live_allowed=false
setup_edge_status=unproven
```

---

### Runtime Owner 7 - Publication Owner

Owns:

```text
FileIO boundary
route construction
Workbench outputs
Dossier folder structure
Selection Desk folder structure
Trade Journal Import and Trade History route support when implementation is added
manifest/status/diagnostic publication support
```

Must not own:

```text
broker truth
account truth
ranking truth
selection truth
trade permission
strategy
trade motive reconstruction
```

---

### Trade Forensics / Trade Journal Owner - Support Owner

Owns future bookkeeping/forensic journal records only:

```text
setup packet import contract
before/after Aurora cutoff classification
one final text file per trade
match-confidence labels
what Aurora can and cannot claim
```

It consumes MT5 trade facts and optional live/packet evidence. It does not grant permission, execute trades, rank symbols, or prove edge.

---

## 8. Guidebook Map

Core guidebooks remain under `docs/`.

Use this map:

```text
docs/00_AURORA_CORE_MAIN_PAGE_GUIDEBOOK.md       front door
docs/01_AURORA_CORE_HANDOFF_CONTINUITY_GUIDEBOOK.md continuity/handoff
docs/02_TIMING_HEARTBEAT_BREATHING_SPINE_GUIDEBOOK.md timing/heartbeat
docs/03_RUNTIME_OWNER_GUIDEBOOK.md runtime owners
docs/04_PUBLICATION_TRUTH_PRINTING_GUIDEBOOK.md publication law
docs/05_BOARD_OPERATOR_COCKPIT_GUIDEBOOK.md board/operator cockpit
docs/06_DOSSIER_GUIDEBOOK.md dossiers
docs/07_GOVERNANCE_LEDGER_GUIDEBOOK.md governance/logging/ledger
docs/08_SCORE_FORMULA_EVIDENCE_INTEGRITY_GUIDEBOOK.md formulas/evidence
docs/09_BUCKET_UNIVERSE_TAXONOMY_GUIDEBOOK.md taxonomy/universe; needs ongoing naming sync
docs/10_SELECTION_BASKET_CONSTRUCTION_GUIDEBOOK.md selection/ranking_group contract
docs/11_ALERTS_PERMISSION_SAFETY_GUIDEBOOK.md alerts/permission
docs/12_VALIDATION_OUTCOME_GUIDEBOOK.md validation/outcome/edge
docs/13_EXTERNAL_WORKER_CALCULATION_BRIDGE_GUIDEBOOK.md external worker
docs/14_MT5_FUNCTION_GUIDEBOOK.md MT5 API constraints
docs/15_ANTI_DRIFT_SOURCE_OF_TRUTH_GUIDEBOOK.md source truth / anti-drift
docs/26_TRADE_JOURNAL_SYSTEM.md trade journal setup packet and one-file-per-trade forensic contract
docs/37_OPERATOR_WORKFLOW_AND_UX_RUNBOOK.md operator first-click workflow, trader-chat export safety, and runtime visual-output test gate
```

If older guidebooks still use bucket-era language, treat it as stale unless explicitly marked historical.

---

## 9. Proof Discipline

```text
Compile success proves build compatibility only.
Runtime file output proves only observed publication behavior under observed terminal/account/server conditions.
Placeholder files prove only structure publication.
Backtests do not prove live edge.
Selection is attention, not permission.
Trade journal setup packets prove user/chat intent only when linked; they do not prove edge or permission.
No live trading, prop-firm readiness, strategy edge, or execution approval exists until evidence specifically proves it.
```

Decision default after source edits:

```text
TEST FIRST
```
