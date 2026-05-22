#ifndef AC_EXTERNAL_WORKER_RESULT_ENVELOPE_MQH
#define AC_EXTERNAL_WORKER_RESULT_ENVELOPE_MQH

// Runtime 3 same-owner helper.
// Purpose: prevent a stale/missing Gateway heartbeat from falsely rejecting an
// otherwise fresh, job-bound, snapshot-bound, authority-safe result envelope.
// Heartbeat/lifecycle remain health truth. They do not grant result authority.

void AC_ValidateExternalWorkerResultEnvelopeNoHeartbeatGate()
{
   if(AC_EXTERNAL_WORKER_STATUS.accepted_result)
      return;

   if(AC_EXTERNAL_WORKER_STATUS.result_validation_reason != "Heartbeat is not fresh")
      return;

   if(!AC_EXTERNAL_WORKER_STATUS.result_present || !AC_EXTERNAL_WORKER_STATUS.result_manifest_present)
      return;

   string result_text = AC_EWReadTextFile(AC_ExternalWorkerResultPath(), 12000);
   string manifest_text = AC_EWReadTextFile(AC_ExternalWorkerResultManifestPath(), 8000);
   if(result_text == "" || manifest_text == "")
      return;

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

   if(!AC_EXTERNAL_WORKER_STATUS.install_status_file_present
      || !AC_EXTERNAL_WORKER_STATUS.worker_installed
      || AC_EXTERNAL_WORKER_STATUS.install_validation_status != "Accepted")
      return;

   if(result_authority != AC_EXTERNAL_WORKER_AUTHORITY || manifest_authority != AC_EXTERNAL_WORKER_AUTHORITY)
      return;
   if(result_trade_permission != "false" || manifest_trade_permission != "false")
      return;
   if(result_status != "complete" || manifest_status != "complete")
      return;
   if(result_snapshot_id == "" || result_snapshot_id != manifest_snapshot_id)
      return;
   if(result_snapshot_id != AC_EXTERNAL_WORKER_LAST_SNAPSHOT_ID)
      return;
   if(result_job_bus_schema == "" || result_job_bus_schema != manifest_job_bus_schema || result_job_bus_schema != AC_EXTERNAL_WORKER_JOB_BUS_SCHEMA_VERSION)
      return;
   if(result_job_id == "" || result_job_id != manifest_job_id || result_job_id != AC_EXTERNAL_WORKER_LAST_JOB_ID)
      return;
   if(result_job_type == "" || result_job_type != manifest_job_type || result_job_type != AC_EXTERNAL_WORKER_LAST_JOB_TYPE)
      return;
   if(result_job_resource_class == "" || result_job_resource_class != manifest_job_resource_class)
      return;
   if(result_job_max_runtime_ms == "" || result_job_max_runtime_ms != manifest_job_max_runtime_ms)
      return;
   if(result_job_status != "complete" || manifest_job_status != "complete")
      return;
   if(result_row_count == "" || result_row_count != manifest_row_count)
      return;
   if((int)StringToInteger(result_row_count) != AC_EXTERNAL_WORKER_LAST_SNAPSHOT_ROWS)
      return;
   if(result_checksum == "" || result_checksum != manifest_checksum)
      return;
   if(result_checksum != AC_EXTERNAL_WORKER_LAST_SNAPSHOT_PAYLOAD_CHECKSUM)
      return;
   if(result_generated_unix == "" || result_generated_unix != manifest_generated_unix)
      return;

   long generated = (long)StringToInteger(result_generated_unix);
   if(generated <= 0)
      return;

   long age = (long)TimeGMT() - generated;
   if(age < 0) age = 0;
   AC_EXTERNAL_WORKER_STATUS.result_age_seconds = (int)age;
   AC_EXTERNAL_WORKER_STATUS.last_result_seen = (datetime)generated;
   if(age > AC_EXTERNAL_WORKER_RESULT_MAX_AGE_SECONDS)
      return;

   AC_EXTERNAL_WORKER_STATUS.accepted_result = true;
   AC_EXTERNAL_WORKER_STATUS.job_bus_status = "Accepted";
   AC_EXTERNAL_WORKER_STATUS.job_bus_validation_status = "Accepted";
   AC_EXTERNAL_WORKER_STATUS.job_bus_validation_reason = "Gateway result envelope accepted; heartbeat/lifecycle remain separate health truth";
   AC_EXTERNAL_WORKER_STATUS.result_validation_status = "Accepted";
   AC_EXTERNAL_WORKER_STATUS.result_validation_reason = "Gateway result accepted by install proof, result/manifest pair, latest MT5 snapshot, latest MT5 job envelope, row count, checksum, authority, permission, and result freshness; heartbeat is not a result hard gate";

   AC_EXTERNAL_WORKER_STATUS.result_snapshot_id = result_snapshot_id;
   AC_EXTERNAL_WORKER_STATUS.result_job_bus_schema_version = result_job_bus_schema;
   AC_EXTERNAL_WORKER_STATUS.result_job_id = result_job_id;
   AC_EXTERNAL_WORKER_STATUS.result_job_type = result_job_type;
   AC_EXTERNAL_WORKER_STATUS.result_job_resource_class = result_job_resource_class;
   AC_EXTERNAL_WORKER_STATUS.result_job_max_runtime_ms = result_job_max_runtime_ms;
   AC_EXTERNAL_WORKER_STATUS.result_job_status = result_job_status;
   AC_EXTERNAL_WORKER_STATUS.result_authority = result_authority;
   AC_EXTERNAL_WORKER_STATUS.result_trade_permission = result_trade_permission;
   AC_EXTERNAL_WORKER_STATUS.result_payload_checksum = result_checksum;
   AC_EXTERNAL_WORKER_STATUS.result_row_count = (int)StringToInteger(result_row_count);
}

#endif
