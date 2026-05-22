from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Tuple
import csv
import io
import math

from aurora_worker_io import atomic_write_text, payload_checksum, read_text, unix_time, utc_stamp

L6_LAYER_FOLDER = "Layer_6_Cost_Friction_Ranking"
L6_INPUT_NAME = "l6_input_primitives.csv"
L6_RANKED_NAME = "ranked_symbols.csv"
L6_MANIFEST_NAME = "ranked_symbols.manifest"
L6_TOP20_NAME = "ranked_symbols_top20.txt"
L6_SYMBOL_RANK_FOLDER = "SymbolRanks"
L6_JOB_TYPE = "L6_COST_FRICTION_RANKING_V1"
L6_LAYER_NAME = "Layer 6 - Cost / Friction Ranking"
L6_OWNER = "Runtime 4 - Surface Scoring Owner"

BUCKET_ORDER = {
    "hostile_friction": 0,
    "expensive_friction": 1,
    "acceptable_friction": 2,
    "good_friction": 3,
    "elite_friction": 4,
}
ORDER_BUCKET = {v: k for k, v in BUCKET_ORDER.items()}

OUTPUT_FIELDS = [
    "rank_index",
    "symbol",
    "layer_id",
    "layer_name",
    "friction_score",
    "friction_bucket",
    "rank_state",
    "score_quality",
    "calculation_quality",
    "spread_bps",
    "spread_points",
    "spread_cost_worst_minlot_account",
    "effective_cost_minlot_account",
    "cost_model_compare_status",
    "cost_model_mismatch_ratio",
    "account_cost_zero_nonzero_spread_suspicious",
    "volume_model_quality",
    "commission_model_status",
    "spread_bps_penalty",
    "account_cost_penalty",
    "tick_age_penalty",
    "quote_quality_penalty",
    "surface_quality_penalty",
    "value_quality_penalty",
    "margin_quality_penalty",
    "commission_unknown_penalty",
    "slippage_unknown_penalty",
    "cost_model_mismatch_penalty",
    "zero_cost_suspicious_penalty",
    "volume_model_penalty",
    "reason",
    "trade_permission",
    "selection_runtime",
]


@dataclass
class L6RankSummary:
    status: str
    reason: str
    input_count: int = 0
    row_count: int = 0
    ranked_count: int = 0
    ranked_degraded_count: int = 0
    not_rankable_quality_count: int = 0
    elite_count: int = 0
    good_count: int = 0
    acceptable_count: int = 0
    expensive_count: int = 0
    hostile_count: int = 0
    zero_cost_suspicious_count: int = 0
    mismatch_count: int = 0
    symbol_rank_files_written: int = 0
    payload_checksum: str = "not_available"
    ranked_csv_path: str = "not_available"
    manifest_path: str = "not_available"
    top20_path: str = "not_available"
    symbol_rank_folder_path: str = "not_available"


def _safe_float(value: str | None, default: float = 0.0) -> float:
    if value is None:
        return default
    text = str(value).strip()
    if text == "" or text.lower() in {"nan", "inf", "-inf", "not_available", "pending"}:
        return default
    try:
        number = float(text)
        if math.isnan(number) or math.isinf(number):
            return default
        return number
    except ValueError:
        return default


def _safe_text(row: Dict[str, str], key: str, default: str = "not_available") -> str:
    value = row.get(key, default)
    if value is None or str(value).strip() == "":
        return default
    return str(value).strip()


def _safe_bool_text(value: str | None) -> bool:
    return str(value or "").strip().lower() == "true"


def _sanitize_path_part(value: str) -> str:
    safe = str(value).strip() or "unknown"
    for ch in ['\\', '/', ':', '*', '?', '"', '<', '>', '|', ' ']:
        safe = safe.replace(ch, '_')
    return safe


def _bucket_from_score(score: float) -> str:
    if score >= 90.0:
        return "elite_friction"
    if score >= 75.0:
        return "good_friction"
    if score >= 60.0:
        return "acceptable_friction"
    if score >= 40.0:
        return "expensive_friction"
    return "hostile_friction"


def _apply_bucket_cap(bucket: str, cap: str) -> str:
    return ORDER_BUCKET[min(BUCKET_ORDER.get(bucket, 0), BUCKET_ORDER.get(cap, 0))]


