from __future__ import annotations

from pathlib import Path
from collections import defaultdict
import csv
import io
import time

from aurora_worker_io import WorkerPaths, atomic_write_text, payload_checksum, read_text, unix_time, utc_stamp
from aurora_worker_l12 import L12PublishSummary, publish_l12_ranking_group_heat_quality

DIST_FIELDS = ["ranking_group","rankable_count","l6_available_count","l7_available_count","l8_available_count","l9_available_count","l6_avg","l7_avg","l8_avg","l9_avg","risk_review_count","not_rankable_count"]
THIN_FIELDS = ["ranking_group","group_symbol_count","rankable_count","top5_symbol_count","thin_group_flag","thin_group_reason","selection_runtime","trade_permission"]
RANKABLE_STATES = {"ranked", "ranked_partial", "risk_review"}


def _csv_rows(text: str) -> list[dict[str, str]]:
    return [{str(k): "" if v is None else str(v) for k, v in row.items()} for row in csv.DictReader(io.StringIO(text.replace("\r\n", "\n")))]


def _csv_text(rows: list[dict[str, str]], fields: list[str]) -> str:
    out = io.StringIO(newline="")
    writer = csv.DictWriter(out, fieldnames=fields, extrasaction="ignore", lineterminator="\n")
    writer.writeheader()
    for row in rows:
        writer.writerow({field: row.get(field, "not_available") for field in fields})
    return out.getvalue()


def _num(value: str | None) -> float | None:
    try:
        return float(str(value or "").strip())
    except ValueError:
        return None


def _rankable(row: dict[str, str]) -> bool:
    return str(row.get("rank_state", "")).strip().lower() in RANKABLE_STATES


def _score_values(rows: list[dict[str, str]], key: str) -> list[float]:
    values: list[float] = []
    for row in rows:
        value = _num(row.get(key))
        if value is not None:
            values.append(value)
    return values


def _avg(values: list[float]) -> str:
    return f"{sum(values) / len(values):.2f}" if values else "0.00"


def _publish_l12_contract_reports(paths: WorkerPaths) -> None:
    l12_dir = paths.outbox / "Layers" / "Layer_12_Ranking_Group_Heat_Quality"
    heat_path = l12_dir / "l12_group_heat_quality.csv"
    l11_path = paths.outbox / "Layers" / "Layer_11_Symbol_Ranking_Inside_Ranking_Group" / "ranked_symbols_by_group.csv"
    if not heat_path.exists():
        return
    heat_rows = _csv_rows(read_text(heat_path))
    l11_rows = _csv_rows(read_text(l11_path)) if l11_path.exists() else []
    l11_by_group: dict[str, list[dict[str, str]]] = defaultdict(list)
    for row in l11_rows:
        l11_by_group[row.get("ranking_group", "not_available")].append(row)

    dist_rows: list[dict[str, str]] = []
    thin_rows: list[dict[str, str]] = []
    for heat in heat_rows:
        group = heat.get("ranking_group", "not_available")
        members = l11_by_group.get(group, [])
        rankable_rows = [row for row in members if _rankable(row)]
        if rankable_rows:
            l6 = _score_values(rankable_rows, "l6_score")
            l7 = _score_values(rankable_rows, "l7_score")
            l8 = _score_values(rankable_rows, "l8_score")
            l9 = _score_values(rankable_rows, "l9_score")
            dist_rows.append({
                "ranking_group": group,
                "rankable_count": str(len(rankable_rows)),
                "l6_available_count": str(len(l6)),
                "l7_available_count": str(len(l7)),
                "l8_available_count": str(len(l8)),
                "l9_available_count": str(len(l9)),
                "l6_avg": _avg(l6),
                "l7_avg": _avg(l7),
                "l8_avg": _avg(l8),
                "l9_avg": _avg(l9),
                "risk_review_count": str(sum(1 for row in members if str(row.get("risk_review_flag", "false")).lower() == "true" or str(row.get("rank_state", "")).lower() == "risk_review")),
                "not_rankable_count": str(max(0, len(members) - len(rankable_rows))),
            })
        else:
            dist_rows.append({
                "ranking_group": group,
                "rankable_count": heat.get("rankable_count", "0"),
                "l6_available_count": "0",
                "l7_available_count": "0",
                "l8_available_count": "0",
                "l9_available_count": "0",
                "l6_avg": heat.get("l6_avg_score", "0.00"),
                "l7_avg": heat.get("l7_avg_score", "0.00"),
                "l8_avg": heat.get("l8_avg_score", "0.00"),
                "l9_avg": heat.get("l9_avg_score", "0.00"),
                "risk_review_count": heat.get("risk_review_count", "0"),
                "not_rankable_count": heat.get("not_rankable_count", "0"),
            })
        if heat.get("thin_group_flag", "false") == "true":
            thin_rows.append({
                "ranking_group": group,
                "group_symbol_count": heat.get("group_symbol_count", "0"),
                "rankable_count": heat.get("rankable_count", "0"),
                "top5_symbol_count": heat.get("top5_symbol_count", "0"),
                "thin_group_flag": "true",
                "thin_group_reason": heat.get("thin_group_reason", "not_available"),
                "selection_runtime": "false",
                "trade_permission": "false",
            })
    atomic_write_text(l12_dir / "l12_component_distribution_by_group.csv", _csv_text(dist_rows, DIST_FIELDS))
    atomic_write_text(l12_dir / "l12_thin_group_warnings.csv", _csv_text(thin_rows, THIN_FIELDS))


