#ifndef AC_L3_FUNDAMENTAL_LINKS_MQH
#define AC_L3_FUNDAMENTAL_LINKS_MQH

void AC_L3BuildFundamentalHints(AC_L3SymbolSpecs &s)
{
   string root = AC_L3CleanSymbolRoot(s.symbol);
   s.fundamental_supported = "Unsupported";
   s.fundamental_identity_quality = "Not available";
   s.yahoo_query = "Not available";
   s.google_finance_query = "Not available";
   s.marketwatch_query = "Not available";
   s.sec_edgar_query = "Not available";
   s.finviz_query = "Not available";
   s.morningstar_query = "Not available";
   s.link_truth = "Lookup hints only - not verified";

   if(s.asset_class == "FX" || s.asset_class == "Forex")
   {
      s.fundamental_supported = "FX macro";
      s.fundamental_identity_quality = "Currency pair identity";
      s.yahoo_query = root;
      s.google_finance_query = root;
      s.marketwatch_query = root;
      return;
   }

   if(s.asset_class == "Commodities")
   {
      s.fundamental_supported = "Commodity macro";
      s.fundamental_identity_quality = "Commodity identity";
      s.yahoo_query = root;
      s.google_finance_query = root;
      s.marketwatch_query = root;
      return;
   }

   if(s.asset_class == "Crypto")
   {
      s.fundamental_supported = "Crypto asset";
      s.fundamental_identity_quality = "Crypto symbol identity";
      s.yahoo_query = root;
      s.google_finance_query = root;
      s.marketwatch_query = root;
      return;
   }

   if(s.isin != "" || s.description != "" || s.asset_class == "Equities" || s.asset_class == "Stocks" || StringFind(s.market_group, "Equity") >= 0 || StringFind(s.ranking_group, "Stock") >= 0)
   {
      s.fundamental_supported = "Equity lookup";
      s.fundamental_identity_quality = (s.isin != "" ? "ISIN available" : "Symbol and description only");
      s.yahoo_query = root;
      s.google_finance_query = root;
      s.marketwatch_query = root;
      s.sec_edgar_query = (StringFind(s.isin, "US") == 0 ? s.isin : "Not available");
      s.finviz_query = root;
      s.morningstar_query = root;
      return;
   }

   if(s.classification_quality == "Bucket Unknown")
   {
      s.fundamental_supported = "Identity ambiguous";
      s.fundamental_identity_quality = "Needs broker or taxonomy identity";
      return;
   }
}

#endif