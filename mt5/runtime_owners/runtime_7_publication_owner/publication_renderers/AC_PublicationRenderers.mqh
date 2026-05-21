#ifndef AC_PUBLICATION_RENDERERS_MQH
#define AC_PUBLICATION_RENDERERS_MQH

// Board / Dossier Renderer Service.
// Renders prepared owner/status packets only. It must not compute trading truth,
// ranking, selection, market-open state, broker specs, quotes, or permission.

static string AC_L0_FIRST_FAILURE = "";
static string AC_L0_FAILURE_ADDENDUM = "";
static int    AC_L0_CACHED_SYMBOLS_TOTAL = -1;
static string AC_L0_CACHED_DOSSIER_SCHEMA_VERSION = "";
static string AC_L0_CACHED_L2_ROUTE_GENERATION_KEY = "";
static string AC_L0_CACHED_L3_CACHE_KEY = "";
static bool   AC_L0_CACHED_PASS_VALID = false;
static AC_Layer0StatusPacket AC_L0_CACHED_STATUS;
static AC_WriteResult AC_L0_CACHED_RESULT;

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
   text += "Layer 4 Quote, Tick, and Spread: " + (market_state == "open" ? "Pending" : "Cut off until market reopens") + "\r\n";
   text += "Layer 5 Basic Gate: " + (market_state == "open" ? "Pending" : "Cut off until market reopens") + "\r\n";
   text += "\r\n";
   text += "CURRENT LIMITS\r\n";
   text += "----------------------------------------\r\n";
   text += "Broker Symbol Exists: Yes\r\n";
   text += "Market State Known: " + ((market_state == "open" || market_state == "closed") ? "Yes" : "No") + "\r\n";
   text += "Broker Specs Known: " + (AC_L3_READY && market_state == "open" ? "See Layer 3" : "No") + "\r\n";
   text += "Live Quote Truth Known: No\r\n";
   text += "Ranking Active: No\r\n";
   text += "Selection Active: No\r\n";
   text += "Permission Active: No\r\n";
   text += AC_Layer1DossierSection(symbol);
   text += AC_Layer2DossierSection(symbol);
   text += AC_Layer3DossierSection(symbol);
   text += "\r\nNEXT REQUIRED\r\n";
   text += "----------------------------------------\r\n";
   text += (market_state == "open" ? "Next step: Layer 4 quote, tick, and spread truth\r\n" : "Next step: wait for Layer 2 recheck before deeper layers\r\n");
   text += "Open / Closed owner: Layer 2 only\r\n";
   text += "\r\n";
   text += "NO GO\r\n";
   text += "----------------------------------------\r\n";
   text += "Tradable: No\r\n";
   text += "Ranked: No\r\n";
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
   if(max_attempts < 1)
      max_attempts = 1;

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
   status.batch_start_index = 0;
   status.batch_end_index = total - 1;

   bool all_ok = true;
   int attempted = 0;
   int written = 0;
   int failed = 0;
   int retries_total = 0;

   for(int idx = 0; idx < total; idx++)
   {
      attempted++;
      string symbol = SymbolName(idx, false);
      if(symbol == "")
      {
         all_ok = false;
         failed++;
         string failure = "symbol=<empty>|index=" + IntegerToString(idx) + "|status=empty_symbol_name";
         if(AC_L0_FIRST_FAILURE == "")
            AC_L0_FIRST_FAILURE = failure;
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
         if(AC_L0_FIRST_FAILURE == "")
            AC_L0_FIRST_FAILURE = failure_line;
         AC_L0_FAILURE_ADDENDUM += failure_line + "\r\n";
      }
   }

   status.batch_attempted = attempted;
   status.batch_written = written;
   status.dossier_shells_ready = written;
   status.dossier_shells_missing = total - written;
   if(status.dossier_shells_missing < 0)
      status.dossier_shells_missing = 0;
   status.next_symbol_index = total;
   status.batch_complete = (total > 0 && written == total);
   status.batch_duration_ms = GetTickCount() - start_ms;
   status.failed_symbol_count = failed;
   status.retry_count_total = retries_total;
   status.first_failure = AC_L0_FIRST_FAILURE;

   if(total <= 0)
   {
      status.status = "Waiting for broker symbol universe";
      status.main_blocker = "SymbolsTotal(false) returned zero";
   }
   else if(status.batch_complete && failed == 0)
   {
      status.status = "Complete";
      status.trust_state = "Dossiers Ready";
      status.main_blocker = "Layer 4 quote, tick, and spread truth not started";
   }
   else
   {
      status.status = "Complete with warnings";
      status.trust_state = "Dossiers Degraded";
      status.main_blocker = "Some symbol Dossier packets failed; see Upgrade Addendum";
   }

   string batch_status = all_ok ? "dossier_universe_complete" : "dossier_universe_complete_with_degraded";
   AC_L0_CACHED_SYMBOLS_TOTAL = total;
   AC_L0_CACHED_DOSSIER_SCHEMA_VERSION = AC_DOSSIER_SHELL_SCHEMA_VERSION;
   AC_L0_CACHED_L2_ROUTE_GENERATION_KEY = AC_L2_ROUTE_GENERATION_KEY;
   AC_L0_CACHED_L3_CACHE_KEY = AC_L3_CACHE_KEY;
   AC_L0_CACHED_PASS_VALID = true;
   AC_L0_CACHED_STATUS = status;
   AC_BuildLayer2Texts();
   AC_BuildLayer3Texts();
   AC_L0_CACHED_RESULT = AC_MakeSyntheticWriteResult(AC_DossiersFolder(), all_ok, batch_status, (ulong)written, "full_universe_dossier_pass_with_l2_routes_and_l3_sections");
   return AC_L0_CACHED_RESULT;
}

