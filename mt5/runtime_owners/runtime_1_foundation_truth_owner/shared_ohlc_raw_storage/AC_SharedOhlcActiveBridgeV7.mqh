#ifndef AC_SHARED_OHLC_ACTIVE_BRIDGE_V7_MQH
#define AC_SHARED_OHLC_ACTIVE_BRIDGE_V7_MQH

// Runtime 1 Shared OHLC Raw Storage Owner - active bridge v7.
// Single visible publisher per symbol/timeframe:
//   OHLC Store/Symbols/<symbol>/<TF>.seed.csv
// No visible Current, State, Priority Windows, append, or fast-window folders are created by this owner.
// L8 compatibility reads the same seed files through legacy function names.
// Raw MT5 CopyRates/MqlRates storage only. No ranking, selection, permission, execution, or calculations here.

static string AC_SHARED_OHLC_STATUS = "seed_active";
static string AC_SHARED_OHLC_MODE = "single_file_per_symbol_timeframe_seed_refresh";
static bool   AC_SHARED_OHLC_BOOT_SEED_COMPLETE = false;
static bool   AC_SHARED_OHLC_PRIORITY_WINDOW_COMPLETE = true;
static int    AC_SHARED_OHLC_TIMEFRAMES_ENABLED = 6;
static int    AC_SHARED_OHLC_TARGET_SEED_BARS = 1500;
static int    AC_SHARED_OHLC_SYMBOLS_TOTAL = 0;
static int    AC_SHARED_OHLC_SYMBOL_TF_TOTAL = 0;
static int    AC_SHARED_OHLC_SYMBOL_TF_ATTEMPTED = 0;
static int    AC_SHARED_OHLC_SYMBOL_TF_SEEDED = 0;
static int    AC_SHARED_OHLC_SYMBOL_TF_PARTIAL = 0;
static int    AC_SHARED_OHLC_SYMBOL_TF_ERROR = 0;
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
static int    AC_SHARED_OHLC_TOPUP_ATTEMPTED = 0;
static int    AC_SHARED_OHLC_TOPUP_IMPROVED = 0;
static int    AC_SHARED_OHLC_TOPUP_STILL_PARTIAL = 0;
static int    AC_SHARED_OHLC_TOPUP_SKIPPED_COMPLETE = 0;
static int    AC_SHARED_OHLC_TOPUP_ERROR = 0;
static int    AC_SHARED_OHLC_SEED_CURSOR = 0;
static int    AC_SHARED_OHLC_REFRESH_CURSOR = 0;
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
static uint   AC_SHARED_OHLC_SERVICE_BUDGET_MS = 160;
static uint   AC_SHARED_OHLC_SERVICE_INTERVAL_MS = 500;
static uint   AC_SHARED_OHLC_LAST_RUN_TICK = 0;
static string AC_SHARED_OHLC_ADAPTIVE_MODE = "single_file_seed_refresh";
static int    AC_SHARED_OHLC_COOLDOWN_RUNS = 0;
static int    AC_SHARED_OHLC_SERVICE_TASKS_USED = 0;

string AC_SharedOhlcServerFolder(){ return AC_BASE_FOLDER + "\\" + AC_ServerNameForRoute(); }
string AC_SharedOhlcMarketDataFolder(){ return AC_SharedOhlcServerFolder() + "\\Shared Market Data"; }
string AC_SharedOhlcRootFolder(){ return AC_SharedOhlcMarketDataFolder() + "\\OHLC Store"; }
string AC_SharedOhlcStatusFolder(){ return AC_SharedOhlcRootFolder() + "\\Status"; }
string AC_SharedOhlcSymbolsFolder(){ return AC_SharedOhlcRootFolder() + "\\Symbols"; }
string AC_SharedOhlcStatusPath(){ return AC_SharedOhlcStatusFolder() + "\\status.txt"; }
string AC_SharedOhlcManifestPath(){ return AC_SharedOhlcStatusFolder() + "\\manifest.txt"; }
string AC_SharedOhlcSymbolFolder(const string s){ return AC_SharedOhlcSymbolsFolder() + "\\" + AC_SanitizePathPart(s); }
string AC_SharedOhlcSeedPath(const string s,const string tf){ return AC_SharedOhlcSymbolFolder(s)+"\\"+tf+".seed.csv"; }
string AC_SharedOhlcFastWindowPath(const string s,const string tf){ return AC_SharedOhlcSeedPath(s,tf); }
string AC_SharedOhlcCurrentPath(const string s,const string tf){ return AC_SharedOhlcSeedPath(s,tf); }
string AC_SharedOhlcAppendPath(const string s,const string tf){ return AC_SharedOhlcSeedPath(s,tf); }
string AC_SharedOhlcWindowFolder(const string s){ return AC_SharedOhlcSymbolFolder(s); }

