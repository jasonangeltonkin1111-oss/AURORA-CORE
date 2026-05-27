#ifndef AC_PUBLICATION_RENDERERS_MQH
#define AC_PUBLICATION_RENDERERS_MQH

// Board / Dossier Renderer Service.
// Runtime 7 renders publication surfaces only. It does not calculate ranking, selection, permission, alerts, or execution.
// Active raw OHLC storage belongs to Runtime 1 Shared OHLC Raw Storage Owner.
// Runtime 3 external worker owns calculation-support outputs.
// Dossier publication stays owned by AC_Layer0DossierPublication.mqh; this file must not redefine its batch owner.

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
#include "AC_Layer0DossierPublication.mqh"

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
   text += "stable_parent_surfaces=Global;Groups;Selection Index.txt\r\n";
   text += "compatibility_helper_surfaces=01_Global;02_Asset_Classes;90_System_Indexes;91_Layer_Summaries\r\n";
   text += "compatibility_helper_surface_policy=compatibility_only_not_route_law_authority\r\n";
   text += "route_authority_note=Global_and_Groups_are_stable_operator_routes;01_Global_and_02_Asset_Classes_are_shortcut_helper_surfaces\r\n";
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
   text += "schema_version=5\r\n";
   text += "owner_name=Runtime 7 publication owner selection desk router\r\n";
   text += "source_owner=Runtime 3 external worker L10-L17 calculation support outputs\r\n";
   text += "status=" + AC_SelectionDeskScaffoldStatus() + "\r\n";
   text += "reason=" + AC_SelectionDeskBlockerSummary() + "\r\n";
   text += "root_path=" + AC_SelectionDeskFolder() + "\r\n";
   text += "stable_global_path=" + AC_SelectionGlobalFolder() + "\r\n";
   text += "stable_groups_path=" + AC_SelectionGroupsFolder() + "\r\n";
   text += "stable_route_contract=Global;Groups;Selection Index.txt\r\n";
   text += "compatibility_global_top10_path=" + AC_SelectionGlobalTop10Folder() + "\r\n";
   text += "compatibility_deep_evidence_path=" + AC_SelectionGlobalDeepEvidenceFolder() + "\r\n";
   text += "compatibility_route_contract=01_Global;02_Asset_Classes;90_System_Indexes;91_Layer_Summaries\r\n";
   text += "global_top10_status=" + AC_SelectionDeskSafeValue(AC_L16_STATUS) + "\r\n";
   text += "global_top10_selected_count=" + IntegerToString(AC_L16_SELECTED_COUNT) + "\r\n";
   text += "global_top10_top_symbol=" + AC_L16_TOP_SYMBOL + "\r\n";
   text += "deep_evidence_status=" + AC_SelectionDeskSafeValue(AC_L17_STATUS) + "\r\n";
   text += "deep_evidence_selected_count=" + IntegerToString(AC_L17_DEEP_SELECTED_COUNT) + "\r\n";
   text += "deep_evidence_top_symbol=" + AC_L17_TOP_SYMBOL + "\r\n";
   text += "selection_runtime=false\r\ntrade_permission=false\r\nentry_signal=false\r\nexecution=false\r\n";
   text += "generated_at=" + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS) + "\r\n";
   return text;
}

