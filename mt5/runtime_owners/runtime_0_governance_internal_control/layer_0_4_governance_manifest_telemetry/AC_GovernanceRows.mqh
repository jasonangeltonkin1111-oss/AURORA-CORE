#ifndef AC_GOVERNANCE_ROWS_MQH
#define AC_GOVERNANCE_ROWS_MQH

// Dependencies are included by mt5/AuroraCore.mq5 using root includes.

string AC_BoolText(const bool value)
{
   return value ? "true" : "false";
}

string AC_Runtime0FreshnessState(const AC_Runtime0Snapshot &snapshot)
{
   if(snapshot.timer_busy_stale_flag) return "stale_busy";
   if(snapshot.file_publication_blocked) return "degraded_publication_problem";
   if(snapshot.timer_duration_gt_period_flag) return "degraded_timer_over_period";
   return "fresh";
}

string AC_RuntimeStatusText(const AC_Runtime0Snapshot &snapshot)
{
   string text = "";
   text += "system_name=" + AC_SYSTEM_NAME + "\r\n";
   text += "build_version=" + AC_BUILD_VERSION + "\r\n";
   text += "upgrade_id=" + AC_UPGRADE_ID + "\r\n";
   text += "runtime_owner=" + AC_RUNTIME0_OWNER + "\r\n";
   text += "runtime_state=" + snapshot.runtime_state + "\r\n";
   text += "build_phase=" + AC_BUILD_PHASE + "\r\n";
   text += "heartbeat_id=" + IntegerToString((int)snapshot.heartbeat_id) + "\r\n";
   text += "generated_at=" + snapshot.generated_at + "\r\n";
   text += "route_root=" + snapshot.route_root + "\r\n";
   text += "folder_create_status=" + snapshot.folder_create_status + "\r\n";
   text += "placeholder_status=" + snapshot.placeholder_status + "\r\n";
   text += "fileio_status=" + snapshot.fileio_status + "\r\n";
   text += "manifest_status=" + snapshot.manifest_status + "\r\n";
   text += "telemetry_status=" + snapshot.telemetry_status + "\r\n";
   text += "diagnostics_status=" + snapshot.diagnostics_status + "\r\n";
   text += "upgrade_log_status=" + snapshot.upgrade_log_status + "\r\n";
   text += "upgrade_addendum_status=" + snapshot.upgrade_addendum_status + "\r\n";
   text += "micro_log_status=" + snapshot.micro_log_status + "\r\n";
   text += "owner_status=" + snapshot.owner_status + "\r\n";
   text += "layer_0_1_startup_runtime_identity_status=" + snapshot.layer_0_1_status + "\r\n";
   text += "layer_0_2_scheduler_heartbeat_breathing_status=" + snapshot.layer_0_2_status + "\r\n";
   text += "layer_0_4_governance_manifest_telemetry_status=" + snapshot.layer_0_4_status + "\r\n";
   text += "timer_started_ms=" + IntegerToString((int)snapshot.timer_started_ms) + "\r\n";
   text += "timer_finished_ms=" + IntegerToString((int)snapshot.timer_finished_ms) + "\r\n";
   text += "timer_duration_ms=" + IntegerToString((int)snapshot.timer_duration_ms) + "\r\n";
   text += "timer_period_ms=" + IntegerToString(AC_TIMER_MILLISECONDS) + "\r\n";
   text += "timer_busy_skip_count=" + IntegerToString(snapshot.timer_busy_skip_count) + "\r\n";
   text += "timer_busy_age_ms=" + IntegerToString((int)snapshot.timer_busy_age_ms) + "\r\n";
   text += "timer_busy_stale_flag=" + AC_BoolText(snapshot.timer_busy_stale_flag) + "\r\n";
   text += "timer_duration_gt_period_flag=" + AC_BoolText(snapshot.timer_duration_gt_period_flag) + "\r\n";
   text += "timer_pressure_state=" + snapshot.timer_pressure_state + "\r\n";
   text += "file_publication_blocked=" + AC_BoolText(snapshot.file_publication_blocked) + "\r\n";
   text += "degraded_reason=" + snapshot.degraded_reason + "\r\n";
   text += "blocked_reason=" + snapshot.blocked_reason + "\r\n";
   text += "next_allowed_step=inspect_current_layer_blockers_and_runtime_outputs_before_patch_or_permission\r\n";
   return text;
}

