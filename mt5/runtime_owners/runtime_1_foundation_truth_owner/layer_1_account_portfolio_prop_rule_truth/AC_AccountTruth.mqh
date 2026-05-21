#ifndef AC_ACCOUNT_TRUTH_MQH
#define AC_ACCOUNT_TRUTH_MQH

// Runtime 1 owns account, portfolio, current exposure, and account activity truth.
// This owner is read-only. It reports truth and never grants permission.

static bool   AC_L1_READY = false;
static uint   AC_L1_LAST_SCAN_MS = 0;
static uint   AC_L1_SCAN_DURATION_MS = 0;
static string AC_L1_SCAN_STATUS = "not_started";
static string AC_L1_SCAN_FAILURE = "";
static string AC_L1_BOARD_SECTION = "";
static string AC_L1_WORKBENCH_SECTION = "";
static string AC_L1_ACCOUNT_STATUS_TEXT = "";
static string AC_L1_RECENT_ACTIVITY_BOARD = "";
static string AC_L1_OPEN_ROWS = "";
static string AC_L1_PENDING_ROWS = "";
static string AC_L1_CLOSED_ROWS = "";
static string AC_L1_CANCEL_ROWS = "";

static long   AC_L1_LOGIN = 0;
static string AC_L1_SERVER = "";
static string AC_L1_CURRENCY = "";
static string AC_L1_TRADE_MODE = "";
static long   AC_L1_LEVERAGE = 0;
static double AC_L1_BALANCE = 0.0;
static double AC_L1_EQUITY = 0.0;
static double AC_L1_CREDIT = 0.0;
static double AC_L1_FLOATING_PL = 0.0;
static double AC_L1_MARGIN = 0.0;
static double AC_L1_FREE_MARGIN = 0.0;
static double AC_L1_MARGIN_LEVEL = 0.0;
static int    AC_L1_OPEN_POSITIONS = 0;
static int    AC_L1_PENDING_ORDERS = 0;
static int    AC_L1_HISTORY_DEALS_TOTAL = 0;
static int    AC_L1_HISTORY_ORDERS_TOTAL = 0;
static int    AC_L1_CLOSED_TRADES = 0;
static int    AC_L1_WIN_COUNT = 0;
static int    AC_L1_LOSS_COUNT = 0;
static int    AC_L1_FILLED_ORDERS = 0;
static int    AC_L1_CANCELED_ORDERS = 0;
static double AC_L1_NET_PROFIT = 0.0;
static double AC_L1_GROSS_PROFIT = 0.0;
static double AC_L1_GROSS_LOSS = 0.0;
static double AC_L1_LARGEST_WIN = 0.0;
static double AC_L1_LARGEST_LOSS = 0.0;
static double AC_L1_BUY_NET = 0.0;
static double AC_L1_SELL_NET = 0.0;
static int    AC_L1_BUY_COUNT = 0;
static int    AC_L1_SELL_COUNT = 0;
static string AC_L1_WORST_SYMBOL = "none";
static double AC_L1_WORST_SYMBOL_NET = 0.0;
static string AC_L1_WORST_DAY = "none";
static double AC_L1_WORST_DAY_NET = 0.0;

static string AC_L1_SYMBOLS[];
static double AC_L1_SYMBOL_NET[];
static int    AC_L1_SYMBOL_CLOSED[];
static int    AC_L1_SYMBOL_WINS[];
static int    AC_L1_SYMBOL_LOSSES[];
static int    AC_L1_SYMBOL_OPEN[];
static int    AC_L1_SYMBOL_PENDING[];
static int    AC_L1_SYMBOL_CANCELED[];
static string AC_L1_SYMBOL_ROWS[];

static string AC_L1_DAYS[];
static double AC_L1_DAY_NET[];

string AC_TradeModeText(const long mode)
{
   if(mode == ACCOUNT_TRADE_MODE_DEMO)
      return "demo";
   if(mode == ACCOUNT_TRADE_MODE_CONTEST)
      return "contest";
   if(mode == ACCOUNT_TRADE_MODE_REAL)
      return "real";
   return "unknown";
}

