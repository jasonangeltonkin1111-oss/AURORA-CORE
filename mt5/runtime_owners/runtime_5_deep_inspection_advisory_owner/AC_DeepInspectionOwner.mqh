#ifndef AC_DEEP_INSPECTION_OWNER_MQH
#define AC_DEEP_INSPECTION_OWNER_MQH

// Runtime 5 / Deep Inspection Advisory Owner.
// First pass: status and publication shell only.
// No broker ownership, no FileIO ownership, no ranking, no selection, no execution.

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
   else
      AC_L5_MAIN_BLOCKER = "Layer 5 advisory calculations not implemented yet; degraded shell published";

   AC_L5_BOARD_SECTION = "\r\nLAYER 5 - DEEP INSPECTION ADVISORY\r\n";
   AC_L5_BOARD_SECTION += "----------------------------------------\r\n";
   AC_L5_BOARD_SECTION += "Status:            " + AC_L5_STATUS + "\r\n";
   AC_L5_BOARD_SECTION += "Trust:             " + AC_L5_TRUST_STATE + "\r\n";
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
   AC_L5_WORKBENCH_SECTION += "eligible_open=" + IntegerToString(AC_L5_ELIGIBLE_OPEN) + "\r\n";
   AC_L5_WORKBENCH_SECTION += "ready_symbols=" + IntegerToString(AC_L5_READY_SYMBOLS) + "\r\n";
   AC_L5_WORKBENCH_SECTION += "pending_symbols=" + IntegerToString(AC_L5_PENDING_SYMBOLS) + "\r\n";
   AC_L5_WORKBENCH_SECTION += "main_blocker=" + AC_L5_MAIN_BLOCKER + "\r\n";
   AC_L5_WORKBENCH_SECTION += "inputs_consumed=L1_L2_L3_L4_status_only_first_pass\r\n";
   AC_L5_WORKBENCH_SECTION += "outputs_published=dossier_section_shell_board_summary_workbench_status_row\r\n";
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
   text += "Degraded Publication: TRUE\r\n";
   text += "Deep Calculations Active: FALSE\r\n";
   text += "Permission: FALSE\r\n";
   text += "Ranking: FALSE\r\n";
   text += "Selection: FALSE\r\n";
   text += "Owner Boundary: Runtime 5 advisory shell only; L1-L4 remain source truth.\r\n";
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
      + "|eligible_open=" + IntegerToString(AC_L5_ELIGIBLE_OPEN)
      + "|ready_symbols=" + IntegerToString(AC_L5_READY_SYMBOLS)
      + "|pending_symbols=" + IntegerToString(AC_L5_PENDING_SYMBOLS)
      + "|main_blocker=" + AC_L5_MAIN_BLOCKER
      + "|permission=false|ranking_runtime=false|selection_runtime=false";
}

#endif
