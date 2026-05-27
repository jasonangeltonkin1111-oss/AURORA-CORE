from __future__ import annotations

from pathlib import Path
from typing import Iterable
import csv
import io

import aurora_worker_selection_surface_shortcuts as base
from aurora_worker_io import atomic_write_text, read_text, utc_stamp, unix_time

EMPTY_SELECTION_SHORTCUT_SUMMARY = base.EMPTY_SELECTION_SHORTCUT_SUMMARY
SelectionShortcutSummary = base.SelectionShortcutSummary


SYSTEM_POINTER_TARGETS = {
    "00_Group_Index.txt": "Selection Desk/Groups/00_Group_Index.txt",
    "00_Group_Index.csv": "Selection Desk/Groups/00_Group_Index.csv",
    "00_Taxonomy_Tree.txt": "Selection Desk/Groups/00_Taxonomy_Tree.txt",
    "00_Taxonomy_Tree.csv": "Selection Desk/Groups/00_Taxonomy_Tree.csv",
    "00_Taxonomy_Tree_Status.txt": "Selection Desk/Groups/00_Taxonomy_Tree_Status.txt",
    "00_Dossier_Copy_Status.txt": "Selection Desk/Groups/00_Dossier_Copy_Status.txt",
}

STALE_WARNING_BLOCK = "\n".join([
    "STALE-SECTION WARNING",
    "Base dossier content below may be older than this current shortcut overlay if the bounded dossier renderer has not refreshed this symbol yet.",
    "Read the overlay above as the current Selection Desk truth for this shortcut file.",
    "----------------------------------------",
    "",
])

OVERLAY_TRUST_BLOCK = "\n".join([
    "OVERLAY TRUST RULE",
    "overlay_truth=current_selection_truth",
    "base_dossier_body_policy=may_lag_current_selection_overlay",
    "operator_rule=trust_overlay_for_current_selection_membership;trust_base_body_for_symbol_detail_only",
    "stale_warning_policy=only_loud_when_staleness_is_proven_by_future_timestamp_generation_check",
    "----------------------------------------",
    "",
])


def _selection_desk(root: Path) -> Path:
    return base._selection_desk(root)


def _system_indexes_dir(root: Path) -> Path:
    return _selection_desk(root) / "90_System_Indexes"


def _root_readme_text() -> str:
    return "\n".join([
        "AURORA SELECTION DESK",
        "----------------------------------------",
        "stable_parent_surfaces=Global;Groups;Selection Index.txt",
        "compatibility_helper_surfaces=01_Global;02_Asset_Classes;90_System_Indexes;91_Layer_Summaries",
        "route_authority_note=Global_and_Groups_are_stable_operator_routes;01_Global_and_02_Asset_Classes_are_shortcut_helper_surfaces",
        "Global/current_top10.csv = stable current L16 Global Top 10 inspection basket source.",
        "Groups/ = stable ranking_group operator route and current group indexes.",
        "01_Global/Top_10 = compatibility shortcut surface with copied dossier files plus current shortcut overlays.",
        "02_Asset_Classes = compatibility shortcut surface for asset-class/group review files.",
        "90_System_Indexes = pointer/status/helper surfaces only; live group counts must not be stale-copied here.",
        "91_Layer_Summaries = helper layer-summary copies for operator review.",
        "Shortcut copies are held when source dossiers are closed, unknown, duplicate, blocked, stale, or unsafe.",
        "All shortcut folders are copy/view surfaces only. They do not calculate trade permission, entry signal, or execution.",
        "selection_runtime=false",
        "trade_permission=false",
        "entry_signal=false",
        "execution=false",
        f"generated_utc={utc_stamp()}",
        "",
    ])


