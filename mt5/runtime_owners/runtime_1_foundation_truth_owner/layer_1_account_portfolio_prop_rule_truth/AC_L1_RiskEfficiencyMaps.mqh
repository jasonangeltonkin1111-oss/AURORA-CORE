#ifndef AC_L1_RISK_EFFICIENCY_MAPS_MQH
#define AC_L1_RISK_EFFICIENCY_MAPS_MQH

string AC_L1RiskBreachLabel(const double risk_pct)
{
   if(risk_pct > 0.50) return "extreme";
   if(risk_pct > 0.20) return "hard risk breach";
   if(risk_pct > 0.10) return "unit risk breach";
   return "inside unit risk";
}

string AC_L1RiskBreachSymbolLine(const string symbol,
                                 const int rows,
                                 const double net_money,
                                 const double total_risk,
                                 const int unit_breaches,
                                 const int hard_breaches,
                                 const int extreme_breaches)
{
   double net_over_risk = (total_risk > 0.0 ? net_money / total_risk : 0.0);
   return AC_L1PadRight(symbol, 14)
      + AC_L1PadLeft(IntegerToString(rows), 6)
      + AC_L1PadLeft(AC_L1MoneyText(net_money), 11)
      + AC_L1PadLeft(AC_L1MoneyText(total_risk), 11)
      + AC_L1PadLeft(DoubleToString(net_over_risk, 2), 10)
      + AC_L1PadLeft(IntegerToString(unit_breaches), 8)
      + AC_L1PadLeft(IntegerToString(hard_breaches), 8)
      + AC_L1PadLeft(IntegerToString(extreme_breaches), 8)
      + "\r\n";
}

string AC_L1RiskEfficiencyMap()
{
   int rows_total = ArraySize(AC_L1_CLOSED);
   int eligible_rows = 0;
   int blocked_rows = 0;
   int unit_breaches = 0;
   int hard_breaches = 0;
   int extreme_breaches = 0;
   int loss_rows_over_hard_loss = 0;
   double total_est_risk = 0.0;
   double net_money = 0.0;
   double gross_win_money = 0.0;
   double gross_loss_money = 0.0;
   double largest_risk = 0.0;
   double largest_risk_pct = 0.0;
   string largest_risk_symbol = "none";
   double largest_loss = 0.0;
   string largest_loss_symbol = "none";

   double unit_risk_money = AC_L1_EQUITY * 0.001;
   double hard_risk_money = AC_L1_EQUITY * 0.002;
   double extreme_risk_money = AC_L1_EQUITY * 0.005;

   for(int i = 0; i < rows_total; i++)
   {
      double risk = 0.0;
      if(!AC_L1EstimateClosedInitialRiskMoney(AC_L1_CLOSED[i], risk))
      {
         blocked_rows++;
         continue;
      }

      eligible_rows++;
      total_est_risk += risk;
      net_money += AC_L1_CLOSED[i].net_result;
      if(AC_L1_CLOSED[i].net_result > 0.0) gross_win_money += AC_L1_CLOSED[i].net_result;
      if(AC_L1_CLOSED[i].net_result < 0.0) gross_loss_money += AC_L1_CLOSED[i].net_result;

      double risk_pct = (AC_L1_EQUITY > 0.0 ? (risk / AC_L1_EQUITY) * 100.0 : 0.0);
      if(risk > unit_risk_money) unit_breaches++;
      if(risk > hard_risk_money) hard_breaches++;
      if(risk > extreme_risk_money) extreme_breaches++;
      if(hard_risk_money > 0.0 && AC_L1_CLOSED[i].net_result < 0.0 && MathAbs(AC_L1_CLOSED[i].net_result) > hard_risk_money) loss_rows_over_hard_loss++;

      if(risk > largest_risk)
      {
         largest_risk = risk;
         largest_risk_pct = risk_pct;
         largest_risk_symbol = AC_L1_CLOSED[i].symbol;
      }
      if(AC_L1_CLOSED[i].net_result < largest_loss)
      {
         largest_loss = AC_L1_CLOSED[i].net_result;
         largest_loss_symbol = AC_L1_CLOSED[i].symbol;
      }
   }

   double net_over_risk = (total_est_risk > 0.0 ? net_money / total_est_risk : 0.0);
   double avg_risk = (eligible_rows > 0 ? total_est_risk / eligible_rows : 0.0);
   double total_risk_pct = (AC_L1_EQUITY > 0.0 ? (total_est_risk / AC_L1_EQUITY) * 100.0 : 0.0);
   double avg_risk_pct = (AC_L1_EQUITY > 0.0 ? (avg_risk / AC_L1_EQUITY) * 100.0 : 0.0);
   double largest_loss_pct = (AC_L1_EQUITY > 0.0 ? (MathAbs(largest_loss) / AC_L1_EQUITY) * 100.0 : 0.0);
   double risk_ready_pct = (rows_total > 0 ? ((double)eligible_rows * 100.0) / rows_total : 0.0);

   string text = AC_L1MapHeader("RISK EFFICIENCY MAP");
   text += "Purpose:                measure return versus estimated initial SL risk\r\n";
   text += "Risk Source:            OrderCalcProfit entry-to-SL estimate from Layer 1 money-risk helper\r\n";
   text += "Policy Basis:           Jason numeric policy: 0.10% unit, 0.20% hard, 0.50% extreme\r\n";
   text += "Selected Closed Rows:   " + IntegerToString(rows_total) + "\r\n";
   text += "Risk Eligible Rows:     " + IntegerToString(eligible_rows) + " / " + IntegerToString(rows_total) + " (" + AC_L1PercentText(risk_ready_pct) + ")\r\n";
   text += "Risk Blocked Rows:      " + IntegerToString(blocked_rows) + "\r\n";
   text += "Total Est Risk:         " + AC_L1MoneyText(total_est_risk) + " (" + AC_L1PercentText(total_risk_pct) + " equity)\r\n";
   text += "Net Result on Risk Rows:" + AC_L1MoneyText(net_money) + "\r\n";
   text += "Net / Risk:             " + DoubleToString(net_over_risk, 2) + "\r\n";
   text += "Average Risk / Row:     " + AC_L1MoneyText(avg_risk) + " (" + AC_L1PercentText(avg_risk_pct) + " equity)\r\n";
   text += "Gross Win / Loss:       " + AC_L1MoneyText(gross_win_money) + " / " + AC_L1MoneyText(gross_loss_money) + "\r\n";
   text += "Largest Est Risk:       " + largest_risk_symbol + " " + AC_L1MoneyText(largest_risk) + " (" + AC_L1PercentText(largest_risk_pct) + " equity) - " + AC_L1RiskBreachLabel(largest_risk_pct) + "\r\n";
   text += "Largest Loss:           " + largest_loss_symbol + " " + AC_L1MoneyText(largest_loss) + " (" + AC_L1PercentText(largest_loss_pct) + " equity)\r\n";
   text += "Trade Permission:       FALSE\r\n";
   return text;
}

