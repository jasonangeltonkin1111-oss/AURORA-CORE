#ifndef AC_L1_OVERSEER_BRIEF_MQH
#define AC_L1_OVERSEER_BRIEF_MQH

string AC_L1BriefHealthText(const int closed_count,
                            const double profit_factor,
                            const double expected_payoff,
                            const double net_r,
                            const double net_over_risk)
{
   if(closed_count <= 0) return "No closed sample";
   if(profit_factor < 1.0 || expected_payoff < 0.0 || net_r < 0.0 || net_over_risk < 0.0) return "Defensive Review";
   return "Positive History - Not Edge Proof";
}

string AC_L1BriefActionBias(const int closed_count,
                            const double profit_factor,
                            const double expected_payoff,
                            const double net_r,
                            const double net_over_risk)
{
   if(closed_count <= 0) return "Wait for evidence";
   if(profit_factor < 1.0 || expected_payoff < 0.0 || net_r < 0.0 || net_over_risk < 0.0) return "Preserve capital / no promotion";
   return "Review only / no permission upgrade";
}

void AC_L1BriefRiskCore(double &total_risk,
                        double &net_r,
                        int &risk_rows)
{
   total_risk = 0.0;
   net_r = 0.0;
   risk_rows = 0;
   for(int i = 0; i < ArraySize(AC_L1_CLOSED); i++)
   {
      double risk = 0.0;
      if(!AC_L1EstimateClosedInitialRiskMoney(AC_L1_CLOSED[i], risk)) continue;
      total_risk += risk;
      net_r += AC_L1ClosedTradeRMultiple(AC_L1_CLOSED[i], risk);
      risk_rows++;
   }
}

string AC_L1BriefWorstAssetRisk(double &worst_net_over_risk,
                                double &worst_net,
                                double &worst_risk)
{
   double net[6];
   double risk_total[6];
   int rows[6];
   for(int i = 0; i < 6; i++)
   {
      net[i] = 0.0;
      risk_total[i] = 0.0;
      rows[i] = 0;
   }

   for(int r = 0; r < ArraySize(AC_L1_CLOSED); r++)
   {
      int asset = AC_L1AssetClassIndex(AC_L1_CLOSED[r].symbol);
      if(asset < 0 || asset > 5) asset = 5;
      double risk = 0.0;
      if(!AC_L1EstimateClosedInitialRiskMoney(AC_L1_CLOSED[r], risk)) continue;
      rows[asset]++;
      net[asset] += AC_L1_CLOSED[r].net_result;
      risk_total[asset] += risk;
   }

   string worst_asset = "none";
   worst_net_over_risk = 0.0;
   worst_net = 0.0;
   worst_risk = 0.0;
   bool first = true;
   for(int a = 0; a < 6; a++)
   {
      if(rows[a] <= 0 || risk_total[a] <= 0.0) continue;
      double nor = net[a] / risk_total[a];
      if(first || nor < worst_net_over_risk)
      {
         first = false;
         worst_net_over_risk = nor;
         worst_net = net[a];
         worst_risk = risk_total[a];
         worst_asset = AC_L1AssetClassName(a);
      }
   }
   return worst_asset;
}

string AC_L1BriefLargestMoneyAsset(double &largest_loss_net)
{
   double net[6];
   int rows[6];
   for(int i = 0; i < 6; i++)
   {
      net[i] = 0.0;
      rows[i] = 0;
   }
   for(int r = 0; r < ArraySize(AC_L1_CLOSED); r++)
   {
      int asset = AC_L1AssetClassIndex(AC_L1_CLOSED[r].symbol);
      if(asset < 0 || asset > 5) asset = 5;
      rows[asset]++;
      net[asset] += AC_L1_CLOSED[r].net_result;
   }
   string worst_asset = "none";
   largest_loss_net = 0.0;
   bool first = true;
   for(int a = 0; a < 6; a++)
   {
      if(rows[a] <= 0) continue;
      if(first || net[a] < largest_loss_net)
      {
         first = false;
         largest_loss_net = net[a];
         worst_asset = AC_L1AssetClassName(a);
      }
   }
   return worst_asset;
}

