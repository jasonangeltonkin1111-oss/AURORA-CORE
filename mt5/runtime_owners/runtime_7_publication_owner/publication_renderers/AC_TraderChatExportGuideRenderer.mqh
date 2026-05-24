#ifndef AC_TRADER_CHAT_EXPORT_GUIDE_RENDERER_MQH
#define AC_TRADER_CHAT_EXPORT_GUIDE_RENDERER_MQH

// Compact Board guide for trader-chat export discipline.
// This is renderer text only. It does not create trade permission, setup permission, packet import, packet matching, or execution authority.
// L17 is rendered natively inside AC_MarketBoardRenderer.mqh; this wrapper now appends only the trader-chat guide.

string AC_BoardTraderChatExportGuideSection()
{
   string text = "";
   text += "\r\nTRADER CHAT EXPORT GUIDE\r\n";
   text += "--------------------------------------------------\r\n";
   text += "Purpose: copy Board + chosen Dossier(s) to trader chat; if a trade idea is produced, its reply must include a machine block for packet export.\r\n";
   text += "Trader Chat Style: free-form human review is allowed, but export fields below must be present and strict.\r\n";
   text += "Required Blocks: PROFESSOR SIAM TRADE REVIEW; TRADE_SETUP_REVIEW_CARD; AURORA PACKET DECISION; AURORA CAN CLAIM; AURORA CANNOT CLAIM.\r\n";
   text += "Required Fields: review_status, trade_action, symbol, side, declared_timeframe, setup_name, setup_proof_level, planned_entry/zone, planned_sl or invalidation_price, planned_tp or target_logic, planned_risk_pct or planned_risk_money, main_reason, main_risk, reason_id, packet_required, packet_status.\r\n";
   text += "Reason ID Format: RID_YYYYMMDD_HHMMSS_SYMBOL_SIDE. Put the reason_id in the MT5 order comment when placing the trade.\r\n";
   text += "Safety Locks: trade_permission=false; prop_firm_safe=false; requires_manual_confirmation=true; no approved trade, no guaranteed outcome, no proven edge unless validation evidence exists.\r\n";
   text += "Packet Meaning: setup packet is journal evidence only. MT5 history must confirm actual execution. Aurora import/matching is not active unless later runtime proof says so.\r\n";
   return text;
}

string AC_BuildTraderBoardText(const AC_Runtime0Snapshot &snapshot,
                               const AC_Layer0StatusPacket &status)
{
   return AC_BuildTraderBoardText_Base(snapshot, status) + AC_BoardTraderChatExportGuideSection();
}

#endif
