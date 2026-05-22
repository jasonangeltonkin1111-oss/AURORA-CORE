#ifndef AC_PUBLICATION_RENDERERS_MQH
#define AC_PUBLICATION_RENDERERS_MQH

// Board / Dossier Renderer Service.
// Renders prepared owner/status packets only. It must not compute trading truth,
// selection, market-open state, broker specs, quotes, or permission.
// L6-E reads tiny Gateway sidecar proof files only: manifest, top20, and one per-symbol rank file.
// It must not parse the full ranked_symbols.csv in the MT5 heartbeat/dossier loop.

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
static string AC_L6_MANIFEST_PAYLOAD_CHECKSUM = "not_available";
static string AC_L6_MANIFEST_STATUS = "not_loaded";
static string AC_L6_MANIFEST_REASON = "not_loaded";
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
static int AC_L6_SOURCE_INPUT_MANIFEST_ROW_COUNT = 0;
static int AC_L6_SOURCE_L5_GATE_PASS = 0;
static string AC_L6_SOURCE_INPUT_PAYLOAD_CHECKSUM = "not_available";
static bool AC_L6_INPUT_COUNT_MATCHES_INPUT_MANIFEST = false;
static bool AC_L6_INPUT_COUNT_MATCHES_SOURCE_L5_GATE_PASS = false;
static bool AC_L6_GENERATION_COUNTS_OK = false;
static bool AC_L6_LIVE_L5_DRIFT = false;
static int AC_L6_LIVE_L5_DRIFT_DELTA = 0;
static bool AC_L6_RANKED_ACCEPTED = false;
static uint AC_L6_CALCULATION_DURATION_MS = 0;

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

string AC_L6SymbolRankPath(const string symbol)
{
   return AC_L6SymbolRankFolderPath() + "\\" + AC_SanitizePathPart(symbol) + ".txt";
}

string AC_ReadSmallTextFile(const string path, const int max_chars = 120000)
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

string AC_KvValue(const string text, const string key, const string fallback = "not_available")
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

int AC_KvInt(const string text, const string key, const int fallback = 0)
{
   string value = AC_KvValue(text, key, "");
   if(value == "") return fallback;
   return (int)StringToInteger(value);
}

double AC_KvDouble(const string text, const string key, const double fallback = 0.0)
{
   string value = AC_KvValue(text, key, "");
   if(value == "") return fallback;
   return StringToDouble(value);
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
      if(StringFind(line, "1|") == 0)
         return line;
   }
   return "not_available";
}

