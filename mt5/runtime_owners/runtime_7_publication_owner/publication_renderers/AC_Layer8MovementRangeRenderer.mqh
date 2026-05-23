#ifndef AC_LAYER8_MOVEMENT_RANGE_RENDERER_MQH
#define AC_LAYER8_MOVEMENT_RANGE_RENDERER_MQH

// Runtime 7 render-only surface for Layer 8 Movement / Range Ranking.
// Reads only OHLC priority-window availability plus L8 sidecar proof files.
// It must not calculate movement, rank, call CopyRates, select, permit, or execute.
// L8 display uses the Gateway accepted surface epoch to prevent false degraded flicker
// when the EA publishes a newer input manifest before the next Gateway rank completes.

static string AC_L8_STATUS = "Pending ranked sidecar";
static string AC_L8_TRUST_STATE = "Ranking Pending";
static string AC_L8_VALIDATION_STATUS = "Pending";
static string AC_L8_VALIDATION_REASON = "ranked_symbols.manifest missing or not accepted";
static string AC_L8_MAIN_BLOCKER = "ranked_symbols.manifest has not been accepted yet";
static string AC_L8_DISPLAY_STATE = "PENDING_RANK";
static bool   AC_L8_RANKED_ACCEPTED = false;
static bool   AC_L8_INPUT_COUNTS_OK_RENDERED = false;
static bool   AC_L8_GENERATION_COUNTS_OK_RENDERED = false;
static bool   AC_L8_GENERATION_IDENTITY_OK_RENDERED = false;
static bool   AC_L8_LATEST_INPUT_PENDING_NEXT_RANK = false;
static bool   AC_L8_ACCEPTED_HELD_RECALC_PENDING = false;
static bool   AC_L8_SNAPSHOT_DRIFT_RENDERED = false;
static int    AC_L8_SNAPSHOT_DRIFT_DELTA_RENDERED = 0;
static int    AC_L8_INPUT_ROWS_RENDERED = 0;
static int    AC_L8_EXPORT_L5_PASS_RENDERED = 0;
static int    AC_L8_RANKED_ROWS_RENDERED = 0;
static int    AC_L8_RANKED_COUNT_RENDERED = 0;
static int    AC_L8_RANKED_PARTIAL_COUNT_RENDERED = 0;
static int    AC_L8_RANKED_RISK_REVIEW_COUNT_RENDERED = 0;
static int    AC_L8_RANKED_DEGRADED_COUNT_RENDERED = 0;
static int    AC_L8_NOT_RANKABLE_QUALITY_COUNT_RENDERED = 0;
static int    AC_L8_ELITE_COUNT_RENDERED = 0;
static int    AC_L8_STRONG_COUNT_RENDERED = 0;
static int    AC_L8_ACCEPTABLE_COUNT_RENDERED = 0;
static int    AC_L8_WEAK_COUNT_RENDERED = 0;
static int    AC_L8_POOR_COUNT_RENDERED = 0;
static int    AC_L8_SYMBOL_RANK_FILES_WRITTEN_RENDERED = 0;
static int    AC_L8_SYMBOL_RANK_FILES_ACTUAL_RENDERED = 0;
static string AC_L8_SYMBOL_RANK_FILE_COUNT_OK_RENDERED = "false";
static string AC_L8_SYMBOL_RANK_FILENAME_MODE_RENDERED = "not_available";
static string AC_L8_INPUT_PAYLOAD_CHECKSUM_RENDERED = "not_available";
static string AC_L8_RANKED_PAYLOAD_CHECKSUM_RENDERED = "not_available";
static string AC_L8_RANKED_SOURCE_INPUT_CHECKSUM_RENDERED = "not_available";
static string AC_L8_RANKED_INPUT_CHECKSUM_RENDERED = "not_available";
static string AC_L8_RANKED_INPUT_CHECKSUM_AFTER_RENDERED = "not_available";
static string AC_L8_TOP20_FIRST_LINE = "not_available";
static int    AC_L8_OHLC_MIN_READY_RENDERED = 0;
static int    AC_L8_OHLC_M5_READY_RENDERED = 0;
static int    AC_L8_OHLC_M15_READY_RENDERED = 0;
static int    AC_L8_OHLC_H1_READY_RENDERED = 0;
static int    AC_L8_OHLC_H4_READY_RENDERED = 0;
static bool   AC_L8_ACCEPTED_EPOCH_PRESENT_RENDERED = false;
static bool   AC_L8_ACCEPTED_EPOCH_VALID_RENDERED = false;
static string AC_L8_ACCEPTED_EPOCH_STATUS_RENDERED = "not_available";
static string AC_L8_ACCEPTED_EPOCH_L8_STATUS_RENDERED = "not_available";
static int    AC_L8_ACCEPTED_EPOCH_ACCEPTED_UNIX_RENDERED = 0;
static int    AC_L8_ACCEPTED_EPOCH_VALID_UNTIL_UNIX_RENDERED = 0;
static int    AC_L8_ACCEPTED_EPOCH_AGE_SECONDS_RENDERED = -1;

string AC_L8LayerFolder(){ return AC_ExternalWorkerOutboxFolder() + "\\Layers\\Layer_8_Movement_Range_Ranking"; }
string AC_L8InputManifestPath(){ return AC_L8LayerFolder() + "\\l8_input_primitives.manifest"; }
string AC_L8RankedManifestPath(){ return AC_L8LayerFolder() + "\\ranked_symbols.manifest"; }
string AC_L8RankedCsvPath(){ return AC_L8LayerFolder() + "\\ranked_symbols.csv"; }
string AC_L8RankedTop20Path(){ return AC_L8LayerFolder() + "\\ranked_symbols_top20.txt"; }
string AC_L8SymbolRankFolderPath(){ return AC_L8LayerFolder() + "\\SymbolRanks"; }
string AC_L8SurfaceAcceptedEpochPath(){ return AC_ExternalWorkerOutboxFolder() + "\\surface_accepted_epoch.manifest"; }

string AC_L8ReadSmallTextFile(const string path, const int max_chars = 30000)
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

string AC_L8KvValue(const string text, const string key, const string fallback = "not_available")
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

int AC_L8KvInt(const string text, const string key, const int fallback = 0)
{
   string value = AC_L8KvValue(text, key, "");
   if(value == "") return fallback;
   return (int)StringToInteger(value);
}

string AC_L8BoolText(const bool value){ return value ? "TRUE" : "FALSE"; }
string AC_L8BoolKv(const bool value){ return value ? "true" : "false"; }
int AC_L8NowUnixSafe(){ return (int)TimeCurrent(); }

