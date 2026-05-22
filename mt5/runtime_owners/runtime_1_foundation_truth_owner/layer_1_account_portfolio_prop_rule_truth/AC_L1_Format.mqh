#ifndef AC_L1_FORMAT_MQH
#define AC_L1_FORMAT_MQH

string AC_L1TimeText(const datetime value)
{
   if(value <= 0) return "unavailable";
   return TimeToString(value, TIME_DATE | TIME_SECONDS);
}

string AC_L1ShortTimeText(const datetime value)
{
   if(value <= 0) return "--";
   return TimeToString(value, TIME_DATE | TIME_MINUTES);
}

string AC_L1MoneyText(const double value)
{
   return DoubleToString(value, 2);
}

string AC_L1PriceText(const double value)
{
   if(value <= 0.0) return "--";
   return DoubleToString(value, 5);
}

string AC_L1VolumeText(const double value)
{
   return DoubleToString(value, 2);
}

string AC_L1PercentText(const double value)
{
   return DoubleToString(value, 2) + "%";
}

string AC_L1PadRight(string text, const int width)
{
   if(StringLen(text) >= width)
      return text + " ";
   while(StringLen(text) < width)
      text += " ";
   return text + " ";
}

string AC_L1PadLeft(string text, const int width)
{
   if(StringLen(text) >= width)
      return text + " ";
   while(StringLen(text) < width)
      text = " " + text;
   return text + " ";
}

string AC_L1TradeModeText(const long mode)
{
   if(mode == ACCOUNT_TRADE_MODE_DEMO) return "demo";
   if(mode == ACCOUNT_TRADE_MODE_CONTEST) return "contest";
   if(mode == ACCOUNT_TRADE_MODE_REAL) return "real";
   return "unknown";
}

string AC_L1PositionTypeText(const long type)
{
   if(type == POSITION_TYPE_BUY) return "buy";
   if(type == POSITION_TYPE_SELL) return "sell";
   return EnumToString((ENUM_POSITION_TYPE)type);
}

string AC_L1OrderTypeText(const long type)
{
   if(type == ORDER_TYPE_BUY) return "buy";
   if(type == ORDER_TYPE_SELL) return "sell";
   if(type == ORDER_TYPE_BUY_LIMIT) return "buy_limit";
   if(type == ORDER_TYPE_SELL_LIMIT) return "sell_limit";
   if(type == ORDER_TYPE_BUY_STOP) return "buy_stop";
   if(type == ORDER_TYPE_SELL_STOP) return "sell_stop";
   if(type == ORDER_TYPE_BUY_STOP_LIMIT) return "buy_stop_limit";
   if(type == ORDER_TYPE_SELL_STOP_LIMIT) return "sell_stop_limit";
   if(type == ORDER_TYPE_CLOSE_BY) return "close_by";
   return EnumToString((ENUM_ORDER_TYPE)type);
}

string AC_L1OrderStateText(const long state)
{
   if(state == ORDER_STATE_STARTED) return "started";
   if(state == ORDER_STATE_PLACED) return "placed";
   if(state == ORDER_STATE_CANCELED) return "canceled";
   if(state == ORDER_STATE_PARTIAL) return "partial";
   if(state == ORDER_STATE_FILLED) return "filled";
   if(state == ORDER_STATE_REJECTED) return "rejected";
   if(state == ORDER_STATE_EXPIRED) return "expired";
   return EnumToString((ENUM_ORDER_STATE)state);
}

string AC_L1DealTypeText(const long type)
{
   if(type == DEAL_TYPE_BUY) return "buy";
   if(type == DEAL_TYPE_SELL) return "sell";
   return EnumToString((ENUM_DEAL_TYPE)type);
}

string AC_L1DealEntryText(const long entry)
{
   if(entry == DEAL_ENTRY_IN) return "in";
   if(entry == DEAL_ENTRY_OUT) return "out";
   if(entry == DEAL_ENTRY_INOUT) return "inout";
   if(entry == DEAL_ENTRY_OUT_BY) return "out_by";
   return EnumToString((ENUM_DEAL_ENTRY)entry);
}

bool AC_L1DealEntryIsClosed(const long entry)
{
   return (entry == DEAL_ENTRY_OUT || entry == DEAL_ENTRY_OUT_BY || entry == DEAL_ENTRY_INOUT);
}

bool AC_L1OrderStateIsCancelLike(const long state)
{
   return (state == ORDER_STATE_CANCELED || state == ORDER_STATE_REJECTED || state == ORDER_STATE_EXPIRED);
}

#endif