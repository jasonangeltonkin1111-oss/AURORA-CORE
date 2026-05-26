#ifndef AC_LAYER17_DEEP_EVIDENCE_RENDERER_MQH
#define AC_LAYER17_DEEP_EVIDENCE_RENDERER_MQH

// Runtime 7 render-only surface for Layer 17 Deep Evidence Queue Split.
// Reads worker L17 summary and CSV outputs only.
// Canonical Selection Desk shortcuts live under 01_Global/Deep_Evidence; legacy Global/* files are not acceptance authority.
// Must not collect OHLC, ticks, indicators, liquidity, permit, alert, or execute.

static string AC_L17_STATUS = "Pending L17 Deep Evidence Queue Split";
static string AC_L17_VALIDATION_STATUS = "Pending";
static string AC_L17_VALIDATION_REASON = "l17_deep_evidence_summary.txt missing or not accepted/degraded";
static string AC_L17_MAIN_BLOCKER = "l17 summary has not been accepted yet";
static bool   AC_L17_ACCEPTED = false;
static int    AC_L17_VISIBLE_CANDIDATE_COUNT = 0;
static int    AC_L17_DEEP_SELECTED_COUNT = 0;
static int    AC_L17_REJECTED_CANDIDATE_COUNT = 0;
static int    AC_L17_CLEAN_SELECTED_COUNT = 0;
static int    AC_L17_FALLBACK_SELECTED_COUNT = 0;
static int    AC_L17_FULL_DEPTH_COUNT = 0;
static int    AC_L17_STANDARD_DEPTH_COUNT = 0;
static int    AC_L17_FALLBACK_LIMITED_DEPTH_COUNT = 0;
static int    AC_L17_WATCH_ONLY_COUNT = 0;
static int    AC_L17_ALERT_ELIGIBLE_CANDIDATE_COUNT = 0;
static int    AC_L17_WRITE_FAILED_COUNT = 0;
static string AC_L17_TOP_SYMBOL = "not_available";
static string AC_L17_SOURCE_L16_STATUS = "not_available";
static string AC_L17_SOURCE_L16_HOLD_STATE = "not_available";
static string AC_L17_SOURCE_L16_VISIBLE_SURFACE_STATE = "not_available";
static string AC_L17_GENERATED_UTC = "not_available";

string AC_L17LayerFolder(){ return AC_ExternalWorkerOutboxFolder() + "\\Layers\\Layer_17_Deep_Evidence_Selection_Split"; }
string AC_L17SummaryPath(){ return AC_L17LayerFolder() + "\\l17_deep_evidence_summary.txt"; }
string AC_L17SelectedCsvPath(){ return AC_L17LayerFolder() + "\\l17_deep_evidence_selected.csv"; }
string AC_L17RejectedCsvPath(){ return AC_L17LayerFolder() + "\\l17_deep_evidence_rejected.csv"; }
string AC_L17DepthSummaryCsvPath(){ return AC_L17LayerFolder() + "\\l17_depth_assignment_summary.csv"; }
string AC_L17ManifestPath(){ return AC_L17LayerFolder() + "\\l17_deep_evidence.manifest"; }
string AC_L17SelectionDeskPath(){ return AC_SelectionGlobalDeepEvidenceFolder() + "\\00_Deep_Evidence_Split.txt"; }
string AC_L17SelectionDeskCsvPath(){ return AC_SelectionGlobalDeepEvidenceFolder() + "\\00_Deep_Evidence_Split.csv"; }
string AC_L17SelectionDeskManifestPath(){ return AC_SelectionGlobalDeepEvidenceFolder() + "\\00_Deep_Evidence_Split_Manifest.txt"; }

string AC_L17ReadSmallTextFile(const string path, const int max_chars = 50000)
{
   int common_flag = AC_USE_COMMON_FILES ? FILE_COMMON : 0;
   if(!FileIsExist(path, common_flag)) return "";
   ResetLastError();
   int handle = FileOpen(path, AC_FileFlags() | FILE_READ);
   if(handle == INVALID_HANDLE) return "";
   string text = "";
   while(!FileIsEnding(handle) && StringLen(text) < max_chars)
   {
      string line = FileReadString(handle);
      text += line;
      if(!FileIsEnding(handle)) text += "\n";
   }
   FileClose(handle);
   if(StringLen(text) > max_chars) text = StringSubstr(text, 0, max_chars);
   return text;
}

string AC_L17KvValue(const string text, const string key, const string fallback = "not_available")
{
   string lines[];
   ushort separator = StringGetCharacter("\n", 0);
   int count = StringSplit(text, separator, lines);
   string prefix = key + "=";
   for(int i = 0; i < count; i++)
   {
      string line = lines[i];
      StringReplace(line, "\r", "");
      StringTrimLeft(line);
      StringTrimRight(line);
      if(StringFind(line, prefix) == 0)
      {
         string value = StringSubstr(line, StringLen(prefix));
         StringTrimLeft(value);
         StringTrimRight(value);
         return value == "" ? fallback : value;
      }
   }
   return fallback;
}

