#ifndef AC_PUBLICATION_RENDERERS_MQH
#define AC_PUBLICATION_RENDERERS_MQH

// Board / Dossier Renderer Service.
// Runtime 7 renders publication surfaces only. It does not calculate ranking, selection, permission, alerts, or execution.
// Active raw OHLC storage belongs to Runtime 1 Shared OHLC Raw Storage Owner.
// Runtime 3 external worker owns calculation-support outputs.
// This renderer may publish fallback scaffolds, but must not overwrite accepted canonical worker Selection Desk surfaces.

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
   text += "Authority: current Runtime 3 worker outputs read by Runtime 7 renderers; no trade permission.\r\n";
   text += "Current Selection Surface: visible held L16 basket plus L17 evidence-budget queue split.\r\n";
   text += "L16 Status: " + AC_L16_STATUS + "\r\n";
   text += "L16 Visible Surface State: " + AC_L16_VISIBLE_SURFACE_STATE + "\r\n";
   text += "L16 Hold State: " + AC_L16_HOLD_STATE + "\r\n";
   text += "L16 Hold Valid Until UTC: " + AC_L16_HOLD_VALID_UNTIL_UTC + "\r\n";
   text += "L16 Selected Count: " + IntegerToString(AC_L16_SELECTED_COUNT) + " / 10\r\n";
   text += "L16 Top Symbol: " + AC_L16_TOP_SYMBOL + "\r\n";
   text += "L17 Status: " + AC_L17_STATUS + "\r\n";
   text += "L17 Queue Selected: " + IntegerToString(AC_L17_DEEP_SELECTED_COUNT) + " / 5\r\n";
   text += "L17 Clean / Fallback Queued: " + IntegerToString(AC_L17_CLEAN_SELECTED_COUNT) + " / " + IntegerToString(AC_L17_FALLBACK_SELECTED_COUNT) + "\r\n";
   text += "L17 Top Queued Symbol: " + AC_L17_TOP_SYMBOL + "\r\n";
   text += "This Symbol L16 Visible Member: " + (l16_row == "" ? "FALSE" : "TRUE") + "\r\n";
   text += "This Symbol L17 Queue Selected: " + (l17_row == "" ? "FALSE" : "TRUE") + "\r\n";
   text += "Selection Meaning: inspection and evidence-budget queue surfaces only; no setup alert, no trade permission, no execution.\r\n";
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

   StringReplace(text, "Pipeline Position:   L15 correlation/diversity scored\r\n", "Pipeline Position:   Latest accepted selection/evidence surface; see CURRENT SELECTION TRUTH\r\n");
   StringReplace(text, "Pipeline Position:   L14 raw candidate pool member\r\n", "Pipeline Position:   Candidate-pool visible; see CURRENT SELECTION TRUTH\r\n");
   StringReplace(text, "L16 Global Top 10:            not_built_or_not_active_here\r\n", "L16/L17 Selection Truth:      see CURRENT SELECTION TRUTH\r\n");
   StringReplace(text, "Selection Active: L15 scoring only; no Global Top 10 or trade permission\r\n", "Selection Active: latest selection/evidence surfaces only; no trade permission\r\n");
   StringReplace(text, "Next step: Layer 16 Global Top 10 builder after L15 correlation/diversity output is accepted.\r\n", "Next step: inspect currently queued evidence-budget symbols first; non-selected rows remain visible/watch-only unless later source truth changes.\r\n");
   text = AC_FilterLinesContaining(text, "Rank Path:");
   text = AC_FilterLinesContaining(text, "Symbol Sidecar Path:");
   text = AC_FilterLinesContaining(text, "Gateway Required:");
   StringReplace(text, "Not available", "Unavailable");
   StringReplace(text, "not_available", "unavailable");
   return text;
}

