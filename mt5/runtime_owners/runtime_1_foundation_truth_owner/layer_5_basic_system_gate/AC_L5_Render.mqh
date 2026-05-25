#ifndef AC_L5_RENDER_MQH
#define AC_L5_RENDER_MQH
void AC_BuildLayer5Texts()
{
   if(AC_L5ShouldRefresh())
   {
      AC_RefreshLayer5BasicSystemGate();
      return;
   }
   AC_L5SyncCompatibilityFields();

   AC_L5_BOARD_SECTION = "\r\nLAYER 5 - BASIC SYSTEM GATE\r\n";
   AC_L5_BOARD_SECTION += "----------------------------------------\r\n";
   AC_L5_BOARD_SECTION += "Status:                     " + AC_L5_STATUS + "\r\n";
   AC_L5_BOARD_SECTION += "Trust:                      " + AC_L5_TRUST_STATE + "\r\n";
   AC_L5_BOARD_SECTION += "Scanned Symbols:            " + IntegerToString(AC_L5_SCANNED) + "\r\n";
   AC_L5_BOARD_SECTION += "Gate Pass:                  " + IntegerToString(AC_L5_GATE_PASS) + "\r\n";
   AC_L5_BOARD_SECTION += "Gate Blocked:               " + IntegerToString(AC_L5_GATE_BLOCKED) + "\r\n";
   AC_L5_BOARD_SECTION += "Closed / Not Open:          " + IntegerToString(AC_L5_BLOCK_CLOSED_MARKET) + "\r\n";
   AC_L5_BOARD_SECTION += "Stale / Non-Fresh Quote:    " + IntegerToString(AC_L5_BLOCK_STALE_QUOTE) + "\r\n";
   AC_L5_BOARD_SECTION += "Missing Tick:               " + IntegerToString(AC_L5_BLOCK_MISSING_TICK) + "\r\n";
   AC_L5_BOARD_SECTION += "Invalid Bid/Ask:            " + IntegerToString(AC_L5_BLOCK_INVALID_BIDASK) + "\r\n";
   AC_L5_BOARD_SECTION += "Missing Specs:              " + IntegerToString(AC_L5_BLOCK_MISSING_SPECS) + "\r\n";
   AC_L5_BOARD_SECTION += "Trade Mode Blocked:         " + IntegerToString(AC_L5_BLOCK_TRADE_MODE) + "\r\n";
   AC_L5_BOARD_SECTION += "Absurd Spread:              " + IntegerToString(AC_L5_BLOCK_ABSURD_SPREAD) + "\r\n";
   AC_L5_BOARD_SECTION += "Classification Review:      " + IntegerToString(AC_L5_BLOCK_CLASSIFICATION_REVIEW) + "\r\n";
   AC_L5_BOARD_SECTION += "L4 Surface Not Usable:      " + IntegerToString(AC_L5_BLOCK_L4_SURFACE_NOT_USABLE) + "\r\n";
   AC_L5_BOARD_SECTION += "Max Fresh Tick Age:         " + DoubleToString(AC_L5_MAX_FRESH_TICK_AGE_SECONDS, 1) + " sec\r\n";
   AC_L5_BOARD_SECTION += "Worst Blocker:              " + AC_L5_MAIN_BLOCKER + "\r\n";
   AC_L5_BOARD_SECTION += "Scan Duration:              " + IntegerToString((int)AC_L5_SCAN_DURATION_MS) + " ms\r\n";
   AC_L5_BOARD_SECTION += "Ranking Runtime:            FALSE\r\n";
   AC_L5_BOARD_SECTION += "Selection Runtime:          FALSE\r\n";
   AC_L5_BOARD_SECTION += "Trade Permission:           FALSE\r\n";

   AC_L5_WORKBENCH_SECTION = "\r\nL5_BASIC_SYSTEM_GATE\r\n";
   AC_L5_WORKBENCH_SECTION += "----------------------------------------\r\n";
   AC_L5_WORKBENCH_SECTION += "owner_name=" + AC_RUNTIME1_OWNER + "\r\n";
   AC_L5_WORKBENCH_SECTION += "layer_name=" + AC_LAYER_5_NAME + "\r\n";
   AC_L5_WORKBENCH_SECTION += "status=" + AC_L5_STATUS + "\r\n";
   AC_L5_WORKBENCH_SECTION += "trust_state=" + AC_L5_TRUST_STATE + "\r\n";
   AC_L5_WORKBENCH_SECTION += "gate_policy=" + AC_L5_GATE_POLICY + "\r\n";
   AC_L5_WORKBENCH_SECTION += "source_truth_owner=L2_L3_L4_existing_owner_packets_only\r\n";
   AC_L5_WORKBENCH_SECTION += "calculation_owner=none_basic_gate_only\r\n";
   AC_L5_WORKBENCH_SECTION += "gateway_required=false\r\n";
   AC_L5_WORKBENCH_SECTION += "last_upstream_key=" + AC_L5_LAST_UPSTREAM_KEY + "\r\n";
   AC_L5_WORKBENCH_SECTION += "current_upstream_key=" + AC_L5UpstreamKey() + "\r\n";
   AC_L5_WORKBENCH_SECTION += "find_cache_last_index=" + IntegerToString(AC_L5_FIND_LAST_INDEX) + "\r\n";
   AC_L5_WORKBENCH_SECTION += "find_cache_hits=" + IntegerToString(AC_L5_FIND_CACHE_HITS) + "\r\n";
   AC_L5_WORKBENCH_SECTION += "find_full_scan_count=" + IntegerToString(AC_L5_FIND_FULL_SCAN_COUNT) + "\r\n";
   AC_L5_WORKBENCH_SECTION += "scanned_symbols=" + IntegerToString(AC_L5_SCANNED) + "\r\n";
   AC_L5_WORKBENCH_SECTION += "gate_pass=" + IntegerToString(AC_L5_GATE_PASS) + "\r\n";
   AC_L5_WORKBENCH_SECTION += "gate_blocked=" + IntegerToString(AC_L5_GATE_BLOCKED) + "\r\n";
   AC_L5_WORKBENCH_SECTION += "blocked_closed_market=" + IntegerToString(AC_L5_BLOCK_CLOSED_MARKET) + "\r\n";
   AC_L5_WORKBENCH_SECTION += "blocked_stale_quote=" + IntegerToString(AC_L5_BLOCK_STALE_QUOTE) + "\r\n";
   AC_L5_WORKBENCH_SECTION += "blocked_missing_tick=" + IntegerToString(AC_L5_BLOCK_MISSING_TICK) + "\r\n";
   AC_L5_WORKBENCH_SECTION += "blocked_invalid_bidask=" + IntegerToString(AC_L5_BLOCK_INVALID_BIDASK) + "\r\n";
   AC_L5_WORKBENCH_SECTION += "blocked_missing_specs=" + IntegerToString(AC_L5_BLOCK_MISSING_SPECS) + "\r\n";
   AC_L5_WORKBENCH_SECTION += "blocked_trade_mode=" + IntegerToString(AC_L5_BLOCK_TRADE_MODE) + "\r\n";
   AC_L5_WORKBENCH_SECTION += "blocked_absurd_spread=" + IntegerToString(AC_L5_BLOCK_ABSURD_SPREAD) + "\r\n";
   AC_L5_WORKBENCH_SECTION += "blocked_classification_review=" + IntegerToString(AC_L5_BLOCK_CLASSIFICATION_REVIEW) + "\r\n";
   AC_L5_WORKBENCH_SECTION += "blocked_l2_not_ready=" + IntegerToString(AC_L5_BLOCK_L2_NOT_READY) + "\r\n";
   AC_L5_WORKBENCH_SECTION += "blocked_l3_not_ready=" + IntegerToString(AC_L5_BLOCK_L3_NOT_READY) + "\r\n";
   AC_L5_WORKBENCH_SECTION += "blocked_l4_not_ready=" + IntegerToString(AC_L5_BLOCK_L4_NOT_READY) + "\r\n";
   AC_L5_WORKBENCH_SECTION += "blocked_l4_surface_not_usable=" + IntegerToString(AC_L5_BLOCK_L4_SURFACE_NOT_USABLE) + "\r\n";
   AC_L5_WORKBENCH_SECTION += "absurd_spread_bps_limit=" + DoubleToString(AC_L5_ABSURD_SPREAD_BPS_LIMIT, 2) + "\r\n";
   AC_L5_WORKBENCH_SECTION += "max_fresh_tick_age_seconds=" + DoubleToString(AC_L5_MAX_FRESH_TICK_AGE_SECONDS, 1) + "\r\n";
   AC_L5_WORKBENCH_SECTION += "main_blocker=" + AC_L5_MAIN_BLOCKER + "\r\n";
   AC_L5_WORKBENCH_SECTION += "ranking_runtime=false\r\n";
   AC_L5_WORKBENCH_SECTION += "selection_runtime=false\r\n";
   AC_L5_WORKBENCH_SECTION += "trade_permission=false\r\n";
   AC_L5_WORKBENCH_SECTION += "refresh_duration_ms=" + IntegerToString((int)AC_L5_SCAN_DURATION_MS) + "\r\n";
}

