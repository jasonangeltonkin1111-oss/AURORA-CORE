#ifndef AC_L2_STATE_MQH
#define AC_L2_STATE_MQH

static bool     AC_L2_READY = false;
static uint     AC_L2_SCAN_STARTED_MS = 0;
static uint     AC_L2_SCAN_DURATION_MS = 0;
static double   AC_L2_SYMBOLS_PER_SECOND = 0.0;
static string   AC_L2_SCAN_STATUS = "not_started";
static string   AC_L2_SCAN_FAILURE = "";
static datetime AC_L2_LAST_FULL_SCAN_TIME = 0;
static string   AC_L2_ROUTE_GENERATION_KEY = "not_scanned";
static string   AC_L2_ROUTE_MEMBERSHIP_CHECKSUM = "not_scanned";
static int      AC_L2_LAST_SERVER_DAY_OF_WEEK = -1;
static int      AC_L2_LAST_SYMBOLS_TOTAL = -1;

static AC_L2SymbolState AC_L2_SYMBOLS[];

static int AC_L2_SYMBOLS_TOTAL = 0;
static int AC_L2_SYMBOLS_SCANNED = 0;
static int AC_L2_OPEN_COUNT = 0;
static int AC_L2_CLOSED_COUNT = 0;
static int AC_L2_UNKNOWN_COUNT = 0;
static int AC_L2_TRADE_SESSION_SUCCESS_COUNT = 0;
static int AC_L2_TRADE_SESSION_FAILURE_COUNT = 0;
static int AC_L2_QUOTE_SESSION_SUCCESS_COUNT = 0;
static int AC_L2_QUOTE_SESSION_FAILURE_COUNT = 0;
static int AC_L2_SYMBOL_INFO_FAILURE_COUNT = 0;
static int AC_L2_ROUTE_WRITE_OPEN_COUNT = 0;
static int AC_L2_ROUTE_WRITE_CLOSED_COUNT = 0;
static int AC_L2_ROUTE_WRITE_UNKNOWN_COUNT = 0;
static int AC_L2_ROUTE_WRITE_FAILURE_COUNT = 0;
static int AC_L2_DUPLICATE_CLEANUP_COUNT = 0;
static int AC_L2_DUPLICATE_CLEANUP_FAILURE_COUNT = 0;
static string AC_L2_WORST_FAILURE_REASON = "none";

static string AC_L2_BOARD_SECTION = "";
static string AC_L2_WORKBENCH_SECTION = "";

void AC_L2Reset()
{
   AC_L2_READY = false;
   AC_L2_SCAN_STARTED_MS = GetTickCount();
   AC_L2_SCAN_DURATION_MS = 0;
   AC_L2_SYMBOLS_PER_SECOND = 0.0;
   AC_L2_SCAN_STATUS = "scanning";
   AC_L2_SCAN_FAILURE = "";
   ArrayResize(AC_L2_SYMBOLS, 0);

   AC_L2_SYMBOLS_TOTAL = 0;
   AC_L2_SYMBOLS_SCANNED = 0;
   AC_L2_OPEN_COUNT = 0;
   AC_L2_CLOSED_COUNT = 0;
   AC_L2_UNKNOWN_COUNT = 0;
   AC_L2_TRADE_SESSION_SUCCESS_COUNT = 0;
   AC_L2_TRADE_SESSION_FAILURE_COUNT = 0;
   AC_L2_QUOTE_SESSION_SUCCESS_COUNT = 0;
   AC_L2_QUOTE_SESSION_FAILURE_COUNT = 0;
   AC_L2_SYMBOL_INFO_FAILURE_COUNT = 0;
   AC_L2_ROUTE_MEMBERSHIP_CHECKSUM = "not_scanned";
   AC_L2_ROUTE_WRITE_OPEN_COUNT = 0;
   AC_L2_ROUTE_WRITE_CLOSED_COUNT = 0;
   AC_L2_ROUTE_WRITE_UNKNOWN_COUNT = 0;
   AC_L2_ROUTE_WRITE_FAILURE_COUNT = 0;
   AC_L2_DUPLICATE_CLEANUP_COUNT = 0;
   AC_L2_DUPLICATE_CLEANUP_FAILURE_COUNT = 0;
   AC_L2_WORST_FAILURE_REASON = "none";

   AC_L2_BOARD_SECTION = "";
   AC_L2_WORKBENCH_SECTION = "";
}

int AC_L2FindIndex(const string symbol)
{
   for(int i = 0; i < ArraySize(AC_L2_SYMBOLS); i++)
      if(AC_L2_SYMBOLS[i].symbol == symbol) return i;
   return -1;
}

string AC_L2MarketStateForSymbol(const string symbol)
{
   int idx = AC_L2FindIndex(symbol);
   if(idx < 0) return "unknown";
   if(AC_L2_SYMBOLS[idx].market_state == "open") return "open";
   if(AC_L2_SYMBOLS[idx].market_state == "closed") return "closed";
   return "unknown";
}

#endif
