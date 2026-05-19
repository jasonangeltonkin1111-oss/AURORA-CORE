# 05 DECISION STATE REGISTER

## Purpose
Operational decision-state register for AURORA CORE baseline status, transition control, and evidence-gated upgrades.

## What belongs here
- Baseline decision states for architecture, scaffold, worker boundary, and permission posture.
- Explicit state-transition laws that prevent wording-based bypasses.
- Evidence requirements required before any status upgrade claim.

## What must not belong here
- MT5 implementation code, EA files, `.mqh` logic, or Python worker implementation files.
- Trading approval, live-use approval, directional-alert approval, auto-trading approval, or prop-firm-readiness claims.
- Guidebook duplication or replacement of `docs/00` through `docs/15` doctrinal ownership.

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
| Blueprint scaffold | CREATED / NEEDS DETAILING |
| Control spine scaffold | CREATED / NEEDS DETAILING |
| Governance schema scaffold | CREATED / NEEDS SCHEMAS |
| Research scaffold | CREATED / NEEDS SOURCES |
| Prompt scaffold | CREATED / NEEDS PROMPTS |
| Archive scaffold | CREATED / EVIDENCE ONLY |
| MT5 source planning scaffold | CREATED / NO IMPLEMENTATION |
| MT5 source implementation | HOLD UNTIL STRUCTURE + CONTRACTS ARE READY |
| External calculation worker | PROCEED TO DESIGN / UNPROVEN IMPLEMENTATION |
| Python + file snapshot bridge | BEST FIRST CANDIDATE |
| WebRequest main bridge | HOLD |
| Sockets bridge | CONSIDER LATER |
| C/C++ worker | HOLD AS LATER OPTIMIZATION |
| Directional alerts | HOLD |
| Setup strategy layer | QUARANTINE |
| Auto-trading | BLOCKED |
| Trading edge claim | UNPROVEN |

## State Transition Rules
- HOLD may not become PROCEED without source/evidence reason.
- QUARANTINE may not become PROCEED without falsifier, baseline, data requirement, cost model, kill condition, and first evidence review.
- UNPROVEN may not become VALIDATED without outcome evidence, null model, cost/slippage model, and sample/regime review.
- BLOCKED may not be bypassed by wording changes such as “alerts only,” “paper only,” or “operator assist.”
- CREATED means scaffold/file exists only; it does not prove implementation, compile, runtime, or edge.

## Evidence Required to Upgrade State
- Source truth upgrade requires current file inspection.
- Compile readiness requires compile output.
- Runtime readiness requires runtime logs/generated outputs.
- Publication readiness requires generated files and manifest proof.
- External worker readiness requires request/result/schema/hash/freshness validation proof.
- Edge readiness requires validation/outcome evidence after costs and null model.
- Prop-firm readiness requires current prop-rule profile evidence.

## Source-of-truth relationship
- Active doctrinal source remains `docs/00` through `docs/15` guidebooks.
- MT5 remains owner of broker truth, publication, permission blocks, and validation of worker outputs.
- External worker may calculate only; it may not become broker truth, publication owner, permission owner, or execution brain.

## Next acceptable work
- Keep this table current when decisions are explicitly upgraded with evidence.
- Add decision-change entries that point to concrete files/logs/outputs proving the upgrade.
- Keep transition and evidence rules strict; reject language-only upgrades.

## No-go rules
- Do not move existing active guidebooks out of `docs/` without an explicit migration run.
- Do not claim readiness states without file/runtime evidence.
- Do not introduce implementation files, execution permissions, or runtime-output spam in Git during scaffold runs.

## Scaffold notice
```text
This folder scaffold is now created.
Existing guidebooks remain in docs/ until an explicit migration run is approved.
Do not duplicate guidebook content here.
```
