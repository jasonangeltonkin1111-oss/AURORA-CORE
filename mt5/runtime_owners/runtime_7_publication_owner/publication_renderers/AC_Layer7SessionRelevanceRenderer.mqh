#ifndef AC_LAYER7_SESSION_RELEVANCE_RENDERER_MQH
#define AC_LAYER7_SESSION_RELEVANCE_RENDERER_MQH

// Runtime 7 render-only surface for Layer 7 Session Relevance.
// Reads only lightweight L7 sidecar proof files: input manifest, ranked manifest,
// top20, per-symbol rank sidecars, and the Gateway accepted surface epoch.
// It must not score, rank, decide sessions, gate symbols, select, permit,
// execute, parse ranked CSV files, call SymbolInfoSession*, CopyTicks, or CopyRates.

static string AC_L7_STATUS = "Pending ranked sidecar";
static string AC_L7_TRUST_STATE = "Ranking Pending";
static string AC_L7_VALIDATION_STATUS = "Pending";
static string AC_L7_VALIDATION_REASON = "ranked sidecar not checked yet";
static string AC_L7_MAIN_BLOCKER = "ranked_symbols.manifest has not been accepted yet";
static string AC_L7_OPERATOR_SUMMARY = "Gateway ranked sidecar pending";
static string AC_L7_DISPLAY_STATE = "PENDING_RANK";
static bool   AC_L7_RANKED_ACCEPTED = false;
static bool   AC_L7_INPUT_COUNTS_OK_RENDERED = false;
static bool   AC_L7_GENERATION_COUNTS_OK_RENDERED = false;
static bool   AC_L7_GENERATION_IDENTITY_OK_RENDERED = false;
static bool   AC_L7_LATEST_INPUT_PENDING_NEXT_RANK = false;
static bool   AC_L7_SNAPSHOT_DRIFT_RENDERED = false;
static int    AC_L7_SNAPSHOT_DRIFT_DELTA_RENDERED = 0;
static int    AC_L7_INPUT_ROWS_RENDERED = 0;
static int    AC_L7_EXPORT_L5_PASS_RENDERED = 0;
static int    AC_L7_RANKED_ROWS_RENDERED = 0;
static int    AC_L7_RANKED_COUNT_RENDERED = 0;
static int    AC_L7_RANKED_DEGRADED_COUNT_RENDERED = 0;
static int    AC_L7_NOT_RANKABLE_QUALITY_COUNT_RENDERED = 0;
static int    AC_L7_ELITE_COUNT_RENDERED = 0;
static int    AC_L7_STRONG_COUNT_RENDERED = 0;
static int    AC_L7_ACCEPTABLE_COUNT_RENDERED = 0;
static int    AC_L7_WEAK_COUNT_RENDERED = 0;
static int    AC_L7_POOR_COUNT_RENDERED = 0;
static int    AC_L7_SYMBOL_RANK_FILES_WRITTEN_RENDERED = 0;
static int    AC_L7_SYMBOL_RANK_FILES_ACTUAL_RENDERED = 0;
static string AC_L7_SYMBOL_RANK_FILE_COUNT_OK_RENDERED = "false";
static string AC_L7_SYMBOL_RANK_FILENAME_MODE_RENDERED = "not_available";
static string AC_L7_INPUT_PAYLOAD_CHECKSUM_RENDERED = "not_available";
static string AC_L7_RANKED_SOURCE_INPUT_CHECKSUM_RENDERED = "not_available";
static string AC_L7_RANKED_PAYLOAD_CHECKSUM_RENDERED = "not_available";
static string AC_L7_TOP20_FIRST_LINE = "not_available";
static string AC_L7_CURRENT_GLOBAL_SESSION_RENDERED = "not_available";
static string AC_L7_SESSION_TIME_BASIS_RENDERED = "pending";
static string AC_L7_SESSION_DEFINITION_SOURCE_RENDERED = "pending";
static string AC_L7_SESSION_PROFILE_POLICY_RENDERED = "not_available";
static string AC_L7_ACCEPTED_EPOCH_PRESENT_RENDERED = "false";
static string AC_L7_ACCEPTED_EPOCH_VALID_RENDERED = "false";
static string AC_L7_ACCEPTED_EPOCH_ID_RENDERED = "not_available";
static string AC_L7_ACCEPTED_EPOCH_L7_STATUS_RENDERED = "not_available";
static int    AC_L7_ACCEPTED_EPOCH_ACCEPTED_UNIX_RENDERED = 0;
static int    AC_L7_ACCEPTED_EPOCH_VALID_UNTIL_UNIX_RENDERED = 0;
static int    AC_L7_ACCEPTED_EPOCH_AGE_SECONDS_RENDERED = -1;
static long   AC_L7_LAST_REFRESH_HEARTBEAT_ID = -1;

string AC_L7LayerFolder(){ return AC_ExternalWorkerOutboxFolder() + "\\Layers\\Layer_7_Session_Relevance_Ranking"; }
string AC_L7InputManifestPath(){ return AC_L7LayerFolder() + "\\l7_input_primitives.manifest"; }
string AC_L7RankedManifestPath(){ return AC_L7LayerFolder() + "\\ranked_symbols.manifest"; }
string AC_L7RankedCsvPath(){ return AC_L7LayerFolder() + "\\ranked_symbols.csv"; }
string AC_L7RankedTop20Path(){ return AC_L7LayerFolder() + "\\ranked_symbols_top20.txt"; }
string AC_L7SymbolRankFolderPath(){ return AC_L7LayerFolder() + "\\SymbolRanks"; }
string AC_L7AcceptedSurfaceEpochPath(){ return AC_ExternalWorkerOutboxFolder() + "\\surface_accepted_epoch.manifest"; }

