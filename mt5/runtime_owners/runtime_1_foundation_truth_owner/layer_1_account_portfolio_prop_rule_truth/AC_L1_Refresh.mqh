#ifndef AC_L1_REFRESH_MQH
#define AC_L1_REFRESH_MQH
void AC_L1AppendPortfolioMaps()
{
   // Account Status is a GPT-overseer briefing pack first, then the normal account report,
   // then grouped evidence blocks. Do not move this content onto Market Board.
   AC_L1_ACCOUNT_STATUS_TEXT = AC_L1OverseerBriefPack() + AC_L1AccountStatusSectionIndex() + AC_L1_ACCOUNT_STATUS_TEXT;

   // Live/open-pending evidence first after the base report because it can change fastest.
   AC_L1_ACCOUNT_STATUS_TEXT += AC_L1OpenPendingLiveMap();
   AC_L1_ACCOUNT_STATUS_TEXT += AC_L1OpenPendingRiskReadinessMap();
   AC_L1_ACCOUNT_STATUS_TEXT += AC_L1OpenPendingSymbolExposureMap();
   AC_L1_ACCOUNT_STATUS_TEXT += AC_L1OpenPendingAssetExposureMap();

   // Selected-history portfolio shape and leak maps.
   AC_L1_ACCOUNT_STATUS_TEXT += AC_L1AccountPortfolioMapsFull();
   AC_L1_ACCOUNT_STATUS_TEXT += AC_L1PortfolioConcentrationMap();
   AC_L1_ACCOUNT_STATUS_TEXT += AC_L1AssetRiskHeatMapV2();
   AC_L1_ACCOUNT_STATUS_TEXT += AC_L1DirectionRiskMap();
   AC_L1_ACCOUNT_STATUS_TEXT += AC_L1TimeWindowRiskMapV2();
   AC_L1_ACCOUNT_STATUS_TEXT += AC_L1HoldingTimeRiskMapV2();
   AC_L1_ACCOUNT_STATUS_TEXT += AC_L1CurrencyResultRiskMap();

   // Cluster, recovery, and sequence damage.
   AC_L1_ACCOUNT_STATUS_TEXT += AC_L1TradeClusterV2Map();
   AC_L1_ACCOUNT_STATUS_TEXT += AC_L1EquityDrawdownRecoveryMap();
   AC_L1_ACCOUNT_STATUS_TEXT += AC_L1RecoveryDamageMapsFull();

   // Money-risk, R-multiple, and risk-efficiency proof spine.
   AC_L1_ACCOUNT_STATUS_TEXT += AC_L1ClosedMoneyRiskReadinessMap();
   AC_L1_ACCOUNT_STATUS_TEXT += AC_L1RMultipleMapsFull();
   AC_L1_ACCOUNT_STATUS_TEXT += AC_L1RiskEfficiencyMapsFull();
   AC_L1_ACCOUNT_STATUS_TEXT += AC_L1RReadinessMap();

   // Cost, tag, and data-quality proof last before raw/history detail from base renderer.
   AC_L1_ACCOUNT_STATUS_TEXT += AC_L1CostAndTagMapsFull();
   AC_L1_ACCOUNT_STATUS_TEXT += AC_L1DataQualityLedger();

   AC_L1_WORKBENCH_SECTION += "account_status_report_order=overseer_index_base_live_portfolio_cluster_recovery_risk_cost_quality\r\n";
   AC_L1_WORKBENCH_SECTION += "overseer_brief=enabled_account_status_prefix\r\n";
   AC_L1_WORKBENCH_SECTION += "next_decision_hints=enabled_account_status_prefix\r\n";
   AC_L1_WORKBENCH_SECTION += "section_index=enabled_account_status_prefix\r\n";
   AC_L1_WORKBENCH_SECTION += "live_exposure=enabled_board_and_account_status\r\n";
   AC_L1_WORKBENCH_SECTION += "live_risk_at_sl=enabled_estimated_account_status_and_board_summary\r\n";
   AC_L1_WORKBENCH_SECTION += "live_exposure_maps=enabled_account_status_symbol_and_asset\r\n";
   AC_L1_WORKBENCH_SECTION += "portfolio_concentration=enabled_account_status_only\r\n";
   AC_L1_WORKBENCH_SECTION += "asset_risk_heat_maps=enabled_account_status_only\r\n";
   AC_L1_WORKBENCH_SECTION += "direction_risk_maps=enabled_account_status_only\r\n";
   AC_L1_WORKBENCH_SECTION += "time_window_risk_maps=enabled_account_status_only\r\n";
   AC_L1_WORKBENCH_SECTION += "holding_time_risk_maps=enabled_account_status_only\r\n";
   AC_L1_WORKBENCH_SECTION += "cluster_v2_maps=enabled_account_status_only\r\n";
   AC_L1_WORKBENCH_SECTION += "currency_risk_maps=enabled_account_status_only\r\n";
   AC_L1_WORKBENCH_SECTION += "recovery_damage_maps=enabled_account_status_only\r\n";
   AC_L1_WORKBENCH_SECTION += "setup_tag_readiness=enabled_account_status_only\r\n";
   AC_L1_WORKBENCH_SECTION += "cost_tag_maps=enabled_account_status_only\r\n";
   AC_L1_WORKBENCH_SECTION += "data_quality_ledger=enabled_account_status_only\r\n";
   AC_L1_WORKBENCH_SECTION += "equity_drawdown_map=enabled_account_status_only\r\n";
   AC_L1_WORKBENCH_SECTION += "money_risk_readiness=enabled_account_status_only\r\n";
   AC_L1_WORKBENCH_SECTION += "r_multiple_maps=enabled_account_status_only\r\n";
   AC_L1_WORKBENCH_SECTION += "risk_efficiency_maps=enabled_account_status_only\r\n";
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
   ArrayResize(AC_L1_POSITIONS, 0);
   AC_L1RefreshAccountSnapshot();
   AC_L1ScanPositions();
   AC_L1ScanPendingOrders();
}

#endif