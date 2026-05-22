#ifndef AC_L1_OPEN_PENDING_SCAN_MQH
#define AC_L1_OPEN_PENDING_SCAN_MQH
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

#endif
