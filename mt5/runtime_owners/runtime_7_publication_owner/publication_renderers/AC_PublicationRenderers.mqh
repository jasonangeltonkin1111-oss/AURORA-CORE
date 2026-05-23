#ifndef AC_PUBLICATION_RENDERERS_MQH
#define AC_PUBLICATION_RENDERERS_MQH

// Shared OHLC Raw Storage active bootstrap.
// Compile-safe single-file bridge until the Runtime 1 owner include tree is locally installed.
// Source authority: Runtime 1 Shared OHLC Raw Storage Owner. This code stores raw MT5 bars only.
// No calculations, ranking, selection, trade permission, or execution.

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
static int    AC_SHARED_OHLC_SEED_SYMBOL_INDEX = 0;
static int    AC_SHARED_OHLC_SEED_TF_INDEX = 0;
static int    AC_SHARED_OHLC_APPEND_SYMBOL_INDEX = 0;
static int    AC_SHARED_OHLC_APPEND_TF_INDEX = 0;
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
static uint   AC_SHARED_OHLC_LAST_SERVICE_MS = 0;
static int    AC_SHARED_OHLC_TASKS_PER_SERVICE = 8;
static uint   AC_SHARED_OHLC_SERVICE_BUDGET_MS = 120;
static uint   AC_SHARED_OHLC_LAST_RUN_TICK = 0;

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
string AC_SharedOhlcSeedPath(const string s,const string tf){ return AC_SharedOhlcSymbolFolder(s)+"\\"+tf+".seed.csv"; }
string AC_SharedOhlcAppendPath(const string s,const string tf){ return AC_SharedOhlcSymbolFolder(s)+"\\"+tf+".append.csv"; }
string AC_SharedOhlcCurrentPath(const string s,const string tf){ return AC_SharedOhlcCurrentFolder(s)+"\\"+tf+".current.csv"; }
string AC_SharedOhlcLastTimePath(const string s,const string tf){ return AC_SharedOhlcStateFolder(s)+"\\"+tf+".last_time.txt"; }

string AC_SharedOhlcTfLabel(const int i){ if(i==0)return "M1"; if(i==1)return "M5"; if(i==2)return "M15"; if(i==3)return "H1"; if(i==4)return "H4"; return "D1"; }
ENUM_TIMEFRAMES AC_SharedOhlcTfEnum(const int i){ if(i==0)return PERIOD_M1; if(i==1)return PERIOD_M5; if(i==2)return PERIOD_M15; if(i==3)return PERIOD_H1; if(i==4)return PERIOD_H4; return PERIOD_D1; }

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

