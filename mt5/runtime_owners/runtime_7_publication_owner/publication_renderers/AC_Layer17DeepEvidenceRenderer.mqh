#ifndef AC_LAYER17_DEEP_EVIDENCE_RENDERER_MQH
#define AC_LAYER17_DEEP_EVIDENCE_RENDERER_MQH

// Runtime 7 render-only surface for Layer 17 Deep Evidence Selection Split.
// Reads worker L17 summary and CSV outputs only.
// Must not collect OHLC, ticks, indicators, liquidity, permit, alert, or execute.

static string AC_L17_STATUS = "Pending L17 Deep Evidence Split";
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
string AC_L17SelectionDeskPath(){ return AC_SelectionGlobalFolder() + "\\Deep Evidence Split.txt"; }
string AC_L17SelectionDeskCsvPath(){ return AC_SelectionGlobalFolder() + "\\current_deep_evidence_split.csv"; }
string AC_L17SelectionDeskManifestPath(){ return AC_SelectionGlobalFolder() + "\\current_deep_evidence_split_manifest.txt"; }

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
   AC_L17_STATUS = "Pending L17 Deep Evidence Split";
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

   bool files_ok = FileIsExist(AC_L17SelectedCsvPath(), AC_CommonFlag())
      && FileIsExist(AC_L17RejectedCsvPath(), AC_CommonFlag())
      && FileIsExist(AC_L17DepthSummaryCsvPath(), AC_CommonFlag())
      && FileIsExist(AC_L17ManifestPath(), AC_CommonFlag())
      && FileIsExist(AC_L17SelectionDeskPath(), AC_CommonFlag())
      && FileIsExist(AC_L17SelectionDeskCsvPath(), AC_CommonFlag())
      && FileIsExist(AC_L17SelectionDeskManifestPath(), AC_CommonFlag());
   bool safety_ok = (deep_evidence_runtime == "false" && trade_permission == "false" && entry_signal == "false" && execution == "false");
   bool scope_ok = (collects_ohlc == "false" && collects_ticks == "false" && collects_indicators == "false" && collects_liquidity == "false" && all_symbol_scan == "false");
   bool counts_ok = (AC_L17_VISIBLE_CANDIDATE_COUNT > 0 && AC_L17_DEEP_SELECTED_COUNT >= 0 && AC_L17_DEEP_SELECTED_COUNT <= 5);
   bool writes_ok = (AC_L17_WRITE_FAILED_COUNT == 0);
   bool status_ok = (status == "accepted" || status == "degraded" || status == "write_degraded");

   if(status_ok && files_ok && safety_ok && scope_ok && counts_ok && writes_ok)
   {
      AC_L17_ACCEPTED = true;
      AC_L17_STATUS = (status == "accepted" ? "Accepted" : "Degraded Accepted");
      AC_L17_VALIDATION_STATUS = (status == "accepted" ? "Accepted" : "Degraded");
      AC_L17_VALIDATION_REASON = "summary/files/counts/safety/scope accepted; status=" + status;
      AC_L17_MAIN_BLOCKER = (status == "accepted" ? "none" : "Deep evidence split constrained; inspect selected/rejected rows");
      return;
   }

   AC_L17_STATUS = "L17 Deep Evidence Split degraded";
   AC_L17_VALIDATION_STATUS = "Degraded";
   AC_L17_VALIDATION_REASON = "status=" + status
      + ";files_ok=" + (files_ok ? "true" : "false")
      + ";counts_ok=" + (counts_ok ? "true" : "false")
      + ";safety_ok=" + (safety_ok ? "true" : "false")
      + ";scope_ok=" + (scope_ok ? "true" : "false")
      + ";writes_ok=" + (writes_ok ? "true" : "false");
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

