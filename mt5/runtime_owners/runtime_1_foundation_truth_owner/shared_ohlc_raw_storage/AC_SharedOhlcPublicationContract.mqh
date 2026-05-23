#ifndef AC_SHARED_OHLC_PUBLICATION_CONTRACT_MQH
#define AC_SHARED_OHLC_PUBLICATION_CONTRACT_MQH

// Runtime 1 Shared OHLC Raw Storage Owner - publication compile contract.
// Purpose: expose one stable OHLC read/render contract to Runtime 7 renderers.
// This file is not a second OHLC owner. It does not call CopyRates, seed bars,
// append bars, rank, select, permit trades, or execute.
// It exists to stop renderer files from depending on split-generation OHLC internals.

static string AC_SHARED_OHLC_STATUS = "contract_loaded_storage_runtime_pending";
static string AC_SHARED_OHLC_MODE = "publication_contract_only_no_copyrates_service";
static bool   AC_SHARED_OHLC_BOOT_SEED_COMPLETE = false;
static bool   AC_SHARED_OHLC_PRIORITY_WINDOW_COMPLETE = false;
static int    AC_SHARED_OHLC_L8_FAST_READY = 0;
static int    AC_SHARED_OHLC_L8_FAST_TOTAL = 0;
static int    AC_SHARED_OHLC_L8_FAST_ATTEMPTED = 0;
static int    AC_SHARED_OHLC_L8_FAST_ERROR = 0;
static int    AC_SHARED_OHLC_SYMBOLS_TOTAL = 0;
static int    AC_SHARED_OHLC_TIMEFRAMES_ENABLED = 6;
static int    AC_SHARED_OHLC_TARGET_SEED_BARS = 1500;
static int    AC_SHARED_OHLC_WINDOW_M5_READY = 0;
static int    AC_SHARED_OHLC_WINDOW_M15_READY = 0;
static int    AC_SHARED_OHLC_WINDOW_H1_READY = 0;
static int    AC_SHARED_OHLC_WINDOW_H4_READY = 0;

string AC_SharedOhlcServerFolder()
{
   return AC_BASE_FOLDER + "\\" + AC_ServerNameForRoute();
}

string AC_SharedOhlcMarketDataFolder()
{
   return AC_SharedOhlcServerFolder() + "\\Shared Market Data";
}

string AC_SharedOhlcRootFolder()
{
   return AC_SharedOhlcMarketDataFolder() + "\\OHLC Store";
}

string AC_SharedOhlcSymbolsFolder()
{
   return AC_SharedOhlcRootFolder() + "\\Symbols";
}

string AC_SharedOhlcSymbolFolder(const string symbol)
{
   return AC_SharedOhlcSymbolsFolder() + "\\" + AC_SanitizePathPart(symbol);
}

string AC_SharedOhlcWindowFolder(const string symbol)
{
   return AC_SharedOhlcSymbolFolder(symbol) + "\\Priority Windows";
}

string AC_SharedOhlcFastWindowPath(const string symbol, const string tf)
{
   return AC_SharedOhlcWindowFolder(symbol) + "\\" + tf + ".window.csv";
}

string AC_SharedOhlcPriorityLabel(const int priority)
{
   if(priority == 1) return "P1_open_positions_or_pending_orders";
   if(priority == 2) return "P2_layer5_pass_symbols";
   if(priority == 3) return "P3_future_candidate_ranked_selected_reserved";
   if(priority == 4) return "P4_other_open_symbols";
   return "P5_closed_blocked_unknown_low_priority";
}

bool AC_SharedOhlcSymbolHasOpenPosition(const string symbol)
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(PositionGetSymbol(i) == symbol)
         return true;
   }
   return false;
}

bool AC_SharedOhlcSymbolHasPendingOrder(const string symbol)
{
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      ulong ticket = OrderGetTicket(i);
      if(ticket != 0 && OrderGetString(ORDER_SYMBOL) == symbol)
         return true;
   }
   return false;
}

bool AC_SharedOhlcSymbolL5Pass(const string symbol)
{
   for(int i = 0; i < ArraySize(AC_L5_SYMBOLS); i++)
   {
      if(AC_L5_SYMBOLS[i].symbol == symbol)
         return AC_L5_SYMBOLS[i].pass;
   }
   return false;
}

