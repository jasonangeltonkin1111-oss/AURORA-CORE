#ifndef AC_DEEP_INSPECTION_OWNER_MQH
#define AC_DEEP_INSPECTION_OWNER_MQH

// Runtime 5 / Deep Inspection Advisory Owner.
// Runtime 5 owns advisory interpretation and presentation only.
// Heavy/deep calculations must be executed through Runtime 3 External Worker job-bus acceptance.
// Runtime 5 must not duplicate L1 account truth, L2 market-state truth, L3 broker specs/value truth,
// L4 live quote/spread truth, Runtime 3 worker transport/result validation, FileIO/routes,
// Board/Dossier rendering authority, ranking, selection, permission, strategy, or execution.
// Surface rule: Board = compact operator summary; Dossier = rich per-symbol advisory truth;
// Workbench = machine/meta diagnostics, owner contract, job binding, counters, timings, rejections.
// No-repeat rule: L5 references L1-L4 gates only. It does not restate raw earlier-layer data.

static bool   AC_L5_READY = false;
static string AC_L5_STATUS = "Shell only";
static string AC_L5_TRUST_STATE = "Advisory Not Ready";
static string AC_L5_MAIN_BLOCKER = "Layer 5 advisory calculations not implemented yet";
static string AC_L5_READINESS_STATE = "blocked_not_evaluated";
static string AC_L5_READINESS_REASON = "Layer 5 readiness packet has not run yet";
static string AC_L5_BOARD_SECTION = "";
static string AC_L5_WORKBENCH_SECTION = "";
static uint   AC_L5_REFRESH_DURATION_MS = 0;
static int    AC_L5_ELIGIBLE_OPEN = 0;
static int    AC_L5_READY_SYMBOLS = 0;
static int    AC_L5_PENDING_SYMBOLS = 0;
static int    AC_L5_BLOCKED_L2_GATE = 0;
static int    AC_L5_BLOCKED_L3_GATE = 0;
static int    AC_L5_BLOCKED_L4_GATE = 0;
static int    AC_L5_BLOCKED_RUNTIME3_GATE = 0;
static int    AC_L5_BLOCKED_NO_ELIGIBLE = 0;
static int    AC_L5_DEEP_PACKET_PENDING = 0;
static string AC_L5_L2_GATE_STATUS = "not_evaluated";
static string AC_L5_L3_GATE_STATUS = "not_evaluated";
static string AC_L5_L4_GATE_STATUS = "not_evaluated";
static string AC_L5_RUNTIME3_GATE_STATUS = "not_evaluated";
static string AC_L5_CALCULATION_LANE = "Runtime3_external_worker_job_bus_required_for_deep_calculation";
static string AC_L5_EXECUTION_OWNER = "Runtime_3_external_worker_job_bus_and_result_acceptance";
static string AC_L5_SOURCE_TRUTH_OWNER = "L1_L2_L3_L4_existing_owner_gates_only";
static string AC_L5_SURFACE_OWNER = "Runtime_5_advisory_interpretation_shell_only";
static string AC_L5_NO_DUPLICATE_OWNER_CONTRACT = "no_duplicate_L1_L2_L3_L4_Runtime3_FileIO_route_board_dossier_ranking_selection_permission_execution_owner";
static string AC_L5_BOARD_LAYOUT_CONTRACT = "compact_operator_summary_same_style_as_L1_L2_L3_L4";
static string AC_L5_DOSSIER_LAYOUT_CONTRACT = "rich_per_symbol_advisory_packet_same_style_as_L3_L4_dossier_sections_without_repeating_raw_previous_layer_data";
static string AC_L5_WORKBENCH_LAYOUT_CONTRACT = "machine_meta_diagnostics_same_style_as_L1_L2_L3_L4_workbench_sections";

string AC_L5BoolText(const bool value)
{
   return value ? "TRUE" : "FALSE";
}

