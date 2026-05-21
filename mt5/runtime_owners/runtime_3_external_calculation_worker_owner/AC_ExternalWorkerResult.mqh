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

   string manifest_status = AC_EWValue(manifest_text, "result_status");
   string manifest_authority = AC_EWValue(manifest_text, "authority");
   string manifest_trade_permission = AC_EWValue(manifest_text, "trade_permission");
   string manifest_snapshot_id = AC_EWValue(manifest_text, "source_snapshot_id");
   string manifest_row_count = AC_EWValue(manifest_text, "row_count");
   string manifest_checksum = AC_EWValue(manifest_text, "payload_checksum");

   AC_EXTERNAL_WORKER_STATUS.result_snapshot_id = result_snapshot_id;
   AC_EXTERNAL_WORKER_STATUS.result_authority = result_authority;
   AC_EXTERNAL_WORKER_STATUS.result_trade_permission = result_trade_permission;
   AC_EXTERNAL_WORKER_STATUS.result_payload_checksum = result_checksum;
   AC_EXTERNAL_WORKER_STATUS.result_row_count = (int)StringToInteger(result_row_count);

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
   if(result_row_count == "" || result_row_count != manifest_row_count)
   {
      AC_EXTERNAL_WORKER_STATUS.accepted_result = false;
      AC_EXTERNAL_WORKER_STATUS.result_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.result_validation_reason = "Row count mismatch";
      return;
   }
   if(result_checksum == "" || result_checksum != manifest_checksum)
   {
      AC_EXTERNAL_WORKER_STATUS.accepted_result = false;
      AC_EXTERNAL_WORKER_STATUS.result_validation_status = "Rejected";
      AC_EXTERNAL_WORKER_STATUS.result_validation_reason = "Payload checksum mismatch";
      return;
   }

   AC_EXTERNAL_WORKER_STATUS.accepted_result = true;
   AC_EXTERNAL_WORKER_STATUS.result_validation_status = "Accepted";
   AC_EXTERNAL_WORKER_STATUS.result_validation_reason = "Result and manifest accepted";
}

#endif
