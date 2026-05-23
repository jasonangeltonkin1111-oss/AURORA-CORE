#ifndef AC_PUBLICATION_RENDERERS_MQH
#define AC_PUBLICATION_RENDERERS_MQH

// Shared OHLC Raw Storage active bootstrap.
// Compile-safe single-file bridge until the Runtime 1 owner include tree is locally installed.
// Source authority: Runtime 1 Shared OHLC Raw Storage Owner. This code stores raw MT5 bars only.
// No calculations, ranking, selection, trade permission, or execution.
// Priority law: P1 open/pending, P2 L5 pass, P3 future candidate/ranked/selected,
// P4 other open, P5 closed/blocked/unknown/low-priority.

static string AC_SHARED_OHLC_STATUS = "seed_active";
static string AC_SHARED_OHLC_MODE = "boot_seed_bounded_raw_storage";
static bool   AC_SHARED_OHLC_BOOT_SEED_COMPLETE = false;
static int    AC_SHARED_OHLC_TIMEFRAMES_ENABLED = 6;
static int    AC_SHARED_OHLC_TARGET_SEED_BARS = 1500;
static int    AC_SHARED_OHLC_SYMBOLS_TOTAL = 0;
static int    AC_SHARED_OHLC_SYMBOL_TF_TOTAL = 0;
static int    AC_SHARED_OHLC_SYMBOL_TF_SEEDED = 0;
static int    AC_SHARED_OHLC_SYMBOL_TF_PARTIAL = 0;
static int    AC_SHARED_OHLC_SYMBOL_TF_ERROR = 0;
static int    AC_SHARED_OHLC_SYMBOL_TF_ATTEMPTED = 0;
static int    AC_SHARED_OHLC_SYMBOL_TF_PENDING = 0;
static int    AC_SHARED_OHLC_APPEND_WRITTEN = 0;
static int    AC_SHARED_OHLC_APPEND_SKIPPED_DUPLICATE = 0;
static int    AC_SHARED_OHLC_APPEND_ERROR = 0;
static int    AC_SHARED_OHLC_APPEND_BACKLOG_P1 = 0;
static int    AC_SHARED_OHLC_APPEND_BACKLOG_P2 = 0;
static int    AC_SHARED_OHLC_APPEND_BACKLOG_P3 = 0;
static int    AC_SHARED_OHLC_APPEND_BACKLOG_P4 = 0;
static int    AC_SHARED_OHLC_APPEND_BACKLOG_P5 = 0;
static string AC_SHARED_OHLC_ROUTE_STATUS = "not_attempted";
static string AC_SHARED_OHLC_STATUS_WRITE = "not_attempted";
static string AC_SHARED_OHLC_MANIFEST_WRITE = "not_attempted";
static string AC_SHARED_OHLC_LAST_SYMBOL = "";
static string AC_SHARED_OHLC_LAST_TF = "";
static string AC_SHARED_OHLC_LAST_TASK_STATUS = "not_started";
static int    AC_SHARED_OHLC_LAST_PRIORITY = 0;
static string AC_SHARED_OHLC_LAST_PRIORITY_LABEL = "none";
static uint   AC_SHARED_OHLC_LAST_SERVICE_MS = 0;
static int    AC_SHARED_OHLC_TASKS_PER_SERVICE = 2;
static uint   AC_SHARED_OHLC_SERVICE_BUDGET_MS = 120;
static uint   AC_SHARED_OHLC_SERVICE_INTERVAL_MS = 500;
static uint   AC_SHARED_OHLC_LAST_RUN_TICK = 0;
static string AC_SHARED_OHLC_ADAPTIVE_MODE = "normal";
static int    AC_SHARED_OHLC_FAST_STREAK = 0;
static int    AC_SHARED_OHLC_COOLDOWN_RUNS = 0;
static int    AC_SHARED_OHLC_SERVICE_TASKS_USED = 0;

static int    AC_SHARED_OHLC_L8_FAST_P1_INDEX = 0;
static int    AC_SHARED_OHLC_L8_FAST_P2_INDEX = 0;
static int    AC_SHARED_OHLC_L8_FAST_P3_INDEX = 0;
static int    AC_SHARED_OHLC_L8_FAST_P4_INDEX = 0;
static int    AC_SHARED_OHLC_L8_FAST_TOTAL = 0;
static int    AC_SHARED_OHLC_L8_FAST_ATTEMPTED = 0;
static int    AC_SHARED_OHLC_L8_FAST_READY = 0;
static int    AC_SHARED_OHLC_L8_FAST_PARTIAL = 0;
static int    AC_SHARED_OHLC_L8_FAST_ERROR = 0;
static int    AC_SHARED_OHLC_L8_FAST_PENDING = 0;
static int    AC_SHARED_OHLC_L8_FAST_M5_READY = 0;
static int    AC_SHARED_OHLC_L8_FAST_M15_READY = 0;
static int    AC_SHARED_OHLC_L8_FAST_H1_READY = 0;
static int    AC_SHARED_OHLC_L8_FAST_H4_READY = 0;
static int    AC_SHARED_OHLC_L8_FAST_P1_ATTEMPTED = 0;
static int    AC_SHARED_OHLC_L8_FAST_P2_ATTEMPTED = 0;
static int    AC_SHARED_OHLC_L8_FAST_P3_ATTEMPTED = 0;
static int    AC_SHARED_OHLC_L8_FAST_P4_ATTEMPTED = 0;
static bool   AC_SHARED_OHLC_L8_FAST_COMPLETE = false;

static int    AC_SHARED_OHLC_SEED_P1_INDEX = 0;
static int    AC_SHARED_OHLC_SEED_P2_INDEX = 0;
static int    AC_SHARED_OHLC_SEED_P3_INDEX = 0;
static int    AC_SHARED_OHLC_SEED_P4_INDEX = 0;
static int    AC_SHARED_OHLC_SEED_P5_INDEX = 0;
static int    AC_SHARED_OHLC_APPEND_P1_INDEX = 0;
static int    AC_SHARED_OHLC_APPEND_P2_INDEX = 0;
static int    AC_SHARED_OHLC_APPEND_P3_INDEX = 0;
static int    AC_SHARED_OHLC_APPEND_P4_INDEX = 0;
static int    AC_SHARED_OHLC_APPEND_P5_INDEX = 0;
static int    AC_SHARED_OHLC_P1_ATTEMPTED = 0;
static int    AC_SHARED_OHLC_P2_ATTEMPTED = 0;
static int    AC_SHARED_OHLC_P3_ATTEMPTED = 0;
static int    AC_SHARED_OHLC_P4_ATTEMPTED = 0;
static int    AC_SHARED_OHLC_P5_ATTEMPTED = 0;

