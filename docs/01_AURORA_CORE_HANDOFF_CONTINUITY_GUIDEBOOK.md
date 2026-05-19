# AURORA CORE — HANDOFF & CONTINUITY GUIDEBOOK

**System:** AURORA CORE  
**Role:** Continuity spine, restart protocol, decision snapshot, and next-chat handoff guide.  
**Primary use:** If a chat becomes bloated, lost, truncated, or replaced, this guidebook lets the next chat continue without rebuilding the whole context from memory.

---

## 0. Why This Guidebook Exists

Large architecture work fails when continuity is carried only inside a chat window.

AURORA CORE must not depend on one long conversation staying alive.

This guidebook exists so that every future chat, worker, or audit can restart from the current truth without guessing.

It records:

```text
what has already been decided
what is locked
what is still open
what guidebooks exist
what guidebooks are planned
what folder structure is under discussion
what the next strongest work should be
what must not be claimed
what research discipline is mandatory
what file-creation discipline is mandatory
```

This is a handoff book, not a full blueprint.

It should stay lean enough to read quickly, but complete enough to prevent drift.

---

## 1. Research Basis for This Handoff Pattern

This guidebook follows a just-enough-documentation model.

The target is not maximum documentation volume.

The target is enough current-state truth to let future work estimate effort, continue safely, and avoid repeating old mistakes.

Useful handoff documentation should preserve:

```text
current state
decisions made
open questions
ownership boundaries
dependencies
acceptance criteria
next actions
risk warnings
```

AURORA adds stricter requirements because this is trading-system architecture:

```text
evidence rank
source-of-truth status
permission state
no-edge-claim state
anti-drift warnings
publication law
runtime owner boundaries
```

---

## 2. Current System Identity

System name:

```text
AURORA CORE
```

Full description:

```text
Native MT5 Market Intelligence, Runtime Ownership, and Truth Publication System
```

Short definition:

```text
AURORA CORE scans wide with cheap broker truth, ranks through buckets, builds diversified inspection baskets, applies expensive evidence only to selected symbols, publishes truth and degradation atomically, and blocks trading claims until outcome validation proves edge.
```

AURORA CORE is not:

```text
a finished trading edge
a signal seller
a live-trading permission system
a prop-firm-ready execution system
a proof of expectancy
```

---

## 3. Current GitHub Repository

Repository:

```text
https://github.com/jasonangeltonkin1111-oss/AURORA-CORE
```

Current created source-of-truth files known at this handoff point:

```text
README.md
docs/00_AURORA_CORE_MAIN_PAGE_GUIDEBOOK.md
docs/01_AURORA_CORE_HANDOFF_CONTINUITY_GUIDEBOOK.md
```

Important note:

```text
The current docs/ folder is temporary-good, not final-perfect.
A cleaner structure with blueprint/ and guidebooks/ is under discussion.
Do not reorganize files until the folder plan is explicitly approved.
```

---

## 4. Current Decision Snapshot

```text
AURORA CORE identity: PROCEED
Runtime Owner top-level structure: PROCEED
23 logical layers under Runtime Owners: PROCEED
MT5 native-first direction: PROCEED
Publication-first law: PROCEED
Timing / heartbeat guidebook: PROCEED
Completed-run steady-state refresh (30-minute full refresh): PROCEED
External calculation worker architecture: PROCEED TO GUIDEBOOK DESIGN
Python worker + file snapshot bridge: BEST FIRST CANDIDATE
C/C++ worker: HOLD
WebRequest bridge for main runtime bridge: HOLD
Sockets bridge for main runtime bridge: CONSIDER
MT5-only heavy calculations: HOLD
Bucket-first selection: PROCEED
Selected evidence only: PROCEED
Outcome validation required before edge claims: PROCEED

External DOM/API: HOLD
Directional alerts: HOLD
Setup strategy layer: QUARANTINE
Auto-trading: BLOCKED
Trading edge claim: UNPROVEN
```

No future chat may upgrade HOLD / QUARANTINE / BLOCKED / UNPROVEN states without evidence.

---

## 5. Permanent Architecture Spine

AURORA CORE follows this spine:

```text
Account + Broker Truth
→ Market Availability
→ One Basic Gate
→ Cheap Broad Ranking
→ Bucket Ranking
→ Dynamic Bucket Selection
→ Correlation-Aware Global Top 10
→ Selected Deep Evidence
→ Integrity / Permission / Alert State
→ Outcome Validation Later
```

This means:

```text
wide cheap truth first
one hard eligibility gate only
descriptive ranking before prediction
bucket structure before global basket
selected-symbol evidence only
permission blocked until validation
```

Forbidden reinterpretation:

```text
Top 10 = trade list
high rank = signal
deep evidence = confirmation
indicator context = entry rule
MT5 DOM = true institutional order flow
architecture = edge proof
```

