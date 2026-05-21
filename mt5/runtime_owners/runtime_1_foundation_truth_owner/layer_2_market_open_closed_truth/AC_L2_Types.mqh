#ifndef AC_L2_TYPES_MQH
#define AC_L2_TYPES_MQH

struct AC_L2SymbolState
{
   string symbol;
   string broker_symbol;
   string market_state;              // open | closed | unknown
   string market_state_reason;
   long   trade_mode;
   string trade_mode_text;
   bool   trade_session_available;
   bool   quote_session_available;
   int    trade_session_count_today;
   int    quote_session_count_today;
   string current_day_of_week;
   int    server_seconds_of_day;
   string active_trade_session_from;
   string active_trade_session_to;
   string next_trade_session_from;
   string next_trade_session_to;
   int    minutes_since_session_open;
   int    minutes_until_session_close;
   int    minutes_until_next_open;
   string session_window_basis;
   string server_time_used;
   string server_time_basis;
   bool   symbol_info_ok;
   bool   symbol_synchronized_checked;
   bool   symbol_synchronized;
   bool   tick_checked;
   string tick_support_state;
   string source_quality;
   int    retries_used;
   string failure_reason;
   datetime next_recheck_due;
   bool   trade_permission;
};

#endif