string AC_RuntimeTelemetryRow(const AC_Runtime0Snapshot &snapshot)
{
   return "schema_name=runtime_telemetry|schema_version=v0.2|source_owner=" + AC_RUNTIME0_OWNER
      + "|build_version=" + AC_BUILD_VERSION
      + "|upgrade_id=" + AC_UPGRADE_ID
      + "|source_layer=" + AC_LAYER_0_2_NAME
      + "|heartbeat_id=" + IntegerToString((int)snapshot.heartbeat_id)
      + "|timer_duration_ms=" + IntegerToString((int)snapshot.timer_duration_ms)
      + "|timer_period_ms=" + IntegerToString(AC_TIMER_MILLISECONDS)
      + "|timer_budget_ms=" + IntegerToString((int)AC_TIMER_BUDGET_MS)
      + "|timer_budget_policy=disabled_no_artificial_throttle_complete_current_task_first"
      + "|timer_busy_skip_count=" + IntegerToString(snapshot.timer_busy_skip_count)
      + "|timer_duration_gt_period_flag=" + AC_BoolText(snapshot.timer_duration_gt_period_flag)
      + "|timer_busy_stale_flag=" + AC_BoolText(snapshot.timer_busy_stale_flag)
      + "|timer_pressure_state=" + snapshot.timer_pressure_state
      + "|over_budget_flag=" + AC_BoolText(snapshot.over_budget)
      + "|runtime_state=" + snapshot.runtime_state
      + "|publication_completed_flag=" + AC_BoolText(!snapshot.file_publication_blocked);
}

string AC_OwnerStatusRow(const AC_Runtime0Snapshot &snapshot)
{
   return "schema_name=owner_status|schema_version=v0.2|owner_id=runtime_0_governance_internal_control|owner_name=" + AC_RUNTIME0_OWNER
      + "|build_version=" + AC_BUILD_VERSION
      + "|upgrade_id=" + AC_UPGRADE_ID
      + "|owner_status=" + snapshot.owner_status
      + "|heartbeat_id=" + IntegerToString((int)snapshot.heartbeat_id)
      + "|freshness_state=" + AC_Runtime0FreshnessState(snapshot)
      + "|timer_pressure_state=" + snapshot.timer_pressure_state
      + "|primary_output_available=" + AC_BoolText(!snapshot.file_publication_blocked);
}

string AC_LayerStatusRows(const AC_Runtime0Snapshot &snapshot)
{
   string text = "";
   text += "schema_name=layer_status|schema_version=v0.1|layer_id=0.1|layer_name=" + AC_LAYER_0_1_NAME + "|source_owner=" + AC_RUNTIME0_OWNER + "|layer_status=" + snapshot.layer_0_1_status + "\r\n";
   text += "schema_name=layer_status|schema_version=v0.1|layer_id=0.2|layer_name=" + AC_LAYER_0_2_NAME + "|source_owner=" + AC_RUNTIME0_OWNER + "|layer_status=" + snapshot.layer_0_2_status + "\r\n";
   text += "schema_name=layer_status|schema_version=v0.1|layer_id=0.4|layer_name=" + AC_LAYER_0_4_NAME + "|source_owner=" + AC_RUNTIME0_OWNER + "|layer_status=" + snapshot.layer_0_4_status + "\r\n";
   return text;
}

string AC_ManifestRow(const string surface, const AC_WriteResult &result, const AC_Runtime0Snapshot &snapshot, const string phase = "primary")
{
   return "schema_name=manifest|schema_version=v0.1|surface=" + surface
      + "|phase=" + phase
      + "|source_owner=" + AC_RUNTIME0_OWNER
      + "|source_layer=" + AC_LAYER_0_4_NAME
      + "|build_version=" + AC_BUILD_VERSION
      + "|upgrade_id=" + AC_UPGRADE_ID
      + "|heartbeat_id=" + IntegerToString((int)snapshot.heartbeat_id)
      + "|write_status=" + result.status
      + "|final_exists=" + AC_BoolText(result.final_exists)
      + "|final_size=" + AC_UlongToText(result.final_size)
      + "|file_publication_blocked=" + AC_BoolText(!result.ok)
      + "|final_path=" + result.final_path
      + "|error_code=" + IntegerToString(result.error_code);
}

string AC_MicroLogRow(const string function_name, const uint start_ms, const uint end_ms, const string status)
{
   return "schema_name=micro_log|schema_version=v0.1|upgrade_id=" + AC_UPGRADE_ID
      + "|function=" + function_name
      + "|start_ms=" + IntegerToString((int)start_ms)
      + "|end_ms=" + IntegerToString((int)end_ms)
      + "|duration_ms=" + IntegerToString((int)(end_ms - start_ms))
      + "|status=" + status;
}

