#ifndef AC_LAYER12_GROUP_HEAT_QUALITY_RENDERER_MQH
#define AC_LAYER12_GROUP_HEAT_QUALITY_RENDERER_MQH

// Runtime 7 render-only surface for Layer 12 Ranking Group Heat / Quality.
// Reads worker L12 summary and canonical layer summary index outputs only.
// Must not rank symbols, select groups, build candidates, build Global Top 10, permit, alert, or execute.

static string AC_L12_STATUS = "Pending L12 group heat quality";
static string AC_L12_VALIDATION_STATUS = "Pending";
static string AC_L12_VALIDATION_REASON = "l12_group_heat_quality_summary.txt missing or not accepted";
static string AC_L12_MAIN_BLOCKER = "l12 summary has not been accepted yet";
static bool   AC_L12_ACCEPTED = false;
static int    AC_L12_GROUP_COUNT = 0;
static int    AC_L12_ACCEPTED_GROUP_COUNT = 0;
static int    AC_L12_THIN_GROUP_COUNT = 0;
static int    AC_L12_RISK_REVIEW_GROUP_COUNT = 0;
static int    AC_L12_WRITE_FAILED_COUNT = 0;
static string AC_L12_TOP_HEAT_GROUP = "not_available";
static string AC_L12_TOP_QUALITY_GROUP = "not_available";
static string AC_L12_TOP_STRENGTH_GROUP = "not_available";
static string AC_L12_GENERATED_UTC = "not_available";

string AC_L12LayerFolder(){ return AC_ExternalWorkerOutboxFolder() + "\\Layers\\Layer_12_Ranking_Group_Heat_Quality"; }
string AC_L12SummaryPath(){ return AC_L12LayerFolder() + "\\l12_group_heat_quality_summary.txt"; }
string AC_L12HeatCsvPath(){ return AC_L12LayerFolder() + "\\l12_group_heat_quality.csv"; }
string AC_L12CanonicalSummaryFolder(){ return AC_SelectionDeskFolder() + "\\91_Layer_Summaries\\L12_Group_Heat_Quality"; }
string AC_L12SelectionDeskIndexPath(){ return AC_L12CanonicalSummaryFolder() + "\\00_Group_Heat_Quality_Index.txt"; }
string AC_L12SelectionDeskIndexCsvPath(){ return AC_L12CanonicalSummaryFolder() + "\\00_Group_Heat_Quality_Index.csv"; }

string AC_L12ReadSmallTextFile(const string path, const int max_chars = 50000)
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

string AC_L12KvValue(const string text, const string key, const string fallback = "not_available")
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

int AC_L12KvInt(const string text, const string key, const int fallback = 0)
{
   string value = AC_L12KvValue(text, key, "");
   if(value == "") return fallback;
   return (int)StringToInteger(value);
}

