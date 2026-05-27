#property strict
#property version   "1.086"
#property description "AURORA CORE - runtime spine, foundation truth, gateway support"

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
bool AC_PLACEHOLDER_CLEANUP_DONE = false;
int  AC_TIMER_SETUP_ERROR = 0;
int  AC_TIMER_TICKS_SINCE_WORKBENCH = 0;
int  AC_TIMER_BUSY_SKIP_COUNT = 0;
uint AC_TIMER_BUSY_STARTED_MS = 0;
uint AC_LAST_TIMER_DURATION_MS = 0;
string AC_MICRO_LOG = "";
string AC_LAST_BOARD_TEXT = "";
string AC_LAST_RUNTIME_STATUS_TEXT = "";
string AC_LAST_WORKBENCH_STATUS_TEXT = "";
string AC_LAST_ACCOUNT_STATUS_TEXT = "";
string AC_LAST_ACCOUNT_ROOT_STATUS_TEXT = "";
string AC_LAST_MICRO_LOG_TEXT = "";
string AC_LAST_WORKBENCH_SURFACE_SYNC_KEY = "";

void AC_AppendReason(const string reason)
{
   if(reason == "") return;
   if(AC_SNAPSHOT.blocked_reason == "") AC_SNAPSHOT.blocked_reason = reason;
   else AC_SNAPSHOT.blocked_reason += ";" + reason;
}

void AC_AppendDegradedReason(const string reason)
{
   if(reason == "") return;
   if(AC_SNAPSHOT.degraded_reason == "") AC_SNAPSHOT.degraded_reason = reason;
   else AC_SNAPSHOT.degraded_reason += ";" + reason;
}

void AC_SetLayer0Status(const string l01, const string l02, const string l04)
{
   AC_SNAPSHOT.layer_0_1_status = l01;
   AC_SNAPSHOT.layer_0_2_status = l02;
   AC_SNAPSHOT.layer_0_4_status = l04;
}

void AC_ResetSnapshot()
{
   AC_SNAPSHOT.heartbeat_id = 0;
   AC_SNAPSHOT.timer_started_ms = 0;
   AC_SNAPSHOT.timer_finished_ms = 0;
   AC_SNAPSHOT.timer_duration_ms = 0;
   AC_SNAPSHOT.over_budget = false;
   AC_SNAPSHOT.timer_busy_skip_count = AC_TIMER_BUSY_SKIP_COUNT;
   AC_SNAPSHOT.timer_busy_age_ms = 0;
   AC_SNAPSHOT.timer_busy_stale_flag = false;
   AC_SNAPSHOT.timer_duration_gt_period_flag = false;
   AC_SNAPSHOT.timer_pressure_state = "not_started";
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
   AC_SNAPSHOT.owner_status = "running";
   AC_SNAPSHOT.layer_0_1_status = "pending";
   AC_SNAPSHOT.layer_0_2_status = "pending";
   AC_SNAPSHOT.layer_0_4_status = "pending";
   AC_SNAPSHOT.file_publication_blocked = false;
   AC_SNAPSHOT.degraded_reason = "";
   AC_SNAPSHOT.blocked_reason = "";
   AC_MICRO_LOG = "schema_name=micro_log_snapshot\r\nschema_version=v0.7\r\n";
   AC_Layer0InitStatus(AC_L0_STATUS);
   AC_L0_STATUS.trade_permission = false;
   AC_L0_STATUS.auto_trade_allowed = false;
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
   AC_AppendReason(surface + ":" + AC_WriteStatusFromResult(result));
}

void AC_RecordDegradedWrite(const string surface, const AC_WriteResult &result)
{
   if(result.ok) return;
   AC_AppendDegradedReason(surface + ":" + AC_WriteStatusFromResult(result));
}

void AC_MergeWriteResult(const string surface, const AC_WriteResult &result, string &detail)
{
   detail += AC_WriteResultLine(surface, result) + "\r\n";
   AC_RecordWriteProblem(surface, result);
}

