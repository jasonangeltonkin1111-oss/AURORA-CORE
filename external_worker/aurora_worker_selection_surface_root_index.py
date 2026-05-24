from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Dict

from aurora_worker_io import WorkerPaths, atomic_write_text, read_text, utc_stamp, unix_time


@dataclass(frozen=True)
class SelectionRootIndexSummary:
    status: str
    reason: str
    files_written: int = 0
    files_expected: int = 2
    write_failed_count: int = 0
    index_path: str = "not_available"
    readme_path: str = "not_available"


EMPTY_SELECTION_ROOT_INDEX_SUMMARY = SelectionRootIndexSummary("pending", "selection_root_index_not_run")


def _account_root(root: Path) -> Path:
    return WorkerPaths.from_root(root).outbox.parents[2]


def _selection_desk(root: Path) -> Path:
    return _account_root(root) / "Selection Desk"


def _write(path: Path, text: str, failed: list[Path]) -> bool:
    ok = atomic_write_text(path, text)
    if not ok:
        failed.append(path)
    return ok


def _kv_file(path: Path) -> Dict[str, str]:
    if not path.exists():
        return {}
    data: Dict[str, str] = {}
    for raw_line in read_text(path).replace("\r\n", "\n").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        data[key.strip()] = value.strip()
    return data


def _status_value(path: Path) -> str:
    return _kv_file(path).get("status", "missing") if path.exists() else "missing"


def _readme_text() -> str:
    return "\n".join([
        "AURORA SELECTION DESK",
        "----------------------------------------",
        "Preferred operator paths:",
        "01_Global/Top_10 = L16 Global Top 10 inspection basket with copied dossier files.",
        "02_Asset_Classes/<asset_class>/01_Top_5_All_<asset_class> = Top 5 shortcut across the whole asset class.",
        "02_Asset_Classes/<asset_class>/02_Groups/<ranking_group> = shallow Top 5 per dynamic ranking_group.",
        "90_System_Indexes = copied index/status proof surfaces.",
        "91_Layer_Summaries = layer summary copies for operator review.",
        "",
        "Compatibility paths:",
        "Global/ = legacy Selection Desk Global surface kept for compatibility/readback.",
        "Groups/ = legacy deep taxonomy tree kept temporarily for compatibility/readback.",
        "Do not use legacy Global/Groups as the primary operator review path unless troubleshooting compatibility.",
        "",
        "Authority:",
        "All Selection Desk folders are copy/view surfaces only.",
        "They do not calculate scores, trade permission, entry signals, alerts, or execution.",
        "Scoring and selection remain owned by their existing layer owners.",
        "",
        f"generated_utc={utc_stamp()}",
        "",
    ])


def _index_text(root: Path) -> str:
    desk = _selection_desk(root)
    global_status_path = desk / "01_Global" / "Top_10" / "00_Global_Top_10_Copy_Status.txt"
    asset_status_path = desk / "02_Asset_Classes" / "00_Asset_Class_Top5_Status.txt"
    shallow_status_path = desk / "02_Asset_Classes" / "00_Shallow_Group_Top5_Status.txt"
    system_index = desk / "90_System_Indexes" / "00_Group_Index.csv"
    layer_l13 = desk / "91_Layer_Summaries" / "L13_Selected_Ranking_Groups" / "00_Selected_Ranking_Groups.csv"

    global_status = _status_value(global_status_path)
    asset_status = _status_value(asset_status_path)
    shallow_status = _status_value(shallow_status_path)
    legacy_global_present = (desk / "Global").exists()
    legacy_groups_present = (desk / "Groups").exists()

    preferred_ok = all(s == "accepted" for s in (global_status, asset_status, shallow_status))
    partial_ok = any(s == "accepted" for s in (global_status, asset_status, shallow_status))
    if preferred_ok:
        status = "accepted"
        reason = "preferred_selection_desk_surfaces_available"
    elif partial_ok:
        status = "partial"
        reason = "some_preferred_selection_desk_surfaces_available"
    else:
        status = "pending"
        reason = "preferred_selection_desk_surfaces_missing_or_not_accepted"

    lines = [
        "schema_name=selection_desk_root_index",
        "schema_version=2",
        "owner_name=Runtime 5 - Taxonomy / Ranking Group Owner",
        "support_owner=Runtime 3 external worker copy bridge",
        "source_owner=existing layer owner outputs only",
        f"status={status}",
        f"reason={reason}",
        "preferred_operator_root=Selection Desk",
        "preferred_global_top10=01_Global/Top_10",
        "preferred_asset_class_top5=02_Asset_Classes/<asset_class>/01_Top_5_All_<asset_class>",
        "preferred_shallow_group_top5=02_Asset_Classes/<asset_class>/02_Groups/<ranking_group>",
        "system_indexes=90_System_Indexes",
        "layer_summaries=91_Layer_Summaries",
        f"global_top10_shortcut_status={global_status}",
        f"asset_class_top5_shortcut_status={asset_status}",
        f"shallow_group_top5_shortcut_status={shallow_status}",
        f"system_group_index_present={str(system_index.exists()).lower()}",
        f"l13_selected_group_summary_present={str(layer_l13.exists()).lower()}",
        f"legacy_global_present={str(legacy_global_present).lower()}",
        f"legacy_groups_present={str(legacy_groups_present).lower()}",
        "legacy_policy=compatibility_readback_only_not_primary_operator_surface",
        "selection_runtime=false",
        "trade_permission=false",
        "entry_signal=false",
        "execution=false",
        f"generated_utc={utc_stamp()}",
        f"generated_unix={unix_time()}",
        "",
    ]
    return "\n".join(lines)


def publish_selection_desk_root_operator_index(root: Path) -> SelectionRootIndexSummary:
    failed: list[Path] = []
    desk = _selection_desk(root)
    desk.mkdir(parents=True, exist_ok=True)
    readme_path = desk / "00_Read_Me.txt"
    index_path = desk / "00_Selection_Index.txt"
    written = 0
    if _write(readme_path, _readme_text(), failed):
        written += 1
    if _write(index_path, _index_text(root), failed):
        written += 1
    status = "accepted" if not failed else "write_degraded"
    reason = "selection_root_operator_index_published" if status == "accepted" else "selection_root_operator_index_write_failed"
    return SelectionRootIndexSummary(status, reason, written, 2, len(failed), str(index_path), str(readme_path))