def l12_result_lines(summary: L12PublishSummary, duration_ms: int) -> str:
    return "\n".join([
        f"l12_group_heat_quality_status={summary.status}",
        f"l12_group_heat_quality_reason={summary.reason}",
        f"l12_group_heat_quality_duration_ms={duration_ms}",
        f"l12_ranking_group_count={summary.ranking_group_count}",
        f"l12_accepted_group_count={summary.accepted_group_count}",
        f"l12_thin_group_count={summary.thin_group_count}",
        f"l12_risk_review_group_count={summary.risk_review_group_count}",
        f"l12_write_failed_count={summary.write_failed_count}",
        f"l12_top_heat_group={summary.top_heat_group}",
        f"l12_top_quality_group={summary.top_quality_group}",
        f"l12_top_strength_group={summary.top_strength_group}",
        f"l12_heat_quality_path={summary.heat_quality_path}",
        f"l12_summary_path={summary.summary_path}",
        f"l12_selection_desk_heat_index_path={summary.selection_desk_heat_index_path}",
        "l12_meaning=ranking_group_attention_quality_only",
        "l12_directional_validity=false",
        "l12_expectancy_validated=false",
        "l12_selection_runtime=false",
        "l12_trade_permission=false",
        "l12_entry_signal=false",
        "l12_execution=false",
        "",
    ])


def _replace_or_append_l12_block(result_text: str, lines: str) -> str:
    marker = "l12_group_heat_quality_status="
    normalized = result_text.replace("\r\n", "\n")
    if marker not in normalized:
        return normalized.rstrip() + "\n" + lines
    before, _sep, tail = normalized.partition(marker)
    kept_tail = []
    for line in tail.splitlines():
        if line.startswith("l12_"):
            continue
        kept_tail.append(line)
    suffix = "\n".join(kept_tail).strip()
    return before.rstrip() + "\n" + lines + (suffix + "\n" if suffix else "")


def run_l12_after_l11(root: Path) -> L12PublishSummary:
    paths = WorkerPaths.from_root(root)
    paths.ensure()
    start_ns = time.perf_counter_ns()
    summary = publish_l12_ranking_group_heat_quality(paths.outbox)
    _publish_l12_contract_reports(paths)
    duration_ms = max(0, (time.perf_counter_ns() - start_ns) // 1_000_000)
    result_path = paths.outbox / "result_latest.txt"
    if result_path.exists():
        text = read_text(result_path)
        updated = _replace_or_append_l12_block(text, l12_result_lines(summary, duration_ms))
        atomic_write_text(result_path, updated)
        manifest_path = paths.outbox / "result_latest.manifest"
        manifest = "\n".join([
            "schema_name=aurora_worker_result_manifest",
            "schema_version=8",
            "worker_l12_append_status=appended_by_l12_dispatch",
            f"result_size={len(updated.encode('utf-8'))}",
            f"payload_checksum={payload_checksum(updated.splitlines())}",
            "authority=calculation_support_only",
            "selection_runtime=false",
            "trade_permission=false",
            "entry_signal=false",
            "execution=false",
            f"generated_utc={utc_stamp()}",
            f"generated_unix={unix_time()}",
            "",
        ])
        atomic_write_text(manifest_path, manifest)
    return summary
