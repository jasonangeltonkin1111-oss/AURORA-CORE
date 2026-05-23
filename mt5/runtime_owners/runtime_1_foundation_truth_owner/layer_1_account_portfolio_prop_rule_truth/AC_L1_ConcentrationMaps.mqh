#ifndef AC_L1_CONCENTRATION_MAPS_MQH
#define AC_L1_CONCENTRATION_MAPS_MQH

string AC_L1ConcentrationLevel(const double share_pct)
{
   if(share_pct >= 50.0) return "extreme concentration";
   if(share_pct >= 35.0) return "high concentration";
   if(share_pct >= 25.0) return "moderate concentration";
   return "diversified enough for sample";
}

string AC_L1ConcentrationTimeWindow(const datetime t)
{
   int h = TimeHour(t);
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

      string tw = AC_L1ConcentrationTimeWindow(AC_L1_CLOSED[r].close_time);
      int ti = 4;
      if(tw == "00-06") ti = 0;
      else if(tw == "06-10") ti = 1;
      else if(tw == "10-14") ti = 2;
      else if(tw == "14-18") ti = 3;
      time_rows[ti]++;
      time_net[ti] += AC_L1_CLOSED[r].net_result;

      string hb = AC_L1ConcentrationHoldBucket(AC_L1_CLOSED[r].entry_time, AC_L1_CLOSED[r].close_time);
      int hi = 4;
      if(hb == "0-5m") hi = 0;
      else if(hb == "5-30m") hi = 1;
      else if(hb == "30m-2h") hi = 2;
      else if(hb == "2h-1d") hi = 3;
      hold_rows[hi]++;
      hold_net[hi] += AC_L1_CLOSED[r].net_result;
   }

   int top_direction_rows = (buy_rows >= sell_rows ? buy_rows : sell_rows);
   double top_direction_net = (buy_rows >= sell_rows ? buy_net : sell_net);
   string top_direction = (buy_rows >= sell_rows ? "buy" : "sell");

   int top_time_i = 0;
   int top_hold_i = 0;
   for(int i = 1; i < 5; i++)
   {
      if(time_rows[i] > time_rows[top_time_i]) top_time_i = i;
      if(hold_rows[i] > hold_rows[top_hold_i]) top_hold_i = i;
   }
   string time_name[5] = {"00-06", "06-10", "10-14", "14-18", "18-24"};
   string hold_name[5] = {"0-5m", "5-30m", "30m-2h", "2h-1d", "1d+"};

   double top_symbol_share = (total_rows > 0 ? ((double)top_symbol_rows * 100.0) / total_rows : 0.0);
   double top_asset_share = (total_rows > 0 ? ((double)top_asset_rows * 100.0) / total_rows : 0.0);
   double top_direction_share = (total_rows > 0 ? ((double)top_direction_rows * 100.0) / total_rows : 0.0);
   double top_time_share = (total_rows > 0 ? ((double)time_rows[top_time_i] * 100.0) / total_rows : 0.0);
   double top_hold_share = (total_rows > 0 ? ((double)hold_rows[top_hold_i] * 100.0) / total_rows : 0.0);

   double max_share = top_symbol_share;
   string max_basis = "symbol";
   if(top_asset_share > max_share){ max_share = top_asset_share; max_basis = "asset"; }
   if(top_direction_share > max_share){ max_share = top_direction_share; max_basis = "direction"; }
   if(top_time_share > max_share){ max_share = top_time_share; max_basis = "time window"; }
   if(top_hold_share > max_share){ max_share = top_hold_share; max_basis = "holding time"; }

   string text = AC_L1MapHeader("PORTFOLIO CONCENTRATION MAP");
   text += "Scope:                  selected closed history only\r\n";
   text += "Purpose:                show where sample exposure is clustered by count, not edge proof\r\n";
   text += "Selected Closed Rows:   " + IntegerToString(total_rows) + "\r\n";
   text += "Top Symbol Share:       " + top_symbol + " " + IntegerToString(top_symbol_rows) + " rows (" + AC_L1PercentText(top_symbol_share) + ") | Net " + AC_L1MoneyText(top_symbol_net) + "\r\n";
   text += "Top Asset Share:        " + top_asset + " " + IntegerToString(top_asset_rows) + " rows (" + AC_L1PercentText(top_asset_share) + ") | Net " + AC_L1MoneyText(top_asset_net) + "\r\n";
   text += "Top Direction Share:    " + top_direction + " " + IntegerToString(top_direction_rows) + " rows (" + AC_L1PercentText(top_direction_share) + ") | Net " + AC_L1MoneyText(top_direction_net) + "\r\n";
   text += "Top Time Window Share:  " + time_name[top_time_i] + " " + IntegerToString(time_rows[top_time_i]) + " rows (" + AC_L1PercentText(top_time_share) + ") | Net " + AC_L1MoneyText(time_net[top_time_i]) + "\r\n";
   text += "Top Hold Window Share:  " + hold_name[top_hold_i] + " " + IntegerToString(hold_rows[top_hold_i]) + " rows (" + AC_L1PercentText(top_hold_share) + ") | Net " + AC_L1MoneyText(hold_net[top_hold_i]) + "\r\n";
   text += "Concentration Peak:     " + max_basis + " " + AC_L1PercentText(max_share) + " - " + AC_L1ConcentrationLevel(max_share) + "\r\n";
   text += "Trade Permission:       FALSE\r\n";
   return text;
}

#endif