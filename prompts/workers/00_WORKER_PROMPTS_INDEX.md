# AURORA CORE — WORKER PROMPTS INDEX

**System:** AURORA CORE  
**Role:** GPT-led worker workflow index, layer-build discipline, audit rhythm, prompt boundary, and anti-Codex-as-architect law.  
**Status:** ACTIVE WORKFLOW INDEX — not source code and not a prompt dump folder.

---

## 0. Purpose

This index defines how future Aurora workers should run layer work without creating file sprawl, skipping research, or letting Codex replace GPT-led analysis.

Core law:

```text
Workers must read the right books, name the Runtime Owner and layer properly, research first, convert research into implementation constraints, patch/create only what scope justifies, debug/audit after creation, and only then complete.
```

---

## 1. What Belongs Here

```text
worker workflow templates
mandatory research-first chain
layer build rhythm
layer audit rhythm
handoff prompt rules
prompt boundaries
Codex-use restrictions
naming rules
anti-drift workflow controls
```

---

## 2. What Must Not Belong Here

```text
full guidebook duplicates
MT5 implementation code
.mq5 / .mqh source
Python worker implementation
mass prompt dumps
trade permission
edge claims
runtime-generated outputs
```

Prompts are execution tools.

They are not source truth.

---

## 3. Naming Law

Every Runtime Owner and layer reference must include the proper name.

Correct:

```text
Runtime 0 — Governance / Internal Control Owner
Layer 0.1 — Startup / Runtime Identity
Layer 0.2 — Scheduler / Heartbeat / Breathing Spine
Layer 0.4 — Governance / Manifest / Telemetry
Runtime 1 — Foundation Truth Owner
Layer 1 — Account / Portfolio / Prop Rule Truth
Layer 2 — Market Open / Closed Truth
Layer 3 — Symbol + Broker Specs Truth
```

Incorrect:

```text
Runtime 0
Layer 1
L1
first layer
```

Short codes may appear only after the full name is stated in the same section.

---

## 4. No File-Sprawl Law

Do not create a new tiny file for every small idea.

Before creating a new file, ask:

```text
Can this strengthen an existing index, blueprint, contract, schema, or plan?
Does this file prevent a real failure?
Will future workers know to read it?
Is this part of the planned system, or just a clever extra?
```

Default:

```text
update existing owner file first
create new file only when it has a clear owner and recurring use
```

---

## 5. Mandatory Research-Apply-Patch-Audit Chain

Every serious Aurora worker run must follow this chain:

```text
1. READ
   Read Super Index, Decision State Register, Anti-Drift, and task-specific books/files.

2. RESEARCH
   Use official/current sources where platform, coding, market, prop-firm, broker, validation, timing, FileIO, or edge facts matter.
   Do not rely on generic sites or memory when official/source evidence exists.

3. TRANSLATE RESEARCH
   Convert research into concrete constraints, owner boundaries, allowed functions, forbidden functions, failure states, acceptance criteria, tests, rollback rules, or schema fields.
   Research that does not change the work is decoration and must be removed or marked non-actionable.

4. INSPECT CURRENT SOURCE / FILES
   Inspect current repo files before patching.
   Existing owner first.
   No duplicate owner.

5. PATCH / CREATE
   Patch existing files first where possible.
   Create new files only when the file has clear recurring use and prevents real drift/failure.

6. DEBUG / STATIC AUDIT
   After creating or updating files, inspect the result.
   Check naming, stale contradictions, source-route drift, missing acceptance criteria, forbidden scope, and fake proof language.

7. REPORT
   Report what changed, what evidence supports it, what remains unproven, and the next allowed step.
```

A run is not complete at file creation.

A run is complete only after post-change audit.

---

## 6. Worker Startup Workflow

Every serious worker run must:

```text
1. Read README.md.
2. Read control/01_CURRENT_SOURCE_TRUTH_MAP.md.
3. Read control/00_MUST_READ_INDEX.md.
4. Read control/00_SUPER_INDEX_RUN_ROUTER.md.
5. Read control/05_DECISION_STATE_REGISTER.md.
6. Read control/02_MASTER_REPO_FILE_INDEX.md.
7. Read docs/15_ANTI_DRIFT_SOURCE_OF_TRUTH_GUIDEBOOK.md.
8. Read the task-specific guidebooks/files from the Super Index.
9. Inspect current relevant repo files.
10. Do internet/platform research where facts matter.
11. Translate the research into constraints/tests/no-go rules.
12. Declare run mode and scope.
13. Produce or patch only what the scope justifies.
14. Debug/audit the created or updated files before final report.
```

---

## 7. Runtime 0 First Source Workflow Template

For the next MT5 source build, use this rhythm:

```text
Run mode: SOURCE IMPLEMENTATION
Runtime Owner: Runtime 0 — Governance / Internal Control Owner
Internal Layers:
- Layer 0.1 — Startup / Runtime Identity
- Layer 0.2 — Scheduler / Heartbeat / Breathing Spine
- Layer 0.4 — Governance / Manifest / Telemetry
Support Owner:
- Runtime 7 — Publication Owner, FileIO/routes only

1. Read mandatory Runtime 0 files from the Super Index.
2. Research official MQL5 docs for OnTimer, EventSetTimer, EventKillTimer, FolderCreate, FileOpen, FileWrite, FileFlush, FileMove, FileIsExist, FileSize, GetLastError, ResetLastError.
3. Translate research into exact allowed functions, failure states, and tests.
4. Inspect current mt5/ source files.
5. Patch the smallest Runtime 0 source slice only.
6. Compile in MetaEditor.
7. Runtime-smoke folder creation and file writing.
8. Audit generated Runtime Status, Manifest, Status, Diagnostics, telemetry, owner rows, and layer rows.
9. Do not proceed to Runtime 1 — Foundation Truth Owner / Layer 1 — Account / Portfolio / Prop Rule Truth until Runtime 0 passes.
```

---

## 8. Generic Layer Build Workflow Template

For later layer builds, use this rhythm:

```text
Run mode: SOURCE PLANNING or SOURCE IMPLEMENTATION
Runtime Owner: <runtime number + proper owner name>
Layer: <number + full proper layer name>

1. Read mandatory books from Super Index.
2. Inspect current active files.
3. Research official/platform facts.
4. Translate research into implementation constraints.
5. Define allowed scope.
6. Define forbidden scope.
7. Define input functions/sources.
8. Define output fields.
9. Define degraded/missing/stale states.
10. Define publication behavior.
11. Define governance rows.
12. Define compile test.
13. Define runtime test.
14. Define negative tests.
15. Patch smallest useful slice.
16. Compile if source changed.
17. Runtime-test if FileIO/timer/publication changed.
18. Audit outputs.
19. Update decision state only with evidence.
```

---

## 9. Layer Audit Workflow Template

For any completed layer patch, audit:

```text
1. Did the patch touch only the intended Runtime Owner and layer?
2. Did every Runtime Owner/layer reference use number + proper name?
3. Did it avoid forbidden future-layer behavior?
4. Did it preserve FileIO / route ownership?
5. Did it generate or define required governance rows?
6. Did compile proof exist if source changed?
7. Did runtime proof exist if runtime readiness was claimed?
8. Did manifest proof align with physical files if publication was claimed?
9. Did any new shadow owner or shadow path appear?
10. Did research convert into constraints/tests/no-go rules?
11. Does the decision state need updating, and is there evidence?
```

---

## 10. Codex Use Boundary

Codex may be used sparingly for:

```text
mechanical cleanup
format sync
narrow file edits after GPT-led design
small patch application with explicit scope
```

Codex may not be used for:

```text
internet research
architecture decisions
MT5 function selection
edge validation
permission decisions
broad rewrites
replacing layer-by-layer testing
```

Core law:

```text
Codex is a wrench, not the architect.
```

---

## 11. Runtime 1 — Foundation Truth Owner / Layer 1 Later Worker Rule

Before implementing Runtime 1 — Foundation Truth Owner / Layer 1 — Account / Portfolio / Prop Rule Truth, a worker must prove Runtime 0 has already passed.

Read:

```text
control/00_SUPER_INDEX_RUN_ROUTER.md
control/05_DECISION_STATE_REGISTER.md
blueprint/02_RUNTIME_OWNER_BLUEPRINT.md
blueprint/03_LOGICAL_LAYER_BLUEPRINT.md
blueprint/04_BUILD_PHASE_BLUEPRINT.md
blueprint/07_FILEIO_ROUTE_OWNERSHIP_CONTRACT.md
blueprint/08_MT5_SOURCE_FOLDER_CONTRACT.md
governance/schemas/01_MINIMUM_GOVERNANCE_SCHEMA_CONTRACTS.md
research/mt5_official_docs/00_MT5_OFFICIAL_DOCS_INDEX.md
research/validation_methods/00_VALIDATION_METHODS_INDEX.md
mt5/00_RUNTIME0_GOVERNANCE_INTERNAL_CONTROL_SOURCE_PLAN_AND_TESTS.md
mt5/01_LAYER1_ACCOUNT_PORTFOLIO_PROP_RULE_TRUTH_SOURCE_PLAN_AND_TESTS.md
```

Runtime 1 — Foundation Truth Owner / Layer 1 — Account / Portfolio / Prop Rule Truth implementation must remain limited to account/terminal truth shell, publication proof, and governance proof.

---

## 12. Final Worker Law

```text
Do not build from vibes.
Do not spawn files for decoration.
Do not call a Runtime Owner or layer by number only.
Research first.
Turn research into constraints.
Patch/create only what earns its place.
Debug/audit after creation.
Then report.
```