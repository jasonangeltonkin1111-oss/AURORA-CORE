# AURORA CORE — BUILD PHASE BLUEPRINT

**System:** AURORA CORE  
**Role:** Planned-system completion ladder, phase gates, Runtime 0 first-source boundary, and anti-endless-planning / anti-big-bang-coding control.  
**Status:** DETAILED BLUEPRINT — required before MT5 source implementation starts.

---

## 0. Purpose

This blueprint defines the build sequence from completed overview guidebooks into real MT5 source implementation.

It exists to prevent two opposite failures:

```text
1. endless planning that never reaches code
2. rushed coding that skips Runtime 0, FileIO, folder creation, heartbeat, telemetry, and governance proof
```

Core law:

```text
Runtime 0 — Governance / Internal Control Owner is the first source build.
Layer 1 — Account / Portfolio / Prop Rule Truth starts only after Runtime 0 proves folder creation, FileIO, heartbeat, manifest, telemetry, status rows, and diagnostics.
Do not wait for perfect documents forever, but do not skip the internal runtime foundation.
```

---

## 1. Research Foundation

Incremental delivery reduces risk by building small, testable slices instead of large unverified systems.

MQL5 `OnTimer()` has one timer per program and does not queue a new Timer event when one is already queued or processing. A broad all-at-once EA implementation can destroy cadence before correctness is visible.

Reference:

```text
https://www.mql5.com/en/docs/event_handlers/ontimer
```

MQL5 file operations are sandboxed, `FileOpen()` returns `INVALID_HANDLE` on failure, `FolderCreate()` creates folders relative to the Files/Common sandbox, `FileMove()` needs `FILE_REWRITE` when replacing an existing file, and frequent `FileFlush()` can affect program speed.

References:

```text
https://www.mql5.com/en/docs/files/fileopen
https://www.mql5.com/en/docs/files/foldercreate
https://www.mql5.com/en/docs/files/filemove
https://www.mql5.com/en/docs/files/fileflush
```

Aurora translation:

```text
Build Runtime 0 first.
Prove folder creation and file writing before account/market truth.
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
Runtime 0 first-source boundary
Layer 1 later-source boundary
what is required before source begins
what must remain blocked
acceptance criteria for moving phases
```

---

## 3. Current Phase State

```text
Guidebook overview set: COMPLETE — 16 / 16
Post-guidebook scaffold: CREATED
Super Index / Run Router: CREATED / DRAFT AUTHORITY
Decision State Register: OPERATIONAL BUT MAY NEED STATUS SYNC
Runtime Owner Blueprint: NEEDS RUNTIME 0 SYNC IF NOT PATCHED
Logical Layer Blueprint: NEEDS RUNTIME 0 SYNC IF NOT PATCHED
Build Phase Blueprint: THIS FILE / RUNTIME 0 FIRST
MT5 source implementation: HOLD UNTIL RUNTIME 0 SOURCE PLAN IS ACCEPTED
```

---

## 4. Planned-System Completion Ladder

Completed foundation artifacts:

```text
1. Guidebook overview set — COMPLETE
2. Runtime Owner Blueprint — CREATED / NEEDS RUNTIME 0 AS FIRST SOURCE OWNER
3. Logical Layer Blueprint — CREATED / NEEDS RUNTIME 0 INTERNAL LAYERS
4. Build Phase Blueprint — THIS FILE / RUNTIME 0 FIRST
5. FileIO / route ownership contract — CREATED
6. Minimum governance schema contracts — CREATED
7. MT5 source folder contract — CREATED / RUNTIME 0 FIRST
8. Runtime 0 — Governance / Internal Control Owner source plan and tests — CREATED
```

Correct implementation ladder:

```text
1. Runtime 0 — Governance / Internal Control Owner source implementation.
2. Compile Runtime 0 source.
3. Runtime-smoke Runtime 0 in MT5.
4. Verify account-safe folder creation.
5. Verify Runtime Status.txt, Workbench/Manifest.txt, Workbench/Status.txt, and Workbench/Diagnostics.txt.
6. Verify manifest, runtime telemetry, Runtime 0 owner status, and Runtime 0 layer status rows.
7. Audit Runtime 0 outputs and failure states.
8. Only then start Layer 1 — Account / Portfolio / Prop Rule Truth.
```

