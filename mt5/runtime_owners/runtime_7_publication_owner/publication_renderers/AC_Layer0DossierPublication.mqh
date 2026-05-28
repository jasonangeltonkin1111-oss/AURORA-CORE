#ifndef AC_LAYER0_DOSSIER_PUBLICATION_MQH
#define AC_LAYER0_DOSSIER_PUBLICATION_MQH
static string AC_L0_FIRST_FAILURE = "";
static string AC_L0_FAILURE_ADDENDUM = "";
static string AC_DOSSIER_RENDER_LAYOUT_KEY = "dossier_topview_v4_symbol_surface_overview_l18_l19_truth";
static int    AC_L0_CACHED_SYMBOLS_TOTAL = -1;
static string AC_L0_CACHED_DOSSIER_SCHEMA_VERSION = "";
static string AC_L0_CACHED_DOSSIER_RENDER_LAYOUT_KEY = "";
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
static string AC_L0_CACHED_L9_STATUS = "";
static string AC_L0_CACHED_L9_GEOMETRY_QUALITY = "";
static string AC_L0_CACHED_L9_INPUT_CHECKSUM = "";
static string AC_L0_CACHED_L9_RANKED_CHECKSUM = "";
static int    AC_L0_CACHED_L9_RANKED_ROWS = -1;
static int    AC_L0_CACHED_L9_OHLC_REQUIRED_READY = -1;
static bool   AC_L0_CACHED_L9_ACCEPTED = false;
static string AC_L0_CACHED_L10_STATUS = "";
static string AC_L0_CACHED_L10_SUMMARY_CHECK_KEY = "";
static int    AC_L0_CACHED_L10_SYMBOL_COUNT = -1;
static int    AC_L0_CACHED_L10_RANKING_GROUP_COUNT = -1;
static bool   AC_L0_CACHED_L10_ACCEPTED = false;
static string AC_L0_CACHED_L11_STATUS = "";
static int    AC_L0_CACHED_L11_RANKED_SYMBOL_COUNT = -1;
static int    AC_L0_CACHED_L11_TOP5_GROUP_COUNT = -1;
static string AC_L0_CACHED_L11_GENERATED_UTC = "";
static bool   AC_L0_CACHED_L11_ACCEPTED = false;
static string AC_L0_CACHED_L12_STATUS = "";
static int    AC_L0_CACHED_L12_GROUP_COUNT = -1;
static string AC_L0_CACHED_L12_GENERATED_UTC = "";
static bool   AC_L0_CACHED_L12_ACCEPTED = false;
static string AC_L0_CACHED_L13_STATUS = "";
static int    AC_L0_CACHED_L13_SELECTED_GROUP_COUNT = -1;
static string AC_L0_CACHED_L13_GENERATED_UTC = "";
static bool   AC_L0_CACHED_L13_ACCEPTED = false;
static string AC_L0_CACHED_L14_STATUS = "";
static int    AC_L0_CACHED_L14_CANDIDATE_POOL_SIZE = -1;
static string AC_L0_CACHED_L14_GENERATED_UTC = "";
static bool   AC_L0_CACHED_L14_ACCEPTED = false;
static string AC_L0_CACHED_L15_STATUS = "";
static int    AC_L0_CACHED_L15_CANDIDATE_SCORED_COUNT = -1;
static int    AC_L0_CACHED_L15_HIGH_CORR_PAIR_COUNT = -1;
static string AC_L0_CACHED_L15_GENERATED_UTC = "";
static bool   AC_L0_CACHED_L15_ACCEPTED = false;
static string AC_L18_STATUS = "pending";
static string AC_L18_REASON = "l18 status surface not read";
static string AC_L18_FRESHNESS_STATUS = "unknown";
static string AC_L18_GENERATED_UTC = "not_available";
static int    AC_L18_SOURCE_FILES_EXPECTED = 0;
static int    AC_L18_SOURCE_FILES_FOUND = 0;
static int    AC_L18_SOURCE_FILES_MISSING = 0;
static int    AC_L18_SOURCE_FILES_PARTIAL = 0;
static int    AC_L18_SELECTED_UNIQUE_SYMBOLS = 0;
static int    AC_L18_SELECTED_DUPLICATE_ROUTE_COPIES = 0;
static int    AC_L18_FRESHNESS_STALE_COUNT = 0;
static int    AC_L18_FRESHNESS_UNKNOWN_COUNT = 0;
static string AC_L19_STATUS = "pending";
static string AC_L19_REASON = "l19 status surface not read";
static string AC_L19_FRESHNESS_STATUS = "unknown";
static string AC_L19_GENERATED_UTC = "not_available";
static int    AC_L19_SOURCE_FILES_EXPECTED = 0;
static int    AC_L19_SOURCE_FILES_FOUND = 0;
static int    AC_L19_SOURCE_FILES_MISSING = 0;
static int    AC_L19_SOURCE_FILES_PARTIAL = 0;
static int    AC_L19_SELECTED_UNIQUE_SYMBOLS = 0;
static int    AC_L19_SELECTED_DUPLICATE_ROUTE_COPIES = 0;
static int    AC_L19_VALID_GEOMETRY_ROWS = 0;
static int    AC_L19_FRESHNESS_STALE_COUNT = 0;
static int    AC_L19_FRESHNESS_UNKNOWN_COUNT = 0;
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

string AC_L0DossierRouteStateForSymbol(const string symbol)
{
   string market_state = AC_L2MarketStateForSymbol(symbol);
   if(market_state == "open" || market_state == "closed")
      return market_state;
   return "unknown";
}

string AC_L18StatusPath(){ return AC_ExternalWorkerOutboxFolder() + "\\Layers\\Layer_18_Selected_Raw_OHLC_Bar_Pack\\l18_status.txt"; }
string AC_L19StatusPath(){ return AC_ExternalWorkerOutboxFolder() + "\\Layers\\Layer_19_Wick_Candle_Geometry_Pack\\l19_status.txt"; }

string AC_SurfaceStateFromStatus(const string status)
{
   string s = status;
   StringToLower(s);
   if(StringFind(s, "history_limited") >= 0) return "PARTIAL";
   if(StringFind(s, "accepted") >= 0 || StringFind(s, "complete") >= 0) return "ACCEPTED";
   if(StringFind(s, "partial") >= 0) return "PARTIAL";
   if(StringFind(s, "degraded") >= 0 || StringFind(s, "stale") >= 0 || StringFind(s, "expired") >= 0) return "DEGRADED";
   if(StringFind(s, "seed") >= 0) return "SEEDING";
   if(StringFind(s, "pending") >= 0) return "PENDING";
   if(StringFind(s, "blocked") >= 0) return "BLOCKED";
   if(StringFind(s, "review") >= 0) return "REVIEW";
   return "UNKNOWN";
}

string AC_DossierOverviewRow(const string surface,
                             const string state,
                             const string evidence,
                             const string blocker,
                             const string meaning)
{
   return surface + " | " + state + " | " + evidence + " | " + blocker + " | " + meaning + "\r\n";
}

