#ifndef AC_L1_MAPS_MQH
#define AC_L1_MAPS_MQH

string AC_L1MapHeader(const string title)
{
   return "\r\n" + title + "\r\n----------------------------------------\r\n";
}

int AC_L1CloseHour(const datetime value)
{
   if(value <= 0) return -1;
   MqlDateTime parts;
   TimeToStruct(value, parts);
   return parts.hour;
}

int AC_L1TimeWindowIndex(const datetime value)
{
   int hour = AC_L1CloseHour(value);
   if(hour < 0) return -1;
   if(hour < 6) return 0;
   if(hour < 10) return 1;
   if(hour < 14) return 2;
   if(hour < 18) return 3;
   return 4;
}

string AC_L1TimeWindowName(const int index)
{
   if(index == 0) return "00-06";
   if(index == 1) return "06-10";
   if(index == 2) return "10-14";
   if(index == 3) return "14-18";
   if(index == 4) return "18-24";
   return "unknown";
}

int AC_L1HoldBucketIndex(const AC_L1ClosedTradeRow &row)
{
   if(row.entry_time <= 0 || row.close_time <= row.entry_time) return 0;
   long seconds = (long)(row.close_time - row.entry_time);
   if(seconds <= 300) return 0;
   if(seconds <= 1800) return 1;
   if(seconds <= 7200) return 2;
   if(seconds <= 86400) return 3;
   return 4;
}

string AC_L1HoldBucketName(const int index)
{
   if(index == 0) return "0-5m";
   if(index == 1) return "5-30m";
   if(index == 2) return "30m-2h";
   if(index == 3) return "2h-1d";
   if(index == 4) return "1d+";
   return "unknown";
}

string AC_L1MapStatsLine(const string name,
                         const int trades,
                         const int wins,
                         const double net)
{
   double avg = (trades > 0 ? net / trades : 0.0);
   double win_pct = (trades > 0 ? ((double)wins * 100.0) / trades : 0.0);
   return AC_L1PadRight(name, 12)
      + AC_L1PadLeft(IntegerToString(trades), 7)
      + AC_L1PadLeft(AC_L1MoneyText(net), 11)
      + AC_L1PadLeft(AC_L1MoneyText(avg), 10)
      + AC_L1PadLeft(AC_L1PercentText(win_pct), 9)
      + "\r\n";
}

string AC_L1CleanSymbolRoot(string symbol)
{
   int dot = StringFind(symbol, ".");
   if(dot > 0) symbol = StringSubstr(symbol, 0, dot);
   return symbol;
}

bool AC_L1IsKnownCurrency(const string value)
{
   return (value == "USD" || value == "EUR" || value == "GBP" || value == "JPY" ||
           value == "CHF" || value == "AUD" || value == "NZD" || value == "CAD" ||
           value == "SGD" || value == "ZAR");
}

bool AC_L1ForexPairParts(const string symbol, string &base_ccy, string &quote_ccy)
{
   string root = AC_L1CleanSymbolRoot(symbol);
   if(StringLen(root) < 6) return false;
   base_ccy = StringSubstr(root, 0, 3);
   quote_ccy = StringSubstr(root, 3, 3);
   return (AC_L1IsKnownCurrency(base_ccy) && AC_L1IsKnownCurrency(quote_ccy));
}

int AC_L1AssetClassIndex(const string symbol)
{
   string root = AC_L1CleanSymbolRoot(symbol);
   string base_ccy = "";
   string quote_ccy = "";
   if(AC_L1ForexPairParts(symbol, base_ccy, quote_ccy)) return 0;
   if(StringFind(root, "XAU") >= 0 || StringFind(root, "XAG") >= 0) return 1;
   if(StringFind(root, "OIL") >= 0 || StringFind(root, "WTI") >= 0 || StringFind(root, "BRENT") >= 0) return 2;
   if(StringFind(root, "BTC") >= 0 || StringFind(root, "ETH") >= 0 || StringFind(root, "XMR") >= 0 || StringFind(root, "LTC") >= 0 || StringFind(root, "XRP") >= 0) return 3;
   if(StringFind(root, "DJC") >= 0 || StringFind(root, "NAC") >= 0 || StringFind(root, "SPC") >= 0 || StringFind(root, "UKC") >= 0 || StringFind(root, "GEC") >= 0 || StringFind(root, "JPC") >= 0) return 4;
   return 5;
}

