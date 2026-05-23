from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Tuple
import csv
import io
import math

from aurora_worker_io import atomic_write_text, payload_checksum, read_text, unix_time, utc_stamp

L8_LAYER_FOLDER = "Layer_8_Movement_Range_Ranking"
L8_INPUT_NAME = "l8_input_primitives.csv"
L8_INPUT_MANIFEST_NAME = "l8_input_primitives.manifest"
L8_RANKED_NAME = "ranked_symbols.csv"
L8_MANIFEST_NAME = "ranked_symbols.manifest"
L8_TOP20_NAME = "ranked_symbols_top20.txt"
L8_SYMBOL_RANK_FOLDER = "SymbolRanks"
L8_SYMBOL_RANK_FILENAME_MODE = "sanitized_symbol__payload_checksum"
L8_JOB_TYPE = "L8_MOVEMENT_RANGE_RANKING_V1"
L8_LAYER_NAME = "Layer 8 - Movement / Range Ranking"
L8_OWNER = "Runtime 4 - Surface Scoring Owner"

MOVEMENT_BUCKET_ORDER = {
    "poor_movement_range": 0,
    "weak_movement_range": 1,
    "acceptable_movement_range": 2,
    "strong_movement_range": 3,
    "elite_movement_range": 4,
}

OUTPUT_FIELDS = [
    "rank_index", "symbol", "layer_id", "layer_name", "movement_score", "movement_bucket",
    "rank_state", "score_quality", "range_availability_score", "movement_quality_score",
    "expansion_compression_score", "range_position_quality_score", "quote_surface_quality_score",
    "m5_bars_copied", "m15_bars_copied", "h1_bars_copied", "m5_expansion_ratio",
    "m15_expansion_ratio", "h1_expansion_ratio", "m5_compression_ratio", "m15_compression_ratio",
    "h1_compression_ratio", "m5_range_points_48", "m15_range_points_64", "h1_range_points_72",
    "m5_close_position_in_48_range_pct", "m15_close_position_in_64_range_pct",
    "h1_close_position_in_72_range_pct", "quote_quality", "surface_quality", "tick_age_seconds",
    "spread_bps", "reason", "trade_permission", "selection_runtime",
]


@dataclass
class L8RankSummary:
    status: str
    reason: str
    input_count: int = 0
    source_input_manifest_present: bool = False
    source_input_manifest_row_count: int = 0
    source_l5_gate_pass: int = 0
    source_input_payload_checksum: str = "not_available"
    input_payload_checksum: str = "not_available"
    input_payload_checksum_after_rank: str = "not_available"
    input_generation_stable: bool = False
    row_count: int = 0
    ranked_count: int = 0
    ranked_partial_count: int = 0
    ranked_degraded_count: int = 0
    not_rankable_quality_count: int = 0
    elite_count: int = 0
    strong_count: int = 0
    acceptable_count: int = 0
    weak_count: int = 0
    poor_count: int = 0
    symbol_rank_files_written: int = 0
    symbol_rank_files_actual: int = 0
    symbol_rank_filename_mode: str = L8_SYMBOL_RANK_FILENAME_MODE
    stale_tmp_files_removed: int = 0
    stale_tmp_files_failed: int = 0
    payload_checksum: str = "not_available"
    ranked_csv_path: str = "not_available"
    manifest_path: str = "not_available"
    top20_path: str = "not_available"
    symbol_rank_folder_path: str = "not_available"


def _safe_float(value: str | None, default: float = 0.0) -> float:
    if value is None:
        return default
    text = str(value).strip()
    if text == "" or text.lower() in {"nan", "inf", "-inf", "not_available", "pending", "partial"}:
        return default
    try:
        number = float(text)
        if math.isnan(number) or math.isinf(number):
            return default
        return number
    except ValueError:
        return default


def _safe_int(value: str | None, default: int = 0) -> int:
    if value is None:
        return default
    text = str(value).strip()
    if text == "" or text.lower() in {"nan", "inf", "-inf", "not_available", "pending", "partial"}:
        return default
    try:
        return int(float(text))
    except ValueError:
        return default


def _safe_text(row: Dict[str, str], key: str, default: str = "not_available") -> str:
    value = row.get(key, default)
    if value is None or str(value).strip() == "":
        return default
    return str(value).strip()


def _parse_kv_text(text: str) -> Dict[str, str]:
    data: Dict[str, str] = {}
    for raw_line in text.replace("\r\n", "\n").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        data[key.strip()] = value.strip()
    return data


