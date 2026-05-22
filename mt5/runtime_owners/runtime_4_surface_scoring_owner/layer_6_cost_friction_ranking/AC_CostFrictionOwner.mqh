#ifndef AC_COST_FRICTION_OWNER_MQH
#define AC_COST_FRICTION_OWNER_MQH

// Runtime 4 / Surface Scoring Owner - Layer 6 skeleton.
// Layer 6 is Cost / Friction Ranking. This file is L6-B only: surfaces and contracts.
// No Gateway job is emitted here yet, no Python calculation is performed here yet,
// and no symbols are blocked by Layer 6. Layer 5 remains the only hard gate.

static string AC_RUNTIME4_OWNER = "Runtime 4 - Surface Scoring Owner";
static string AC_LAYER_6_NAME = "Layer 6 - Cost / Friction Ranking";
static string AC_L6_STATUS = "Pending Gateway calculation";
static string AC_L6_TRUST_STATE = "Ranking Not Ready";
static string AC_L6_MAIN_BLOCKER = "L6 skeleton is waiting for Gateway calculation implementation";
static string AC_L6_JOB_TYPE = "L6_COST_FRICTION_RANKING_V1";
static string AC_L6_EXPECTED_OUTPUT = "l6_cost_friction_ranking_v1";
static string AC_L6_RANKED_CSV_PATH = "Outbox\\Layers\\Layer_6_Cost_Friction_Ranking\\ranked_symbols.csv";
static string AC_L6_RANKED_MANIFEST_PATH = "Outbox\\Layers\\Layer_6_Cost_Friction_Ranking\\ranked_symbols.manifest";
static string AC_L6_TOP20_PATH = "Outbox\\Layers\\Layer_6_Cost_Friction_Ranking\\ranked_symbols_top20.txt";

static int AC_L6_INPUT_L5_PASS_SYMBOLS = 0;
static int AC_L6_RANKED_SYMBOLS = 0;
static int AC_L6_RANKED_DEGRADED_SYMBOLS = 0;
static int AC_L6_NOT_RANKABLE_QUALITY_SYMBOLS = 0;
static int AC_L6_ELITE_FRICTION_COUNT = 0;
static int AC_L6_GOOD_FRICTION_COUNT = 0;
static int AC_L6_ACCEPTABLE_FRICTION_COUNT = 0;
static int AC_L6_EXPENSIVE_FRICTION_COUNT = 0;
static int AC_L6_HOSTILE_FRICTION_COUNT = 0;
static string AC_L6_BEST_SYMBOL = "not_available";
static string AC_L6_WORST_RANKED_SYMBOL = "not_available";
static double AC_L6_BEST_SCORE = 0.0;
static double AC_L6_WORST_SCORE = 0.0;
static uint AC_L6_CALCULATION_DURATION_MS = 0;

void AC_RefreshLayer6CostFrictionSkeleton()
{
   AC_L6_INPUT_L5_PASS_SYMBOLS = AC_L5_GATE_PASS;
   AC_L6_STATUS = "Pending Gateway calculation";
   AC_L6_TRUST_STATE = "Ranking Not Ready";
   AC_L6_MAIN_BLOCKER = "Gateway handler and ranked CSV are not implemented yet";
   AC_L6_RANKED_SYMBOLS = 0;
   AC_L6_RANKED_DEGRADED_SYMBOLS = 0;
   AC_L6_NOT_RANKABLE_QUALITY_SYMBOLS = 0;
   AC_L6_ELITE_FRICTION_COUNT = 0;
   AC_L6_GOOD_FRICTION_COUNT = 0;
   AC_L6_ACCEPTABLE_FRICTION_COUNT = 0;
   AC_L6_EXPENSIVE_FRICTION_COUNT = 0;
   AC_L6_HOSTILE_FRICTION_COUNT = 0;
   AC_L6_BEST_SYMBOL = "pending";
   AC_L6_WORST_RANKED_SYMBOL = "pending";
   AC_L6_BEST_SCORE = 0.0;
   AC_L6_WORST_SCORE = 0.0;
   AC_L6_CALCULATION_DURATION_MS = 0;
}

