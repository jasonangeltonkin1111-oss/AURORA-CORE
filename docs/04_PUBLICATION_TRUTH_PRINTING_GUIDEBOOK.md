# AURORA CORE — PUBLICATION & TRUTH PRINTING GUIDEBOOK

**System:** AURORA CORE  
**Role:** Publication law, output surface routing, atomic-style write discipline, manifest proof, degraded publication, and no-disappearing-output authority.  
**Status:** Overview guidebook foundation. Implementation details may be refined when FileIO/source work begins.

---

## 0. Purpose

This guidebook defines how AURORA CORE physically prints truth.

It protects one of Aurora's highest laws:

```text
Broken truth may block review or trading.
Broken truth must not block printing.
```

The Publication Owner writes state.

It does not create hidden trading truth.

It does not recompute ranks, scores, evidence, or permission.

It prints the truth produced by the rightful Runtime Owners.

---

## 1. What This Guidebook Owns

This guidebook owns:

```text
publication law
publication surfaces
final route ownership
Board publication
Dossier publication
Selection Desk publication
Governance publication
Manifest proof
Atomic Update Overview publication
atomic-style write pattern
temp-to-final contract
degraded publication rules
physical publication blockers
invalid publication blockers
file verification rules
publication failure states
publication recovery rules
publication telemetry fields
```

---

## 2. What This Guidebook Must Not Own

This guidebook must not own:

```text
account truth
surface scoring
bucket classification
Global Top 10 computation
selected evidence computation
permission decisions
edge validation
formula definitions
Board layout details
Dossier layout details
Governance schema details
```

Publication displays and records owner truth.

Publication does not secretly compute owner truth.

---

## 3. Official MQL5 File I/O Constraints

AURORA CORE is native MT5 / MQL5, so file publication must respect MQL5 behavior.

### File sandbox

MQL5 file operations are sandboxed.

Files are usually located under the terminal's `MQL5\Files` directory, or under the shared common folder when `FILE_COMMON` is used.

Official reference:

```text
https://www.mql5.com/en/docs/files/fileopen
```

Aurora implication:

```text
Publication routes must be explicit and owned.
No module may invent absolute output paths.
No scattered FileOpen/FileWrite outside the publication/FileIO owner.
```

### FileFlush discipline

`FileFlush()` writes buffered data to disk, but frequent use can reduce program speed. Data is also forced to disk when a file is closed.

Official reference:

```text
https://www.mql5.com/en/docs/files/fileflush
```

Aurora implication:

```text
Build content in memory.
Write temp file.
Flush/close at a controlled boundary.
Do not FileFlush spam inside loops.
```

### FileMove temp-to-final

`FileMove()` moves or renames files. If the destination exists, `FILE_REWRITE` is required or the move can fail.

Official reference:

```text
https://www.mql5.com/en/docs/files/filemove
```

Aurora implication:

```text
Use temp-to-final publication:
content buffer → temp file → flush/close → move temp to final with rewrite → verify final.
```

### FileIsExist verification

`FileIsExist()` checks whether a file exists. Existence alone does not prove file correctness.

Official reference:

```text
https://www.mql5.com/en/docs/files/fileisexist
```

Aurora implication:

```text
File exists does not equal file is correct.
Verify existence, size, timestamp, route, status, and manifest entry.
```

---

## 4. Publication Law

The primary law:

```text
Broken truth may block review or trading.
Broken truth must not block printing.
```

Publication must continue when truth is:

```text
partial
stale
unknown
degraded
incomplete
mismatched
not review-safe
not trade-safe
waiting on dependency
```

Publication may be physically blocked only when writing is actually impossible.

---

## 5. Publication vs Review vs Trading Permission

These are separate lanes:

```text
publication_allowed ≠ review_allowed
publication_allowed ≠ trade_allowed
```

Correct example:

```text
file_publication_allowed = true
review_allowed = false
trade_allowed = false
reason = stale_quote / partial_evidence / missing_spec / dependency_wait
```

Wrong example:

```text
file not printed because quote is stale
```

