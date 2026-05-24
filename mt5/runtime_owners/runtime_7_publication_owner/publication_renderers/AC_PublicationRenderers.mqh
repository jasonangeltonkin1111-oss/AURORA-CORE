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
   text += "Current Selection Surface: latest accepted L16/L17 source truth available to the renderer.\r\n";
   text += "L16 Status: " + AC_L16_STATUS + "\r\n";
   text += "L16 Selected Count: " + IntegerToString(AC_L16_SELECTED_COUNT) + " / 10\r\n";
   text += "L16 Unfilled Slots: " + IntegerToString(AC_L16_UNFILLED_SLOTS_COUNT) + "\r\n";
   text += "L16 Correlation Rejects: " + IntegerToString(AC_L16_CORRELATION_REJECT_COUNT) + "\r\n";
   text += "L16 Group Cap Rejects: " + IntegerToString(AC_L16_GROUP_CAP_REJECT_COUNT) + "\r\n";
   text += "L16 Top Symbol: " + AC_L16_TOP_SYMBOL + "\r\n";
   text += "L17 Status: " + AC_L17_STATUS + "\r\n";
   text += "L17 Deep Selected: " + IntegerToString(AC_L17_DEEP_SELECTED_COUNT) + " / 5\r\n";
   text += "L17 Clean Selected: " + IntegerToString(AC_L17_CLEAN_SELECTED_COUNT) + "\r\n";
   text += "L17 Fallback Selected: " + IntegerToString(AC_L17_FALLBACK_SELECTED_COUNT) + "\r\n";
   text += "L17 Top Deep Symbol: " + AC_L17_TOP_SYMBOL + "\r\n";
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
   if(l17_row == "")
   {
      text += "This Symbol L17 Deep Selected: FALSE\r\n";
      text += "This Symbol L17 Meaning: visible evidence only unless later L17 source truth selects it.\r\n";
   }
   else
   {
      text += "This Symbol L17 Deep Selected: TRUE\r\n";
      text += "This Symbol L17 Rank: #" + AC_L17CsvField(l17_row, 0) + " / " + IntegerToString(AC_L17_DEEP_SELECTED_COUNT) + "\r\n";
      text += "This Symbol L17 Depth Assignment: " + AC_L17CsvField(l17_row, 24) + "\r\n";
      text += "This Symbol L17 Budget Class: " + AC_L17CsvField(l17_row, 25) + "\r\n";
      text += "This Symbol L17 Selection Reason: " + AC_L17CsvField(l17_row, 30) + "\r\n";
   }
   text += "Selection Meaning: current selection surfaces are inspection and evidence-budget surfaces only; no setup alert, no trade permission, no execution.\r\n";
   text += "Current Next Required: inspect currently selected evidence-budget symbols first; non-selected rows remain visible/watch-only unless later source truth changes.\r\n";
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
   StringReplace(text, "Next step: Layer 16 Global Top 10 builder after L15 correlation/diversity output is accepted.\r\n", "Next step: inspect currently selected evidence-budget symbols first; non-selected rows remain visible/watch-only unless later source truth changes.\r\n");
   StringReplace(text, "Layer 11-15 are inspection/selection-scoring surfaces only; no Global Top 10, alert, or trade permission exists here.\r\n", "Layer 11+ selection/evidence surfaces are inspection and evidence-budget surfaces only; no alert, trade permission, or execution exists here.\r\n");

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

// Wrap the existing board renderer so a compact trader-chat export guide can be appended without rewriting the Board owner.
#define AC_BuildTraderBoardText AC_BuildTraderBoardText_Base
#include "AC_MarketBoardRenderer.mqh"
#undef AC_BuildTraderBoardText
#include "AC_TraderChatExportGuideRenderer.mqh"

#endif