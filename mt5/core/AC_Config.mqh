#ifndef AC_CONFIG_MQH
#define AC_CONFIG_MQH

static const string AC_SYSTEM_NAME        = "AURORA CORE";
static const string AC_BUILD_PHASE        = "selection_desk_stable_parent_routes";
static const string AC_BUILD_VERSION      = "0.019";
static const string AC_UPGRADE_ID         = "SELECTION_DESK_STABLE_PARENT_ROUTES";
static const string AC_UPGRADE_SUMMARY    = "Stabilizes Selection Desk parent folders as Groups and Global so Top/Rank numbering remains child file content rather than route ownership.";
static const string AC_UPGRADE_SCOPE      = "Stable Selection Desk parent routes, placeholder labels, diagnostics, and documentation alignment only; no generated universe rows, no taxonomy runtime load, no ranking, no selection logic, no alerts, no strategy, no worker, and no trade execution.";
static const string AC_UPGRADE_TEST_PLAN  = "Compile AuroraCore.mq5; smoke Selection Desk/Groups and Selection Desk/Global placeholders; verify rank/top numbering is not used in parent folder names and runtime_permission remains LOOKUP_ONLY_NOT_TRADE_PERMISSION.";
static const string AC_LOGGING_POLICY     = "bounded_snapshot_plus_upgrade_addendum_not_append_spam";
static const string AC_RUNTIME0_OWNER     = "Runtime 0 - Governance / Internal Control Owner";
static const string AC_RUNTIME1_OWNER     = "Runtime 1 - Foundation Truth Owner";
static const string AC_RUNTIME7_OWNER     = "Runtime 7 - Publication Owner";
static const string AC_LAYER_0_1_NAME     = "Layer 0.1 - Startup / Runtime Identity";
static const string AC_LAYER_0_2_NAME     = "Layer 0.2 - Scheduler / Heartbeat / Breathing Spine";
static const string AC_LAYER_0_4_NAME     = "Layer 0.4 - Governance / Manifest / Telemetry";
static const string AC_LAYER_1_NAME       = "Layer 1 - Account / Portfolio / Prop Rule Truth";
static const string AC_BASE_FOLDER        = "Aurora Core";
static const string AC_WORKBENCH_FOLDER   = "Workbench";
static const string AC_DOSSIERS_FOLDER    = "Dossiers";
static const string AC_SELECTION_FOLDER   = "Selection Desk";
static const string AC_SELECTION_GROUPS_FOLDER = "Groups";
static const string AC_SELECTION_GLOBAL_FOLDER = "Global";
static const int    AC_TIMER_SECONDS      = 1;
static const int    AC_PUBLICATION_INTERVAL_HEARTBEATS = 5;
static const uint   AC_TIMER_BUDGET_MS    = 250;
static const bool   AC_USE_COMMON_FILES   = true;

#endif