void AC_RefreshLayer6RankedSidecar()
{
   AC_L6_INPUT_L5_PASS_SYMBOLS = AC_L5_GATE_PASS;
   AC_L6_RANKED_ACCEPTED = false;
   AC_L6_STATUS = "Pending ranked sidecar";
   AC_L6_TRUST_STATE = "Ranking Pending";
   AC_L6_VALIDATION_STATUS = "Pending";
   AC_L6_VALIDATION_REASON = "ranked_symbols.manifest missing or not accepted";
   AC_L6_MAIN_BLOCKER = "ranked_symbols.manifest has not been accepted yet";
   AC_L6_MANIFEST_STATUS = "not_loaded";
   AC_L6_MANIFEST_REASON = "not_loaded";
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
   AC_L6_SOURCE_INPUT_MANIFEST_ROW_COUNT = 0;
   AC_L6_SOURCE_L5_GATE_PASS = 0;
   AC_L6_SOURCE_INPUT_PAYLOAD_CHECKSUM = "not_available";
   AC_L6_INPUT_COUNT_MATCHES_INPUT_MANIFEST = false;
   AC_L6_INPUT_COUNT_MATCHES_SOURCE_L5_GATE_PASS = false;
   AC_L6_GENERATION_COUNTS_OK = false;
   AC_L6_LIVE_L5_DRIFT = false;
   AC_L6_LIVE_L5_DRIFT_DELTA = 0;
   AC_L6_MANIFEST_PAYLOAD_CHECKSUM = "not_available";
   AC_L6_TOP20_FIRST_LINE = "not_available";
   AC_L6_CALCULATION_DURATION_MS = 0;

   string manifest = AC_ReadSmallTextFile(AC_L6RankedManifestPath(), 30000);
   if(manifest == "")
   {
      AC_L6_VALIDATION_STATUS = "Missing";
      AC_L6_VALIDATION_REASON = "ranked_symbols.manifest missing or unreadable";
      AC_L6_MAIN_BLOCKER = AC_L6_VALIDATION_REASON;
      return;
   }

   AC_L6_MANIFEST_STATUS = AC_KvValue(manifest, "status", "not_available");
   AC_L6_MANIFEST_REASON = AC_KvValue(manifest, "reason", "not_available");
   AC_L6_MANIFEST_INPUT_COUNT = AC_KvInt(manifest, "input_count", 0);
   AC_L6_RANKED_SYMBOLS = AC_KvInt(manifest, "row_count", 0);
   AC_L6_RANKED_DEGRADED_SYMBOLS = AC_KvInt(manifest, "ranked_degraded_count", 0);
   AC_L6_NOT_RANKABLE_QUALITY_SYMBOLS = AC_KvInt(manifest, "not_rankable_quality_count", 0);
   AC_L6_ELITE_FRICTION_COUNT = AC_KvInt(manifest, "elite_friction_count", 0);
   AC_L6_GOOD_FRICTION_COUNT = AC_KvInt(manifest, "good_friction_count", 0);
   AC_L6_ACCEPTABLE_FRICTION_COUNT = AC_KvInt(manifest, "acceptable_friction_count", 0);
   AC_L6_EXPENSIVE_FRICTION_COUNT = AC_KvInt(manifest, "expensive_friction_count", 0);
   AC_L6_HOSTILE_FRICTION_COUNT = AC_KvInt(manifest, "hostile_friction_count", 0);
   AC_L6_ZERO_COST_SUSPICIOUS_COUNT = AC_KvInt(manifest, "zero_cost_nonzero_spread_suspicious_count", 0);
   AC_L6_COST_MODEL_MISMATCH_COUNT = AC_KvInt(manifest, "cost_model_mismatch_count", 0);
   AC_L6_SYMBOL_RANK_FILES_WRITTEN = AC_KvInt(manifest, "symbol_rank_files_written", 0);
   AC_L6_SOURCE_INPUT_MANIFEST_ROW_COUNT = AC_KvInt(manifest, "source_input_manifest_row_count", 0);
   AC_L6_SOURCE_L5_GATE_PASS = AC_KvInt(manifest, "source_l5_gate_pass", 0);
   AC_L6_SOURCE_INPUT_PAYLOAD_CHECKSUM = AC_KvValue(manifest, "source_input_payload_checksum", "not_available");
   AC_L6_INPUT_COUNT_MATCHES_INPUT_MANIFEST = (AC_KvValue(manifest, "input_csv_count_matches_input_manifest", "false") == "true");
   AC_L6_INPUT_COUNT_MATCHES_SOURCE_L5_GATE_PASS = (AC_KvValue(manifest, "input_csv_count_matches_source_l5_gate_pass", "false") == "true");
   AC_L6_MANIFEST_PAYLOAD_CHECKSUM = AC_KvValue(manifest, "payload_checksum", "not_available");

   string authority = AC_KvValue(manifest, "authority", "not_available");
   string trade_permission = AC_KvValue(manifest, "trade_permission", "not_available");
   string ranking_runtime = AC_KvValue(manifest, "ranking_runtime", "not_available");
   string selection_runtime = AC_KvValue(manifest, "selection_runtime", "not_available");

   bool manifest_ok = (AC_L6_MANIFEST_STATUS == "complete");
   bool basic_rank_counts_ok = (AC_L6_MANIFEST_INPUT_COUNT == AC_L6_RANKED_SYMBOLS);
   bool source_manifest_count_ok = (AC_L6_SOURCE_INPUT_MANIFEST_ROW_COUNT > 0 && AC_L6_SOURCE_INPUT_MANIFEST_ROW_COUNT == AC_L6_MANIFEST_INPUT_COUNT);
   bool source_l5_export_count_ok = (AC_L6_SOURCE_L5_GATE_PASS > 0 && AC_L6_SOURCE_L5_GATE_PASS == AC_L6_MANIFEST_INPUT_COUNT);
   bool source_manifest_flags_ok = (AC_L6_INPUT_COUNT_MATCHES_INPUT_MANIFEST && AC_L6_INPUT_COUNT_MATCHES_SOURCE_L5_GATE_PASS);
   AC_L6_GENERATION_COUNTS_OK = (basic_rank_counts_ok && source_manifest_count_ok && source_l5_export_count_ok && source_manifest_flags_ok);
   AC_L6_LIVE_L5_DRIFT = (AC_L6_RANKED_SYMBOLS != AC_L5_GATE_PASS);
   AC_L6_LIVE_L5_DRIFT_DELTA = AC_L6_RANKED_SYMBOLS - AC_L5_GATE_PASS;
   bool counts_ok = AC_L6_GENERATION_COUNTS_OK;
   bool authority_ok = (authority == "calculation_support_only");
   bool permission_ok = (trade_permission == "false" && selection_runtime == "false" && ranking_runtime == "true");
   bool files_ok = FileIsExist(AC_L6RankedCsvPath(), AC_CommonFlag()) && FileIsExist(AC_L6RankedTop20Path(), AC_CommonFlag());
   bool symbol_files_ok = (AC_L6_SYMBOL_RANK_FILES_WRITTEN == AC_L6_RANKED_SYMBOLS);

   if(manifest_ok && counts_ok && authority_ok && permission_ok && files_ok && symbol_files_ok)
   {
      AC_L6_RANKED_ACCEPTED = true;
      if(AC_L6_LIVE_L5_DRIFT)
      {
         AC_L6_STATUS = "Ranked sidecar accepted - L5 drift";
         AC_L6_TRUST_STATE = "Ranking Ready With Drift";
         AC_L6_VALIDATION_STATUS = "AcceptedWithDrift";
         AC_L6_VALIDATION_REASON = "ranked sidecar matches its exported L6 input generation; current live L5 pass count drifted after export";
         AC_L6_MAIN_BLOCKER = "none_l6_snapshot_valid_current_l5_drift=true";
      }
      else
      {
         AC_L6_STATUS = "Ranked sidecar accepted";
         AC_L6_TRUST_STATE = "Ranking Ready";
         AC_L6_VALIDATION_STATUS = "Accepted";
         AC_L6_VALIDATION_REASON = "ranked sidecar matches exported L6 input generation and current L5 pass count";
         AC_L6_MAIN_BLOCKER = "none";
      }
      AC_L6_TOP20_FIRST_LINE = AC_L6FirstTop20Symbol(AC_ReadSmallTextFile(AC_L6RankedTop20Path(), 16000));
      return;
   }

   AC_L6_STATUS = "Ranked sidecar degraded";
   AC_L6_TRUST_STATE = "Ranking Degraded";
   AC_L6_VALIDATION_STATUS = "Degraded";
   AC_L6_VALIDATION_REASON = "manifest_ok=" + (manifest_ok ? "true" : "false")
      + ";generation_counts_ok=" + (AC_L6_GENERATION_COUNTS_OK ? "true" : "false")
      + ";basic_rank_counts_ok=" + (basic_rank_counts_ok ? "true" : "false")
      + ";source_manifest_count_ok=" + (source_manifest_count_ok ? "true" : "false")
      + ";source_l5_export_count_ok=" + (source_l5_export_count_ok ? "true" : "false")
      + ";source_manifest_flags_ok=" + (source_manifest_flags_ok ? "true" : "false")
      + ";live_l5_drift=" + (AC_L6_LIVE_L5_DRIFT ? "true" : "false")
      + ";authority_ok=" + (authority_ok ? "true" : "false")
      + ";permission_ok=" + (permission_ok ? "true" : "false")
      + ";files_ok=" + (files_ok ? "true" : "false")
      + ";symbol_files_ok=" + (symbol_files_ok ? "true" : "false");
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
   text += "L6 Drift Delta:             " + IntegerToString(AC_L6_LIVE_L5_DRIFT_DELTA) + "\r\n";
   text += "Ranked Degraded:            " + IntegerToString(AC_L6_RANKED_DEGRADED_SYMBOLS) + "\r\n";
   text += "Not Rankable Quality:       " + IntegerToString(AC_L6_NOT_RANKABLE_QUALITY_SYMBOLS) + "\r\n";
   text += "Elite Friction:             " + IntegerToString(AC_L6_ELITE_FRICTION_COUNT) + "\r\n";
   text += "Good Friction:              " + IntegerToString(AC_L6_GOOD_FRICTION_COUNT) + "\r\n";
   text += "Acceptable Friction:        " + IntegerToString(AC_L6_ACCEPTABLE_FRICTION_COUNT) + "\r\n";
   text += "Expensive Friction:         " + IntegerToString(AC_L6_EXPENSIVE_FRICTION_COUNT) + "\r\n";
   text += "Hostile Friction:           " + IntegerToString(AC_L6_HOSTILE_FRICTION_COUNT) + "\r\n";
   text += "Zero Cost Suspicious:       " + IntegerToString(AC_L6_ZERO_COST_SUSPICIOUS_COUNT) + "\r\n";
   text += "Cost Model Mismatches:      " + IntegerToString(AC_L6_COST_MODEL_MISMATCH_COUNT) + "\r\n";
   text += "Top Ranked:                 " + AC_L6_TOP20_FIRST_LINE + "\r\n";
   text += "Ranked CSV:                 " + AC_L6_RANKED_CSV_PATH + "\r\n";
   text += "Manifest:                   " + AC_L6_RANKED_MANIFEST_PATH + "\r\n";
   text += "Top20:                      " + AC_L6_TOP20_PATH + "\r\n";
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
   text += "L6 Snapshot Drift: " + (AC_L6_LIVE_L5_DRIFT ? "TRUE" : "FALSE") + "\r\n";
   text += "Current L5 Pass Symbols: " + IntegerToString(AC_L6_INPUT_L5_PASS_SYMBOLS) + "\r\n";
   text += "L6 Export L5 Pass Symbols: " + IntegerToString(AC_L6_SOURCE_L5_GATE_PASS) + "\r\n";
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
      text += "Rank Index: pending\r\n";
      text += "Friction Score: pending\r\n";
      text += "Friction Bucket: pending\r\n";
      text += "Validation Reason: " + AC_L6_VALIDATION_REASON + "\r\n";
   }
   else
   {
      string rank_text = AC_ReadSmallTextFile(AC_L6SymbolRankPath(symbol), 12000);
      if(rank_text == "")
      {
         text += "Rank State: symbol_rank_sidecar_missing\r\n";
         text += "Rank Index: missing\r\n";
         text += "Friction Score: missing\r\n";
         text += "Friction Bucket: missing\r\n";
      }
      else
      {
         text += "Rank State: " + AC_KvValue(rank_text, "rank_state", "not_available") + "\r\n";
         text += "Rank Index: " + AC_KvValue(rank_text, "rank_index", "not_available") + " / " + IntegerToString(AC_L6_RANKED_SYMBOLS) + "\r\n";
         text += "Friction Score: " + AC_KvValue(rank_text, "friction_score", "not_available") + "\r\n";
         text += "Friction Bucket: " + AC_KvValue(rank_text, "friction_bucket", "not_available") + "\r\n";
         text += "Score Quality: " + AC_KvValue(rank_text, "score_quality", "not_available") + "\r\n";
         text += "Calculation Quality: " + AC_KvValue(rank_text, "calculation_quality", "not_available") + "\r\n";
         text += "Spread BPS: " + AC_KvValue(rank_text, "spread_bps", "not_available") + "\r\n";
         text += "Effective Min Lot Cost: " + AC_KvValue(rank_text, "effective_cost_minlot_account", "not_available") + "\r\n";
         text += "Cost Model Compare: " + AC_KvValue(rank_text, "cost_model_compare_status", "not_available") + "\r\n";
         text += "Zero Cost Suspicious: " + AC_KvValue(rank_text, "account_cost_zero_nonzero_spread_suspicious", "not_available") + "\r\n";
         text += "Volume Model Quality: " + AC_KvValue(rank_text, "volume_model_quality", "not_available") + "\r\n";
         text += "Commission Model: " + AC_KvValue(rank_text, "commission_model_status", "not_available") + "\r\n";
         text += "Reason: " + AC_KvValue(rank_text, "reason", "not_available") + "\r\n";
      }
      text += "Rank Source: " + AC_L6SymbolRankPath(symbol) + "\r\n";
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
   text += "job_type=" + AC_L6_JOB_TYPE + "\r\n";
   text += "current_l5_pass_symbols=" + IntegerToString(AC_L6_INPUT_L5_PASS_SYMBOLS) + "\r\n";
   text += "l6_export_l5_pass_symbols=" + IntegerToString(AC_L6_SOURCE_L5_GATE_PASS) + "\r\n";
   text += "manifest_input_count=" + IntegerToString(AC_L6_MANIFEST_INPUT_COUNT) + "\r\n";
   text += "ranked_symbols=" + IntegerToString(AC_L6_RANKED_SYMBOLS) + "\r\n";
   text += "source_input_manifest_row_count=" + IntegerToString(AC_L6_SOURCE_INPUT_MANIFEST_ROW_COUNT) + "\r\n";
   text += "source_input_payload_checksum=" + AC_L6_SOURCE_INPUT_PAYLOAD_CHECKSUM + "\r\n";
   text += "input_csv_count_matches_input_manifest=" + (AC_L6_INPUT_COUNT_MATCHES_INPUT_MANIFEST ? "true" : "false") + "\r\n";
   text += "input_csv_count_matches_source_l5_gate_pass=" + (AC_L6_INPUT_COUNT_MATCHES_SOURCE_L5_GATE_PASS ? "true" : "false") + "\r\n";
   text += "generation_counts_ok=" + (AC_L6_GENERATION_COUNTS_OK ? "true" : "false") + "\r\n";
   text += "live_l5_drift=" + (AC_L6_LIVE_L5_DRIFT ? "true" : "false") + "\r\n";
   text += "live_l5_drift_delta=" + IntegerToString(AC_L6_LIVE_L5_DRIFT_DELTA) + "\r\n";
   text += "ranked_degraded_symbols=" + IntegerToString(AC_L6_RANKED_DEGRADED_SYMBOLS) + "\r\n";
   text += "not_rankable_quality_symbols=" + IntegerToString(AC_L6_NOT_RANKABLE_QUALITY_SYMBOLS) + "\r\n";
   text += "elite_friction_count=" + IntegerToString(AC_L6_ELITE_FRICTION_COUNT) + "\r\n";
   text += "good_friction_count=" + IntegerToString(AC_L6_GOOD_FRICTION_COUNT) + "\r\n";
   text += "acceptable_friction_count=" + IntegerToString(AC_L6_ACCEPTABLE_FRICTION_COUNT) + "\r\n";
   text += "expensive_friction_count=" + IntegerToString(AC_L6_EXPENSIVE_FRICTION_COUNT) + "\r\n";
   text += "hostile_friction_count=" + IntegerToString(AC_L6_HOSTILE_FRICTION_COUNT) + "\r\n";
   text += "zero_cost_nonzero_spread_suspicious_count=" + IntegerToString(AC_L6_ZERO_COST_SUSPICIOUS_COUNT) + "\r\n";
   text += "cost_model_mismatch_count=" + IntegerToString(AC_L6_COST_MODEL_MISMATCH_COUNT) + "\r\n";
   text += "symbol_rank_files_written=" + IntegerToString(AC_L6_SYMBOL_RANK_FILES_WRITTEN) + "\r\n";
   text += "payload_checksum=" + AC_L6_MANIFEST_PAYLOAD_CHECKSUM + "\r\n";
   text += "ranked_csv_path=" + AC_L6_RANKED_CSV_PATH + "\r\n";
   text += "ranked_manifest_path=" + AC_L6_RANKED_MANIFEST_PATH + "\r\n";
   text += "top20_path=" + AC_L6_TOP20_PATH + "\r\n";
   text += "symbol_rank_folder=" + AC_L6_SYMBOL_RANK_FOLDER + "\r\n";
   text += "main_blocker=" + AC_L6_MAIN_BLOCKER + "\r\n";
   text += "ranking_runtime=" + (AC_L6_RANKED_ACCEPTED ? "true" : "false") + "\r\n";
   text += "selection_runtime=false\r\n";
   text += "trade_permission=false\r\n";
   return text;
}

