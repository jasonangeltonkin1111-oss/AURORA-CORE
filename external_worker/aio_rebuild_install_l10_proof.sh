#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
pass(){ echo "PASS|$1|$2"; }
fail(){ echo "FAIL|$1|$2"; }
warn(){ echo "WARN|$1|$2"; }
check_has(){ local name="$1" file="$2" pat="$3"; rg -q "$pat" "$file" && pass "$name" "$file" || fail "$name" "$file"; }
check_no_has(){ local name="$1" file="$2" pat="$3"; if rg -q "$pat" "$file"; then fail "$name" "$file"; else pass "$name" "$file"; fi }

echo "PASS|branch|$(git branch --show-current)"
echo "PASS|commit|$(git rev-parse HEAD)"

REQ=(
"external_worker/aurora_worker_l11.py"
"external_worker/aurora_worker_l11_dispatch.py"
"external_worker/aurora_worker_entrypoint.py"
"external_worker/AuroraWorker.spec"
"mt5/runtime_owners/runtime_7_publication_owner/publication_renderers/AC_Layer11SelectionGroupsRenderer.mqh"
"mt5/runtime_owners/runtime_7_publication_owner/publication_renderers/AC_MarketBoardRenderer.mqh"
"mt5/runtime_owners/runtime_7_publication_owner/publication_renderers/AC_Layer0DossierPublication.mqh"
"mt5/runtime_owners/runtime_7_publication_owner/publication_renderers/AC_PublicationRenderers.mqh"
"mt5/AuroraCore.mq5"
)
for f in "${REQ[@]}"; do [[ -f "$f" ]] && pass "source_exists" "$f" || fail "source_exists" "$f"; done

python -m py_compile external_worker/*.py && pass py_compile "external_worker/*.py" || fail py_compile "external_worker/*.py"

echo "COMPILE_NOT_RUN"

check_has l11_layer_route "external_worker/aurora_worker_l11.py" "Layer_11_Symbol_Ranking_Inside_Ranking_Group"
check_has l11_selection_groups_writer "external_worker/aurora_worker_l11.py" "Selection Desk"
check_has l11_group_index_txt "external_worker/aurora_worker_l11.py" "00_Group_Index.txt"
check_has l11_group_index_csv "external_worker/aurora_worker_l11.py" "00_Group_Index.csv"
check_has l11_dispatch_called "external_worker/aurora_worker_entrypoint.py" "run_l11_after_core"
check_has l11_package_hiddenimport "external_worker/AuroraWorker.spec" "aurora_worker_l11"
check_has l11_fn_board "${REQ[4]}" "AC_Layer11BoardSection\\("
check_has l11_fn_dossier "${REQ[4]}" "AC_Layer11DossierSection\\("
check_has l11_fn_workbench "${REQ[4]}" "AC_Layer11WorkbenchSection\\("
check_has marketboard_calls_l11 "${REQ[5]}" "AC_Layer11BoardSection\\("
check_has workbench_calls_l11 "${REQ[5]}" "AC_Layer11WorkbenchSection\\("
check_has publication_includes_l11 "${REQ[7]}" "AC_Layer11SelectionGroupsRenderer.mqh"
check_has dossier_composition_wrapper "${REQ[7]}" "AC_Layer11AndSharedOhlcRenderDossierSection"
check_has dossier_wrapper_appends_l11 "${REQ[7]}" "AC_Layer11DossierSection\\(symbol\\)"
check_has dossier_macro_bridge "${REQ[7]}" "#define AC_SharedOhlcRenderDossierSection AC_Layer11AndSharedOhlcRenderDossierSection"

for f in external_worker/aurora_worker_l11.py external_worker/aurora_worker_l11_dispatch.py mt5/runtime_owners/runtime_7_publication_owner/publication_renderers/AC_Layer11SelectionGroupsRenderer.mqh; do
  check_has false_selection_runtime "$f" "selection_runtime=false"
  check_has false_trade_permission "$f" "trade_permission=false"
  check_has false_entry_signal "$f" "entry_signal=false"
  check_has false_execution "$f" "execution=false"
  check_no_has forbidden_bucket_top5 "$f" "bucket_top5|sub_bucket_top5|Top 5 Per Bucket|major_bucket|minor_bucket|aggregation_group"
done

COMMON_ROOT="${APPDATA:-}/MetaQuotes/Terminal/Common/Files/Aurora Core"
if [[ -z "${APPDATA:-}" ]]; then
  warn mt5_runtime_checks "APPDATA missing; skipped MT5 Common Files runtime proof checks"
else
  if [[ -d "$COMMON_ROOT" ]]; then pass mt5_common_root "$COMMON_ROOT"; else warn mt5_common_root "missing: $COMMON_ROOT"; fi
  group_index_txt="$(find "$COMMON_ROOT" -path '*/Selection Desk/Groups/00_Group_Index.txt' -type f | head -n 1 || true)"
  group_index_csv="$(find "$COMMON_ROOT" -path '*/Selection Desk/Groups/00_Group_Index.csv' -type f | head -n 1 || true)"
  group_txt="$(find "$COMMON_ROOT" -path '*/Selection Desk/Groups/*.txt' ! -name '00_Group_Index.txt' -type f | head -n 1 || true)"
  group_csv="$(find "$COMMON_ROOT" -path '*/Selection Desk/Groups/*.csv' ! -name '00_Group_Index.csv' -type f | head -n 1 || true)"
  [[ -n "$group_index_txt" ]] && pass selection_groups_index_txt "$group_index_txt" || fail selection_groups_index_txt "missing"
  [[ -n "$group_index_csv" ]] && pass selection_groups_index_csv "$group_index_csv" || fail selection_groups_index_csv "missing"
  [[ -n "$group_txt" ]] && pass selection_group_txt "$group_txt" || fail selection_group_txt "missing"
  [[ -n "$group_csv" ]] && pass selection_group_csv "$group_csv" || fail selection_group_csv "missing"
fi

board_file="$(find "$ROOT/external_worker" -type f -name 'Market_Board*.txt' | head -n 1 || true)"
dossier_file="$(find "$ROOT/external_worker" -type f -name 'Dossier_Open_*.txt' | head -n 1 || true)"
workbench_file="$(find "$ROOT/external_worker" -type f -iname '*surface_overseer*.txt' | head -n 1 || true)"

if [[ -n "$board_file" ]]; then check_has board_l11_title "$board_file" "LAYER 11 - SYMBOL RANKING INSIDE RANKING GROUP"; else warn board_visual_proof "Market_Board*.txt missing; run MT5 after rebuild"; fi
if [[ -n "$dossier_file" ]]; then check_has dossier_l11_header "$dossier_file" "LAYER 11 - SYMBOL RANKING INSIDE RANKING GROUP"; else warn dossier_visual_proof "Dossier_Open_*.txt missing; run MT5 after rebuild"; fi
if [[ -n "$workbench_file" ]]; then check_has wb_l11_key "$workbench_file" "schema_name=l11_symbol_ranking_inside_group"; else warn workbench_visual_proof "*surface_overseer*.txt missing; run MT5 after rebuild"; fi
