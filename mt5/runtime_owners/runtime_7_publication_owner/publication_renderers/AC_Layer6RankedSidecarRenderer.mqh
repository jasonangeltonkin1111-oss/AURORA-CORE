#ifndef AC_LAYER6_RANKED_SIDECAR_RENDERER_MQH
#define AC_LAYER6_RANKED_SIDECAR_RENDERER_MQH

#include "../../runtime_3_external_calculation_worker_owner/AC_ExternalWorkerRenderIndex.mqh"

// Runtime 7 render-only surface for Layer 6 Cost / Friction Ranking.
// Recovery note: this file was restored after a partial overwrite regression.
// It renders prepared Runtime 3/Gateway sidecar/index truth only. It must not score,
// select, permit, execute, poll broker APIs, or own FileIO/routes.

static string AC_RUNTIME4_OWNER = "Runtime 4 - Surface Scoring Owner";
static string AC_LAYER_6_NAME = "Layer 6 - Cost / Friction Ranking";
static string AC_L6_STATUS = "Pending ranked sidecar";
static string AC_L6_TRUST_STATE = "Ranking Pending";
static string AC_L6_VALIDATION_STATUS = "Pending";
static string AC_L6_VALIDATION_REASON = "ranked sidecar not checked yet";
static string AC_L6_MAIN_BLOCKER = "ranked_symbols.manifest has not been accepted yet";
static string AC_L6_JOB_TYPE = "L6_COST_FRICTION_RANKING_V1";
static string AC_L6_EXPECTED_OUTPUT = "ranked_symbols_csv_manifest_top20_symbol_rank_sidecars";
static string AC_L6_RANKED_CSV_PATH = "Outbox\\Layers\\Layer_6_Cost_Friction_Ranking\\ranked_symbols.csv";
static string AC_L6_RANKED_MANIFEST_PATH = "Outbox\\Layers\\Layer_6_Cost_Friction_Ranking\\ranked_symbols.manifest";
static string AC_L6_TOP20_PATH = "Outbox\\Layers\\Layer_6_Cost_Friction_Ranking\\ranked_symbols_top20.txt";
static string AC_L6_SYMBOL_RANK_FOLDER = "Outbox\\Layers\\Layer_6_Cost_Friction_Ranking\\SymbolRanks";
static string AC_L6_SYMBOL_RANK_FILENAME_MODE_EXPECTED = "sanitized_symbol__payload_checksum";
static string AC_L6_MANIFEST_PAYLOAD_CHECKSUM = "not_available";
static string AC_L6_MANIFEST_STATUS = "not_loaded";
static string AC_L6_MANIFEST_REASON = "not_loaded";
static string AC_L6_MANIFEST_SYMBOL_RANK_FILENAME_MODE = "not_available";
static string AC_L6_TOP20_FIRST_LINE = "not_available";
static int AC_L6_INPUT_L5_PASS_SYMBOLS = 0;
static int AC_L6_MANIFEST_INPUT_COUNT = 0;
static int AC_L6_RANKED_SYMBOLS = 0;
static int AC_L6_RANKED_DEGRADED_SYMBOLS = 0;
static int AC_L6_NOT_RANKABLE_QUALITY_SYMBOLS = 0;
static int AC_L6_ELITE_FRICTION_COUNT = 0;
static int AC_L6_GOOD_FRICTION_COUNT = 0;
static int AC_L6_ACCEPTABLE_FRICTION_COUNT = 0;
static int AC_L6_EXPENSIVE_FRICTION_COUNT = 0;
static int AC_L6_HOSTILE_FRICTION_COUNT = 0;
static int AC_L6_ZERO_COST_SUSPICIOUS_COUNT = 0;
static int AC_L6_COST_MODEL_MISMATCH_COUNT = 0;
static int AC_L6_SYMBOL_RANK_FILES_WRITTEN = 0;
static int AC_L6_SYMBOL_RANK_FILES_ACTUAL = 0;
static int AC_L6_SOURCE_INPUT_MANIFEST_ROW_COUNT = 0;
static int AC_L6_SOURCE_L5_GATE_PASS = 0;
static string AC_L6_SOURCE_INPUT_PAYLOAD_CHECKSUM = "not_available";
static bool AC_L6_INPUT_COUNT_MATCHES_INPUT_MANIFEST = false;
static bool AC_L6_INPUT_COUNT_MATCHES_SOURCE_L5_GATE_PASS = false;
static bool AC_L6_SYMBOL_RANK_FILE_COUNT_OK = false;
static bool AC_L6_GENERATION_COUNTS_OK = false;
static bool AC_L6_LIVE_L5_DRIFT = false;
static int AC_L6_LIVE_L5_DRIFT_DELTA = 0;
static bool AC_L6_RANKED_ACCEPTED = false;
static uint AC_L6_CALCULATION_DURATION_MS = 0;
static long AC_L6_LAST_REFRESH_HEARTBEAT_ID = -1;

