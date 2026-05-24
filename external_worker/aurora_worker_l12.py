from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Iterable, List, Sequence, Tuple
from collections import defaultdict
import csv
import io
import math
import statistics

from aurora_worker_io import atomic_write_text, payload_checksum, read_text, unix_time, utc_stamp


L12_LAYER_FOLDER = "Layer_12_Ranking_Group_Heat_Quality"
L12_LAYER_ID = "12"
L12_LAYER_NAME = "Layer 12 - Ranking Group Heat / Quality"
L12_OWNER = "Runtime 5 - Taxonomy / Ranking Group Owner"
L12_SCHEMA_VERSION = "1"
L12_SCHEMA_NAME = "l12_ranking_group_heat_quality"
L12_AUTHORITY = "ranking_group_attention_quality_only"
L12_MIN_RANKABLE_FOR_FULL_CONFIDENCE = 3
L12_TOP_N = 5

L12_HEAT_QUALITY_FIELDS = [
    "ranking_group",
    "ranking_group_slug",
    "asset_class",
    "market_group",
    "market_segment",
    "group_state",
    "ranking_group_heat_rank",
    "ranking_group_quality_rank",
    "ranking_group_strength_rank",
    "ranking_group_heat",
    "ranking_group_quality_score",
    "ranking_group_strength",
    "group_symbol_count",
    "rankable_count",
    "not_rankable_count",
    "risk_review_count",
    "top5_symbol_count",
    "backup_depth",
    "top_symbol",
    "top_symbol_score",
    "top5_avg_score",
    "top5_median_score",
    "top5_min_score",
    "top5_max_score",
    "top_symbol_separation",
    "l6_avg_score",
    "l7_avg_score",
    "l8_avg_score",
    "l9_avg_score",
    "session_relevance_avg",
    "component_completeness_avg",
    "percent_group_above_70",
    "percent_group_above_60",
    "thin_group_flag",
    "thin_group_reason",
    "rank_stability",
    "rank_change",
    "churn_penalty",
    "prior_cycle_available",
    "meaning",
    "directional_validity",
    "expectancy_validated",
    "selection_runtime",
    "trade_permission",
    "entry_signal",
    "execution",
    "reason",
    "source_l11_checksum",
    "generated_utc",
]

L12_DISTRIBUTION_FIELDS = [
    "ranking_group",
    "rankable_count",
    "l6_available_count",
    "l7_available_count",
    "l8_available_count",
    "l9_available_count",
    "l6_avg",
    "l7_avg",
    "l8_avg",
    "l9_avg",
    "l6_missing_count",
    "l7_missing_count",
    "l8_missing_count",
    "l9_missing_count",
    "risk_review_count",
    "not_rankable_quality_count",
    "not_rankable_taxonomy_count",
]

L12_THIN_WARNING_FIELDS = [
    "ranking_group",
    "group_symbol_count",
    "rankable_count",
    "top5_symbol_count",
    "thin_group_flag",
    "thin_group_reason",
    "selection_runtime",
    "trade_permission",
]


@dataclass(frozen=True)
class L12PublishSummary:
    status: str
    reason: str
    ranking_group_count: int = 0
    accepted_group_count: int = 0
    accepted_with_review_group_count: int = 0
    thin_group_count: int = 0
    no_top5_group_count: int = 0
    risk_review_group_count: int = 0
    write_failed_count: int = 0
    heat_quality_path: str = "not_available"
    heat_quality_summary_path: str = "not_available"
    selection_desk_heat_index_path: str = "not_available"
    top_heat_group: str = "not_available"
    top_quality_group: str = "not_available"
    top_strength_group: str = "not_available"


EMPTY_L12_SUMMARY = L12PublishSummary("pending", "l12_not_run")


def _safe_text(row: Dict[str, str], key: str, default: str = "not_available") -> str:
    value = row.get(key, default)
    text = "" if value is None else str(value).strip()
    return text if text else default


def _safe_float(value: str | None) -> Tuple[bool, float]:
    text = str(value or "").strip()
    if text == "" or text.lower() in {"nan", "inf", "-inf", "not_available", "pending", "partial"}:
        return False, 0.0
    try:
        number = float(text)
    except ValueError:
        return False, 0.0
    if math.isnan(number) or math.isinf(number):
        return False, 0.0
    return True, max(0.0, min(100.0, number))


