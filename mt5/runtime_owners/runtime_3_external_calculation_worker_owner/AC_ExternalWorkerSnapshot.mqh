#ifndef AC_EXTERNAL_WORKER_SNAPSHOT_MQH
#define AC_EXTERNAL_WORKER_SNAPSHOT_MQH

static string AC_EXTERNAL_WORKER_LAST_SNAPSHOT_ID = "not_exported";
static string AC_EXTERNAL_WORKER_LAST_SNAPSHOT_STATUS = "not_exported";
static string AC_EXTERNAL_WORKER_LAST_SNAPSHOT_MANIFEST_STATUS = "not_exported";
static string AC_EXTERNAL_WORKER_LAST_SNAPSHOT_PAYLOAD_CHECKSUM = "not_available";
static string AC_EXTERNAL_WORKER_LAST_JOB_ID = "not_exported";
static string AC_EXTERNAL_WORKER_LAST_JOB_TYPE = "not_available";
static string AC_EXTERNAL_WORKER_LAST_JOB_STATUS = "not_exported";
static ulong  AC_EXTERNAL_WORKER_LAST_SNAPSHOT_SIZE = 0;
static int    AC_EXTERNAL_WORKER_LAST_SNAPSHOT_ROWS = 0;

static string AC_L6_LAST_INPUT_EXPORT_STATUS = "not_exported";
static string AC_L6_LAST_INPUT_MANIFEST_STATUS = "not_exported";
static string AC_L6_LAST_INPUT_PAYLOAD_CHECKSUM = "not_available";
static int    AC_L6_LAST_INPUT_ROWS = 0;
static ulong  AC_L6_LAST_INPUT_SIZE = 0;
static int    AC_L6_LAST_BUY_1LOT_OK = 0;
static int    AC_L6_LAST_SELL_1LOT_OK = 0;
static int    AC_L6_LAST_BUY_MINLOT_OK = 0;
static int    AC_L6_LAST_SELL_MINLOT_OK = 0;
static int    AC_L6_LAST_ONELOT_INVALID = 0;
static int    AC_L6_LAST_MINLOT_INVALID = 0;
static int    AC_L6_LAST_COST_ASYMMETRY_COUNT = 0;

string AC_ExternalWorkerSnapshotId()
{
   return AC_AccountForRoute() + "_" + IntegerToString((int)TimeCurrent()) + "_" + IntegerToString((int)GetTickCount());
}

string AC_ExternalWorkerPayloadChecksum(const string payload)
{
   long checksum = 0;
   int len = StringLen(payload);
   for(int i = 0; i < len; i++)
   {
      ushort ch = StringGetCharacter(payload, i);
      checksum = (checksum + ((long)ch * (long)(i + 1))) % 2147483647;
   }
   return IntegerToString((int)checksum);
}

string AC_ExternalWorkerJobId(const string snapshot_id)
{
   return snapshot_id + "_" + AC_EXTERNAL_WORKER_DEFAULT_JOB_TYPE;
}

string AC_L6CsvSafe(string value)
{
   StringReplace(value, "\r", " ");
   StringReplace(value, "\n", " ");
   StringReplace(value, ",", "_");
   StringReplace(value, "|", "_");
   return value;
}

string AC_L6BoolCsv(const bool value)
{
   return value ? "true" : "false";
}

string AC_L6MoneyCsv(const double value)
{
   return DoubleToString(value, 8);
}

string AC_L6VolumeCsv(const double value)
{
   return DoubleToString(value, 8);
}

string AC_L6PriceCsv(const double value)
{
   return DoubleToString(value, 10);
}

string AC_L6FrictionLayerOutboxFolder()
{
   return AC_ExternalWorkerOutboxFolder() + "\\Layers\\Layer_6_Cost_Friction_Ranking";
}

string AC_L6FrictionInputCsvPath()
{
   return AC_L6FrictionLayerOutboxFolder() + "\\l6_input_primitives.csv";
}