string AC_L6RankedLayerFolder()
{
   return AC_ExternalWorkerOutboxFolder() + "\\Layers\\Layer_6_Cost_Friction_Ranking";
}

string AC_L6RankedManifestPath()
{
   return AC_L6RankedLayerFolder() + "\\ranked_symbols.manifest";
}

string AC_L6RankedCsvPath()
{
   return AC_L6RankedLayerFolder() + "\\ranked_symbols.csv";
}

string AC_L6RankedTop20Path()
{
   return AC_L6RankedLayerFolder() + "\\ranked_symbols_top20.txt";
}

string AC_L6SymbolRankFolderPath()
{
   return AC_L6RankedLayerFolder() + "\\SymbolRanks";
}

string AC_L6SymbolRankChecksum(const string symbol)
{
   string payload = symbol + "\r\n";
   long checksum = 0;
   for(int i = 0; i < StringLen(payload); i++)
   {
      int ch = StringGetCharacter(payload, i);
      checksum = (checksum + ((long)ch * (long)(i + 1))) % 2147483647;
   }
   return IntegerToString((int)checksum);
}

string AC_L6SymbolRankFilename(const string symbol)
{
   return AC_SanitizePathPart(symbol) + "__" + AC_L6SymbolRankChecksum(symbol) + ".txt";
}

string AC_L6SymbolRankPath(const string symbol)
{
   return AC_L6SymbolRankFolderPath() + "\\" + AC_L6SymbolRankFilename(symbol);
}

string AC_L6ReadSmallTextFile(const string path, const int max_chars = 120000)
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

string AC_L6KvValue(const string text, const string key, const string fallback = "not_available")
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

int AC_L6KvInt(const string text, const string key, const int fallback = 0)
{
   string value = AC_L6KvValue(text, key, "");
   if(value == "") return fallback;
   return (int)StringToInteger(value);
}

string AC_L6FirstTop20Symbol(const string top20_text)
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