string AC_L7ReadSmallTextFile(const string path, const int max_chars = 30000)
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

string AC_L7BoolText(const bool value){ return value ? "TRUE" : "FALSE"; }
string AC_L7BoolKv(const bool value){ return value ? "true" : "false"; }

string AC_L7PipeField(const string pipe_text, const int index, const string fallback = "not_available")
{
   string line = pipe_text;
   StringReplace(line, "\r", "");
   StringTrimLeft(line);
   StringTrimRight(line);
   if(line == "" || line == "not_available") return fallback;
   string parts[];
   ushort separator = StringGetCharacter("|", 0);
   int count = StringSplit(line, separator, parts);
   if(index < 0 || index >= count) return fallback;
   string value = parts[index];
   StringTrimLeft(value);
   StringTrimRight(value);
   if(value == "") return fallback;
   return value;
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
      if(StringFind(line, "1|") == 0) return line;
   }
   return "not_available";
}

string AC_L7SymbolRankPathByFind(const string symbol)
{
   string pattern = AC_L7SymbolRankFolderPath() + "\\" + AC_SanitizePathPart(symbol) + "__*.txt";
   string found = "";
   long handle = FileFindFirst(pattern, found, AC_CommonFlag());
   if(handle == INVALID_HANDLE) return "";
   FileFindClose(handle);
   if(found == "") return "";
   return AC_L7SymbolRankFolderPath() + "\\" + found;
}

void AC_L7ResetAcceptedEpochState()
{
   AC_L7_ACCEPTED_EPOCH_PRESENT_RENDERED = "false";
   AC_L7_ACCEPTED_EPOCH_VALID_RENDERED = "false";
   AC_L7_ACCEPTED_EPOCH_ID_RENDERED = "not_available";
   AC_L7_ACCEPTED_EPOCH_L7_STATUS_RENDERED = "not_available";
   AC_L7_ACCEPTED_EPOCH_ACCEPTED_UNIX_RENDERED = 0;
   AC_L7_ACCEPTED_EPOCH_VALID_UNTIL_UNIX_RENDERED = 0;
   AC_L7_ACCEPTED_EPOCH_AGE_SECONDS_RENDERED = -1;
}

void AC_L7RefreshAcceptedEpochState()
{
   AC_L7ResetAcceptedEpochState();
   string epoch_text = AC_L7ReadSmallTextFile(AC_L7AcceptedSurfaceEpochPath(), 12000);
   if(epoch_text == "") return;
   AC_L7_ACCEPTED_EPOCH_PRESENT_RENDERED = "true";
   AC_L7_ACCEPTED_EPOCH_ID_RENDERED = AC_L7KvValue(epoch_text, "epoch_id", "not_available");
   AC_L7_ACCEPTED_EPOCH_L7_STATUS_RENDERED = AC_L7KvValue(epoch_text, "l7_status", "not_available");
   AC_L7_ACCEPTED_EPOCH_ACCEPTED_UNIX_RENDERED = AC_L7KvInt(epoch_text, "accepted_unix", 0);
   AC_L7_ACCEPTED_EPOCH_VALID_UNTIL_UNIX_RENDERED = AC_L7KvInt(epoch_text, "valid_until_unix", 0);
   string authority = AC_L7KvValue(epoch_text, "authority", "not_available");
   string trade_permission = AC_L7KvValue(epoch_text, "trade_permission", "not_available");
   string selection_runtime = AC_L7KvValue(epoch_text, "selection_runtime", "not_available");
   int now_unix = (int)TimeGMT();
   if(AC_L7_ACCEPTED_EPOCH_ACCEPTED_UNIX_RENDERED > 0 && now_unix >= AC_L7_ACCEPTED_EPOCH_ACCEPTED_UNIX_RENDERED)
      AC_L7_ACCEPTED_EPOCH_AGE_SECONDS_RENDERED = now_unix - AC_L7_ACCEPTED_EPOCH_ACCEPTED_UNIX_RENDERED;
   bool valid = (AC_L7_ACCEPTED_EPOCH_L7_STATUS_RENDERED == "complete"
      && AC_L7_ACCEPTED_EPOCH_VALID_UNTIL_UNIX_RENDERED >= now_unix
      && authority == AC_EXTERNAL_WORKER_AUTHORITY
      && trade_permission == "false"
      && selection_runtime == "false");
   AC_L7_ACCEPTED_EPOCH_VALID_RENDERED = valid ? "true" : "false";
}

