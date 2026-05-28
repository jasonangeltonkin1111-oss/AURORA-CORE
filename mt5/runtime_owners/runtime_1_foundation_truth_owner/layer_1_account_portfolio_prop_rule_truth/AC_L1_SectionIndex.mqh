#ifndef AC_L1_SECTION_INDEX_MQH
#define AC_L1_SECTION_INDEX_MQH

string AC_L1SectionIndexLine(const string section_id,
                             const string section_name,
                             const string purpose)
{
   return AC_L1PadRight(section_id, 38)
      + AC_L1PadRight(section_name, 40)
      + purpose
      + "\r\n";
}

string AC_L1AccountStatusSectionIndex()
{
   string text = AC_L1MapHeader("LAYER 1 ACCOUNT STATUS SECTION INDEX");
   text += "section_id:             L1_ACCOUNT_STATUS_SECTION_INDEX\r\n";
   text += "Purpose:                stable map order for GPT overseer parsing and human navigation\r\n";
   text += "Index Mode:             actual section_id registry, not broad group summary\r\n";
   text += AC_L1PadRight("Section ID", 38) + AC_L1PadRight("Section Name", 40) + "Purpose\r\n";

   text += AC_L1SectionIndexLine("L1_OVERSEER_BRIEF", "Layer 1 - Overseer Brief", "top account state and action bias");
   text += AC_L1SectionIndexLine("L1_TOP_PORTFOLIO_LEAKS", "Top Portfolio Leaks", "fast leak triage");
   text += AC_L1SectionIndexLine("L1_NEXT_DECISION_HINTS", "Layer 1 - Next Decision Hints", "review priorities and blocked promotions");
   text += AC_L1SectionIndexLine("L1_MAP_POLICY", "Layer 1 Map Policy", "scope, risk basis, permission boundary");
   text += AC_L1SectionIndexLine("L1_ACCOUNT_STATUS_SECTION_INDEX", "Layer 1 Account Status Section Index", "navigation for this report");

   text += AC_L1SectionIndexLine("L1_ACCOUNT_STATUS_HEADER", "Aurora Core - Account Status", "base report identity and build metadata");
   text += AC_L1SectionIndexLine("L1_ACCOUNT_SUMMARY", "Account Summary", "balance, equity, floating P/L, margin");
   text += AC_L1SectionIndexLine("L1_RESULTS", "Results", "selected-history account metrics");
   text += AC_L1SectionIndexLine("L1_OPEN_POSITIONS_FULL", "Open Positions - Full", "raw open position detail");
   text += AC_L1SectionIndexLine("L1_PENDING_ORDERS_FULL", "Pending Orders - Full", "raw pending order detail");
   text += AC_L1SectionIndexLine("L1_CLOSED_TRADE_HISTORY_SELECTED_DETAIL", "Closed Trade History - Selected Detail", "raw selected closed trade rows");
   text += AC_L1SectionIndexLine("L1_CANCELED_ORDER_EVENTS_SELECTED_DETAIL", "Canceled Order Events - Selected Detail", "raw cancel/reject/expire rows");
   text += AC_L1SectionIndexLine("L1_SYMBOL_PERFORMANCE_BASE", "Symbol Performance", "selected-history symbol results");
   text += AC_L1SectionIndexLine("L1_DAILY_PERFORMANCE_BASE", "Daily Performance", "selected-history close-date grouping");
   text += AC_L1SectionIndexLine("L1_DIRECTION_SUMMARY_BASE", "Direction Summary", "selected-history buy/sell result summary");

   text += AC_L1SectionIndexLine("L1_OPEN_PENDING_LIVE_EXPOSURE", "Open / Pending Live Exposure", "near-live open and pending summary");
   text += AC_L1SectionIndexLine("L1_OPEN_PENDING_RISK_AT_SL_READINESS", "Open / Pending Risk-at-SL Readiness", "live SL risk readiness");
   text += AC_L1SectionIndexLine("L1_OPEN_PENDING_SYMBOL_EXPOSURE", "Open / Pending Symbol Exposure", "live symbol exposure");
   text += AC_L1SectionIndexLine("L1_OPEN_PENDING_ASSET_EXPOSURE", "Open / Pending Asset Exposure", "live asset exposure");

   text += AC_L1SectionIndexLine("L1_SELECTED_HISTORY_NOTICE", "Selected History Notice", "history scope and 90-day plus 100-row rule");
   text += AC_L1SectionIndexLine("L1_DIAGNOSIS_PANEL", "Layer 1 Diagnosis Panel", "basic mode and primary leak summary");
   text += AC_L1SectionIndexLine("L1_FLAG_LEDGER", "Layer 1 Flag Ledger", "critical numeric warnings");
   text += AC_L1SectionIndexLine("L1_JASON_RISK_BUDGET", "Jason Risk Budget Map", "personal risk budgets stricter than firms");
   text += AC_L1SectionIndexLine("L1_ASSET_CLASS_BASIC", "Asset Class Map", "basic net/win view by asset class");
   text += AC_L1SectionIndexLine("L1_CURRENCY_TOUCH_BASIC", "Currency Touch Map", "basic forex currency exposure");
   text += AC_L1SectionIndexLine("L1_SYMBOL_PAIN_STRENGTH", "Symbol Pain / Strength Map", "worst and best symbol scan");
   text += AC_L1SectionIndexLine("L1_TIME_WINDOW_BASIC", "Time Window Map", "basic broker-server close-time view");
   text += AC_L1SectionIndexLine("L1_HOLDING_TIME_BASIC", "Holding Time Map", "basic duration bucket view");
   text += AC_L1SectionIndexLine("L1_CLUSTER_BASIC", "Cluster Map", "basic duplicate/cluster decision-unit view");
   text += AC_L1SectionIndexLine("L1_PORTFOLIO_CONCENTRATION", "Portfolio Concentration Map", "sample concentration by count");

   text += AC_L1SectionIndexLine("L1_ASSET_RISK_HEAT_V2", "Asset Risk Heat Map V2", "asset net/risk and breach heat");
   text += AC_L1SectionIndexLine("L1_DIRECTION_RISK", "Direction Risk Map", "buy/sell net/risk comparison");
   text += AC_L1SectionIndexLine("L1_TIME_WINDOW_RISK_V2", "Time Window Risk Map V2", "time-window net/risk comparison");
   text += AC_L1SectionIndexLine("L1_HOLDING_TIME_RISK_V2", "Holding Time Risk Map V2", "hold-duration net/risk comparison");
   text += AC_L1SectionIndexLine("L1_CURRENCY_RESULT_RISK", "Currency Result / Risk Map", "forex currency net/risk view");
   text += AC_L1SectionIndexLine("L1_TRADE_CLUSTER_V2", "Trade Cluster Map V2", "minute-level cluster diagnostics");
   text += AC_L1SectionIndexLine("L1_EQUITY_DRAWDOWN_RECOVERY", "Equity / Drawdown Recovery Map", "closed-history equity reconstruction");
   text += AC_L1SectionIndexLine("L1_RECOVERY_QUALITY", "Recovery Quality Map", "selected-history recovery reconstruction");
   text += AC_L1SectionIndexLine("L1_STREAK_DAMAGE", "Streak Damage Map", "worst/best rolling trade sequences");

   text += AC_L1SectionIndexLine("L1_CLOSED_MONEY_RISK_READINESS", "Closed Trade Money-Risk Readiness", "SL risk estimation readiness");
   text += AC_L1SectionIndexLine("L1_R_MULTIPLE_SELECTED_HISTORY", "R-Multiple Map", "estimated R diagnostics");
   text += AC_L1SectionIndexLine("L1_R_BY_SYMBOL", "R By Symbol Map", "symbol-level R impact");
   text += AC_L1SectionIndexLine("L1_RISK_EFFICIENCY", "Risk Efficiency Map", "return versus estimated risk");
   text += AC_L1SectionIndexLine("L1_RISK_BREACH", "Risk Breach Map", "unit/hard/extreme risk breach counts");
   text += AC_L1SectionIndexLine("L1_SYMBOL_RISK_BREACH_HEAT", "Symbol Risk Breach Heat Map", "symbol-level breach heat");
   text += AC_L1SectionIndexLine("L1_R_READINESS", "R Readiness Map", "input readiness for R diagnostics");

   text += AC_L1SectionIndexLine("L1_COST_DRAG_SELECTED_HISTORY", "Cost Drag Map", "commission/swap/fee drag");
   text += AC_L1SectionIndexLine("L1_COST_DRAG_BY_SYMBOL", "Cost Drag By Symbol Map", "symbol-level cost drag");
   text += AC_L1SectionIndexLine("L1_SETUP_TAG_READINESS", "Setup Tag Readiness Map", "magic/comment structure readiness");
   text += AC_L1SectionIndexLine("L1_MAGIC_COMMENT_TAG", "Magic / Comment Tag Map", "raw tag impact grouping");
   text += AC_L1SectionIndexLine("L1_RULE_DATA_QUALITY_LEDGER", "Rule / Data Quality Ledger", "data defects and quality warnings");

   text += "Trade Permission:       FALSE\r\n";
   return text;
}

#endif