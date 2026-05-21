#ifndef AC_SERVER_PATHS_MQH
#define AC_SERVER_PATHS_MQH

// Dependencies are included by mt5/AuroraCore.mq5 using root includes.
// Publication / FileIO / Route Service owns route building only. It does not own trading truth.
// Runtime 3 external worker split:
// - Shared worker binary/install payload lives under Aurora Core\External Worker so all terminals/accounts can use one package.
// - Per-server/account worker IO, status, inbox, outbox, logs, and proof files remain under Aurora Core\<server>\<account>\Workbench\External Worker.

string AC_SanitizePathPart(string value)
{
   StringTrimLeft(value);
   StringTrimRight(value);
   if(value == "")
      value = "unknown";

   StringReplace(value, "\\", "_");
   StringReplace(value, "/", "_");
   StringReplace(value, ":", "_");
   StringReplace(value, "*", "_");
   StringReplace(value, "?", "_");
   StringReplace(value, "\"", "_");
   StringReplace(value, "<", "_");
   StringReplace(value, ">", "_");
   StringReplace(value, "|", "_");
   StringReplace(value, " ", "_");
   return value;
}

int AC_FileFlags()
{
   int flags = FILE_TXT | FILE_ANSI;
   if(AC_USE_COMMON_FILES)
      flags |= FILE_COMMON;
   return flags;
}

int AC_CommonFlag()
{
   return AC_USE_COMMON_FILES ? FILE_COMMON : 0;
}

bool AC_FolderDetailHasWarning(const string detail)
{
   return StringFind(detail, "folder_create_warning_at=") >= 0;
}

string AC_FolderStatusFromDetail(const bool folders_ok, const string detail)
{
   if(!folders_ok)
      return "folder_create_failed";
   if(AC_FolderDetailHasWarning(detail))
      return "folder_create_warning";
   return "folder_create_ok";
}

string AC_ServerNameForRoute()
{
   string server = AccountInfoString(ACCOUNT_SERVER);
   if(server == "")
      server = TerminalInfoString(TERMINAL_NAME);
   return AC_SanitizePathPart(server);
}

string AC_AccountForRoute()
{
   long login = AccountInfoInteger(ACCOUNT_LOGIN);
   if(login <= 0)
      return "unknown_account";
   return IntegerToString(login);
}

string AC_SharedRootFolder()
{
   return AC_BASE_FOLDER;
}

string AC_RootFolder()
{
   return AC_BASE_FOLDER + "\\" + AC_ServerNameForRoute() + "\\" + AC_AccountForRoute();
}