def _sanitize_path_part(value: str) -> str:
    safe = str(value).strip() or "unknown"
    for ch in ['\\', '/', ':', '*', '?', '"', '<', '>', '|', ' ']:
        safe = safe.replace(ch, '_')
    return safe


def _symbol_checksum(symbol: str) -> str:
    return payload_checksum([str(symbol).strip() or "unknown"])


def _symbol_rank_filename(symbol: str) -> str:
    return f"{_sanitize_path_part(symbol)}__{_symbol_checksum(symbol)}.txt"


def _remove_file_if_exists(path: Path) -> Tuple[int, int]:
    if not path.exists():
        return 0, 0
    try:
        path.unlink()
        return 1, 0
    except OSError:
        return 0, 1


def _cleanup_glob(folder: Path, pattern: str) -> Tuple[int, int]:
    removed = 0
    failed = 0
    if not folder.exists():
        return removed, failed
    for path in folder.glob(pattern):
        r, f = _remove_file_if_exists(path)
        removed += r
        failed += f
    return removed, failed


def _clear_symbol_rank_files(symbol_rank_dir: Path) -> Tuple[int, int]:
    removed = 0
    failed = 0
    if not symbol_rank_dir.exists():
        return removed, failed
    for pattern in ("*.txt", "*.tmp", "*.write_failed.txt"):
        r, f = _cleanup_glob(symbol_rank_dir, pattern)
        removed += r
        failed += f
    return removed, failed


def _clear_layer_transient_files(layer_dir: Path) -> Tuple[int, int]:
    removed = 0
    failed = 0
    for pattern in ("*.tmp", "*.write_failed.txt"):
        r, f = _cleanup_glob(layer_dir, pattern)
        removed += r
        failed += f
    return removed, failed


def _clear_final_rank_outputs(ranked_path: Path, top20_path: Path, symbol_rank_dir: Path) -> Tuple[int, int]:
    removed = 0
    failed = 0
    for path in (ranked_path, top20_path):
        r, f = _remove_file_if_exists(path)
        removed += r
        failed += f
    r, f = _clear_symbol_rank_files(symbol_rank_dir)
    removed += r
    failed += f
    return removed, failed


def _final_symbol_rank_txt_count(symbol_rank_dir: Path) -> int:
    if not symbol_rank_dir.exists():
        return 0
    return sum(1 for p in symbol_rank_dir.glob("*.txt") if p.is_file())


def _csv_payload_checksum(text: str) -> str:
    rows = [line for line in text.replace("\r\n", "\n").splitlines() if line.strip()]
    return payload_checksum(rows)


def _quality_score(text: str, good_words: Tuple[str, ...], warning_words: Tuple[str, ...], severe_words: Tuple[str, ...]) -> Tuple[float, str]:
    lower = text.lower()
    if any(word in lower for word in severe_words):
        return 10.0, f"severe_{text}"
    if any(word in lower for word in warning_words):
        return 55.0, f"warning_{text}"
    if any(word in lower for word in good_words):
        return 90.0, f"ok_{text}"
    if text in {"not_available", "missing", "pending"}:
        return 30.0, f"unknown_{text}"
    return 60.0, f"review_{text}"


def _availability_component(copied: int, requested: int, minimum: int) -> Tuple[float, str]:
    if requested <= 0:
        return 0.0, "invalid_request"
    if copied >= requested:
        return 100.0, "bars_full"
    if copied >= minimum:
        return max(45.0, min(80.0, 100.0 * copied / requested)), "bars_partial"
    if copied > 0:
        return 20.0, "bars_insufficient"
    return 0.0, "bars_missing"


def _expansion_score(ratio: float) -> Tuple[float, str]:
    if ratio <= 0.0:
        return 15.0, "expansion_unavailable"
    if ratio < 0.55:
        return 20.0, "compressed_severe"
    if ratio < 0.75:
        return 40.0, "compressed"
    if ratio < 1.05:
        return 65.0, "neutral_to_mild_compression"
    if ratio <= 1.80:
        return 92.0, "usable_expansion"
    if ratio <= 3.00:
        return 72.0, "hot_expansion_review"
    return 35.0, "violent_expansion_review"


def _range_position_score(position_pct: float) -> Tuple[float, str]:
    if position_pct <= 0.0:
        return 45.0, "range_position_unavailable_or_floor"
    if 20.0 <= position_pct <= 80.0:
        return 90.0, "range_position_not_extreme"
    if 5.0 <= position_pct < 20.0 or 80.0 < position_pct <= 95.0:
        return 65.0, "range_position_edge_caution"
    return 35.0, "range_position_extreme"


