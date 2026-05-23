#ifndef AC_EXTERNAL_WORKER_L8_INPUT_PRIMITIVES_MQH
#define AC_EXTERNAL_WORKER_L8_INPUT_PRIMITIVES_MQH

// Runtime 3 input primitive exporter for Layer 8 Movement / Range Ranking.
// Source truth remains MT5: Layer 5 pass set, L2 market state, L3 taxonomy/spec point,
// L4 live quote/surface packet, and bounded CopyRates-derived OHLC primitives.
// This file must not rank, select, permit, execute, or create a strategy signal.

static string AC_L8_LAST_INPUT_EXPORT_STATUS = "not_exported";
static string AC_L8_LAST_INPUT_MANIFEST_STATUS = "not_exported";
static string AC_L8_LAST_INPUT_PAYLOAD_CHECKSUM = "not_available";
static string AC_L8_LAST_INPUT_UPSTREAM_KEY = "not_exported";
static int    AC_L8_LAST_INPUT_ROWS = 0;
static ulong  AC_L8_LAST_INPUT_SIZE = 0;
static int    AC_L8_LAST_M5_OK = 0;
static int    AC_L8_LAST_M15_OK = 0;
static int    AC_L8_LAST_H1_OK = 0;
static int    AC_L8_LAST_ANY_COPY_DEGRADED = 0;

string AC_L8InputUpstreamKey()
{
   return "l5_upstream=" + AC_L5UpstreamKey()
      + "|l5_pass=" + IntegerToString(AC_L5_GATE_PASS)
      + "|l3_cache=" + AC_L3_CACHE_KEY
      + "|l4_cache=" + AC_L4_CACHE_KEY
      + "|l4_refresh=" + AC_L4_REFRESH_KEY
      + "|symbols_total=" + IntegerToString(SymbolsTotal(false));
}

string AC_L8CsvSafe(string value)
{
   StringReplace(value, "\r", " ");
   StringReplace(value, "\n", " ");
   StringReplace(value, ",", "_");
   StringReplace(value, "|", "_");
   return value;
}

string AC_L8BoolCsv(const bool value)
{
   return value ? "true" : "false";
}

string AC_L8PriceCsv(const double value)
{
   return DoubleToString(value, 10);
}

string AC_L8NumberCsv(const double value)
{
   return DoubleToString(value, 6);
}

string AC_L8LayerOutboxFolder()
{
   return AC_ExternalWorkerOutboxFolder() + "\\Layers\\Layer_8_Movement_Range_Ranking";
}

string AC_L8InputCsvPath()
{
   return AC_L8LayerOutboxFolder() + "\\l8_input_primitives.csv";
}

string AC_L8InputManifestPath()
{
   return AC_L8LayerOutboxFolder() + "\\l8_input_primitives.manifest";
}

string AC_L8InputCsvHeader()
{
   return "symbol,l5_gate_status,l5_gate_reason,asset_class,ranking_group,market_state,quote_quality,surface_quality,bid,ask,mid,spread_points,spread_bps,tick_age_seconds,digits,point,trade_permission,"
      + "m5_bars_requested,m5_bars_copied,m5_copy_status,m5_last_bar_time,m5_range_points_12,m5_range_points_48,m5_avg_bar_range_points_12,m5_avg_bar_range_points_48,m5_expansion_ratio,m5_compression_ratio,m5_close_position_in_48_range_pct,"
      + "m15_bars_requested,m15_bars_copied,m15_copy_status,m15_last_bar_time,m15_range_points_16,m15_range_points_64,m15_avg_bar_range_points_16,m15_avg_bar_range_points_64,m15_expansion_ratio,m15_compression_ratio,m15_close_position_in_64_range_pct,"
      + "h1_bars_requested,h1_bars_copied,h1_copy_status,h1_last_bar_time,h1_range_points_24,h1_range_points_72,h1_avg_bar_range_points_24,h1_avg_bar_range_points_72,h1_expansion_ratio,h1_compression_ratio,h1_close_position_in_72_range_pct\r\n";
}

