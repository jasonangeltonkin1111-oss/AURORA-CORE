from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable, List, Tuple

from aurora_worker_l10_schema import (
    L10_RUNTIME2_ROW_FIELD_COUNT,
    L10_RUNTIME2_ROW_FIELDS,
    L10_RUNTIME_PERMISSION_LOOKUP_ONLY,
)
from aurora_worker_l10_normalize import normalize_symbol_text, canonical_symbol_root


@dataclass(frozen=True)
class L10UniverseTaxonomyRow:
    row_index: int
    server: str
    broker_file: str
    broker_symbol: str
    canonical_symbol: str
    asset_class: str
    market_group: str
    market_segment: str
    ranking_group: str
    strict_rank_allowed: str
    public_research_rank_allowed: str
    review_lane: str
    classification_confidence: str
    evidence_rank: str
    runtime_permission: str
    evidence_status: str
    source_status: str
    block_reason: str
    broker_symbol_key: str
    canonical_symbol_key: str
    broker_symbol_root_key: str
    canonical_symbol_root_key: str
    raw_row: str


@dataclass(frozen=True)
class L10InvalidUniverseRow:
    row_index: int
    reason: str
    field_count: int
    raw_row: str


@dataclass(frozen=True)
class L10UniverseParseResult:
    rows: Tuple[L10UniverseTaxonomyRow, ...]
    invalid_rows: Tuple[L10InvalidUniverseRow, ...]
    duplicate_primary_keys: Tuple[str, ...]
    duplicate_broker_symbol_keys: Tuple[str, ...]

    @property
    def row_count(self) -> int:
        return len(self.rows)

    @property
    def invalid_count(self) -> int:
        return len(self.invalid_rows)

    @property
    def duplicate_primary_key_count(self) -> int:
        return len(self.duplicate_primary_keys)

    @property
    def duplicate_broker_symbol_key_count(self) -> int:
        return len(self.duplicate_broker_symbol_keys)


def _clean(value: str | None, default: str = "not_available") -> str:
    text = str(value or "").strip()
    return text if text else default


def _yes(value: str | None) -> bool:
    return str(value or "").strip().upper() == "YES"


def l10_split_universe_row(raw_row: str) -> List[str]:
    return [part.strip() for part in str(raw_row or "").rstrip("\r\n").split("|")]


def l10_parse_universe_row(raw_row: str, row_index: int) -> Tuple[L10UniverseTaxonomyRow | None, L10InvalidUniverseRow | None]:
    parts = l10_split_universe_row(raw_row)
    field_count = len(parts)
    if field_count != L10_RUNTIME2_ROW_FIELD_COUNT:
        return None, L10InvalidUniverseRow(row_index, f"field_count_mismatch expected={L10_RUNTIME2_ROW_FIELD_COUNT} actual={field_count}", field_count, raw_row)

    data = dict(zip(L10_RUNTIME2_ROW_FIELDS, parts))
    required_fields = ("broker_symbol", "asset_class", "market_group", "market_segment", "ranking_group")
    missing = [field for field in required_fields if _clean(data.get(field), "") == ""]
    if missing:
        return None, L10InvalidUniverseRow(row_index, "missing_required_fields=" + ",".join(missing), field_count, raw_row)

    runtime_permission = _clean(data.get("runtime_permission"))
    if runtime_permission != L10_RUNTIME_PERMISSION_LOOKUP_ONLY:
        return None, L10InvalidUniverseRow(row_index, f"invalid_runtime_permission={runtime_permission}", field_count, raw_row)

    broker_symbol = _clean(data.get("broker_symbol"))
    canonical_symbol = _clean(data.get("canonical_symbol"), broker_symbol)

    row = L10UniverseTaxonomyRow(
        row_index=row_index,
        server=_clean(data.get("server")),
        broker_file=_clean(data.get("broker_file")),
        broker_symbol=broker_symbol,
        canonical_symbol=canonical_symbol,
        asset_class=_clean(data.get("asset_class")),
        market_group=_clean(data.get("market_group")),
        market_segment=_clean(data.get("market_segment")),
        ranking_group=_clean(data.get("ranking_group")),
        strict_rank_allowed=_clean(data.get("strict_rank_allowed"), "NO"),
        public_research_rank_allowed=_clean(data.get("public_research_rank_allowed"), "NO"),
        review_lane=_clean(data.get("review_lane")),
        classification_confidence=_clean(data.get("classification_confidence")),
        evidence_rank=_clean(data.get("evidence_rank")),
        runtime_permission=runtime_permission,
        evidence_status=_clean(data.get("evidence_status")),
        source_status=_clean(data.get("source_status")),
        block_reason=_clean(data.get("block_reason")),
        broker_symbol_key=normalize_symbol_text(broker_symbol),
        canonical_symbol_key=normalize_symbol_text(canonical_symbol),
        broker_symbol_root_key=canonical_symbol_root(broker_symbol),
        canonical_symbol_root_key=canonical_symbol_root(canonical_symbol),
        raw_row=raw_row,
    )
    return row, None


def l10_primary_key(row: L10UniverseTaxonomyRow) -> str:
    return "|".join((row.server, row.broker_file, row.broker_symbol_key))


def l10_parse_universe_rows(raw_rows: Iterable[str]) -> L10UniverseParseResult:
    parsed_rows: List[L10UniverseTaxonomyRow] = []
    invalid_rows: List[L10InvalidUniverseRow] = []
    primary_key_counts: dict[str, int] = {}
    broker_key_counts: dict[str, int] = {}

    for row_index, raw_row in enumerate(raw_rows):
        if str(raw_row or "").strip() == "":
            continue
        row, invalid = l10_parse_universe_row(str(raw_row), row_index)
        if invalid is not None:
            invalid_rows.append(invalid)
            continue
        if row is None:
            invalid_rows.append(L10InvalidUniverseRow(row_index, "parser_returned_no_row", 0, str(raw_row)))
            continue
        parsed_rows.append(row)
        primary_key = l10_primary_key(row)
        primary_key_counts[primary_key] = primary_key_counts.get(primary_key, 0) + 1
        broker_key_counts[row.broker_symbol_key] = broker_key_counts.get(row.broker_symbol_key, 0) + 1

    duplicate_primary_keys = tuple(sorted(key for key, count in primary_key_counts.items() if count > 1))
    duplicate_broker_symbol_keys = tuple(sorted(key for key, count in broker_key_counts.items() if count > 1))
    return L10UniverseParseResult(
        rows=tuple(parsed_rows),
        invalid_rows=tuple(invalid_rows),
        duplicate_primary_keys=duplicate_primary_keys,
        duplicate_broker_symbol_keys=duplicate_broker_symbol_keys,
    )


def l10_row_allows_strict_rank(row: L10UniverseTaxonomyRow) -> bool:
    return _yes(row.strict_rank_allowed)


def l10_row_allows_public_research_rank(row: L10UniverseTaxonomyRow) -> bool:
    return _yes(row.public_research_rank_allowed)


def l10_invalid_rows_as_dicts(invalid_rows: Iterable[L10InvalidUniverseRow]) -> List[dict[str, str]]:
    return [
        {
            "row_index": str(row.row_index),
            "reason": row.reason,
            "field_count": str(row.field_count),
            "raw_row": row.raw_row,
        }
        for row in invalid_rows
    ]