string AC_L6FrictionInputManifestPath()
{
   return AC_L6FrictionLayerOutboxFolder() + "\\l6_input_primitives.manifest";
}

bool AC_L6VolumeInRange(const double volume, const AC_L3SymbolSpecs &l3)
{
   if(volume <= 0.0) return false;
   if(l3.volume_min > 0.0 && volume + 0.00000001 < l3.volume_min) return false;
   if(l3.volume_max > 0.0 && volume - 0.00000001 > l3.volume_max) return false;
   return true;
}

void AC_L6CalcSpreadCost(const string symbol,
                         const ENUM_ORDER_TYPE order_type,
                         const double volume,
                         const double price_open,
                         const double price_close,
                         double &cost,
                         string &status,
                         int &error_code)
{
   cost = 0.0;
   status = "not_attempted";
   error_code = 0;

   if(volume <= 0.0)
   {
      status = "invalid_volume";
      return;
   }
   if(price_open <= 0.0 || price_close <= 0.0)
   {
      status = "invalid_prices";
      return;
   }

   ResetLastError();
   double profit = 0.0;
   bool ok = OrderCalcProfit(order_type, symbol, volume, price_open, price_close, profit);
   error_code = GetLastError();
   if(!ok)
   {
      status = "ordercalcprofit_failed";
      return;
   }

   cost = MathAbs(profit);
   status = "ok";
}

string AC_L6InputCsvHeader()
{
   return "symbol,l5_gate_status,l5_gate_reason,asset_class,ranking_group,digits,point,contract_size,volume_min,volume_step,volume_max,value_quality,margin_quality,quote_quality,surface_quality,bid,ask,mid,spread_points,spread_bps,tick_age_seconds,zero_spread_state,spread_cost_buy_1lot_account,spread_cost_sell_1lot_account,spread_cost_worst_1lot_account,spread_cost_buy_minlot_account,spread_cost_sell_minlot_account,spread_cost_worst_minlot_account,ordercalcprofit_buy_1lot_status,ordercalcprofit_sell_1lot_status,ordercalcprofit_buy_minlot_status,ordercalcprofit_sell_minlot_status,ordercalcprofit_buy_1lot_error,ordercalcprofit_sell_1lot_error,ordercalcprofit_buy_minlot_error,ordercalcprofit_sell_minlot_error,cost_asymmetry_detected,commission_status,slippage_status,trade_permission\r\n";
}

void AC_L6ResetInputPrimitiveCounters()
{
   AC_L6_LAST_INPUT_ROWS = 0;
   AC_L6_LAST_BUY_1LOT_OK = 0;
   AC_L6_LAST_SELL_1LOT_OK = 0;
   AC_L6_LAST_BUY_MINLOT_OK = 0;
   AC_L6_LAST_SELL_MINLOT_OK = 0;
   AC_L6_LAST_ONELOT_INVALID = 0;
   AC_L6_LAST_MINLOT_INVALID = 0;
   AC_L6_LAST_COST_ASYMMETRY_COUNT = 0;
}