string AC_EnsureRootFolders()
{
   string detail = "";
   bool ok = AC_EnsureRuntimeFolders(detail);
   if(ok)
      return "folder_create_ok|" + detail;
   return "folder_create_failed|" + detail;
}

void AC_ServiceTradeJournal()
{
   if(!AC_TRADE_JOURNAL_READY)
   {
      AC_TradeJournalInit();
      return;
   }

   if(AC_L1_READY)
      AC_TradeJournalPublishOneHistoricalTrade();
}

string AC_AccountStatusRootMirrorPath()
{
   return AC_RootFolder() + "\\Account Status.txt";
}

AC_WriteResult AC_CombineAccountStatusWrite(const AC_WriteResult &workbench_write,
                                            const AC_WriteResult &root_write)
{
   if(workbench_write.ok && root_write.ok)
      return root_write;
   string detail = "workbench=" + AC_WriteStatusFromResult(workbench_write) + "|root=" + AC_WriteStatusFromResult(root_write);
   string status = "account_status_partial_publication";
   if(!workbench_write.ok && !root_write.ok)
      status = "account_status_publication_failed";
   return AC_MakeSyntheticWriteResult(root_write.final_path, false, status, root_write.final_size, detail);
}

AC_WriteResult AC_PublishAccountStatus()
{
   string text = AC_AccountTruthText();
   AC_WriteResult workbench_write = AC_WriteTextFileIfChanged(AC_AccountStatusPath(), text, AC_LAST_ACCOUNT_STATUS_TEXT);
   AC_WriteResult root_write = AC_WriteTextFileIfChanged(AC_AccountStatusRootMirrorPath(), text, AC_LAST_ACCOUNT_ROOT_STATUS_TEXT);
   return AC_CombineAccountStatusWrite(workbench_write, root_write);
}

AC_WriteResult AC_PublishMarketBoard(const AC_Layer0StatusPacket &status)
{
   string text = AC_BuildTraderBoardText(AC_SNAPSHOT, status);
   return AC_WriteTextFileIfChanged(AC_MarketBoardPath(), text, AC_LAST_BOARD_TEXT);
}

AC_WriteResult AC_PublishManifest(const AC_WriteResult &account_status,
                                  const AC_WriteResult &dossier_batch,
                                  const AC_WriteResult &worker_required,
                                  const AC_WriteResult &board_write)
{
   string text = "";
   text += AC_ManifestRow("Account Status", account_status, AC_SNAPSHOT) + "\r\n";
   text += AC_ManifestRow("Foundation Dossier Batch", dossier_batch, AC_SNAPSHOT) + "\r\n";
   text += AC_ManifestRow("Gateway worker_required", worker_required, AC_SNAPSHOT) + "\r\n";
   text += AC_ManifestRow("Market Board", board_write, AC_SNAPSHOT) + "\r\n";
   text += AC_TradeJournalStatusText();
   text += AC_OwnerStatusRow(AC_SNAPSHOT) + "\r\n";
   text += AC_LayerStatusRows(AC_SNAPSHOT);
   return AC_WriteTextFileFastAtomicIfChanged(AC_ManifestPath(), text, "manifest_changed_only");
}

AC_WriteResult AC_PublishTelemetry(const AC_WriteResult &board_write)
{
   string text = "";
   text += AC_RuntimeTelemetryRow(AC_SNAPSHOT) + "\r\n";
   text += AC_WriteResultLine("Market Board", board_write) + "\r\n";
   text += AC_HeartbeatStatusText(AC_SNAPSHOT);
   return AC_WriteTextFileIfChanged(AC_WorkbenchStatusPath(), text, AC_LAST_WORKBENCH_STATUS_TEXT);
}

