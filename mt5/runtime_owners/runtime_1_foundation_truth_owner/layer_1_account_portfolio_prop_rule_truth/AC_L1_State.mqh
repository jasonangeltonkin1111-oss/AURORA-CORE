#ifndef AC_L1_STATE_MQH
#define AC_L1_STATE_MQH

static bool   AC_L1_READY = false;
static uint   AC_L1_SCAN_STARTED_MS = 0;
static uint   AC_L1_SCAN_DURATION_MS = 0;
static string AC_L1_SCAN_STATUS = "not_started";
static string AC_L1_SCAN_FAILURE = "";
static string AC_L1_HISTORY_STATUS = "not_selected";
static string AC_L1_HISTORY_QUALITY = "unknown";
static string AC_L1_HISTORY_NOTE = "history not scanned yet";

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

static AC_L1PositionRow AC_L1_POSITIONS[];
static AC_L1PendingOrderRow AC_L1_PENDING[];
static AC_L1ClosedTradeRow AC_L1_CLOSED[];
static AC_L1OrderEventRow AC_L1_CANCELS[];
static AC_L1SymbolStats AC_L1_SYMBOL_STATS[];
static AC_L1DayStats AC_L1_DAY_STATS[];

static int    AC_L1_HISTORY_DEALS_TOTAL = 0;
static int    AC_L1_HISTORY_ORDERS_TOTAL = 0;
static int    AC_L1_FILLED_ORDERS = 0;
static int    AC_L1_CANCEL_LIKE_ORDERS = 0;
static int    AC_L1_PARTIAL_RECONSTRUCTION_COUNT = 0;
static int    AC_L1_ORDER_CONTEXT_PARTIAL_COUNT = 0;
static int    AC_L1_CORE_RECONSTRUCTION_COMPLETE_COUNT = 0;
static int    AC_L1_RECENT_BOARD_ROWS = 0;

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
static string AC_L1_BEST_SYMBOL = "none";
static double AC_L1_BEST_SYMBOL_NET = 0.0;
static string AC_L1_WORST_DAY = "none";
static double AC_L1_WORST_DAY_NET = 0.0;
static string AC_L1_BEST_DAY = "none";
static double AC_L1_BEST_DAY_NET = 0.0;
static long   AC_L1_DURATION_SUM_SECONDS = 0;
static int    AC_L1_DURATION_COUNT = 0;

static string AC_L1_BOARD_SECTION = "";
static string AC_L1_WORKBENCH_SECTION = "";
static string AC_L1_ACCOUNT_STATUS_TEXT = "";

void AC_L1Reset()
{
   AC_L1_READY = false;
   AC_L1_SCAN_STARTED_MS = GetTickCount();
   AC_L1_SCAN_DURATION_MS = 0;
   AC_L1_SCAN_STATUS = "scanning";
   AC_L1_SCAN_FAILURE = "";
   AC_L1_HISTORY_STATUS = "not_selected";
   AC_L1_HISTORY_QUALITY = "unknown";
   AC_L1_HISTORY_NOTE = "history scan started";

   ArrayResize(AC_L1_POSITIONS, 0);
   ArrayResize(AC_L1_PENDING, 0);
   ArrayResize(AC_L1_CLOSED, 0);
   ArrayResize(AC_L1_CANCELS, 0);
   ArrayResize(AC_L1_SYMBOL_STATS, 0);
   ArrayResize(AC_L1_DAY_STATS, 0);

   AC_L1_HISTORY_DEALS_TOTAL = 0;
   AC_L1_HISTORY_ORDERS_TOTAL = 0;
   AC_L1_FILLED_ORDERS = 0;
   AC_L1_CANCEL_LIKE_ORDERS = 0;
   AC_L1_PARTIAL_RECONSTRUCTION_COUNT = 0;
   AC_L1_ORDER_CONTEXT_PARTIAL_COUNT = 0;
   AC_L1_CORE_RECONSTRUCTION_COMPLETE_COUNT = 0;
   AC_L1_RECENT_BOARD_ROWS = 0;

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
   AC_L1_BEST_SYMBOL = "none";
   AC_L1_BEST_SYMBOL_NET = 0.0;
   AC_L1_WORST_DAY = "none";
   AC_L1_WORST_DAY_NET = 0.0;
   AC_L1_BEST_DAY = "none";
   AC_L1_BEST_DAY_NET = 0.0;
   AC_L1_DURATION_SUM_SECONDS = 0;
   AC_L1_DURATION_COUNT = 0;

   AC_L1_BOARD_SECTION = "";
   AC_L1_WORKBENCH_SECTION = "";
   AC_L1_ACCOUNT_STATUS_TEXT = "";
}