string AC_L6BuildInputPrimitiveRows()
{
   AC_L6ResetInputPrimitiveCounters();
   string text = AC_L6InputCsvHeader();
   int rows = 0;

   for(int i = 0; i < ArraySize(AC_L5_SYMBOLS); i++)
   {
      if(!AC_L5_SYMBOLS[i].pass)
         continue;

      string symbol = AC_L5_SYMBOLS[i].symbol;
      int l3_index = AC_L3FindIndex(symbol);
      int l4_index = AC_L4FindIndex(symbol);

      string asset_class = "not_available";
      string ranking_group = "not_available";
      long digits = 0;
      double point = 0.0;
      double contract_size = 0.0;
      double volume_min = 0.0;
      double volume_step = 0.0;
      double volume_max = 0.0;
      string value_quality = "not_available";
      string margin_quality = "not_available";
      bool one_lot_in_range = false;
      bool min_lot_in_range = false;

      if(l3_index >= 0)
      {
         AC_L3SymbolSpecs l3 = AC_L3_SYMBOLS[l3_index];
         asset_class = l3.asset_class;
         ranking_group = l3.ranking_group;
         digits = l3.digits;
         point = l3.point;
         contract_size = l3.contract_size;
         volume_min = l3.volume_min;
         volume_step = l3.volume_step;
         volume_max = l3.volume_max;
         value_quality = l3.value_quality;
         margin_quality = l3.margin_quality;
         one_lot_in_range = AC_L6VolumeInRange(1.0, l3);
         min_lot_in_range = AC_L6VolumeInRange(l3.volume_min, l3);
      }

      string quote_quality = "not_available";
      string surface_quality = "not_available";
      double bid = 0.0;
      double ask = 0.0;
      double mid = 0.0;
      double spread_points = 0.0;
      double spread_bps = 0.0;
      double tick_age_seconds = 0.0;
      string zero_spread_state = "not_available";

      if(l4_index >= 0)
      {
         AC_L4SymbolPacket l4 = AC_L4_SYMBOLS[l4_index];
         quote_quality = l4.quote_quality;
         surface_quality = l4.surface_quality;
         bid = l4.bid;
         ask = l4.ask;
         if(bid > 0.0 && ask > 0.0) mid = (bid + ask) / 2.0;
         spread_points = l4.spread_points_live;
         spread_bps = l4.spread_bps_live;
         tick_age_seconds = l4.tick_age_seconds;
         zero_spread_state = l4.zero_spread_state;
      }

      double buy_1lot = 0.0;
      double sell_1lot = 0.0;
      double buy_minlot = 0.0;
      double sell_minlot = 0.0;
      string buy_1lot_status = one_lot_in_range ? "not_attempted" : "volume_1lot_not_valid_for_symbol";
      string sell_1lot_status = one_lot_in_range ? "not_attempted" : "volume_1lot_not_valid_for_symbol";
      string buy_minlot_status = min_lot_in_range ? "not_attempted" : "volume_min_not_valid_for_symbol";
      string sell_minlot_status = min_lot_in_range ? "not_attempted" : "volume_min_not_valid_for_symbol";
      int buy_1lot_error = 0;
      int sell_1lot_error = 0;
      int buy_minlot_error = 0;
      int sell_minlot_error = 0;

      if(one_lot_in_range)
      {
         AC_L6CalcSpreadCost(symbol, ORDER_TYPE_BUY, 1.0, ask, bid, buy_1lot, buy_1lot_status, buy_1lot_error);
         AC_L6CalcSpreadCost(symbol, ORDER_TYPE_SELL, 1.0, bid, ask, sell_1lot, sell_1lot_status, sell_1lot_error);
      }
      else
      {
         AC_L6_LAST_ONELOT_INVALID++;
      }
      if(min_lot_in_range)
      {
         AC_L6CalcSpreadCost(symbol, ORDER_TYPE_BUY, volume_min, ask, bid, buy_minlot, buy_minlot_status, buy_minlot_error);
         AC_L6CalcSpreadCost(symbol, ORDER_TYPE_SELL, volume_min, bid, ask, sell_minlot, sell_minlot_status, sell_minlot_error);
      }
      else
      {
         AC_L6_LAST_MINLOT_INVALID++;
      }

      if(buy_1lot_status == "ok") AC_L6_LAST_BUY_1LOT_OK++;
      if(sell_1lot_status == "ok") AC_L6_LAST_SELL_1LOT_OK++;
      if(buy_minlot_status == "ok") AC_L6_LAST_BUY_MINLOT_OK++;
      if(sell_minlot_status == "ok") AC_L6_LAST_SELL_MINLOT_OK++;

      double worst_1lot = MathMax(buy_1lot, sell_1lot);
      double worst_minlot = MathMax(buy_minlot, sell_minlot);
      bool asymmetry = (MathAbs(buy_1lot - sell_1lot) > 0.00000001 || MathAbs(buy_minlot - sell_minlot) > 0.00000001);
      if(asymmetry) AC_L6_LAST_COST_ASYMMETRY_COUNT++;

      text += AC_L6CsvSafe(symbol)
         + "," + AC_L6CsvSafe(AC_L5_SYMBOLS[i].gate_status)
         + "," + AC_L6CsvSafe(AC_L5_SYMBOLS[i].gate_reason)
         + "," + AC_L6CsvSafe(asset_class)
         + "," + AC_L6CsvSafe(ranking_group)
         + "," + IntegerToString((int)digits)
         + "," + DoubleToString(point, 10)
         + "," + DoubleToString(contract_size, 8)
         + "," + AC_L6VolumeCsv(volume_min)
         + "," + AC_L6VolumeCsv(volume_step)
         + "," + AC_L6VolumeCsv(volume_max)
         + "," + AC_L6CsvSafe(value_quality)
         + "," + AC_L6CsvSafe(margin_quality)
         + "," + AC_L6CsvSafe(quote_quality)
         + "," + AC_L6CsvSafe(surface_quality)
         + "," + AC_L6PriceCsv(bid)
         + "," + AC_L6PriceCsv(ask)
         + "," + AC_L6PriceCsv(mid)
         + "," + DoubleToString(spread_points, 4)
         + "," + DoubleToString(spread_bps, 6)
         + "," + DoubleToString(tick_age_seconds, 3)
         + "," + AC_L6CsvSafe(zero_spread_state)
         + "," + AC_L6MoneyCsv(buy_1lot)
         + "," + AC_L6MoneyCsv(sell_1lot)
         + "," + AC_L6MoneyCsv(worst_1lot)
         + "," + AC_L6MoneyCsv(buy_minlot)
         + "," + AC_L6MoneyCsv(sell_minlot)
         + "," + AC_L6MoneyCsv(worst_minlot)
         + "," + AC_L6CsvSafe(buy_1lot_status)
         + "," + AC_L6CsvSafe(sell_1lot_status)
         + "," + AC_L6CsvSafe(buy_minlot_status)
         + "," + AC_L6CsvSafe(sell_minlot_status)
         + "," + IntegerToString(buy_1lot_error)
         + "," + IntegerToString(sell_1lot_error)
         + "," + IntegerToString(buy_minlot_error)
         + "," + IntegerToString(sell_minlot_error)
         + "," + AC_L6BoolCsv(asymmetry)
         + ",commission_not_available_from_api"
         + ",slippage_not_modelled_v1"
         + ",false\r\n";
      rows++;
   }

   AC_L6_LAST_INPUT_ROWS = rows;
   return text;
}