Stale truth should print as stale.

Partial truth should print as partial.

Unavailable truth should print as unavailable.

---

## 6. Publication Surfaces

AURORA CORE has these publication surfaces:

```text
Board
Dossier
Selection Desk
Governance
Manifest
Atomic Update Overview
```

Surface roles:

```text
Publication prints.
Board summarizes.
Dossier explains per symbol.
Governance proves.
Manifest records publication proof.
Runtime Owners own truth.
```

No surface may secretly become another surface.

---

## 7. Route Ownership

Only the Publication Owner may own final output routes.

Runtime Owners may produce state.

They may not invent final publication paths.

Forbidden:

```text
Foundation Owner writes its own final Board file.
Selected Evidence Owner writes final Dossier files directly.
Basket Selection Owner creates a new Selection Desk path.
Any helper opens final publication files outside Publication Owner/FileIO owner.
```

Allowed:

```text
Runtime Owners expose state.
Publication Owner reads state.
Publication Owner writes final surfaces.
Manifest records proof.
```

---

## 8. Atomic-Style Write Pattern

The standard publication pattern:

```text
1. Build full content in memory.
2. Open temp file for writing.
3. Write content to temp file.
4. Flush/close once at controlled boundary.
5. Move temp file to final file with rewrite.
6. Verify final file exists.
7. Verify final file size > 0 where applicable.
8. Write manifest entry.
9. Publish status to Atomic Update Overview.
```

Do not write directly to final output line-by-line during long computation.

Do not flush repeatedly inside symbol loops.

Do not leave half-built final files as if complete.

---

## 9. Temp-to-Final Contract

Each publication must know:

```text
surface
final_path
temp_path
route_owner
source_owner_snapshot
write_started_at
write_finished_at
bytes_written
move_status
verify_status
manifest_status
```

If temp write succeeds but final move fails:

```text
publication_status = move_failed
file_publication_blocked = true
review_allowed = false
trade_allowed = false
```

If truth is degraded but final file writes successfully:

```text
publication_status = written_degraded
file_publication_blocked = false
review_allowed = depends_on_truth_state
trade_allowed = false if needed
```

---

## 10. Manifest Proof

Every meaningful publication should produce proof.

Minimum manifest fields:

```text
file_id
surface
route
final_path
temp_path
write_started_at
write_finished_at
bytes_written
final_exists
final_size
write_status
degraded_state
source_owner_versions
cycle_id
heartbeat_id
publication_owner_status
```

Manifest proof must distinguish:

```text
file_written_clean
file_written_degraded
file_written_partial
physical_write_failed
verify_failed
route_missing
```

---

## 11. Board Publication Contract

Board is system-level cockpit output.

Publication Owner must print Board even if some sections are degraded.

Board may show:

```text
runtime health
Atomic Update Overview
account/risk summary
foundation summary
bucket summary
Global Top 10
selected evidence progress
heatmap status
publication status
permission/alert state
warnings/action needed
```

Board must not become:

```text
raw OHLC dump
raw tick dump
full Dossier
full governance ledger
strategy proof file
```

If Board is partial:

```text
board_status = partial or complete_with_degraded
missing_sections listed
review/trading state separate
```

---

## 12. Dossier Publication Contract

Dossier is per-symbol truth output.

Every symbol may have a useful Dossier shell.

Selected symbols may have deeper evidence sections.

Non-selected symbols must not appear blank.

Correct non-selected state:

```text
deep_evidence_status = not_selected_this_cycle
reason = not_global_top10 / not_bucket_leader / not_backup / not_manual_watch
```

Dossier publication must not wait for deep evidence unless the physical route cannot be written.

---

## 13. Selection Desk Publication Contract

Selection Desk shows selection truth.

It may display:

```text
Bucket Top 5
Sub-Bucket Top 5
Candidate Pool
Global Top 10
Correlation Rejects
Backup Fill
Selected Deep Evidence Batch
```

It must not recompute:

```text
bucket ranks
Global Top 10
correlation rejects
permission state
```

