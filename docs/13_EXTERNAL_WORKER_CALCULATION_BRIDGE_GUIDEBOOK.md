# AURORA CORE — EXTERNAL WORKER & CALCULATION BRIDGE GUIDEBOOK

**System:** AURORA CORE  
**Role:** External calculation boundary, bridge protocol, worker health, snapshot validation, technology selection, and anti-shadow-brain law.  
**Status:** Overview guidebook foundation. No worker bridge is production-approved until implemented, tested, and validated.

---

## 0. Purpose

This guidebook defines whether and how AURORA CORE may use an external worker for heavy calculations.

It answers:

```text
What may leave MT5?
What must stay inside MT5?
How does MT5 request calculations?
How does the worker return results?
How does MT5 verify freshness/schema/hash?
What happens if worker is offline, stale, slow, or wrong?
Can worker output affect Board/Dossier?
Can worker output affect permission?
What bridge is allowed first?
```

Core law:

```text
External worker may calculate.
External worker may not become broker truth, publication owner, permission owner, or hidden execution brain.
```

---

## 1. What This Guidebook Owns

This guidebook owns:

```text
external worker decision state
Python vs C/C++ vs MQL5-only vs WebRequest vs socket vs file bridge
MT5 responsibility boundary
external worker responsibility boundary
bridge protocol
snapshot files
request/response IDs
schema validation
hash validation
worker heartbeat
worker manifest
stale output handling
offline worker handling
worker result degradation
automatic mode
security/deployment constraints
future optimization path
```

---

## 2. What This Guidebook Must Not Own

This guidebook must not own:

```text
broker truth
live account truth
order sending
trade permission
publication routes
final Board/Dossier writing
final source-of-truth labels without MT5 validation
MT5 Function Guidebook details
anti-drift authority hierarchy
```

External worker calculates.

MT5 validates and publishes.

Permission remains with Permission / Alert Owner.

---

## 3. Research Foundation

MetaQuotes provides official MetaTrader 5 Python integration. The official documentation describes Python functions for receiving terminal data and using it for statistical calculations and machine learning workflows.

Reference:

```text
https://www.mql5.com/en/docs/python_metatrader5
```

Aurora translation:

```text
Python is a strong first external worker candidate for heavy calculations, statistics, correlation, taxonomy, ranking transforms, and validation/outcome calculations.
```

MQL5 file operations are sandboxed and may use the terminal Files folder or shared common folder with `FILE_COMMON`.

Reference:

```text
https://www.mql5.com/en/docs/files/fileopen
```

Aurora translation:

```text
File snapshot bridge is inspectable, restartable, and compatible with Aurora's manifest/proof discipline.
```

MQL5 `WebRequest()` is synchronous, requires allowed URLs, and cannot run in Strategy Tester.

Reference:

```text
https://www.mql5.com/en/docs/network/webrequest
```

Aurora translation:

```text
WebRequest is HOLD for the main runtime calculation bridge.
```

MQL5 sockets are supported for EAs/scripts, with lifecycle and timeout complexity.

Reference:

```text
https://www.mql5.com/en/docs/network/socketcreate
```

Aurora translation:

```text
Sockets are CONSIDER later after file bridge proves insufficient.
```

---

## 4. External Worker Decision State

Current decision state:

```text
External calculation worker: PROCEED TO GUIDEBOOK DESIGN.
Python worker + file snapshot bridge: BEST FIRST CANDIDATE.
C/C++ worker: HOLD as later optimization.
WebRequest bridge for main runtime bridge: HOLD.
Sockets bridge: CONSIDER later after file bridge proves insufficient.
MT5-only heavy calculations: HOLD as fallback, not preferred long-term.
```

This is not implementation proof.

This is not runtime proof.

This is not permission to trade.

---

## 5. MT5 Authority Boundary

MT5 owns:

```text
broker truth
account truth
symbol universe truth
quote/session truth
selected raw source snapshots
publication surfaces
permission blocks
file route ownership
worker health monitoring
schema/freshness validation
operator display
```

MT5 must not blindly trust worker output.

MT5 validates worker outputs before use.

---

## 6. External Worker Allowed Responsibilities

External Worker may own:

```text
heavy calculations
ranking transforms if assigned
correlation matrices
bucket heat calculations
large taxonomy processing
selected evidence transforms
statistical summaries
validation/outcome calculations later
```

Worker output is candidate calculation truth until MT5 validates it.

---

## 7. External Worker Forbidden Responsibilities

External Worker must not own:

```text
broker truth
live account truth
order sending
trade permission
publication routes
final Board/Dossier writing
final source-of-truth labels without MT5 validation
```

External worker must not become a shadow brain.

---

## 8. Candidate Technology Comparison

### Python Worker

Status:

```text
BEST FIRST CANDIDATE
```

Strengths:

```text
statistics
dataframes
correlation
taxonomy transforms
batch ranking
validation/outcome calculations
research-to-production speed
```

Risks:

```text
Python environment dependency
version/package drift
worker health monitoring required
can become second broker-truth owner if not fenced
```

### C / C++ Worker

Status:

```text
HOLD as later optimization
```

Strengths:

```text
speed
determinism
compiled deployment
optimized kernels
```

Risks:

```text
harder debugging
higher development friction
premature optimization while formulas still move
```

### MQL5-only Heavy Calculations

Status:

```text
HOLD as fallback
```

Strengths:

```text
single runtime
simpler deployment
native terminal control
```

Risks:

```text
OnTimer pressure
harder bulk analytics
risk of heartbeat overload
```

### WebRequest Bridge

Status:

```text
HOLD for main runtime bridge
```

Reason:

```text
synchronous
blocks program execution while waiting
requires allowed URLs
not Strategy Tester compatible
```