void AC_L7ResetRenderState()
{
   AC_L7_STATUS = "Pending ranked sidecar";
   AC_L7_TRUST_STATE = "Ranking Pending";
   AC_L7_VALIDATION_STATUS = "Pending";
   AC_L7_VALIDATION_REASON = "ranked_symbols.manifest missing or not accepted";
   AC_L7_MAIN_BLOCKER = "ranked_symbols.manifest has not been accepted yet";
   AC_L7_OPERATOR_SUMMARY = "Gateway ranked sidecar pending";
   AC_L7_DISPLAY_STATE = "PENDING_RANK";
   AC_L7_RANKED_ACCEPTED = false;
   AC_L7_INPUT_COUNTS_OK_RENDERED = false;
   AC_L7_GENERATION_COUNTS_OK_RENDERED = false;
   AC_L7_GENERATION_IDENTITY_OK_RENDERED = false;
   AC_L7_LATEST_INPUT_PENDING_NEXT_RANK = false;
   AC_L7_SNAPSHOT_DRIFT_RENDERED = false;
   AC_L7_SNAPSHOT_DRIFT_DELTA_RENDERED = 0;
   AC_L7_INPUT_ROWS_RENDERED = 0;
   AC_L7_EXPORT_L5_PASS_RENDERED = 0;
   AC_L7_RANKED_ROWS_RENDERED = 0;
   AC_L7_RANKED_COUNT_RENDERED = 0;
   AC_L7_RANKED_DEGRADED_COUNT_RENDERED = 0;
   AC_L7_NOT_RANKABLE_QUALITY_COUNT_RENDERED = 0;
   AC_L7_ELITE_COUNT_RENDERED = 0;
   AC_L7_STRONG_COUNT_RENDERED = 0;
   AC_L7_ACCEPTABLE_COUNT_RENDERED = 0;
   AC_L7_WEAK_COUNT_RENDERED = 0;
   AC_L7_POOR_COUNT_RENDERED = 0;
   AC_L7_SYMBOL_RANK_FILES_WRITTEN_RENDERED = 0;
   AC_L7_SYMBOL_RANK_FILES_ACTUAL_RENDERED = 0;
   AC_L7_SYMBOL_RANK_FILE_COUNT_OK_RENDERED = "false";
   AC_L7_SYMBOL_RANK_FILENAME_MODE_RENDERED = "not_available";
   AC_L7_INPUT_PAYLOAD_CHECKSUM_RENDERED = "not_available";
   AC_L7_RANKED_SOURCE_INPUT_CHECKSUM_RENDERED = "not_available";
   AC_L7_RANKED_PAYLOAD_CHECKSUM_RENDERED = "not_available";
   AC_L7_TOP20_FIRST_LINE = "not_available";
   AC_L7_CURRENT_GLOBAL_SESSION_RENDERED = "not_available";
   AC_L7_SESSION_TIME_BASIS_RENDERED = "pending";
   AC_L7_SESSION_DEFINITION_SOURCE_RENDERED = "pending";
   AC_L7_SESSION_PROFILE_POLICY_RENDERED = "not_available";
   AC_L7ResetAcceptedEpochState();
}

void AC_L7LoadTop20Evidence()
{
   string top20_text = AC_L7ReadSmallTextFile(AC_L7RankedTop20Path(), 16000);
   AC_L7_TOP20_FIRST_LINE = AC_L7FirstTop20Symbol(top20_text);
   AC_L7_CURRENT_GLOBAL_SESSION_RENDERED = AC_L7PipeField(AC_L7_TOP20_FIRST_LINE, 6, "not_available");
}

void AC_L7AcceptCurrentEpoch()
{
   AC_L7_RANKED_ACCEPTED = true;
   AC_L7_DISPLAY_STATE = "ACCEPTED_CURRENT";
   AC_L7_STATUS = "Ranked sidecar accepted";
   AC_L7_TRUST_STATE = "Ranking Ready";
   AC_L7_VALIDATION_STATUS = "Accepted";
   AC_L7_VALIDATION_REASON = "ranked manifest/top20/csv/SymbolRanks sidecars match current L7 input proof and permission boundaries";
   AC_L7_MAIN_BLOCKER = "none";
   AC_L7_OPERATOR_SUMMARY = "Complete - ranked sidecar accepted for current L7 input epoch";
}

void AC_L7AcceptHeldEpoch()
{
   AC_L7_RANKED_ACCEPTED = true;
   AC_L7_DISPLAY_STATE = "ACCEPTED_HELD_RECALC_PENDING";
   AC_L7_STATUS = "Ranked sidecar accepted - recalculation pending";
   AC_L7_TRUST_STATE = "Ranking Held";
   AC_L7_VALIDATION_STATUS = "AcceptedHeld";
   AC_L7_LATEST_INPUT_PENDING_NEXT_RANK = true;
   AC_L7_VALIDATION_REASON = "latest input checksum is newer than ranked sidecar; last accepted Gateway surface epoch remains valid";
   AC_L7_MAIN_BLOCKER = "none";
   AC_L7_OPERATOR_SUMMARY = "Accepted held - newer L7 input is pending next Gateway rank; last accepted epoch remains valid";
}

