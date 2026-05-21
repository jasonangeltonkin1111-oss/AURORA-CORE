#ifndef AC_L4_RENDER_TRUTH_MQH
#define AC_L4_RENDER_TRUTH_MQH

void AC_BuildLayer4Texts()
{
   AC_L4_BOARD_SECTION = "\r\nLAYER 4 - LIVE QUOTE AND SPREAD TRUTH\r\n";
   AC_L4_BOARD_SECTION += "----------------------------------------\r\n";
   AC_L4_BOARD_SECTION += "Status:                     " + AC_L4_SCAN_STATUS + "\r\n";
   AC_L4_BOARD_SECTION += "Eligible Open Symbols:      " + IntegerToString(AC_L4_ELIGIBLE_OPEN) + "\r\n";
   AC_L4_BOARD_SECTION += "Scanned:                    " + AC_L4Ratio(AC_L4_SCANNED, AC_L4_ELIGIBLE_OPEN) + "\r\n";
   AC_L4_BOARD_SECTION += "Fresh Quotes:               " + IntegerToString(AC_L4_FRESH_QUOTES) + "\r\n";
   AC_L4_BOARD_SECTION += "Aging Quotes:               " + IntegerToString(AC_L4_AGING_QUOTES) + "\r\n";
   AC_L4_BOARD_SECTION += "Stale Quotes:               " + IntegerToString(AC_L4_STALE_QUOTES) + "\r\n";
   AC_L4_BOARD_SECTION += "Missing Tick Packets:       " + IntegerToString(AC_L4_MISSING_TICK) + "\r\n";
   AC_L4_BOARD_SECTION += "Invalid Bid/Ask:            " + IntegerToString(AC_L4_INVALID_BIDASK) + "\r\n";
   AC_L4_BOARD_SECTION += "Fresh Zero Spread:          " + IntegerToString(AC_L4_ZERO_SPREAD_FRESH) + "\r\n";
   AC_L4_BOARD_SECTION += "High Spread Warnings:       " + IntegerToString(AC_L4_HIGH_SPREAD_WARNINGS) + "\r\n";
   AC_L4_BOARD_SECTION += "Daily Change Available:     " + AC_L4Ratio(AC_L4_DAILY_CHANGE_AVAILABLE, AC_L4_ELIGIBLE_OPEN) + "\r\n";
   AC_L4_BOARD_SECTION += "Dossier Refresh:            Open symbols every " + IntegerToString(AC_L4_DOSSIER_REFRESH_SECONDS) + " sec\r\n";
   AC_L4_BOARD_SECTION += "Top List Refresh Contract:  " + IntegerToString(AC_L4_TOP_LIST_REFRESH_SECONDS) + " sec when ranking exists\r\n";
   AC_L4_BOARD_SECTION += "Scan Duration:              " + IntegerToString((int)AC_L4_SCAN_DURATION_MS) + " ms\r\n";
   AC_L4_BOARD_SECTION += "Worst Blocker:              " + AC_L4_WORST_FAILURE_REASON + "\r\n";
   AC_L4_BOARD_SECTION += "Trade Permission:           FALSE\r\n";

   AC_L4_WORKBENCH_SECTION = "\r\nL4_MARKETWATCH_TRUTH\r\n";
   AC_L4_WORKBENCH_SECTION += "----------------------------------------\r\n";
   AC_L4_WORKBENCH_SECTION += "scan_status=" + AC_L4_SCAN_STATUS + "\r\n";
   AC_L4_WORKBENCH_SECTION += "scan_duration_ms=" + IntegerToString((int)AC_L4_SCAN_DURATION_MS) + "\r\n";
   AC_L4_WORKBENCH_SECTION += "cache_key=" + AC_L4_CACHE_KEY + "\r\n";
   AC_L4_WORKBENCH_SECTION += "eligible_open=" + IntegerToString(AC_L4_ELIGIBLE_OPEN) + "\r\n";
   AC_L4_WORKBENCH_SECTION += "scanned=" + IntegerToString(AC_L4_SCANNED) + "\r\n";
   AC_L4_WORKBENCH_SECTION += "fresh_quotes=" + IntegerToString(AC_L4_FRESH_QUOTES) + "\r\n";
   AC_L4_WORKBENCH_SECTION += "aging_quotes=" + IntegerToString(AC_L4_AGING_QUOTES) + "\r\n";
   AC_L4_WORKBENCH_SECTION += "stale_quotes=" + IntegerToString(AC_L4_STALE_QUOTES) + "\r\n";
   AC_L4_WORKBENCH_SECTION += "missing_tick=" + IntegerToString(AC_L4_MISSING_TICK) + "\r\n";
   AC_L4_WORKBENCH_SECTION += "invalid_bidask=" + IntegerToString(AC_L4_INVALID_BIDASK) + "\r\n";
   AC_L4_WORKBENCH_SECTION += "zero_spread_fresh=" + IntegerToString(AC_L4_ZERO_SPREAD_FRESH) + "\r\n";
   AC_L4_WORKBENCH_SECTION += "daily_change_available=" + IntegerToString(AC_L4_DAILY_CHANGE_AVAILABLE) + "\r\n";
   AC_L4_WORKBENCH_SECTION += "high_spread_warnings=" + IntegerToString(AC_L4_HIGH_SPREAD_WARNINGS) + "\r\n";
   AC_L4_WORKBENCH_SECTION += "symbolinfotick_success=" + IntegerToString(AC_L4_SYMBOLINFO_TICK_SUCCESS) + "\r\n";
   AC_L4_WORKBENCH_SECTION += "symbolinfotick_failure=" + IntegerToString(AC_L4_SYMBOLINFO_TICK_FAILURE) + "\r\n";
   AC_L4_WORKBENCH_SECTION += "trade_permission=false\r\n";
}

