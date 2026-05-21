#ifndef AC_L2_SCAN_MQH
#define AC_L2_SCAN_MQH

void AC_BuildLayer2Texts();

int AC_L2NormalizeSessionSecond(const datetime value)
{
   int seconds = (int)value;
   if(seconds < 0) return -1;
   if(seconds > 86400) seconds = seconds % 86400;
   return seconds;
}

bool AC_L2TimeInsideSession(const int now_seconds, const int from_seconds, const int to_seconds)
{
   if(now_seconds < 0 || from_seconds < 0 || to_seconds < 0) return false;
   if(from_seconds == to_seconds) return true;
   if(to_seconds > from_seconds)
      return (now_seconds >= from_seconds && now_seconds < to_seconds);
   return (now_seconds >= from_seconds || now_seconds < to_seconds);
}

int AC_L2MinutesUntil(const int now_seconds, const int target_seconds)
{
   if(now_seconds < 0 || target_seconds < 0) return -1;
   int delta = target_seconds - now_seconds;
   if(delta < 0) delta += 86400;
   return delta / 60;
}

int AC_L2MinutesSince(const int now_seconds, const int start_seconds)
{
   if(now_seconds < 0 || start_seconds < 0) return -1;
   int delta = now_seconds - start_seconds;
   if(delta < 0) delta += 86400;
   return delta / 60;
}

void AC_L2InitSymbolState(AC_L2SymbolState &state, const string symbol)
{
   state.symbol = symbol;
   state.broker_symbol = symbol;
   state.market_state = "unknown";
   state.market_state_reason = "not_scanned";
   state.trade_mode = -1;
   state.trade_mode_text = "unknown";
   state.trade_session_available = false;
   state.quote_session_available = false;
   state.trade_session_count_today = 0;
   state.quote_session_count_today = 0;
   state.current_day_of_week = "unknown";
   state.server_seconds_of_day = -1;
   state.active_trade_session_from = "unavailable";
   state.active_trade_session_to = "unavailable";
   state.next_trade_session_from = "unavailable";
   state.next_trade_session_to = "unavailable";
   state.minutes_since_session_open = -1;
   state.minutes_until_session_close = -1;
   state.minutes_until_next_open = -1;
   state.session_window_basis = "server_session_time_of_day";
   state.server_time_used = "TimeCurrent";
   state.server_time_basis = "broker_server_last_known_marketwatch_quote_time";
   state.symbol_info_ok = false;
   state.symbol_synchronized_checked = true;
   state.symbol_synchronized = false;
   state.tick_checked = false;
   state.tick_support_state = "not_checked";
   state.source_quality = "unknown";
   state.retries_used = 0;
   state.failure_reason = "";
   state.next_recheck_due = 0;
   state.trade_permission = false;
}

