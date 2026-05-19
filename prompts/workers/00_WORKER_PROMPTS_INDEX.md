# AURORA CORE — WORKER PROMPTS INDEX

**System:** AURORA CORE  
**Role:** GPT-led worker workflow index, layer-build discipline, audit rhythm, prompt boundary, and anti-Codex-as-architect law.  
**Status:** ACTIVE WORKFLOW INDEX — not source code and not a prompt dump folder.

---

## 0. Purpose

This index defines how future Aurora workers should run layer work without creating file sprawl, skipping research, or letting Codex replace GPT-led analysis.

Core law:

```text
Workers must read the right books, name the layer properly, build the smallest useful slice, test it, audit it, and only then move on.
```

---

## 1. What Belongs Here

```text
worker workflow templates
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

Every layer reference must include the layer number and proper name.

Correct:

```text
Layer 1 — Account / Portfolio / Prop Rule Truth
Layer 2 — Market Open / Closed Truth
Layer 3 — Symbol + Broker Specs Truth
```

Incorrect:

```text
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

## 5. Worker Startup Workflow

Every serious worker run must:

```text
1. Read README.md.
2. Read control/00_SUPER_INDEX_RUN_ROUTER.md.
3. Read control/00_MUST_READ_INDEX.md.
4. Read control/05_DECISION_STATE_REGISTER.md.
5. Read docs/15_ANTI_DRIFT_SOURCE_OF_TRUTH_GUIDEBOOK.md.
6. Read the task-specific guidebooks from the Super Index.
7. Inspect current relevant repo files.
8. Do internet/platform research where facts matter.
9. Declare run mode and scope.
10. Produce or patch only what the scope justifies.
```

---

## 6. Layer Build Workflow Template

For any future layer build, use this rhythm:

```text
Run mode: SOURCE PLANNING or SOURCE IMPLEMENTATION LATER
Runtime Owner: <proper owner name>
Layer: <number + full proper layer name>

1. Read mandatory books from Super Index.
2. Inspect current active files.
3. Research official platform facts.
4. Define allowed scope.
5. Define forbidden scope.
6. Define input functions/sources.
7. Define output fields.
8. Define degraded/missing/stale states.
9. Define publication behavior.
10. Define governance rows.
11. Define compile test.
12. Define runtime test.
13. Define negative tests.
14. Patch smallest useful slice.
15. Compile if source changed.
16. Runtime-test if FileIO/timer/publication changed.
17. Audit outputs.
18. Update decision state only with evidence.
```

---

## 7. Layer Audit Workflow Template

For any completed layer patch, audit:

```text
1. Did the patch touch only the intended Runtime Owner and layer?
2. Did every layer reference use number + proper name?
3. Did it avoid forbidden future-layer behavior?
4. Did it preserve FileIO / route ownership?
5. Did it generate or define required governance rows?
6. Did compile proof exist if source changed?
7. Did runtime proof exist if runtime readiness was claimed?
8. Did manifest proof align with physical files if publication was claimed?
9. Did any new shadow owner or shadow path appear?
10. Does the decision state need updating, and is there evidence?
```

---

## 8. Codex Use Boundary

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

## 9. Layer 1 — Account / Portfolio / Prop Rule Truth Worker Rule

Before implementing Layer 1 — Account / Portfolio / Prop Rule Truth, a worker must read:

```text
control/00_SUPER_INDEX_RUN_ROUTER.md
control/05_DECISION_STATE_REGISTER.md
blueprint/02_RUNTIME_OWNER_BLUEPRINT.md
blueprint/03_LOGICAL_LAYER_BLUEPRINT.md
blueprint/04_BUILD_PHASE_BLUEPRINT.md
blueprint/07_FILEIO_ROUTE_OWNERSHIP_CONTRACT.md
governance/schemas/01_MINIMUM_GOVERNANCE_SCHEMA_CONTRACTS.md
research/mt5_official_docs/00_MT5_OFFICIAL_DOCS_INDEX.md
research/validation_methods/00_VALIDATION_METHODS_INDEX.md
mt5/01_LAYER1_ACCOUNT_PORTFOLIO_PROP_RULE_TRUTH_SOURCE_PLAN_AND_TESTS.md
```

Layer 1 — Account / Portfolio / Prop Rule Truth implementation must remain limited to account/terminal truth shell, publication proof, and governance proof.

---

## 10. Final Worker Law

```text
Do not build from vibes.
Do not spawn files for decoration.
Do not call a layer by number only.
Read, research, patch, test, audit, then move.
```