def _parse_kv(text: str) -> Dict[str, str]:
    data: Dict[str, str] = {}
    for raw in text.replace("\r\n", "\n").splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        data[key.strip()] = value.strip()
    return data


def _read_csv(path: Path) -> List[Dict[str, str]]:
    reader = csv.DictReader(io.StringIO(read_text(path).replace("\r\n", "\n")))
    return [{str(k): ("" if v is None else str(v)) for k, v in row.items()} for row in reader]


def _csv_text(rows: Sequence[Dict[str, str]], fields: Sequence[str]) -> str:
    buffer = io.StringIO(newline="")
    writer = csv.DictWriter(buffer, fieldnames=list(fields), extrasaction="ignore", lineterminator="\n")
    writer.writeheader()
    for row in rows:
        writer.writerow({field: str(row.get(field, "not_available")) for field in fields})
    return buffer.getvalue()


def _manifest_text(name: str, row_count: int, payload_text: str, reason: str) -> str:
    return "\n".join([
        f"schema_name={name}_manifest",
        f"schema_version={L12_SCHEMA_VERSION}",
        f"layer_id={L12_LAYER_ID}",
        f"layer_name={L12_LAYER_NAME}",
        f"owner={L12_OWNER}",
        f"authority={L12_AUTHORITY}",
        f"row_count={row_count}",
        f"payload_checksum={payload_checksum(payload_text.splitlines())}",
        f"payload_size_bytes={len(payload_text.encode('utf-8'))}",
        f"reason={reason}",
        "directional_validity=false",
        "expectancy_validated=false",
        "selection_runtime=false",
        "trade_permission=false",
        "entry_signal=false",
        "execution=false",
        f"generated_utc={utc_stamp()}",
        f"generated_unix={unix_time()}",
        "",
    ])


def _sanitize(value: str) -> str:
    safe = str(value).strip() or "unknown"
    for ch in ['\\', '/', ':', '*', '?', '"', '<', '>', '|']:
        safe = safe.replace(ch, "_")
    safe = "_".join(part for part in safe.replace(" ", "_").split("_") if part)
    return safe or "unknown"


def _write(path: Path, text: str, failed: List[Path]) -> None:
    if not atomic_write_text(path, text):
        failed.append(path)


def _average(values: Iterable[float]) -> float:
    materialized = list(values)
    return sum(materialized) / len(materialized) if materialized else 0.0


def _median(values: Iterable[float]) -> float:
    materialized = list(values)
    return statistics.median(materialized) if materialized else 0.0


def _score(row: Dict[str, str], key: str) -> Tuple[bool, float]:
    return _safe_float(row.get(key))


def _rankable(row: Dict[str, str]) -> bool:
    return _safe_text(row, "rank_state", "").lower() in {"ranked", "ranked_partial", "risk_review"}


def _risk_review(row: Dict[str, str]) -> bool:
    return _safe_text(row, "risk_review_flag", "false").lower() == "true" or _safe_text(row, "rank_state", "").lower() == "risk_review"


def _component_values(rows: List[Dict[str, str]], key: str) -> List[float]:
    values: List[float] = []
    for row in rows:
        ok, value = _score(row, key)
        if ok:
            values.append(value)
    return values


def _component_available_count(rows: List[Dict[str, str]], key: str) -> int:
    return len(_component_values(rows, key))


def _component_missing_count(rows: List[Dict[str, str]], key: str) -> int:
    return max(0, len(rows) - _component_available_count(rows, key))


def _top_symbol_separation(scores: List[float]) -> float:
    if len(scores) < 2:
        return 0.0
    ordered = sorted(scores, reverse=True)
    return max(0.0, min(100.0, ordered[0] - ordered[1]))


def _bounded(value: float) -> float:
    return max(0.0, min(100.0, value))


