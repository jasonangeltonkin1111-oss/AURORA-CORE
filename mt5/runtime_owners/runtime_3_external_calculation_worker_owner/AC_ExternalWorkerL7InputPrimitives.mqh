#ifndef AC_EXTERNAL_WORKER_L7_INPUT_PRIMITIVES_MQH
#define AC_EXTERNAL_WORKER_L7_INPUT_PRIMITIVES_MQH

static string AC_L7_LAST_INPUT_EXPORT_STATUS = "not_exported";
static string AC_L7_LAST_INPUT_MANIFEST_STATUS = "not_exported";
static string AC_L7_LAST_INPUT_PAYLOAD_CHECKSUM = "not_available";
static string AC_L7_LAST_INPUT_UPSTREAM_KEY = "not_exported";
static int    AC_L7_LAST_INPUT_ROWS = 0;
static ulong  AC_L7_LAST_INPUT_SIZE = 0;
static string AC_L7_LAST_SESSION_TIME_BASIS = "not_available";

string AC_L7InputUpstreamKey()
{
   return "l5_upstream=" + AC_L5UpstreamKey()
      + "|l5_pass=" + IntegerToString(AC_L5_GATE_PASS)
      + "|l3_cache=" + AC_L3_CACHE_KEY
      + "|l4_cache=" + AC_L4_CACHE_KEY
      + "|l4_refresh=" + AC_L4_REFRESH_KEY
      + "|symbols_total=" + IntegerToString(SymbolsTotal(false));
}

datetime AC_L7SessionSourceTime()
{
   // L7 input identity must be tied to the upstream source epoch, not to a fresh
   // TimeCurrent() call on every publication pass. L7 consumes L4 quote/surface
   // packets, so the L4 refresh timestamp is the correct stable source epoch.
   if(AC_L4_LAST_REFRESH_TIME > 0)
   {
      AC_L7_LAST_SESSION_TIME_BASIS = "broker_server_time_of_day_from_L4_refresh_time_marketwatch_caveat";
      return AC_L4_LAST_REFRESH_TIME;
   }

   AC_L7_LAST_SESSION_TIME_BASIS = "broker_server_time_of_day_from_TimeCurrent_fallback_marketwatch_caveat";
   return TimeCurrent();
}

string AC_L7CsvSafe(string value)
{
   StringReplace(value, "\r", " ");
   StringReplace(value, "\n", " ");
   StringReplace(value, ",", "_");
   StringReplace(value, "|", "_");
   return value;
}

string AC_L7BoolCsv(const bool value)
{
   return value ? "true" : "false";
}

string AC_L7PriceCsv(const double value)
{
   return DoubleToString(value, 10);
}

string AC_L7SpreadCsv(const double value)
{
   return DoubleToString(value, 6);
}

string AC_L7SessionLayerOutboxFolder()
{
   return AC_ExternalWorkerOutboxFolder() + "\\Layers\\Layer_7_Session_Relevance_Ranking";
}

string AC_L7SessionInputCsvPath()
{
   return AC_L7SessionLayerOutboxFolder() + "\\l7_input_primitives.csv";
}

string AC_L7SessionInputManifestPath()
{
   return AC_L7SessionLayerOutboxFolder() + "\\l7_input_primitives.manifest";
}

string AC_L7InputCsvHeader()
{
   return "symbol,l5_gate_status,l5_gate_reason,asset_class,ranking_group,market_state,server_time_unix,server_day_of_week,server_time_of_day_seconds,session_time_basis,session_definition_source,quote_quality,surface_quality,bid,ask,spread_points,spread_bps,daily_change_pct,tick_age_seconds,zero_spread_state,trade_permission\r\n";
}

