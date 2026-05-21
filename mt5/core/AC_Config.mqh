#ifndef AC_CONFIG_MQH
#define AC_CONFIG_MQH

static const string AC_SYSTEM_NAME        = "AURORA CORE";
static const string AC_BUILD_PHASE        = "board_dossier_shell_foundation_fast_universe";
static const string AC_BUILD_VERSION      = "0.021";
static const string AC_UPGRADE_ID         = "L0_FAST_UNIVERSE_SHELL_FILL";
static const string AC_UPGRADE_SUMMARY    = "Removes artificial L0 dossier-shell throttling so the broker symbol universe fills as fast as MT5/FileIO allows, with bounded retries and failure addendum reporting.";
static const string AC_UPGRADE_SCOPE      = "Layer 0 publication and per-symbol Dossier shell foundation only; full broker universe shell fill runs immediately instead of waiting on timer batches; Board renders L0 status, Workbench carries developer detail, failed symbol data packets are recorded as addendum text; no open/closed classification, no specs, no quotes, no ranking, no selection, no alerts, no strategy, no Python worker, and no trade execution.";
static const string AC_UPGRADE_TEST_PLAN  = "Compile AuroraCore.mq5; smoke Market Board.txt, Workbench/Status.txt, Manifest.txt, Micro Log.txt, and Dossiers/Unknown/<symbol>.txt universe creation; verify L0 attempts all broker symbols immediately, records failed symbol packets without blocking, and does not claim Layer 2 open/closed, ranking, selection, or permission.";
static const string AC_LOGGING_POLICY     = "bounded_snapshot_plus_failed_packet_addendum_not_symbol_loop_spam";
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
static const int    AC_DOSSIER_SHELL_WRITE_RETRIES = 3;
static const uint   AC_TIMER_BUDGET_MS    = 250;
static const bool   AC_USE_COMMON_FILES   = true;

#endif