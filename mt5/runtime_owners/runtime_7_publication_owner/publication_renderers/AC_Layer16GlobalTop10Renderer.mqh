#ifndef AC_LAYER16_GLOBAL_TOP10_RENDERER_MQH
#define AC_LAYER16_GLOBAL_TOP10_RENDERER_MQH

// Runtime 7 render-only surface for Layer 16 Global Top 10 Builder.
// Reads worker L16 summary and CSV outputs only.
// Must not build the basket, calculate correlation, permit, alert, or execute.

static string AC_L16_STATUS = "Pending L16 Global Top 10";
static string AC_L16_VALIDATION_STATUS = "Pending";
static string AC_L16_VALIDATION_REASON = "l16_global_top10_summary.txt missing or not accepted/degraded";
static string AC_L16_MAIN_BLOCKER = "l16 summary has not been accepted yet";
static bool   AC_L16_ACCEPTED = false;
static int    AC_L16_CANDIDATE_POOL_SIZE = 0;
static int    AC_L16_L15_CANDIDATE_COUNT = 0;
static int    AC_L16_SELECTED_COUNT = 0;
static int    AC_L16_UNFILLED_SLOTS_COUNT = 10;
static int    AC_L16_REJECT_COUNT = 0;
static int    AC_L16_CORRELATION_REJECT_COUNT = 0;
static int    AC_L16_GROUP_CAP_REJECT_COUNT = 0;
static int    AC_L16_FALLBACK_COUNT = 0;
static int    AC_L16_GROUP_COUNT = 0;
static int    AC_L16_WRITE_FAILED_COUNT = 0;
static string AC_L16_TOP_SYMBOL = "not_available";
static string AC_L16_GENERATED_UTC = "not_available";
static string AC_L16_THRESHOLD_STATUS = "untested_default_not_holy_law";
static string AC_L16_HOLD_STATE = "not_available";
static string AC_L16_HOLD_VALID_UNTIL_UTC = "not_available";
static string AC_L16_VISIBLE_SURFACE_STATE = "not_available";
static int    AC_L16_HOLD_AGE_SECONDS = 0;

string AC_L16LayerFolder(){ return AC_ExternalWorkerOutboxFolder() + "\\Layers\\Layer_16_Global_Top10_Builder"; }
string AC_L16SummaryPath(){ return AC_L16LayerFolder() + "\\l16_global_top10_summary.txt"; }
string AC_L16Top10CsvPath(){ return AC_L16LayerFolder() + "\\l16_global_top10.csv"; }
string AC_L16RejectsCsvPath(){ return AC_L16LayerFolder() + "\\l16_global_top10_rejects.csv"; }
string AC_L16FallbacksCsvPath(){ return AC_L16LayerFolder() + "\\l16_global_top10_fallbacks.csv"; }
string AC_L16ManifestPath(){ return AC_L16LayerFolder() + "\\l16_global_top10.manifest"; }
string AC_L16SelectionDeskPath(){ return AC_SelectionGlobalFolder() + "\\Global Top 10.txt"; }
string AC_L16SelectionDeskCsvPath(){ return AC_SelectionGlobalFolder() + "\\current_top10.csv"; }
string AC_L16SelectionDeskManifestPath(){ return AC_SelectionGlobalFolder() + "\\current_top10_manifest.txt"; }

string AC_L16ReadSmallTextFile(const string path, const int max_chars = 50000)
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

string AC_L16KvValue(const string text, const string key, const string fallback = "not_available")
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

int AC_L16KvInt(const string text, const string key, const int fallback = 0)
{
   string value = AC_L16KvValue(text, key, "");
   if(value == "") return fallback;
   return (int)StringToInteger(value);
}