string AC_SharedOhlcTfLabel(const int i){ if(i==0)return "M1"; if(i==1)return "M5"; if(i==2)return "M15"; if(i==3)return "H1"; if(i==4)return "H4"; return "D1"; }
ENUM_TIMEFRAMES AC_SharedOhlcTfEnum(const int i){ if(i==0)return PERIOD_M1; if(i==1)return PERIOD_M5; if(i==2)return PERIOD_M15; if(i==3)return PERIOD_H1; if(i==4)return PERIOD_H4; return PERIOD_D1; }
int AC_SharedOhlcTfIndexFromLabel(const string tf){ if(tf=="M1")return 0; if(tf=="M5")return 1; if(tf=="M15")return 2; if(tf=="H1")return 3; if(tf=="H4")return 4; return 5; }

string AC_SharedOhlcPriorityLabel(const int p)
{
   if(p==1)return "P1_open_positions_or_pending_orders";
   if(p==2)return "P2_layer5_pass_symbols";
   if(p==3)return "P3_future_candidate_ranked_selected_reserved";
   if(p==4)return "P4_other_open_symbols";
   return "P5_closed_blocked_unknown_low_priority";
}

bool AC_SharedOhlcSymbolHasOpenPosition(const string s){ for(int i=PositionsTotal()-1;i>=0;i--) if(PositionGetSymbol(i)==s) return true; return false; }
bool AC_SharedOhlcSymbolHasPendingOrder(const string s){ for(int i=OrdersTotal()-1;i>=0;i--){ ulong ticket=OrderGetTicket(i); if(ticket!=0 && OrderGetString(ORDER_SYMBOL)==s) return true; } return false; }
bool AC_SharedOhlcSymbolL5PassFast(const string s){ for(int i=0;i<ArraySize(AC_L5_SYMBOLS);i++) if(AC_L5_SYMBOLS[i].symbol==s) return AC_L5_SYMBOLS[i].pass; return false; }
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

long AC_SharedOhlcPricePoints(const string s,const double p){ double pt=SymbolInfoDouble(s,SYMBOL_POINT); if(pt<=0.0)return 0; return (long)MathRound(p/pt); }
string AC_SharedOhlcHeader(const string s,const string tf){ return "#schema=shared_ohlc_raw_v2_single_file\r\n#owner=Runtime 1 Shared OHLC Raw Storage Owner\r\n#symbol="+s+"\r\n#timeframe="+tf+"\r\n#price_encoding=integer_points\r\nbar_time,open_i,high_i,low_i,close_i,tick_volume,spread,real_volume\r\n"; }
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

bool AC_SharedOhlcEnsureSymbolFolder(const string s)
{
   string d="";
   return AC_EnsureFolderPath(AC_SharedOhlcSymbolFolder(s),d);
}

int AC_SharedOhlcSeedFileRows(const string s,const string tf)
{
   string path=AC_SharedOhlcSeedPath(s,tf);
   ResetLastError(); int h=FileOpen(path,AC_FileFlags()|FILE_READ); if(h==INVALID_HANDLE) return 0;
   int rows=0;
   while(!FileIsEnding(h))
   {
      string line=FileReadString(h);
      if(StringLen(line)>0 && StringSubstr(line,0,1)!="#" && StringFind(line,"bar_time")!=0) rows++;
   }
   FileClose(h);
   return rows;
}