string AC_L1RiskBreachMap()
{
   int rows_total = ArraySize(AC_L1_CLOSED);
   int eligible_rows = 0;
   int unit_breaches = 0;
   int hard_breaches = 0;
   int extreme_breaches = 0;
   int loss_rows_over_unit_loss = 0;
   int loss_rows_over_hard_loss = 0;
   int loss_rows_over_extreme_loss = 0;
   double unit_risk_money = AC_L1_EQUITY * 0.001;
   double hard_risk_money = AC_L1_EQUITY * 0.002;
   double extreme_risk_money = AC_L1_EQUITY * 0.005;

   for(int i = 0; i < rows_total; i++)
   {
      double risk = 0.0;
      if(!AC_L1EstimateClosedInitialRiskMoney(AC_L1_CLOSED[i], risk)) continue;
      eligible_rows++;
      if(risk > unit_risk_money) unit_breaches++;
      if(risk > hard_risk_money) hard_breaches++;
      if(risk > extreme_risk_money) extreme_breaches++;
      double loss_abs = (AC_L1_CLOSED[i].net_result < 0.0 ? MathAbs(AC_L1_CLOSED[i].net_result) : 0.0);
      if(loss_abs > unit_risk_money) loss_rows_over_unit_loss++;
      if(loss_abs > hard_risk_money) loss_rows_over_hard_loss++;
      if(loss_abs > extreme_risk_money) loss_rows_over_extreme_loss++;
   }

   double unit_pct = (eligible_rows > 0 ? ((double)unit_breaches * 100.0) / eligible_rows : 0.0);
   double hard_pct = (eligible_rows > 0 ? ((double)hard_breaches * 100.0) / eligible_rows : 0.0);
   double extreme_pct = (eligible_rows > 0 ? ((double)extreme_breaches * 100.0) / eligible_rows : 0.0);

   string text = AC_L1MapHeader("RISK BREACH MAP");
   text += "Scope:                  selected closed rows with estimated money-risk only\r\n";
   text += "Unit Risk 0.10%:        " + AC_L1MoneyText(unit_risk_money) + "\r\n";
   text += "Hard Risk 0.20%:        " + AC_L1MoneyText(hard_risk_money) + "\r\n";
   text += "Extreme Risk 0.50%:     " + AC_L1MoneyText(extreme_risk_money) + "\r\n";
   text += "Risk Eligible Rows:     " + IntegerToString(eligible_rows) + " / " + IntegerToString(rows_total) + "\r\n";
   text += "Rows Above Unit Risk:   " + IntegerToString(unit_breaches) + " (" + AC_L1PercentText(unit_pct) + ")\r\n";
   text += "Rows Above Hard Risk:   " + IntegerToString(hard_breaches) + " (" + AC_L1PercentText(hard_pct) + ")\r\n";
   text += "Rows Above Extreme Risk:" + IntegerToString(extreme_breaches) + " (" + AC_L1PercentText(extreme_pct) + ")\r\n";
   text += "Loss Rows > Unit:       " + IntegerToString(loss_rows_over_unit_loss) + "\r\n";
   text += "Loss Rows > Hard:       " + IntegerToString(loss_rows_over_hard_loss) + "\r\n";
   text += "Loss Rows > Extreme:    " + IntegerToString(loss_rows_over_extreme_loss) + "\r\n";
   text += "Trade Permission:       FALSE\r\n";
   return text;
}

