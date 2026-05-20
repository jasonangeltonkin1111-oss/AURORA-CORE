# AURORA CORE — SEED / SENTINEL INHERITANCE AUDIT BEFORE LAYER 1 SOURCE

**System:** AURORA CORE  
**Run mode:** AUDIT / SOURCE PLANNING  
**Status:** BLOCKING INHERITANCE AUDIT — required before MT5 source implementation starts.  
**Target next source slice:** Layer 1 — Account / Portfolio / Prop Rule Truth.  

---

## 0. Purpose

This audit records what AURORA CORE should inherit from AURORA SEED and Aurora Sentinel before writing the first MT5 source file.

Core law:

```text
Do not build AURORA CORE MT5 source from blank imagination.
Inherit the proven folder/FileIO/publication lessons from Seed.
Use Sentinel as runtime-law and failure-mode evidence.
Then build Core smaller, cleaner, and layer-by-layer.
```

---

## 1. Evidence Sources Inspected

Seed:

```text
jasonangeltonkin1111-oss/AURORA-SEED
README.md
mt5/AuroraSeed.mq5
mt5/core/AS_Config.mqh
mt5/core/AS_AccountProbe.mqh
mt5/io/AS_ServerPaths.mqh
mt5/io/AS_FileIO.mqh
```

Sentinel:

```text
jasonangeltonkin1111-oss/Aurora-Sentinel-Scanner
README.md
ASC_CORE.MD
```

Evidence rank:

```text
Direct repo/source inspection.
This proves source/document state, not runtime behavior.
```

---

## 2. Seed Findings — What To Inherit

### 2.1 Print-truth-first identity

Seed README states the first mission clearly:

```text
Stay alive, keep printing, expose truth, and never pretend degraded data is valid.
```

Core inheritance:

```text
Layer 1 — Account / Portfolio / Prop Rule Truth must prove startup, heartbeat, account truth, publication, manifest/proof rows, and degraded-state visibility before any market scan/ranking logic exists.
```

### 2.2 Account-safe routing

Seed README and config/source lock account-safe routing:

```text
Aurora Seed Core/<SERVER>/<ACCOUNT_NUMBER>/
```

Seed implementation:

```text
AS_BASE_FOLDER = "Aurora Seed Core"
AS_SERVER_FOLDER = "Upcomers-Server"
AS_AccountFolderName() uses ACCOUNT_LOGIN
AS_BuildServerPaths() builds server_root_folder and account_root_folder
```

Core inheritance:

```text
AURORA CORE must use account-safe routing from the start.
Recommended Core root pattern:
Aurora Core/<SERVER>/<ACCOUNT_NUMBER>/
```

Do not write account-mixed output under one shared folder.

### 2.3 Central path owner

Seed has a single path owner pattern:

```text
mt5/io/AS_ServerPaths.mqh
```

It centralizes:

```text
root folder
account folder
Workbench paths
Dossier paths
Selection Desk paths
External bridge paths
journals/manifests/diagnostics aliases
```

Core inheritance:

```text
Create one Core path owner only.
No random helpers may invent output paths.
```

Recommended Core owner later:

```text
mt5/io/AC_ServerPaths.mqh
```

### 2.4 Compact Workbench pattern

Seed README RUN007 says Runtime Workbench is minimized to:

```text
Status.txt
Logs.txt
Manifest.txt
Diagnostics.txt
```

Seed source later aliases many old surfaces into compact Workbench files.

Core inheritance:

```text
Do not create a sprawling Workbench on first source pass.
Layer 1 — Account / Portfolio / Prop Rule Truth should publish only small account status + minimum governance proof.
```

### 2.5 Last-good-preserved FileIO

Seed FileIO contains strong reusable patterns:

```text
directory tree creation
verified write with readback
FileMove promotion with FILE_REWRITE
last-good preserved when promote fails
non-atomic fallback only when no previous final exists
append flush policy
FileIO metrics
```

Core inheritance:

```text
Core FileIO must inherit the pattern: memory content → temp → verified temp → promote → verify final → manifest/status.
Last-good should be preserved where practical.
```

But Core should not copy Seed FileIO blindly. It should create a smaller Layer 1-safe version first.

### 2.6 Account probe pattern

Seed account probe captures:

```text
ACCOUNT_SERVER
ACCOUNT_COMPANY
ACCOUNT_LOGIN
ACCOUNT_CURRENCY
ACCOUNT_LEVERAGE
ACCOUNT_BALANCE
ACCOUNT_EQUITY
TERMINAL_COMPANY
TERMINAL_NAME
TERMINAL_PATH
TERMINAL_COMMONDATA_PATH
TERMINAL_CONNECTED
TERMINAL_TRADE_ALLOWED
```