Selection Desk consumes owner truth and prints it.

---

## 14. Governance Publication Contract

Governance files prove what happened.

Governance may include:

```text
manifest
runtime telemetry
layer status
score registry
formula registry
selection ledger
evidence integrity
alert ledger
prop rule profile
outcome ledger
heatmap registry
order-flow availability
contradiction ledger
```

Governance must not become the primary human cockpit.

Governance proves.

Board summarizes.

Dossier explains per symbol.

---

## 15. Atomic Update Overview Publication Contract

Atomic Update Overview is the live publication state summary.

It must expose:

```text
current owner
current lane
current layer
cycle state
last successful publication
oldest starved task
deep evidence progress
recovery queue size
next scheduled owner
pressure state
breath phase
publication status
```

It should update even when deep evidence is incomplete.

It exists to prevent fake-alive runtime.

---

## 16. Degraded Publication Rules

Truth degradation must be visible.

Common degraded states:

```text
partial
stale
unknown
missing_dependency
waiting_on_owner
unavailable
failed_soft
failed_hard
complete_with_degraded
```

Correct pattern:

```text
Dossier printed.
Status = partial.
Reason = waiting_on_layer_18_ohlc.
Review allowed = false.
Trading allowed = false.
Publication blocked = false.
```

Wrong pattern:

```text
Dossier missing because OHLC incomplete.
```

---

## 17. Physical Publication Blockers

Valid physical blockers:

```text
route_missing
folder_create_failed
temp_file_open_failed
temp_write_failed
flush_or_close_failed
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

## 18. Invalid Publication Blockers

Invalid publication blockers:

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
```

These may block review/trading.

They must not block physical file printing.

---

## 19. File Verification Rules

Minimum verification:

```text
final_exists
final_size
write_status
manifest_entry_exists
write_timestamp_current
surface_status_recorded
```

File exists is not enough.

File size is not enough.

Manifest without file is not enough.

All must align.

---

## 20. Publication Failure States

Publication failure states:

```text
not_attempted
route_missing
temp_open_failed
temp_write_failed
flush_failed
close_failed
move_failed
verify_failed
manifest_failed
written_clean
written_partial
written_degraded
stale_publication
```

Publication must never silently fail.

---

## 21. Recovery Rules

Recovery Lane handles:

```text
failed temp cleanup
retry physical write failure
route repair if safe
manifest repair
stale publication marking
partial write status exposure
```

Recovery must not:

```text
hide previous failure
reset counters to fake clean state
retry endlessly without budget
block all other publication
```

---

## 22. Telemetry Fields

Publication telemetry fields:

```text
last_board_write_time
last_dossier_write_time
last_selection_desk_write_time
last_governance_write_time
manifest_write_status
file_write_fail_count
publication_age_seconds
publication_owner_status
surface_write_count
surface_write_failed_count
surface_written_degraded_count
file_publication_blocked_count
```

These fields should feed Board and governance.

---

## 23. No-Go Patterns

Do not allow:

```text
scattered FileOpen/FileWrite
runtime owners inventing output paths
Board recomputing truth
Dossier recomputing truth
Selection Desk recomputing truth
files disappearing because truth is dirty
publication blocked by review/trading block
FileFlush spam inside loops
half-written final files
manifest saying success when final file failed
```

---

## 24. Acceptance Criteria

This guidebook is acceptable if it protects publication truth.

Acceptance criteria:

```text
Defines all publication surfaces.
Defines final route ownership.
Defines temp-to-final write pattern.
Defines manifest proof fields.
Separates publication_allowed from review_allowed and trade_allowed.
Defines valid physical blockers.
Defines invalid blockers.
Prevents disappearing files.
Prevents scattered FileOpen/FileWrite.
Does not compute ranks, scores, evidence, or permission itself.
```

---

## 25. Final Publication Law

```text
Publication prints.
Board summarizes.
Dossier explains per symbol.
Governance proves.
Manifest records.
Runtime Owners own truth.
Broken truth must print as broken truth.
```
