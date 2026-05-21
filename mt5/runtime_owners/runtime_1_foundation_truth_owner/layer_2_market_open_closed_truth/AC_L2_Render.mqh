#ifndef AC_L2_RENDER_MQH
#define AC_L2_RENDER_MQH

string AC_L2TimeText(const datetime value)
{
   if(value <= 0) return "unavailable";
   return TimeToString(value, TIME_DATE | TIME_SECONDS);
}

string AC_L2PercentText(const int count, const int total)
{
   if(total <= 0) return "not_available";
   return StringFormat("%.1f%%", ((double)count * 100.0) / (double)total);
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
      layer_status = "degraded_count_mismatch";

   AC_L2_BOARD_SECTION = "\r\nLAYER 2 - MARKET OPEN / CLOSED TRUTH\r\n";
   AC_L2_BOARD_SECTION += "----------------------------------------\r\n";
   AC_L2_BOARD_SECTION += "Status:              " + layer_status + "\r\n";
   AC_L2_BOARD_SECTION += "Broker Symbols:      " + IntegerToString(AC_L2_SYMBOLS_TOTAL) + "\r\n";
   AC_L2_BOARD_SECTION += "Open:                " + IntegerToString(AC_L2_OPEN_COUNT) + "\r\n";
   AC_L2_BOARD_SECTION += "Closed:              " + IntegerToString(AC_L2_CLOSED_COUNT) + "\r\n";
   AC_L2_BOARD_SECTION += "Unknown:             " + IntegerToString(AC_L2_UNKNOWN_COUNT) + "\r\n";
   AC_L2_BOARD_SECTION += "Known Completion:    " + completion + "\r\n";
   AC_L2_BOARD_SECTION += "Trade Sessions OK:   " + IntegerToString(AC_L2_TRADE_SESSION_SUCCESS_COUNT) + "\r\n";
   AC_L2_BOARD_SECTION += "Quote Sessions OK:   " + IntegerToString(AC_L2_QUOTE_SESSION_SUCCESS_COUNT) + "\r\n";
   AC_L2_BOARD_SECTION += "API Failures:         trade_session=" + IntegerToString(AC_L2_TRADE_SESSION_FAILURE_COUNT) + " symbol_info=" + IntegerToString(AC_L2_SYMBOL_INFO_FAILURE_COUNT) + "\r\n";
   AC_L2_BOARD_SECTION += "Route Writes:         open=" + IntegerToString(AC_L2_ROUTE_WRITE_OPEN_COUNT) + " closed=" + IntegerToString(AC_L2_ROUTE_WRITE_CLOSED_COUNT) + " unknown=" + IntegerToString(AC_L2_ROUTE_WRITE_UNKNOWN_COUNT) + " failed=" + IntegerToString(AC_L2_ROUTE_WRITE_FAILURE_COUNT) + "\r\n";
   AC_L2_BOARD_SECTION += "Route Cleanup:        removed_duplicates=" + IntegerToString(AC_L2_DUPLICATE_CLEANUP_COUNT) + " cleanup_failed=" + IntegerToString(AC_L2_DUPLICATE_CLEANUP_FAILURE_COUNT) + "\r\n";
   AC_L2_BOARD_SECTION += "Session Basis:        server_session_time_of_day; session dates ignored by design\r\n";
   AC_L2_BOARD_SECTION += "Server Time Source:   TimeCurrent with broker/MarketWatch caveat\r\n";
   AC_L2_BOARD_SECTION += "Worst Blocker:        " + AC_L2_WORST_FAILURE_REASON + "\r\n";
   AC_L2_BOARD_SECTION += "Trade Permission:     FALSE\r\n";
   AC_L2_BOARD_SECTION += "Cutoff Rule:          closed symbols stop deeper layer publication until next_recheck_due\r\n";

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
   if(!AC_L2_READY) return "\r\nLAYER 2 - MARKET OPEN / CLOSED TRUTH\r\n----------------------------------------\r\nstatus=pending\r\n";
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
      text += "market_state=unknown\r\n";
      text += "market_state_reason=l2_packet_missing_for_symbol\r\n";
      text += "deeper_layer_cutoff=true\r\n";
      text += "trade_permission=false\r\n";
      return text;
   }

   AC_L2SymbolState s = AC_L2_SYMBOLS[idx];
   text += "market_state=" + s.market_state + "\r\n";
   text += "market_state_reason=" + s.market_state_reason + "\r\n";
   text += "trade_mode=" + IntegerToString((int)s.trade_mode) + "\r\n";
   text += "trade_mode_text=" + s.trade_mode_text + "\r\n";
   text += "trade_session_available=" + AC_L2BoolText(s.trade_session_available) + "\r\n";
   text += "quote_session_available=" + AC_L2BoolText(s.quote_session_available) + "\r\n";
   text += "trade_session_count_today=" + IntegerToString(s.trade_session_count_today) + "\r\n";
   text += "quote_session_count_today=" + IntegerToString(s.quote_session_count_today) + "\r\n";
   text += "session_window_basis=" + s.session_window_basis + "\r\n";
   text += "server_time_used=" + s.server_time_used + "\r\n";
   text += "server_time_basis=" + s.server_time_basis + "\r\n";
   text += "server_day_of_week=" + s.current_day_of_week + "\r\n";
   text += "server_seconds_of_day=" + AC_L2SecondsOfDayText(s.server_seconds_of_day) + "\r\n";
   text += "active_trade_session=" + s.active_trade_session_from + "-" + s.active_trade_session_to + "\r\n";
   text += "next_trade_session=" + s.next_trade_session_from + "-" + s.next_trade_session_to + "\r\n";
   text += "minutes_since_session_open=" + IntegerToString(s.minutes_since_session_open) + "\r\n";
   text += "minutes_until_session_close=" + IntegerToString(s.minutes_until_session_close) + "\r\n";
   text += "minutes_until_next_open=" + IntegerToString(s.minutes_until_next_open) + "\r\n";
   text += "symbol_synchronized_checked=" + AC_L2BoolText(s.symbol_synchronized_checked) + "\r\n";
   text += "symbol_synchronized=" + AC_L2BoolText(s.symbol_synchronized) + "\r\n";
   text += "tick_support_state=" + s.tick_support_state + "\r\n";
   text += "source_quality=" + s.source_quality + "\r\n";
   text += "next_recheck_due=" + AC_L2TimeText(s.next_recheck_due) + "\r\n";
   text += "deeper_layer_cutoff=" + (s.market_state == "open" ? "false" : "true") + "\r\n";
   text += "deeper_layer_cutoff_reason=" + (s.market_state == "open" ? "market_session_open" : "market_not_confirmed_open") + "\r\n";
   text += "trade_permission=false\r\n";
   return text;
}

string AC_Layer2StatusRow()
{
   return "schema_name=layer_status|schema_version=v2.0|layer_id=2|layer_name=" + AC_LAYER_2_NAME
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