string AC_SharedOhlcServerFolder(){ return AC_BASE_FOLDER + "\\" + AC_ServerNameForRoute(); }
string AC_SharedOhlcMarketDataFolder(){ return AC_SharedOhlcServerFolder() + "\\Shared Market Data"; }
string AC_SharedOhlcRootFolder(){ return AC_SharedOhlcMarketDataFolder() + "\\OHLC Store"; }
string AC_SharedOhlcStatusFolder(){ return AC_SharedOhlcRootFolder() + "\\Status"; }
string AC_SharedOhlcSymbolsFolder(){ return AC_SharedOhlcRootFolder() + "\\Symbols"; }
string AC_SharedOhlcFastWindowsFolder(){ return AC_SharedOhlcRootFolder() + "\\Fast Windows"; }
string AC_SharedOhlcStatusPath(){ return AC_SharedOhlcStatusFolder() + "\\status.txt"; }
string AC_SharedOhlcManifestPath(){ return AC_SharedOhlcStatusFolder() + "\\manifest.txt"; }
string AC_SharedOhlcSymbolFolder(const string s){ return AC_SharedOhlcSymbolsFolder() + "\\" + AC_SanitizePathPart(s); }
string AC_SharedOhlcFastSymbolFolder(const string s){ return AC_SharedOhlcFastWindowsFolder() + "\\" + AC_SanitizePathPart(s); }
string AC_SharedOhlcCurrentFolder(const string s){ return AC_SharedOhlcSymbolFolder(s) + "\\Current"; }
string AC_SharedOhlcStateFolder(const string s){ return AC_SharedOhlcSymbolFolder(s) + "\\State"; }
string AC_SharedOhlcSeedPath(const string s,const string tf){ return AC_SharedOhlcSymbolFolder(s)+"\\"+tf+".seed.csv"; }
string AC_SharedOhlcAppendPath(const string s,const string tf){ return AC_SharedOhlcSymbolFolder(s)+"\\"+tf+".append.csv"; }
string AC_SharedOhlcFastWindowPath(const string s,const string tf){ return AC_SharedOhlcFastSymbolFolder(s)+"\\"+tf+".window.csv"; }
string AC_SharedOhlcCurrentPath(const string s,const string tf){ return AC_SharedOhlcCurrentFolder(s)+"\\"+tf+".current.csv"; }
string AC_SharedOhlcLastTimePath(const string s,const string tf){ return AC_SharedOhlcStateFolder(s)+"\\"+tf+".last_time.txt"; }

string AC_SharedOhlcTfLabel(const int i){ if(i==0)return "M1"; if(i==1)return "M5"; if(i==2)return "M15"; if(i==3)return "H1"; if(i==4)return "H4"; return "D1"; }
ENUM_TIMEFRAMES AC_SharedOhlcTfEnum(const int i){ if(i==0)return PERIOD_M1; if(i==1)return PERIOD_M5; if(i==2)return PERIOD_M15; if(i==3)return PERIOD_H1; if(i==4)return PERIOD_H4; return PERIOD_D1; }
string AC_SharedOhlcL8FastTfLabel(const int i){ if(i==0)return "M5"; if(i==1)return "M15"; if(i==2)return "H1"; return "H4"; }
ENUM_TIMEFRAMES AC_SharedOhlcL8FastTfEnum(const int i){ if(i==0)return PERIOD_M5; if(i==1)return PERIOD_M15; if(i==2)return PERIOD_H1; return PERIOD_H4; }
int AC_SharedOhlcL8FastBars(const int i){ if(i==0)return 64; if(i==1)return 80; if(i==2)return 80; return 42; }
int AC_SharedOhlcL8FastTfCount(){ return 4; }

string AC_SharedOhlcPriorityLabel(const int p)
{
   if(p==1)return "P1_open_positions_or_pending_orders";
   if(p==2)return "P2_layer5_pass_symbols";
   if(p==3)return "P3_future_candidate_ranked_selected_reserved";
   if(p==4)return "P4_other_open_symbols";
   return "P5_closed_blocked_unknown_low_priority";
}

long AC_SharedOhlcPricePoints(const string s,const double p){ double pt=SymbolInfoDouble(s,SYMBOL_POINT); if(pt<=0.0)return 0; return (long)MathRound(p/pt); }
string AC_SharedOhlcHeader(const string s,const string tf){ return "#schema=shared_ohlc_raw_v1\r\n#symbol="+s+"\r\n#timeframe="+tf+"\r\n#price_encoding=integer_points\r\nbar_time,open_i,high_i,low_i,close_i,tick_volume,spread,real_volume\r\n"; }
string AC_SharedOhlcRow(const string s,const MqlRates &r){ return IntegerToString((long)r.time)+","+IntegerToString(AC_SharedOhlcPricePoints(s,r.open))+","+IntegerToString(AC_SharedOhlcPricePoints(s,r.high))+","+IntegerToString(AC_SharedOhlcPricePoints(s,r.low))+","+IntegerToString(AC_SharedOhlcPricePoints(s,r.close))+","+IntegerToString((long)r.tick_volume)+","+IntegerToString(r.spread)+","+IntegerToString((long)r.real_volume); }

bool AC_SharedOhlcEnsureRouteOnly()
{
   string d=""; bool ok=true;
   ok=AC_EnsureFolderPath(AC_SharedOhlcMarketDataFolder(),d)&&ok;
   ok=AC_EnsureFolderPath(AC_SharedOhlcRootFolder(),d)&&ok;
   ok=AC_EnsureFolderPath(AC_SharedOhlcStatusFolder(),d)&&ok;
   ok=AC_EnsureFolderPath(AC_SharedOhlcSymbolsFolder(),d)&&ok;
   ok=AC_EnsureFolderPath(AC_SharedOhlcFastWindowsFolder(),d)&&ok;
   AC_SHARED_OHLC_ROUTE_STATUS=ok?"folder_create_ok":"folder_create_degraded";
   return ok;
}

bool AC_SharedOhlcEnsureSymbolFolders(const string s)
{
   string d=""; bool ok=true;
   ok=AC_EnsureFolderPath(AC_SharedOhlcSymbolFolder(s),d)&&ok;
   ok=AC_EnsureFolderPath(AC_SharedOhlcCurrentFolder(s),d)&&ok;
   ok=AC_EnsureFolderPath(AC_SharedOhlcStateFolder(s),d)&&ok;
   return ok;
}

bool AC_SharedOhlcEnsureFastSymbolFolder(const string s)
{
   string d=""; return AC_EnsureFolderPath(AC_SharedOhlcFastSymbolFolder(s),d);
}

long AC_SharedOhlcReadLastTime(const string p)
{
   int flags=AC_FileFlags()|FILE_READ;
   ResetLastError(); int h=FileOpen(p,flags); if(h==INVALID_HANDLE)return 0;
   string v=FileReadString(h); FileClose(h); return (long)StringToInteger(v);
}

void AC_SharedOhlcWriteLastTime(const string p,const datetime t){ AC_WriteTextFileFastAtomic(p,IntegerToString((long)t)); }

bool AC_SharedOhlcAppendLine(const string p,const string line,const string header)
{
   bool exists=FileIsExist(p,AC_CommonFlag());
   ResetLastError(); int h=FileOpen(p,AC_FileFlags()|FILE_READ|FILE_WRITE);
   if(h==INVALID_HANDLE)return false;
   FileSeek(h,0,SEEK_END);
   if(!exists) FileWriteString(h,header);
   FileWriteString(h,line+"\r\n");
   FileFlush(h); FileClose(h); return true;
}

bool AC_SharedOhlcSymbolHasOpenPosition(const string s)
{
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      if(PositionGetSymbol(i)==s) return true;
   }
   return false;
}

bool AC_SharedOhlcSymbolHasPendingOrder(const string s)
{
   for(int i=OrdersTotal()-1;i>=0;i--)
   {
      ulong ticket=OrderGetTicket(i);
      if(ticket==0) continue;
      if(OrderGetString(ORDER_SYMBOL)==s) return true;
   }
   return false;
}

bool AC_SharedOhlcSymbolL5PassFast(const string s)
{
   for(int i=0;i<ArraySize(AC_L5_SYMBOLS);i++) if(AC_L5_SYMBOLS[i].symbol==s) return AC_L5_SYMBOLS[i].pass;
   return false;
}

