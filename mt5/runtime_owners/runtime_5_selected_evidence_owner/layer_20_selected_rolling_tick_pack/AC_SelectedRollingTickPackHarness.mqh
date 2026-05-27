#ifndef AC_SELECTED_ROLLING_TICK_PACK_HARNESS_MQH
#define AC_SELECTED_ROLLING_TICK_PACK_HARNESS_MQH

#include "AC_SelectedRollingTickPackPublication.mqh"

#ifndef AC_L20_RUNTIME_ACTIVATION_ENABLED
#define AC_L20_RUNTIME_ACTIVATION_ENABLED false
#endif

static const string AC_L20_HARNESS_STATUS_DISABLED = "not_wired_disabled_until_L19_running_on_main";

struct AC_L20HarnessResult
{
   bool   activation_enabled;
   bool   attempted;
   bool   published;
   int    selected_count;
   int    updated_symbols;
   int    degraded_symbols;
   int    unavailable_symbols;
   int    update_duration_ms;
   string status;
   string reason;
   string publish_detail;
};

void AC_L20HarnessEmptyResult(AC_L20HarnessResult &result)
{
   result.activation_enabled = AC_L20_RUNTIME_ACTIVATION_ENABLED;
   result.attempted = false;
   result.published = false;
   result.selected_count = 0;
   result.updated_symbols = 0;
   result.degraded_symbols = 0;
   result.unavailable_symbols = 0;
   result.update_duration_ms = 0;
   result.status = AC_L20_HARNESS_STATUS_DISABLED;
   result.reason = "runtime_activation_disabled_no_OnTimer_call";
   result.publish_detail = "not_attempted";
}

string AC_L20HarnessStatusText(const AC_L20HarnessResult &result)
{
   string text = "schema_name=aurora_l20_harness_status\r\n";
   text += "schema_version=1\r\n";
   text += "activation_enabled=" + AC_L20BoolText(result.activation_enabled) + "\r\n";
   text += "attempted=" + AC_L20BoolText(result.attempted) + "\r\n";
   text += "published=" + AC_L20BoolText(result.published) + "\r\n";
   text += "status=" + result.status + "\r\n";
   text += "reason=" + result.reason + "\r\n";
   text += "selected_count=" + IntegerToString(result.selected_count) + "\r\n";
   text += "updated_symbols=" + IntegerToString(result.updated_symbols) + "\r\n";
   text += "degraded_symbols=" + IntegerToString(result.degraded_symbols) + "\r\n";
   text += "unavailable_symbols=" + IntegerToString(result.unavailable_symbols) + "\r\n";
   text += "update_duration_ms=" + IntegerToString(result.update_duration_ms) + "\r\n";
   text += "publish_detail=" + result.publish_detail + "\r\n";
   text += "current_quote_owner=L4\r\n";
   text += "trade_permission=false\r\n";
   text += "entry_signal=false\r\n";
   text += "execution=false\r\n";
   text += "institutional_order_flow_claim=false\r\n";
   return text;
}

bool AC_L20HarnessCompileTouch(string &detail)
{
   AC_L20HarnessResult result;
   AC_L20HarnessEmptyResult(result);

   AC_L20SymbolSummary summary;
   AC_L20EmptySummary(summary, "COMPILE_TOUCH", "not_wired", "compile_touch_only_no_runtime_capture");

   string csv_header = AC_L20CsvHeader();
   string board_line = AC_L20BoardLine(summary);
   string dossier_section = AC_L20DossierSection(summary);
   string harness_status = AC_L20HarnessStatusText(result);

   detail = "compile_touch_ok;csv_header_len=" + IntegerToString(StringLen(csv_header))
      + ";board_line_len=" + IntegerToString(StringLen(board_line))
      + ";dossier_section_len=" + IntegerToString(StringLen(dossier_section))
      + ";harness_status_len=" + IntegerToString(StringLen(harness_status));
   return true;
}

bool AC_L20HarnessRunDisabled(string &status_text)
{
   AC_L20HarnessResult result;
   AC_L20HarnessEmptyResult(result);
   status_text = AC_L20HarnessStatusText(result);
   return false;
}

#endif