---

## 5. Runtime 0 First Source Phase

First coding target:

```text
Runtime Owner: Runtime 0 — Governance / Internal Control Owner
Internal layers:
Layer 0.1 — Startup / Runtime Identity
Layer 0.2 — Scheduler / Heartbeat / Breathing Spine
Layer 0.4 — Governance / Manifest / Telemetry
Support owner: Runtime 7 — Publication Owner for FileIO/routes only
```

Allowed in first source slice:

```text
EA OnInit / OnTimer / OnDeinit shell
EventSetTimer / EventKillTimer
runtime identity
heartbeat counter and duration
account-safe folder root attempt
Runtime Status.txt
Workbench/Manifest.txt
Workbench/Status.txt
Workbench/Diagnostics.txt
manifest row
runtime telemetry row
Runtime 0 owner status row
Runtime 0 layer status rows
FileIO through Runtime 7 publication support
```

Forbidden in first source slice:

```text
Layer 1 — Account / Portfolio / Prop Rule Truth account capture beyond route labels
symbols
market sessions
quotes
ranking
buckets
selection
deep evidence
alerts
strategy
external worker
trading
```

---

## 6. Layer 1 Later Source Phase

Layer 1 — Account / Portfolio / Prop Rule Truth remains the first market/account truth layer, but it is not the first EA source build.

It starts only after Runtime 0 passes.

Layer 1 later target:

```text
Runtime Owner: Runtime 1 — Foundation Truth Owner
Layer: Layer 1 — Account / Portfolio / Prop Rule Truth
```

Layer 1 later may include:

```text
AccountInfoInteger / AccountInfoDouble / AccountInfoString capture
account status publication
prop-rule profile placeholder
Layer 1 owner/layer status rows
```

Layer 1 later may not include:

```text
symbol universe scanning
sessions
quotes
ranking
buckets
selection
alerts
strategy
external worker
```

---

## 7. Advancement Rules

Runtime 0 may advance to Layer 1 only when:

```text
Runtime 0 source compiles.
Runtime 0 EA initializes.
Timer heartbeat runs.
Account-safe root folder is created or failure is honestly printed.
Runtime Status.txt prints or failure is honestly printed.
Workbench/Manifest.txt prints or failure is honestly printed.
Workbench/Status.txt prints or failure is honestly printed.
Workbench/Diagnostics.txt prints or failure is honestly printed.
Runtime telemetry exists.
Runtime 0 owner status exists.
Runtime 0 layer status rows exist.
No Runtime 1+ market/account truth logic appears except route labels.
```

MT5 source phase may claim readiness only with:

```text
compile output when source changes
runtime generated files/logs when runtime behavior is claimed
manifest proof when publication is claimed
```

---

## 8. No-Go Patterns

Do not allow:

```text
coding Layer 1 before Runtime 0 proves folder/FileIO writing
coding all Runtime Owners at once
coding all Runtime 0 layers at once if not needed
using coding ASAP to skip Runtime 0
waiting for perfect documentation forever
claiming scaffold equals implementation
claiming source exists before .mq5/.mqh exists
claiming compile proof without compile output
claiming runtime proof without runtime outputs
```

---

## 9. Acceptance Criteria

This blueprint is acceptable if:

```text
Runtime 0 is the first source target.
Layer 1 — Account / Portfolio / Prop Rule Truth is held until Runtime 0 passes.
Folder creation and FileIO publication are treated as first proof.
Big-bang EA scaffolding is forbidden.
Runtime 7 publication support is allowed only for FileIO/route proof.
```

---

## 10. Final Build Phase Law

```text
Before Aurora knows the account or market, Aurora must prove it can create its home, breathe, write, and report failure.
Runtime 0 first. Then Layer 1.
No shortcut river. No endless swamp.
```