AC_WriteResult AC_PublishDiagnostics(const AC_WriteResult &account_status,
                                     const AC_WriteResult &dossier_batch,
                                     const AC_WriteResult &worker_required,
                                     const AC_WriteResult &board_write)
{
   string text = "";
   text += AC_Layer0WorkbenchText(AC_L0_STATUS);
   text += "\r\nRuntime Status\r\n----------------------------------------\r\n";
   text += AC_RuntimeStatusText(AC_SNAPSHOT);
   text += AC_TradeJournalWorkbenchSection(AC_TRADE_JOURNAL_STATUS);
   text += "\r\nWrite Detail\r\n----------------------------------------\r\n";
   text += AC_WriteResultLine("Account Status", account_status) + "\r\n";
   text += AC_WriteResultLine("Foundation Dossier Batch", dossier_batch) + "\r\n";
   text += AC_WriteResultLine("Gateway worker_required", worker_required) + "\r\n";
   text += AC_WriteResultLine("Market Board", board_write) + "\r\n";
   return AC_WriteTextFileFastAtomicIfChanged(AC_DiagnosticsPath(), text, "diagnostics_changed_only");
}

AC_WriteResult AC_PublishUpgradeLog(const AC_WriteResult &runtime_write,
                                    const AC_WriteResult &telemetry_write,
                                    const AC_WriteResult &manifest_write,
                                    const AC_WriteResult &diagnostics_write)
{
   string text = AC_UpgradeLogText(AC_SNAPSHOT, runtime_write, telemetry_write, manifest_write, diagnostics_write);
   return AC_WriteTextFileFastAtomicIfChanged(AC_UpgradeLogPath(), text, "upgrade_log_changed_only");
}

AC_WriteResult AC_PublishUpgradeAddendum(const string detail)
{
   string text = AC_UpgradeAddendumText(AC_SNAPSHOT);
   text += "write_detail=\r\n" + detail;
   return AC_WriteTextFileFastAtomicIfChanged(AC_UpgradeAddendumPath(), text, "upgrade_addendum_changed_only");
}

AC_WriteResult AC_PublishRuntimeStatus(const AC_Runtime0Snapshot &snapshot)
{
   string text = AC_RuntimeStatusText(snapshot);
   return AC_WriteTextFileIfChanged(AC_RuntimeStatusPath(), text, AC_LAST_RUNTIME_STATUS_TEXT);
}

int OnInit()
{
   AC_EnsureRootFolders();
   AC_TradeJournalInit();
   ResetLastError();
   EventSetMillisecondTimer(AC_TIMER_MILLISECONDS);
   AC_TIMER_SETUP_ERROR = GetLastError();
   AC_TIMER_READY = (AC_TIMER_SETUP_ERROR == 0);
   if(!AC_TIMER_READY)
   {
      AC_ResetSnapshot();
      AC_SNAPSHOT.runtime_state = "init_degraded_timer_not_set";
      AC_SNAPSHOT.layer_0_1_status = "accepted";
      AC_SNAPSHOT.layer_0_2_status = "failed_timer_not_set";
      AC_SNAPSHOT.layer_0_4_status = "degraded_init_status_only";
      AC_SNAPSHOT.terminal_connected = TerminalInfoInteger(TERMINAL_CONNECTED) ? "true" : "false";
      AC_AppendReason("timer_setup_error_" + IntegerToString(AC_TIMER_SETUP_ERROR));
      AC_PublishRuntimeStatus(AC_SNAPSHOT);
   }
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   AC_ResetSnapshot();
   AC_SNAPSHOT.runtime_state = "deinitialized";
   AC_SNAPSHOT.generated_at = TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS);
   AC_SNAPSHOT.terminal_connected = TerminalInfoInteger(TERMINAL_CONNECTED) ? "true" : "false";
   AC_SetLayer0Status("accepted", "deinitialized", "deinitialized_status_written");
   AC_AppendDegradedReason("deinit_reason=" + IntegerToString(reason));
   AC_PublishRuntimeStatus(AC_SNAPSHOT);
}

void OnTick()
{
}

