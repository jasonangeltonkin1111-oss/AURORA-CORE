#ifndef AC_SERVER_PATHS_MQH
#define AC_SERVER_PATHS_MQH

string AC_SafePart(const string value)
{
   string safe = value;
   StringReplace(safe, "\\", "_");
   StringReplace(safe, "/", "_");
   StringReplace(safe, ":", "_");
   StringReplace(safe, "*", "_");
   StringReplace(safe, "?", "_");
   StringReplace(safe, "\"", "_");
   StringReplace(safe, "<", "_");
   StringReplace(safe, ">", "_");
   StringReplace(safe, "|", "_");
   StringTrimLeft(safe);
   StringTrimRight(safe);
   return safe == "" ? "unknown" : safe;
}

string AC_ServerFolder()
{
   string server = AccountInfoString(ACCOUNT_SERVER);
   if(server == "") server = "unknown_server";
   return AC_SafePart(server);
}

string AC_AccountFolder()
{
   long login = AccountInfoInteger(ACCOUNT_LOGIN);
   if(login <= 0) return "unknown_account";
   return IntegerToString(login);
}

string AC_RootFolder()
{
   return AC_BASE_FOLDER + "\\" + AC_ServerFolder() + "\\" + AC_AccountFolder();
}

string AC_WorkbenchFolder()
{
   return AC_RootFolder() + "\\" + AC_WORKBENCH_FOLDER;
}

string AC_WorkbenchInternalFolder()
{
   return AC_WorkbenchFolder() + "\\Internal";
}

string AC_WorkbenchManifestsFolder()
{
   return AC_WorkbenchFolder() + "\\Manifests";
}

string AC_WorkbenchStatusFolder()
{
   return AC_WorkbenchFolder() + "\\Status";
}

string AC_WorkbenchDiagnosticsFolder()
{
   return AC_WorkbenchFolder() + "\\Diagnostics";
}

string AC_WorkbenchCacheFolder()
{
   return AC_WorkbenchFolder() + "\\Cache";
}

string AC_WorkbenchFileIoStatusFolder()
{
   return AC_WorkbenchStatusFolder() + "\\FileIO";
}

string AC_WorkbenchFileIoAuditFolder()
{
   return AC_WorkbenchDiagnosticsFolder() + "\\FileIO";
}

string AC_Runtime0Folder()
{
   return AC_WorkbenchInternalFolder() + "\\Runtime0";
}

string AC_Runtime0ManifestPath()
{
   return AC_WorkbenchManifestsFolder() + "\\Runtime0_Identity.manifest";
}

string AC_HeartbeatPath()
{
   return AC_WorkbenchStatusFolder() + "\\Heartbeat.txt";
}

string AC_GovernancePath()
{
   return AC_WorkbenchStatusFolder() + "\\Governance.txt";
}

string AC_ExternalWorkerFolder()
{
   return AC_RootFolder() + "\\" + AC_EXTERNAL_WORKER_FOLDER;
}

string AC_ExternalWorkerControlFolder()
{
   return AC_ExternalWorkerFolder() + "\\" + AC_EXTERNAL_WORKER_CONTROL_FOLDER;
}

string AC_ExternalWorkerInboxFolder()
{
   return AC_ExternalWorkerFolder() + "\\" + AC_EXTERNAL_WORKER_INBOX_FOLDER;
}

string AC_ExternalWorkerOutboxFolder()
{
   return AC_ExternalWorkerFolder() + "\\" + AC_EXTERNAL_WORKER_OUTBOX_FOLDER;
}

string AC_ExternalWorkerStatusFolder()
{
   return AC_ExternalWorkerFolder() + "\\" + AC_EXTERNAL_WORKER_STATUS_FOLDER;
}

string AC_ExternalWorkerLogsFolder()
{
   return AC_ExternalWorkerFolder() + "\\" + AC_EXTERNAL_WORKER_LOGS_FOLDER;
}

string AC_ExternalWorkerQuarantineFolder()
{
   return AC_ExternalWorkerFolder() + "\\" + AC_EXTERNAL_WORKER_QUARANTINE_FOLDER;
}

string AC_ExternalWorkerJobPath()
{
   return AC_ExternalWorkerInboxFolder() + "\\job_latest.json";
}

string AC_ExternalWorkerResultPath()
{
   return AC_ExternalWorkerOutboxFolder() + "\\result_latest.txt";
}

