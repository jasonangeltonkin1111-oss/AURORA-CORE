#ifndef AC_LAYER7_SESSION_RELEVANCE_RENDERER_MQH
#define AC_LAYER7_SESSION_RELEVANCE_RENDERER_MQH

// Runtime 7 render-only surface for Layer 7 Session Relevance.
// Reads only lightweight L7 sidecar proof files: input manifest, ranked manifest,
// top20, and per-symbol rank sidecars. It must not score, rank, decide sessions,
// gate symbols, select, permit, execute, parse ranked CSV files, call
// SymbolInfoSession*, CopyTicks, or CopyRates.

static string AC_L7_STATUS = "Pending ranked sidecar";
static string AC_L7_TRUST_STATE = "Ranking Pending";
static string AC_L7_VALIDATION_STATUS = "Pending";
static string AC_L7_VALIDATION_REASON = "ranked sidecar not checked yet";
static string AC_L7_MAIN_BLOCKER = "ranked_symbols.manifest has not been accepted yet";
static bool   AC_L7_RANKED_ACCEPTED = false;
static int    AC_L7_INPUT_ROWS_RENDERED = 0;
static int    AC_L7_RANKED_ROWS_RENDERED = 0;
static string AC_L7_INPUT_PAYLOAD_CHECKSUM_RENDERED = "not_available";
static string AC_L7_RANKED_PAYLOAD_CHECKSUM_RENDERED = "not_available";
static string AC_L7_TOP20_FIRST_LINE = "not_available";
static string AC_L7_SESSION_TIME_BASIS_RENDERED = "pending";
static string AC_L7_SESSION_DEFINITION_SOURCE_RENDERED = "pending";

string AC_L7LayerFolder()
{
   return AC_ExternalWorkerOutboxFolder() + "\\Layers\\Layer_7_Session_Relevance_Ranking";
}

string AC_L7InputManifestPath()
{
   return AC_L7LayerFolder() + "\\l7_input_primitives.manifest";
}

string AC_L7RankedManifestPath()
{
   return AC_L7LayerFolder() + "\\ranked_symbols.manifest";
}

string AC_L7RankedCsvPath()
{
   return AC_L7LayerFolder() + "\\ranked_symbols.csv";
}

string AC_L7RankedTop20Path()
{
   return AC_L7LayerFolder() + "\\ranked_symbols_top20.txt";
}

string AC_L7SymbolRankFolderPath()
{
   return AC_L7LayerFolder() + "\\SymbolRanks";
}

string AC_L7ReadSmallTextFile(const string path, const int max_chars = 30000)
{
   int common_flag = AC_USE_COMMON_FILES ? FILE_COMMON : 0;
   if(!FileIsExist(path, common_flag))
      return "";

   ResetLastError();
   int handle = FileOpen(path, AC_FileFlags() | FILE_READ);
   if(handle == INVALID_HANDLE)
      return "";

   string text = "";
   while(!FileIsEnding(handle) && StringLen(text) < max_chars)
   {
      string line = FileReadString(handle);
      text += line;
      if(!FileIsEnding(handle))
         text += "\n";
   }
   FileClose(handle);
   if(StringLen(text) > max_chars)
      text = StringSubstr(text, 0, max_chars);
   return text;
}

string AC_L7KvValue(const string text, const string key, const string fallback = "not_available")
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
         return value;
      }
   }
   return fallback;
}

int AC_L7KvInt(const string text, const string key, const int fallback = 0)
{
   string value = AC_L7KvValue(text, key, "");
   if(value == "") return fallback;
   return (int)StringToInteger(value);
}

string AC_L7BoolText(const bool value)
{
   return value ? "TRUE" : "FALSE";
}

string AC_L7BoolKv(const bool value)
{
   return value ? "true" : "false";
}

string AC_L7FirstTop20Symbol(const string top20_text)
{
   string lines[];
   ushort separator = StringGetCharacter("\n", 0);
   int count = StringSplit(top20_text, separator, lines);
   for(int i = 0; i < count; i++)
   {
      string line = lines[i];
      StringReplace(line, "\r", "");
      StringTrimLeft(line);
      StringTrimRight(line);
      if(StringFind(line, "1|") == 0)
         return line;
   }
   return "not_available";
}