def _movement_presence_score(row: Dict[str, str]) -> Tuple[float, str]:
    ranges = [
        _safe_float(row.get("m5_range_points_48")),
        _safe_float(row.get("m15_range_points_64")),
        _safe_float(row.get("h1_range_points_72")),
    ]
    nonzero = sum(1 for value in ranges if value > 0.0)
    if nonzero == 3:
        return 90.0, "movement_present_all_timeframes"
    if nonzero == 2:
        return 72.0, "movement_present_two_timeframes"
    if nonzero == 1:
        return 45.0, "movement_present_one_timeframe"
    return 10.0, "movement_absent_or_unavailable"


def _bucket_from_score(score: float) -> str:
    if score >= 85.0:
        return "elite_movement_range"
    if score >= 70.0:
        return "strong_movement_range"
    if score >= 55.0:
        return "acceptable_movement_range"
    if score >= 35.0:
        return "weak_movement_range"
    return "poor_movement_range"


def _score_row(row: Dict[str, str]) -> Dict[str, str | float]:
    symbol = _safe_text(row, "symbol")
    market_state = _safe_text(row, "market_state")
    quote_quality = _safe_text(row, "quote_quality")
    surface_quality = _safe_text(row, "surface_quality")
    tick_age = _safe_float(row.get("tick_age_seconds"))
    spread_bps = _safe_float(row.get("spread_bps"))

    m5_copied = _safe_int(row.get("m5_bars_copied"))
    m15_copied = _safe_int(row.get("m15_bars_copied"))
    h1_copied = _safe_int(row.get("h1_bars_copied"))
    m5_requested = _safe_int(row.get("m5_bars_requested"), 64)
    m15_requested = _safe_int(row.get("m15_bars_requested"), 80)
    h1_requested = _safe_int(row.get("h1_bars_requested"), 80)

    a5, r5 = _availability_component(m5_copied, m5_requested, 48)
    a15, r15 = _availability_component(m15_copied, m15_requested, 64)
    a1, r1 = _availability_component(h1_copied, h1_requested, 72)
    availability_score = (a5 * 0.40) + (a15 * 0.35) + (a1 * 0.25)

    movement_score, movement_reason = _movement_presence_score(row)

    e5, er5 = _expansion_score(_safe_float(row.get("m5_expansion_ratio")))
    e15, er15 = _expansion_score(_safe_float(row.get("m15_expansion_ratio")))
    e1, er1 = _expansion_score(_safe_float(row.get("h1_expansion_ratio")))
    expansion_score = (e5 * 0.40) + (e15 * 0.35) + (e1 * 0.25)

    p5, pr5 = _range_position_score(_safe_float(row.get("m5_close_position_in_48_range_pct")))
    p15, pr15 = _range_position_score(_safe_float(row.get("m15_close_position_in_64_range_pct")))
    p1, pr1 = _range_position_score(_safe_float(row.get("h1_close_position_in_72_range_pct")))
    position_score = (p5 * 0.40) + (p15 * 0.35) + (p1 * 0.25)

    quote_score, quote_reason = _quality_score(quote_quality, ("fresh", "ok", "usable"), ("aging", "warning", "partial"), ("missing", "stale", "invalid"))
    surface_score, surface_reason = _quality_score(surface_quality, ("usable", "fresh", "ok"), ("warning", "partial", "aging"), ("missing", "stale", "invalid"))
    live_surface_score = (quote_score * 0.55) + (surface_score * 0.45)
    if tick_age > 60.0:
        live_surface_score = min(live_surface_score, 35.0)
    elif tick_age > 20.0:
        live_surface_score = min(live_surface_score, 65.0)

    score = (
        availability_score * 0.20
        + movement_score * 0.25
        + expansion_score * 0.25
        + position_score * 0.15
        + live_surface_score * 0.15
    )
    score = max(0.0, min(100.0, score))

    reasons: List[str] = [
        "ok_L5Pass", f"m5_{r5}", f"m15_{r15}", f"h1_{r1}", movement_reason,
        f"m5_{er5}", f"m15_{er15}", f"h1_{er1}", f"m5_{pr5}", f"m15_{pr15}", f"h1_{pr1}",
        quote_reason, surface_reason, "movement_range_ranking_only_no_direction_no_entry",
    ]

    rank_state = "ranked"
    score_quality = "usable_movement_range_model"
    if market_state != "open":
        rank_state = "not_rankable_quality"
        score_quality = "not_rankable_market_not_open"
        reasons.append(f"market_state={market_state}")
    elif m5_copied < 24 and m15_copied < 24 and h1_copied < 24:
        rank_state = "not_rankable_quality"
        score_quality = "not_rankable_insufficient_bars"
    elif availability_score < 55.0:
        rank_state = "ranked_degraded"
        score_quality = "degraded_range_history_availability"
    elif live_surface_score < 50.0:
        rank_state = "ranked_degraded"
        score_quality = "degraded_quote_or_surface_quality"
    elif availability_score < 85.0:
        rank_state = "ranked_partial"
        score_quality = "usable_with_partial_range_history"

    bucket = _bucket_from_score(score)
    return {
        "symbol": symbol,
        "movement_score": score,
        "movement_bucket": bucket,
        "rank_state": rank_state,
        "score_quality": score_quality,
        "range_availability_score": availability_score,
        "movement_quality_score": movement_score,
        "expansion_compression_score": expansion_score,
        "range_position_quality_score": position_score,
        "quote_surface_quality_score": live_surface_score,
        "m5_bars_copied": float(m5_copied),
        "m15_bars_copied": float(m15_copied),
        "h1_bars_copied": float(h1_copied),
        "m5_expansion_ratio": _safe_float(row.get("m5_expansion_ratio")),
        "m15_expansion_ratio": _safe_float(row.get("m15_expansion_ratio")),
        "h1_expansion_ratio": _safe_float(row.get("h1_expansion_ratio")),
        "m5_compression_ratio": _safe_float(row.get("m5_compression_ratio")),
        "m15_compression_ratio": _safe_float(row.get("m15_compression_ratio")),
        "h1_compression_ratio": _safe_float(row.get("h1_compression_ratio")),
        "m5_range_points_48": _safe_float(row.get("m5_range_points_48")),
        "m15_range_points_64": _safe_float(row.get("m15_range_points_64")),
        "h1_range_points_72": _safe_float(row.get("h1_range_points_72")),
        "m5_close_position_in_48_range_pct": _safe_float(row.get("m5_close_position_in_48_range_pct")),
        "m15_close_position_in_64_range_pct": _safe_float(row.get("m15_close_position_in_64_range_pct")),
        "h1_close_position_in_72_range_pct": _safe_float(row.get("h1_close_position_in_72_range_pct")),
        "quote_quality": quote_quality,
        "surface_quality": surface_quality,
        "tick_age_seconds": tick_age,
        "spread_bps": spread_bps,
        "reason": ";".join(reasons),
        "trade_permission": "false",
        "selection_runtime": "false",
    }