def _spread_penalty_and_cap(spread_bps: float) -> Tuple[float, str, str]:
    if spread_bps >= 100.0:
        return 70.0, "hostile_friction", "spread_bps_ge_100"
    if spread_bps >= 50.0:
        return 55.0, "hostile_friction", "spread_bps_ge_50"
    if spread_bps >= 20.0:
        return 40.0, "expensive_friction", "spread_bps_ge_20"
    if spread_bps >= 10.0:
        return 28.0, "acceptable_friction", "spread_bps_ge_10"
    if spread_bps >= 5.0:
        return 15.0, "good_friction", "spread_bps_ge_5"
    if spread_bps >= 2.0:
        return 6.0, "elite_friction", "spread_bps_ge_2"
    return 0.0, "elite_friction", "spread_bps_clean"


def _quality_penalty(text: str, good_words: Tuple[str, ...], warning_words: Tuple[str, ...], severe_words: Tuple[str, ...]) -> Tuple[float, str]:
    lower = text.lower()
    if any(word in lower for word in severe_words):
        return 20.0, f"severe_{text}"
    if any(word in lower for word in warning_words):
        return 8.0, f"warning_{text}"
    if any(word in lower for word in good_words):
        return 0.0, f"ok_{text}"
    if text in {"not_available", "missing", "pending"}:
        return 14.0, f"unknown_{text}"
    return 4.0, f"review_{text}"


def _effective_cost_minlot(row: Dict[str, str]) -> Tuple[float, str]:
    ordercalc = _safe_float(row.get("spread_cost_worst_minlot_account"))
    value_formula = _safe_float(row.get("value_formula_spread_cost_minlot_account"))
    tickvalue = _safe_float(row.get("tickvalue_spread_cost_minlot_account"))
    contract = _safe_float(row.get("contract_spread_cost_minlot_raw")) if row.get("contract_cost_status") == "raw_account_currency_ok" else 0.0
    candidates = [("ordercalcprofit", ordercalc), ("value_formula", value_formula), ("tickvalue", tickvalue), ("contract_account_currency", contract)]
    usable = [(name, value) for name, value in candidates if value > 0.0]
    if not usable:
        return 0.0, "no_positive_cost_model"
    name, value = max(usable, key=lambda item: item[1])
    return value, name