def _pointer_text(filename: str, authoritative_path: str) -> str:
    return "\n".join([
        "schema_name=selection_desk_pointer",
        "schema_version=1",
        "status=pointer_only",
        f"pointer_file={filename}",
        f"authoritative_path={authoritative_path}",
        "reason=avoid_stale_duplicate_live_truth_in_90_System_Indexes",
        "owner=Runtime_3_worker_selection_shortcut_ux_wrapper",
        "authority=pointer_only_no_live_count_authority",
        "selection_runtime=false",
        "trade_permission=false",
        "entry_signal=false",
        "execution=false",
        f"generated_utc={utc_stamp()}",
        f"generated_unix={unix_time()}",
        "",
    ])


def _pointer_csv(filename: str, authoritative_path: str) -> str:
    fields = ["schema_name", "schema_version", "status", "pointer_file", "authoritative_path", "reason", "authority", "selection_runtime", "trade_permission", "entry_signal", "execution", "generated_utc", "generated_unix"]
    row = {
        "schema_name": "selection_desk_pointer",
        "schema_version": "1",
        "status": "pointer_only",
        "pointer_file": filename,
        "authoritative_path": authoritative_path,
        "reason": "avoid_stale_duplicate_live_truth_in_90_System_Indexes",
        "authority": "pointer_only_no_live_count_authority",
        "selection_runtime": "false",
        "trade_permission": "false",
        "entry_signal": "false",
        "execution": "false",
        "generated_utc": utc_stamp(),
        "generated_unix": str(unix_time()),
    }
    buffer = io.StringIO(newline="")
    writer = csv.DictWriter(buffer, fieldnames=fields, lineterminator="\n")
    writer.writeheader()
    writer.writerow(row)
    return buffer.getvalue()


def _pointer_payload(filename: str, authoritative_path: str) -> str:
    if filename.lower().endswith(".csv"):
        return _pointer_csv(filename, authoritative_path)
    return _pointer_text(filename, authoritative_path)


def _write_pointer_files(root: Path) -> int:
    system = _system_indexes_dir(root)
    system.mkdir(parents=True, exist_ok=True)
    written = 0
    for filename, authoritative in SYSTEM_POINTER_TARGETS.items():
        pointer_name = filename.rsplit(".", 1)[0] + "_POINTER.txt"
        if atomic_write_text(system / pointer_name, _pointer_text(pointer_name, authoritative)):
            written += 1
        # Replace stale mirror text/csv with a pointer payload using the same filename so old readers do not consume stale counts.
        if atomic_write_text(system / filename, _pointer_payload(filename, authoritative)):
            written += 1
    return written


def _rewrite_overlay_warning(path: Path) -> bool:
    try:
        text = read_text(path)
    except OSError:
        return False
    if STALE_WARNING_BLOCK not in text:
        return False
    updated = text.replace(STALE_WARNING_BLOCK, OVERLAY_TRUST_BLOCK)
    return atomic_write_text(path, updated)


def _rewrite_shortcut_overlays(root: Path) -> int:
    folders: Iterable[Path] = [
        _selection_desk(root) / "01_Global" / "Top_10",
        _selection_desk(root) / "02_Asset_Classes",
    ]
    rewritten = 0
    for folder in folders:
        if not folder.exists():
            continue
        for path in folder.rglob("*.txt"):
            if path.name.startswith("00_"):
                continue
            if _rewrite_overlay_warning(path):
                rewritten += 1
    return rewritten


def _repair_selection_surface_ux(root: Path) -> None:
    desk = _selection_desk(root)
    desk.mkdir(parents=True, exist_ok=True)
    atomic_write_text(desk / "00_Read_Me.txt", _root_readme_text())
    _write_pointer_files(root)
    _rewrite_shortcut_overlays(root)


def publish_l11_asset_class_shortcuts(root: Path) -> SelectionShortcutSummary:
    summary = base.publish_l11_asset_class_shortcuts(root)
    _repair_selection_surface_ux(root)
    return summary


def publish_l16_global_top10_shortcuts(root: Path) -> SelectionShortcutSummary:
    summary = base.publish_l16_global_top10_shortcuts(root)
    _repair_selection_surface_ux(root)
    return summary