string AC_L1BriefWeakestDirection(double &weakest_net_over_risk)
{
   double net[2];
   double risk_total[2];
   int rows[2];
   for(int i = 0; i < 2; i++)
   {
      net[i] = 0.0;
      risk_total[i] = 0.0;
      rows[i] = 0;
   }
   for(int r = 0; r < ArraySize(AC_L1_CLOSED); r++)
   {
      int idx = -1;
      if(AC_L1_CLOSED[r].side == "buy") idx = 0;
      if(AC_L1_CLOSED[r].side == "sell") idx = 1;
      if(idx < 0) continue;
      double risk = 0.0;
      if(!AC_L1EstimateClosedInitialRiskMoney(AC_L1_CLOSED[r], risk)) continue;
      rows[idx]++;
      net[idx] += AC_L1_CLOSED[r].net_result;
      risk_total[idx] += risk;
   }
   weakest_net_over_risk = 0.0;
   string weakest = "none";
   bool first = true;
   for(int i = 0; i < 2; i++)
   {
      if(rows[i] <= 0 || risk_total[i] <= 0.0) continue;
      double nor = net[i] / risk_total[i];
      if(first || nor < weakest_net_over_risk)
      {
         first = false;
         weakest_net_over_risk = nor;
         weakest = (i == 0 ? "buy" : "sell");
      }
   }
   return weakest;
}

string AC_L1BriefWeakestTimeWindow(double &weakest_net_over_risk)
{
   double net[5];
   double risk_total[5];
   int rows[5];
   for(int i = 0; i < 5; i++)
   {
      net[i] = 0.0;
      risk_total[i] = 0.0;
      rows[i] = 0;
   }
   for(int r = 0; r < ArraySize(AC_L1_CLOSED); r++)
   {
      int idx = AC_L1TimeWindowIndex(AC_L1_CLOSED[r].close_time);
      if(idx < 0 || idx > 4) continue;
      double risk = 0.0;
      if(!AC_L1EstimateClosedInitialRiskMoney(AC_L1_CLOSED[r], risk)) continue;
      rows[idx]++;
      net[idx] += AC_L1_CLOSED[r].net_result;
      risk_total[idx] += risk;
   }
   weakest_net_over_risk = 0.0;
   string weakest = "none";
   bool first = true;
   for(int i = 0; i < 5; i++)
   {
      if(rows[i] <= 0 || risk_total[i] <= 0.0) continue;
      double nor = net[i] / risk_total[i];
      if(first || nor < weakest_net_over_risk)
      {
         first = false;
         weakest_net_over_risk = nor;
         weakest = AC_L1TimeWindowName(i);
      }
   }
   return weakest;
}

string AC_L1BriefWeakestHoldBucket(double &weakest_net_over_risk)
{
   double net[5];
   double risk_total[5];
   int rows[5];
   for(int i = 0; i < 5; i++)
   {
      net[i] = 0.0;
      risk_total[i] = 0.0;
      rows[i] = 0;
   }
   for(int r = 0; r < ArraySize(AC_L1_CLOSED); r++)
   {
      int idx = AC_L1HoldBucketIndex(AC_L1_CLOSED[r]);
      if(idx < 0 || idx > 4) continue;
      double risk = 0.0;
      if(!AC_L1EstimateClosedInitialRiskMoney(AC_L1_CLOSED[r], risk)) continue;
      rows[idx]++;
      net[idx] += AC_L1_CLOSED[r].net_result;
      risk_total[idx] += risk;
   }
   weakest_net_over_risk = 0.0;
   string weakest = "none";
   bool first = true;
   for(int i = 0; i < 5; i++)
   {
      if(rows[i] <= 0 || risk_total[i] <= 0.0) continue;
      double nor = net[i] / risk_total[i];
      if(first || nor < weakest_net_over_risk)
      {
         first = false;
         weakest_net_over_risk = nor;
         weakest = AC_L1HoldBucketName(i);
      }
   }
   return weakest;
}

string AC_L1MapPolicySection()
{
   string text = AC_L1MapHeader("LAYER 1 MAP POLICY");
   text += "section_id:             L1_MAP_POLICY\r\n";
   text += "All Maps:               selected-history diagnostics only\r\n";
   text += "Risk Basis:             estimated OrderCalcProfit entry-to-SL when available\r\n";
   text += "Permission:             no Layer 1 map grants entry, setup, selection, or execution permission\r\n";
   text += "Trade Permission:       FALSE\r\n";
   return text;
}