void AC_L12RefreshSummary()
{
   AC_L12_ACCEPTED = false;
   AC_L12_STATUS = "Pending L12 group heat quality";
   AC_L12_VALIDATION_STATUS = "Pending";
   AC_L12_VALIDATION_REASON = "l12_group_heat_quality_summary.txt missing or unreadable";
   AC_L12_MAIN_BLOCKER = AC_L12_VALIDATION_REASON;
   AC_L12_GROUP_COUNT = 0;
   AC_L12_ACCEPTED_GROUP_COUNT = 0;
   AC_L12_THIN_GROUP_COUNT = 0;
   AC_L12_RISK_REVIEW_GROUP_COUNT = 0;
   AC_L12_WRITE_FAILED_COUNT = 0;
   AC_L12_TOP_HEAT_GROUP = "not_available";
   AC_L12_TOP_QUALITY_GROUP = "not_available";
   AC_L12_TOP_STRENGTH_GROUP = "not_available";
   AC_L12_GENERATED_UTC = "not_available";

   string summary = AC_L12ReadSmallTextFile(AC_L12SummaryPath(), 50000);
   if(summary == "") return;

   string status = AC_L12KvValue(summary, "status", "pending");
   string selection_runtime = AC_L12KvValue(summary, "selection_runtime", "not_available");
   string trade_permission = AC_L12KvValue(summary, "trade_permission", "not_available");
   string entry_signal = AC_L12KvValue(summary, "entry_signal", "not_available");
   string execution = AC_L12KvValue(summary, "execution", "not_available");
   AC_L12_GROUP_COUNT = AC_L12KvInt(summary, "ranking_group_count", 0);
   AC_L12_ACCEPTED_GROUP_COUNT = AC_L12KvInt(summary, "accepted_group_count", 0);
   AC_L12_THIN_GROUP_COUNT = AC_L12KvInt(summary, "thin_group_count", 0);
   AC_L12_RISK_REVIEW_GROUP_COUNT = AC_L12KvInt(summary, "risk_review_group_count", 0);
   AC_L12_WRITE_FAILED_COUNT = AC_L12KvInt(summary, "write_failed_count", 0);
   AC_L12_TOP_HEAT_GROUP = AC_L12KvValue(summary, "top_heat_group", "not_available");
   AC_L12_TOP_QUALITY_GROUP = AC_L12KvValue(summary, "top_quality_group", "not_available");
   AC_L12_TOP_STRENGTH_GROUP = AC_L12KvValue(summary, "top_strength_group", "not_available");
   AC_L12_GENERATED_UTC = AC_L12KvValue(summary, "generated_utc", "not_available");

   bool files_ok = FileIsExist(AC_L12HeatCsvPath(), AC_CommonFlag())
      && FileIsExist(AC_L12SelectionDeskIndexPath(), AC_CommonFlag())
      && FileIsExist(AC_L12SelectionDeskIndexCsvPath(), AC_CommonFlag());
   bool permission_ok = (selection_runtime == "false" && trade_permission == "false" && entry_signal == "false" && execution == "false");
   bool counts_ok = (AC_L12_GROUP_COUNT > 0);
   bool writes_ok = (AC_L12_WRITE_FAILED_COUNT == 0);

   if(status == "accepted" && files_ok && permission_ok && counts_ok && writes_ok)
   {
      AC_L12_ACCEPTED = true;
      AC_L12_STATUS = "Accepted";
      AC_L12_VALIDATION_STATUS = "Accepted";
      AC_L12_VALIDATION_REASON = "summary/files/counts/canonical_layer_summary_index/permission all accepted";
      AC_L12_MAIN_BLOCKER = "none";
      return;
   }

   AC_L12_STATUS = "L12 group heat quality degraded";
   AC_L12_VALIDATION_STATUS = "Degraded";
   AC_L12_VALIDATION_REASON = "status=" + status
      + ";files_ok=" + (files_ok ? "true" : "false")
      + ";counts_ok=" + (counts_ok ? "true" : "false")
      + ";permission_ok=" + (permission_ok ? "true" : "false")
      + ";writes_ok=" + (writes_ok ? "true" : "false");
   AC_L12_MAIN_BLOCKER = AC_L12_VALIDATION_REASON;
}

string AC_Layer12BoardSection()
{
   AC_L12RefreshSummary();
   string text = "";
   text += "\r\nLAYER 12 - RANKING GROUP HEAT / QUALITY\r\n";
   text += "----------------------------------------\r\n";
   text += "Status:                     " + AC_L12_STATUS + "\r\n";
   text += "Owner:                      Runtime 5 - Taxonomy / Ranking Group Owner\r\n";
   text += "Input Source:               L11 guarded ranked groups + Top 5 per ranking_group\r\n";
   text += "Ranking Groups Scored:      " + IntegerToString(AC_L12_GROUP_COUNT) + "\r\n";
   text += "Accepted Groups:            " + IntegerToString(AC_L12_ACCEPTED_GROUP_COUNT) + "\r\n";
   text += "Thin Groups:                " + IntegerToString(AC_L12_THIN_GROUP_COUNT) + "\r\n";
   text += "Risk Review Groups:         " + IntegerToString(AC_L12_RISK_REVIEW_GROUP_COUNT) + "\r\n";
   text += "Top Heat Group:             " + AC_L12_TOP_HEAT_GROUP + "\r\n";
   text += "Top Quality Group:          " + AC_L12_TOP_QUALITY_GROUP + "\r\n";
   text += "Top Strength Group:         " + AC_L12_TOP_STRENGTH_GROUP + "\r\n";
   text += "Selection Runtime:          FALSE\r\n";
   text += "Trade Permission:           FALSE\r\n";
   text += "Entry Signal:               FALSE\r\n";
   text += "Execution:                  FALSE\r\n";
   text += "Main Blocker:               " + AC_L12_MAIN_BLOCKER + "\r\n";
   return text;
}

string AC_L12CsvField(string line, int index, string fallback = "not_available")
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

string AC_L12CsvLineForGroup(const string ranking_group)
{
   string csv = AC_L12ReadSmallTextFile(AC_L12HeatCsvPath(), 1000000);
   if(csv == "") return "";
   string lines[];
   ushort separator = StringGetCharacter("\n", 0);
   int count = StringSplit(csv, separator, lines);
   for(int i = 1; i < count; i++)
   {
      string line = lines[i];
      StringReplace(line, "\r", "");
      if(AC_L12CsvField(line, 0, "") == ranking_group)
         return line;
   }
   return "";
}

