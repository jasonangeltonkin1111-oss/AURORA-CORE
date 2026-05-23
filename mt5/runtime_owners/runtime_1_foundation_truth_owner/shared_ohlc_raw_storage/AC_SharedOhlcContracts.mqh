#ifndef AC_SHARED_OHLC_CONTRACTS_MQH
#define AC_SHARED_OHLC_CONTRACTS_MQH

// Runtime 1 support service - Shared OHLC Raw Storage Owner.
// This module defines raw storage contracts only.
// It must not calculate range, wick/body geometry, ATR, trend, volatility, scoring, ranking, selection, permission, or execution.

static const string AC_SHARED_OHLC_OWNER_NAME = "Runtime 1 Support - Shared OHLC Raw Storage Owner";
static const string AC_SHARED_OHLC_SCHEMA_VERSION = "shared_ohlc_raw_store_v1";
static const string AC_SHARED_OHLC_AUTHORITY = "raw_mqlrates_storage_only";
static const string AC_SHARED_OHLC_SOURCE_API = "CopyRates_MqlRates";
static const string AC_SHARED_OHLC_LAYER_ACCESS_POLICY = "future_layers_read_shared_ohlc_owner_no_private_copyrates_no_private_candle_cache";
static const string AC_SHARED_OHLC_CALCULATION_POLICY = "no_calculations_in_storage_owner_gateway_or_layers_calculate_only_under_their_own_contract";
static const string AC_SHARED_OHLC_SURFACE_POLICY = "board_overview_only_dossier_availability_only_no_raw_bar_dump_until_dedicated_future_layer";

static const int AC_SHARED_OHLC_TARGET_SEED_BARS = 1500;
static const int AC_SHARED_OHLC_MAX_COPY_PER_SLICE = 1500;
static const int AC_SHARED_OHLC_BOOT_SEED_SLICE_BUDGET_MS = 40;
static const int AC_SHARED_OHLC_APPEND_SLICE_BUDGET_MS = 25;
static const int AC_SHARED_OHLC_CURRENT_BAR_COPY_COUNT = 1;

static const int AC_SHARED_OHLC_PRIORITY_OPEN_OR_PENDING = 1;
static const int AC_SHARED_OHLC_PRIORITY_L5_PASS = 2;
static const int AC_SHARED_OHLC_PRIORITY_FUTURE_CANDIDATE = 3;
static const int AC_SHARED_OHLC_PRIORITY_OTHER_OPEN = 4;
static const int AC_SHARED_OHLC_PRIORITY_CLOSED_BLOCKED_UNKNOWN = 5;

struct AC_SharedOhlcTimeframeContract
{
   string label;
   ENUM_TIMEFRAMES timeframe;
   int target_bars;
   bool enabled;
};

struct AC_SharedOhlcSymbolTfStatus
{
   string symbol;
   string timeframe_label;
   int priority;
   int requested_bars;
   int copied_bars;
   datetime oldest_bar_time;
   datetime newest_closed_bar_time;
   datetime current_bar_time;
   bool seed_attempted;
   bool seed_complete;
   bool append_attempted;
   bool append_complete;
   string storage_status;
   string last_error_text;
};

void AC_SharedOhlcDefaultTimeframes(AC_SharedOhlcTimeframeContract &frames[])
{
   ArrayResize(frames, 6);

   frames[0].label = "M1";
   frames[0].timeframe = PERIOD_M1;
   frames[0].target_bars = AC_SHARED_OHLC_TARGET_SEED_BARS;
   frames[0].enabled = true;

   frames[1].label = "M5";
   frames[1].timeframe = PERIOD_M5;
   frames[1].target_bars = AC_SHARED_OHLC_TARGET_SEED_BARS;
   frames[1].enabled = true;

   frames[2].label = "M15";
   frames[2].timeframe = PERIOD_M15;
   frames[2].target_bars = AC_SHARED_OHLC_TARGET_SEED_BARS;
   frames[2].enabled = true;

   frames[3].label = "H1";
   frames[3].timeframe = PERIOD_H1;
   frames[3].target_bars = AC_SHARED_OHLC_TARGET_SEED_BARS;
   frames[3].enabled = true;

   frames[4].label = "H4";
   frames[4].timeframe = PERIOD_H4;
   frames[4].target_bars = AC_SHARED_OHLC_TARGET_SEED_BARS;
   frames[4].enabled = true;

   frames[5].label = "D1";
   frames[5].timeframe = PERIOD_D1;
   frames[5].target_bars = AC_SHARED_OHLC_TARGET_SEED_BARS;
   frames[5].enabled = true;
}

#endif
