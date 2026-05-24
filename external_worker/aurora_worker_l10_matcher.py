from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable, Tuple

from aurora_worker_l10_normalize import normalize_symbol_text, canonical_symbol_root, normalize_match_candidates
from aurora_worker_l10_universe_parser import L10UniverseTaxonomyRow


@dataclass(frozen=True)
class L10SymbolMatchResult:
    symbol: str
    symbol_key: str
    symbol_root_key: str
    match_state: str
    match_type: str
    match_confidence: str
    matched_row: L10UniverseTaxonomyRow | None
    candidate_count: int
    conflict_count: int
    conflict_rows: Tuple[L10UniverseTaxonomyRow, ...]
    reason: str

    @property
    def matched(self) -> bool:
        return self.matched_row is not None and self.match_state == "matched"

    @property
    def conflict(self) -> bool:
        return self.match_state == "conflict"

    @property
    def unknown(self) -> bool:
        return self.match_state == "unknown"


@dataclass(frozen=True)
class L10MatcherIndex:
    by_server_broker_symbol: dict[str, Tuple[L10UniverseTaxonomyRow, ...]]
    by_broker_symbol: dict[str, Tuple[L10UniverseTaxonomyRow, ...]]
    by_canonical_symbol: dict[str, Tuple[L10UniverseTaxonomyRow, ...]]
    by_broker_root: dict[str, Tuple[L10UniverseTaxonomyRow, ...]]
    by_canonical_root: dict[str, Tuple[L10UniverseTaxonomyRow, ...]]


def _append_index(index: dict[str, list[L10UniverseTaxonomyRow]], key: str, row: L10UniverseTaxonomyRow) -> None:
    clean_key = str(key or "").strip().upper()
    if not clean_key:
        return
    index.setdefault(clean_key, []).append(row)


def _freeze_index(index: dict[str, list[L10UniverseTaxonomyRow]]) -> dict[str, Tuple[L10UniverseTaxonomyRow, ...]]:
    return {key: tuple(rows) for key, rows in index.items()}


def l10_build_matcher_index(rows: Iterable[L10UniverseTaxonomyRow]) -> L10MatcherIndex:
    by_server_broker_symbol: dict[str, list[L10UniverseTaxonomyRow]] = {}
    by_broker_symbol: dict[str, list[L10UniverseTaxonomyRow]] = {}
    by_canonical_symbol: dict[str, list[L10UniverseTaxonomyRow]] = {}
    by_broker_root: dict[str, list[L10UniverseTaxonomyRow]] = {}
    by_canonical_root: dict[str, list[L10UniverseTaxonomyRow]] = {}

    for row in rows:
        server_key = normalize_symbol_text(row.server)
        _append_index(by_server_broker_symbol, f"{server_key}|{row.broker_symbol_key}", row)
        _append_index(by_broker_symbol, row.broker_symbol_key, row)
        _append_index(by_canonical_symbol, row.canonical_symbol_key, row)
        _append_index(by_broker_root, row.broker_symbol_root_key, row)
        _append_index(by_canonical_root, row.canonical_symbol_root_key, row)

    return L10MatcherIndex(
        by_server_broker_symbol=_freeze_index(by_server_broker_symbol),
        by_broker_symbol=_freeze_index(by_broker_symbol),
        by_canonical_symbol=_freeze_index(by_canonical_symbol),
        by_broker_root=_freeze_index(by_broker_root),
        by_canonical_root=_freeze_index(by_canonical_root),
    )


def _taxonomy_signature(row: L10UniverseTaxonomyRow) -> tuple[str, str, str, str]:
    return (
        row.asset_class.strip().upper(),
        row.market_group.strip().upper(),
        row.market_segment.strip().upper(),
        row.ranking_group.strip().upper(),
    )


def _same_taxonomy(rows: Tuple[L10UniverseTaxonomyRow, ...]) -> bool:
    if len(rows) <= 1:
        return True
    first = _taxonomy_signature(rows[0])
    return all(_taxonomy_signature(row) == first for row in rows[1:])


def _strongest_row(rows: Tuple[L10UniverseTaxonomyRow, ...]) -> L10UniverseTaxonomyRow:
    def score(row: L10UniverseTaxonomyRow) -> tuple[int, int, int]:
        strict = 1 if row.strict_rank_allowed.strip().upper() == "YES" else 0
        public = 1 if row.public_research_rank_allowed.strip().upper() == "YES" else 0
        confidence = row.classification_confidence.strip().upper()
        confidence_score = {"HIGH": 3, "MEDIUM": 2, "LOW": 1}.get(confidence, 0)
        return strict, public, confidence_score

    return sorted(rows, key=score, reverse=True)[0]


