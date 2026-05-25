#ifndef AC_L4_STATE_MQH
#define AC_L4_STATE_MQH

static bool AC_L4_READY = false;
static uint AC_L4_SCAN_STARTED_MS = 0;
static uint AC_L4_SCAN_DURATION_MS = 0;
static string AC_L4_SCAN_STATUS = "Not started";
static string AC_L4_CACHE_KEY = "not_scanned";
static string AC_L4_REFRESH_KEY = "not_refreshed";
static datetime AC_L4_LAST_REFRESH_TIME = 0;

static AC_L4SymbolPacket AC_L4_SYMBOLS[];

static int AC_L4_ELIGIBLE_OPEN = 0;
static int AC_L4_SCANNED = 0;
static int AC_L4_FRESH_QUOTES = 0;
static int AC_L4_AGING_QUOTES = 0;
static int AC_L4_STALE_QUOTES = 0;
static int AC_L4_MISSING_TICK = 0;
static int AC_L4_INVALID_BIDASK = 0;
static int AC_L4_ZERO_SPREAD_FRESH = 0;
static int AC_L4_DAILY_CHANGE_AVAILABLE = 0;
static int AC_L4_HIGH_SPREAD_WARNINGS = 0;
static int AC_L4_SYMBOLINFO_TICK_SUCCESS = 0;
static int AC_L4_SYMBOLINFO_TICK_FAILURE = 0;
static int AC_L4_ACTIVITY_API_AVAILABLE = 0;
static int AC_L4_ACTIVITY_NONZERO = 0;
static int AC_L4_FIND_LAST_INDEX = -1;
static int AC_L4_FIND_CACHE_HITS = 0;
static int AC_L4_FIND_FULL_SCAN_COUNT = 0;

static string AC_L4_BOARD_SECTION = "";
static string AC_L4_WORKBENCH_SECTION = "";
static string AC_L4_WORST_FAILURE_REASON = "None";

void AC_L4Reset()
{
   AC_L4_READY = false;
   AC_L4_SCAN_STARTED_MS = GetTickCount();
   AC_L4_SCAN_DURATION_MS = 0;
   AC_L4_SCAN_STATUS = "Scanning";
   // Use the same TimeTradeServer-first clock as L2 session truth. TimeCurrent()
   // is last-quote time in OnTimer and can freeze on stale Market Watch quotes.
   AC_L4_LAST_REFRESH_TIME = AC_L2CurrentSessionServerTime();
   ArrayResize(AC_L4_SYMBOLS, 0);

   AC_L4_ELIGIBLE_OPEN = 0;
   AC_L4_SCANNED = 0;
   AC_L4_FRESH_QUOTES = 0;
   AC_L4_AGING_QUOTES = 0;
   AC_L4_STALE_QUOTES = 0;
   AC_L4_MISSING_TICK = 0;
   AC_L4_INVALID_BIDASK = 0;
   AC_L4_ZERO_SPREAD_FRESH = 0;
   AC_L4_DAILY_CHANGE_AVAILABLE = 0;
   AC_L4_HIGH_SPREAD_WARNINGS = 0;
   AC_L4_SYMBOLINFO_TICK_SUCCESS = 0;
   AC_L4_SYMBOLINFO_TICK_FAILURE = 0;
   AC_L4_ACTIVITY_API_AVAILABLE = 0;
   AC_L4_ACTIVITY_NONZERO = 0;
   AC_L4_FIND_LAST_INDEX = -1;
   AC_L4_FIND_CACHE_HITS = 0;
   AC_L4_FIND_FULL_SCAN_COUNT = 0;

   AC_L4_BOARD_SECTION = "";
   AC_L4_WORKBENCH_SECTION = "";
   AC_L4_WORST_FAILURE_REASON = "None";
}

int AC_L4FindIndex(const string symbol)
{
   int total = ArraySize(AC_L4_SYMBOLS);
   if(total <= 0) return -1;

   if(AC_L4_FIND_LAST_INDEX >= 0 && AC_L4_FIND_LAST_INDEX < total && AC_L4_SYMBOLS[AC_L4_FIND_LAST_INDEX].symbol == symbol)
   {
      AC_L4_FIND_CACHE_HITS++;
      return AC_L4_FIND_LAST_INDEX;
   }

   int next_index = AC_L4_FIND_LAST_INDEX + 1;
   if(next_index >= 0 && next_index < total && AC_L4_SYMBOLS[next_index].symbol == symbol)
   {
      AC_L4_FIND_LAST_INDEX = next_index;
      AC_L4_FIND_CACHE_HITS++;
      return next_index;
   }

   int previous_index = AC_L4_FIND_LAST_INDEX - 1;
   if(previous_index >= 0 && previous_index < total && AC_L4_SYMBOLS[previous_index].symbol == symbol)
   {
      AC_L4_FIND_LAST_INDEX = previous_index;
      AC_L4_FIND_CACHE_HITS++;
      return previous_index;
   }

   AC_L4_FIND_FULL_SCAN_COUNT++;
   for(int i=0; i<total; i++)
   {
      if(AC_L4_SYMBOLS[i].symbol == symbol)
      {
         AC_L4_FIND_LAST_INDEX = i;
         return i;
      }
   }
   return -1;
}

#endif