string AC_OrderTypeText(const long type)
{
   if(type == ORDER_TYPE_BUY) return "buy";
   if(type == ORDER_TYPE_SELL) return "sell";
   if(type == ORDER_TYPE_BUY_LIMIT) return "buy_limit";
   if(type == ORDER_TYPE_SELL_LIMIT) return "sell_limit";
   if(type == ORDER_TYPE_BUY_STOP) return "buy_stop";
   if(type == ORDER_TYPE_SELL_STOP) return "sell_stop";
   if(type == ORDER_TYPE_BUY_STOP_LIMIT) return "buy_stop_limit";
   if(type == ORDER_TYPE_SELL_STOP_LIMIT) return "sell_stop_limit";
   return "unknown";
}

string AC_OrderStateText(const long state)
{
   if(state == ORDER_STATE_STARTED) return "started";
   if(state == ORDER_STATE_PLACED) return "placed";
   if(state == ORDER_STATE_CANCELED) return "canceled";
   if(state == ORDER_STATE_PARTIAL) return "partial";
   if(state == ORDER_STATE_FILLED) return "filled";
   if(state == ORDER_STATE_REJECTED) return "rejected";
   if(state == ORDER_STATE_EXPIRED) return "expired";
   if(state == ORDER_STATE_REQUEST_ADD) return "request_add";
   if(state == ORDER_STATE_REQUEST_MODIFY) return "request_modify";
   if(state == ORDER_STATE_REQUEST_CANCEL) return "request_cancel";
   return "unknown";
}

string AC_PositionTypeText(const long type)
{
   if(type == POSITION_TYPE_BUY) return "buy";
   if(type == POSITION_TYPE_SELL) return "sell";
   return "unknown";
}

string AC_DealTypeText(const long type)
{
   if(type == DEAL_TYPE_BUY) return "buy";
   if(type == DEAL_TYPE_SELL) return "sell";
   if(type == DEAL_TYPE_BALANCE) return "balance";
   if(type == DEAL_TYPE_CREDIT) return "credit";
   if(type == DEAL_TYPE_CHARGE) return "charge";
   if(type == DEAL_TYPE_CORRECTION) return "correction";
   if(type == DEAL_TYPE_BONUS) return "bonus";
   if(type == DEAL_TYPE_COMMISSION) return "commission";
   if(type == DEAL_TYPE_SWAP) return "swap";
   return "other";
}

string AC_DateText(const datetime value)
{
   return TimeToString(value, TIME_DATE | TIME_SECONDS);
}

int AC_L1_FindSymbol(const string symbol)
{
   int n = ArraySize(AC_L1_SYMBOLS);
   for(int i = 0; i < n; i++)
   {
      if(AC_L1_SYMBOLS[i] == symbol)
         return i;
   }

   ArrayResize(AC_L1_SYMBOLS, n + 1);
   ArrayResize(AC_L1_SYMBOL_NET, n + 1);
   ArrayResize(AC_L1_SYMBOL_CLOSED, n + 1);
   ArrayResize(AC_L1_SYMBOL_WINS, n + 1);
   ArrayResize(AC_L1_SYMBOL_LOSSES, n + 1);
   ArrayResize(AC_L1_SYMBOL_OPEN, n + 1);
   ArrayResize(AC_L1_SYMBOL_PENDING, n + 1);
   ArrayResize(AC_L1_SYMBOL_CANCELED, n + 1);
   ArrayResize(AC_L1_SYMBOL_ROWS, n + 1);

   AC_L1_SYMBOLS[n] = symbol;
   AC_L1_SYMBOL_NET[n] = 0.0;
   AC_L1_SYMBOL_CLOSED[n] = 0;
   AC_L1_SYMBOL_WINS[n] = 0;
   AC_L1_SYMBOL_LOSSES[n] = 0;
   AC_L1_SYMBOL_OPEN[n] = 0;
   AC_L1_SYMBOL_PENDING[n] = 0;
   AC_L1_SYMBOL_CANCELED[n] = 0;
   AC_L1_SYMBOL_ROWS[n] = "";
   return n;
}

int AC_L1_FindDay(const string day)
{
   int n = ArraySize(AC_L1_DAYS);
   for(int i = 0; i < n; i++)
   {
      if(AC_L1_DAYS[i] == day)
         return i;
   }
   ArrayResize(AC_L1_DAYS, n + 1);
   ArrayResize(AC_L1_DAY_NET, n + 1);
   AC_L1_DAYS[n] = day;
   AC_L1_DAY_NET[n] = 0.0;
   return n;
}

