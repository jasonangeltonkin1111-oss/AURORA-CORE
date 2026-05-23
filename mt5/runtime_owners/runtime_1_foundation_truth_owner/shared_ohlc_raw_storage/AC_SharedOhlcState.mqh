#ifndef AC_SHARED_OHLC_STATE_MQH
#define AC_SHARED_OHLC_STATE_MQH

// Runtime 1 support service - Shared OHLC Raw Storage Owner state.
// State tracks raw storage progress only. It does not calculate market features.

static bool   AC_SHARED_OHLC_READY = false;
static bool   AC_SHARED_OHLC_BOOT_SEED_COMPLETE = false;
static bool   AC_SHARED_OHLC_APPEND_MODE_ACTIVE = false;
static string AC_SHARED_OHLC_STATUS = "not_started";
static string AC_SHARED_OHLC_MODE = "boot_seed_pending";
static string AC_SHARED_OHLC_LAST_ERROR = "";
static uint   AC_SHARED_OHLC_LAST_SERVICE_DURATION_MS = 0;
static int    AC_SHARED_OHLC_SYMBOLS_TOTAL = 0;
static int    AC_SHARED_OHLC_TIMEFRAMES_ENABLED = 0;
static int    AC_SHARED_OHLC_SYMBOL_TF_TOTAL = 0;
static int    AC_SHARED_OHLC_SYMBOL_TF_SEEDED = 0;
static int    AC_SHARED_OHLC_SYMBOL_TF_PARTIAL = 0;
static int    AC_SHARED_OHLC_SYMBOL_TF_PENDING = 0;
static int    AC_SHARED_OHLC_SYMBOL_TF_ERROR = 0;
static int    AC_SHARED_OHLC_APPEND_BACKLOG_P1 = 0;
static int    AC_SHARED_OHLC_APPEND_BACKLOG_P2 = 0;
static int    AC_SHARED_OHLC_APPEND_BACKLOG_P3 = 0;
static int    AC_SHARED_OHLC_APPEND_BACKLOG_P4 = 0;
static int    AC_SHARED_OHLC_APPEND_BACKLOG_P5 = 0;
static datetime AC_SHARED_OHLC_LAST_BAR_TIME_SEEN = 0;
static string AC_SHARED_OHLC_LAST_SYMBOL = "";
static string AC_SHARED_OHLC_LAST_TIMEFRAME = "";

static AC_SharedOhlcTimeframeContract AC_SHARED_OHLC_FRAMES[];

void AC_SharedOhlcResetCounters()
{
   // Shared OHLC is a broker-universe source owner. It must not silently scope
   // itself to Market Watch only, otherwise future layers may read a partial
   // raw store while the surface appears healthy.
   AC_SHARED_OHLC_SYMBOLS_TOTAL = SymbolsTotal(false);
   AC_SharedOhlcDefaultTimeframes(AC_SHARED_OHLC_FRAMES);
   AC_SHARED_OHLC_TIMEFRAMES_ENABLED = 0;
   for(int i = 0; i < ArraySize(AC_SHARED_OHLC_FRAMES); i++)
   {
      if(AC_SHARED_OHLC_FRAMES[i].enabled)
         AC_SHARED_OHLC_TIMEFRAMES_ENABLED++;
   }

   AC_SHARED_OHLC_SYMBOL_TF_TOTAL = AC_SHARED_OHLC_SYMBOLS_TOTAL * AC_SHARED_OHLC_TIMEFRAMES_ENABLED;
   AC_SHARED_OHLC_SYMBOL_TF_SEEDED = 0;
   AC_SHARED_OHLC_SYMBOL_TF_PARTIAL = 0;
   AC_SHARED_OHLC_SYMBOL_TF_PENDING = AC_SHARED_OHLC_SYMBOL_TF_TOTAL;
   AC_SHARED_OHLC_SYMBOL_TF_ERROR = 0;
   AC_SHARED_OHLC_APPEND_BACKLOG_P1 = 0;
   AC_SHARED_OHLC_APPEND_BACKLOG_P2 = 0;
   AC_SHARED_OHLC_APPEND_BACKLOG_P3 = 0;
   AC_SHARED_OHLC_APPEND_BACKLOG_P4 = 0;
   AC_SHARED_OHLC_APPEND_BACKLOG_P5 = 0;
}

