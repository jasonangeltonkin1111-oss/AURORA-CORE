#ifndef AC_GOVERNANCE_ROWS_MQH
#define AC_GOVERNANCE_ROWS_MQH

// Dependencies are included by mt5/AuroraCore.mq5 using root includes.

string AC_BoolText(const bool value)
{
   return value ? "true" : "false";
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
   text += "fileio_status=" + snapshot.fileio_status + "\r\n";
   text += "manifest_status=" + snapshot.manifest_status + "\r\n";
   text += "telemetry_status=" + snapshot.telemetry_status + "\r\n";
   text += "owner_status=" + snapshot.owner_status + "\r\n";
   text += "layer_0_1_startup_runtime_identity_status=" + snapshot.layer_0_1_status + "\r\n";
   text += "layer_0_2_scheduler_heartbeat_breathing_status=" + snapshot.layer_0_2_status + "\r\n";
   text += "layer_0_4_governance_manifest_telemetry_status=" + snapshot.layer_0_4_status + "\r\n";
   text += "file_publication_blocked=" + AC_BoolText(snapshot.file_publication_blocked) + "\r\n";
   text += "degraded_reason=" + snapshot.degraded_reason + "\r\n";
   text += "blocked_reason=" + snapshot.blocked_reason + "\r\n";
   text += "next_allowed_step=Runtime 1 - Foundation Truth Owner / Layer 1 - Account / Portfolio / Prop Rule Truth only after Runtime 0 compile and runtime smoke proof\r\n";
   return text;
}

string AC_RuntimeTelemetryRow(const AC_Runtime0Snapshot &snapshot)
{
   return "schema_name=runtime_telemetry|schema_version=v0.1|source_owner=" + AC_RUNTIME0_OWNER
      + "|build_version=" + AC_BUILD_VERSION
      + "|upgrade_id=" + AC_UPGRADE_ID
      + "|source_layer=" + AC_LAYER_0_2_NAME
      + "|heartbeat_id=" + IntegerToString((int)snapshot.heartbeat_id)
      + "|timer_duration_ms=" + IntegerToString((int)snapshot.timer_duration_ms)
      + "|timer_budget_ms=" + IntegerToString((int)AC_TIMER_BUDGET_MS)
      + "|over_budget_flag=" + AC_BoolText(snapshot.over_budget)
      + "|runtime_state=" + snapshot.runtime_state
      + "|publication_completed_flag=" + AC_BoolText(!snapshot.file_publication_blocked);
}

string AC_OwnerStatusRow(const AC_Runtime0Snapshot &snapshot)
{
   return "schema_name=owner_status|schema_version=v0.1|owner_id=runtime_0_governance_internal_control|owner_name=" + AC_RUNTIME0_OWNER
      + "|build_version=" + AC_BUILD_VERSION
      + "|upgrade_id=" + AC_UPGRADE_ID
      + "|owner_status=" + snapshot.owner_status
      + "|heartbeat_id=" + IntegerToString((int)snapshot.heartbeat_id)
      + "|freshness_state=fresh|primary_output_available=" + AC_BoolText(!snapshot.file_publication_blocked);
}

string AC_LayerStatusRows(const AC_Runtime0Snapshot &snapshot)
{
   string text = "";
   text += "schema_name=layer_status|schema_version=v0.1|layer_id=0.1|layer_name=" + AC_LAYER_0_1_NAME + "|source_owner=" + AC_RUNTIME0_OWNER + "|layer_status=" + snapshot.layer_0_1_status + "\r\n";
   text += "schema_name=layer_status|schema_version=v0.1|layer_id=0.2|layer_name=" + AC_LAYER_0_2_NAME + "|source_owner=" + AC_RUNTIME0_OWNER + "|layer_status=" + snapshot.layer_0_2_status + "\r\n";
   text += "schema_name=layer_status|schema_version=v0.1|layer_id=0.4|layer_name=" + AC_LAYER_0_4_NAME + "|source_owner=" + AC_RUNTIME0_OWNER + "|layer_status=" + snapshot.layer_0_4_status + "\r\n";
   return text;
}

string AC_ManifestRow(const string surface, const AC_WriteResult &result, const AC_Runtime0Snapshot &snapshot)
{
   return "schema_name=manifest|schema_version=v0.1|surface=" + surface
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

string AC_UpgradeLogText(const AC_Runtime0Snapshot &snapshot,
                         const AC_WriteResult &runtime_write,
                         const AC_WriteResult &status_write,
                         const AC_WriteResult &manifest_write,
                         const AC_WriteResult &diagnostics_write)
{
   string text = "";
   text += "schema_name=upgrade_log\r\n";
   text += "schema_version=v0.1\r\n";
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
   text += "timer_budget_ms=" + IntegerToString((int)AC_TIMER_BUDGET_MS) + "\r\n";
   text += "over_budget_flag=" + AC_BoolText(snapshot.over_budget) + "\r\n";
   text += "runtime_status_write=" + AC_WriteResultLine("Runtime Status", runtime_write) + "\r\n";
   text += "workbench_status_write=" + AC_WriteResultLine("Workbench Status", status_write) + "\r\n";
   text += "manifest_write=" + AC_WriteResultLine("Manifest", manifest_write) + "\r\n";
   text += "diagnostics_write=" + AC_WriteResultLine("Diagnostics", diagnostics_write) + "\r\n";
   text += "acceptance_compile_proof=pending_external_metaeditor_output\r\n";
   text += "acceptance_runtime_smoke=pending_user_generated_files_review\r\n";
   text += "acceptance_note=Upgrade Log is a bounded snapshot overwritten each heartbeat, not an append journal. It proves latest upgrade state without file-growth spam.\r\n";
   return text;
}

#endif