void AC_L18RefreshStatus()
{
   string text = AC_L16ReadSmallTextFile(AC_L18StatusPath(), 30000);
   if(text == "")
   {
      AC_L18_STATUS = "pending";
      AC_L18_REASON = "l18_status_missing_or_unreadable";
      AC_L18_FRESHNESS_STATUS = "unknown";
      AC_L18_GENERATED_UTC = "not_available";
      AC_L18_SOURCE_FILES_EXPECTED = 0;
      AC_L18_SOURCE_FILES_FOUND = 0;
      AC_L18_SOURCE_FILES_MISSING = 0;
      AC_L18_SOURCE_FILES_PARTIAL = 0;
      AC_L18_SELECTED_UNIQUE_SYMBOLS = 0;
      AC_L18_SELECTED_DUPLICATE_ROUTE_COPIES = 0;
      AC_L18_FRESHNESS_STALE_COUNT = 0;
      AC_L18_FRESHNESS_UNKNOWN_COUNT = 0;
      return;
   }
   AC_L18_STATUS = AC_L16KvValue(text, "status", "pending");
   AC_L18_REASON = AC_L16KvValue(text, "reason", "not_available");
   AC_L18_FRESHNESS_STATUS = AC_L16KvValue(text, "freshness_status", "unknown");
   AC_L18_GENERATED_UTC = AC_L16KvValue(text, "generated_utc", "not_available");
   AC_L18_SOURCE_FILES_EXPECTED = AC_L16KvInt(text, "source_files_expected", 0);
   AC_L18_SOURCE_FILES_FOUND = AC_L16KvInt(text, "source_files_found", 0);
   AC_L18_SOURCE_FILES_MISSING = AC_L16KvInt(text, "source_files_missing", 0);
   AC_L18_SOURCE_FILES_PARTIAL = AC_L16KvInt(text, "source_files_partial", 0);
   AC_L18_SELECTED_UNIQUE_SYMBOLS = AC_L16KvInt(text, "selected_unique_symbols_seen", 0);
   AC_L18_SELECTED_DUPLICATE_ROUTE_COPIES = AC_L16KvInt(text, "selected_duplicate_route_copies", 0);
   AC_L18_FRESHNESS_STALE_COUNT = AC_L16KvInt(text, "freshness_stale_count", 0);
   AC_L18_FRESHNESS_UNKNOWN_COUNT = AC_L16KvInt(text, "freshness_unknown_count", 0);
}

void AC_L19RefreshStatus()
{
   string text = AC_L16ReadSmallTextFile(AC_L19StatusPath(), 30000);
   if(text == "")
   {
      AC_L19_STATUS = "pending";
      AC_L19_REASON = "l19_status_missing_or_unreadable";
      AC_L19_FRESHNESS_STATUS = "unknown";
      AC_L19_GENERATED_UTC = "not_available";
      AC_L19_SOURCE_FILES_EXPECTED = 0;
      AC_L19_SOURCE_FILES_FOUND = 0;
      AC_L19_SOURCE_FILES_MISSING = 0;
      AC_L19_SOURCE_FILES_PARTIAL = 0;
      AC_L19_SELECTED_UNIQUE_SYMBOLS = 0;
      AC_L19_SELECTED_DUPLICATE_ROUTE_COPIES = 0;
      AC_L19_VALID_GEOMETRY_ROWS = 0;
      AC_L19_FRESHNESS_STALE_COUNT = 0;
      AC_L19_FRESHNESS_UNKNOWN_COUNT = 0;
      return;
   }
   AC_L19_STATUS = AC_L16KvValue(text, "status", "pending");
   AC_L19_REASON = AC_L16KvValue(text, "reason", "not_available");
   AC_L19_FRESHNESS_STATUS = AC_L16KvValue(text, "freshness_status", "unknown");
   AC_L19_GENERATED_UTC = AC_L16KvValue(text, "generated_utc", "not_available");
   AC_L19_SOURCE_FILES_EXPECTED = AC_L16KvInt(text, "source_files_expected", 0);
   AC_L19_SOURCE_FILES_FOUND = AC_L16KvInt(text, "source_files_found", 0);
   AC_L19_SOURCE_FILES_MISSING = AC_L16KvInt(text, "source_files_missing", 0);
   AC_L19_SOURCE_FILES_PARTIAL = AC_L16KvInt(text, "source_files_partial", 0);
   AC_L19_SELECTED_UNIQUE_SYMBOLS = AC_L16KvInt(text, "selected_unique_symbols_seen", 0);
   AC_L19_SELECTED_DUPLICATE_ROUTE_COPIES = AC_L16KvInt(text, "selected_duplicate_route_copies", 0);
   AC_L19_VALID_GEOMETRY_ROWS = AC_L16KvInt(text, "valid_geometry_rows", 0);
   AC_L19_FRESHNESS_STALE_COUNT = AC_L16KvInt(text, "freshness_stale_count", 0);
   AC_L19_FRESHNESS_UNKNOWN_COUNT = AC_L16KvInt(text, "freshness_unknown_count", 0);
}

void AC_L18L19RefreshStatus()
{
   AC_L18RefreshStatus();
   AC_L19RefreshStatus();
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

string AC_DossierHeaderSection(const string symbol, const string market_state)
{
   string text = "";
   text += "AURORA CORE - SYMBOL DOSSIER\r\n";
   text += "==================================================\r\n";
   text += "Build Version:    " + AC_BUILD_VERSION + "\r\n";
   text += "Heartbeat ID:     " + IntegerToString((int)AC_HEARTBEAT_ID) + "\r\n";
   text += "Generated At:     " + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS) + "\r\n";
   text += "Current Broker Time: " + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS) + "\r\n";
   text += "Symbol:           " + symbol + "\r\n";
   text += "Broker Symbol:    " + symbol + "\r\n";
   text += "Market State:     " + AC_MarketStateTitle(market_state) + "\r\n";
   text += "Dossier Route:    " + AC_DossierSymbolPathByState(symbol, market_state) + "\r\n";
   text += "Server:           " + AC_ServerNameForRoute() + "\r\n";
   text += "Account:          " + AC_AccountForRoute() + "\r\n";
   text += "Trade Permission: FALSE\r\n";
   text += "Auto Trading:     FALSE\r\n";
   return text;
}

string AC_DossierSymbolTopViewSection(const string symbol, const string market_state)
{
   string l14_row = AC_L14CsvLineForSymbol(symbol);
   string l15_row = AC_L15CsvLineForSymbol(symbol);
   string l16_row = AC_L16CsvLineForSymbol(symbol);
   string l17_row = AC_L17CsvLineForSymbol(symbol);
   string l17_rejected_row = AC_L17RejectedCsvLineForSymbol(symbol);
   string pipeline_position = "pre-candidate or not selected";
   if(l17_row != "") pipeline_position = "L17 deep evidence queue selected";
   else if(l16_row != "") pipeline_position = "L16 Global Top 10 visible basket";
   else if(l15_row != "") pipeline_position = "L15 correlation/diversity scored";
   else if(l14_row != "") pipeline_position = "L14 raw candidate pool member";
   string text = "";
   text += "\r\nSYMBOL TOP VIEW\r\n";
   text += "--------------------------------------------------\r\n";
   text += "Symbol:              " + symbol + "\r\n";
   text += "Market State:        " + AC_MarketStateTitle(market_state) + "\r\n";
   text += "Pipeline Position:   " + pipeline_position + "\r\n";
   text += "L14 Candidate:       " + (l14_row != "" ? "TRUE rank #" + AC_L14CsvField(l14_row, 0) + " / " + IntegerToString(AC_L14_CANDIDATE_POOL_SIZE) : "FALSE") + "\r\n";
   text += "L15 Diversity:       " + (l15_row != "" ? "TRUE rank #" + AC_L15CsvField(l15_row, 0) + " / " + IntegerToString(AC_L15_CANDIDATE_POOL_SIZE) : "FALSE") + "\r\n";
   text += "L16 Top 10:          " + (l16_row != "" ? "TRUE rank #" + AC_L16CsvField(l16_row, 0) + " / " + IntegerToString(AC_L16_SELECTED_COUNT) : "FALSE") + "\r\n";
   text += "L17 Deep Evidence:   " + (l17_row != "" ? "TRUE queue #" + AC_L17CsvField(l17_row, 0) + " / " + IntegerToString(AC_L17_DEEP_SELECTED_COUNT) : (l17_rejected_row != "" ? "WATCH_ONLY / rejected queue" : "FALSE")) + "\r\n";
   text += "Surface State:       L6=" + AC_L6_STATUS + " | L7=" + AC_L7_STATUS + " | L8=" + AC_L8_STATUS + " | L9=" + AC_L9_STATUS + " | L9_quality=" + AC_L9_GEOMETRY_QUALITY_STATE + "\r\n";
   text += "Selection State:     L10=" + AC_L10_STATUS + " | L11=" + AC_L11_STATUS + " | L12=" + AC_L12_STATUS + " | L13=" + AC_L13_STATUS + " | L14=" + AC_L14_STATUS + " | L15=" + AC_L15_STATUS + " | L16=" + AC_L16_STATUS + " | L17=" + AC_L17_STATUS + "\r\n";
   text += "Evidence State:      L18=" + AC_L18_STATUS + " | L19=" + AC_L19_STATUS + "\r\n";
   text += "Trade Permission:    FALSE\r\n";
   text += "Entry Signal:        FALSE\r\n";
   text += "Execution:           FALSE\r\n";
   return text;
}

