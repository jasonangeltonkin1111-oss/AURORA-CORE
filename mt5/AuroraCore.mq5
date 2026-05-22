#property strict
#property version   "1.046"
#property description "AURORA CORE - foundation truth and gateway support"

#include "core/AC_Config.mqh"
#include "core/AC_CommonTypes.mqh"
#include "runtime_owners/runtime_7_publication_owner/publication_routes/AC_ServerPaths.mqh"
#include "runtime_owners/runtime_7_publication_owner/publication_fileio/AC_FileIO.mqh"
#include "runtime_owners/runtime_0_governance_internal_control/layer_0_1_startup_runtime_identity/AC_RuntimeIdentity.mqh"
#include "runtime_owners/runtime_0_governance_internal_control/layer_0_2_scheduler_heartbeat_breathing/AC_Heartbeat.mqh"
#include "runtime_owners/runtime_0_governance_internal_control/layer_0_4_governance_manifest_telemetry/AC_GovernanceRows.mqh"
#include "runtime_owners/runtime_1_foundation_truth_owner/layer_1_account_portfolio_prop_rule_truth/AC_AccountTruth.mqh"
#include "runtime_owners/runtime_1_foundation_truth_owner/layer_2_market_open_closed_truth/AC_MarketSessionTruth.mqh"
#include "runtime_owners/runtime_2_market_universe_taxonomy_lookup/AC_MarketUniverse.mqh"
#include "runtime_owners/runtime_1_foundation_truth_owner/layer_3_broker_symbol_specs_truth/AC_BrokerSpecsTruth.mqh"
#include "runtime_owners/runtime_1_foundation_truth_owner/layer_4_market_watch_truth/AC_MarketWatchTruth.mqh"
#include "runtime_owners/runtime_1_foundation_truth_owner/layer_5_basic_system_gate/AC_BasicSystemGate.mqh"
#include "runtime_owners/runtime_3_external_calculation_worker_owner/AC_ExternalWorkerOwner.mqh"
#include "runtime_owners/runtime_7_publication_owner/publication_renderers/AC_PublicationRenderers.mqh"

AC_Runtime0Snapshot AC_SNAPSHOT;
AC_Layer0StatusPacket AC_L0_STATUS;
bool AC_TIMER_READY = false;
int  AC_TIMER_SETUP_ERROR = 0;
int  AC_TIMER_TICKS_SINCE_WORKBENCH = 0;
string AC_MICRO_LOG = "";
string AC_LAST_BOARD_TEXT = "";
string AC_LAST_RUNTIME_STATUS_TEXT = "";
string AC_LAST_WORKBENCH_STATUS_TEXT = "";
string AC_LAST_ACCOUNT_STATUS_TEXT = "";

void AC_AppendReason(const string reason)
{
   if(reason == "") return;
   if(AC_SNAPSHOT.blocked_reason == "") AC_SNAPSHOT.blocked_reason = reason;
   else AC_SNAPSHOT.blocked_reason += ";" + reason;
}

void AC_ResetSnapshot()
{
   AC_SNAPSHOT.runtime_state = "not_started";
   AC_SNAPSHOT.terminal_connected = "unknown";
   AC_SNAPSHOT.timer_setup_status = AC_TIMER_READY ? "timer_set" : "timer_not_set";
   AC_SNAPSHOT.timer_setup_error = AC_TIMER_SETUP_ERROR;
   AC_SNAPSHOT.route_root = AC_RootFolder();
   AC_SNAPSHOT.folder_create_status = "not_attempted";
   AC_SNAPSHOT.placeholder_status = "not_attempted";
   AC_SNAPSHOT.fileio_status = "not_attempted";
   AC_SNAPSHOT.manifest_status = "not_attempted";
   AC_SNAPSHOT.telemetry_status = "not_attempted";
   AC_SNAPSHOT.diagnostics_status = "not_attempted";
   AC_SNAPSHOT.upgrade_log_status = "not_attempted";
   AC_SNAPSHOT.upgrade_addendum_status = "not_attempted";
   AC_SNAPSHOT.micro_log_status = "not_attempted";
   AC_SNAPSHOT.owner_status = "not_started";
   AC_SNAPSHOT.layer_0_1_status = "not_started";
   AC_SNAPSHOT.layer_0_2_status = "not_started";
   AC_SNAPSHOT.layer_0_4_status = "not_started";
   AC_SNAPSHOT.file_publication_blocked = false;
   AC_SNAPSHOT.degraded_reason = "";
   AC_SNAPSHOT.blocked_reason = "";
   AC_MICRO_LOG = "schema_name=micro_log_snapshot\r\nschema_version=v0.6\r\n";
   AC_Layer0InitStatus(AC_L0_STATUS);
}

