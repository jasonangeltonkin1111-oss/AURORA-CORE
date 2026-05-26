from __future__ import annotations

from pathlib import Path
from typing import Iterable, Tuple

from aurora_worker_io import payload_checksum, read_kv
from aurora_worker_l10_group_builder import l10_build_ranking_groups
from aurora_worker_l10_matcher import l10_build_matcher_index, l10_match_symbols
from aurora_worker_l10_path_planner import l10_build_symbol_path_plans
from aurora_worker_l10_publisher import L10PublishSummary, publish_l10_taxonomy_outputs
from aurora_worker_l10_quality import l10_resolve_matches
from aurora_worker_l10_schema import L10_LAYER_FOLDER, L10_SCHEMA_VERSION
from aurora_worker_l10_universe_parser import l10_duplicate_keys_as_dicts, l10_parse_universe_rows


EMPTY_L10_SUMMARY = L10PublishSummary(
    status="pending",
    reason="l10_not_run",
)


def _source_payload_checksum(symbols: Tuple[str, ...], runtime2_rows: Tuple[str, ...], server: str | None) -> str:
    lines = [
        f"schema_version={L10_SCHEMA_VERSION}",
        f"server={str(server or 'not_available').strip() or 'not_available'}",
        "broker_symbols",
        *symbols,
        "runtime2_rows",
        *runtime2_rows,
    ]
    return payload_checksum(lines)


def _summary_from_existing_outputs(outbox_root: Path, source_checksum: str) -> L10PublishSummary | None:
    layer_dir = outbox_root / "Layers" / L10_LAYER_FOLDER
    summary_path = layer_dir / "taxonomy_summary.txt"
    required_paths = (
        layer_dir / "taxonomy_symbols.csv",
        layer_dir / "taxonomy_symbols.manifest",
        layer_dir / "ranking_groups.csv",
        layer_dir / "ranking_groups.manifest",
        layer_dir / "symbol_path_index.csv",
        layer_dir / "symbol_path_index.txt",
        summary_path,
    )
    if not all(path.exists() for path in required_paths):
        return None
    data = read_kv(summary_path)
    if data.get("schema_version") != L10_SCHEMA_VERSION:
        return None
    if data.get("source_payload_checksum") != source_checksum:
        return None
    if data.get("selection_runtime") != "false" or data.get("trade_permission") != "false":
        return None
    status = data.get("status", "accepted")
    if status not in {"accepted", "write_degraded"}:
        return None

    def as_int(key: str) -> int:
        try:
            return int(float(data.get(key, "0")))
        except ValueError:
            return 0

    return L10PublishSummary(
        status=status,
        reason="skipped_unchanged_source_reused_existing_l10_outputs;" + data.get("reason", "existing_l10_outputs_reused"),
        symbol_count=as_int("symbol_count"),
        ranking_group_count=as_int("ranking_group_count"),
        symbol_path_index_count=as_int("symbol_path_index_count"),
        group_member_csv_count=as_int("group_member_csv_count"),
        invalid_universe_row_count=as_int("invalid_universe_row_count"),
        duplicate_universe_key_count=as_int("duplicate_universe_key_count"),
        accepted_strict_count=as_int("accepted_strict_count"),
        accepted_public_research_count=as_int("accepted_public_research_count"),
        review_required_count=as_int("review_required_count"),
        unknown_count=as_int("unknown_count"),
        omitted_count=as_int("omitted_count"),
        blocked_count=as_int("blocked_count"),
        conflict_count=as_int("conflict_count"),
        missing_dossier_source_count=as_int("missing_dossier_source_count"),
        rank_allowed_count=as_int("rank_allowed_count"),
        downstream_classification_eligible_count=as_int("downstream_classification_eligible_count"),
        active_group_count=as_int("active_group_count"),
        active_with_review_group_count=as_int("active_with_review_group_count"),
        review_only_group_count=as_int("review_only_group_count"),
        write_failed_count=as_int("write_failed_count"),
        source_payload_checksum=source_checksum,
        reused_existing_outputs=True,
        taxonomy_symbols_path=str(layer_dir / "taxonomy_symbols.csv"),
        ranking_groups_path=str(layer_dir / "ranking_groups.csv"),
        symbol_path_index_path=str(layer_dir / "symbol_path_index.csv"),
        summary_path=str(summary_path),
    )


def publish_l10_taxonomy_classification(
    outbox_root: Path,
    broker_symbols: Iterable[str],
    runtime2_universe_rows: Iterable[str],
    server: str | None = None,
) -> L10PublishSummary:
    """Run L10 taxonomy classification as orchestration only.

    L10 is taxonomy/ranking_group map only. It does not rank symbols, build Top 5,
    build Global Top 10, copy Dossiers, grant permission, or execute trades.
    """
    symbols: Tuple[str, ...] = tuple(str(symbol).strip() for symbol in broker_symbols if str(symbol or "").strip())
    runtime2_rows: Tuple[str, ...] = tuple(str(row).strip() for row in runtime2_universe_rows if str(row or "").strip())
    source_checksum = _source_payload_checksum(symbols, runtime2_rows, server)
    reused = _summary_from_existing_outputs(outbox_root, source_checksum)
    if reused is not None:
        return reused

    universe_parse = l10_parse_universe_rows(runtime2_rows)
    duplicate_universe_key_rows = l10_duplicate_keys_as_dicts(universe_parse)
    if not symbols:
        return publish_l10_taxonomy_outputs(
            outbox_root=outbox_root,
            taxonomy_symbols=tuple(),
            ranking_groups=tuple(),
            symbol_path_plans=tuple(),
            invalid_universe_rows=universe_parse.invalid_rows,
            duplicate_universe_key_rows=duplicate_universe_key_rows,
            source_payload_checksum=source_checksum,
        )

    matcher_index = l10_build_matcher_index(universe_parse.rows)
    matches = l10_match_symbols(symbols, matcher_index, server=server)
    resolved = l10_resolve_matches(matches)
    ranking_groups = l10_build_ranking_groups(resolved)
    path_plans = l10_build_symbol_path_plans(resolved)
    return publish_l10_taxonomy_outputs(
        outbox_root=outbox_root,
        taxonomy_symbols=resolved,
        ranking_groups=ranking_groups,
        symbol_path_plans=path_plans,
        invalid_universe_rows=universe_parse.invalid_rows,
        duplicate_universe_key_rows=duplicate_universe_key_rows,
        source_payload_checksum=source_checksum,
    )
