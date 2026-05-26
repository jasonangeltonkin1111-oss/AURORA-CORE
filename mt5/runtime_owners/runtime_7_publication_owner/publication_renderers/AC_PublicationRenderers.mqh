#ifndef AC_PUBLICATION_RENDERERS_MQH
#define AC_PUBLICATION_RENDERERS_MQH

// Board / Dossier Renderer Service.
// Runtime 7 renders OHLC visibility only.
// Active raw OHLC storage belongs to Runtime 1 Shared OHLC Raw Storage Owner.
// Do not place a second CopyRates/storage scheduler here.
// The active bridge is included here because it is the existing Runtime 1 owner surface
// for priority windows, status, Board/Dossier/Workbench render sections, and bounded
// service activation. Runtime 7 calls it; Runtime 1 owns it.

#include "../../runtime_1_foundation_truth_owner/shared_ohlc_raw_storage/AC_SharedOhlcActiveBridge.mqh"
#include "../../runtime_1_foundation_truth_owner/shared_ohlc_raw_storage/AC_SharedOhlcLegacyAliases.mqh"
#include "../../runtime_3_external_calculation_worker_owner/AC_ExternalWorkerRenderIndex.mqh"
#include "AC_Layer7SessionRelevanceRenderer.mqh"
#include "AC_Layer8MovementRangeRenderer.mqh"
#include "AC_Layer9StructureLocationRenderer.mqh"
#include "AC_Layer10TaxonomyRenderer.mqh"
#include "AC_Layer11SelectionGroupsRenderer.mqh"
#include "AC_Layer12GroupHeatQualityRenderer.mqh"
#include "AC_Layer13DynamicGroupSelectionRenderer.mqh"
#include "AC_Layer14CandidatePoolRenderer.mqh"
#include "AC_Layer15CorrelationDiversityRenderer.mqh"
#include "AC_Layer16GlobalTop10Renderer.mqh"
#include "AC_Layer17DeepEvidenceRenderer.mqh"
#include "AC_Layer6RankedSidecarRenderer.mqh"
#include "AC_RenderIndexOptimizedDossierSections.mqh"
#include "AC_DossierPhysicalReconciliation.mqh"

string AC_FilterLinesContaining(string text, const string needle)
{
   string lines[];
   ushort sep = StringGetCharacter("\n", 0);
   int count = StringSplit(text, sep, lines);
   string out = "";
   for(int i = 0; i < count; i++)
   {
      string line = lines[i];
      if(StringFind(line, needle) >= 0) continue;
      StringReplace(line, "\r", "");
      out += line + "\r\n";
   }
   return out;
}

