#ifndef AC_CONFIG_MQH
#define AC_CONFIG_MQH

static const string AC_SYSTEM_NAME        = "AURORA CORE";
static const string AC_BUILD_PHASE        = "l0_near_instant_board_cached_universe";
static const string AC_BUILD_VERSION      = "0.022";
static const string AC_UPGRADE_ID         = "L0_NEAR_INSTANT_BOARD_CACHED_UNIVERSE";
static const string AC_UPGRADE_SUMMARY    = "Makes Layer 0 complete as a fast symbol-universe shell pass with cached completion and near-instant atomic Board/status refresh without re-running the full universe every timer event.";
static const string AC_UPGRADE_SCOPE      = "Layer 0 publication and per-symbol Dossier shell foundation only; full broker universe shell fill runs immediately on first pass or symbol-count change, then Board/Workbench refresh from the L0 status packet; failed symbol data packets are recorded as addendum text; no open/closed classification, no specs, no quotes, no ranking, no selection, no alerts, no strategy, no Python worker, and no trade execution.";
static const string AC_UPGRADE_TEST_PLAN  = "Compile AuroraCore.mq5; smoke Market Board.txt near-instant refresh, Workbench/Status.txt, Manifest.txt, Micro Log.txt, and Dossiers/Unknown/<symbol>.txt universe creation; verify full L0 shell universe is not re-written every timer event, failed packets report in addendum, and no Layer 2 open/closed, ranking, selection, or permission is claimed.";
static const string AC_LOGGING_POLICY     = "near_instant_board_snapshot_plus_failed_packet_addendum_not_symbol_loop_spam";
static const string AC_RUNTIME0_OWNER     = "Runtime 0 - Governance / Internal Control Owner";
static const string AC_RUNTIME1_OWNER     = "Runtime 1 - Foundation Truth Owner";
static const string AC_PUBLICATION_SERVICE_OWNER = "Publication / FileIO / Route Service";
static const string AC_BOARD_DOSSIER_RENDERER_OWNER = "Board / Dossier Renderer Service";
static const string AC_LAYER_0_1_NAME     = "Layer 0.1 - Startup / Runtime Identity";
static const string AC_LAYER_0_2_NAME     = "Layer 0.2 - Scheduler / Heartbeat / Breathing Spine";
static const string AC_LAYER_0_4_NAME     = "Layer 0.4 - Governance / Manifest / Telemetry";
static const string AC_LAYER_0_BOARD_DOSSIER_NAME = "Layer 0 - Board + Dossier Shell Foundation";
static const string AC_LAYER_1_NAME       = "Layer 1 - Account / Portfolio / Prop Rule Truth";
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
static const uint   AC_TIMER_BUDGET_MS    = 250;
static const bool   AC_USE_COMMON_FILES   = true;

#endif