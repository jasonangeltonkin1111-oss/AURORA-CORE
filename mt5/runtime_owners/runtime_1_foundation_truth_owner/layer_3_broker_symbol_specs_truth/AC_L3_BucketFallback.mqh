#ifndef AC_L3_BUCKET_FALLBACK_MQH
#define AC_L3_BUCKET_FALLBACK_MQH

string AC_L3Upper(string value)
{
   StringToUpper(value);
   return value;
}

string AC_L3CleanSymbolRoot(string symbol)
{
   int dot = StringFind(symbol, ".");
   if(dot > 0) symbol = StringSubstr(symbol, 0, dot);
   return AC_L3Upper(symbol);
}

bool AC_L3ApplyUniverseRow(AC_L3SymbolSpecs &s, const string row)
{
   if(row == "") return false;
   string parts[];
   int count = StringSplit(row, '|', parts);
   if(count < 8) return false;
   s.asset_class = parts[4];
   s.market_group = parts[5];
   s.market_segment = parts[6];
   s.ranking_group = parts[7];
   s.classification_source = "Runtime 2 taxonomy fallback";
   s.classification_quality = "Bucket Ready - Taxonomy Fallback";
   s.classification_fallback_used = true;
   return true;
}

bool AC_L3ApplyUniverseFallback(AC_L3SymbolSpecs &s)
{
   string exact = AC_L3Upper(s.symbol);
   string root = AC_L3CleanSymbolRoot(s.symbol);
   for(int i = 0; i < AC_UniverseLoadedRowCount(); i++)
   {
      string row = AC_UniverseGeneratedRowByIndex(i);
      string parts[];
      int count = StringSplit(row, '|', parts);
      if(count < 8) continue;
      string broker_symbol = AC_L3Upper(parts[2]);
      string canonical_symbol = AC_L3Upper(parts[3]);
      if(broker_symbol == exact || canonical_symbol == exact || broker_symbol == root || canonical_symbol == root)
      {
         return AC_L3ApplyUniverseRow(s, row);
      }
   }
   return false;
}

bool AC_L3LooksLikeFX(const string root)
{
   if(StringLen(root) != 6) return false;
   string known = "|USD|EUR|GBP|JPY|AUD|NZD|CAD|CHF|SEK|NOK|DKK|MXN|ZAR|TRY|CZK|PLN|HKD|SGD|CNH|HUF|";
   string base = StringSubstr(root, 0, 3);
   string quote = StringSubstr(root, 3, 3);
   return (StringFind(known, "|" + base + "|") >= 0 && StringFind(known, "|" + quote + "|") >= 0);
}

void AC_L3ApplySymbolGrammarFallback(AC_L3SymbolSpecs &s)
{
   string root = AC_L3CleanSymbolRoot(s.symbol);
   if(AC_L3LooksLikeFX(root))
   {
      s.asset_class = "FX";
      s.market_group = "Forex";
      s.market_segment = "Currency Pair";
      s.ranking_group = "Currency / Forex Pairs";
      s.classification_source = "Symbol grammar fallback";
      s.classification_quality = "Bucket Ready - Symbol Grammar Fallback";
      s.classification_fallback_used = true;
      return;
   }
   if(root == "XAUUSD" || root == "XAGUSD" || root == "XPTUSD" || root == "XPDUSD")
   {
      s.asset_class = "Commodities";
      s.market_group = "Precious Metals";
      s.market_segment = (root == "XAGUSD" ? "Silver" : (root == "XAUUSD" ? "Gold" : "Precious Metal"));
      s.ranking_group = "Commodities / Precious Metals";
      s.classification_source = "Symbol grammar fallback";
      s.classification_quality = "Bucket Ready - Symbol Grammar Fallback";
      s.classification_fallback_used = true;
      return;
   }
   if(StringFind(root, "BTC") >= 0 || StringFind(root, "ETH") >= 0 || StringFind(root, "USDT") >= 0)
   {
      s.asset_class = "Crypto";
      s.market_group = "All Crypto CFDs";
      s.market_segment = "Crypto Asset";
      s.ranking_group = "Crypto Currency / All Crypto CFDs";
      s.classification_source = "Symbol grammar fallback";
      s.classification_quality = "Bucket Ready - Symbol Grammar Fallback";
      s.classification_fallback_used = true;
      return;
   }
   s.asset_class = "Unknown";
   s.market_group = "Unknown";
   s.market_segment = "Unknown";
   s.ranking_group = "Unknown";
   s.classification_source = "Unresolved";
   s.classification_quality = "Bucket Unknown";
   s.classification_fallback_used = false;
}

void AC_L3ClassifySymbol(AC_L3SymbolSpecs &s)
{
   s.asset_class = "Unknown";
   s.market_group = "Unknown";
   s.market_segment = "Unknown";
   s.ranking_group = "Unknown";
   s.classification_source = "Unresolved";
   s.classification_quality = "Bucket Unknown";
   s.classification_fallback_used = false;

   if(AC_L3ApplyUniverseFallback(s)) return;
   AC_L3ApplySymbolGrammarFallback(s);
}

#endif