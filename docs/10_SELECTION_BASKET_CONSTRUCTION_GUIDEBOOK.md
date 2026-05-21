# AURORA CORE - SELECTION DESK AND GROUP SELECTION GUIDEBOOK

**System:** AURORA CORE  
**Role:** Selection Desk stable parent-folder contract, taxonomy naming contract, group authority, candidate-pool construction, diversification/correlation control, global inspection basket, backup fill, and selection-ledger authority.  
**Status:** Professional stable-parent contract lock. This replaces old major/minor/bucket wording and removes Top-N numbering from parent folder names.

---

## 0. Purpose

This guidebook defines how AURORA CORE stores classification and how it later selects inspection candidates.

The permanent taxonomy contract is:

```text
asset_class -> market_group -> market_segment -> symbol
ranking_group = EA-safe group field used for caps, selection, diversification, and Top-N logic
```

Core law:

```text
Selection is attention.
Selection is not permission.
Folder parents are stable ownership surfaces.
Ranking/order/Top-N numbers are child-file content, not parent-folder names.
Ranking Group is the selection/cap/diversification grouping field.
Market Segment is classification detail, not automatically the ranking bucket.
```

The enemy:

```text
Global Top 10 becomes "best trades".
Changing rank/order becomes a folder route.
```

Kill that language immediately.

---

## 1. Naming Contract

Use these exact taxonomy columns:

```text
asset_class
market_group
market_segment
ranking_group
symbol
```

Keep these broker/source safety columns where applicable:

```text
server
account
broker_file
broker_symbol
canonical_symbol
ea_lookup_key
taxonomy_lookup_key
classification_confidence
evidence_status
strict_rank_allowed
public_research_rank_allowed
review_lane
block_reason
```

Old names are retired for active source fields, route names, and publication labels:

```text
major_bucket
minor_bucket
ranking_group
bucket_top5
sub_bucket_top5
```

Do not reintroduce them as active source fields, route names, or operator-facing publication labels.

---

## 2. Taxonomy Hierarchy

AURORA CORE stores a universal three-level hierarchy:

```text
Asset Class
└── Market Group
    └── Market Segment
        └── Symbol
```

Examples:

```text
asset_class=Equities
market_group=Information Technology
market_segment=Semiconductors
symbol=NVDA
ranking_group=Information Technology / Semiconductors
```

```text
asset_class=Commodities
market_group=Metals
market_segment=Gold
symbol=XAUUSD
ranking_group=Metals / Gold
```

```text
asset_class=Crypto
market_group=Major Crypto
market_segment=Bitcoin
symbol=BTCUSD
ranking_group=Major Crypto / Bitcoin
```

```text
asset_class=FX
market_group=Majors
market_segment=USD Cross
symbol=EURUSD
ranking_group=FX Majors / USD Crosses
```

Non-equity symbols must not be forced into equity-style sector naming.

---

## 3. Ranking Group Law

Ranking Group answers:

```text
Which EA-safe group should this symbol use for ranking, caps, diversification, and selection controls?
```

Market Segment answers:

```text
What precise classification segment does this symbol belong to?
```

These are not always the same.

Why:

```text
Some segments only contain 1-2 symbols.
Ranking every tiny segment separately creates fake diversification and unstable selection.
```

Therefore:

```text
Store asset_class, market_group, and market_segment for classification truth.
Use ranking_group for selection/cap/diversification rules unless a later owner explicitly proves a narrower grouping is safe.
```

---

## 4. Selection Desk Folder Contract

Runtime 7 Publication Owner owns the folder routes.

Allowed current stable parent folders:

```text
Selection Desk/Groups/
Selection Desk/Global/
```

Forbidden parent folder names:

```text
Selection Desk/Ranking Group Top 5/
Selection Desk/Global Top 10/
Selection Desk/Top 5/
Selection Desk/Top 10/
Selection Desk/Rank 1/
Selection Desk/Cycle <number>/
```

Reason:

```text
Top-N and rank order change over time.
Changing order must not change route ownership.
Only child files/rows may carry rank numbers, cycle IDs, and Top-N metadata.
```

Allowed future pattern:

```text
Selection Desk/Groups/_INDEX.txt
Selection Desk/Groups/<stable-group-name>.txt
Selection Desk/Global/_INDEX.txt
Selection Desk/Global/Global Selection.txt
```

The sibling `_INDEX.txt` file may explain:

```text
cycle_id
generated_at
selection_status
ranking_order_definition
rank_number_meaning
top_n_cutoff
input_source
expected_child_files
row_count
strict/public/review/degraded counts
reject/backup counts
runtime_permission=false
trade_permission=false
```

Required placeholder file metadata:

```text
placeholder_status=structure_only
truth_status=no_runtime_truth_yet
selection_parent_runtime=true
ranking_group_runtime=false
selection_logic_runtime=false
trade_permission=false
route_contract=stable_parent_folder_numbers_live_inside_child_files_not_folder_names
scope_guard=no_symbols_no_ranking_no_selection_claim_no_strategy_no_execution
```

No placeholder may imply ranked symbols, live selection, trade permission, edge, or prop-firm readiness.

The Dossiers folder contract stays separate and must not be renamed by Selection Desk work:

```text
Dossiers/
Dossiers/Open/
Dossiers/Closed/
Dossiers/Unknown/
```

---

## 5. What This Guidebook Owns

