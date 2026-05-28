#ifndef AC_L3_API_GETTERS_MQH
#define AC_L3_API_GETTERS_MQH

bool AC_L3GetInteger(const string symbol, const ENUM_SYMBOL_INFO_INTEGER prop, long &value, const string field, AC_L3SymbolSpecs &s)
{
   ResetLastError();
   if(SymbolInfoInteger(symbol, prop, value))
   {
      AC_L3_SYMBOLINFO_INTEGER_SUCCESS++;
      s.required_fields_ok++;
      return true;
   }
   AC_L3_SYMBOLINFO_INTEGER_FAILURE++;
   s.required_fields_failed++;
   s.missing_required_fields += field + "; ";
   return false;
}

bool AC_L3GetDouble(const string symbol, const ENUM_SYMBOL_INFO_DOUBLE prop, double &value, const string field, AC_L3SymbolSpecs &s)
{
   ResetLastError();
   if(SymbolInfoDouble(symbol, prop, value))
   {
      AC_L3_SYMBOLINFO_DOUBLE_SUCCESS++;
      s.required_fields_ok++;
      return true;
   }
   AC_L3_SYMBOLINFO_DOUBLE_FAILURE++;
   s.required_fields_failed++;
   s.missing_required_fields += field + "; ";
   return false;
}

bool AC_L3GetOptionalInteger(const string symbol, const ENUM_SYMBOL_INFO_INTEGER prop, long &value)
{
   ResetLastError();
   return SymbolInfoInteger(symbol, prop, value);
}

bool AC_L3GetString(const string symbol, const ENUM_SYMBOL_INFO_STRING prop, string &value, const string field)
{
   ResetLastError();
   if(SymbolInfoString(symbol, prop, value))
   {
      AC_L3_SYMBOLINFO_STRING_SUCCESS++;
      return true;
   }
   AC_L3_SYMBOLINFO_STRING_FAILURE++;
   value = "";
   return false;
}

#endif
