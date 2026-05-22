#ifndef AC_L3_SCAN_ONE_MQH
#define AC_L3_SCAN_ONE_MQH
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
   AC_L3LoadBrokerMetadata(AC_L3_SYMBOLS[next]);
   AC_L3BuildFundamentalHints(AC_L3_SYMBOLS[next]);
   AC_L3CalculateValueAndMargin(AC_L3_SYMBOLS[next]);
   AC_L3_SYMBOLS[next].source_quality = AC_L3SpecQualityText(AC_L3_SYMBOLS[next]);
   if(AC_L3_SYMBOLS[next].failure_reason != "" && AC_L3_WORST_FAILURE_REASON == "None") AC_L3_WORST_FAILURE_REASON = AC_L3_SYMBOLS[next].failure_reason;
   AC_L3FinalizeCounters(AC_L3_SYMBOLS[next]);
}

#endif