bool AC_SharedOhlcSymbolFutureCandidateReserved(const string s)
{
   // P3 is a reserved hook only. This bridge must not infer future candidate/ranked/selected state.
   // Later Runtime 5/6/7 owners may publish an explicit source flag for this function to read.
   return false;
}

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
   int total=SymbolsTotal(false);
   int count=0;
   for(int i=0;i<total;i++)
   {
      string s=SymbolName(i,false);
      if(AC_SharedOhlcPriorityForSymbol(s)==priority) count++;
   }
   return count;
}

string AC_SharedOhlcSymbolByPriorityOrdinal(const int priority,const int ordinal)
{
   int total=SymbolsTotal(false);
   int seen=0;
   for(int i=0;i<total;i++)
   {
      string s=SymbolName(i,false);
      if(AC_SharedOhlcPriorityForSymbol(s)!=priority) continue;
      if(seen==ordinal) return s;
      seen++;
   }
   return "";
}

void AC_SharedOhlcMarkPriorityAttempt(const int priority,const bool l8_fast)
{
   AC_SHARED_OHLC_LAST_PRIORITY=priority;
   AC_SHARED_OHLC_LAST_PRIORITY_LABEL=AC_SharedOhlcPriorityLabel(priority);
   if(l8_fast)
   {
      if(priority==1) AC_SHARED_OHLC_L8_FAST_P1_ATTEMPTED++;
      else if(priority==2) AC_SHARED_OHLC_L8_FAST_P2_ATTEMPTED++;
      else if(priority==3) AC_SHARED_OHLC_L8_FAST_P3_ATTEMPTED++;
      else if(priority==4) AC_SHARED_OHLC_L8_FAST_P4_ATTEMPTED++;
      return;
   }
   if(priority==1) AC_SHARED_OHLC_P1_ATTEMPTED++;
   else if(priority==2) AC_SHARED_OHLC_P2_ATTEMPTED++;
   else if(priority==3) AC_SHARED_OHLC_P3_ATTEMPTED++;
   else if(priority==4) AC_SHARED_OHLC_P4_ATTEMPTED++;
   else AC_SHARED_OHLC_P5_ATTEMPTED++;
}

int AC_SharedOhlcGetIndexForPriority(const int priority,const bool append_mode)
{
   if(append_mode)
   {
      if(priority==1)return AC_SHARED_OHLC_APPEND_P1_INDEX;
      if(priority==2)return AC_SHARED_OHLC_APPEND_P2_INDEX;
      if(priority==3)return AC_SHARED_OHLC_APPEND_P3_INDEX;
      if(priority==4)return AC_SHARED_OHLC_APPEND_P4_INDEX;
      return AC_SHARED_OHLC_APPEND_P5_INDEX;
   }
   if(priority==1)return AC_SHARED_OHLC_SEED_P1_INDEX;
   if(priority==2)return AC_SHARED_OHLC_SEED_P2_INDEX;
   if(priority==3)return AC_SHARED_OHLC_SEED_P3_INDEX;
   if(priority==4)return AC_SHARED_OHLC_SEED_P4_INDEX;
   return AC_SHARED_OHLC_SEED_P5_INDEX;
}

void AC_SharedOhlcSetIndexForPriority(const int priority,const bool append_mode,const int value)
{
   if(append_mode)
   {
      if(priority==1)AC_SHARED_OHLC_APPEND_P1_INDEX=value;
      else if(priority==2)AC_SHARED_OHLC_APPEND_P2_INDEX=value;
      else if(priority==3)AC_SHARED_OHLC_APPEND_P3_INDEX=value;
      else if(priority==4)AC_SHARED_OHLC_APPEND_P4_INDEX=value;
      else AC_SHARED_OHLC_APPEND_P5_INDEX=value;
      return;
   }
   if(priority==1)AC_SHARED_OHLC_SEED_P1_INDEX=value;
   else if(priority==2)AC_SHARED_OHLC_SEED_P2_INDEX=value;
   else if(priority==3)AC_SHARED_OHLC_SEED_P3_INDEX=value;
   else if(priority==4)AC_SHARED_OHLC_SEED_P4_INDEX=value;
   else AC_SHARED_OHLC_SEED_P5_INDEX=value;
}

int AC_SharedOhlcGetL8FastIndexForPriority(const int priority)
{
   if(priority==1)return AC_SHARED_OHLC_L8_FAST_P1_INDEX;
   if(priority==2)return AC_SHARED_OHLC_L8_FAST_P2_INDEX;
   if(priority==3)return AC_SHARED_OHLC_L8_FAST_P3_INDEX;
   return AC_SHARED_OHLC_L8_FAST_P4_INDEX;
}

void AC_SharedOhlcSetL8FastIndexForPriority(const int priority,const int value)
{
   if(priority==1)AC_SHARED_OHLC_L8_FAST_P1_INDEX=value;
   else if(priority==2)AC_SHARED_OHLC_L8_FAST_P2_INDEX=value;
   else if(priority==3)AC_SHARED_OHLC_L8_FAST_P3_INDEX=value;
   else AC_SHARED_OHLC_L8_FAST_P4_INDEX=value;
}

void AC_SharedOhlcUpdateL8FastTotals()
{
   int total=0;
   for(int p=1;p<=4;p++) total+=AC_SharedOhlcPrioritySymbolCount(p)*AC_SharedOhlcL8FastTfCount();
   AC_SHARED_OHLC_L8_FAST_TOTAL=total;
   AC_SHARED_OHLC_L8_FAST_PENDING=AC_SHARED_OHLC_L8_FAST_TOTAL-AC_SHARED_OHLC_L8_FAST_ATTEMPTED;
   if(AC_SHARED_OHLC_L8_FAST_PENDING<0)AC_SHARED_OHLC_L8_FAST_PENDING=0;
   AC_SHARED_OHLC_L8_FAST_COMPLETE=(AC_SHARED_OHLC_L8_FAST_TOTAL>0 && AC_SHARED_OHLC_L8_FAST_ATTEMPTED>=AC_SHARED_OHLC_L8_FAST_TOTAL);
}

void AC_SharedOhlcUpdateTotals()
{
   AC_SHARED_OHLC_SYMBOLS_TOTAL=SymbolsTotal(false);
   AC_SHARED_OHLC_SYMBOL_TF_TOTAL=AC_SHARED_OHLC_SYMBOLS_TOTAL*AC_SHARED_OHLC_TIMEFRAMES_ENABLED;
   AC_SHARED_OHLC_SYMBOL_TF_PENDING=AC_SHARED_OHLC_SYMBOL_TF_TOTAL-AC_SHARED_OHLC_SYMBOL_TF_ATTEMPTED;
   if(AC_SHARED_OHLC_SYMBOL_TF_PENDING<0)AC_SHARED_OHLC_SYMBOL_TF_PENDING=0;
   AC_SHARED_OHLC_APPEND_BACKLOG_P1=AC_SharedOhlcPrioritySymbolCount(1)*AC_SHARED_OHLC_TIMEFRAMES_ENABLED;
   AC_SHARED_OHLC_APPEND_BACKLOG_P2=AC_SharedOhlcPrioritySymbolCount(2)*AC_SHARED_OHLC_TIMEFRAMES_ENABLED;
   AC_SHARED_OHLC_APPEND_BACKLOG_P3=AC_SharedOhlcPrioritySymbolCount(3)*AC_SHARED_OHLC_TIMEFRAMES_ENABLED;
   AC_SHARED_OHLC_APPEND_BACKLOG_P4=AC_SharedOhlcPrioritySymbolCount(4)*AC_SHARED_OHLC_TIMEFRAMES_ENABLED;
   AC_SHARED_OHLC_APPEND_BACKLOG_P5=AC_SharedOhlcPrioritySymbolCount(5)*AC_SHARED_OHLC_TIMEFRAMES_ENABLED;
   AC_SharedOhlcUpdateL8FastTotals();
}