It labels degraded state and keeps trade permission false.

Core inheritance:

```text
Layer 1 — Account / Portfolio / Prop Rule Truth should reuse the concept of safe account/terminal probes.
Platform trade flags must remain platform facts only, not Aurora permission.
```

---

## 3. Seed Findings — What Not To Copy Yet

Do not copy Seed's large include graph into Core first source:

```text
layer0
layer1
layer2
layer3
layer4
external
rhythm
nerve
chain supervisor
candidate board
trade history
symbol universe
dossier bootstrap
```

Reason:

```text
Core Layer 1 — Account / Portfolio / Prop Rule Truth must stay small.
Seed has valuable inherited patterns, but it is already far beyond first-source scope.
```

Do not copy:

```text
symbol universe loops
Dossier bootstrap
Candidate Board publisher
Layer 2 broker specs
Layer 3 ranking
External worker bridge
Selection Desk
trade-event bridge
```

before Layer 1 is compiled, runtime-smoked, printed, and audited.

---

## 4. Sentinel Findings — What To Inherit Conceptually

Sentinel README establishes source-of-truth rule:

```text
MT5 compile-path code is the only authority for runtime behavior.
If documentation conflicts with compile-path code, code wins.
```

Core inheritance:

```text
Once Core source exists, current active MT5 source outranks guidebook prose for implementation truth.
```

Sentinel ASC_CORE.MD provides runtime laws:

```text
1 beat per second heartbeat governance
Scan → Write → Read breathing
lane ownership
bounded lane admission
no hidden compute in render
selected-symbol single owner chain
warmup vs steady-state honesty
explicit missingness
failure honesty
operator trust over appearance
```

Core inheritance:

```text
Use Sentinel as runtime-law and failure-mode reference.
Do not copy Sentinel complexity into Core Layer 1.
```

---

## 5. Inheritance Decision

### Adopt now

```text
Seed account-safe routing concept
Seed central path owner pattern
Seed FileIO verified/last-good preserved concept
Seed account probe concept
Seed print-truth/degraded-publication law
Sentinel heartbeat/lane/breathing law
Sentinel no hidden ownership law
Sentinel source-of-truth hierarchy once source exists
```

### Hold until later

```text
Seed symbol universe
Seed Dossiers
Seed Candidate Board
Seed Selection Desk
Seed external worker bridge
Seed Layer 2/3/4 implementation
Sentinel full lane system
Sentinel HUD/render laws beyond Core publication needs
```

### Kill for Layer 1

```text
broad include graph
all-owner scaffold
symbol scanning
ranking
alerts
strategy
external worker implementation
trade-event bridge
```

---

## 6. Required Core Source Shape After Audit

First source should be small:

```text
mt5/AuroraCore.mq5
mt5/core/AC_Config.mqh
mt5/core/AC_Runtime.mqh
mt5/core/AC_AccountProbe.mqh
mt5/io/AC_ServerPaths.mqh
mt5/io/AC_FileIO.mqh
```

Optional only if required:

```text
mt5/shared/AC_Text.mqh
```

Do not create all Runtime Owner files yet.

Do not create folder scaffolds for future layers in code yet.

---

## 7. Required Layer 1 — Account / Portfolio / Prop Rule Truth Outputs

Minimum outputs:

```text
Account Status shell
Manifest proof row/file
Runtime Telemetry row/file
Owner Status row/file
Layer Status row/file
```

Minimum route pattern:

```text
Aurora Core/<SERVER>/<ACCOUNT_NUMBER>/
```

Potential compact folder model:

```text
Aurora Core/<SERVER>/<ACCOUNT_NUMBER>/Account Status.txt
Aurora Core/<SERVER>/<ACCOUNT_NUMBER>/Workbench/Manifest.txt
Aurora Core/<SERVER>/<ACCOUNT_NUMBER>/Workbench/Status.txt
Aurora Core/<SERVER>/<ACCOUNT_NUMBER>/Workbench/Diagnostics.txt
```

This is a proposed Layer 1 route shape, not a full output architecture.

---

## 8. Audit Blockers Before Coding

Resolved by this audit:

```text
Seed folder/FileIO inheritance inspected.
Sentinel runtime laws inspected.
Layer 1 source must not start from blank design.
```

Still required when coding starts:

```text
inspect current AURORA CORE mt5/ source folder before writing
create only Layer 1 — Account / Portfolio / Prop Rule Truth source
compile in MetaEditor after source is created
runtime smoke in MT5 Common Files before claiming runtime proof
```

---

## 9. Final Inheritance Law

```text
Seed gives Core the small truthful printer shape.
Sentinel gives Core the runtime-law scars.
Core must inherit both without copying their bloat.
```
