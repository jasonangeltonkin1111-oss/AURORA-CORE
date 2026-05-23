#ifndef AC_LAYER9_STRUCTURE_LOCATION_RENDERER_MQH
#define AC_LAYER9_STRUCTURE_LOCATION_RENDERER_MQH

// Runtime 7 render-only surface for Layer 9 Structure / Location Geometry.
// Reads only L9 sidecar proof files and Runtime 1 OHLC priority-window file existence.
// It must not calculate structure/location, rank, call CopyRates, select, permit, or execute.

static string AC_L9_STATUS = "Pending ranked sidecar";
static string AC_L9_TRUST_STATE = "Geometry Pending";
static string AC_L9_VALIDATION_STATUS = "Pending";
static string AC_L9_VALIDATION_REASON = "ranked_symbols.manifest missing or not accepted";
static string AC_L9_MAIN_BLOCKER = "ranked_symbols.manifest has not been accepted yet";
static bool   AC_L9_RANKED_ACCEPTED = false;
static int    AC_L9_INPUT_ROWS_RENDERED = 0;
static int    AC_L9_RANKED_ROWS_RENDERED = 0;
static int    AC_L9_RANKED_COUNT_RENDERED = 0;
static int    AC_L9_RANKED_PARTIAL_COUNT_RENDERED = 0;
static int    AC_L9_RANKED_RISK_REVIEW_COUNT_RENDERED = 0;
static int    AC_L9_NOT_RANKABLE_QUALITY_COUNT_RENDERED = 0;
static int    AC_L9_ELITE_COUNT_RENDERED = 0;
static int    AC_L9_STRONG_COUNT_RENDERED = 0;
static int    AC_L9_ACCEPTABLE_COUNT_RENDERED = 0;
static int    AC_L9_WEAK_COUNT_RENDERED = 0;
static int    AC_L9_LOW_ATTENTION_COUNT_RENDERED = 0;
static int    AC_L9_NEAR_HIGH_COUNT_RENDERED = 0;
static int    AC_L9_NEAR_LOW_COUNT_RENDERED = 0;
static int    AC_L9_MIDRANGE_COUNT_RENDERED = 0;
static int    AC_L9_COMPRESSION_COUNT_RENDERED = 0;
static int    AC_L9_SYMBOL_RANK_FILES_WRITTEN_RENDERED = 0;
static int    AC_L9_SYMBOL_RANK_FILES_ACTUAL_RENDERED = 0;
static string AC_L9_SYMBOL_RANK_FILE_COUNT_OK_RENDERED = "false";
static string AC_L9_INPUT_PAYLOAD_CHECKSUM_RENDERED = "not_available";
static string AC_L9_RANKED_PAYLOAD_CHECKSUM_RENDERED = "not_available";
static string AC_L9_TOP20_FIRST_LINE = "not_available";
static int    AC_L9_OHLC_M15_READY_RENDERED = 0;
static int    AC_L9_OHLC_H1_READY_RENDERED = 0;
static int    AC_L9_OHLC_H4_READY_RENDERED = 0;
static int    AC_L9_OHLC_D1_READY_RENDERED = 0;
static int    AC_L9_OHLC_REQUIRED_READY_RENDERED = 0;

string AC_L9LayerFolder(){ return AC_ExternalWorkerOutboxFolder() + "\\Layers\\Layer_9_Structure_Location_Geometry"; }
string AC_L9InputManifestPath(){ return AC_L9LayerFolder() + "\\l9_input_primitives.manifest"; }
string AC_L9RankedManifestPath(){ return AC_L9LayerFolder() + "\\ranked_symbols.manifest"; }
string AC_L9RankedCsvPath(){ return AC_L9LayerFolder() + "\\ranked_symbols.csv"; }
string AC_L9RankedTop20Path(){ return AC_L9LayerFolder() + "\\ranked_symbols_top20.txt"; }
string AC_L9SymbolRankFolderPath(){ return AC_L9LayerFolder() + "\\SymbolRanks"; }

string AC_L9ReadSmallTextFile(const string path, const int max_chars = 30000)
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

