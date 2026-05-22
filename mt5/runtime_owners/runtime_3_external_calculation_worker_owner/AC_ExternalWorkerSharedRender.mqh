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
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "shared_status_age_seconds=" + IntegerToString(AC_EXTERNAL_WORKER_STATUS.shared_status_age_seconds) + "\r\n";
   AC_EXTERNAL_WORKER_WORKBENCH_SECTION += "shared_status_path=" + AC_EXTERNAL_WORKER_STATUS.shared_status_path + "\r\n";

   AC_EXTERNAL_WORKER_STATUS_ROW += "|shared_status_validation_status=" + AC_EXTERNAL_WORKER_STATUS.shared_status_validation_status
      + "|shared_status_loop_count=" + AC_EXTERNAL_WORKER_STATUS.shared_status_loop_count
      + "|shared_status_discovered_root_count=" + AC_EXTERNAL_WORKER_STATUS.shared_status_discovered_root_count
      + "|shared_status_processed_root_count=" + AC_EXTERNAL_WORKER_STATUS.shared_status_processed_root_count
      + "|shared_status_accepted_root_count=" + AC_EXTERNAL_WORKER_STATUS.shared_status_accepted_root_count
      + "|shared_status_degraded_root_count=" + AC_EXTERNAL_WORKER_STATUS.shared_status_degraded_root_count;
}

#endif
