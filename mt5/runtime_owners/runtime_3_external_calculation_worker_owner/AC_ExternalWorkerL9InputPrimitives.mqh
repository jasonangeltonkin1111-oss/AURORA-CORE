#ifndef AC_EXTERNAL_WORKER_L9_INPUT_PRIMITIVES_MQH
#define AC_EXTERNAL_WORKER_L9_INPUT_PRIMITIVES_MQH

// Runtime 3 input metadata exporter for Layer 9 Structure / Location Geometry.
// Runtime 1 Shared OHLC Raw Store owns OHLC collection and priority-window files.
// Runtime 3/Gateway reads those priority-window files and calculates L9 structure/location.
// This exporter must not call CopyRates, rank, select, permit, execute, or create strategy signals.

static string AC_L9_LAST_INPUT_EXPORT_STATUS = "not_exported";
static string AC_L9_LAST_INPUT_MANIFEST_STATUS = "not_exported";
static string AC_L9_LAST_INPUT_PAYLOAD_CHECKSUM = "not_available";
static string AC_L9_LAST_INPUT_UPSTREAM_KEY = "not_exported";
static int    AC_L9_LAST_INPUT_ROWS = 0;
static ulong  AC_L9_LAST_INPUT_SIZE = 0;

string AC_L9InputUpstreamKey()
{
   return "l5_upstream=" + AC_L5UpstreamKey()
      + "|l5_pass=" + IntegerToString(AC_L5_GATE_PASS)
      + "|l3_cache=" + AC_L3_CACHE_KEY
      + "|l4_cache=" + AC_L4_CACHE_KEY
      + "|l4_refresh=" + AC_L4_REFRESH_KEY
      + "|symbols_total=" + IntegerToString(SymbolsTotal(false));
}

string AC_L9CsvSafe(string value)
{
   StringReplace(value, "\r", " ");
   StringReplace(value, "\n", " ");
   StringReplace(value, ",", "_");
   StringReplace(value, "|", "_");
   return value;
}

string AC_L9PriceCsv(const double value)
{
   return DoubleToString(value, 10);
}

string AC_L9NumberCsv(const double value)
{
   return DoubleToString(value, 6);
}

string AC_L9LayerOutboxFolder()
{
   return AC_ExternalWorkerOutboxFolder() + "\\Layers\\Layer_9_Structure_Location_Geometry";
}

string AC_L9InputCsvPath()
{
   return AC_L9LayerOutboxFolder() + "\\l9_input_primitives.csv";
}

string AC_L9ExporterInputManifestPath()
{
   return AC_L9LayerOutboxFolder() + "\\l9_input_primitives.manifest";
}

string AC_L9InputCsvHeader()
{
   return "symbol,l5_gate_status,l5_gate_reason,asset_class,ranking_group,market_state,quote_quality,surface_quality,bid,ask,mid,spread_points,spread_bps,tick_age_seconds,digits,point,trade_permission\r\n";
}

void AC_L9ResetInputPrimitiveCounters()
{
   AC_L9_LAST_INPUT_ROWS = 0;
}

string AC_L9BuildInputPrimitiveRows()
{
   AC_L9ResetInputPrimitiveCounters();
   string text = AC_L9InputCsvHeader();
   int rows = 0;

   for(int i = 0; i < ArraySize(AC_L5_SYMBOLS); i++)
   {
      if(!AC_L5_SYMBOLS[i].pass)
         continue;

      string symbol = AC_L5_SYMBOLS[i].symbol;
      string market_state = AC_L2MarketStateForSymbol(symbol);
      int l3_index = AC_L3FindIndex(symbol);
      int l4_index = AC_L4FindIndex(symbol);

      string asset_class = "not_available";
      string ranking_group = "not_available";
      long digits = 0;
      double point = 0.0;
      if(l3_index >= 0)
      {
         AC_L3SymbolSpecs l3 = AC_L3_SYMBOLS[l3_index];
         asset_class = l3.asset_class;
         ranking_group = l3.ranking_group;
         digits = l3.digits;
         point = l3.point;
      }
      if(point <= 0.0)
         point = SymbolInfoDouble(symbol, SYMBOL_POINT);

      string quote_quality = "not_available";
      string surface_quality = "not_available";
      double bid = 0.0;
      double ask = 0.0;
      double mid = 0.0;
      double spread_points = 0.0;
      double spread_bps = 0.0;
      double tick_age_seconds = 0.0;
      if(l4_index >= 0)
      {
         AC_L4SymbolPacket l4 = AC_L4_SYMBOLS[l4_index];
         quote_quality = l4.quote_quality;
         surface_quality = l4.surface_quality;
         bid = l4.bid;
         ask = l4.ask;
         spread_points = l4.spread_points_live;
         spread_bps = l4.spread_bps_live;
         tick_age_seconds = l4.tick_age_seconds;
         if(bid > 0.0 && ask > 0.0)
            mid = (bid + ask) / 2.0;
      }

      text += AC_L9CsvSafe(symbol)
         + "," + AC_L9CsvSafe(AC_L5_SYMBOLS[i].gate_status)
         + "," + AC_L9CsvSafe(AC_L5_SYMBOLS[i].gate_reason)
         + "," + AC_L9CsvSafe(asset_class)
         + "," + AC_L9CsvSafe(ranking_group)
         + "," + AC_L9CsvSafe(market_state)
         + "," + AC_L9CsvSafe(quote_quality)
         + "," + AC_L9CsvSafe(surface_quality)
         + "," + AC_L9PriceCsv(bid)
         + "," + AC_L9PriceCsv(ask)
         + "," + AC_L9PriceCsv(mid)
         + "," + AC_L9NumberCsv(spread_points)
         + "," + AC_L9NumberCsv(spread_bps)
         + "," + AC_L9NumberCsv(tick_age_seconds)
         + "," + IntegerToString((int)digits)
         + "," + AC_L9PriceCsv(point)
         + ",false\r\n";
      rows++;
   }

   AC_L9_LAST_INPUT_ROWS = rows;
   return text;
}