string AC_L1TopPortfolioLeaksSection(const string worst_asset_risk,
                                     const double worst_asset_nor,
                                     const string money_asset,
                                     const double money_asset_net,
                                     const string weak_direction,
                                     const double weak_direction_nor,
                                     const string weak_time,
                                     const double weak_time_nor,
                                     const string weak_hold,
                                     const double weak_hold_nor)
{
   string text = AC_L1MapHeader("TOP PORTFOLIO LEAKS");
   text += "section_id:             L1_TOP_PORTFOLIO_LEAKS\r\n";
   text += AC_L1PadRight("Rank", 6) + AC_L1PadRight("Leak Type", 17) + AC_L1PadRight("Name", 18) + AC_L1PadRight("Metric", 15) + AC_L1PadLeft("Value", 12) + "\r\n";
   text += AC_L1PadRight("1", 6) + AC_L1PadRight("Symbol", 17) + AC_L1PadRight(AC_L1_WORST_SYMBOL, 18) + AC_L1PadRight("Net", 15) + AC_L1PadLeft(AC_L1MoneyText(AC_L1_WORST_SYMBOL_NET), 12) + "\r\n";
   text += AC_L1PadRight("2", 6) + AC_L1PadRight("Asset Money", 17) + AC_L1PadRight(money_asset, 18) + AC_L1PadRight("Net", 15) + AC_L1PadLeft(AC_L1MoneyText(money_asset_net), 12) + "\r\n";
   text += AC_L1PadRight("3", 6) + AC_L1PadRight("Asset Risk", 17) + AC_L1PadRight(worst_asset_risk, 18) + AC_L1PadRight("Net/Risk", 15) + AC_L1PadLeft(DoubleToString(worst_asset_nor, 2), 12) + "\r\n";
   text += AC_L1PadRight("4", 6) + AC_L1PadRight("Direction", 17) + AC_L1PadRight(weak_direction, 18) + AC_L1PadRight("Net/Risk", 15) + AC_L1PadLeft(DoubleToString(weak_direction_nor, 2), 12) + "\r\n";
   text += AC_L1PadRight("5", 6) + AC_L1PadRight("Time Window", 17) + AC_L1PadRight(weak_time, 18) + AC_L1PadRight("Net/Risk", 15) + AC_L1PadLeft(DoubleToString(weak_time_nor, 2), 12) + "\r\n";
   text += AC_L1PadRight("6", 6) + AC_L1PadRight("Hold Bucket", 17) + AC_L1PadRight(weak_hold, 18) + AC_L1PadRight("Net/Risk", 15) + AC_L1PadLeft(DoubleToString(weak_hold_nor, 2), 12) + "\r\n";
   text += "Trade Permission:       FALSE\r\n";
   return text;
}

string AC_L1NextDecisionHintsSection(const string state,
                                     const string action_bias,
                                     const string worst_symbol,
                                     const string money_asset,
                                     const string worst_asset_risk,
                                     const string weak_direction,
                                     const string weak_time,
                                     const string weak_hold,
                                     const int risk_rows,
                                     const int closed_count)
{
   bool defensive = (StringFind(state, "Defensive") >= 0 || StringFind(action_bias, "Preserve") >= 0);
   string text = AC_L1MapHeader("LAYER 1 - NEXT DECISION HINTS");
   text += "section_id:             L1_NEXT_DECISION_HINTS\r\n";
   text += "Capital Mode:           " + (defensive ? "Defensive" : "Review Only") + "\r\n";
   text += "Do Not Increase Risk:   " + (defensive ? "TRUE" : "TRUE - Layer 1 never upgrades risk") + "\r\n";
   text += "Do Not Promote Setup:   TRUE\r\n";
   text += "Review Priority 1:      " + worst_symbol + " symbol damage\r\n";
   text += "Review Priority 2:      " + money_asset + " money leak asset\r\n";
   text += "Review Priority 3:      " + worst_asset_risk + " risk-efficiency asset\r\n";
   text += "Review Priority 4:      " + weak_direction + " direction risk\r\n";
   text += "Review Priority 5:      " + weak_time + " time-window risk\r\n";
   text += "Review Priority 6:      " + weak_hold + " holding-time risk\r\n";
   text += "Setup Analytics:        BLOCKED until structured magic/comment tags exist\r\n";
   text += "Live Risk Review:       " + (ArraySize(AC_L1_POSITIONS) > 0 || ArraySize(AC_L1_PENDING) > 0 ? "REVIEW open/pending maps" : "WAITING - no open/pending trades") + "\r\n";
   text += "Risk Geometry Proof:    " + IntegerToString(risk_rows) + " / " + IntegerToString(closed_count) + " closed rows estimated\r\n";
   text += "Trade Permission:       FALSE\r\n";
   return text;
}

