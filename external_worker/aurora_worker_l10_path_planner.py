from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable, Tuple

from aurora_worker_l10_normalize import future_group_folder_path
from aurora_worker_l10_quality import L10ResolvedTaxonomy


@dataclass(frozen=True)
class L10SymbolPathPlan:
    symbol: str
    canonical_symbol: str
    asset_class: str
    market_group: str
    market_segment: str
    ranking_group: str
    taxonomy_state: str
    rank_allowed: bool
    downstream_classification_eligible: bool
    dossier_source_path: str
    future_group_folder: str
    reason: str

    @property
    def selection_allowed(self) -> bool:
        return self.downstream_classification_eligible

    def as_symbol_path_index_row(self) -> dict[str, str]:
        return {
            "symbol": self.symbol,
            "canonical_symbol": self.canonical_symbol,
            "asset_class": self.asset_class,
            "market_group": self.market_group,
            "market_segment": self.market_segment,
            "ranking_group": self.ranking_group,
            "taxonomy_state": self.taxonomy_state,
            "rank_allowed": "true" if self.rank_allowed else "false",
            "downstream_classification_eligible": "true" if self.downstream_classification_eligible else "false",
            "dossier_source_path": self.dossier_source_path,
            "future_group_folder": self.future_group_folder,
            "reason": self.reason,
        }


def _text(value: str | None, default: str = "not_available") -> str:
    text = str(value or "").strip()
    return text if text else default


def _future_group_path_for(row: L10ResolvedTaxonomy) -> str:
    if row.ranking_group == "Unknown" or not row.rank_allowed:
        return "not_available"
    return future_group_folder_path(row.ranking_group)


def l10_build_symbol_path_plan(row: L10ResolvedTaxonomy) -> L10SymbolPathPlan:
    return L10SymbolPathPlan(
        symbol=row.symbol,
        canonical_symbol=row.canonical_symbol,
        asset_class=row.asset_class,
        market_group=row.market_group,
        market_segment=row.market_segment,
        ranking_group=row.ranking_group,
        taxonomy_state=row.taxonomy_state,
        rank_allowed=row.rank_allowed,
        downstream_classification_eligible=row.downstream_classification_eligible,
        dossier_source_path=_text(row.dossier_source_path),
        future_group_folder=_future_group_path_for(row),
        reason=row.reason,
    )


def l10_build_symbol_path_plans(rows: Iterable[L10ResolvedTaxonomy]) -> Tuple[L10SymbolPathPlan, ...]:
    return tuple(l10_build_symbol_path_plan(row) for row in rows)


def l10_symbol_path_index_rows(plans: Iterable[L10SymbolPathPlan]) -> list[dict[str, str]]:
    return [plan.as_symbol_path_index_row() for plan in plans]


def l10_symbol_path_index_text(plans: Iterable[L10SymbolPathPlan], max_rows: int = 5000) -> str:
    materialized = tuple(plans)
    lines = [
        "SYMBOL PATH INDEX",
        "----------------------------------------",
        "Meaning: L10 taxonomy roadmap only; group folder hints are pending downstream processing and are not proof that copied Dossiers exist.",
        "Runtime Permission: FALSE",
        "",
    ]
    for plan in materialized[:max_rows]:
        lines.extend(
            [
                plan.symbol,
                f"Taxonomy:          {plan.asset_class} > {plan.market_group} > {plan.market_segment} > {plan.ranking_group}",
                f"State:             {plan.taxonomy_state}",
                f"Rank Allowed:      {'TRUE' if plan.rank_allowed else 'FALSE'}",
                f"Downstream Classification Eligible: {'TRUE' if plan.downstream_classification_eligible else 'FALSE'}",
                f"Dossier Source:    {plan.dossier_source_path}",
                f"Future Group Path: {plan.future_group_folder}",
                f"Reason:            {plan.reason}",
                "Runtime Permission: FALSE",
                "",
            ]
        )
    if len(materialized) > max_rows:
        lines.append(f"TRUNCATED: displayed {max_rows} of {len(materialized)} symbols")
        lines.append("")
    return "\n".join(lines)