void AC_L8CalcRangeWindow(const MqlRates &rates[],
                          const int copied,
                          const int window,
                          const double point,
                          double &range_points,
                          double &avg_bar_range_points,
                          double &close_position_pct)
{
   range_points = 0.0;
   avg_bar_range_points = 0.0;
   close_position_pct = 0.0;
   if(copied <= 0 || window <= 0 || point <= 0.0)
      return;

   int limit = MathMin(copied, window);
   double highest = rates[0].high;
   double lowest = rates[0].low;
   double range_sum = 0.0;
   for(int i = 0; i < limit; i++)
   {
      if(rates[i].high > highest) highest = rates[i].high;
      if(rates[i].low < lowest) lowest = rates[i].low;
      range_sum += MathAbs(rates[i].high - rates[i].low) / point;
   }

   range_points = MathAbs(highest - lowest) / point;
   avg_bar_range_points = range_sum / (double)limit;
   double span = highest - lowest;
   if(span > 0.0)
      close_position_pct = ((rates[0].close - lowest) / span) * 100.0;
}

void AC_L8CalcTimeframePrimitives(const string symbol,
                                  const ENUM_TIMEFRAMES timeframe,
                                  const int requested,
                                  const int recent_window,
                                  const int baseline_window,
                                  const int position_window,
                                  const double point,
                                  int &bars_copied,
                                  string &copy_status,
                                  datetime &last_bar_time,
                                  double &recent_range_points,
                                  double &baseline_range_points,
                                  double &recent_avg_bar_range_points,
                                  double &baseline_avg_bar_range_points,
                                  double &expansion_ratio,
                                  double &compression_ratio,
                                  double &close_position_pct)
{
   bars_copied = 0;
   copy_status = "not_attempted";
   last_bar_time = 0;
   recent_range_points = 0.0;
   baseline_range_points = 0.0;
   recent_avg_bar_range_points = 0.0;
   baseline_avg_bar_range_points = 0.0;
   expansion_ratio = 0.0;
   compression_ratio = 0.0;
   close_position_pct = 0.0;

   if(symbol == "" || requested <= 0 || point <= 0.0)
   {
      copy_status = "invalid_request";
      return;
   }

   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   ResetLastError();
   int copied = CopyRates(symbol, timeframe, 0, requested, rates);
   int error_code = GetLastError();
   if(copied <= 0)
   {
      bars_copied = 0;
      copy_status = "copyrates_failed_" + IntegerToString(error_code);
      return;
   }

   bars_copied = copied;
   last_bar_time = rates[0].time;
   if(copied >= requested)
      copy_status = "ok_full";
   else
      copy_status = "partial_" + IntegerToString(copied) + "_of_" + IntegerToString(requested);

   double position_range_points = 0.0;
   double position_avg_unused = 0.0;
   AC_L8CalcRangeWindow(rates, copied, recent_window, point, recent_range_points, recent_avg_bar_range_points, position_avg_unused);
   AC_L8CalcRangeWindow(rates, copied, baseline_window, point, baseline_range_points, baseline_avg_bar_range_points, position_avg_unused);
   AC_L8CalcRangeWindow(rates, copied, position_window, point, position_range_points, position_avg_unused, close_position_pct);

   if(recent_avg_bar_range_points > 0.0 && baseline_avg_bar_range_points > 0.0)
   {
      expansion_ratio = recent_avg_bar_range_points / baseline_avg_bar_range_points;
      compression_ratio = baseline_avg_bar_range_points / recent_avg_bar_range_points;
   }
}

void AC_L8ResetInputPrimitiveCounters()
{
   AC_L8_LAST_INPUT_ROWS = 0;
   AC_L8_LAST_M5_OK = 0;
   AC_L8_LAST_M15_OK = 0;
   AC_L8_LAST_H1_OK = 0;
   AC_L8_LAST_ANY_COPY_DEGRADED = 0;
}