void AC_L16RefreshSummary()
{
   AC_L16_ACCEPTED = false;
   AC_L16_STATUS = "Pending L16 Global Top 10";
   AC_L16_VALIDATION_STATUS = "Pending";
   AC_L16_VALIDATION_REASON = "l16_global_top10_summary.txt missing or unreadable";
   AC_L16_MAIN_BLOCKER = AC_L16_VALIDATION_REASON;
   AC_L16_CANDIDATE_POOL_SIZE = 0;
   AC_L16_L15_CANDIDATE_COUNT = 0;
   AC_L16_SELECTED_COUNT = 0;
   AC_L16_UNFILLED_SLOTS_COUNT = 10;
   AC_L16_REJECT_COUNT = 0;
   AC_L16_CORRELATION_REJECT_COUNT = 0;
   AC_L16_GROUP_CAP_REJECT_COUNT = 0;
   AC_L16_FALLBACK_COUNT = 0;
   AC_L16_GROUP_COUNT = 0;
   AC_L16_WRITE_FAILED_COUNT = 0;
   AC_L16_TOP_SYMBOL = "not_available";
   AC_L16_GENERATED_UTC = "not_available";
   AC_L16_THRESHOLD_STATUS = "untested_default_not_holy_law";
   AC_L16_HOLD_STATE = "not_available";
   AC_L16_HOLD_VALID_UNTIL_UTC = "not_available";
   AC_L16_VISIBLE_SURFACE_STATE = "not_available";
   AC_L16_HOLD_AGE_SECONDS = 0;

   string summary = AC_L16ReadSmallTextFile(AC_L16SummaryPath(), 50000);
   if(summary == "") return;

   string status = AC_L16KvValue(summary, "status", "pending");
   string global_top10_runtime = AC_L16KvValue(summary, "global_top10_runtime", "not_available");
   string trade_permission = AC_L16KvValue(summary, "trade_permission", "not_available");
   string entry_signal = AC_L16KvValue(summary, "entry_signal", "not_available");
   string execution = AC_L16KvValue(summary, "execution", "not_available");
   AC_L16_CANDIDATE_POOL_SIZE = AC_L16KvInt(summary, "candidate_pool_size", 0);
   AC_L16_L15_CANDIDATE_COUNT = AC_L16KvInt(summary, "l15_candidate_count", 0);
   AC_L16_SELECTED_COUNT = AC_L16KvInt(summary, "selected_count", 0);
   AC_L16_UNFILLED_SLOTS_COUNT = AC_L16KvInt(summary, "unfilled_slots_count", 10);
   AC_L16_REJECT_COUNT = AC_L16KvInt(summary, "reject_count", 0);
   AC_L16_CORRELATION_REJECT_COUNT = AC_L16KvInt(summary, "correlation_reject_count", 0);
   AC_L16_GROUP_CAP_REJECT_COUNT = AC_L16KvInt(summary, "group_cap_reject_count", 0);
   AC_L16_FALLBACK_COUNT = AC_L16KvInt(summary, "fallback_count", 0);
   AC_L16_GROUP_COUNT = AC_L16KvInt(summary, "group_count", 0);
   AC_L16_WRITE_FAILED_COUNT = AC_L16KvInt(summary, "write_failed_count", 0);
   AC_L16_TOP_SYMBOL = AC_L16KvValue(summary, "top_symbol", "not_available");
   AC_L16_GENERATED_UTC = AC_L16KvValue(summary, "generated_utc", "not_available");
   AC_L16_THRESHOLD_STATUS = AC_L16KvValue(summary, "threshold_status", "untested_default_not_holy_law");
   AC_L16_HOLD_STATE = AC_L16KvValue(summary, "l16_hold_state", "not_available");
   AC_L16_HOLD_VALID_UNTIL_UTC = AC_L16KvValue(summary, "l16_hold_valid_until_utc", "not_available");
   AC_L16_VISIBLE_SURFACE_STATE = AC_L16KvValue(summary, "l16_visible_surface_state", "not_available");
   AC_L16_HOLD_AGE_SECONDS = AC_L16KvInt(summary, "l16_hold_age_seconds", 0);

   bool files_ok = FileIsExist(AC_L16Top10CsvPath(), AC_CommonFlag())
      && FileIsExist(AC_L16RejectsCsvPath(), AC_CommonFlag())
      && FileIsExist(AC_L16FallbacksCsvPath(), AC_CommonFlag())
      && FileIsExist(AC_L16ManifestPath(), AC_CommonFlag())
      && FileIsExist(AC_L16SelectionDeskPath(), AC_CommonFlag())
      && FileIsExist(AC_L16SelectionDeskCsvPath(), AC_CommonFlag())
      && FileIsExist(AC_L16SelectionDeskManifestPath(), AC_CommonFlag());
   bool permission_ok = (global_top10_runtime == "false" && trade_permission == "false" && entry_signal == "false" && execution == "false");
   bool counts_ok = (AC_L16_CANDIDATE_POOL_SIZE > 0 && AC_L16_L15_CANDIDATE_COUNT > 0 && AC_L16_SELECTED_COUNT >= 0);
   bool writes_ok = (AC_L16_WRITE_FAILED_COUNT == 0);
   bool status_ok = (status == "accepted" || status == "degraded" || status == "write_degraded");

   if(status_ok && files_ok && permission_ok && counts_ok && writes_ok)
   {
      AC_L16_ACCEPTED = true;
      AC_L16_STATUS = (status == "accepted" ? "Accepted" : "Degraded Accepted");
      AC_L16_VALIDATION_STATUS = (status == "accepted" ? "Accepted" : "Degraded");
      AC_L16_VALIDATION_REASON = "summary/files/counts/permission accepted; status=" + status;
      AC_L16_MAIN_BLOCKER = (status == "accepted" ? "none" : "Global Top 10 constrained; unfilled slots visible");
      return;
   }

   AC_L16_STATUS = "L16 Global Top 10 degraded";
   AC_L16_VALIDATION_STATUS = "Degraded";
   AC_L16_VALIDATION_REASON = "status=" + status
      + ";files_ok=" + (files_ok ? "true" : "false")
      + ";counts_ok=" + (counts_ok ? "true" : "false")
      + ";permission_ok=" + (permission_ok ? "true" : "false")
      + ";writes_ok=" + (writes_ok ? "true" : "false");
   AC_L16_MAIN_BLOCKER = AC_L16_VALIDATION_REASON;
}