void AC_L7RefreshRankedSidecar()
{
   if(AC_L7_LAST_REFRESH_HEARTBEAT_ID == AC_HEARTBEAT_ID) return;
   AC_L7_LAST_REFRESH_HEARTBEAT_ID = AC_HEARTBEAT_ID;
   AC_L7ResetRenderState();
   AC_L7RefreshAcceptedEpochState();

   string input_manifest = AC_L7ReadSmallTextFile(AC_L7InputManifestPath(), 30000);
   if(input_manifest == "")
   {
      AC_L7_VALIDATION_STATUS = "Missing";
      AC_L7_DISPLAY_STATE = "MISSING";
      AC_L7_VALIDATION_REASON = "l7_input_primitives.manifest missing or unreadable";
      AC_L7_MAIN_BLOCKER = AC_L7_VALIDATION_REASON;
      AC_L7_OPERATOR_SUMMARY = "Missing L7 input manifest";
      return;
   }

   int input_rows = AC_L7KvInt(input_manifest, "row_count", 0);
   int input_l5_pass = AC_L7KvInt(input_manifest, "l5_gate_pass", 0);
   string input_write_ok = AC_L7KvValue(input_manifest, "write_ok", "false");
   string input_payload_checksum = AC_L7KvValue(input_manifest, "payload_checksum", "not_available");
   AC_L7_INPUT_ROWS_RENDERED = input_rows;
   AC_L7_EXPORT_L5_PASS_RENDERED = input_l5_pass;
   AC_L7_INPUT_PAYLOAD_CHECKSUM_RENDERED = input_payload_checksum;
   AC_L7_SESSION_TIME_BASIS_RENDERED = AC_L7KvValue(input_manifest, "session_time_basis", "pending");
   AC_L7_SESSION_DEFINITION_SOURCE_RENDERED = AC_L7KvValue(input_manifest, "session_definition_source", "pending");
   AC_L7_INPUT_COUNTS_OK_RENDERED = (input_write_ok == "true" && input_rows > 0 && input_rows == input_l5_pass);
   AC_L7_SNAPSHOT_DRIFT_RENDERED = (input_rows != AC_L5_GATE_PASS);
   AC_L7_SNAPSHOT_DRIFT_DELTA_RENDERED = input_rows - AC_L5_GATE_PASS;

   string ranked_manifest = AC_L7ReadSmallTextFile(AC_L7RankedManifestPath(), 30000);
   if(ranked_manifest == "")
   {
      AC_L7_VALIDATION_STATUS = "InputAccepted";
      AC_L7_VALIDATION_REASON = "input manifest accepted; ranked_symbols.manifest missing or unreadable";
      AC_L7_MAIN_BLOCKER = "ranked_symbols.manifest has not been built or accepted yet";
      AC_L7_STATUS = "Input export ready - ranked sidecar pending";
      AC_L7_TRUST_STATE = "Ranking Pending";
      AC_L7_DISPLAY_STATE = "PENDING_RANK";
      AC_L7_OPERATOR_SUMMARY = "L7 input ready; Gateway ranked sidecar pending";
      return;
   }

   string ranked_status = AC_L7KvValue(ranked_manifest, "status", "not_available");
   int ranked_input_count = AC_L7KvInt(ranked_manifest, "input_count", 0);
   int ranked_rows = AC_L7KvInt(ranked_manifest, "row_count", 0);
   int source_input_rows = AC_L7KvInt(ranked_manifest, "source_input_manifest_row_count", 0);
   int source_l5_gate_pass = AC_L7KvInt(ranked_manifest, "source_l5_gate_pass", 0);
   string source_input_checksum = AC_L7KvValue(ranked_manifest, "source_input_payload_checksum", "not_available");
   string ranked_input_checksum = AC_L7KvValue(ranked_manifest, "input_payload_checksum", "not_available");
   string ranked_input_checksum_after = AC_L7KvValue(ranked_manifest, "input_payload_checksum_after_rank", "not_available");
   string checksum_match_text = AC_L7KvValue(ranked_manifest, "input_payload_checksum_matches_source_manifest", "false");
   string authority = AC_L7KvValue(ranked_manifest, "authority", "not_available");
   string trade_permission = AC_L7KvValue(ranked_manifest, "trade_permission", "not_available");
   string ranking_runtime = AC_L7KvValue(ranked_manifest, "ranking_runtime", "not_available");
   string selection_runtime = AC_L7KvValue(ranked_manifest, "selection_runtime", "not_available");
   string execution = AC_L7KvValue(ranked_manifest, "execution", "not_available");

   AC_L7_RANKED_ROWS_RENDERED = ranked_rows;
   AC_L7_RANKED_COUNT_RENDERED = AC_L7KvInt(ranked_manifest, "ranked_count", 0);
   AC_L7_RANKED_DEGRADED_COUNT_RENDERED = AC_L7KvInt(ranked_manifest, "ranked_degraded_count", 0);
   AC_L7_NOT_RANKABLE_QUALITY_COUNT_RENDERED = AC_L7KvInt(ranked_manifest, "not_rankable_quality_count", 0);
   AC_L7_ELITE_COUNT_RENDERED = AC_L7KvInt(ranked_manifest, "elite_session_relevance_count", 0);
   AC_L7_STRONG_COUNT_RENDERED = AC_L7KvInt(ranked_manifest, "strong_session_relevance_count", 0);
   AC_L7_ACCEPTABLE_COUNT_RENDERED = AC_L7KvInt(ranked_manifest, "acceptable_session_relevance_count", 0);
   AC_L7_WEAK_COUNT_RENDERED = AC_L7KvInt(ranked_manifest, "weak_session_relevance_count", 0);
   AC_L7_POOR_COUNT_RENDERED = AC_L7KvInt(ranked_manifest, "poor_session_relevance_count", 0);
   AC_L7_SYMBOL_RANK_FILES_WRITTEN_RENDERED = AC_L7KvInt(ranked_manifest, "symbol_rank_files_written", 0);
   AC_L7_SYMBOL_RANK_FILES_ACTUAL_RENDERED = AC_L7KvInt(ranked_manifest, "symbol_rank_files_actual", 0);
   AC_L7_SYMBOL_RANK_FILE_COUNT_OK_RENDERED = AC_L7KvValue(ranked_manifest, "symbol_rank_file_count_ok", "false");
   AC_L7_SYMBOL_RANK_FILENAME_MODE_RENDERED = AC_L7KvValue(ranked_manifest, "symbol_rank_filename_mode", "not_available");
   AC_L7_RANKED_SOURCE_INPUT_CHECKSUM_RENDERED = source_input_checksum;
   AC_L7_RANKED_PAYLOAD_CHECKSUM_RENDERED = AC_L7KvValue(ranked_manifest, "payload_checksum", "not_available");
   AC_L7_SESSION_PROFILE_POLICY_RENDERED = AC_L7KvValue(ranked_manifest, "session_profile_policy", "not_available");

   bool input_ok = (input_write_ok == "true" && input_rows > 0 && input_rows == input_l5_pass);
   bool manifest_ok = (ranked_status == "complete");
   bool counts_ok = (ranked_input_count == ranked_rows && ranked_rows == input_rows && source_input_rows == input_rows && source_l5_gate_pass == input_l5_pass);
   bool identity_ok = (source_input_checksum == input_payload_checksum && input_payload_checksum != "not_available")
      || (checksum_match_text == "true" && ranked_input_checksum == input_payload_checksum && ranked_input_checksum_after == input_payload_checksum);
   bool authority_ok = (authority == AC_EXTERNAL_WORKER_AUTHORITY);
   bool permission_ok = (trade_permission == "false" && selection_runtime == "false" && ranking_runtime == "true" && execution == "false");
   bool files_ok = FileIsExist(AC_L7RankedCsvPath(), AC_CommonFlag())
      && FileIsExist(AC_L7RankedTop20Path(), AC_CommonFlag())
      && AC_L7_SYMBOL_RANK_FILE_COUNT_OK_RENDERED == "true"
      && AC_L7_SYMBOL_RANK_FILES_WRITTEN_RENDERED == ranked_rows
      && AC_L7_SYMBOL_RANK_FILES_ACTUAL_RENDERED == ranked_rows;
   bool accepted_epoch_valid = (AC_L7_ACCEPTED_EPOCH_VALID_RENDERED == "true");

   AC_L7_GENERATION_COUNTS_OK_RENDERED = counts_ok && files_ok;
   AC_L7_GENERATION_IDENTITY_OK_RENDERED = identity_ok;
   if(files_ok) AC_L7LoadTop20Evidence();

   if(input_ok && manifest_ok && counts_ok && identity_ok && authority_ok && permission_ok && files_ok)
   {
      AC_L7AcceptCurrentEpoch();
      return;
   }

   if(input_ok && manifest_ok && counts_ok && !identity_ok && authority_ok && permission_ok && files_ok && accepted_epoch_valid)
   {
      AC_L7AcceptHeldEpoch();
      return;
   }

   AC_L7_RANKED_ACCEPTED = false;
   AC_L7_DISPLAY_STATE = accepted_epoch_valid ? "PENDING_RANK" : "DEGRADED_BROKEN";
   AC_L7_STATUS = accepted_epoch_valid ? "Ranked sidecar pending" : "Ranked sidecar degraded";
   AC_L7_TRUST_STATE = accepted_epoch_valid ? "Ranking Pending" : "Ranking Degraded";
   AC_L7_VALIDATION_STATUS = accepted_epoch_valid ? "Pending" : "Degraded";
   AC_L7_VALIDATION_REASON = "input_ok=" + (input_ok ? "true" : "false")
      + ";manifest_ok=" + (manifest_ok ? "true" : "false")
      + ";counts_ok=" + (counts_ok ? "true" : "false")
      + ";identity_ok=" + (identity_ok ? "true" : "false")
      + ";authority_ok=" + (authority_ok ? "true" : "false")
      + ";permission_ok=" + (permission_ok ? "true" : "false")
      + ";files_ok=" + (files_ok ? "true" : "false")
      + ";accepted_epoch_valid=" + (accepted_epoch_valid ? "true" : "false");
   AC_L7_MAIN_BLOCKER = AC_L7_VALIDATION_REASON;
   if(!files_ok) AC_L7_OPERATOR_SUMMARY = "Gateway ranked sidecar files are incomplete or missing";
   else if(!counts_ok) AC_L7_OPERATOR_SUMMARY = "Gateway ranked sidecar count contract mismatch";
   else if(!authority_ok || !permission_ok) AC_L7_OPERATOR_SUMMARY = "Gateway ranked sidecar permission or authority boundary mismatch";
   else if(!identity_ok && !accepted_epoch_valid) AC_L7_OPERATOR_SUMMARY = "Ranked sidecar complete but epoch is expired or unavailable; waiting for next accepted Gateway rank";
   else AC_L7_OPERATOR_SUMMARY = "Gateway ranked sidecar pending/degraded; see Workbench boolean ledger";
}

