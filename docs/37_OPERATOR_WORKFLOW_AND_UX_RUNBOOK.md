# 37 OPERATOR WORKFLOW AND UX RUNBOOK

## Purpose
This runbook tells a human operator where to look first, what each surface means, what may be exported for review, and what must never be inferred from Aurora outputs.

It is workflow documentation only. It does not create runtime logic, routes, FileIO authority, score authority, selection authority, alert authority, trade permission, execution authority, prop-firm readiness, or edge validation.

## Source authority
Use this order when an operator-facing surface disagrees with another source:

1. Current repo source/code/config.
2. Current runtime outputs from MT5/Common/Files, Workbench, logs, and manifests.
3. README and control files.
4. Board/Dossier/Workbench surface standards.
5. This runbook.
6. Reports, screenshots, prompts, memory, and AI reasoning.

This runbook is a navigation layer, not an implementation owner.

## Operator first-click order
When Aurora is running, inspect in this order:

```text
1. Market Board
2. Workbench / Status / Diagnostics when Board shows stale, degraded, failed, blocked, or starved state
3. Selection Desk / Selection Index when Board shows a current inspection basket
4. Selected symbol Dossier(s)
5. Trader-chat export block only after the Board and Dossier both show the needed source, missing, degraded, and stale evidence labels
6. Trade Journal only for later bookkeeping / forensic linkage, not permission
```

Do not start from a Dossier alone. A Dossier can be rich but stale, partial, not selected, or downstream of blocked upstream truth.

Do not start from Global Top 10 alone. Global Top 10 is an inspection basket, not a trade list.

## Surface jobs

| Surface | Human job | Allowed meaning | Forbidden meaning |
|---|---|---|---|
| Market Board | Fast cockpit | health, freshness, blockers, selected inspection order, permission lock | strategy proof, entry signal, trade approval |
| Workbench / Diagnostics | Proof and debug | owner proof, route proof, stale/degraded reasons, timing pressure | trader cockpit, signal page |
| Selection Desk | Selection/readback navigation | Groups/Global/Selection Index inspection surfaces | parent route rank ownership, best trades |
| Dossier | Per-symbol truth | rich symbol state, source quality, missing/degraded evidence | independent permission, isolated trade trigger |
| Trader-chat export | Manual review context | labelled truth packet for discussion | Aurora-approved trade or proven edge |
| Trade Journal | Forensic linkage later | record of human/MT5 facts and packet linkage | reason certainty, edge validation, permission grant |

## Board operator checklist
The Board must answer these before a human exports or acts on anything:

```text
Is Aurora alive?
Is the Board fresh or stale?
Is publication physically working?
Is the system over budget or starved?
Is Layer 1 risk/prop state configured and safe enough for review?
Are Layers 2-5 complete enough for the symbol universe?
What is blocked, degraded, stale, or incomplete?
Is there a current Global Top 10 inspection basket?
Is there an L17 evidence-budget queue?
Are L18-L22 deep evidence layers present, missing, stale, or degraded?
What is explicitly allowed?
What is explicitly not allowed?
```

If the Board cannot answer those questions, the next action is Workbench/Diagnostics review, not trading.

## Dossier operator checklist
Before using a symbol Dossier for manual review, verify:

```text
symbol matches current broker/server/account scope
Dossier generated time is acceptable
L2 market/session truth is present or its absence is labelled
L3 specs/value/margin truth is present or its absence is labelled
L4 quote/spread/tick freshness is present or its absence is labelled
L5 gate state is visible
current selection truth says whether the symbol is L16 visible and/or L17 queued
missing evidence list is visible for later L18-L22 layers
trade_permission=false remains visible
entry_signal=false remains visible
execution=false remains visible
```

A Dossier with missing or degraded evidence may still be useful for truth export. It is not trade permission.

## Manual review and trader-chat export rule
Trader-chat export may exist when the packet is clearly labelled as truth context. Export must preserve:

```text
source files or sections
packet creation time
symbol
cycle/source identifiers when available
upstream layers present
missing_evidence_list
degraded_evidence_list
stale_evidence_list
evidence_completeness_pct
review_warnings
permission_block_reason
manual_review_packet_available
trader_chat_export_available
entry_signal=false
trade_allowed=false
auto_trade_allowed=false
live_allowed=false
prop_firm_ready=false
edge_validated=false
```

Allowed wording:

```text
selected for inspection
watch-only export
manual review context
evidence-budget queued
missing evidence
stale evidence
degraded evidence
trade blocked
permission blocked
```

Forbidden wording:

```text
directional certainty phrase
opposite-direction certainty phrase
probability marketing
best trade now
Aurora approved trade
prop-rule cleared
edge proven
institution-grade flow certainty
smart money confirmed
```

## Incomplete/degraded state handling
Incomplete, degraded, stale, partial, unknown, or mismatched data must be visible.

These states may block review quality, trade permission, alerts, selection promotion, and validation status.

They must not hide physical file publication unless the failure is route, FileIO, permission, disk, path, or source-object failure.

## Overtrading guardrail
Aurora outputs are designed to reduce hunting, not create pressure to trade.

Rules:

```text
Zero trades is valid.
No selected basket is valid.
A selected basket is attention, not action.
A queued evidence packet is review context, not entry permission.
Low spread is not edge.
Movement is not edge.
Near high/low is not direction.
Correlation/diversity is basket hygiene, not expectancy.
```

If a human feels pressure to trade because a surface is full of ranked symbols, the workflow has failed and must be tightened.

## Runtime visual-output test gate
Do not patch Board/Dossier renderer wording from source taste alone. Renderer wording changes require current output evidence.

Before changing runtime renderer text, capture or provide:

```text
current Market Board output
one selected-symbol Dossier output
Workbench/status output when Board reports stale/degraded/failed/starved state
exact confusing line(s)
why the line could make a human infer trade permission, signal, or prop-rule clearance
the smallest replacement wording
expected before/after output
MetaEditor compile proof after code change
runtime output proof after code change
```

Special watch labels:

```text
TRADING READINESS
Best Current Use
READY_FOR_MANUAL_REVIEW_EXPORT
GLOBAL TOP 10 - INSPECTION ORDER
TOP 5 PER SELECTED GROUP
manual trade-review queue
```

These labels are not automatically wrong. They become patch targets only if current output makes inspection feel like trade instruction, hides degraded/stale truth, or weakens the permission lock.

## Escalation rules

```text
Board stale -> inspect Workbench/Diagnostics first.
Publication failed -> inspect FileIO/route/workbench proof first.
Layer mismatch -> inspect owning layer output, not renderer text.
Worker stale/offline -> inspect Runtime 3/Gateway status first.
Dossier contradicts Board -> inspect source owner packet and runtime timestamp.
Global Top 10 looks like trade list -> treat as UX bug.
Any permission flag true without validation proof -> STOP and hand to overseer.
```

## Acceptance criteria
This workflow is acceptable only when a human can answer, in under one minute:

```text
What do I open first?
What is current?
What is stale?
What is incomplete?
What is degraded?
What is blocked?
What is selected for inspection?
What may I export for manual review?
What is explicitly not allowed?
Where is the proof if something looks wrong?
```

## Final workflow law

```text
Board tells the operator where to look.
Workbench proves what happened.
Dossier explains one symbol.
Selection Desk organizes inspection.
Trader-chat export packages context.
None of them grant trade permission without future validation proof.
```