def _format_value(value: str | float) -> str:
    if isinstance(value, float):
        return f"{value:.6f}"
    return str(value).replace("\r", " ").replace("\n", " ").replace(",", "_")


def _write_ranked_csv(scored: List[Dict[str, str | float]]) -> str:
    output = io.StringIO(newline="")
    writer = csv.DictWriter(output, fieldnames=OUTPUT_FIELDS)
    writer.writeheader()
    for index, row in enumerate(scored, start=1):
        out = {field: "" for field in OUTPUT_FIELDS}
        out.update({k: _format_value(v) for k, v in row.items() if k in out})
        out["rank_index"] = str(index)
        out["layer_id"] = "8"
        out["layer_name"] = L8_LAYER_NAME
        writer.writerow(out)
    return output.getvalue().replace("\r\n", "\n").replace("\n", "\r\n")


def _top20_text(scored: List[Dict[str, str | float]]) -> str:
    lines = [
        "LAYER 8 - MOVEMENT / RANGE RANKING - TOP 20",
        "----------------------------------------",
        f"Generated UTC: {utc_stamp()}",
        "Trade Permission: FALSE",
        "Selection Runtime: FALSE",
        "Policy: Movement/range ranking only; no direction, entry, selection, or execution authority.",
        "",
        "rank|symbol|score|bucket|state|m5_expansion|m15_expansion|h1_expansion|reason",
    ]
    for index, row in enumerate(scored[:20], start=1):
        lines.append(
            f"{index}|{row['symbol']}|{float(row['movement_score']):.2f}|{row['movement_bucket']}|{row['rank_state']}|"
            f"{float(row['m5_expansion_ratio']):.4f}|{float(row['m15_expansion_ratio']):.4f}|{float(row['h1_expansion_ratio']):.4f}|{row['reason']}"
        )
    lines.append("")
    return "\n".join(lines)