string AC_SelectionDeskLayerStatusText()
{
   string text = "";
   text += "schema_name=selection_desk_layer_status\r\n";
   text += "schema_version=5\r\n";
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
   text += "schema_version=5\r\n";
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
   detail += "groups=" + folder_detail + ";";
   folders_ok = AC_EnsureFolderPath(AC_SelectionGlobalFolder(), folder_detail) && folders_ok;
   detail += "global=" + folder_detail + ";";
   folders_ok = AC_EnsureFolderPath(AC_SelectionGlobalTop10Folder(), folder_detail) && folders_ok;
   detail += "compat_global_top10=" + folder_detail + ";";
   folders_ok = AC_EnsureFolderPath(AC_SelectionGlobalDeepEvidenceFolder(), folder_detail) && folders_ok;
   detail += "compat_deep_evidence=" + folder_detail + ";";
   folders_ok = AC_EnsureFolderPath(AC_SelectionAssetClassesFolder(), folder_detail) && folders_ok;
   detail += "compat_asset_classes=" + folder_detail + ";";
   folders_ok = AC_EnsureFolderPath(AC_SelectionSystemIndexesFolder(), folder_detail) && folders_ok;
   detail += "compat_system_indexes=" + folder_detail + ";";
   folders_ok = AC_EnsureFolderPath(AC_SelectionLayerSummariesFolder(), folder_detail) && folders_ok;
   detail += "compat_layer_summaries=" + folder_detail + ";";

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

   string global_reason = "missing_or_pending_l16_worker_output:" + AC_L16Top10CsvPath();
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
      detail += "l16_surface_preserved=true;";
   }

   r = AC_WriteTextFile(AC_SelectionAssetClassTop5StatusPath(), AC_SelectionDeskShortcutStatusText("asset_class_top5", group_reason));
   AC_SelectionDeskMergeWrite(r, written, failed, bytes, failed_paths);
   r = AC_WriteTextFile(AC_SelectionAssetClassTop5IndexPath(), "AURORA SELECTION DESK - ASSET CLASS TOP 5 INDEX\r\n----------------------------------------\r\n" + AC_SelectionDeskShortcutStatusText("asset_class_top5", group_reason));
   AC_SelectionDeskMergeWrite(r, written, failed, bytes, failed_paths);
   r = AC_WriteTextFile(AC_SelectionShallowGroupTop5StatusPath(), AC_SelectionDeskShortcutStatusText("shallow_group_top5", group_reason));
   AC_SelectionDeskMergeWrite(r, written, failed, bytes, failed_paths);
   r = AC_WriteTextFile(AC_SelectionLegacyGlobalStatusPath(), AC_SelectionDeskShortcutStatusText("stable_global_support_surface", global_reason));
   AC_SelectionDeskMergeWrite(r, written, failed, bytes, failed_paths);
   r = AC_WriteTextFile(AC_SelectionLegacyGroupsStatusPath(), AC_SelectionDeskShortcutStatusText("stable_groups_support_surface", group_reason));
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
#define AC_BuildTraderBoardText AC_BuildTraderBoardText_TraderChatWrapper
#include "AC_TraderChatExportGuideRenderer.mqh"
#undef AC_BuildTraderBoardText

string AC_UxBoardStateLine(const string name, const string value)
{
   return name + ": " + value + "\r\n";
}

string AC_UxBoardRow(const string layer, const string state, const string detail)
{
   return layer + " | " + state + " | " + detail + "\r\n";
}

void AC_UxAppendWarning(string &text, int &idx, const string warning)
{
   if(warning == "" || warning == "none")
      return;
   text += "[" + IntegerToString(idx) + "] " + warning + "\r\n";
   idx++;
}

string AC_UxBoardPublicationBlocker(const AC_Layer0StatusPacket &status)
{
   if(status.main_blocker == "" || status.main_blocker == "none" || StringFind(status.main_blocker, "none_") == 0)
      return "NONE";
   return status.main_blocker;
}

string AC_UxBoardInspectionWarning(const AC_Layer0StatusPacket &status)
{
   string text = "";
   if(StringFind(status.main_blocker, "l5_drift=true") >= 0)
      text += "L6 snapshot valid but drifted from current L5 pass set; ";
   if(AC_BoardWarningText() != "none")
      text += AC_BoardWarningText();
   if(text == "")
      return "none";
   return text;
}

string AC_UxBoardInspectionState()
{
   if(AC_BoardWarningText() == "none" && AC_L18_SOURCE_FILES_MISSING == 0 && AC_L19_FRESHNESS_STALE_COUNT == 0)
      return "USABLE";
   return "USABLE_WITH_WARNINGS";
}

string AC_UxBoardGatewayLine()
{
   return AC_BoardGatewayState() + " | " + AC_EXTERNAL_WORKER_STATUS.worker_status + " | " + AC_BoardGatewayProgress();
}