AC_WriteResult AC_WriteTextFileFastAtomic_DossierNormalized(const string final_path, const string content);

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
   if(AC_L16_ACCEPTED && AC_L17_ACCEPTED)
      return "accepted_current_l16_l17_surfaces_detected";
   if(AC_L16_ACCEPTED || AC_L17_ACCEPTED)
      return "accepted_partial_current_selection_surfaces_detected";
   if(AC_L11_ACCEPTED || AC_L12_ACCEPTED || AC_L13_ACCEPTED || AC_L14_ACCEPTED || AC_L15_ACCEPTED)
      return "selection_pipeline_partially_available";
   return "pending_upstream_worker_outputs";
}

string AC_SelectionDeskBlockerSummary()
{
   if(AC_L16_ACCEPTED && AC_L17_ACCEPTED)
      return "none_for_l16_l17_current_selection_surfaces";

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
   string text = "";
   text += "AURORA SELECTION DESK\r\n";
   text += "----------------------------------------\r\n";
   text += "status=" + AC_SelectionDeskScaffoldStatus() + "\r\n";
   text += "meaning=operator_selection_view_and_dossier_shortcut_surface_only\r\n";
   text += "canonical_surfaces=01_Global;02_Asset_Classes;90_System_Indexes;91_Layer_Summaries\r\n";
   text += "canonical_global_top10=01_Global/Top_10\r\n";
   text += "canonical_deep_evidence=01_Global/Deep_Evidence\r\n";
   text += "legacy_surfaces=Global;Groups\r\n";
   text += "legacy_surfaces_policy=support_only_not_l18_canonical_targets_not_acceptance_authority\r\n";
   text += "current_blockers=" + AC_SelectionDeskBlockerSummary() + "\r\n";
   text += "gateway_status=" + AC_SelectionDeskSafeValue(AC_EXTERNAL_WORKER_STATUS.worker_status) + "\r\n";
   text += "gateway_install_status=" + AC_SelectionDeskSafeValue(AC_EXTERNAL_WORKER_STATUS.install_status) + "\r\n";
   text += "selection_runtime=false\r\ntrade_permission=false\r\nentry_signal=false\r\nexecution=false\r\n";
   text += "generated_at=" + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS) + "\r\n";
   return text;
}

string AC_SelectionDeskIndexText()
{
   string text = "";
   text += "schema_name=selection_desk_root_index\r\n";
   text += "schema_version=3\r\n";
   text += "owner_name=Runtime 7 publication owner selection desk router\r\n";
   text += "source_owner=Runtime 3 external worker L10-L17 calculation support outputs\r\n";
   text += "status=" + AC_SelectionDeskScaffoldStatus() + "\r\n";
   text += "reason=" + AC_SelectionDeskBlockerSummary() + "\r\n";
   text += "root_path=" + AC_SelectionDeskFolder() + "\r\n";
   text += "canonical_index_path=" + AC_SelectionCanonicalIndexPath() + "\r\n";
   text += "status_path=" + AC_SelectionDeskStatusPath() + "\r\n";
   text += "global_top10_status=" + AC_SelectionDeskSafeValue(AC_L16_STATUS) + "\r\n";
   text += "global_top10_selected_count=" + IntegerToString(AC_L16_SELECTED_COUNT) + "\r\n";
   text += "global_top10_top_symbol=" + AC_L16_TOP_SYMBOL + "\r\n";
   text += "deep_evidence_status=" + AC_SelectionDeskSafeValue(AC_L17_STATUS) + "\r\n";
   text += "deep_evidence_selected_count=" + IntegerToString(AC_L17_DEEP_SELECTED_COUNT) + "\r\n";
   text += "deep_evidence_top_symbol=" + AC_L17_TOP_SYMBOL + "\r\n";
   text += "canonical_global_top10=" + AC_SelectionGlobalTop10Folder() + "\r\n";
   text += "canonical_deep_evidence=" + AC_SelectionGlobalDeepEvidenceFolder() + "\r\n";
   text += "selection_runtime=false\r\ntrade_permission=false\r\nentry_signal=false\r\nexecution=false\r\n";
   text += "generated_at=" + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS) + "\r\n";
   return text;
}

