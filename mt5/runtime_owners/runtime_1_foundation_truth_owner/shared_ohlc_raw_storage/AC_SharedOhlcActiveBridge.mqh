#ifndef AC_SHARED_OHLC_ACTIVE_BRIDGE_MQH
#define AC_SHARED_OHLC_ACTIVE_BRIDGE_MQH

// Runtime 1 Shared OHLC Raw Storage Owner - active bridge.
// Raw CopyRates/MqlRates storage only.
// No calculations, no ranking, no selection, no trade permission, no execution.
// Performance law: P1 is serviced fastest; P5 is serviced slowest; partial/error seeds are retried for eventual 1500-bar completion when broker history becomes available.

static string AC_SHARED_OHLC_STATUS = "seed_active";
static string AC_SHARED_OHLC_MODE = "priority_window_then_full_seed_then_topup_append";
static bool   AC_SHARED_OHLC_BOOT_SEED_COMPLETE = false;
static bool   AC_SHARED_OHLC_PRIORITY_WINDOW_COMPLETE = false;
static int    AC_SHARED_OHLC_TIMEFRAMES_ENABLED = 8;
static int    AC_SHARED_OHLC_TARGET_SEED_BARS = 1500;
static int    AC_SHARED_OHLC_SYMBOLS_TOTAL = 0;
static int    AC_SHARED_OHLC_SYMBOL_TF_TOTAL = 0;
static int    AC_SHARED_OHLC_SYMBOL_TF_SEEDED = 0;
static int    AC_SHARED_OHLC_SYMBOL_TF_PARTIAL = 0;
static int    AC_SHARED_OHLC_SYMBOL_TF_ERROR = 0;
static int    AC_SHARED_OHLC_SYMBOL_TF_ATTEMPTED = 0;
static int    AC_SHARED_OHLC_SYMBOL_TF_PENDING = 0;
static int    AC_SHARED_OHLC_WINDOW_TOTAL = 0;
static int    AC_SHARED_OHLC_WINDOW_ATTEMPTED = 0;
static int    AC_SHARED_OHLC_WINDOW_READY = 0;
static int    AC_SHARED_OHLC_WINDOW_PARTIAL = 0;
static int    AC_SHARED_OHLC_WINDOW_ERROR = 0;
static int    AC_SHARED_OHLC_WINDOW_M5_READY = 0;
static int    AC_SHARED_OHLC_WINDOW_M15_READY = 0;
static int    AC_SHARED_OHLC_WINDOW_H1_READY = 0;
static int    AC_SHARED_OHLC_WINDOW_H4_READY = 0;
static int    AC_SHARED_OHLC_WINDOW_P1_ATTEMPTED = 0;
static int    AC_SHARED_OHLC_WINDOW_P2_ATTEMPTED = 0;
static int    AC_SHARED_OHLC_WINDOW_P3_ATTEMPTED = 0;
static int    AC_SHARED_OHLC_WINDOW_P4_ATTEMPTED = 0;
static int    AC_SHARED_OHLC_P1_ATTEMPTED = 0;
static int    AC_SHARED_OHLC_P2_ATTEMPTED = 0;
static int    AC_SHARED_OHLC_P3_ATTEMPTED = 0;
static int    AC_SHARED_OHLC_P4_ATTEMPTED = 0;
static int    AC_SHARED_OHLC_P5_ATTEMPTED = 0;
static int    AC_SHARED_OHLC_APPEND_WRITTEN = 0;
static int    AC_SHARED_OHLC_APPEND_SKIPPED_DUPLICATE = 0;
static int    AC_SHARED_OHLC_APPEND_ERROR = 0;
static int    AC_SHARED_OHLC_APPEND_BACKLOG_P1 = 0;
static int    AC_SHARED_OHLC_APPEND_BACKLOG_P2 = 0;
static int    AC_SHARED_OHLC_APPEND_BACKLOG_P3 = 0;
static int    AC_SHARED_OHLC_APPEND_BACKLOG_P4 = 0;
static int    AC_SHARED_OHLC_APPEND_BACKLOG_P5 = 0;
static int    AC_SHARED_OHLC_SEED_P1_INDEX = 0;
static int    AC_SHARED_OHLC_SEED_P2_INDEX = 0;
static int    AC_SHARED_OHLC_SEED_P3_INDEX = 0;
static int    AC_SHARED_OHLC_SEED_P4_INDEX = 0;
static int    AC_SHARED_OHLC_SEED_P5_INDEX = 0;
static int    AC_SHARED_OHLC_WINDOW_P1_INDEX = 0;
static int    AC_SHARED_OHLC_WINDOW_P2_INDEX = 0;
static int    AC_SHARED_OHLC_WINDOW_P3_INDEX = 0;
static int    AC_SHARED_OHLC_WINDOW_P4_INDEX = 0;
static int    AC_SHARED_OHLC_APPEND_P1_INDEX = 0;
static int    AC_SHARED_OHLC_APPEND_P2_INDEX = 0;
static int    AC_SHARED_OHLC_APPEND_P3_INDEX = 0;
static int    AC_SHARED_OHLC_APPEND_P4_INDEX = 0;
static int    AC_SHARED_OHLC_APPEND_P5_INDEX = 0;
static int    AC_SHARED_OHLC_TOPUP_P1_INDEX = 0;
static int    AC_SHARED_OHLC_TOPUP_P2_INDEX = 0;
static int    AC_SHARED_OHLC_TOPUP_P3_INDEX = 0;
static int    AC_SHARED_OHLC_TOPUP_P4_INDEX = 0;
static int    AC_SHARED_OHLC_TOPUP_P5_INDEX = 0;
static int    AC_SHARED_OHLC_TOPUP_ATTEMPTED = 0;
static int    AC_SHARED_OHLC_TOPUP_IMPROVED = 0;
static int    AC_SHARED_OHLC_TOPUP_STILL_PARTIAL = 0;
static int    AC_SHARED_OHLC_TOPUP_SKIPPED_COMPLETE = 0;
static int    AC_SHARED_OHLC_TOPUP_ERROR = 0;
static string AC_SHARED_OHLC_ROUTE_STATUS = "not_attempted";
static string AC_SHARED_OHLC_STATUS_WRITE = "not_attempted";
static string AC_SHARED_OHLC_MANIFEST_WRITE = "not_attempted";
static string AC_SHARED_OHLC_LAST_SYMBOL = "";
static string AC_SHARED_OHLC_LAST_TF = "";
static string AC_SHARED_OHLC_LAST_TASK_STATUS = "not_started";
static string AC_SHARED_OHLC_LAST_PRIORITY_LABEL = "none";
static int    AC_SHARED_OHLC_LAST_PRIORITY = 0;
static uint   AC_SHARED_OHLC_LAST_SERVICE_MS = 0;
static int    AC_SHARED_OHLC_TASKS_PER_SERVICE = 2;
static uint   AC_SHARED_OHLC_SERVICE_BUDGET_MS = 120;
static uint   AC_SHARED_OHLC_SERVICE_INTERVAL_MS = 500;
static uint   AC_SHARED_OHLC_LAST_RUN_TICK = 0;
static string AC_SHARED_OHLC_ADAPTIVE_MODE = "normal";
static int    AC_SHARED_OHLC_FAST_STREAK = 0;
static int    AC_SHARED_OHLC_COOLDOWN_RUNS = 0;
static int    AC_SHARED_OHLC_SERVICE_TASKS_USED = 0;
static int    AC_SHARED_OHLC_SEED_SKIPPED_EXISTING = 0;