string AC_L7SymbolRankPathByFind(const string symbol)
{
   string pattern = AC_L7SymbolRankFolderPath() + "\\" + AC_SanitizePathPart(symbol) + "__*.txt";
   string found = "";
   long handle = FileFindFirst(pattern, found, AC_CommonFlag());
   if(handle == INVALID_HANDLE)
      return "";
   FileFindClose(handle);
   if(found == "")
      return "";
   return AC_L7SymbolRankFolderPath() + "\\" + found;
}

void AC_L7RefreshRankedSidecar()
{
   AC_L7_STATUS = "Pending ranked sidecar";
   AC_L7_TRUST_STATE = "Ranking Pending";
   AC_L7_VALIDATION_STATUS = "Pending";
   AC_L7_VALIDATION_REASON = "ranked_symbols.manifest missing or not accepted";
   AC_L7_MAIN_BLOCKER = "ranked_symbols.manifest has not been accepted yet";
   AC_L7_RANKED_ACCEPTED = false;
   AC_L7_INPUT_ROWS_RENDERED = 0;
   AC_L7_RANKED_ROWS_RENDERED = 0;
   AC_L7_INPUT_PAYLOAD_CHECKSUM_RENDERED = "not_available";
   AC_L7_RANKED_PAYLOAD_CHECKSUM_RENDERED = "not_available";
   AC_L7_TOP20_FIRST_LINE = "not_available";
   AC_L7_SESSION_TIME_BASIS_RENDERED = "pending";
   AC_L7_SESSION_DEFINITION_SOURCE_RENDERED = "pending";

   string input_manifest = AC_L7ReadSmallTextFile(AC_L7InputManifestPath(), 30000);
   if(input_manifest == "")
   {
      AC_L7_VALIDATION_STATUS = "Missing";
      AC_L7_VALIDATION_REASON = "l7_input_primitives.manifest missing or unreadable";
      AC_L7_MAIN_BLOCKER = AC_L7_VALIDATION_REASON;
      return;
   }

   string ranked_manifest = AC_L7ReadSmallTextFile(AC_L7RankedManifestPath(), 30000);
   if(ranked_manifest == "")
   {
      AC_L7_VALIDATION_STATUS = "InputAccepted";
      AC_L7_VALIDATION_REASON = "input manifest accepted; ranked_symbols.manifest missing or unreadable";
      AC_L7_MAIN_BLOCKER = "ranked_symbols.manifest has not been built or accepted yet";
      AC_L7_STATUS = "Input export ready - ranked sidecar pending";
      AC_L7_TRUST_STATE = "Ranking Pending";
      AC_L7_INPUT_ROWS_RENDERED = AC_L7KvInt(input_manifest, "row_count", 0);
      AC_L7_INPUT_PAYLOAD_CHECKSUM_RENDERED = AC_L7KvValue(input_manifest, "payload_checksum", "not_available");
      AC_L7_SESSION_TIME_BASIS_RENDERED = AC_L7KvValue(input_manifest, "session_time_basis", "pending");
      AC_L7_SESSION_DEFINITION_SOURCE_RENDERED = AC_L7KvValue(input_manifest, "session_definition_source", "pending");
      return;
   }

   int input_rows = AC_L7KvInt(input_manifest, "row_count", 0);
   int input_l5_pass = AC_L7KvInt(input_manifest, "l5_gate_pass", 0);
   string input_write_ok = AC_L7KvValue(input_manifest, "write_ok", "false");
   string input_payload_checksum = AC_L7KvValue(input_manifest, "payload_checksum", "not_available");
   string input_session_time_basis = AC_L7KvValue(input_manifest, "session_time_basis", "pending");
   string input_session_definition_source = AC_L7KvValue(input_manifest, "session_definition_source", "pending");

   string ranked_status = AC_L7KvValue(ranked_manifest, "status", "not_available");
   int ranked_input_count = AC_L7KvInt(ranked_manifest, "input_count", 0);
   int ranked_rows = AC_L7KvInt(ranked_manifest, "row_count", 0);
   int source_input_rows = AC_L7KvInt(ranked_manifest, "source_input_manifest_row_count", 0);
   string source_input_checksum = AC_L7KvValue(ranked_manifest, "source_input_payload_checksum", "not_available");
   string ranked_payload_checksum = AC_L7KvValue(ranked_manifest, "payload_checksum", "not_available");
   string authority = AC_L7KvValue(ranked_manifest, "authority", "not_available");
   string trade_permission = AC_L7KvValue(ranked_manifest, "trade_permission", "not_available");
   string ranking_runtime = AC_L7KvValue(ranked_manifest, "ranking_runtime", "not_available");
   string selection_runtime = AC_L7KvValue(ranked_manifest, "selection_runtime", "not_available");

   AC_L7_INPUT_ROWS_RENDERED = input_rows;
   AC_L7_RANKED_ROWS_RENDERED = ranked_rows;
   AC_L7_INPUT_PAYLOAD_CHECKSUM_RENDERED = input_payload_checksum;
   AC_L7_RANKED_PAYLOAD_CHECKSUM_RENDERED = ranked_payload_checksum;
   AC_L7_SESSION_TIME_BASIS_RENDERED = input_session_time_basis;
   AC_L7_SESSION_DEFINITION_SOURCE_RENDERED = input_session_definition_source;

   bool input_ok = (input_write_ok == "true" && input_rows > 0 && input_rows == input_l5_pass && input_rows == AC_L5_GATE_PASS);
   bool manifest_ok = (ranked_status == "complete");
   bool counts_ok = (ranked_input_count == ranked_rows && ranked_rows == input_rows && source_input_rows == input_rows);
   bool identity_ok = (source_input_checksum == input_payload_checksum && input_payload_checksum != "not_available");
   bool authority_ok = (authority == AC_EXTERNAL_WORKER_AUTHORITY);
   bool permission_ok = (trade_permission == "false" && selection_runtime == "false" && ranking_runtime == "true");
   bool files_ok = FileIsExist(AC_L7RankedCsvPath(), AC_CommonFlag()) && FileIsExist(AC_L7RankedTop20Path(), AC_CommonFlag());

   if(input_ok && manifest_ok && counts_ok && identity_ok && authority_ok && permission_ok && files_ok)
   {
      AC_L7_RANKED_ACCEPTED = true;
      AC_L7_STATUS = "Ranked sidecar accepted";
      AC_L7_TRUST_STATE = "Ranking Ready";
      AC_L7_VALIDATION_STATUS = "Accepted";
      AC_L7_VALIDATION_REASON = "ranked manifest/top20/csv sidecars match L7 input proof and permission boundaries";
      AC_L7_MAIN_BLOCKER = "none";
      AC_L7_TOP20_FIRST_LINE = AC_L7FirstTop20Symbol(AC_L7ReadSmallTextFile(AC_L7RankedTop20Path(), 16000));
      return;
   }

   AC_L7_STATUS = "Ranked sidecar degraded";
   AC_L7_TRUST_STATE = "Ranking Degraded";
   AC_L7_VALIDATION_STATUS = "Degraded";
   AC_L7_VALIDATION_REASON = "input_ok=" + (input_ok ? "true" : "false")
      + ";manifest_ok=" + (manifest_ok ? "true" : "false")
      + ";counts_ok=" + (counts_ok ? "true" : "false")
      + ";identity_ok=" + (identity_ok ? "true" : "false")
      + ";authority_ok=" + (authority_ok ? "true" : "false")
      + ";permission_ok=" + (permission_ok ? "true" : "false")
      + ";files_ok=" + (files_ok ? "true" : "false");
   AC_L7_MAIN_BLOCKER = AC_L7_VALIDATION_REASON;
}

