# VERITAS ATLAS

**Truth-first MT5 market intelligence, Gateway-driven analysis, and prop-firm risk protection.**

VERITAS ATLAS is the clean rebuild direction for the old Aurora/Core work. It is designed to keep MT5 lightweight, keep every source owner single, keep every folder indexed, and prevent hidden drift, shadow systems, fake proof, and premature auto-trading authority.

VA exists to answer:

```text
What does the broker/account/market actually say right now?
Which symbols deserve inspection?
Which evidence exists?
Which evidence is missing?
What is stale, degraded, blocked, or unsafe?
What may be discussed manually with trader chat?
What remains locked from auto execution?
```

---

## Current status

This repository is in **blueprint / controlled rebuild planning** mode unless current source, compile evidence, and runtime outputs prove otherwise.

The old Aurora/Core architecture is treated as historical evidence and lessons learned. It does not automatically prove that VERITAS ATLAS is implemented, compiled, live-ready, prop-firm-safe, or edge-proven.

Truth order:

```text
repo/source/config
compile/test/runtime/logs
official docs and primary sources
broker/prop-firm rules
reports and generated outputs
memory / old prompts / blueprints
AI reasoning
```

---

## Mandatory reading order

Before touching architecture, files, source, or docs:

```text
README.md
AGENTS.md
OVERVIEW_INDEX.md
Relevant folder INDEX.md
Relevant folder GUIDELINES.md
Relevant source/content file
```

If a folder does not have its required index/guideline pair, do not add serious content to that folder until the index/guideline gap is fixed.

---

## System identity

```text
System: VERITAS ATLAS
Short name: VA
MT5 terminal side: Atlas Terminal
EXE worker side: Veritas Atlas Gateway
Worker name: Gateway
Foundation/runtime proof surface: Atlas Bench
Cockpit surface: Atlas Board
Per-symbol truth surface: Atlas Dossier
Selected inspection surface: Atlas Slate
Audit/proof surface: Atlas Ledger
Risk/permission surface: Atlas Vault
```

**Gateway is locked terminology.** Do not rename it to worker, daemon, helper, bot, engine, or assistant in active docs/source. It may be described as the EXE worker only for explanation, but the official name is Gateway.

---

## Core doctrine

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

## Foundation law

Layer 0 is the foundation. Foundation is built first.

Layer 0 owns:

```text
Atlas Bench
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

Layer 1 owns the initial visible surfaces:

```text
Atlas Board
Atlas Dossier shell/index
Atlas Slate
Atlas Ledger shell
Atlas Vault default blocked state
```

Later layers feed those surfaces through packets. Later layers do not create, rename, or own the foundation.

A later change to foundation requires a formal **Foundation Migration** with reason, rollback path, updated indexes, and runtime proof.

---

## Lightweight MT5 law

MT5 must stay the live broker-truth conveyor, not the heavy brain.

MT5 owns:

```text
broker/account truth
symbol universe truth
symbol specs/session/margin truth
Market Watch quote/spread/freshness truth
raw OHLC/tick packet extraction
Gateway packet handoff and acceptance
foundation surfaces
Vault fail-closed state
```

MT5 must not become the heavy analysis graph. It must not repeatedly read back every file, rewrite every layer, scan folders on the hot path, create duplicate owners, or recalculate Gateway intelligence.

Gateway owns heavy analysis:

```text
friction/session/movement/structure/taxonomy/group/ranking/selection/deep-evidence calculations
```

Gateway may calculate heavily, cache, and read declared upstream packets. Gateway may not own broker truth, FileIO routes, MT5 publication authority, final account safety, or auto execution authority.

---

## Layer blueprint draft

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

The layer map is a blueprint until source/runtime evidence proves implementation.

---

## Trading permission split

Manual / trader-chat trading and auto trading are different permissions.

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

No ranking, setup candidate, or trader-chat pack is auto-trading permission.

---

## Index law

Every folder that contains active project material must have exactly one folder index and exactly one folder guideline file.

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

No extra markdown files are allowed inside MT5 source folders unless explicitly approved as a migration. Planning, doctrine, and reports belong outside MT5 source folders.

Every layer folder must keep its index unlocked and current. When a layer file is added, removed, renamed, or gains/changing ownership, the layer index must be updated in the same patch.

---

## File-size and inspectability law

VA prefers many small, indexed, single-owner files over large monoliths.

A source file that cannot be fully read, audited, and patched without truncation is an operational risk.

Guideline limits:

```text
source file target: 150-350 lines
source file hard review point: 500 lines
function target: 10-40 lines
function hard review point: 80 lines
```

Large files must be split by owner/responsibility before feature growth continues.

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

## Agent / Codex discipline

ChatGPT should do connected repo/audit/patch work when possible. Codex is allowed only when necessary, but Codex must obey `AGENTS.md`, the overview index, folder indexes, folder guidelines, and owner boundaries.

No agent may add:

```text
V2 files
backup owners
shadow FileIO
shadow path builders
hidden fallback writers
duplicate Gateway owners
large shared helper dumping grounds
unindexed source files
unindexed layer files
```

---

## Decision gate

Serious audits and implementation reports must end with exactly one:

```text
PROCEED
HOLD
KILL
TEST FIRST
```

Default for blueprint-to-code work: **TEST FIRST** until source, compile, and runtime proof exist.
