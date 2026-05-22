#ifndef AC_SESSION_RELEVANCE_OWNER_MQH
#define AC_SESSION_RELEVANCE_OWNER_MQH

// Runtime 4 / Surface Scoring Owner - Layer 7 contract stub.
// Layer 7 is Session Relevance Ranking.
// It ranks session-context relevance for Layer 5 pass symbols only.
// It must not decide market open/closed truth; Layer 2 owns broker session availability.
// It must not hard-block symbols; Layer 5 remains the only broad all-symbol hard gate.
// It must not calculate OHLC session ranges, prior session highs/lows, VWAP, liquidity maps,
// strategy entries, selection, trade permission, or execution.
// Future active L7 MT5 primitive export must live in Runtime 3 snapshot/Gateway support.
// Future active L7 Gateway ranking must live in external_worker calculation-support source.
// Future active L7 Board/Dossier/Workbench rendering must live in Runtime 7 renderers.
// This file defines no globals or render functions to avoid duplicate L7 owners.

#endif