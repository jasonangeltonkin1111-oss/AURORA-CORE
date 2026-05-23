from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Iterable, List, Tuple
import csv
import io

from aurora_worker_io import atomic_write_text, payload_checksum, read_text, unix_time, utc_stamp

RENDER_INDEX_FOLDER = "RenderIndex"
RENDER_INDEX_MANIFEST_NAME = "render_index.manifest"
RENDER_INDEX_SCHEMA_VERSION = "1"
RENDER_INDEX_AUTHORITY = "calculation_support_only"

LAYER_SPECS = {
    "l6": {
        "layer_id": "6",
        "layer_folder": "Layer_6_Cost_Friction_Ranking",
        "index_name": "l6_symbol_rank_index.csv",
        "score_key": "friction_score",
        "bucket_key": "friction_bucket",
        "quality_key": "score_quality",
        "job_type": "L6_COST_FRICTION_RANKING_V1",
    },
    "l7": {
        "layer_id": "7",
        "layer_folder": "Layer_7_Session_Relevance_Ranking",
        "index_name": "l7_symbol_rank_index.csv",
        "score_key": "session_score",
        "bucket_key": "session_bucket",
        "quality_key": "score_quality",
        "job_type": "L7_SESSION_RELEVANCE_RANKING_V1",
    },
    "l8": {
        "layer_id": "8",
        "layer_folder": "Layer_8_Movement_Range_Ranking",
        "index_name": "l8_symbol_rank_index.csv",
        "score_key": "movement_score",
        "bucket_key": "movement_bucket",
        "quality_key": "score_quality",
        "job_type": "L8_MOVEMENT_RANGE_RANKING_V1",
    },
    "l9": {
        "layer_id": "9",
        "layer_folder": "Layer_9_Structure_Location_Geometry",
        "index_name": "l9_symbol_rank_index.csv",
        "score_key": "structure_watchlist_score",
        "bucket_key": "structure_bucket",
        "quality_key": "score_quality",
        "job_type": "L9_STRUCTURE_LOCATION_GEOMETRY_V1",
    },
}

INDEX_FIELDS = [
    "symbol",
    "layer_id",
    "rank_index",
    "score",
    "bucket",
    "rank_state",
    "score_quality",
    "rank_path",
    "rank_file_checksum",
    "source_ranked_manifest_checksum",
    "source_ranked_manifest_status",
    "generated_unix",
    "authority",
    "trade_permission",
    "selection_runtime",
    "execution",
]

OHLC_INDEX_FIELDS = [
    "symbol",
    "m5_ready",
    "m15_ready",
    "h1_ready",
    "h4_ready",
    "d1_ready",
    "l8_min_ready",
    "l9_required_ready",
    "authority",
    "trade_permission",
    "selection_runtime",
    "execution",
]


@dataclass
class LayerIndexSummary:
    layer_key: str
    status: str
    reason: str
    row_count: int = 0
    source_manifest_status: str = "not_available"
    source_manifest_checksum: str = "not_available"
    source_manifest_path: str = "not_available"
    symbol_rank_folder_path: str = "not_available"
    output_path: str = "not_available"
    output_checksum: str = "not_available"
    files_seen: int = 0
    files_indexed: int = 0
    files_skipped: int = 0


@dataclass
class RenderIndexSummary:
    status: str
    reason: str
    layer_summaries: List[LayerIndexSummary]
    ohlc_row_count: int = 0
    ohlc_index_checksum: str = "not_available"
    manifest_path: str = "not_available"


def _parse_kv_text(text: str) -> Dict[str, str]:
    data: Dict[str, str] = {}
    for raw_line in text.replace("\r\n", "\n").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        data[key.strip()] = value.strip()
    return data


def _safe_value(data: Dict[str, str], key: str, fallback: str = "not_available") -> str:
    value = data.get(key, fallback)
    if value is None:
        return fallback
    text = str(value).strip()
    return text if text else fallback


def _read_kv_or_empty(path: Path) -> Dict[str, str]:
    if not path.exists():
        return {}
    try:
        return _parse_kv_text(read_text(path))
    except OSError:
        return {}


def _csv_text(rows: List[Dict[str, str]], fields: List[str]) -> str:
    buffer = io.StringIO(newline="")
    writer = csv.DictWriter(buffer, fieldnames=fields, extrasaction="ignore")
    writer.writeheader()
    for row in rows:
        writer.writerow({field: row.get(field, "") for field in fields})
    return buffer.getvalue().replace("\r\n", "\n").replace("\n", "\r\n")


