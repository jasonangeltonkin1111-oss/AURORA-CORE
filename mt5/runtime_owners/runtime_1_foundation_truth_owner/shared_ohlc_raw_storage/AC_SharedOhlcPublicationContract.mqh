#ifndef AC_SHARED_OHLC_PUBLICATION_CONTRACT_MQH
#define AC_SHARED_OHLC_PUBLICATION_CONTRACT_MQH

// Runtime 1 Shared OHLC Raw Storage Owner - publication contract.
// Stable include path consumed by Runtime 7 renderers and truncated compatibility shims.
// Delegates to the current active Runtime 1 bridge used by AC_PublicationRenderers.mqh.
// No duplicate owner: AC_SharedOhlcActiveBridge.mqh owns raw CopyRates/MqlRates
// storage, priority-window/status surfaces, bounded service activation, and
// Board/Dossier/Workbench render sections for the current active path.
// V6/V7 bridge files are retained as review-only historical/prototype variants
// unless a future migration explicitly promotes one with compile/runtime proof.

#include "AC_SharedOhlcActiveBridge.mqh"
#include "AC_SharedOhlcLegacyAliases.mqh"

#endif