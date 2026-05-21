#ifndef AC_L2_RENDER_MQH
#define AC_L2_RENDER_MQH

string AC_L2TimeText(const datetime value)
{
   if(value <= 0) return "Unavailable";
   return TimeToString(value, TIME_DATE | TIME_SECONDS);
}

string AC_L2PercentText(const int count, const int total)
{
   if(total <= 0) return "Not available";
   return StringFormat("%.1f%%", ((double)count * 100.0) / (double)total);
}

string AC_L2TitleText(string value)
{
   if(value == "open") return "Open";
   if(value == "closed") return "Closed";
   if(value == "unknown") return "Unknown";
   StringReplace(value, "_", " ");
   if(StringLen(value) > 0) value = StringSubstr(value, 0, 1) + StringSubstr(value, 1);
   return value;
}

string AC_L2BoolTitle(const bool value)
{
   return value ? "Yes" : "No";
}

string AC_L2StatusLine(const AC_L2SymbolState &state)
{
   return state.symbol
      + "|market_state=" + state.market_state
      + "|reason=" + state.market_state_reason
      + "|trade_mode=" + state.trade_mode_text
      + "|trade_session_available=" + AC_L2BoolText(state.trade_session_available)
      + "|quote_session_available=" + AC_L2BoolText(state.quote_session_available)
      + "|next_recheck_due=" + AC_L2TimeText(state.next_recheck_due);
}

