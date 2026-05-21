#ifndef AC_L1_RENDER_MQH
#define AC_L1_RENDER_MQH

string AC_L1DurationText(const long seconds)
{
   if(seconds <= 0) return "unavailable";
   long minutes = seconds / 60;
   long hours = minutes / 60;
   long days = hours / 24;
   if(days > 0) return IntegerToString((int)days) + "d " + IntegerToString((int)(hours % 24)) + "h";
   if(hours > 0) return IntegerToString((int)hours) + "h " + IntegerToString((int)(minutes % 60)) + "m";
   return IntegerToString((int)minutes) + "m";
}

string AC_L1ClosedTradeLine(const AC_L1ClosedTradeRow &row)
{
   return AC_L1PadRight(AC_L1ShortTimeText(row.close_time), 17)
      + AC_L1PadRight(row.symbol, 14)
      + AC_L1PadRight(row.side, 6)
      + AC_L1PadLeft(AC_L1VolumeText(row.volume), 7)
      + AC_L1PadLeft(AC_L1PriceText(row.entry_price), 12)
      + AC_L1PadLeft(AC_L1PriceText(row.close_price), 12)
      + AC_L1PadLeft(AC_L1MoneyText(row.net_result), 10)
      + "  " + row.source_quality;
}

string AC_L1ClosedTradeDetailLine(const AC_L1ClosedTradeRow &row)
{
   return AC_L1ClosedTradeLine(row)
      + " | commission=" + AC_L1MoneyText(row.commission)
      + " swap=" + AC_L1MoneyText(row.swap)
      + " fee=" + AC_L1MoneyText(row.fee)
      + " core=" + row.entry_reconstruction_status
      + " order_ctx=" + row.order_context_status;
}

string AC_L1PositionLine(const AC_L1PositionRow &row)
{
   return AC_L1PadRight(AC_L1ShortTimeText(row.open_time), 17)
      + AC_L1PadRight(row.symbol, 14)
      + AC_L1PadRight(row.side, 6)
      + AC_L1PadLeft(AC_L1VolumeText(row.volume), 7)
      + AC_L1PadLeft(AC_L1PriceText(row.entry_price), 12)
      + AC_L1PadLeft(AC_L1PriceText(row.stop_loss), 12)
      + AC_L1PadLeft(AC_L1PriceText(row.take_profit), 12)
      + AC_L1PadLeft(AC_L1MoneyText(row.profit), 10);
}

string AC_L1PendingLine(const AC_L1PendingOrderRow &row)
{
   return AC_L1PadRight(AC_L1ShortTimeText(row.setup_time), 17)
      + AC_L1PadRight(row.symbol, 14)
      + AC_L1PadRight(row.type_text, 15)
      + AC_L1PadLeft(AC_L1VolumeText(row.volume), 7)
      + AC_L1PadLeft(AC_L1PriceText(row.price), 12)
      + AC_L1PadLeft(AC_L1PriceText(row.stop_loss), 12)
      + AC_L1PadLeft(AC_L1PriceText(row.take_profit), 12);
}

string AC_L1CancelLine(const AC_L1OrderEventRow &row)
{
   return AC_L1PadRight(AC_L1ShortTimeText(row.setup_time), 17)
      + AC_L1PadRight(row.symbol, 14)
      + AC_L1PadRight(row.type_text, 15)
      + AC_L1PadRight(row.state_text, 10)
      + AC_L1PadLeft(AC_L1VolumeText(row.volume_initial), 7)
      + AC_L1PadLeft(AC_L1PriceText(row.price_open), 12);
}