void AC_L2ScanOneSymbol(const string symbol, const int broker_index, const datetime server_time, const int day_of_week, const int seconds_of_day)
{
   int next = ArraySize(AC_L2_SYMBOLS);
   ArrayResize(AC_L2_SYMBOLS, next + 1);
   AC_L2InitSymbolState(AC_L2_SYMBOLS[next], symbol);
   AC_L2_SYMBOLS[next].current_day_of_week = AC_L2DayOfWeekText(day_of_week);
   AC_L2_SYMBOLS[next].server_seconds_of_day = seconds_of_day;

   ResetLastError();
   long trade_mode = -1;
   if(SymbolInfoInteger(symbol, SYMBOL_TRADE_MODE, trade_mode))
   {
      AC_L2_SYMBOLS[next].symbol_info_ok = true;
      AC_L2_SYMBOLS[next].trade_mode = trade_mode;
      AC_L2_SYMBOLS[next].trade_mode_text = AC_L2TradeModeText(trade_mode);
   }
   else
   {
      AC_L2_SYMBOLS[next].symbol_info_ok = false;
      AC_L2_SYMBOLS[next].failure_reason = "SymbolInfoInteger_SYMBOL_TRADE_MODE_failed_error=" + IntegerToString(GetLastError());
      AC_L2_SYMBOL_INFO_FAILURE_COUNT++;
      if(AC_L2_WORST_FAILURE_REASON == "none") AC_L2_WORST_FAILURE_REASON = AC_L2_SYMBOLS[next].failure_reason;
   }

   ResetLastError();
   bool sync_value = SymbolIsSynchronized(symbol);
   int sync_error = GetLastError();
   AC_L2_SYMBOLS[next].symbol_synchronized = sync_value;
   if(sync_error != 0 && AC_L2_SYMBOLS[next].failure_reason == "")
      AC_L2_SYMBOLS[next].failure_reason = "SymbolIsSynchronized_error=" + IntegerToString(sync_error);

   bool active_trade_session = false;
   int active_from = -1;
   int active_to = -1;
   int next_from = -1;
   int next_to = -1;
   int session_count = 0;

   for(uint session_index = 0; session_index < 24; session_index++)
   {
      datetime from_time = 0;
      datetime to_time = 0;
      ResetLastError();
      if(!SymbolInfoSessionTrade(symbol, (ENUM_DAY_OF_WEEK)day_of_week, session_index, from_time, to_time))
      {
         if(session_index == 0) AC_L2_TRADE_SESSION_FAILURE_COUNT++;
         break;
      }
      session_count++;
      int from_seconds = AC_L2NormalizeSessionSecond(from_time);
      int to_seconds = AC_L2NormalizeSessionSecond(to_time);
      if(AC_L2TimeInsideSession(seconds_of_day, from_seconds, to_seconds))
      {
         active_trade_session = true;
         active_from = from_seconds;
         active_to = to_seconds;
      }
      if(!active_trade_session && from_seconds >= 0)
      {
         int mins = AC_L2MinutesUntil(seconds_of_day, from_seconds);
         if(next_from < 0 || mins < AC_L2MinutesUntil(seconds_of_day, next_from))
         {
            next_from = from_seconds;
            next_to = to_seconds;
         }
      }
   }

   AC_L2_SYMBOLS[next].trade_session_count_today = session_count;
   AC_L2_SYMBOLS[next].trade_session_available = (session_count > 0);
   if(session_count > 0) AC_L2_TRADE_SESSION_SUCCESS_COUNT++;

   int quote_count = 0;
   for(uint quote_index = 0; quote_index < 24; quote_index++)
   {
      datetime q_from = 0;
      datetime q_to = 0;
      ResetLastError();
      if(!SymbolInfoSessionQuote(symbol, (ENUM_DAY_OF_WEEK)day_of_week, quote_index, q_from, q_to))
      {
         if(quote_index == 0) AC_L2_QUOTE_SESSION_FAILURE_COUNT++;
         break;
      }
      quote_count++;
   }
   AC_L2_SYMBOLS[next].quote_session_count_today = quote_count;
   AC_L2_SYMBOLS[next].quote_session_available = (quote_count > 0);
   if(quote_count > 0) AC_L2_QUOTE_SESSION_SUCCESS_COUNT++;

   if(active_trade_session)
   {
      AC_L2_SYMBOLS[next].active_trade_session_from = AC_L2SecondsOfDayText(active_from);
      AC_L2_SYMBOLS[next].active_trade_session_to = AC_L2SecondsOfDayText(active_to);
      AC_L2_SYMBOLS[next].minutes_since_session_open = AC_L2MinutesSince(seconds_of_day, active_from);
      AC_L2_SYMBOLS[next].minutes_until_session_close = AC_L2MinutesUntil(seconds_of_day, active_to);
   }
   if(next_from >= 0)
   {
      AC_L2_SYMBOLS[next].next_trade_session_from = AC_L2SecondsOfDayText(next_from);
      AC_L2_SYMBOLS[next].next_trade_session_to = AC_L2SecondsOfDayText(next_to);
      AC_L2_SYMBOLS[next].minutes_until_next_open = AC_L2MinutesUntil(seconds_of_day, next_from);
   }

   if(!AC_L2_SYMBOLS[next].symbol_info_ok)
   {
      AC_L2_SYMBOLS[next].market_state = "unknown";
      AC_L2_SYMBOLS[next].market_state_reason = "symbol_trade_mode_unavailable";
      AC_L2_SYMBOLS[next].source_quality = "unknown";
      AC_L2_UNKNOWN_COUNT++;
      AC_L2_SYMBOLS[next].next_recheck_due = server_time + 60;
      return;
   }

   if(!AC_L2TradeModeAllowsOpenMarket(trade_mode))
   {
      AC_L2_SYMBOLS[next].market_state = "closed";
      AC_L2_SYMBOLS[next].market_state_reason = "trade_mode_" + AC_L2_SYMBOLS[next].trade_mode_text;
      AC_L2_SYMBOLS[next].source_quality = AC_L2_SYMBOLS[next].trade_session_available ? "complete" : "partial";
      AC_L2_CLOSED_COUNT++;
      int recheck_minutes = (AC_L2_SYMBOLS[next].minutes_until_next_open >= 0 ? AC_L2_SYMBOLS[next].minutes_until_next_open : 60);
      AC_L2_SYMBOLS[next].next_recheck_due = server_time + (recheck_minutes * 60);
      return;
   }

   if(!AC_L2_SYMBOLS[next].trade_session_available)
   {
      AC_L2_SYMBOLS[next].market_state = "unknown";
      AC_L2_SYMBOLS[next].market_state_reason = "trade_session_unavailable";
      AC_L2_SYMBOLS[next].source_quality = "unknown";
      AC_L2_UNKNOWN_COUNT++;
      AC_L2_SYMBOLS[next].next_recheck_due = server_time + 60;
      return;
   }

   if(active_trade_session)
   {
      AC_L2_SYMBOLS[next].market_state = "open";
      AC_L2_SYMBOLS[next].market_state_reason = "inside_trade_session_and_trade_mode_allows_open_market";
      AC_L2_SYMBOLS[next].source_quality = AC_L2_SYMBOLS[next].quote_session_available ? "complete" : "partial_quote_session_missing";
      AC_L2_OPEN_COUNT++;
      int close_minutes = AC_L2_SYMBOLS[next].minutes_until_session_close;
      if(close_minutes < 1) close_minutes = AC_L2_REFRESH_SECONDS / 60;
      if(close_minutes < 1) close_minutes = 1;
      AC_L2_SYMBOLS[next].next_recheck_due = server_time + (close_minutes * 60);
      return;
   }

   AC_L2_SYMBOLS[next].market_state = "closed";
   AC_L2_SYMBOLS[next].market_state_reason = "outside_trade_session";
   AC_L2_SYMBOLS[next].source_quality = "complete";
   AC_L2_CLOSED_COUNT++;
   int open_minutes = (AC_L2_SYMBOLS[next].minutes_until_next_open >= 0 ? AC_L2_SYMBOLS[next].minutes_until_next_open : 60);
   if(open_minutes < 1) open_minutes = 1;
   AC_L2_SYMBOLS[next].next_recheck_due = server_time + (open_minutes * 60);
}

