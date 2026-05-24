#ifndef AC_LAYER11_SELECTION_GROUPS_RENDERER_MQH
#define AC_LAYER11_SELECTION_GROUPS_RENDERER_MQH

// Runtime 7 render-only surface for Layer 11 Symbol Ranking Inside Ranking Group.
// Reads only Python worker L11 summary/ranked outputs and visible Selection Desk files.
// Must not rank, classify, select groups, build Global Top 10, permit, alert, or execute.

static string AC_L11_STATUS = "Pending L11 symbol ranking";
static string AC_L11_VALIDATION_STATUS = "Pending";
static string AC_L11_VALIDATION_REASON = "l11_summary.txt missing or not accepted";
static string AC_L11_MAIN_BLOCKER = "l11_summary.txt has not been accepted yet";
static bool   AC_L11_ACCEPTED = false;
static int    AC_L11_RANKING_GROUP_COUNT = 0;
static int    AC_L11_RANKED_SYMBOL_COUNT = 0;
static int    AC_L11_NOT_RANKABLE_TAXONOMY_COUNT = 0;
static int    AC_L11_NOT_RANKABLE_QUALITY_COUNT = 0;
static int    AC_L11_RISK_REVIEW_COUNT = 0;
static int    AC_L11_TOP5_GROUP_COUNT = 0;
static int    AC_L11_VISIBLE_GROUP_FILES_WRITTEN = 0;
static int    AC_L11_VISIBLE_GROUP_FILES_EXPECTED = 0;
static int    AC_L11_WRITE_FAILED_COUNT = 0;
static string AC_L11_GENERATED_UTC = "not_available";

string AC_L11LayerFolder(){ return AC_ExternalWorkerOutboxFolder() + "\\Layers\\Layer_11_Symbol_Ranking_Inside_Ranking_Group"; }
string AC_L11SummaryPath(){ return AC_L11LayerFolder() + "\\l11_summary.txt"; }
string AC_L11RankedSymbolsPath(){ return AC_L11LayerFolder() + "\\ranked_symbols_by_group.csv"; }
string AC_L11Top5Path(){ return AC_L11LayerFolder() + "\\ranking_group_top5.csv"; }
string AC_L11VisibleGroupIndexPath(){ return AC_SelectionGroupsFolder() + "\\00_Group_Index.txt"; }
string AC_L11VisibleGroupIndexCsvPath(){ return AC_SelectionGroupsFolder() + "\\00_Group_Index.csv"; }

string AC_L11ReadSmallTextFile(const string path, const int max_chars = 50000)
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

string AC_L11KvValue(const string text, const string key, const string fallback = "not_available")
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

int AC_L11KvInt(const string text, const string key, const int fallback = 0)
{
   string value = AC_L11KvValue(text, key, "");
   if(value == "") return fallback;
   return (int)StringToInteger(value);
}

string AC_L11BoolText(const bool value){ return value ? "TRUE" : "FALSE"; }
string AC_L11BoolKv(const bool value){ return value ? "true" : "false"; }

