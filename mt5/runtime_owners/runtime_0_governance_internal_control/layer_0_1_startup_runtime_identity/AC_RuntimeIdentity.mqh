#ifndef AC_RUNTIME_IDENTITY_MQH
#define AC_RUNTIME_IDENTITY_MQH

// Dependencies are included by mt5/AuroraCore.mq5 using root includes.
// This module intentionally avoids nested cross-owner includes to prevent MQL5 include-path drift.

string AC_NowText()
{
   return TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS);
}

string AC_RuntimeIdentityText()
{
   string text = "";
   text += "system_name=" + AC_SYSTEM_NAME + "\r\n";
   text += "runtime_owner=" + AC_RUNTIME0_OWNER + "\r\n";
   text += "build_phase=" + AC_BUILD_PHASE + "\r\n";
   text += "generated_at=" + AC_NowText() + "\r\n";
   text += "route_root=" + AC_RootFolder() + "\r\n";
   return text;
}

#endif