void AC_AddMicroLog(const string function_name, const uint start_ms, const string status)
{
   uint end_ms = GetTickCount();
   AC_MICRO_LOG += AC_MicroLogRow(function_name, start_ms, end_ms, status) + "\r\n";
}

void AC_RecordWriteProblem(const string surface, const AC_WriteResult &result)
{
   if(result.ok) return;
   AC_SNAPSHOT.file_publication_blocked = true;
   AC_AppendReason(surface + "=" + result.status);
}

string AC_BuildWorkbenchStatusText(const AC_WriteResult &account_write,
                                   const AC_Layer0StatusPacket &layer0_status)
{
   return AC_RuntimeTelemetryRow(AC_SNAPSHOT) + "\r\n"
      + AC_OwnerStatusRow(AC_SNAPSHOT) + "\r\n"
      + AC_LayerStatusRows(AC_SNAPSHOT)
      + AC_Layer0StatusRow(layer0_status) + "\r\n"
      + AC_AccountTruthStatusRow(account_write) + "\r\n"
      + AC_Layer2StatusRow() + "\r\n"
      + AC_Layer3StatusRow() + "\r\n"
      + AC_Layer4StatusRow() + "\r\n"
      + AC_Layer5StatusRow() + "\r\n"
      + AC_ExternalWorkerStatusRow() + "\r\n"
      + AC_UniverseStatusRow() + "\r\n\r\n"
      + AC_Layer0WorkbenchText(layer0_status)
      + AC_ExternalWorkerWorkbenchSection();
}

string AC_BuildRuntimeStatusText()
{
   return AC_RuntimeIdentityText() + AC_RuntimeStatusText(AC_SNAPSHOT) + AC_HeartbeatStatusText(AC_SNAPSHOT);
}

void AC_FinalizeState(const AC_WriteResult &runtime_write,
                      const AC_WriteResult &status_write,
                      const AC_WriteResult &manifest_write,
                      const AC_WriteResult &diagnostics_write,
                      const AC_WriteResult &account_write,
                      const AC_WriteResult &board_write,
                      const AC_WriteResult &dossier_batch_write)
{
   AC_SNAPSHOT.fileio_status = runtime_write.ok ? runtime_write.status : runtime_write.status;
   AC_SNAPSHOT.telemetry_status = status_write.ok ? status_write.status : status_write.status;
   AC_SNAPSHOT.manifest_status = manifest_write.ok ? manifest_write.status : manifest_write.status;
   AC_SNAPSHOT.diagnostics_status = diagnostics_write.ok ? diagnostics_write.status : diagnostics_write.status;
   AC_RecordWriteProblem("Runtime Status", runtime_write);
   AC_RecordWriteProblem("Workbench Status", status_write);
   AC_RecordWriteProblem("Manifest", manifest_write);
   AC_RecordWriteProblem("Diagnostics", diagnostics_write);
   AC_RecordWriteProblem("Account Status", account_write);
   AC_RecordWriteProblem("Market Board", board_write);
   AC_RecordWriteProblem("Dossier Universe", dossier_batch_write);
   AC_SNAPSHOT.layer_0_4_status = (status_write.ok && manifest_write.ok && diagnostics_write.ok && board_write.ok && dossier_batch_write.ok) ? "complete" : "complete_with_degraded";
   AC_SNAPSHOT.owner_status = AC_SNAPSHOT.file_publication_blocked ? "complete_with_degraded" : "complete";
}

void AC_ApplyLateWriteStatus(const string surface, const AC_WriteResult &result)
{
   AC_RecordWriteProblem(surface, result);
   if(!result.ok)
      AC_SNAPSHOT.file_publication_blocked = true;
}

AC_WriteResult AC_PublishMarketBoardOnly()
{
   AC_SNAPSHOT.terminal_connected = TerminalInfoInteger(TERMINAL_CONNECTED) ? "true" : "false";
   if(AC_L1_READY)
   {
      AC_RefreshLayer1SnapshotOnly();
      AC_BuildLayer1Texts();
   }
   if(AC_L2_READY) AC_BuildLayer2Texts();
   if(AC_L3_READY) AC_BuildLayer3Texts();
   if(AC_L4_READY) AC_BuildLayer4Texts();
   AC_BuildLayer5Texts();
   string board_text = AC_BuildTraderBoardText(AC_SNAPSHOT, AC_L0_STATUS);
   return AC_WriteTextFileIfChanged(AC_MarketBoardPath(), board_text, AC_LAST_BOARD_TEXT, false);
}

