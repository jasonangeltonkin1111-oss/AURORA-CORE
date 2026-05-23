#ifndef AC_PUBLICATION_RENDERERS_MQH
#define AC_PUBLICATION_RENDERERS_MQH

// Board / Dossier Renderer Service.
// Shared OHLC visual bootstrap surface.
// This is compile-safe and creates visible server-level route/status proof before full seed scheduling.
// It does not call CopyRates, calculate, rank, select, permit, or execute.

static string AC_SHARED_OHLC_STATUS = "ready_storage_contract_loaded_seed_not_started";
static string AC_SHARED_OHLC_MODE = "boot_seed_pending";
static bool   AC_SHARED_OHLC_BOOT_SEED_COMPLETE = false;
static int    AC_SHARED_OHLC_TIMEFRAMES_ENABLED = 6;
static int    AC_SHARED_OHLC_TARGET_SEED_BARS = 1500;
static int    AC_SHARED_OHLC_SYMBOLS_TOTAL = 0;
static int    AC_SHARED_OHLC_SYMBOL_TF_TOTAL = 0;
static int    AC_SHARED_OHLC_SYMBOL_TF_SEEDED = 0;
static int    AC_SHARED_OHLC_SYMBOL_TF_PARTIAL = 0;
static int    AC_SHARED_OHLC_SYMBOL_TF_PENDING = 0;
static int    AC_SHARED_OHLC_APPEND_BACKLOG_P1 = 0;
static int    AC_SHARED_OHLC_APPEND_BACKLOG_P2 = 0;
static int    AC_SHARED_OHLC_APPEND_BACKLOG_P3 = 0;
static int    AC_SHARED_OHLC_APPEND_BACKLOG_P4 = 0;
static int    AC_SHARED_OHLC_APPEND_BACKLOG_P5 = 0;
static string AC_SHARED_OHLC_ROUTE_STATUS = "not_attempted";
static string AC_SHARED_OHLC_STATUS_WRITE = "not_attempted";
static string AC_SHARED_OHLC_MANIFEST_WRITE = "not_attempted";

string AC_SharedOhlcServerFolder(){ return AC_BASE_FOLDER + "\\" + AC_ServerNameForRoute(); }
string AC_SharedOhlcMarketDataFolder(){ return AC_SharedOhlcServerFolder() + "\\Shared Market Data"; }
string AC_SharedOhlcRootFolder(){ return AC_SharedOhlcMarketDataFolder() + "\\OHLC Store"; }
string AC_SharedOhlcStatusFolder(){ return AC_SharedOhlcRootFolder() + "\\Status"; }
string AC_SharedOhlcSymbolsFolder(){ return AC_SharedOhlcRootFolder() + "\\Symbols"; }
string AC_SharedOhlcStatusPath(){ return AC_SharedOhlcStatusFolder() + "\\status.txt"; }
string AC_SharedOhlcManifestPath(){ return AC_SharedOhlcStatusFolder() + "\\manifest.txt"; }

