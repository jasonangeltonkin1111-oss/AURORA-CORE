# Aurora Gateway Layer Manifest Contract

Status: draft active contract  
Scope: Gateway sidecar manifests for layer-agnostic lifecycle proof  
Owner: Existing Gateway EXE calculation-support lane + EA/MT5 publication owner boundary  
Applies to: current L6/L7/L8 and future L1-L23 sidecar-producing layers

## Purpose

Gateway layers must publish small, readable manifests that let the existing Gateway EXE and EA publication surfaces decide whether a layer is:

- ranked/output accepted
- ranked/output degraded
- input ready but ranked/output pending
- input degraded
- missing/unavailable

Lag is acceptable. Contradiction is not acceptable.

The Gateway EXE may observe and report layer lifecycle proof. It must not become the EA surface writer, trade permission owner, selection permission owner, broker truth owner, or FileIO route owner.

## Authority boundary

Every Gateway-side manifest must preserve these safety fields unless a later explicitly owned layer contract says otherwise:

```text
authority=calculation_support_only
trade_permission=false
selection_runtime=false
```

Gateway can calculate and publish sidecar evidence. EA/MT5 remains the owner of:

- Market Board publication
- Workbench publication
- Dossier publication
- broker truth
- trade permission
- selection permission
- execution permission

## Manifest roles

A layer manifest must identify its role using `manifest_role` when possible. If older manifests do not have this field, the overseer may infer role from filename.

Allowed initial roles:

```text
input_primitives
ranked_output
selection_output
execution_support
diagnostic
```

Current filename inference:

```text
ranked_symbols.manifest -> ranked_output
*_input_primitives.manifest -> input_primitives
input_primitives.manifest -> input_primitives
```

## Minimum common fields

All layer manifests should move toward this minimum contract:

```text
schema_name=<layer_specific_manifest_schema>
schema_version=<integer>
layer_id=<integer>
layer_name=<human readable layer name>
job_type=<stable job type id>
manifest_role=input_primitives|ranked_output|selection_output|execution_support|diagnostic
status=<complete|input_degraded|pending|degraded|not_available>
reason=<short bounded reason>
row_count=<integer>
input_count=<integer when available>
payload_checksum=<checksum or not_available>
input_payload_checksum=<checksum or not_available>
source_input_payload_checksum=<checksum or not_available>
input_generation_stable=true|false|not_available
authority=calculation_support_only
trade_permission=false
selection_runtime=false
ranking_runtime=true|false|not_available
generated_utc=<YYYY-MM-DD HH:MM:SS UTC>
generated_unix=<integer>
```

## Ranked output fields

Ranked/output layers should additionally publish:

```text
symbol_rank_files_written=<integer>
symbol_rank_files_actual=<integer>
symbol_rank_filename_mode=<mode name>
ranked_csv_path=<path or not_available>
ranked_manifest_path=<path or not_available>
```

A ranked output is accepted when:

```text
status in {complete,input_degraded}
authority=calculation_support_only
trade_permission=false
selection_runtime=false or not_available
row_count == input_count when input_count is available
symbol_rank_files_written == row_count when symbol files are claimed
symbol_rank_files_actual == row_count when symbol files are claimed
```

`input_degraded` means the layer is truthfully degraded but still has enough structured proof to publish. It does not automatically grant permission.

## Input primitive fields

Input-only layers should publish:

```text
manifest_role=input_primitives
row_count=<integer>
l5_gate_pass=<integer when applicable>
payload_checksum=<checksum>
authority=calculation_support_only
trade_permission=false
selection_runtime=false
ranking_runtime=false
```

Input-ready layers are not mismatches merely because ranked output is not available yet. Their lifecycle state is:

```text
input_ready_rank_pending
```

They become mismatches only if their own input manifest is internally broken, unsafe, or violates authority fields.

## Gateway overseer lifecycle states

The Gateway surface overseer may report:

```text
ranked_output_accepted
ranked_output_degraded
input_ready_rank_pending
input_degraded
missing_manifest
unreadable_manifest
```

Summary status policy:

```text
accepted                         -> all discovered ranked/output layers accepted and no pending layers
accepted_with_pending_layers     -> no mismatches, but one or more input-only layers are awaiting ranked output
mismatch_detected                -> one or more layer manifests are degraded, unreadable, authority-unsafe, or internally inconsistent
no_layers_found                  -> Outbox/Layers contains no layer directories
```

## Output discipline

Manifests must stay small and cheap to parse. Do not put large symbol tables in manifests. Large rows belong in CSV files or SymbolRanks files.

Reasons must be bounded and de-duplicated. Repeated daemon reuse must not grow strings indefinitely.

Recommended max reason policy:

```text
reason_max_parts=12
reason_max_chars=512
```

## Future layer guidance

For future L1-L23 layers:

1. First add an input manifest with `manifest_role=input_primitives`.
2. Then add ranked/output manifests when the output stage exists.
3. Never make pending input-only stages look broken.
4. Never use a layer manifest as trade permission or selection permission.
5. Add fields by extension; do not break the minimum contract.

## Test acceptance

After rebuild/install and daemon cycles, the current expected state with L6/L7 ranked and L8 input-only is:

```text
schema_name=aurora_gateway_surface_overseer_status
schema_version=2
status=accepted_with_pending_layers
accepted_layer_count=2
pending_layer_count=1
mismatch_count=0
Layer_8...manifest_role=input_primitives
Layer_8...lifecycle_state=input_ready_rank_pending
Layer_8...pending=true
Layer_8...mismatch=false
surface_write_authority=false
ea_publication_authority=true
authority=calculation_support_only
trade_permission=false
selection_runtime=false
```

Decision gate before promotion: TEST FIRST.