### Socket Bridge

Status:

```text
CONSIDER later
```

Reason:

```text
potentially faster and bidirectional
but more complex lifecycle/protocol/failure handling
```

---

## 9. Python Worker + File Snapshot Bridge

Recommended first bridge:

```text
Python worker + file snapshot bridge
```

Reason:

```text
auditable
simple
restartable
fits 30-minute refresh
fits manifest/proof law
does not block OnTimer like WebRequest
easier than sockets
easier than C++ while formulas still evolve
```

---

## 10. Bridge Lifecycle

Lifecycle:

```text
1. MT5 completes broker/source truth collection.
2. MT5 writes input snapshot.
3. MT5 writes calculation request.
4. Worker detects request.
5. Worker reads input snapshot.
6. Worker calculates heavy transforms.
7. Worker writes result snapshot.
8. Worker writes worker manifest/status.
9. MT5 reads worker result.
10. MT5 validates request/cycle/schema/hash/freshness.
11. MT5 publishes Board/Dossier/Governance.
12. Permission remains blocked unless Permission Owner allows.
```

---

## 11. Conceptual Bridge Files

Conceptual bridge layout:

```text
bridge/
  in/
    aurora_input_snapshot.json
    selected_symbols_snapshot.json
    calculation_request.json

  out/
    calculation_result.json
    worker_status.json
    worker_manifest.json

  archive/
    requests/
    results/
```

This is conceptual only.

Final path belongs to future route/FileIO design.

---

## 12. Input Snapshot Contract

Input snapshot fields:

```text
request_id
cycle_id
generated_at
server
account
symbol_universe_hash
source_snapshot_hash
eligible_symbols
surface_inputs
bucket_inputs
selected_symbols
schema_version
```

Input snapshot is produced by MT5.

Worker may not alter it.

---

## 13. Calculation Request Contract

Calculation request fields:

```text
request_id
cycle_id
request_type
created_at
source_snapshot_path
source_snapshot_hash
requested_outputs
schema_version
priority
expiry_time
```

A stale request should expire.

Expired request results must not be used as fresh output.

---

## 14. Worker Result Contract

Worker result fields:

```text
request_id
cycle_id
worker_id
worker_version
started_at
finished_at
input_hash_seen
result_hash
schema_version
calculation_status
results
degraded_reasons
```

If `input_hash_seen` does not match the MT5 source snapshot hash:

```text
worker_result_status = rejected
```

---

## 15. Worker Status Contract

Worker status fields:

```text
worker_alive
worker_version
last_seen
last_request_id
last_completed_request_id
last_error
queue_depth
calculation_duration_ms
worker_pressure_state
```

Board must show stale/offline/failed worker state if worker outputs are needed.

---

## 16. Hash / Schema / Freshness Validation

MT5 must validate:

```text
request_id match
cycle_id match
schema_version
worker_version
input_hash_seen
result_hash
freshness
calculation_status
worker heartbeat
```

If validation fails:

```text
worker_result_status = rejected / stale / invalid / unavailable
publication_allowed = true
review_allowed = false if worker output is required
trade_allowed = false
```

---

## 17. Worker Failure States

Failure states:

```text
worker_disabled
worker_not_configured
worker_offline
worker_stale
worker_busy
request_pending
request_expired
result_missing
result_schema_mismatch
result_hash_mismatch
input_hash_mismatch
worker_version_mismatch
calculation_failed
calculation_partial
calculation_degraded
```

Worker failure must print.

Worker failure must not hide publication.

---

## 18. Automatic Mode Rules

All worker flow may be automatic only if it is:

```text
self-starting
self-monitoring
self-degrading
self-recovering
self-reporting
```

Automatic does not mean blind trust.

Automatic does not mean trading permission.

---

## 19. Board / Dossier / Governance Integration

Board may show:

```text
external_worker_enabled
external_worker_status
last_worker_seen
last_worker_request_id
last_worker_completed_request_id
worker_result_freshness
worker_calculation_duration_ms
worker_degraded_reason
```

Dossier may show worker-dependent calculation state where relevant.

Governance should record worker request/result proof.

---

## 20. Permission Safety Rules

Worker output may not grant permission.

If worker output is required and unavailable:

```text
review_allowed = false if required
trade_allowed = false
permission_block_reason = worker_output_unavailable / stale / invalid
```

Permission / Alert Owner remains authority.

---

## 21. Security / Deployment Constraints

External worker introduces deployment risk.

Track:

```text
python_version
package_versions
worker_version
worker_path
worker_start_method
allowed_bridge_path
worker_permissions
last_known_good_worker_version
```

Do not run unknown scripts without version/provenance control.

---

## 22. No-Go Patterns

Do not allow:

```text
MT5 blindly trusts worker output
worker writes final Board/Dossier
worker sends trades
worker decides permission
worker owns broker truth
worker output used without request_id/cycle_id check
worker stale result used as fresh
WebRequest blocks OnTimer for routine calculation
socket bridge introduced before file bridge contract exists
C++ worker built before Python/file bridge is falsified
```

---

## 23. Acceptance Criteria

This guidebook is acceptable if the worker boundary is safe and auditable.

Acceptance criteria:

```text
MT5 remains broker truth and publication owner.
External worker may calculate only from snapshots.
Worker output requires request_id/cycle_id/schema/hash/freshness validation.
Python + file bridge is best first candidate.
WebRequest main bridge is HOLD.
Sockets are CONSIDER later.
C/C++ is HOLD as optimization.
Worker failure prints degraded truth.
Worker failure cannot hide publication.
Worker cannot grant permission or trade.
```

---

## 24. Final External Worker Law

```text
The worker may be powerful.
It may not be sovereign.
```
