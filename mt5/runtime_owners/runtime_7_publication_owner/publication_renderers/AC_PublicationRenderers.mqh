#ifndef AC_PUBLICATION_RENDERERS_MQH
#define AC_PUBLICATION_RENDERERS_MQH

// Board / Dossier Renderer Service.
// Compile-safe Shared OHLC surface scaffold.
// This renderer-level scaffold prevents compile failure when the full new OHLC owner files
// have not yet been installed into the local MT5 Include tree.
// It does not fetch bars, calculate, rank, select, permit, or execute.
// Full raw CopyRates/MqlRates ownership remains planned for Runtime 1 Shared OHLC Raw Storage Owner.

static string AC_SHARED_OHLC_STATUS = "ready_storage_contract_loaded_seed_not_started";
static string AC_SHARED_OHLC_MODE = "boot_seed_pending";
static bool   AC_SHARED_OHLC_BOOT_SEED_COMPLETE = false;
static int    AC_SHARED_OHLC_SYMBOLS_TOTAL = 0;
static int    AC_SHARED_OHLC_TIMEFRAMES_ENABLED = 6;
static int    AC_SHARED_OHLC_TARGET_SEED_BARS = 1500;
static int    AC_SHARED_OHLC_SYMBOL_TF_TOTAL = 0;
static int    AC_SHARED_OHLC_SYMBOL_TF_SEEDED = 0;
static int    AC_SHARED_OHLC_SYMBOL_TF_PARTIAL = 0;
static int    AC_SHARED_OHLC_SYMBOL_TF_PENDING = 0;
static int    AC_SHARED_OHLC_APPEND_BACKLOG_P1 = 0;
static int    AC_SHARED_OHLC_APPEND_BACKLOG_P2 = 0;
static int    AC_SHARED_OHLC_APPEND_BACKLOG_P3 = 0;
static int    AC_SHARED_OHLC_APPEND_BACKLOG_P4 = 0;
static int    AC_SHARED_OHLC_APPEND_BACKLOG_P5 = 0;

string AC_SharedOhlcRenderBoardSection()
{
   string text = "\r\nSHARED OHLC RAW STORE\r\n";
   text += "----------------------------------------\r\n";
   text += "Status:                 " + AC_SHARED_OHLC_STATUS + "\r\n";
   text += "Mode:                   " + AC_SHARED_OHLC_MODE + "\r\n";
   text += "Server Scope:           " + AC_ServerNameForRoute() + "\r\n";
   text += "Symbols Tracked:        " + IntegerToString(AC_SHARED_OHLC_SYMBOLS_TOTAL) + "\r\n";
   text += "Timeframes Enabled:     " + IntegerToString(AC_SHARED_OHLC_TIMEFRAMES_ENABLED) + "\r\n";
   text += "Target Bars / TF:       " + IntegerToString(AC_SHARED_OHLC_TARGET_SEED_BARS) + "\r\n";
   text += "Seeded Symbol-TFs:      " + IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_SEEDED) + " / " + IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_TOTAL) + "\r\n";
   text += "Partial Symbol-TFs:     " + IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_PARTIAL) + "\r\n";
   text += "Pending Symbol-TFs:     " + IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_PENDING) + "\r\n";
   text += "Append Backlog:         P1=" + IntegerToString(AC_SHARED_OHLC_APPEND_BACKLOG_P1)
      + " P2=" + IntegerToString(AC_SHARED_OHLC_APPEND_BACKLOG_P2)
      + " P3=" + IntegerToString(AC_SHARED_OHLC_APPEND_BACKLOG_P3)
      + " P4=" + IntegerToString(AC_SHARED_OHLC_APPEND_BACKLOG_P4)
      + " P5=" + IntegerToString(AC_SHARED_OHLC_APPEND_BACKLOG_P5) + "\r\n";
   text += "Raw Bars Printed:       FALSE\r\n";
   text += "Trade Permission:       FALSE\r\n";
   return text;
}

string AC_SharedOhlcRenderDossierSection(const string symbol)
{
   string text = "\r\nSHARED OHLC RAW STORE OVERVIEW\r\n";
   text += "----------------------------------------\r\n";
   text += "Owner:                  Runtime 1 Shared OHLC Raw Storage Owner\r\n";
   text += "Symbol:                 " + symbol + "\r\n";
   text += "Server Scope:           " + AC_ServerNameForRoute() + "\r\n";
   text += "Store Status:           " + AC_SHARED_OHLC_STATUS + "\r\n";
   text += "Store Mode:             " + AC_SHARED_OHLC_MODE + "\r\n";
   text += "Target Bars / TF:       " + IntegerToString(AC_SHARED_OHLC_TARGET_SEED_BARS) + "\r\n";
   text += "Timeframes Enabled:     " + IntegerToString(AC_SHARED_OHLC_TIMEFRAMES_ENABLED) + "\r\n";
   text += "Raw Bars Shown Here:    FALSE\r\n";
   text += "Layer Access Policy:    future_layers_read_shared_raw_store_no_private_copyrates\r\n";
   text += "Calculation Policy:     no_calculations_in_mt5_raw_storage_owner\r\n";
   return text;
}

string AC_SharedOhlcRenderWorkbenchSection()
{
   string text = "SHARED_OHLC_RAW_STORAGE_OWNER\r\n";
   text += "----------------------------------------\r\n";
   text += "shared_ohlc_status=" + AC_SHARED_OHLC_STATUS + "\r\n";
   text += "shared_ohlc_mode=" + AC_SHARED_OHLC_MODE + "\r\n";
   text += "shared_ohlc_boot_seed_complete=" + (AC_SHARED_OHLC_BOOT_SEED_COMPLETE ? "true" : "false") + "\r\n";
   text += "shared_ohlc_target_seed_bars=" + IntegerToString(AC_SHARED_OHLC_TARGET_SEED_BARS) + "\r\n";
   text += "shared_ohlc_timeframes_enabled=" + IntegerToString(AC_SHARED_OHLC_TIMEFRAMES_ENABLED) + "\r\n";
   text += "shared_ohlc_symbols_total=" + IntegerToString(AC_SHARED_OHLC_SYMBOLS_TOTAL) + "\r\n";
   text += "shared_ohlc_symbol_tf_total=" + IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_TOTAL) + "\r\n";
   text += "shared_ohlc_symbol_tf_seeded=" + IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_SEEDED) + "\r\n";
   text += "shared_ohlc_raw_bars_printed_to_board=false\r\n";
   text += "shared_ohlc_raw_bars_printed_to_dossier=false\r\n";
   text += "shared_ohlc_copyrates_owner=shared_ohlc_raw_storage_owner_only\r\n";
   text += "shared_ohlc_future_layers_private_copyrates_allowed=false\r\n";
   text += "shared_ohlc_compile_surface=scaffold_no_full_seed_scheduler_enabled\r\n";
   return text;
}

#include "AC_Layer7SessionRelevanceRenderer.mqh"
#include "AC_Layer6RankedSidecarRenderer.mqh"
#include "AC_Layer0DossierPublication.mqh"
#include "AC_MarketBoardRenderer.mqh"

#endif