bool AC_SharedOhlcSeedOne(const string s,const int tfi)
{
   string tf=AC_SharedOhlcTfLabel(tfi); ENUM_TIMEFRAMES e=AC_SharedOhlcTfEnum(tfi);
   AC_SHARED_OHLC_LAST_SYMBOL=s; AC_SHARED_OHLC_LAST_TF=tf; AC_SharedOhlcEnsureSymbolFolders(s);
   MqlRates rates[]; ResetLastError(); int copied=CopyRates(s,e,1,AC_SHARED_OHLC_TARGET_SEED_BARS,rates);
   AC_SHARED_OHLC_SYMBOL_TF_ATTEMPTED++;
   if(copied<=0){ AC_SHARED_OHLC_SYMBOL_TF_ERROR++; AC_SHARED_OHLC_LAST_TASK_STATUS="seed_copyrates_unavailable_"+IntegerToString(GetLastError()); return false; }
   string text=AC_SharedOhlcHeader(s,tf);
   for(int i=0;i<copied;i++) text+=AC_SharedOhlcRow(s,rates[i])+"\r\n";
   AC_WriteResult wr=AC_WriteTextFileFastAtomic(AC_SharedOhlcSeedPath(s,tf),text);
   if(!wr.ok){ AC_SHARED_OHLC_SYMBOL_TF_ERROR++; AC_SHARED_OHLC_LAST_TASK_STATUS="seed_write_failed_"+wr.status; return false; }
   AC_SharedOhlcWriteLastTime(AC_SharedOhlcLastTimePath(s,tf),rates[copied-1].time);
   MqlRates cur[]; if(CopyRates(s,e,0,1,cur)>0) AC_WriteTextFileFastAtomic(AC_SharedOhlcCurrentPath(s,tf),AC_SharedOhlcHeader(s,tf)+AC_SharedOhlcRow(s,cur[0])+"\r\n");
   if(copied>=AC_SHARED_OHLC_TARGET_SEED_BARS){ AC_SHARED_OHLC_SYMBOL_TF_SEEDED++; AC_SHARED_OHLC_LAST_TASK_STATUS="seed_complete"; }
   else { AC_SHARED_OHLC_SYMBOL_TF_PARTIAL++; AC_SHARED_OHLC_LAST_TASK_STATUS="seed_partial_"+IntegerToString(copied); }
   return true;
}

bool AC_SharedOhlcSeedL8FastForPriority(const int priority)
{
   int symbols=AC_SharedOhlcPrioritySymbolCount(priority);
   if(symbols<=0) return false;
   int index=AC_SharedOhlcGetL8FastIndexForPriority(priority);
   int total_tasks=symbols*AC_SharedOhlcL8FastTfCount();
   if(index>=total_tasks) return false;
   int symbol_ordinal=index/AC_SharedOhlcL8FastTfCount();
   int tf_index=index%AC_SharedOhlcL8FastTfCount();
   string s=AC_SharedOhlcSymbolByPriorityOrdinal(priority,symbol_ordinal);
   if(s=="") { AC_SharedOhlcSetL8FastIndexForPriority(priority,index+1); return true; }
   string tf=AC_SharedOhlcL8FastTfLabel(tf_index);
   ENUM_TIMEFRAMES e=AC_SharedOhlcL8FastTfEnum(tf_index);
   int target=AC_SharedOhlcL8FastBars(tf_index);
   AC_SharedOhlcMarkPriorityAttempt(priority,true);
   AC_SHARED_OHLC_LAST_SYMBOL=s; AC_SHARED_OHLC_LAST_TF=tf; AC_SharedOhlcEnsureFastSymbolFolder(s);
   MqlRates rates[]; ResetLastError(); int copied=CopyRates(s,e,1,target,rates);
   AC_SHARED_OHLC_L8_FAST_ATTEMPTED++;
   if(copied<=0)
   {
      AC_SHARED_OHLC_L8_FAST_ERROR++;
      AC_SHARED_OHLC_LAST_TASK_STATUS="l8_fast_"+AC_SHARED_OHLC_LAST_PRIORITY_LABEL+"_copyrates_unavailable_"+IntegerToString(GetLastError());
   }
   else
   {
      string text=AC_SharedOhlcHeader(s,tf);
      for(int i=0;i<copied;i++) text+=AC_SharedOhlcRow(s,rates[i])+"\r\n";
      AC_WriteResult wr=AC_WriteTextFileFastAtomic(AC_SharedOhlcFastWindowPath(s,tf),text);
      if(!wr.ok)
      {
         AC_SHARED_OHLC_L8_FAST_ERROR++;
         AC_SHARED_OHLC_LAST_TASK_STATUS="l8_fast_"+AC_SHARED_OHLC_LAST_PRIORITY_LABEL+"_write_failed_"+wr.status;
      }
      else if(copied>=target)
      {
         AC_SHARED_OHLC_L8_FAST_READY++;
         if(tf=="M5") AC_SHARED_OHLC_L8_FAST_M5_READY++;
         else if(tf=="M15") AC_SHARED_OHLC_L8_FAST_M15_READY++;
         else if(tf=="H1") AC_SHARED_OHLC_L8_FAST_H1_READY++;
         else if(tf=="H4") AC_SHARED_OHLC_L8_FAST_H4_READY++;
         AC_SHARED_OHLC_LAST_TASK_STATUS="l8_fast_"+AC_SHARED_OHLC_LAST_PRIORITY_LABEL+"_ready_"+IntegerToString(copied);
      }
      else
      {
         AC_SHARED_OHLC_L8_FAST_PARTIAL++;
         AC_SHARED_OHLC_LAST_TASK_STATUS="l8_fast_"+AC_SHARED_OHLC_LAST_PRIORITY_LABEL+"_partial_"+IntegerToString(copied)+"_of_"+IntegerToString(target);
      }
   }
   AC_SharedOhlcSetL8FastIndexForPriority(priority,index+1);
   AC_SharedOhlcUpdateL8FastTotals();
   return true;
}

bool AC_SharedOhlcSeedL8FastOne()
{
   for(int p=1;p<=4;p++) if(AC_SharedOhlcSeedL8FastForPriority(p)) return true;
   AC_SHARED_OHLC_L8_FAST_COMPLETE=true;
   AC_SHARED_OHLC_LAST_TASK_STATUS="l8_fast_priority_flow_complete";
   return false;
}

bool AC_SharedOhlcSeedPriorityOne(const int priority)
{
   int symbols=AC_SharedOhlcPrioritySymbolCount(priority);
   if(symbols<=0) return false;
   int index=AC_SharedOhlcGetIndexForPriority(priority,false);
   int total_tasks=symbols*AC_SHARED_OHLC_TIMEFRAMES_ENABLED;
   if(index>=total_tasks) return false;
   int symbol_ordinal=index/AC_SHARED_OHLC_TIMEFRAMES_ENABLED;
   int tf_index=index%AC_SHARED_OHLC_TIMEFRAMES_ENABLED;
   string s=AC_SharedOhlcSymbolByPriorityOrdinal(priority,symbol_ordinal);
   AC_SharedOhlcSetIndexForPriority(priority,false,index+1);
   if(s=="") return true;
   AC_SharedOhlcMarkPriorityAttempt(priority,false);
   return AC_SharedOhlcSeedOne(s,tf_index);
}

