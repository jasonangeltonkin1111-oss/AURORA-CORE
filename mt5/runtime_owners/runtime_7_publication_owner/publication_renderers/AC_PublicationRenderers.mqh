#ifndef AC_PUBLICATION_RENDERERS_MQH
#define AC_PUBLICATION_RENDERERS_MQH

// Board / Dossier Renderer Service.
// Runtime 7 renders OHLC visibility only.
// Active raw OHLC storage belongs to Runtime 1 Shared OHLC Raw Storage Owner.
// Do not place CopyRates, raw storage scheduling, seed, append, top-up, or priority-window ownership here.

#include "../../runtime_1_foundation_truth_owner/shared_ohlc_raw_storage/AC_SharedOhlcPublicationContract.mqh"
#include "AC_Layer7SessionRelevanceRenderer.mqh"
#include "AC_Layer8MovementRangeRenderer.mqh"
#include "AC_Layer6RankedSidecarRenderer.mqh"
#include "AC_Layer0DossierPublication.mqh"
#include "AC_MarketBoardRenderer.mqh"

#endif