# 00 MT5 SOURCE INDEX

## Purpose
MT5 source index for active source-tree ownership and implementation-scope guardrails.

## Current status
- MT5 source exists and is active in limited scope (Runtime 0 orchestrator + identity/heartbeat/governance rows, Runtime 1 Layer 1 account snapshot, Runtime 1 Layer 2 market open/closed truth, Runtime 1 Layer 3 broker specs/value truth, Runtime 1 Layer 4 live quote/spread truth, Runtime 1 Layer 5 Basic System Gate, Runtime 1 Shared OHLC Raw Storage source scaffold, Runtime 2 generated-row lookup-only source, Runtime 3 Calculation Gateway support surfaces including L6/L7/L8/L9/L10/L11/L12/L13/L14/L15/L16/L17 worker-output readback surfaces, Runtime 4 Layer 7 Session Relevance contract stub, and Publication/FileIO/Route Service source under inherited `runtime_7_publication_owner` folder naming).
- Layer 1 source is active as account/portfolio/prop-rule truth. It must stay bounded: account status/history surfaces should use a bounded recent operator window. Current rule: retain all selected closed-trade rows inside the last 90 days; if fewer than 100 closed rows exist in that window, extend older history only until 100 closed rows are available when possible. The output must label this selected-history rule honestly. Full all-time `HistorySelect(0, now)` scans are runtime-risky and must not be reintroduced as normal heartbeat behavior without explicit proof/budget.
- Layer 3 source is active as broker/spec/value foundation. It scans Layer 2 known open and closed symbols, skips unknown symbols, and must render failed value or margin calculations as `Not available`, never fake `0.00`.
- Layer 5 source is active only as Basic System Gate. It consumes L2/L3/L4 owner packets and outputs pass/blocked eligibility. It must not become friction scoring, ranking, selection, permission, execution, or Gateway calculation authority.
- Shared OHLC Raw Storage source is present as Runtime 1 support service scaffold. It owns raw `CopyRates`/`MqlRates` storage contracts only and must not calculate range, wick/body geometry, ATR, trend, volatility, scoring, ranking, selection, permission, or execution. It is not scheduler-activated for full all-symbol 1500-bar seed until compile/runtime proof is captured.
- Runtime 4 Layer 7 source is contract-only. It defines Session Relevance Ranking ownership and explicitly forbids duplicate market-open truth, hard gating, OHLC/session-range ownership, VWAP ownership, selection, permission, and execution.
- Runtime 3 Gateway support is source-present, but Windows autonomy proof remains evidence-class separated: source wired, Python syntax, PowerShell parse, package rebuild, scheduled task registration, daemon running, watchdog recovery, and MT5 Workbench readback are not the same proof. Gateway may calculate from shared raw OHLC files for L15, but must not fetch broker history directly. L16 consumes L14/L15 worker outputs only and must not read raw OHLC or recompute correlation. L17 consumes L16 held visible display rows only and must not collect OHLC/ticks/indicators/liquidity.
- Runtime 7 render surfaces are source-present for L11-L17 worker readback. They render Board/Dossier/Workbench-style sections only and must not calculate scores, correlation, selection, permission, execution, or deep evidence collection.
- Publication/status/manifest truth repair is source-present, including late-write surfacing intent in final status publication.
- Placeholder Selection Desk parent-route files are structure-only route shells unless populated by worker outputs. They are physical publication surfaces, not trading truth.
- Dossiers are active publication packets, but they do not prove ranking, selection, strategy, execution, trade permission, or prop-firm readiness.
- Compile/runtime proof is still required after source edits.