def _group_state(rankable_count: int, top5_count: int, risk_review_count: int) -> Tuple[str, bool, str]:
    if rankable_count <= 0:
        return "NO_RANKABLE_SYMBOLS", True, "no_rankable_symbols"
    if top5_count <= 0:
        return "NO_TOP5", True, "top5_missing"
    if rankable_count < L12_MIN_RANKABLE_FOR_FULL_CONFIDENCE:
        return "THIN_GROUP", True, f"rankable_count_below_{L12_MIN_RANKABLE_FOR_FULL_CONFIDENCE}"
    if risk_review_count > 0:
        return "ACCEPTED_WITH_REVIEW", False, "risk_review_members_present"
    return "ACCEPTED", False, "clean_group_heat_quality_available"


def _build_group_rows(ranked_rows: List[Dict[str, str]], top5_rows: List[Dict[str, str]], source_checksum: str) -> Tuple[List[Dict[str, str]], List[Dict[str, str]], List[Dict[str, str]]]:
    by_group: Dict[str, List[Dict[str, str]]] = defaultdict(list)
    top5_by_group: Dict[str, List[Dict[str, str]]] = defaultdict(list)
    for row in ranked_rows:
        by_group[_safe_text(row, "ranking_group", "Unknown")].append(row)
    for row in top5_rows:
        top5_by_group[_safe_text(row, "ranking_group", "Unknown")].append(row)

    heat_rows: List[Dict[str, str]] = []
    distribution_rows: List[Dict[str, str]] = []
    thin_rows: List[Dict[str, str]] = []

    for group, members in sorted(by_group.items()):
        rankable_rows = [row for row in members if _rankable(row)]
        top5 = [row for row in top5_by_group.get(group, []) if _rankable(row)]
        if not top5:
            top5 = sorted(rankable_rows, key=lambda row: float(row.get("l11_group_score", "0") or 0), reverse=True)[:L12_TOP_N]

        scores = [value for ok, value in (_score(row, "l11_group_score") for row in rankable_rows) if ok]
        top5_scores = [value for ok, value in (_score(row, "l11_group_score") for row in top5) if ok]
        group_symbol_count = len(members)
        rankable_count = len(rankable_rows)
        not_rankable_count = group_symbol_count - rankable_count
        risk_review_count = sum(1 for row in members if _risk_review(row))
        top5_count = len(top5)
        backup_depth = max(0, top5_count - 1)

        state, thin, thin_reason = _group_state(rankable_count, top5_count, risk_review_count)

        l6_values = _component_values(rankable_rows, "l6_score")
        l7_values = _component_values(rankable_rows, "l7_score")
        l8_values = _component_values(rankable_rows, "l8_score")
        l9_values = _component_values(rankable_rows, "l9_score")
        component_available_total = (
            _component_available_count(rankable_rows, "l6_score")
            + _component_available_count(rankable_rows, "l7_score")
            + _component_available_count(rankable_rows, "l8_score")
            + _component_available_count(rankable_rows, "l9_score")
        )
        component_possible_total = max(1, rankable_count * 4)
        component_completeness = 100.0 * component_available_total / component_possible_total

        rankable_ratio = 100.0 * rankable_count / max(1, group_symbol_count)
        clean_ratio = 100.0 * max(0, rankable_count - risk_review_count) / max(1, rankable_count)
        top5_available_factor = 100.0 if top5_count > 0 else 0.0
        backup_depth_factor = 100.0 * min(4, backup_depth) / 4.0
        clean_count_factor = 100.0 * min(10, max(0, rankable_count - risk_review_count)) / 10.0
        risk_review_penalty = min(25.0, risk_review_count * 5.0)
        not_rankable_penalty = min(25.0, not_rankable_count * 3.0)
        thin_group_penalty = 20.0 if thin else 0.0
        degraded_penalty = min(25.0, risk_review_penalty + thin_group_penalty + (not_rankable_count * 2.0))

        top_symbol = top5[0].get("symbol", "not_available") if top5 else "not_available"
        top_symbol_score = max(top5_scores) if top5_scores else (max(scores) if scores else 0.0)
        top5_avg = _average(top5_scores)
        top5_median = _median(top5_scores)
        top5_min = min(top5_scores) if top5_scores else 0.0
        top5_max = max(top5_scores) if top5_scores else 0.0
        separation = _top_symbol_separation(top5_scores if top5_scores else scores)
        percent_above_70 = 100.0 * sum(1 for value in scores if value >= 70.0) / max(1, len(scores))
        percent_above_60 = 100.0 * sum(1 for value in scores if value >= 60.0) / max(1, len(scores))
        session_relevance_avg = _average(l7_values)

        quality = _bounded(
            (rankable_ratio * 0.25)
            + (clean_ratio * 0.25)
            + (component_completeness * 0.20)
            + (top5_available_factor * 0.10)
            + (backup_depth_factor * 0.10)
            - risk_review_penalty
            - not_rankable_penalty
            - thin_group_penalty
        )
        strength = _bounded(
            (top_symbol_score * 0.35)
            + (top5_avg * 0.35)
            + (top5_median * 0.15)
            + (backup_depth_factor * 0.10)
            + (clean_count_factor * 0.05)
            - degraded_penalty
        )
        rank_stability = 0.0
        churn_penalty = 0.0
        heat = _bounded(
            (top5_avg * 0.30)
            + (percent_above_70 * 0.20)
            + (separation * 0.15)
            + (session_relevance_avg * 0.20)
            + (rank_stability * 0.10)
            - churn_penalty
        )

        first = members[0] if members else {}
        heat_rows.append({
            "ranking_group": group,
            "ranking_group_slug": _safe_text(first, "ranking_group_slug", _sanitize(group)),
            "asset_class": _safe_text(first, "asset_class", "Unknown"),
            "market_group": _safe_text(first, "market_group", "Unknown"),
            "market_segment": _safe_text(first, "market_segment", "Unknown"),
            "group_state": state,
            "ranking_group_heat_rank": "pending_rank_assignment",
            "ranking_group_quality_rank": "pending_rank_assignment",
            "ranking_group_strength_rank": "pending_rank_assignment",
            "ranking_group_heat": f"{heat:.2f}",
            "ranking_group_quality_score": f"{quality:.2f}",
            "ranking_group_strength": f"{strength:.2f}",
            "group_symbol_count": str(group_symbol_count),
            "rankable_count": str(rankable_count),
            "not_rankable_count": str(not_rankable_count),
            "risk_review_count": str(risk_review_count),
            "top5_symbol_count": str(top5_count),
            "backup_depth": str(backup_depth),
            "top_symbol": top_symbol,
            "top_symbol_score": f"{top_symbol_score:.2f}",
            "top5_avg_score": f"{top5_avg:.2f}",
            "top5_median_score": f"{top5_median:.2f}",
            "top5_min_score": f"{top5_min:.2f}",
            "top5_max_score": f"{top5_max:.2f}",
            "top_symbol_separation": f"{separation:.2f}",
            "l6_avg_score": f"{_average(l6_values):.2f}",
            "l7_avg_score": f"{_average(l7_values):.2f}",
            "l8_avg_score": f"{_average(l8_values):.2f}",
            "l9_avg_score": f"{_average(l9_values):.2f}",
            "session_relevance_avg": f"{session_relevance_avg:.2f}",
            "component_completeness_avg": f"{component_completeness:.2f}",
            "percent_group_above_70": f"{percent_above_70:.2f}",
            "percent_group_above_60": f"{percent_above_60:.2f}",
            "thin_group_flag": "true" if thin else "false",
            "thin_group_reason": thin_reason if thin else "not_thin",
            "rank_stability": "not_available_first_cycle",
            "rank_change": "not_available_first_cycle",
            "churn_penalty": "0_first_cycle_no_prior_snapshot",
            "prior_cycle_available": "false",
            "meaning": "ranking_group_attention_quality_only",
            "directional_validity": "false",
            "expectancy_validated": "false",
            "selection_runtime": "false",
            "trade_permission": "false",
            "entry_signal": "false",
            "execution": "false",
            "reason": thin_reason if thin else "l12_group_heat_quality_scored",
            "source_l11_checksum": source_checksum,
            "generated_utc": utc_stamp(),
        })

        distribution_rows.append({
            "ranking_group": group,
            "rankable_count": str(rankable_count),
            "l6_available_count": str(_component_available_count(rankable_rows, "l6_score")),
            "l7_available_count": str(_component_available_count(rankable_rows, "l7_score")),
            "l8_available_count": str(_component_available_count(rankable_rows, "l8_score")),
            "l9_available_count": str(_component_available_count(rankable_rows, "l9_score")),
            "l6_avg": f"{_average(l6_values):.2f}",
            "l7_avg": f"{_average(l7_values):.2f}",
            "l8_avg": f"{_average(l8_values):.2f}",
            "l9_avg": f"{_average(l9_values):.2f}",
            "l6_missing_count": str(_component_missing_count(rankable_rows, "l6_score")),
            "l7_missing_count": str(_component_missing_count(rankable_rows, "l7_score")),
            "l8_missing_count": str(_component_missing_count(rankable_rows, "l8_score")),
            "l9_missing_count": str(_component_missing_count(rankable_rows, "l9_score")),
            "risk_review_count": str(risk_review_count),
            "not_rankable_quality_count": str(sum(1 for row in members if _safe_text(row, "rank_state", "") == "not_rankable_quality")),
            "not_rankable_taxonomy_count": str(sum(1 for row in members if _safe_text(row, "rank_state", "") == "not_rankable_taxonomy")),
        })

        if thin:
            thin_rows.append({
                "ranking_group": group,
                "group_symbol_count": str(group_symbol_count),
                "rankable_count": str(rankable_count),
                "top5_symbol_count": str(top5_count),
                "thin_group_flag": "true",
                "thin_group_reason": thin_reason,
                "selection_runtime": "false",
                "trade_permission": "false",
            })

    _assign_ranks(heat_rows, "ranking_group_heat", "ranking_group_heat_rank")
    _assign_ranks(heat_rows, "ranking_group_quality_score", "ranking_group_quality_rank")
    _assign_ranks(heat_rows, "ranking_group_strength", "ranking_group_strength_rank")

    return heat_rows, distribution_rows, thin_rows