string AC_Layer6BoardSection()
{
   AC_RefreshLayer6CostFrictionSkeleton();
   string text = "\r\nLAYER 6 - COST / FRICTION RANKING\r\n";
   text += "----------------------------------------\r\n";
   text += "Status:                     " + AC_L6_STATUS + "\r\n";
   text += "Trust:                      " + AC_L6_TRUST_STATE + "\r\n";
   text += "Owner:                      " + AC_RUNTIME4_OWNER + "\r\n";
   text += "Gateway Required:           TRUE\r\n";
   text += "Gateway Result Accepted:    FALSE\r\n";
   text += "Input Source:               Layer 5 pass set only\r\n";
   text += "L5 Pass Symbols:            " + IntegerToString(AC_L6_INPUT_L5_PASS_SYMBOLS) + "\r\n";
   text += "Ranked Symbols:             " + IntegerToString(AC_L6_RANKED_SYMBOLS) + "\r\n";
   text += "Ranked Degraded:            " + IntegerToString(AC_L6_RANKED_DEGRADED_SYMBOLS) + "\r\n";
   text += "Not Rankable Quality:       " + IntegerToString(AC_L6_NOT_RANKABLE_QUALITY_SYMBOLS) + "\r\n";
   text += "Elite Friction:             " + IntegerToString(AC_L6_ELITE_FRICTION_COUNT) + "\r\n";
   text += "Good Friction:              " + IntegerToString(AC_L6_GOOD_FRICTION_COUNT) + "\r\n";
   text += "Acceptable Friction:        " + IntegerToString(AC_L6_ACCEPTABLE_FRICTION_COUNT) + "\r\n";
   text += "Expensive Friction:         " + IntegerToString(AC_L6_EXPENSIVE_FRICTION_COUNT) + "\r\n";
   text += "Hostile Friction:           " + IntegerToString(AC_L6_HOSTILE_FRICTION_COUNT) + "\r\n";
   text += "Best Friction Symbol:       " + AC_L6_BEST_SYMBOL + "\r\n";
   text += "Best Score:                 pending\r\n";
   text += "Worst Ranked Symbol:        " + AC_L6_WORST_RANKED_SYMBOL + "\r\n";
   text += "Worst Score:                pending\r\n";
   text += "CSV Output:                 " + AC_L6_RANKED_CSV_PATH + "\r\n";
   text += "Main Blocker:               " + AC_L6_MAIN_BLOCKER + "\r\n";
   text += "Gateway Job:                " + AC_L6_JOB_TYPE + "\r\n";
   text += "Calculation Duration:       0 ms\r\n";
   text += "Ranking Runtime:            TRUE\r\n";
   text += "Selection Runtime:          FALSE\r\n";
   text += "Trade Permission:           FALSE\r\n";
   return text;
}

string AC_Layer6DossierSection(const string symbol)
{
   AC_RefreshLayer6CostFrictionSkeleton();
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
   text += "Gateway Required: TRUE\r\n";
   text += "Gateway Result Accepted: FALSE\r\n";
   text += "L5 Gate Status: " + l5_status + "\r\n";
   text += "L5 Gate Reason: " + l5_reason + "\r\n";
   if(l5_status == "pass")
   {
      text += "Rank State: pending_gateway_calculation\r\n";
      text += "Rank Index: pending\r\n";
      text += "Friction Score: pending\r\n";
      text += "Friction Bucket: pending\r\n";
      text += "CSV Source: " + AC_L6_RANKED_CSV_PATH + "\r\n";
      text += "\r\nCost Snapshot\r\n";
      text += "----------------------------------------\r\n";
      text += "Spread / round-trip cost values are pending L6 Gateway calculation.\r\n";
      text += "MT5 will provide OrderCalcProfit cost primitives in L6-C; Python ranks in L6-D.\r\n";
   }
   else
   {
      text += "Rank State: not_ranked_l5_gate_failed\r\n";
      text += "Friction Score: not_available\r\n";
      text += "Friction Bucket: not_available\r\n";
   }
   text += "\r\nBoundary\r\n";
   text += "----------------------------------------\r\n";
   text += "Source Owner: Layer 5 pass set + Layer 3/4 packets + future MT5 cost primitives\r\n";
   text += "Scoring Owner: " + AC_RUNTIME4_OWNER + "\r\n";
   text += "Calculation Support: Runtime 3 Gateway\r\n";
   text += "Ranking Runtime: TRUE\r\n";
   text += "Selection Runtime: FALSE\r\n";
   text += "Trade Permission: FALSE\r\n";
   text += "Execution: FALSE\r\n";
   return text;
}