string AC_L1SymbolSummaryTable()
{
   string text = "Symbol Summary\r\n";
   text += "----------------------------------------\r\n";
   text += AC_L1PadRight("Symbol", 14) + AC_L1PadLeft("Closed", 8) + AC_L1PadLeft("Wins", 7) + AC_L1PadLeft("Loss", 7) + AC_L1PadLeft("Cancel", 8) + AC_L1PadLeft("Net", 12) + "\r\n";
   for(int i = 0; i < ArraySize(AC_L1_SYMBOL_STATS); i++)
   {
      if(AC_L1_SYMBOL_STATS[i].closed_count <= 0 && AC_L1_SYMBOL_STATS[i].open_count <= 0 && AC_L1_SYMBOL_STATS[i].pending_count <= 0 && AC_L1_SYMBOL_STATS[i].canceled_count <= 0)
         continue;
      text += AC_L1PadRight(AC_L1_SYMBOL_STATS[i].symbol, 14)
         + AC_L1PadLeft(IntegerToString(AC_L1_SYMBOL_STATS[i].closed_count), 8)
         + AC_L1PadLeft(IntegerToString(AC_L1_SYMBOL_STATS[i].win_count), 7)
         + AC_L1PadLeft(IntegerToString(AC_L1_SYMBOL_STATS[i].loss_count), 7)
         + AC_L1PadLeft(IntegerToString(AC_L1_SYMBOL_STATS[i].canceled_count), 8)
         + AC_L1PadLeft(AC_L1MoneyText(AC_L1_SYMBOL_STATS[i].net_result), 12)
         + "\r\n";
   }
   return text;
}

string AC_L1DaySummaryTable()
{
   string text = "Day Summary\r\n";
   text += "----------------------------------------\r\n";
   text += AC_L1PadRight("Day", 14) + AC_L1PadLeft("Closed", 8) + AC_L1PadLeft("Net", 12) + "\r\n";
   for(int i = 0; i < ArraySize(AC_L1_DAY_STATS); i++)
   {
      text += AC_L1PadRight(AC_L1_DAY_STATS[i].day, 14)
         + AC_L1PadLeft(IntegerToString(AC_L1_DAY_STATS[i].closed_count), 8)
         + AC_L1PadLeft(AC_L1MoneyText(AC_L1_DAY_STATS[i].net_result), 12)
         + "\r\n";
   }
   return text;
}

