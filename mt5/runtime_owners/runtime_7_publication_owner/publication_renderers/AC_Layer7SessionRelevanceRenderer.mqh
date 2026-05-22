#ifndef AC_LAYER7_SESSION_RELEVANCE_RENDERER_MQH
#define AC_LAYER7_SESSION_RELEVANCE_RENDERER_MQH

string AC_Layer7BoardSection()
{
   string current_l5_pass = "not_available";
#ifdef AC_L5_GATE_PASS
   current_l5_pass = IntegerToString(AC_L5_GATE_PASS);
#endif

   string text = "";
   text += "\r\nLAYER 7 - SESSION RELEVANCE RANKING\r\n";
   text += "----------------------------------------\r\n";
   text += "Status: Pending ranked sidecar\r\n";
   text += "Trust: Ranking Pending\r\n";
   text += "Validation: Pending\r\n";
   text += "Owner: Runtime 4 - Surface Scoring Owner\r\n";
   text += "Gateway Required: TRUE\r\n";
   text += "Gateway Result Accepted: FALSE\r\n";
   text += "Input Source: Layer 5 pass set only\r\n";
   text += "Current L5 Pass Symbols: " + current_l5_pass + "\r\n";
   text += "L7 Export L5 Pass Symbols: 0\r\n";
   text += "Manifest Input Count: 0\r\n";
   text += "Ranked Symbols: 0\r\n";
   text += "Generation Counts OK: FALSE\r\n";
   text += "Generation Identity OK: FALSE\r\n";
   text += "L7 Snapshot Drift: FALSE\r\n";
   text += "L7 Drift Delta: 0\r\n";
   text += "Current Global Session: pending\r\n";
   text += "Session Basis: pending\r\n";
   text += "UTC Basis: pending\r\n";
   text += "Main Blocker: ranked_symbols.manifest has not been built or accepted yet\r\n";
   text += "Gateway Job: L7_SESSION_RELEVANCE_RANKING_V1\r\n";
   text += "Ranking Runtime: FALSE\r\n";
   text += "Selection Runtime: FALSE\r\n";
   text += "Trade Permission: FALSE\r\n";
   return text;
}

string AC_Layer7DossierSection(const string symbol)
{
   string l5_gate_status = "not_available";
   int l5_index = AC_L5FindIndex(symbol);
   if(l5_index >= 0)
   {
      l5_gate_status = AC_L5_SYMBOLS[l5_index].gate_pass ? "pass" : "not_pass";
   }

   string text = "";
   text += "\r\nLAYER 7 - SESSION RELEVANCE RANKING\r\n";
   text += "----------------------------------------\r\n";
   text += "Status: Pending ranked sidecar\r\n";
   text += "Owner: Runtime 4 - Surface Scoring Owner\r\n";
   text += "Gateway Result Accepted: FALSE\r\n";
   text += "Validation: Pending\r\n";
   text += "L5 Gate Status: " + l5_gate_status + "\r\n";
   text += "Rank State: ranked_sidecar_not_built\r\n";
   text += "Session Score: pending\r\n";
   text += "Session Bucket: pending\r\n";
   text += "Score Quality: pending\r\n";
   text += "Current Session: pending\r\n";
   text += "Session Definition Source: pending\r\n";
   text += "Session Time Basis: pending\r\n";
   text += "UTC Basis: pending\r\n";
   text += "Boundary:\r\n";
   text += "Source Owner: Layer 5 pass set + Layer 2/3/4 packets later\r\n";
   text += "Scoring Owner: Runtime 4 - Surface Scoring Owner via Runtime 3 Gateway support later\r\n";
   text += "Layer 7 Blocks Symbols: FALSE\r\n";
   text += "Selection Runtime: FALSE\r\n";
   text += "Trade Permission: FALSE\r\n";
   text += "Execution: FALSE\r\n";
   return text;
}

string AC_Layer7WorkbenchSection()
{
   string current_l5_pass = "not_available";
#ifdef AC_L5_GATE_PASS
   current_l5_pass = IntegerToString(AC_L5_GATE_PASS);
#endif

   string text = "";
   text += "\r\nL7_SESSION_RELEVANCE_RANKING\r\n";
   text += "----------------------------------------\r\n";
   text += "owner_name=Runtime 4 - Surface Scoring Owner\r\n";
   text += "layer_name=Layer 7 - Session Relevance Ranking\r\n";
   text += "status=Pending ranked sidecar\r\n";
   text += "trust_state=Ranking Pending\r\n";
   text += "validation_status=Pending\r\n";
   text += "gateway_required=true\r\n";
   text += "gateway_result_accepted=false\r\n";
   text += "job_type=L7_SESSION_RELEVANCE_RANKING_V1\r\n";
   text += "current_l5_pass_symbols=" + current_l5_pass + "\r\n";
   text += "l7_export_l5_pass_symbols=0\r\n";
   text += "manifest_input_count=0\r\n";
   text += "ranked_symbols=0\r\n";
   text += "generation_counts_ok=false\r\n";
   text += "generation_identity_ok=false\r\n";
   text += "live_l5_drift=false\r\n";
   text += "live_l5_drift_delta=0\r\n";
   text += "current_global_session=pending\r\n";
   text += "session_time_basis=pending\r\n";
   text += "utc_basis=pending\r\n";
   text += "ranking_runtime=false\r\n";
   text += "selection_runtime=false\r\n";
   text += "trade_permission=false\r\n";
   return text;
}

#endif
