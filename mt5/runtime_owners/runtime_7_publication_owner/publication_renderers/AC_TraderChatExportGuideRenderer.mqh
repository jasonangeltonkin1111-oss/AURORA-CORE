#ifndef AC_TRADER_CHAT_EXPORT_GUIDE_RENDERER_MQH
#define AC_TRADER_CHAT_EXPORT_GUIDE_RENDERER_MQH

// Compact Board guide for trader-chat export discipline.
// This is renderer text only. It does not create trade permission, setup permission, packet import, packet matching, or execution authority.
// L17 is rendered natively inside AC_MarketBoardRenderer.mqh; this wrapper appends render-only trader overview and export guide sections.
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

bool AC_TCSIsSelectedRankingGroup(const string ranking_group)
{
   string csv = AC_L13ReadSmallTextFile(AC_L13SelectedCsvPath(), 1000000);
   if(csv == "") return false;
   string lines[];
   ushort separator = StringGetCharacter("\n", 0);
   int count = StringSplit(csv, separator, lines);
   for(int i = 1; i < count; i++)
   {
      string line = lines[i];
      StringReplace(line, "\r", "");
      if(AC_TCSCsvField(line, 1, "") == ranking_group) return true;
   }
   return false;
}

string AC_TCSTop10RankText(const string symbol)
{
   string row = AC_L16CsvLineForSymbol(symbol);
   if(row == "") return "No";
   return "#" + AC_TCSCsvField(row, 0, "NA");
}

string AC_TCSCompactSymbolRow(const string rank_text,
                              const string symbol,
                              const string ranking_group,
                              const string final_score,
                              const string strength_score,
                              const string corr_score,
                              const string top10_text)
{
   string l6_row = AC_TCSL6CsvLineForSymbol(symbol);
   string l11_row = AC_L11RankedCsvLineForSymbol(symbol);
   string bps = (l6_row == "" ? "NA" : AC_TCSCsvField(l6_row, 9, "NA"));
   string move = (l11_row == "" ? "NA" : AC_TCSCsvField(l11_row, 37, "NA"));
   string loc = (l11_row == "" ? "NA" : AC_TCSCsvField(l11_row, 40, "NA"));

   return rank_text + " " + symbol
      + " | group=" + ranking_group
      + " | final=" + final_score
      + " | strength=" + strength_score
      + " | bps=" + bps
      + " | spike=NA"
      + " | move=" + move
      + " | loc=" + loc
      + " | corr=" + corr_score
      + " | top10=" + top10_text
      + " | atr=NA | ind=NA | liq=NA | setup=NA\r\n";
}

string AC_BoardGlobalTop10TraderOverviewSection(const int max_rows = 10)
{
   AC_L16RefreshSummary();
   string text = "";
   text += "\r\nGLOBAL TOP 10 - TRADER OVERVIEW\r\n";
   text += "--------------------------------------------------\r\n";
   text += "Purpose: compact inspection order for trader chat; scores are source-owner values, not board calculations.\r\n";
   text += "Status: " + AC_L16_STATUS + " | selected=" + IntegerToString(AC_L16_SELECTED_COUNT) + "/10 | permission=false\r\n";
   text += "Legend: final=inspection score | strength=candidate/source score | bps=spread cost bps | spike=spread spike score | move=movement score | loc=location score | corr=max correlation | NA=owner not active/exposed\r\n";

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
      string final_score = AC_TCSCsvField(line, 7, "NA");
      string strength_score = AC_TCSCsvField(line, 8, "NA");
      string corr_score = AC_TCSCsvField(line, 13, "NA");
      text += AC_TCSCompactSymbolRow(rank_text, symbol, ranking_group, final_score, strength_score, corr_score, rank_text);
      printed++;
   }
   if(printed == 0) text += "Rows: NA - no usable L16 rows found.\r\n";
   text += "Meaning: inspection basket only; no entry signal, no setup permission, no execution.\r\n";
   return text;
}

string AC_BoardSelectedGroupsTop5TraderOverviewSection(const int max_groups = 7, const int max_symbols_per_group = 5)
{
   AC_L11RefreshSummary();
   AC_L13RefreshSummary();
   string text = "";
   text += "\r\nTOP 5 PER SELECTED DYNAMIC GROUP\r\n";
   text += "--------------------------------------------------\r\n";
   text += "Source: L13 selected ranking_groups + Symbol Ranking Inside Ranking Group Top 5.\r\n";
   text += "Status: groups=" + IntegerToString(AC_L13_SELECTED_GROUP_COUNT) + " | permission=false\r\n";

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
         string symbol = AC_TCSCsvField(row, 7, "NA");
         string group_symbol_rank = AC_TCSCsvField(row, 5, "NA");
         string group_score_row = AC_TCSCsvField(row, 13, "NA");
         string top10_text = AC_TCSTop10RankText(symbol);
         string l16_row = AC_L16CsvLineForSymbol(symbol);
         string corr_score = (l16_row == "" ? "NA" : AC_TCSCsvField(l16_row, 13, "NA"));
         text += AC_TCSCompactSymbolRow("#" + group_symbol_rank, symbol, ranking_group, group_score_row, group_score_row, corr_score, top10_text);
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
   text += "\r\nTRADER SELECTION OVERVIEW\r\n";
   text += "==================================================\r\n";
   text += "Purpose: fast symbol quality cockpit for trader chat. Render-only; no score calculation, no new owner.\r\n";
   text += "Future placeholders: ATR=NA, indicator=NA, liquidity/risk=NA, setup=NA until their owners exist.\r\n";
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

string AC_BuildTraderBoardText(const AC_Runtime0Snapshot &snapshot,
                               const AC_Layer0StatusPacket &status)
{
   return AC_BuildTraderBoardText_Base(snapshot, status) + AC_BoardTraderSelectionOverviewSection() + AC_BoardTraderChatExportGuideSection();
}

#endif