string AC_Layer7BoardSection()
{
   AC_L7RefreshRankedSidecar();
   string text = "";
   text += "\r\nLAYER 7 - SESSION RELEVANCE RANKING\r\n";
   text += "----------------------------------------\r\n";
   text += "Status:                     " + AC_L7_STATUS + "\r\n";
   text += "Display State:              " + AC_L7_DISPLAY_STATE + "\r\n";
   text += "Summary:                    " + AC_L7_OPERATOR_SUMMARY + "\r\n";
   text += "Gateway Result Accepted:    " + AC_L7BoolText(AC_L7_RANKED_ACCEPTED) + "\r\n";
   text += "Input Source:               Layer 5 pass set only\r\n";
   text += "Current L5 Pass Symbols:    " + IntegerToString(AC_L5_GATE_PASS) + "\r\n";
   text += "L7 Export L5 Pass Symbols:  " + IntegerToString(AC_L7_EXPORT_L5_PASS_RENDERED) + "\r\n";
   text += "Manifest Input Count:       " + IntegerToString(AC_L7_INPUT_ROWS_RENDERED) + "\r\n";
   text += "Ranked Symbols:             " + IntegerToString(AC_L7_RANKED_ROWS_RENDERED) + "\r\n";
   text += "Counts Contract:            " + (AC_L7_GENERATION_COUNTS_OK_RENDERED ? "OK" : "CHECK") + "\r\n";
   text += "Identity Contract:          " + (AC_L7_GENERATION_IDENTITY_OK_RENDERED ? "OK" : "CHECK") + "\r\n";
   text += "Latest Input Pending Rank:  " + AC_L7BoolText(AC_L7_LATEST_INPUT_PENDING_NEXT_RANK) + "\r\n";
   text += "Accepted Epoch Valid:       " + AC_L7BoolText(AC_L7_ACCEPTED_EPOCH_VALID_RENDERED == "true") + "\r\n";
   text += "Accepted Epoch Age Seconds: " + IntegerToString(AC_L7_ACCEPTED_EPOCH_AGE_SECONDS_RENDERED) + "\r\n";
   text += "Snapshot Drift:             " + (AC_L7_SNAPSHOT_DRIFT_RENDERED ? "YES" : "NO") + "\r\n";
   text += "Ranked Clean/Partial:       " + IntegerToString(AC_L7_RANKED_COUNT_RENDERED) + "\r\n";
   text += "Ranked Degraded:            " + IntegerToString(AC_L7_RANKED_DEGRADED_COUNT_RENDERED) + "\r\n";
   text += "Not Rankable Quality:       " + IntegerToString(AC_L7_NOT_RANKABLE_QUALITY_COUNT_RENDERED) + "\r\n";
   text += "Session Buckets:            elite=" + IntegerToString(AC_L7_ELITE_COUNT_RENDERED) + "; strong=" + IntegerToString(AC_L7_STRONG_COUNT_RENDERED) + "; acceptable=" + IntegerToString(AC_L7_ACCEPTABLE_COUNT_RENDERED) + "; weak=" + IntegerToString(AC_L7_WEAK_COUNT_RENDERED) + "; poor=" + IntegerToString(AC_L7_POOR_COUNT_RENDERED) + "\r\n";
   text += "SymbolRank Files:           " + IntegerToString(AC_L7_SYMBOL_RANK_FILES_ACTUAL_RENDERED) + " / " + IntegerToString(AC_L7_SYMBOL_RANK_FILES_WRITTEN_RENDERED) + " count_ok=" + AC_L7BoolText(AC_L7_SYMBOL_RANK_FILE_COUNT_OK_RENDERED == "true") + "\r\n";
   text += "Top Ranked Evidence:        " + AC_L7_TOP20_FIRST_LINE + "\r\n";
   text += "Current Global Session:     " + AC_L7_CURRENT_GLOBAL_SESSION_RENDERED + "\r\n";
   text += "Session Basis:              " + AC_L7_SESSION_TIME_BASIS_RENDERED + "\r\n";
   text += "Session Definition Source:  " + AC_L7_SESSION_DEFINITION_SOURCE_RENDERED + "\r\n";
   text += "Session Policy:             " + AC_L7_SESSION_PROFILE_POLICY_RENDERED + "\r\n";
   text += "Dead Time Meaning:          off-session caution; not a trade-time recommendation\r\n";
   text += "Diagnostics:                Workbench L7 section has full epoch and blocker ledger\r\n";
   text += "Gateway Job:                L7_SESSION_RELEVANCE_RANKING_V1\r\n";
   text += "Ranking Runtime:            " + AC_L7BoolText(AC_L7_RANKED_ACCEPTED) + "\r\n";
   text += "Selection Runtime:          FALSE\r\n";
   text += "Trade Permission:           FALSE\r\n";
   return text;
}