string AC_L8PipeField(const string pipe_text, const int index, const string fallback = "not_available")
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
   return value == "" ? fallback : value;
}

string AC_L8FirstTop20Symbol(const string top20_text)
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

string AC_L8SymbolRankPathByFind(const string symbol)
{
   string pattern = AC_L8SymbolRankFolderPath() + "\\" + AC_SanitizePathPart(symbol) + "__*.txt";
   string found = "";
   long handle = FileFindFirst(pattern, found, AC_CommonFlag());
   if(handle == INVALID_HANDLE) return "";
   FileFindClose(handle);
   if(found == "") return "";
   return AC_L8SymbolRankFolderPath() + "\\" + found;
}

bool AC_L8FastWindowAvailable(const string symbol, const string tf)
{
   return FileIsExist(AC_SharedOhlcFastWindowPath(symbol, tf), AC_CommonFlag());
}

string AC_L8PrettyRankState(string value)
{
   if(value == "ranked") return "Ranked";
   if(value == "ranked_partial") return "Ranked Partial";
   if(value == "ranked_risk_review" || value == "ranked_degraded") return "Risk Review";
   if(value == "not_rankable_quality") return "Not Rankable";
   StringReplace(value, "_", " ");
   return value;
}

string AC_L8PrettyBucket(string value)
{
   if(value == "elite_movement_range") return "Elite Movement / Range";
   if(value == "strong_movement_range") return "Strong Movement / Range";
   if(value == "acceptable_movement_range") return "Acceptable Movement / Range";
   if(value == "weak_movement_range") return "Weak Movement / Range";
   if(value == "poor_movement_range") return "Poor Movement / Range";
   StringReplace(value, "_", " ");
   return value;
}

string AC_L8PrettyRegime(string value)
{
   if(value == "violent_spike_risk") return "Violent Spike Risk";
   if(value == "choppy_range") return "Choppy Range";
   if(value == "compressed") return "Compressed";
   if(value == "clean_expansion") return "Clean Expansion";
   if(value == "normal") return "Normal";
   StringReplace(value, "_", " ");
   return value;
}

string AC_L8PrettyTop20Line(string pipe_line)
{
   if(pipe_line == "" || pipe_line == "not_available") return "not_available";
   string rank = AC_L8PipeField(pipe_line, 0, "");
   string symbol = AC_L8PipeField(pipe_line, 1, "");
   string score = AC_L8PipeField(pipe_line, 2, "");
   string bucket = AC_L8PipeField(pipe_line, 3, "");
   string state = AC_L8PipeField(pipe_line, 4, "");
   string regime = AC_L8PipeField(pipe_line, 5, "");
   if(rank == "" || symbol == "" || score == "" || bucket == "" || state == "" || regime == "") return "not_available";
   return "#" + rank + " " + symbol + " | " + score + " | " + AC_L8PrettyBucket(bucket) + " | " + AC_L8PrettyRankState(state) + " | " + AC_L8PrettyRegime(regime);
}

void AC_L8RefreshSurfaceAcceptedEpoch()
{
   AC_L8_ACCEPTED_EPOCH_PRESENT_RENDERED = false;
   AC_L8_ACCEPTED_EPOCH_VALID_RENDERED = false;
   AC_L8_ACCEPTED_EPOCH_STATUS_RENDERED = "not_available";
   AC_L8_ACCEPTED_EPOCH_L8_STATUS_RENDERED = "not_available";
   AC_L8_ACCEPTED_EPOCH_ACCEPTED_UNIX_RENDERED = 0;
   AC_L8_ACCEPTED_EPOCH_VALID_UNTIL_UNIX_RENDERED = 0;
   AC_L8_ACCEPTED_EPOCH_AGE_SECONDS_RENDERED = -1;

   string epoch_text = AC_L8ReadSmallTextFile(AC_L8SurfaceAcceptedEpochPath(), 12000);
   if(epoch_text == "") return;

   int now_unix = AC_L8NowUnixSafe();
   AC_L8_ACCEPTED_EPOCH_PRESENT_RENDERED = true;
   AC_L8_ACCEPTED_EPOCH_STATUS_RENDERED = AC_L8KvValue(epoch_text, "display_epoch_status", "not_available");
   AC_L8_ACCEPTED_EPOCH_L8_STATUS_RENDERED = AC_L8KvValue(epoch_text, "l8_status", "not_available");
   AC_L8_ACCEPTED_EPOCH_ACCEPTED_UNIX_RENDERED = AC_L8KvInt(epoch_text, "accepted_unix", 0);
   AC_L8_ACCEPTED_EPOCH_VALID_UNTIL_UNIX_RENDERED = AC_L8KvInt(epoch_text, "valid_until_unix", 0);
   if(AC_L8_ACCEPTED_EPOCH_ACCEPTED_UNIX_RENDERED > 0 && now_unix > 0)
      AC_L8_ACCEPTED_EPOCH_AGE_SECONDS_RENDERED = now_unix - AC_L8_ACCEPTED_EPOCH_ACCEPTED_UNIX_RENDERED;

   AC_L8_ACCEPTED_EPOCH_VALID_RENDERED = (
      AC_L8_ACCEPTED_EPOCH_STATUS_RENDERED == "accepted_current" &&
      AC_L8_ACCEPTED_EPOCH_L8_STATUS_RENDERED == "complete" &&
      AC_L8_ACCEPTED_EPOCH_VALID_UNTIL_UNIX_RENDERED > now_unix &&
      now_unix > 0
   );
}

bool AC_L8SurfaceEpochValidForL8()
{
   return AC_L8_ACCEPTED_EPOCH_VALID_RENDERED;
}

void AC_L8RefreshOhlcFastWindowReadiness()
{
   AC_L8_OHLC_MIN_READY_RENDERED = 0;
   AC_L8_OHLC_M5_READY_RENDERED = 0;
   AC_L8_OHLC_M15_READY_RENDERED = 0;
   AC_L8_OHLC_H1_READY_RENDERED = 0;
   AC_L8_OHLC_H4_READY_RENDERED = 0;
   for(int i = 0; i < ArraySize(AC_L5_SYMBOLS); i++)
   {
      if(!AC_L5_SYMBOLS[i].pass) continue;
      string symbol = AC_L5_SYMBOLS[i].symbol;
      bool m5 = AC_L8FastWindowAvailable(symbol, "M5");
      bool m15 = AC_L8FastWindowAvailable(symbol, "M15");
      bool h1 = AC_L8FastWindowAvailable(symbol, "H1");
      bool h4 = AC_L8FastWindowAvailable(symbol, "H4");
      if(m5) AC_L8_OHLC_M5_READY_RENDERED++;
      if(m15) AC_L8_OHLC_M15_READY_RENDERED++;
      if(h1) AC_L8_OHLC_H1_READY_RENDERED++;
      if(h4) AC_L8_OHLC_H4_READY_RENDERED++;
      if(m5 && m15 && h1) AC_L8_OHLC_MIN_READY_RENDERED++;
   }
}

