#ifndef AC_L3_RENDER_TRUTH_MQH
#define AC_L3_RENDER_TRUTH_MQH

string AC_L3Ratio(const int count, const int total)
{
   return IntegerToString(count) + " / " + IntegerToString(total);
}

string AC_L3DossierLine(const string label, const string value)
{
   return label + ": " + value + "\r\n";
}

void AC_L3AppendVisibleDossierLine(string &text, const string label, const string value)
{
   if(AC_L3MetadataValueVisible(value))
      text += AC_L3DossierLine(label, value);
}

string AC_L3ObservedMoneyText(const double value)
{
   return AC_L3MoneyText(value);
}

string AC_L3ObservedCalculationMoneyText(const double value, const bool available)
{
   return AC_L3CalculationMoneyText(value, available);
}

string AC_L3MarginRateText(const bool available, const double initial, const double maintenance)
{
   if(!available)
      return "Not available / Not available";
   return AC_L3NumberText(initial, 6) + " / " + AC_L3NumberText(maintenance, 6);
}

string AC_L3TruthStatusText()
{
   if(!AC_L3_READY)
      return "Pending";
   if(AC_L3_SPEC_UNAVAILABLE_COUNT > 0 || AC_L3_CRITICAL_MISSING_COUNT > 0)
      return "Degraded - specs incomplete";
   if(AC_L3_VALUE_UNAVAILABLE_COUNT > 0 || AC_L3_MARGIN_UNAVAILABLE_COUNT > 0)
      return "Degraded - value/margin unavailable";
   if(AC_L3_VALUE_PARTIAL_COUNT > 0 || AC_L3_MARGIN_PARTIAL_COUNT > 0)
      return "Review - specs complete with value/margin partials";
   return AC_L3_SCAN_STATUS;
}

string AC_L3ClosedLayer4Status(const string market_state)
{
   if(market_state == "closed") return "Cut off after Layer 3 until market reopens";
   if(market_state == "unknown") return "Blocked until Layer 2 confirms market state";
   return "Layer 4 quote, tick, and spread truth required next";
}