string AC_Layer16BoardSection()
{
   AC_L16RefreshSummary();
   string text = "";
   text += "\r\nLAYER 16 - GLOBAL TOP 10 INSPECTION BASKET\r\n";
   text += "----------------------------------------\r\n";
   text += "Status:                     " + AC_L16_STATUS + "\r\n";
   text += "Owner:                      Runtime 5 - Taxonomy / Ranking Group Owner\r\n";
   text += "Input Source:               L14 candidate pool + L15 correlation/diversity\r\n";
   text += "Visible Surface State:      " + AC_L16_VISIBLE_SURFACE_STATE + "\r\n";
   text += "Hold State:                 " + AC_L16_HOLD_STATE + "\r\n";
   text += "Hold Age Seconds:           " + IntegerToString(AC_L16_HOLD_AGE_SECONDS) + "\r\n";
   text += "Hold Valid Until UTC:       " + AC_L16_HOLD_VALID_UNTIL_UTC + "\r\n";
   text += "Visible Basket Meaning:     held display basket; latest calculation files may differ inside worker layer until hold expiry\r\n";
   text += "Candidate Pool Size:        " + IntegerToString(AC_L16_CANDIDATE_POOL_SIZE) + "\r\n";
   text += "L15 Candidate Count:        " + IntegerToString(AC_L16_L15_CANDIDATE_COUNT) + "\r\n";
   text += "Selected Count:             " + IntegerToString(AC_L16_SELECTED_COUNT) + " / 10\r\n";
   text += "Unfilled Slots:             " + IntegerToString(AC_L16_UNFILLED_SLOTS_COUNT) + "\r\n";
   text += "Reject Count:               " + IntegerToString(AC_L16_REJECT_COUNT) + "\r\n";
   text += "Correlation Rejects:        " + IntegerToString(AC_L16_CORRELATION_REJECT_COUNT) + "\r\n";
   text += "Group Cap Rejects:          " + IntegerToString(AC_L16_GROUP_CAP_REJECT_COUNT) + "\r\n";
   text += "Fallback Count:             " + IntegerToString(AC_L16_FALLBACK_COUNT) + "\r\n";
   text += "Groups Represented:         " + IntegerToString(AC_L16_GROUP_COUNT) + "\r\n";
   text += "Top Symbol:                 " + AC_L16_TOP_SYMBOL + "\r\n";
   text += "Threshold Status:           " + AC_L16_THRESHOLD_STATUS + "\r\n";
   text += "Source Generated UTC:       " + AC_L16_GENERATED_UTC + "\r\n";
   text += "Global Top10 Runtime:       FALSE\r\n";
   text += "Trade Permission:           FALSE\r\n";
   text += "Entry Signal:               FALSE\r\n";
   text += "Execution:                  FALSE\r\n";
   text += "Main Blocker:               " + AC_L16_MAIN_BLOCKER + "\r\n";
   return text;
}