void AC_L5ResetReadinessPacket()
{
   AC_L5_READY = false;
   AC_L5_STATUS = "Readiness shell";
   AC_L5_TRUST_STATE = "Advisory Not Ready";
   AC_L5_READINESS_STATE = "blocked_not_evaluated";
   AC_L5_READINESS_REASON = "Layer 5 readiness packet has not run yet";
   AC_L5_MAIN_BLOCKER = "Layer 5 advisory calculations not implemented yet";
   AC_L5_READY_SYMBOLS = 0;
   AC_L5_PENDING_SYMBOLS = 0;
   AC_L5_BLOCKED_L2_GATE = 0;
   AC_L5_BLOCKED_L3_GATE = 0;
   AC_L5_BLOCKED_L4_GATE = 0;
   AC_L5_BLOCKED_RUNTIME3_GATE = 0;
   AC_L5_BLOCKED_NO_ELIGIBLE = 0;
   AC_L5_DEEP_PACKET_PENDING = 0;
   AC_L5_L2_GATE_STATUS = AC_L2_READY ? "ready" : "blocked";
   AC_L5_L3_GATE_STATUS = AC_L3_READY ? "ready" : "blocked";
   AC_L5_L4_GATE_STATUS = AC_L4_READY ? "ready" : "blocked";
   AC_L5_RUNTIME3_GATE_STATUS = AC_EXTERNAL_WORKER_STATUS.accepted_result ? "accepted" : "blocked";
}

void AC_L5EvaluateReadinessPacket()
{
   AC_L5ResetReadinessPacket();
   AC_L5_ELIGIBLE_OPEN = AC_L4_READY ? AC_L4_ELIGIBLE_OPEN : 0;

   if(!AC_L2_READY)
   {
      AC_L5_READINESS_STATE = "blocked_l2_gate_not_ready";
      AC_L5_READINESS_REASON = "Layer 2 owner gate is not ready; see Layer 2 section";
      AC_L5_MAIN_BLOCKER = "Layer 2 owner gate not ready";
      AC_L5_BLOCKED_L2_GATE = 1;
      return;
   }
   if(!AC_L3_READY)
   {
      AC_L5_READINESS_STATE = "blocked_l3_gate_not_ready";
      AC_L5_READINESS_REASON = "Layer 3 owner gate is not ready; see Layer 3 section";
      AC_L5_MAIN_BLOCKER = "Layer 3 owner gate not ready";
      AC_L5_BLOCKED_L3_GATE = 1;
      return;
   }
   if(!AC_L4_READY)
   {
      AC_L5_READINESS_STATE = "blocked_l4_gate_not_ready";
      AC_L5_READINESS_REASON = "Layer 4 owner gate is not ready; see Layer 4 section";
      AC_L5_MAIN_BLOCKER = "Layer 4 owner gate not ready";
      AC_L5_BLOCKED_L4_GATE = 1;
      return;
   }
   if(AC_L5_ELIGIBLE_OPEN <= 0)
   {
      AC_L5_READINESS_STATE = "blocked_no_eligible_symbols";
      AC_L5_READINESS_REASON = "Layer 4 reports no eligible open-symbol gate count";
      AC_L5_MAIN_BLOCKER = "No Layer 4 eligible open-symbol gate count";
      AC_L5_BLOCKED_NO_ELIGIBLE = 1;
      return;
   }
   if(!AC_EXTERNAL_WORKER_STATUS.accepted_result)
   {
      AC_L5_READINESS_STATE = "blocked_runtime3_not_accepted";
      AC_L5_READINESS_REASON = "Runtime 3 worker result gate is not accepted";
      AC_L5_MAIN_BLOCKER = "Waiting for Runtime 3 accepted external-worker result gate";
      AC_L5_BLOCKED_RUNTIME3_GATE = AC_L5_ELIGIBLE_OPEN;
      AC_L5_PENDING_SYMBOLS = AC_L5_ELIGIBLE_OPEN;
      return;
   }

   AC_L5_READINESS_STATE = "ready_for_deep_packet";
   AC_L5_READINESS_REASON = "L2/L3/L4 owner gates and Runtime 3 worker gate are accepted; deep advisory packet not implemented yet";
   AC_L5_MAIN_BLOCKER = "Deep advisory packet implementation pending";
   AC_L5_TRUST_STATE = "Advisory Gate Ready";
   AC_L5_DEEP_PACKET_PENDING = AC_L5_ELIGIBLE_OPEN;
   AC_L5_PENDING_SYMBOLS = AC_L5_ELIGIBLE_OPEN;
}

string AC_L5ReadinessText()
{
   if(AC_L5_READINESS_STATE == "blocked_not_evaluated") return "Not evaluated";
   return AC_L5_READINESS_STATE;
}

string AC_L5LayerGateSummary()
{
   return "L2=" + AC_L5_L2_GATE_STATUS
      + ";L3=" + AC_L5_L3_GATE_STATUS
      + ";L4=" + AC_L5_L4_GATE_STATUS
      + ";R3=" + AC_L5_RUNTIME3_GATE_STATUS;
}

