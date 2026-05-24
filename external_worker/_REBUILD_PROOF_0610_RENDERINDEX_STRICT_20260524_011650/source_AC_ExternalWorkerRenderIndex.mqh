#ifndef AC_EXTERNAL_WORKER_RENDER_INDEX_MQH
#define AC_EXTERNAL_WORKER_RENDER_INDEX_MQH

// Runtime 3 / Runtime 7 support reader for worker-produced RenderIndex v1.
// This file reads compact worker indexes once per heartbeat and exposes lookup helpers.
// It does not score, rank, select, permit, execute, publish final routes, or own FileIO.

#define AC_RENDER_INDEX_MAX_ROWS 4096

struct AC_RenderIndexRow
{
   string symbol;
   int layer_id;
   string rank_index;
   string score;
   string bucket;
   string rank_state;
   string score_quality;
   string rank_path;
   string rank_file_checksum;
   string source_ranked_manifest_checksum;
   string source_ranked_manifest_status;
};

struct AC_OhlcReadinessIndexRow
{
   string symbol;
   bool m5_ready;
   bool m15_ready;
   bool h1_ready;
   bool h4_ready;
   bool d1_ready;
   bool l8_min_ready;
   bool l9_required_ready;
};

static long AC_RENDER_INDEX_LAST_REFRESH_HEARTBEAT_ID = -1;
static bool AC_RENDER_INDEX_ACCEPTED = false;
static string AC_RENDER_INDEX_STATUS = "not_loaded";
static string AC_RENDER_INDEX_REASON = "not_loaded";
static string AC_RENDER_INDEX_MANIFEST_CHECKSUM = "not_available";
static int AC_RENDER_INDEX_L6_ROWS = 0;
static int AC_RENDER_INDEX_L7_ROWS = 0;
static int AC_RENDER_INDEX_L8_ROWS = 0;
static int AC_RENDER_INDEX_L9_ROWS = 0;
static int AC_RENDER_INDEX_OHLC_ROWS = 0;
static AC_RenderIndexRow AC_RENDER_INDEX_ROWS[];
static AC_OhlcReadinessIndexRow AC_RENDER_INDEX_OHLC_ROWS_DATA[];

string AC_RenderIndexFolderPath()
{
   return AC_ExternalWorkerOutboxFolder() + "\\RenderIndex";
}

string AC_RenderIndexManifestPath()
{
   return AC_RenderIndexFolderPath() + "\\render_index.manifest";
}

string AC_RenderIndexLayerCsvPath(const int layer_id)
{
   if(layer_id == 6) return AC_RenderIndexFolderPath() + "\\l6_symbol_rank_index.csv";
   if(layer_id == 7) return AC_RenderIndexFolderPath() + "\\l7_symbol_rank_index.csv";
   if(layer_id == 8) return AC_RenderIndexFolderPath() + "\\l8_symbol_rank_index.csv";
   if(layer_id == 9) return AC_RenderIndexFolderPath() + "\\l9_symbol_rank_index.csv";
   return "";
}

string AC_RenderIndexOhlcCsvPath()
{
   return AC_RenderIndexFolderPath() + "\\ohlc_window_readiness_index.csv";
}

string AC_RenderIndexReadTextFile(const string path, const int max_chars = 250000)
{
   int common_flag = AC_USE_COMMON_FILES ? FILE_COMMON : 0;
   if(!FileIsExist(path, common_flag)) return "";
   ResetLastError();
   int handle = FileOpen(path, AC_FileFlags() | FILE_READ);
   if(handle == INVALID_HANDLE) return "";
   string text = "";
   while(!FileIsEnding(handle) && StringLen(text) < max_chars)
   {
      string line = FileReadString(handle);
      text += line;
      if(!FileIsEnding(handle)) text += "\n";
   }
   FileClose(handle);
   if(StringLen(text) > max_chars) text = StringSubstr(text, 0, max_chars);
   return text;
}

string AC_RenderIndexKvValue(const string text, const string key, const string fallback = "not_available")
{
   string lines[];
   ushort separator = StringGetCharacter("\n", 0);
   int count = StringSplit(text, separator, lines);
   string prefix = key + "=";
   for(int i = 0; i < count; i++)
   {
      string line = lines[i];
      StringReplace(line, "\r", "");
      StringTrimLeft(line);
      StringTrimRight(line);
      if(StringFind(line, prefix) == 0)
      {
         string value = StringSubstr(line, StringLen(prefix));
         StringTrimLeft(value);
         StringTrimRight(value);
         return value == "" ? fallback : value;
      }
   }
   return fallback;
}

bool AC_RenderIndexBoolField(const string value)
{
   string text = value;
   StringTrimLeft(text);
   StringTrimRight(text);
   StringToLower(text);
   return text == "true" || text == "1" || text == "yes";
}

string AC_RenderIndexCsvField(const string row, const int index, const string fallback = "")
{
   string parts[];
   ushort sep = StringGetCharacter(",", 0);
   int count = StringSplit(row, sep, parts);
   if(index < 0 || index >= count) return fallback;
   string value = parts[index];
   StringTrimLeft(value);
   StringTrimRight(value);
   return value;
}