string AC_Layer7BoardSection()
{
   AC_L7RefreshRankedSidecar();
   string text = "";
   text += "\r\nLAYER 7 - SESSION RELEVANCE RANKING\r\n";
   text += "----------------------------------------\r\n";
   text += "Status: " + AC_L7_STATUS + "\r\n";
   text += "Trust: " + AC_L7_TRUST_STATE + "\r\n";
   text += "Validation: " + AC_L7_VALIDATION_STATUS + "\r\n";
   text += "Owner: Runtime 4 - Surface Scoring Owner\r\n";
   text += "Gateway Required: TRUE\r\n";
   text += "Gateway Result Accepted: " + AC_L7BoolText(AC_L7_RANKED_ACCEPTED) + "\r\n";
   text += "Input Source: Layer 5 pass set only\r\n";
   text += "Current L5 Pass Symbols: " + IntegerToString(AC_L5_GATE_PASS) + "\r\n";
   text += "Manifest Input Count: " + IntegerToString(AC_L7_INPUT_ROWS_RENDERED) + "\r\n";
   text += "Ranked Symbols: " + IntegerToString(AC_L7_RANKED_ROWS_RENDERED) + "\r\n";
   text += "Top Ranked: " + AC_L7_TOP20_FIRST_LINE + "\r\n";
   text += "Current Global Session: " + AC_L7KvValue(AC_L7_TOP20_FIRST_LINE, "current_session", "see_top20") + "\r\n";
   text += "Session Basis: " + AC_L7_SESSION_TIME_BASIS_RENDERED + "\r\n";
   text += "Session Definition Source: " + AC_L7_SESSION_DEFINITION_SOURCE_RENDERED + "\r\n";
   text += "UTC Basis: gateway_sidecar_utc_generated\r\n";
   text += "Main Blocker: " + AC_L7_MAIN_BLOCKER + "\r\n";
   text += "Gateway Job: L7_SESSION_RELEVANCE_RANKING_V1\r\n";
   text += "Ranking Runtime: " + AC_L7BoolText(AC_L7_RANKED_ACCEPTED) + "\r\n";
   text += "Selection Runtime: FALSE\r\n";
   text += "Trade Permission: FALSE\r\n";
   return text;
}