string AC_Layer5BoardSection()
{
   if(AC_L5_BOARD_SECTION == "" || AC_L5ShouldRefresh()) AC_BuildLayer5Texts();
   return AC_L5_BOARD_SECTION;
}

string AC_Layer5WorkbenchSection()
{
   if(AC_L5_WORKBENCH_SECTION == "" || AC_L5ShouldRefresh()) AC_BuildLayer5Texts();
   return AC_L5_WORKBENCH_SECTION;
}

string AC_Layer5DossierSection(const string symbol)
{
   if(AC_L5ShouldRefresh()) AC_BuildLayer5Texts();
   int index = AC_L5FindIndex(symbol);
   string text = "\r\nLAYER 5 - BASIC SYSTEM GATE\r\n";
   text += "----------------------------------------\r\n";
   text += "Status: " + AC_L5_STATUS + "\r\n";
   text += "Trust: " + AC_L5_TRUST_STATE + "\r\n";
   text += "Gate Purpose: First all-symbol hard eligibility gate; blocks garbage symbols before scoring/ranking layers.\r\n";
   text += "Source Inputs: Layer 2 market state, Layer 3 specs/classification, Layer 4 quote/spread quality.\r\n";
   if(index < 0)
   {
      text += "Gate Status: not_available\r\n";
      text += "Gate Reason: symbol not found in Layer 5 gate pass\r\n";
   }
   else
   {
      AC_L5GatePacket p = AC_L5_SYMBOLS[index];
      text += "Gate Status: " + p.gate_status + "\r\n";
      text += "Gate Reason: " + p.gate_reason + "\r\n";
      text += "L2 Gate: " + p.l2_gate + "\r\n";
      text += "L3 Gate: " + p.l3_gate + "\r\n";
      text += "L4 Gate: " + p.l4_gate + "\r\n";
      text += "Blocked Closed / Not Open: " + AC_L5BoolText(p.blocked_closed_market) + "\r\n";
      text += "Blocked Stale / Non-Fresh Quote: " + AC_L5BoolText(p.blocked_stale_quote) + "\r\n";
      text += "Blocked Missing Tick: " + AC_L5BoolText(p.blocked_missing_tick) + "\r\n";
      text += "Blocked Invalid Bid/Ask: " + AC_L5BoolText(p.blocked_invalid_bidask) + "\r\n";
      text += "Blocked Missing Specs: " + AC_L5BoolText(p.blocked_missing_specs) + "\r\n";
      text += "Blocked Trade Mode: " + AC_L5BoolText(p.blocked_trade_mode) + "\r\n";
      text += "Blocked Absurd Spread: " + AC_L5BoolText(p.blocked_absurd_spread) + "\r\n";
      text += "Blocked Classification Review: " + AC_L5BoolText(p.blocked_classification_review) + "\r\n";
      text += "Blocked L4 Surface Not Usable: " + AC_L5BoolText(p.blocked_l4_surface_not_usable) + "\r\n";
   }
   text += "\r\nBoundary\r\n";
   text += "----------------------------------------\r\n";
   text += "Calculation Owner: none; basic gate only\r\n";
   text += "Gateway Required: FALSE\r\n";
   text += "Ranking Runtime: FALSE\r\n";
   text += "Selection Runtime: FALSE\r\n";
   text += "Trade Permission: FALSE\r\n";
   text += "Next Layer: Layer 6 Cost / Friction Ranking consumes L5 pass set only.\r\n";
   return text;
}

