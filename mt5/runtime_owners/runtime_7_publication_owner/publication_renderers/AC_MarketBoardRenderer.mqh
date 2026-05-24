#ifndef AC_MARKET_BOARD_RENDERER_MQH
#define AC_MARKET_BOARD_RENDERER_MQH

string AC_BoardHealthTag(const string status)
{
   if(StringFind(status, "Accepted") >= 0 || StringFind(status, "accepted") >= 0 ||
      StringFind(status, "Complete") >= 0 || StringFind(status, "complete") >= 0 ||
      StringFind(status, "Ready") >= 0 || StringFind(status, "ready") >= 0)
      return "OK";
   if(StringFind(status, "Drift") >= 0 || StringFind(status, "drift") >= 0)
      return "DRIFT";
   if(StringFind(status, "Degraded") >= 0 || StringFind(status, "degraded") >= 0 ||
      StringFind(status, "Expired") >= 0 || StringFind(status, "expired") >= 0)
      return "DEGRADED";
   if(StringFind(status, "Pending") >= 0 || StringFind(status, "pending") >= 0)
      return "PENDING";
   if(StringFind(status, "Review") >= 0 || StringFind(status, "review") >= 0 ||
      StringFind(status, "warning") >= 0 || StringFind(status, "Warning") >= 0)
      return "REVIEW";
   if(StringFind(status, "seed") >= 0 || StringFind(status, "Seed") >= 0)
      return "SEEDING";
   return "CHECK";
}

string AC_BoardWarningText()
{
   string text = "";
   if(AC_L6_STATUS != "Accepted") text += "L6=" + AC_L6_STATUS + "; ";
   if(AC_L7_STATUS != "Accepted") text += "L7=" + AC_L7_STATUS + "; ";
   if(AC_L8_STATUS != "Accepted") text += "L8=" + AC_L8_STATUS + "; ";
   if(AC_L9_STATUS != "Accepted") text += "L9=" + AC_L9_STATUS + "; ";
   if(AC_L15_STATUS != "Accepted") text += "L15=" + AC_L15_STATUS + "; ";
   if(text == "") return "none";
   return text;
}

string AC_BoardHeaderSection(const AC_Layer0StatusPacket &status)
{
   string text = "";
   text += "AURORA CORE - MARKET BOARD\r\n";
   text += "==================================================\r\n";
   text += "State:            " + status.status + "\r\n";
   text += "Trust:            " + status.trust_state + "\r\n";
   text += "Trade Permission: FALSE\r\n";
   text += "Auto Trading:     FALSE\r\n";
   return text;
}

string AC_BoardSystemCockpitSection(const AC_Layer0StatusPacket &status)
{
   string text = "";
   text += "\r\nSYSTEM COCKPIT\r\n";
   text += "--------------------------------------------------\r\n";
   text += "Runtime Mode:        Publication + inspection ranking\r\n";
   text += "Selection Stage:     L15 correlation/diversity scoring only\r\n";
   text += "Permission Stage:    Not active\r\n";
   text += "Primary Warning:     " + AC_BoardWarningText() + "\r\n";
   text += "Main Blocker:        " + status.main_blocker + "\r\n";
   return text;
}

string AC_BoardOperatorActionSection()
{
   string text = "";
   text += "\r\nOPERATOR ACTION VIEW\r\n";
   text += "--------------------------------------------------\r\n";
   text += "Use For Trading:      NO\r\n";
   text += "Use For Inspection:   YES\r\n";
   text += "Use For Selection:    L15 scoring only; no Global Top 10 yet\r\n";
   text += "Best Current Use:     Review candidate quality, degradation, and L15 diversity constraints\r\n";
   text += "Do Not Do:            No trade, no alert, no execution, no prop-firm safety claim\r\n";
   return text;
}

