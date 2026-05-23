#ifndef AC_RENDER_INDEX_OPTIMIZED_DOSSIER_SECTIONS_MQH
#define AC_RENDER_INDEX_OPTIMIZED_DOSSIER_SECTIONS_MQH

// RenderIndex v1 Dossier wrappers.
// These wrappers are included after the original L7/L8/L9 renderer functions and before
// AC_Layer0DossierPublication.mqh. They let Dossier publication use compact worker indexes
// when accepted, while preserving the original renderers as fallback.
// No scoring, selection, permission, execution, route ownership, or FileIO ownership is added.

string AC_Layer7DossierSection_RenderIndex(const string symbol)
{
   AC_L7RefreshRankedSidecar();
   int l5_index = AC_L5FindIndex(symbol);
   string l5_gate_status = "not_available";
   if(l5_index >= 0)
      l5_gate_status = AC_L5_SYMBOLS[l5_index].pass ? "pass" : "not_pass";

   AC_RenderIndexRow row;
   bool index_hit = (AC_L7_RANKED_ACCEPTED && AC_RenderIndexLookup(7, symbol, row));
   if(!index_hit)
      return AC_Layer7DossierSection(symbol);

   string text = "";
   text += "\r\nLAYER 7 - SESSION RELEVANCE RANKING\r\n";
   text += "----------------------------------------\r\n";
   text += "Status: " + AC_L7_STATUS + "\r\n";
   text += "Summary: " + AC_L7_OPERATOR_SUMMARY + "\r\n";
   text += "Owner: Runtime 4 - Surface Scoring Owner\r\n";
   text += "Gateway Result Accepted: " + AC_L7BoolText(AC_L7_RANKED_ACCEPTED) + "\r\n";
   text += "Validation: " + AC_L7_VALIDATION_STATUS + "\r\n";
   text += "L5 Gate Status: " + l5_gate_status + "\r\n";
   text += "Generation Counts OK: " + AC_L7BoolText(AC_L7_GENERATION_COUNTS_OK_RENDERED) + "\r\n";
   text += "Generation Identity OK: " + AC_L7BoolText(AC_L7_GENERATION_IDENTITY_OK_RENDERED) + "\r\n";
   text += "Rank Evidence: accepted_current_epoch_render_index_v1\r\n";
   text += "Rank State: " + row.rank_state + "\r\n";
   text += "Rank Index: " + row.rank_index + " / " + IntegerToString(AC_L7_RANKED_ROWS_RENDERED) + "\r\n";
   text += "Session Score: " + row.score + "\r\n";
   text += "Session Bucket: " + row.bucket + "\r\n";
   text += "Score Quality: " + row.score_quality + "\r\n";
   text += "Rank Source: render_index_v1\r\n";
   text += "Rank Path: " + row.rank_path + "\r\n";
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

string AC_Layer8DossierSection_RenderIndex(const string symbol)
{
   AC_L8RefreshRankedSidecar();
   int l5_index = AC_L5FindIndex(symbol);
   string l5_gate_status = "not_available";
   if(l5_index >= 0)
      l5_gate_status = AC_L5_SYMBOLS[l5_index].pass ? "pass" : "not_pass";

   AC_RenderIndexRow row;
   AC_OhlcReadinessIndexRow ohlc;
   bool index_hit = (AC_L8_RANKED_ACCEPTED && AC_RenderIndexLookup(8, symbol, row));
   bool ohlc_hit = AC_RenderIndexLookupOhlc(symbol, ohlc);
   if(!index_hit || !ohlc_hit)
      return AC_Layer8DossierSection(symbol);

   int priority = AC_SharedOhlcPriorityForSymbol(symbol);
   string text = "";
   text += "\r\nLAYER 8 - MOVEMENT / RANGE RANKING\r\n";
   text += "----------------------------------------\r\n";
   text += "Status: " + AC_L8_STATUS + "\r\n";
   text += "Owner: Runtime 4 - Surface Scoring Owner\r\n";
   text += "Gateway Result Accepted: " + AC_L8BoolText(AC_L8_RANKED_ACCEPTED) + "\r\n";
   text += "Validation: " + AC_L8_VALIDATION_STATUS + "\r\n";
   text += "Symbol Priority: " + AC_SharedOhlcPriorityLabel(priority) + "\r\n";
   text += "L5 Gate Status: " + l5_gate_status + "\r\n";
   text += "OHLC L8 Minimum Ready: " + AC_L8BoolText(ohlc.l8_min_ready) + "\r\n";
   text += "M5 Window: " + (ohlc.m5_ready ? "available" : "pending") + "\r\n";
   text += "M15 Window: " + (ohlc.m15_ready ? "available" : "pending") + "\r\n";
   text += "H1 Window: " + (ohlc.h1_ready ? "available" : "pending") + "\r\n";
   text += "H4 Context Window: " + (ohlc.h4_ready ? "available" : "pending") + "\r\n";
   text += "Generation Counts OK: " + AC_L8BoolText(AC_L8_GENERATION_COUNTS_OK_RENDERED) + "\r\n";
   text += "Generation Identity OK: " + AC_L8BoolText(AC_L8_GENERATION_IDENTITY_OK_RENDERED) + "\r\n";
   text += "Rank Evidence: accepted_current_epoch_render_index_v1\r\n";
   text += "Rank State: " + row.rank_state + "\r\n";
   text += "Rank Index: " + row.rank_index + " / " + IntegerToString(AC_L8_RANKED_ROWS_RENDERED) + "\r\n";
   text += "Movement Score: " + row.score + "\r\n";
   text += "Movement Bucket: " + row.bucket + "\r\n";
   text += "Score Quality: " + row.score_quality + "\r\n";
   text += "Rank Source: render_index_v1\r\n";
   text += "Rank Path: " + row.rank_path + "\r\n";
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

string AC_Layer9DossierSection_RenderIndex(const string symbol)
{
   AC_L9RefreshRankedSidecar();
   int l5_index = AC_L5FindIndex(symbol);
   string l5_gate_status = "not_available";
   if(l5_index >= 0)
      l5_gate_status = AC_L5_SYMBOLS[l5_index].pass ? "pass" : "not_pass";

   AC_RenderIndexRow row;
   AC_OhlcReadinessIndexRow ohlc;
   bool index_hit = (AC_L9_RANKED_ACCEPTED && AC_RenderIndexLookup(9, symbol, row));
   bool ohlc_hit = AC_RenderIndexLookupOhlc(symbol, ohlc);
   if(!index_hit || !ohlc_hit)
      return AC_Layer9DossierSection(symbol);

   string text = "";
   text += "\r\nLAYER 9 - STRUCTURE / LOCATION GEOMETRY\r\n";
   text += "----------------------------------------\r\n";
   text += "Status: " + AC_L9_STATUS + "\r\n";
   text += "Owner: Runtime 4 - Surface Scoring Owner\r\n";
   text += "Gateway Result Accepted: " + AC_L9BoolText(AC_L9_RANKED_ACCEPTED) + "\r\n";
   text += "Validation: " + AC_L9_VALIDATION_STATUS + "\r\n";
   text += "L5 Gate Status: " + l5_gate_status + "\r\n";
   text += "OHLC Required Ready: " + AC_L9BoolText(ohlc.l9_required_ready) + "\r\n";
   text += "M15 Window: " + (ohlc.m15_ready ? "available" : "pending") + "\r\n";
   text += "H1 Window: " + (ohlc.h1_ready ? "available" : "pending") + "\r\n";
   text += "H4 Window: " + (ohlc.h4_ready ? "available" : "pending") + "\r\n";
   text += "D1 Window: " + (ohlc.d1_ready ? "available" : "pending") + "\r\n";
   text += "Rank Evidence: accepted_current_epoch_render_index_v1\r\n";
   text += "Rank State: " + row.rank_state + "\r\n";
   text += "Rank Index: " + row.rank_index + " / " + IntegerToString(AC_L9_RANKED_ROWS_RENDERED) + "\r\n";
   text += "Structure Watchlist Score: " + row.score + "\r\n";
   text += "Structure Bucket: " + row.bucket + "\r\n";
   text += "Score Quality: " + row.score_quality + "\r\n";
   text += "Rank Source: render_index_v1\r\n";
   text += "Rank Path: " + row.rank_path + "\r\n";
   text += "Structure Policy: watchlist only; no direction, entry, selection, permission, or execution\r\n";
   text += "Boundary:\r\n";
   text += "Source Owner: Runtime 1 Shared OHLC Priority Windows + Layer 5 pass set\r\n";
   text += "Scoring Owner: Runtime 4 - Surface Scoring Owner via Runtime 3 Gateway support\r\n";
   text += "Layer 9 Blocks Symbols: FALSE\r\n";
   text += "Selection Runtime: FALSE\r\n";
   text += "Trade Permission: FALSE\r\n";
   text += "Execution: FALSE\r\n";
   return text;
}

#define AC_Layer7DossierSection AC_Layer7DossierSection_RenderIndex
#define AC_Layer8DossierSection AC_Layer8DossierSection_RenderIndex
#define AC_Layer9DossierSection AC_Layer9DossierSection_RenderIndex

#endif