#ifndef AC_SELECTED_ROLLING_TICK_PACK_PUBLICATION_MQH
#define AC_SELECTED_ROLLING_TICK_PACK_PUBLICATION_MQH

// Layer 20 publication scaffold.
// Depends on the active Route/FileIO owner functions when included deliberately after L1-L19 stability.
// This file must not become a duplicate FileIO or route owner.
// It only builds L20 paths/text and delegates writes to AC_WriteTextFile/AC_WriteTextFileFastAtomic.

string AC_L20LayerFolder()
{
   return AC_ExternalWorkerOutboxFolder() + "\\Layers\\Layer_20_Selected_Rolling_Tick_Pack";
}

string AC_L20TickPackPath()
{
   return AC_L20LayerFolder() + "\\l20_selected_rolling_tick_pack.csv";
}

string AC_L20SummaryPath()
{
   return AC_L20LayerFolder() + "\\l20_selected_rolling_tick_summary.txt";
}

string AC_L20ManifestPath()
{
   return AC_L20LayerFolder() + "\\l20_selected_rolling_tick.manifest";
}

string AC_L20ErrorsPath()
{
   return AC_L20LayerFolder() + "\\l20_selected_rolling_tick_errors.csv";
}

string AC_L20PerfPath()
{
   return AC_L20LayerFolder() + "\\l20_selected_rolling_tick_perf.txt";
}

string AC_L20SelectionDeskPackPath()
{
   return AC_SelectionGlobalFolder() + "\\current_selected_rolling_tick_pack.csv";
}

string AC_L20SelectionDeskTextPath()
{
   return AC_SelectionGlobalFolder() + "\\Selected Rolling Tick Pack.txt";
}

bool AC_L20EnsureOutputFolders(string &detail)
{
   string layer_detail = "";
   string global_detail = "";
   bool layer_ok = AC_EnsureFolderPath(AC_L20LayerFolder(), layer_detail);
   bool global_ok = AC_EnsureFolderPath(AC_SelectionGlobalFolder(), global_detail);
   detail = "l20_layer_folder=" + layer_detail + ";selection_global=" + global_detail;
   return layer_ok && global_ok;
}

string AC_L20SummaryText(const AC_L20SymbolSummary &rows[], const int row_count, const string status, const string reason, const int update_duration_ms)
{
   int active = 0;
   int degraded = 0;
   int unavailable = 0;
   int spikes = 0;
   int gappy = 0;
   int missing = 0;
   for(int i = 0; i < row_count; i++)
   {
      if(rows[i].status == "ACTIVE_ROLLING") active++;
      else if(rows[i].status == "UNAVAILABLE_NO_TICKS" || rows[i].status == "missing_scope") unavailable++;
      else degraded++;
      if(rows[i].spread_spike_count_10m > 0) spikes++;
      if(rows[i].status == "DEGRADED_GAPPY_FEED") gappy++;
      if(rows[i].status == "missing_scope") missing++;
   }

   string text = "schema_name=aurora_l20_selected_rolling_tick_summary\r\n";
   text += "schema_version=1\r\n";
   text += "status=" + status + "\r\n";
   text += "reason=" + reason + "\r\n";
   text += "selected_symbols_expected=" + IntegerToString(row_count) + "\r\n";
   text += "symbols_active=" + IntegerToString(active) + "\r\n";
   text += "symbols_degraded=" + IntegerToString(degraded) + "\r\n";
   text += "symbols_unavailable=" + IntegerToString(unavailable) + "\r\n";
   text += "symbols_missing_scope=" + IntegerToString(missing) + "\r\n";
   text += "spread_spike_symbols=" + IntegerToString(spikes) + "\r\n";
   text += "gappy_symbols=" + IntegerToString(gappy) + "\r\n";
   text += "rolling_window_seconds=" + IntegerToString(AC_L20_ROLLING_WINDOW_SECONDS) + "\r\n";
   text += "max_selected_symbols=" + IntegerToString(AC_L20_MAX_SELECTED_SYMBOLS) + "\r\n";
   text += "max_ticks_per_symbol=" + IntegerToString(AC_L20_MAX_TICKS_PER_SYMBOL) + "\r\n";
   text += "update_duration_ms=" + IntegerToString(update_duration_ms) + "\r\n";
   text += "all_symbol_tick_harvest=false\r\n";
   text += "serial_10_minute_wait_per_symbol=false\r\n";
   text += "institutional_order_flow_claim=false\r\n";
   text += "trade_permission=false\r\n";
   text += "entry_signal=false\r\n";
   text += "execution=false\r\n";
   return text;
}

