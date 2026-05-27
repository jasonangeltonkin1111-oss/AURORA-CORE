# 35 L16 GLOBAL TOP10 BUILDER CONTROL

Layer 16 builds the diversified Global Top 10 inspection basket.

This layer is inspection only. It is not a trade signal, edge proof, alert, prop-firm approval, or order layer.

## Inputs

L16 may consume L14 candidate pool files and L15 correlation-diversity files only. It may use L12 and L13 score context already carried through L14 rows.

It must not read all-symbol OHLC, create private OHLC caches, call MT5, poll brokers, read trade history, or use strategy/setup logic.

## Selection law

L16 starts with highest inspection score first, then enforces diversification.

Default rule: after the first selected candidate, a new candidate may enter the basket only when its absolute pairwise correlation to every already selected symbol is at or below 0.30. This threshold is an untested default, not holy law.

If strict rules cannot fill 10 symbols, L16 must publish unfilled slots or explicit degraded fallback truth. It must not silently break the rule.

## Score

V1 score uses existing inspection evidence only:

l14 candidate priority 55 percent, l15 diversity score 20 percent, group selection score 10 percent, group strength 10 percent, group quality 5 percent.

Forbidden ingredients: directional setup logic, FVG, OB, BOS, CHOCH, sweep claims, AI confidence, probability-marketing labels, prop-rule approval, or order logic.

## Outputs

Workbench/Gateway/Outbox/Layers/Layer_16_Global_Top10_Builder must publish l16_global_top10.csv, l16_global_top10_rejects.csv, l16_global_top10_fallbacks.csv, l16_global_top10_summary.txt, and l16_global_top10.manifest.

Selection Desk/Global must publish current_top10.csv, current_top10_manifest.txt, and Global Top 10.txt.

## Meaning

Global Top 10 means inspect these first. It does not mean best trades, entry list, validated edge, or prop-rule clearance.

## Acceptance

L16 is accepted only when runtime proves it reads L14 and L15 files, picks high score first, applies the correlation cap against already selected symbols, records rejects, records unfilled slots, writes stable Global route files, and keeps all permission/order fields false.

Decision: TEST FIRST.
