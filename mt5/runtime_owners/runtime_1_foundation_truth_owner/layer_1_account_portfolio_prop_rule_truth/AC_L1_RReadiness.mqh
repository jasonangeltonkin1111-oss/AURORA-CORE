#ifndef AC_L1_RREADINESS_MQH
#define AC_L1_RREADINESS_MQH

bool AC_L1RowHasEntryTruth(const AC_L1ClosedTradeRow &row)
{
   return (row.entry_time > 0 && row.entry_price > 0.0 && row.entry_reconstruction_status == "complete");
}

bool AC_L1RowHasStopLoss(const AC_L1ClosedTradeRow &row)
{
   return (row.stop_loss > 0.0);
}

bool AC_L1RowHasTakeProfit(const AC_L1ClosedTradeRow &row)
{
   return (row.take_profit > 0.0);
}

bool AC_L1RowHasValidRiskGeometry(const AC_L1ClosedTradeRow &row)
{
   if(!AC_L1RowHasEntryTruth(row)) return false;
   if(!AC_L1RowHasStopLoss(row)) return false;
   if(row.volume <= 0.0) return false;
   if(row.side == "buy") return (row.stop_loss < row.entry_price);
   if(row.side == "sell") return (row.stop_loss > row.entry_price);
   return false;
}

string AC_L1RReadinessMap()
{
   int rows_total = ArraySize(AC_L1_CLOSED);
   int rows_with_entry = 0;
   int rows_without_entry = 0;
   int rows_with_sl = 0;
   int rows_without_sl = 0;
   int rows_with_tp = 0;
   int rows_without_tp = 0;
   int rows_with_valid_risk_geometry = 0;
   int rows_with_invalid_risk_geometry = 0;
   int rows_with_order_context_complete = 0;
   int rows_with_order_context_partial = 0;
   int rows_with_order_context_unavailable = 0;

   for(int i = 0; i < rows_total; i++)
   {
      bool has_entry = AC_L1RowHasEntryTruth(AC_L1_CLOSED[i]);
      bool has_sl = AC_L1RowHasStopLoss(AC_L1_CLOSED[i]);
      bool has_tp = AC_L1RowHasTakeProfit(AC_L1_CLOSED[i]);
      bool valid_geometry = AC_L1RowHasValidRiskGeometry(AC_L1_CLOSED[i]);

      if(has_entry) rows_with_entry++; else rows_without_entry++;
      if(has_sl) rows_with_sl++; else rows_without_sl++;
      if(has_tp) rows_with_tp++; else rows_without_tp++;
      if(valid_geometry) rows_with_valid_risk_geometry++;
      else if(has_entry && has_sl) rows_with_invalid_risk_geometry++;

      if(AC_L1_CLOSED[i].order_context_status == "protective_context_complete") rows_with_order_context_complete++;
      else if(AC_L1_CLOSED[i].order_context_status == "protective_context_partial") rows_with_order_context_partial++;
      else rows_with_order_context_unavailable++;
   }

   double entry_pct = (rows_total > 0 ? ((double)rows_with_entry * 100.0) / rows_total : 0.0);
   double sl_pct = (rows_total > 0 ? ((double)rows_with_sl * 100.0) / rows_total : 0.0);
   double geometry_pct = (rows_total > 0 ? ((double)rows_with_valid_risk_geometry * 100.0) / rows_total : 0.0);

   string text = AC_L1MapHeader("R READINESS MAP");
   text += "Purpose:                readiness only; no R-multiple calculated here\r\n";
   text += "Selected Closed Rows:   " + IntegerToString(rows_total) + "\r\n";
   text += "Rows With Entry Truth:  " + IntegerToString(rows_with_entry) + " / " + IntegerToString(rows_total) + " (" + AC_L1PercentText(entry_pct) + ")\r\n";
   text += "Rows Without Entry:     " + IntegerToString(rows_without_entry) + "\r\n";
   text += "Rows With SL:           " + IntegerToString(rows_with_sl) + " / " + IntegerToString(rows_total) + " (" + AC_L1PercentText(sl_pct) + ")\r\n";
   text += "Rows Without SL:        " + IntegerToString(rows_without_sl) + "\r\n";
   text += "Rows With TP:           " + IntegerToString(rows_with_tp) + "\r\n";
   text += "Rows Without TP:        " + IntegerToString(rows_without_tp) + "\r\n";
   text += "Risk Geometry Ready:    " + IntegerToString(rows_with_valid_risk_geometry) + " / " + IntegerToString(rows_total) + " (" + AC_L1PercentText(geometry_pct) + ")\r\n";
   text += "Risk Geometry Invalid:  " + IntegerToString(rows_with_invalid_risk_geometry) + "\r\n";
   text += "Order Context Complete: " + IntegerToString(rows_with_order_context_complete) + "\r\n";
   text += "Order Context Partial:  " + IntegerToString(rows_with_order_context_partial) + "\r\n";
   text += "Order Context Missing:  " + IntegerToString(rows_with_order_context_unavailable) + "\r\n";
   text += "Money-R Status:         unavailable_until_tick_value_contract_currency_and_SL_money_risk_are_proved\r\n";
   text += "R-Multiple Status:      blocked_until_money_risk_source_is_proved\r\n";
   return text;
}

#endif