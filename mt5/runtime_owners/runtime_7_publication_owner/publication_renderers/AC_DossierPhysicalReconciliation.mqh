#ifndef AC_DOSSIER_PHYSICAL_RECONCILIATION_MQH
#define AC_DOSSIER_PHYSICAL_RECONCILIATION_MQH

// Render/publication support for physical Dossier route truth.
// This file does not own routes, FileIO, Layer 2 market state, ranking, selection, permission, or execution.
// It enumerates the existing Open/Closed/Unknown folders and compares physical files to Layer 2 route truth.

static int    AC_DOSSIER_PHYSICAL_OPEN_FILES = 0;
static int    AC_DOSSIER_PHYSICAL_CLOSED_FILES = 0;
static int    AC_DOSSIER_PHYSICAL_UNKNOWN_FILES = 0;
static int    AC_DOSSIER_EXPECTED_OPEN_FILES = 0;
static int    AC_DOSSIER_EXPECTED_CLOSED_FILES = 0;
static int    AC_DOSSIER_EXPECTED_UNKNOWN_FILES = 0;
static int    AC_DOSSIER_PHYSICAL_MISSING_SYMBOLS = 0;
static int    AC_DOSSIER_PHYSICAL_DUPLICATE_SYMBOLS = 0;
static int    AC_DOSSIER_PHYSICAL_WRONG_FOLDER_SYMBOLS = 0;
static int    AC_DOSSIER_PHYSICAL_ORPHAN_FILES = 0;
static bool   AC_DOSSIER_PHYSICAL_CLEANUP_PENDING = false;
static bool   AC_DOSSIER_PHYSICAL_MATCH_OK = false;
static string AC_DOSSIER_PHYSICAL_MISSING_SAMPLE = "";
static string AC_DOSSIER_PHYSICAL_DUPLICATE_SAMPLE = "";
static string AC_DOSSIER_PHYSICAL_WRONG_FOLDER_SAMPLE = "";
static string AC_DOSSIER_PHYSICAL_ORPHAN_SAMPLE = "";
static string AC_DOSSIER_PHYSICAL_LAST_PROOF_KEY = "";
static string AC_DOSSIER_PHYSICAL_LAST_SOURCE_KEY = "";
static uint   AC_DOSSIER_PHYSICAL_LAST_REFRESH_MS = 0;
static uint   AC_DOSSIER_PHYSICAL_CACHE_MS = 1000;

#define AC_DOSSIER_CLEANUP_PENDING AC_DOSSIER_PHYSICAL_CLEANUP_PENDING

string AC_DossierPhysicalNormalizeState(string state)
{
   StringTrimLeft(state);
   StringTrimRight(state);
   if(state == "open") return "open";
   if(state == "closed") return "closed";
   return "unknown";
}

string AC_DossierSymbolPathByState(const string symbol, const string market_state)
{
   string state = AC_DossierPhysicalNormalizeState(market_state);
   if(state == "open") return AC_DossierOpenSymbolPath(symbol);
   if(state == "closed") return AC_DossierClosedSymbolPath(symbol);
   return AC_DossierUnknownSymbolPath(symbol);
}

void AC_DossierPhysicalAppendSample(string &sample, const string value)
{
   if(value == "") return;
   if(sample == "")
   {
      sample = value;
      return;
   }
   if(StringLen(sample) < 240)
      sample += "," + value;
}

bool AC_DossierPhysicalFileExists(const string path)
{
   return FileIsExist(path, AC_CommonFlag());
}

int AC_DossierPhysicalCountFolderFiles(const string folder)
{
   string filename = "";
   long handle = FileFindFirst(folder + "\\*.txt", filename, AC_CommonFlag());
   if(handle == INVALID_HANDLE)
      return 0;

   int count = 0;
   do
   {
      if(filename != "" && StringSubstr(filename, 0, 1) != "_")
         count++;
   }
   while(FileFindNext(handle, filename));

   FileFindClose(handle);
   return count;
}

bool AC_DossierPhysicalKnownSymbolStem(const string stem, const int total)
{
   for(int idx = 0; idx < total; idx++)
   {
      string symbol = SymbolName(idx, false);
      if(symbol == "") continue;
      if(AC_SanitizePathPart(symbol) == stem)
         return true;
   }
   return false;
}