string AC_DossierL16L17PipelineCorrectionSection(const string symbol)
{
   AC_L16RefreshSummary();
   AC_L17RefreshSummary();
   string l16_row = AC_L16CsvLineForSymbol(symbol);
   string l17_row = AC_L17CsvLineForSymbol(symbol);
   string text = "";
   text += "\r\nCURRENT SELECTION TRUTH\r\n";
   text += "----------------------------------------\r\n";
   text += "Purpose: compact current upstream selection truth before full selection detail sections.\r\n";
   text += "Authority: this section supersedes older top-shell pipeline, selection-active, or NEXT REQUIRED wording if those lower sections still mention an earlier layer.\r\n";
   text += "Current Selection Surface: visible held L16 basket plus L17 queue split source truth available to the renderer.\r\n";
   text += "L16 Status: " + AC_L16_STATUS + "\r\n";
   text += "L16 Visible Surface State: " + AC_L16_VISIBLE_SURFACE_STATE + "\r\n";
   text += "L16 Hold State: " + AC_L16_HOLD_STATE + "\r\n";
   text += "L16 Hold Valid Until UTC: " + AC_L16_HOLD_VALID_UNTIL_UTC + "\r\n";
   text += "L16 Visible Basket Meaning: held display basket; latest calculation files may differ until hold expiry.\r\n";
   text += "L16 Selected Count: " + IntegerToString(AC_L16_SELECTED_COUNT) + " / 10\r\n";
   text += "L16 Unfilled Slots: " + IntegerToString(AC_L16_UNFILLED_SLOTS_COUNT) + "\r\n";
   text += "L16 Correlation Rejects: " + IntegerToString(AC_L16_CORRELATION_REJECT_COUNT) + "\r\n";
   text += "L16 Group Cap Rejects: " + IntegerToString(AC_L16_GROUP_CAP_REJECT_COUNT) + "\r\n";
   text += "L16 Top Symbol: " + AC_L16_TOP_SYMBOL + "\r\n";
   text += "L17 Status: " + AC_L17_STATUS + "\r\n";
   text += "L17 Queue Selected: " + IntegerToString(AC_L17_DEEP_SELECTED_COUNT) + " / 5\r\n";
   text += "L17 Clean Queued: " + IntegerToString(AC_L17_CLEAN_SELECTED_COUNT) + "\r\n";
   text += "L17 Fallback Queued: " + IntegerToString(AC_L17_FALLBACK_SELECTED_COUNT) + "\r\n";
   text += "L17 Top Queued Symbol: " + AC_L17_TOP_SYMBOL + "\r\n";
   if(l16_row == "")
   {
      text += "This Symbol L16 Visible Member: FALSE\r\n";
      text += "This Symbol Meaning: not in visible held Global Top 10 inspection basket; keep as evidence only.\r\n";
   }
   else
   {
      text += "This Symbol L16 Visible Member: TRUE\r\n";
      text += "This Symbol Visible Global Rank: #" + AC_L16CsvField(l16_row, 0) + " / " + IntegerToString(AC_L16_SELECTED_COUNT) + "\r\n";
      text += "This Symbol L16 Primary Score: " + AC_L16CsvField(l16_row, 7) + "\r\n";
      text += "This Symbol Selection Reason: " + AC_L16CsvField(l16_row, 22) + "\r\n";
      text += "This Symbol Row Hold Visible: " + AC_L16CsvField(l16_row, 38) + "\r\n";
      text += "This Symbol Row Hold State: " + AC_L16CsvField(l16_row, 39) + "\r\n";
   }
   if(l17_row == "")
   {
      text += "This Symbol L17 Queue Selected: FALSE\r\n";
      text += "This Symbol L17 Meaning: visible/watch-only unless later L17 source truth queues it.\r\n";
   }
   else
   {
      text += "This Symbol L17 Queue Selected: TRUE\r\n";
      text += "This Symbol L17 Queue Rank: #" + AC_L17CsvField(l17_row, 0) + " / " + IntegerToString(AC_L17_DEEP_SELECTED_COUNT) + "\r\n";
      text += "This Symbol L17 Depth Assignment: " + AC_L17CsvField(l17_row, 24) + "\r\n";
      text += "This Symbol L17 Budget Class: " + AC_L17CsvField(l17_row, 25) + "\r\n";
      text += "This Symbol L17 Selection Reason: " + AC_L17CsvField(l17_row, 30) + "\r\n";
   }
   text += "Selection Meaning: current selection surfaces are inspection and evidence-budget queue surfaces only; no setup alert, no trade permission, no execution.\r\n";
   text += "Current Next Required: inspect currently queued evidence-budget symbols first; non-selected rows remain visible/watch-only unless later source truth changes.\r\n";
   return text;
}

string AC_Layer11L12L13L14L15L16L17AndSharedOhlcRenderDossierSection(const string symbol)
{
   string text = "";
   text += AC_DossierL16L17PipelineCorrectionSection(symbol);
   text += AC_Layer11DossierSection(symbol);
   text += AC_Layer12DossierSection(symbol);
   text += AC_Layer13DossierSection(symbol);
   text += AC_Layer14DossierSection(symbol);
   text += AC_Layer15DossierSection(symbol);
   text += AC_Layer16DossierSection(symbol);
   text += AC_Layer17DossierSection(symbol);
   text += AC_SharedOhlcRenderDossierSection(symbol);
   return text;
}

