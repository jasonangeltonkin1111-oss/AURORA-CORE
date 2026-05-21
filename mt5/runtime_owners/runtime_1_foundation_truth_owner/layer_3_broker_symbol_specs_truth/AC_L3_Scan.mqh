#ifndef AC_L3_SCAN_MQH
#define AC_L3_SCAN_MQH

void AC_BuildLayer3Texts();

bool AC_L3GetInteger(const string symbol, const ENUM_SYMBOL_INFO_INTEGER prop, long &value, const string field, AC_L3SymbolSpecs &s)
{
   ResetLastError();
   if(SymbolInfoInteger(symbol, prop, value))
   {
      AC_L3_SYMBOLINFO_INTEGER_SUCCESS++;
      s.required_fields_ok++;
      return true;
   }
   AC_L3_SYMBOLINFO_INTEGER_FAILURE++;
   s.required_fields_failed++;
   s.missing_required_fields += field + "; ";
   return false;
}

bool AC_L3GetDouble(const string symbol, const ENUM_SYMBOL_INFO_DOUBLE prop, double &value, const string field, AC_L3SymbolSpecs &s)
{
   ResetLastError();
   if(SymbolInfoDouble(symbol, prop, value))
   {
      AC_L3_SYMBOLINFO_DOUBLE_SUCCESS++;
      s.required_fields_ok++;
      return true;
   }
   AC_L3_SYMBOLINFO_DOUBLE_FAILURE++;
   s.required_fields_failed++;
   s.missing_required_fields += field + "; ";
   return false;
}

bool AC_L3GetOptionalInteger(const string symbol, const ENUM_SYMBOL_INFO_INTEGER prop, long &value)
{
   ResetLastError();
   return SymbolInfoInteger(symbol, prop, value);
}

bool AC_L3GetString(const string symbol, const ENUM_SYMBOL_INFO_STRING prop, string &value, const string field)
{
   ResetLastError();
   if(SymbolInfoString(symbol, prop, value))
   {
      AC_L3_SYMBOLINFO_STRING_SUCCESS++;
      return true;
   }
   AC_L3_SYMBOLINFO_STRING_FAILURE++;
   value = "";
   return false;
}

