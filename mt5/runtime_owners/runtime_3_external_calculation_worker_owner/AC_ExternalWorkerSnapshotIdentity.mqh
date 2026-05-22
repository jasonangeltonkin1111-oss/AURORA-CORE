#ifndef AC_EXTERNAL_WORKER_SNAPSHOT_IDENTITY_MQH
#define AC_EXTERNAL_WORKER_SNAPSHOT_IDENTITY_MQH

static string AC_EXTERNAL_WORKER_LAST_SNAPSHOT_ID = "not_exported";
static string AC_EXTERNAL_WORKER_LAST_SNAPSHOT_STATUS = "not_exported";
static string AC_EXTERNAL_WORKER_LAST_SNAPSHOT_MANIFEST_STATUS = "not_exported";
static string AC_EXTERNAL_WORKER_LAST_SNAPSHOT_PAYLOAD_CHECKSUM = "not_available";
static string AC_EXTERNAL_WORKER_LAST_SNAPSHOT_UPSTREAM_KEY = "not_exported";
static string AC_EXTERNAL_WORKER_LAST_JOB_ID = "not_exported";
static string AC_EXTERNAL_WORKER_LAST_JOB_TYPE = "not_available";
static string AC_EXTERNAL_WORKER_LAST_JOB_STATUS = "not_exported";
static ulong  AC_EXTERNAL_WORKER_LAST_SNAPSHOT_SIZE = 0;
static int    AC_EXTERNAL_WORKER_LAST_SNAPSHOT_ROWS = 0;

string AC_ExternalWorkerSnapshotId()
{
   return AC_AccountForRoute() + "_" + IntegerToString((int)TimeCurrent()) + "_" + IntegerToString((int)GetTickCount());
}

string AC_ExternalWorkerSnapshotUpstreamKey()
{
   return "symbols_total=" + IntegerToString(SymbolsTotal(false))
      + "|l2_route=" + AC_L2_ROUTE_GENERATION_KEY
      + "|l3_cache=" + AC_L3_CACHE_KEY
      + "|l4_cache=" + AC_L4_CACHE_KEY
      + "|l4_refresh=" + AC_L4_REFRESH_KEY
      + "|l5_upstream=" + AC_L5UpstreamKey()
      + "|l5_pass=" + IntegerToString(AC_L5_GATE_PASS)
      + "|l6_input=" + AC_L6_LAST_INPUT_UPSTREAM_KEY
      + "|l6_checksum=" + AC_L6_LAST_INPUT_PAYLOAD_CHECKSUM
      + "|l7_input=" + AC_L7_LAST_INPUT_UPSTREAM_KEY
      + "|l7_rows=" + IntegerToString(AC_L7_LAST_INPUT_ROWS);
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

string AC_ExternalWorkerJobId(const string snapshot_id)
{
   return snapshot_id + "_" + AC_EXTERNAL_WORKER_DEFAULT_JOB_TYPE;
}

#endif