string AC_L9KvValue(const string text, const string key, const string fallback = "not_available")
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

int AC_L9KvInt(const string text, const string key, const int fallback = 0)
{
   string value = AC_L9KvValue(text, key, "");
   if(value == "") return fallback;
   return (int)StringToInteger(value);
}

string AC_L9BoolText(const bool value){ return value ? "TRUE" : "FALSE"; }
string AC_L9BoolKv(const bool value){ return value ? "true" : "false"; }

string AC_L9PipeField(const string pipe_text, const int index, const string fallback = "not_available")
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

string AC_L9FirstTop20Symbol(const string top20_text)
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

string AC_L9SymbolRankPathByFind(const string symbol)
{
   string pattern = AC_L9SymbolRankFolderPath() + "\\" + AC_SanitizePathPart(symbol) + "__*.txt";
   string found = "";
   long handle = FileFindFirst(pattern, found, AC_CommonFlag());
   if(handle == INVALID_HANDLE) return "";
   FileFindClose(handle);
   if(found == "") return "";
   return AC_L9SymbolRankFolderPath() + "\\" + found;
}

bool AC_L9FastWindowAvailable(const string symbol, const string tf)
{
   return FileIsExist(AC_SharedOhlcFastWindowPath(symbol, tf), AC_CommonFlag());
}

string AC_L9PrettyRankState(string value)
{
   if(value == "ranked") return "Ranked";
   if(value == "ranked_partial") return "Ranked Partial";
   if(value == "ranked_risk_review") return "Risk Review";
   if(value == "not_rankable_quality") return "Not Rankable";
   StringReplace(value, "_", " ");
   return value;
}

string AC_L9PrettyBucket(string value)
{
   if(value == "elite_structure_watch") return "Elite Structure Watch";
   if(value == "strong_structure_watch") return "Strong Structure Watch";
   if(value == "acceptable_structure_watch") return "Acceptable Structure Watch";
   if(value == "weak_structure_watch") return "Weak Structure Watch";
   if(value == "low_attention_structure") return "Low Attention Structure";
   StringReplace(value, "_", " ");
   return value;
}

string AC_L9PrettyEvent(string value)
{
   if(value == "near_high_event_zone") return "Near High Event Zone";
   if(value == "near_low_event_zone") return "Near Low Event Zone";
   if(value == "upper_range_watch") return "Upper Range Watch";
   if(value == "lower_range_watch") return "Lower Range Watch";
   if(value == "midrange_low_attention") return "Midrange Low Attention";
   if(value == "structure_data_partial") return "Structure Data Partial";
   StringReplace(value, "_", " ");
   return value;
}

string AC_L9PrettyTop20Line(string pipe_line)
{
   if(pipe_line == "" || pipe_line == "not_available") return "not_available";
   string rank = AC_L9PipeField(pipe_line, 0, "");
   string symbol = AC_L9PipeField(pipe_line, 1, "");
   string score = AC_L9PipeField(pipe_line, 2, "");
   string bucket = AC_L9PipeField(pipe_line, 3, "");
   string state = AC_L9PipeField(pipe_line, 4, "");
   string event_zone = AC_L9PipeField(pipe_line, 5, "");
   if(rank == "" || symbol == "" || score == "" || bucket == "" || state == "" || event_zone == "") return "not_available";
   return "#" + rank + " " + symbol + " | " + score + " | " + AC_L9PrettyBucket(bucket) + " | " + AC_L9PrettyRankState(state) + " | " + AC_L9PrettyEvent(event_zone);
}

