#ifndef AC_DEEP_INSPECTION_OWNER_MQH
#define AC_DEEP_INSPECTION_OWNER_MQH

// Runtime 5 / Deep Inspection Advisory Owner.
// First pass: status and publication shell only.
// Runtime 5 owns advisory interpretation and presentation surfaces only.
// Heavy/deep calculations must be executed through Runtime 3 External Worker job-bus acceptance.
// Runtime 5 must not duplicate L1 account truth, L2 market-state truth, L3 broker specs/value truth,
// L4 live quote/spread truth, Runtime 3 worker transport/result validation, FileIO/routes,
// Board/Dossier rendering authority, ranking, selection, permission, strategy, or execution.

static bool   AC_L5_READY = false;
static string AC_L5_STATUS = "Shell only";
static string AC_L5_TRUST_STATE = "Advisory Not Ready";
static string AC_L5_MAIN_BLOCKER = "Layer 5 advisory calculations not implemented yet";
static string AC_L5_BOARD_SECTION = "";
static string AC_L5_WORKBENCH_SECTION = "";
static uint   AC_L5_REFRESH_DURATION_MS = 0;
static int    AC_L5_ELIGIBLE_OPEN = 0;
static int    AC_L5_READY_SYMBOLS = 0;
static int    AC_L5_PENDING_SYMBOLS = 0;
static string AC_L5_CALCULATION_LANE = "Runtime3_external_worker_job_bus_required_for_deep_calculation";
static string AC_L5_EXECUTION_OWNER = "Runtime_3_external_worker_job_bus_and_result_acceptance";
static string AC_L5_SOURCE_TRUTH_OWNER = "L1_L2_L3_L4_existing_owner_packets_only";
static string AC_L5_SURFACE_OWNER = "Runtime_5_advisory_interpretation_shell_only";
static string AC_L5_NO_DUPLICATE_OWNER_CONTRACT = "no_duplicate_L1_L2_L3_L4_Runtime3_FileIO_route_board_dossier_ranking_selection_permission_execution_owner";
static string AC_L5_DOSSIER_LAYOUT_CONTRACT = "rich_per_symbol_advisory_packet_after_runtime3_accepts_worker_result";
static string AC_L5_BOARD_LAYOUT_CONTRACT = "compact_aggregate_only_no_symbol_spam_no_ranking_no_selection";
static string AC_L5_WORKBENCH_LAYOUT_CONTRACT = "full_owner_boundary_job_bus_binding_counters_timings_rejections";