int AC_DossierPhysicalCountOrphansInFolder(const string folder, const string folder_label, const int total)
{
   string filename = "";
   long handle = FileFindFirst(folder + "\\*.txt", filename, AC_CommonFlag());
   if(handle == INVALID_HANDLE)
      return 0;

   int orphan_count = 0;
   do
   {
      if(filename == "" || StringSubstr(filename, 0, 1) == "_")
         continue;

      string stem = filename;
      int dot_pos = StringFind(stem, ".txt");
      if(dot_pos >= 0)
         stem = StringSubstr(stem, 0, dot_pos);

      if(!AC_DossierPhysicalKnownSymbolStem(stem, total))
      {
         orphan_count++;
         AC_DossierPhysicalAppendSample(AC_DOSSIER_PHYSICAL_ORPHAN_SAMPLE, folder_label + "/" + filename);
      }
   }
   while(FileFindNext(handle, filename));

   FileFindClose(handle);
   return orphan_count;
}

string AC_DossierPhysicalSourceKey(const int total)
{
   return "symbols=" + IntegerToString(total)
      + "|l2_route=" + AC_L2_ROUTE_GENERATION_KEY
      + "|open=" + IntegerToString(AC_L2_OPEN_COUNT)
      + "|closed=" + IntegerToString(AC_L2_CLOSED_COUNT)
      + "|unknown=" + IntegerToString(AC_L2_UNKNOWN_COUNT)
      + "|writes_open=" + IntegerToString(AC_L2_ROUTE_WRITE_OPEN_COUNT)
      + "|writes_closed=" + IntegerToString(AC_L2_ROUTE_WRITE_CLOSED_COUNT)
      + "|writes_unknown=" + IntegerToString(AC_L2_ROUTE_WRITE_UNKNOWN_COUNT)
      + "|write_failures=" + IntegerToString(AC_L2_ROUTE_WRITE_FAILURE_COUNT)
      + "|cleanup=" + IntegerToString(AC_L2_DUPLICATE_CLEANUP_COUNT)
      + "|cleanup_failures=" + IntegerToString(AC_L2_DUPLICATE_CLEANUP_FAILURE_COUNT);
}

