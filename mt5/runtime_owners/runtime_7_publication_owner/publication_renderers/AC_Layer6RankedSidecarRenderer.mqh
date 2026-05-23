#ifndef AC_LAYER6_RANKED_SIDECAR_RENDERER_MQH
#define AC_LAYER6_RANKED_SIDECAR_RENDERER_MQH

#include "../../runtime_3_external_calculation_worker_owner/AC_ExternalWorkerRenderIndex.mqh"

// Renders prepared owner/status packets only. It must not compute trading truth,
// selection, market-open state, broker specs, quotes, or permission.
// L6-E reads tiny Gateway sidecar proof files only: manifest, top20, and one per-symbol rank file.
// It must not parse the full ranked_symbols.csv in the MT5 heartbeat/dossier loop.
static string AC_RUNTIME4_OWNER = "Runtime 4 - Surface Scoring Owner";
static string AC_LAYER_6_NAME = "Layer 6 - Cost / Friction Ranking";
static string AC_L6_STATUS = "Pending ranked sidecar";
static string AC_L6_TRUST_STATE = "Ranking Pending";
static string AC_L6_VALIDATION_STATUS = "Pending";
static string AC_L6_VALIDATION_REASON = "ranked sidecar not checked yet";
static string AC_L6_MAIN_BLOCKER = "ranked_symbols.manifest has not been accepted yet";
static string AC_L6_JOB_TYPE = "L6_COST_FRICTION_RANKING_V1";
static string AC_L6_EXPECTED_OUTPUT = "ranked_symbols_csv_manifest_top20_symbol_rank_sidecars";
static string AC_L6_RANKED_CSV_PATH = "Outbox\\Layers\\Layer_6_Cost_Friction_Ranking\\ranked_symbols.csv";
static string AC_L6_RANKED_MANIFEST_PATH = "Outbox\\Layers\\Layer_6_Cost_Friction_Ranking\\ranked_symbols.manifest";
static string AC_L6_TOP20_PATH = "Outbox\\Layers\\Layer_6_Cost_Friction_Ranking\\ranked_symbols_top20.txt";
static string AC_L6_SYMBOL_RANK_FOLDER = "Outbox\\Layers\\Layer_6_Cost_Friction_Ranking\\SymbolRanks";
static string AC_L6_SYMBOL_RANK_FILENAME_MODE_EXPECTED = "sanitized_symbol__payload_checksum";
static string AC_L6_MANIFEST_PAYLOAD_CHECKSUM = "not_available";
static string AC_L6_MANIFEST_STATUS = "not_loaded";
static string AC_L6_MANIFEST_REASON = "not_loaded";
static string AC_L6_MANIFEST_SYMBOL_RANK_FILENAME_MODE = "not_available";
static string AC_L6_TOP20_FIRST_LINE = "not_available";
static int AC_L6_INPUT_L5_PASS_SYMBOLS = 0;
static int AC_L6_MANIFEST_INPUT_COUNT = 0;
static int AC_L6_RANKED_SYMBOLS = 0;
static int AC_L6_RANKED_DEGRADED_SYMBOLS = 0;
static int AC_L6_NOT_RANKABLE_QUALITY_SYMBOLS = 0;
static int AC_L6_ELITE_FRICTION_COUNT = 0;
static int AC_L6_GOOD_FRICTION_COUNT = 0;
static int AC_L6_ACCEPTABLE_FRICTION_COUNT = 0;
static int AC_L6_EXPENSIVE_FRICTION_COUNT = 0;
static int AC_L6_HOSTILE_FRICTION_COUNT = 0;
static int AC_L6_ZERO_COST_SUSPICIOUS_COUNT = 0;
static int AC_L6_COST_MODEL_MISMATCH_COUNT = 0;
static int AC_L6_SYMBOL_RANK_FILES_WRITTEN = 0;
static int AC_L6_SYMBOL_RANK_FILES_ACTUAL = 0;