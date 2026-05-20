#property strict
#property version   "000.010"
#property description "AURORA CORE — Runtime 0 first source slice"

#include "core/AC_Config.mqh"
#include "core/AC_CommonTypes.mqh"
#include "runtime_owners/runtime_7_publication_owner/publication_routes/AC_ServerPaths.mqh"
#include "runtime_owners/runtime_7_publication_owner/publication_fileio/AC_FileIO.mqh"
#include "runtime_owners/runtime_0_governance_internal_control/layer_0_1_startup_runtime_identity/AC_RuntimeIdentity.mqh"
#include "runtime_owners/runtime_0_governance_internal_control/layer_0_2_scheduler_heartbeat_breathing/AC_Heartbeat.mqh"
#include "runtime_owners/runtime_0_governance_internal_control/layer_0_4_governance_manifest_telemetry/AC_GovernanceRows.mqh"

AC_Runtime0Snapshot AC_SNAPSHOT;

void AC_ResetSnapshot()
{
   AC_SNAPSHOT.runtime_state = "not_started";
   AC_SNAPSHOT.terminal_connected = "unknown";
   AC_SNAPSHOT.route_root = AC_RootFolder();
   AC_SNAPSHOT.folder_create_status = "not_attempted";
   AC_SNAPSHOT.fileio_status = "not_attempted";
   AC_SNAPSHOT.manifest_status = "not_attempted";
   AC_SNAPSHOT.telemetry_status = "not_attempted";
   AC_SNAPSHOT.owner_status = "not_started";
   AC_SNAPSHOT.layer_0_1_status = "not_started";
   AC_SNAPSHOT.layer_0_2_status = "not_started";
   AC_SNAPSHOT.layer_0_4_status = "not_started";
   AC_SNAPSHOT.file_publication_blocked = false;
   AC_SNAPSHOT.degraded_reason = "";
   AC_SNAPSHOT.blocked_reason = "";
}

void AC_PublishRuntime0()
{
   AC_ResetSnapshot();
   AC_HeartbeatBegin(AC_SNAPSHOT);

   AC_SNAPSHOT.terminal_connected = TerminalInfoInteger(TERMINAL_CONNECTED) ? "true" : "false";
   AC_SNAPSHOT.layer_0_1_status = "complete";
   AC_SNAPSHOT.layer_0_2_status = "filling";
   AC_SNAPSHOT.layer_0_4_status = "filling";
   AC_SNAPSHOT.owner_status = "filling";

   string folder_detail = "";
   bool folders_ok = AC_EnsureRuntimeFolders(folder_detail);
   AC_SNAPSHOT.folder_create_status = folders_ok ? "folder_create_ok" : "folder_create_failed";
   if(!folders_ok)
   {
      AC_SNAPSHOT.file_publication_blocked = true;
      AC_SNAPSHOT.blocked_reason = folder_detail;
   }

   AC_HeartbeatFinish(AC_SNAPSHOT);
   AC_SNAPSHOT.layer_0_2_status = AC_SNAPSHOT.over_budget ? "complete_with_degraded" : "complete";

   string runtime_status = AC_RuntimeIdentityText();
   runtime_status += AC_RuntimeStatusText(AC_SNAPSHOT);
   runtime_status += AC_HeartbeatStatusText(AC_SNAPSHOT);

   AC_WriteResult runtime_write = AC_WriteTextFile(AC_RuntimeStatusPath(), runtime_status);
   AC_SNAPSHOT.fileio_status = runtime_write.ok ? "fileio_ok" : runtime_write.status;
   if(!runtime_write.ok)
   {
      AC_SNAPSHOT.file_publication_blocked = true;
      AC_SNAPSHOT.blocked_reason = runtime_write.detail;
   }

   string telemetry = AC_RuntimeTelemetryRow(AC_SNAPSHOT) + "\r\n";
   AC_WriteResult telemetry_write = AC_WriteTextFile(AC_WorkbenchStatusPath(), telemetry + AC_OwnerStatusRow(AC_SNAPSHOT) + "\r\n" + AC_LayerStatusRows(AC_SNAPSHOT));
   AC_SNAPSHOT.telemetry_status = telemetry_write.ok ? "telemetry_written" : telemetry_write.status;

   string manifest = "";
   manifest += AC_ManifestRow("Runtime Status", runtime_write, AC_SNAPSHOT) + "\r\n";
   manifest += AC_ManifestRow("Workbench Status", telemetry_write, AC_SNAPSHOT) + "\r\n";
   AC_WriteResult manifest_write = AC_WriteTextFile(AC_ManifestPath(), manifest);
   AC_SNAPSHOT.manifest_status = manifest_write.ok ? "manifest_written" : manifest_write.status;

   string diagnostics = "";
   diagnostics += "system_name=" + AC_SYSTEM_NAME + "\r\n";
   diagnostics += "runtime_owner=" + AC_RUNTIME0_OWNER + "\r\n";
   diagnostics += "folder_detail=" + folder_detail + "\r\n";
   diagnostics += "runtime_write=" + AC_WriteResultLine("Runtime Status", runtime_write) + "\r\n";
   diagnostics += "telemetry_write=" + AC_WriteResultLine("Workbench Status", telemetry_write) + "\r\n";
   diagnostics += "manifest_write=" + AC_WriteResultLine("Manifest", manifest_write) + "\r\n";
   diagnostics += "forbidden_scope_check=no_runtime_1_no_symbols_no_ranking_no_alerts_no_external_worker\r\n";
   AC_WriteTextFile(AC_DiagnosticsPath(), diagnostics);

   AC_SNAPSHOT.layer_0_4_status = (manifest_write.ok && telemetry_write.ok) ? "complete" : "complete_with_degraded";
   AC_SNAPSHOT.owner_status = AC_SNAPSHOT.file_publication_blocked ? "complete_with_degraded" : "complete";
}

int OnInit()
{
   AC_ResetSnapshot();
   EventSetTimer(AC_TIMER_SECONDS);
   AC_PublishRuntime0();
   return INIT_SUCCEEDED;
}

void OnTimer()
{
   AC_PublishRuntime0();
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   string diagnostics = "system_name=" + AC_SYSTEM_NAME + "\r\n";
   diagnostics += "runtime_owner=" + AC_RUNTIME0_OWNER + "\r\n";
   diagnostics += "deinit_reason=" + IntegerToString(reason) + "\r\n";
   diagnostics += "generated_at=" + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS) + "\r\n";
   AC_WriteTextFile(AC_DiagnosticsPath(), diagnostics);
}
