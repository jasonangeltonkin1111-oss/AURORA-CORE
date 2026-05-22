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
   text += AC_L1MagicCommentTagMap(12);
   return text;
}

#endif