#ifndef AC_LAYER15_CORRELATION_DIVERSITY_RENDERER_MQH
#define AC_LAYER15_CORRELATION_DIVERSITY_RENDERER_MQH

// Runtime 7 render-only surface for Layer 15 Correlation / Diversity Selection.
// Reads worker L15 summary and CSV outputs only.
// Must not calculate correlation, build Global Top 10, permit, alert, or execute.

static string AC_L15_STATUS = "Pending L15 correlation diversity";
static string AC_L15_VALIDATION_STATUS = "Pending";
static string AC_L15_VALIDATION_REASON = "l15_correlation_diversity_summary.txt missing or not accepted/degraded";
static string AC_L15_MAIN_BLOCKER = "l15 summary has not been accepted yet";
static bool   AC_L15_ACCEPTED = false;
static int    AC_L15_CANDIDATE_POOL_SIZE = 0;
static int    AC_L15_CANDIDATE_SCORED_COUNT = 0;
static int    AC_L15_PAIRWISE_PAIR_COUNT = 0;
static int    AC_L15_CORR_PAIR_COUNT = 0;
static int    AC_L15_HIGH_CORR_PAIR_COUNT = 0;
static int    AC_L15_CORR_UNAVAILABLE_COUNT = 0;
static int    AC_L15_GROUP_COUNT = 0;
static int    AC_L15_WRITE_FAILED_COUNT = 0;
static string AC_L15_TOP_DIVERSITY_CANDIDATE = "not_available";
static string AC_L15_MAX_PAIR_CORR_ABS = "not_available";
static string AC_L15_GENERATED_UTC = "not_available";
static string AC_L15_THRESHOLD_STATUS = "untested_default_not_holy_law";

string AC_L15LayerFolder(){ return AC_ExternalWorkerOutboxFolder() + "\\Layers\\Layer_15_Correlation_Diversity_Selection"; }
string AC_L15SummaryPath(){ return AC_L15LayerFolder() + "\\l15_correlation_diversity_summary.txt"; }
string AC_L15ScoresCsvPath(){ return AC_L15LayerFolder() + "\\l15_candidate_diversity_scores.csv"; }
string AC_L15MatrixCsvPath(){ return AC_L15LayerFolder() + "\\l15_candidate_correlation_matrix.csv"; }
string AC_L15GroupCsvPath(){ return AC_L15LayerFolder() + "\\l15_group_diversity_summary.csv"; }
string AC_L15ManifestPath(){ return AC_L15LayerFolder() + "\\l15_correlation_diversity.manifest"; }
string AC_L15SelectionDeskPath(){ return AC_SelectionGroupsFolder() + "\\00_Correlation_Diversity_Summary.txt"; }
string AC_L15SelectionDeskCsvPath(){ return AC_SelectionGroupsFolder() + "\\00_Correlation_Diversity_Summary.csv"; }

string AC_L15ReadSmallTextFile(const string path, const int max_chars = 50000)
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

string AC_L15KvValue(const string text, const string key, const string fallback = "not_available")
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

int AC_L15KvInt(const string text, const string key, const int fallback = 0)
{
   string value = AC_L15KvValue(text, key, "");
   if(value == "") return fallback;
   return (int)StringToInteger(value);
}

