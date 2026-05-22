#ifndef AC_BASIC_SYSTEM_GATE_MQH
#define AC_BASIC_SYSTEM_GATE_MQH

// Runtime 1 / Foundation Truth Owner dispatcher for Layer 5.
// Layer 5 owns only the Basic System Gate: the first all-symbol hard eligibility gate.
// It consumes L2 market state, L3 broker/spec/value/classification packets, and L4 quote/spread packets.
// It must not calculate friction/ranking, session scoring, movement, structure, selection, strategy, permission, execution, FileIO, routes, or Gateway transport.

static bool   AC_L5_READY = false;
static string AC_L5_STATUS = "Not started";
static string AC_L5_TRUST_STATE = "Gate Not Ready";
static string AC_L5_MAIN_BLOCKER = "Layer 5 basic gate has not run yet";
static string AC_L5_BOARD_SECTION = "";
static string AC_L5_WORKBENCH_SECTION = "";
static uint   AC_L5_SCAN_STARTED_MS = 0;
static uint   AC_L5_SCAN_DURATION_MS = 0;
static string AC_L5_LAST_UPSTREAM_KEY = "not_scanned";

static int AC_L5_SCANNED = 0;
static int AC_L5_GATE_PASS = 0;
static int AC_L5_GATE_BLOCKED = 0;
static int AC_L5_BLOCK_CLOSED_MARKET = 0;
static int AC_L5_BLOCK_STALE_QUOTE = 0;
static int AC_L5_BLOCK_MISSING_TICK = 0;
static int AC_L5_BLOCK_INVALID_BIDASK = 0;
static int AC_L5_BLOCK_MISSING_SPECS = 0;
static int AC_L5_BLOCK_TRADE_MODE = 0;
static int AC_L5_BLOCK_ABSURD_SPREAD = 0;
static int AC_L5_BLOCK_CLASSIFICATION_REVIEW = 0;
static int AC_L5_BLOCK_L2_NOT_READY = 0;
static int AC_L5_BLOCK_L3_NOT_READY = 0;
static int AC_L5_BLOCK_L4_NOT_READY = 0;

// Compatibility fields retained until AuroraCore diagnostics is fully renamed away from the retired advisory packet wording.
// They are mapped to Basic System Gate state, not to a deep advisory/calculation packet.
static int AC_L5_ELIGIBLE_OPEN = 0;
static int AC_L5_READY_SYMBOLS = 0;
static int AC_L5_PENDING_SYMBOLS = 0;
static string AC_L5_PACKET_SCHEMA_VERSION = "l5_basic_system_gate_v1";
static string AC_L5_PACKET_STATUS = "basic_gate_not_started";
static string AC_L5_PACKET_SOURCE = "l2_l3_l4_owner_packets";
static string AC_L5_PACKET_BINDING_STATUS = "not_a_gateway_packet_basic_gate_only";
static string AC_L5_PACKET_REASON = "Layer 5 is Basic System Gate; scoring/advisory packets start at Layer 6+";
static string AC_L5_PACKET_OWNER_BOUNDARY = "basic_system_gate_only_no_gateway_no_calculation_no_ranking_no_selection_no_permission";
static string AC_L5_FRICTION_ADVISORY = "not_layer5_belongs_to_layer6";
static string AC_L5_VOLATILITY_ADVISORY = "not_layer5_belongs_to_later_scoring_layers";
static string AC_L5_STRUCTURE_ADVISORY = "not_layer5_belongs_to_later_scoring_layers";
static string AC_L5_SESSION_ADVISORY = "not_layer5_belongs_to_later_scoring_layers";
static string AC_L5_RISK_ADVISORY = "not_layer5_permission_or_risk_owner";
static string AC_L5_KILL_REASON = "basic_gate_not_run";
static string AC_L5_QUALITY_STATE = "basic_gate_not_started";

static string AC_L5_GATE_POLICY = "closed_market_or_stale_quote_or_invalid_bidask_or_missing_specs_or_disabled_trade_mode_or_absurd_spread_or_unresolved_classification_review_blocks";
static string AC_L5_WORST_BLOCKER = "None";
static double AC_L5_ABSURD_SPREAD_BPS_LIMIT = 250.0;

struct AC_L5GatePacket
{
   string symbol;
   string gate_status;
   string gate_reason;
   string l2_gate;
   string l3_gate;
   string l4_gate;
   bool pass;
   bool blocked_closed_market;
   bool blocked_stale_quote;
   bool blocked_missing_tick;
   bool blocked_invalid_bidask;
   bool blocked_missing_specs;
   bool blocked_trade_mode;
   bool blocked_absurd_spread;
   bool blocked_classification_review;
   bool trade_permission;
};

static AC_L5GatePacket AC_L5_SYMBOLS[];

string AC_L5BoolText(const bool value)
{
   return value ? "TRUE" : "FALSE";
}

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
   AC_L5_WORST_BLOCKER = "None";
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