bool AC_SharedOhlcFullSeedPriorityOne()
{
   for(int p=1;p<=5;p++) if(AC_SharedOhlcSeedPriorityOne(p)) return true;
   AC_SHARED_OHLC_BOOT_SEED_COMPLETE=true;
   AC_SHARED_OHLC_MODE="append_only_priority_refresh";
   AC_SHARED_OHLC_STATUS=(AC_SHARED_OHLC_SYMBOL_TF_ERROR>0||AC_SHARED_OHLC_SYMBOL_TF_PARTIAL>0)?"seed_done_with_partial_or_errors_append_active":"seed_complete_append_active";
   AC_SHARED_OHLC_LAST_TASK_STATUS="full_seed_priority_flow_complete";
   return false;
}

bool AC_SharedOhlcAppendOne(const string s,const int tfi)
{
   string tf=AC_SharedOhlcTfLabel(tfi); ENUM_TIMEFRAMES e=AC_SharedOhlcTfEnum(tfi);
   AC_SHARED_OHLC_LAST_SYMBOL=s; AC_SHARED_OHLC_LAST_TF=tf; AC_SharedOhlcEnsureSymbolFolders(s);
   MqlRates r[]; if(CopyRates(s,e,1,1,r)<=0){AC_SHARED_OHLC_APPEND_ERROR++; AC_SHARED_OHLC_LAST_TASK_STATUS="append_"+AC_SHARED_OHLC_LAST_PRIORITY_LABEL+"_copyrates_unavailable"; return false;}
   long last=AC_SharedOhlcReadLastTime(AC_SharedOhlcLastTimePath(s,tf));
   if((long)r[0].time<=last){AC_SHARED_OHLC_APPEND_SKIPPED_DUPLICATE++; AC_SHARED_OHLC_LAST_TASK_STATUS="append_"+AC_SHARED_OHLC_LAST_PRIORITY_LABEL+"_no_new_closed_bar"; return true;}
   if(!AC_SharedOhlcAppendLine(AC_SharedOhlcAppendPath(s,tf),AC_SharedOhlcRow(s,r[0]),AC_SharedOhlcHeader(s,tf))){AC_SHARED_OHLC_APPEND_ERROR++; AC_SHARED_OHLC_LAST_TASK_STATUS="append_"+AC_SHARED_OHLC_LAST_PRIORITY_LABEL+"_write_failed"; return false;}
   AC_SharedOhlcWriteLastTime(AC_SharedOhlcLastTimePath(s,tf),r[0].time); AC_SHARED_OHLC_APPEND_WRITTEN++; AC_SHARED_OHLC_LAST_TASK_STATUS="append_"+AC_SHARED_OHLC_LAST_PRIORITY_LABEL+"_written"; return true;
}

bool AC_SharedOhlcAppendPriorityOne(const int priority)
{
   int symbols=AC_SharedOhlcPrioritySymbolCount(priority);
   if(symbols<=0) return false;
   int index=AC_SharedOhlcGetIndexForPriority(priority,true);
   int total_tasks=symbols*AC_SHARED_OHLC_TIMEFRAMES_ENABLED;
   if(total_tasks<=0) return false;
   if(index>=total_tasks) index=0;
   int symbol_ordinal=index/AC_SHARED_OHLC_TIMEFRAMES_ENABLED;
   int tf_index=index%AC_SHARED_OHLC_TIMEFRAMES_ENABLED;
   string s=AC_SharedOhlcSymbolByPriorityOrdinal(priority,symbol_ordinal);
   AC_SharedOhlcSetIndexForPriority(priority,true,index+1);
   if(s=="") return true;
   AC_SharedOhlcMarkPriorityAttempt(priority,false);
   return AC_SharedOhlcAppendOne(s,tf_index);
}

bool AC_SharedOhlcAppendPriorityRefreshOne()
{
   for(int p=1;p<=5;p++) if(AC_SharedOhlcAppendPriorityOne(p)) return true;
   AC_SHARED_OHLC_LAST_TASK_STATUS="append_priority_flow_no_symbols";
   return false;
}

void AC_SharedOhlcApplyAdaptiveThrottle()
{
   if(AC_SHARED_OHLC_LAST_SERVICE_MS>500)
   {
      AC_SHARED_OHLC_ADAPTIVE_MODE="cooldown";
      AC_SHARED_OHLC_TASKS_PER_SERVICE=1;
      AC_SHARED_OHLC_SERVICE_INTERVAL_MS=2000;
      AC_SHARED_OHLC_SERVICE_BUDGET_MS=80;
      AC_SHARED_OHLC_COOLDOWN_RUNS=10;
      AC_SHARED_OHLC_FAST_STREAK=0;
      return;
   }
   if(AC_SHARED_OHLC_COOLDOWN_RUNS>0)
   {
      AC_SHARED_OHLC_COOLDOWN_RUNS--;
      AC_SHARED_OHLC_ADAPTIVE_MODE="cooldown";
      AC_SHARED_OHLC_TASKS_PER_SERVICE=1;
      AC_SHARED_OHLC_SERVICE_INTERVAL_MS=2000;
      AC_SHARED_OHLC_SERVICE_BUDGET_MS=80;
      return;
   }
   if(AC_SHARED_OHLC_LAST_SERVICE_MS>250)
   {
      AC_SHARED_OHLC_ADAPTIVE_MODE="protective";
      AC_SHARED_OHLC_TASKS_PER_SERVICE=1;
      AC_SHARED_OHLC_SERVICE_INTERVAL_MS=1000;
      AC_SHARED_OHLC_SERVICE_BUDGET_MS=80;
      AC_SHARED_OHLC_FAST_STREAK=0;
      return;
   }
   if(AC_SHARED_OHLC_LAST_SERVICE_MS<80) AC_SHARED_OHLC_FAST_STREAK++; else AC_SHARED_OHLC_FAST_STREAK=0;
   if(AC_SHARED_OHLC_FAST_STREAK>=5)
   {
      AC_SHARED_OHLC_ADAPTIVE_MODE="fast";
      AC_SHARED_OHLC_TASKS_PER_SERVICE=4;
      AC_SHARED_OHLC_SERVICE_INTERVAL_MS=250;
      AC_SHARED_OHLC_SERVICE_BUDGET_MS=120;
      return;
   }
   AC_SHARED_OHLC_ADAPTIVE_MODE="normal";
   AC_SHARED_OHLC_TASKS_PER_SERVICE=2;
   AC_SHARED_OHLC_SERVICE_INTERVAL_MS=500;
   AC_SHARED_OHLC_SERVICE_BUDGET_MS=120;
}