string AC_UpgradeAddendumText(const AC_Runtime0Snapshot &snapshot)
{
   string text = "";
   text += "schema_name=upgrade_addendum\r\n";
   text += "schema_version=v0.4\r\n";
   text += "system_name=" + AC_SYSTEM_NAME + "\r\n";
   text += "build_version=" + AC_BUILD_VERSION + "\r\n";
   text += "upgrade_id=" + AC_UPGRADE_ID + "\r\n";
   text += "generated_at=" + snapshot.generated_at + "\r\n";
   text += "addendum_reason=runtime0_spine_identity_gateway_timer_repair\r\n";
   text += "logging_contract=" + AC_LOGGING_POLICY + "\r\n";
   text += "board_contract=trading_side_summary_atomic_update_only_when_content_changes\r\n";
   text += "workbench_contract=developer_status_layer_packets_slower_refresh_without_trader_bloat\r\n";
   text += "dossier_contract=foundation_dossier_publication_called_by_timer_but_truth_owned_by_runtime1\r\n";
   text += "statistics_contract=each_layer_owner_outputs_own_status_packet_board_reads_packets_only\r\n";
   text += "gateway_contract=runtime0_calls_existing_runtime3_control_snapshot_status_owner_no_new_worker_owner\r\n";
   text += "timer_milliseconds=" + IntegerToString(AC_TIMER_MILLISECONDS) + "\r\n";
   text += "timer_budget_policy=disabled_no_artificial_throttle_complete_current_task_first\r\n";
   text += "workbench_interval_heartbeats=" + IntegerToString(AC_WORKBENCH_INTERVAL_HEARTBEATS) + "\r\n";
   text += "dossier_shell_write_retries=" + IntegerToString(AC_DOSSIER_SHELL_WRITE_RETRIES) + "\r\n";
   text += "scope_guard=no_strategy_no_execution_no_trade_permission_no_scheduler_v2_no_gateway_v2\r\n";
   text += "compile_proof=pending_external_metaeditor_output\r\n";
   text += "runtime_smoke=pending_user_generated_files_review\r\n";
   return text;
}

string AC_UpgradeLogText(const AC_Runtime0Snapshot &snapshot,
                         const AC_WriteResult &runtime_write,
                         const AC_WriteResult &status_write,
                         const AC_WriteResult &manifest_write,
                         const AC_WriteResult &diagnostics_write)
{
   string text = "";
   text += "schema_name=upgrade_log\r\n";
   text += "schema_version=v0.2\r\n";
   text += "system_name=" + AC_SYSTEM_NAME + "\r\n";
   text += "build_version=" + AC_BUILD_VERSION + "\r\n";
   text += "upgrade_id=" + AC_UPGRADE_ID + "\r\n";
   text += "upgrade_summary=" + AC_UPGRADE_SUMMARY + "\r\n";
   text += "upgrade_scope=" + AC_UPGRADE_SCOPE + "\r\n";
   text += "upgrade_test_plan=" + AC_UPGRADE_TEST_PLAN + "\r\n";
   text += "logging_policy=" + AC_LOGGING_POLICY + "\r\n";
   text += "generated_at=" + snapshot.generated_at + "\r\n";
   text += "heartbeat_id=" + IntegerToString((int)snapshot.heartbeat_id) + "\r\n";
   text += "timer_duration_ms=" + IntegerToString((int)snapshot.timer_duration_ms) + "\r\n";
   text += "timer_period_ms=" + IntegerToString(AC_TIMER_MILLISECONDS) + "\r\n";
   text += "timer_pressure_state=" + snapshot.timer_pressure_state + "\r\n";
   text += "timer_budget_ms=" + IntegerToString((int)AC_TIMER_BUDGET_MS) + "\r\n";
   text += "timer_budget_policy=disabled_no_artificial_throttle_complete_current_task_first\r\n";
   text += "over_budget_flag=" + AC_BoolText(snapshot.over_budget) + "\r\n";
   text += "runtime_status_write=" + AC_WriteResultLine("Runtime Status", runtime_write) + "\r\n";
   text += "workbench_status_write=" + AC_WriteResultLine("Workbench Status", status_write) + "\r\n";
   text += "manifest_write=" + AC_WriteResultLine("Manifest", manifest_write) + "\r\n";
   text += "diagnostics_write=" + AC_WriteResultLine("Diagnostics", diagnostics_write) + "\r\n";
   text += "acceptance_compile_proof=pending_external_metaeditor_output\r\n";
   text += "acceptance_runtime_smoke=pending_user_generated_files_review\r\n";
   text += "acceptance_note=Upgrade Log and Upgrade Addendum are bounded snapshots. Micro Log records major phase timings only.\r\n";
   return text;
}

#endif