string AC_NormalizeDossierShellText(string text)
{
   if(StringFind(text, "AURORA CORE - SYMBOL DOSSIER") < 0)
      return text;

   string top_trade_lock_marker = "__AC_DOSSIER_TOP_TRADE_PERMISSION_LOCK__\r\n";
   int top_trade_lock_pos = StringFind(text, "Trade Permission: FALSE\r\n");
   if(top_trade_lock_pos >= 0)
   {
      text = StringSubstr(text, 0, top_trade_lock_pos) + top_trade_lock_marker + StringSubstr(text, top_trade_lock_pos + StringLen("Trade Permission: FALSE\r\n"));
   }

   // Native top-shell wording cleanup. Current selection truth below remains the detailed authority.
   StringReplace(text, "Pipeline Position:   L15 correlation/diversity scored\r\n", "Pipeline Position:   Latest accepted selection/evidence surface; see CURRENT SELECTION TRUTH\r\n");
   StringReplace(text, "Pipeline Position:   L14 raw candidate pool member\r\n", "Pipeline Position:   Candidate-pool visible; see CURRENT SELECTION TRUTH\r\n");
   StringReplace(text, "L16 Global Top 10:            not_built_or_not_active_here\r\n", "L16/L17 Selection Truth:      see CURRENT SELECTION TRUTH\r\n");
   StringReplace(text, "Selection Active: L15 scoring only; no Global Top 10 or trade permission\r\n", "Selection Active: latest selection/evidence surfaces only; no trade permission\r\n");
   StringReplace(text, "Permission Active: No\r\n", "");
   StringReplace(text, "L23 Trade Permission:         false\r\n", "");
   StringReplace(text, "Next step: Layer 16 Global Top 10 builder after L15 correlation/diversity output is accepted.\r\n", "Next step: inspect currently queued evidence-budget symbols first; non-selected rows remain visible/watch-only unless later source truth changes.\r\n");
   StringReplace(text, "Layer 11-15 are inspection/selection-scoring surfaces only; no Global Top 10, alert, or trade permission exists here.\r\n", "Layer 11+ selection/evidence surfaces are inspection and evidence-budget queue surfaces only; no alert, trade permission, or execution exists here.\r\n");

   // Top-shell permission is declared once in the Dossier header and in the compact NO GO block.
   StringReplace(text, "Trade Permission:    FALSE\r\n", "");
   StringReplace(text, "Entry Signal:        FALSE\r\n", "");
   StringReplace(text, "Execution:           FALSE\r\n", "");
   StringReplace(text, "Permission Result:     FALSE\r\n", "Permission Result:     Blocked\r\n");
   StringReplace(text, "Entry Signal:          FALSE\r\n", "");
   StringReplace(text, "Execution:             FALSE\r\n", "");

   // Full-detail repeated permission/runtime false noise. Keep top header and NO GO as the permission lock.
   StringReplace(text, "Trade Permission: FALSE\r\n", "");
   StringReplace(text, "Trade Permission:       false\r\n", "");
   StringReplace(text, "Trade Permission:       FALSE\r\n", "");
   StringReplace(text, "Trade Permission:      FALSE\r\n", "");
   StringReplace(text, "Trade Permission:          FALSE\r\n", "");
   StringReplace(text, "Trade Permission:           FALSE\r\n", "");
   StringReplace(text, "Selection Runtime: FALSE\r\n", "");
   StringReplace(text, "Selection Runtime:          FALSE\r\n", "");
   StringReplace(text, "Ranking Runtime: FALSE\r\n", "");
   StringReplace(text, "Ranking Runtime:            FALSE\r\n", "");
   StringReplace(text, "Candidate Pool Runtime: FALSE\r\n", "");
   StringReplace(text, "Global Top10 Runtime: FALSE\r\n", "");
   StringReplace(text, "Deep Evidence Runtime: FALSE\r\n", "");
   StringReplace(text, "Entry Signal: FALSE\r\n", "");
   StringReplace(text, "Entry Signal:           false\r\n", "");
   StringReplace(text, "Entry Signal:          FALSE\r\n", "");
   StringReplace(text, "Entry Signal:               FALSE\r\n", "");
   StringReplace(text, "Execution: FALSE\r\n", "");
   StringReplace(text, "Execution:              false\r\n", "");
   StringReplace(text, "Execution:             FALSE\r\n", "");
   StringReplace(text, "Execution:                  FALSE\r\n", "");
   StringReplace(text, "Layer 6 Blocks Symbols: FALSE\r\n", "");
   StringReplace(text, "Layer 7 Blocks Symbols: FALSE\r\n", "");
   StringReplace(text, "Layer 8 Blocks Symbols: FALSE\r\n", "");
   StringReplace(text, "Layer 9 Blocks Symbols: FALSE\r\n", "");

   // Debug proof belongs in Workbench/status files unless abnormal.
   text = AC_FilterLinesContaining(text, "Rank Path:");
   text = AC_FilterLinesContaining(text, "Symbol Sidecar Path:");
   text = AC_FilterLinesContaining(text, "Source Generated UTC:");
   text = AC_FilterLinesContaining(text, "SymbolRank Filename Mode:");
   text = AC_FilterLinesContaining(text, "Generation Counts OK:");
   text = AC_FilterLinesContaining(text, "Generation Identity OK:");
   text = AC_FilterLinesContaining(text, "Gateway Required:");
   StringReplace(text, "Gateway Result Accepted: TRUE\r\n", "");
   StringReplace(text, "Validation: Accepted\r\n", "");
   StringReplace(text, "Validation: AcceptedWithDrift\r\n", "Validation: drift accepted\r\n");

   // Trader-facing dossiers should say why data is missing, not repeat placeholder filler.
   StringReplace(text, "Not available", "Unavailable");
   StringReplace(text, "not_available", "unavailable");

   StringReplace(text, top_trade_lock_marker, "Trade Permission: FALSE\r\n");
   return text;
}