string AC_L7RenderRankEvidenceBlock(const string rank_text, const string rank_path, const string display_state)
{
   bool current = (display_state == "ACCEPTED_CURRENT");
   bool held = (display_state == "ACCEPTED_HELD_RECALC_PENDING");
   string prefix = current ? "" : "Last Accepted ";
   string evidence = current ? "accepted_current_epoch" : (held ? "accepted_held_recalc_pending" : "unaccepted_stale_or_mismatched_epoch");
   string text = "";
   text += "Rank Evidence: " + evidence + "\r\n";
   text += prefix + "Rank State: " + AC_L7KvValue(rank_text, "rank_state", "not_available") + "\r\n";
   text += prefix + "Rank Index: " + AC_L7KvValue(rank_text, "rank_index", "not_available") + " / " + IntegerToString(AC_L7_RANKED_ROWS_RENDERED) + "\r\n";
   text += prefix + "Session Score: " + AC_L7KvValue(rank_text, "session_score", "not_available") + "\r\n";
   text += prefix + "Session Confidence: " + AC_L7KvValue(rank_text, "session_relevance_confidence", "not_available") + "\r\n";
   text += prefix + "Session Bucket: " + AC_L7KvValue(rank_text, "session_bucket", "not_available") + "\r\n";
   text += prefix + "Score Quality: " + AC_L7KvValue(rank_text, "score_quality", "not_available") + "\r\n";
   text += prefix + "Current Session: " + AC_L7KvValue(rank_text, "current_session", "not_available") + "\r\n";
   text += prefix + "Session Minutes Elapsed: " + AC_L7KvValue(rank_text, "session_minutes_elapsed", "not_available") + "\r\n";
   text += prefix + "Session Minutes Remaining: " + AC_L7KvValue(rank_text, "session_minutes_remaining", "not_available") + "\r\n";
   text += "Session Definition Source: " + AC_L7KvValue(rank_text, "session_definition_source", "not_available") + "\r\n";
   text += "Session Time Basis: " + AC_L7KvValue(rank_text, "session_time_basis", "not_available") + "\r\n";
   text += "Time Basis Confidence: " + AC_L7KvValue(rank_text, "time_basis_confidence", "not_available") + "\r\n";
   text += "Symbol Session Fit Score: " + AC_L7KvValue(rank_text, "symbol_session_fit_score", "not_available") + "\r\n";
   text += "Live Activity Quality Score: " + AC_L7KvValue(rank_text, "live_activity_quality_score", "not_available") + "\r\n";
   text += "Quote Freshness Quality Score: " + AC_L7KvValue(rank_text, "quote_freshness_quality_score", "not_available") + "\r\n";
   text += "Spread Session Safety Score: " + AC_L7KvValue(rank_text, "spread_session_safety_score", "not_available") + "\r\n";
   text += "Tick Age Seconds: " + AC_L7KvValue(rank_text, "tick_age_seconds", "not_available") + "\r\n";
   text += "Spread BPS: " + AC_L7KvValue(rank_text, "spread_bps", "not_available") + "\r\n";
   text += "Quote Quality: " + AC_L7KvValue(rank_text, "quote_quality", "not_available") + "\r\n";
   text += "Surface Quality: " + AC_L7KvValue(rank_text, "surface_quality", "not_available") + "\r\n";
   text += "Reason: " + AC_L7KvValue(rank_text, "reason", "not_available") + "\r\n";
   text += "Rank Source: " + rank_path + "\r\n";
   return text;
}

