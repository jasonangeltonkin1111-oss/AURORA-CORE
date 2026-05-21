#ifndef AC_CONFIG_MQH
#define AC_CONFIG_MQH

static const string AC_SYSTEM_NAME        = "AURORA CORE";
static const string AC_BUILD_PHASE        = "layer3_final_metadata_cleanup";
static const string AC_BUILD_VERSION      = "1.035";
static const string AC_UPGRADE_ID         = "L3_FINAL_METADATA_CLEANUP";
static const string AC_UPGRADE_SUMMARY    = "Final Layer 3 metadata cleanup: broker metadata is advisory only, ISIN is removed from trader-facing Dossiers, empty broker metadata lines are hidden, metadata retrieval belongs to the scan owner, HK equity links are exchange-qualified, and workbook/Runtime 2 taxonomy remains bucket authority.";
static const string AC_UPGRADE_SCOPE      = "Layer 0 cached universe publication plus Layer 1 account/portfolio report polish, Layer 2 market open/closed/unknown session truth, and Layer 3 broker specs/value/advisory metadata cleanup for Layer 2 known open and closed symbols. Unknown symbols may stop earlier. No Layer 4 live quote freshness, ranking, selection, alerts, strategy, Python worker, or trade execution.";
static const string AC_UPGRADE_TEST_PLAN  = "Compile AuroraCore.mq5; run EA; confirm Dossiers hide empty Exchange/Sector/Industry/Country lines, omit ISIN entirely, display only non-empty broker advisory metadata, keep workbook/Runtime 2 taxonomy as bucket authority, and render HK Yahoo links as zero-padded .HK symbols such as 0001.HK.";
static const string AC_LOGGING_POLICY     = "near_instant_board_write_if_changed_plus_l3_final_metadata_cleanup";
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
static const string AC_DOSSIER_SHELL_SCHEMA_VERSION = "dossier_v1.035_l3_final_metadata_cleanup";
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