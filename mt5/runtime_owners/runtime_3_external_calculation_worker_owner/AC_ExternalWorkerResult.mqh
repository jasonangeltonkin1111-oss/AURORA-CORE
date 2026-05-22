#ifndef AC_EXTERNAL_WORKER_RESULT_MQH
#define AC_EXTERNAL_WORKER_RESULT_MQH

string AC_EWReadTextFile(const string path, const int max_chars)
{
   ResetLastError();
   int handle = FileOpen(path, AC_FileFlags() | FILE_READ);
   if(handle == INVALID_HANDLE)
      return "";
   string text = "";
   while(!FileIsEnding(handle) && StringLen(text) < max_chars)
      text += FileReadString(handle) + "\n";
   FileClose(handle);
   return text;
}

string AC_EWValue(const string text, const string key)
{
   string pattern = key + "=";
   string lines[];
   ushort separator = StringGetCharacter("\n", 0);
   int count = StringSplit(text, separator, lines);

   for(int i = 0; i < count; i++)
   {
      string line = lines[i];
      StringReplace(line, "\r", "");
      StringTrimLeft(line);
      StringTrimRight(line);

      if(StringFind(line, pattern) != 0)
         continue;

      string value = StringSubstr(line, StringLen(pattern));
      StringTrimLeft(value);
      StringTrimRight(value);
      return value;
   }

   return "";
}

bool AC_LoadExternalWorkerInstallText(string &install_text)
{
   AC_EXTERNAL_WORKER_STATUS.install_status_file_present = FileIsExist(AC_ExternalWorkerInstallStatusPath(), AC_CommonFlag());
   AC_EXTERNAL_WORKER_STATUS.shared_install_status_file_present = FileIsExist(AC_SharedExternalWorkerInstallStatusPath(), AC_CommonFlag());

   if(AC_EXTERNAL_WORKER_STATUS.install_status_file_present)
   {
      install_text = AC_EWReadTextFile(AC_ExternalWorkerInstallStatusPath(), 8000);
      if(install_text != "")
      {
         AC_EXTERNAL_WORKER_STATUS.install_status_source = "account_worker_install_status.txt";
         AC_EXTERNAL_WORKER_STATUS.install_status_path = AC_ExternalWorkerInstallStatusPath();
         return true;
      }
   }

   if(AC_EXTERNAL_WORKER_STATUS.shared_install_status_file_present)
   {
      install_text = AC_EWReadTextFile(AC_SharedExternalWorkerInstallStatusPath(), 8000);
      if(install_text != "")
      {
         AC_EXTERNAL_WORKER_STATUS.install_status_source = "shared_worker_install_status.txt";
         AC_EXTERNAL_WORKER_STATUS.install_status_path = AC_SharedExternalWorkerInstallStatusPath();
         AC_EXTERNAL_WORKER_STATUS.install_status_file_present = true;
         return true;
      }
   }

   install_text = "";
   return false;
}

