#property strict
#property version   "1.050"
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
#include "runtime_owners/runtime_1_foundation_truth_owner/trade_journal_forensics/AC_TradeJournalOwner.mqh"
#include "runtime_owners/runtime_3_external_calculation_worker_owner/AC_ExternalWorkerOwner.mqh"
#include "runtime_owners/runtime_7_publication_owner/publication_renderers/AC_PublicationRenderers.mqh"

AC_Runtime0Snapshot AC_SNAPSHOT;
AC_Layer0StatusPacket AC_L0_STATUS;
bool AC_TIMER_READY = false;
bool AC_TIMER_BUSY = false;
int  AC_TIMER_SETUP_ERROR = 0;
int  AC_TIMER_TICKS_SINCE_WORKBENCH = 0;
int  AC_TIMER_BUSY_SKIP_COUNT = 0;
uint AC_LAST_TIMER_DURATION_MS = 0;
string AC_MICRO_LOG = "";
string AC_LAST_BOARD_TEXT = "";
string AC_LAST_RUNTIME_STATUS_TEXT = "";
string AC_LAST_WORKBENCH_STATUS_TEXT = "";
string AC_LAST_ACCOUNT_STATUS_TEXT = "";
string AC_LAST_WORKBENCH_SURFACE_SYNC_KEY = "";

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
      + AC_TradeJournalStatusRow(AC_TRADE_JOURNAL_STATUS) + "\r\n"
      + AC_ExternalWorkerStatusRow() + "\r\n"
      + AC_UniverseStatusRow() + "\r\n\r\n"
      + AC_Layer0WorkbenchText(layer0_status)
      + AC_Layer1WorkbenchSection()
      + AC_TradeJournalWorkbenchSection(AC_TRADE_JOURNAL_STATUS)
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

string AC_L7SurfaceSyncKeyFromRenderedState()
{
   return AC_L7_STATUS
      + "|validation=" + AC_L7_VALIDATION_STATUS
      + "|accepted=" + AC_L7BoolKv(AC_L7_RANKED_ACCEPTED)
      + "|input_rows=" + IntegerToString(AC_L7_INPUT_ROWS_RENDERED)
      + "|l5_pass=" + IntegerToString(AC_L7_EXPORT_L5_PASS_RENDERED)
      + "|ranked_rows=" + IntegerToString(AC_L7_RANKED_ROWS_RENDERED)
      + "|counts=" + AC_L7BoolKv(AC_L7_GENERATION_COUNTS_OK_RENDERED)
      + "|identity=" + AC_L7BoolKv(AC_L7_GENERATION_IDENTITY_OK_RENDERED)
      + "|symbol_files=" + IntegerToString(AC_L7_SYMBOL_RANK_FILES_ACTUAL_RENDERED)
      + "|session=" + AC_L7_CURRENT_GLOBAL_SESSION_RENDERED
      + "|input_checksum=" + AC_L7_INPUT_PAYLOAD_CHECKSUM_RENDERED
      + "|ranked_checksum=" + AC_L7_RANKED_PAYLOAD_CHECKSUM_RENDERED;
}

string AC_L8SurfaceSyncKeyFromRenderedState()
{
   return AC_L8_STATUS
      + "|validation=" + AC_L8_VALIDATION_STATUS
      + "|accepted=" + AC_L8BoolKv(AC_L8_RANKED_ACCEPTED)
      + "|input_rows=" + IntegerToString(AC_L8_INPUT_ROWS_RENDERED)
      + "|l5_pass=" + IntegerToString(AC_L8_EXPORT_L5_PASS_RENDERED)
      + "|ranked_rows=" + IntegerToString(AC_L8_RANKED_ROWS_RENDERED)
      + "|counts=" + AC_L8BoolKv(AC_L8_GENERATION_COUNTS_OK_RENDERED)
      + "|identity=" + AC_L8BoolKv(AC_L8_GENERATION_IDENTITY_OK_RENDERED)
      + "|symbol_files=" + IntegerToString(AC_L8_SYMBOL_RANK_FILES_ACTUAL_RENDERED)
      + "|ohlc_min=" + IntegerToString(AC_L8_OHLC_MIN_READY_RENDERED)
      + "|m5=" + IntegerToString(AC_L8_OHLC_M5_READY_RENDERED)
      + "|m15=" + IntegerToString(AC_L8_OHLC_M15_READY_RENDERED)
      + "|h1=" + IntegerToString(AC_L8_OHLC_H1_READY_RENDERED)
      + "|h4=" + IntegerToString(AC_L8_OHLC_H4_READY_RENDERED)
      + "|input_checksum=" + AC_L8_INPUT_PAYLOAD_CHECKSUM_RENDERED
      + "|ranked_checksum=" + AC_L8_RANKED_PAYLOAD_CHECKSUM_RENDERED;
}

string AC_SurfaceSyncKeyFromRenderedState()
{
   return "L7{" + AC_L7SurfaceSyncKeyFromRenderedState() + "}|L8{" + AC_L8SurfaceSyncKeyFromRenderedState() + "}";
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
   AC_WriteResult board_write = AC_WriteTextFileIfChanged(AC_MarketBoardPath(), board_text, AC_LAST_BOARD_TEXT, false);

   string surface_sync_key = AC_SurfaceSyncKeyFromRenderedState();
   if(surface_sync_key != AC_LAST_WORKBENCH_SURFACE_SYNC_KEY)
   {
      AC_WriteResult synthetic_account_write = AC_MakeSyntheticWriteResult(AC_AccountStatusPath(), true, "unchanged_no_write", (ulong)StringLen(AC_LAST_ACCOUNT_STATUS_TEXT), "board_tick_surface_sync_no_account_status_write");
      AC_WriteResult workbench_sync_write = AC_WriteTextFileIfChanged(AC_WorkbenchStatusPath(), AC_BuildWorkbenchStatusText(synthetic_account_write, AC_L0_STATUS), AC_LAST_WORKBENCH_STATUS_TEXT, false);
      if(workbench_sync_write.ok)
         AC_LAST_WORKBENCH_SURFACE_SYNC_KEY = surface_sync_key;
   }

   return board_write;
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
   bool trade_journal_ok = AC_TradeJournalInit();
   if(!trade_journal_ok)
   {
      AC_SNAPSHOT.file_publication_blocked = true;
      AC_AppendReason("trade_journal=" + AC_TRADE_JOURNAL_STATUS.route_status);
   }
   AC_AddMicroLog("trade_journal_skeleton_init", phase_start, AC_TRADE_JOURNAL_STATUS.status);

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