#ifndef AC_SHARED_OHLC_ROUTES_MQH
#define AC_SHARED_OHLC_ROUTES_MQH

// Publication / FileIO / Route Service route extension for Shared OHLC Raw Storage.
// Route owner only. No OHLC truth, no CopyRates, no calculation, no ranking, no permission.

string AC_ServerRootFolder()
{
   return AC_BASE_FOLDER + "\\" + AC_ServerNameForRoute();
}

string AC_SharedMarketDataFolder()
{
   return AC_ServerRootFolder() + "\\Shared Market Data";
}

string AC_SharedOhlcRootFolder()
{
   return AC_SharedMarketDataFolder() + "\\OHLC Store";
}

string AC_SharedOhlcStatusFolder()
{
   return AC_SharedOhlcRootFolder() + "\\Status";
}

string AC_SharedOhlcSymbolsFolder()
{
   return AC_SharedOhlcRootFolder() + "\\Symbols";
}

string AC_SharedOhlcSymbolFolder(const string symbol)
{
   return AC_SharedOhlcSymbolsFolder() + "\\" + AC_SanitizePathPart(symbol);
}

string AC_SharedOhlcCurrentFolder(const string symbol)
{
   return AC_SharedOhlcSymbolFolder(symbol) + "\\Current";
}

string AC_SharedOhlcClosedBarsPath(const string symbol, const string timeframe_label)
{
   return AC_SharedOhlcSymbolFolder(symbol) + "\\" + AC_SanitizePathPart(timeframe_label) + ".ohlc.csv";
}

string AC_SharedOhlcCurrentBarPath(const string symbol, const string timeframe_label)
{
   return AC_SharedOhlcCurrentFolder(symbol) + "\\" + AC_SanitizePathPart(timeframe_label) + ".current.csv";
}

string AC_SharedOhlcSymbolSummaryPath(const string symbol)
{
   return AC_SharedOhlcSymbolFolder(symbol) + "\\summary.txt";
}

string AC_SharedOhlcManifestPath()
{
   return AC_SharedOhlcStatusFolder() + "\\manifest.txt";
}

string AC_SharedOhlcStatusPath()
{
   return AC_SharedOhlcStatusFolder() + "\\status.txt";
}

string AC_SharedOhlcIndexPath()
{
   return AC_SharedOhlcStatusFolder() + "\\symbol_timeframe_index.csv";
}

bool AC_EnsureSharedOhlcBaseFolders(string &detail)
{
   string server_detail = "";
   string shared_market_data_detail = "";
   string root_detail = "";
   string status_detail = "";
   string symbols_detail = "";

   bool server_ok = AC_EnsureFolderPath(AC_ServerRootFolder(), server_detail);
   bool shared_market_data_ok = AC_EnsureFolderPath(AC_SharedMarketDataFolder(), shared_market_data_detail);
   bool root_ok = AC_EnsureFolderPath(AC_SharedOhlcRootFolder(), root_detail);
   bool status_ok = AC_EnsureFolderPath(AC_SharedOhlcStatusFolder(), status_detail);
   bool symbols_ok = AC_EnsureFolderPath(AC_SharedOhlcSymbolsFolder(), symbols_detail);

   detail = "server_root=" + server_detail
      + ";shared_market_data=" + shared_market_data_detail
      + ";shared_ohlc_root=" + root_detail
      + ";shared_ohlc_status=" + status_detail
      + ";shared_ohlc_symbols=" + symbols_detail
      + ";shared_ohlc_status_path=" + AC_SharedOhlcStatusPath()
      + ";shared_ohlc_manifest_path=" + AC_SharedOhlcManifestPath()
      + ";shared_ohlc_index_path=" + AC_SharedOhlcIndexPath();

   return server_ok && shared_market_data_ok && root_ok && status_ok && symbols_ok;
}

bool AC_EnsureSharedOhlcSymbolFolders(const string symbol, string &detail)
{
   string symbol_detail = "";
   string current_detail = "";

   bool symbol_ok = AC_EnsureFolderPath(AC_SharedOhlcSymbolFolder(symbol), symbol_detail);
   bool current_ok = AC_EnsureFolderPath(AC_SharedOhlcCurrentFolder(symbol), current_detail);

   detail = "symbol=" + AC_SanitizePathPart(symbol)
      + ";symbol_folder=" + symbol_detail
      + ";current_folder=" + current_detail;

   return symbol_ok && current_ok;
}

#endif