def _checksum_text_lines(text: str) -> str:
    rows = [line for line in text.replace("\r\n", "\n").splitlines() if line.strip()]
    return payload_checksum(rows)


def _symbol_rank_files(symbol_rank_dir: Path) -> Iterable[Path]:
    if not symbol_rank_dir.exists():
        return []
    return sorted(path for path in symbol_rank_dir.glob("*.txt") if path.is_file())


def _build_layer_index(outbox: Path, render_dir: Path, layer_key: str, generated_unix: int) -> LayerIndexSummary:
    spec = LAYER_SPECS[layer_key]
    layer_dir = outbox / "Layers" / spec["layer_folder"]
    manifest_path = layer_dir / "ranked_symbols.manifest"
    symbol_rank_dir = layer_dir / "SymbolRanks"
    output_path = render_dir / spec["index_name"]
    manifest = _read_kv_or_empty(manifest_path)
    source_status = _safe_value(manifest, "status", "missing_manifest")
    source_checksum = _safe_value(manifest, "payload_checksum", "not_available")
    files = list(_symbol_rank_files(symbol_rank_dir))

    rows: List[Dict[str, str]] = []
    skipped = 0
    for rank_file in files:
        data = _read_kv_or_empty(rank_file)
        symbol = _safe_value(data, "symbol", "")
        if not symbol:
            skipped += 1
            continue
        score = _safe_value(data, spec["score_key"], "not_available")
        bucket = _safe_value(data, spec["bucket_key"], "not_available")
        rank_state = _safe_value(data, "rank_state", "not_available")
        rank_index = _safe_value(data, "rank_index", "not_available")
        score_quality = _safe_value(data, spec["quality_key"], "not_available")
        rank_checksum = _safe_value(data, "symbol_rank_checksum", "not_available")
        if rank_checksum == "not_available":
            rank_checksum = _checksum_text_lines(read_text(rank_file))
        rows.append({
            "symbol": symbol,
            "layer_id": spec["layer_id"],
            "rank_index": rank_index,
            "score": score,
            "bucket": bucket,
            "rank_state": rank_state,
            "score_quality": score_quality,
            "rank_path": str(rank_file),
            "rank_file_checksum": rank_checksum,
            "source_ranked_manifest_checksum": source_checksum,
            "source_ranked_manifest_status": source_status,
            "generated_unix": str(generated_unix),
            "authority": RENDER_INDEX_AUTHORITY,
            "trade_permission": "false",
            "selection_runtime": "false",
            "execution": "false",
        })
    rows.sort(key=lambda row: (row["symbol"], row["layer_id"]))
    text = _csv_text(rows, INDEX_FIELDS)
    output_checksum = _checksum_text_lines(text)
    ok = atomic_write_text(output_path, text)
    status = "complete" if ok else "write_degraded"
    reason = "indexed_existing_symbol_rank_sidecars" if ok else "failed_to_write_layer_render_index"
    if not manifest:
        status = "missing_source_manifest"
        reason = "ranked_symbols.manifest missing or unreadable; index contains any discoverable SymbolRanks only"
    return LayerIndexSummary(
        layer_key=layer_key,
        status=status,
        reason=reason,
        row_count=len(rows),
        source_manifest_status=source_status,
        source_manifest_checksum=source_checksum,
        source_manifest_path=str(manifest_path),
        symbol_rank_folder_path=str(symbol_rank_dir),
        output_path=str(output_path),
        output_checksum=output_checksum,
        files_seen=len(files),
        files_indexed=len(rows),
        files_skipped=skipped,
    )


def _shared_ohlc_store_root(outbox: Path) -> Path:
    account_root = outbox.parents[2]
    server_root = account_root.parent
    return server_root / "Shared Market Data" / "OHLC Store"


def _symbol_from_rank_indexes(layer_summaries: List[LayerIndexSummary], render_dir: Path) -> List[str]:
    symbols: set[str] = set()
    for summary in layer_summaries:
        path = Path(summary.output_path)
        if not path.exists():
            continue
        try:
            reader = csv.DictReader(io.StringIO(read_text(path).replace("\r\n", "\n")))
            for row in reader:
                symbol = str(row.get("symbol", "")).strip()
                if symbol:
                    symbols.add(symbol)
        except OSError:
            continue
    return sorted(symbols)


def _priority_window_path(store_root: Path, symbol: str, tf: str) -> Path:
    return store_root / "Symbols" / symbol / "Priority Windows" / f"{tf}.window.csv"