void AC_PublishRuntime0Full(const bool force_publication = false)
{
   AC_ResetSnapshot();
   uint phase_start = GetTickCount();
   AC_HeartbeatBegin(AC_SNAPSHOT);
   AC_SNAPSHOT.terminal_connected = TerminalInfoInteger(TERMINAL_CONNECTED) ? "true" : "false";
   AC_SNAPSHOT.layer_0_1_status = "complete";
   AC_SNAPSHOT.layer_0_2_status = "filling";
   AC_SNAPSHOT.layer_0_4_status = "filling";
   AC_SNAPSHOT.owner_status = "filling";
   if(!AC_TIMER_READY)
   {
      AC_SNAPSHOT.degraded_reason = "timer_setup_not_confirmed";
      AC_AppendReason("timer_setup_error=" + IntegerToString(AC_TIMER_SETUP_ERROR));
   }
   AC_AddMicroLog("publish_prepare", phase_start, "complete");

   phase_start = GetTickCount();
   string folder_detail = "";
   bool folders_ok = AC_EnsureRuntimeFolders(folder_detail);
   AC_SNAPSHOT.folder_create_status = AC_FolderStatusFromDetail(folders_ok, folder_detail);
   if(!folders_ok)
   {
      AC_SNAPSHOT.file_publication_blocked = true;
      AC_AppendReason(folder_detail);
   }
   AC_AddMicroLog("ensure_runtime_folders", phase_start, AC_SNAPSHOT.folder_create_status);

   phase_start = GetTickCount();
   AC_SNAPSHOT.placeholder_status = AC_CleanupLegacyPlaceholderFiles();
   AC_AddMicroLog("cleanup_legacy_placeholder_files", phase_start, AC_SNAPSHOT.placeholder_status);

   phase_start = GetTickCount();
   AC_RefreshExternalWorkerStatus();
   AC_WriteResult worker_required_write = AC_WriteExternalWorkerRequired();
   AC_AddMicroLog("gateway_status_and_required", phase_start, worker_required_write.status);

   phase_start = GetTickCount();
   AC_RefreshLayer1AccountTruth();
   AC_AddMicroLog("refresh_layer1_account_truth", phase_start, AC_L1_SCAN_STATUS);

   phase_start = GetTickCount();
   if(AC_L2ShouldRunFullScan()) AC_RefreshLayer2MarketSessionTruth();
   else AC_BuildLayer2Texts();
   AC_AddMicroLog("refresh_layer2_market_session_truth", phase_start, AC_L2_SCAN_STATUS);

   phase_start = GetTickCount();
   if(AC_L3ShouldRunFullScan()) AC_RefreshLayer3BrokerSpecsTruth();
   else AC_BuildLayer3Texts();
   AC_AddMicroLog("refresh_layer3_broker_specs_truth", phase_start, AC_L3_SCAN_STATUS);

   phase_start = GetTickCount();
   if(AC_L4ShouldRunFullScan()) AC_RefreshLayer4MarketWatchTruth();
   else AC_BuildLayer4Texts();
   AC_AddMicroLog("refresh_layer4_market_watch_truth", phase_start, AC_L4_SCAN_STATUS);

   phase_start = GetTickCount();
   AC_BuildLayer5Texts();
   AC_AddMicroLog("refresh_layer5_basic_system_gate", phase_start, AC_L5_STATUS);

   phase_start = GetTickCount();
   AC_WriteResult dossier_batch_write = AC_PublishLayer0DossierBatch(AC_L0_STATUS);
   AC_RecordWriteProblem("Dossier Universe", dossier_batch_write);
   AC_AddMicroLog("l0_l2_l3_l4_l5_dossier_universe", phase_start, dossier_batch_write.status);

   AC_HeartbeatFinish(AC_SNAPSHOT);
   AC_SNAPSHOT.layer_0_2_status = AC_SNAPSHOT.over_budget ? "complete_with_degraded" : "complete";

   phase_start = GetTickCount();
   AC_WriteResult board_write = AC_WriteTextFileIfChanged(AC_MarketBoardPath(), AC_BuildTraderBoardText(AC_SNAPSHOT, AC_L0_STATUS), AC_LAST_BOARD_TEXT, force_publication);
   AC_WriteResult account_write = AC_WriteTextFileIfChanged(AC_AccountStatusPath(), AC_AccountTruthText(), AC_LAST_ACCOUNT_STATUS_TEXT, force_publication);
   AC_WriteResult runtime_write = AC_WriteTextFileIfChanged(AC_RuntimeStatusPath(), AC_BuildRuntimeStatusText(), AC_LAST_RUNTIME_STATUS_TEXT, force_publication);
   AC_WriteResult status_write = AC_WriteTextFileIfChanged(AC_WorkbenchStatusPath(), AC_BuildWorkbenchStatusText(account_write, AC_L0_STATUS), AC_LAST_WORKBENCH_STATUS_TEXT, force_publication);
   AC_AddMicroLog("write_primary_surfaces_if_changed", phase_start, (board_write.ok && account_write.ok && runtime_write.ok && status_write.ok) ? "complete" : "degraded");

   string manifest = "";
   manifest += AC_ManifestRow("Market Board", board_write, AC_SNAPSHOT, "trader_board_if_changed") + "\r\n";
   manifest += AC_ManifestRow("Dossier Universe", dossier_batch_write, AC_SNAPSHOT, "l0_l2_l3_l4_l5_dossier_universe_cached_or_run") + "\r\n";
   manifest += AC_ManifestRow("Runtime Status", runtime_write, AC_SNAPSHOT, "runtime_if_changed") + "\r\n";
   manifest += AC_ManifestRow("Workbench Status", status_write, AC_SNAPSHOT, "workbench_if_changed") + "\r\n";
   manifest += AC_ManifestRow("Account Status", account_write, AC_SNAPSHOT, "account_if_changed") + "\r\n";
   manifest += AC_ManifestRow("Gateway Required", worker_required_write, AC_SNAPSHOT, "gateway_required_control") + "\r\n";
   AC_WriteResult manifest_write = AC_WriteTextFile(AC_ManifestPath(), manifest);

   string diagnostics = "";
   diagnostics += "system_name=" + AC_SYSTEM_NAME + "\r\n";
   diagnostics += "build_version=" + AC_BUILD_VERSION + "\r\n";
   diagnostics += "upgrade_id=" + AC_UPGRADE_ID + "\r\n";
   diagnostics += "runtime_owner=" + AC_RUNTIME0_OWNER + "\r\n";
   diagnostics += "publication_service_owner=" + AC_PUBLICATION_SERVICE_OWNER + "\r\n";
   diagnostics += "board_dossier_renderer_owner=" + AC_BOARD_DOSSIER_RENDERER_OWNER + "\r\n";
   diagnostics += "foundation_truth_owner=" + AC_RUNTIME1_OWNER + "\r\n";
   diagnostics += "gateway_owner=" + AC_RUNTIME3_OWNER + "\r\n";
   diagnostics += "layer5_owner=" + AC_RUNTIME1_OWNER + "\r\n";
   diagnostics += "timer_setup_status=" + AC_SNAPSHOT.timer_setup_status + "\r\n";
   diagnostics += "timer_setup_error=" + IntegerToString(AC_SNAPSHOT.timer_setup_error) + "\r\n";
   diagnostics += "folder_detail=" + folder_detail + "\r\n";
   diagnostics += "placeholder_status=" + AC_SNAPSHOT.placeholder_status + "\r\n";
   diagnostics += "market_board_write=" + AC_WriteResultLine("Market Board", board_write) + "\r\n";
   diagnostics += "dossier_universe_write=" + AC_WriteResultLine("Dossier Universe", dossier_batch_write) + "\r\n";
   diagnostics += "runtime_write=" + AC_WriteResultLine("Runtime Status", runtime_write) + "\r\n";
   diagnostics += "workbench_status_write=" + AC_WriteResultLine("Workbench Status", status_write) + "\r\n";
   diagnostics += "account_status_write=" + AC_WriteResultLine("Account Status", account_write) + "\r\n";
   diagnostics += "gateway_required_write=" + AC_WriteResultLine("Gateway Required", worker_required_write) + "\r\n";
   diagnostics += "manifest_write=" + AC_WriteResultLine("Manifest", manifest_write) + "\r\n";
   diagnostics += "gateway_status=" + AC_EXTERNAL_WORKER_STATUS.worker_status + "\r\n";
   diagnostics += "gateway_install_status=" + AC_EXTERNAL_WORKER_STATUS.install_status + "\r\n";
   diagnostics += "gateway_expected_exe=" + AC_ExternalWorkerExePath() + "\r\n";
   diagnostics += "gateway_required_path=" + AC_ExternalWorkerRequiredPath() + "\r\n";
   diagnostics += "gateway_authority=" + AC_EXTERNAL_WORKER_AUTHORITY + "\r\n";
   diagnostics += "gateway_popup_alerts=false\r\n";
   diagnostics += "gateway_core_blocking=false\r\n";
   diagnostics += "layer1_scan_status=" + AC_L1_SCAN_STATUS + "\r\n";
   diagnostics += "layer1_scan_duration_ms=" + IntegerToString((int)AC_L1_SCAN_DURATION_MS) + "\r\n";
   diagnostics += "layer2_scan_status=" + AC_L2_SCAN_STATUS + "\r\n";
   diagnostics += "layer2_scan_duration_ms=" + IntegerToString((int)AC_L2_SCAN_DURATION_MS) + "\r\n";
   diagnostics += "layer2_open_count=" + IntegerToString(AC_L2_OPEN_COUNT) + "\r\n";
   diagnostics += "layer2_closed_count=" + IntegerToString(AC_L2_CLOSED_COUNT) + "\r\n";
   diagnostics += "layer2_unknown_count=" + IntegerToString(AC_L2_UNKNOWN_COUNT) + "\r\n";
   diagnostics += "layer2_route_generation_key=" + AC_L2_ROUTE_GENERATION_KEY + "\r\n";
   diagnostics += "layer3_scan_status=" + AC_L3_SCAN_STATUS + "\r\n";
   diagnostics += "layer3_scan_duration_ms=" + IntegerToString((int)AC_L3_SCAN_DURATION_MS) + "\r\n";
   diagnostics += "layer3_eligible_from_l2=" + IntegerToString(AC_L3_ELIGIBLE_FROM_L2) + "\r\n";
   diagnostics += "layer3_spec_ready_count=" + IntegerToString(AC_L3_SPEC_READY_COUNT) + "\r\n";
   diagnostics += "layer3_value_ready_count=" + IntegerToString(AC_L3_VALUE_READY_COUNT) + "\r\n";
   diagnostics += "layer3_margin_ready_count=" + IntegerToString(AC_L3_MARGIN_READY_COUNT) + "\r\n";
   diagnostics += "layer3_cache_key=" + AC_L3_CACHE_KEY + "\r\n";
   diagnostics += "layer4_scan_status=" + AC_L4_SCAN_STATUS + "\r\n";
   diagnostics += "layer4_scan_duration_ms=" + IntegerToString((int)AC_L4_SCAN_DURATION_MS) + "\r\n";
   diagnostics += "layer4_eligible_open=" + IntegerToString(AC_L4_ELIGIBLE_OPEN) + "\r\n";
   diagnostics += "layer4_fresh_quotes=" + IntegerToString(AC_L4_FRESH_QUOTES) + "\r\n";
   diagnostics += "layer4_missing_tick=" + IntegerToString(AC_L4_MISSING_TICK) + "\r\n";
   diagnostics += "layer4_invalid_bidask=" + IntegerToString(AC_L4_INVALID_BIDASK) + "\r\n";
   diagnostics += "layer4_cache_key=" + AC_L4_CACHE_KEY + "\r\n";
   diagnostics += "layer4_refresh_key=" + AC_L4_REFRESH_KEY + "\r\n";
   diagnostics += "layer5_status=" + AC_L5_STATUS + "\r\n";
   diagnostics += "layer5_gate_policy=" + AC_L5_GATE_POLICY + "\r\n";
   diagnostics += "layer5_scanned_symbols=" + IntegerToString(AC_L5_SCANNED) + "\r\n";
   diagnostics += "layer5_gate_pass=" + IntegerToString(AC_L5_GATE_PASS) + "\r\n";
   diagnostics += "layer5_gate_blocked=" + IntegerToString(AC_L5_GATE_BLOCKED) + "\r\n";
   diagnostics += "layer5_blocked_closed_market=" + IntegerToString(AC_L5_BLOCK_CLOSED_MARKET) + "\r\n";
   diagnostics += "layer5_blocked_stale_quote=" + IntegerToString(AC_L5_BLOCK_STALE_QUOTE) + "\r\n";
   diagnostics += "layer5_blocked_missing_tick=" + IntegerToString(AC_L5_BLOCK_MISSING_TICK) + "\r\n";
   diagnostics += "layer5_blocked_invalid_bidask=" + IntegerToString(AC_L5_BLOCK_INVALID_BIDASK) + "\r\n";
   diagnostics += "layer5_blocked_missing_specs=" + IntegerToString(AC_L5_BLOCK_MISSING_SPECS) + "\r\n";
   diagnostics += "layer5_blocked_trade_mode=" + IntegerToString(AC_L5_BLOCK_TRADE_MODE) + "\r\n";
   diagnostics += "layer5_blocked_absurd_spread=" + IntegerToString(AC_L5_BLOCK_ABSURD_SPREAD) + "\r\n";
   diagnostics += "layer5_blocked_classification_review=" + IntegerToString(AC_L5_BLOCK_CLASSIFICATION_REVIEW) + "\r\n";
   diagnostics += "layer5_blocked_l2_not_ready=" + IntegerToString(AC_L5_BLOCK_L2_NOT_READY) + "\r\n";
   diagnostics += "layer5_blocked_l3_not_ready=" + IntegerToString(AC_L5_BLOCK_L3_NOT_READY) + "\r\n";
   diagnostics += "layer5_blocked_l4_not_ready=" + IntegerToString(AC_L5_BLOCK_L4_NOT_READY) + "\r\n";
   diagnostics += "layer5_last_upstream_key=" + AC_L5_LAST_UPSTREAM_KEY + "\r\n";
   diagnostics += "layer5_current_upstream_key=" + AC_L5UpstreamKey() + "\r\n";
   diagnostics += "layer5_calculation_owner=none_basic_gate_only\r\n";
   diagnostics += "layer5_gateway_required=false\r\n";
   diagnostics += "layer5_ranking_runtime=false\r\n";
   diagnostics += "layer5_selection_runtime=false\r\n";
   diagnostics += "layer5_trade_permission=false\r\n";
   diagnostics += "layer5_refresh_duration_ms=" + IntegerToString((int)AC_L5_REFRESH_DURATION_MS) + "\r\n";
   diagnostics += "layer2_to_layer3_contract=layer3_scans_known_open_and_closed_symbols_unknown_symbols_may_stop_earlier\r\n";
   diagnostics += "layer4_cutoff_rule=open_symbols_only_closed_symbols_stop_after_layer3_until_reopened\r\n";
   diagnostics += "layer4_owner_contract=runtime1_foundation_truth_symbolinfotick_marketwatch_only_no_history_no_dom_no_indicators_no_ranking_no_permission\r\n";
   diagnostics += "layer5_owner_contract=runtime1_basic_system_gate_consumes_l2_l3_l4_owner_packets_no_gateway_no_calculation_no_ranking_no_selection_no_permission\r\n";
   diagnostics += "gateway_contract=runtime3_global_daemon_watchdog_job_bus_result_acceptance_no_popup_no_board_dossier_authority_no_permission\r\n";
   diagnostics += "board_contract=near_instant_atomic_update_only_on_content_change\r\n";
   diagnostics += "workbench_contract=slower_developer_status_refresh_meta_non_trading_proof_not_trader_bloat\r\n";
   diagnostics += "statistics_contract=owner_gate_packet_not_board_recalculation_gateway_not_used_for_L0_L1_L2_L3_L4_or_L5\r\n";
   diagnostics += "symbol_packet_retry_limit=" + IntegerToString(AC_DOSSIER_SHELL_WRITE_RETRIES) + "\r\n";
   diagnostics += "timer_milliseconds=" + IntegerToString(AC_TIMER_MILLISECONDS) + "\r\n";
   diagnostics += "workbench_interval_heartbeats=" + IntegerToString(AC_WORKBENCH_INTERVAL_HEARTBEATS) + "\r\n";
   diagnostics += "l2_refresh_seconds=" + IntegerToString(AC_L2_REFRESH_SECONDS) + "\r\n";
   diagnostics += "l4_dossier_refresh_seconds=" + IntegerToString(AC_L4_DOSSIER_REFRESH_SECONDS) + "\r\n";
   diagnostics += "l4_top_list_refresh_seconds=" + IntegerToString(AC_L4_TOP_LIST_REFRESH_SECONDS) + "\r\n";
   diagnostics += "calculation_runtime_refresh_seconds=" + IntegerToString(AC_CALCULATION_RUNTIME_REFRESH_SECONDS) + "\r\n";
   diagnostics += "gateway_health_check_seconds=" + IntegerToString(AC_EXTERNAL_WORKER_HEALTH_CHECK_SECONDS) + "\r\n";
   diagnostics += "experimental_timer_100ms=" + IntegerToString(AC_EXPERIMENTAL_TIMER_100MS) + "\r\n";
   diagnostics += "experimental_timer_10ms=" + IntegerToString(AC_EXPERIMENTAL_TIMER_10MS) + "\r\n";
   diagnostics += "universe_lookup_contract_status=" + AC_UniverseContractStatus() + "\r\n";
   diagnostics += AC_UniverseDiagnosticsText();
   diagnostics += "logging_policy=" + AC_LOGGING_POLICY + "\r\n";
   diagnostics += "scope_check=L0_cached_universe_plus_L1_account_history_plus_L2_market_state_owner_gate_plus_L3_broker_specs_value_owner_gate_plus_L4_live_marketwatch_owner_gate_plus_L5_basic_system_gate_plus_runtime3_gateway_foundation_no_history_no_dom_no_ranking_no_selection_no_strategy_no_execution\r\n";
   phase_start = GetTickCount();
   AC_WriteResult diagnostics_write = AC_WriteTextFile(AC_DiagnosticsPath(), diagnostics);
   AC_AddMicroLog("write_diagnostics", phase_start, diagnostics_write.ok ? "complete" : "degraded");

   AC_FinalizeState(runtime_write, status_write, manifest_write, diagnostics_write, account_write, board_write, dossier_batch_write);

   phase_start = GetTickCount();
   board_write = AC_WriteTextFileIfChanged(AC_MarketBoardPath(), AC_BuildTraderBoardText(AC_SNAPSHOT, AC_L0_STATUS), AC_LAST_BOARD_TEXT, force_publication);
   runtime_write = AC_WriteTextFileIfChanged(AC_RuntimeStatusPath(), AC_BuildRuntimeStatusText(), AC_LAST_RUNTIME_STATUS_TEXT, force_publication);
   status_write = AC_WriteTextFileIfChanged(AC_WorkbenchStatusPath(), AC_BuildWorkbenchStatusText(account_write, AC_L0_STATUS), AC_LAST_WORKBENCH_STATUS_TEXT, force_publication);
   AC_AddMicroLog("republish_final_status_if_changed", phase_start, (board_write.ok && runtime_write.ok && status_write.ok) ? "complete" : "degraded");

   manifest = "";
   manifest += AC_ManifestRow("Market Board", board_write, AC_SNAPSHOT, "final_status_if_changed") + "\r\n";
   manifest += AC_ManifestRow("Dossier Universe", dossier_batch_write, AC_SNAPSHOT, "l0_l2_l3_l4_l5_dossier_universe_cached_or_run") + "\r\n";
   manifest += AC_ManifestRow("Runtime Status", runtime_write, AC_SNAPSHOT, "final_runtime_if_changed") + "\r\n";
   manifest += AC_ManifestRow("Workbench Status", status_write, AC_SNAPSHOT, "final_workbench_if_changed") + "\r\n";
   manifest += AC_ManifestRow("Account Status", account_write, AC_SNAPSHOT, "account_if_changed") + "\r\n";
   manifest += AC_ManifestRow("Diagnostics", diagnostics_write, AC_SNAPSHOT, "diagnostics") + "\r\n";
   manifest += AC_ManifestRow("Gateway Required", worker_required_write, AC_SNAPSHOT, "gateway_required_control") + "\r\n";
   manifest_write = AC_WriteTextFile(AC_ManifestPath(), manifest);
   AC_SNAPSHOT.manifest_status = manifest_write.ok ? manifest_write.status : manifest_write.status;
   AC_ApplyLateWriteStatus("Manifest Final", manifest_write);

   AC_WriteResult upgrade_addendum_write = AC_WriteTextFile(AC_UpgradeAddendumPath(), AC_UpgradeAddendumText(AC_SNAPSHOT) + "\r\n" + AC_Layer0FailureAddendumText());
   AC_SNAPSHOT.upgrade_addendum_status = upgrade_addendum_write.ok ? upgrade_addendum_write.status : upgrade_addendum_write.status;
   AC_ApplyLateWriteStatus("Upgrade Addendum", upgrade_addendum_write);

   AC_WriteResult micro_log_write = AC_WriteTextFile(AC_MicroLogPath(), AC_MICRO_LOG);
   AC_SNAPSHOT.micro_log_status = micro_log_write.ok ? micro_log_write.status : micro_log_write.status;
   AC_ApplyLateWriteStatus("Micro Log", micro_log_write);

   AC_WriteResult upgrade_log_write = AC_WriteTextFile(AC_UpgradeLogPath(), AC_UpgradeLogText(AC_SNAPSHOT, runtime_write, status_write, manifest_write, diagnostics_write));
   AC_SNAPSHOT.upgrade_log_status = upgrade_log_write.ok ? upgrade_log_write.status : upgrade_log_write.status;
   AC_ApplyLateWriteStatus("Upgrade Log", upgrade_log_write);

   manifest += AC_ManifestRow("Upgrade Addendum", upgrade_addendum_write, AC_SNAPSHOT, "upgrade_addendum") + "\r\n";
   manifest += AC_ManifestRow("Micro Log", micro_log_write, AC_SNAPSHOT, "micro_log") + "\r\n";
   manifest += AC_ManifestRow("Upgrade Log", upgrade_log_write, AC_SNAPSHOT, "upgrade_log") + "\r\n";
   AC_WriteResult manifest_final_write = AC_WriteTextFile(AC_ManifestPath(), manifest);
   AC_ApplyLateWriteStatus("Manifest With Micro Logs", manifest_final_write);
   AC_SNAPSHOT.manifest_status = manifest_final_write.ok ? manifest_final_write.status : manifest_final_write.status;
   AC_SNAPSHOT.layer_0_4_status = (board_write.ok && runtime_write.ok && status_write.ok && diagnostics_write.ok && manifest_write.ok && manifest_final_write.ok && upgrade_addendum_write.ok && micro_log_write.ok && upgrade_log_write.ok && dossier_batch_write.ok) ? "complete" : "complete_with_degraded";
   AC_SNAPSHOT.owner_status = AC_SNAPSHOT.file_publication_blocked ? "complete_with_degraded" : "complete";
   AC_WriteTextFileIfChanged(AC_MarketBoardPath(), AC_BuildTraderBoardText(AC_SNAPSHOT, AC_L0_STATUS), AC_LAST_BOARD_TEXT, false);
   AC_WriteTextFileIfChanged(AC_RuntimeStatusPath(), AC_BuildRuntimeStatusText(), AC_LAST_RUNTIME_STATUS_TEXT, false);
   AC_WriteTextFileIfChanged(AC_WorkbenchStatusPath(), AC_BuildWorkbenchStatusText(account_write, AC_L0_STATUS), AC_LAST_WORKBENCH_STATUS_TEXT, false);
}

