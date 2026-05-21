#ifndef AC_CONFIG_MQH
#define AC_CONFIG_MQH

static const string AC_SYSTEM_NAME        = "AURORA CORE";
static const string AC_BUILD_PHASE        = "board_dossier_shell_foundation";
static const string AC_BUILD_VERSION      = "0.020";
static const string AC_UPGRADE_ID         = "BOARD_DOSSIER_SHELL_FOUNDATION";
static const string AC_UPGRADE_SUMMARY    = "Adds the L0 trader Board, renderer/status spine, and bounded Unknown Dossier shell fill so the broker universe can start publishing without Board-side statistics bloat.";
static const string AC_UPGRADE_SCOPE      = "Layer 0 publication and per-symbol Dossier shell foundation only; Board renders prepared L0 status, Workbench carries developer detail, Dossiers fill under Unknown in bounded batches; no open/closed classification, no specs, no quotes, no ranking, no selection, no alerts, no strategy, no Python worker, and no trade execution.";
static const string AC_UPGRADE_TEST_PLAN  = "Compile AuroraCore.mq5; smoke Market Board.txt, Workbench/Status.txt, Manifest.txt, Micro Log.txt, and bounded Dossiers/Unknown/<symbol>.txt shell creation; verify Board shows L0 symbol shell coverage only and does not claim Layer 2 open/closed, ranking, selection, or permission.";
static const string AC_LOGGING_POLICY     = "bounded_snapshot_plus_major_phase_timing_not_append_spam";
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
static const int    AC_TIMER_SECONDS      = 1;
static const int    AC_PUBLICATION_INTERVAL_HEARTBEATS = 5;
static const int    AC_DOSSIER_SHELL_BATCH_SIZE = 25;
static const uint   AC_TIMER_BUDGET_MS    = 250;
static const bool   AC_USE_COMMON_FILES   = true;

#endif