bool AC_L5SpreadAbsurd(const AC_L4SymbolPacket &l4)
{
   if(l4.spread_bps_live <= 0.0) return false;
   return l4.spread_bps_live > AC_L5_ABSURD_SPREAD_BPS_LIMIT;
}

AC_L5GatePacket AC_L5EvaluateSymbol(const string symbol)
{
   AC_L5GatePacket p;
   p.symbol = symbol;
   p.gate_status = "blocked";
   p.gate_reason = "";
   p.l2_gate = "not_ready";
   p.l3_gate = "not_ready";
   p.l4_gate = "not_ready";
   p.pass = false;
   p.blocked_closed_market = false;
   p.blocked_stale_quote = false;
   p.blocked_missing_tick = false;
   p.blocked_invalid_bidask = false;
   p.blocked_missing_specs = false;
   p.blocked_trade_mode = false;
   p.blocked_absurd_spread = false;
   p.blocked_classification_review = false;
   p.trade_permission = false;

   if(!AC_L2_READY)
   {
      AC_L5AppendReason(p.gate_reason, "l2_not_ready");
      AC_L5_BLOCK_L2_NOT_READY++;
      return p;
   }

   string market_state = AC_L2MarketStateForSymbol(symbol);
   p.l2_gate = market_state;
   if(market_state != "open")
   {
      p.blocked_closed_market = true;
      AC_L5AppendReason(p.gate_reason, "market_not_open");
      AC_L5_BLOCK_CLOSED_MARKET++;
      return p;
   }

   if(!AC_L3_READY)
   {
      AC_L5AppendReason(p.gate_reason, "l3_not_ready");
      AC_L5_BLOCK_L3_NOT_READY++;
      return p;
   }
   int l3_index = AC_L3FindIndex(symbol);
   if(l3_index < 0)
   {
      p.blocked_missing_specs = true;
      AC_L5AppendReason(p.gate_reason, "l3_specs_missing");
      AC_L5_BLOCK_MISSING_SPECS++;
      return p;
   }
   AC_L3SymbolSpecs l3 = AC_L3_SYMBOLS[l3_index];
   p.l3_gate = l3.source_quality;

   if(!AC_L5SpecsEssentialReady(l3))
   {
      p.blocked_missing_specs = true;
      AC_L5AppendReason(p.gate_reason, "essential_specs_missing");
      AC_L5_BLOCK_MISSING_SPECS++;
   }
   if(!AC_L5TradeModeAllowed(l3.trade_mode))
   {
      p.blocked_trade_mode = true;
      AC_L5AppendReason(p.gate_reason, "trade_mode_disabled");
      AC_L5_BLOCK_TRADE_MODE++;
   }
   if(AC_L5ClassificationRequiresReview(l3))
   {
      p.blocked_classification_review = true;
      AC_L5AppendReason(p.gate_reason, "classification_review_required");
      AC_L5_BLOCK_CLASSIFICATION_REVIEW++;
   }

   if(!AC_L4_READY)
   {
      AC_L5AppendReason(p.gate_reason, "l4_not_ready");
      AC_L5_BLOCK_L4_NOT_READY++;
      return p;
   }
   int l4_index = AC_L4FindIndex(symbol);
   if(l4_index < 0)
   {
      p.blocked_missing_tick = true;
      AC_L5AppendReason(p.gate_reason, "l4_quote_packet_missing");
      AC_L5_BLOCK_MISSING_TICK++;
      return p;
   }
   AC_L4SymbolPacket l4 = AC_L4_SYMBOLS[l4_index];
   p.l4_gate = l4.quote_quality;

   if(!l4.tick_available)
   {
      p.blocked_missing_tick = true;
      AC_L5AppendReason(p.gate_reason, "tick_missing");
      AC_L5_BLOCK_MISSING_TICK++;
   }
   if(l4.quote_quality == "stale" || l4.quote_quality == "missing" || l4.tick_age_seconds > 60.0)
   {
      p.blocked_stale_quote = true;
      AC_L5AppendReason(p.gate_reason, "quote_stale_or_missing");
      AC_L5_BLOCK_STALE_QUOTE++;
   }
   if(!l4.bid_ask_valid)
   {
      p.blocked_invalid_bidask = true;
      AC_L5AppendReason(p.gate_reason, "invalid_bid_ask");
      AC_L5_BLOCK_INVALID_BIDASK++;
   }
   if(AC_L5SpreadAbsurd(l4))
   {
      p.blocked_absurd_spread = true;
      AC_L5AppendReason(p.gate_reason, "absurd_spread_bps");
      AC_L5_BLOCK_ABSURD_SPREAD++;
   }

   p.pass = (p.gate_reason == "");
   p.gate_status = p.pass ? "pass" : "blocked";
   if(p.pass)
   {
      p.gate_reason = "eligible_basic_system_gate";
      AC_L5_GATE_PASS++;
   }
   else
   {
      AC_L5_GATE_BLOCKED++;
      AC_L5TrackWorstBlocker(p.gate_reason);
   }
   return p;
}

