#ifndef AC_L1_REFRESH_MQH
#define AC_L1_REFRESH_MQH

void AC_L1RemoveLegacyBracketSectionId(const string legacy_id)
{
   string core = "[section_id=" + legacy_id + "]";
   StringReplace(AC_L1_ACCOUNT_STATUS_TEXT, core + "\r\n", "");
   StringReplace(AC_L1_ACCOUNT_STATUS_TEXT, core + "\n", "");
   StringReplace(AC_L1_ACCOUNT_STATUS_TEXT, core, "");
}

void AC_L1NormalizeBaseAccountStatusSections()
{
   // Base Account Status section ids are now rendered directly by AC_L1_Render.mqh.
   // This function only removes legacy bracket-style tags from older local/runtime copies.
   // It must not add duplicate ids, recalculate account truth, move content, or grant permission.
   if(AC_L1_ACCOUNT_STATUS_TEXT == "")
      return;

   AC_L1RemoveLegacyBracketSectionId("account_summary");
   AC_L1RemoveLegacyBracketSectionId("results");
   AC_L1RemoveLegacyBracketSectionId("open_positions_full");
   AC_L1RemoveLegacyBracketSectionId("pending_orders_full");
   AC_L1RemoveLegacyBracketSectionId("closed_trade_history_selected_detail");
   AC_L1RemoveLegacyBracketSectionId("cancel_reject_expire_selected_detail");
   AC_L1RemoveLegacyBracketSectionId("symbol_performance");
   AC_L1RemoveLegacyBracketSectionId("daily_performance");
   AC_L1RemoveLegacyBracketSectionId("direction_summary");
}

string AC_L1PropRuleTruthBlock()
{
   string text = "\r\nPROP RULE TRUTH\r\n";
   text += "----------------------------------------\r\n";
   text += "section_id:             L1_PROP_RULE_TRUTH\r\n";
   text += "Prop Rule Profile:      NOT_LOADED / UNKNOWN\r\n";
   text += "Prop Rule Safety:       UNKNOWN - live/funded permission blocked until firm rules are loaded and verified\r\n";
   text += "Policy Source:          Jason local planning guard only; not broker or prop-firm rule proof\r\n";
   text += "Trade Permission:       FALSE\r\n";
   return text;
}

void AC_L1ResetLiveSnapshotRows()
{
   ArrayResize(AC_L1_POSITIONS, 0);
   ArrayResize(AC_L1_PENDING, 0);

   for(int i = 0; i < ArraySize(AC_L1_SYMBOL_STATS); i++)
   {
      AC_L1_SYMBOL_STATS[i].open_count = 0;
      AC_L1_SYMBOL_STATS[i].pending_count = 0;
   }
}

void AC_L1AppendPortfolioMaps()
{
   // Account Status is a GPT-overseer briefing pack first, then the normal account report,
   // then grouped evidence blocks. Do not move this content onto Market Board.
   AC_L1_ACCOUNT_STATUS_TEXT = AC_L1OverseerBriefPack() + AC_L1AccountStatusSectionIndex() + AC_L1PropRuleTruthBlock() + AC_L1_ACCOUNT_STATUS_TEXT;

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
   AC_L1_ACCOUNT_STATUS_TEXT += AC_L1TradeClusterMap();
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

   // Final safety strip in case an older local renderer or copied Include injected legacy bracket ids.
   AC_L1NormalizeBaseAccountStatusSections();

   AC_L1_WORKBENCH_SECTION += "account_status_report_order=overseer_index_prop_rule_base_live_portfolio_cluster_recovery_risk_cost_quality\r\n";
   AC_L1_WORKBENCH_SECTION += "prop_rule_profile_status=not_loaded_unknown\r\n";
   AC_L1_WORKBENCH_SECTION += "prop_rule_safety=unknown_live_funded_permission_blocked\r\n";
   AC_L1_WORKBENCH_SECTION += "prop_rule_policy_source=jason_local_planning_guard_not_firm_rule_proof\r\n";
   AC_L1_WORKBENCH_SECTION += "overseer_brief=enabled_account_status_prefix\r\n";
   AC_L1_WORKBENCH_SECTION += "next_decision_hints=enabled_account_status_prefix\r\n";
   AC_L1_WORKBENCH_SECTION += "section_index=enabled_account_status_prefix\r\n";
   AC_L1_WORKBENCH_SECTION += "base_account_status_section_ids=enabled\r\n";
   AC_L1_WORKBENCH_SECTION += "legacy_bracket_section_ids=stripped\r\n";
   AC_L1_WORKBENCH_SECTION += "live_exposure=enabled_board_and_account_status\r\n";
   AC_L1_WORKBENCH_SECTION += "live_risk_at_sl=enabled_estimated_account_status_and_board_summary\r\n";
   AC_L1_WORKBENCH_SECTION += "live_exposure_maps=enabled_account_status_symbol_and_asset\r\n";
   AC_L1_WORKBENCH_SECTION += "portfolio_concentration=enabled_account_status_only\r\n";
   AC_L1_WORKBENCH_SECTION += "asset_risk_heat_maps=enabled_account_status_only\r\n";
   AC_L1_WORKBENCH_SECTION += "direction_risk_maps=enabled_account_status_only\r\n";
   AC_L1_WORKBENCH_SECTION += "time_window_risk_maps=enabled_account_status_only\r\n";
   AC_L1_WORKBENCH_SECTION += "holding_time_maps=enabled_account_status_only\r\n";
   AC_L1_WORKBENCH_SECTION += "holding_time_risk_maps=enabled_account_status_only\r\n";
   AC_L1_WORKBENCH_SECTION += "trade_cluster_maps=enabled_account_status_only\r\n";
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

void AC_L1AppendTimingProof()
{
   AC_L1_WORKBENCH_SECTION += "render_duration_ms=" + IntegerToString((int)AC_L1_RENDER_DURATION_MS) + "\r\n";
   AC_L1_WORKBENCH_SECTION += "total_refresh_duration_ms=" + IntegerToString((int)AC_L1_TOTAL_REFRESH_DURATION_MS) + "\r\n";
   AC_L1_WORKBENCH_SECTION += "timing_note=scan_duration_excludes_render_maps_and_file_write;total_refresh_excludes_publication_fileio\r\n";
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

   uint render_start_ms = GetTickCount();
   AC_BuildLayer1Texts();
   AC_L1NormalizeBaseAccountStatusSections();
   AC_L1AppendPortfolioMaps();
   AC_L1_RENDER_DURATION_MS = GetTickCount() - render_start_ms;
   AC_L1_TOTAL_REFRESH_DURATION_MS = GetTickCount() - AC_L1_SCAN_STARTED_MS;
   AC_L1AppendTimingProof();
}

void AC_RefreshLayer1SnapshotOnly()
{
   uint snapshot_start_ms = GetTickCount();
   AC_L1ResetLiveSnapshotRows();
   AC_L1RefreshAccountSnapshot();
   AC_L1ScanPositions();
   AC_L1ScanPendingOrders();
   AC_L1_TOTAL_REFRESH_DURATION_MS = GetTickCount() - snapshot_start_ms;
}

#endif
