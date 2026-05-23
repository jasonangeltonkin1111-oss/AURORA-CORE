from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import List, Tuple

from aurora_worker_io import atomic_write_text, payload_checksum, utc_stamp, unix_time
from aurora_worker_l9_contract import (
    L9_AUTHORITY,
    L9_INPUT_MANIFEST_NAME,
    L9_INPUT_NAME,
    L9_JOB_TYPE,
    L9_LAYER_FOLDER,
    L9_LAYER_NAME,
    L9_MANIFEST_NAME,
    L9_MODEL_VERSION,
    L9_OWNER,
    L9_POLICY,
    L9_RANKED_NAME,
    L9_SCORE_WEIGHTS,
    L9_SOURCE_OWNER,
    L9_SYMBOL_RANK_FILENAME_MODE,
    L9_SYMBOL_RANK_FOLDER,
    L9_TF_WEIGHTS,
    L9_TOP20_NAME,
)


@dataclass
class L9RankSummary:
    status: str
    reason: str
    input_count: int = 0
    row_count: int = 0
    ranked_count: int = 0
    ranked_partial_count: int = 0
    ranked_risk_review_count: int = 0
    not_rankable_quality_count: int = 0
    elite_count: int = 0
    strong_count: int = 0
    acceptable_count: int = 0
    weak_count: int = 0
    low_attention_count: int = 0
    near_high_event_zone_count: int = 0
    near_low_event_zone_count: int = 0
    midrange_low_attention_count: int = 0
    compression_at_boundary_count: int = 0
    symbol_rank_files_written: int = 0
    symbol_rank_files_actual: int = 0
    symbol_rank_filename_mode: str = L9_SYMBOL_RANK_FILENAME_MODE
    payload_checksum: str = "not_available"
    ranked_csv_path: str = "not_available"
    manifest_path: str = "not_available"
    top20_path: str = "not_available"
    symbol_rank_folder_path: str = "not_available"


def _layer_dir(outbox: Path) -> Path:
    return outbox / "Layers" / L9_LAYER_FOLDER


def _shared_ohlc_store_root(outbox: Path) -> Path:
    # outbox = <server>/<account>/Workbench/Gateway/Outbox
    account_root = outbox.parents[2]
    server_root = account_root.parent
    return server_root / "Shared Market Data" / "OHLC Store"


def _format_weights(weights: dict[str, float]) -> str:
    return ",".join(f"{key}:{value:g}" for key, value in weights.items())


def _count_final_symbol_rank_files(symbol_rank_dir: Path) -> int:
    if not symbol_rank_dir.exists():
        return 0
    return sum(1 for path in symbol_rank_dir.glob("*.txt") if path.is_file())


def _read_nonempty_lines(path: Path) -> List[str]:
    if not path.exists():
        return []
    return [line for line in path.read_text(encoding="utf-8", errors="replace").replace("\r\n", "\n").splitlines() if line.strip()]


def _cleanup_pending_stale_outputs(layer_dir: Path, symbol_rank_dir: Path) -> Tuple[int, int]:
    removed = failed = 0
    for path in (layer_dir / L9_RANKED_NAME, layer_dir / L9_TOP20_NAME):
        if not path.exists():
            continue
        try:
            path.unlink()
            removed += 1
        except OSError:
            failed += 1
    if symbol_rank_dir.exists():
        for path in symbol_rank_dir.glob("*.txt"):
            try:
                path.unlink()
                removed += 1
            except OSError:
                failed += 1
    return removed, failed