void AC_SharedOhlcMarkPriorityAttempt(const int p)
{
   AC_SHARED_OHLC_LAST_PRIORITY=p; AC_SHARED_OHLC_LAST_PRIORITY_LABEL=AC_SharedOhlcPriorityLabel(p);
   if(p==1)AC_SHARED_OHLC_P1_ATTEMPTED++; else if(p==2)AC_SHARED_OHLC_P2_ATTEMPTED++; else if(p==3)AC_SHARED_OHLC_P3_ATTEMPTED++; else if(p==4)AC_SHARED_OHLC_P4_ATTEMPTED++; else AC_SHARED_OHLC_P5_ATTEMPTED++;
}

void AC_SharedOhlcUpdateTotals()
{
   AC_SHARED_OHLC_SYMBOLS_TOTAL=SymbolsTotal(false);
   AC_SHARED_OHLC_SYMBOL_TF_TOTAL=AC_SHARED_OHLC_SYMBOLS_TOTAL*AC_SHARED_OHLC_TIMEFRAMES_ENABLED;
   AC_SHARED_OHLC_SYMBOL_TF_PENDING=AC_SHARED_OHLC_SYMBOL_TF_TOTAL-AC_SHARED_OHLC_SYMBOL_TF_ATTEMPTED; if(AC_SHARED_OHLC_SYMBOL_TF_PENDING<0)AC_SHARED_OHLC_SYMBOL_TF_PENDING=0;
   int p1=0,p2=0,p3=0,p4=0,p5=0;
   for(int i=0;i<AC_SHARED_OHLC_SYMBOLS_TOTAL;i++){ int p=AC_SharedOhlcPriorityForSymbol(SymbolName(i,false)); if(p==1)p1++; else if(p==2)p2++; else if(p==3)p3++; else if(p==4)p4++; else p5++; }
   AC_SHARED_OHLC_APPEND_BACKLOG_P1=p1*AC_SHARED_OHLC_TIMEFRAMES_ENABLED; AC_SHARED_OHLC_APPEND_BACKLOG_P2=p2*AC_SHARED_OHLC_TIMEFRAMES_ENABLED; AC_SHARED_OHLC_APPEND_BACKLOG_P3=p3*AC_SHARED_OHLC_TIMEFRAMES_ENABLED; AC_SHARED_OHLC_APPEND_BACKLOG_P4=p4*AC_SHARED_OHLC_TIMEFRAMES_ENABLED; AC_SHARED_OHLC_APPEND_BACKLOG_P5=p5*AC_SHARED_OHLC_TIMEFRAMES_ENABLED;
   AC_SHARED_OHLC_WINDOW_TOTAL=(p1+p2+p3+p4)*4;
}

