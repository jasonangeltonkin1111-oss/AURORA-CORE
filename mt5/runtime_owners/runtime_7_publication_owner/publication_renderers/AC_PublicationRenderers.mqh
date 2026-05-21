#ifndef AC_PUBLICATION_RENDERERS_MQH
#define AC_PUBLICATION_RENDERERS_MQH

// Board / Dossier Renderer Service.
// Renders prepared owner/status packets only. It must not compute trading truth,
// ranking, selection, market-open state, broker specs, quotes, or permission.

static int    AC_L0_LAST_SYMBOLS_TOTAL = -1;
static int    AC_L0_NEXT_SYMBOL_INDEX = 0;
static int    AC_L0_SHELLS_WRITTEN = 0;
static string AC_L0_FIRST_FAILURE = "";

string AC_PercentText(const int complete_count, const int total_count)
{
   if(total_count <= 0)
      return "not_available";
   double pct = ((double)complete_count * 100.0) / (double)total_count;
   return StringFormat("%.1f%%", pct);
}

void AC_Layer0InitStatus(AC_Layer0StatusPacket &status)
{
   status.layer_id = "L0";
   status.layer_name = AC_LAYER_0_BOARD_DOSSIER_NAME;
   status.owner_name = AC_BOARD_DOSSIER_RENDERER_OWNER;
   status.status = "not_started";
   status.trust_state = "NOT_READY";
   status.main_blocker = "dossier_shell_coverage_not_started";
   status.broker_symbols_total = 0;
   status.marketwatch_symbols_total = 0;
   status.dossier_shells_ready = 0;
   status.dossier_shells_missing = 0;
   status.batch_start_index = 0;
   status.batch_end_index = -1;
   status.batch_attempted = 0;
   status.batch_written = 0;
   status.next_symbol_index = 0;
   status.batch_duration_ms = 0;
   status.batch_complete = false;
   status.trade_permission = false;
   status.auto_trade_allowed = false;
   status.ranking_runtime = false;
   status.selection_runtime = false;
   status.market_state_known = false;
   status.specs_known = false;
   status.quotes_known = false;
   status.first_failure = "";
}

string AC_BuildLayer0DossierShellText(const string symbol,
                                      const int broker_index,
                                      const AC_Layer0StatusPacket &status)
{
   string text = "";
   text += "AURORA CORE - SYMBOL DOSSIER\r\n";
   text += "----------------------------------------\r\n";
   text += "symbol=" + symbol + "\r\n";
   text += "broker_symbol=" + symbol + "\r\n";
   text += "canonical_symbol=pending\r\n";
   text += "folder_state=Unknown\r\n";
   text += "dossier_state=L0_FOUNDATION_SHELL\r\n";
   text += "trust_state=INCOMPLETE\r\n";
   text += "trade_permission=false\r\n";
   text += "auto_trade_allowed=false\r\n";
   text += "generated_at=" + AC_NowText() + "\r\n";
   text += "server=" + AC_ServerNameForRoute() + "\r\n";
   text += "account=" + AC_AccountForRoute() + "\r\n";
   text += "\r\n";
   text += "LAYER 0 - PUBLICATION FOUNDATION\r\n";
   text += "----------------------------------------\r\n";
   text += "dossier_shell=written\r\n";
   text += "symbol_source=broker_symbol_enumeration\r\n";
   text += "broker_symbol_index=" + IntegerToString(broker_index) + "\r\n";
   text += "route=" + AC_DossierUnknownSymbolPath(symbol) + "\r\n";
   text += "publication_state=shell_only\r\n";
   text += "renderer_owner=" + AC_BOARD_DOSSIER_RENDERER_OWNER + "\r\n";
   text += "fileio_owner=" + AC_PUBLICATION_SERVICE_OWNER + "\r\n";
   text += "\r\n";
   text += "LAYER PROGRESS\r\n";
   text += "----------------------------------------\r\n";
   text += "L0_publication=complete\r\n";
   text += "L1_account_truth=pending\r\n";
   text += "L2_open_closed_truth=pending\r\n";
   text += "L3_broker_specs=pending\r\n";
   text += "L4_market_watch=pending\r\n";
   text += "L5_basic_gate=pending\r\n";
   text += "L6_L23=inactive\r\n";
   text += "\r\n";
   text += "KNOWN_AT_LAYER_0\r\n";
   text += "----------------------------------------\r\n";
   text += "broker_symbol_exists=true\r\n";
   text += "dossier_shell_created=true\r\n";
   text += "market_state_known=false\r\n";
   text += "broker_specs_known=false\r\n";
   text += "quote_truth_known=false\r\n";
   text += "taxonomy_attached=false\r\n";
   text += "ranking_runtime=false\r\n";
   text += "selection_runtime=false\r\n";
   text += "permission_runtime=false\r\n";
   text += "\r\n";
   text += "NEXT_REQUIRED\r\n";
   text += "----------------------------------------\r\n";
   text += "next_needed_truth=Layer 1 account truth and Layer 2 open/closed truth later\r\n";
   text += "open_closed_owner=Layer 2 only; not measured by Layer 0\r\n";
   text += "\r\n";
   text += "NO_GO\r\n";
   text += "----------------------------------------\r\n";
   text += "not_open=true\r\n";
   text += "not_closed=true\r\n";
   text += "not_tradable=true\r\n";
   text += "not_ranked=true\r\n";
   text += "not_selected=true\r\n";
   text += "no_alert=true\r\n";
   text += "no_permission=true\r\n";
   text += "\r\n";
   text += "L0_UNIVERSE_PROGRESS_SNAPSHOT\r\n";
   text += "----------------------------------------\r\n";
   text += "broker_symbols_seen=" + IntegerToString(status.broker_symbols_total) + "\r\n";
   text += "dossier_shells_ready=" + IntegerToString(status.dossier_shells_ready) + "\r\n";
   text += "dossier_shells_missing=" + IntegerToString(status.dossier_shells_missing) + "\r\n";
   text += "completion=" + AC_PercentText(status.dossier_shells_ready, status.broker_symbols_total) + "\r\n";
   return text;
}

