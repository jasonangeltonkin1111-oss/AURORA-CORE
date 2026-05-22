#ifndef AC_L1_LIVE_EXPOSURE_MQH
#define AC_L1_LIVE_EXPOSURE_MQH

string AC_L1LiveExposureLine(const string label,
                             const int count,
                             const double volume,
                             const double pl)
{
   return AC_L1PadRight(label, 16)
      + AC_L1PadLeft(IntegerToString(count), 7)
      + AC_L1PadLeft(AC_L1VolumeText(volume), 10)
      + AC_L1PadLeft(AC_L1MoneyText(pl), 12)
      + "\r\n";
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
   text += AC_L1LiveExposureLine("buy_pending", pending_buy_count, pending_buy_volume, 0.0);
   text += AC_L1LiveExposureLine("sell_pending", pending_sell_count, pending_sell_volume, 0.0);
   text += AC_L1LiveExposureLine("pending_total", pending_total, pending_total_volume, 0.0);
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

   for(int i = 0; i < open_total; i++)
   {
      open_volume += AC_L1_POSITIONS[i].volume;
      open_pl += AC_L1_POSITIONS[i].profit;
      if(AC_L1_POSITIONS[i].stop_loss <= 0.0) open_no_sl++;
      if(AC_L1_POSITIONS[i].take_profit <= 0.0) open_no_tp++;
   }

   for(int p = 0; p < pending_total; p++)
   {
      pending_volume += AC_L1_PENDING[p].volume;
      if(AC_L1_PENDING[p].stop_loss <= 0.0) pending_no_sl++;
      if(AC_L1_PENDING[p].take_profit <= 0.0) pending_no_tp++;
   }

   string text = "\r\nLAYER 1 - LIVE OPEN/PENDING SUMMARY\r\n";
   text += "----------------------------------------\r\n";
   text += "Open / Pending:       " + IntegerToString(open_total) + " / " + IntegerToString(pending_total) + "\r\n";
   text += "Open Volume:          " + AC_L1VolumeText(open_volume) + "\r\n";
   text += "Pending Volume:       " + AC_L1VolumeText(pending_volume) + "\r\n";
   text += "Floating P/L:         " + AC_L1MoneyText(open_pl) + "\r\n";
   text += "Open Without SL/TP:   " + IntegerToString(open_no_sl) + " / " + IntegerToString(open_no_tp) + "\r\n";
   text += "Pending No SL/TP:     " + IntegerToString(pending_no_sl) + " / " + IntegerToString(pending_no_tp) + "\r\n";
   text += "Refresh Source:       near_live_snapshot_scan\r\n";
   text += "Trade Permission:     FALSE\r\n";
   return text;
}

#endif