bool AC_SharedOhlcWriteOneFile(const string s,const int tfi,const bool count_as_window)
{
   string tf=AC_SharedOhlcTfLabel(tfi); ENUM_TIMEFRAMES e=AC_SharedOhlcTfEnum(tfi);
   AC_SHARED_OHLC_LAST_SYMBOL=s; AC_SHARED_OHLC_LAST_TF=tf; AC_SharedOhlcEnsureSymbolFolder(s);
   MqlRates rates[]; ResetLastError(); int copied=CopyRates(s,e,1,AC_SHARED_OHLC_TARGET_SEED_BARS,rates);
   AC_SHARED_OHLC_SYMBOL_TF_ATTEMPTED++;
   if(count_as_window) AC_SHARED_OHLC_WINDOW_ATTEMPTED++;
   if(copied<=0){ AC_SHARED_OHLC_SYMBOL_TF_ERROR++; if(count_as_window)AC_SHARED_OHLC_WINDOW_ERROR++; AC_SHARED_OHLC_LAST_TASK_STATUS="copyrates_unavailable_"+IntegerToString(GetLastError()); return false; }
   string text=AC_SharedOhlcHeader(s,tf); for(int i=0;i<copied;i++) text+=AC_SharedOhlcRow(s,rates[i])+"\r\n";
   AC_WriteResult wr=AC_WriteTextFileFastAtomic(AC_SharedOhlcSeedPath(s,tf),text);
   if(!wr.ok){ AC_SHARED_OHLC_SYMBOL_TF_ERROR++; if(count_as_window)AC_SHARED_OHLC_WINDOW_ERROR++; AC_SHARED_OHLC_LAST_TASK_STATUS="single_file_write_failed_"+wr.status; return false; }
   if(copied>=AC_SHARED_OHLC_TARGET_SEED_BARS){ AC_SHARED_OHLC_SYMBOL_TF_SEEDED++; AC_SHARED_OHLC_LAST_TASK_STATUS="single_file_seed_complete"; }
   else { AC_SHARED_OHLC_SYMBOL_TF_PARTIAL++; AC_SHARED_OHLC_LAST_TASK_STATUS="single_file_seed_partial_"+IntegerToString(copied); }
   if(count_as_window)
   {
      if(tf=="M5" || tf=="M15" || tf=="H1" || tf=="H4")
      {
         AC_SHARED_OHLC_WINDOW_READY++;
         if(tf=="M5")AC_SHARED_OHLC_WINDOW_M5_READY++; else if(tf=="M15")AC_SHARED_OHLC_WINDOW_M15_READY++; else if(tf=="H1")AC_SHARED_OHLC_WINDOW_H1_READY++; else if(tf=="H4")AC_SHARED_OHLC_WINDOW_H4_READY++;
      }
   }
   return true;
}

void AC_SharedOhlcApplyStageProfile()
{
   if(AC_SHARED_OHLC_LAST_SERVICE_MS>500){ AC_SHARED_OHLC_TASKS_PER_SERVICE=1; AC_SHARED_OHLC_SERVICE_INTERVAL_MS=2000; AC_SHARED_OHLC_SERVICE_BUDGET_MS=80; AC_SHARED_OHLC_COOLDOWN_RUNS=10; AC_SHARED_OHLC_ADAPTIVE_MODE="slow_call_cooldown"; return; }
   if(AC_SHARED_OHLC_COOLDOWN_RUNS>0){ AC_SHARED_OHLC_COOLDOWN_RUNS--; AC_SHARED_OHLC_TASKS_PER_SERVICE=1; AC_SHARED_OHLC_SERVICE_INTERVAL_MS=1000; AC_SHARED_OHLC_SERVICE_BUDGET_MS=80; AC_SHARED_OHLC_ADAPTIVE_MODE="protective_cooldown"; return; }
   if(!AC_SHARED_OHLC_BOOT_SEED_COMPLETE){ AC_SHARED_OHLC_TASKS_PER_SERVICE=2; AC_SHARED_OHLC_SERVICE_INTERVAL_MS=500; AC_SHARED_OHLC_SERVICE_BUDGET_MS=160; AC_SHARED_OHLC_ADAPTIVE_MODE="full_seed_single_file_stage"; return; }
   if(AC_SHARED_OHLC_LAST_PRIORITY==1){ AC_SHARED_OHLC_TASKS_PER_SERVICE=4; AC_SHARED_OHLC_SERVICE_INTERVAL_MS=250; AC_SHARED_OHLC_SERVICE_BUDGET_MS=180; AC_SHARED_OHLC_ADAPTIVE_MODE="refresh_P1_fast"; return; }
   if(AC_SHARED_OHLC_LAST_PRIORITY==2){ AC_SHARED_OHLC_TASKS_PER_SERVICE=3; AC_SHARED_OHLC_SERVICE_INTERVAL_MS=500; AC_SHARED_OHLC_SERVICE_BUDGET_MS=160; AC_SHARED_OHLC_ADAPTIVE_MODE="refresh_P2_active"; return; }
   if(AC_SHARED_OHLC_LAST_PRIORITY==5){ AC_SHARED_OHLC_TASKS_PER_SERVICE=1; AC_SHARED_OHLC_SERVICE_INTERVAL_MS=5000; AC_SHARED_OHLC_SERVICE_BUDGET_MS=80; AC_SHARED_OHLC_ADAPTIVE_MODE="refresh_P5_slow_background"; return; }
   AC_SHARED_OHLC_TASKS_PER_SERVICE=1; AC_SHARED_OHLC_SERVICE_INTERVAL_MS=1000; AC_SHARED_OHLC_SERVICE_BUDGET_MS=100; AC_SHARED_OHLC_ADAPTIVE_MODE="refresh_standard";
}

