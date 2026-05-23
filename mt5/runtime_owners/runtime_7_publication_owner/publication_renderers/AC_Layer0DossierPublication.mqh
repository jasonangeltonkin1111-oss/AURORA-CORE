#ifndef AC_LAYER0_DOSSIER_PUBLICATION_MQH
#define AC_LAYER0_DOSSIER_PUBLICATION_MQH
static string AC_L0_FIRST_FAILURE = "";
static string AC_L0_FAILURE_ADDENDUM = "";
static int    AC_L0_CACHED_SYMBOLS_TOTAL = -1;
static string AC_L0_CACHED_DOSSIER_SCHEMA_VERSION = "";
static string AC_L0_CACHED_L2_ROUTE_GENERATION_KEY = "";
static string AC_L0_CACHED_L3_CACHE_KEY = "";
static string AC_L0_CACHED_L4_CACHE_KEY = "";
static string AC_L0_CACHED_L4_REFRESH_KEY = "";
static string AC_L0_CACHED_L5_STATUS = "";
static string AC_L0_CACHED_L6_STATUS = "";
static string AC_L0_CACHED_L6_CHECKSUM = "";
static string AC_L0_CACHED_L7_STATUS = "";
static string AC_L0_CACHED_L7_INPUT_CHECKSUM = "";
static string AC_L0_CACHED_L7_RANKED_CHECKSUM = "";
static int    AC_L0_CACHED_L7_RANKED_ROWS = -1;
static bool   AC_L0_CACHED_L7_ACCEPTED = false;
static string AC_L0_CACHED_L8_STATUS = "";
static string AC_L0_CACHED_L8_INPUT_CHECKSUM = "";
static string AC_L0_CACHED_L8_RANKED_CHECKSUM = "";
static int    AC_L0_CACHED_L8_RANKED_ROWS = -1;
static int    AC_L0_CACHED_L8_OHLC_MIN_READY = -1;
static bool   AC_L0_CACHED_L8_ACCEPTED = false;
static bool   AC_L0_CACHED_PASS_VALID = false;
static AC_Layer0StatusPacket AC_L0_CACHED_STATUS;
static AC_WriteResult AC_L0_CACHED_RESULT;
static string AC_L0_INCREMENTAL_SOURCE_KEY = "";
static int    AC_L0_INCREMENTAL_NEXT_INDEX = 0;
static int    AC_L0_INCREMENTAL_WRITTEN_TOTAL = 0;
static int    AC_L0_INCREMENTAL_FAILED_TOTAL = 0;
static int    AC_L0_INCREMENTAL_RETRY_TOTAL = 0;

string AC_PercentText(const int complete_count, const int total_count)
{
   if(total_count <= 0)
      return "Not available";
   double pct = ((double)complete_count * 100.0) / (double)total_count;
   return StringFormat("%.1f%%", pct);
}

string AC_MarketStateTitle(const string market_state)
{
   if(market_state == "open") return "Open";
   if(market_state == "closed") return "Closed";
   return "Unknown";
}

void AC_Layer0InitStatus(AC_Layer0StatusPacket &status)
{
   status.layer_id = "L0";
   status.layer_name = AC_LAYER_0_BOARD_DOSSIER_NAME;
   status.owner_name = AC_BOARD_DOSSIER_RENDERER_OWNER;
   status.status = "Not started";
   status.trust_state = "Not Ready";
   status.main_blocker = "Dossier coverage has not started";
   status.broker_symbols_total = 0;
   status.marketwatch_symbols_total = 0;
   status.dossier_shells_ready = 0;
   status.dossier_shells_missing = 0;
   status.batch_start_index = 0;
   status.batch_end_index = -1;
   status.batch_attempted = 0;
   status.batch_written = 0;
   status.next_symbol_index = 0;
   status.failed_symbol_count = 0;
   status.retry_count_total = 0;
   status.batch_duration_ms = 0;
   status.batch_complete = false;
   status.trade_permission = false;
   status.auto_trade_allowed = false;
   status.ranking_runtime = false;
   status.selection_runtime = false;
   status.market_state_known = false;
   status.specs_known = false;
   status.quotes_known = false;
   status.first_failure = "";
}

