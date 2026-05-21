# AURORA CORE — LAYER 1 — ACCOUNT / PORTFOLIO / PROP RULE TRUTH SOURCE PLAN AND TESTS

**System:** AURORA CORE  
**Runtime Owner:** Foundation Truth Owner  
**Layer:** Layer 1 — Account / Portfolio / Prop Rule Truth  
**Status:** SOURCE PLANNING GATE — no `.mq5` or `.mqh` implementation yet.

---

## 0. Purpose

This file defines the first real MT5 source slice for AURORA CORE.

It exists to make coding start soon without drifting into a broad EA scaffold.

Core law:

```text
The first source slice is Layer 1 — Account / Portfolio / Prop Rule Truth only.
It captures account/terminal truth, publishes a small proof surface, and writes minimum governance proof rows.
It must not scan symbols, rank markets, create alerts, call strategies, or use an external worker.
```

---

## 1. Mandatory Reads Before Coding

Before implementing this layer, read:

```text
README.md
control/01_CONTROL_GOVERNANCE.md
control/01_CONTROL_GOVERNANCE.md
control/01_CONTROL_GOVERNANCE.md
docs/15_ANTI_DRIFT_SOURCE_OF_TRUTH_GUIDEBOOK.md
blueprint/02_RUNTIME_OWNER_BLUEPRINT.md
blueprint/03_LOGICAL_LAYER_BLUEPRINT.md
blueprint/04_BUILD_PHASE_BLUEPRINT.md
blueprint/07_FILEIO_ROUTE_OWNERSHIP_CONTRACT.md
governance/schemas/01_MINIMUM_GOVERNANCE_SCHEMA_CONTRACTS.md
research/mt5_official_docs/00_MT5_OFFICIAL_DOCS_INDEX.md
research/validation_methods/00_VALIDATION_METHODS_INDEX.md
prompts/workers/00_WORKER_PROMPTS_INDEX.md
```

No source worker may start from memory alone.

---

## 2. Allowed Scope

Layer 1 — Account / Portfolio / Prop Rule Truth may include:

```text
EA initialization shell
bounded timer heartbeat shell
account identity capture
account balance/equity/margin/free-margin/profit capture
account trade-mode flag capture as platform fact only
terminal/server/company/currency capture
prop-rule profile status placeholder
small account status publication surface
manifest row
runtime telemetry row
owner status row
layer status row
basic failure/degraded labels
```

---

## 3. Forbidden Scope

Layer 1 — Account / Portfolio / Prop Rule Truth must not include:

```text
symbol universe scanning
SymbolsTotal / SymbolName loops
SymbolInfoTick market-watch loops
SymbolInfoSessionTrade / SymbolInfoSessionQuote
SymbolInfoInteger/Double/String broker spec scanning
CopyRates
CopyTicks
MarketBookAdd / MarketBookGet
indicator handles
ranking
bucket taxonomy
selection
Global Top 10
deep evidence
SendNotification alerts
WebRequest
Python/external worker
trade execution
strategy setup logic
```

If any forbidden behavior appears, decision defaults to HOLD / TEST FIRST.

---

## 4. Allowed MQL5 Function Families

Allowed account functions:

```text
AccountInfoDouble
AccountInfoInteger
AccountInfoString
```

Allowed terminal/runtime support later:

```text
TerminalInfoInteger
TerminalInfoString
GetLastError
ResetLastError
TimeCurrent / TimeLocal / TimeGMT where labels are clear
EventSetTimer / EventKillTimer
OnInit / OnTimer / OnDeinit
```

Allowed FileIO only through approved FileIO owner pattern later:

```text
FileOpen
FileWrite
FileFlush
FileClose
FileMove
FileIsExist
FileSize
FolderCreate
```

FileIO must follow the FileIO / Route Ownership Contract.

---

## 5. Output Surfaces for First Slice

Keep first output small.

Minimum publication surfaces:

```text
Account Status shell
Manifest row
Runtime Telemetry row
Owner Status row
Layer Status row
```

Do not create full Board, full Dossier, Selection Desk, or external worker bridge outputs in this first slice.

---

## 6. Account Status Fields

Minimum account fields:

```text
generated_at
account_login
account_name
account_server
account_company
account_currency
account_trade_mode
account_trade_allowed_platform_flag
account_trade_expert_platform_flag
balance
equity
profit
margin
free_margin
margin_level
credit
stopout_mode
stopout_call
stopout_so
prop_rule_status
risk_state
status
degraded_reason
blocked_reason
```

