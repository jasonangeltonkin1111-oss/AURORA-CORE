#ifndef AC_SELECTED_ROLLING_TICK_PACK_MQH
#define AC_SELECTED_ROLLING_TICK_PACK_MQH

// Layer 20 - Selected Rolling Tick Pack
// Source-present scaffold only until L1-L19 selected-scope truth is stable and overseer approves wiring.
// Purpose: selected-symbol rolling MT5 tick/spread proxy truth.
// Forbidden: institutional order flow, buy/sell pressure, setup confirmation, trade permission, execution, DOM, ATR/VWAP/indicator ownership.
// Runtime activation must remain blocked until this file is included deliberately and MetaEditor/runtime proof exists.

static const int    AC_L20_MAX_SELECTED_SYMBOLS       = 16;
static const int    AC_L20_MAX_TICKS_PER_SYMBOL       = 2048;
static const int    AC_L20_ROLLING_WINDOW_SECONDS     = 600;
static const int    AC_L20_INTERNAL_UPDATE_SECONDS    = 10;
static const int    AC_L20_PUBLISH_SECONDS            = 60;
static const int    AC_L20_RETIRED_GRACE_SECONDS      = 900;
static const double AC_L20_SPREAD_SPIKE_MULTIPLIER    = 2.5;
static const double AC_L20_SPREAD_SPIKE_SEVERE_MULT   = 4.0;

struct AC_L20SymbolSummary
{
   string symbol;
   string status;
   string reason;
   string selected_scope_source;
   int    tick_count_1m;
   int    tick_count_5m;
   int    tick_count_10m;
   double spread_min_points_10m;
   double spread_max_points_10m;
   double spread_avg_points_10m;
   double spread_stddev_points_10m;
   int    spread_spike_count_10m;
   int    spread_spike_minor_count_10m;
   int    spread_spike_major_count_10m;
   int    spread_spike_severe_count_10m;
   double tick_gap_avg_seconds;
   double tick_gap_max_seconds;
   int    bid_change_count_10m;
   int    ask_change_count_10m;
   int    last_change_count_10m;
   int    volume_change_count_10m;
   int    bid_up_count_10m;
   int    bid_down_count_10m;
   int    ask_up_count_10m;
   int    ask_down_count_10m;
   int    mid_change_count_10m;
   double mid_range_points_10m;
   int    ticks_appended_last_update;
   int    ticks_pruned_last_update;
   int    buffer_count;
   ulong  oldest_tick_msc;
   ulong  newest_tick_msc;
   int    latest_tick_age_seconds;
   int    copyticks_call_count;
   int    copyticksrange_call_count;
   int    copyticks_error_code;
   string flags_decode_status;
   string sample_quality;
   string proxy_confidence;
   string boundary_text;
   bool   trade_permission;
   bool   entry_signal;
   bool   execution;
   bool   institutional_order_flow_claim;
};

struct AC_L20LayerSummary
{
   string status;
   string reason;
   string selected_scope_source;
   int    selected_symbols_expected;
   int    selected_symbols_seen;
   int    selected_symbols_with_ticks;
   int    selected_symbols_missing_ticks;
   int    symbols_active;
   int    symbols_degraded;
   int    symbols_unavailable;
   int    total_spread_spike_count;
   int    gappy_symbol_count;
   int    reset_count_total;
   int    copyticks_call_count;
   int    copyticksrange_call_count;
   int    update_duration_ms;
   int    publish_duration_ms;
   string budget_status;
   string output_contract;
   bool   trade_permission;
   bool   entry_signal;
   bool   execution;
   bool   institutional_order_flow_claim;
};