string AC_SharedOhlcServerFolder(){ return AC_BASE_FOLDER + "\\" + AC_ServerNameForRoute(); }
string AC_SharedOhlcMarketDataFolder(){ return AC_SharedOhlcServerFolder() + "\\Shared Market Data"; }
string AC_SharedOhlcRootFolder(){ return AC_SharedOhlcMarketDataFolder() + "\\OHLC Store"; }
string AC_SharedOhlcStatusFolder(){ return AC_SharedOhlcRootFolder() + "\\Status"; }
string AC_SharedOhlcSymbolsFolder(){ return AC_SharedOhlcRootFolder() + "\\Symbols"; }
string AC_SharedOhlcStatusPath(){ return AC_SharedOhlcStatusFolder() + "\\status.txt"; }
string AC_SharedOhlcManifestPath(){ return AC_SharedOhlcStatusFolder() + "\\manifest.txt"; }
string AC_SharedOhlcSymbolFolder(const string s){ return AC_SharedOhlcSymbolsFolder() + "\\" + AC_SanitizePathPart(s); }
string AC_SharedOhlcCurrentFolder(const string s){ return AC_SharedOhlcSymbolFolder(s) + "\\Current"; }
string AC_SharedOhlcStateFolder(const string s){ return AC_SharedOhlcSymbolFolder(s) + "\\State"; }
string AC_SharedOhlcWindowFolder(const string s){ return AC_SharedOhlcSymbolFolder(s) + "\\Priority Windows"; }
string AC_SharedOhlcSeedPath(const string s,const string tf){ return AC_SharedOhlcSymbolFolder(s)+"\\"+tf+".seed.csv"; }
string AC_SharedOhlcAppendPath(const string s,const string tf){ return AC_SharedOhlcSymbolFolder(s)+"\\"+tf+".append.csv"; }
string AC_SharedOhlcFastWindowPath(const string s,const string tf){ return AC_SharedOhlcWindowFolder(s)+"\\"+tf+".window.csv"; }
string AC_SharedOhlcCurrentPath(const string s,const string tf){ return AC_SharedOhlcCurrentFolder(s)+"\\"+tf+".current.csv"; }
string AC_SharedOhlcLastTimePath(const string s,const string tf){ return AC_SharedOhlcStateFolder(s)+"\\"+tf+".last_time.txt"; }
string AC_SharedOhlcSeedCountPath(const string s,const string tf){ return AC_SharedOhlcStateFolder(s)+"\\"+tf+".seed_count.txt"; }

string AC_SharedOhlcTfLabel(const int i){ if(i==0)return "M1"; if(i==1)return "M5"; if(i==2)return "M15"; if(i==3)return "M30"; if(i==4)return "H1"; if(i==5)return "H4"; if(i==6)return "D1"; return "W1"; }
ENUM_TIMEFRAMES AC_SharedOhlcTfEnum(const int i){ if(i==0)return PERIOD_M1; if(i==1)return PERIOD_M5; if(i==2)return PERIOD_M15; if(i==3)return PERIOD_M30; if(i==4)return PERIOD_H1; if(i==5)return PERIOD_H4; if(i==6)return PERIOD_D1; return PERIOD_W1; }
string AC_SharedOhlcWindowTfLabel(const int i){ if(i==0)return "M5"; if(i==1)return "M15"; if(i==2)return "H1"; return "H4"; }
ENUM_TIMEFRAMES AC_SharedOhlcWindowTfEnum(const int i){ if(i==0)return PERIOD_M5; if(i==1)return PERIOD_M15; if(i==2)return PERIOD_H1; return PERIOD_H4; }
int AC_SharedOhlcWindowBars(const int i){ if(i==0)return 64; if(i==1)return 80; if(i==2)return 80; return 42; }
int AC_SharedOhlcWindowTfCount(){ return 4; }

string AC_SharedOhlcPriorityLabel(const int p)
{
   if(p==1)return "P1_open_positions_or_pending_orders";
   if(p==2)return "P2_layer5_pass_symbols";
   if(p==3)return "P3_future_candidate_ranked_selected_reserved";
   if(p==4)return "P4_other_open_symbols";
   return "P5_closed_blocked_unknown_low_priority";
}

long AC_SharedOhlcPricePoints(const string s,const double p){ double pt=SymbolInfoDouble(s,SYMBOL_POINT); if(pt<=0.0)return 0; return (long)MathRound(p/pt); }
string AC_SharedOhlcHeader(const string s,const string tf){ return "#schema=shared_ohlc_raw_v1\r\n#owner=Runtime 1 Shared OHLC Raw Storage Owner\r\n#symbol="+s+"\r\n#timeframe="+tf+"\r\n#price_encoding=integer_points\r\nbar_time,open_i,high_i,low_i,close_i,tick_volume,spread,real_volume\r\n"; }
string AC_SharedOhlcRow(const string s,const MqlRates &r){ return IntegerToString((long)r.time)+","+IntegerToString(AC_SharedOhlcPricePoints(s,r.open))+","+IntegerToString(AC_SharedOhlcPricePoints(s,r.high))+","+IntegerToString(AC_SharedOhlcPricePoints(s,r.low))+","+IntegerToString(AC_SharedOhlcPricePoints(s,r.close))+","+IntegerToString((long)r.tick_volume)+","+IntegerToString(r.spread)+","+IntegerToString((long)r.real_volume); }

bool AC_SharedOhlcEnsureRouteOnly()
{
   string d=""; bool ok=true;
   ok=AC_EnsureFolderPath(AC_SharedOhlcMarketDataFolder(),d)&&ok;
   ok=AC_EnsureFolderPath(AC_SharedOhlcRootFolder(),d)&&ok;
   ok=AC_EnsureFolderPath(AC_SharedOhlcStatusFolder(),d)&&ok;
   ok=AC_EnsureFolderPath(AC_SharedOhlcSymbolsFolder(),d)&&ok;
   AC_SHARED_OHLC_ROUTE_STATUS=ok?"folder_create_ok":"folder_create_degraded";
   return ok;
}

bool AC_SharedOhlcEnsureSymbolFolders(const string s)
{
   string d=""; bool ok=true;
   ok=AC_EnsureFolderPath(AC_SharedOhlcSymbolFolder(s),d)&&ok;
   ok=AC_EnsureFolderPath(AC_SharedOhlcCurrentFolder(s),d)&&ok;
   ok=AC_EnsureFolderPath(AC_SharedOhlcStateFolder(s),d)&&ok;
   ok=AC_EnsureFolderPath(AC_SharedOhlcWindowFolder(s),d)&&ok;
   return ok;
}

long AC_SharedOhlcReadLong(const string p)
{
   ResetLastError(); int h=FileOpen(p,AC_FileFlags()|FILE_READ); if(h==INVALID_HANDLE)return 0;
   string v=FileReadString(h); FileClose(h); return (long)StringToInteger(v);
}
void AC_SharedOhlcWriteLong(const string p,const long v){ AC_WriteTextFileFastAtomic(p,IntegerToString(v)); }
long AC_SharedOhlcReadLastTime(const string p){ return AC_SharedOhlcReadLong(p); }
void AC_SharedOhlcWriteLastTime(const string p,const datetime t){ AC_SharedOhlcWriteLong(p,(long)t); }

bool AC_SharedOhlcAppendLine(const string p,const string line,const string header)
{
   bool exists=FileIsExist(p,AC_CommonFlag());
   ResetLastError(); int h=FileOpen(p,AC_FileFlags()|FILE_READ|FILE_WRITE);
   if(h==INVALID_HANDLE)return false;
   FileSeek(h,0,SEEK_END); if(!exists) FileWriteString(h,header);
   FileWriteString(h,line+"\r\n"); FileFlush(h); FileClose(h); return true;
}

