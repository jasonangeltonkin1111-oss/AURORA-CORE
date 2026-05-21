#ifndef AC_L3_BROKER_METADATA_MQH
#define AC_L3_BROKER_METADATA_MQH

string AC_L3StringPropertyStatus(const bool ok, const string value, const int error_code)
{
   if(ok && value != "") return "Broker API returned value";
   if(ok && value == "") return "Broker API succeeded but broker returned blank";
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
   return ok && value != "";
}

void AC_L3LoadBrokerMetadata(AC_L3SymbolSpecs &s)
{
   int value_count = 0;
   string value = "";
   string status = "";

   if(AC_L3GetMetadataString(s.symbol, SYMBOL_ISIN, value, status)) { s.isin = value; value_count++; }
   else s.isin = "Not available";
   s.isin_status = status;

   if(AC_L3GetMetadataString(s.symbol, SYMBOL_EXCHANGE, value, status)) { s.exchange = value; value_count++; }
   else s.exchange = "Not available";
   s.exchange_status = status;

   if(AC_L3GetMetadataString(s.symbol, SYMBOL_SECTOR_NAME, value, status)) { s.sector = value; value_count++; }
   else s.sector = "Not available";
   s.sector_status = status;

   if(AC_L3GetMetadataString(s.symbol, SYMBOL_INDUSTRY_NAME, value, status)) { s.industry = value; value_count++; }
   else s.industry = "Not available";
   s.industry_status = status;

   if(AC_L3GetMetadataString(s.symbol, SYMBOL_COUNTRY, value, status)) { s.country = value; value_count++; }
   else s.country = "Not available";
   s.country_status = status;

   if(value_count >= 5) s.broker_metadata_status = "Complete from broker symbol properties";
   else if(value_count > 0) s.broker_metadata_status = "Partial from broker symbol properties";
   else s.broker_metadata_status = "Unavailable from broker symbol properties";
}

#endif