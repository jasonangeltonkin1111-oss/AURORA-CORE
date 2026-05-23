#ifndef AC_ACCOUNT_TRUTH_MQH
#define AC_ACCOUNT_TRUTH_MQH

// Runtime 1 owner dispatcher.
// One source owner, split implementation files.
// Board/Dossier/Workbench render Layer 1 truth from this owner only.
// This owner is read-only and never grants trade permission.

#include "AC_L1_Types.mqh"
#include "AC_L1_Format.mqh"
#include "AC_L1_State.mqh"
#include "AC_L1_Scan.mqh"
string AC_L1ClusterKey(const AC_L1ClosedTradeRow &row);
#include "AC_L1_Maps.mqh"
#include "AC_L1_RReadiness.mqh"
#include "AC_L1_MoneyRiskReadiness.mqh"
#include "AC_L1_LiveExposure.mqh"
#include "AC_L1_LiveExposureMaps.mqh"
#include "AC_L1_CostTagMaps.mqh"
#include "AC_L1_DataQualityMaps.mqh"
#include "AC_L1_EquityDrawdownMaps.mqh"
#define AC_Layer1BoardSection AC_Layer1BoardSection_Base
#define AC_AccountTruthStatusRow AC_AccountTruthStatusRow_Base
#include "AC_L1_Render.mqh"
#undef AC_Layer1BoardSection
#undef AC_AccountTruthStatusRow

string AC_L1BoardLine(const string label, const string value)
{
   return AC_L1PadRight(label + ":", 22) + value + "\r\n";
}

string AC_L1CompactBoardSection()
{
   int closed_count = ArraySize(AC_L1_CLOSED);
   double profit_factor = (AC_L1_GROSS_LOSS < 0.0 ? AC_L1_GROSS_PROFIT / MathAbs(AC_L1_GROSS_LOSS) : 0.0);
   double expected_payoff = (closed_count > 0 ? AC_L1_NET_PROFIT / closed_count : 0.0);
   double open_profit_pct = (AC_L1_EQUITY > 0.0 ? (AC_L1_FLOATING_PL / AC_L1_EQUITY) * 100.0 : 0.0);
   double current_dd_money = (AC_L1_BALANCE > AC_L1_EQUITY ? AC_L1_BALANCE - AC_L1_EQUITY : 0.0);
   double current_dd_pct = (AC_L1_BALANCE > 0.0 ? (current_dd_money / AC_L1_BALANCE) * 100.0 : 0.0);
   double hard_risk_money = AC_L1_EQUITY * 0.002;
   double largest_loss_usage = (hard_risk_money > 0.0 && AC_L1_LARGEST_LOSS < 0.0 ? (MathAbs(AC_L1_LARGEST_LOSS) / hard_risk_money) * 100.0 : 0.0);

   string health = "Needs validation";
   if(closed_count > 0 && (profit_factor < 1.0 || expected_payoff < 0.0)) health = "Defensive review";
   if(closed_count > 0 && profit_factor >= 1.0 && expected_payoff >= 0.0) health = "Positive history, not edge proof";

   string text = "\r\nLAYER 1 - ACCOUNT AND PORTFOLIO\r\n";
   text += "----------------------------------------\r\n";
   text += AC_L1BoardLine("Account", IntegerToString((int)AC_L1_LOGIN) + " / " + AC_L1_SERVER);
   text += AC_L1BoardLine("Mode / Currency", AC_L1_TRADE_MODE + " / " + AC_L1_CURRENCY);
   text += AC_L1BoardLine("Balance / Equity", AC_L1MoneyText(AC_L1_BALANCE) + " / " + AC_L1MoneyText(AC_L1_EQUITY));
   text += AC_L1BoardLine("Floating P/L", AC_L1MoneyText(AC_L1_FLOATING_PL) + " (" + AC_L1PercentText(open_profit_pct) + ")");
   text += AC_L1BoardLine("Current Drawdown", AC_L1MoneyText(current_dd_money) + " (" + AC_L1PercentText(current_dd_pct) + ")");
   text += AC_L1BoardLine("Open / Pending", IntegerToString(ArraySize(AC_L1_POSITIONS)) + " / " + IntegerToString(ArraySize(AC_L1_PENDING)));
   text += AC_L1BoardLine("Selected Closed Rows", IntegerToString(closed_count));
   text += AC_L1BoardLine("Net Profit", AC_L1MoneyText(AC_L1_NET_PROFIT));
   text += AC_L1BoardLine("Profit Factor", DoubleToString(profit_factor, 2));
   text += AC_L1BoardLine("Expected Payoff", AC_L1MoneyText(expected_payoff));
   text += AC_L1BoardLine("Best / Worst Symbol", AC_L1_BEST_SYMBOL + " " + AC_L1MoneyText(AC_L1_BEST_SYMBOL_NET) + " / " + AC_L1_WORST_SYMBOL + " " + AC_L1MoneyText(AC_L1_WORST_SYMBOL_NET));
   text += AC_L1BoardLine("Worst Day", AC_L1_WORST_DAY + " " + AC_L1MoneyText(AC_L1_WORST_DAY_NET));
   text += AC_L1BoardLine("Hard Risk 0.20%", AC_L1MoneyText(hard_risk_money));
   text += AC_L1BoardLine("Largest Loss Usage", AC_L1PercentText(largest_loss_usage));
   text += AC_L1BoardLine("Health", health);
   text += AC_L1BoardLine("Trade Permission", "FALSE");
   text += "Note: Account Status carries full trades, maps, cost, tag, quality, and drawdown detail.\r\n";
   return text;
}

string AC_Layer1BoardSection()
{
   if(!AC_L1_READY)
      return "\r\nLAYER 1 - ACCOUNT AND PORTFOLIO\r\n----------------------------------------\r\nStatus: Pending\r\n";
   return AC_L1CompactBoardSection() + AC_L1OpenPendingBoardSummary() + AC_L1PortfolioMapSummary();
}

string AC_AccountTruthStatusRow(const AC_WriteResult &account_write)
{
   return AC_AccountTruthStatusRow_Base(account_write) + "|portfolio_maps=enabled|portfolio_map_scope=summary_board_full_account_status|r_readiness=enabled|money_risk_readiness=enabled|live_exposure=enabled|live_exposure_maps=enabled|cost_tag_maps=enabled|data_quality_ledger=enabled|equity_drawdown_map=enabled|board_layer1_compact=true";
}

#endif