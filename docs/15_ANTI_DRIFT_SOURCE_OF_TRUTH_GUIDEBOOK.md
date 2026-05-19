# AURORA CORE — ANTI-DRIFT & SOURCE-OF-TRUTH GUIDEBOOK

**System:** AURORA CORE  
**Role:** Source-of-truth hierarchy, anti-shadow-owner law, contradiction handling, archive limits, Git authority limits, Codex drift controls, and no-fake-proof doctrine.  
**Status:** Final overview guidebook foundation for the 16-book guidebook set.

---

## 0. Purpose

This guidebook prevents AURORA CORE from becoming several conflicting systems.

It answers:

```text
What is source truth?
What outranks what?
What happens when memory conflicts with files?
What happens when roadmap conflicts with source?
What happens when old reports conflict with current guidebooks?
How are contradictions logged?
How are duplicate owners killed?
How are old paths prevented?
How does Codex avoid broad rewrite drift?
```

Core law:

```text
Current active source truth outranks memory, old prompts, old reports, screenshots, and archive code.
```

---

## 1. What This Guidebook Owns

This guidebook owns:

```text
source-of-truth hierarchy
anti-shadow-owner law
no duplicate owners
no route invention
current-source-first rule
guidebook authority rules
repo folder authority
archive authority limits
contradiction ledger rules
Codex prompt drift controls
patch scope controls
changed-files discipline
no fake proof law
external worker drift controls
runtime owner boundary protection
```

---

## 2. What This Guidebook Must Not Own

This guidebook must not own:

```text
formula details
MT5 function details
bridge protocol details
trading strategy validation
publication surface layouts
```

Anti-Drift owns authority and boundaries.

It does not own all domain content.

---

## 3. Research Foundation

Version control preserves change history and supports rollback, but old commits are not current authority.

Reference:

```text
https://en.wikipedia.org/wiki/Commit_%28version_control%29
```

Aurora translation:

```text
Git history is evidence.
Git history is not current runtime truth.
```

Architectural Decision Records preserve the context, decision, and consequences of major choices.

Reference:

```text
https://arxiv.org/abs/2604.27333
```

Aurora translation:

```text
Major Aurora decisions need decision records or guidebook/ledger entries: context, decision, consequence, status, superseded-by.
```

Postmortem discipline preserves what happened, why, and how to prevent recurrence.

Reference:

```text
https://arxiv.org/abs/2505.01926
```

Aurora translation:

```text
Drift events and contradictions should be recorded as learning artifacts, not vague blame or memory.
```

---

## 4. Source-of-Truth Hierarchy

General hierarchy:

```text
1. Current active source files
2. Current active guidebooks
3. Current active governance/ledger outputs
4. Current README / index files
5. Current accepted Codex prompts
6. Recent audit reports with file evidence
7. Git history / previous commits
8. Archived guidebooks/reports/prompts
9. Screenshots / pasted outputs / user reports
10. Chat memory / AI reasoning
```

For source implementation:

```text
active source files outrank guidebook prose
```

For architecture planning before code exists:

```text
current guidebooks outrank memory and old reports
```

For runtime behavior:

```text
runtime logs / generated outputs outrank source intention
```

---

## 5. Current Owner First Law

Before adding anything:

```text
find current owner
inspect current owner
patch current owner if possible
do not create duplicate owner
```

This applies to:

```text
functions
helpers
routes
files
formulas
scores
workers
ledgers
publication surfaces
```

---

## 6. No Shadow Owner Law

A shadow owner is anything that secretly owns truth belonging elsewhere.

Forbidden examples:

```text
Board computes Global Top 10
Dossier recalculates scores
External worker decides permission
Validation grants live permission directly
Publication Owner creates ranking truth
Indicator helper creates setup signal
```

Shadow owners are architecture infection.

Kill them early.

---

## 7. No Shadow Path Law

No module may invent:

```text
new final output path
new route root
new Board path
new Dossier path
new governance folder
new worker bridge folder
```

without route owner approval.

Route changes require:

```text
current route inspected
reason for change
migration plan
rollback plan
manifest update
publication test later
```

---

## 8. Archive Authority Limits

Archive code, old reports, old prompts, and old guidebooks are evidence.

They are not active authority.

Archive may be used to:

```text
recover lost intent
compare old behavior
find previous fixes
understand failures
```

Archive may not:

```text
override current source
silently reintroduce old paths
restore deleted owners without review
claim current runtime truth
```

---

## 9. Git History Authority Limits

Git history proves what existed at a point in time.

It does not prove current behavior.

Correct use:

