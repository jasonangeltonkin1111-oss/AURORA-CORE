#ifndef AC_EXTERNAL_WORKER_TYPES_MQH
#define AC_EXTERNAL_WORKER_TYPES_MQH

struct AC_ExternalWorkerStatus
{
   bool required;
   bool auto_launch_desired;
   bool popup_alerts;
   bool exe_present;
   bool heartbeat_present;
   bool result_manifest_present;
   bool result_present;
   bool accepted_result;
   string owner_name;
   string worker_status;
   string install_status;
   string heartbeat_status;
   string result_status;
   string launch_mode;
   string launch_implementation;
   string launch_status;
   string launch_blocker;
   string missing_reason;
   string expected_exe_path;
   string required_path;
   string heartbeat_path;
   string result_path;
   string authority;
   datetime checked_at;
   datetime last_heartbeat_seen;
   datetime last_result_seen;
   datetime last_launch_attempt_time;
   int heartbeat_age_seconds;
   int result_age_seconds;
   int launch_attempts;
   int last_error;
};

#endif
