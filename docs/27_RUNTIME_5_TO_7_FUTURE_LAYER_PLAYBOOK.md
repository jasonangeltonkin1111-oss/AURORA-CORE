# 27 RUNTIME 5 TO 7 FUTURE LAYER PLAYBOOK

## Purpose

This guide explains how the future layers work together from Layer 10 through Layer 22, and how those outputs should appear on the Board, Dossiers, Selection Desk, Workbench, and manifests.

It exists so future chats/agents do not drift into duplicate owners, shadow renderers, fake Top 10 authority, or trade-permission language.

This guide is a planning/control document. It is not runtime proof.

---

## Absolute Laws

1. **Layer 5 remains the only broad all-symbol hard gate.** Later layers may classify, rank, select, label, degrade, inspect, or reject, but must not reopen L5-blocked symbols.
2. **Ranking is inspection priority only.** High rank does not mean buy/sell, edge, expectancy, or trade permission.
3. **Selection Desk does not render Dossier content.** If Dossier files appear in Selection Desk, they must be copied from the Dossier owner without modification.
4. **Market Board is the cockpit.** It shows compact reasons, rank rows, status, warnings, and copy integrity. It does not print full raw evidence.
5. **Dossier is the full per-symbol truth file.** It is rendered by the Dossier renderer from owner truth sections, not by Selection Desk.
6. **Workbench is proof detail.** Full ledgers, row mismatches, conflicts, invalid rows, copy failures, checksums, and diagnostics live there.
7. **Stable routes only.** Stable truths may become folders. Changing ranks, Top-N order, scores, cycle IDs, and timestamps belong inside files/manifests, not parent route names.
8. **Trade permission stays false until Layer 23 and validation evidence explicitly support otherwise.**

---

## Route Contradiction Resolution

Earlier operator wording may say `Top 10` or `Top 5 per bucket`. The active architecture should express that as stable Selection Desk surfaces:

```text
Selection Desk/Groups/
Selection Desk/Global/
Selection Desk/Selection Index.txt
```

Inside those stable routes, files may display the current Top-N view:

```text
Selection Desk/Groups/<ranking_group_slug>/current_top5_manifest.txt
Selection Desk/Groups/<ranking_group_slug>/01_<symbol>.txt
Selection Desk/Global/current_top10_manifest.txt
Selection Desk/Global/01_<symbol>.txt
```

The folder is stable (`Groups`, `Global`, ranking_group slug). The rank is inside filenames/manifests for operator convenience. If future implementation chooses to avoid rank prefixes in filenames too, use `current_members.csv` and copied symbol files by symbol name, but do not create changing parent folders.

EA-facing vocabulary remains:

```text
ranking_group
```

Operator-facing language may say:

```text
Top 5 per group
Global Top 10 inspection basket
```

Do not use active source names such as `bucket_top5`, `sub_bucket_top5`, or `Top 5 Per Bucket`.

---

## Big Picture Flow

```text
Runtime 5 - Taxonomy / Ranking Group Owner
  L10 classify symbols into ranking_groups
  L11 rank symbols inside each ranking_group
  L12 score ranking_group heat / quality
  L13 choose active ranking_groups
  L14 pull group leaders and backups

Runtime 6 - Basket Selection Owner
  L15 apply correlation / diversity selection
  L16 build Global Top 10 inspection basket

Runtime 7 - Selected Evidence Owner
  L17 split visible selection vs deep evidence selection
  L18 selected raw OHLC bar pack
  L19 selected wick/candle geometry pack
  L20 selected rolling tick pack
  L21 selected indicator/reference pack
  L22 selected deep market evidence / liquidity / MT5 order-flow proxy pack

Runtime 8 / Layer 23 later
  setup / strategy / permission / alert state
```

Runtime numbering note: source may still contain inherited `runtime_7_publication_owner` service naming. That folder naming is publication support inheritance, not selected-evidence trading truth authority.

---

## Layer 10 — Taxonomy Classification / Ranking Group Map

### Question answered

```text
What is this symbol, and which stable ranking_group does it belong to?
```

### Inputs

```text
Runtime 2 generated taxonomy lookup rows
L3 broker identity evidence
L5 gate state
L6-L9 availability summaries only
Dossier source path map
```

### Outputs

```text
taxonomy_symbols.csv
ranking_groups.csv
symbol_path_index.csv
unknown_symbols.csv
review_required_symbols.csv
conflict_symbols.csv
omitted_symbols.csv
missing_dossier_source.csv
```

### Board surface

Compact taxonomy/ranking_group summary:

```text
classified symbols
unknown symbols
review required
conflicts
omitted
ranking groups active
groups with L5 pass
L5 pass symbols mapped
symbol path index state
selection_runtime=false
trade_permission=false
```

### Dossier surface

Per-symbol taxonomy section:

```text
asset_class
market_group
market_segment
ranking_group
match source
match confidence
rank_allowed
selection_allowed
future group path
trade_permission=false
```

### Must not do

```text
No symbol ranking.
No Top 5.
No Global Top 10.
No Dossier copy.
No trade permission.
```

---

## Layer 11 — Symbol Ranking Inside Ranking Group

### Question answered

```text
Inside this symbol's own ranking_group, which symbols deserve inspection first?
```

### Inputs

```text
L10 taxonomy symbols and ranking_groups
L5 pass/degraded state
L6 cost/friction score
L7 session relevance score
L8 movement/range score
L9 structure/location score
```

### Output meaning

L11 produces intra-group inspection rank only.

```text
ranking_group_rank
ranking_group_rank_percentile
l11_group_score
leader_flag
backup_flag
risk_review flag
not_rankable reason
```

### Top 5 per group meaning

Top 5 per group is a **view** of L11 ranked symbols inside each ranking_group. It is not a separate owner.

### Selection Desk relation

L11 may create/update stable group files under:

```text
Selection Desk/Groups/<ranking_group_slug>/
```

If copied Dossiers are created here, they must be copied from the Dossier owner, not rendered by L11.

### Board surface

Show compact Top 5 per group rows:

```text
Group: Currency / Forex Major Pairs
1 EURUSD | L6 cost | L7 session | L8 movement | L9 structure | reason | copy_state
2 GBPUSD | ...
```

### Must not do

```text
No group heat.
No group selection.
No correlation/diversity.
No Global Top 10.
No trade permission.
```

---

## Layer 12 — Ranking Group Heat / Quality Ranking

### Question answered

```text
Which ranking_groups are currently strongest, healthiest, or most worth attention?
```

### Inputs

```text
L10 group membership
L11 intra-group ranks
L6-L9 component distributions by group
L5 pass/degraded counts
```

### Outputs

```text
ranking_group_strength
ranking_group_heat
ranking_group_quality_score
group clean/degraded/review counts
top symbol score
top N average score
backup depth
rank stability
thin group warnings
```

### Board surface

Compact group heat table:

```text
Group | Heat | Quality | L5 Pass | Leaders | Warnings
```

### Must not do

```text
No direct Global Top 10.
No correlation/diversity.
No trade permission.
```

---

## Layer 13 — Dynamic Ranking Group Selection

### Question answered

```text
Which ranking_groups deserve attention this cycle?
```

### Inputs

```text
L12 group heat / quality
L10 taxonomy state
L5 pass count per group
review/unknown/conflict state
```

### Logic frame

```text
If enough valid groups exist, select strongest groups.
If too few valid groups exist, fallback to broader market_segment only when explicitly allowed.
If taxonomy is unknown/review/conflict, group cannot silently become selected.
```

### Outputs

```text
selected_ranking_groups
fallback_reason
selected_group_count
rejected_group_count
group_selection_reason
```

### Board surface

```text
Selected Groups: <n>
Fallback Used: true/false
Rejected Groups: <n>
Main Blocker: <reason>
```

### Must not do

```text
No symbol-level final basket.
No correlation/diversity.
No trade permission.
```

---

## Layer 14 — Ranking Group Leader Candidate Pool

### Question answered

```text
From selected ranking_groups, which leaders/backups should enter the candidate pool?
```

### Inputs

```text
L13 selected groups
L11 top ranked symbols inside groups
L12 group heat / quality
L10 taxonomy state
L5 gate state
```

### Outputs

```text
candidate_pool_members
candidate_source
leader_or_backup
candidate_reason
backup_included_flag
candidate_pool_size
```

### Board surface

```text
Candidate Pool: <n>
Leaders: <n>
Backups: <n>
Review Excluded: <n>
```

### Selection Desk relation

L14 may update group leader views under stable group folders. If it copies Dossiers, copies must be byte-identical from Dossier source.

### Must not do

```text
No correlation/diversity final filter.
No Global Top 10 final basket.
No trade permission.
```

---

## Layer 15 — Correlation / Diversity Selection

### Question answered

```text
Which candidate symbols should be rejected or replaced because they are too correlated, overlapping, or exposure-clustered?
```

### Inputs

```text
L14 candidate pool only
L10 ranking_group taxonomy
L1 exposure/currency/ranking_group portfolio context where available
selected OHLC proxy only if available and scoped
```

### Scope law

