#ifndef AC_LAYER10_TAXONOMY_RENDERER_MQH
#define AC_LAYER10_TAXONOMY_RENDERER_MQH

// Runtime 7 render-only surface for Layer 10 Taxonomy / Ranking Group Map.
// Reads only Python worker L10 summary and per-symbol sidecars.
// Must not classify, rank, select, copy Dossiers, permit, alert, or execute.

static string AC_L10_STATUS = "Pending taxonomy sidecar";
static string AC_L10_TRUST_STATE = "Taxonomy Pending";
static string AC_L10_VALIDATION_STATUS = "Pending";
static string AC_L10_VALIDATION_REASON = "taxonomy_summary.txt missing or not accepted";
static string AC_L10_MAIN_BLOCKER = "taxonomy_summary.txt has not been accepted yet";
static bool   AC_L10_ACCEPTED = false;
static int    AC_L10_SYMBOL_COUNT = 0;
static int    AC_L10_ACCEPTED_STRICT_COUNT = 0;
static int    AC_L10_ACCEPTED_PUBLIC_RESEARCH_COUNT = 0;
static int    AC_L10_REVIEW_REQUIRED_COUNT = 0;
static int    AC_L10_UNKNOWN_COUNT = 0;
static int    AC_L10_OMITTED_COUNT = 0;
static int    AC_L10_BLOCKED_COUNT = 0;
static int    AC_L10_CONFLICT_COUNT = 0;
static int    AC_L10_RANK_ALLOWED_COUNT = 0;
static int    AC_L10_SELECTION_ALLOWED_COUNT = 0;
static int    AC_L10_RANKING_GROUP_COUNT = 0;
static int    AC_L10_ACTIVE_GROUP_COUNT = 0;
static int    AC_L10_ACTIVE_WITH_REVIEW_GROUP_COUNT = 0;
static int    AC_L10_REVIEW_ONLY_GROUP_COUNT = 0;
static int    AC_L10_SYMBOL_PATH_INDEX_COUNT = 0;
static int    AC_L10_SYMBOL_SIDECAR_COUNT = 0;
static int    AC_L10_GROUP_MEMBER_CSV_COUNT = 0;
static int    AC_L10_INVALID_UNIVERSE_ROW_COUNT = 0;
static int    AC_L10_WRITE_FAILED_COUNT = 0;
static string AC_L10_GENERATED_UTC = "not_available";
static string AC_L10_SUMMARY_CHECK_KEY = "not_available";

string AC_L10LayerFolder(){ return AC_ExternalWorkerOutboxFolder() + "\\Layers\\Layer_10_Taxonomy_Classification"; }
string AC_L10SummaryPath(){ return AC_L10LayerFolder() + "\\taxonomy_summary.txt"; }
string AC_L10TaxonomySymbolsPath(){ return AC_L10LayerFolder() + "\\taxonomy_symbols.csv"; }
string AC_L10RankingGroupsPath(){ return AC_L10LayerFolder() + "\\ranking_groups.csv"; }
string AC_L10SymbolPathIndexPath(){ return AC_L10LayerFolder() + "\\symbol_path_index.csv"; }
string AC_L10GroupsFolder(){ return AC_L10LayerFolder() + "\\Groups"; }
string AC_L10SymbolTaxonomyFolder(){ return AC_L10LayerFolder() + "\\SymbolTaxonomy"; }
string AC_L10SymbolTaxonomyPath(const string symbol){ return AC_L10SymbolTaxonomyFolder() + "\\" + AC_SanitizePathPart(symbol) + ".txt"; }

string AC_L10ReadSmallTextFile(const string path, const int max_chars = 30000)
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

string AC_L10KvValue(const string text, const string key, const string fallback = "not_available")
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

int AC_L10KvInt(const string text, const string key, const int fallback = 0)
{
   string value = AC_L10KvValue(text, key, "");
   if(value == "") return fallback;
   return (int)StringToInteger(value);
}

string AC_L10BoolText(const bool value){ return value ? "TRUE" : "FALSE"; }
string AC_L10BoolKv(const bool value){ return value ? "true" : "false"; }