string AC_L1AssetClassName(const int index)
{
   if(index == 0) return "Forex";
   if(index == 1) return "Metals";
   if(index == 2) return "Energy";
   if(index == 3) return "Crypto";
   if(index == 4) return "Indices/CFD";
   return "Other";
}

int AC_L1CurrencyIndex(const string ccy)
{
   if(ccy == "USD") return 0;
   if(ccy == "EUR") return 1;
   if(ccy == "GBP") return 2;
   if(ccy == "JPY") return 3;
   if(ccy == "CHF") return 4;
   if(ccy == "AUD") return 5;
   if(ccy == "NZD") return 6;
   if(ccy == "CAD") return 7;
   if(ccy == "SGD") return 8;
   if(ccy == "ZAR") return 9;
   return -1;
}

string AC_L1CurrencyName(const int index)
{
   if(index == 0) return "USD";
   if(index == 1) return "EUR";
   if(index == 2) return "GBP";
   if(index == 3) return "JPY";
   if(index == 4) return "CHF";
   if(index == 5) return "AUD";
   if(index == 6) return "NZD";
   if(index == 7) return "CAD";
   if(index == 8) return "SGD";
   if(index == 9) return "ZAR";
   return "UNK";
}

string AC_L1RiskBudgetMap()
{
   double unit_risk = AC_L1_EQUITY * 0.001;
   double hard_risk = AC_L1_EQUITY * 0.002;
   double daily_budget = AC_L1_EQUITY * 0.01;
   double guard_budget = AC_L1_EQUITY * 0.03;
   double current_drawdown = (AC_L1_BALANCE > AC_L1_EQUITY ? AC_L1_BALANCE - AC_L1_EQUITY : 0.0);
   double largest_loss_usage = (hard_risk > 0.0 && AC_L1_LARGEST_LOSS < 0.0 ? (MathAbs(AC_L1_LARGEST_LOSS) / hard_risk) * 100.0 : 0.0);
   double worst_day_usage = (daily_budget > 0.0 && AC_L1_WORST_DAY_NET < 0.0 ? (MathAbs(AC_L1_WORST_DAY_NET) / daily_budget) * 100.0 : 0.0);

   string text = AC_L1MapHeader("JASON RISK BUDGET MAP");
   text += "Equity:                 " + AC_L1MoneyText(AC_L1_EQUITY) + "\r\n";
   text += "0.10% Unit Risk:        " + AC_L1MoneyText(unit_risk) + "\r\n";
   text += "0.20% Hard Trade Risk:  " + AC_L1MoneyText(hard_risk) + "\r\n";
   text += "1.00% Daily Budget:     " + AC_L1MoneyText(daily_budget) + "\r\n";
   text += "3.00% Drawdown Guard:   " + AC_L1MoneyText(guard_budget) + "\r\n";
   text += "Current Drawdown:       " + AC_L1MoneyText(current_drawdown) + "\r\n";
   text += "Largest Loss Usage:     " + AC_L1PercentText(largest_loss_usage) + " of 0.20% hard risk\r\n";
   text += "Worst Day Usage:        " + AC_L1PercentText(worst_day_usage) + " of 1.00% daily budget\r\n";
   text += "Policy Basis:           Jason numeric policy only; not broker or prop permission\r\n";
   return text;
}