void AC_RefreshLayer5BasicSystemGate()
{
   string upstream_key = AC_L5UpstreamKey();
   AC_L5Reset();
   AC_L5_LAST_UPSTREAM_KEY = upstream_key;

   int total = SymbolsTotal(false);
   ArrayResize(AC_L5_SYMBOLS, 0);

   for(int i = 0; i < total; i++)
   {
      string symbol = SymbolName(i, false);
      if(symbol == "") continue;
      AC_L5GatePacket p = AC_L5EvaluateSymbol(symbol);
      int n = ArraySize(AC_L5_SYMBOLS);
      ArrayResize(AC_L5_SYMBOLS, n + 1);
      AC_L5_SYMBOLS[n] = p;
      AC_L5_SCANNED++;
      if(!p.pass && AC_L5_WORST_BLOCKER == "None") AC_L5_WORST_BLOCKER = p.gate_reason;
   }

   AC_L5_SCAN_DURATION_MS = GetTickCount() - AC_L5_SCAN_STARTED_MS;
   AC_L5_STATUS = "Complete";
   AC_L5_TRUST_STATE = "Gate Ready";
   AC_L5_MAIN_BLOCKER = (AC_L5_GATE_BLOCKED > 0 ? AC_L5_WORST_BLOCKER : "None");
   AC_L5_READY = true;
   AC_L5SyncCompatibilityFields();
   AC_BuildLayer5Texts();
}

int AC_L5FindIndex(const string symbol)
{
   for(int i = 0; i < ArraySize(AC_L5_SYMBOLS); i++)
      if(AC_L5_SYMBOLS[i].symbol == symbol) return i;
   return -1;
}

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
   AC_L5_BOARD_SECTION += "Stale Quote:                " + IntegerToString(AC_L5_BLOCK_STALE_QUOTE) + "\r\n";
   AC_L5_BOARD_SECTION += "Missing Tick:               " + IntegerToString(AC_L5_BLOCK_MISSING_TICK) + "\r\n";
   AC_L5_BOARD_SECTION += "Invalid Bid/Ask:            " + IntegerToString(AC_L5_BLOCK_INVALID_BIDASK) + "\r\n";
   AC_L5_BOARD_SECTION += "Missing Specs:              " + IntegerToString(AC_L5_BLOCK_MISSING_SPECS) + "\r\n";
   AC_L5_BOARD_SECTION += "Trade Mode Blocked:         " + IntegerToString(AC_L5_BLOCK_TRADE_MODE) + "\r\n";
   AC_L5_BOARD_SECTION += "Absurd Spread:              " + IntegerToString(AC_L5_BLOCK_ABSURD_SPREAD) + "\r\n";
   AC_L5_BOARD_SECTION += "Classification Review:      " + IntegerToString(AC_L5_BLOCK_CLASSIFICATION_REVIEW) + "\r\n";
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
   AC_L5_WORKBENCH_SECTION += "absurd_spread_bps_limit=" + DoubleToString(AC_L5_ABSURD_SPREAD_BPS_LIMIT, 2) + "\r\n";
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
      text += "Blocked Stale Quote: " + AC_L5BoolText(p.blocked_stale_quote) + "\r\n";
      text += "Blocked Missing Tick: " + AC_L5BoolText(p.blocked_missing_tick) + "\r\n";
      text += "Blocked Invalid Bid/Ask: " + AC_L5BoolText(p.blocked_invalid_bidask) + "\r\n";
      text += "Blocked Missing Specs: " + AC_L5BoolText(p.blocked_missing_specs) + "\r\n";
      text += "Blocked Trade Mode: " + AC_L5BoolText(p.blocked_trade_mode) + "\r\n";
      text += "Blocked Absurd Spread: " + AC_L5BoolText(p.blocked_absurd_spread) + "\r\n";
      text += "Blocked Classification Review: " + AC_L5BoolText(p.blocked_classification_review) + "\r\n";
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
   return "schema_name=layer_status|schema_version=v5_basic_gate_2|layer_id=5|layer_name=" + AC_LAYER_5_NAME
      + "|source_owner=" + AC_RUNTIME1_OWNER
      + "|build_version=" + AC_BUILD_VERSION
      + "|upgrade_id=" + AC_UPGRADE_ID
      + "|layer_status=" + AC_L5_STATUS
      + "|trust_state=" + AC_L5_TRUST_STATE
      + "|gate_policy=" + AC_L5_GATE_POLICY
      + "|last_upstream_key=" + AC_L5_LAST_UPSTREAM_KEY
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
      + "|main_blocker=" + AC_L5_MAIN_BLOCKER
      + "|calculation_owner=none_basic_gate_only|gateway_required=false|ranking_runtime=false|selection_runtime=false|permission=false";
}

#endif