void AC_L15RefreshSummary()
{
   AC_L15_ACCEPTED = false;
   AC_L15_STATUS = "Pending L15 correlation diversity";
   AC_L15_VALIDATION_STATUS = "Pending";
   AC_L15_VALIDATION_REASON = "l15_correlation_diversity_summary.txt missing or unreadable";
   AC_L15_MAIN_BLOCKER = AC_L15_VALIDATION_REASON;
   AC_L15_CANDIDATE_POOL_SIZE = 0;
   AC_L15_CANDIDATE_SCORED_COUNT = 0;
   AC_L15_PAIRWISE_PAIR_COUNT = 0;
   AC_L15_CORR_PAIR_COUNT = 0;
   AC_L15_HIGH_CORR_PAIR_COUNT = 0;
   AC_L15_CORR_UNAVAILABLE_COUNT = 0;
   AC_L15_GROUP_COUNT = 0;
   AC_L15_WRITE_FAILED_COUNT = 0;
   AC_L15_TOP_DIVERSITY_CANDIDATE = "not_available";
   AC_L15_MAX_PAIR_CORR_ABS = "not_available";
   AC_L15_GENERATED_UTC = "not_available";
   AC_L15_THRESHOLD_STATUS = "untested_default_not_holy_law";

   string summary = AC_L15ReadSmallTextFile(AC_L15SummaryPath(), 50000);
   if(summary == "") return;

   string status = AC_L15KvValue(summary, "status", "pending");
   string selection_runtime = AC_L15KvValue(summary, "selection_runtime", "not_available");
   string trade_permission = AC_L15KvValue(summary, "trade_permission", "not_available");
   string entry_signal = AC_L15KvValue(summary, "entry_signal", "not_available");
   string execution = AC_L15KvValue(summary, "execution", "not_available");
   AC_L15_CANDIDATE_POOL_SIZE = AC_L15KvInt(summary, "candidate_pool_size", 0);
   AC_L15_CANDIDATE_SCORED_COUNT = AC_L15KvInt(summary, "candidate_scored_count", 0);
   AC_L15_PAIRWISE_PAIR_COUNT = AC_L15KvInt(summary, "pairwise_pair_count", 0);
   AC_L15_CORR_PAIR_COUNT = AC_L15KvInt(summary, "corr_pair_count", 0);
   AC_L15_HIGH_CORR_PAIR_COUNT = AC_L15KvInt(summary, "high_corr_pair_count", 0);
   AC_L15_CORR_UNAVAILABLE_COUNT = AC_L15KvInt(summary, "corr_unavailable_count", 0);
   AC_L15_GROUP_COUNT = AC_L15KvInt(summary, "group_count", 0);
   AC_L15_WRITE_FAILED_COUNT = AC_L15KvInt(summary, "write_failed_count", 0);
   AC_L15_TOP_DIVERSITY_CANDIDATE = AC_L15KvValue(summary, "top_diversity_candidate", "not_available");
   AC_L15_MAX_PAIR_CORR_ABS = AC_L15KvValue(summary, "max_pair_corr_abs", "not_available");
   AC_L15_GENERATED_UTC = AC_L15KvValue(summary, "generated_utc", "not_available");
   AC_L15_THRESHOLD_STATUS = AC_L15KvValue(summary, "threshold_status", "untested_default_not_holy_law");

   bool files_ok = FileIsExist(AC_L15ScoresCsvPath(), AC_CommonFlag())
      && FileIsExist(AC_L15MatrixCsvPath(), AC_CommonFlag())
      && FileIsExist(AC_L15GroupCsvPath(), AC_CommonFlag())
      && FileIsExist(AC_L15ManifestPath(), AC_CommonFlag())
      && FileIsExist(AC_L15SelectionDeskPath(), AC_CommonFlag())
      && FileIsExist(AC_L15SelectionDeskCsvPath(), AC_CommonFlag());
   bool permission_ok = (selection_runtime == "false" && trade_permission == "false" && entry_signal == "false" && execution == "false");
   bool counts_ok = (AC_L15_CANDIDATE_POOL_SIZE > 0 && AC_L15_CANDIDATE_SCORED_COUNT > 0 && AC_L15_PAIRWISE_PAIR_COUNT >= 0);
   bool writes_ok = (AC_L15_WRITE_FAILED_COUNT == 0);
   bool status_ok = (status == "accepted" || status == "degraded" || status == "write_degraded");

   if(status_ok && files_ok && permission_ok && counts_ok && writes_ok)
   {
      AC_L15_ACCEPTED = true;
      AC_L15_STATUS = (status == "accepted" ? "Accepted" : "Degraded Accepted");
      AC_L15_VALIDATION_STATUS = (status == "accepted" ? "Accepted" : "Degraded");
      AC_L15_VALIDATION_REASON = "summary/files/counts/permission accepted; status=" + status;
      AC_L15_MAIN_BLOCKER = (status == "accepted" ? "none" : "correlation degraded but proof published");
      return;
   }

   AC_L15_STATUS = "L15 correlation diversity degraded";
   AC_L15_VALIDATION_STATUS = "Degraded";
   AC_L15_VALIDATION_REASON = "status=" + status
      + ";files_ok=" + (files_ok ? "true" : "false")
      + ";counts_ok=" + (counts_ok ? "true" : "false")
      + ";permission_ok=" + (permission_ok ? "true" : "false")
      + ";writes_ok=" + (writes_ok ? "true" : "false");
   AC_L15_MAIN_BLOCKER = AC_L15_VALIDATION_REASON;
}