void AC_ValidateExternalWorkerInstallStatus()
{
   string install_text = "";
   if(!AC_LoadExternalWorkerInstallText(install_text))
   {
      AC_EXTERNAL_WORKER_STATUS.worker_installed = false;
      AC_EXTERNAL_WORKER_STATUS.install_status = "Missing";
      AC_EXTERNAL_WORKER_STATUS.install_validation_status = "Missing";
      AC_EXTERNAL_WORKER_STATUS.install_validation_reason = "worker install proof missing from account and shared status paths";
      AC_EXTERNAL_WORKER_STATUS.install_status_age_seconds = -1;
      return;
   }

   string installed = AC_EWValue(install_text, "installed");
   string authority = AC_EWValue(install_text, "authority");
   string trade_permission = AC_EWValue(install_text, "trade_permission");
   string generated_unix = AC_EWValue(install_text, "generated_unix");
   AC_EXTERNAL_WORKER_STATUS.install_worker_version = AC_EWValue(install_text, "worker_version");
   AC_EXTERNAL_WORKER_STATUS.install_flat_exe_present = AC_EWValue(install_text, "flat_exe_present");
   AC_EXTERNAL_WORKER_STATUS.install_packaged_exe_present = AC_EWValue(install_text, "packaged_exe_present");
   AC_EXTERNAL_WORKER_STATUS.install_flat_exe_runtime_authority = AC_EWValue(install_text, "flat_exe_runtime_authority");
   AC_EXTERNAL_WORKER_STATUS.install_packaged_exe_runtime_authority = AC_EWValue(install_text, "packaged_exe_runtime_authority");
   AC_EXTERNAL_WORKER_STATUS.install_packaged_internal_python_dll_present = AC_EWValue(install_text, "packaged_internal_python_dll_present");
   AC_EXTERNAL_WORKER_STATUS.install_daemon_method = AC_EWValue(install_text, "daemon_install_method");
   AC_EXTERNAL_WORKER_STATUS.install_task_name = AC_EWValue(install_text, "scheduled_task_name");
   AC_EXTERNAL_WORKER_STATUS.install_task_registered = AC_EWValue(install_text, "scheduled_task_registered");
   AC_EXTERNAL_WORKER_STATUS.install_task_state = AC_EWValue(install_text, "scheduled_task_state");
   AC_EXTERNAL_WORKER_STATUS.install_task_error = AC_EWValue(install_text, "scheduled_task_error");
   AC_EXTERNAL_WORKER_STATUS.install_auto_start_configured = AC_EWValue(install_text, "auto_start_configured");
   AC_EXTERNAL_WORKER_STATUS.install_watchdog_method = AC_EWValue(install_text, "watchdog_install_method");
   AC_EXTERNAL_WORKER_STATUS.install_watchdog_task_name = AC_EWValue(install_text, "watchdog_task_name");
   AC_EXTERNAL_WORKER_STATUS.install_watchdog_task_registered = AC_EWValue(install_text, "watchdog_task_registered");
   AC_EXTERNAL_WORKER_STATUS.install_watchdog_task_state = AC_EWValue(install_text, "watchdog_task_state");
   AC_EXTERNAL_WORKER_STATUS.install_watchdog_task_error = AC_EWValue(install_text, "watchdog_task_error");
   AC_EXTERNAL_WORKER_STATUS.install_operator_cmd_required = AC_EWValue(install_text, "operator_cmd_required");

   if(installed != "true")
   {
      AC_EXTERNAL_WORKER_STATUS.worker_installed = false;
      AC_EXTERNAL_WORKER_STATUS.install_status = "Missing";
      AC_EXTERNAL_WORKER_STATUS.install_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.install_validation_reason = "installed flag is not true";
      return;
   }
   if(authority != AC_EXTERNAL_WORKER_AUTHORITY)
   {
      AC_EXTERNAL_WORKER_STATUS.worker_installed = false;
      AC_EXTERNAL_WORKER_STATUS.install_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.install_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.install_validation_reason = "install authority mismatch";
      return;
   }
   if(trade_permission != "false")
   {
      AC_EXTERNAL_WORKER_STATUS.worker_installed = false;
      AC_EXTERNAL_WORKER_STATUS.install_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.install_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.install_validation_reason = "install trade permission is not false";
      return;
   }

   long generated = (long)StringToInteger(generated_unix);
   if(generated > 0)
   {
      long age = (long)TimeGMT() - generated;
      if(age < 0) age = 0;
      AC_EXTERNAL_WORKER_STATUS.install_status_age_seconds = (int)age;
   }
   else
   {
      AC_EXTERNAL_WORKER_STATUS.install_status_age_seconds = -1;
   }

   AC_EXTERNAL_WORKER_STATUS.worker_installed = true;
   AC_EXTERNAL_WORKER_STATUS.install_status = "Installed";
   AC_EXTERNAL_WORKER_STATUS.install_validation_status = "Accepted";
   AC_EXTERNAL_WORKER_STATUS.install_validation_reason = "worker install proof accepted from " + AC_EXTERNAL_WORKER_STATUS.install_status_source;
}