string AC_L1AssetClassMap()
{
   int trades[6];
   int wins[6];
   double net[6];
   for(int r = 0; r < 6; r++) { trades[r] = 0; wins[r] = 0; net[r] = 0.0; }

   for(int i = 0; i < ArraySize(AC_L1_CLOSED); i++)
   {
      int idx = AC_L1AssetClassIndex(AC_L1_CLOSED[i].symbol);
      if(idx < 0 || idx > 5) idx = 5;
      trades[idx]++;
      if(AC_L1_CLOSED[i].net_result > 0.0) wins[idx]++;
      net[idx] += AC_L1_CLOSED[i].net_result;
   }

   string text = AC_L1MapHeader("ASSET CLASS MAP");
   text += AC_L1PadRight("Class", 12) + AC_L1PadLeft("Trades", 7) + AC_L1PadLeft("Net", 11) + AC_L1PadLeft("Avg", 10) + AC_L1PadLeft("Win%", 9) + "\r\n";
   for(int c = 0; c < 6; c++)
      text += AC_L1MapStatsLine(AC_L1AssetClassName(c), trades[c], wins[c], net[c]);
   text += "Classification Basis: symbol-name heuristic only; taxonomy-owner link pending\r\n";
   return text;
}

string AC_L1CurrencyExposureMap()
{
   int touches[10];
   int wins[10];
   double net[10];
   for(int r = 0; r < 10; r++) { touches[r] = 0; wins[r] = 0; net[r] = 0.0; }

   for(int i = 0; i < ArraySize(AC_L1_CLOSED); i++)
   {
      string base_ccy = "";
      string quote_ccy = "";
      if(!AC_L1ForexPairParts(AC_L1_CLOSED[i].symbol, base_ccy, quote_ccy)) continue;
      int b = AC_L1CurrencyIndex(base_ccy);
      int q = AC_L1CurrencyIndex(quote_ccy);
      double allocated = AC_L1_CLOSED[i].net_result * 0.5;
      bool win = (AC_L1_CLOSED[i].net_result > 0.0);
      if(b >= 0)
      {
         touches[b]++;
         if(win) wins[b]++;
         net[b] += allocated;
      }
      if(q >= 0)
      {
         touches[q]++;
         if(win) wins[q]++;
         net[q] += allocated;
      }
   }

   string text = AC_L1MapHeader("CURRENCY TOUCH MAP - FOREX ONLY");
   text += AC_L1PadRight("Currency", 12) + AC_L1PadLeft("Touches", 7) + AC_L1PadLeft("Net50", 11) + AC_L1PadLeft("Avg", 10) + AC_L1PadLeft("Win%", 9) + "\r\n";
   for(int c = 0; c < 10; c++)
      text += AC_L1MapStatsLine(AC_L1CurrencyName(c), touches[c], wins[c], net[c]);
   text += "Net Basis: forex-pair rows only, 50/50 net allocation to base and quote currency\r\n";
   return text;
}

