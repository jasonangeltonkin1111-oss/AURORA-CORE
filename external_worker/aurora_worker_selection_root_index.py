from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List

from aurora_worker_io import WorkerPaths, atomic_write_text_if_changed, read_text, utc_stamp, unix_time


@dataclass(frozen=True)
class SelectionRootIndexSummary:
    status: str
    reason: str
    root_index_path: str = "not_available"
    readme_path: str = "not_available"
    write_failed_count: int = 0


EMPTY_SELECTION_ROOT_INDEX_SUMMARY = SelectionRootIndexSummary("pending", "selection_root_index_not_run")


def _account_root(root: Path) -> Path:
    return WorkerPaths.from_root(root).root


def _selection_desk(root: Path) -> Path:
    return _account_root(root) / "Selection Desk"


def _gateway_result_latest(root: Path) -> Path:
    return WorkerPaths.from_root(root).outbox / "result_latest.txt"


def _write(path: Path, text: str, failed: List[Path]) -> bool:
    ok = atomic_write_text_if_changed(path, text, durable=True)
    if not ok:
        failed.append(path)
    return ok


def _kv(path: Path) -> Dict[str, str]:
    data: Dict[str, str] = {}
    if not path.exists():
        return data
    for raw in read_text(path).replace("\r\n", "\n").splitlines():
        if "=" not in raw or raw.strip().startswith("#"):
            continue
        key, value = raw.split("=", 1)
        data[key.strip()] = value.strip()
    return data


def _status(data: Dict[str, str], fallback: str = "pending") -> str:
    return data.get("status", fallback) or fallback


def _exists_text(path: Path) -> str:
    return "true" if path.exists() else "false"


def _truthy(data: Dict[str, str], key: str) -> bool:
    return str(data.get(key, "false")).strip().lower() == "true"


def _latest_layer_currentness(result: Dict[str, str]) -> Dict[str, str]:
    required = ["l16", "l17", "l18", "l19"]
    values: Dict[str, str] = {}
    blocked: List[str] = []
    for layer in required:
        current_key = f"{layer}_current_chain_valid"
        downstream_key = f"{layer}_downstream_allowed"
        current = "true" if _truthy(result, current_key) else "false"
        downstream = "true" if _truthy(result, downstream_key) else "false"
        values[current_key] = current
        values[downstream_key] = downstream
        if current != "true" or downstream != "true":
            reason = result.get(f"{layer}_currentness_reason", result.get(f"{layer}_global_top10_reason", result.get(f"{layer}_selected_raw_ohlc_reason", "not_available")))
            blocked.append(f"{layer}:current={current};downstream={downstream};reason={reason}")
    values["latest_chain_current_for_downstream"] = "true" if not blocked and result else "false"
    values["latest_chain_blockers"] = ";".join(blocked) if blocked else "none"
    values["latest_result_present"] = "true" if result else "false"
    return values


def _selection_readme_text() -> str:
    return "\n".join([
        "AURORA SELECTION DESK",
        "----------------------------------------",
        "index_type=worker_support_navigation_index",
        "authority=operator_navigation_only_not_runtime_route_law",
        "route_law_owner=Runtime 7 publication route owner",
        "score_owner=Runtime 3 calculation support outputs",
        "",
        "Stable operator routes:",
        "Selection Desk/Global = stable current L16 Global Top 10 inspection basket source.",
        "Selection Desk/Groups = stable ranking_group operator route and current group indexes.",
        "Selection Desk/Selection Index.txt = stable operator navigation surface mirrored by this worker support index.",
        "",
        "Compatibility/helper routes:",
        "01_Global/Top_10 = compatibility shortcut surface with copied dossier files plus current shortcut overlays.",
        "01_Global/Deep_Evidence = L17 deep-evidence selection split shortcut surface.",
        "02_Asset_Classes/<asset_class>/01_Top_5_All_<asset_class> = helper shortcut across the whole asset class.",
        "02_Asset_Classes/<asset_class>/02_Groups/<compact_ranking_group_key> = helper Top 5 per ranking_group shortcut.",
        "90_System_Indexes = pointer/status/helper surfaces only; live group counts must not be stale-copied here.",
        "91_Layer_Summaries = helper layer-summary copies for operator review.",
        "",
        "Currentness law:",
        "visible_for_operator may be true while current_for_downstream is false.",
        "held_previous surfaces are navigation/history only and must not be treated as current selection truth.",
        "Selection Desk root status follows latest Gateway currentness, not merely file existence.",
        "",
        "L18 target scope:",
        "l18_target_scope=selected_copied_dossiers_only_with_source_mode_label",
        "l18_allowed_surfaces=01_Global/Top_10/*.txt;02_Asset_Classes/*/01_Top_5_All_*/*.txt;02_Asset_Classes/*/02_Groups/*/*.txt",
        "l18_source_manifest=Selection Desk/Global/current_top10.csv when available",
        "l18_excluded_surfaces=Selection Desk/Global raw files;Selection Desk/Groups raw files;90_System_Indexes;91_Layer_Summaries;base Dossiers/Open;base Dossiers/Closed;base Dossiers/Unknown",
        "l18_rule=decorate_selected_copied_dossiers_only_no_all_symbol_scan_no_ohlc_store_owner_change",
        "",
        "Trading safety:",
        "selection_runtime=false",
        "trade_permission=false",
        "entry_signal=false",
        "execution=false",
        f"generated_utc={utc_stamp()}",
        f"generated_unix={unix_time()}",
        "",
    ])