void AC_L9RefreshOhlcWindowReadiness()
{
   AC_L9_OHLC_M15_READY_RENDERED = 0;
   AC_L9_OHLC_H1_READY_RENDERED = 0;
   AC_L9_OHLC_H4_READY_RENDERED = 0;
   AC_L9_OHLC_D1_READY_RENDERED = 0;
   AC_L9_OHLC_REQUIRED_READY_RENDERED = 0;
   for(int i = 0; i < ArraySize(AC_L5_SYMBOLS); i++)
   {
      if(!AC_L5_SYMBOLS[i].pass) continue;
      string symbol = AC_L5_SYMBOLS[i].symbol;
      bool m15 = AC_L9FastWindowAvailable(symbol, "M15");
      bool h1 = AC_L9FastWindowAvailable(symbol, "H1");
      bool h4 = AC_L9FastWindowAvailable(symbol, "H4");
      bool d1 = AC_L9FastWindowAvailable(symbol, "D1");
      if(m15) AC_L9_OHLC_M15_READY_RENDERED++;
      if(h1) AC_L9_OHLC_H1_READY_RENDERED++;
      if(h4) AC_L9_OHLC_H4_READY_RENDERED++;
      if(d1) AC_L9_OHLC_D1_READY_RENDERED++;
      if(m15 && h1 && h4 && d1) AC_L9_OHLC_REQUIRED_READY_RENDERED++;
   }
}