string AC_L7BuildInputPrimitiveRows()
{
   AC_L7_LAST_INPUT_ROWS = 0;
   string text = AC_L7InputCsvHeader();
   int rows = 0;

   datetime server_time = AC_L7SessionSourceTime();
   MqlDateTime server_dt;
   TimeToStruct(server_time, server_dt);
   int server_time_of_day_seconds = (server_dt.hour * 3600) + (server_dt.min * 60) + server_dt.sec;
   string server_time_unix = IntegerToString((int)server_time);
   string server_day_of_week = IntegerToString(server_dt.day_of_week);
   string session_time_basis = AC_L7_LAST_SESSION_TIME_BASIS;
   string session_definition_source = "pending_gateway_static_profile";

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
      if(l3_index >= 0)
      {
         AC_L3SymbolSpecs l3 = AC_L3_SYMBOLS[l3_index];
         asset_class = l3.asset_class;
         ranking_group = l3.ranking_group;
      }

      string quote_quality = "not_available";
      string surface_quality = "not_available";
      double bid = 0.0;
      double ask = 0.0;
      double spread_points = 0.0;
      double spread_bps = 0.0;
      double daily_change_pct = 0.0;
      double tick_age_seconds = 0.0;
      string zero_spread_state = "not_available";

      if(l4_index >= 0)
      {
         AC_L4SymbolPacket l4 = AC_L4_SYMBOLS[l4_index];
         quote_quality = l4.quote_quality;
         surface_quality = l4.surface_quality;
         bid = l4.bid;
         ask = l4.ask;
         spread_points = l4.spread_points_live;
         spread_bps = l4.spread_bps_live;
         daily_change_pct = l4.daily_change_pct;
         tick_age_seconds = l4.tick_age_seconds;
         zero_spread_state = l4.zero_spread_state;
      }

      text += AC_L7CsvSafe(symbol)
         + "," + AC_L7CsvSafe(AC_L5_SYMBOLS[i].gate_status)
         + "," + AC_L7CsvSafe(AC_L5_SYMBOLS[i].gate_reason)
         + "," + AC_L7CsvSafe(asset_class)
         + "," + AC_L7CsvSafe(ranking_group)
         + "," + AC_L7CsvSafe(market_state)
         + "," + server_time_unix
         + "," + server_day_of_week
         + "," + IntegerToString(server_time_of_day_seconds)
         + "," + AC_L7CsvSafe(session_time_basis)
         + "," + AC_L7CsvSafe(session_definition_source)
         + "," + AC_L7CsvSafe(quote_quality)
         + "," + AC_L7CsvSafe(surface_quality)
         + "," + AC_L7PriceCsv(bid)
         + "," + AC_L7PriceCsv(ask)
         + "," + AC_L7SpreadCsv(spread_points)
         + "," + AC_L7SpreadCsv(spread_bps)
         + "," + AC_L7SpreadCsv(daily_change_pct)
         + "," + AC_L7SpreadCsv(tick_age_seconds)
         + "," + AC_L7CsvSafe(zero_spread_state)
         + ",false\r\n";
      rows++;
   }

   AC_L7_LAST_INPUT_ROWS = rows;
   return text;
}

AC_WriteResult AC_ExportLayer7SessionRelevanceInputPrimitives()
{
   string folder_detail = "";
   AC_EnsureFolderPath(AC_L7SessionLayerOutboxFolder(), folder_detail);

   string rows = AC_L7BuildInputPrimitiveRows();
   string payload_checksum = AC_ExternalWorkerPayloadChecksum(rows);
   string upstream_key = AC_L7InputUpstreamKey();
   AC_WriteResult csv_write = AC_WriteTextFile(AC_L7SessionInputCsvPath(), rows);

   string manifest = "";
   manifest += "schema_name=l7_session_relevance_input_primitives_manifest\r\n";
   manifest += "schema_version=3\r\n";
   manifest += "layer_id=7\r\n";
   manifest += "layer_name=Layer 7 - Session Relevance Input Primitives\r\n";
   manifest += "owner_name=Runtime 4 - Surface Scoring Owner reserved; input primitives only in current source\r\n";
   manifest += "job_type=L7_SESSION_RELEVANCE_INPUT_PRIMITIVES_V1\r\n";
   manifest += "write_status=" + csv_write.status + "\r\n";
   manifest += "write_ok=" + (csv_write.ok ? "true" : "false") + "\r\n";
   manifest += "folder_detail=" + folder_detail + "\r\n";
   manifest += "row_count=" + IntegerToString(AC_L7_LAST_INPUT_ROWS) + "\r\n";
   manifest += "l5_gate_pass=" + IntegerToString(AC_L5_GATE_PASS) + "\r\n";
   manifest += "upstream_key=" + upstream_key + "\r\n";
   manifest += "payload_checksum=" + payload_checksum + "\r\n";
   manifest += "csv_path=" + AC_L7SessionInputCsvPath() + "\r\n";
   manifest += "csv_precision_policy=price_10_decimals_spread_bps_6_decimals_tick_age_6_decimals\r\n";
   manifest += "session_time_basis=" + AC_L7_LAST_SESSION_TIME_BASIS + "\r\n";
   manifest += "session_definition_source=pending_gateway_static_profile\r\n";
   manifest += "input_epoch_policy=L7_uses_L4_refresh_time_when_available_to_prevent_identity_churn\r\n";
   manifest += "source_truth_owner=L5_pass_set_plus_L2_market_state_plus_L3_taxonomy_plus_L4_quote_surface_packets\r\n";
   manifest += "calculation_support_owner=Runtime3_Calculation_Gateway_L7_session_relevance_support_pending\r\n";
   manifest += "authority=" + AC_EXTERNAL_WORKER_AUTHORITY + "\r\n";
   manifest += "trade_permission=false\r\n";
   manifest += "input_primitives_only=true\r\n";
   manifest += "ranking_runtime=false\r\n";
   manifest += "ranked_output_runtime=false\r\n";
   manifest += "selection_runtime=false\r\n";
   manifest += "generated_unix=" + IntegerToString((int)TimeGMT()) + "\r\n";

   AC_WriteResult manifest_write = AC_WriteTextFile(AC_L7SessionInputManifestPath(), manifest);
   AC_L7_LAST_INPUT_EXPORT_STATUS = csv_write.status;
   AC_L7_LAST_INPUT_MANIFEST_STATUS = manifest_write.status;
   AC_L7_LAST_INPUT_PAYLOAD_CHECKSUM = payload_checksum;
   AC_L7_LAST_INPUT_UPSTREAM_KEY = upstream_key;
   AC_L7_LAST_INPUT_SIZE = csv_write.final_size;
   return csv_write;
}

#endif
