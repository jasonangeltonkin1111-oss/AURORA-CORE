#ifndef AC_LAYER0_DOSSIER_PUBLICATION_BOUNDED_HOT_LANE_MQH
#define AC_LAYER0_DOSSIER_PUBLICATION_BOUNDED_HOT_LANE_MQH

// Same Runtime 7 Board / Dossier Renderer Service support lane.
// This file does not own FileIO, routes, market truth, ranking, selection, permission, or execution.
// It redirects the existing Layer 0 dossier batch caller away from the unsafe unbounded universe pass
// so Runtime 0 heartbeat surfaces can breathe while Dossier files are refreshed incrementally.

int AC_L0BoundedDossierMaxSymbolsPerPass()
{
   if(AC_DOSSIER_UNIVERSE_MAX_SYMBOLS_PER_PASS > 0)
      return AC_DOSSIER_UNIVERSE_MAX_SYMBOLS_PER_PASS;
   return 3;
}

uint AC_L0BoundedDossierPassBudgetMs()
{
   if(AC_DOSSIER_UNIVERSE_PASS_BUDGET_MS > 0)
      return (uint)AC_DOSSIER_UNIVERSE_PASS_BUDGET_MS;
   return 750;
}

string AC_L0DossierMainBlockerFromSurfaces()
{
   if(AC_L6_MAIN_BLOCKER != "none") return AC_L6_MAIN_BLOCKER;
   if(AC_L7_MAIN_BLOCKER != "none") return AC_L7_MAIN_BLOCKER;
   if(AC_L8_MAIN_BLOCKER != "none") return AC_L8_MAIN_BLOCKER;
   if(AC_L9_MAIN_BLOCKER != "none") return AC_L9_MAIN_BLOCKER;
   if(AC_L10_MAIN_BLOCKER != "none") return AC_L10_MAIN_BLOCKER;
   return AC_L5_MAIN_BLOCKER;
}

