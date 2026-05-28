#ifndef AC_CONFIG_MQH
#define AC_CONFIG_MQH

static const string AC_SYSTEM_NAME        = "AURORA CORE";
static const string AC_BUILD_PHASE        = "heartbeat_data_change_refresh";
static const string AC_BUILD_VERSION      = "1.092";
static const string AC_UPGRADE_ID         = "L0_L4_HEARTBEAT_DATA_CHANGE_REFRESH";
static const string AC_UPGRADE_SUMMARY    = "Restores heartbeat-driven changed-only publication by making Layer 4 refresh keys data-change driven instead of clock-time driven, so quote checks can run every heartbeat without dirtying every Dossier/Gateway surface from static time refresh.";
static const string AC_UPGRADE_SCOPE      = "Existing Runtime 1 Layer 4 market-watch truth owner and existing Runtime 7 publication chain only. No new owner, FileIO owner, route owner, worker V2, strategy, alerts, execution, or trade permission is added. Dossiers and gateway inputs should dirty from source data change, not refresh_time churn.";
static const string AC_UPGRADE_TEST_PLAN  = "Compile must confirm build_version=1.092. Runtime proof must show Runtime_Status.txt and Market Board.txt advance on the 250ms heartbeat, L4 refresh_key no longer contains refresh_time, unchanged Dossiers stay skipped/no-rewrite, changed quote packets update their affected surfaces, and timer_duration_gt_period_flag/timer_busy_skip_count do not climb under normal load. Layer 6 remains cost/friction ranking only; trade_permission=false, auto_trade_allowed=false, selection_runtime=false, entry_signal=false, execution=false.";
static const string AC_LOGGING_POLICY     = "event_boundary_heartbeat_data_change_refresh_no_permission_no_new_owner";
static const string AC_RUNTIME0_OWNER     = "Runtime 0 - Governance / Internal Control Owner";
static const string AC_RUNTIME1_OWNER     = "Runtime 1 - Foundation Truth Owner";
static const string AC_RUNTIME3_OWNER     = "Runtime 3 - Calculation Gateway Owner";
static const string AC_RUNTIME5_OWNER     = "Runtime 5 - Reserved / Not Layer 5 Owner";
static const string AC_PUBLICATION_SERVICE_OWNER = "Publication / FileIO / Route Service";
static const string AC_BOARD_DOSSIER_RENDERER_OWNER = "Board / Dossier Renderer Service";
static const string AC_LAYER_0_1_NAME     = "Layer 0.1 - Startup / Runtime Identity";
static const string AC_LAYER_0_2_NAME     = "Layer 0.2 - Scheduler / Heartbeat / Breathing Spine";
static const string AC_LAYER_0_4_NAME     = "Layer 0.4 - Governance / Manifest / Telemetry";
static const string AC_LAYER_0_BOARD_DOSSIER_NAME = "Layer 0 - Board + Dossier Foundation";
static const string AC_LAYER_1_NAME       = "Layer 1 - Account / Portfolio / Prop Rule Truth";
static const string AC_LAYER_2_NAME       = "Layer 2 - Market Open / Closed Truth";
static const string AC_LAYER_3_NAME       = "Layer 3 - Broker Specs and Value Truth";
static const string AC_LAYER_4_NAME       = "Layer 4 - Live Quote and Spread Truth";
static const string AC_LAYER_5_NAME       = "Layer 5 - Basic System Gate";
static const string AC_LAYER_EXTERNAL_WORKER_NAME = "Calculation Gateway Foundation";
static const string AC_GATEWAY_DISPLAY_NAME = "Gateway";
static const string AC_GATEWAY_LEGACY_PATH_POLICY = "physical_gateway_paths_active_external_worker_names_are_internal_compatibility_only";
static const string AC_GATEWAY_SHARED_TARGET_FOLDER = "Gateway";
static const string AC_GATEWAY_ACCOUNT_TARGET_FOLDER = "Gateway";
static const string AC_GATEWAY_JOB_BUS_SCHEMA_VERSION = "job_bus_v1";
static const string AC_EXTERNAL_WORKER_JOB_BUS_SCHEMA_VERSION = "job_bus_v1";
static const string AC_DOSSIER_SHELL_SCHEMA_VERSION = "dossier_v1.092_data_change_refresh";
static const string AC_L5_CALCULATION_EXECUTION_OWNER = "none_basic_gate_only";
static const string AC_L5_ADVISORY_SURFACE_OWNER = "not_layer5_belongs_to_layer6_plus";
static const string AC_L5_PREVIOUS_LAYER_DUPLICATION_POLICY = "forbidden_l5_consumes_l2_l3_l4_owner_packets_and_outputs_basic_pass_block_gate_only";
static const string AC_BASE_FOLDER        = "Aurora Core";
static const string AC_WORKBENCH_FOLDER   = "Workbench";
static const string AC_EXTERNAL_WORKER_FOLDER = "Gateway";
static const string AC_EXTERNAL_WORKER_CONTROL_FOLDER = "Control";
static const string AC_EXTERNAL_WORKER_INBOX_FOLDER = "Inbox";
static const string AC_EXTERNAL_WORKER_OUTBOX_FOLDER = "Outbox";
static const string AC_EXTERNAL_WORKER_STATUS_FOLDER = "Status";
static const string AC_EXTERNAL_WORKER_LOGS_FOLDER = "Logs";
static const string AC_EXTERNAL_WORKER_QUARANTINE_FOLDER = "Quarantine";
static const string AC_EXTERNAL_WORKER_EXE_FILE = "AuroraWorker.exe";
static const string AC_EXTERNAL_WORKER_LAUNCH_MODE = "WINDOWS_SCHEDULED_TASK_GLOBAL_DAEMON_WATCHDOG";
static const string AC_EXTERNAL_WORKER_LAUNCH_IMPLEMENTATION = "windows_scheduled_task_global_daemon_watchdog";
static const string AC_EXTERNAL_WORKER_DEFAULT_JOB_TYPE = "R3_SNAPSHOT_VALIDATION_V1";
static const string AC_EXTERNAL_WORKER_JOB_RESOURCE_CLASS = "light_serial";
static const int    AC_EXTERNAL_WORKER_JOB_MAX_RUNTIME_MS = 3000;
static const string AC_DOSSIERS_FOLDER    = "Dossiers";
static const string AC_SELECTION_FOLDER   = "Selection Desk";
static const string AC_SELECTION_GROUPS_FOLDER = "Groups";
static const string AC_SELECTION_GLOBAL_FOLDER = "Global";
static const string AC_SELECTION_INDEX_FILE = "Selection Index.txt";
static const string AC_TRADE_JOURNAL_IMPORT_FOLDER = "Trade Journal Import";
static const string AC_TRADE_JOURNAL_INBOX_FOLDER = "Inbox";
static const string AC_TRADE_JOURNAL_ACCEPTED_FOLDER = "Accepted";
static const string AC_TRADE_JOURNAL_REJECTED_FOLDER = "Rejected";
static const string AC_TRADE_JOURNAL_ORPHANED_FOLDER = "Orphaned";
static const string AC_TRADE_HISTORY_FOLDER = "Trade History";
static const string AC_TRADE_HISTORY_BEFORE_AURORA_FOLDER = "Before Aurora";
static const string AC_TRADE_HISTORY_AURORA_CAPTURED_FOLDER = "Aurora Captured";
static const string AC_MARKET_BOARD_FILE  = "Market Board.txt";
static const int    AC_TIMER_MILLISECONDS = 250;
static const int    AC_TIMER_STUCK_WARN_MS = 5000;
static const int    AC_WORKBENCH_INTERVAL_HEARTBEATS = 120;
static const int    AC_L2_REFRESH_SECONDS = 300;
static const int    AC_L4_DOSSIER_REFRESH_SECONDS = 0;
static const int    AC_L4_TOP_LIST_REFRESH_SECONDS = 10;
static const int    AC_CALCULATION_RUNTIME_REFRESH_SECONDS = 30;
static const int    AC_EXTERNAL_WORKER_HEALTH_CHECK_SECONDS = 15;
static const int    AC_EXTERNAL_WORKER_HEARTBEAT_MAX_AGE_SECONDS = 45;
static const int    AC_EXTERNAL_WORKER_RESULT_MAX_AGE_SECONDS = 90;
static const int    AC_EXTERNAL_WORKER_SHARED_STATUS_MAX_AGE_SECONDS = 90;
static const int    AC_EXTERNAL_WORKER_LAUNCH_COOLDOWN_SECONDS = 30;
static const int    AC_EXTERNAL_WORKER_MAX_LAUNCH_ATTEMPTS = 3;
static const bool   AC_EXTERNAL_WORKER_REQUIRED = true;
static const bool   AC_EXTERNAL_WORKER_AUTO_LAUNCH_DESIRED = true;
static const bool   AC_EXTERNAL_WORKER_POPUP_ALERTS = false;
static const string AC_EXTERNAL_WORKER_AUTHORITY = "calculation_support_only";
static const int    AC_EXPERIMENTAL_TIMER_100MS = 100;
static const int    AC_EXPERIMENTAL_TIMER_10MS = 10;
static const int    AC_DOSSIER_SHELL_WRITE_RETRIES = 3;
static const int    AC_DOSSIER_UNIVERSE_MAX_SYMBOLS_PER_PASS = 0;
static const int    AC_DOSSIER_UNIVERSE_PASS_BUDGET_MS = 0;
static const int    AC_BOARD_RECENT_ACTIVITY_MAX_ROWS = 100;
static const int    AC_BOARD_CANCELED_ACTIVITY_MAX_ROWS = 20;
static const int    AC_DOSSIER_SYMBOL_ACTIVITY_MAX_ROWS = 30;
static const uint   AC_TIMER_BUDGET_MS    = 0;
static const bool   AC_USE_COMMON_FILES   = true;

string AC_L0CsvCompatField(string line, int index)
{
   string cols[];
   ushort sep = StringGetCharacter(",", 0);
   int count = StringSplit(line, sep, cols);
   if(index < 0 || index >= count) return "";
   string value = cols[index];
   StringTrimLeft(value);
   StringTrimRight(value);
   StringReplace(value, "\"", "");
   return value;
}

string AC_L6CsvLineForSymbol(const string symbol){ return ""; }
string AC_L7CsvLineForSymbol(const string symbol){ return ""; }
string AC_L8CsvLineForSymbol(const string symbol){ return ""; }
string AC_L9CsvLineForSymbol(const string symbol){ return ""; }
string AC_L10CsvLineForSymbol(const string symbol){ return ""; }

string AC_L6CsvField(string line, int index){ return AC_L0CsvCompatField(line, index); }
string AC_L7CsvField(string line, int index){ return AC_L0CsvCompatField(line, index); }
string AC_L8CsvField(string line, int index){ return AC_L0CsvCompatField(line, index); }
string AC_L9CsvField(string line, int index){ return AC_L0CsvCompatField(line, index); }
string AC_L10CsvField(string line, int index){ return AC_L0CsvCompatField(line, index); }

#endif
