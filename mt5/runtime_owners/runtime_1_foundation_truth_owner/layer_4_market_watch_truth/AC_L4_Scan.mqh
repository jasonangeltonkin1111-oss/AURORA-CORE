#ifndef AC_L4_SCAN_MQH
#define AC_L4_SCAN_MQH

void AC_BuildLayer4Texts();

bool AC_L4GetDouble(const string symbol, const ENUM_SYMBOL_INFO_DOUBLE prop, double &value)
{
   ResetLastError();
   if(SymbolInfoDouble(symbol, prop, value)) return true;
   value = 0.0;
   return false;
}

bool AC_L4GetInteger(const string symbol, const ENUM_SYMBOL_INFO_INTEGER prop, long &value)
{
   ResetLastError();
   if(SymbolInfoInteger(symbol, prop, value)) return true;
   value = 0;
   return false;
}

string AC_L4BuildCacheKey(const int total)
{
   return AC_DOSSIER_SHELL_SCHEMA_VERSION
      + " | L2 " + AC_L2_ROUTE_GENERATION_KEY
      + " | L3 " + AC_L3_CACHE_KEY
      + " | symbols " + IntegerToString(total);
}

string AC_L4BoolKey(const bool value)
{
   return value ? "1" : "0";
}

string AC_L4PacketDataChangeKey()
{
   string key = "l4_packet_data_change";
   int total = ArraySize(AC_L4_SYMBOLS);
   for(int i = 0; i < total; i++)
   {
      AC_L4SymbolPacket p = AC_L4_SYMBOLS[i];
      key += "|" + p.symbol
         + ":state=" + p.market_state
         + ":scan=" + p.scan_status
         + ":tick=" + AC_L4BoolKey(p.tick_available)
         + ":q=" + p.quote_quality
         + ":surf=" + p.surface_quality
         + ":bid=" + DoubleToString(p.bid, p.digits)
         + ":ask=" + DoubleToString(p.ask, p.digits)
         + ":last=" + DoubleToString(p.last, p.digits)
         + ":spread_pts=" + DoubleToString(p.spread_points_live, 1)
         + ":spread_bps=" + DoubleToString(p.spread_bps_live, 4)
         + ":zero=" + p.zero_spread_state
         + ":daily=" + DoubleToString(p.daily_change_pct, 4)
         + ":tick_msc=" + IntegerToString(p.tick_time_msc)
         + ":flags=" + IntegerToString((int)p.tick_flags)
         + ":fail=" + p.failure_reason;
   }
   return key;
}

void AC_L4InitPacket(AC_L4SymbolPacket &p, const string symbol)
{
   p.symbol = symbol;
   p.market_state = AC_L2MarketStateForSymbol(symbol);
   p.scan_status = "Pending";
   p.tick_available = false;
   p.tick_error_code = 0;
   p.tick_time_broker = 0;
   p.tick_time_msc = 0;
   p.tick_age_ms = -1;
   p.tick_age_seconds = -1.0;
   p.tick_flags = 0;
   p.bid = 0.0;
   p.ask = 0.0;
   p.last = 0.0;
   p.volume = 0;
   p.volume_real = 0.0;
   p.bid_valid = false;
   p.ask_valid = false;
   p.last_valid = false;
   p.bid_ask_valid = false;
   p.quote_valid_flag = false;
   p.point = 0.0;
   p.digits = 0;
   p.spread_price_live = 0.0;
   p.spread_points_live = 0.0;
   p.spread_pips_live = 0.0;
   p.spread_pct_live = 0.0;
   p.spread_bps_live = 0.0;
   p.spread_source = "Not available";
   p.spread_spec_points = -1;
   p.spread_float = false;
   p.spread_vs_spec_status = "Not checked";
   p.zero_spread_state = "Not checked";
   p.spread_score = "No Score";
   p.daily_change_pct = 0.0;
   p.daily_change_status = "Not available";
   p.daily_open = 0.0;
   p.daily_high_bid = 0.0;
   p.daily_low_bid = 0.0;
   p.daily_high_ask = 0.0;
   p.daily_low_ask = 0.0;
   p.daily_high_last = 0.0;
   p.daily_low_last = 0.0;
   p.daily_range_position_pct = 0.0;
   p.session_aw = 0.0;
   p.session_volume = 0.0;
   p.session_turnover = 0.0;
   p.session_interest = 0.0;
   p.session_deals = 0;
   p.session_buy_orders = 0;
   p.session_sell_orders = 0;
   p.activity_status = "Not available";
   p.quote_quality = "Not scanned";
   p.surface_quality = "Not scanned";
   p.failure_reason = "";
   p.trade_permission = false;
}

