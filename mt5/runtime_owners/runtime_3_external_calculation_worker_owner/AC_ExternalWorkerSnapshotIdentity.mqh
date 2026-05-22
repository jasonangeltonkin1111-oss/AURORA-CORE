#ifndef AC_EXTERNAL_WORKER_SNAPSHOT_IDENTITY_MQH
#define AC_EXTERNAL_WORKER_SNAPSHOT_IDENTITY_MQH

static string AC_EXTERNAL_WORKER_LAST_SNAPSHOT_ID = "not_exported";
static string AC_EXTERNAL_WORKER_LAST_SNAPSHOT_STATUS = "not_exported";
static string AC_EXTERNAL_WORKER_LAST_SNAPSHOT_MANIFEST_STATUS = "not_exported";
static string AC_EXTERNAL_WORKER_LAST_SNAPSHOT_PAYLOAD_CHECKSUM = "not_available";
static string AC_EXTERNAL_WORKER_LAST_JOB_ID = "not_exported";
static string AC_EXTERNAL_WORKER_LAST_JOB_TYPE = "not_available";
static string AC_EXTERNAL_WORKER_LAST_JOB_STATUS = "not_exported";
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

string AC_ExternalWorkerJobId(const string snapshot_id)
{
   return snapshot_id + "_" + AC_EXTERNAL_WORKER_DEFAULT_JOB_TYPE;
}

#endif
