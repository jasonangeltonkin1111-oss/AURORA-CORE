#ifndef AC_L3_VALUE_FORMULA_MQH
#define AC_L3_VALUE_FORMULA_MQH

string AC_L3ErrorText(const int error_code)
{
   if(error_code == 0) return "0";
   return IntegerToString(error_code);
}

bool AC_L3ReferencePricesFromTick(AC_L3SymbolSpecs &s)
{
   MqlTick tick;
   ResetLastError();
   if(!SymbolInfoTick(s.symbol, tick))
   {
      s.value_reference_error = GetLastError();
      s.price_reference_status = "No tick packet from SymbolInfoTick. Error " + AC_L3ErrorText(s.value_reference_error);
      s.value_reference_detail = "SymbolInfoTick failed; no Layer 3 price reference. Layer 4 must verify quote/tick freshness.";
      return false;
   }

   s.value_reference_error = 0;
   bool buy_ok = (tick.ask > 0.0);
   bool sell_ok = (tick.bid > 0.0);
   if(buy_ok)
   {
      s.value_reference_buy_ok = true;
      s.value_reference_buy_price = tick.ask;
   }
   if(sell_ok)
   {
      s.value_reference_sell_ok = true;
      s.value_reference_sell_price = tick.bid;
   }

   if(buy_ok && sell_ok)
   {
      s.price_reference_status = "SymbolInfoTick bid/ask reference available; freshness still belongs to Layer 4";
      s.value_reference_detail = "buy_reference=ask; sell_reference=bid; Layer 3 uses it only for calculation diagnostics.";
      return true;
   }

   if(buy_ok || sell_ok)
   {
      s.price_reference_status = "Partial SymbolInfoTick reference available; freshness still belongs to Layer 4";
      s.value_reference_detail = "One side of bid/ask was zero or unavailable. Layer 3 can diagnose only the available side.";
      return true;
   }

   s.price_reference_status = "SymbolInfoTick returned no positive bid/ask reference";
   s.value_reference_detail = "Tick packet existed, but bid and ask were not positive. This is no usable reference price, not an OrderCalc API failure.";
   return false;
}

void AC_L3ApplyTickValueFallback(AC_L3SymbolSpecs &s)
{
   s.tick_value_fallback_status = "Not used";
   if(s.tick_size <= 0.0 || s.point <= 0.0)
   {
      s.tick_value_fallback_status = "Not used - point or tick size missing/zero";
      return;
   }

   double buy_tick = (s.tick_value_profit > 0.0 ? s.tick_value_profit : s.tick_value);
   double sell_tick = (s.tick_value_loss > 0.0 ? s.tick_value_loss : s.tick_value);
   if(buy_tick <= 0.0 || sell_tick <= 0.0)
   {
      s.tick_value_fallback_status = "Not used - broker tick value missing/zero";
      return;
   }

   bool filled_buy = false;
   bool filled_sell = false;

   if(!s.order_calc_profit_buy_ok)
   {
      s.money_per_tick_buy_1lot = buy_tick;
      s.money_per_point_buy_1lot = buy_tick * (s.point / s.tick_size);
      s.money_per_price_unit_buy_1lot = s.money_per_point_buy_1lot / s.point;
      s.value_buy_status = "Fallback used - OrderCalcProfit buy not proven";
      filled_buy = true;
   }

   if(!s.order_calc_profit_sell_ok)
   {
      s.money_per_tick_sell_1lot = sell_tick;
      s.money_per_point_sell_1lot = sell_tick * (s.point / s.tick_size);
      s.money_per_price_unit_sell_1lot = s.money_per_point_sell_1lot / s.point;
      s.value_sell_status = "Fallback used - OrderCalcProfit sell not proven";
      filled_sell = true;
   }

   if(!filled_buy && !filled_sell)
   {
      s.tick_value_fallback_status = "Not used - OrderCalcProfit already supplied both sides";
      return;
   }

   s.value_from_tick_value = true;
   if(filled_buy && filled_sell)
      s.tick_value_fallback_status = "Used - broker tick value filled both missing sides";
   else if(filled_buy)
      s.tick_value_fallback_status = "Used - broker tick value filled missing buy side only";
   else
      s.tick_value_fallback_status = "Used - broker tick value filled missing sell side only";

   if(s.order_calc_profit_buy_ok || s.order_calc_profit_sell_ok)
   {
      s.value_source = "Mixed: OrderCalcProfit for proven side; broker tick value fallback for missing side";
      s.tick_value_crosscheck_status = "Partial fallback used; prefer OrderCalcProfit-proven side where available";
   }
   else
   {
      s.value_source = "Broker tick value fallback. Confirm with OrderCalcProfit after Layer 4 quote truth.";
      s.tick_value_crosscheck_status = "Broker tick value used; OrderCalcProfit pending";
   }
}