void AC_BuildLayer5Texts()
{
   uint start_ms = GetTickCount();
   AC_L5EvaluateReadinessPacket();
   AC_L5_REFRESH_DURATION_MS = GetTickCount() - start_ms;

   AC_L5_BOARD_SECTION = "\r\nLAYER 5 - DEEP INSPECTION ADVISORY\r\n";
   AC_L5_BOARD_SECTION += "----------------------------------------\r\n";
   AC_L5_BOARD_SECTION += "Status:                     " + AC_L5_STATUS + "\r\n";
   AC_L5_BOARD_SECTION += "Trust:                      " + AC_L5_TRUST_STATE + "\r\n";
   AC_L5_BOARD_SECTION += "Calculation Lane:           External Worker via Runtime 3\r\n";
   AC_L5_BOARD_SECTION += "Runtime 3 Result Accepted:  " + AC_L5BoolText(AC_EXTERNAL_WORKER_STATUS.accepted_result) + "\r\n";
   AC_L5_BOARD_SECTION += "Owner Gates:                " + AC_L5LayerGateSummary() + "\r\n";
   AC_L5_BOARD_SECTION += "Eligible Gate Count:        " + IntegerToString(AC_L5_ELIGIBLE_OPEN) + "\r\n";
   AC_L5_BOARD_SECTION += "Ready Advisory Packets:     " + IntegerToString(AC_L5_READY_SYMBOLS) + "\r\n";
   AC_L5_BOARD_SECTION += "Pending Advisory Packets:   " + IntegerToString(AC_L5_PENDING_SYMBOLS) + "\r\n";
   AC_L5_BOARD_SECTION += "Readiness:                  " + AC_L5ReadinessText() + "\r\n";
   AC_L5_BOARD_SECTION += "Worst Blocker:              " + AC_L5_MAIN_BLOCKER + "\r\n";
   AC_L5_BOARD_SECTION += "Scan Duration:              " + IntegerToString((int)AC_L5_REFRESH_DURATION_MS) + " ms\r\n";
   AC_L5_BOARD_SECTION += "Trade Permission:           FALSE\r\n";
   AC_L5_BOARD_SECTION += "Ranking Runtime:            FALSE\r\n";
   AC_L5_BOARD_SECTION += "Selection Runtime:          FALSE\r\n";

   AC_L5_WORKBENCH_SECTION = "\r\nL5_DEEP_INSPECTION_ADVISORY\r\n";
   AC_L5_WORKBENCH_SECTION += "----------------------------------------\r\n";
   AC_L5_WORKBENCH_SECTION += "owner_name=" + AC_RUNTIME5_OWNER + "\r\n";
   AC_L5_WORKBENCH_SECTION += "layer_name=" + AC_LAYER_5_NAME + "\r\n";
   AC_L5_WORKBENCH_SECTION += "status=" + AC_L5_STATUS + "\r\n";
   AC_L5_WORKBENCH_SECTION += "trust_state=" + AC_L5_TRUST_STATE + "\r\n";
   AC_L5_WORKBENCH_SECTION += "readiness_state=" + AC_L5_READINESS_STATE + "\r\n";
   AC_L5_WORKBENCH_SECTION += "readiness_reason=" + AC_L5_READINESS_REASON + "\r\n";
   AC_L5_WORKBENCH_SECTION += "calculation_lane=" + AC_L5_CALCULATION_LANE + "\r\n";
   AC_L5_WORKBENCH_SECTION += "execution_owner=" + AC_L5_EXECUTION_OWNER + "\r\n";
   AC_L5_WORKBENCH_SECTION += "source_truth_owner=" + AC_L5_SOURCE_TRUTH_OWNER + "\r\n";
   AC_L5_WORKBENCH_SECTION += "surface_owner=" + AC_L5_SURFACE_OWNER + "\r\n";
   AC_L5_WORKBENCH_SECTION += "duplicate_owner_contract=" + AC_L5_NO_DUPLICATE_OWNER_CONTRACT + "\r\n";
   AC_L5_WORKBENCH_SECTION += "no_repeat_data_contract=L5_references_owner_gates_only_no_raw_L1_L2_L3_L4_packet_duplication\r\n";
   AC_L5_WORKBENCH_SECTION += "board_layout_contract=" + AC_L5_BOARD_LAYOUT_CONTRACT + "\r\n";
   AC_L5_WORKBENCH_SECTION += "dossier_layout_contract=" + AC_L5_DOSSIER_LAYOUT_CONTRACT + "\r\n";
   AC_L5_WORKBENCH_SECTION += "workbench_layout_contract=" + AC_L5_WORKBENCH_LAYOUT_CONTRACT + "\r\n";
   AC_L5_WORKBENCH_SECTION += "mt5_heavy_calculation_allowed=false\r\n";
   AC_L5_WORKBENCH_SECTION += "runtime3_worker_required_for_deep_calculation=true\r\n";
   AC_L5_WORKBENCH_SECTION += "runtime3_result_accepted=" + (AC_EXTERNAL_WORKER_STATUS.accepted_result ? "true" : "false") + "\r\n";
   AC_L5_WORKBENCH_SECTION += "runtime3_job_bus_status=" + AC_EXTERNAL_WORKER_STATUS.job_bus_status + "\r\n";
   AC_L5_WORKBENCH_SECTION += "runtime3_job_bus_validation_status=" + AC_EXTERNAL_WORKER_STATUS.job_bus_validation_status + "\r\n";
   AC_L5_WORKBENCH_SECTION += "runtime3_result_job_id=" + AC_EXTERNAL_WORKER_STATUS.result_job_id + "\r\n";
   AC_L5_WORKBENCH_SECTION += "runtime3_result_job_type=" + AC_EXTERNAL_WORKER_STATUS.result_job_type + "\r\n";
   AC_L5_WORKBENCH_SECTION += "runtime3_result_job_status=" + AC_EXTERNAL_WORKER_STATUS.result_job_status + "\r\n";
   AC_L5_WORKBENCH_SECTION += "owner_gate_summary=" + AC_L5LayerGateSummary() + "\r\n";
   AC_L5_WORKBENCH_SECTION += "eligible_gate_count=" + IntegerToString(AC_L5_ELIGIBLE_OPEN) + "\r\n";
   AC_L5_WORKBENCH_SECTION += "ready_symbols=" + IntegerToString(AC_L5_READY_SYMBOLS) + "\r\n";
   AC_L5_WORKBENCH_SECTION += "pending_symbols=" + IntegerToString(AC_L5_PENDING_SYMBOLS) + "\r\n";
   AC_L5_WORKBENCH_SECTION += "blocked_l2_gate=" + IntegerToString(AC_L5_BLOCKED_L2_GATE) + "\r\n";
   AC_L5_WORKBENCH_SECTION += "blocked_l3_gate=" + IntegerToString(AC_L5_BLOCKED_L3_GATE) + "\r\n";
   AC_L5_WORKBENCH_SECTION += "blocked_l4_gate=" + IntegerToString(AC_L5_BLOCKED_L4_GATE) + "\r\n";
   AC_L5_WORKBENCH_SECTION += "blocked_runtime3_gate=" + IntegerToString(AC_L5_BLOCKED_RUNTIME3_GATE) + "\r\n";
   AC_L5_WORKBENCH_SECTION += "blocked_no_eligible=" + IntegerToString(AC_L5_BLOCKED_NO_ELIGIBLE) + "\r\n";
   AC_L5_WORKBENCH_SECTION += "deep_packet_pending=" + IntegerToString(AC_L5_DEEP_PACKET_PENDING) + "\r\n";
   AC_L5_WORKBENCH_SECTION += "main_blocker=" + AC_L5_MAIN_BLOCKER + "\r\n";
   AC_L5_WORKBENCH_SECTION += "inputs_consumed=L1_L2_L3_L4_owner_gates_plus_Runtime3_accepted_worker_result_only\r\n";
   AC_L5_WORKBENCH_SECTION += "outputs_published=board_summary_dossier_advisory_section_workbench_machine_meta_status_row\r\n";
   AC_L5_WORKBENCH_SECTION += "permission=false\r\n";
   AC_L5_WORKBENCH_SECTION += "ranking_runtime=false\r\n";
   AC_L5_WORKBENCH_SECTION += "selection_runtime=false\r\n";
   AC_L5_WORKBENCH_SECTION += "fileio_owner=Publication_FileIO_Route_Service_only\r\n";
   AC_L5_WORKBENCH_SECTION += "publication_policy=print_degraded_truth_do_not_block_files\r\n";
   AC_L5_WORKBENCH_SECTION += "refresh_duration_ms=" + IntegerToString((int)AC_L5_REFRESH_DURATION_MS) + "\r\n";
}