void AC_L3InitSymbol(AC_L3SymbolSpecs &s, const string symbol)
{
   s.symbol = symbol;
   s.l2_market_state = AC_L2MarketStateForSymbol(symbol);
   s.l2_allows_deeper_layers = AC_L2AllowsDeeperLayers(symbol);
   s.scan_state = "Pending";
   s.description = "";
   s.path = "";
   s.currency_base = "";
   s.currency_profit = "";
   s.currency_margin = "";
   s.account_currency = AccountInfoString(ACCOUNT_CURRENCY);
   s.digits = 0;
   s.point = 0.0;
   s.tick_size = 0.0;
   s.tick_value = 0.0;
   s.tick_value_profit = 0.0;
   s.tick_value_loss = 0.0;
   s.contract_size = 0.0;
   s.volume_min = 0.0;
   s.volume_max = 0.0;
   s.volume_step = 0.0;
   s.volume_limit = 0.0;
   s.trade_mode = -1;
   s.execution_mode = -1;
   s.filling_mode = -1;
   s.order_mode = -1;
   s.expiration_mode = -1;
   s.gtc_mode = -1;
   s.stops_level = -1;
   s.freeze_level = -1;
   s.calculation_mode = -1;
   s.chart_mode = -1;
   s.spread_float = false;
   s.spread_points_spec = -1;
   s.swap_mode = -1;
   s.swap_long = 0.0;
   s.swap_short = 0.0;
   s.swap_rollover3days = -1;
   s.margin_initial_spec = 0.0;
   s.margin_maintenance_spec = 0.0;
   s.margin_hedged_spec = 0.0;
   s.margin_rate_buy_ok = false;
   s.margin_rate_sell_ok = false;
   s.margin_rate_buy_initial = 0.0;
   s.margin_rate_buy_maintenance = 0.0;
   s.margin_rate_sell_initial = 0.0;
   s.margin_rate_sell_maintenance = 0.0;
   s.margin_rate_buy_error = 0;
   s.margin_rate_sell_error = 0;
   s.margin_rate_buy_status = "Not checked";
   s.margin_rate_sell_status = "Not checked";
   s.order_calc_margin_buy_ok = false;
   s.order_calc_margin_sell_ok = false;
   s.margin_min_buy_ok = false;
   s.margin_min_sell_ok = false;
   s.margin_buy_1lot_account_ccy = 0.0;
   s.margin_sell_1lot_account_ccy = 0.0;
   s.margin_buy_minlot_account_ccy = 0.0;
   s.margin_sell_minlot_account_ccy = 0.0;
   s.order_calc_margin_buy_error = 0;
   s.order_calc_margin_sell_error = 0;
   s.margin_min_buy_error = 0;
   s.margin_min_sell_error = 0;
   s.margin_buy_status = "Not checked";
   s.margin_sell_status = "Not checked";
   s.margin_min_buy_status = "Not checked";
   s.margin_min_sell_status = "Not checked";
   s.order_calc_profit_buy_ok = false;
   s.order_calc_profit_sell_ok = false;
   s.value_from_tick_value = false;
   s.money_per_point_buy_1lot = 0.0;
   s.money_per_point_sell_1lot = 0.0;
   s.money_per_tick_buy_1lot = 0.0;
   s.money_per_tick_sell_1lot = 0.0;
   s.money_per_price_unit_buy_1lot = 0.0;
   s.money_per_price_unit_sell_1lot = 0.0;
   s.value_reference_buy_price = 0.0;
   s.value_reference_sell_price = 0.0;
   s.value_reference_buy_ok = false;
   s.value_reference_sell_ok = false;
   s.value_reference_error = 0;
   s.order_calc_profit_buy_error = 0;
   s.order_calc_profit_sell_error = 0;
   s.value_reference_detail = "Not checked";
   s.value_buy_status = "Not checked";
   s.value_sell_status = "Not checked";
   s.tick_value_fallback_status = "Not checked";
   s.tick_value_crosscheck_status = "Not available";
   s.price_reference_status = "Not available";
   s.value_source = "Not available";
   s.isin = "";
   s.exchange = "";
   s.sector = "";
   s.industry = "";
   s.country = "";
   s.asset_class = "Unknown";
   s.market_group = "Unknown";
   s.market_segment = "Unknown";
   s.ranking_group = "Unknown";
   s.classification_source = "Unresolved";
   s.classification_quality = "Bucket Unknown";
   s.classification_fallback_used = false;
   s.fundamental_supported = "Unsupported";
   s.fundamental_identity_quality = "Not available";
   s.yahoo_query = "Not available";
   s.google_finance_query = "Not available";
   s.marketwatch_query = "Not available";
   s.sec_edgar_query = "Not available";
   s.finviz_query = "Not available";
   s.morningstar_query = "Not available";
   s.link_truth = "Literal lookup links - not verified market data";
   s.required_fields_ok = 0;
   s.required_fields_failed = 0;
   s.missing_required_fields = "";
   s.source_quality = "Pending";
   s.value_quality = "Value Formula Unavailable";
   s.margin_quality = "Margin Formula Unavailable";
   s.volume_grid_quality = "Volume Grid Unavailable";
   s.failure_reason = "";
   s.trade_permission = false;
}

