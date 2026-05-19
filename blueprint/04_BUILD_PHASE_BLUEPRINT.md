# AURORA CORE — BUILD PHASE BLUEPRINT

**System:** AURORA CORE  
**Role:** Planned-system completion ladder, phase gates, source-start boundary, Layer 1 entry contract, and anti-endless-planning / anti-big-bang-coding control.  
**Status:** DETAILED BLUEPRINT — required before MT5 source implementation starts.

---

## 0. Purpose

This blueprint defines the build sequence from completed overview guidebooks into real MT5 source implementation.

It exists to prevent two opposite failures:

```text
1. endless planning that never reaches code
2. rushed coding that skips required contracts and recreates drift
```

Core law:

```text
Move toward code through the planned-system completion ladder.
Do not skip blueprint, control, schemas, route contracts, research anchors, or tests.
Do not wait for perfect documents before starting Layer 1.
```

---

## 1. Research Foundation

Incremental delivery reduces risk by building small, testable slices instead of large unverified systems. Aurora must apply that principle to MT5 source because MQL5 runtime timing and FileIO behavior can fail silently if broad work is loaded into the wrong lane.

Reference:

```text
https://en.wikipedia.org/wiki/Incremental_build_model
```

MQL5 `OnTimer()` has one timer per program and does not queue a new Timer event when one is already queued or processing. This means a broad all-at-once EA implementation can destroy cadence before correctness is even visible.

Reference:

```text
https://www.mql5.com/en/docs/event_handlers/ontimer
```

Aurora translation:

```text
Build small.
Measure heartbeat pressure.
Publish degraded truth.
Do not hide heavy work inside OnTimer.
```

---

## 2. What This Blueprint Owns

This blueprint owns:

```text
planned-system completion ladder
phase order
phase gates
coding-start gate
Layer 1 first-source boundary
what is required before MT5 source
what must remain blocked
acceptance criteria for moving phases
```

---

## 3. What This Blueprint Must Not Own

This blueprint must not own:

```text
full guidebook doctrine
final MQL5 code
Python worker implementation
formula math
trading strategy
runtime proof claims
compile proof claims
```

---

## 4. Current Phase State

```text
Guidebook overview set: COMPLETE — 16 / 16
Post-guidebook scaffold: CREATED
Super Index / Run Router: CREATED / DRAFT AUTHORITY
Decision State Register: OPERATIONAL
Runtime Owner Blueprint: DETAILED
Logical Layer Blueprint: DETAILED
Build Phase Blueprint: THIS FILE
MT5 source implementation: HOLD UNTIL CONTRACT GATE IS COMPLETE
```

---

## 5. Planned-System Completion Ladder

The required path is:

```text
1. Detail Runtime Owner Blueprint.
2. Detail Logical Layer Blueprint.
3. Detail Build Phase Blueprint.
4. Define FileIO / route ownership contract.
5. Create minimum governance schema contracts.
6. Create/update research indexes with required official-source anchors.
7. Create prompt/workflow templates only where they help future layer work.
8. Define Layer 1 source plan and tests.
9. Start MT5 Layer 1 only.
```

This ladder is not optional.

It is also not an excuse to delay coding forever.

---

## 6. Phase 1 — Overview Doctrine Complete

Status:

```text
COMPLETE — 16 / 16 guidebooks
```

Evidence:

```text
docs/00 through docs/15 exist
Main Page and Handoff list 16 / 16 complete
```

No more overview guidebooks should be added unless a new need is proven.

---

## 7. Phase 2 — Scaffold and Control Spine

Status:

```text
CREATED / NEEDS TARGETED DETAILING
```

Includes:

```text
blueprint/
control/
governance/
research/
prompts/
archive/
mt5/
```

Important:

```text
Scaffold existence is not implementation proof.
Scaffold existence is not compile proof.
Scaffold existence is not runtime proof.
```

---

## 8. Phase 3 — Blueprint Detailing

Required blueprint artifacts:

```text
blueprint/02_RUNTIME_OWNER_BLUEPRINT.md
blueprint/03_LOGICAL_LAYER_BLUEPRINT.md
blueprint/04_BUILD_PHASE_BLUEPRINT.md
```

