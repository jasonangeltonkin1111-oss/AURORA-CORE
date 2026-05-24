#ifndef AC_L1_CONCENTRATION_MAPS_MQH
#define AC_L1_CONCENTRATION_MAPS_MQH

string AC_L1ConcentrationLevel(const double share_pct)
{
   if(share_pct >= 50.0) return "extreme concentration";
   if(share_pct >= 35.0) return "high concentration";
   if(share_pct >= 25.0) return "moderate concentration";
   return "diversified enough for sample";
}

int AC_L1HourOfDatetime(const datetime t)
{
   MqlDateTime parts;
   TimeToStruct(t, parts);
   return parts.hour;
}

string AC_L1ConcentrationTimeWindow(const datetime t)
{
   int h = AC_L1HourOfDatetime(t);
   if(h < 6) return "00-06";
   if(h < 10) return "06-10";
   if(h < 14) return "10-14";
   if(h < 18) return "14-18";
   return "18-24";
}

string AC_L1ConcentrationHoldBucket(const datetime entry_time,
                                    const datetime close_time)
{
   long seconds = (long)(close_time - entry_time);
   if(seconds < 0) seconds = 0;
   if(seconds <= 300) return "0-5m";
   if(seconds <= 1800) return "5-30m";
   if(seconds <= 7200) return "30m-2h";
   if(seconds <= 86400) return "2h-1d";
   return "1d+";
}

string AC_L1TopSymbolByRows(int &top_rows,
                            double &top_net)
{
   string best_symbol = "none";
   top_rows = 0;
   top_net = 0.0;
   string used = "|";
   for(int i = 0; i < ArraySize(AC_L1_CLOSED); i++)
   {
      string symbol = AC_L1_CLOSED[i].symbol;
      if(symbol == "" || StringFind(used, "|" + symbol + "|") >= 0) continue;
      used += symbol + "|";
      int rows = 0;
      double net = 0.0;
      for(int j = 0; j < ArraySize(AC_L1_CLOSED); j++)
      {
         if(AC_L1_CLOSED[j].symbol != symbol) continue;
         rows++;
         net += AC_L1_CLOSED[j].net_result;
      }
      if(rows > top_rows)
      {
         top_rows = rows;
         top_net = net;
         best_symbol = symbol;
      }
   }
   return best_symbol;
}

string AC_L1TopAssetByRows(int &top_rows,
                           double &top_net)
{
   int rows[6];
   double net[6];
   for(int i = 0; i < 6; i++)
   {
      rows[i] = 0;
      net[i] = 0.0;
   }
   for(int r = 0; r < ArraySize(AC_L1_CLOSED); r++)
   {
      int idx = AC_L1AssetClassIndex(AC_L1_CLOSED[r].symbol);
      if(idx < 0 || idx > 5) idx = 5;
      rows[idx]++;
      net[idx] += AC_L1_CLOSED[r].net_result;
   }
   int best = 0;
   for(int c = 1; c < 6; c++) if(rows[c] > rows[best]) best = c;
   top_rows = rows[best];
   top_net = net[best];
   return AC_L1AssetClassName(best);
}