def _assign_ranks(rows: List[Dict[str, str]], score_key: str, rank_key: str) -> None:
    ordered = sorted(rows, key=lambda row: (-float(row.get(score_key, "0") or 0), row.get("ranking_group", "")))
    for index, row in enumerate(ordered, start=1):
        row[rank_key] = str(index)


def _selection_groups_dir(outbox_root: Path) -> Path:
    # outbox = <account>/Workbench/Gateway/Outbox
    return outbox_root.parents[2] / "Selection Desk" / "Groups"


def _group_text(row: Dict[str, str]) -> str:
    keys = [
        "ranking_group", "asset_class", "market_group", "market_segment", "group_state",
        "ranking_group_heat_rank", "ranking_group_quality_rank", "ranking_group_strength_rank",
        "ranking_group_heat", "ranking_group_quality_score", "ranking_group_strength",
        "top_symbol", "top_symbol_score", "top5_avg_score", "backup_depth",
        "thin_group_flag", "thin_group_reason", "risk_review_count", "meaning",
        "selection_runtime", "trade_permission", "entry_signal", "execution", "reason",
    ]
    return "\n".join([
        "L12 - RANKING GROUP HEAT / QUALITY",
        "----------------------------------------",
        f"schema_name={L12_SCHEMA_NAME}",
        f"schema_version={L12_SCHEMA_VERSION}",
        f"owner={L12_OWNER}",
        f"layer_id={L12_LAYER_ID}",
    ] + [f"{key}={row.get(key, 'not_available')}" for key in keys] + [
        f"generated_utc={utc_stamp()}",
        f"generated_unix={unix_time()}",
        "",
    ])