void AC_BuildLayer3Texts()
{
   int denom = AC_L3_ELIGIBLE_FROM_L2;
   AC_L3_BOARD_SECTION = "\r\nLAYER 3 - BROKER SPECS AND VALUE TRUTH\r\n";
   AC_L3_BOARD_SECTION += "----------------------------------------\r\n";
   AC_L3_BOARD_SECTION += "Status:                    " + AC_L3TruthStatusText() + "\r\n";
   AC_L3_BOARD_SECTION += "Scan Status:               " + AC_L3_SCAN_STATUS + "\r\n";
   AC_L3_BOARD_SECTION += "Eligible From Layer 2:      " + IntegerToString(AC_L3_ELIGIBLE_FROM_L2) + "\r\n";
   AC_L3_BOARD_SECTION += "Scanned:                   " + AC_L3Ratio(AC_L3_SCANNED_COUNT, denom) + "\r\n";
   AC_L3_BOARD_SECTION += "Closed Symbols Scanned:    " + IntegerToString(AC_L3_SKIPPED_CLOSED) + "\r\n";
   AC_L3_BOARD_SECTION += "Unknown Symbols Skipped:   " + IntegerToString(AC_L3_SKIPPED_UNKNOWN) + "\r\n";
   AC_L3_BOARD_SECTION += "Layer 4 Cutoff:            Open symbols only; closed symbols stop after Layer 3\r\n";
   AC_L3_BOARD_SECTION += "\r\nSpecification Readiness\r\n";
   AC_L3_BOARD_SECTION += "Specs Ready:               " + AC_L3Ratio(AC_L3_SPEC_READY_COUNT, denom) + "\r\n";
   AC_L3_BOARD_SECTION += "Specs Partial:             " + AC_L3Ratio(AC_L3_SPEC_PARTIAL_COUNT, denom) + "\r\n";
   AC_L3_BOARD_SECTION += "Specs Unavailable:         " + AC_L3Ratio(AC_L3_SPEC_UNAVAILABLE_COUNT, denom) + "\r\n";
   AC_L3_BOARD_SECTION += "Critical Missing Data:     " + AC_L3Ratio(AC_L3_CRITICAL_MISSING_COUNT, denom) + "\r\n";
   AC_L3_BOARD_SECTION += "\r\nValue and Margin Readiness\r\n";
   AC_L3_BOARD_SECTION += "Value Formula Ready:       " + AC_L3Ratio(AC_L3_VALUE_READY_COUNT, denom) + "\r\n";
   AC_L3_BOARD_SECTION += "Value Formula Partial:     " + AC_L3Ratio(AC_L3_VALUE_PARTIAL_COUNT, denom) + "\r\n";
   AC_L3_BOARD_SECTION += "Value Formula Unavailable: " + AC_L3Ratio(AC_L3_VALUE_UNAVAILABLE_COUNT, denom) + "\r\n";
   AC_L3_BOARD_SECTION += "Margin Formula Ready:      " + AC_L3Ratio(AC_L3_MARGIN_READY_COUNT, denom) + "\r\n";
   AC_L3_BOARD_SECTION += "Margin Formula Partial:    " + AC_L3Ratio(AC_L3_MARGIN_PARTIAL_COUNT, denom) + "\r\n";
   AC_L3_BOARD_SECTION += "Margin Formula Unavailable:" + AC_L3Ratio(AC_L3_MARGIN_UNAVAILABLE_COUNT, denom) + "\r\n";
   AC_L3_BOARD_SECTION += "Volume Grid Ready:         " + AC_L3Ratio(AC_L3_VOLUME_GRID_READY_COUNT, denom) + "\r\n";
   AC_L3_BOARD_SECTION += "\r\nClassification and Fundamental Links\r\n";
   AC_L3_BOARD_SECTION += "Taxonomy Ready:            " + AC_L3Ratio(AC_L3_BUCKET_READY_COUNT, denom) + "\r\n";
   AC_L3_BOARD_SECTION += "Taxonomy Fallback Used:    " + AC_L3Ratio(AC_L3_BUCKET_FALLBACK_COUNT, denom) + "\r\n";
   AC_L3_BOARD_SECTION += "Taxonomy Unknown:          " + AC_L3Ratio(AC_L3_BUCKET_UNKNOWN_COUNT, denom) + "\r\n";
   AC_L3_BOARD_SECTION += "Fundamental Links Ready:   " + AC_L3Ratio(AC_L3_FUNDAMENTAL_READY_COUNT, denom) + "\r\n";
   AC_L3_BOARD_SECTION += "Fundamental Unsupported:   " + AC_L3Ratio(AC_L3_FUNDAMENTAL_UNSUPPORTED_COUNT, denom) + "\r\n";
   AC_L3_BOARD_SECTION += "Identity Ambiguous:        " + AC_L3Ratio(AC_L3_FUNDAMENTAL_AMBIGUOUS_COUNT, denom) + "\r\n";
   AC_L3_BOARD_SECTION += "\r\nWorst Blocker:             " + AC_L3_WORST_FAILURE_REASON + "\r\n";
   AC_L3_BOARD_SECTION += "Scan Duration:             " + IntegerToString((int)AC_L3_SCAN_DURATION_MS) + " ms\r\n";
   AC_L3_BOARD_SECTION += "Trade Permission:          FALSE\r\n";
   AC_L3_BOARD_SECTION += "Next Layer:                Layer 4 quote, tick, and spread truth for ready open symbols\r\n";

   AC_L3_WORKBENCH_SECTION = "\r\nL3_BROKER_SPECS_VALUE_SCAN\r\n";
   AC_L3_WORKBENCH_SECTION += "----------------------------------------\r\n";
   AC_L3_WORKBENCH_SECTION += "truth_status=" + AC_L3TruthStatusText() + "\r\n";
   AC_L3_WORKBENCH_SECTION += "scan_status=" + AC_L3_SCAN_STATUS + "\r\n";
   AC_L3_WORKBENCH_SECTION += "scan_duration_ms=" + IntegerToString((int)AC_L3_SCAN_DURATION_MS) + "\r\n";
   AC_L3_WORKBENCH_SECTION += "eligible_from_l2_known=" + IntegerToString(AC_L3_ELIGIBLE_FROM_L2) + "\r\n";
   AC_L3_WORKBENCH_SECTION += "scanned_count=" + IntegerToString(AC_L3_SCANNED_COUNT) + "\r\n";
   AC_L3_WORKBENCH_SECTION += "closed_symbols_scanned=" + IntegerToString(AC_L3_SKIPPED_CLOSED) + "\r\n";
   AC_L3_WORKBENCH_SECTION += "unknown_symbols_skipped=" + IntegerToString(AC_L3_SKIPPED_UNKNOWN) + "\r\n";
   AC_L3_WORKBENCH_SECTION += "layer4_cutoff_rule=open_symbols_only_closed_symbols_stop_after_layer3\r\n";
   AC_L3_WORKBENCH_SECTION += "spec_ready_count=" + IntegerToString(AC_L3_SPEC_READY_COUNT) + "\r\n";
   AC_L3_WORKBENCH_SECTION += "spec_partial_count=" + IntegerToString(AC_L3_SPEC_PARTIAL_COUNT) + "\r\n";
   AC_L3_WORKBENCH_SECTION += "spec_unavailable_count=" + IntegerToString(AC_L3_SPEC_UNAVAILABLE_COUNT) + "\r\n";
   AC_L3_WORKBENCH_SECTION += "critical_missing_count=" + IntegerToString(AC_L3_CRITICAL_MISSING_COUNT) + "\r\n";
   AC_L3_WORKBENCH_SECTION += "value_ready_count=" + IntegerToString(AC_L3_VALUE_READY_COUNT) + "\r\n";
   AC_L3_WORKBENCH_SECTION += "value_partial_count=" + IntegerToString(AC_L3_VALUE_PARTIAL_COUNT) + "\r\n";
   AC_L3_WORKBENCH_SECTION += "value_unavailable_count=" + IntegerToString(AC_L3_VALUE_UNAVAILABLE_COUNT) + "\r\n";
   AC_L3_WORKBENCH_SECTION += "margin_ready_count=" + IntegerToString(AC_L3_MARGIN_READY_COUNT) + "\r\n";
   AC_L3_WORKBENCH_SECTION += "margin_partial_count=" + IntegerToString(AC_L3_MARGIN_PARTIAL_COUNT) + "\r\n";
   AC_L3_WORKBENCH_SECTION += "margin_unavailable_count=" + IntegerToString(AC_L3_MARGIN_UNAVAILABLE_COUNT) + "\r\n";
   AC_L3_WORKBENCH_SECTION += "symbol_info_integer_success=" + IntegerToString(AC_L3_SYMBOLINFO_INTEGER_SUCCESS) + "\r\n";
   AC_L3_WORKBENCH_SECTION += "symbol_info_integer_failure=" + IntegerToString(AC_L3_SYMBOLINFO_INTEGER_FAILURE) + "\r\n";
   AC_L3_WORKBENCH_SECTION += "symbol_info_double_success=" + IntegerToString(AC_L3_SYMBOLINFO_DOUBLE_SUCCESS) + "\r\n";
   AC_L3_WORKBENCH_SECTION += "symbol_info_double_failure=" + IntegerToString(AC_L3_SYMBOLINFO_DOUBLE_FAILURE) + "\r\n";
   AC_L3_WORKBENCH_SECTION += "symbol_info_string_success=" + IntegerToString(AC_L3_SYMBOLINFO_STRING_SUCCESS) + "\r\n";
   AC_L3_WORKBENCH_SECTION += "symbol_info_string_failure=" + IntegerToString(AC_L3_SYMBOLINFO_STRING_FAILURE) + "\r\n";
   AC_L3_WORKBENCH_SECTION += "order_calc_profit_buy_success=" + IntegerToString(AC_L3_ORDERCALC_PROFIT_BUY_SUCCESS) + "\r\n";
   AC_L3_WORKBENCH_SECTION += "order_calc_profit_buy_failure=" + IntegerToString(AC_L3_ORDERCALC_PROFIT_BUY_FAILURE) + "\r\n";
   AC_L3_WORKBENCH_SECTION += "order_calc_profit_sell_success=" + IntegerToString(AC_L3_ORDERCALC_PROFIT_SELL_SUCCESS) + "\r\n";
   AC_L3_WORKBENCH_SECTION += "order_calc_profit_sell_failure=" + IntegerToString(AC_L3_ORDERCALC_PROFIT_SELL_FAILURE) + "\r\n";
   AC_L3_WORKBENCH_SECTION += "order_calc_margin_buy_success=" + IntegerToString(AC_L3_ORDERCALC_MARGIN_BUY_SUCCESS) + "\r\n";
   AC_L3_WORKBENCH_SECTION += "order_calc_margin_buy_failure=" + IntegerToString(AC_L3_ORDERCALC_MARGIN_BUY_FAILURE) + "\r\n";
   AC_L3_WORKBENCH_SECTION += "order_calc_margin_sell_success=" + IntegerToString(AC_L3_ORDERCALC_MARGIN_SELL_SUCCESS) + "\r\n";
   AC_L3_WORKBENCH_SECTION += "order_calc_margin_sell_failure=" + IntegerToString(AC_L3_ORDERCALC_MARGIN_SELL_FAILURE) + "\r\n";
   AC_L3_WORKBENCH_SECTION += "margin_rate_buy_success=" + IntegerToString(AC_L3_MARGIN_RATE_BUY_SUCCESS) + "\r\n";
   AC_L3_WORKBENCH_SECTION += "margin_rate_buy_failure=" + IntegerToString(AC_L3_MARGIN_RATE_BUY_FAILURE) + "\r\n";
   AC_L3_WORKBENCH_SECTION += "margin_rate_sell_success=" + IntegerToString(AC_L3_MARGIN_RATE_SELL_SUCCESS) + "\r\n";
   AC_L3_WORKBENCH_SECTION += "margin_rate_sell_failure=" + IntegerToString(AC_L3_MARGIN_RATE_SELL_FAILURE) + "\r\n";
   AC_L3_WORKBENCH_SECTION += "cache_key=" + AC_L3_CACHE_KEY + "\r\n";
   AC_L3_WORKBENCH_SECTION += "broker_metadata_contradiction_count=" + IntegerToString(AC_L3_BROKER_METADATA_CONTRADICTION_COUNT) + "\r\n";
   AC_L3_WORKBENCH_SECTION += "hk_country_us_hidden_count=" + IntegerToString(AC_L3_HK_COUNTRY_US_HIDDEN_COUNT) + "\r\n";
   AC_L3_WORKBENCH_SECTION += "hk_exchange_xnym_hidden_count=" + IntegerToString(AC_L3_HK_EXCHANGE_XNYM_HIDDEN_COUNT) + "\r\n";
   AC_L3_WORKBENCH_SECTION += "broker_sector_industry_poison_count=" + IntegerToString(AC_L3_BROKER_SECTOR_INDUSTRY_POISON_COUNT) + "\r\n";
   AC_L3_WORKBENCH_SECTION += "trade_permission=false\r\n";
}