void AC_BuildLayer1Texts()
{
   int closed_count = ArraySize(AC_L1_CLOSED);
   int win_count = 0;
   int loss_count = 0;
   for(int i = 0; i < ArraySize(AC_L1_SYMBOL_STATS); i++)
   {
      win_count += AC_L1_SYMBOL_STATS[i].win_count;
      loss_count += AC_L1_SYMBOL_STATS[i].loss_count;
   }

   double profit_factor = (AC_L1_GROSS_LOSS < 0.0 ? AC_L1_GROSS_PROFIT / MathAbs(AC_L1_GROSS_LOSS) : 0.0);
   double expected_payoff = (closed_count > 0 ? AC_L1_NET_PROFIT / closed_count : 0.0);
   double win_rate = (closed_count > 0 ? ((double)win_count * 100.0) / closed_count : 0.0);
   double avg_win = (win_count > 0 ? AC_L1_GROSS_PROFIT / win_count : 0.0);
   double avg_loss = (loss_count > 0 ? AC_L1_GROSS_LOSS / loss_count : 0.0);
   double avg_duration_seconds = (AC_L1_DURATION_COUNT > 0 ? ((double)AC_L1_DURATION_SUM_SECONDS / AC_L1_DURATION_COUNT) : 0.0);
   double start_balance_estimate = AC_L1_BALANCE - AC_L1_NET_PROFIT;
   double realized_return_pct = (start_balance_estimate > 0.0 ? (AC_L1_NET_PROFIT / start_balance_estimate) * 100.0 : 0.0);
   double current_dd_money = AC_L1_BALANCE - AC_L1_EQUITY;
   double current_dd_pct = (AC_L1_BALANCE > 0.0 ? (current_dd_money / AC_L1_BALANCE) * 100.0 : 0.0);
   double daily_dd_limit_money = AC_L1_EQUITY * 0.01;
   double max_dd_limit_money = AC_L1_EQUITY * 0.03;
   double default_risk_money = AC_L1_EQUITY * 0.001;
   double hard_risk_money = AC_L1_EQUITY * 0.002;
   double max_open_risk_money = AC_L1_EQUITY * 0.01;
   double open_profit_pct = (AC_L1_EQUITY > 0.0 ? (AC_L1_FLOATING_PL / AC_L1_EQUITY) * 100.0 : 0.0);
   double largest_loss_vs_hard_risk = (hard_risk_money > 0.0 && AC_L1_LARGEST_LOSS < 0.0 ? MathAbs(AC_L1_LARGEST_LOSS) / hard_risk_money : 0.0);
   string account_health = "needs_validation";
   if(closed_count > 0 && profit_factor < 1.0) account_health = "negative_expectancy_until_proven_otherwise";
   if(closed_count > 0 && profit_factor >= 1.0 && win_rate >= 50.0) account_health = "historically_positive_but_not_edge_proof";

   string warning_text = "";
   if(closed_count <= 0) warning_text += "- No closed-trade sample yet; L1 history cannot assess expectancy.\r\n";
   if(closed_count > 0 && profit_factor < 1.0) warning_text += "- Profit factor below 1.0: negative expectancy until proven otherwise.\r\n";
   if(closed_count > 0 && expected_payoff < 0.0) warning_text += "- Expected payoff is negative.\r\n";
   if(closed_count > 0 && win_rate < 45.0) warning_text += "- Win rate is weak for current history sample.\r\n";
   if(largest_loss_vs_hard_risk > 1.0) warning_text += "- Largest historical loss exceeds 0.2% hard-risk amount.\r\n";
   if(AC_L1_PARTIAL_RECONSTRUCTION_COUNT > 0) warning_text += "- Some trades have partial core reconstruction; compare with MT5 report before strict parity claims.\r\n";
   if(AC_L1_ORDER_CONTEXT_PARTIAL_COUNT > 0) warning_text += "- Some trades lack full SL/TP order context; core trade result may still be usable.\r\n";
   if(warning_text == "") warning_text = "- No L1 warning triggered, but this is still account-history supervision, not edge proof.\r\n";

   AC_L1_BOARD_SECTION = "\r\nLAYER 1 - ACCOUNT / PORTFOLIO\r\n";
   AC_L1_BOARD_SECTION += "----------------------------------------\r\n";
   AC_L1_BOARD_SECTION += "Account:          " + IntegerToString((int)AC_L1_LOGIN) + " / " + AC_L1_SERVER + "\r\n";
   AC_L1_BOARD_SECTION += "Mode/Currency:    " + AC_L1_TRADE_MODE + " / " + AC_L1_CURRENCY + "\r\n";
   AC_L1_BOARD_SECTION += "Balance/Equity:   " + AC_L1MoneyText(AC_L1_BALANCE) + " / " + AC_L1MoneyText(AC_L1_EQUITY) + "\r\n";
   AC_L1_BOARD_SECTION += "Floating P/L:     " + AC_L1MoneyText(AC_L1_FLOATING_PL) + " (" + AC_L1PercentText(open_profit_pct) + ")\r\n";
   AC_L1_BOARD_SECTION += "Current DD:       " + AC_L1MoneyText(current_dd_money) + " (" + AC_L1PercentText(current_dd_pct) + ")\r\n";
   AC_L1_BOARD_SECTION += "Free Margin:      " + AC_L1MoneyText(AC_L1_FREE_MARGIN) + "\r\n";
   AC_L1_BOARD_SECTION += "Open/Pending:     " + IntegerToString(ArraySize(AC_L1_POSITIONS)) + " / " + IntegerToString(ArraySize(AC_L1_PENDING)) + "\r\n";
   AC_L1_BOARD_SECTION += "History Window:   1970.01.01 -> broker TimeCurrent() | report_compare=not_strict_unless_same_cutoff\r\n";
   AC_L1_BOARD_SECTION += "\r\nPortfolio Health\r\n";
   AC_L1_BOARD_SECTION += "Closed Trades:    " + IntegerToString(closed_count) + "\r\n";
   AC_L1_BOARD_SECTION += "Net P/L:          " + AC_L1MoneyText(AC_L1_NET_PROFIT) + " (" + AC_L1PercentText(realized_return_pct) + " est.)\r\n";
   AC_L1_BOARD_SECTION += "Gross P/L:        " + AC_L1MoneyText(AC_L1_GROSS_PROFIT) + " / " + AC_L1MoneyText(AC_L1_GROSS_LOSS) + "\r\n";
   AC_L1_BOARD_SECTION += "Profit Factor:    " + DoubleToString(profit_factor, 2) + "\r\n";
   AC_L1_BOARD_SECTION += "Win Rate:         " + AC_L1PercentText(win_rate) + " (" + IntegerToString(win_count) + "W/" + IntegerToString(loss_count) + "L)\r\n";
   AC_L1_BOARD_SECTION += "Expected Payoff:  " + AC_L1MoneyText(expected_payoff) + "\r\n";
   AC_L1_BOARD_SECTION += "Avg Win/Loss:     " + AC_L1MoneyText(avg_win) + " / " + AC_L1MoneyText(avg_loss) + "\r\n";
   AC_L1_BOARD_SECTION += "Largest W/L:      " + AC_L1MoneyText(AC_L1_LARGEST_WIN) + " / " + AC_L1MoneyText(AC_L1_LARGEST_LOSS) + "\r\n";
   AC_L1_BOARD_SECTION += "Largest Loss/Risk:" + DoubleToString(largest_loss_vs_hard_risk, 2) + "x 0.2% hard-risk\r\n";
   AC_L1_BOARD_SECTION += "Avg Duration:     " + AC_L1DurationText((long)avg_duration_seconds) + " from " + IntegerToString(AC_L1_DURATION_COUNT) + " reconstructed trades\r\n";
   AC_L1_BOARD_SECTION += "Best Symbol:      " + AC_L1_BEST_SYMBOL + " " + AC_L1MoneyText(AC_L1_BEST_SYMBOL_NET) + "\r\n";
   AC_L1_BOARD_SECTION += "Worst Symbol:     " + AC_L1_WORST_SYMBOL + " " + AC_L1MoneyText(AC_L1_WORST_SYMBOL_NET) + "\r\n";
   AC_L1_BOARD_SECTION += "Best Day:         " + AC_L1_BEST_DAY + " " + AC_L1MoneyText(AC_L1_BEST_DAY_NET) + "\r\n";
   AC_L1_BOARD_SECTION += "Worst Day:        " + AC_L1_WORST_DAY + " " + AC_L1MoneyText(AC_L1_WORST_DAY_NET) + "\r\n";
   AC_L1_BOARD_SECTION += "Buy/Sell Net:     " + IntegerToString(AC_L1_BUY_COUNT) + " buy " + AC_L1MoneyText(AC_L1_BUY_NET) + " | " + IntegerToString(AC_L1_SELL_COUNT) + " sell " + AC_L1MoneyText(AC_L1_SELL_NET) + "\r\n";
   AC_L1_BOARD_SECTION += "Health:           " + account_health + "\r\n";
   AC_L1_BOARD_SECTION += "History Quality:  " + AC_L1_HISTORY_QUALITY + "\r\n";
   AC_L1_BOARD_SECTION += "Core Recon:       " + IntegerToString(AC_L1_CORE_RECONSTRUCTION_COMPLETE_COUNT) + " complete / " + IntegerToString(AC_L1_PARTIAL_RECONSTRUCTION_COUNT) + " partial_core\r\n";
   AC_L1_BOARD_SECTION += "Order Context:    " + IntegerToString(AC_L1_ORDER_CONTEXT_PARTIAL_COUNT) + " partial_or_missing_SLTP\r\n";
   AC_L1_BOARD_SECTION += "\r\nRisk Envelope - Planning Only\r\n";
   AC_L1_BOARD_SECTION += "0.1% risk:        " + AC_L1MoneyText(default_risk_money) + "\r\n";
   AC_L1_BOARD_SECTION += "0.2% hard max:    " + AC_L1MoneyText(hard_risk_money) + "\r\n";
   AC_L1_BOARD_SECTION += "1% open/daily:    " + AC_L1MoneyText(max_open_risk_money) + " / " + AC_L1MoneyText(daily_dd_limit_money) + "\r\n";
   AC_L1_BOARD_SECTION += "3% max DD guard:  " + AC_L1MoneyText(max_dd_limit_money) + "\r\n";
   AC_L1_BOARD_SECTION += "Trade Permission: FALSE\r\n";
   AC_L1_BOARD_SECTION += "\r\nL1 Warnings\r\n";
   AC_L1_BOARD_SECTION += "----------------------------------------\r\n";
   AC_L1_BOARD_SECTION += warning_text;

   if(ArraySize(AC_L1_POSITIONS) > 0)
   {
      AC_L1_BOARD_SECTION += "\r\nOpen Positions\r\n";
      AC_L1_BOARD_SECTION += "Time             Symbol        Side      Vol       Entry          SL          TP       P/L\r\n";
      for(int p = 0; p < ArraySize(AC_L1_POSITIONS) && p < 10; p++)
         AC_L1_BOARD_SECTION += AC_L1PositionLine(AC_L1_POSITIONS[p]) + "\r\n";
   }

   if(ArraySize(AC_L1_PENDING) > 0)
   {
      AC_L1_BOARD_SECTION += "\r\nPending Orders\r\n";
      AC_L1_BOARD_SECTION += "Time             Symbol        Type             Vol       Price          SL          TP\r\n";
      for(int o = 0; o < ArraySize(AC_L1_PENDING) && o < 10; o++)
         AC_L1_BOARD_SECTION += AC_L1PendingLine(AC_L1_PENDING[o]) + "\r\n";
   }

   AC_L1_BOARD_SECTION += "\r\nRecent Closed Trades - compact\r\n";
   AC_L1_BOARD_SECTION += "Time             Symbol        Side      Vol       Entry       Close       Net  Quality\r\n";
   int board_closed_limit = 25;
   int board_closed = 0;
   for(int c = 0; c < ArraySize(AC_L1_CLOSED) && board_closed < board_closed_limit; c++)
   {
      AC_L1_BOARD_SECTION += AC_L1ClosedTradeLine(AC_L1_CLOSED[c]) + "\r\n";
      board_closed++;
   }
   if(board_closed <= 0) AC_L1_BOARD_SECTION += "none\r\n";

   AC_L1_BOARD_SECTION += "\r\nCanceled / Rejected / Expired - summary only\r\n";
   AC_L1_BOARD_SECTION += "Total: " + IntegerToString(AC_L1_CANCEL_LIKE_ORDERS) + " | Full list in Account Status, not full Board.\r\n";

   AC_L1_WORKBENCH_SECTION = "L1_ACCOUNT_PORTFOLIO_SCAN\r\n";
   AC_L1_WORKBENCH_SECTION += "----------------------------------------\r\n";
   AC_L1_WORKBENCH_SECTION += "scan_status=" + AC_L1_SCAN_STATUS + "\r\n";
   AC_L1_WORKBENCH_SECTION += "scan_duration_ms=" + IntegerToString((int)AC_L1_SCAN_DURATION_MS) + "\r\n";
   AC_L1_WORKBENCH_SECTION += "history_status=" + AC_L1_HISTORY_STATUS + "\r\n";
   AC_L1_WORKBENCH_SECTION += "history_quality=" + AC_L1_HISTORY_QUALITY + "\r\n";
   AC_L1_WORKBENCH_SECTION += "history_note=" + AC_L1_HISTORY_NOTE + "\r\n";
   AC_L1_WORKBENCH_SECTION += "history_from=0\r\n";
   AC_L1_WORKBENCH_SECTION += "history_to=TimeCurrent_or_TimeGMT_fallback\r\n";
   AC_L1_WORKBENCH_SECTION += "report_compare_mode=not_strict_time_window_mismatch_unless_same_cutoff\r\n";
   AC_L1_WORKBENCH_SECTION += "history_deals_total=" + IntegerToString(AC_L1_HISTORY_DEALS_TOTAL) + "\r\n";
   AC_L1_WORKBENCH_SECTION += "history_orders_total=" + IntegerToString(AC_L1_HISTORY_ORDERS_TOTAL) + "\r\n";
   AC_L1_WORKBENCH_SECTION += "core_reconstruction_complete_count=" + IntegerToString(AC_L1_CORE_RECONSTRUCTION_COMPLETE_COUNT) + "\r\n";
   AC_L1_WORKBENCH_SECTION += "partial_reconstruction_count=" + IntegerToString(AC_L1_PARTIAL_RECONSTRUCTION_COUNT) + "\r\n";
   AC_L1_WORKBENCH_SECTION += "order_context_partial_count=" + IntegerToString(AC_L1_ORDER_CONTEXT_PARTIAL_COUNT) + "\r\n";
   AC_L1_WORKBENCH_SECTION += "duration_count=" + IntegerToString(AC_L1_DURATION_COUNT) + "\r\n";
   AC_L1_WORKBENCH_SECTION += "scan_failure=" + AC_L1_SCAN_FAILURE + "\r\n";

   AC_L1_ACCOUNT_STATUS_TEXT = "AURORA CORE - ACCOUNT STATUS\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "----------------------------------------\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "build_version=" + AC_BUILD_VERSION + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "upgrade_id=" + AC_UPGRADE_ID + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "runtime_owner=" + AC_RUNTIME1_OWNER + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "layer_status=" + (AC_L1_HISTORY_STATUS == "available" ? "complete_with_reconstruction_quality" : "partial") + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "history_quality=" + AC_L1_HISTORY_QUALITY + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "report_compare_mode=not_strict_time_window_mismatch_unless_same_cutoff\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "\r\nACCOUNT SUMMARY\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "----------------------------------------\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "Account=" + IntegerToString((int)AC_L1_LOGIN) + " server=" + AC_L1_SERVER + " mode=" + AC_L1_TRADE_MODE + " currency=" + AC_L1_CURRENCY + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "Balance=" + AC_L1MoneyText(AC_L1_BALANCE) + " Equity=" + AC_L1MoneyText(AC_L1_EQUITY) + " Floating=" + AC_L1MoneyText(AC_L1_FLOATING_PL) + " FreeMargin=" + AC_L1MoneyText(AC_L1_FREE_MARGIN) + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "Closed=" + IntegerToString(closed_count) + " Net=" + AC_L1MoneyText(AC_L1_NET_PROFIT) + " PF=" + DoubleToString(profit_factor, 2) + " WinRate=" + AC_L1PercentText(win_rate) + " ExpectedPayoff=" + AC_L1MoneyText(expected_payoff) + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "BestSymbol=" + AC_L1_BEST_SYMBOL + " " + AC_L1MoneyText(AC_L1_BEST_SYMBOL_NET) + " WorstSymbol=" + AC_L1_WORST_SYMBOL + " " + AC_L1MoneyText(AC_L1_WORST_SYMBOL_NET) + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "BestDay=" + AC_L1_BEST_DAY + " " + AC_L1MoneyText(AC_L1_BEST_DAY_NET) + " WorstDay=" + AC_L1_WORST_DAY + " " + AC_L1MoneyText(AC_L1_WORST_DAY_NET) + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "CoreReconComplete=" + IntegerToString(AC_L1_CORE_RECONSTRUCTION_COMPLETE_COUNT) + " PartialCore=" + IntegerToString(AC_L1_PARTIAL_RECONSTRUCTION_COUNT) + " OrderContextPartial=" + IntegerToString(AC_L1_ORDER_CONTEXT_PARTIAL_COUNT) + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "HistoryNote=" + AC_L1_HISTORY_NOTE + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "\r\nOpen Positions - Full\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "Time             Symbol        Side      Vol       Entry          SL          TP       P/L\r\n";
   for(int fp = 0; fp < ArraySize(AC_L1_POSITIONS); fp++) AC_L1_ACCOUNT_STATUS_TEXT += AC_L1PositionLine(AC_L1_POSITIONS[fp]) + "\r\n";
   if(ArraySize(AC_L1_POSITIONS) <= 0) AC_L1_ACCOUNT_STATUS_TEXT += "none\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "\r\nPending Orders - Full\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "Time             Symbol        Type             Vol       Price          SL          TP\r\n";
   for(int fo = 0; fo < ArraySize(AC_L1_PENDING); fo++) AC_L1_ACCOUNT_STATUS_TEXT += AC_L1PendingLine(AC_L1_PENDING[fo]) + "\r\n";
   if(ArraySize(AC_L1_PENDING) <= 0) AC_L1_ACCOUNT_STATUS_TEXT += "none\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "\r\nClosed Trade History - Full\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "Time             Symbol        Side      Vol       Entry       Close       Net  Quality | Cost/Core/Order Context\r\n";
   for(int fc = 0; fc < ArraySize(AC_L1_CLOSED); fc++) AC_L1_ACCOUNT_STATUS_TEXT += AC_L1ClosedTradeDetailLine(AC_L1_CLOSED[fc]) + "\r\n";
   if(ArraySize(AC_L1_CLOSED) <= 0) AC_L1_ACCOUNT_STATUS_TEXT += "none\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "\r\nCanceled / Rejected / Expired Orders - Full\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "Time             Symbol        Type           State        Vol       Price\r\n";
   for(int x = 0; x < ArraySize(AC_L1_CANCELS); x++) AC_L1_ACCOUNT_STATUS_TEXT += AC_L1CancelLine(AC_L1_CANCELS[x]) + "\r\n";
   if(ArraySize(AC_L1_CANCELS) <= 0) AC_L1_ACCOUNT_STATUS_TEXT += "none\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "\r\n" + AC_L1SymbolSummaryTable() + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += AC_L1DaySummaryTable() + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "Direction Summary\r\n----------------------------------------\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "Buy trades=" + IntegerToString(AC_L1_BUY_COUNT) + " net=" + AC_L1MoneyText(AC_L1_BUY_NET) + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "Sell trades=" + IntegerToString(AC_L1_SELL_COUNT) + " net=" + AC_L1MoneyText(AC_L1_SELL_NET) + "\r\n";
}

