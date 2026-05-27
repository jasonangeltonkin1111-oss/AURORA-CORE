# 26 L10 TAXONOMY CLASSIFICATION CONTROL

## Purpose

Define Layer 10 as the active taxonomy and `ranking_group` map for AURORA CORE.

Layer 10 answers:

```text
What is this broker symbol?
Which active taxonomy path does it belong to?
Which stable ranking_group can later layers use for intra-group ranking, group heat, group selection, candidate sourcing, and Selection Desk routing?
```

Layer 10 is not a ranking engine, not a Selection Desk copier, not Global Top 10, not Top 5 per group, not a trade signal, and not trade permission.

---

## Owner Boundary

```text
Runtime owner: Runtime 5 - Taxonomy / Ranking Group Owner
Layer: 10 - Taxonomy Classification / Ranking Group Map
```

Layer 10 owns the active runtime taxonomy fields:

```text
asset_class
market_group
market_segment
ranking_group
canonical_symbol
taxonomy_match_state
taxonomy_review_state
rank_allowed_state
selection_allowed_state
ranking_group_path_slug
future_selection_desk_group_path
symbol_path_index row
unknown/review/conflict/omitted ledgers
group membership counts
group active/inactive state
```

Layer 10 must not own:

```text
broker specs
live quote truth
spread calculation
surface scores
symbol rank inside group
ranking_group heat / quality
selected ranking_group list
candidate pool construction
correlation / diversity selection
Global Top 10
Top 5 per group
Dossier rendering
Dossier copying
trade permission
entry signals
strategy validation
```

Those belong later:

```text
L3 = broker specs / broker identity evidence
Runtime 2 = generated taxonomy lookup source
L11 = symbol ranking inside ranking_group
L12 = ranking_group heat / quality
L13 = dynamic ranking_group selection
L14 = ranking_group leader candidate pool
L15 = correlation / diversity selection
L16 = Global Top 10 builder
Selection Desk copier = copied Dossier files only, not Dossier rendering
L23 = setup / strategy / permission / alert state
```

---

## Current Source-Truth Split

L3 may collect and display broker identity evidence and legacy taxonomy evidence while L10 is being introduced. L3 must not remain the final active taxonomy authority after L10 is live.

Runtime 2 generated universe rows are lookup source, not ranking runtime and not trade permission.

Layer 10 consumes Runtime 2 rows and L3 broker identity evidence, then publishes the active runtime taxonomy truth for later layers.

Preferred migration:

```text
Phase A: L3 keeps taxonomy evidence fields but labels them as evidence / pending L10 authority.
Phase B: L10 publishes active taxonomy authority.
Phase C: L1 exposure maps and later selection layers consume L10 taxonomy where available.
```

Do not rip L3 fields out before L10 runtime output is proven.

---

## Naming Law

Active EA-facing vocabulary uses:

```text
asset_class
market_group
market_segment
ranking_group
symbol
```

Do not create new active output names such as:

```text
bucket
bucket_top5
sub_bucket_top5
Top 5 Per Bucket
```

Operator-friendly folders may use words like `Top 5 Per Group`, but manifests must keep the source field name:

```text
ranking_group=<value>
```

Old bucket wording may exist only as source provenance or historical notes, never as a new runtime authority.

---

## Input Sources

Layer 10 consumes:

```text
Runtime 2 generated taxonomy lookup rows
L3 broker identity evidence
L5 gate state
L6-L9 surface result availability summaries only
Dossier source path map
```

Source priority:

```text
1. Runtime 2 exact server + broker_symbol match
2. Runtime 2 exact broker_symbol match
3. Runtime 2 exact canonical_symbol match
4. Runtime 2 normalized broker root match
5. Runtime 2 normalized canonical root match
6. curated alias table when present
7. L3 broker identity evidence
8. symbol grammar fallback
9. unknown / review_required
```

Layer 10 must never silently guess clean. Every fallback or uncertainty must be visible in output.

---

## Runtime 2 Row Contract

Expected generated row schema:

```text
server|broker_file|broker_symbol|canonical_symbol|asset_class|market_group|market_segment|ranking_group|strict_rank_allowed|public_research_rank_allowed|review_lane|classification_confidence|evidence_rank|runtime_permission|evidence_status|source_status|block_reason
```

Required row validation:

```text
field_count == 17
broker_symbol not empty
asset_class not empty
market_group not empty
market_segment not empty
ranking_group not empty
runtime_permission == LOOKUP_ONLY_NOT_TRADE_PERMISSION
no duplicate active primary key without conflict ledger entry
```

Invalid rows must be ledgered, not ignored.

---

## Symbol Taxonomy States

Every broker symbol must end in exactly one active taxonomy state:

```text
ACCEPTED_STRICT
ACCEPTED_PUBLIC_RESEARCH
REVIEW_REQUIRED
UNKNOWN
OMITTED
BLOCKED
CONFLICT
MISSING_DOSSIER_SOURCE
```

