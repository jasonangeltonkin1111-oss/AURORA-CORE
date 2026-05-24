#ifndef AC_RENDER_INDEX_OPTIMIZED_DOSSIER_SECTIONS_MQH
#define AC_RENDER_INDEX_OPTIMIZED_DOSSIER_SECTIONS_MQH

// RenderIndex v1 Dossier wrappers.
// These wrappers are included after the original L6/L7/L8/L9 renderer functions and before
// AC_Layer0DossierPublication.mqh. They let Dossier publication use compact worker indexes
// when accepted, while preserving the original renderers as fallback.
// No scoring, selection, permission, execution, route ownership, or FileIO ownership is added.

static long AC_RI_L6_DOSSIER_REFRESH_HEARTBEAT_ID = -1;
static long AC_RI_L7_DOSSIER_REFRESH_HEARTBEAT_ID = -1;
static long AC_RI_L8_DOSSIER_REFRESH_HEARTBEAT_ID = -1;
static long AC_RI_L9_DOSSIER_REFRESH_HEARTBEAT_ID = -1;

void AC_RIEnsureL6DossierRefresh()
{
   if(AC_RI_L6_DOSSIER_REFRESH_HEARTBEAT_ID == AC_HEARTBEAT_ID) return;
   AC_RI_L6_DOSSIER_REFRESH_HEARTBEAT_ID = AC_HEARTBEAT_ID;
   AC_RefreshLayer6RankedSidecar();
}

void AC_RIEnsureL7DossierRefresh()
{
   if(AC_RI_L7_DOSSIER_REFRESH_HEARTBEAT_ID == AC_HEARTBEAT_ID) return;
   AC_RI_L7_DOSSIER_REFRESH_HEARTBEAT_ID = AC_HEARTBEAT_ID;
   AC_L7RefreshRankedSidecar();
}

void AC_RIEnsureL8DossierRefresh()
{
   if(AC_RI_L8_DOSSIER_REFRESH_HEARTBEAT_ID == AC_HEARTBEAT_ID) return;
   AC_RI_L8_DOSSIER_REFRESH_HEARTBEAT_ID = AC_HEARTBEAT_ID;
   AC_L8RefreshRankedSidecar();
}

void AC_RIEnsureL9DossierRefresh()
{
   if(AC_RI_L9_DOSSIER_REFRESH_HEARTBEAT_ID == AC_HEARTBEAT_ID) return;
   AC_RI_L9_DOSSIER_REFRESH_HEARTBEAT_ID = AC_HEARTBEAT_ID;
   AC_L9RefreshRankedSidecar();
}

string AC_RILayerBlockedSection(const string layer_title, const string owner, const string l5_status, const string l5_reason, const string score_label, const string bucket_label, const string boundary_source_owner, const string policy_line)
{
   string text = "\r\n" + layer_title + "\r\n";
   text += "----------------------------------------\r\n";
   text += "Status: not_ranked_l5_gate_failed\r\n";
   text += "Owner: " + owner + "\r\n";
   text += "Gateway Result Accepted: FALSE\r\n";
   text += "Validation: blocked_by_current_layer5_gate\r\n";
   text += "L5 Gate Status: " + l5_status + "\r\n";
   text += "L5 Gate Reason: " + l5_reason + "\r\n";
   text += "Rank State: not_ranked_l5_gate_failed\r\n";
   text += score_label + ": not_available\r\n";
   text += bucket_label + ": not_available\r\n";
   text += "Rank Source: skipped_current_l5_gate_not_pass\r\n";
   text += policy_line + "\r\n";
   text += "Boundary:\r\n";
   text += "Source Owner: " + boundary_source_owner + "\r\n";
   text += "Scoring Owner: Runtime 4 - Surface Scoring Owner via Runtime 3 Gateway support\r\n";
   text += "Layer Blocks Symbols: FALSE\r\n";
   text += "Selection Runtime: FALSE\r\n";
   text += "Trade Permission: FALSE\r\n";
   text += "Execution: FALSE\r\n";
   return text;
}

