#ifndef AC_LAYER14_CANDIDATE_POOL_RENDERER_MQH
#define AC_LAYER14_CANDIDATE_POOL_RENDERER_MQH

// Runtime 7 render-only surface for Layer 14 Ranking Group Leader Candidate Pool.
// Reads worker L14 summary and canonical layer summary index outputs only.
// Must not diversify, run correlation, build Global Top 10, permit, alert, or execute.

static string AC_L14_STATUS = "Pending L14 candidate pool";
static string AC_L14_VALIDATION_STATUS = "Pending";
static string AC_L14_VALIDATION_REASON = "l14_candidate_pool_summary.txt missing or not accepted";
static string AC_L14_MAIN_BLOCKER = "l14 summary has not been accepted yet";
static bool   AC_L14_ACCEPTED = false;
static int    AC_L14_SELECTED_GROUP_COUNT = 0;
static int    AC_L14_CANDIDATE_POOL_SIZE = 0;
static int    AC_L14_LEADER_CANDIDATE_COUNT = 0;
static int    AC_L14_BACKUP_CANDIDATE_COUNT = 0;
static int    AC_L14_REVIEW_CANDIDATE_COUNT = 0;
static int    AC_L14_THIN_FALLBACK_CANDIDATE_COUNT = 0;
static int    AC_L14_WRITE_FAILED_COUNT = 0;
static string AC_L14_TOP_CANDIDATE = "not_available";
static string AC_L14_GENERATED_UTC = "not_available";

string AC_L14LayerFolder(){ return AC_ExternalWorkerOutboxFolder() + "\\Layers\\Layer_14_Ranking_Group_Leader_Candidate_Pool"; }
string AC_L14SummaryPath(){ return AC_L14LayerFolder() + "\\l14_candidate_pool_summary.txt"; }
string AC_L14CandidateCsvPath(){ return AC_L14LayerFolder() + "\\l14_candidate_pool.csv"; }
string AC_L14CandidateManifestPath(){ return AC_L14LayerFolder() + "\\l14_candidate_pool.manifest"; }
string AC_L14CanonicalSummaryFolder(){ return AC_SelectionDeskFolder() + "\\91_Layer_Summaries\\L14_Candidate_Pool"; }
string AC_L14SelectionDeskPath(){ return AC_L14CanonicalSummaryFolder() + "\\00_Ranking_Group_Leader_Candidate_Pool.txt"; }
string AC_L14SelectionDeskCsvPath(){ return AC_L14CanonicalSummaryFolder() + "\\00_Ranking_Group_Leader_Candidate_Pool.csv"; }

string AC_L14ReadSmallTextFile(const string path, const int max_chars = 50000)
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

string AC_L14KvValue(const string text, const string key, const string fallback = "not_available")
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

int AC_L14KvInt(const string text, const string key, const int fallback = 0)
{
   string value = AC_L14KvValue(text, key, "");
   if(value == "") return fallback;
   return (int)StringToInteger(value);
}