string AC_BoardUniverseSnapshotSection(const AC_Layer0StatusPacket &status)
{
   string text = "";
   text += "\r\nUNIVERSE SNAPSHOT\r\n";
   text += "--------------------------------------------------\r\n";
   text += "Broker Symbols Seen:       " + IntegerToString(status.broker_symbols_total) + "\r\n";
   text += "Dossier Generation:        " + IntegerToString(status.dossier_shells_ready) + " / " + IntegerToString(status.broker_symbols_total) + " = " + AC_PercentText(status.dossier_shells_ready, status.broker_symbols_total) + "\r\n";
   text += "Open / Closed Known:       " + IntegerToString(AC_L2_OPEN_COUNT) + " / " + IntegerToString(AC_L2_CLOSED_COUNT) + "\r\n";
   text += "L5 Pass / Blocked:         " + IntegerToString(AC_L5_GATE_PASS) + " / " + IntegerToString(AC_L5_GATE_BLOCKED) + "\r\n";
   text += "L14 Candidate Pool:        " + IntegerToString(AC_L14_CANDIDATE_POOL_SIZE) + "\r\n";
   text += "L14 Top Candidate:         " + AC_L14_TOP_CANDIDATE + "\r\n";
   text += "L15 Candidates Scored:     " + IntegerToString(AC_L15_CANDIDATE_SCORED_COUNT) + "\r\n";
   text += "L15 Top Diversity:         " + AC_L15_TOP_DIVERSITY_CANDIDATE + "\r\n";
   return text;
}

string AC_BoardLayerHealthMatrixSection(const AC_Layer0StatusPacket &status)
{
   string text = "";
   text += "\r\nLAYER HEALTH MATRIX\r\n";
   text += "--------------------------------------------------\r\n";
   text += "L0   Publication / Dossier       " + AC_BoardHealthTag(status.status) + "   " + IntegerToString(status.dossier_shells_ready) + "/" + IntegerToString(status.broker_symbols_total) + " generated\r\n";
   text += "L1   Account / Portfolio         " + (AC_L1_READY ? "OK" : "PENDING") + "   " + (AC_L1_READY ? "available" : "pending") + "\r\n";
   text += "L2   Market Open / Closed        " + AC_BoardHealthTag(AC_L2_SCAN_STATUS) + "   open " + IntegerToString(AC_L2_OPEN_COUNT) + " / closed " + IntegerToString(AC_L2_CLOSED_COUNT) + "\r\n";
   text += "L3   Broker Specs / Value        " + AC_BoardHealthTag(AC_L3_SCAN_STATUS) + "   " + AC_L3_SCAN_STATUS + "\r\n";
   text += "L4   Quote / Spread              " + AC_BoardHealthTag(AC_L4_SCAN_STATUS) + "   " + AC_L4_SCAN_STATUS + "\r\n";
   text += "L5   Basic System Gate           " + AC_BoardHealthTag(AC_L5_STATUS) + "   pass " + IntegerToString(AC_L5_GATE_PASS) + " / blocked " + IntegerToString(AC_L5_GATE_BLOCKED) + "\r\n";
   text += "L6   Cost / Friction             " + AC_BoardHealthTag(AC_L6_STATUS) + "   " + AC_L6_STATUS + "\r\n";
   text += "L7   Session Relevance           " + AC_BoardHealthTag(AC_L7_STATUS) + "   " + AC_L7_STATUS + "\r\n";
   text += "L8   Movement / Range            " + AC_BoardHealthTag(AC_L8_STATUS) + "   " + AC_L8_STATUS + "\r\n";
   text += "L9   Structure / Location        " + AC_BoardHealthTag(AC_L9_STATUS) + "   " + AC_L9_STATUS + "\r\n";
   text += "L10  Taxonomy / Ranking Group    " + AC_BoardHealthTag(AC_L10_STATUS) + "   " + AC_L10_STATUS + "\r\n";
   text += "L11  Symbol Rank in Group        " + AC_BoardHealthTag(AC_L11_STATUS) + "   " + AC_L11_STATUS + "\r\n";
   text += "L12  Group Heat / Quality        " + AC_BoardHealthTag(AC_L12_STATUS) + "   " + AC_L12_STATUS + "\r\n";
   text += "L13  Group Selection             " + AC_BoardHealthTag(AC_L13_STATUS) + "   " + AC_L13_STATUS + "\r\n";
   text += "L14  Candidate Pool              " + AC_BoardHealthTag(AC_L14_STATUS) + "   " + AC_L14_STATUS + "\r\n";
   text += "L15  Correlation / Diversity     " + AC_BoardHealthTag(AC_L15_STATUS) + "   " + AC_L15_STATUS + "\r\n";
   text += "OHLC Shared Raw Store            " + AC_BoardHealthTag(AC_SHARED_OHLC_STATUS) + "   " + AC_SHARED_OHLC_STATUS + "\r\n";
   return text;
}