void AC_SharedOhlcVisualBootstrap()
{
   AC_SHARED_OHLC_SYMBOLS_TOTAL = SymbolsTotal(false);
   AC_SHARED_OHLC_SYMBOL_TF_TOTAL = AC_SHARED_OHLC_SYMBOLS_TOTAL * AC_SHARED_OHLC_TIMEFRAMES_ENABLED;
   AC_SHARED_OHLC_SYMBOL_TF_PENDING = AC_SHARED_OHLC_SYMBOL_TF_TOTAL - AC_SHARED_OHLC_SYMBOL_TF_SEEDED;
   if(AC_SHARED_OHLC_SYMBOL_TF_PENDING < 0) AC_SHARED_OHLC_SYMBOL_TF_PENDING = 0;

   string d0="", d1="", d2="", d3="", d4="";
   bool ok = AC_EnsureFolderPath(AC_SharedOhlcServerFolder(), d0);
   ok = AC_EnsureFolderPath(AC_SharedOhlcMarketDataFolder(), d1) && ok;
   ok = AC_EnsureFolderPath(AC_SharedOhlcRootFolder(), d2) && ok;
   ok = AC_EnsureFolderPath(AC_SharedOhlcStatusFolder(), d3) && ok;
   ok = AC_EnsureFolderPath(AC_SharedOhlcSymbolsFolder(), d4) && ok;
   AC_SHARED_OHLC_ROUTE_STATUS = ok ? "folder_create_ok" : "folder_create_degraded";

   string status = "schema_name=shared_ohlc_raw_store_status\r\n";
   status += "schema_version=surface_bootstrap_v1\r\n";
   status += "owner=Runtime 1 Shared OHLC Raw Storage Owner\r\n";
   status += "status=" + AC_SHARED_OHLC_STATUS + "\r\n";
   status += "mode=" + AC_SHARED_OHLC_MODE + "\r\n";
   status += "scope=broker_universe_symbols_total_false\r\n";
   status += "route_root=" + AC_SharedOhlcRootFolder() + "\r\n";
   status += "symbols_total=" + IntegerToString(AC_SHARED_OHLC_SYMBOLS_TOTAL) + "\r\n";
   status += "timeframes_enabled=" + IntegerToString(AC_SHARED_OHLC_TIMEFRAMES_ENABLED) + "\r\n";
   status += "target_seed_bars=" + IntegerToString(AC_SHARED_OHLC_TARGET_SEED_BARS) + "\r\n";
   status += "symbol_tf_total=" + IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_TOTAL) + "\r\n";
   status += "symbol_tf_seeded=" + IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_SEEDED) + "\r\n";
   status += "symbol_tf_pending=" + IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_PENDING) + "\r\n";
   status += "full_seed_scheduler_active=false\r\n";
   status += "raw_bars_written=false\r\n";
   status += "trade_permission=false\r\n";
   status += "selection_runtime=false\r\n";
   status += "calculation_runtime=false\r\n";
   AC_WriteResult sw = AC_WriteTextFileFastAtomic(AC_SharedOhlcStatusPath(), status);
   AC_SHARED_OHLC_STATUS_WRITE = sw.status;

   string manifest = "schema_name=shared_ohlc_raw_store_manifest\r\n";
   manifest += "schema_version=surface_bootstrap_v1\r\n";
   manifest += "owner=Runtime 1 Shared OHLC Raw Storage Owner\r\n";
   manifest += "route_root=" + AC_SharedOhlcRootFolder() + "\r\n";
   manifest += "status_path=" + AC_SharedOhlcStatusPath() + "\r\n";
   manifest += "manifest_path=" + AC_SharedOhlcManifestPath() + "\r\n";
   manifest += "symbols_folder=" + AC_SharedOhlcSymbolsFolder() + "\r\n";
   manifest += "scope=broker_universe_symbols_total_false\r\n";
   manifest += "copyrates_fetch_active=false\r\n";
   manifest += "full_seed_scheduler_active=false\r\n";
   manifest += "raw_bars_printed_to_board=false\r\n";
   manifest += "raw_bars_printed_to_dossier=false\r\n";
   manifest += "route_status=" + AC_SHARED_OHLC_ROUTE_STATUS + "\r\n";
   manifest += "status_write=" + AC_SHARED_OHLC_STATUS_WRITE + "\r\n";
   AC_WriteResult mw = AC_WriteTextFileFastAtomic(AC_SharedOhlcManifestPath(), manifest);
   AC_SHARED_OHLC_MANIFEST_WRITE = mw.status;
}