bool AC_SharedOhlcSymbolHasOpenPosition(const string s)
{
   for(int i=PositionsTotal()-1;i>=0;i--) if(PositionGetSymbol(i)==s) return true;
   return false;
}

bool AC_SharedOhlcSymbolHasPendingOrder(const string s)
{
   for(int i=OrdersTotal()-1;i>=0;i--){ ulong ticket=OrderGetTicket(i); if(ticket!=0 && OrderGetString(ORDER_SYMBOL)==s) return true; }
   return false;
}

bool AC_SharedOhlcSymbolL5PassFast(const string s)
{
   for(int i=0;i<ArraySize(AC_L5_SYMBOLS);i++) if(AC_L5_SYMBOLS[i].symbol==s) return AC_L5_SYMBOLS[i].pass;
   return false;
}

bool AC_SharedOhlcSymbolFutureCandidateReserved(const string s){ return false; }

int AC_SharedOhlcPriorityForSymbol(const string s)
{
   if(s=="") return 5;
   if(AC_SharedOhlcSymbolHasOpenPosition(s) || AC_SharedOhlcSymbolHasPendingOrder(s)) return 1;
   if(AC_SharedOhlcSymbolL5PassFast(s)) return 2;
   if(AC_SharedOhlcSymbolFutureCandidateReserved(s)) return 3;
   if(AC_L2MarketStateForSymbol(s)=="open") return 4;
   return 5;
}

int AC_SharedOhlcPrioritySymbolCount(const int priority)
{
   int total=SymbolsTotal(false), count=0;
   for(int i=0;i<total;i++){ string s=SymbolName(i,false); if(AC_SharedOhlcPriorityForSymbol(s)==priority) count++; }
   return count;
}

string AC_SharedOhlcSymbolByPriorityOrdinal(const int priority,const int ordinal)
{
   int total=SymbolsTotal(false), seen=0;
   for(int i=0;i<total;i++){ string s=SymbolName(i,false); if(AC_SharedOhlcPriorityForSymbol(s)!=priority) continue; if(seen==ordinal) return s; seen++; }
   return "";
}

void AC_SharedOhlcMarkPriorityAttempt(const int priority,const bool window_task)
{
   AC_SHARED_OHLC_LAST_PRIORITY=priority;
   AC_SHARED_OHLC_LAST_PRIORITY_LABEL=AC_SharedOhlcPriorityLabel(priority);
   if(window_task)
   {
      if(priority==1)AC_SHARED_OHLC_WINDOW_P1_ATTEMPTED++; else if(priority==2)AC_SHARED_OHLC_WINDOW_P2_ATTEMPTED++; else if(priority==3)AC_SHARED_OHLC_WINDOW_P3_ATTEMPTED++; else if(priority==4)AC_SHARED_OHLC_WINDOW_P4_ATTEMPTED++;
      return;
   }
   if(priority==1)AC_SHARED_OHLC_P1_ATTEMPTED++; else if(priority==2)AC_SHARED_OHLC_P2_ATTEMPTED++; else if(priority==3)AC_SHARED_OHLC_P3_ATTEMPTED++; else if(priority==4)AC_SHARED_OHLC_P4_ATTEMPTED++; else AC_SHARED_OHLC_P5_ATTEMPTED++;
}

int AC_SharedOhlcGetIndexForPriority(const int p,const bool append_mode)
{
   if(append_mode){ if(p==1)return AC_SHARED_OHLC_APPEND_P1_INDEX; if(p==2)return AC_SHARED_OHLC_APPEND_P2_INDEX; if(p==3)return AC_SHARED_OHLC_APPEND_P3_INDEX; if(p==4)return AC_SHARED_OHLC_APPEND_P4_INDEX; return AC_SHARED_OHLC_APPEND_P5_INDEX; }
   if(p==1)return AC_SHARED_OHLC_SEED_P1_INDEX; if(p==2)return AC_SHARED_OHLC_SEED_P2_INDEX; if(p==3)return AC_SHARED_OHLC_SEED_P3_INDEX; if(p==4)return AC_SHARED_OHLC_SEED_P4_INDEX; return AC_SHARED_OHLC_SEED_P5_INDEX;
}
void AC_SharedOhlcSetIndexForPriority(const int p,const bool append_mode,const int v)
{
   if(append_mode){ if(p==1)AC_SHARED_OHLC_APPEND_P1_INDEX=v; else if(p==2)AC_SHARED_OHLC_APPEND_P2_INDEX=v; else if(p==3)AC_SHARED_OHLC_APPEND_P3_INDEX=v; else if(p==4)AC_SHARED_OHLC_APPEND_P4_INDEX=v; else AC_SHARED_OHLC_APPEND_P5_INDEX=v; return; }
   if(p==1)AC_SHARED_OHLC_SEED_P1_INDEX=v; else if(p==2)AC_SHARED_OHLC_SEED_P2_INDEX=v; else if(p==3)AC_SHARED_OHLC_SEED_P3_INDEX=v; else if(p==4)AC_SHARED_OHLC_SEED_P4_INDEX=v; else AC_SHARED_OHLC_SEED_P5_INDEX=v;
}
int AC_SharedOhlcGetTopupIndexForPriority(const int p){ if(p==1)return AC_SHARED_OHLC_TOPUP_P1_INDEX; if(p==2)return AC_SHARED_OHLC_TOPUP_P2_INDEX; if(p==3)return AC_SHARED_OHLC_TOPUP_P3_INDEX; if(p==4)return AC_SHARED_OHLC_TOPUP_P4_INDEX; return AC_SHARED_OHLC_TOPUP_P5_INDEX; }
void AC_SharedOhlcSetTopupIndexForPriority(const int p,const int v){ if(p==1)AC_SHARED_OHLC_TOPUP_P1_INDEX=v; else if(p==2)AC_SHARED_OHLC_TOPUP_P2_INDEX=v; else if(p==3)AC_SHARED_OHLC_TOPUP_P3_INDEX=v; else if(p==4)AC_SHARED_OHLC_TOPUP_P4_INDEX=v; else AC_SHARED_OHLC_TOPUP_P5_INDEX=v; }
int AC_SharedOhlcGetWindowIndexForPriority(const int p){ if(p==1)return AC_SHARED_OHLC_WINDOW_P1_INDEX; if(p==2)return AC_SHARED_OHLC_WINDOW_P2_INDEX; if(p==3)return AC_SHARED_OHLC_WINDOW_P3_INDEX; return AC_SHARED_OHLC_WINDOW_P4_INDEX; }
void AC_SharedOhlcSetWindowIndexForPriority(const int p,const int v){ if(p==1)AC_SHARED_OHLC_WINDOW_P1_INDEX=v; else if(p==2)AC_SHARED_OHLC_WINDOW_P2_INDEX=v; else if(p==3)AC_SHARED_OHLC_WINDOW_P3_INDEX=v; else AC_SHARED_OHLC_WINDOW_P4_INDEX=v; }