string AC_BoardSurfaceScoringSnapshotSection()
{
   string text = "";
   text += "\r\nSURFACE SCORING SNAPSHOT\r\n";
   text += "--------------------------------------------------\r\n";
   text += "Layer 6 Cost/Friction:       " + AC_L6_STATUS + "\r\n";
   text += "Layer 7 Session Relevance:   " + AC_L7_STATUS + "\r\n";
   text += "Layer 8 Movement/Range:      " + AC_L8_STATUS + "\r\n";
   text += "Layer 9 Structure/Location:  " + AC_L9_STATUS + "\r\n";
   text += "Meaning:                    ranking/inspection only; no direction, setup, alert, or permission\r\n";
   return text;
}

string AC_BoardSelectionPipelineSnapshotSection()
{
   string text = "";
   text += "\r\nSELECTION PIPELINE SNAPSHOT\r\n";
   text += "--------------------------------------------------\r\n";
   text += "L10 Taxonomy:             " + AC_L10_STATUS + "\r\n";
   text += "L11 Intra-group Ranking:  " + AC_L11_STATUS + "\r\n";
   text += "L12 Group Heat/Quality:   " + AC_L12_STATUS + "\r\n";
   text += "L13 Group Selection:      " + AC_L13_STATUS + "\r\n";
   text += "L14 Candidate Pool:       " + AC_L14_STATUS + " | size=" + IntegerToString(AC_L14_CANDIDATE_POOL_SIZE) + "\r\n";
   text += "L15 Correlation Filter:   " + AC_L15_STATUS + " | scored=" + IntegerToString(AC_L15_CANDIDATE_SCORED_COUNT) + " | high_corr_pairs=" + IntegerToString(AC_L15_HIGH_CORR_PAIR_COUNT) + "\r\n";
   text += "L16 Global Top 10:        not built / not active here\r\n";
   text += "L23 Trade Permission:     false\r\n";
   text += "Pipeline Meaning:         inspection candidates only; no Global Top 10, alert, or trade permission\r\n";
   return text;
}

string AC_BoardDegradationSnapshotSection(const AC_Layer0StatusPacket &status)
{
   string text = "";
   text += "\r\nDEGRADATION / BLOCKER SNAPSHOT\r\n";
   text += "--------------------------------------------------\r\n";
   text += "Hard Trading Block:        permission system not active\r\n";
   text += "Main Runtime Blocker:      " + status.main_blocker + "\r\n";
   text += "Surface Warnings:          " + AC_BoardWarningText() + "\r\n";
   text += "L15 Threshold Status:      " + AC_L15_THRESHOLD_STATUS + "\r\n";
   text += "Max Pair Corr Abs:         " + AC_L15_MAX_PAIR_CORR_ABS + "\r\n";
   text += "Safety Meaning:            publication and inspection may continue; trading remains blocked\r\n";
   return text;
}