void AC_L10RefreshTaxonomySummary()
{
   AC_L10_ACCEPTED = false;
   AC_L10_STATUS = "Pending taxonomy sidecar";
   AC_L10_TRUST_STATE = "Taxonomy Pending";
   AC_L10_VALIDATION_STATUS = "Pending";
   AC_L10_VALIDATION_REASON = "taxonomy_summary.txt missing or unreadable";
   AC_L10_MAIN_BLOCKER = AC_L10_VALIDATION_REASON;
   AC_L10_SYMBOL_COUNT = 0;
   AC_L10_ACCEPTED_STRICT_COUNT = 0;
   AC_L10_ACCEPTED_PUBLIC_RESEARCH_COUNT = 0;
   AC_L10_REVIEW_REQUIRED_COUNT = 0;
   AC_L10_UNKNOWN_COUNT = 0;
   AC_L10_OMITTED_COUNT = 0;
   AC_L10_BLOCKED_COUNT = 0;
   AC_L10_CONFLICT_COUNT = 0;
   AC_L10_RANK_ALLOWED_COUNT = 0;
   AC_L10_SELECTION_ALLOWED_COUNT = 0;
   AC_L10_RANKING_GROUP_COUNT = 0;
   AC_L10_ACTIVE_GROUP_COUNT = 0;
   AC_L10_ACTIVE_WITH_REVIEW_GROUP_COUNT = 0;
   AC_L10_REVIEW_ONLY_GROUP_COUNT = 0;
   AC_L10_SYMBOL_PATH_INDEX_COUNT = 0;
   AC_L10_SYMBOL_SIDECAR_COUNT = 0;
   AC_L10_GROUP_MEMBER_CSV_COUNT = 0;
   AC_L10_INVALID_UNIVERSE_ROW_COUNT = 0;
   AC_L10_WRITE_FAILED_COUNT = 0;
   AC_L10_GENERATED_UTC = "not_available";
   AC_L10_SUMMARY_CHECK_KEY = "not_available";

   string summary = AC_L10ReadSmallTextFile(AC_L10SummaryPath(), 30000);
   if(summary == "") return;

   AC_L10_SYMBOL_COUNT = AC_L10KvInt(summary, "symbol_count", 0);
   AC_L10_ACCEPTED_STRICT_COUNT = AC_L10KvInt(summary, "accepted_strict_count", 0);
   AC_L10_ACCEPTED_PUBLIC_RESEARCH_COUNT = AC_L10KvInt(summary, "accepted_public_research_count", 0);
   AC_L10_REVIEW_REQUIRED_COUNT = AC_L10KvInt(summary, "review_required_count", 0);
   AC_L10_UNKNOWN_COUNT = AC_L10KvInt(summary, "unknown_count", 0);
   AC_L10_OMITTED_COUNT = AC_L10KvInt(summary, "omitted_count", 0);
   AC_L10_BLOCKED_COUNT = AC_L10KvInt(summary, "blocked_count", 0);
   AC_L10_CONFLICT_COUNT = AC_L10KvInt(summary, "conflict_count", 0);
   AC_L10_RANK_ALLOWED_COUNT = AC_L10KvInt(summary, "rank_allowed_count", 0);
   AC_L10_SELECTION_ALLOWED_COUNT = AC_L10KvInt(summary, "selection_allowed_count", 0);
   AC_L10_RANKING_GROUP_COUNT = AC_L10KvInt(summary, "ranking_group_count", 0);
   AC_L10_ACTIVE_GROUP_COUNT = AC_L10KvInt(summary, "active_group_count", 0);
   AC_L10_ACTIVE_WITH_REVIEW_GROUP_COUNT = AC_L10KvInt(summary, "active_with_review_group_count", 0);
   AC_L10_REVIEW_ONLY_GROUP_COUNT = AC_L10KvInt(summary, "review_only_group_count", 0);
   AC_L10_SYMBOL_PATH_INDEX_COUNT = AC_L10KvInt(summary, "symbol_path_index_count", 0);
   AC_L10_SYMBOL_SIDECAR_COUNT = AC_L10KvInt(summary, "symbol_sidecar_count", 0);
   AC_L10_GROUP_MEMBER_CSV_COUNT = AC_L10KvInt(summary, "group_member_csv_count", 0);
   AC_L10_INVALID_UNIVERSE_ROW_COUNT = AC_L10KvInt(summary, "invalid_universe_row_count", 0);
   AC_L10_WRITE_FAILED_COUNT = AC_L10KvInt(summary, "write_failed_count", 0);
   AC_L10_GENERATED_UTC = AC_L10KvValue(summary, "generated_utc", "not_available");
   string selection_runtime = AC_L10KvValue(summary, "selection_runtime", "not_available");
   string trade_permission = AC_L10KvValue(summary, "trade_permission", "not_available");
   string authority = AC_L10KvValue(summary, "authority", "not_available");

   bool files_ok = FileIsExist(AC_L10TaxonomySymbolsPath(), AC_CommonFlag())
      && FileIsExist(AC_L10RankingGroupsPath(), AC_CommonFlag())
      && FileIsExist(AC_L10SymbolPathIndexPath(), AC_CommonFlag());
   bool counts_ok = (AC_L10_SYMBOL_COUNT > 0 && AC_L10_SYMBOL_PATH_INDEX_COUNT == AC_L10_SYMBOL_COUNT);
   bool sidecars_ok = (AC_L10_SYMBOL_SIDECAR_COUNT == 0 || AC_L10_SYMBOL_SIDECAR_COUNT == AC_L10_SYMBOL_COUNT);
   bool group_csv_ok = (AC_L10_GROUP_MEMBER_CSV_COUNT == 0 || AC_L10_GROUP_MEMBER_CSV_COUNT == AC_L10_RANKING_GROUP_COUNT);
   bool authority_ok = (authority == "taxonomy_classification_only");
   bool permission_ok = (selection_runtime == "false" && trade_permission == "false");
   bool writes_ok = (AC_L10_WRITE_FAILED_COUNT == 0);

   AC_L10_SUMMARY_CHECK_KEY = "symbols=" + IntegerToString(AC_L10_SYMBOL_COUNT)
      + "|groups=" + IntegerToString(AC_L10_RANKING_GROUP_COUNT)
      + "|strict=" + IntegerToString(AC_L10_ACCEPTED_STRICT_COUNT)
      + "|public=" + IntegerToString(AC_L10_ACCEPTED_PUBLIC_RESEARCH_COUNT)
      + "|review=" + IntegerToString(AC_L10_REVIEW_REQUIRED_COUNT)
      + "|unknown=" + IntegerToString(AC_L10_UNKNOWN_COUNT)
      + "|sidecars=" + IntegerToString(AC_L10_SYMBOL_SIDECAR_COUNT)
      + "|group_csvs=" + IntegerToString(AC_L10_GROUP_MEMBER_CSV_COUNT)
      + "|generated=" + AC_L10_GENERATED_UTC;

   if(files_ok && counts_ok && sidecars_ok && group_csv_ok && authority_ok && permission_ok && writes_ok)
   {
      AC_L10_ACCEPTED = true;
      AC_L10_STATUS = (AC_L10_REVIEW_REQUIRED_COUNT > 0 || AC_L10_UNKNOWN_COUNT > 0 || AC_L10_CONFLICT_COUNT > 0) ? "Accepted with review items" : "Accepted";
      AC_L10_TRUST_STATE = "Taxonomy Ready";
      AC_L10_VALIDATION_STATUS = "Accepted";
      AC_L10_VALIDATION_REASON = "summary/files/counts/sidecars/group_csvs/authority/permission all accepted";
      AC_L10_MAIN_BLOCKER = "none";
      return;
   }

   AC_L10_STATUS = "Taxonomy sidecar degraded";
   AC_L10_TRUST_STATE = "Taxonomy Degraded";
   AC_L10_VALIDATION_STATUS = "Degraded";
   AC_L10_VALIDATION_REASON = "files_ok=" + (files_ok ? "true" : "false")
      + ";counts_ok=" + (counts_ok ? "true" : "false")
      + ";sidecars_ok=" + (sidecars_ok ? "true" : "false")
      + ";group_csv_ok=" + (group_csv_ok ? "true" : "false")
      + ";authority_ok=" + (authority_ok ? "true" : "false")
      + ";permission_ok=" + (permission_ok ? "true" : "false")
      + ";writes_ok=" + (writes_ok ? "true" : "false");
   AC_L10_MAIN_BLOCKER = AC_L10_VALIDATION_REASON;
}

