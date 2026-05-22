# 00 MT5 SOURCE INDEX

## Purpose
MT5 source index for active source-tree ownership and implementation-scope guardrails.

## Current status
- MT5 source exists and is active in limited scope (Runtime 0 orchestrator + identity/heartbeat/governance rows, Runtime 1 Layer 1 account snapshot, Runtime 1 Layer 2 market open/closed truth, Runtime 1 Layer 3 broker specs/value truth, Runtime 1 Layer 4 live quote/spread truth, Runtime 1 Layer 5 Basic System Gate, Runtime 2 generated-row lookup-only source, Runtime 3 Calculation Gateway support surfaces, and Publication/FileIO/Route Service source under inherited `runtime_7_publication_owner` folder naming).
- Layer 1 source is active as account/portfolio/prop-rule truth. It must stay bounded: account status/history surfaces should use a bounded recent window, currently target last 100 closed trades or last 3 months, and must label bounded history honestly. Full all-time `HistorySelect(0, now)` scans are runtime-risky and must not be reintroduced without explicit proof/budget.
- Layer 3 source is active as broker/spec/value foundation. It scans Layer 2 known open and closed symbols, skips unknown symbols, and must render failed value or margin calculations as `Not available`, never fake `0.00`.
- Layer 5 source is active only as Basic System Gate. It consumes L2/L3/L4 owner packets and outputs pass/blocked eligibility. It must not become friction scoring, ranking, selection, permission, execution, or Gateway calculation authority.
- Runtime 3 Gateway support is source-present, but Windows autonomy proof remains evidence-class separated: source wired, Python syntax, PowerShell parse, package rebuild, scheduled task registration, daemon running, watchdog recovery, and MT5 Workbench readback are not the same proof.
- Publication/status/manifest truth repair is source-present, including late-write surfacing intent in final status publication.
- Placeholder Selection Desk parent-route files are structure-only route shells; they are physical publication surfaces, not ranking/selection/trading truth.
- Dossiers are active publication packets, but they do not prove ranking, selection, strategy, execution, trade permission, or prop-firm readiness.
- Compile/runtime proof is still required after source edits.

## Key files in this folder
- `mt5/AuroraCore.mq5`
- `mt5/core/AC_Config.mqh`
- `mt5/runtime_owners/00_RUNTIME_OWNERS_SOURCE_INDEX.md`
- `mt5/runtime_owners/runtime_1_foundation_truth_owner/layer_1_account_portfolio_prop_rule_truth/AC_AccountTruth.mqh`
- `mt5/runtime_owners/runtime_1_foundation_truth_owner/layer_1_account_portfolio_prop_rule_truth/AC_L1_Scan.mqh`
- `mt5/runtime_owners/runtime_1_foundation_truth_owner/layer_3_broker_symbol_specs_truth/AC_BrokerSpecsTruth.mqh`
- `mt5/runtime_owners/runtime_1_foundation_truth_owner/layer_3_broker_symbol_specs_truth/AC_L3_RenderTruth.mqh`
- `mt5/runtime_owners/runtime_1_foundation_truth_owner/layer_5_basic_system_gate/AC_BasicSystemGate.mqh`
- `mt5/runtime_owners/runtime_3_external_calculation_worker_owner/AC_ExternalWorkerOwner.mqh`
- `mt5/runtime_owners/runtime_7_publication_owner/publication_renderers/AC_PublicationRenderers.mqh`
- `external_worker/00_EXTERNAL_WORKER_SOURCE_INDEX.md`
- `mt5/00_RUNTIME0_GOVERNANCE_INTERNAL_CONTROL_SOURCE_PLAN_AND_TESTS.md`
- `mt5/01_LAYER1_ACCOUNT_PORTFOLIO_PROP_RULE_TRUTH_SOURCE_PLAN_AND_TESTS.md`

## Layer 1 account-history boundary
- Layer 1 may read account balances, equity, floating P/L, open positions, pending orders, and bounded recent history.
- Layer 1 must not become a strategy, signal, execution, ranking, or permission owner.
- Account status history should be capped to a recent operator-relevant window: target last 100 closed trades or last 3 months, whichever bounds the scan first.
- If a broader all-time report is needed later, build it as a deliberate slow-lane/report task with explicit timer budget and runtime proof, not inside normal heartbeat/full-publication cadence.

## External worker source boundary
- Active worker source authority is indexed in `external_worker/00_EXTERNAL_WORKER_SOURCE_INDEX.md`.
- One-shot repair scripts, emergency restore scripts, and `_aurora_*_backup_*` folders are not Runtime 3 source authority.
- Do not patch packaged artifacts, backup snapshots, or repair scripts as if they are active Runtime 3 logic.
- Do not claim Runtime 3B complete from Git source alone; require Windows task/daemon/watchdog/MT5 readback evidence.

## Folder Governance
- **Purpose:** index MT5 implementation ownership and source placement.
- **What belongs here:** MT5 source, MT5 source indexes, source plans/tests.
- **What must not belong here:** duplicate control doctrine or fake readiness claims.
- **Authority boundary:** MT5 source files are implementation truth.
- **Update rules:** update this index when source owners/files change.
- **No-go rules:** do not claim compile/runtime/trading readiness without explicit evidence.
- **Relationship to master index:** this folder is mapped in `control/02_MASTER_REPO_FILE_INDEX.md`.

## When to update this index
- When active owner scope changes.
- When new MT5 source index/planning files are added.
- When startup routing or source-truth hierarchy changes.
- When external worker source authority, packaging policy, or Runtime 3 proof requirements change.
