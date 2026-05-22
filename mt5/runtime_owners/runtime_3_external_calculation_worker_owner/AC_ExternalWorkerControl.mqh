#ifndef AC_EXTERNAL_WORKER_CONTROL_MQH
#define AC_EXTERNAL_WORKER_CONTROL_MQH

void AC_BuildExternalWorkerTexts();
void AC_AppendExternalWorkerSharedSupervisorTexts();

string AC_ExternalWorkerRequiredText()
{
   string text = "";
   text += "schema_name=external_worker_required\r\n";
   text += "schema_version=2\r\n";
   text += "system_name=" + AC_SYSTEM_NAME + "\r\n";
   text += "build_version=" + AC_BUILD_VERSION + "\r\n";
   text += "upgrade_id=" + AC_UPGRADE_ID + "\r\n";
   text += "source_owner=" + AC_RUNTIME3_OWNER + "\r\n";
   text += "required=" + (AC_EXTERNAL_WORKER_REQUIRED ? "true" : "false") + "\r\n";
   text += "auto_launch_desired=" + (AC_EXTERNAL_WORKER_AUTO_LAUNCH_DESIRED ? "true" : "false") + "\r\n";
   text += "launch_mode=" + AC_EXTERNAL_WORKER_LAUNCH_MODE + "\r\n";
   text += "launch_implementation=" + AC_EXTERNAL_WORKER_LAUNCH_IMPLEMENTATION + "\r\n";
   text += "launch_cooldown_seconds=" + IntegerToString(AC_EXTERNAL_WORKER_LAUNCH_COOLDOWN_SECONDS) + "\r\n";
   text += "max_launch_attempts=" + IntegerToString(AC_EXTERNAL_WORKER_MAX_LAUNCH_ATTEMPTS) + "\r\n";
   text += "popup_alerts=false\r\n";
   text += "authority=" + AC_EXTERNAL_WORKER_AUTHORITY + "\r\n";
   text += "server=" + AC_ServerNameForRoute() + "\r\n";
   text += "account=" + AC_AccountForRoute() + "\r\n";
   text += "expected_worker_exe=" + AC_ExternalWorkerExePath() + "\r\n";
   text += "expected_packaged_worker_exe=" + AC_ExternalWorkerPackagedExePath() + "\r\n";
   text += "install_status_path=" + AC_ExternalWorkerInstallStatusPath() + "\r\n";
   text += "lifecycle_status_path=" + AC_ExternalWorkerProcessStatusPath() + "\r\n";
   text += "snapshot_path=" + AC_ExternalWorkerSnapshotPath() + "\r\n";
   text += "result_path=" + AC_ExternalWorkerResultPath() + "\r\n";
   text += "trade_permission=false\r\n";
   text += "generated_at=" + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS) + "\r\n";
   return text;
}