string AC_L8BuildInputPrimitiveRows()
{
   AC_L8ResetInputPrimitiveCounters();
   string text = AC_L8InputCsvHeader();
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

      int m5_copied = 0, m15_copied = 0, h1_copied = 0;
      string m5_status = "not_attempted", m15_status = "not_attempted", h1_status = "not_attempted";
      datetime m5_time = 0, m15_time = 0, h1_time = 0;
      double m5_range_12 = 0.0, m5_range_48 = 0.0, m5_avg_12 = 0.0, m5_avg_48 = 0.0, m5_expansion = 0.0, m5_compression = 0.0, m5_position = 0.0;
      double m15_range_16 = 0.0, m15_range_64 = 0.0, m15_avg_16 = 0.0, m15_avg_64 = 0.0, m15_expansion = 0.0, m15_compression = 0.0, m15_position = 0.0;
      double h1_range_24 = 0.0, h1_range_72 = 0.0, h1_avg_24 = 0.0, h1_avg_72 = 0.0, h1_expansion = 0.0, h1_compression = 0.0, h1_position = 0.0;

      AC_L8CalcTimeframePrimitives(symbol, PERIOD_M5, 64, 12, 48, 48, point, m5_copied, m5_status, m5_time, m5_range_12, m5_range_48, m5_avg_12, m5_avg_48, m5_expansion, m5_compression, m5_position);
      AC_L8CalcTimeframePrimitives(symbol, PERIOD_M15, 80, 16, 64, 64, point, m15_copied, m15_status, m15_time, m15_range_16, m15_range_64, m15_avg_16, m15_avg_64, m15_expansion, m15_compression, m15_position);
      AC_L8CalcTimeframePrimitives(symbol, PERIOD_H1, 80, 24, 72, 72, point, h1_copied, h1_status, h1_time, h1_range_24, h1_range_72, h1_avg_24, h1_avg_72, h1_expansion, h1_compression, h1_position);

      if(StringFind(m5_status, "ok_full") == 0) AC_L8_LAST_M5_OK++;
      if(StringFind(m15_status, "ok_full") == 0) AC_L8_LAST_M15_OK++;
      if(StringFind(h1_status, "ok_full") == 0) AC_L8_LAST_H1_OK++;
      if(StringFind(m5_status, "ok_full") != 0 || StringFind(m15_status, "ok_full") != 0 || StringFind(h1_status, "ok_full") != 0) AC_L8_LAST_ANY_COPY_DEGRADED++;

      text += AC_L8CsvSafe(symbol)
         + "," + AC_L8CsvSafe(AC_L5_SYMBOLS[i].gate_status)
         + "," + AC_L8CsvSafe(AC_L5_SYMBOLS[i].gate_reason)
         + "," + AC_L8CsvSafe(asset_class)
         + "," + AC_L8CsvSafe(ranking_group)
         + "," + AC_L8CsvSafe(market_state)
         + "," + AC_L8CsvSafe(quote_quality)
         + "," + AC_L8CsvSafe(surface_quality)
         + "," + AC_L8PriceCsv(bid)
         + "," + AC_L8PriceCsv(ask)
         + "," + AC_L8PriceCsv(mid)
         + "," + AC_L8NumberCsv(spread_points)
         + "," + AC_L8NumberCsv(spread_bps)
         + "," + AC_L8NumberCsv(tick_age_seconds)
         + "," + IntegerToString((int)digits)
         + "," + AC_L8PriceCsv(point)
         + ",false"
         + ",64," + IntegerToString(m5_copied) + "," + AC_L8CsvSafe(m5_status) + "," + IntegerToString((int)m5_time) + "," + AC_L8NumberCsv(m5_range_12) + "," + AC_L8NumberCsv(m5_range_48) + "," + AC_L8NumberCsv(m5_avg_12) + "," + AC_L8NumberCsv(m5_avg_48) + "," + AC_L8NumberCsv(m5_expansion) + "," + AC_L8NumberCsv(m5_compression) + "," + AC_L8NumberCsv(m5_position)
         + ",80," + IntegerToString(m15_copied) + "," + AC_L8CsvSafe(m15_status) + "," + IntegerToString((int)m15_time) + "," + AC_L8NumberCsv(m15_range_16) + "," + AC_L8NumberCsv(m15_range_64) + "," + AC_L8NumberCsv(m15_avg_16) + "," + AC_L8NumberCsv(m15_avg_64) + "," + AC_L8NumberCsv(m15_expansion) + "," + AC_L8NumberCsv(m15_compression) + "," + AC_L8NumberCsv(m15_position)
         + ",80," + IntegerToString(h1_copied) + "," + AC_L8CsvSafe(h1_status) + "," + IntegerToString((int)h1_time) + "," + AC_L8NumberCsv(h1_range_24) + "," + AC_L8NumberCsv(h1_range_72) + "," + AC_L8NumberCsv(h1_avg_24) + "," + AC_L8NumberCsv(h1_avg_72) + "," + AC_L8NumberCsv(h1_expansion) + "," + AC_L8NumberCsv(h1_compression) + "," + AC_L8NumberCsv(h1_position)
         + "\r\n";
      rows++;
   }

   AC_L8_LAST_INPUT_ROWS = rows;
   return text;
}

