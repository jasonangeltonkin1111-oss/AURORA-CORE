#ifndef AC_L1_RECOVERY_DAMAGE_MAPS_MQH
#define AC_L1_RECOVERY_DAMAGE_MAPS_MQH

string AC_L1SequenceResultLine(const string label,
                               const int start_rank,
                               const int end_rank,
                               const double net_money,
                               const double net_r)
{
   return AC_L1PadRight(label, 14)
      + AC_L1PadLeft(IntegerToString(start_rank), 8)
      + AC_L1PadLeft(IntegerToString(end_rank), 8)
      + AC_L1PadLeft(AC_L1MoneyText(net_money), 12)
      + AC_L1PadLeft(DoubleToString(net_r, 2), 10)
      + "\r\n";
}

void AC_L1SequenceWindowStats(const int window,
                              int &worst_start,
                              int &worst_end,
                              double &worst_net,
                              double &worst_r,
                              int &best_start,
                              int &best_end,
                              double &best_net,
                              double &best_r)
{
   int rows = ArraySize(AC_L1_CLOSED);
   worst_start = 0;
   worst_end = 0;
   worst_net = 0.0;
   worst_r = 0.0;
   best_start = 0;
   best_end = 0;
   best_net = 0.0;
   best_r = 0.0;
   if(window <= 0 || rows < window) return;

   int order[];
   ArrayResize(order, rows);
   string used = "|";
   for(int rank = 0; rank < rows; rank++)
      order[rank] = AC_L1ClosedChronologicalIndexByRank(rank, used);

   bool first = true;
   for(int s = 0; s <= rows - window; s++)
   {
      double net = 0.0;
      double net_r = 0.0;
      for(int k = 0; k < window; k++)
      {
         int idx = order[s + k];
         if(idx < 0) continue;
         net += AC_L1_CLOSED[idx].net_result;
         double risk = 0.0;
         if(AC_L1EstimateClosedInitialRiskMoney(AC_L1_CLOSED[idx], risk))
            net_r += AC_L1ClosedTradeRMultiple(AC_L1_CLOSED[idx], risk);
      }

      if(first || net < worst_net)
      {
         worst_net = net;
         worst_r = net_r;
         worst_start = s + 1;
         worst_end = s + window;
      }
      if(first || net > best_net)
      {
         best_net = net;
         best_r = net_r;
         best_start = s + 1;
         best_end = s + window;
      }
      first = false;
   }
}

string AC_L1StreakDamageMap()
{
   int w3s, w3e, b3s, b3e;
   int w5s, w5e, b5s, b5e;
   int w10s, w10e, b10s, b10e;
   double w3n, w3r, b3n, b3r;
   double w5n, w5r, b5n, b5r;
   double w10n, w10r, b10n, b10r;
   AC_L1SequenceWindowStats(3, w3s, w3e, w3n, w3r, b3s, b3e, b3n, b3r);
   AC_L1SequenceWindowStats(5, w5s, w5e, w5n, w5r, b5s, b5e, b5n, b5r);
   AC_L1SequenceWindowStats(10, w10s, w10e, w10n, w10r, b10s, b10e, b10n, b10r);

   int rows = ArraySize(AC_L1_CLOSED);
   int max_loss_streak = 0;
   int current_loss_streak = 0;
   double max_loss_streak_money = 0.0;
   double current_loss_money = 0.0;
   int max_win_streak = 0;
   int current_win_streak = 0;
   double max_win_streak_money = 0.0;
   double current_win_money = 0.0;

   string used = "|";
   for(int rank = 0; rank < rows; rank++)
   {
      int idx = AC_L1ClosedChronologicalIndexByRank(rank, used);
      if(idx < 0) continue;
      double net = AC_L1_CLOSED[idx].net_result;
      if(net < 0.0)
      {
         current_loss_streak++;
         current_loss_money += net;
         current_win_streak = 0;
         current_win_money = 0.0;
         if(current_loss_streak > max_loss_streak || (current_loss_streak == max_loss_streak && current_loss_money < max_loss_streak_money))
         {
            max_loss_streak = current_loss_streak;
            max_loss_streak_money = current_loss_money;
         }
      }
      else if(net > 0.0)
      {
         current_win_streak++;
         current_win_money += net;
         current_loss_streak = 0;
         current_loss_money = 0.0;
         if(current_win_streak > max_win_streak || (current_win_streak == max_win_streak && current_win_money > max_win_streak_money))
         {
            max_win_streak = current_win_streak;
            max_win_streak_money = current_win_money;
         }
      }
      else
      {
         current_loss_streak = 0;
         current_loss_money = 0.0;
         current_win_streak = 0;
         current_win_money = 0.0;
      }
   }

   string text = AC_L1MapHeader("STREAK DAMAGE MAP");
   text += "section_id:             L1_STREAK_DAMAGE\r\n";
   text += "Scope:                  selected closed history in chronological order\r\n";
   text += "Rows:                   " + IntegerToString(rows) + "\r\n";
   text += "Max Loss Streak:        " + IntegerToString(max_loss_streak) + " trades / " + AC_L1MoneyText(max_loss_streak_money) + "\r\n";
   text += "Max Win Streak:         " + IntegerToString(max_win_streak) + " trades / " + AC_L1MoneyText(max_win_streak_money) + "\r\n";
   text += AC_L1PadRight("Sequence", 14) + AC_L1PadLeft("Start", 8) + AC_L1PadLeft("End", 8) + AC_L1PadLeft("Net", 12) + AC_L1PadLeft("Net R", 10) + "\r\n";
   text += AC_L1SequenceResultLine("Worst 3", w3s, w3e, w3n, w3r);
   text += AC_L1SequenceResultLine("Worst 5", w5s, w5e, w5n, w5r);
   text += AC_L1SequenceResultLine("Worst 10", w10s, w10e, w10n, w10r);
   text += AC_L1SequenceResultLine("Best 3", b3s, b3e, b3n, b3r);
   text += AC_L1SequenceResultLine("Best 5", b5s, b5e, b5n, b5r);
   text += AC_L1SequenceResultLine("Best 10", b10s, b10e, b10n, b10r);
   text += "Trade Permission:       FALSE\r\n";
   return text;
}