string AC_Layer17BoardSection()
{
   AC_L17RefreshSummary();
   string text = "";
   text += "\r\nLAYER 17 - DEEP EVIDENCE SELECTION SPLIT\r\n";
   text += "----------------------------------------\r\n";
   text += "Status:                     " + AC_L17_STATUS + "\r\n";
   text += "Owner:                      Runtime 4 - Surface Scoring / Deep Evidence Selection Support\r\n";
   text += "Input Source:               L16 held visible display rows only\r\n";
   text += "Source L16 Status:          " + AC_L17_SOURCE_L16_STATUS + "\r\n";
   text += "Source L16 Hold State:      " + AC_L17_SOURCE_L16_HOLD_STATE + "\r\n";
   text += "Visible Candidates:         " + IntegerToString(AC_L17_VISIBLE_CANDIDATE_COUNT) + "\r\n";
   text += "Deep Selected:              " + IntegerToString(AC_L17_DEEP_SELECTED_COUNT) + " / 5\r\n";
   text += "Rejected / Watch Only:      " + IntegerToString(AC_L17_REJECTED_CANDIDATE_COUNT) + "\r\n";
   text += "Clean Selected:             " + IntegerToString(AC_L17_CLEAN_SELECTED_COUNT) + "\r\n";
   text += "Fallback Selected:          " + IntegerToString(AC_L17_FALLBACK_SELECTED_COUNT) + "\r\n";
   text += "Full Depth Requests:        " + IntegerToString(AC_L17_FULL_DEPTH_COUNT) + "\r\n";
   text += "Standard Depth Requests:    " + IntegerToString(AC_L17_STANDARD_DEPTH_COUNT) + "\r\n";
   text += "Fallback Limited Requests:  " + IntegerToString(AC_L17_FALLBACK_LIMITED_DEPTH_COUNT) + "\r\n";
   text += "Top Deep Symbol:            " + AC_L17_TOP_SYMBOL + "\r\n";
   text += "Source Generated UTC:       " + AC_L17_GENERATED_UTC + "\r\n";
   text += "Collects OHLC:              FALSE\r\n";
   text += "Collects Ticks:             FALSE\r\n";
   text += "Collects Indicators:        FALSE\r\n";
   text += "Collects Liquidity:         FALSE\r\n";
   text += "All Symbol Scan:            FALSE\r\n";
   text += "Trade Permission:           FALSE\r\n";
   text += "Entry Signal:               FALSE\r\n";
   text += "Execution:                  FALSE\r\n";
   text += "Main Blocker:               " + AC_L17_MAIN_BLOCKER + "\r\n";
   return text;
}

string AC_Layer17DossierSection(const string symbol)
{
   AC_L17RefreshSummary();
   string row = AC_L17CsvLineForSymbol(symbol);
   string text = "";
   text += "\r\nLAYER 17 - DEEP EVIDENCE SELECTION SPLIT\r\n";
   text += "----------------------------------------\r\n";
   text += "Status: " + AC_L17_STATUS + "\r\n";
   text += "Owner: Runtime 4 - Surface Scoring / Deep Evidence Selection Support\r\n";
   text += "Source L16 Hold State: " + AC_L17_SOURCE_L16_HOLD_STATE + "\r\n";
   text += "Source Generated UTC: " + AC_L17_GENERATED_UTC + "\r\n";
   if(row == "")
   {
      text += "Deep Evidence Selected: FALSE\r\n";
      text += "Reason: symbol not present in current L17 selected deep evidence split, or L17 not readable yet\r\n";
   }
   else
   {
      text += "Deep Evidence Selected: TRUE\r\n";
      text += "Deep Evidence Rank: #" + AC_L17CsvField(row, 0) + " / " + IntegerToString(AC_L17_DEEP_SELECTED_COUNT) + "\r\n";
      text += "Source L16 Display Rank: #" + AC_L17CsvField(row, 3) + "\r\n";
      text += "Source L16 Tier: " + AC_L17CsvField(row, 5) + "\r\n";
      text += "Source L16 Clean Diversified: " + AC_L17CsvField(row, 6) + "\r\n";
      text += "Source L16 Fallback Used: " + AC_L17CsvField(row, 7) + "\r\n";
      text += "Ranking Group: " + AC_L17CsvField(row, 12) + "\r\n";
      text += "L16 Primary Score: " + AC_L17CsvField(row, 16) + "\r\n";
      text += "Max Corr To Selected: " + AC_L17CsvField(row, 17) + "\r\n";
      text += "Correlation State: " + AC_L17CsvField(row, 19) + "\r\n";
      text += "Depth Assignment: " + AC_L17CsvField(row, 24) + "\r\n";
      text += "Evidence Budget Class: " + AC_L17CsvField(row, 25) + "\r\n";
      text += "OHLC Depth: " + AC_L17CsvField(row, 26) + "\r\n";
      text += "Tick Depth: " + AC_L17CsvField(row, 27) + "\r\n";
      text += "Indicator Depth: " + AC_L17CsvField(row, 28) + "\r\n";
      text += "Liquidity Depth: " + AC_L17CsvField(row, 29) + "\r\n";
      text += "Selection Reason: " + AC_L17CsvField(row, 30) + "\r\n";
   }
   text += "Meaning: deep_evidence_selection_split_only_not_evidence_collection_not_trade_permission\r\n";
   text += "Deep Evidence Runtime: FALSE\r\n";
   text += "Trade Permission: FALSE\r\n";
   text += "Entry Signal: FALSE\r\n";
   text += "Execution: FALSE\r\n";
   return text;
}

#endif
