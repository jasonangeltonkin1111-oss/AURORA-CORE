from __future__ import annotations

from pathlib import Path
import csv
import io

from aurora_worker_io import WorkerPaths, payload_checksum, read_text

L11_LAYER_FOLDER = "Layer_11_Symbol_Ranking_Inside_Ranking_Group"


def _sanitize(value: str) -> str:
    safe = str(value).strip() or "unknown"
    for ch in ['\\', '/', ':', '*', '?', '"', '<', '>', '|', ' ']:
        safe = safe.replace(ch, '_')
    return safe


def cleanup_l11_stale_symbol_rank_sidecars(root: Path) -> int:
    """Remove stale L11 SymbolRanks sidecars not present in current ranked_symbols_by_group.csv.

    The L11 publisher writes one sidecar per current ranked row. If a symbol drops out of
    the current L6-L9 RenderIndex input set, an old sidecar can remain and make
    symbol_rank_files_actual > symbol_rank_files_written. That is a stale file, not a
    failed write. This helper removes only sidecars whose generated filename is not in
    the current ranked symbol set.
    """
    paths = WorkerPaths.from_root(root)
    layer_dir = paths.outbox / "Layers" / L11_LAYER_FOLDER
    ranked_csv_path = layer_dir / "ranked_symbols_by_group.csv"
    symbol_dir = layer_dir / "SymbolRanks"
    if not ranked_csv_path.exists() or not symbol_dir.exists():
        return 0

    reader = csv.DictReader(io.StringIO(read_text(ranked_csv_path).replace("\r\n", "\n")))
    expected_names = set()
    for row in reader:
        symbol = str(row.get("symbol", "")).strip()
        if not symbol:
            continue
        expected_names.add(f"{_sanitize(symbol)}__{payload_checksum([symbol])}.txt")

    removed = 0
    for path in symbol_dir.glob("*.txt"):
        if path.name in expected_names:
            continue
        try:
            path.unlink()
            removed += 1
        except OSError:
            # Do not hide failure by deleting summary files. The next L11 publish will
            # still show write_degraded if the stale file could not be removed.
            pass
    return removed
