#property strict
#property version   "0.012"
#property description "AURORA CORE - Runtime 0 first source slice"

#include "core/AC_Config.mqh"
#include "core/AC_CommonTypes.mqh"
#include "runtime_owners/runtime_7_publication_owner/publication_routes/AC_ServerPaths.mqh"
#include "runtime_owners/runtime_7_publication_owner/publication_fileio/AC_FileIO.mqh"
#include "runtime_owners/runtime_0_governance_internal_control/layer_0_1_startup_runtime_identity/AC_RuntimeIdentity.mqh"
#include "runtime_owners/runtime_0_governance_internal_control/layer_0_2_scheduler_heartbeat_breathing/AC_Heartbeat.mqh"
#include "runtime_owners/runtime_0_governance_internal_control/layer_0_4_governance_manifest_telemetry/AC_GovernanceRows.mqh"

AC_Runtime0Snapshot AC_SNAPSHOT;
bool AC_TIMER_READY = false;
int  AC_TIMER_SETUP_ERROR = 0;
int  AC_TIMER_TICKS_SINCE_PUBLICATION = 0;

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
   AC_SNAPSHOT.fileio_status = "not_attempted";
   AC_SNAPSHOT.manifest_status = "not_attempted";
   AC_SNAPSHOT.telemetry_status = "not_attempted";
   AC_SNAPSHOT.diagnostics_status = "not_attempted";
   AC_SNAPSHOT.upgrade_log_status = "not_attempted";
   AC_SNAPSHOT.owner_status = "not_started";
   AC_SNAPSHOT.layer_0_1_status = "not_started";
   AC_SNAPSHOT.layer_0_2_status = "not_started";
   AC_SNAPSHOT.layer_0_4_status = "not_started";
   AC_SNAPSHOT.file_publication_blocked = false;
   AC_SNAPSHOT.degraded_reason = "";
   AC_SNAPSHOT.blocked_reason = "";
}

void AC_RecordWriteProblem(const string surface, const AC_WriteResult &result)
{
   if(result.ok) return;
   AC_SNAPSHOT.file_publication_blocked = true;
   AC_AppendReason(surface + "=" + result.status);
}

string AC_BuildWorkbenchStatusText()
{
   return AC_RuntimeTelemetryRow(AC_SNAPSHOT) + "\r\n" + AC_OwnerStatusRow(AC_SNAPSHOT) + "\r\n" + AC_LayerStatusRows(AC_SNAPSHOT);
}

string AC_BuildRuntimeStatusText()
{
   return AC_RuntimeIdentityText() + AC_RuntimeStatusText(AC_SNAPSHOT) + AC_HeartbeatStatusText(AC_SNAPSHOT);
}

