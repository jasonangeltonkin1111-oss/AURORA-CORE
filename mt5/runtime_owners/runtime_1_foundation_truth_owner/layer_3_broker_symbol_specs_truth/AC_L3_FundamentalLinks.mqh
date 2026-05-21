#ifndef AC_L3_FUNDAMENTAL_LINKS_MQH
#define AC_L3_FUNDAMENTAL_LINKS_MQH

string AC_L3SearchUrl(const string query)
{
   string q = query;
   StringReplace(q, " ", "+");
   return "https://www.google.com/search?q=" + q;
}

string AC_L3YahooFxUrl(const string root)
{
   return "https://finance.yahoo.com/quote/" + root + "=X";
}

string AC_L3YahooQuoteUrl(const string root)
{
   return "https://finance.yahoo.com/quote/" + root;
}

string AC_L3LeftPadZeros(string value, const int width)
{
   while(StringLen(value) < width) value = "0" + value;
   return value;
}

string AC_L3ExternalQuoteSymbol(const string symbol)
{
   string lower = symbol;
   StringToLower(lower);
   string root = AC_L3CleanSymbolRoot(symbol);
   if(StringFind(lower, ".xhkg") > 0)
      return AC_L3LeftPadZeros(root, 4) + ".HK";
   return root;
}

void AC_L3BuildFundamentalHints(AC_L3SymbolSpecs &s)
{
   string root = AC_L3CleanSymbolRoot(s.symbol);
   string external_symbol = AC_L3ExternalQuoteSymbol(s.symbol);
   s.fundamental_supported = "Unsupported";
   s.fundamental_identity_quality = "Not available";
   s.yahoo_query = "Not available";
   s.google_finance_query = "Not available";
   s.marketwatch_query = "Not available";
   s.sec_edgar_query = "Not available";
   s.finviz_query = "Not available";
   s.morningstar_query = "Not available";
   s.link_truth = "Literal lookup links - not verified market data";

   if(s.asset_class == "FX" || s.asset_class == "Forex")
   {
      string base = (StringLen(root) >= 6 ? StringSubstr(root, 0, 3) : "");
      string quote = (StringLen(root) >= 6 ? StringSubstr(root, 3, 3) : "");
      s.fundamental_supported = "FX macro";
      s.fundamental_identity_quality = "Currency pair identity";
      s.yahoo_query = AC_L3YahooFxUrl(root);
      s.google_finance_query = "https://www.google.com/finance/quote/" + base + "-" + quote;
      s.marketwatch_query = AC_L3SearchUrl("MarketWatch " + root + " currency");
      s.sec_edgar_query = "Not applicable - FX macro";
      s.finviz_query = AC_L3SearchUrl("Finviz forex " + root);
      s.morningstar_query = AC_L3SearchUrl("Morningstar currency " + root);
      return;
   }

   if(s.asset_class == "Commodities")
   {
      s.fundamental_supported = "Commodity macro";
      s.fundamental_identity_quality = "Commodity identity";
      s.yahoo_query = AC_L3SearchUrl("Yahoo Finance " + root + " commodity");
      s.google_finance_query = AC_L3SearchUrl("Google Finance " + root + " commodity");
      s.marketwatch_query = AC_L3SearchUrl("MarketWatch " + root + " commodity");
      s.sec_edgar_query = "Not applicable - commodity macro";
      s.finviz_query = "Not applicable - commodity macro";
      s.morningstar_query = AC_L3SearchUrl("Morningstar " + root + " commodity");
      return;
   }

   if(s.asset_class == "Crypto")
   {
      s.fundamental_supported = "Crypto asset";
      s.fundamental_identity_quality = "Crypto symbol identity";
      s.yahoo_query = AC_L3SearchUrl("Yahoo Finance " + root + " crypto");
      s.google_finance_query = AC_L3SearchUrl("Google Finance " + root + " crypto");
      s.marketwatch_query = AC_L3SearchUrl("MarketWatch " + root + " crypto");
      s.sec_edgar_query = "Not applicable - crypto asset";
      s.finviz_query = "Not applicable - crypto asset";
      s.morningstar_query = AC_L3SearchUrl("Morningstar " + root + " crypto");
      return;
   }

   if(s.description != "" || s.asset_class == "Equities" || s.asset_class == "Stocks" || StringFind(s.market_group, "Equity") >= 0 || StringFind(s.ranking_group, "Stock") >= 0)
   {
      string identity = (s.description != "" ? s.description : external_symbol);
      s.fundamental_supported = "Equity lookup";
      s.fundamental_identity_quality = "Symbol and description only";
      s.yahoo_query = AC_L3YahooQuoteUrl(external_symbol);
      s.google_finance_query = AC_L3SearchUrl("Google Finance " + external_symbol + " " + identity);
      s.marketwatch_query = AC_L3SearchUrl("MarketWatch " + external_symbol + " " + identity);
      s.sec_edgar_query = AC_L3SearchUrl("SEC EDGAR " + external_symbol + " " + identity);
      s.finviz_query = (StringFind(external_symbol, ".HK") > 0 ? "Not applicable - non-US exchange" : "https://finviz.com/quote.ashx?t=" + external_symbol);
      s.morningstar_query = AC_L3SearchUrl("Morningstar " + external_symbol + " " + identity);
      return;
   }

   if(s.classification_quality == "Bucket Unknown")
   {
      s.fundamental_supported = "Identity ambiguous";
      s.fundamental_identity_quality = "Needs broker or taxonomy identity";
      s.yahoo_query = AC_L3SearchUrl("Yahoo Finance " + root);
      s.google_finance_query = AC_L3SearchUrl("Google Finance " + root);
      s.marketwatch_query = AC_L3SearchUrl("MarketWatch " + root);
      return;
   }
}

#endif