void AC_ReadExternalWorkerSharedStatus()
{
   AC_EXTERNAL_WORKER_STATUS.shared_status_file_present = FileIsExist(AC_SharedExternalWorkerStatusPath(), AC_CommonFlag());
   if(!AC_EXTERNAL_WORKER_STATUS.shared_status_file_present)
   {
      AC_EXTERNAL_WORKER_STATUS.shared_status_validation_status = "Missing";
      AC_EXTERNAL_WORKER_STATUS.shared_status_validation_reason = "shared_worker_status.txt missing";
      AC_EXTERNAL_WORKER_STATUS.shared_status_age_seconds = -1;
      return;
   }

   string shared_text = AC_EWReadTextFile(AC_SharedExternalWorkerStatusPath(), 12000);
   if(shared_text == "")
   {
      AC_EXTERNAL_WORKER_STATUS.shared_status_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.shared_status_validation_reason = "shared_worker_status.txt could not be read";
      AC_EXTERNAL_WORKER_STATUS.shared_status_age_seconds = -1;
      return;
   }

   string authority = AC_EWValue(shared_text, "authority");
   string trade_permission = AC_EWValue(shared_text, "trade_permission");
   string generated_unix = AC_EWValue(shared_text, "last_loop_unix");
   AC_EXTERNAL_WORKER_STATUS.shared_status_worker_version = AC_EWValue(shared_text, "worker_version");
   AC_EXTERNAL_WORKER_STATUS.shared_status_mode = AC_EWValue(shared_text, "mode");
   AC_EXTERNAL_WORKER_STATUS.shared_status_loop_count = AC_EWValue(shared_text, "loop_count");
   AC_EXTERNAL_WORKER_STATUS.shared_status_discovered_root_count = AC_EWValue(shared_text, "discovered_root_count");
   AC_EXTERNAL_WORKER_STATUS.shared_status_processed_root_count = AC_EWValue(shared_text, "processed_root_count");
   AC_EXTERNAL_WORKER_STATUS.shared_status_accepted_root_count = AC_EWValue(shared_text, "accepted_root_count");
   AC_EXTERNAL_WORKER_STATUS.shared_status_degraded_root_count = AC_EWValue(shared_text, "degraded_root_count");
   AC_EXTERNAL_WORKER_STATUS.shared_daemon_task_registered = AC_EWValue(shared_text, "daemon_task_registered");
   AC_EXTERNAL_WORKER_STATUS.shared_daemon_task_state = AC_EWValue(shared_text, "daemon_task_state");
   AC_EXTERNAL_WORKER_STATUS.shared_watchdog_task_registered = AC_EWValue(shared_text, "watchdog_task_registered");
   AC_EXTERNAL_WORKER_STATUS.shared_watchdog_task_state = AC_EWValue(shared_text, "watchdog_task_state");
   AC_EXTERNAL_WORKER_STATUS.shared_watchdog_last_check_utc = AC_EWValue(shared_text, "watchdog_last_check_utc");
   AC_EXTERNAL_WORKER_STATUS.shared_watchdog_last_action = AC_EWValue(shared_text, "watchdog_last_action");
   AC_EXTERNAL_WORKER_STATUS.shared_watchdog_last_reason = AC_EWValue(shared_text, "watchdog_last_reason");
   AC_EXTERNAL_WORKER_STATUS.shared_watchdog_restart_attempted = AC_EWValue(shared_text, "watchdog_restart_attempted");
   AC_EXTERNAL_WORKER_STATUS.shared_watchdog_restart_result = AC_EWValue(shared_text, "watchdog_restart_result");
   AC_EXTERNAL_WORKER_STATUS.shared_operator_cmd_required = AC_EWValue(shared_text, "operator_cmd_required");
   AC_EXTERNAL_WORKER_STATUS.shared_cpu_logical_count = AC_EWValue(shared_text, "cpu_logical_count");
   AC_EXTERNAL_WORKER_STATUS.shared_cpu_used_percent = AC_EWValue(shared_text, "cpu_used_percent");
   AC_EXTERNAL_WORKER_STATUS.shared_memory_total_mb = AC_EWValue(shared_text, "memory_total_mb");
   AC_EXTERNAL_WORKER_STATUS.shared_memory_available_mb = AC_EWValue(shared_text, "memory_available_mb");
   AC_EXTERNAL_WORKER_STATUS.shared_memory_used_percent = AC_EWValue(shared_text, "memory_used_percent");
   AC_EXTERNAL_WORKER_STATUS.shared_memory_limit_percent = AC_EWValue(shared_text, "memory_limit_percent");
   AC_EXTERNAL_WORKER_STATUS.shared_cpu_limit_percent = AC_EWValue(shared_text, "cpu_limit_percent");
   AC_EXTERNAL_WORKER_STATUS.shared_terminal_process_count = AC_EWValue(shared_text, "terminal_process_count");
   AC_EXTERNAL_WORKER_STATUS.shared_aurora_worker_process_count = AC_EWValue(shared_text, "aurora_worker_process_count");
   AC_EXTERNAL_WORKER_STATUS.shared_registered_root_count = AC_EWValue(shared_text, "registered_root_count");
   AC_EXTERNAL_WORKER_STATUS.shared_resource_throttle_active = AC_EWValue(shared_text, "resource_throttle_active");
   AC_EXTERNAL_WORKER_STATUS.shared_resource_throttle_reason = AC_EWValue(shared_text, "resource_throttle_reason");
   AC_EXTERNAL_WORKER_STATUS.shared_recommended_parallel_jobs = AC_EWValue(shared_text, "recommended_parallel_jobs");

   if(authority != AC_EXTERNAL_WORKER_AUTHORITY)
   {
      AC_EXTERNAL_WORKER_STATUS.shared_status_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.shared_status_validation_reason = "shared status authority mismatch";
      return;
   }
   if(trade_permission != "false")
   {
      AC_EXTERNAL_WORKER_STATUS.shared_status_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.shared_status_validation_reason = "shared status trade permission is not false";
      return;
   }

   long generated = (long)StringToInteger(generated_unix);
   if(generated > 0)
   {
      long age = (long)TimeGMT() - generated;
      if(age < 0) age = 0;
      AC_EXTERNAL_WORKER_STATUS.shared_status_age_seconds = (int)age;
   }
   else
   {
      AC_EXTERNAL_WORKER_STATUS.shared_status_age_seconds = -1;
   }

   AC_EXTERNAL_WORKER_STATUS.shared_status_validation_status = "Accepted";
   AC_EXTERNAL_WORKER_STATUS.shared_status_validation_reason = "shared supervisor status accepted";
}