void AC_L11RefreshSummary()
{
   AC_L11_ACCEPTED = false;
   AC_L11_STATUS = "Pending L11 symbol ranking";
   AC_L11_VALIDATION_STATUS = "Pending";
   AC_L11_VALIDATION_REASON = "l11_summary.txt missing or unreadable";
   AC_L11_MAIN_BLOCKER = AC_L11_VALIDATION_REASON;
   AC_L11_RANKING_GROUP_COUNT = 0;
   AC_L11_RANKED_SYMBOL_COUNT = 0;
   AC_L11_NOT_RANKABLE_TAXONOMY_COUNT = 0;
   AC_L11_NOT_RANKABLE_QUALITY_COUNT = 0;
   AC_L11_RISK_REVIEW_COUNT = 0;
   AC_L11_TOP5_GROUP_COUNT = 0;
   AC_L11_VISIBLE_GROUP_FILES_WRITTEN = 0;
   AC_L11_VISIBLE_GROUP_FILES_EXPECTED = 0;
   AC_L11_WRITE_FAILED_COUNT = 0;
   AC_L11_GENERATED_UTC = "not_available";

   string summary = AC_L11ReadSmallTextFile(AC_L11SummaryPath(), 50000);
   if(summary == "") return;

   string status = AC_L11KvValue(summary, "status", "pending");
   string selection_runtime = AC_L11KvValue(summary, "selection_runtime", "not_available");
   string trade_permission = AC_L11KvValue(summary, "trade_permission", "not_available");
   string entry_signal = AC_L11KvValue(summary, "entry_signal", "not_available");
   string execution = AC_L11KvValue(summary, "execution", "not_available");
   AC_L11_RANKING_GROUP_COUNT = AC_L11KvInt(summary, "ranking_group_count", 0);
   AC_L11_RANKED_SYMBOL_COUNT = AC_L11KvInt(summary, "ranked_symbol_count", 0);
   AC_L11_NOT_RANKABLE_TAXONOMY_COUNT = AC_L11KvInt(summary, "not_rankable_taxonomy_count", 0);
   AC_L11_NOT_RANKABLE_QUALITY_COUNT = AC_L11KvInt(summary, "not_rankable_quality_count", 0);
   AC_L11_RISK_REVIEW_COUNT = AC_L11KvInt(summary, "risk_review_count", 0);
   AC_L11_TOP5_GROUP_COUNT = AC_L11KvInt(summary, "top5_group_count", 0);
   AC_L11_VISIBLE_GROUP_FILES_WRITTEN = AC_L11KvInt(summary, "visible_group_files_written", 0);
   AC_L11_VISIBLE_GROUP_FILES_EXPECTED = AC_L11KvInt(summary, "visible_group_files_expected", 0);
   AC_L11_WRITE_FAILED_COUNT = AC_L11KvInt(summary, "write_failed_count", 0);
   AC_L11_GENERATED_UTC = AC_L11KvValue(summary, "generated_utc", "not_available");

   bool files_ok = FileIsExist(AC_L11RankedSymbolsPath(), AC_CommonFlag())
      && FileIsExist(AC_L11Top5Path(), AC_CommonFlag())
      && FileIsExist(AC_L11VisibleGroupIndexPath(), AC_CommonFlag())
      && FileIsExist(AC_L11VisibleGroupIndexCsvPath(), AC_CommonFlag());
   bool permission_ok = (selection_runtime == "false" && trade_permission == "false" && entry_signal == "false" && execution == "false");
   bool counts_ok = (AC_L11_RANKING_GROUP_COUNT > 0 && AC_L11_RANKED_SYMBOL_COUNT > 0);
   bool visible_ok = (AC_L11_VISIBLE_GROUP_FILES_EXPECTED > 0 && AC_L11_VISIBLE_GROUP_FILES_WRITTEN == AC_L11_VISIBLE_GROUP_FILES_EXPECTED);
   bool writes_ok = (AC_L11_WRITE_FAILED_COUNT == 0);

   if(status == "accepted" && files_ok && permission_ok && counts_ok && visible_ok && writes_ok)
   {
      AC_L11_ACCEPTED = true;
      AC_L11_STATUS = "Accepted";
      AC_L11_VALIDATION_STATUS = "Accepted";
      AC_L11_VALIDATION_REASON = "summary/files/counts/visible_selection_desk_groups/permission all accepted";
      AC_L11_MAIN_BLOCKER = "none";
      return;
   }

   AC_L11_STATUS = "L11 symbol ranking degraded";
   AC_L11_VALIDATION_STATUS = "Degraded";
   AC_L11_VALIDATION_REASON = "status=" + status
      + ";files_ok=" + (files_ok ? "true" : "false")
      + ";counts_ok=" + (counts_ok ? "true" : "false")
      + ";visible_ok=" + (visible_ok ? "true" : "false")
      + ";permission_ok=" + (permission_ok ? "true" : "false")
      + ";writes_ok=" + (writes_ok ? "true" : "false");
   AC_L11_MAIN_BLOCKER = AC_L11_VALIDATION_REASON;
}

