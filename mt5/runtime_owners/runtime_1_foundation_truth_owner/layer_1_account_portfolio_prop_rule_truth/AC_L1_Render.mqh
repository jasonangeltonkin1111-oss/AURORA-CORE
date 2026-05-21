#ifndef AC_L1_RENDER_MQH
#define AC_L1_RENDER_MQH

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

   AC_L1_BOARD_SECTION = "\r\nLAYER 1 - ACCOUNT / PORTFOLIO\r\n";
   AC_L1_BOARD_SECTION += "----------------------------------------\r\n";
   AC_L1_BOARD_SECTION += "Account:          " + IntegerToString((int)AC_L1_LOGIN) + " / " + AC_L1_SERVER + "\r\n";
   AC_L1_BOARD_SECTION += "Currency:         " + AC_L1_CURRENCY + "\r\n";
   AC_L1_BOARD_SECTION += "Mode:             " + AC_L1_TRADE_MODE + "\r\n";
   AC_L1_BOARD_SECTION += "Leverage:         1:" + IntegerToString((int)AC_L1_LEVERAGE) + "\r\n";
   AC_L1_BOARD_SECTION += "Balance:          " + AC_L1MoneyText(AC_L1_BALANCE) + "\r\n";
   AC_L1_BOARD_SECTION += "Equity:           " + AC_L1MoneyText(AC_L1_EQUITY) + "\r\n";
   AC_L1_BOARD_SECTION += "Floating P/L:     " + AC_L1MoneyText(AC_L1_FLOATING_PL) + "\r\n";
   AC_L1_BOARD_SECTION += "Margin Used:      " + AC_L1MoneyText(AC_L1_MARGIN) + "\r\n";
   AC_L1_BOARD_SECTION += "Free Margin:      " + AC_L1MoneyText(AC_L1_FREE_MARGIN) + "\r\n";
   AC_L1_BOARD_SECTION += "Open Positions:   " + IntegerToString(ArraySize(AC_L1_POSITIONS)) + "\r\n";
   AC_L1_BOARD_SECTION += "Pending Orders:   " + IntegerToString(ArraySize(AC_L1_PENDING)) + "\r\n";
   AC_L1_BOARD_SECTION += "\r\nHistory Summary\r\n";
   AC_L1_BOARD_SECTION += "Closed Trades:    " + IntegerToString(closed_count) + "\r\n";
   AC_L1_BOARD_SECTION += "Net P/L:          " + AC_L1MoneyText(AC_L1_NET_PROFIT) + "\r\n";
   AC_L1_BOARD_SECTION += "Gross Profit:     " + AC_L1MoneyText(AC_L1_GROSS_PROFIT) + "\r\n";
   AC_L1_BOARD_SECTION += "Gross Loss:       " + AC_L1MoneyText(AC_L1_GROSS_LOSS) + "\r\n";
   AC_L1_BOARD_SECTION += "Profit Factor:    " + DoubleToString(profit_factor, 2) + "\r\n";
   AC_L1_BOARD_SECTION += "Expected Payoff:  " + AC_L1MoneyText(expected_payoff) + "\r\n";
   AC_L1_BOARD_SECTION += "Win Rate:         " + AC_L1PercentText(win_rate) + "\r\n";
   AC_L1_BOARD_SECTION += "Avg Win:          " + AC_L1MoneyText(avg_win) + "\r\n";
   AC_L1_BOARD_SECTION += "Avg Loss:         " + AC_L1MoneyText(avg_loss) + "\r\n";
   AC_L1_BOARD_SECTION += "Largest Win:      " + AC_L1MoneyText(AC_L1_LARGEST_WIN) + "\r\n";
   AC_L1_BOARD_SECTION += "Largest Loss:     " + AC_L1MoneyText(AC_L1_LARGEST_LOSS) + "\r\n";
   AC_L1_BOARD_SECTION += "Canceled Orders:  " + IntegerToString(AC_L1_CANCEL_LIKE_ORDERS) + "\r\n";
   AC_L1_BOARD_SECTION += "Worst Symbol:     " + AC_L1_WORST_SYMBOL + " " + AC_L1MoneyText(AC_L1_WORST_SYMBOL_NET) + "\r\n";
   AC_L1_BOARD_SECTION += "Worst Day:        " + AC_L1_WORST_DAY + " " + AC_L1MoneyText(AC_L1_WORST_DAY_NET) + "\r\n";
   AC_L1_BOARD_SECTION += "History Quality:  " + AC_L1_HISTORY_QUALITY + "\r\n";
   AC_L1_BOARD_SECTION += "Trade Permission: FALSE\r\n";

   if(ArraySize(AC_L1_POSITIONS) > 0)
   {
      AC_L1_BOARD_SECTION += "\r\nOpen Positions\r\n";
      AC_L1_BOARD_SECTION += "Time             Symbol        Side      Vol       Entry          SL          TP       P/L\r\n";
      for(int p = 0; p < ArraySize(AC_L1_POSITIONS) && AC_L1_RECENT_BOARD_ROWS < AC_BOARD_RECENT_ACTIVITY_MAX_ROWS; p++, AC_L1_RECENT_BOARD_ROWS++)
         AC_L1_BOARD_SECTION += AC_L1PositionLine(AC_L1_POSITIONS[p]) + "\r\n";
   }

   if(ArraySize(AC_L1_PENDING) > 0)
   {
      AC_L1_BOARD_SECTION += "\r\nPending Orders\r\n";
      AC_L1_BOARD_SECTION += "Time             Symbol        Type             Vol       Price          SL          TP\r\n";
      for(int o = 0; o < ArraySize(AC_L1_PENDING) && AC_L1_RECENT_BOARD_ROWS < AC_BOARD_RECENT_ACTIVITY_MAX_ROWS; o++, AC_L1_RECENT_BOARD_ROWS++)
         AC_L1_BOARD_SECTION += AC_L1PendingLine(AC_L1_PENDING[o]) + "\r\n";
   }

   AC_L1_BOARD_SECTION += "\r\nRecent Closed Trades\r\n";
   AC_L1_BOARD_SECTION += "Time             Symbol        Side      Vol       Entry       Close       Net  Quality\r\n";
   int board_closed = 0;
   for(int c = 0; c < ArraySize(AC_L1_CLOSED) && AC_L1_RECENT_BOARD_ROWS < AC_BOARD_RECENT_ACTIVITY_MAX_ROWS; c++)
   {
      AC_L1_BOARD_SECTION += AC_L1ClosedTradeLine(AC_L1_CLOSED[c]) + "\r\n";
      AC_L1_RECENT_BOARD_ROWS++;
      board_closed++;
   }
   if(board_closed <= 0) AC_L1_BOARD_SECTION += "none\r\n";

   AC_L1_BOARD_SECTION += "\r\nRecent Canceled / Rejected / Expired Orders - capped\r\n";
   AC_L1_BOARD_SECTION += "Time             Symbol        Type           State        Vol       Price\r\n";
   int cancel_limit = AC_BOARD_CANCELED_ACTIVITY_MAX_ROWS;
   int shown_cancel = 0;
   for(int k = 0; k < ArraySize(AC_L1_CANCELS) && shown_cancel < cancel_limit && AC_L1_RECENT_BOARD_ROWS < AC_BOARD_RECENT_ACTIVITY_MAX_ROWS; k++)
   {
      AC_L1_BOARD_SECTION += AC_L1CancelLine(AC_L1_CANCELS[k]) + "\r\n";
      AC_L1_RECENT_BOARD_ROWS++;
      shown_cancel++;
   }
   if(shown_cancel <= 0) AC_L1_BOARD_SECTION += "none\r\n";

   AC_L1_WORKBENCH_SECTION = "L1_ACCOUNT_PORTFOLIO_SCAN\r\n";
   AC_L1_WORKBENCH_SECTION += "----------------------------------------\r\n";
   AC_L1_WORKBENCH_SECTION += "scan_status=" + AC_L1_SCAN_STATUS + "\r\n";
   AC_L1_WORKBENCH_SECTION += "scan_duration_ms=" + IntegerToString((int)AC_L1_SCAN_DURATION_MS) + "\r\n";
   AC_L1_WORKBENCH_SECTION += "history_status=" + AC_L1_HISTORY_STATUS + "\r\n";
   AC_L1_WORKBENCH_SECTION += "history_quality=" + AC_L1_HISTORY_QUALITY + "\r\n";
   AC_L1_WORKBENCH_SECTION += "history_note=" + AC_L1_HISTORY_NOTE + "\r\n";
   AC_L1_WORKBENCH_SECTION += "history_deals_total=" + IntegerToString(AC_L1_HISTORY_DEALS_TOTAL) + "\r\n";
   AC_L1_WORKBENCH_SECTION += "history_orders_total=" + IntegerToString(AC_L1_HISTORY_ORDERS_TOTAL) + "\r\n";
   AC_L1_WORKBENCH_SECTION += "partial_reconstruction_count=" + IntegerToString(AC_L1_PARTIAL_RECONSTRUCTION_COUNT) + "\r\n";
   AC_L1_WORKBENCH_SECTION += "scan_failure=" + AC_L1_SCAN_FAILURE + "\r\n";

   AC_L1_ACCOUNT_STATUS_TEXT = "AURORA CORE - ACCOUNT STATUS\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "----------------------------------------\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "build_version=" + AC_BUILD_VERSION + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "upgrade_id=" + AC_UPGRADE_ID + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "runtime_owner=" + AC_RUNTIME1_OWNER + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "layer_status=" + (AC_L1_HISTORY_STATUS == "available" ? "complete_with_reconstruction_quality" : "partial") + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "history_quality=" + AC_L1_HISTORY_QUALITY + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += AC_L1_BOARD_SECTION + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "\r\nClosed Trade History - Full\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "Time             Symbol        Side      Vol       Entry       Close       Net  Quality\r\n";
   for(int fc = 0; fc < ArraySize(AC_L1_CLOSED); fc++) AC_L1_ACCOUNT_STATUS_TEXT += AC_L1ClosedTradeLine(AC_L1_CLOSED[fc]) + "\r\n";
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
   return "schema_name=layer_status|schema_version=v1.1|layer_id=1|layer_name=" + AC_LAYER_1_NAME
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
      + "|scan_status=" + AC_L1_SCAN_STATUS
      + "|trade_permission=false";
}

#endif