These must be detailed enough to answer:

```text
Which owner owns Layer 1?
What does Layer 1 produce?
What is forbidden in Layer 1?
What comes after Layer 1?
What contracts must exist before source begins?
```

---

## 9. Phase 4 — FileIO / Route Ownership Contract

Required before source:

```text
blueprint/07_FILEIO_ROUTE_OWNERSHIP_CONTRACT.md
```

Must answer:

```text
Who owns FileOpen/FileWrite/FileMove/FileFlush/FileIsExist?
What can physically block publication?
What cannot block publication?
What is the temp-to-final pattern?
What route paths are conceptual vs approved?
How are generated files verified?
```

---

## 10. Phase 5 — Minimum Governance Schema Contracts

Required before source:

```text
governance/schemas/01_MINIMUM_GOVERNANCE_SCHEMA_CONTRACTS.md
```

Minimum schemas:

```text
manifest
runtime telemetry
owner status
layer status
```

These schemas are needed before runtime claims can be honest.

---

## 11. Phase 6 — Research Anchors

Research indexes must contain official-source anchors for implementation work.

Minimum anchors before Layer 1:

```text
MQL5 AccountInfoInteger / AccountInfoDouble / AccountInfoString
MQL5 TerminalInfo*
MQL5 FileOpen / FileMove / FileFlush / FileIsExist
MQL5 OnTimer
```

Research must convert sources into:

```text
constraints
failure states
acceptance checks
no-go rules
```

---

## 12. Phase 7 — Prompt / Workflow Templates

Prompts should be created only where they reduce drift.

Useful templates later:

```text
Layer build prompt template
Layer audit prompt template
Compile-failure triage prompt template
Runtime-output audit prompt template
```

Prompts are execution tools, not source truth.

---

## 13. Phase 8 — Layer 1 Source Plan and Tests

Before source begins, define:

```text
Layer 1 owner
Layer 1 source files planned
Layer 1 input functions
Layer 1 output fields
Layer 1 degraded states
Layer 1 publication surface
Layer 1 governance rows
Layer 1 compile checks
Layer 1 runtime checks
Layer 1 kill/rollback condition
```

Layer 1 must be small.

Layer 1 must not include Layer 2–5.

---

## 14. Phase 9 — Start MT5 Layer 1 Only

First coding target:

```text
Runtime Owner: Foundation Truth Owner
Layer: 1 — Account / Portfolio / Prop Rule Truth
```

Allowed in first source slice:

```text
account identity shell
basic AccountInfo* capture
account status publication shell
minimum manifest/runtime/owner/layer status rows
FileIO temp-to-final through approved owner
```

Forbidden in first source slice:

```text
symbol universe scanning
market session logic
market watch quote loop
ranking
buckets
selection
deep evidence
alerts
strategy
external worker
```

---

## 15. Advancement Rules

A phase may advance only when:

```text
required files exist
required owner boundaries are clear
required acceptance criteria are written
required no-go rules are written
contradictions are resolved or explicitly held
```

MT5 source phase may advance only with:

```text
compile output when source changes
runtime generated files/logs when runtime behavior is claimed
manifest proof when publication is claimed
```

---

## 16. No-Go Patterns

Do not allow:

```text
coding all Runtime Owners at once
coding all Foundation layers at once
using coding ASAP to skip planned contracts
waiting for perfect documentation forever
claiming scaffold equals implementation
claiming source exists before .mq5/.mqh exists
claiming compile proof without compile output
claiming runtime proof without runtime outputs
```

---

## 17. Acceptance Criteria

This blueprint is acceptable if:

```text
planned-system completion ladder is explicit
MT5 source remains held until contracts are ready
coding is not delayed beyond the necessary contract gate
Layer 1 is clearly first source target
big-bang EA scaffolding is forbidden
minimum governance schemas and FileIO contract are required before source
```

---

## 18. Final Build Phase Law

```text
Finish the planned foundations.
Then code Layer 1.
No shortcut river.
No endless swamp.
```