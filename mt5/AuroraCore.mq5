#property strict
#property version   "0.019"
#property description "AURORA CORE - Selection Desk stable parent routes"

#include "core/AC_Config.mqh"
#include "core/AC_CommonTypes.mqh"
#include "runtime_owners/runtime_7_publication_owner/publication_routes/AC_ServerPaths.mqh"
#include "runtime_owners/runtime_7_publication_owner/publication_fileio/AC_FileIO.mqh"
#include "runtime_owners/runtime_0_governance_internal_control/layer_0_1_startup_runtime_identity/AC_RuntimeIdentity.mqh"
#include "runtime_owners/runtime_0_governance_internal_control/layer_0_2_scheduler_heartbeat_breathing/AC_Heartbeat.mqh"
#include "runtime_owners/runtime_0_governance_internal_control/layer_0_4_governance_manifest_telemetry/AC_GovernanceRows.mqh"
#include "runtime_owners/runtime_1_foundation_truth_owner/layer_1_account_portfolio_prop_rule_truth/AC_AccountTruth.mqh"
#include "runtime_owners/runtime_2_market_universe_taxonomy_lookup/AC_MarketUniverse.mqh"

AC_Runtime0Snapshot AC_SNAPSHOT;
bool AC_TIMER_READY = false;
int  AC_TIMER_SETUP_ERROR = 0;
int  AC_TIMER_TICKS_SINCE_PUBLICATION = 0;
string AC_MICRO_LOG = "";

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
   AC_MICRO_LOG = "schema_name=micro_log_snapshot\r\nschema_version=v0.1\r\n";
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

string AC_BuildWorkbenchStatusText(const AC_WriteResult &account_write)
{
   return AC_RuntimeTelemetryRow(AC_SNAPSHOT) + "\r\n" + AC_OwnerStatusRow(AC_SNAPSHOT) + "\r\n" + AC_LayerStatusRows(AC_SNAPSHOT) + AC_AccountTruthStatusRow(account_write) + "\r\n" + AC_UniverseStatusRow() + "\r\n";
}

string AC_BuildRuntimeStatusText()
{
   return AC_RuntimeIdentityText() + AC_RuntimeStatusText(AC_SNAPSHOT) + AC_HeartbeatStatusText(AC_SNAPSHOT);
}

string AC_PlaceholderText(const string surface)
{
   string text = "";
   text += "system_name=" + AC_SYSTEM_NAME + "\r\n";
   text += "build_version=" + AC_BUILD_VERSION + "\r\n";
   text += "upgrade_id=" + AC_UPGRADE_ID + "\r\n";
   text += "placeholder_surface=" + surface + "\r\n";
   text += "placeholder_status=structure_only\r\n";
   text += "truth_status=no_runtime_truth_yet\r\n";
   text += "selection_parent_runtime=true\r\n";
   text += "ranking_group_runtime=false\r\n";
   text += "selection_logic_runtime=false\r\n";
   text += "trade_permission=false\r\n";
   text += "scope_guard=no_symbols_no_ranking_no_selection_claim_no_strategy_no_execution\r\n";
   text += "route_contract=stable_parent_folder_numbers_live_inside_child_files_not_folder_names\r\n";
   text += "generated_at=" + AC_NowText() + "\r\n";
   return text;
}

string AC_SelectionIndexPlaceholderText()
{
   string text = "";
   text += "schema_name=selection_index\r\n";
   text += "schema_version=v0.1\r\n";
   text += "system_name=" + AC_SYSTEM_NAME + "\r\n";
   text += "build_version=" + AC_BUILD_VERSION + "\r\n";
   text += "upgrade_id=" + AC_UPGRADE_ID + "\r\n";
   text += "selection_index_path=" + AC_SelectionIndexPath() + "\r\n";
   text += "selection_groups_folder=" + AC_SelectionGroupsFolder() + "\r\n";
   text += "selection_global_folder=" + AC_SelectionGlobalFolder() + "\r\n";
   text += "index_status=structure_only\r\n";
   text += "truth_status=no_runtime_selection_truth_yet\r\n";
   text += "rank_order_runtime=false\r\n";
   text += "ranking_group_runtime=false\r\n";
   text += "selection_logic_runtime=false\r\n";
   text += "trade_permission=false\r\n";
   text += "intended_future_fields=cycle_id,generated_at,group_rank,symbol_rank,asset_class,market_group,market_segment,ranking_group,symbol,score_summary,evidence_status,gate_status,reject_reason,child_file_path\r\n";
   text += "route_contract=stable_parent_folders_groups_and_global; ranking_numbers_live_inside_this_index_or_child_files_not_folder_names\r\n";
   text += "generated_at=" + AC_NowText() + "\r\n";
   return text;
}

