#ifndef AC_TRADE_JOURNAL_OWNER_MQH
#define AC_TRADE_JOURNAL_OWNER_MQH

// Trade Journal / Trade Forensics support owner.
// Runtime 1 support bookkeeping/forensics only.
// MVP historical generator uses Layer 1 selected closed rows only.
// It does not run its own all-time history scan.
// It does not call CopyRates.
// It may copy a bounded trade-duration OHLC slice from the existing Shared OHLC Raw Store files.
// It does not parse setup packets yet.
// It does not match packets to trades yet.
// It does not use OnTradeTransaction yet.
// It grants no trade permission, no execution permission, no setup permission, and no prop-firm safety approval.

static const string AC_TRADE_JOURNAL_OWNER_NAME = "Runtime 1 - Trade Journal / Trade Forensics Support Owner";
static const string AC_TRADE_JOURNAL_SCHEMA_VERSION = "trade_journal_status_v1.070_shared_ohlc_slice";
static const string AC_TRADE_JOURNAL_AUTHORITY = "bookkeeping_forensics_status_only_no_permission_no_execution";
static const string AC_TRADE_JOURNAL_STATUS_SKELETON = "skeleton_source_present_historical_mvp_available";
static const int    AC_TRADE_JOURNAL_MAX_HISTORICAL_WRITES_PER_PASS = 1;
static const int    AC_TRADE_JOURNAL_MAX_HISTORICAL_ROWS_INSPECTED_PER_PASS = 12;
static const int    AC_TRADE_JOURNAL_OHLC_SLICE_MAX_ROWS = 240;

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
   int    historical_files_written_this_pass;
   int    packets_seen_total;
   int    packets_rejected_total;
   int    packets_orphaned_total;
   int    packets_matched_total;
   uint   last_service_duration_ms;
};

AC_TradeJournalStatusPacket AC_TRADE_JOURNAL_STATUS;
bool AC_TRADE_JOURNAL_READY = false;
int  AC_TRADE_JOURNAL_NEXT_HISTORICAL_INDEX = 0;

bool AC_TradeJournalPublishOneHistoricalTrade();

string AC_TradeJournalBoolText(const bool value)
{
   return value ? "true" : "false";
}

string AC_TradeJournalSafeText(string value)
{
   StringReplace(value, "\r", " ");
   StringReplace(value, "\n", " ");
   return value;
}

string AC_TradeJournalDateText(const datetime value)
{
   if(value <= 0)
      return "unknown";
   return TimeToString(value, TIME_DATE | TIME_SECONDS);
}

string AC_TradeJournalDateFolder(const datetime value)
{
   string text = TimeToString(value, TIME_DATE);
   if(StringLen(text) < 7)
      return "unknown\\unknown";
   string yyyy = StringSubstr(text, 0, 4);
   string mm = StringSubstr(text, 5, 2);
   return yyyy + "\\" + mm;
}

string AC_TradeJournalFilenameTime(const datetime value)
{
   if(value <= 0)
      return "unknown_time";
   string d = TimeToString(value, TIME_DATE);
   string t = TimeToString(value, TIME_MINUTES);
   StringReplace(d, ".", "-");
   StringReplace(t, ":", "");
   return d + "_" + t;
}

string AC_TradeJournalClosedTradeBaseFolder(const AC_L1ClosedTradeRow &row)
{
   datetime basis_time = row.close_time > 0 ? row.close_time : row.entry_time;
   string symbol_folder = AC_SanitizePathPart(row.symbol);
   if(symbol_folder == "")
      symbol_folder = "unknown_symbol";
   return AC_TradeHistoryBeforeAuroraFolder() + "\\" + AC_TradeJournalDateFolder(basis_time) + "\\" + symbol_folder;
}

string AC_TradeJournalClosedTradePath(const AC_L1ClosedTradeRow &row)
{
   datetime basis_time = row.close_time > 0 ? row.close_time : row.entry_time;
   string symbol_part = AC_SanitizePathPart(row.symbol);
   string side_part = AC_SanitizePathPart(row.side);
   if(symbol_part == "") symbol_part = "UNKNOWN";
   if(side_part == "") side_part = "UNKNOWN";

   string id_part = "";
   if(row.position_id > 0)
      id_part = "POS-" + IntegerToString(row.position_id);
   else if(row.deal_ticket > 0)
      id_part = "DEAL-" + AC_UlongToText(row.deal_ticket);
   else
      id_part = "ORPHANED_HISTORY_ROW";

   return AC_TradeJournalClosedTradeBaseFolder(row) + "\\" + AC_TradeJournalFilenameTime(basis_time) + "_" + symbol_part + "_" + side_part + "_" + id_part + ".txt";
}

