from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Tuple

from aurora_worker_io import WorkerPaths, atomic_write_text, read_kv, unix_time, utc_stamp

SURFACE_OVERSEER_SCHEMA_VERSION = "1"
SURFACE_OVERSEER_STATUS_NAME = "surface_overseer_status.txt"
EXPECTED_AUTHORITY = "calculation_support_only"


@dataclass
class LayerSurfaceProof:
    folder_name: str
    manifest_path: str
    layer_id: str = "not_available"
    layer_name: str = "not_available"
    job_type: str = "not_available"
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
    mismatch: bool = True
    mismatch_reason: str = "manifest missing"


@dataclass
class SurfaceOverseerSummary:
    status: str
    reason: str
    layer_count: int = 0
    accepted_layer_count: int = 0
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


def _manifest_candidates(layer_dir: Path) -> List[Path]:
    preferred = [layer_dir / "ranked_symbols.manifest"]
    if preferred[0].exists():
        return preferred
    manifests = sorted(p for p in layer_dir.glob("*.manifest") if p.is_file())
    return manifests[:1]


def _layer_from_manifest(layer_dir: Path, manifest_path: Path) -> LayerSurfaceProof:
    proof = LayerSurfaceProof(folder_name=layer_dir.name, manifest_path=str(manifest_path))
    try:
        data: Dict[str, str] = read_kv(manifest_path)
    except Exception as exc:
        proof.status = "unreadable_manifest"
        proof.reason = f"manifest unreadable: {type(exc).__name__}: {_safe_text(exc)}"
        proof.mismatch_reason = proof.reason
        return proof

    proof.layer_id = data.get("layer_id", data.get("layer", "not_available"))
    proof.layer_name = data.get("layer_name", layer_dir.name)
    proof.job_type = data.get("job_type", "not_available")
    proof.status = data.get("status", "not_available")
    proof.reason = data.get("reason", "not_available")
    proof.input_count = _safe_int(data.get("input_count"), _safe_int(data.get("source_input_manifest_row_count")))
    proof.row_count = _safe_int(data.get("row_count"))
    proof.symbol_rank_files_written = _safe_int(data.get("symbol_rank_files_written"))
    proof.symbol_rank_files_actual = _safe_int(data.get("symbol_rank_files_actual"))
    proof.payload_checksum = data.get("payload_checksum", "not_available")
    proof.input_payload_checksum = data.get("input_payload_checksum", data.get("source_input_payload_checksum", "not_available"))
    proof.input_generation_stable = data.get("input_generation_stable", "not_available")
    proof.authority = data.get("authority", "not_available")
    proof.trade_permission = data.get("trade_permission", "not_available")
    proof.selection_runtime = data.get("selection_runtime", "not_available")
    proof.ranking_runtime = data.get("ranking_runtime", "not_available")

    status_ok = proof.status in {"complete", "input_degraded"}
    authority_ok = proof.authority == EXPECTED_AUTHORITY
    trade_ok = proof.trade_permission == "false"
    selection_ok = proof.selection_runtime in {"false", "not_available"}
    row_ok = proof.row_count >= 0 and (proof.input_count <= 0 or proof.row_count == proof.input_count)
    files_ok = True
    if "symbol_rank_files_written" in data or "symbol_rank_files_actual" in data:
        files_ok = proof.symbol_rank_files_written == proof.row_count and proof.symbol_rank_files_actual == proof.row_count

    failures: List[str] = []
    if not status_ok:
        failures.append(f"status={proof.status}")
    if not authority_ok:
        failures.append(f"authority={proof.authority}")
    if not trade_ok:
        failures.append(f"trade_permission={proof.trade_permission}")
    if not selection_ok:
        failures.append(f"selection_runtime={proof.selection_runtime}")
    if not row_ok:
        failures.append(f"row_count={proof.row_count}/input_count={proof.input_count}")
    if not files_ok:
        failures.append(f"symbol_rank_files_written={proof.symbol_rank_files_written}/actual={proof.symbol_rank_files_actual}/row_count={proof.row_count}")

    proof.accepted = len(failures) == 0
    proof.mismatch = not proof.accepted
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
            proofs.append(LayerSurfaceProof(folder_name=layer_dir.name, manifest_path=str(layer_dir / "ranked_symbols.manifest")))
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
        f"degraded_layer_count={summary.degraded_layer_count}",
        f"mismatch_count={summary.mismatch_count}",
        f"newest_manifest_unix={summary.newest_manifest_unix}",
        "scope=layer_agnostic_gateway_sidecar_manifest_observer",
        "surface_write_authority=false",
        "ea_publication_authority=true",
        "authority=calculation_support_only",
        "trade_permission=false",
        "selection_runtime=false",
        f"generated_utc={utc_stamp()}",
        f"generated_unix={unix_time()}",
        "",
        "folder_name|layer_id|status|accepted|mismatch|row_count|input_count|symbol_rank_files_actual|payload_checksum|mismatch_reason|manifest_path",
    ]
    for proof in proofs:
        lines.append("|".join([
            _safe_text(proof.folder_name),
            _safe_text(proof.layer_id),
            _safe_text(proof.status),
            "true" if proof.accepted else "false",
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
    mismatch_count = sum(1 for p in proofs if p.mismatch)
    degraded = layer_count - accepted
    if layer_count <= 0:
        status = "no_layers_found"
        reason = "Outbox/Layers contains no layer directories"
    elif mismatch_count == 0:
        status = "accepted"
        reason = "all discovered Gateway layer manifests are internally aligned"
    else:
        status = "mismatch_detected"
        reason = f"{mismatch_count} layer manifest(s) are degraded or internally mismatched"
    summary = SurfaceOverseerSummary(
        status=status,
        reason=reason,
        layer_count=layer_count,
        accepted_layer_count=accepted,
        degraded_layer_count=degraded,
        mismatch_count=mismatch_count,
        newest_manifest_unix=newest,
        status_path=str(status_path),
        write_ok=False,
    )
    summary.write_ok = atomic_write_text(status_path, _status_text(summary, proofs))
    return summary
