#ifndef AC_L1_HISTORY_RECONSTRUCTION_MQH
#define AC_L1_HISTORY_RECONSTRUCTION_MQH

bool AC_L1HistoryBudgetExceeded()
{
   if(AC_L1_HISTORY_SCAN_STARTED_MS == 0) return false;
   uint elapsed = GetTickCount() - AC_L1_HISTORY_SCAN_STARTED_MS;
   if(elapsed <= (uint)AC_L1_HISTORY_SCAN_BUDGET_MS) return false;

   AC_L1_HISTORY_SCAN_DURATION_MS = elapsed;
   AC_L1_SCAN_STATUS = "complete_with_degraded";
   AC_L1_HISTORY_STATUS = "available_partial_budget_limited";
   if(AC_L1_HISTORY_BUDGET_ABORT_COUNT <= 0)
      AC_L1_HISTORY_BUDGET_ABORT_COUNT = 1;
   if(StringFind(AC_L1_HISTORY_QUALITY, "budget_limited") < 0)
      AC_L1_HISTORY_QUALITY += "_budget_limited";
   if(StringFind(AC_L1_HISTORY_NOTE, "history reconstruction stopped by Layer 1 scan budget") < 0)
      AC_L1_HISTORY_NOTE += "; history reconstruction stopped by Layer 1 scan budget; selected rows are partial and must not be interpreted as complete account history";
   return true;
}

double AC_L1SafeDealFee(const ulong deal_ticket)
{
   double value = 0.0;
   ResetLastError();
   if(HistoryDealGetDouble(deal_ticket, (ENUM_DEAL_PROPERTY_DOUBLE)DEAL_FEE, value))
      return value;
   return 0.0;
}

bool AC_L1AllocatedPositionCostValues(const long position_id,
                                      const double close_volume,
                                      double &commission_value,
                                      double &swap_value,
                                      double &fee_value)
{
   commission_value = 0.0;
   swap_value = 0.0;
   fee_value = 0.0;
   if(position_id <= 0) return false;

   double commission_sum = 0.0;
   double swap_sum = 0.0;
   double fee_sum = 0.0;
   double closed_volume_sum = 0.0;

   int total = HistoryDealsTotal();
   for(int i = 0; i < total; i++)
   {
      if(AC_L1HistoryBudgetExceeded()) return false;
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket == 0) continue;
      if(HistoryDealGetInteger(ticket, DEAL_POSITION_ID) != position_id) continue;

      commission_sum += HistoryDealGetDouble(ticket, DEAL_COMMISSION);
      swap_sum += HistoryDealGetDouble(ticket, DEAL_SWAP);
      fee_sum += AC_L1SafeDealFee(ticket);

      long entry = HistoryDealGetInteger(ticket, DEAL_ENTRY);
      long type = HistoryDealGetInteger(ticket, DEAL_TYPE);
      if(AC_L1DealEntryIsClosed(entry) && (type == DEAL_TYPE_BUY || type == DEAL_TYPE_SELL))
         closed_volume_sum += HistoryDealGetDouble(ticket, DEAL_VOLUME);
   }

   double factor = 1.0;
   if(closed_volume_sum > 0.0 && close_volume > 0.0)
   {
      factor = close_volume / closed_volume_sum;
      if(factor < 0.0) factor = 0.0;
      if(factor > 1.0) factor = 1.0;
   }

   commission_value = commission_sum * factor;
   swap_value = swap_sum * factor;
   fee_value = fee_sum * factor;
   return true;
}

bool AC_L1SelectedDealIsClosedTrade(const ulong deal_ticket)
{
   if(deal_ticket == 0) return false;
   long entry = HistoryDealGetInteger(deal_ticket, DEAL_ENTRY);
   if(!AC_L1DealEntryIsClosed(entry)) return false;
   string symbol = HistoryDealGetString(deal_ticket, DEAL_SYMBOL);
   if(symbol == "") return false;
   long type = HistoryDealGetInteger(deal_ticket, DEAL_TYPE);
   return (type == DEAL_TYPE_BUY || type == DEAL_TYPE_SELL);
}

int AC_L1CountSelectedClosedTradeDeals()
{
   int count = 0;
   int total = HistoryDealsTotal();
   for(int i = total - 1; i >= 0; i--)
   {
      if(AC_L1HistoryBudgetExceeded()) break;
      ulong ticket = HistoryDealGetTicket(i);
      if(AC_L1SelectedDealIsClosedTrade(ticket)) count++;
   }
   return count;
}