string AC_TradeJournalSharedOhlcSymbolFolder(const string symbol)
{
   return AC_BASE_FOLDER + "\\" + AC_ServerNameForRoute() + "\\Shared Market Data\\OHLC Store\\Symbols\\" + AC_SanitizePathPart(symbol);
}

string AC_TradeJournalSharedOhlcSeedPath(const string symbol, const string timeframe_label)
{
   return AC_TradeJournalSharedOhlcSymbolFolder(symbol) + "\\" + timeframe_label + ".seed.csv";
}

string AC_TradeJournalSharedOhlcAppendPath(const string symbol, const string timeframe_label)
{
   return AC_TradeJournalSharedOhlcSymbolFolder(symbol) + "\\" + timeframe_label + ".append.csv";
}

int AC_TradeJournalOhlcTfSeconds(const string timeframe_label)
{
   if(timeframe_label == "M1") return 60;
   if(timeframe_label == "M5") return 300;
   if(timeframe_label == "M15") return 900;
   if(timeframe_label == "M30") return 1800;
   if(timeframe_label == "H1") return 3600;
   if(timeframe_label == "H4") return 14400;
   if(timeframe_label == "D1") return 86400;
   return 60;
}

bool AC_TradeJournalOhlcRowOverlapsTrade(const string line,
                                         const datetime entry_time,
                                         const datetime close_time,
                                         const int timeframe_seconds)
{
   int comma = StringFind(line, ",");
   if(comma <= 0)
      return false;

   string bar_time_text = StringSubstr(line, 0, comma);
   long bar_time_long = (long)StringToInteger(bar_time_text);
   if(bar_time_long <= 0)
      return false;

   long entry_long = (long)entry_time;
   long close_long = (long)close_time;
   long bar_end = bar_time_long + timeframe_seconds;

   return (bar_time_long <= close_long && bar_end >= entry_long);
}

bool AC_TradeJournalLineIsOhlcDataRow(const string line)
{
   if(line == "") return false;
   if(StringFind(line, "#") == 0) return false;
   if(StringFind(line, "bar_time") == 0) return false;
   return (StringFind(line, ",") > 0);
}

int AC_TradeJournalAppendSharedOhlcFileSlice(const string path,
                                             const datetime entry_time,
                                             const datetime close_time,
                                             const string timeframe_label,
                                             int &remaining_rows,
                                             string &rows_text,
                                             string &source_detail)
{
   if(remaining_rows <= 0)
      return 0;

   int common_flag = AC_USE_COMMON_FILES ? FILE_COMMON : 0;
   if(!FileIsExist(path, common_flag))
   {
      if(source_detail != "") source_detail += ";";
      source_detail += path + "=missing";
      return 0;
   }

   ResetLastError();
   int handle = FileOpen(path, FILE_READ | FILE_TXT | FILE_ANSI | common_flag);
   if(handle == INVALID_HANDLE)
   {
      if(source_detail != "") source_detail += ";";
      source_detail += path + "=open_failed_error_" + IntegerToString(GetLastError());
      return 0;
   }

   int copied = 0;
   int scanned = 0;
   int tf_seconds = AC_TradeJournalOhlcTfSeconds(timeframe_label);

   while(!FileIsEnding(handle) && remaining_rows > 0)
   {
      string line = FileReadString(handle);
      if(!AC_TradeJournalLineIsOhlcDataRow(line))
         continue;
      scanned++;
      if(!AC_TradeJournalOhlcRowOverlapsTrade(line, entry_time, close_time, tf_seconds))
         continue;

      rows_text += line + "\r\n";
      copied++;
      remaining_rows--;
   }

   FileClose(handle);

   if(source_detail != "") source_detail += ";";
   source_detail += path + "=read_scanned_" + IntegerToString(scanned) + "_copied_" + IntegerToString(copied);
   return copied;
}