def _score_row(row: Dict[str, str]) -> Dict[str, str | float]:
    symbol = _safe_text(row, "symbol")
    spread_bps = _safe_float(row.get("spread_bps"))
    spread_points = _safe_float(row.get("spread_points"))
    tick_age = _safe_float(row.get("tick_age_seconds"))
    worst_minlot = _safe_float(row.get("spread_cost_worst_minlot_account"))
    effective_cost, effective_cost_source = _effective_cost_minlot(row)
    compare_status = _safe_text(row, "cost_model_compare_status")
    compare_ratio = _safe_float(row.get("cost_model_mismatch_ratio"))
    zero_suspicious = _safe_bool_text(row.get("account_cost_zero_nonzero_spread_suspicious"))
    volume_model = _safe_text(row, "volume_model_quality")
    commission_status = _safe_text(row, "commission_model_status")

    spread_penalty, bucket_cap, spread_reason = _spread_penalty_and_cap(spread_bps)
    score = 100.0 - spread_penalty
    reasons: List[str] = [spread_reason, f"effective_cost_source={effective_cost_source}"]

    account_cost_penalty = 0.0
    if effective_cost <= 0.0 and spread_bps > 0.0:
        account_cost_penalty = 8.0
        reasons.append("effective_minlot_cost_unavailable")
    elif effective_cost >= 10.0:
        account_cost_penalty = 12.0
        reasons.append("high_minlot_account_cost")
    elif effective_cost >= 2.0:
        account_cost_penalty = 6.0
        reasons.append("moderate_minlot_account_cost")
    score -= account_cost_penalty

    tick_age_penalty = 0.0
    if tick_age > 20.0:
        tick_age_penalty = 10.0
        reasons.append("tick_age_gt_20s")
    elif tick_age > 5.0:
        tick_age_penalty = 4.0
        reasons.append("tick_age_gt_5s")
    score -= tick_age_penalty

    quote_quality_penalty, quote_reason = _quality_penalty(_safe_text(row, "quote_quality"), ("fresh", "ok", "usable"), ("aging", "warning", "partial"), ("missing", "stale", "invalid"))
    surface_quality_penalty, surface_reason = _quality_penalty(_safe_text(row, "surface_quality"), ("usable", "fresh", "ok"), ("warning", "partial"), ("missing", "stale", "invalid"))
    value_quality_penalty, value_reason = _quality_penalty(_safe_text(row, "value_quality"), ("ready", "ok", "complete"), ("partial", "fallback", "warning"), ("missing", "failed", "invalid"))
    margin_quality_penalty, margin_reason = _quality_penalty(_safe_text(row, "margin_quality"), ("ready", "ok", "complete"), ("partial", "fallback", "warning"), ("missing", "failed", "invalid"))
    score -= quote_quality_penalty + surface_quality_penalty + value_quality_penalty + margin_quality_penalty
    reasons += [quote_reason, surface_reason, value_reason, margin_reason]

    commission_unknown_penalty = 0.0
    if commission_status != "known_machine_verified":
        commission_unknown_penalty = 10.0
        bucket_cap = _apply_bucket_cap(bucket_cap, "good_friction")
        reasons.append("commission_not_machine_verified")
    score -= commission_unknown_penalty

    slippage_unknown_penalty = 5.0
    score -= slippage_unknown_penalty
    reasons.append("slippage_not_modelled_v1")

    cost_model_mismatch_penalty = 0.0
    calculation_quality = "complete_cost_model"
    if compare_status == "mismatch_gt_25pct":
        cost_model_mismatch_penalty = 5.0 if spread_bps < 1.0 else 15.0
        calculation_quality = "degraded_cost_model_mismatch"
        reasons.append("cost_model_mismatch_gt_25pct")
    elif compare_status == "warning_gt_10pct":
        cost_model_mismatch_penalty = 6.0
        calculation_quality = "warning_cost_model_mismatch"
        reasons.append("cost_model_warning_gt_10pct")
    elif compare_status == "primary_unavailable_or_zero":
        cost_model_mismatch_penalty = 8.0
        calculation_quality = "degraded_primary_cost_zero_or_unavailable"
        reasons.append("primary_cost_zero_or_unavailable")
    score -= cost_model_mismatch_penalty

    zero_cost_suspicious_penalty = 0.0
    if zero_suspicious:
        zero_cost_suspicious_penalty = 22.0
        bucket_cap = _apply_bucket_cap(bucket_cap, "acceptable_friction")
        calculation_quality = "account_cost_zero_suspicious"
        reasons.append("zero_account_cost_with_nonzero_spread")
    score -= zero_cost_suspicious_penalty

    volume_model_penalty = 0.0
    if volume_model != "normal":
        volume_model_penalty = 12.0
        bucket_cap = _apply_bucket_cap(bucket_cap, "acceptable_friction")
        reasons.append(f"volume_model={volume_model}")
    score -= volume_model_penalty

    score = max(0.0, min(100.0, score))
    bucket = _apply_bucket_cap(_bucket_from_score(score), bucket_cap)

    rank_state = "ranked"
    score_quality = "clean"
    if calculation_quality != "complete_cost_model" or volume_model != "normal" or commission_status != "known_machine_verified":
        rank_state = "ranked_degraded"
        score_quality = "degraded"
    if effective_cost <= 0.0 and spread_bps > 0.0 and zero_suspicious:
        rank_state = "not_rankable_quality"
        score_quality = "not_rankable_quality"

    return {
        "symbol": symbol,
        "friction_score": score,
        "friction_bucket": bucket,
        "rank_state": rank_state,
        "score_quality": score_quality,
        "calculation_quality": calculation_quality,
        "spread_bps": spread_bps,
        "spread_points": spread_points,
        "spread_cost_worst_minlot_account": worst_minlot,
        "effective_cost_minlot_account": effective_cost,
        "cost_model_compare_status": compare_status,
        "cost_model_mismatch_ratio": compare_ratio,
        "account_cost_zero_nonzero_spread_suspicious": "true" if zero_suspicious else "false",
        "volume_model_quality": volume_model,
        "commission_model_status": commission_status,
        "spread_bps_penalty": spread_penalty,
        "account_cost_penalty": account_cost_penalty,
        "tick_age_penalty": tick_age_penalty,
        "quote_quality_penalty": quote_quality_penalty,
        "surface_quality_penalty": surface_quality_penalty,
        "value_quality_penalty": value_quality_penalty,
        "margin_quality_penalty": margin_quality_penalty,
        "commission_unknown_penalty": commission_unknown_penalty,
        "slippage_unknown_penalty": slippage_unknown_penalty,
        "cost_model_mismatch_penalty": cost_model_mismatch_penalty,
        "zero_cost_suspicious_penalty": zero_cost_suspicious_penalty,
        "volume_model_penalty": volume_model_penalty,
        "reason": ";".join(reasons),
        "trade_permission": "false",
        "selection_runtime": "false",
    }