string AC_L1SymbolPainStrengthMap(const int limit)
{
   string text = AC_L1MapHeader("SYMBOL PAIN / STRENGTH MAP");
   text += "Worst Symbols\r\n";
   text += AC_L1PadRight("Symbol", 14) + AC_L1PadLeft("Trades", 7) + AC_L1PadLeft("Net", 11) + AC_L1PadLeft("Avg", 10) + AC_L1PadLeft("Win%", 9) + "\r\n";

   string used = "|";
   for(int rank = 0; rank < limit; rank++)
   {
      int best_index = -1;
      double best_value = 0.0;
      for(int i = 0; i < ArraySize(AC_L1_SYMBOL_STATS); i++)
      {
         if(AC_L1_SYMBOL_STATS[i].closed_count <= 0) continue;
         string key = "|" + AC_L1_SYMBOL_STATS[i].symbol + "|";
         if(StringFind(used, key) >= 0) continue;
         if(best_index < 0 || AC_L1_SYMBOL_STATS[i].net_result < best_value)
         {
            best_index = i;
            best_value = AC_L1_SYMBOL_STATS[i].net_result;
         }
      }
      if(best_index < 0) break;
      int trades = AC_L1_SYMBOL_STATS[best_index].closed_count;
      int wins = AC_L1_SYMBOL_STATS[best_index].win_count;
      text += AC_L1MapStatsLine(AC_L1_SYMBOL_STATS[best_index].symbol, trades, wins, AC_L1_SYMBOL_STATS[best_index].net_result);
      used += AC_L1_SYMBOL_STATS[best_index].symbol + "|";
   }

   text += "\r\nBest Symbols\r\n";
   text += AC_L1PadRight("Symbol", 14) + AC_L1PadLeft("Trades", 7) + AC_L1PadLeft("Net", 11) + AC_L1PadLeft("Avg", 10) + AC_L1PadLeft("Win%", 9) + "\r\n";
   used = "|";
   for(int rank2 = 0; rank2 < limit; rank2++)
   {
      int best_index2 = -1;
      double best_value2 = 0.0;
      for(int j = 0; j < ArraySize(AC_L1_SYMBOL_STATS); j++)
      {
         if(AC_L1_SYMBOL_STATS[j].closed_count <= 0) continue;
         string key2 = "|" + AC_L1_SYMBOL_STATS[j].symbol + "|";
         if(StringFind(used, key2) >= 0) continue;
         if(best_index2 < 0 || AC_L1_SYMBOL_STATS[j].net_result > best_value2)
         {
            best_index2 = j;
            best_value2 = AC_L1_SYMBOL_STATS[j].net_result;
         }
      }
      if(best_index2 < 0) break;
      int trades2 = AC_L1_SYMBOL_STATS[best_index2].closed_count;
      int wins2 = AC_L1_SYMBOL_STATS[best_index2].win_count;
      text += AC_L1MapStatsLine(AC_L1_SYMBOL_STATS[best_index2].symbol, trades2, wins2, AC_L1_SYMBOL_STATS[best_index2].net_result);
      used += AC_L1_SYMBOL_STATS[best_index2].symbol + "|";
   }
   return text;
}

string AC_L1TimeWindowMap()
{
   int trades[5];
   int wins[5];
   double net[5];
   for(int r = 0; r < 5; r++) { trades[r] = 0; wins[r] = 0; net[r] = 0.0; }

   for(int i = 0; i < ArraySize(AC_L1_CLOSED); i++)
   {
      int idx = AC_L1TimeWindowIndex(AC_L1_CLOSED[i].close_time);
      if(idx < 0 || idx > 4) continue;
      trades[idx]++;
      if(AC_L1_CLOSED[i].net_result > 0.0) wins[idx]++;
      net[idx] += AC_L1_CLOSED[i].net_result;
   }

   string text = AC_L1MapHeader("TIME WINDOW MAP - BROKER SERVER TIME");
   text += AC_L1PadRight("Window", 12) + AC_L1PadLeft("Trades", 7) + AC_L1PadLeft("Net", 11) + AC_L1PadLeft("Avg", 10) + AC_L1PadLeft("Win%", 9) + "\r\n";
   for(int w = 0; w < 5; w++)
      text += AC_L1MapStatsLine(AC_L1TimeWindowName(w), trades[w], wins[w], net[w]);
   text += "Time Basis: broker server close time\r\n";
   return text;
}

string AC_L1HoldingTimeMap()
{
   int trades[5];
   int wins[5];
   double net[5];
   for(int r = 0; r < 5; r++) { trades[r] = 0; wins[r] = 0; net[r] = 0.0; }

   for(int i = 0; i < ArraySize(AC_L1_CLOSED); i++)
   {
      int idx = AC_L1HoldBucketIndex(AC_L1_CLOSED[i]);
      if(idx < 0 || idx > 4) continue;
      trades[idx]++;
      if(AC_L1_CLOSED[i].net_result > 0.0) wins[idx]++;
      net[idx] += AC_L1_CLOSED[i].net_result;
   }

   string text = AC_L1MapHeader("HOLDING TIME MAP");
   text += AC_L1PadRight("Duration", 12) + AC_L1PadLeft("Trades", 7) + AC_L1PadLeft("Net", 11) + AC_L1PadLeft("Avg", 10) + AC_L1PadLeft("Win%", 9) + "\r\n";
   for(int h = 0; h < 5; h++)
      text += AC_L1MapStatsLine(AC_L1HoldBucketName(h), trades[h], wins[h], net[h]);
   return text;
}