Meaning:

```text
ACCEPTED_STRICT           = strong Runtime 2 / broker-confirmed classification; rank_allowed may be true
ACCEPTED_PUBLIC_RESEARCH  = research-backed but not fully broker-confirmed; rank_allowed may be true with warning
REVIEW_REQUIRED           = classification exists but not clean enough for ranking
UNKNOWN                   = no trustworthy classification
OMITTED                   = operator omitted / excluded from ranking lookup
BLOCKED                   = explicit taxonomy block
CONFLICT                  = multiple incompatible taxonomy matches
MISSING_DOSSIER_SOURCE    = taxonomy exists but source Dossier copy path cannot be resolved later
```

Rank eligibility is not trade permission.

```text
rank_allowed=true does not mean selection_allowed=true
enabled selection does not mean enabled trade permission
trade_permission=false always in Layer 10
```

---

## L10 Output Files

Worker outbox route:

```text
Workbench/Gateway/Outbox/Layers/Layer_10_Taxonomy_Classification/
    taxonomy_symbols.csv
    taxonomy_symbols.manifest
    ranking_groups.csv
    ranking_groups.manifest
    symbol_path_index.csv
    symbol_path_index.txt
    unknown_symbols.csv
    review_required_symbols.csv
    conflict_symbols.csv
    omitted_symbols.csv
    missing_dossier_source.csv
    taxonomy_summary.txt
    Groups/
        <ranking_group_slug>.summary.txt
```

No Top 10 files are produced by L10.
No Top 5 files are produced by L10.
No Dossier copies are produced by L10.

---

## `taxonomy_symbols.csv` Contract

Required columns:

```text
symbol
canonical_symbol
asset_class
market_group
market_segment
ranking_group
taxonomy_state
review_state
match_type
match_confidence
classification_source
classification_confidence
evidence_rank
source_status
block_reason
rank_allowed
selection_allowed
l5_gate_state
l5_eligible_flag
l6_available
l7_available
l8_available
l9_available
dossier_source_path
future_group_folder
future_top5_copy_path
future_top10_copy_path
reason
trade_permission
```

Rules:

```text
One row per broker symbol.
No silent omission.
No symbol may have two active ranking_groups.
Unknown values must be literal `Unknown` or `not_available`, not blank.
trade_permission=false for every row.
```

---

## `ranking_groups.csv` Contract

Required columns:

```text
ranking_group
ranking_group_slug
asset_class
market_group
market_segment
symbol_count
open_count
l5_pass_count
l5_degraded_count
l5_blocked_count
strict_rank_allowed_count
public_research_allowed_count
review_required_count
unknown_count
conflict_count
missing_dossier_count
group_state
future_selection_desk_group_path
trade_permission
```

Group states:

```text
ACTIVE
ACTIVE_WITH_REVIEW
REVIEW_ONLY
EMPTY
BLOCKED
```

Layer 10 group state is taxonomy/group readiness only, not group heat and not selected group state.

---

## Symbol Path Index Contract

Layer 10 must publish a symbol roadmap so an operator or later chat can ask where any symbol belongs.

CSV required columns:

```text
symbol
canonical_symbol
asset_class
market_group
market_segment
ranking_group
taxonomy_state
rank_allowed
selection_allowed
dossier_source_path
future_group_folder
future_top5_copy_path
future_top10_copy_path
reason
```

Readable TXT example:

```text
SYMBOL PATH INDEX
----------------------------------------
EURZAR
Taxonomy:          FX > Forex > Exotic Pair > Currency / Forex Exotic Pairs
State:             ACCEPTED_STRICT
Rank Allowed:      TRUE
Selection Allowed: TRUE
Dossier Source:    Dossiers/Open/EURZAR.txt
Future Group Path: Selection Desk/Top 5 Per Group/Currency - Forex Exotic Pairs/
Top 5 Copy:        pending Layer 11 rank
Top 10 Copy:       pending Layer 16 rank
Trade Permission:  FALSE
```

L10 may publish future Selection Desk paths, but must not create ranked/copied Dossier outputs.

---

## Selection Desk Relationship

Layer 10 is a path planner only.

It may publish:

```text
future_group_folder
safe ranking_group slug
symbol path index
ranking_group membership map
```

It must not publish:

```text
Top 10 dossier copies
Top 5 per group dossier copies
ranked copied dossiers
selection desk final basket
```

Later Selection Desk copier law:

```text
Dossier folder is the source Dossier owner.
Selection Desk Top 10 / Top 5 files must be byte-identical copies of source Dossier files.
Selection Desk copier must not render or modify Dossier content.
Rank explanations belong in Market Board, Selection Index, summaries, and manifests, not inside copied Dossier files.
```

---

## Market Board Contract

Board section must be compact:

```text
LAYER 10 - TAXONOMY / RANKING GROUP MAP
----------------------------------------
Status:                     Accepted With Review Items / Partial / Pending / Degraded
Owner:                      Runtime 5 - Taxonomy / Ranking Group Owner
Input Source:               Runtime 2 lookup + L3 broker identity + L5 gate state
Broker Symbols:             <n>
Classified Symbols:         <n> / <n>
Unknown Symbols:            <n>
Review Required:            <n>
Conflicts:                  <n>
Omitted:                    <n>
Blocked:                    <n>
Ranking Groups Active:      <n>
Groups With L5 Pass:        <n>
L5 Pass Symbols Mapped:     <n> / <n>
Symbol Path Index:          available / partial / pending
Selection Desk Copy Runtime:FALSE
Selection Runtime:          FALSE
Trade Permission:           FALSE
Main Blocker:               <reason>
```

Optional compact active group preview:

```text
LAYER 10 - ACTIVE RANKING GROUPS
----------------------------------------
Group                              Symbols   L5 Pass   Review   Unknown
Currency / Forex Major Pairs       12        3         0        0
Currency / Forex Cross Pairs       31        5         0        0
Crypto Currency / Large Cap Crypto 6         4         0        0
```

Board must not print full taxonomy ledgers.

---

## Dossier Contract

Per-symbol Dossier section:

```text
LAYER 10 - TAXONOMY / RANKING GROUP MAP
----------------------------------------
Status:                <taxonomy_state>
Asset Class:           <asset_class>
Market Group:          <market_group>
Market Segment:        <market_segment>
Ranking Group:         <ranking_group>
Canonical Symbol:      <canonical_symbol>
Match Source:          <classification_source>
Match Type:            <match_type>
Classification Confidence: <classification_confidence>
Review State:          <review_state>
Rank Allowed:          TRUE/FALSE
Selection Allowed:     TRUE/FALSE
Future Group Folder:   <future_group_folder>
Future Copy State:     pending_l11_rank
Selection Runtime:     FALSE
Trade Permission:      FALSE
Meaning:               taxonomy_only_no_rank_no_selection_no_trade
```

Unknown example:

```text
Status:                UNKNOWN
Ranking Group:         Unknown
Review State:          manual_review_required
Rank Allowed:          FALSE
Selection Allowed:     FALSE
Reason:                no Runtime 2 match and grammar fallback failed
Trade Permission:      FALSE
```

---

## Worker Module Build Order

Create child modules before the master:

```text
external_worker/aurora_worker_l10_schema.py
external_worker/aurora_worker_l10_normalize.py
external_worker/aurora_worker_l10_universe_parser.py
external_worker/aurora_worker_l10_matcher.py
external_worker/aurora_worker_l10_quality.py
external_worker/aurora_worker_l10_group_builder.py
external_worker/aurora_worker_l10_path_planner.py
external_worker/aurora_worker_l10_publisher.py
external_worker/aurora_worker_l10.py
```

Responsibilities:

```text
schema.py          = constants and column contracts only
normalize.py       = display-preserving symbol normalization and safe slugs
universe_parser.py = Runtime 2 row parsing and row validation
matcher.py         = broker symbol to universe row matching and conflict detection
quality.py         = taxonomy state / rank_allowed / selection_allowed resolution
group_builder.py   = ranking_group aggregate counts
path_planner.py    = future Selection Desk and symbol path index path planning
publisher.py       = atomic text/csv/manifest output through existing worker IO helper
l10.py             = orchestration only, no giant logic
```

---

## Acceptance Tests

L10 is acceptable only when:

```text
Every broker symbol has exactly one taxonomy row or one explicit review/unknown row.
No symbol silently disappears.
No symbol has more than one active ranking_group.
Runtime 2 rows are parsed with expected schema.
L3 evidence is used only as evidence, not final authority.
All fallback classifications are visibly labeled.
All unknown symbols are listed.
All review-required symbols are listed.
All conflict symbols are listed.
All omitted symbols are listed.
All invalid universe rows are listed.
L5 pass symbols are all mapped or visibly blocked.
Symbol Path Index exists.
Market Board shows L10 summary.
Dossier shows L10 taxonomy section.
selection_runtime=false.
trade_permission=false.
No Top 10 files are produced by L10.
No Top 5 files are produced by L10.
No Dossier copies are produced by L10.
```

---

## Proof Levels

Keep proof classes separate:

```text
source contract created
worker child modules syntax pass
worker master wired
worker output files written
MT5 renders board section
MT5 renders Dossier section
runtime readback observed
symbol counts reconcile
L5 pass symbols mapped
Selection Desk future paths visible
```

Do not claim runtime complete from source alone.
Do not claim selection ready from L10.
Do not claim trade permission from taxonomy.

---

## Decision

PROCEED with L10 only after this contract is accepted.

First implementation patch should create schema and normalization child modules only.
Runtime wiring must wait until parser/matcher/quality/group/path/publisher modules exist and pass syntax/static review.
