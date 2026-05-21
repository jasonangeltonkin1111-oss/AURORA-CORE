#ifndef AC_EXTERNAL_WORKER_RENDER_MQH
#define AC_EXTERNAL_WORKER_RENDER_MQH

void AC_BuildExternalWorkerTexts()
{
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION = "\r\nEXTERNAL_CALCULATION_WORKER\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "----------------------------------------\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "owner=" + AC_RUNTIME3_OWNER + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "required=" + (AC_EXTERNAL_WORKER_STATUS.required ? "true" : "false") + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "auto_launch_desired=" + (AC_EXTERNAL_WORKER_STATUS.auto_launch_desired ? "true" : "false") + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "launch_mode=" + AC_EXTERNAL_WORKER_STATUS.launch_mode + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "launch_implementation=" + AC_EXTERNAL_WORKER_STATUS.launch_implementation + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "launch_status=" + AC_EXTERNAL_WORKER_STATUS.launch_status + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "launch_blocker=" + AC_EXTERNAL_WORKER_STATUS.launch_blocker + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "launch_attempts=" + IntegerToString(AC_EXTERNAL_WORKER_STATUS.launch_attempts) + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "popup_alerts=false\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "authority=" + AC_EXTERNAL_WORKER_STATUS.authority + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "worker_status=" + AC_EXTERNAL_WORKER_STATUS.worker_status + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "install_status=" + AC_EXTERNAL_WORKER_STATUS.install_status + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "install_status_source=" + AC_EXTERNAL_WORKER_STATUS.install_status_source + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "install_status_file_present=" + (AC_EXTERNAL_WORKER_STATUS.install_status_file_present ? "true" : "false") + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "worker_installed=" + (AC_EXTERNAL_WORKER_STATUS.worker_installed ? "true" : "false") + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "install_validation_status=" + AC_EXTERNAL_WORKER_STATUS.install_validation_status + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "install_validation_reason=" + AC_EXTERNAL_WORKER_STATUS.install_validation_reason + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "install_worker_version=" + AC_EXTERNAL_WORKER_STATUS.install_worker_version + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "install_status_age_seconds=" + IntegerToString(AC_EXTERNAL_WORKER_STATUS.install_status_age_seconds) + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "install_flat_exe_present=" + AC_EXTERNAL_WORKER_STATUS.install_flat_exe_present + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "install_packaged_exe_present=" + AC_EXTERNAL_WORKER_STATUS.install_packaged_exe_present + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "lifecycle_file_present=" + (AC_EXTERNAL_WORKER_STATUS.lifecycle_file_present ? "true" : "false") + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "lifecycle_fresh=" + (AC_EXTERNAL_WORKER_STATUS.lifecycle_fresh ? "true" : "false") + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "lifecycle_status=" + AC_EXTERNAL_WORKER_STATUS.lifecycle_status + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "lifecycle_validation_status=" + AC_EXTERNAL_WORKER_STATUS.lifecycle_validation_status + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "lifecycle_validation_reason=" + AC_EXTERNAL_WORKER_STATUS.lifecycle_validation_reason + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "lifecycle_worker_version=" + AC_EXTERNAL_WORKER_STATUS.lifecycle_worker_version + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "lifecycle_pid=" + AC_EXTERNAL_WORKER_STATUS.lifecycle_pid + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "lifecycle_mode=" + AC_EXTERNAL_WORKER_STATUS.lifecycle_mode + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "lifecycle_start_utc=" + AC_EXTERNAL_WORKER_STATUS.lifecycle_start_utc + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "lifecycle_last_loop_utc=" + AC_EXTERNAL_WORKER_STATUS.lifecycle_last_loop_utc + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "lifecycle_last_loop_age_seconds=" + IntegerToString(AC_EXTERNAL_WORKER_STATUS.lifecycle_last_loop_age_seconds) + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "lifecycle_loop_count=" + IntegerToString(AC_EXTERNAL_WORKER_STATUS.lifecycle_loop_count) + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "lifecycle_last_run_exit_code=" + IntegerToString(AC_EXTERNAL_WORKER_STATUS.lifecycle_last_run_exit_code) + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "lifecycle_last_validation_status=" + AC_EXTERNAL_WORKER_STATUS.lifecycle_last_validation_status + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "lifecycle_last_validation_reason=" + AC_EXTERNAL_WORKER_STATUS.lifecycle_last_validation_reason + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "lifecycle_last_snapshot_id=" + AC_EXTERNAL_WORKER_STATUS.lifecycle_last_snapshot_id + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "heartbeat_status=" + AC_EXTERNAL_WORKER_STATUS.heartbeat_status + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "heartbeat_validation_status=" + AC_EXTERNAL_WORKER_STATUS.heartbeat_validation_status + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "heartbeat_validation_reason=" + AC_EXTERNAL_WORKER_STATUS.heartbeat_validation_reason + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "heartbeat_age_seconds=" + IntegerToString(AC_EXTERNAL_WORKER_STATUS.heartbeat_age_seconds) + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "result_status=" + AC_EXTERNAL_WORKER_STATUS.result_status + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "result_validation_status=" + AC_EXTERNAL_WORKER_STATUS.result_validation_status + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "result_validation_reason=" + AC_EXTERNAL_WORKER_STATUS.result_validation_reason + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "result_age_seconds=" + IntegerToString(AC_EXTERNAL_WORKER_STATUS.result_age_seconds) + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "accepted_result=" + (AC_EXTERNAL_WORKER_STATUS.accepted_result ? "true" : "false") + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "result_snapshot_id=" + AC_EXTERNAL_WORKER_STATUS.result_snapshot_id + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "result_row_count=" + IntegerToString(AC_EXTERNAL_WORKER_STATUS.result_row_count) + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "result_payload_checksum=" + AC_EXTERNAL_WORKER_STATUS.result_payload_checksum + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "result_authority=" + AC_EXTERNAL_WORKER_STATUS.result_authority + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "result_trade_permission=" + AC_EXTERNAL_WORKER_STATUS.result_trade_permission + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "snapshot_status=" + AC_EXTERNAL_WORKER_LAST_SNAPSHOT_STATUS + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "snapshot_manifest_status=" + AC_EXTERNAL_WORKER_LAST_SNAPSHOT_MANIFEST_STATUS + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "snapshot_id=" + AC_EXTERNAL_WORKER_LAST_SNAPSHOT_ID + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "snapshot_rows=" + IntegerToString(AC_EXTERNAL_WORKER_LAST_SNAPSHOT_ROWS) + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "snapshot_size=" + AC_UlongToText(AC_EXTERNAL_WORKER_LAST_SNAPSHOT_SIZE) + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "snapshot_payload_checksum=" + AC_EXTERNAL_WORKER_LAST_SNAPSHOT_PAYLOAD_CHECKSUM + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "snapshot_path=" + AC_ExternalWorkerSnapshotPath() + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "snapshot_manifest_path=" + AC_ExternalWorkerSnapshotManifestPath() + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "exe_present_diagnostic=" + (AC_EXTERNAL_WORKER_STATUS.exe_present ? "true" : "false") + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "exe_flat_present_diagnostic=" + (AC_EXTERNAL_WORKER_STATUS.exe_flat_present ? "true" : "false") + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "exe_folder_present_diagnostic=" + (AC_EXTERNAL_WORKER_STATUS.exe_folder_present ? "true" : "false") + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "exe_detection_note=diagnostic_only_install_truth_comes_from_worker_install_status\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "flat_exe_error=" + IntegerToString(AC_EXTERNAL_WORKER_STATUS.flat_exe_error) + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "folder_exe_error=" + IntegerToString(AC_EXTERNAL_WORKER_STATUS.folder_exe_error) + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "heartbeat_present=" + (AC_EXTERNAL_WORKER_STATUS.heartbeat_present ? "true" : "false") + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "result_present=" + (AC_EXTERNAL_WORKER_STATUS.result_present ? "true" : "false") + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "result_manifest_present=" + (AC_EXTERNAL_WORKER_STATUS.result_manifest_present ? "true" : "false") + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "expected_exe_path=" + AC_EXTERNAL_WORKER_STATUS.expected_exe_path + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "expected_folder_exe_path=" + AC_EXTERNAL_WORKER_STATUS.expected_folder_exe_path + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "install_status_path=" + AC_EXTERNAL_WORKER_STATUS.install_status_path + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "lifecycle_path=" + AC_EXTERNAL_WORKER_STATUS.lifecycle_path + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "required_path=" + AC_EXTERNAL_WORKER_STATUS.required_path + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "heartbeat_path=" + AC_EXTERNAL_WORKER_STATUS.heartbeat_path + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "result_path=" + AC_EXTERNAL_WORKER_STATUS.result_path + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "missing_reason=" + AC_EXTERNAL_WORKER_STATUS.missing_reason + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "last_error=" + IntegerToString(AC_EXTERNAL_WORKER_STATUS.last_error) + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "trade_permission=false\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "board_alerts=disabled_for_now\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "mt5_core_continues_if_worker_missing=true\r\n";

   AC_EXTERNAL_WORKER_STATUS_ROW = "schema_name=external_worker_status|schema_version=v0.9|source_owner=" + AC_RUNTIME3_OWNER
      + "|build_version=" + AC_BUILD_VERSION
      + "|upgrade_id=" + AC_UPGRADE_ID
      + "|required=" + (AC_EXTERNAL_WORKER_STATUS.required ? "true" : "false")
      + "|auto_launch_desired=" + (AC_EXTERNAL_WORKER_STATUS.auto_launch_desired ? "true" : "false")
      + "|launch_mode=" + AC_EXTERNAL_WORKER_STATUS.launch_mode
      + "|launch_implementation=" + AC_EXTERNAL_WORKER_STATUS.launch_implementation
      + "|launch_status=" + AC_EXTERNAL_WORKER_STATUS.launch_status
      + "|worker_status=" + AC_EXTERNAL_WORKER_STATUS.worker_status
      + "|install_status=" + AC_EXTERNAL_WORKER_STATUS.install_status
      + "|worker_installed=" + (AC_EXTERNAL_WORKER_STATUS.worker_installed ? "true" : "false")
      + "|install_validation_status=" + AC_EXTERNAL_WORKER_STATUS.install_validation_status
      + "|install_status_file_present=" + (AC_EXTERNAL_WORKER_STATUS.install_status_file_present ? "true" : "false")
      + "|lifecycle_file_present=" + (AC_EXTERNAL_WORKER_STATUS.lifecycle_file_present ? "true" : "false")
      + "|lifecycle_fresh=" + (AC_EXTERNAL_WORKER_STATUS.lifecycle_fresh ? "true" : "false")
      + "|lifecycle_validation_status=" + AC_EXTERNAL_WORKER_STATUS.lifecycle_validation_status
      + "|lifecycle_pid=" + AC_EXTERNAL_WORKER_STATUS.lifecycle_pid
      + "|lifecycle_mode=" + AC_EXTERNAL_WORKER_STATUS.lifecycle_mode
      + "|lifecycle_loop_count=" + IntegerToString(AC_EXTERNAL_WORKER_STATUS.lifecycle_loop_count)
      + "|lifecycle_last_loop_age_seconds=" + IntegerToString(AC_EXTERNAL_WORKER_STATUS.lifecycle_last_loop_age_seconds)
      + "|exe_present_diagnostic=" + (AC_EXTERNAL_WORKER_STATUS.exe_present ? "true" : "false")
      + "|heartbeat_status=" + AC_EXTERNAL_WORKER_STATUS.heartbeat_status
      + "|heartbeat_validation_status=" + AC_EXTERNAL_WORKER_STATUS.heartbeat_validation_status
      + "|heartbeat_age_seconds=" + IntegerToString(AC_EXTERNAL_WORKER_STATUS.heartbeat_age_seconds)
      + "|result_status=" + AC_EXTERNAL_WORKER_STATUS.result_status
      + "|result_validation_status=" + AC_EXTERNAL_WORKER_STATUS.result_validation_status
      + "|result_age_seconds=" + IntegerToString(AC_EXTERNAL_WORKER_STATUS.result_age_seconds)
      + "|accepted_result=" + (AC_EXTERNAL_WORKER_STATUS.accepted_result ? "true" : "false")
      + "|result_snapshot_id=" + AC_EXTERNAL_WORKER_STATUS.result_snapshot_id
      + "|result_row_count=" + IntegerToString(AC_EXTERNAL_WORKER_STATUS.result_row_count)
      + "|result_payload_checksum=" + AC_EXTERNAL_WORKER_STATUS.result_payload_checksum
      + "|snapshot_status=" + AC_EXTERNAL_WORKER_LAST_SNAPSHOT_STATUS
      + "|snapshot_rows=" + IntegerToString(AC_EXTERNAL_WORKER_LAST_SNAPSHOT_ROWS)
      + "|snapshot_payload_checksum=" + AC_EXTERNAL_WORKER_LAST_SNAPSHOT_PAYLOAD_CHECKSUM
      + "|authority=" + AC_EXTERNAL_WORKER_STATUS.authority
      + "|trade_permission=false";
}

string AC_ExternalWorkerWorkbenchSection()
{
   if(AC_EXTERNAL_WORKER_WORKBENCH_SECTION == "")
      return "\r\nEXTERNAL_CALCULATION_WORKER\r\nstatus=not_checked\r\n";
   return AC_EXTERNAL_WORKER_WORKBENCH_SECTION;
}

string AC_ExternalWorkerStatusRow()
{
   if(AC_EXTERNAL_WORKER_STATUS_ROW == "")
      return "schema_name=external_worker_status|schema_version=v0.9|source_owner=" + AC_RUNTIME3_OWNER + "|worker_status=not_checked|trade_permission=false";
   return AC_EXTERNAL_WORKER_STATUS_ROW;
}

#endif