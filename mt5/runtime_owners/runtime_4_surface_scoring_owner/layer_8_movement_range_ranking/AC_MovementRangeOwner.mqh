#ifndef AC_MOVEMENT_RANGE_OWNER_MQH
#define AC_MOVEMENT_RANGE_OWNER_MQH

// Runtime 4 / Surface Scoring Owner - Layer 8 contract stub.
// Layer 8 is Movement / Range Ranking.
// It ranks bounded movement and range quality for Layer 5 pass symbols only.
// It must not decide market open/closed truth; Layer 2 owns broker session availability.
// It must not hard-block symbols; Layer 5 remains the only broad all-symbol hard gate.
// It must not become selected deep OHLC evidence; Layer 18 owns selected raw OHLC bar packs.
// It must not claim trend direction, breakout confirmation, strategy edge, selection, trade permission, or execution.
// Runtime 3 may export bounded L8 history primitives for Gateway support.
// Future active L8 Gateway scoring must live in external_worker calculation-support source.
// Future active L8 Board/Dossier/Workbench rendering must live in Runtime 7 renderers.
// This file defines no globals or render functions to avoid duplicate L8 owners.

#endif