void AC_RefreshExternalWorkerStatus()
{
   AC_ExternalWorkerInitStatus();
   AC_EXTERNAL_WORKER_LAST_CHECK_TIME = TimeCurrent();

   int common_flag = AC_CommonFlag();
   ResetLastError();
   AC_EXTERNAL_WORKER_STATUS.exe_flat_present = FileIsExist(AC_ExternalWorkerExePath(), common_flag);
   AC_EXTERNAL_WORKER_STATUS.flat_exe_error = GetLastError();
   ResetLastError();
   AC_EXTERNAL_WORKER_STATUS.exe_folder_present = FileIsExist(AC_ExternalWorkerPackagedExePath(), common_flag);
   AC_EXTERNAL_WORKER_STATUS.folder_exe_error = GetLastError();
   AC_EXTERNAL_WORKER_STATUS.exe_present = (AC_EXTERNAL_WORKER_STATUS.exe_flat_present || AC_EXTERNAL_WORKER_STATUS.exe_folder_present);
   AC_EXTERNAL_WORKER_STATUS.last_error = AC_EXTERNAL_WORKER_STATUS.exe_present ? 0 : AC_EXTERNAL_WORKER_STATUS.flat_exe_error;

   AC_ValidateExternalWorkerInstallStatus();
   AC_ReadExternalWorkerSharedStatus();
   AC_ValidateExternalWorkerLifecycle();

   AC_EXTERNAL_WORKER_STATUS.heartbeat_present = FileIsExist(AC_ExternalWorkerHeartbeatPath(), common_flag);
   AC_EXTERNAL_WORKER_STATUS.result_manifest_present = FileIsExist(AC_ExternalWorkerResultManifestPath(), common_flag);
   AC_EXTERNAL_WORKER_STATUS.result_present = FileIsExist(AC_ExternalWorkerResultPath(), common_flag);

   if(AC_L4_READY)
      AC_ExportExternalWorkerSnapshot();

   if(AC_EXTERNAL_WORKER_STATUS.auto_launch_desired)
   {
      if(AC_EXTERNAL_WORKER_STATUS.install_task_registered == "true")
      {
         AC_EXTERNAL_WORKER_STATUS.launch_status = "Windows task registered";
         AC_EXTERNAL_WORKER_STATUS.launch_blocker = "none_registered_task_controls_worker";
      }
      else if(AC_EXTERNAL_WORKER_STATUS.launch_implementation == "not_implemented_yet")
      {
         AC_EXTERNAL_WORKER_STATUS.launch_status = "Desired - daemon task missing";
         AC_EXTERNAL_WORKER_STATUS.launch_blocker = "run install_worker_global.ps1";
      }
      else
      {
         AC_EXTERNAL_WORKER_STATUS.launch_status = "Desired - implementation configured";
         AC_EXTERNAL_WORKER_STATUS.launch_blocker = "Waiting for registered task proof";
      }
   }
   else
   {
      AC_EXTERNAL_WORKER_STATUS.launch_status = "Disabled";
      AC_EXTERNAL_WORKER_STATUS.launch_blocker = "Auto launch disabled by config";
   }

   if(!AC_EXTERNAL_WORKER_STATUS.worker_installed)
   {
      AC_EXTERNAL_WORKER_STATUS.install_status = "Missing";
      AC_EXTERNAL_WORKER_STATUS.worker_status = "Not Installed";
      AC_EXTERNAL_WORKER_STATUS.missing_reason = AC_EXTERNAL_WORKER_STATUS.install_validation_reason;
   }
   else
   {
      AC_EXTERNAL_WORKER_STATUS.install_status = "Installed";
      AC_EXTERNAL_WORKER_STATUS.worker_status = "Installed - heartbeat pending";
      AC_EXTERNAL_WORKER_STATUS.missing_reason = "";
   }

   if(AC_EXTERNAL_WORKER_STATUS.lifecycle_file_present)
   {
      if(AC_EXTERNAL_WORKER_STATUS.lifecycle_fresh)
         AC_EXTERNAL_WORKER_STATUS.worker_status = "Lifecycle fresh - heartbeat pending";
      else if(AC_EXTERNAL_WORKER_STATUS.worker_installed)
         AC_EXTERNAL_WORKER_STATUS.worker_status = "Lifecycle present - " + AC_EXTERNAL_WORKER_STATUS.lifecycle_validation_status;
   }

   if(AC_EXTERNAL_WORKER_STATUS.heartbeat_present)
   {
      AC_EXTERNAL_WORKER_STATUS.heartbeat_status = "Present";
      AC_ValidateExternalWorkerHeartbeat();
      AC_EXTERNAL_WORKER_STATUS.worker_status = AC_EXTERNAL_WORKER_STATUS.worker_installed ? "Heartbeat present - " + AC_EXTERNAL_WORKER_STATUS.heartbeat_validation_status : "Heartbeat present but install proof missing";
   }
   else
   {
      AC_EXTERNAL_WORKER_STATUS.heartbeat_status = "Missing";
      AC_EXTERNAL_WORKER_STATUS.heartbeat_validation_status = "Missing";
      AC_EXTERNAL_WORKER_STATUS.heartbeat_validation_reason = "Heartbeat file missing";
   }

   if(AC_EXTERNAL_WORKER_STATUS.result_present && AC_EXTERNAL_WORKER_STATUS.result_manifest_present)
   {
      AC_EXTERNAL_WORKER_STATUS.result_status = "Result files present - validating";
      AC_ValidateExternalWorkerResult();
      if(AC_EXTERNAL_WORKER_STATUS.accepted_result)
         AC_EXTERNAL_WORKER_STATUS.result_status = "Accepted";
      else
         AC_EXTERNAL_WORKER_STATUS.result_status = "Rejected";
   }
   else if(AC_EXTERNAL_WORKER_STATUS.result_present || AC_EXTERNAL_WORKER_STATUS.result_manifest_present)
   {
      AC_EXTERNAL_WORKER_STATUS.result_status = "Partial result files present - rejected until manifest/result pair complete";
      AC_EXTERNAL_WORKER_STATUS.result_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.result_validation_reason = "Result and manifest pair not complete";
   }
   else
   {
      AC_EXTERNAL_WORKER_STATUS.result_status = "No result yet";
      AC_EXTERNAL_WORKER_STATUS.result_validation_status = "Pending";
      AC_EXTERNAL_WORKER_STATUS.result_validation_reason = "No result files present";
   }

   AC_BuildExternalWorkerTexts();
   AC_AppendExternalWorkerSharedSupervisorTexts();
}

bool AC_ExternalWorkerShouldCheck()
{
   if(AC_EXTERNAL_WORKER_LAST_CHECK_TIME <= 0) return true;
   return (TimeCurrent() - AC_EXTERNAL_WORKER_LAST_CHECK_TIME) >= AC_EXTERNAL_WORKER_HEALTH_CHECK_SECONDS;
}

AC_WriteResult AC_WriteExternalWorkerRequired()
{
   return AC_WriteTextFile(AC_ExternalWorkerRequiredPath(), AC_ExternalWorkerRequiredText());
}

#endif