AC_WriteResult AC_PublishLayer0DossierBatch(AC_Layer0StatusPacket &status)
{
   int total = SymbolsTotal(false);
   if(AC_L0_CACHED_PASS_VALID
      && total == AC_L0_CACHED_SYMBOLS_TOTAL
      && AC_L0_CACHED_DOSSIER_SCHEMA_VERSION == AC_DOSSIER_SHELL_SCHEMA_VERSION
      && AC_L0_CACHED_L2_ROUTE_GENERATION_KEY == AC_L2_ROUTE_GENERATION_KEY
      && AC_L0_CACHED_L3_CACHE_KEY == AC_L3_CACHE_KEY)
   {
      status = AC_L0_CACHED_STATUS;
      status.marketwatch_symbols_total = SymbolsTotal(true);
      return AC_MakeSyntheticWriteResult(AC_DossiersFolder(), true, "dossier_universe_cached_no_rewrite", (ulong)status.dossier_shells_ready, "cached_universe_status_no_symbol_rewrite|schema=" + AC_L0_CACHED_DOSSIER_SCHEMA_VERSION + "|l2=" + AC_L0_CACHED_L2_ROUTE_GENERATION_KEY + "|l3=" + AC_L0_CACHED_L3_CACHE_KEY);
   }
   return AC_RunLayer0UniverseShellPass(status);
}

