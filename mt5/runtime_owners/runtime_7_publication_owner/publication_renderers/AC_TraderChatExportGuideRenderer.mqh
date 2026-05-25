#ifndef AC_TRADER_CHAT_EXPORT_GUIDE_RENDERER_MQH
#define AC_TRADER_CHAT_EXPORT_GUIDE_RENDERER_MQH

// Compact Board guide for trader-chat export discipline.
// This is renderer text only. It does not create trade permission, setup permission, packet import, packet matching, or execution authority.
// Trader overview reads existing layer-owner outputs only. It must not calculate new scores, create routes, write files, permit, alert, or execute.

string AC_TCSValueOrNA(string value)
{
   StringTrimLeft(value);
   StringTrimRight(value);
   if(value == "" || value == "not_available" || value == "pending" || value == "nan" || value == "NaN") return "NA";
   return value;
}

string AC_TCSCsvField(string line, int index, string fallback = "NA")
{
   string cols[];
   ushort sep = StringGetCharacter(",", 0);
   int count = StringSplit(line, sep, cols);
   if(index < 0 || index >= count) return fallback;
   string value = cols[index];
   StringTrimLeft(value);
   StringTrimRight(value);
   StringReplace(value, "\"", "");
   return AC_TCSValueOrNA(value);
}

bool AC_TCSHasQueueSelection(const string symbol)
{
   return (AC_L17CsvLineForSymbol(symbol) != "");
}

bool AC_TCSHasTop10Selection(const string symbol)
{
   return (AC_L16CsvLineForSymbol(symbol) != "");
}

string AC_TCSReviewText(const string symbol)
{
   if(AC_TCSHasQueueSelection(symbol)) return "YES";
   if(AC_TCSHasTop10Selection(symbol)) return "WATCH";
   return "NO";
}

string AC_TCSBoardReadinessState()
{
   AC_L16RefreshSummary();
   AC_L17RefreshSummary();
   if(AC_L16_SELECTED_COUNT > 0 && AC_L17_DEEP_SELECTED_COUNT > 0)
      return "READY_FOR_REVIEW";
   if(AC_L16_SELECTED_COUNT > 0)
      return "WATCH_ONLY";
   return "BLOCKED";
}

string AC_TCSBoardReadinessReason()
{
   string state = AC_TCSBoardReadinessState();
   if(state == "READY_FOR_REVIEW")
      return "selection/evidence-budget queue candidates exist, but L23 strategy-risk-permission owner is not active";
   if(state == "WATCH_ONLY")
      return "visible Top 10 candidates exist, but no L17 queue selection is ready";
   return "no current selected evidence-budget queue candidates available";
}

string AC_TCSL6CsvLineForSymbol(const string symbol)
{
   string csv = AC_L6ReadSmallTextFile(AC_L6RankedCsvPath(), 1000000);
   if(csv == "") return "";
   string lines[];
   ushort separator = StringGetCharacter("\n", 0);
   int count = StringSplit(csv, separator, lines);
   for(int i = 1; i < count; i++)
   {
      string line = lines[i];
      StringReplace(line, "\r", "");
      if(AC_TCSCsvField(line, 1, "") == symbol) return line;
   }
   return "";
}

string AC_TCSTop10RankText(const string symbol)
{
   string row = AC_L16CsvLineForSymbol(symbol);
   if(row == "") return "No";
   return "#" + AC_TCSCsvField(row, 0, "NA");
}

string AC_TCSQueueText(const string symbol)
{
   string row = AC_L17CsvLineForSymbol(symbol);
   if(row == "") return "No";
   return "#" + AC_TCSCsvField(row, 0, "NA");
}

