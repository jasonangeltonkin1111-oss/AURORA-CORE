#ifndef AC_CONFIG_MQH
#define AC_CONFIG_MQH

static const string AC_SYSTEM_NAME        = "AURORA CORE";
static const string AC_BUILD_PHASE        = "runtime_1_layer_1_account_truth_slice";
static const string AC_BUILD_VERSION      = "0.013";
static const string AC_UPGRADE_ID         = "RUN013_RUNTIME1_LAYER1_ACCOUNT_TRUTH";
static const string AC_UPGRADE_SUMMARY    = "Adds Runtime 1 Layer 1 account and portfolio truth publication after Runtime 0 smoke proof.";
static const string AC_UPGRADE_SCOPE      = "Runtime 1 Layer 1 account/portfolio truth only, using Runtime 7 publication and Runtime 0 governance manifest support.";
static const string AC_UPGRADE_TEST_PLAN  = "Compile AuroraCore.mq5; smoke Runtime Status, Manifest, Status, Diagnostics, Upgrade Log, Account Status; verify no trading, symbols, ranking, alerts, strategy, or external worker logic.";
static const string AC_LOGGING_POLICY     = "bounded_snapshot_rewrite_not_append_spam";
static const string AC_RUNTIME0_OWNER     = "Runtime 0 - Governance / Internal Control Owner";
static const string AC_RUNTIME1_OWNER     = "Runtime 1 - Foundation Truth Owner";
static const string AC_RUNTIME7_OWNER     = "Runtime 7 - Publication Owner";
static const string AC_LAYER_0_1_NAME     = "Layer 0.1 - Startup / Runtime Identity";
static const string AC_LAYER_0_2_NAME     = "Layer 0.2 - Scheduler / Heartbeat / Breathing Spine";
static const string AC_LAYER_0_4_NAME     = "Layer 0.4 - Governance / Manifest / Telemetry";
static const string AC_LAYER_1_NAME       = "Layer 1 - Account / Portfolio / Prop Rule Truth";
static const string AC_BASE_FOLDER        = "Aurora Core";
static const string AC_WORKBENCH_FOLDER   = "Workbench";
static const int    AC_TIMER_SECONDS      = 1;
static const int    AC_PUBLICATION_INTERVAL_HEARTBEATS = 5;
static const uint   AC_TIMER_BUDGET_MS    = 250;
static const bool   AC_USE_COMMON_FILES   = true;

#endif