int AC_SharedOhlcPriorityForSymbol(const string symbol)
{
   if(symbol == "") return 5;
   if(AC_SharedOhlcSymbolHasOpenPosition(symbol) || AC_SharedOhlcSymbolHasPendingOrder(symbol)) return 1;
   if(AC_SharedOhlcSymbolL5Pass(symbol)) return 2;
   // P3 is reserved for future candidate/ranked/selected ownership. This contract does not infer it.
   if(AC_L2MarketStateForSymbol(symbol) == "open") return 4;
   return 5;
}

void AC_SharedOhlcRefreshPublicationCounters()
{
   AC_SHARED_OHLC_SYMBOLS_TOTAL = SymbolsTotal(false);
   AC_SHARED_OHLC_L8_FAST_TOTAL = AC_L5_GATE_PASS;
   AC_SHARED_OHLC_L8_FAST_READY = 0;
   AC_SHARED_OHLC_L8_FAST_ATTEMPTED = 0;
   AC_SHARED_OHLC_L8_FAST_ERROR = 0;
   AC_SHARED_OHLC_WINDOW_M5_READY = 0;
   AC_SHARED_OHLC_WINDOW_M15_READY = 0;
   AC_SHARED_OHLC_WINDOW_H1_READY = 0;
   AC_SHARED_OHLC_WINDOW_H4_READY = 0;

   for(int i = 0; i < ArraySize(AC_L5_SYMBOLS); i++)
   {
      if(!AC_L5_SYMBOLS[i].pass)
         continue;
      string symbol = AC_L5_SYMBOLS[i].symbol;
      bool m5 = FileIsExist(AC_SharedOhlcFastWindowPath(symbol, "M5"), AC_CommonFlag());
      bool m15 = FileIsExist(AC_SharedOhlcFastWindowPath(symbol, "M15"), AC_CommonFlag());
      bool h1 = FileIsExist(AC_SharedOhlcFastWindowPath(symbol, "H1"), AC_CommonFlag());
      bool h4 = FileIsExist(AC_SharedOhlcFastWindowPath(symbol, "H4"), AC_CommonFlag());
      if(m5) AC_SHARED_OHLC_WINDOW_M5_READY++;
      if(m15) AC_SHARED_OHLC_WINDOW_M15_READY++;
      if(h1) AC_SHARED_OHLC_WINDOW_H1_READY++;
      if(h4) AC_SHARED_OHLC_WINDOW_H4_READY++;
      if(m5 || m15 || h1 || h4) AC_SHARED_OHLC_L8_FAST_ATTEMPTED++;
      if(m5 && m15 && h1) AC_SHARED_OHLC_L8_FAST_READY++;
   }
}

string AC_SharedOhlcRenderBoardSection()
{
   AC_SharedOhlcRefreshPublicationCounters();
   string text = "\r\nSHARED OHLC RAW STORE\r\n";
   text += "----------------------------------------\r\n";
   text += "Status:                 " + AC_SHARED_OHLC_STATUS + "\r\n";
   text += "Mode:                   " + AC_SHARED_OHLC_MODE + "\r\n";
   text += "Scope:                  broker_universe_symbols_total_false\r\n";
   text += "Symbols Tracked:        " + IntegerToString(AC_SHARED_OHLC_SYMBOLS_TOTAL) + "\r\n";
   text += "L8 Fast Ready:          " + IntegerToString(AC_SHARED_OHLC_L8_FAST_READY) + " / " + IntegerToString(AC_SHARED_OHLC_L8_FAST_TOTAL) + "\r\n";
   text += "M5/M15/H1/H4 Ready:     " + IntegerToString(AC_SHARED_OHLC_WINDOW_M5_READY) + " / " + IntegerToString(AC_SHARED_OHLC_WINDOW_M15_READY) + " / " + IntegerToString(AC_SHARED_OHLC_WINDOW_H1_READY) + " / " + IntegerToString(AC_SHARED_OHLC_WINDOW_H4_READY) + "\r\n";
   text += "Raw Bars Printed:       FALSE\r\n";
   text += "Trade Permission:       FALSE\r\n";
   return text;
}