string AC_UxBoardChainStateSection()
{
   string cycle = AC_BoardGatewayCycleText();
   string text = "";
   text += "\r\nCHAIN COCKPIT\r\n";
   text += "--------------------------------------------------\r\n";
   text += AC_UxBoardStateLine("Chain State", AC_L16KvValue(cycle, "chain_state", "not_runtime_proven"));
   text += AC_UxBoardStateLine("Core Completion", AC_L16KvValue(cycle, "core_completion_state", "not_runtime_proven"));
   text += AC_UxBoardStateLine("Deep Completion", AC_L16KvValue(cycle, "deep_completion_state", "not_runtime_proven"));
   text += AC_UxBoardStateLine("Current Top10", "L16=" + IntegerToString(AC_L16_SELECTED_COUNT) + "/10 state=" + AC_L16_STATUS);
   text += AC_UxBoardStateLine("Current Top5 Deep", "L17=" + IntegerToString(AC_L17_DEEP_SELECTED_COUNT) + "/5 state=" + AC_L17_STATUS);
   text += AC_UxBoardStateLine("Static Hold", AC_L16KvValue(cycle, "accepted_epoch_static_hold_active", "false") + " remaining=" + AC_L16KvValue(cycle, "accepted_epoch_static_remaining_seconds", "0") + "s");
   text += AC_UxBoardStateLine("Retry Cycle", AC_L16KvValue(cycle, "retry_cycle_count", "0") + "/" + AC_L16KvValue(cycle, "retry_cycle_limit", "5"));
   text += AC_UxBoardStateLine("Main Blocker", AC_L16KvValue(cycle, "main_blocker_owner", "not_runtime_proven") + " | " + AC_L16KvValue(cycle, "main_blocker_reason", "not_runtime_proven"));
   text += AC_UxBoardStateLine("L8 Strict State", AC_L8_STATUS);
   text += AC_UxBoardStateLine("L15 Correlation", AC_L15_STATUS + " current=" + AC_L16KvValue(cycle, "l15_current_chain_valid", "see_gateway_result"));
   text += AC_UxBoardStateLine("L16 Top10", AC_L16_STATUS + " current=" + AC_L16KvValue(cycle, "l16_current_chain_valid", "see_gateway_result"));
   text += AC_UxBoardStateLine("L17 Currentness", AC_L17_STATUS + " current=" + AC_L16KvValue(cycle, "l17_current_chain_valid", "see_gateway_result"));
   text += AC_UxBoardStateLine("L18 Raw OHLC", AC_L18_STATUS + " current=" + AC_L16KvValue(cycle, "l18_current_chain_valid", "see_gateway_result"));
   text += AC_UxBoardStateLine("L19 Geometry", AC_L19_STATUS + " current=" + AC_L16KvValue(cycle, "l19_current_chain_valid", "see_gateway_result"));
   text += AC_UxBoardStateLine("L20 Tick/Spread", "not_active");
   text += "Trade Permission: FALSE\r\n";
   return text;
}

string AC_UxBoardHeaderSection(const AC_Layer0StatusPacket &status)
{
   string text = "";
   text += "AURORA CORE - OPERATOR BOARD\r\n";
   text += "==================================================\r\n";
   text += AC_UxBoardStateLine("Publication State", status.status);
   text += AC_UxBoardStateLine("Dossier Route", (AC_DOSSIER_PHYSICAL_MATCH_OK ? "CLEAN" : "MISMATCH") + " | open " + IntegerToString(AC_DOSSIER_PHYSICAL_OPEN_FILES) + "/" + IntegerToString(AC_DOSSIER_EXPECTED_OPEN_FILES) + " closed " + IntegerToString(AC_DOSSIER_PHYSICAL_CLOSED_FILES) + "/" + IntegerToString(AC_DOSSIER_EXPECTED_CLOSED_FILES) + " unknown " + IntegerToString(AC_DOSSIER_PHYSICAL_UNKNOWN_FILES) + "/" + IntegerToString(AC_DOSSIER_EXPECTED_UNKNOWN_FILES));
   text += AC_UxBoardStateLine("Inspection State", AC_UxBoardInspectionState());
   text += AC_UxBoardStateLine("Selection State", "L16/L17 inspection surfaces only | L16=" + IntegerToString(AC_L16_SELECTED_COUNT) + " L17=" + IntegerToString(AC_L17_DEEP_SELECTED_COUNT));
   text += AC_UxBoardStateLine("Trading State", "BLOCKED");
   text += AC_UxBoardStateLine("Gateway State", AC_UxBoardGatewayLine());
   text += "Trade Permission: FALSE\r\n";
   text += "Auto Trading:     FALSE\r\n";
   return text;
}