string AC_Layer4BoardSection()
{
   if(!AC_L4_READY)
      return "\r\nLAYER 4 - LIVE QUOTE AND SPREAD TRUTH\r\n----------------------------------------\r\nStatus: Pending\r\n";
   return AC_L4_BOARD_SECTION;
}

string AC_Layer4WorkbenchSection()
{
   if(!AC_L4_READY)
      return "\r\nL4_MARKETWATCH_TRUTH\r\nstatus=pending\r\n";
   return AC_L4_WORKBENCH_SECTION;
}

string AC_Layer4DossierSection(const string symbol)
{
   string market_state = AC_L2MarketStateForSymbol(symbol);
   string text = "\r\nLAYER 4 - LIVE QUOTE AND SPREAD TRUTH\r\n";
   text += "----------------------------------------\r\n";

   if(market_state != "open")
   {
      text += "Status: Cut Off\r\n";
      text += "Reason: Layer 2 market state is not Open\r\n";
      text += "Live Quote Truth: Not refreshed while market is closed or unknown\r\n";
      text += "Trade Permission: FALSE\r\n";
      return text;
   }

   int idx = AC_L4FindIndex(symbol);
   if(idx < 0)
   {
      text += "Status: Pending\r\n";
      text += "Reason: Layer 4 packet has not scanned this open symbol yet\r\n";
      text += "Trade Permission: FALSE\r\n";
      return text;
   }

   AC_L4SymbolPacket p = AC_L4_SYMBOLS[idx];
   text += "Status: " + p.scan_status + "\r\n";
   text += "Quote Quality: " + p.quote_quality + "\r\n";
   text += "Surface Quality: " + p.surface_quality + "\r\n";
   text += "Tick Source: SymbolInfoTick\r\n";
   text += "Tick Time: " + AC_L4DateTimeText(p.tick_time_broker) + " broker/server\r\n";
   text += "Tick Age: " + AC_L4NumberText(p.tick_age_seconds, 1) + " sec\r\n";
   text += "Bid: " + AC_L4PriceText(p.bid, p.digits) + "\r\n";
   text += "Ask: " + AC_L4PriceText(p.ask, p.digits) + "\r\n";
   text += "Last: " + AC_L4PriceText(p.last, p.digits) + "\r\n";
   text += "Spread: " + AC_L4NumberText(p.spread_points_live, 1) + " points / " + AC_L4NumberText(p.spread_pips_live, 1) + " pips / " + AC_L4BpsText(p.spread_bps_live) + "\r\n";
   text += "Spread Score: " + p.spread_score + "\r\n";
   text += "Spread Source: " + p.spread_source + "\r\n";
   text += "Broker Spread Spec: " + IntegerToString((int)p.spread_spec_points) + " points / " + (p.spread_float ? "Floating" : "Fixed or unspecified") + "\r\n";
   text += "Spread Check: " + p.spread_vs_spec_status + "\r\n";
   text += "Zero Spread State: " + p.zero_spread_state + "\r\n";

   text += "\r\nDaily Change\r\n";
   text += "----------------------------------------\r\n";
   text += "Daily Change: " + (p.daily_change_status == "Available" ? AC_L4PctText(p.daily_change_pct) : "Not available") + "\r\n";
   text += "Daily Open: " + AC_L4PriceText(p.daily_open, p.digits) + "\r\n";
   text += "Daily High Bid: " + AC_L4PriceText(p.daily_high_bid, p.digits) + "\r\n";
   text += "Daily Low Bid: " + AC_L4PriceText(p.daily_low_bid, p.digits) + "\r\n";
   text += "Daily High Ask: " + AC_L4PriceText(p.daily_high_ask, p.digits) + "\r\n";
   text += "Daily Low Ask: " + AC_L4PriceText(p.daily_low_ask, p.digits) + "\r\n";
   text += "Daily Range Position: " + AC_L4PctText(p.daily_range_position_pct) + "\r\n";
   text += "Daily Change Source: Broker Market Watch property\r\n";

   text += "\r\nActivity\r\n";
   text += "----------------------------------------\r\n";
   text += "Session Average Weighted Price: " + AC_L4PriceText(p.session_aw, p.digits) + "\r\n";
   text += "Session Volume: " + AC_L4NumberText(p.session_volume, 2) + "\r\n";
   text += "Session Turnover: " + AC_L4NumberText(p.session_turnover, 2) + "\r\n";
   text += "Session Deals: " + IntegerToString((int)p.session_deals) + "\r\n";
   text += "Activity Status: " + p.activity_status + "\r\n";

   text += "\r\nQuality\r\n";
   text += "----------------------------------------\r\n";
   text += "Failure Reason: " + AC_L4TextOrNA(p.failure_reason) + "\r\n";
   text += "Trade Permission: FALSE\r\n";
   return text;
}