string AC_TCSCompactSymbolRow(const string rank_text,
                              const string symbol,
                              const string ranking_group,
                              const string score_label,
                              const string score_value,
                              const string source_score_label,
                              const string source_score_value,
                              const string corr_score,
                              const string top10_text)
{
   string l6_row = AC_TCSL6CsvLineForSymbol(symbol);
   string l11_row = AC_L11RankedCsvLineForSymbol(symbol);
   string bps = (l6_row == "" ? "NA" : AC_TCSCsvField(l6_row, 9, "NA"));
   string move = (l11_row == "" ? "NA" : AC_TCSCsvField(l11_row, 37, "NA"));
   string loc = (l11_row == "" ? "NA" : AC_TCSCsvField(l11_row, 40, "NA"));
   string queue_text = AC_TCSQueueText(symbol);
   string review_text = AC_TCSReviewText(symbol);

   return rank_text + " " + symbol
      + " | group=" + ranking_group
      + " | " + score_label + "=" + score_value
      + " | " + source_score_label + "=" + source_score_value
      + " | bps=" + bps
      + " | move=" + move
      + " | loc=" + loc
      + " | corr=" + corr_score
      + " | top10=" + top10_text
      + " | queue=" + queue_text
      + " | review=" + review_text
      + " | permission=NO\r\n";
}

string AC_BoardGlobalTop10TraderOverviewSection(const int max_rows = 10)
{
   AC_L16RefreshSummary();
   AC_L17RefreshSummary();
   string text = "";
   text += "\r\nGLOBAL TOP 10 - INSPECTION ORDER\r\n";
   text += "--------------------------------------------------\r\n";
   text += "Purpose: compact inspection order; scores are source-owner values, not board calculations.\r\n";
   text += "Status: " + AC_L16_STATUS + " | selected=" + IntegerToString(AC_L16_SELECTED_COUNT) + "/10 | queued=" + IntegerToString(AC_L17_DEEP_SELECTED_COUNT) + "/5 | readiness=" + AC_TCSBoardReadinessState() + "\r\n";
   text += "Legend: basket=constrained inspection score | source=upstream candidate score | bps=spread cost | move/location are surface scores | queue=L17 evidence-budget queue rank | review=manual trade-review queue, not permission.\r\n";
   text += "Inactive future owners: ATR, indicators, liquidity, setup, L23 permission.\r\n";
   text += "Rank Note: Global rank may not sort by basket score alone because L16 also applies group/correlation/fallback constraints.\r\n";

   string csv = AC_L16ReadSmallTextFile(AC_L16Top10CsvPath(), 1000000);
   if(csv == "")
   {
      text += "Rows: NA - L16 Global Top 10 CSV not readable yet.\r\n";
      return text;
   }

   string lines[];
   ushort separator = StringGetCharacter("\n", 0);
   int count = StringSplit(csv, separator, lines);
   int printed = 0;
   for(int i = 1; i < count && printed < max_rows; i++)
   {
      string line = lines[i];
      StringReplace(line, "\r", "");
      if(line == "") continue;
      string rank_text = "#" + AC_TCSCsvField(line, 0, "NA");
      string symbol = AC_TCSCsvField(line, 1, "NA");
      string ranking_group = AC_TCSCsvField(line, 3, "NA");
      string basket_score = AC_TCSCsvField(line, 7, "NA");
      string source_score = AC_TCSCsvField(line, 8, "NA");
      string corr_score = AC_TCSCsvField(line, 13, "NA");
      text += AC_TCSCompactSymbolRow(rank_text, symbol, ranking_group, "basket", basket_score, "source", source_score, corr_score, rank_text);
      printed++;
   }
   if(printed == 0) text += "Rows: NA - no usable L16 rows found.\r\n";
   text += "Meaning: inspection/review queue only; no setup permission, no execution.\r\n";
   return text;
}

