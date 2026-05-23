#ifndef AC_MARKET_BOARD_RENDERER_MQH
#define AC_MARKET_BOARD_RENDERER_MQH
string AC_BuildTraderBoardText(const AC_Runtime0Snapshot &snapshot,
                               const AC_Layer0StatusPacket &status)
{
   string text = "";
   text += "AURORA CORE - MARKET BOARD\r\n";
   text += "----------------------------------------\r\n";
   text += "State:            " + status.status + "\r\n";
   text += "Trust:            " + status.trust_state + "\r\n";
   text += "Trade Permission: FALSE\r\n";
   text += "Auto Trading:     FALSE\r\n";
   text += "\r\n";
   text += "DOSSIER COVERAGE\r\n";
   text += "----------------------------------------\r\n";
   text += "Broker Symbols Seen:    " + IntegerToString(status.broker_symbols_total) + "\r\n";
   text += "Dossiers Ready:         " + IntegerToString(status.dossier_shells_ready) + " / " + IntegerToString(status.broker_symbols_total) + "\r\n";
   text += "Dossiers Missing:       " + IntegerToString(status.dossier_shells_missing) + "\r\n";
   text += "Completion:             " + AC_PercentText(status.dossier_shells_ready, status.broker_symbols_total) + "\r\n";
   text += "Failed Dossiers:        " + IntegerToString(status.failed_symbol_count) + "\r\n";
   text += "Dossier Pass Duration:  " + IntegerToString((int)status.batch_duration_ms) + " ms\r\n";
   text += "\r\n";
   text += "CURRENT FOUNDATION + SURFACE SCORING\r\n";
   text += "----------------------------------------\r\n";
   text += "Layer 0: Publication + Dossier Foundation\r\n";
   text += "Layer 1: Account / Portfolio Truth\r\n";
   text += "Layer 2: Market Open / Closed Truth\r\n";
   text += "Layer 3: Broker Specs and Value Truth\r\n";
   text += "Layer 4: Live Quote and Spread Truth\r\n";
   text += "Layer 5: Basic System Gate\r\n";
   text += "Layer 6: Cost / Friction Ranking\r\n";
   text += AC_Layer1BoardSection();
   text += AC_Layer2BoardSection();
   text += AC_Layer3BoardSection();
   text += AC_Layer4BoardSection();
   text += AC_Layer5BoardSection();
   text += AC_Layer6BoardSection();
   text += AC_Layer7BoardSection();
   text += AC_SharedOhlcRenderBoardSection();
   text += "\r\nTRADING READINESS\r\n";
   text += "----------------------------------------\r\n";
   text += "Market State Known: " + ((AC_L2_OPEN_COUNT + AC_L2_CLOSED_COUNT) > 0 ? "Partial or Complete" : "No") + "\r\n";
   text += "Specs Known:        " + (AC_L3_READY ? "See Layer 3 readiness" : "No") + "\r\n";
   text += "Quotes Known:       " + (AC_L4_READY ? "See Layer 4 readiness" : "No") + "\r\n";
   text += "Cost Ranking:       " + AC_L6_STATUS + "\r\n";
   text += "OHLC Raw Store:     " + AC_SHARED_OHLC_STATUS + "\r\n";
   text += "Selection Active:   No\r\n";
   text += "Permission Active:  No\r\n";
   text += "\r\n";
   text += "TRUST BLOCKER\r\n";
   text += "----------------------------------------\r\n";
   text += status.main_blocker + "\r\n";
   text += "Layer 6 is ranking/scoring only; Layer 5 remains the only hard gate.\r\n";
   text += "Shared OHLC is raw storage only; no strategy, selection, or permission authority.\r\n";
   text += "\r\n";
   text += "ACTION\r\n";
   text += "----------------------------------------\r\n";
   text += "Board refresh is atomic and writes only when state text changes.\r\n";
   text += "No selection, alerts, or trade permission exists.\r\n";
   return text;
}

string AC_Layer0StatusRow(const AC_Layer0StatusPacket &status)
{
   return "schema_name=layer_status|schema_version=v0.12|layer_id=L0|layer_name=" + status.layer_name
      + "|source_owner=" + status.owner_name
      + "|status=" + status.status
      + "|trust_state=" + status.trust_state
      + "|broker_symbols_total=" + IntegerToString(status.broker_symbols_total)
      + "|marketwatch_symbols_total=" + IntegerToString(status.marketwatch_symbols_total)
      + "|dossier_shells_ready=" + IntegerToString(status.dossier_shells_ready)
      + "|dossier_shells_missing=" + IntegerToString(status.dossier_shells_missing)
      + "|failed_symbol_count=" + IntegerToString(status.failed_symbol_count)
      + "|retry_count_total=" + IntegerToString(status.retry_count_total)
      + "|completion=" + AC_PercentText(status.dossier_shells_ready, status.broker_symbols_total)
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
      + "|shared_ohlc_status=" + AC_SHARED_OHLC_STATUS
      + "|shared_ohlc_mode=" + AC_SHARED_OHLC_MODE
      + "|shared_ohlc_seed_complete=" + (AC_SHARED_OHLC_BOOT_SEED_COMPLETE ? "true" : "false")
      + "|main_blocker=" + status.main_blocker
      + "|trade_permission=false|ranking_runtime=" + (AC_L6_RANKED_ACCEPTED ? "true" : "false") + "|selection_runtime=false|market_state_known=" + (((AC_L2_OPEN_COUNT + AC_L2_CLOSED_COUNT) > 0) ? "true" : "false");
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
   text += "dossier_shells_ready=" + IntegerToString(status.dossier_shells_ready) + "\r\n";
   text += "dossier_shells_missing=" + IntegerToString(status.dossier_shells_missing) + "\r\n";
   text += "failed_symbol_count=" + IntegerToString(status.failed_symbol_count) + "\r\n";
   text += "retry_count_total=" + IntegerToString(status.retry_count_total) + "\r\n";
   text += "completion=" + AC_PercentText(status.dossier_shells_ready, status.broker_symbols_total) + "\r\n";
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
   text += "main_blocker=" + status.main_blocker + "\r\n";
   text += "first_failure=" + status.first_failure + "\r\n";
   text += "statistics_owner=layer_owner_packet_not_board_calculation\r\n";
   text += "gateway=used_for_L6_cost_friction_ranking_only_not_for_L0_L1_L2_L3_L4_or_L5\r\n";
   text += "mt5_script_worker=not_used_for_runtime_board_stats\r\n";
   text += "\r\n" + AC_Layer1WorkbenchSection();
   text += AC_Layer2WorkbenchSection();
   text += AC_Layer3WorkbenchSection();
   text += AC_Layer4WorkbenchSection();
   text += AC_Layer5WorkbenchSection();
   text += AC_Layer6WorkbenchSection();
   text += AC_Layer7WorkbenchSection();
   text += "\r\n" + AC_SharedOhlcRenderWorkbenchSection();
   return text;
}

string AC_Layer0FailureAddendumText()
{
   string text = "";
   text += "L0_L2_L3_L4_L5_L6_FAILED_SYMBOL_PACKET_ADDENDUM\r\n";
   text += "----------------------------------------\r\n";
   if(AC_L0_FAILURE_ADDENDUM == "") text += "none\r\n";
   else text += AC_L0_FAILURE_ADDENDUM;
   return text;
}

#endif