void AC_SharedOhlcPublishStatus()
{
   string status="schema_name=shared_ohlc_raw_store_status\r\nschema_version=active_raw_store_v7_single_file\r\nowner=Runtime 1 Shared OHLC Raw Storage Owner\r\nstatus="+AC_SHARED_OHLC_STATUS+"\r\nmode="+AC_SHARED_OHLC_MODE+"\r\nscope=broker_universe_symbols_total_false\r\nlayout_policy=one_visible_source_file_per_symbol_timeframe\r\nremoved_visible_folders=Current|State|Priority Windows|Append|Fast Windows\r\nroute_root="+AC_SharedOhlcRootFolder()+"\r\nsymbols_total="+IntegerToString(AC_SHARED_OHLC_SYMBOLS_TOTAL)+"\r\ntimeframes_enabled="+IntegerToString(AC_SHARED_OHLC_TIMEFRAMES_ENABLED)+"\r\ntarget_seed_bars="+IntegerToString(AC_SHARED_OHLC_TARGET_SEED_BARS)+"\r\nsymbol_tf_total="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_TOTAL)+"\r\nsymbol_tf_attempted="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_ATTEMPTED)+"\r\nsymbol_tf_seeded="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_SEEDED)+"\r\nsymbol_tf_partial="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_PARTIAL)+"\r\nsymbol_tf_error="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_ERROR)+"\r\nsymbol_tf_pending="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_PENDING)+"\r\npriority_window_total="+IntegerToString(AC_SHARED_OHLC_WINDOW_TOTAL)+"\r\npriority_window_attempted="+IntegerToString(AC_SHARED_OHLC_WINDOW_ATTEMPTED)+"\r\npriority_window_ready="+IntegerToString(AC_SHARED_OHLC_WINDOW_READY)+"\r\npriority_window_partial="+IntegerToString(AC_SHARED_OHLC_WINDOW_PARTIAL)+"\r\npriority_window_error="+IntegerToString(AC_SHARED_OHLC_WINDOW_ERROR)+"\r\npriority_window_complete=true\r\nfull_seed_scheduler_active="+(AC_SHARED_OHLC_BOOT_SEED_COMPLETE?"false":"true")+"\r\ncopyrates_fetch_active=true\r\nlast_priority="+AC_SHARED_OHLC_LAST_PRIORITY_LABEL+"\r\nlast_symbol="+AC_SHARED_OHLC_LAST_SYMBOL+"\r\nlast_timeframe="+AC_SHARED_OHLC_LAST_TF+"\r\nlast_task_status="+AC_SHARED_OHLC_LAST_TASK_STATUS+"\r\nlast_service_ms="+IntegerToString((int)AC_SHARED_OHLC_LAST_SERVICE_MS)+"\r\nservice_tasks_used="+IntegerToString(AC_SHARED_OHLC_SERVICE_TASKS_USED)+"\r\nservice_tasks_per_run="+IntegerToString(AC_SHARED_OHLC_TASKS_PER_SERVICE)+"\r\nservice_interval_ms="+IntegerToString((int)AC_SHARED_OHLC_SERVICE_INTERVAL_MS)+"\r\nservice_budget_ms="+IntegerToString((int)AC_SHARED_OHLC_SERVICE_BUDGET_MS)+"\r\nadaptive_mode="+AC_SHARED_OHLC_ADAPTIVE_MODE+"\r\nraw_bars_written=true\r\ntrade_permission=false\r\nselection_runtime=false\r\ncalculation_runtime=false\r\n";
   AC_WriteResult sw=AC_WriteTextFileFastAtomic(AC_SharedOhlcStatusPath(),status); AC_SHARED_OHLC_STATUS_WRITE=sw.status;
   string mf="schema_name=shared_ohlc_raw_store_manifest\r\nschema_version=active_raw_store_v7_single_file\r\nowner=Runtime 1 Shared OHLC Raw Storage Owner\r\nroute_root="+AC_SharedOhlcRootFolder()+"\r\nstatus_path="+AC_SharedOhlcStatusPath()+"\r\nmanifest_path="+AC_SharedOhlcManifestPath()+"\r\nsymbols_folder="+AC_SharedOhlcSymbolsFolder()+"\r\nlayout_policy=one_visible_source_file_per_symbol_timeframe\r\nsource_file_example=Aurora Core\\<server>\\Shared Market Data\\OHLC Store\\Symbols\\<symbol>\\M5.seed.csv\r\ncopyrates_fetch_active=true\r\nfull_seed_scheduler_active="+(AC_SHARED_OHLC_BOOT_SEED_COMPLETE?"false":"true")+"\r\nroute_status="+AC_SHARED_OHLC_ROUTE_STATUS+"\r\nstatus_write="+AC_SHARED_OHLC_STATUS_WRITE+"\r\nservice_tasks_per_run="+IntegerToString(AC_SHARED_OHLC_TASKS_PER_SERVICE)+"\r\nservice_interval_ms="+IntegerToString((int)AC_SHARED_OHLC_SERVICE_INTERVAL_MS)+"\r\nadaptive_mode="+AC_SHARED_OHLC_ADAPTIVE_MODE+"\r\nlast_priority="+AC_SHARED_OHLC_LAST_PRIORITY_LABEL+"\r\n";
   AC_WriteResult mw=AC_WriteTextFileFastAtomic(AC_SharedOhlcManifestPath(),mf); AC_SHARED_OHLC_MANIFEST_WRITE=mw.status;
}

