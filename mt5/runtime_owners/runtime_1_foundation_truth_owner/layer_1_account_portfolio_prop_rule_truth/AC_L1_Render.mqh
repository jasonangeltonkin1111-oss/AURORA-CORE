#ifndef AC_L1_RENDER_MQH
#define AC_L1_RENDER_MQH

#define AC_L1_ACCOUNT_STATUS_TRADE_ROW_LIMIT 100
#define AC_L1_ACCOUNT_STATUS_HISTORY_DAYS 90

string AC_L1TitleText(string value)
{
   StringReplace(value, "_", " ");
   return value;
}

long AC_L1TradeDurationSeconds(const AC_L1ClosedTradeRow &row)
{
   if(row.entry_time <= 0 || row.close_time <= row.entry_time) return 0;
   return (long)(row.close_time - row.entry_time);
}

string AC_L1DurationText(const long seconds)
{
   if(seconds <= 0) return "n/a";
   long minutes = seconds / 60;
   long hours = minutes / 60;
   long days = hours / 24;
   if(days > 0) return IntegerToString((int)days) + "d " + IntegerToString((int)(hours % 24)) + "h";
   if(hours > 0) return IntegerToString((int)hours) + "h " + IntegerToString((int)(minutes % 60)) + "m";
   return IntegerToString((int)minutes) + "m";
}

string AC_L1TradeResultText(const AC_L1ClosedTradeRow &row)
{
   if(row.net_result > 0.0) return "Win";
   if(row.net_result < 0.0) return "Loss";
   return "Flat";
}

string AC_L1ClosedTradeLine(const AC_L1ClosedTradeRow &row)
{
   return AC_L1PadRight(AC_L1ShortTimeText(row.close_time), 17)
      + AC_L1PadRight(row.symbol, 12)
      + AC_L1PadRight(row.side, 6)
      + AC_L1PadLeft(AC_L1VolumeText(row.volume), 7)
      + AC_L1PadLeft(AC_L1PriceText(row.entry_price), 11)
      + AC_L1PadLeft(AC_L1PriceText(row.close_price), 11)
      + AC_L1PadLeft(AC_L1MoneyText(row.net_result), 10)
      + AC_L1PadLeft(AC_L1DurationText(AC_L1TradeDurationSeconds(row)), 9)
      + "  " + AC_L1TradeResultText(row);
}

string AC_L1ClosedTradeDetailLine(const AC_L1ClosedTradeRow &row)
{
   return AC_L1ClosedTradeLine(row)
      + " | Commission " + AC_L1MoneyText(row.commission)
      + " | Swap " + AC_L1MoneyText(row.swap)
      + " | Fee " + AC_L1MoneyText(row.fee)
      + " | SL " + AC_L1PriceText(row.stop_loss)
      + " | TP " + AC_L1PriceText(row.take_profit);
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
   string text = "Symbol Performance\r\n";
   text += "----------------------------------------\r\n";
   text += AC_L1PadRight("Symbol", 14) + AC_L1PadLeft("Trades", 8) + AC_L1PadLeft("Wins", 7) + AC_L1PadLeft("Losses", 8) + AC_L1PadLeft("Win %", 8) + AC_L1PadLeft("Net", 12) + "\r\n";
   for(int i = 0; i < ArraySize(AC_L1_SYMBOL_STATS); i++)
   {
      if(AC_L1_SYMBOL_STATS[i].closed_count <= 0 && AC_L1_SYMBOL_STATS[i].open_count <= 0 && AC_L1_SYMBOL_STATS[i].pending_count <= 0 && AC_L1_SYMBOL_STATS[i].canceled_count <= 0)
         continue;
      double wr = (AC_L1_SYMBOL_STATS[i].closed_count > 0 ? ((double)AC_L1_SYMBOL_STATS[i].win_count * 100.0) / AC_L1_SYMBOL_STATS[i].closed_count : 0.0);
      text += AC_L1PadRight(AC_L1_SYMBOL_STATS[i].symbol, 14)
         + AC_L1PadLeft(IntegerToString(AC_L1_SYMBOL_STATS[i].closed_count), 8)
         + AC_L1PadLeft(IntegerToString(AC_L1_SYMBOL_STATS[i].win_count), 7)
         + AC_L1PadLeft(IntegerToString(AC_L1_SYMBOL_STATS[i].loss_count), 8)
         + AC_L1PadLeft(AC_L1PercentText(wr), 8)
         + AC_L1PadLeft(AC_L1MoneyText(AC_L1_SYMBOL_STATS[i].net_result), 12)
         + "\r\n";
   }
   return text;
}