string AC_UxBoardPrimaryWarningsSection(const AC_Layer0StatusPacket &status)
{
   string text = "";
   text += "\r\nPRIMARY WARNINGS\r\n";
   text += "--------------------------------------------------\r\n";
   int idx = 1;
   if(AC_BoardGatewayState() != "ACCEPTED")
      AC_UxAppendWarning(text, idx, "Gateway not accepted: " + AC_UxBoardGatewayLine());
   if(StringFind(status.main_blocker, "l5_drift=true") >= 0 || StringFind(AC_L6_STATUS, "drift") >= 0 || StringFind(AC_L6_STATUS, "Drift") >= 0)
      AC_UxAppendWarning(text, idx, "L6 drift: current L5 pass set differs from L6 export/readback");
   if(AC_BoardStatusNeedsWarning(AC_L8_STATUS))
      AC_UxAppendWarning(text, idx, "L8 degraded/review: " + AC_L8_STATUS);
   if(AC_BoardStatusNeedsWarning(AC_L10_STATUS))
      AC_UxAppendWarning(text, idx, "L10 review items present: " + AC_L10_STATUS);
   if(AC_BoardStatusNeedsWarning(AC_L16_STATUS) || AC_L16_FALLBACK_COUNT > 0)
      AC_UxAppendWarning(text, idx, "L16 degraded/fallback-heavy: selected=" + IntegerToString(AC_L16_SELECTED_COUNT) + "/10 fallback=" + IntegerToString(AC_L16_FALLBACK_COUNT));
   if(AC_L18_SOURCE_FILES_MISSING > 0)
      AC_UxAppendWarning(text, idx, "L18 partial: found " + IntegerToString(AC_L18_SOURCE_FILES_FOUND) + "/" + IntegerToString(AC_L18_SOURCE_FILES_EXPECTED) + " missing=" + IntegerToString(AC_L18_SOURCE_FILES_MISSING));
   if(AC_L19_FRESHNESS_STALE_COUNT > 0 || AC_SurfaceStateFromStatus(AC_L19_STATUS) == "DEGRADED")
      AC_UxAppendWarning(text, idx, "L19 degraded/stale: rows=" + IntegerToString(AC_L19_VALID_GEOMETRY_ROWS) + " stale=" + IntegerToString(AC_L19_FRESHNESS_STALE_COUNT));
   AC_UxAppendWarning(text, idx, "L23 blocked: no validated setup, alert, permission, or execution system");
   if(idx == 1)
      text += "none\r\n";
   return text;
}

string AC_UxBoardOperatorActionSection()
{
   string text = "";
   text += "\r\nOPERATOR ACTION\r\n";
   text += "--------------------------------------------------\r\n";
   text += "Use for trading:      NO\r\n";
   text += "Use for inspection:   YES\r\n";
   text += "Inspect first:        L17 deep evidence queue, then L16 watch-only rows and dossiers\r\n";
   text += "Do not do:            no alert, no execution, no prop-firm safety claim\r\n";
   return text;
}