string AC_BuildTraderBoardText(const AC_Runtime0Snapshot &snapshot,
                               const AC_Layer0StatusPacket &status)
{
   string text = "";
   text += "AURORA CORE - MARKET BOARD\r\n";
   text += "----------------------------------------\r\n";
   text += "State:            " + status.status + "\r\n";
   text += "Trust:            " + status.trust_state + "\r\n";
   text += "Trade Permission: FALSE\r\n";
   text += "Auto Trading:     FALSE\r\n";
   text += "\r\n";
   text += "DOSSIER COVERAGE\r\n";
   text += "----------------------------------------\r\n";
   text += "Broker Symbols Seen:    " + IntegerToString(status.broker_symbols_total) + "\r\n";
   text += "Dossiers Ready:         " + IntegerToString(status.dossier_shells_ready) + " / " + IntegerToString(status.broker_symbols_total) + "\r\n";
   text += "Dossiers Missing:       " + IntegerToString(status.dossier_shells_missing) + "\r\n";
   text += "Completion:             " + AC_PercentText(status.dossier_shells_ready, status.broker_symbols_total) + "\r\n";
   text += "Failed Dossiers:        " + IntegerToString(status.failed_symbol_count) + "\r\n";
   text += "Dossier Pass Duration:  " + IntegerToString((int)status.batch_duration_ms) + " ms\r\n";
   text += "\r\n";
   text += "CURRENT FOUNDATION\r\n";
   text += "----------------------------------------\r\n";
   text += "Layer 0: Publication + Dossier Foundation\r\n";
   text += "Layer 1: Account / Portfolio Truth\r\n";
   text += "Layer 2: Market Open / Closed Truth\r\n";
   text += "Layer 3: Broker Specs and Value Truth\r\n";
   text += "Next Layer Needed: Layer 4 quote, tick, and spread truth\r\n";
   text += AC_Layer1BoardSection();
   text += AC_Layer2BoardSection();
   text += AC_Layer3BoardSection();
   text += "\r\nTRADING READINESS\r\n";
   text += "----------------------------------------\r\n";
   text += "Market State Known: " + ((AC_L2_OPEN_COUNT + AC_L2_CLOSED_COUNT) > 0 ? "Partial or Complete" : "No") + "\r\n";
   text += "Specs Known:        " + (AC_L3_READY ? "See Layer 3 readiness" : "No") + "\r\n";
   text += "Quotes Known:       No\r\n";
   text += "Ranking Active:     No\r\n";
   text += "Selection Active:   No\r\n";
   text += "Permission Active:  No\r\n";
   text += "\r\n";
   text += "TRUST BLOCKER\r\n";
   text += "----------------------------------------\r\n";
   text += status.main_blocker + "\r\n";
   text += "Closed symbols are cut off from deeper layers until their Layer 2 recheck.\r\n";
   text += "\r\n";
   text += "ACTION\r\n";
   text += "----------------------------------------\r\n";
   text += "Board refresh is atomic and writes only when state text changes.\r\n";
   text += "No ranking, selection, alerts, or trade permission exists.\r\n";
   return text;
}

string AC_Layer0StatusRow(const AC_Layer0StatusPacket &status)
{
   return "schema_name=layer_status|schema_version=v0.7|layer_id=L0|layer_name=" + status.layer_name
      + "|source_owner=" + status.owner_name
      + "|status=" + status.status
      + "|trust_state=" + status.trust_state
      + "|broker_symbols_total=" + IntegerToString(status.broker_symbols_total)
      + "|marketwatch_symbols_total=" + IntegerToString(status.marketwatch_symbols_total)
      + "|dossier_shells_ready=" + IntegerToString(status.dossier_shells_ready)
      + "|dossier_shells_missing=" + IntegerToString(status.dossier_shells_missing)
      + "|failed_symbol_count=" + IntegerToString(status.failed_symbol_count)
      + "|retry_count_total=" + IntegerToString(status.retry_count_total)
      + "|completion=" + AC_PercentText(status.dossier_shells_ready, status.broker_symbols_total)
      + "|pass_start_index=" + IntegerToString(status.batch_start_index)
      + "|pass_end_index=" + IntegerToString(status.batch_end_index)
      + "|symbols_attempted=" + IntegerToString(status.batch_attempted)
      + "|symbols_written=" + IntegerToString(status.batch_written)
      + "|pass_duration_ms=" + IntegerToString((int)status.batch_duration_ms)
      + "|cached_pass_valid=" + (AC_L0_CACHED_PASS_VALID ? "true" : "false")
      + "|dossier_shell_schema_version=" + AC_DOSSIER_SHELL_SCHEMA_VERSION
      + "|cached_dossier_shell_schema_version=" + AC_L0_CACHED_DOSSIER_SCHEMA_VERSION
      + "|cached_l2_route_generation_key=" + AC_L0_CACHED_L2_ROUTE_GENERATION_KEY
      + "|cached_l3_cache_key=" + AC_L0_CACHED_L3_CACHE_KEY
      + "|main_blocker=" + status.main_blocker
      + "|trade_permission=false|ranking_runtime=false|selection_runtime=false|market_state_known=" + (((AC_L2_OPEN_COUNT + AC_L2_CLOSED_COUNT) > 0) ? "true" : "false");
}