AC_WriteResult AC_EmptySyntheticResult()
{
   return AC_MakeSyntheticWriteResult(AC_DossiersUnknownFolder(), true, "not_started", 0, "not_started");
}

string AC_BuildLayer0DossierShellText(const string symbol,
                                      const int broker_index,
                                      const AC_Layer0StatusPacket &status)
{
   string market_state = AC_L2MarketStateForSymbol(symbol);
   string text = "";
   text += "AURORA CORE - SYMBOL DOSSIER\r\n";
   text += "----------------------------------------\r\n";
   text += "Symbol: " + symbol + "\r\n";
   text += "Broker Symbol: " + symbol + "\r\n";
   text += "Market State: " + AC_MarketStateTitle(market_state) + "\r\n";
   text += "Dossier Route: " + AC_DossierSymbolPathByState(symbol, market_state) + "\r\n";
   text += "Server: " + AC_ServerNameForRoute() + "\r\n";
   text += "Account: " + AC_AccountForRoute() + "\r\n";
   text += "Trade Permission: FALSE\r\n";
   text += "Auto Trading: FALSE\r\n";
   text += "\r\n";
   text += "FOUNDATION STATUS\r\n";
   text += "----------------------------------------\r\n";
   text += "Layer 0 Publication: Complete\r\n";
   text += "Layer 1 Account and Portfolio: " + (AC_L1_READY ? "Available" : "Pending") + "\r\n";
   text += "Layer 2 Market State: " + (AC_L2_READY ? AC_L2_SCAN_STATUS : "Pending") + "\r\n";
   text += "Layer 3 Broker Specs and Value: " + (AC_L3_READY ? AC_L3_SCAN_STATUS : "Pending") + "\r\n";
   text += "Layer 4 Live Quote and Spread: " + (market_state == "open" ? (AC_L4_READY ? AC_L4_SCAN_STATUS : "Pending") : "Cut off until market reopens") + "\r\n";
   text += "Layer 5 Basic System Gate: " + AC_L5_STATUS + "\r\n";
   text += "Layer 6 Cost / Friction Ranking: " + AC_L6_STATUS + "\r\n";
   text += "Layer 7 Session Relevance Ranking: " + AC_L7_STATUS + "\r\n";
   text += "Layer 8 Movement / Range Ranking: " + AC_L8_STATUS + "\r\n";
   text += "Shared OHLC Raw Store: " + AC_SHARED_OHLC_STATUS + "\r\n";
   text += "\r\n";
   text += "CURRENT LIMITS\r\n";
   text += "----------------------------------------\r\n";
   text += "Broker Symbol Exists: Yes\r\n";
   text += "Market State Known: " + ((market_state == "open" || market_state == "closed") ? "Yes" : "No") + "\r\n";
   text += "Broker Static Specs: " + (AC_L3_READY ? "Available / Scanned (see Layer 3)" : "Pending Layer 3 scan") + "\r\n";
   text += "Live Quote Truth: " + (market_state == "open" ? (AC_L4_READY ? "Available / Scanned (see Layer 4)" : "Unavailable - Layer 4 not scanned yet") : "Unavailable - market closed or unknown") + "\r\n";
   text += "Cost / Friction Ranking: " + AC_L6_STATUS + "\r\n";
   text += "Session Relevance Ranking: " + AC_L7_STATUS + "\r\n";
   text += "Movement / Range Ranking: " + AC_L8_STATUS + "\r\n";
   text += "Shared OHLC Raw Store: " + AC_SHARED_OHLC_STATUS + "\r\n";
   text += "Selection Active: No\r\n";
   text += "Permission Active: No\r\n";
   text += AC_Layer1DossierSection(symbol);
   text += AC_Layer2DossierSection(symbol);
   text += AC_Layer3DossierSection(symbol);
   text += AC_Layer4DossierSection(symbol);
   text += AC_Layer5DossierSection(symbol);
   text += AC_Layer6DossierSection(symbol);
   text += AC_Layer7DossierSection(symbol);
   text += AC_Layer8DossierSection(symbol);
   text += AC_SharedOhlcRenderDossierSection(symbol);
   text += "\r\nNEXT REQUIRED\r\n";
   text += "----------------------------------------\r\n";
   text += (market_state == "open" ? "Next step: Layer 8 movement/range proof only after OHLC fast windows and Gateway sidecars are accepted\r\n" : "Next step: wait for Layer 2 recheck before deeper layers\r\n");
   text += "Open / Closed owner: Layer 2 only\r\n";
   text += "Layer 6-8 rank only Layer 5 pass symbols; they do not hard-block symbols.\r\n";
   text += "Shared OHLC is raw storage only; future layers must read it instead of calling CopyRates privately.\r\n";
   text += "\r\n";
   text += "NO GO\r\n";
   text += "----------------------------------------\r\n";
   text += "Tradable: No\r\n";
   text += "Selected: No\r\n";
   text += "Alert Active: No\r\n";
   text += "Permission: No\r\n";
   return text;
}