void AC_L4FinalizeCounters(const AC_L4SymbolPacket &p)
{
   if(p.market_state != "open") return;
   AC_L4_ELIGIBLE_OPEN++;
   AC_L4_SCANNED++;

   if(!p.tick_available) AC_L4_MISSING_TICK++;
   else if(!p.bid_ask_valid) AC_L4_INVALID_BIDASK++;
   else if(p.quote_quality == "Fresh") AC_L4_FRESH_QUOTES++;
   else if(p.quote_quality == "Aging") AC_L4_AGING_QUOTES++;
   else AC_L4_STALE_QUOTES++;

   if(p.zero_spread_state == "Fresh Zero Spread") AC_L4_ZERO_SPREAD_FRESH++;
   if(p.daily_change_status == "Available") AC_L4_DAILY_CHANGE_AVAILABLE++;
   if(p.spread_score == "Hostile") AC_L4_HIGH_SPREAD_WARNINGS++;
   if(p.activity_status == "Activity Available - Nonzero") AC_L4_ACTIVITY_NONZERO++;
   else if(p.activity_status == "Activity API Available - Zero Values") AC_L4_ACTIVITY_API_AVAILABLE++;
   if(p.failure_reason != "" && AC_L4_WORST_FAILURE_REASON == "None") AC_L4_WORST_FAILURE_REASON = p.failure_reason;
}