string AC_Layer7DossierSection(const string symbol)
{
   AC_L7RefreshRankedSidecar();
   string l5_gate_status = "not_available";
   int l5_index = AC_L5FindIndex(symbol);
   if(l5_index >= 0)
      l5_gate_status = AC_L5_SYMBOLS[l5_index].pass ? "pass" : "not_pass";

   string text = "";
   text += "\r\nLAYER 7 - SESSION RELEVANCE RANKING\r\n";
   text += "----------------------------------------\r\n";
   text += "Status: " + AC_L7_STATUS + "\r\n";
   text += "Owner: Runtime 4 - Surface Scoring Owner\r\n";
   text += "Gateway Result Accepted: " + AC_L7BoolText(AC_L7_RANKED_ACCEPTED) + "\r\n";
   text += "Validation: " + AC_L7_VALIDATION_STATUS + "\r\n";
   text += "L5 Gate Status: " + l5_gate_status + "\r\n";

   if(l5_gate_status != "pass")
   {
      text += "Rank State: not_ranked_l5_gate_failed\r\n";
      text += "Session Score: not_available\r\n";
      text += "Session Bucket: not_available\r\n";
   }
   else if(!AC_L7_RANKED_ACCEPTED)
   {
      text += "Rank State: ranked_sidecar_not_accepted\r\n";
      text += "Session Score: pending\r\n";
      text += "Session Bucket: pending\r\n";
      text += "Validation Reason: " + AC_L7_VALIDATION_REASON + "\r\n";
   }
   else
   {
      string rank_path = AC_L7SymbolRankPathByFind(symbol);
      string rank_text = rank_path == "" ? "" : AC_L7ReadSmallTextFile(rank_path, 12000);
      if(rank_text == "")
      {
         text += "Rank State: symbol_rank_sidecar_missing\r\n";
         text += "Session Score: missing\r\n";
         text += "Session Bucket: missing\r\n";
      }
      else
      {
         text += "Rank State: " + AC_L7KvValue(rank_text, "rank_state", "not_available") + "\r\n";
         text += "Rank Index: " + AC_L7KvValue(rank_text, "rank_index", "not_available") + " / " + IntegerToString(AC_L7_RANKED_ROWS_RENDERED) + "\r\n";
         text += "Session Score: " + AC_L7KvValue(rank_text, "session_score", "not_available") + "\r\n";
         text += "Session Bucket: " + AC_L7KvValue(rank_text, "session_bucket", "not_available") + "\r\n";
         text += "Score Quality: " + AC_L7KvValue(rank_text, "score_quality", "not_available") + "\r\n";
         text += "Current Session: " + AC_L7KvValue(rank_text, "current_session", "not_available") + "\r\n";
         text += "Session Definition Source: " + AC_L7KvValue(rank_text, "session_definition_source", "not_available") + "\r\n";
         text += "Session Time Basis: " + AC_L7KvValue(rank_text, "session_time_basis", "not_available") + "\r\n";
         text += "Time Basis Confidence: " + AC_L7KvValue(rank_text, "time_basis_confidence", "not_available") + "\r\n";
         text += "Symbol Session Fit Score: " + AC_L7KvValue(rank_text, "symbol_session_fit_score", "not_available") + "\r\n";
         text += "Live Activity Quality Score: " + AC_L7KvValue(rank_text, "live_activity_quality_score", "not_available") + "\r\n";
         text += "Quote Freshness Quality Score: " + AC_L7KvValue(rank_text, "quote_freshness_quality_score", "not_available") + "\r\n";
         text += "Spread Session Safety Score: " + AC_L7KvValue(rank_text, "spread_session_safety_score", "not_available") + "\r\n";
         text += "Reason: " + AC_L7KvValue(rank_text, "reason", "not_available") + "\r\n";
         text += "Rank Source: " + rank_path + "\r\n";
      }
   }

   text += "Boundary:\r\n";
   text += "Source Owner: Layer 5 pass set + Layer 2/3/4 packets\r\n";
   text += "Scoring Owner: Runtime 4 - Surface Scoring Owner via Runtime 3 Gateway support\r\n";
   text += "Layer 7 Blocks Symbols: FALSE\r\n";
   text += "Selection Runtime: FALSE\r\n";
   text += "Trade Permission: FALSE\r\n";
   text += "Execution: FALSE\r\n";
   return text;
}