string AC_ExternalWorkerResultManifestPath()
{
   return AC_ExternalWorkerOutboxFolder() + "\\result_latest.manifest";
}

string AC_ExternalWorkerHeartbeatPath()
{
   return AC_ExternalWorkerStatusFolder() + "\\worker_heartbeat.txt";
}

string AC_ExternalWorkerInstallStatusPath()
{
   return AC_ExternalWorkerStatusFolder() + "\\worker_install_status.txt";
}

string AC_ExternalWorkerLaunchStatusPath()
{
   return AC_ExternalWorkerStatusFolder() + "\\worker_launch_status.txt";
}

string AC_ExternalWorkerSnapshotIndexPath()
{
   return AC_ExternalWorkerOutboxFolder() + "\\render_index_snapshot.txt";
}

string AC_ExternalWorkerSnapshotCsvPath()
{
   return AC_ExternalWorkerOutboxFolder() + "\\render_index_snapshot.csv";
}

string AC_ExternalWorkerExePath()
{
   return AC_ExternalWorkerControlFolder() + "\\" + AC_EXTERNAL_WORKER_EXE_FILE;
}

string AC_SharedRootFolder()
{
   string server = AccountInfoString(ACCOUNT_SERVER);
   if(server == "") server = "unknown_server";
   return AC_BASE_FOLDER + "\\" + AC_SafePart(server);
}

string AC_SharedMarketDataFolder()
{
   return AC_SharedRootFolder() + "\\Shared Market Data";
}

string AC_SharedOhlcStoreFolder()
{
   return AC_SharedMarketDataFolder() + "\\OHLC Store";
}

string AC_SharedOhlcSymbolsFolder()
{
   return AC_SharedOhlcStoreFolder() + "\\Symbols";
}

string AC_SharedOhlcWorkbenchFolder()
{
   return AC_WorkbenchFolder() + "\\Shared OHLC Raw Storage";
}

string AC_SharedOhlcStatusPath()
{
   return AC_SharedOhlcWorkbenchFolder() + "\\shared_ohlc_status.txt";
}

string AC_SharedOhlcManifestPath()
{
   return AC_SharedOhlcWorkbenchFolder() + "\\shared_ohlc_manifest.txt";
}

string AC_SharedOhlcSymbolTfPath(const string symbol, const string timeframe)
{
   return AC_SharedOhlcSymbolsFolder() + "\\" + AC_SafePart(symbol) + "\\" + AC_SafePart(timeframe) + ".csv";
}

string AC_DossiersFolder()
{
   return AC_RootFolder() + "\\" + AC_DOSSIERS_FOLDER;
}

string AC_DossiersOpenFolder()
{
   return AC_DossiersFolder() + "\\Open";
}

string AC_DossiersClosedFolder()
{
   return AC_DossiersFolder() + "\\Closed";
}

string AC_DossiersUnknownFolder()
{
   return AC_DossiersFolder() + "\\Unknown";
}

string AC_SelectionDeskFolder()
{
   return AC_RootFolder() + "\\" + AC_SELECTION_FOLDER;
}

string AC_SelectionGroupsFolder()
{
   return AC_SelectionDeskFolder() + "\\" + AC_SELECTION_GROUPS_FOLDER;
}

string AC_SelectionGlobalFolder()
{
   return AC_SelectionDeskFolder() + "\\" + AC_SELECTION_GLOBAL_FOLDER;
}

string AC_SelectionCompatibilityGlobalFolder()
{
   return AC_SelectionDeskFolder() + "\\01_Global";
}

string AC_SelectionCanonicalGlobalFolder()
{
   // Legacy alias retained for older includes. 01_Global is a compatibility/helper route, not the stable Global authority.
   return AC_SelectionCompatibilityGlobalFolder();
}

string AC_SelectionGlobalTop10Folder()
{
   return AC_SelectionCompatibilityGlobalFolder() + "\\Top_10";
}

string AC_SelectionGlobalDeepEvidenceFolder()
{
   return AC_SelectionCompatibilityGlobalFolder() + "\\Deep_Evidence";
}

string AC_SelectionAssetClassesFolder()
{
   return AC_SelectionDeskFolder() + "\\02_Asset_Classes";
}

string AC_SelectionSystemIndexesFolder()
{
   return AC_SelectionDeskFolder() + "\\90_System_Indexes";
}