void AC_L8ResetRenderState()
{
   AC_L8_STATUS = "Pending ranked sidecar";
   AC_L8_TRUST_STATE = "Ranking Pending";
   AC_L8_VALIDATION_STATUS = "Pending";
   AC_L8_VALIDATION_REASON = "ranked_symbols.manifest missing or not accepted";
   AC_L8_MAIN_BLOCKER = "ranked_symbols.manifest has not been accepted yet";
   AC_L8_DISPLAY_STATE = "PENDING_RANK";
   AC_L8_RANKED_ACCEPTED = false;
   AC_L8_INPUT_COUNTS_OK_RENDERED = false;
   AC_L8_GENERATION_COUNTS_OK_RENDERED = false;
   AC_L8_GENERATION_IDENTITY_OK_RENDERED = false;
   AC_L8_LATEST_INPUT_PENDING_NEXT_RANK = false;
   AC_L8_ACCEPTED_HELD_RECALC_PENDING = false;
   AC_L8_SNAPSHOT_DRIFT_RENDERED = false;
   AC_L8_SNAPSHOT_DRIFT_DELTA_RENDERED = 0;
   AC_L8_INPUT_ROWS_RENDERED = 0;
   AC_L8_EXPORT_L5_PASS_RENDERED = 0;
   AC_L8_RANKED_ROWS_RENDERED = 0;
   AC_L8_RANKED_COUNT_RENDERED = 0;
   AC_L8_RANKED_PARTIAL_COUNT_RENDERED = 0;
   AC_L8_RANKED_RISK_REVIEW_COUNT_RENDERED = 0;
   AC_L8_RANKED_DEGRADED_COUNT_RENDERED = 0;
   AC_L8_NOT_RANKABLE_QUALITY_COUNT_RENDERED = 0;
   AC_L8_ELITE_COUNT_RENDERED = 0;
   AC_L8_STRONG_COUNT_RENDERED = 0;
   AC_L8_ACCEPTABLE_COUNT_RENDERED = 0;
   AC_L8_WEAK_COUNT_RENDERED = 0;
   AC_L8_POOR_COUNT_RENDERED = 0;
   AC_L8_SYMBOL_RANK_FILES_WRITTEN_RENDERED = 0;
   AC_L8_SYMBOL_RANK_FILES_ACTUAL_RENDERED = 0;
   AC_L8_SYMBOL_RANK_FILE_COUNT_OK_RENDERED = "false";
   AC_L8_SYMBOL_RANK_FILENAME_MODE_RENDERED = "not_available";
   AC_L8_INPUT_PAYLOAD_CHECKSUM_RENDERED = "not_available";
   AC_L8_RANKED_PAYLOAD_CHECKSUM_RENDERED = "not_available";
   AC_L8_RANKED_SOURCE_INPUT_CHECKSUM_RENDERED = "not_available";
   AC_L8_RANKED_INPUT_CHECKSUM_RENDERED = "not_available";
   AC_L8_RANKED_INPUT_CHECKSUM_AFTER_RENDERED = "not_available";
   AC_L8_TOP20_FIRST_LINE = "not_available";
   AC_L8_ACCEPTED_EPOCH_PRESENT_RENDERED = false;
   AC_L8_ACCEPTED_EPOCH_VALID_RENDERED = false;
   AC_L8_ACCEPTED_EPOCH_STATUS_RENDERED = "not_available";
   AC_L8_ACCEPTED_EPOCH_L8_STATUS_RENDERED = "not_available";
   AC_L8_ACCEPTED_EPOCH_ACCEPTED_UNIX_RENDERED = 0;
   AC_L8_ACCEPTED_EPOCH_VALID_UNTIL_UNIX_RENDERED = 0;
   AC_L8_ACCEPTED_EPOCH_AGE_SECONDS_RENDERED = -1;
}

