#ifndef AC_CONFIG_MQH
#define AC_CONFIG_MQH

static const string AC_SYSTEM_NAME        = "AURORA CORE";
static const string AC_BUILD_PHASE        = "runtime2_universe_owner_skeleton";
static const string AC_BUILD_VERSION      = "0.018";
static const string AC_UPGRADE_ID         = "RUNTIME2_UNIVERSE_OWNER_SKELETON";
static const string AC_UPGRADE_SUMMARY    = "Adds the Runtime 2 Market Universe / Taxonomy Lookup Owner skeleton and publishes lookup-only diagnostics without importing the 1703-row universe yet.";
static const string AC_UPGRADE_SCOPE      = "Runtime 2 skeleton owner, schema/count diagnostics, and documentation alignment only; no generated universe rows, no taxonomy runtime load, no ranking, no selection logic, no alerts, no strategy, no worker, and no trade execution.";
static const string AC_UPGRADE_TEST_PLAN  = "Compile AuroraCore.mq5; smoke Workbench diagnostics/status output; verify universe loaded_row_count=0, expected_row_count=1703, old_field_names_active=false, and runtime_permission=LOOKUP_ONLY_NOT_TRADE_PERMISSION.";
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
static const string AC_RANKING_GROUP_TOP5_FOLDER = "Ranking Group Top 5";
static const string AC_GLOBAL_TOP10_FOLDER = "Global Top 10";
static const int    AC_TIMER_SECONDS      = 1;
static const int    AC_PUBLICATION_INTERVAL_HEARTBEATS = 5;
static const uint   AC_TIMER_BUDGET_MS    = 250;
static const bool   AC_USE_COMMON_FILES   = true;

#endif