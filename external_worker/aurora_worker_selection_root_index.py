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
    return WorkerPaths.from_root(root).outbox.parents[2]


def _selection_desk(root: Path) -> Path:
    return _account_root(root) / "Selection Desk"


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


def _selection_readme_text() -> str:
    return "\n".join([
        "AURORA SELECTION DESK",
        "----------------------------------------",
        "index_type=worker_support_navigation_index",
        "authority=operator_navigation_only_not_runtime_route_law",
        "route_law_owner=Runtime 7 publication route owner",
        "score_owner=Runtime 3 calculation support outputs",
        "",
        "Rich operator surfaces:",
        "01_Global/Top_10 = Global Top 10 inspection basket with selected dossier shortcuts.",
        "01_Global/Deep_Evidence = L17 deep-evidence selection split shortcuts.",
        "02_Asset_Classes/<asset_class>/01_Top_5_All_<asset_class> = Top 5 shortcut across the whole asset class.",
        "02_Asset_Classes/<asset_class>/02_Groups/<compact_ranking_group_key> = shallow Top 5 per ranking_group shortcut.",
        "90_System_Indexes = worker support indexes, status files, taxonomy proof, cleanup proof.",
        "91_Layer_Summaries = L12-L15 summary copies for operator review.",
        "",
        "Stable parent policy:",
        "Selection Desk/Global and Selection Desk/Groups are stable parent routes and may remain for compatibility.",
        "They are not proof of trade permission and they are not L18 canonical targets.",
        "",
        "L18 target scope:",
        "l18_target_scope=canonical_selection_shortcut_dossiers_only",
        "l18_allowed_surfaces=01_Global/Top_10/*.txt;02_Asset_Classes/*/01_Top_5_All_*/*.txt;02_Asset_Classes/*/02_Groups/*/*.txt",
        "l18_excluded_surfaces=Selection Desk/Global;Selection Desk/Groups;90_System_Indexes;91_Layer_Summaries;base Dossiers/Open;base Dossiers/Closed;base Dossiers/Unknown",
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
    deep_evidence_exists = (desk / "01_Global" / "Deep_Evidence" / "00_Deep_Evidence_Split.txt").exists()

    root_ok = all([
        (desk / "01_Global" / "Top_10" / "00_Global_Top_10.txt").exists(),
        (desk / "02_Asset_Classes" / "00_Asset_Class_Top5_Index.txt").exists(),
        (desk / "02_Asset_Classes" / "00_Shallow_Group_Top5_Status.txt").exists(),
        (desk / "90_System_Indexes").exists(),
        (desk / "91_Layer_Summaries").exists(),
    ])
    legacy_present = (desk / "Global").exists() or (desk / "Groups").exists()
    warning_parts: List[str] = []
    if legacy_present:
        warning_parts.append("legacy_surfaces_present")
    if _status(global_status) != "accepted":
        warning_parts.append("global_top10_not_accepted")
    if _status(asset_status) != "accepted":
        warning_parts.append("asset_class_top5_not_accepted")
    if _status(group_status) != "accepted":
        warning_parts.append("group_top5_not_accepted")
    if not deep_evidence_exists:
        warning_parts.append("deep_evidence_split_not_present_yet")

    status = "accepted" if root_ok and not warning_parts else ("accepted_with_runtime_warnings" if root_ok else "pending")
    reason = "worker_support_selection_navigation_ready" if status == "accepted" else (";".join(warning_parts) if warning_parts else "worker_support_selection_navigation_not_ready")

    return "\n".join([
        "schema_name=selection_desk_worker_support_index",
        "schema_version=3",
        "owner_name=Runtime 3 external worker support index publisher",
        "source_owner=Runtime 3 calculation outputs plus Runtime 7 publication surfaces",
        "authority=operator_navigation_only_not_runtime_route_law",
        "route_law_owner=Runtime 7 publication route owner",
        f"status={status}",
        f"reason={reason}",
        f"global_top10_status={_status(global_status)}",
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
        f"legacy_global_present={_exists_text(desk / 'Global')}",
        f"legacy_groups_present={_exists_text(desk / 'Groups')}",
        "rich_operator_surfaces=01_Global;02_Asset_Classes;90_System_Indexes;91_Layer_Summaries",
        "stable_parent_surfaces=Global;Groups",
        "stable_parent_surfaces_policy=compatibility_parent_routes_not_l18_targets",
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
    _write(readme_path, _selection_readme_text(), failed)
    _write(index_path, _selection_index_text(root), failed)
    status = "accepted" if not failed else "write_degraded"
    reason = "selection_worker_support_index_published" if status == "accepted" else "selection_worker_support_index_write_failed"
    return SelectionRootIndexSummary(status, reason, str(index_path), str(readme_path), len(failed))
