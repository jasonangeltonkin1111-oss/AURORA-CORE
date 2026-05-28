# VERITAS ATLAS Overview Index

This is the master surface-view index for the VERITAS ATLAS controlled rebuild blueprint.

It is intentionally short enough to stay readable and must remain current whenever the layer blueprint, folder structure, or surface contract changes.

---

## Purpose

This file owns high-level navigation for:

```text
system identity
layer map
folder/index law
surface map
Gateway map
permission split
build sequence
```

This file does not own implementation truth, compile proof, runtime proof, trading edge proof, or prop-firm permission.

---

## Required startup path

```text
README.md
AGENTS.md
OVERVIEW_INDEX.md
Relevant folder INDEX.md
Relevant folder GUIDELINES.md
Relevant source/content file
```

---

## Active system names

| Name | Meaning |
|---|---|
| VERITAS ATLAS | Full system name |
| VA | Short system name |
| Atlas Terminal | MT5 side |
| Veritas Atlas Gateway | EXE worker side |
| Gateway | Locked worker name |
| Atlas Bench | Runtime/foundation proof surface |
| Atlas Board | Main cockpit surface |
| Atlas Dossier | Per-symbol truth surface |
| Atlas Slate | Selected inspection surface |
| Atlas Ledger | Audit/proof surface |
| Atlas Vault | Risk/permission surface |

---

## Top-level repo map

| Path | Role | Required docs |
|---|---|---|
| `README.md` | Repo front door | root file |
| `AGENTS.md` | Canonical agent law | root file |
| `OVERVIEW_INDEX.md` | Master surface-view index | root file |
| `mt5/` | Atlas Terminal source | one `INDEX.md`, one `GUIDELINES.md`, then code/source only |
| `gateway/` | Veritas Atlas Gateway source | `INDEX.md`, `GUIDELINES.md` |
| `docs/` | Blueprint/guidance docs | `INDEX.md`, `GUIDELINES.md` |
| `control/` | Control/governance compatibility area | existing index/guidance or migration needed |
| `research/` | Research references only | `INDEX.md`, `GUIDELINES.md` |
| `prompts/` | Prompt templates only | `INDEX.md`, `GUIDELINES.md` |
| `reports/` | Historical reports only | `INDEX.md`, `GUIDELINES.md` if used |

Existing Aurora/Core folders may remain during transition, but new VA work must follow the index/guideline law.

---

## Folder law

Every active project folder must contain exactly:

```text
INDEX.md
GUIDELINES.md
```

for folder documentation.

The MT5 source folder and each MT5 source subfolder may contain only:

```text
INDEX.md
GUIDELINES.md
code/source files
```

No extra markdown inside MT5 source folders unless explicitly approved as a migration.

Every layer folder index must be updated whenever a file is added, removed, renamed, or changes ownership.

---

## Layer map

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

---

## Runtime owner grouping

### MT5 / Atlas Terminal

```text
L0 Atlas Bench
L1 Atlas Surfaces
L2 Broker Account
L3 Symbol Universe
L4 Symbol Specs
L5 Market Watch
L6 OHLC Tick Feed
L7 Gateway Link
Atlas Vault final fail-closed state
```

### Gateway

```text
L8 Gateway Intake
L9 Cost Friction
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

---

## Foundation build order

```text
1. L0 Atlas Bench
2. L1 Atlas Surfaces
3. L2-L6 MT5 raw truth chain
4. L7 Gateway Link
5. L8-L30 Gateway trading-analysis chain
```

L0/L1 must exist before deeper layers. The system must be visible while being built.

---

## Surface ownership

| Surface | Built by | Purpose | Must not do |
|---|---|---|---|
| Atlas Bench | L0 | runtime proof, timer, FileIO/path/packet status | trading logic |
| Atlas Board | L1 | compact cockpit | recalculate layer truth |
| Atlas Dossier | L1 | per-symbol packet truth | own broker data or setup logic |
| Atlas Slate | L1 | selected inspection set | imply trade permission |
| Atlas Ledger | L1/L0 proof feed | hashes, manifests, sequence proof | silently repair truth |
| Atlas Vault | L1 shell, later Vault logic | fail-closed permission state | grant auto execution without proof |

---

## Packet law

Each layer should normally produce:

```text
1 packet
1 status row
optional bounded diagnostics when justified
```

Layers consume declared upstream packets and write their own downstream packet. Layers do not read the entire system unless explicitly declared as a join layer.

---

## Permission split

| Stage | Trader chat | Manual decision | Auto trading |
|---|---|---|---|
| Before L19 | locked | locked | locked |
| After L19 | allowed with caution | human responsibility | locked |
| After L20-L29 | richer evidence allowed | human responsibility | locked |
| After L30 someday | still evidence-dependent | human responsibility | locked unless Vault/execution proof allows |

No layer output is auto-trading permission by itself.

---

## Build gate

The default gate for VA implementation is:

```text
TEST FIRST
```

Source presence proves source presence only. Compile proof, runtime proof, Gateway proof, and trading proof are separate evidence classes.