string AC_Layer0WorkbenchText(const AC_Layer0StatusPacket &status)
{
   string text = "";
   text += "L0_BOARD_DOSSIER_FOUNDATION\r\n";
   text += "----------------------------------------\r\n";
   text += "layer_id=L0\r\n";
   text += "layer_name=" + status.layer_name + "\r\n";
   text += "owner_name=" + status.owner_name + "\r\n";
   text += "status=" + status.status + "\r\n";
   text += "trust_state=" + status.trust_state + "\r\n";
   text += "broker_symbols_total=" + IntegerToString(status.broker_symbols_total) + "\r\n";
   text += "marketwatch_symbols_total=" + IntegerToString(status.marketwatch_symbols_total) + "\r\n";
   text += "dossier_shells_ready=" + IntegerToString(status.dossier_shells_ready) + "\r\n";
   text += "dossier_shells_missing=" + IntegerToString(status.dossier_shells_missing) + "\r\n";
   text += "failed_symbol_count=" + IntegerToString(status.failed_symbol_count) + "\r\n";
   text += "retry_count_total=" + IntegerToString(status.retry_count_total) + "\r\n";
   text += "completion=" + AC_PercentText(status.dossier_shells_ready, status.broker_symbols_total) + "\r\n";
   text += "pass_start_index=" + IntegerToString(status.batch_start_index) + "\r\n";
   text += "pass_end_index=" + IntegerToString(status.batch_end_index) + "\r\n";
   text += "symbols_attempted=" + IntegerToString(status.batch_attempted) + "\r\n";
   text += "symbols_written=" + IntegerToString(status.batch_written) + "\r\n";
   text += "pass_duration_ms=" + IntegerToString((int)status.batch_duration_ms) + "\r\n";
   text += "cached_pass_valid=" + (AC_L0_CACHED_PASS_VALID ? "true" : "false") + "\r\n";
   text += "dossier_shell_schema_version=" + AC_DOSSIER_SHELL_SCHEMA_VERSION + "\r\n";
   text += "cached_dossier_shell_schema_version=" + AC_L0_CACHED_DOSSIER_SCHEMA_VERSION + "\r\n";
   text += "l2_route_generation_key=" + AC_L2_ROUTE_GENERATION_KEY + "\r\n";
   text += "cached_l2_route_generation_key=" + AC_L0_CACHED_L2_ROUTE_GENERATION_KEY + "\r\n";
   text += "l3_cache_key=" + AC_L3_CACHE_KEY + "\r\n";
   text += "cached_l3_cache_key=" + AC_L0_CACHED_L3_CACHE_KEY + "\r\n";
   text += "main_blocker=" + status.main_blocker + "\r\n";
   text += "first_failure=" + status.first_failure + "\r\n";
   text += "statistics_owner=layer_owner_packet_not_board_calculation\r\n";
   text += "python_worker=not_used_for_L0_L1_L2_or_L3\r\n";
   text += "mt5_script_worker=not_used_for_runtime_board_stats\r\n";
   text += "\r\n" + AC_Layer1WorkbenchSection();
   text += AC_Layer2WorkbenchSection();
   text += AC_Layer3WorkbenchSection();
   return text;
}

string AC_Layer0FailureAddendumText()
{
   string text = "";
   text += "L0_L2_L3_FAILED_SYMBOL_PACKET_ADDENDUM\r\n";
   text += "----------------------------------------\r\n";
   if(AC_L0_FAILURE_ADDENDUM == "")
      text += "none\r\n";
   else
      text += AC_L0_FAILURE_ADDENDUM;
   return text;
}

#endif