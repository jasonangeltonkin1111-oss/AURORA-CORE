# 33 L13 CLOSEOUT AND L14 HANDOFF

## Layer 13 Closeout State

Layer 13 is Dynamic Ranking Group Selection.

It answers:

```text
Which ranking_groups should move forward for candidate sourcing attention this cycle?
```

It does not answer:

```text
Which symbols are candidates?
Which symbols are diversified?
Which symbols enter Global Top 10?
Which symbols are trades?
```

L13 is group-attention routing only.

---

## Runtime Evidence From L13 Test Package

The 2026-05-24 runtime package `18503(58).7z` proved that L13 is physically publishing and visible:

```text
result_latest.txt contains l13_dynamic_group_selection_status=accepted
Layer_13_Dynamic_Ranking_Group_Selection folder exists
l13_selected_ranking_groups.csv exists
l13_rejected_ranking_groups.csv exists
l13_fallback_decisions.csv exists
l13_group_selection_summary.txt exists
l13_selected_ranking_groups.manifest exists
Selection Desk/Groups/00_Selected_Ranking_Groups.txt exists
Selection Desk/Groups/00_Selected_Ranking_Groups.csv exists
Market Board contains LAYER 13 - DYNAMIC RANKING GROUP SELECTION
Dossiers contain LAYER 13 - DYNAMIC RANKING GROUP SELECTION
trade_permission=false
entry_signal=false
execution=false
```

That evidence upgrades L13 from source-wired to runtime-published for the tested build.

Latest source patch after that package corrected thin-group truth labeling. A rebuild/live test should confirm thin groups now print as `SELECTED_THIN_FALLBACK` / `thin_fallback`.

---

## Current L13 Output Contract

Worker output route:

```text
Workbench/Gateway/Outbox/Layers/Layer_13_Dynamic_Ranking_Group_Selection/
    l13_selected_ranking_groups.csv
    l13_rejected_ranking_groups.csv
    l13_fallback_decisions.csv
    l13_group_selection_summary.txt
    l13_selected_ranking_groups.manifest
    RankingGroups/
        <ranking_group_slug>.selection.txt
```

Visible operator route:

```text
Selection Desk/Groups/
    00_Selected_Ranking_Groups.txt
    00_Selected_Ranking_Groups.csv
```

---

## Final L13 Selection Ladder

L13 fills best-available groups from strongest to weakest while keeping truth labels explicit:

```text
Tier 1: SELECTED_STRONG / strong
Tier 2: SELECTED_WITH_REVIEW / usable_review
Tier 3: SELECTED_WEAK_FALLBACK / weak_fallback
Tier 4: SELECTED_THIN_FALLBACK / thin_fallback
Tier 5: FALLBACK_SELECTED_MARKET_SEGMENT / market_segment_fallback (future fallback only)
```

Core law:

```text
L13 must not select zero merely because the market is weak.
L13 may select weak/thin groups for inspection.
L13 must label weak/thin/fallback selection honestly.
L13 must never convert selected groups into trade permission.
```

---

## Thin Group Closeout Rule

Thin groups are a separate risk class.

If `thin_group_flag=true`, L13 must label the selected group as:

```text
Group Selection State: SELECTED_THIN_FALLBACK
Selection Quality Tier: thin_fallback
```

It must not label thin groups as ordinary weak fallback.

This keeps L14/L15/L16 from mistaking thin fallback for normal weak-but-usable group depth.

---

## Permission Contract

All L13 outputs must keep:

```text
selection_runtime=false
trade_permission=false
entry_signal=false
execution=false
```

L13 selection means:

```text
ranking_group_selected_for_candidate_sourcing_attention_only
```

It does not mean:

```text
candidate symbol selected
basket selected
trade setup found
permission granted
```

---

## L13 Acceptance Checklist

L13 is considered closed when the latest rebuild/runtime package confirms:

```text
l13_dynamic_group_selection_status=accepted
l13_selected_ranking_group_count > 0
l13_write_failed_count=0
Selection Desk selected group files exist
Market Board L13 section exists
Dossier L13 section exists
Workbench L13 section exists
Thin groups, if selected, show SELECTED_THIN_FALLBACK / thin_fallback
trade_permission=false
entry_signal=false
execution=false
```

---

## Known Minor Cleanup

The canonical runtime package showed worker version:

```text
0.6.13_l13_dynamic_ranking_group_selection
```

If Git source still shows an older worker version label, update the version label during the next local rebuild patch only. Do not broad-rewrite the worker file just to change a label unless done safely from a local checkout.

---

## L14 Handoff Boundary

Layer 14 starts after L13.

L14 purpose:

```text
Build the raw candidate pool from selected ranking_groups.
```

L14 inputs:

```text
L13 selected groups
L11 Top 5 per group
L12 heat/quality context
```

L14 owns:

```text
candidate_pool_members
candidate_source
candidate_reason
backup_included_flag
```

L14 must not do:

```text
correlation filtering
Global Top 10 final basket
trade permission
entry signals
execution
```

L14 creates the pool. It does not diversify it yet.

---

## Decision

L13: TEST FIRST until the latest thin-fallback patch is runtime-proven.

L14: READY TO DESIGN/START after one final L13 rebuild proof package confirms the thin fallback labels.
