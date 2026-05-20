#ifndef AC_SERVER_PATHS_MQH
#define AC_SERVER_PATHS_MQH

#include "../../../core/AC_Config.mqh"

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

string AC_RuntimeStatusPath()
{
   return AC_RootFolder() + "\\Runtime Status.txt";
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
   bool ok = true;
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
      if(!FolderCreate(current, AC_USE_COMMON_FILES ? FILE_COMMON : 0))
      {
         int err = GetLastError();
         // FolderCreate can fail when folder already exists on some builds/environments.
         // Treat existing/usable folder as acceptable by probing with a tiny temp file later.
         if(err != 0)
         {
            detail = "folder_create_failed_at=" + current + ";error=" + IntegerToString(err);
            ok = false;
         }
      }
   }

   if(ok)
      detail = "folder_create_ok";
   return ok;
}

bool AC_EnsureRuntimeFolders(string &detail)
{
   string root_detail = "";
   string wb_detail = "";
   bool root_ok = AC_EnsureFolderPath(AC_RootFolder(), root_detail);
   bool wb_ok = AC_EnsureFolderPath(AC_WorkbenchFolder(), wb_detail);
   detail = "root=" + root_detail + ";workbench=" + wb_detail;
   return root_ok && wb_ok;
}

#endif
