#ifndef AC_SHARED_OHLC_OWNER_MQH
#define AC_SHARED_OHLC_OWNER_MQH

// Runtime 1 support service - Shared OHLC Raw Storage Owner.
// Source owner for raw MT5 OHLC storage only.
// No calculations, no scoring, no ranking, no selection, no permission, no execution.

#include "AC_SharedOhlcContracts.mqh"
#include "AC_SharedOhlcState.mqh"
#include "AC_SharedOhlcCodec.mqh"

bool AC_SharedOhlcSymbolHasOpenPosition(const string symbol)
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      string position_symbol = PositionGetSymbol(i);
      if(position_symbol == symbol)
         return true;
   }
   return false;
}

bool AC_SharedOhlcSymbolHasPendingOrder(const string symbol)
{
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      ulong ticket = OrderGetTicket(i);
      if(ticket == 0)
         continue;
      string order_symbol = OrderGetString(ORDER_SYMBOL);
      if(order_symbol == symbol)
         return true;
   }
   return false;
}

bool AC_SharedOhlcSymbolL5Pass(const string symbol)
{
   for(int i = 0; i < ArraySize(AC_L5_SYMBOLS); i++)
   {
      if(AC_L5_SYMBOLS[i].symbol == symbol)
         return AC_L5_SYMBOLS[i].pass;
   }
   return false;
}

int AC_SharedOhlcPriorityForSymbol(const string symbol)
{
   if(AC_SharedOhlcSymbolHasOpenPosition(symbol) || AC_SharedOhlcSymbolHasPendingOrder(symbol))
      return AC_SHARED_OHLC_PRIORITY_OPEN_OR_PENDING;

   if(AC_SharedOhlcSymbolL5Pass(symbol))
      return AC_SHARED_OHLC_PRIORITY_L5_PASS;

   // Priority 3 is reserved for future candidate/ranked/selected symbols once those owners exist.
   // This owner must not infer candidate/ranking state itself.

   bool selected = (bool)SymbolInfoInteger(symbol, SYMBOL_SELECT);
   if(selected)
      return AC_SHARED_OHLC_PRIORITY_OTHER_OPEN;

   return AC_SHARED_OHLC_PRIORITY_CLOSED_BLOCKED_UNKNOWN;
}

void AC_SharedOhlcAddPriorityBacklog(const int priority)
{
   if(priority == AC_SHARED_OHLC_PRIORITY_OPEN_OR_PENDING) AC_SHARED_OHLC_APPEND_BACKLOG_P1++;
   else if(priority == AC_SHARED_OHLC_PRIORITY_L5_PASS) AC_SHARED_OHLC_APPEND_BACKLOG_P2++;
   else if(priority == AC_SHARED_OHLC_PRIORITY_FUTURE_CANDIDATE) AC_SHARED_OHLC_APPEND_BACKLOG_P3++;
   else if(priority == AC_SHARED_OHLC_PRIORITY_OTHER_OPEN) AC_SHARED_OHLC_APPEND_BACKLOG_P4++;
   else AC_SHARED_OHLC_APPEND_BACKLOG_P5++;
}

bool AC_SharedOhlcInit()
{
   uint start_ms = GetTickCount();
   AC_SharedOhlcResetCounters();
   string folder_detail = "";
   bool folders_ok = AC_EnsureSharedOhlcBaseFolders(folder_detail);

   AC_SHARED_OHLC_READY = folders_ok;
   AC_SHARED_OHLC_STATUS = folders_ok ? "ready_storage_contract_loaded_seed_not_started" : "route_folder_degraded";
   AC_SHARED_OHLC_MODE = "boot_seed_pending";
   AC_SHARED_OHLC_LAST_ERROR = folders_ok ? "" : folder_detail;
   AC_SHARED_OHLC_LAST_SERVICE_DURATION_MS = GetTickCount() - start_ms;

   AC_WriteTextFileFastAtomic(AC_SharedOhlcStatusPath(), AC_SharedOhlcStatusRow());
   return folders_ok;
}

