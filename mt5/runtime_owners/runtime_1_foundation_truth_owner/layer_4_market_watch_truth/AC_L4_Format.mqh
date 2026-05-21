#ifndef AC_L4_FORMAT_MQH
#define AC_L4_FORMAT_MQH

string AC_L4BoolText(const bool value)
{
   return value ? "true" : "false";
}

string AC_L4YesNo(const bool value)
{
   return value ? "Yes" : "No";
}

string AC_L4TextOrNA(const string value)
{
   if(value == "") return "Not available";
   return value;
}

string AC_L4NumberText(const double value, const int digits = 6)
{
   return DoubleToString(value, digits);
}

string AC_L4PriceText(const double value, const long digits)
{
   int d = (int)digits;
   if(d < 0) d = 5;
   if(d > 8) d = 8;
   return DoubleToString(value, d);
}

string AC_L4DateTimeText(const datetime value)
{
   if(value <= 0) return "Not available";
   return TimeToString(value, TIME_DATE | TIME_SECONDS);
}

string AC_L4Ratio(const int count, const int total)
{
   return IntegerToString(count) + " / " + IntegerToString(total);
}

string AC_L4PctText(const double value)
{
   return DoubleToString(value, 2) + "%";
}

string AC_L4BpsText(const double value)
{
   return DoubleToString(value, 2) + " BPS";
}

string AC_L4SpreadScore(const double bps, const bool available)
{
   if(!available) return "No Score";
   if(bps <= 2.0) return "Excellent";
   if(bps <= 5.0) return "Good";
   if(bps <= 10.0) return "Usable";
   if(bps <= 25.0) return "Expensive";
   return "Hostile";
}

string AC_L4QuoteQuality(const bool tick_available,
                         const bool bid_ask_valid,
                         const double tick_age_seconds)
{
   if(!tick_available) return "Missing Tick";
   if(!bid_ask_valid) return "Invalid Bid / Ask";
   if(tick_age_seconds <= 10.0) return "Fresh";
   if(tick_age_seconds <= 60.0) return "Aging";
   return "Stale";
}

#endif