string AC_TradeJournalSharedOhlcSliceText(const string symbol,
                                          const datetime entry_time,
                                          const datetime close_time)
{
   string text = "TRADE DURATION OHLC CONTEXT\r\n";
   text += "--------------------------------------------------\r\n";
   text += "ohlc_context_type=shared_store_bar_slice_not_tick_replay\r\n";
   text += "ohlc_owner=Runtime 1 Shared OHLC Raw Storage Owner\r\n";
   text += "source_policy=read_existing_shared_ohlc_files_only_no_copyrates\r\n";
   text += "copyrates_used=false\r\n";
   text += "preferred_timeframe=M1\r\n";
   text += "fallback_timeframe=M5\r\n";
   text += "entry_time_broker=" + AC_TradeJournalDateText(entry_time) + "\r\n";
   text += "close_time_broker=" + AC_TradeJournalDateText(close_time) + "\r\n";
   text += "price_encoding=integer_points_as_stored_by_shared_ohlc_owner\r\n";
   text += "columns=bar_time,open_i,high_i,low_i,close_i,tick_volume,spread,real_volume\r\n";
   text += "max_rows=" + IntegerToString(AC_TRADE_JOURNAL_OHLC_SLICE_MAX_ROWS) + "\r\n";

   if(symbol == "" || entry_time <= 0 || close_time <= 0)
   {
      text += "slice_status=blocked_missing_symbol_or_trade_times\r\n";
      text += "[OHLC_ROWS_BEGIN]\r\n[OHLC_ROWS_END]\r\n\r\n";
      return text;
   }

   datetime effective_close = close_time;
   if(effective_close < entry_time)
   {
      text += "slice_status=blocked_close_before_entry\r\n";
      text += "[OHLC_ROWS_BEGIN]\r\n[OHLC_ROWS_END]\r\n\r\n";
      return text;
   }

   string rows_text = "";
   string source_detail = "";
   int remaining_rows = AC_TRADE_JOURNAL_OHLC_SLICE_MAX_ROWS;
   int copied_m1 = 0;
   int copied_m5 = 0;

   copied_m1 += AC_TradeJournalAppendSharedOhlcFileSlice(AC_TradeJournalSharedOhlcSeedPath(symbol, "M1"), entry_time, effective_close, "M1", remaining_rows, rows_text, source_detail);
   copied_m1 += AC_TradeJournalAppendSharedOhlcFileSlice(AC_TradeJournalSharedOhlcAppendPath(symbol, "M1"), entry_time, effective_close, "M1", remaining_rows, rows_text, source_detail);

   string timeframe_used = "M1";
   int copied_total = copied_m1;
   if(copied_total <= 0)
   {
      remaining_rows = AC_TRADE_JOURNAL_OHLC_SLICE_MAX_ROWS;
      rows_text = "";
      source_detail += ";fallback_to_M5";
      copied_m5 += AC_TradeJournalAppendSharedOhlcFileSlice(AC_TradeJournalSharedOhlcSeedPath(symbol, "M5"), entry_time, effective_close, "M5", remaining_rows, rows_text, source_detail);
      copied_m5 += AC_TradeJournalAppendSharedOhlcFileSlice(AC_TradeJournalSharedOhlcAppendPath(symbol, "M5"), entry_time, effective_close, "M5", remaining_rows, rows_text, source_detail);
      timeframe_used = "M5";
      copied_total = copied_m5;
   }

   string slice_status = "";
   if(copied_total > 0 && remaining_rows <= 0)
      slice_status = "copied_from_shared_store_truncated_row_cap";
   else if(copied_total > 0)
      slice_status = "copied_from_shared_store";
   else
      slice_status = "no_rows_in_trade_duration_or_shared_store_missing";

   text += "timeframe_used=" + timeframe_used + "\r\n";
   text += "slice_status=" + slice_status + "\r\n";
   text += "bar_count=" + IntegerToString(copied_total) + "\r\n";
   text += "source_files=" + source_detail + "\r\n";
   text += "[OHLC_ROWS_BEGIN]\r\n";
   text += rows_text;
   text += "[OHLC_ROWS_END]\r\n\r\n";
   return text;
}

