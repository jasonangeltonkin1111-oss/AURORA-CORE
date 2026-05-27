from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Tuple

from aurora_worker_io import WorkerPaths, atomic_write_text, read_kv, unix_time, utc_stamp

SURFACE_OVERSEER_SCHEMA_VERSION = "5"
SURFACE_OVERSEER_STATUS_NAME = "surface_overseer_status.txt"
EXPECTED_AUTHORITY = "calculation_support_only"

RANKED_MANIFEST_NAME = "ranked_symbols.manifest"
STATUS_SURFACE_NAMES = ("l18_status.txt", "l19_status.txt")
LAYER_RANKED_MANIFEST_NAMES = (
    "ranked_symbols.manifest",
    "ranked_symbols_by_group.manifest",
    "l12_group_heat_quality.manifest",
)
INPUT_MANIFEST_SUFFIXES = ("_input_primitives.manifest", "input_primitives.manifest")
L10_AUXILIARY_INPUT_MANIFESTS = {"l10_runtime2_universe_rows.manifest"}
RANKED_OUTPUT_AUTHORITIES = {
    "calculation_support_only",
    "taxonomy_classification_only",
    "intra_group_inspection_priority_only",
    "ranking_group_attention_quality_only",
    "ranking_group_selection_only",
    "candidate_pool_sourcing_only",
    "correlation_diversity_scoring_only",
    "global_top10_inspection_basket_only",
    "deep_evidence_selection_split_only",
    "raw_ohlc_bar_pack_only",
    "wick_candle_geometry_pack_only",
}
RANKED_OUTPUT_ACCEPTED_STATUSES = {"complete", "accepted", "degraded", "write_degraded", "not_available"}
STATUS_SURFACE_ACCEPTED_STATUSES = {"complete", "accepted", "ready", "fresh", "ok"}
STATUS_SURFACE_PENDING_STATUSES = {"pending", "pending_input", "pending_input_contract", "pending_input_manifest", "not_available", "not_ready", "queued", "waiting"}
STATUS_SURFACE_DEGRADED_STATUSES = {"degraded", "write_degraded", "partial", "stale", "aging", "missing_data", "missing_source", "incomplete"}
SYMBOL_RANK_FILE_CONTRACT_LAYERS = {"6", "7", "8", "9"}


@dataclass
class LayerSurfaceProof:
    folder_name: str
    manifest_path: str
    layer_id: str = "not_available"
    layer_name: str = "not_available"
    job_type: str = "not_available"
    manifest_role: str = "unknown"
    lifecycle_state: str = "missing_manifest"
    status: str = "missing_manifest"
    reason: str = "manifest missing"
    input_count: int = 0
    row_count: int = 0
    symbol_rank_files_written: int = 0
    symbol_rank_files_actual: int = 0
    payload_checksum: str = "not_available"
    input_payload_checksum: str = "not_available"
    input_generation_stable: str = "not_available"
    authority: str = "not_available"
    trade_permission: str = "not_available"
    selection_runtime: str = "not_available"
    ranking_runtime: str = "not_available"
    accepted: bool = False
    pending: bool = False
    status_only: bool = False
    honest_degraded: bool = False
    mismatch: bool = True
    mismatch_reason: str = "manifest missing"


@dataclass
class SurfaceOverseerSummary:
    status: str
    reason: str
    layer_count: int = 0
    accepted_layer_count: int = 0
    pending_layer_count: int = 0
    status_only_layer_count: int = 0
    degraded_layer_count: int = 0
    mismatch_count: int = 0
    newest_manifest_unix: int = 0
    status_path: str = "not_available"
    write_ok: bool = False


def _safe_int(value: str | None, default: int = 0) -> int:
    try:
        if value is None:
            return default
        text = str(value).strip()
        if text == "" or text.lower() in {"not_available", "missing", "pending", "nan"}:
            return default
        return int(float(text))
    except Exception:
        return default


