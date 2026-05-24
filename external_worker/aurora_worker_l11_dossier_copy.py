from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Sequence, Tuple
from collections import defaultdict
import csv
import io
import re

from aurora_worker_io import WorkerPaths, atomic_write_text, read_text, payload_checksum

L11_LAYER_FOLDER = "Layer_11_Symbol_Ranking_Inside_Ranking_Group"

@dataclass(frozen=True)
class L11DossierCopySummary:
    status: str
    reason: str
    dossier_copies_written: int = 0
    dossier_copies_expected: int = 0
    dossier_sources_missing: int = 0
    stale_dossier_rank_files_removed: int = 0
    write_failed_count: int = 0

EMPTY_L11_DOSSIER_COPY_SUMMARY = L11DossierCopySummary("pending", "l11_dossier_copy_not_run")


def _sanitize(value: str) -> str:
    safe = str(value or "").strip() or "Unknown"
    safe = safe.replace("&", "and")
    safe = re.sub(r"[\\/:*?\"<>|]+", "_", safe)
    safe = re.sub(r"\s+", "_", safe)
    safe = re.sub(r"_+", "_", safe).strip("_.")
    return safe or "Unknown"


def _display(value: str) -> str:
    return str(value or "").strip() or "Unknown"


def _csv_rows(text: str) -> List[Dict[str, str]]:
    reader = csv.DictReader(io.StringIO(text.replace("\r\n", "\n")))
    return [{str(k): ("" if v is None else str(v)) for k, v in row.items()} for row in reader]


def _rank_value(row: Dict[str, str]) -> int:
    try:
        return int(str(row.get("ranking_group_rank", "999999")).strip())
    except ValueError:
        return 999999


def _is_top5(row: Dict[str, str]) -> bool:
    return str(row.get("in_top5_per_ranking_group", "")).strip().lower() == "true" and _rank_value(row) <= 5


def _rank_filename(row: Dict[str, str]) -> str:
    rank = _rank_value(row)
    symbol = _sanitize(row.get("symbol", "unknown"))
    return f"{rank:02d}_{symbol}.txt" if rank < 999999 else f"not_rankable_{symbol}.txt"


def _account_root(root: Path) -> Path:
    return WorkerPaths.from_root(root).outbox.parents[2]


def _selection_groups_dir(root: Path) -> Path:
    return _account_root(root) / "Selection Desk" / "Groups"


def _ranked_symbols_path(root: Path) -> Path:
    paths = WorkerPaths.from_root(root)
    return paths.outbox / "Layers" / L11_LAYER_FOLDER / "ranked_symbols_by_group.csv"


def _target_folder(root: Path, row: Dict[str, str]) -> Path:
    return (
        _selection_groups_dir(root)
        / _sanitize(_display(row.get("asset_class")))
        / _sanitize(_display(row.get("market_group")))
        / _sanitize(_display(row.get("market_segment")))
        / _sanitize(_display(row.get("ranking_group")))
    )


def _candidate_dossier_paths(account_root: Path, symbol: str) -> List[Path]:
    clean_symbol = str(symbol or "").strip()
    if clean_symbol == "":
        return []
    safe_symbol = _sanitize(clean_symbol)
    names = []
    for base in (clean_symbol, safe_symbol):
        names.extend([base, f"{base}.txt"])
    # Preserve order and uniqueness.
    unique_names = []
    seen = set()
    for name in names:
        if name not in seen:
            unique_names.append(name)
            seen.add(name)
    candidates: List[Path] = []
    for state in ("Open", "Closed", "Unknown"):
        folder = account_root / "Dossiers" / state
        for name in unique_names:
            candidates.append(folder / name)
    return candidates


def _find_dossier(account_root: Path, symbol: str) -> Optional[Path]:
    for path in _candidate_dossier_paths(account_root, symbol):
        if path.exists() and path.is_file():
            return path
    dossiers_root = account_root / "Dossiers"
    if not dossiers_root.exists():
        return None
    clean_symbol = str(symbol or "").strip()
    safe_symbol = _sanitize(clean_symbol)
    wanted = {clean_symbol.lower(), f"{clean_symbol}.txt".lower(), safe_symbol.lower(), f"{safe_symbol}.txt".lower()}
    for path in dossiers_root.rglob("*.txt"):
        if path.name.lower() in wanted:
            return path
    return None


def _cleanup_stale_tree_rank_files(folder: Path, expected_names: Iterable[str]) -> int:
    expected = set(expected_names)
    removed = 0
    for path in folder.glob("*.txt"):
        if not re.match(r"^\d{2}_.+\.txt$", path.name):
            continue
        if path.name in expected:
            continue
        try:
            path.unlink()
            removed += 1
        except OSError:
            pass
    return removed


def copy_l11_tree_rank_files_from_dossiers(root: Path) -> L11DossierCopySummary:
    ranked_path = _ranked_symbols_path(root)
    if not ranked_path.exists():
        return L11DossierCopySummary("pending", f"missing_ranked_symbols_by_group:{ranked_path}")
    rows = [row for row in _csv_rows(read_text(ranked_path)) if _is_top5(row)]
    if not rows:
        return L11DossierCopySummary("pending", "no_top5_rows_available_for_dossier_copy")

    account_root = _account_root(root)
    grouped: Dict[Path, List[Dict[str, str]]] = defaultdict(list)
    for row in rows:
        grouped[_target_folder(root, row)].append(row)

    written = 0
    expected = 0
    missing = 0
    failed = 0
    stale_removed = 0
    for folder, group_rows in grouped.items():
        folder.mkdir(parents=True, exist_ok=True)
        expected_names = [_rank_filename(row) for row in group_rows]
        stale_removed += _cleanup_stale_tree_rank_files(folder, expected_names)
        for row in group_rows:
            expected += 1
            symbol = str(row.get("symbol", "")).strip()
            target = folder / _rank_filename(row)
            source = _find_dossier(account_root, symbol)
            if source is None:
                missing += 1
                continue
            content = read_text(source)
            if atomic_write_text(target, content):
                written += 1
            else:
                failed += 1

    status = "accepted" if written == expected and missing == 0 and failed == 0 else "write_degraded"
    reason = "l11_tree_rank_files_copied_from_source_dossiers" if status == "accepted" else "one_or_more_l11_tree_dossier_copies_missing_or_failed"
    return L11DossierCopySummary(status, reason, written, expected, missing, stale_removed, failed)