string AC_Layer5DossierSection(const string symbol)
{
   string text = "\r\nLAYER 5 - DEEP INSPECTION ADVISORY\r\n";
   text += "----------------------------------------\r\n";
   text += "Status: " + AC_L5_STATUS + "\r\n";
   text += "Trust: " + AC_L5_TRUST_STATE + "\r\n";
   text += "Calculation Lane: Runtime 3 external worker\r\n";
   text += "Runtime 3 Result Accepted: " + AC_L5BoolText(AC_EXTERNAL_WORKER_STATUS.accepted_result) + "\r\n";
   text += "L2 Market Gate: See Layer 2 section\r\n";
   text += "L3 Specs Gate: See Layer 3 section\r\n";
   text += "L4 Quote Gate: See Layer 4 section\r\n";
   text += "Readiness State: " + AC_L5_READINESS_STATE + "\r\n";
   text += "Readiness Reason: " + AC_L5_READINESS_REASON + "\r\n";
   text += "Blocker: " + AC_L5_MAIN_BLOCKER + "\r\n";

   text += "\r\nAdvisory Packet\r\n";
   text += "----------------------------------------\r\n";
   text += "Friction Advisory: not_implemented\r\n";
   text += "Volatility Advisory: not_implemented\r\n";
   text += "Structure Advisory: not_implemented\r\n";
   text += "Session Advisory: not_implemented\r\n";
   text += "Risk Advisory: not_implemented\r\n";
   text += "Invalidation / Kill Reason: not_implemented\r\n";

   text += "\r\nQuality\r\n";
   text += "----------------------------------------\r\n";
   text += "Deep Calculations Active: FALSE\r\n";
   text += "MT5 Heavy Calculation Active: FALSE\r\n";
   text += "Degraded Publication: TRUE\r\n";
   text += "Trade Permission: FALSE\r\n";
   text += "Ranking Runtime: FALSE\r\n";
   text += "Selection Runtime: FALSE\r\n";
   text += "Owner Boundary: Consumes L1-L4 owner gates and Runtime 3 accepted worker result only; does not recalculate or repeat earlier-layer truth.\r\n";
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
   return "schema_name=layer_status|schema_version=v5.2|layer_id=5|layer_name=" + AC_LAYER_5_NAME
      + "|source_owner=" + AC_RUNTIME5_OWNER
      + "|build_version=" + AC_BUILD_VERSION
      + "|upgrade_id=" + AC_UPGRADE_ID
      + "|layer_status=" + AC_L5_STATUS
      + "|trust_state=" + AC_L5_TRUST_STATE
      + "|readiness_state=" + AC_L5_READINESS_STATE
      + "|readiness_reason=" + AC_L5_READINESS_REASON
      + "|calculation_lane=" + AC_L5_CALCULATION_LANE
      + "|execution_owner=" + AC_L5_EXECUTION_OWNER
      + "|source_truth_owner=" + AC_L5_SOURCE_TRUTH_OWNER
      + "|runtime3_worker_required_for_deep_calculation=true"
      + "|runtime3_result_accepted=" + (AC_EXTERNAL_WORKER_STATUS.accepted_result ? "true" : "false")
      + "|runtime3_job_bus_status=" + AC_EXTERNAL_WORKER_STATUS.job_bus_status
      + "|owner_gate_summary=" + AC_L5LayerGateSummary()
      + "|eligible_gate_count=" + IntegerToString(AC_L5_ELIGIBLE_OPEN)
      + "|ready_symbols=" + IntegerToString(AC_L5_READY_SYMBOLS)
      + "|pending_symbols=" + IntegerToString(AC_L5_PENDING_SYMBOLS)
      + "|blocked_l2_gate=" + IntegerToString(AC_L5_BLOCKED_L2_GATE)
      + "|blocked_l3_gate=" + IntegerToString(AC_L5_BLOCKED_L3_GATE)
      + "|blocked_l4_gate=" + IntegerToString(AC_L5_BLOCKED_L4_GATE)
      + "|blocked_runtime3_gate=" + IntegerToString(AC_L5_BLOCKED_RUNTIME3_GATE)
      + "|blocked_no_eligible=" + IntegerToString(AC_L5_BLOCKED_NO_ELIGIBLE)
      + "|deep_packet_pending=" + IntegerToString(AC_L5_DEEP_PACKET_PENDING)
      + "|main_blocker=" + AC_L5_MAIN_BLOCKER
      + "|permission=false|ranking_runtime=false|selection_runtime=false|mt5_heavy_calculation_allowed=false";
}

#endif
