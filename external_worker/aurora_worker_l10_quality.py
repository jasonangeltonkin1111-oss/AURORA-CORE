from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable, Tuple

from aurora_worker_l10_matcher import L10SymbolMatchResult
from aurora_worker_l10_schema import l10_trade_permission_text
from aurora_worker_l10_universe_parser import L10UniverseTaxonomyRow
from aurora_worker_l10_normalize import (
    future_group_folder_path,
    future_top5_copy_path,
    future_top10_copy_path,
)


@dataclass(frozen=True)
class L10ResolvedTaxonomy:
    symbol: str
    canonical_symbol: str
    asset_class: str
    market_group: str
    market_segment: str
    ranking_group: str
    taxonomy_state: str
    review_state: str
    match_type: str
    match_confidence: str
    classification_source: str
    classification_confidence: str
    evidence_rank: str
    source_status: str
    block_reason: str
    rank_allowed: bool
    selection_allowed: bool
    dossier_source_path: str
    future_group_folder: str
    future_top5_copy_path: str
    future_top10_copy_path: str
    reason: str
    trade_permission: str

    def as_taxonomy_symbol_row(self) -> dict[str, str]:
        return {
            "symbol": self.symbol,
            "canonical_symbol": self.canonical_symbol,
            "asset_class": self.asset_class,
            "market_group": self.market_group,
            "market_segment": self.market_segment,
            "ranking_group": self.ranking_group,
            "taxonomy_state": self.taxonomy_state,
            "review_state": self.review_state,
            "match_type": self.match_type,
            "match_confidence": self.match_confidence,
            "classification_source": self.classification_source,
            "classification_confidence": self.classification_confidence,
            "evidence_rank": self.evidence_rank,
            "source_status": self.source_status,
            "block_reason": self.block_reason,
            "rank_allowed": "true" if self.rank_allowed else "false",
            "selection_allowed": "true" if self.selection_allowed else "false",
            "dossier_source_path": self.dossier_source_path,
            "future_group_folder": self.future_group_folder,
            "future_top5_copy_path": self.future_top5_copy_path,
            "future_top10_copy_path": self.future_top10_copy_path,
            "reason": self.reason,
            "trade_permission": self.trade_permission,
        }


@dataclass(frozen=True)
class L10QualitySummary:
    total_symbols: int
    accepted_strict_count: int
    accepted_public_research_count: int
    review_required_count: int
    unknown_count: int
    omitted_count: int
    blocked_count: int
    conflict_count: int
    missing_dossier_source_count: int
    rank_allowed_count: int
    selection_allowed_count: int


def _upper(value: str | None) -> str:
    return str(value or "").strip().upper()


def _text(value: str | None, default: str = "not_available") -> str:
    text = str(value or "").strip()
    return text if text else default


def _row_is_blocked(row: L10UniverseTaxonomyRow) -> bool:
    block_reason = _upper(row.block_reason)
    review_lane = _upper(row.review_lane)
    source_status = _upper(row.source_status)
    return "BLOCK" in block_reason or "BLOCK" in review_lane or source_status == "BLOCKED"


def _row_is_omitted(row: L10UniverseTaxonomyRow) -> bool:
    block_reason = _upper(row.block_reason)
    review_lane = _upper(row.review_lane)
    source_status = _upper(row.source_status)
    return "OMIT" in block_reason or "OMIT" in review_lane or "OMIT" in source_status


def _row_needs_review(row: L10UniverseTaxonomyRow) -> bool:
    review_lane = _upper(row.review_lane)
    evidence_status = _upper(row.evidence_status)
    source_status = _upper(row.source_status)
    return "REVIEW" in review_lane or "REVIEW" in evidence_status or "REVIEW" in source_status


def _row_strict_rank_allowed(row: L10UniverseTaxonomyRow) -> bool:
    return _upper(row.strict_rank_allowed) == "YES"


def _row_public_research_rank_allowed(row: L10UniverseTaxonomyRow) -> bool:
    return _upper(row.public_research_rank_allowed) == "YES"


def _default_dossier_source_path(symbol: str) -> str:
    # L10 plans paths only. The Dossier owner remains the true source and later code must verify the real route.
    return f"Dossiers/<Open_or_Closed_or_Unknown>/{symbol}.txt"


def _planned_group_path(ranking_group: str, rank_allowed: bool) -> str:
    if not rank_allowed or ranking_group == "Unknown":
        return "not_available"
    return future_group_folder_path(ranking_group)


def _planned_top5_path(symbol: str, ranking_group: str, rank_allowed: bool) -> str:
    if not rank_allowed or ranking_group == "Unknown":
        return "not_available"
    return future_top5_copy_path(symbol, ranking_group)


def _planned_top10_path(symbol: str, selection_allowed: bool) -> str:
    if not selection_allowed:
        return "not_available"
    return future_top10_copy_path(symbol)