## Key files in this folder
- `mt5/AuroraCore.mq5`
- `mt5/core/AC_Config.mqh`
- `mt5/runtime_owners/00_RUNTIME_OWNERS_SOURCE_INDEX.md`
- `mt5/runtime_owners/runtime_1_foundation_truth_owner/layer_1_account_portfolio_prop_rule_truth/AC_AccountTruth.mqh`
- `mt5/runtime_owners/runtime_1_foundation_truth_owner/layer_1_account_portfolio_prop_rule_truth/AC_L1_Scan.mqh`
- `mt5/runtime_owners/runtime_1_foundation_truth_owner/layer_1_account_portfolio_prop_rule_truth/AC_L1_Maps.mqh`
- `mt5/runtime_owners/runtime_1_foundation_truth_owner/layer_3_broker_symbol_specs_truth/AC_BrokerSpecsTruth.mqh`
- `mt5/runtime_owners/runtime_1_foundation_truth_owner/layer_3_broker_symbol_specs_truth/AC_L3_RenderTruth.mqh`
- `mt5/runtime_owners/runtime_1_foundation_truth_owner/layer_5_basic_system_gate/AC_BasicSystemGate.mqh`
- `mt5/runtime_owners/runtime_1_foundation_truth_owner/shared_ohlc_raw_storage/00_SHARED_OHLC_RAW_STORAGE_SOURCE_INDEX.md`
- `mt5/runtime_owners/runtime_1_foundation_truth_owner/shared_ohlc_raw_storage/AC_SharedOhlcRawStorage.mqh`
- `mt5/runtime_owners/runtime_1_foundation_truth_owner/shared_ohlc_raw_storage/AC_SharedOhlcOwner.mqh`
- `mt5/runtime_owners/runtime_7_publication_owner/publication_routes/AC_SharedOhlcRoutes.mqh`
- `mt5/runtime_owners/runtime_3_external_calculation_worker_owner/AC_ExternalWorkerOwner.mqh`
- `mt5/runtime_owners/runtime_3_external_calculation_worker_owner/AC_ExternalWorkerL7InputPrimitives.mqh`
- `mt5/runtime_owners/runtime_4_surface_scoring_owner/layer_7_session_relevance_ranking/AC_SessionRelevanceOwner.mqh`
- `mt5/runtime_owners/runtime_7_publication_owner/publication_renderers/AC_PublicationRenderers.mqh`
- `mt5/runtime_owners/runtime_7_publication_owner/publication_renderers/AC_Layer7SessionRelevanceRenderer.mqh`
- `mt5/runtime_owners/runtime_7_publication_owner/publication_renderers/AC_Layer8MovementRangeRenderer.mqh`
- `mt5/runtime_owners/runtime_7_publication_owner/publication_renderers/AC_Layer9StructureLocationRenderer.mqh`
- `mt5/runtime_owners/runtime_7_publication_owner/publication_renderers/AC_Layer10TaxonomyRenderer.mqh`
- `mt5/runtime_owners/runtime_7_publication_owner/publication_renderers/AC_Layer11SelectionGroupsRenderer.mqh`
- `mt5/runtime_owners/runtime_7_publication_owner/publication_renderers/AC_Layer12GroupHeatQualityRenderer.mqh`
- `mt5/runtime_owners/runtime_7_publication_owner/publication_renderers/AC_Layer13DynamicGroupSelectionRenderer.mqh`
- `mt5/runtime_owners/runtime_7_publication_owner/publication_renderers/AC_Layer14CandidatePoolRenderer.mqh`
- `mt5/runtime_owners/runtime_7_publication_owner/publication_renderers/AC_Layer15CorrelationDiversityRenderer.mqh`
- `mt5/runtime_owners/runtime_7_publication_owner/publication_renderers/AC_Layer16GlobalTop10Renderer.mqh`
- `mt5/runtime_owners/runtime_7_publication_owner/publication_renderers/AC_Layer17DeepEvidenceRenderer.mqh`
- `external_worker/00_EXTERNAL_WORKER_SOURCE_INDEX.md`
- `mt5/00_RUNTIME0_GOVERNANCE_INTERNAL_CONTROL_SOURCE_PLAN_AND_TESTS.md`
- `mt5/01_LAYER1_ACCOUNT_PORTFOLIO_PROP_RULE_TRUTH_SOURCE_PLAN_AND_TESTS.md`