void AC_L3FinalizeCounters(const AC_L3SymbolSpecs &s)
{
   if(s.scan_state == "Skipped Unknown") { AC_L3_SKIPPED_UNKNOWN++; return; }
   if(s.l2_market_state == "closed") AC_L3_SKIPPED_CLOSED++;

   AC_L3_SCANNED_COUNT++;
   if(s.source_quality == "Specs Ready") AC_L3_SPEC_READY_COUNT++;
   else if(s.source_quality == "Specs Partial") AC_L3_SPEC_PARTIAL_COUNT++;
   else AC_L3_SPEC_UNAVAILABLE_COUNT++;
   if(s.required_fields_failed > 0) AC_L3_CRITICAL_MISSING_COUNT++;

   if(s.value_quality == "Value Formula Ready") AC_L3_VALUE_READY_COUNT++;
   else if(s.value_quality == "Value Formula Partial") AC_L3_VALUE_PARTIAL_COUNT++;
   else AC_L3_VALUE_UNAVAILABLE_COUNT++;

   if(s.margin_quality == "Margin Formula Ready") AC_L3_MARGIN_READY_COUNT++;
   else if(s.margin_quality == "Margin Formula Partial") AC_L3_MARGIN_PARTIAL_COUNT++;
   else AC_L3_MARGIN_UNAVAILABLE_COUNT++;

   if(s.volume_grid_quality == "Volume Grid Ready") AC_L3_VOLUME_GRID_READY_COUNT++;
   else AC_L3_VOLUME_GRID_INVALID_COUNT++;

   if(StringFind(s.classification_quality, "Bucket Ready") == 0)
   {
      AC_L3_BUCKET_READY_COUNT++;
      if(s.classification_fallback_used) AC_L3_BUCKET_FALLBACK_COUNT++;
   }
   else AC_L3_BUCKET_UNKNOWN_COUNT++;

   if(s.fundamental_supported == "Unsupported") AC_L3_FUNDAMENTAL_UNSUPPORTED_COUNT++;
   else if(s.fundamental_supported == "Identity ambiguous") AC_L3_FUNDAMENTAL_AMBIGUOUS_COUNT++;
   else AC_L3_FUNDAMENTAL_READY_COUNT++;
}