string AC_Layer3BoardSection()
{
   if(!AC_L3_READY) return "\r\nLAYER 3 - BROKER SPECS AND VALUE TRUTH\r\n----------------------------------------\r\nStatus: Pending\r\n";
   return AC_L3_BOARD_SECTION;
}

string AC_Layer3WorkbenchSection()
{
   if(!AC_L3_READY) return "\r\nL3_BROKER_SPECS_VALUE_SCAN\r\nstatus=pending\r\n";
   return AC_L3_WORKBENCH_SECTION;
}

string AC_Layer3DossierSection(const string symbol)
{
   string text = "\r\nLAYER 3 - BROKER SPECS AND VALUE TRUTH\r\n";
   text += "----------------------------------------\r\n";
   int idx = AC_L3FindIndex(symbol);
   if(idx < 0)
   {
      text += AC_L3DossierLine("Status", "Pending");
      text += AC_L3DossierLine("Trade Permission", "FALSE");
      return text;
   }

   AC_L3SymbolSpecs s = AC_L3_SYMBOLS[idx];
   text += AC_L3DossierLine("Status", s.scan_state);
   text += AC_L3DossierLine("Broker Static Specs", s.source_quality);
   if(s.l2_market_state == "closed")
      text += AC_L3DossierLine("Live Quote Truth", "Unavailable - market closed / no fresh tick");
   else
      text += AC_L3DossierLine("Live Quote Truth", "Pending Layer 4 quote/tick scan");
   text += AC_L3DossierLine("Value Formula", s.value_quality);
   text += AC_L3DossierLine("Margin Formula", s.margin_quality);
   text += AC_L3DossierLine("Volume Grid", s.volume_grid_quality);
   text += AC_L3DossierLine("Layer 4 Status", AC_L3ClosedLayer4Status(s.l2_market_state));
   text += AC_L3DossierLine("Trade Permission", "FALSE");

   if(s.scan_state != "Scanned")
   {
      text += AC_L3DossierLine("Reason", AC_L3TextOrNA(s.failure_reason));
      text += AC_L3DossierLine("Next Needed", "Layer 2 must confirm this symbol as open or closed before Layer 3 can scan it");
      return text;
   }

   text += "\r\nIdentity\r\n";
   text += AC_L3DossierLine("Description", AC_L3TextOrNA(s.description));
   text += AC_L3DossierLine("Path", AC_L3TextOrNA(s.path));
   AC_L3AppendVisibleDossierLine(text, "Exchange", s.exchange);
   AC_L3AppendVisibleDossierLine(text, "Sector", s.sector);
   AC_L3AppendVisibleDossierLine(text, "Industry", s.industry);
   AC_L3AppendVisibleDossierLine(text, "Country", s.country);
   if(s.broker_metadata_status != "Hidden - broker returned no displayable advisory metadata")
   {
      text += AC_L3DossierLine("Broker Metadata", s.broker_metadata_status);
      text += AC_L3DossierLine("Metadata Truth", "Broker advisory only; workbook/Runtime 2 taxonomy remains bucket authority");
   }

   text += "\r\nClassification\r\n";
   text += AC_L3DossierLine("Asset Class", s.asset_class);
   text += AC_L3DossierLine("Market Group", s.market_group);
   text += AC_L3DossierLine("Market Segment", s.market_segment);
   text += AC_L3DossierLine("Ranking Group", s.ranking_group);
   text += AC_L3DossierLine("Source", s.classification_source);
   text += AC_L3DossierLine("Quality", s.classification_quality);

   text += "\r\nFundamental Links\r\n";
   text += AC_L3DossierLine("Supported Type", s.fundamental_supported);
   text += AC_L3DossierLine("Identity Quality", s.fundamental_identity_quality);
   text += AC_L3DossierLine("Yahoo Finance URL", s.yahoo_query);
   text += AC_L3DossierLine("Google Finance URL", s.google_finance_query);
   text += AC_L3DossierLine("MarketWatch URL", s.marketwatch_query);
   text += AC_L3DossierLine("SEC EDGAR URL", s.sec_edgar_query);
   text += AC_L3DossierLine("Finviz URL", s.finviz_query);
   text += AC_L3DossierLine("Morningstar URL", s.morningstar_query);
   text += AC_L3DossierLine("Link Truth", s.link_truth);

   text += "\r\nBroker Contract\r\n";
   text += AC_L3DossierLine("Digits", IntegerToString((int)s.digits));
   text += AC_L3DossierLine("Point", AC_L3NumberText(s.point, 8));
   text += AC_L3DossierLine("Tick Size", AC_L3NumberText(s.tick_size, 8));
   text += AC_L3DossierLine("Tick Value", AC_L3NumberText(s.tick_value, 6));
   text += AC_L3DossierLine("Tick Value Profit", AC_L3NumberText(s.tick_value_profit, 6));
   text += AC_L3DossierLine("Tick Value Loss", AC_L3NumberText(s.tick_value_loss, 6));
   text += AC_L3DossierLine("Contract Size", AC_L3NumberText(s.contract_size, 4));

   text += "\r\nVolume Rules\r\n";
   text += AC_L3DossierLine("Minimum Volume", AC_L3NumberText(s.volume_min, 4));
   text += AC_L3DossierLine("Maximum Volume", AC_L3NumberText(s.volume_max, 4));
   text += AC_L3DossierLine("Volume Step", AC_L3NumberText(s.volume_step, 4));
   text += AC_L3DossierLine("Volume Limit", AC_L3NumberText(s.volume_limit, 4));

   text += "\r\nExecution Rules\r\n";
   text += AC_L3DossierLine("Trade Mode", AC_L3TradeModeText(s.trade_mode));
   text += AC_L3DossierLine("Execution Mode", IntegerToString((int)s.execution_mode));
   text += AC_L3DossierLine("Filling Mode", IntegerToString((int)s.filling_mode));
   text += AC_L3DossierLine("Order Mode", IntegerToString((int)s.order_mode));
   text += AC_L3DossierLine("Expiration Mode", IntegerToString((int)s.expiration_mode));
   text += AC_L3DossierLine("GTC Mode", IntegerToString((int)s.gtc_mode));
   text += AC_L3DossierLine("Stops Level", IntegerToString((int)s.stops_level) + " points");
   text += AC_L3DossierLine("Freeze Level", IntegerToString((int)s.freeze_level) + " points");

   text += "\r\nSpread Specification\r\n";
   text += AC_L3DossierLine("Floating Spread", AC_L3BoolText(s.spread_float));
   text += AC_L3DossierLine("Spread Points", IntegerToString((int)s.spread_points_spec));
   text += AC_L3DossierLine("Note", "Live bid, ask, tick freshness, and live spread belong to Layer 4");

   text += "\r\nSwap\r\n";
   text += AC_L3DossierLine("Swap Mode", IntegerToString((int)s.swap_mode));
   text += AC_L3DossierLine("Swap Long", AC_L3NumberText(s.swap_long, 6));
   text += AC_L3DossierLine("Swap Short", AC_L3NumberText(s.swap_short, 6));
   text += AC_L3DossierLine("Triple Swap Day", IntegerToString((int)s.swap_rollover3days));

   text += "\r\nValue Formula Primitives\r\n";
   text += AC_L3DossierLine("Account Currency", s.account_currency);
   text += AC_L3DossierLine("Profit Currency", AC_L3TextOrNA(s.currency_profit));
   text += AC_L3DossierLine("Margin Currency", AC_L3TextOrNA(s.currency_margin));
   text += AC_L3DossierLine("Price Reference", s.price_reference_status);
   text += AC_L3DossierLine("Reference Detail", s.value_reference_detail);
   text += AC_L3DossierLine("Reference Buy Price", AC_L3ReferencePriceText(s.value_reference_buy_ok, s.value_reference_buy_price));
   text += AC_L3DossierLine("Reference Sell Price", AC_L3ReferencePriceText(s.value_reference_sell_ok, s.value_reference_sell_price));
   text += AC_L3DossierLine("Value Source", s.value_source);
   text += AC_L3DossierLine("Money Per Point Buy One Lot", AC_L3ObservedCalculationMoneyText(s.money_per_point_buy_1lot, s.order_calc_profit_buy_ok || s.value_from_tick_value));
   text += AC_L3DossierLine("Money Per Point Buy Status", s.value_buy_status);
   text += AC_L3DossierLine("Money Per Point Sell One Lot", AC_L3ObservedCalculationMoneyText(s.money_per_point_sell_1lot, s.order_calc_profit_sell_ok || s.value_from_tick_value));
   text += AC_L3DossierLine("Money Per Point Sell Status", s.value_sell_status);
   text += AC_L3DossierLine("Money Per Tick Buy One Lot", AC_L3ObservedCalculationMoneyText(s.money_per_tick_buy_1lot, s.order_calc_profit_buy_ok || s.value_from_tick_value));
   text += AC_L3DossierLine("Money Per Tick Sell One Lot", AC_L3ObservedCalculationMoneyText(s.money_per_tick_sell_1lot, s.order_calc_profit_sell_ok || s.value_from_tick_value));
   text += AC_L3DossierLine("Tick Value Fallback", s.tick_value_fallback_status);
   text += AC_L3DossierLine("Tick Value Crosscheck", s.tick_value_crosscheck_status);

   text += "\r\nMargin Primitives\r\n";
   text += AC_L3DossierLine("Margin Buy One Lot", AC_L3ObservedCalculationMoneyText(s.margin_buy_1lot_account_ccy, s.order_calc_margin_buy_ok));
   text += AC_L3DossierLine("Margin Buy One Lot Status", s.margin_buy_status);
   text += AC_L3DossierLine("Margin Sell One Lot", AC_L3ObservedCalculationMoneyText(s.margin_sell_1lot_account_ccy, s.order_calc_margin_sell_ok));
   text += AC_L3DossierLine("Margin Sell One Lot Status", s.margin_sell_status);
   text += AC_L3DossierLine("Margin Buy Minimum Volume", AC_L3ObservedCalculationMoneyText(s.margin_buy_minlot_account_ccy, s.margin_min_buy_ok));
   text += AC_L3DossierLine("Margin Buy Minimum Volume Status", s.margin_min_buy_status);
   text += AC_L3DossierLine("Margin Sell Minimum Volume", AC_L3ObservedCalculationMoneyText(s.margin_sell_minlot_account_ccy, s.margin_min_sell_ok));
   text += AC_L3DossierLine("Margin Sell Minimum Volume Status", s.margin_min_sell_status);
   text += AC_L3DossierLine("Margin Rate Buy", AC_L3MarginRateText(s.margin_rate_buy_ok, s.margin_rate_buy_initial, s.margin_rate_buy_maintenance));
   text += AC_L3DossierLine("Margin Rate Buy Status", s.margin_rate_buy_status);
   text += AC_L3DossierLine("Margin Rate Sell", AC_L3MarginRateText(s.margin_rate_sell_ok, s.margin_rate_sell_initial, s.margin_rate_sell_maintenance));
   text += AC_L3DossierLine("Margin Rate Sell Status", s.margin_rate_sell_status);

   text += "\r\nQuality\r\n";
   text += AC_L3DossierLine("Required Fields Ready", IntegerToString(s.required_fields_ok));
   text += AC_L3DossierLine("Required Fields Missing", IntegerToString(s.required_fields_failed));
   text += AC_L3DossierLine("Missing Fields", AC_L3TextOrNA(s.missing_required_fields));
   text += AC_L3DossierLine("Failure Reason", AC_L3TextOrNA(s.failure_reason));
   text += AC_L3DossierLine("Next Needed", AC_L3ClosedLayer4Status(s.l2_market_state));
   return text;
}