static string AC_L0_FIRST_FAILURE = "";
static string AC_L0_FAILURE_ADDENDUM = "";
static int    AC_L0_CACHED_SYMBOLS_TOTAL = -1;
static string AC_L0_CACHED_DOSSIER_SCHEMA_VERSION = "";
static string AC_L0_CACHED_L2_ROUTE_GENERATION_KEY = "";
static string AC_L0_CACHED_L3_CACHE_KEY = "";
static string AC_L0_CACHED_L4_CACHE_KEY = "";
static string AC_L0_CACHED_L4_REFRESH_KEY = "";
static string AC_L0_CACHED_L5_STATUS = "";
static string AC_L0_CACHED_L6_STATUS = "";
static string AC_L0_CACHED_L6_CHECKSUM = "";
static bool   AC_L0_CACHED_PASS_VALID = false;
static AC_Layer0StatusPacket AC_L0_CACHED_STATUS;
static AC_WriteResult AC_L0_CACHED_RESULT;

string AC_PercentText(const int complete_count, const int total_count)
{
   if(total_count <= 0)
      return "Not available";
   double pct = ((double)complete_count * 100.0) / (double)total_count;
   return StringFormat("%.1f%%", pct);
}

string AC_MarketStateTitle(const string market_state)
{
   if(market_state == "open") return "Open";
   if(market_state == "closed") return "Closed";
   return "Unknown";
}

