#ifndef AC_LAYER13_DYNAMIC_GROUP_SELECTION_RENDERER_MQH
#define AC_LAYER13_DYNAMIC_GROUP_SELECTION_RENDERER_MQH

// Runtime 7 render-only surface for Layer 13 Dynamic Ranking Group Selection.
// Reads worker L13 summary and CSV outputs only.
// Must not rank symbols, build candidates, run correlation, build Global Top 10, permit, alert, or execute.

static string AC_L13_STATUS = "Pending L13 dynamic group selection";
static string AC_L13_VALIDATION_STATUS = "Pending";
static string AC_L13_VALIDATION_REASON = "l13_group_selection_summary.txt missing or not accepted";
static string AC_L13_MAIN_BLOCKER = "l13 summary has not been accepted yet";
static bool   AC_L13_ACCEPTED = false;
static int    AC_L13_VALID_GROUP_COUNT = 0;
static int    AC_L13_SELECTED_GROUP_COUNT = 0;
static int    AC_L13_REJECTED_GROUP_COUNT = 0;
static int    AC_L13_WRITE_FAILED_COUNT = 0;
static string AC_L13_FALLBACK_USED = "false";
static string AC_L13_FALLBACK_REASON = "not_required";
static string AC_L13_SELECTION_QUALITY_TIER = "not_available";
static string AC_L13_MARKET_CONDITION_NOTE = "not_available";
static string AC_L13_TOP_SELECTED_GROUP = "not_available";
static string AC_L13_GENERATED_UTC = "not_available";

string AC_L13LayerFolder(){ return AC_ExternalWorkerOutboxFolder() + "\\Layers\\Layer_13_Dynamic_Ranking_Group_Selection"; }
string AC_L13SummaryPath(){ return AC_L13LayerFolder() + "\\l13_group_selection_summary.txt"; }
string AC_L13SelectedCsvPath(){ return AC_L13LayerFolder() + "\\l13_selected_ranking_groups.csv"; }
string AC_L13RejectedCsvPath(){ return AC_L13LayerFolder() + "\\l13_rejected_ranking_groups.csv"; }
string AC_L13SelectionDeskIndexPath(){ return AC_SelectionGroupsFolder() + "\\00_Selected_Ranking_Groups.txt"; }
string AC_L13SelectionDeskIndexCsvPath(){ return AC_SelectionGroupsFolder() + "\\00_Selected_Ranking_Groups.csv"; }

string AC_L13ReadSmallTextFile(const string path, const int max_chars = 50000)
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

string AC_L13KvValue(const string text, const string key, const string fallback = "not_available")
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

int AC_L13KvInt(const string text, const string key, const int fallback = 0)
{
   string value = AC_L13KvValue(text, key, "");
   if(value == "") return fallback;
   return (int)StringToInteger(value);
}

void AC_L13RefreshSummary()
{
   AC_L13_ACCEPTED = false;
   AC_L13_STATUS = "Pending L13 dynamic group selection";
   AC_L13_VALIDATION_STATUS = "Pending";
   AC_L13_VALIDATION_REASON = "l13_group_selection_summary.txt missing or unreadable";
   AC_L13_MAIN_BLOCKER = AC_L13_VALIDATION_REASON;
   AC_L13_VALID_GROUP_COUNT = 0;
   AC_L13_SELECTED_GROUP_COUNT = 0;
   AC_L13_REJECTED_GROUP_COUNT = 0;
   AC_L13_WRITE_FAILED_COUNT = 0;
   AC_L13_FALLBACK_USED = "false";
   AC_L13_FALLBACK_REASON = "not_required";
   AC_L13_SELECTION_QUALITY_TIER = "not_available";
   AC_L13_MARKET_CONDITION_NOTE = "not_available";
   AC_L13_TOP_SELECTED_GROUP = "not_available";
   AC_L13_GENERATED_UTC = "not_available";

   string summary = AC_L13ReadSmallTextFile(AC_L13SummaryPath(), 50000);
   if(summary == "") return;

   string status = AC_L13KvValue(summary, "status", "pending");
   string selection_runtime = AC_L13KvValue(summary, "selection_runtime", "not_available");
   string trade_permission = AC_L13KvValue(summary, "trade_permission", "not_available");
   string entry_signal = AC_L13KvValue(summary, "entry_signal", "not_available");
   string execution = AC_L13KvValue(summary, "execution", "not_available");
   AC_L13_VALID_GROUP_COUNT = AC_L13KvInt(summary, "valid_group_count", 0);
   AC_L13_SELECTED_GROUP_COUNT = AC_L13KvInt(summary, "selected_ranking_group_count", 0);
   AC_L13_REJECTED_GROUP_COUNT = AC_L13KvInt(summary, "rejected_ranking_group_count", 0);
   AC_L13_WRITE_FAILED_COUNT = AC_L13KvInt(summary, "write_failed_count", 0);
   AC_L13_FALLBACK_USED = AC_L13KvValue(summary, "fallback_used", "false");
   AC_L13_FALLBACK_REASON = AC_L13KvValue(summary, "fallback_reason", "not_required");
   AC_L13_SELECTION_QUALITY_TIER = AC_L13KvValue(summary, "selection_quality_tier", "not_available");
   AC_L13_MARKET_CONDITION_NOTE = AC_L13KvValue(summary, "market_condition_note", "not_available");
   AC_L13_TOP_SELECTED_GROUP = AC_L13KvValue(summary, "top_selected_group", "not_available");
   AC_L13_GENERATED_UTC = AC_L13KvValue(summary, "generated_utc", "not_available");

   bool files_ok = FileIsExist(AC_L13SelectedCsvPath(), AC_CommonFlag())
      && FileIsExist(AC_L13RejectedCsvPath(), AC_CommonFlag())
      && FileIsExist(AC_L13SelectionDeskIndexPath(), AC_CommonFlag())
      && FileIsExist(AC_L13SelectionDeskIndexCsvPath(), AC_CommonFlag());
   bool permission_ok = (selection_runtime == "false" && trade_permission == "false" && entry_signal == "false" && execution == "false");
   bool counts_ok = (AC_L13_SELECTED_GROUP_COUNT > 0);
   bool writes_ok = (AC_L13_WRITE_FAILED_COUNT == 0);

   if(status == "accepted" && files_ok && permission_ok && counts_ok && writes_ok)
   {
      AC_L13_ACCEPTED = true;
      AC_L13_STATUS = "Accepted";
      AC_L13_VALIDATION_STATUS = "Accepted";
      AC_L13_VALIDATION_REASON = "summary/files/counts/permission all accepted";
      AC_L13_MAIN_BLOCKER = "none";
      return;
   }

   AC_L13_STATUS = "L13 dynamic group selection degraded";
   AC_L13_VALIDATION_STATUS = "Degraded";
   AC_L13_VALIDATION_REASON = "status=" + status
      + ";files_ok=" + (files_ok ? "true" : "false")
      + ";counts_ok=" + (counts_ok ? "true" : "false")
      + ";permission_ok=" + (permission_ok ? "true" : "false")
      + ";writes_ok=" + (writes_ok ? "true" : "false");
   AC_L13_MAIN_BLOCKER = AC_L13_VALIDATION_REASON;
}