def _safe_text(value: object, default: str = "not_available") -> str:
    text = str(value if value is not None else "").replace("\r", " ").replace("\n", " ").strip()
    return text if text else default


def _is_input_manifest(path: Path) -> bool:
    name = path.name.lower()
    return any(name.endswith(suffix) for suffix in INPUT_MANIFEST_SUFFIXES) or name.endswith("_input.manifest")


def _is_layer_ranked_manifest(path: Path) -> bool:
    return path.name.lower() in LAYER_RANKED_MANIFEST_NAMES


def _is_status_surface(path: Path) -> bool:
    return path.name.lower() in STATUS_SURFACE_NAMES


def _manifest_candidates(layer_dir: Path) -> List[Path]:
    ranked = sorted(p for p in layer_dir.glob("*.manifest") if p.is_file() and _is_layer_ranked_manifest(p))
    if ranked:
        return ranked[:1]
    input_manifests = sorted(p for p in layer_dir.glob("*.manifest") if p.is_file() and _is_input_manifest(p))
    if input_manifests:
        return input_manifests[:1]
    manifests = sorted(p for p in layer_dir.glob("*.manifest") if p.is_file())
    if manifests:
        return manifests[:1]
    status_surfaces = sorted(p for p in layer_dir.glob("*.txt") if p.is_file() and _is_status_surface(p))
    return status_surfaces[:1]


def _manifest_role(path: Path) -> str:
    if path.name.lower() in L10_AUXILIARY_INPUT_MANIFESTS:
        return "input_source_manifest"
    if _is_layer_ranked_manifest(path):
        return "ranked_output"
    if _is_input_manifest(path):
        return "input_primitives"
    if _is_status_surface(path):
        return "status_freshness_surface"
    return "generic_manifest"


def _layer_has_symbol_rank_file_contract(data: Dict[str, str], proof: LayerSurfaceProof) -> bool:
    """Return true only when a layer is expected to publish one symbol rank file per row.

    L15-L17 publish CSV/report/selection surfaces. Their row_count is not supposed to
    equal numbered symbol rank files, so zero symbol_rank_files_* counters must not
    degrade them. L6-L9 ranked-sidecar layers still keep strict file-count proof.
    """
    explicit = _safe_text(
        data.get("symbol_rank_file_contract", data.get("file_contract", data.get("rank_file_contract"))),
        "not_available",
    ).lower()
    if explicit in {"per_row", "one_file_per_row", "symbol_rank_files_per_row", "true", "required"}:
        return True
    if explicit in {"none", "not_required", "surface_only", "csv_only", "report_only", "false"}:
        return False
    layer_id = _safe_text(proof.layer_id, "").strip()
    if layer_id in SYMBOL_RANK_FILE_CONTRACT_LAYERS:
        return True
    return False


def _infer_status_layer_id(layer_dir: Path) -> str:
    name = layer_dir.name.lower().replace("-", "_")
    if "l18" in name or "layer18" in name or "layer_18" in name:
        return "18"
    if "l19" in name or "layer19" in name or "layer_19" in name:
        return "19"
    return "not_available"