string AC_BoardDossierCoverageSection(const AC_Layer0StatusPacket &status)
{
   string text = "";
   text += "\r\nDOSSIER COVERAGE\r\n";
   text += "--------------------------------------------------\r\n";
   text += "Broker Symbols Seen:        " + IntegerToString(status.broker_symbols_total) + "\r\n";
   text += "Current Generation Updated: " + IntegerToString(status.dossier_shells_ready) + " / " + IntegerToString(status.broker_symbols_total) + "\r\n";
   text += "Current Generation Left:    " + IntegerToString(status.dossier_shells_missing) + "\r\n";
   text += "Generation Progress:        " + AC_PercentText(status.dossier_shells_ready, status.broker_symbols_total) + "\r\n";
   text += "Physical Missing:           not_reconciled_by_this_counter\r\n";
   text += "Counter Truth:              ready/left counts are current-generation refresh progress, not physical file count\r\n";
   text += "Failed Current Writes:      " + IntegerToString(status.failed_symbol_count) + "\r\n";
   text += "Dossier Pass Duration:      " + IntegerToString((int)status.batch_duration_ms) + " ms\r\n";
   return text;
}

string AC_BoardTradingReadinessSection()
{
   string text = "";
   text += "\r\nTRADING READINESS\r\n";
   text += "--------------------------------------------------\r\n";
   text += "Market State Known: " + ((AC_L2_OPEN_COUNT + AC_L2_CLOSED_COUNT) > 0 ? "Partial or Complete" : "No") + "\r\n";
   text += "Specs Known:        " + (AC_L3_READY ? "See Layer 3 readiness" : "No") + "\r\n";
   text += "Quotes Known:       " + (AC_L4_READY ? "See Layer 4 readiness" : "No") + "\r\n";
   text += "Cost Ranking:       " + AC_L6_STATUS + "\r\n";
   text += "Session Ranking:    " + AC_L7_STATUS + "\r\n";
   text += "Movement Ranking:   " + AC_L8_STATUS + "\r\n";
   text += "Structure Ranking:  " + AC_L9_STATUS + "\r\n";
   text += "Taxonomy Map:       " + AC_L10_STATUS + "\r\n";
   text += "Symbol Ranking:     " + AC_L11_STATUS + "\r\n";
   text += "Group Heat Quality: " + AC_L12_STATUS + "\r\n";
   text += "Group Selection:    " + AC_L13_STATUS + "\r\n";
   text += "Candidate Pool:     " + AC_L14_STATUS + "\r\n";
   text += "Correlation/Diversity: " + AC_L15_STATUS + "\r\n";
   text += "OHLC Raw Store:     " + AC_SHARED_OHLC_STATUS + "\r\n";
   text += "Selection Active:   L15 scoring only; no Global Top 10 or trade permission\r\n";
   text += "Permission Active:  No\r\n";
   return text;
}

string AC_BoardTrustBlockerSection(const AC_Layer0StatusPacket &status)
{
   string text = "";
   text += "\r\nTRUST BLOCKER\r\n";
   text += "--------------------------------------------------\r\n";
   text += status.main_blocker + "\r\n";
   text += "Layer 6-9 are ranking/scoring only; Layer 10 is taxonomy/ranking_group map only; Layer 11 is intra-group inspection priority only; Layer 12 is group heat/quality only; Layer 13 selects groups for attention only; Layer 14 builds a raw candidate pool only; Layer 15 scores correlation/diversity only; Layer 5 remains the only hard gate.\r\n";
   text += "Shared OHLC is raw storage only; no strategy, selection, or permission authority.\r\n";
   return text;
}

string AC_BoardActionSection()
{
   string text = "";
   text += "\r\nACTION\r\n";
   text += "--------------------------------------------------\r\n";
   text += "Board refresh is atomic and writes only when state text changes.\r\n";
   text += "L15 may constrain later L16 inspection selection; no Global Top 10, alerts, or trade permission exists.\r\n";
   return text;
}