void AC_L9RefreshRankedSidecar()
{
   AC_L9RefreshOhlcWindowReadiness();
   AC_L9_RANKED_ACCEPTED = false;
   string input_manifest = AC_L9ReadSmallTextFile(AC_L9InputManifestPath(), 30000);
   if(input_manifest == "")
   {
      AC_L9_STATUS = "Input pending";
      AC_L9_TRUST_STATE = "Geometry Pending";
      AC_L9_VALIDATION_STATUS = "Missing";
      AC_L9_VALIDATION_REASON = "l9_input_primitives.manifest missing or unreadable";
      AC_L9_MAIN_BLOCKER = AC_L9_VALIDATION_REASON;
      return;
   }

   AC_L9_INPUT_ROWS_RENDERED = AC_L9KvInt(input_manifest, "row_count", 0);
   AC_L9_INPUT_PAYLOAD_CHECKSUM_RENDERED = AC_L9KvValue(input_manifest, "payload_checksum", "not_available");

   string ranked_manifest = AC_L9ReadSmallTextFile(AC_L9RankedManifestPath(), 30000);
   if(ranked_manifest == "")
   {
      AC_L9_STATUS = "Input export ready - ranked sidecar pending";
      AC_L9_TRUST_STATE = "Geometry Pending";
      AC_L9_VALIDATION_STATUS = "InputAccepted";
      AC_L9_VALIDATION_REASON = "input manifest accepted; ranked_symbols.manifest missing or unreadable";
      AC_L9_MAIN_BLOCKER = "ranked_symbols.manifest has not been built or accepted yet";
      return;
   }

   string ranked_status = AC_L9KvValue(ranked_manifest, "status", "not_available");
   AC_L9_RANKED_ROWS_RENDERED = AC_L9KvInt(ranked_manifest, "row_count", 0);
   AC_L9_RANKED_COUNT_RENDERED = AC_L9KvInt(ranked_manifest, "ranked_count", 0);
   AC_L9_RANKED_PARTIAL_COUNT_RENDERED = AC_L9KvInt(ranked_manifest, "ranked_partial_count", 0);
   AC_L9_RANKED_RISK_REVIEW_COUNT_RENDERED = AC_L9KvInt(ranked_manifest, "ranked_risk_review_count", 0);
   AC_L9_NOT_RANKABLE_QUALITY_COUNT_RENDERED = AC_L9KvInt(ranked_manifest, "not_rankable_quality_count", 0);
   AC_L9_ELITE_COUNT_RENDERED = AC_L9KvInt(ranked_manifest, "elite_structure_watch_count", 0);
   AC_L9_STRONG_COUNT_RENDERED = AC_L9KvInt(ranked_manifest, "strong_structure_watch_count", 0);
   AC_L9_ACCEPTABLE_COUNT_RENDERED = AC_L9KvInt(ranked_manifest, "acceptable_structure_watch_count", 0);
   AC_L9_WEAK_COUNT_RENDERED = AC_L9KvInt(ranked_manifest, "weak_structure_watch_count", 0);
   AC_L9_LOW_ATTENTION_COUNT_RENDERED = AC_L9KvInt(ranked_manifest, "low_attention_structure_count", 0);
   AC_L9_NEAR_HIGH_COUNT_RENDERED = AC_L9KvInt(ranked_manifest, "near_high_event_zone_count", 0);
   AC_L9_NEAR_LOW_COUNT_RENDERED = AC_L9KvInt(ranked_manifest, "near_low_event_zone_count", 0);
   AC_L9_MIDRANGE_COUNT_RENDERED = AC_L9KvInt(ranked_manifest, "midrange_low_attention_count", 0);
   AC_L9_COMPRESSION_COUNT_RENDERED = AC_L9KvInt(ranked_manifest, "compression_at_boundary_count", 0);
   AC_L9_SYMBOL_RANK_FILES_WRITTEN_RENDERED = AC_L9KvInt(ranked_manifest, "symbol_rank_files_written", 0);
   AC_L9_SYMBOL_RANK_FILES_ACTUAL_RENDERED = AC_L9KvInt(ranked_manifest, "symbol_rank_files_actual", 0);
   AC_L9_SYMBOL_RANK_FILE_COUNT_OK_RENDERED = AC_L9KvValue(ranked_manifest, "symbol_rank_file_count_ok", "false");
   AC_L9_RANKED_PAYLOAD_CHECKSUM_RENDERED = AC_L9KvValue(ranked_manifest, "ranked_payload_checksum", "not_available");

   bool status_ok = (ranked_status == "complete" || ranked_status == "empty_input");
   bool counts_ok = (AC_L9_INPUT_ROWS_RENDERED == AC_L9_RANKED_ROWS_RENDERED && AC_L9_RANKED_ROWS_RENDERED >= 0);
   bool files_ok = FileIsExist(AC_L9RankedCsvPath(), AC_CommonFlag())
      && FileIsExist(AC_L9RankedTop20Path(), AC_CommonFlag())
      && AC_L9_SYMBOL_RANK_FILE_COUNT_OK_RENDERED == "true";

   if(status_ok && counts_ok && files_ok)
   {
      AC_L9_RANKED_ACCEPTED = true;
      AC_L9_STATUS = "Ranked sidecar accepted";
      AC_L9_TRUST_STATE = "Geometry Ready";
      AC_L9_VALIDATION_STATUS = "Accepted";
      AC_L9_VALIDATION_REASON = "ranked manifest/top20/csv/SymbolRanks sidecars match L9 input proof and permission boundaries";
      AC_L9_MAIN_BLOCKER = "none";
      AC_L9_TOP20_FIRST_LINE = AC_L9PrettyTop20Line(AC_L9FirstTop20Symbol(AC_L9ReadSmallTextFile(AC_L9RankedTop20Path(), 16000)));
      return;
   }

   AC_L9_STATUS = "Ranked sidecar degraded";
   AC_L9_TRUST_STATE = "Geometry Degraded";
   AC_L9_VALIDATION_STATUS = "Degraded";
   AC_L9_VALIDATION_REASON = "status_ok=" + (status_ok ? "true" : "false")
      + ";counts_ok=" + (counts_ok ? "true" : "false")
      + ";files_ok=" + (files_ok ? "true" : "false");
   AC_L9_MAIN_BLOCKER = AC_L9_VALIDATION_REASON;
}