void AC_L3ScanOneSymbol(const string symbol)
{
   int next = ArraySize(AC_L3_SYMBOLS);
   ArrayResize(AC_L3_SYMBOLS, next + 1);
   AC_L3InitSymbol(AC_L3_SYMBOLS[next], symbol);

   if(AC_L3_SYMBOLS[next].l2_market_state == "unknown")
   {
      AC_L3_SYMBOLS[next].scan_state = "Skipped Unknown";
      AC_L3_SYMBOLS[next].source_quality = "Skipped - Market Unknown";
      AC_L3_SYMBOLS[next].failure_reason = "Layer 2 did not establish a known market state.";
      AC_L3FinalizeCounters(AC_L3_SYMBOLS[next]);
      return;
   }

   AC_L3_ELIGIBLE_FROM_L2++;
   AC_L3_SYMBOLS[next].scan_state = "Scanned";
   if(AC_L3_SYMBOLS[next].l2_market_state == "closed")
      AC_L3_SYMBOLS[next].failure_reason = "Layer 2 market is closed; Layer 3 specs still scanned. Layer 4 is the first cutoff layer. ";

   AC_L3GetString(symbol, SYMBOL_DESCRIPTION, AC_L3_SYMBOLS[next].description, "Description");
   AC_L3GetString(symbol, SYMBOL_PATH, AC_L3_SYMBOLS[next].path, "Path");
   AC_L3GetString(symbol, SYMBOL_CURRENCY_BASE, AC_L3_SYMBOLS[next].currency_base, "Base currency");
   AC_L3GetString(symbol, SYMBOL_CURRENCY_PROFIT, AC_L3_SYMBOLS[next].currency_profit, "Profit currency");
   AC_L3GetString(symbol, SYMBOL_CURRENCY_MARGIN, AC_L3_SYMBOLS[next].currency_margin, "Margin currency");

   AC_L3GetInteger(symbol, SYMBOL_DIGITS, AC_L3_SYMBOLS[next].digits, "Digits", AC_L3_SYMBOLS[next]);
   AC_L3GetInteger(symbol, SYMBOL_TRADE_MODE, AC_L3_SYMBOLS[next].trade_mode, "Trade mode", AC_L3_SYMBOLS[next]);
   AC_L3GetInteger(symbol, SYMBOL_TRADE_EXEMODE, AC_L3_SYMBOLS[next].execution_mode, "Execution mode", AC_L3_SYMBOLS[next]);
   AC_L3GetInteger(symbol, SYMBOL_FILLING_MODE, AC_L3_SYMBOLS[next].filling_mode, "Filling mode", AC_L3_SYMBOLS[next]);
   AC_L3GetInteger(symbol, SYMBOL_ORDER_MODE, AC_L3_SYMBOLS[next].order_mode, "Order mode", AC_L3_SYMBOLS[next]);
   AC_L3GetInteger(symbol, SYMBOL_EXPIRATION_MODE, AC_L3_SYMBOLS[next].expiration_mode, "Expiration mode", AC_L3_SYMBOLS[next]);
   AC_L3GetInteger(symbol, SYMBOL_ORDER_GTC_MODE, AC_L3_SYMBOLS[next].gtc_mode, "GTC mode", AC_L3_SYMBOLS[next]);
   AC_L3GetInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL, AC_L3_SYMBOLS[next].stops_level, "Stops level", AC_L3_SYMBOLS[next]);
   AC_L3GetInteger(symbol, SYMBOL_TRADE_FREEZE_LEVEL, AC_L3_SYMBOLS[next].freeze_level, "Freeze level", AC_L3_SYMBOLS[next]);
   AC_L3GetInteger(symbol, SYMBOL_TRADE_CALC_MODE, AC_L3_SYMBOLS[next].calculation_mode, "Calculation mode", AC_L3_SYMBOLS[next]);
   AC_L3GetInteger(symbol, SYMBOL_CHART_MODE, AC_L3_SYMBOLS[next].chart_mode, "Chart mode", AC_L3_SYMBOLS[next]);
   long spread_float_int = 0;
   if(AC_L3GetInteger(symbol, SYMBOL_SPREAD_FLOAT, spread_float_int, "Spread type", AC_L3_SYMBOLS[next])) AC_L3_SYMBOLS[next].spread_float = (spread_float_int != 0);
   long spread_points = 0;
   if(AC_L3GetOptionalInteger(symbol, SYMBOL_SPREAD, spread_points)) AC_L3_SYMBOLS[next].spread_points_spec = spread_points;
   AC_L3GetInteger(symbol, SYMBOL_SWAP_MODE, AC_L3_SYMBOLS[next].swap_mode, "Swap mode", AC_L3_SYMBOLS[next]);
   AC_L3GetInteger(symbol, SYMBOL_SWAP_ROLLOVER3DAYS, AC_L3_SYMBOLS[next].swap_rollover3days, "Swap rollover day", AC_L3_SYMBOLS[next]);

   AC_L3GetDouble(symbol, SYMBOL_POINT, AC_L3_SYMBOLS[next].point, "Point", AC_L3_SYMBOLS[next]);
   AC_L3GetDouble(symbol, SYMBOL_TRADE_TICK_SIZE, AC_L3_SYMBOLS[next].tick_size, "Tick size", AC_L3_SYMBOLS[next]);
   AC_L3GetDouble(symbol, SYMBOL_TRADE_TICK_VALUE, AC_L3_SYMBOLS[next].tick_value, "Tick value", AC_L3_SYMBOLS[next]);
   AC_L3GetDouble(symbol, SYMBOL_TRADE_TICK_VALUE_PROFIT, AC_L3_SYMBOLS[next].tick_value_profit, "Tick value profit", AC_L3_SYMBOLS[next]);
   AC_L3GetDouble(symbol, SYMBOL_TRADE_TICK_VALUE_LOSS, AC_L3_SYMBOLS[next].tick_value_loss, "Tick value loss", AC_L3_SYMBOLS[next]);
   AC_L3GetDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE, AC_L3_SYMBOLS[next].contract_size, "Contract size", AC_L3_SYMBOLS[next]);
   AC_L3GetDouble(symbol, SYMBOL_VOLUME_MIN, AC_L3_SYMBOLS[next].volume_min, "Minimum volume", AC_L3_SYMBOLS[next]);
   AC_L3GetDouble(symbol, SYMBOL_VOLUME_MAX, AC_L3_SYMBOLS[next].volume_max, "Maximum volume", AC_L3_SYMBOLS[next]);
   AC_L3GetDouble(symbol, SYMBOL_VOLUME_STEP, AC_L3_SYMBOLS[next].volume_step, "Volume step", AC_L3_SYMBOLS[next]);
   AC_L3GetDouble(symbol, SYMBOL_VOLUME_LIMIT, AC_L3_SYMBOLS[next].volume_limit, "Volume limit", AC_L3_SYMBOLS[next]);
   AC_L3GetDouble(symbol, SYMBOL_SWAP_LONG, AC_L3_SYMBOLS[next].swap_long, "Swap long", AC_L3_SYMBOLS[next]);
   AC_L3GetDouble(symbol, SYMBOL_SWAP_SHORT, AC_L3_SYMBOLS[next].swap_short, "Swap short", AC_L3_SYMBOLS[next]);
   AC_L3GetDouble(symbol, SYMBOL_MARGIN_INITIAL, AC_L3_SYMBOLS[next].margin_initial_spec, "Initial margin", AC_L3_SYMBOLS[next]);
   AC_L3GetDouble(symbol, SYMBOL_MARGIN_MAINTENANCE, AC_L3_SYMBOLS[next].margin_maintenance_spec, "Maintenance margin", AC_L3_SYMBOLS[next]);
   AC_L3GetDouble(symbol, SYMBOL_MARGIN_HEDGED, AC_L3_SYMBOLS[next].margin_hedged_spec, "Hedged margin", AC_L3_SYMBOLS[next]);

   AC_L3_SYMBOLS[next].volume_grid_quality = AC_L3VolumeGridQuality(AC_L3_SYMBOLS[next]);
   AC_L3ClassifySymbol(AC_L3_SYMBOLS[next]);
   AC_L3BuildFundamentalHints(AC_L3_SYMBOLS[next]);
   AC_L3CalculateValueAndMargin(AC_L3_SYMBOLS[next]);
   AC_L3_SYMBOLS[next].source_quality = AC_L3SpecQualityText(AC_L3_SYMBOLS[next]);
   if(AC_L3_SYMBOLS[next].failure_reason != "" && AC_L3_WORST_FAILURE_REASON == "None") AC_L3_WORST_FAILURE_REASON = AC_L3_SYMBOLS[next].failure_reason;
   AC_L3FinalizeCounters(AC_L3_SYMBOLS[next]);
}

