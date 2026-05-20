# AURORA CORE - SUPER INDEX / RUN ROUTER

**System:** AURORA CORE  
**Role:** current run router, reading law, work-mode router, source-of-truth gateway, and anti-drift control surface.  
**Status:** CURRENT ROUTER - must be read with `README.md` and `control/01_CURRENT_SOURCE_TRUTH_MAP.md` before any serious work.

---

## 0. Purpose

This Super Index tells every future Aurora run what to read, what mode it is in, what is allowed, what is forbidden, and what evidence is required before claims can be upgraded.

Core law:

```text
Every serious run must follow the current source truth map before touching architecture, schemas, source, prompts, or claims.
Runtime/source files outrank old guidebook-era wording for implementation truth.
No serious run may proceed from memory alone.
```

---

## 1. Current System State

```text
README.md: current repo-level direction
control/01_CURRENT_SOURCE_TRUTH_MAP.md: current navigation and contradiction-prevention bridge
Guidebooks: active doctrine, but older wording must be patched when it conflicts with current source truth
MT5 source implementation: active source exists, limited scope only
Runtime 0: governance/status/manifest/diagnostics/micro-log support exists
Runtime 1 Layer 1: account truth snapshot exists
Runtime 2: taxonomy/universe lookup skeleton or contract only unless generated rows are committed
Runtime 7: FileIO/routes owner exists
Selection Desk: structure placeholders only
Dossiers: Open/Closed/Unknown structure preserved
External worker: design-stage only; no production authority granted
Trading edge claim: UNPROVEN
Setup strategy layer: QUARANTINE
Directional alerts: HOLD
Auto-trading / trade permission: BLOCKED
```

Important:

```text
Existing guidebooks and source slices mean documentation and limited implementation exist.
They do not mean compile proof exists for the latest patch.
They do not mean runtime proof exists for the latest patch.
They do not mean ranking, selection, edge, strategy, alerts, or trading permission exists.
```

---

## 2. Source-of-Truth Hierarchy

Default hierarchy:

```text
1. Current active MT5 source files for implementation truth
2. Runtime/generated file evidence supplied by the user for observed behavior
3. README.md for current repo-level direction
4. control/01_CURRENT_SOURCE_TRUTH_MAP.md for current navigation and contradiction prevention
5. This router for work routing
6. control/05_DECISION_STATE_REGISTER.md for decision/evidence gates
7. Active docs/ guidebooks for doctrine
8. Active blueprint/ contracts for structure
9. governance/ schemas and ledgers
10. research/ primary-source constraints
11. Git history / previous commits
12. Old guidebooks, reports, prompts, screenshots, chats, and memory as background only
```

If any source conflicts, log the contradiction before editing. Do not resolve it by guessing.

---

## 3. Mandatory First Read for Every Serious Run

Every serious Aurora run must first read:

```text
README.md
control/01_CURRENT_SOURCE_TRUTH_MAP.md
control/00_MUST_READ_INDEX.md
control/00_SUPER_INDEX_RUN_ROUTER.md
control/05_DECISION_STATE_REGISTER.md
docs/15_ANTI_DRIFT_SOURCE_OF_TRUTH_GUIDEBOOK.md
```

Then read the relevant guidebook, blueprint, governance contract, research note, and active source owner files for the task.

---

## 4. Run Modes

Every serious run must declare one primary mode:

```text
AUDIT
RESEARCH
BLUEPRINT
CONTROL
SCHEMA
PROMPT BUILD
PATCH
SOURCE PLANNING
SOURCE IMPLEMENTATION
EDGE VALIDATION
LIVE EVIDENCE REVIEW
```

Mode boundaries:

```text
AUDIT may inspect and recommend. It must not pretend changes were made.
RESEARCH may gather and convert evidence into constraints. It must not approve implementation by itself.
BLUEPRINT may define structure. It must not duplicate full guidebooks or create source code.
CONTROL may define process law. It must not approve trading.
SCHEMA may define schemas/examples. It must not create runtime-generated output spam.
PROMPT BUILD may create execution prompts. It must not claim proof.
PATCH may edit declared files only.
SOURCE PLANNING may define source contracts. It must not create EA implementation unless explicitly approved.
SOURCE IMPLEMENTATION may patch current active owners only after source inspection and scope lock.
EDGE VALIDATION may test claims. It must not grant live permission.
LIVE EVIDENCE REVIEW may evaluate supplied live/demo evidence only within evidence bounds.
```

---

## 5. Current Naming and Route Locks

Taxonomy field names:

```text
asset_class
market_group
market_segment
ranking_group
symbol
```

Dossier folders stay:

```text
Dossiers/
Dossiers/Open/
Dossiers/Closed/
Dossiers/Unknown/
```

Selection Desk parent folders are stable:

```text
Selection Desk/
Selection Desk/Groups/
Selection Desk/Global/
Selection Desk/Selection Index.txt
```

Do not create parent folders named after changing ranks or Top-N values.

Top-N belongs inside future child files or indexes, not route ownership.

Dead active names:

```text
major_bucket
minor_bucket
aggregation_group
bucket_top5
sub_bucket_top5
Top 5 Per Bucket
```

These may appear only in historical notes or contradiction ledgers, not active routes, source fields, or operator-facing output labels.

---

## 6. MT5 Source Implementation Law

Current MT5 source exists. Do not treat the repo as planning-only.

Runtime 0 / Runtime 1 / Runtime 2 / Runtime 7 source truth must be inspected before changes.

Active first-source scope already includes:

```text
Runtime 0 governance/status/manifest/diagnostics/micro-log support
Runtime 1 Layer 1 account truth snapshot
Runtime 2 taxonomy/universe lookup skeleton or contract only unless generated rows are present
Runtime 7 route and FileIO support
```

Forbidden behavior:

```text
broad rewrites
building all runtime owners at once
unverified external worker dependency
unbounded OnTimer work
hidden publication blockers
hidden permission grants
duplicate FileIO/path/logging/timer/publication owners
selection/ranking/trading logic from placeholder routes
```

---

## 7. Router by Work Type

### 7.1 Runtime 0 / Governance / Logging / First-Source Proof

Read:

```text
control/01_CURRENT_SOURCE_TRUTH_MAP.md
control/05_DECISION_STATE_REGISTER.md
docs/02_TIMING_HEARTBEAT_BREATHING_SPINE_GUIDEBOOK.md
docs/04_PUBLICATION_TRUTH_PRINTING_GUIDEBOOK.md
docs/07_GOVERNANCE_LEDGER_GUIDEBOOK.md
docs/14_MT5_FUNCTION_GUIDEBOOK.md
docs/15_ANTI_DRIFT_SOURCE_OF_TRUTH_GUIDEBOOK.md
blueprint/04_BUILD_PHASE_BLUEPRINT.md
blueprint/07_FILEIO_ROUTE_OWNERSHIP_CONTRACT.md
blueprint/08_MT5_SOURCE_FOLDER_CONTRACT.md
governance/schemas/01_MINIMUM_GOVERNANCE_SCHEMA_CONTRACTS.md
research/mt5_official_docs/00_MT5_OFFICIAL_DOCS_INDEX.md
research/validation_methods/00_VALIDATION_METHODS_INDEX.md
mt5/00_RUNTIME0_GOVERNANCE_INTERNAL_CONTROL_SOURCE_PLAN_AND_TESTS.md
mt5/AuroraCore.mq5
mt5/core/AC_Config.mqh
mt5/core/AC_CommonTypes.mqh
mt5/runtime_owners/runtime_0_governance_internal_control/
mt5/runtime_owners/runtime_7_publication_owner/
```

Must preserve:

```text
OnTimer stays bounded.
Logging is bounded snapshot/addendum style, not spam.
Runtime 7 owns routes/FileIO.
Publication must print honest degraded truth rather than hide files.
```

---

### 7.2 Publication / Route / Dossier / Selection Desk Structure

Read:

```text
control/01_CURRENT_SOURCE_TRUTH_MAP.md
docs/04_PUBLICATION_TRUTH_PRINTING_GUIDEBOOK.md
docs/05_BOARD_OPERATOR_COCKPIT_GUIDEBOOK.md
docs/06_DOSSIER_GUIDEBOOK.md
docs/07_GOVERNANCE_LEDGER_GUIDEBOOK.md
docs/10_SELECTION_BASKET_CONSTRUCTION_GUIDEBOOK.md
docs/14_MT5_FUNCTION_GUIDEBOOK.md
docs/15_ANTI_DRIFT_SOURCE_OF_TRUTH_GUIDEBOOK.md
blueprint/07_FILEIO_ROUTE_OWNERSHIP_CONTRACT.md
blueprint/08_MT5_SOURCE_FOLDER_CONTRACT.md
mt5/AuroraCore.mq5
mt5/runtime_owners/runtime_7_publication_owner/publication_routes/AC_ServerPaths.mqh
mt5/runtime_owners/runtime_7_publication_owner/publication_fileio/AC_FileIO.mqh
```

Must preserve:

```text
Dossiers stay Open/Closed/Unknown.
Selection Desk parent folders stay Groups and Global, plus Selection Index.txt.
No Top-N parent folders.
Broken truth may block review/trading but must not block physical publication.
```

---

### 7.3 Runtime 1 Account / Portfolio / Prop Rule Truth

Read:

```text
control/01_CURRENT_SOURCE_TRUTH_MAP.md
docs/03_RUNTIME_OWNER_GUIDEBOOK.md
docs/04_PUBLICATION_TRUTH_PRINTING_GUIDEBOOK.md
docs/07_GOVERNANCE_LEDGER_GUIDEBOOK.md
docs/11_ALERTS_PERMISSION_SAFETY_GUIDEBOOK.md
docs/14_MT5_FUNCTION_GUIDEBOOK.md
docs/15_ANTI_DRIFT_SOURCE_OF_TRUTH_GUIDEBOOK.md
mt5/AuroraCore.mq5
mt5/runtime_owners/runtime_1_foundation_truth_owner/layer_1_account_portfolio_prop_rule_truth/AC_AccountTruth.mqh
```

Must preserve:

```text
Account truth is read-only.
trade_permission remains blocked.
Prop rule profile is not configured until explicitly implemented and verified.
```

---

### 7.4 Runtime 2 Taxonomy / Universe / Ranking Group Contract

Read:

```text
control/01_CURRENT_SOURCE_TRUTH_MAP.md
docs/09_BUCKET_UNIVERSE_TAXONOMY_GUIDEBOOK.md
docs/10_SELECTION_BASKET_CONSTRUCTION_GUIDEBOOK.md
docs/07_GOVERNANCE_LEDGER_GUIDEBOOK.md
docs/08_SCORE_FORMULA_EVIDENCE_INTEGRITY_GUIDEBOOK.md
docs/14_MT5_FUNCTION_GUIDEBOOK.md
docs/15_ANTI_DRIFT_SOURCE_OF_TRUTH_GUIDEBOOK.md
mt5/AuroraCore.mq5
mt5/core/AC_Config.mqh
mt5/runtime_owners/runtime_2_market_universe_taxonomy_lookup/AC_MarketUniverse.mqh
```

Must preserve:

```text
Use asset_class, market_group, market_segment, ranking_group, symbol.
Do not revive major_bucket, minor_bucket, aggregation_group, or bucket_top5 as active terms.
Do not rebuild taxonomy inside OnTimer.
Do not imply generated universe rows exist unless source files prove they are committed.
```

---

### 7.5 Selection / Basket / Candidate Pool

Read:

```text
control/01_CURRENT_SOURCE_TRUTH_MAP.md
docs/10_SELECTION_BASKET_CONSTRUCTION_GUIDEBOOK.md
docs/09_BUCKET_UNIVERSE_TAXONOMY_GUIDEBOOK.md
docs/08_SCORE_FORMULA_EVIDENCE_INTEGRITY_GUIDEBOOK.md
docs/07_GOVERNANCE_LEDGER_GUIDEBOOK.md
docs/12_VALIDATION_OUTCOME_GUIDEBOOK.md
docs/15_ANTI_DRIFT_SOURCE_OF_TRUTH_GUIDEBOOK.md
mt5/AuroraCore.mq5
mt5/core/AC_Config.mqh
mt5/runtime_owners/runtime_2_market_universe_taxonomy_lookup/AC_MarketUniverse.mqh
```

Must preserve:

```text
Selection is attention, not permission.
Current Selection Desk files are placeholders only.
Ranking numbers belong inside child files/indexes, not folder names.
No selection logic exists until deliberately implemented and tested.
```

---

### 7.6 External Worker Work

Read:

```text
control/01_CURRENT_SOURCE_TRUTH_MAP.md
docs/13_EXTERNAL_WORKER_CALCULATION_BRIDGE_GUIDEBOOK.md
docs/07_GOVERNANCE_LEDGER_GUIDEBOOK.md
docs/12_VALIDATION_OUTCOME_GUIDEBOOK.md
docs/14_MT5_FUNCTION_GUIDEBOOK.md
docs/15_ANTI_DRIFT_SOURCE_OF_TRUTH_GUIDEBOOK.md
```

Must preserve:

```text
External worker may calculate only.
MT5 owns broker truth, account truth, symbol universe truth, publication surfaces, permission blocks, and final validation.
No external worker production authority exists yet.
```

---

### 7.7 Alerts / Permission / Safety Work

Read:

```text
docs/11_ALERTS_PERMISSION_SAFETY_GUIDEBOOK.md
docs/12_VALIDATION_OUTCOME_GUIDEBOOK.md
docs/07_GOVERNANCE_LEDGER_GUIDEBOOK.md
docs/05_BOARD_OPERATOR_COCKPIT_GUIDEBOOK.md
docs/14_MT5_FUNCTION_GUIDEBOOK.md
docs/15_ANTI_DRIFT_SOURCE_OF_TRUTH_GUIDEBOOK.md
```

Must preserve:

```text
No permission without evidence.
No live/funded/prop-firm readiness claim from architecture, compile, placeholders, or backtest alone.
```

---

## 8. Completed-Run Refresh Law

After a future full successful run reaches `runtime_normal` / `run_complete`:

```text
Default steady-state full-system refresh cadence = every 30 minutes.
```

Between full refreshes:

```text
heartbeat remains alive
status surfaces still print health
critical account/risk/terminal/file-write states still update
stale/degraded states remain visible
Recovery Lane may continue bounded retry work
external worker health is monitored if enabled
```

---

## 9. Codex Use Law

Codex is temporary and sparing.

Codex may be used for:

```text
narrow mechanical edits
format cleanup
repo-wide text sync after design is settled
small patch application after GPT-led research/audit
scaffold creation only when explicitly scoped
```

Codex may not be used for:

```text
main architecture decisions
internet research
edge validation
choosing MT5 functions
trading logic design
permission decisions
broad rewrites
replacing layer-by-layer testing
```

Core law:

```text
Codex is a wrench, not the architect.
```

---

## 10. Proof Discipline

```text
Compile success proves syntax/build compatibility only.
Runtime file output proves only observed publication behavior under observed terminal/account/server conditions.
Placeholder files prove only structure publication.
Selection is attention, not permission.
No live trading, prop-firm readiness, strategy edge, or execution approval exists until evidence specifically proves it.
```

Decision default after source edits:

```text
TEST FIRST
```