string AC_L1PortfolioConcentrationMap()
{
   int total_rows = ArraySize(AC_L1_CLOSED);
   int top_symbol_rows = 0;
   double top_symbol_net = 0.0;
   string top_symbol = AC_L1TopSymbolByRows(top_symbol_rows, top_symbol_net);

   int top_asset_rows = 0;
   double top_asset_net = 0.0;
   string top_asset = AC_L1TopAssetByRows(top_asset_rows, top_asset_net);

   int buy_rows = 0;
   int sell_rows = 0;
   double buy_net = 0.0;
   double sell_net = 0.0;
   int time_rows[5];
   double time_net[5];
   int hold_rows[5];
   double hold_net[5];
   for(int i = 0; i < 5; i++)
   {
      time_rows[i] = 0;
      time_net[i] = 0.0;
      hold_rows[i] = 0;
      hold_net[i] = 0.0;
   }

   for(int r = 0; r < total_rows; r++)
   {
      if(AC_L1_CLOSED[r].side == "buy")
      {
         buy_rows++;
         buy_net += AC_L1_CLOSED[r].net_result;
      }
      else if(AC_L1_CLOSED[r].side == "sell")
      {
         sell_rows++;
         sell_net += AC_L1_CLOSED[r].net_result;
      }

      string window = AC_L1ConcentrationTimeWindow(AC_L1_CLOSED[r].close_time);
      int wi = 4;
      if(window == "00-06") wi = 0;
      else if(window == "06-10") wi = 1;
      else if(window == "10-14") wi = 2;
      else if(window == "14-18") wi = 3;
      time_rows[wi]++;
      time_net[wi] += AC_L1_CLOSED[r].net_result;

      string hold = AC_L1ConcentrationHoldBucket(AC_L1_CLOSED[r].entry_time, AC_L1_CLOSED[r].close_time);
      int hi = 4;
      if(hold == "0-5m") hi = 0;
      else if(hold == "5-30m") hi = 1;
      else if(hold == "30m-2h") hi = 2;
      else if(hold == "2h-1d") hi = 3;
      hold_rows[hi]++;
      hold_net[hi] += AC_L1_CLOSED[r].net_result;
   }

   double top_symbol_share = (total_rows > 0 ? (100.0 * top_symbol_rows / total_rows) : 0.0);
   double top_asset_share = (total_rows > 0 ? (100.0 * top_asset_rows / total_rows) : 0.0);
   double buy_share = (total_rows > 0 ? (100.0 * buy_rows / total_rows) : 0.0);
   double sell_share = (total_rows > 0 ? (100.0 * sell_rows / total_rows) : 0.0);

   string text = AC_L1MapHeader("PORTFOLIO CONCENTRATION MAP");
   text += "Scope:                  selected closed history only\r\n";
   text += "Purpose:                show where sample exposure is clustered by count, not edge proof\r\n";
   text += "Top Symbol:             " + top_symbol + " | Rows " + IntegerToString(top_symbol_rows) + " | Share " + AC_PercentText(top_symbol_rows, total_rows) + " | Net " + AC_L1MoneyText(top_symbol_net) + " | " + AC_L1ConcentrationLevel(top_symbol_share) + "\r\n";
   text += "Top Asset Class:        " + top_asset + " | Rows " + IntegerToString(top_asset_rows) + " | Share " + AC_PercentText(top_asset_rows, total_rows) + " | Net " + AC_L1MoneyText(top_asset_net) + " | " + AC_L1ConcentrationLevel(top_asset_share) + "\r\n";
   text += "Direction Mix:          Buy " + IntegerToString(buy_rows) + " (" + DoubleToString(buy_share, 1) + "%) Net " + AC_L1MoneyText(buy_net) + " | Sell " + IntegerToString(sell_rows) + " (" + DoubleToString(sell_share, 1) + "%) Net " + AC_L1MoneyText(sell_net) + "\r\n";
   text += "Time Window Rows:       00-06=" + IntegerToString(time_rows[0]) + " | 06-10=" + IntegerToString(time_rows[1]) + " | 10-14=" + IntegerToString(time_rows[2]) + " | 14-18=" + IntegerToString(time_rows[3]) + " | 18-24=" + IntegerToString(time_rows[4]) + "\r\n";
   text += "Hold Buckets:           0-5m=" + IntegerToString(hold_rows[0]) + " | 5-30m=" + IntegerToString(hold_rows[1]) + " | 30m-2h=" + IntegerToString(hold_rows[2]) + " | 2h-1d=" + IntegerToString(hold_rows[3]) + " | 1d+=" + IntegerToString(hold_rows[4]) + "\r\n";
   text += "Concentration Policy:   diagnostic only; does not grant trade permission\r\n";
   text += "Trade Permission:       FALSE\r\n";
   return text;
}

#endif