def _symbol_rank_text(rank_index: int, row: Dict[str, str | float]) -> str:
    symbol = str(row["symbol"])
    lines = [
        "schema_name=l8_symbol_rank", "schema_version=1", "layer_id=8", f"layer_name={L8_LAYER_NAME}",
        f"owner_name={L8_OWNER}", f"job_type={L8_JOB_TYPE}", f"rank_index={rank_index}", f"symbol={symbol}",
        f"symbol_rank_filename_mode={L8_SYMBOL_RANK_FILENAME_MODE}", f"symbol_rank_filename={_symbol_rank_filename(symbol)}",
        f"symbol_rank_checksum={_symbol_checksum(symbol)}",
        f"movement_score={float(row['movement_score']):.6f}", f"movement_bucket={row['movement_bucket']}",
        f"rank_state={row['rank_state']}", f"score_quality={row['score_quality']}",
        f"range_availability_score={float(row['range_availability_score']):.6f}",
        f"movement_quality_score={float(row['movement_quality_score']):.6f}",
        f"expansion_compression_score={float(row['expansion_compression_score']):.6f}",
        f"range_position_quality_score={float(row['range_position_quality_score']):.6f}",
        f"quote_surface_quality_score={float(row['quote_surface_quality_score']):.6f}",
        f"m5_bars_copied={float(row['m5_bars_copied']):.6f}", f"m15_bars_copied={float(row['m15_bars_copied']):.6f}",
        f"h1_bars_copied={float(row['h1_bars_copied']):.6f}", f"m5_expansion_ratio={float(row['m5_expansion_ratio']):.6f}",
        f"m15_expansion_ratio={float(row['m15_expansion_ratio']):.6f}", f"h1_expansion_ratio={float(row['h1_expansion_ratio']):.6f}",
        f"m5_compression_ratio={float(row['m5_compression_ratio']):.6f}", f"m15_compression_ratio={float(row['m15_compression_ratio']):.6f}",
        f"h1_compression_ratio={float(row['h1_compression_ratio']):.6f}", f"m5_range_points_48={float(row['m5_range_points_48']):.6f}",
        f"m15_range_points_64={float(row['m15_range_points_64']):.6f}", f"h1_range_points_72={float(row['h1_range_points_72']):.6f}",
        f"m5_close_position_in_48_range_pct={float(row['m5_close_position_in_48_range_pct']):.6f}",
        f"m15_close_position_in_64_range_pct={float(row['m15_close_position_in_64_range_pct']):.6f}",
        f"h1_close_position_in_72_range_pct={float(row['h1_close_position_in_72_range_pct']):.6f}",
        f"quote_quality={row['quote_quality']}", f"surface_quality={row['surface_quality']}",
        f"tick_age_seconds={float(row['tick_age_seconds']):.6f}", f"spread_bps={float(row['spread_bps']):.6f}",
        f"reason={_format_value(row['reason'])}", "authority=calculation_support_only", "trade_permission=false",
        "selection_runtime=false", f"generated_utc={utc_stamp()}", f"generated_unix={unix_time()}", "",
    ]
    return "\n".join(lines)