void AC_SharedOhlcUpdateTotals()
{
   AC_SHARED_OHLC_SYMBOLS_TOTAL=SymbolsTotal(false);
   AC_SHARED_OHLC_SYMBOL_TF_TOTAL=AC_SHARED_OHLC_SYMBOLS_TOTAL*AC_SHARED_OHLC_TIMEFRAMES_ENABLED;
   AC_SHARED_OHLC_SYMBOL_TF_PENDING=AC_SHARED_OHLC_SYMBOL_TF_TOTAL-AC_SHARED_OHLC_SYMBOL_TF_ATTEMPTED; if(AC_SHARED_OHLC_SYMBOL_TF_PENDING<0)AC_SHARED_OHLC_SYMBOL_TF_PENDING=0;
   int p1=AC_SharedOhlcPrioritySymbolCount(1), p2=AC_SharedOhlcPrioritySymbolCount(2), p3=AC_SharedOhlcPrioritySymbolCount(3), p4=AC_SharedOhlcPrioritySymbolCount(4), p5=AC_SharedOhlcPrioritySymbolCount(5);
   AC_SHARED_OHLC_APPEND_BACKLOG_P1=p1*AC_SHARED_OHLC_TIMEFRAMES_ENABLED; AC_SHARED_OHLC_APPEND_BACKLOG_P2=p2*AC_SHARED_OHLC_TIMEFRAMES_ENABLED; AC_SHARED_OHLC_APPEND_BACKLOG_P3=p3*AC_SHARED_OHLC_TIMEFRAMES_ENABLED; AC_SHARED_OHLC_APPEND_BACKLOG_P4=p4*AC_SHARED_OHLC_TIMEFRAMES_ENABLED; AC_SHARED_OHLC_APPEND_BACKLOG_P5=p5*AC_SHARED_OHLC_TIMEFRAMES_ENABLED;
   AC_SHARED_OHLC_WINDOW_TOTAL=(p1+p2+p3+p4)*AC_SharedOhlcWindowTfCount();
}

bool AC_SharedOhlcSeedOne(const string s,const int tfi)
{
   string tf=AC_SharedOhlcTfLabel(tfi); ENUM_TIMEFRAMES e=AC_SharedOhlcTfEnum(tfi); AC_SHARED_OHLC_LAST_SYMBOL=s; AC_SHARED_OHLC_LAST_TF=tf; AC_SharedOhlcEnsureSymbolFolders(s);
   MqlRates rates[]; ResetLastError(); int copied=CopyRates(s,e,1,AC_SHARED_OHLC_TARGET_SEED_BARS,rates); AC_SHARED_OHLC_SYMBOL_TF_ATTEMPTED++;
   if(copied<=0){ AC_SHARED_OHLC_SYMBOL_TF_ERROR++; AC_SharedOhlcWriteLong(AC_SharedOhlcSeedCountPath(s,tf),0); AC_SHARED_OHLC_LAST_TASK_STATUS="seed_copyrates_unavailable_"+IntegerToString(GetLastError()); return false; }
   string text=AC_SharedOhlcHeader(s,tf); for(int i=0;i<copied;i++) text+=AC_SharedOhlcRow(s,rates[i])+"\r\n";
   AC_WriteResult wr=AC_WriteTextFileFastAtomic(AC_SharedOhlcSeedPath(s,tf),text); if(!wr.ok){ AC_SHARED_OHLC_SYMBOL_TF_ERROR++; AC_SHARED_OHLC_LAST_TASK_STATUS="seed_write_failed_"+wr.status; return false; }
   AC_SharedOhlcWriteLastTime(AC_SharedOhlcLastTimePath(s,tf),rates[copied-1].time); AC_SharedOhlcWriteLong(AC_SharedOhlcSeedCountPath(s,tf),copied);
   MqlRates cur[]; if(CopyRates(s,e,0,1,cur)>0) AC_WriteTextFileFastAtomic(AC_SharedOhlcCurrentPath(s,tf),AC_SharedOhlcHeader(s,tf)+AC_SharedOhlcRow(s,cur[0])+"\r\n");
   if(copied>=AC_SHARED_OHLC_TARGET_SEED_BARS){ AC_SHARED_OHLC_SYMBOL_TF_SEEDED++; AC_SHARED_OHLC_LAST_TASK_STATUS="seed_complete"; } else { AC_SHARED_OHLC_SYMBOL_TF_PARTIAL++; AC_SHARED_OHLC_LAST_TASK_STATUS="seed_partial_"+IntegerToString(copied); }
   return true;
}

bool AC_SharedOhlcSeedOneIfNeeded(const string s,const int tfi)
{
   string tf=AC_SharedOhlcTfLabel(tfi);
   AC_SHARED_OHLC_LAST_SYMBOL=s;
   AC_SHARED_OHLC_LAST_TF=tf;
   long old_count=AC_SharedOhlcReadLong(AC_SharedOhlcSeedCountPath(s,tf));
   if(old_count>=AC_SHARED_OHLC_TARGET_SEED_BARS && FileIsExist(AC_SharedOhlcSeedPath(s,tf),AC_CommonFlag()))
   {
      AC_SHARED_OHLC_SYMBOL_TF_ATTEMPTED++;
      AC_SHARED_OHLC_SYMBOL_TF_SEEDED++;
      AC_SHARED_OHLC_SEED_SKIPPED_EXISTING++;
      AC_SHARED_OHLC_LAST_TASK_STATUS="seed_skip_existing_complete_"+IntegerToString((int)old_count);
      return true;
   }
   return AC_SharedOhlcSeedOne(s,tfi);
}

bool AC_SharedOhlcSeedWindowForPriority(const int priority)
{
   int symbols=AC_SharedOhlcPrioritySymbolCount(priority); if(symbols<=0) return false;
   int index=AC_SharedOhlcGetWindowIndexForPriority(priority); int total_tasks=symbols*AC_SharedOhlcWindowTfCount(); if(index>=total_tasks) return false;
   int symbol_ordinal=index/AC_SharedOhlcWindowTfCount(); int tf_index=index%AC_SharedOhlcWindowTfCount(); string s=AC_SharedOhlcSymbolByPriorityOrdinal(priority,symbol_ordinal);
   AC_SharedOhlcSetWindowIndexForPriority(priority,index+1); if(s=="") return true;
   string tf=AC_SharedOhlcWindowTfLabel(tf_index); ENUM_TIMEFRAMES e=AC_SharedOhlcWindowTfEnum(tf_index); int target=AC_SharedOhlcWindowBars(tf_index);
   AC_SharedOhlcMarkPriorityAttempt(priority,true); AC_SHARED_OHLC_LAST_SYMBOL=s; AC_SHARED_OHLC_LAST_TF=tf; AC_SharedOhlcEnsureSymbolFolders(s);
   MqlRates rates[]; ResetLastError(); int copied=CopyRates(s,e,1,target,rates); AC_SHARED_OHLC_WINDOW_ATTEMPTED++;
   if(copied<=0){ AC_SHARED_OHLC_WINDOW_ERROR++; AC_SHARED_OHLC_LAST_TASK_STATUS="priority_window_"+AC_SHARED_OHLC_LAST_PRIORITY_LABEL+"_copyrates_unavailable_"+IntegerToString(GetLastError()); return false; }
   string text=AC_SharedOhlcHeader(s,tf); for(int i=0;i<copied;i++) text+=AC_SharedOhlcRow(s,rates[i])+"\r\n";
   AC_WriteResult wr=AC_WriteTextFileFastAtomic(AC_SharedOhlcFastWindowPath(s,tf),text);
   if(!wr.ok){ AC_SHARED_OHLC_WINDOW_ERROR++; AC_SHARED_OHLC_LAST_TASK_STATUS="priority_window_"+AC_SHARED_OHLC_LAST_PRIORITY_LABEL+"_write_failed_"+wr.status; return false; }
   if(copied>=target){ AC_SHARED_OHLC_WINDOW_READY++; if(tf=="M5")AC_SHARED_OHLC_WINDOW_M5_READY++; else if(tf=="M15")AC_SHARED_OHLC_WINDOW_M15_READY++; else if(tf=="H1")AC_SHARED_OHLC_WINDOW_H1_READY++; else if(tf=="H4")AC_SHARED_OHLC_WINDOW_H4_READY++; AC_SHARED_OHLC_LAST_TASK_STATUS="priority_window_"+AC_SHARED_OHLC_LAST_PRIORITY_LABEL+"_ready_"+IntegerToString(copied); }
   else { AC_SHARED_OHLC_WINDOW_PARTIAL++; AC_SHARED_OHLC_LAST_TASK_STATUS="priority_window_"+AC_SHARED_OHLC_LAST_PRIORITY_LABEL+"_partial_"+IntegerToString(copied)+"_of_"+IntegerToString(target); }
   return true;
}