string AC_UxBoardTruthContractSection()
{
   string text = "";
   text += "\r\nBOARD TRUTH CONTRACT\r\n";
   text += "--------------------------------------------------\r\n";
   text += "Board calculates scores:     FALSE\r\n";
   text += "Board grants permission:     FALSE\r\n";
   text += "Board owns FileIO routes:    FALSE\r\n";
   text += "Board renders owner truth:   TRUE\r\n";
   text += "Selection means trade:       FALSE\r\n";
   text += "L23 permission active:       FALSE\r\n";
   return text;
}

string AC_UxBoardWhyTradingBlockedSection()
{
   string text = "";
   text += "\r\nWHY TRADING IS BLOCKED\r\n";
   text += "--------------------------------------------------\r\n";
   text += "1. L23 strategy validation is not active.\r\n";
   text += "2. No setup formula is validated.\r\n";
   text += "3. No prop-firm rule profile is granting permission.\r\n";
   text += "4. L18/L19 are evidence/display packs only.\r\n";
   text += "5. Gateway liveness/result acceptance must be fresh before worker output can be trusted as current.\r\n";
   return text;
}

string AC_UxBoardGroupedSurfaceSections(const AC_Layer0StatusPacket &status)
{
   string text = "";
   text += "\r\nFOUNDATION TRUTH\r\n";
   text += "--------------------------------------------------\r\n";
   text += AC_UxBoardRow("L0 Publication", AC_BoardHealthTag(status.status), IntegerToString(status.dossier_shells_ready) + "/" + IntegerToString(status.broker_symbols_total) + " generated | publication only");
   text += AC_UxBoardRow("L1 Account", AC_L1_READY ? "ACCEPTED" : "PENDING", AC_L1_READY ? "available" : "account truth pending");
   text += AC_UxBoardRow("L2 Market State", AC_BoardHealthTag(AC_L2_SCAN_STATUS), "open " + IntegerToString(AC_L2_OPEN_COUNT) + " / closed " + IntegerToString(AC_L2_CLOSED_COUNT));
   text += AC_UxBoardRow("L3 Specs / Value", AC_BoardHealthTag(AC_L3_SCAN_STATUS), AC_L3_SCAN_STATUS + " | specs/value/margin");
   text += AC_UxBoardRow("L4 Quote / Spread", AC_BoardHealthTag(AC_L4_SCAN_STATUS), "fresh " + IntegerToString(AC_L4_FRESH_QUOTES) + " / stale " + IntegerToString(AC_L4_STALE_QUOTES) + " | " + AC_L4_SCAN_STATUS);
   text += AC_UxBoardRow("L5 Basic Gate", AC_BoardHealthTag(AC_L5_STATUS), "pass " + IntegerToString(AC_L5_GATE_PASS) + " / blocked " + IntegerToString(AC_L5_GATE_BLOCKED) + " | eligibility only");

   text += "\r\nSURFACE RANKING - INSPECTION ONLY\r\n";
   text += "--------------------------------------------------\r\n";
   text += AC_UxBoardRow("L6 Cost/Friction", AC_BoardHealthTag(AC_L6_STATUS), AC_L6_STATUS + " | accepted=" + (AC_L6_RANKED_ACCEPTED ? "true" : "false"));
   text += AC_UxBoardRow("L7 Session", AC_BoardHealthTag(AC_L7_STATUS), AC_L7_STATUS + " | rows=" + IntegerToString(AC_L7_RANKED_ROWS_RENDERED));
   text += AC_UxBoardRow("L8 Movement", AC_BoardHealthTag(AC_L8_STATUS), AC_L8_STATUS + " | rows=" + IntegerToString(AC_L8_RANKED_ROWS_RENDERED) + " ohlc_min=" + IntegerToString(AC_L8_OHLC_MIN_READY_RENDERED));
   text += AC_UxBoardRow("L9 Structure", AC_BoardHealthTag(AC_L9_STATUS), AC_L9_STATUS + " | quality=" + AC_L9_GEOMETRY_QUALITY_STATE);

   text += "\r\nSELECTION PIPELINE - NOT PERMISSION\r\n";
   text += "--------------------------------------------------\r\n";
   text += AC_UxBoardRow("L10 Taxonomy", AC_BoardHealthTag(AC_L10_STATUS), AC_L10_STATUS + " | symbols=" + IntegerToString(AC_L10_SYMBOL_COUNT));
   text += AC_UxBoardRow("L11 Group Rank", AC_BoardHealthTag(AC_L11_STATUS), AC_L11_STATUS + " | ranked=" + IntegerToString(AC_L11_RANKED_SYMBOL_COUNT));
   text += AC_UxBoardRow("L12 Group Heat", AC_BoardHealthTag(AC_L12_STATUS), AC_L12_STATUS + " | groups=" + IntegerToString(AC_L12_GROUP_COUNT));
   text += AC_UxBoardRow("L13 Group Selection", AC_BoardHealthTag(AC_L13_STATUS), AC_L13_STATUS + " | selected groups=" + IntegerToString(AC_L13_SELECTED_GROUP_COUNT));
   text += AC_UxBoardRow("L14 Candidate Pool", AC_BoardHealthTag(AC_L14_STATUS), AC_L14_STATUS + " | pool=" + IntegerToString(AC_L14_CANDIDATE_POOL_SIZE));
   text += AC_UxBoardRow("L15 Diversity", AC_BoardHealthTag(AC_L15_STATUS), AC_L15_STATUS + " | scored=" + IntegerToString(AC_L15_CANDIDATE_SCORED_COUNT));
   text += AC_UxBoardRow("L16 Global Top 10", AC_BoardHealthTag(AC_L16_STATUS), AC_L16_STATUS + " | selected=" + IntegerToString(AC_L16_SELECTED_COUNT) + "/10 fallback=" + IntegerToString(AC_L16_FALLBACK_COUNT));
   text += AC_UxBoardRow("L17 Deep Evidence", AC_BoardHealthTag(AC_L17_STATUS), AC_L17_STATUS + " | deep=" + IntegerToString(AC_L17_DEEP_SELECTED_COUNT) + "/5 fallback=" + IntegerToString(AC_L17_FALLBACK_SELECTED_COUNT));

   text += "\r\nEVIDENCE / PERMISSION\r\n";
   text += "--------------------------------------------------\r\n";
   text += AC_UxBoardRow("L18 Raw OHLC", AC_SurfaceStateFromStatus(AC_L18_STATUS), "found " + IntegerToString(AC_L18_SOURCE_FILES_FOUND) + "/" + IntegerToString(AC_L18_SOURCE_FILES_EXPECTED) + " missing=" + IntegerToString(AC_L18_SOURCE_FILES_MISSING) + " | " + AC_L18_FRESHNESS_STATUS);
   text += AC_UxBoardRow("L19 Wick Geometry", AC_SurfaceStateFromStatus(AC_L19_STATUS), "rows=" + IntegerToString(AC_L19_VALID_GEOMETRY_ROWS) + " stale=" + IntegerToString(AC_L19_FRESHNESS_STALE_COUNT) + " | " + AC_L19_FRESHNESS_STATUS);
   text += AC_UxBoardRow("L20 Rolling Tick", "NOT_ACTIVE", "design hold");
   text += AC_UxBoardRow("L21 Indicators", "NOT_ACTIVE", "design hold");
   text += AC_UxBoardRow("L22 Liquidity/DOM", "NOT_ACTIVE", "design hold");
   text += AC_UxBoardRow("L23 Permission", "BLOCKED", "strategy not validated | trade_permission=false entry_signal=false execution=false");

   text += "\r\nSUPPORT SERVICES\r\n";
   text += "--------------------------------------------------\r\n";
   text += AC_UxBoardRow("OHLC Shared Store", AC_BoardHealthTag(AC_SHARED_OHLC_STATUS), "tf=8 pending=" + IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_PENDING) + " topup=" + IntegerToString(AC_SHARED_OHLC_TOPUP_ATTEMPTED) + " | raw storage only");
   text += AC_UxBoardRow("Gateway / Worker", AC_BoardGatewayState(), AC_UxBoardGatewayLine());
   text += AC_UxBoardRow("Selection Desk", AC_BoardHealthTag(AC_SelectionDeskScaffoldStatus()), "L16=" + IntegerToString(AC_L16_SELECTED_COUNT) + " L17=" + IntegerToString(AC_L17_DEEP_SELECTED_COUNT) + " dup_l18=" + IntegerToString(AC_L18_SELECTED_DUPLICATE_ROUTE_COPIES));
   return text;
}

