from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Sequence
import csv
import io

from aurora_worker_io import atomic_write_text, payload_checksum, unix_time, utc_stamp
from aurora_worker_l10_group_builder import L10RankingGroupSummary, l10_group_build_summary, l10_ranking_group_rows
from aurora_worker_l10_normalize import safe_file_slug
from aurora_worker_l10_path_planner import L10SymbolPathPlan, l10_symbol_path_index_rows, l10_symbol_path_index_text
from aurora_worker_l10_quality import L10QualitySummary, L10ResolvedTaxonomy, l10_quality_summary, l10_rows_for_state
from aurora_worker_l10_schema import (
    L10_AUTHORITY,
    L10_BLOCKED_SYMBOLS_NAME,
    L10_CONFLICT_SYMBOLS_NAME,
    L10_DUPLICATE_UNIVERSE_KEY_FIELDS,
    L10_DUPLICATE_UNIVERSE_KEYS_NAME,
    L10_GROUPS_FOLDER,
    L10_INVALID_UNIVERSE_ROWS_NAME,
    L10_LAYER_FOLDER,
    L10_LAYER_ID,
    L10_LAYER_NAME,
    L10_MISSING_DOSSIER_SOURCE_NAME,
    L10_OMITTED_SYMBOLS_NAME,
    L10_OWNER,
    L10_RANKING_GROUP_FIELDS,
    L10_RANKING_GROUPS_MANIFEST_NAME,
    L10_RANKING_GROUPS_NAME,
    L10_REVIEW_REQUIRED_SYMBOLS_NAME,
    L10_SCHEMA_VERSION,
    L10_SUMMARY_NAME,
    L10_SYMBOL_PATH_INDEX_CSV_NAME,
    L10_SYMBOL_PATH_INDEX_FIELDS,
    L10_SYMBOL_PATH_INDEX_TXT_NAME,
    L10_TAXONOMY_SYMBOL_FIELDS,
    L10_TAXONOMY_SYMBOLS_MANIFEST_NAME,
    L10_TAXONOMY_SYMBOLS_NAME,
    L10_UNKNOWN_SYMBOLS_NAME,
    l10_selection_runtime_text,
    l10_trade_permission_text,
)
from aurora_worker_l10_universe_parser import L10InvalidUniverseRow, l10_invalid_rows_as_dicts

L10_SYMBOL_TAXONOMY_FOLDER = "SymbolTaxonomy"
L10_GROUP_MEMBER_FIELDS = [
    "symbol",
    "canonical_symbol",
    "asset_class",
    "market_group",
    "market_segment",
    "ranking_group",
    "taxonomy_state",
    "rank_allowed",
    "downstream_classification_eligible",
    "future_group_folder",
    "reason",
    "trade_permission",
]


@dataclass(frozen=True)
class L10PublishSummary:
    status: str
    reason: str
    symbol_count: int = 0
    ranking_group_count: int = 0
    symbol_path_index_count: int = 0
    group_member_csv_count: int = 0
    invalid_universe_row_count: int = 0
    duplicate_universe_key_count: int = 0
    accepted_strict_count: int = 0
    accepted_public_research_count: int = 0
    review_required_count: int = 0
    unknown_count: int = 0
    omitted_count: int = 0
    blocked_count: int = 0
    conflict_count: int = 0
    missing_dossier_source_count: int = 0
    rank_allowed_count: int = 0
    downstream_classification_eligible_count: int = 0
    active_group_count: int = 0
    active_with_review_group_count: int = 0
    review_only_group_count: int = 0
    write_failed_count: int = 0
    source_payload_checksum: str = "not_available"
    reused_existing_outputs: bool = False
    taxonomy_symbols_path: str = "not_available"
    ranking_groups_path: str = "not_available"
    symbol_path_index_path: str = "not_available"
    summary_path: str = "not_available"

    @property
    def selection_allowed_count(self) -> int:
        return self.downstream_classification_eligible_count