bool AC_SharedOhlcSeedPriorityWindowOne()
{
   for(int p=1;p<=4;p++) if(AC_SharedOhlcSeedWindowForPriority(p)) return true;
   AC_SHARED_OHLC_PRIORITY_WINDOW_COMPLETE=true; AC_SHARED_OHLC_LAST_TASK_STATUS="priority_window_flow_complete"; return false;
}

bool AC_SharedOhlcSeedPriorityOne(const int priority)
{
   int symbols=AC_SharedOhlcPrioritySymbolCount(priority); if(symbols<=0) return false;
   int index=AC_SharedOhlcGetIndexForPriority(priority,false); int total_tasks=symbols*AC_SHARED_OHLC_TIMEFRAMES_ENABLED; if(index>=total_tasks) return false;
   int symbol_ordinal=index/AC_SHARED_OHLC_TIMEFRAMES_ENABLED; int tf_index=index%AC_SHARED_OHLC_TIMEFRAMES_ENABLED; string s=AC_SharedOhlcSymbolByPriorityOrdinal(priority,symbol_ordinal);
   AC_SharedOhlcSetIndexForPriority(priority,false,index+1); if(s=="") return true; AC_SharedOhlcMarkPriorityAttempt(priority,false); return AC_SharedOhlcSeedOneIfNeeded(s,tf_index);
}

bool AC_SharedOhlcFullSeedPriorityOne()
{
   for(int p=1;p<=5;p++) if(AC_SharedOhlcSeedPriorityOne(p)) return true;
   AC_SHARED_OHLC_BOOT_SEED_COMPLETE=true; AC_SHARED_OHLC_MODE="topup_partial_then_append_priority_refresh"; AC_SHARED_OHLC_STATUS="seed_initial_pass_complete_topup_active"; AC_SHARED_OHLC_LAST_TASK_STATUS="full_seed_initial_pass_complete_topup_active"; return false;
}

bool AC_SharedOhlcTopupOneForPriority(const int priority)
{
   int symbols=AC_SharedOhlcPrioritySymbolCount(priority); if(symbols<=0) return false;
   int index=AC_SharedOhlcGetTopupIndexForPriority(priority); int total_tasks=symbols*AC_SHARED_OHLC_TIMEFRAMES_ENABLED; if(total_tasks<=0) return false; if(index>=total_tasks) index=0;
   int symbol_ordinal=index/AC_SHARED_OHLC_TIMEFRAMES_ENABLED; int tf_index=index%AC_SHARED_OHLC_TIMEFRAMES_ENABLED; string s=AC_SharedOhlcSymbolByPriorityOrdinal(priority,symbol_ordinal);
   AC_SharedOhlcSetTopupIndexForPriority(priority,index+1); if(s=="") return true;
   string tf=AC_SharedOhlcTfLabel(tf_index); long old_count=AC_SharedOhlcReadLong(AC_SharedOhlcSeedCountPath(s,tf));
   if(old_count>=AC_SHARED_OHLC_TARGET_SEED_BARS){ AC_SHARED_OHLC_TOPUP_SKIPPED_COMPLETE++; AC_SHARED_OHLC_LAST_TASK_STATUS="topup_skip_already_1500"; return true; }
   AC_SharedOhlcMarkPriorityAttempt(priority,false); AC_SHARED_OHLC_TOPUP_ATTEMPTED++;
   bool ok=AC_SharedOhlcSeedOne(s,tf_index); long new_count=AC_SharedOhlcReadLong(AC_SharedOhlcSeedCountPath(s,tf));
   if(ok && new_count>old_count){ AC_SHARED_OHLC_TOPUP_IMPROVED++; AC_SHARED_OHLC_LAST_TASK_STATUS="topup_improved_"+IntegerToString((int)old_count)+"_to_"+IntegerToString((int)new_count); return true; }
   if(ok){ AC_SHARED_OHLC_TOPUP_STILL_PARTIAL++; AC_SHARED_OHLC_LAST_TASK_STATUS="topup_still_partial_"+IntegerToString((int)new_count); return true; }
   AC_SHARED_OHLC_TOPUP_ERROR++; return false;
}

bool AC_SharedOhlcTopupPriorityRefreshOne(){ for(int p=1;p<=5;p++) if(AC_SharedOhlcTopupOneForPriority(p)) return true; AC_SHARED_OHLC_LAST_TASK_STATUS="topup_priority_flow_no_symbols"; return false; }

bool AC_SharedOhlcAppendOne(const string s,const int tfi)
{
   string tf=AC_SharedOhlcTfLabel(tfi); ENUM_TIMEFRAMES e=AC_SharedOhlcTfEnum(tfi); AC_SHARED_OHLC_LAST_SYMBOL=s; AC_SHARED_OHLC_LAST_TF=tf; AC_SharedOhlcEnsureSymbolFolders(s);
   MqlRates r[]; if(CopyRates(s,e,1,1,r)<=0){AC_SHARED_OHLC_APPEND_ERROR++; AC_SHARED_OHLC_LAST_TASK_STATUS="append_"+AC_SHARED_OHLC_LAST_PRIORITY_LABEL+"_copyrates_unavailable"; return false;}
   long last=AC_SharedOhlcReadLastTime(AC_SharedOhlcLastTimePath(s,tf)); if((long)r[0].time<=last){AC_SHARED_OHLC_APPEND_SKIPPED_DUPLICATE++; AC_SHARED_OHLC_LAST_TASK_STATUS="append_"+AC_SHARED_OHLC_LAST_PRIORITY_LABEL+"_no_new_closed_bar"; return true;}
   if(!AC_SharedOhlcAppendLine(AC_SharedOhlcAppendPath(s,tf),AC_SharedOhlcRow(s,r[0]),AC_SharedOhlcHeader(s,tf))){AC_SHARED_OHLC_APPEND_ERROR++; AC_SHARED_OHLC_LAST_TASK_STATUS="append_"+AC_SHARED_OHLC_LAST_PRIORITY_LABEL+"_write_failed"; return false;}
   AC_SharedOhlcWriteLastTime(AC_SharedOhlcLastTimePath(s,tf),r[0].time); AC_SHARED_OHLC_APPEND_WRITTEN++; AC_SHARED_OHLC_LAST_TASK_STATUS="append_"+AC_SHARED_OHLC_LAST_PRIORITY_LABEL+"_written"; return true;
}

bool AC_SharedOhlcAppendPriorityOne(const int priority)
{
   int symbols=AC_SharedOhlcPrioritySymbolCount(priority); if(symbols<=0) return false;
   int index=AC_SharedOhlcGetIndexForPriority(priority,true); int total_tasks=symbols*AC_SHARED_OHLC_TIMEFRAMES_ENABLED; if(total_tasks<=0) return false; if(index>=total_tasks) index=0;
   int symbol_ordinal=index/AC_SHARED_OHLC_TIMEFRAMES_ENABLED; int tf_index=index%AC_SHARED_OHLC_TIMEFRAMES_ENABLED; string s=AC_SharedOhlcSymbolByPriorityOrdinal(priority,symbol_ordinal);
   AC_SharedOhlcSetIndexForPriority(priority,true,index+1); if(s=="") return true; AC_SharedOhlcMarkPriorityAttempt(priority,false); return AC_SharedOhlcAppendOne(s,tf_index);
}

