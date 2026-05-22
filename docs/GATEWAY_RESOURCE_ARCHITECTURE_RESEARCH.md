# Gateway Resource Architecture Research Guide

Status: research and guardrail document only. This file does not change runtime behavior.

## Purpose

The Gateway must remain a single background support runtime that can serve many MetaTrader terminals, many accounts, and future layers without creating popup windows, duplicate runtime owners, runaway CPU, memory bloat, or OnTimer starvation.

The EA remains the MT5 runtime truth owner. Gateway is calculation support only unless a later approved owner contract explicitly changes that. Gateway must never own trade permission, selection permission, FileIO routes, MT5 broker truth, or hidden execution authority.

## Source-truth constraints

1. MT5 OnTimer cannot be treated like a queue. Official MQL5 behavior says each MQL5 program has one timer and if a Timer event is already queued or being processed, a new Timer event is not added. Therefore heavy work must leave MT5 and MT5 must only publish bounded snapshots and read bounded proof files.
2. MT5 file exchange must stay under the terminal/common file sandbox. Common file paths are the correct bridge for multi-terminal local Gateway work.
3. PyInstaller one-folder Gateway packaging is preferred over loose Python for runtime proof. The packaged worker must remain windowless/background.
4. Python ThreadPoolExecutor is useful for I/O overlap, but CPU-bound Python work should not rely on threads for parallel CPU scaling. Process pools, vectorized computation, or chunked single-process calculation are safer when calculation becomes heavy.
5. Shared memory and memory-mapped files are future tools for large numeric arrays, but they add lifecycle cleanup risk. Do not use them until CSV/file proof becomes the bottleneck and a small proof harness shows lower CPU/memory/IO cost.

## Current safe operating model

- One global Gateway daemon process per Windows user profile.
- One shared root: Aurora Core/Gateway.
- Many account roots discovered under Aurora Core/<SERVER>/<ACCOUNT>/Workbench/Gateway.
- MT5 writes account-local Control/Inbox files.
- Gateway writes account-local Status/Outbox files.
- Gateway writes shared status under Aurora Core/Gateway/Status.
- Scheduled task starts packaged AuroraWorker.exe in the background.
- Foreground fallback is forbidden.
- GUI, console, splash, browser, tray UI, and popup alerts are forbidden.

## Future layer load classes

### Light serial layers

Examples: Layer 6 cost/friction, Layer 7 session labels, Layer 10 taxonomy lookup when cached.

Recommended execution:

- Single process.
- Chunked per-account processing.
- Reuse parsed snapshots where possible.
- Write compact manifests and sidecars.
- Avoid per-symbol heavy logs.

### Medium vector layers

Examples: Layer 8 movement/range, Layer 9 geometry, Layer 11 group rankings, Layer 12 heat scores.

Recommended execution:

- Batch symbols into arrays.
- Parse CSV once into compact in-memory records.
- Compute many simple metrics in one pass per timeframe/session.
- Consider NumPy only after packaging proof confirms no bloat/regression.
- Cap per-cycle work by time budget and continue next cycle instead of blocking.

### Heavy selected-symbol layers

Examples: Layer 18 OHLC pack, Layer 19 candle geometry, Layer 20 rolling tick pack, Layer 21 references, Layer 22 liquidity/DOM proxy.

Recommended execution:

- Only selected candidates, never full universe by default.
- Request small explicit windows from MT5.
- Separate raw pack publication from derived calculation.
- Keep MT5 owner responsible for broker/timeframe data source truth.
- Gateway may compute derived evidence but must not invent missing market data.

### Selection and permission layers

Examples: Layer 15 diversity, Layer 16 Top 10 attention basket, Layer 23 permission/alert state.

Recommended execution:

- Must stay fail-closed.
- No permission can be granted from Gateway health alone.
- Permission owner must consume proof manifests, not raw enthusiasm.
- Output must distinguish attention candidate from trade permission.

## Resource scheduler design

The Gateway should evolve from a single loop into a cooperative scheduler, not a multi-daemon swarm.

Recommended task record fields:

- account_key
- terminal_root
- layer_id
- job_type
- input_path
- input_manifest_path
- output_contract
- due_unix
- priority
- estimated_cost_class: light, medium, heavy
- max_runtime_ms
- max_memory_mb
- stale_after_seconds
- source_snapshot_id
- source_payload_checksum
- authority=calculation_support_only
- trade_permission=false

Recommended queues:

1. Health lane: shared status, account process status, repair proof. Tiny and always first.
2. Freshness lane: detect changed input manifests and skip unchanged jobs.
3. Light lane: L6/L7/L10 quick jobs.
4. Medium lane: L8/L9/L11/L12 vector jobs with chunk budgets.
5. Heavy selected lane: L18-L22 selected-symbol evidence only.
6. Permission lane: future proof-only lane, fail-closed by default.

## CPU rules

