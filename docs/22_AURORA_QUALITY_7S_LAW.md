# AURORA CORE - QUALITY 7S LAW

**System:** AURORA CORE  
**Status:** Mandatory development-quality law.  
**Scope:** EA source files, route/file output structure, Workbench diagnostics, Dossiers, Selection Desk, generated universe files, docs, runbooks, prompts, reports, and future operator-facing outputs.

---

## 0. Purpose

AURORA CORE must not become a technically correct mess.

The final product must look and read like a professional trading intelligence system:

```text
clear structure
stable routes
logical information flow
operator-readable files
no hunting for truth
no duplicate truth owners
no decorative garbage
no fake readiness
```

This law adapts the practical spirit of 5S/6S/7S workplace quality into Aurora EA development.

It is not copied literally.

It is converted into enforceable EA quality rules.

---

## 1. The Aurora 7S Quality Law

Aurora development uses these seven gates:

```text
1. Sort
2. Structure
3. Shine
4. Standardize
5. Save
6. Safety
7. Sustain
```

Every meaningful patch, document update, generated file, output surface, or folder route must pass these gates.

If a patch fails the 7S law, it is not professional enough to be merged without a clear exception and rollback plan.

---

## 2. S1 - Sort

Sort means remove or quarantine what does not belong.

Required checks:

```text
remove dead helpers
remove stale labels
remove obsolete route names
remove duplicate owner logic
remove fake proof language
remove old Top-N parent route wording
quarantine research-only ideas
separate historical names from active runtime authority
```

For Aurora bucket/universe work:

```text
old workbook field names may exist as source/legacy fields
old workbook field names must not become active EA-facing authority
```

Examples:

```text
aggregation_group may be source input
ranking_group is active EA-facing meaning
Top 5 may be child file content
Top 5 must not be a changing parent route owner
```

---

## 3. S2 - Structure

Structure means every truth has a correct home.

Required route law:

```text
Dossiers = per-symbol truth
Selection Desk = grouped attention and selection views
Workbench = runtime proof, diagnostics, manifests, upgrade logs
Runtime 2 = universe/taxonomy lookup truth
Runtime 7 = route and FileIO ownership
```

Current stable route contract:

```text
Dossiers/
Dossiers/Open/
Dossiers/Closed/
Dossiers/Unknown/
Selection Desk/Groups/
Selection Desk/Global/
Selection Desk/Selection Index.txt
Workbench/
```

Forbidden structure drift:

```text
Dossiers grouped by bucket/ranking_group as source storage
Top 5 / Top 10 / rank numbers as parent folder names
cycle IDs as parent folder names
hidden writer folders
duplicate FileIO/path owners
operator data buried only inside diagnostics
large ledgers dumped into cockpit files
```

Rule:

```text
stable things become folders
changing things become file rows, metadata, indexes, or generated reports
```

---

## 4. S3 - Shine

Shine means clean, polished, readable output.

Operator-facing files must be easy to scan.

Required output quality:

```text
clear title/header
schema/version/source owner
generated time with honest time basis
status first
counts before detail
warnings before long rows
short summaries before deep ledgers
consistent key names
consistent separators
clear section order
no random dumps
no mixed old/new vocabulary
```

Every operator-facing file should answer quickly:

```text
What is this?
When was it generated?
What owner wrote it?
Is it complete, partial, degraded, blocked, or placeholder-only?
What counts matter?
What should I look at next?
What must I not infer from this file?
```

Candidate/selection surfaces must look professional, not like raw debug trash.

Deep detail belongs in Workbench/Diagnostics, not every cockpit file.

---

## 5. S4 - Standardize

Standardize means the same truth is represented the same way everywhere.

Required naming contract:

```text
asset_class
market_group
market_segment
ranking_group
symbol
server
broker_file
broker_symbol
canonical_symbol
ea_lookup_key
strict_rank_allowed
public_research_rank_allowed
review_lane
classification_confidence
evidence_rank
runtime_permission
trade_permission
```

Required boolean/status style:

```text
true/false for booleans
LOOKUP_ONLY_NOT_TRADE_PERMISSION for lookup-only runtime permission
structure_only for placeholders
skeleton_only_rows_not_imported when Runtime 2 rows are not loaded
```

Forbidden active terms:

```text
major_bucket
minor_bucket
aggregation_group as active EA authority
bucket_top5
sub_bucket_top5
best trades
safe trades
prop-firm ready without proof
```

Standardize also means route names, docs, diagnostics, README, runbooks, and source code must not disagree.