string AC_WorkbenchFolder()
{
   return AC_RootFolder() + "\\" + AC_WORKBENCH_FOLDER;
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

string AC_ExternalWorkerFolder()
{
   return AC_WorkbenchFolder() + "\\" + AC_EXTERNAL_WORKER_FOLDER;
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

string AC_ExternalWorkerExePath()
{
   return AC_SharedExternalWorkerFolder() + "\\" + AC_EXTERNAL_WORKER_EXE_FILE;
}

string AC_ExternalWorkerPackagedExePath()
{
   return AC_SharedExternalWorkerPackageFolder() + "\\" + AC_EXTERNAL_WORKER_EXE_FILE;
}

string AC_ExternalWorkerRequiredPath()
{
   return AC_ExternalWorkerControlFolder() + "\\worker_required.txt";
}

string AC_ExternalWorkerInstallStatusPath()
{
   return AC_ExternalWorkerStatusFolder() + "\\worker_install_status.txt";
}

string AC_ExternalWorkerProcessStatusPath()
{
   return AC_ExternalWorkerStatusFolder() + "\\worker_process_status.txt";
}

string AC_ExternalWorkerHeartbeatPath()
{
   return AC_ExternalWorkerStatusFolder() + "\\worker_heartbeat.txt";
}

string AC_ExternalWorkerResultStatusPath()
{
   return AC_ExternalWorkerStatusFolder() + "\\worker_result_status.txt";
}

string AC_ExternalWorkerSnapshotPath()
{
   return AC_ExternalWorkerInboxFolder() + "\\snapshot_latest.txt";
}

string AC_ExternalWorkerSnapshotManifestPath()
{
   return AC_ExternalWorkerInboxFolder() + "\\snapshot_latest.manifest";
}

string AC_ExternalWorkerResultPath()
{
   return AC_ExternalWorkerOutboxFolder() + "\\result_latest.txt";
}

string AC_ExternalWorkerResultManifestPath()
{
   return AC_ExternalWorkerOutboxFolder() + "\\result_latest.manifest";
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

string AC_SelectionIndexPath()
{
   return AC_SelectionDeskFolder() + "\\" + AC_SELECTION_INDEX_FILE;
}

string AC_MarketBoardPath()
{
   return AC_RootFolder() + "\\" + AC_MARKET_BOARD_FILE;
}

string AC_DossierOpenSymbolPath(const string symbol)
{
   return AC_DossiersOpenFolder() + "\\" + AC_SanitizePathPart(symbol) + ".txt";
}

string AC_DossierClosedSymbolPath(const string symbol)
{
   return AC_DossiersClosedFolder() + "\\" + AC_SanitizePathPart(symbol) + ".txt";
}

string AC_DossierUnknownSymbolPath(const string symbol)
{
   return AC_DossiersUnknownFolder() + "\\" + AC_SanitizePathPart(symbol) + ".txt";
}

string AC_DossierSymbolPathByState(const string symbol, const string market_state)
{
   if(market_state == "open") return AC_DossierOpenSymbolPath(symbol);
   if(market_state == "closed") return AC_DossierClosedSymbolPath(symbol);
   return AC_DossierUnknownSymbolPath(symbol);
}

string AC_RuntimeStatusPath()
{
   return AC_RootFolder() + "\\Runtime Status.txt";
}

string AC_AccountStatusPath()
{
   return AC_RootFolder() + "\\Account Status.txt";
}

string AC_ManifestPath()
{
   return AC_WorkbenchFolder() + "\\Manifest.txt";
}

string AC_WorkbenchStatusPath()
{
   return AC_WorkbenchFolder() + "\\Status.txt";
}

string AC_DiagnosticsPath()
{
   return AC_WorkbenchFolder() + "\\Diagnostics.txt";
}

string AC_UpgradeLogPath()
{
   return AC_WorkbenchFolder() + "\\Upgrade Log.txt";
}

string AC_UpgradeAddendumPath()
{
   return AC_WorkbenchFolder() + "\\Upgrade Addendum.txt";
}

string AC_MicroLogPath()
{
   return AC_WorkbenchFolder() + "\\Micro Log.txt";
}

string AC_PlaceholderPath(const string folder_path)
{
   return folder_path + "\\_PLACEHOLDER.txt";
}

bool AC_EnsureFolderPath(const string folder_path, string &detail)
{
   string parts[];
   int count = StringSplit(folder_path, '\\', parts);
   if(count <= 0)
   {
      detail = "folder_path_split_failed";
      return false;
   }

   string current = "";
   detail = "folder_create_attempted";

   for(int i = 0; i < count; i++)
   {
      if(parts[i] == "")
         continue;
      if(current == "")
         current = parts[i];
      else
         current = current + "\\" + parts[i];

      ResetLastError();
      bool created = FolderCreate(current, AC_CommonFlag());
      int err = GetLastError();
      if(!created && err != 0)
         detail += ";folder_create_warning_at=" + current + ";error=" + IntegerToString(err);
   }

   if(detail == "folder_create_attempted")
      detail = "folder_create_attempted_no_errors";
   return true;
}

bool AC_EnsureRuntimeFolders(string &detail)
{
   string root_detail = "";
   string wb_detail = "";
   string shared_worker_detail = "";
   string shared_worker_package_detail = "";
   string shared_worker_status_detail = "";
   string worker_detail = "";
   string worker_control_detail = "";
   string worker_inbox_detail = "";
   string worker_outbox_detail = "";
   string worker_status_detail = "";
   string worker_logs_detail = "";
   string worker_quarantine_detail = "";
   string dossiers_detail = "";
   string open_detail = "";
   string closed_detail = "";
   string unknown_detail = "";
   string selection_desk_detail = "";
   string selection_groups_detail = "";
   string selection_global_detail = "";

   bool root_ok = AC_EnsureFolderPath(AC_RootFolder(), root_detail);
   bool wb_ok = AC_EnsureFolderPath(AC_WorkbenchFolder(), wb_detail);
   bool shared_worker_ok = AC_EnsureFolderPath(AC_SharedExternalWorkerFolder(), shared_worker_detail);
   bool shared_worker_package_ok = AC_EnsureFolderPath(AC_SharedExternalWorkerPackageFolder(), shared_worker_package_detail);
   bool shared_worker_status_ok = AC_EnsureFolderPath(AC_SharedExternalWorkerStatusFolder(), shared_worker_status_detail);
   bool worker_ok = AC_EnsureFolderPath(AC_ExternalWorkerFolder(), worker_detail);
   bool worker_control_ok = AC_EnsureFolderPath(AC_ExternalWorkerControlFolder(), worker_control_detail);
   bool worker_inbox_ok = AC_EnsureFolderPath(AC_ExternalWorkerInboxFolder(), worker_inbox_detail);
   bool worker_outbox_ok = AC_EnsureFolderPath(AC_ExternalWorkerOutboxFolder(), worker_outbox_detail);
   bool worker_status_ok = AC_EnsureFolderPath(AC_ExternalWorkerStatusFolder(), worker_status_detail);
   bool worker_logs_ok = AC_EnsureFolderPath(AC_ExternalWorkerLogsFolder(), worker_logs_detail);
   bool worker_quarantine_ok = AC_EnsureFolderPath(AC_ExternalWorkerQuarantineFolder(), worker_quarantine_detail);
   bool dossiers_ok = AC_EnsureFolderPath(AC_DossiersFolder(), dossiers_detail);
   bool open_ok = AC_EnsureFolderPath(AC_DossiersOpenFolder(), open_detail);
   bool closed_ok = AC_EnsureFolderPath(AC_DossiersClosedFolder(), closed_detail);
   bool unknown_ok = AC_EnsureFolderPath(AC_DossiersUnknownFolder(), unknown_detail);
   bool selection_desk_ok = AC_EnsureFolderPath(AC_SelectionDeskFolder(), selection_desk_detail);
   bool selection_groups_ok = AC_EnsureFolderPath(AC_SelectionGroupsFolder(), selection_groups_detail);
   bool selection_global_ok = AC_EnsureFolderPath(AC_SelectionGlobalFolder(), selection_global_detail);

   detail = "root=" + root_detail
      + ";workbench=" + wb_detail
      + ";shared_external_worker=" + shared_worker_detail
      + ";shared_external_worker_package=" + shared_worker_package_detail
      + ";shared_external_worker_status=" + shared_worker_status_detail
      + ";external_worker_account_io=" + worker_detail
      + ";external_worker_control=" + worker_control_detail
      + ";external_worker_inbox=" + worker_inbox_detail
      + ";external_worker_outbox=" + worker_outbox_detail
      + ";external_worker_status=" + worker_status_detail
      + ";external_worker_logs=" + worker_logs_detail
      + ";external_worker_quarantine=" + worker_quarantine_detail
      + ";dossiers=" + dossiers_detail
      + ";dossiers_open=" + open_detail
      + ";dossiers_closed=" + closed_detail
      + ";dossiers_unknown=" + unknown_detail
      + ";selection_desk=" + selection_desk_detail
      + ";selection_groups=" + selection_groups_detail
      + ";selection_global=" + selection_global_detail
      + ";market_board_path=" + AC_MarketBoardPath()
      + ";external_worker_required_path=" + AC_ExternalWorkerRequiredPath()
      + ";shared_external_worker_exe_path=" + AC_ExternalWorkerPackagedExePath()
      + ";shared_worker_install_status_path=" + AC_SharedExternalWorkerInstallStatusPath()
      + ";shared_worker_status_path=" + AC_SharedExternalWorkerStatusPath()
      + ";selection_index_path=" + AC_SelectionIndexPath();

   return root_ok && wb_ok && shared_worker_ok && shared_worker_package_ok && shared_worker_status_ok && worker_ok && worker_control_ok && worker_inbox_ok && worker_outbox_ok && worker_status_ok && worker_logs_ok && worker_quarantine_ok && dossiers_ok && open_ok && closed_ok && unknown_ok && selection_desk_ok && selection_groups_ok && selection_global_ok;
}

#endif