def _manifest(summary: L8RankSummary, input_path: Path) -> str:
    source_counts_ok = summary.source_input_manifest_present and summary.input_count == summary.source_input_manifest_row_count
    source_l5_ok = summary.source_l5_gate_pass <= 0 or summary.input_count == summary.source_l5_gate_pass
    input_manifest_checksum_ok = summary.source_input_payload_checksum in {"not_available", ""} or summary.source_input_payload_checksum == summary.input_payload_checksum
    symbol_files_ok = summary.symbol_rank_files_written == summary.row_count and summary.symbol_rank_files_actual == summary.row_count
    return "\n".join([
        "schema_name=layer_ranked_symbols_manifest", "schema_version=1", "layer_id=8", f"layer_name={L8_LAYER_NAME}",
        f"owner_name={L8_OWNER}", f"job_type={L8_JOB_TYPE}", f"status={summary.status}", f"reason={summary.reason}",
        f"input_csv_path={input_path}", f"source_input_manifest_present={'true' if summary.source_input_manifest_present else 'false'}",
        f"source_input_manifest_row_count={summary.source_input_manifest_row_count}", f"source_l5_gate_pass={summary.source_l5_gate_pass}",
        f"source_input_payload_checksum={summary.source_input_payload_checksum}", f"input_payload_checksum={summary.input_payload_checksum}",
        f"input_payload_checksum_after_rank={summary.input_payload_checksum_after_rank}",
        f"input_generation_stable={'true' if summary.input_generation_stable else 'false'}",
        f"input_payload_checksum_matches_source_manifest={'true' if input_manifest_checksum_ok else 'false'}",
        f"input_csv_count_matches_input_manifest={'true' if source_counts_ok else 'false'}",
        f"input_csv_count_matches_source_l5_gate_pass={'true' if source_l5_ok else 'false'}",
        f"ranked_csv_path={summary.ranked_csv_path}", f"ranked_manifest_path={summary.manifest_path}", f"top20_path={summary.top20_path}",
        f"symbol_rank_folder_path={summary.symbol_rank_folder_path}", f"symbol_rank_filename_mode={summary.symbol_rank_filename_mode}",
        f"symbol_rank_files_written={summary.symbol_rank_files_written}", f"symbol_rank_files_actual={summary.symbol_rank_files_actual}",
        f"symbol_rank_file_count_ok={'true' if symbol_files_ok else 'false'}", f"stale_tmp_files_removed={summary.stale_tmp_files_removed}",
        f"stale_tmp_files_failed={summary.stale_tmp_files_failed}", f"input_count={summary.input_count}", f"row_count={summary.row_count}",
        f"ranked_count={summary.ranked_count}", f"ranked_partial_count={summary.ranked_partial_count}",
        f"ranked_degraded_count={summary.ranked_degraded_count}", f"not_rankable_quality_count={summary.not_rankable_quality_count}",
        f"elite_movement_range_count={summary.elite_count}", f"strong_movement_range_count={summary.strong_count}",
        f"acceptable_movement_range_count={summary.acceptable_count}", f"weak_movement_range_count={summary.weak_count}",
        f"poor_movement_range_count={summary.poor_count}", f"payload_checksum={summary.payload_checksum}",
        "authority=calculation_support_only", "trade_permission=false", "ranking_runtime=true", "selection_runtime=false",
        "movement_range_policy=ranking_only_no_direction_no_entry_no_selection_no_execution",
        f"generated_utc={utc_stamp()}", f"generated_unix={unix_time()}", "",
    ])


def _summary_from_ranked_manifest(manifest_text: str, fallback: L8RankSummary) -> L8RankSummary:
    data = _parse_kv_text(manifest_text)
    return L8RankSummary(
        status=data.get("status", fallback.status),
        reason=data.get("reason", fallback.reason),
        input_count=_safe_int(data.get("input_count"), fallback.input_count),
        source_input_manifest_present=data.get("source_input_manifest_present", "false").lower() == "true",
        source_input_manifest_row_count=_safe_int(data.get("source_input_manifest_row_count"), fallback.source_input_manifest_row_count),
        source_l5_gate_pass=_safe_int(data.get("source_l5_gate_pass"), fallback.source_l5_gate_pass),
        source_input_payload_checksum=data.get("source_input_payload_checksum", fallback.source_input_payload_checksum),
        input_payload_checksum=data.get("input_payload_checksum", fallback.input_payload_checksum),
        input_payload_checksum_after_rank=data.get("input_payload_checksum_after_rank", fallback.input_payload_checksum_after_rank),
        input_generation_stable=data.get("input_generation_stable", "false").lower() == "true",
        row_count=_safe_int(data.get("row_count"), fallback.row_count),
        ranked_count=_safe_int(data.get("ranked_count"), fallback.ranked_count),
        ranked_partial_count=_safe_int(data.get("ranked_partial_count"), fallback.ranked_partial_count),
        ranked_degraded_count=_safe_int(data.get("ranked_degraded_count"), fallback.ranked_degraded_count),
        not_rankable_quality_count=_safe_int(data.get("not_rankable_quality_count"), fallback.not_rankable_quality_count),
        elite_count=_safe_int(data.get("elite_movement_range_count"), fallback.elite_count),
        strong_count=_safe_int(data.get("strong_movement_range_count"), fallback.strong_count),
        acceptable_count=_safe_int(data.get("acceptable_movement_range_count"), fallback.acceptable_count),
        weak_count=_safe_int(data.get("weak_movement_range_count"), fallback.weak_count),
        poor_count=_safe_int(data.get("poor_movement_range_count"), fallback.poor_count),
        symbol_rank_files_written=_safe_int(data.get("symbol_rank_files_written"), fallback.symbol_rank_files_written),
        symbol_rank_files_actual=_safe_int(data.get("symbol_rank_files_actual"), fallback.symbol_rank_files_actual),
        symbol_rank_filename_mode=data.get("symbol_rank_filename_mode", fallback.symbol_rank_filename_mode),
        stale_tmp_files_removed=fallback.stale_tmp_files_removed,
        stale_tmp_files_failed=fallback.stale_tmp_files_failed,
        payload_checksum=data.get("payload_checksum", fallback.payload_checksum),
        ranked_csv_path=fallback.ranked_csv_path,
        manifest_path=fallback.manifest_path,
        top20_path=fallback.top20_path,
        symbol_rank_folder_path=fallback.symbol_rank_folder_path,
    )