If source and docs disagree, current source wins, docs must be patched, and the contradiction must be logged.

---

## 6. S5 - Save

Save means preserve useful truth cleanly and safely.

Required save law:

```text
important outputs must be physically written when their owner exists
writes must use the approved FileIO owner
atomic write pattern must be preserved
upgrade/change logs must record meaningful source changes
local workbooks must not be accidentally committed
runtime proof must be kept in Workbench, Manifest, Diagnostics, and Upgrade logs
```

FileIO law:

```text
build content in memory
write temp
flush at controlled boundary
close
move temp to final with rewrite as needed
verify final existence/size
report exact failure status
```

Save does not mean spam.

Forbidden save behavior:

```text
per-tick log spam
heavy flush loops
large workbook parsing inside OnTimer
unbounded append files
manual duplicate writers
hidden fallback writers
```

---

## 7. S6 - Safety

Safety means the EA must not mislead the trader/operator.

Required safety labels:

```text
trade_permission=false until explicitly proven otherwise
selection is attention, not permission
ranking is inspection priority, not edge proof
lookup truth is not live tradability
compile success is not runtime proof
runtime file output is not trading edge
public research is not broker-confirmed truth
```

Prop-firm safety blocks:

```text
no live/funded permission without firm rule profile
no edge claim without backtest/OOS/demo/live evidence chain
no strategy/execution permission from folder/ranking work
no public-research row treated as strict broker truth
```

If an output can be misunderstood as permission, it must say what it is not.

---

## 8. S7 - Sustain

Sustain means quality must survive future runs.

Required recurring checks:

```text
README/source/doc route alignment
no duplicate owner scan
no stale route names
no old bucket labels as active authority
no dead helper scan
compile-risk sniff
runtime-risk sniff
proof level stated
rollback path stated
```

Every serious run should leave the repo:

```text
cleaner
more coherent
more professional
more operator-readable
less duplicated
less ambiguous
more testable
```

If a patch makes the system harder to understand, it failed Sustain even if the code compiles.

---

## 9. Selection Desk Quality Contract

Selection Desk must remain clean and readable.

Stable parent structure:

```text
Selection Desk/
├── Groups/
├── Global/
└── Selection Index.txt
```

Planned child outputs are still allowed:

```text
Selection Desk/Groups/<ranking_group>.txt
Selection Desk/Global/Global Top 10.txt
Selection Desk/Groups/_INDEX.txt
Selection Desk/Global/_INDEX.txt
```

Top-N is not removed.

Top-N is relocated to file content and child output files.

The parent folder names stay stable.

Group files may later contain:

```text
group_top_n=5
ranking_group=<name>
symbol_count=<count>
rank_1=<symbol>
rank_2=<symbol>
rank_3=<symbol>
rank_4=<symbol>
rank_5=<symbol>
trade_permission=false
```

Global files may later contain:

```text
global_top_n=10
cycle_id=<id>
rank_1=<symbol>
...
rank_10=<symbol>
trade_permission=false
```

Selection Index may later contain:

```text
cycle_id
generated_at
group_rank
symbol_rank
asset_class
market_group
market_segment
ranking_group
symbol
score_summary
evidence_status
gate_status
reject_reason
child_file_path
```

---

## 10. Dossier Quality Contract

Dossiers stay simple and stable:

```text
Dossiers/Open/
Dossiers/Closed/
Dossiers/Unknown/
```

Dossiers must not become bucket/ranking_group parent folders.

Each symbol Dossier should carry taxonomy inside the file:

```text
asset_class=<value>
market_group=<value>
market_segment=<value>
ranking_group=<value>
```

Dossier route = symbol availability/storage truth.

Ranking/grouping = file content and Selection Desk views.

Do not mix them.

---

## 11. Aurora Quality Acceptance Checklist

Before a patch is called clean, verify:

```text
Does every output have a correct home?
Can an operator find the important data in under 10 seconds?
Are changing rankings inside files, not folders?
Are stable concepts folders?
Are old names quarantined or translated?
Are docs and source aligned?
Is FileIO still single-owner?
Are placeholders clearly labelled as placeholders?
Are trade/edge/prop-firm claims blocked?
Is there a rollback path?
```

If the answer is no, the patch is not finished.

---

## 12. Decision Law

For quality/structure work:

```text
If structure is correct and readable, PROCEED.
If source/docs disagree, HOLD.
If route ownership is duplicated, KILL the duplicate.
If output quality is unproven, TEST FIRST.
```

This law is mandatory for future Aurora Core development.