string AC_Layer5StatusRow()
{
   if(AC_L5ShouldRefresh()) AC_BuildLayer5Texts();
   AC_L5SyncCompatibilityFields();
   return "schema_name=layer_status|schema_version=v5_basic_gate_5|layer_id=5|layer_name=" + AC_LAYER_5_NAME
      + "|source_owner=" + AC_RUNTIME1_OWNER
      + "|build_version=" + AC_BUILD_VERSION
      + "|upgrade_id=" + AC_UPGRADE_ID
      + "|layer_status=" + AC_L5_STATUS
      + "|trust_state=" + AC_L5_TRUST_STATE
      + "|gate_policy=" + AC_L5_GATE_POLICY
      + "|last_upstream_key=" + AC_L5_LAST_UPSTREAM_KEY
      + "|find_cache_last_index=" + IntegerToString(AC_L5_FIND_LAST_INDEX)
      + "|find_cache_hits=" + IntegerToString(AC_L5_FIND_CACHE_HITS)
      + "|find_full_scan_count=" + IntegerToString(AC_L5_FIND_FULL_SCAN_COUNT)
      + "|scanned_symbols=" + IntegerToString(AC_L5_SCANNED)
      + "|gate_pass=" + IntegerToString(AC_L5_GATE_PASS)
      + "|gate_blocked=" + IntegerToString(AC_L5_GATE_BLOCKED)
      + "|blocked_closed_market=" + IntegerToString(AC_L5_BLOCK_CLOSED_MARKET)
      + "|blocked_stale_quote=" + IntegerToString(AC_L5_BLOCK_STALE_QUOTE)
      + "|blocked_missing_tick=" + IntegerToString(AC_L5_BLOCK_MISSING_TICK)
      + "|blocked_invalid_bidask=" + IntegerToString(AC_L5_BLOCK_INVALID_BIDASK)
      + "|blocked_missing_specs=" + IntegerToString(AC_L5_BLOCK_MISSING_SPECS)
      + "|blocked_trade_mode=" + IntegerToString(AC_L5_BLOCK_TRADE_MODE)
      + "|blocked_absurd_spread=" + IntegerToString(AC_L5_BLOCK_ABSURD_SPREAD)
      + "|blocked_classification_review=" + IntegerToString(AC_L5_BLOCK_CLASSIFICATION_REVIEW)
      + "|blocked_l4_surface_not_usable=" + IntegerToString(AC_L5_BLOCK_L4_SURFACE_NOT_USABLE)
      + "|max_fresh_tick_age_seconds=" + DoubleToString(AC_L5_MAX_FRESH_TICK_AGE_SECONDS, 1)
      + "|main_blocker=" + AC_L5_MAIN_BLOCKER
      + "|calculation_owner=none_basic_gate_only|gateway_required=false|ranking_runtime=false|selection_runtime=false|permission=false";
}

#endif