void AC_ValidateExternalWorkerLifecycle()
{
   AC_EXTERNAL_WORKER_STATUS.lifecycle_file_present = FileIsExist(AC_ExternalWorkerProcessStatusPath(), AC_CommonFlag());
   if(!AC_EXTERNAL_WORKER_STATUS.lifecycle_file_present)
   {
      AC_EXTERNAL_WORKER_STATUS.lifecycle_fresh = false;
      AC_EXTERNAL_WORKER_STATUS.lifecycle_status = "Missing";
      AC_EXTERNAL_WORKER_STATUS.lifecycle_validation_status = "Missing";
      AC_EXTERNAL_WORKER_STATUS.lifecycle_validation_reason = "worker_process_status.txt missing";
      AC_EXTERNAL_WORKER_STATUS.lifecycle_last_loop_age_seconds = -1;
      return;
   }

   string lifecycle_text = AC_EWReadTextFile(AC_ExternalWorkerProcessStatusPath(), 8000);
   if(lifecycle_text == "")
   {
      AC_EXTERNAL_WORKER_STATUS.lifecycle_fresh = false;
      AC_EXTERNAL_WORKER_STATUS.lifecycle_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.lifecycle_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.lifecycle_validation_reason = "worker_process_status.txt could not be read";
      return;
   }

   string authority = AC_EWValue(lifecycle_text, "authority");
   string trade_permission = AC_EWValue(lifecycle_text, "trade_permission");
   string generated_unix = AC_EWValue(lifecycle_text, "generated_unix");
   string last_loop_unix = AC_EWValue(lifecycle_text, "last_loop_unix");
   AC_EXTERNAL_WORKER_STATUS.lifecycle_worker_version = AC_EWValue(lifecycle_text, "worker_version");
   AC_EXTERNAL_WORKER_STATUS.lifecycle_pid = AC_EWValue(lifecycle_text, "process_id");
   AC_EXTERNAL_WORKER_STATUS.lifecycle_mode = AC_EWValue(lifecycle_text, "mode");
   AC_EXTERNAL_WORKER_STATUS.lifecycle_start_utc = AC_EWValue(lifecycle_text, "process_start_utc");
   AC_EXTERNAL_WORKER_STATUS.lifecycle_last_loop_utc = AC_EWValue(lifecycle_text, "last_loop_utc");
   AC_EXTERNAL_WORKER_STATUS.lifecycle_loop_count = (int)StringToInteger(AC_EWValue(lifecycle_text, "loop_count"));
   AC_EXTERNAL_WORKER_STATUS.lifecycle_last_run_exit_code = (int)StringToInteger(AC_EWValue(lifecycle_text, "last_run_exit_code"));
   AC_EXTERNAL_WORKER_STATUS.lifecycle_last_validation_status = AC_EWValue(lifecycle_text, "last_validation_status");
   AC_EXTERNAL_WORKER_STATUS.lifecycle_last_validation_reason = AC_EWValue(lifecycle_text, "last_validation_reason");
   AC_EXTERNAL_WORKER_STATUS.lifecycle_last_snapshot_id = AC_EWValue(lifecycle_text, "last_snapshot_id");
   AC_EXTERNAL_WORKER_STATUS.lifecycle_last_job_id = AC_EWValue(lifecycle_text, "last_job_id");
   AC_EXTERNAL_WORKER_STATUS.lifecycle_last_job_type = AC_EWValue(lifecycle_text, "last_job_type");
   AC_EXTERNAL_WORKER_STATUS.lifecycle_payload_checksum = AC_EWValue(lifecycle_text, "payload_checksum");

   if(authority != AC_EXTERNAL_WORKER_AUTHORITY)
   {
      AC_EXTERNAL_WORKER_STATUS.lifecycle_fresh = false;
      AC_EXTERNAL_WORKER_STATUS.lifecycle_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.lifecycle_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.lifecycle_validation_reason = "lifecycle authority mismatch";
      return;
   }
   if(trade_permission != "false")
   {
      AC_EXTERNAL_WORKER_STATUS.lifecycle_fresh = false;
      AC_EXTERNAL_WORKER_STATUS.lifecycle_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.lifecycle_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.lifecycle_validation_reason = "lifecycle trade permission is not false";
      return;
   }

   long generated = (long)StringToInteger(generated_unix);
   long last_loop = (long)StringToInteger(last_loop_unix);
   if(generated <= 0 || last_loop <= 0)
   {
      AC_EXTERNAL_WORKER_STATUS.lifecycle_fresh = false;
      AC_EXTERNAL_WORKER_STATUS.lifecycle_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.lifecycle_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.lifecycle_validation_reason = "lifecycle timestamp missing";
      return;
   }

   long age = (long)TimeGMT() - last_loop;
   if(age < 0) age = 0;
   AC_EXTERNAL_WORKER_STATUS.lifecycle_last_loop_age_seconds = (int)age;
   if(age > AC_EXTERNAL_WORKER_HEARTBEAT_MAX_AGE_SECONDS)
   {
      AC_EXTERNAL_WORKER_STATUS.lifecycle_fresh = false;
      AC_EXTERNAL_WORKER_STATUS.lifecycle_status = "Stale";
      AC_EXTERNAL_WORKER_STATUS.lifecycle_validation_status = "Stale";
      AC_EXTERNAL_WORKER_STATUS.lifecycle_validation_reason = "worker lifecycle loop older than allowed max age";
      return;
   }

   AC_EXTERNAL_WORKER_STATUS.lifecycle_fresh = true;
   AC_EXTERNAL_WORKER_STATUS.lifecycle_status = "Fresh";
   AC_EXTERNAL_WORKER_STATUS.lifecycle_validation_status = "Fresh";
   AC_EXTERNAL_WORKER_STATUS.lifecycle_validation_reason = "worker_process_status.txt accepted";
}