int AC_SharedOhlcCopyClosedBars(const string symbol,
                                const AC_SharedOhlcTimeframeContract &frame,
                                MqlRates &rates[])
{
   ArrayResize(rates, 0);
   if(symbol == "" || !frame.enabled)
      return 0;

   ResetLastError();
   int copied = CopyRates(symbol, frame.timeframe, 1, frame.target_bars, rates);
   return copied;
}

bool AC_SharedOhlcSeedSymbolTimeframe(const string symbol,
                                      const AC_SharedOhlcTimeframeContract &frame,
                                      AC_SharedOhlcSymbolTfStatus &status)
{
   status.symbol = symbol;
   status.timeframe_label = frame.label;
   status.priority = AC_SharedOhlcPriorityForSymbol(symbol);
   status.requested_bars = frame.target_bars;
   status.copied_bars = 0;
   status.oldest_bar_time = 0;
   status.newest_closed_bar_time = 0;
   status.current_bar_time = 0;
   status.seed_attempted = true;
   status.seed_complete = false;
   status.append_attempted = false;
   status.append_complete = false;
   status.storage_status = "seed_attempted";
   status.last_error_text = "";

   string folder_detail = "";
   if(!AC_EnsureSharedOhlcSymbolFolders(symbol, folder_detail))
   {
      status.storage_status = "symbol_folder_failed";
      status.last_error_text = folder_detail;
      return false;
   }

   MqlRates closed_rates[];
   int copied = AC_SharedOhlcCopyClosedBars(symbol, frame, closed_rates);
   status.copied_bars = copied;

   if(copied <= 0)
   {
      status.storage_status = "copyrates_pending_or_unavailable";
      status.last_error_text = "copyrates_error=" + IntegerToString(GetLastError());
      return false;
   }

   // CopyRates stores the oldest copied element at physical index 0.
   // start_pos=1 excludes the current forming bar, so copied-1 is newest closed.
   status.oldest_bar_time = closed_rates[0].time;
   status.newest_closed_bar_time = closed_rates[copied - 1].time;
   string closed_csv = AC_SharedOhlcRatesToClosedCsv(symbol, frame.label, closed_rates, copied);
   AC_WriteResult closed_write = AC_WriteTextFileFastAtomic(AC_SharedOhlcClosedBarsPath(symbol, frame.label), closed_csv);
   if(!closed_write.ok)
   {
      status.storage_status = "closed_file_write_failed";
      status.last_error_text = closed_write.status + ";error=" + IntegerToString(closed_write.error_code);
      return false;
   }

   MqlRates current_rate[];
   ResetLastError();
   int current_copied = CopyRates(symbol, frame.timeframe, 0, AC_SHARED_OHLC_CURRENT_BAR_COPY_COUNT, current_rate);
   if(current_copied > 0)
   {
      status.current_bar_time = current_rate[0].time;
      string current_csv = AC_SharedOhlcCurrentCsv(symbol, frame.label, current_rate[0]);
      AC_WriteTextFileFastAtomic(AC_SharedOhlcCurrentBarPath(symbol, frame.label), current_csv);
   }

   status.seed_complete = (copied >= frame.target_bars);
   status.storage_status = status.seed_complete ? "seed_complete" : "seed_partial";
   return true;
}

string AC_SharedOhlcSymbolTfStatusLine(const AC_SharedOhlcSymbolTfStatus &status)
{
   string line = status.symbol;
   line += "," + status.timeframe_label;
   line += "," + IntegerToString(status.priority);
   line += "," + IntegerToString(status.requested_bars);
   line += "," + IntegerToString(status.copied_bars);
   line += "," + IntegerToString((long)status.oldest_bar_time);
   line += "," + IntegerToString((long)status.newest_closed_bar_time);
   line += "," + IntegerToString((long)status.current_bar_time);
   line += "," + status.storage_status;
   line += "," + (status.seed_complete ? "true" : "false");
   return line;
}

string AC_SharedOhlcIndexHeader()
{
   return "symbol,timeframe,priority,requested_bars,copied_bars,oldest_bar_time,newest_closed_bar_time,current_bar_time,storage_status,seed_complete\r\n";
}