Important:

```text
account_trade_allowed_platform_flag is not Aurora trade permission.
account_trade_expert_platform_flag is not Aurora auto-trading permission.
prop_rule_status may be unknown.
unknown prop_rule_status must print honestly.
```

---

## 7. Minimum Governance Rows

Layer 1 — Account / Portfolio / Prop Rule Truth must generate or plan these rows:

### Manifest row

```text
surface = account_status
source_owner = Foundation Truth Owner
source_layer = Layer 1 — Account / Portfolio / Prop Rule Truth
write_status = file_written_clean / file_written_degraded / file_written_partial / failed state
```

### Runtime telemetry row

```text
heartbeat_id
timer_started_at
timer_finished_at
timer_duration_ms
timer_budget_ms
over_budget_flag
publication_completed_flag
fake_alive_risk_flag
```

### Owner status row

```text
owner_id = foundation_truth_owner
owner_name = Foundation Truth Owner
owner_status
last_attempt_at
last_success_at
freshness_state
```

### Layer status row

```text
layer_id = 1
layer_name = Layer 1 — Account / Portfolio / Prop Rule Truth
source_owner = Foundation Truth Owner
layer_status
primary_output_available
```

---

## 8. Failure / Degraded States

Required states:

```text
account_unavailable
terminal_disconnected
account_field_missing
prop_rule_unknown
file_route_missing
temp_file_open_failed
temp_write_failed
move_to_final_failed
final_verify_failed
manifest_failed
runtime_telemetry_missing
owner_status_missing
layer_status_missing
```

These states must be printed or recorded.

They must not be hidden behind `complete`.

---

## 9. Compile Test

After source is created or changed, compile proof requires:

```text
compiled file path
MetaEditor/compiler output
error count
warning count
timestamp
```

Compile success proves only syntax/basic build compatibility.

It does not prove runtime publication, edge, live safety, or prop-firm readiness.

---

## 10. Runtime Smoke Test

Runtime smoke proof requires generated outputs/logs showing:

```text
EA initialized
Timer heartbeat executed
Layer 1 — Account / Portfolio / Prop Rule Truth attempted
account status output attempted
manifest row produced
runtime telemetry row produced
owner status row produced
layer status row produced
no forbidden Layer 2+ behavior present
```

No runtime-generated files/logs = no runtime proof.

---

## 11. Negative Tests

Minimum negative cases:

```text
simulate or detect FileOpen invalid handle
simulate or detect final move failure
prop rule profile unknown
account field unavailable
manifest row failure
owner/layer status missing
```

Expected result:

```text
physical publication failures are visible
unknown prop-rule state is honest
trade permission remains false
no clean-complete claim when proof rows fail
```

---

## 12. Acceptance Criteria

Layer 1 — Account / Portfolio / Prop Rule Truth source implementation may be accepted only if:

```text
source scope stays inside Layer 1 — Account / Portfolio / Prop Rule Truth
AccountInfo* fields are captured or honestly unavailable
platform trade flags are labelled as platform flags only
prop_rule_status can be unknown without hiding publication
FileIO uses approved owner pattern
manifest/runtime/owner/layer proof rows exist
compile proof exists after source creation
runtime proof exists before runtime readiness is claimed
no symbols/ranking/buckets/alerts/strategy/external-worker logic appears
```

---

## 13. Rollback / HOLD Conditions

Hold or roll back if:

```text
compile fails
runtime files do not print
manifest contradicts physical output
owner status says complete while layer status failed
Layer 1 — Account / Portfolio / Prop Rule Truth includes forbidden later-layer logic
FileIO route is invented outside approved contract
trade permission is inferred from account flags
```

---

## 14. Next Step After This Plan

If this plan is accepted and source implementation is explicitly requested, next source target is:

```text
Create the smallest MT5 source slice for Layer 1 — Account / Portfolio / Prop Rule Truth.
```

Do not start Layer 2 — Market Open / Closed Truth until Layer 1 is compiled, runtime-smoked, published, and audited.

---

## 15. Final Layer 1 Law

```text
Layer 1 — Account / Portfolio / Prop Rule Truth proves Aurora can identify the account, pulse, print, and prove its own first output.
Nothing more.
```