int AC_L17KvInt(const string text, const string key, const int fallback = 0)
{
   string value = AC_L17KvValue(text, key, "");
   if(value == "") return fallback;
   return (int)StringToInteger(value);
}

void AC_L17RefreshSummary()
{
   AC_L17_ACCEPTED = false;
   AC_L17_STATUS = "Pending L17 Deep Evidence Queue Split";
   AC_L17_VALIDATION_STATUS = "Pending";
   AC_L17_VALIDATION_REASON = "l17_deep_evidence_summary.txt missing or unreadable";
   AC_L17_MAIN_BLOCKER = AC_L17_VALIDATION_REASON;
   AC_L17_VISIBLE_CANDIDATE_COUNT = 0;
   AC_L17_DEEP_SELECTED_COUNT = 0;
   AC_L17_REJECTED_CANDIDATE_COUNT = 0;
   AC_L17_CLEAN_SELECTED_COUNT = 0;
   AC_L17_FALLBACK_SELECTED_COUNT = 0;
   AC_L17_FULL_DEPTH_COUNT = 0;
   AC_L17_STANDARD_DEPTH_COUNT = 0;
   AC_L17_FALLBACK_LIMITED_DEPTH_COUNT = 0;
   AC_L17_WATCH_ONLY_COUNT = 0;
   AC_L17_ALERT_ELIGIBLE_CANDIDATE_COUNT = 0;
   AC_L17_WRITE_FAILED_COUNT = 0;
   AC_L17_TOP_SYMBOL = "not_available";
   AC_L17_SOURCE_L16_STATUS = "not_available";
   AC_L17_SOURCE_L16_HOLD_STATE = "not_available";
   AC_L17_SOURCE_L16_VISIBLE_SURFACE_STATE = "not_available";
   AC_L17_GENERATED_UTC = "not_available";

   string summary = AC_L17ReadSmallTextFile(AC_L17SummaryPath(), 50000);
   if(summary == "") return;

   string status = AC_L17KvValue(summary, "status", "pending");
   string deep_evidence_runtime = AC_L17KvValue(summary, "deep_evidence_runtime", "not_available");
   string trade_permission = AC_L17KvValue(summary, "trade_permission", "not_available");
   string entry_signal = AC_L17KvValue(summary, "entry_signal", "not_available");
   string execution = AC_L17KvValue(summary, "execution", "not_available");
   string collects_ohlc = AC_L17KvValue(summary, "collects_ohlc", "not_available");
   string collects_ticks = AC_L17KvValue(summary, "collects_ticks", "not_available");
   string collects_indicators = AC_L17KvValue(summary, "collects_indicators", "not_available");
   string collects_liquidity = AC_L17KvValue(summary, "collects_liquidity", "not_available");
   string all_symbol_scan = AC_L17KvValue(summary, "all_symbol_scan", "not_available");
   AC_L17_VISIBLE_CANDIDATE_COUNT = AC_L17KvInt(summary, "visible_candidate_count", 0);
   AC_L17_DEEP_SELECTED_COUNT = AC_L17KvInt(summary, "deep_selected_count", 0);
   AC_L17_REJECTED_CANDIDATE_COUNT = AC_L17KvInt(summary, "rejected_candidate_count", 0);
   AC_L17_CLEAN_SELECTED_COUNT = AC_L17KvInt(summary, "clean_selected_count", 0);
   AC_L17_FALLBACK_SELECTED_COUNT = AC_L17KvInt(summary, "fallback_selected_count", 0);
   AC_L17_FULL_DEPTH_COUNT = AC_L17KvInt(summary, "full_depth_count", 0);
   AC_L17_STANDARD_DEPTH_COUNT = AC_L17KvInt(summary, "standard_depth_count", 0);
   AC_L17_FALLBACK_LIMITED_DEPTH_COUNT = AC_L17KvInt(summary, "fallback_limited_depth_count", 0);
   AC_L17_WATCH_ONLY_COUNT = AC_L17KvInt(summary, "watch_only_count", 0);
   AC_L17_ALERT_ELIGIBLE_CANDIDATE_COUNT = AC_L17KvInt(summary, "alert_eligible_candidate_count", 0);
   AC_L17_WRITE_FAILED_COUNT = AC_L17KvInt(summary, "write_failed_count", 0);
   AC_L17_TOP_SYMBOL = AC_L17KvValue(summary, "top_symbol", "not_available");
   AC_L17_SOURCE_L16_STATUS = AC_L17KvValue(summary, "source_l16_status", "not_available");
   AC_L17_SOURCE_L16_HOLD_STATE = AC_L17KvValue(summary, "source_l16_hold_state", "not_available");
   AC_L17_SOURCE_L16_VISIBLE_SURFACE_STATE = AC_L17KvValue(summary, "source_l16_visible_surface_state", "not_available");
   AC_L17_GENERATED_UTC = AC_L17KvValue(summary, "generated_utc", "not_available");

   bool core_files_ok = FileIsExist(AC_L17SelectedCsvPath(), AC_CommonFlag())
      && FileIsExist(AC_L17RejectedCsvPath(), AC_CommonFlag())
      && FileIsExist(AC_L17DepthSummaryCsvPath(), AC_CommonFlag())
      && FileIsExist(AC_L17ManifestPath(), AC_CommonFlag());
   bool canonical_surface_seen = FileIsExist(AC_L17SelectionDeskPath(), AC_CommonFlag())
      && FileIsExist(AC_L17SelectionDeskCsvPath(), AC_CommonFlag());
   bool safety_ok = (deep_evidence_runtime == "false" && trade_permission == "false" && entry_signal == "false" && execution == "false");
   bool scope_ok = (collects_ohlc == "false" && collects_ticks == "false" && collects_indicators == "false" && collects_liquidity == "false" && all_symbol_scan == "false");
   bool counts_ok = (AC_L17_VISIBLE_CANDIDATE_COUNT > 0 && AC_L17_DEEP_SELECTED_COUNT >= 0 && AC_L17_DEEP_SELECTED_COUNT <= 5);
   bool status_ok = (status == "accepted" || status == "degraded" || status == "write_degraded");

   if(status_ok && core_files_ok && safety_ok && scope_ok && counts_ok)
   {
      AC_L17_ACCEPTED = true;
      AC_L17_STATUS = (status == "accepted" ? "Accepted" : "Degraded Accepted");
      AC_L17_VALIDATION_STATUS = (status == "accepted" ? "Accepted" : "Degraded");
      AC_L17_VALIDATION_REASON = "summary/core_files/counts/safety/scope accepted; canonical_surface_seen=" + (canonical_surface_seen ? "true" : "false") + ";status=" + status;
      AC_L17_MAIN_BLOCKER = (status == "accepted" ? "none" : "Deep evidence queue split constrained; inspect selected/rejected rows");
      return;
   }

   AC_L17_STATUS = "L17 Deep Evidence Queue Split degraded";
   AC_L17_VALIDATION_STATUS = "Degraded";
   AC_L17_VALIDATION_REASON = "status=" + status
      + ";core_files_ok=" + (core_files_ok ? "true" : "false")
      + ";canonical_surface_seen=" + (canonical_surface_seen ? "true" : "false")
      + ";counts_ok=" + (counts_ok ? "true" : "false")
      + ";safety_ok=" + (safety_ok ? "true" : "false")
      + ";scope_ok=" + (scope_ok ? "true" : "false");
   AC_L17_MAIN_BLOCKER = AC_L17_VALIDATION_REASON;
}