void AC_BuildLayer2Texts()
{
   int known_count = AC_L2_OPEN_COUNT + AC_L2_CLOSED_COUNT;
   string completion = AC_L2PercentText(known_count, AC_L2_SYMBOLS_TOTAL);
   string layer_status = AC_L2_SCAN_STATUS;
   if(AC_L2_SYMBOLS_TOTAL > 0 && (AC_L2_OPEN_COUNT + AC_L2_CLOSED_COUNT + AC_L2_UNKNOWN_COUNT) != AC_L2_SYMBOLS_TOTAL)
      layer_status = "Count mismatch - degraded";

   AC_L2_BOARD_SECTION = "\r\nLAYER 2 - MARKET OPEN / CLOSED TRUTH\r\n";
   AC_L2_BOARD_SECTION += "----------------------------------------\r\n";
   AC_L2_BOARD_SECTION += "Status:              " + AC_L2TitleText(layer_status) + "\r\n";
   AC_L2_BOARD_SECTION += "Broker Symbols:      " + IntegerToString(AC_L2_SYMBOLS_TOTAL) + "\r\n";
   AC_L2_BOARD_SECTION += "Open:                " + IntegerToString(AC_L2_OPEN_COUNT) + "\r\n";
   AC_L2_BOARD_SECTION += "Closed:              " + IntegerToString(AC_L2_CLOSED_COUNT) + "\r\n";
   AC_L2_BOARD_SECTION += "Unknown:             " + IntegerToString(AC_L2_UNKNOWN_COUNT) + "\r\n";
   AC_L2_BOARD_SECTION += "Known Completion:    " + completion + "\r\n";
   AC_L2_BOARD_SECTION += "Trade Sessions OK:   " + IntegerToString(AC_L2_TRADE_SESSION_SUCCESS_COUNT) + "\r\n";
   AC_L2_BOARD_SECTION += "Quote Sessions OK:   " + IntegerToString(AC_L2_QUOTE_SESSION_SUCCESS_COUNT) + "\r\n";
   AC_L2_BOARD_SECTION += "API Failures:         Trade Sessions " + IntegerToString(AC_L2_TRADE_SESSION_FAILURE_COUNT) + " | Symbol Info " + IntegerToString(AC_L2_SYMBOL_INFO_FAILURE_COUNT) + "\r\n";
   AC_L2_BOARD_SECTION += "Route Writes:         Open " + IntegerToString(AC_L2_ROUTE_WRITE_OPEN_COUNT) + " | Closed " + IntegerToString(AC_L2_ROUTE_WRITE_CLOSED_COUNT) + " | Unknown " + IntegerToString(AC_L2_ROUTE_WRITE_UNKNOWN_COUNT) + " | Failed " + IntegerToString(AC_L2_ROUTE_WRITE_FAILURE_COUNT) + "\r\n";
   AC_L2_BOARD_SECTION += "Route Cleanup:        Removed Duplicates " + IntegerToString(AC_L2_DUPLICATE_CLEANUP_COUNT) + " | Failed " + IntegerToString(AC_L2_DUPLICATE_CLEANUP_FAILURE_COUNT) + "\r\n";
   AC_L2_BOARD_SECTION += "Session Basis:        Server session time of day; session dates ignored by design\r\n";
   AC_L2_BOARD_SECTION += "Server Time Source:   TimeCurrent with broker / MarketWatch caveat\r\n";
   AC_L2_BOARD_SECTION += "Worst Blocker:        " + AC_L2TitleText(AC_L2_WORST_FAILURE_REASON) + "\r\n";
   AC_L2_BOARD_SECTION += "Trade Permission:     FALSE\r\n";
   AC_L2_BOARD_SECTION += "Cutoff Rule:          Closed symbols stop deeper layer publication until the next recheck\r\n";

   AC_L2_WORKBENCH_SECTION = "\r\nL2_MARKET_OPEN_CLOSED_SCAN\r\n";
   AC_L2_WORKBENCH_SECTION += "----------------------------------------\r\n";
   AC_L2_WORKBENCH_SECTION += "scan_status=" + layer_status + "\r\n";
   AC_L2_WORKBENCH_SECTION += "scan_duration_ms=" + IntegerToString((int)AC_L2_SCAN_DURATION_MS) + "\r\n";
   AC_L2_WORKBENCH_SECTION += "symbols_seen=" + IntegerToString(AC_L2_SYMBOLS_TOTAL) + "\r\n";
   AC_L2_WORKBENCH_SECTION += "symbols_scanned=" + IntegerToString(AC_L2_SYMBOLS_SCANNED) + "\r\n";
   AC_L2_WORKBENCH_SECTION += "open_count=" + IntegerToString(AC_L2_OPEN_COUNT) + "\r\n";
   AC_L2_WORKBENCH_SECTION += "closed_count=" + IntegerToString(AC_L2_CLOSED_COUNT) + "\r\n";
   AC_L2_WORKBENCH_SECTION += "unknown_count=" + IntegerToString(AC_L2_UNKNOWN_COUNT) + "\r\n";
   AC_L2_WORKBENCH_SECTION += "trade_session_success_count=" + IntegerToString(AC_L2_TRADE_SESSION_SUCCESS_COUNT) + "\r\n";
   AC_L2_WORKBENCH_SECTION += "trade_session_failure_count=" + IntegerToString(AC_L2_TRADE_SESSION_FAILURE_COUNT) + "\r\n";
   AC_L2_WORKBENCH_SECTION += "quote_session_success_count=" + IntegerToString(AC_L2_QUOTE_SESSION_SUCCESS_COUNT) + "\r\n";
   AC_L2_WORKBENCH_SECTION += "quote_session_failure_count=" + IntegerToString(AC_L2_QUOTE_SESSION_FAILURE_COUNT) + "\r\n";
   AC_L2_WORKBENCH_SECTION += "symbol_info_failure_count=" + IntegerToString(AC_L2_SYMBOL_INFO_FAILURE_COUNT) + "\r\n";
   AC_L2_WORKBENCH_SECTION += "route_write_open_count=" + IntegerToString(AC_L2_ROUTE_WRITE_OPEN_COUNT) + "\r\n";
   AC_L2_WORKBENCH_SECTION += "route_write_closed_count=" + IntegerToString(AC_L2_ROUTE_WRITE_CLOSED_COUNT) + "\r\n";
   AC_L2_WORKBENCH_SECTION += "route_write_unknown_count=" + IntegerToString(AC_L2_ROUTE_WRITE_UNKNOWN_COUNT) + "\r\n";
   AC_L2_WORKBENCH_SECTION += "route_write_failure_count=" + IntegerToString(AC_L2_ROUTE_WRITE_FAILURE_COUNT) + "\r\n";
   AC_L2_WORKBENCH_SECTION += "duplicate_cleanup_count=" + IntegerToString(AC_L2_DUPLICATE_CLEANUP_COUNT) + "\r\n";
   AC_L2_WORKBENCH_SECTION += "duplicate_cleanup_failure_count=" + IntegerToString(AC_L2_DUPLICATE_CLEANUP_FAILURE_COUNT) + "\r\n";
   AC_L2_WORKBENCH_SECTION += "session_time_basis=server_session_time_of_day\r\n";
   AC_L2_WORKBENCH_SECTION += "server_time_source=TimeCurrent_then_TimeTradeServer_then_TimeGMT_fallback\r\n";
   AC_L2_WORKBENCH_SECTION += "cutoff_rule=closed_symbol_blocks_deeper_layer_publication_until_next_recheck_due\r\n";
   AC_L2_WORKBENCH_SECTION += "worst_failure_reason=" + AC_L2_WORST_FAILURE_REASON + "\r\n";
   AC_L2_WORKBENCH_SECTION += "trade_permission=false\r\n";
}

string AC_Layer2BoardSection()
{
   if(!AC_L2_READY) return "\r\nLAYER 2 - MARKET OPEN / CLOSED TRUTH\r\n----------------------------------------\r\nStatus: Pending\r\n";
   return AC_L2_BOARD_SECTION;
}