def _layer_from_manifest(layer_dir: Path, manifest_path: Path) -> LayerSurfaceProof:
    role = _manifest_role(manifest_path)
    proof = LayerSurfaceProof(folder_name=layer_dir.name, manifest_path=str(manifest_path), manifest_role=role)
    try:
        data: Dict[str, str] = read_kv(manifest_path)
    except Exception as exc:
        proof.status = "unreadable_manifest"
        proof.lifecycle_state = "degraded"
        proof.reason = f"manifest unreadable: {type(exc).__name__}: {_safe_text(exc)}"
        proof.mismatch_reason = proof.reason
        return proof

    proof.layer_id = data.get("layer_id", data.get("layer", "not_available"))
    if proof.layer_id == "not_available" and role == "status_freshness_surface":
        proof.layer_id = _infer_status_layer_id(layer_dir)
    proof.layer_name = data.get("layer_name", layer_dir.name)
    proof.job_type = data.get("job_type", "not_available")
    proof.status = data.get("status", "not_available")
    proof.reason = data.get("reason", "not_available")
    proof.input_count = _safe_int(data.get("input_count"), _safe_int(data.get("source_input_manifest_row_count"), _safe_int(data.get("row_count"), _safe_int(data.get("l5_gate_pass")))))
    proof.row_count = _safe_int(data.get("row_count"), proof.input_count if role == "input_primitives" else 0)
    proof.symbol_rank_files_written = _safe_int(data.get("symbol_rank_files_written"))
    proof.symbol_rank_files_actual = _safe_int(data.get("symbol_rank_files_actual"))
    proof.payload_checksum = data.get("payload_checksum", "not_available")
    proof.input_payload_checksum = data.get("input_payload_checksum", data.get("source_input_payload_checksum", proof.payload_checksum))
    proof.input_generation_stable = data.get("input_generation_stable", "not_available")
    safe_support_role = role in {"input_primitives", "input_source_manifest", "status_freshness_surface"}
    proof.authority = data.get("authority", EXPECTED_AUTHORITY if safe_support_role else "not_available")
    proof.trade_permission = data.get("trade_permission", "false" if safe_support_role else "not_available")
    proof.selection_runtime = data.get("selection_runtime", "false" if safe_support_role else "not_available")
    proof.ranking_runtime = data.get("ranking_runtime", "false" if safe_support_role else "not_available")
    entry_signal = data.get("entry_signal", "false" if safe_support_role else "not_available")
    execution = data.get("execution", "false" if safe_support_role else "not_available")

    failures: List[str] = []
    authority_ok = proof.authority in RANKED_OUTPUT_AUTHORITIES if role in {"ranked_output", "generic_manifest"} else proof.authority == EXPECTED_AUTHORITY
    trade_ok = proof.trade_permission == "false"
    selection_ok = proof.selection_runtime in {"false", "not_available"}
    entry_ok = entry_signal in {"false", "not_available"}
    execution_ok = execution in {"false", "not_available"}
    if not authority_ok:
        failures.append(f"authority={proof.authority}")
    if not trade_ok:
        failures.append(f"trade_permission={proof.trade_permission}")
    if not selection_ok:
        failures.append(f"selection_runtime={proof.selection_runtime}")
    if not entry_ok:
        failures.append(f"entry_signal={entry_signal}")
    if not execution_ok:
        failures.append(f"execution={execution}")

    if role in {"input_primitives", "input_source_manifest"}:
        row_ok = proof.row_count >= 0 and (proof.input_count <= 0 or proof.row_count == proof.input_count)
        if not row_ok:
            failures.append(f"input_row_count={proof.row_count}/input_count={proof.input_count}")
        proof.pending = len(failures) == 0
        proof.accepted = False
        proof.mismatch = len(failures) > 0
        proof.lifecycle_state = "input_ready_rank_pending" if proof.pending else "input_degraded"
        proof.mismatch_reason = "none_input_waiting_for_ranked_output" if proof.pending else ";".join(failures)
        if proof.reason == "not_available":
            proof.reason = "input primitives manifest present; ranked output manifest not published yet"
        return proof

    if role == "status_freshness_surface":
        status = proof.status.lower()
        proof.status_only = True
        if failures:
            proof.accepted = False
            proof.pending = False
            proof.honest_degraded = False
            proof.mismatch = True
            proof.lifecycle_state = "status_surface_mismatch"
            proof.mismatch_reason = ";".join(failures)
        elif status in STATUS_SURFACE_PENDING_STATUSES:
            proof.accepted = False
            proof.pending = True
            proof.honest_degraded = False
            proof.mismatch = False
            proof.lifecycle_state = "status_surface_pending"
            proof.mismatch_reason = "none_status_surface_pending"
        elif status in STATUS_SURFACE_DEGRADED_STATUSES:
            proof.accepted = False
            proof.pending = False
            proof.honest_degraded = True
            proof.mismatch = False
            proof.lifecycle_state = "status_surface_honest_degraded"
            proof.mismatch_reason = "none_status_surface_honest_degraded"
        elif status in STATUS_SURFACE_ACCEPTED_STATUSES:
            proof.accepted = True
            proof.pending = False
            proof.honest_degraded = False
            proof.mismatch = False
            proof.lifecycle_state = "status_surface_accepted"
            proof.mismatch_reason = "none_status_surface"
        else:
            proof.accepted = False
            proof.pending = False
            proof.honest_degraded = True
            proof.mismatch = False
            proof.lifecycle_state = "status_surface_honest_degraded"
            proof.mismatch_reason = f"none_status_surface_unmapped_status={proof.status}"
        return proof

    status_ok = proof.status in RANKED_OUTPUT_ACCEPTED_STATUSES
    row_ok = proof.row_count >= 0 and (proof.input_count <= 0 or proof.row_count == proof.input_count)
    checksum_ok = proof.payload_checksum != "not_available" or role == "generic_manifest"
    files_ok = True
    if _layer_has_symbol_rank_file_contract(data, proof):
        files_ok = proof.symbol_rank_files_written == proof.row_count and proof.symbol_rank_files_actual == proof.row_count

    if not status_ok:
        failures.append(f"status={proof.status}")
    if not row_ok:
        failures.append(f"row_count={proof.row_count}/input_count={proof.input_count}")
    if not checksum_ok:
        failures.append("payload_checksum=not_available")
    if not files_ok:
        failures.append(f"symbol_rank_files_written={proof.symbol_rank_files_written}/actual={proof.symbol_rank_files_actual}/row_count={proof.row_count}")

    proof.accepted = len(failures) == 0
    proof.pending = False
    proof.mismatch = not proof.accepted
    proof.lifecycle_state = f"{role}_accepted" if proof.accepted else f"{role}_degraded"
    proof.mismatch_reason = "none" if proof.accepted else ";".join(failures)
    return proof