string AC_BuildTraderBoardText(const AC_Runtime0Snapshot &snapshot,
                               const AC_Layer0StatusPacket &status)
{
   // Build existing layer detail first. These existing owner sections refresh their own packets/sidecars.
   // The top-view that follows reads those owner fields; it does not create a second refresh/scoring owner.
   string l1 = AC_Layer1BoardSection();
   string l2 = AC_Layer2BoardSection();
   string l3 = AC_Layer3BoardSection();
   string l4 = AC_Layer4BoardSection();
   string l5 = AC_Layer5BoardSection();
   string l6 = AC_Layer6BoardSection();
   string l7 = AC_Layer7BoardSection();
   string l8 = AC_Layer8BoardSection();
   string l9 = AC_Layer9BoardSection();
   string l10 = AC_Layer10BoardSection();
   string l11 = AC_Layer11BoardSection();
   string l12 = AC_Layer12BoardSection();
   string l13 = AC_Layer13BoardSection();
   string l14 = AC_Layer14BoardSection();
   string l15 = AC_Layer15BoardSection();
   string ohlc = AC_SharedOhlcRenderBoardSection();

   string text = "";
   text += AC_BoardHeaderSection(status);
   text += AC_BoardSystemCockpitSection(status);
   text += AC_BoardOperatorActionSection();
   text += AC_BoardUniverseSnapshotSection(status);
   text += AC_BoardLayerHealthMatrixSection(status);
   text += AC_BoardSurfaceScoringSnapshotSection();
   text += AC_BoardSelectionPipelineSnapshotSection();
   text += AC_BoardDegradationSnapshotSection(status);
   text += AC_BoardDossierCoverageSection(status);
   text += "\r\nFULL LAYER DETAIL\r\n";
   text += "==================================================\r\n";
   text += l1;
   text += l2;
   text += l3;
   text += l4;
   text += l5;
   text += l6;
   text += l7;
   text += l8;
   text += l9;
   text += l10;
   text += l11;
   text += l12;
   text += l13;
   text += l14;
   text += l15;
   text += ohlc;
   text += AC_BoardTradingReadinessSection();
   text += AC_BoardTrustBlockerSection(status);
   text += AC_BoardActionSection();
   return text;
}

string AC_Layer0StatusRow(const AC_Layer0StatusPacket &status)
{
   return "schema_name=layer_status|schema_version=v0.17|layer_id=L0|layer_name=" + status.layer_name
      + "|source_owner=" + status.owner_name
      + "|status=" + status.status
      + "|trust_state=" + status.trust_state
      + "|broker_symbols_total=" + IntegerToString(status.broker_symbols_total)
      + "|marketwatch_symbols_total=" + IntegerToString(status.marketwatch_symbols_total)
      + "|dossier_current_generation_updated=" + IntegerToString(status.dossier_shells_ready)
      + "|dossier_current_generation_left=" + IntegerToString(status.dossier_shells_missing)
      + "|dossier_physical_missing=not_reconciled_by_generation_counter"
      + "|dossier_counter_truth=current_generation_progress_not_physical_file_count"
      + "|failed_current_write_count=" + IntegerToString(status.failed_symbol_count)
      + "|retry_count_total=" + IntegerToString(status.retry_count_total)
      + "|generation_progress=" + AC_PercentText(status.dossier_shells_ready, status.broker_symbols_total)
      + "|pass_start_index=" + IntegerToString(status.batch_start_index)
      + "|pass_end_index=" + IntegerToString(status.batch_end_index)
      + "|symbols_attempted=" + IntegerToString(status.batch_attempted)
      + "|symbols_written=" + IntegerToString(status.batch_written)
      + "|pass_duration_ms=" + IntegerToString((int)status.batch_duration_ms)
      + "|cached_pass_valid=" + (AC_L0_CACHED_PASS_VALID ? "true" : "false")
      + "|dossier_shell_schema_version=" + AC_DOSSIER_SHELL_SCHEMA_VERSION
      + "|cached_dossier_shell_schema_version=" + AC_L0_CACHED_DOSSIER_SCHEMA_VERSION
      + "|cached_l2_route_generation_key=" + AC_L0_CACHED_L2_ROUTE_GENERATION_KEY
      + "|cached_l3_cache_key=" + AC_L0_CACHED_L3_CACHE_KEY
      + "|cached_l4_cache_key=" + AC_L0_CACHED_L4_CACHE_KEY
      + "|cached_l4_refresh_key=" + AC_L0_CACHED_L4_REFRESH_KEY
      + "|cached_l5_status=" + AC_L0_CACHED_L5_STATUS
      + "|cached_l6_status=" + AC_L0_CACHED_L6_STATUS
      + "|cached_l6_checksum=" + AC_L0_CACHED_L6_CHECKSUM
      + "|cached_l7_status=" + AC_L0_CACHED_L7_STATUS
      + "|cached_l8_status=" + AC_L0_CACHED_L8_STATUS
      + "|cached_l10_status=" + AC_L10_STATUS
      + "|cached_l11_status=" + AC_L11_STATUS
      + "|cached_l12_status=" + AC_L12_STATUS
      + "|cached_l13_status=" + AC_L13_STATUS
      + "|cached_l14_status=" + AC_L14_STATUS
      + "|cached_l15_status=" + AC_L15_STATUS
      + "|shared_ohlc_status=" + AC_SHARED_OHLC_STATUS
      + "|shared_ohlc_mode=" + AC_SHARED_OHLC_MODE
      + "|shared_ohlc_seed_complete=" + (AC_SHARED_OHLC_BOOT_SEED_COMPLETE ? "true" : "false")
      + "|main_blocker=" + status.main_blocker
      + "|trade_permission=false|ranking_runtime=" + ((AC_L6_RANKED_ACCEPTED || AC_L7_RANKED_ACCEPTED || AC_L8_RANKED_ACCEPTED || AC_L9_RANKED_ACCEPTED || AC_L10_ACCEPTED || AC_L11_ACCEPTED || AC_L12_ACCEPTED || AC_L13_ACCEPTED || AC_L14_ACCEPTED || AC_L15_ACCEPTED) ? "true" : "false") + "|selection_runtime=false|market_state_known=" + (((AC_L2_OPEN_COUNT + AC_L2_CLOSED_COUNT) > 0) ? "true" : "false");
}

