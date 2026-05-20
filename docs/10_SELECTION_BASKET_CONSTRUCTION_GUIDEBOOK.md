# AURORA CORE - SELECTION DESK AND RANKING GROUP GUIDEBOOK

**System:** AURORA CORE  
**Role:** Selection Desk folder contract, taxonomy naming contract, Ranking Group authority, candidate-pool construction, diversification/correlation control, Global Top 10 inspection basket, backup fill, and selection-ledger authority.  
**Status:** Professional contract lock. This replaces old major/minor/bucket wording for new active work.

---

## 0. Purpose

This guidebook defines how AURORA CORE stores classification and how it later selects inspection candidates.

The permanent taxonomy contract is:

```text
asset_class -> market_group -> market_segment -> symbol
ranking_group = EA-safe aggregation group used for caps, selection, diversification, and Top 5 / Top 10 logic
```

Core law:

```text
Selection is attention.
Selection is not permission.
Ranking Group is the selection/cap/diversification grouping field.
Market Segment is classification detail, not automatically the ranking bucket.
```

The enemy:

```text
Global Top 10 becomes "best trades".
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
aggregation_group
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
Which EA-safe aggregation group should this symbol use for ranking, caps, diversification, and selection controls?
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

Allowed current placeholder folders:

```text
Selection Desk/Ranking Group Top 5/
Selection Desk/Global Top 10/
```

Required placeholder file metadata:

```text
placeholder_status=structure_only
truth_status=no_runtime_truth_yet
ranking_group_runtime=false
selection_logic_runtime=false
trade_permission=false
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
Selection Desk folder naming contract
ranking_group selection authority
Ranking Group Top 5 later
candidate pool later
dynamic ranking_group selection later
correlation / overlap filtering later
diversity scoring later
backup fill later
Global Top 10 later
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

## 7. Ranking Group Top 5 vs Global Top 10

Ranking Group Top 5 answers later:

```text
Which symbols are strongest alternatives inside this ranking_group?
```

Global Top 10 answers later:

```text
Which selected candidates form the best diversified inspection basket right now?
```

Ranking Group Top 5 must remain visible even if a symbol is not in Global Top 10.

Correlation rejection from Global Top 10 must not erase the symbol from its ranking group list.

---

## 8. Candidate Pool Contract

Candidate pool should be built from ranking group leaders.

Wrong:

```text
sort all eligible symbols globally and pick top 10
```

Correct later:

```text
rank inside ranking_group
select active/valid ranking_groups
build candidate pool from ranking_group leaders
apply diversity/correlation controls
build Global Top 10
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
ranking_group_rank
surface_score_summary
ranking_group_heat_score
candidate_reason
candidate_status
data_quality_status
```

---

## 9. Dynamic Ranking Group Selection Contract

Dynamic ranking group selection may consider later:

```text
ranking_group_heat
ranking_group_strength
ranking_group_quality
ranking_group_activity
ranking_group_cost
ranking_group_movement
ranking_group_degraded_count
ranking_group_backup_depth
```

Dynamic ranking groups are selected for inspection coverage.

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

Backup fill is used later when Global Top 10 cannot be filled cleanly from primary candidates.

Backup fill must record:

```text
backup_fill_used
backup_symbol
backup_source_ranking_group
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
Ranking Group = EA selection/cap/diversification bucket
```

Retired active names:

```text
major_bucket
minor_bucket
aggregation_group
bucket_top5
sub_bucket_top5
```

Current status:

```text
This contract locks the professional naming and route placeholder direction.
No real ranking, selection, candidate pool, strategy, execution, edge proof, or trade permission exists yet.
```
