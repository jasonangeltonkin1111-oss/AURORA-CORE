#ifndef AC_L3_FORMAT_MQH
#define AC_L3_FORMAT_MQH

string AC_L3BoolText(const bool value)
{
   return value ? "true" : "false";
}

string AC_L3TextOrNA(const string value)
{
   if(value == "") return "Not available";
   return value;
}

string AC_L3MoneyText(const double value)
{
   return DoubleToString(value, 2);
}

string AC_L3NumberText(const double value, const int digits = 6)
{
   return DoubleToString(value, digits);
}

string AC_L3TradeModeText(const long mode)
{
   if(mode == SYMBOL_TRADE_MODE_DISABLED) return "Disabled";
   if(mode == SYMBOL_TRADE_MODE_LONGONLY) return "Long only";
   if(mode == SYMBOL_TRADE_MODE_SHORTONLY) return "Short only";
   if(mode == SYMBOL_TRADE_MODE_CLOSEONLY) return "Close only";
   if(mode == SYMBOL_TRADE_MODE_FULL) return "Full access";
   return "Unknown trade mode " + IntegerToString((int)mode);
}

string AC_L3VolumeGridQuality(const AC_L3SymbolSpecs &s)
{
   if(s.volume_min <= 0.0 || s.volume_step <= 0.0 || s.volume_max <= 0.0) return "Volume Grid Unavailable";
   if(s.volume_min > s.volume_max) return "Volume Grid Invalid";
   return "Volume Grid Ready";
}

string AC_L3ValueQualityText(const AC_L3SymbolSpecs &s)
{
   if(s.order_calc_profit_buy_ok && s.order_calc_profit_sell_ok && s.money_per_point_buy_1lot > 0.0 && s.money_per_point_sell_1lot > 0.0 && s.point > 0.0 && s.volume_step > 0.0)
      return "Value Formula Ready";
   if(s.order_calc_profit_buy_ok || s.order_calc_profit_sell_ok || s.value_from_tick_value)
      return "Value Formula Partial";
   return "Value Formula Unavailable";
}

string AC_L3MarginQualityText(const AC_L3SymbolSpecs &s)
{
   if(s.order_calc_margin_buy_ok && s.order_calc_margin_sell_ok) return "Margin Formula Ready";
   if(s.order_calc_margin_buy_ok || s.order_calc_margin_sell_ok || s.margin_rate_buy_ok || s.margin_rate_sell_ok) return "Margin Formula Partial";
   return "Margin Formula Unavailable";
}

string AC_L3SpecQualityText(const AC_L3SymbolSpecs &s)
{
   if(s.scan_state == "Skipped Unknown") return "Skipped - Market Unknown";
   if(s.required_fields_failed <= 0) return "Specs Ready";
   if(s.required_fields_ok > 0) return "Specs Partial";
   return "Specs Unavailable";
}

#endif