# 00 BLUEPRINT INDEX

## Purpose

Blueprint index for AURORA CORE system-level architecture, logical layers, runtime ownership, publication surfaces, permission boundaries, validation structure, route/FileIO contracts, and MT5 source placement.

This index is for the trading system itself. It is not a branch-management map, worker-process map, or overseer-process map.

## First read before using any blueprint

1. `AGENTS.md`
2. `README.md`
3. `control/02_MASTER_REPO_FILE_INDEX.md`
4. `control/00_CONTROL_INDEX.md`
5. `control/01_CONTROL_GOVERNANCE.md`

Then open the blueprint file relevant to the system layer, owner, route, publication surface, or validation boundary being inspected.

## Active blueprint navigation

- `blueprint/01_SYSTEM_IDENTITY_AND_MISSION.md` = system identity and mission
- `blueprint/02_RUNTIME_OWNER_BLUEPRINT.md` = runtime owner and system-service boundaries
- `blueprint/03_LOGICAL_LAYER_BLUEPRINT.md` = active 23-layer trading/system chain
- `blueprint/04_BUILD_PHASE_BLUEPRINT.md` = build phase and evidence gates
- `blueprint/05_PUBLICATION_SURFACE_BLUEPRINT.md` = Board, Dossier, Selection Desk, Workbench publication surfaces
- `blueprint/06_PERMISSION_AND_VALIDATION_BLUEPRINT.md` = permission, validation, review/export, and proof boundaries
- `blueprint/07_FILEIO_ROUTE_OWNERSHIP_CONTRACT.md` = route and FileIO ownership
- `blueprint/08_MT5_SOURCE_FOLDER_CONTRACT.md` = MT5 source placement and source-folder contract

## Blueprint authority warning

Blueprints are structural contracts. Current source/config/index files decide active implementation truth when source and blueprint disagree.

A blueprint does not prove source correctness, compile success, runtime output, broker compatibility, prop-firm safety, trading permission, edge validation, or live readiness.

## Retired process blueprint

`blueprint/09_PARALLEL_WORK_AND_MERGE_CONTROL_BLUEPRINT.md` is no longer part of active system blueprint navigation. The repository front door must describe AURORA CORE as a trading-intelligence system, not as an overseer/worker-process system.

Historical branch/process controls may be reconstructed from Git history if ever needed, but they are not active system identity.
