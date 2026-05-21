#ifndef AC_L3_BROKER_METADATA_MQH
#define AC_L3_BROKER_METADATA_MQH

bool AC_L3MetadataValueVisible(const string value)
{
   if(value == "") return false;
   if(value == "Not available") return false;
   if(value == "Undefined") return false;
   if(value == "N/A") return false;
   if(value == "NA") return false;
   return true;
}

string AC_L3StringPropertyStatus(const bool ok, const string value, const int error_code)
{
   if(ok && AC_L3MetadataValueVisible(value)) return "Broker API returned visible value";
   if(ok && value == "") return "Broker API succeeded but broker returned blank";
   if(ok && !AC_L3MetadataValueVisible(value)) return "Broker API returned non-display value: " + value;
   return "Broker API failed. Error " + IntegerToString(error_code);
}

bool AC_L3GetMetadataString(const string symbol,
                            const ENUM_SYMBOL_INFO_STRING prop,
                            string &value,
                            string &status)
{
   value = "";
   ResetLastError();
   bool ok = SymbolInfoString(symbol, prop, value);
   int error_code = ok ? 0 : GetLastError();
   status = AC_L3StringPropertyStatus(ok, value, error_code);
   return ok && AC_L3MetadataValueVisible(value);
}

bool AC_L3BrokerMetadataLooksContradictory(const AC_L3SymbolSpecs &s)
{
   if(s.sector == "Technology" && s.industry == "Consumer Electronics")
   {
      if(StringFind(s.market_group, "Technology") < 0 &&
         StringFind(s.market_group, "Consumer") < 0 &&
         StringFind(s.market_segment, "Technology") < 0 &&
         StringFind(s.market_segment, "Consumer") < 0 &&
         StringFind(s.ranking_group, "Technology") < 0 &&
         StringFind(s.ranking_group, "Consumer") < 0)
         return true;
   }
   return false;
}

void AC_L3LoadBrokerMetadata(AC_L3SymbolSpecs &s)
{
   int value_count = 0;
   string value = "";
   string status = "";

   // ISIN is deliberately not loaded into trader-facing Layer 3 output.
   // The broker/server can repeat or leak stale/default ISIN values across unrelated symbols.
   // Keep authoritative identity and bucket logic in Runtime 2 / workbook export, not ISIN.
   s.isin = "";
   s.isin_status = "Removed from trader-facing metadata";

   if(AC_L3GetMetadataString(s.symbol, SYMBOL_EXCHANGE, value, status)) { s.exchange = value; value_count++; }
   else s.exchange = "";
   s.exchange_status = status;

   if(AC_L3GetMetadataString(s.symbol, SYMBOL_SECTOR_NAME, value, status)) { s.sector = value; value_count++; }
   else s.sector = "";
   s.sector_status = status;

   if(AC_L3GetMetadataString(s.symbol, SYMBOL_INDUSTRY_NAME, value, status)) { s.industry = value; value_count++; }
   else s.industry = "";
   s.industry_status = status;

   if(AC_L3GetMetadataString(s.symbol, SYMBOL_COUNTRY, value, status)) { s.country = value; value_count++; }
   else s.country = "";
   s.country_status = status;

   if(value_count <= 0)
      s.broker_metadata_status = "Hidden - broker returned no displayable advisory metadata";
   else if(AC_L3BrokerMetadataLooksContradictory(s))
      s.broker_metadata_status = "Advisory only - broker metadata may contradict workbook taxonomy";
   else
      s.broker_metadata_status = "Advisory only - broker metadata displayed when non-empty";
}

#endif