def _csv_text(rows: Sequence[dict[str, str]], fields: Sequence[str]) -> str:
    buffer = io.StringIO(newline="")
    writer = csv.DictWriter(buffer, fieldnames=list(fields), extrasaction="ignore", lineterminator="\n")
    writer.writeheader()
    for row in rows:
        writer.writerow({field: str(row.get(field, "not_available")) for field in fields})
    return buffer.getvalue()


def _manifest_text(name: str, row_count: int, payload_text: str, reason: str) -> str:
    payload_rows = payload_text.splitlines()
    return "\n".join(
        [
            f"schema_name={name}_manifest",
            f"schema_version={L10_SCHEMA_VERSION}",
            f"layer_id={L10_LAYER_ID}",
            f"layer_name={L10_LAYER_NAME}",
            f"owner={L10_OWNER}",
            f"authority={L10_AUTHORITY}",
            f"row_count={row_count}",
            f"payload_checksum={payload_checksum(payload_rows)}",
            f"payload_size_bytes={len(payload_text.encode('utf-8'))}",
            f"reason={reason}",
            f"selection_runtime={l10_selection_runtime_text()}",
            f"trade_permission={l10_trade_permission_text()}",
            f"generated_utc={utc_stamp()}",
            f"generated_unix={unix_time()}",
            "",
        ]
    )


def _taxonomy_rows(symbols: Iterable[L10ResolvedTaxonomy]) -> list[dict[str, str]]:
    rows: list[dict[str, str]] = []
    for row in symbols:
        output = row.as_taxonomy_symbol_row()
        output.setdefault("l5_gate_state", "not_available")
        output.setdefault("l5_eligible_flag", "not_available")
        output.setdefault("l6_available", "not_available")
        output.setdefault("l7_available", "not_available")
        output.setdefault("l8_available", "not_available")
        output.setdefault("l9_available", "not_available")
        rows.append(output)
    return rows


def _group_member_row(row: L10ResolvedTaxonomy) -> dict[str, str]:
    return {
        "symbol": row.symbol,
        "canonical_symbol": row.canonical_symbol,
        "asset_class": row.asset_class,
        "market_group": row.market_group,
        "market_segment": row.market_segment,
        "ranking_group": row.ranking_group,
        "taxonomy_state": row.taxonomy_state,
        "rank_allowed": "true" if row.rank_allowed else "false",
        "downstream_classification_eligible": "true" if row.downstream_classification_eligible else "false",
        "future_group_folder": row.future_group_folder,
        "reason": row.reason,
        "trade_permission": row.trade_permission,
    }


def _write(path: Path, text: str, failed_paths: list[Path]) -> None:
    if not atomic_write_text(path, text):
        failed_paths.append(path)


def _summary_text(
    quality: L10QualitySummary,
    group_summary,
    symbol_path_count: int,
    invalid_count: int,
    duplicate_key_count: int,
    write_failed_count: int,
    symbol_sidecar_count: int,
    group_member_csv_count: int,
    status: str,
    reason: str,
    source_payload_checksum: str,
) -> str:
    return "\n".join(
        [
            "schema_name=l10_taxonomy_classification_summary",
            f"schema_version={L10_SCHEMA_VERSION}",
            f"layer_id={L10_LAYER_ID}",
            f"layer_name={L10_LAYER_NAME}",
            f"owner={L10_OWNER}",
            f"authority={L10_AUTHORITY}",
            f"status={status}",
            f"reason={reason}",
            f"source_payload_checksum={source_payload_checksum}",
            "reused_existing_outputs=false",
            f"symbol_count={quality.total_symbols}",
            f"accepted_strict_count={quality.accepted_strict_count}",
            f"accepted_public_research_count={quality.accepted_public_research_count}",
            f"review_required_count={quality.review_required_count}",
            f"unknown_count={quality.unknown_count}",
            f"omitted_count={quality.omitted_count}",
            f"blocked_count={quality.blocked_count}",
            f"conflict_count={quality.conflict_count}",
            f"missing_dossier_source_count={quality.missing_dossier_source_count}",
            f"rank_allowed_count={quality.rank_allowed_count}",
            f"downstream_classification_eligible_count={quality.downstream_classification_eligible_count}",
            f"ranking_group_count={group_summary.total_groups}",
            f"active_group_count={group_summary.active_groups}",
            f"active_with_review_group_count={group_summary.active_with_review_groups}",
            f"review_only_group_count={group_summary.review_only_groups}",
            f"blocked_group_count={group_summary.blocked_groups}",
            f"symbol_path_index_count={symbol_path_count}",
            f"symbol_sidecar_count={symbol_sidecar_count}",
            f"group_member_csv_count={group_member_csv_count}",
            f"invalid_universe_row_count={invalid_count}",
            f"duplicate_universe_key_count={duplicate_key_count}",
            f"write_failed_count={write_failed_count}",
            "selection_runtime=false",
            "trade_permission=false",
            "meaning=taxonomy_only_group_member_csvs_no_rank_no_top5_no_top10_no_dossier_copy_no_trade_permission",
            f"generated_utc={utc_stamp()}",
            f"generated_unix={unix_time()}",
            "",
        ]
    )