void AC_SharedOhlcUpdateTotals()
{
   AC_SHARED_OHLC_SYMBOLS_TOTAL=SymbolsTotal(false);
   AC_SHARED_OHLC_SYMBOL_TF_TOTAL=AC_SHARED_OHLC_SYMBOLS_TOTAL*AC_SHARED_OHLC_TIMEFRAMES_ENABLED;
   AC_SHARED_OHLC_SYMBOL_TF_PENDING=AC_SHARED_OHLC_SYMBOL_TF_TOTAL-AC_SHARED_OHLC_SYMBOL_TF_ATTEMPTED;
   if(AC_SHARED_OHLC_SYMBOL_TF_PENDING<0)AC_SHARED_OHLC_SYMBOL_TF_PENDING=0;
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

bool AC_SharedOhlcAppendOne(const string s,const int tfi)
{
   string tf=AC_SharedOhlcTfLabel(tfi); ENUM_TIMEFRAMES e=AC_SharedOhlcTfEnum(tfi);
   AC_SHARED_OHLC_LAST_SYMBOL=s; AC_SHARED_OHLC_LAST_TF=tf; AC_SharedOhlcEnsureSymbolFolders(s);
   MqlRates r[]; if(CopyRates(s,e,1,1,r)<=0){AC_SHARED_OHLC_APPEND_ERROR++; AC_SHARED_OHLC_LAST_TASK_STATUS="append_copyrates_unavailable"; return false;}
   long last=AC_SharedOhlcReadLastTime(AC_SharedOhlcLastTimePath(s,tf));
   if((long)r[0].time<=last){AC_SHARED_OHLC_APPEND_SKIPPED_DUPLICATE++; AC_SHARED_OHLC_LAST_TASK_STATUS="append_no_new_closed_bar"; return true;}
   if(!AC_SharedOhlcAppendLine(AC_SharedOhlcAppendPath(s,tf),AC_SharedOhlcRow(s,r[0]),AC_SharedOhlcHeader(s,tf))){AC_SHARED_OHLC_APPEND_ERROR++; AC_SHARED_OHLC_LAST_TASK_STATUS="append_write_failed"; return false;}
   AC_SharedOhlcWriteLastTime(AC_SharedOhlcLastTimePath(s,tf),r[0].time); AC_SHARED_OHLC_APPEND_WRITTEN++; AC_SHARED_OHLC_LAST_TASK_STATUS="append_written"; return true;
}

void AC_SharedOhlcAdvanceCursor(int &si,int &ti)
{
   ti++; if(ti>=AC_SHARED_OHLC_TIMEFRAMES_ENABLED){ti=0; si++; if(si>=AC_SHARED_OHLC_SYMBOLS_TOTAL)si=0;}
}

void AC_SharedOhlcService()
{
   uint now=GetTickCount(); if(now-AC_SHARED_OHLC_LAST_RUN_TICK<200)return; AC_SHARED_OHLC_LAST_RUN_TICK=now;
   uint start=GetTickCount(); AC_SharedOhlcEnsureRouteOnly(); AC_SharedOhlcUpdateTotals(); int tasks=0;
   while(tasks<AC_SHARED_OHLC_TASKS_PER_SERVICE && (GetTickCount()-start)<AC_SHARED_OHLC_SERVICE_BUDGET_MS && AC_SHARED_OHLC_SYMBOLS_TOTAL>0)
   {
      if(!AC_SHARED_OHLC_BOOT_SEED_COMPLETE)
      {
         string s=SymbolName(AC_SHARED_OHLC_SEED_SYMBOL_INDEX,false); if(s!="") AC_SharedOhlcSeedOne(s,AC_SHARED_OHLC_SEED_TF_INDEX);
         AC_SHARED_OHLC_SEED_TF_INDEX++; if(AC_SHARED_OHLC_SEED_TF_INDEX>=AC_SHARED_OHLC_TIMEFRAMES_ENABLED){AC_SHARED_OHLC_SEED_TF_INDEX=0; AC_SHARED_OHLC_SEED_SYMBOL_INDEX++;}
         if(AC_SHARED_OHLC_SEED_SYMBOL_INDEX>=AC_SHARED_OHLC_SYMBOLS_TOTAL){AC_SHARED_OHLC_BOOT_SEED_COMPLETE=true; AC_SHARED_OHLC_MODE="append_only_priority_refresh"; AC_SHARED_OHLC_STATUS=(AC_SHARED_OHLC_SYMBOL_TF_ERROR>0||AC_SHARED_OHLC_SYMBOL_TF_PARTIAL>0)?"seed_done_with_partial_or_errors_append_active":"seed_complete_append_active"; AC_SHARED_OHLC_SEED_SYMBOL_INDEX=0;}
      }
      else
      {
         string s2=SymbolName(AC_SHARED_OHLC_APPEND_SYMBOL_INDEX,false); if(s2!="") AC_SharedOhlcAppendOne(s2,AC_SHARED_OHLC_APPEND_TF_INDEX);
         AC_SharedOhlcAdvanceCursor(AC_SHARED_OHLC_APPEND_SYMBOL_INDEX,AC_SHARED_OHLC_APPEND_TF_INDEX);
      }
      tasks++;
   }
   AC_SHARED_OHLC_LAST_SERVICE_MS=GetTickCount()-start; AC_SharedOhlcUpdateTotals();

   string status="schema_name=shared_ohlc_raw_store_status\r\nschema_version=active_raw_store_v1\r\nowner=Runtime 1 Shared OHLC Raw Storage Owner\r\nstatus="+AC_SHARED_OHLC_STATUS+"\r\nmode="+AC_SHARED_OHLC_MODE+"\r\nscope=broker_universe_symbols_total_false\r\nroute_root="+AC_SharedOhlcRootFolder()+"\r\nsymbols_total="+IntegerToString(AC_SHARED_OHLC_SYMBOLS_TOTAL)+"\r\ntimeframes_enabled="+IntegerToString(AC_SHARED_OHLC_TIMEFRAMES_ENABLED)+"\r\ntarget_seed_bars="+IntegerToString(AC_SHARED_OHLC_TARGET_SEED_BARS)+"\r\nsymbol_tf_total="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_TOTAL)+"\r\nsymbol_tf_attempted="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_ATTEMPTED)+"\r\nsymbol_tf_seeded="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_SEEDED)+"\r\nsymbol_tf_partial="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_PARTIAL)+"\r\nsymbol_tf_error="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_ERROR)+"\r\nsymbol_tf_pending="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_PENDING)+"\r\nfull_seed_scheduler_active="+(AC_SHARED_OHLC_BOOT_SEED_COMPLETE?"false":"true")+"\r\ncopyrates_fetch_active=true\r\nlast_symbol="+AC_SHARED_OHLC_LAST_SYMBOL+"\r\nlast_timeframe="+AC_SHARED_OHLC_LAST_TF+"\r\nlast_task_status="+AC_SHARED_OHLC_LAST_TASK_STATUS+"\r\nlast_service_ms="+IntegerToString((int)AC_SHARED_OHLC_LAST_SERVICE_MS)+"\r\nraw_bars_written=true\r\ntrade_permission=false\r\nselection_runtime=false\r\ncalculation_runtime=false\r\n";
   AC_WriteResult sw=AC_WriteTextFileFastAtomic(AC_SharedOhlcStatusPath(),status); AC_SHARED_OHLC_STATUS_WRITE=sw.status;
   string mf="schema_name=shared_ohlc_raw_store_manifest\r\nschema_version=active_raw_store_v1\r\nowner=Runtime 1 Shared OHLC Raw Storage Owner\r\nroute_root="+AC_SharedOhlcRootFolder()+"\r\nstatus_path="+AC_SharedOhlcStatusPath()+"\r\nmanifest_path="+AC_SharedOhlcManifestPath()+"\r\nsymbols_folder="+AC_SharedOhlcSymbolsFolder()+"\r\nscope=broker_universe_symbols_total_false\r\ncopyrates_fetch_active=true\r\nfull_seed_scheduler_active="+(AC_SHARED_OHLC_BOOT_SEED_COMPLETE?"false":"true")+"\r\nappend_mode_active="+(AC_SHARED_OHLC_BOOT_SEED_COMPLETE?"true":"false")+"\r\nraw_bars_printed_to_board=false\r\nraw_bars_printed_to_dossier=false\r\nroute_status="+AC_SHARED_OHLC_ROUTE_STATUS+"\r\nstatus_write="+AC_SHARED_OHLC_STATUS_WRITE+"\r\n";
   AC_WriteResult mw=AC_WriteTextFileFastAtomic(AC_SharedOhlcManifestPath(),mf); AC_SHARED_OHLC_MANIFEST_WRITE=mw.status;
}