string AC_Layer10BoardSection()
{
   AC_L10RefreshTaxonomySummary();
   string text = "";
   text += "\r\nLAYER 10 - TAXONOMY / RANKING GROUP MAP\r\n";
   text += "----------------------------------------\r\n";
   text += "Status:                     " + AC_L10_STATUS + "\r\n";
   text += "Trust:                      " + AC_L10_TRUST_STATE + "\r\n";
   text += "Validation:                 " + AC_L10_VALIDATION_STATUS + "\r\n";
   text += "Owner:                      Runtime 5 - Taxonomy / Ranking Group Owner\r\n";
   text += "Gateway Required:           TRUE\r\n";
   text += "Gateway Result Accepted:    " + AC_L10BoolText(AC_L10_ACCEPTED) + "\r\n";
   text += "Symbols Classified:         " + IntegerToString(AC_L10_SYMBOL_COUNT) + "\r\n";
   text += "Accepted Strict:            " + IntegerToString(AC_L10_ACCEPTED_STRICT_COUNT) + "\r\n";
   text += "Accepted Public Research:   " + IntegerToString(AC_L10_ACCEPTED_PUBLIC_RESEARCH_COUNT) + "\r\n";
   text += "Review Required:            " + IntegerToString(AC_L10_REVIEW_REQUIRED_COUNT) + "\r\n";
   text += "Unknown:                    " + IntegerToString(AC_L10_UNKNOWN_COUNT) + "\r\n";
   text += "Conflicts / Blocked:        " + IntegerToString(AC_L10_CONFLICT_COUNT) + " / " + IntegerToString(AC_L10_BLOCKED_COUNT) + "\r\n";
   text += "Rank Allowed:               " + IntegerToString(AC_L10_RANK_ALLOWED_COUNT) + "\r\n";
   text += "Selection Path Eligible:    " + IntegerToString(AC_L10_SELECTION_ALLOWED_COUNT) + "\r\n";
   text += "Ranking Groups:             " + IntegerToString(AC_L10_RANKING_GROUP_COUNT) + "\r\n";
   text += "Active Groups:              " + IntegerToString(AC_L10_ACTIVE_GROUP_COUNT) + "\r\n";
   text += "Active With Review Groups:  " + IntegerToString(AC_L10_ACTIVE_WITH_REVIEW_GROUP_COUNT) + "\r\n";
   text += "Review Only Groups:         " + IntegerToString(AC_L10_REVIEW_ONLY_GROUP_COUNT) + "\r\n";
   text += "Symbol Path Index:          " + IntegerToString(AC_L10_SYMBOL_PATH_INDEX_COUNT) + " / " + IntegerToString(AC_L10_SYMBOL_COUNT) + "\r\n";
   text += "Symbol Sidecars:            " + IntegerToString(AC_L10_SYMBOL_SIDECAR_COUNT) + " / " + IntegerToString(AC_L10_SYMBOL_COUNT) + "\r\n";
   text += "Group Member CSVs:          " + IntegerToString(AC_L10_GROUP_MEMBER_CSV_COUNT) + " / " + IntegerToString(AC_L10_RANKING_GROUP_COUNT) + "\r\n";
   text += "Group Member Folder:        " + AC_L10GroupsFolder() + "\r\n";
   text += "Generated UTC:              " + AC_L10_GENERATED_UTC + "\r\n";
   text += "Policy:                     taxonomy_only_group_member_csvs_no_rank_no_top5_no_top10_no_dossier_copy\r\n";
   text += "Next Layer:                 L11 fills per-group Top 5 copied Dossiers after ranking\r\n";
   text += "Main Blocker:               " + AC_L10_MAIN_BLOCKER + "\r\n";
   text += "Ranking Runtime:            " + AC_L10BoolText(AC_L10_ACCEPTED) + "\r\n";
   text += "Selection Runtime:          FALSE\r\n";
   text += "Trade Permission:           FALSE\r\n";
   return text;
}

