#ifndef AC_EXTERNAL_WORKER_SNAPSHOT_MQH
#define AC_EXTERNAL_WORKER_SNAPSHOT_MQH

static string AC_EXTERNAL_WORKER_LAST_SNAPSHOT_ID = "not_exported";
static string AC_EXTERNAL_WORKER_LAST_SNAPSHOT_STATUS = "not_exported";
static string AC_EXTERNAL_WORKER_LAST_SNAPSHOT_MANIFEST_STATUS = "not_exported";
static string AC_EXTERNAL_WORKER_LAST_SNAPSHOT_PAYLOAD_CHECKSUM = "not_available";
static ulong  AC_EXTERNAL_WORKER_LAST_SNAPSHOT_SIZE = 0;
static int    AC_EXTERNAL_WORKER_LAST_SNAPSHOT_ROWS = 0;

string AC_ExternalWorkerSnapshotId()
{
   return AC_AccountForRoute() + "_" + IntegerToString((int)TimeCurrent()) + "_" + IntegerToString((int)GetTickCount());
}

string AC_ExternalWorkerPayloadChecksum(const string payload)
{
   long checksum = 0;
   int len = StringLen(payload);
   for(int i = 0; i < len; i++)
   {
      ushort ch = StringGetCharacter(payload, i);
      checksum = (checksum + ((long)ch * (long)(i + 1))) % 2147483647;
   }
   return IntegerToString((int)checksum);
}

string AC_ExternalWorkerSnapshotHeader(const string snapshot_id, const int rows, const string payload_checksum)
{
   string text = "";
   text += "schema_name=aurora_external_worker_snapshot\r\n";
   text += "schema_version=1\r\n";
   text += "snapshot_id=" + snapshot_id + "\r\n";
   text += "system_name=" + AC_SYSTEM_NAME + "\r\n";
   text += "build_version=" + AC_BUILD_VERSION + "\r\n";
   text += "upgrade_id=" + AC_UPGRADE_ID + "\r\n";
   text += "source_owner=MT5_Runtime_1_and_Runtime_3\r\n";
   text += "worker_owner=" + AC_RUNTIME3_OWNER + "\r\n";
   text += "authority=" + AC_EXTERNAL_WORKER_AUTHORITY + "\r\n";
   text += "server=" + AC_ServerNameForRoute() + "\r\n";
   text += "account=" + AC_AccountForRoute() + "\r\n";
   text += "source_layers=L1,L2,L3,L4\r\n";
   text += "future_layer_5_status=not_implemented_yet\r\n";
   text += "row_count=" + IntegerToString(rows) + "\r\n";
   text += "payload_checksum=" + payload_checksum + "\r\n";
   text += "snapshot_complete=true\r\n";
   text += "trade_permission=false\r\n";
   text += "ranking_runtime=false\r\n";
   text += "selection_runtime=false\r\n\r\n";
   return text;
}

string AC_ExternalWorkerSnapshotRows()
{
   string text = "symbol|market_state|l3_ready|l4_ready|quote_quality|surface_quality|bid|ask|spread_points|spread_bps|daily_change_pct|tick_age_seconds|trade_permission\r\n";
   int total = SymbolsTotal(false);
   int rows = 0;
   for(int idx = 0; idx < total; idx++)
   {
      string symbol = SymbolName(idx, false);
      if(symbol == "") continue;
      string market_state = AC_L2MarketStateForSymbol(symbol);
      int l4_index = AC_L4FindIndex(symbol);
      string quote_quality = "not_available";
      string surface_quality = "not_available";
      double bid = 0.0;
      double ask = 0.0;
      double spread_points = 0.0;
      double spread_bps = 0.0;
      double daily_change_pct = 0.0;
      double tick_age_seconds = 0.0;
      if(l4_index >= 0)
      {
         quote_quality = AC_L4_SYMBOLS[l4_index].quote_quality;
         surface_quality = AC_L4_SYMBOLS[l4_index].surface_quality;
         bid = AC_L4_SYMBOLS[l4_index].bid;
         ask = AC_L4_SYMBOLS[l4_index].ask;
         spread_points = AC_L4_SYMBOLS[l4_index].spread_points_live;
         spread_bps = AC_L4_SYMBOLS[l4_index].spread_bps_live;
         daily_change_pct = AC_L4_SYMBOLS[l4_index].daily_change_pct;
         tick_age_seconds = AC_L4_SYMBOLS[l4_index].tick_age_seconds;
      }
      text += symbol + "|" + market_state + "|" + (AC_L3_READY ? "true" : "false") + "|" + (l4_index >= 0 ? "true" : "false") + "|" + quote_quality + "|" + surface_quality + "|" + DoubleToString(bid, 8) + "|" + DoubleToString(ask, 8) + "|" + DoubleToString(spread_points, 2) + "|" + DoubleToString(spread_bps, 4) + "|" + DoubleToString(daily_change_pct, 4) + "|" + DoubleToString(tick_age_seconds, 1) + "|false\r\n";
      rows++;
   }
   AC_EXTERNAL_WORKER_LAST_SNAPSHOT_ROWS = rows;
   return text;
}

AC_WriteResult AC_ExportExternalWorkerSnapshot()
{
   string snapshot_id = AC_ExternalWorkerSnapshotId();
   string rows = AC_ExternalWorkerSnapshotRows();
   string payload_checksum = AC_ExternalWorkerPayloadChecksum(rows);
   string snapshot = AC_ExternalWorkerSnapshotHeader(snapshot_id, AC_EXTERNAL_WORKER_LAST_SNAPSHOT_ROWS, payload_checksum) + rows;
   AC_WriteResult snapshot_write = AC_WriteTextFile(AC_ExternalWorkerSnapshotPath(), snapshot);
   string manifest = "schema_name=aurora_external_worker_snapshot_manifest\r\nschema_version=1\r\nsnapshot_id=" + snapshot_id + "\r\nwrite_status=" + snapshot_write.status + "\r\nwrite_ok=" + (snapshot_write.ok ? "true" : "false") + "\r\nrow_count=" + IntegerToString(AC_EXTERNAL_WORKER_LAST_SNAPSHOT_ROWS) + "\r\npayload_checksum=" + payload_checksum + "\r\nauthority=" + AC_EXTERNAL_WORKER_AUTHORITY + "\r\ntrade_permission=false\r\n";
   AC_WriteResult manifest_write = AC_WriteTextFile(AC_ExternalWorkerSnapshotManifestPath(), manifest);
   AC_EXTERNAL_WORKER_LAST_SNAPSHOT_ID = snapshot_id;
   AC_EXTERNAL_WORKER_LAST_SNAPSHOT_STATUS = snapshot_write.status;
   AC_EXTERNAL_WORKER_LAST_SNAPSHOT_MANIFEST_STATUS = manifest_write.status;
   AC_EXTERNAL_WORKER_LAST_SNAPSHOT_PAYLOAD_CHECKSUM = payload_checksum;
   AC_EXTERNAL_WORKER_LAST_SNAPSHOT_SIZE = snapshot_write.final_size;
   return snapshot_write;
}

#endif