bool AC_SharedOhlcAppendPriorityRefreshOne(){ for(int p=1;p<=5;p++) if(AC_SharedOhlcAppendPriorityOne(p)) return true; AC_SHARED_OHLC_LAST_TASK_STATUS="append_priority_flow_no_symbols"; return false; }

void AC_SharedOhlcApplyPriorityProfile(const int priority)
{
   if(priority==1){ AC_SHARED_OHLC_TASKS_PER_SERVICE=4; AC_SHARED_OHLC_SERVICE_INTERVAL_MS=250; AC_SHARED_OHLC_SERVICE_BUDGET_MS=180; AC_SHARED_OHLC_ADAPTIVE_MODE="P1_fast"; return; }
   if(priority==2){ AC_SHARED_OHLC_TASKS_PER_SERVICE=3; AC_SHARED_OHLC_SERVICE_INTERVAL_MS=500; AC_SHARED_OHLC_SERVICE_BUDGET_MS=160; AC_SHARED_OHLC_ADAPTIVE_MODE="P2_active"; return; }
   if(priority==3){ AC_SHARED_OHLC_TASKS_PER_SERVICE=2; AC_SHARED_OHLC_SERVICE_INTERVAL_MS=750; AC_SHARED_OHLC_SERVICE_BUDGET_MS=140; AC_SHARED_OHLC_ADAPTIVE_MODE="P3_reserved"; return; }
   if(priority==4){ AC_SHARED_OHLC_TASKS_PER_SERVICE=1; AC_SHARED_OHLC_SERVICE_INTERVAL_MS=1000; AC_SHARED_OHLC_SERVICE_BUDGET_MS=100; AC_SHARED_OHLC_ADAPTIVE_MODE="P4_standard"; return; }
   AC_SHARED_OHLC_TASKS_PER_SERVICE=1; AC_SHARED_OHLC_SERVICE_INTERVAL_MS=5000; AC_SHARED_OHLC_SERVICE_BUDGET_MS=80; AC_SHARED_OHLC_ADAPTIVE_MODE="P5_slow_background";
}

void AC_SharedOhlcApplySlowCallProtection()
{
   if(AC_SHARED_OHLC_LAST_SERVICE_MS>500){ AC_SHARED_OHLC_TASKS_PER_SERVICE=1; if(AC_SHARED_OHLC_SERVICE_INTERVAL_MS<2000) AC_SHARED_OHLC_SERVICE_INTERVAL_MS=2000; AC_SHARED_OHLC_SERVICE_BUDGET_MS=80; AC_SHARED_OHLC_COOLDOWN_RUNS=10; AC_SHARED_OHLC_FAST_STREAK=0; AC_SHARED_OHLC_ADAPTIVE_MODE=AC_SHARED_OHLC_ADAPTIVE_MODE+"_cooldown"; return; }
   if(AC_SHARED_OHLC_COOLDOWN_RUNS>0){ AC_SHARED_OHLC_COOLDOWN_RUNS--; AC_SHARED_OHLC_TASKS_PER_SERVICE=1; if(AC_SHARED_OHLC_SERVICE_INTERVAL_MS<1000) AC_SHARED_OHLC_SERVICE_INTERVAL_MS=1000; AC_SHARED_OHLC_SERVICE_BUDGET_MS=80; AC_SHARED_OHLC_ADAPTIVE_MODE=AC_SHARED_OHLC_ADAPTIVE_MODE+"_protective"; }
}

void AC_SharedOhlcPublishStatus()
{
   string status="schema_name=shared_ohlc_raw_store_status\r\nschema_version=active_raw_store_v5\r\nowner=Runtime 1 Shared OHLC Raw Storage Owner\r\nstatus="+AC_SHARED_OHLC_STATUS+"\r\nmode="+AC_SHARED_OHLC_MODE+"\r\nscope=broker_universe_symbols_total_false\r\npriority_policy=P1_fastest_open_pending_P2_active_L5_pass_P3_reserved_P4_standard_other_open_P5_slow_background_closed_blocked_unknown\r\nroute_root="+AC_SharedOhlcRootFolder()+"\r\nwindow_storage_policy=integrated_under_symbols_symbol_priority_windows_no_root_fast_windows_owner\r\nsupported_timeframes=M1,M5,M15,M30,H1,H4,D1,W1\r\nl18_required_timeframes=M1,M5,M15,M30,H1,H4,D1,W1\r\nmissing_required_timeframes=none_configured_seed_may_still_be_pending\r\nsymbols_total="+IntegerToString(AC_SHARED_OHLC_SYMBOLS_TOTAL)+"\r\ntimeframes_enabled="+IntegerToString(AC_SHARED_OHLC_TIMEFRAMES_ENABLED)+"\r\ntarget_seed_bars="+IntegerToString(AC_SHARED_OHLC_TARGET_SEED_BARS)+"\r\nsymbol_tf_total="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_TOTAL)+"\r\nsymbol_tf_attempted="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_ATTEMPTED)+"\r\nsymbol_tf_seeded="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_SEEDED)+"\r\nsymbol_tf_partial="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_PARTIAL)+"\r\nsymbol_tf_error="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_ERROR)+"\r\nsymbol_tf_pending="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_PENDING)+"\r\nseed_skipped_existing_count="+IntegerToString(AC_SHARED_OHLC_SEED_SKIPPED_EXISTING)+"\r\nskipped_unchanged_count="+IntegerToString(AC_SHARED_OHLC_SEED_SKIPPED_EXISTING)+"\r\npriority_window_total="+IntegerToString(AC_SHARED_OHLC_WINDOW_TOTAL)+"\r\npriority_window_attempted="+IntegerToString(AC_SHARED_OHLC_WINDOW_ATTEMPTED)+"\r\npriority_window_ready="+IntegerToString(AC_SHARED_OHLC_WINDOW_READY)+"\r\npriority_window_partial="+IntegerToString(AC_SHARED_OHLC_WINDOW_PARTIAL)+"\r\npriority_window_error="+IntegerToString(AC_SHARED_OHLC_WINDOW_ERROR)+"\r\npriority_window_complete="+(AC_SHARED_OHLC_PRIORITY_WINDOW_COMPLETE?"true":"false")+"\r\ntopup_attempted="+IntegerToString(AC_SHARED_OHLC_TOPUP_ATTEMPTED)+"\r\ntopup_improved="+IntegerToString(AC_SHARED_OHLC_TOPUP_IMPROVED)+"\r\ntopup_still_partial="+IntegerToString(AC_SHARED_OHLC_TOPUP_STILL_PARTIAL)+"\r\ntopup_skipped_complete="+IntegerToString(AC_SHARED_OHLC_TOPUP_SKIPPED_COMPLETE)+"\r\ntopup_error="+IntegerToString(AC_SHARED_OHLC_TOPUP_ERROR)+"\r\nfull_seed_scheduler_active="+(AC_SHARED_OHLC_BOOT_SEED_COMPLETE?"false":"true")+"\r\ncopyrates_fetch_active=true\r\nlast_priority="+AC_SHARED_OHLC_LAST_PRIORITY_LABEL+"\r\nlast_symbol="+AC_SHARED_OHLC_LAST_SYMBOL+"\r\nlast_timeframe="+AC_SHARED_OHLC_LAST_TF+"\r\nlast_task_status="+AC_SHARED_OHLC_LAST_TASK_STATUS+"\r\nlast_service_ms="+IntegerToString((int)AC_SHARED_OHLC_LAST_SERVICE_MS)+"\r\nservice_tasks_used="+IntegerToString(AC_SHARED_OHLC_SERVICE_TASKS_USED)+"\r\nservice_tasks_per_run="+IntegerToString(AC_SHARED_OHLC_TASKS_PER_SERVICE)+"\r\nservice_interval_ms="+IntegerToString((int)AC_SHARED_OHLC_SERVICE_INTERVAL_MS)+"\r\nservice_budget_ms="+IntegerToString((int)AC_SHARED_OHLC_SERVICE_BUDGET_MS)+"\r\nadaptive_mode="+AC_SHARED_OHLC_ADAPTIVE_MODE+"\r\ncooldown_runs="+IntegerToString(AC_SHARED_OHLC_COOLDOWN_RUNS)+"\r\nraw_bars_written=true\r\ntrade_permission=false\r\nselection_runtime=false\r\ncalculation_runtime=false\r\n";
   AC_WriteResult sw=AC_WriteTextFileFastAtomic(AC_SharedOhlcStatusPath(),status); AC_SHARED_OHLC_STATUS_WRITE=sw.status;
   string mf="schema_name=shared_ohlc_raw_store_manifest\r\nschema_version=active_raw_store_v5\r\nowner=Runtime 1 Shared OHLC Raw Storage Owner\r\nroute_root="+AC_SharedOhlcRootFolder()+"\r\nstatus_path="+AC_SharedOhlcStatusPath()+"\r\nmanifest_path="+AC_SharedOhlcManifestPath()+"\r\nsymbols_folder="+AC_SharedOhlcSymbolsFolder()+"\r\npriority_window_storage=integrated_under_each_symbol_folder\r\npriority_window_example=Aurora Core\\<server>\\Shared Market Data\\OHLC Store\\Symbols\\<symbol>\\Priority Windows\\M5.window.csv\r\nsupported_timeframes=M1,M5,M15,M30,H1,H4,D1,W1\r\nl18_required_timeframes=M1,M5,M15,M30,H1,H4,D1,W1\r\nscope=broker_universe_symbols_total_false\r\npriority_policy=P1_fastest_open_pending_P2_active_L5_pass_P3_reserved_P4_standard_other_open_P5_slow_background_closed_blocked_unknown\r\ncopyrates_fetch_active=true\r\npriority_window_complete="+(AC_SHARED_OHLC_PRIORITY_WINDOW_COMPLETE?"true":"false")+"\r\nfull_seed_scheduler_active="+(AC_SHARED_OHLC_BOOT_SEED_COMPLETE?"false":"true")+"\r\ntopup_active=true\r\nappend_mode_active="+(AC_SHARED_OHLC_BOOT_SEED_COMPLETE?"true":"false")+"\r\nraw_bars_printed_to_board=false\r\nraw_bars_printed_to_dossier=false\r\nroute_status="+AC_SHARED_OHLC_ROUTE_STATUS+"\r\nstatus_write="+AC_SHARED_OHLC_STATUS_WRITE+"\r\nservice_tasks_per_run="+IntegerToString(AC_SHARED_OHLC_TASKS_PER_SERVICE)+"\r\nservice_interval_ms="+IntegerToString((int)AC_SHARED_OHLC_SERVICE_INTERVAL_MS)+"\r\nadaptive_mode="+AC_SHARED_OHLC_ADAPTIVE_MODE+"\r\nlast_priority="+AC_SHARED_OHLC_LAST_PRIORITY_LABEL+"\r\n";
   AC_WriteResult mw=AC_WriteTextFileFastAtomic(AC_SharedOhlcManifestPath(),mf); AC_SHARED_OHLC_MANIFEST_WRITE=mw.status;
}

