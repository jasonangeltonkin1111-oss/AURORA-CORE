#ifndef AC_ACCOUNT_TRUTH_MQH
#define AC_ACCOUNT_TRUTH_MQH

// Runtime 1 owner dispatcher.
// One source owner, split implementation files.
// Board/Dossier/Workbench render Layer 1 truth from this owner only.
// This owner is read-only and never grants trade permission.

#include "AC_L1_Types.mqh"
#include "AC_L1_Format.mqh"
#include "AC_L1_State.mqh"
#include "AC_L1_Scan.mqh"
#include "AC_L1_Maps.mqh"
#define AC_Layer1BoardSection AC_Layer1BoardSection_Base
#include "AC_L1_Render.mqh"
#undef AC_Layer1BoardSection

string AC_Layer1BoardSection()
{
   if(!AC_L1_READY)
      return "\r\nLAYER 1 - ACCOUNT AND PORTFOLIO\r\n----------------------------------------\r\nStatus: Pending\r\n";
   return AC_Layer1BoardSection_Base() + AC_L1PortfolioMapSummary();
}

#endif