def _unknown_result(match: L10SymbolMatchResult, state: str, reason: str) -> L10ResolvedTaxonomy:
    symbol = match.symbol
    return L10ResolvedTaxonomy(
        symbol=symbol,
        canonical_symbol=match.symbol_root_key or symbol or "Unknown",
        asset_class="Unknown",
        market_group="Unknown",
        market_segment="Unknown",
        ranking_group="Unknown",
        taxonomy_state=state,
        review_state="manual_review_required",
        match_type=match.match_type,
        match_confidence=match.match_confidence,
        classification_source="not_available",
        classification_confidence="none",
        evidence_rank="not_available",
        source_status="not_available",
        block_reason="not_available",
        rank_allowed=False,
        selection_allowed=False,
        dossier_source_path=_default_dossier_source_path(symbol),
        future_group_folder="not_available",
        future_top5_copy_path="not_available",
        future_top10_copy_path="not_available",
        reason=reason,
        trade_permission=l10_trade_permission_text(),
    )


def l10_resolve_match_quality(match: L10SymbolMatchResult) -> L10ResolvedTaxonomy:
    if match.conflict:
        return _unknown_result(match, "CONFLICT", match.reason)
    if match.unknown or match.matched_row is None:
        return _unknown_result(match, "UNKNOWN", match.reason)

    row = match.matched_row
    if _row_is_blocked(row):
        taxonomy_state = "BLOCKED"
        review_state = "blocked_by_taxonomy_source"
        rank_allowed = False
        selection_allowed = False
        reason = "taxonomy_row_blocked"
    elif _row_is_omitted(row):
        taxonomy_state = "OMITTED"
        review_state = "operator_omitted_or_source_omitted"
        rank_allowed = False
        selection_allowed = False
        reason = "taxonomy_row_omitted"
    elif _row_needs_review(row):
        taxonomy_state = "REVIEW_REQUIRED"
        review_state = row.review_lane
        rank_allowed = False
        selection_allowed = False
        reason = "taxonomy_row_requires_review"
    elif _row_strict_rank_allowed(row):
        taxonomy_state = "ACCEPTED_STRICT"
        review_state = row.review_lane
        rank_allowed = True
        selection_allowed = True
        reason = "strict_rank_allowed_taxonomy_match"
    elif _row_public_research_rank_allowed(row):
        taxonomy_state = "ACCEPTED_PUBLIC_RESEARCH"
        review_state = row.review_lane
        rank_allowed = True
        selection_allowed = True
        reason = "public_research_rank_allowed_taxonomy_match"
    else:
        taxonomy_state = "REVIEW_REQUIRED"
        review_state = row.review_lane
        rank_allowed = False
        selection_allowed = False
        reason = "taxonomy_match_not_rank_allowed"

    symbol = match.symbol
    ranking_group = row.ranking_group
    return L10ResolvedTaxonomy(
        symbol=symbol,
        canonical_symbol=row.canonical_symbol,
        asset_class=row.asset_class,
        market_group=row.market_group,
        market_segment=row.market_segment,
        ranking_group=ranking_group,
        taxonomy_state=taxonomy_state,
        review_state=_text(review_state),
        match_type=match.match_type,
        match_confidence=match.match_confidence,
        classification_source="Runtime 2 generated taxonomy lookup",
        classification_confidence=row.classification_confidence,
        evidence_rank=row.evidence_rank,
        source_status=row.source_status,
        block_reason=row.block_reason,
        rank_allowed=rank_allowed,
        selection_allowed=selection_allowed,
        dossier_source_path=_default_dossier_source_path(symbol),
        future_group_folder=_planned_group_path(ranking_group, rank_allowed),
        future_top5_copy_path=_planned_top5_path(symbol, ranking_group, rank_allowed),
        future_top10_copy_path=_planned_top10_path(symbol, selection_allowed),
        reason=reason + ";" + match.reason,
        trade_permission=l10_trade_permission_text(),
    )


def l10_resolve_matches(matches: Iterable[L10SymbolMatchResult]) -> Tuple[L10ResolvedTaxonomy, ...]:
    return tuple(l10_resolve_match_quality(match) for match in matches)


def l10_quality_summary(rows: Iterable[L10ResolvedTaxonomy]) -> L10QualitySummary:
    materialized = tuple(rows)
    return L10QualitySummary(
        total_symbols=len(materialized),
        accepted_strict_count=sum(1 for row in materialized if row.taxonomy_state == "ACCEPTED_STRICT"),
        accepted_public_research_count=sum(1 for row in materialized if row.taxonomy_state == "ACCEPTED_PUBLIC_RESEARCH"),
        review_required_count=sum(1 for row in materialized if row.taxonomy_state == "REVIEW_REQUIRED"),
        unknown_count=sum(1 for row in materialized if row.taxonomy_state == "UNKNOWN"),
        omitted_count=sum(1 for row in materialized if row.taxonomy_state == "OMITTED"),
        blocked_count=sum(1 for row in materialized if row.taxonomy_state == "BLOCKED"),
        conflict_count=sum(1 for row in materialized if row.taxonomy_state == "CONFLICT"),
        missing_dossier_source_count=sum(1 for row in materialized if row.taxonomy_state == "MISSING_DOSSIER_SOURCE"),
        rank_allowed_count=sum(1 for row in materialized if row.rank_allowed),
        selection_allowed_count=sum(1 for row in materialized if row.selection_allowed),
    )


def l10_rows_for_state(rows: Iterable[L10ResolvedTaxonomy], taxonomy_state: str) -> list[dict[str, str]]:
    wanted = _upper(taxonomy_state)
    return [row.as_taxonomy_symbol_row() for row in rows if _upper(row.taxonomy_state) == wanted]