void AC_SharedOhlcService()
{
   uint now=GetTickCount(); if(now-AC_SHARED_OHLC_LAST_RUN_TICK<AC_SHARED_OHLC_SERVICE_INTERVAL_MS)return; AC_SHARED_OHLC_LAST_RUN_TICK=now;
   uint start=GetTickCount(); AC_SharedOhlcEnsureRouteOnly(); AC_SharedOhlcUpdateTotals(); int tasks=0; AC_SHARED_OHLC_SERVICE_TASKS_USED=0;
   while(tasks<AC_SHARED_OHLC_TASKS_PER_SERVICE && (GetTickCount()-start)<AC_SHARED_OHLC_SERVICE_BUDGET_MS && AC_SHARED_OHLC_SYMBOLS_TOTAL>0)
   {
      if(!AC_SHARED_OHLC_PRIORITY_WINDOW_COMPLETE){ AC_SHARED_OHLC_MODE="priority_window_seed_active"; AC_SharedOhlcSeedPriorityWindowOne(); }
      else if(!AC_SHARED_OHLC_BOOT_SEED_COMPLETE){ AC_SHARED_OHLC_MODE="full_seed_priority_active"; AC_SharedOhlcFullSeedPriorityOne(); }
      else
      {
         AC_SHARED_OHLC_MODE="topup_partial_then_append_priority_refresh";
         if(!AC_SharedOhlcTopupPriorityRefreshOne()) AC_SharedOhlcAppendPriorityRefreshOne();
      }
      tasks++; AC_SHARED_OHLC_SERVICE_TASKS_USED=tasks;
   }
   AC_SHARED_OHLC_LAST_SERVICE_MS=GetTickCount()-start;
   AC_SharedOhlcUpdateTotals(); AC_SharedOhlcApplyPriorityProfile(AC_SHARED_OHLC_LAST_PRIORITY); AC_SharedOhlcApplySlowCallProtection(); AC_SharedOhlcPublishStatus();
}

string AC_SharedOhlcRenderBoardSection()
{
   AC_SharedOhlcService();
   string text="\r\nSHARED OHLC RAW STORE\r\n----------------------------------------\r\n";
   text+="Status:                 "+AC_SHARED_OHLC_STATUS+"\r\nMode:                   "+AC_SHARED_OHLC_MODE+"\r\nSupported Timeframes:   M1,M5,M15,M30,H1,H4,D1,W1\r\nL18 Required TFs:       M1,M5,M15,M30,H1,H4,D1,W1\r\nPriority Speed:         P1 fastest, P2 active, P3 reserved, P4 standard, P5 slow background\r\nWindow Storage:         integrated under Symbols/<symbol>/Priority Windows\r\nLast Priority:          "+AC_SHARED_OHLC_LAST_PRIORITY_LABEL+"\r\nRoute Root:             "+AC_SharedOhlcRootFolder()+"\r\nRoute Status:           "+AC_SHARED_OHLC_ROUTE_STATUS+"\r\nStatus File Write:      "+AC_SHARED_OHLC_STATUS_WRITE+"\r\nManifest File Write:    "+AC_SHARED_OHLC_MANIFEST_WRITE+"\r\nSymbols Tracked:        "+IntegerToString(AC_SHARED_OHLC_SYMBOLS_TOTAL)+"\r\nPriority Windows:       "+IntegerToString(AC_SHARED_OHLC_WINDOW_READY)+" ready / "+IntegerToString(AC_SHARED_OHLC_WINDOW_TOTAL)+" total\r\nAttempted Symbol-TFs:   "+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_ATTEMPTED)+" / "+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_TOTAL)+"\r\nSeeded/Partial/Error:   "+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_SEEDED)+" / "+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_PARTIAL)+" / "+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_ERROR)+"\r\nSeed Skipped Existing:  "+IntegerToString(AC_SHARED_OHLC_SEED_SKIPPED_EXISTING)+"\r\nTopup Improved/Partial: "+IntegerToString(AC_SHARED_OHLC_TOPUP_IMPROVED)+" / "+IntegerToString(AC_SHARED_OHLC_TOPUP_STILL_PARTIAL)+"\r\nPending Symbol-TFs:     "+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_PENDING)+"\r\nLast Task:              "+AC_SHARED_OHLC_LAST_SYMBOL+" "+AC_SHARED_OHLC_LAST_TF+" "+AC_SHARED_OHLC_LAST_TASK_STATUS+"\r\nService Duration:       "+IntegerToString((int)AC_SHARED_OHLC_LAST_SERVICE_MS)+" ms\r\nService Throttle:       mode="+AC_SHARED_OHLC_ADAPTIVE_MODE+" tasks="+IntegerToString(AC_SHARED_OHLC_TASKS_PER_SERVICE)+" interval_ms="+IntegerToString((int)AC_SHARED_OHLC_SERVICE_INTERVAL_MS)+" budget_ms="+IntegerToString((int)AC_SHARED_OHLC_SERVICE_BUDGET_MS)+"\r\nRaw Bars Printed:       FALSE\r\nTrade Permission:       FALSE\r\n";
   return text;
}

