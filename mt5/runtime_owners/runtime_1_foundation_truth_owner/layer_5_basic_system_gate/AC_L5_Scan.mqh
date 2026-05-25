#ifndef AC_L5_SCAN_MQH
#define AC_L5_SCAN_MQH
AC_L5GatePacket AC_L5EvaluateSymbol(const string symbol)
{
   AC_L5GatePacket p;
   p.symbol = symbol;
   p.gate_status = "blocked";
   p.gate_reason = "";
   p.l2_gate = "not_ready";
   p.l3_gate = "not_ready";
   p.l4_gate = "not_ready";
   p.pass = false;
   p.blocked_closed_market = false;
   p.blocked_stale_quote = false;
   p.blocked_missing_tick = false;
   p.blocked_invalid_bidask = false;
   p.blocked_missing_specs = false;
   p.blocked_trade_mode = false;
   p.blocked_absurd_spread = false;
   p.blocked_classification_review = false;
   p.blocked_l4_surface_not_usable = false;
   p.trade_permission = false;

   if(!AC_L2_READY)
   {
      AC_L5AppendReason(p.gate_reason, "l2_not_ready");
      AC_L5_BLOCK_L2_NOT_READY++;
      return p;
   }

   string market_state = AC_L2MarketStateForSymbol(symbol);
   p.l2_gate = market_state;
   if(market_state != "open")
   {
      p.blocked_closed_market = true;
      AC_L5AppendReason(p.gate_reason, "market_not_open");
      AC_L5_BLOCK_CLOSED_MARKET++;
      return p;
   }

   if(!AC_L3_READY)
   {
      AC_L5AppendReason(p.gate_reason, "l3_not_ready");
      AC_L5_BLOCK_L3_NOT_READY++;
      return p;
   }
   int l3_index = AC_L3FindIndex(symbol);
   if(l3_index < 0)
   {
      p.blocked_missing_specs = true;
      AC_L5AppendReason(p.gate_reason, "l3_specs_missing");
      AC_L5_BLOCK_MISSING_SPECS++;
      return p;
   }
   AC_L3SymbolSpecs l3 = AC_L3_SYMBOLS[l3_index];
   p.l3_gate = l3.source_quality;

   if(!AC_L5SpecsEssentialReady(l3))
   {
      p.blocked_missing_specs = true;
      AC_L5AppendReason(p.gate_reason, "essential_specs_missing");
      AC_L5_BLOCK_MISSING_SPECS++;
   }
   if(!AC_L5TradeModeAllowed(l3.trade_mode))
   {
      p.blocked_trade_mode = true;
      AC_L5AppendReason(p.gate_reason, "trade_mode_disabled");
      AC_L5_BLOCK_TRADE_MODE++;
   }
   if(AC_L5ClassificationRequiresReview(l3))
   {
      p.blocked_classification_review = true;
      AC_L5AppendReason(p.gate_reason, "classification_review_required");
      AC_L5_BLOCK_CLASSIFICATION_REVIEW++;
   }

   if(!AC_L4_READY)
   {
      AC_L5AppendReason(p.gate_reason, "l4_not_ready");
      AC_L5_BLOCK_L4_NOT_READY++;
      return p;
   }
   int l4_index = AC_L4FindIndex(symbol);
   if(l4_index < 0)
   {
      p.blocked_missing_tick = true;
      AC_L5AppendReason(p.gate_reason, "l4_quote_packet_missing");
      AC_L5_BLOCK_MISSING_TICK++;
      return p;
   }
   AC_L4SymbolPacket l4 = AC_L4_SYMBOLS[l4_index];
   p.l4_gate = l4.quote_quality;

   if(!l4.tick_available)
   {
      p.blocked_missing_tick = true;
      AC_L5AppendReason(p.gate_reason, "tick_missing");
      AC_L5_BLOCK_MISSING_TICK++;
   }
   if(!AC_L5QuoteFreshEnough(l4))
   {
      p.blocked_stale_quote = true;
      AC_L5AppendReason(p.gate_reason, "quote_not_fresh_enough");
      AC_L5_BLOCK_STALE_QUOTE++;
   }
   if(!l4.bid_ask_valid)
   {
      p.blocked_invalid_bidask = true;
      AC_L5AppendReason(p.gate_reason, "invalid_bid_ask");
      AC_L5_BLOCK_INVALID_BIDASK++;
   }
   if(!AC_L5SurfaceUsable(l4))
   {
      p.blocked_l4_surface_not_usable = true;
      AC_L5AppendReason(p.gate_reason, "l4_surface_not_usable");
      AC_L5_BLOCK_L4_SURFACE_NOT_USABLE++;
   }
   if(AC_L5SpreadAbsurd(l4))
   {
      p.blocked_absurd_spread = true;
      AC_L5AppendReason(p.gate_reason, "absurd_spread_bps");
      AC_L5_BLOCK_ABSURD_SPREAD++;
   }

   p.pass = (p.gate_reason == "");
   p.gate_status = p.pass ? "pass" : "blocked";
   if(p.pass)
   {
      p.gate_reason = "eligible_basic_system_gate";
      AC_L5_GATE_PASS++;
   }
   else
   {
      AC_L5TrackWorstBlocker(p.gate_reason);
   }
   return p;
}

