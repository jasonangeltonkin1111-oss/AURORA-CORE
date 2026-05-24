#ifndef AC_L1_COST_TAG_MAPS_MQH
#define AC_L1_COST_TAG_MAPS_MQH

string AC_L1TagKey(const long magic,
                   string comment)
{
   StringTrimLeft(comment);
   StringTrimRight(comment);
   if(comment == "") comment = "no_comment";
   if(StringLen(comment) > 24) comment = StringSubstr(comment, 0, 24);
   return "magic=" + IntegerToString((int)magic) + ";comment=" + comment;
}

bool AC_L1CommentHasStructuredToken(string comment,
                                    const string token)
{
   StringToLower(comment);
   string t = token;
   StringToLower(t);
   return (StringFind(comment, t) >= 0);
}

string AC_L1SetupTagQuality(const int rows,
                            const int structured_rows,
                            const int magic_rows,
                            const int comment_rows)
{
   if(rows <= 0) return "no selected rows";
   double structured_pct = ((double)structured_rows * 100.0) / rows;
   double magic_pct = ((double)magic_rows * 100.0) / rows;
   double comment_pct = ((double)comment_rows * 100.0) / rows;
   if(structured_pct >= 80.0 && magic_pct >= 80.0) return "strong setup tagging";
   if(structured_pct >= 50.0 || (magic_pct >= 50.0 && comment_pct >= 50.0)) return "partial setup tagging";
   if(comment_pct > 0.0 || magic_pct > 0.0) return "weak setup tagging";
   return "tag source mostly missing";
}

string AC_L1SetupTagReadinessMap()
{
   int rows = ArraySize(AC_L1_CLOSED);
   int rows_with_magic = 0;
   int rows_magic_zero = 0;
   int rows_with_comment = 0;
   int rows_missing_comment = 0;
   int rows_with_structured_setup = 0;
   int rows_with_strategy_id = 0;
   int rows_with_entry_reason = 0;
   int rows_with_exit_reason = 0;
   int rows_with_risk_tag = 0;
   int distinct_magic = 0;
   int distinct_comment = 0;
   string magic_seen = "|";
   string comment_seen = "|";

   for(int i = 0; i < rows; i++)
   {
      long magic = AC_L1_CLOSED[i].magic;
      string magic_key = IntegerToString((int)magic);
      string comment = AC_L1_CLOSED[i].comment;
      StringTrimLeft(comment);
      StringTrimRight(comment);

      if(magic != 0) rows_with_magic++; else rows_magic_zero++;
      if(StringFind(magic_seen, "|" + magic_key + "|") < 0)
      {
         magic_seen += magic_key + "|";
         distinct_magic++;
      }

      if(comment != "") rows_with_comment++; else rows_missing_comment++;
      string comment_key = comment;
      if(comment_key == "") comment_key = "no_comment";
      if(StringLen(comment_key) > 40) comment_key = StringSubstr(comment_key, 0, 40);
      if(StringFind(comment_seen, "|" + comment_key + "|") < 0)
      {
         comment_seen += comment_key + "|";
         distinct_comment++;
      }

      bool has_strategy = AC_L1CommentHasStructuredToken(comment, "strategy=") || AC_L1CommentHasStructuredToken(comment, "strategy:") || AC_L1CommentHasStructuredToken(comment, "sid=") || AC_L1CommentHasStructuredToken(comment, "setup=");
      bool has_entry = AC_L1CommentHasStructuredToken(comment, "entry=") || AC_L1CommentHasStructuredToken(comment, "entry:") || AC_L1CommentHasStructuredToken(comment, "reason=");
      bool has_exit = AC_L1CommentHasStructuredToken(comment, "exit=") || AC_L1CommentHasStructuredToken(comment, "exit:") || AC_L1CommentHasStructuredToken(comment, "close=");
      bool has_risk = AC_L1CommentHasStructuredToken(comment, "risk=") || AC_L1CommentHasStructuredToken(comment, "risk:") || AC_L1CommentHasStructuredToken(comment, "r=");
      if(has_strategy) rows_with_strategy_id++;
      if(has_entry) rows_with_entry_reason++;
      if(has_exit) rows_with_exit_reason++;
      if(has_risk) rows_with_risk_tag++;
      if(has_strategy || has_entry || has_exit || has_risk) rows_with_structured_setup++;
   }

   double magic_pct = (rows > 0 ? ((double)rows_with_magic * 100.0) / rows : 0.0);
   double comment_pct = (rows > 0 ? ((double)rows_with_comment * 100.0) / rows : 0.0);
   double structured_pct = (rows > 0 ? ((double)rows_with_structured_setup * 100.0) / rows : 0.0);
   string quality = AC_L1SetupTagQuality(rows, rows_with_structured_setup, rows_with_magic, rows_with_comment);

   string text = AC_L1MapHeader("SETUP TAG READINESS MAP");
   text += "Scope:                  selected closed history tag quality only\r\n";
   text += "Purpose:                prove whether future setup performance maps can trust magic/comment identity\r\n";
   text += "Selected Closed Rows:   " + IntegerToString(rows) + "\r\n";
   text += "Rows With Magic:        " + IntegerToString(rows_with_magic) + " / " + IntegerToString(rows) + " (" + AC_L1PercentText(magic_pct) + ")\r\n";
   text += "Rows Magic Zero:        " + IntegerToString(rows_magic_zero) + "\r\n";
   text += "Rows With Comment:      " + IntegerToString(rows_with_comment) + " / " + IntegerToString(rows) + " (" + AC_L1PercentText(comment_pct) + ")\r\n";
   text += "Rows Missing Comment:   " + IntegerToString(rows_missing_comment) + "\r\n";
   text += "Structured Setup Rows:  " + IntegerToString(rows_with_structured_setup) + " / " + IntegerToString(rows) + " (" + AC_L1PercentText(structured_pct) + ")\r\n";
   text += "Strategy ID Rows:       " + IntegerToString(rows_with_strategy_id) + "\r\n";
   text += "Entry Reason Rows:      " + IntegerToString(rows_with_entry_reason) + "\r\n";
   text += "Exit Reason Rows:       " + IntegerToString(rows_with_exit_reason) + "\r\n";
   text += "Risk Tag Rows:          " + IntegerToString(rows_with_risk_tag) + "\r\n";
   text += "Distinct Magic Values:  " + IntegerToString(distinct_magic) + "\r\n";
   text += "Distinct Comment Tags:  " + IntegerToString(distinct_comment) + "\r\n";
   text += "Tag Quality:            " + quality + "\r\n";
   text += "Setup Map Status:       performance-by-setup blocked until structured tags exist\r\n";
   text += "Trade Permission:       FALSE\r\n";
   return text;
}