void AC_SharedOhlcService()
{
   uint now=GetTickCount(); if(now-AC_SHARED_OHLC_LAST_RUN_TICK<AC_SHARED_OHLC_SERVICE_INTERVAL_MS)return; AC_SHARED_OHLC_LAST_RUN_TICK=now;
   uint start=GetTickCount(); AC_SharedOhlcEnsureRouteOnly(); AC_SharedOhlcUpdateTotals(); int tasks=0; AC_SHARED_OHLC_SERVICE_TASKS_USED=0;
   int total_tasks=AC_SHARED_OHLC_SYMBOL_TF_TOTAL;
   while(tasks<AC_SHARED_OHLC_TASKS_PER_SERVICE && (GetTickCount()-start)<AC_SHARED_OHLC_SERVICE_BUDGET_MS && total_tasks>0)
   {
      int cursor=AC_SHARED_OHLC_BOOT_SEED_COMPLETE?AC_SHARED_OHLC_REFRESH_CURSOR:AC_SHARED_OHLC_SEED_CURSOR;
      int task=cursor%total_tasks; int si=task/AC_SHARED_OHLC_TIMEFRAMES_ENABLED; int ti=task%AC_SHARED_OHLC_TIMEFRAMES_ENABLED; string s=SymbolName(si,false); int p=AC_SharedOhlcPriorityForSymbol(s);
      AC_SharedOhlcMarkPriorityAttempt(p); AC_SharedOhlcWriteOneFile(s,ti,(ti>=1 && ti<=4 && p<=4));
      if(AC_SHARED_OHLC_BOOT_SEED_COMPLETE) AC_SHARED_OHLC_REFRESH_CURSOR++; else { AC_SHARED_OHLC_SEED_CURSOR++; if(AC_SHARED_OHLC_SEED_CURSOR>=total_tasks){ AC_SHARED_OHLC_BOOT_SEED_COMPLETE=true; AC_SHARED_OHLC_STATUS="seed_initial_pass_complete_refresh_active"; AC_SHARED_OHLC_MODE="single_file_refresh_active"; }}
      tasks++; AC_SHARED_OHLC_SERVICE_TASKS_USED=tasks;
   }
   AC_SHARED_OHLC_LAST_SERVICE_MS=GetTickCount()-start; AC_SharedOhlcUpdateTotals(); AC_SharedOhlcApplyStageProfile(); AC_SharedOhlcPublishStatus();
}