string AC_Layer1BoardSection()
{
   if(!AC_L1_READY) return "\r\nLAYER 1 - ACCOUNT / PORTFOLIO\r\n----------------------------------------\r\nstatus=pending\r\n";
   return AC_L1_BOARD_SECTION;
}

string AC_Layer1WorkbenchSection()
{
   if(!AC_L1_READY) return "L1_ACCOUNT_PORTFOLIO_SCAN\r\nstatus=pending\r\n";
   return AC_L1_WORKBENCH_SECTION;
}

string AC_Layer1DossierSection(const string symbol)
{
   string text = "\r\nLAYER 1 - ACCOUNT / PORTFOLIO CONTEXT\r\n";
   text += "----------------------------------------\r\n";
   text += "account_balance=" + AC_L1MoneyText(AC_L1_BALANCE) + "\r\n";
   text += "account_equity=" + AC_L1MoneyText(AC_L1_EQUITY) + "\r\n";
   text += "floating_pl=" + AC_L1MoneyText(AC_L1_FLOATING_PL) + "\r\n";
   text += "trade_permission=false\r\n";

   int stats = -1;
   for(int i = 0; i < ArraySize(AC_L1_SYMBOL_STATS); i++)
      if(AC_L1_SYMBOL_STATS[i].symbol == symbol) { stats = i; break; }

   if(stats < 0)
   {
      text += "symbol_account_state=no_account_activity_found\r\n";
      return text;
   }

   double symbol_win_rate = (AC_L1_SYMBOL_STATS[stats].closed_count > 0 ? ((double)AC_L1_SYMBOL_STATS[stats].win_count * 100.0) / AC_L1_SYMBOL_STATS[stats].closed_count : 0.0);
   text += "symbol_account_state=" + ((AC_L1_SYMBOL_STATS[stats].open_count > 0) ? "open_position" : ((AC_L1_SYMBOL_STATS[stats].pending_count > 0) ? "pending_order" : "history_only")) + "\r\n";
   text += "open_position_count=" + IntegerToString(AC_L1_SYMBOL_STATS[stats].open_count) + "\r\n";
   text += "pending_order_count=" + IntegerToString(AC_L1_SYMBOL_STATS[stats].pending_count) + "\r\n";
   text += "closed_trades=" + IntegerToString(AC_L1_SYMBOL_STATS[stats].closed_count) + "\r\n";
   text += "canceled_orders=" + IntegerToString(AC_L1_SYMBOL_STATS[stats].canceled_count) + "\r\n";
   text += "symbol_net_pl=" + AC_L1MoneyText(AC_L1_SYMBOL_STATS[stats].net_result) + "\r\n";
   text += "symbol_win_rate=" + AC_L1PercentText(symbol_win_rate) + "\r\n";

   text += "\r\nSymbol Closed Trades\r\n";
   text += "Time             Symbol        Side      Vol       Entry       Close       Net  Quality\r\n";
   int shown = 0;
   for(int c = 0; c < ArraySize(AC_L1_CLOSED) && shown < AC_DOSSIER_SYMBOL_ACTIVITY_MAX_ROWS; c++)
   {
      if(AC_L1_CLOSED[c].symbol != symbol) continue;
      text += AC_L1ClosedTradeLine(AC_L1_CLOSED[c]) + "\r\n";
      shown++;
   }
   if(shown <= 0) text += "none\r\n";

   text += "\r\nSymbol Canceled / Rejected / Expired Orders\r\n";
   text += "Time             Symbol        Type           State        Vol       Price\r\n";
   int shown_cancel = 0;
   for(int k = 0; k < ArraySize(AC_L1_CANCELS) && shown_cancel < AC_DOSSIER_SYMBOL_ACTIVITY_MAX_ROWS; k++)
   {
      if(AC_L1_CANCELS[k].symbol != symbol) continue;
      text += AC_L1CancelLine(AC_L1_CANCELS[k]) + "\r\n";
      shown_cancel++;
   }
   if(shown_cancel <= 0) text += "none\r\n";

   return text;
}