void AC_FinalizeState(const AC_WriteResult &runtime_write,
                      const AC_WriteResult &status_write,
                      const AC_WriteResult &manifest_write,
                      const AC_WriteResult &diagnostics_write)
{
   AC_SNAPSHOT.fileio_status = runtime_write.ok ? "runtime_status_written" : runtime_write.status;
   AC_SNAPSHOT.telemetry_status = status_write.ok ? "workbench_status_written" : status_write.status;
   AC_SNAPSHOT.manifest_status = manifest_write.ok ? "manifest_written" : manifest_write.status;
   AC_SNAPSHOT.diagnostics_status = diagnostics_write.ok ? "diagnostics_written" : diagnostics_write.status;
   AC_RecordWriteProblem("Runtime Status", runtime_write);
   AC_RecordWriteProblem("Workbench Status", status_write);
   AC_RecordWriteProblem("Manifest", manifest_write);
   AC_RecordWriteProblem("Diagnostics", diagnostics_write);
   AC_SNAPSHOT.layer_0_4_status = (status_write.ok && manifest_write.ok && diagnostics_write.ok) ? "complete" : "complete_with_degraded";
   AC_SNAPSHOT.owner_status = AC_SNAPSHOT.file_publication_blocked ? "complete_with_degraded" : "complete";
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
   if(!AC_TIMER_READY)
   {
      AC_SNAPSHOT.degraded_reason = "timer_setup_not_confirmed";
      AC_AppendReason("timer_setup_error=" + IntegerToString(AC_TIMER_SETUP_ERROR));
   }
   string folder_detail = "";
   bool folders_ok = AC_EnsureRuntimeFolders(folder_detail);
   AC_SNAPSHOT.folder_create_status = folders_ok ? "folder_create_ok" : "folder_create_failed";
   if(!folders_ok)
   {
      AC_SNAPSHOT.file_publication_blocked = true;
      AC_AppendReason(folder_detail);
   }
   AC_HeartbeatFinish(AC_SNAPSHOT);
   AC_SNAPSHOT.layer_0_2_status = AC_SNAPSHOT.over_budget ? "complete_with_degraded" : "complete";

   AC_WriteResult runtime_write = AC_WriteTextFile(AC_RuntimeStatusPath(), AC_BuildRuntimeStatusText());
   AC_WriteResult status_write = AC_WriteTextFile(AC_WorkbenchStatusPath(), AC_BuildWorkbenchStatusText());
   string manifest = "";
   manifest += AC_ManifestRow("Runtime Status", runtime_write, AC_SNAPSHOT) + "\r\n";
   manifest += AC_ManifestRow("Workbench Status", status_write, AC_SNAPSHOT) + "\r\n";
   AC_WriteResult manifest_write = AC_WriteTextFile(AC_ManifestPath(), manifest);

   string diagnostics = "";
   diagnostics += "system_name=" + AC_SYSTEM_NAME + "\r\n";
   diagnostics += "build_version=" + AC_BUILD_VERSION + "\r\n";
   diagnostics += "upgrade_id=" + AC_UPGRADE_ID + "\r\n";
   diagnostics += "runtime_owner=" + AC_RUNTIME0_OWNER + "\r\n";
   diagnostics += "timer_setup_status=" + AC_SNAPSHOT.timer_setup_status + "\r\n";
   diagnostics += "timer_setup_error=" + IntegerToString(AC_SNAPSHOT.timer_setup_error) + "\r\n";
   diagnostics += "folder_detail=" + folder_detail + "\r\n";
   diagnostics += "runtime_write=" + AC_WriteResultLine("Runtime Status", runtime_write) + "\r\n";
   diagnostics += "workbench_status_write=" + AC_WriteResultLine("Workbench Status", status_write) + "\r\n";
   diagnostics += "manifest_write=" + AC_WriteResultLine("Manifest", manifest_write) + "\r\n";
   diagnostics += "logging_policy=" + AC_LOGGING_POLICY + "\r\n";
   diagnostics += "publication_interval_heartbeats=" + IntegerToString(AC_PUBLICATION_INTERVAL_HEARTBEATS) + "\r\n";
   diagnostics += "scope_check=runtime0_only\r\n";
   AC_WriteResult diagnostics_write = AC_WriteTextFile(AC_DiagnosticsPath(), diagnostics);
   AC_FinalizeState(runtime_write, status_write, manifest_write, diagnostics_write);

   runtime_write = AC_WriteTextFile(AC_RuntimeStatusPath(), AC_BuildRuntimeStatusText());
   status_write = AC_WriteTextFile(AC_WorkbenchStatusPath(), AC_BuildWorkbenchStatusText());
   manifest = "";
   manifest += AC_ManifestRow("Runtime Status", runtime_write, AC_SNAPSHOT) + "\r\n";
   manifest += AC_ManifestRow("Workbench Status", status_write, AC_SNAPSHOT) + "\r\n";
   manifest += AC_ManifestRow("Diagnostics", diagnostics_write, AC_SNAPSHOT) + "\r\n";
   manifest_write = AC_WriteTextFile(AC_ManifestPath(), manifest);
   AC_SNAPSHOT.manifest_status = manifest_write.ok ? "manifest_written" : manifest_write.status;
   AC_RecordWriteProblem("Manifest Final", manifest_write);

   AC_WriteResult upgrade_log_write = AC_WriteTextFile(AC_UpgradeLogPath(), AC_UpgradeLogText(AC_SNAPSHOT, runtime_write, status_write, manifest_write, diagnostics_write));
   AC_SNAPSHOT.upgrade_log_status = upgrade_log_write.ok ? "upgrade_log_written" : upgrade_log_write.status;
   AC_RecordWriteProblem("Upgrade Log", upgrade_log_write);
   manifest += AC_ManifestRow("Upgrade Log", upgrade_log_write, AC_SNAPSHOT) + "\r\n";
   AC_WriteResult manifest_final_write = AC_WriteTextFile(AC_ManifestPath(), manifest);
   AC_RecordWriteProblem("Manifest With Upgrade Log", manifest_final_write);
   AC_SNAPSHOT.manifest_status = manifest_final_write.ok ? "manifest_written" : manifest_final_write.status;
   AC_SNAPSHOT.owner_status = AC_SNAPSHOT.file_publication_blocked ? "complete_with_degraded" : "complete";
   AC_WriteTextFile(AC_RuntimeStatusPath(), AC_BuildRuntimeStatusText());
   AC_WriteTextFile(AC_WorkbenchStatusPath(), AC_BuildWorkbenchStatusText());
}

int OnInit()
{
   AC_ResetSnapshot();
   ResetLastError();
   AC_TIMER_READY = EventSetTimer(AC_TIMER_SECONDS);
   AC_TIMER_SETUP_ERROR = AC_TIMER_READY ? 0 : GetLastError();
   AC_PublishRuntime0();
   return INIT_SUCCEEDED;
}

void OnTimer()
{
   AC_TIMER_TICKS_SINCE_PUBLICATION++;
   if(AC_TIMER_TICKS_SINCE_PUBLICATION < AC_PUBLICATION_INTERVAL_HEARTBEATS) return;
   AC_TIMER_TICKS_SINCE_PUBLICATION = 0;
   AC_PublishRuntime0();
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   string diagnostics = "system_name=" + AC_SYSTEM_NAME + "\r\n";
   diagnostics += "build_version=" + AC_BUILD_VERSION + "\r\n";
   diagnostics += "upgrade_id=" + AC_UPGRADE_ID + "\r\n";
   diagnostics += "runtime_owner=" + AC_RUNTIME0_OWNER + "\r\n";
   diagnostics += "deinit_reason=" + IntegerToString(reason) + "\r\n";
   diagnostics += "generated_at=" + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS) + "\r\n";
   AC_WriteTextFile(AC_DiagnosticsPath(), diagnostics);
}