def _discover_layer_proofs(paths: WorkerPaths) -> Tuple[List[LayerSurfaceProof], int]:
    layers_root = paths.outbox / "Layers"
    proofs: List[LayerSurfaceProof] = []
    newest = 0
    if not layers_root.exists():
        return proofs, newest
    for layer_dir in sorted(p for p in layers_root.iterdir() if p.is_dir()):
        candidates = _manifest_candidates(layer_dir)
        if not candidates:
            proofs.append(LayerSurfaceProof(folder_name=layer_dir.name, manifest_path=str(layer_dir / RANKED_MANIFEST_NAME)))
            continue
        manifest = candidates[0]
        try:
            newest = max(newest, int(manifest.stat().st_mtime))
        except OSError:
            pass
        proofs.append(_layer_from_manifest(layer_dir, manifest))
    return proofs, newest


def _status_text(summary: SurfaceOverseerSummary, proofs: List[LayerSurfaceProof]) -> str:
    lines = [
        "schema_name=aurora_gateway_surface_overseer_status",
        f"schema_version={SURFACE_OVERSEER_SCHEMA_VERSION}",
        f"status={summary.status}",
        f"reason={summary.reason}",
        f"layer_count={summary.layer_count}",
        f"accepted_layer_count={summary.accepted_layer_count}",
        f"pending_layer_count={summary.pending_layer_count}",
        f"status_only_layer_count={summary.status_only_layer_count}",
        f"degraded_layer_count={summary.degraded_layer_count}",
        f"mismatch_count={summary.mismatch_count}",
        f"newest_manifest_unix={summary.newest_manifest_unix}",
        "scope=layer_agnostic_gateway_sidecar_manifest_observer",
        "lifecycle_policy=ranked_outputs_must_align_input_manifests_input_only_layers_are_pending_not_mismatch",
        "file_count_policy=symbol_rank_file_counts_checked_only_for_per_row_rank_file_contract_layers",
        "surface_write_authority=false",
        "ea_publication_authority=true",
        "authority=calculation_support_only",
        "trade_permission=false",
        "selection_runtime=false",
        f"generated_utc={utc_stamp()}",
        f"generated_unix={unix_time()}",
        "",
        "folder_name|layer_id|manifest_role|lifecycle_state|status|accepted|pending|status_only|honest_degraded|mismatch|row_count|input_count|symbol_rank_files_actual|payload_checksum|mismatch_reason|manifest_path",
    ]
    for proof in proofs:
        lines.append("|".join([
            _safe_text(proof.folder_name),
            _safe_text(proof.layer_id),
            _safe_text(proof.manifest_role),
            _safe_text(proof.lifecycle_state),
            _safe_text(proof.status),
            "true" if proof.accepted else "false",
            "true" if proof.pending else "false",
            "true" if proof.status_only else "false",
            "true" if proof.honest_degraded else "false",
            "true" if proof.mismatch else "false",
            str(proof.row_count),
            str(proof.input_count),
            str(proof.symbol_rank_files_actual),
            _safe_text(proof.payload_checksum),
            _safe_text(proof.mismatch_reason),
            _safe_text(proof.manifest_path),
        ]))
    lines.append("")
    return "\n".join(lines)