void AC_TradeJournalResetStatus()
{
   AC_TRADE_JOURNAL_STATUS.owner_name = AC_TRADE_JOURNAL_OWNER_NAME;
   AC_TRADE_JOURNAL_STATUS.status = AC_TRADE_JOURNAL_STATUS_SKELETON;
   AC_TRADE_JOURNAL_STATUS.authority = AC_TRADE_JOURNAL_AUTHORITY;
   AC_TRADE_JOURNAL_STATUS.schema_version = AC_TRADE_JOURNAL_SCHEMA_VERSION;
   AC_TRADE_JOURNAL_STATUS.route_status = "route_scaffold_source_present_runtime_proof_required";
   AC_TRADE_JOURNAL_STATUS.historical_generator_status = "mvp_available_waiting_for_l1_ready";
   AC_TRADE_JOURNAL_STATUS.live_capture_status = "not_implemented";
   AC_TRADE_JOURNAL_STATUS.packet_import_status = "not_implemented";
   AC_TRADE_JOURNAL_STATUS.packet_matching_status = "not_implemented";
   AC_TRADE_JOURNAL_STATUS.last_error = "";
   AC_TRADE_JOURNAL_STATUS.trade_permission = false;
   AC_TRADE_JOURNAL_STATUS.execution_permission = false;
   AC_TRADE_JOURNAL_STATUS.prop_firm_safety = false;
   AC_TRADE_JOURNAL_STATUS.historical_files_written_this_pass = 0;
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
   AC_TRADE_JOURNAL_STATUS.status = AC_TRADE_JOURNAL_READY ? "skeleton_ready_historical_mvp_available" : "skeleton_route_degraded";
   AC_TRADE_JOURNAL_STATUS.last_error = AC_TRADE_JOURNAL_READY ? "" : folder_detail;
   AC_TRADE_JOURNAL_STATUS.last_service_duration_ms = GetTickCount() - start_ms;

   if(AC_TRADE_JOURNAL_READY && AC_L1_READY)
      AC_TradeJournalPublishOneHistoricalTrade();

   return AC_TRADE_JOURNAL_READY;
}

