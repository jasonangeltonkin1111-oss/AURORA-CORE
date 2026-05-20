#ifndef AC_CONFIG_MQH
#define AC_CONFIG_MQH

static const string AC_SYSTEM_NAME        = "AURORA CORE";
static const string AC_BUILD_PHASE        = "runtime_0_first_source_slice";
static const string AC_BUILD_VERSION      = "0.012";
static const string AC_UPGRADE_ID         = "RUN012_RUNTIME0_LOGGING_REPAIR_FINALITY";
static const string AC_UPGRADE_SUMMARY    = "Repairs half-patched RUN011 state, final-state publication, timer setup evidence, and bounded Workbench upgrade logging.";
static const string AC_UPGRADE_SCOPE      = "Runtime 0 governance plus Runtime 7 publication support only.";
static const string AC_UPGRADE_TEST_PLAN  = "Compile AuroraCore.mq5; smoke Runtime Status, Manifest, Status, Diagnostics, Upgrade Log; verify final statuses are not stale.";
static const string AC_LOGGING_POLICY     = "bounded_snapshot_rewrite_not_append_spam";
static const string AC_RUNTIME0_OWNER     = "Runtime 0 - Governance / Internal Control Owner";
static const string AC_RUNTIME7_OWNER     = "Runtime 7 - Publication Owner";
static const string AC_LAYER_0_1_NAME     = "Layer 0.1 - Startup / Runtime Identity";
static const string AC_LAYER_0_2_NAME     = "Layer 0.2 - Scheduler / Heartbeat / Breathing Spine";
static const string AC_LAYER_0_4_NAME     = "Layer 0.4 - Governance / Manifest / Telemetry";
static const string AC_BASE_FOLDER        = "Aurora Core";
static const string AC_WORKBENCH_FOLDER   = "Workbench";
static const int    AC_TIMER_SECONDS      = 1;
static const int    AC_PUBLICATION_INTERVAL_HEARTBEATS = 5;
static const uint   AC_TIMER_BUDGET_MS    = 250;
static const bool   AC_USE_COMMON_FILES   = true;

#endif
