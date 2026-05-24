#ifndef AC_TRADE_JOURNAL_OWNER_MQH
#define AC_TRADE_JOURNAL_OWNER_MQH

// Trade Journal / Trade Forensics support owner.
// Skeleton only. This source intentionally does not generate trade files yet.
// No trade permission, no execution permission, no setup permission, no packet matching.

#include "AC_TradeJournalTypes.mqh"
#include "AC_TradeJournalRender.mqh"

AC_TradeJournalStatusPacket AC_TRADE_JOURNAL_STATUS;
bool AC_TRADE_JOURNAL_READY = false;

void AC_TradeJournalResetStatus()
{
   AC_TRADE_JOURNAL_STATUS.owner_name = AC_TRADE_JOURNAL_OWNER_NAME;
   AC_TRADE_JOURNAL_STATUS.status = AC_TRADE_JOURNAL_STATUS_SKELETON;
   AC_TRADE_JOURNAL_STATUS.authority = AC_TRADE_JOURNAL_AUTHORITY;
   AC_TRADE_JOURNAL_STATUS.schema_version = AC_TRADE_JOURNAL_SCHEMA_VERSION;
   AC_TRADE_JOURNAL_STATUS.route_status = "route_scaffold_source_present_runtime_proof_required";
   AC_TRADE_JOURNAL_STATUS.historical_generator_status = "not_implemented";
   AC_TRADE_JOURNAL_STATUS.live_capture_status = "not_implemented";
   AC_TRADE_JOURNAL_STATUS.packet_import_status = "not_implemented";
   AC_TRADE_JOURNAL_STATUS.packet_matching_status = "not_implemented";
   AC_TRADE_JOURNAL_STATUS.last_error = "";
   AC_TRADE_JOURNAL_STATUS.trade_permission = false;
   AC_TRADE_JOURNAL_STATUS.execution_permission = false;
   AC_TRADE_JOURNAL_STATUS.prop_firm_safety = false;
   AC_TRADE_JOURNAL_STATUS.historical_files_written_total = 0;
   AC_TRADE_JOURNAL_STATUS.packets_seen_total = 0;
   AC_TRADE_JOURNAL_STATUS.packets_rejected_total = 0;
   AC_TRADE_JOURNAL_STATUS.packets_orphaned_total = 0;
   AC_TRADE_JOURNAL_STATUS.packets_matched_total = 0;
   AC_TRADE_JOURNAL_STATUS.last_service_duration_ms = 0;
}

bool AC_TradeJournalInit()
{
   uint start_ms = GetTickCount();
   AC_TradeJournalResetStatus();

   string folder_detail = "";
   bool import_ok = AC_EnsureFolderPath(AC_TradeJournalImportFolder(), folder_detail);
   bool inbox_ok = AC_EnsureFolderPath(AC_TradeJournalInboxFolder(), folder_detail);
   bool accepted_ok = AC_EnsureFolderPath(AC_TradeJournalAcceptedFolder(), folder_detail);
   bool rejected_ok = AC_EnsureFolderPath(AC_TradeJournalRejectedFolder(), folder_detail);
   bool orphaned_ok = AC_EnsureFolderPath(AC_TradeJournalOrphanedFolder(), folder_detail);
   bool history_ok = AC_EnsureFolderPath(AC_TradeHistoryFolder(), folder_detail);
   bool before_ok = AC_EnsureFolderPath(AC_TradeHistoryBeforeAuroraFolder(), folder_detail);
   bool captured_ok = AC_EnsureFolderPath(AC_TradeHistoryAuroraCapturedFolder(), folder_detail);

   AC_TRADE_JOURNAL_READY = import_ok && inbox_ok && accepted_ok && rejected_ok && orphaned_ok && history_ok && before_ok && captured_ok;
   AC_TRADE_JOURNAL_STATUS.route_status = AC_TRADE_JOURNAL_READY ? "route_folders_ensured" : "route_folder_degraded";
   AC_TRADE_JOURNAL_STATUS.status = AC_TRADE_JOURNAL_READY ? "skeleton_ready_no_runtime_features" : "skeleton_route_degraded";
   AC_TRADE_JOURNAL_STATUS.last_error = AC_TRADE_JOURNAL_READY ? "" : folder_detail;
   AC_TRADE_JOURNAL_STATUS.last_service_duration_ms = GetTickCount() - start_ms;
   return AC_TRADE_JOURNAL_READY;
}

string AC_TradeJournalStatusText()
{
   return AC_TradeJournalStatusRow(AC_TRADE_JOURNAL_STATUS);
}

#endif