def _try_reuse_unchanged_rank_outputs(summary: L8RankSummary, manifest_path: Path, ranked_path: Path, top20_path: Path, symbol_rank_dir: Path) -> L8RankSummary | None:
    if not summary.source_input_manifest_present:
        return None
    if summary.source_input_payload_checksum in {"", "not_available"}:
        return None
    if summary.input_payload_checksum != summary.source_input_payload_checksum:
        return None
    if not manifest_path.exists() or not ranked_path.exists() or not top20_path.exists():
        return None
    existing = _summary_from_ranked_manifest(read_text(manifest_path), summary)
    actual_symbol_rank_files = _final_symbol_rank_txt_count(symbol_rank_dir)
    if existing.status not in {"complete", "input_degraded"}:
        return None
    if existing.symbol_rank_filename_mode != L8_SYMBOL_RANK_FILENAME_MODE:
        return None
    if not existing.input_generation_stable:
        return None
    if existing.input_payload_checksum != summary.input_payload_checksum:
        return None
    if existing.input_payload_checksum_after_rank != summary.input_payload_checksum:
        return None
    if existing.source_input_payload_checksum != summary.source_input_payload_checksum:
        return None
    if existing.input_count <= 0 or existing.row_count != existing.input_count:
        return None
    if existing.symbol_rank_files_written != existing.row_count:
        return None
    if actual_symbol_rank_files != existing.row_count:
        return None
    existing.reason = "skipped_unchanged_input_reused_existing_ranked_outputs;" + existing.reason
    existing.stale_tmp_files_removed = summary.stale_tmp_files_removed
    existing.stale_tmp_files_failed = summary.stale_tmp_files_failed
    existing.symbol_rank_files_actual = actual_symbol_rank_files
    return existing


