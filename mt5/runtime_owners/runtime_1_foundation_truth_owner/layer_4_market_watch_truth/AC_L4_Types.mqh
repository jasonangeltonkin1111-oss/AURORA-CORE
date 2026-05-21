#ifndef AC_L4_TYPES_MQH
#define AC_L4_TYPES_MQH

struct AC_L4SymbolPacket
{
   string symbol;
   string market_state;
   string scan_status;

   bool tick_available;
   int tick_error_code;
   datetime tick_time_broker;
   long tick_time_msc;
   long tick_age_ms;
   double tick_age_seconds;
   uint tick_flags;

   double bid;
   double ask;
   double last;
   long volume;
   double volume_real;

   bool bid_valid;
   bool ask_valid;
   bool last_valid;
   bool bid_ask_valid;
   bool quote_valid_flag;

   double point;
   long digits;
   double spread_price_live;
   double spread_points_live;
   double spread_pips_live;
   double spread_pct_live;
   double spread_bps_live;
   string spread_source;
   long spread_spec_points;
   bool spread_float;
   string spread_vs_spec_status;
   string zero_spread_state;
   string spread_score;

   double daily_change_pct;
   string daily_change_status;
   double daily_open;
   double daily_high_bid;
   double daily_low_bid;
   double daily_high_ask;
   double daily_low_ask;
   double daily_high_last;
   double daily_low_last;
   double daily_range_position_pct;

   double session_aw;
   double session_volume;
   double session_turnover;
   double session_interest;
   long session_deals;
   long session_buy_orders;
   long session_sell_orders;
   string activity_status;

   string quote_quality;
   string surface_quality;
   string failure_reason;
   bool trade_permission;
};

#endif
