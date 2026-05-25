#ifndef AC_L5_POLICY_MQH
#define AC_L5_POLICY_MQH
string AC_L5UpstreamKey()
{
   return "L2=" + (AC_L2_READY ? "ready" : "not_ready")
      + "|L2Route=" + AC_L2_ROUTE_GENERATION_KEY
      + "|L3=" + (AC_L3_READY ? "ready" : "not_ready")
      + "|L3Cache=" + AC_L3_CACHE_KEY
      + "|L4=" + (AC_L4_READY ? "ready" : "not_ready")
      + "|L4Cache=" + AC_L4_CACHE_KEY
      + "|L4Refresh=" + AC_L4_REFRESH_KEY;
}

bool AC_L5ShouldRefresh()
{
   if(!AC_L5_READY) return true;
   return AC_L5_LAST_UPSTREAM_KEY != AC_L5UpstreamKey();
}

string AC_L5LayerGateSummary()
{
   return "scanned=" + IntegerToString(AC_L5_SCANNED)
      + ";pass=" + IntegerToString(AC_L5_GATE_PASS)
      + ";blocked=" + IntegerToString(AC_L5_GATE_BLOCKED);
}

void AC_L5SyncCompatibilityFields()
{
   int normalized_blocked = AC_L5_SCANNED - AC_L5_GATE_PASS;
   if(normalized_blocked < 0) normalized_blocked = 0;
   AC_L5_GATE_BLOCKED = normalized_blocked;
   AC_L5_REFRESH_DURATION_MS = AC_L5_SCAN_DURATION_MS;
   AC_L5_ELIGIBLE_OPEN = AC_L5_SCANNED;
   AC_L5_READY_SYMBOLS = AC_L5_GATE_PASS;
   AC_L5_PENDING_SYMBOLS = AC_L5_GATE_BLOCKED;
   AC_L5_PACKET_STATUS = AC_L5_READY ? "basic_gate_complete" : "basic_gate_not_ready";
   AC_L5_PACKET_BINDING_STATUS = "not_a_gateway_packet_basic_gate_only";
   AC_L5_PACKET_REASON = "Layer 5 Basic System Gate completed from L2/L3/L4 owner packets; scoring/advisory fields belong to Layer 6+";
   AC_L5_KILL_REASON = AC_L5_MAIN_BLOCKER;
   AC_L5_QUALITY_STATE = AC_L5_READY ? "basic_gate_ready" : "basic_gate_not_ready";
}

void AC_L5Reset()
{
   AC_L5_READY = false;
   AC_L5_STATUS = "Scanning";
   AC_L5_TRUST_STATE = "Gate Not Ready";
   AC_L5_MAIN_BLOCKER = "Layer 5 basic gate scan in progress";
   AC_L5_SCAN_STARTED_MS = GetTickCount();
   AC_L5_SCAN_DURATION_MS = 0;
   AC_L5_REFRESH_DURATION_MS = 0;
   AC_L5_BOARD_SECTION = "";
   AC_L5_WORKBENCH_SECTION = "";
   AC_L5_SCANNED = 0;
   AC_L5_GATE_PASS = 0;
   AC_L5_GATE_BLOCKED = 0;
   AC_L5_BLOCK_CLOSED_MARKET = 0;
   AC_L5_BLOCK_STALE_QUOTE = 0;
   AC_L5_BLOCK_MISSING_TICK = 0;
   AC_L5_BLOCK_INVALID_BIDASK = 0;
   AC_L5_BLOCK_MISSING_SPECS = 0;
   AC_L5_BLOCK_TRADE_MODE = 0;
   AC_L5_BLOCK_ABSURD_SPREAD = 0;
   AC_L5_BLOCK_CLASSIFICATION_REVIEW = 0;
   AC_L5_BLOCK_L2_NOT_READY = 0;
   AC_L5_BLOCK_L3_NOT_READY = 0;
   AC_L5_BLOCK_L4_NOT_READY = 0;
   AC_L5_BLOCK_L4_SURFACE_NOT_USABLE = 0;
   AC_L5_WORST_BLOCKER = "None";
   AC_L5_FIND_LAST_INDEX = -1;
   AC_L5_FIND_CACHE_HITS = 0;
   AC_L5_FIND_FULL_SCAN_COUNT = 0;
   ArrayResize(AC_L5_SYMBOLS, 0);
   AC_L5SyncCompatibilityFields();
}

void AC_L5AppendReason(string &reason, const string next_reason)
{
   if(next_reason == "") return;
   if(reason == "") reason = next_reason;
   else reason += ";" + next_reason;
}

void AC_L5TrackWorstBlocker(const string reason)
{
   if(reason == "") return;
   if(AC_L5_WORST_BLOCKER == "None") AC_L5_WORST_BLOCKER = reason;
}

string AC_L5Lower(string value)
{
   StringToLower(value);
   return value;
}

bool AC_L5TradeModeAllowed(const long trade_mode)
{
   // SYMBOL_TRADE_MODE_DISABLED is 0 in MQL5. Avoid hard-coding other permission states here.
   return trade_mode != 0;
}

bool AC_L5SpecsEssentialReady(const AC_L3SymbolSpecs &l3)
{
   if(l3.required_fields_failed > 0) return false;
   if(l3.point <= 0.0) return false;
   if(l3.digits < 0) return false;
   if(l3.contract_size <= 0.0) return false;
   if(l3.volume_min <= 0.0 || l3.volume_step <= 0.0 || l3.volume_max <= 0.0) return false;
   return true;
}

bool AC_L5ClassificationRequiresReview(const AC_L3SymbolSpecs &l3)
{
   if(l3.classification_quality == "manual_review_required") return true;
   if(l3.classification_quality == "review_required") return true;
   if(l3.ranking_group == "" || l3.ranking_group == "unknown" || l3.ranking_group == "Unknown") return true;
   if(l3.asset_class == "" || l3.asset_class == "unknown" || l3.asset_class == "Unknown") return true;
   return false;
}

bool AC_L5QuoteFreshEnough(const AC_L4SymbolPacket &l4)
{
   string quote_quality = AC_L5Lower(l4.quote_quality);
   string zero_spread_state = AC_L5Lower(l4.zero_spread_state);

   if(!l4.tick_available) return false;
   if(quote_quality != "fresh") return false;
   if(l4.tick_age_seconds < 0.0) return false;
   if(l4.tick_age_seconds > AC_L5_MAX_FRESH_TICK_AGE_SECONDS) return false;
   if(zero_spread_state == "zero spread not fresh") return false;
   return true;
}

bool AC_L5SurfaceUsable(const AC_L4SymbolPacket &l4)
{
   string surface_quality = AC_L5Lower(l4.surface_quality);
   return surface_quality == "surface usable";
}

bool AC_L5SpreadAbsurd(const AC_L4SymbolPacket &l4)
{
   if(l4.spread_bps_live <= 0.0) return false;
   return l4.spread_bps_live > AC_L5_ABSURD_SPREAD_BPS_LIMIT;
}

#endif