def publish_surface_overseer_status(paths: WorkerPaths) -> SurfaceOverseerSummary:
    """Publish layer-agnostic Gateway sidecar freshness/mismatch proof.

    This is not a new EXE and not a surface writer. It runs inside the existing
    Gateway worker and writes only Gateway-owned status proof. EA/MT5 remains the
    publication authority for Market Board, Workbench, Dossiers, and trading state.
    """
    status_path = paths.status / SURFACE_OVERSEER_STATUS_NAME
    proofs, newest = _discover_layer_proofs(paths)
    layer_count = len(proofs)
    accepted = sum(1 for p in proofs if p.accepted)
    pending = sum(1 for p in proofs if p.pending)
    status_only = sum(1 for p in proofs if p.status_only)
    mismatch_count = sum(1 for p in proofs if p.mismatch)
    degraded = sum(1 for p in proofs if p.honest_degraded)
    if layer_count <= 0:
        status = "no_layers_found"
        reason = "Outbox/Layers contains no layer directories"
    elif mismatch_count == 0 and degraded > 0:
        status = "honest_degraded_due_to_missing_data"
        reason = f"{degraded} layer status surface(s) report degraded/pending data without contract mismatch"
    elif mismatch_count == 0 and pending == 0 and status_only > 0:
        status = "accepted_with_status_only_layers"
        reason = "all discovered Gateway layer manifests are aligned; status-only layers are observational"
    elif mismatch_count == 0 and pending == 0:
        status = "accepted"
        reason = "all discovered Gateway layer ranked manifests are internally aligned"
    elif mismatch_count == 0:
        status = "accepted_with_pending_layers"
        reason = f"{pending} layer manifest(s) are input-ready but awaiting ranked output"
    else:
        status = "mismatch_detected"
        reason = f"{mismatch_count} layer manifest(s) are degraded or internally mismatched"
    summary = SurfaceOverseerSummary(
        status=status,
        reason=reason,
        layer_count=layer_count,
        accepted_layer_count=accepted,
        pending_layer_count=pending,
        status_only_layer_count=status_only,
        degraded_layer_count=degraded,
        mismatch_count=mismatch_count,
        newest_manifest_unix=newest,
        status_path=str(status_path),
        write_ok=False,
    )
    summary.write_ok = atomic_write_text(status_path, _status_text(summary, proofs))
    return summary
