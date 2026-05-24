#ifndef AC_L1_CLUSTER_V2_MAPS_MQH
#define AC_L1_CLUSTER_V2_MAPS_MQH

string AC_L1ClusterMinuteKey(const AC_L1ClosedTradeRow &row)
{
   datetime minute_time = row.entry_time - (row.entry_time % 60);
   return row.symbol + "|" + TimeToString(minute_time, TIME_DATE | TIME_MINUTES);
}

string AC_L1ClusterSameSymbolMinuteKey(const AC_L1ClosedTradeRow &row)
{
   datetime minute_time = row.entry_time - (row.entry_time % 60);
   return row.symbol + "|" + TimeToString(minute_time, TIME_DATE | TIME_MINUTES);
}

string AC_L1ClusterSameSymbolSideMinuteKey(const AC_L1ClosedTradeRow &row)
{
   datetime minute_time = row.entry_time - (row.entry_time % 60);
   return row.symbol + "|" + row.side + "|" + TimeToString(minute_time, TIME_DATE | TIME_MINUTES);
}

void AC_L1ClusterGroupStats(const string key,
                            const int mode,
                            int &rows,
                            int &buy_rows,
                            int &sell_rows,
                            double &net,
                            double &risk,
                            double &net_r)
{
   rows = 0;
   buy_rows = 0;
   sell_rows = 0;
   net = 0.0;
   risk = 0.0;
   net_r = 0.0;
   for(int i = 0; i < ArraySize(AC_L1_CLOSED); i++)
   {
      string row_key = "";
      if(mode == 1) row_key = AC_L1ClusterSameSymbolSideMinuteKey(AC_L1_CLOSED[i]);
      else row_key = AC_L1ClusterSameSymbolMinuteKey(AC_L1_CLOSED[i]);
      if(row_key != key) continue;
      rows++;
      if(AC_L1_CLOSED[i].side == "buy") buy_rows++;
      if(AC_L1_CLOSED[i].side == "sell") sell_rows++;
      net += AC_L1_CLOSED[i].net_result;
      double row_risk = 0.0;
      if(AC_L1EstimateClosedInitialRiskMoney(AC_L1_CLOSED[i], row_risk))
      {
         risk += row_risk;
         net_r += AC_L1ClosedTradeRMultiple(AC_L1_CLOSED[i], row_risk);
      }
   }
}

string AC_L1ClusterV2Line(const string label,
                          const int groups,
                          const int rows,
                          const double net,
                          const double risk,
                          const double net_r)
{
   double net_over_risk = (risk > 0.0 ? net / risk : 0.0);
   return AC_L1PadRight(label, 22)
      + AC_L1PadLeft(IntegerToString(groups), 8)
      + AC_L1PadLeft(IntegerToString(rows), 8)
      + AC_L1PadLeft(AC_L1MoneyText(net), 12)
      + AC_L1PadLeft(AC_L1MoneyText(risk), 12)
      + AC_L1PadLeft(DoubleToString(net_r, 2), 10)
      + AC_L1PadLeft(DoubleToString(net_over_risk, 2), 10)
      + "\r\n";
}

void AC_L1ClusterModeSummary(const int mode,
                             int &groups,
                             int &rows,
                             double &net,
                             double &risk,
                             double &net_r,
                             string &worst_key,
                             int &worst_rows,
                             double &worst_net,
                             double &worst_risk,
                             double &worst_net_r,
                             string &best_key,
                             int &best_rows,
                             double &best_net,
                             double &best_risk,
                             double &best_net_r)
{
   groups = 0;
   rows = 0;
   net = 0.0;
   risk = 0.0;
   net_r = 0.0;
   worst_key = "none";
   worst_rows = 0;
   worst_net = 0.0;
   worst_risk = 0.0;
   worst_net_r = 0.0;
   best_key = "none";
   best_rows = 0;
   best_net = 0.0;
   best_risk = 0.0;
   best_net_r = 0.0;

   string seen = "|";
   bool first_group = true;
   for(int i = 0; i < ArraySize(AC_L1_CLOSED); i++)
   {
      string key = (mode == 1 ? AC_L1ClusterSameSymbolSideMinuteKey(AC_L1_CLOSED[i]) : AC_L1ClusterSameSymbolMinuteKey(AC_L1_CLOSED[i]));
      if(StringFind(seen, "|" + key + "|") >= 0) continue;
      seen += key + "|";

      int group_rows = 0;
      int buy_rows = 0;
      int sell_rows = 0;
      double group_net = 0.0;
      double group_risk = 0.0;
      double group_net_r = 0.0;
      AC_L1ClusterGroupStats(key, mode, group_rows, buy_rows, sell_rows, group_net, group_risk, group_net_r);
      if(group_rows <= 1) continue;

      groups++;
      rows += group_rows;
      net += group_net;
      risk += group_risk;
      net_r += group_net_r;

      if(first_group || group_net < worst_net)
      {
         worst_key = key;
         worst_rows = group_rows;
         worst_net = group_net;
         worst_risk = group_risk;
         worst_net_r = group_net_r;
      }
      if(first_group || group_net > best_net)
      {
         best_key = key;
         best_rows = group_rows;
         best_net = group_net;
         best_risk = group_risk;
         best_net_r = group_net_r;
      }
      first_group = false;
   }
}

