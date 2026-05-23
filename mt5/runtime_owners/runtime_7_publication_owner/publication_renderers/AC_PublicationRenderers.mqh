#ifndef AC_PUBLICATION_RENDERERS_MQH
#define AC_PUBLICATION_RENDERERS_MQH

// Board / Dossier Renderer Service.
// Shared OHLC raw storage is included here only so Board/Dossier can render overview/proof sections.
// Rendering does not make Board/Dossier the OHLC source owner.
#include "../publication_routes/AC_SharedOhlcRoutes.mqh"
#include "../../runtime_1_foundation_truth_owner/shared_ohlc_raw_storage/AC_SharedOhlcRawStorage.mqh"
#include "../../runtime_1_foundation_truth_owner/shared_ohlc_raw_storage/AC_SharedOhlcSurface.mqh"
#include "AC_Layer7SessionRelevanceRenderer.mqh"
#include "AC_Layer6RankedSidecarRenderer.mqh"
#include "AC_Layer0DossierPublication.mqh"
#include "AC_MarketBoardRenderer.mqh"

#endif