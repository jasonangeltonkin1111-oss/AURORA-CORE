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
#include "AC_Layer6RankedSidecarRenderer.mqh"
#include "AC_RenderIndexOptimizedDossierSections.mqh"

string AC_Layer11L12L13L14L15AndSharedOhlcRenderDossierSection(const string symbol)
{
   string text = "";
   text += AC_Layer11DossierSection(symbol);
   text += AC_Layer12DossierSection(symbol);
   text += AC_Layer13DossierSection(symbol);
   text += AC_Layer14DossierSection(symbol);
   text += AC_Layer15DossierSection(symbol);
   text += AC_SharedOhlcRenderDossierSection(symbol);
   return text;
}

// Surgical render-composition bridge:
// AC_Layer0DossierPublication.mqh already appends AC_SharedOhlcRenderDossierSection(symbol)
// after L10. The macro below routes that single existing append through the L11+L12+L13+L14+L15+OHLC wrapper
// so the Dossier receives L11/L12/L13/L14/L15 without a broad rewrite of the active Dossier owner.
// L15 is now safe to inject here because AC_Layer0DossierPublication.mqh tracks L15 in the Dossier source key
// and cached no-rewrite contract.
#define AC_SharedOhlcRenderDossierSection AC_Layer11L12L13L14L15AndSharedOhlcRenderDossierSection
#include "AC_Layer0DossierPublication.mqh"
#undef AC_SharedOhlcRenderDossierSection

#include "AC_MarketBoardRenderer.mqh"

#endif