void AC_L1_AddSymbolRow(const string symbol, const string row)
{
   if(symbol == "") return;
   int idx = AC_L1_FindSymbol(symbol);
   AC_L1_SYMBOL_ROWS[idx] += row + "\r\n";
}

void AC_L1_ResetData()
{
   AC_L1_SCAN_STATUS = "scanning";
   AC_L1_SCAN_FAILURE = "";
   AC_L1_BOARD_SECTION = "";
   AC_L1_WORKBENCH_SECTION = "";
   AC_L1_ACCOUNT_STATUS_TEXT = "";
   AC_L1_RECENT_ACTIVITY_BOARD = "";
   AC_L1_OPEN_ROWS = "";
   AC_L1_PENDING_ROWS = "";
   AC_L1_CLOSED_ROWS = "";
   AC_L1_CANCEL_ROWS = "";

   AC_L1_OPEN_POSITIONS = 0;
   AC_L1_PENDING_ORDERS = 0;
   AC_L1_HISTORY_DEALS_TOTAL = 0;
   AC_L1_HISTORY_ORDERS_TOTAL = 0;
   AC_L1_CLOSED_TRADES = 0;
   AC_L1_WIN_COUNT = 0;
   AC_L1_LOSS_COUNT = 0;
   AC_L1_FILLED_ORDERS = 0;
   AC_L1_CANCELED_ORDERS = 0;
   AC_L1_NET_PROFIT = 0.0;
   AC_L1_GROSS_PROFIT = 0.0;
   AC_L1_GROSS_LOSS = 0.0;
   AC_L1_LARGEST_WIN = 0.0;
   AC_L1_LARGEST_LOSS = 0.0;
   AC_L1_BUY_NET = 0.0;
   AC_L1_SELL_NET = 0.0;
   AC_L1_BUY_COUNT = 0;
   AC_L1_SELL_COUNT = 0;
   AC_L1_WORST_SYMBOL = "none";
   AC_L1_WORST_SYMBOL_NET = 0.0;
   AC_L1_WORST_DAY = "none";
   AC_L1_WORST_DAY_NET = 0.0;

   ArrayResize(AC_L1_SYMBOLS, 0);
   ArrayResize(AC_L1_SYMBOL_NET, 0);
   ArrayResize(AC_L1_SYMBOL_CLOSED, 0);
   ArrayResize(AC_L1_SYMBOL_WINS, 0);
   ArrayResize(AC_L1_SYMBOL_LOSSES, 0);
   ArrayResize(AC_L1_SYMBOL_OPEN, 0);
   ArrayResize(AC_L1_SYMBOL_PENDING, 0);
   ArrayResize(AC_L1_SYMBOL_CANCELED, 0);
   ArrayResize(AC_L1_SYMBOL_ROWS, 0);
   ArrayResize(AC_L1_DAYS, 0);
   ArrayResize(AC_L1_DAY_NET, 0);
}

void AC_RefreshLayer1SnapshotOnly()
{
   AC_L1_LOGIN = AccountInfoInteger(ACCOUNT_LOGIN);
   AC_L1_SERVER = AccountInfoString(ACCOUNT_SERVER);
   AC_L1_CURRENCY = AccountInfoString(ACCOUNT_CURRENCY);
   AC_L1_TRADE_MODE = AC_TradeModeText(AccountInfoInteger(ACCOUNT_TRADE_MODE));
   AC_L1_LEVERAGE = AccountInfoInteger(ACCOUNT_LEVERAGE);
   AC_L1_BALANCE = AccountInfoDouble(ACCOUNT_BALANCE);
   AC_L1_EQUITY = AccountInfoDouble(ACCOUNT_EQUITY);
   AC_L1_CREDIT = AccountInfoDouble(ACCOUNT_CREDIT);
   AC_L1_FLOATING_PL = AccountInfoDouble(ACCOUNT_PROFIT);
   AC_L1_MARGIN = AccountInfoDouble(ACCOUNT_MARGIN);
   AC_L1_FREE_MARGIN = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   AC_L1_MARGIN_LEVEL = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
   AC_L1_OPEN_POSITIONS = PositionsTotal();
   AC_L1_PENDING_ORDERS = OrdersTotal();
}

void AC_L1_AppendRecentBoardRow(const string row, int &count)
{
   if(count >= AC_BOARD_RECENT_ACTIVITY_MAX_ROWS) return;
   AC_L1_RECENT_ACTIVITY_BOARD += row + "\r\n";
   count++;
}