string AC_DossierCurrentnessProofSection(const string symbol,
                                         const string market_state)
{
   string text = "";
   text += "\r\nCURRENTNESS PROOF\r\n";
   text += "--------------------------------------------------\r\n";
   text += "build_version=" + AC_BUILD_VERSION + "\r\n";
   text += "heartbeat_id=" + IntegerToString((int)AC_HEARTBEAT_ID) + "\r\n";
   text += "generated_at=" + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS) + "\r\n";
   text += "current_broker_time=" + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS) + "\r\n";
   text += "dossier_route=" + AC_DossierSymbolPathByState(symbol, market_state) + "\r\n";
   text += "market_state=" + AC_MarketStateTitle(market_state) + "\r\n";
   text += "l5_status=" + AC_L5_STATUS + "\r\n";
   text += "l6_status=" + AC_L6_STATUS + "\r\n";
   text += "l7_status=" + AC_L7_STATUS + "\r\n";
   text += "trade_permission=false\r\n";
   text += "auto_trade_allowed=false\r\n";
   text += "entry_signal=false\r\n";
   text += "execution=false\r\n";
   return text;
}

string AC_DossierSymbolSurfaceOverviewSection(const string symbol, const string market_state)
{
   string l14_row = AC_L14CsvLineForSymbol(symbol);
   string l15_row = AC_L15CsvLineForSymbol(symbol);
   string l16_row = AC_L16CsvLineForSymbol(symbol);
   string l17_row = AC_L17CsvLineForSymbol(symbol);
   string l17_rejected_row = AC_L17RejectedCsvLineForSymbol(symbol);
   bool l16_selected = (l16_row != "");
   bool l17_selected = (l17_row != "");
   bool l17_watch = (l17_rejected_row != "");
   string text = "";
   text += "\r\nSYMBOL SURFACE OVERVIEW\r\n";
   text += "--------------------------------------------------\r\n";
   text += "Surface | State | Evidence | Blocker | Meaning\r\n";
   text += AC_DossierOverviewRow("Physical Dossier Route", "ACCEPTED", AC_DossierSymbolPathByState(symbol, market_state), "physical_route_clean", "route membership only");
   text += AC_DossierOverviewRow("L2 Market State", (market_state == "open" || market_state == "closed") ? "ACCEPTED" : "UNKNOWN", AC_MarketStateTitle(market_state), market_state == "unknown" ? "market_state_unknown" : "none", "closed market is not a Dossier error");
   text += AC_DossierOverviewRow("L5 Gate", AC_SurfaceStateFromStatus(AC_L5_STATUS), AC_L5_STATUS, "see_layer_5_detail", "basic eligibility gate only");
   text += AC_DossierOverviewRow("L6 Cost/Friction", AC_SurfaceStateFromStatus(AC_L6_STATUS), AC_L6_STATUS, AC_L6_RANKED_ACCEPTED ? "none" : "ranked_sidecar_not_current_accepted", "inspection ranking only");
   text += AC_DossierOverviewRow("L7 Session", AC_SurfaceStateFromStatus(AC_L7_STATUS), AC_L7_STATUS, AC_L7_RANKED_ACCEPTED ? "none" : "epoch_or_count_contract_pending", "session relevance only");
   text += AC_DossierOverviewRow("L8 Movement", AC_SurfaceStateFromStatus(AC_L8_STATUS), AC_L8_STATUS, AC_L8_RANKED_ACCEPTED ? "none" : "ohlc_or_epoch_contract_degraded", "movement/range scoring only");
   text += AC_DossierOverviewRow("L9 Structure", AC_SurfaceStateFromStatus(AC_L9_STATUS), AC_L9_STATUS + " quality=" + AC_L9_GEOMETRY_QUALITY_STATE, AC_L9_RANKED_ACCEPTED ? "none" : "structure_or_ohlc_contract_degraded", "structure/location context only");
   text += AC_DossierOverviewRow("L10 Taxonomy", AC_SurfaceStateFromStatus(AC_L10_STATUS), AC_L10_STATUS, AC_L10_ACCEPTED ? "none" : "taxonomy_summary_pending", "ranking_group lookup only");
   text += AC_DossierOverviewRow("L11 Group Rank", AC_SurfaceStateFromStatus(AC_L11_STATUS), AC_L11_STATUS, AC_L11_ACCEPTED ? "none" : "group_rank_pending", "rank inside group only");
   text += AC_DossierOverviewRow("L12 Group Heat", AC_SurfaceStateFromStatus(AC_L12_STATUS), AC_L12_STATUS, AC_L12_ACCEPTED ? "none" : "group_heat_pending", "group heat/quality only");
   text += AC_DossierOverviewRow("L13 Group Selection", AC_SurfaceStateFromStatus(AC_L13_STATUS), AC_L13_STATUS, AC_L13_ACCEPTED ? "none" : "group_selection_pending", "attention group selection only");
   text += AC_DossierOverviewRow("L14 Candidate Pool", AC_SurfaceStateFromStatus(AC_L14_STATUS), (l14_row != "" ? "candidate=true rank #" + AC_L14CsvField(l14_row, 0) : "candidate=false"), l14_row != "" ? "none" : "not_selected", "raw candidate pool only");
   text += AC_DossierOverviewRow("L15 Correlation", AC_SurfaceStateFromStatus(AC_L15_STATUS), (l15_row != "" ? "scored=true rank #" + AC_L15CsvField(l15_row, 0) : "scored=false"), l15_row != "" ? "none" : "not_selected", "correlation/diversity scoring only");
   text += AC_DossierOverviewRow("L16 Global Top 10", l16_selected ? AC_SurfaceStateFromStatus(AC_L16_STATUS) : "NOT_ACTIVE", l16_selected ? "top10_member=true rank #" + AC_L16CsvField(l16_row, 0) : "top10_member=false", l16_selected ? AC_L16_MAIN_BLOCKER : "not_selected", "visible inspection basket only");
   text += AC_DossierOverviewRow("L17 Deep Evidence", l17_selected ? AC_SurfaceStateFromStatus(AC_L17_STATUS) : (l17_watch ? "REVIEW" : "NOT_ACTIVE"), l17_selected ? "queue_selected=true rank #" + AC_L17CsvField(l17_row, 0) : (l17_watch ? "watch_only=true" : "queue_selected=false"), l17_selected ? AC_L17_MAIN_BLOCKER : (l17_watch ? "watch_only_not_degraded" : "not_selected"), "evidence budget split only");
   text += AC_DossierOverviewRow("L18 Raw OHLC", l16_selected ? AC_SurfaceStateFromStatus(AC_L18_STATUS) : "NOT_ACTIVE", "status=" + AC_L18_STATUS + " found=" + IntegerToString(AC_L18_SOURCE_FILES_FOUND) + "/" + IntegerToString(AC_L18_SOURCE_FILES_EXPECTED), l16_selected ? AC_L18_REASON : "not_selected", "selected raw OHLC display only");
   text += AC_DossierOverviewRow("L19 Wick/Candle", l16_selected ? AC_SurfaceStateFromStatus(AC_L19_STATUS) : "NOT_ACTIVE", "status=" + AC_L19_STATUS + " geometry_rows=" + IntegerToString(AC_L19_VALID_GEOMETRY_ROWS), l16_selected ? AC_L19_REASON : "not_selected", "wick/candle geometry only");
   text += AC_DossierOverviewRow("L20 Rolling Tick", "NOT_ACTIVE", "design_hold feed_quality_proxy_future", "not_runtime_active", "future selected-symbol tick/feed quality evidence only");
   text += AC_DossierOverviewRow("L21 Indicator Pack", "NOT_ACTIVE", "design_hold explainable_reference_future", "not_runtime_active", "future ATR/VWAP/Bollinger/Donchian context only");
   text += AC_DossierOverviewRow("L22 Liquidity/DOM Proxy", "NOT_ACTIVE", "design_hold evidence_scaffold_future", "not_runtime_active", "future evidence/POI/liquidity proxy only");
   text += AC_DossierOverviewRow("L23 Setup/Permission", "BLOCKED", "trade_permission=false entry_signal=false execution=false auto_trade_allowed=false alert_allowed=false", "strategy_validation_status=not_validated", "validation scaffold only; no setup, alert, permission, or execution");
   return text;
}