string AC_Layer6WorkbenchSection()
{
   AC_RefreshLayer6CostFrictionSkeleton();
   string text = "\r\nL6_COST_FRICTION_RANKING\r\n";
   text += "----------------------------------------\r\n";
   text += "owner_name=" + AC_RUNTIME4_OWNER + "\r\n";
   text += "layer_name=" + AC_LAYER_6_NAME + "\r\n";
   text += "status=" + AC_L6_STATUS + "\r\n";
   text += "trust_state=" + AC_L6_TRUST_STATE + "\r\n";
   text += "gateway_required=true\r\n";
   text += "gateway_result_accepted=false\r\n";
   text += "source_truth_owner=L5_pass_set_plus_L3_L4_owner_packets_plus_future_mt5_ordercalcprofit_primitives\r\n";
   text += "calculation_support_owner=Runtime3_Calculation_Gateway\r\n";
   text += "job_bus_schema_version=" + AC_EXTERNAL_WORKER_JOB_BUS_SCHEMA_VERSION + "\r\n";
   text += "job_type=" + AC_L6_JOB_TYPE + "\r\n";
   text += "expected_output=" + AC_L6_EXPECTED_OUTPUT + "\r\n";
   text += "input_l5_pass_symbols=" + IntegerToString(AC_L6_INPUT_L5_PASS_SYMBOLS) + "\r\n";
   text += "ranked_symbols=" + IntegerToString(AC_L6_RANKED_SYMBOLS) + "\r\n";
   text += "ranked_degraded_symbols=" + IntegerToString(AC_L6_RANKED_DEGRADED_SYMBOLS) + "\r\n";
   text += "not_rankable_quality_symbols=" + IntegerToString(AC_L6_NOT_RANKABLE_QUALITY_SYMBOLS) + "\r\n";
   text += "ranked_csv_path=" + AC_L6_RANKED_CSV_PATH + "\r\n";
   text += "ranked_manifest_path=" + AC_L6_RANKED_MANIFEST_PATH + "\r\n";
   text += "top20_path=" + AC_L6_TOP20_PATH + "\r\n";
   text += "main_blocker=" + AC_L6_MAIN_BLOCKER + "\r\n";
   text += "calculation_duration_ms=0\r\n";
   text += "ranking_runtime=true\r\n";
   text += "selection_runtime=false\r\n";
   text += "trade_permission=false\r\n";
   return text;
}

string AC_Layer6StatusRow()
{
   AC_RefreshLayer6CostFrictionSkeleton();
   return "schema_name=layer_status|schema_version=v6_skeleton_1|layer_id=6|layer_name=" + AC_LAYER_6_NAME
      + "|source_owner=" + AC_RUNTIME4_OWNER
      + "|layer_status=" + AC_L6_STATUS
      + "|trust_state=" + AC_L6_TRUST_STATE
      + "|gateway_required=true|gateway_result_accepted=false"
      + "|input_l5_pass_symbols=" + IntegerToString(AC_L6_INPUT_L5_PASS_SYMBOLS)
      + "|ranked_symbols=" + IntegerToString(AC_L6_RANKED_SYMBOLS)
      + "|ranked_csv_path=" + AC_L6_RANKED_CSV_PATH
      + "|job_type=" + AC_L6_JOB_TYPE
      + "|ranking_runtime=true|selection_runtime=false|permission=false";
}

#endif
