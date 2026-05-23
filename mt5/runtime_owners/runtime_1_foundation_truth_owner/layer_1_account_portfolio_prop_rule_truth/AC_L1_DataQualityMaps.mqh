#ifndef AC_L1_DATA_QUALITY_MAPS_MQH
#define AC_L1_DATA_QUALITY_MAPS_MQH

string AC_L1QualityLedgerLine(const string severity,
                              const string key,
                              const string value)
{
   return AC_L1PadRight(severity, 9)
      + "| " + AC_L1PadRight(key, 38)
      + "| " + value
      + "\r\n";
}

string AC_L1DataQualityLedger()
{
   int rows_total = ArraySize(AC_L1_CLOSED);
   int rows_without_entry = 0;
   int rows_without_sl = 0;
   int rows_without_tp = 0;
   int rows_invalid_risk_geometry = 0;
   int rows_partial_reconstruction = 0;
   int rows_order_context_partial = 0;
   int rows_order_context_unavailable = 0;
   int rows_cost_allocated_partial = 0;
   int rows_magic_zero = 0;
   int rows_comment_missing = 0;
   int rows_large_loss_over_hard_risk = 0;

   double hard_risk = AC_L1_EQUITY * 0.002;

   for(int i = 0; i < rows_total; i++)
   {
      if(!(AC_L1_CLOSED[i].entry_time > 0 && AC_L1_CLOSED[i].entry_price > 0.0)) rows_without_entry++;
      if(AC_L1_CLOSED[i].stop_loss <= 0.0) rows_without_sl++;
      if(AC_L1_CLOSED[i].take_profit <= 0.0) rows_without_tp++;
      if(AC_L1_CLOSED[i].stop_loss > 0.0 && AC_L1_CLOSED[i].entry_price > 0.0)
      {
         bool valid = false;
         if(AC_L1_CLOSED[i].side == "buy") valid = (AC_L1_CLOSED[i].stop_loss < AC_L1_CLOSED[i].entry_price);
         if(AC_L1_CLOSED[i].side == "sell") valid = (AC_L1_CLOSED[i].stop_loss > AC_L1_CLOSED[i].entry_price);
         if(!valid) rows_invalid_risk_geometry++;
      }
      if(AC_L1_CLOSED[i].entry_reconstruction_status != "complete") rows_partial_reconstruction++;
      if(AC_L1_CLOSED[i].order_context_status == "protective_context_partial") rows_order_context_partial++;
      else if(AC_L1_CLOSED[i].order_context_status == "order_context_unavailable") rows_order_context_unavailable++;
      if(StringFind(AC_L1_CLOSED[i].source_quality, "partial") >= 0) rows_cost_allocated_partial++;
      if(AC_L1_CLOSED[i].magic == 0) rows_magic_zero++;
      string comment = AC_L1_CLOSED[i].comment;
      StringTrimLeft(comment);
      StringTrimRight(comment);
      if(comment == "") rows_comment_missing++;
      if(hard_risk > 0.0 && AC_L1_CLOSED[i].net_result < 0.0 && MathAbs(AC_L1_CLOSED[i].net_result) > hard_risk) rows_large_loss_over_hard_risk++;
   }

   int cluster_groups = 0;
   int cluster_rows = 0;
   double cluster_net = 0.0;
   AC_L1ClusterStats(cluster_groups, cluster_rows, cluster_net);

   string text = AC_L1MapHeader("RULE / DATA QUALITY LEDGER");
   text += "Scope:                  selected closed history diagnostics only\r\n";
   text += "Rows Total:             " + IntegerToString(rows_total) + "\r\n";
   text += "Trade Permission:       FALSE\r\n";
   text += AC_L1QualityLedgerLine("INFO", "selected_history_rows", IntegerToString(rows_total));
   text += AC_L1QualityLedgerLine(rows_without_entry > 0 ? "WARNING" : "OK", "rows_without_entry_truth", IntegerToString(rows_without_entry));
   text += AC_L1QualityLedgerLine(rows_without_sl > 0 ? "WARNING" : "OK", "rows_without_stop_loss", IntegerToString(rows_without_sl));
   text += AC_L1QualityLedgerLine(rows_without_tp > 0 ? "INFO" : "OK", "rows_without_take_profit", IntegerToString(rows_without_tp));
   text += AC_L1QualityLedgerLine(rows_invalid_risk_geometry > 0 ? "WARNING" : "OK", "rows_invalid_sl_geometry", IntegerToString(rows_invalid_risk_geometry));
   text += AC_L1QualityLedgerLine(rows_partial_reconstruction > 0 ? "WARNING" : "OK", "rows_partial_entry_reconstruction", IntegerToString(rows_partial_reconstruction));
   text += AC_L1QualityLedgerLine(rows_order_context_partial > 0 ? "INFO" : "OK", "rows_order_context_partial", IntegerToString(rows_order_context_partial));
   text += AC_L1QualityLedgerLine(rows_order_context_unavailable > 0 ? "WARNING" : "OK", "rows_order_context_unavailable", IntegerToString(rows_order_context_unavailable));
   text += AC_L1QualityLedgerLine(rows_cost_allocated_partial > 0 ? "INFO" : "OK", "rows_partial_cost_allocation_source", IntegerToString(rows_cost_allocated_partial));
   text += AC_L1QualityLedgerLine(rows_magic_zero > 0 ? "INFO" : "OK", "rows_magic_zero", IntegerToString(rows_magic_zero));
   text += AC_L1QualityLedgerLine(rows_comment_missing > 0 ? "INFO" : "OK", "rows_comment_missing", IntegerToString(rows_comment_missing));
   text += AC_L1QualityLedgerLine(rows_large_loss_over_hard_risk > 0 ? "CRITICAL" : "OK", "loss_rows_over_0_2pct_hard_risk", IntegerToString(rows_large_loss_over_hard_risk));
   text += AC_L1QualityLedgerLine(cluster_rows > 0 ? "WARNING" : "OK", "cluster_rows_same_symbol_side_time", IntegerToString(cluster_rows) + " rows / " + IntegerToString(cluster_groups) + " groups / net " + AC_L1MoneyText(cluster_net));
   text += AC_L1QualityLedgerLine("INFO", "ledger_scope", "diagnostic_only_no_trade_permission");
   return text;
}

#endif