def _group_summary_text(group: L10RankingGroupSummary) -> str:
    return "\n".join(
        [
            "schema_name=l10_ranking_group_summary",
            f"schema_version={L10_SCHEMA_VERSION}",
            f"ranking_group={group.ranking_group}",
            f"ranking_group_slug={group.ranking_group_slug}",
            f"asset_class={group.asset_class}",
            f"market_group={group.market_group}",
            f"market_segment={group.market_segment}",
            f"symbol_count={group.symbol_count}",
            f"strict_rank_allowed_count={group.strict_rank_allowed_count}",
            f"public_research_allowed_count={group.public_research_allowed_count}",
            f"review_required_count={group.review_required_count}",
            f"unknown_count={group.unknown_count}",
            f"conflict_count={group.conflict_count}",
            f"group_state={group.group_state}",
            f"future_selection_desk_group_path={group.future_selection_desk_group_path}",
            f"all_members_csv={group.ranking_group_slug}.members.csv",
            "selection_runtime=false",
            "trade_permission=false",
            f"generated_utc={utc_stamp()}",
            f"generated_unix={unix_time()}",
            "",
        ]
    )


def _symbol_taxonomy_text(row: L10ResolvedTaxonomy) -> str:
    return "\n".join(
        [
            "schema_name=l10_symbol_taxonomy_sidecar",
            f"schema_version={L10_SCHEMA_VERSION}",
            f"layer_id={L10_LAYER_ID}",
            f"layer_name={L10_LAYER_NAME}",
            f"owner={L10_OWNER}",
            f"symbol={row.symbol}",
            f"canonical_symbol={row.canonical_symbol}",
            f"asset_class={row.asset_class}",
            f"market_group={row.market_group}",
            f"market_segment={row.market_segment}",
            f"ranking_group={row.ranking_group}",
            f"taxonomy_state={row.taxonomy_state}",
            f"review_state={row.review_state}",
            f"match_type={row.match_type}",
            f"match_confidence={row.match_confidence}",
            f"classification_source={row.classification_source}",
            f"classification_confidence={row.classification_confidence}",
            f"evidence_rank={row.evidence_rank}",
            f"source_status={row.source_status}",
            f"block_reason={row.block_reason}",
            f"rank_allowed={'true' if row.rank_allowed else 'false'}",
            f"downstream_classification_eligible={'true' if row.downstream_classification_eligible else 'false'}",
            f"future_group_folder={row.future_group_folder}",
            f"reason={row.reason}",
            "selection_runtime=false",
            "trade_permission=false",
            "meaning=taxonomy_only_no_rank_no_selection_no_trade_permission",
            f"generated_utc={utc_stamp()}",
            f"generated_unix={unix_time()}",
            "",
        ]
    )