void AC_Layer0InitStatus(AC_Layer0StatusPacket &status)
{
   status.layer_id = "L0";
   status.layer_name = AC_LAYER_0_BOARD_DOSSIER_NAME;
   status.owner_name = AC_BOARD_DOSSIER_RENDERER_OWNER;
   status.status = "Not started";
   status.trust_state = "Not Ready";
   status.main_blocker = "Dossier coverage has not started";
   status.broker_symbols_total = 0;
   status.marketwatch_symbols_total = 0;
   status.dossier_shells_ready = 0;
   status.dossier_shells_missing = 0;
   status.batch_start_index = 0;
   status.batch_end_index = -1;
   status.batch_attempted = 0;
   status.batch_written = 0;
   status.next_symbol_index = 0;
   status.failed_symbol_count = 0;
   status.retry_count_total = 0;
   status.batch_duration_ms = 0;
   status.batch_complete = false;
   status.trade_permission = false;
   status.auto_trade_allowed = false;
   status.ranking_runtime = false;
   status.selection_runtime = false;
   status.market_state_known = false;
   status.specs_known = false;
   status.quotes_known = false;
   status.first_failure = "";
}

AC_WriteResult AC_EmptySyntheticResult()
{
   return AC_MakeSyntheticWriteResult(AC_DossiersUnknownFolder(), true, "not_started", 0, "not_started");
}

