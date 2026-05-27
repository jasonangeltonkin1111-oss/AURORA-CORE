#ifndef AC_TRADER_CHAT_EXPORT_GUIDE_RENDERER_MQH
#define AC_TRADER_CHAT_EXPORT_GUIDE_RENDERER_MQH

// Compact Board guide for trader-chat export discipline.
// This is renderer text only. It does not create trade permission, setup permission, packet import, packet matching, or execution authority.
// Trader overview reads existing layer-owner outputs only. It must not calculate new scores, create routes, write files, permit, alert, or execute.
// L23 export is allowed as labelled manual-review truth context; L23 permission remains blocked unless a later validation/permission owner upgrades it with proof.

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

string AC_TCSQueueText(const string symbol)
{
   string row = AC_L17CsvLineForSymbol(symbol);
   if(row == "") return "0";
   return AC_TCSCsvField(row, 0, "0");
}

string AC_TCSTop10RankText(const string symbol)
{
   string row = AC_L16CsvLineForSymbol(symbol);
   if(row == "") return "0";
   return AC_TCSCsvField(row, 0, "0");
}

string AC_TCSBoardReadinessState()
{
   AC_L16RefreshSummary();
   AC_L17RefreshSummary();
   if(AC_L16_SELECTED_COUNT > 0 && AC_L17_DEEP_SELECTED_COUNT > 0)
      return "DEEP_QUEUE_NUMERIC_CONTEXT_AVAILABLE";
   if(AC_L16_SELECTED_COUNT > 0)
      return "TOP10_NUMERIC_CONTEXT_ONLY";
   return "NO_CURRENT_NUMERIC_EXPORT";
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

string AC_TCSCostShort(string value)
{
   value = AC_TCSValueOrNA(value);
   if(value == "complete_cost_model") return "OK";
   if(value == "warning_micro_spread_cost_model_mismatch") return "MICRO_WARN";
   if(value == "warning_cost_model_mismatch") return "WARN";
   if(value == "usable_fallback_cost_model_primary_unavailable") return "FALLBACK";
   if(value == "degraded_cost_model_mismatch") return "DEGRADED";
   return value;
}

string AC_TCSShortGroup(string group)
{
   group = AC_TCSValueOrNA(group);
   if(group == "Currency / Forex Cross Pairs") return "FX Cross";
   if(group == "Currency / Forex Major Pairs") return "FX Major";
   if(group == "Currency / Forex Exotic Pairs") return "FX Exotic";
   if(group == "Commodities / Precious Metals") return "Metals";
   if(group == "Index / European Indices") return "EU Index";
   if(group == "Index / US Indices") return "US Index";
   if(group == "Crypto Currency / Large Cap Crypto") return "Crypto Large";
   return group;
}

string AC_TCSDeepNumericText()
{
   return "L17=" + IntegerToString(AC_L17_DEEP_SELECTED_COUNT) + "/5"
      + " | L18=" + IntegerToString(AC_L18_SOURCE_FILES_FOUND) + "/" + IntegerToString(AC_L18_SOURCE_FILES_EXPECTED)
      + " miss=" + IntegerToString(AC_L18_SOURCE_FILES_MISSING)
      + " | L19 rows=" + IntegerToString(AC_L19_VALID_GEOMETRY_ROWS)
      + " stale=" + IntegerToString(AC_L19_FRESHNESS_STALE_COUNT);
}

string AC_TCSSymbolNumericCard(const string rank_text,
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
   string cost_state = (l6_row == "" ? "NA" : AC_TCSCostShort(AC_TCSCsvField(l6_row, 9, "NA")));
   string move = (l11_row == "" ? "NA" : AC_TCSCsvField(l11_row, 37, "NA"));
   string loc = (l11_row == "" ? "NA" : AC_TCSCsvField(l11_row, 40, "NA"));
   string queue_rank = AC_TCSQueueText(symbol);
   string top10_rank = top10_text;
   if(top10_rank == "No") top10_rank = "0";

   string text = "";
   text += rank_text + " " + symbol + " - " + AC_TCSShortGroup(ranking_group) + "\r\n";
   text += "  Scores: " + score_label + "=" + score_value
      + " | " + source_score_label + "=" + source_score_value
      + " | cost=" + cost_state
      + " | move=" + move
      + " | loc=" + loc + "\r\n";
   text += "  Trade data: corr=" + corr_score
      + " | top10=" + top10_rank
      + " | queue=" + queue_rank
      + " | " + AC_TCSDeepNumericText() + "\r\n";
   return text;
}

string AC_BoardGlobalTop10TraderOverviewSection(const int max_rows = 10)
{
   AC_L16RefreshSummary();
   AC_L17RefreshSummary();
   string text = "";
   text += "\r\nGLOBAL TOP 10 - TRADE DATA SNAPSHOT\r\n";
   text += "--------------------------------------------------\r\n";
   text += "Status: " + AC_L16_STATUS
      + " | selected=" + IntegerToString(AC_L16_SELECTED_COUNT) + "/10"
      + " | fallback=" + IntegerToString(AC_L16_FALLBACK_COUNT)
      + " | deep=" + IntegerToString(AC_L17_DEEP_SELECTED_COUNT) + "/5"
      + " | readiness=" + AC_TCSBoardReadinessState() + "\r\n";
   text += "Numbers: basket/source scores, cost state, move, location, correlation, Top10 rank, queue rank, L18/L19 deep-data counters.\r\n";

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
      text += AC_TCSSymbolNumericCard(rank_text, symbol, ranking_group, "basket", basket_score, "source", source_score, corr_score, rank_text);
      printed++;
   }
   if(printed == 0) text += "Rows: NA - no usable L16 rows found.\r\n";
   return text;
}