void AC_BuildLayer1Texts()
{
   double profit_factor = (AC_L1_GROSS_LOSS < 0.0 ? AC_L1_GROSS_PROFIT / MathAbs(AC_L1_GROSS_LOSS) : 0.0);
   double expected_payoff = (AC_L1_CLOSED_TRADES > 0 ? AC_L1_NET_PROFIT / AC_L1_CLOSED_TRADES : 0.0);
   double win_rate = (AC_L1_CLOSED_TRADES > 0 ? ((double)AC_L1_WIN_COUNT * 100.0) / AC_L1_CLOSED_TRADES : 0.0);
   double avg_win = (AC_L1_WIN_COUNT > 0 ? AC_L1_GROSS_PROFIT / AC_L1_WIN_COUNT : 0.0);
   double avg_loss = (AC_L1_LOSS_COUNT > 0 ? AC_L1_GROSS_LOSS / AC_L1_LOSS_COUNT : 0.0);

   AC_L1_BOARD_SECTION = "\r\nLAYER 1 - ACCOUNT / PORTFOLIO\r\n";
   AC_L1_BOARD_SECTION += "----------------------------------------\r\n";
   AC_L1_BOARD_SECTION += "Account:          " + IntegerToString((int)AC_L1_LOGIN) + " / " + AC_L1_SERVER + "\r\n";
   AC_L1_BOARD_SECTION += "Currency:         " + AC_L1_CURRENCY + "\r\n";
   AC_L1_BOARD_SECTION += "Mode:             " + AC_L1_TRADE_MODE + "\r\n";
   AC_L1_BOARD_SECTION += "Leverage:         1:" + IntegerToString((int)AC_L1_LEVERAGE) + "\r\n";
   AC_L1_BOARD_SECTION += "Balance:          " + DoubleToString(AC_L1_BALANCE, 2) + "\r\n";
   AC_L1_BOARD_SECTION += "Equity:           " + DoubleToString(AC_L1_EQUITY, 2) + "\r\n";
   AC_L1_BOARD_SECTION += "Floating P/L:     " + DoubleToString(AC_L1_FLOATING_PL, 2) + "\r\n";
   AC_L1_BOARD_SECTION += "Margin Used:      " + DoubleToString(AC_L1_MARGIN, 2) + "\r\n";
   AC_L1_BOARD_SECTION += "Free Margin:      " + DoubleToString(AC_L1_FREE_MARGIN, 2) + "\r\n";
   AC_L1_BOARD_SECTION += "Open Positions:   " + IntegerToString(AC_L1_OPEN_POSITIONS) + "\r\n";
   AC_L1_BOARD_SECTION += "Pending Orders:   " + IntegerToString(AC_L1_PENDING_ORDERS) + "\r\n";
   AC_L1_BOARD_SECTION += "\r\nHistory Summary\r\n";
   AC_L1_BOARD_SECTION += "Closed Trades:    " + IntegerToString(AC_L1_CLOSED_TRADES) + "\r\n";
   AC_L1_BOARD_SECTION += "Net P/L:          " + DoubleToString(AC_L1_NET_PROFIT, 2) + "\r\n";
   AC_L1_BOARD_SECTION += "Gross Profit:     " + DoubleToString(AC_L1_GROSS_PROFIT, 2) + "\r\n";
   AC_L1_BOARD_SECTION += "Gross Loss:       " + DoubleToString(AC_L1_GROSS_LOSS, 2) + "\r\n";
   AC_L1_BOARD_SECTION += "Profit Factor:    " + DoubleToString(profit_factor, 2) + "\r\n";
   AC_L1_BOARD_SECTION += "Expected Payoff:  " + DoubleToString(expected_payoff, 2) + "\r\n";
   AC_L1_BOARD_SECTION += "Win Rate:         " + DoubleToString(win_rate, 2) + "%\r\n";
   AC_L1_BOARD_SECTION += "Avg Win:          " + DoubleToString(avg_win, 2) + "\r\n";
   AC_L1_BOARD_SECTION += "Avg Loss:         " + DoubleToString(avg_loss, 2) + "\r\n";
   AC_L1_BOARD_SECTION += "Largest Win:      " + DoubleToString(AC_L1_LARGEST_WIN, 2) + "\r\n";
   AC_L1_BOARD_SECTION += "Largest Loss:     " + DoubleToString(AC_L1_LARGEST_LOSS, 2) + "\r\n";
   AC_L1_BOARD_SECTION += "Filled Orders:    " + IntegerToString(AC_L1_FILLED_ORDERS) + "\r\n";
   AC_L1_BOARD_SECTION += "Canceled Orders:  " + IntegerToString(AC_L1_CANCELED_ORDERS) + "\r\n";
   AC_L1_BOARD_SECTION += "Worst Symbol:     " + AC_L1_WORST_SYMBOL + " " + DoubleToString(AC_L1_WORST_SYMBOL_NET, 2) + "\r\n";
   AC_L1_BOARD_SECTION += "Worst Day:        " + AC_L1_WORST_DAY + " " + DoubleToString(AC_L1_WORST_DAY_NET, 2) + "\r\n";
   AC_L1_BOARD_SECTION += "Trade Permission: FALSE\r\n";
   AC_L1_BOARD_SECTION += "Main Blocker:     Layer 1 reports account truth only; permission owner is inactive.\r\n";
   AC_L1_BOARD_SECTION += "\r\nRECENT ACCOUNT ACTIVITY - MAX 100\r\n";
   AC_L1_BOARD_SECTION += "----------------------------------------\r\n";
   AC_L1_BOARD_SECTION += (AC_L1_RECENT_ACTIVITY_BOARD == "" ? "none\r\n" : AC_L1_RECENT_ACTIVITY_BOARD);

   AC_L1_WORKBENCH_SECTION = "L1_ACCOUNT_PORTFOLIO_SCAN\r\n";
   AC_L1_WORKBENCH_SECTION += "----------------------------------------\r\n";
   AC_L1_WORKBENCH_SECTION += "scan_status=" + AC_L1_SCAN_STATUS + "\r\n";
   AC_L1_WORKBENCH_SECTION += "scan_duration_ms=" + IntegerToString((int)AC_L1_SCAN_DURATION_MS) + "\r\n";
   AC_L1_WORKBENCH_SECTION += "history_deals_total=" + IntegerToString(AC_L1_HISTORY_DEALS_TOTAL) + "\r\n";
   AC_L1_WORKBENCH_SECTION += "history_orders_total=" + IntegerToString(AC_L1_HISTORY_ORDERS_TOTAL) + "\r\n";
   AC_L1_WORKBENCH_SECTION += "scan_failure=" + AC_L1_SCAN_FAILURE + "\r\n";
   AC_L1_WORKBENCH_SECTION += "board_rows_max=" + IntegerToString(AC_BOARD_RECENT_ACTIVITY_MAX_ROWS) + "\r\n";
   AC_L1_WORKBENCH_SECTION += "symbol_dossier_rows_max=" + IntegerToString(AC_DOSSIER_SYMBOL_ACTIVITY_MAX_ROWS) + "\r\n";

   AC_L1_ACCOUNT_STATUS_TEXT = "system_name=" + AC_SYSTEM_NAME + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "build_version=" + AC_BUILD_VERSION + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "upgrade_id=" + AC_UPGRADE_ID + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "runtime_owner=" + AC_RUNTIME1_OWNER + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "layer_name=" + AC_LAYER_1_NAME + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "scan_status=" + AC_L1_SCAN_STATUS + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += AC_L1_BOARD_SECTION + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "OPEN POSITIONS FULL\r\n----------------------------------------\r\n" + (AC_L1_OPEN_ROWS == "" ? "none\r\n" : AC_L1_OPEN_ROWS) + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "PENDING ORDERS FULL\r\n----------------------------------------\r\n" + (AC_L1_PENDING_ROWS == "" ? "none\r\n" : AC_L1_PENDING_ROWS) + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "CLOSED DEAL HISTORY FULL\r\n----------------------------------------\r\n" + (AC_L1_CLOSED_ROWS == "" ? "none\r\n" : AC_L1_CLOSED_ROWS) + "\r\n";
   AC_L1_ACCOUNT_STATUS_TEXT += "CANCELED / EXPIRED / REJECTED ORDERS\r\n----------------------------------------\r\n" + (AC_L1_CANCEL_ROWS == "" ? "none\r\n" : AC_L1_CANCEL_ROWS) + "\r\n";
}