string AC_BuildLayer0DossierShellText(const string symbol,
                                      const int broker_index,
                                      const AC_Layer0StatusPacket &status)
{
   string market_state = AC_L2MarketStateForSymbol(symbol);
   string text = "";
   text += "AURORA CORE - SYMBOL DOSSIER\r\n";
   text += "----------------------------------------\r\n";
   text += "Symbol: " + symbol + "\r\n";
   text += "Broker Symbol: " + symbol + "\r\n";
   text += "Market State: " + AC_MarketStateTitle(market_state) + "\r\n";
   text += "Dossier Route: " + AC_DossierSymbolPathByState(symbol, market_state) + "\r\n";
   text += "Server: " + AC_ServerNameForRoute() + "\r\n";
   text += "Account: " + AC_AccountForRoute() + "\r\n";
   text += "Trade Permission: FALSE\r\n";
   text += "Auto Trading: FALSE\r\n";
   text += "\r\n";
   text += "FOUNDATION STATUS\r\n";
   text += "----------------------------------------\r\n";
   text += "Layer 0 Publication: Complete\r\n";
   text += "Layer 1 Account and Portfolio: " + (AC_L1_READY ? "Available" : "Pending") + "\r\n";
   text += "Layer 2 Market State: " + (AC_L2_READY ? AC_L2_SCAN_STATUS : "Pending") + "\r\n";
   text += "Layer 3 Broker Specs and Value: " + (AC_L3_READY ? AC_L3_SCAN_STATUS : "Pending") + "\r\n";
   text += "Layer 4 Live Quote and Spread: " + (market_state == "open" ? (AC_L4_READY ? AC_L4_SCAN_STATUS : "Pending") : "Cut off until market reopens") + "\r\n";
   text += "Layer 5 Basic System Gate: " + AC_L5_STATUS + "\r\n";
   text += "Layer 6 Cost / Friction Ranking: " + AC_L6_STATUS + "\r\n";
   text += "\r\n";
   text += "CURRENT LIMITS\r\n";
   text += "----------------------------------------\r\n";
   text += "Broker Symbol Exists: Yes\r\n";
   text += "Market State Known: " + ((market_state == "open" || market_state == "closed") ? "Yes" : "No") + "\r\n";
   text += "Broker Static Specs: " + (AC_L3_READY ? "Available / Scanned (see Layer 3)" : "Pending Layer 3 scan") + "\r\n";
   text += "Live Quote Truth: " + (market_state == "open" ? (AC_L4_READY ? "Available / Scanned (see Layer 4)" : "Unavailable - Layer 4 not scanned yet") : "Unavailable - market closed or unknown") + "\r\n";
   text += "Cost / Friction Ranking: " + AC_L6_STATUS + "\r\n";
   text += "Selection Active: No\r\n";
   text += "Permission Active: No\r\n";
   text += AC_Layer1DossierSection(symbol);
   text += AC_Layer2DossierSection(symbol);
   text += AC_Layer3DossierSection(symbol);
   text += AC_Layer4DossierSection(symbol);
   text += AC_Layer5DossierSection(symbol);
   text += AC_Layer6DossierSection(symbol);
   text += "\r\nNEXT REQUIRED\r\n";
   text += "----------------------------------------\r\n";
   text += (market_state == "open" ? "Next step: Layer 7 only after L6 live proof is accepted\r\n" : "Next step: wait for Layer 2 recheck before deeper layers\r\n");
   text += "Open / Closed owner: Layer 2 only\r\n";
   text += "Layer 6 ranks only Layer 5 pass symbols; it does not hard-block symbols.\r\n";
   text += "\r\n";
   text += "NO GO\r\n";
   text += "----------------------------------------\r\n";
   text += "Tradable: No\r\n";
   text += "Selected: No\r\n";
   text += "Alert Active: No\r\n";
   text += "Permission: No\r\n";
   return text;
}

void AC_CleanupOtherDossierRoutes(const string symbol, const string market_state, const bool target_write_ok)
{
   if(!target_write_ok) return;
   string open_path = AC_DossierOpenSymbolPath(symbol);
   string closed_path = AC_DossierClosedSymbolPath(symbol);
   string unknown_path = AC_DossierUnknownSymbolPath(symbol);
   string target_path = AC_DossierSymbolPathByState(symbol, market_state);
   if(open_path != target_path)
   {
      AC_WriteResult cleanup_open = AC_DeleteFileIfExists(open_path);
      if(cleanup_open.status == "deleted") AC_L2_DUPLICATE_CLEANUP_COUNT++;
      else if(!cleanup_open.ok) AC_L2_DUPLICATE_CLEANUP_FAILURE_COUNT++;
   }
   if(closed_path != target_path)
   {
      AC_WriteResult cleanup_closed = AC_DeleteFileIfExists(closed_path);
      if(cleanup_closed.status == "deleted") AC_L2_DUPLICATE_CLEANUP_COUNT++;
      else if(!cleanup_closed.ok) AC_L2_DUPLICATE_CLEANUP_FAILURE_COUNT++;
   }
   if(unknown_path != target_path)
   {
      AC_WriteResult cleanup_unknown = AC_DeleteFileIfExists(unknown_path);
      if(cleanup_unknown.status == "deleted") AC_L2_DUPLICATE_CLEANUP_COUNT++;
      else if(!cleanup_unknown.ok) AC_L2_DUPLICATE_CLEANUP_FAILURE_COUNT++;
   }
}

bool AC_WriteLayer0ShellWithRetries(const string symbol,
                                    const int broker_index,
                                    const AC_Layer0StatusPacket &status,
                                    int &retries_used,
                                    string &failure_line)
{
   retries_used = 0;
   failure_line = "";
   int max_attempts = AC_DOSSIER_SHELL_WRITE_RETRIES;
   if(max_attempts < 1) max_attempts = 1;
   string market_state = AC_L2MarketStateForSymbol(symbol);
   string target_path = AC_DossierSymbolPathByState(symbol, market_state);
   for(int attempt = 1; attempt <= max_attempts; attempt++)
   {
      AC_WriteResult write = AC_WriteTextFileFastAtomic(target_path, AC_BuildLayer0DossierShellText(symbol, broker_index, status));
      if(write.ok)
      {
         if(market_state == "open") AC_L2_ROUTE_WRITE_OPEN_COUNT++;
         else if(market_state == "closed") AC_L2_ROUTE_WRITE_CLOSED_COUNT++;
         else AC_L2_ROUTE_WRITE_UNKNOWN_COUNT++;
         AC_CleanupOtherDossierRoutes(symbol, market_state, true);
         retries_used = attempt - 1;
         return true;
      }
      retries_used = attempt;
      failure_line = "symbol=" + symbol + "|index=" + IntegerToString(broker_index) + "|state=" + market_state + "|attempt=" + IntegerToString(attempt) + "|status=" + write.status + "|error=" + IntegerToString(write.error_code);
   }
   AC_L2_ROUTE_WRITE_FAILURE_COUNT++;
   return false;
}

