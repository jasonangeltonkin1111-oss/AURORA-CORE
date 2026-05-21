#ifndef AC_COMMON_TYPES_MQH
#define AC_COMMON_TYPES_MQH

string AC_UlongToText(const ulong value)
{
   return StringFormat("%I64u", value);
}

struct AC_WriteResult
{
   bool   attempted;
   bool   ok;
   bool   temp_open_ok;
   bool   temp_write_ok;
   bool   move_ok;
   bool   final_exists;
   ulong  final_size;
   int    error_code;
   string status;
   string detail;
   string final_path;
   string temp_path;
};

struct AC_Runtime0Snapshot
{
   long   heartbeat_id;
   uint   timer_started_ms;
   uint   timer_finished_ms;
   uint   timer_duration_ms;
   bool   over_budget;
   string generated_at;
   string runtime_state;
   string terminal_connected;
   string timer_setup_status;
   int    timer_setup_error;
   string route_root;
   string folder_create_status;
   string placeholder_status;
   string fileio_status;
   string manifest_status;
   string telemetry_status;
   string diagnostics_status;
   string upgrade_log_status;
   string upgrade_addendum_status;
   string micro_log_status;
   string owner_status;
   string layer_0_1_status;
   string layer_0_2_status;
   string layer_0_4_status;
   bool   file_publication_blocked;
   string degraded_reason;
   string blocked_reason;
};

struct AC_Layer0StatusPacket
{
   string layer_id;
   string layer_name;
   string owner_name;
   string status;
   string trust_state;
   string main_blocker;
   int    broker_symbols_total;
   int    marketwatch_symbols_total;
   int    dossier_shells_ready;
   int    dossier_shells_missing;
   int    batch_start_index;
   int    batch_end_index;
   int    batch_attempted;
   int    batch_written;
   int    next_symbol_index;
   uint   batch_duration_ms;
   bool   batch_complete;
   bool   trade_permission;
   bool   auto_trade_allowed;
   bool   ranking_runtime;
   bool   selection_runtime;
   bool   market_state_known;
   bool   specs_known;
   bool   quotes_known;
   string first_failure;
};

#endif