string AC_L1OverseerBriefPack()
{
   int closed_count = ArraySize(AC_L1_CLOSED);
   double profit_factor = (AC_L1_GROSS_LOSS < 0.0 ? AC_L1_GROSS_PROFIT / MathAbs(AC_L1_GROSS_LOSS) : 0.0);
   double expected_payoff = (closed_count > 0 ? AC_L1_NET_PROFIT / closed_count : 0.0);
   double total_risk = 0.0;
   double net_r = 0.0;
   int risk_rows = 0;
   AC_L1BriefRiskCore(total_risk, net_r, risk_rows);
   double net_over_risk = (total_risk > 0.0 ? AC_L1_NET_PROFIT / total_risk : 0.0);

   double worst_asset_nor = 0.0;
   double worst_asset_net = 0.0;
   double worst_asset_risk = 0.0;
   string worst_asset_risk_name = AC_L1BriefWorstAssetRisk(worst_asset_nor, worst_asset_net, worst_asset_risk);
   double money_asset_net = 0.0;
   string money_asset = AC_L1BriefLargestMoneyAsset(money_asset_net);
   double weak_direction_nor = 0.0;
   string weak_direction = AC_L1BriefWeakestDirection(weak_direction_nor);
   double weak_time_nor = 0.0;
   string weak_time = AC_L1BriefWeakestTimeWindow(weak_time_nor);
   double weak_hold_nor = 0.0;
   string weak_hold = AC_L1BriefWeakestHoldBucket(weak_hold_nor);

   string state = AC_L1BriefHealthText(closed_count, profit_factor, expected_payoff, net_r, net_over_risk);
   string action_bias = AC_L1BriefActionBias(closed_count, profit_factor, expected_payoff, net_r, net_over_risk);

   string text = AC_L1MapHeader("LAYER 1 - OVERSEER BRIEF");
   text += "section_id:             L1_OVERSEER_BRIEF\r\n";
   text += "Account State:          " + state + "\r\n";
   text += "Closed Sample:          " + IntegerToString(closed_count) + " rows\r\n";
   text += "Net Result:             " + AC_L1MoneyText(AC_L1_NET_PROFIT) + "\r\n";
   text += "Profit Factor:          " + DoubleToString(profit_factor, 2) + "\r\n";
   text += "Expected Payoff:        " + AC_L1MoneyText(expected_payoff) + "\r\n";
   text += "Risk Rows:              " + IntegerToString(risk_rows) + " / " + IntegerToString(closed_count) + "\r\n";
   text += "Net R:                  " + DoubleToString(net_r, 2) + "\r\n";
   text += "Risk Efficiency:        " + DoubleToString(net_over_risk, 2) + " Net/Risk\r\n";
   text += "Worst Symbol:           " + AC_L1_WORST_SYMBOL + " " + AC_L1MoneyText(AC_L1_WORST_SYMBOL_NET) + "\r\n";
   text += "Worst Asset Risk:       " + worst_asset_risk_name + " " + DoubleToString(worst_asset_nor, 2) + " Net/Risk\r\n";
   text += "Largest Money Asset:    " + money_asset + " " + AC_L1MoneyText(money_asset_net) + "\r\n";
   text += "Weakest Direction:      " + weak_direction + " " + DoubleToString(weak_direction_nor, 2) + " Net/Risk\r\n";
   text += "Weakest Time Window:    " + weak_time + " " + DoubleToString(weak_time_nor, 2) + " Net/Risk\r\n";
   text += "Weakest Hold Bucket:    " + weak_hold + " " + DoubleToString(weak_hold_nor, 2) + " Net/Risk\r\n";
   text += "Live Exposure:          " + IntegerToString(ArraySize(AC_L1_POSITIONS)) + " open / " + IntegerToString(ArraySize(AC_L1_PENDING)) + " pending\r\n";
   text += "Primary Action Bias:    " + action_bias + "\r\n";
   text += "Trade Permission:       FALSE\r\n";
   text += AC_L1TopPortfolioLeaksSection(worst_asset_risk_name, worst_asset_nor, money_asset, money_asset_net, weak_direction, weak_direction_nor, weak_time, weak_time_nor, weak_hold, weak_hold_nor);
   text += AC_L1NextDecisionHintsSection(state, action_bias, AC_L1_WORST_SYMBOL, money_asset, worst_asset_risk_name, weak_direction, weak_time, weak_hold, risk_rows, closed_count);
   text += AC_L1MapPolicySection();
   return text;
}

#endif