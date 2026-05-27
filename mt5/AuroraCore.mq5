#property strict
#property version   "1.078"
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
   AC_AppendReason(surface + ":" + AC_WriteStatusFromResult(result));
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

AC_WriteResult AC_PublishAccountStatus()
{
   string text = AC_AccountTruthText();
   return AC_WriteTextFileIfChanged(AC_AccountStatusPath(), text, AC_LAST_ACCOUNT_STATUS_TEXT);
}

AC_WriteResult AC_PublishMarketBoard(const AC_Layer0StatusPacket &status)
{
   string text = AC_BuildTraderBoardText(AC_SNAPSHOT, status);
   return AC_WriteTextFileIfChanged(AC_MarketBoardPath(), text, AC_LAST_BOARD_TEXT);
}

AC_WriteResult AC_PublishManifest(const AC_WriteResult &board_write)
{
   string text = "";
   text += AC_ManifestRow("Market Board", board_write, AC_SNAPSHOT) + "\r\n";
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

AC_WriteResult AC_PublishDiagnostics(const AC_WriteResult &board_write)
{
   string text = "";
   text += AC_Layer0WorkbenchText(AC_L0_STATUS);
   text += "\r\nRuntime Status\r\n----------------------------------------\r\n";
   text += AC_RuntimeStatusText(AC_SNAPSHOT);
   text += "\r\nWrite Detail\r\n----------------------------------------\r\n";
   text += AC_WriteResultLine("Market Board", board_write) + "\r\n";
   return AC_WriteTextFileFastAtomicIfChanged(AC_DiagnosticsPath(), text, "diagnostics_changed_only");
}

AC_WriteResult AC_PublishUpgradeLog(const AC_WriteResult &board_write)
{
   string text = AC_UpgradeLogText(AC_SNAPSHOT, board_write, board_write, board_write, board_write);
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
   ResetLastError();
   EventSetMillisecondTimer(AC_TIMER_MILLISECONDS);
   AC_TIMER_SETUP_ERROR = GetLastError();
   AC_TIMER_READY = (AC_TIMER_SETUP_ERROR == 0);
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   EventKillTimer();
}

void OnTick()
{
}

void OnTimer()
{
   if(AC_TIMER_BUSY)
   {
      AC_TIMER_BUSY_SKIP_COUNT++;
      return;
   }
   AC_TIMER_BUSY = true;
   uint timer_start = GetTickCount();
   AC_ResetSnapshot();
   string detail = "";
   AC_SNAPSHOT.runtime_state = "heartbeat_ok";
   AC_SNAPSHOT.terminal_connected = TerminalInfoInteger(TERMINAL_CONNECTED) ? "true" : "false";

   uint start = GetTickCount();
   AC_SNAPSHOT.folder_create_status = AC_EnsureRootFolders();
   AC_AddMicroLog("AC_EnsureRootFolders", start, AC_SNAPSHOT.folder_create_status);

   start = GetTickCount();
   AC_SNAPSHOT.placeholder_status = AC_CleanupLegacyPlaceholderFiles();
   AC_AddMicroLog("AC_CleanupLegacyPlaceholderFiles", start, AC_SNAPSHOT.placeholder_status);

   start = GetTickCount();
   AC_WriteResult account_status = AC_PublishAccountStatus();
   AC_AddMicroLog("AC_PublishAccountStatus", start, account_status.status);
   AC_RecordWriteProblem("account_status", account_status);

   // Critical Runtime 1 -> Runtime 7 bridge.
   // This existing owner invokes L2/L3/L4/L5 dependency refreshes and physically
   // publishes the per-symbol Dossier files into Dossiers/Open, Dossiers/Closed,
   // and Dossiers/Unknown. Without this call the EA compiles as a thin Board shell
   // and the Board can show L2 pending with zero Dossier files.
   start = GetTickCount();
   AC_WriteResult dossier_batch = AC_PublishLayer0DossierBatch(AC_L0_STATUS);
   AC_SNAPSHOT.owner_status = dossier_batch.status;
   AC_AddMicroLog("AC_PublishLayer0DossierBatch", start, dossier_batch.status);
   AC_MergeWriteResult("dossier_batch", dossier_batch, detail);

   start = GetTickCount();
   AC_WriteResult board = AC_PublishMarketBoard(AC_L0_STATUS);
   AC_SNAPSHOT.fileio_status = board.status;
   AC_AddMicroLog("AC_PublishMarketBoard", start, board.status);
   AC_RecordWriteProblem("market_board", board);

   start = GetTickCount();
   AC_WriteResult manifest = AC_PublishManifest(board);
   AC_SNAPSHOT.manifest_status = manifest.status;
   AC_AddMicroLog("AC_PublishManifest", start, manifest.status);
   AC_MergeWriteResult("manifest", manifest, detail);

   start = GetTickCount();
   AC_WriteResult telemetry = AC_PublishTelemetry(board);
   AC_SNAPSHOT.telemetry_status = telemetry.status;
   AC_AddMicroLog("AC_PublishTelemetry", start, telemetry.status);
   AC_MergeWriteResult("telemetry", telemetry, detail);

   start = GetTickCount();
   AC_WriteResult diagnostics = AC_PublishDiagnostics(board);
   AC_SNAPSHOT.diagnostics_status = diagnostics.status;
   AC_AddMicroLog("AC_PublishDiagnostics", start, diagnostics.status);
   AC_MergeWriteResult("diagnostics", diagnostics, detail);

   start = GetTickCount();
   AC_WriteResult upgrade_log = AC_PublishUpgradeLog(board);
   AC_SNAPSHOT.upgrade_log_status = upgrade_log.status;
   AC_AddMicroLog("AC_PublishUpgradeLog", start, upgrade_log.status);
   AC_MergeWriteResult("upgrade_log", upgrade_log, detail);

   start = GetTickCount();
   AC_WriteResult upgrade_addendum = AC_PublishUpgradeAddendum(detail);
   AC_SNAPSHOT.upgrade_addendum_status = upgrade_addendum.status;
   AC_AddMicroLog("AC_PublishUpgradeAddendum", start, upgrade_addendum.status);
   AC_RecordWriteProblem("upgrade_addendum", upgrade_addendum);

   AC_LAST_TIMER_DURATION_MS = GetTickCount() - timer_start;
   start = GetTickCount();
   AC_WriteResult runtime_status = AC_PublishRuntimeStatus(AC_SNAPSHOT);
   AC_AddMicroLog("AC_PublishRuntimeStatus", start, runtime_status.status);
   AC_SNAPSHOT.micro_log_status = AC_WriteTextFileIfChanged(AC_MicroLogPath(), AC_MICRO_LOG, AC_LAST_RUNTIME_STATUS_TEXT).status;
   AC_TIMER_TICKS_SINCE_WORKBENCH++;
   AC_TIMER_BUSY = false;
}