string AC_Layer7DossierSection(const string symbol)
{
   AC_L7RefreshRankedSidecar();
   string l5_gate_status = "not_available";
   int l5_index = AC_L5FindIndex(symbol);
   if(l5_index >= 0) l5_gate_status = AC_L5_SYMBOLS[l5_index].pass ? "pass" : "not_pass";
   string text = "";
   text += "\r\nLAYER 7 - SESSION RELEVANCE RANKING\r\n";
   text += "----------------------------------------\r\n";
   text += "Status: " + AC_L7_STATUS + "\r\n";
   text += "Display State: " + AC_L7_DISPLAY_STATE + "\r\n";
   text += "Summary: " + AC_L7_OPERATOR_SUMMARY + "\r\n";
   text += "Owner: Runtime 4 - Surface Scoring Owner\r\n";
   text += "Gateway Result Accepted: " + AC_L7BoolText(AC_L7_RANKED_ACCEPTED) + "\r\n";
   text += "Validation: " + AC_L7_VALIDATION_STATUS + "\r\n";
   text += "L5 Gate Status: " + l5_gate_status + "\r\n";
   text += "Generation Counts OK: " + AC_L7BoolText(AC_L7_GENERATION_COUNTS_OK_RENDERED) + "\r\n";
   text += "Generation Identity OK: " + AC_L7BoolText(AC_L7_GENERATION_IDENTITY_OK_RENDERED) + "\r\n";
   text += "Latest Input Pending Next Rank: " + AC_L7BoolText(AC_L7_LATEST_INPUT_PENDING_NEXT_RANK) + "\r\n";
   text += "Accepted Epoch Valid: " + AC_L7BoolText(AC_L7_ACCEPTED_EPOCH_VALID_RENDERED == "true") + "\r\n";
   text += "Accepted Epoch Age Seconds: " + IntegerToString(AC_L7_ACCEPTED_EPOCH_AGE_SECONDS_RENDERED) + "\r\n";
   if(l5_gate_status != "pass")
   {
      text += "Rank Evidence: not_applicable\r\n";
      text += "Rank State: not_ranked_l5_gate_failed\r\n";
      text += "Session Score: not_available\r\n";
      text += "Session Bucket: not_available\r\n";
      text += "Note: Layer 7 ranks only the current Layer 5 pass set.\r\n";
   }
   else
   {
      string rank_path = AC_L7SymbolRankPathByFind(symbol);
      string rank_text = rank_path == "" ? "" : AC_L7ReadSmallTextFile(rank_path, 12000);
      if(rank_text == "")
      {
         text += "Rank Evidence: missing_symbol_sidecar\r\n";
         text += "Rank State: symbol_rank_sidecar_missing\r\n";
         text += "Session Score: missing\r\n";
         text += "Session Bucket: missing\r\n";
         text += "Validation Reason: " + AC_L7_VALIDATION_REASON + "\r\n";
      }
      else
      {
         if(AC_L7_DISPLAY_STATE == "ACCEPTED_HELD_RECALC_PENDING")
         {
            text += "Acceptance Note: symbol sidecar belongs to the last accepted epoch; newer L7 input is pending the next Gateway rank.\r\n";
            text += "Validation Reason: " + AC_L7_VALIDATION_REASON + "\r\n";
         }
         else if(!AC_L7_RANKED_ACCEPTED)
         {
            text += "Acceptance Note: symbol sidecar is not accepted because no valid current or held L7 epoch is available.\r\n";
            text += "Validation Reason: " + AC_L7_VALIDATION_REASON + "\r\n";
         }
         text += AC_L7RenderRankEvidenceBlock(rank_text, rank_path, AC_L7_DISPLAY_STATE);
      }
   }
   text += "Session Policy: " + AC_L7_SESSION_PROFILE_POLICY_RENDERED + "\r\n";
   text += "Dead Time Meaning: off-session caution; not a trade-time recommendation\r\n";
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
   text += "display_state=" + AC_L7_DISPLAY_STATE + "\r\n";
   text += "trust_state=" + AC_L7_TRUST_STATE + "\r\n";
   text += "validation_status=" + AC_L7_VALIDATION_STATUS + "\r\n";
   text += "validation_reason=" + AC_L7_VALIDATION_REASON + "\r\n";
   text += "operator_summary=" + AC_L7_OPERATOR_SUMMARY + "\r\n";
   text += "gateway_required=true\r\n";
   text += "gateway_result_accepted=" + AC_L7BoolKv(AC_L7_RANKED_ACCEPTED) + "\r\n";
   text += "job_type=L7_SESSION_RELEVANCE_RANKING_V1\r\n";
   text += "current_l5_pass_symbols=" + IntegerToString(AC_L5_GATE_PASS) + "\r\n";
   text += "l7_export_l5_pass_symbols=" + IntegerToString(AC_L7_EXPORT_L5_PASS_RENDERED) + "\r\n";
   text += "manifest_input_count=" + IntegerToString(AC_L7_INPUT_ROWS_RENDERED) + "\r\n";
   text += "input_counts_ok=" + AC_L7BoolKv(AC_L7_INPUT_COUNTS_OK_RENDERED) + "\r\n";
   text += "ranked_symbols=" + IntegerToString(AC_L7_RANKED_ROWS_RENDERED) + "\r\n";
   text += "ranked_count=" + IntegerToString(AC_L7_RANKED_COUNT_RENDERED) + "\r\n";
   text += "ranked_degraded_count=" + IntegerToString(AC_L7_RANKED_DEGRADED_COUNT_RENDERED) + "\r\n";
   text += "not_rankable_quality_count=" + IntegerToString(AC_L7_NOT_RANKABLE_QUALITY_COUNT_RENDERED) + "\r\n";
   text += "elite_session_relevance_count=" + IntegerToString(AC_L7_ELITE_COUNT_RENDERED) + "\r\n";
   text += "strong_session_relevance_count=" + IntegerToString(AC_L7_STRONG_COUNT_RENDERED) + "\r\n";
   text += "acceptable_session_relevance_count=" + IntegerToString(AC_L7_ACCEPTABLE_COUNT_RENDERED) + "\r\n";
   text += "weak_session_relevance_count=" + IntegerToString(AC_L7_WEAK_COUNT_RENDERED) + "\r\n";
   text += "poor_session_relevance_count=" + IntegerToString(AC_L7_POOR_COUNT_RENDERED) + "\r\n";
   text += "generation_counts_ok=" + AC_L7BoolKv(AC_L7_GENERATION_COUNTS_OK_RENDERED) + "\r\n";
   text += "generation_identity_ok=" + AC_L7BoolKv(AC_L7_GENERATION_IDENTITY_OK_RENDERED) + "\r\n";
   text += "latest_input_pending_next_rank=" + AC_L7BoolKv(AC_L7_LATEST_INPUT_PENDING_NEXT_RANK) + "\r\n";
   text += "accepted_epoch_present=" + AC_L7_ACCEPTED_EPOCH_PRESENT_RENDERED + "\r\n";
   text += "accepted_epoch_valid=" + AC_L7_ACCEPTED_EPOCH_VALID_RENDERED + "\r\n";
   text += "accepted_epoch_id=" + AC_L7_ACCEPTED_EPOCH_ID_RENDERED + "\r\n";
   text += "accepted_epoch_l7_status=" + AC_L7_ACCEPTED_EPOCH_L7_STATUS_RENDERED + "\r\n";
   text += "accepted_epoch_accepted_unix=" + IntegerToString(AC_L7_ACCEPTED_EPOCH_ACCEPTED_UNIX_RENDERED) + "\r\n";
   text += "accepted_epoch_valid_until_unix=" + IntegerToString(AC_L7_ACCEPTED_EPOCH_VALID_UNTIL_UNIX_RENDERED) + "\r\n";
   text += "accepted_epoch_age_seconds=" + IntegerToString(AC_L7_ACCEPTED_EPOCH_AGE_SECONDS_RENDERED) + "\r\n";
   text += "symbol_rank_filename_mode=" + AC_L7_SYMBOL_RANK_FILENAME_MODE_RENDERED + "\r\n";
   text += "symbol_rank_files_written=" + IntegerToString(AC_L7_SYMBOL_RANK_FILES_WRITTEN_RENDERED) + "\r\n";
   text += "symbol_rank_files_actual=" + IntegerToString(AC_L7_SYMBOL_RANK_FILES_ACTUAL_RENDERED) + "\r\n";
   text += "symbol_rank_file_count_ok=" + AC_L7_SYMBOL_RANK_FILE_COUNT_OK_RENDERED + "\r\n";
   text += "live_l5_drift=" + AC_L7BoolKv(AC_L7_SNAPSHOT_DRIFT_RENDERED) + "\r\n";
   text += "live_l5_drift_delta=" + IntegerToString(AC_L7_SNAPSHOT_DRIFT_DELTA_RENDERED) + "\r\n";
   text += "current_global_session=" + AC_L7_CURRENT_GLOBAL_SESSION_RENDERED + "\r\n";
   text += "latest_input_checksum=" + AC_L7_INPUT_PAYLOAD_CHECKSUM_RENDERED + "\r\n";
   text += "ranked_source_input_checksum=" + AC_L7_RANKED_SOURCE_INPUT_CHECKSUM_RENDERED + "\r\n";
   text += "ranked_payload_checksum=" + AC_L7_RANKED_PAYLOAD_CHECKSUM_RENDERED + "\r\n";
   text += "top_ranked=" + AC_L7_TOP20_FIRST_LINE + "\r\n";
   text += "input_manifest_path=Outbox\\Layers\\Layer_7_Session_Relevance_Ranking\\l7_input_primitives.manifest\r\n";
   text += "ranked_manifest_path=Outbox\\Layers\\Layer_7_Session_Relevance_Ranking\\ranked_symbols.manifest\r\n";
   text += "accepted_epoch_manifest_path=Outbox\\surface_accepted_epoch.manifest\r\n";
   text += "top20_path=Outbox\\Layers\\Layer_7_Session_Relevance_Ranking\\ranked_symbols_top20.txt\r\n";
   text += "symbol_rank_folder=Outbox\\Layers\\Layer_7_Session_Relevance_Ranking\\SymbolRanks\r\n";
   text += "session_time_basis=" + AC_L7_SESSION_TIME_BASIS_RENDERED + "\r\n";
   text += "session_definition_source=" + AC_L7_SESSION_DEFINITION_SOURCE_RENDERED + "\r\n";
   text += "session_profile_policy=" + AC_L7_SESSION_PROFILE_POLICY_RENDERED + "\r\n";
   text += "dead_time_meaning=off_session_caution_not_trade_time_recommendation\r\n";
   text += "main_blocker=" + AC_L7_MAIN_BLOCKER + "\r\n";
   text += "ranking_runtime=" + AC_L7BoolKv(AC_L7_RANKED_ACCEPTED) + "\r\n";
   text += "selection_runtime=false\r\n";
   text += "trade_permission=false\r\n";
   return text;
}

#endif
