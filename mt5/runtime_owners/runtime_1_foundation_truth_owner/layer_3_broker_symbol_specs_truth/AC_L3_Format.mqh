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

string AC_L3AdaptiveMoneyText(const double value)
{
   double abs_value = MathAbs(value);
   if(abs_value == 0.0)
      return "0.00";
   if(abs_value < 0.000001)
      return DoubleToString(value, 10);
   if(abs_value < 0.005)
      return DoubleToString(value, 8);
   if(abs_value < 1.0)
      return DoubleToString(value, 6);
   return DoubleToString(value, 2);
}

string AC_L3MoneyText(const double value)
{
   return AC_L3AdaptiveMoneyText(value);
}

string AC_L3CalculationMoneyText(const double value, const bool available)
{
   // Calculation-money fields are used as account-currency value/margin proof.
   // A broker/API call can return success with a zero result for closed or
   // conversion-limited symbols; zero is not usable value truth, so render it
   // honestly as unavailable instead of fake precision.
   if(!available || value <= 0.0)
      return "Not available";
   return AC_L3AdaptiveMoneyText(value);
}

string AC_L3ReferencePriceText(const bool available, const double value)
{
   if(!available)
      return "Not available";
   return DoubleToString(value, 8);
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
   // Value formula readiness is about account-currency value per point/tick.
   // Volume grid belongs to AC_L3VolumeGridQuality() and must not downgrade
   // proven OrderCalcProfit value truth.
   if(s.order_calc_profit_buy_ok && s.order_calc_profit_sell_ok && s.money_per_point_buy_1lot > 0.0 && s.money_per_point_sell_1lot > 0.0 && s.point > 0.0)
      return "Value Formula Ready";
   if((s.order_calc_profit_buy_ok && s.money_per_point_buy_1lot > 0.0) || (s.order_calc_profit_sell_ok && s.money_per_point_sell_1lot > 0.0) || s.value_from_tick_value)
      return "Value Formula Partial";
   return "Value Formula Unavailable";
}

string AC_L3MarginQualityText(const AC_L3SymbolSpecs &s)
{
   if(s.order_calc_margin_buy_ok && s.order_calc_margin_sell_ok && s.margin_buy_1lot_account_ccy > 0.0 && s.margin_sell_1lot_account_ccy > 0.0) return "Margin Formula Ready";
   if((s.order_calc_margin_buy_ok && s.margin_buy_1lot_account_ccy > 0.0) || (s.order_calc_margin_sell_ok && s.margin_sell_1lot_account_ccy > 0.0) || s.margin_rate_buy_ok || s.margin_rate_sell_ok) return "Margin Formula Partial";
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