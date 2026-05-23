#ifndef AC_L1_LIVE_EXPOSURE_MQH
#define AC_L1_LIVE_EXPOSURE_MQH

bool AC_L1LiveSideIsBuy(const string side)
{
   return (StringFind(side, "buy") >= 0);
}

bool AC_L1LiveSideIsSell(const string side)
{
   return (StringFind(side, "sell") >= 0);
}

bool AC_L1LiveRiskGeometryValid(const string side,
                                const double entry_price,
                                const double stop_loss)
{
   if(entry_price <= 0.0 || stop_loss <= 0.0) return false;
   if(AC_L1LiveSideIsBuy(side)) return (stop_loss < entry_price);
   if(AC_L1LiveSideIsSell(side)) return (stop_loss > entry_price);
   return false;
}

bool AC_L1EstimateRiskAtSL(const string symbol,
                           const string side,
                           const double volume,
                           const double entry_price,
                           const double stop_loss,
                           double &risk_money)
{
   risk_money = 0.0;
   if(symbol == "" || volume <= 0.0) return false;
   if(!AC_L1LiveRiskGeometryValid(side, entry_price, stop_loss)) return false;

   ENUM_ORDER_TYPE order_type = ORDER_TYPE_BUY;
   if(AC_L1LiveSideIsSell(side)) order_type = ORDER_TYPE_SELL;
   else if(!AC_L1LiveSideIsBuy(side)) return false;

   double profit_at_sl = 0.0;
   ResetLastError();
   if(!OrderCalcProfit(order_type, symbol, volume, entry_price, stop_loss, profit_at_sl))
      return false;

   if(profit_at_sl >= 0.0)
      return false;

   risk_money = MathAbs(profit_at_sl);
   return (risk_money > 0.0);
}

string AC_L1LiveExposureLine(const string label,
                             const int count,
                             const double volume,
                             const double pl)
{
   return AC_L1PadRight(AC_L1DisplayText(label), 16)
      + AC_L1PadLeft(IntegerToString(count), 7)
      + AC_L1PadLeft(AC_L1VolumeText(volume), 10)
      + AC_L1PadLeft(AC_L1MoneyText(pl), 12)
      + "\r\n";
}