def _summary_text(summary: L12PublishSummary) -> str:
    return "\n".join([
        f"schema_name={L12_SCHEMA_NAME}",
        f"schema_version={L12_SCHEMA_VERSION}",
        f"owner_name={L12_OWNER}",
        f"layer_id={L12_LAYER_ID}",
        f"layer_name={L12_LAYER_NAME}",
        f"status={summary.status}",
        f"reason={summary.reason}",
        "input_source=L11",
        "input_files=ranked_symbols_by_group.csv,ranking_group_top5.csv,l11_summary.txt",
        f"ranking_group_count={summary.ranking_group_count}",
        f"accepted_group_count={summary.accepted_group_count}",
        f"accepted_with_review_group_count={summary.accepted_with_review_group_count}",
        f"thin_group_count={summary.thin_group_count}",
        f"no_top5_group_count={summary.no_top5_group_count}",
        f"risk_review_group_count={summary.risk_review_group_count}",
        f"top_heat_group={summary.top_heat_group}",
        f"top_quality_group={summary.top_quality_group}",
        f"top_strength_group={summary.top_strength_group}",
        f"write_failed_count={summary.write_failed_count}",
        f"heat_quality_path={summary.heat_quality_path}",
        f"selection_desk_heat_index_path={summary.selection_desk_heat_index_path}",
        "rank_stability=not_available_first_cycle",
        "rank_change=not_available_first_cycle",
        "prior_cycle_available=false",
        "meaning=ranking_group_attention_quality_only",
        "directional_validity=false",
        "expectancy_validated=false",
        "selection_runtime=false",
        "trade_permission=false",
        "entry_signal=false",
        "execution=false",
        f"generated_utc={utc_stamp()}",
        f"generated_unix={unix_time()}",
        "",
    ])


