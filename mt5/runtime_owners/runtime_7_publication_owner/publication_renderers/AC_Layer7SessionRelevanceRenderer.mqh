#ifndef AC_LAYER7_SESSION_RELEVANCE_RENDERER_MQH
#define AC_LAYER7_SESSION_RELEVANCE_RENDERER_MQH

// Runtime 7 render-only surface for Layer 7 Session Relevance.
// Reads only the lightweight L7 input-primitives manifest in this stage.
// It must not score, rank, decide sessions, gate symbols, select, permit, execute,
// parse ranked CSV files, call SymbolInfoSession*, CopyTicks, or CopyRates.

string AC_L7InputLayerFolder()
{
   return AC_ExternalWorkerOutboxFolder() + "\\Layers\\Layer_7_Session_Relevance_Ranking";
}

string AC_L7InputManifestPath()
{
   return AC_L7InputLayerFolder() + "\\l7_input_primitives.manifest";
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

void AC_L7LoadInputManifest(string &manifest_text,
                            bool &manifest_present,
                            string &write_status,
                            string &write_ok,
                            int &row_count,
                            int &l5_gate_pass,
                            string &payload_checksum,
                            string &csv_path,
                            string &session_time_basis,
                            string &session_definition_source,
                            bool &input_counts_ok,
                            bool &live_l5_drift,
                            int &live_l5_drift_delta)
{
   manifest_text = AC_L7ReadSmallTextFile(AC_L7InputManifestPath(), 30000);
   manifest_present = (manifest_text != "");
   write_status = "missing";
   write_ok = "false";
   row_count = 0;
   l5_gate_pass = 0;
   payload_checksum = "not_available";
   csv_path = "not_available";
   session_time_basis = "pending";
   session_definition_source = "pending";
   input_counts_ok = false;
   live_l5_drift = false;
   live_l5_drift_delta = 0;

   if(!manifest_present)
      return;

   write_status = AC_L7KvValue(manifest_text, "write_status", "not_available");
   write_ok = AC_L7KvValue(manifest_text, "write_ok", "false");
   row_count = AC_L7KvInt(manifest_text, "row_count", 0);
   l5_gate_pass = AC_L7KvInt(manifest_text, "l5_gate_pass", 0);
   payload_checksum = AC_L7KvValue(manifest_text, "payload_checksum", "not_available");
   csv_path = AC_L7KvValue(manifest_text, "csv_path", "not_available");
   session_time_basis = AC_L7KvValue(manifest_text, "session_time_basis", "pending");
   session_definition_source = AC_L7KvValue(manifest_text, "session_definition_source", "pending");
   input_counts_ok = (write_ok == "true" && row_count > 0 && row_count == l5_gate_pass);
   live_l5_drift = (row_count != AC_L5_GATE_PASS);
   live_l5_drift_delta = row_count - AC_L5_GATE_PASS;
}

string AC_Layer7BoardSection()
{
   string manifest_text;
   bool manifest_present;
   string write_status;
   string write_ok;
   int row_count;
   int l5_gate_pass;
   string payload_checksum;
   string csv_path;
   string session_time_basis;
   string session_definition_source;
   bool input_counts_ok;
   bool live_l5_drift;
   int live_l5_drift_delta;
   AC_L7LoadInputManifest(manifest_text, manifest_present, write_status, write_ok, row_count, l5_gate_pass, payload_checksum, csv_path, session_time_basis, session_definition_source, input_counts_ok, live_l5_drift, live_l5_drift_delta);

   string current_l5_pass = IntegerToString(AC_L5_GATE_PASS);
   string status = input_counts_ok ? "Input export ready - ranked sidecar pending" : "Pending ranked sidecar";
   string validation = input_counts_ok ? "InputAccepted" : (manifest_present ? "InputDegraded" : "Pending");
   string main_blocker = input_counts_ok ? "ranked_symbols.manifest has not been built or accepted yet" : "l7_input_primitives.manifest missing or degraded; ranked sidecar not built";

   string text = "";
   text += "\r\nLAYER 7 - SESSION RELEVANCE RANKING\r\n";
   text += "----------------------------------------\r\n";
   text += "Status: " + status + "\r\n";
   text += "Trust: Ranking Pending\r\n";
   text += "Validation: " + validation + "\r\n";
   text += "Owner: Runtime 4 - Surface Scoring Owner\r\n";
   text += "Gateway Required: TRUE\r\n";
   text += "Gateway Result Accepted: FALSE\r\n";
   text += "Input Source: Layer 5 pass set only\r\n";
   text += "Current L5 Pass Symbols: " + current_l5_pass + "\r\n";
   text += "L7 Input Export Status: " + write_status + "\r\n";
   text += "L7 Input Export Accepted: " + AC_L7BoolText(input_counts_ok) + "\r\n";
   text += "L7 Export L5 Pass Symbols: " + IntegerToString(l5_gate_pass) + "\r\n";
   text += "Manifest Input Count: " + IntegerToString(row_count) + "\r\n";
   text += "Input Counts OK: " + AC_L7BoolText(input_counts_ok) + "\r\n";
   text += "Ranked Symbols: 0\r\n";
   text += "Generation Counts OK: FALSE\r\n";
   text += "Generation Identity OK: FALSE\r\n";
   text += "L7 Snapshot Drift: " + AC_L7BoolText(live_l5_drift) + "\r\n";
   text += "L7 Drift Delta: " + IntegerToString(live_l5_drift_delta) + "\r\n";
   text += "Current Global Session: pending_gateway_scoring\r\n";
   text += "Session Basis: " + session_time_basis + "\r\n";
   text += "Session Definition Source: " + session_definition_source + "\r\n";
   text += "UTC Basis: pending_gateway_snapshot\r\n";
   text += "Input Manifest: Outbox\\Layers\\Layer_7_Session_Relevance_Ranking\\l7_input_primitives.manifest\r\n";
   text += "Input CSV: Outbox\\Layers\\Layer_7_Session_Relevance_Ranking\\l7_input_primitives.csv\r\n";
   text += "Main Blocker: " + main_blocker + "\r\n";
   text += "Gateway Job: L7_SESSION_RELEVANCE_RANKING_V1\r\n";
   text += "Ranking Runtime: FALSE\r\n";
   text += "Selection Runtime: FALSE\r\n";
   text += "Trade Permission: FALSE\r\n";
   return text;
}

string AC_Layer7DossierSection(const string symbol)
{
   string manifest_text;
   bool manifest_present;
   string write_status;
   string write_ok;
   int row_count;
   int l5_gate_pass;
   string payload_checksum;
   string csv_path;
   string session_time_basis;
   string session_definition_source;
   bool input_counts_ok;
   bool live_l5_drift;
   int live_l5_drift_delta;
   AC_L7LoadInputManifest(manifest_text, manifest_present, write_status, write_ok, row_count, l5_gate_pass, payload_checksum, csv_path, session_time_basis, session_definition_source, input_counts_ok, live_l5_drift, live_l5_drift_delta);

   string l5_gate_status = "not_available";
   int l5_index = AC_L5FindIndex(symbol);
   if(l5_index >= 0)
   {
      l5_gate_status = AC_L5_SYMBOLS[l5_index].pass ? "pass" : "not_pass";
   }

   string status = input_counts_ok ? "Input export ready - ranked sidecar pending" : "Pending ranked sidecar";
   string validation = input_counts_ok ? "InputAccepted" : (manifest_present ? "InputDegraded" : "Pending");

   string text = "";
   text += "\r\nLAYER 7 - SESSION RELEVANCE RANKING\r\n";
   text += "----------------------------------------\r\n";
   text += "Status: " + status + "\r\n";
   text += "Owner: Runtime 4 - Surface Scoring Owner\r\n";
   text += "Gateway Result Accepted: FALSE\r\n";
   text += "Validation: " + validation + "\r\n";
   text += "Input Export Status: " + write_status + "\r\n";
   text += "Input Export Rows: " + IntegerToString(row_count) + "\r\n";
   text += "Input Counts OK: " + AC_L7BoolText(input_counts_ok) + "\r\n";
   text += "L7 Snapshot Drift: " + AC_L7BoolText(live_l5_drift) + "\r\n";
   text += "L5 Gate Status: " + l5_gate_status + "\r\n";
   text += "Rank State: ranked_sidecar_not_built\r\n";
   text += "Session Score: pending\r\n";
   text += "Session Bucket: pending\r\n";
   text += "Score Quality: pending\r\n";
   text += "Current Session: pending_gateway_scoring\r\n";
   text += "Session Definition Source: " + session_definition_source + "\r\n";
   text += "Session Time Basis: " + session_time_basis + "\r\n";
   text += "UTC Basis: pending_gateway_snapshot\r\n";
   text += "Boundary:\r\n";
   text += "Source Owner: Layer 5 pass set + Layer 2/3/4 packets\r\n";
   text += "Scoring Owner: Runtime 4 - Surface Scoring Owner via Runtime 3 Gateway support later\r\n";
   text += "Layer 7 Blocks Symbols: FALSE\r\n";
   text += "Selection Runtime: FALSE\r\n";
   text += "Trade Permission: FALSE\r\n";
   text += "Execution: FALSE\r\n";
   return text;
}

string AC_Layer7WorkbenchSection()
{
   string manifest_text;
   bool manifest_present;
   string write_status;
   string write_ok;
   int row_count;
   int l5_gate_pass;
   string payload_checksum;
   string csv_path;
   string session_time_basis;
   string session_definition_source;
   bool input_counts_ok;
   bool live_l5_drift;
   int live_l5_drift_delta;
   AC_L7LoadInputManifest(manifest_text, manifest_present, write_status, write_ok, row_count, l5_gate_pass, payload_checksum, csv_path, session_time_basis, session_definition_source, input_counts_ok, live_l5_drift, live_l5_drift_delta);

   string status = input_counts_ok ? "Input export ready - ranked sidecar pending" : "Pending ranked sidecar";
   string validation = input_counts_ok ? "InputAccepted" : (manifest_present ? "InputDegraded" : "Pending");

   string text = "";
   text += "\r\nL7_SESSION_RELEVANCE_RANKING\r\n";
   text += "----------------------------------------\r\n";
   text += "owner_name=Runtime 4 - Surface Scoring Owner\r\n";
   text += "layer_name=Layer 7 - Session Relevance Ranking\r\n";
   text += "status=" + status + "\r\n";
   text += "trust_state=Ranking Pending\r\n";
   text += "validation_status=" + validation + "\r\n";
   text += "gateway_required=true\r\n";
   text += "gateway_result_accepted=false\r\n";
   text += "job_type=L7_SESSION_RELEVANCE_RANKING_V1\r\n";
   text += "current_l5_pass_symbols=" + IntegerToString(AC_L5_GATE_PASS) + "\r\n";
   text += "l7_input_manifest_present=" + AC_L7BoolKv(manifest_present) + "\r\n";
   text += "l7_input_export_status=" + write_status + "\r\n";
   text += "l7_input_export_accepted=" + AC_L7BoolKv(input_counts_ok) + "\r\n";
   text += "l7_export_l5_pass_symbols=" + IntegerToString(l5_gate_pass) + "\r\n";
   text += "manifest_input_count=" + IntegerToString(row_count) + "\r\n";
   text += "input_counts_ok=" + AC_L7BoolKv(input_counts_ok) + "\r\n";
   text += "ranked_symbols=0\r\n";
   text += "generation_counts_ok=false\r\n";
   text += "generation_identity_ok=false\r\n";
   text += "live_l5_drift=" + AC_L7BoolKv(live_l5_drift) + "\r\n";
   text += "live_l5_drift_delta=" + IntegerToString(live_l5_drift_delta) + "\r\n";
   text += "source_input_payload_checksum=" + payload_checksum + "\r\n";
   text += "input_manifest_path=Outbox\\Layers\\Layer_7_Session_Relevance_Ranking\\l7_input_primitives.manifest\r\n";
   text += "input_csv_path=Outbox\\Layers\\Layer_7_Session_Relevance_Ranking\\l7_input_primitives.csv\r\n";
   text += "current_global_session=pending_gateway_scoring\r\n";
   text += "session_time_basis=" + session_time_basis + "\r\n";
   text += "session_definition_source=" + session_definition_source + "\r\n";
   text += "utc_basis=pending_gateway_snapshot\r\n";
   text += "ranking_runtime=false\r\n";
   text += "selection_runtime=false\r\n";
   text += "trade_permission=false\r\n";
   return text;
}

#endif