string AC_L1OpenPendingRiskReadinessMap()
{
   int open_total = ArraySize(AC_L1_POSITIONS);
   int pending_total = ArraySize(AC_L1_PENDING);
   int open_with_sl = 0;
   int open_without_sl = 0;
   int open_valid_geometry = 0;
   int open_invalid_geometry = 0;
   int open_risk_estimated = 0;
   int open_risk_blocked = 0;
   int pending_with_sl = 0;
   int pending_without_sl = 0;
   int pending_valid_geometry = 0;
   int pending_invalid_geometry = 0;
   int pending_risk_estimated = 0;
   int pending_risk_blocked = 0;
   double open_est_risk_money = 0.0;
   double pending_est_risk_money = 0.0;

   for(int i = 0; i < open_total; i++)
   {
      bool has_sl = (AC_L1_POSITIONS[i].stop_loss > 0.0);
      if(has_sl) open_with_sl++; else open_without_sl++;

      bool valid_geometry = AC_L1LiveRiskGeometryValid(AC_L1_POSITIONS[i].side, AC_L1_POSITIONS[i].entry_price, AC_L1_POSITIONS[i].stop_loss);
      if(valid_geometry) open_valid_geometry++;
      else if(has_sl) open_invalid_geometry++;

      double risk = 0.0;
      if(AC_L1EstimateRiskAtSL(AC_L1_POSITIONS[i].symbol, AC_L1_POSITIONS[i].side, AC_L1_POSITIONS[i].volume, AC_L1_POSITIONS[i].entry_price, AC_L1_POSITIONS[i].stop_loss, risk))
      {
         open_risk_estimated++;
         open_est_risk_money += risk;
      }
      else open_risk_blocked++;
   }

   for(int p = 0; p < pending_total; p++)
   {
      bool has_sl = (AC_L1_PENDING[p].stop_loss > 0.0);
      if(has_sl) pending_with_sl++; else pending_without_sl++;

      bool valid_geometry = AC_L1LiveRiskGeometryValid(AC_L1_PENDING[p].type_text, AC_L1_PENDING[p].price, AC_L1_PENDING[p].stop_loss);
      if(valid_geometry) pending_valid_geometry++;
      else if(has_sl) pending_invalid_geometry++;

      double risk = 0.0;
      if(AC_L1EstimateRiskAtSL(AC_L1_PENDING[p].symbol, AC_L1_PENDING[p].type_text, AC_L1_PENDING[p].volume, AC_L1_PENDING[p].price, AC_L1_PENDING[p].stop_loss, risk))
      {
         pending_risk_estimated++;
         pending_est_risk_money += risk;
      }
      else pending_risk_blocked++;
   }

   double open_risk_pct = (AC_L1_EQUITY > 0.0 ? (open_est_risk_money / AC_L1_EQUITY) * 100.0 : 0.0);
   double pending_risk_pct = (AC_L1_EQUITY > 0.0 ? (pending_est_risk_money / AC_L1_EQUITY) * 100.0 : 0.0);
   double combined_risk_money = open_est_risk_money + pending_est_risk_money;
   double combined_risk_pct = (AC_L1_EQUITY > 0.0 ? (combined_risk_money / AC_L1_EQUITY) * 100.0 : 0.0);

   string text = AC_L1MapHeader("OPEN / PENDING RISK-AT-SL READINESS MAP");
   text += "Purpose:                estimated risk-at-SL readiness for live open/pending rows\r\n";
   text += "Estimate Source:        OrderCalcProfit using entry/open price to SL in account currency\r\n";
   text += "Proof Status:           estimated, not execution permission or prop-rule proof\r\n";
   text += "Open Positions:         " + IntegerToString(open_total) + "\r\n";
   text += "Open With SL:           " + IntegerToString(open_with_sl) + "\r\n";
   text += "Open Without SL:        " + IntegerToString(open_without_sl) + "\r\n";
   text += "Open Valid Geometry:    " + IntegerToString(open_valid_geometry) + "\r\n";
   text += "Open Invalid Geometry:  " + IntegerToString(open_invalid_geometry) + "\r\n";
   text += "Open Risk Estimated:    " + IntegerToString(open_risk_estimated) + " / " + IntegerToString(open_total) + "\r\n";
   text += "Open Risk Blocked:      " + IntegerToString(open_risk_blocked) + "\r\n";
   text += "Open Est Risk Money:    " + AC_L1MoneyText(open_est_risk_money) + " (" + AC_L1PercentText(open_risk_pct) + " equity)\r\n";
   text += "Pending Orders:         " + IntegerToString(pending_total) + "\r\n";
   text += "Pending With SL:        " + IntegerToString(pending_with_sl) + "\r\n";
   text += "Pending Without SL:     " + IntegerToString(pending_without_sl) + "\r\n";
   text += "Pending Valid Geometry: " + IntegerToString(pending_valid_geometry) + "\r\n";
   text += "Pending Invalid Geometry: " + IntegerToString(pending_invalid_geometry) + "\r\n";
   text += "Pending Risk Estimated: " + IntegerToString(pending_risk_estimated) + " / " + IntegerToString(pending_total) + "\r\n";
   text += "Pending Risk Blocked:   " + IntegerToString(pending_risk_blocked) + "\r\n";
   text += "Pending Est Risk Money: " + AC_L1MoneyText(pending_est_risk_money) + " (" + AC_L1PercentText(pending_risk_pct) + " equity)\r\n";
   text += "Combined Est Risk:      " + AC_L1MoneyText(combined_risk_money) + " (" + AC_L1PercentText(combined_risk_pct) + " equity)\r\n";
   text += "Trade Permission:       FALSE\r\n";
   return text;
}