def _index_text(rows: List[Dict[str, str]], summary: L12PublishSummary) -> str:
    ordered = sorted(rows, key=lambda row: int(row.get("ranking_group_heat_rank", "999999") or 999999))
    lines = [
        "L12 GROUP HEAT / QUALITY INDEX",
        "----------------------------------------",
        f"Status: {summary.status}",
        f"Ranking Groups Scored: {summary.ranking_group_count}",
        f"Accepted Groups: {summary.accepted_group_count}",
        f"Thin Groups: {summary.thin_group_count}",
        f"Risk Review Groups: {summary.risk_review_group_count}",
        "Meaning: group_attention_quality_only",
        "Selection Runtime: FALSE",
        "Trade Permission: FALSE",
        "Entry Signal: FALSE",
        "Execution: FALSE",
        "",
        "HeatRank | QualityRank | StrengthRank | Group | Heat | Quality | Strength | State | Warning",
    ]
    for row in ordered:
        lines.append(
            f"{row.get('ranking_group_heat_rank')} | {row.get('ranking_group_quality_rank')} | {row.get('ranking_group_strength_rank')} | "
            f"{row.get('ranking_group')} | {row.get('ranking_group_heat')} | {row.get('ranking_group_quality_score')} | "
            f"{row.get('ranking_group_strength')} | {row.get('group_state')} | {row.get('thin_group_reason')}"
        )
    lines.append("")
    return "\n".join(lines)