AC_WriteResult AC_PublishLayer0DossierBatch(AC_Layer0StatusPacket &status)
{
   AC_Layer0InitStatus(status);

   uint start_ms = GetTickCount();
   int total = SymbolsTotal(false);
   int marketwatch_total = SymbolsTotal(true);

   if(total != AC_L0_LAST_SYMBOLS_TOTAL)
   {
      AC_L0_LAST_SYMBOLS_TOTAL = total;
      AC_L0_NEXT_SYMBOL_INDEX = 0;
      AC_L0_SHELLS_WRITTEN = 0;
      AC_L0_FIRST_FAILURE = "";
   }

   status.broker_symbols_total = total;
   status.marketwatch_symbols_total = marketwatch_total;
   status.batch_start_index = AC_L0_NEXT_SYMBOL_INDEX;
   status.batch_end_index = AC_L0_NEXT_SYMBOL_INDEX - 1;

   int batch_limit = AC_DOSSIER_SHELL_BATCH_SIZE;
   if(batch_limit < 1)
      batch_limit = 1;

   bool batch_ok = true;
   int attempted = 0;
   int written = 0;

   while(AC_L0_NEXT_SYMBOL_INDEX < total && attempted < batch_limit)
   {
      int idx = AC_L0_NEXT_SYMBOL_INDEX;
      string symbol = SymbolName(idx, false);
      AC_L0_NEXT_SYMBOL_INDEX++;
      attempted++;
      status.batch_end_index = idx;

      if(symbol == "")
      {
         batch_ok = false;
         if(AC_L0_FIRST_FAILURE == "")
            AC_L0_FIRST_FAILURE = "empty_symbol_name_at_index_" + IntegerToString(idx);
         continue;
      }

      AC_WriteResult write = AC_WriteTextFile(AC_DossierUnknownSymbolPath(symbol), AC_BuildLayer0DossierShellText(symbol, idx, status));
      if(write.ok)
      {
         AC_L0_SHELLS_WRITTEN++;
         written++;
      }
      else
      {
         batch_ok = false;
         if(AC_L0_FIRST_FAILURE == "")
            AC_L0_FIRST_FAILURE = symbol + "=" + write.status;
      }
   }

   status.batch_attempted = attempted;
   status.batch_written = written;
   status.dossier_shells_ready = AC_L0_SHELLS_WRITTEN;
   status.dossier_shells_missing = total - AC_L0_SHELLS_WRITTEN;
   if(status.dossier_shells_missing < 0)
      status.dossier_shells_missing = 0;
   status.next_symbol_index = AC_L0_NEXT_SYMBOL_INDEX;
   status.batch_complete = (total > 0 && AC_L0_SHELLS_WRITTEN >= total);
   status.batch_duration_ms = GetTickCount() - start_ms;
   status.first_failure = AC_L0_FIRST_FAILURE;

   if(total <= 0)
   {
      status.status = "waiting_for_broker_symbol_universe";
      status.main_blocker = "SymbolsTotal_false_returned_zero";
   }
   else if(status.batch_complete && AC_L0_FIRST_FAILURE == "")
   {
      status.status = "complete";
      status.trust_state = "L0_SHELLS_READY";
      status.main_blocker = "Layer 2 open_closed_truth_not_started";
   }
   else if(AC_L0_FIRST_FAILURE != "")
   {
      status.status = "filling_with_degraded";
      status.main_blocker = AC_L0_FIRST_FAILURE;
   }
   else
   {
      status.status = "filling";
      status.main_blocker = "dossier_shell_coverage_incomplete";
   }

   string batch_status = batch_ok ? "dossier_batch_ok" : "dossier_batch_degraded";
   if(status.batch_complete && AC_L0_FIRST_FAILURE == "")
      batch_status = "dossier_shells_complete";

   return AC_MakeSyntheticWriteResult(AC_DossiersUnknownFolder(), batch_ok, batch_status, (ulong)written, "bounded_dossier_shell_batch");
}

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
   text += "UNIVERSE SHELL COVERAGE\r\n";
   text += "----------------------------------------\r\n";
   text += "Broker Symbols Seen:    " + IntegerToString(status.broker_symbols_total) + "\r\n";
   text += "Dossier Shells Ready:   " + IntegerToString(status.dossier_shells_ready) + " / " + IntegerToString(status.broker_symbols_total) + "\r\n";
   text += "Dossier Shells Missing: " + IntegerToString(status.dossier_shells_missing) + "\r\n";
   text += "Completion:             " + AC_PercentText(status.dossier_shells_ready, status.broker_symbols_total) + "\r\n";
   text += "\r\n";
   text += "CURRENT LAYER\r\n";
   text += "----------------------------------------\r\n";
   text += "Layer 0:          Publication + Dossier Shell Foundation\r\n";
   text += "Layer 0 Status:   " + status.status + "\r\n";
   text += "Next Layer Needed: Layer 1 account truth / Layer 2 open-closed truth later\r\n";
   text += "\r\n";
   text += "READINESS\r\n";
   text += "----------------------------------------\r\n";
   text += "L0 Publication Shells: " + status.status + "\r\n";
   text += "L1 Account Truth:      pending\r\n";
   text += "L2 Open/Closed Truth:  pending\r\n";
   text += "L3 Broker Specs:       pending\r\n";
   text += "L4 Market Watch Truth: pending\r\n";
   text += "L5 Basic Gate:         pending\r\n";
   text += "L6-L23:                inactive\r\n";
   text += "\r\n";
   text += "TRADING READINESS\r\n";
   text += "----------------------------------------\r\n";
   text += "Market State Known: false\r\n";
   text += "Specs Known:        false\r\n";
   text += "Quotes Known:       false\r\n";
   text += "Ranking Active:     false\r\n";
   text += "Selection Active:   false\r\n";
   text += "Permission Active:  false\r\n";
   text += "\r\n";
   text += "TRUST BLOCKER\r\n";
   text += "----------------------------------------\r\n";
   text += status.main_blocker + "\r\n";
   text += "Open/Closed counts belong to Layer 2 and are not measured in Layer 0.\r\n";
   text += "\r\n";
   text += "ACTION\r\n";
   text += "----------------------------------------\r\n";
   text += "Wait. Aurora is building the per-symbol foundation only.\r\n";
   text += "No trading review, ranking, selection, alerts, or trade permission exists.\r\n";
   text += "\r\n";
   text += "Generated: " + snapshot.generated_at + "\r\n";
   return text;
}

