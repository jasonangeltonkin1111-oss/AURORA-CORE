#ifndef AC_SERVER_PATHS_MQH
#define AC_SERVER_PATHS_MQH

// Dependencies are included by mt5/AuroraCore.mq5 using root includes.
// Runtime 7 owns route building; config is supplied by the main include chain.

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

string AC_RootFolder()
{
   return AC_BASE_FOLDER + "\\" + AC_ServerNameForRoute() + "\\" + AC_AccountForRoute();
}

string AC_WorkbenchFolder()
{
   return AC_RootFolder() + "\\" + AC_WORKBENCH_FOLDER;
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
   string dossiers_detail = "";
   string open_detail = "";
   string closed_detail = "";
   string unknown_detail = "";
   string selection_desk_detail = "";
   string selection_groups_detail = "";
   string selection_global_detail = "";

   bool root_ok = AC_EnsureFolderPath(AC_RootFolder(), root_detail);
   bool wb_ok = AC_EnsureFolderPath(AC_WorkbenchFolder(), wb_detail);
   bool dossiers_ok = AC_EnsureFolderPath(AC_DossiersFolder(), dossiers_detail);
   bool open_ok = AC_EnsureFolderPath(AC_DossiersOpenFolder(), open_detail);
   bool closed_ok = AC_EnsureFolderPath(AC_DossiersClosedFolder(), closed_detail);
   bool unknown_ok = AC_EnsureFolderPath(AC_DossiersUnknownFolder(), unknown_detail);
   bool selection_desk_ok = AC_EnsureFolderPath(AC_SelectionDeskFolder(), selection_desk_detail);
   bool selection_groups_ok = AC_EnsureFolderPath(AC_SelectionGroupsFolder(), selection_groups_detail);
   bool selection_global_ok = AC_EnsureFolderPath(AC_SelectionGlobalFolder(), selection_global_detail);

   detail = "root=" + root_detail
      + ";workbench=" + wb_detail
      + ";dossiers=" + dossiers_detail
      + ";dossiers_open=" + open_detail
      + ";dossiers_closed=" + closed_detail
      + ";dossiers_unknown=" + unknown_detail
      + ";selection_desk=" + selection_desk_detail
      + ";selection_groups=" + selection_groups_detail
      + ";selection_global=" + selection_global_detail;

   return root_ok && wb_ok && dossiers_ok && open_ok && closed_ok && unknown_ok && selection_desk_ok && selection_groups_ok && selection_global_ok;
}

#endif