string AC_L1DaySummaryTable()
{
   string text = "Daily Performance\r\n";
   text += "----------------------------------------\r\n";
   text += AC_L1PadRight("Day", 14) + AC_L1PadLeft("Trades", 8) + AC_L1PadLeft("Net", 12) + "\r\n";
   for(int i = 0; i < ArraySize(AC_L1_DAY_STATS); i++)
   {
      text += AC_L1PadRight(AC_L1_DAY_STATS[i].day, 14)
         + AC_L1PadLeft(IntegerToString(AC_L1_DAY_STATS[i].closed_count), 8)
         + AC_L1PadLeft(AC_L1MoneyText(AC_L1_DAY_STATS[i].net_result), 12)
         + "\r\n";
   }
   return text;
}

datetime AC_L1AccountStatusHistoryCutoff()
{
   datetime now_time = TimeCurrent();
   if(now_time <= 0) now_time = TimeGMT();
   if(now_time <= 0) return 0;
   return (datetime)(now_time - (AC_L1_ACCOUNT_STATUS_HISTORY_DAYS * 86400));
}

bool AC_L1ClosedRowInsideAccountStatusWindow(const AC_L1ClosedTradeRow &row,
                                             const datetime cutoff_time,
                                             const int shown_count)
{
   if(shown_count >= AC_L1_ACCOUNT_STATUS_TRADE_ROW_LIMIT) return false;
   if(cutoff_time > 0 && row.close_time > 0 && row.close_time < cutoff_time) return false;
   return true;
}

bool AC_L1CancelRowInsideAccountStatusWindow(const AC_L1OrderEventRow &row,
                                             const datetime cutoff_time,
                                             const int shown_count)
{
   if(shown_count >= AC_L1_ACCOUNT_STATUS_TRADE_ROW_LIMIT) return false;
   datetime event_time = row.done_time;
   if(event_time <= 0) event_time = row.setup_time;
   if(cutoff_time > 0 && event_time > 0 && event_time < cutoff_time) return false;
   return true;
}

void AC_L1ComputeReportStats(int &win_count,
                             int &loss_count,
                             int &short_count,
                             int &short_wins,
                             int &long_count,
                             int &long_wins,
                             int &max_win_streak,
                             int &max_loss_streak,
                             double &max_win_streak_money,
                             double &max_loss_streak_money,
                             double &balance_drawdown_absolute,
                             double &balance_drawdown_maximal,
                             double &balance_drawdown_relative_pct,
                             double &average_consecutive_wins,
                             double &average_consecutive_losses)
{
   win_count = 0;
   loss_count = 0;
   short_count = 0;
   short_wins = 0;
   long_count = 0;
   long_wins = 0;
   max_win_streak = 0;
   max_loss_streak = 0;
   max_win_streak_money = 0.0;
   max_loss_streak_money = 0.0;
   balance_drawdown_absolute = 0.0;
   balance_drawdown_maximal = 0.0;
   balance_drawdown_relative_pct = 0.0;
   average_consecutive_wins = 0.0;
   average_consecutive_losses = 0.0;

   double start_balance = AC_L1_BALANCE - AC_L1_NET_PROFIT;
   double curve = start_balance;
   double peak = curve;
   int current_win_streak = 0;
   int current_loss_streak = 0;
   double current_win_money = 0.0;
   double current_loss_money = 0.0;
   int win_groups = 0;
   int loss_groups = 0;
   int win_streak_total = 0;
   int loss_streak_total = 0;
   bool in_win_group = false;
   bool in_loss_group = false;

   for(int i = ArraySize(AC_L1_CLOSED) - 1; i >= 0; i--)
   {
      AC_L1ClosedTradeRow row = AC_L1_CLOSED[i];
      if(row.side == "sell") short_count++;
      if(row.side == "buy") long_count++;

      curve += row.net_result;
      if(curve > peak) peak = curve;
      double dd = peak - curve;
      if(dd > balance_drawdown_maximal) balance_drawdown_maximal = dd;
      if(peak > 0.0)
      {
         double dd_pct = (dd / peak) * 100.0;
         if(dd_pct > balance_drawdown_relative_pct) balance_drawdown_relative_pct = dd_pct;
      }

      if(row.net_result > 0.0)
      {
         win_count++;
         if(row.side == "sell") short_wins++;
         if(row.side == "buy") long_wins++;
         if(!in_win_group) { win_groups++; in_win_group = true; }
         in_loss_group = false;
         current_win_streak++;
         current_win_money += row.net_result;
         if(current_loss_streak > 0)
         {
            loss_streak_total += current_loss_streak;
            current_loss_streak = 0;
            current_loss_money = 0.0;
         }
         if(current_win_streak > max_win_streak || (current_win_streak == max_win_streak && current_win_money > max_win_streak_money))
         {
            max_win_streak = current_win_streak;
            max_win_streak_money = current_win_money;
         }
      }
      else if(row.net_result < 0.0)
      {
         loss_count++;
         if(!in_loss_group) { loss_groups++; in_loss_group = true; }
         in_win_group = false;
         current_loss_streak++;
         current_loss_money += row.net_result;
         if(current_win_streak > 0)
         {
            win_streak_total += current_win_streak;
            current_win_streak = 0;
            current_win_money = 0.0;
         }
         if(current_loss_streak > max_loss_streak || (current_loss_streak == max_loss_streak && current_loss_money < max_loss_streak_money))
         {
            max_loss_streak = current_loss_streak;
            max_loss_streak_money = current_loss_money;
         }
      }
   }

   if(current_win_streak > 0) win_streak_total += current_win_streak;
   if(current_loss_streak > 0) loss_streak_total += current_loss_streak;
   average_consecutive_wins = (win_groups > 0 ? (double)win_streak_total / win_groups : 0.0);
   average_consecutive_losses = (loss_groups > 0 ? (double)loss_streak_total / loss_groups : 0.0);
   balance_drawdown_absolute = balance_drawdown_maximal;
}

