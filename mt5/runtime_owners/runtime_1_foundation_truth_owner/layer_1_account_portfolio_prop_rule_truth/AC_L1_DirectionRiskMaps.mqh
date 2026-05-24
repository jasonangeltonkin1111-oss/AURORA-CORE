#ifndef AC_L1_DIRECTION_RISK_MAPS_MQH
#define AC_L1_DIRECTION_RISK_MAPS_MQH

string AC_L1DirectionRiskLine(const string side,
                              const int rows,
                              const int wins,
                              const int losses,
                              const double net,
                              const double risk,
                              const double net_r,
                              const double best_r,
                              const double worst_r,
                              const int unit_breaches,
                              const int hard_breaches,
                              const int extreme_breaches)
{
   double win_pct = (rows > 0 ? ((double)wins * 100.0) / rows : 0.0);
   double net_over_risk = (risk > 0.0 ? net / risk : 0.0);
   double avg_r = (rows > 0 ? net_r / rows : 0.0);
   return AC_L1PadRight(side, 8)
      + AC_L1PadLeft(IntegerToString(rows), 6)
      + AC_L1PadLeft(AC_L1PercentText(win_pct), 9)
      + AC_L1PadLeft(AC_L1MoneyText(net), 11)
      + AC_L1PadLeft(AC_L1MoneyText(risk), 11)
      + AC_L1PadLeft(DoubleToString(net_over_risk, 2), 10)
      + AC_L1PadLeft(DoubleToString(net_r, 2), 10)
      + AC_L1PadLeft(DoubleToString(avg_r, 2), 9)
      + AC_L1PadLeft(DoubleToString(best_r, 2), 9)
      + AC_L1PadLeft(DoubleToString(worst_r, 2), 9)
      + AC_L1PadLeft(IntegerToString(unit_breaches), 7)
      + AC_L1PadLeft(IntegerToString(hard_breaches), 7)
      + AC_L1PadLeft(IntegerToString(extreme_breaches), 8)
      + "\r\n";
}

string AC_L1DirectionRiskMap()
{
   int rows[2];
   int wins[2];
   int losses[2];
   double net[2];
   double risk[2];
   double net_r[2];
   double best_r[2];
   double worst_r[2];
   int unit_breaches[2];
   int hard_breaches[2];
   int extreme_breaches[2];

   for(int i = 0; i < 2; i++)
   {
      rows[i] = 0;
      wins[i] = 0;
      losses[i] = 0;
      net[i] = 0.0;
      risk[i] = 0.0;
      net_r[i] = 0.0;
      best_r[i] = -999999.0;
      worst_r[i] = 999999.0;
      unit_breaches[i] = 0;
      hard_breaches[i] = 0;
      extreme_breaches[i] = 0;
   }

   int total_rows = ArraySize(AC_L1_CLOSED);
   int risk_rows = 0;
   int invalid_side_rows = 0;
   double unit_risk_money = AC_L1_EQUITY * 0.001;
   double hard_risk_money = AC_L1_EQUITY * 0.002;
   double extreme_risk_money = AC_L1_EQUITY * 0.005;

   for(int r = 0; r < total_rows; r++)
   {
      int side_index = -1;
      if(AC_L1_CLOSED[r].side == "buy") side_index = 0;
      else if(AC_L1_CLOSED[r].side == "sell") side_index = 1;
      else
      {
         invalid_side_rows++;
         continue;
      }

      double row_risk = 0.0;
      if(!AC_L1EstimateClosedInitialRiskMoney(AC_L1_CLOSED[r], row_risk))
         continue;

      double row_r = AC_L1ClosedTradeRMultiple(AC_L1_CLOSED[r], row_risk);
      rows[side_index]++;
      risk_rows++;
      net[side_index] += AC_L1_CLOSED[r].net_result;
      risk[side_index] += row_risk;
      net_r[side_index] += row_r;
      if(AC_L1_CLOSED[r].net_result > 0.0) wins[side_index]++;
      if(AC_L1_CLOSED[r].net_result < 0.0) losses[side_index]++;
      if(row_r > best_r[side_index]) best_r[side_index] = row_r;
      if(row_r < worst_r[side_index]) worst_r[side_index] = row_r;
      if(row_risk > unit_risk_money) unit_breaches[side_index]++;
      if(row_risk > hard_risk_money) hard_breaches[side_index]++;
      if(row_risk > extreme_risk_money) extreme_breaches[side_index]++;
   }

   double buy_net_over_risk = (risk[0] > 0.0 ? net[0] / risk[0] : 0.0);
   double sell_net_over_risk = (risk[1] > 0.0 ? net[1] / risk[1] : 0.0);
   string weaker_side = "none";
   if(rows[0] > 0 || rows[1] > 0)
      weaker_side = (buy_net_over_risk <= sell_net_over_risk ? "buy" : "sell");

   string text = AC_L1MapHeader("DIRECTION RISK MAP");
   text += "Scope:                  selected closed rows with estimated money-risk only\r\n";
   text += "Risk Source:            OrderCalcProfit entry-to-SL estimate from Layer 1 money-risk helper\r\n";
   text += "Policy Basis:           Jason numeric policy: 0.10% unit, 0.20% hard, 0.50% extreme\r\n";
   text += "Selected Closed Rows:   " + IntegerToString(total_rows) + "\r\n";
   text += "Risk Eligible Rows:     " + IntegerToString(risk_rows) + " / " + IntegerToString(total_rows) + "\r\n";
   text += "Invalid Side Rows:      " + IntegerToString(invalid_side_rows) + "\r\n";
   text += "Weaker Net/Risk Side:   " + weaker_side + "\r\n";
   text += AC_L1PadRight("Side", 8)
      + AC_L1PadLeft("Rows", 6)
      + AC_L1PadLeft("Win%", 9)
      + AC_L1PadLeft("Net", 11)
      + AC_L1PadLeft("Risk", 11)
      + AC_L1PadLeft("Net/Risk", 10)
      + AC_L1PadLeft("Net R", 10)
      + AC_L1PadLeft("Avg R", 9)
      + AC_L1PadLeft("Best R", 9)
      + AC_L1PadLeft("Worst R", 9)
      + AC_L1PadLeft("Unit", 7)
      + AC_L1PadLeft("Hard", 7)
      + AC_L1PadLeft("Extreme", 8)
      + "\r\n";

   double buy_best = (rows[0] > 0 ? best_r[0] : 0.0);
   double buy_worst = (rows[0] > 0 ? worst_r[0] : 0.0);
   double sell_best = (rows[1] > 0 ? best_r[1] : 0.0);
   double sell_worst = (rows[1] > 0 ? worst_r[1] : 0.0);
   text += AC_L1DirectionRiskLine("buy", rows[0], wins[0], losses[0], net[0], risk[0], net_r[0], buy_best, buy_worst, unit_breaches[0], hard_breaches[0], extreme_breaches[0]);
   text += AC_L1DirectionRiskLine("sell", rows[1], wins[1], losses[1], net[1], risk[1], net_r[1], sell_best, sell_worst, unit_breaches[1], hard_breaches[1], extreme_breaches[1]);
   text += "Trade Permission:       FALSE\r\n";
   return text;
}

#endif