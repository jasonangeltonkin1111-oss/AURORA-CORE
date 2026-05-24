#ifndef AC_L1_EQUITY_DRAWDOWN_MAPS_MQH
#define AC_L1_EQUITY_DRAWDOWN_MAPS_MQH

string AC_L1DealTicketKey(const ulong deal_ticket)
{
   return IntegerToString((long)deal_ticket);
}

int AC_L1ClosedChronologicalIndexByRank(const int rank,
                                        string &used_keys)
{
   int best_index = -1;
   datetime best_time = 0;
   ulong best_ticket = 0;

   for(int i = 0; i < ArraySize(AC_L1_CLOSED); i++)
   {
      string key = AC_L1DealTicketKey(AC_L1_CLOSED[i].deal_ticket);
      if(StringFind(used_keys, "|" + key + "|") >= 0) continue;
      datetime t = AC_L1_CLOSED[i].close_time;
      ulong ticket = AC_L1_CLOSED[i].deal_ticket;
      if(best_index < 0 || t < best_time || (t == best_time && ticket < best_ticket))
      {
         best_index = i;
         best_time = t;
         best_ticket = ticket;
      }
   }

   if(best_index >= 0)
      used_keys += AC_L1DealTicketKey(AC_L1_CLOSED[best_index].deal_ticket) + "|";
   return best_index;
}

string AC_L1EquityDrawdownRecoveryMap()
{
   int rows = ArraySize(AC_L1_CLOSED);
   double start_equity_est = AC_L1_BALANCE - AC_L1_NET_PROFIT;
   double running_equity = start_equity_est;
   double peak_equity = running_equity;
   double lowest_equity = running_equity;
   double max_drawdown_money = 0.0;
   double max_drawdown_pct = 0.0;
   datetime peak_time = 0;
   datetime max_dd_peak_time = 0;
   datetime max_dd_low_time = 0;
   datetime current_drawdown_start = 0;
   int max_dd_start_trade_rank = 0;
   int max_dd_low_trade_rank = 0;
   int trades_since_peak = 0;
   int max_recovery_trades = 0;
   int current_recovery_trades = 0;
   int unrecovered_drawdown = 0;
   bool max_dd_started_from_initial_balance = false;

   string used = "|";
   for(int rank = 0; rank < rows; rank++)
   {
      int idx = AC_L1ClosedChronologicalIndexByRank(rank, used);
      if(idx < 0) break;

      running_equity += AC_L1_CLOSED[idx].net_result;
      datetime close_time = AC_L1_CLOSED[idx].close_time;

      if(running_equity > peak_equity)
      {
         if(current_recovery_trades > max_recovery_trades)
            max_recovery_trades = current_recovery_trades;
         peak_equity = running_equity;
         peak_time = close_time;
         current_drawdown_start = 0;
         current_recovery_trades = 0;
      }
      else
      {
         if(current_drawdown_start <= 0) current_drawdown_start = peak_time;
         current_recovery_trades++;
      }

      if(running_equity < lowest_equity)
         lowest_equity = running_equity;

      double dd = peak_equity - running_equity;
      double dd_pct = (peak_equity > 0.0 ? (dd / peak_equity) * 100.0 : 0.0);
      if(dd > max_drawdown_money)
      {
         max_drawdown_money = dd;
         max_drawdown_pct = dd_pct;
         max_dd_peak_time = (current_drawdown_start > 0 ? current_drawdown_start : peak_time);
         max_dd_low_time = close_time;
         max_dd_started_from_initial_balance = (max_dd_peak_time <= 0);
         max_dd_start_trade_rank = (max_dd_started_from_initial_balance ? 0 : rank + 1 - current_recovery_trades);
         max_dd_low_trade_rank = rank + 1;
      }
   }

   trades_since_peak = current_recovery_trades;
   unrecovered_drawdown = (running_equity < peak_equity ? 1 : 0);
   double current_distance_from_peak = (peak_equity > running_equity ? peak_equity - running_equity : 0.0);
   double current_distance_pct = (peak_equity > 0.0 ? (current_distance_from_peak / peak_equity) * 100.0 : 0.0);
   double selected_return_money = running_equity - start_equity_est;
   double selected_return_pct = (start_equity_est > 0.0 ? (selected_return_money / start_equity_est) * 100.0 : 0.0);
   string max_dd_peak_text = (max_dd_started_from_initial_balance ? "initial_selected_history_balance" : AC_L1TimeText(max_dd_peak_time));
   string max_dd_span_text = (max_dd_started_from_initial_balance
      ? "initial_balance_to_" + IntegerToString(max_dd_low_trade_rank) + " chronological ranks"
      : IntegerToString(max_dd_start_trade_rank) + " to " + IntegerToString(max_dd_low_trade_rank) + " chronological ranks");

   string text = AC_L1MapHeader("EQUITY / DRAWDOWN RECOVERY MAP");
   text += "section_id:             L1_EQUITY_DRAWDOWN_RECOVERY\r\n";
   text += "Scope:                  selected closed history only; open equity shown separately by live exposure maps\r\n";
   text += "Rows:                   " + IntegerToString(rows) + "\r\n";
   text += "Start Equity Estimate:  " + AC_L1MoneyText(start_equity_est) + "\r\n";
   text += "End Equity Estimate:    " + AC_L1MoneyText(running_equity) + "\r\n";
   text += "Selected Return:        " + AC_L1MoneyText(selected_return_money) + " (" + AC_L1PercentText(selected_return_pct) + ")\r\n";
   text += "Peak Equity Estimate:   " + AC_L1MoneyText(peak_equity) + "\r\n";
   text += "Lowest Equity Estimate: " + AC_L1MoneyText(lowest_equity) + "\r\n";
   text += "Max Drawdown:           " + AC_L1MoneyText(max_drawdown_money) + " (" + AC_L1PercentText(max_drawdown_pct) + ")\r\n";
   text += "Max DD Peak Basis:      " + max_dd_peak_text + "\r\n";
   text += "Max DD Low Time:        " + AC_L1TimeText(max_dd_low_time) + "\r\n";
   text += "Max DD Trade Span:      " + max_dd_span_text + "\r\n";
   text += "Max Recovery Trades:    " + IntegerToString(max_recovery_trades) + "\r\n";
   text += "Current Distance Peak:  " + AC_L1MoneyText(current_distance_from_peak) + " (" + AC_L1PercentText(current_distance_pct) + ")\r\n";
   text += "Trades Since Peak:      " + IntegerToString(trades_since_peak) + "\r\n";
   text += "Recovery Status:        " + (unrecovered_drawdown == 1 ? "unrecovered_selected_history_drawdown" : "recovered_to_selected_history_peak") + "\r\n";
   text += "Proof Status:           reconstructed_from_selected_closed_rows_not_broker_equity_curve\r\n";
   text += "Trade Permission:       FALSE\r\n";
   return text;
}

#endif