# 39 AURORA COMPLETION EPOCH CONTROL

## Purpose
Defines the currentness and completion contract used by the external worker chain from L14 through L19, plus future-safe L20-L23 vocabulary.

This document is guidance. Active source files remain implementation truth.

## Currentness Contract
Every downstream-selected layer must fail closed when currentness is missing.

Required status meaning:
- `latest_current=true` means the layer was built from the latest accepted upstream source.
- `downstream_allowed=true` means a later layer may consume this output as current chain truth.
- `visible_output_source=held_previous` is operator history only.
- `write_degraded`, `write_failed`, `decode_error`, `pending`, `partial`, `degraded`, `stale`, and `missing` cannot create an accepted static epoch.

## Completion Levels
Core Completion and Deep Completion are separate.

Core Completion requires current L6-L17 plus current selected minimum L18/L19 evidence. L18/L19 may be `complete_history_limited` when data exists, decodes, is fresh or aging, and only display depth is shallow.

Deep Completion can remain `deep_filling` after core completion. History-limited deep evidence must stay labelled and must not imply trading readiness.

## L15 Correlation Contract
L15 consumes latest-current L14 only.

Correlation is recent reachable diversification context:
- primary timeframe: M15
- secondary timeframe: M5
- minimum aligned returns: 64
- deep target returns: 350
- H1: optional reference, not primary blocker

Correlation is not edge proof, direction, setup, entry, or trade permission.

## Future-Layer Weave
L20-L23 are future-safe scaffolds until source and runtime proof activate them.

L20 may expose selected-symbol feed-quality and execution-risk proxy metadata with an MT5 proxy caveat. It must not claim institution-grade flow authority.

L21 may expose explainable indicator/reference context such as ATR, VWAP, Bollinger, Donchian, and range metadata. It must not become an indicator-stack signal engine.

L22 may expose evidence/POI/liquidity proxy structures and validation-safe placeholders. It must not use directional wording, probability-marketing claims, or permission authority.

L23 may expose validation-state scaffolding, evidence-chain tracking, missing/degraded evidence lists, and kill-condition labels. Defaults remain:
- `trade_permission=false`
- `entry_signal=false`
- `execution=false`
- `auto_trade_allowed=false`
- `alert_allowed=false`

Validation is not proof. GPT is not runtime authority. Evidence is not permission.
