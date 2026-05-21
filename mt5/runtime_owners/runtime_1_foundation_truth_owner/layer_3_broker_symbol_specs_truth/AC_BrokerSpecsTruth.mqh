#ifndef AC_BROKER_SPECS_TRUTH_MQH
#define AC_BROKER_SPECS_TRUTH_MQH

// Runtime 1 / Foundation Truth Owner dispatcher for Layer 3.
// Owns broker specification, classification readiness, fundamental lookup hints,
// and value/margin formula primitives only.
// It never owns live quote freshness, ranking, selection, strategy, execution, or permission.

#include "AC_L3_Types.mqh"
#include "AC_L3_Format.mqh"
#include "AC_L3_State.mqh"
#include "AC_L3_BucketFallback.mqh"
#include "AC_L3_FundamentalLinks.mqh"
#include "AC_L3_ValueFormula.mqh"
#include "AC_L3_Scan.mqh"
#include "AC_L3_Render.mqh"

#endif