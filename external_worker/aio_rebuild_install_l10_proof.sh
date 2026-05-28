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
"external_worker/aurora_worker_l11_cleanup.py"
"external_worker/aurora_worker_l11_dispatch.py"
"external_worker/aurora_worker_l11_dossier_copy.py"
"external_worker/aurora_worker_l11_tree.py"
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
check_has l11_cleanup_helper "external_worker/aurora_worker_l11_cleanup.py" "cleanup_l11_stale_symbol_rank_sidecars"
check_has l11_dossier_copy_helper "external_worker/aurora_worker_l11_dossier_copy.py" "copy_l11_tree_rank_files_from_dossiers"
check_has l11_dossier_copy_dispatch "external_worker/aurora_worker_l11_dispatch.py" "copy_l11_tree_rank_files_from_dossiers"
check_has l11_tree_module "external_worker/aurora_worker_l11_tree.py" "publish_l11_selection_desk_taxonomy_tree"
check_has l11_tree_status "external_worker/aurora_worker_l11_tree.py" "00_Taxonomy_Tree_Status.txt"
check_has l11_tree_txt "external_worker/aurora_worker_l11_tree.py" "00_Taxonomy_Tree.txt"
check_has l11_tree_csv "external_worker/aurora_worker_l11_tree.py" "00_Taxonomy_Tree.csv"
check_has l11_tree_group_summary "external_worker/aurora_worker_l11_tree.py" "00_Group_Summary.txt"
check_has l11_tree_ranked_symbols "external_worker/aurora_worker_l11_tree.py" "00_Group_Ranked_Symbols.csv"
check_has l11_tree_top5_txt "external_worker/aurora_worker_l11_tree.py" "00_Top5_Current.txt"
check_has l11_tree_top5_csv "external_worker/aurora_worker_l11_tree.py" "00_Top5_Current.csv"
check_has l11_tree_dispatch_called "external_worker/aurora_worker_l11_dispatch.py" "publish_l11_selection_desk_taxonomy_tree"
check_has l11_dispatch_called "external_worker/aurora_worker_entrypoint.py" "run_l11_after_core"
check_has l11_package_hiddenimport "external_worker/AuroraWorker.spec" "aurora_worker_l11"
check_has l11_cleanup_hiddenimport "external_worker/AuroraWorker.spec" "aurora_worker_l11_cleanup"
check_has l11_dossier_copy_hiddenimport "external_worker/AuroraWorker.spec" "aurora_worker_l11_dossier_copy"
check_has l11_tree_hiddenimport "external_worker/AuroraWorker.spec" "aurora_worker_l11_tree"
check_has l11_fn_board "${REQ[7]}" "AC_Layer11BoardSection\\("
check_has l11_fn_dossier "${REQ[7]}" "AC_Layer11DossierSection\\("
check_has l11_fn_workbench "${REQ[7]}" "AC_Layer11WorkbenchSection\\("
check_has marketboard_calls_l11 "${REQ[8]}" "AC_Layer11BoardSection\\("
check_has workbench_calls_l11 "${REQ[8]}" "AC_Layer11WorkbenchSection\\("
check_has publication_includes_l11 "${REQ[10]}" "AC_Layer11SelectionGroupsRenderer.mqh"
check_has dossier_composition_wrapper "${REQ[10]}" "AC_Layer11AndSharedOhlcRenderDossierSection"
check_has dossier_wrapper_appends_l11 "${REQ[10]}" "AC_Layer11DossierSection\\(symbol\\)"
check_has dossier_macro_bridge "${REQ[10]}" "#define AC_SharedOhlcRenderDossierSection AC_Layer11AndSharedOhlcRenderDossierSection"

