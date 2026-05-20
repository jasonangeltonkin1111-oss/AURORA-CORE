# AURORA CORE — MT5 SOURCE FOLDER CONTRACT

**System:** AURORA CORE  
**Role:** MT5 source folder authority, Runtime Owner folder law, proper naming contract, Runtime 0 internal-control owner, layer-folder structure, and first-source layout gate.  
**Status:** SOURCE FOLDER CONTRACT — required before MT5 source implementation starts.

---

## 0. Purpose

This contract defines how AURORA CORE MT5 source files must be organized.

It converts the architecture rule:

```text
Runtime Owners are top-level architecture headers.
Logical layers live under Runtime Owners.
```

into a real source folder contract.

Core law:

```text
Every major Runtime Owner gets its own EA source folder.
Every Runtime Owner folder contains its own layer folders.
Every layer folder uses the layer number and full semantic layer name.
No layer may be referenced by number only.
```

---

## 1. Why This Contract Exists

Without this contract, the EA source can drift into:

```text
flat helper pile
random include folder
23-engine fragmentation
shadow owners
unclear FileIO ownership
unclear governance ownership
copy-pasted Seed/Sentinel bloat
```

The source tree must be readable by a person who does not already know Aurora.

Correct:

```text
layer_1_account_portfolio_prop_rule_truth
```

Wrong:

```text
layer1
l1
account
misc
helpers
```

---

## 2. What This Contract Owns

This contract owns:

```text
MT5 source folder naming law
Runtime Owner folder map
Runtime 0 internal-control owner definition
layer folder naming law
first-source folder set
no-empty-folder-spam rule
Seed/Sentinel inheritance boundary
source file creation boundary
```

---

## 3. What This Contract Must Not Own

This contract must not own:

```text
full MQL5 implementation code
formula logic
strategy logic
trading permission
runtime proof claims
compile proof claims
external worker implementation
complete future folder population
```

This file defines where code belongs.

It does not prove code exists.

---

## 4. Runtime Owner Source Folder Map

The MT5 source owner folders are:

```text
mt5/runtime_owners/runtime_0_governance_internal_control/
mt5/runtime_owners/runtime_1_foundation_truth_owner/
mt5/runtime_owners/runtime_2_surface_scoring_owner/
mt5/runtime_owners/runtime_3_bucket_intelligence_owner/
mt5/runtime_owners/runtime_4_basket_selection_owner/
mt5/runtime_owners/runtime_5_selected_evidence_owner/
mt5/runtime_owners/runtime_6_permission_alert_owner/
mt5/runtime_owners/runtime_7_publication_owner/
mt5/runtime_owners/runtime_8_validation_outcome_owner/
```

Runtime Owner folder names must include:

```text
runtime number
proper owner name
owner purpose words
```

---

## 5. Runtime 0 — Governance / Internal Control Owner

Runtime 0 is the internal EA spine.

It owns internal governance and control mechanisms needed by all Runtime Owners.

Runtime 0 may own:

```text
startup identity
runtime mode
scheduler / heartbeat / breathing spine
decision-state mirror
governance row helpers
manifest row helpers
runtime telemetry helpers
diagnostics / error capture
schema/version constants
internal recovery state
source-start proof controls
```

Runtime 0 must not own:

```text
account truth
symbol truth
quote truth
score truth
bucket truth
selection truth
deep evidence truth
permission truth
trade execution
strategy logic
operator-facing market meaning
```

Runtime 0 is an owner.

Runtime 0 is not a market brain.

---

## 6. Runtime 0 Layer Folder Set

Runtime 0 layer folders:

```text
runtime_0_governance_internal_control/
  layer_0_1_startup_runtime_identity/
  layer_0_2_scheduler_heartbeat_breathing/
  layer_0_3_decision_state_and_modes/
  layer_0_4_governance_manifest_telemetry/
  layer_0_5_diagnostics_errors_recovery/
```

These are internal-control layers.

They are not displayed as trader-facing layers.

They support the EA runtime.

---

## 7. Runtime 1 — Foundation Truth Owner Folder Set

