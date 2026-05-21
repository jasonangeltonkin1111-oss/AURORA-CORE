#ifndef AC_L1_TYPES_MQH
#define AC_L1_TYPES_MQH

struct AC_L1PositionRow
{
   ulong ticket;
   string symbol;
   string side;
   double volume;
   double entry_price;
   double stop_loss;
   double take_profit;
   double current_price;
   double profit;
   datetime open_time;
   long magic;
   string comment;
};

struct AC_L1PendingOrderRow
{
   ulong ticket;
   string symbol;
   string type_text;
   string state_text;
   double volume;
   double price;
   double stop_loss;
   double take_profit;
   datetime setup_time;
   datetime expiration_time;
   long magic;
   string comment;
};

struct AC_L1ClosedTradeRow
{
   ulong deal_ticket;
   ulong order_ticket;
   ulong entry_order_ticket;
   long position_id;
   string symbol;
   string side;
   string entry_text;
   double volume;
   datetime entry_time;
   double entry_price;
   datetime close_time;
   double close_price;
   double stop_loss;
   double take_profit;
   double profit;
   double commission;
   double swap;
   double net_result;
   long magic;
   string comment;
   long close_reason;
   string source_quality;
   string entry_reconstruction_status;
   string paired_entry_status;
   string stop_loss_source;
   string take_profit_source;
};

struct AC_L1OrderEventRow
{
   ulong ticket;
   string symbol;
   string type_text;
   string state_text;
   double volume_initial;
   double price_open;
   double stop_loss;
   double take_profit;
   datetime setup_time;
   datetime done_time;
   long magic;
   string comment;
};

struct AC_L1SymbolStats
{
   string symbol;
   double net_result;
   int closed_count;
   int win_count;
   int loss_count;
   int open_count;
   int pending_count;
   int canceled_count;
};

struct AC_L1DayStats
{
   string day;
   double net_result;
   int closed_count;
};

#endif