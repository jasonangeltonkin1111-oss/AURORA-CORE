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
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "heartbeat_status=" + AC_EXTERNAL_WORKER_STATUS.heartbeat_status + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "result_status=" + AC_EXTERNAL_WORKER_STATUS.result_status + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "snapshot_status=" + AC_EXTERNAL_WORKER_LAST_SNAPSHOT_STATUS + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "snapshot_manifest_status=" + AC_EXTERNAL_WORKER_LAST_SNAPSHOT_MANIFEST_STATUS + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "snapshot_id=" + AC_EXTERNAL_WORKER_LAST_SNAPSHOT_ID + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "snapshot_rows=" + IntegerToString(AC_EXTERNAL_WORKER_LAST_SNAPSHOT_ROWS) + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "snapshot_size=" + AC_UlongToText(AC_EXTERNAL_WORKER_LAST_SNAPSHOT_SIZE) + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "snapshot_payload_checksum=" + AC_EXTERNAL_WORKER_LAST_SNAPSHOT_PAYLOAD_CHECKSUM + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "snapshot_path=" + AC_ExternalWorkerSnapshotPath() + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "snapshot_manifest_path=" + AC_ExternalWorkerSnapshotManifestPath() + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "exe_present=" + (AC_EXTERNAL_WORKER_STATUS.exe_present ? "true" : "false") + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "heartbeat_present=" + (AC_EXTERNAL_WORKER_STATUS.heartbeat_present ? "true" : "false") + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "result_present=" + (AC_EXTERNAL_WORKER_STATUS.result_present ? "true" : "false") + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "result_manifest_present=" + (AC_EXTERNAL_WORKER_STATUS.result_manifest_present ? "true" : "false") + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "accepted_result=false\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "expected_exe_path=" + AC_EXTERNAL_WORKER_STATUS.expected_exe_path + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "required_path=" + AC_EXTERNAL_WORKER_STATUS.required_path + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "heartbeat_path=" + AC_EXTERNAL_WORKER_STATUS.heartbeat_path + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "result_path=" + AC_EXTERNAL_WORKER_STATUS.result_path + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "missing_reason=" + AC_EXTERNAL_WORKER_STATUS.missing_reason + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "last_error=" + IntegerToString(AC_EXTERNAL_WORKER_STATUS.last_error) + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "trade_permission=false\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "board_alerts=disabled_for_now\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "mt5_core_continues_if_worker_missing=true\r\n";

   AC_EXTERNAL_WORKER_STATUS_ROW = "schema_name=external_worker_status|schema_version=v0.4|source_owner=" + AC_RUNTIME3_OWNER
      + "|build_version=" + AC_BUILD_VERSION
      + "|upgrade_id=" + AC_UPGRADE_ID
      + "|required=" + (AC_EXTERNAL_WORKER_STATUS.required ? "true" : "false")
      + "|auto_launch_desired=" + (AC_EXTERNAL_WORKER_STATUS.auto_launch_desired ? "true" : "false")
      + "|launch_mode=" + AC_EXTERNAL_WORKER_STATUS.launch_mode
      + "|launch_implementation=" + AC_EXTERNAL_WORKER_STATUS.launch_implementation
      + "|launch_status=" + AC_EXTERNAL_WORKER_STATUS.launch_status
      + "|worker_status=" + AC_EXTERNAL_WORKER_STATUS.worker_status
      + "|install_status=" + AC_EXTERNAL_WORKER_STATUS.install_status
      + "|heartbeat_status=" + AC_EXTERNAL_WORKER_STATUS.heartbeat_status
      + "|result_status=" + AC_EXTERNAL_WORKER_STATUS.result_status
      + "|snapshot_status=" + AC_EXTERNAL_WORKER_LAST_SNAPSHOT_STATUS
      + "|snapshot_rows=" + IntegerToString(AC_EXTERNAL_WORKER_LAST_SNAPSHOT_ROWS)
      + "|snapshot_payload_checksum=" + AC_EXTERNAL_WORKER_LAST_SNAPSHOT_PAYLOAD_CHECKSUM
      + "|exe_present=" + (AC_EXTERNAL_WORKER_STATUS.exe_present ? "true" : "false")
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
      return "schema_name=external_worker_status|schema_version=v0.4|source_owner=" + AC_RUNTIME3_OWNER + "|worker_status=not_checked|trade_permission=false";
   return AC_EXTERNAL_WORKER_STATUS_ROW;
}

#endif