void AC_L3CalculateValueAndMargin(AC_L3SymbolSpecs &s)
{
   s.price_reference_status = "Calculation reference only until Layer 4";
   s.value_source = "Not available";
   s.value_from_tick_value = false;

   bool any_reference_ok = AC_L3ReferencePricesFromTick(s);
   if(!any_reference_ok)
   {
      AC_L3ApplyTickValueFallback(s);
      if(s.value_from_tick_value)
         s.failure_reason += "OrderCalcProfit and OrderCalcMargin not called because no usable SymbolInfoTick bid/ask reference existed; broker tick value fallback used; ";
      else
         s.failure_reason += "No usable SymbolInfoTick bid/ask reference and no usable tick value fallback; ";
   }

   if(s.value_reference_buy_ok)
   {
      double profit_buy = 0.0;
      ResetLastError();
      if(s.point > 0.0 && OrderCalcProfit(ORDER_TYPE_BUY, s.symbol, 1.0, s.value_reference_buy_price, s.value_reference_buy_price + s.point, profit_buy))
      {
         s.order_calc_profit_buy_ok = true;
         s.money_per_point_buy_1lot = MathAbs(profit_buy);
         s.value_source = "OrderCalcProfit using SymbolInfoTick ask reference";
         s.value_buy_status = "OrderCalcProfit success";
         AC_L3_ORDERCALC_PROFIT_BUY_SUCCESS++;
      }
      else
      {
         s.order_calc_profit_buy_error = GetLastError();
         AC_L3_ORDERCALC_PROFIT_BUY_FAILURE++;
         s.value_buy_status = "OrderCalcProfit failed. Error " + AC_L3ErrorText(s.order_calc_profit_buy_error);
         s.failure_reason += "OrderCalcProfit buy failed error=" + AC_L3ErrorText(s.order_calc_profit_buy_error) + "; ";
      }

      double margin_buy = 0.0;
      ResetLastError();
      if(OrderCalcMargin(ORDER_TYPE_BUY, s.symbol, 1.0, s.value_reference_buy_price, margin_buy))
      {
         s.order_calc_margin_buy_ok = true;
         s.margin_buy_1lot_account_ccy = margin_buy;
         s.margin_buy_status = "OrderCalcMargin success";
         AC_L3_ORDERCALC_MARGIN_BUY_SUCCESS++;
      }
      else
      {
         s.order_calc_margin_buy_error = GetLastError();
         AC_L3_ORDERCALC_MARGIN_BUY_FAILURE++;
         s.margin_buy_status = "OrderCalcMargin failed. Error " + AC_L3ErrorText(s.order_calc_margin_buy_error);
         s.failure_reason += "OrderCalcMargin buy failed error=" + AC_L3ErrorText(s.order_calc_margin_buy_error) + "; ";
      }

      if(s.volume_min > 0.0)
      {
         double margin_min_buy = 0.0;
         ResetLastError();
         if(OrderCalcMargin(ORDER_TYPE_BUY, s.symbol, s.volume_min, s.value_reference_buy_price, margin_min_buy))
         {
            s.margin_min_buy_ok = true;
            s.margin_buy_minlot_account_ccy = margin_min_buy;
            s.margin_min_buy_status = "OrderCalcMargin success";
         }
         else
         {
            s.margin_min_buy_error = GetLastError();
            s.margin_min_buy_status = "OrderCalcMargin failed. Error " + AC_L3ErrorText(s.margin_min_buy_error);
         }
      }
      else s.margin_min_buy_status = "Not called - minimum volume missing/zero";
   }
   else
   {
      s.value_buy_status = "Not called - no positive ask reference from SymbolInfoTick";
      s.margin_buy_status = "Not called - no positive ask reference from SymbolInfoTick";
      s.margin_min_buy_status = "Not called - no positive ask reference from SymbolInfoTick";
   }

   if(s.value_reference_sell_ok)
   {
      double profit_sell = 0.0;
      ResetLastError();
      if(s.point > 0.0 && OrderCalcProfit(ORDER_TYPE_SELL, s.symbol, 1.0, s.value_reference_sell_price, s.value_reference_sell_price - s.point, profit_sell))
      {
         s.order_calc_profit_sell_ok = true;
         s.money_per_point_sell_1lot = MathAbs(profit_sell);
         s.value_source = "OrderCalcProfit using SymbolInfoTick bid reference";
         s.value_sell_status = "OrderCalcProfit success";
         AC_L3_ORDERCALC_PROFIT_SELL_SUCCESS++;
      }
      else
      {
         s.order_calc_profit_sell_error = GetLastError();
         AC_L3_ORDERCALC_PROFIT_SELL_FAILURE++;
         s.value_sell_status = "OrderCalcProfit failed. Error " + AC_L3ErrorText(s.order_calc_profit_sell_error);
         s.failure_reason += "OrderCalcProfit sell failed error=" + AC_L3ErrorText(s.order_calc_profit_sell_error) + "; ";
      }

      double margin_sell = 0.0;
      ResetLastError();
      if(OrderCalcMargin(ORDER_TYPE_SELL, s.symbol, 1.0, s.value_reference_sell_price, margin_sell))
      {
         s.order_calc_margin_sell_ok = true;
         s.margin_sell_1lot_account_ccy = margin_sell;
         s.margin_sell_status = "OrderCalcMargin success";
         AC_L3_ORDERCALC_MARGIN_SELL_SUCCESS++;
      }
      else
      {
         s.order_calc_margin_sell_error = GetLastError();
         AC_L3_ORDERCALC_MARGIN_SELL_FAILURE++;
         s.margin_sell_status = "OrderCalcMargin failed. Error " + AC_L3ErrorText(s.order_calc_margin_sell_error);
         s.failure_reason += "OrderCalcMargin sell failed error=" + AC_L3ErrorText(s.order_calc_margin_sell_error) + "; ";
      }

      if(s.volume_min > 0.0)
      {
         double margin_min_sell = 0.0;
         ResetLastError();
         if(OrderCalcMargin(ORDER_TYPE_SELL, s.symbol, s.volume_min, s.value_reference_sell_price, margin_min_sell))
         {
            s.margin_min_sell_ok = true;
            s.margin_sell_minlot_account_ccy = margin_min_sell;
            s.margin_min_sell_status = "OrderCalcMargin success";
         }
         else
         {
            s.margin_min_sell_error = GetLastError();
            s.margin_min_sell_status = "OrderCalcMargin failed. Error " + AC_L3ErrorText(s.margin_min_sell_error);
         }
      }
      else s.margin_min_sell_status = "Not called - minimum volume missing/zero";
   }
   else
   {
      s.value_sell_status = "Not called - no positive bid reference from SymbolInfoTick";
      s.margin_sell_status = "Not called - no positive bid reference from SymbolInfoTick";
      s.margin_min_sell_status = "Not called - no positive bid reference from SymbolInfoTick";
   }

   if(any_reference_ok && (!s.order_calc_profit_buy_ok || !s.order_calc_profit_sell_ok))
      AC_L3ApplyTickValueFallback(s);

   if(s.point > 0.0 && s.tick_size > 0.0)
   {
      if(s.order_calc_profit_buy_ok)
      {
         s.money_per_tick_buy_1lot = s.money_per_point_buy_1lot * (s.tick_size / s.point);
         s.money_per_price_unit_buy_1lot = s.money_per_point_buy_1lot / s.point;
      }
      if(s.order_calc_profit_sell_ok)
      {
         s.money_per_tick_sell_1lot = s.money_per_point_sell_1lot * (s.tick_size / s.point);
         s.money_per_price_unit_sell_1lot = s.money_per_point_sell_1lot / s.point;
      }
   }

   double initial = 0.0;
   double maintenance = 0.0;
   ResetLastError();
   if(SymbolInfoMarginRate(s.symbol, ORDER_TYPE_BUY, initial, maintenance))
   {
      s.margin_rate_buy_ok = true;
      s.margin_rate_buy_initial = initial;
      s.margin_rate_buy_maintenance = maintenance;
      s.margin_rate_buy_status = "SymbolInfoMarginRate success";
      AC_L3_MARGIN_RATE_BUY_SUCCESS++;
   }
   else
   {
      s.margin_rate_buy_error = GetLastError();
      s.margin_rate_buy_status = "SymbolInfoMarginRate failed. Error " + AC_L3ErrorText(s.margin_rate_buy_error);
      AC_L3_MARGIN_RATE_BUY_FAILURE++;
   }

   initial = 0.0;
   maintenance = 0.0;
   ResetLastError();
   if(SymbolInfoMarginRate(s.symbol, ORDER_TYPE_SELL, initial, maintenance))
   {
      s.margin_rate_sell_ok = true;
      s.margin_rate_sell_initial = initial;
      s.margin_rate_sell_maintenance = maintenance;
      s.margin_rate_sell_status = "SymbolInfoMarginRate success";
      AC_L3_MARGIN_RATE_SELL_SUCCESS++;
   }
   else
   {
      s.margin_rate_sell_error = GetLastError();
      s.margin_rate_sell_status = "SymbolInfoMarginRate failed. Error " + AC_L3ErrorText(s.margin_rate_sell_error);
      AC_L3_MARGIN_RATE_SELL_FAILURE++;
   }

   double reference_tick_value = s.tick_value;
   double calc_tick = MathMax(s.money_per_tick_buy_1lot, s.money_per_tick_sell_1lot);
   if(reference_tick_value <= 0.0 || calc_tick <= 0.0) s.tick_value_crosscheck_status = "Not available - broker tick value or calculated tick value was zero";
   else if(s.value_from_tick_value) s.tick_value_crosscheck_status = "Broker tick value used where OrderCalcProfit was not proven";
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