string AC_L16CsvField(string line, int index, string fallback = "not_available")
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

string AC_L16CsvLineForSymbol(const string symbol)
{
   string csv = AC_L16ReadSmallTextFile(AC_L16Top10CsvPath(), 1000000);
   if(csv == "") return "";
   string lines[];
   ushort separator = StringGetCharacter("\n", 0);
   int count = StringSplit(csv, separator, lines);
   for(int i = 1; i < count; i++)
   {
      string line = lines[i];
      StringReplace(line, "\r", "");
      if(AC_L16CsvField(line, 1, "") == symbol) return line;
   }
   return "";
}

string AC_Layer16DossierSection(const string symbol)
{
   AC_L16RefreshSummary();
   string row = AC_L16CsvLineForSymbol(symbol);
   string text = "";
   text += "\r\nLAYER 16 - GLOBAL TOP 10 INSPECTION BASKET\r\n";
   text += "----------------------------------------\r\n";
   text += "Status: " + AC_L16_STATUS + "\r\n";
   text += "Owner: Runtime 5 - Taxonomy / Ranking Group Owner\r\n";
   text += "Visible Surface State: " + AC_L16_VISIBLE_SURFACE_STATE + "\r\n";
   text += "Hold State: " + AC_L16_HOLD_STATE + "\r\n";
   text += "Hold Valid Until UTC: " + AC_L16_HOLD_VALID_UNTIL_UTC + "\r\n";
   text += "Visible Basket Meaning: held display basket; latest calculation files may differ until hold expiry\r\n";
   text += "Source Generated UTC: " + AC_L16_GENERATED_UTC + "\r\n";
   if(row == "")
   {
      text += "Global Top 10 Member: FALSE\r\n";
      text += "Reason: symbol not present in visible held L16 Global Top 10, or L16 not readable yet\r\n";
   }
   else
   {
      text += "Global Top 10 Member: TRUE\r\n";
      text += "Global Rank: #" + AC_L16CsvField(row, 0) + " / " + IntegerToString(AC_L16_SELECTED_COUNT) + "\r\n";
      text += "Ranking Group: " + AC_L16CsvField(row, 3) + "\r\n";
      text += "L16 Primary Score: " + AC_L16CsvField(row, 7) + "\r\n";
      text += "L14 Candidate Score: " + AC_L16CsvField(row, 8) + "\r\n";
      text += "L15 Diversity Score: " + AC_L16CsvField(row, 9) + "\r\n";
      text += "Max Corr To Selected: " + AC_L16CsvField(row, 13) + "\r\n";
      text += "Max Corr Pair: " + AC_L16CsvField(row, 14) + "\r\n";
      text += "Correlation Clean: " + AC_L16CsvField(row, 15) + "\r\n";
      text += "Correlation State: " + AC_L16CsvField(row, 16) + "\r\n";
      text += "Correlation Confidence: " + AC_L16CsvField(row, 17) + "\r\n";
      text += "Currency Overlap Score: " + AC_L16CsvField(row, 18) + "\r\n";
      text += "Ranking Group Overlap Score: " + AC_L16CsvField(row, 19) + "\r\n";
      text += "Leader / Backup: " + AC_L16CsvField(row, 20) + "\r\n";
      text += "Candidate Source: " + AC_L16CsvField(row, 21) + "\r\n";
      text += "Selection Reason: " + AC_L16CsvField(row, 22) + "\r\n";
      text += "Row Hold Visible: " + AC_L16CsvField(row, 38) + "\r\n";
      text += "Row Hold State: " + AC_L16CsvField(row, 39) + "\r\n";
   }
   text += "Meaning: global_top10_inspection_basket_only_not_trade_permission\r\n";
   text += "Global Top10 Runtime: FALSE\r\n";
   text += "Trade Permission: FALSE\r\n";
   text += "Entry Signal: FALSE\r\n";
   text += "Execution: FALSE\r\n";
   return text;
}