string AC_Layer12DossierSection(const string symbol)
{
   AC_L12RefreshSummary();
   string l11_row = AC_L11RankedCsvLineForSymbol(symbol);
   string ranking_group = l11_row == "" ? "not_available" : AC_L11CsvField(l11_row, 0);
   string row = ranking_group == "not_available" ? "" : AC_L12CsvLineForGroup(ranking_group);
   string text = "";
   text += "\r\nLAYER 12 - RANKING GROUP HEAT / QUALITY\r\n";
   text += "----------------------------------------\r\n";
   text += "Status: " + AC_L12_STATUS + "\r\n";
   text += "Owner: Runtime 5 - Taxonomy / Ranking Group Owner\r\n";
   if(row == "")
   {
      text += "Ranking Group: " + ranking_group + "\r\n";
      text += "Group State: not_available\r\n";
      text += "Reason: L12 heat row missing for this symbol's ranking_group or L12 not accepted yet\r\n";
   }
   else
   {
      text += "Ranking Group: " + AC_L12CsvField(row, 0) + "\r\n";
      text += "Group Heat Rank: #" + AC_L12CsvField(row, 6) + " / " + IntegerToString(AC_L12_GROUP_COUNT) + "\r\n";
      text += "Group Quality Rank: #" + AC_L12CsvField(row, 7) + " / " + IntegerToString(AC_L12_GROUP_COUNT) + "\r\n";
      text += "Group Strength Rank: #" + AC_L12CsvField(row, 8) + " / " + IntegerToString(AC_L12_GROUP_COUNT) + "\r\n";
      text += "Group Heat: " + AC_L12CsvField(row, 9) + "\r\n";
      text += "Group Quality: " + AC_L12CsvField(row, 10) + "\r\n";
      text += "Group Strength: " + AC_L12CsvField(row, 11) + "\r\n";
      text += "Group State: " + AC_L12CsvField(row, 5) + "\r\n";
      text += "Top Symbol: " + AC_L12CsvField(row, 18) + "\r\n";
      text += "Top Symbol Score: " + AC_L12CsvField(row, 19) + "\r\n";
      text += "Top 5 Avg Score: " + AC_L12CsvField(row, 20) + "\r\n";
      text += "Backup Depth: " + AC_L12CsvField(row, 17) + "\r\n";
      text += "Thin Group: " + AC_L12CsvField(row, 27) + "\r\n";
      text += "Risk Review Count: " + AC_L12CsvField(row, 15) + "\r\n";
   }
   text += "Meaning: group_attention_quality_only\r\n";
   text += "Selection Runtime: FALSE\r\n";
   text += "Trade Permission: FALSE\r\n";
   text += "Entry Signal: FALSE\r\n";
   text += "Execution: FALSE\r\n";
   return text;
}

string AC_Layer12WorkbenchSection()
{
   AC_L12RefreshSummary();
   string text = "";
   text += "\r\nL12_RANKING_GROUP_HEAT_QUALITY\r\n";
   text += "----------------------------------------\r\n";
   text += "schema_name=l12_ranking_group_heat_quality\r\n";
   text += "schema_version=1\r\n";
   text += "owner_name=Runtime 5 - Taxonomy / Ranking Group Owner\r\n";
   text += "layer_id=12\r\n";
   text += "input_source=L11_guarded\r\n";
   text += "status=" + AC_L12_STATUS + "\r\n";
   text += "validation_status=" + AC_L12_VALIDATION_STATUS + "\r\n";
   text += "validation_reason=" + AC_L12_VALIDATION_REASON + "\r\n";
   text += "ranking_group_count=" + IntegerToString(AC_L12_GROUP_COUNT) + "\r\n";
   text += "accepted_group_count=" + IntegerToString(AC_L12_ACCEPTED_GROUP_COUNT) + "\r\n";
   text += "thin_group_count=" + IntegerToString(AC_L12_THIN_GROUP_COUNT) + "\r\n";
   text += "risk_review_group_count=" + IntegerToString(AC_L12_RISK_REVIEW_GROUP_COUNT) + "\r\n";
   text += "top_heat_group=" + AC_L12_TOP_HEAT_GROUP + "\r\n";
   text += "top_quality_group=" + AC_L12_TOP_QUALITY_GROUP + "\r\n";
   text += "top_strength_group=" + AC_L12_TOP_STRENGTH_GROUP + "\r\n";
   text += "summary_path=" + AC_L12SummaryPath() + "\r\n";
   text += "heat_quality_path=" + AC_L12HeatCsvPath() + "\r\n";
   text += "selection_desk_heat_index_path=" + AC_L12SelectionDeskIndexPath() + "\r\n";
   text += "selection_runtime=false\r\n";
   text += "trade_permission=false\r\n";
   text += "entry_signal=false\r\n";
   text += "execution=false\r\n";
   return text;
}

#endif