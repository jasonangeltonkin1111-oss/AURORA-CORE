#ifndef AC_L3_TYPES_MQH
#define AC_L3_TYPES_MQH

struct AC_L3SymbolSpecs
{
   string symbol;
   string l2_market_state;
   bool   l2_allows_deeper_layers;
   string scan_state;

   string description;
   string path;
   string currency_base;
   string currency_profit;
   string currency_margin;
   string account_currency;

   long   digits;
   double point;
   double tick_size;
   double tick_value;
   double tick_value_profit;
   double tick_value_loss;
   double contract_size;

   double volume_min;
   double volume_max;
   double volume_step;
   double volume_limit;

   long trade_mode;
   long execution_mode;
   long filling_mode;
   long order_mode;
   long expiration_mode;
   long gtc_mode;
   long stops_level;
   long freeze_level;
   long calculation_mode;
   long chart_mode;

   bool spread_float;
   long spread_points_spec;

   long swap_mode;
   double swap_long;
   double swap_short;
   long swap_rollover3days;

   double margin_initial_spec;
   double margin_maintenance_spec;
   double margin_hedged_spec;

   bool margin_rate_buy_ok;
   bool margin_rate_sell_ok;
   double margin_rate_buy_initial;
   double margin_rate_buy_maintenance;
   double margin_rate_sell_initial;
   double margin_rate_sell_maintenance;
   int margin_rate_buy_error;
   int margin_rate_sell_error;
   string margin_rate_buy_status;
   string margin_rate_sell_status;

   bool order_calc_margin_buy_ok;
   bool order_calc_margin_sell_ok;
   bool margin_min_buy_ok;
   bool margin_min_sell_ok;
   double margin_buy_1lot_account_ccy;
   double margin_sell_1lot_account_ccy;
   double margin_buy_minlot_account_ccy;
   double margin_sell_minlot_account_ccy;
   int order_calc_margin_buy_error;
   int order_calc_margin_sell_error;
   int margin_min_buy_error;
   int margin_min_sell_error;
   string margin_buy_status;
   string margin_sell_status;
   string margin_min_buy_status;
   string margin_min_sell_status;

   bool order_calc_profit_buy_ok;
   bool order_calc_profit_sell_ok;
   bool value_from_tick_value;
   double money_per_point_buy_1lot;
   double money_per_point_sell_1lot;
   double money_per_tick_buy_1lot;
   double money_per_tick_sell_1lot;
   double money_per_price_unit_buy_1lot;
   double money_per_price_unit_sell_1lot;
   double value_reference_buy_price;
   double value_reference_sell_price;
   bool value_reference_buy_ok;
   bool value_reference_sell_ok;
   int value_reference_error;
   int order_calc_profit_buy_error;
   int order_calc_profit_sell_error;
   string value_reference_detail;
   string value_buy_status;
   string value_sell_status;
   string tick_value_fallback_status;
   string tick_value_crosscheck_status;
   string price_reference_status;
   string value_source;

   string isin;
   string exchange;
   string sector;
   string industry;
   string country;
   string isin_status;
   string exchange_status;
   string sector_status;
   string industry_status;
   string country_status;
   string broker_metadata_status;
   string asset_class;
   string market_group;
   string market_segment;
   string ranking_group;
   string classification_source;
   string classification_quality;
   bool   classification_fallback_used;

   string fundamental_supported;
   string fundamental_identity_quality;
   string yahoo_query;
   string google_finance_query;
   string marketwatch_query;
   string sec_edgar_query;
   string finviz_query;
   string morningstar_query;
   string link_truth;

   int required_fields_ok;
   int required_fields_failed;
   string missing_required_fields;
   string source_quality;
   string value_quality;
   string margin_quality;
   string volume_grid_quality;
   string failure_reason;
   bool trade_permission;
};

#endif