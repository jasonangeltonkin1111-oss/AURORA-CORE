#ifndef AC_EXTERNAL_WORKER_STATE_MQH
#define AC_EXTERNAL_WORKER_STATE_MQH

static AC_ExternalWorkerStatus AC_EXTERNAL_WORKER_STATUS;
static string AC_EXTERNAL_WORKER_WORKBENCH_SECTION = "";
static string AC_EXTERNAL_WORKER_STATUS_ROW = "";
static datetime AC_EXTERNAL_WORKER_LAST_CHECK_TIME = 0;

void AC_ExternalWorkerInitStatus()
{
   AC_EXTERNAL_WORKER_STATUS.required = AC_EXTERNAL_WORKER_REQUIRED;
   AC_EXTERNAL_WORKER_STATUS.auto_launch_desired = AC_EXTERNAL_WORKER_AUTO_LAUNCH_DESIRED;
   AC_EXTERNAL_WORKER_STATUS.popup_alerts = AC_EXTERNAL_WORKER_POPUP_ALERTS;
   AC_EXTERNAL_WORKER_STATUS.exe_present = false;
   AC_EXTERNAL_WORKER_STATUS.heartbeat_present = false;
   AC_EXTERNAL_WORKER_STATUS.result_manifest_present = false;
   AC_EXTERNAL_WORKER_STATUS.result_present = false;
   AC_EXTERNAL_WORKER_STATUS.accepted_result = false;
   AC_EXTERNAL_WORKER_STATUS.owner_name = AC_RUNTIME3_OWNER;
   AC_EXTERNAL_WORKER_STATUS.worker_status = "Not checked";
   AC_EXTERNAL_WORKER_STATUS.install_status = "Not checked";
   AC_EXTERNAL_WORKER_STATUS.heartbeat_status = "Not checked";
   AC_EXTERNAL_WORKER_STATUS.heartbeat_validation_status = "Not checked";
   AC_EXTERNAL_WORKER_STATUS.heartbeat_validation_reason = "";
   AC_EXTERNAL_WORKER_STATUS.result_status = "Not checked";
   AC_EXTERNAL_WORKER_STATUS.result_validation_status = "Not checked";
   AC_EXTERNAL_WORKER_STATUS.result_validation_reason = "";
   AC_EXTERNAL_WORKER_STATUS.result_snapshot_id = "not_available";
   AC_EXTERNAL_WORKER_STATUS.result_authority = "not_available";
   AC_EXTERNAL_WORKER_STATUS.result_trade_permission = "not_available";
   AC_EXTERNAL_WORKER_STATUS.result_payload_checksum = "not_available";
   AC_EXTERNAL_WORKER_STATUS.result_row_count = 0;
   AC_EXTERNAL_WORKER_STATUS.launch_mode = AC_EXTERNAL_WORKER_LAUNCH_MODE;
   AC_EXTERNAL_WORKER_STATUS.launch_implementation = AC_EXTERNAL_WORKER_LAUNCH_IMPLEMENTATION;
   AC_EXTERNAL_WORKER_STATUS.launch_status = "Not attempted";
   AC_EXTERNAL_WORKER_STATUS.launch_blocker = "";
   AC_EXTERNAL_WORKER_STATUS.missing_reason = "";
   AC_EXTERNAL_WORKER_STATUS.expected_exe_path = AC_ExternalWorkerExePath();
   AC_EXTERNAL_WORKER_STATUS.required_path = AC_ExternalWorkerRequiredPath();
   AC_EXTERNAL_WORKER_STATUS.heartbeat_path = AC_ExternalWorkerHeartbeatPath();
   AC_EXTERNAL_WORKER_STATUS.result_path = AC_ExternalWorkerResultPath();
   AC_EXTERNAL_WORKER_STATUS.authority = AC_EXTERNAL_WORKER_AUTHORITY;
   AC_EXTERNAL_WORKER_STATUS.checked_at = TimeCurrent();
   AC_EXTERNAL_WORKER_STATUS.last_heartbeat_seen = 0;
   AC_EXTERNAL_WORKER_STATUS.last_result_seen = 0;
   AC_EXTERNAL_WORKER_STATUS.last_launch_attempt_time = 0;
   AC_EXTERNAL_WORKER_STATUS.heartbeat_age_seconds = -1;
   AC_EXTERNAL_WORKER_STATUS.result_age_seconds = -1;
   AC_EXTERNAL_WORKER_STATUS.launch_attempts = 0;
   AC_EXTERNAL_WORKER_STATUS.last_error = 0;
}

#endif
