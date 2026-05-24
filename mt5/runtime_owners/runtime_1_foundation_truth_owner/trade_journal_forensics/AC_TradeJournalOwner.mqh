#ifndef AC_TRADE_JOURNAL_OWNER_MQH
#define AC_TRADE_JOURNAL_OWNER_MQH

// Trade Journal / Trade Forensics support owner.
// Compile-safe skeleton only.
// This owner is Runtime 1 support bookkeeping/forensics status only.
// It does not generate trade-history files yet.
// It does not parse setup packets yet.
// It does not match packets to trades yet.
// It does not use OnTradeTransaction yet.
// It grants no trade permission, no execution permission, no setup permission, and no prop-firm safety approval.

static const string AC_TRADE_JOURNAL_OWNER_NAME = "Runtime 1 - Trade Journal / Trade Forensics Support Owner";
static const string AC_TRADE_JOURNAL_SCHEMA_VERSION = "trade_journal_status_v1.067";
static const string AC_TRADE_JOURNAL_AUTHORITY = "bookkeeping_forensics_status_only_no_permission_no_execution";
static const string AC_TRADE_JOURNAL_STATUS_SKELETON = "skeleton_source_present_no_trade_generation";

struct AC_TradeJournalStatusPacket
{
   string owner_name;
   string status;
   string authority;
   string schema_version;
   string route_status;
   string historical_generator_status;
   string live_capture_status;
   string packet_import_status;
   string packet_matching_status;
   string last_error;
   bool   trade_permission;
   bool   execution_permission;
   bool   prop_firm_safety;
   int    historical_files_written_total;
   int    packets_seen_total;
   int    packets_rejected_total;
   int    packets_orphaned_total;
   int    packets_matched_total;
   uint   last_service_duration_ms;
};

AC_TradeJournalStatusPacket AC_TRADE_JOURNAL_STATUS;
bool AC_TRADE_JOURNAL_READY = false;

string AC_TradeJournalBoolText(const bool value)
{
   return value ? "true" : "false";
}

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

bool AC_TradeJournalEnsureFolder(const string folder_path, string &detail)
{
   string folder_detail = "";
   bool ok = AC_EnsureFolderPath(folder_path, folder_detail);
   if(detail == "")
      detail = folder_detail;
   else
      detail += ";" + folder_detail;
   return ok;
}

bool AC_TradeJournalInit()
{
   uint start_ms = GetTickCount();
   AC_TradeJournalResetStatus();

   string folder_detail = "";
   bool import_ok = AC_TradeJournalEnsureFolder(AC_TradeJournalImportFolder(), folder_detail);
   bool inbox_ok = AC_TradeJournalEnsureFolder(AC_TradeJournalInboxFolder(), folder_detail);
   bool accepted_ok = AC_TradeJournalEnsureFolder(AC_TradeJournalAcceptedFolder(), folder_detail);
   bool rejected_ok = AC_TradeJournalEnsureFolder(AC_TradeJournalRejectedFolder(), folder_detail);
   bool orphaned_ok = AC_TradeJournalEnsureFolder(AC_TradeJournalOrphanedFolder(), folder_detail);
   bool history_ok = AC_TradeJournalEnsureFolder(AC_TradeHistoryFolder(), folder_detail);
   bool before_ok = AC_TradeJournalEnsureFolder(AC_TradeHistoryBeforeAuroraFolder(), folder_detail);
   bool captured_ok = AC_TradeJournalEnsureFolder(AC_TradeHistoryAuroraCapturedFolder(), folder_detail);

   AC_TRADE_JOURNAL_READY = import_ok && inbox_ok && accepted_ok && rejected_ok && orphaned_ok && history_ok && before_ok && captured_ok;
   AC_TRADE_JOURNAL_STATUS.route_status = AC_TRADE_JOURNAL_READY ? "route_folders_ensured" : "route_folder_degraded";
   AC_TRADE_JOURNAL_STATUS.status = AC_TRADE_JOURNAL_READY ? "skeleton_ready_no_runtime_features" : "skeleton_route_degraded";
   AC_TRADE_JOURNAL_STATUS.last_error = AC_TRADE_JOURNAL_READY ? "" : folder_detail;
   AC_TRADE_JOURNAL_STATUS.last_service_duration_ms = GetTickCount() - start_ms;
   return AC_TRADE_JOURNAL_READY;
}

string AC_TradeJournalStatusRow(const AC_TradeJournalStatusPacket &status)
{
   string row = "trade_journal_status=" + status.status;
   row += "|owner=" + status.owner_name;
   row += "|schema_version=" + status.schema_version;
   row += "|authority=" + status.authority;
   row += "|route_status=" + status.route_status;
   row += "|historical_generator=" + status.historical_generator_status;
   row += "|live_capture=" + status.live_capture_status;
   row += "|packet_import=" + status.packet_import_status;
   row += "|packet_matching=" + status.packet_matching_status;
   row += "|historical_files_written_total=" + IntegerToString(status.historical_files_written_total);
   row += "|packets_seen_total=" + IntegerToString(status.packets_seen_total);
   row += "|packets_rejected_total=" + IntegerToString(status.packets_rejected_total);
   row += "|packets_orphaned_total=" + IntegerToString(status.packets_orphaned_total);
   row += "|packets_matched_total=" + IntegerToString(status.packets_matched_total);
   row += "|trade_permission=" + AC_TradeJournalBoolText(status.trade_permission);
   row += "|execution_permission=" + AC_TradeJournalBoolText(status.execution_permission);
   row += "|prop_firm_safety=" + AC_TradeJournalBoolText(status.prop_firm_safety);
   row += "|last_service_duration_ms=" + IntegerToString((int)status.last_service_duration_ms);
   if(status.last_error != "")
      row += "|last_error=" + status.last_error;
   return row;
}

string AC_TradeJournalWorkbenchSection(const AC_TradeJournalStatusPacket &status)
{
   string text = "\r\nTRADE JOURNAL / TRADE FORENSICS\r\n";
   text += "----------------------------------------\r\n";
   text += "Status: " + status.status + "\r\n";
   text += "Owner: " + status.owner_name + "\r\n";
   text += "Authority: " + status.authority + "\r\n";
   text += "Route Status: " + status.route_status + "\r\n";
   text += "Historical Generator: " + status.historical_generator_status + "\r\n";
   text += "Live Capture: " + status.live_capture_status + "\r\n";
   text += "Packet Import: " + status.packet_import_status + "\r\n";
   text += "Packet Matching: " + status.packet_matching_status + "\r\n";
   text += "Historical Files Written: " + IntegerToString(status.historical_files_written_total) + "\r\n";
   text += "Packets Seen / Rejected / Orphaned / Matched: "
      + IntegerToString(status.packets_seen_total) + " / "
      + IntegerToString(status.packets_rejected_total) + " / "
      + IntegerToString(status.packets_orphaned_total) + " / "
      + IntegerToString(status.packets_matched_total) + "\r\n";
   text += "Trade Permission: FALSE\r\n";
   text += "Execution Permission: FALSE\r\n";
   text += "Prop Firm Safety: FALSE\r\n";
   text += "Contract: skeleton only; no old-trade motive reconstruction, no packet matching, no permission, no execution.\r\n";
   if(status.last_error != "")
      text += "Last Error: " + status.last_error + "\r\n";
   return text;
}

string AC_TradeJournalStatusText()
{
   return AC_TradeJournalStatusRow(AC_TRADE_JOURNAL_STATUS) + "\r\n";
}

#endif