string AC_BoardSelectedGroupsTop5TraderOverviewSection(const int max_groups = 7, const int max_symbols_per_group = 3)
{
   AC_L11RefreshSummary();
   AC_L13RefreshSummary();
   AC_L17RefreshSummary();
   string text = "";
   text += "\r\nTOP SYMBOLS PER SELECTED GROUP - TRADE DATA SNAPSHOT\r\n";
   text += "--------------------------------------------------\r\n";
   text += "Status: selected_groups=" + IntegerToString(AC_L13_SELECTED_GROUP_COUNT)
      + " | symbols_per_group_shown=" + IntegerToString(max_symbols_per_group)
      + " | " + AC_TCSDeepNumericText() + "\r\n";
   text += "Numbers: group rank/score, L6 cost state, L8 move score, L9 location score, correlation if in Top10, queue rank.\r\n";

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
      text += "\r\n[" + AC_TCSShortGroup(ranking_group) + "] full_group=" + ranking_group
         + " | selected_rank=#" + group_rank
         + " | group_score=" + group_score + "\r\n";

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
         text += AC_TCSSymbolNumericCard("#" + group_symbol_rank, symbol, ranking_group, "group_score", group_score_row, "group_rank", "#" + group_symbol_rank, corr_score, top10_text);
         symbols_printed++;
      }
      if(symbols_printed == 0) text += "Rows: NA - no Top symbols found for this selected group.\r\n";
      groups_printed++;
   }

   if(groups_printed == 0) text += "Rows: NA - no selected dynamic groups found.\r\n";
   return text;
}

string AC_BoardTraderSelectionOverviewSection()
{
   string text = "";
   text += "\r\nSELECTION DESK - TRADER DATA VIEW\r\n";
   text += "==================================================\r\n";
   text += "Purpose: readable symbol trade-data context from existing owner outputs. Render-only; no score calculation, no new owner.\r\n";
   text += AC_BoardGlobalTop10TraderOverviewSection(10);
   text += AC_BoardSelectedGroupsTop5TraderOverviewSection(7, 3);
   return text;
}

string AC_L23ExportPermissionLockSection()
{
   string text = "";
   text += "\r\nL23 EXPORT / PERMISSION LOCK\r\n";
   text += "--------------------------------------------------\r\n";
   text += "manual_review_packet_available = true only when copied packet truth is labelled with source, missing, degraded, and stale evidence.\r\n";
   text += "trader_chat_export_available = true only for truth-context export; it is not an entry instruction.\r\n";
   text += "class_1_system_alert_allowed: system-status only; class_2_setup_alert_allowed=false; directional_alert_allowed=false.\r\n";
   text += "entry_signal=false; trade_allowed=false; auto_trade_allowed=false; live_allowed=false; prop_firm_ready=false; edge_validated=false.\r\n";
   text += "Permission Block Reason: validation_missing; prop_profile_not_runtime_verified; selected evidence may be partial/degraded/stale.\r\n";
   return text;
}