def _manifest(summary: L9RankSummary, input_path: Path, input_manifest_path: Path, store_root: Path, stale_removed: int, stale_failed: int) -> str:
    reason = str(summary.reason).replace("\r", " ").replace("\n", " ")[:640]
    return "\n".join([
        "schema_name=layer_ranked_symbols_manifest",
        "schema_version=1",
        "layer_id=9",
        f"layer_name={L9_LAYER_NAME}",
        f"owner_name={L9_OWNER}",
        f"job_type={L9_JOB_TYPE}",
        f"l9_model_version={L9_MODEL_VERSION}",
        f"status={summary.status}",
        f"reason={reason}",
        f"input_csv_path={input_path}",
        f"input_manifest_path={input_manifest_path}",
        f"shared_ohlc_store_root={store_root}",
        "ohlc_route=OHLC_Store/Symbols/<symbol>/Priority_Windows/<TF>.window.csv",
        f"required_timeframe_weights={_format_weights(L9_TF_WEIGHTS)}",
        f"score_weights={_format_weights(L9_SCORE_WEIGHTS)}",
        f"input_count={summary.input_count}",
        f"row_count={summary.row_count}",
        f"ranked_count={summary.ranked_count}",
        f"ranked_partial_count={summary.ranked_partial_count}",
        f"ranked_risk_review_count={summary.ranked_risk_review_count}",
        f"not_rankable_quality_count={summary.not_rankable_quality_count}",
        f"elite_structure_watch_count={summary.elite_count}",
        f"strong_structure_watch_count={summary.strong_count}",
        f"acceptable_structure_watch_count={summary.acceptable_count}",
        f"weak_structure_watch_count={summary.weak_count}",
        f"low_attention_structure_count={summary.low_attention_count}",
        f"near_high_event_zone_count={summary.near_high_event_zone_count}",
        f"near_low_event_zone_count={summary.near_low_event_zone_count}",
        f"midrange_low_attention_count={summary.midrange_low_attention_count}",
        f"compression_at_boundary_count={summary.compression_at_boundary_count}",
        f"symbol_rank_filename_mode={summary.symbol_rank_filename_mode}",
        f"symbol_rank_files_written={summary.symbol_rank_files_written}",
        f"symbol_rank_files_actual={summary.symbol_rank_files_actual}",
        f"symbol_rank_file_count_ok={'true' if summary.symbol_rank_files_written == summary.row_count and summary.symbol_rank_files_actual == summary.row_count else 'false'}",
        f"stale_output_files_removed={stale_removed}",
        f"stale_output_files_failed={stale_failed}",
        f"payload_checksum={summary.payload_checksum}",
        f"ranked_csv_path={summary.ranked_csv_path}",
        f"ranked_manifest_path={summary.manifest_path}",
        f"top20_path={summary.top20_path}",
        f"symbol_rank_folder_path={summary.symbol_rank_folder_path}",
        f"authority={L9_AUTHORITY}",
        "trade_permission=false",
        "ranking_runtime=false",
        "selection_runtime=false",
        "entry_signal=false",
        f"structure_location_policy={L9_POLICY}",
        f"source_owner={L9_SOURCE_OWNER}",
        "master_module_status=not_built_yet",
        "module_plan=contract_then_price_basis_then_windows_then_tf_location_then_boundary_quality_then_room_profile_then_event_zone_then_master_ranker",
        "publication_order=contract_manifest_only_until_l9_input_and_scoring_modules_exist",
        f"generated_utc={utc_stamp()}",
        f"generated_unix={unix_time()}",
        "",
    ])


def _top20_pending_text(summary: L9RankSummary) -> str:
    return "\n".join([
        "LAYER 9 - STRUCTURE / LOCATION GEOMETRY - TOP 20",
        "----------------------------------------",
        f"Generated UTC: {utc_stamp()}",
        "Status: Pending / contract only",
        "Trade Permission: FALSE",
        "Selection Runtime: FALSE",
        "Entry Signal: FALSE",
        f"Model Version: {L9_MODEL_VERSION}",
        f"Policy: {L9_POLICY}",
        "Source: Runtime 1 Shared OHLC Priority Windows + L5 pass set only",
        f"Reason: {summary.reason}",
        "",
        "rank|symbol|score|bucket|state|event_zone|reason",
        "",
    ])


def publish_l9_structure_location_rankings(outbox: Path) -> L9RankSummary:
    layer_dir = _layer_dir(outbox)
    input_path = layer_dir / L9_INPUT_NAME
    input_manifest_path = layer_dir / L9_INPUT_MANIFEST_NAME
    ranked_path = layer_dir / L9_RANKED_NAME
    manifest_path = layer_dir / L9_MANIFEST_NAME
    top20_path = layer_dir / L9_TOP20_NAME
    symbol_rank_dir = layer_dir / L9_SYMBOL_RANK_FOLDER
    store_root = _shared_ohlc_store_root(outbox)
    layer_dir.mkdir(parents=True, exist_ok=True)
    symbol_rank_dir.mkdir(parents=True, exist_ok=True)

    stale_removed, stale_failed = _cleanup_pending_stale_outputs(layer_dir, symbol_rank_dir)
    input_lines = _read_nonempty_lines(input_path)
    input_count = max(0, len(input_lines) - 1) if input_lines else 0

    if input_path.exists() and input_manifest_path.exists():
        status = "pending_scoring_modules"
        reason = "l9 input contract exists; scoring submodules are not built yet"
    elif input_path.exists():
        status = "pending_input_manifest"
        reason = "l9_input_primitives.csv exists but l9_input_primitives.manifest is missing"
    else:
        status = "pending_input_contract"
        reason = "l9 input primitives not exported yet; L9 is contract-only and must not invent source data"

    summary = L9RankSummary(
        status=status,
        reason=reason,
        input_count=input_count,
        row_count=0,
        ranked_csv_path=str(ranked_path),
        manifest_path=str(manifest_path),
        top20_path=str(top20_path),
        symbol_rank_folder_path=str(symbol_rank_dir),
    )
    summary.symbol_rank_files_actual = _count_final_symbol_rank_files(symbol_rank_dir)
    manifest_text = _manifest(summary, input_path, input_manifest_path, store_root, stale_removed, stale_failed)
    summary.payload_checksum = payload_checksum(manifest_text.splitlines())
    manifest_text = manifest_text.replace("payload_checksum=not_available", f"payload_checksum={summary.payload_checksum}")

    atomic_write_text(top20_path, _top20_pending_text(summary))
    atomic_write_text(manifest_path, manifest_text)
    return summary
