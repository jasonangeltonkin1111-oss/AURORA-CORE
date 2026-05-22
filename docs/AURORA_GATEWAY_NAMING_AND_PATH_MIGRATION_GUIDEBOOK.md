# AURORA GATEWAY NAMING AND PATH MIGRATION GUIDEBOOK

Runtime 3 is the Calculation Gateway.

The old name "External Worker" is retired for operator-facing language, but old file names, function names, and physical folders are still legacy compatibility until a separate migration is proven.

## Current accepted language

Use:

```text
Gateway
Calculation Gateway
Runtime 3 - Calculation Gateway Owner
```

Avoid in new operator-facing surfaces:

```text
External Worker
External Calculation Worker
```

## Critical compatibility rule

Do not blindly rename these yet:

```text
AC_ExternalWorker*
external_worker/
AuroraWorker.exe
Aurora Core\External Worker\
Aurora Core\<SERVER>\<ACCOUNT>\Workbench\External Worker\
```

Those names may still be bound to:

```text
MQL include paths
scheduled task actions
packaged EXE install paths
shared worker status readers
per-account inbox/outbox/status files
existing runtime proof files
```

A blind rename can break a working daemon and create another popup/runtime failure.

## Current safe state

The repository now treats Gateway as the display name and Runtime 3 owner concept.

Physical paths remain:

```text
Shared legacy path:
Aurora Core\External Worker\

Per-account legacy path:
Aurora Core\<SERVER>\<ACCOUNT>\Workbench\External Worker\
```

This is intentional for live-output proof.

## Future target paths

The eventual target is:

```text
Shared Gateway path:
Aurora Core\Gateway\

Per-account Gateway path:
Aurora Core\<SERVER>\<ACCOUNT>\Workbench\Gateway\
```

## Required migration order

1. Keep legacy paths working.
2. Add Gateway paths as primary targets with legacy fallback reads.
3. Update installer to write Gateway shared install/status files.
4. Update scheduled tasks to packaged Gateway EXE path only after the packaged folder exists.
5. Update MQL path owner to read Gateway first, then legacy External Worker fallback.
6. Prove one daemon, no popup, fresh shared status, fresh heartbeat, accepted result, and no duplicate worker process.
7. Only after proof, deprecate legacy External Worker paths.

## Forbidden migration patterns

Do not:

```text
rename folders without fallback
rename AC_ExternalWorker* symbols in one broad rewrite
change scheduled task path without installed EXE proof
remove legacy status readers before Gateway status exists
create a second Gateway owner
create duplicate FileIO/path/timer owners
let Gateway own trading permission
let Gateway own Layer 5 gate truth
```

## Runtime authority boundary

Gateway is support only:

```text
authority=calculation_support_only
trade_permission=false
ranking_runtime=false unless a later approved layer explicitly owns ranking
selection_runtime=false unless a later approved layer explicitly owns selection
```

Layer 5 does not require Gateway.

```text
Layer 5 = Basic System Gate
Gateway Required = false
Calculation Owner = none_basic_gate_only
```

Layer 6+ may later consume Gateway calculation support if explicitly designed and proved.

## Live-output proof requirements

For this surface rename pass, proof should show:

```text
build_version=1.046
upgrade_id=RUNTIME1_L5_GATEWAY_SURFACE_ALIGNMENT
Layer 5 - Basic System Gate
Runtime 3 - Calculation Gateway Owner
gateway_owner=Runtime 3 - Calculation Gateway Owner
gateway_status=...
gateway_required_write=...
gateway_authority=calculation_support_only
gateway_core_blocking=false
layer5_gateway_required=false
layer5_calculation_owner=none_basic_gate_only
```

It is acceptable if legacy physical paths still contain:

```text
External Worker
AC_ExternalWorker*
shared_worker_status.txt
worker_required.txt
```

Those are compatibility names, not current operator-facing architecture.