string AC_L17CsvField(string line, int index, string fallback = "not_available")
{
   string cols[];
   ushort sep = StringGetCharacter(",", 0);
   int count = StringSplit(line, sep, cols);
   if(index < 0 || index >= count) return fallback;
   string value = cols[index];
   StringTrimLeft(value);
   StringTrimRight(value);
   StringReplace(value, "\"", "");
   return value == "" ? fallback : value;
}

string AC_L17CsvLineForSymbol(const string symbol)
{
   string csv = AC_L17ReadSmallTextFile(AC_L17SelectedCsvPath(), 1000000);
   if(csv == "") return "";
   string lines[];
   ushort separator = StringGetCharacter("\n", 0);
   int count = StringSplit(csv, separator, lines);
   for(int i = 1; i < count; i++)
   {
      string line = lines[i];
      StringReplace(line, "\r", "");
      if(AC_L17CsvField(line, 1, "") == symbol) return line;
   }
   return "";
}

string AC_L17RejectedCsvLineForSymbol(const string symbol)
{
   string csv = AC_L17ReadSmallTextFile(AC_L17RejectedCsvPath(), 1000000);
   if(csv == "") return "";
   string lines[];
   ushort separator = StringGetCharacter("\n", 0);
   int count = StringSplit(csv, separator, lines);
   for(int i = 1; i < count; i++)
   {
      string line = lines[i];
      StringReplace(line, "\r", "");
      if(AC_L17CsvField(line, 1, "") == symbol) return line;
   }
   return "";
}