string AC_Layer11BoardSection()
{
   AC_L11RefreshSummary();
   string text = "";
   text += "\r\nLAYER 11 - SYMBOL RANKING INSIDE RANKING GROUP\r\n";
   text += "----------------------------------------\r\n";
   text += "Status:                     " + AC_L11_STATUS + "\r\n";
   text += "Owner:                      Runtime 5 - Taxonomy / Ranking Group Owner\r\n";
   text += "Input Source:                L10 taxonomy + L6-L9 surface scores\r\n";
   text += "Ranking Groups:             " + IntegerToString(AC_L11_RANKING_GROUP_COUNT) + "\r\n";
   text += "Rankable Symbols:           " + IntegerToString(AC_L11_RANKED_SYMBOL_COUNT) + "\r\n";
   text += "Top 5 per ranking_group:    " + (AC_L11_TOP5_GROUP_COUNT > 0 ? "available" : "pending") + "\r\n";
   text += "Selection Desk Groups:      " + AC_SelectionGroupsFolder() + "\r\n";
   text += "Visible Group Files:        " + IntegerToString(AC_L11_VISIBLE_GROUP_FILES_WRITTEN) + " / " + IntegerToString(AC_L11_VISIBLE_GROUP_FILES_EXPECTED) + "\r\n";
   text += "Unknown ranking_group:      " + IntegerToString(AC_L11_NOT_RANKABLE_TAXONOMY_COUNT) + "\r\n";
   text += "Risk Review Symbols:        " + IntegerToString(AC_L11_RISK_REVIEW_COUNT) + "\r\n";
   text += "Main Blocker:               " + AC_L11_MAIN_BLOCKER + "\r\n";
   text += "Selection Runtime:          FALSE\r\n";
   text += "Trade Permission:           FALSE\r\n";
   text += "Entry Signal:               FALSE\r\n";
   text += "Execution:                  FALSE\r\n";
   return text;
}

string AC_L11CsvField(string line, int index, string fallback = "not_available")
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

string AC_L11RankedCsvLineForSymbol(const string symbol)
{
   string csv = AC_L11ReadSmallTextFile(AC_L11RankedSymbolsPath(), 1000000);
   if(csv == "") return "";
   string lines[];
   ushort separator = StringGetCharacter("\n", 0);
   int count = StringSplit(csv, separator, lines);
   for(int i = 1; i < count; i++)
   {
      string line = lines[i];
      StringReplace(line, "\r", "");
      if(AC_L11CsvField(line, 7, "") == symbol)
         return line;
   }
   return "";
}