def _format_value(value: str | float) -> str:
    if isinstance(value, float):
        return f"{value:.6f}"
    text = str(value)
    return text.replace("\r", " ").replace("\n", " ").replace(",", "_")


def _write_ranked_csv(scored: List[Dict[str, str | float]]) -> str:
    output = io.StringIO(newline="")
    writer = csv.DictWriter(output, fieldnames=OUTPUT_FIELDS)
    writer.writeheader()
    for index, row in enumerate(scored, start=1):
        out = {field: "" for field in OUTPUT_FIELDS}
        out.update({k: _format_value(v) for k, v in row.items() if k in out})
        out["rank_index"] = str(index)
        out["layer_id"] = "6"
        out["layer_name"] = L6_LAYER_NAME
        writer.writerow(out)
    return output.getvalue().replace("\r\n", "\n").replace("\n", "\r\n")


def _top20_text(scored: List[Dict[str, str | float]]) -> str:
    lines = [
        "LAYER 6 - COST / FRICTION RANKING - TOP 20",
        "----------------------------------------",
        f"Generated UTC: {utc_stamp()}",
        "Trade Permission: FALSE",
        "Selection Runtime: FALSE",
        "",
        "rank|symbol|score|bucket|state|spread_bps|effective_minlot_cost|reason",
    ]
    for index, row in enumerate(scored[:20], start=1):
        lines.append(f"{index}|{row['symbol']}|{float(row['friction_score']):.2f}|{row['friction_bucket']}|{row['rank_state']}|{float(row['spread_bps']):.6f}|{float(row['effective_cost_minlot_account']):.6f}|{row['reason']}")
    lines.append("")
    return "\n".join(lines)


def _symbol_rank_text(rank_index: int, row: Dict[str, str | float]) -> str:
    lines = [
        "schema_name=l6_symbol_rank",
        "schema_version=1",
        "layer_id=6",
        f"layer_name={L6_LAYER_NAME}",
        f"owner_name={L6_OWNER}",
        f"job_type={L6_JOB_TYPE}",
        f"rank_index={rank_index}",
        f"symbol={row['symbol']}",
        f"friction_score={float(row['friction_score']):.6f}",
        f"friction_bucket={row['friction_bucket']}",
        f"rank_state={row['rank_state']}",
        f"score_quality={row['score_quality']}",
        f"calculation_quality={row['calculation_quality']}",
        f"spread_bps={float(row['spread_bps']):.6f}",
        f"spread_points={float(row['spread_points']):.6f}",
        f"effective_cost_minlot_account={float(row['effective_cost_minlot_account']):.6f}",
        f"cost_model_compare_status={row['cost_model_compare_status']}",
        f"account_cost_zero_nonzero_spread_suspicious={row['account_cost_zero_nonzero_spread_suspicious']}",
        f"volume_model_quality={row['volume_model_quality']}",
        f"commission_model_status={row['commission_model_status']}",
        f"reason={_format_value(row['reason'])}",
        "authority=calculation_support_only",
        "trade_permission=false",
        "selection_runtime=false",
        f"generated_utc={utc_stamp()}",
        f"generated_unix={unix_time()}",
        "",
    ]
    return "\n".join(lines)


def _manifest(summary: L6RankSummary, input_path: Path) -> str:
    return "\n".join([
        "schema_name=layer_ranked_symbols_manifest",
        "schema_version=2",
        "layer_id=6",
        f"layer_name={L6_LAYER_NAME}",
        f"owner_name={L6_OWNER}",
        f"job_type={L6_JOB_TYPE}",
        f"status={summary.status}",
        f"reason={summary.reason}",
        f"input_csv_path={input_path}",
        f"ranked_csv_path={summary.ranked_csv_path}",
        f"ranked_manifest_path={summary.manifest_path}",
        f"top20_path={summary.top20_path}",
        f"symbol_rank_folder_path={summary.symbol_rank_folder_path}",
        f"symbol_rank_files_written={summary.symbol_rank_files_written}",
        f"input_count={summary.input_count}",
        f"row_count={summary.row_count}",
        f"ranked_count={summary.ranked_count}",
        f"ranked_degraded_count={summary.ranked_degraded_count}",
        f"not_rankable_quality_count={summary.not_rankable_quality_count}",
        f"elite_friction_count={summary.elite_count}",
        f"good_friction_count={summary.good_count}",
        f"acceptable_friction_count={summary.acceptable_count}",
        f"expensive_friction_count={summary.expensive_count}",
        f"hostile_friction_count={summary.hostile_count}",
        f"zero_cost_nonzero_spread_suspicious_count={summary.zero_cost_suspicious_count}",
        f"cost_model_mismatch_count={summary.mismatch_count}",
        f"payload_checksum={summary.payload_checksum}",
        "authority=calculation_support_only",
        "trade_permission=false",
        "ranking_runtime=true",
        "selection_runtime=false",
        f"generated_utc={utc_stamp()}",
        f"generated_unix={unix_time()}",
        "",
    ])