def publish_l8_movement_range_rankings(outbox: Path) -> L8RankSummary:
    layer_dir = outbox / "Layers" / L8_LAYER_FOLDER
    input_path = layer_dir / L8_INPUT_NAME
    input_manifest_path = layer_dir / L8_INPUT_MANIFEST_NAME
    ranked_path = layer_dir / L8_RANKED_NAME
    manifest_path = layer_dir / L8_MANIFEST_NAME
    top20_path = layer_dir / L8_TOP20_NAME
    symbol_rank_dir = layer_dir / L8_SYMBOL_RANK_FOLDER
    layer_dir.mkdir(parents=True, exist_ok=True)
    symbol_rank_dir.mkdir(parents=True, exist_ok=True)

    summary = L8RankSummary("missing_input", "l8_input_primitives.csv missing", ranked_csv_path=str(ranked_path), manifest_path=str(manifest_path), top20_path=str(top20_path), symbol_rank_folder_path=str(symbol_rank_dir))
    if input_manifest_path.exists():
        input_manifest = _parse_kv_text(read_text(input_manifest_path))
        summary.source_input_manifest_present = True
        summary.source_input_manifest_row_count = _safe_int(input_manifest.get("row_count"), 0)
        summary.source_l5_gate_pass = _safe_int(input_manifest.get("l5_gate_pass"), 0)
        summary.source_input_payload_checksum = input_manifest.get("payload_checksum", "not_available")

    removed, failed = _clear_layer_transient_files(layer_dir)
    sr_removed, sr_failed = _cleanup_glob(symbol_rank_dir, "*.tmp")
    summary.stale_tmp_files_removed += removed + sr_removed
    summary.stale_tmp_files_failed += failed + sr_failed

    if not input_path.exists():
        removed, failed = _clear_final_rank_outputs(ranked_path, top20_path, symbol_rank_dir)
        summary.stale_tmp_files_removed += removed
        summary.stale_tmp_files_failed += failed
        atomic_write_text(manifest_path, _manifest(summary, input_path))
        return summary

    text = read_text(input_path)
    summary.input_payload_checksum = _csv_payload_checksum(text)
    reused = _try_reuse_unchanged_rank_outputs(summary, manifest_path, ranked_path, top20_path, symbol_rank_dir)
    if reused is not None:
        atomic_write_text(manifest_path, _manifest(reused, input_path))
        return reused

    reader = csv.DictReader(io.StringIO(text.replace("\r\n", "\n")))
    rows = [row for row in reader]
    summary.input_count = len(rows)
    scored = [_score_row(row) for row in rows]
    scored.sort(key=lambda row: (
        MOVEMENT_BUCKET_ORDER.get(str(row["movement_bucket"]), 0),
        float(row["movement_score"]),
        float(row["range_availability_score"]),
        float(row["expansion_compression_score"]),
        str(row["symbol"]),
    ), reverse=True)

    text_after_rank = read_text(input_path)
    summary.input_payload_checksum_after_rank = _csv_payload_checksum(text_after_rank)
    after_rows = [row for row in csv.DictReader(io.StringIO(text_after_rank.replace("\r\n", "\n")))]
    summary.input_generation_stable = summary.input_payload_checksum == summary.input_payload_checksum_after_rank and summary.input_count == len(after_rows)
    if not summary.input_generation_stable:
        removed, failed = _clear_final_rank_outputs(ranked_path, top20_path, symbol_rank_dir)
        summary.stale_tmp_files_removed += removed
        summary.stale_tmp_files_failed += failed
        summary.status = "input_changed_during_rank"
        summary.reason = (
            f"l8 input changed while ranking; before_count={summary.input_count}; after_count={len(after_rows)}; "
            f"before_checksum={summary.input_payload_checksum}; after_checksum={summary.input_payload_checksum_after_rank}; final ranked outputs cleared"
        )
        atomic_write_text(manifest_path, _manifest(summary, input_path))
        return summary

    removed, failed = _clear_final_rank_outputs(ranked_path, top20_path, symbol_rank_dir)
    summary.stale_tmp_files_removed += removed
    summary.stale_tmp_files_failed += failed

    ranked_csv = _write_ranked_csv(scored)
    ranked_lines = [line for line in ranked_csv.replace("\r\n", "\n").splitlines() if line.strip()]
    summary.payload_checksum = payload_checksum(ranked_lines)
    summary.status = "complete"
    summary.reason = "ranked all rows present in stable L8 input generation"
    summary.row_count = len(scored)
    summary.ranked_count = sum(1 for row in scored if row["rank_state"] == "ranked")
    summary.ranked_partial_count = sum(1 for row in scored if row["rank_state"] == "ranked_partial")
    summary.ranked_degraded_count = sum(1 for row in scored if row["rank_state"] == "ranked_degraded")
    summary.not_rankable_quality_count = sum(1 for row in scored if row["rank_state"] == "not_rankable_quality")
    summary.elite_count = sum(1 for row in scored if row["movement_bucket"] == "elite_movement_range")
    summary.strong_count = sum(1 for row in scored if row["movement_bucket"] == "strong_movement_range")
    summary.acceptable_count = sum(1 for row in scored if row["movement_bucket"] == "acceptable_movement_range")
    summary.weak_count = sum(1 for row in scored if row["movement_bucket"] == "weak_movement_range")
    summary.poor_count = sum(1 for row in scored if row["movement_bucket"] == "poor_movement_range")

    if summary.source_input_manifest_present and summary.source_input_manifest_row_count != summary.input_count:
        summary.status = "input_degraded"
        summary.reason = f"input CSV row count {summary.input_count} differs from source input manifest row_count {summary.source_input_manifest_row_count}"
    elif summary.source_l5_gate_pass > 0 and summary.source_l5_gate_pass != summary.input_count:
        summary.status = "input_degraded"
        summary.reason = f"input CSV row count {summary.input_count} differs from source l5_gate_pass {summary.source_l5_gate_pass}"

    ranked_ok = atomic_write_text(ranked_path, ranked_csv)
    top20_ok = atomic_write_text(top20_path, _top20_text(scored))
    files_written = 0
    for index, row in enumerate(scored, start=1):
        if atomic_write_text(symbol_rank_dir / _symbol_rank_filename(str(row["symbol"])), _symbol_rank_text(index, row)):
            files_written += 1
    summary.symbol_rank_files_written = files_written
    summary.symbol_rank_files_actual = _final_symbol_rank_txt_count(symbol_rank_dir)

    if not ranked_ok or not top20_ok or files_written != len(scored) or summary.symbol_rank_files_actual != len(scored):
        summary.status = "write_degraded"
        summary.reason = "ranked CSV, top20, or per-symbol rank write failed; sidecar proof may be partial"
    atomic_write_text(manifest_path, _manifest(summary, input_path))
    return summary