string AC_SelectionDeskLayerStatusText()
{
   string text = "";
   text += "schema_name=selection_desk_layer_status\r\n";
   text += "schema_version=3\r\n";
   text += "status=" + AC_SelectionDeskScaffoldStatus() + "\r\n";
   text += "gateway_status=" + AC_SelectionDeskSafeValue(AC_EXTERNAL_WORKER_STATUS.worker_status) + "\r\n";
   text += "gateway_install_status=" + AC_SelectionDeskSafeValue(AC_EXTERNAL_WORKER_STATUS.install_status) + "\r\n";
   text += "l10_status=" + AC_SelectionDeskSafeValue(AC_L10_STATUS) + "\r\n";
   text += "l11_status=" + AC_SelectionDeskSafeValue(AC_L11_STATUS) + "\r\n";
   text += "l12_status=" + AC_SelectionDeskSafeValue(AC_L12_STATUS) + "\r\n";
   text += "l13_status=" + AC_SelectionDeskSafeValue(AC_L13_STATUS) + "\r\n";
   text += "l14_status=" + AC_SelectionDeskSafeValue(AC_L14_STATUS) + "\r\n";
   text += "l15_status=" + AC_SelectionDeskSafeValue(AC_L15_STATUS) + "\r\n";
   text += "l16_status=" + AC_SelectionDeskSafeValue(AC_L16_STATUS) + "\r\n";
   text += "l16_selected_count=" + IntegerToString(AC_L16_SELECTED_COUNT) + "\r\n";
   text += "l17_status=" + AC_SelectionDeskSafeValue(AC_L17_STATUS) + "\r\n";
   text += "l17_deep_selected_count=" + IntegerToString(AC_L17_DEEP_SELECTED_COUNT) + "\r\n";
   text += "blockers=" + AC_SelectionDeskBlockerSummary() + "\r\n";
   text += "selection_runtime=false\r\ntrade_permission=false\r\nentry_signal=false\r\nexecution=false\r\n";
   text += "generated_at=" + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS) + "\r\n";
   return text;
}

string AC_SelectionDeskShortcutStatusText(const string shortcut_type, const string reason)
{
   string text = "";
   text += "schema_name=selection_surface_shortcut_status\r\n";
   text += "schema_version=3\r\n";
   text += "owner_name=Runtime 7 publication owner fallback scaffold\r\n";
   text += "source_owner=Runtime 3 external worker copy bridge\r\n";
   text += "shortcut_type=" + shortcut_type + "\r\n";
   text += "status=" + AC_SelectionDeskScaffoldStatus() + "\r\n";
   text += "reason=" + AC_SelectionDeskSafeValue(reason) + "\r\n";
   text += "selection_runtime=false\r\ntrade_permission=false\r\nentry_signal=false\r\nexecution=false\r\n";
   text += "generated_at=" + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS) + "\r\n";
   return text;
}

void AC_SelectionDeskMergeWrite(const AC_WriteResult &result, int &written, int &failed, ulong &bytes, string &failed_paths)
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

   string global_reason = "missing_or_pending_l16_canonical_worker_output:" + AC_L16Top10CsvPath();
   string group_reason = "missing_or_pending_l11_to_l15_selection_group_outputs";
   if(!AC_L16_ACCEPTED)
   {
      r = AC_WriteTextFile(AC_SelectionGlobalTop10TextPath(), "L16 GLOBAL TOP 10 DOSSIER SHORTCUTS\r\n----------------------------------------\r\n" + AC_SelectionDeskShortcutStatusText("global_top10_dossier_copy", global_reason));
      AC_SelectionDeskMergeWrite(r, written, failed, bytes, failed_paths);
      r = AC_WriteTextFile(AC_SelectionGlobalTop10CsvPath(), "global_top10_rank,symbol,canonical_symbol,copy_status,meaning,trade_permission,entry_signal,execution,generated_at\r\n");
      AC_SelectionDeskMergeWrite(r, written, failed, bytes, failed_paths);
      r = AC_WriteTextFile(AC_SelectionGlobalTop10CopyStatusPath(), AC_SelectionDeskShortcutStatusText("global_top10_dossier_copy", global_reason));
      AC_SelectionDeskMergeWrite(r, written, failed, bytes, failed_paths);
   }
   else
   {
      detail += "canonical_l16_surface_preserved=true;";
   }

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