def publish_l6_cost_friction_rankings(outbox: Path) -> L6RankSummary:
    layer_dir = outbox / "Layers" / L6_LAYER_FOLDER
    input_path = layer_dir / L6_INPUT_NAME
    ranked_path = layer_dir / L6_RANKED_NAME
    manifest_path = layer_dir / L6_MANIFEST_NAME
    top20_path = layer_dir / L6_TOP20_NAME
    symbol_rank_dir = layer_dir / L6_SYMBOL_RANK_FOLDER
    layer_dir.mkdir(parents=True, exist_ok=True)
    symbol_rank_dir.mkdir(parents=True, exist_ok=True)

    summary = L6RankSummary(
        status="missing_input",
        reason="l6_input_primitives.csv missing",
        ranked_csv_path=str(ranked_path),
        manifest_path=str(manifest_path),
        top20_path=str(top20_path),
        symbol_rank_folder_path=str(symbol_rank_dir),
    )
    if not input_path.exists():
        atomic_write_text(manifest_path, _manifest(summary, input_path))
        return summary

    text = read_text(input_path)
    reader = csv.DictReader(io.StringIO(text.replace("\r\n", "\n")))
    rows = [row for row in reader]
    summary.input_count = len(rows)
    scored = [_score_row(row) for row in rows]
    scored.sort(key=lambda row: (
        BUCKET_ORDER.get(str(row["friction_bucket"]), 0),
        float(row["friction_score"]),
        -float(row["spread_bps"]),
        -float(row["effective_cost_minlot_account"]),
        str(row["symbol"]),
    ), reverse=True)

    ranked_csv = _write_ranked_csv(scored)
    ranked_lines = [line for line in ranked_csv.replace("\r\n", "\n").splitlines() if line.strip()]
    summary.payload_checksum = payload_checksum(ranked_lines)
    summary.status = "complete"
    summary.reason = "ranked all Layer 5 pass symbols from L6 input primitives"
    summary.row_count = len(scored)
    summary.ranked_count = sum(1 for row in scored if row["rank_state"] == "ranked")
    summary.ranked_degraded_count = sum(1 for row in scored if row["rank_state"] == "ranked_degraded")
    summary.not_rankable_quality_count = sum(1 for row in scored if row["rank_state"] == "not_rankable_quality")
    summary.elite_count = sum(1 for row in scored if row["friction_bucket"] == "elite_friction")
    summary.good_count = sum(1 for row in scored if row["friction_bucket"] == "good_friction")
    summary.acceptable_count = sum(1 for row in scored if row["friction_bucket"] == "acceptable_friction")
    summary.expensive_count = sum(1 for row in scored if row["friction_bucket"] == "expensive_friction")
    summary.hostile_count = sum(1 for row in scored if row["friction_bucket"] == "hostile_friction")
    summary.zero_cost_suspicious_count = sum(1 for row in scored if row["account_cost_zero_nonzero_spread_suspicious"] == "true")
    summary.mismatch_count = sum(1 for row in scored if row["cost_model_compare_status"] in {"mismatch_gt_25pct", "warning_gt_10pct"})

    ranked_ok = atomic_write_text(ranked_path, ranked_csv)
    top20_ok = atomic_write_text(top20_path, _top20_text(scored))
    files_written = 0
    for index, row in enumerate(scored, start=1):
        symbol_path = symbol_rank_dir / f"{_sanitize_path_part(str(row['symbol']))}.txt"
        if atomic_write_text(symbol_path, _symbol_rank_text(index, row)):
            files_written += 1
    summary.symbol_rank_files_written = files_written

    if not ranked_ok or not top20_ok or files_written != len(scored):
        summary.status = "write_degraded"
        summary.reason = "ranked CSV, top20, or per-symbol rank write failed; sidecar proof may be partial"
    atomic_write_text(manifest_path, _manifest(summary, input_path))
    return summary
