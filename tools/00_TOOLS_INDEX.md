# 00 TOOLS INDEX

## Purpose
Index for utility/support tooling used to assist governance, auditing, and bounded preparation workflows.

## What belongs here
- Utility scripts/check helpers for documentation/index audits or bounded preprocessing.
- Tooling notes that support but do not redefine runtime/source ownership.

## What must not belong here
- MT5 runtime owner logic authority.
- Trade/edge/permission claims.
- Replacement of control/docs source-truth hierarchy.

## Authority and usage
- `tools/` is utility support only.
- Tool outputs must be validated against current source truth before claims are upgraded.

## No-go rules
- Do not treat tool output alone as runtime proof.
- Do not introduce shadow owners via tooling.
- Do not bypass mandatory first-read and source inspection flow.

## When to update this index
- When new tooling entry points are added.
- When tool usage boundaries or validation gates change.
