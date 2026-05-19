# AURORA CORE — VALIDATION METHODS INDEX

**System:** AURORA CORE  
**Role:** Validation-method research index, proof boundary map, source/compile/runtime/publication evidence rules, and Layer 1 — Account / Portfolio / Prop Rule Truth acceptance method.  
**Status:** ACTIVE RESEARCH INDEX — not runtime proof and not edge validation.

---

## 0. Purpose

This index defines how Aurora evaluates whether a planned source layer has actually been built, compiled, run, and proven at the correct evidence level.

This file is not about trading edge yet.

For the first MT5 source slice, this file is about system validation for:

```text
Layer 1 — Account / Portfolio / Prop Rule Truth
```

Core law:

```text
Layer validation proves only the layer behavior it directly tests.
It does not prove trading edge, live safety, prop-firm readiness, or future layers.
```

---

## 1. What Belongs Here

```text
source inspection method
compile proof method
runtime proof method
publication proof method
governance row proof method
negative test method
rollback/kill method
Layer 1 — Account / Portfolio / Prop Rule Truth acceptance method
```

---

## 2. What Must Not Belong Here

```text
MT5 implementation code
strategy edge validation results
backtest profit claims
live trading approval
setup alert approval
auto-trading approval
full duplicated guidebooks
runtime-generated output spam
```

---

## 3. Naming Law

Every layer reference must include the layer number and proper name.

Correct:

```text
Layer 1 — Account / Portfolio / Prop Rule Truth
Layer 2 — Market Open / Closed Truth
Layer 4 — Market Watch Truth
```

Incorrect:

```text
Layer 1
L1
first layer
```

Short codes may appear only after the full name is stated in the same section.

---

## 4. Evidence Classes for Source Work

For Aurora source work, use these practical evidence classes:

```text
0. Claim / intent / plan
1. AI reasoning
2. User report / screenshot / pasted output
3. Direct repo/source file inspection
4. Compile output / static validation
5. Runtime generated logs/files/manifest rows
6. Repeated runtime smoke across restart/session conditions
7. Forward demo/live evidence later
```

Layer 1 — Account / Portfolio / Prop Rule Truth can reach only source/compile/runtime publication proof in the first source phase.

It cannot prove edge.

---

## 5. Source Inspection Method

Before claiming source truth:

```text
inspect current active files
confirm owner boundary
confirm no duplicate owner
confirm no shadow route
confirm no forbidden functions for the layer
confirm exact changed files
```

For Layer 1 — Account / Portfolio / Prop Rule Truth, source inspection must confirm it does not include:

```text
symbol universe scanning
SymbolInfoTick quote loops
CopyRates
CopyTicks
MarketBookGet
indicator handles
alerts
WebRequest
external worker logic
strategy logic
trade execution
```

---

## 6. Compile Proof Method

Compile proof requires:

```text
actual MetaEditor/compiler output
file path compiled
error count
warning count
build timestamp
```

Compile success proves:

```text
syntax/basic build compatibility for the compiled files
```

Compile success does not prove:

```text
runtime behavior
publication
edge
permission
live safety
```

---

## 7. Runtime Proof Method

Runtime proof requires actual generated runtime evidence.

For Layer 1 — Account / Portfolio / Prop Rule Truth, runtime proof should include:

```text
EA initialized
heartbeat/timer ran
account fields captured
publication attempted
manifest row generated
runtime telemetry row generated
owner status row generated
layer status row generated
```

No runtime files/logs = no runtime proof.

---

## 8. Publication Proof Method

Publication proof requires alignment between:

```text
final file exists
final file size > 0 where expected
manifest row says written
manifest route matches actual path
write status is clean/degraded/partial/failed honestly
```

File existence alone is weak.

Manifest alone is weak.

They must align.

---

## 9. Governance Row Proof Method

Layer 1 — Account / Portfolio / Prop Rule Truth must generate or plan to generate these rows:

```text
manifest row
runtime telemetry row
owner status row
layer status row
```

Required truth:

```text
owner = Foundation Truth Owner
layer = Layer 1 — Account / Portfolio / Prop Rule Truth
status = not_started / shell_printed / partial / complete / failed / degraded
```

---

## 10. Negative Test Method

Negative tests are required because happy-path files lie.

Layer 1 — Account / Portfolio / Prop Rule Truth negative cases:

```text
FileOpen fails / invalid handle
FileMove fails
manifest write fails
account info unavailable / terminal disconnected
prop-rule profile unknown
runtime telemetry missing
owner/layer row missing
```

Expected behavior:

```text
file publication failure is visible
review/trade remains blocked where relevant
no fake clean state
no missing expected diagnostic state
```

---

## 11. Rollback / Kill Method

A layer source patch must be rolled back or held if:

```text
compile fails
runtime fails to print expected files
manifest contradicts physical files
owner status says complete but layer row fails
Layer 1 includes forbidden Layer 2+ behavior
FileIO route is invented outside the approved contract
```

Decision:

```text
HOLD / TEST FIRST
```

---

## 12. Layer 1 — Account / Portfolio / Prop Rule Truth Acceptance Method

Layer 1 — Account / Portfolio / Prop Rule Truth is acceptable only if:

```text
source scope is limited to account/terminal truth shell plus proof rows
AccountInfo* fields are captured or honestly unavailable
prop-rule profile can be unknown without blocking publication
publication route uses approved FileIO owner pattern
manifest/runtime/owner/layer proof rows exist or source plan defines them before coding
compile proof exists after source is created
runtime proof exists before runtime readiness is claimed
no symbols/ranking/buckets/alerts/strategy/external-worker logic appears
```

---

## 13. Final Validation Method Law

```text
A layer is not done because it was written.
It is done when its owner boundary, compile result, runtime output, publication proof, and failure states survive inspection.
```