string AC_L1ClusterKey(const AC_L1ClosedTradeRow &row)
{
   return row.symbol + "|" + row.side + "|" + TimeToString(row.entry_time, TIME_DATE | TIME_SECONDS) + "|" + TimeToString(row.close_time, TIME_DATE | TIME_SECONDS);
}

string AC_L1ClusterMap()
{
   int raw_rows = ArraySize(AC_L1_CLOSED);
   int cluster_groups = 0;
   int cluster_rows = 0;
   int largest_group_rows = 0;
   string largest_group_symbol = "none";
   double cluster_net = 0.0;
   string seen = "|";

   for(int i = 0; i < raw_rows; i++)
   {
      string key = AC_L1ClusterKey(AC_L1_CLOSED[i]);
      string mark = "|" + key + "|";
      if(StringFind(seen, mark) >= 0) continue;
      seen += key + "|";

      int group_rows = 0;
      double group_net = 0.0;
      for(int j = 0; j < raw_rows; j++)
      {
         if(AC_L1ClusterKey(AC_L1_CLOSED[j]) != key) continue;
         group_rows++;
         group_net += AC_L1_CLOSED[j].net_result;
      }
      if(group_rows > 1)
      {
         cluster_groups++;
         cluster_rows += group_rows;
         cluster_net += group_net;
         if(group_rows > largest_group_rows)
         {
            largest_group_rows = group_rows;
            largest_group_symbol = AC_L1_CLOSED[i].symbol;
         }
      }
   }

   int estimated_decision_units = raw_rows - cluster_rows + cluster_groups;
   string text = AC_L1MapHeader("CLUSTER MAP");
   text += "Raw Closed Rows:          " + IntegerToString(raw_rows) + "\r\n";
   text += "Estimated Decision Units: " + IntegerToString(estimated_decision_units) + "\r\n";
   text += "Cluster Groups:           " + IntegerToString(cluster_groups) + "\r\n";
   text += "Cluster Rows:             " + IntegerToString(cluster_rows) + "\r\n";
   text += "Cluster Net:              " + AC_L1MoneyText(cluster_net) + "\r\n";
   text += "Largest Cluster:          " + largest_group_symbol + " / " + IntegerToString(largest_group_rows) + " rows\r\n";
   text += "Cluster Basis:            same symbol + side + entry time + close time\r\n";
   return text;
}

string AC_L1PortfolioMapSummary()
{
   string text = "\r\nLAYER 1 - PORTFOLIO MAP SUMMARY\r\n";
   text += "----------------------------------------\r\n";
   text += "Risk Unit 0.10%:       " + AC_L1MoneyText(AC_L1_EQUITY * 0.001) + "\r\n";
   text += "Hard Risk 0.20%:       " + AC_L1MoneyText(AC_L1_EQUITY * 0.002) + "\r\n";
   text += "Worst Symbol:          " + AC_L1_WORST_SYMBOL + " " + AC_L1MoneyText(AC_L1_WORST_SYMBOL_NET) + "\r\n";
   text += "Best Symbol:           " + AC_L1_BEST_SYMBOL + " " + AC_L1MoneyText(AC_L1_BEST_SYMBOL_NET) + "\r\n";
   text += "Worst Day:             " + AC_L1_WORST_DAY + " " + AC_L1MoneyText(AC_L1_WORST_DAY_NET) + "\r\n";
   text += "Closed Rows:           " + IntegerToString(ArraySize(AC_L1_CLOSED)) + "\r\n";
   text += "Map Mode:              numeric_read_only_no_trade_permission\r\n";
   return text;
}

string AC_L1AccountPortfolioMapsFull()
{
   string text = "";
   text += AC_L1RiskBudgetMap();
   text += AC_L1AssetClassMap();
   text += AC_L1CurrencyExposureMap();
   text += AC_L1SymbolPainStrengthMap(5);
   text += AC_L1TimeWindowMap();
   text += AC_L1HoldingTimeMap();
   text += AC_L1ClusterMap();
   return text;
}

#endif