def _selection_index_text(root: Path) -> str:
    desk = _selection_desk(root)
    global_status = _kv(desk / "01_Global" / "Top_10" / "00_Global_Top_10_Copy_Status.txt")
    asset_status = _kv(desk / "02_Asset_Classes" / "00_Asset_Class_Top5_Status.txt")
    group_status = _kv(desk / "02_Asset_Classes" / "00_Shallow_Group_Top5_Status.txt")
    cleanup_status = _kv(desk / "90_System_Indexes" / "00_Legacy_Selection_Surface_Cleanup_Status.txt")
    result_latest = _kv(_gateway_result_latest(root))
    currentness = _latest_layer_currentness(result_latest)
    deep_evidence_exists = (desk / "01_Global" / "Deep_Evidence" / "00_Deep_Evidence_Split.txt").exists()
    stable_global_current_top10 = (desk / "Global" / "current_top10.csv").exists()
    stable_groups_index = (desk / "Groups" / "00_Group_Index.csv").exists()

    root_ok = all([
        stable_global_current_top10,
        stable_groups_index,
        (desk / "01_Global" / "Top_10" / "00_Global_Top_10.txt").exists(),
        (desk / "02_Asset_Classes" / "00_Asset_Class_Top5_Index.txt").exists(),
        (desk / "02_Asset_Classes" / "00_Shallow_Group_Top5_Status.txt").exists(),
        (desk / "90_System_Indexes").exists(),
        (desk / "91_Layer_Summaries").exists(),
    ])
    warning_parts: List[str] = []
    if not stable_global_current_top10:
        warning_parts.append("stable_global_current_top10_missing")
    if not stable_groups_index:
        warning_parts.append("stable_groups_index_missing")
    if _status(global_status) != "accepted":
        warning_parts.append("global_top10_shortcuts_not_accepted")
    if _status(asset_status) != "accepted":
        warning_parts.append("asset_class_top5_not_accepted")
    if _status(group_status) != "accepted":
        warning_parts.append("group_top5_not_accepted")
    if not deep_evidence_exists:
        warning_parts.append("deep_evidence_split_not_present_yet")
    if currentness["latest_result_present"] != "true":
        warning_parts.append("gateway_result_latest_missing")
    if currentness["latest_chain_current_for_downstream"] != "true":
        warning_parts.append("latest_chain_not_current_for_downstream")

    if not root_ok:
        status = "pending"
    elif currentness["latest_chain_current_for_downstream"] != "true":
        status = "currentness_blocked_visible_history_only"
    elif warning_parts:
        status = "accepted_with_runtime_warnings"
    else:
        status = "accepted_current"

    if status == "accepted_current":
        reason = "selection_navigation_ready_and_latest_chain_current_for_downstream"
    elif status == "currentness_blocked_visible_history_only":
        reason = "selection_surfaces_visible_but_latest_chain_not_current_for_downstream;" + currentness["latest_chain_blockers"]
    else:
        reason = ";".join(warning_parts) if warning_parts else "selection_navigation_not_ready"

    current_for_downstream = "true" if status == "accepted_current" else "false"
    visible_for_operator = "true" if root_ok else "false"
    held_previous = "true" if visible_for_operator == "true" and current_for_downstream != "true" else "false"

    return "\n".join([
        "schema_name=selection_desk_worker_support_index",
        "schema_version=6",
        "owner_name=Runtime 3 external worker support index publisher",
        "source_owner=Runtime 3 calculation outputs plus Runtime 7 publication surfaces",
        "authority=operator_navigation_only_not_runtime_route_law",
        "route_law_owner=Runtime 7 publication route owner",
        f"status={status}",
        f"reason={reason}",
        f"visible_for_operator={visible_for_operator}",
        f"current_for_downstream={current_for_downstream}",
        f"held_previous={held_previous}",
        f"latest_result_present={currentness['latest_result_present']}",
        f"latest_chain_current_for_downstream={currentness['latest_chain_current_for_downstream']}",
        f"latest_chain_blockers={currentness['latest_chain_blockers']}",
        f"l16_current_chain_valid={currentness['l16_current_chain_valid']}",
        f"l16_downstream_allowed={currentness['l16_downstream_allowed']}",
        f"l17_current_chain_valid={currentness['l17_current_chain_valid']}",
        f"l17_downstream_allowed={currentness['l17_downstream_allowed']}",
        f"l18_current_chain_valid={currentness['l18_current_chain_valid']}",
        f"l18_downstream_allowed={currentness['l18_downstream_allowed']}",
        f"l19_current_chain_valid={currentness['l19_current_chain_valid']}",
        f"l19_downstream_allowed={currentness['l19_downstream_allowed']}",
        f"stable_global_current_top10_present={_exists_text(desk / 'Global' / 'current_top10.csv')}",
        f"stable_groups_index_present={_exists_text(desk / 'Groups' / '00_Group_Index.csv')}",
        f"global_top10_shortcut_status={_status(global_status)}",
        f"global_top10_copies_written={global_status.get('dossier_copies_written', 'not_available')}",
        f"global_top10_copies_expected={global_status.get('dossier_copies_expected', 'not_available')}",
        f"asset_class_top5_status={_status(asset_status)}",
        f"asset_class_top5_copies_written={asset_status.get('dossier_copies_written', 'not_available')}",
        f"asset_class_top5_copies_expected={asset_status.get('dossier_copies_expected', 'not_available')}",
        f"group_top5_status={_status(group_status)}",
        f"group_top5_copies_written={group_status.get('dossier_copies_written', 'not_available')}",
        f"group_top5_copies_expected={group_status.get('dossier_copies_expected', 'not_available')}",
        f"deep_evidence_split_present={_exists_text(desk / '01_Global' / 'Deep_Evidence' / '00_Deep_Evidence_Split.txt')}",
        f"legacy_cleanup_status={_status(cleanup_status, 'not_run')}",
        "stable_operator_routes=Global;Groups;Selection Index.txt",
        "compatibility_helper_surfaces=01_Global;02_Asset_Classes;90_System_Indexes;91_Layer_Summaries",
        "stable_parent_surfaces_policy=stable_operator_routes_not_trade_permission",
        "selection_runtime=false",
        "trade_permission=false",
        "entry_signal=false",
        "execution=false",
        f"generated_utc={utc_stamp()}",
        f"generated_unix={unix_time()}",
        "",
    ])


def publish_selection_root_index(root: Path) -> SelectionRootIndexSummary:
    failed: List[Path] = []
    desk = _selection_desk(root)
    desk.mkdir(parents=True, exist_ok=True)
    readme_path = desk / "00_Read_Me.txt"
    index_path = desk / "00_Selection_Index.txt"
    stable_index_path = desk / "Selection Index.txt"
    _write(readme_path, _selection_readme_text(), failed)
    index_text = _selection_index_text(root)
    _write(index_path, index_text, failed)
    _write(stable_index_path, index_text, failed)
    status = "accepted" if not failed else "write_degraded"
    reason = "selection_worker_support_index_published" if status == "accepted" else "selection_worker_support_index_write_failed"
    return SelectionRootIndexSummary(status, reason, str(stable_index_path), str(readme_path), len(failed))
