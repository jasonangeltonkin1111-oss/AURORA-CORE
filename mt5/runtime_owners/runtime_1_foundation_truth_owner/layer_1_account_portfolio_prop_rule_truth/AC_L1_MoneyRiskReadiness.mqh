#ifndef AC_L1_MONEY_RISK_READINESS_MQH
#define AC_L1_MONEY_RISK_READINESS_MQH

bool AC_L1ClosedRiskOrderType(const string side,
                              ENUM_ORDER_TYPE &order_type)
{
   if(side == "buy")
   {
      order_type = ORDER_TYPE_BUY;
      return true;
   }
   if(side == "sell")
   {
      order_type = ORDER_TYPE_SELL;
      return true;
   }
   return false;
}

bool AC_L1EstimateClosedInitialRiskMoney(const AC_L1ClosedTradeRow &row,
                                         double &risk_money)
{
   risk_money = 0.0;
   if(!AC_L1RowHasValidRiskGeometry(row)) return false;
   if(row.symbol == "" || row.volume <= 0.0) return false;

   ENUM_ORDER_TYPE order_type = ORDER_TYPE_BUY;
   if(!AC_L1ClosedRiskOrderType(row.side, order_type)) return false;

   double profit_at_sl = 0.0;
   ResetLastError();
   if(!OrderCalcProfit(order_type, row.symbol, row.volume, row.entry_price, row.stop_loss, profit_at_sl))
      return false;

   if(profit_at_sl >= 0.0)
      return false;

   risk_money = MathAbs(profit_at_sl);
   return (risk_money > 0.0);
}

string AC_L1ClosedMoneyRiskReadinessMap()
{
   int rows_total = ArraySize(AC_L1_CLOSED);
   int rows_with_entry = 0;
   int rows_with_sl = 0;
   int rows_valid_geometry = 0;
   int rows_missing_symbol = 0;
   int rows_invalid_volume = 0;
   int rows_invalid_side = 0;
   int rows_risk_estimated = 0;
   int rows_risk_blocked = 0;
   int rows_risk_non_loss = 0;
   double total_est_risk = 0.0;
   double largest_est_risk = 0.0;
   string largest_est_risk_symbol = "none";

   for(int i = 0; i < rows_total; i++)
   {
      AC_L1ClosedTradeRow row = AC_L1_CLOSED[i];
      if(AC_L1RowHasEntryTruth(row)) rows_with_entry++;
      if(AC_L1RowHasStopLoss(row)) rows_with_sl++;
      if(AC_L1RowHasValidRiskGeometry(row)) rows_valid_geometry++;
      if(row.symbol == "") rows_missing_symbol++;
      if(row.volume <= 0.0) rows_invalid_volume++;
      ENUM_ORDER_TYPE order_type = ORDER_TYPE_BUY;
      if(!AC_L1ClosedRiskOrderType(row.side, order_type)) rows_invalid_side++;

      double risk = 0.0;
      if(AC_L1EstimateClosedInitialRiskMoney(row, risk))
      {
         rows_risk_estimated++;
         total_est_risk += risk;
         if(risk > largest_est_risk)
         {
            largest_est_risk = risk;
            largest_est_risk_symbol = row.symbol;
         }
      }
      else
      {
         rows_risk_blocked++;
         if(AC_L1RowHasValidRiskGeometry(row) && row.symbol != "" && row.volume > 0.0 && AC_L1ClosedRiskOrderType(row.side, order_type))
         {
            double profit_at_sl = 0.0;
            if(OrderCalcProfit(order_type, row.symbol, row.volume, row.entry_price, row.stop_loss, profit_at_sl) && profit_at_sl >= 0.0)
               rows_risk_non_loss++;
         }
      }
   }

   double risk_ready_pct = (rows_total > 0 ? ((double)rows_risk_estimated * 100.0) / rows_total : 0.0);
   double geometry_pct = (rows_total > 0 ? ((double)rows_valid_geometry * 100.0) / rows_total : 0.0);
   double avg_est_risk = (rows_risk_estimated > 0 ? total_est_risk / rows_risk_estimated : 0.0);
   double total_risk_pct_equity = (AC_L1_EQUITY > 0.0 ? (total_est_risk / AC_L1_EQUITY) * 100.0 : 0.0);
   double largest_risk_pct_equity = (AC_L1_EQUITY > 0.0 ? (largest_est_risk / AC_L1_EQUITY) * 100.0 : 0.0);

   string text = AC_L1MapHeader("CLOSED TRADE MONEY-RISK READINESS MAP");
   text += "Purpose:                prove whether closed rows can estimate initial SL money risk\r\n";
   text += "Estimate Source:        OrderCalcProfit from reconstructed entry price to stored SL\r\n";
   text += "Proof Status:           estimated account-currency risk, not broker equity curve or trade permission proof\r\n";
   text += "Selected Closed Rows:   " + IntegerToString(rows_total) + "\r\n";
   text += "Rows With Entry Truth:  " + IntegerToString(rows_with_entry) + "\r\n";
   text += "Rows With SL:           " + IntegerToString(rows_with_sl) + "\r\n";
   text += "Risk Geometry Ready:    " + IntegerToString(rows_valid_geometry) + " / " + IntegerToString(rows_total) + " (" + AC_L1PercentText(geometry_pct) + ")\r\n";
   text += "Risk Money Estimated:   " + IntegerToString(rows_risk_estimated) + " / " + IntegerToString(rows_total) + " (" + AC_L1PercentText(risk_ready_pct) + ")\r\n";
   text += "Risk Money Blocked:     " + IntegerToString(rows_risk_blocked) + "\r\n";
   text += "Missing Symbol Rows:    " + IntegerToString(rows_missing_symbol) + "\r\n";
   text += "Invalid Volume Rows:    " + IntegerToString(rows_invalid_volume) + "\r\n";
   text += "Invalid Side Rows:      " + IntegerToString(rows_invalid_side) + "\r\n";
   text += "Non-Loss Risk Results:  " + IntegerToString(rows_risk_non_loss) + "\r\n";
   text += "Total Est Risk:         " + AC_L1MoneyText(total_est_risk) + " (" + AC_L1PercentText(total_risk_pct_equity) + " equity)\r\n";
   text += "Average Est Risk:       " + AC_L1MoneyText(avg_est_risk) + "\r\n";
   text += "Largest Est Risk:       " + largest_est_risk_symbol + " " + AC_L1MoneyText(largest_est_risk) + " (" + AC_L1PercentText(largest_risk_pct_equity) + " equity)\r\n";
   text += "Money-R Status:         " + (rows_risk_estimated > 0 ? "estimated money-risk source available for R test" : "blocked - no rows estimated") + "\r\n";
   text += "R-Multiple Status:      readiness only; full R map still blocked until next feature run\r\n";
   text += "Trade Permission:       FALSE\r\n";
   return text;
}

#endif