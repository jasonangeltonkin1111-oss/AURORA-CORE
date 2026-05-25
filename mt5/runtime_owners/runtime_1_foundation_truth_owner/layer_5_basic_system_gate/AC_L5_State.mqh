#ifndef AC_L5_STATE_MQH
#define AC_L5_STATE_MQH

static bool   AC_L5_READY = false;
static string AC_L5_STATUS = "Not started";
static string AC_L5_TRUST_STATE = "Gate Not Ready";
static string AC_L5_MAIN_BLOCKER = "Layer 5 basic gate has not run yet";
static string AC_L5_BOARD_SECTION = "";
static string AC_L5_WORKBENCH_SECTION = "";
static uint   AC_L5_SCAN_STARTED_MS = 0;
static uint   AC_L5_SCAN_DURATION_MS = 0;
static uint   AC_L5_REFRESH_DURATION_MS = 0;
static string AC_L5_LAST_UPSTREAM_KEY = "not_scanned";
static int    AC_L5_FIND_LAST_INDEX = -1;
static int    AC_L5_FIND_CACHE_HITS = 0;
static int    AC_L5_FIND_FULL_SCAN_COUNT = 0;

static int AC_L5_SCANNED = 0;
static int AC_L5_GATE_PASS = 0;
static int AC_L5_ELIGIBLE_CLEAN = 0;
static int AC_L5_ELIGIBLE_DEGRADED = 0;
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
static int AC_L5_BLOCK_L4_SURFACE_NOT_USABLE = 0;
static int AC_L5_DEGRADED_L3_VALUE_OR_MARGIN = 0;
static int AC_L5_DEGRADED_L3_VOLUME_GRID = 0;
static int AC_L5_DEGRADED_L3_SPEC_PARTIAL = 0;

// Compatibility fields retained until AuroraCore diagnostics is fully renamed away from the retired advisory packet wording.
// They are mapped to Basic System Gate state, not to a deep advisory/calculation packet.
static int AC_L5_ELIGIBLE_OPEN = 0;
static int AC_L5_READY_SYMBOLS = 0;
static int AC_L5_PENDING_SYMBOLS = 0;
static string AC_L5_PACKET_SCHEMA_VERSION = "l5_basic_system_gate_v2";
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

static string AC_L5_GATE_POLICY = "closed_market_or_non_fresh_quote_or_invalid_bidask_or_missing_specs_or_disabled_trade_mode_or_absurd_spread_or_unresolved_classification_review_or_l4_surface_not_usable_blocks;eligible_symbols_are_clean_or_degraded_only";
static string AC_L5_WORST_BLOCKER = "None";
static double AC_L5_ABSURD_SPREAD_BPS_LIMIT = 250.0;
static double AC_L5_MAX_FRESH_TICK_AGE_SECONDS = 30.0;

struct AC_L5GatePacket
{
   string symbol;
   string gate_status;
   string gate_state;
   string gate_reason;
   string degraded_reason;
   string l2_gate;
   string l3_gate;
   string l4_gate;
   double eligibility_score;
   bool pass;
   bool degraded;
   bool blocked_closed_market;
   bool blocked_stale_quote;
   bool blocked_missing_tick;
   bool blocked_invalid_bidask;
   bool blocked_missing_specs;
   bool blocked_trade_mode;
   bool blocked_absurd_spread;
   bool blocked_classification_review;
   bool blocked_l4_surface_not_usable;
   bool degraded_l3_value_or_margin;
   bool degraded_l3_volume_grid;
   bool degraded_l3_spec_partial;
   bool trade_permission;
};

static AC_L5GatePacket AC_L5_SYMBOLS[];

string AC_L5BoolText(const bool value)
{
   return value ? "TRUE" : "FALSE";
}

#endif