bool AC_L1FindEntryDealForPosition(const long position_id,
                                   const int close_deal_index,
                                   datetime &entry_time,
                                   double &entry_price,
                                   string &entry_side)
{
   entry_time = 0;
   entry_price = 0.0;
   entry_side = "unknown";
   if(position_id <= 0) return false;

   for(int i = close_deal_index - 1; i >= 0; i--)
   {
      if(AC_L1HistoryBudgetExceeded()) return false;
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket == 0) continue;
      if(HistoryDealGetInteger(ticket, DEAL_POSITION_ID) != position_id) continue;
      if(HistoryDealGetInteger(ticket, DEAL_ENTRY) != DEAL_ENTRY_IN) continue;
      entry_time = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
      entry_price = HistoryDealGetDouble(ticket, DEAL_PRICE);
      entry_side = AC_L1DealTypeText(HistoryDealGetInteger(ticket, DEAL_TYPE));
      return (entry_time > 0 || entry_price > 0.0);
   }
   return false;
}

bool AC_L1FindHistoryOrderForPosition(const long position_id,
                                      ulong &entry_order_ticket,
                                      double &entry_price,
                                      double &stop_loss,
                                      double &take_profit)
{
   entry_order_ticket = 0;
   entry_price = 0.0;
   stop_loss = 0.0;
   take_profit = 0.0;
   if(position_id <= 0) return false;

   bool found = false;
   datetime earliest_time = 0;
   datetime latest_sl_time = 0;
   datetime latest_tp_time = 0;
   int total = HistoryOrdersTotal();
   for(int i = 0; i < total; i++)
   {
      if(AC_L1HistoryBudgetExceeded()) return found;
      ulong order_ticket = HistoryOrderGetTicket(i);
      if(order_ticket == 0) continue;
      if(HistoryOrderGetInteger(order_ticket, ORDER_POSITION_ID) != position_id) continue;

      found = true;
      datetime order_time = (datetime)HistoryOrderGetInteger(order_ticket, ORDER_TIME_DONE);
      if(order_time <= 0) order_time = (datetime)HistoryOrderGetInteger(order_ticket, ORDER_TIME_SETUP);

      double price = HistoryOrderGetDouble(order_ticket, ORDER_PRICE_OPEN);
      if(price > 0.0 && (entry_order_ticket == 0 || earliest_time <= 0 || (order_time > 0 && order_time < earliest_time)))
      {
         entry_order_ticket = order_ticket;
         entry_price = price;
         earliest_time = order_time;
      }

      double sl = HistoryOrderGetDouble(order_ticket, ORDER_SL);
      if(sl > 0.0 && (latest_sl_time <= 0 || order_time >= latest_sl_time))
      {
         stop_loss = sl;
         latest_sl_time = order_time;
      }

      double tp = HistoryOrderGetDouble(order_ticket, ORDER_TP);
      if(tp > 0.0 && (latest_tp_time <= 0 || order_time >= latest_tp_time))
      {
         take_profit = tp;
         latest_tp_time = order_time;
      }
   }
   return found;
}

void AC_L1AddClosedStats(const AC_L1ClosedTradeRow &row)
{
   AC_L1_NET_PROFIT += row.net_result;
   if(row.net_result > 0.0)
   {
      AC_L1_GROSS_PROFIT += row.net_result;
      if(row.net_result > AC_L1_LARGEST_WIN) AC_L1_LARGEST_WIN = row.net_result;
   }
   else if(row.net_result < 0.0)
   {
      AC_L1_GROSS_LOSS += row.net_result;
      if(row.net_result < AC_L1_LARGEST_LOSS) AC_L1_LARGEST_LOSS = row.net_result;
   }

   if(row.side == "buy") { AC_L1_BUY_COUNT++; AC_L1_BUY_NET += row.net_result; }
   if(row.side == "sell") { AC_L1_SELL_COUNT++; AC_L1_SELL_NET += row.net_result; }

   if(row.entry_time > 0 && row.close_time > row.entry_time)
   {
      AC_L1_DURATION_SUM_SECONDS += (long)(row.close_time - row.entry_time);
      AC_L1_DURATION_COUNT++;
   }

   int s = AC_L1FindSymbolStats(row.symbol);
   AC_L1_SYMBOL_STATS[s].net_result += row.net_result;
   AC_L1_SYMBOL_STATS[s].closed_count++;
   if(row.net_result > 0.0) AC_L1_SYMBOL_STATS[s].win_count++;
   if(row.net_result < 0.0) AC_L1_SYMBOL_STATS[s].loss_count++;

   string day = TimeToString(row.close_time, TIME_DATE);
   int d = AC_L1FindDayStats(day);
   AC_L1_DAY_STATS[d].net_result += row.net_result;
   AC_L1_DAY_STATS[d].closed_count++;
}

#endif