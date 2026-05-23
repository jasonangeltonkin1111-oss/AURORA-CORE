#ifndef AC_SHARED_OHLC_RAW_STORAGE_MQH
#define AC_SHARED_OHLC_RAW_STORAGE_MQH

// Dispatcher include for Runtime 1 support service - Shared OHLC Raw Storage Owner.
// Include this after routes, FileIO, Layer 5 state, and publication services are available.
// This owner stores raw MT5 history only. It does not calculate features or own future-layer logic.

#include "AC_SharedOhlcContracts.mqh"
#include "AC_SharedOhlcState.mqh"
#include "AC_SharedOhlcCodec.mqh"
#include "AC_SharedOhlcOwner.mqh"
#include "AC_SharedOhlcQueues.mqh"
#include "AC_SharedOhlcManifest.mqh"

#endif
