# Gateway Index

This folder is the Veritas Atlas Gateway source area.

## Purpose

Gateway is the EXE worker side of VERITAS ATLAS. Gateway owns heavy analysis and returns compact, validated packets to MT5.

Official name:

```text
Veritas Atlas Gateway
Gateway
```

Do not rename it to daemon, helper, worker, assistant, or bot in active source/docs.

## Gateway layer scope

Gateway owns:

```text
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

## Must not own

Gateway must not own:

```text
broker truth
account truth
MT5 quote truth
FileIO routes
MT5 publication authority
final Vault safety authority
auto execution authority
```

## Required subfolders

Create only when implementation begins:

```text
l08_gateway_intake/
l09_cost_friction/
l10_session_context/
l11_movement_range/
l12_structure_location/
l13_taxonomy_groups/
l14_group_heat/
l15_in_group_ranking/
l16_correlation_diversity/
l17_global_selection/
l18_deep_routing/
l19_raw_evidence_pack/
l20_candle_wick_geometry/
l21_indicator_reference/
l22_liquidity_map/
l23_structure_reaction_evidence/
l24_fvg_imbalance_evidence/
l25_orb_evidence/
l26_poi_zone_evidence/
l27_risk_geometry/
l28_setup_candidate_builder/
l29_trader_chat_pack/
l30_validation_ledger/
common/
io/
runtime/
tests/
```

Each subfolder must have exactly one `INDEX.md`, one `GUIDELINES.md`, and source/test files only.

## Current implementation truth

Blueprint only until source, tests, package build, and runtime handshake prove implementation.