string AC_L1CostDragMap()
{
   int rows = ArraySize(AC_L1_CLOSED);
   double gross_trade_pl = 0.0;
   double commission_sum = 0.0;
   double swap_sum = 0.0;
   double fee_sum = 0.0;
   double cost_sum = 0.0;
   double net_sum = 0.0;

   for(int i = 0; i < rows; i++)
   {
      gross_trade_pl += AC_L1_CLOSED[i].profit;
      commission_sum += AC_L1_CLOSED[i].commission;
      swap_sum += AC_L1_CLOSED[i].swap;
      fee_sum += AC_L1_CLOSED[i].fee;
      net_sum += AC_L1_CLOSED[i].net_result;
   }
   cost_sum = commission_sum + swap_sum + fee_sum;

   double cost_abs = MathAbs(cost_sum);
   double gross_profit_abs = MathAbs(AC_L1_GROSS_PROFIT);
   double net_abs = MathAbs(net_sum);
   double cost_vs_gross_profit_pct = (gross_profit_abs > 0.0 ? (cost_abs / gross_profit_abs) * 100.0 : 0.0);
   double cost_vs_net_abs_pct = (net_abs > 0.0 ? (cost_abs / net_abs) * 100.0 : 0.0);
   double avg_cost = (rows > 0 ? cost_sum / rows : 0.0);

   string text = AC_L1MapHeader("COST DRAG MAP - SELECTED HISTORY");
   text += "Rows:                   " + IntegerToString(rows) + "\r\n";
   text += "Gross Trade P/L:        " + AC_L1MoneyText(gross_trade_pl) + "\r\n";
   text += "Commission:             " + AC_L1MoneyText(commission_sum) + "\r\n";
   text += "Swap:                   " + AC_L1MoneyText(swap_sum) + "\r\n";
   text += "Fee:                    " + AC_L1MoneyText(fee_sum) + "\r\n";
   text += "Total Cost Drag:        " + AC_L1MoneyText(cost_sum) + "\r\n";
   text += "Net Result:             " + AC_L1MoneyText(net_sum) + "\r\n";
   text += "Avg Cost / Row:         " + AC_L1MoneyText(avg_cost) + "\r\n";
   text += "Cost / Gross Profit:    " + AC_L1PercentText(cost_vs_gross_profit_pct) + "\r\n";
   text += "Cost / Abs Net Result:  " + AC_L1PercentText(cost_vs_net_abs_pct) + "\r\n";
   text += "Scope:                  selected closed history only\r\n";
   return text;
}