AC_WriteResult AC_ExportLayer8MovementRangeInputPrimitives()
{
   string folder_detail = "";
   AC_EnsureFolderPath(AC_L8LayerOutboxFolder(), folder_detail);

   string rows = AC_L8BuildInputPrimitiveRows();
   string payload_checksum = AC_ExternalWorkerPayloadChecksum(rows);
   string upstream_key = AC_L8InputUpstreamKey();
   AC_WriteResult csv_write = AC_WriteTextFile(AC_L8InputCsvPath(), rows);

   string manifest = "";
   manifest += "schema_name=l8_movement_range_input_primitives_manifest\r\n";
   manifest += "schema_version=1\r\n";
   manifest += "layer_id=8\r\n";
   manifest += "layer_name=Layer 8 - Movement / Range Input Primitives\r\n";
   manifest += "owner_name=Runtime 4 - Surface Scoring Owner reserved; Runtime 3 exports bounded input primitives only\r\n";
   manifest += "job_type=L8_MOVEMENT_RANGE_INPUT_PRIMITIVES_V1\r\n";
   manifest += "write_status=" + csv_write.status + "\r\n";
   manifest += "write_ok=" + (csv_write.ok ? "true" : "false") + "\r\n";
   manifest += "folder_detail=" + folder_detail + "\r\n";
   manifest += "row_count=" + IntegerToString(AC_L8_LAST_INPUT_ROWS) + "\r\n";
   manifest += "l5_gate_pass=" + IntegerToString(AC_L5_GATE_PASS) + "\r\n";
   manifest += "m5_full_copy_count=" + IntegerToString(AC_L8_LAST_M5_OK) + "\r\n";
   manifest += "m15_full_copy_count=" + IntegerToString(AC_L8_LAST_M15_OK) + "\r\n";
   manifest += "h1_full_copy_count=" + IntegerToString(AC_L8_LAST_H1_OK) + "\r\n";
   manifest += "any_copy_degraded_count=" + IntegerToString(AC_L8_LAST_ANY_COPY_DEGRADED) + "\r\n";
   manifest += "upstream_key=" + upstream_key + "\r\n";
   manifest += "payload_checksum=" + payload_checksum + "\r\n";
   manifest += "csv_path=" + AC_L8InputCsvPath() + "\r\n";
   manifest += "copyrates_policy=bounded_M5_64_M15_80_H1_80_L5_pass_set_only_partial_history_allowed\r\n";
   manifest += "source_truth_owner=L5_pass_set_plus_L2_market_state_plus_L3_point_taxonomy_plus_L4_quote_surface_packets_plus_CopyRates_bounded_OHLC\r\n";
   manifest += "calculation_support_owner=Runtime3_Calculation_Gateway_L8_movement_range_support\r\n";
   manifest += "movement_range_policy=ranking_only_no_direction_no_entry_no_selection_no_execution\r\n";
   manifest += "authority=" + AC_EXTERNAL_WORKER_AUTHORITY + "\r\n";
   manifest += "trade_permission=false\r\n";
   manifest += "input_primitives_only=true\r\n";
   manifest += "ranking_runtime=false\r\n";
   manifest += "ranked_output_runtime=false\r\n";
   manifest += "selection_runtime=false\r\n";
   manifest += "generated_unix=" + IntegerToString((int)TimeGMT()) + "\r\n";

   AC_WriteResult manifest_write = AC_WriteTextFile(AC_L8InputManifestPath(), manifest);
   AC_L8_LAST_INPUT_EXPORT_STATUS = csv_write.status;
   AC_L8_LAST_INPUT_MANIFEST_STATUS = manifest_write.status;
   AC_L8_LAST_INPUT_PAYLOAD_CHECKSUM = payload_checksum;
   AC_L8_LAST_INPUT_UPSTREAM_KEY = upstream_key;
   AC_L8_LAST_INPUT_SIZE = csv_write.final_size;
   return csv_write;
}

#endif