def _resolve_rows(symbol: str, symbol_key: str, symbol_root: str, match_type: str, rows: Tuple[L10UniverseTaxonomyRow, ...]) -> L10SymbolMatchResult:
    if not rows:
        return L10SymbolMatchResult(symbol, symbol_key, symbol_root, "unknown", "unknown", "none", None, 0, 0, tuple(), "no_rows_for_match_type")
    if not _same_taxonomy(rows):
        return L10SymbolMatchResult(
            symbol=symbol,
            symbol_key=symbol_key,
            symbol_root_key=symbol_root,
            match_state="conflict",
            match_type=match_type,
            match_confidence="none",
            matched_row=None,
            candidate_count=len(rows),
            conflict_count=len(rows),
            conflict_rows=rows,
            reason="multiple_rows_with_incompatible_taxonomy",
        )
    chosen = _strongest_row(rows)
    confidence = "high" if match_type in {"exact_server_broker_symbol", "exact_broker_symbol_any_server", "exact_canonical_symbol"} else "medium"
    reason = "matched_unique_row" if len(rows) == 1 else "matched_multiple_rows_same_taxonomy_chose_strongest_evidence"
    return L10SymbolMatchResult(
        symbol=symbol,
        symbol_key=symbol_key,
        symbol_root_key=symbol_root,
        match_state="matched",
        match_type=match_type,
        match_confidence=confidence,
        matched_row=chosen,
        candidate_count=len(rows),
        conflict_count=0,
        conflict_rows=tuple(),
        reason=reason,
    )


def l10_match_symbol(symbol: str, index: L10MatcherIndex, server: str | None = None) -> L10SymbolMatchResult:
    display_symbol = str(symbol or "").strip()
    symbol_key = normalize_symbol_text(display_symbol)
    symbol_root = canonical_symbol_root(display_symbol)
    if not symbol_key:
        return L10SymbolMatchResult(display_symbol, symbol_key, symbol_root, "unknown", "unknown", "none", None, 0, 0, tuple(), "empty_symbol")

    server_key = normalize_symbol_text(server)
    if server_key:
        rows = index.by_server_broker_symbol.get(f"{server_key}|{symbol_key}", tuple())
        if rows:
            return _resolve_rows(display_symbol, symbol_key, symbol_root, "exact_server_broker_symbol", rows)

    match_attempts: tuple[tuple[str, Tuple[L10UniverseTaxonomyRow, ...]], ...] = (
        ("exact_broker_symbol_any_server", index.by_broker_symbol.get(symbol_key, tuple())),
        ("exact_canonical_symbol", index.by_canonical_symbol.get(symbol_key, tuple())),
        ("normalized_broker_root", index.by_broker_root.get(symbol_root, tuple())),
        ("normalized_canonical_root", index.by_canonical_root.get(symbol_root, tuple())),
    )
    for match_type, rows in match_attempts:
        if rows:
            return _resolve_rows(display_symbol, symbol_key, symbol_root, match_type, rows)

    candidates = normalize_match_candidates(display_symbol)
    return L10SymbolMatchResult(
        symbol=display_symbol,
        symbol_key=symbol_key,
        symbol_root_key=symbol_root,
        match_state="unknown",
        match_type="unknown",
        match_confidence="none",
        matched_row=None,
        candidate_count=len(candidates),
        conflict_count=0,
        conflict_rows=tuple(),
        reason="no_runtime2_taxonomy_match_for_symbol_or_root",
    )


def l10_match_symbols(symbols: Iterable[str], index: L10MatcherIndex, server: str | None = None) -> Tuple[L10SymbolMatchResult, ...]:
    return tuple(l10_match_symbol(symbol, index, server) for symbol in symbols)


def l10_conflict_results_as_dicts(results: Iterable[L10SymbolMatchResult]) -> list[dict[str, str]]:
    rows: list[dict[str, str]] = []
    for result in results:
        if not result.conflict:
            continue
        for conflict_row in result.conflict_rows:
            rows.append(
                {
                    "symbol": result.symbol,
                    "match_type": result.match_type,
                    "candidate_count": str(result.candidate_count),
                    "conflict_row_index": str(conflict_row.row_index),
                    "asset_class": conflict_row.asset_class,
                    "market_group": conflict_row.market_group,
                    "market_segment": conflict_row.market_segment,
                    "ranking_group": conflict_row.ranking_group,
                    "reason": result.reason,
                }
            )
    return rows


def l10_unknown_results_as_dicts(results: Iterable[L10SymbolMatchResult]) -> list[dict[str, str]]:
    return [
        {
            "symbol": result.symbol,
            "symbol_key": result.symbol_key,
            "symbol_root_key": result.symbol_root_key,
            "reason": result.reason,
        }
        for result in results
        if result.unknown
    ]