void AC_SharedOhlcService()
{
   uint now=GetTickCount(); if(now-AC_SHARED_OHLC_LAST_RUN_TICK<AC_SHARED_OHLC_SERVICE_INTERVAL_MS)return; AC_SHARED_OHLC_LAST_RUN_TICK=now;
   uint start=GetTickCount(); AC_SharedOhlcEnsureRouteOnly(); AC_SharedOhlcUpdateTotals(); int tasks=0; AC_SHARED_OHLC_SERVICE_TASKS_USED=0;
   while(tasks<AC_SHARED_OHLC_TASKS_PER_SERVICE && (GetTickCount()-start)<AC_SHARED_OHLC_SERVICE_BUDGET_MS && AC_SHARED_OHLC_SYMBOLS_TOTAL>0)
   {
      if(!AC_SHARED_OHLC_L8_FAST_COMPLETE) AC_SharedOhlcSeedL8FastOne();
      else if(!AC_SHARED_OHLC_BOOT_SEED_COMPLETE) AC_SharedOhlcFullSeedPriorityOne();
      else AC_SharedOhlcAppendPriorityRefreshOne();
      tasks++; AC_SHARED_OHLC_SERVICE_TASKS_USED=tasks;
   }
   AC_SHARED_OHLC_LAST_SERVICE_MS=GetTickCount()-start; AC_SharedOhlcUpdateTotals(); AC_SharedOhlcApplyAdaptiveThrottle();
   if(!AC_SHARED_OHLC_L8_FAST_COMPLETE) AC_SHARED_OHLC_MODE="l8_fast_window_priority_seed_active";

   string status="schema_name=shared_ohlc_raw_store_status\r\nschema_version=active_raw_store_v3\r\nowner=Runtime 1 Shared OHLC Raw Storage Owner\r\nstatus="+AC_SHARED_OHLC_STATUS+"\r\nmode="+AC_SHARED_OHLC_MODE+"\r\nscope=broker_universe_symbols_total_false\r\npriority_policy=P1_open_pending_then_P2_L5_pass_then_P3_reserved_then_P4_other_open_then_P5_closed_blocked_unknown\r\nroute_root="+AC_SharedOhlcRootFolder()+"\r\nsymbols_total="+IntegerToString(AC_SHARED_OHLC_SYMBOLS_TOTAL)+"\r\ntimeframes_enabled="+IntegerToString(AC_SHARED_OHLC_TIMEFRAMES_ENABLED)+"\r\ntarget_seed_bars="+IntegerToString(AC_SHARED_OHLC_TARGET_SEED_BARS)+"\r\nsymbol_tf_total="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_TOTAL)+"\r\nsymbol_tf_attempted="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_ATTEMPTED)+"\r\nsymbol_tf_seeded="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_SEEDED)+"\r\nsymbol_tf_partial="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_PARTIAL)+"\r\nsymbol_tf_error="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_ERROR)+"\r\nsymbol_tf_pending="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_PENDING)+"\r\npriority_attempted_p1="+IntegerToString(AC_SHARED_OHLC_P1_ATTEMPTED)+"\r\npriority_attempted_p2="+IntegerToString(AC_SHARED_OHLC_P2_ATTEMPTED)+"\r\npriority_attempted_p3="+IntegerToString(AC_SHARED_OHLC_P3_ATTEMPTED)+"\r\npriority_attempted_p4="+IntegerToString(AC_SHARED_OHLC_P4_ATTEMPTED)+"\r\npriority_attempted_p5="+IntegerToString(AC_SHARED_OHLC_P5_ATTEMPTED)+"\r\nl8_fast_window_total="+IntegerToString(AC_SHARED_OHLC_L8_FAST_TOTAL)+"\r\nl8_fast_window_attempted="+IntegerToString(AC_SHARED_OHLC_L8_FAST_ATTEMPTED)+"\r\nl8_fast_window_ready="+IntegerToString(AC_SHARED_OHLC_L8_FAST_READY)+"\r\nl8_fast_window_partial="+IntegerToString(AC_SHARED_OHLC_L8_FAST_PARTIAL)+"\r\nl8_fast_window_error="+IntegerToString(AC_SHARED_OHLC_L8_FAST_ERROR)+"\r\nl8_fast_window_pending="+IntegerToString(AC_SHARED_OHLC_L8_FAST_PENDING)+"\r\nl8_fast_window_complete="+(AC_SHARED_OHLC_L8_FAST_COMPLETE?"true":"false")+"\r\nl8_fast_p1_attempted="+IntegerToString(AC_SHARED_OHLC_L8_FAST_P1_ATTEMPTED)+"\r\nl8_fast_p2_attempted="+IntegerToString(AC_SHARED_OHLC_L8_FAST_P2_ATTEMPTED)+"\r\nl8_fast_p3_attempted="+IntegerToString(AC_SHARED_OHLC_L8_FAST_P3_ATTEMPTED)+"\r\nl8_fast_p4_attempted="+IntegerToString(AC_SHARED_OHLC_L8_FAST_P4_ATTEMPTED)+"\r\nl8_fast_m5_ready="+IntegerToString(AC_SHARED_OHLC_L8_FAST_M5_READY)+"\r\nl8_fast_m15_ready="+IntegerToString(AC_SHARED_OHLC_L8_FAST_M15_READY)+"\r\nl8_fast_h1_ready="+IntegerToString(AC_SHARED_OHLC_L8_FAST_H1_READY)+"\r\nl8_fast_h4_ready="+IntegerToString(AC_SHARED_OHLC_L8_FAST_H4_READY)+"\r\nfull_seed_scheduler_active="+(AC_SHARED_OHLC_BOOT_SEED_COMPLETE?"false":"true")+"\r\ncopyrates_fetch_active=true\r\nlast_priority="+AC_SHARED_OHLC_LAST_PRIORITY_LABEL+"\r\nlast_symbol="+AC_SHARED_OHLC_LAST_SYMBOL+"\r\nlast_timeframe="+AC_SHARED_OHLC_LAST_TF+"\r\nlast_task_status="+AC_SHARED_OHLC_LAST_TASK_STATUS+"\r\nlast_service_ms="+IntegerToString((int)AC_SHARED_OHLC_LAST_SERVICE_MS)+"\r\nservice_tasks_used="+IntegerToString(AC_SHARED_OHLC_SERVICE_TASKS_USED)+"\r\nservice_tasks_per_run="+IntegerToString(AC_SHARED_OHLC_TASKS_PER_SERVICE)+"\r\nservice_interval_ms="+IntegerToString((int)AC_SHARED_OHLC_SERVICE_INTERVAL_MS)+"\r\nservice_budget_ms="+IntegerToString((int)AC_SHARED_OHLC_SERVICE_BUDGET_MS)+"\r\nadaptive_mode="+AC_SHARED_OHLC_ADAPTIVE_MODE+"\r\ncooldown_runs="+IntegerToString(AC_SHARED_OHLC_COOLDOWN_RUNS)+"\r\nraw_bars_written=true\r\ntrade_permission=false\r\nselection_runtime=false\r\ncalculation_runtime=false\r\n";
   AC_WriteResult sw=AC_WriteTextFileFastAtomic(AC_SharedOhlcStatusPath(),status); AC_SHARED_OHLC_STATUS_WRITE=sw.status;
   string mf="schema_name=shared_ohlc_raw_store_manifest\r\nschema_version=active_raw_store_v3\r\nowner=Runtime 1 Shared OHLC Raw Storage Owner\r\nroute_root="+AC_SharedOhlcRootFolder()+"\r\nstatus_path="+AC_SharedOhlcStatusPath()+"\r\nmanifest_path="+AC_SharedOhlcManifestPath()+"\r\nsymbols_folder="+AC_SharedOhlcSymbolsFolder()+"\r\nfast_windows_folder="+AC_SharedOhlcFastWindowsFolder()+"\r\nscope=broker_universe_symbols_total_false\r\npriority_policy=P1_open_pending_then_P2_L5_pass_then_P3_reserved_then_P4_other_open_then_P5_closed_blocked_unknown\r\ncopyrates_fetch_active=true\r\nl8_fast_window_active="+(AC_SHARED_OHLC_L8_FAST_COMPLETE?"false":"true")+"\r\nl8_fast_window_complete="+(AC_SHARED_OHLC_L8_FAST_COMPLETE?"true":"false")+"\r\nl8_fast_window_ready="+IntegerToString(AC_SHARED_OHLC_L8_FAST_READY)+"\r\nl8_fast_window_total="+IntegerToString(AC_SHARED_OHLC_L8_FAST_TOTAL)+"\r\nfull_seed_scheduler_active="+(AC_SHARED_OHLC_BOOT_SEED_COMPLETE?"false":"true")+"\r\nappend_mode_active="+(AC_SHARED_OHLC_BOOT_SEED_COMPLETE?"true":"false")+"\r\nraw_bars_printed_to_board=false\r\nraw_bars_printed_to_dossier=false\r\nroute_status="+AC_SHARED_OHLC_ROUTE_STATUS+"\r\nstatus_write="+AC_SHARED_OHLC_STATUS_WRITE+"\r\nservice_tasks_per_run="+IntegerToString(AC_SHARED_OHLC_TASKS_PER_SERVICE)+"\r\nservice_interval_ms="+IntegerToString((int)AC_SHARED_OHLC_SERVICE_INTERVAL_MS)+"\r\nadaptive_mode="+AC_SHARED_OHLC_ADAPTIVE_MODE+"\r\nlast_priority="+AC_SHARED_OHLC_LAST_PRIORITY_LABEL+"\r\n";
   AC_WriteResult mw=AC_WriteTextFileFastAtomic(AC_SharedOhlcManifestPath(),mf); AC_SHARED_OHLC_MANIFEST_WRITE=mw.status;
}