string AC_Layer4StatusRow()
{
   return "schema_name=layer_status|schema_version=v4.0|layer_id=4|layer_name=" + AC_LAYER_4_NAME
      + "|source_owner=" + AC_RUNTIME1_OWNER
      + "|build_version=" + AC_BUILD_VERSION
      + "|upgrade_id=" + AC_UPGRADE_ID
      + "|layer_status=" + (AC_L4_READY ? AC_L4_SCAN_STATUS : "pending")
      + "|eligible_open=" + IntegerToString(AC_L4_ELIGIBLE_OPEN)
      + "|scanned=" + IntegerToString(AC_L4_SCANNED)
      + "|fresh_quotes=" + IntegerToString(AC_L4_FRESH_QUOTES)
      + "|aging_quotes=" + IntegerToString(AC_L4_AGING_QUOTES)
      + "|stale_quotes=" + IntegerToString(AC_L4_STALE_QUOTES)
      + "|missing_tick=" + IntegerToString(AC_L4_MISSING_TICK)
      + "|invalid_bidask=" + IntegerToString(AC_L4_INVALID_BIDASK)
      + "|zero_spread_fresh=" + IntegerToString(AC_L4_ZERO_SPREAD_FRESH)
      + "|daily_change_available=" + IntegerToString(AC_L4_DAILY_CHANGE_AVAILABLE)
      + "|cache_key=" + AC_L4_CACHE_KEY
      + "|trade_permission=false";
}

#endif