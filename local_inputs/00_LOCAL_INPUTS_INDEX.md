# 00 LOCAL INPUTS INDEX

## Purpose
Index for local staging inputs used to prepare/manual-feed bounded data artifacts into Aurora workflows.

## What belongs here
- Local staging files supplied by operator for bounded import/review runs.
- Input manifests, sample snapshots, and temporary import support artifacts.

## What must not belong here
- Active MT5 source-of-truth files.
- Runtime-generated production outputs presented as proof by default.
- Trading permission, edge, or runtime-readiness claims.

## Authority and usage
- `local_inputs/` is staging/support only.
- Current source truth remains `README.md` + `control/01_CURRENT_SOURCE_TRUTH_MAP.md` + active MT5 source files.
- Files here require explicit validation and provenance checks before being treated as evidence.

## No-go rules
- Do not treat local staging files as implementation truth.
- Do not bypass owner boundaries using ad-hoc local inputs.
- Do not claim compile/runtime proof from local inputs alone.

## When to update this index
- When new local input conventions are added.
- When import-validation gates change.