string AC_SharedOhlcRenderBoardSection()
{
   AC_SharedOhlcService();
   string text="\r\nSHARED OHLC RAW STORE\r\n----------------------------------------\r\n";
   text+="Status:                 "+AC_SHARED_OHLC_STATUS+"\r\nMode:                   "+AC_SHARED_OHLC_MODE+"\r\nPriority Flow:          P1 open/pending -> P2 L5 pass -> P3 reserved -> P4 other open -> P5 closed/blocked/unknown\r\nLast Priority:          "+AC_SHARED_OHLC_LAST_PRIORITY_LABEL+"\r\nRoute Root:             "+AC_SharedOhlcRootFolder()+"\r\nFast Windows Route:     "+AC_SharedOhlcFastWindowsFolder()+"\r\nRoute Status:           "+AC_SHARED_OHLC_ROUTE_STATUS+"\r\nStatus File Write:      "+AC_SHARED_OHLC_STATUS_WRITE+"\r\nManifest File Write:    "+AC_SHARED_OHLC_MANIFEST_WRITE+"\r\nSymbols Tracked:        "+IntegerToString(AC_SHARED_OHLC_SYMBOLS_TOTAL)+"\r\nTimeframes Enabled:     "+IntegerToString(AC_SHARED_OHLC_TIMEFRAMES_ENABLED)+"\r\nTarget Bars / TF:       "+IntegerToString(AC_SHARED_OHLC_TARGET_SEED_BARS)+"\r\nL8 Fast Windows:        "+IntegerToString(AC_SHARED_OHLC_L8_FAST_READY)+" ready / "+IntegerToString(AC_SHARED_OHLC_L8_FAST_TOTAL)+" total\r\nL8 Fast P1/P2/P3/P4:    "+IntegerToString(AC_SHARED_OHLC_L8_FAST_P1_ATTEMPTED)+" / "+IntegerToString(AC_SHARED_OHLC_L8_FAST_P2_ATTEMPTED)+" / "+IntegerToString(AC_SHARED_OHLC_L8_FAST_P3_ATTEMPTED)+" / "+IntegerToString(AC_SHARED_OHLC_L8_FAST_P4_ATTEMPTED)+"\r\nL8 Fast M5/M15/H1/H4:   "+IntegerToString(AC_SHARED_OHLC_L8_FAST_M5_READY)+" / "+IntegerToString(AC_SHARED_OHLC_L8_FAST_M15_READY)+" / "+IntegerToString(AC_SHARED_OHLC_L8_FAST_H1_READY)+" / "+IntegerToString(AC_SHARED_OHLC_L8_FAST_H4_READY)+"\r\nL8 Fast Partial/Error:  "+IntegerToString(AC_SHARED_OHLC_L8_FAST_PARTIAL)+" / "+IntegerToString(AC_SHARED_OHLC_L8_FAST_ERROR)+"\r\nAttempted Symbol-TFs:   "+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_ATTEMPTED)+" / "+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_TOTAL)+"\r\nPriority Attempts P1-P5:"+IntegerToString(AC_SHARED_OHLC_P1_ATTEMPTED)+" / "+IntegerToString(AC_SHARED_OHLC_P2_ATTEMPTED)+" / "+IntegerToString(AC_SHARED_OHLC_P3_ATTEMPTED)+" / "+IntegerToString(AC_SHARED_OHLC_P4_ATTEMPTED)+" / "+IntegerToString(AC_SHARED_OHLC_P5_ATTEMPTED)+"\r\nSeeded Symbol-TFs:      "+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_SEEDED)+"\r\nPartial Symbol-TFs:     "+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_PARTIAL)+"\r\nError Symbol-TFs:       "+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_ERROR)+"\r\nPending Symbol-TFs:     "+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_PENDING)+"\r\nLast Task:              "+AC_SHARED_OHLC_LAST_SYMBOL+" "+AC_SHARED_OHLC_LAST_TF+" "+AC_SHARED_OHLC_LAST_TASK_STATUS+"\r\nService Duration:       "+IntegerToString((int)AC_SHARED_OHLC_LAST_SERVICE_MS)+" ms\r\nService Throttle:       mode="+AC_SHARED_OHLC_ADAPTIVE_MODE+" tasks="+IntegerToString(AC_SHARED_OHLC_TASKS_PER_SERVICE)+" interval_ms="+IntegerToString((int)AC_SHARED_OHLC_SERVICE_INTERVAL_MS)+" budget_ms="+IntegerToString((int)AC_SHARED_OHLC_SERVICE_BUDGET_MS)+"\r\nRaw Bars Printed:       FALSE\r\nTrade Permission:       FALSE\r\n";
   return text;
}

string AC_SharedOhlcRenderDossierSection(const string symbol)
{
   AC_SharedOhlcEnsureRouteOnly();
   string m5=FileIsExist(AC_SharedOhlcFastWindowPath(symbol,"M5"),AC_CommonFlag())?"available":"pending";
   string m15=FileIsExist(AC_SharedOhlcFastWindowPath(symbol,"M15"),AC_CommonFlag())?"available":"pending";
   string h1=FileIsExist(AC_SharedOhlcFastWindowPath(symbol,"H1"),AC_CommonFlag())?"available":"pending";
   string h4=FileIsExist(AC_SharedOhlcFastWindowPath(symbol,"H4"),AC_CommonFlag())?"available":"pending";
   bool l8_min=(m5=="available" && m15=="available" && h1=="available");
   int priority=AC_SharedOhlcPriorityForSymbol(symbol);
   string text="\r\nSHARED OHLC RAW STORE OVERVIEW\r\n----------------------------------------\r\n";
   text+="Owner:                  Runtime 1 Shared OHLC Raw Storage Owner\r\nSymbol:                 "+symbol+"\r\nSymbol Priority:        "+AC_SharedOhlcPriorityLabel(priority)+"\r\nStore Status:           "+AC_SHARED_OHLC_STATUS+"\r\nStore Mode:             "+AC_SHARED_OHLC_MODE+"\r\nRaw Store Route:        "+AC_SharedOhlcRootFolder()+"\r\nSymbol Store Route:     "+AC_SharedOhlcSymbolFolder(symbol)+"\r\nFast Window Route:      "+AC_SharedOhlcFastSymbolFolder(symbol)+"\r\nL8 Minimum Ready:       "+(l8_min?"TRUE":"FALSE")+"\r\nL8 M5 Window:           "+m5+"\r\nL8 M15 Window:          "+m15+"\r\nL8 H1 Window:           "+h1+"\r\nL8 H4 Context Window:   "+h4+"\r\nRaw Bars Shown Here:    FALSE\r\nCalculation Policy:     no_calculations_in_mt5_raw_storage_owner\r\n";
   return text;
}