void AC_L1RefreshAccountSnapshot()
{
   AC_L1_LOGIN = AccountInfoInteger(ACCOUNT_LOGIN);
   AC_L1_SERVER = AccountInfoString(ACCOUNT_SERVER);
   AC_L1_CURRENCY = AccountInfoString(ACCOUNT_CURRENCY);
   AC_L1_TRADE_MODE = AC_L1TradeModeText(AccountInfoInteger(ACCOUNT_TRADE_MODE));
   AC_L1_LEVERAGE = AccountInfoInteger(ACCOUNT_LEVERAGE);
   AC_L1_BALANCE = AccountInfoDouble(ACCOUNT_BALANCE);
   AC_L1_EQUITY = AccountInfoDouble(ACCOUNT_EQUITY);
   AC_L1_CREDIT = AccountInfoDouble(ACCOUNT_CREDIT);
   AC_L1_FLOATING_PL = AccountInfoDouble(ACCOUNT_PROFIT);
   AC_L1_MARGIN = AccountInfoDouble(ACCOUNT_MARGIN);
   AC_L1_FREE_MARGIN = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   AC_L1_MARGIN_LEVEL = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
}

int AC_L1FindSymbolStats(const string symbol)
{
   int total = ArraySize(AC_L1_SYMBOL_STATS);
   for(int i = 0; i < total; i++)
      if(AC_L1_SYMBOL_STATS[i].symbol == symbol) return i;

   ArrayResize(AC_L1_SYMBOL_STATS, total + 1);
   AC_L1_SYMBOL_STATS[total].symbol = symbol;
   AC_L1_SYMBOL_STATS[total].net_result = 0.0;
   AC_L1_SYMBOL_STATS[total].closed_count = 0;
   AC_L1_SYMBOL_STATS[total].win_count = 0;
   AC_L1_SYMBOL_STATS[total].loss_count = 0;
   AC_L1_SYMBOL_STATS[total].open_count = 0;
   AC_L1_SYMBOL_STATS[total].pending_count = 0;
   AC_L1_SYMBOL_STATS[total].canceled_count = 0;
   return total;
}

int AC_L1FindDayStats(const string day)
{
   int total = ArraySize(AC_L1_DAY_STATS);
   for(int i = 0; i < total; i++)
      if(AC_L1_DAY_STATS[i].day == day) return i;

   ArrayResize(AC_L1_DAY_STATS, total + 1);
   AC_L1_DAY_STATS[total].day = day;
   AC_L1_DAY_STATS[total].net_result = 0.0;
   AC_L1_DAY_STATS[total].closed_count = 0;
   return total;
}

void AC_L1FinalizeStats()
{
   for(int i = 0; i < ArraySize(AC_L1_SYMBOL_STATS); i++)
   {
      if(AC_L1_SYMBOL_STATS[i].net_result < AC_L1_WORST_SYMBOL_NET)
      {
         AC_L1_WORST_SYMBOL_NET = AC_L1_SYMBOL_STATS[i].net_result;
         AC_L1_WORST_SYMBOL = AC_L1_SYMBOL_STATS[i].symbol;
      }
      if(AC_L1_SYMBOL_STATS[i].closed_count > 0 && (AC_L1_BEST_SYMBOL == "none" || AC_L1_SYMBOL_STATS[i].net_result > AC_L1_BEST_SYMBOL_NET))
      {
         AC_L1_BEST_SYMBOL_NET = AC_L1_SYMBOL_STATS[i].net_result;
         AC_L1_BEST_SYMBOL = AC_L1_SYMBOL_STATS[i].symbol;
      }
   }

   for(int j = 0; j < ArraySize(AC_L1_DAY_STATS); j++)
   {
      if(AC_L1_DAY_STATS[j].net_result < AC_L1_WORST_DAY_NET)
      {
         AC_L1_WORST_DAY_NET = AC_L1_DAY_STATS[j].net_result;
         AC_L1_WORST_DAY = AC_L1_DAY_STATS[j].day;
      }
      if(AC_L1_DAY_STATS[j].closed_count > 0 && (AC_L1_BEST_DAY == "none" || AC_L1_DAY_STATS[j].net_result > AC_L1_BEST_DAY_NET))
      {
         AC_L1_BEST_DAY_NET = AC_L1_DAY_STATS[j].net_result;
         AC_L1_BEST_DAY = AC_L1_DAY_STATS[j].day;
      }
   }
}

#endif