for f in external_worker/aurora_worker_l11.py external_worker/aurora_worker_l11_cleanup.py external_worker/aurora_worker_l11_dispatch.py external_worker/aurora_worker_l11_dossier_copy.py external_worker/aurora_worker_l11_tree.py mt5/runtime_owners/runtime_7_publication_owner/publication_renderers/AC_Layer11SelectionGroupsRenderer.mqh; do
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
  tree_status="$(find "$COMMON_ROOT" -path '*/Selection Desk/Groups/00_Taxonomy_Tree_Status.txt' -type f | head -n 1 || true)"
  tree_txt="$(find "$COMMON_ROOT" -path '*/Selection Desk/Groups/00_Taxonomy_Tree.txt' -type f | head -n 1 || true)"
  tree_csv="$(find "$COMMON_ROOT" -path '*/Selection Desk/Groups/00_Taxonomy_Tree.csv' -type f | head -n 1 || true)"
  group_summary="$(find "$COMMON_ROOT" -path '*/Selection Desk/Groups/*/*/*/*/00_Group_Summary.txt' -type f | head -n 1 || true)"
  group_ranked="$(find "$COMMON_ROOT" -path '*/Selection Desk/Groups/*/*/*/*/00_Group_Ranked_Symbols.csv' -type f | head -n 1 || true)"
  top5_txt="$(find "$COMMON_ROOT" -path '*/Selection Desk/Groups/*/*/*/*/00_Top5_Current.txt' -type f | head -n 1 || true)"
  top5_csv="$(find "$COMMON_ROOT" -path '*/Selection Desk/Groups/*/*/*/*/00_Top5_Current.csv' -type f | head -n 1 || true)"
  rank_file="$(find "$COMMON_ROOT" -path '*/Selection Desk/Groups/*/*/*/*/[0-9][0-9]_*.txt' -type f | head -n 1 || true)"
  [[ -n "$group_index_txt" ]] && pass selection_groups_index_txt "$group_index_txt" || fail selection_groups_index_txt "missing"
  [[ -n "$group_index_csv" ]] && pass selection_groups_index_csv "$group_index_csv" || fail selection_groups_index_csv "missing"
  [[ -n "$tree_status" ]] && pass taxonomy_tree_status "$tree_status" || fail taxonomy_tree_status "missing"
  [[ -n "$tree_txt" ]] && pass taxonomy_tree_txt "$tree_txt" || fail taxonomy_tree_txt "missing"
  [[ -n "$tree_csv" ]] && pass taxonomy_tree_csv "$tree_csv" || fail taxonomy_tree_csv "missing"
  [[ -n "$group_summary" ]] && pass taxonomy_group_summary "$group_summary" || fail taxonomy_group_summary "missing"
  [[ -n "$group_ranked" ]] && pass taxonomy_group_ranked "$group_ranked" || fail taxonomy_group_ranked "missing"
  [[ -n "$top5_txt" ]] && pass taxonomy_group_top5_txt "$top5_txt" || fail taxonomy_group_top5_txt "missing"
  [[ -n "$top5_csv" ]] && pass taxonomy_group_top5_csv "$top5_csv" || fail taxonomy_group_top5_csv "missing"
  [[ -n "$rank_file" ]] && pass taxonomy_rank_file "$rank_file" || fail taxonomy_rank_file "missing"
  if [[ -n "$rank_file" ]]; then
    check_no_has taxonomy_rank_file_not_stub "$rank_file" "^L11 RANK CARD$"
    check_has taxonomy_rank_file_dossier_content "$rank_file" "AURORA CORE|DOSSIER|LAYER 11 - SYMBOL RANKING INSIDE RANKING GROUP"
  fi
fi

board_file="$(find "$ROOT/external_worker" -type f -name 'Market_Board*.txt' | head -n 1 || true)"
dossier_file="$(find "$ROOT/external_worker" -type f -name 'Dossier_Open_*.txt' | head -n 1 || true)"
workbench_file="$(find "$ROOT/external_worker" -type f -iname '*surface_overseer*.txt' | head -n 1 || true)"

if [[ -n "$board_file" ]]; then check_has board_l11_title "$board_file" "LAYER 11 - SYMBOL RANKING INSIDE RANKING GROUP"; else warn board_visual_proof "Market_Board*.txt missing; run MT5 after rebuild"; fi
if [[ -n "$dossier_file" ]]; then check_has dossier_l11_header "$dossier_file" "LAYER 11 - SYMBOL RANKING INSIDE RANKING GROUP"; else warn dossier_visual_proof "Dossier_Open_*.txt missing; run MT5 after rebuild"; fi
if [[ -n "$workbench_file" ]]; then check_has wb_l11_key "$workbench_file" "schema_name=l11_symbol_ranking_inside_group"; else warn workbench_visual_proof "*surface_overseer*.txt missing; run MT5 after rebuild"; fi