AC_WriteResult AC_RunLayer0UniverseShellPassBoundedHotLane(AC_Layer0StatusPacket &status)
{
   AC_Layer0InitStatus(status);
   AC_L0_FIRST_FAILURE = "";
   AC_L0_FAILURE_ADDENDUM = "";

   uint start_ms = GetTickCount();
   int total = SymbolsTotal(false);
   int marketwatch_total = SymbolsTotal(true);
   status.broker_symbols_total = total;
   status.marketwatch_symbols_total = marketwatch_total;

   AC_L0RefreshDossierSectionDependencies();
   string render_key = AC_L0DossierSourceKey(total);
   string progress_key = AC_L0DossierProgressKey(total);
   bool progress_changed = (progress_key != AC_L0_INCREMENTAL_SOURCE_KEY);
   bool had_cached_pass = AC_L0_CACHED_PASS_VALID;
   bool reset_needed = (progress_changed || AC_L0_INCREMENTAL_NEXT_INDEX < 0 || AC_L0_INCREMENTAL_NEXT_INDEX >= total);

   if(reset_needed)
   {
      AC_L0ResetIncrementalPass(progress_key);
      if(progress_changed || !had_cached_pass)
      {
         AC_L0ReconcileDossierRouteMembership(total);
         AC_L0SeedMissingRouteDossiers(total, status);
      }
   }

   int start_index = AC_L0_INCREMENTAL_NEXT_INDEX;
   int max_symbols = AC_L0BoundedDossierMaxSymbolsPerPass();
   if(max_symbols < 1) max_symbols = 1;
   int end_limit = total;
   if(start_index + max_symbols < end_limit)
      end_limit = start_index + max_symbols;

   uint pass_budget_ms = AC_L0BoundedDossierPassBudgetMs();
   status.batch_start_index = start_index;
   status.batch_end_index = start_index - 1;

   bool all_ok = true;
   int attempted = 0;
   int written = 0;
   int failed = 0;
   int retries_total = 0;
   bool budget_stop = false;

   for(int idx = start_index; idx < end_limit; idx++)
   {
      attempted++;
      string symbol = SymbolName(idx, false);
      if(symbol == "")
      {
         all_ok = false;
         failed++;
         string failure = "symbol=<empty>|index=" + IntegerToString(idx) + "|status=empty_symbol_name";
         if(AC_L0_FIRST_FAILURE == "") AC_L0_FIRST_FAILURE = failure;
         AC_L0_FAILURE_ADDENDUM += failure + "\r\n";
      }
      else
      {
         int retries_used = 0;
         string failure_line = "";
         if(AC_WriteLayer0ShellWithRetries(symbol, idx, status, retries_used, failure_line))
         {
            written++;
            retries_total += retries_used;
         }
         else
         {
            all_ok = false;
            failed++;
            retries_total += retries_used;
            if(AC_L0_FIRST_FAILURE == "") AC_L0_FIRST_FAILURE = failure_line;
            AC_L0_FAILURE_ADDENDUM += failure_line + "\r\n";
         }
      }

      if(pass_budget_ms > 0 && (GetTickCount() - start_ms) >= pass_budget_ms)
      {
         budget_stop = true;
         break;
      }
   }

   AC_L0_INCREMENTAL_NEXT_INDEX = start_index + attempted;
   status.batch_end_index = AC_L0_INCREMENTAL_NEXT_INDEX - 1;
   AC_L0_INCREMENTAL_WRITTEN_TOTAL += written;
   AC_L0_INCREMENTAL_FAILED_TOTAL += failed;
   AC_L0_INCREMENTAL_RETRY_TOTAL += retries_total;

   status.batch_attempted = attempted;
   status.batch_written = written;
   status.dossier_shells_ready = AC_L0_INCREMENTAL_WRITTEN_TOTAL;
   status.dossier_shells_missing = total - AC_L0_INCREMENTAL_WRITTEN_TOTAL;
   if(status.dossier_shells_missing < 0) status.dossier_shells_missing = 0;
   status.next_symbol_index = AC_L0_INCREMENTAL_NEXT_INDEX;
   status.batch_complete = (total > 0 && AC_L0_INCREMENTAL_NEXT_INDEX >= total);
   status.batch_duration_ms = GetTickCount() - start_ms;
   status.failed_symbol_count = AC_L0_INCREMENTAL_FAILED_TOTAL;
   status.retry_count_total = AC_L0_INCREMENTAL_RETRY_TOTAL;
   status.first_failure = AC_L0_FIRST_FAILURE;

   if(total <= 0)
   {
      status.status = "Waiting for broker symbol universe";
      status.main_blocker = "SymbolsTotal(false) returned zero";
   }
   else if(status.batch_complete && AC_L0_INCREMENTAL_FAILED_TOTAL == 0)
   {
      status.status = "Complete";
      status.trust_state = "Dossiers Ready";
      status.main_blocker = AC_L0DossierMainBlockerFromSurfaces();
   }
   else if(status.batch_complete)
   {
      status.status = "Complete with warnings";
      status.trust_state = "Dossiers Degraded";
      status.main_blocker = "Some symbol Dossier packets failed; see Upgrade Addendum";
   }
   else
   {
      status.status = "Incremental publishing";
      status.trust_state = "Dossiers Updating";
      status.main_blocker = budget_stop ? "Bounded Dossier hot lane stopped on heartbeat budget; continues next heartbeat" : "Bounded Dossier hot lane stopped on symbol cap; continues next heartbeat";
   }

   string batch_status = status.batch_complete ? ((AC_L0_INCREMENTAL_FAILED_TOTAL == 0) ? "dossier_universe_complete" : "dossier_universe_complete_with_degraded") : "dossier_universe_incremental_bounded_in_progress";

   if(status.batch_complete)
   {
      AC_L0_CACHED_SYMBOLS_TOTAL = total;
      AC_L0_CACHED_DOSSIER_SCHEMA_VERSION = AC_DOSSIER_SHELL_SCHEMA_VERSION;
      AC_L0_CACHED_DOSSIER_RENDER_LAYOUT_KEY = AC_DOSSIER_RENDER_LAYOUT_KEY;
      AC_L0_CACHED_L2_ROUTE_GENERATION_KEY = AC_L2_ROUTE_GENERATION_KEY;
      AC_L0_CACHED_L3_CACHE_KEY = AC_L3_CACHE_KEY;
      AC_L0_CACHED_L4_CACHE_KEY = AC_L4_CACHE_KEY;
      AC_L0_CACHED_L4_REFRESH_KEY = AC_L4_REFRESH_KEY;
      AC_L0_CACHED_L5_STATUS = AC_L5_STATUS;
      AC_L0_CACHED_L6_STATUS = AC_L6_STATUS;
      AC_L0_CACHED_L6_CHECKSUM = AC_L6_MANIFEST_PAYLOAD_CHECKSUM;
      AC_L0CacheLayer7Proof();
      AC_L0CacheLayer8Proof();
      AC_L0CacheLayer9Proof();
      AC_L0CacheLayer10Proof();
      AC_L0CacheLayer11Proof();
      AC_L0CacheLayer12Proof();
      AC_L0CacheLayer13Proof();
      AC_L0CacheLayer14Proof();
      AC_L0CacheLayer15Proof();
      AC_L16RefreshSummary();
      AC_L17RefreshSummary();
      AC_L0_CACHED_PASS_VALID = true;
      AC_L0_CACHED_STATUS = status;
      AC_L0_CACHED_RESULT = AC_MakeSyntheticWriteResult(AC_DossiersFolder(), AC_L0_INCREMENTAL_FAILED_TOTAL == 0, batch_status, (ulong)AC_L0_INCREMENTAL_WRITTEN_TOTAL, "bounded_dossier_universe_pass_complete|progress_key=" + progress_key + "|render_key=" + render_key + "|max_symbols=" + IntegerToString(max_symbols) + "|budget_ms=" + IntegerToString((int)pass_budget_ms) + "|mode=bounded_hot_lane_no_timer_starvation");
      return AC_L0_CACHED_RESULT;
   }

   AC_L0_CACHED_PASS_VALID = false;
   return AC_MakeSyntheticWriteResult(AC_DossiersFolder(), all_ok, batch_status, (ulong)written, "bounded_dossier_universe_pass_partial|progress_key=" + progress_key + "|render_key=" + render_key + "|start=" + IntegerToString(start_index) + "|end=" + IntegerToString(status.batch_end_index) + "|next=" + IntegerToString(AC_L0_INCREMENTAL_NEXT_INDEX) + "|max_symbols=" + IntegerToString(max_symbols) + "|budget_ms=" + IntegerToString((int)pass_budget_ms) + "|duration_ms=" + IntegerToString((int)status.batch_duration_ms) + "|budget_stop=" + (budget_stop ? "true" : "false") + "|mode=bounded_hot_lane_no_timer_starvation");
}

AC_WriteResult AC_PublishLayer0DossierBatchBoundedHotLane(AC_Layer0StatusPacket &status)
{
   AC_RefreshLayer6RankedSidecar();
   AC_L7RefreshRankedSidecar();
   AC_L8RefreshRankedSidecar();
   AC_L9RefreshRankedSidecar();
   AC_L10RefreshTaxonomySummary();
   AC_L11RefreshSummary();
   AC_L12RefreshSummary();
   AC_L13RefreshSummary();
   AC_L14RefreshSummary();
   AC_L15RefreshSummary();
   AC_L16RefreshSummary();
   AC_L17RefreshSummary();
   return AC_RunLayer0UniverseShellPassBoundedHotLane(status);
}

#define AC_PublishLayer0DossierBatch AC_PublishLayer0DossierBatchBoundedHotLane

#endif