void AC_RefreshLayer6RankedSidecar()
{
   if(AC_L6_LAST_REFRESH_HEARTBEAT_ID == AC_HEARTBEAT_ID) return;
   AC_L6_LAST_REFRESH_HEARTBEAT_ID = AC_HEARTBEAT_ID;

   AC_L6_INPUT_L5_PASS_SYMBOLS = AC_L5_GATE_PASS;
   AC_L6_RANKED_ACCEPTED = false;
   AC_L6_STATUS = "Pending ranked sidecar";
   AC_L6_TRUST_STATE = "Ranking Pending";
   AC_L6_VALIDATION_STATUS = "Pending";
   AC_L6_VALIDATION_REASON = "ranked_symbols.manifest missing or not accepted";
   AC_L6_MAIN_BLOCKER = "ranked_symbols.manifest has not been accepted yet";
   AC_L6_MANIFEST_STATUS = "not_loaded";
   AC_L6_MANIFEST_REASON = "not_loaded";
   AC_L6_MANIFEST_SYMBOL_RANK_FILENAME_MODE = "not_available";
   AC_L6_MANIFEST_INPUT_COUNT = 0;
   AC_L6_RANKED_SYMBOLS = 0;
   AC_L6_RANKED_DEGRADED_SYMBOLS = 0;
   AC_L6_NOT_RANKABLE_QUALITY_SYMBOLS = 0;
   AC_L6_ELITE_FRICTION_COUNT = 0;
   AC_L6_GOOD_FRICTION_COUNT = 0;
   AC_L6_ACCEPTABLE_FRICTION_COUNT = 0;
   AC_L6_EXPENSIVE_FRICTION_COUNT = 0;
   AC_L6_HOSTILE_FRICTION_COUNT = 0;
   AC_L6_ZERO_COST_SUSPICIOUS_COUNT = 0;
   AC_L6_COST_MODEL_MISMATCH_COUNT = 0;
   AC_L6_SYMBOL_RANK_FILES_WRITTEN = 0;
   AC_L6_SYMBOL_RANK_FILES_ACTUAL = 0;
   AC_L6_SOURCE_INPUT_MANIFEST_ROW_COUNT = 0;
   AC_L6_SOURCE_L5_GATE_PASS = 0;
   AC_L6_SOURCE_INPUT_PAYLOAD_CHECKSUM = "not_available";
   AC_L6_INPUT_COUNT_MATCHES_INPUT_MANIFEST = false;
   AC_L6_INPUT_COUNT_MATCHES_SOURCE_L5_GATE_PASS = false;
   AC_L6_SYMBOL_RANK_FILE_COUNT_OK = false;
   AC_L6_GENERATION_COUNTS_OK = false;
   AC_L6_LIVE_L5_DRIFT = false;
   AC_L6_LIVE_L5_DRIFT_DELTA = 0;
   AC_L6_MANIFEST_PAYLOAD_CHECKSUM = "not_available";
   AC_L6_TOP20_FIRST_LINE = "not_available";

   string manifest = AC_L6ReadSmallTextFile(AC_L6RankedManifestPath(), 30000);
   if(manifest == "")
   {
      AC_L6_VALIDATION_STATUS = "Missing";
      AC_L6_VALIDATION_REASON = "ranked_symbols.manifest missing or unreadable";
      AC_L6_MAIN_BLOCKER = AC_L6_VALIDATION_REASON;
      return;
   }

   AC_L6_MANIFEST_STATUS = AC_L6KvValue(manifest, "status", "not_available");
   AC_L6_MANIFEST_REASON = AC_L6KvValue(manifest, "reason", "not_available");
   AC_L6_MANIFEST_INPUT_COUNT = AC_L6KvInt(manifest, "input_count", 0);
   AC_L6_RANKED_SYMBOLS = AC_L6KvInt(manifest, "row_count", 0);
   AC_L6_RANKED_DEGRADED_SYMBOLS = AC_L6KvInt(manifest, "ranked_degraded_count", 0);
   AC_L6_NOT_RANKABLE_QUALITY_SYMBOLS = AC_L6KvInt(manifest, "not_rankable_quality_count", 0);
   AC_L6_ELITE_FRICTION_COUNT = AC_L6KvInt(manifest, "elite_friction_count", 0);
   AC_L6_GOOD_FRICTION_COUNT = AC_L6KvInt(manifest, "good_friction_count", 0);
   AC_L6_ACCEPTABLE_FRICTION_COUNT = AC_L6KvInt(manifest, "acceptable_friction_count", 0);
   AC_L6_EXPENSIVE_FRICTION_COUNT = AC_L6KvInt(manifest, "expensive_friction_count", 0);
   AC_L6_HOSTILE_FRICTION_COUNT = AC_L6KvInt(manifest, "hostile_friction_count", 0);
   AC_L6_ZERO_COST_SUSPICIOUS_COUNT = AC_L6KvInt(manifest, "zero_cost_nonzero_spread_suspicious_count", 0);
   AC_L6_COST_MODEL_MISMATCH_COUNT = AC_L6KvInt(manifest, "cost_model_mismatch_count", 0);
   AC_L6_SYMBOL_RANK_FILES_WRITTEN = AC_L6KvInt(manifest, "symbol_rank_files_written", 0);
   AC_L6_SYMBOL_RANK_FILES_ACTUAL = AC_L6KvInt(manifest, "symbol_rank_files_actual", 0);
   AC_L6_MANIFEST_SYMBOL_RANK_FILENAME_MODE = AC_L6KvValue(manifest, "symbol_rank_filename_mode", "not_available");
   AC_L6_SYMBOL_RANK_FILE_COUNT_OK = (AC_L6KvValue(manifest, "symbol_rank_file_count_ok", "false") == "true");
   AC_L6_SOURCE_INPUT_MANIFEST_ROW_COUNT = AC_L6KvInt(manifest, "source_input_manifest_row_count", 0);
   AC_L6_SOURCE_L5_GATE_PASS = AC_L6KvInt(manifest, "source_l5_gate_pass", 0);
   AC_L6_SOURCE_INPUT_PAYLOAD_CHECKSUM = AC_L6KvValue(manifest, "source_input_payload_checksum", "not_available");
   AC_L6_INPUT_COUNT_MATCHES_INPUT_MANIFEST = (AC_L6KvValue(manifest, "input_csv_count_matches_input_manifest", "false") == "true");
   AC_L6_INPUT_COUNT_MATCHES_SOURCE_L5_GATE_PASS = (AC_L6KvValue(manifest, "input_csv_count_matches_source_l5_gate_pass", "false") == "true");
   AC_L6_MANIFEST_PAYLOAD_CHECKSUM = AC_L6KvValue(manifest, "payload_checksum", "not_available");

   string authority = AC_L6KvValue(manifest, "authority", "not_available");
   string trade_permission = AC_L6KvValue(manifest, "trade_permission", "not_available");
   string ranking_runtime = AC_L6KvValue(manifest, "ranking_runtime", "not_available");
   string selection_runtime = AC_L6KvValue(manifest, "selection_runtime", "not_available");

   bool manifest_ok = (AC_L6_MANIFEST_STATUS == "complete");
   bool counts_ok = (AC_L6_MANIFEST_INPUT_COUNT == AC_L6_RANKED_SYMBOLS && AC_L6_RANKED_SYMBOLS > 0);
   bool source_ok = (AC_L6_SOURCE_INPUT_MANIFEST_ROW_COUNT == AC_L6_MANIFEST_INPUT_COUNT && AC_L6_SOURCE_L5_GATE_PASS == AC_L6_MANIFEST_INPUT_COUNT);
   bool flags_ok = (AC_L6_INPUT_COUNT_MATCHES_INPUT_MANIFEST && AC_L6_INPUT_COUNT_MATCHES_SOURCE_L5_GATE_PASS);
   AC_L6_GENERATION_COUNTS_OK = (counts_ok && source_ok && flags_ok);
   AC_L6_LIVE_L5_DRIFT = (AC_L6_RANKED_SYMBOLS != AC_L5_GATE_PASS);
   AC_L6_LIVE_L5_DRIFT_DELTA = AC_L6_RANKED_SYMBOLS - AC_L5_GATE_PASS;
   bool authority_ok = (authority == AC_EXTERNAL_WORKER_AUTHORITY);
   bool permission_ok = (trade_permission == "false" && selection_runtime == "false" && ranking_runtime == "true");
   bool files_ok = FileIsExist(AC_L6RankedCsvPath(), AC_CommonFlag()) && FileIsExist(AC_L6RankedTop20Path(), AC_CommonFlag());
   bool symbol_files_ok = (AC_L6_SYMBOL_RANK_FILES_WRITTEN == AC_L6_RANKED_SYMBOLS && AC_L6_SYMBOL_RANK_FILES_ACTUAL == AC_L6_RANKED_SYMBOLS && AC_L6_SYMBOL_RANK_FILE_COUNT_OK);

   if(manifest_ok && AC_L6_GENERATION_COUNTS_OK && authority_ok && permission_ok && files_ok && symbol_files_ok)
   {
      AC_L6_RANKED_ACCEPTED = true;
      AC_L6_STATUS = AC_L6_LIVE_L5_DRIFT ? "Ranked sidecar accepted - L5 drift" : "Ranked sidecar accepted";
      AC_L6_TRUST_STATE = AC_L6_LIVE_L5_DRIFT ? "Ranking Ready With Drift" : "Ranking Ready";
      AC_L6_VALIDATION_STATUS = AC_L6_LIVE_L5_DRIFT ? "AcceptedWithDrift" : "Accepted";
      AC_L6_VALIDATION_REASON = AC_L6_LIVE_L5_DRIFT ? "ranked sidecar matches exported L6 input generation; current live L5 pass count drifted after export" : "ranked sidecar matches exported L6 input generation and current L5 pass count";
      AC_L6_MAIN_BLOCKER = AC_L6_LIVE_L5_DRIFT ? "none_l6_snapshot_valid_current_l5_drift=true" : "none";
      AC_L6_TOP20_FIRST_LINE = AC_L6FirstTop20Symbol(AC_L6ReadSmallTextFile(AC_L6RankedTop20Path(), 16000));
      return;
   }

   AC_L6_STATUS = "Ranked sidecar degraded";
   AC_L6_TRUST_STATE = "Ranking Degraded";
   AC_L6_VALIDATION_STATUS = "Degraded";
   AC_L6_VALIDATION_REASON = "manifest_ok=" + (manifest_ok ? "true" : "false")
      + ";generation_counts_ok=" + (AC_L6_GENERATION_COUNTS_OK ? "true" : "false")
      + ";authority_ok=" + (authority_ok ? "true" : "false")
      + ";permission_ok=" + (permission_ok ? "true" : "false")
      + ";files_ok=" + (files_ok ? "true" : "false")
      + ";symbol_files_ok=" + (symbol_files_ok ? "true" : "false")
      + ";live_l5_drift=" + (AC_L6_LIVE_L5_DRIFT ? "true" : "false");
   AC_L6_MAIN_BLOCKER = AC_L6_VALIDATION_REASON;
}

