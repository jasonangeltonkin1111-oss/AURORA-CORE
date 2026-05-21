#ifndef AC_CONFIG_MQH
#define AC_CONFIG_MQH

static const string AC_SYSTEM_NAME        = "AURORA CORE";
static const string AC_BUILD_PHASE        = "l0_l1_compile_and_schema_cache_repair";
static const string AC_BUILD_VERSION      = "1.026";
static const string AC_UPGRADE_ID         = "L0_L1_COMPILE_SCHEMA_CACHE_REPAIR";
static const string AC_UPGRADE_SUMMARY    = "Repairs Layer 1 account-history compile compatibility and forces one-time Dossier shell rebuild when the embedded Dossier schema changes.";
static const string AC_UPGRADE_SCOPE      = "Layer 0 cached universe publication plus Layer 1 account, portfolio, current exposure, reconstructed closed history, canceled order context, Board account report, Account Status report, and per-symbol Dossier slices. No Layer 2 open/closed, specs, quotes, ranking, selection, alerts, strategy, Python worker, or trade execution.";
static const string AC_UPGRADE_TEST_PLAN  = "Compile AuroraCore.mq5; verify AC_L1_Scan.mqh no longer rejects DEAL_FEE/HistoryDealGetDouble usage; run EA; confirm Dossiers rebuild once for dossier_shell_schema_version change and then cache without rewrite storms; inspect Market Board, Account Status, Workbench, Manifest, and symbol Dossiers.";
static const string AC_LOGGING_POLICY     = "near_instant_board_write_if_changed_plus_layer1_scan_addendum";
static const string AC_RUNTIME0_OWNER     = "Runtime 0 - Governance / Internal Control Owner";
static const string AC_RUNTIME1_OWNER     = "Runtime 1 - Foundation Truth Owner";
static const string AC_PUBLICATION_SERVICE_OWNER = "Publication / FileIO / Route Service";
static const string AC_BOARD_DOSSIER_RENDERER_OWNER = "Board / Dossier Renderer Service";
static const string AC_LAYER_0_1_NAME     = "Layer 0.1 - Startup / Runtime Identity";
static const string AC_LAYER_0_2_NAME     = "Layer 0.2 - Scheduler / Heartbeat / Breathing Spine";
static const string AC_LAYER_0_4_NAME     = "Layer 0.4 - Governance / Manifest / Telemetry";
static const string AC_LAYER_0_BOARD_DOSSIER_NAME = "Layer 0 - Board + Dossier Shell Foundation";
static const string AC_LAYER_1_NAME       = "Layer 1 - Account / Portfolio / Prop Rule Truth";
static const string AC_DOSSIER_SHELL_SCHEMA_VERSION = "dossier_shell_v1.026_l1_account_slices";
static const string AC_BASE_FOLDER        = "Aurora Core";
static const string AC_WORKBENCH_FOLDER   = "Workbench";
static const string AC_DOSSIERS_FOLDER    = "Dossiers";
static const string AC_SELECTION_FOLDER   = "Selection Desk";
static const string AC_SELECTION_GROUPS_FOLDER = "Groups";
static const string AC_SELECTION_GLOBAL_FOLDER = "Global";
static const string AC_SELECTION_INDEX_FILE = "Selection Index.txt";
static const string AC_MARKET_BOARD_FILE  = "Market Board.txt";
static const int    AC_TIMER_MILLISECONDS = 250;
static const int    AC_WORKBENCH_INTERVAL_HEARTBEATS = 4;
static const int    AC_DOSSIER_SHELL_WRITE_RETRIES = 3;
static const int    AC_BOARD_RECENT_ACTIVITY_MAX_ROWS = 100;
static const int    AC_BOARD_CANCELED_ACTIVITY_MAX_ROWS = 20;
static const int    AC_DOSSIER_SYMBOL_ACTIVITY_MAX_ROWS = 30;
static const uint   AC_TIMER_BUDGET_MS    = 250;
static const bool   AC_USE_COMMON_FILES   = true;

#endif