void AC_BuildLayer1Texts()
{
   int closed_count = ArraySize(AC_L1_CLOSED);
   int win_count = 0;
   int loss_count = 0;
   int short_count = 0;
   int short_wins = 0;
   int long_count = 0;
   int long_wins = 0;
   int max_win_streak = 0;
   int max_loss_streak = 0;
   double max_win_streak_money = 0.0;
   double max_loss_streak_money = 0.0;
   double balance_drawdown_absolute = 0.0;
   double balance_drawdown_maximal = 0.0;
   double balance_drawdown_relative_pct = 0.0;
   double avg_consecutive_wins = 0.0;
   double avg_consecutive_losses = 0.0;
   AC_L1ComputeReportStats(win_count, loss_count, short_count, short_wins, long_count, long_wins, max_win_streak, max_loss_streak, max_win_streak_money, max_loss_streak_money, balance_drawdown_absolute, balance_drawdown_maximal, balance_drawdown_relative_pct, avg_consecutive_wins, avg_consecutive_losses);

   double profit_factor = (AC_L1_GROSS_LOSS < 0.0 ? AC_L1_GROSS_PROFIT / MathAbs(AC_L1_GROSS_LOSS) : 0.0);
   double expected_payoff = (closed_count > 0 ? AC_L1_NET_PROFIT / closed_count : 0.0);
   double win_rate = (closed_count > 0 ? ((double)win_count * 100.0) / closed_count : 0.0);
   double loss_rate = (closed_count > 0 ? ((double)loss_count * 100.0) / closed_count : 0.0);
   double short_win_rate = (short_count > 0 ? ((double)short_wins * 100.0) / short_count : 0.0);
   double long_win_rate = (long_count > 0 ? ((double)long_wins * 100.0) / long_count : 0.0);
   double avg_win = (win_count > 0 ? AC_L1_GROSS_PROFIT / win_count : 0.0);
   double avg_loss = (loss_count > 0 ? AC_L1_GROSS_LOSS / loss_count : 0.0);
   double avg_duration_seconds = (AC_L1_DURATION_COUNT > 0 ? ((double)AC_L1_DURATION_SUM_SECONDS / AC_L1_DURATION_COUNT) : 0.0);
   double start_balance_estimate = AC_L1_BALANCE - AC_L1_NET_PROFIT;
   double realized_return_pct = (start_balance_estimate > 0.0 ? (AC_L1_NET_PROFIT / start_balance_estimate) * 100.0 : 0.0);
   double current_dd_money = MathMax(0.0, AC_L1_BALANCE - AC_L1_EQUITY);
   double current_dd_pct = (AC_L1_BALANCE > 0.0 ? (current_dd_money / AC_L1_BALANCE) * 100.0 : 0.0);
   double equity_cushion_money = MathMax(0.0, AC_L1_EQUITY - AC_L1_BALANCE);
   double daily_dd_limit_money = AC_L1_EQUITY * 0.01;
   double max_dd_limit_money = AC_L1_EQUITY * 0.03;
   double default_risk_money = AC_L1_EQUITY * 0.001;
   double hard_risk_money = AC_L1_EQUITY * 0.002;
   double max_open_risk_money = AC_L1_EQUITY * 0.01;
   double open_profit_pct = (AC_L1_EQUITY > 0.0 ? (AC_L1_FLOATING_PL / AC_L1_EQUITY) * 100.0 : 0.0);
   double largest_loss_vs_hard_risk = (hard_risk_money > 0.0 && AC_L1_LARGEST_LOSS < 0.0 ? MathAbs(AC_L1_LARGEST_LOSS) / hard_risk_money : 0.0);
   datetime account_status_cutoff = AC_L1AccountStatusHistoryCutoff();
   string account_status_cutoff_text = (account_status_cutoff > 0 ? AC_L1TimeText(account_status_cutoff) : "unavailable");
   string account_health = "Needs validation";
   if(closed_count > 0 && profit_factor < 1.0) account_health = "Negative expectancy until proven otherwise";
   if(closed_count > 0 && profit_factor >= 1.0 && win_rate >= 50.0) account_health = "Positive history, not edge proof";

   string warning_text = "";
   if(closed_count <= 0) warning_text += "- No closed-trade sample yet; history cannot assess expectancy.\r\n";
   if(closed_count > 0 && profit_factor < 1.0) warning_text += "- Profit factor below 1.0: negative expectancy until proven otherwise.\r\n";
   if(closed_count > 0 && expected_payoff < 0.0) warning_text += "- Expected payoff is negative.\r\n";
   if(closed_count > 0 && win_rate < 45.0) warning_text += "- Win rate is weak for current history sample.\r\n";
   if(largest_loss_vs_hard_risk > 1.0) warning_text += "- Largest historical loss exceeds the 0.2% hard-risk amount.\r\n";
   if(warning_text == "") warning_text = "- No Layer 1 risk warning triggered. This is account supervision, not edge proof.\r\n";

   AC_L1_BOARD_SECTION = "\r\nLAYER 1 - ACCOUNT AND PORTFOLIO\r\n";
   AC_L1_BOARD_SECTION += "----------------------------------------\r\n";
   AC_L1_BOARD_SECTION += "Account:             " + IntegerToString((int)AC_L1_LOGIN) + " / " + AC_L1_SERVER + "\r\n";
   AC_L1_BOARD_SECTION += "Mode / Currency:     " + AC_L1_TRADE_MODE + " / " + AC_L1_CURRENCY + "\r\n";
   AC_L1_BOARD_SECTION += "Balance / Equity:    " + AC_L1MoneyText(AC_L1_BALANCE) + " / " + AC_L1MoneyText(AC_L1_EQUITY) + "\r\n";
   AC_L1_BOARD_SECTION += "Floating P/L:        " + AC_L1MoneyText(AC_L1_FLOATING_PL) + " (" + AC_L1PercentText(open_profit_pct) + ")\r\n";
   AC_L1_BOARD_SECTION += "Current Drawdown:    " + AC_L1MoneyText(current_dd_money) + " (" + AC_L1PercentText(current_dd_pct) + ")\r\n";
   if(equity_cushion_money > 0.0) AC_L1_BOARD_SECTION += "Equity Cushion:      " + AC_L1MoneyText(equity_cushion_money) + "\r\n";
   AC_L1_BOARD_SECTION += "Free Margin:         " + AC_L1MoneyText(AC_L1_FREE_MARGIN) + "\r\n";
   AC_L1_BOARD_SECTION += "Open / Pending:      " + IntegerToString(ArraySize(AC_L1_POSITIONS)) + " / " + IntegerToString(ArraySize(AC_L1_PENDING)) + "\r\n";
   AC_L1_BOARD_SECTION += "\r\nMT5-Style Results\r\n";
   AC_L1_BOARD_SECTION += "Total Net Profit:    " + AC_L1MoneyText(AC_L1_NET_PROFIT) + "\r\n";
   AC_L1_BOARD_SECTION += "Gross Profit / Loss: " + AC_L1MoneyText(AC_L1_GROSS_PROFIT) + " / " + AC_L1MoneyText(AC_L1_GROSS_LOSS) + "\r\n";
   AC_L1_BOARD_SECTION += "Profit Factor:       " + DoubleToString(profit_factor, 2) + "\r\n";
   AC_L1_BOARD_SECTION += "Expected Payoff:     " + AC_L1MoneyText(expected_payoff) + "\r\n";
   AC_L1_BOARD_SECTION += "Balance Drawdown:    " + AC_L1MoneyText(balance_drawdown_absolute) + " | Max " + AC_L1MoneyText(balance_drawdown_maximal) + " (" + AC_L1PercentText(balance_drawdown_relative_pct) + ")\r\n";
   AC_L1_BOARD_SECTION += "Total Trades:        " + IntegerToString(closed_count) + "\r\n";
   AC_L1_BOARD_SECTION += "Profit Trades:       " + IntegerToString(win_count) + " (" + AC_L1PercentText(win_rate) + ")\r\n";
   AC_L1_BOARD_SECTION += "Loss Trades:         " + IntegerToString(loss_count) + " (" + AC_L1PercentText(loss_rate) + ")\r\n";
   AC_L1_BOARD_SECTION += "Short / Long Trades: " + IntegerToString(short_count) + " (" + AC_L1PercentText(short_win_rate) + " won) / " + IntegerToString(long_count) + " (" + AC_L1PercentText(long_win_rate) + " won)\r\n";
   AC_L1_BOARD_SECTION += "Largest Win / Loss:  " + AC_L1MoneyText(AC_L1_LARGEST_WIN) + " / " + AC_L1MoneyText(AC_L1_LARGEST_LOSS) + "\r\n";
   AC_L1_BOARD_SECTION += "Average Win / Loss:  " + AC_L1MoneyText(avg_win) + " / " + AC_L1MoneyText(avg_loss) + "\r\n";
   AC_L1_BOARD_SECTION += "Max Win Streak:      " + IntegerToString(max_win_streak) + " (" + AC_L1MoneyText(max_win_streak_money) + ")\r\n";
   AC_L1_BOARD_SECTION += "Max Loss Streak:     " + IntegerToString(max_loss_streak) + " (" + AC_L1MoneyText(max_loss_streak_money) + ")\r\n";
   AC_L1_BOARD_SECTION += "Average Duration:    " + AC_L1DurationText((long)avg_duration_seconds) + " from " + IntegerToString(AC_L1_DURATION_COUNT) + " trades\r\n";
   AC_L1_BOARD_SECTION += "Best Symbol:         " + AC_L1_BEST_SYMBOL + " " + AC_L1MoneyText(AC_L1_BEST_SYMBOL_NET) + "\r\n";
   AC_L1_BOARD_SECTION += "Worst Symbol:        " + AC_L1_WORST_SYMBOL + " " + AC_L1MoneyText(AC_L1_WORST_SYMBOL_NET) + "\r\n";
   AC_L1_BOARD_SECTION += "Best Day:            " + AC_L1_BEST_DAY + " " + AC_L1MoneyText(AC_L1_BEST_DAY_NET) + "\r\n";
   AC_L1_BOARD_SECTION += "Worst Day:           " + AC_L1_WORST_DAY + " " + AC_L1MoneyText(AC_L1_WORST_DAY_NET) + "\r\n";
   AC_L1_BOARD_SECTION += "Health:              " + account_health + "\r\n";
   AC_L1_BOARD_SECTION += "\r\nRisk Envelope - Jason Policy Only\r\n";
   AC_L1_BOARD_SECTION += "Policy Truth:        Local stricter-than-firm planning guard; not broker or prop-firm permission proof\r\n";
   AC_L1_BOARD_SECTION += "0.1% Risk:           " + AC_L1MoneyText(default_risk_money) + "\r\n";
   AC_L1_BOARD_SECTION += "0.2% Hard Max:       " + AC_L1MoneyText(hard_risk_money) + "\r\n";
   AC_L1_BOARD_SECTION += "1% Open / Daily:     " + AC_L1MoneyText(max_open_risk_money) + " / " + AC_L1MoneyText(daily_dd_limit_money) + "\r\n";
   AC_L1_BOARD_SECTION += "3% Max DD Guard:     " + AC_L1MoneyText(max_dd_limit_money) + "\r\n";
   AC_L1_BOARD_SECTION += "Trade Permission:    FALSE\r\n";
   AC_L1_BOARD_SECTION += "\r\nLayer 1 Warnings\r\n";
   AC_L1_BOARD_SECTION += "----------------------------------------\r\n";
   AC_L1_BOARD_SECTION += warning_text;

   AC_L1_BOARD_SECTION += "\r\nRecent Closed Trades\r\n";
   AC_L1_BOARD_SECTION += "Time             Symbol      Side      Vol      Entry      Close       Net Duration  Result\r\n";
   int board_closed_limit = 25;
   int board_closed = 0;
   for(int c = 0; c < ArraySize(AC_L1_CLOSED) && board_closed < board_closed_limit; c++)
   {
      AC_L1_BOARD_SECTION += AC_L1ClosedTradeLine(AC_L1_CLOSED[c]) + "\r\n";
      board_closed++;
   }
   if(board_closed <= 0) AC_L1_BOARD_SECTION += "none\r\n";
   AC_L1_BOARD_SECTION += "\r\nCanceled / Rejected / Expired: " + IntegerToString(AC_L1_CANCEL_LIKE_ORDERS) + " total. Bounded list in Account Status.\r\n";

   AC_L1_WORKBENCH_SECTION = "L1_ACCOUNT_PORTFOLIO_SCAN\r\n";
   AC_L1_WORKBENCH_SECTION += "----------------------------------------\r\n";
   AC_L1_WORKBENCH_SECTION += "scan_status=" + AC_L1_SCAN_STATUS + "\r\n";
   AC_L1_WORKBENCH_SECTION += "scan_duration_ms=" + IntegerToString((int)AC_L1_SCAN_DURATION_MS) + "\r\n";
   AC_L1_WORKBENCH_SECTION += "history_status=" + AC_L1_HISTORY_STATUS + "\r\n";
   AC_L1_WORKBENCH_SECTION += "history_quality=" + AC_L1_HISTORY_QUALITY + "\r\n";
   AC_L1_WORKBENCH_SECTION += "history_note=" + AC_L1_HISTORY_NOTE + "\r\n";
   AC_L1_WORKBENCH_SECTION += "history_from=TimeCurrent_or_TimeGMT_minus_90_days\r\n";
   AC_L1_WORKBENCH_SECTION += "history_to=TimeCurrent_or_TimeGMT_fallback\r\n";
   AC_L1_WORKBENCH_SECTION += "account_status_history_days=" + IntegerToString(AC_L1_ACCOUNT_STATUS_HISTORY_DAYS) + "\r\n";
   AC_L1_WORKBENCH_SECTION += "account_status_row_limit=" + IntegerToString(AC_L1_ACCOUNT_STATUS_TRADE_ROW_LIMIT) + "\r\n";
   AC_L1_WORKBENCH_SECTION += "account_status_cutoff=" + account_status_cutoff_text + "\r\n";
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
   AC_L1_ACCOUNT_STATUS_TEXT += "Build: " + AC_BUILD_VERSION + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "Upgrade: " + AC_UPGRADE_ID + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "History Window: Selected bounded history (last 90 days to broker TimeCurrent/TimeGMT fallback). Strict MT5 report comparison needs the same cutoff.\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "Account Status Detail Window: selected bounded history; recent closed trades and recent cancel-like orders; max " + IntegerToString(AC_L1_ACCOUNT_STATUS_TRADE_ROW_LIMIT) + " rows per detailed history section. Totals refer to selected bounded history window.\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "Account Status Cutoff: " + account_status_cutoff_text + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "\r\nACCOUNT SUMMARY\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "----------------------------------------\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "Account: " + IntegerToString((int)AC_L1_LOGIN) + " | Server: " + AC_L1_SERVER + " | Mode: " + AC_L1_TRADE_MODE + " | Currency: " + AC_L1_CURRENCY + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "Balance: " + AC_L1MoneyText(AC_L1_BALANCE) + " | Equity: " + AC_L1MoneyText(AC_L1_EQUITY) + " | Floating P/L: " + AC_L1MoneyText(AC_L1_FLOATING_PL) + " | Free Margin: " + AC_L1MoneyText(AC_L1_FREE_MARGIN) + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "Current Drawdown: " + AC_L1MoneyText(current_dd_money) + " (" + AC_L1PercentText(current_dd_pct) + ") | Equity Cushion: " + AC_L1MoneyText(equity_cushion_money) + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "\r\nRESULTS\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "----------------------------------------\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "Total Net Profit: " + AC_L1MoneyText(AC_L1_NET_PROFIT) + " | Gross Profit: " + AC_L1MoneyText(AC_L1_GROSS_PROFIT) + " | Gross Loss: " + AC_L1MoneyText(AC_L1_GROSS_LOSS) + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "Profit Factor: " + DoubleToString(profit_factor, 2) + " | Expected Payoff: " + AC_L1MoneyText(expected_payoff) + " | Total Trades: " + IntegerToString(closed_count) + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "Profit Trades: " + IntegerToString(win_count) + " (" + AC_L1PercentText(win_rate) + ") | Loss Trades: " + IntegerToString(loss_count) + " (" + AC_L1PercentText(loss_rate) + ")\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "Short Trades: " + IntegerToString(short_count) + " (" + AC_L1PercentText(short_win_rate) + " won) | Long Trades: " + IntegerToString(long_count) + " (" + AC_L1PercentText(long_win_rate) + " won)\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "Largest Win / Loss: " + AC_L1MoneyText(AC_L1_LARGEST_WIN) + " / " + AC_L1MoneyText(AC_L1_LARGEST_LOSS) + " | Average Win / Loss: " + AC_L1MoneyText(avg_win) + " / " + AC_L1MoneyText(avg_loss) + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "Max Consecutive Wins: " + IntegerToString(max_win_streak) + " (" + AC_L1MoneyText(max_win_streak_money) + ") | Max Consecutive Losses: " + IntegerToString(max_loss_streak) + " (" + AC_L1MoneyText(max_loss_streak_money) + ")\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "Average Consecutive Wins: " + DoubleToString(avg_consecutive_wins, 1) + " | Average Consecutive Losses: " + DoubleToString(avg_consecutive_losses, 1) + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "Balance Drawdown Absolute: " + AC_L1MoneyText(balance_drawdown_absolute) + " | Maximal: " + AC_L1MoneyText(balance_drawdown_maximal) + " (" + AC_L1PercentText(balance_drawdown_relative_pct) + ")\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "Average Trade Duration: " + AC_L1DurationText((long)avg_duration_seconds) + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "Best Symbol: " + AC_L1_BEST_SYMBOL + " " + AC_L1MoneyText(AC_L1_BEST_SYMBOL_NET) + " | Worst Symbol: " + AC_L1_WORST_SYMBOL + " " + AC_L1MoneyText(AC_L1_WORST_SYMBOL_NET) + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "Best Day: " + AC_L1_BEST_DAY + " " + AC_L1MoneyText(AC_L1_BEST_DAY_NET) + " | Worst Day: " + AC_L1_WORST_DAY + " " + AC_L1MoneyText(AC_L1_WORST_DAY_NET) + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "\r\nOpen Positions - Full\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "Time             Symbol        Side      Vol       Entry          SL          TP       P/L\r\n";
   for(int fp = 0; fp < ArraySize(AC_L1_POSITIONS); fp++) AC_L1_ACCOUNT_STATUS_TEXT += AC_L1PositionLine(AC_L1_POSITIONS[fp]) + "\r\n";
   if(ArraySize(AC_L1_POSITIONS) <= 0) AC_L1_ACCOUNT_STATUS_TEXT += "none\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "\r\nPending Orders - Full\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "Time             Symbol        Type             Vol       Price          SL          TP\r\n";
   for(int fo = 0; fo < ArraySize(AC_L1_PENDING); fo++) AC_L1_ACCOUNT_STATUS_TEXT += AC_L1PendingLine(AC_L1_PENDING[fo]) + "\r\n";
   if(ArraySize(AC_L1_PENDING) <= 0) AC_L1_ACCOUNT_STATUS_TEXT += "none\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "\r\nClosed Trade History - Bounded Detail\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "Rule: latest selected rows only; close_time >= " + account_status_cutoff_text + "; max_rows=" + IntegerToString(AC_L1_ACCOUNT_STATUS_TRADE_ROW_LIMIT) + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "Time             Symbol      Side      Vol      Entry      Close       Net Duration  Result | Costs and Protection\r\n";
   int closed_shown = 0;
   for(int fc = 0; fc < ArraySize(AC_L1_CLOSED); fc++)
   {
      if(!AC_L1ClosedRowInsideAccountStatusWindow(AC_L1_CLOSED[fc], account_status_cutoff, closed_shown)) continue;
      AC_L1_ACCOUNT_STATUS_TEXT += AC_L1ClosedTradeDetailLine(AC_L1_CLOSED[fc]) + "\r\n";
      closed_shown++;
   }
   if(closed_shown <= 0) AC_L1_ACCOUNT_STATUS_TEXT += "none\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "Closed Detail Rows Shown: " + IntegerToString(closed_shown) + " / " + IntegerToString(ArraySize(AC_L1_CLOSED)) + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "\r\nCanceled / Rejected / Expired Orders - Bounded Detail\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "Rule: latest selected rows only; event_time >= " + account_status_cutoff_text + "; max_rows=" + IntegerToString(AC_L1_ACCOUNT_STATUS_TRADE_ROW_LIMIT) + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "Time             Symbol        Type           State        Vol       Price\r\n";
   int cancels_shown = 0;
   for(int x = 0; x < ArraySize(AC_L1_CANCELS); x++)
   {
      if(!AC_L1CancelRowInsideAccountStatusWindow(AC_L1_CANCELS[x], account_status_cutoff, cancels_shown)) continue;
      AC_L1_ACCOUNT_STATUS_TEXT += AC_L1CancelLine(AC_L1_CANCELS[x]) + "\r\n";
      cancels_shown++;
   }
   if(cancels_shown <= 0) AC_L1_ACCOUNT_STATUS_TEXT += "none\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "Canceled Detail Rows Shown: " + IntegerToString(cancels_shown) + " / " + IntegerToString(ArraySize(AC_L1_CANCELS)) + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "\r\n" + AC_L1SymbolSummaryTable() + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += AC_L1DaySummaryTable() + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "Direction Summary\r\n----------------------------------------\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "Buy Trades: " + IntegerToString(AC_L1_BUY_COUNT) + " | Net: " + AC_L1MoneyText(AC_L1_BUY_NET) + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "Sell Trades: " + IntegerToString(AC_L1_SELL_COUNT) + " | Net: " + AC_L1MoneyText(AC_L1_SELL_NET) + "\r\n";
}