string AC_Layer6BoardSection()
{
   AC_RefreshLayer6RankedSidecar();
   string text = "\r\nLAYER 6 - COST / FRICTION RANKING\r\n";
   text += "----------------------------------------\r\n";
   text += "Status:                     " + AC_L6_STATUS + "\r\n";
   text += "Trust:                      " + AC_L6_TRUST_STATE + "\r\n";
   text += "Validation:                 " + AC_L6_VALIDATION_STATUS + "\r\n";
   text += "Owner:                      " + AC_RUNTIME4_OWNER + "\r\n";
   text += "Gateway Required:           TRUE\r\n";
   text += "Gateway Result Accepted:    " + (AC_L6_RANKED_ACCEPTED ? "TRUE" : "FALSE") + "\r\n";
   text += "Input Source:               Layer 5 pass set only\r\n";
   text += "Current L5 Pass Symbols:    " + IntegerToString(AC_L6_INPUT_L5_PASS_SYMBOLS) + "\r\n";
   text += "L6 Export L5 Pass Symbols:  " + IntegerToString(AC_L6_SOURCE_L5_GATE_PASS) + "\r\n";
   text += "Manifest Input Count:       " + IntegerToString(AC_L6_MANIFEST_INPUT_COUNT) + "\r\n";
   text += "Ranked Symbols:             " + IntegerToString(AC_L6_RANKED_SYMBOLS) + "\r\n";
   text += "Generation Counts OK:       " + (AC_L6_GENERATION_COUNTS_OK ? "TRUE" : "FALSE") + "\r\n";
   text += "L6 Snapshot Drift:          " + (AC_L6_LIVE_L5_DRIFT ? "TRUE" : "FALSE") + "\r\n";
   text += "SymbolRank Files Actual:    " + IntegerToString(AC_L6_SYMBOL_RANK_FILES_ACTUAL) + " / " + IntegerToString(AC_L6_SYMBOL_RANK_FILES_WRITTEN) + "\r\n";
   text += "Top Ranked:                 " + AC_L6_TOP20_FIRST_LINE + "\r\n";
   text += "Main Blocker:               " + AC_L6_MAIN_BLOCKER + "\r\n";
   text += "Gateway Job:                " + AC_L6_JOB_TYPE + "\r\n";
   text += "Ranking Runtime:            " + (AC_L6_RANKED_ACCEPTED ? "TRUE" : "FALSE") + "\r\n";
   text += "Selection Runtime:          FALSE\r\n";
   text += "Trade Permission:           FALSE\r\n";
   return text;
}