AC_WriteResult AC_ExportLayer6CostFrictionInputPrimitives()
{
   string folder_detail = "";
   AC_EnsureFolderPath(AC_L6FrictionLayerOutboxFolder(), folder_detail);

   string rows = AC_L6BuildInputPrimitiveRows();
   string payload_checksum = AC_ExternalWorkerPayloadChecksum(rows);
   AC_WriteResult csv_write = AC_WriteTextFile(AC_L6FrictionInputCsvPath(), rows);

   string manifest = "";
   manifest += "schema_name=l6_cost_friction_input_primitives_manifest\r\n";
   manifest += "schema_version=2\r\n";
   manifest += "layer_id=6\r\n";
   manifest += "layer_name=Layer 6 - Cost / Friction Ranking\r\n";
   manifest += "owner_name=Runtime 4 - Surface Scoring Owner\r\n";
   manifest += "job_type=L6_COST_FRICTION_RANKING_V1\r\n";
   manifest += "write_status=" + csv_write.status + "\r\n";
   manifest += "write_ok=" + (csv_write.ok ? "true" : "false") + "\r\n";
   manifest += "folder_detail=" + folder_detail + "\r\n";
   manifest += "row_count=" + IntegerToString(AC_L6_LAST_INPUT_ROWS) + "\r\n";
   manifest += "l5_gate_pass=" + IntegerToString(AC_L5_GATE_PASS) + "\r\n";
   manifest += "payload_checksum=" + payload_checksum + "\r\n";
   manifest += "csv_path=" + AC_L6FrictionInputCsvPath() + "\r\n";
   manifest += "csv_precision_policy=money_8_decimals_volume_8_decimals_price_10_decimals_spread_bps_6_decimals\r\n";
   manifest += "ordercalcprofit_buy_1lot_ok_count=" + IntegerToString(AC_L6_LAST_BUY_1LOT_OK) + "\r\n";
   manifest += "ordercalcprofit_sell_1lot_ok_count=" + IntegerToString(AC_L6_LAST_SELL_1LOT_OK) + "\r\n";
   manifest += "ordercalcprofit_buy_minlot_ok_count=" + IntegerToString(AC_L6_LAST_BUY_MINLOT_OK) + "\r\n";
   manifest += "ordercalcprofit_sell_minlot_ok_count=" + IntegerToString(AC_L6_LAST_SELL_MINLOT_OK) + "\r\n";
   manifest += "volume_1lot_invalid_count=" + IntegerToString(AC_L6_LAST_ONELOT_INVALID) + "\r\n";
   manifest += "volume_minlot_invalid_count=" + IntegerToString(AC_L6_LAST_MINLOT_INVALID) + "\r\n";
   manifest += "cost_asymmetry_detected_count=" + IntegerToString(AC_L6_LAST_COST_ASYMMETRY_COUNT) + "\r\n";
   manifest += "source_truth_owner=L5_pass_set_plus_L3_L4_packets_plus_MT5_OrderCalcProfit_primitives\r\n";
   manifest += "calculation_support_owner=Runtime3_Calculation_Gateway_future_L6D\r\n";
   manifest += "authority=" + AC_EXTERNAL_WORKER_AUTHORITY + "\r\n";
   manifest += "trade_permission=false\r\n";
   manifest += "ranking_runtime=true\r\n";
   manifest += "selection_runtime=false\r\n";
   manifest += "generated_unix=" + IntegerToString((int)TimeGMT()) + "\r\n";

   AC_WriteResult manifest_write = AC_WriteTextFile(AC_L6FrictionInputManifestPath(), manifest);
   AC_L6_LAST_INPUT_EXPORT_STATUS = csv_write.status;
   AC_L6_LAST_INPUT_MANIFEST_STATUS = manifest_write.status;
   AC_L6_LAST_INPUT_PAYLOAD_CHECKSUM = payload_checksum;
   AC_L6_LAST_INPUT_SIZE = csv_write.final_size;
   return csv_write;
}