string AC_TradeJournalRenderBeforeAuroraTrade(const AC_L1ClosedTradeRow &row)
{
   string text = "AURORA TRADE FORENSIC JOURNAL\r\n";
   text += "==================================================\r\n\r\n";
   text += "IDENTITY\r\n";
   text += "--------------------------------------------------\r\n";
   text += "forensic_class=BEFORE_AURORA_RECONSTRUCTED\r\n";
   text += "capture_status=history_only_from_layer1_selected_closed_rows\r\n";
   text += "confidence=limited_history_reconstruction\r\n";
   text += "account=" + IntegerToString(AC_L1_LOGIN) + "\r\n";
   text += "server=" + AC_TradeJournalSafeText(AC_L1_SERVER) + "\r\n";
   text += "currency=" + AC_TradeJournalSafeText(AC_L1_CURRENCY) + "\r\n";
   text += "symbol=" + AC_TradeJournalSafeText(row.symbol) + "\r\n";
   text += "side=" + AC_TradeJournalSafeText(row.side) + "\r\n";
   text += "position_id=" + IntegerToString(row.position_id) + "\r\n";
   text += "deal_ticket=" + AC_UlongToText(row.deal_ticket) + "\r\n";
   text += "order_ticket=" + AC_UlongToText(row.order_ticket) + "\r\n";
   text += "entry_order_ticket=" + AC_UlongToText(row.entry_order_ticket) + "\r\n";
   text += "magic=" + IntegerToString(row.magic) + "\r\n";
   text += "comment=" + AC_TradeJournalSafeText(row.comment) + "\r\n\r\n";

   text += "TRADE FACTS\r\n";
   text += "--------------------------------------------------\r\n";
   text += "entry_time_broker=" + AC_TradeJournalDateText(row.entry_time) + "\r\n";
   text += "close_time_broker=" + AC_TradeJournalDateText(row.close_time) + "\r\n";
   text += "entry_price=" + DoubleToString(row.entry_price, 8) + "\r\n";
   text += "close_price=" + DoubleToString(row.close_price, 8) + "\r\n";
   text += "volume=" + DoubleToString(row.volume, 2) + "\r\n";
   text += "stop_loss=" + DoubleToString(row.stop_loss, 8) + "\r\n";
   text += "take_profit=" + DoubleToString(row.take_profit, 8) + "\r\n";
   text += "profit=" + DoubleToString(row.profit, 2) + "\r\n";
   text += "commission=" + DoubleToString(row.commission, 2) + "\r\n";
   text += "swap=" + DoubleToString(row.swap, 2) + "\r\n";
   text += "fee=" + DoubleToString(row.fee, 2) + "\r\n";
   text += "net_result=" + DoubleToString(row.net_result, 2) + "\r\n";
   text += "close_reason=" + IntegerToString(row.close_reason) + "\r\n\r\n";

   text += AC_TradeJournalSharedOhlcSliceText(row.symbol, row.entry_time, row.close_time);

   text += "ORDER / DEAL / POSITION GROUPING\r\n";
   text += "--------------------------------------------------\r\n";
   text += "source_quality=" + AC_TradeJournalSafeText(row.source_quality) + "\r\n";
   text += "entry_reconstruction_status=" + AC_TradeJournalSafeText(row.entry_reconstruction_status) + "\r\n";
   text += "paired_entry_status=" + AC_TradeJournalSafeText(row.paired_entry_status) + "\r\n";
   text += "order_context_status=" + AC_TradeJournalSafeText(row.order_context_status) + "\r\n";
   text += "stop_loss_source=" + AC_TradeJournalSafeText(row.stop_loss_source) + "\r\n";
   text += "take_profit_source=" + AC_TradeJournalSafeText(row.take_profit_source) + "\r\n\r\n";

   text += "AURORA LIVE CAPTURE\r\n";
   text += "--------------------------------------------------\r\n";
   text += "live_entry_snapshot=unavailable_before_Aurora\r\n";
   text += "live_exit_snapshot=unavailable_before_Aurora\r\n";
   text += "layer_snapshot_at_entry=unavailable_unless_archived_or_tagged\r\n";
   text += "setup_reason=unknown_unless_packet_or_tagged\r\n";
   text += "declared_timeframe=unknown_unless_packet_or_tagged\r\n\r\n";

   text += "IMPORTED SETUP PACKET\r\n";
   text += "--------------------------------------------------\r\n";
   text += "packet_status=unavailable_before_packet_import_system\r\n";
   text += "packet_match=none\r\n";
   text += "match_confidence=none\r\n";
   text += "trade_permission=false\r\n";
   text += "prop_firm_safe=false\r\n\r\n";

   text += "WHAT AURORA CAN HONESTLY SAY\r\n";
   text += "--------------------------------------------------\r\n";
   text += "- MT5/Layer1 selected history supplied the trade facts above.\r\n";
   text += "- Shared OHLC rows, when present, are copied from the existing raw store only and are bar-level context, not tick replay.\r\n";
   text += "- This is a historical forensic record, not proof of motive or edge.\r\n";
   text += "- Costs/result fields are limited by the Layer 1 reconstruction quality fields.\r\n\r\n";

   text += "WHAT AURORA CANNOT CLAIM\r\n";
   text += "--------------------------------------------------\r\n";
   text += "- Aurora cannot prove why this trade was taken.\r\n";
   text += "- Aurora cannot prove the timeframe used.\r\n";
   text += "- Aurora cannot prove live layer state at entry.\r\n";
   text += "- OHLC context cannot prove setup logic, edge, or execution quality by itself.\r\n";
   text += "- Aurora cannot claim trade permission, prop-firm safety, or proven edge.\r\n\r\n";

   text += "PROOF / QUALITY LEDGER\r\n";
   text += "--------------------------------------------------\r\n";
   text += "mt5_facts=layer1_selected_history_row\r\n";
   text += "history_grouping=" + AC_TradeJournalSafeText(row.paired_entry_status) + "\r\n";
   text += "ohlc_duration_context=read_existing_shared_store_only_no_copyrates\r\n";
   text += "live_capture=unavailable_before_Aurora\r\n";
   text += "setup_packet=unavailable\r\n";
   text += "timeframe=unknown\r\n";
   text += "decision_reason=unknown\r\n";
   text += "journal_writer=Trade Journal Historical MVP\r\n";
   text += "journal_scope=one_file_per_trade_before_aurora_reconstructed\r\n\r\n";
   text += "END\r\n";
   text += "==================================================\r\n";
   return text;
}

