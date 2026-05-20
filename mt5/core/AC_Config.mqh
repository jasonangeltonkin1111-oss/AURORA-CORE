#ifndef AC_CONFIG_MQH
#define AC_CONFIG_MQH

static const string AC_SYSTEM_NAME        = "AURORA CORE";
static const string AC_BUILD_PHASE        = "runtime_1_layer_1_micro_logging_and_placeholder_routes";
static const string AC_BUILD_VERSION      = "0.014";
static const string AC_UPGRADE_ID         = "RUN014_MICRO_LOGGING_AND_PLACEHOLDER_ROUTES";
static const string AC_UPGRADE_SUMMARY    = "Adds bounded micro function timing logs, upgrade addendum snapshot, and placeholder route folders for Dossiers plus Selection Top folders.";
static const string AC_UPGRADE_SCOPE      = "Runtime 0 governance logging, Runtime 7 route placeholders, and Runtime 1 Layer 1 account truth only; no symbol scan, dossier content, ranking, selection logic, alerts, strategy, worker, or trade execution.";
static const string AC_UPGRADE_TEST_PLAN  = "Compile AuroraCore.mq5; smoke Runtime Status, Account Status, Manifest, Status, Diagnostics, Upgrade Log, Upgrade Addendum, Micro Log, Dossier placeholders, and Selection placeholders.";
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
static const string AC_SELECTION_FOLDER   = "Selection";
static const int    AC_TIMER_SECONDS      = 1;
static const int    AC_PUBLICATION_INTERVAL_HEARTBEATS = 5;
static const uint   AC_TIMER_BUDGET_MS    = 250;
static const bool   AC_USE_COMMON_FILES   = true;

#endif
