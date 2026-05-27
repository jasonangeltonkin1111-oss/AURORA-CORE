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

string AC_SanitizePathPart(const string value)
{
   return AC_SafePart(value);
}

int AC_CommonFlag()
{
   return AC_USE_COMMON_FILES ? FILE_COMMON : 0;
}

int AC_FileFlags()
{
   return FILE_TXT | FILE_ANSI | AC_CommonFlag();
}

string AC_ServerFolder()
{
   string server = AccountInfoString(ACCOUNT_SERVER);
   if(server == "") server = "unknown_server";
   return AC_SafePart(server);
}

string AC_ServerNameForRoute()
{
   return AC_ServerFolder();
}

string AC_AccountFolder()
{
   long login = AccountInfoInteger(ACCOUNT_LOGIN);
   if(login <= 0) return "unknown_account";
   return IntegerToString(login);
}

string AC_AccountForRoute()
{
   return AC_AccountFolder();
}

string AC_RootFolder()
{
   return AC_BASE_FOLDER + "\\" + AC_ServerFolder() + "\\" + AC_AccountFolder();
}

string AC_SharedRootFolder()
{
   return AC_BASE_FOLDER + "\\" + AC_ServerFolder();
}

bool AC_EnsureFolderPath(const string folder_path, string &detail)
{
   if(folder_path == "")
   {
      detail = "folder_path_empty";
      return false;
   }

   int common_flag = AC_CommonFlag();
   if(FileIsExist(folder_path, common_flag))
   {
      detail = "folder_exists";
      return true;
   }

   ResetLastError();
   bool created = FolderCreate(folder_path, common_flag);
   int error_code = GetLastError();
   bool exists_after = FileIsExist(folder_path, common_flag);
   if(created || exists_after)
   {
      detail = created ? "folder_created" : "folder_exists_after_create";
      return true;
   }

   detail = "folder_create_failed_error_" + IntegerToString(error_code);
   return false;
}