void AC_L14RefreshSummary()
{
   AC_L14_ACCEPTED = false;
   AC_L14_STATUS = "Pending L14 candidate pool";
   AC_L14_VALIDATION_STATUS = "Pending";
   AC_L14_VALIDATION_REASON = "l14_candidate_pool_summary.txt missing or unreadable";
   AC_L14_MAIN_BLOCKER = AC_L14_VALIDATION_REASON;
   AC_L14_SELECTED_GROUP_COUNT = 0;
   AC_L14_CANDIDATE_POOL_SIZE = 0;
   AC_L14_LEADER_CANDIDATE_COUNT = 0;
   AC_L14_BACKUP_CANDIDATE_COUNT = 0;
   AC_L14_REVIEW_CANDIDATE_COUNT = 0;
   AC_L14_THIN_FALLBACK_CANDIDATE_COUNT = 0;
   AC_L14_WRITE_FAILED_COUNT = 0;
   AC_L14_TOP_CANDIDATE = "not_available";
   AC_L14_GENERATED_UTC = "not_available";

   string summary = AC_L14ReadSmallTextFile(AC_L14SummaryPath(), 50000);
   if(summary == "") return;

   string status = AC_L14KvValue(summary, "status", "pending");
   string candidate_pool_runtime = AC_L14KvValue(summary, "candidate_pool_runtime", "not_available");
   string trade_permission = AC_L14KvValue(summary, "trade_permission", "not_available");
   string entry_signal = AC_L14KvValue(summary, "entry_signal", "not_available");
   string execution = AC_L14KvValue(summary, "execution", "not_available");
   AC_L14_SELECTED_GROUP_COUNT = AC_L14KvInt(summary, "selected_group_count", 0);
   AC_L14_CANDIDATE_POOL_SIZE = AC_L14KvInt(summary, "candidate_pool_size", 0);
   AC_L14_LEADER_CANDIDATE_COUNT = AC_L14KvInt(summary, "leader_candidate_count", 0);
   AC_L14_BACKUP_CANDIDATE_COUNT = AC_L14KvInt(summary, "backup_candidate_count", 0);
   AC_L14_REVIEW_CANDIDATE_COUNT = AC_L14KvInt(summary, "review_candidate_count", 0);
   AC_L14_THIN_FALLBACK_CANDIDATE_COUNT = AC_L14KvInt(summary, "thin_fallback_candidate_count", 0);
   AC_L14_WRITE_FAILED_COUNT = AC_L14KvInt(summary, "write_failed_count", 0);
   AC_L14_TOP_CANDIDATE = AC_L14KvValue(summary, "top_candidate", "not_available");
   AC_L14_GENERATED_UTC = AC_L14KvValue(summary, "generated_utc", "not_available");

   bool files_ok = FileIsExist(AC_L14CandidateCsvPath(), AC_CommonFlag())
      && FileIsExist(AC_L14CandidateManifestPath(), AC_CommonFlag())
      && FileIsExist(AC_L14SelectionDeskPath(), AC_CommonFlag())
      && FileIsExist(AC_L14SelectionDeskCsvPath(), AC_CommonFlag());
   bool permission_ok = (candidate_pool_runtime == "false" && trade_permission == "false" && entry_signal == "false" && execution == "false");
   bool counts_ok = (AC_L14_CANDIDATE_POOL_SIZE > 0);
   bool writes_ok = (AC_L14_WRITE_FAILED_COUNT == 0);

   if(status == "accepted" && files_ok && permission_ok && counts_ok && writes_ok)
   {
      AC_L14_ACCEPTED = true;
      AC_L14_STATUS = "Accepted";
      AC_L14_VALIDATION_STATUS = "Accepted";
      AC_L14_VALIDATION_REASON = "summary/files/counts/canonical_layer_summary_index/permission all accepted";
      AC_L14_MAIN_BLOCKER = "none";
      return;
   }

   AC_L14_STATUS = "L14 candidate pool degraded";
   AC_L14_VALIDATION_STATUS = "Degraded";
   AC_L14_VALIDATION_REASON = "status=" + status
      + ";files_ok=" + (files_ok ? "true" : "false")
      + ";counts_ok=" + (counts_ok ? "true" : "false")
      + ";permission_ok=" + (permission_ok ? "true" : "false")
      + ";writes_ok=" + (writes_ok ? "true" : "false");
   AC_L14_MAIN_BLOCKER = AC_L14_VALIDATION_REASON;
}

string AC_Layer14BoardSection()
{
   AC_L14RefreshSummary();
   string text = "";
   text += "\r\nLAYER 14 - RANKING GROUP LEADER CANDIDATE POOL\r\n";
   text += "----------------------------------------\r\n";
   text += "Status:                     " + AC_L14_STATUS + "\r\n";
   text += "Owner:                      Runtime 5 - Taxonomy / Ranking Group Owner\r\n";
   text += "Input Source:               L13 selected groups + guarded L11 top5 + L12 group heat\r\n";
   text += "Selected Groups Consumed:   " + IntegerToString(AC_L14_SELECTED_GROUP_COUNT) + "\r\n";
   text += "Candidate Pool Size:        " + IntegerToString(AC_L14_CANDIDATE_POOL_SIZE) + "\r\n";
   text += "Leader Candidates:          " + IntegerToString(AC_L14_LEADER_CANDIDATE_COUNT) + "\r\n";
   text += "Backup Candidates:          " + IntegerToString(AC_L14_BACKUP_CANDIDATE_COUNT) + "\r\n";
   text += "Review Candidates:          " + IntegerToString(AC_L14_REVIEW_CANDIDATE_COUNT) + "\r\n";
   text += "Thin Fallback Candidates:   " + IntegerToString(AC_L14_THIN_FALLBACK_CANDIDATE_COUNT) + "\r\n";
   text += "Top Candidate:              " + AC_L14_TOP_CANDIDATE + "\r\n";
   text += "Source Generated UTC:       " + AC_L14_GENERATED_UTC + "\r\n";
   text += "Candidate Pool Runtime:     FALSE\r\n";
   text += "Trade Permission:           FALSE\r\n";
   text += "Entry Signal:               FALSE\r\n";
   text += "Execution:                  FALSE\r\n";
   text += "Main Blocker:               " + AC_L14_MAIN_BLOCKER + "\r\n";
   return text;
}

string AC_L14CsvField(string line, int index, string fallback = "not_available")
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

string AC_L14CsvLineForSymbol(const string symbol)
{
   string csv = AC_L14ReadSmallTextFile(AC_L14CandidateCsvPath(), 1000000);
   if(csv == "") return "";
   string lines[];
   ushort separator = StringGetCharacter("\n", 0);
   int count = StringSplit(csv, separator, lines);
   for(int i = 1; i < count; i++)
   {
      string line = lines[i];
      StringReplace(line, "\r", "");
      if(AC_L14CsvField(line, 1, "") == symbol) return line;
   }
   return "";
}

