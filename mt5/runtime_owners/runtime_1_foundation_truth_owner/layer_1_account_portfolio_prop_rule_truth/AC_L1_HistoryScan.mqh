#ifndef AC_L1_HISTORY_SCAN_MQH
#define AC_L1_HISTORY_SCAN_MQH
void AC_L1ScanHistory()
{
   AC_L1_HISTORY_SCAN_STARTED_MS = GetTickCount();
   datetime to_time = TimeCurrent();
   if(to_time <= 0) to_time = TimeGMT();
   datetime from_time = 0;
   if(to_time > 0)
      from_time = (datetime)(to_time - (AC_L1_HISTORY_LOOKBACK_DAYS * 86400));

   ResetLastError();
   if(!HistorySelect(from_time, to_time))
   {
      AC_L1_HISTORY_STATUS = "unavailable";
      AC_L1_HISTORY_QUALITY = "unavailable";
      AC_L1_HISTORY_NOTE = "HistorySelect failed; history must not be interpreted as zero";
      AC_L1_SCAN_FAILURE = "HistorySelect_failed_error=" + IntegerToString(GetLastError());
      AC_L1_HISTORY_SCAN_DURATION_MS = GetTickCount() - AC_L1_HISTORY_SCAN_STARTED_MS;
      return;
   }

   int closed_in_lookback = AC_L1CountSelectedClosedTradeDeals();
   bool extend_to_minimum = (closed_in_lookback < AC_L1_CLOSED_SCAN_LIMIT && AC_L1_HISTORY_BUDGET_ABORT_COUNT <= 0);
   if(extend_to_minimum)
   {
      ResetLastError();
      if(!HistorySelect(0, to_time))
      {
         AC_L1_HISTORY_STATUS = "unavailable";
         AC_L1_HISTORY_QUALITY = "unavailable";
         AC_L1_HISTORY_NOTE = "HistorySelect extension failed; history must not be interpreted as zero";
         AC_L1_SCAN_FAILURE = "HistorySelect_extend_failed_error=" + IntegerToString(GetLastError());
         AC_L1_HISTORY_SCAN_DURATION_MS = GetTickCount() - AC_L1_HISTORY_SCAN_STARTED_MS;
         return;
      }
   }

   AC_L1_HISTORY_STATUS = (extend_to_minimum ? "available_extended_to_minimum" : "available_bounded_lookback");
   AC_L1_HISTORY_QUALITY = (extend_to_minimum ? "lookback_plus_minimum_fill" : "bounded_lookback_all_rows");
   AC_L1_HISTORY_NOTE = (extend_to_minimum
      ? "last 90 days had fewer than 100 closed trades; selected older history to fill up to 100 rows when available; totals refer to selected filled window; position-cost allocation source"
      : "selected last 90 days; all closed rows inside lookback are retained even when more than 100; totals refer to selected lookback; position-cost allocation source");
   AC_L1_HISTORY_DEALS_TOTAL = HistoryDealsTotal();
   AC_L1_HISTORY_ORDERS_TOTAL = HistoryOrdersTotal();

   for(int i = AC_L1_HISTORY_DEALS_TOTAL - 1; i >= 0; i--)
   {
      if(AC_L1HistoryBudgetExceeded()) break;
      if(extend_to_minimum && ArraySize(AC_L1_CLOSED) >= AC_L1_CLOSED_SCAN_LIMIT) break;
      ulong deal_ticket = HistoryDealGetTicket(i);
      if(deal_ticket == 0) continue;
      long entry = HistoryDealGetInteger(deal_ticket, DEAL_ENTRY);
      if(!AC_L1DealEntryIsClosed(entry)) continue;
      string symbol = HistoryDealGetString(deal_ticket, DEAL_SYMBOL);
      if(symbol == "") continue;
      long type = HistoryDealGetInteger(deal_ticket, DEAL_TYPE);
      if(type != DEAL_TYPE_BUY && type != DEAL_TYPE_SELL) continue;

      int next = ArraySize(AC_L1_CLOSED);
      ArrayResize(AC_L1_CLOSED, next + 1);
      AC_L1_CLOSED[next].deal_ticket = deal_ticket;
      AC_L1_CLOSED[next].order_ticket = (ulong)HistoryDealGetInteger(deal_ticket, DEAL_ORDER);
      AC_L1_CLOSED[next].entry_order_ticket = 0;
      AC_L1_CLOSED[next].position_id = HistoryDealGetInteger(deal_ticket, DEAL_POSITION_ID);
      AC_L1_CLOSED[next].symbol = symbol;
      AC_L1_CLOSED[next].side = AC_L1DealTypeText(type);
      AC_L1_CLOSED[next].entry_text = AC_L1DealEntryText(entry);
      AC_L1_CLOSED[next].volume = HistoryDealGetDouble(deal_ticket, DEAL_VOLUME);
      AC_L1_CLOSED[next].entry_time = 0;
      AC_L1_CLOSED[next].entry_price = 0.0;
      AC_L1_CLOSED[next].close_time = (datetime)HistoryDealGetInteger(deal_ticket, DEAL_TIME);
      AC_L1_CLOSED[next].close_price = HistoryDealGetDouble(deal_ticket, DEAL_PRICE);
      AC_L1_CLOSED[next].stop_loss = 0.0;
      AC_L1_CLOSED[next].take_profit = 0.0;
      AC_L1_CLOSED[next].profit = HistoryDealGetDouble(deal_ticket, DEAL_PROFIT);
      bool costs_complete = AC_L1AllocatedPositionCostValues(AC_L1_CLOSED[next].position_id, AC_L1_CLOSED[next].volume, AC_L1_CLOSED[next].commission, AC_L1_CLOSED[next].swap, AC_L1_CLOSED[next].fee);
      AC_L1_CLOSED[next].net_result = AC_L1_CLOSED[next].profit + AC_L1_CLOSED[next].commission + AC_L1_CLOSED[next].swap + AC_L1_CLOSED[next].fee;
      AC_L1_CLOSED[next].magic = HistoryDealGetInteger(deal_ticket, DEAL_MAGIC);
      AC_L1_CLOSED[next].comment = HistoryDealGetString(deal_ticket, DEAL_COMMENT);
      AC_L1_CLOSED[next].close_reason = HistoryDealGetInteger(deal_ticket, DEAL_REASON);
      AC_L1_CLOSED[next].source_quality = costs_complete ? "partial_core_position_cost_allocated" : "partial_core_cost_budget_limited";
      AC_L1_CLOSED[next].entry_reconstruction_status = "unavailable";
      AC_L1_CLOSED[next].paired_entry_status = "paired_entry_unavailable";
      AC_L1_CLOSED[next].order_context_status = "order_context_unavailable";
      AC_L1_CLOSED[next].stop_loss_source = "unavailable";
      AC_L1_CLOSED[next].take_profit_source = "unavailable";

      if(AC_L1_HISTORY_BUDGET_ABORT_COUNT <= 0)
      {
         datetime entry_time = 0;
         double entry_price = 0.0;
         string entry_side = "unknown";
         if(AC_L1FindEntryDealForPosition(AC_L1_CLOSED[next].position_id, i, entry_time, entry_price, entry_side))
         {
            AC_L1_CLOSED[next].entry_time = entry_time;
            AC_L1_CLOSED[next].entry_price = entry_price;
            AC_L1_CLOSED[next].side = entry_side;
            AC_L1_CLOSED[next].entry_reconstruction_status = "complete";
            AC_L1_CLOSED[next].paired_entry_status = "paired_entry_found";
            AC_L1_CLOSED[next].source_quality = costs_complete ? "core_complete_position_cost_allocated" : "core_complete_cost_budget_limited";
            AC_L1_CORE_RECONSTRUCTION_COMPLETE_COUNT++;
         }
      }

      if(AC_L1_HISTORY_BUDGET_ABORT_COUNT <= 0)
      {
         ulong entry_order = 0;
         double order_entry = 0.0;
         double sl = 0.0;
         double tp = 0.0;
         if(AC_L1FindHistoryOrderForPosition(AC_L1_CLOSED[next].position_id, entry_order, order_entry, sl, tp))
         {
            AC_L1_CLOSED[next].entry_order_ticket = entry_order;
            if(AC_L1_CLOSED[next].entry_price <= 0.0 && order_entry > 0.0)
            {
               AC_L1_CLOSED[next].entry_price = order_entry;
               AC_L1_CLOSED[next].entry_reconstruction_status = "partial_order_entry_only";
            }
            if(sl > 0.0)
            {
               AC_L1_CLOSED[next].stop_loss = sl;
               AC_L1_CLOSED[next].stop_loss_source = "history_order_position_id";
            }
            if(tp > 0.0)
            {
               AC_L1_CLOSED[next].take_profit = tp;
               AC_L1_CLOSED[next].take_profit_source = "history_order_position_id";
            }
         }
      }

      if(AC_L1_CLOSED[next].stop_loss > 0.0 && AC_L1_CLOSED[next].take_profit > 0.0)
         AC_L1_CLOSED[next].order_context_status = "protective_context_complete";
      else if(AC_L1_CLOSED[next].entry_order_ticket > 0 || AC_L1_CLOSED[next].stop_loss > 0.0 || AC_L1_CLOSED[next].take_profit > 0.0)
         AC_L1_CLOSED[next].order_context_status = "protective_context_partial";

      if(AC_L1_HISTORY_BUDGET_ABORT_COUNT > 0)
      {
         AC_L1_PARTIAL_RECONSTRUCTION_COUNT++;
         AC_L1_CLOSED[next].entry_reconstruction_status = "budget_limited";
         AC_L1_CLOSED[next].paired_entry_status = "paired_entry_budget_limited";
         AC_L1_CLOSED[next].order_context_status = "order_context_budget_limited";
      }
      else if(AC_L1_CLOSED[next].entry_reconstruction_status != "complete")
      {
         AC_L1_CLOSED[next].source_quality = costs_complete ? "partial_core_position_cost_allocated" : "partial_core_cost_budget_limited";
         AC_L1_PARTIAL_RECONSTRUCTION_COUNT++;
         AC_L1_HISTORY_QUALITY = (extend_to_minimum ? "lookback_plus_minimum_fill_partial_core_position_cost_allocated" : "bounded_lookback_partial_core_position_cost_allocated");
      }
      else if(AC_L1_CLOSED[next].order_context_status != "protective_context_complete")
      {
         AC_L1_ORDER_CONTEXT_PARTIAL_COUNT++;
         if(AC_L1_HISTORY_QUALITY == "bounded_lookback_all_rows") AC_L1_HISTORY_QUALITY = "bounded_lookback_order_context_partial_position_cost_allocated";
         if(AC_L1_HISTORY_QUALITY == "lookback_plus_minimum_fill") AC_L1_HISTORY_QUALITY = "lookback_plus_minimum_fill_order_context_partial_position_cost_allocated";
      }

      AC_L1AddClosedStats(AC_L1_CLOSED[next]);
   }

   for(int o = AC_L1_HISTORY_ORDERS_TOTAL - 1; o >= 0; o--)
   {
      if(AC_L1HistoryBudgetExceeded()) break;
      ulong order_ticket = HistoryOrderGetTicket(o);
      if(order_ticket == 0) continue;
      long state = HistoryOrderGetInteger(order_ticket, ORDER_STATE);
      if(state == ORDER_STATE_FILLED || state == ORDER_STATE_PARTIAL) AC_L1_FILLED_ORDERS++;
      if(!AC_L1OrderStateIsCancelLike(state)) continue;
      if(ArraySize(AC_L1_CANCELS) >= AC_L1_CANCEL_SCAN_LIMIT)
      {
         AC_L1_CANCEL_LIKE_ORDERS++;
         continue;
      }

      int next = ArraySize(AC_L1_CANCELS);
      ArrayResize(AC_L1_CANCELS, next + 1);
      AC_L1_CANCELS[next].ticket = order_ticket;
      AC_L1_CANCELS[next].symbol = HistoryOrderGetString(order_ticket, ORDER_SYMBOL);
      AC_L1_CANCELS[next].type_text = AC_L1OrderTypeText(HistoryOrderGetInteger(order_ticket, ORDER_TYPE));
      AC_L1_CANCELS[next].state_text = AC_L1OrderStateText(state);
      AC_L1_CANCELS[next].volume_initial = HistoryOrderGetDouble(order_ticket, ORDER_VOLUME_INITIAL);
      AC_L1_CANCELS[next].price_open = HistoryOrderGetDouble(order_ticket, ORDER_PRICE_OPEN);
      AC_L1_CANCELS[next].stop_loss = HistoryOrderGetDouble(order_ticket, ORDER_SL);
      AC_L1_CANCELS[next].take_profit = HistoryOrderGetDouble(order_ticket, ORDER_TP);
      AC_L1_CANCELS[next].setup_time = (datetime)HistoryOrderGetInteger(order_ticket, ORDER_TIME_SETUP);
      AC_L1_CANCELS[next].done_time = (datetime)HistoryOrderGetInteger(order_ticket, ORDER_TIME_DONE);
      AC_L1_CANCELS[next].magic = HistoryOrderGetInteger(order_ticket, ORDER_MAGIC);
      AC_L1_CANCELS[next].comment = HistoryOrderGetString(order_ticket, ORDER_COMMENT);
      AC_L1_CANCEL_LIKE_ORDERS++;

      if(AC_L1_CANCELS[next].symbol != "")
      {
         int s = AC_L1FindSymbolStats(AC_L1_CANCELS[next].symbol);
         AC_L1_SYMBOL_STATS[s].canceled_count++;
      }
   }

   if(ArraySize(AC_L1_CANCELS) >= AC_L1_CANCEL_SCAN_LIMIT)
      AC_L1_HISTORY_QUALITY += "_cancel_rows_capped";

   if(ArraySize(AC_L1_CLOSED) <= 0)
      AC_L1_HISTORY_NOTE = "selected history; no closed exit deals detected; policy=all 90d rows or minimum-fill to 100 when available; position-cost allocation source";

   AC_L1_HISTORY_SCAN_DURATION_MS = GetTickCount() - AC_L1_HISTORY_SCAN_STARTED_MS;
}

#endif