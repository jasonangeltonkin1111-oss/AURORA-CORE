#ifndef AC_SHARED_OHLC_CODEC_MQH
#define AC_SHARED_OHLC_CODEC_MQH

// Lossless compact raw row codec for Shared OHLC Raw Storage.
// This is storage normalization only. It does not calculate market features.

long AC_SharedOhlcPriceToPoints(const string symbol, const double price)
{
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
   if(point <= 0.0)
      return 0;
   return (long)MathRound(price / point);
}

string AC_SharedOhlcClosedHeader(const string symbol, const string timeframe_label)
{
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

   string text = "#schema=" + AC_SHARED_OHLC_SCHEMA_VERSION + "\r\n";
   text += "#owner=" + AC_SHARED_OHLC_OWNER_NAME + "\r\n";
   text += "#authority=" + AC_SHARED_OHLC_AUTHORITY + "\r\n";
   text += "#symbol=" + symbol + "\r\n";
   text += "#timeframe=" + timeframe_label + "\r\n";
   text += "#digits=" + IntegerToString(digits) + "\r\n";
   text += "#point=" + DoubleToString(point, digits + 2) + "\r\n";
   text += "#price_encoding=integer_points_price_divided_by_symbol_point\r\n";
   text += "#current_bar_policy=excluded_from_closed_file_current_bar_written_to_current_sidecar\r\n";
   text += "bar_time,open_i,high_i,low_i,close_i,tick_volume,spread,real_volume\r\n";
   return text;
}

string AC_SharedOhlcRateRow(const string symbol, const MqlRates &rate)
{
   string row = IntegerToString((long)rate.time);
   row += "," + IntegerToString(AC_SharedOhlcPriceToPoints(symbol, rate.open));
   row += "," + IntegerToString(AC_SharedOhlcPriceToPoints(symbol, rate.high));
   row += "," + IntegerToString(AC_SharedOhlcPriceToPoints(symbol, rate.low));
   row += "," + IntegerToString(AC_SharedOhlcPriceToPoints(symbol, rate.close));
   row += "," + IntegerToString((long)rate.tick_volume);
   row += "," + IntegerToString(rate.spread);
   row += "," + IntegerToString((long)rate.real_volume);
   return row;
}

string AC_SharedOhlcRatesToClosedCsv(const string symbol,
                                     const string timeframe_label,
                                     const MqlRates &rates[],
                                     const int copied)
{
   string text = AC_SharedOhlcClosedHeader(symbol, timeframe_label);
   for(int i = 0; i < copied; i++)
      text += AC_SharedOhlcRateRow(symbol, rates[i]) + "\r\n";
   return text;
}

string AC_SharedOhlcCurrentCsv(const string symbol,
                               const string timeframe_label,
                               const MqlRates &rate)
{
   string text = AC_SharedOhlcClosedHeader(symbol, timeframe_label);
   text += AC_SharedOhlcRateRow(symbol, rate) + "\r\n";
   return text;
}

#endif