void AC_ValidateExternalWorkerHeartbeat()
{
   if(!AC_EXTERNAL_WORKER_STATUS.heartbeat_present)
   {
      AC_EXTERNAL_WORKER_STATUS.heartbeat_validation_status = "Missing";
      AC_EXTERNAL_WORKER_STATUS.heartbeat_validation_reason = "Heartbeat file missing";
      AC_EXTERNAL_WORKER_STATUS.heartbeat_age_seconds = -1;
      return;
   }
   string heartbeat_text = AC_EWReadTextFile(AC_ExternalWorkerHeartbeatPath(), 8000);
   if(heartbeat_text == "")
   {
      AC_EXTERNAL_WORKER_STATUS.heartbeat_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.heartbeat_validation_reason = "Heartbeat could not be read";
      AC_EXTERNAL_WORKER_STATUS.heartbeat_age_seconds = -1;
      return;
   }
   string authority = AC_EWValue(heartbeat_text, "authority");
   string trade_permission = AC_EWValue(heartbeat_text, "trade_permission");
   string generated_unix = AC_EWValue(heartbeat_text, "generated_unix");
   AC_EXTERNAL_WORKER_STATUS.heartbeat_job_bus_schema_version = AC_EWValue(heartbeat_text, "last_job_bus_schema_version");
   AC_EXTERNAL_WORKER_STATUS.heartbeat_job_id = AC_EWValue(heartbeat_text, "last_job_id");
   AC_EXTERNAL_WORKER_STATUS.heartbeat_job_type = AC_EWValue(heartbeat_text, "last_job_type");
   if(authority != AC_EXTERNAL_WORKER_AUTHORITY)
   {
      AC_EXTERNAL_WORKER_STATUS.heartbeat_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.heartbeat_validation_reason = "Heartbeat authority mismatch";
      return;
   }
   if(trade_permission != "false")
   {
      AC_EXTERNAL_WORKER_STATUS.heartbeat_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.heartbeat_validation_reason = "Heartbeat trade permission is not false";
      return;
   }
   long generated = (long)StringToInteger(generated_unix);
   if(generated <= 0)
   {
      AC_EXTERNAL_WORKER_STATUS.heartbeat_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.heartbeat_validation_reason = "Heartbeat generated_unix missing";
      return;
   }
   long age = (long)TimeGMT() - generated;
   if(age < 0) age = 0;
   AC_EXTERNAL_WORKER_STATUS.heartbeat_age_seconds = (int)age;
   AC_EXTERNAL_WORKER_STATUS.last_heartbeat_seen = (datetime)generated;
   if(age > AC_EXTERNAL_WORKER_HEARTBEAT_MAX_AGE_SECONDS)
   {
      AC_EXTERNAL_WORKER_STATUS.heartbeat_validation_status = "Stale";
      AC_EXTERNAL_WORKER_STATUS.heartbeat_validation_reason = "Heartbeat older than allowed max age";
      return;
   }
   AC_EXTERNAL_WORKER_STATUS.heartbeat_validation_status = "Fresh";
   AC_EXTERNAL_WORKER_STATUS.heartbeat_validation_reason = "Heartbeat accepted";
}

