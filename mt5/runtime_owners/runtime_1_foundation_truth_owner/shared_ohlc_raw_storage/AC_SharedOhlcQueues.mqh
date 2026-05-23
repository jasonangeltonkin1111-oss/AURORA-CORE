#ifndef AC_SHARED_OHLC_QUEUES_MQH
#define AC_SHARED_OHLC_QUEUES_MQH

// Queue policy for Shared OHLC Raw Storage.
// This module decides storage refresh order only. It must not filter, score, rank, select, or permit symbols.

static int AC_SHARED_OHLC_SEED_SYMBOL_INDEX = 0;
static int AC_SHARED_OHLC_SEED_TIMEFRAME_INDEX = 0;
static int AC_SHARED_OHLC_APPEND_PRIORITY_CURSOR = AC_SHARED_OHLC_PRIORITY_OPEN_OR_PENDING;

void AC_SharedOhlcResetSeedQueue()
{
   AC_SHARED_OHLC_SEED_SYMBOL_INDEX = 0;
   AC_SHARED_OHLC_SEED_TIMEFRAME_INDEX = 0;
   AC_SHARED_OHLC_BOOT_SEED_COMPLETE = false;
   AC_SHARED_OHLC_APPEND_MODE_ACTIVE = false;
   AC_SHARED_OHLC_MODE = "boot_seed_pending";
}

bool AC_SharedOhlcSeedQueueDone()
{
   return (AC_SHARED_OHLC_SYMBOL_TF_TOTAL > 0 && AC_SHARED_OHLC_SYMBOL_TF_PENDING <= 0);
}

void AC_SharedOhlcMarkSeedResult(const AC_SharedOhlcSymbolTfStatus &status)
{
   if(status.storage_status == "seed_complete")
      AC_SHARED_OHLC_SYMBOL_TF_SEEDED++;
   else if(status.storage_status == "seed_partial")
      AC_SHARED_OHLC_SYMBOL_TF_PARTIAL++;
   else
      AC_SHARED_OHLC_SYMBOL_TF_ERROR++;

   if(AC_SHARED_OHLC_SYMBOL_TF_PENDING > 0)
      AC_SHARED_OHLC_SYMBOL_TF_PENDING--;

   AC_SHARED_OHLC_LAST_SYMBOL = status.symbol;
   AC_SHARED_OHLC_LAST_TIMEFRAME = status.timeframe_label;
   AC_SHARED_OHLC_LAST_BAR_TIME_SEEN = status.newest_closed_bar_time;
}

void AC_SharedOhlcActivateAppendModeIfReady()
{
   if(!AC_SharedOhlcSeedQueueDone())
      return;

   AC_SHARED_OHLC_BOOT_SEED_COMPLETE = true;
   AC_SHARED_OHLC_APPEND_MODE_ACTIVE = true;
   AC_SHARED_OHLC_STATUS = "append_mode_active";
   AC_SHARED_OHLC_MODE = "append_only_priority_refresh";
}

void AC_SharedOhlcResetAppendBacklogCounters()
{
   AC_SHARED_OHLC_APPEND_BACKLOG_P1 = 0;
   AC_SHARED_OHLC_APPEND_BACKLOG_P2 = 0;
   AC_SHARED_OHLC_APPEND_BACKLOG_P3 = 0;
   AC_SHARED_OHLC_APPEND_BACKLOG_P4 = 0;
   AC_SHARED_OHLC_APPEND_BACKLOG_P5 = 0;
}

void AC_SharedOhlcBuildPriorityBacklogSnapshot()
{
   AC_SharedOhlcResetAppendBacklogCounters();
   int total = SymbolsTotal(true);
   for(int i = 0; i < total; i++)
   {
      string symbol = SymbolName(i, true);
      int priority = AC_SharedOhlcPriorityForSymbol(symbol);
      AC_SharedOhlcAddPriorityBacklog(priority);
   }
}

#endif