void AC_BuildLayer5Texts()
{
   uint start_ms = GetTickCount();
   AC_L5_ELIGIBLE_OPEN = AC_L4_READY ? AC_L4_ELIGIBLE_OPEN : 0;
   AC_L5_READY_SYMBOLS = 0;
   AC_L5_PENDING_SYMBOLS = AC_L5_ELIGIBLE_OPEN;
   AC_L5_READY = false;
   AC_L5_STATUS = "Shell only";
   AC_L5_TRUST_STATE = "Advisory Not Ready";
   if(!AC_L4_READY)
      AC_L5_MAIN_BLOCKER = "Waiting for Layer 4 live quote and spread truth";
   else if(AC_L5_ELIGIBLE_OPEN <= 0)
      AC_L5_MAIN_BLOCKER = "No open symbols eligible for Layer 5 advisory shell";
   else if(!AC_EXTERNAL_WORKER_STATUS.accepted_result)
      AC_L5_MAIN_BLOCKER = "Waiting for Runtime 3 accepted external-worker job result before deep advisory calculations";
   else
      AC_L5_MAIN_BLOCKER = "Runtime 3 job bus accepted; Layer 5 deep advisory calculation packet not implemented yet; degraded shell published";

   AC_L5_BOARD_SECTION = "\r\nLAYER 5 - DEEP INSPECTION ADVISORY\r\n";
   AC_L5_BOARD_SECTION += "----------------------------------------\r\n";
   AC_L5_BOARD_SECTION += "Status:            " + AC_L5_STATUS + "\r\n";
   AC_L5_BOARD_SECTION += "Trust:             " + AC_L5_TRUST_STATE + "\r\n";
   AC_L5_BOARD_SECTION += "Calculation Lane:  External Worker via Runtime 3\r\n";
   AC_L5_BOARD_SECTION += "Worker Accepted:   " + (AC_EXTERNAL_WORKER_STATUS.accepted_result ? "TRUE" : "FALSE") + "\r\n";
   AC_L5_BOARD_SECTION += "Eligible Open:     " + IntegerToString(AC_L5_ELIGIBLE_OPEN) + "\r\n";
   AC_L5_BOARD_SECTION += "Ready Symbols:     " + IntegerToString(AC_L5_READY_SYMBOLS) + "\r\n";
   AC_L5_BOARD_SECTION += "Pending Symbols:   " + IntegerToString(AC_L5_PENDING_SYMBOLS) + "\r\n";
   AC_L5_BOARD_SECTION += "Permission:        FALSE\r\n";
   AC_L5_BOARD_SECTION += "Ranking:           FALSE\r\n";
   AC_L5_BOARD_SECTION += "Selection:         FALSE\r\n";
   AC_L5_BOARD_SECTION += "Blocker:           " + AC_L5_MAIN_BLOCKER + "\r\n";

   AC_L5_WORKBENCH_SECTION = "\r\nL5_DEEP_INSPECTION_ADVISORY\r\n";
   AC_L5_WORKBENCH_SECTION += "----------------------------------------\r\n";
   AC_L5_WORKBENCH_SECTION += "owner_name=" + AC_RUNTIME5_OWNER + "\r\n";
   AC_L5_WORKBENCH_SECTION += "layer_name=" + AC_LAYER_5_NAME + "\r\n";
   AC_L5_WORKBENCH_SECTION += "status=" + AC_L5_STATUS + "\r\n";
   AC_L5_WORKBENCH_SECTION += "trust_state=" + AC_L5_TRUST_STATE + "\r\n";
   AC_L5_WORKBENCH_SECTION += "calculation_lane=" + AC_L5_CALCULATION_LANE + "\r\n";
   AC_L5_WORKBENCH_SECTION += "execution_owner=" + AC_L5_EXECUTION_OWNER + "\r\n";
   AC_L5_WORKBENCH_SECTION += "source_truth_owner=" + AC_L5_SOURCE_TRUTH_OWNER + "\r\n";
   AC_L5_WORKBENCH_SECTION += "surface_owner=" + AC_L5_SURFACE_OWNER + "\r\n";
   AC_L5_WORKBENCH_SECTION += "duplicate_owner_contract=" + AC_L5_NO_DUPLICATE_OWNER_CONTRACT + "\r\n";
   AC_L5_WORKBENCH_SECTION += "mt5_heavy_calculation_allowed=false\r\n";
   AC_L5_WORKBENCH_SECTION += "runtime3_worker_required_for_deep_calculation=true\r\n";
   AC_L5_WORKBENCH_SECTION += "runtime3_result_accepted=" + (AC_EXTERNAL_WORKER_STATUS.accepted_result ? "true" : "false") + "\r\n";
   AC_L5_WORKBENCH_SECTION += "runtime3_job_bus_status=" + AC_EXTERNAL_WORKER_STATUS.job_bus_status + "\r\n";
   AC_L5_WORKBENCH_SECTION += "runtime3_job_bus_validation_status=" + AC_EXTERNAL_WORKER_STATUS.job_bus_validation_status + "\r\n";
   AC_L5_WORKBENCH_SECTION += "runtime3_result_job_id=" + AC_EXTERNAL_WORKER_STATUS.result_job_id + "\r\n";
   AC_L5_WORKBENCH_SECTION += "runtime3_result_job_type=" + AC_EXTERNAL_WORKER_STATUS.result_job_type + "\r\n";
   AC_L5_WORKBENCH_SECTION += "runtime3_result_job_status=" + AC_EXTERNAL_WORKER_STATUS.result_job_status + "\r\n";
   AC_L5_WORKBENCH_SECTION += "eligible_open=" + IntegerToString(AC_L5_ELIGIBLE_OPEN) + "\r\n";
   AC_L5_WORKBENCH_SECTION += "ready_symbols=" + IntegerToString(AC_L5_READY_SYMBOLS) + "\r\n";
   AC_L5_WORKBENCH_SECTION += "pending_symbols=" + IntegerToString(AC_L5_PENDING_SYMBOLS) + "\r\n";
   AC_L5_WORKBENCH_SECTION += "main_blocker=" + AC_L5_MAIN_BLOCKER + "\r\n";
   AC_L5_WORKBENCH_SECTION += "inputs_consumed=L1_L2_L3_L4_owner_packets_plus_Runtime3_accepted_worker_result_only\r\n";
   AC_L5_WORKBENCH_SECTION += "outputs_published=dossier_advisory_shell_board_summary_workbench_status_row\r\n";
   AC_L5_WORKBENCH_SECTION += "planned_dossier_layout=" + AC_L5_DOSSIER_LAYOUT_CONTRACT + "\r\n";
   AC_L5_WORKBENCH_SECTION += "planned_board_layout=" + AC_L5_BOARD_LAYOUT_CONTRACT + "\r\n";
   AC_L5_WORKBENCH_SECTION += "planned_workbench_layout=" + AC_L5_WORKBENCH_LAYOUT_CONTRACT + "\r\n";
   AC_L5_WORKBENCH_SECTION += "permission=false\r\n";
   AC_L5_WORKBENCH_SECTION += "ranking_runtime=false\r\n";
   AC_L5_WORKBENCH_SECTION += "selection_runtime=false\r\n";
   AC_L5_WORKBENCH_SECTION += "fileio_owner=Publication_FileIO_Route_Service_only\r\n";
   AC_L5_WORKBENCH_SECTION += "publication_policy=print_degraded_truth_do_not_block_files\r\n";
   AC_L5_REFRESH_DURATION_MS = GetTickCount() - start_ms;
   AC_L5_WORKBENCH_SECTION += "refresh_duration_ms=" + IntegerToString((int)AC_L5_REFRESH_DURATION_MS) + "\r\n";
}