bool AC_AllPlaceholdersOk(const AC_WriteResult &dossiers_root,
                          const AC_WriteResult &dossiers_open,
                          const AC_WriteResult &dossiers_closed,
                          const AC_WriteResult &dossiers_unknown,
                          const AC_WriteResult &selection_groups,
                          const AC_WriteResult &selection_global,
                          const AC_WriteResult &selection_index)
{
   return dossiers_root.ok && dossiers_open.ok && dossiers_closed.ok && dossiers_unknown.ok && selection_groups.ok && selection_global.ok && selection_index.ok;
}

void AC_FinalizeState(const AC_WriteResult &runtime_write,
                      const AC_WriteResult &status_write,
                      const AC_WriteResult &manifest_write,
                      const AC_WriteResult &diagnostics_write,
                      const AC_WriteResult &account_write)
{
   AC_SNAPSHOT.fileio_status = runtime_write.ok ? "runtime_status_written" : runtime_write.status;
   AC_SNAPSHOT.telemetry_status = status_write.ok ? "workbench_status_written" : status_write.status;
   AC_SNAPSHOT.manifest_status = manifest_write.ok ? "manifest_written" : manifest_write.status;
   AC_SNAPSHOT.diagnostics_status = diagnostics_write.ok ? "diagnostics_written" : diagnostics_write.status;
   AC_RecordWriteProblem("Runtime Status", runtime_write);
   AC_RecordWriteProblem("Workbench Status", status_write);
   AC_RecordWriteProblem("Manifest", manifest_write);
   AC_RecordWriteProblem("Diagnostics", diagnostics_write);
   AC_RecordWriteProblem("Account Status", account_write);
   AC_SNAPSHOT.layer_0_4_status = (status_write.ok && manifest_write.ok && diagnostics_write.ok) ? "complete" : "complete_with_degraded";
   AC_SNAPSHOT.owner_status = AC_SNAPSHOT.file_publication_blocked ? "complete_with_degraded" : "complete";
}