string AC_Layer6DossierSection(const string symbol)
{
   AC_RefreshLayer6RankedSidecar();
   int l5_index = AC_L5FindIndex(symbol);
   string l5_status = "not_available";
   string l5_reason = "symbol not found in Layer 5 gate packet";
   if(l5_index >= 0)
   {
      l5_status = AC_L5_SYMBOLS[l5_index].gate_status;
      l5_reason = AC_L5_SYMBOLS[l5_index].gate_reason;
   }

   string text = "\r\nLAYER 6 - COST / FRICTION RANKING\r\n";
   text += "----------------------------------------\r\n";
   text += "Status: " + AC_L6_STATUS + "\r\n";
   text += "Owner: " + AC_RUNTIME4_OWNER + "\r\n";
   text += "Gateway Result Accepted: " + (AC_L6_RANKED_ACCEPTED ? "TRUE" : "FALSE") + "\r\n";
   text += "Validation: " + AC_L6_VALIDATION_STATUS + "\r\n";
   text += "L5 Gate Status: " + l5_status + "\r\n";
   text += "L5 Gate Reason: " + l5_reason + "\r\n";

   if(l5_status != "pass")
   {
      text += "Rank State: not_ranked_l5_gate_failed\r\n";
      text += "Friction Score: not_available\r\n";
      text += "Friction Bucket: not_available\r\n";
   }
   else if(!AC_L6_RANKED_ACCEPTED)
   {
      text += "Rank State: ranked_sidecar_not_accepted\r\n";
      text += "Validation Reason: " + AC_L6_VALIDATION_REASON + "\r\n";
   }
   else
   {
      AC_RenderIndexRow index_row;
      bool index_hit = AC_RenderIndexLookup(6, symbol, index_row);
      if(index_hit)
      {
         text += "Rank Evidence: accepted_current_epoch_render_index_v1\r\n";
         text += "Rank State: " + index_row.rank_state + "\r\n";
         text += "Rank Index: " + index_row.rank_index + " / " + IntegerToString(AC_L6_RANKED_SYMBOLS) + "\r\n";
         text += "Friction Score: " + index_row.score + "\r\n";
         text += "Friction Bucket: " + index_row.bucket + "\r\n";
         text += "Score Quality: " + index_row.score_quality + "\r\n";
         text += "Rank Source: render_index_v1\r\n";
         text += "Rank Path: " + index_row.rank_path + "\r\n";
      }
      else
      {
         string rank_text = AC_L6ReadSmallTextFile(AC_L6SymbolRankPath(symbol), 12000);
         text += "Rank Evidence: " + (rank_text == "" ? "symbol_rank_sidecar_missing" : "symbol_rank_sidecar_fallback") + "\r\n";
         text += "Rank State: " + AC_L6KvValue(rank_text, "rank_state", "not_available") + "\r\n";
         text += "Friction Score: " + AC_L6KvValue(rank_text, "friction_score", "not_available") + "\r\n";
         text += "Friction Bucket: " + AC_L6KvValue(rank_text, "friction_bucket", "not_available") + "\r\n";
         text += "Score Quality: " + AC_L6KvValue(rank_text, "score_quality", "not_available") + "\r\n";
         text += "Rank Source: " + AC_L6SymbolRankPath(symbol) + "\r\n";
      }
   }

   text += "\r\nBoundary\r\n";
   text += "----------------------------------------\r\n";
   text += "Source Owner: Layer 5 pass set + Layer 3/4 packets + MT5 cost primitives\r\n";
   text += "Scoring Owner: " + AC_RUNTIME4_OWNER + " via Runtime 3 Gateway support\r\n";
   text += "Layer 6 Blocks Symbols: FALSE\r\n";
   text += "Selection Runtime: FALSE\r\n";
   text += "Trade Permission: FALSE\r\n";
   text += "Execution: FALSE\r\n";
   return text;
}