string AC_SharedOhlcBoardSection()
{
   string text = "\r\nSHARED OHLC RAW STORE\r\n";
   text += "----------------------------------------\r\n";
   text += "Status:                 " + AC_SHARED_OHLC_STATUS + "\r\n";
   text += "Mode:                   " + AC_SHARED_OHLC_MODE + "\r\n";
   text += "Server Scope:           " + AC_ServerNameForRoute() + "\r\n";
   text += "Symbols Tracked:        " + IntegerToString(AC_SHARED_OHLC_SYMBOLS_TOTAL) + "\r\n";
   text += "Timeframes Enabled:     " + IntegerToString(AC_SHARED_OHLC_TIMEFRAMES_ENABLED) + "\r\n";
   text += "Target Bars / TF:       " + IntegerToString(AC_SHARED_OHLC_TARGET_SEED_BARS) + "\r\n";
   text += "Seeded Symbol-TFs:      " + IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_SEEDED) + " / " + IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_TOTAL) + "\r\n";
   text += "Partial Symbol-TFs:     " + IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_PARTIAL) + "\r\n";
   text += "Pending Symbol-TFs:     " + IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_PENDING) + "\r\n";
   text += "Append Backlog:         P1=" + IntegerToString(AC_SHARED_OHLC_APPEND_BACKLOG_P1)
      + " P2=" + IntegerToString(AC_SHARED_OHLC_APPEND_BACKLOG_P2)
      + " P3=" + IntegerToString(AC_SHARED_OHLC_APPEND_BACKLOG_P3)
      + " P4=" + IntegerToString(AC_SHARED_OHLC_APPEND_BACKLOG_P4)
      + " P5=" + IntegerToString(AC_SHARED_OHLC_APPEND_BACKLOG_P5) + "\r\n";
   text += "Raw Bars Printed:       FALSE\r\n";
   text += "Trade Permission:       FALSE\r\n";
   return text;
}

string AC_SharedOhlcDossierSection(const string symbol)
{
   string text = "\r\nSHARED OHLC RAW STORE OVERVIEW\r\n";
   text += "----------------------------------------\r\n";
   text += "Owner:                  " + AC_SHARED_OHLC_OWNER_NAME + "\r\n";
   text += "Symbol:                 " + symbol + "\r\n";
   text += "Server Scope:           " + AC_ServerNameForRoute() + "\r\n";
   text += "Store Status:           " + AC_SHARED_OHLC_STATUS + "\r\n";
   text += "Store Mode:             " + AC_SHARED_OHLC_MODE + "\r\n";
   text += "Target Bars / TF:       " + IntegerToString(AC_SHARED_OHLC_TARGET_SEED_BARS) + "\r\n";
   text += "Timeframes Enabled:     " + IntegerToString(AC_SHARED_OHLC_TIMEFRAMES_ENABLED) + "\r\n";
   text += "Raw Bars Shown Here:    FALSE\r\n";
   text += "Raw Store Route:        " + AC_SharedOhlcSymbolFolder(symbol) + "\r\n";
   text += "Layer Access Policy:    " + AC_SHARED_OHLC_LAYER_ACCESS_POLICY + "\r\n";
   text += "Calculation Policy:     " + AC_SHARED_OHLC_CALCULATION_POLICY + "\r\n";
   return text;
}

string AC_SharedOhlcWorkbenchSection()
{
   string text = "SHARED_OHLC_RAW_STORAGE_OWNER\r\n";
   text += "----------------------------------------\r\n";
   text += AC_SharedOhlcStatusRow();
   text += "shared_ohlc_route_root=" + AC_SharedOhlcRootFolder() + "\r\n";
   text += "shared_ohlc_status_path=" + AC_SharedOhlcStatusPath() + "\r\n";
   text += "shared_ohlc_manifest_path=" + AC_SharedOhlcManifestPath() + "\r\n";
   text += "shared_ohlc_raw_bars_printed_to_board=false\r\n";
   text += "shared_ohlc_raw_bars_printed_to_dossier=false\r\n";
   text += "shared_ohlc_copyrates_owner=shared_ohlc_raw_storage_owner_only\r\n";
   text += "shared_ohlc_future_layers_private_copyrates_allowed=false\r\n";
   return text;
}

#endif