void AC_L8RefreshRankedSidecar()
{
   AC_L8ResetRenderState();
   AC_L8RefreshOhlcFastWindowReadiness();
   AC_L8RefreshSurfaceAcceptedEpoch();

   string input_manifest = AC_L8ReadSmallTextFile(AC_L8InputManifestPath(), 30000);
   if(input_manifest == "")
   {
      AC_L8_DISPLAY_STATE = "PENDING_RANK";
      AC_L8_VALIDATION_STATUS = "Missing";
      AC_L8_VALIDATION_REASON = "l8_input_primitives.manifest missing or unreadable";
      AC_L8_MAIN_BLOCKER = AC_L8_VALIDATION_REASON;
      return;
   }

   int input_rows = AC_L8KvInt(input_manifest, "row_count", 0);
   int input_l5_pass = AC_L8KvInt(input_manifest, "l5_gate_pass", 0);
   string input_write_ok = AC_L8KvValue(input_manifest, "write_ok", "false");
   string input_payload_checksum = AC_L8KvValue(input_manifest, "payload_checksum", "not_available");
   AC_L8_INPUT_ROWS_RENDERED = input_rows;
   AC_L8_EXPORT_L5_PASS_RENDERED = input_l5_pass;
   AC_L8_INPUT_PAYLOAD_CHECKSUM_RENDERED = input_payload_checksum;
   AC_L8_INPUT_COUNTS_OK_RENDERED = (input_write_ok == "true" && input_rows > 0 && input_rows == input_l5_pass);
   AC_L8_SNAPSHOT_DRIFT_RENDERED = (input_rows != AC_L5_GATE_PASS);
   AC_L8_SNAPSHOT_DRIFT_DELTA_RENDERED = input_rows - AC_L5_GATE_PASS;

   string ranked_manifest = AC_L8ReadSmallTextFile(AC_L8RankedManifestPath(), 30000);
   if(ranked_manifest == "")
   {
      AC_L8_DISPLAY_STATE = "PENDING_RANK";
      AC_L8_STATUS = "Input export ready - ranked sidecar pending";
      AC_L8_TRUST_STATE = "Ranking Pending";
      AC_L8_VALIDATION_STATUS = "InputAccepted";
      AC_L8_VALIDATION_REASON = "input manifest accepted; ranked_symbols.manifest missing or unreadable";
      AC_L8_MAIN_BLOCKER = "ranked_symbols.manifest has not been built or accepted yet";
      return;
   }

   string ranked_status = AC_L8KvValue(ranked_manifest, "status", "not_available");
   int ranked_input_count = AC_L8KvInt(ranked_manifest, "input_count", 0);
   int ranked_rows = AC_L8KvInt(ranked_manifest, "row_count", 0);
   int source_input_rows = AC_L8KvInt(ranked_manifest, "source_input_manifest_row_count", 0);
   int source_l5_gate_pass = AC_L8KvInt(ranked_manifest, "source_l5_gate_pass", 0);
   string source_input_checksum = AC_L8KvValue(ranked_manifest, "source_input_payload_checksum", "not_available");
   string ranked_input_checksum = AC_L8KvValue(ranked_manifest, "input_payload_checksum", "not_available");
   string ranked_input_checksum_after = AC_L8KvValue(ranked_manifest, "input_payload_checksum_after_rank", "not_available");
   string checksum_match_text = AC_L8KvValue(ranked_manifest, "input_payload_checksum_matches_source_manifest", "false");
   string ranked_payload_checksum = AC_L8KvValue(ranked_manifest, "payload_checksum", "not_available");
   string authority = AC_L8KvValue(ranked_manifest, "authority", "not_available");
   string trade_permission = AC_L8KvValue(ranked_manifest, "trade_permission", "not_available");
   string ranking_runtime = AC_L8KvValue(ranked_manifest, "ranking_runtime", "not_available");
   string selection_runtime = AC_L8KvValue(ranked_manifest, "selection_runtime", "not_available");

   AC_L8_RANKED_SOURCE_INPUT_CHECKSUM_RENDERED = source_input_checksum;
   AC_L8_RANKED_INPUT_CHECKSUM_RENDERED = ranked_input_checksum;
   AC_L8_RANKED_INPUT_CHECKSUM_AFTER_RENDERED = ranked_input_checksum_after;
   AC_L8_RANKED_ROWS_RENDERED = ranked_rows;
   AC_L8_RANKED_COUNT_RENDERED = AC_L8KvInt(ranked_manifest, "ranked_count", 0);
   AC_L8_RANKED_PARTIAL_COUNT_RENDERED = AC_L8KvInt(ranked_manifest, "ranked_partial_count", 0);
   AC_L8_RANKED_RISK_REVIEW_COUNT_RENDERED = AC_L8KvInt(ranked_manifest, "ranked_risk_review_count", AC_L8KvInt(ranked_manifest, "ranked_degraded_count", 0));
   AC_L8_RANKED_DEGRADED_COUNT_RENDERED = AC_L8KvInt(ranked_manifest, "ranked_degraded_count", 0);
   AC_L8_NOT_RANKABLE_QUALITY_COUNT_RENDERED = AC_L8KvInt(ranked_manifest, "not_rankable_quality_count", 0);
   AC_L8_ELITE_COUNT_RENDERED = AC_L8KvInt(ranked_manifest, "elite_movement_range_count", 0);
   AC_L8_STRONG_COUNT_RENDERED = AC_L8KvInt(ranked_manifest, "strong_movement_range_count", 0);
   AC_L8_ACCEPTABLE_COUNT_RENDERED = AC_L8KvInt(ranked_manifest, "acceptable_movement_range_count", 0);
   AC_L8_WEAK_COUNT_RENDERED = AC_L8KvInt(ranked_manifest, "weak_movement_range_count", 0);
   AC_L8_POOR_COUNT_RENDERED = AC_L8KvInt(ranked_manifest, "poor_movement_range_count", 0);
   AC_L8_SYMBOL_RANK_FILES_WRITTEN_RENDERED = AC_L8KvInt(ranked_manifest, "symbol_rank_files_written", 0);
   AC_L8_SYMBOL_RANK_FILES_ACTUAL_RENDERED = AC_L8KvInt(ranked_manifest, "symbol_rank_files_actual", 0);
   AC_L8_SYMBOL_RANK_FILE_COUNT_OK_RENDERED = AC_L8KvValue(ranked_manifest, "symbol_rank_file_count_ok", "false");
   AC_L8_SYMBOL_RANK_FILENAME_MODE_RENDERED = AC_L8KvValue(ranked_manifest, "symbol_rank_filename_mode", "not_available");
   AC_L8_RANKED_PAYLOAD_CHECKSUM_RENDERED = ranked_payload_checksum;

   bool input_ok = (input_write_ok == "true" && input_rows > 0 && input_rows == input_l5_pass);
   bool ohlc_ok = (AC_L8_OHLC_MIN_READY_RENDERED == AC_L5_GATE_PASS && AC_L5_GATE_PASS > 0);
   bool manifest_ok = (ranked_status == "complete" || ranked_status == "input_degraded");
   bool counts_ok = (ranked_input_count == ranked_rows && ranked_rows == input_rows && source_input_rows == input_rows && source_l5_gate_pass == input_l5_pass);
   bool identity_ok = (source_input_checksum == input_payload_checksum && input_payload_checksum != "not_available")
      || (checksum_match_text == "true" && ranked_input_checksum == input_payload_checksum && ranked_input_checksum_after == input_payload_checksum);
   bool authority_ok = (authority == AC_EXTERNAL_WORKER_AUTHORITY);
   bool permission_ok = (trade_permission == "false" && selection_runtime == "false" && ranking_runtime == "true");
   bool files_ok = FileIsExist(AC_L8RankedCsvPath(), AC_CommonFlag())
      && FileIsExist(AC_L8RankedTop20Path(), AC_CommonFlag())
      && AC_L8_SYMBOL_RANK_FILE_COUNT_OK_RENDERED == "true"
      && AC_L8_SYMBOL_RANK_FILES_WRITTEN_RENDERED == ranked_rows
      && AC_L8_SYMBOL_RANK_FILES_ACTUAL_RENDERED == ranked_rows;

   AC_L8_GENERATION_COUNTS_OK_RENDERED = counts_ok && files_ok;
   AC_L8_GENERATION_IDENTITY_OK_RENDERED = identity_ok;

   if(input_ok && ohlc_ok && manifest_ok && counts_ok && identity_ok && authority_ok && permission_ok && files_ok)
   {
      AC_L8_RANKED_ACCEPTED = true;
      AC_L8_DISPLAY_STATE = "ACCEPTED_CURRENT";
      AC_L8_STATUS = "Ranked sidecar accepted";
      AC_L8_TRUST_STATE = "Ranking Ready";
      AC_L8_VALIDATION_STATUS = "Accepted";
      AC_L8_VALIDATION_REASON = "ranked manifest/top20/csv/SymbolRanks sidecars match L8 input proof, OHLC priority windows, and permission boundaries";
      AC_L8_MAIN_BLOCKER = "none";
      AC_L8_TOP20_FIRST_LINE = AC_L8PrettyTop20Line(AC_L8FirstTop20Symbol(AC_L8ReadSmallTextFile(AC_L8RankedTop20Path(), 16000)));
      return;
   }

   bool identity_only_blocker = input_ok && ohlc_ok && manifest_ok && counts_ok && !identity_ok && authority_ok && permission_ok && files_ok;
   if(identity_only_blocker && AC_L8SurfaceEpochValidForL8())
   {
      AC_L8_RANKED_ACCEPTED = true;
      AC_L8_ACCEPTED_HELD_RECALC_PENDING = true;
      AC_L8_LATEST_INPUT_PENDING_NEXT_RANK = true;
      AC_L8_DISPLAY_STATE = "ACCEPTED_HELD_RECALC_PENDING";
      AC_L8_STATUS = "Ranked sidecar accepted - recalculation pending";
      AC_L8_TRUST_STATE = "Ranking Held";
      AC_L8_VALIDATION_STATUS = "AcceptedHeld";
      AC_L8_VALIDATION_REASON = "ranked sidecar belongs to last accepted L8 epoch; latest input checksum changed and is pending next Gateway rank";
      AC_L8_MAIN_BLOCKER = "none";
      AC_L8_TOP20_FIRST_LINE = AC_L8PrettyTop20Line(AC_L8FirstTop20Symbol(AC_L8ReadSmallTextFile(AC_L8RankedTop20Path(), 16000)));
      return;
   }

   AC_L8_DISPLAY_STATE = AC_L8_ACCEPTED_EPOCH_PRESENT_RENDERED && !AC_L8_ACCEPTED_EPOCH_VALID_RENDERED ? "EXPIRED_STALE" : "DEGRADED_BROKEN";
   AC_L8_STATUS = "Ranked sidecar degraded";
   AC_L8_TRUST_STATE = "Ranking Degraded";
   AC_L8_VALIDATION_STATUS = "Degraded";
   AC_L8_VALIDATION_REASON = "input_ok=" + (input_ok ? "true" : "false")
      + ";ohlc_ok=" + (ohlc_ok ? "true" : "false")
      + ";manifest_ok=" + (manifest_ok ? "true" : "false")
      + ";counts_ok=" + (counts_ok ? "true" : "false")
      + ";identity_ok=" + (identity_ok ? "true" : "false")
      + ";authority_ok=" + (authority_ok ? "true" : "false")
      + ";permission_ok=" + (permission_ok ? "true" : "false")
      + ";files_ok=" + (files_ok ? "true" : "false")
      + ";accepted_epoch_valid=" + (AC_L8_ACCEPTED_EPOCH_VALID_RENDERED ? "true" : "false");
   AC_L8_MAIN_BLOCKER = AC_L8_VALIDATION_REASON;
}