string AC_Layer11DossierSection(const string symbol)
{
   AC_L11RefreshSummary();
   string row = AC_L11RankedCsvLineForSymbol(symbol);
   string text = "";
   text += "\r\nLAYER 11 - SYMBOL RANKING INSIDE RANKING GROUP\r\n";
   text += "----------------------------------------\r\n";
   text += "Status: " + AC_L11_STATUS + "\r\n";
   text += "Owner: Runtime 5 - Taxonomy / Ranking Group Owner\r\n";
   if(row == "")
   {
      text += "Rank State: not_available\r\n";
      text += "Reason: L11 ranked_symbols_by_group.csv missing this symbol or L11 not accepted yet\r\n";
   }
   else
   {
      text += "Ranking Group: " + AC_L11CsvField(row, 0) + "\r\n";
      text += "Ranking Group Rank: #" + AC_L11CsvField(row, 5) + " / " + AC_L11CsvField(row, 6) + "\r\n";
      text += "Group Percentile: " + AC_L11CsvField(row, 14) + "\r\n";
      text += "In Top 5 per ranking_group: " + AC_L11CsvField(row, 20) + "\r\n";
      text += "Leader Flag: " + AC_L11CsvField(row, 16) + "\r\n";
      text += "Backup Flag: " + AC_L11CsvField(row, 17) + "\r\n";
      text += "L11 Group Score: " + AC_L11CsvField(row, 13) + "\r\n";
      text += "Rank State: " + AC_L11CsvField(row, 15) + "\r\n";
      text += "Components:\r\n";
      text += "  L6 Cost/Friction: " + AC_L11CsvField(row, 31) + " state=" + AC_L11CsvField(row, 33) + "\r\n";
      text += "  L7 Session: " + AC_L11CsvField(row, 34) + " state=" + AC_L11CsvField(row, 36) + "\r\n";
      text += "  L8 Movement: " + AC_L11CsvField(row, 37) + " state=" + AC_L11CsvField(row, 39) + "\r\n";
      text += "  L9 Structure: " + AC_L11CsvField(row, 40) + " state=" + AC_L11CsvField(row, 42) + "\r\n";
      if(StringFind(AC_L11CsvField(row, 15), "not_rankable") >= 0)
         text += "Not Rankable Reason: " + AC_L11CsvField(row, 22) + "\r\n";
      else
         text += "Reason: " + AC_L11CsvField(row, 44) + "\r\n";
   }
   text += "Meaning: intra_group_inspection_priority_only\r\n";
   text += "Selection Runtime: FALSE\r\n";
   text += "Trade Permission: FALSE\r\n";
   text += "Entry Signal: FALSE\r\n";
   text += "Execution: FALSE\r\n";
   return text;
}

string AC_Layer11WorkbenchSection()
{
   AC_L11RefreshSummary();
   string text = "";
   text += "\r\nL11_SYMBOL_RANKING_INSIDE_GROUP\r\n";
   text += "----------------------------------------\r\n";
   text += "schema_name=l11_symbol_ranking_inside_group\r\n";
   text += "schema_version=1\r\n";
   text += "owner_name=Runtime 5 - Taxonomy / Ranking Group Owner\r\n";
   text += "layer_id=11\r\n";
   text += "input_taxonomy_source=L10\r\n";
   text += "input_surface_layers=L6,L7,L8,L9\r\n";
   text += "component_weights=L6:25,L7:20,L8:25,L9:30\r\n";
   text += "status=" + AC_L11_STATUS + "\r\n";
   text += "validation_status=" + AC_L11_VALIDATION_STATUS + "\r\n";
   text += "validation_reason=" + AC_L11_VALIDATION_REASON + "\r\n";
   text += "ranking_group_count=" + IntegerToString(AC_L11_RANKING_GROUP_COUNT) + "\r\n";
   text += "ranked_symbol_count=" + IntegerToString(AC_L11_RANKED_SYMBOL_COUNT) + "\r\n";
   text += "not_rankable_taxonomy_count=" + IntegerToString(AC_L11_NOT_RANKABLE_TAXONOMY_COUNT) + "\r\n";
   text += "risk_review_count=" + IntegerToString(AC_L11_RISK_REVIEW_COUNT) + "\r\n";
   text += "top5_group_count=" + IntegerToString(AC_L11_TOP5_GROUP_COUNT) + "\r\n";
   text += "visible_selection_desk_groups_written=" + IntegerToString(AC_L11_VISIBLE_GROUP_FILES_WRITTEN) + "\r\n";
   text += "visible_selection_desk_groups_expected=" + IntegerToString(AC_L11_VISIBLE_GROUP_FILES_EXPECTED) + "\r\n";
   text += "summary_path=" + AC_L11SummaryPath() + "\r\n";
   text += "ranked_symbols_by_group_path=" + AC_L11RankedSymbolsPath() + "\r\n";
   text += "visible_group_index_path=" + AC_L11VisibleGroupIndexPath() + "\r\n";
   text += "selection_runtime=false\r\n";
   text += "trade_permission=false\r\n";
   text += "entry_signal=false\r\n";
   text += "execution=false\r\n";
   return text;
}

#endif