void AC_DossierPhysicalRefreshProof()
{
   int total = SymbolsTotal(false);
   uint now_ms = GetTickCount();
   string source_key = AC_DossierPhysicalSourceKey(total);
   if(AC_DOSSIER_PHYSICAL_LAST_SOURCE_KEY == source_key
      && AC_DOSSIER_PHYSICAL_LAST_PROOF_KEY != ""
      && (now_ms - AC_DOSSIER_PHYSICAL_LAST_REFRESH_MS) < AC_DOSSIER_PHYSICAL_CACHE_MS)
      return;

   AC_DOSSIER_PHYSICAL_OPEN_FILES = AC_DossierPhysicalCountFolderFiles(AC_DossiersOpenFolder());
   AC_DOSSIER_PHYSICAL_CLOSED_FILES = AC_DossierPhysicalCountFolderFiles(AC_DossiersClosedFolder());
   AC_DOSSIER_PHYSICAL_UNKNOWN_FILES = AC_DossierPhysicalCountFolderFiles(AC_DossiersUnknownFolder());

   AC_DOSSIER_EXPECTED_OPEN_FILES = AC_L2_OPEN_COUNT;
   AC_DOSSIER_EXPECTED_CLOSED_FILES = AC_L2_CLOSED_COUNT;
   AC_DOSSIER_EXPECTED_UNKNOWN_FILES = AC_L2_UNKNOWN_COUNT;
   AC_DOSSIER_PHYSICAL_MISSING_SYMBOLS = 0;
   AC_DOSSIER_PHYSICAL_DUPLICATE_SYMBOLS = 0;
   AC_DOSSIER_PHYSICAL_WRONG_FOLDER_SYMBOLS = 0;
   AC_DOSSIER_PHYSICAL_ORPHAN_FILES = 0;
   AC_DOSSIER_PHYSICAL_CLEANUP_PENDING = false;
   AC_DOSSIER_PHYSICAL_MATCH_OK = false;
   AC_DOSSIER_PHYSICAL_MISSING_SAMPLE = "";
   AC_DOSSIER_PHYSICAL_DUPLICATE_SAMPLE = "";
   AC_DOSSIER_PHYSICAL_WRONG_FOLDER_SAMPLE = "";
   AC_DOSSIER_PHYSICAL_ORPHAN_SAMPLE = "";

   for(int idx = 0; idx < total; idx++)
   {
      string symbol = SymbolName(idx, false);
      if(symbol == "") continue;

      string state = AC_DossierPhysicalNormalizeState(AC_L2MarketStateForSymbol(symbol));
      bool open_exists = AC_DossierPhysicalFileExists(AC_DossierOpenSymbolPath(symbol));
      bool closed_exists = AC_DossierPhysicalFileExists(AC_DossierClosedSymbolPath(symbol));
      bool unknown_exists = AC_DossierPhysicalFileExists(AC_DossierUnknownSymbolPath(symbol));
      int exists_count = (open_exists ? 1 : 0) + (closed_exists ? 1 : 0) + (unknown_exists ? 1 : 0);

      bool target_exists = (state == "open" ? open_exists : (state == "closed" ? closed_exists : unknown_exists));
      if(!target_exists)
      {
         AC_DOSSIER_PHYSICAL_MISSING_SYMBOLS++;
         AC_DossierPhysicalAppendSample(AC_DOSSIER_PHYSICAL_MISSING_SAMPLE, symbol + ":expected_" + state);
      }

      if(exists_count > 1)
      {
         AC_DOSSIER_PHYSICAL_DUPLICATE_SYMBOLS++;
         AC_DossierPhysicalAppendSample(AC_DOSSIER_PHYSICAL_DUPLICATE_SAMPLE, symbol);
      }

      if((state == "open" && (closed_exists || unknown_exists))
         || (state == "closed" && (open_exists || unknown_exists))
         || (state == "unknown" && (open_exists || closed_exists)))
      {
         AC_DOSSIER_PHYSICAL_WRONG_FOLDER_SYMBOLS++;
         AC_DossierPhysicalAppendSample(AC_DOSSIER_PHYSICAL_WRONG_FOLDER_SAMPLE, symbol + ":expected_" + state);
      }
   }

   AC_DOSSIER_PHYSICAL_ORPHAN_FILES += AC_DossierPhysicalCountOrphansInFolder(AC_DossiersOpenFolder(), "Open", total);
   AC_DOSSIER_PHYSICAL_ORPHAN_FILES += AC_DossierPhysicalCountOrphansInFolder(AC_DossiersClosedFolder(), "Closed", total);
   AC_DOSSIER_PHYSICAL_ORPHAN_FILES += AC_DossierPhysicalCountOrphansInFolder(AC_DossiersUnknownFolder(), "Unknown", total);

   AC_DOSSIER_PHYSICAL_CLEANUP_PENDING = (AC_DOSSIER_PHYSICAL_DUPLICATE_SYMBOLS > 0 || AC_DOSSIER_PHYSICAL_WRONG_FOLDER_SYMBOLS > 0 || AC_DOSSIER_PHYSICAL_ORPHAN_FILES > 0);
   AC_DOSSIER_PHYSICAL_MATCH_OK = (AC_DOSSIER_PHYSICAL_OPEN_FILES == AC_DOSSIER_EXPECTED_OPEN_FILES
      && AC_DOSSIER_PHYSICAL_CLOSED_FILES == AC_DOSSIER_EXPECTED_CLOSED_FILES
      && AC_DOSSIER_PHYSICAL_UNKNOWN_FILES == AC_DOSSIER_EXPECTED_UNKNOWN_FILES
      && AC_DOSSIER_PHYSICAL_MISSING_SYMBOLS == 0
      && AC_DOSSIER_PHYSICAL_DUPLICATE_SYMBOLS == 0
      && AC_DOSSIER_PHYSICAL_WRONG_FOLDER_SYMBOLS == 0
      && AC_DOSSIER_PHYSICAL_ORPHAN_FILES == 0);

   AC_DOSSIER_PHYSICAL_LAST_PROOF_KEY = "open_files=" + IntegerToString(AC_DOSSIER_PHYSICAL_OPEN_FILES)
      + "|closed_files=" + IntegerToString(AC_DOSSIER_PHYSICAL_CLOSED_FILES)
      + "|unknown_files=" + IntegerToString(AC_DOSSIER_PHYSICAL_UNKNOWN_FILES)
      + "|expected_open=" + IntegerToString(AC_DOSSIER_EXPECTED_OPEN_FILES)
      + "|expected_closed=" + IntegerToString(AC_DOSSIER_EXPECTED_CLOSED_FILES)
      + "|expected_unknown=" + IntegerToString(AC_DOSSIER_EXPECTED_UNKNOWN_FILES)
      + "|missing_symbols=" + IntegerToString(AC_DOSSIER_PHYSICAL_MISSING_SYMBOLS)
      + "|duplicate_symbols=" + IntegerToString(AC_DOSSIER_PHYSICAL_DUPLICATE_SYMBOLS)
      + "|wrong_folder_symbols=" + IntegerToString(AC_DOSSIER_PHYSICAL_WRONG_FOLDER_SYMBOLS)
      + "|orphan_files=" + IntegerToString(AC_DOSSIER_PHYSICAL_ORPHAN_FILES)
      + "|cleanup_pending=" + (AC_DOSSIER_PHYSICAL_CLEANUP_PENDING ? "true" : "false")
      + "|physical_match=" + (AC_DOSSIER_PHYSICAL_MATCH_OK ? "true" : "false");
   AC_DOSSIER_PHYSICAL_LAST_SOURCE_KEY = source_key;
   AC_DOSSIER_PHYSICAL_LAST_REFRESH_MS = now_ms;
}

#endif