string AC_Layer5DossierSection(const string symbol)
{
   string market_state = AC_L2MarketStateForSymbol(symbol);
   string text = "\r\nLAYER 5 - DEEP INSPECTION ADVISORY\r\n";
   text += "----------------------------------------\r\n";
   text += "Symbol: " + symbol + "\r\n";
   text += "Market State Source: Layer 2\r\n";
   text += "Market State: " + market_state + "\r\n";
   text += "Status: " + AC_L5_STATUS + "\r\n";
   text += "Trust: " + AC_L5_TRUST_STATE + "\r\n";
   text += "Blocker: " + AC_L5_MAIN_BLOCKER + "\r\n";
   text += "\r\nCALCULATION LANE\r\n";
   text += "Runtime 5 Owns: Advisory interpretation shell and per-symbol advisory presentation\r\n";
   text += "Runtime 3 Owns: External-worker job bus, worker result acceptance, snapshot/job binding\r\n";
   text += "Worker Result Accepted: " + (AC_EXTERNAL_WORKER_STATUS.accepted_result ? "TRUE" : "FALSE") + "\r\n";
   text += "Job Bus Status: " + AC_EXTERNAL_WORKER_STATUS.job_bus_status + "\r\n";
   text += "Job Type: " + AC_EXTERNAL_WORKER_STATUS.result_job_type + "\r\n";
   text += "MT5 Heavy Calculation Active: FALSE\r\n";
   text += "\r\nPLANNED L5 DOSSIER PACKET\r\n";
   text += "Readiness: pending_runtime3_accepted_deep_result\r\n";
   text += "Friction Advisory: not_implemented\r\n";
   text += "Volatility Advisory: not_implemented\r\n";
   text += "Structure Advisory: not_implemented\r\n";
   text += "Session Advisory: not_implemented\r\n";
   text += "Risk Advisory: not_implemented\r\n";
   text += "Invalidation / Kill Reason: not_implemented\r\n";
   text += "Degraded Publication: TRUE\r\n";
   text += "Deep Calculations Active: FALSE\r\n";
   text += "Permission: FALSE\r\n";
   text += "Ranking: FALSE\r\n";
   text += "Selection: FALSE\r\n";
   text += "Owner Boundary: Runtime 5 consumes L1-L4 owner packets and Runtime 3 accepted worker result only; it does not recalculate earlier-layer truth.\r\n";
   return text;
}

string AC_Layer5BoardSection()
{
   if(AC_L5_BOARD_SECTION == "") AC_BuildLayer5Texts();
   return AC_L5_BOARD_SECTION;
}

string AC_Layer5WorkbenchSection()
{
   if(AC_L5_WORKBENCH_SECTION == "") AC_BuildLayer5Texts();
   return AC_L5_WORKBENCH_SECTION;
}

string AC_Layer5StatusRow()
{
   return "schema_name=layer_status|schema_version=v0.9|layer_id=L5|layer_name=" + AC_LAYER_5_NAME
      + "|source_owner=" + AC_RUNTIME5_OWNER
      + "|status=" + AC_L5_STATUS
      + "|trust_state=" + AC_L5_TRUST_STATE
      + "|calculation_lane=" + AC_L5_CALCULATION_LANE
      + "|execution_owner=" + AC_L5_EXECUTION_OWNER
      + "|source_truth_owner=" + AC_L5_SOURCE_TRUTH_OWNER
      + "|runtime3_worker_required_for_deep_calculation=true"
      + "|runtime3_result_accepted=" + (AC_EXTERNAL_WORKER_STATUS.accepted_result ? "true" : "false")
      + "|runtime3_job_bus_status=" + AC_EXTERNAL_WORKER_STATUS.job_bus_status
      + "|eligible_open=" + IntegerToString(AC_L5_ELIGIBLE_OPEN)
      + "|ready_symbols=" + IntegerToString(AC_L5_READY_SYMBOLS)
      + "|pending_symbols=" + IntegerToString(AC_L5_PENDING_SYMBOLS)
      + "|main_blocker=" + AC_L5_MAIN_BLOCKER
      + "|permission=false|ranking_runtime=false|selection_runtime=false|mt5_heavy_calculation_allowed=false";
}

#endif