string AC_Layer2WorkbenchSection()
{
   if(!AC_L2_READY) return "\r\nL2_MARKET_OPEN_CLOSED_SCAN\r\nstatus=pending\r\n";
   return AC_L2_WORKBENCH_SECTION;
}

string AC_Layer2DossierSection(const string symbol)
{
   string text = "\r\nLAYER 2 - MARKET OPEN / CLOSED TRUTH\r\n";
   text += "----------------------------------------\r\n";
   int idx = AC_L2FindIndex(symbol);
   if(idx < 0)
   {
      text += "Market State: Unknown\r\n";
      text += "Reason: Layer 2 packet missing for this symbol\r\n";
      text += "Deeper Layer Cutoff: Yes\r\n";
      text += "Trade Permission: FALSE\r\n";
      return text;
   }

   AC_L2SymbolState s = AC_L2_SYMBOLS[idx];
   text += "Market State: " + AC_L2TitleText(s.market_state) + "\r\n";
   text += "Reason: " + AC_L2TitleText(s.market_state_reason) + "\r\n";
   text += "Trade Mode: " + s.trade_mode_text + "\r\n";
   text += "Trade Session Available: " + AC_L2BoolTitle(s.trade_session_available) + "\r\n";
   text += "Quote Session Available: " + AC_L2BoolTitle(s.quote_session_available) + "\r\n";
   text += "Trade Sessions Today: " + IntegerToString(s.trade_session_count_today) + "\r\n";
   text += "Quote Sessions Today: " + IntegerToString(s.quote_session_count_today) + "\r\n";
   text += "Session Window Basis: Server session time of day\r\n";
   text += "Server Time Used: " + s.server_time_used + "\r\n";
   text += "Server Time Basis: " + AC_L2TitleText(s.server_time_basis) + "\r\n";
   text += "Server Day: " + s.current_day_of_week + "\r\n";
   text += "Server Time Of Day: " + AC_L2SecondsOfDayText(s.server_seconds_of_day) + "\r\n";
   text += "Active Trade Session: " + s.active_trade_session_from + " - " + s.active_trade_session_to + "\r\n";
   text += "Next Trade Session: " + s.next_trade_session_from + " - " + s.next_trade_session_to + "\r\n";
   text += "Minutes Since Session Open: " + IntegerToString(s.minutes_since_session_open) + "\r\n";
   text += "Minutes Until Session Close: " + IntegerToString(s.minutes_until_session_close) + "\r\n";
   text += "Minutes Until Next Open: " + IntegerToString(s.minutes_until_next_open) + "\r\n";
   text += "Symbol Synchronization Checked: " + AC_L2BoolTitle(s.symbol_synchronized_checked) + "\r\n";
   text += "Symbol Synchronized: " + AC_L2BoolTitle(s.symbol_synchronized) + "\r\n";
   text += "Tick Support: " + AC_L2TitleText(s.tick_support_state) + "\r\n";
   text += "Source Quality: " + AC_L2TitleText(s.source_quality) + "\r\n";
   text += "Next Recheck Due: " + AC_L2TimeText(s.next_recheck_due) + "\r\n";
   text += "Deeper Layer Cutoff: " + (s.market_state == "open" ? "No" : "Yes") + "\r\n";
   text += "Cutoff Reason: " + (s.market_state == "open" ? "Market session is open" : "Market is not confirmed open") + "\r\n";
   text += "Trade Permission: FALSE\r\n";
   return text;
}

string AC_Layer2StatusRow()
{
   return "schema_name=layer_status|schema_version=v2.1|layer_id=2|layer_name=" + AC_LAYER_2_NAME
      + "|source_owner=" + AC_RUNTIME1_OWNER
      + "|build_version=" + AC_BUILD_VERSION
      + "|upgrade_id=" + AC_UPGRADE_ID
      + "|layer_status=" + (AC_L2_READY ? AC_L2_SCAN_STATUS : "pending")
      + "|symbols_total=" + IntegerToString(AC_L2_SYMBOLS_TOTAL)
      + "|open_count=" + IntegerToString(AC_L2_OPEN_COUNT)
      + "|closed_count=" + IntegerToString(AC_L2_CLOSED_COUNT)
      + "|unknown_count=" + IntegerToString(AC_L2_UNKNOWN_COUNT)
      + "|trade_session_success=" + IntegerToString(AC_L2_TRADE_SESSION_SUCCESS_COUNT)
      + "|trade_session_failure=" + IntegerToString(AC_L2_TRADE_SESSION_FAILURE_COUNT)
      + "|route_write_failures=" + IntegerToString(AC_L2_ROUTE_WRITE_FAILURE_COUNT)
      + "|cutoff_rule=closed_symbols_block_deeper_layers"
      + "|trade_permission=false";
}

#endif