string AC_SharedOhlcRenderDossierSection(const string symbol)
{
   AC_SharedOhlcEnsureRouteOnly();
   string m5=FileIsExist(AC_SharedOhlcFastWindowPath(symbol,"M5"),AC_CommonFlag())?"available":"pending";
   string m15=FileIsExist(AC_SharedOhlcFastWindowPath(symbol,"M15"),AC_CommonFlag())?"available":"pending";
   string h1=FileIsExist(AC_SharedOhlcFastWindowPath(symbol,"H1"),AC_CommonFlag())?"available":"pending";
   string h4=FileIsExist(AC_SharedOhlcFastWindowPath(symbol,"H4"),AC_CommonFlag())?"available":"pending";
   bool min_ready=(m5=="available" && m15=="available" && h1=="available");
   int priority=AC_SharedOhlcPriorityForSymbol(symbol);
   string text="\r\nSHARED OHLC RAW STORE OVERVIEW\r\n----------------------------------------\r\n";
   text+="Owner:                  Runtime 1 Shared OHLC Raw Storage Owner\r\nSymbol:                 "+symbol+"\r\nSymbol Priority:        "+AC_SharedOhlcPriorityLabel(priority)+"\r\nStore Status:           "+AC_SHARED_OHLC_STATUS+"\r\nStore Mode:             "+AC_SHARED_OHLC_MODE+"\r\nRaw Store Route:        "+AC_SharedOhlcRootFolder()+"\r\nSymbol Store Route:     "+AC_SharedOhlcSymbolFolder(symbol)+"\r\nPriority Window Route:  "+AC_SharedOhlcWindowFolder(symbol)+"\r\nWindow Minimum Ready:   "+(min_ready?"TRUE":"FALSE")+"\r\nWindow M5/M15/H1/H4:    "+m5+" / "+m15+" / "+h1+" / "+h4+"\r\nRaw Bars Shown Here:    FALSE\r\nCalculation Policy:     no_calculations_in_mt5_raw_storage_owner\r\n";
   return text;
}

string AC_SharedOhlcRenderWorkbenchSection()
{
   AC_SharedOhlcService();
   string text="SHARED_OHLC_RAW_STORAGE_OWNER\r\n----------------------------------------\r\n";
   text+="shared_ohlc_status="+AC_SHARED_OHLC_STATUS+"\r\nshared_ohlc_mode="+AC_SHARED_OHLC_MODE+"\r\nshared_ohlc_supported_timeframes=M1,M5,M15,M30,H1,H4,D1,W1\r\nshared_ohlc_l18_required_timeframes=M1,M5,M15,M30,H1,H4,D1,W1\r\nshared_ohlc_missing_required_timeframes=none_configured_seed_may_still_be_pending\r\nshared_ohlc_priority_speed=P1_fastest_P2_active_P3_reserved_P4_standard_P5_slow_background\r\nshared_ohlc_last_priority="+AC_SHARED_OHLC_LAST_PRIORITY_LABEL+"\r\nshared_ohlc_route_root="+AC_SharedOhlcRootFolder()+"\r\nshared_ohlc_status_path="+AC_SharedOhlcStatusPath()+"\r\nshared_ohlc_manifest_path="+AC_SharedOhlcManifestPath()+"\r\nshared_ohlc_route_status="+AC_SHARED_OHLC_ROUTE_STATUS+"\r\nshared_ohlc_status_write="+AC_SHARED_OHLC_STATUS_WRITE+"\r\nshared_ohlc_manifest_write="+AC_SHARED_OHLC_MANIFEST_WRITE+"\r\nshared_ohlc_scope=broker_universe_symbols_total_false\r\nshared_ohlc_copyrates_fetch_active=true\r\nshared_ohlc_priority_window_complete="+(AC_SHARED_OHLC_PRIORITY_WINDOW_COMPLETE?"true":"false")+"\r\nshared_ohlc_full_seed_scheduler_active="+(AC_SHARED_OHLC_BOOT_SEED_COMPLETE?"false":"true")+"\r\nshared_ohlc_topup_active=true\r\nshared_ohlc_append_mode_active="+(AC_SHARED_OHLC_BOOT_SEED_COMPLETE?"true":"false")+"\r\nshared_ohlc_symbol_tf_total="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_TOTAL)+"\r\nshared_ohlc_symbol_tf_attempted="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_ATTEMPTED)+"\r\nshared_ohlc_symbol_tf_seeded="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_SEEDED)+"\r\nshared_ohlc_symbol_tf_partial="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_PARTIAL)+"\r\nshared_ohlc_symbol_tf_error="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_ERROR)+"\r\nshared_ohlc_seed_skipped_existing="+IntegerToString(AC_SHARED_OHLC_SEED_SKIPPED_EXISTING)+"\r\nshared_ohlc_skipped_unchanged_count="+IntegerToString(AC_SHARED_OHLC_SEED_SKIPPED_EXISTING)+"\r\nshared_ohlc_topup_attempted="+IntegerToString(AC_SHARED_OHLC_TOPUP_ATTEMPTED)+"\r\nshared_ohlc_topup_improved="+IntegerToString(AC_SHARED_OHLC_TOPUP_IMPROVED)+"\r\nshared_ohlc_topup_still_partial="+IntegerToString(AC_SHARED_OHLC_TOPUP_STILL_PARTIAL)+"\r\nshared_ohlc_append_written="+IntegerToString(AC_SHARED_OHLC_APPEND_WRITTEN)+"\r\nshared_ohlc_last_service_ms="+IntegerToString((int)AC_SHARED_OHLC_LAST_SERVICE_MS)+"\r\nshared_ohlc_service_tasks_used="+IntegerToString(AC_SHARED_OHLC_SERVICE_TASKS_USED)+"\r\nshared_ohlc_service_tasks_per_run="+IntegerToString(AC_SHARED_OHLC_TASKS_PER_SERVICE)+"\r\nshared_ohlc_service_interval_ms="+IntegerToString((int)AC_SHARED_OHLC_SERVICE_INTERVAL_MS)+"\r\nshared_ohlc_service_budget_ms="+IntegerToString((int)AC_SHARED_OHLC_SERVICE_BUDGET_MS)+"\r\nshared_ohlc_adaptive_mode="+AC_SHARED_OHLC_ADAPTIVE_MODE+"\r\nshared_ohlc_cooldown_runs="+IntegerToString(AC_SHARED_OHLC_COOLDOWN_RUNS)+"\r\nshared_ohlc_last_task="+AC_SHARED_OHLC_LAST_SYMBOL+"|"+AC_SHARED_OHLC_LAST_TF+"|"+AC_SHARED_OHLC_LAST_TASK_STATUS+"\r\nshared_ohlc_raw_bars_printed_to_board=false\r\nshared_ohlc_raw_bars_printed_to_dossier=false\r\n";
   return text;
}

#endif