string AC_ExternalWorkerSnapshotHeader(const string snapshot_id, const string job_id, const int rows, const string payload_checksum)
{
   string text = "";
   text += "schema_name=aurora_external_worker_snapshot\r\n";
   text += "schema_version=2\r\n";
   text += "snapshot_id=" + snapshot_id + "\r\n";
   text += "job_bus_schema_version=" + AC_EXTERNAL_WORKER_JOB_BUS_SCHEMA_VERSION + "\r\n";
   text += "job_id=" + job_id + "\r\n";
   text += "job_type=" + AC_EXTERNAL_WORKER_DEFAULT_JOB_TYPE + "\r\n";
   text += "job_resource_class=" + AC_EXTERNAL_WORKER_JOB_RESOURCE_CLASS + "\r\n";
   text += "job_max_runtime_ms=" + IntegerToString(AC_EXTERNAL_WORKER_JOB_MAX_RUNTIME_MS) + "\r\n";
   text += "job_requested_layer=L5\r\n";
   text += "job_expected_output=deep_readiness_shell_only\r\n";
   text += "system_name=" + AC_SYSTEM_NAME + "\r\n";
   text += "build_version=" + AC_BUILD_VERSION + "\r\n";
   text += "upgrade_id=" + AC_UPGRADE_ID + "\r\n";
   text += "source_owner=MT5_Runtime_1_and_Runtime_3\r\n";
   text += "worker_owner=" + AC_RUNTIME3_OWNER + "\r\n";
   text += "authority=" + AC_EXTERNAL_WORKER_AUTHORITY + "\r\n";
   text += "server=" + AC_ServerNameForRoute() + "\r\n";
   text += "account=" + AC_AccountForRoute() + "\r\n";
   text += "source_layers=L1,L2,L3,L4\r\n";
   text += "future_layer_5_status=job_bus_shell_only\r\n";
   text += "row_count=" + IntegerToString(rows) + "\r\n";
   text += "payload_checksum=" + payload_checksum + "\r\n";
   text += "snapshot_complete=true\r\n";
   text += "trade_permission=false\r\n";
   text += "ranking_runtime=false\r\n";
   text += "selection_runtime=false\r\n\r\n";
   return text;
}