string AC_Layer3StatusRow()
{
   return "schema_name=layer_status|schema_version=v3.4|layer_id=3|layer_name=" + AC_LAYER_3_NAME
      + "|source_owner=" + AC_RUNTIME1_OWNER
      + "|build_version=" + AC_BUILD_VERSION
      + "|upgrade_id=" + AC_UPGRADE_ID
      + "|layer_status=" + (AC_L3_READY ? AC_L3TruthStatusText() : "pending")
      + "|scan_status=" + (AC_L3_READY ? AC_L3_SCAN_STATUS : "pending")
      + "|eligible_from_l2_known=" + IntegerToString(AC_L3_ELIGIBLE_FROM_L2)
      + "|scanned_count=" + IntegerToString(AC_L3_SCANNED_COUNT)
      + "|closed_symbols_scanned=" + IntegerToString(AC_L3_SKIPPED_CLOSED)
      + "|unknown_symbols_skipped=" + IntegerToString(AC_L3_SKIPPED_UNKNOWN)
      + "|spec_ready_count=" + IntegerToString(AC_L3_SPEC_READY_COUNT)
      + "|value_ready_count=" + IntegerToString(AC_L3_VALUE_READY_COUNT)
      + "|value_partial_count=" + IntegerToString(AC_L3_VALUE_PARTIAL_COUNT)
      + "|value_unavailable_count=" + IntegerToString(AC_L3_VALUE_UNAVAILABLE_COUNT)
      + "|margin_ready_count=" + IntegerToString(AC_L3_MARGIN_READY_COUNT)
      + "|margin_partial_count=" + IntegerToString(AC_L3_MARGIN_PARTIAL_COUNT)
      + "|margin_unavailable_count=" + IntegerToString(AC_L3_MARGIN_UNAVAILABLE_COUNT)
      + "|taxonomy_ready_count=" + IntegerToString(AC_L3_BUCKET_READY_COUNT)
      + "|trade_permission=false";
}

#endif