void AC_CleanupOtherDossierRoutes(const string symbol, const string market_state, const bool target_write_ok)
{
   if(!target_write_ok) return;
   string open_path = AC_DossierOpenSymbolPath(symbol);
   string closed_path = AC_DossierClosedSymbolPath(symbol);
   string unknown_path = AC_DossierUnknownSymbolPath(symbol);
   string target_path = AC_DossierSymbolPathByState(symbol, market_state);
   if(open_path != target_path)
   {
      AC_WriteResult cleanup_open = AC_DeleteFileIfExists(open_path);
      if(cleanup_open.status == "deleted") AC_L2_DUPLICATE_CLEANUP_COUNT++;
      else if(!cleanup_open.ok) AC_L2_DUPLICATE_CLEANUP_FAILURE_COUNT++;
   }
   if(closed_path != target_path)
   {
      AC_WriteResult cleanup_closed = AC_DeleteFileIfExists(closed_path);
      if(cleanup_closed.status == "deleted") AC_L2_DUPLICATE_CLEANUP_COUNT++;
      else if(!cleanup_closed.ok) AC_L2_DUPLICATE_CLEANUP_FAILURE_COUNT++;
   }
   if(unknown_path != target_path)
   {
      AC_WriteResult cleanup_unknown = AC_DeleteFileIfExists(unknown_path);
      if(cleanup_unknown.status == "deleted") AC_L2_DUPLICATE_CLEANUP_COUNT++;
      else if(!cleanup_unknown.ok) AC_L2_DUPLICATE_CLEANUP_FAILURE_COUNT++;
   }
}

bool AC_WriteLayer0ShellWithRetries(const string symbol,
                                    const int broker_index,
                                    const AC_Layer0StatusPacket &status,
                                    int &retries_used,
                                    string &failure_line)
{
   retries_used = 0;
   failure_line = "";
   int max_attempts = AC_DOSSIER_SHELL_WRITE_RETRIES;
   if(max_attempts < 1) max_attempts = 1;
   string market_state = AC_L2MarketStateForSymbol(symbol);
   string target_path = AC_DossierSymbolPathByState(symbol, market_state);
   for(int attempt = 1; attempt <= max_attempts; attempt++)
   {
      AC_WriteResult write = AC_WriteTextFileFastAtomic(target_path, AC_BuildLayer0DossierShellText(symbol, broker_index, status));
      if(write.ok)
      {
         if(market_state == "open") AC_L2_ROUTE_WRITE_OPEN_COUNT++;
         else if(market_state == "closed") AC_L2_ROUTE_WRITE_CLOSED_COUNT++;
         else AC_L2_ROUTE_WRITE_UNKNOWN_COUNT++;
         AC_CleanupOtherDossierRoutes(symbol, market_state, true);
         retries_used = attempt - 1;
         return true;
      }
      retries_used = attempt;
      failure_line = "symbol=" + symbol + "|index=" + IntegerToString(broker_index) + "|state=" + market_state + "|attempt=" + IntegerToString(attempt) + "|status=" + write.status + "|error=" + IntegerToString(write.error_code);
   }
   AC_L2_ROUTE_WRITE_FAILURE_COUNT++;
   return false;
}