string AC_L1RiskBreachBySymbolMap(const int limit)
{
   string text = AC_L1MapHeader("SYMBOL RISK BREACH HEAT MAP");
   text += "Scope:                  selected closed rows with estimated money-risk only\r\n";
   text += AC_L1PadRight("Symbol", 14)
      + AC_L1PadLeft("Rows", 6)
      + AC_L1PadLeft("Net", 11)
      + AC_L1PadLeft("Risk", 11)
      + AC_L1PadLeft("Net/Risk", 10)
      + AC_L1PadLeft("Unit", 8)
      + AC_L1PadLeft("Hard", 8)
      + AC_L1PadLeft("Extreme", 8)
      + "\r\n";

   string used = "|";
   int printed = 0;
   double unit_risk_money = AC_L1_EQUITY * 0.001;
   double hard_risk_money = AC_L1_EQUITY * 0.002;
   double extreme_risk_money = AC_L1_EQUITY * 0.005;

   for(int rank = 0; rank < limit; rank++)
   {
      string selected_symbol = "";
      int selected_rows = 0;
      int selected_unit = 0;
      int selected_hard = 0;
      int selected_extreme = 0;
      double selected_net = 0.0;
      double selected_risk = 0.0;
      double selected_score = -1.0;

      for(int i = 0; i < ArraySize(AC_L1_CLOSED); i++)
      {
         string symbol = AC_L1_CLOSED[i].symbol;
         if(symbol == "") continue;
         if(StringFind(used, "|" + symbol + "|") >= 0) continue;

         int rows = 0;
         int unit = 0;
         int hard = 0;
         int extreme = 0;
         double net = 0.0;
         double risk_total = 0.0;

         for(int j = 0; j < ArraySize(AC_L1_CLOSED); j++)
         {
            if(AC_L1_CLOSED[j].symbol != symbol) continue;
            double risk = 0.0;
            if(!AC_L1EstimateClosedInitialRiskMoney(AC_L1_CLOSED[j], risk)) continue;
            rows++;
            net += AC_L1_CLOSED[j].net_result;
            risk_total += risk;
            if(risk > unit_risk_money) unit++;
            if(risk > hard_risk_money) hard++;
            if(risk > extreme_risk_money) extreme++;
         }

         if(rows <= 0) continue;
         double score = (double)(unit + (hard * 2) + (extreme * 3)) + MathAbs(net / MathMax(risk_total, 0.01));
         if(score > selected_score)
         {
            selected_score = score;
            selected_symbol = symbol;
            selected_rows = rows;
            selected_unit = unit;
            selected_hard = hard;
            selected_extreme = extreme;
            selected_net = net;
            selected_risk = risk_total;
         }
      }

      if(selected_symbol == "") break;
      used += selected_symbol + "|";
      text += AC_L1RiskBreachSymbolLine(selected_symbol, selected_rows, selected_net, selected_risk, selected_unit, selected_hard, selected_extreme);
      printed++;
   }

   if(printed <= 0) text += "none\r\n";
   text += "Sort:                   breach severity plus absolute net/risk impact\r\n";
   text += "Trade Permission:       FALSE\r\n";
   return text;
}

string AC_L1RiskEfficiencyMapsFull()
{
   string text = "";
   text += AC_L1RiskEfficiencyMap();
   text += AC_L1RiskBreachMap();
   text += AC_L1RiskBreachBySymbolMap(12);
   return text;
}

#endif