string AC_UxBoardBlockerSplitSection(const AC_Layer0StatusPacket &status)
{
   string text = "";
   text += "\r\nBLOCKER SPLIT\r\n";
   text += "--------------------------------------------------\r\n";
   text += "Publication Blocker: " + AC_UxBoardPublicationBlocker(status) + "\r\n";
   text += "Inspection Warning:  " + AC_UxBoardInspectionWarning(status) + "\r\n";
   text += "Trading Blocker:     L23 strategy validation not active\r\n";
   return text;
}

string AC_BuildTraderBoardText(const AC_Runtime0Snapshot &snapshot,
                               const AC_Layer0StatusPacket &status)
{
   AC_BoardRefreshSurfacePackets();
   AC_DossierPhysicalRefreshProof();

   string l1 = AC_Layer1BoardSection();
   string l2 = AC_Layer2BoardSection();
   string l3 = AC_Layer3BoardSection();
   string l4 = AC_Layer4BoardSection();
   string l5 = AC_Layer5BoardSection();
   string l6 = AC_Layer6BoardSection();
   string l7 = AC_Layer7BoardSection();
   string l8 = AC_Layer8BoardSection();
   string l9 = AC_Layer9BoardSection();
   string l10 = AC_Layer10BoardSection();
   string l11 = AC_Layer11BoardSection();
   string l12 = AC_Layer12BoardSection();
   string l13 = AC_Layer13BoardSection();
   string l14 = AC_Layer14BoardSection();
   string l15 = AC_Layer15BoardSection();
   string l16 = AC_Layer16BoardSection();
   string l17 = AC_Layer17BoardSection();
   string ohlc = AC_SharedOhlcRenderBoardSection();

   string text = "";
   text += AC_UxBoardHeaderSection(status);
   text += AC_UxBoardChainStateSection();
   text += AC_UxBoardPrimaryWarningsSection(status);
   text += AC_UxBoardOperatorActionSection();
   text += AC_UxBoardTruthContractSection();
   text += AC_UxBoardWhyTradingBlockedSection();
   text += AC_BoardUniverseSnapshotSection(status);
   text += AC_UxBoardGroupedSurfaceSections(status);
   text += AC_UxBoardBlockerSplitSection(status);
   text += AC_BoardSurfaceScoringSnapshotSection();
   text += AC_BoardSurfaceCoherenceProofSection();
   text += AC_BoardSelectionPipelineSnapshotSection();
   text += AC_BoardDegradationSnapshotSection(status);
   text += AC_BoardDossierCoverageSection(status);
   text += AC_BoardTraderSelectionOverviewSection();
   text += "\r\nFULL TECHNICAL DETAIL - BELOW THIS LINE\r\n";
   text += "==================================================\r\n";
   text += l1;
   text += l2;
   text += l3;
   text += l4;
   text += l5;
   text += l6;
   text += l7;
   text += l8;
   text += l9;
   text += l10;
   text += l11;
   text += l12;
   text += l13;
   text += l14;
   text += l15;
   text += l16;
   text += l17;
   text += ohlc;
   text += AC_BoardTradingReadinessSection();
   text += AC_BoardTrustBlockerSection(status);
   text += AC_BoardActionSection();
   text += AC_BoardTraderChatExportGuideSection();
   return text;
}

string AC_Layer0StatusRow(const AC_Layer0StatusPacket &status)
{
   return AC_Layer0StatusRow_Base(status);
}

string AC_Layer0WorkbenchText(const AC_Layer0StatusPacket &status)
{
   return AC_Layer0WorkbenchText_Base(status);
}

#endif