AC_WriteResult AC_RunLayer0UniverseShellPass(AC_Layer0StatusPacket &status)
{
   AC_Layer0InitStatus(status);
   AC_L0_FIRST_FAILURE = "";
   AC_L0_FAILURE_ADDENDUM = "";
   uint start_ms = GetTickCount();
   int total = SymbolsTotal(false);
   int marketwatch_total = SymbolsTotal(true);
   status.broker_symbols_total = total;
   status.marketwatch_symbols_total = marketwatch_total;
   status.batch_start_index = 0;
   status.batch_end_index = total - 1;
   bool all_ok = true;
   int attempted = 0;
   int written = 0;
   int failed = 0;
   int retries_total = 0;
   for(int idx = 0; idx < total; idx++)
   {
      attempted++;
      string symbol = SymbolName(idx, false);
      if(symbol == "")
      {
         all_ok = false;
         failed++;
         string failure = "symbol=<empty>|index=" + IntegerToString(idx) + "|status=empty_symbol_name";
         if(AC_L0_FIRST_FAILURE == "") AC_L0_FIRST_FAILURE = failure;
         AC_L0_FAILURE_ADDENDUM += failure + "\r\n";
         continue;
      }
      int retries_used = 0;
      string failure_line = "";
      if(AC_WriteLayer0ShellWithRetries(symbol, idx, status, retries_used, failure_line))
      {
         written++;
         retries_total += retries_used;
      }
      else
      {
         all_ok = false;
         failed++;
         retries_total += retries_used;
         if(AC_L0_FIRST_FAILURE == "") AC_L0_FIRST_FAILURE = failure_line;
         AC_L0_FAILURE_ADDENDUM += failure_line + "\r\n";
      }
   }
   status.batch_attempted = attempted;
   status.batch_written = written;
   status.dossier_shells_ready = written;
   status.dossier_shells_missing = total - written;
   if(status.dossier_shells_missing < 0) status.dossier_shells_missing = 0;
   status.next_symbol_index = total;
   status.batch_complete = (total > 0 && written == total);
   status.batch_duration_ms = GetTickCount() - start_ms;
   status.failed_symbol_count = failed;
   status.retry_count_total = retries_total;
   status.first_failure = AC_L0_FIRST_FAILURE;
   if(total <= 0)
   {
      status.status = "Waiting for broker symbol universe";
      status.main_blocker = "SymbolsTotal(false) returned zero";
   }
   else if(status.batch_complete && failed == 0)
   {
      status.status = "Complete";
      status.trust_state = "Dossiers Ready";
      status.main_blocker = AC_L6_MAIN_BLOCKER == "none" ? AC_L5_MAIN_BLOCKER : AC_L6_MAIN_BLOCKER;
   }
   else
   {
      status.status = "Complete with warnings";
      status.trust_state = "Dossiers Degraded";
      status.main_blocker = "Some symbol Dossier packets failed; see Upgrade Addendum";
   }
   string batch_status = all_ok ? "dossier_universe_complete" : "dossier_universe_complete_with_degraded";
   AC_L0_CACHED_SYMBOLS_TOTAL = total;
   AC_L0_CACHED_DOSSIER_SCHEMA_VERSION = AC_DOSSIER_SHELL_SCHEMA_VERSION;
   AC_L0_CACHED_L2_ROUTE_GENERATION_KEY = AC_L2_ROUTE_GENERATION_KEY;
   AC_L0_CACHED_L3_CACHE_KEY = AC_L3_CACHE_KEY;
   AC_L0_CACHED_L4_CACHE_KEY = AC_L4_CACHE_KEY;
   AC_L0_CACHED_L4_REFRESH_KEY = AC_L4_REFRESH_KEY;
   AC_L0_CACHED_L5_STATUS = AC_L5_STATUS;
   AC_L0_CACHED_L6_STATUS = AC_L6_STATUS;
   AC_L0_CACHED_L6_CHECKSUM = AC_L6_MANIFEST_PAYLOAD_CHECKSUM;
   AC_L0_CACHED_PASS_VALID = true;
   AC_L0_CACHED_STATUS = status;
   AC_BuildLayer2Texts();
   AC_BuildLayer3Texts();
   AC_BuildLayer4Texts();
   AC_BuildLayer5Texts();
   AC_RefreshLayer6RankedSidecar();
   AC_L0_CACHED_RESULT = AC_MakeSyntheticWriteResult(AC_DossiersFolder(), all_ok, batch_status, (ulong)written, "full_universe_dossier_pass_sequential_symbol_by_symbol_with_l2_l3_l4_l5_l6_ranked_sidecar_sections");
   return AC_L0_CACHED_RESULT;
}

