#ifndef AC_SELECTED_ROLLING_TICK_PACK_MQH
#define AC_SELECTED_ROLLING_TICK_PACK_MQH

// Layer 20 - Selected Rolling Tick Pack
// DESIGN/SOURCE-PRESENT ONLY until L19 is confirmed running on main and overseer approves wiring.
// L4 remains source owner for current bid/ask/last/live spread/quote freshness.
// L20 owns selected rolling historical tick-row derived metrics only.

static const int    AC_L20_MAX_SELECTED_SYMBOLS       = 16;
static const int    AC_L20_MAX_TICK_ROWS_PER_SYMBOL   = 2048;
static const int    AC_L20_ROLLING_WINDOW_SECONDS     = 600;
static const int    AC_L20_RETIRED_GRACE_SECONDS      = 900;
static const double AC_L20_SPREAD_SPIKE_MULTIPLIER    = 2.5;
static const double AC_L20_SPREAD_SPIKE_SEVERE_MULT   = 4.0;

struct AC_L20SymbolSummary
{
   string symbol;
   string status;
   string reason;
   string selected_scope_source;
   string l4_quote_reference_status;
   int    tick_count_1m;
   int    tick_count_5m;
   int    tick_count_10m;
   double spread_min_points_10m;
   double spread_max_points_10m;
   double spread_avg_points_10m;
   double spread_stddev_points_10m;
   int    spread_spike_count_10m;
   int    spread_spike_severe_count_10m;
   double tick_gap_avg_seconds;
   double tick_gap_max_seconds;
   int    observed_bid_change_count_10m;
   int    observed_ask_change_count_10m;
   int    observed_last_change_count_10m;
   int    observed_volume_change_count_10m;
   int    observed_mid_change_count_10m;
   double observed_mid_range_points_10m;
   int    buffer_count;
   ulong  oldest_tick_msc;
   ulong  newest_tick_msc;
   int    latest_tick_age_seconds;
   int    copyticksrange_call_count;
   int    copyticks_error_code;
   string flags_decode_status;
   string sample_quality;
   string proxy_confidence;
   bool   current_quote_owner;
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
int    AC_L20_BUFFER_COUNT[AC_L20_MAX_SELECTED_SYMBOLS];
ulong  AC_L20_ROW_TIME_MSC[AC_L20_MAX_SELECTED_SYMBOLS][AC_L20_MAX_TICK_ROWS_PER_SYMBOL];
double AC_L20_ROW_OBS_BID[AC_L20_MAX_SELECTED_SYMBOLS][AC_L20_MAX_TICK_ROWS_PER_SYMBOL];
double AC_L20_ROW_OBS_ASK[AC_L20_MAX_SELECTED_SYMBOLS][AC_L20_MAX_TICK_ROWS_PER_SYMBOL];
double AC_L20_ROW_OBS_LAST[AC_L20_MAX_SELECTED_SYMBOLS][AC_L20_MAX_TICK_ROWS_PER_SYMBOL];
ulong  AC_L20_ROW_OBS_VOLUME[AC_L20_MAX_SELECTED_SYMBOLS][AC_L20_MAX_TICK_ROWS_PER_SYMBOL];
uint   AC_L20_ROW_FLAGS[AC_L20_MAX_SELECTED_SYMBOLS][AC_L20_MAX_TICK_ROWS_PER_SYMBOL];
double AC_L20_ROW_OBS_SPREAD_POINTS[AC_L20_MAX_SELECTED_SYMBOLS][AC_L20_MAX_TICK_ROWS_PER_SYMBOL];

ulong AC_L20SecondsToMsc(const int seconds) { return (ulong)seconds * (ulong)1000; }
string AC_L20BoolText(const bool value) { return value ? "true" : "false"; }
string AC_L20BoundaryText() { return "selected MT5 tick-row observations only; current_quote_owner=L4; no signal or permission"; }

void AC_L20ClearSlot(const int slot)
{
   if(slot < 0 || slot >= AC_L20_MAX_SELECTED_SYMBOLS) return;
   AC_L20_SYMBOLS[slot] = "";
   AC_L20_ACTIVE[slot] = false;
   AC_L20_RETIRED_GRACE[slot] = false;
   AC_L20_RETIRED_UNTIL[slot] = 0;
   AC_L20_LAST_TICK_MSC[slot] = 0;
   AC_L20_BUFFER_COUNT[slot] = 0;
}

void AC_L20Init()
{
   for(int i = 0; i < AC_L20_MAX_SELECTED_SYMBOLS; i++) AC_L20ClearSlot(i);
}

int AC_L20FindSlot(const string symbol)
{
   for(int i = 0; i < AC_L20_MAX_SELECTED_SYMBOLS; i++) if(AC_L20_SYMBOLS[i] == symbol) return i;
   return -1;
}

int AC_L20FirstEmptyOrGraceSlot()
{
   int first_grace = -1;
   for(int i = 0; i < AC_L20_MAX_SELECTED_SYMBOLS; i++)
   {
      if(AC_L20_SYMBOLS[i] == "") return i;
      if(first_grace < 0 && AC_L20_RETIRED_GRACE[i]) first_grace = i;
   }
   return first_grace;
}

bool AC_L20SelectSymbol(const string symbol, const ulong now_msc, string &reason)
{
   reason = "";
   if(symbol == "") { reason = "empty_symbol"; return false; }
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
   if(slot < 0) { reason = "max_selected_symbols_reached"; return false; }
   AC_L20_SYMBOLS[slot] = symbol;
   AC_L20_ACTIVE[slot] = true;
   AC_L20_RETIRED_GRACE[slot] = false;
   AC_L20_RETIRED_UNTIL[slot] = 0;
   AC_L20_LAST_TICK_MSC[slot] = 0;
   AC_L20_BUFFER_COUNT[slot] = 0;
   reason = "new_symbol_bootstrap_required";
   return true;
}

bool AC_L20ValidTickRowObservation(const MqlTick &tick, const double point)
{
   if(point <= 0.0) return false;
   if(tick.bid <= 0.0 || tick.ask <= 0.0) return false;
   if(tick.ask < tick.bid) return false;
   return true;
}

double AC_L20ObservedSpreadPoints(const MqlTick &tick, const double point)
{
   if(point <= 0.0) return 0.0;
   return (tick.ask - tick.bid) / point;
}

void AC_L20AppendTickRowToSlot(const int slot, const MqlTick &tick, const double point)
{
   if(slot < 0 || slot >= AC_L20_MAX_SELECTED_SYMBOLS) return;
   int count = AC_L20_BUFFER_COUNT[slot];
   if(count >= AC_L20_MAX_TICK_ROWS_PER_SYMBOL)
   {
      for(int i = 1; i < count; i++)
      {
         AC_L20_ROW_TIME_MSC[slot][i - 1] = AC_L20_ROW_TIME_MSC[slot][i];
         AC_L20_ROW_OBS_BID[slot][i - 1] = AC_L20_ROW_OBS_BID[slot][i];
         AC_L20_ROW_OBS_ASK[slot][i - 1] = AC_L20_ROW_OBS_ASK[slot][i];
         AC_L20_ROW_OBS_LAST[slot][i - 1] = AC_L20_ROW_OBS_LAST[slot][i];
         AC_L20_ROW_OBS_VOLUME[slot][i - 1] = AC_L20_ROW_OBS_VOLUME[slot][i];
         AC_L20_ROW_FLAGS[slot][i - 1] = AC_L20_ROW_FLAGS[slot][i];
         AC_L20_ROW_OBS_SPREAD_POINTS[slot][i - 1] = AC_L20_ROW_OBS_SPREAD_POINTS[slot][i];
      }
      count = AC_L20_MAX_TICK_ROWS_PER_SYMBOL - 1;
   }
   AC_L20_ROW_TIME_MSC[slot][count] = tick.time_msc;
   AC_L20_ROW_OBS_BID[slot][count] = tick.bid;
   AC_L20_ROW_OBS_ASK[slot][count] = tick.ask;
   AC_L20_ROW_OBS_LAST[slot][count] = tick.last;
   AC_L20_ROW_OBS_VOLUME[slot][count] = tick.volume;
   AC_L20_ROW_FLAGS[slot][count] = tick.flags;
   AC_L20_ROW_OBS_SPREAD_POINTS[slot][count] = AC_L20ObservedSpreadPoints(tick, point);
   AC_L20_BUFFER_COUNT[slot] = count + 1;
   if(tick.time_msc > AC_L20_LAST_TICK_MSC[slot]) AC_L20_LAST_TICK_MSC[slot] = tick.time_msc;
}

int AC_L20PruneOldTickRows(const int slot, const ulong cutoff_msc)
{
   if(slot < 0 || slot >= AC_L20_MAX_SELECTED_SYMBOLS) return 0;
   int count = AC_L20_BUFFER_COUNT[slot];
   int first_keep = 0;
   while(first_keep < count && AC_L20_ROW_TIME_MSC[slot][first_keep] < cutoff_msc) first_keep++;
   if(first_keep <= 0) return 0;
   int new_count = 0;
   for(int i = first_keep; i < count; i++)
   {
      AC_L20_ROW_TIME_MSC[slot][new_count] = AC_L20_ROW_TIME_MSC[slot][i];
      AC_L20_ROW_OBS_BID[slot][new_count] = AC_L20_ROW_OBS_BID[slot][i];
      AC_L20_ROW_OBS_ASK[slot][new_count] = AC_L20_ROW_OBS_ASK[slot][i];
      AC_L20_ROW_OBS_LAST[slot][new_count] = AC_L20_ROW_OBS_LAST[slot][i];
      AC_L20_ROW_OBS_VOLUME[slot][new_count] = AC_L20_ROW_OBS_VOLUME[slot][i];
      AC_L20_ROW_FLAGS[slot][new_count] = AC_L20_ROW_FLAGS[slot][i];
      AC_L20_ROW_OBS_SPREAD_POINTS[slot][new_count] = AC_L20_ROW_OBS_SPREAD_POINTS[slot][i];
      new_count++;
   }
   AC_L20_BUFFER_COUNT[slot] = new_count;
   return first_keep;
}

int AC_L20UpdateSlotFromCopyTicksRange(const int slot, const ulong now_msc, int &copy_error)
{
   copy_error = 0;
   if(slot < 0 || slot >= AC_L20_MAX_SELECTED_SYMBOLS || AC_L20_SYMBOLS[slot] == "") return 0;
   string symbol = AC_L20_SYMBOLS[slot];
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
   if(point <= 0.0) { copy_error = -1; return 0; }
   ulong from_msc = AC_L20_LAST_TICK_MSC[slot] > 0 ? AC_L20_LAST_TICK_MSC[slot] + (ulong)1 : now_msc - AC_L20SecondsToMsc(AC_L20_ROLLING_WINDOW_SECONDS);
   MqlTick ticks[];
   ResetLastError();
   int copied = CopyTicksRange(symbol, ticks, COPY_TICKS_ALL, from_msc, now_msc);
   if(copied < 0) { copy_error = GetLastError(); return 0; }
   int appended = 0;
   for(int i = 0; i < copied; i++)
   {
      if(!AC_L20ValidTickRowObservation(ticks[i], point)) continue;
      if(AC_L20_LAST_TICK_MSC[slot] > 0 && ticks[i].time_msc <= AC_L20_LAST_TICK_MSC[slot]) continue;
      AC_L20AppendTickRowToSlot(slot, ticks[i], point);
      appended++;
   }
   return appended;
}

void AC_L20EmptySummary(AC_L20SymbolSummary &s, const string symbol, const string status, const string reason)
{
   s.symbol = symbol; s.status = status; s.reason = reason;
   s.selected_scope_source = "not_available"; s.l4_quote_reference_status = "not_wired";
   s.tick_count_1m = 0; s.tick_count_5m = 0; s.tick_count_10m = 0;
   s.spread_min_points_10m = 0.0; s.spread_max_points_10m = 0.0; s.spread_avg_points_10m = 0.0; s.spread_stddev_points_10m = 0.0;
   s.spread_spike_count_10m = 0; s.spread_spike_severe_count_10m = 0;
   s.tick_gap_avg_seconds = 0.0; s.tick_gap_max_seconds = 0.0;
   s.observed_bid_change_count_10m = 0; s.observed_ask_change_count_10m = 0; s.observed_last_change_count_10m = 0; s.observed_volume_change_count_10m = 0;
   s.observed_mid_change_count_10m = 0; s.observed_mid_range_points_10m = 0.0;
   s.buffer_count = 0; s.oldest_tick_msc = 0; s.newest_tick_msc = 0; s.latest_tick_age_seconds = -1;
   s.copyticksrange_call_count = 0; s.copyticks_error_code = 0;
   s.flags_decode_status = "not_available"; s.sample_quality = "not_available"; s.proxy_confidence = "none";
   s.current_quote_owner = false; s.trade_permission = false; s.entry_signal = false; s.execution = false; s.institutional_order_flow_claim = false;
}

void AC_L20SummarizeSlot(const int slot, const ulong now_msc, AC_L20SymbolSummary &s)
{
   if(slot < 0 || slot >= AC_L20_MAX_SELECTED_SYMBOLS || AC_L20_SYMBOLS[slot] == "") { AC_L20EmptySummary(s, "", "missing_scope", "slot_empty"); return; }
   AC_L20EmptySummary(s, AC_L20_SYMBOLS[slot], "ACTIVE_ROLLING", "rolling_tick_window_summarized");
   s.selected_scope_source = "selected_scope_owner_pending_runtime_wiring";
   s.l4_quote_reference_status = "pending_L4_reference_reader";
   int count = AC_L20_BUFFER_COUNT[slot];
   s.buffer_count = count;
   if(count <= 0) { s.status = AC_L20_RETIRED_GRACE[slot] ? "RETIRED_GRACE" : "UNAVAILABLE_NO_TICKS"; s.reason = "no_tick_rows_in_buffer"; s.sample_quality = "none"; return; }

   ulong cutoff_1m = now_msc - AC_L20SecondsToMsc(60);
   ulong cutoff_5m = now_msc - AC_L20SecondsToMsc(300);
   ulong cutoff_10m = now_msc - AC_L20SecondsToMsc(AC_L20_ROLLING_WINDOW_SECONDS);
   double spread_sum = 0.0, spread_sq_sum = 0.0, mid_min = 0.0, mid_max = 0.0;
   bool mid_seeded = false, spread_seeded = false;
   uint flags_seen = 0;
   double point = SymbolInfoDouble(s.symbol, SYMBOL_POINT);

   for(int i = 0; i < count; i++)
   {
      ulong t = AC_L20_ROW_TIME_MSC[slot][i];
      if(t >= cutoff_1m) s.tick_count_1m++;
      if(t >= cutoff_5m) s.tick_count_5m++;
      if(t >= cutoff_10m) s.tick_count_10m++;
      if(t < cutoff_10m) continue;

      double spread = AC_L20_ROW_OBS_SPREAD_POINTS[slot][i];
      if(!spread_seeded) { s.spread_min_points_10m = spread; s.spread_max_points_10m = spread; spread_seeded = true; }
      else { if(spread < s.spread_min_points_10m) s.spread_min_points_10m = spread; if(spread > s.spread_max_points_10m) s.spread_max_points_10m = spread; }
      spread_sum += spread; spread_sq_sum += spread * spread;
      double mid = (AC_L20_ROW_OBS_BID[slot][i] + AC_L20_ROW_OBS_ASK[slot][i]) * 0.5;
      if(!mid_seeded) { mid_min = mid; mid_max = mid; mid_seeded = true; } else { if(mid < mid_min) mid_min = mid; if(mid > mid_max) mid_max = mid; }
      flags_seen |= AC_L20_ROW_FLAGS[slot][i];

      if(i > 0)
      {
         ulong prev_t = AC_L20_ROW_TIME_MSC[slot][i - 1];
         if(prev_t >= cutoff_10m && t >= prev_t)
         {
            double gap = (double)(t - prev_t) / 1000.0;
            s.tick_gap_avg_seconds += gap;
            if(gap > s.tick_gap_max_seconds) s.tick_gap_max_seconds = gap;
         }
         uint flags = AC_L20_ROW_FLAGS[slot][i];
         if((flags & TICK_FLAG_BID) != 0) s.observed_bid_change_count_10m++;
         if((flags & TICK_FLAG_ASK) != 0) s.observed_ask_change_count_10m++;
         if((flags & TICK_FLAG_LAST) != 0) s.observed_last_change_count_10m++;
         if((flags & TICK_FLAG_VOLUME) != 0) s.observed_volume_change_count_10m++;
         double prev_mid = (AC_L20_ROW_OBS_BID[slot][i - 1] + AC_L20_ROW_OBS_ASK[slot][i - 1]) * 0.5;
         if(mid != prev_mid) s.observed_mid_change_count_10m++;
      }
   }

   int n = s.tick_count_10m;
   if(n > 0)
   {
      s.spread_avg_points_10m = spread_sum / (double)n;
      double variance = (spread_sq_sum / (double)n) - (s.spread_avg_points_10m * s.spread_avg_points_10m);
      if(variance < 0.0) variance = 0.0;
      s.spread_stddev_points_10m = MathSqrt(variance);
      double major_threshold = MathMax(1.0, s.spread_avg_points_10m * AC_L20_SPREAD_SPIKE_MULTIPLIER);
      double severe_threshold = MathMax(1.0, s.spread_avg_points_10m * AC_L20_SPREAD_SPIKE_SEVERE_MULT);
      for(int i = 0; i < count; i++)
      {
         if(AC_L20_ROW_TIME_MSC[slot][i] < cutoff_10m) continue;
         double spread = AC_L20_ROW_OBS_SPREAD_POINTS[slot][i];
         if(spread >= major_threshold) s.spread_spike_count_10m++;
         if(spread >= severe_threshold) s.spread_spike_severe_count_10m++;
      }
      if(n > 1) s.tick_gap_avg_seconds = s.tick_gap_avg_seconds / (double)(n - 1);
      if(mid_seeded && point > 0.0) s.observed_mid_range_points_10m = (mid_max - mid_min) / point;
   }

   s.oldest_tick_msc = AC_L20_ROW_TIME_MSC[slot][0];
   s.newest_tick_msc = AC_L20_ROW_TIME_MSC[slot][count - 1];
   s.latest_tick_age_seconds = s.newest_tick_msc > 0 && now_msc >= s.newest_tick_msc ? (int)((now_msc - s.newest_tick_msc) / (ulong)1000) : -1;
   s.flags_decode_status = flags_seen == 0 ? "degraded_flags_unclear" : "decoded";

   if(s.tick_count_10m <= 0) { s.status = "UNAVAILABLE_NO_TICKS"; s.reason = "no_tick_rows_in_rolling_window"; s.sample_quality = "none"; s.proxy_confidence = "none"; }
   else if(s.latest_tick_age_seconds > 60) { s.status = "DEGRADED_STALE_TICKS"; s.reason = "latest_tick_row_too_old"; s.sample_quality = "stale"; s.proxy_confidence = "low"; }
   else if(s.tick_gap_max_seconds > 30.0) { s.status = "DEGRADED_GAPPY_FEED"; s.reason = "tick_gap_max_seconds_over_30"; s.sample_quality = "gappy"; s.proxy_confidence = "medium_low"; }
   else if(s.spread_spike_severe_count_10m > 0) { s.status = "DEGRADED_SPREAD_UNSTABLE"; s.reason = "severe_observed_spread_spike_seen"; s.sample_quality = "spread_unstable"; s.proxy_confidence = "medium"; }
   else { s.status = "ACTIVE_ROLLING"; s.reason = "rolling_tick_window_proxy_active"; s.sample_quality = "usable"; s.proxy_confidence = s.flags_decode_status == "decoded" ? "medium" : "low"; }
}

string AC_L20CsvHeader()
{
   return "symbol,status,reason,selected_scope_source,l4_quote_reference_status,tick_row_count_1m,tick_row_count_5m,tick_row_count_10m,spread_observed_min_points_10m,spread_observed_avg_points_10m,spread_observed_max_points_10m,spread_observed_stddev_points_10m,spread_observed_spike_count_10m,tick_gap_avg_seconds,tick_gap_max_seconds,observed_bid_change_count_10m,observed_ask_change_count_10m,observed_last_change_count_10m,observed_volume_change_count_10m,observed_mid_change_count_10m,observed_mid_range_points_10m,latest_tick_row_age_seconds,buffer_count,oldest_tick_msc,newest_tick_msc,flags_decode_status,sample_quality,proxy_confidence,current_quote_owner,institutional_order_flow_claim,trade_permission,entry_signal,execution";
}

string AC_L20SummaryCsvRow(const AC_L20SymbolSummary &s)
{
   return s.symbol + "," + s.status + "," + s.reason + "," + s.selected_scope_source + "," + s.l4_quote_reference_status + ","
      + IntegerToString(s.tick_count_1m) + "," + IntegerToString(s.tick_count_5m) + "," + IntegerToString(s.tick_count_10m) + ","
      + DoubleToString(s.spread_min_points_10m, 2) + "," + DoubleToString(s.spread_avg_points_10m, 2) + "," + DoubleToString(s.spread_max_points_10m, 2) + "," + DoubleToString(s.spread_stddev_points_10m, 2) + ","
      + IntegerToString(s.spread_spike_count_10m) + "," + DoubleToString(s.tick_gap_avg_seconds, 2) + "," + DoubleToString(s.tick_gap_max_seconds, 2) + ","
      + IntegerToString(s.observed_bid_change_count_10m) + "," + IntegerToString(s.observed_ask_change_count_10m) + "," + IntegerToString(s.observed_last_change_count_10m) + "," + IntegerToString(s.observed_volume_change_count_10m) + ","
      + IntegerToString(s.observed_mid_change_count_10m) + "," + DoubleToString(s.observed_mid_range_points_10m, 2) + "," + IntegerToString(s.latest_tick_age_seconds) + "," + IntegerToString(s.buffer_count) + ","
      + StringFormat("%I64u", s.oldest_tick_msc) + "," + StringFormat("%I64u", s.newest_tick_msc) + ","
      + s.flags_decode_status + "," + s.sample_quality + "," + s.proxy_confidence + ","
      + AC_L20BoolText(s.current_quote_owner) + "," + AC_L20BoolText(s.institutional_order_flow_claim) + "," + AC_L20BoolText(s.trade_permission) + "," + AC_L20BoolText(s.entry_signal) + "," + AC_L20BoolText(s.execution);
}

string AC_L20DossierSection(const AC_L20SymbolSummary &s)
{
   string text = "\r\nL20 SELECTED ROLLING TICK WINDOW PACK\r\n";
   text += "Status: " + s.status + " | Reason: " + s.reason + "\r\n";
   text += "Source: MT5 historical tick rows; current quote owner=L4 | L4 Reference: " + s.l4_quote_reference_status + "\r\n";
   text += "Tick Rows: 1m=" + IntegerToString(s.tick_count_1m) + " | 5m=" + IntegerToString(s.tick_count_5m) + " | 10m=" + IntegerToString(s.tick_count_10m) + "\r\n";
   text += "Observed Spread Points: min=" + DoubleToString(s.spread_min_points_10m, 2) + " | avg=" + DoubleToString(s.spread_avg_points_10m, 2) + " | max=" + DoubleToString(s.spread_max_points_10m, 2) + " | stddev=" + DoubleToString(s.spread_stddev_points_10m, 2) + " | spikes=" + IntegerToString(s.spread_spike_count_10m) + "\r\n";
   text += "Gaps: avg=" + DoubleToString(s.tick_gap_avg_seconds, 2) + "s | max=" + DoubleToString(s.tick_gap_max_seconds, 2) + "s\r\n";
   text += "Observed Row Changes: bid=" + IntegerToString(s.observed_bid_change_count_10m) + " | ask=" + IntegerToString(s.observed_ask_change_count_10m) + " | last=" + IntegerToString(s.observed_last_change_count_10m) + " | volume=" + IntegerToString(s.observed_volume_change_count_10m) + "\r\n";
   text += "Observed Mid Proxy: changes=" + IntegerToString(s.observed_mid_change_count_10m) + " | range_points=" + DoubleToString(s.observed_mid_range_points_10m, 2) + "\r\n";
   text += "Quality: sample=" + s.sample_quality + " | confidence=" + s.proxy_confidence + " | flags=" + s.flags_decode_status + "\r\n";
   text += "Boundary: review-only tick-window context; L4 owns current quote truth; no signal or permission\r\n";
   return text;
}

string AC_L20BoardLine(const AC_L20SymbolSummary &s)
{
   return s.symbol + " | TickRows10m " + IntegerToString(s.tick_count_10m)
      + " | SprObsAvg " + DoubleToString(s.spread_avg_points_10m, 2)
      + " | SprObsMax " + DoubleToString(s.spread_max_points_10m, 2)
      + " | Spike " + IntegerToString(s.spread_spike_count_10m)
      + " | GapMax " + DoubleToString(s.tick_gap_max_seconds, 2) + "s"
      + " | " + s.status;
}

#endif