This guidebook owns:

```text
taxonomy naming contract
Selection Desk stable parent folder naming contract
ranking_group selection authority
Groups index later
Global index later
group child files later
global child files later
candidate pool later
dynamic ranking_group selection later
correlation / overlap filtering later
diversity scoring later
backup fill later
global inspection basket later
correlation rejects later
selection hysteresis later
selection churn control later
manual pins later
selected-deep-evidence feed later
selection ledger requirements later
```

---

## 6. What This Guidebook Must Not Own

This guidebook must not own:

```text
FileIO implementation
Runtime 0 heartbeat/governance proof
Runtime 1 account truth
surface score formulas
deep evidence computation
trade permission
setup validation
alerts
outcome edge claims
trade execution
```

Selection chooses attention.

Selection does not approve trading.

---

## 7. Groups vs Global

Groups answers later:

```text
Which symbols are strongest alternatives inside each stable ranking_group?
```

Global answers later:

```text
Which selected candidates form the best diversified inspection basket right now?
```

Group files must remain visible even if a symbol is not in the global basket.

Correlation rejection from Global must not erase the symbol from its group list.

---

## 8. Candidate Pool Contract

Candidate pool should be built from group leaders.

Wrong:

```text
sort all eligible symbols globally and pick top 10
```

Correct later:

```text
rank inside ranking_group
select active/valid ranking_groups
build candidate pool from group leaders
apply diversity/correlation controls
build global inspection basket
publish rejects/backups
```

Candidate pool fields later:

```text
cycle_id
symbol
asset_class
market_group
market_segment
ranking_group
rank_in_group
surface_score_summary
group_heat_score
candidate_reason
candidate_status
data_quality_status
```

---

## 9. Dynamic Group Selection Contract

Dynamic group selection may consider later:

```text
group_heat
group_strength
group_quality
group_activity
group_cost
group_movement
group_degraded_count
group_backup_depth
```

Dynamic groups are selected for inspection coverage.

They are not trading sectors.

They are not permission groups.

---

## 10. Correlation / Overlap Control

Correlation and overlap controls help avoid picking many versions of the same exposure.

Fields later:

```text
correlation_sample_count
correlation_window
correlation_to_selected
currency_overlap
ranking_group_overlap
asset_class_overlap
market_group_overlap
market_segment_overlap
diversity_score
correlation_confidence
reject_reason
```

No naked correlation numbers.

Every correlation value needs:

```text
window
sample_count
confidence
source
```

---

## 11. Diversity Score Contract

Diversity score may use later:

```text
correlation_to_selected
currency_overlap
ranking_group_overlap
asset_class_overlap
market_group_overlap
market_segment_overlap
instrument_type_overlap
session_overlap
```

Diversity score means:

```text
concentration control
```

It does not mean:

```text
edge
lower guaranteed risk
prop-firm safety
```

---

## 12. Weak Evidence Rule

If correlation, taxonomy, or ranking input is insufficient:

```text
correlation_status=insufficient_sample
classification_confidence=low_or_unknown
strict_rank_allowed=false unless source evidence proves otherwise
selection_may_continue=true only if clearly labelled inspection-only
trade_permission=false
```

Do not block all publication because taxonomy or correlation evidence is weak.

Publish weak evidence as weak.

---

## 13. Backup Fill Rules

Backup fill is used later when Global cannot be filled cleanly from primary candidates.

Backup fill must record:

```text
backup_fill_used
backup_symbol
backup_source_group
backup_reason
backup_rank
backup_data_quality_status
```

Backup fill is still inspection-only.

---

## 14. Anti-Fake-Proof Rules

Forbidden language:

```text
best trades
safe basket
edge proven
prop-firm ready
trade approved
```

Required metadata on selection outputs later:

```text
selection_type=inspection
trade_permission=false
directional_validity=false
expectancy_validated=false
ranking_group_contract=active
```

---

## 15. Runtime Constraint

MQL5 timer work must stay lightweight.

The EA should consume taxonomy/ranking_group as a cached lookup, not rebuild or over-analyze taxonomy inside OnTimer.

Runtime owners must not turn taxonomy classification into a heavy per-heartbeat process.

---

## 16. Decision

Use:

```text
Asset Class -> Market Group -> Market Segment -> Symbol
Ranking Group = EA selection/cap/diversification group field
Selection Desk/Groups = stable parent for per-group child files and index metadata
Selection Desk/Global = stable parent for global child files and index metadata
```

Retired active names:

```text
major_bucket
minor_bucket
ranking_group
bucket_top5
sub_bucket_top5
```

Current status:

```text
This contract locks professional naming and stable parent routes.
No real ranking, selection, candidate pool, strategy, execution, edge proof, or trade permission exists yet.
```

## Restoration Addendum — Spine Alignment (L10-L16)
- Ranking Group Top-N alternatives remain visible even when not in Global Top 10.
- Global Top 10 means diversified inspection basket, not best 10 trades.
- Correlation rejects apply to Global Top 10 construction only; ranking_group alternatives remain visible for operator review.
- Candidate pool sources: selected ranking_group leaders, backup leaders, ranking_group heat leaders, raw global leaders if policy allows, manual pins later.
- Dynamic selection: max 7 ranking_groups; if valid groups 3-6 select all; if <=2 use market_segment fallback.
- No route folders may encode ranks, Top-N values, or cycle IDs.