string AC_BoardSelectedGroupsTop5TraderOverviewSection(const int max_groups = 7, const int max_symbols_per_group = 5)
{
   AC_L11RefreshSummary();
   AC_L13RefreshSummary();
   AC_L17RefreshSummary();
   string text = "";
   text += "\r\nTOP 5 PER SELECTED GROUP\r\n";
   text += "--------------------------------------------------\r\n";
   text += "Source: L13 selected ranking_groups + Symbol Ranking Inside Ranking Group Top 5.\r\n";
   text += "Status: groups=" + IntegerToString(AC_L13_SELECTED_GROUP_COUNT) + " | dynamic selected groups only\r\n";
   text += "Legend: group_score=L11 score | group_rank=rank inside selected group | top10=L16 visible basket membership | queue=L17 evidence-budget queue rank | review=manual trade-review queue, not permission.\r\n";

   string selected_csv = AC_L13ReadSmallTextFile(AC_L13SelectedCsvPath(), 1000000);
   string top5_csv = AC_L11ReadSmallTextFile(AC_L11Top5Path(), 1000000);
   if(selected_csv == "" || top5_csv == "")
   {
      text += "Rows: NA - selected groups or Top 5 CSV not readable yet.\r\n";
      return text;
   }

   string selected_lines[];
   string top5_lines[];
   ushort sep = StringGetCharacter("\n", 0);
   int selected_count = StringSplit(selected_csv, sep, selected_lines);
   int top5_count = StringSplit(top5_csv, sep, top5_lines);
   int groups_printed = 0;

   for(int g = 1; g < selected_count && groups_printed < max_groups; g++)
   {
      string group_line = selected_lines[g];
      StringReplace(group_line, "\r", "");
      if(group_line == "") continue;
      string ranking_group = AC_TCSCsvField(group_line, 1, "NA");
      if(ranking_group == "NA") continue;
      string group_rank = AC_TCSCsvField(group_line, 0, "NA");
      string group_score = AC_TCSCsvField(group_line, 8, "NA");
      text += "\r\n[" + ranking_group + "] selected_rank=#" + group_rank + " | group_selection_score=" + group_score + "\r\n";

      int symbols_printed = 0;
      for(int i = 1; i < top5_count && symbols_printed < max_symbols_per_group; i++)
      {
         string row = top5_lines[i];
         StringReplace(row, "\r", "");
         if(row == "") continue;
         if(AC_TCSCsvField(row, 0, "") != ranking_group) continue;
         string symbol = AC_TCSCsvField(row, 5, "NA");
         string group_symbol_rank = AC_TCSCsvField(row, 4, "NA");
         string group_score_row = AC_TCSCsvField(row, 6, "NA");
         string top10_text = AC_TCSTop10RankText(symbol);
         string l16_row = AC_L16CsvLineForSymbol(symbol);
         string corr_score = (l16_row == "" ? "NA" : AC_TCSCsvField(l16_row, 13, "NA"));
         text += AC_TCSCompactSymbolRow("#" + group_symbol_rank, symbol, ranking_group, "group_score", group_score_row, "group_rank", "#" + group_symbol_rank, corr_score, top10_text);
         symbols_printed++;
      }
      if(symbols_printed == 0) text += "Rows: NA - no Top 5 rows found for this selected group.\r\n";
      groups_printed++;
   }

   if(groups_printed == 0) text += "Rows: NA - no selected dynamic groups found.\r\n";
   text += "Meaning: selected dynamic groups only; not all groups, not trade permission.\r\n";
   return text;
}

string AC_BoardTraderSelectionOverviewSection()
{
   string text = "";
   text += "\r\nSELECTION DESK - TRADER VIEW\r\n";
   text += "==================================================\r\n";
   text += "Purpose: fast symbol quality cockpit for trader chat. Render-only; no score calculation, no new owner.\r\n";
   text += "Trade lock is declared once at the Board header; rows below are inspection/review queue only.\r\n";
   text += AC_BoardGlobalTop10TraderOverviewSection(10);
   text += AC_BoardSelectedGroupsTop5TraderOverviewSection(7, 5);
   return text;
}

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

#endif