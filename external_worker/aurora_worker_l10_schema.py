from __future__ import annotations

from dataclasses import dataclass
from typing import Tuple

L10_LAYER_FOLDER = "Layer_10_Taxonomy_Classification"
L10_LAYER_ID = "10"
L10_LAYER_NAME = "Layer 10 - Taxonomy / Ranking Group Map"
L10_OWNER = "Runtime 5 - Taxonomy / Ranking Group Owner"
L10_JOB_TYPE = "L10_TAXONOMY_CLASSIFICATION_V1"
L10_SCHEMA_VERSION = "l10_taxonomy_classification_v1"
L10_AUTHORITY = "taxonomy_classification_only"

L10_TAXONOMY_SYMBOLS_NAME = "taxonomy_symbols.csv"
L10_TAXONOMY_SYMBOLS_MANIFEST_NAME = "taxonomy_symbols.manifest"
L10_RANKING_GROUPS_NAME = "ranking_groups.csv"
L10_RANKING_GROUPS_MANIFEST_NAME = "ranking_groups.manifest"
L10_SYMBOL_PATH_INDEX_CSV_NAME = "symbol_path_index.csv"
L10_SYMBOL_PATH_INDEX_TXT_NAME = "symbol_path_index.txt"
L10_UNKNOWN_SYMBOLS_NAME = "unknown_symbols.csv"
L10_REVIEW_REQUIRED_SYMBOLS_NAME = "review_required_symbols.csv"
L10_CONFLICT_SYMBOLS_NAME = "conflict_symbols.csv"
L10_OMITTED_SYMBOLS_NAME = "omitted_symbols.csv"
L10_BLOCKED_SYMBOLS_NAME = "blocked_symbols.csv"
L10_INVALID_UNIVERSE_ROWS_NAME = "invalid_universe_rows.csv"
L10_MISSING_DOSSIER_SOURCE_NAME = "missing_dossier_source.csv"
L10_SUMMARY_NAME = "taxonomy_summary.txt"
L10_GROUPS_FOLDER = "Groups"

L10_SELECTION_DESK_ROOT = "Selection Desk"
L10_SELECTION_GROUPS_ROOT = "Groups"
L10_SELECTION_GLOBAL_ROOT = "Global"
L10_SELECTION_INDEX_NAME = "Selection Index.txt"
L10_SYMBOL_PATH_INDEX_FOLDER = "Symbol Path Index"

L10_RUNTIME2_ROW_FIELD_COUNT = 17
L10_RUNTIME_PERMISSION_LOOKUP_ONLY = "LOOKUP_ONLY_NOT_TRADE_PERMISSION"
L10_RUNTIME_PERMISSION_NO_AUTO_RANKING = "NO_AUTO_RANKING"
L10_SAFE_RUNTIME_PERMISSIONS = {
    L10_RUNTIME_PERMISSION_LOOKUP_ONLY,
    L10_RUNTIME_PERMISSION_NO_AUTO_RANKING,
}

L10_TAXONOMY_STATES = {
    "ACCEPTED_STRICT",
    "ACCEPTED_PUBLIC_RESEARCH",
    "REVIEW_REQUIRED",
    "UNKNOWN",
    "OMITTED",
    "BLOCKED",
    "CONFLICT",
    "MISSING_DOSSIER_SOURCE",
}

L10_GROUP_STATES = {
    "ACTIVE",
    "ACTIVE_WITH_REVIEW",
    "REVIEW_ONLY",
    "EMPTY",
    "BLOCKED",
}

L10_MATCH_TYPES = {
    "exact_server_broker_symbol",
    "exact_broker_symbol_any_server",
    "exact_canonical_symbol",
    "normalized_broker_root",
    "normalized_canonical_root",
    "alias_table",
    "l3_broker_identity_evidence",
    "symbol_grammar_fallback",
    "unknown",
    "conflict",
}

L10_TAXONOMY_SYMBOL_FIELDS = [
    "symbol",
    "canonical_symbol",
    "asset_class",
    "market_group",
    "market_segment",
    "ranking_group",
    "taxonomy_state",
    "review_state",
    "match_type",
    "match_confidence",
    "classification_source",
    "classification_confidence",
    "evidence_rank",
    "source_status",
    "block_reason",
    "rank_allowed",
    "selection_allowed",
    "downstream_classification_eligible",
    "l5_gate_state",
    "l5_eligible_flag",
    "l6_available",
    "l7_available",
    "l8_available",
    "l9_available",
    "dossier_source_path",
    "future_group_folder",
    "future_top5_copy_path",
    "future_top10_copy_path",
    "reason",
    "trade_permission",
]

L10_RANKING_GROUP_FIELDS = [
    "ranking_group",
    "ranking_group_slug",
    "asset_class",
    "market_group",
    "market_segment",
    "symbol_count",
    "open_count",
    "l5_pass_count",
    "l5_degraded_count",
    "l5_blocked_count",
    "strict_rank_allowed_count",
    "public_research_allowed_count",
    "review_required_count",
    "unknown_count",
    "conflict_count",
    "missing_dossier_count",
    "group_state",
    "future_selection_desk_group_path",
    "trade_permission",
]

L10_SYMBOL_PATH_INDEX_FIELDS = [
    "symbol",
    "canonical_symbol",
    "asset_class",
    "market_group",
    "market_segment",
    "ranking_group",
    "taxonomy_state",
    "rank_allowed",
    "selection_allowed",
    "downstream_classification_eligible",
    "dossier_source_path",
    "future_group_folder",
    "future_top5_copy_path",
    "future_top10_copy_path",
    "reason",
]

L10_RUNTIME2_ROW_FIELDS = [
    "server",
    "broker_file",
    "broker_symbol",
    "canonical_symbol",
    "asset_class",
    "market_group",
    "market_segment",
    "ranking_group",
    "strict_rank_allowed",
    "public_research_rank_allowed",
    "review_lane",
    "classification_confidence",
    "evidence_rank",
    "runtime_permission",
    "evidence_status",
    "source_status",
    "block_reason",
]


@dataclass(frozen=True)
class L10OutputContract:
    layer_folder: str = L10_LAYER_FOLDER
    schema_version: str = L10_SCHEMA_VERSION
    owner: str = L10_OWNER
    job_type: str = L10_JOB_TYPE
    taxonomy_symbols_name: str = L10_TAXONOMY_SYMBOLS_NAME
    ranking_groups_name: str = L10_RANKING_GROUPS_NAME
    symbol_path_index_name: str = L10_SYMBOL_PATH_INDEX_CSV_NAME


def l10_required_output_names() -> Tuple[str, ...]:
    return (
        L10_TAXONOMY_SYMBOLS_NAME,
        L10_TAXONOMY_SYMBOLS_MANIFEST_NAME,
        L10_RANKING_GROUPS_NAME,
        L10_RANKING_GROUPS_MANIFEST_NAME,
        L10_SYMBOL_PATH_INDEX_CSV_NAME,
        L10_SYMBOL_PATH_INDEX_TXT_NAME,
        L10_UNKNOWN_SYMBOLS_NAME,
        L10_REVIEW_REQUIRED_SYMBOLS_NAME,
        L10_CONFLICT_SYMBOLS_NAME,
        L10_OMITTED_SYMBOLS_NAME,
        L10_BLOCKED_SYMBOLS_NAME,
        L10_INVALID_UNIVERSE_ROWS_NAME,
        L10_MISSING_DOSSIER_SOURCE_NAME,
        L10_SUMMARY_NAME,
    )


def l10_trade_permission_text() -> str:
    return "false"


def l10_selection_runtime_text() -> str:
    return "false"
