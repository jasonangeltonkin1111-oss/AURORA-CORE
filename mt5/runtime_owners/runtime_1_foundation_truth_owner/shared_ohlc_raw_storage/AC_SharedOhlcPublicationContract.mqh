#ifndef AC_SHARED_OHLC_PUBLICATION_CONTRACT_MQH
#define AC_SHARED_OHLC_PUBLICATION_CONTRACT_MQH

// Runtime 1 Shared OHLC Raw Storage Owner - publication contract.
// Stable include path consumed by Runtime 7 renderers.
// Delegates to the current active Runtime 1 bridge.
// No duplicate owner: AC_SharedOhlcActiveBridgeV7.mqh owns the single visible source file per symbol/timeframe.

#include "AC_SharedOhlcActiveBridgeV7.mqh"
#include "AC_SharedOhlcLegacyAliases.mqh"

#endif