string AC_L1RecoveryQualityMap()
{
   int rows = ArraySize(AC_L1_CLOSED);
   double start_equity_est = AC_L1_BALANCE - AC_L1_NET_PROFIT;
   double running_equity = start_equity_est;
   double peak_equity = running_equity;
   int current_drawdown_trades = 0;
   int max_recovery_trades = 0;
   int recovered_events = 0;
   int unrecovered_events = 0;
   double worst_unrecovered_money = 0.0;
   int worst_unrecovered_trades = 0;
   double total_recovered_drawdown = 0.0;

   string used = "|";
   for(int rank = 0; rank < rows; rank++)
   {
      int idx = AC_L1ClosedChronologicalIndexByRank(rank, used);
      if(idx < 0) continue;
      running_equity += AC_L1_CLOSED[idx].net_result;

      if(running_equity > peak_equity)
      {
         if(current_drawdown_trades > 0)
         {
            recovered_events++;
            if(current_drawdown_trades > max_recovery_trades) max_recovery_trades = current_drawdown_trades;
         }
         peak_equity = running_equity;
         current_drawdown_trades = 0;
      }
      else
      {
         current_drawdown_trades++;
         double dd = peak_equity - running_equity;
         if(dd > worst_unrecovered_money)
         {
            worst_unrecovered_money = dd;
            worst_unrecovered_trades = current_drawdown_trades;
         }
      }
   }

   if(current_drawdown_trades > 0) unrecovered_events++;
   double current_distance = (peak_equity > running_equity ? peak_equity - running_equity : 0.0);
   double current_distance_pct = (peak_equity > 0.0 ? (current_distance / peak_equity) * 100.0 : 0.0);
   string status = (current_distance > 0.0 ? "unrecovered drawdown" : "recovered to selected-history peak");
   string quality = "not enough recovered cycles";
   if(recovered_events > 0 && current_distance <= 0.0) quality = "recovery observed and currently recovered";
   else if(recovered_events > 0 && current_distance > 0.0) quality = "recovery observed but currently underwater";
   else if(recovered_events <= 0 && current_distance > 0.0) quality = "no recovery event in selected sample";

   string text = AC_L1MapHeader("RECOVERY QUALITY MAP");
   text += "section_id:             L1_RECOVERY_QUALITY\r\n";
   text += "Scope:                  selected closed history only; reconstructed from closed rows\r\n";
   text += "Rows:                   " + IntegerToString(rows) + "\r\n";
   text += "Start Equity Estimate:  " + AC_L1MoneyText(start_equity_est) + "\r\n";
   text += "End Equity Estimate:    " + AC_L1MoneyText(running_equity) + "\r\n";
   text += "Peak Equity Estimate:   " + AC_L1MoneyText(peak_equity) + "\r\n";
   text += "Recovered Events:       " + IntegerToString(recovered_events) + "\r\n";
   text += "Unrecovered Events:     " + IntegerToString(unrecovered_events) + "\r\n";
   text += "Max Recovery Trades:    " + IntegerToString(max_recovery_trades) + "\r\n";
   text += "Worst Unrecovered DD:   " + AC_L1MoneyText(worst_unrecovered_money) + " over " + IntegerToString(worst_unrecovered_trades) + " trades\r\n";
   text += "Current Distance Peak:  " + AC_L1MoneyText(current_distance) + " (" + AC_L1PercentText(current_distance_pct) + ")\r\n";
   text += "Recovery Status:        " + status + "\r\n";
   text += "Recovery Quality:       " + quality + "\r\n";
   text += "Proof Status:           reconstructed from selected closed rows, not broker equity curve\r\n";
   text += "Trade Permission:       FALSE\r\n";
   return text;
}

string AC_L1RecoveryDamageMapsFull()
{
   string text = "";
   text += AC_L1RecoveryQualityMap();
   text += AC_L1StreakDamageMap();
   return text;
}

#endif