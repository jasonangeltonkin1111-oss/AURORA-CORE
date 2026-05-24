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
#include "AC_Layer6RankedSidecarRenderer.mqh"
#include "AC_RenderIndexOptimizedDossierSections.mqh"

string AC_DossierL16PipelineCorrectionSection(const string symbol)
{
   AC_L16RefreshSummary();
   string l16_row = AC_L16CsvLineForSymbol(symbol);
   string text = "";
   text += "\r\nL16 PIPELINE CORRECTION / CURRENT SELECTION TRUTH\r\n";
   text += "----------------------------------------\r\n";
   text += "Reason: top Dossier shell may still contain older L15-era summary wording; this bridge prints current L16 truth before full selection details.\r\n";
   text += "L16 Status: " + AC_L16_STATUS + "\r\n";
   text += "L16 Selected Count: " + IntegerToString(AC_L16_SELECTED_COUNT) + " / 10\r\n";
   text += "L16 Unfilled Slots: " + IntegerToString(AC_L16_UNFILLED_SLOTS_COUNT) + "\r\n";
   text += "L16 Correlation Rejects: " + IntegerToString(AC_L16_CORRELATION_REJECT_COUNT) + "\r\n";
   text += "L16 Group Cap Rejects: " + IntegerToString(AC_L16_GROUP_CAP_REJECT_COUNT) + "\r\n";
   text += "L16 Top Symbol: " + AC_L16_TOP_SYMBOL + "\r\n";
   if(l16_row == "")
   {
      text += "This Symbol L16 Member: FALSE\r\n";
      text += "This Symbol Meaning: not in current Global Top 10 inspection basket; keep as evidence only.\r\n";
   }
   else
   {
      text += "This Symbol L16 Member: TRUE\r\n";
      text += "This Symbol Global Rank: #" + AC_L16CsvField(l16_row, 0) + " / " + IntegerToString(AC_L16_SELECTED_COUNT) + "\r\n";
      text += "This Symbol L16 Primary Score: " + AC_L16CsvField(l16_row, 7) + "\r\n";
      text += "This Symbol Selection Reason: " + AC_L16CsvField(l16_row, 22) + "\r\n";
   }
   text += "Selection Meaning: L16 is an inspection basket only; no setup alert, no trade permission, no execution.\r\n";
   text += "Next Required: inspect L16 members first; non-members remain supporting evidence unless later source truth changes.\r\n";
   return text;
}

string AC_Layer11L12L13L14L15L16AndSharedOhlcRenderDossierSection(const string symbol)
{
   string text = "";
   text += AC_DossierL16PipelineCorrectionSection(symbol);
   text += AC_Layer11DossierSection(symbol);
   text += AC_Layer12DossierSection(symbol);
   text += AC_Layer13DossierSection(symbol);
   text += AC_Layer14DossierSection(symbol);
   text += AC_Layer15DossierSection(symbol);
   text += AC_Layer16DossierSection(symbol);
   text += AC_SharedOhlcRenderDossierSection(symbol);
   return text;
}

// Surgical render-composition bridge:
// AC_Layer0DossierPublication.mqh already appends AC_SharedOhlcRenderDossierSection(symbol)
// after L10. The macro below routes that single existing append through the L16 correction + L11+L12+L13+L14+L15+L16+OHLC wrapper
// so the Dossier receives current L16 inspection-basket truth without a broad rewrite of the active Dossier owner.
// L16 is render-only here. The worker owns Global Top 10 calculation support.
#define AC_SharedOhlcRenderDossierSection AC_Layer11L12L13L14L15L16AndSharedOhlcRenderDossierSection
#include "AC_Layer0DossierPublication.mqh"
#undef AC_SharedOhlcRenderDossierSection

// Wrap the existing board renderer so a compact trader-chat export guide can be appended without rewriting the Board owner.
#define AC_BuildTraderBoardText AC_BuildTraderBoardText_Base
#include "AC_MarketBoardRenderer.mqh"
#undef AC_BuildTraderBoardText
#include "AC_TraderChatExportGuideRenderer.mqh"

#endif