string AC_Layer0StatusRow(const AC_Layer0StatusPacket &status)
{
   return "schema_name=layer_status|schema_version=v0.2|layer_id=L0|layer_name=" + status.layer_name
      + "|source_owner=" + status.owner_name
      + "|status=" + status.status
      + "|trust_state=" + status.trust_state
      + "|broker_symbols_total=" + IntegerToString(status.broker_symbols_total)
      + "|marketwatch_symbols_total=" + IntegerToString(status.marketwatch_symbols_total)
      + "|dossier_shells_ready=" + IntegerToString(status.dossier_shells_ready)
      + "|dossier_shells_missing=" + IntegerToString(status.dossier_shells_missing)
      + "|completion=" + AC_PercentText(status.dossier_shells_ready, status.broker_symbols_total)
      + "|batch_start_index=" + IntegerToString(status.batch_start_index)
      + "|batch_end_index=" + IntegerToString(status.batch_end_index)
      + "|batch_attempted=" + IntegerToString(status.batch_attempted)
      + "|batch_written=" + IntegerToString(status.batch_written)
      + "|next_symbol_index=" + IntegerToString(status.next_symbol_index)
      + "|batch_duration_ms=" + IntegerToString((int)status.batch_duration_ms)
      + "|main_blocker=" + status.main_blocker
      + "|trade_permission=false|ranking_runtime=false|selection_runtime=false|market_state_known=false";
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
   text += "completion=" + AC_PercentText(status.dossier_shells_ready, status.broker_symbols_total) + "\r\n";
   text += "batch_start_index=" + IntegerToString(status.batch_start_index) + "\r\n";
   text += "batch_end_index=" + IntegerToString(status.batch_end_index) + "\r\n";
   text += "batch_attempted=" + IntegerToString(status.batch_attempted) + "\r\n";
   text += "batch_written=" + IntegerToString(status.batch_written) + "\r\n";
   text += "next_symbol_index=" + IntegerToString(status.next_symbol_index) + "\r\n";
   text += "batch_duration_ms=" + IntegerToString((int)status.batch_duration_ms) + "\r\n";
   text += "batch_complete=" + (status.batch_complete ? "true" : "false") + "\r\n";
   text += "main_blocker=" + status.main_blocker + "\r\n";
   text += "first_failure=" + status.first_failure + "\r\n";
   text += "statistics_owner=layer_owner_packet_not_board_calculation\r\n";
   text += "python_worker=not_used_for_L0_lightweight_stats\r\n";
   text += "mt5_script_worker=not_used_for_runtime_board_stats\r\n";
   text += "open_closed_counts=not_available_until_L2\r\n";
   return text;
}

#endif