from __future__ import annotations

from dataclasses import dataclass
from typing import Dict, Iterable, Tuple

from aurora_worker_l10_normalize import safe_folder_slug
from aurora_worker_l10_quality import L10ResolvedTaxonomy
from aurora_worker_l10_schema import l10_trade_permission_text


@dataclass(frozen=True)
class L10RankingGroupSummary:
    ranking_group: str
    ranking_group_slug: str
    asset_class: str
    market_group: str
    market_segment: str
    symbol_count: int
    open_count: int
    l5_pass_count: int
    l5_degraded_count: int
    l5_blocked_count: int
    strict_rank_allowed_count: int
    public_research_allowed_count: int
    review_required_count: int
    unknown_count: int
    conflict_count: int
    missing_dossier_count: int
    group_state: str
    future_selection_desk_group_path: str
    trade_permission: str

    def as_ranking_group_row(self) -> dict[str, str]:
        return {
            "ranking_group": self.ranking_group,
            "ranking_group_slug": self.ranking_group_slug,
            "asset_class": self.asset_class,
            "market_group": self.market_group,
            "market_segment": self.market_segment,
            "symbol_count": str(self.symbol_count),
            "open_count": str(self.open_count),
            "l5_pass_count": str(self.l5_pass_count),
            "l5_degraded_count": str(self.l5_degraded_count),
            "l5_blocked_count": str(self.l5_blocked_count),
            "strict_rank_allowed_count": str(self.strict_rank_allowed_count),
            "public_research_allowed_count": str(self.public_research_allowed_count),
            "review_required_count": str(self.review_required_count),
            "unknown_count": str(self.unknown_count),
            "conflict_count": str(self.conflict_count),
            "missing_dossier_count": str(self.missing_dossier_count),
            "group_state": self.group_state,
            "future_selection_desk_group_path": self.future_selection_desk_group_path,
            "trade_permission": self.trade_permission,
        }


@dataclass(frozen=True)
class L10GroupBuildSummary:
    total_groups: int
    active_groups: int
    active_with_review_groups: int
    review_only_groups: int
    empty_groups: int
    blocked_groups: int
    total_grouped_symbols: int


def _text(value: str | None, default: str = "not_available") -> str:
    text = str(value or "").strip()
    return text if text else default


def _gate_state(row: L10ResolvedTaxonomy) -> str:
    # The L10 quality resolver does not own L5 yet. Future publisher can enrich this from live L5 input.
    return "not_available"


def _group_key(row: L10ResolvedTaxonomy) -> str:
    group = _text(row.ranking_group, "Unknown")
    if row.taxonomy_state in {"UNKNOWN", "CONFLICT"}:
        return "Unknown"
    return group


def _future_group_path(ranking_group: str) -> str:
    # Stable parent route. Top-N labels belong in files/manifests, not parent folders.
    return f"Selection Desk/Groups/{safe_folder_slug(ranking_group)}/"


def _resolve_group_state(symbol_count: int, rank_allowed_count: int, review_count: int, unknown_count: int, conflict_count: int, blocked_count: int) -> str:
    if symbol_count <= 0:
        return "EMPTY"
    if blocked_count >= symbol_count:
        return "BLOCKED"
    if rank_allowed_count > 0 and (review_count > 0 or unknown_count > 0 or conflict_count > 0):
        return "ACTIVE_WITH_REVIEW"
    if rank_allowed_count > 0:
        return "ACTIVE"
    if review_count > 0 or unknown_count > 0 or conflict_count > 0:
        return "REVIEW_ONLY"
    return "REVIEW_ONLY"


def l10_build_ranking_groups(rows: Iterable[L10ResolvedTaxonomy]) -> Tuple[L10RankingGroupSummary, ...]:
    materialized = tuple(rows)
    grouped: Dict[str, list[L10ResolvedTaxonomy]] = {}
    for row in materialized:
        grouped.setdefault(_group_key(row), []).append(row)

    summaries: list[L10RankingGroupSummary] = []
    for ranking_group in sorted(grouped.keys()):
        members = tuple(grouped[ranking_group])
        first_known = next((row for row in members if row.ranking_group != "Unknown"), members[0])
        symbol_count = len(members)
        strict_count = sum(1 for row in members if row.taxonomy_state == "ACCEPTED_STRICT")
        public_count = sum(1 for row in members if row.taxonomy_state == "ACCEPTED_PUBLIC_RESEARCH")
        review_count = sum(1 for row in members if row.taxonomy_state == "REVIEW_REQUIRED")
        unknown_count = sum(1 for row in members if row.taxonomy_state == "UNKNOWN")
        conflict_count = sum(1 for row in members if row.taxonomy_state == "CONFLICT")
        blocked_count = sum(1 for row in members if row.taxonomy_state == "BLOCKED")
        missing_dossier_count = sum(1 for row in members if row.taxonomy_state == "MISSING_DOSSIER_SOURCE")
        rank_allowed_count = sum(1 for row in members if row.rank_allowed)
        group_state = _resolve_group_state(symbol_count, rank_allowed_count, review_count, unknown_count, conflict_count, blocked_count)
        summaries.append(
            L10RankingGroupSummary(
                ranking_group=ranking_group,
                ranking_group_slug=safe_folder_slug(ranking_group),
                asset_class=_text(first_known.asset_class, "Unknown"),
                market_group=_text(first_known.market_group, "Unknown"),
                market_segment=_text(first_known.market_segment, "Unknown"),
                symbol_count=symbol_count,
                open_count=0,
                l5_pass_count=0,
                l5_degraded_count=0,
                l5_blocked_count=0,
                strict_rank_allowed_count=strict_count,
                public_research_allowed_count=public_count,
                review_required_count=review_count,
                unknown_count=unknown_count,
                conflict_count=conflict_count,
                missing_dossier_count=missing_dossier_count,
                group_state=group_state,
                future_selection_desk_group_path=_future_group_path(ranking_group),
                trade_permission=l10_trade_permission_text(),
            )
        )
    return tuple(summaries)


def l10_group_build_summary(groups: Iterable[L10RankingGroupSummary]) -> L10GroupBuildSummary:
    materialized = tuple(groups)
    return L10GroupBuildSummary(
        total_groups=len(materialized),
        active_groups=sum(1 for group in materialized if group.group_state == "ACTIVE"),
        active_with_review_groups=sum(1 for group in materialized if group.group_state == "ACTIVE_WITH_REVIEW"),
        review_only_groups=sum(1 for group in materialized if group.group_state == "REVIEW_ONLY"),
        empty_groups=sum(1 for group in materialized if group.group_state == "EMPTY"),
        blocked_groups=sum(1 for group in materialized if group.group_state == "BLOCKED"),
        total_grouped_symbols=sum(group.symbol_count for group in materialized),
    )


def l10_ranking_group_rows(groups: Iterable[L10RankingGroupSummary]) -> list[dict[str, str]]:
    return [group.as_ranking_group_row() for group in groups]
