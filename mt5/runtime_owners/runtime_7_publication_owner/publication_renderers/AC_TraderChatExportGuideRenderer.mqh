#ifndef AC_TRADER_CHAT_EXPORT_GUIDE_RENDERER_MQH
#define AC_TRADER_CHAT_EXPORT_GUIDE_RENDERER_MQH

// Compact Board guide for trader-chat export discipline.
// This is renderer text only. It does not create trade permission, setup permission, packet import, packet matching, or execution authority.
// Also performs a surgical text injection so L17 appears inside the existing Board cockpit sections without rewriting AC_MarketBoardRenderer.mqh.

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

void AC_BoardReplaceOnce(string &text, const string needle, const string replacement)
{
   if(StringFind(text, needle) >= 0)
      StringReplace(text, needle, replacement);
}

void AC_BoardInsertBeforeOnce(string &text, const string marker, const string insertion)
{
   int pos = StringFind(text, marker);
   if(pos < 0) return;
   text = StringSubstr(text, 0, pos) + insertion + StringSubstr(text, pos);
}

string AC_BoardL17CompactLine()
{
   return "L17 Deep Evidence:        " + IntegerToString(AC_L17_DEEP_SELECTED_COUNT) + " / 5 | clean=" + IntegerToString(AC_L17_CLEAN_SELECTED_COUNT)
      + " | fallback=" + IntegerToString(AC_L17_FALLBACK_SELECTED_COUNT) + " | top=" + AC_L17_TOP_SYMBOL + "\r\n";
}

string AC_BoardL17PipelineLine()
{
   return "L17 Deep Evidence Split: " + AC_L17_STATUS + " | deep=" + IntegerToString(AC_L17_DEEP_SELECTED_COUNT) + "/5 | clean=" + IntegerToString(AC_L17_CLEAN_SELECTED_COUNT)
      + " | fallback=" + IntegerToString(AC_L17_FALLBACK_SELECTED_COUNT) + " | watch=" + IntegerToString(AC_L17_WATCH_ONLY_COUNT) + "\r\n";
}

string AC_BoardL17NativeIntegratedText(string base)
{
   AC_L17RefreshSummary();

   string marker = "L16 Top Symbol:            " + AC_L16_TOP_SYMBOL + "\r\n";
   AC_BoardReplaceOnce(base, marker, marker + AC_BoardL17CompactLine());

   marker = "L16  Global Top 10 Basket        " + AC_BoardHealthTag(AC_L16_STATUS) + "   " + AC_L16_STATUS + "\r\n";
   AC_BoardReplaceOnce(base, marker, marker + "L17  Deep Evidence Split         " + AC_BoardHealthTag(AC_L17_STATUS) + "   " + AC_L17_STATUS + "\r\n");

   marker = "L16 Global Top 10:        " + AC_L16_STATUS + " | selected=" + IntegerToString(AC_L16_SELECTED_COUNT) + "/10 | unfilled=" + IntegerToString(AC_L16_UNFILLED_SLOTS_COUNT) + " | corr_rejects=" + IntegerToString(AC_L16_CORRELATION_REJECT_COUNT) + "\r\n";
   AC_BoardReplaceOnce(base, marker, marker + AC_BoardL17PipelineLine());

   marker = "L16 Unfilled Slots:        " + IntegerToString(AC_L16_UNFILLED_SLOTS_COUNT) + "\r\n";
   AC_BoardReplaceOnce(base, marker, marker + "L17 Fallback Selected:     " + IntegerToString(AC_L17_FALLBACK_SELECTED_COUNT) + "\r\nL17 Watch Only:             " + IntegerToString(AC_L17_WATCH_ONLY_COUNT) + "\r\n");

   marker = "Global Top 10:      " + AC_L16_STATUS + "\r\n";
   AC_BoardReplaceOnce(base, marker, marker + "Deep Evidence Split: " + AC_L17_STATUS + "\r\n");

   marker = "Layer 6-9 are ranking/scoring only; Layer 10 is taxonomy/ranking_group map only; Layer 11 is intra-group inspection priority only; Layer 12 is group heat/quality only; Layer 13 selects groups for attention only; Layer 14 builds a raw candidate pool only; later selection layers may narrow inspection order only; Layer 5 remains the only hard gate.\r\n";
   AC_BoardReplaceOnce(base, marker, "Layer 6-9 are ranking/scoring only; Layer 10 is taxonomy/ranking_group map only; Layer 11 is intra-group inspection priority only; Layer 12 is group heat/quality only; Layer 13 selects groups for attention only; Layer 14 builds a raw candidate pool only; Layer 15 scores correlation/diversity only; Layer 16 builds the visible inspection basket only; Layer 17 splits future deep-evidence budget only; Layer 5 remains the only hard gate.\r\n");

   marker = "Latest accepted selection surface may guide inspection order; no alerts, execution, or trade permission exists.\r\n";
   AC_BoardReplaceOnce(base, marker, "Latest accepted L16/L17 selection surfaces may guide inspection order and evidence budget only; no alerts, execution, or trade permission exists.\r\n");

   string l17_detail = AC_Layer17BoardSection();
   AC_BoardInsertBeforeOnce(base, "\r\nSHARED OHLC RAW STORE\r\n", l17_detail);
   return base;
}

string AC_BuildTraderBoardText(const AC_Runtime0Snapshot &snapshot,
                               const AC_Layer0StatusPacket &status)
{
   string base = AC_BuildTraderBoardText_Base(snapshot, status);
   base = AC_BoardL17NativeIntegratedText(base);
   return base + AC_BoardTraderChatExportGuideSection();
}

#endif