void AC_RefreshLayer5BasicSystemGate()
{
   string upstream_key = AC_L5UpstreamKey();
   AC_L5Reset();
   AC_L5_LAST_UPSTREAM_KEY = upstream_key;

   int total = SymbolsTotal(false);
   ArrayResize(AC_L5_SYMBOLS, 0);

   for(int i = 0; i < total; i++)
   {
      string symbol = SymbolName(i, false);
      if(symbol == "") continue;
      AC_L5GatePacket p = AC_L5EvaluateSymbol(symbol);
      int n = ArraySize(AC_L5_SYMBOLS);
      ArrayResize(AC_L5_SYMBOLS, n + 1);
      AC_L5_SYMBOLS[n] = p;
      AC_L5_SCANNED++;
      if(!p.pass) AC_L5TrackWorstBlocker(p.gate_reason);
   }

   AC_L5_SCAN_DURATION_MS = GetTickCount() - AC_L5_SCAN_STARTED_MS;
   AC_L5_REFRESH_DURATION_MS = AC_L5_SCAN_DURATION_MS;
   AC_L5_STATUS = "Complete";
   AC_L5_TRUST_STATE = "Gate Ready";
   AC_L5SyncCompatibilityFields();
   AC_L5_MAIN_BLOCKER = (AC_L5_GATE_BLOCKED > 0 ? AC_L5_WORST_BLOCKER : "None");
   AC_L5_READY = true;
   AC_L5SyncCompatibilityFields();
   AC_BuildLayer5Texts();
}

int AC_L5FindIndex(const string symbol)
{
   int total = ArraySize(AC_L5_SYMBOLS);
   if(total <= 0) return -1;

   if(AC_L5_FIND_LAST_INDEX >= 0 && AC_L5_FIND_LAST_INDEX < total && AC_L5_SYMBOLS[AC_L5_FIND_LAST_INDEX].symbol == symbol)
   {
      AC_L5_FIND_CACHE_HITS++;
      return AC_L5_FIND_LAST_INDEX;
   }

   int next_index = AC_L5_FIND_LAST_INDEX + 1;
   if(next_index >= 0 && next_index < total && AC_L5_SYMBOLS[next_index].symbol == symbol)
   {
      AC_L5_FIND_LAST_INDEX = next_index;
      AC_L5_FIND_CACHE_HITS++;
      return next_index;
   }

   int previous_index = AC_L5_FIND_LAST_INDEX - 1;
   if(previous_index >= 0 && previous_index < total && AC_L5_SYMBOLS[previous_index].symbol == symbol)
   {
      AC_L5_FIND_LAST_INDEX = previous_index;
      AC_L5_FIND_CACHE_HITS++;
      return previous_index;
   }

   AC_L5_FIND_FULL_SCAN_COUNT++;
   for(int i = 0; i < total; i++)
   {
      if(AC_L5_SYMBOLS[i].symbol == symbol)
      {
         AC_L5_FIND_LAST_INDEX = i;
         return i;
      }
   }
   return -1;
}

#endif