AC_WriteResult AC_PublishLayer0DossierBatch(AC_Layer0StatusPacket &status)
{
   AC_RefreshLayer6RankedSidecar();
   int total = SymbolsTotal(false);
   if(AC_L0_CACHED_PASS_VALID
      && total == AC_L0_CACHED_SYMBOLS_TOTAL
      && AC_L0_CACHED_DOSSIER_SCHEMA_VERSION == AC_DOSSIER_SHELL_SCHEMA_VERSION
      && AC_L0_CACHED_L2_ROUTE_GENERATION_KEY == AC_L2_ROUTE_GENERATION_KEY
      && AC_L0_CACHED_L3_CACHE_KEY == AC_L3_CACHE_KEY
      && AC_L0_CACHED_L4_CACHE_KEY == AC_L4_CACHE_KEY
      && AC_L0_CACHED_L4_REFRESH_KEY == AC_L4_REFRESH_KEY
      && AC_L0_CACHED_L5_STATUS == AC_L5_STATUS
      && AC_L0_CACHED_L6_STATUS == AC_L6_STATUS
      && AC_L0_CACHED_L6_CHECKSUM == AC_L6_MANIFEST_PAYLOAD_CHECKSUM)
   {
      status = AC_L0_CACHED_STATUS;
      status.marketwatch_symbols_total = SymbolsTotal(true);
      return AC_MakeSyntheticWriteResult(AC_DossiersFolder(), true, "dossier_universe_cached_no_rewrite", (ulong)status.dossier_shells_ready, "cached_universe_status_no_symbol_rewrite|schema=" + AC_L0_CACHED_DOSSIER_SCHEMA_VERSION + "|l2=" + AC_L0_CACHED_L2_ROUTE_GENERATION_KEY + "|l3=" + AC_L0_CACHED_L3_CACHE_KEY + "|l4=" + AC_L0_CACHED_L4_CACHE_KEY + "|l4_refresh=" + AC_L0_CACHED_L4_REFRESH_KEY + "|l5=" + AC_L0_CACHED_L5_STATUS + "|l6=" + AC_L0_CACHED_L6_STATUS + "|l6_checksum=" + AC_L0_CACHED_L6_CHECKSUM);
   }
   return AC_RunLayer0UniverseShellPass(status);
}

string AC_BuildTraderBoardText(const AC_Runtime0Snapshot &snapshot,
                               const AC_Layer0StatusPacket &status)
{
   string text = "";
   text += "AURORA CORE - MARKET BOARD\r\n";
   text += "----------------------------------------\r\n";
   text += "State:            " + status.status + "\r\n";
   text += "Trust:            " + status.trust_state + "\r\n";
   text += "Trade Permission: FALSE\r\n";
   text += "Auto Trading:     FALSE\r\n";
   text += "\r\n";
   text += "DOSSIER COVERAGE\r\n";
   text += "----------------------------------------\r\n";
   text += "Broker Symbols Seen:    " + IntegerToString(status.broker_symbols_total) + "\r\n";
   text += "Dossiers Ready:         " + IntegerToString(status.dossier_shells_ready) + " / " + IntegerToString(status.broker_symbols_total) + "\r\n";
   text += "Dossiers Missing:       " + IntegerToString(status.dossier_shells_missing) + "\r\n";
   text += "Completion:             " + AC_PercentText(status.dossier_shells_ready, status.broker_symbols_total) + "\r\n";
   text += "Failed Dossiers:        " + IntegerToString(status.failed_symbol_count) + "\r\n";
   text += "Dossier Pass Duration:  " + IntegerToString((int)status.batch_duration_ms) + " ms\r\n";
   text += "\r\n";
   text += "CURRENT FOUNDATION + SURFACE SCORING\r\n";
   text += "----------------------------------------\r\n";
   text += "Layer 0: Publication + Dossier Foundation\r\n";
   text += "Layer 1: Account / Portfolio Truth\r\n";
   text += "Layer 2: Market Open / Closed Truth\r\n";
   text += "Layer 3: Broker Specs and Value Truth\r\n";
   text += "Layer 4: Live Quote and Spread Truth\r\n";
   text += "Layer 5: Basic System Gate\r\n";
   text += "Layer 6: Cost / Friction Ranking\r\n";
   text += AC_Layer1BoardSection();
   text += AC_Layer2BoardSection();
   text += AC_Layer3BoardSection();
   text += AC_Layer4BoardSection();
   text += AC_Layer5BoardSection();
   text += AC_Layer6BoardSection();
   text += "\r\nTRADING READINESS\r\n";
   text += "----------------------------------------\r\n";
   text += "Market State Known: " + ((AC_L2_OPEN_COUNT + AC_L2_CLOSED_COUNT) > 0 ? "Partial or Complete" : "No") + "\r\n";
   text += "Specs Known:        " + (AC_L3_READY ? "See Layer 3 readiness" : "No") + "\r\n";
   text += "Quotes Known:       " + (AC_L4_READY ? "See Layer 4 readiness" : "No") + "\r\n";
   text += "Cost Ranking:       " + AC_L6_STATUS + "\r\n";
   text += "Selection Active:   No\r\n";
   text += "Permission Active:  No\r\n";
   text += "\r\n";
   text += "TRUST BLOCKER\r\n";
   text += "----------------------------------------\r\n";
   text += status.main_blocker + "\r\n";
   text += "Layer 6 is ranking/scoring only; Layer 5 remains the only hard gate.\r\n";
   text += "\r\n";
   text += "ACTION\r\n";
   text += "----------------------------------------\r\n";
   text += "Board refresh is atomic and writes only when state text changes.\r\n";
   text += "No selection, alerts, or trade permission exists.\r\n";
   return text;
}