string AC_SelectionLayerSummariesFolder()
{
   return AC_SelectionDeskFolder() + "\\91_Layer_Summaries";
}

string AC_SelectionReadMePath()
{
   return AC_SelectionDeskFolder() + "\\00_Read_Me.txt";
}

string AC_SelectionCanonicalIndexPath()
{
   return AC_SelectionDeskFolder() + "\\00_Selection_Index.txt";
}

string AC_SelectionDeskStatusPath()
{
   return AC_SelectionSystemIndexesFolder() + "\\00_Selection_Desk_Status.txt";
}

string AC_SelectionLayerStatusPath()
{
   return AC_SelectionLayerSummariesFolder() + "\\00_Selection_Layer_Status.txt";
}

string AC_SelectionGlobalTop10TextPath()
{
   return AC_SelectionGlobalTop10Folder() + "\\00_Global_Top_10.txt";
}

string AC_SelectionGlobalTop10CsvPath()
{
   return AC_SelectionGlobalTop10Folder() + "\\00_Global_Top_10.csv";
}

string AC_SelectionGlobalTop10CopyStatusPath()
{
   return AC_SelectionGlobalTop10Folder() + "\\00_Global_Top_10_Copy_Status.txt";
}

string AC_SelectionAssetClassTop5StatusPath()
{
   return AC_SelectionAssetClassesFolder() + "\\00_Asset_Class_Top5_Status.txt";
}

string AC_SelectionAssetClassTop5IndexPath()
{
   return AC_SelectionAssetClassesFolder() + "\\00_Asset_Class_Top5_Index.txt";
}

string AC_SelectionShallowGroupTop5StatusPath()
{
   return AC_SelectionAssetClassesFolder() + "\\00_Shallow_Group_Top5_Status.txt";
}

string AC_SelectionLegacyGlobalStatusPath()
{
   return AC_SelectionGlobalFolder() + "\\00_Global_Surface_Status.txt";
}

string AC_SelectionLegacyGroupsStatusPath()
{
   return AC_SelectionGroupsFolder() + "\\00_Group_Surface_Status.txt";
}

string AC_SelectionIndexPath()
{
   return AC_SelectionDeskFolder() + "\\" + AC_SELECTION_INDEX_FILE;
}

string AC_TradeJournalImportFolder()
{
   return AC_RootFolder() + "\\" + AC_TRADE_JOURNAL_IMPORT_FOLDER;
}

string AC_TradeJournalInboxFolder()
{
   return AC_TradeJournalImportFolder() + "\\" + AC_TRADE_JOURNAL_INBOX_FOLDER;
}

string AC_TradeJournalAcceptedFolder()
{
   return AC_TradeJournalImportFolder() + "\\" + AC_TRADE_JOURNAL_ACCEPTED_FOLDER;
}

string AC_TradeJournalRejectedFolder()
{
   return AC_TradeJournalImportFolder() + "\\" + AC_TRADE_JOURNAL_REJECTED_FOLDER;
}

string AC_TradeJournalOrphanedFolder()
{
   return AC_TradeJournalImportFolder() + "\\" + AC_TRADE_JOURNAL_ORPHANED_FOLDER;
}

string AC_TradeHistoryFolder()
{
   return AC_RootFolder() + "\\" + AC_TRADE_HISTORY_FOLDER;
}

string AC_TradeHistoryBeforeAuroraFolder()
{
   return AC_TradeHistoryFolder() + "\\" + AC_TRADE_HISTORY_BEFORE_AURORA_FOLDER;
}

string AC_TradeHistoryAuroraCapturedFolder()
{
   return AC_TradeHistoryFolder() + "\\" + AC_TRADE_HISTORY_AURORA_CAPTURED_FOLDER;
}

string AC_MarketBoardPath()
{
   return AC_RootFolder() + "\\" + AC_MARKET_BOARD_FILE;
}

string AC_DossierOpenSymbolPath(const string symbol)
{
   return AC_DossiersOpenFolder() + "\\" + AC_SafePart(symbol) + ".txt";
}

string AC_DossierClosedSymbolPath(const string symbol)
{
   return AC_DossiersClosedFolder() + "\\" + AC_SafePart(symbol) + ".txt";
}

string AC_DossierUnknownSymbolPath(const string symbol)
{
   return AC_DossiersUnknownFolder() + "\\" + AC_SafePart(symbol) + ".txt";
}

#endif
