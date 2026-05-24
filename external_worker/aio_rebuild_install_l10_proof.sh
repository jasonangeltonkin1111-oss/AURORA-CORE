#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
pass(){ echo "PASS|$1|$2"; }
fail(){ echo "FAIL|$1|$2"; }
warn(){ echo "WARN|$1|$2"; }
check_has(){ local name="$1" file="$2" pat="$3"; rg -q "$pat" "$file" && pass "$name" "$file" || fail "$name" "$file"; }

echo "PASS|branch|$(git branch --show-current)"
echo "PASS|commit|$(git rev-parse HEAD)"

REQ=(
"mt5/runtime_owners/runtime_7_publication_owner/publication_renderers/AC_Layer10TaxonomyRenderer.mqh"
"mt5/runtime_owners/runtime_7_publication_owner/publication_renderers/AC_MarketBoardRenderer.mqh"
"mt5/runtime_owners/runtime_7_publication_owner/publication_renderers/AC_Layer0DossierPublication.mqh"
"mt5/runtime_owners/runtime_7_publication_owner/publication_renderers/AC_PublicationRenderers.mqh"
"mt5/AuroraCore.mq5"
)
for f in "${REQ[@]}"; do [[ -f "$f" ]] && pass "source_exists" "$f" || fail "source_exists" "$f"; done

check_has l10_fn_board "${REQ[0]}" "AC_Layer10BoardSection\\(" 
check_has l10_fn_dossier "${REQ[0]}" "AC_Layer10DossierSection\\(" 
check_has l10_fn_workbench "${REQ[0]}" "AC_Layer10WorkbenchSection\\(" 
check_has marketboard_calls_l10 "${REQ[1]}" "AC_Layer10BoardSection\\(" 
check_has dossier_calls_l10 "${REQ[2]}" "AC_Layer10DossierSection\\(" 
check_has workbench_calls_l10 "${REQ[1]}" "AC_Layer10WorkbenchSection\\(" 
check_has publication_includes_l10 "${REQ[3]}" "AC_Layer10TaxonomyRenderer.mqh"

COMMON_ROOT="${APPDATA:-}/MetaQuotes/Terminal/Common/Files/Aurora Core"
if [[ -z "${APPDATA:-}" ]]; then warn install_copy "APPDATA missing; skipped MT5 copy/install"; else
  if [[ -d "$COMMON_ROOT" ]]; then pass mt5_common_root "$COMMON_ROOT"; else warn mt5_common_root "missing: $COMMON_ROOT"; fi
fi

echo "COMPILE_NOT_RUN"

board_file="$(find "$ROOT/external_worker" -type f -name 'Market_Board*.txt' | head -n 1 || true)"
dossier_file="$(find "$ROOT/external_worker" -type f -name 'Dossier_Open_*.txt' | head -n 1 || true)"
workbench_file="$(find "$ROOT/external_worker" -type f -iname '*surface_overseer*.txt' | head -n 1 || true)"

if [[ -n "$board_file" ]]; then
  check_has board_l10_title "$board_file" "LAYER 10 - TAXONOMY / RANKING GROUP MAP"
  check_has board_taxonomy_map "$board_file" "Taxonomy Map:"
else fail board_visual_proof "Market_Board*.txt" "missing"; fi
if [[ -n "$dossier_file" ]]; then
  check_has dossier_l10_header "$dossier_file" "Layer 10 Taxonomy / Ranking Group Map:"
  check_has dossier_l10_caps "$dossier_file" "LAYER 10 - TAXONOMY / RANKING GROUP MAP"
else fail dossier_visual_proof "Dossier_Open_*.txt" "missing"; fi
if [[ -n "$workbench_file" ]]; then
  check_has wb_l10_key "$workbench_file" "L10_TAXONOMY_RANKING_GROUP_MAP|Layer_10_Taxonomy_Classification"
else fail workbench_visual_proof "*surface_overseer*.txt" "missing"; fi