```text
runtime_1_foundation_truth_owner/
  layer_1_account_portfolio_prop_rule_truth/
  layer_2_market_open_closed_truth/
  layer_3_symbol_broker_specs_truth/
  layer_4_market_watch_truth/
  layer_5_basic_system_gate/
```

Runtime 1 source starts only after Runtime 0 — Governance / Internal Control Owner proves folder creation, FileIO, heartbeat, manifest, telemetry, owner status, layer status, and diagnostics.

First Runtime 1 target later:

```text
Layer 1 — Account / Portfolio / Prop Rule Truth
```

Do not create source for Runtime 1 Layers 1–5 until Runtime 0 — Governance / Internal Control Owner is compiled, runtime-smoked, published, and audited.

---

## 8. Runtime 2 — Surface Scoring Owner Folder Set

```text
runtime_2_surface_scoring_owner/
  layer_6_surface_cost_friction_ranking/
  layer_7_session_relevance_ranking/
  layer_8_surface_movement_range_ranking/
  layer_9_surface_structure_location_geometry/
```

These folders must not be created until real source files are being added with explicit approval.

---

## 9. Runtime 3 — Bucket Intelligence Owner Folder Set

```text
runtime_3_bucket_intelligence_owner/
  layer_10_broker_bucket_classification/
  layer_11_symbol_ranking_inside_buckets/
  layer_12_bucket_heat_quality_ranking/
  layer_13_dynamic_top_bucket_selection/
  layer_14_bucket_leader_candidate_pool/
```

No bucket source exists during Runtime 0 — Governance / Internal Control Owner implementation.

---

## 10. Runtime 4 — Basket Selection Owner Folder Set

```text
runtime_4_basket_selection_owner/
  layer_15_correlation_diversity_selection/
  layer_16_global_top_10_builder/
```

Global Top 10 remains an inspection basket, not a trade list.

No selection source exists during Runtime 0 — Governance / Internal Control Owner implementation.

---

## 11. Runtime 5 — Selected Evidence Owner Folder Set

```text
runtime_5_selected_evidence_owner/
  layer_17_deep_evidence_selection_split/
  layer_18_selected_raw_ohlc_bar_pack/
  layer_19_selected_wick_candle_geometry_pack/
  layer_20_selected_rolling_tick_pack/
  layer_21_selected_indicator_reference_pack/
  layer_22_deep_market_evidence_liquidity_mt5_order_flow_proxy_pack/
```

Selected Evidence is expensive and selected-only.

No selected evidence source exists during Runtime 0 — Governance / Internal Control Owner implementation.

---

## 12. Runtime 6 — Permission / Alert Owner Folder Set

```text
runtime_6_permission_alert_owner/
  layer_23_setup_strategy_permission_alert_state/
```

Default state remains:

```text
setup strategy = QUARANTINE
directional alerts = HOLD
auto-trading = BLOCKED
trade permission = false
```

No alerts or setup logic exist during Runtime 0 — Governance / Internal Control Owner implementation.

---

## 13. Runtime 7 — Publication Owner Folder Set

Runtime 7 owns physical publication.

```text
runtime_7_publication_owner/
  publication_fileio/
  publication_routes/
  publication_surfaces/
  publication_manifest/
```

Runtime 7 may contain:

```text
AC_FileIO.mqh
AC_ServerPaths.mqh
AC_PublicationManifest.mqh later
AC_PublicationSurfaces.mqh later
```

Runtime 7 must not compute source truth.

It prints and proves outputs.

Runtime 7 support is allowed in the first source slice because Runtime 0 cannot prove folder creation or file writing without Publication Owner support.

---

## 14. Runtime 8 — Validation / Outcome Owner Folder Set

```text
runtime_8_validation_outcome_owner/
  validation_hypothesis_registry/
  validation_outcome_ledger/
  validation_null_model/
  validation_cost_model/
```

Validation may recommend future state changes.

Permission decides.

No validation source exists during Runtime 0 — Governance / Internal Control Owner implementation.

---

## 15. Core Shared Folder

