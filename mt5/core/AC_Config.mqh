#ifndef AC_CONFIG_MQH
#define AC_CONFIG_MQH

static const string AC_SYSTEM_NAME        = "AURORA CORE";
static const string AC_BUILD_PHASE        = "layer2_market_open_closed_truth";
static const string AC_BUILD_VERSION      = "1.028";
static const string AC_UPGRADE_ID         = "L2_MARKET_OPEN_CLOSED_TRUTH";
static const string AC_UPGRADE_SUMMARY    = "Adds Foundation Truth Owner Layer 2 market open/closed/unknown session truth with Dossier route publication and closed-symbol downstream cutoff state.";
static const string AC_UPGRADE_SCOPE      = "Layer 0 cached universe publication plus Layer 1 account/portfolio truth and Layer 2 market open/closed/unknown session truth. L2 may route Dossiers to Open/Closed/Unknown and expose downstream cutoff state. No Layer 3 specs, Layer 4 quotes, ranking, selection, alerts, strategy, Python worker, or trade execution.";
static const string AC_UPGRADE_TEST_PLAN  = "Compile AuroraCore.mq5; run EA; inspect Market Board L2 summary; confirm open+closed+unknown equals broker symbols; confirm Dossiers publish to Open/Closed/Unknown with no missing files; confirm closed-symbol Dossiers show deeper-layer cutoff and next_recheck_due; inspect Workbench Status, Manifest, Diagnostics, and no trade permission.";
static const string AC_LOGGING_POLICY     = "near_instant_board_write_if_changed_plus_l2_session_truth_route_publication";
static const string AC_RUNTIME0_OWNER     = "Runtime 0 - Governance / Internal Control Owner";
static const string AC_RUNTIME1_OWNER     = "Runtime 1 - Foundation Truth Owner";
static const string AC_PUBLICATION_SERVICE_OWNER = "Publication / FileIO / Route Service";
static const string AC_BOARD_DOSSIER_RENDERER_OWNER = "Board / Dossier Renderer Service";
static const string AC_LAYER_0_1_NAME     = "Layer 0.1 - Startup / Runtime Identity";
static const string AC_LAYER_0_2_NAME     = "Layer 0.2 - Scheduler / Heartbeat / Breathing Spine";
static const string AC_LAYER_0_4_NAME     = "Layer 0.4 - Governance / Manifest / Telemetry";
static const string AC_LAYER_0_BOARD_DOSSIER_NAME = "Layer 0 - Board + Dossier Shell Foundation";
static const string AC_LAYER_1_NAME       = "Layer 1 - Account / Portfolio / Prop Rule Truth";
static const string AC_LAYER_2_NAME       = "Layer 2 - Market Open / Closed Truth";
static const string AC_DOSSIER_SHELL_SCHEMA_VERSION = "dossier_shell_v1.028_l2_market_state_routes";
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
static const int    AC_L2_REFRESH_SECONDS = 300;
static const int    AC_DOSSIER_SHELL_WRITE_RETRIES = 3;
static const int    AC_BOARD_RECENT_ACTIVITY_MAX_ROWS = 100;
static const int    AC_BOARD_CANCELED_ACTIVITY_MAX_ROWS = 20;
static const int    AC_DOSSIER_SYMBOL_ACTIVITY_MAX_ROWS = 30;
static const uint   AC_TIMER_BUDGET_MS    = 250;
static const bool   AC_USE_COMMON_FILES   = true;

#endif