string AC_Layer9BoardSection()
{
   AC_L9RefreshRankedSidecar();
   string text = "";
   text += "\r\nLAYER 9 - STRUCTURE / LOCATION GEOMETRY\r\n";
   text += "----------------------------------------\r\n";
   text += "Status:                     " + AC_L9_STATUS + "\r\n";
   text += "Trust:                      " + AC_L9_TRUST_STATE + "\r\n";
   text += "Validation:                 " + AC_L9_VALIDATION_STATUS + "\r\n";
   text += "Owner:                      Runtime 4 - Surface Scoring Owner\r\n";
   text += "Gateway Required:           TRUE\r\n";
   text += "Gateway Result Accepted:    " + AC_L9BoolText(AC_L9_RANKED_ACCEPTED) + "\r\n";
   text += "Input Source:               Runtime 1 OHLC Priority Windows + Layer 5 pass set\r\n";
   text += "Current L5 Pass Symbols:    " + IntegerToString(AC_L5_GATE_PASS) + "\r\n";
   text += "M15/H1/H4/D1 Ready:         " + IntegerToString(AC_L9_OHLC_M15_READY_RENDERED) + " / " + IntegerToString(AC_L9_OHLC_H1_READY_RENDERED) + " / " + IntegerToString(AC_L9_OHLC_H4_READY_RENDERED) + " / " + IntegerToString(AC_L9_OHLC_D1_READY_RENDERED) + "\r\n";
   text += "All Required Windows Ready: " + IntegerToString(AC_L9_OHLC_REQUIRED_READY_RENDERED) + " / " + IntegerToString(AC_L5_GATE_PASS) + "\r\n";
   text += "Manifest Input Count:       " + IntegerToString(AC_L9_INPUT_ROWS_RENDERED) + "\r\n";
   text += "Ranked Symbols:             " + IntegerToString(AC_L9_RANKED_ROWS_RENDERED) + "\r\n";
   text += "Ranked Clean:               " + IntegerToString(AC_L9_RANKED_COUNT_RENDERED) + "\r\n";
   text += "Ranked Partial:             " + IntegerToString(AC_L9_RANKED_PARTIAL_COUNT_RENDERED) + "\r\n";
   text += "Risk Review:                " + IntegerToString(AC_L9_RANKED_RISK_REVIEW_COUNT_RENDERED) + "\r\n";
   text += "Not Rankable Quality:       " + IntegerToString(AC_L9_NOT_RANKABLE_QUALITY_COUNT_RENDERED) + "\r\n";
   text += "Elite Structure Watch:      " + IntegerToString(AC_L9_ELITE_COUNT_RENDERED) + "\r\n";
   text += "Strong Structure Watch:     " + IntegerToString(AC_L9_STRONG_COUNT_RENDERED) + "\r\n";
   text += "Near High Event Zones:      " + IntegerToString(AC_L9_NEAR_HIGH_COUNT_RENDERED) + "\r\n";
   text += "Near Low Event Zones:       " + IntegerToString(AC_L9_NEAR_LOW_COUNT_RENDERED) + "\r\n";
   text += "Compression At Boundary:    " + IntegerToString(AC_L9_COMPRESSION_COUNT_RENDERED) + "\r\n";
   text += "Top Ranked:                 " + AC_L9_TOP20_FIRST_LINE + "\r\n";
   text += "Geometry Policy:            watchlist_only_no_direction_no_entry_no_selection_no_execution\r\n";
   text += "Ranked CSV:                 Outbox\\Layers\\Layer_9_Structure_Location_Geometry\\ranked_symbols.csv\r\n";
   text += "Main Blocker:               " + AC_L9_MAIN_BLOCKER + "\r\n";
   text += "Gateway Job:                L9_STRUCTURE_LOCATION_GEOMETRY_V1\r\n";
   text += "Ranking Runtime:            " + AC_L9BoolText(AC_L9_RANKED_ACCEPTED) + "\r\n";
   text += "Selection Runtime:          FALSE\r\n";
   text += "Trade Permission:           FALSE\r\n";
   return text;
}

