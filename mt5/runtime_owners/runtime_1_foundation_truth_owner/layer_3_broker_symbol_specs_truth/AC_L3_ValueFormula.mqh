#ifndef AC_L3_VALUE_FORMULA_MQH
#define AC_L3_VALUE_FORMULA_MQH

bool AC_L3ReferencePrice(const string symbol, double &price)
{
   price = 0.0;
   double ask = 0.0;
   double bid = 0.0;
   if(SymbolInfoDouble(symbol, SYMBOL_ASK, ask) && ask > 0.0)
   {
      price = ask;
      return true;
   }
   if(SymbolInfoDouble(symbol, SYMBOL_BID, bid) && bid > 0.0)
   {
      price = bid;
      return true;
   }
   return false;
}

void AC_L3CalculateValueAndMargin(AC_L3SymbolSpecs &s)
{
   s.price_reference_status = "Calculation reference only until Layer 4";
   double price = 0.0;
   if(!AC_L3ReferencePrice(s.symbol, price))
   {
      s.failure_reason += "Price reference unavailable for value checks; ";
      s.value_quality = "Value Formula Unavailable";
      s.margin_quality = "Margin Formula Unavailable";
      return;
   }

   double profit_buy = 0.0;
   ResetLastError();
   if(s.point > 0.0 && OrderCalcProfit(ORDER_TYPE_BUY, s.symbol, 1.0, price, price + s.point, profit_buy))
   {
      s.order_calc_profit_buy_ok = true;
      s.money_per_point_buy_1lot = MathAbs(profit_buy);
      AC_L3_ORDERCALC_PROFIT_BUY_SUCCESS++;
   }
   else
   {
      AC_L3_ORDERCALC_PROFIT_BUY_FAILURE++;
      s.failure_reason += "OrderCalcProfit buy failed; ";
   }

   double profit_sell = 0.0;
   ResetLastError();
   if(s.point > 0.0 && OrderCalcProfit(ORDER_TYPE_SELL, s.symbol, 1.0, price, price - s.point, profit_sell))
   {
      s.order_calc_profit_sell_ok = true;
      s.money_per_point_sell_1lot = MathAbs(profit_sell);
      AC_L3_ORDERCALC_PROFIT_SELL_SUCCESS++;
   }
   else
   {
      AC_L3_ORDERCALC_PROFIT_SELL_FAILURE++;
      s.failure_reason += "OrderCalcProfit sell failed; ";
   }

   if(s.point > 0.0 && s.tick_size > 0.0)
   {
      s.money_per_tick_buy_1lot = s.money_per_point_buy_1lot * (s.tick_size / s.point);
      s.money_per_tick_sell_1lot = s.money_per_point_sell_1lot * (s.tick_size / s.point);
      s.money_per_price_unit_buy_1lot = s.money_per_point_buy_1lot / s.point;
      s.money_per_price_unit_sell_1lot = s.money_per_point_sell_1lot / s.point;
   }

   double margin_buy = 0.0;
   ResetLastError();
   if(OrderCalcMargin(ORDER_TYPE_BUY, s.symbol, 1.0, price, margin_buy))
   {
      s.order_calc_margin_buy_ok = true;
      s.margin_buy_1lot_account_ccy = margin_buy;
      AC_L3_ORDERCALC_MARGIN_BUY_SUCCESS++;
   }
   else
   {
      AC_L3_ORDERCALC_MARGIN_BUY_FAILURE++;
      s.failure_reason += "OrderCalcMargin buy failed; ";
   }

   double margin_sell = 0.0;
   ResetLastError();
   if(OrderCalcMargin(ORDER_TYPE_SELL, s.symbol, 1.0, price, margin_sell))
   {
      s.order_calc_margin_sell_ok = true;
      s.margin_sell_1lot_account_ccy = margin_sell;
      AC_L3_ORDERCALC_MARGIN_SELL_SUCCESS++;
   }
   else
   {
      AC_L3_ORDERCALC_MARGIN_SELL_FAILURE++;
      s.failure_reason += "OrderCalcMargin sell failed; ";
   }

   if(s.volume_min > 0.0)
   {
      double margin_min_buy = 0.0;
      if(OrderCalcMargin(ORDER_TYPE_BUY, s.symbol, s.volume_min, price, margin_min_buy)) s.margin_buy_minlot_account_ccy = margin_min_buy;
      double margin_min_sell = 0.0;
      if(OrderCalcMargin(ORDER_TYPE_SELL, s.symbol, s.volume_min, price, margin_min_sell)) s.margin_sell_minlot_account_ccy = margin_min_sell;
   }

   double initial = 0.0;
   double maintenance = 0.0;
   if(SymbolInfoMarginRate(s.symbol, ORDER_TYPE_BUY, initial, maintenance))
   {
      s.margin_rate_buy_ok = true;
      s.margin_rate_buy_initial = initial;
      s.margin_rate_buy_maintenance = maintenance;
      AC_L3_MARGIN_RATE_BUY_SUCCESS++;
   }
   else AC_L3_MARGIN_RATE_BUY_FAILURE++;

   initial = 0.0;
   maintenance = 0.0;
   if(SymbolInfoMarginRate(s.symbol, ORDER_TYPE_SELL, initial, maintenance))
   {
      s.margin_rate_sell_ok = true;
      s.margin_rate_sell_initial = initial;
      s.margin_rate_sell_maintenance = maintenance;
      AC_L3_MARGIN_RATE_SELL_SUCCESS++;
   }
   else AC_L3_MARGIN_RATE_SELL_FAILURE++;

   double reference_tick_value = s.tick_value;
   double calc_tick = MathMax(s.money_per_tick_buy_1lot, s.money_per_tick_sell_1lot);
   if(reference_tick_value <= 0.0 || calc_tick <= 0.0) s.tick_value_crosscheck_status = "Not available";
   else
   {
      double delta = MathAbs(reference_tick_value - calc_tick);
      double tolerance = MathMax(0.01, reference_tick_value * 0.10);
      s.tick_value_crosscheck_status = (delta <= tolerance ? "Match" : "Mismatch - prefer OrderCalcProfit for later sizing" );
   }

   s.value_quality = AC_L3ValueQualityText(s);
   s.margin_quality = AC_L3MarginQualityText(s);
}

#endif