void AC_RefreshLayer2MarketSessionTruth()
{
   AC_L2Reset();
   datetime server_time = TimeCurrent();
   if(server_time <= 0) server_time = TimeTradeServer();
   if(server_time <= 0) server_time = TimeGMT();

   MqlDateTime dt;
   TimeToStruct(server_time, dt);
   int seconds_of_day = dt.hour * 3600 + dt.min * 60 + dt.sec;
   int day_of_week = dt.day_of_week;

   int total = SymbolsTotal(false);
   AC_L2_SYMBOLS_TOTAL = total;
   AC_L2_LAST_SERVER_DAY_OF_WEEK = day_of_week;
   AC_L2_LAST_SYMBOLS_TOTAL = total;
   AC_L2_LAST_FULL_SCAN_TIME = server_time;
   AC_L2_ROUTE_GENERATION_KEY = AC_DOSSIER_SHELL_SCHEMA_VERSION + "|server_day=" + IntegerToString(day_of_week) + "|scan_time=" + IntegerToString((int)server_time);

   if(total <= 0)
   {
      AC_L2_SCAN_STATUS = "unavailable";
      AC_L2_SCAN_FAILURE = "SymbolsTotal_false_returned_zero";
      AC_L2_WORST_FAILURE_REASON = AC_L2_SCAN_FAILURE;
      AC_L2_UNKNOWN_COUNT = 0;
      AC_L2_READY = true;
      AC_L2_SCAN_DURATION_MS = GetTickCount() - AC_L2_SCAN_STARTED_MS;
      AC_BuildLayer2Texts();
      return;
   }

   for(int idx = 0; idx < total; idx++)
   {
      string symbol = SymbolName(idx, false);
      if(symbol == "")
      {
         AC_L2_UNKNOWN_COUNT++;
         if(AC_L2_WORST_FAILURE_REASON == "none") AC_L2_WORST_FAILURE_REASON = "empty_symbol_name_at_index=" + IntegerToString(idx);
         continue;
      }
      AC_L2ScanOneSymbol(symbol, idx, server_time, day_of_week, seconds_of_day);
      AC_L2_SYMBOLS_SCANNED++;
   }

   AC_L2_SCAN_STATUS = "complete";
   if(AC_L2_UNKNOWN_COUNT > 0 || AC_L2_SYMBOL_INFO_FAILURE_COUNT > 0 || AC_L2_TRADE_SESSION_FAILURE_COUNT > 0)
      AC_L2_SCAN_STATUS = "complete_with_degraded";
   AC_L2_SCAN_DURATION_MS = GetTickCount() - AC_L2_SCAN_STARTED_MS;
   AC_L2_READY = true;
   AC_BuildLayer2Texts();
}

bool AC_L2ShouldRunFullScan()
{
   if(!AC_L2_READY) return true;
   int total = SymbolsTotal(false);
   if(total != AC_L2_LAST_SYMBOLS_TOTAL) return true;
   datetime server_time = TimeCurrent();
   if(server_time <= 0) server_time = TimeTradeServer();
   MqlDateTime dt;
   TimeToStruct(server_time, dt);
   if(dt.day_of_week != AC_L2_LAST_SERVER_DAY_OF_WEEK) return true;
   if((server_time - AC_L2_LAST_FULL_SCAN_TIME) >= AC_L2_REFRESH_SECONDS) return true;
   return false;
}

bool AC_L2AllowsDeeperLayers(const string symbol)
{
   int idx = AC_L2FindIndex(symbol);
   if(idx < 0) return false;
   return (AC_L2_SYMBOLS[idx].market_state == "open");
}

#endif