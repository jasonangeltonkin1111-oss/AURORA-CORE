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
   int start = StringFind(text, pattern);
   if(start < 0) return "";
   start += StringLen(pattern);
   int end = StringFind(text, "\n", start);
   if(end < 0) end = StringLen(text);
   string value = StringSubstr(text, start, end - start);
   StringTrimLeft(value);
   StringTrimRight(value);
   StringReplace(value, "\r", "");
   return value;
}

void AC_ValidateExternalWorkerInstallStatus()
{
   AC_EXTERNAL_WORKER_STATUS.install_status_file_present = FileIsExist(AC_ExternalWorkerInstallStatusPath(), AC_CommonFlag());
   if(!AC_EXTERNAL_WORKER_STATUS.install_status_file_present)
   {
      AC_EXTERNAL_WORKER_STATUS.worker_installed = false;
      AC_EXTERNAL_WORKER_STATUS.install_status = "Missing";
      AC_EXTERNAL_WORKER_STATUS.install_validation_status = "Missing";
      AC_EXTERNAL_WORKER_STATUS.install_validation_reason = "worker_install_status.txt missing";
      AC_EXTERNAL_WORKER_STATUS.install_status_age_seconds = -1;
      return;
   }

   string install_text = AC_EWReadTextFile(AC_ExternalWorkerInstallStatusPath(), 8000);
   if(install_text == "")
   {
      AC_EXTERNAL_WORKER_STATUS.worker_installed = false;
      AC_EXTERNAL_WORKER_STATUS.install_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.install_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.install_validation_reason = "worker_install_status.txt could not be read";
      return;
   }

   string installed = AC_EWValue(install_text, "installed");
   string authority = AC_EWValue(install_text, "authority");
   string trade_permission = AC_EWValue(install_text, "trade_permission");
   string generated_unix = AC_EWValue(install_text, "generated_unix");
   AC_EXTERNAL_WORKER_STATUS.install_worker_version = AC_EWValue(install_text, "worker_version");
   AC_EXTERNAL_WORKER_STATUS.install_flat_exe_present = AC_EWValue(install_text, "flat_exe_present");
   AC_EXTERNAL_WORKER_STATUS.install_packaged_exe_present = AC_EWValue(install_text, "packaged_exe_present");

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
   AC_EXTERNAL_WORKER_STATUS.install_validation_reason = "worker_install_status.txt accepted";
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

   string manifest_status = AC_EWValue(manifest_text, "result_status");
   string manifest_authority = AC_EWValue(manifest_text, "authority");
   string manifest_trade_permission = AC_EWValue(manifest_text, "trade_permission");
   string manifest_snapshot_id = AC_EWValue(manifest_text, "source_snapshot_id");
   string manifest_row_count = AC_EWValue(manifest_text, "row_count");
   string manifest_checksum = AC_EWValue(manifest_text, "payload_checksum");
   string manifest_generated_unix = AC_EWValue(manifest_text, "generated_unix");

   AC_EXTERNAL_WORKER_STATUS.result_snapshot_id = result_snapshot_id;
   AC_EXTERNAL_WORKER_STATUS.result_authority = result_authority;
   AC_EXTERNAL_WORKER_STATUS.result_trade_permission = result_trade_permission;
   AC_EXTERNAL_WORKER_STATUS.result_payload_checksum = result_checksum;
   AC_EXTERNAL_WORKER_STATUS.result_row_count = (int)StringToInteger(result_row_count);

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
   AC_EXTERNAL_WORKER_STATUS.result_validation_status = "Accepted";
   AC_EXTERNAL_WORKER_STATUS.result_validation_reason = "Result bound to latest MT5 snapshot and accepted";
}

#endif