AC_WriteResult AC_WriteTextFileFastAtomic_DossierNormalized(const string final_path, const string content);

// Surgical render-composition bridge:
// AC_Layer0DossierPublication.mqh already appends AC_SharedOhlcRenderDossierSection(symbol)
// after L10. The macro below routes that single existing append through the current selection truth + L11+L12+L13+L14+L15+L16+L17+OHLC wrapper
// so the Dossier receives current selection and evidence-budget truth without a broad rewrite of the active Dossier owner.
// Later selection surfaces are render-only here. The worker owns calculation-support outputs.
// The FileIO macro below intercepts only the generated Dossier shell text before it reaches the real FileIO owner.
#define AC_SharedOhlcRenderDossierSection AC_Layer11L12L13L14L15L16L17AndSharedOhlcRenderDossierSection
#define AC_WriteTextFileFastAtomic AC_WriteTextFileFastAtomic_DossierNormalized
#include "AC_Layer0DossierPublication.mqh"
#undef AC_WriteTextFileFastAtomic
#undef AC_SharedOhlcRenderDossierSection

AC_WriteResult AC_WriteTextFileFastAtomic_DossierNormalized(const string final_path, const string content)
{
   string normalized = AC_NormalizeDossierShellText(content);
   return AC_WriteTextFileFastAtomic(final_path, normalized);
}

string AC_SelectionDeskSafeValue(string value)
{
   StringReplace(value, "\r", " ");
   StringReplace(value, "\n", " ");
   StringReplace(value, "|", ";");
   return value;
}

void AC_SelectionDeskRefreshPipeline()
{
   AC_L10RefreshTaxonomySummary();
   AC_L11RefreshSummary();
   AC_L12RefreshSummary();
   AC_L13RefreshSummary();
   AC_L14RefreshSummary();
   AC_L15RefreshSummary();
   AC_L16RefreshSummary();
   AC_L17RefreshSummary();
}

string AC_SelectionDeskScaffoldStatus()
{
   if(AC_L16_ACCEPTED || AC_L17_ACCEPTED)
      return "selection_outputs_detected";
   if(AC_L11_ACCEPTED || AC_L12_ACCEPTED || AC_L13_ACCEPTED || AC_L14_ACCEPTED || AC_L15_ACCEPTED)
      return "selection_pipeline_partially_available";
   return "pending_upstream_worker_outputs";
}