string AC_Layer13BoardSection()
{
   AC_L13RefreshSummary();
   string text = "";
   text += "\r\nLAYER 13 - DYNAMIC RANKING GROUP SELECTION\r\n";
   text += "----------------------------------------\r\n";
   text += "Status:                     " + AC_L13_STATUS + "\r\n";
   text += "Owner:                      Runtime 5 - Taxonomy / Ranking Group Owner\r\n";
   text += "Input Source:               L12 group heat quality\r\n";
   text += "Valid Groups:               " + IntegerToString(AC_L13_VALID_GROUP_COUNT) + "\r\n";
   text += "Selected Groups:            " + IntegerToString(AC_L13_SELECTED_GROUP_COUNT) + "\r\n";
   text += "Rejected Groups:            " + IntegerToString(AC_L13_REJECTED_GROUP_COUNT) + "\r\n";
   text += "Selection Quality:          " + AC_L13_SELECTION_QUALITY_TIER + "\r\n";
   text += "Fallback Used:              " + AC_L13_FALLBACK_USED + "\r\n";
   text += "Fallback Reason:            " + AC_L13_FALLBACK_REASON + "\r\n";
   text += "Market Condition Note:      " + AC_L13_MARKET_CONDITION_NOTE + "\r\n";
   text += "Top Selected Group:         " + AC_L13_TOP_SELECTED_GROUP + "\r\n";
   text += "Selection Runtime:          FALSE\r\n";
   text += "Trade Permission:           FALSE\r\n";
   text += "Entry Signal:               FALSE\r\n";
   text += "Execution:                  FALSE\r\n";
   text += "Main Blocker:               " + AC_L13_MAIN_BLOCKER + "\r\n";
   return text;
}

string AC_L13CsvField(string line, int index, string fallback = "not_available")
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

string AC_L13CsvLineForGroup(const string ranking_group)
{
   string csv = AC_L13ReadSmallTextFile(AC_L13SelectedCsvPath(), 1000000);
   if(csv != "")
   {
      string lines[];
      ushort separator = StringGetCharacter("\n", 0);
      int count = StringSplit(csv, separator, lines);
      for(int i = 1; i < count; i++)
      {
         string line = lines[i];
         StringReplace(line, "\r", "");
         if(AC_L13CsvField(line, 1, "") == ranking_group) return line;
      }
   }
   csv = AC_L13ReadSmallTextFile(AC_L13RejectedCsvPath(), 1000000);
   if(csv == "") return "";
   string rej_lines[];
   ushort sep2 = StringGetCharacter("\n", 0);
   int rej_count = StringSplit(csv, sep2, rej_lines);
   for(int j = 1; j < rej_count; j++)
   {
      string line2 = rej_lines[j];
      StringReplace(line2, "\r", "");
      if(AC_L13CsvField(line2, 0, "") == ranking_group) return "REJECTED|" + line2;
   }
   return "";
}

