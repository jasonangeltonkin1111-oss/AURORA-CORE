#ifndef AC_L1_R_MULTIPLE_MAPS_MQH
#define AC_L1_R_MULTIPLE_MAPS_MQH

double AC_L1ClosedTradeRMultiple(const AC_L1ClosedTradeRow &row,
                                 const double risk_money)
{
   if(risk_money <= 0.0) return 0.0;
   return row.net_result / risk_money;
}

string AC_L1RBySymbolLine(const string symbol,
                          const int rows,
                          const double net_r,
                          const double best_r,
                          const double worst_r,
                          const double net_money)
{
   double avg_r = (rows > 0 ? net_r / rows : 0.0);
   return AC_L1PadRight(symbol, 14)
      + AC_L1PadLeft(IntegerToString(rows), 6)
      + AC_L1PadLeft(DoubleToString(net_r, 2), 10)
      + AC_L1PadLeft(DoubleToString(avg_r, 2), 10)
      + AC_L1PadLeft(DoubleToString(best_r, 2), 10)
      + AC_L1PadLeft(DoubleToString(worst_r, 2), 10)
      + AC_L1PadLeft(AC_L1MoneyText(net_money), 11)
      + "\r\n";
}

string AC_L1RMultipleMap()
{
   int rows_total = ArraySize(AC_L1_CLOSED);
   int r_rows = 0;
   int blocked_rows = 0;
   int win_rows = 0;
   int loss_rows = 0;
   double net_r = 0.0;
   double gross_win_r = 0.0;
   double gross_loss_r = 0.0;
   double best_r = -999999.0;
   double worst_r = 999999.0;
   string best_r_symbol = "none";
   string worst_r_symbol = "none";
   double total_est_risk = 0.0;
   double largest_risk = 0.0;
   string largest_risk_symbol = "none";

   for(int i = 0; i < rows_total; i++)
   {
      double risk = 0.0;
      if(!AC_L1EstimateClosedInitialRiskMoney(AC_L1_CLOSED[i], risk))
      {
         blocked_rows++;
         continue;
      }

      double r = AC_L1ClosedTradeRMultiple(AC_L1_CLOSED[i], risk);
      r_rows++;
      net_r += r;
      total_est_risk += risk;
      if(risk > largest_risk)
      {
         largest_risk = risk;
         largest_risk_symbol = AC_L1_CLOSED[i].symbol;
      }
      if(r > best_r)
      {
         best_r = r;
         best_r_symbol = AC_L1_CLOSED[i].symbol;
      }
      if(r < worst_r)
      {
         worst_r = r;
         worst_r_symbol = AC_L1_CLOSED[i].symbol;
      }
      if(r > 0.0)
      {
         win_rows++;
         gross_win_r += r;
      }
      else if(r < 0.0)
      {
         loss_rows++;
         gross_loss_r += r;
      }
   }

   double avg_r = (r_rows > 0 ? net_r / r_rows : 0.0);
   double avg_win_r = (win_rows > 0 ? gross_win_r / win_rows : 0.0);
   double avg_loss_r = (loss_rows > 0 ? gross_loss_r / loss_rows : 0.0);
   double r_ready_pct = (rows_total > 0 ? ((double)r_rows * 100.0) / rows_total : 0.0);
   double total_risk_pct = (AC_L1_EQUITY > 0.0 ? (total_est_risk / AC_L1_EQUITY) * 100.0 : 0.0);
   if(r_rows <= 0)
   {
      best_r = 0.0;
      worst_r = 0.0;
   }

   string text = AC_L1MapHeader("R-MULTIPLE MAP - SELECTED HISTORY");
   text += "Purpose:                estimated R diagnostics from closed rows with money-risk readiness\r\n";
   text += "Risk Source:            OrderCalcProfit entry-to-SL estimate from Layer 1 money-risk helper\r\n";
   text += "Proof Status:           estimated R, not edge proof, not broker equity curve, not trade permission\r\n";
   text += "Selected Closed Rows:   " + IntegerToString(rows_total) + "\r\n";
   text += "R Eligible Rows:        " + IntegerToString(r_rows) + " / " + IntegerToString(rows_total) + " (" + AC_L1PercentText(r_ready_pct) + ")\r\n";
   text += "R Blocked Rows:         " + IntegerToString(blocked_rows) + "\r\n";
   text += "Net R:                  " + DoubleToString(net_r, 2) + "\r\n";
   text += "Average R:              " + DoubleToString(avg_r, 2) + "\r\n";
   text += "Average Win R:          " + DoubleToString(avg_win_r, 2) + "\r\n";
   text += "Average Loss R:         " + DoubleToString(avg_loss_r, 2) + "\r\n";
   text += "Best R:                 " + best_r_symbol + " " + DoubleToString(best_r, 2) + "\r\n";
   text += "Worst R:                " + worst_r_symbol + " " + DoubleToString(worst_r, 2) + "\r\n";
   text += "Estimated Risk Total:   " + AC_L1MoneyText(total_est_risk) + " (" + AC_L1PercentText(total_risk_pct) + " equity)\r\n";
   text += "Largest Risk Row:       " + largest_risk_symbol + " " + AC_L1MoneyText(largest_risk) + "\r\n";
   text += "Trade Permission:       FALSE\r\n";
   return text;
}