string AC_Layer0StatusRow(const AC_Layer0StatusPacket &status)
{
   return "schema_name=layer_status|schema_version=v0.12|layer_id=L0|layer_name=" + status.layer_name
      + "|source_owner=" + status.owner_name
      + "|status=" + status.status
      + "|trust_state=" + status.trust_state
      + "|broker_symbols_total=" + IntegerToString(status.broker_symbols_total)
      + "|marketwatch_symbols_total=" + IntegerToString(status.marketwatch_symbols_total)
      + "|dossier_shells_ready=" + IntegerToString(status.dossier_shells_ready)
      + "|dossier_shells_missing=" + IntegerToString(status.dossier_shells_missing)
      + "|failed_symbol_count=" + IntegerToString(status.failed_symbol_count)
      + "|retry_count_total=" + IntegerToString(status.retry_count_total)
      + "|completion=" + AC_PercentText(status.dossier_shells_ready, status.broker_symbols_total)
      + "|pass_start_index=" + IntegerToString(status.batch_start_index)
      + "|pass_end_index=" + IntegerToString(status.batch_end_index)
      + "|symbols_attempted=" + IntegerToString(status.batch_attempted)
      + "|symbols_written=" + IntegerToString(status.batch_written)
      + "|pass_duration_ms=" + IntegerToString((int)status.batch_duration_ms)
      + "|cached_pass_valid=" + (AC_L0_CACHED_PASS_VALID ? "true" : "false")
      + "|dossier_shell_schema_version=" + AC_DOSSIER_SHELL_SCHEMA_VERSION
      + "|cached_dossier_shell_schema_version=" + AC_L0_CACHED_DOSSIER_SCHEMA_VERSION
      + "|cached_l2_route_generation_key=" + AC_L0_CACHED_L2_ROUTE_GENERATION_KEY
      + "|cached_l3_cache_key=" + AC_L0_CACHED_L3_CACHE_KEY
      + "|cached_l4_cache_key=" + AC_L0_CACHED_L4_CACHE_KEY
      + "|cached_l4_refresh_key=" + AC_L0_CACHED_L4_REFRESH_KEY
      + "|cached_l5_status=" + AC_L0_CACHED_L5_STATUS
      + "|cached_l6_status=" + AC_L0_CACHED_L6_STATUS
      + "|cached_l6_checksum=" + AC_L0_CACHED_L6_CHECKSUM
      + "|main_blocker=" + status.main_blocker
      + "|trade_permission=false|ranking_runtime=" + (AC_L6_RANKED_ACCEPTED ? "true" : "false") + "|selection_runtime=false|market_state_known=" + (((AC_L2_OPEN_COUNT + AC_L2_CLOSED_COUNT) > 0) ? "true" : "false");
}

string AC_Layer0WorkbenchText(const AC_Layer0StatusPacket &status)
{
   string text = "";
   text += "L0_BOARD_DOSSIER_FOUNDATION\r\n";
   text += "----------------------------------------\r\n";
   text += "layer_id=L0\r\n";
   text += "layer_name=" + status.layer_name + "\r\n";
   text += "owner_name=" + status.owner_name + "\r\n";
   text += "status=" + status.status + "\r\n";
   text += "trust_state=" + status.trust_state + "\r\n";
   text += "broker_symbols_total=" + IntegerToString(status.broker_symbols_total) + "\r\n";
   text += "marketwatch_symbols_total=" + IntegerToString(status.marketwatch_symbols_total) + "\r\n";
   text += "dossier_shells_ready=" + IntegerToString(status.dossier_shells_ready) + "\r\n";
   text += "dossier_shells_missing=" + IntegerToString(status.dossier_shells_missing) + "\r\n";
   text += "failed_symbol_count=" + IntegerToString(status.failed_symbol_count) + "\r\n";
   text += "retry_count_total=" + IntegerToString(status.retry_count_total) + "\r\n";
   text += "completion=" + AC_PercentText(status.dossier_shells_ready, status.broker_symbols_total) + "\r\n";
   text += "pass_start_index=" + IntegerToString(status.batch_start_index) + "\r\n";
   text += "pass_end_index=" + IntegerToString(status.batch_end_index) + "\r\n";
   text += "symbols_attempted=" + IntegerToString(status.batch_attempted) + "\r\n";
   text += "symbols_written=" + IntegerToString(status.batch_written) + "\r\n";
   text += "pass_duration_ms=" + IntegerToString((int)status.batch_duration_ms) + "\r\n";
   text += "cached_pass_valid=" + (AC_L0_CACHED_PASS_VALID ? "true" : "false") + "\r\n";
   text += "dossier_shell_schema_version=" + AC_DOSSIER_SHELL_SCHEMA_VERSION + "\r\n";
   text += "cached_dossier_shell_schema_version=" + AC_L0_CACHED_DOSSIER_SCHEMA_VERSION + "\r\n";
   text += "l2_route_generation_key=" + AC_L2_ROUTE_GENERATION_KEY + "\r\n";
   text += "cached_l2_route_generation_key=" + AC_L0_CACHED_L2_ROUTE_GENERATION_KEY + "\r\n";
   text += "l3_cache_key=" + AC_L3_CACHE_KEY + "\r\n";
   text += "cached_l3_cache_key=" + AC_L0_CACHED_L3_CACHE_KEY + "\r\n";
   text += "l4_cache_key=" + AC_L4_CACHE_KEY + "\r\n";
   text += "l4_refresh_key=" + AC_L4_REFRESH_KEY + "\r\n";
   text += "cached_l4_cache_key=" + AC_L0_CACHED_L4_CACHE_KEY + "\r\n";
   text += "cached_l4_refresh_key=" + AC_L0_CACHED_L4_REFRESH_KEY + "\r\n";
   text += "cached_l5_status=" + AC_L0_CACHED_L5_STATUS + "\r\n";
   text += "cached_l6_status=" + AC_L0_CACHED_L6_STATUS + "\r\n";
   text += "cached_l6_checksum=" + AC_L0_CACHED_L6_CHECKSUM + "\r\n";
   text += "main_blocker=" + status.main_blocker + "\r\n";
   text += "first_failure=" + status.first_failure + "\r\n";
   text += "statistics_owner=layer_owner_packet_not_board_calculation\r\n";
   text += "gateway=used_for_L6_cost_friction_ranking_only_not_for_L0_L1_L2_L3_L4_or_L5\r\n";
   text += "mt5_script_worker=not_used_for_runtime_board_stats\r\n";
   text += "\r\n" + AC_Layer1WorkbenchSection();
   text += AC_Layer2WorkbenchSection();
   text += AC_Layer3WorkbenchSection();
   text += AC_Layer4WorkbenchSection();
   text += AC_Layer5WorkbenchSection();
   text += AC_Layer6WorkbenchSection();
   return text;
}

string AC_Layer0FailureAddendumText()
{
   string text = "";
   text += "L0_L2_L3_L4_L5_L6_FAILED_SYMBOL_PACKET_ADDENDUM\r\n";
   text += "----------------------------------------\r\n";
   if(AC_L0_FAILURE_ADDENDUM == "") text += "none\r\n";
   else text += AC_L0_FAILURE_ADDENDUM;
   return text;
}

#endif