string AC_SharedOhlcRenderBoardSection()
{
   AC_SharedOhlcService();
   string text="\r\nSHARED OHLC RAW STORE\r\n----------------------------------------\r\n";
   text+="Status:                 "+AC_SHARED_OHLC_STATUS+"\r\nMode:                   "+AC_SHARED_OHLC_MODE+"\r\nRoute Root:             "+AC_SharedOhlcRootFolder()+"\r\nRoute Status:           "+AC_SHARED_OHLC_ROUTE_STATUS+"\r\nStatus File Write:      "+AC_SHARED_OHLC_STATUS_WRITE+"\r\nManifest File Write:    "+AC_SHARED_OHLC_MANIFEST_WRITE+"\r\nSymbols Tracked:        "+IntegerToString(AC_SHARED_OHLC_SYMBOLS_TOTAL)+"\r\nTimeframes Enabled:     "+IntegerToString(AC_SHARED_OHLC_TIMEFRAMES_ENABLED)+"\r\nTarget Bars / TF:       "+IntegerToString(AC_SHARED_OHLC_TARGET_SEED_BARS)+"\r\nAttempted Symbol-TFs:   "+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_ATTEMPTED)+" / "+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_TOTAL)+"\r\nSeeded Symbol-TFs:      "+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_SEEDED)+"\r\nPartial Symbol-TFs:     "+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_PARTIAL)+"\r\nError Symbol-TFs:       "+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_ERROR)+"\r\nPending Symbol-TFs:     "+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_PENDING)+"\r\nLast Task:              "+AC_SHARED_OHLC_LAST_SYMBOL+" "+AC_SHARED_OHLC_LAST_TF+" "+AC_SHARED_OHLC_LAST_TASK_STATUS+"\r\nService Duration:       "+IntegerToString((int)AC_SHARED_OHLC_LAST_SERVICE_MS)+" ms\r\nRaw Bars Printed:       FALSE\r\nTrade Permission:       FALSE\r\n";
   return text;
}