string AC_L1RBySymbolMap(const int limit)
{
   string text = AC_L1MapHeader("R BY SYMBOL MAP");
   text += "Scope:                  selected closed rows with estimated money-risk only\r\n";
   text += AC_L1PadRight("Symbol", 14)
      + AC_L1PadLeft("Rows", 6)
      + AC_L1PadLeft("Net R", 10)
      + AC_L1PadLeft("Avg R", 10)
      + AC_L1PadLeft("Best R", 10)
      + AC_L1PadLeft("Worst R", 10)
      + AC_L1PadLeft("Net", 11)
      + "\r\n";

   string used = "|";
   int printed = 0;
   for(int rank = 0; rank < limit; rank++)
   {
      string best_symbol = "";
      double best_abs_net_r = -1.0;
      int best_rows = 0;
      double best_net_r = 0.0;
      double best_symbol_best_r = -999999.0;
      double best_symbol_worst_r = 999999.0;
      double best_net_money = 0.0;

      for(int i = 0; i < ArraySize(AC_L1_CLOSED); i++)
      {
         string symbol = AC_L1_CLOSED[i].symbol;
         if(symbol == "") continue;
         if(StringFind(used, "|" + symbol + "|") >= 0) continue;

         int rows = 0;
         double symbol_net_r = 0.0;
         double symbol_best_r = -999999.0;
         double symbol_worst_r = 999999.0;
         double symbol_net_money = 0.0;

         for(int j = 0; j < ArraySize(AC_L1_CLOSED); j++)
         {
            if(AC_L1_CLOSED[j].symbol != symbol) continue;
            double risk = 0.0;
            if(!AC_L1EstimateClosedInitialRiskMoney(AC_L1_CLOSED[j], risk)) continue;
            double r = AC_L1ClosedTradeRMultiple(AC_L1_CLOSED[j], risk);
            rows++;
            symbol_net_r += r;
            symbol_net_money += AC_L1_CLOSED[j].net_result;
            if(r > symbol_best_r) symbol_best_r = r;
            if(r < symbol_worst_r) symbol_worst_r = r;
         }

         if(rows <= 0) continue;
         double abs_net_r = MathAbs(symbol_net_r);
         if(abs_net_r > best_abs_net_r)
         {
            best_abs_net_r = abs_net_r;
            best_symbol = symbol;
            best_rows = rows;
            best_net_r = symbol_net_r;
            best_symbol_best_r = symbol_best_r;
            best_symbol_worst_r = symbol_worst_r;
            best_net_money = symbol_net_money;
         }
      }

      if(best_symbol == "") break;
      used += best_symbol + "|";
      text += AC_L1RBySymbolLine(best_symbol, best_rows, best_net_r, best_symbol_best_r, best_symbol_worst_r, best_net_money);
      printed++;
   }

   if(printed <= 0) text += "none\r\n";
   text += "Sort:                   largest absolute net R first\r\n";
   text += "Trade Permission:       FALSE\r\n";
   return text;
}

string AC_L1RMultipleMapsFull()
{
   string text = "";
   text += AC_L1RMultipleMap();
   text += AC_L1RBySymbolMap(12);
   return text;
}

#endif