---

## 6. Runtime Owner Structure Is Permanent

Runtime Owners are the permanent top-level blueprint headers.

Logical layers live under Runtime Owners.

Layer details can be revised later, but Runtime Owner headers remain the system overview spine.

```text
Runtime Owner 1 — Foundation Truth Owner
Runtime Owner 2 — Surface Scoring Owner
Runtime Owner 3 — Bucket Intelligence Owner
Runtime Owner 4 — Basket Selection Owner
Runtime Owner 5 — Selected Evidence Owner
Runtime Owner 6 — Permission / Alert Owner
Runtime Owner 7 — Publication Owner
Runtime Owner 8 — Validation / Outcome Owner
```

The system must not become 23 separate runtime engines.

---

## 7. Logical Layer Set

```text
1.  Account / Portfolio / Prop Rule Truth
2.  Market Open / Closed Truth
3.  Symbol + Broker Specs Truth
4.  Market Watch Truth
5.  Basic System Gate

6.  Surface Cost / Friction Ranking
7.  Session Relevance Ranking
8.  Surface Movement / Range Ranking
9.  Surface Structure / Location Geometry

10. Broker Bucket Classification
11. Symbol Ranking Inside Buckets
12. Bucket Heat / Bucket Quality Ranking
13. Dynamic Top Bucket Selection
14. Bucket Leader Candidate Pool

15. Correlation / Diversity Selection
16. Global Top 10 Builder

17. Deep Evidence Selection Split
18. Selected Raw OHLC Bar Pack
19. Selected Wick / Candle Geometry Pack
20. Selected Rolling Tick Pack
21. Selected Indicator / Reference Pack
22. Deep Market Evidence / Liquidity / MT5 Order-Flow Proxy Pack

23. Setup / Strategy / Permission / Alert State
```

These layers are logical truth layers.

They are not permission to build 23 independent engines.

---

## 8. Folder Structure Status

The current repo has started with:

```text
README.md
docs/
```

A better final structure has been proposed but not yet approved or applied.

Proposed future structure:

```text
AURORA-CORE/
  README.md

  blueprint/
    00_BLUEPRINT_INDEX.md
    01_SYSTEM_IDENTITY_AND_MISSION.md
    02_RUNTIME_OWNER_BLUEPRINT.md
    03_LOGICAL_LAYER_BLUEPRINT.md
    04_BUILD_PHASE_BLUEPRINT.md
    05_PUBLICATION_SURFACE_BLUEPRINT.md
    06_PERMISSION_AND_VALIDATION_BLUEPRINT.md

  guidebooks/
    00_MAIN_PAGE_GUIDEBOOK.md
    01_HANDOFF_CONTINUITY_GUIDEBOOK.md
    02_RUNTIME_OWNER_GUIDEBOOK.md
    03_TIMING_HEARTBEAT_BREATHING_SPINE_GUIDEBOOK.md
    04_PUBLICATION_TRUTH_PRINTING_GUIDEBOOK.md
    05_BOARD_OPERATOR_COCKPIT_GUIDEBOOK.md
    06_DOSSIER_GUIDEBOOK.md
    07_GOVERNANCE_LEDGER_GUIDEBOOK.md
    08_SCORE_FORMULA_EVIDENCE_INTEGRITY_GUIDEBOOK.md
    09_BUCKET_UNIVERSE_TAXONOMY_GUIDEBOOK.md
    10_SELECTION_BASKET_CONSTRUCTION_GUIDEBOOK.md
    11_ALERTS_PERMISSION_SAFETY_GUIDEBOOK.md
    12_VALIDATION_OUTCOME_GUIDEBOOK.md
    13_MT5_FUNCTION_GUIDEBOOK.md
    14_ANTI_DRIFT_SOURCE_OF_TRUTH_GUIDEBOOK.md

  control/
    00_MUST_READ_INDEX.md
    01_ANTI_DRIFT_LAW.md
    02_WORKER_STARTUP_CHECKLIST.md
    03_WORKFLOW_AND_PROMPT_LAW.md
    04_BOOK_STYLE_AND_QUALITY_GATES.md
    05_DECISION_STATE_REGISTER.md

  mt5/
    AuroraCore.mq5
    runtime_owners/
    io/
    shared/
    config/

  governance/
    schemas/
    registries/
    examples/

  research/
    mt5_official_docs/
    broker_behavior/
    prop_firm_rules/
    validation_methods/
    order_flow_limits/

  prompts/
    universal/
    workers/
    codex/
    audits/

  archive/
    old_blueprints/
    old_guidebook_drafts/
    superseded_prompts/
```

Decision state:

```text
Folder structure proposal: DISCUSS / REFINE FIRST
Migration from docs/ to guidebooks/: HOLD UNTIL APPROVED
```

---