string AC_Layer13DossierSection(const string symbol)
{
   AC_L13RefreshSummary();
   string l11_row = AC_L11RankedCsvLineForSymbol(symbol);
   string ranking_group = l11_row == "" ? "not_available" : AC_L11CsvField(l11_row, 0);
   string row = ranking_group == "not_available" ? "" : AC_L13CsvLineForGroup(ranking_group);
   bool rejected = StringFind(row, "REJECTED|") == 0;
   if(rejected) row = StringSubstr(row, 9);
   string text = "";
   text += "\r\nLAYER 13 - DYNAMIC RANKING GROUP SELECTION\r\n";
   text += "----------------------------------------\r\n";
   text += "Status: " + AC_L13_STATUS + "\r\n";
   text += "Owner: Runtime 5 - Taxonomy / Ranking Group Owner\r\n";
   if(row == "")
   {
      text += "Ranking Group: " + ranking_group + "\r\n";
      text += "Group Selection State: not_available\r\n";
      text += "Reason: L13 selected/rejected row missing for this symbol's ranking_group or L13 not accepted yet\r\n";
   }
   else if(rejected)
   {
      text += "Ranking Group: " + AC_L13CsvField(row, 0) + "\r\n";
      text += "Group Selection State: " + AC_L13CsvField(row, 7) + "\r\n";
      text += "Selection Quality Tier: " + AC_L13CsvField(row, 6) + "\r\n";
      text += "Group Selection Score: " + AC_L13CsvField(row, 5) + "\r\n";
      text += "Rejected Reason: " + AC_L13CsvField(row, 9) + "\r\n";
      text += "Fallback Used: " + AC_L13_FALLBACK_USED + "\r\n";
      text += "Fallback Reason: " + AC_L13_FALLBACK_REASON + "\r\n";
   }
   else
   {
      text += "Ranking Group: " + AC_L13CsvField(row, 1) + "\r\n";
      text += "Group Selection State: " + AC_L13CsvField(row, 6) + "\r\n";
      text += "Group Selection Rank: #" + AC_L13CsvField(row, 0) + " / " + IntegerToString(AC_L13_SELECTED_GROUP_COUNT) + "\r\n";
      text += "Selection Quality Tier: " + AC_L13CsvField(row, 7) + "\r\n";
      text += "Group Selection Score: " + AC_L13CsvField(row, 8) + "\r\n";
      text += "Selected Reason: " + AC_L13CsvField(row, 20) + "\r\n";
      text += "Fallback Used: " + AC_L13CsvField(row, 21) + "\r\n";
      text += "Fallback Reason: " + AC_L13CsvField(row, 22) + "\r\n";
      text += "Market Condition Note: " + AC_L13CsvField(row, 23) + "\r\n";
   }
   text += "Meaning: group_selected_for_candidate_sourcing_attention_only\r\n";
   text += "Selection Runtime: FALSE\r\n";
   text += "Trade Permission: FALSE\r\n";
   text += "Entry Signal: FALSE\r\n";
   text += "Execution: FALSE\r\n";
   return text;
}

string AC_Layer13WorkbenchSection()
{
   AC_L13RefreshSummary();
   string text = "";
   text += "\r\nL13_DYNAMIC_RANKING_GROUP_SELECTION\r\n";
   text += "----------------------------------------\r\n";
   text += "schema_name=l13_dynamic_ranking_group_selection\r\n";
   text += "schema_version=1\r\n";
   text += "owner_name=Runtime 5 - Taxonomy / Ranking Group Owner\r\n";
   text += "layer_id=13\r\n";
   text += "input_source=L12\r\n";
   text += "status=" + AC_L13_STATUS + "\r\n";
   text += "validation_status=" + AC_L13_VALIDATION_STATUS + "\r\n";
   text += "validation_reason=" + AC_L13_VALIDATION_REASON + "\r\n";
   text += "valid_group_count=" + IntegerToString(AC_L13_VALID_GROUP_COUNT) + "\r\n";
   text += "selected_ranking_group_count=" + IntegerToString(AC_L13_SELECTED_GROUP_COUNT) + "\r\n";
   text += "rejected_ranking_group_count=" + IntegerToString(AC_L13_REJECTED_GROUP_COUNT) + "\r\n";
   text += "fallback_used=" + AC_L13_FALLBACK_USED + "\r\n";
   text += "fallback_reason=" + AC_L13_FALLBACK_REASON + "\r\n";
   text += "selection_quality_tier=" + AC_L13_SELECTION_QUALITY_TIER + "\r\n";
   text += "market_condition_note=" + AC_L13_MARKET_CONDITION_NOTE + "\r\n";
   text += "top_selected_group=" + AC_L13_TOP_SELECTED_GROUP + "\r\n";
   text += "summary_path=" + AC_L13SummaryPath() + "\r\n";
   text += "selected_path=" + AC_L13SelectedCsvPath() + "\r\n";
   text += "selection_desk_selected_path=" + AC_L13SelectionDeskIndexPath() + "\r\n";
   text += "selection_runtime=false\r\n";
   text += "trade_permission=false\r\n";
   text += "entry_signal=false\r\n";
   text += "execution=false\r\n";
   return text;
}

#endif