## Layer 1 account-history boundary
- Layer 1 may read account balances, equity, floating P/L, open positions, pending orders, and selected recent history.
- Layer 1 must not become a strategy, signal, execution, ranking, or permission owner.
- Account status history should use the current selected-history rule: keep all closed rows inside the last 90 days; if that set has fewer than 100 rows, fill with older closed rows up to 100 when available. This is a minimum-fill rule, not a hard cap against the 90-day window.
- Layer 1 portfolio maps are numeric read-only account-history maps. They may summarize selected closed history by risk budget, asset class, currency touch, symbol, time window, holding time, and cluster grouping. They must not become trade permission, ranking, selection, or execution authority.
- If a broader all-time report is needed later, build it as a deliberate slow-lane/report task with explicit timer budget and runtime proof, not inside normal heartbeat/full-publication cadence.

## Shared OHLC raw storage boundary
- Shared OHLC Raw Storage may call `CopyRates` for raw `MqlRates` storage only.
- Shared OHLC Raw Storage stores server-level raw bars under `Aurora Core/<server>/Shared Market Data/OHLC Store/` through the route owner.
- Shared OHLC Raw Storage may use Layer 5 pass/blocked state only for refresh priority, not symbol filtering authority.
- Future layers must not call `CopyRates` or create private OHLC caches for normal layer work.
- Gateway/EXE may calculate from shared raw files later, but must not fetch broker history directly.
- Board may show overview status only; Dossiers may show availability/counts only until a dedicated future layer owns bar display.
- Current implementation is source scaffold only; compile proof and bounded scheduler activation are still required.

## External worker source boundary
- Active worker source authority is indexed in `external_worker/00_EXTERNAL_WORKER_SOURCE_INDEX.md`.
- One-shot repair scripts, emergency restore scripts, and `_aurora_*_backup_*` folders are not Runtime 3 source authority.
- Do not patch packaged artifacts, backup snapshots, or repair scripts as if they are active Runtime 3 logic.
- Do not claim Runtime 3B complete from Git source alone; require Windows task/daemon/watchdog/MT5 readback evidence.
- Gateway/EXE remains calculation support only and must consume shared raw OHLC files when OHLC-derived calculations are implemented.
- L15 may calculate correlation/diversity from Shared OHLC Store and L14 candidate pool only. Missing OHLC must degrade visibly, not fake correlation.
- L16 may build the Global Top 10 inspection basket from L14/L15 worker outputs only. It must not read raw OHLC, recompute correlation, permit, alert, or execute.
- L17 may split L16 held visible display rows into selected/rejected future deep-evidence budget only. It must not collect OHLC, ticks, indicators, liquidity, poll brokers, permit, alert, or execute.

## Runtime 7 render surface boundary
- Runtime 7 renderers may read worker summaries/CSVs and display Board/Dossier/Workbench sections.
- Renderers must not calculate L11-L17 scores, re-rank symbols, build selected groups, build candidate pools, calculate correlation, create new basket authority, collect evidence, permit, alert, or execute.
- L15 renderer is readback only. L16 renderer is readback only; worker L16 owns calculation-support Global Top 10 construction. L17 renderer is readback only; worker L17 owns deep-evidence selection split output.

## Layer 7 contract boundary
- Layer 7 is Session Relevance Ranking under Runtime 4 Surface Scoring Owner.
- Layer 7 may rank session-context relevance for Layer 5 pass symbols only.
- Layer 7 must consume Layer 2 market/session truth rather than deciding open/closed state.
- Layer 7 must not become a hard gate, strategy, selection, permission, execution, OHLC/session-range, VWAP, or liquidity-map owner.
- L7 input primitive export is now source-present in Runtime 3, but L7 Gateway sidecar scoring remains pending and requires separate proof.

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
- When shared raw OHLC ownership, routes, or scheduler activation changes.