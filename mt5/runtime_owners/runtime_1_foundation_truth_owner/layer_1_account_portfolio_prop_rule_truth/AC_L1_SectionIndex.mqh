#ifndef AC_L1_SECTION_INDEX_MQH
#define AC_L1_SECTION_INDEX_MQH

string AC_L1SectionIndexLine(const string section_id,
                             const string section_name,
                             const string purpose)
{
   return AC_L1PadRight(section_id, 33)
      + AC_L1PadRight(section_name, 36)
      + purpose
      + "\r\n";
}

string AC_L1AccountStatusSectionIndex()
{
   string text = AC_L1MapHeader("LAYER 1 ACCOUNT STATUS SECTION INDEX");
   text += "section_id:             L1_ACCOUNT_STATUS_SECTION_INDEX\r\n";
   text += "Purpose:                stable map order for GPT overseer parsing and human navigation\r\n";
   text += AC_L1PadRight("Section ID", 33) + AC_L1PadRight("Section Name", 36) + "Purpose\r\n";
   text += AC_L1SectionIndexLine("L1_OVERSEER_BRIEF", "Layer 1 - Overseer Brief", "top account state and action bias");
   text += AC_L1SectionIndexLine("L1_TOP_PORTFOLIO_LEAKS", "Top Portfolio Leaks", "fast leak triage");
   text += AC_L1SectionIndexLine("L1_NEXT_DECISION_HINTS", "Layer 1 - Next Decision Hints", "review priorities and blocked promotions");
   text += AC_L1SectionIndexLine("L1_MAP_POLICY", "Layer 1 Map Policy", "scope, risk basis, permission boundary");
   text += AC_L1SectionIndexLine("L1_ACCOUNT_SUMMARY", "Account Summary", "account balance/equity snapshot");
   text += AC_L1SectionIndexLine("L1_RESULTS", "Results", "selected-history MT5-style performance");
   text += AC_L1SectionIndexLine("L1_LIVE_OPEN_PENDING", "Live Open/Pending Maps", "near-live position and order exposure");
   text += AC_L1SectionIndexLine("L1_PORTFOLIO_SHAPE", "Portfolio Maps", "portfolio concentration, asset, direction, time, hold, currency");
   text += AC_L1SectionIndexLine("L1_CLUSTER_RECOVERY", "Cluster / Recovery Maps", "cluster damage, streaks, recovery quality");
   text += AC_L1SectionIndexLine("L1_RISK_R_STACK", "Money Risk / R / Efficiency", "risk geometry, R-multiple, risk efficiency");
   text += AC_L1SectionIndexLine("L1_COST_TAG_QUALITY", "Cost / Tag / Data Quality", "cost drag, setup tag readiness, data quality");
   text += AC_L1SectionIndexLine("L1_RAW_HISTORY", "Raw History Detail", "closed/canceled row evidence");
   text += "Trade Permission:       FALSE\r\n";
   return text;
}

#endif