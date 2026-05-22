#ifndef AC_BASIC_SYSTEM_GATE_MQH
#define AC_BASIC_SYSTEM_GATE_MQH

// Runtime 1 / Foundation Truth Owner dispatcher for Layer 5.
// Layer 5 owns only the Basic System Gate: the first all-symbol hard eligibility gate.
// It consumes L2 market state, L3 broker/spec/value/classification packets, and L4 quote/spread packets.
// It must not calculate friction/ranking, session scoring, movement, structure, selection, strategy, permission, execution, FileIO, routes, or Gateway transport.

#include "AC_L5_State.mqh"
#include "AC_L5_Policy.mqh"
#include "AC_L5_Scan.mqh"
#include "AC_L5_Render.mqh"

#endif