int OnInit()
{
   AC_ResetSnapshot();
   ResetLastError();
   AC_TIMER_READY = EventSetMillisecondTimer(AC_TIMER_MILLISECONDS);
   AC_TIMER_SETUP_ERROR = AC_TIMER_READY ? 0 : GetLastError();
   AC_PublishRuntime0Full(true);
   return INIT_SUCCEEDED;
}

void OnTimer()
{
   if(AC_L2ShouldRunFullScan() || AC_L3ShouldRunFullScan() || AC_L4ShouldRunFullScan() || AC_ExternalWorkerShouldCheck())
   {
      AC_PublishRuntime0Full(false);
      return;
   }

   AC_HeartbeatBegin(AC_SNAPSHOT);
   AC_SNAPSHOT.runtime_state = "board_refresh_tick";
   AC_WriteResult board_write = AC_PublishMarketBoardOnly();
   AC_HeartbeatFinish(AC_SNAPSHOT);

   AC_TIMER_TICKS_SINCE_WORKBENCH++;
   if(AC_TIMER_TICKS_SINCE_WORKBENCH >= AC_WORKBENCH_INTERVAL_HEARTBEATS)
   {
      AC_TIMER_TICKS_SINCE_WORKBENCH = 0;
      AC_PublishRuntime0Full(false);
   }
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   string diagnostics = "system_name=" + AC_SYSTEM_NAME + "\r\n";
   diagnostics += "build_version=" + AC_BUILD_VERSION + "\r\n";
   diagnostics += "upgrade_id=" + AC_UPGRADE_ID + "\r\n";
   diagnostics += "runtime_owner=" + AC_RUNTIME0_OWNER + "\r\n";
   diagnostics += "publication_service_owner=" + AC_PUBLICATION_SERVICE_OWNER + "\r\n";
   diagnostics += "gateway_owner=" + AC_RUNTIME3_OWNER + "\r\n";
   diagnostics += "layer5_owner=" + AC_RUNTIME1_OWNER + "\r\n";
   diagnostics += "deinit_reason=" + IntegerToString(reason) + "\r\n";
   diagnostics += "generated_at=" + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS) + "\r\n";
   AC_WriteTextFile(AC_DiagnosticsPath(), diagnostics);
}