string AC_Layer16WorkbenchSection()
{
   AC_L16RefreshSummary();
   string text = "";
   text += "\r\nL16_GLOBAL_TOP10_BUILDER\r\n";
   text += "----------------------------------------\r\n";
   text += "schema_name=l16_global_top10_builder\r\n";
   text += "schema_version=2\r\n";
   text += "owner_name=Runtime 5 - Taxonomy / Ranking Group Owner\r\n";
   text += "layer_id=16\r\n";
   text += "input_source=L14_candidate_pool+L15_correlation_diversity_outputs\r\n";
   text += "status=" + AC_L16_STATUS + "\r\n";
   text += "validation_status=" + AC_L16_VALIDATION_STATUS + "\r\n";
   text += "validation_reason=" + AC_L16_VALIDATION_REASON + "\r\n";
   text += "visible_surface_state=" + AC_L16_VISIBLE_SURFACE_STATE + "\r\n";
   text += "hold_state=" + AC_L16_HOLD_STATE + "\r\n";
   text += "hold_age_seconds=" + IntegerToString(AC_L16_HOLD_AGE_SECONDS) + "\r\n";
   text += "hold_valid_until_utc=" + AC_L16_HOLD_VALID_UNTIL_UTC + "\r\n";
   text += "visible_basket_meaning=held_display_basket_latest_calculation_files_may_differ_until_hold_expiry\r\n";
   text += "candidate_pool_size=" + IntegerToString(AC_L16_CANDIDATE_POOL_SIZE) + "\r\n";
   text += "l15_candidate_count=" + IntegerToString(AC_L16_L15_CANDIDATE_COUNT) + "\r\n";
   text += "selected_count=" + IntegerToString(AC_L16_SELECTED_COUNT) + "\r\n";
   text += "unfilled_slots_count=" + IntegerToString(AC_L16_UNFILLED_SLOTS_COUNT) + "\r\n";
   text += "reject_count=" + IntegerToString(AC_L16_REJECT_COUNT) + "\r\n";
   text += "correlation_reject_count=" + IntegerToString(AC_L16_CORRELATION_REJECT_COUNT) + "\r\n";
   text += "group_cap_reject_count=" + IntegerToString(AC_L16_GROUP_CAP_REJECT_COUNT) + "\r\n";
   text += "fallback_count=" + IntegerToString(AC_L16_FALLBACK_COUNT) + "\r\n";
   text += "group_count=" + IntegerToString(AC_L16_GROUP_COUNT) + "\r\n";
   text += "top_symbol=" + AC_L16_TOP_SYMBOL + "\r\n";
   text += "threshold_status=" + AC_L16_THRESHOLD_STATUS + "\r\n";
   text += "source_generated_utc=" + AC_L16_GENERATED_UTC + "\r\n";
   text += "summary_path=" + AC_L16SummaryPath() + "\r\n";
   text += "top10_csv_path=" + AC_L16Top10CsvPath() + "\r\n";
   text += "rejects_csv_path=" + AC_L16RejectsCsvPath() + "\r\n";
   text += "selection_desk_path=" + AC_L16SelectionDeskPath() + "\r\n";
   text += "global_top10_runtime=false\r\n";
   text += "trade_permission=false\r\n";
   text += "entry_signal=false\r\n";
   text += "execution=false\r\n";
   return text;
}

#endif