string AC_Layer8BoardSection()
{
   AC_L8RefreshRankedSidecar();
   string text = "";
   text += "\r\nLAYER 8 - MOVEMENT / RANGE RANKING\r\n";
   text += "----------------------------------------\r\n";
   text += "Status:                     " + AC_L8_STATUS + "\r\n";
   text += "Display State:              " + AC_L8_DISPLAY_STATE + "\r\n";
   text += "Trust:                      " + AC_L8_TRUST_STATE + "\r\n";
   text += "Validation:                 " + AC_L8_VALIDATION_STATUS + "\r\n";
   text += "Owner:                      Runtime 4 - Surface Scoring Owner\r\n";
   text += "Gateway Required:           TRUE\r\n";
   text += "Gateway Result Accepted:    " + AC_L8BoolText(AC_L8_RANKED_ACCEPTED) + "\r\n";
   text += "Latest Input Pending Rank:  " + AC_L8BoolText(AC_L8_LATEST_INPUT_PENDING_NEXT_RANK) + "\r\n";
   text += "Input Source:               Runtime 1 Shared OHLC Priority Windows + Layer 5 pass set\r\n";
   text += "Current L5 Pass Symbols:    " + IntegerToString(AC_L5_GATE_PASS) + "\r\n";
   text += "OHLC L8 Minimum Ready:      " + IntegerToString(AC_L8_OHLC_MIN_READY_RENDERED) + " / " + IntegerToString(AC_L5_GATE_PASS) + "\r\n";
   text += "M5 Windows Ready:           " + IntegerToString(AC_L8_OHLC_M5_READY_RENDERED) + " / " + IntegerToString(AC_L5_GATE_PASS) + "\r\n";
   text += "M15 Windows Ready:          " + IntegerToString(AC_L8_OHLC_M15_READY_RENDERED) + " / " + IntegerToString(AC_L5_GATE_PASS) + "\r\n";
   text += "H1 Windows Ready:           " + IntegerToString(AC_L8_OHLC_H1_READY_RENDERED) + " / " + IntegerToString(AC_L5_GATE_PASS) + "\r\n";
   text += "H4 Context Ready:           " + IntegerToString(AC_L8_OHLC_H4_READY_RENDERED) + " / " + IntegerToString(AC_L5_GATE_PASS) + "\r\n";
   text += "L8 Export L5 Pass Symbols:  " + IntegerToString(AC_L8_EXPORT_L5_PASS_RENDERED) + "\r\n";
   text += "Manifest Input Count:       " + IntegerToString(AC_L8_INPUT_ROWS_RENDERED) + "\r\n";
   text += "Ranked Symbols:             " + IntegerToString(AC_L8_RANKED_ROWS_RENDERED) + "\r\n";
   text += "Input Counts OK:            " + AC_L8BoolText(AC_L8_INPUT_COUNTS_OK_RENDERED) + "\r\n";
   text += "Generation Counts OK:       " + AC_L8BoolText(AC_L8_GENERATION_COUNTS_OK_RENDERED) + "\r\n";
   text += "Generation Identity OK:     " + AC_L8BoolText(AC_L8_GENERATION_IDENTITY_OK_RENDERED) + "\r\n";
   text += "Accepted Epoch Valid:       " + AC_L8BoolText(AC_L8_ACCEPTED_EPOCH_VALID_RENDERED) + "\r\n";
   text += "Accepted Epoch Age Sec:     " + IntegerToString(AC_L8_ACCEPTED_EPOCH_AGE_SECONDS_RENDERED) + "\r\n";
   text += "Accepted Epoch Until Unix:  " + IntegerToString(AC_L8_ACCEPTED_EPOCH_VALID_UNTIL_UNIX_RENDERED) + "\r\n";
   text += "L8 Snapshot Drift:          " + AC_L8BoolText(AC_L8_SNAPSHOT_DRIFT_RENDERED) + "\r\n";
   text += "L8 Drift Delta:             " + IntegerToString(AC_L8_SNAPSHOT_DRIFT_DELTA_RENDERED) + "\r\n";
   text += "Ranked Clean:               " + IntegerToString(AC_L8_RANKED_COUNT_RENDERED) + "\r\n";
   text += "Ranked Partial:             " + IntegerToString(AC_L8_RANKED_PARTIAL_COUNT_RENDERED) + "\r\n";
   text += "Risk Review:                " + IntegerToString(AC_L8_RANKED_RISK_REVIEW_COUNT_RENDERED) + "\r\n";
   text += "Not Rankable Quality:       " + IntegerToString(AC_L8_NOT_RANKABLE_QUALITY_COUNT_RENDERED) + "\r\n";
   text += "Elite Movement / Range:     " + IntegerToString(AC_L8_ELITE_COUNT_RENDERED) + "\r\n";
   text += "Strong Movement / Range:    " + IntegerToString(AC_L8_STRONG_COUNT_RENDERED) + "\r\n";
   text += "Acceptable Movement Range:  " + IntegerToString(AC_L8_ACCEPTABLE_COUNT_RENDERED) + "\r\n";
   text += "Weak Movement / Range:      " + IntegerToString(AC_L8_WEAK_COUNT_RENDERED) + "\r\n";
   text += "Poor Movement / Range:      " + IntegerToString(AC_L8_POOR_COUNT_RENDERED) + "\r\n";
   text += "SymbolRank Filename Mode:   " + AC_L8_SYMBOL_RANK_FILENAME_MODE_RENDERED + "\r\n";
   text += "SymbolRank Files Written:   " + IntegerToString(AC_L8_SYMBOL_RANK_FILES_WRITTEN_RENDERED) + "\r\n";
   text += "SymbolRank Files Actual:    " + IntegerToString(AC_L8_SYMBOL_RANK_FILES_ACTUAL_RENDERED) + "\r\n";
   text += "SymbolRank File Count OK:   " + AC_L8BoolText(AC_L8_SYMBOL_RANK_FILE_COUNT_OK_RENDERED == "true") + "\r\n";
   text += "Top Ranked:                 " + AC_L8_TOP20_FIRST_LINE + "\r\n";
   text += "Movement Policy:            ranking_only_no_direction_no_entry_no_selection_no_execution\r\n";
   text += "Ranked CSV:                 Outbox\\Layers\\Layer_8_Movement_Range_Ranking\\ranked_symbols.csv\r\n";
   text += "Manifest:                   Outbox\\Layers\\Layer_8_Movement_Range_Ranking\\ranked_symbols.manifest\r\n";
   text += "Top20:                      Outbox\\Layers\\Layer_8_Movement_Range_Ranking\\ranked_symbols_top20.txt\r\n";
   text += "Main Blocker:               " + AC_L8_MAIN_BLOCKER + "\r\n";
   text += "Gateway Job:                L8_MOVEMENT_RANGE_RANKING_V1\r\n";
   text += "Ranking Runtime:            " + AC_L8BoolText(AC_L8_RANKED_ACCEPTED) + "\r\n";
   text += "Selection Runtime:          FALSE\r\n";
   text += "Trade Permission:           FALSE\r\n";
   return text;
}