void AC_RefreshLayer1AccountTruth()
{
   uint start_ms = GetTickCount();
   AC_L1_ResetData();
   AC_RefreshLayer1SnapshotOnly();

   int recent_count = 0;

   for(int p = 0; p < PositionsTotal(); p++)
   {
      ulong ticket = PositionGetTicket(p);
      if(ticket == 0) continue;
      string symbol = PositionGetString(POSITION_SYMBOL);
      long type = PositionGetInteger(POSITION_TYPE);
      double volume = PositionGetDouble(POSITION_VOLUME);
      double price = PositionGetDouble(POSITION_PRICE_OPEN);
      double profit = PositionGetDouble(POSITION_PROFIT);
      int idx = AC_L1_FindSymbol(symbol);
      AC_L1_SYMBOL_OPEN[idx]++;
      string row = "OPEN|ticket=" + IntegerToString((int)ticket) + "|symbol=" + symbol + "|side=" + AC_PositionTypeText(type) + "|volume=" + DoubleToString(volume, 2) + "|price=" + DoubleToString(price, 5) + "|profit=" + DoubleToString(profit, 2);
      AC_L1_OPEN_ROWS += row + "\r\n";
      AC_L1_AddSymbolRow(symbol, row);
      AC_L1_AppendRecentBoardRow(row, recent_count);
   }

   for(int o = 0; o < OrdersTotal(); o++)
   {
      ulong ticket = OrderGetTicket(o);
      if(ticket == 0) continue;
      string symbol = OrderGetString(ORDER_SYMBOL);
      long type = OrderGetInteger(ORDER_TYPE);
      double volume = OrderGetDouble(ORDER_VOLUME_CURRENT);
      double price = OrderGetDouble(ORDER_PRICE_OPEN);
      datetime setup_time = (datetime)OrderGetInteger(ORDER_TIME_SETUP);
      int idx = AC_L1_FindSymbol(symbol);
      AC_L1_SYMBOL_PENDING[idx]++;
      string row = "PENDING|time=" + AC_DateText(setup_time) + "|ticket=" + IntegerToString((int)ticket) + "|symbol=" + symbol + "|type=" + AC_OrderTypeText(type) + "|volume=" + DoubleToString(volume, 2) + "|price=" + DoubleToString(price, 5);
      AC_L1_PENDING_ROWS += row + "\r\n";
      AC_L1_AddSymbolRow(symbol, row);
      AC_L1_AppendRecentBoardRow(row, recent_count);
   }

   datetime to_time = TimeCurrent();
   bool history_ok = HistorySelect(0, to_time);
   if(!history_ok)
   {
      AC_L1_SCAN_STATUS = "history_select_failed";
      AC_L1_SCAN_FAILURE = "HistorySelect_failed_error=" + IntegerToString(GetLastError());
   }
   else
   {
      AC_L1_HISTORY_DEALS_TOTAL = HistoryDealsTotal();
      AC_L1_HISTORY_ORDERS_TOTAL = HistoryOrdersTotal();

      for(int d = 0; d < AC_L1_HISTORY_DEALS_TOTAL; d++)
      {
         ulong ticket = HistoryDealGetTicket(d);
         if(ticket == 0) continue;
         string symbol = HistoryDealGetString(ticket, DEAL_SYMBOL);
         long type = HistoryDealGetInteger(ticket, DEAL_TYPE);
         long entry = HistoryDealGetInteger(ticket, DEAL_ENTRY);
         datetime time = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
         double volume = HistoryDealGetDouble(ticket, DEAL_VOLUME);
         double price = HistoryDealGetDouble(ticket, DEAL_PRICE);
         double net = HistoryDealGetDouble(ticket, DEAL_PROFIT) + HistoryDealGetDouble(ticket, DEAL_SWAP) + HistoryDealGetDouble(ticket, DEAL_COMMISSION);

         if(symbol == "") continue;
         if(type != DEAL_TYPE_BUY && type != DEAL_TYPE_SELL) continue;
         if(entry != DEAL_ENTRY_OUT && entry != DEAL_ENTRY_INOUT && entry != DEAL_ENTRY_OUT_BY) continue;

         AC_L1_CLOSED_TRADES++;
         AC_L1_NET_PROFIT += net;
         if(net > 0.0)
         {
            AC_L1_WIN_COUNT++;
            AC_L1_GROSS_PROFIT += net;
            if(net > AC_L1_LARGEST_WIN) AC_L1_LARGEST_WIN = net;
         }
         else if(net < 0.0)
         {
            AC_L1_LOSS_COUNT++;
            AC_L1_GROSS_LOSS += net;
            if(net < AC_L1_LARGEST_LOSS) AC_L1_LARGEST_LOSS = net;
         }

         if(type == DEAL_TYPE_BUY) { AC_L1_BUY_COUNT++; AC_L1_BUY_NET += net; }
         if(type == DEAL_TYPE_SELL) { AC_L1_SELL_COUNT++; AC_L1_SELL_NET += net; }

         int sidx = AC_L1_FindSymbol(symbol);
         AC_L1_SYMBOL_NET[sidx] += net;
         AC_L1_SYMBOL_CLOSED[sidx]++;
         if(net > 0.0) AC_L1_SYMBOL_WINS[sidx]++;
         if(net < 0.0) AC_L1_SYMBOL_LOSSES[sidx]++;

         string day = TimeToString(time, TIME_DATE);
         int didx = AC_L1_FindDay(day);
         AC_L1_DAY_NET[didx] += net;

         string row = "CLOSED|time=" + AC_DateText(time) + "|ticket=" + IntegerToString((int)ticket) + "|symbol=" + symbol + "|side=" + AC_DealTypeText(type) + "|volume=" + DoubleToString(volume, 2) + "|price=" + DoubleToString(price, 5) + "|net=" + DoubleToString(net, 2);
         AC_L1_CLOSED_ROWS += row + "\r\n";
         AC_L1_AddSymbolRow(symbol, row);
      }

      int canceled_board_count = 0;
      for(int h = AC_L1_HISTORY_ORDERS_TOTAL - 1; h >= 0; h--)
      {
         ulong order_ticket = HistoryOrderGetTicket(h);
         if(order_ticket == 0) continue;
         long state = HistoryOrderGetInteger(order_ticket, ORDER_STATE);
         if(state == ORDER_STATE_FILLED || state == ORDER_STATE_PARTIAL)
            AC_L1_FILLED_ORDERS++;

         bool is_cancel_like = (state == ORDER_STATE_CANCELED || state == ORDER_STATE_REJECTED || state == ORDER_STATE_EXPIRED);
         if(!is_cancel_like) continue;

         AC_L1_CANCELED_ORDERS++;
         string symbol = HistoryOrderGetString(order_ticket, ORDER_SYMBOL);
         long type = HistoryOrderGetInteger(order_ticket, ORDER_TYPE);
         double volume = HistoryOrderGetDouble(order_ticket, ORDER_VOLUME_INITIAL);
         double price = HistoryOrderGetDouble(order_ticket, ORDER_PRICE_OPEN);
         datetime setup_time = (datetime)HistoryOrderGetInteger(order_ticket, ORDER_TIME_SETUP);
         int sidx = AC_L1_FindSymbol(symbol);
         AC_L1_SYMBOL_CANCELED[sidx]++;
         string row = "CANCELED|time=" + AC_DateText(setup_time) + "|ticket=" + IntegerToString((int)order_ticket) + "|symbol=" + symbol + "|type=" + AC_OrderTypeText(type) + "|state=" + AC_OrderStateText(state) + "|volume=" + DoubleToString(volume, 2) + "|price=" + DoubleToString(price, 5);
         if(canceled_board_count < AC_BOARD_CANCELED_ACTIVITY_MAX_ROWS)
         {
            AC_L1_CANCEL_ROWS += row + "\r\n";
            AC_L1_AppendRecentBoardRow(row, recent_count);
            canceled_board_count++;
         }
         AC_L1_AddSymbolRow(symbol, row);
      }
   }

   for(int i = 0; i < ArraySize(AC_L1_SYMBOLS); i++)
   {
      if(AC_L1_SYMBOL_NET[i] < AC_L1_WORST_SYMBOL_NET)
      {
         AC_L1_WORST_SYMBOL_NET = AC_L1_SYMBOL_NET[i];
         AC_L1_WORST_SYMBOL = AC_L1_SYMBOLS[i];
      }
   }
   for(int j = 0; j < ArraySize(AC_L1_DAYS); j++)
   {
      if(AC_L1_DAY_NET[j] < AC_L1_WORST_DAY_NET)
      {
         AC_L1_WORST_DAY_NET = AC_L1_DAY_NET[j];
         AC_L1_WORST_DAY = AC_L1_DAYS[j];
      }
   }

   if(AC_L1_SCAN_STATUS == "scanning")
      AC_L1_SCAN_STATUS = "complete";
   AC_L1_SCAN_DURATION_MS = GetTickCount() - start_ms;
   AC_L1_LAST_SCAN_MS = GetTickCount();
   AC_L1_READY = true;
   AC_BuildLayer1Texts();
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
   text += "account_balance=" + DoubleToString(AC_L1_BALANCE, 2) + "\r\n";
   text += "account_equity=" + DoubleToString(AC_L1_EQUITY, 2) + "\r\n";
   text += "floating_pl=" + DoubleToString(AC_L1_FLOATING_PL, 2) + "\r\n";
   text += "margin_used=" + DoubleToString(AC_L1_MARGIN, 2) + "\r\n";
   text += "free_margin=" + DoubleToString(AC_L1_FREE_MARGIN, 2) + "\r\n";
   int idx = -1;
   for(int i = 0; i < ArraySize(AC_L1_SYMBOLS); i++) if(AC_L1_SYMBOLS[i] == symbol) { idx = i; break; }
   if(idx < 0)
   {
      text += "symbol_account_state=no_account_activity_found\r\n";
      text += "trade_permission=false\r\n";
      return text;
   }
   double symbol_win_rate = (AC_L1_SYMBOL_CLOSED[idx] > 0 ? ((double)AC_L1_SYMBOL_WINS[idx] * 100.0) / AC_L1_SYMBOL_CLOSED[idx] : 0.0);
   text += "symbol_account_state=" + ((AC_L1_SYMBOL_OPEN[idx] > 0) ? "open_position" : ((AC_L1_SYMBOL_PENDING[idx] > 0) ? "pending_order" : ((AC_L1_SYMBOL_CLOSED[idx] > 0 || AC_L1_SYMBOL_CANCELED[idx] > 0) ? "history_only" : "no_activity"))) + "\r\n";
   text += "open_position_count=" + IntegerToString(AC_L1_SYMBOL_OPEN[idx]) + "\r\n";
   text += "pending_order_count=" + IntegerToString(AC_L1_SYMBOL_PENDING[idx]) + "\r\n";
   text += "closed_trades=" + IntegerToString(AC_L1_SYMBOL_CLOSED[idx]) + "\r\n";
   text += "canceled_orders=" + IntegerToString(AC_L1_SYMBOL_CANCELED[idx]) + "\r\n";
   text += "symbol_net_pl=" + DoubleToString(AC_L1_SYMBOL_NET[idx], 2) + "\r\n";
   text += "symbol_win_rate=" + DoubleToString(symbol_win_rate, 2) + "%\r\n";
   text += "trade_permission=false\r\n";
   text += "symbol_activity_rows\r\n";
   text += (AC_L1_SYMBOL_ROWS[idx] == "" ? "none\r\n" : AC_L1_SYMBOL_ROWS[idx]);
   return text;
}

string AC_AccountTruthText()
{
   if(!AC_L1_READY) AC_RefreshLayer1AccountTruth();
   return AC_L1_ACCOUNT_STATUS_TEXT;
}

string AC_AccountTruthStatusRow(const AC_WriteResult &account_write)
{
   return "schema_name=layer_status|schema_version=v1.0|layer_id=1|layer_name=" + AC_LAYER_1_NAME
      + "|source_owner=" + AC_RUNTIME1_OWNER
      + "|build_version=" + AC_BUILD_VERSION
      + "|upgrade_id=" + AC_UPGRADE_ID
      + "|layer_status=" + (AC_L1_READY && account_write.ok ? "complete" : "complete_with_degraded")
      + "|account_status_available=" + AC_BoolText(account_write.ok)
      + "|closed_trades=" + IntegerToString(AC_L1_CLOSED_TRADES)
      + "|history_deals_total=" + IntegerToString(AC_L1_HISTORY_DEALS_TOTAL)
      + "|history_orders_total=" + IntegerToString(AC_L1_HISTORY_ORDERS_TOTAL)
      + "|scan_status=" + AC_L1_SCAN_STATUS
      + "|trade_permission=false";
}

#endif