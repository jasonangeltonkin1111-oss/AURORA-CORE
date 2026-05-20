#ifndef AC_ACCOUNT_TRUTH_MQH
#define AC_ACCOUNT_TRUTH_MQH

// Runtime 1 owns account and portfolio truth.
// This first Layer 1 slice is read-only: no trading, no symbols, no strategy, no permission grant.

string AC_TradeModeText(const long mode)
{
   if(mode == ACCOUNT_TRADE_MODE_DEMO)
      return "demo";
   if(mode == ACCOUNT_TRADE_MODE_CONTEST)
      return "contest";
   if(mode == ACCOUNT_TRADE_MODE_REAL)
      return "real";
   return "unknown";
}

string AC_AccountTruthText()
{
   string text = "";
   text += "system_name=" + AC_SYSTEM_NAME + "\r\n";
   text += "build_version=" + AC_BUILD_VERSION + "\r\n";
   text += "upgrade_id=" + AC_UPGRADE_ID + "\r\n";
   text += "runtime_owner=" + AC_RUNTIME1_OWNER + "\r\n";
   text += "layer_name=" + AC_LAYER_1_NAME + "\r\n";
   text += "generated_at=" + AC_NowText() + "\r\n";
   text += "account_login=" + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)) + "\r\n";
   text += "account_server=" + AccountInfoString(ACCOUNT_SERVER) + "\r\n";
   text += "account_company=" + AccountInfoString(ACCOUNT_COMPANY) + "\r\n";
   text += "account_name=" + AccountInfoString(ACCOUNT_NAME) + "\r\n";
   text += "account_currency=" + AccountInfoString(ACCOUNT_CURRENCY) + "\r\n";
   text += "account_trade_mode=" + AC_TradeModeText(AccountInfoInteger(ACCOUNT_TRADE_MODE)) + "\r\n";
   text += "account_leverage=" + IntegerToString(AccountInfoInteger(ACCOUNT_LEVERAGE)) + "\r\n";
   text += "balance=" + DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2) + "\r\n";
   text += "equity=" + DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2) + "\r\n";
   text += "profit=" + DoubleToString(AccountInfoDouble(ACCOUNT_PROFIT), 2) + "\r\n";
   text += "margin=" + DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN), 2) + "\r\n";
   text += "free_margin=" + DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_FREE), 2) + "\r\n";
   text += "margin_level=" + DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_LEVEL), 2) + "\r\n";
   text += "open_position_count=" + IntegerToString(PositionsTotal()) + "\r\n";
   text += "pending_order_count=" + IntegerToString(OrdersTotal()) + "\r\n";
   text += "prop_rule_status=not_configured\r\n";
   text += "risk_state=observed_only_no_permission\r\n";
   text += "trade_permission=blocked\r\n";
   text += "scope_check=layer1_account_truth_only_no_symbols_no_ranking_no_strategy_no_execution\r\n";
   return text;
}

string AC_AccountTruthStatusRow(const AC_WriteResult &account_write)
{
   return "schema_name=layer_status|schema_version=v0.1|layer_id=1|layer_name=" + AC_LAYER_1_NAME
      + "|source_owner=" + AC_RUNTIME1_OWNER
      + "|build_version=" + AC_BUILD_VERSION
      + "|upgrade_id=" + AC_UPGRADE_ID
      + "|layer_status=" + (account_write.ok ? "complete" : "complete_with_degraded")
      + "|account_status_available=" + AC_BoolText(account_write.ok)
      + "|trade_permission=blocked";
}

#endif