string AC_Layer10DossierSection(const string symbol)
{
   AC_L10RefreshTaxonomySummary();
   string sidecar_path = AC_L10SymbolTaxonomyPath(symbol);
   string sidecar = AC_L10ReadSmallTextFile(sidecar_path, 16000);
   string text = "";
   text += "\r\nLayer 10 Taxonomy / Ranking Group Map:\r\n";
   text += "\r\nLAYER 10 - TAXONOMY / RANKING GROUP MAP\r\n";
   text += "----------------------------------------\r\n";
   text += "Status: " + AC_L10_STATUS + "\r\n";
   text += "Owner: Runtime 5 - Taxonomy / Ranking Group Owner\r\n";
   text += "Gateway Result Accepted: " + AC_L10BoolText(AC_L10_ACCEPTED) + "\r\n";
   text += "Validation: " + AC_L10_VALIDATION_STATUS + "\r\n";
   if(sidecar == "")
   {
      text += "Symbol Taxonomy State: sidecar_missing\r\n";
      text += "Symbol Sidecar Path: " + sidecar_path + "\r\n";
      text += "Reason: L10 symbol sidecar missing or unreadable; taxonomy summary may still be available\r\n";
   }
   else
   {
      text += "Asset Class: " + AC_L10KvValue(sidecar, "asset_class", "Unknown") + "\r\n";
      text += "Market Group: " + AC_L10KvValue(sidecar, "market_group", "Unknown") + "\r\n";
      text += "Market Segment: " + AC_L10KvValue(sidecar, "market_segment", "Unknown") + "\r\n";
      text += "Ranking Group: " + AC_L10KvValue(sidecar, "ranking_group", "Unknown") + "\r\n";
      text += "Taxonomy State: " + AC_L10KvValue(sidecar, "taxonomy_state", "not_available") + "\r\n";
      text += "Review State: " + AC_L10KvValue(sidecar, "review_state", "not_available") + "\r\n";
      text += "Match Type: " + AC_L10KvValue(sidecar, "match_type", "not_available") + "\r\n";
      text += "Classification Source: " + AC_L10KvValue(sidecar, "classification_source", "not_available") + "\r\n";
      text += "Classification Confidence: " + AC_L10KvValue(sidecar, "classification_confidence", "not_available") + "\r\n";
      text += "Evidence Rank: " + AC_L10KvValue(sidecar, "evidence_rank", "not_available") + "\r\n";
      text += "Rank Allowed: " + AC_L10KvValue(sidecar, "rank_allowed", "false") + "\r\n";
      text += "Selection Path Eligible: " + AC_L10KvValue(sidecar, "selection_allowed", "false") + "\r\n";
      text += "Future Group Folder: " + AC_L10KvValue(sidecar, "future_group_folder", "not_available") + "\r\n";
      text += "Reason: " + AC_L10KvValue(sidecar, "reason", "not_available") + "\r\n";
      text += "Symbol Sidecar Path: " + sidecar_path + "\r\n";
   }
   text += "Group Member CSVs: " + IntegerToString(AC_L10_GROUP_MEMBER_CSV_COUNT) + " / " + IntegerToString(AC_L10_RANKING_GROUP_COUNT) + "\r\n";
   text += "Taxonomy Policy: classification and ranking_group map only; group member CSVs are review lists, not Top 5 and not selection\r\n";
   text += "Next Layer: L11 ranks symbols inside this ranking_group and may fill per-group Top 5 copied Dossiers\r\n";
   text += "Selection Runtime: FALSE\r\n";
   text += "Trade Permission: FALSE\r\n";
   text += "Execution: FALSE\r\n";
   return text;
}

