#ifndef AC_L1_ACCOUNT_STATUS_NORMALIZE_MQH
#define AC_L1_ACCOUNT_STATUS_NORMALIZE_MQH

void AC_L1EnsureSectionId(string &text,
                          const string header,
                          const string section_id)
{
   string needle = header + "\r\n----------------------------------------\r\n";
   string replacement = header + "\r\n----------------------------------------\r\nsection_id:             " + section_id + "\r\n";
   if(StringFind(text, replacement) >= 0) return;
   StringReplace(text, needle, replacement);
}

void AC_L1NormalizeBracketSectionId(string &text,
                                    const string legacy_id,
                                    const string section_id)
{
   string legacy = "[section_id=" + legacy_id + "]\r\n";
   string standard = "section_id:             " + section_id + "\r\n";
   if(StringFind(text, standard) >= 0)
   {
      StringReplace(text, legacy, "");
      return;
   }
   StringReplace(text, legacy, standard);
}

void AC_L1NormalizeBaseAccountStatusSections()
{
   AC_L1NormalizeBracketSectionId(AC_L1_ACCOUNT_STATUS_TEXT, "account_summary", "L1_ACCOUNT_SUMMARY");
   AC_L1NormalizeBracketSectionId(AC_L1_ACCOUNT_STATUS_TEXT, "results", "L1_RESULTS");
   AC_L1NormalizeBracketSectionId(AC_L1_ACCOUNT_STATUS_TEXT, "open_positions_full", "L1_OPEN_POSITIONS_FULL");
   AC_L1NormalizeBracketSectionId(AC_L1_ACCOUNT_STATUS_TEXT, "pending_orders_full", "L1_PENDING_ORDERS_FULL");
   AC_L1NormalizeBracketSectionId(AC_L1_ACCOUNT_STATUS_TEXT, "closed_trade_history_selected_detail", "L1_CLOSED_TRADE_HISTORY_SELECTED_DETAIL");
   AC_L1NormalizeBracketSectionId(AC_L1_ACCOUNT_STATUS_TEXT, "cancel_reject_expire_selected_detail", "L1_CANCELED_ORDER_EVENTS_SELECTED_DETAIL");
   AC_L1NormalizeBracketSectionId(AC_L1_ACCOUNT_STATUS_TEXT, "symbol_performance", "L1_SYMBOL_PERFORMANCE_BASE");
   AC_L1NormalizeBracketSectionId(AC_L1_ACCOUNT_STATUS_TEXT, "daily_performance", "L1_DAILY_PERFORMANCE_BASE");
   AC_L1NormalizeBracketSectionId(AC_L1_ACCOUNT_STATUS_TEXT, "direction_summary", "L1_DIRECTION_SUMMARY_BASE");

   AC_L1EnsureSectionId(AC_L1_ACCOUNT_STATUS_TEXT, "AURORA CORE - ACCOUNT STATUS", "L1_ACCOUNT_STATUS_HEADER");
   AC_L1EnsureSectionId(AC_L1_ACCOUNT_STATUS_TEXT, "ACCOUNT SUMMARY", "L1_ACCOUNT_SUMMARY");
   AC_L1EnsureSectionId(AC_L1_ACCOUNT_STATUS_TEXT, "RESULTS", "L1_RESULTS");
   AC_L1EnsureSectionId(AC_L1_ACCOUNT_STATUS_TEXT, "Open Positions - Full", "L1_OPEN_POSITIONS_FULL");
   AC_L1EnsureSectionId(AC_L1_ACCOUNT_STATUS_TEXT, "Pending Orders - Full", "L1_PENDING_ORDERS_FULL");
   AC_L1EnsureSectionId(AC_L1_ACCOUNT_STATUS_TEXT, "Closed Trade History - Selected Detail", "L1_CLOSED_TRADE_HISTORY_SELECTED_DETAIL");
   AC_L1EnsureSectionId(AC_L1_ACCOUNT_STATUS_TEXT, "Canceled / Rejected / Expired Orders - Selected Detail", "L1_CANCELED_ORDER_EVENTS_SELECTED_DETAIL");
   AC_L1EnsureSectionId(AC_L1_ACCOUNT_STATUS_TEXT, "Symbol Performance", "L1_SYMBOL_PERFORMANCE_BASE");
   AC_L1EnsureSectionId(AC_L1_ACCOUNT_STATUS_TEXT, "Daily Performance", "L1_DAILY_PERFORMANCE_BASE");
   AC_L1EnsureSectionId(AC_L1_ACCOUNT_STATUS_TEXT, "Direction Summary", "L1_DIRECTION_SUMMARY_BASE");
}

#endif