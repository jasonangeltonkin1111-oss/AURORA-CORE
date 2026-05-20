# 05 DECISION STATE REGISTER

## Purpose
Operational decision-state register for AURORA CORE baseline status, transition control, and evidence-gated upgrades.

This file prevents Aurora from confusing speed with skipped work.

Coding should begin as soon as the required planned-system contracts are ready, but coding must not bypass the blueprint, control, governance, research, prompt, route, and test artifacts already planned.

## What belongs here
- Baseline decision states for architecture, scaffold, worker boundary, and permission posture.
- Explicit state-transition laws that prevent wording-based bypasses.
- Evidence requirements required before any status upgrade claim.
- Coding-start gate status.
- Planned-system completion ladder status.

## What must not belong here
- MT5 implementation code, EA files, `.mqh` logic, or Python worker implementation files.
- Trading approval, live-use approval, directional-alert approval, auto-trading approval, or prop-firm-readiness claims.
- Guidebook duplication or replacement of `docs/00` through `docs/15` doctrinal ownership.

## Current source truth note

This register is subordinate to active source truth in `mt5/` and the navigation bridge in `control/01_CURRENT_SOURCE_TRUTH_MAP.md`.

Where this file still contains old planning-era states, treat those rows as historical and patch them to match current source status before using them as routing authority.

## Decision-state baseline table
| Decision area | Baseline state |
|---|---|
| AURORA CORE identity | PROCEED |
| Runtime Owner top-level structure | PROCEED |
| 23 logical layers under Runtime Owners | PROCEED |
| Guidebook overview set | COMPLETE — 16 / 16 |
| Current docs/ location | ACTIVE |
| Guidebook migration to guidebooks/ | HOLD UNTIL APPROVED |
| Post-guidebook Phase 1 scaffold | CREATED |
| Super Index / Run Router | ACTIVE / CURRENT ROUTER AUTHORITY |
| Blueprint scaffold | CREATED / NEEDS DETAILING |
| Control spine scaffold | CREATED / NEEDS DETAILING |
| Governance schema scaffold | CREATED / NEEDS SCHEMAS |
| Research scaffold | CREATED / NEEDS SOURCES |
| Prompt scaffold | CREATED / NEEDS PROMPTS |
| Archive scaffold | CREATED / EVIDENCE ONLY |
| MT5 source planning scaffold | ACTIVE / IMPLEMENTATION EXISTS (LIMITED SCOPE) |
| Planned-system completion ladder | PROCEED |
| Runtime Owner Blueprint | NEXT / REQUIRED BEFORE MT5 SOURCE |
| Logical Layer Blueprint | REQUIRED BEFORE MT5 SOURCE |
| Build Phase Blueprint | REQUIRED BEFORE MT5 SOURCE |
| FileIO / route ownership contract | REQUIRED BEFORE MT5 SOURCE |
| Minimum governance schemas | REQUIRED BEFORE MT5 SOURCE |
| Layer 1 source plan and tests | REQUIRED BEFORE MT5 SOURCE |
| MT5 source implementation | ACTIVE (LIMITED: Runtime 0, Runtime 1 Layer 1, Runtime 2 skeleton, Runtime 7) |
| External calculation worker | PROCEED TO DESIGN / UNPROVEN IMPLEMENTATION |
| Python + file snapshot bridge | BEST FIRST CANDIDATE |
| WebRequest main bridge | HOLD |
| Sockets bridge | CONSIDER LATER |
| C/C++ worker | HOLD AS LATER OPTIMIZATION |
| Directional alerts | HOLD |
| Setup strategy layer | QUARANTINE |
| Auto-trading | BLOCKED |
| Trading edge claim | UNPROVEN |

## Planned-System Completion Ladder (historical planning ladder)
The next phase is not endless planning and not immediate coding.

The intended path is:

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

Note: this ladder is retained as historical scaffold context; active source has already started in limited scope.
```

Coding starts after the required contracts exist, not after every possible document is perfect.

But coding must not skip planned non-code system foundations that prevent drift.

## State Transition Rules
- HOLD may not become PROCEED without source/evidence reason.
- QUARANTINE may not become PROCEED without falsifier, baseline, data requirement, cost model, kill condition, and first evidence review.
- UNPROVEN may not become VALIDATED without outcome evidence, null model, cost/slippage model, and sample/regime review.
- BLOCKED may not be bypassed by wording changes such as “alerts only,” “paper only,” or “operator assist.”
- CREATED means scaffold/file exists only; it does not prove implementation, compile, runtime, or edge.
- NEXT means it is the next planned artifact to detail, not a permission to skip later planned artifacts.
- REQUIRED BEFORE MT5 SOURCE means real MT5 implementation must hold until the requirement exists.

## Evidence Required to Upgrade State
- Source truth upgrade requires current file inspection.
- Compile readiness requires compile output.
- Runtime readiness requires runtime logs/generated outputs.
- Publication readiness requires generated files and manifest proof.
- External worker readiness requires request/result/schema/hash/freshness validation proof.
- Edge readiness requires validation/outcome evidence after costs and null model.
- Prop-firm readiness requires current prop-rule profile evidence.
- MT5 source-start readiness requires the planned-system contract gate to exist and be auditable.

## Source-of-truth relationship
- Active doctrinal source remains `docs/00` through `docs/15` guidebooks.
- `control/00_SUPER_INDEX_RUN_ROUTER.md` routes work and prevents skipped planned phases.
- MT5 remains owner of broker truth, publication, permission blocks, and validation of worker outputs.
- External worker may calculate only; it may not become broker truth, publication owner, permission owner, or execution brain.

## Next acceptable work
- Detail the Runtime Owner Blueprint.
- Keep this table current when decisions are explicitly upgraded with evidence.
- Add decision-change entries that point to concrete files/logs/outputs proving the upgrade.
- Keep transition and evidence rules strict; reject language-only upgrades.

## No-go rules
- Do not move existing active guidebooks out of `docs/` without an explicit migration run.
- Do not claim readiness states without file/runtime evidence.
- Do not introduce MT5 source implementation before the planned-system contract gate exists.
- Do not use “coding ASAP” as permission to skip blueprint/control/governance/research/prompt contracts already planned.
- Do not introduce execution permissions or runtime-output spam in Git during scaffold/planning runs.

## Scaffold notice
```text
This folder scaffold is now created.
Existing guidebooks remain in docs/ until an explicit migration run is approved.
Do not duplicate guidebook content here.
```