string AC_Layer6WorkbenchSection()
{
   AC_RefreshLayer6RankedSidecar();
   string text = "\r\nL6_COST_FRICTION_RANKING\r\n";
   text += "----------------------------------------\r\n";
   text += "owner_name=" + AC_RUNTIME4_OWNER + "\r\n";
   text += "layer_name=" + AC_LAYER_6_NAME + "\r\n";
   text += "status=" + AC_L6_STATUS + "\r\n";
   text += "trust_state=" + AC_L6_TRUST_STATE + "\r\n";
   text += "validation_status=" + AC_L6_VALIDATION_STATUS + "\r\n";
   text += "validation_reason=" + AC_L6_VALIDATION_REASON + "\r\n";
   text += "gateway_required=true\r\n";
   text += "gateway_result_accepted=" + (AC_L6_RANKED_ACCEPTED ? "true" : "false") + "\r\n";
   text += "current_l5_pass_symbols=" + IntegerToString(AC_L6_INPUT_L5_PASS_SYMBOLS) + "\r\n";
   text += "l6_export_l5_pass_symbols=" + IntegerToString(AC_L6_SOURCE_L5_GATE_PASS) + "\r\n";
   text += "manifest_input_count=" + IntegerToString(AC_L6_MANIFEST_INPUT_COUNT) + "\r\n";
   text += "ranked_symbols=" + IntegerToString(AC_L6_RANKED_SYMBOLS) + "\r\n";
   text += "generation_counts_ok=" + (AC_L6_GENERATION_COUNTS_OK ? "true" : "false") + "\r\n";
   text += "live_l5_drift=" + (AC_L6_LIVE_L5_DRIFT ? "true" : "false") + "\r\n";
   text += "symbol_rank_files_written=" + IntegerToString(AC_L6_SYMBOL_RANK_FILES_WRITTEN) + "\r\n";
   text += "symbol_rank_files_actual=" + IntegerToString(AC_L6_SYMBOL_RANK_FILES_ACTUAL) + "\r\n";
   text += "payload_checksum=" + AC_L6_MANIFEST_PAYLOAD_CHECKSUM + "\r\n";
   text += "main_blocker=" + AC_L6_MAIN_BLOCKER + "\r\n";
   text += "ranking_runtime=" + (AC_L6_RANKED_ACCEPTED ? "true" : "false") + "\r\n";
   text += "selection_runtime=false\r\n";
   text += "trade_permission=false\r\n";
   return text;
}

#endif
