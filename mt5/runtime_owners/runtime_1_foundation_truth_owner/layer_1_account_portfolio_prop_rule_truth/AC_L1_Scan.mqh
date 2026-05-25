#ifndef AC_L1_SCAN_MQH
#define AC_L1_SCAN_MQH

// Forward declaration: render implementation is included after scan in the Runtime 1 dispatcher.
void AC_BuildLayer1Texts();
string AC_L1PortfolioMapSummary();
string AC_L1AccountPortfolioMapsFull();

static int AC_L1_HISTORY_LOOKBACK_DAYS = 90;
static int AC_L1_CLOSED_SCAN_LIMIT = 100;
static int AC_L1_CANCEL_SCAN_LIMIT = 20;
static int AC_L1_HISTORY_SCAN_BUDGET_MS = 350;

#include "AC_L1_HistoryReconstruction.mqh"
#include "AC_L1_OpenPendingScan.mqh"
#include "AC_L1_HistoryScan.mqh"
#include "AC_L1_Refresh.mqh"

#endif