string AC_Layer15BoardSection()
{
   AC_L15RefreshSummary();
   string text = "";
   text += "\r\nLAYER 15 - CORRELATION / DIVERSITY SELECTION\r\n";
   text += "----------------------------------------\r\n";
   text += "Status:                     " + AC_L15_STATUS + "\r\n";
   text += "Owner:                      Runtime 5 - Taxonomy / Ranking Group Owner\r\n";
   text += "Input Source:               L14 candidate pool + Shared OHLC Store when available\r\n";
   text += "Candidate Pool Size:        " + IntegerToString(AC_L15_CANDIDATE_POOL_SIZE) + "\r\n";
   text += "Candidates Scored:          " + IntegerToString(AC_L15_CANDIDATE_SCORED_COUNT) + "\r\n";
   text += "Pairwise Pairs:             " + IntegerToString(AC_L15_PAIRWISE_PAIR_COUNT) + "\r\n";
   text += "Correlation Pairs:          " + IntegerToString(AC_L15_CORR_PAIR_COUNT) + "\r\n";
   text += "High Correlation Pairs:     " + IntegerToString(AC_L15_HIGH_CORR_PAIR_COUNT) + "\r\n";
   text += "Correlation Unavailable:    " + IntegerToString(AC_L15_CORR_UNAVAILABLE_COUNT) + "\r\n";
   text += "Groups Represented:         " + IntegerToString(AC_L15_GROUP_COUNT) + "\r\n";
   text += "Max Pair Corr Abs:          " + AC_L15_MAX_PAIR_CORR_ABS + "\r\n";
   text += "Top Diversity Candidate:    " + AC_L15_TOP_DIVERSITY_CANDIDATE + "\r\n";
   text += "Threshold Status:           " + AC_L15_THRESHOLD_STATUS + "\r\n";
   text += "Source Generated UTC:       " + AC_L15_GENERATED_UTC + "\r\n";
   text += "Selection Runtime:          FALSE\r\n";
   text += "Trade Permission:           FALSE\r\n";
   text += "Entry Signal:               FALSE\r\n";
   text += "Execution:                  FALSE\r\n";
   text += "Main Blocker:               " + AC_L15_MAIN_BLOCKER + "\r\n";
   return text;
}

string AC_L15CsvField(string line, int index, string fallback = "not_available")
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

string AC_L15CsvLineForSymbol(const string symbol)
{
   string csv = AC_L15ReadSmallTextFile(AC_L15ScoresCsvPath(), 1000000);
   if(csv == "") return "";
   string lines[];
   ushort separator = StringGetCharacter("\n", 0);
   int count = StringSplit(csv, separator, lines);
   for(int i = 1; i < count; i++)
   {
      string line = lines[i];
      StringReplace(line, "\r", "");
      if(AC_L15CsvField(line, 1, "") == symbol) return line;
   }
   return "";
}