void AC_L0CacheLayer7Proof()
{
   AC_L7RefreshRankedSidecar();
   AC_L0_CACHED_L7_STATUS = AC_L7_STATUS;
   AC_L0_CACHED_L7_INPUT_CHECKSUM = AC_L7_INPUT_PAYLOAD_CHECKSUM_RENDERED;
   AC_L0_CACHED_L7_RANKED_CHECKSUM = AC_L7_RANKED_PAYLOAD_CHECKSUM_RENDERED;
   AC_L0_CACHED_L7_RANKED_ROWS = AC_L7_RANKED_ROWS_RENDERED;
   AC_L0_CACHED_L7_ACCEPTED = AC_L7_RANKED_ACCEPTED;
}

void AC_L0CacheLayer8Proof()
{
   AC_L8RefreshRankedSidecar();
   AC_L0_CACHED_L8_STATUS = AC_L8_STATUS;
   AC_L0_CACHED_L8_INPUT_CHECKSUM = AC_L8_INPUT_PAYLOAD_CHECKSUM_RENDERED;
   AC_L0_CACHED_L8_RANKED_CHECKSUM = AC_L8_RANKED_PAYLOAD_CHECKSUM_RENDERED;
   AC_L0_CACHED_L8_RANKED_ROWS = AC_L8_RANKED_ROWS_RENDERED;
   AC_L0_CACHED_L8_OHLC_MIN_READY = AC_L8_OHLC_MIN_READY_RENDERED;
   AC_L0_CACHED_L8_ACCEPTED = AC_L8_RANKED_ACCEPTED;
}

void AC_L0RefreshDossierSectionDependencies()
{
   // Dossier shell text renders L2/L3/L4/L5/L6/L7/L8/OHLC sections.
   // Refresh these packets before any symbol file is written so cached proof and physical Dossier content cannot split-brain.
   AC_BuildLayer2Texts();
   AC_BuildLayer3Texts();
   AC_BuildLayer4Texts();
   AC_BuildLayer5Texts();
   AC_RefreshLayer6RankedSidecar();
   AC_L0CacheLayer7Proof();
   AC_L0CacheLayer8Proof();
}

string AC_L0DossierSourceKey(const int total)
{
   return "schema=" + AC_DOSSIER_SHELL_SCHEMA_VERSION
      + "|total=" + IntegerToString(total)
      + "|l2=" + AC_L2_ROUTE_GENERATION_KEY
      + "|l3=" + AC_L3_CACHE_KEY
      + "|l4=" + AC_L4_CACHE_KEY
      + "|l4_refresh=" + AC_L4_REFRESH_KEY
      + "|l5=" + AC_L5_STATUS
      + "|l6=" + AC_L6_STATUS
      + "|l6_checksum=" + AC_L6_MANIFEST_PAYLOAD_CHECKSUM
      + "|l7=" + AC_L7_STATUS
      + "|l7_input=" + AC_L7_INPUT_PAYLOAD_CHECKSUM_RENDERED
      + "|l7_ranked=" + AC_L7_RANKED_PAYLOAD_CHECKSUM_RENDERED
      + "|l7_rows=" + IntegerToString(AC_L7_RANKED_ROWS_RENDERED)
      + "|l7_accepted=" + (AC_L7_RANKED_ACCEPTED ? "true" : "false")
      + "|l8=" + AC_L8_STATUS
      + "|l8_input=" + AC_L8_INPUT_PAYLOAD_CHECKSUM_RENDERED
      + "|l8_ranked=" + AC_L8_RANKED_PAYLOAD_CHECKSUM_RENDERED
      + "|l8_rows=" + IntegerToString(AC_L8_RANKED_ROWS_RENDERED)
      + "|l8_ohlc_min=" + IntegerToString(AC_L8_OHLC_MIN_READY_RENDERED)
      + "|l8_accepted=" + (AC_L8_RANKED_ACCEPTED ? "true" : "false")
      + "|ohlc=" + AC_SHARED_OHLC_STATUS
      + "|ohlc_mode=" + AC_SHARED_OHLC_MODE
      + "|ohlc_l8_fast=" + IntegerToString(AC_SHARED_OHLC_L8_FAST_READY);
}

