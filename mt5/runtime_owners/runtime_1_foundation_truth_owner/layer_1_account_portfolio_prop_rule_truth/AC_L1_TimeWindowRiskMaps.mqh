#ifndef AC_L1_TIME_WINDOW_RISK_MAPS_MQH
#define AC_L1_TIME_WINDOW_RISK_MAPS_MQH

string AC_L1TimeWindowRiskLine(const string window,
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
   return AC_L1PadRight(window, 9)
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

string AC_L1TimeWindowRiskMapV2()
{
   int rows[5];
   int wins[5];
   int losses[5];
   double net[5];
   double risk[5];
   double net_r[5];
   double best_r[5];
   double worst_r[5];
   int unit_breaches[5];
   int hard_breaches[5];
   int extreme_breaches[5];

   for(int i = 0; i < 5; i++)
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
   int time_unavailable_rows = 0;
   double unit_risk_money = AC_L1_EQUITY * 0.001;
   double hard_risk_money = AC_L1_EQUITY * 0.002;
   double extreme_risk_money = AC_L1_EQUITY * 0.005;

   for(int r = 0; r < total_rows; r++)
   {
      int idx = AC_L1TimeWindowIndex(AC_L1_CLOSED[r].close_time);
      if(idx < 0 || idx > 4)
      {
         time_unavailable_rows++;
         continue;
      }

      double row_risk = 0.0;
      if(!AC_L1EstimateClosedInitialRiskMoney(AC_L1_CLOSED[r], row_risk))
         continue;

      double row_r = AC_L1ClosedTradeRMultiple(AC_L1_CLOSED[r], row_risk);
      rows[idx]++;
      risk_rows++;
      net[idx] += AC_L1_CLOSED[r].net_result;
      risk[idx] += row_risk;
      net_r[idx] += row_r;
      if(AC_L1_CLOSED[r].net_result > 0.0) wins[idx]++;
      if(AC_L1_CLOSED[r].net_result < 0.0) losses[idx]++;
      if(row_r > best_r[idx]) best_r[idx] = row_r;
      if(row_r < worst_r[idx]) worst_r[idx] = row_r;
      if(row_risk > unit_risk_money) unit_breaches[idx]++;
      if(row_risk > hard_risk_money) hard_breaches[idx]++;
      if(row_risk > extreme_risk_money) extreme_breaches[idx]++;
   }

   string weakest_window = "none";
   double weakest_net_over_risk = 0.0;
   bool first_weak = true;
   for(int i = 0; i < 5; i++)
   {
      if(rows[i] <= 0) continue;
      double nor = (risk[i] > 0.0 ? net[i] / risk[i] : 0.0);
      if(first_weak || nor < weakest_net_over_risk)
      {
         first_weak = false;
         weakest_net_over_risk = nor;
         weakest_window = AC_L1TimeWindowName(i);
      }
   }

   string text = AC_L1MapHeader("TIME WINDOW RISK MAP V2 - BROKER SERVER TIME");
   text += "section_id:             L1_TIME_WINDOW_RISK_V2\r\n";
   text += "Scope:                  selected closed rows with estimated money-risk only\r\n";
   text += "Risk Source:            OrderCalcProfit entry-to-SL estimate from Layer 1 money-risk helper\r\n";
   text += "Time Basis:             broker server close time\r\n";
   text += "Policy Basis:           Jason numeric policy: 0.10% unit, 0.20% hard, 0.50% extreme\r\n";
   text += "Selected Closed Rows:   " + IntegerToString(total_rows) + "\r\n";
   text += "Risk Eligible Rows:     " + IntegerToString(risk_rows) + " / " + IntegerToString(total_rows) + "\r\n";
   text += "Time Unavailable Rows:  " + IntegerToString(time_unavailable_rows) + "\r\n";
   text += "Weakest Net/Risk Window: " + weakest_window + " " + DoubleToString(weakest_net_over_risk, 2) + "\r\n";
   text += AC_L1PadRight("Window", 9)
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

   for(int i = 0; i < 5; i++)
   {
      double br = (rows[i] > 0 ? best_r[i] : 0.0);
      double wr = (rows[i] > 0 ? worst_r[i] : 0.0);
      text += AC_L1TimeWindowRiskLine(AC_L1TimeWindowName(i), rows[i], wins[i], losses[i], net[i], risk[i], net_r[i], br, wr, unit_breaches[i], hard_breaches[i], extreme_breaches[i]);
   }

   text += "Trade Permission:       FALSE\r\n";
   return text;
}

#endif