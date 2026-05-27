#ifndef AC_SELECTED_ROLLING_TICK_PACK_PUBLICATION_MQH
#define AC_SELECTED_ROLLING_TICK_PACK_PUBLICATION_MQH

#include "AC_SelectedRollingTickPack.mqh"

// L20 publication scaffold.
// Builds L20 text/CSV/manifest only and delegates physical writes to the existing FileIO owner when wired.
// L20 does not own FileIO, routes, current quote truth, permission, signal, or execution.

string AC_L20LayerFolder()
{
   return AC_ExternalWorkerOutboxFolder() + "\\Layers\\Layer_20_Selected_Rolling_Tick_Pack";
}

string AC_L20TickPackPath() { return AC_L20LayerFolder() + "\\l20_selected_rolling_tick_pack.csv"; }
string AC_L20SummaryPath() { return AC_L20LayerFolder() + "\\l20_selected_rolling_tick_summary.txt"; }
string AC_L20ManifestPath() { return AC_L20LayerFolder() + "\\l20_selected_rolling_tick.manifest"; }
string AC_L20SelectionDeskPackPath() { return AC_SelectionGlobalFolder() + "\\current_selected_rolling_tick_pack.csv"; }
string AC_L20SelectionDeskTextPath() { return AC_SelectionGlobalFolder() + "\\Selected Rolling Tick Pack.txt"; }

string AC_L20CsvText(const AC_L20SymbolSummary &rows[], const int row_count)
{
   string text = AC_L20CsvHeader() + "\r\n";
   for(int i = 0; i < row_count; i++) text += AC_L20SummaryCsvRow(rows[i]) + "\r\n";
   return text;
}

string AC_L20SummaryText(const AC_L20SymbolSummary &rows[], const int row_count, const string status, const string reason, const int update_duration_ms)
{
   int active = 0;
   int degraded = 0;
   int unavailable = 0;
   int spikes = 0;
   int gappy = 0;
   for(int i = 0; i < row_count; i++)
   {
      if(rows[i].status == "ACTIVE_ROLLING") active++;
      else if(rows[i].status == "UNAVAILABLE_NO_TICKS" || rows[i].status == "missing_scope") unavailable++;
      else degraded++;
      if(rows[i].spread_spike_count_10m > 0) spikes++;
      if(rows[i].status == "DEGRADED_GAPPY_FEED") gappy++;
   }

   string text = "schema_name=aurora_l20_selected_rolling_tick_summary\r\n";
   text += "schema_version=1\r\n";
   text += "status=" + status + "\r\n";
   text += "reason=" + reason + "\r\n";
   text += "selected_symbols_expected=" + IntegerToString(row_count) + "\r\n";
   text += "symbols_active=" + IntegerToString(active) + "\r\n";
   text += "symbols_degraded=" + IntegerToString(degraded) + "\r\n";
   text += "symbols_unavailable=" + IntegerToString(unavailable) + "\r\n";
   text += "spread_spike_symbols=" + IntegerToString(spikes) + "\r\n";
   text += "gappy_symbols=" + IntegerToString(gappy) + "\r\n";
   text += "rolling_window_seconds=" + IntegerToString(AC_L20_ROLLING_WINDOW_SECONDS) + "\r\n";
   text += "max_selected_symbols=" + IntegerToString(AC_L20_MAX_SELECTED_SYMBOLS) + "\r\n";
   text += "max_tick_rows_per_symbol=" + IntegerToString(AC_L20_MAX_TICK_ROWS_PER_SYMBOL) + "\r\n";
   text += "update_duration_ms=" + IntegerToString(update_duration_ms) + "\r\n";
   text += "current_quote_owner=L4\r\n";
   text += "all_symbol_tick_harvest=false\r\n";
   text += "institutional_order_flow_claim=false\r\n";
   text += "trade_permission=false\r\n";
   text += "entry_signal=false\r\n";
   text += "execution=false\r\n";
   return text;
}

string AC_L20SelectionDeskText(const AC_L20SymbolSummary &rows[], const int row_count, const string status, const string reason)
{
   string text = "L20 SELECTED ROLLING TICK WINDOW PACK\r\n";
   text += "Status: " + status + " | Reason: " + reason + "\r\n";
   text += "Meaning: selected historical tick-row proxy metrics only; current quote owner=L4; not signal or permission.\r\n";
   for(int i = 0; i < row_count; i++) text += AC_L20BoardLine(rows[i]) + "\r\n";
   return text;
}

string AC_L20ManifestText(const string status, const string reason, const int row_count)
{
   string text = "schema_name=aurora_l20_selected_rolling_tick_manifest\r\n";
   text += "schema_version=1\r\n";
   text += "status=" + status + "\r\n";
   text += "reason=" + reason + "\r\n";
   text += "row_count=" + IntegerToString(row_count) + "\r\n";
   text += "authority=selected_tick_window_metrics_only\r\n";
   text += "current_quote_owner=L4\r\n";
   text += "trade_permission=false\r\n";
   text += "entry_signal=false\r\n";
   text += "execution=false\r\n";
   text += "institutional_order_flow_claim=false\r\n";
   return text;
}

bool AC_L20PublishOutputs(const AC_L20SymbolSummary &rows[], const int row_count, const string status, const string reason, const int update_duration_ms, string &publish_detail)
{
   string csv = AC_L20CsvText(rows, row_count);
   string summary = AC_L20SummaryText(rows, row_count, status, reason, update_duration_ms);
   string desk = AC_L20SelectionDeskText(rows, row_count, status, reason);
   string manifest = AC_L20ManifestText(status, reason, row_count);

   AC_WriteResult pack_write = AC_WriteTextFile(AC_L20TickPackPath(), csv);
   AC_WriteResult summary_write = AC_WriteTextFile(AC_L20SummaryPath(), summary);
   AC_WriteResult desk_pack_write = AC_WriteTextFile(AC_L20SelectionDeskPackPath(), csv);
   AC_WriteResult desk_text_write = AC_WriteTextFile(AC_L20SelectionDeskTextPath(), desk);
   AC_WriteResult manifest_write = AC_WriteTextFile(AC_L20ManifestPath(), manifest);

   publish_detail = "pack=" + pack_write.status + ";summary=" + summary_write.status + ";selection_pack=" + desk_pack_write.status + ";selection_text=" + desk_text_write.status + ";manifest=" + manifest_write.status;
   return pack_write.ok && summary_write.ok && desk_pack_write.ok && desk_text_write.ok && manifest_write.ok;
}

#endif