string AC_Layer10WorkbenchSection()
{
   AC_L10RefreshTaxonomySummary();
   string text = "";
   text += "\r\nL10_TAXONOMY_RANKING_GROUP_MAP\r\n";
   text += "----------------------------------------\r\n";
   text += "owner_name=Runtime 5 - Taxonomy / Ranking Group Owner\r\n";
   text += "layer_name=Layer 10 - Taxonomy / Ranking Group Map\r\n";
   text += "status=" + AC_L10_STATUS + "\r\n";
   text += "trust_state=" + AC_L10_TRUST_STATE + "\r\n";
   text += "validation_status=" + AC_L10_VALIDATION_STATUS + "\r\n";
   text += "validation_reason=" + AC_L10_VALIDATION_REASON + "\r\n";
   text += "symbol_count=" + IntegerToString(AC_L10_SYMBOL_COUNT) + "\r\n";
   text += "accepted_strict_count=" + IntegerToString(AC_L10_ACCEPTED_STRICT_COUNT) + "\r\n";
   text += "accepted_public_research_count=" + IntegerToString(AC_L10_ACCEPTED_PUBLIC_RESEARCH_COUNT) + "\r\n";
   text += "review_required_count=" + IntegerToString(AC_L10_REVIEW_REQUIRED_COUNT) + "\r\n";
   text += "unknown_count=" + IntegerToString(AC_L10_UNKNOWN_COUNT) + "\r\n";
   text += "conflict_count=" + IntegerToString(AC_L10_CONFLICT_COUNT) + "\r\n";
   text += "rank_allowed_count=" + IntegerToString(AC_L10_RANK_ALLOWED_COUNT) + "\r\n";
   text += "selection_allowed_count=" + IntegerToString(AC_L10_SELECTION_ALLOWED_COUNT) + "\r\n";
   text += "ranking_group_count=" + IntegerToString(AC_L10_RANKING_GROUP_COUNT) + "\r\n";
   text += "active_group_count=" + IntegerToString(AC_L10_ACTIVE_GROUP_COUNT) + "\r\n";
   text += "active_with_review_group_count=" + IntegerToString(AC_L10_ACTIVE_WITH_REVIEW_GROUP_COUNT) + "\r\n";
   text += "review_only_group_count=" + IntegerToString(AC_L10_REVIEW_ONLY_GROUP_COUNT) + "\r\n";
   text += "symbol_path_index_count=" + IntegerToString(AC_L10_SYMBOL_PATH_INDEX_COUNT) + "\r\n";
   text += "symbol_sidecar_count=" + IntegerToString(AC_L10_SYMBOL_SIDECAR_COUNT) + "\r\n";
   text += "group_member_csv_count=" + IntegerToString(AC_L10_GROUP_MEMBER_CSV_COUNT) + "\r\n";
   text += "invalid_universe_row_count=" + IntegerToString(AC_L10_INVALID_UNIVERSE_ROW_COUNT) + "\r\n";
   text += "write_failed_count=" + IntegerToString(AC_L10_WRITE_FAILED_COUNT) + "\r\n";
   text += "summary_path=" + AC_L10SummaryPath() + "\r\n";
   text += "taxonomy_symbols_path=" + AC_L10TaxonomySymbolsPath() + "\r\n";
   text += "ranking_groups_path=" + AC_L10RankingGroupsPath() + "\r\n";
   text += "symbol_path_index_path=" + AC_L10SymbolPathIndexPath() + "\r\n";
   text += "groups_folder=" + AC_L10GroupsFolder() + "\r\n";
   text += "symbol_taxonomy_folder=" + AC_L10SymbolTaxonomyFolder() + "\r\n";
   text += "summary_check_key=" + AC_L10_SUMMARY_CHECK_KEY + "\r\n";
   text += "classification_policy=taxonomy_only_group_member_csvs_no_rank_no_top5_no_top10_no_dossier_copy\r\n";
   text += "main_blocker=" + AC_L10_MAIN_BLOCKER + "\r\n";
   text += "ranking_runtime=" + AC_L10BoolKv(AC_L10_ACCEPTED) + "\r\n";
   text += "selection_runtime=false\r\n";
   text += "trade_permission=false\r\n";
   return text;
}

#endif
