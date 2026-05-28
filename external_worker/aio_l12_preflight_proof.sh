#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
pass(){ echo "PASS|$1|$2"; }
fail(){ echo "FAIL|$1|$2"; exit 1; }
check_has(){ local name="$1" file="$2" pat="$3"; rg -q "$pat" "$file" && pass "$name" "$file" || fail "$name" "$file missing pattern: $pat"; }
check_no_has(){ local name="$1" file="$2" pat="$3"; if rg -q "$pat" "$file"; then fail "$name" "$file forbidden pattern: $pat"; else pass "$name" "$file"; fi }

echo "PASS|branch|$(git branch --show-current)"
echo "PASS|commit|$(git rev-parse HEAD)"

REQ=(
"docs/30_L12_RANKING_GROUP_HEAT_QUALITY_CONTROL.md"
"external_worker/aurora_worker_l12.py"
"external_worker/aurora_worker_l12_dispatch.py"
"external_worker/aurora_worker_entrypoint.py"
"external_worker/aurora_worker_surface_overseer.py"
"external_worker/AuroraWorker.spec"
"mt5/runtime_owners/runtime_7_publication_owner/publication_renderers/AC_Layer12GroupHeatQualityRenderer.mqh"
"mt5/runtime_owners/runtime_7_publication_owner/publication_renderers/AC_PublicationRenderers.mqh"
"mt5/runtime_owners/runtime_7_publication_owner/publication_renderers/AC_MarketBoardRenderer.mqh"
)
for f in "${REQ[@]}"; do [[ -f "$f" ]] && pass source_exists "$f" || fail source_exists "$f missing"; done

python -m py_compile external_worker/aurora_worker_l12.py external_worker/aurora_worker_l12_dispatch.py external_worker/aurora_worker_surface_overseer.py external_worker/aurora_worker_entrypoint.py && pass py_compile "l12/overseer/entrypoint" || fail py_compile "l12/overseer/entrypoint"

check_has l12_worker_route external_worker/aurora_worker_l12.py "Layer_12_Ranking_Group_Heat_Quality"
check_has l12_worker_summary external_worker/aurora_worker_l12.py "l12_group_heat_quality_summary.txt"
check_has l12_worker_heat_csv external_worker/aurora_worker_l12.py "l12_group_heat_quality.csv"
check_has l12_worker_manifest external_worker/aurora_worker_l12.py "l12_group_heat_quality.manifest"
check_has l12_worker_selection_index external_worker/aurora_worker_l12.py "00_Group_Heat_Quality_Index"
check_has l12_distribution_report external_worker/aurora_worker_l12_dispatch.py "l12_component_distribution_by_group.csv"
check_has l12_thin_report external_worker/aurora_worker_l12_dispatch.py "l12_thin_group_warnings.csv"
check_has l12_entrypoint_dispatch external_worker/aurora_worker_entrypoint.py "run_l12_after_l11"
check_has l13_runtime_default_off external_worker/aurora_worker_entrypoint.py "ENABLE_L13_RUNTIME = False"
check_has l13_surface_gate external_worker/aurora_worker_entrypoint.py "l13_runtime_enabled="
check_has l12_spec_hiddenimport external_worker/AuroraWorker.spec "aurora_worker_l12"
check_has l12_dispatch_hiddenimport external_worker/AuroraWorker.spec "aurora_worker_l12_dispatch"
check_has recorder_hiddenimport external_worker/AuroraWorker.spec "aurora_worker_recorder"
check_has overseer_hiddenimport external_worker/AuroraWorker.spec "aurora_worker_surface_overseer"
check_has l12_renderer_include mt5/runtime_owners/runtime_7_publication_owner/publication_renderers/AC_PublicationRenderers.mqh "AC_Layer12GroupHeatQualityRenderer.mqh"
check_has l12_board_call mt5/runtime_owners/runtime_7_publication_owner/publication_renderers/AC_MarketBoardRenderer.mqh "AC_Layer12BoardSection"
check_has l12_workbench_call mt5/runtime_owners/runtime_7_publication_owner/publication_renderers/AC_MarketBoardRenderer.mqh "AC_Layer12WorkbenchSection"
check_has l12_dossier_call mt5/runtime_owners/runtime_7_publication_owner/publication_renderers/AC_PublicationRenderers.mqh "AC_Layer12DossierSection"
check_has l12_overseer_manifest external_worker/aurora_worker_surface_overseer.py "l12_group_heat_quality.manifest"
check_has l11_overseer_manifest external_worker/aurora_worker_surface_overseer.py "ranked_symbols_by_group.manifest"

for f in docs/30_L12_RANKING_GROUP_HEAT_QUALITY_CONTROL.md external_worker/aurora_worker_l12.py external_worker/aurora_worker_l12_dispatch.py mt5/runtime_owners/runtime_7_publication_owner/publication_renderers/AC_Layer12GroupHeatQualityRenderer.mqh; do
  check_has false_selection_runtime "$f" "selection_runtime=false|Selection Runtime: FALSE"
  check_has false_trade_permission "$f" "trade_permission=false|Trade Permission: FALSE"
  check_has false_entry_signal "$f" "entry_signal=false|Entry Signal: FALSE"
  check_has false_execution "$f" "execution=false|Execution: FALSE"
done

for f in external_worker/aurora_worker_l12.py external_worker/aurora_worker_l12_dispatch.py mt5/runtime_owners/runtime_7_publication_owner/publication_renderers/AC_Layer12GroupHeatQualityRenderer.mqh; do
  check_no_has forbidden_l12_authority "$f" "trade_permission=true|entry_signal=true|execution=true|selection_runtime=true"
done

pass l12_preflight "source gate passed; runtime proof still requires rebuild + MT5 run"