string AC_SharedOhlcStatusRow()
{
   string row = "shared_ohlc_schema=" + AC_SHARED_OHLC_SCHEMA_VERSION + "\r\n";
   row += "shared_ohlc_owner=" + AC_SHARED_OHLC_OWNER_NAME + "\r\n";
   row += "shared_ohlc_authority=" + AC_SHARED_OHLC_AUTHORITY + "\r\n";
   row += "shared_ohlc_scope=broker_universe_symbols_total_false\r\n";
   row += "shared_ohlc_status=" + AC_SHARED_OHLC_STATUS + "\r\n";
   row += "shared_ohlc_mode=" + AC_SHARED_OHLC_MODE + "\r\n";
   row += "shared_ohlc_boot_seed_complete=" + (AC_SHARED_OHLC_BOOT_SEED_COMPLETE ? "true" : "false") + "\r\n";
   row += "shared_ohlc_append_mode_active=" + (AC_SHARED_OHLC_APPEND_MODE_ACTIVE ? "true" : "false") + "\r\n";
   row += "shared_ohlc_symbols_total=" + IntegerToString(AC_SHARED_OHLC_SYMBOLS_TOTAL) + "\r\n";
   row += "shared_ohlc_timeframes_enabled=" + IntegerToString(AC_SHARED_OHLC_TIMEFRAMES_ENABLED) + "\r\n";
   row += "shared_ohlc_symbol_tf_total=" + IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_TOTAL) + "\r\n";
   row += "shared_ohlc_symbol_tf_seeded=" + IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_SEEDED) + "\r\n";
   row += "shared_ohlc_symbol_tf_partial=" + IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_PARTIAL) + "\r\n";
   row += "shared_ohlc_symbol_tf_pending=" + IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_PENDING) + "\r\n";
   row += "shared_ohlc_symbol_tf_error=" + IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_ERROR) + "\r\n";
   row += "shared_ohlc_append_backlog_p1=" + IntegerToString(AC_SHARED_OHLC_APPEND_BACKLOG_P1) + "\r\n";
   row += "shared_ohlc_append_backlog_p2=" + IntegerToString(AC_SHARED_OHLC_APPEND_BACKLOG_P2) + "\r\n";
   row += "shared_ohlc_append_backlog_p3=" + IntegerToString(AC_SHARED_OHLC_APPEND_BACKLOG_P3) + "\r\n";
   row += "shared_ohlc_append_backlog_p4=" + IntegerToString(AC_SHARED_OHLC_APPEND_BACKLOG_P4) + "\r\n";
   row += "shared_ohlc_append_backlog_p5=" + IntegerToString(AC_SHARED_OHLC_APPEND_BACKLOG_P5) + "\r\n";
   row += "shared_ohlc_last_service_duration_ms=" + IntegerToString((int)AC_SHARED_OHLC_LAST_SERVICE_DURATION_MS) + "\r\n";
   row += "shared_ohlc_last_symbol=" + AC_SHARED_OHLC_LAST_SYMBOL + "\r\n";
   row += "shared_ohlc_last_timeframe=" + AC_SHARED_OHLC_LAST_TIMEFRAME + "\r\n";
   row += "shared_ohlc_last_error=" + AC_SHARED_OHLC_LAST_ERROR + "\r\n";
   row += "shared_ohlc_layer_access_policy=" + AC_SHARED_OHLC_LAYER_ACCESS_POLICY + "\r\n";
   row += "shared_ohlc_calculation_policy=" + AC_SHARED_OHLC_CALCULATION_POLICY + "\r\n";
   return row;
}

#endif