string AC_SharedOhlcRenderBoardSection()
{
   AC_SharedOhlcService();
   string text="\r\nSHARED OHLC RAW STORE\r\n----------------------------------------\r\n";
   text+="Status:                 "+AC_SHARED_OHLC_STATUS+"\r\nMode:                   "+AC_SHARED_OHLC_MODE+"\r\nLayout:                 one visible source file per symbol/timeframe\r\nRemoved Folders:        Current, State, Priority Windows, Append, Fast Windows\r\nRoute Root:             "+AC_SharedOhlcRootFolder()+"\r\nRoute Status:           "+AC_SHARED_OHLC_ROUTE_STATUS+"\r\nStatus File Write:      "+AC_SHARED_OHLC_STATUS_WRITE+"\r\nManifest File Write:    "+AC_SHARED_OHLC_MANIFEST_WRITE+"\r\nSymbols Tracked:        "+IntegerToString(AC_SHARED_OHLC_SYMBOLS_TOTAL)+"\r\nAttempted Symbol-TFs:   "+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_ATTEMPTED)+" / "+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_TOTAL)+"\r\nSeeded/Partial/Error:   "+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_SEEDED)+" / "+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_PARTIAL)+" / "+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_ERROR)+"\r\nPending Symbol-TFs:     "+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_PENDING)+"\r\nLast Task:              "+AC_SHARED_OHLC_LAST_SYMBOL+" "+AC_SHARED_OHLC_LAST_TF+" "+AC_SHARED_OHLC_LAST_TASK_STATUS+"\r\nService Duration:       "+IntegerToString((int)AC_SHARED_OHLC_LAST_SERVICE_MS)+" ms\r\nService Throttle:       mode="+AC_SHARED_OHLC_ADAPTIVE_MODE+" tasks="+IntegerToString(AC_SHARED_OHLC_TASKS_PER_SERVICE)+" interval_ms="+IntegerToString((int)AC_SHARED_OHLC_SERVICE_INTERVAL_MS)+" budget_ms="+IntegerToString((int)AC_SHARED_OHLC_SERVICE_BUDGET_MS)+"\r\nRaw Bars Printed:       FALSE\r\nTrade Permission:       FALSE\r\n";
   return text;
}

string AC_SharedOhlcRenderDossierSection(const string symbol)
{
   AC_SharedOhlcEnsureRouteOnly();
   string m5=FileIsExist(AC_SharedOhlcSeedPath(symbol,"M5"),AC_CommonFlag())?"available":"pending";
   string m15=FileIsExist(AC_SharedOhlcSeedPath(symbol,"M15"),AC_CommonFlag())?"available":"pending";
   string h1=FileIsExist(AC_SharedOhlcSeedPath(symbol,"H1"),AC_CommonFlag())?"available":"pending";
   string h4=FileIsExist(AC_SharedOhlcSeedPath(symbol,"H4"),AC_CommonFlag())?"available":"pending";
   int priority=AC_SharedOhlcPriorityForSymbol(symbol);
   string text="\r\nSHARED OHLC RAW STORE OVERVIEW\r\n----------------------------------------\r\n";
   text+="Owner:                  Runtime 1 Shared OHLC Raw Storage Owner\r\nSymbol:                 "+symbol+"\r\nSymbol Priority:        "+AC_SharedOhlcPriorityLabel(priority)+"\r\nStore Status:           "+AC_SHARED_OHLC_STATUS+"\r\nStore Mode:             "+AC_SHARED_OHLC_MODE+"\r\nRaw Store Route:        "+AC_SharedOhlcRootFolder()+"\r\nSymbol Store Route:     "+AC_SharedOhlcSymbolFolder(symbol)+"\r\nSource M5/M15/H1/H4:    "+m5+" / "+m15+" / "+h1+" / "+h4+"\r\nRaw Bars Shown Here:    FALSE\r\nCalculation Policy:     no_calculations_in_mt5_raw_storage_owner\r\n";
   return text;
}

