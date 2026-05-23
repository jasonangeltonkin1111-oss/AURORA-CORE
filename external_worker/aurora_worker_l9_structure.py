from __future__ import annotations

from pathlib import Path

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
    L9_SYMBOL_RANK_FOLDER,
    L9_TF_WEIGHTS,
    L9_TOP20_NAME,
)
from aurora_worker_l9_score import L9FinalSummary, publish_l9_structure_scores


def _layer_dir(outbox: Path) -> Path:
    return outbox / "Layers" / L9_LAYER_FOLDER


def _shared_ohlc_store_root(outbox: Path) -> Path:
    account_root = outbox.parents[2]
    server_root = account_root.parent
    return server_root / "Shared Market Data" / "OHLC Store"


def _format_weights(weights: dict[str, float]) -> str:
    return ",".join(f"{key}:{value:g}" for key, value in weights.items())


def _pending_manifest(summary: L9FinalSummary, input_path: Path, input_manifest_path: Path, store_root: Path) -> str:
    reason = str(summary.reason).replace("\r", " ").replace("\n", " ")[:640]
    return "\n".join([
        "schema_name=layer_ranked_symbols_manifest",
        "schema_version=2",
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
        "symbol_rank_file_count_ok=false",
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
        "publication_order=score_when_l9_input_exists_else_pending_manifest_only",
        f"generated_utc={utc_stamp()}",
        f"generated_unix={unix_time()}",
        "",
    ])


def _top20_pending_text(summary: L9FinalSummary) -> str:
    return "\n".join([
        "LAYER 9 - STRUCTURE / LOCATION GEOMETRY - TOP 20",
        "----------------------------------------",
        f"Generated UTC: {utc_stamp()}",
        "Status: Pending",
        "Trade Permission: FALSE",
        "Selection Runtime: FALSE",
        "Entry Signal: FALSE",
        f"Model Version: {L9_MODEL_VERSION}",
        f"Policy: {L9_POLICY}",
        "Source: Runtime 1 Shared OHLC Priority Windows + L9 input primitives",
        f"Reason: {summary.reason}",
        "",
        "rank|symbol|score|bucket|state|event_zone|reason",
        "",
    ])


def publish_l9_structure_location_rankings(outbox: Path) -> L9FinalSummary:
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

    if input_path.exists() and input_manifest_path.exists():
        return publish_l9_structure_scores(outbox)

    status = "pending_input_manifest" if input_path.exists() else "pending_input_contract"
    reason = "l9_input_primitives.csv exists but manifest is missing" if input_path.exists() else "l9 input primitives not exported yet; L9 must not invent source data"
    summary = L9FinalSummary(
        status=status,
        reason=reason,
        input_count=0,
        row_count=0,
        ranked_csv_path=str(ranked_path),
        manifest_path=str(manifest_path),
        top20_path=str(top20_path),
        symbol_rank_folder_path=str(symbol_rank_dir),
    )
    manifest_text = _pending_manifest(summary, input_path, input_manifest_path, store_root)
    summary.payload_checksum = payload_checksum(manifest_text.splitlines())
    manifest_text = manifest_text.replace("payload_checksum=not_available", f"payload_checksum={summary.payload_checksum}")
    atomic_write_text(top20_path, _top20_pending_text(summary))
    atomic_write_text(manifest_path, manifest_text)
    return summary
