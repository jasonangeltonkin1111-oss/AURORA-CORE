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
string AC_L1ClusterKey(const AC_L1ClosedTradeRow &row);
#include "AC_L1_Maps.mqh"
#include "AC_L1_RReadiness.mqh"
#include "AC_L1_LiveExposure.mqh"
#include "AC_L1_LiveExposureMaps.mqh"
#include "AC_L1_CostTagMaps.mqh"
#define AC_Layer1BoardSection AC_Layer1BoardSection_Base
#define AC_AccountTruthStatusRow AC_AccountTruthStatusRow_Base
#include "AC_L1_Render.mqh"
#undef AC_Layer1BoardSection
#undef AC_AccountTruthStatusRow

string AC_Layer1BoardSection()
{
   if(!AC_L1_READY)
      return "\r\nLAYER 1 - ACCOUNT AND PORTFOLIO\r\n----------------------------------------\r\nStatus: Pending\r\n";
   return AC_Layer1BoardSection_Base() + AC_L1OpenPendingBoardSummary() + AC_L1PortfolioMapSummary();
}

string AC_AccountTruthStatusRow(const AC_WriteResult &account_write)
{
   return AC_AccountTruthStatusRow_Base(account_write) + "|portfolio_maps=enabled|portfolio_map_scope=summary_board_full_account_status|r_readiness=enabled|live_exposure=enabled|live_exposure_maps=enabled|cost_tag_maps=enabled";
}

#endif