string AC_SharedOhlcRenderWorkbenchSection()
{
   AC_SharedOhlcService();
   string text="SHARED_OHLC_RAW_STORAGE_OWNER\r\n----------------------------------------\r\n";
   text+="shared_ohlc_status="+AC_SHARED_OHLC_STATUS+"\r\nshared_ohlc_mode="+AC_SHARED_OHLC_MODE+"\r\nshared_ohlc_layout_policy=one_visible_source_file_per_symbol_timeframe\r\nshared_ohlc_removed_visible_folders=Current|State|Priority Windows|Append|Fast Windows\r\nshared_ohlc_route_root="+AC_SharedOhlcRootFolder()+"\r\nshared_ohlc_status_path="+AC_SharedOhlcStatusPath()+"\r\nshared_ohlc_manifest_path="+AC_SharedOhlcManifestPath()+"\r\nshared_ohlc_route_status="+AC_SHARED_OHLC_ROUTE_STATUS+"\r\nshared_ohlc_status_write="+AC_SHARED_OHLC_STATUS_WRITE+"\r\nshared_ohlc_manifest_write="+AC_SHARED_OHLC_MANIFEST_WRITE+"\r\nshared_ohlc_scope=broker_universe_symbols_total_false\r\nshared_ohlc_copyrates_fetch_active=true\r\nshared_ohlc_full_seed_scheduler_active="+(AC_SHARED_OHLC_BOOT_SEED_COMPLETE?"false":"true")+"\r\nshared_ohlc_symbol_tf_total="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_TOTAL)+"\r\nshared_ohlc_symbol_tf_attempted="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_ATTEMPTED)+"\r\nshared_ohlc_symbol_tf_seeded="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_SEEDED)+"\r\nshared_ohlc_symbol_tf_partial="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_PARTIAL)+"\r\nshared_ohlc_symbol_tf_error="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_ERROR)+"\r\nshared_ohlc_last_service_ms="+IntegerToString((int)AC_SHARED_OHLC_LAST_SERVICE_MS)+"\r\nshared_ohlc_service_tasks_used="+IntegerToString(AC_SHARED_OHLC_SERVICE_TASKS_USED)+"\r\nshared_ohlc_service_tasks_per_run="+IntegerToString(AC_SHARED_OHLC_TASKS_PER_SERVICE)+"\r\nshared_ohlc_service_interval_ms="+IntegerToString((int)AC_SHARED_OHLC_SERVICE_INTERVAL_MS)+"\r\nshared_ohlc_service_budget_ms="+IntegerToString((int)AC_SHARED_OHLC_SERVICE_BUDGET_MS)+"\r\nshared_ohlc_adaptive_mode="+AC_SHARED_OHLC_ADAPTIVE_MODE+"\r\nshared_ohlc_last_task="+AC_SHARED_OHLC_LAST_SYMBOL+"|"+AC_SHARED_OHLC_LAST_TF+"|"+AC_SHARED_OHLC_LAST_TASK_STATUS+"\r\nshared_ohlc_raw_bars_printed_to_board=false\r\nshared_ohlc_raw_bars_printed_to_dossier=false\r\n";
   return text;
}

#endif