void OnTimer()
{
   if(AC_TIMER_BUSY)
   {
      AC_TIMER_BUSY_SKIP_COUNT++;
      uint busy_age = (AC_TIMER_BUSY_STARTED_MS > 0) ? (GetTickCount() - AC_TIMER_BUSY_STARTED_MS) : 0;
      if(busy_age > (uint)AC_TIMER_STUCK_WARN_MS)
      {
         AC_SNAPSHOT.timer_busy_skip_count = AC_TIMER_BUSY_SKIP_COUNT;
         AC_SNAPSHOT.timer_busy_age_ms = busy_age;
         AC_SNAPSHOT.timer_busy_stale_flag = true;
         AC_SNAPSHOT.timer_pressure_state = "stale_busy";
      }
      return;
   }

   AC_TIMER_BUSY = true;
   AC_TIMER_BUSY_STARTED_MS = GetTickCount();
   AC_ResetSnapshot();
   AC_SNAPSHOT.timer_busy_skip_count = AC_TIMER_BUSY_SKIP_COUNT;
   AC_HeartbeatBegin(AC_SNAPSHOT);
   AC_SetLayer0Status("running", "running", "pending");
   string detail = "";
   AC_SNAPSHOT.terminal_connected = TerminalInfoInteger(TERMINAL_CONNECTED) ? "true" : "false";

   uint start = GetTickCount();
   AC_SNAPSHOT.folder_create_status = AC_EnsureRootFolders();
   AC_AddMicroLog("AC_EnsureRootFolders", start, AC_SNAPSHOT.folder_create_status);
   AC_SNAPSHOT.layer_0_1_status = (StringFind(AC_SNAPSHOT.folder_create_status, "folder_create_ok") == 0) ? "accepted" : "degraded_folder_create";

   start = GetTickCount();
   if(!AC_PLACEHOLDER_CLEANUP_DONE)
   {
      AC_SNAPSHOT.placeholder_status = AC_CleanupLegacyPlaceholderFiles();
      AC_PLACEHOLDER_CLEANUP_DONE = true;
   }
   else
   {
      AC_SNAPSHOT.placeholder_status = "skipped_already_done_this_session";
   }
   AC_AddMicroLog("AC_CleanupLegacyPlaceholderFiles", start, AC_SNAPSHOT.placeholder_status);

   start = GetTickCount();
   AC_WriteResult account_status = AC_PublishAccountStatus();
   AC_AddMicroLog("AC_PublishAccountStatus", start, account_status.status);
   AC_RecordWriteProblem("account_status", account_status);

   start = GetTickCount();
   AC_ServiceTradeJournal();
   AC_AddMicroLog("AC_ServiceTradeJournal", start, AC_TRADE_JOURNAL_STATUS.status + ":" + AC_TRADE_JOURNAL_STATUS.historical_generator_status);

   // Critical Runtime 1 -> Runtime 7 bridge.
   // This existing owner invokes L2/L3/L4/L5 dependency refreshes and physically
   // publishes the per-symbol Dossier files into Dossiers/Open, Dossiers/Closed,
   // and Dossiers/Unknown. Runtime 1 owns the truth; Layer 0 only orchestrates the pass.
   start = GetTickCount();
   AC_WriteResult dossier_batch = AC_PublishLayer0DossierBatch(AC_L0_STATUS);
   AC_AddMicroLog("AC_PublishLayer0DossierBatch", start, dossier_batch.status);
   AC_MergeWriteResult("dossier_batch", dossier_batch, detail);

   start = GetTickCount();
   AC_WriteResult worker_required = AC_WriteExternalWorkerRequired();
   AC_AddMicroLog("AC_WriteExternalWorkerRequired", start, worker_required.status);
   AC_RecordWriteProblem("gateway_worker_required", worker_required);

   start = GetTickCount();
   AC_RefreshExternalWorkerStatus();
   AC_AddMicroLog("AC_RefreshExternalWorkerStatus", start, AC_EXTERNAL_WORKER_STATUS.result_status);
   if(AC_EXTERNAL_WORKER_STATUS.result_validation_status == "Rejected")
      AC_RecordDegradedWrite("gateway_result", AC_MakeSyntheticWriteResult(AC_ExternalWorkerResultPath(), false, AC_EXTERNAL_WORKER_STATUS.result_validation_status, 0, AC_EXTERNAL_WORKER_STATUS.result_validation_reason));

   start = GetTickCount();
   AC_WriteResult board = AC_PublishMarketBoard(AC_L0_STATUS);
   AC_SNAPSHOT.fileio_status = board.status;
   AC_AddMicroLog("AC_PublishMarketBoard", start, board.status);
   AC_RecordWriteProblem("market_board", board);

   AC_SNAPSHOT.layer_0_2_status = "running_finish_pending";
   AC_SNAPSHOT.layer_0_4_status = "running_publication_pending";
   AC_HeartbeatFinish(AC_SNAPSHOT);
   AC_LAST_TIMER_DURATION_MS = AC_SNAPSHOT.timer_duration_ms;

   start = GetTickCount();
   AC_WriteResult runtime_status = AC_PublishRuntimeStatus(AC_SNAPSHOT);
   AC_AddMicroLog("AC_PublishRuntimeStatus", start, runtime_status.status);

   start = GetTickCount();
   AC_WriteResult manifest = AC_PublishManifest(account_status, dossier_batch, worker_required, board);
   AC_SNAPSHOT.manifest_status = manifest.status;
   AC_AddMicroLog("AC_PublishManifest", start, manifest.status);
   AC_MergeWriteResult("manifest", manifest, detail);

   start = GetTickCount();
   AC_WriteResult telemetry = AC_PublishTelemetry(board);
   AC_SNAPSHOT.telemetry_status = telemetry.status;
   AC_AddMicroLog("AC_PublishTelemetry", start, telemetry.status);
   AC_MergeWriteResult("telemetry", telemetry, detail);

   start = GetTickCount();
   AC_WriteResult diagnostics = AC_PublishDiagnostics(account_status, dossier_batch, worker_required, board);
   AC_SNAPSHOT.diagnostics_status = diagnostics.status;
   AC_AddMicroLog("AC_PublishDiagnostics", start, diagnostics.status);
   AC_MergeWriteResult("diagnostics", diagnostics, detail);

   AC_SNAPSHOT.layer_0_4_status = (manifest.ok && telemetry.ok && diagnostics.ok) ? "accepted" : "degraded_publication_status";
   AC_SNAPSHOT.layer_0_2_status = AC_SNAPSHOT.timer_duration_gt_period_flag ? "degraded_over_period" : "accepted";
   AC_SNAPSHOT.owner_status = AC_SNAPSHOT.file_publication_blocked ? "degraded_publication_problem" : "accepted";

   start = GetTickCount();
   runtime_status = AC_PublishRuntimeStatus(AC_SNAPSHOT);
   AC_AddMicroLog("AC_PublishRuntimeStatusFinal", start, runtime_status.status);

   start = GetTickCount();
   AC_WriteResult upgrade_log = AC_PublishUpgradeLog(runtime_status, telemetry, manifest, diagnostics);
   AC_SNAPSHOT.upgrade_log_status = upgrade_log.status;
   AC_AddMicroLog("AC_PublishUpgradeLog", start, upgrade_log.status);
   AC_MergeWriteResult("upgrade_log", upgrade_log, detail);

   start = GetTickCount();
   AC_WriteResult upgrade_addendum = AC_PublishUpgradeAddendum(detail);
   AC_SNAPSHOT.upgrade_addendum_status = upgrade_addendum.status;
   AC_AddMicroLog("AC_PublishUpgradeAddendum", start, upgrade_addendum.status);
   AC_RecordWriteProblem("upgrade_addendum", upgrade_addendum);

   start = GetTickCount();
   AC_WriteResult micro_log = AC_WriteTextFileIfChanged(AC_MicroLogPath(), AC_MICRO_LOG, AC_LAST_MICRO_LOG_TEXT);
   AC_SNAPSHOT.micro_log_status = micro_log.status;
   AC_AddMicroLog("AC_PublishMicroLog", start, micro_log.status);

   AC_TIMER_TICKS_SINCE_WORKBENCH++;
   AC_TIMER_BUSY = false;
   AC_TIMER_BUSY_STARTED_MS = 0;
}