string AC_PlaceholderPath(const string folder_path)
{
   return folder_path + "\\__aurora_placeholder.txt";
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

string AC_MicroLogPath()
{
   return AC_WorkbenchDiagnosticsFolder() + "\\MicroLog.txt";
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

string AC_SharedExternalWorkerFolder()
{
   return AC_SharedRootFolder() + "\\" + AC_EXTERNAL_WORKER_FOLDER;
}

string AC_SharedExternalWorkerPackageFolder()
{
   return AC_SharedExternalWorkerFolder() + "\\AuroraWorker";
}

string AC_SharedExternalWorkerStatusFolder()
{
   return AC_SharedExternalWorkerFolder() + "\\" + AC_EXTERNAL_WORKER_STATUS_FOLDER;
}

string AC_SharedExternalWorkerInstallStatusPath()
{
   return AC_SharedExternalWorkerStatusFolder() + "\\shared_worker_install_status.txt";
}

string AC_SharedExternalWorkerStatusPath()
{
   return AC_SharedExternalWorkerStatusFolder() + "\\shared_worker_status.txt";
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

string AC_ExternalWorkerProcessStatusPath()
{
   return AC_ExternalWorkerStatusFolder() + "\\worker_process_status.txt";
}

string AC_ExternalWorkerRequiredPath()
{
   return AC_ExternalWorkerStatusFolder() + "\\worker_required.txt";
}

string AC_ExternalWorkerSnapshotPath()
{
   return AC_ExternalWorkerInboxFolder() + "\\snapshot_latest.txt";
}

string AC_ExternalWorkerSnapshotManifestPath()
{
   return AC_ExternalWorkerInboxFolder() + "\\snapshot_latest.manifest";
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

string AC_ExternalWorkerPackagedExePath()
{
   return AC_SharedExternalWorkerPackageFolder() + "\\" + AC_EXTERNAL_WORKER_EXE_FILE;
}

string AC_SharedMarketDataFolder()
{
   return AC_SharedRootFolder() + "\\Shared Market Data";
}

string AC_SharedOhlcStoreFolder()
{
   return AC_SharedMarketDataFolder() + "\\OHLC Store";
}

string AC_SharedOhlcWorkbenchFolder()
{
   return AC_WorkbenchFolder() + "\\Shared OHLC Raw Storage";
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

string AC_ManifestPath()
{
   return AC_WorkbenchManifestsFolder() + "\\Publication_Manifest.txt";
}

string AC_WorkbenchStatusPath()
{
   return AC_WorkbenchStatusFolder() + "\\Workbench_Status.txt";
}

string AC_DiagnosticsPath()
{
   return AC_WorkbenchDiagnosticsFolder() + "\\Diagnostics.txt";
}

string AC_UpgradeLogPath()
{
   return AC_WorkbenchStatusFolder() + "\\Upgrade_Log.txt";
}

string AC_UpgradeAddendumPath()
{
   return AC_WorkbenchStatusFolder() + "\\Upgrade_Addendum.txt";
}

string AC_RuntimeStatusPath()
{
   return AC_WorkbenchStatusFolder() + "\\Runtime_Status.txt";
}

string AC_AccountStatusPath()
{
   return AC_WorkbenchStatusFolder() + "\\Account_Status.txt";
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

bool AC_EnsureRuntimeFolders(string &detail)
{
   bool ok = true;
   string d = "";
   detail = "";

   string folders[];
   ArrayResize(folders, 37);
   folders[0] = AC_RootFolder();
   folders[1] = AC_WorkbenchFolder();
   folders[2] = AC_WorkbenchInternalFolder();
   folders[3] = AC_WorkbenchManifestsFolder();
   folders[4] = AC_WorkbenchStatusFolder();
   folders[5] = AC_WorkbenchDiagnosticsFolder();
   folders[6] = AC_WorkbenchCacheFolder();
   folders[7] = AC_WorkbenchFileIoStatusFolder();
   folders[8] = AC_WorkbenchFileIoAuditFolder();
   folders[9] = AC_Runtime0Folder();
   folders[10] = AC_ExternalWorkerFolder();
   folders[11] = AC_ExternalWorkerControlFolder();
   folders[12] = AC_ExternalWorkerInboxFolder();
   folders[13] = AC_ExternalWorkerOutboxFolder();
   folders[14] = AC_ExternalWorkerStatusFolder();
   folders[15] = AC_ExternalWorkerLogsFolder();
   folders[16] = AC_ExternalWorkerQuarantineFolder();
   folders[17] = AC_SharedRootFolder();
   folders[18] = AC_SharedExternalWorkerFolder();
   folders[19] = AC_SharedExternalWorkerPackageFolder();
   folders[20] = AC_SharedExternalWorkerStatusFolder();
   folders[21] = AC_SharedMarketDataFolder();
   folders[22] = AC_SharedOhlcStoreFolder();
   folders[23] = AC_SharedOhlcWorkbenchFolder();
   folders[24] = AC_DossiersFolder();
   folders[25] = AC_DossiersOpenFolder();
   folders[26] = AC_DossiersClosedFolder();
   folders[27] = AC_DossiersUnknownFolder();
   folders[28] = AC_SelectionDeskFolder();
   folders[29] = AC_SelectionGroupsFolder();
   folders[30] = AC_SelectionGlobalFolder();
   folders[31] = AC_SelectionCompatibilityGlobalFolder();
   folders[32] = AC_SelectionGlobalTop10Folder();
   folders[33] = AC_SelectionGlobalDeepEvidenceFolder();
   folders[34] = AC_SelectionAssetClassesFolder();
   folders[35] = AC_SelectionSystemIndexesFolder();
   folders[36] = AC_SelectionLayerSummariesFolder();

   for(int i = 0; i < ArraySize(folders); i++)
   {
      bool folder_ok = AC_EnsureFolderPath(folders[i], d);
      if(detail != "") detail += ";";
      detail += "folder_" + IntegerToString(i) + "=" + d;
      ok = folder_ok && ok;
   }

   return ok;
}

#endif
