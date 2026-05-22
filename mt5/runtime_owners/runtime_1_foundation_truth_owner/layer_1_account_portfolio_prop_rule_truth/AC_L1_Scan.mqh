#ifndef AC_L1_SCAN_MQH
#define AC_L1_SCAN_MQH

// Forward declaration: render implementation is included after scan in the Runtime 1 dispatcher.
void AC_BuildLayer1Texts();
string AC_L1PortfolioMapSummary();
string AC_L1AccountPortfolioMapsFull();

static int AC_L1_HISTORY_LOOKBACK_DAYS = 90;
static int AC_L1_CLOSED_SCAN_LIMIT = 100;
static int AC_L1_CANCEL_SCAN_LIMIT = 20;

double AC_L1SafeDealFee(const ulong deal_ticket)
{
   double value = 0.0;
   ResetLastError();
   if(HistoryDealGetDouble(deal_ticket, (ENUM_DEAL_PROPERTY_DOUBLE)DEAL_FEE, value))
      return value;
   return 0.0;
}

void AC_L1AllocatedPositionCostValues(const long position_id,
                                      const double close_volume,
                                      double &commission_value,
                                      double &swap_value,
                                      double &fee_value)
{
   commission_value = 0.0;
   swap_value = 0.0;
   fee_value = 0.0;
   if(position_id <= 0) return;

   double commission_sum = 0.0;
   double swap_sum = 0.0;
   double fee_sum = 0.0;
   double closed_volume_sum = 0.0;

   int total = HistoryDealsTotal();
   for(int i = 0; i < total; i++)
   {
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

void AC_L1ScanPositions()
{
   int observed = PositionsTotal();
   for(int i = 0; i < observed; i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      int next = ArraySize(AC_L1_POSITIONS);
      ArrayResize(AC_L1_POSITIONS, next + 1);
      AC_L1_POSITIONS[next].ticket = ticket;
      AC_L1_POSITIONS[next].symbol = PositionGetString(POSITION_SYMBOL);
      AC_L1_POSITIONS[next].side = AC_L1PositionTypeText(PositionGetInteger(POSITION_TYPE));
      AC_L1_POSITIONS[next].volume = PositionGetDouble(POSITION_VOLUME);
      AC_L1_POSITIONS[next].entry_price = PositionGetDouble(POSITION_PRICE_OPEN);
      AC_L1_POSITIONS[next].stop_loss = PositionGetDouble(POSITION_SL);
      AC_L1_POSITIONS[next].take_profit = PositionGetDouble(POSITION_TP);
      AC_L1_POSITIONS[next].current_price = PositionGetDouble(POSITION_PRICE_CURRENT);
      AC_L1_POSITIONS[next].profit = PositionGetDouble(POSITION_PROFIT);
      AC_L1_POSITIONS[next].open_time = (datetime)PositionGetInteger(POSITION_TIME);
      AC_L1_POSITIONS[next].magic = PositionGetInteger(POSITION_MAGIC);
      AC_L1_POSITIONS[next].comment = PositionGetString(POSITION_COMMENT);

      int s = AC_L1FindSymbolStats(AC_L1_POSITIONS[next].symbol);
      AC_L1_SYMBOL_STATS[s].open_count++;
   }
}

void AC_L1ScanPendingOrders()
{
   int observed = OrdersTotal();
   for(int i = 0; i < observed; i++)
   {
      ulong ticket = OrderGetTicket(i);
      if(ticket == 0) continue;
      long state = OrderGetInteger(ORDER_STATE);
      if(state != ORDER_STATE_PLACED && state != ORDER_STATE_PARTIAL) continue;

      int next = ArraySize(AC_L1_PENDING);
      ArrayResize(AC_L1_PENDING, next + 1);
      AC_L1_PENDING[next].ticket = ticket;
      AC_L1_PENDING[next].symbol = OrderGetString(ORDER_SYMBOL);
      AC_L1_PENDING[next].type_text = AC_L1OrderTypeText(OrderGetInteger(ORDER_TYPE));
      AC_L1_PENDING[next].state_text = AC_L1OrderStateText(state);
      AC_L1_PENDING[next].volume = OrderGetDouble(ORDER_VOLUME_CURRENT);
      AC_L1_PENDING[next].price = OrderGetDouble(ORDER_PRICE_OPEN);
      AC_L1_PENDING[next].stop_loss = OrderGetDouble(ORDER_SL);
      AC_L1_PENDING[next].take_profit = OrderGetDouble(ORDER_TP);
      AC_L1_PENDING[next].setup_time = (datetime)OrderGetInteger(ORDER_TIME_SETUP);
      AC_L1_PENDING[next].expiration_time = (datetime)OrderGetInteger(ORDER_TIME_EXPIRATION);
      AC_L1_PENDING[next].magic = OrderGetInteger(ORDER_MAGIC);
      AC_L1_PENDING[next].comment = OrderGetString(ORDER_COMMENT);

      int s = AC_L1FindSymbolStats(AC_L1_PENDING[next].symbol);
      AC_L1_SYMBOL_STATS[s].pending_count++;
   }
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

void AC_L1ScanHistory()
{
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
      return;
   }

   int closed_in_lookback = AC_L1CountSelectedClosedTradeDeals();
   bool extend_to_minimum = (closed_in_lookback < AC_L1_CLOSED_SCAN_LIMIT);
   if(extend_to_minimum)
   {
      ResetLastError();
      if(!HistorySelect(0, to_time))
      {
         AC_L1_HISTORY_STATUS = "unavailable";
         AC_L1_HISTORY_QUALITY = "unavailable";
         AC_L1_HISTORY_NOTE = "HistorySelect extension failed; history must not be interpreted as zero";
         AC_L1_SCAN_FAILURE = "HistorySelect_extend_failed_error=" + IntegerToString(GetLastError());
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
      AC_L1AllocatedPositionCostValues(AC_L1_CLOSED[next].position_id, AC_L1_CLOSED[next].volume, AC_L1_CLOSED[next].commission, AC_L1_CLOSED[next].swap, AC_L1_CLOSED[next].fee);
      AC_L1_CLOSED[next].net_result = AC_L1_CLOSED[next].profit + AC_L1_CLOSED[next].commission + AC_L1_CLOSED[next].swap + AC_L1_CLOSED[next].fee;
      AC_L1_CLOSED[next].magic = HistoryDealGetInteger(deal_ticket, DEAL_MAGIC);
      AC_L1_CLOSED[next].comment = HistoryDealGetString(deal_ticket, DEAL_COMMENT);
      AC_L1_CLOSED[next].close_reason = HistoryDealGetInteger(deal_ticket, DEAL_REASON);
      AC_L1_CLOSED[next].source_quality = "partial_core_position_cost_allocated";
      AC_L1_CLOSED[next].entry_reconstruction_status = "unavailable";
      AC_L1_CLOSED[next].paired_entry_status = "paired_entry_unavailable";
      AC_L1_CLOSED[next].order_context_status = "order_context_unavailable";
      AC_L1_CLOSED[next].stop_loss_source = "unavailable";
      AC_L1_CLOSED[next].take_profit_source = "unavailable";

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
         AC_L1_CLOSED[next].source_quality = "core_complete_position_cost_allocated";
         AC_L1_CORE_RECONSTRUCTION_COMPLETE_COUNT++;
      }

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

      if(AC_L1_CLOSED[next].stop_loss > 0.0 && AC_L1_CLOSED[next].take_profit > 0.0)
         AC_L1_CLOSED[next].order_context_status = "protective_context_complete";
      else if(AC_L1_CLOSED[next].entry_order_ticket > 0 || AC_L1_CLOSED[next].stop_loss > 0.0 || AC_L1_CLOSED[next].take_profit > 0.0)
         AC_L1_CLOSED[next].order_context_status = "protective_context_partial";

      if(AC_L1_CLOSED[next].entry_reconstruction_status != "complete")
      {
         AC_L1_CLOSED[next].source_quality = "partial_core_position_cost_allocated";
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
}

void AC_L1AppendPortfolioMaps()
{
   AC_L1_BOARD_SECTION += AC_L1PortfolioMapSummary();
   AC_L1_ACCOUNT_STATUS_TEXT += AC_L1AccountPortfolioMapsFull();
   AC_L1_WORKBENCH_SECTION += "portfolio_maps=enabled_summary_board_full_account_status\r\n";
}

void AC_RefreshLayer1AccountTruth()
{
   AC_L1Reset();
   AC_L1RefreshAccountSnapshot();
   AC_L1ScanPositions();
   AC_L1ScanPendingOrders();
   AC_L1ScanHistory();
   AC_L1FinalizeStats();
   if(AC_L1_SCAN_STATUS == "scanning") AC_L1_SCAN_STATUS = "complete";
   AC_L1_SCAN_DURATION_MS = GetTickCount() - AC_L1_SCAN_STARTED_MS;
   AC_L1_READY = true;
   AC_BuildLayer1Texts();
   AC_L1AppendPortfolioMaps();
}

void AC_RefreshLayer1SnapshotOnly()
{
   AC_L1RefreshAccountSnapshot();
}

#endif