string AC_L23ExportPacketSchemaSection()
{
   string text = "";
   text += "\r\nL23 TRADER-CHAT EXPORT PACKET SCHEMA\r\n";
   text += "--------------------------------------------------\r\n";
   text += "Required Machine Block Name: AURORA_L23_TRADER_REVIEW_EXPORT_PACKET.\r\n";
   text += "Required Fields: schema_version, packet_created_utc, symbol, source_cycle_id, source_files_or_sections, upstream_layers_present, evidence_completeness_pct, missing_evidence_list, degraded_evidence_list, stale_evidence_list.\r\n";
   text += "Context Fields: setup_research_candidate, structure_context_summary, liquidity_context_summary, risk_geometry_context_summary, review_warnings, validation_required_reason, permission_block_reason.\r\n";
   text += "Permission Fields Required: manual_review_packet_available, trader_chat_export_available, class_1_system_alert_allowed, class_2_setup_alert_allowed, directional_alert_allowed, entry_signal, trade_allowed, auto_trade_allowed, live_allowed, prop_firm_ready, edge_validated.\r\n";
   text += "Forbidden Values Before Validation: true values for entry, trade, auto, live, prop, or edge permission fields.\r\n";
   text += "Forbidden Wording: directional confirmation, probability marketing, guarantee language, best-now phrasing, prop-firm safety claims, or institutional-flow confirmation claims.\r\n";
   return text;
}

string AC_BoardTraderChatExportGuideSection()
{
   string text = "";
   text += "\r\nTRADER CHAT EXPORT GUIDE\r\n";
   text += "--------------------------------------------------\r\n";
   text += "Purpose: copy Board + chosen Dossier(s) to trader chat as labelled truth context. Partial/degraded export is allowed when missing/degraded/stale evidence is visible.\r\n";
   text += "Trader Chat Style: free-form human review is allowed, but the machine block below must stay strict and must not imply Aurora permission.\r\n";
   text += "Required Blocks: PROFESSOR SIAM TRADE REVIEW; TRADE_SETUP_REVIEW_CARD; AURORA_L23_TRADER_REVIEW_EXPORT_PACKET; AURORA CAN CLAIM; AURORA CANNOT CLAIM.\r\n";
   text += "Review Fields: review_status, discretionary_review_action, symbol, human_review_side_optional, declared_timeframe, setup_name, setup_proof_level, planned_entry_or_zone_if_human_defined, planned_sl_or_invalidation_if_human_defined, planned_tp_or_target_logic_if_human_defined, planned_risk_if_human_defined, main_reason, main_risk, reason_id, packet_required, packet_status.\r\n";
   text += "Reason ID Format: RID_YYYYMMDD_HHMMSS_SYMBOL_SIDE. If a human later places a discretionary trade outside Aurora, use the reason_id only as journal linkage.\r\n";
   text += "Safety Locks: trade_allowed=false; auto_trade_allowed=false; entry_signal=false; prop_firm_ready=false; requires_manual_confirmation=true; no approved trade, no guaranteed outcome, no proven edge unless validation evidence exists.\r\n";
   text += "Packet Meaning: setup packet is journal/evidence-review evidence only. MT5 history must confirm any actual human execution. Aurora import/matching is not active unless later runtime proof says so.\r\n";
   text += AC_L23ExportPermissionLockSection();
   text += AC_L23ExportPacketSchemaSection();
   return text;
}

string AC_BuildTraderBoardText(const AC_Runtime0Snapshot &snapshot,
                               const AC_Layer0StatusPacket &status)
{
   string text = AC_BuildTraderBoardText_Base(snapshot, status);
   text += AC_BoardTraderChatExportGuideSection();
   return text;
}

#endif