Allowed shared source folder:

```text
mt5/core/
```

Allowed contents:

```text
AC_Config.mqh
AC_CommonTypes.mqh
AC_Text.mqh if needed
```

`mt5/core/` may hold shared constants and simple common helpers.

It must not become a hidden owner.

Forbidden in `mt5/core/`:

```text
account truth engine
symbol truth engine
FileIO final writer
ranking engine
permission engine
strategy engine
```

---

## 16. No Empty-Folder Spam Rule

Git does not track empty folders.

Do not create dozens of `.gitkeep` files just to show future folders.

Rule:

```text
The folder contract is defined here.
Actual folders are created only when their first real module is created.
```

This prevents folder confetti while preserving the architecture.

---

## 17. First Source Slice Folder Set

The first source slice is Runtime 0 — Governance / Internal Control Owner plus only the Runtime 7 — Publication Owner support needed to prove folders and file writing.

The first source slice may create only these source areas:

```text
mt5/AuroraCore.mq5
mt5/core/AC_Config.mqh
mt5/core/AC_CommonTypes.mqh

mt5/runtime_owners/runtime_0_governance_internal_control/
  layer_0_1_startup_runtime_identity/AC_RuntimeIdentity.mqh
  layer_0_2_scheduler_heartbeat_breathing/AC_Heartbeat.mqh
  layer_0_4_governance_manifest_telemetry/AC_GovernanceRows.mqh

mt5/runtime_owners/runtime_7_publication_owner/
  publication_fileio/AC_FileIO.mqh
  publication_routes/AC_ServerPaths.mqh
```

Do not create Runtime 1 — Foundation Truth Owner source in the first source slice.

Do not create source folders for all future owners yet.

---

## 18. Seed / Sentinel Inheritance Boundary

Seed and Sentinel are evidence.

They are not the new design authority.

Adopt from Seed now:

```text
account-safe routing concept
central path owner pattern
verified FileIO / last-good preserved concept
print-truth / degraded-publication law
```

Adopt from Seed later:

```text
account probe concept for Layer 1 — Account / Portfolio / Prop Rule Truth
```

Adopt from Sentinel now:

```text
heartbeat / breathing / lane law
no hidden ownership law
source-of-truth hierarchy once source exists
failure honesty law
```

Do not copy now:

```text
Seed broad include graph
Seed symbol universe
Seed account probe into Runtime 0
Seed Candidate Board
Seed Dossier bootstrap
Seed Selection Desk
Seed external worker bridge
Seed Layer 2/3/4 logic
Sentinel full complexity
```

Core is the new designed system.

---

## 19. Naming Rules

All source folder and module names must be human-readable.

Layer folders must include:

```text
layer number
full semantic layer name
```

Runtime folders must include:

```text
runtime number
full owner name
```

Module names should be explicit:

```text
AC_Layer0_1_StartupRuntimeIdentity.mqh
AC_Layer0_2_HeartbeatBreathing.mqh
AC_Layer0_4_GovernanceRows.mqh
AC_ServerPaths.mqh
AC_FileIO.mqh
```

Avoid vague names:

```text
AC_L1.mqh
AC_Helper.mqh
AC_Core2.mqh
AC_Manager.mqh
AC_Utils.mqh
```

---

## 20. Acceptance Criteria

This contract is acceptable if:

```text
Runtime Owner folders are defined.
Runtime 0 — Governance / Internal Control Owner is defined.
Every runtime owner has proper semantic folder names.
Every layer folder uses number + full name.
No empty-folder spam is allowed.
First source slice is Runtime 0 first.
Runtime 7 publication support is allowed only to prove folder/FileIO writing.
Runtime 1 — Foundation Truth Owner source is held until Runtime 0 passes.
Seed/Sentinel inheritance is bounded.
```

---

## 21. Final Source Folder Law

```text
Before Aurora knows the account or market, Aurora must prove it can create its home, breathe, write, and report failure.
Readable folders are part of correctness.
Every owner has a home.
Every layer has a name.
No hidden owner. No folder confetti. No blank-slate reinvention.
```