string AC_L20_SYMBOLS[AC_L20_MAX_SELECTED_SYMBOLS];
bool   AC_L20_ACTIVE[AC_L20_MAX_SELECTED_SYMBOLS];
bool   AC_L20_RETIRED_GRACE[AC_L20_MAX_SELECTED_SYMBOLS];
ulong  AC_L20_RETIRED_UNTIL[AC_L20_MAX_SELECTED_SYMBOLS];
ulong  AC_L20_LAST_TICK_MSC[AC_L20_MAX_SELECTED_SYMBOLS];
int    AC_L20_RESET_COUNT[AC_L20_MAX_SELECTED_SYMBOLS];
string AC_L20_RESET_REASONS[AC_L20_MAX_SELECTED_SYMBOLS];
int    AC_L20_BUFFER_COUNT[AC_L20_MAX_SELECTED_SYMBOLS];
ulong  AC_L20_TICK_TIME_MSC[AC_L20_MAX_SELECTED_SYMBOLS][AC_L20_MAX_TICKS_PER_SYMBOL];
double AC_L20_TICK_BID[AC_L20_MAX_SELECTED_SYMBOLS][AC_L20_MAX_TICKS_PER_SYMBOL];
double AC_L20_TICK_ASK[AC_L20_MAX_SELECTED_SYMBOLS][AC_L20_MAX_TICKS_PER_SYMBOL];
double AC_L20_TICK_LAST[AC_L20_MAX_SELECTED_SYMBOLS][AC_L20_MAX_TICKS_PER_SYMBOL];
long   AC_L20_TICK_VOLUME[AC_L20_MAX_SELECTED_SYMBOLS][AC_L20_MAX_TICKS_PER_SYMBOL];
double AC_L20_TICK_VOLUME_REAL[AC_L20_MAX_SELECTED_SYMBOLS][AC_L20_MAX_TICKS_PER_SYMBOL];
uint   AC_L20_TICK_FLAGS[AC_L20_MAX_SELECTED_SYMBOLS][AC_L20_MAX_TICKS_PER_SYMBOL];
double AC_L20_TICK_SPREAD_POINTS[AC_L20_MAX_SELECTED_SYMBOLS][AC_L20_MAX_TICKS_PER_SYMBOL];

ulong AC_L20SecondsToMsc(const int seconds)
{
   return (ulong)seconds * (ulong)1000;
}

string AC_L20BoundaryText()
{
   return "MT5 tick proxy evidence only; directional_validity=false; institutional_order_flow_claim=false; trade_permission=false; entry_signal=false; execution=false";
}

bool AC_L20IsEmptySlot(const int slot)
{
   if(slot < 0 || slot >= AC_L20_MAX_SELECTED_SYMBOLS)
      return true;
   return AC_L20_SYMBOLS[slot] == "";
}

void AC_L20ClearSlot(const int slot, const string reason)
{
   if(slot < 0 || slot >= AC_L20_MAX_SELECTED_SYMBOLS)
      return;
   AC_L20_SYMBOLS[slot] = "";
   AC_L20_ACTIVE[slot] = false;
   AC_L20_RETIRED_GRACE[slot] = false;
   AC_L20_RETIRED_UNTIL[slot] = 0;
   AC_L20_LAST_TICK_MSC[slot] = 0;
   AC_L20_RESET_COUNT[slot] = 0;
   AC_L20_RESET_REASONS[slot] = reason;
   AC_L20_BUFFER_COUNT[slot] = 0;
}

void AC_L20Init()
{
   for(int i = 0; i < AC_L20_MAX_SELECTED_SYMBOLS; i++)
      AC_L20ClearSlot(i, "init");
}

int AC_L20FindSlot(const string symbol)
{
   for(int i = 0; i < AC_L20_MAX_SELECTED_SYMBOLS; i++)
   {
      if(AC_L20_SYMBOLS[i] == symbol)
         return i;
   }
   return -1;
}

int AC_L20FirstEmptyOrGraceSlot()
{
   int first_grace = -1;
   for(int i = 0; i < AC_L20_MAX_SELECTED_SYMBOLS; i++)
   {
      if(AC_L20_SYMBOLS[i] == "")
         return i;
      if(first_grace < 0 && AC_L20_RETIRED_GRACE[i])
         first_grace = i;
   }
   return first_grace;
}