string AC_SharedOhlcRenderBoardSection()
{
   AC_SharedOhlcVisualBootstrap();
   string text = "\r\nSHARED OHLC RAW STORE\r\n";
   text += "----------------------------------------\r\n";
   text += "Status:                 " + AC_SHARED_OHLC_STATUS + "\r\n";
   text += "Mode:                   " + AC_SHARED_OHLC_MODE + "\r\n";
   text += "Route Root:             " + AC_SharedOhlcRootFolder() + "\r\n";
   text += "Route Status:           " + AC_SHARED_OHLC_ROUTE_STATUS + "\r\n";
   text += "Status File Write:      " + AC_SHARED_OHLC_STATUS_WRITE + "\r\n";
   text += "Manifest File Write:    " + AC_SHARED_OHLC_MANIFEST_WRITE + "\r\n";
   text += "Symbols Tracked:        " + IntegerToString(AC_SHARED_OHLC_SYMBOLS_TOTAL) + "\r\n";
   text += "Timeframes Enabled:     " + IntegerToString(AC_SHARED_OHLC_TIMEFRAMES_ENABLED) + "\r\n";
   text += "Target Bars / TF:       " + IntegerToString(AC_SHARED_OHLC_TARGET_SEED_BARS) + "\r\n";
   text += "Seeded Symbol-TFs:      " + IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_SEEDED) + " / " + IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_TOTAL) + "\r\n";
   text += "Pending Symbol-TFs:     " + IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_PENDING) + "\r\n";
   text += "Full Seed Active:       FALSE\r\n";
   text += "Raw Bars Printed:       FALSE\r\n";
   text += "Trade Permission:       FALSE\r\n";
   return text;
}

string AC_SharedOhlcRenderDossierSection(const string symbol)
{
   AC_SharedOhlcVisualBootstrap();
   string text = "\r\nSHARED OHLC RAW STORE OVERVIEW\r\n";
   text += "----------------------------------------\r\n";
   text += "Owner:                  Runtime 1 Shared OHLC Raw Storage Owner\r\n";
   text += "Symbol:                 " + symbol + "\r\n";
   text += "Store Status:           " + AC_SHARED_OHLC_STATUS + "\r\n";
   text += "Store Mode:             " + AC_SHARED_OHLC_MODE + "\r\n";
   text += "Raw Store Route:        " + AC_SharedOhlcRootFolder() + "\r\n";
   text += "Raw Bars Shown Here:    FALSE\r\n";
   text += "Calculation Policy:     no_calculations_in_mt5_raw_storage_owner\r\n";
   return text;
}

string AC_SharedOhlcRenderWorkbenchSection()
{
   AC_SharedOhlcVisualBootstrap();
   string text = "SHARED_OHLC_RAW_STORAGE_OWNER\r\n";
   text += "----------------------------------------\r\n";
   text += "shared_ohlc_status=" + AC_SHARED_OHLC_STATUS + "\r\n";
   text += "shared_ohlc_mode=" + AC_SHARED_OHLC_MODE + "\r\n";
   text += "shared_ohlc_route_root=" + AC_SharedOhlcRootFolder() + "\r\n";
   text += "shared_ohlc_status_path=" + AC_SharedOhlcStatusPath() + "\r\n";
   text += "shared_ohlc_manifest_path=" + AC_SharedOhlcManifestPath() + "\r\n";
   text += "shared_ohlc_route_status=" + AC_SHARED_OHLC_ROUTE_STATUS + "\r\n";
   text += "shared_ohlc_status_write=" + AC_SHARED_OHLC_STATUS_WRITE + "\r\n";
   text += "shared_ohlc_manifest_write=" + AC_SHARED_OHLC_MANIFEST_WRITE + "\r\n";
   text += "shared_ohlc_scope=broker_universe_symbols_total_false\r\n";
   text += "shared_ohlc_full_seed_scheduler_active=false\r\n";
   text += "shared_ohlc_copyrates_fetch_active=false\r\n";
   return text;
}

#include "AC_Layer7SessionRelevanceRenderer.mqh"
#include "AC_Layer6RankedSidecarRenderer.mqh"
#include "AC_Layer0DossierPublication.mqh"
#include "AC_MarketBoardRenderer.mqh"

#endif