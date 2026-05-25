#ifndef AC_L3_REFRESH_MQH
#define AC_L3_REFRESH_MQH
void AC_RefreshLayer3BrokerSpecsTruth()
{
   AC_L3Reset();
   int total = SymbolsTotal(false);
   AC_L3_LAST_SYMBOLS_TOTAL = total;
   AC_L3_LAST_L2_ROUTE_KEY = AC_L2_ROUTE_GENERATION_KEY;
   // L3 owns static/semi-static broker symbol specs and value metadata. It must
   // not be invalidated by ordinary L2 open/closed route churn; L5 consumes L2
   // and L3 separately when building the hard gate.
   AC_L3_CACHE_KEY = AC_DOSSIER_SHELL_SCHEMA_VERSION + " | symbols " + IntegerToString(total) + " | owner=L3BrokerSpecsTruth | broker_universe=SymbolsTotal_false";

   for(int idx = 0; idx < total; idx++)
   {
      string symbol = SymbolName(idx, false);
      if(symbol == "") continue;
      AC_L3ScanOneSymbol(symbol);
   }

   AC_L3_SCAN_STATUS = "Complete";
   if(AC_L3_SPEC_UNAVAILABLE_COUNT > 0 || AC_L3_CRITICAL_MISSING_COUNT > 0)
      AC_L3_SCAN_STATUS = "Degraded - specs incomplete";
   else if(AC_L3_VALUE_UNAVAILABLE_COUNT > 0 || AC_L3_MARGIN_UNAVAILABLE_COUNT > 0)
      AC_L3_SCAN_STATUS = "Degraded - value/margin unavailable";
   else if(AC_L3_SPEC_PARTIAL_COUNT > 0 || AC_L3_VALUE_PARTIAL_COUNT > 0 || AC_L3_MARGIN_PARTIAL_COUNT > 0)
      AC_L3_SCAN_STATUS = "Review - specs complete with value/margin partials";
   AC_L3_SCAN_DURATION_MS = GetTickCount() - AC_L3_SCAN_STARTED_MS;
   AC_L3_READY = true;
   AC_BuildLayer3Texts();
}

bool AC_L3ShouldRunFullScan()
{
   if(!AC_L3_READY) return true;
   if(AC_L3_LAST_SYMBOLS_TOTAL != SymbolsTotal(false)) return true;
   return false;
}

#endif