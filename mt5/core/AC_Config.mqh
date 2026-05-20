#ifndef AC_CONFIG_MQH
#define AC_CONFIG_MQH

static const string AC_SYSTEM_NAME        = "AURORA CORE";
static const string AC_BUILD_PHASE        = "runtime_0_first_source_slice";
static const string AC_BUILD_VERSION      = "0.011";
static const string AC_UPGRADE_ID         = "RUN011_RUNTIME0_LIGHTWEIGHT_UPGRADE_LOGGING";
static const string AC_UPGRADE_SUMMARY    = "Adds bounded Workbench upgrade audit logging and final-state publication cleanup for Runtime 0.";
static const string AC_UPGRADE_SCOPE      = "Runtime 0 governance plus Runtime 7 publication support only; no Runtime 1, symbols, ranking, alerts, strategy, worker, or trading logic.";
static const string AC_UPGRADE_TEST_PLAN  = "Compile AuroraCore.mq5; runtime smoke Runtime Status, Manifest, Status, Diagnostics, Upgrade Log; verify no stale not_attempted final states.";
static const string AC_LOGGING_POLICY     = "bounded_snapshot_rewrite_not_append_spam";
static const string AC_RUNTIME0_OWNER     = "Runtime 0 - Governance / Internal Control Owner";
static const string AC_RUNTIME7_OWNER     = "Runtime 7 - Publication Owner";
static const string AC_LAYER_0_1_NAME     = "Layer 0.1 - Startup / Runtime Identity";
static const string AC_LAYER_0_2_NAME     = "Layer 0.2 - Scheduler / Heartbeat / Breathing Spine";
static const string AC_LAYER_0_4_NAME     = "Layer 0.4 - Governance / Manifest / Telemetry";
static const string AC_BASE_FOLDER        = "Aurora Core";
static const string AC_WORKBENCH_FOLDER   = "Workbench";
static const int    AC_TIMER_SECONDS      = 1;
static const uint   AC_TIMER_BUDGET_MS    = 250;
static const bool   AC_USE_COMMON_FILES   = true;

#endif