void AC_L4ScanOneOpenSymbol(const string symbol)
{
   int next = ArraySize(AC_L4_SYMBOLS);
   ArrayResize(AC_L4_SYMBOLS, next + 1);
   AC_L4InitPacket(AC_L4_SYMBOLS[next], symbol);

   if(AC_L4_SYMBOLS[next].market_state != "open")
   {
      AC_L4_SYMBOLS[next].scan_status = "Cut Off";
      AC_L4_SYMBOLS[next].failure_reason = "Layer 2 market state is not open.";
      return;
   }

   AC_L4_SYMBOLS[next].scan_status = "Scanned";
   MqlTick tick;
   ResetLastError();
   if(SymbolInfoTick(symbol, tick))
   {
      AC_L4_SYMBOLINFO_TICK_SUCCESS++;
      AC_L4_SYMBOLS[next].tick_available = true;
      AC_L4_SYMBOLS[next].bid = tick.bid;
      AC_L4_SYMBOLS[next].ask = tick.ask;
      AC_L4_SYMBOLS[next].last = tick.last;
      AC_L4_SYMBOLS[next].volume = tick.volume;
      AC_L4_SYMBOLS[next].volume_real = tick.volume_real;
      AC_L4_SYMBOLS[next].tick_time_broker = tick.time;
      AC_L4_SYMBOLS[next].tick_time_msc = tick.time_msc;
      AC_L4_SYMBOLS[next].tick_flags = tick.flags;
   }
   else
   {
      AC_L4_SYMBOLINFO_TICK_FAILURE++;
      AC_L4_SYMBOLS[next].tick_available = false;
      AC_L4_SYMBOLS[next].tick_error_code = GetLastError();
      AC_L4_SYMBOLS[next].failure_reason = "SymbolInfoTick failed with error " + IntegerToString(AC_L4_SYMBOLS[next].tick_error_code);
   }

   long digits = 0;
   if(AC_L4GetInteger(symbol, SYMBOL_DIGITS, digits)) AC_L4_SYMBOLS[next].digits = digits;
   AC_L4GetDouble(symbol, SYMBOL_POINT, AC_L4_SYMBOLS[next].point);
   long spread_float_int = 0;
   if(AC_L4GetInteger(symbol, SYMBOL_SPREAD_FLOAT, spread_float_int)) AC_L4_SYMBOLS[next].spread_float = (spread_float_int != 0);
   long spread_spec = 0;
   if(AC_L4GetInteger(symbol, SYMBOL_SPREAD, spread_spec)) AC_L4_SYMBOLS[next].spread_spec_points = spread_spec;

   if(AC_L4_SYMBOLS[next].tick_available)
   {
      // TimeCurrent() is last-quote time in OnTimer. If the same stale quote pins
      // TimeCurrent, tick age can incorrectly become zero. Use L2's current
      // server-time ladder instead: TimeTradeServer -> TimeCurrent -> TimeGMT.
      datetime now_time = AC_L2CurrentSessionServerTime();
      long now_msc = (long)now_time * 1000;
      if(AC_L4_SYMBOLS[next].tick_time_msc > 0 && now_msc >= AC_L4_SYMBOLS[next].tick_time_msc)
      {
         AC_L4_SYMBOLS[next].tick_age_ms = now_msc - AC_L4_SYMBOLS[next].tick_time_msc;
         AC_L4_SYMBOLS[next].tick_age_seconds = (double)AC_L4_SYMBOLS[next].tick_age_ms / 1000.0;
      }
      else if(AC_L4_SYMBOLS[next].tick_time_broker > 0 && now_time >= AC_L4_SYMBOLS[next].tick_time_broker)
      {
         AC_L4_SYMBOLS[next].tick_age_ms = (long)(now_time - AC_L4_SYMBOLS[next].tick_time_broker) * 1000;
         AC_L4_SYMBOLS[next].tick_age_seconds = (double)AC_L4_SYMBOLS[next].tick_age_ms / 1000.0;
      }
      else
      {
         AC_L4_SYMBOLS[next].tick_age_ms = -1;
         AC_L4_SYMBOLS[next].tick_age_seconds = -1.0;
         if(AC_L4_SYMBOLS[next].failure_reason == "")
            AC_L4_SYMBOLS[next].failure_reason = "Tick time is ahead of current server time or unavailable; quote freshness unsafe.";
      }

      AC_L4_SYMBOLS[next].bid_valid = (AC_L4_SYMBOLS[next].bid > 0.0);
      AC_L4_SYMBOLS[next].ask_valid = (AC_L4_SYMBOLS[next].ask > 0.0);
      AC_L4_SYMBOLS[next].last_valid = (AC_L4_SYMBOLS[next].last > 0.0);
      AC_L4_SYMBOLS[next].bid_ask_valid = (AC_L4_SYMBOLS[next].bid_valid && AC_L4_SYMBOLS[next].ask_valid && AC_L4_SYMBOLS[next].ask >= AC_L4_SYMBOLS[next].bid);
      AC_L4_SYMBOLS[next].quote_valid_flag = (AC_L4_SYMBOLS[next].bid_ask_valid && AC_L4_SYMBOLS[next].tick_age_seconds >= 0.0);
      AC_L4_SYMBOLS[next].quote_quality = AC_L4QuoteQuality(AC_L4_SYMBOLS[next].tick_available, AC_L4_SYMBOLS[next].bid_ask_valid, AC_L4_SYMBOLS[next].tick_age_seconds);

      if(!AC_L4_SYMBOLS[next].bid_ask_valid && AC_L4_SYMBOLS[next].failure_reason == "")
         AC_L4_SYMBOLS[next].failure_reason = "Tick exists but bid/ask is invalid.";

      if(AC_L4_SYMBOLS[next].bid_ask_valid && AC_L4_SYMBOLS[next].point > 0.0)
      {
         double mid = (AC_L4_SYMBOLS[next].bid + AC_L4_SYMBOLS[next].ask) / 2.0;
         AC_L4_SYMBOLS[next].spread_price_live = AC_L4_SYMBOLS[next].ask - AC_L4_SYMBOLS[next].bid;
         AC_L4_SYMBOLS[next].spread_points_live = AC_L4_SYMBOLS[next].spread_price_live / AC_L4_SYMBOLS[next].point;
         AC_L4_SYMBOLS[next].spread_pips_live = AC_L4_SYMBOLS[next].spread_points_live / AC_L4PointsPerPip(AC_L4_SYMBOLS[next].digits);
         if(mid > 0.0)
         {
            AC_L4_SYMBOLS[next].spread_pct_live = (AC_L4_SYMBOLS[next].spread_price_live / mid) * 100.0;
            AC_L4_SYMBOLS[next].spread_bps_live = (AC_L4_SYMBOLS[next].spread_price_live / mid) * 10000.0;
         }
         AC_L4_SYMBOLS[next].spread_source = "Live bid/ask from SymbolInfoTick";
         AC_L4_SYMBOLS[next].spread_score = AC_L4SpreadScore(AC_L4_SYMBOLS[next].spread_bps_live, true);
         if(AC_L4_SYMBOLS[next].spread_points_live == 0.0)
            AC_L4_SYMBOLS[next].zero_spread_state = (AC_L4_SYMBOLS[next].quote_quality == "Fresh" ? "Fresh Zero Spread" : "Zero Spread Not Fresh");
         else
            AC_L4_SYMBOLS[next].zero_spread_state = "Not Zero";

         if(AC_L4_SYMBOLS[next].spread_spec_points >= 0)
         {
            double diff = MathAbs(AC_L4_SYMBOLS[next].spread_points_live - (double)AC_L4_SYMBOLS[next].spread_spec_points);
            AC_L4_SYMBOLS[next].spread_vs_spec_status = (diff <= 1.0 ? "Live near broker spec" : "Live differs from broker spec");
         }
      }
      else if(AC_L4_SYMBOLS[next].bid_ask_valid && AC_L4_SYMBOLS[next].point <= 0.0 && AC_L4_SYMBOLS[next].failure_reason == "")
      {
         AC_L4_SYMBOLS[next].failure_reason = "Tick exists but SYMBOL_POINT is unavailable; spread units unsafe.";
      }
   }
   else
   {
      AC_L4_SYMBOLS[next].quote_quality = "Missing Tick";
   }

   if(AC_L4GetDouble(symbol, SYMBOL_PRICE_CHANGE, AC_L4_SYMBOLS[next].daily_change_pct))
      AC_L4_SYMBOLS[next].daily_change_status = "Available";
   AC_L4GetDouble(symbol, SYMBOL_SESSION_OPEN, AC_L4_SYMBOLS[next].daily_open);
   AC_L4GetDouble(symbol, SYMBOL_BIDHIGH, AC_L4_SYMBOLS[next].daily_high_bid);
   AC_L4GetDouble(symbol, SYMBOL_BIDLOW, AC_L4_SYMBOLS[next].daily_low_bid);
   AC_L4GetDouble(symbol, SYMBOL_ASKHIGH, AC_L4_SYMBOLS[next].daily_high_ask);
   AC_L4GetDouble(symbol, SYMBOL_ASKLOW, AC_L4_SYMBOLS[next].daily_low_ask);
   AC_L4GetDouble(symbol, SYMBOL_LASTHIGH, AC_L4_SYMBOLS[next].daily_high_last);
   AC_L4GetDouble(symbol, SYMBOL_LASTLOW, AC_L4_SYMBOLS[next].daily_low_last);

   if(AC_L4_SYMBOLS[next].daily_high_bid > AC_L4_SYMBOLS[next].daily_low_bid && AC_L4_SYMBOLS[next].bid > 0.0)
      AC_L4_SYMBOLS[next].daily_range_position_pct = ((AC_L4_SYMBOLS[next].bid - AC_L4_SYMBOLS[next].daily_low_bid) / (AC_L4_SYMBOLS[next].daily_high_bid - AC_L4_SYMBOLS[next].daily_low_bid)) * 100.0;

   bool activity_api = false;
   activity_api = AC_L4GetDouble(symbol, SYMBOL_SESSION_AW, AC_L4_SYMBOLS[next].session_aw) || activity_api;
   activity_api = AC_L4GetDouble(symbol, SYMBOL_SESSION_VOLUME, AC_L4_SYMBOLS[next].session_volume) || activity_api;
   activity_api = AC_L4GetDouble(symbol, SYMBOL_SESSION_TURNOVER, AC_L4_SYMBOLS[next].session_turnover) || activity_api;
   activity_api = AC_L4GetDouble(symbol, SYMBOL_SESSION_INTEREST, AC_L4_SYMBOLS[next].session_interest) || activity_api;
   bool deals_api = AC_L4GetInteger(symbol, SYMBOL_SESSION_DEALS, AC_L4_SYMBOLS[next].session_deals);
   bool buy_orders_api = AC_L4GetInteger(symbol, SYMBOL_SESSION_BUY_ORDERS, AC_L4_SYMBOLS[next].session_buy_orders);
   bool sell_orders_api = AC_L4GetInteger(symbol, SYMBOL_SESSION_SELL_ORDERS, AC_L4_SYMBOLS[next].session_sell_orders);
   activity_api = activity_api || deals_api || buy_orders_api || sell_orders_api;
   bool activity_nonzero = (AC_L4_SYMBOLS[next].session_aw != 0.0 || AC_L4_SYMBOLS[next].session_volume != 0.0 || AC_L4_SYMBOLS[next].session_turnover != 0.0 || AC_L4_SYMBOLS[next].session_interest != 0.0 || AC_L4_SYMBOLS[next].session_deals != 0 || AC_L4_SYMBOLS[next].session_buy_orders != 0 || AC_L4_SYMBOLS[next].session_sell_orders != 0);
   if(activity_nonzero) AC_L4_SYMBOLS[next].activity_status = "Activity Available - Nonzero";
   else if(activity_api) AC_L4_SYMBOLS[next].activity_status = "Activity API Available - Zero Values";
   else AC_L4_SYMBOLS[next].activity_status = "Broker Not Providing";

   if(AC_L4_SYMBOLS[next].quote_quality == "Fresh" && AC_L4_SYMBOLS[next].spread_score != "Hostile")
      AC_L4_SYMBOLS[next].surface_quality = "Surface Usable";
   else if(AC_L4_SYMBOLS[next].quote_quality == "Missing Tick" || AC_L4_SYMBOLS[next].quote_quality == "Invalid Bid / Ask")
      AC_L4_SYMBOLS[next].surface_quality = "Surface Blocked";
   else
      AC_L4_SYMBOLS[next].surface_quality = "Surface Warning";

   AC_L4FinalizeCounters(AC_L4_SYMBOLS[next]);
}