## 9. Current Guidebook Library Plan

The guidebook set under discussion:

```text
Guidebook tracker
Created: 7
Total: 16
Remaining: 9

Planned remaining:
07 — Governance & Ledger Guidebook
08 — Score, Formula & Evidence Integrity Guidebook
09 — Bucket Universe & Taxonomy Guidebook
10 — Selection & Basket Construction Guidebook
11 — Alerts, Permission & Safety Guidebook
12 — Validation & Outcome Guidebook
13 — External Worker & Calculation Bridge Guidebook
14 — MT5 Function Guidebook
15 — Anti-Drift & Source-of-Truth Guidebook
```


```text
00 — Main Page Guidebook
01 — Handoff & Continuity Guidebook
02 — Runtime Owner Guidebook
03 — Timing, Heartbeat & Breathing Spine Guidebook
04 — Publication & Truth Printing Guidebook
05 — Board & Operator Cockpit Guidebook
06 — Dossier Guidebook
07 — Governance & Ledger Guidebook
08 — Score, Formula & Evidence Integrity Guidebook
09 — Bucket Universe & Taxonomy Guidebook
10 — Selection & Basket Construction Guidebook
11 — Alerts, Permission & Safety Guidebook
12 — Validation & Outcome Guidebook
13 — External Worker & Calculation Bridge Guidebook
14 — MT5 Function Guidebook
15 — Anti-Drift & Source-of-Truth Guidebook
```

Potential issue:

```text
Runtime Owner Guidebook may belong before Timing, or the Runtime Owner content may remain in blueprint/ while guidebooks start with Timing.
This is not yet locked.
```

Recommended next discussion:

```text
Should the next book be Runtime Owner Guidebook or Timing / Heartbeat Guidebook?
```

Current leaning:

```text
Timing / Heartbeat is the next most valuable book because it defines how Aurora breathes and prevents fake-alive runtime failure.
```

---

## 10. Mandatory Book Discussion Protocol

Before creating or updating any guidebook, the chat must do the following:

```text
1. Identify the book's purpose.
2. Identify what the book owns.
3. Identify what the book must not own.
4. Research official / credible sources where relevant.
5. Convert research into Aurora-specific laws, constraints, fields, tests, or acceptance criteria.
6. Identify failure modes the book must prevent.
7. Identify contradictions with existing guidebooks or blueprint files.
8. Refine the outline with the user.
9. Only create/update the file after the user explicitly approves creation or update.
```

Exception:

```text
This handoff guidebook was created immediately because the user explicitly asked for a continuity handoff guidebook now.
```

---

## 11. Mandatory Research Rule

For every serious guidebook discussion, perform deep analysis and research.

Research must not be decorative.

It must be converted into at least one of:

```text
system law
owner boundary
field requirement
cadence rule
failure state
acceptance criterion
verification test
no-go rule
rollback rule
ledger requirement
```

For MT5 / MQL5 behavior, prefer:

```text
official MQL5 / MetaQuotes documentation
platform behavior references
current source inspection when code exists
runtime evidence when available
```

For engineering process / documentation / validation behavior, prefer:

```text
credible software engineering sources
official docs where available
reputable engineering handbooks
peer-reviewed or systematic-review sources when useful
```

If research is inconclusive, mark it:

```text
research_status = incomplete
claim_status = unproven
next_action = define falsifier or inspect source
```

---

## 12. File Creation Discipline

Do not jump directly to Git file creation.

Default workflow:

```text
discuss
research
analyze
refine outline
agree final structure
then create/update file only after explicit user instruction
```

Allowed direct creation:

```text
user explicitly says create it now
user explicitly says update the repo now
user explicitly says make the file
user explicitly says commit it
```

When creating or updating files:

```text
preserve current folder decisions
avoid surprise migrations
avoid renaming existing files unless approved
use one clean commit per coherent document change
summarize changed path and commit SHA
```

---

## 13. Next-Chat Restart Protocol

If a new chat must continue this work, start by reading:

```text
README.md
docs/00_AURORA_CORE_MAIN_PAGE_GUIDEBOOK.md
docs/01_AURORA_CORE_HANDOFF_CONTINUITY_GUIDEBOOK.md
```

Then confirm:

```text
AURORA CORE identity
Runtime Owner top-level structure
current decision snapshot
folder structure status
guidebook library plan
mandatory book discussion protocol
mandatory research rule
file creation discipline
```

Then ask or infer which task is next.

If the user says "continue the books", the next chat should continue from:

```text
Discuss and refine the next overview guidebook before creating it.
Likely candidate: Timing, Heartbeat & Breathing Spine Guidebook.
```

---


## 13A. External Worker Boundary Law (Design-Stage Only)

```text
External calculation worker: PROCEED TO GUIDEBOOK DESIGN
External worker implementation status: UNPROVEN
External worker is not production-approved, not coded, and grants no trading permission.
```