string AC_Layer8DossierSection(const string symbol)
{
   AC_L8RefreshRankedSidecar();
   string l5_gate_status = "not_available";
   int l5_index = AC_L5FindIndex(symbol);
   if(l5_index >= 0) l5_gate_status = AC_L5_SYMBOLS[l5_index].pass ? "pass" : "not_pass";
   bool m5 = AC_L8FastWindowAvailable(symbol, "M5");
   bool m15 = AC_L8FastWindowAvailable(symbol, "M15");
   bool h1 = AC_L8FastWindowAvailable(symbol, "H1");
   bool h4 = AC_L8FastWindowAvailable(symbol, "H4");
   bool ohlc_min = (m5 && m15 && h1);
   int priority = AC_SharedOhlcPriorityForSymbol(symbol);

   string text = "";
   text += "\r\nLAYER 8 - MOVEMENT / RANGE RANKING\r\n";
   text += "----------------------------------------\r\n";
   text += "Status: " + AC_L8_STATUS + "\r\n";
   text += "Display State: " + AC_L8_DISPLAY_STATE + "\r\n";
   text += "Owner: Runtime 4 - Surface Scoring Owner\r\n";
   text += "Gateway Result Accepted: " + AC_L8BoolText(AC_L8_RANKED_ACCEPTED) + "\r\n";
   text += "Latest Input Pending Rank: " + AC_L8BoolText(AC_L8_LATEST_INPUT_PENDING_NEXT_RANK) + "\r\n";
   text += "Validation: " + AC_L8_VALIDATION_STATUS + "\r\n";
   text += "Symbol Priority: " + AC_SharedOhlcPriorityLabel(priority) + "\r\n";
   text += "L5 Gate Status: " + l5_gate_status + "\r\n";
   text += "OHLC L8 Minimum Ready: " + AC_L8BoolText(ohlc_min) + "\r\n";
   text += "M5 Window: " + (m5 ? "available" : "pending") + "\r\n";
   text += "M15 Window: " + (m15 ? "available" : "pending") + "\r\n";
   text += "H1 Window: " + (h1 ? "available" : "pending") + "\r\n";
   text += "H4 Context Window: " + (h4 ? "available" : "pending") + "\r\n";
   text += "Generation Counts OK: " + AC_L8BoolText(AC_L8_GENERATION_COUNTS_OK_RENDERED) + "\r\n";
   text += "Generation Identity OK: " + AC_L8BoolText(AC_L8_GENERATION_IDENTITY_OK_RENDERED) + "\r\n";
   if(AC_L8_ACCEPTED_HELD_RECALC_PENDING)
      text += "Note: Symbol rank belongs to last accepted L8 epoch; newer input is waiting for next Gateway rank.\r\n";

   if(l5_gate_status != "pass")
   {
      text += "Rank State: not_ranked_l5_gate_failed\r\n";
      text += "Movement Score: not_available\r\n";
      text += "Movement Bucket: not_available\r\n";
   }
   else if(!ohlc_min && !AC_L8_ACCEPTED_HELD_RECALC_PENDING)
   {
      text += "Rank State: ohlc_priority_windows_pending\r\n";
      text += "Movement Score: pending\r\n";
      text += "Movement Bucket: pending\r\n";
   }
   else if(!AC_L8_RANKED_ACCEPTED)
   {
      text += "Rank State: ranked_sidecar_not_accepted\r\n";
      text += "Movement Score: pending\r\n";
      text += "Movement Bucket: pending\r\n";
      text += "Validation Reason: " + AC_L8_VALIDATION_REASON + "\r\n";
   }
   else
   {
      string rank_path = AC_L8SymbolRankPathByFind(symbol);
      string rank_text = rank_path == "" ? "" : AC_L8ReadSmallTextFile(rank_path, 14000);
      if(rank_text == "")
      {
         text += "Rank State: symbol_rank_sidecar_missing\r\n";
         text += "Movement Score: missing\r\n";
         text += "Movement Bucket: missing\r\n";
      }
      else
      {
         string raw_rank_state = AC_L8KvValue(rank_text, "rank_state", "not_available");
         text += "Symbol Review State: " + AC_L8PrettyRankState(raw_rank_state) + "\r\n";
         text += "Rank State: " + raw_rank_state + "\r\n";
         text += "Rank Index: " + AC_L8KvValue(rank_text, "rank_index", "not_available") + " / " + IntegerToString(AC_L8_RANKED_ROWS_RENDERED) + "\r\n";
         text += "Movement Score: " + AC_L8KvValue(rank_text, "movement_score", "not_available") + "\r\n";
         text += "Movement Bucket: " + AC_L8KvValue(rank_text, "movement_bucket", "not_available") + "\r\n";
         text += "Movement Regime: " + AC_L8PrettyRegime(AC_L8KvValue(rank_text, "movement_regime", "not_available")) + "\r\n";
         text += "Score Quality: " + AC_L8KvValue(rank_text, "score_quality", "not_available") + "\r\n";
         text += "Range Availability Score: " + AC_L8KvValue(rank_text, "range_availability_score", "not_available") + "\r\n";
         text += "Movement Quality Score: " + AC_L8KvValue(rank_text, "movement_quality_score", "not_available") + "\r\n";
         text += "Expansion / Compression Score: " + AC_L8KvValue(rank_text, "expansion_compression_score", "not_available") + "\r\n";
         text += "Range Position Quality Score: " + AC_L8KvValue(rank_text, "range_position_quality_score", "not_available") + "\r\n";
         text += "Quote / Surface Quality Score: " + AC_L8KvValue(rank_text, "quote_surface_quality_score", "not_available") + "\r\n";
         text += "M5 Bars Copied: " + AC_L8KvValue(rank_text, "m5_bars_copied", "not_available") + "\r\n";
         text += "M15 Bars Copied: " + AC_L8KvValue(rank_text, "m15_bars_copied", "not_available") + "\r\n";
         text += "H1 Bars Copied: " + AC_L8KvValue(rank_text, "h1_bars_copied", "not_available") + "\r\n";
         text += "M5 Expansion Ratio: " + AC_L8KvValue(rank_text, "m5_expansion_ratio", "not_available") + "\r\n";
         text += "M15 Expansion Ratio: " + AC_L8KvValue(rank_text, "m15_expansion_ratio", "not_available") + "\r\n";
         text += "H1 Expansion Ratio: " + AC_L8KvValue(rank_text, "h1_expansion_ratio", "not_available") + "\r\n";
         text += "M5 Range 48: " + AC_L8KvValue(rank_text, "m5_range_points_48", "not_available") + "\r\n";
         text += "M15 Range 64: " + AC_L8KvValue(rank_text, "m15_range_points_64", "not_available") + "\r\n";
         text += "H1 Range 72: " + AC_L8KvValue(rank_text, "h1_range_points_72", "not_available") + "\r\n";
         text += "Reason: " + AC_L8KvValue(rank_text, "reason", "not_available") + "\r\n";
         text += "Rank Source: " + rank_path + "\r\n";
      }
   }

   text += "Movement Policy: ranking only; no direction, entry, selection, permission, or execution\r\n";
   text += "Boundary:\r\n";
   text += "Source Owner: Runtime 1 Shared OHLC Priority Windows + Layer 5 pass set\r\n";
   text += "Scoring Owner: Runtime 4 - Surface Scoring Owner via Runtime 3 Gateway support\r\n";
   text += "Layer 8 Blocks Symbols: FALSE\r\n";
   text += "Selection Runtime: FALSE\r\n";
   text += "Trade Permission: FALSE\r\n";
   text += "Execution: FALSE\r\n";
   return text;
}