int AC_RenderIndexAppendRow(const AC_RenderIndexRow &row)
{
   int size = ArraySize(AC_RENDER_INDEX_ROWS);
   if(size >= AC_RENDER_INDEX_MAX_ROWS) return size;
   ArrayResize(AC_RENDER_INDEX_ROWS, size + 1);
   AC_RENDER_INDEX_ROWS[size] = row;
   return size + 1;
}

int AC_RenderIndexAppendOhlcRow(const AC_OhlcReadinessIndexRow &row)
{
   int size = ArraySize(AC_RENDER_INDEX_OHLC_ROWS_DATA);
   if(size >= AC_RENDER_INDEX_MAX_ROWS) return size;
   ArrayResize(AC_RENDER_INDEX_OHLC_ROWS_DATA, size + 1);
   AC_RENDER_INDEX_OHLC_ROWS_DATA[size] = row;
   return size + 1;
}

int AC_RenderIndexLoadLayerCsv(const int layer_id)
{
   string path = AC_RenderIndexLayerCsvPath(layer_id);
   string text = path == "" ? "" : AC_RenderIndexReadTextFile(path, 300000);
   if(text == "") return 0;
   string lines[];
   ushort sep = StringGetCharacter("\n", 0);
   int count = StringSplit(text, sep, lines);
   int rows = 0;
   for(int i = 1; i < count; i++)
   {
      string line = lines[i];
      StringReplace(line, "\r", "");
      StringTrimLeft(line);
      StringTrimRight(line);
      if(line == "") continue;
      AC_RenderIndexRow row;
      row.symbol = AC_RenderIndexCsvField(line, 0, "");
      row.layer_id = (int)StringToInteger(AC_RenderIndexCsvField(line, 1, "0"));
      row.rank_index = AC_RenderIndexCsvField(line, 2, "not_available");
      row.score = AC_RenderIndexCsvField(line, 3, "not_available");
      row.bucket = AC_RenderIndexCsvField(line, 4, "not_available");
      row.rank_state = AC_RenderIndexCsvField(line, 5, "not_available");
      row.score_quality = AC_RenderIndexCsvField(line, 6, "not_available");
      row.rank_path = AC_RenderIndexCsvField(line, 7, "");
      row.rank_file_checksum = AC_RenderIndexCsvField(line, 8, "not_available");
      row.source_ranked_manifest_checksum = AC_RenderIndexCsvField(line, 9, "not_available");
      row.source_ranked_manifest_status = AC_RenderIndexCsvField(line, 10, "not_available");
      string authority = AC_RenderIndexCsvField(line, 12, "not_available");
      string trade_permission = AC_RenderIndexCsvField(line, 13, "not_available");
      string selection_runtime = AC_RenderIndexCsvField(line, 14, "not_available");
      string execution = AC_RenderIndexCsvField(line, 15, "not_available");
      if(row.symbol == "" || row.layer_id != layer_id) continue;
      if(authority != AC_EXTERNAL_WORKER_AUTHORITY || trade_permission != "false" || selection_runtime != "false" || execution != "false") continue;
      AC_RenderIndexAppendRow(row);
      rows++;
   }
   return rows;
}

int AC_RenderIndexLoadOhlcCsv()
{
   string text = AC_RenderIndexReadTextFile(AC_RenderIndexOhlcCsvPath(), 300000);
   if(text == "") return 0;
   string lines[];
   ushort sep = StringGetCharacter("\n", 0);
   int count = StringSplit(text, sep, lines);
   int rows = 0;
   for(int i = 1; i < count; i++)
   {
      string line = lines[i];
      StringReplace(line, "\r", "");
      StringTrimLeft(line);
      StringTrimRight(line);
      if(line == "") continue;
      string authority = AC_RenderIndexCsvField(line, 8, "not_available");
      string trade_permission = AC_RenderIndexCsvField(line, 9, "not_available");
      string selection_runtime = AC_RenderIndexCsvField(line, 10, "not_available");
      string execution = AC_RenderIndexCsvField(line, 11, "not_available");
      if(authority != AC_EXTERNAL_WORKER_AUTHORITY || trade_permission != "false" || selection_runtime != "false" || execution != "false") continue;
      AC_OhlcReadinessIndexRow row;
      row.symbol = AC_RenderIndexCsvField(line, 0, "");
      if(row.symbol == "") continue;
      row.m5_ready = AC_RenderIndexBoolField(AC_RenderIndexCsvField(line, 1, "false"));
      row.m15_ready = AC_RenderIndexBoolField(AC_RenderIndexCsvField(line, 2, "false"));
      row.h1_ready = AC_RenderIndexBoolField(AC_RenderIndexCsvField(line, 3, "false"));
      row.h4_ready = AC_RenderIndexBoolField(AC_RenderIndexCsvField(line, 4, "false"));
      row.d1_ready = AC_RenderIndexBoolField(AC_RenderIndexCsvField(line, 5, "false"));
      row.l8_min_ready = AC_RenderIndexBoolField(AC_RenderIndexCsvField(line, 6, "false"));
      row.l9_required_ready = AC_RenderIndexBoolField(AC_RenderIndexCsvField(line, 7, "false"));
      AC_RenderIndexAppendOhlcRow(row);
      rows++;
   }
   return rows;
}