string AC_Layer0WorkbenchText(const AC_Layer0StatusPacket &status)
{
   string text = "";
   text += "L0_BOARD_DOSSIER_FOUNDATION\r\n";
   text += "----------------------------------------\r\n";
   text += "layer_id=L0\r\n";
   text += "layer_name=" + status.layer_name + "\r\n";
   text += "owner_name=" + status.owner_name + "\r\n";
   text += "status=" + status.status + "\r\n";
   text += "trust_state=" + status.trust_state + "\r\n";
   text += "broker_symbols_total=" + IntegerToString(status.broker_symbols_total) + "\r\n";
   text += "marketwatch_symbols_total=" + IntegerToString(status.marketwatch_symbols_total) + "\r\n";
   text += "dossier_current_generation_updated=" + IntegerToString(status.dossier_shells_ready) + "\r\n";
   text += "dossier_current_generation_left=" + IntegerToString(status.dossier_shells_missing) + "\r\n";
   text += "dossier_physical_missing=not_reconciled_by_generation_counter\r\n";
   text += "dossier_counter_truth=current_generation_progress_not_physical_file_count\r\n";
   text += "failed_current_write_count=" + IntegerToString(status.failed_symbol_count) + "\r\n";
   text += "retry_count_total=" + IntegerToString(status.retry_count_total) + "\r\n";
   text += "generation_progress=" + AC_PercentText(status.dossier_shells_ready, status.broker_symbols_total) + "\r\n";
   text += "pass_start_index=" + IntegerToString(status.batch_start_index) + "\r\n";
   text += "pass_end_index=" + IntegerToString(status.batch_end_index) + "\r\n";
   text += "symbols_attempted=" + IntegerToString(status.batch_attempted) + "\r\n";
   text += "symbols_written=" + IntegerToString(status.batch_written) + "\r\n";
   text += "pass_duration_ms=" + IntegerToString((int)status.batch_duration_ms) + "\r\n";
   text += "cached_pass_valid=" + (AC_L0_CACHED_PASS_VALID ? "true" : "false") + "\r\n";
   text += "dossier_shell_schema_version=" + AC_DOSSIER_SHELL_SCHEMA_VERSION + "\r\n";
   text += "cached_dossier_shell_schema_version=" + AC_L0_CACHED_DOSSIER_SCHEMA_VERSION + "\r\n";
   text += "l2_route_generation_key=" + AC_L2_ROUTE_GENERATION_KEY + "\r\n";
   text += "cached_l2_route_generation_key=" + AC_L0_CACHED_L2_ROUTE_GENERATION_KEY + "\r\n";
   text += "l3_cache_key=" + AC_L3_CACHE_KEY + "\r\n";
   text += "cached_l3_cache_key=" + AC_L0_CACHED_L3_CACHE_KEY + "\r\n";
   text += "l4_cache_key=" + AC_L4_CACHE_KEY + "\r\n";
   text += "l4_refresh_key=" + AC_L4_REFRESH_KEY + "\r\n";
   text += "cached_l4_cache_key=" + AC_L0_CACHED_L4_CACHE_KEY + "\r\n";
   text += "cached_l4_refresh_key=" + AC_L0_CACHED_L4_REFRESH_KEY + "\r\n";
   text += "cached_l5_status=" + AC_L0_CACHED_L5_STATUS + "\r\n";
   text += "cached_l6_status=" + AC_L0_CACHED_L6_STATUS + "\r\n";
   text += "cached_l6_checksum=" + AC_L0_CACHED_L6_CHECKSUM + "\r\n";
   text += "cached_l7_status=" + AC_L0_CACHED_L7_STATUS + "\r\n";
   text += "cached_l8_status=" + AC_L0_CACHED_L8_STATUS + "\r\n";
   text += "cached_l9_status=" + AC_L9_STATUS + "\r\n";
   text += "cached_l10_status=" + AC_L10_STATUS + "\r\n";
   text += "cached_l11_status=" + AC_L11_STATUS + "\r\n";
   text += "cached_l12_status=" + AC_L12_STATUS + "\r\n";
   text += "cached_l13_status=" + AC_L13_STATUS + "\r\n";
   text += "cached_l14_status=" + AC_L14_STATUS + "\r\n";
   text += "cached_l15_status=" + AC_L15_STATUS + "\r\n";
   text += "main_blocker=" + status.main_blocker + "\r\n";
   text += "first_failure=" + status.first_failure + "\r\n";
   text += "statistics_owner=layer_owner_packet_not_board_calculation\r\n";
   text += "gateway=used_for_L6_L7_L8_L9_L10_L11_L12_L13_L14_L15_surface_taxonomy_ranking_group_selection_candidate_pool_correlation_only_not_for_L0_L1_L2_L3_L4_or_L5\r\n";
   text += "mt5_script_worker=not_used_for_runtime_board_stats\r\n";
   text += "\r\n" + AC_Layer1WorkbenchSection();
   text += AC_Layer2WorkbenchSection();
   text += AC_Layer3WorkbenchSection();
   text += AC_Layer4WorkbenchSection();
   text += AC_Layer5WorkbenchSection();
   text += AC_Layer6WorkbenchSection();
   text += AC_Layer7WorkbenchSection();
   text += AC_Layer8WorkbenchSection();
   text += AC_Layer9WorkbenchSection();
   text += AC_Layer10WorkbenchSection();
   text += AC_Layer11WorkbenchSection();
   text += AC_Layer12WorkbenchSection();
   text += AC_Layer13WorkbenchSection();
   text += AC_Layer14WorkbenchSection();
   text += AC_Layer15WorkbenchSection();
   text += "\r\n" + AC_SharedOhlcRenderWorkbenchSection();
   return text;
}

string AC_Layer0FailureAddendumText()
{
   string text = "";
   text += "L0_L2_L3_L4_L5_L6_L7_L8_L9_L10_L11_L12_L13_L14_L15_FAILED_SYMBOL_PACKET_ADDENDUM\r\n";
   text += "----------------------------------------\r\n";
   if(AC_L0_FAILURE_ADDENDUM == "") text += "none\r\n";
   else text += AC_L0_FAILURE_ADDENDUM;
   return text;
}

#endif