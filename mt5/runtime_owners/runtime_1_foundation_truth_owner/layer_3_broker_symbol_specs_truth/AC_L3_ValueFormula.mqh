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

void AC_L3ApplyTickValueFallback(AC_L3SymbolSpecs &s)
{
   if(s.tick_size <= 0.0 || s.point <= 0.0) return;
   double buy_tick = (s.tick_value_profit > 0.0 ? s.tick_value_profit : s.tick_value);
   double sell_tick = (s.tick_value_loss > 0.0 ? s.tick_value_loss : s.tick_value);
   if(buy_tick <= 0.0 || sell_tick <= 0.0) return;

   s.value_from_tick_value = true;
   s.money_per_tick_buy_1lot = buy_tick;
   s.money_per_tick_sell_1lot = sell_tick;
   s.money_per_point_buy_1lot = buy_tick * (s.point / s.tick_size);
   s.money_per_point_sell_1lot = sell_tick * (s.point / s.tick_size);
   s.money_per_price_unit_buy_1lot = s.money_per_point_buy_1lot / s.point;
   s.money_per_price_unit_sell_1lot = s.money_per_point_sell_1lot / s.point;
   s.value_source = "Broker tick value fallback. Confirm with OrderCalcProfit after Layer 4 quote truth.";
   s.tick_value_crosscheck_status = "Broker tick value used; OrderCalcProfit pending";
}

void AC_L3CalculateValueAndMargin(AC_L3SymbolSpecs &s)
{
   s.price_reference_status = "Calculation reference only until Layer 4";
   s.value_source = "Not available";
   s.value_from_tick_value = false;

   double price = 0.0;
   bool price_ok = AC_L3ReferencePrice(s.symbol, price);
   if(!price_ok)
   {
      s.price_reference_status = "No broker price reference available in Layer 3";
      AC_L3ApplyTickValueFallback(s);
      if(s.value_from_tick_value)
         s.failure_reason += "OrderCalcProfit deferred because no broker price reference was available; ";
      else
         s.failure_reason += "Price reference unavailable and no usable tick value fallback; ";
   }

   if(price_ok)
   {
      double profit_buy = 0.0;
      ResetLastError();
      if(s.point > 0.0 && OrderCalcProfit(ORDER_TYPE_BUY, s.symbol, 1.0, price, price + s.point, profit_buy))
      {
         s.order_calc_profit_buy_ok = true;
         s.money_per_point_buy_1lot = MathAbs(profit_buy);
         s.value_source = "OrderCalcProfit using Layer 3 price reference";
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
         s.value_source = "OrderCalcProfit using Layer 3 price reference";
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
         if(OrderCalcMargin(ORDER_TYPE_BUY, s.symbol, s.volume_min, price, margin_min_buy))
         {
            s.margin_min_buy_ok = true;
            s.margin_buy_minlot_account_ccy = margin_min_buy;
         }
         double margin_min_sell = 0.0;
         if(OrderCalcMargin(ORDER_TYPE_SELL, s.symbol, s.volume_min, price, margin_min_sell))
         {
            s.margin_min_sell_ok = true;
            s.margin_sell_minlot_account_ccy = margin_min_sell;
         }
      }
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
   else if(s.value_from_tick_value) s.tick_value_crosscheck_status = "Broker tick value used; OrderCalcProfit pending";
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