No all-symbol 1200x1200 correlation matrix.

### Outputs

```text
candidate_accept/reject
correlation/diversity reason
replacement candidate
ranking_group overlap warning
currency overlap warning
```

### Board surface

```text
Correlation Rejects: <n>
Backup Fill Used: <n>
Diversity State: accepted/partial/degraded
```

### Must not do

```text
No trade permission.
No strategy edge claim.
```

---

## Layer 16 — Global Top 10 Builder

### Question answered

```text
What is the diversified Global Top 10 inspection basket for this cycle?
```

### Inputs

```text
L15 accepted/replaced candidates
L14 candidate pool
L11 ranks
L12 group quality
L10 taxonomy
```

### Outputs

```text
global_top10
global_rank
global_reason
backup_fill_reason
correlation_rejects
copy plan for Selection Desk/Global
```

### Meaning law

Global Top 10 means:

```text
Inspect these first.
```

It does not mean:

```text
Best trades.
Buy/sell.
High probability.
Permission.
```

### Selection Desk relation

Global view lives under stable route:

```text
Selection Desk/Global/
```

Copied Dossiers in the Global view must be copied from Dossier source unchanged.

### Board surface

Board must show Global Top 10 rows with compact reasons:

```text
Rank | Symbol | ranking_group | L6 | L7 | L8 | L9 | diversity note | copy state | reason
```

### Must not do

```text
No deep OHLC/tick collection for all symbols.
No trade permission.
```

---

## Layer 17 — Deep Evidence Selection Split

### Question answered

```text
Which selected symbols get deeper evidence packs, and which remain visible-only?
```

### Inputs

```text
L16 Global Top 10
L14 backup/leader pool where needed
operator pinned symbols later if allowed
resource budget
```

### Outputs

```text
visible_top_n_only
deep_evidence_selected
deep_selected_total
visible_only_total
selection_reason
depth_assignment
```

### Board surface

```text
Deep Evidence Selected: <n>
Visible Only: <n>
Evidence Budget State: ok/degraded
```

### Must not do

```text
No setup signal.
No permission.
```

---

## Layer 18 — Selected Raw OHLC Bar Pack

### Question answered

```text
For selected symbols only, what raw OHLC bars are available and complete?
```

### Inputs

```text
L17 deep selected symbols
Runtime 1 shared OHLC store / MT5 CopyRates support
```

### Outputs

```text
selected OHLC packs
bar completeness
newest bar time
stale/missing state
```

### Board surface

```text
OHLC Pack: ready/partial/stale/missing per selected symbol count
```

### Must not do

```text
No all-symbol deep OHLC.
No candle interpretation.
No trade signal.
```

---

## Layer 19 — Selected Wick / Candle Geometry Pack

### Question answered

```text
For selected symbols only, what is the candle geometry derived from L18 raw bars?
```

### Inputs

```text
L18 raw OHLC bars
```

### Outputs

```text
range
body
upper_wick
lower_wick
wick percentages
close location
zero-range flags
```

### Board surface

```text
Wick Geometry: ready/partial/missing
```

### Must not do

```text
No buy/sell from wick shape.
No fake reversal/continuation claim.
```

---

## Layer 20 — Selected Rolling Tick Pack

### Question answered

```text
For selected symbols only, what is the recent tick/spread behavior?
```

### Inputs

```text
L17 deep selected symbols
MT5 CopyTicks / CopyTicksRange support
```

### Outputs

```text
tick_count_1m/5m/10m
spread min/max/avg
spread spike count
tick gap stats
bid/ask change count
flags/state
```

### Board surface

```text
Rolling Tick Pack: ready/partial/stale/missing
```

### Must not do

```text
No HFT claim.
No institutional order-flow claim.
No trade permission.
```

---

## Layer 21 — Selected Indicator / Reference Pack

### Question answered

```text
For selected symbols only, what indicator/reference context exists?
```

### Inputs

```text
L18 OHLC bars
MT5 indicators / worker calculations where scoped
```

### Outputs

```text
ATR
range percentile
MA slope
StdDev
Bollinger Bands
VWAP with source label
spread-to-range
```

### Board surface

```text
Indicator Pack: ready/partial/missing
```

### Must not do

```text
No BB touch = buy.
No VWAP touch = entry.
No indicator-only signal.
```

---

## Layer 22 — Deep Market Evidence / Liquidity / MT5 Order-Flow Proxy Pack

### Question answered

```text
For selected symbols only, what deeper market evidence context exists?
```

### Inputs

```text
L18 OHLC
L19 candle geometry
L20 tick pack
L21 indicator/reference pack
MT5 MarketBookAdd/MarketBookGet if available
```