string AC_Layer6DossierSection_RenderIndex(const string symbol)
{
   int l5_index = AC_L5FindIndex(symbol);
   string l5_status = "not_available";
   string l5_reason = "symbol not found in Layer 5 gate packet";
   if(l5_index >= 0)
   {
      l5_status = AC_L5_SYMBOLS[l5_index].gate_status;
      l5_reason = AC_L5_SYMBOLS[l5_index].gate_reason;
   }
   if(l5_status != "pass")
      return AC_RILayerBlockedSection("LAYER 6 - COST / FRICTION RANKING", AC_RUNTIME4_OWNER, l5_status, l5_reason, "Friction Score", "Friction Bucket", "Layer 5 pass set + Layer 3/4 packets + MT5 cost primitives", "Cost Policy: ranking only; no selection, permission, or execution");

   AC_RIEnsureL6DossierRefresh();
   AC_RenderIndexRow row;
   bool index_hit = (AC_L6_RANKED_ACCEPTED && AC_RenderIndexLookup(6, symbol, row));
   if(!index_hit)
      return AC_Layer6DossierSection(symbol);

   string text = "\r\nLAYER 6 - COST / FRICTION RANKING\r\n";
   text += "----------------------------------------\r\n";
   text += "Status: " + AC_L6_STATUS + "\r\n";
   text += "Owner: " + AC_RUNTIME4_OWNER + "\r\n";
   text += "Gateway Result Accepted: " + (AC_L6_RANKED_ACCEPTED ? "TRUE" : "FALSE") + "\r\n";
   text += "Validation: " + AC_L6_VALIDATION_STATUS + "\r\n";
   text += "L6 Snapshot Drift: " + (AC_L6_LIVE_L5_DRIFT ? "TRUE" : "FALSE") + "\r\n";
   text += "Current L5 Pass Symbols: " + IntegerToString(AC_L6_INPUT_L5_PASS_SYMBOLS) + "\r\n";
   text += "L6 Export L5 Pass Symbols: " + IntegerToString(AC_L6_SOURCE_L5_GATE_PASS) + "\r\n";
   text += "SymbolRank Filename Mode: " + AC_L6_MANIFEST_SYMBOL_RANK_FILENAME_MODE + "\r\n";
   text += "Expected SymbolRank File: " + AC_L6SymbolRankFilename(symbol) + "\r\n";
   text += "L5 Gate Status: " + l5_status + "\r\n";
   text += "L5 Gate Reason: " + l5_reason + "\r\n";
   text += "Rank Evidence: accepted_current_epoch_render_index_v1\r\n";
   text += "Rank State: " + row.rank_state + "\r\n";
   text += "Rank Index: " + row.rank_index + " / " + IntegerToString(AC_L6_RANKED_SYMBOLS) + "\r\n";
   text += "Friction Score: " + row.score + "\r\n";
   text += "Friction Bucket: " + row.bucket + "\r\n";
   text += "Score Quality: " + row.score_quality + "\r\n";
   text += "Rank Source: render_index_v1\r\n";
   text += "Rank Path: " + row.rank_path + "\r\n";
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

string AC_Layer7DossierSection_RenderIndex(const string symbol)
{
   int l5_index = AC_L5FindIndex(symbol);
   string l5_gate_status = "not_available";
   if(l5_index >= 0)
      l5_gate_status = AC_L5_SYMBOLS[l5_index].pass ? "pass" : "not_pass";
   if(l5_gate_status != "pass")
      return AC_RILayerBlockedSection("LAYER 7 - SESSION RELEVANCE RANKING", "Runtime 4 - Surface Scoring Owner", l5_gate_status, "current Layer 5 gate is not pass", "Session Score", "Session Bucket", "Layer 5 pass set + Layer 2/3/4 packets", "Session Policy: off-session caution only; not a trade-time recommendation");

   AC_RIEnsureL7DossierRefresh();
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
   int l5_index = AC_L5FindIndex(symbol);
   string l5_gate_status = "not_available";
   if(l5_index >= 0)
      l5_gate_status = AC_L5_SYMBOLS[l5_index].pass ? "pass" : "not_pass";
   if(l5_gate_status != "pass")
      return AC_RILayerBlockedSection("LAYER 8 - MOVEMENT / RANGE RANKING", "Runtime 4 - Surface Scoring Owner", l5_gate_status, "current Layer 5 gate is not pass", "Movement Score", "Movement Bucket", "Runtime 1 Shared OHLC Priority Windows + Layer 5 pass set", "Movement Policy: ranking only; no direction, entry, selection, permission, or execution");

   AC_RIEnsureL8DossierRefresh();
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
   int l5_index = AC_L5FindIndex(symbol);
   string l5_gate_status = "not_available";
   if(l5_index >= 0)
      l5_gate_status = AC_L5_SYMBOLS[l5_index].pass ? "pass" : "not_pass";
   if(l5_gate_status != "pass")
      return AC_RILayerBlockedSection("LAYER 9 - STRUCTURE / LOCATION GEOMETRY", "Runtime 4 - Surface Scoring Owner", l5_gate_status, "current Layer 5 gate is not pass", "Structure Watchlist Score", "Structure Bucket", "Runtime 1 Shared OHLC Priority Windows + Layer 5 pass set", "Structure Policy: watchlist only; no direction, entry, selection, permission, or execution");

   AC_RIEnsureL9DossierRefresh();
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

#define AC_Layer6DossierSection AC_Layer6DossierSection_RenderIndex
#define AC_Layer7DossierSection AC_Layer7DossierSection_RenderIndex
#define AC_Layer8DossierSection AC_Layer8DossierSection_RenderIndex
#define AC_Layer9DossierSection AC_Layer9DossierSection_RenderIndex

#endif