string AC_L1TradeClusterV2Map()
{
   int same_side_groups, same_side_rows;
   double same_side_net, same_side_risk, same_side_net_r;
   string same_side_worst_key, same_side_best_key;
   int same_side_worst_rows, same_side_best_rows;
   double same_side_worst_net, same_side_worst_risk, same_side_worst_r;
   double same_side_best_net, same_side_best_risk, same_side_best_r;

   int same_symbol_groups, same_symbol_rows;
   double same_symbol_net, same_symbol_risk, same_symbol_net_r;
   string same_symbol_worst_key, same_symbol_best_key;
   int same_symbol_worst_rows, same_symbol_best_rows;
   double same_symbol_worst_net, same_symbol_worst_risk, same_symbol_worst_r;
   double same_symbol_best_net, same_symbol_best_risk, same_symbol_best_r;

   AC_L1ClusterModeSummary(1, same_side_groups, same_side_rows, same_side_net, same_side_risk, same_side_net_r,
                           same_side_worst_key, same_side_worst_rows, same_side_worst_net, same_side_worst_risk, same_side_worst_r,
                           same_side_best_key, same_side_best_rows, same_side_best_net, same_side_best_risk, same_side_best_r);
   AC_L1ClusterModeSummary(2, same_symbol_groups, same_symbol_rows, same_symbol_net, same_symbol_risk, same_symbol_net_r,
                           same_symbol_worst_key, same_symbol_worst_rows, same_symbol_worst_net, same_symbol_worst_risk, same_symbol_worst_r,
                           same_symbol_best_key, same_symbol_best_rows, same_symbol_best_net, same_symbol_best_risk, same_symbol_best_r);

   double total_loss_abs = 0.0;
   for(int i = 0; i < ArraySize(AC_L1_CLOSED); i++)
      if(AC_L1_CLOSED[i].net_result < 0.0) total_loss_abs += MathAbs(AC_L1_CLOSED[i].net_result);
   double cluster_loss_share = (total_loss_abs > 0.0 && same_symbol_net < 0.0 ? (MathAbs(same_symbol_net) / total_loss_abs) * 100.0 : 0.0);

   string text = AC_L1MapHeader("TRADE CLUSTER MAP V2");
   text += "section_id:             L1_TRADE_CLUSTER_V2\r\n";
   text += "Scope:                  selected closed history; minute-level cluster diagnostics\r\n";
   text += "Risk Source:            estimated money risk when available; cluster map is diagnostic only\r\n";
   text += AC_L1PadRight("Cluster Type", 22)
      + AC_L1PadLeft("Groups", 8)
      + AC_L1PadLeft("Rows", 8)
      + AC_L1PadLeft("Net", 12)
      + AC_L1PadLeft("Risk", 12)
      + AC_L1PadLeft("Net R", 10)
      + AC_L1PadLeft("Net/Risk", 10)
      + "\r\n";
   text += AC_L1ClusterV2Line("Same symbol+side", same_side_groups, same_side_rows, same_side_net, same_side_risk, same_side_net_r);
   text += AC_L1ClusterV2Line("Same symbol minute", same_symbol_groups, same_symbol_rows, same_symbol_net, same_symbol_risk, same_symbol_net_r);
   text += "Worst Same-Side Cluster: " + same_side_worst_key + " | rows " + IntegerToString(same_side_worst_rows) + " | net " + AC_L1MoneyText(same_side_worst_net) + " | risk " + AC_L1MoneyText(same_side_worst_risk) + " | R " + DoubleToString(same_side_worst_r, 2) + "\r\n";
   text += "Best Same-Side Cluster:  " + same_side_best_key + " | rows " + IntegerToString(same_side_best_rows) + " | net " + AC_L1MoneyText(same_side_best_net) + " | risk " + AC_L1MoneyText(same_side_best_risk) + " | R " + DoubleToString(same_side_best_r, 2) + "\r\n";
   text += "Worst Symbol-Minute:    " + same_symbol_worst_key + " | rows " + IntegerToString(same_symbol_worst_rows) + " | net " + AC_L1MoneyText(same_symbol_worst_net) + " | risk " + AC_L1MoneyText(same_symbol_worst_risk) + " | R " + DoubleToString(same_symbol_worst_r, 2) + "\r\n";
   text += "Best Symbol-Minute:     " + same_symbol_best_key + " | rows " + IntegerToString(same_symbol_best_rows) + " | net " + AC_L1MoneyText(same_symbol_best_net) + " | risk " + AC_L1MoneyText(same_symbol_best_risk) + " | R " + DoubleToString(same_symbol_best_r, 2) + "\r\n";
   text += "Cluster Loss Share:     " + AC_L1PercentText(cluster_loss_share) + " of selected gross loss, using same-symbol-minute net when negative\r\n";
   text += "Trade Permission:       FALSE\r\n";
   return text;
}

#endif