void AC_ValidateExternalWorkerResult()
{
   if(!AC_EXTERNAL_WORKER_STATUS.result_present || !AC_EXTERNAL_WORKER_STATUS.result_manifest_present)
   {
      AC_EXTERNAL_WORKER_STATUS.accepted_result = false;
      AC_EXTERNAL_WORKER_STATUS.result_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.result_validation_reason = "Result and manifest pair not complete";
      return;
   }

   string result_text = AC_EWReadTextFile(AC_ExternalWorkerResultPath(), 12000);
   string manifest_text = AC_EWReadTextFile(AC_ExternalWorkerResultManifestPath(), 8000);
   if(result_text == "" || manifest_text == "")
   {
      AC_EXTERNAL_WORKER_STATUS.accepted_result = false;
      AC_EXTERNAL_WORKER_STATUS.result_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.result_validation_reason = "Result or manifest could not be read";
      return;
   }

   string result_status = AC_EWValue(result_text, "result_status");
   string result_reason = AC_EWValue(result_text, "result_reason");
   string result_authority = AC_EWValue(result_text, "authority");
   string result_trade_permission = AC_EWValue(result_text, "trade_permission");
   string result_snapshot_id = AC_EWValue(result_text, "source_snapshot_id");
   string result_row_count = AC_EWValue(result_text, "row_count");
   string result_checksum = AC_EWValue(result_text, "payload_checksum");
   string result_generated_unix = AC_EWValue(result_text, "generated_unix");
   string result_job_bus_schema = AC_EWValue(result_text, "job_bus_schema_version");
   string result_job_id = AC_EWValue(result_text, "job_id");
   string result_job_type = AC_EWValue(result_text, "job_type");
   string result_job_resource_class = AC_EWValue(result_text, "job_resource_class");
   string result_job_max_runtime_ms = AC_EWValue(result_text, "job_max_runtime_ms");
   string result_job_status = AC_EWValue(result_text, "job_status");

   string manifest_status = AC_EWValue(manifest_text, "result_status");
   string manifest_authority = AC_EWValue(manifest_text, "authority");
   string manifest_trade_permission = AC_EWValue(manifest_text, "trade_permission");
   string manifest_snapshot_id = AC_EWValue(manifest_text, "source_snapshot_id");
   string manifest_row_count = AC_EWValue(manifest_text, "row_count");
   string manifest_checksum = AC_EWValue(manifest_text, "payload_checksum");
   string manifest_generated_unix = AC_EWValue(manifest_text, "generated_unix");
   string manifest_job_bus_schema = AC_EWValue(manifest_text, "job_bus_schema_version");
   string manifest_job_id = AC_EWValue(manifest_text, "job_id");
   string manifest_job_type = AC_EWValue(manifest_text, "job_type");
   string manifest_job_resource_class = AC_EWValue(manifest_text, "job_resource_class");
   string manifest_job_max_runtime_ms = AC_EWValue(manifest_text, "job_max_runtime_ms");
   string manifest_job_status = AC_EWValue(manifest_text, "job_status");

   AC_EXTERNAL_WORKER_STATUS.result_snapshot_id = result_snapshot_id;
   AC_EXTERNAL_WORKER_STATUS.result_job_bus_schema_version = result_job_bus_schema;
   AC_EXTERNAL_WORKER_STATUS.result_job_id = result_job_id;
   AC_EXTERNAL_WORKER_STATUS.result_job_type = result_job_type;
   AC_EXTERNAL_WORKER_STATUS.result_job_resource_class = result_job_resource_class;
   AC_EXTERNAL_WORKER_STATUS.result_job_max_runtime_ms = result_job_max_runtime_ms;
   AC_EXTERNAL_WORKER_STATUS.result_job_status = result_job_status;
   AC_EXTERNAL_WORKER_STATUS.job_bus_expected_job_id = AC_EXTERNAL_WORKER_LAST_JOB_ID;
   AC_EXTERNAL_WORKER_STATUS.job_bus_expected_job_type = AC_EXTERNAL_WORKER_LAST_JOB_TYPE;
   AC_EXTERNAL_WORKER_STATUS.job_bus_expected_schema_version = AC_EXTERNAL_WORKER_JOB_BUS_SCHEMA_VERSION;
   AC_EXTERNAL_WORKER_STATUS.job_bus_result_job_id = result_job_id;
   AC_EXTERNAL_WORKER_STATUS.job_bus_result_job_type = result_job_type;
   AC_EXTERNAL_WORKER_STATUS.job_bus_result_schema_version = result_job_bus_schema;
   AC_EXTERNAL_WORKER_STATUS.result_authority = result_authority;
   AC_EXTERNAL_WORKER_STATUS.result_trade_permission = result_trade_permission;
   AC_EXTERNAL_WORKER_STATUS.result_payload_checksum = result_checksum;
   AC_EXTERNAL_WORKER_STATUS.result_row_count = (int)StringToInteger(result_row_count);

   if(!AC_EXTERNAL_WORKER_STATUS.install_status_file_present
      || !AC_EXTERNAL_WORKER_STATUS.worker_installed
      || AC_EXTERNAL_WORKER_STATUS.install_validation_status != "Accepted")
   {
      AC_EXTERNAL_WORKER_STATUS.accepted_result = false;
      AC_EXTERNAL_WORKER_STATUS.result_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.result_validation_reason = "Install status proof is not accepted";
      return;
   }
   if(AC_EXTERNAL_WORKER_STATUS.heartbeat_validation_status != "Fresh")
   {
      AC_EXTERNAL_WORKER_STATUS.accepted_result = false;
      AC_EXTERNAL_WORKER_STATUS.result_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.result_validation_reason = "Heartbeat is not fresh";
      return;
   }
   if(result_authority != AC_EXTERNAL_WORKER_AUTHORITY || manifest_authority != AC_EXTERNAL_WORKER_AUTHORITY)
   {
      AC_EXTERNAL_WORKER_STATUS.accepted_result = false;
      AC_EXTERNAL_WORKER_STATUS.result_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.result_validation_reason = "Authority mismatch";
      return;
   }
   if(result_trade_permission != "false" || manifest_trade_permission != "false")
   {
      AC_EXTERNAL_WORKER_STATUS.accepted_result = false;
      AC_EXTERNAL_WORKER_STATUS.result_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.result_validation_reason = "Trade permission field is not false";
      return;
   }
   if(result_status != "complete" || manifest_status != "complete")
   {
      AC_EXTERNAL_WORKER_STATUS.accepted_result = false;
      AC_EXTERNAL_WORKER_STATUS.result_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.result_validation_reason = "Worker result not complete: " + result_reason;
      return;
   }
   if(result_snapshot_id == "" || result_snapshot_id != manifest_snapshot_id)
   {
      AC_EXTERNAL_WORKER_STATUS.accepted_result = false;
      AC_EXTERNAL_WORKER_STATUS.result_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.result_validation_reason = "Snapshot id mismatch";
      return;
   }
   if(result_snapshot_id != AC_EXTERNAL_WORKER_LAST_SNAPSHOT_ID)
   {
      AC_EXTERNAL_WORKER_STATUS.accepted_result = false;
      AC_EXTERNAL_WORKER_STATUS.result_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.result_validation_reason = "Result snapshot id does not match latest MT5 snapshot";
      return;
   }
   if(result_job_bus_schema == "" || result_job_bus_schema != manifest_job_bus_schema || result_job_bus_schema != AC_EXTERNAL_WORKER_JOB_BUS_SCHEMA_VERSION)
   {
      AC_EXTERNAL_WORKER_STATUS.accepted_result = false;
      AC_EXTERNAL_WORKER_STATUS.job_bus_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.job_bus_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.job_bus_validation_reason = "Job bus schema mismatch";
      AC_EXTERNAL_WORKER_STATUS.result_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.result_validation_reason = "Job bus schema mismatch";
      return;
   }
   if(result_job_id == "" || result_job_id != manifest_job_id || result_job_id != AC_EXTERNAL_WORKER_LAST_JOB_ID)
   {
      AC_EXTERNAL_WORKER_STATUS.accepted_result = false;
      AC_EXTERNAL_WORKER_STATUS.job_bus_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.job_bus_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.job_bus_validation_reason = "Job id mismatch";
      AC_EXTERNAL_WORKER_STATUS.result_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.result_validation_reason = "Job id mismatch";
      return;
   }
   if(result_job_type == "" || result_job_type != manifest_job_type || result_job_type != AC_EXTERNAL_WORKER_LAST_JOB_TYPE)
   {
      AC_EXTERNAL_WORKER_STATUS.accepted_result = false;
      AC_EXTERNAL_WORKER_STATUS.job_bus_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.job_bus_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.job_bus_validation_reason = "Job type mismatch";
      AC_EXTERNAL_WORKER_STATUS.result_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.result_validation_reason = "Job type mismatch";
      return;
   }
   if(result_job_resource_class == "" || result_job_resource_class != manifest_job_resource_class)
   {
      AC_EXTERNAL_WORKER_STATUS.accepted_result = false;
      AC_EXTERNAL_WORKER_STATUS.job_bus_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.job_bus_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.job_bus_validation_reason = "Job resource class mismatch";
      AC_EXTERNAL_WORKER_STATUS.result_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.result_validation_reason = "Job resource class mismatch";
      return;
   }
   if(result_job_max_runtime_ms == "" || result_job_max_runtime_ms != manifest_job_max_runtime_ms)
   {
      AC_EXTERNAL_WORKER_STATUS.accepted_result = false;
      AC_EXTERNAL_WORKER_STATUS.job_bus_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.job_bus_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.job_bus_validation_reason = "Job max runtime mismatch";
      AC_EXTERNAL_WORKER_STATUS.result_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.result_validation_reason = "Job max runtime mismatch";
      return;
   }
   if(result_job_status != "complete" || manifest_job_status != "complete")
   {
      AC_EXTERNAL_WORKER_STATUS.accepted_result = false;
      AC_EXTERNAL_WORKER_STATUS.job_bus_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.job_bus_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.job_bus_validation_reason = "Job status is not complete";
      AC_EXTERNAL_WORKER_STATUS.result_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.result_validation_reason = "Job status is not complete";
      return;
   }
   if(result_row_count == "" || result_row_count != manifest_row_count)
   {
      AC_EXTERNAL_WORKER_STATUS.accepted_result = false;
      AC_EXTERNAL_WORKER_STATUS.result_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.result_validation_reason = "Row count mismatch";
      return;
   }
   if((int)StringToInteger(result_row_count) != AC_EXTERNAL_WORKER_LAST_SNAPSHOT_ROWS)
   {
      AC_EXTERNAL_WORKER_STATUS.accepted_result = false;
      AC_EXTERNAL_WORKER_STATUS.result_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.result_validation_reason = "Result row count does not match latest MT5 snapshot";
      return;
   }
   if(result_checksum == "" || result_checksum != manifest_checksum)
   {
      AC_EXTERNAL_WORKER_STATUS.accepted_result = false;
      AC_EXTERNAL_WORKER_STATUS.result_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.result_validation_reason = "Payload checksum mismatch";
      return;
   }
   if(result_checksum != AC_EXTERNAL_WORKER_LAST_SNAPSHOT_PAYLOAD_CHECKSUM)
   {
      AC_EXTERNAL_WORKER_STATUS.accepted_result = false;
      AC_EXTERNAL_WORKER_STATUS.result_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.result_validation_reason = "Result checksum does not match latest MT5 snapshot";
      return;
   }
   if(result_generated_unix == "" || result_generated_unix != manifest_generated_unix)
   {
      AC_EXTERNAL_WORKER_STATUS.accepted_result = false;
      AC_EXTERNAL_WORKER_STATUS.result_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.result_validation_reason = "Result generated_unix mismatch";
      return;
   }
   long generated = (long)StringToInteger(result_generated_unix);
   if(generated <= 0)
   {
      AC_EXTERNAL_WORKER_STATUS.accepted_result = false;
      AC_EXTERNAL_WORKER_STATUS.result_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.result_validation_reason = "Result generated_unix missing";
      return;
   }
   long age = (long)TimeGMT() - generated;
   if(age < 0) age = 0;
   AC_EXTERNAL_WORKER_STATUS.result_age_seconds = (int)age;
   AC_EXTERNAL_WORKER_STATUS.last_result_seen = (datetime)generated;
   if(age > AC_EXTERNAL_WORKER_RESULT_MAX_AGE_SECONDS)
   {
      AC_EXTERNAL_WORKER_STATUS.accepted_result = false;
      AC_EXTERNAL_WORKER_STATUS.result_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.result_validation_reason = "Result older than allowed max age";
      return;
   }

   AC_EXTERNAL_WORKER_STATUS.accepted_result = true;
   AC_EXTERNAL_WORKER_STATUS.job_bus_status = "Accepted";
   AC_EXTERNAL_WORKER_STATUS.job_bus_validation_status = "Accepted";
   AC_EXTERNAL_WORKER_STATUS.job_bus_validation_reason = "R3 snapshot validation result bound to latest MT5 job envelope";
   AC_EXTERNAL_WORKER_STATUS.result_validation_status = "Accepted";
   AC_EXTERNAL_WORKER_STATUS.result_validation_reason = "R3 snapshot validation result bound to accepted install proof, fresh heartbeat, latest MT5 snapshot, and latest MT5 job envelope";
}

#endif