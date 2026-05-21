# 03 CONTRADICTION LEDGER

## Purpose
Track explicit contradictions found during governance/documentation repair runs and record their disposition.

| contradiction_id | status | Claim A | Claim B | Source for A | Source for B | Which source outranks | Patch applied | Remaining risk |
|---|---|---|---|---|---|---|---|---|
| C-2026-05-20-01 | fixed | MT5 folder treated as scaffold/planning-only and forbids implementation files in run context. | Active MT5 implementation exists in limited scope (Runtime 0, Runtime 1 Layer 1, Runtime 2 skeleton, Runtime 7). | `mt5/00_MT5_SOURCE_INDEX.md` (pre-patch wording) | `mt5/AuroraCore.mq5`, `mt5/core/AC_Config.mqh`, `control/01_CURRENT_SOURCE_TRUTH_MAP.md` | Active source + current source truth map | Reworded purpose/current-status/no-go to reflect active limited source and prevent duplicate-owner rewrites instead of blanket no-implementation wording. | Low; other legacy docs may still contain historical planning language. |
| C-2026-05-20-02 | fixed | Archive index was generic scaffold wording and did not clearly declare authority limits against current truth map. | Archive must be historical-only and explicitly subordinated to current source truth map. | `archive/00_ARCHIVE_INDEX.md` (pre-patch) | `control/01_CURRENT_SOURCE_TRUTH_MAP.md` and run contract | Current source truth map and control hierarchy | Added explicit historical authority warning and update rules. | Low. |
| C-2026-05-20-03 | fixed | Schema index missing mandatory upstream read chain and key-file/update hooks. | Governance schema indexes should route through current source truth map and define update ownership. | `governance/schemas/00_SCHEMA_INDEX.md` (pre-patch) | `control/01_CURRENT_SOURCE_TRUTH_MAP.md`, `control/02_MASTER_REPO_FILE_INDEX.md` | Control routing hierarchy | Added mandatory first read, key files section, and when-to-update rules. | Low. |
| C-2026-05-20-04 | fixed | Handoff stale-term scan list included `MT5 source implementation: HOLD` and `planning-only` as if active status candidates. | Current implementation state is limited-active source; those phrases are dead active terms and should remain only historical/negated contexts. | `docs/01_AURORA_CORE_HANDOFF_CONTINUITY_GUIDEBOOK.md` | `control/01_CURRENT_SOURCE_TRUTH_MAP.md` | Current source truth map | Removed stale scan lines from handoff seed section. | Low. |


## RUN_SCOPE = FULL_SYSTEM_FOLDER_SPINE_REPAIR
- Added during full system governance/blueprint/folder-spine deep repair run.