void AC_L0ResetIncrementalPass(const string source_key)
{
   AC_L0_INCREMENTAL_SOURCE_KEY = source_key;
   AC_L0_INCREMENTAL_NEXT_INDEX = 0;
   AC_L0_INCREMENTAL_WRITTEN_TOTAL = 0;
   AC_L0_INCREMENTAL_FAILED_TOTAL = 0;
   AC_L0_INCREMENTAL_RETRY_TOTAL = 0;
   AC_L0_CACHED_PASS_VALID = false;
}

AC_WriteResult AC_RunLayer0UniverseShellPass(AC_Layer0StatusPacket &status)
{
   AC_Layer0InitStatus(status);
   AC_L0_FIRST_FAILURE = "";
   AC_L0_FAILURE_ADDENDUM = "";
   uint start_ms = GetTickCount();
   int total = SymbolsTotal(false);
   int marketwatch_total = SymbolsTotal(true);
   status.broker_symbols_total = total;
   status.marketwatch_symbols_total = marketwatch_total;
   AC_L0RefreshDossierSectionDependencies();
   string source_key = AC_L0DossierSourceKey(total);
   if(source_key != AC_L0_INCREMENTAL_SOURCE_KEY || AC_L0_INCREMENTAL_NEXT_INDEX < 0 || AC_L0_INCREMENTAL_NEXT_INDEX >= total)
      AC_L0ResetIncrementalPass(source_key);

   int max_symbols = AC_DOSSIER_UNIVERSE_MAX_SYMBOLS_PER_PASS;
   if(max_symbols < 1) max_symbols = 1;
   int budget_ms = AC_DOSSIER_UNIVERSE_PASS_BUDGET_MS;
   if(budget_ms < 10) budget_ms = 10;
   int start_index = AC_L0_INCREMENTAL_NEXT_INDEX;
   int end_limit = MathMin(total, start_index + max_symbols);
   status.batch_start_index = start_index;
   status.batch_end_index = start_index - 1;

   bool all_ok = true;
   int attempted = 0;
   int written = 0;
   int failed = 0;
   int retries_total = 0;
   for(int idx = start_index; idx < end_limit; idx++)
   {
      if(attempted > 0 && (GetTickCount() - start_ms) >= (uint)budget_ms)
         break;
      attempted++;
      string symbol = SymbolName(idx, false);
      if(symbol == "")
      {
         all_ok = false;
         failed++;
         string failure = "symbol=<empty>|index=" + IntegerToString(idx) + "|status=empty_symbol_name";
         if(AC_L0_FIRST_FAILURE == "") AC_L0_FIRST_FAILURE = failure;
         AC_L0_FAILURE_ADDENDUM += failure + "\r\n";
         continue;
      }
      int retries_used = 0;
      string failure_line = "";
      if(AC_WriteLayer0ShellWithRetries(symbol, idx, status, retries_used, failure_line))
      {
         written++;
         retries_total += retries_used;
      }
      else
      {
         all_ok = false;
         failed++;
         retries_total += retries_used;
         if(AC_L0_FIRST_FAILURE == "") AC_L0_FIRST_FAILURE = failure_line;
         AC_L0_FAILURE_ADDENDUM += failure_line + "\r\n";
      }
   }

   AC_L0_INCREMENTAL_NEXT_INDEX = start_index + attempted;
   status.batch_end_index = AC_L0_INCREMENTAL_NEXT_INDEX - 1;
   AC_L0_INCREMENTAL_WRITTEN_TOTAL += written;
   AC_L0_INCREMENTAL_FAILED_TOTAL += failed;
   AC_L0_INCREMENTAL_RETRY_TOTAL += retries_total;

   status.batch_attempted = attempted;
   status.batch_written = written;
   status.dossier_shells_ready = AC_L0_INCREMENTAL_WRITTEN_TOTAL;
   status.dossier_shells_missing = total - AC_L0_INCREMENTAL_WRITTEN_TOTAL;
   if(status.dossier_shells_missing < 0) status.dossier_shells_missing = 0;
   status.next_symbol_index = AC_L0_INCREMENTAL_NEXT_INDEX;
   status.batch_complete = (total > 0 && AC_L0_INCREMENTAL_NEXT_INDEX >= total);
   status.batch_duration_ms = GetTickCount() - start_ms;
   status.failed_symbol_count = AC_L0_INCREMENTAL_FAILED_TOTAL;
   status.retry_count_total = AC_L0_INCREMENTAL_RETRY_TOTAL;
   status.first_failure = AC_L0_FIRST_FAILURE;

   if(total <= 0)
   {
      status.status = "Waiting for broker symbol universe";
      status.main_blocker = "SymbolsTotal(false) returned zero";
   }
   else if(status.batch_complete && AC_L0_INCREMENTAL_FAILED_TOTAL == 0)
   {
      status.status = "Complete";
      status.trust_state = "Dossiers Ready";
      status.main_blocker = AC_L6_MAIN_BLOCKER == "none" ? (AC_L7_MAIN_BLOCKER == "none" ? (AC_L8_MAIN_BLOCKER == "none" ? AC_L5_MAIN_BLOCKER : AC_L8_MAIN_BLOCKER) : AC_L7_MAIN_BLOCKER) : AC_L6_MAIN_BLOCKER;
   }
   else if(status.batch_complete)
   {
      status.status = "Complete with warnings";
      status.trust_state = "Dossiers Degraded";
      status.main_blocker = "Some symbol Dossier packets failed; see Upgrade Addendum";
   }
   else
   {
      status.status = "Incremental publishing";
      status.trust_state = "Dossiers Updating";
      status.main_blocker = "Dossier universe bounded time-slice in progress to protect timer budget";
   }

   string batch_status = status.batch_complete ? ((AC_L0_INCREMENTAL_FAILED_TOTAL == 0) ? "dossier_universe_complete" : "dossier_universe_complete_with_degraded") : "dossier_universe_partial_bounded_pass";
   if(status.batch_complete)
   {
      AC_L0_CACHED_SYMBOLS_TOTAL = total;
      AC_L0_CACHED_DOSSIER_SCHEMA_VERSION = AC_DOSSIER_SHELL_SCHEMA_VERSION;
      AC_L0_CACHED_L2_ROUTE_GENERATION_KEY = AC_L2_ROUTE_GENERATION_KEY;
      AC_L0_CACHED_L3_CACHE_KEY = AC_L3_CACHE_KEY;
      AC_L0_CACHED_L4_CACHE_KEY = AC_L4_CACHE_KEY;
      AC_L0_CACHED_L4_REFRESH_KEY = AC_L4_REFRESH_KEY;
      AC_L0_CACHED_L5_STATUS = AC_L5_STATUS;
      AC_L0_CACHED_L6_STATUS = AC_L6_STATUS;
      AC_L0_CACHED_L6_CHECKSUM = AC_L6_MANIFEST_PAYLOAD_CHECKSUM;
      AC_L0CacheLayer7Proof();
      AC_L0CacheLayer8Proof();
      AC_L0_CACHED_PASS_VALID = true;
      AC_L0_CACHED_STATUS = status;
      AC_L0_CACHED_RESULT = AC_MakeSyntheticWriteResult(AC_DossiersFolder(), AC_L0_INCREMENTAL_FAILED_TOTAL == 0, batch_status, (ulong)AC_L0_INCREMENTAL_WRITTEN_TOTAL, "bounded_dossier_universe_pass_complete|source_key=" + source_key + "|max_symbols_per_pass=" + IntegerToString(max_symbols) + "|budget_ms=" + IntegerToString(budget_ms));
      return AC_L0_CACHED_RESULT;
   }

   AC_L0_CACHED_PASS_VALID = false;
   return AC_MakeSyntheticWriteResult(AC_DossiersFolder(), all_ok, batch_status, (ulong)written, "bounded_dossier_universe_pass_partial|source_key=" + source_key + "|start=" + IntegerToString(start_index) + "|end=" + IntegerToString(status.batch_end_index) + "|next=" + IntegerToString(AC_L0_INCREMENTAL_NEXT_INDEX) + "|max_symbols_per_pass=" + IntegerToString(max_symbols) + "|budget_ms=" + IntegerToString(budget_ms));
}

