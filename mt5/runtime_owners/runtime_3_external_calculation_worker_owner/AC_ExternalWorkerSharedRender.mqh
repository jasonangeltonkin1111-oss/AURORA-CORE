#ifndef AC_EXTERNAL_WORKER_SHARED_RENDER_MQH
#define AC_EXTERNAL_WORKER_SHARED_RENDER_MQH

// Runtime 3 shared supervisor render addendum.
// Displays already-owned shared daemon truth only; it does not validate results,
// grant acceptance, launch processes, rank symbols, select trades, or own execution.

void AC_AppendExternalWorkerSharedSupervisorTexts()
{
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "shared_status_file_present=" + (AC_EXTERNAL_WORKER_STATUS.shared_status_file_present ? "true" : "false") + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "shared_status_validation_status=" + AC_EXTERNAL_WORKER_STATUS.shared_status_validation_status + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "shared_status_validation_reason=" + AC_EXTERNAL_WORKER_STATUS.shared_status_validation_reason + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "shared_status_worker_version=" + AC_EXTERNAL_WORKER_STATUS.shared_status_worker_version + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "shared_status_mode=" + AC_EXTERNAL_WORKER_STATUS.shared_status_mode + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "shared_status_loop_count=" + AC_EXTERNAL_WORKER_STATUS.shared_status_loop_count + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "shared_status_discovered_root_count=" + AC_EXTERNAL_WORKER_STATUS.shared_status_discovered_root_count + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "shared_status_processed_root_count=" + AC_EXTERNAL_WORKER_STATUS.shared_status_processed_root_count + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "shared_status_accepted_root_count=" + AC_EXTERNAL_WORKER_STATUS.shared_status_accepted_root_count + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "shared_status_degraded_root_count=" + AC_EXTERNAL_WORKER_STATUS.shared_status_degraded_root_count + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "shared_daemon_task_registered=" + AC_EXTERNAL_WORKER_STATUS.shared_daemon_task_registered + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "shared_daemon_task_state=" + AC_EXTERNAL_WORKER_STATUS.shared_daemon_task_state + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "shared_watchdog_task_registered=" + AC_EXTERNAL_WORKER_STATUS.shared_watchdog_task_registered + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "shared_watchdog_task_state=" + AC_EXTERNAL_WORKER_STATUS.shared_watchdog_task_state + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "shared_watchdog_last_check_utc=" + AC_EXTERNAL_WORKER_STATUS.shared_watchdog_last_check_utc + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "shared_watchdog_last_action=" + AC_EXTERNAL_WORKER_STATUS.shared_watchdog_last_action + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "shared_operator_cmd_required=" + AC_EXTERNAL_WORKER_STATUS.shared_operator_cmd_required + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "shared_cpu_logical_count=" + AC_EXTERNAL_WORKER_STATUS.shared_cpu_logical_count + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "shared_memory_total_mb=" + AC_EXTERNAL_WORKER_STATUS.shared_memory_total_mb + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "shared_memory_available_mb=" + AC_EXTERNAL_WORKER_STATUS.shared_memory_available_mb + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "shared_memory_used_percent=" + AC_EXTERNAL_WORKER_STATUS.shared_memory_used_percent + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "shared_memory_limit_percent=" + AC_EXTERNAL_WORKER_STATUS.shared_memory_limit_percent + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "shared_cpu_limit_percent=" + AC_EXTERNAL_WORKER_STATUS.shared_cpu_limit_percent + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "shared_terminal_process_count=" + AC_EXTERNAL_WORKER_STATUS.shared_terminal_process_count + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "shared_aurora_worker_process_count=" + AC_EXTERNAL_WORKER_STATUS.shared_aurora_worker_process_count + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "shared_registered_root_count=" + AC_EXTERNAL_WORKER_STATUS.shared_registered_root_count + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "shared_resource_throttle_active=" + AC_EXTERNAL_WORKER_STATUS.shared_resource_throttle_active + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "shared_resource_throttle_reason=" + AC_EXTERNAL_WORKER_STATUS.shared_resource_throttle_reason + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "shared_recommended_parallel_jobs=" + AC_EXTERNAL_WORKER_STATUS.shared_recommended_parallel_jobs + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "shared_status_age_seconds=" + IntegerToString(AC_EXTERNAL_WORKER_STATUS.shared_status_age_seconds) + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "shared_status_path=" + AC_EXTERNAL_WORKER_STATUS.shared_status_path + "\r\n";

   AC_EXTERNAL_WORKER_STATUS_ROW += "|shared_status_validation_status=" + AC_EXTERNAL_WORKER_STATUS.shared_status_validation_status
      + "|shared_status_loop_count=" + AC_EXTERNAL_WORKER_STATUS.shared_status_loop_count
      + "|shared_status_discovered_root_count=" + AC_EXTERNAL_WORKER_STATUS.shared_status_discovered_root_count
      + "|shared_status_processed_root_count=" + AC_EXTERNAL_WORKER_STATUS.shared_status_processed_root_count
      + "|shared_status_accepted_root_count=" + AC_EXTERNAL_WORKER_STATUS.shared_status_accepted_root_count
      + "|shared_status_degraded_root_count=" + AC_EXTERNAL_WORKER_STATUS.shared_status_degraded_root_count
      + "|shared_daemon_task_state=" + AC_EXTERNAL_WORKER_STATUS.shared_daemon_task_state
      + "|shared_watchdog_task_state=" + AC_EXTERNAL_WORKER_STATUS.shared_watchdog_task_state
      + "|shared_operator_cmd_required=" + AC_EXTERNAL_WORKER_STATUS.shared_operator_cmd_required
      + "|shared_resource_throttle_active=" + AC_EXTERNAL_WORKER_STATUS.shared_resource_throttle_active;
}

#endif
