#ifndef AC_EXTERNAL_WORKER_L6_INPUT_PRIMITIVES_MQH
#define AC_EXTERNAL_WORKER_L6_INPUT_PRIMITIVES_MQH

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
static int    AC_L6_LAST_TICKVALUE_FALLBACK_OK = 0;
static int    AC_L6_LAST_VALUE_FORMULA_FALLBACK_OK = 0;
static int    AC_L6_LAST_CONTRACT_FALLBACK_OK = 0;
static int    AC_L6_LAST_COST_MODEL_MISMATCH_COUNT = 0;
static int    AC_L6_LAST_ZERO_COST_NONZERO_SPREAD_COUNT = 0;
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

string AC_L6RatioCsv(const double value)
{
   return DoubleToString(value, 6);
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

string AC_L6CostModelCompareStatus(const double primary_cost,
                                   const double fallback_cost,
                                   const string fallback_status,
                                   double &ratio)
{
   ratio = 0.0;
   if(primary_cost <= 0.0)
      return "primary_unavailable_or_zero";
   if(fallback_status != "ok" || fallback_cost <= 0.0)
      return "fallback_unavailable";

   double high = MathMax(primary_cost, fallback_cost);
   double low = MathMin(primary_cost, fallback_cost);
   if(low <= 0.0)
      return "fallback_unavailable";

   ratio = high / low;
   if(ratio > 1.25)
      return "mismatch_gt_25pct";
   if(ratio > 1.10)
      return "warning_gt_10pct";
   return "aligned";
}

string AC_L6VolumeModelQuality(const double volume_min,
                               const double volume_step,
                               const double volume_max,
                               const double contract_size)
{
   if(volume_min <= 0.0 || volume_step <= 0.0 || volume_max <= 0.0)
      return "invalid_volume_grid";
   if(volume_min < 0.000001 || volume_step < 0.000001)
      return "micro_volume_grid_review";
   if(volume_max > 100000000.0)
      return "extreme_max_volume_review";
   if(contract_size >= 100000.0 && volume_min < 0.0001)
      return "micro_volume_large_contract_review";
   return "normal";
}

string AC_L6InputCsvHeader()
{
   return "symbol,l5_gate_status,l5_gate_reason,asset_class,ranking_group,digits,point,calculation_mode,currency_profit,currency_margin,account_currency,contract_size,volume_min,volume_step,volume_max,volume_model_quality,value_quality,margin_quality,quote_quality,surface_quality,bid,ask,mid,spread_price,spread_points,spread_bps,tick_age_seconds,zero_spread_state,tick_size,tick_value,tick_value_profit,tick_value_loss,money_per_price_unit_buy_1lot,money_per_price_unit_sell_1lot,value_source,tick_value_fallback_status_l3,tick_value_crosscheck_status_l3,spread_cost_buy_1lot_account,spread_cost_sell_1lot_account,spread_cost_worst_1lot_account,spread_cost_buy_minlot_account,spread_cost_sell_minlot_account,spread_cost_worst_minlot_account,ordercalcprofit_buy_1lot_status,ordercalcprofit_sell_1lot_status,ordercalcprofit_buy_minlot_status,ordercalcprofit_sell_minlot_status,ordercalcprofit_buy_1lot_error,ordercalcprofit_sell_1lot_error,ordercalcprofit_buy_minlot_error,ordercalcprofit_sell_minlot_error,cost_asymmetry_detected,tickvalue_spread_cost_1lot_account,tickvalue_spread_cost_minlot_account,tickvalue_cost_status,value_formula_spread_cost_1lot_account,value_formula_spread_cost_minlot_account,value_formula_cost_status,contract_spread_cost_1lot_raw,contract_spread_cost_minlot_raw,contract_cost_status,cost_model_primary,cost_model_compare_status,cost_model_mismatch_ratio,account_cost_zero_nonzero_spread_suspicious,commission_model_status,commission_score_policy,slippage_status,trade_permission\r\n";
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
   AC_L6_LAST_TICKVALUE_FALLBACK_OK = 0;
   AC_L6_LAST_VALUE_FORMULA_FALLBACK_OK = 0;
   AC_L6_LAST_CONTRACT_FALLBACK_OK = 0;
   AC_L6_LAST_COST_MODEL_MISMATCH_COUNT = 0;
   AC_L6_LAST_ZERO_COST_NONZERO_SPREAD_COUNT = 0;
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
      long calculation_mode = -1;
      string currency_profit = "not_available";
      string currency_margin = "not_available";
      string account_currency = "not_available";
      double contract_size = 0.0;
      double volume_min = 0.0;
      double volume_step = 0.0;
      double volume_max = 0.0;
      string value_quality = "not_available";
      string margin_quality = "not_available";
      double tick_size = 0.0;
      double tick_value = 0.0;
      double tick_value_profit = 0.0;
      double tick_value_loss = 0.0;
      double money_per_price_unit_buy_1lot = 0.0;
      double money_per_price_unit_sell_1lot = 0.0;
      string value_source = "not_available";
      string tick_value_fallback_status_l3 = "not_available";
      string tick_value_crosscheck_status_l3 = "not_available";
      bool one_lot_in_range = false;
      bool min_lot_in_range = false;

      if(l3_index >= 0)
      {
         AC_L3SymbolSpecs l3 = AC_L3_SYMBOLS[l3_index];
         asset_class = l3.asset_class;
         ranking_group = l3.ranking_group;
         digits = l3.digits;
         point = l3.point;
         calculation_mode = l3.calculation_mode;
         currency_profit = l3.currency_profit;
         currency_margin = l3.currency_margin;
         account_currency = l3.account_currency;
         contract_size = l3.contract_size;
         volume_min = l3.volume_min;
         volume_step = l3.volume_step;
         volume_max = l3.volume_max;
         value_quality = l3.value_quality;
         margin_quality = l3.margin_quality;
         tick_size = l3.tick_size;
         tick_value = l3.tick_value;
         tick_value_profit = l3.tick_value_profit;
         tick_value_loss = l3.tick_value_loss;
         money_per_price_unit_buy_1lot = l3.money_per_price_unit_buy_1lot;
         money_per_price_unit_sell_1lot = l3.money_per_price_unit_sell_1lot;
         value_source = l3.value_source;
         tick_value_fallback_status_l3 = l3.tick_value_fallback_status;
         tick_value_crosscheck_status_l3 = l3.tick_value_crosscheck_status;
         one_lot_in_range = AC_L6VolumeInRange(1.0, l3);
         min_lot_in_range = AC_L6VolumeInRange(l3.volume_min, l3);
      }

      string quote_quality = "not_available";
      string surface_quality = "not_available";
      double bid = 0.0;
      double ask = 0.0;
      double mid = 0.0;
      double spread_price = 0.0;
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
         if(bid > 0.0 && ask > 0.0)
         {
            mid = (bid + ask) / 2.0;
            spread_price = MathAbs(ask - bid);
         }
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

      double tick_ref_value = MathMax(tick_value_loss, MathMax(tick_value_profit, tick_value));
      double tickvalue_cost_1lot = 0.0;
      double tickvalue_cost_minlot = 0.0;
      string tickvalue_cost_status = "unavailable";
      if(spread_price >= 0.0 && tick_size > 0.0 && tick_ref_value > 0.0)
      {
         double ticks_in_spread = spread_price / tick_size;
         tickvalue_cost_1lot = ticks_in_spread * tick_ref_value;
         tickvalue_cost_minlot = tickvalue_cost_1lot * volume_min;
         tickvalue_cost_status = "ok";
         AC_L6_LAST_TICKVALUE_FALLBACK_OK++;
      }
      else if(tick_size <= 0.0 || tick_ref_value <= 0.0)
      {
         tickvalue_cost_status = "tickvalue_unavailable_or_zero";
      }

      double value_formula_ppu = MathMax(money_per_price_unit_buy_1lot, money_per_price_unit_sell_1lot);
      double value_formula_cost_1lot = 0.0;
      double value_formula_cost_minlot = 0.0;
      string value_formula_cost_status = "unavailable";
      if(spread_price >= 0.0 && value_formula_ppu > 0.0)
      {
         value_formula_cost_1lot = spread_price * value_formula_ppu;
         value_formula_cost_minlot = value_formula_cost_1lot * volume_min;
         value_formula_cost_status = "ok";
         AC_L6_LAST_VALUE_FORMULA_FALLBACK_OK++;
      }

      double contract_cost_1lot = 0.0;
      double contract_cost_minlot = 0.0;
      string contract_cost_status = "unavailable";
      if(spread_price >= 0.0 && contract_size > 0.0)
      {
         contract_cost_1lot = spread_price * contract_size;
         contract_cost_minlot = contract_cost_1lot * volume_min;
         if(currency_profit == account_currency)
            contract_cost_status = "raw_account_currency_ok";
         else
            contract_cost_status = "raw_profit_currency_not_account";
         AC_L6_LAST_CONTRACT_FALLBACK_OK++;
      }

      double compare_ratio = 0.0;
      string compare_status = AC_L6CostModelCompareStatus(worst_minlot, value_formula_cost_minlot, value_formula_cost_status, compare_ratio);
      if(compare_status == "fallback_unavailable")
         compare_status = AC_L6CostModelCompareStatus(worst_minlot, tickvalue_cost_minlot, tickvalue_cost_status, compare_ratio);
      if(compare_status == "fallback_unavailable" && contract_cost_status == "raw_account_currency_ok")
         compare_status = AC_L6CostModelCompareStatus(worst_minlot, contract_cost_minlot, "ok", compare_ratio);
      if(compare_status == "mismatch_gt_25pct" || compare_status == "warning_gt_10pct")
         AC_L6_LAST_COST_MODEL_MISMATCH_COUNT++;

      bool zero_cost_nonzero_spread = (worst_minlot <= 0.0 && spread_price > 0.0 && spread_bps > 0.0);
      if(zero_cost_nonzero_spread) AC_L6_LAST_ZERO_COST_NONZERO_SPREAD_COUNT++;

      string volume_model_quality = AC_L6VolumeModelQuality(volume_min, volume_step, volume_max, contract_size);
      string commission_model_status = "not_available_from_api";
      string commission_score_policy = "penalize_unknown_commission_and_cap_elite";

      text += AC_L6CsvSafe(symbol)
         + "," + AC_L6CsvSafe(AC_L5_SYMBOLS[i].gate_status)
         + "," + AC_L6CsvSafe(AC_L5_SYMBOLS[i].gate_reason)
         + "," + AC_L6CsvSafe(asset_class)
         + "," + AC_L6CsvSafe(ranking_group)
         + "," + IntegerToString((int)digits)
         + "," + DoubleToString(point, 10)
         + "," + IntegerToString((int)calculation_mode)
         + "," + AC_L6CsvSafe(currency_profit)
         + "," + AC_L6CsvSafe(currency_margin)
         + "," + AC_L6CsvSafe(account_currency)
         + "," + DoubleToString(contract_size, 8)
         + "," + AC_L6VolumeCsv(volume_min)
         + "," + AC_L6VolumeCsv(volume_step)
         + "," + AC_L6VolumeCsv(volume_max)
         + "," + AC_L6CsvSafe(volume_model_quality)
         + "," + AC_L6CsvSafe(value_quality)
         + "," + AC_L6CsvSafe(margin_quality)
         + "," + AC_L6CsvSafe(quote_quality)
         + "," + AC_L6CsvSafe(surface_quality)
         + "," + AC_L6PriceCsv(bid)
         + "," + AC_L6PriceCsv(ask)
         + "," + AC_L6PriceCsv(mid)
         + "," + AC_L6PriceCsv(spread_price)
         + "," + DoubleToString(spread_points, 4)
         + "," + DoubleToString(spread_bps, 6)
         + "," + DoubleToString(tick_age_seconds, 3)
         + "," + AC_L6CsvSafe(zero_spread_state)
         + "," + DoubleToString(tick_size, 10)
         + "," + AC_L6MoneyCsv(tick_value)
         + "," + AC_L6MoneyCsv(tick_value_profit)
         + "," + AC_L6MoneyCsv(tick_value_loss)
         + "," + AC_L6MoneyCsv(money_per_price_unit_buy_1lot)
         + "," + AC_L6MoneyCsv(money_per_price_unit_sell_1lot)
         + "," + AC_L6CsvSafe(value_source)
         + "," + AC_L6CsvSafe(tick_value_fallback_status_l3)
         + "," + AC_L6CsvSafe(tick_value_crosscheck_status_l3)
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
         + "," + AC_L6MoneyCsv(tickvalue_cost_1lot)
         + "," + AC_L6MoneyCsv(tickvalue_cost_minlot)
         + "," + AC_L6CsvSafe(tickvalue_cost_status)
         + "," + AC_L6MoneyCsv(value_formula_cost_1lot)
         + "," + AC_L6MoneyCsv(value_formula_cost_minlot)
         + "," + AC_L6CsvSafe(value_formula_cost_status)
         + "," + AC_L6MoneyCsv(contract_cost_1lot)
         + "," + AC_L6MoneyCsv(contract_cost_minlot)
         + "," + AC_L6CsvSafe(contract_cost_status)
         + ",ordercalcprofit"
         + "," + AC_L6CsvSafe(compare_status)
         + "," + AC_L6RatioCsv(compare_ratio)
         + "," + AC_L6BoolCsv(zero_cost_nonzero_spread)
         + "," + AC_L6CsvSafe(commission_model_status)
         + "," + AC_L6CsvSafe(commission_score_policy)
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
   manifest += "schema_version=3\r\n";
   manifest += "layer_id=6\r\n";
   manifest += "layer_name=Layer 6 - Cost / Friction Input Primitives\r\n";
   manifest += "owner_name=Runtime 4 - Surface Scoring Owner reserved; input primitives only in current source\r\n";
   manifest += "job_type=L6_COST_FRICTION_INPUT_PRIMITIVES_V1\r\n";
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
   manifest += "tickvalue_fallback_ok_count=" + IntegerToString(AC_L6_LAST_TICKVALUE_FALLBACK_OK) + "\r\n";
   manifest += "value_formula_fallback_ok_count=" + IntegerToString(AC_L6_LAST_VALUE_FORMULA_FALLBACK_OK) + "\r\n";
   manifest += "contract_fallback_ok_count=" + IntegerToString(AC_L6_LAST_CONTRACT_FALLBACK_OK) + "\r\n";
   manifest += "cost_model_mismatch_count=" + IntegerToString(AC_L6_LAST_COST_MODEL_MISMATCH_COUNT) + "\r\n";
   manifest += "zero_cost_nonzero_spread_suspicious_count=" + IntegerToString(AC_L6_LAST_ZERO_COST_NONZERO_SPREAD_COUNT) + "\r\n";
   manifest += "source_truth_owner=L5_pass_set_plus_L3_L4_packets_plus_MT5_OrderCalcProfit_primitives_plus_value_formula_tickvalue_contract_fallbacks\r\n";
   manifest += "calculation_support_owner=Runtime3_Calculation_Gateway_L6_cost_friction_ranking_support\r\n";
   manifest += "authority=" + AC_EXTERNAL_WORKER_AUTHORITY + "\r\n";
   manifest += "trade_permission=false\r\n";
   manifest += "input_primitives_only=true\r\n";
   manifest += "ranking_runtime=false\r\n";
   manifest += "ranked_output_runtime=false\r\n";
   manifest += "selection_runtime=false\r\n";
   manifest += "generated_unix=" + IntegerToString((int)TimeGMT()) + "\r\n";

   AC_WriteResult manifest_write = AC_WriteTextFile(AC_L6FrictionInputManifestPath(), manifest);
   AC_L6_LAST_INPUT_EXPORT_STATUS = csv_write.status;
   AC_L6_LAST_INPUT_MANIFEST_STATUS = manifest_write.status;
   AC_L6_LAST_INPUT_PAYLOAD_CHECKSUM = payload_checksum;
   AC_L6_LAST_INPUT_SIZE = csv_write.final_size;
   return csv_write;
}

#endif