string AC_SelectionDeskBlockerSummary()
{
   string blockers = "";
   if(!AC_L11_ACCEPTED) blockers += "L11=" + AC_SelectionDeskSafeValue(AC_L11_MAIN_BLOCKER) + ";";
   if(!AC_L12_ACCEPTED) blockers += "L12=" + AC_SelectionDeskSafeValue(AC_L12_MAIN_BLOCKER) + ";";
   if(!AC_L13_ACCEPTED) blockers += "L13=" + AC_SelectionDeskSafeValue(AC_L13_MAIN_BLOCKER) + ";";
   if(!AC_L14_ACCEPTED) blockers += "L14=" + AC_SelectionDeskSafeValue(AC_L14_MAIN_BLOCKER) + ";";
   if(!AC_L15_ACCEPTED) blockers += "L15=" + AC_SelectionDeskSafeValue(AC_L15_MAIN_BLOCKER) + ";";
   if(!AC_L16_ACCEPTED) blockers += "L16=" + AC_SelectionDeskSafeValue(AC_L16_MAIN_BLOCKER) + ";";
   if(!AC_L17_ACCEPTED) blockers += "L17=" + AC_SelectionDeskSafeValue(AC_L17_MAIN_BLOCKER) + ";";
   return blockers == "" ? "none" : blockers;
}

string AC_SelectionDeskReadMeText()
{
   string status = AC_SelectionDeskScaffoldStatus();
   string text = "";
   text += "AURORA SELECTION DESK\r\n";
   text += "----------------------------------------\r\n";
   text += "status=" + status + "\r\n";
   text += "meaning=operator_selection_view_and_dossier_shortcut_surface_only\r\n";
   text += "canonical_surfaces=01_Global;02_Asset_Classes;90_System_Indexes;91_Layer_Summaries\r\n";
   text += "canonical_global_top10=01_Global/Top_10\r\n";
   text += "canonical_asset_top5=02_Asset_Classes/<asset_class>/01_Top_5_All_<asset_class>\r\n";
   text += "canonical_group_top5=02_Asset_Classes/<asset_class>/02_Groups/<ranking_group>\r\n";
   text += "canonical_deep_evidence=01_Global/Deep_Evidence\r\n";
   text += "legacy_surfaces=Global;Groups\r\n";
   text += "legacy_surfaces_policy=support_only_not_l18_canonical_targets\r\n";
   text += "selection_runtime=false\r\n";
   text += "trade_permission=false\r\n";
   text += "entry_signal=false\r\n";
   text += "execution=false\r\n";
   text += "current_blockers=" + AC_SelectionDeskBlockerSummary() + "\r\n";
   text += "gateway_status=" + AC_SelectionDeskSafeValue(AC_EXTERNAL_WORKER_STATUS.worker_status) + "\r\n";
   text += "gateway_install_status=" + AC_SelectionDeskSafeValue(AC_EXTERNAL_WORKER_STATUS.install_status) + "\r\n";
   text += "generated_at=" + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS) + "\r\n";
   return text;
}

string AC_SelectionDeskIndexText()
{
   string status = AC_SelectionDeskScaffoldStatus();
   string text = "";
   text += "schema_name=selection_desk_root_index\r\n";
   text += "schema_version=mt5_pending_scaffold_v1\r\n";
   text += "owner_name=Runtime 7 publication owner pending scaffold\r\n";
   text += "source_owner=Runtime 3 external worker L10-L17 calculation support outputs\r\n";
   text += "status=" + status + "\r\n";
   text += "reason=" + AC_SelectionDeskBlockerSummary() + "\r\n";
   text += "root_path=" + AC_SelectionDeskFolder() + "\r\n";
   text += "readme_path=" + AC_SelectionReadMePath() + "\r\n";
   text += "legacy_index_path=" + AC_SelectionIndexPath() + "\r\n";
   text += "canonical_index_path=" + AC_SelectionCanonicalIndexPath() + "\r\n";
   text += "status_path=" + AC_SelectionDeskStatusPath() + "\r\n";
   text += "global_top10_surface=" + AC_SelectionGlobalTop10Folder() + "\r\n";
   text += "asset_class_surface=" + AC_SelectionAssetClassesFolder() + "\r\n";
   text += "system_indexes_surface=" + AC_SelectionSystemIndexesFolder() + "\r\n";
   text += "layer_summaries_surface=" + AC_SelectionLayerSummariesFolder() + "\r\n";
   text += "l18_target_scope=canonical_selection_shortcut_dossiers_only\r\n";
   text += "l18_allowed_surfaces=01_Global/Top_10/*.txt;02_Asset_Classes/*/01_Top_5_All_*/*.txt;02_Asset_Classes/*/02_Groups/*/*.txt\r\n";
   text += "l18_excluded_surfaces=Selection Desk/Global;Selection Desk/Groups;90_System_Indexes;91_Layer_Summaries;base Dossiers/Open;base Dossiers/Closed;base Dossiers/Unknown\r\n";
   text += "selection_runtime=false\r\n";
   text += "trade_permission=false\r\n";
   text += "entry_signal=false\r\n";
   text += "execution=false\r\n";
   text += "generated_at=" + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS) + "\r\n";
   return text;
}