bool AC_TradeJournalPublishOneHistoricalTrade()
{
   uint start_ms = GetTickCount();
   AC_TRADE_JOURNAL_STATUS.historical_generator_status = "waiting_for_layer1_selected_history";
   if(!AC_TRADE_JOURNAL_READY)
   {
      AC_TRADE_JOURNAL_STATUS.historical_generator_status = "blocked_route_not_ready";
      AC_TRADE_JOURNAL_STATUS.last_service_duration_ms = GetTickCount() - start_ms;
      return false;
   }
   if(!AC_L1_READY)
   {
      AC_TRADE_JOURNAL_STATUS.last_service_duration_ms = GetTickCount() - start_ms;
      return false;
   }

   int total = ArraySize(AC_L1_CLOSED);
   if(total <= 0)
   {
      AC_TRADE_JOURNAL_STATUS.historical_generator_status = "no_selected_closed_rows";
      AC_TRADE_JOURNAL_STATUS.last_service_duration_ms = GetTickCount() - start_ms;
      return true;
   }

   if(AC_TRADE_JOURNAL_NEXT_HISTORICAL_INDEX >= total)
      AC_TRADE_JOURNAL_NEXT_HISTORICAL_INDEX = 0;

   int inspected = 0;
   int written = 0;
   int common_flag = AC_USE_COMMON_FILES ? FILE_COMMON : 0;

   while(inspected < AC_TRADE_JOURNAL_MAX_HISTORICAL_ROWS_INSPECTED_PER_PASS && written < AC_TRADE_JOURNAL_MAX_HISTORICAL_WRITES_PER_PASS)
   {
      int idx = AC_TRADE_JOURNAL_NEXT_HISTORICAL_INDEX;
      AC_TRADE_JOURNAL_NEXT_HISTORICAL_INDEX++;
      if(AC_TRADE_JOURNAL_NEXT_HISTORICAL_INDEX >= total)
         AC_TRADE_JOURNAL_NEXT_HISTORICAL_INDEX = 0;
      inspected++;

      AC_L1ClosedTradeRow row = AC_L1_CLOSED[idx];
      string folder_path = AC_TradeJournalClosedTradeBaseFolder(row);
      string folder_detail = "";
      if(!AC_TradeJournalEnsureFolder(folder_path, folder_detail))
      {
         AC_TRADE_JOURNAL_STATUS.historical_generator_status = "folder_failed";
         AC_TRADE_JOURNAL_STATUS.last_error = folder_detail;
         break;
      }

      string final_path = AC_TradeJournalClosedTradePath(row);
      if(FileIsExist(final_path, common_flag))
         continue;

      string content = AC_TradeJournalRenderBeforeAuroraTrade(row);
      AC_WriteResult result = AC_WriteTextFile(final_path, content);
      if(!result.ok)
      {
         AC_TRADE_JOURNAL_STATUS.historical_generator_status = "write_failed";
         AC_TRADE_JOURNAL_STATUS.last_error = result.status + ";error=" + IntegerToString(result.error_code) + ";path=" + final_path;
         break;
      }

      written++;
      AC_TRADE_JOURNAL_STATUS.historical_files_written_this_pass++;
   }

   if(written > 0)
      AC_TRADE_JOURNAL_STATUS.historical_generator_status = "mvp_wrote_before_aurora_file";
   else if(AC_TRADE_JOURNAL_STATUS.historical_generator_status == "waiting_for_layer1_selected_history")
      AC_TRADE_JOURNAL_STATUS.historical_generator_status = "mvp_no_new_file_this_pass";

   AC_TRADE_JOURNAL_STATUS.status = "historical_mvp_active_bounded";
   AC_TRADE_JOURNAL_STATUS.last_service_duration_ms = GetTickCount() - start_ms;
   return (AC_TRADE_JOURNAL_STATUS.historical_generator_status != "write_failed" && AC_TRADE_JOURNAL_STATUS.historical_generator_status != "folder_failed");
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
   row += "|historical_files_written_this_pass=" + IntegerToString(status.historical_files_written_this_pass);
   row += "|ohlc_duration_context=read_existing_shared_store_only";
   row += "|ohlc_copyrates_used=false";
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
   text += "OHLC Duration Context: read existing Shared OHLC Store files only; CopyRates used here: FALSE\r\n";
   text += "Live Capture: " + status.live_capture_status + "\r\n";
   text += "Packet Import: " + status.packet_import_status + "\r\n";
   text += "Packet Matching: " + status.packet_matching_status + "\r\n";
   text += "Historical Files Written This Pass: " + IntegerToString(status.historical_files_written_this_pass) + "\r\n";
   text += "Packets Seen / Rejected / Orphaned / Matched: "
      + IntegerToString(status.packets_seen_total) + " / "
      + IntegerToString(status.packets_rejected_total) + " / "
      + IntegerToString(status.packets_orphaned_total) + " / "
      + IntegerToString(status.packets_matched_total) + "\r\n";
   text += "Trade Permission: FALSE\r\n";
   text += "Execution Permission: FALSE\r\n";
   text += "Prop Firm Safety: FALSE\r\n";
   text += "Contract: historical MVP writes Before Aurora reconstructed files only; OHLC context is copied from existing Shared OHLC store files only; no old-trade motive reconstruction, no packet matching, no permission, no execution.\r\n";
   if(status.last_error != "")
      text += "Last Error: " + status.last_error + "\r\n";
   return text;
}

string AC_TradeJournalStatusText()
{
   return AC_TradeJournalStatusRow(AC_TRADE_JOURNAL_STATUS) + "\r\n";
}

#endif