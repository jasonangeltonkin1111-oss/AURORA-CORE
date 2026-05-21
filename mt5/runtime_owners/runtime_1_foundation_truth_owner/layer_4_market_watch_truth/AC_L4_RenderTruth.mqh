#ifndef AC_L4_RENDER_TRUTH_MQH
#define AC_L4_RENDER_TRUTH_MQH

void AC_BuildLayer4Texts()
{
   AC_L4_BOARD_SECTION = "\r\nLAYER 4 - LIVE QUOTE AND SPREAD TRUTH\r\n";
   AC_L4_BOARD_SECTION += "----------------------------------------\r\n";
   AC_L4_BOARD_SECTION += "Status:                     " + AC_L4_SCAN_STATUS + "\r\n";
   AC_L4_BOARD_SECTION += "Eligible Open Symbols:      " + IntegerToString(AC_L4_ELIGIBLE_OPEN) + "\r\n";
   AC_L4_BOARD_SECTION += "Scanned:                    " + IntegerToString(AC_L4_SCANNED) + "\r\n";
   AC_L4_BOARD_SECTION += "Fresh Quotes:               " + IntegerToString(AC_L4_FRESH_QUOTES) + "\r\n";
   AC_L4_BOARD_SECTION += "Aging Quotes:               " + IntegerToString(AC_L4_AGING_QUOTES) + "\r\n";
   AC_L4_BOARD_SECTION += "Stale Quotes:               " + IntegerToString(AC_L4_STALE_QUOTES) + "\r\n";
   AC_L4_BOARD_SECTION += "Missing Tick Packets:       " + IntegerToString(AC_L4_MISSING_TICK) + "\r\n";
   AC_L4_BOARD_SECTION += "Invalid Bid/Ask:            " + IntegerToString(AC_L4_INVALID_BIDASK) + "\r\n";
   AC_L4_BOARD_SECTION += "Fresh Zero Spread:          " + IntegerToString(AC_L4_ZERO_SPREAD_FRESH) + "\r\n";
   AC_L4_BOARD_SECTION += "High Spread Warnings:       " + IntegerToString(AC_L4_HIGH_SPREAD_WARNINGS) + "\r\n";
   AC_L4_BOARD_SECTION += "Daily Change Available:     " + IntegerToString(AC_L4_DAILY_CHANGE_AVAILABLE) + "\r\n";
   AC_L4_BOARD_SECTION += "Scan Duration:              " + IntegerToString((int)AC_L4_SCAN_DURATION_MS) + " ms\r\n";
   AC_L4_BOARD_SECTION += "Worst Blocker:              " + AC_L4_WORST_FAILURE_REASON + "\r\n";
   AC_L4_BOARD_SECTION += "Trade Permission:           FALSE\r\n";

   AC_L4_WORKBENCH_SECTION = "\r\nL4_MARKETWATCH_TRUTH\r\n";
   AC_L4_WORKBENCH_SECTION += "----------------------------------------\r\n";
   AC_L4_WORKBENCH_SECTION += "scan_status=" + AC_L4_SCAN_STATUS + "\r\n";
   AC_L4_WORKBENCH_SECTION += "scan_duration_ms=" + IntegerToString((int)AC_L4_SCAN_DURATION_MS) + "\r\n";
   AC_L4_WORKBENCH_SECTION += "eligible_open=" + IntegerToString(AC_L4_ELIGIBLE_OPEN) + "\r\n";
   AC_L4_WORKBENCH_SECTION += "fresh_quotes=" + IntegerToString(AC_L4_FRESH_QUOTES) + "\r\n";
   AC_L4_WORKBENCH_SECTION += "aging_quotes=" + IntegerToString(AC_L4_AGING_QUOTES) + "\r\n";
   AC_L4_WORKBENCH_SECTION += "stale_quotes=" + IntegerToString(AC_L4_STALE_QUOTES) + "\r\n";
   AC_L4_WORKBENCH_SECTION += "missing_tick=" + IntegerToString(AC_L4_MISSING_TICK) + "\r\n";
   AC_L4_WORKBENCH_SECTION += "invalid_bidask=" + IntegerToString(AC_L4_INVALID_BIDASK) + "\r\n";
   AC_L4_WORKBENCH_SECTION += "zero_spread_fresh=" + IntegerToString(AC_L4_ZERO_SPREAD_FRESH) + "\r\n";
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

#endif