string AC_DossierOperatorMeaningSection(const string symbol, const string market_state)
{
   string text = "";
   text += "\r\nOPERATOR MEANING\r\n";
   text += "--------------------------------------------------\r\n";
   if(market_state == "open")
      text += "This symbol may be inspectable if it passes L5 and appears in ranking/selection outputs.\r\n";
   else
      text += "This symbol is not open; deeper trading inspection is blocked until Layer 2 recheck changes state.\r\n";
   text += "Current files support publication and inspection review only.\r\n";
   text += "No setup alert, no trade permission, and no execution permission exists here.\r\n";
   return text;
}

string AC_DossierScoreCardSection(const string symbol)
{
   string l11_row = AC_L11RankedCsvLineForSymbol(symbol);
   string l14_row = AC_L14CsvLineForSymbol(symbol);
   string l15_row = AC_L15CsvLineForSymbol(symbol);
   string text = "";
   text += "\r\nSCORE CARD\r\n";
   text += "--------------------------------------------------\r\n";
   if(l11_row == "")
   {
      text += "L11 Score Card:        not_available\r\n";
      text += "Reason:                symbol missing from L11 ranked group CSV or L11 unreadable\r\n";
   }
   else
   {
      text += "L6 Cost/Friction:      " + AC_L11CsvField(l11_row, 31) + " state=" + AC_L11CsvField(l11_row, 33) + "\r\n";
      text += "L7 Session Relevance:  " + AC_L11CsvField(l11_row, 34) + " state=" + AC_L11CsvField(l11_row, 36) + "\r\n";
      text += "L8 Movement/Range:     " + AC_L11CsvField(l11_row, 37) + " state=" + AC_L11CsvField(l11_row, 39) + "\r\n";
      text += "L9 Structure/Location: " + AC_L11CsvField(l11_row, 40) + " state=" + AC_L11CsvField(l11_row, 42) + "\r\n";
      text += "L11 Group Score:       " + AC_L11CsvField(l11_row, 13) + " state=" + AC_L11CsvField(l11_row, 15) + "\r\n";
   }
   if(l14_row != "")
      text += "L14 Priority Score:    " + AC_L14CsvField(l14_row, 13) + " role=" + AC_L14CsvField(l14_row, 9) + "\r\n";
   else
      text += "L14 Priority Score:    not_available\r\n";
   if(l15_row != "")
   {
      text += "L15 Diversity Score:   " + AC_L15CsvField(l15_row, 23) + " state=" + AC_L15CsvField(l15_row, 24) + "\r\n";
      text += "L15 Corr Max Abs:      " + AC_L15CsvField(l15_row, 16) + "\r\n";
      text += "L16 Constraint Hint:   " + AC_L15CsvField(l15_row, 30) + "\r\n";
   }
   else
      text += "L15 Diversity Score:   not_available\r\n";
   text += "Score Meaning:         inspection_only_not_trade_permission\r\n";
   return text;
}

string AC_DossierPipelinePositionSection(const string symbol, const string market_state)
{
   string text = "";
   text += "\r\nPIPELINE POSITION\r\n";
   text += "--------------------------------------------------\r\n";
   text += "L2 Market State:              " + AC_MarketStateTitle(market_state) + "\r\n";
   text += "L5 Basic Gate:                see L5 detail below\r\n";
   text += "L6-L9 Surface Scoring:        ranking/inspection only\r\n";
   text += "L10 Taxonomy:                 " + AC_L10_STATUS + "\r\n";
   text += "L11 Intra-group Ranking:      " + AC_L11_STATUS + "\r\n";
   text += "L12 Group Heat / Quality:     " + AC_L12_STATUS + "\r\n";
   text += "L13 Group Selection:          " + AC_L13_STATUS + "\r\n";
   text += "L14 Candidate Pool:           " + AC_L14_STATUS + "\r\n";
   text += "L15 Correlation / Diversity:  " + AC_L15_STATUS + "\r\n";
   text += "L16 Global Top 10:            " + AC_L16_STATUS + "\r\n";
   text += "L17 Deep Evidence Split:      " + AC_L17_STATUS + "\r\n";
   text += "L18 Raw OHLC Bar Pack:        " + AC_L18_STATUS + " freshness=" + AC_L18_FRESHNESS_STATUS + "\r\n";
   text += "L19 Wick / Candle Geometry:   " + AC_L19_STATUS + " freshness=" + AC_L19_FRESHNESS_STATUS + "\r\n";
   text += "L23 Trade Permission:         false\r\n";
   return text;
}

string AC_DossierRiskBlockerCardSection(const string symbol)
{
   string text = "";
   text += "\r\nRISK / BLOCKER CARD\r\n";
   text += "--------------------------------------------------\r\n";
   text += "Permission Result:     FALSE\r\n";
   text += "Entry Signal:          FALSE\r\n";
   text += "Execution:             FALSE\r\n";
   text += "Main Cautions:\r\n";
   text += "  L7: " + AC_L7_STATUS + "\r\n";
   text += "  L8: " + AC_L8_STATUS + "\r\n";
   text += "  L9: " + AC_L9_STATUS + " | quality=" + AC_L9_GEOMETRY_QUALITY_STATE + "\r\n";
   text += "  L14: " + AC_L14_STATUS + "\r\n";
   text += "  L15: " + AC_L15_STATUS + "\r\n";
   text += "Safety Meaning:        publication/inspection may continue; trading remains blocked\r\n";
   return text;
}

string AC_DossierCurrentLimitsSection(const string symbol, const string market_state)
{
   string text = "";
   text += "\r\nCURRENT LIMITS\r\n";
   text += "--------------------------------------------------\r\n";
   text += "Broker Symbol Exists: Yes\r\n";
   text += "Market State Known: " + ((market_state == "open" || market_state == "closed") ? "Yes" : "No") + "\r\n";
   text += "Broker Static Specs: " + (AC_L3_READY ? "Available / Scanned (see Layer 3)" : "Pending Layer 3 scan") + "\r\n";
   text += "Live Quote Truth: " + (market_state == "open" ? (AC_L4_READY ? "Available / Scanned (see Layer 4)" : "Unavailable - Layer 4 not scanned yet") : "Unavailable - market closed or unknown") + "\r\n";
   text += "Surface Ranking: L6=" + AC_L6_STATUS + " | L7=" + AC_L7_STATUS + " | L8=" + AC_L8_STATUS + " | L9=" + AC_L9_STATUS + " | L9_quality=" + AC_L9_GEOMETRY_QUALITY_STATE + "\r\n";
   text += "Selection Ranking: L10=" + AC_L10_STATUS + " | L11=" + AC_L11_STATUS + " | L12=" + AC_L12_STATUS + " | L13=" + AC_L13_STATUS + " | L14=" + AC_L14_STATUS + " | L15=" + AC_L15_STATUS + " | L16=" + AC_L16_STATUS + " | L17=" + AC_L17_STATUS + "\r\n";
   text += "Selected Evidence: L18=" + AC_L18_STATUS + " | L19=" + AC_L19_STATUS + "\r\n";
   text += "Shared OHLC Raw Store: " + AC_SHARED_OHLC_STATUS + "\r\n";
   text += "Selection Active: L16/L17 inspection and evidence-budget surfaces only; no trade permission\r\n";
   text += "Permission Active: No\r\n";
   return text;
}

