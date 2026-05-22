#ifndef AC_L1_REFRESH_MQH
#define AC_L1_REFRESH_MQH
void AC_L1AppendPortfolioMaps()
{
   AC_L1_BOARD_SECTION += AC_L1PortfolioMapSummary();
   AC_L1_ACCOUNT_STATUS_TEXT += AC_L1AccountPortfolioMapsFull();
   AC_L1_ACCOUNT_STATUS_TEXT += AC_L1RReadinessMap();
   AC_L1_WORKBENCH_SECTION += "portfolio_maps=enabled_summary_board_full_account_status\r\n";
   AC_L1_WORKBENCH_SECTION += "r_readiness=enabled_account_status_only\r\n";
}

void AC_RefreshLayer1AccountTruth()
{
   AC_L1Reset();
   AC_L1RefreshAccountSnapshot();
   AC_L1ScanPositions();
   AC_L1ScanPendingOrders();
   AC_L1ScanHistory();
   AC_L1FinalizeStats();
   if(AC_L1_SCAN_STATUS == "scanning") AC_L1_SCAN_STATUS = "complete";
   AC_L1_SCAN_DURATION_MS = GetTickCount() - AC_L1_SCAN_STARTED_MS;
   AC_L1_READY = true;
   AC_BuildLayer1Texts();
   AC_L1AppendPortfolioMaps();
}

void AC_RefreshLayer1SnapshotOnly()
{
   AC_L1RefreshAccountSnapshot();
}

#endif