string AC_L1CostDragBySymbolMap(const int limit)
{
   string text = AC_L1MapHeader("COST DRAG BY SYMBOL MAP");
   text += AC_L1PadRight("Symbol", 14)
      + AC_L1PadLeft("Rows", 6)
      + AC_L1PadLeft("Cost", 11)
      + AC_L1PadLeft("Net", 11)
      + AC_L1PadLeft("AvgCost", 11)
      + "\r\n";

   string used = "|";
   int printed = 0;
   for(int rank = 0; rank < limit; rank++)
   {
      string best_symbol = "";
      double best_cost_abs = -1.0;
      int rows = 0;
      double cost = 0.0;
      double net = 0.0;

      for(int i = 0; i < ArraySize(AC_L1_CLOSED); i++)
      {
         string symbol = AC_L1_CLOSED[i].symbol;
         if(symbol == "") continue;
         if(StringFind(used, "|" + symbol + "|") >= 0) continue;

         int tmp_rows = 0;
         double tmp_cost = 0.0;
         double tmp_net = 0.0;
         for(int j = 0; j < ArraySize(AC_L1_CLOSED); j++)
         {
            if(AC_L1_CLOSED[j].symbol != symbol) continue;
            tmp_rows++;
            tmp_cost += AC_L1_CLOSED[j].commission + AC_L1_CLOSED[j].swap + AC_L1_CLOSED[j].fee;
            tmp_net += AC_L1_CLOSED[j].net_result;
         }

         double tmp_cost_abs = MathAbs(tmp_cost);
         if(tmp_cost_abs > best_cost_abs)
         {
            best_cost_abs = tmp_cost_abs;
            best_symbol = symbol;
            rows = tmp_rows;
            cost = tmp_cost;
            net = tmp_net;
         }
      }

      if(best_symbol == "") break;
      used += best_symbol + "|";
      double avg_cost = (rows > 0 ? cost / rows : 0.0);
      text += AC_L1PadRight(best_symbol, 14)
         + AC_L1PadLeft(IntegerToString(rows), 6)
         + AC_L1PadLeft(AC_L1MoneyText(cost), 11)
         + AC_L1PadLeft(AC_L1MoneyText(net), 11)
         + AC_L1PadLeft(AC_L1MoneyText(avg_cost), 11)
         + "\r\n";
      printed++;
   }

   if(printed <= 0) text += "none\r\n";
   text += "Sort:                   largest absolute cost drag first\r\n";
   return text;
}

string AC_L1MagicCommentTagMap(const int limit)
{
   string text = AC_L1MapHeader("MAGIC / COMMENT TAG MAP");
   text += "Scope:                  selected closed history only\r\n";
   text += "Tag Basis:              magic number + truncated comment; no inferred setup identity\r\n";
   text += AC_L1PadRight("Tag", 34)
      + AC_L1PadLeft("Rows", 6)
      + AC_L1PadLeft("Net", 11)
      + AC_L1PadLeft("Avg", 10)
      + AC_L1PadLeft("Win%", 9)
      + "\r\n";

   string used = "|";
   int printed = 0;
   for(int rank = 0; rank < limit; rank++)
   {
      string best_tag = "";
      double best_abs_net = -1.0;
      int rows = 0;
      int wins = 0;
      double net = 0.0;

      for(int i = 0; i < ArraySize(AC_L1_CLOSED); i++)
      {
         string tag = AC_L1TagKey(AC_L1_CLOSED[i].magic, AC_L1_CLOSED[i].comment);
         if(StringFind(used, "|" + tag + "|") >= 0) continue;

         int tmp_rows = 0;
         int tmp_wins = 0;
         double tmp_net = 0.0;
         for(int j = 0; j < ArraySize(AC_L1_CLOSED); j++)
         {
            if(AC_L1TagKey(AC_L1_CLOSED[j].magic, AC_L1_CLOSED[j].comment) != tag) continue;
            tmp_rows++;
            if(AC_L1_CLOSED[j].net_result > 0.0) tmp_wins++;
            tmp_net += AC_L1_CLOSED[j].net_result;
         }

         double tmp_abs = MathAbs(tmp_net);
         if(tmp_abs > best_abs_net)
         {
            best_abs_net = tmp_abs;
            best_tag = tag;
            rows = tmp_rows;
            wins = tmp_wins;
            net = tmp_net;
         }
      }

      if(best_tag == "") break;
      used += best_tag + "|";
      double avg = (rows > 0 ? net / rows : 0.0);
      double win_pct = (rows > 0 ? ((double)wins * 100.0) / rows : 0.0);
      text += AC_L1PadRight(best_tag, 34)
         + AC_L1PadLeft(IntegerToString(rows), 6)
         + AC_L1PadLeft(AC_L1MoneyText(net), 11)
         + AC_L1PadLeft(AC_L1MoneyText(avg), 10)
         + AC_L1PadLeft(AC_L1PercentText(win_pct), 9)
         + "\r\n";
      printed++;
   }

   if(printed <= 0) text += "none\r\n";
   text += "Sort:                   largest absolute net impact first\r\n";
   return text;
}

string AC_L1CostAndTagMapsFull()
{
   string text = "";
   text += AC_L1CostDragMap();
   text += AC_L1CostDragBySymbolMap(10);
   text += AC_L1SetupTagReadinessMap();
   text += AC_L1MagicCommentTagMap(12);
   return text;
}

#endif