string AC_L1OpenPendingLiveMap()
{
   int open_total = ArraySize(AC_L1_POSITIONS);
   int pending_total = ArraySize(AC_L1_PENDING);
   int buy_count = 0;
   int sell_count = 0;
   int no_sl_count = 0;
   int no_tp_count = 0;
   double buy_volume = 0.0;
   double sell_volume = 0.0;
   double buy_pl = 0.0;
   double sell_pl = 0.0;
   double total_volume = 0.0;
   double total_pl = 0.0;

   for(int i = 0; i < open_total; i++)
   {
      total_volume += AC_L1_POSITIONS[i].volume;
      total_pl += AC_L1_POSITIONS[i].profit;
      if(AC_L1_POSITIONS[i].stop_loss <= 0.0) no_sl_count++;
      if(AC_L1_POSITIONS[i].take_profit <= 0.0) no_tp_count++;
      if(AC_L1_POSITIONS[i].side == "buy")
      {
         buy_count++;
         buy_volume += AC_L1_POSITIONS[i].volume;
         buy_pl += AC_L1_POSITIONS[i].profit;
      }
      else if(AC_L1_POSITIONS[i].side == "sell")
      {
         sell_count++;
         sell_volume += AC_L1_POSITIONS[i].volume;
         sell_pl += AC_L1_POSITIONS[i].profit;
      }
   }

   int pending_buy_count = 0;
   int pending_sell_count = 0;
   int pending_no_sl_count = 0;
   int pending_no_tp_count = 0;
   double pending_buy_volume = 0.0;
   double pending_sell_volume = 0.0;
   double pending_total_volume = 0.0;

   for(int p = 0; p < pending_total; p++)
   {
      pending_total_volume += AC_L1_PENDING[p].volume;
      if(AC_L1_PENDING[p].stop_loss <= 0.0) pending_no_sl_count++;
      if(AC_L1_PENDING[p].take_profit <= 0.0) pending_no_tp_count++;
      if(StringFind(AC_L1_PENDING[p].type_text, "buy") >= 0)
      {
         pending_buy_count++;
         pending_buy_volume += AC_L1_PENDING[p].volume;
      }
      else if(StringFind(AC_L1_PENDING[p].type_text, "sell") >= 0)
      {
         pending_sell_count++;
         pending_sell_volume += AC_L1_PENDING[p].volume;
      }
   }

   double equity_pct = (AC_L1_EQUITY > 0.0 ? (total_pl / AC_L1_EQUITY) * 100.0 : 0.0);

   string text = AC_L1MapHeader("OPEN / PENDING LIVE EXPOSURE MAP");
   text += "Freshness Source:       current PositionsTotal/OrdersTotal scan inside Layer 1\r\n";
   text += "Open Positions:         " + IntegerToString(open_total) + "\r\n";
   text += "Pending Orders:         " + IntegerToString(pending_total) + "\r\n";
   text += "Floating P/L:           " + AC_L1MoneyText(total_pl) + " (" + AC_L1PercentText(equity_pct) + " equity)\r\n";
   text += "Open Direction Map\r\n";
   text += AC_L1PadRight("Side", 16) + AC_L1PadLeft("Count", 7) + AC_L1PadLeft("Volume", 10) + AC_L1PadLeft("P/L", 12) + "\r\n";
   text += AC_L1LiveExposureLine("buy", buy_count, buy_volume, buy_pl);
   text += AC_L1LiveExposureLine("sell", sell_count, sell_volume, sell_pl);
   text += AC_L1LiveExposureLine("total", open_total, total_volume, total_pl);
   text += "Open Rows Without SL:   " + IntegerToString(no_sl_count) + "\r\n";
   text += "Open Rows Without TP:   " + IntegerToString(no_tp_count) + "\r\n";
   text += "Pending Direction Map\r\n";
   text += AC_L1PadRight("Side", 16) + AC_L1PadLeft("Count", 7) + AC_L1PadLeft("Volume", 10) + AC_L1PadLeft("P/L", 12) + "\r\n";
   text += AC_L1LiveExposureLine("buy pending", pending_buy_count, pending_buy_volume, 0.0);
   text += AC_L1LiveExposureLine("sell pending", pending_sell_count, pending_sell_volume, 0.0);
   text += AC_L1LiveExposureLine("pending total", pending_total, pending_total_volume, 0.0);
   text += "Pending Rows Without SL: " + IntegerToString(pending_no_sl_count) + "\r\n";
   text += "Pending Rows Without TP: " + IntegerToString(pending_no_tp_count) + "\r\n";
   text += "Trade Permission:       FALSE\r\n";
   return text;
}