string AC_DossierFoundationStatusSection(const string symbol, const string market_state)
{
   string text = "";
   text += "\r\nFOUNDATION STATUS\r\n";
   text += "--------------------------------------------------\r\n";
   text += "Layer 0 Publication: Complete\r\n";
   text += "Layer 1 Account and Portfolio: " + (AC_L1_READY ? "Available" : "Pending") + "\r\n";
   text += "Layer 2 Market State: " + (AC_L2_READY ? AC_L2_SCAN_STATUS : "Pending") + "\r\n";
   text += "Layer 3 Broker Specs and Value: " + (AC_L3_READY ? AC_L3_SCAN_STATUS : "Pending") + "\r\n";
   text += "Layer 4 Live Quote and Spread: " + (market_state == "open" ? (AC_L4_READY ? AC_L4_SCAN_STATUS : "Pending") : "Cut off until market reopens") + "\r\n";
   text += "Layer 5 Basic System Gate: " + AC_L5_STATUS + "\r\n";
   text += "Layer 6 Cost / Friction Ranking: " + AC_L6_STATUS + "\r\n";
   text += "Layer 7 Session Relevance Ranking: " + AC_L7_STATUS + "\r\n";
   text += "Layer 8 Movement / Range Ranking: " + AC_L8_STATUS + "\r\n";
   text += "Layer 9 Structure / Location Geometry: " + AC_L9_STATUS + " | quality=" + AC_L9_GEOMETRY_QUALITY_STATE + "\r\n";
   text += "Layer 10 Taxonomy / Ranking Group Map: " + AC_L10_STATUS + "\r\n";
   text += "Layer 11 Symbol Ranking Inside Group: " + AC_L11_STATUS + "\r\n";
   text += "Layer 12 Ranking Group Heat / Quality: " + AC_L12_STATUS + "\r\n";
   text += "Layer 13 Dynamic Group Selection: " + AC_L13_STATUS + "\r\n";
   text += "Layer 14 Candidate Pool: " + AC_L14_STATUS + "\r\n";
   text += "Layer 15 Correlation / Diversity: " + AC_L15_STATUS + "\r\n";
   text += "Layer 16 Global Top 10: " + AC_L16_STATUS + "\r\n";
   text += "Layer 17 Deep Evidence Split: " + AC_L17_STATUS + "\r\n";
   text += "Layer 18 Raw OHLC Bar Pack: " + AC_L18_STATUS + " | freshness=" + AC_L18_FRESHNESS_STATUS + "\r\n";
   text += "Layer 19 Wick / Candle Geometry: " + AC_L19_STATUS + " | freshness=" + AC_L19_FRESHNESS_STATUS + "\r\n";
   text += "Layer 20 Rolling Tick Pack: NOT_ACTIVE design/hold\r\n";
   text += "Layer 21 Indicator / Reference Pack: NOT_ACTIVE design/hold\r\n";
   text += "Layer 22 Liquidity / DOM Proxy: NOT_ACTIVE design/hold\r\n";
   text += "Layer 23 Setup / Permission State: BLOCKED trade_permission=false\r\n";
   text += "Shared OHLC Raw Store: " + AC_SHARED_OHLC_STATUS + "\r\n";
   return text;
}

string AC_DossierNextRequiredSection(const string market_state)
{
   string text = "";
   text += "\r\nNEXT REQUIRED\r\n";
   text += "----------------------------------------\r\n";
   text += (market_state == "open" ? "Next step: inspect L16/L17 selection context, then wait for L18/L19/OHLC evidence to become fresh enough.\r\n" : "Next step: wait for Layer 2 recheck before deeper layers.\r\n");
   text += "Open / Closed owner: Layer 2 only\r\n";
   text += "Layer 6-9 rank only Layer 5 pass symbols; they do not hard-block symbols.\r\n";
   text += "Layer 10 classifies symbols into ranking_groups only; it does not rank, select, copy Dossiers, or permit trades.\r\n";
   text += "Layer 11-19 are inspection/evidence surfaces only; no setup alert or trade permission exists here.\r\n";
   text += "Shared OHLC is raw storage only; future layers must read it instead of calling CopyRates privately.\r\n";
   return text;
}

string AC_DossierNoGoSection()
{
   string text = "";
   text += "\r\nNO GO\r\n";
   text += "----------------------------------------\r\n";
   text += "Tradable: No\r\n";
   text += "Selected For Trade: No\r\n";
   text += "Alert Active: No\r\n";
   text += "Permission: No\r\n";
   text += "Execution: No\r\n";
   return text;
}