string AC_Layer17BoardSection()
{
   AC_L17RefreshSummary();
   string text = "";
   text += "\r\nLAYER 17 - DEEP EVIDENCE QUEUE SPLIT\r\n";
   text += "----------------------------------------\r\n";
   text += "Status:                     " + AC_L17_STATUS + "\r\n";
   text += "Visible Candidates:         " + IntegerToString(AC_L17_VISIBLE_CANDIDATE_COUNT) + "\r\n";
   text += "Queue Selected:             " + IntegerToString(AC_L17_DEEP_SELECTED_COUNT) + " / 5\r\n";
   text += "Clean / Fallback Selected:  " + IntegerToString(AC_L17_CLEAN_SELECTED_COUNT) + " / " + IntegerToString(AC_L17_FALLBACK_SELECTED_COUNT) + "\r\n";
   text += "Top Queued Symbol:          " + AC_L17_TOP_SYMBOL + "\r\n";
   text += "Source Generated UTC:       " + AC_L17_GENERATED_UTC + "\r\n";
   text += "Main Blocker:               " + AC_L17_MAIN_BLOCKER + "\r\n";
   text += "Trade Permission:           FALSE\r\n";
   text += "Entry Signal:               FALSE\r\n";
   text += "Execution:                  FALSE\r\n";
   return text;
}

string AC_Layer17DossierSection(const string symbol)
{
   AC_L17RefreshSummary();
   string row = AC_L17CsvLineForSymbol(symbol);
   string rejected_row = AC_L17RejectedCsvLineForSymbol(symbol);
   string text = "";
   text += "\r\nLAYER 17 - DEEP EVIDENCE QUEUE SPLIT\r\n";
   text += "----------------------------------------\r\n";
   text += "Status: " + AC_L17_STATUS + "\r\n";
   text += "Source L16 Hold State: " + AC_L17_SOURCE_L16_HOLD_STATE + "\r\n";
   if(row == "" && rejected_row == "")
   {
      text += "Queue Selected: FALSE\r\n";
      text += "Visible / Watch Only: UNKNOWN\r\n";
      text += "Reason: symbol not present in current L17 selected/rejected split, or L17 not readable yet\r\n";
   }
   else if(row == "")
   {
      text += "Queue Selected: FALSE\r\n";
      text += "Visible / Watch Only: TRUE\r\n";
      text += "Reject / Watch Reason: " + AC_L17CsvField(rejected_row, 8) + "\r\n";
   }
   else
   {
      text += "Queue Selected: TRUE\r\n";
      text += "Queue Rank: #" + AC_L17CsvField(row, 0) + " / " + IntegerToString(AC_L17_DEEP_SELECTED_COUNT) + "\r\n";
      text += "Source L16 Tier: " + AC_L17CsvField(row, 5) + "\r\n";
      text += "Ranking Group: " + AC_L17CsvField(row, 12) + "\r\n";
      text += "Depth Assignment: " + AC_L17CsvField(row, 24) + "\r\n";
      text += "Selection Reason: " + AC_L17CsvField(row, 30) + "\r\n";
   }
   text += "Meaning: queue split only; not evidence collection or permission\r\n";
   return text;
}

string AC_Layer17WorkbenchSection()
{
   AC_L17RefreshSummary();
   string text = "";
   text += "\r\nL17_DEEP_EVIDENCE_QUEUE_SPLIT\r\n";
   text += "----------------------------------------\r\n";
   text += "schema_name=l17_deep_evidence_queue_split\r\n";
   text += "schema_version=3\r\n";
   text += "status=" + AC_L17_STATUS + "\r\n";
   text += "validation_status=" + AC_L17_VALIDATION_STATUS + "\r\n";
   text += "validation_reason=" + AC_L17_VALIDATION_REASON + "\r\n";
   text += "source_l16_status=" + AC_L17_SOURCE_L16_STATUS + "\r\n";
   text += "visible_candidate_count=" + IntegerToString(AC_L17_VISIBLE_CANDIDATE_COUNT) + "\r\n";
   text += "deep_selected_count=" + IntegerToString(AC_L17_DEEP_SELECTED_COUNT) + "\r\n";
   text += "fallback_selected_count=" + IntegerToString(AC_L17_FALLBACK_SELECTED_COUNT) + "\r\n";
   text += "top_symbol=" + AC_L17_TOP_SYMBOL + "\r\n";
   text += "generated_utc=" + AC_L17_GENERATED_UTC + "\r\n";
   text += "selected_csv_path=" + AC_L17SelectedCsvPath() + "\r\n";
   text += "canonical_selection_desk_path=" + AC_L17SelectionDeskPath() + "\r\n";
   text += "collects_ohlc=false\r\n";
   text += "collects_ticks=false\r\n";
   text += "collects_indicators=false\r\n";
   text += "collects_liquidity=false\r\n";
   text += "all_symbol_scan=false\r\n";
   text += "deep_evidence_runtime=false\r\n";
   text += "trade_permission=false\r\n";
   text += "entry_signal=false\r\n";
   text += "execution=false\r\n";
   return text;
}

#endif