string AC_Layer9DossierSection(const string symbol)
{
   AC_L9RefreshRankedSidecar();
   string text = "";
   text += "\r\nLAYER 9 - STRUCTURE / LOCATION GEOMETRY\r\n";
   text += "----------------------------------------\r\n";
   text += "Status: " + AC_L9_STATUS + "\r\n";
   text += "Owner: Runtime 4 - Surface Scoring Owner\r\n";
   text += "Gateway Result Accepted: " + AC_L9BoolText(AC_L9_RANKED_ACCEPTED) + "\r\n";
   text += "Validation: " + AC_L9_VALIDATION_STATUS + "\r\n";
   text += "M15/H1/H4/D1 Windows: " + (AC_L9FastWindowAvailable(symbol,"M15") ? "available" : "pending") + " / " + (AC_L9FastWindowAvailable(symbol,"H1") ? "available" : "pending") + " / " + (AC_L9FastWindowAvailable(symbol,"H4") ? "available" : "pending") + " / " + (AC_L9FastWindowAvailable(symbol,"D1") ? "available" : "pending") + "\r\n";

   if(!AC_L9_RANKED_ACCEPTED)
   {
      text += "Rank State: ranked_sidecar_not_accepted\r\n";
      text += "Structure Watchlist Score: pending\r\n";
      text += "Validation Reason: " + AC_L9_VALIDATION_REASON + "\r\n";
   }
   else
   {
      string rank_path = AC_L9SymbolRankPathByFind(symbol);
      string rank_text = rank_path == "" ? "" : AC_L9ReadSmallTextFile(rank_path, 16000);
      if(rank_text == "")
      {
         text += "Rank State: symbol_rank_sidecar_missing\r\n";
         text += "Structure Watchlist Score: missing\r\n";
      }
      else
      {
         text += "Symbol Review State: " + AC_L9PrettyRankState(AC_L9KvValue(rank_text, "rank_state", "not_available")) + "\r\n";
         text += "Rank Index: " + AC_L9KvValue(rank_text, "rank_index", "not_available") + " / " + IntegerToString(AC_L9_RANKED_ROWS_RENDERED) + "\r\n";
         text += "Structure Watchlist Score: " + AC_L9KvValue(rank_text, "structure_watchlist_score", "not_available") + "\r\n";
         text += "Structure Bucket: " + AC_L9PrettyBucket(AC_L9KvValue(rank_text, "structure_bucket", "not_available")) + "\r\n";
         text += "Event Zone: " + AC_L9PrettyEvent(AC_L9KvValue(rank_text, "event_zone", "not_available")) + "\r\n";
         text += "Geometry Regime: " + AC_L9KvValue(rank_text, "geometry_regime", "not_available") + "\r\n";
         text += "Watchlist: " + AC_L9KvValue(rank_text, "watchlist", "not_available") + "\r\n";
         text += "Price Basis: " + AC_L9KvValue(rank_text, "price_basis", "not_available") + "\r\n";
         text += "M15 Position: " + AC_L9KvValue(rank_text, "m15_position_pct", "not_available") + "% | " + AC_L9PrettyEvent(AC_L9KvValue(rank_text, "m15_zone_state", "not_available")) + "\r\n";
         text += "H1 Position: " + AC_L9KvValue(rank_text, "h1_position_pct", "not_available") + "% | " + AC_L9PrettyEvent(AC_L9KvValue(rank_text, "h1_zone_state", "not_available")) + "\r\n";
         text += "H4 Position: " + AC_L9KvValue(rank_text, "h4_position_pct", "not_available") + "% | " + AC_L9PrettyEvent(AC_L9KvValue(rank_text, "h4_zone_state", "not_available")) + "\r\n";
         text += "D1 Position: " + AC_L9KvValue(rank_text, "d1_position_pct", "not_available") + "% | " + AC_L9PrettyEvent(AC_L9KvValue(rank_text, "d1_zone_state", "not_available")) + "\r\n";
         text += "Room Up / Down ATR: " + AC_L9KvValue(rank_text, "room_up_atr", "not_available") + " / " + AC_L9KvValue(rank_text, "room_down_atr", "not_available") + "\r\n";
         text += "Room Profile: " + AC_L9KvValue(rank_text, "room_profile", "not_available") + "\r\n";
         text += "Boundary Touch Count: " + AC_L9KvValue(rank_text, "boundary_touch_count", "not_available") + "\r\n";
         text += "Reason: " + AC_L9KvValue(rank_text, "reason", "not_available") + "\r\n";
         text += "Rank Source: " + rank_path + "\r\n";
      }
   }

   text += "Geometry Policy: watchlist only; no direction, entry, selection, permission, or execution\r\n";
   text += "Layer 9 Blocks Symbols: FALSE\r\n";
   text += "Selection Runtime: FALSE\r\n";
   text += "Trade Permission: FALSE\r\n";
   text += "Execution: FALSE\r\n";
   return text;
}