def publish_l10_taxonomy_outputs(
    outbox_root: Path,
    taxonomy_symbols: Iterable[L10ResolvedTaxonomy],
    ranking_groups: Iterable[L10RankingGroupSummary],
    symbol_path_plans: Iterable[L10SymbolPathPlan],
    invalid_universe_rows: Iterable[L10InvalidUniverseRow] = tuple(),
    duplicate_universe_key_rows: Iterable[dict[str, str]] = tuple(),
    source_payload_checksum: str = "not_available",
) -> L10PublishSummary:
    layer_dir = outbox_root / "Layers" / L10_LAYER_FOLDER
    groups_dir = layer_dir / L10_GROUPS_FOLDER
    symbol_taxonomy_dir = layer_dir / L10_SYMBOL_TAXONOMY_FOLDER
    layer_dir.mkdir(parents=True, exist_ok=True)
    groups_dir.mkdir(parents=True, exist_ok=True)
    symbol_taxonomy_dir.mkdir(parents=True, exist_ok=True)

    symbols = tuple(taxonomy_symbols)
    groups = tuple(ranking_groups)
    plans = tuple(symbol_path_plans)
    invalid_rows = tuple(invalid_universe_rows)
    duplicate_key_rows = tuple(duplicate_universe_key_rows)
    quality = l10_quality_summary(symbols)
    group_summary = l10_group_build_summary(groups)

    symbols_by_group: dict[str, list[L10ResolvedTaxonomy]] = {}
    for row in symbols:
        symbols_by_group.setdefault(row.ranking_group, []).append(row)

    taxonomy_csv = _csv_text(_taxonomy_rows(symbols), L10_TAXONOMY_SYMBOL_FIELDS)
    ranking_groups_csv = _csv_text(l10_ranking_group_rows(groups), L10_RANKING_GROUP_FIELDS)
    symbol_path_csv = _csv_text(l10_symbol_path_index_rows(plans), L10_SYMBOL_PATH_INDEX_FIELDS)
    symbol_path_txt = l10_symbol_path_index_text(plans)
    unknown_csv = _csv_text(l10_rows_for_state(symbols, "UNKNOWN"), L10_TAXONOMY_SYMBOL_FIELDS)
    review_csv = _csv_text(l10_rows_for_state(symbols, "REVIEW_REQUIRED"), L10_TAXONOMY_SYMBOL_FIELDS)
    conflict_csv = _csv_text(l10_rows_for_state(symbols, "CONFLICT"), L10_TAXONOMY_SYMBOL_FIELDS)
    omitted_csv = _csv_text(l10_rows_for_state(symbols, "OMITTED"), L10_TAXONOMY_SYMBOL_FIELDS)
    blocked_csv = _csv_text(l10_rows_for_state(symbols, "BLOCKED"), L10_TAXONOMY_SYMBOL_FIELDS)
    missing_dossier_csv = _csv_text(l10_rows_for_state(symbols, "MISSING_DOSSIER_SOURCE"), L10_TAXONOMY_SYMBOL_FIELDS)
    invalid_csv = _csv_text(l10_invalid_rows_as_dicts(invalid_rows), ("row_index", "reason", "field_count", "raw_row"))
    duplicate_keys_csv = _csv_text(duplicate_key_rows, L10_DUPLICATE_UNIVERSE_KEY_FIELDS)

    failed_paths: list[Path] = []
    _write(layer_dir / L10_TAXONOMY_SYMBOLS_NAME, taxonomy_csv, failed_paths)
    _write(layer_dir / L10_TAXONOMY_SYMBOLS_MANIFEST_NAME, _manifest_text("l10_taxonomy_symbols", len(symbols), taxonomy_csv, "taxonomy_symbols_published"), failed_paths)
    _write(layer_dir / L10_RANKING_GROUPS_NAME, ranking_groups_csv, failed_paths)
    _write(layer_dir / L10_RANKING_GROUPS_MANIFEST_NAME, _manifest_text("l10_ranking_groups", len(groups), ranking_groups_csv, "ranking_groups_published"), failed_paths)
    _write(layer_dir / L10_SYMBOL_PATH_INDEX_CSV_NAME, symbol_path_csv, failed_paths)
    _write(layer_dir / L10_SYMBOL_PATH_INDEX_TXT_NAME, symbol_path_txt, failed_paths)
    _write(layer_dir / L10_UNKNOWN_SYMBOLS_NAME, unknown_csv, failed_paths)
    _write(layer_dir / L10_REVIEW_REQUIRED_SYMBOLS_NAME, review_csv, failed_paths)
    _write(layer_dir / L10_CONFLICT_SYMBOLS_NAME, conflict_csv, failed_paths)
    _write(layer_dir / L10_OMITTED_SYMBOLS_NAME, omitted_csv, failed_paths)
    _write(layer_dir / L10_BLOCKED_SYMBOLS_NAME, blocked_csv, failed_paths)
    _write(layer_dir / L10_MISSING_DOSSIER_SOURCE_NAME, missing_dossier_csv, failed_paths)
    _write(layer_dir / L10_INVALID_UNIVERSE_ROWS_NAME, invalid_csv, failed_paths)
    _write(layer_dir / L10_DUPLICATE_UNIVERSE_KEYS_NAME, duplicate_keys_csv, failed_paths)

    group_member_csv_count = 0
    for group in groups:
        _write(groups_dir / f"{group.ranking_group_slug}.summary.txt", _group_summary_text(group), failed_paths)
        members = sorted(symbols_by_group.get(group.ranking_group, []), key=lambda row: row.symbol)
        member_rows = [_group_member_row(row) for row in members]
        _write(groups_dir / f"{group.ranking_group_slug}.members.csv", _csv_text(member_rows, L10_GROUP_MEMBER_FIELDS), failed_paths)
        group_member_csv_count += 1

    symbol_sidecar_count = 0
    for row in symbols:
        _write(symbol_taxonomy_dir / f"{safe_file_slug(row.symbol)}.txt", _symbol_taxonomy_text(row), failed_paths)
        symbol_sidecar_count += 1

    status = "accepted" if not failed_paths else "write_degraded"
    reason = "l10_taxonomy_outputs_published" if not failed_paths else "one_or_more_l10_outputs_failed_atomic_write"
    summary_text = _summary_text(
        quality,
        group_summary,
        len(plans),
        len(invalid_rows),
        len(duplicate_key_rows),
        len(failed_paths),
        symbol_sidecar_count,
        group_member_csv_count,
        status,
        reason,
        source_payload_checksum,
    )
    _write(layer_dir / L10_SUMMARY_NAME, summary_text, failed_paths)

    if failed_paths and status == "accepted":
        status = "write_degraded"
        reason = "one_or_more_l10_outputs_failed_atomic_write"
    return L10PublishSummary(
        status=status,
        reason=reason,
        symbol_count=quality.total_symbols,
        ranking_group_count=len(groups),
        symbol_path_index_count=len(plans),
        group_member_csv_count=group_member_csv_count,
        invalid_universe_row_count=len(invalid_rows),
        duplicate_universe_key_count=len(duplicate_key_rows),
        accepted_strict_count=quality.accepted_strict_count,
        accepted_public_research_count=quality.accepted_public_research_count,
        review_required_count=quality.review_required_count,
        unknown_count=quality.unknown_count,
        omitted_count=quality.omitted_count,
        blocked_count=quality.blocked_count,
        conflict_count=quality.conflict_count,
        missing_dossier_source_count=quality.missing_dossier_source_count,
        rank_allowed_count=quality.rank_allowed_count,
        downstream_classification_eligible_count=quality.downstream_classification_eligible_count,
        active_group_count=group_summary.active_groups,
        active_with_review_group_count=group_summary.active_with_review_groups,
        review_only_group_count=group_summary.review_only_groups,
        write_failed_count=len(failed_paths),
        source_payload_checksum=source_payload_checksum,
        reused_existing_outputs=False,
        taxonomy_symbols_path=str(layer_dir / L10_TAXONOMY_SYMBOLS_NAME),
        ranking_groups_path=str(layer_dir / L10_RANKING_GROUPS_NAME),
        symbol_path_index_path=str(layer_dir / L10_SYMBOL_PATH_INDEX_CSV_NAME),
        summary_path=str(layer_dir / L10_SUMMARY_NAME),
    )
