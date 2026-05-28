from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import List
import shutil

from aurora_worker_io import WorkerPaths, atomic_write_text, read_text, utc_stamp, unix_time


@dataclass(frozen=True)
class SelectionSurfaceCleanupSummary:
    status: str
    reason: str
    legacy_groups_removed: int = 0
    legacy_global_removed: int = 0
    deep_evidence_files_preserved: int = 0
    write_failed_count: int = 0
    status_path: str = "not_available"


EMPTY_SELECTION_SURFACE_CLEANUP_SUMMARY = SelectionSurfaceCleanupSummary("pending", "selection_surface_cleanup_not_run")


def _account_root(root: Path) -> Path:
    return WorkerPaths.from_root(root).outbox.parents[2]


def _selection_desk(root: Path) -> Path:
    return _account_root(root) / "Selection Desk"


def _write(path: Path, text: str, failed: List[Path]) -> bool:
    ok = atomic_write_text(path, text)
    if not ok:
        failed.append(path)
    return ok


def _count_tree(path: Path) -> int:
    if not path.exists():
        return 0
    count = 0
    for item in path.rglob("*"):
        count += 1
    return count


def _remove_tree(path: Path) -> int:
    count = _count_tree(path)
    if count <= 0 and not path.exists():
        return 0
    shutil.rmtree(path, ignore_errors=True)
    return count


def _preserve_deep_evidence(root: Path, failed: List[Path]) -> int:
    desk = _selection_desk(root)
    old_global = desk / "Global"
    new_deep = desk / "01_Global" / "Deep_Evidence"
    new_deep.mkdir(parents=True, exist_ok=True)
    mapping = {
        "Deep Evidence Split.txt": "00_Deep_Evidence_Split.txt",
        "current_deep_evidence_split.csv": "00_Deep_Evidence_Split.csv",
        "current_deep_evidence_split_manifest.txt": "00_Deep_Evidence_Split_Manifest.txt",
    }
    preserved = 0
    for src_name, dst_name in mapping.items():
        src = old_global / src_name
        if not src.exists() or not src.is_file():
            continue
        if _write(new_deep / dst_name, read_text(src), failed):
            preserved += 1
    return preserved


def _cleanup_status_text(summary: SelectionSurfaceCleanupSummary) -> str:
    return "\n".join([
        "schema_name=selection_surface_legacy_cleanup_status",
        "schema_version=1",
        "owner_name=Runtime 3 external worker selection surface cleanup bridge",
        "source_owner=Runtime 7 publication surfaces",
        "cleanup_scope=legacy_selection_desk_groups_and_global_after_clean_shortcuts_exist",
        f"status={summary.status}",
        f"reason={summary.reason}",
        f"legacy_groups_removed={summary.legacy_groups_removed}",
        f"legacy_global_removed={summary.legacy_global_removed}",
        f"deep_evidence_files_preserved={summary.deep_evidence_files_preserved}",
        f"write_failed_count={summary.write_failed_count}",
        "clean_global_path=Selection Desk/01_Global",
        "clean_asset_class_path=Selection Desk/02_Asset_Classes",
        "system_indexes_path=Selection Desk/90_System_Indexes",
        "layer_summaries_path=Selection Desk/91_Layer_Summaries",
        "selection_runtime=false",
        "trade_permission=false",
        "entry_signal=false",
        "execution=false",
        f"generated_utc={utc_stamp()}",
        f"generated_unix={unix_time()}",
        "",
    ])


def cleanup_legacy_selection_surface_paths(root: Path) -> SelectionSurfaceCleanupSummary:
    failed: List[Path] = []
    desk = _selection_desk(root)
    status_path = desk / "90_System_Indexes" / "00_Legacy_Selection_Surface_Cleanup_Status.txt"
    required_clean_paths = [
        desk / "01_Global" / "Top_10" / "00_Global_Top_10.txt",
        desk / "02_Asset_Classes" / "00_Asset_Class_Top5_Index.txt",
        desk / "02_Asset_Classes" / "00_Shallow_Group_Top5_Status.txt",
        desk / "90_System_Indexes",
        desk / "91_Layer_Summaries",
    ]
    missing = [str(path) for path in required_clean_paths if not path.exists()]
    if missing:
        summary = SelectionSurfaceCleanupSummary("pending", "clean_selection_surface_not_ready_missing:" + ";".join(missing), 0, 0, 0, 0, str(status_path))
        status_path.parent.mkdir(parents=True, exist_ok=True)
        _write(status_path, _cleanup_status_text(summary), failed)
        return summary

    preserved = _preserve_deep_evidence(root, failed)
    groups_removed = _remove_tree(desk / "Groups")
    global_removed = _remove_tree(desk / "Global")

    status = "accepted" if not failed else "write_degraded"
    reason = "legacy_selection_surface_paths_removed" if status == "accepted" else "legacy_paths_removed_but_cleanup_status_or_preservation_write_failed"
    summary = SelectionSurfaceCleanupSummary(status, reason, groups_removed, global_removed, preserved, len(failed), str(status_path))
    status_path.parent.mkdir(parents=True, exist_ok=True)
    _write(status_path, _cleanup_status_text(summary), failed)
    return summary
