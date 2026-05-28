from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Tuple

from aurora_worker_io import payload_checksum, read_kv, read_text


L10_RUNTIME2_INPUT_NAME = "l10_runtime2_universe_rows.psv"
L10_RUNTIME2_INPUT_MANIFEST_NAME = "l10_runtime2_universe_rows.manifest"


@dataclass(frozen=True)
class L10SourceBundle:
    broker_symbols: Tuple[str, ...]
    runtime2_rows: Tuple[str, ...]
    runtime2_input_path: str
    status: str
    reason: str


EMPTY_L10_SOURCE_BUNDLE = L10SourceBundle(
    broker_symbols=tuple(),
    runtime2_rows=tuple(),
    runtime2_input_path="not_available",
    status="pending",
    reason="l10_source_not_loaded",
)


def l10_broker_symbols_from_snapshot_rows(snapshot_rows: Iterable[str]) -> Tuple[str, ...]:
    """Extract broker symbols from the Runtime 3 snapshot rows.

    Current MT5 snapshot row schema begins with:

    symbol|market_state|l3_ready|l4_ready|quote_quality|...

    This helper deliberately extracts only column 0. It does not classify,
    rank, select, or grant permission.
    """
    symbols: list[str] = []
    seen: set[str] = set()
    for raw in snapshot_rows:
        line = str(raw or "").strip()
        if not line:
            continue
        parts = line.split("|")
        if not parts:
            continue
        symbol = parts[0].strip()
        if not symbol or symbol.lower() == "symbol":
            continue
        if symbol not in seen:
            symbols.append(symbol)
            seen.add(symbol)
    return tuple(symbols)


def l10_runtime2_input_path(outbox_root: Path) -> Path:
    return outbox_root / "Layers" / "Layer_10_Taxonomy_Classification" / L10_RUNTIME2_INPUT_NAME


def l10_runtime2_manifest_path(outbox_root: Path) -> Path:
    return outbox_root / "Layers" / "Layer_10_Taxonomy_Classification" / L10_RUNTIME2_INPUT_MANIFEST_NAME


def _runtime2_payload_rows(input_text: str) -> Tuple[str, ...]:
    rows = tuple(line for line in input_text.replace("\r\n", "\n").splitlines() if line.strip())
    if rows and rows[0].lower().startswith("server|broker_file|broker_symbol|"):
        rows = rows[1:]
    return rows


def _manifest_int(manifest: dict[str, str], key: str) -> int | None:
    value = str(manifest.get(key, "")).strip()
    if not value:
        return None
    try:
        return int(float(value))
    except ValueError:
        return None


def l10_load_runtime2_rows_if_available(outbox_root: Path) -> Tuple[Tuple[str, ...], str, str, str]:
    input_path = l10_runtime2_input_path(outbox_root)
    manifest_path = l10_runtime2_manifest_path(outbox_root)
    if not input_path.exists():
        return tuple(), str(input_path), "pending", "missing_l10_runtime2_universe_rows_input"
    if not manifest_path.exists():
        return tuple(), str(input_path), "pending", "missing_l10_runtime2_universe_rows_manifest"

    text = read_text(input_path)
    rows = _runtime2_payload_rows(text)
    if not rows:
        return tuple(), str(input_path), "pending", "l10_runtime2_universe_rows_input_empty"

    manifest = read_kv(manifest_path)
    expected_rows = _manifest_int(manifest, "row_count")
    if expected_rows is None:
        return tuple(), str(input_path), "pending", "missing_l10_runtime2_manifest_row_count"
    if expected_rows != len(rows):
        return tuple(), str(input_path), "pending", f"l10_runtime2_row_count_mismatch manifest={expected_rows} actual={len(rows)}"

    expected_checksum = str(manifest.get("payload_checksum", "")).strip()
    if not expected_checksum:
        return tuple(), str(input_path), "pending", "missing_l10_runtime2_manifest_payload_checksum"
    actual_checksum = payload_checksum(rows)
    if actual_checksum != expected_checksum:
        return tuple(), str(input_path), "pending", f"l10_runtime2_payload_checksum_mismatch manifest={expected_checksum} actual={actual_checksum}"

    return rows, str(input_path), "available", "l10_runtime2_universe_rows_manifest_verified"


def l10_build_source_bundle(outbox_root: Path, snapshot_rows: Iterable[str]) -> L10SourceBundle:
    broker_symbols = l10_broker_symbols_from_snapshot_rows(snapshot_rows)
    runtime2_rows, input_path, runtime2_status, runtime2_reason = l10_load_runtime2_rows_if_available(outbox_root)
    if not broker_symbols:
        return L10SourceBundle(
            broker_symbols=broker_symbols,
            runtime2_rows=runtime2_rows,
            runtime2_input_path=input_path,
            status="pending",
            reason="no_broker_symbols_in_snapshot_rows",
        )
    if runtime2_status != "available":
        return L10SourceBundle(
            broker_symbols=broker_symbols,
            runtime2_rows=runtime2_rows,
            runtime2_input_path=input_path,
            status="pending",
            reason=runtime2_reason,
        )
    return L10SourceBundle(
        broker_symbols=broker_symbols,
        runtime2_rows=runtime2_rows,
        runtime2_input_path=input_path,
        status="available",
        reason="l10_source_bundle_ready_manifest_verified",
    )