string AC_ExternalWorkerSnapshotRows()
{
   string text = "symbol|market_state|l3_ready|l4_ready|quote_quality|surface_quality|bid|ask|spread_points|spread_bps|daily_change_pct|tick_age_seconds|trade_permission\r\n";
   int total = SymbolsTotal(false);
   int rows = 0;
   for(int idx = 0; idx < total; idx++)
   {
      string symbol = SymbolName(idx, false);
      if(symbol == "") continue;
      string market_state = AC_L2MarketStateForSymbol(symbol);
      int l4_index = AC_L4FindIndex(symbol);
      string quote_quality = "not_available";
      string surface_quality = "not_available";
      double bid = 0.0;
      double ask = 0.0;
      double spread_points = 0.0;
      double spread_bps = 0.0;
      double daily_change_pct = 0.0;
      double tick_age_seconds = 0.0;
      if(l4_index >= 0)
      {
         quote_quality = AC_L4_SYMBOLS[l4_index].quote_quality;
         surface_quality = AC_L4_SYMBOLS[l4_index].surface_quality;
         bid = AC_L4_SYMBOLS[l4_index].bid;
         ask = AC_L4_SYMBOLS[l4_index].ask;
         spread_points = AC_L4_SYMBOLS[l4_index].spread_points_live;
         spread_bps = AC_L4_SYMBOLS[l4_index].spread_bps_live;
         daily_change_pct = AC_L4_SYMBOLS[l4_index].daily_change_pct;
         tick_age_seconds = AC_L4_SYMBOLS[l4_index].tick_age_seconds;
      }
      text += symbol + "|" + market_state + "|" + (AC_L3_READY ? "true" : "false") + "|" + (l4_index >= 0 ? "true" : "false") + "|" + quote_quality + "|" + surface_quality + "|" + DoubleToString(bid, 8) + "|" + DoubleToString(ask, 8) + "|" + DoubleToString(spread_points, 2) + "|" + DoubleToString(spread_bps, 4) + "|" + DoubleToString(daily_change_pct, 4) + "|" + DoubleToString(tick_age_seconds, 1) + "|false\r\n";
      rows++;
   }
   AC_EXTERNAL_WORKER_LAST_SNAPSHOT_ROWS = rows;
   return text;
}