bool AC_L20SelectSymbol(const string symbol, const ulong now_msc, string &reason)
{
   reason = "";
   if(symbol == "")
   {
      reason = "empty_symbol";
      return false;
   }
   int slot = AC_L20FindSlot(symbol);
   if(slot >= 0)
   {
      AC_L20_ACTIVE[slot] = true;
      AC_L20_RETIRED_GRACE[slot] = false;
      AC_L20_RETIRED_UNTIL[slot] = 0;
      reason = "existing_buffer_kept";
      return true;
   }
   slot = AC_L20FirstEmptyOrGraceSlot();
   if(slot < 0)
   {
      reason = "max_selected_symbols_reached";
      return false;
   }
   AC_L20_SYMBOLS[slot] = symbol;
   AC_L20_ACTIVE[slot] = true;
   AC_L20_RETIRED_GRACE[slot] = false;
   AC_L20_RETIRED_UNTIL[slot] = 0;
   AC_L20_LAST_TICK_MSC[slot] = 0;
   AC_L20_BUFFER_COUNT[slot] = 0;
   AC_L20_RESET_COUNT[slot]++;
   AC_L20_RESET_REASONS[slot] = "symbol_newly_enters_selected_set";
   reason = "new_symbol_bootstrap_required";
   return true;
}

void AC_L20RetireMissingSelections(const string &selected_symbols[], const int selected_count, const ulong now_msc)
{
   for(int slot = 0; slot < AC_L20_MAX_SELECTED_SYMBOLS; slot++)
   {
      if(AC_L20_SYMBOLS[slot] == "")
         continue;
      bool still_selected = false;
      for(int i = 0; i < selected_count; i++)
      {
         if(selected_symbols[i] == AC_L20_SYMBOLS[slot])
         {
            still_selected = true;
            break;
         }
      }
      if(still_selected)
         continue;
      if(!AC_L20_RETIRED_GRACE[slot])
      {
         AC_L20_ACTIVE[slot] = false;
         AC_L20_RETIRED_GRACE[slot] = true;
         AC_L20_RETIRED_UNTIL[slot] = now_msc + AC_L20SecondsToMsc(AC_L20_RETIRED_GRACE_SECONDS);
         AC_L20_RESET_REASONS[slot] = "retired_grace_symbol_left_selected_set";
      }
      else if(now_msc > AC_L20_RETIRED_UNTIL[slot])
      {
         AC_L20ClearSlot(slot, "retired_grace_expired_purged");
      }
   }
}

ulong AC_L20NowMsc()
{
   return (ulong)TimeCurrent() * (ulong)1000;
}

bool AC_L20ValidQuote(const MqlTick &tick, const double point)
{
   if(point <= 0.0)
      return false;
   if(tick.bid <= 0.0 || tick.ask <= 0.0)
      return false;
   if(tick.ask < tick.bid)
      return false;
   return true;
}

double AC_L20SpreadPoints(const MqlTick &tick, const double point)
{
   if(point <= 0.0)
      return 0.0;
   return (tick.ask - tick.bid) / point;
}