string AC_SelectionDeskLayerStatusText()
{
   string text = "";
   text += "schema_name=selection_desk_layer_status\r\n";
   text += "schema_version=mt5_pending_scaffold_v1\r\n";
   text += "status=" + AC_SelectionDeskScaffoldStatus() + "\r\n";
   text += "gateway_status=" + AC_SelectionDeskSafeValue(AC_EXTERNAL_WORKER_STATUS.worker_status) + "\r\n";
   text += "gateway_install_status=" + AC_SelectionDeskSafeValue(AC_EXTERNAL_WORKER_STATUS.install_status) + "\r\n";
   text += "l10_status=" + AC_SelectionDeskSafeValue(AC_L10_STATUS) + "\r\n";
   text += "l11_status=" + AC_SelectionDeskSafeValue(AC_L11_STATUS) + "\r\n";
   text += "l11_blocker=" + AC_SelectionDeskSafeValue(AC_L11_MAIN_BLOCKER) + "\r\n";
   text += "l12_status=" + AC_SelectionDeskSafeValue(AC_L12_STATUS) + "\r\n";
   text += "l12_blocker=" + AC_SelectionDeskSafeValue(AC_L12_MAIN_BLOCKER) + "\r\n";
   text += "l13_status=" + AC_SelectionDeskSafeValue(AC_L13_STATUS) + "\r\n";
   text += "l13_blocker=" + AC_SelectionDeskSafeValue(AC_L13_MAIN_BLOCKER) + "\r\n";
   text += "l14_status=" + AC_SelectionDeskSafeValue(AC_L14_STATUS) + "\r\n";
   text += "l14_blocker=" + AC_SelectionDeskSafeValue(AC_L14_MAIN_BLOCKER) + "\r\n";
   text += "l15_status=" + AC_SelectionDeskSafeValue(AC_L15_STATUS) + "\r\n";
   text += "l15_blocker=" + AC_SelectionDeskSafeValue(AC_L15_MAIN_BLOCKER) + "\r\n";
   text += "l16_status=" + AC_SelectionDeskSafeValue(AC_L16_STATUS) + "\r\n";
   text += "l16_selected_count=" + IntegerToString(AC_L16_SELECTED_COUNT) + "\r\n";
   text += "l16_blocker=" + AC_SelectionDeskSafeValue(AC_L16_MAIN_BLOCKER) + "\r\n";
   text += "l17_status=" + AC_SelectionDeskSafeValue(AC_L17_STATUS) + "\r\n";
   text += "l17_deep_selected_count=" + IntegerToString(AC_L17_DEEP_SELECTED_COUNT) + "\r\n";
   text += "l17_blocker=" + AC_SelectionDeskSafeValue(AC_L17_MAIN_BLOCKER) + "\r\n";
   text += "selection_runtime=false\r\n";
   text += "trade_permission=false\r\n";
   text += "entry_signal=false\r\n";
   text += "execution=false\r\n";
   text += "generated_at=" + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS) + "\r\n";
   return text;
}