string AC_L20CsvText(const AC_L20SymbolSummary &rows[], const int row_count)
{
   string text = AC_L20CsvHeader() + "\r\n";
   for(int i = 0; i < row_count; i++)
      text += AC_L20SummaryCsvRow(rows[i]) + "\r\n";
   return text;
}

string AC_L20SelectionDeskText(const AC_L20SymbolSummary &rows[], const int row_count, const string status, const string reason)
{
   string text = "L20 SELECTED ROLLING TICK PACK\r\n";
   text += "----------------------------------------\r\n";
   text += "Status: " + status + "\r\n";
   text += "Reason: " + reason + "\r\n";
   text += "Meaning: selected-symbol MT5 tick/spread proxy evidence only; not order flow, not signal, not permission.\r\n";
   for(int i = 0; i < row_count; i++)
      text += AC_L20BoardLine(rows[i]) + "\r\n";
   return text;
}

string AC_L20ManifestText(const string status, const string reason, const int row_count)
{
   string text = "schema_name=aurora_l20_selected_rolling_tick_manifest\r\n";
   text += "schema_version=1\r\n";
   text += "status=" + status + "\r\n";
   text += "reason=" + reason + "\r\n";
   text += "row_count=" + IntegerToString(row_count) + "\r\n";
   text += "authority=selected_tick_proxy_truth_only\r\n";
   text += "runtime_activation_requires_overseer=true\r\n";
   text += "trade_permission=false\r\n";
   text += "entry_signal=false\r\n";
   text += "execution=false\r\n";
   text += "institutional_order_flow_claim=false\r\n";
   return text;
}

bool AC_L20PublishOutputs(const AC_L20SymbolSummary &rows[],
                          const int row_count,
                          const string status,
                          const string reason,
                          const int update_duration_ms,
                          string &publish_detail)
{
   string folder_detail = "";
   if(!AC_L20EnsureOutputFolders(folder_detail))
   {
      publish_detail = "folder_failed;" + folder_detail;
      return false;
   }

   string csv = AC_L20CsvText(rows, row_count);
   string summary = AC_L20SummaryText(rows, row_count, status, reason, update_duration_ms);
   string desk = AC_L20SelectionDeskText(rows, row_count, status, reason);
   string manifest = AC_L20ManifestText(status, reason, row_count);

   AC_WriteResult pack_write = AC_WriteTextFileFastAtomic(AC_L20TickPackPath(), csv);
   AC_WriteResult summary_write = AC_WriteTextFile(AC_L20SummaryPath(), summary);
   AC_WriteResult desk_pack_write = AC_WriteTextFileFastAtomic(AC_L20SelectionDeskPackPath(), csv);
   AC_WriteResult desk_text_write = AC_WriteTextFile(AC_L20SelectionDeskTextPath(), desk);
   AC_WriteResult manifest_write = AC_WriteTextFile(AC_L20ManifestPath(), manifest);

   publish_detail = "folder=" + folder_detail
      + ";pack=" + pack_write.status
      + ";summary=" + summary_write.status
      + ";selection_pack=" + desk_pack_write.status
      + ";selection_text=" + desk_text_write.status
      + ";manifest=" + manifest_write.status;

   return pack_write.ok && summary_write.ok && desk_pack_write.ok && desk_text_write.ok && manifest_write.ok;
}

#endif
