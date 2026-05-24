from __future__ import annotations

from pathlib import Path
from typing import Iterable, Tuple

from aurora_worker_l10_group_builder import l10_build_ranking_groups
from aurora_worker_l10_matcher import l10_build_matcher_index, l10_match_symbols
from aurora_worker_l10_path_planner import l10_build_symbol_path_plans
from aurora_worker_l10_publisher import L10PublishSummary, publish_l10_taxonomy_outputs
from aurora_worker_l10_quality import l10_resolve_matches
from aurora_worker_l10_universe_parser import l10_parse_universe_rows


EMPTY_L10_SUMMARY = L10PublishSummary(
    status="pending",
    reason="l10_not_run",
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
    universe_parse = l10_parse_universe_rows(runtime2_universe_rows)
    if not symbols:
        return publish_l10_taxonomy_outputs(
            outbox_root=outbox_root,
            taxonomy_symbols=tuple(),
            ranking_groups=tuple(),
            symbol_path_plans=tuple(),
            invalid_universe_rows=universe_parse.invalid_rows,
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
    )