void AC_RefreshLayer4MarketWatchTruth()
{
   AC_L4Reset();
   int total = SymbolsTotal(false);
   AC_L4_CACHE_KEY = AC_L4BuildCacheKey(total);

   for(int idx=0; idx<total; idx++)
   {
      string symbol = SymbolName(idx, false);
      if(symbol == "") continue;
      if(AC_L2MarketStateForSymbol(symbol) != "open") continue;
      AC_L4ScanOneOpenSymbol(symbol);
   }

   AC_L4_SCAN_STATUS = "Complete";
   if(AC_L4_MISSING_TICK > 0 || AC_L4_INVALID_BIDASK > 0 || AC_L4_STALE_QUOTES > 0 || AC_L4_HIGH_SPREAD_WARNINGS > 0)
      AC_L4_SCAN_STATUS = "Complete with warnings";
   AC_L4_SCAN_DURATION_MS = GetTickCount() - AC_L4_SCAN_STARTED_MS;
   // Refresh key is deliberately data-change driven, not refresh-time driven.
   // This stops a clock tick from forcing all Dossiers/Gateway inputs dirty while still changing when live quote packets change.
   AC_L4_REFRESH_KEY = AC_L4_CACHE_KEY + " | data_change=" + AC_FileIOContentSignature(AC_L4PacketDataChangeKey());
   AC_L4_READY = true;
   AC_BuildLayer4Texts();
}

bool AC_L4ShouldRunFullScan()
{
   int total = SymbolsTotal(false);
   if(!AC_L4_READY) return true;
   if(AC_L4_CACHE_KEY == "not_scanned") return true;
   if(AC_L4_CACHE_KEY != AC_L4BuildCacheKey(total)) return true;
   if(AC_L4_DOSSIER_REFRESH_SECONDS <= 0)
   {
      uint now_ms = GetTickCount();
      if(AC_L4_LAST_REFRESH_MS == now_ms) return false;
      return (now_ms - AC_L4_LAST_REFRESH_MS) >= (uint)AC_TIMER_MILLISECONDS;
   }
   if(AC_L2CurrentSessionServerTime() - AC_L4_LAST_REFRESH_TIME >= AC_L4_DOSSIER_REFRESH_SECONDS) return true;
   return false;
}

#endif