string AC_Layer1BoardSection()
{
   if(!AC_L1_READY) return "\r\nLAYER 1 - ACCOUNT AND PORTFOLIO\r\n----------------------------------------\r\nStatus: Pending\r\n";
   return AC_L1_BOARD_SECTION;
}

string AC_Layer1WorkbenchSection()
{
   if(!AC_L1_READY) return "L1_ACCOUNT_PORTFOLIO_SCAN\r\nstatus=pending\r\n";
   return AC_L1_WORKBENCH_SECTION;
}

string AC_Layer1DossierSection(const string symbol)
{
   string text = "\r\nLAYER 1 - ACCOUNT AND PORTFOLIO CONTEXT\r\n";
   text += "----------------------------------------\r\n";
   text += "Account Balance: " + AC_L1MoneyText(AC_L1_BALANCE) + "\r\n";
   text += "Account Equity: " + AC_L1MoneyText(AC_L1_EQUITY) + "\r\n";
   text += "Floating P/L: " + AC_L1MoneyText(AC_L1_FLOATING_PL) + "\r\n";
   text += "Trade Permission: FALSE\r\n";

   int stats = -1;
   for(int i = 0; i < ArraySize(AC_L1_SYMBOL_STATS); i++)
      if(AC_L1_SYMBOL_STATS[i].symbol == symbol) { stats = i; break; }

   if(stats < 0)
   {
      text += "Symbol Account State: No account activity found\r\n";
      return text;
   }

   double symbol_win_rate = (AC_L1_SYMBOL_STATS[stats].closed_count > 0 ? ((double)AC_L1_SYMBOL_STATS[stats].win_count * 100.0) / AC_L1_SYMBOL_STATS[stats].closed_count : 0.0);
   text += "Symbol Account State: " + ((AC_L1_SYMBOL_STATS[stats].open_count > 0) ? "Open position" : ((AC_L1_SYMBOL_STATS[stats].pending_count > 0) ? "Pending order" : "History only")) + "\r\n";
   text += "Open Positions: " + IntegerToString(AC_L1_SYMBOL_STATS[stats].open_count) + "\r\n";
   text += "Pending Orders: " + IntegerToString(AC_L1_SYMBOL_STATS[stats].pending_count) + "\r\n";
   text += "Closed Trades: " + IntegerToString(AC_L1_SYMBOL_STATS[stats].closed_count) + "\r\n";
   text += "Canceled Orders: " + IntegerToString(AC_L1_SYMBOL_STATS[stats].canceled_count) + "\r\n";
   text += "Symbol Net P/L: " + AC_L1MoneyText(AC_L1_SYMBOL_STATS[stats].net_result) + "\r\n";
   text += "Symbol Win Rate: " + AC_L1PercentText(symbol_win_rate) + "\r\n";

   text += "\r\nSymbol Closed Trades\r\n";
   text += "Time             Symbol      Side      Vol      Entry      Close       Net Duration  Result\r\n";
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
   return "schema_name=layer_status|schema_version=v1.4|layer_id=1|layer_name=" + AC_LAYER_1_NAME
      + "|source_owner=" + AC_RUNTIME1_OWNER
      + "|build_version=" + AC_BUILD_VERSION
      + "|upgrade_id=" + AC_UPGRADE_ID
      + "|layer_status=" + (AC_L1_READY && account_write.ok ? "complete_with_report_metrics" : "partial")
      + "|account_status_available=" + AC_BoolText(account_write.ok)
      + "|closed_trades=" + IntegerToString(ArraySize(AC_L1_CLOSED))
      + "|canceled_orders=" + IntegerToString(AC_L1_CANCEL_LIKE_ORDERS)
      + "|history_deals_total=" + IntegerToString(AC_L1_HISTORY_DEALS_TOTAL)
      + "|history_orders_total=" + IntegerToString(AC_L1_HISTORY_ORDERS_TOTAL)
      + "|history_quality=" + AC_L1_HISTORY_QUALITY
      + "|account_status_history_days=" + IntegerToString(AC_L1_ACCOUNT_STATUS_HISTORY_DAYS)
      + "|account_status_row_limit=" + IntegerToString(AC_L1_ACCOUNT_STATUS_TRADE_ROW_LIMIT)
      + "|duration_count=" + IntegerToString(AC_L1_DURATION_COUNT)
      + "|scan_status=" + AC_L1_SCAN_STATUS
      + "|trade_permission=false";
}

#endif
