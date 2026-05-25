from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

from aurora_worker_io import WorkerPaths


@dataclass(frozen=True)
class SelectionRootIndexSummary:
    status: str
    reason: str
    files_written: int = 0
    files_expected: int = 0
    write_failed_count: int = 0
    index_path: str = "not_available"
    readme_path: str = "not_available"


EMPTY_SELECTION_ROOT_INDEX_SUMMARY = SelectionRootIndexSummary("pending", "selection_root_index_not_run")


def _account_root(root: Path) -> Path:
    return WorkerPaths.from_root(root).outbox.parents[2]


def _selection_desk(root: Path) -> Path:
    return _account_root(root) / "Selection Desk"


def publish_selection_desk_root_operator_index(root: Path) -> SelectionRootIndexSummary:
    """Compatibility shim only.

    The canonical root index/README writer is aurora_worker_selection_root_index.py.
    It must run after the final selected-dossier decorator and legacy cleanup.
    L11 may still import this older module for backward compatibility, but it must
    not write root index files or reintroduce stale legacy/canonical wording.
    """
    desk = _selection_desk(root)
    return SelectionRootIndexSummary(
        status="deferred",
        reason="canonical_root_index_owned_by_final_cleanup_writer_after_l19",
        files_written=0,
        files_expected=0,
        write_failed_count=0,
        index_path=str(desk / "00_Selection_Index.txt"),
        readme_path=str(desk / "00_Read_Me.txt"),
    )
