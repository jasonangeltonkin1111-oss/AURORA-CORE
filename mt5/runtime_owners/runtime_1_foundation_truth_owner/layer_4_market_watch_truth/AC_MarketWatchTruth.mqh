#ifndef AC_MARKET_WATCH_TRUTH_MQH
#define AC_MARKET_WATCH_TRUTH_MQH

// Runtime 1 / Foundation Truth Owner dispatcher for Layer 4.
// Owns live Market Watch quote, tick, spread, BPS, daily-change, and surface truth only.
// It never owns static broker specs, taxonomy, history, DOM, indicators, ranking, selection, strategy, execution, FileIO, or permission.

#include "AC_L4_Types.mqh"
#include "AC_L4_Format.mqh"
#include "AC_L4_State.mqh"
#include "AC_L4_Scan.mqh"
#include "AC_L4_RenderTruth.mqh"

#endif