string AC_Layer7WorkbenchSection()
{
   AC_L7RefreshRankedSidecar();
   string text = "";
   text += "\r\nL7_SESSION_RELEVANCE_RANKING\r\n";
   text += "----------------------------------------\r\n";
   text += "owner_name=Runtime 4 - Surface Scoring Owner\r\n";
   text += "layer_name=Layer 7 - Session Relevance Ranking\r\n";
   text += "status=" + AC_L7_STATUS + "\r\n";
   text += "trust_state=" + AC_L7_TRUST_STATE + "\r\n";
   text += "validation_status=" + AC_L7_VALIDATION_STATUS + "\r\n";
   text += "validation_reason=" + AC_L7_VALIDATION_REASON + "\r\n";
   text += "gateway_required=true\r\n";
   text += "gateway_result_accepted=" + AC_L7BoolKv(AC_L7_RANKED_ACCEPTED) + "\r\n";
   text += "job_type=L7_SESSION_RELEVANCE_RANKING_V1\r\n";
   text += "current_l5_pass_symbols=" + IntegerToString(AC_L5_GATE_PASS) + "\r\n";
   text += "manifest_input_count=" + IntegerToString(AC_L7_INPUT_ROWS_RENDERED) + "\r\n";
   text += "ranked_symbols=" + IntegerToString(AC_L7_RANKED_ROWS_RENDERED) + "\r\n";
   text += "source_input_payload_checksum=" + AC_L7_INPUT_PAYLOAD_CHECKSUM_RENDERED + "\r\n";
   text += "ranked_payload_checksum=" + AC_L7_RANKED_PAYLOAD_CHECKSUM_RENDERED + "\r\n";
   text += "top_ranked=" + AC_L7_TOP20_FIRST_LINE + "\r\n";
   text += "input_manifest_path=Outbox\\Layers\\Layer_7_Session_Relevance_Ranking\\l7_input_primitives.manifest\r\n";
   text += "ranked_manifest_path=Outbox\\Layers\\Layer_7_Session_Relevance_Ranking\\ranked_symbols.manifest\r\n";
   text += "top20_path=Outbox\\Layers\\Layer_7_Session_Relevance_Ranking\\ranked_symbols_top20.txt\r\n";
   text += "symbol_rank_folder=Outbox\\Layers\\Layer_7_Session_Relevance_Ranking\\SymbolRanks\r\n";
   text += "session_time_basis=" + AC_L7_SESSION_TIME_BASIS_RENDERED + "\r\n";
   text += "session_definition_source=" + AC_L7_SESSION_DEFINITION_SOURCE_RENDERED + "\r\n";
   text += "main_blocker=" + AC_L7_MAIN_BLOCKER + "\r\n";
   text += "ranking_runtime=" + AC_L7BoolKv(AC_L7_RANKED_ACCEPTED) + "\r\n";
   text += "selection_runtime=false\r\n";
   text += "trade_permission=false\r\n";
   return text;
}

#endif