### Outputs

```text
risk geometry context
liquidity distance map
nearest high/low liquidity zones
VWAP context
tick-flow proxy
MT5 DOM proxy availability and imbalance if available
order_flow_source label
confidence and caveats
```

### Board surface

```text
Deep Evidence: ready/partial/degraded
DOM Proxy: available/unavailable/broker-dependent
```

### Must not do

```text
No institutional order-flow proof claim.
No setup confirmation.
No permission.
```

---

## Layer 23 Preview — Permission / Alert State

Layer 23 is not part of Runtime 5-7 completion, but every previous layer must keep its outputs permission-safe.

Layer 23 later asks:

```text
Is there an explicitly validated setup/strategy/permission state?
```

Default state until then:

```text
trade_allowed=false
auto_trade_allowed=false
directional_alert_allowed=false
class_2_setup_alert_allowed=false
```

Class 1 system/risk/integrity alerts may exist separately.

---

## Market Board Roadmap

The Board should progressively add compact sections:

### After L10

```text
Taxonomy completion
Unknown/review/conflict counts
Active ranking_groups
Symbol Path Index state
```

### After L11

```text
Top 5 per ranking_group rows
L6-L9 compact component summaries per listed symbol
copy state if Dossier copies are implemented
```

### After L12-L14

```text
Group heat/quality table
Selected groups
Candidate pool leaders/backups
```

### After L15-L16

```text
Global Top 10 inspection basket
Diversity/correlation notes
Backup fill notes
Dossier copy integrity status
```

### After L17-L22

```text
Selected evidence progress
OHLC/wick/tick/indicator/deep evidence readiness
DOM proxy caveats
```

Board must remain compact. Full raw evidence belongs in Dossiers/Workbench.

---

## Dossier Copy Law For Selection Desk

When Selection Desk begins copying Dossiers:

```text
source_dossier_path=<Dossier owner final file>
selection_copy_path=<Selection Desk stable route file>
copy_mode=byte_copy_from_dossier_owner
copy_status=copied/missing_source/write_failed/size_mismatch/checksum_mismatch
```

Copied Dossier files must not contain inserted rank text, Selection Desk headers, or copied-summary additions. If opened from Dossier or Selection Desk, content must match.

Rank/selection explanation belongs in:

```text
Market Board
Selection Desk/Selection Index.txt
current_top5_manifest.txt
current_top10_manifest.txt
Workbench copy proof
```

---

## Future Chat Startup Checklist

Before patching any future layer, read:

```text
README.md
control/02_MASTER_REPO_FILE_INDEX.md
control/00_CONTROL_INDEX.md
control/01_CONTROL_GOVERNANCE.md
blueprint/02_RUNTIME_OWNER_BLUEPRINT.md
blueprint/03_LOGICAL_LAYER_BLUEPRINT.md
blueprint/05_PUBLICATION_SURFACE_BLUEPRINT.md
docs/26_L10_TAXONOMY_CLASSIFICATION_CONTROL.md
docs/27_RUNTIME_5_TO_7_FUTURE_LAYER_PLAYBOOK.md
relevant layer control doc
relevant active source file
```

Then inspect current source/runtime outputs before designing. Do not rely on memory or this guide as runtime proof.

---

## Layer Completion Gates

### Runtime 5 complete when

```text
L10 taxonomy authority published
L11 intra-group ranks published
L12 group heat/quality published
L13 selected groups published
L14 candidate pool published
Board shows group/leader/candidate state
Dossiers show per-symbol L10-L14 state
Selection Desk group views are stable and copy-safe if copies are implemented
trade_permission=false
```

### Runtime 6 complete when

```text
L15 correlation/diversity published
L16 Global Top 10 inspection basket published
Board shows Global Top 10 with compact reasons
Selection Desk/Global has copy-safe view if copies are implemented
trade_permission=false
```

### Runtime 7 selected evidence complete when

```text
L17 deep selection split published
L18 selected OHLC packs ready/partial ledgers published
L19 selected wick/candle geometry ready/partial ledgers published
L20 selected tick pack ready/partial ledgers published
L21 selected indicator/reference pack ready/partial ledgers published
L22 selected deep evidence/liquidity/DOM proxy ready/partial ledgers published
Board shows selected evidence progress
Dossiers show selected-symbol deep evidence sections
No all-symbol deep evidence collection
trade_permission=false
```

---

## Decision

Use this playbook as the guardrail for future layers. If a future patch creates duplicate truth owners, shadow Dossier rendering, changing-rank parent folders, hidden selection authority, or trade-permission language before Layer 23, reject it.