string AC_Layer14DossierSection(const string symbol)
{
   AC_L14RefreshSummary();
   string row = AC_L14CsvLineForSymbol(symbol);
   string text = "";
   text += "\r\nLAYER 14 - RANKING GROUP LEADER CANDIDATE POOL\r\n";
   text += "----------------------------------------\r\n";
   text += "Status: " + AC_L14_STATUS + "\r\n";
   text += "Owner: Runtime 5 - Taxonomy / Ranking Group Owner\r\n";
   text += "Source Generated UTC: " + AC_L14_GENERATED_UTC + "\r\n";
   if(row == "")
   {
      text += "Candidate Pool Member: FALSE\r\n";
      text += "Reason: symbol not present in latest raw L14 candidate pool, or L14 not accepted/readable yet\r\n";
   }
   else
   {
      text += "Candidate Pool Member: TRUE\r\n";
      text += "Candidate Pool Rank: #" + AC_L14CsvField(row, 0) + " / " + IntegerToString(AC_L14_CANDIDATE_POOL_SIZE) + "\r\n";
      text += "Candidate Source: " + AC_L14CsvField(row, 8) + "\r\n";
      text += "Leader Or Backup: " + AC_L14CsvField(row, 9) + "\r\n";
      text += "Backup Included Flag: " + AC_L14CsvField(row, 10) + "\r\n";
      text += "Candidate Reason: " + AC_L14CsvField(row, 11) + "\r\n";
      text += "Candidate Priority Score: " + AC_L14CsvField(row, 13) + "\r\n";
      text += "Source Ranking Group: " + AC_L14CsvField(row, 3) + "\r\n";
      text += "Source Group Selection State: " + AC_L14CsvField(row, 19) + "\r\n";
      text += "Source Group Selection Tier: " + AC_L14CsvField(row, 20) + "\r\n";
      text += "Risk Review Flag: " + AC_L14CsvField(row, 17) + "\r\n";
   }
   text += "Meaning: raw_candidate_pool_only_not_diversified_not_global_top10\r\n";
   text += "Candidate Pool Runtime: FALSE\r\n";
   text += "Trade Permission: FALSE\r\n";
   text += "Entry Signal: FALSE\r\n";
   text += "Execution: FALSE\r\n";
   return text;
}

string AC_Layer14WorkbenchSection()
{
   AC_L14RefreshSummary();
   string text = "";
   text += "\r\nL14_RANKING_GROUP_LEADER_CANDIDATE_POOL\r\n";
   text += "----------------------------------------\r\n";
   text += "schema_name=l14_ranking_group_leader_candidate_pool\r\n";
   text += "schema_version=1\r\n";
   text += "owner_name=Runtime 5 - Taxonomy / Ranking Group Owner\r\n";
   text += "layer_id=14\r\n";
   text += "input_source=L13_selected_groups+guarded_L11_top5+L12_group_heat_quality\r\n";
   text += "status=" + AC_L14_STATUS + "\r\n";
   text += "validation_status=" + AC_L14_VALIDATION_STATUS + "\r\n";
   text += "validation_reason=" + AC_L14_VALIDATION_REASON + "\r\n";
   text += "selected_group_count=" + IntegerToString(AC_L14_SELECTED_GROUP_COUNT) + "\r\n";
   text += "candidate_pool_size=" + IntegerToString(AC_L14_CANDIDATE_POOL_SIZE) + "\r\n";
   text += "leader_candidate_count=" + IntegerToString(AC_L14_LEADER_CANDIDATE_COUNT) + "\r\n";
   text += "backup_candidate_count=" + IntegerToString(AC_L14_BACKUP_CANDIDATE_COUNT) + "\r\n";
   text += "review_candidate_count=" + IntegerToString(AC_L14_REVIEW_CANDIDATE_COUNT) + "\r\n";
   text += "thin_fallback_candidate_count=" + IntegerToString(AC_L14_THIN_FALLBACK_CANDIDATE_COUNT) + "\r\n";
   text += "top_candidate=" + AC_L14_TOP_CANDIDATE + "\r\n";
   text += "source_generated_utc=" + AC_L14_GENERATED_UTC + "\r\n";
   text += "summary_path=" + AC_L14SummaryPath() + "\r\n";
   text += "candidate_pool_path=" + AC_L14CandidateCsvPath() + "\r\n";
   text += "selection_desk_candidate_pool_path=" + AC_L14SelectionDeskPath() + "\r\n";
   text += "candidate_pool_runtime=false\r\n";
   text += "trade_permission=false\r\n";
   text += "entry_signal=false\r\n";
   text += "execution=false\r\n";
   return text;
}

#endif