def _publish(outbox_root: Path, rows: List[Dict[str, str]], distribution_rows: List[Dict[str, str]], thin_rows: List[Dict[str, str]]) -> L12PublishSummary:
    layer_dir = outbox_root / "Layers" / L12_LAYER_FOLDER
    group_dir = layer_dir / "RankingGroups"
    visible_dir = _selection_groups_dir(outbox_root)
    for folder in (layer_dir, group_dir, visible_dir):
        folder.mkdir(parents=True, exist_ok=True)

    failed: List[Path] = []
    heat_csv = _csv_text(rows, L12_HEAT_QUALITY_FIELDS)
    distribution_csv = _csv_text(distribution_rows, L12_DISTRIBUTION_FIELDS)
    thin_csv = _csv_text(thin_rows, L12_THIN_WARNING_FIELDS)

    top_heat = min(rows, key=lambda row: int(row.get("ranking_group_heat_rank", "999999") or 999999))["ranking_group"] if rows else "not_available"
    top_quality = min(rows, key=lambda row: int(row.get("ranking_group_quality_rank", "999999") or 999999))["ranking_group"] if rows else "not_available"
    top_strength = min(rows, key=lambda row: int(row.get("ranking_group_strength_rank", "999999") or 999999))["ranking_group"] if rows else "not_available"

    provisional = L12PublishSummary(
        status="accepted",
        reason="l12_group_heat_quality_published",
        ranking_group_count=len(rows),
        accepted_group_count=sum(1 for row in rows if row.get("group_state") == "ACCEPTED"),
        accepted_with_review_group_count=sum(1 for row in rows if row.get("group_state") == "ACCEPTED_WITH_REVIEW"),
        thin_group_count=sum(1 for row in rows if row.get("thin_group_flag") == "true"),
        no_top5_group_count=sum(1 for row in rows if row.get("group_state") == "NO_TOP5"),
        risk_review_group_count=sum(1 for row in rows if int(row.get("risk_review_count", "0") or 0) > 0),
        heat_quality_path=str(layer_dir / "l12_group_heat_quality.csv"),
        heat_quality_summary_path=str(layer_dir / "l12_group_heat_quality_summary.txt"),
        selection_desk_heat_index_path=str(visible_dir / "00_Group_Heat_Quality_Index.txt"),
        top_heat_group=top_heat,
        top_quality_group=top_quality,
        top_strength_group=top_strength,
    )

    _write(layer_dir / "l12_group_heat_quality.csv", heat_csv, failed)
    _write(layer_dir / "l12_group_heat_quality.manifest", _manifest_text("l12_group_heat_quality", len(rows), heat_csv, "l12_group_heat_quality_published"), failed)
    _write(layer_dir / "l12_component_distribution_by_group.csv", distribution_csv, failed)
    _write(layer_dir / "l12_thin_group_warnings.csv", thin_csv, failed)

    for row in rows:
        slug = _safe_text(row, "ranking_group_slug", _sanitize(row.get("ranking_group", "Unknown")))
        _write(group_dir / f"{_sanitize(slug)}.heat_quality.txt", _group_text(row), failed)

    final = L12PublishSummary(
        status="accepted" if not failed else "write_degraded",
        reason="l12_group_heat_quality_published" if not failed else "one_or_more_l12_outputs_failed",
        ranking_group_count=provisional.ranking_group_count,
        accepted_group_count=provisional.accepted_group_count,
        accepted_with_review_group_count=provisional.accepted_with_review_group_count,
        thin_group_count=provisional.thin_group_count,
        no_top5_group_count=provisional.no_top5_group_count,
        risk_review_group_count=provisional.risk_review_group_count,
        write_failed_count=len(failed),
        heat_quality_path=provisional.heat_quality_path,
        heat_quality_summary_path=provisional.heat_quality_summary_path,
        selection_desk_heat_index_path=provisional.selection_desk_heat_index_path,
        top_heat_group=top_heat,
        top_quality_group=top_quality,
        top_strength_group=top_strength,
    )
    _write(layer_dir / "l12_group_heat_quality_summary.txt", _summary_text(final), failed)
    _write(visible_dir / "00_Group_Heat_Quality_Index.txt", _index_text(rows, final), failed)
    _write(visible_dir / "00_Group_Heat_Quality_Index.csv", heat_csv, failed)
    return final


def publish_l12_ranking_group_heat_quality(outbox_root: Path) -> L12PublishSummary:
    l11_dir = outbox_root / "Layers" / "Layer_11_Symbol_Ranking_Inside_Ranking_Group"
    summary_path = l11_dir / "l11_summary.txt"
    ranked_path = l11_dir / "ranked_symbols_by_group.csv"
    top5_path = l11_dir / "ranking_group_top5.csv"
    manifest_path = l11_dir / "ranked_symbols_by_group.manifest"

    required = [summary_path, ranked_path, top5_path, manifest_path]
    missing = [str(path) for path in required if not path.exists()]
    if missing:
        return L12PublishSummary("pending", "missing_required_l12_source: " + ";".join(missing))

    try:
        l11_summary = _parse_kv(read_text(summary_path))
        l11_status = l11_summary.get("status", "pending")
        if l11_status not in {"accepted", "write_degraded"}:
            return L12PublishSummary("pending" if l11_status == "pending" else "degraded", f"l11_not_accepted_status={l11_status}")

        ranked_text = read_text(ranked_path)
        source_checksum = payload_checksum(ranked_text.splitlines())
        ranked_rows = _read_csv(ranked_path)
        top5_rows = _read_csv(top5_path)
        if not ranked_rows:
            return L12PublishSummary("pending", "l11_ranked_symbols_by_group_empty")

        rows, distribution_rows, thin_rows = _build_group_rows(ranked_rows, top5_rows, source_checksum)
        if not rows:
            return L12PublishSummary("pending", "no_l12_ranking_groups_to_score")
        return _publish(outbox_root, rows, distribution_rows, thin_rows)
    except Exception as exc:
        return L12PublishSummary("exception", f"{type(exc).__name__}: {exc}")