string AC_Layer9WorkbenchSection()
{
   AC_L9RefreshRankedSidecar();
   string text = "";
   text += "\r\nL9_STRUCTURE_LOCATION_GEOMETRY\r\n";
   text += "----------------------------------------\r\n";
   text += "owner_name=Runtime 4 - Surface Scoring Owner\r\n";
   text += "layer_name=Layer 9 - Structure / Location Geometry\r\n";
   text += "status=" + AC_L9_STATUS + "\r\n";
   text += "trust_state=" + AC_L9_TRUST_STATE + "\r\n";
   text += "validation_status=" + AC_L9_VALIDATION_STATUS + "\r\n";
   text += "validation_reason=" + AC_L9_VALIDATION_REASON + "\r\n";
   text += "gateway_required=true\r\n";
   text += "gateway_result_accepted=" + AC_L9BoolKv(AC_L9_RANKED_ACCEPTED) + "\r\n";
   text += "job_type=L9_STRUCTURE_LOCATION_GEOMETRY_V1\r\n";
   text += "current_l5_pass_symbols=" + IntegerToString(AC_L5_GATE_PASS) + "\r\n";
   text += "ohlc_m15_ready=" + IntegerToString(AC_L9_OHLC_M15_READY_RENDERED) + "\r\n";
   text += "ohlc_h1_ready=" + IntegerToString(AC_L9_OHLC_H1_READY_RENDERED) + "\r\n";
   text += "ohlc_h4_ready=" + IntegerToString(AC_L9_OHLC_H4_READY_RENDERED) + "\r\n";
   text += "ohlc_d1_ready=" + IntegerToString(AC_L9_OHLC_D1_READY_RENDERED) + "\r\n";
   text += "ranked_symbols=" + IntegerToString(AC_L9_RANKED_ROWS_RENDERED) + "\r\n";
   text += "ranked_count=" + IntegerToString(AC_L9_RANKED_COUNT_RENDERED) + "\r\n";
   text += "ranked_partial_count=" + IntegerToString(AC_L9_RANKED_PARTIAL_COUNT_RENDERED) + "\r\n";
   text += "ranked_risk_review_count=" + IntegerToString(AC_L9_RANKED_RISK_REVIEW_COUNT_RENDERED) + "\r\n";
   text += "not_rankable_quality_count=" + IntegerToString(AC_L9_NOT_RANKABLE_QUALITY_COUNT_RENDERED) + "\r\n";
   text += "near_high_event_zone_count=" + IntegerToString(AC_L9_NEAR_HIGH_COUNT_RENDERED) + "\r\n";
   text += "near_low_event_zone_count=" + IntegerToString(AC_L9_NEAR_LOW_COUNT_RENDERED) + "\r\n";
   text += "compression_at_boundary_count=" + IntegerToString(AC_L9_COMPRESSION_COUNT_RENDERED) + "\r\n";
   text += "symbol_rank_files_written=" + IntegerToString(AC_L9_SYMBOL_RANK_FILES_WRITTEN_RENDERED) + "\r\n";
   text += "symbol_rank_files_actual=" + IntegerToString(AC_L9_SYMBOL_RANK_FILES_ACTUAL_RENDERED) + "\r\n";
   text += "symbol_rank_file_count_ok=" + AC_L9_SYMBOL_RANK_FILE_COUNT_OK_RENDERED + "\r\n";
   text += "top_ranked=" + AC_L9_TOP20_FIRST_LINE + "\r\n";
   text += "structure_location_policy=watchlist_only_no_direction_no_entry_no_selection_no_execution\r\n";
   text += "main_blocker=" + AC_L9_MAIN_BLOCKER + "\r\n";
   text += "ranking_runtime=" + AC_L9BoolKv(AC_L9_RANKED_ACCEPTED) + "\r\n";
   text += "selection_runtime=false\r\n";
   text += "trade_permission=false\r\n";
   return text;
}

#endif