string AC_SharedOhlcRenderWorkbenchSection()
{
   AC_SharedOhlcService();
   string text="SHARED_OHLC_RAW_STORAGE_OWNER\r\n----------------------------------------\r\n";
   text+="shared_ohlc_status="+AC_SHARED_OHLC_STATUS+"\r\nshared_ohlc_mode="+AC_SHARED_OHLC_MODE+"\r\nshared_ohlc_priority_policy=P1_open_pending_then_P2_L5_pass_then_P3_reserved_then_P4_other_open_then_P5_closed_blocked_unknown\r\nshared_ohlc_last_priority="+AC_SHARED_OHLC_LAST_PRIORITY_LABEL+"\r\nshared_ohlc_route_root="+AC_SharedOhlcRootFolder()+"\r\nshared_ohlc_fast_windows_folder="+AC_SharedOhlcFastWindowsFolder()+"\r\nshared_ohlc_status_path="+AC_SharedOhlcStatusPath()+"\r\nshared_ohlc_manifest_path="+AC_SharedOhlcManifestPath()+"\r\nshared_ohlc_route_status="+AC_SHARED_OHLC_ROUTE_STATUS+"\r\nshared_ohlc_status_write="+AC_SHARED_OHLC_STATUS_WRITE+"\r\nshared_ohlc_manifest_write="+AC_SHARED_OHLC_MANIFEST_WRITE+"\r\nshared_ohlc_scope=broker_universe_symbols_total_false\r\nshared_ohlc_copyrates_fetch_active=true\r\nshared_ohlc_l8_fast_window_complete="+(AC_SHARED_OHLC_L8_FAST_COMPLETE?"true":"false")+"\r\nshared_ohlc_l8_fast_window_total="+IntegerToString(AC_SHARED_OHLC_L8_FAST_TOTAL)+"\r\nshared_ohlc_l8_fast_window_attempted="+IntegerToString(AC_SHARED_OHLC_L8_FAST_ATTEMPTED)+"\r\nshared_ohlc_l8_fast_window_ready="+IntegerToString(AC_SHARED_OHLC_L8_FAST_READY)+"\r\nshared_ohlc_l8_fast_window_partial="+IntegerToString(AC_SHARED_OHLC_L8_FAST_PARTIAL)+"\r\nshared_ohlc_l8_fast_window_error="+IntegerToString(AC_SHARED_OHLC_L8_FAST_ERROR)+"\r\nshared_ohlc_l8_fast_p1_attempted="+IntegerToString(AC_SHARED_OHLC_L8_FAST_P1_ATTEMPTED)+"\r\nshared_ohlc_l8_fast_p2_attempted="+IntegerToString(AC_SHARED_OHLC_L8_FAST_P2_ATTEMPTED)+"\r\nshared_ohlc_l8_fast_p3_attempted="+IntegerToString(AC_SHARED_OHLC_L8_FAST_P3_ATTEMPTED)+"\r\nshared_ohlc_l8_fast_p4_attempted="+IntegerToString(AC_SHARED_OHLC_L8_FAST_P4_ATTEMPTED)+"\r\nshared_ohlc_l8_fast_m5_ready="+IntegerToString(AC_SHARED_OHLC_L8_FAST_M5_READY)+"\r\nshared_ohlc_l8_fast_m15_ready="+IntegerToString(AC_SHARED_OHLC_L8_FAST_M15_READY)+"\r\nshared_ohlc_l8_fast_h1_ready="+IntegerToString(AC_SHARED_OHLC_L8_FAST_H1_READY)+"\r\nshared_ohlc_l8_fast_h4_ready="+IntegerToString(AC_SHARED_OHLC_L8_FAST_H4_READY)+"\r\nshared_ohlc_full_seed_scheduler_active="+(AC_SHARED_OHLC_BOOT_SEED_COMPLETE?"false":"true")+"\r\nshared_ohlc_append_mode_active="+(AC_SHARED_OHLC_BOOT_SEED_COMPLETE?"true":"false")+"\r\nshared_ohlc_symbol_tf_total="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_TOTAL)+"\r\nshared_ohlc_symbol_tf_attempted="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_ATTEMPTED)+"\r\nshared_ohlc_priority_attempted_p1="+IntegerToString(AC_SHARED_OHLC_P1_ATTEMPTED)+"\r\nshared_ohlc_priority_attempted_p2="+IntegerToString(AC_SHARED_OHLC_P2_ATTEMPTED)+"\r\nshared_ohlc_priority_attempted_p3="+IntegerToString(AC_SHARED_OHLC_P3_ATTEMPTED)+"\r\nshared_ohlc_priority_attempted_p4="+IntegerToString(AC_SHARED_OHLC_P4_ATTEMPTED)+"\r\nshared_ohlc_priority_attempted_p5="+IntegerToString(AC_SHARED_OHLC_P5_ATTEMPTED)+"\r\nshared_ohlc_symbol_tf_seeded="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_SEEDED)+"\r\nshared_ohlc_symbol_tf_partial="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_PARTIAL)+"\r\nshared_ohlc_symbol_tf_error="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_ERROR)+"\r\nshared_ohlc_symbol_tf_pending="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_PENDING)+"\r\nshared_ohlc_append_written="+IntegerToString(AC_SHARED_OHLC_APPEND_WRITTEN)+"\r\nshared_ohlc_last_service_ms="+IntegerToString((int)AC_SHARED_OHLC_LAST_SERVICE_MS)+"\r\nshared_ohlc_service_tasks_used="+IntegerToString(AC_SHARED_OHLC_SERVICE_TASKS_USED)+"\r\nshared_ohlc_service_tasks_per_run="+IntegerToString(AC_SHARED_OHLC_TASKS_PER_SERVICE)+"\r\nshared_ohlc_service_interval_ms="+IntegerToString((int)AC_SHARED_OHLC_SERVICE_INTERVAL_MS)+"\r\nshared_ohlc_service_budget_ms="+IntegerToString((int)AC_SHARED_OHLC_SERVICE_BUDGET_MS)+"\r\nshared_ohlc_adaptive_mode="+AC_SHARED_OHLC_ADAPTIVE_MODE+"\r\nshared_ohlc_cooldown_runs="+IntegerToString(AC_SHARED_OHLC_COOLDOWN_RUNS)+"\r\nshared_ohlc_last_task="+AC_SHARED_OHLC_LAST_SYMBOL+"|"+AC_SHARED_OHLC_LAST_TF+"|"+AC_SHARED_OHLC_LAST_TASK_STATUS+"\r\nshared_ohlc_raw_bars_printed_to_board=false\r\nshared_ohlc_raw_bars_printed_to_dossier=false\r\n";
   return text;
}

#include "AC_Layer7SessionRelevanceRenderer.mqh"
#include "AC_Layer6RankedSidecarRenderer.mqh"
#include "AC_Layer0DossierPublication.mqh"
#include "AC_MarketBoardRenderer.mqh"

#endif