AC_WriteResult AC_ExportExternalWorkerSnapshot()
{
   AC_WriteResult l6_input_write = AC_ExportLayer6CostFrictionInputPrimitives();

   string rows = AC_ExternalWorkerSnapshotRows();
   string payload_checksum = AC_ExternalWorkerPayloadChecksum(rows);
   if(AC_EXTERNAL_WORKER_LAST_SNAPSHOT_ID != "not_exported"
      && AC_EXTERNAL_WORKER_LAST_SNAPSHOT_PAYLOAD_CHECKSUM == payload_checksum)
   {
      AC_EXTERNAL_WORKER_LAST_SNAPSHOT_STATUS = "unchanged_cached";
      AC_EXTERNAL_WORKER_LAST_SNAPSHOT_MANIFEST_STATUS = "unchanged_cached";
      AC_EXTERNAL_WORKER_LAST_JOB_STATUS = "unchanged_cached";
      return AC_MakeSyntheticWriteResult(AC_ExternalWorkerSnapshotPath(), true, "unchanged_cached", AC_EXTERNAL_WORKER_LAST_SNAPSHOT_SIZE, "snapshot_payload_unchanged_no_rewrite|l6_input=" + l6_input_write.status);
   }

   string snapshot_id = AC_ExternalWorkerSnapshotId();
   string job_id = AC_ExternalWorkerJobId(snapshot_id);
   string snapshot = AC_ExternalWorkerSnapshotHeader(snapshot_id, job_id, AC_EXTERNAL_WORKER_LAST_SNAPSHOT_ROWS, payload_checksum) + rows;
   AC_WriteResult snapshot_write = AC_WriteTextFile(AC_ExternalWorkerSnapshotPath(), snapshot);
   string manifest = "schema_name=aurora_external_worker_snapshot_manifest\r\nschema_version=2\r\nsnapshot_id=" + snapshot_id + "\r\njob_bus_schema_version=" + AC_EXTERNAL_WORKER_JOB_BUS_SCHEMA_VERSION + "\r\njob_id=" + job_id + "\r\njob_type=" + AC_EXTERNAL_WORKER_DEFAULT_JOB_TYPE + "\r\njob_resource_class=" + AC_EXTERNAL_WORKER_JOB_RESOURCE_CLASS + "\r\njob_max_runtime_ms=" + IntegerToString(AC_EXTERNAL_WORKER_JOB_MAX_RUNTIME_MS) + "\r\nwrite_status=" + snapshot_write.status + "\r\nwrite_ok=" + (snapshot_write.ok ? "true" : "false") + "\r\nrow_count=" + IntegerToString(AC_EXTERNAL_WORKER_LAST_SNAPSHOT_ROWS) + "\r\npayload_checksum=" + payload_checksum + "\r\nauthority=" + AC_EXTERNAL_WORKER_AUTHORITY + "\r\ntrade_permission=false\r\nl6_input_primitives_status=" + l6_input_write.status + "\r\nl6_input_primitives_rows=" + IntegerToString(AC_L6_LAST_INPUT_ROWS) + "\r\nl6_input_primitives_path=" + AC_L6FrictionInputCsvPath() + "\r\n";
   AC_WriteResult manifest_write = AC_WriteTextFile(AC_ExternalWorkerSnapshotManifestPath(), manifest);
   AC_EXTERNAL_WORKER_LAST_SNAPSHOT_ID = snapshot_id;
   AC_EXTERNAL_WORKER_LAST_JOB_ID = job_id;
   AC_EXTERNAL_WORKER_LAST_JOB_TYPE = AC_EXTERNAL_WORKER_DEFAULT_JOB_TYPE;
   AC_EXTERNAL_WORKER_LAST_JOB_STATUS = snapshot_write.ok && manifest_write.ok ? "exported" : "degraded";
   AC_EXTERNAL_WORKER_LAST_SNAPSHOT_STATUS = snapshot_write.status;
   AC_EXTERNAL_WORKER_LAST_SNAPSHOT_MANIFEST_STATUS = manifest_write.status;
   AC_EXTERNAL_WORKER_LAST_SNAPSHOT_PAYLOAD_CHECKSUM = payload_checksum;
   AC_EXTERNAL_WORKER_LAST_SNAPSHOT_SIZE = snapshot_write.final_size;
   return snapshot_write;
}

#endif