string AC_SelectionDeskShortcutStatusText(const string shortcut_type, const string reason)
{
   string text = "";
   text += "schema_name=selection_surface_shortcut_status\r\n";
   text += "schema_version=mt5_pending_scaffold_v1\r\n";
   text += "owner_name=Runtime 7 publication owner pending scaffold\r\n";
   text += "source_owner=Runtime 3 external worker copy bridge\r\n";
   text += "shortcut_type=" + shortcut_type + "\r\n";
   text += "status=" + AC_SelectionDeskScaffoldStatus() + "\r\n";
   text += "reason=" + AC_SelectionDeskSafeValue(reason) + "\r\n";
   text += "dossier_copies_written=0\r\n";
   text += "dossier_copies_expected=0\r\n";
   text += "selection_runtime=false\r\n";
   text += "trade_permission=false\r\n";
   text += "entry_signal=false\r\n";
   text += "execution=false\r\n";
   text += "generated_at=" + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS) + "\r\n";
   return text;
}

void AC_SelectionDeskMergeWrite(const AC_WriteResult &result,
                                int &written,
                                int &failed,
                                ulong &bytes,
                                string &failed_paths)
{
   if(result.ok)
   {
      written++;
      bytes += result.final_size;
      return;
   }
   failed++;
   failed_paths += result.final_path + "|status=" + result.status + "|error=" + IntegerToString(result.error_code) + ";";
}

