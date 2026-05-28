# VERITAS ATLAS Agent Law

This repository is transitioning from Aurora/Core history into the **VERITAS ATLAS** controlled rebuild blueprint.

Current repo/source/config outranks memory, screenshots, reports, prompts, blueprints, and AI reasoning. This file is the canonical agent instruction file. Do not create duplicate AGENTS files, duplicate repo-law files, or competing instruction systems unless the user explicitly asks.

---

## Required startup flow

Before editing architecture, source, docs, prompts, or indexes, read:

```text
README.md
AGENTS.md
OVERVIEW_INDEX.md
Relevant folder INDEX.md
Relevant folder GUIDELINES.md
Relevant source/content file
```

If a folder has no `INDEX.md` or no `GUIDELINES.md`, do not add serious new content there until the folder-index/guideline gap is fixed or the user explicitly scopes a migration.

---

## Truth order

```text
repo/source/config
compile/test/runtime/logs
official docs and primary sources
broker/prop-firm rules
reports and generated outputs
memory / old prompts / blueprints
AI reasoning
```

Never claim compile success, runtime success, live readiness, prop-firm safety, edge proof, auto-trading readiness, or execution permission without direct evidence.

---

## Agent use policy

ChatGPT should attempt connected repo/audit/patch work first when the tools allow it.

Use Codex only when ChatGPT is blocked, lacks the required execution environment, struggles with the task, or the user explicitly asks for Codex. Codex must still obey this file, the README, the overview index, folder indexes, folder guidelines, and owner boundaries.

If a connector blocks writes or cannot safely patch a file, report `BLOCKED` or `HOLD` honestly. Do not pretend files were updated.

---

## Core VA laws

```text
Print truth first.
Keep MT5 lightweight.
Use Gateway for heavy analysis.
One source owner only.
One read, one write, one packet per layer where possible.
No shadow owners.
No shared business logic dumping grounds.
No fake proof.
No auto trading without validation.
```

---

## Locked terminology

```text
System: VERITAS ATLAS
Short name: VA
MT5 terminal side: Atlas Terminal
EXE worker side: Veritas Atlas Gateway
Official worker name: Gateway
Runtime proof surface: Atlas Bench
Cockpit surface: Atlas Board
Per-symbol truth surface: Atlas Dossier
Selected inspection surface: Atlas Slate
Audit/proof surface: Atlas Ledger
Risk/permission surface: Atlas Vault
```

Do not rename Gateway to worker/daemon/helper/bot/engine in active source or docs. It may be described as an EXE worker only for explanation.

---

## Layer blueprint discipline

The current draft layer map is:

```text
L0  Atlas Bench
L1  Atlas Surfaces
L2  Broker Account
L3  Symbol Universe
L4  Symbol Specs
L5  Market Watch
L6  OHLC Tick Feed
L7  Gateway Link
L8  Gateway Intake
L9  Cost Friction
L10 Session Context
L11 Movement Range
L12 Structure Location
L13 Taxonomy Groups
L14 Group Heat
L15 In-Group Ranking
L16 Correlation Diversity
L17 Global Selection
L18 Deep Routing
L19 Raw Evidence Pack
L20 Candle Wick Geometry
L21 Indicator Reference
L22 Liquidity Map
L23 Structure Reaction Evidence
L24 FVG Imbalance Evidence
L25 ORB Evidence
L26 POI Zone Evidence
L27 Risk Geometry
L28 Setup Candidate Builder
L29 Trader Chat Pack
L30 Validation Ledger
```

This layer map is blueprint truth only until source/runtime proves implementation.

---

## Foundation law

L0 and L1 are foundation layers.

L0 Atlas Bench owns:

```text
runtime identity
folder contract
path contract
FileIO contract
atomic write contract
timer/scheduler/dirty queue
packet registry
layer status registry
Gateway input/output folders
startup proof
performance proof
```

L1 Atlas Surfaces owns initial shells for:

```text
Atlas Board
Atlas Dossier
Atlas Slate
Atlas Ledger
Atlas Vault default blocked state
```

Later layers may feed these surfaces through declared packets. Later layers must not create, rename, or own the foundation.

A foundation change after L0/L1 acceptance requires a formal **Foundation Migration** with reason, rollback path, updated indexes, and runtime proof.