string AC_Layer15DossierSection(const string symbol)
{
   AC_L15RefreshSummary();
   string row = AC_L15CsvLineForSymbol(symbol);
   string text = "";
   text += "\r\nLAYER 15 - CORRELATION / DIVERSITY SELECTION\r\n";
   text += "----------------------------------------\r\n";
   text += "Status: " + AC_L15_STATUS + "\r\n";
   text += "Owner: Runtime 5 - Taxonomy / Ranking Group Owner\r\n";
   text += "Source Generated UTC: " + AC_L15_GENERATED_UTC + "\r\n";
   if(row == "")
   {
      text += "Candidate Pool Member: FALSE\r\n";
      text += "Reason: symbol not present in latest L15 diversity scores, or L15 not readable yet\r\n";
   }
   else
   {
      text += "Candidate Pool Member: TRUE\r\n";
      text += "Candidate Pool Rank: #" + AC_L15CsvField(row, 0) + " / " + IntegerToString(AC_L15_CANDIDATE_POOL_SIZE) + "\r\n";
      text += "Ranking Group: " + AC_L15CsvField(row, 3) + "\r\n";
      text += "Base Currency: " + AC_L15CsvField(row, 11) + "\r\n";
      text += "Quote Currency: " + AC_L15CsvField(row, 12) + "\r\n";
      text += "Pair Count: " + AC_L15CsvField(row, 13) + "\r\n";
      text += "Correlation Pair Count: " + AC_L15CsvField(row, 14) + "\r\n";
      text += "Correlation Unavailable Count: " + AC_L15CsvField(row, 15) + "\r\n";
      text += "Corr To Pool Max Abs: " + AC_L15CsvField(row, 16) + "\r\n";
      text += "Corr To Pool Avg Abs: " + AC_L15CsvField(row, 17) + "\r\n";
      text += "Corr Pair Max Symbol: " + AC_L15CsvField(row, 18) + "\r\n";
      text += "Correlation State: " + AC_L15CsvField(row, 19) + "\r\n";
      text += "Correlation Reason: " + AC_L15CsvField(row, 20) + "\r\n";
      text += "Currency Overlap Score: " + AC_L15CsvField(row, 21) + "\r\n";
      text += "Ranking Group Overlap Score: " + AC_L15CsvField(row, 22) + "\r\n";
      text += "Diversity Score: " + AC_L15CsvField(row, 23) + "\r\n";
      text += "Diversity State: " + AC_L15CsvField(row, 24) + "\r\n";
      text += "Correlation Confidence: " + AC_L15CsvField(row, 29) + "\r\n";
      text += "L16 Constraint Hint: " + AC_L15CsvField(row, 30) + "\r\n";
   }
   text += "Meaning: correlation_diversity_scoring_only_not_global_top10_not_trade_permission\r\n";
   text += "Selection Runtime: FALSE\r\n";
   text += "Trade Permission: FALSE\r\n";
   text += "Entry Signal: FALSE\r\n";
   text += "Execution: FALSE\r\n";
   return text;
}

string AC_Layer15WorkbenchSection()
{
   AC_L15RefreshSummary();
   string text = "";
   text += "\r\nL15_CORRELATION_DIVERSITY_SELECTION\r\n";
   text += "----------------------------------------\r\n";
   text += "schema_name=l15_correlation_diversity_selection\r\n";
   text += "schema_version=1\r\n";
   text += "owner_name=Runtime 5 - Taxonomy / Ranking Group Owner\r\n";
   text += "layer_id=15\r\n";
   text += "input_source=L14_candidate_pool+Shared_OHLC_Store_when_available\r\n";
   text += "status=" + AC_L15_STATUS + "\r\n";
   text += "validation_status=" + AC_L15_VALIDATION_STATUS + "\r\n";
   text += "validation_reason=" + AC_L15_VALIDATION_REASON + "\r\n";
   text += "candidate_pool_size=" + IntegerToString(AC_L15_CANDIDATE_POOL_SIZE) + "\r\n";
   text += "candidate_scored_count=" + IntegerToString(AC_L15_CANDIDATE_SCORED_COUNT) + "\r\n";
   text += "pairwise_pair_count=" + IntegerToString(AC_L15_PAIRWISE_PAIR_COUNT) + "\r\n";
   text += "corr_pair_count=" + IntegerToString(AC_L15_CORR_PAIR_COUNT) + "\r\n";
   text += "high_corr_pair_count=" + IntegerToString(AC_L15_HIGH_CORR_PAIR_COUNT) + "\r\n";
   text += "corr_unavailable_count=" + IntegerToString(AC_L15_CORR_UNAVAILABLE_COUNT) + "\r\n";
   text += "group_count=" + IntegerToString(AC_L15_GROUP_COUNT) + "\r\n";
   text += "top_diversity_candidate=" + AC_L15_TOP_DIVERSITY_CANDIDATE + "\r\n";
   text += "max_pair_corr_abs=" + AC_L15_MAX_PAIR_CORR_ABS + "\r\n";
   text += "threshold_status=" + AC_L15_THRESHOLD_STATUS + "\r\n";
   text += "source_generated_utc=" + AC_L15_GENERATED_UTC + "\r\n";
   text += "summary_path=" + AC_L15SummaryPath() + "\r\n";
   text += "candidate_diversity_scores_path=" + AC_L15ScoresCsvPath() + "\r\n";
   text += "candidate_correlation_matrix_path=" + AC_L15MatrixCsvPath() + "\r\n";
   text += "group_diversity_summary_path=" + AC_L15GroupCsvPath() + "\r\n";
   text += "selection_desk_summary_path=" + AC_L15SelectionDeskPath() + "\r\n";
   text += "selection_runtime=false\r\n";
   text += "trade_permission=false\r\n";
   text += "entry_signal=false\r\n";
   text += "execution=false\r\n";
   return text;
}

#endif