```text
inspect old commit for evidence
compare changes
recover intentionally
record provenance
```

Wrong use:

```text
old commit says it worked, so current system works
old file had a function, so current source owns it
old report claims proof, so current proof exists
```

---

## 10. Current Source vs Guidebook vs Runtime Evidence

If code exists:

```text
current active source file = source truth
```

If documentation conflicts with source:

```text
log contradiction
source is current behavior evidence
guidebook may define intended repair direction
```

If runtime output conflicts with source intention:

```text
runtime output proves observed behavior
source proves intended/compiled logic
contradiction requires investigation
```

---

## 11. Contradiction Ledger Rules

Contradiction ledger fields:

```text
contradiction_id
claim_a
claim_b
source_a
source_b
owner_a
owner_b
evidence_rank_a
evidence_rank_b
which_source_outranks
why
resolution_test
pause_required
status
```

Default:

```text
If contradiction affects source truth, publication, permission, risk, selection, evidence integrity, external worker output, or FileIO route: HOLD / TEST FIRST until resolved.
```

Contradictions must not be solved by vague prose.

---

## 12. Drift Event / Postmortem Record

Drift events should record:

```text
drift_event_id
what_changed
expected_owner
actual_owner
how_detected
impact
root_cause_candidate
files_affected
rollback_needed
prevention_rule
status
```

Purpose:

```text
learn from drift
prevent repeat failure
make future Codex prompts sharper
```

---

## 13. Codex Prompt Drift Controls

Every serious Codex prompt should include:

```text
inspect current files first
update existing owners first
no new paths unless approved
no duplicate owners
no fake proof
no trading/live/edge claims
changed-files summary
contradiction ledger
acceptance criteria
```

Prompts must not instruct broad rewrites unless the current owner is proven insufficient.

---

## 14. Patch Scope Controls

Patch runs must define:

```text
run mode
files in scope
files out of scope
owners affected
forbidden changes
acceptance criteria
rollback notes
```

Do not let documentation patches become architecture rewrites.

Do not let architecture prompts become source patches unless explicitly scoped.

---

## 15. Broad Rewrite Rules

Broad rewrite is allowed only when:

```text
current owner inspected
insufficiency proven
replacement boundary defined
migration plan exists
rollback plan exists
acceptance tests defined
```

Otherwise:

```text
patch current owner
or hold
```

---

## 16. External Worker Drift Controls

External worker may calculate.

It may not become:

```text
broker truth
publication owner
permission owner
final strategy authority
unvalidated source of truth
```

Worker output is candidate calculation truth until MT5 validates:

```text
request_id
cycle_id
schema_version
input_hash_seen
result_hash
freshness
worker_status
```

---

## 17. FileIO / Route Drift Controls

FileIO and route ownership must be protected.

Forbidden:

```text
scattered FileOpen/FileWrite
new final paths without Publication Owner
worker writes final Board/Dossier
guidebook invents route not in route owner
```

Publication routes require manifest proof.

---

## 18. Guidebook Update Discipline

Guidebook changes must:

```text
preserve numbering unless migration approved
update index/handoff if new book added
update progress tracker when created count changes
avoid stale planned paths
avoid duplicate guidebook entries
```

Guidebooks may evolve.

They may not quietly contradict active decisions.

---

## 19. No Fake Proof Rule

Do not claim:

```text
compile proof without compile output
runtime proof without runtime logs
publication proof without generated files/manifest
edge proof without outcome validation
live safety without live evidence
prop-firm readiness without prop-rule evidence
external worker proof without bridge test
```

Evidence must be ranked honestly.

---

## 20. No-Go Patterns

Do not allow:

```text
new helper duplicates existing owner
new route silently appears
old roadmap overrides current guidebook
old report overrides current source
worker output overrides MT5 truth
Board computes truth
Dossier computes truth
Validation grants permission directly
Codex rewrites broad areas without proof
guidebooks conflict but no contradiction ledger
archive code reintroduced silently
Git history treated as current behavior
```

---

## 21. Acceptance Criteria

This guidebook is acceptable if it blocks architecture drift.

Acceptance criteria:

```text
Defines source-of-truth hierarchy.
Protects Runtime Owner boundaries.
Prevents duplicate owners.
Prevents shadow paths.
Defines contradiction ledger rules.
Defines archive and Git history authority limits.
Defines Codex prompt drift controls.
Blocks fake proof.
Blocks broad rewrites without insufficiency proof.
Blocks external worker becoming shadow brain.
```

---

## 22. Final Anti-Drift Law

```text
Aurora dies when it becomes many almost-right systems.
Keep one truth spine.
Kill drift early.
```