string AC_AccountTruthText()
{
   if(!AC_L1_READY) AC_RefreshLayer1AccountTruth();
   return AC_L1_ACCOUNT_STATUS_TEXT;
}

string AC_AccountTruthStatusRow(const AC_WriteResult &account_write)
{
   return "schema_name=layer_status|schema_version=v1.3|layer_id=1|layer_name=" + AC_LAYER_1_NAME
      + "|source_owner=" + AC_RUNTIME1_OWNER
      + "|build_version=" + AC_BUILD_VERSION
      + "|upgrade_id=" + AC_UPGRADE_ID
      + "|layer_status=" + (AC_L1_READY && account_write.ok ? "complete_with_reconstruction_quality" : "partial")
      + "|account_status_available=" + AC_BoolText(account_write.ok)
      + "|closed_trades=" + IntegerToString(ArraySize(AC_L1_CLOSED))
      + "|canceled_orders=" + IntegerToString(AC_L1_CANCEL_LIKE_ORDERS)
      + "|history_deals_total=" + IntegerToString(AC_L1_HISTORY_DEALS_TOTAL)
      + "|history_orders_total=" + IntegerToString(AC_L1_HISTORY_ORDERS_TOTAL)
      + "|history_quality=" + AC_L1_HISTORY_QUALITY
      + "|core_reconstruction_complete=" + IntegerToString(AC_L1_CORE_RECONSTRUCTION_COMPLETE_COUNT)
      + "|partial_core_reconstruction=" + IntegerToString(AC_L1_PARTIAL_RECONSTRUCTION_COUNT)
      + "|order_context_partial=" + IntegerToString(AC_L1_ORDER_CONTEXT_PARTIAL_COUNT)
      + "|scan_status=" + AC_L1_SCAN_STATUS
      + "|trade_permission=false";
}

#endif