void AC_PublishRuntime0()
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
   AC_WriteResult ph_dossiers_root = AC_WriteTextFile(AC_PlaceholderPath(AC_DossiersFolder()), AC_PlaceholderText("Dossiers"));
   AC_WriteResult ph_dossiers_open = AC_WriteTextFile(AC_PlaceholderPath(AC_DossiersOpenFolder()), AC_PlaceholderText("Dossiers/Open"));
   AC_WriteResult ph_dossiers_closed = AC_WriteTextFile(AC_PlaceholderPath(AC_DossiersClosedFolder()), AC_PlaceholderText("Dossiers/Closed"));
   AC_WriteResult ph_dossiers_unknown = AC_WriteTextFile(AC_PlaceholderPath(AC_DossiersUnknownFolder()), AC_PlaceholderText("Dossiers/Unknown"));
   AC_WriteResult ph_selection_groups = AC_WriteTextFile(AC_PlaceholderPath(AC_SelectionGroupsFolder()), AC_PlaceholderText("Selection Desk/Groups"));
   AC_WriteResult ph_selection_global = AC_WriteTextFile(AC_PlaceholderPath(AC_SelectionGlobalFolder()), AC_PlaceholderText("Selection Desk/Global"));
   AC_WriteResult selection_index_write = AC_WriteTextFile(AC_SelectionIndexPath(), AC_SelectionIndexPlaceholderText());
   bool placeholders_ok = AC_AllPlaceholdersOk(ph_dossiers_root, ph_dossiers_open, ph_dossiers_closed, ph_dossiers_unknown, ph_selection_groups, ph_selection_global, selection_index_write);
   AC_SNAPSHOT.placeholder_status = placeholders_ok ? "placeholders_written" : "placeholder_write_degraded";
   AC_RecordWriteProblem("Placeholder Dossiers", ph_dossiers_root);
   AC_RecordWriteProblem("Placeholder Dossiers Open", ph_dossiers_open);
   AC_RecordWriteProblem("Placeholder Dossiers Closed", ph_dossiers_closed);
   AC_RecordWriteProblem("Placeholder Dossiers Unknown", ph_dossiers_unknown);
   AC_RecordWriteProblem("Placeholder Selection Groups", ph_selection_groups);
   AC_RecordWriteProblem("Placeholder Selection Global", ph_selection_global);
   AC_RecordWriteProblem("Selection Index", selection_index_write);
   AC_AddMicroLog("write_placeholder_files", phase_start, AC_SNAPSHOT.placeholder_status);

   AC_HeartbeatFinish(AC_SNAPSHOT);
   AC_SNAPSHOT.layer_0_2_status = AC_SNAPSHOT.over_budget ? "complete_with_degraded" : "complete";

   phase_start = GetTickCount();
   AC_WriteResult account_write = AC_WriteTextFile(AC_AccountStatusPath(), AC_AccountTruthText());
   AC_WriteResult runtime_write = AC_WriteTextFile(AC_RuntimeStatusPath(), AC_BuildRuntimeStatusText());
   AC_WriteResult status_write = AC_WriteTextFile(AC_WorkbenchStatusPath(), AC_BuildWorkbenchStatusText(account_write));
   AC_AddMicroLog("write_primary_surfaces", phase_start, (account_write.ok && runtime_write.ok && status_write.ok) ? "complete" : "degraded");

   string manifest = "";
   manifest += AC_ManifestRow("Runtime Status", runtime_write, AC_SNAPSHOT) + "\r\n";
   manifest += AC_ManifestRow("Workbench Status", status_write, AC_SNAPSHOT) + "\r\n";
   manifest += AC_ManifestRow("Account Status", account_write, AC_SNAPSHOT) + "\r\n";
   manifest += AC_ManifestRow("Dossiers Placeholder", ph_dossiers_root, AC_SNAPSHOT) + "\r\n";
   manifest += AC_ManifestRow("Dossiers Open Placeholder", ph_dossiers_open, AC_SNAPSHOT) + "\r\n";
   manifest += AC_ManifestRow("Dossiers Closed Placeholder", ph_dossiers_closed, AC_SNAPSHOT) + "\r\n";
   manifest += AC_ManifestRow("Dossiers Unknown Placeholder", ph_dossiers_unknown, AC_SNAPSHOT) + "\r\n";
   manifest += AC_ManifestRow("Selection Groups Placeholder", ph_selection_groups, AC_SNAPSHOT) + "\r\n";
   manifest += AC_ManifestRow("Selection Global Placeholder", ph_selection_global, AC_SNAPSHOT) + "\r\n";
   manifest += AC_ManifestRow("Selection Index", selection_index_write, AC_SNAPSHOT) + "\r\n";
   AC_WriteResult manifest_write = AC_WriteTextFile(AC_ManifestPath(), manifest);

   string diagnostics = "";
   diagnostics += "system_name=" + AC_SYSTEM_NAME + "\r\n";
   diagnostics += "build_version=" + AC_BUILD_VERSION + "\r\n";
   diagnostics += "upgrade_id=" + AC_UPGRADE_ID + "\r\n";
   diagnostics += "runtime_owner=" + AC_RUNTIME0_OWNER + "\r\n";
   diagnostics += "timer_setup_status=" + AC_SNAPSHOT.timer_setup_status + "\r\n";
   diagnostics += "timer_setup_error=" + IntegerToString(AC_SNAPSHOT.timer_setup_error) + "\r\n";
   diagnostics += "folder_detail=" + folder_detail + "\r\n";
   diagnostics += "placeholder_status=" + AC_SNAPSHOT.placeholder_status + "\r\n";
   diagnostics += "runtime_write=" + AC_WriteResultLine("Runtime Status", runtime_write) + "\r\n";
   diagnostics += "workbench_status_write=" + AC_WriteResultLine("Workbench Status", status_write) + "\r\n";
   diagnostics += "account_status_write=" + AC_WriteResultLine("Account Status", account_write) + "\r\n";
   diagnostics += "selection_index_write=" + AC_WriteResultLine("Selection Index", selection_index_write) + "\r\n";
   diagnostics += "manifest_write=" + AC_WriteResultLine("Manifest", manifest_write) + "\r\n";
   diagnostics += "selection_desk_structure=Groups + Global stable parent placeholders plus Selection Index file; top/rank numbering belongs inside child files or the index, not folder names\r\n";
   diagnostics += "selection_index_contract=sidecar_file_for_future_group_order_symbol_order_metadata_gate_status_reject_reason_child_paths\r\n";
   diagnostics += "taxonomy_contract=asset_class -> market_group -> market_segment -> symbol; ranking_group is the selection/cap/diversification grouping field\r\n";
   diagnostics += "universe_lookup_contract_status=" + AC_UniverseContractStatus() + "\r\n";
   diagnostics += AC_UniverseDiagnosticsText();
   diagnostics += "logging_policy=" + AC_LOGGING_POLICY + "\r\n";
   diagnostics += "publication_interval_heartbeats=" + IntegerToString(AC_PUBLICATION_INTERVAL_HEARTBEATS) + "\r\n";
   diagnostics += "scope_check=runtime1_layer1_account_truth_placeholders_only_no_symbols_no_ranking_no_strategy_no_execution\r\n";
   phase_start = GetTickCount();
   AC_WriteResult diagnostics_write = AC_WriteTextFile(AC_DiagnosticsPath(), diagnostics);
   AC_AddMicroLog("write_diagnostics", phase_start, diagnostics_write.ok ? "complete" : "degraded");

   AC_FinalizeState(runtime_write, status_write, manifest_write, diagnostics_write, account_write);

   phase_start = GetTickCount();
   runtime_write = AC_WriteTextFile(AC_RuntimeStatusPath(), AC_BuildRuntimeStatusText());
   status_write = AC_WriteTextFile(AC_WorkbenchStatusPath(), AC_BuildWorkbenchStatusText(account_write));
   AC_AddMicroLog("republish_final_status", phase_start, (runtime_write.ok && status_write.ok) ? "complete" : "degraded");

   manifest = "";
   manifest += AC_ManifestRow("Runtime Status", runtime_write, AC_SNAPSHOT) + "\r\n";
   manifest += AC_ManifestRow("Workbench Status", status_write, AC_SNAPSHOT) + "\r\n";
   manifest += AC_ManifestRow("Account Status", account_write, AC_SNAPSHOT) + "\r\n";
   manifest += AC_ManifestRow("Diagnostics", diagnostics_write, AC_SNAPSHOT) + "\r\n";
   manifest += AC_ManifestRow("Dossiers Placeholder", ph_dossiers_root, AC_SNAPSHOT) + "\r\n";
   manifest += AC_ManifestRow("Dossiers Open Placeholder", ph_dossiers_open, AC_SNAPSHOT) + "\r\n";
   manifest += AC_ManifestRow("Dossiers Closed Placeholder", ph_dossiers_closed, AC_SNAPSHOT) + "\r\n";
   manifest += AC_ManifestRow("Dossiers Unknown Placeholder", ph_dossiers_unknown, AC_SNAPSHOT) + "\r\n";
   manifest += AC_ManifestRow("Selection Groups Placeholder", ph_selection_groups, AC_SNAPSHOT) + "\r\n";
   manifest += AC_ManifestRow("Selection Global Placeholder", ph_selection_global, AC_SNAPSHOT) + "\r\n";
   manifest += AC_ManifestRow("Selection Index", selection_index_write, AC_SNAPSHOT) + "\r\n";
   manifest_write = AC_WriteTextFile(AC_ManifestPath(), manifest);
   AC_SNAPSHOT.manifest_status = manifest_write.ok ? "manifest_written" : manifest_write.status;
   AC_RecordWriteProblem("Manifest Final", manifest_write);

   AC_WriteResult upgrade_addendum_write = AC_WriteTextFile(AC_UpgradeAddendumPath(), AC_UpgradeAddendumText(AC_SNAPSHOT));
   AC_SNAPSHOT.upgrade_addendum_status = upgrade_addendum_write.ok ? "upgrade_addendum_written" : upgrade_addendum_write.status;
   AC_RecordWriteProblem("Upgrade Addendum", upgrade_addendum_write);

   AC_WriteResult micro_log_write = AC_WriteTextFile(AC_MicroLogPath(), AC_MICRO_LOG);
   AC_SNAPSHOT.micro_log_status = micro_log_write.ok ? "micro_log_written" : micro_log_write.status;
   AC_RecordWriteProblem("Micro Log", micro_log_write);

   AC_WriteResult upgrade_log_write = AC_WriteTextFile(AC_UpgradeLogPath(), AC_UpgradeLogText(AC_SNAPSHOT, runtime_write, status_write, manifest_write, diagnostics_write));
   AC_SNAPSHOT.upgrade_log_status = upgrade_log_write.ok ? "upgrade_log_written" : upgrade_log_write.status;
   AC_RecordWriteProblem("Upgrade Log", upgrade_log_write);

   manifest += AC_ManifestRow("Upgrade Addendum", upgrade_addendum_write, AC_SNAPSHOT) + "\r\n";
   manifest += AC_ManifestRow("Micro Log", micro_log_write, AC_SNAPSHOT) + "\r\n";
   manifest += AC_ManifestRow("Upgrade Log", upgrade_log_write, AC_SNAPSHOT) + "\r\n";
   AC_WriteResult manifest_final_write = AC_WriteTextFile(AC_ManifestPath(), manifest);
   AC_RecordWriteProblem("Manifest With Micro Logs", manifest_final_write);
   AC_SNAPSHOT.manifest_status = manifest_final_write.ok ? "manifest_written" : manifest_final_write.status;
   AC_SNAPSHOT.owner_status = AC_SNAPSHOT.file_publication_blocked ? "complete_with_degraded" : "complete";
   AC_WriteTextFile(AC_RuntimeStatusPath(), AC_BuildRuntimeStatusText());
   AC_WriteTextFile(AC_WorkbenchStatusPath(), AC_BuildWorkbenchStatusText(account_write));
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