string AC_SharedOhlcRenderDossierSection(const string symbol)
{
   AC_SharedOhlcRefreshPublicationCounters();
   bool m5 = FileIsExist(AC_SharedOhlcFastWindowPath(symbol, "M5"), AC_CommonFlag());
   bool m15 = FileIsExist(AC_SharedOhlcFastWindowPath(symbol, "M15"), AC_CommonFlag());
   bool h1 = FileIsExist(AC_SharedOhlcFastWindowPath(symbol, "H1"), AC_CommonFlag());
   bool h4 = FileIsExist(AC_SharedOhlcFastWindowPath(symbol, "H4"), AC_CommonFlag());
   int priority = AC_SharedOhlcPriorityForSymbol(symbol);

   string text = "\r\nSHARED OHLC RAW STORE OVERVIEW\r\n";
   text += "----------------------------------------\r\n";
   text += "Owner:                  Runtime 1 Shared OHLC Raw Storage Owner\r\n";
   text += "Symbol:                 " + symbol + "\r\n";
   text += "Status:                 " + AC_SHARED_OHLC_STATUS + "\r\n";
   text += "Mode:                   " + AC_SHARED_OHLC_MODE + "\r\n";
   text += "Symbol Priority:        " + AC_SharedOhlcPriorityLabel(priority) + "\r\n";
   text += "M5 Window:              " + (m5 ? "available" : "pending") + "\r\n";
   text += "M15 Window:             " + (m15 ? "available" : "pending") + "\r\n";
   text += "H1 Window:              " + (h1 ? "available" : "pending") + "\r\n";
   text += "H4 Context Window:      " + (h4 ? "available" : "pending") + "\r\n";
   text += "L8 Minimum Ready:       " + ((m5 && m15 && h1) ? "TRUE" : "FALSE") + "\r\n";
   text += "Raw Store Route:        " + AC_SharedOhlcSymbolFolder(symbol) + "\r\n";
   text += "Raw Bars Shown Here:    FALSE\r\n";
   text += "Trade Permission:       FALSE\r\n";
   return text;
}

string AC_SharedOhlcRenderWorkbenchSection()
{
   AC_SharedOhlcRefreshPublicationCounters();
   string text = "\r\nSHARED_OHLC_RAW_STORE\r\n";
   text += "----------------------------------------\r\n";
   text += "shared_ohlc_status=" + AC_SHARED_OHLC_STATUS + "\r\n";
   text += "shared_ohlc_mode=" + AC_SHARED_OHLC_MODE + "\r\n";
   text += "shared_ohlc_scope=broker_universe_symbols_total_false\r\n";
   text += "shared_ohlc_symbols_total=" + IntegerToString(AC_SHARED_OHLC_SYMBOLS_TOTAL) + "\r\n";
   text += "shared_ohlc_boot_seed_complete=" + (AC_SHARED_OHLC_BOOT_SEED_COMPLETE ? "true" : "false") + "\r\n";
   text += "shared_ohlc_l8_fast_ready=" + IntegerToString(AC_SHARED_OHLC_L8_FAST_READY) + "\r\n";
   text += "shared_ohlc_l8_fast_total=" + IntegerToString(AC_SHARED_OHLC_L8_FAST_TOTAL) + "\r\n";
   text += "shared_ohlc_l8_fast_attempted=" + IntegerToString(AC_SHARED_OHLC_L8_FAST_ATTEMPTED) + "\r\n";
   text += "shared_ohlc_l8_fast_error=" + IntegerToString(AC_SHARED_OHLC_L8_FAST_ERROR) + "\r\n";
   text += "shared_ohlc_window_m5_ready=" + IntegerToString(AC_SHARED_OHLC_WINDOW_M5_READY) + "\r\n";
   text += "shared_ohlc_window_m15_ready=" + IntegerToString(AC_SHARED_OHLC_WINDOW_M15_READY) + "\r\n";
   text += "shared_ohlc_window_h1_ready=" + IntegerToString(AC_SHARED_OHLC_WINDOW_H1_READY) + "\r\n";
   text += "shared_ohlc_window_h4_ready=" + IntegerToString(AC_SHARED_OHLC_WINDOW_H4_READY) + "\r\n";
   text += "shared_ohlc_copyrates_active=false\r\n";
   text += "shared_ohlc_raw_bars_printed_to_board=false\r\n";
   text += "shared_ohlc_raw_bars_printed_to_dossier=false\r\n";
   text += "shared_ohlc_trade_permission=false\r\n";
   return text;
}

#endif