MT5 owns:

```text
broker truth
account truth
symbol universe truth
quote/session truth
selected raw source snapshots
publication surfaces
permission blocks
file route ownership
worker health monitoring
schema/freshness validation
operator display
```

External Worker may own:

```text
heavy calculations
ranking transforms if assigned
correlation matrices
bucket heat calculations
large taxonomy processing
selected evidence transforms
statistical summaries
validation/outcome calculations later
```

External Worker must not own:

```text
broker truth
live account truth
order sending
trade permission
publication routes
final Board/Dossier writing
final source-of-truth labels without MT5 validation
```

```text
External worker may calculate.
External worker may not become broker truth, publication owner, or permission owner.
```

Bridge design notes:

```text
Best first candidate: Python Worker + file snapshot bridge.
WebRequest bridge for main runtime bridge: HOLD (synchronous/blocking, allowed URLs required, not available in Strategy Tester).
C/C++ worker: HOLD unless Python/file bridge proves insufficient.
```

References:
- https://www.mql5.com/en/docs/event_handlers/ontimer
- https://www.mql5.com/en/docs/network/webrequest
- https://www.mql5.com/en/docs/python_metatrader5

## 14. Copy/Paste Restart Prompt for Future Chat

Use this if the conversation becomes bloated:

```text
AURORA CORE — CONTINUE GUIDEBOOK SYSTEM WORK

You are continuing the AURORA CORE blueprint and guidebook system.

First read the current repo files:
- README.md
- docs/00_AURORA_CORE_MAIN_PAGE_GUIDEBOOK.md
- docs/01_AURORA_CORE_HANDOFF_CONTINUITY_GUIDEBOOK.md

Do not assume memory is complete.
Do not jump straight to creating files.
For every serious guidebook discussion, do deep analysis and research first.
Convert research into Aurora-specific laws, owner boundaries, failure states, fields, acceptance criteria, tests, or no-go rules.

Current locked structure:
- System name: AURORA CORE
- Runtime Owners are permanent top-level blueprint headers.
- 23 logical layers live under Runtime Owners.
- Publication-first law is active.
- Selected evidence only is active.
- Edge claims are UNPROVEN.
- Setup strategy is QUARANTINE.
- Auto-trading is BLOCKED.
- Completed-run full refresh cadence is every 30 minutes.
- Heartbeat / publication / critical risk checks continue between refreshes.
- External Worker & Calculation Bridge Guidebook is planned (not created yet).
- Guidebook tracker: Created 7 / Total 16 / Remaining 9.
- External worker is design-stage only.
- Python + file snapshot bridge is BEST FIRST CANDIDATE.
- MT5 owns broker truth and publication.
- External worker may calculate but may not become broker truth, publication owner, or permission owner.

Current files created:
- README.md
- docs/00_AURORA_CORE_MAIN_PAGE_GUIDEBOOK.md
- docs/01_AURORA_CORE_HANDOFF_CONTINUITY_GUIDEBOOK.md

Current folder structure is not finalized. A future structure with blueprint/, guidebooks/, control/, mt5/, governance/, research/, prompts/, and archive/ is proposed but not yet applied.

Next likely work:
- Discuss/refine the folder structure.
- Then discuss/refine the Timing, Heartbeat & Breathing Spine Guidebook.
- Only create or update files when explicitly instructed.

Truth first. No fake proof. No edge claim without outcome evidence.
```

---

## 15. Immediate Next Work Queue

Recommended next sequence:

```text
1. Finalize repo folder structure conceptually.
2. Decide whether to migrate docs/ to guidebooks/ now or later.
3. Discuss the Timing, Heartbeat & Breathing Spine Guidebook.
4. Research MT5 OnTimer / event queue / scheduler implications again before writing the timing book.
5. Define lane model: Fast Lane, Standard Lane, Slow Lane, Deep Lane, Recovery Lane, Publication Lane, Validation Lane.
6. Define cadence families and fake-alive failure modes.
7. Only then create the timing guidebook.
```

---

## 16. Critical Failure Modes to Keep Visible

AURORA CORE must avoid these:

```text
chat-memory drift
guidebook duplication
folder sprawl
Runtime Owner drift
23-engine fragmentation
publication blocked by dirty truth
Board clutter
Dossier blankness
score-as-signal language
Top 10-as-trade-list language
all-symbol deep evidence overload
OnTimer cadence death
slow lane starvation
external API fantasy
auto-trade creep
edge claims without outcome evidence
```

---

## 17. Final Handoff Command

```text
If context is lost, restart from the repo, not from memory.
Read the Main Page Guidebook and this Handoff Guidebook first.
Respect Runtime Owners.
Research before writing.
Discuss before creating files.
Print truth.
Validate before permission.
```