string AC_L1OpenPendingBoardSummary()
{
   int open_total = ArraySize(AC_L1_POSITIONS);
   int pending_total = ArraySize(AC_L1_PENDING);
   double open_volume = 0.0;
   double open_pl = 0.0;
   double pending_volume = 0.0;
   int open_no_sl = 0;
   int open_no_tp = 0;
   int pending_no_sl = 0;
   int pending_no_tp = 0;
   double open_est_risk = 0.0;
   double pending_est_risk = 0.0;
   int open_risk_estimated = 0;
   int pending_risk_estimated = 0;

   for(int i = 0; i < open_total; i++)
   {
      open_volume += AC_L1_POSITIONS[i].volume;
      open_pl += AC_L1_POSITIONS[i].profit;
      if(AC_L1_POSITIONS[i].stop_loss <= 0.0) open_no_sl++;
      if(AC_L1_POSITIONS[i].take_profit <= 0.0) open_no_tp++;
      double risk = 0.0;
      if(AC_L1EstimateRiskAtSL(AC_L1_POSITIONS[i].symbol, AC_L1_POSITIONS[i].side, AC_L1_POSITIONS[i].volume, AC_L1_POSITIONS[i].entry_price, AC_L1_POSITIONS[i].stop_loss, risk))
      {
         open_est_risk += risk;
         open_risk_estimated++;
      }
   }

   for(int p = 0; p < pending_total; p++)
   {
      pending_volume += AC_L1_PENDING[p].volume;
      if(AC_L1_PENDING[p].stop_loss <= 0.0) pending_no_sl++;
      if(AC_L1_PENDING[p].take_profit <= 0.0) pending_no_tp++;
      double risk = 0.0;
      if(AC_L1EstimateRiskAtSL(AC_L1_PENDING[p].symbol, AC_L1_PENDING[p].type_text, AC_L1_PENDING[p].volume, AC_L1_PENDING[p].price, AC_L1_PENDING[p].stop_loss, risk))
      {
         pending_est_risk += risk;
         pending_risk_estimated++;
      }
   }

   double combined_risk = open_est_risk + pending_est_risk;
   double combined_risk_pct = (AC_L1_EQUITY > 0.0 ? (combined_risk / AC_L1_EQUITY) * 100.0 : 0.0);

   string text = "\r\nLAYER 1 - LIVE OPEN/PENDING SUMMARY\r\n";
   text += "----------------------------------------\r\n";
   text += "Open / Pending:       " + IntegerToString(open_total) + " / " + IntegerToString(pending_total) + "\r\n";
   text += "Open Volume:          " + AC_L1VolumeText(open_volume) + "\r\n";
   text += "Pending Volume:       " + AC_L1VolumeText(pending_volume) + "\r\n";
   text += "Floating P/L:         " + AC_L1MoneyText(open_pl) + "\r\n";
   text += "Open Without SL/TP:   " + IntegerToString(open_no_sl) + " / " + IntegerToString(open_no_tp) + "\r\n";
   text += "Pending No SL/TP:     " + IntegerToString(pending_no_sl) + " / " + IntegerToString(pending_no_tp) + "\r\n";
   text += "Est Risk at SL:       " + AC_L1MoneyText(combined_risk) + " (" + AC_L1PercentText(combined_risk_pct) + " equity)\r\n";
   text += "Risk Rows Estimated:  " + IntegerToString(open_risk_estimated) + " open / " + IntegerToString(pending_risk_estimated) + " pending\r\n";
   text += "Refresh Source:       near-live snapshot scan\r\n";
   text += "Trade Permission:     FALSE\r\n";
   return text;
}

#endif