void AC_L20AppendTickToSlot(const int slot, const MqlTick &tick, const double point)
{
   if(slot < 0 || slot >= AC_L20_MAX_SELECTED_SYMBOLS)
      return;
   int count = AC_L20_BUFFER_COUNT[slot];
   if(count >= AC_L20_MAX_TICKS_PER_SYMBOL)
   {
      for(int i = 1; i < count; i++)
      {
         AC_L20_TICK_TIME_MSC[slot][i - 1] = AC_L20_TICK_TIME_MSC[slot][i];
         AC_L20_TICK_BID[slot][i - 1] = AC_L20_TICK_BID[slot][i];
         AC_L20_TICK_ASK[slot][i - 1] = AC_L20_TICK_ASK[slot][i];
         AC_L20_TICK_LAST[slot][i - 1] = AC_L20_TICK_LAST[slot][i];
         AC_L20_TICK_VOLUME[slot][i - 1] = AC_L20_TICK_VOLUME[slot][i];
         AC_L20_TICK_VOLUME_REAL[slot][i - 1] = AC_L20_TICK_VOLUME_REAL[slot][i];
         AC_L20_TICK_FLAGS[slot][i - 1] = AC_L20_TICK_FLAGS[slot][i];
         AC_L20_TICK_SPREAD_POINTS[slot][i - 1] = AC_L20_TICK_SPREAD_POINTS[slot][i];
      }
      count = AC_L20_MAX_TICKS_PER_SYMBOL - 1;
   }
   AC_L20_TICK_TIME_MSC[slot][count] = tick.time_msc;
   AC_L20_TICK_BID[slot][count] = tick.bid;
   AC_L20_TICK_ASK[slot][count] = tick.ask;
   AC_L20_TICK_LAST[slot][count] = tick.last;
   AC_L20_TICK_VOLUME[slot][count] = tick.volume;
   AC_L20_TICK_VOLUME_REAL[slot][count] = tick.volume_real;
   AC_L20_TICK_FLAGS[slot][count] = tick.flags;
   AC_L20_TICK_SPREAD_POINTS[slot][count] = AC_L20SpreadPoints(tick, point);
   AC_L20_BUFFER_COUNT[slot] = count + 1;
   if(tick.time_msc > AC_L20_LAST_TICK_MSC[slot])
      AC_L20_LAST_TICK_MSC[slot] = tick.time_msc;
}

int AC_L20PruneOldTicks(const int slot, const ulong cutoff_msc)
{
   if(slot < 0 || slot >= AC_L20_MAX_SELECTED_SYMBOLS)
      return 0;
   int count = AC_L20_BUFFER_COUNT[slot];
   int first_keep = 0;
   while(first_keep < count && AC_L20_TICK_TIME_MSC[slot][first_keep] < cutoff_msc)
      first_keep++;
   if(first_keep <= 0)
      return 0;
   int new_count = 0;
   for(int i = first_keep; i < count; i++)
   {
      AC_L20_TICK_TIME_MSC[slot][new_count] = AC_L20_TICK_TIME_MSC[slot][i];
      AC_L20_TICK_BID[slot][new_count] = AC_L20_TICK_BID[slot][i];
      AC_L20_TICK_ASK[slot][new_count] = AC_L20_TICK_ASK[slot][i];
      AC_L20_TICK_LAST[slot][new_count] = AC_L20_TICK_LAST[slot][i];
      AC_L20_TICK_VOLUME[slot][new_count] = AC_L20_TICK_VOLUME[slot][i];
      AC_L20_TICK_VOLUME_REAL[slot][new_count] = AC_L20_TICK_VOLUME_REAL[slot][i];
      AC_L20_TICK_FLAGS[slot][new_count] = AC_L20_TICK_FLAGS[slot][i];
      AC_L20_TICK_SPREAD_POINTS[slot][new_count] = AC_L20_TICK_SPREAD_POINTS[slot][i];
      new_count++;
   }
   AC_L20_BUFFER_COUNT[slot] = new_count;
   return first_keep;
}

int AC_L20UpdateSlotFromCopyTicksRange(const int slot, const ulong now_msc, int &copy_error)
{
   copy_error = 0;
   if(slot < 0 || slot >= AC_L20_MAX_SELECTED_SYMBOLS || AC_L20_SYMBOLS[slot] == "")
      return 0;
   string symbol = AC_L20_SYMBOLS[slot];
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
   if(point <= 0.0)
   {
      copy_error = -1;
      return 0;
   }
   ulong from_msc = AC_L20_LAST_TICK_MSC[slot] > 0 ? AC_L20_LAST_TICK_MSC[slot] + (ulong)1 : now_msc - AC_L20SecondsToMsc(AC_L20_ROLLING_WINDOW_SECONDS);
   MqlTick ticks[];
   ResetLastError();
   int copied = CopyTicksRange(symbol, ticks, COPY_TICKS_ALL, from_msc, now_msc);
   if(copied < 0)
   {
      copy_error = GetLastError();
      return 0;
   }
   int appended = 0;
   for(int i = 0; i < copied; i++)
   {
      if(!AC_L20ValidQuote(ticks[i], point))
         continue;
      if(AC_L20_LAST_TICK_MSC[slot] > 0 && ticks[i].time_msc <= AC_L20_LAST_TICK_MSC[slot])
         continue;
      AC_L20AppendTickToSlot(slot, ticks[i], point);
      appended++;
   }
   return appended;
}