void AC_RenderIndexRefresh()
{
   if(AC_RENDER_INDEX_LAST_REFRESH_HEARTBEAT_ID == AC_HEARTBEAT_ID) return;
   AC_RENDER_INDEX_LAST_REFRESH_HEARTBEAT_ID = AC_HEARTBEAT_ID;
   AC_RENDER_INDEX_ACCEPTED = false;
   AC_RENDER_INDEX_STATUS = "missing";
   AC_RENDER_INDEX_REASON = "render_index.manifest missing or unreadable";
   AC_RENDER_INDEX_MANIFEST_CHECKSUM = "not_available";
   AC_RENDER_INDEX_L6_ROWS = 0;
   AC_RENDER_INDEX_L7_ROWS = 0;
   AC_RENDER_INDEX_L8_ROWS = 0;
   AC_RENDER_INDEX_L9_ROWS = 0;
   AC_RENDER_INDEX_OHLC_ROWS = 0;
   ArrayResize(AC_RENDER_INDEX_ROWS, 0);
   ArrayResize(AC_RENDER_INDEX_OHLC_ROWS_DATA, 0);

   string manifest = AC_RenderIndexReadTextFile(AC_RenderIndexManifestPath(), 60000);
   if(manifest == "") return;
   string authority = AC_RenderIndexKvValue(manifest, "authority", "not_available");
   string trade_permission = AC_RenderIndexKvValue(manifest, "trade_permission", "not_available");
   string selection_runtime = AC_RenderIndexKvValue(manifest, "selection_runtime", "not_available");
   string execution = AC_RenderIndexKvValue(manifest, "execution", "not_available");
   string layers = AC_RenderIndexKvValue(manifest, "layers_included", "");
   if(authority != AC_EXTERNAL_WORKER_AUTHORITY || trade_permission != "false" || selection_runtime != "false" || execution != "false")
   {
      AC_RENDER_INDEX_STATUS = "rejected";
      AC_RENDER_INDEX_REASON = "manifest authority/permission boundary rejected";
      return;
   }
   if(StringFind(layers, "L6") < 0 || StringFind(layers, "L7") < 0 || StringFind(layers, "L8") < 0 || StringFind(layers, "L9") < 0)
   {
      AC_RENDER_INDEX_STATUS = "rejected";
      AC_RENDER_INDEX_REASON = "manifest does not include L6-L9";
      return;
   }

   AC_RENDER_INDEX_L6_ROWS = AC_RenderIndexLoadLayerCsv(6);
   AC_RENDER_INDEX_L7_ROWS = AC_RenderIndexLoadLayerCsv(7);
   AC_RENDER_INDEX_L8_ROWS = AC_RenderIndexLoadLayerCsv(8);
   AC_RENDER_INDEX_L9_ROWS = AC_RenderIndexLoadLayerCsv(9);
   AC_RENDER_INDEX_OHLC_ROWS = AC_RenderIndexLoadOhlcCsv();
   AC_RENDER_INDEX_STATUS = AC_RenderIndexKvValue(manifest, "status", "loaded");
   AC_RENDER_INDEX_REASON = AC_RenderIndexKvValue(manifest, "reason", "loaded");
   AC_RENDER_INDEX_MANIFEST_CHECKSUM = AC_ExternalWorkerPayloadChecksum(manifest);
   AC_RENDER_INDEX_ACCEPTED = (AC_RENDER_INDEX_L6_ROWS + AC_RENDER_INDEX_L7_ROWS + AC_RENDER_INDEX_L8_ROWS + AC_RENDER_INDEX_L9_ROWS) > 0;
}

bool AC_RenderIndexLookup(const int layer_id, const string symbol, AC_RenderIndexRow &row)
{
   AC_RenderIndexRefresh();
   if(!AC_RENDER_INDEX_ACCEPTED) return false;
   int total = ArraySize(AC_RENDER_INDEX_ROWS);
   for(int i = 0; i < total; i++)
   {
      if(AC_RENDER_INDEX_ROWS[i].layer_id == layer_id && AC_RENDER_INDEX_ROWS[i].symbol == symbol)
      {
         row = AC_RENDER_INDEX_ROWS[i];
         return true;
      }
   }
   return false;
}

bool AC_RenderIndexLookupOhlc(const string symbol, AC_OhlcReadinessIndexRow &row)
{
   AC_RenderIndexRefresh();
   if(!AC_RENDER_INDEX_ACCEPTED) return false;
   int total = ArraySize(AC_RENDER_INDEX_OHLC_ROWS_DATA);
   for(int i = 0; i < total; i++)
   {
      if(AC_RENDER_INDEX_OHLC_ROWS_DATA[i].symbol == symbol)
      {
         row = AC_RENDER_INDEX_OHLC_ROWS_DATA[i];
         return true;
      }
   }
   return false;
}

#endif