AC_WriteResult AC_ExportLayer9StructureLocationInputPrimitives()
{
   string folder_detail = "";
   AC_EnsureFolderPath(AC_L9LayerOutboxFolder(), folder_detail);

   string rows = AC_L9BuildInputPrimitiveRows();
   string payload_checksum = AC_ExternalWorkerPayloadChecksum(rows);
   string upstream_key = AC_L9InputUpstreamKey();
   AC_WriteResult csv_write = AC_WriteTextFile(AC_L9InputCsvPath(), rows);

   string manifest = "";
   manifest += "schema_name=l9_structure_location_input_primitives_manifest\r\n";
   manifest += "schema_version=1\r\n";
   manifest += "layer_id=9\r\n";
   manifest += "layer_name=Layer 9 - Structure / Location Input Metadata\r\n";
   manifest += "owner_name=Runtime 3 exports L9 symbol metadata only; Runtime 1 owns OHLC; Runtime 3 Gateway calculates from priority windows\r\n";
   manifest += "job_type=L9_STRUCTURE_LOCATION_INPUT_METADATA_V1\r\n";
   manifest += "write_status=" + csv_write.status + "\r\n";
   manifest += "write_ok=" + (csv_write.ok ? "true" : "false") + "\r\n";
   manifest += "folder_detail=" + folder_detail + "\r\n";
   manifest += "row_count=" + IntegerToString(AC_L9_LAST_INPUT_ROWS) + "\r\n";
   manifest += "l5_gate_pass=" + IntegerToString(AC_L5_GATE_PASS) + "\r\n";
   manifest += "upstream_key=" + upstream_key + "\r\n";
   manifest += "payload_checksum=" + payload_checksum + "\r\n";
   manifest += "csv_path=" + AC_L9InputCsvPath() + "\r\n";
   manifest += "copyrates_policy=no_copyrates_here_runtime1_shared_ohlc_priority_windows_are_source\r\n";
   manifest += "required_windows=M15,H1,H4,D1\r\n";
   manifest += "source_truth_owner=L5_pass_set_plus_L2_market_state_plus_L3_point_taxonomy_plus_L4_quote_surface_packets_plus_Runtime1_Shared_OHLC_Priority_Windows\r\n";
   manifest += "calculation_support_owner=Runtime3_Gateway_reads_Runtime1_priority_windows_for_L9_structure_location\r\n";
   manifest += "structure_location_policy=watchlist_only_no_direction_no_entry_no_selection_no_execution\r\n";
   manifest += "authority=" + AC_EXTERNAL_WORKER_AUTHORITY + "\r\n";
   manifest += "trade_permission=false\r\n";
   manifest += "input_metadata_only=true\r\n";
   manifest += "ranking_runtime=false\r\n";
   manifest += "ranked_output_runtime=false\r\n";
   manifest += "selection_runtime=false\r\n";
   manifest += "entry_signal=false\r\n";
   manifest += "generated_unix=" + IntegerToString((int)TimeGMT()) + "\r\n";

   AC_WriteResult manifest_write = AC_WriteTextFile(AC_L9ExporterInputManifestPath(), manifest);
   AC_L9_LAST_INPUT_EXPORT_STATUS = csv_write.status;
   AC_L9_LAST_INPUT_MANIFEST_STATUS = manifest_write.status;
   AC_L9_LAST_INPUT_PAYLOAD_CHECKSUM = payload_checksum;
   AC_L9_LAST_INPUT_UPSTREAM_KEY = upstream_key;
   AC_L9_LAST_INPUT_SIZE = csv_write.final_size;
   return csv_write;
}

#endif