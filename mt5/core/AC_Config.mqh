#ifndef AC_CONFIG_MQH
#define AC_CONFIG_MQH

static const string AC_SYSTEM_NAME        = "AURORA CORE";
static const string AC_BUILD_PHASE        = "layer4_market_watch_truth";
static const string AC_BUILD_VERSION      = "1.036";
static const string AC_UPGRADE_ID         = "L4_MARKET_WATCH_TRUTH";
static const string AC_UPGRADE_SUMMARY    = "Adds Runtime 1 Layer 4 live Market Watch truth for open symbols: SymbolInfoTick packet, bid/ask validation, tick freshness, live spread, BPS, daily change, session activity proxies, Board/Workbench counters, and Dossier sections while preserving Runtime 7 as publication-only.";
static const string AC_UPGRADE_SCOPE      = "Runtime 1 owns Layer 1 through Layer 4 foundation truth. Layer 4 scans changing live Market Watch data for open symbols only. Closed symbols remain cut off after Layer 3 until Layer 2 reopens them. No ranking, selection, alerts, strategy, DOM, history, indicators, Python worker, or trade execution.";
static const string AC_UPGRADE_TEST_PLAN  = "Compile AuroraCore.mq5; run EA; confirm Board shows Layer 4 counters, Workbench shows L4 diagnostics, open Dossiers render live quote/spread/BPS/daily-change truth, closed Dossiers show L4 cut off, and trade_permission remains false.";
static const string AC_LOGGING_POLICY     = "near_instant_board_write_if_changed_plus_l4_market_watch_truth_counters_no_per_tick_file_spam";
static const string AC_RUNTIME0_OWNER     = "Runtime 0 - Governance / Internal Control Owner";
static const string AC_RUNTIME1_OWNER     = "Runtime 1 - Foundation Truth Owner";
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
static const string AC_DOSSIER_SHELL_SCHEMA_VERSION = "dossier_v1.036_l4_market_watch_truth";
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
static const int    AC_L4_DOSSIER_REFRESH_SECONDS = 60;
static const int    AC_L4_TOP_LIST_REFRESH_SECONDS = 10;
static const int    AC_CALCULATION_RUNTIME_REFRESH_SECONDS = 300;
static const int    AC_EXPERIMENTAL_TIMER_100MS = 100;
static const int    AC_EXPERIMENTAL_TIMER_10MS = 10;
static const int    AC_DOSSIER_SHELL_WRITE_RETRIES = 3;
static const int    AC_BOARD_RECENT_ACTIVITY_MAX_ROWS = 100;
static const int    AC_BOARD_CANCELED_ACTIVITY_MAX_ROWS = 20;
static const int    AC_DOSSIER_SYMBOL_ACTIVITY_MAX_ROWS = 30;
static const uint   AC_TIMER_BUDGET_MS    = 250;
static const bool   AC_USE_COMMON_FILES   = true;

#endif