string AC_BuildLayer0DossierShellText(const string symbol,
                                      const int broker_index,
                                      const AC_Layer0StatusPacket &status)
{
   string market_state = AC_L0DossierRouteStateForSymbol(symbol);
   string text = "";
   text += AC_DossierHeaderSection(symbol, market_state);
   text += AC_DossierCurrentnessProofSection(symbol, market_state);
   text += AC_DossierSymbolTopViewSection(symbol, market_state);
   text += AC_DossierSymbolSurfaceOverviewSection(symbol, market_state);
   text += AC_DossierOperatorMeaningSection(symbol, market_state);
   text += AC_DossierScoreCardSection(symbol);
   text += AC_DossierPipelinePositionSection(symbol, market_state);
   text += AC_DossierRiskBlockerCardSection(symbol);
   text += AC_DossierCurrentLimitsSection(symbol, market_state);
   text += AC_DossierFoundationStatusSection(symbol, market_state);
   text += "\r\nFULL LAYER DETAIL\r\n";
   text += "==================================================\r\n";
   text += AC_Layer1DossierSection(symbol);
   text += AC_Layer2DossierSection(symbol);
   text += AC_Layer3DossierSection(symbol);
   text += AC_Layer4DossierSection(symbol);
   text += AC_Layer5DossierSection(symbol);
   text += AC_Layer6DossierSection(symbol);
   text += AC_Layer7DossierSection(symbol);
   text += AC_Layer8DossierSection(symbol);
   text += AC_Layer9DossierSection(symbol);
   text += AC_Layer10DossierSection(symbol);
   text += AC_SharedOhlcRenderDossierSection(symbol);
   text += AC_DossierNextRequiredSection(market_state);
   text += AC_DossierNoGoSection();
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

void AC_L0ReconcileDossierRouteMembership(const int total)
{
   if(total <= 0 || !AC_L2_READY) return;
   for(int idx = 0; idx < total; idx++)
   {
      string symbol = SymbolName(idx, false);
      if(symbol == "") continue;
      string market_state = AC_L0DossierRouteStateForSymbol(symbol);
      AC_CleanupOtherDossierRoutes(symbol, market_state, true);
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
   string market_state = AC_L0DossierRouteStateForSymbol(symbol);
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

int AC_L0RouteTruthCount(const string route_state)
{
   if(route_state == "open") return AC_L2_OPEN_COUNT;
   if(route_state == "closed") return AC_L2_CLOSED_COUNT;
   return AC_L2_UNKNOWN_COUNT;
}

bool AC_L0RouteHasCurrentDossier(const int total, const string route_state)
{
   if(total <= 0 || AC_L0RouteTruthCount(route_state) <= 0) return true;
   int common_flag = AC_CommonFlag();
   for(int idx = 0; idx < total; idx++)
   {
      string symbol = SymbolName(idx, false);
      if(symbol == "") continue;
      string market_state = AC_L0DossierRouteStateForSymbol(symbol);
      if(market_state != route_state) continue;
      if(FileIsExist(AC_DossierSymbolPathByState(symbol, market_state), common_flag))
         return true;
   }
   return false;
}

bool AC_L0SeedMissingRouteDossier(const int total,
                                  const string route_state,
                                  const AC_Layer0StatusPacket &status)
{
   if(total <= 0 || !AC_L2_READY || AC_L0RouteTruthCount(route_state) <= 0)
      return true;
   if(AC_L0RouteHasCurrentDossier(total, route_state))
      return true;

   for(int idx = 0; idx < total; idx++)
   {
      string symbol = SymbolName(idx, false);
      if(symbol == "") continue;
      string market_state = AC_L0DossierRouteStateForSymbol(symbol);
      if(market_state != route_state) continue;

      int retries_used = 0;
      string failure_line = "";
      if(AC_WriteLayer0ShellWithRetries(symbol, idx, status, retries_used, failure_line))
         return true;

      if(AC_L0_FIRST_FAILURE == "") AC_L0_FIRST_FAILURE = failure_line;
      AC_L0_FAILURE_ADDENDUM += failure_line + "\r\n";
      return false;
   }
   return false;
}

void AC_L0SeedMissingRouteDossiers(const int total,
                                   const AC_Layer0StatusPacket &status)
{
   AC_L0SeedMissingRouteDossier(total, "closed", status);
   AC_L0SeedMissingRouteDossier(total, "unknown", status);
   AC_L0SeedMissingRouteDossier(total, "open", status);
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

void AC_L0CacheLayer9Proof()
{
   AC_L9RefreshRankedSidecar();
   AC_L0_CACHED_L9_STATUS = AC_L9_STATUS;
   AC_L0_CACHED_L9_GEOMETRY_QUALITY = AC_L9_GEOMETRY_QUALITY_STATE;
   AC_L0_CACHED_L9_INPUT_CHECKSUM = AC_L9_INPUT_PAYLOAD_CHECKSUM_RENDERED;
   AC_L0_CACHED_L9_RANKED_CHECKSUM = AC_L9_RANKED_PAYLOAD_CHECKSUM_RENDERED;
   AC_L0_CACHED_L9_RANKED_ROWS = AC_L9_RANKED_ROWS_RENDERED;
   AC_L0_CACHED_L9_OHLC_REQUIRED_READY = AC_L9_OHLC_REQUIRED_READY_RENDERED;
   AC_L0_CACHED_L9_ACCEPTED = AC_L9_RANKED_ACCEPTED;
}

void AC_L0CacheLayer10Proof()
{
   AC_L10RefreshTaxonomySummary();
   AC_L0_CACHED_L10_STATUS = AC_L10_STATUS;
   AC_L0_CACHED_L10_SUMMARY_CHECK_KEY = AC_L10_SUMMARY_CHECK_KEY;
   AC_L0_CACHED_L10_SYMBOL_COUNT = AC_L10_SYMBOL_COUNT;
   AC_L0_CACHED_L10_RANKING_GROUP_COUNT = AC_L10_RANKING_GROUP_COUNT;
   AC_L0_CACHED_L10_ACCEPTED = AC_L10_ACCEPTED;
}

void AC_L0CacheLayer11Proof()
{
   AC_L11RefreshSummary();
   AC_L0_CACHED_L11_STATUS = AC_L11_STATUS;
   AC_L0_CACHED_L11_RANKED_SYMBOL_COUNT = AC_L11_RANKED_SYMBOL_COUNT;
   AC_L0_CACHED_L11_TOP5_GROUP_COUNT = AC_L11_TOP5_GROUP_COUNT;
   AC_L0_CACHED_L11_GENERATED_UTC = AC_L11_GENERATED_UTC;
   AC_L0_CACHED_L11_ACCEPTED = AC_L11_ACCEPTED;
}

void AC_L0CacheLayer12Proof()
{
   AC_L12RefreshSummary();
   AC_L0_CACHED_L12_STATUS = AC_L12_STATUS;
   AC_L0_CACHED_L12_GROUP_COUNT = AC_L12_GROUP_COUNT;
   AC_L0_CACHED_L12_GENERATED_UTC = AC_L12_GENERATED_UTC;
   AC_L0_CACHED_L12_ACCEPTED = AC_L12_ACCEPTED;
}

void AC_L0CacheLayer13Proof()
{
   AC_L13RefreshSummary();
   AC_L0_CACHED_L13_STATUS = AC_L13_STATUS;
   AC_L0_CACHED_L13_SELECTED_GROUP_COUNT = AC_L13_SELECTED_GROUP_COUNT;
   AC_L0_CACHED_L13_GENERATED_UTC = AC_L13_GENERATED_UTC;
   AC_L0_CACHED_L13_ACCEPTED = AC_L13_ACCEPTED;
}

void AC_L0CacheLayer14Proof()
{
   AC_L14RefreshSummary();
   AC_L0_CACHED_L14_STATUS = AC_L14_STATUS;
   AC_L0_CACHED_L14_CANDIDATE_POOL_SIZE = AC_L14_CANDIDATE_POOL_SIZE;
   AC_L0_CACHED_L14_GENERATED_UTC = AC_L14_GENERATED_UTC;
   AC_L0_CACHED_L14_ACCEPTED = AC_L14_ACCEPTED;
}

void AC_L0CacheLayer15Proof()
{
   AC_L15RefreshSummary();
   AC_L0_CACHED_L15_STATUS = AC_L15_STATUS;
   AC_L0_CACHED_L15_CANDIDATE_SCORED_COUNT = AC_L15_CANDIDATE_SCORED_COUNT;
   AC_L0_CACHED_L15_HIGH_CORR_PAIR_COUNT = AC_L15_HIGH_CORR_PAIR_COUNT;
   AC_L0_CACHED_L15_GENERATED_UTC = AC_L15_GENERATED_UTC;
   AC_L0_CACHED_L15_ACCEPTED = AC_L15_ACCEPTED;
}

void AC_L0RefreshDossierSectionDependencies()
{
   // Dossier shell text renders L2-L17 plus shared OHLC through the publication bridge.
   // Refresh these packets before any symbol file is written so cached proof and physical Dossier content cannot split-brain.
   AC_BuildLayer2Texts();
   AC_BuildLayer3Texts();
   AC_BuildLayer4Texts();
   AC_BuildLayer5Texts();
   AC_RefreshLayer6RankedSidecar();
   AC_L0CacheLayer7Proof();
   AC_L0CacheLayer8Proof();
   AC_L0CacheLayer9Proof();
   AC_L0CacheLayer10Proof();
   AC_L0CacheLayer11Proof();
   AC_L0CacheLayer12Proof();
   AC_L0CacheLayer13Proof();
   AC_L0CacheLayer14Proof();
   AC_L0CacheLayer15Proof();
   AC_L16RefreshSummary();
   AC_L17RefreshSummary();
   AC_L18L19RefreshStatus();
}

string AC_L0DossierSourceKey(const int total)
{
   return "schema=" + AC_DOSSIER_SHELL_SCHEMA_VERSION
      + "|layout=" + AC_DOSSIER_RENDER_LAYOUT_KEY
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
      + "|l9=" + AC_L9_STATUS
      + "|l9_geometry_quality=" + AC_L9_GEOMETRY_QUALITY_STATE
      + "|l9_input=" + AC_L9_INPUT_PAYLOAD_CHECKSUM_RENDERED
      + "|l9_ranked=" + AC_L9_RANKED_PAYLOAD_CHECKSUM_RENDERED
      + "|l9_rows=" + IntegerToString(AC_L9_RANKED_ROWS_RENDERED)
      + "|l9_ohlc_required=" + IntegerToString(AC_L9_OHLC_REQUIRED_READY_RENDERED)
      + "|l9_accepted=" + (AC_L9_RANKED_ACCEPTED ? "true" : "false")
      + "|l10=" + AC_L10_STATUS
      + "|l10_check=" + AC_L10_SUMMARY_CHECK_KEY
      + "|l10_symbols=" + IntegerToString(AC_L10_SYMBOL_COUNT)
      + "|l10_groups=" + IntegerToString(AC_L10_RANKING_GROUP_COUNT)
      + "|l10_accepted=" + (AC_L10_ACCEPTED ? "true" : "false")
      + "|l11=" + AC_L11_STATUS
      + "|l11_ranked=" + IntegerToString(AC_L11_RANKED_SYMBOL_COUNT)
      + "|l11_top5_groups=" + IntegerToString(AC_L11_TOP5_GROUP_COUNT)
      + "|l11_generated=" + AC_L11_GENERATED_UTC
      + "|l11_accepted=" + (AC_L11_ACCEPTED ? "true" : "false")
      + "|l12=" + AC_L12_STATUS
      + "|l12_groups=" + IntegerToString(AC_L12_GROUP_COUNT)
      + "|l12_generated=" + AC_L12_GENERATED_UTC
      + "|l12_accepted=" + (AC_L12_ACCEPTED ? "true" : "false")
      + "|l13=" + AC_L13_STATUS
      + "|l13_selected=" + IntegerToString(AC_L13_SELECTED_GROUP_COUNT)
      + "|l13_generated=" + AC_L13_GENERATED_UTC
      + "|l13_accepted=" + (AC_L13_ACCEPTED ? "true" : "false")
      + "|l14=" + AC_L14_STATUS
      + "|l14_pool=" + IntegerToString(AC_L14_CANDIDATE_POOL_SIZE)
      + "|l14_generated=" + AC_L14_GENERATED_UTC
      + "|l14_accepted=" + (AC_L14_ACCEPTED ? "true" : "false")
      + "|l15=" + AC_L15_STATUS
      + "|l15_scored=" + IntegerToString(AC_L15_CANDIDATE_SCORED_COUNT)
      + "|l15_high_corr=" + IntegerToString(AC_L15_HIGH_CORR_PAIR_COUNT)
      + "|l15_generated=" + AC_L15_GENERATED_UTC
      + "|l15_accepted=" + (AC_L15_ACCEPTED ? "true" : "false")
      + "|l16=" + AC_L16_STATUS
      + "|l16_selected=" + IntegerToString(AC_L16_SELECTED_COUNT)
      + "|l16_top=" + AC_L16_TOP_SYMBOL
      + "|l16_hold=" + AC_L16_HOLD_STATE
      + "|l16_visible=" + AC_L16_VISIBLE_SURFACE_STATE
      + "|l16_generated=" + AC_L16_GENERATED_UTC
      + "|l16_accepted=" + (AC_L16_ACCEPTED ? "true" : "false")
      + "|l17=" + AC_L17_STATUS
      + "|l17_deep=" + IntegerToString(AC_L17_DEEP_SELECTED_COUNT)
      + "|l17_clean=" + IntegerToString(AC_L17_CLEAN_SELECTED_COUNT)
      + "|l17_fallback=" + IntegerToString(AC_L17_FALLBACK_SELECTED_COUNT)
      + "|l17_top=" + AC_L17_TOP_SYMBOL
      + "|l17_generated=" + AC_L17_GENERATED_UTC
      + "|l17_accepted=" + (AC_L17_ACCEPTED ? "true" : "false")
      + "|l18=" + AC_L18_STATUS
      + "|l18_found=" + IntegerToString(AC_L18_SOURCE_FILES_FOUND)
      + "|l18_expected=" + IntegerToString(AC_L18_SOURCE_FILES_EXPECTED)
      + "|l18_missing=" + IntegerToString(AC_L18_SOURCE_FILES_MISSING)
      + "|l18_freshness=" + AC_L18_FRESHNESS_STATUS
      + "|l18_generated=" + AC_L18_GENERATED_UTC
      + "|l19=" + AC_L19_STATUS
      + "|l19_found=" + IntegerToString(AC_L19_SOURCE_FILES_FOUND)
      + "|l19_expected=" + IntegerToString(AC_L19_SOURCE_FILES_EXPECTED)
      + "|l19_geometry=" + IntegerToString(AC_L19_VALID_GEOMETRY_ROWS)
      + "|l19_freshness=" + AC_L19_FRESHNESS_STATUS
      + "|l19_generated=" + AC_L19_GENERATED_UTC
      + "|ohlc=" + AC_SHARED_OHLC_STATUS
      + "|ohlc_mode=" + AC_SHARED_OHLC_MODE
      + "|ohlc_l8_fast=" + IntegerToString(AC_SHARED_OHLC_L8_FAST_READY);
}

string AC_L0DossierProgressKey(const int total)
{
   return "schema=" + AC_DOSSIER_SHELL_SCHEMA_VERSION
      + "|layout=" + AC_DOSSIER_RENDER_LAYOUT_KEY
      + "|total=" + IntegerToString(total)
      + "|l2_route=" + AC_L2_ROUTE_GENERATION_KEY
      + "|l3=" + AC_L3_CACHE_KEY
      + "|l4_universe=" + AC_L4_CACHE_KEY;
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
   string render_key = AC_L0DossierSourceKey(total);
   string progress_key = AC_L0DossierProgressKey(total);
   bool progress_changed = (progress_key != AC_L0_INCREMENTAL_SOURCE_KEY);
   bool had_cached_pass = AC_L0_CACHED_PASS_VALID;
   bool reset_needed = (progress_changed || AC_L0_INCREMENTAL_NEXT_INDEX < 0 || AC_L0_INCREMENTAL_NEXT_INDEX >= total);
   if(reset_needed)
   {
      AC_L0ResetIncrementalPass(progress_key);
      if(progress_changed || !had_cached_pass)
      {
         AC_L0ReconcileDossierRouteMembership(total);
         AC_L0SeedMissingRouteDossiers(total, status);
      }
   }

   int start_index = AC_L0_INCREMENTAL_NEXT_INDEX;
   int end_limit = total;
   status.batch_start_index = start_index;
   status.batch_end_index = start_index - 1;

   bool all_ok = true;
   int attempted = 0;
   int written = 0;
   int failed = 0;
   int retries_total = 0;
   for(int idx = start_index; idx < end_limit; idx++)
   {
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
      status.main_blocker = AC_L6_MAIN_BLOCKER == "none" ? (AC_L7_MAIN_BLOCKER == "none" ? (AC_L8_MAIN_BLOCKER == "none" ? (AC_L9_MAIN_BLOCKER == "none" ? (AC_L10_MAIN_BLOCKER == "none" ? AC_L5_MAIN_BLOCKER : AC_L10_MAIN_BLOCKER) : AC_L9_MAIN_BLOCKER) : AC_L8_MAIN_BLOCKER) : AC_L7_MAIN_BLOCKER) : AC_L6_MAIN_BLOCKER;
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
      status.main_blocker = "Dossier universe pass interrupted before all symbols completed";
   }

   string batch_status = status.batch_complete ? ((AC_L0_INCREMENTAL_FAILED_TOTAL == 0) ? "dossier_universe_complete" : "dossier_universe_complete_with_degraded") : "dossier_universe_partial_interrupted_pass";
   if(status.batch_complete)
   {
      AC_L0_CACHED_SYMBOLS_TOTAL = total;
      AC_L0_CACHED_DOSSIER_SCHEMA_VERSION = AC_DOSSIER_SHELL_SCHEMA_VERSION;
      AC_L0_CACHED_DOSSIER_RENDER_LAYOUT_KEY = AC_DOSSIER_RENDER_LAYOUT_KEY;
      AC_L0_CACHED_L2_ROUTE_GENERATION_KEY = AC_L2_ROUTE_GENERATION_KEY;
      AC_L0_CACHED_L3_CACHE_KEY = AC_L3_CACHE_KEY;
      AC_L0_CACHED_L4_CACHE_KEY = AC_L4_CACHE_KEY;
      AC_L0_CACHED_L4_REFRESH_KEY = AC_L4_REFRESH_KEY;
      AC_L0_CACHED_L5_STATUS = AC_L5_STATUS;
      AC_L0_CACHED_L6_STATUS = AC_L6_STATUS;
      AC_L0_CACHED_L6_CHECKSUM = AC_L6_MANIFEST_PAYLOAD_CHECKSUM;
      AC_L0CacheLayer7Proof();
      AC_L0CacheLayer8Proof();
      AC_L0CacheLayer9Proof();
      AC_L0CacheLayer10Proof();
      AC_L0CacheLayer11Proof();
      AC_L0CacheLayer12Proof();
      AC_L0CacheLayer13Proof();
      AC_L0CacheLayer14Proof();
      AC_L0CacheLayer15Proof();
      AC_L16RefreshSummary();
      AC_L17RefreshSummary();
      AC_L0_CACHED_PASS_VALID = true;
      AC_L0_CACHED_STATUS = status;
      AC_L0_CACHED_RESULT = AC_MakeSyntheticWriteResult(AC_DossiersFolder(), AC_L0_INCREMENTAL_FAILED_TOTAL == 0, batch_status, (ulong)AC_L0_INCREMENTAL_WRITTEN_TOTAL, "unbounded_dossier_universe_pass_complete|progress_key=" + progress_key + "|render_key=" + render_key + "|mode=complete_current_universe_without_artificial_symbol_or_time_budget");
      return AC_L0_CACHED_RESULT;
   }

   AC_L0_CACHED_PASS_VALID = false;
   return AC_MakeSyntheticWriteResult(AC_DossiersFolder(), all_ok, batch_status, (ulong)written, "dossier_universe_pass_partial_only_if_symbol_total_changed_or_interrupted|progress_key=" + progress_key + "|render_key=" + render_key + "|start=" + IntegerToString(start_index) + "|end=" + IntegerToString(status.batch_end_index) + "|next=" + IntegerToString(AC_L0_INCREMENTAL_NEXT_INDEX) + "|mode=no_artificial_symbol_or_time_budget");
}

AC_WriteResult AC_PublishLayer0DossierBatch(AC_Layer0StatusPacket &status)
{
   AC_RefreshLayer6RankedSidecar();
   AC_L7RefreshRankedSidecar();
   AC_L8RefreshRankedSidecar();
   AC_L9RefreshRankedSidecar();
   AC_L10RefreshTaxonomySummary();
   AC_L11RefreshSummary();
   AC_L12RefreshSummary();
   AC_L13RefreshSummary();
   AC_L14RefreshSummary();
   AC_L15RefreshSummary();
   AC_L16RefreshSummary();
   AC_L17RefreshSummary();
   int total = SymbolsTotal(false);
   string current_render_key = AC_L0DossierSourceKey(total);
   string current_progress_key = AC_L0DossierProgressKey(total);
   if(AC_L0_CACHED_PASS_VALID && current_progress_key != AC_L0_INCREMENTAL_SOURCE_KEY)
      AC_L0_CACHED_PASS_VALID = false;

   if(AC_L0_CACHED_PASS_VALID
      && total == AC_L0_CACHED_SYMBOLS_TOTAL
      && AC_L0_CACHED_DOSSIER_SCHEMA_VERSION == AC_DOSSIER_SHELL_SCHEMA_VERSION
      && AC_L0_CACHED_DOSSIER_RENDER_LAYOUT_KEY == AC_DOSSIER_RENDER_LAYOUT_KEY
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
      && AC_L0_CACHED_L8_ACCEPTED == AC_L8_RANKED_ACCEPTED
      && AC_L0_CACHED_L9_STATUS == AC_L9_STATUS
      && AC_L0_CACHED_L9_GEOMETRY_QUALITY == AC_L9_GEOMETRY_QUALITY_STATE
      && AC_L0_CACHED_L9_INPUT_CHECKSUM == AC_L9_INPUT_PAYLOAD_CHECKSUM_RENDERED
      && AC_L0_CACHED_L9_RANKED_CHECKSUM == AC_L9_RANKED_PAYLOAD_CHECKSUM_RENDERED
      && AC_L0_CACHED_L9_RANKED_ROWS == AC_L9_RANKED_ROWS_RENDERED
      && AC_L0_CACHED_L9_OHLC_REQUIRED_READY == AC_L9_OHLC_REQUIRED_READY_RENDERED
      && AC_L0_CACHED_L9_ACCEPTED == AC_L9_RANKED_ACCEPTED
      && AC_L0_CACHED_L10_STATUS == AC_L10_STATUS
      && AC_L0_CACHED_L10_SUMMARY_CHECK_KEY == AC_L10_SUMMARY_CHECK_KEY
      && AC_L0_CACHED_L10_SYMBOL_COUNT == AC_L10_SYMBOL_COUNT
      && AC_L0_CACHED_L10_RANKING_GROUP_COUNT == AC_L10_RANKING_GROUP_COUNT
      && AC_L0_CACHED_L10_ACCEPTED == AC_L10_ACCEPTED
      && AC_L0_CACHED_L11_STATUS == AC_L11_STATUS
      && AC_L0_CACHED_L11_RANKED_SYMBOL_COUNT == AC_L11_RANKED_SYMBOL_COUNT
      && AC_L0_CACHED_L11_TOP5_GROUP_COUNT == AC_L11_TOP5_GROUP_COUNT
      && AC_L0_CACHED_L11_GENERATED_UTC == AC_L11_GENERATED_UTC
      && AC_L0_CACHED_L11_ACCEPTED == AC_L11_ACCEPTED
      && AC_L0_CACHED_L12_STATUS == AC_L12_STATUS
      && AC_L0_CACHED_L12_GROUP_COUNT == AC_L12_GROUP_COUNT
      && AC_L0_CACHED_L12_GENERATED_UTC == AC_L12_GENERATED_UTC
      && AC_L0_CACHED_L12_ACCEPTED == AC_L12_ACCEPTED
      && AC_L0_CACHED_L13_STATUS == AC_L13_STATUS
      && AC_L0_CACHED_L13_SELECTED_GROUP_COUNT == AC_L13_SELECTED_GROUP_COUNT
      && AC_L0_CACHED_L13_GENERATED_UTC == AC_L13_GENERATED_UTC
      && AC_L0_CACHED_L13_ACCEPTED == AC_L13_ACCEPTED
      && AC_L0_CACHED_L14_STATUS == AC_L14_STATUS
      && AC_L0_CACHED_L14_CANDIDATE_POOL_SIZE == AC_L14_CANDIDATE_POOL_SIZE
      && AC_L0_CACHED_L14_GENERATED_UTC == AC_L14_GENERATED_UTC
      && AC_L0_CACHED_L14_ACCEPTED == AC_L14_ACCEPTED
      && AC_L0_CACHED_L15_STATUS == AC_L15_STATUS
      && AC_L0_CACHED_L15_CANDIDATE_SCORED_COUNT == AC_L15_CANDIDATE_SCORED_COUNT
      && AC_L0_CACHED_L15_HIGH_CORR_PAIR_COUNT == AC_L15_HIGH_CORR_PAIR_COUNT
      && AC_L0_CACHED_L15_GENERATED_UTC == AC_L15_GENERATED_UTC
      && AC_L0_CACHED_L15_ACCEPTED == AC_L15_ACCEPTED)
   {
      return AC_RunLayer0UniverseShellPass(status);
   }
   return AC_RunLayer0UniverseShellPass(status);
}

#endif