void AC_L20EmptySummary(AC_L20SymbolSummary &summary, const string symbol, const string status, const string reason)
{
   summary.symbol = symbol;
   summary.status = status;
   summary.reason = reason;
   summary.selected_scope_source = "not_available";
   summary.tick_count_1m = 0;
   summary.tick_count_5m = 0;
   summary.tick_count_10m = 0;
   summary.spread_min_points_10m = 0.0;
   summary.spread_max_points_10m = 0.0;
   summary.spread_avg_points_10m = 0.0;
   summary.spread_stddev_points_10m = 0.0;
   summary.spread_spike_count_10m = 0;
   summary.spread_spike_minor_count_10m = 0;
   summary.spread_spike_major_count_10m = 0;
   summary.spread_spike_severe_count_10m = 0;
   summary.tick_gap_avg_seconds = 0.0;
   summary.tick_gap_max_seconds = 0.0;
   summary.bid_change_count_10m = 0;
   summary.ask_change_count_10m = 0;
   summary.last_change_count_10m = 0;
   summary.volume_change_count_10m = 0;
   summary.bid_up_count_10m = 0;
   summary.bid_down_count_10m = 0;
   summary.ask_up_count_10m = 0;
   summary.ask_down_count_10m = 0;
   summary.mid_change_count_10m = 0;
   summary.mid_range_points_10m = 0.0;
   summary.ticks_appended_last_update = 0;
   summary.ticks_pruned_last_update = 0;
   summary.buffer_count = 0;
   summary.oldest_tick_msc = 0;
   summary.newest_tick_msc = 0;
   summary.latest_tick_age_seconds = -1;
   summary.copyticks_call_count = 0;
   summary.copyticksrange_call_count = 0;
   summary.copyticks_error_code = 0;
   summary.flags_decode_status = "not_available";
   summary.sample_quality = "not_available";
   summary.proxy_confidence = "none";
   summary.boundary_text = AC_L20BoundaryText();
   summary.trade_permission = false;
   summary.entry_signal = false;
   summary.execution = false;
   summary.institutional_order_flow_claim = false;
}

void AC_L20SummarizeSlot(const int slot, const ulong now_msc, AC_L20SymbolSummary &summary)
{
   if(slot < 0 || slot >= AC_L20_MAX_SELECTED_SYMBOLS || AC_L20_SYMBOLS[slot] == "")
   {
      AC_L20EmptySummary(summary, "", "missing_scope", "slot_empty");
      return;
   }
   AC_L20EmptySummary(summary, AC_L20_SYMBOLS[slot], "ACTIVE_ROLLING", "rolling_buffer_summarized");
   summary.selected_scope_source = "selected_scope_owner_pending_runtime_wiring";
   int count = AC_L20_BUFFER_COUNT[slot];
   summary.buffer_count = count;
   if(count <= 0)
   {
      summary.status = AC_L20_RETIRED_GRACE[slot] ? "RETIRED_GRACE" : "UNAVAILABLE_NO_TICKS";
      summary.reason = "no_ticks_in_buffer";
      summary.sample_quality = "none";
      summary.proxy_confidence = "none";
      return;
   }
   ulong cutoff_1m = now_msc - AC_L20SecondsToMsc(60);
   ulong cutoff_5m = now_msc - AC_L20SecondsToMsc(300);
   ulong cutoff_10m = now_msc - AC_L20SecondsToMsc(AC_L20_ROLLING_WINDOW_SECONDS);
   double spread_sum = 0.0;
   double spread_sq_sum = 0.0;