string AC_SharedOhlcRenderDossierSection(const string symbol)
{
   AC_SharedOhlcEnsureRouteOnly();
   string text="\r\nSHARED OHLC RAW STORE OVERVIEW\r\n----------------------------------------\r\n";
   text+="Owner:                  Runtime 1 Shared OHLC Raw Storage Owner\r\nSymbol:                 "+symbol+"\r\nStore Status:           "+AC_SHARED_OHLC_STATUS+"\r\nStore Mode:             "+AC_SHARED_OHLC_MODE+"\r\nRaw Store Route:        "+AC_SharedOhlcRootFolder()+"\r\nSymbol Store Route:     "+AC_SharedOhlcSymbolFolder(symbol)+"\r\nRaw Bars Shown Here:    FALSE\r\nCalculation Policy:     no_calculations_in_mt5_raw_storage_owner\r\n";
   return text;
}

string AC_SharedOhlcRenderWorkbenchSection()
{
   AC_SharedOhlcService();
   string text="SHARED_OHLC_RAW_STORAGE_OWNER\r\n----------------------------------------\r\n";
   text+="shared_ohlc_status="+AC_SHARED_OHLC_STATUS+"\r\nshared_ohlc_mode="+AC_SHARED_OHLC_MODE+"\r\nshared_ohlc_route_root="+AC_SharedOhlcRootFolder()+"\r\nshared_ohlc_status_path="+AC_SharedOhlcStatusPath()+"\r\nshared_ohlc_manifest_path="+AC_SharedOhlcManifestPath()+"\r\nshared_ohlc_route_status="+AC_SHARED_OHLC_ROUTE_STATUS+"\r\nshared_ohlc_status_write="+AC_SHARED_OHLC_STATUS_WRITE+"\r\nshared_ohlc_manifest_write="+AC_SHARED_OHLC_MANIFEST_WRITE+"\r\nshared_ohlc_scope=broker_universe_symbols_total_false\r\nshared_ohlc_copyrates_fetch_active=true\r\nshared_ohlc_full_seed_scheduler_active="+(AC_SHARED_OHLC_BOOT_SEED_COMPLETE?"false":"true")+"\r\nshared_ohlc_append_mode_active="+(AC_SHARED_OHLC_BOOT_SEED_COMPLETE?"true":"false")+"\r\nshared_ohlc_symbol_tf_total="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_TOTAL)+"\r\nshared_ohlc_symbol_tf_attempted="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_ATTEMPTED)+"\r\nshared_ohlc_symbol_tf_seeded="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_SEEDED)+"\r\nshared_ohlc_symbol_tf_partial="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_PARTIAL)+"\r\nshared_ohlc_symbol_tf_error="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_ERROR)+"\r\nshared_ohlc_symbol_tf_pending="+IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_PENDING)+"\r\nshared_ohlc_append_written="+IntegerToString(AC_SHARED_OHLC_APPEND_WRITTEN)+"\r\nshared_ohlc_last_service_ms="+IntegerToString((int)AC_SHARED_OHLC_LAST_SERVICE_MS)+"\r\nshared_ohlc_last_task="+AC_SHARED_OHLC_LAST_SYMBOL+"|"+AC_SHARED_OHLC_LAST_TF+"|"+AC_SHARED_OHLC_LAST_TASK_STATUS+"\r\nshared_ohlc_raw_bars_printed_to_board=false\r\nshared_ohlc_raw_bars_printed_to_dossier=false\r\n";
   return text;
}

#include "AC_Layer7SessionRelevanceRenderer.mqh"
#include "AC_Layer6RankedSidecarRenderer.mqh"
#include "AC_Layer0DossierPublication.mqh"
#include "AC_MarketBoardRenderer.mqh"

#endif