def _build_ohlc_readiness_index(outbox: Path, render_dir: Path, layer_summaries: List[LayerIndexSummary]) -> Tuple[int, str, bool]:
    store_root = _shared_ohlc_store_root(outbox)
    symbols = _symbol_from_rank_indexes(layer_summaries, render_dir)
    rows: List[Dict[str, str]] = []
    for symbol in symbols:
        m5 = _priority_window_path(store_root, symbol, "M5").exists()
        m15 = _priority_window_path(store_root, symbol, "M15").exists()
        h1 = _priority_window_path(store_root, symbol, "H1").exists()
        h4 = _priority_window_path(store_root, symbol, "H4").exists()
        d1 = _priority_window_path(store_root, symbol, "D1").exists()
        rows.append({
            "symbol": symbol,
            "m5_ready": "true" if m5 else "false",
            "m15_ready": "true" if m15 else "false",
            "h1_ready": "true" if h1 else "false",
            "h4_ready": "true" if h4 else "false",
            "d1_ready": "true" if d1 else "false",
            "l8_min_ready": "true" if (m5 and m15 and h1) else "false",
            "l9_required_ready": "true" if (m15 and h1 and h4 and d1) else "false",
            "authority": RENDER_INDEX_AUTHORITY,
            "trade_permission": "false",
            "selection_runtime": "false",
            "execution": "false",
        })
    text = _csv_text(rows, OHLC_INDEX_FIELDS)
    checksum = _checksum_text_lines(text)
    ok = atomic_write_text(render_dir / "ohlc_window_readiness_index.csv", text)
    return len(rows), checksum, ok


def _manifest_text(worker_version: str, summary: RenderIndexSummary, generated_unix: int) -> str:
    lines = [
        "schema_name=aurora_render_index_manifest",
        f"schema_version={RENDER_INDEX_SCHEMA_VERSION}",
        f"worker_version={worker_version}",
        "layers_included=L6,L7,L8,L9",
        f"status={summary.status}",
        f"reason={summary.reason}",
        f"authority={RENDER_INDEX_AUTHORITY}",
        "trade_permission=false",
        "selection_runtime=false",
        "execution=false",
        f"ohlc_window_index_row_count={summary.ohlc_row_count}",
        f"ohlc_window_index_checksum={summary.ohlc_index_checksum}",
    ]
    for layer in summary.layer_summaries:
        prefix = layer.layer_key
        lines.extend([
            f"{prefix}_status={layer.status}",
            f"{prefix}_reason={layer.reason}",
            f"{prefix}_row_count={layer.row_count}",
            f"{prefix}_source_manifest_status={layer.source_manifest_status}",
            f"{prefix}_source_manifest_checksum={layer.source_manifest_checksum}",
            f"{prefix}_index_checksum={layer.output_checksum}",
            f"{prefix}_files_seen={layer.files_seen}",
            f"{prefix}_files_indexed={layer.files_indexed}",
            f"{prefix}_files_skipped={layer.files_skipped}",
            f"{prefix}_index_path={layer.output_path}",
            f"{prefix}_source_manifest_path={layer.source_manifest_path}",
        ])
    lines.extend([
        "source=existing_worker_sidecars_only",
        "publication_owner=mt5_runtime_7_remains_final_surface_publisher",
        f"generated_utc={utc_stamp()}",
        f"generated_unix={generated_unix}",
        "",
    ])
    return "\n".join(lines)


def publish_render_index(outbox: Path, worker_version: str) -> RenderIndexSummary:
    render_dir = outbox / RENDER_INDEX_FOLDER
    render_dir.mkdir(parents=True, exist_ok=True)
    generated_unix = unix_time()
    layer_summaries = [_build_layer_index(outbox, render_dir, layer_key, generated_unix) for layer_key in ("l6", "l7", "l8", "l9")]
    ohlc_rows, ohlc_checksum, ohlc_ok = _build_ohlc_readiness_index(outbox, render_dir, layer_summaries)
    complete_layers = sum(1 for item in layer_summaries if item.status == "complete")
    status = "complete" if complete_layers == 4 and ohlc_ok else "degraded"
    reason = "render_indexes_written_for_l6_l9" if status == "complete" else "one_or_more_render_indexes_degraded_or_missing_source"
    summary = RenderIndexSummary(status=status, reason=reason, layer_summaries=layer_summaries, ohlc_row_count=ohlc_rows, ohlc_index_checksum=ohlc_checksum, manifest_path=str(render_dir / RENDER_INDEX_MANIFEST_NAME))
    manifest = _manifest_text(worker_version, summary, generated_unix)
    if not atomic_write_text(render_dir / RENDER_INDEX_MANIFEST_NAME, manifest):
        summary.status = "write_degraded"
        summary.reason = "failed_to_write_render_index_manifest"
    return summary