string AC_Layer8WorkbenchSection()
{
   AC_L8RefreshRankedSidecar();
   string text = "";
   text += "\r\nL8_MOVEMENT_RANGE_RANKING\r\n";
   text += "----------------------------------------\r\n";
   text += "owner_name=Runtime 4 - Surface Scoring Owner\r\n";
   text += "layer_name=Layer 8 - Movement / Range Ranking\r\n";
   text += "status=" + AC_L8_STATUS + "\r\n";
   text += "display_state=" + AC_L8_DISPLAY_STATE + "\r\n";
   text += "trust_state=" + AC_L8_TRUST_STATE + "\r\n";
   text += "validation_status=" + AC_L8_VALIDATION_STATUS + "\r\n";
   text += "validation_reason=" + AC_L8_VALIDATION_REASON + "\r\n";
   text += "gateway_required=true\r\n";
   text += "gateway_result_accepted=" + AC_L8BoolKv(AC_L8_RANKED_ACCEPTED) + "\r\n";
   text += "latest_input_pending_next_rank=" + AC_L8BoolKv(AC_L8_LATEST_INPUT_PENDING_NEXT_RANK) + "\r\n";
   text += "accepted_held_recalc_pending=" + AC_L8BoolKv(AC_L8_ACCEPTED_HELD_RECALC_PENDING) + "\r\n";
   text += "accepted_epoch_present=" + AC_L8BoolKv(AC_L8_ACCEPTED_EPOCH_PRESENT_RENDERED) + "\r\n";
   text += "accepted_epoch_valid=" + AC_L8BoolKv(AC_L8_ACCEPTED_EPOCH_VALID_RENDERED) + "\r\n";
   text += "accepted_epoch_status=" + AC_L8_ACCEPTED_EPOCH_STATUS_RENDERED + "\r\n";
   text += "accepted_epoch_l8_status=" + AC_L8_ACCEPTED_EPOCH_L8_STATUS_RENDERED + "\r\n";
   text += "accepted_epoch_age_seconds=" + IntegerToString(AC_L8_ACCEPTED_EPOCH_AGE_SECONDS_RENDERED) + "\r\n";
   text += "accepted_epoch_valid_until_unix=" + IntegerToString(AC_L8_ACCEPTED_EPOCH_VALID_UNTIL_UNIX_RENDERED) + "\r\n";
   text += "job_type=L8_MOVEMENT_RANGE_RANKING_V1\r\n";
   text += "current_l5_pass_symbols=" + IntegerToString(AC_L5_GATE_PASS) + "\r\n";
   text += "ohlc_l8_minimum_ready=" + IntegerToString(AC_L8_OHLC_MIN_READY_RENDERED) + "\r\n";
   text += "ohlc_l8_m5_ready=" + IntegerToString(AC_L8_OHLC_M5_READY_RENDERED) + "\r\n";
   text += "ohlc_l8_m15_ready=" + IntegerToString(AC_L8_OHLC_M15_READY_RENDERED) + "\r\n";
   text += "ohlc_l8_h1_ready=" + IntegerToString(AC_L8_OHLC_H1_READY_RENDERED) + "\r\n";
   text += "ohlc_l8_h4_ready=" + IntegerToString(AC_L8_OHLC_H4_READY_RENDERED) + "\r\n";
   text += "manifest_input_count=" + IntegerToString(AC_L8_INPUT_ROWS_RENDERED) + "\r\n";
   text += "input_counts_ok=" + AC_L8BoolKv(AC_L8_INPUT_COUNTS_OK_RENDERED) + "\r\n";
   text += "ranked_symbols=" + IntegerToString(AC_L8_RANKED_ROWS_RENDERED) + "\r\n";
   text += "ranked_count=" + IntegerToString(AC_L8_RANKED_COUNT_RENDERED) + "\r\n";
   text += "ranked_partial_count=" + IntegerToString(AC_L8_RANKED_PARTIAL_COUNT_RENDERED) + "\r\n";
   text += "ranked_risk_review_count=" + IntegerToString(AC_L8_RANKED_RISK_REVIEW_COUNT_RENDERED) + "\r\n";
   text += "legacy_ranked_degraded_count=" + IntegerToString(AC_L8_RANKED_DEGRADED_COUNT_RENDERED) + "\r\n";
   text += "not_rankable_quality_count=" + IntegerToString(AC_L8_NOT_RANKABLE_QUALITY_COUNT_RENDERED) + "\r\n";
   text += "elite_movement_range_count=" + IntegerToString(AC_L8_ELITE_COUNT_RENDERED) + "\r\n";
   text += "strong_movement_range_count=" + IntegerToString(AC_L8_STRONG_COUNT_RENDERED) + "\r\n";
   text += "acceptable_movement_range_count=" + IntegerToString(AC_L8_ACCEPTABLE_COUNT_RENDERED) + "\r\n";
   text += "weak_movement_range_count=" + IntegerToString(AC_L8_WEAK_COUNT_RENDERED) + "\r\n";
   text += "poor_movement_range_count=" + IntegerToString(AC_L8_POOR_COUNT_RENDERED) + "\r\n";
   text += "generation_counts_ok=" + AC_L8BoolKv(AC_L8_GENERATION_COUNTS_OK_RENDERED) + "\r\n";
   text += "generation_identity_ok=" + AC_L8BoolKv(AC_L8_GENERATION_IDENTITY_OK_RENDERED) + "\r\n";
   text += "latest_input_checksum=" + AC_L8_INPUT_PAYLOAD_CHECKSUM_RENDERED + "\r\n";
   text += "ranked_source_input_checksum=" + AC_L8_RANKED_SOURCE_INPUT_CHECKSUM_RENDERED + "\r\n";
   text += "ranked_input_checksum=" + AC_L8_RANKED_INPUT_CHECKSUM_RENDERED + "\r\n";
   text += "ranked_input_checksum_after=" + AC_L8_RANKED_INPUT_CHECKSUM_AFTER_RENDERED + "\r\n";
   text += "symbol_rank_filename_mode=" + AC_L8_SYMBOL_RANK_FILENAME_MODE_RENDERED + "\r\n";
   text += "symbol_rank_files_written=" + IntegerToString(AC_L8_SYMBOL_RANK_FILES_WRITTEN_RENDERED) + "\r\n";
   text += "symbol_rank_files_actual=" + IntegerToString(AC_L8_SYMBOL_RANK_FILES_ACTUAL_RENDERED) + "\r\n";
   text += "symbol_rank_file_count_ok=" + AC_L8_SYMBOL_RANK_FILE_COUNT_OK_RENDERED + "\r\n";
   text += "live_l5_drift=" + AC_L8BoolKv(AC_L8_SNAPSHOT_DRIFT_RENDERED) + "\r\n";
   text += "live_l5_drift_delta=" + IntegerToString(AC_L8_SNAPSHOT_DRIFT_DELTA_RENDERED) + "\r\n";
   text += "source_input_payload_checksum=" + AC_L8_INPUT_PAYLOAD_CHECKSUM_RENDERED + "\r\n";
   text += "ranked_payload_checksum=" + AC_L8_RANKED_PAYLOAD_CHECKSUM_RENDERED + "\r\n";
   text += "top_ranked=" + AC_L8_TOP20_FIRST_LINE + "\r\n";
   text += "input_manifest_path=Outbox\\Layers\\Layer_8_Movement_Range_Ranking\\l8_input_primitives.manifest\r\n";
   text += "ranked_manifest_path=Outbox\\Layers\\Layer_8_Movement_Range_Ranking\\ranked_symbols.manifest\r\n";
   text += "top20_path=Outbox\\Layers\\Layer_8_Movement_Range_Ranking\\ranked_symbols_top20.txt\r\n";
   text += "symbol_rank_folder=Outbox\\Layers\\Layer_8_Movement_Range_Ranking\\SymbolRanks\r\n";
   text += "surface_accepted_epoch_path=Outbox\\surface_accepted_epoch.manifest\r\n";
   text += "movement_policy=ranking_only_no_direction_no_entry_no_selection_no_execution\r\n";
   text += "main_blocker=" + AC_L8_MAIN_BLOCKER + "\r\n";
   text += "ranking_runtime=" + AC_L8BoolKv(AC_L8_RANKED_ACCEPTED) + "\r\n";
   text += "selection_runtime=false\r\n";
   text += "trade_permission=false\r\n";
   return text;
}

#endif
