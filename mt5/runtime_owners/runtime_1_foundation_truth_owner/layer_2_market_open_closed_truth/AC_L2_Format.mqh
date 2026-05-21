#ifndef AC_L2_FORMAT_MQH
#define AC_L2_FORMAT_MQH

string AC_L2BoolText(const bool value)
{
   return value ? "true" : "false";
}

string AC_L2DayOfWeekText(const int day)
{
   if(day == 0) return "Sunday";
   if(day == 1) return "Monday";
   if(day == 2) return "Tuesday";
   if(day == 3) return "Wednesday";
   if(day == 4) return "Thursday";
   if(day == 5) return "Friday";
   if(day == 6) return "Saturday";
   return "unknown";
}

string AC_L2SecondsOfDayText(const int seconds)
{
   if(seconds < 0) return "unavailable";
   int s = seconds;
   if(s > 86399) s = 86399;
   int h = s / 3600;
   int m = (s % 3600) / 60;
   int sec = s % 60;
   return StringFormat("%02d:%02d:%02d", h, m, sec);
}

string AC_L2SessionWindowText(const int from_seconds, const int to_seconds)
{
   if(from_seconds < 0 || to_seconds < 0) return "unavailable";
   return AC_L2SecondsOfDayText(from_seconds) + "-" + AC_L2SecondsOfDayText(to_seconds);
}

string AC_L2TradeModeText(const long mode)
{
   if(mode == SYMBOL_TRADE_MODE_DISABLED) return "disabled";
   if(mode == SYMBOL_TRADE_MODE_LONGONLY) return "long_only";
   if(mode == SYMBOL_TRADE_MODE_SHORTONLY) return "short_only";
   if(mode == SYMBOL_TRADE_MODE_CLOSEONLY) return "close_only";
   if(mode == SYMBOL_TRADE_MODE_FULL) return "full";
   return "unknown_trade_mode_" + IntegerToString((int)mode);
}

bool AC_L2TradeModeAllowsOpenMarket(const long mode)
{
   if(mode == SYMBOL_TRADE_MODE_DISABLED) return false;
   if(mode == SYMBOL_TRADE_MODE_CLOSEONLY) return false;
   return true;
}

#endif