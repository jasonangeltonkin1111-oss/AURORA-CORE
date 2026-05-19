# AURORA CORE — FILEIO / ROUTE OWNERSHIP CONTRACT

**System:** AURORA CORE  
**Role:** FileIO authority, route ownership, atomic-style publication pattern, physical-publication blockers, generated-output proof, and anti-shadow-path contract.  
**Status:** FOUNDATION CONTRACT — required before MT5 source implementation starts.

---

## 0. Purpose

This contract defines who owns file writing, route creation, temp-to-final publication, generated-output verification, and publication failure states in AURORA CORE.

It exists because FileIO mistakes can make Aurora look alive while publishing nothing, or make broken truth disappear instead of printing honestly.

Core law:

```text
Publication Owner owns final output routes and physical file publication.
Runtime Owners produce truth.
Publication Owner prints truth.
No other owner writes final output files directly.
```

---

## 1. Research Foundation

MQL5 file operations are sandboxed. `FileOpen()` works inside the terminal file sandbox, with `FILE_COMMON` available for the shared terminal common folder.

Reference:

```text
https://www.mql5.com/en/docs/files/fileopen
```

`FileMove()` moves or renames a file. If the target file already exists, the `FILE_REWRITE` flag is required or the move can fail.

Reference:

```text
https://www.mql5.com/en/docs/files/filemove
```

`FileFlush()` forces buffered data to disk, but excessive flushing can reduce performance. This means Aurora should flush only at controlled publication boundaries, not inside symbol loops.

Reference:

```text
https://www.mql5.com/en/docs/files/fileflush
```

`FileIsExist()` and `FileSize()` can support verification, but existence alone is not proof of correctness.

References:

```text
https://www.mql5.com/en/docs/files/fileisexist
https://www.mql5.com/en/docs/files/filesize
```

Aurora translation:

```text
Use memory buffer → temp file → controlled flush/close → move temp to final → verify final → record manifest.
```

---

## 2. What This Contract Owns

This contract owns:

```text
FileIO owner boundary
final route ownership
temp-to-final publication pattern
folder creation policy
physical publication blockers
invalid publication blockers
manifest proof requirements
file verification requirements
route drift rules
external worker bridge path boundary later
Layer 1 publication route readiness
```

---

## 3. What This Contract Must Not Own

This contract must not own:

```text
account truth
symbol truth
score truth
bucket truth
selection truth
permission truth
edge validation
final strategy outputs
external worker calculation truth
```

FileIO prints and proves physical output.

It does not compute owner truth.

---

## 4. Owner Boundary

Publication Owner owns:

```text
final output routes
FileOpen/FileWrite/FileFlush/FileClose/FileMove/FileIsExist/FileSize usage for final publication
manifest publication proof
atomic update overview proof
publication failure state
```

Runtime Owners may produce:

```text
in-memory state
owner snapshots
section strings
status fields
source data structures
```

Runtime Owners must not:

```text
open final Board files directly
open final Dossier files directly
invent final output folders
write manifest rows directly outside Publication Owner contract
```

---

## 5. Approved Publication Pattern

Standard pattern:

```text
1. Build full output content in memory.
2. Request route from the approved route owner.
3. Ensure folder exists or report route/folder failure.
4. Write full content to temp file.
5. Flush/close at controlled boundary.
6. Move temp file to final file with rewrite where required.
7. Verify final exists.
8. Verify final size/metadata where applicable.
9. Record manifest row.
10. Publish degraded/failed state to Board/Governance where applicable.
```

Forbidden pattern:

```text
write directly to final output line by line during long computation
flush repeatedly inside symbol loops
let multiple owners open the same final output file
skip final verification
manifest success when final file failed
```

---

## 6. Route Status Values

Route status values:

```text
route_not_defined
route_defined
folder_missing
folder_created
folder_create_failed
temp_path_ready
final_path_ready
route_invalid
route_blocked
```

Route failure must be visible.

Route failure is a physical publication problem.

---

## 7. Physical Publication Blockers

Valid physical blockers:

```text
route_missing
folder_create_failed
temp_file_open_failed
temp_write_failed
flush_failed
close_failed
move_to_final_failed
final_verify_failed
permission_denied
invalid_file_handle
```

Only these kinds of failures may set:

```text
file_publication_blocked = true
```

---

## 8. Invalid Publication Blockers

These may block review/trading, but must not physically block publication:

```text
quote_stale
OHLC_partial
indicator_not_ready
DOM_unavailable
score_degraded
not_review_safe
not_trade_safe
setup_unvalidated
permission_blocked
classification_unknown
worker_output_stale
```

Correct behavior:

```text
file prints
status = degraded / partial / stale / unavailable
review_allowed = false if required
trade_allowed = false
file_publication_blocked = false
```

---

## 9. Minimum Route Families

Route families later:

```text
Board
Dossier
Governance
Manifest
Atomic Update Overview
Selection Desk later
External Worker bridge snapshots later
```

Layer 1 minimum publication may include only:

```text
Board/account status shell
Governance manifest row
Runtime telemetry row
Owner status row
Layer status row
```

Do not create every final surface in the first source slice.

---

## 10. File Verification Contract

Minimum verification:

```text
final_exists
final_size
write_status
manifest_entry_exists
write_timestamp_current
surface_status_recorded
```

Existence alone is not enough.

Size alone is not enough.

Manifest alone is not enough.

They must align.

---

## 11. Manifest Fields Required From Publication

Minimum manifest fields:

```text
file_id
surface
route_key
final_path
temp_path
write_started_at
write_finished_at
bytes_written
final_exists
final_size
write_status
degraded_state
source_owner
source_cycle_id
source_heartbeat_id
publication_owner_status
```

Manifest proves publication attempt and result.

Manifest does not prove trading edge.

---

## 12. External Worker Bridge Route Boundary Later

External worker bridge paths are not final output routes.

They are snapshot-exchange routes.

They still require route ownership and validation.

Worker may not write:

```text
final Board
final Dossier
final Governance truth
permission files
```

Worker may later write only approved bridge outputs such as:

```text
worker_status
calculation_result
worker_manifest
```

MT5 must validate request/cycle/schema/hash/freshness before use.

---

## 13. Layer 1 FileIO Gate

Before Layer 1 source begins, the implementation plan must define:

```text
route keys used by Layer 1
which outputs are mandatory
which outputs are optional
what temp file pattern is used
what manifest row is written
what runtime telemetry row is written
what happens if file publication fails
```

Layer 1 must not create final routes beyond its approved scope.

---

## 14. Anti-Drift Rules

Forbidden:

```text
scattered FileOpen/FileWrite outside FileIO owner
helper creates new route root
runtime owner writes final output file
external worker writes final Board/Dossier
old route restored from archive without approval
new path created because it is convenient
```

If route contradiction is found:

```text
HOLD / TEST FIRST
```

---

## 15. Acceptance Criteria

This contract is acceptable if:

```text
Publication Owner owns final output routes.
Runtime Owners cannot write final files directly.
Temp-to-final pattern is defined.
Physical blockers are defined.
Invalid publication blockers are defined.
Minimum manifest fields are defined.
Layer 1 FileIO gate is defined.
External worker route boundary is defined.
No shadow paths are allowed.
```

---

## 16. Final FileIO Law

```text
Do not hide broken truth by making files disappear.
Print truth, verify the print, record the proof.
```