AC_WriteResult AC_PublishLayer0DossierBatch(AC_Layer0StatusPacket &status)
{
   AC_RefreshLayer6RankedSidecar();
   AC_L7RefreshRankedSidecar();
   AC_L8RefreshRankedSidecar();
   int total = SymbolsTotal(false);
   if(AC_L0_CACHED_PASS_VALID
      && total == AC_L0_CACHED_SYMBOLS_TOTAL
      && AC_L0_CACHED_DOSSIER_SCHEMA_VERSION == AC_DOSSIER_SHELL_SCHEMA_VERSION
      && AC_L0_CACHED_L2_ROUTE_GENERATION_KEY == AC_L2_ROUTE_GENERATION_KEY
      && AC_L0_CACHED_L3_CACHE_KEY == AC_L3_CACHE_KEY
      && AC_L0_CACHED_L4_CACHE_KEY == AC_L4_CACHE_KEY
      && AC_L0_CACHED_L4_REFRESH_KEY == AC_L4_REFRESH_KEY
      && AC_L0_CACHED_L5_STATUS == AC_L5_STATUS
      && AC_L0_CACHED_L6_STATUS == AC_L6_STATUS
      && AC_L0_CACHED_L6_CHECKSUM == AC_L6_MANIFEST_PAYLOAD_CHECKSUM
      && AC_L0_CACHED_L7_STATUS == AC_L7_STATUS
      && AC_L0_CACHED_L7_INPUT_CHECKSUM == AC_L7_INPUT_PAYLOAD_CHECKSUM_RENDERED
      && AC_L0_CACHED_L7_RANKED_CHECKSUM == AC_L7_RANKED_PAYLOAD_CHECKSUM_RENDERED
      && AC_L0_CACHED_L7_RANKED_ROWS == AC_L7_RANKED_ROWS_RENDERED
      && AC_L0_CACHED_L7_ACCEPTED == AC_L7_RANKED_ACCEPTED
      && AC_L0_CACHED_L8_STATUS == AC_L8_STATUS
      && AC_L0_CACHED_L8_INPUT_CHECKSUM == AC_L8_INPUT_PAYLOAD_CHECKSUM_RENDERED
      && AC_L0_CACHED_L8_RANKED_CHECKSUM == AC_L8_RANKED_PAYLOAD_CHECKSUM_RENDERED
      && AC_L0_CACHED_L8_RANKED_ROWS == AC_L8_RANKED_ROWS_RENDERED
      && AC_L0_CACHED_L8_OHLC_MIN_READY == AC_L8_OHLC_MIN_READY_RENDERED
      && AC_L0_CACHED_L8_ACCEPTED == AC_L8_RANKED_ACCEPTED)
   {
      status = AC_L0_CACHED_STATUS;
      status.marketwatch_symbols_total = SymbolsTotal(true);
      return AC_MakeSyntheticWriteResult(AC_DossiersFolder(), true, "dossier_universe_cached_no_rewrite", (ulong)status.dossier_shells_ready, "cached_universe_status_no_symbol_rewrite|schema=" + AC_L0_CACHED_DOSSIER_SCHEMA_VERSION + "|l2=" + AC_L0_CACHED_L2_ROUTE_GENERATION_KEY + "|l3=" + AC_L0_CACHED_L3_CACHE_KEY + "|l4=" + AC_L0_CACHED_L4_CACHE_KEY + "|l4_refresh=" + AC_L0_CACHED_L4_REFRESH_KEY + "|l5=" + AC_L0_CACHED_L5_STATUS + "|l6=" + AC_L0_CACHED_L6_STATUS + "|l6_checksum=" + AC_L0_CACHED_L6_CHECKSUM + "|l7=" + AC_L0_CACHED_L7_STATUS + "|l7_input_checksum=" + AC_L0_CACHED_L7_INPUT_CHECKSUM + "|l7_ranked_checksum=" + AC_L0_CACHED_L7_RANKED_CHECKSUM + "|l7_rows=" + IntegerToString(AC_L0_CACHED_L7_RANKED_ROWS) + "|l8=" + AC_L0_CACHED_L8_STATUS + "|l8_input_checksum=" + AC_L0_CACHED_L8_INPUT_CHECKSUM + "|l8_ranked_checksum=" + AC_L0_CACHED_L8_RANKED_CHECKSUM + "|l8_rows=" + IntegerToString(AC_L0_CACHED_L8_RANKED_ROWS));
   }
   return AC_RunLayer0UniverseShellPass(status);
}

#endif