AC_WriteResult AC_PublishSelectionDeskScaffold()
{
   AC_SelectionDeskRefreshPipeline();

   string detail = "";
   string folder_detail = "";
   bool folders_ok = true;
   folders_ok = AC_EnsureFolderPath(AC_SelectionDeskFolder(), folder_detail) && folders_ok;
   detail += "selection_desk=" + folder_detail + ";";
   folders_ok = AC_EnsureFolderPath(AC_SelectionGroupsFolder(), folder_detail) && folders_ok;
   detail += "legacy_groups=" + folder_detail + ";";
   folders_ok = AC_EnsureFolderPath(AC_SelectionGlobalFolder(), folder_detail) && folders_ok;
   detail += "legacy_global=" + folder_detail + ";";
   folders_ok = AC_EnsureFolderPath(AC_SelectionGlobalTop10Folder(), folder_detail) && folders_ok;
   detail += "global_top10=" + folder_detail + ";";
   folders_ok = AC_EnsureFolderPath(AC_SelectionGlobalDeepEvidenceFolder(), folder_detail) && folders_ok;
   detail += "deep_evidence=" + folder_detail + ";";
   folders_ok = AC_EnsureFolderPath(AC_SelectionAssetClassesFolder(), folder_detail) && folders_ok;
   detail += "asset_classes=" + folder_detail + ";";
   folders_ok = AC_EnsureFolderPath(AC_SelectionSystemIndexesFolder(), folder_detail) && folders_ok;
   detail += "system_indexes=" + folder_detail + ";";
   folders_ok = AC_EnsureFolderPath(AC_SelectionLayerSummariesFolder(), folder_detail) && folders_ok;
   detail += "layer_summaries=" + folder_detail + ";";

   int written = 0;
   int failed = 0;
   ulong bytes = 0;
   string failed_paths = "";

   string readme_text = AC_SelectionDeskReadMeText();
   string index_text = AC_SelectionDeskIndexText();
   string layer_text = AC_SelectionDeskLayerStatusText();
   string global_reason = "missing_or_pending_l16_selection_desk_current_top10_csv:" + AC_L16SelectionDeskCsvPath();
   string group_reason = "missing_or_pending_l11_to_l15_selection_group_outputs";

   AC_WriteResult r = AC_WriteTextFile(AC_SelectionReadMePath(), readme_text);
   AC_SelectionDeskMergeWrite(r, written, failed, bytes, failed_paths);
   r = AC_WriteTextFile(AC_SelectionCanonicalIndexPath(), index_text);
   AC_SelectionDeskMergeWrite(r, written, failed, bytes, failed_paths);
   r = AC_WriteTextFile(AC_SelectionIndexPath(), index_text);
   AC_SelectionDeskMergeWrite(r, written, failed, bytes, failed_paths);
   r = AC_WriteTextFile(AC_SelectionDeskStatusPath(), index_text);
   AC_SelectionDeskMergeWrite(r, written, failed, bytes, failed_paths);
   r = AC_WriteTextFile(AC_SelectionLayerStatusPath(), layer_text);
   AC_SelectionDeskMergeWrite(r, written, failed, bytes, failed_paths);
   r = AC_WriteTextFile(AC_SelectionGlobalTop10TextPath(), "L16 GLOBAL TOP 10 DOSSIER SHORTCUTS\r\n----------------------------------------\r\n" + AC_SelectionDeskShortcutStatusText("global_top10_dossier_copy", global_reason));
   AC_SelectionDeskMergeWrite(r, written, failed, bytes, failed_paths);
   r = AC_WriteTextFile(AC_SelectionGlobalTop10CsvPath(), "global_top10_rank,symbol,canonical_symbol,copy_status,meaning,trade_permission,entry_signal,execution,generated_at\r\n");
   AC_SelectionDeskMergeWrite(r, written, failed, bytes, failed_paths);
   r = AC_WriteTextFile(AC_SelectionGlobalTop10CopyStatusPath(), AC_SelectionDeskShortcutStatusText("global_top10_dossier_copy", global_reason));
   AC_SelectionDeskMergeWrite(r, written, failed, bytes, failed_paths);
   r = AC_WriteTextFile(AC_SelectionAssetClassTop5StatusPath(), AC_SelectionDeskShortcutStatusText("asset_class_top5", group_reason));
   AC_SelectionDeskMergeWrite(r, written, failed, bytes, failed_paths);
   r = AC_WriteTextFile(AC_SelectionAssetClassTop5IndexPath(), "AURORA SELECTION DESK - ASSET CLASS TOP 5 INDEX\r\n----------------------------------------\r\n" + AC_SelectionDeskShortcutStatusText("asset_class_top5", group_reason));
   AC_SelectionDeskMergeWrite(r, written, failed, bytes, failed_paths);
   r = AC_WriteTextFile(AC_SelectionShallowGroupTop5StatusPath(), AC_SelectionDeskShortcutStatusText("shallow_group_top5", group_reason));
   AC_SelectionDeskMergeWrite(r, written, failed, bytes, failed_paths);
   r = AC_WriteTextFile(AC_SelectionLegacyGlobalStatusPath(), AC_SelectionDeskShortcutStatusText("legacy_global_support_surface", global_reason));
   AC_SelectionDeskMergeWrite(r, written, failed, bytes, failed_paths);
   r = AC_WriteTextFile(AC_SelectionLegacyGroupsStatusPath(), AC_SelectionDeskShortcutStatusText("legacy_groups_support_surface", group_reason));
   AC_SelectionDeskMergeWrite(r, written, failed, bytes, failed_paths);

   bool ok = folders_ok && failed == 0;
   string status = ok ? "selection_desk_scaffold_published" : "selection_desk_scaffold_degraded";
   detail += "files_written=" + IntegerToString(written)
      + ";files_failed=" + IntegerToString(failed)
      + ";failed_paths=" + failed_paths
      + ";scaffold_status=" + AC_SelectionDeskScaffoldStatus();
   return AC_MakeSyntheticWriteResult(AC_SelectionDeskFolder(), ok, status, bytes, detail);
}

// Wrap the existing board/workbench/status renderers so compact operator-truth sections can be appended
// without rewriting the Board owner or creating a duplicate dashboard/diagnostics system.
#define AC_BuildTraderBoardText AC_BuildTraderBoardText_Base
#define AC_Layer0WorkbenchText AC_Layer0WorkbenchText_Base
#define AC_Layer0StatusRow AC_Layer0StatusRow_Base
#include "AC_MarketBoardRenderer.mqh"
#undef AC_Layer0StatusRow
#undef AC_Layer0WorkbenchText
#undef AC_BuildTraderBoardText
#include "AC_TraderChatExportGuideRenderer.mqh"

string AC_Layer0StatusRow(const AC_Layer0StatusPacket &status)
{
   return AC_Layer0StatusRow_Base(status);
}

string AC_Layer0WorkbenchText(const AC_Layer0StatusPacket &status)
{
   return AC_Layer0WorkbenchText_Base(status);
}

#endif
