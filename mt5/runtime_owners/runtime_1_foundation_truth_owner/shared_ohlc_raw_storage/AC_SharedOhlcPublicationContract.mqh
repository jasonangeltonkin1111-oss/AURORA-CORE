#ifndef AC_SHARED_OHLC_PUBLICATION_CONTRACT_MQH
#define AC_SHARED_OHLC_PUBLICATION_CONTRACT_MQH

// Runtime 1 Shared OHLC Raw Storage Owner - publication contract.
// This is the stable include path consumed by Runtime 7 renderers.
// It must delegate to the active Runtime 1 bridge, not define a passive stub.
// No duplicate owner: AC_SharedOhlcActiveBridge.mqh owns raw CopyRates/MqlRates storage.

#include "AC_SharedOhlcActiveBridge.mqh"
#include "AC_SharedOhlcLegacyAliases.mqh"

#endif