- Do not spawn one process per terminal or one process per layer.
- Do not launch a worker per EA.
- Keep one daemon and one scheduler.
- Default worker concurrency should be conservative: max(1, min(physical/2, configured_limit)).
- CPU-heavy Python loops should be chunked or moved to vectorized code before increasing concurrency.
- Thread pools are for file IO overlap and small waits, not CPU-heavy pure Python scoring.
- Process pools require strict task size, chunking, timeout, and cancellation rules.
- Never allow nested futures waiting on futures; that deadlocks easily.
- Avoid per-symbol process submits; submit chunks.

## Memory rules

- Avoid loading every layer, every symbol, every timeframe, and every account into memory at once.
- Store account snapshots as immutable cycle objects.
- Reuse parsed data across adjacent layers within the same cycle.
- Drop raw text once parsed if not needed.
- Prefer compact rows/tuples over large nested dictionaries for high-volume future layers.
- Maintain bounded caches keyed by server/account/snapshot_id/schema_version.
- Cache taxonomy and static symbol specs more aggressively than tick/quote data.
- Keep selected-symbol raw evidence windows separate from full-universe ranking state.
- No shared memory until a measured bottleneck exists and cleanup proof is implemented.

## IO rules

- MT5 publishes small contracts and snapshots.
- Gateway writes temp, flush, close, replace, then manifest proof.
- Do not rewrite full outputs if input manifest checksum is unchanged.
- Manifest-first reading is mandatory; large CSV parse should be skipped if manifest says unchanged.
- Board/Dossier should read compact manifests and selected symbol sidecars, not full ranked CSV every timer.
- Keep archive/report generation out of the hot loop.

## Multi-terminal rules

- Account scope must include server/account path.
- Multiple terminals may share one Gateway, but account roots must remain isolated.
- No global mutable state may mix accounts unless explicitly keyed by account_key.
- Shared status may summarize accounts, but account-local outputs remain authoritative for account-local MT5 reads.
- If two terminals use the same account/server, conflict must be reported as duplicate source publishers rather than silently merged.

## Future upgrade sequence

### Stage A: no behavior change instrumentation

- Add per-job duration and input unchanged/changed counters.
- Add peak account roots processed per loop.
- Add per-layer skipped_by_checksum counters.
- Add memory/cpu approximate status already available in shared status.

### Stage B: manifest-delta scheduling

- Gateway skips a layer when input manifest path/checksum/schema/snapshot_id is unchanged.
- Gateway still refreshes heartbeat/status.
- This is the safest first speed upgrade.

### Stage C: cooperative work budget

- Add loop budget in milliseconds.
- Finish health lane every loop.
- Process as many due jobs as budget allows.
- Carry pending jobs to the next loop.

### Stage D: chunked medium jobs

- L8/L9/L11/L12 use chunked symbol batches.
- Each chunk writes partial progress truth but final manifest only when complete.

### Stage E: selected-symbol heavy packs

- L18-L22 operate only on selected candidates from Layer 17.
- No full-universe heavy OHLC/tick/indicator pull.

### Stage F: optional process pool

Only after measurements prove need:

- Use bounded ProcessPoolExecutor for CPU-heavy chunks.
- No nested futures.
- Fixed max_workers from config.
- Timeout and cancellation.
- Chunk size tuned for thousands of rows, not per-symbol microtasks.

### Stage G: optional memory-mapped/shared memory arrays

Only after file parse/copy is proven bottleneck:

- Use memory mapped read-only arrays or SharedMemoryManager.
- Must have cleanup proof.
- Must not replace file manifests as authority.

## Forbidden changes

- No GUI.
- No popup alerts.
- No foreground fallback.
- No one Gateway process per EA.
- No one Gateway process per layer.
- No direct broker connection from Gateway.
- No hidden trade permission.
- No permission state from ranking layers.
- No large full-universe OHLC/tick packs before selection.
- No full CSV parse by MT5 board/dossier loops.
- No unbounded thread/process pools.
- No shared memory without cleanup proof.
- No duplicate FileIO or route owners.

## Acceptance proof for future resource upgrades

A resource upgrade is not accepted until runtime proof shows:

- No visible windows/popups.
- Single Gateway daemon process unless explicitly configured otherwise.
- Multiple accounts discovered and processed without path mixing.
- Shared status fresh.
- Account lifecycle status fresh.
- Result/job/snapshot envelope accepted.
- No OnTimer budget regression.
- CPU/memory counters stay under configured limits during at least 3 cycles.
- Unchanged inputs are skipped by checksum.
- Changed inputs are recalculated and published atomically.
- Trade permission remains false unless future Runtime 8 explicitly owns and proves permission.

## Decision gate

Current safest next implementation is Stage B: manifest-delta scheduling. It reduces CPU and IO without changing layer math or runtime ownership. Do not implement process pools or shared memory first. Those are later optimizations after measurement.