---

## Folder index and guideline law

Every active project folder must have exactly one folder index and exactly one folder guideline file.

Preferred names:

```text
INDEX.md
GUIDELINES.md
```

The MT5 source folder and each MT5 source subfolder may contain only:

```text
INDEX.md
GUIDELINES.md
code/source files
```

No extra markdown files are allowed inside MT5 source folders unless explicitly approved as a migration. Planning, doctrine, reports, and handoffs belong outside MT5 source folders.

Every layer folder must keep its index unlocked and current. If a layer file is added, removed, renamed, or changes ownership, the layer index must be updated in the same patch.

No index update = patch rejected.

---

## Runtime owner boundaries

Patch the existing owner only. No duplicate owners, no V2 helpers, no shadow systems, no broad rewrites.

Forbidden unless explicitly scoped as a migration:

```text
FileOpen/FileWrite/FileFlush/FileMove outside the FileIO owner
path string construction outside the path owner
EventSetTimer or OnTimer ownership outside the timer owner
Board/Dossier/Slate rendering outside the surface owner
Gateway packet ownership outside the Gateway Link / Gateway source owner
Vault permission ownership outside Vault
execution logic outside a future explicit Execution Controller
```

Dossiers display upstream truth; they must not become hidden truth owners.

Board and Slate display accepted packet summaries; they must not recalculate layer truth.

Gateway owns heavy analysis support only. Gateway must not own broker truth, FileIO routes, MT5 publication authority, final account safety, or auto execution authority.

---

## File-size and inspectability law

VA prefers many small, indexed, single-owner files over large monoliths.

Guideline limits:

```text
source file target: 150-350 lines
source file hard review point: 500 lines
function target: 10-40 lines
function hard review point: 80 lines
```

A source file that cannot be fully read, audited, and patched without truncation is an operational risk. Split large files by owner/responsibility before adding more behavior.

---

## Shared module law

Shared files may define language, types, constants, tiny formatting helpers, and result wrappers.

Shared files may not define authority, market logic, permission logic, routing, FileIO, Gateway decisions, ranking, selection, strategy, or execution.

Do not create generic dumping grounds named like:

```text
Utils
Helpers
CommonLogic
SharedEngine
Fixes
V2
Final
Backup
```

If a new feature does not fit an existing owner, create a new indexed module/layer folder.

---

## Runtime output law

Do not recreate the old dozens-of-files-per-layer problem.

Each layer should normally produce:

```text
1 packet
1 status row
optional bounded diagnostics only when justified
```

Board, Dossier, Bench, Slate, Ledger, and Vault render from accepted packet summaries and registries. They must not recalculate layer truth or become hidden source owners.

---

## Trading permission law

Manual/trader-chat trading and auto trading are different permissions.

```text
Before L19 Raw Evidence Pack:
  Trader Chat = locked
  Manual trade discussion = locked
  Auto trading = locked

After L19 Raw Evidence Pack:
  Trader Chat = allowed with caution
  Manual decision = human responsibility
  Auto trading = locked

After L20-L29 evidence layers:
  Trader Chat = richer evidence allowed
  Manual decision = human responsibility
  Auto trading = locked

After L30 Validation Ledger someday:
  Auto trading remains locked unless validation, broker rules, prop-firm rules, forward proof, execution proof, and Vault authority explicitly allow it.
```

No ranking, setup candidate, or Trader Chat Pack is auto-trading permission.

---

## File removal law

Do not remove files casually. Before removing any file, prove from source inspection that it is obsolete, duplicate, generated, harmful, or replaced by a verified path.

Before removal, report:

```text
file path
references/imports/includes/tasks/scripts using it
whether it is active, compatibility wrapper, stale, duplicate, generated artifact, or archive
why removal is safer than keeping or demoting
regression risk
rollback path
```

Preserve compatibility wrappers unless replacement paths are proven and documented. If evidence is incomplete, keep the file and mark it for later cleanup.

---

## Required serious-run report

Serious repo/audit/patch reports must include:

```text
repo/branch
files inspected
files changed
why each changed
owner affected
index/guideline updates done or missing
verification done
verification missing
risk
rollback path
proof level
decision gate
```

End with exactly one:

```text
PROCEED
HOLD
KILL
TEST FIRST
```