void AC_RefreshLayer3BrokerSpecsTruth()
{
   AC_L3Reset();
   int total = SymbolsTotal(false);
   AC_L3_LAST_SYMBOLS_TOTAL = total;
   AC_L3_LAST_L2_ROUTE_KEY = AC_L2_ROUTE_GENERATION_KEY;
   AC_L3_CACHE_KEY = AC_DOSSIER_SHELL_SCHEMA_VERSION + " | L2 " + AC_L2_ROUTE_GENERATION_KEY + " | symbols " + IntegerToString(total);

   for(int idx = 0; idx < total; idx++)
   {
      string symbol = SymbolName(idx, false);
      if(symbol == "") continue;
      AC_L3ScanOneSymbol(symbol);
   }

   AC_L3_SCAN_STATUS = "Complete";
   if(AC_L3_SPEC_PARTIAL_COUNT > 0 || AC_L3_SPEC_UNAVAILABLE_COUNT > 0 || AC_L3_VALUE_UNAVAILABLE_COUNT > 0) AC_L3_SCAN_STATUS = "Complete with warnings";
   AC_L3_SCAN_DURATION_MS = GetTickCount() - AC_L3_SCAN_STARTED_MS;
   AC_L3_READY = true;
   AC_BuildLayer3Texts();
}

bool AC_L3ShouldRunFullScan()
{
   if(!AC_L3_READY) return true;
   if(AC_L3_LAST_SYMBOLS_TOTAL != SymbolsTotal(false)) return true;
   if(AC_L3_LAST_L2_ROUTE_KEY != AC_L2_ROUTE_GENERATION_KEY) return true;
   return false;
}

#endif