#ifndef AC_L3_REFRESH_MQH
#define AC_L3_REFRESH_MQH

string AC_L3SymbolUniverseFingerprint(const int total)
{
   ulong hash = 1469598103934665603;
   for(int idx = 0; idx < total; idx++)
   {
      string symbol = SymbolName(idx, false);
      int len = StringLen(symbol);
      hash = hash ^ (ulong)(idx + 1);
      hash = hash * 1099511628211;
      for(int ch = 0; ch < len; ch++)
      {
         hash = hash ^ (ulong)StringGetCharacter(symbol, ch);
         hash = hash * 1099511628211;
      }
   }
   return IntegerToString((long)hash);
}

string AC_L3BuildCacheKey(const int total)
{
   return AC_DOSSIER_SHELL_SCHEMA_VERSION
      + " | server=" + AccountInfoString(ACCOUNT_SERVER)
      + " | account=" + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN))
      + " | account_currency=" + AccountInfoString(ACCOUNT_CURRENCY)
      + " | symbols=" + IntegerToString(total)
      + " | universe_fingerprint=" + AC_L3SymbolUniverseFingerprint(total)
      + " | owner=L3BrokerSpecsTruth";
}

void AC_RefreshLayer3BrokerSpecsTruth()
{
   AC_L3Reset();
   int total = SymbolsTotal(false);
   AC_L3_LAST_SYMBOLS_TOTAL = total;
   AC_L3_LAST_L2_ROUTE_KEY = AC_L2_ROUTE_GENERATION_KEY;
   // L3 owns static/semi-static broker symbol specs and account-currency value
   // metadata. Ordinary L2 open/closed route churn must not invalidate L3, but
   // broker server/account/currency/symbol-universe changes must.
   AC_L3_CACHE_KEY = AC_L3BuildCacheKey(total);

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
   int total = SymbolsTotal(false);
   if(!AC_L3_READY) return true;
   if(AC_L3_LAST_SYMBOLS_TOTAL != total) return true;
   if(AC_L3_CACHE_KEY != AC_L3BuildCacheKey(total)) return true;
   return false;
}

#endif