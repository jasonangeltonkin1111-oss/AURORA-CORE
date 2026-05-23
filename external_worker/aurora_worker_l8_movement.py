from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Iterable, List, Tuple
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
L8_MODEL_VERSION = "true_range_v2"
L8_LAYER_NAME = "Layer 8 - Movement / Range Ranking"
L8_OWNER = "Runtime 4 - Surface Scoring Owner"
L8_SOURCE_OWNER = "Runtime_1_Shared_OHLC_Fast_Windows"
L8_REASON_MAX_PARTS = 16
L8_REASON_MAX_CHARS = 640

OUTPUT_FIELDS = [
    "rank_index", "symbol", "layer_id", "layer_name", "l8_model_version", "movement_score", "movement_bucket",
    "rank_state", "score_quality", "movement_regime", "asset_class", "ranking_group", "market_state",
    "quote_quality", "surface_quality", "tick_age_seconds", "spread_bps",
    "range_availability_score", "movement_quality_score", "expansion_compression_score",
    "multi_timeframe_agreement_score", "movement_cleanliness_score", "range_position_quality_score",
    "quote_surface_quality_score", "m5_bars_copied", "m15_bars_copied", "h1_bars_copied", "h4_bars_copied",
    "ohlc_fast_window_checksum", "ohlc_window_files_seen", "ohlc_window_files_missing",
    "m5_window_checksum", "m15_window_checksum", "h1_window_checksum", "h4_window_checksum",
    "m5_range_points_12", "m5_range_points_48", "m5_avg_true_range_12", "m5_avg_true_range_48", "m5_expansion_ratio", "m5_chop_proxy", "m5_spike_ratio", "m5_close_position_pct",
    "m15_range_points_16", "m15_range_points_64", "m15_avg_true_range_16", "m15_avg_true_range_64", "m15_expansion_ratio", "m15_chop_proxy", "m15_spike_ratio", "m15_close_position_pct",
    "h1_range_points_24", "h1_range_points_72", "h1_avg_true_range_24", "h1_avg_true_range_72", "h1_expansion_ratio", "h1_chop_proxy", "h1_spike_ratio", "h1_close_position_pct",
    "h4_range_points_6", "h4_range_points_30", "h4_avg_true_range_6", "h4_avg_true_range_30", "h4_expansion_ratio", "h4_context", "single_bar_spike_risk", "range_position_extreme",
    "reason", "trade_permission", "selection_runtime",
]

BUCKET_ORDER = {
    "poor_movement_range": 0,
    "weak_movement_range": 1,
    "acceptable_movement_range": 2,
    "strong_movement_range": 3,
    "elite_movement_range": 4,
}


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
    stale_final_files_removed: int = 0
    stale_final_files_failed: int = 0
    ohlc_fast_window_payload_checksum: str = "not_available"
    ohlc_window_files_seen: int = 0
    ohlc_window_files_missing: int = 0
    payload_checksum: str = "not_available"
    ranked_csv_path: str = "not_available"
    manifest_path: str = "not_available"
    top20_path: str = "not_available"
    symbol_rank_folder_path: str = "not_available"


def _safe_float(value: str | None, default: float = 0.0) -> float:
    try:
        text = "" if value is None else str(value).strip()
        if text == "" or text.lower() in {"nan", "inf", "-inf", "not_available", "pending", "partial"}:
            return default
        number = float(text)
        return default if math.isnan(number) or math.isinf(number) else number
    except ValueError:
        return default


def _safe_int(value: str | None, default: int = 0) -> int:
    try:
        text = "" if value is None else str(value).strip()
        if text == "" or text.lower() in {"nan", "inf", "-inf", "not_available", "pending", "partial"}:
            return default
        return int(float(text))
    except ValueError:
        return default


def _safe_text(row: Dict[str, str], key: str, default: str = "not_available") -> str:
    value = row.get(key, default)
    return default if value is None or str(value).strip() == "" else str(value).strip()


def _bounded_reason(reason: str) -> str:
    seen = set()
    parts: List[str] = []
    for raw in str(reason or "").replace("\r", " ").replace("\n", " ").split(";"):
        part = raw.strip()
        if not part or part in seen:
            continue
        seen.add(part)
        parts.append(part)
        if len(parts) >= L8_REASON_MAX_PARTS:
            break
    text = ";".join(parts) if parts else "not_available"
    if len(text) > L8_REASON_MAX_CHARS:
        text = text[: max(0, L8_REASON_MAX_CHARS - 18)].rstrip("; ") + ";reason_truncated"
    return text


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
        safe = safe.replace(ch, "_")
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
    removed = failed = 0
    if not folder.exists():
        return removed, failed
    for path in folder.glob(pattern):
        r, f = _remove_file_if_exists(path)
        removed += r
        failed += f
    return removed, failed


def _clear_layer_transient_files(layer_dir: Path) -> Tuple[int, int]:
    removed = failed = 0
    for pattern in ("*.tmp", "*.write_failed.txt"):
        r, f = _cleanup_glob(layer_dir, pattern)
        removed += r
        failed += f
    return removed, failed


def _cleanup_symbol_rank_tmp(symbol_rank_dir: Path) -> Tuple[int, int]:
    removed = failed = 0
    for pattern in ("*.tmp", "*.write_failed.txt"):
        r, f = _cleanup_glob(symbol_rank_dir, pattern)
        removed += r
        failed += f
    return removed, failed


def _final_symbol_rank_txt_count(symbol_rank_dir: Path) -> int:
    if not symbol_rank_dir.exists():
        return 0
    return sum(1 for p in symbol_rank_dir.glob("*.txt") if p.is_file())


def _delete_stale_symbol_rank_files(symbol_rank_dir: Path, expected_names: Iterable[str]) -> Tuple[int, int]:
    expected = set(expected_names)
    removed = failed = 0
    if not symbol_rank_dir.exists():
        return removed, failed
    for path in symbol_rank_dir.glob("*.txt"):
        if path.name in expected:
            continue
        r, f = _remove_file_if_exists(path)
        removed += r
        failed += f
    return removed, failed


def _csv_payload_checksum(text: str) -> str:
    rows = [line for line in text.replace("\r\n", "\n").splitlines() if line.strip()]
    return payload_checksum(rows)


def _format_value(value: str | float | int | bool) -> str:
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, float):
        return f"{value:.6f}"
    return str(value).replace("\r", " ").replace("\n", " ").replace(",", "_")


def _shared_ohlc_fast_window_root(outbox: Path) -> Path:
    account_root = outbox.parents[2]
    server_root = account_root.parent
    return server_root / "Shared Market Data" / "OHLC Store" / "Fast Windows"


def _file_payload_checksum(path: Path) -> str:
    if not path.exists():
        return "missing"
    rows = [line for line in read_text(path).replace("\r\n", "\n").splitlines() if line.strip()]
    return payload_checksum(rows)


def _ohlc_window_checksum_packet(symbol_dir: Path) -> Dict[str, str | int]:
    checksums: Dict[str, str | int] = {}
    seen = 0
    missing = 0
    aggregate_parts: List[str] = []
    for tf in ("M5", "M15", "H1", "H4"):
        path = symbol_dir / f"{tf}.window.csv"
        checksum = _file_payload_checksum(path)
        checksums[f"{tf.lower()}_window_checksum"] = checksum
        aggregate_parts.append(f"{tf}={checksum}")
        if checksum == "missing":
            missing += 1
        else:
            seen += 1
    checksums["ohlc_window_files_seen"] = seen
    checksums["ohlc_window_files_missing"] = missing
    checksums["ohlc_fast_window_checksum"] = payload_checksum(aggregate_parts)
    return checksums


def _read_ohlc_window(path: Path) -> List[Dict[str, int]]:
    if not path.exists():
        return []
    rows: List[Dict[str, int]] = []
    for raw in read_text(path).replace("\r\n", "\n").splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or line.startswith("bar_time"):
            continue
        parts = [p.strip() for p in line.split(",")]
        if len(parts) < 8:
            continue
        try:
            rows.append({
                "bar_time": int(float(parts[0])),
                "open_i": int(float(parts[1])),
                "high_i": int(float(parts[2])),
                "low_i": int(float(parts[3])),
                "close_i": int(float(parts[4])),
                "tick_volume": int(float(parts[5])),
                "spread": int(float(parts[6])),
                "real_volume": int(float(parts[7])),
            })
        except ValueError:
            continue
    rows.sort(key=lambda row: row["bar_time"], reverse=True)
    return rows


def _range_points(rows: List[Dict[str, int]], count: int) -> float:
    subset = rows[:count]
    if not subset:
        return 0.0
    return float(max(r["high_i"] for r in subset) - min(r["low_i"] for r in subset))


def _true_ranges(rows: List[Dict[str, int]], count: int) -> List[float]:
    subset = rows[:count]
    values: List[float] = []
    for index, row in enumerate(subset):
        high_low = max(0, row["high_i"] - row["low_i"])
        if index + 1 < len(rows):
            previous_close = rows[index + 1]["close_i"]
            tr = max(high_low, abs(row["high_i"] - previous_close), abs(row["low_i"] - previous_close))
        else:
            tr = high_low
        values.append(float(max(0, tr)))
    return values


def _avg_true_range(rows: List[Dict[str, int]], count: int) -> float:
    values = _true_ranges(rows, count)
    if not values:
        return 0.0
    return sum(values) / float(len(values))


def _sum_true_range(rows: List[Dict[str, int]], count: int) -> float:
    return float(sum(_true_ranges(rows, count)))


def _largest_true_range(rows: List[Dict[str, int]], count: int) -> float:
    values = _true_ranges(rows, count)
    if not values:
        return 0.0
    return float(max(values))


def _position_pct(rows: List[Dict[str, int]], count: int) -> float:
    subset = rows[:count]
    if not subset:
        return 50.0
    high = max(r["high_i"] for r in subset)
    low = min(r["low_i"] for r in subset)
    if high <= low:
        return 50.0
    close = subset[0]["close_i"]
    return max(0.0, min(100.0, ((close - low) / float(high - low)) * 100.0))


def _tf_metrics(rows: List[Dict[str, int]], recent: int, baseline: int) -> Dict[str, float | int]:
    copied = len(rows)
    recent_avail = min(copied, recent)
    baseline_avail = min(copied, baseline)
    recent_range = _range_points(rows, recent_avail)
    baseline_range = _range_points(rows, baseline_avail)
    recent_true = _avg_true_range(rows, recent_avail)
    baseline_true = _avg_true_range(rows, baseline_avail)
    expansion = recent_true / baseline_true if baseline_true > 0.0 else 0.0
    chop = _sum_true_range(rows, baseline_avail) / baseline_range if baseline_range > 0.0 else 0.0
    spike = _largest_true_range(rows, baseline_avail) / baseline_true if baseline_true > 0.0 else 0.0
    return {
        "bars_copied": copied,
        "range_recent": recent_range,
        "range_baseline": baseline_range,
        "avg_true_recent": recent_true,
        "avg_true_baseline": baseline_true,
        "expansion_ratio": expansion,
        "chop_proxy": chop,
        "spike_ratio": spike,
        "close_position_pct": _position_pct(rows, baseline_avail),
    }


def _score_availability(m5: int, m15: int, h1: int, h4: int) -> Tuple[float, str, str]:
    score = 0.0
    parts: List[str] = []
    for label, copied, target, weight in (("m5", m5, 48, 30), ("m15", m15, 64, 30), ("h1", h1, 72, 30), ("h4", h4, 30, 10)):
        ratio = min(1.0, copied / float(target)) if target > 0 else 0.0
        score += ratio * weight
        parts.append(f"{label}_bars={copied}_of_{target}")
    if m5 >= 48 and m15 >= 64 and h1 >= 72:
        return score, "rankable", ";".join(parts + ["ohlc_minimum_ready"])
    if m5 > 0 or m15 > 0 or h1 > 0:
        return score, "degraded", ";".join(parts + ["ohlc_minimum_not_ready"])
    return 0.0, "missing", ";".join(parts + ["ohlc_missing_core_windows"])


def _expansion_score(ratio: float) -> Tuple[float, str]:
    if ratio <= 0.0:
        return 0.0, "missing_true_range_expansion"
    if ratio < 0.55:
        return 22.0, "compressed_dead_true_range"
    if ratio < 0.75:
        return 40.0, "weak_compression_true_range"
    if ratio <= 1.05:
        return 62.0, "neutral_true_range_movement"
    if ratio <= 1.80:
        return 92.0, "usable_true_range_expansion"
    if ratio <= 3.00:
        return 72.0, "hot_true_range_expansion_review"
    return 35.0, "violent_true_range_spike_risk"


def _quote_surface_score(quote_quality: str, surface_quality: str, spread_bps: float, tick_age: float) -> Tuple[float, str]:
    score = 90.0
    reasons: List[str] = []
    lower = f"{quote_quality} {surface_quality}".lower()
    if any(x in lower for x in ("missing", "stale", "invalid")):
        score -= 55.0
        reasons.append("quote_or_surface_severe")
    elif any(x in lower for x in ("aging", "warning", "partial")):
        score -= 25.0
        reasons.append("quote_or_surface_warning")
    else:
        reasons.append("quote_surface_usable")
    if tick_age > 60:
        score -= 30.0
        reasons.append("tick_age_gt_60s")
    elif tick_age > 20:
        score -= 18.0
        reasons.append("tick_age_gt_20s")
    elif tick_age > 5:
        score -= 8.0
        reasons.append("tick_age_gt_5s")
    if spread_bps >= 100:
        score -= 35.0
        reasons.append("spread_bps_ge_100")
    elif spread_bps >= 50:
        score -= 25.0
        reasons.append("spread_bps_ge_50")
    elif spread_bps >= 20:
        score -= 12.0
        reasons.append("spread_bps_ge_20")
    return max(0.0, min(100.0, score)), ";".join(reasons)


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


def _score_row(row: Dict[str, str], fast_root: Path) -> Dict[str, str | float | int | bool]:
    symbol = _safe_text(row, "symbol")
    symbol_dir = fast_root / _sanitize_path_part(symbol)
    checksums = _ohlc_window_checksum_packet(symbol_dir)
    m5 = _tf_metrics(_read_ohlc_window(symbol_dir / "M5.window.csv"), 12, 48)
    m15 = _tf_metrics(_read_ohlc_window(symbol_dir / "M15.window.csv"), 16, 64)
    h1 = _tf_metrics(_read_ohlc_window(symbol_dir / "H1.window.csv"), 24, 72)
    h4 = _tf_metrics(_read_ohlc_window(symbol_dir / "H4.window.csv"), 6, 30)

    market_state = _safe_text(row, "market_state")
    quote_quality = _safe_text(row, "quote_quality")
    surface_quality = _safe_text(row, "surface_quality")
    spread_bps = _safe_float(row.get("spread_bps"))
    tick_age = _safe_float(row.get("tick_age_seconds"))

    availability_score, availability_state, availability_reason = _score_availability(int(m5["bars_copied"]), int(m15["bars_copied"]), int(h1["bars_copied"]), int(h4["bars_copied"]))
    exp_scores = [_expansion_score(float(m5["expansion_ratio"])), _expansion_score(float(m15["expansion_ratio"])), _expansion_score(float(h1["expansion_ratio"]))]
    expansion_score = sum(score for score, _reason in exp_scores) / 3.0
    expansion_reasons = ";".join(reason for _score, reason in exp_scores)

    movement_presence = min(100.0, ((float(m5["avg_true_baseline"]) > 0) * 28.0) + ((float(m15["avg_true_baseline"]) > 0) * 32.0) + ((float(h1["avg_true_baseline"]) > 0) * 32.0) + ((float(h4["avg_true_baseline"]) > 0) * 8.0))
    agreement_values = [float(m5["expansion_ratio"]), float(m15["expansion_ratio"]), float(h1["expansion_ratio"])]
    expanding = sum(1 for x in agreement_values if x >= 1.05)
    compressed = sum(1 for x in agreement_values if 0 < x < 0.75)
    violent = sum(1 for x in agreement_values if x > 3.0)
    agreement_score = max(0.0, min(100.0, 80.0 + expanding * 6.0 - compressed * 18.0 - violent * 30.0))

    avg_chop = (float(m5["chop_proxy"]) + float(m15["chop_proxy"]) + float(h1["chop_proxy"])) / 3.0
    cleanliness_score = max(0.0, min(100.0, 100.0 - max(0.0, avg_chop - 1.0) * 18.0))
    positions = [float(m5["close_position_pct"]), float(m15["close_position_pct"]), float(h1["close_position_pct"])]
    extreme_count = sum(1 for x in positions if x < 5.0 or x > 95.0)
    edge_count = sum(1 for x in positions if 5.0 <= x < 20.0 or 80.0 < x <= 95.0)
    range_position_score = max(0.0, 90.0 - extreme_count * 35.0 - edge_count * 12.0)
    quote_score, quote_reason = _quote_surface_score(quote_quality, surface_quality, spread_bps, tick_age)
    spike_risk = any(float(tf["spike_ratio"]) > 4.0 for tf in (m5, m15, h1)) or violent > 0

    movement_score = max(0.0, min(100.0, availability_score * 0.20 + movement_presence * 0.20 + expansion_score * 0.25 + agreement_score * 0.15 + cleanliness_score * 0.10 + range_position_score * 0.05 + quote_score * 0.05))

    rank_state = "ranked"
    score_quality = "usable_true_range_movement_range_model"
    if availability_state == "missing":
        rank_state = "not_rankable_quality"
        score_quality = "not_rankable_ohlc_fast_windows_missing"
    elif availability_state == "degraded":
        rank_state = "ranked_degraded"
        score_quality = "degraded_ohlc_fast_windows_partial"
    elif int(h4["bars_copied"]) < 30:
        rank_state = "ranked_partial"
        score_quality = "usable_core_windows_h4_context_partial"
    if market_state != "open":
        rank_state = "not_rankable_quality"
        score_quality = "not_rankable_market_not_open"
    elif spike_risk and rank_state == "ranked":
        rank_state = "ranked_degraded"
        score_quality = "degraded_single_bar_true_range_spike_or_violent_expansion_risk"
    elif quote_score < 45 and rank_state == "ranked":
        rank_state = "ranked_degraded"
        score_quality = "degraded_quote_surface_quality"

    if spike_risk:
        regime = "violent_spike_risk"
    elif avg_chop > 4.0:
        regime = "choppy_range"
    elif compressed >= 2:
        regime = "compressed"
    elif expanding >= 2:
        regime = "clean_expansion"
    else:
        regime = "normal"
    h4_context = "unavailable" if int(h4["bars_copied"]) <= 0 else ("confirms" if float(h4["expansion_ratio"]) >= 1.05 else ("contradicts_short_term" if expanding >= 2 and float(h4["expansion_ratio"]) < 0.75 else "neutral"))

    reasons = ["ok_L5Pass", availability_reason, expansion_reasons, quote_reason, f"regime={regime}", f"model={L8_MODEL_VERSION}", f"source={L8_SOURCE_OWNER}", "ranking_only_no_direction_no_entry"]
    if spike_risk:
        reasons.append("single_bar_true_range_spike_or_violent_expansion_risk")
    if extreme_count > 0:
        reasons.append("range_position_extreme")
    if avg_chop > 4.0:
        reasons.append("true_range_chop_proxy_high")

    return {
        "symbol": symbol, "l8_model_version": L8_MODEL_VERSION, "movement_score": movement_score, "movement_bucket": _bucket_from_score(movement_score), "rank_state": rank_state, "score_quality": score_quality, "movement_regime": regime,
        "asset_class": _safe_text(row, "asset_class"), "ranking_group": _safe_text(row, "ranking_group"), "market_state": market_state, "quote_quality": quote_quality, "surface_quality": surface_quality,
        "tick_age_seconds": tick_age, "spread_bps": spread_bps, "range_availability_score": availability_score, "movement_quality_score": movement_presence, "expansion_compression_score": expansion_score,
        "multi_timeframe_agreement_score": agreement_score, "movement_cleanliness_score": cleanliness_score, "range_position_quality_score": range_position_score, "quote_surface_quality_score": quote_score,
        "m5_bars_copied": int(m5["bars_copied"]), "m15_bars_copied": int(m15["bars_copied"]), "h1_bars_copied": int(h1["bars_copied"]), "h4_bars_copied": int(h4["bars_copied"]),
        "ohlc_fast_window_checksum": checksums["ohlc_fast_window_checksum"], "ohlc_window_files_seen": int(checksums["ohlc_window_files_seen"]), "ohlc_window_files_missing": int(checksums["ohlc_window_files_missing"]),
        "m5_window_checksum": checksums["m5_window_checksum"], "m15_window_checksum": checksums["m15_window_checksum"], "h1_window_checksum": checksums["h1_window_checksum"], "h4_window_checksum": checksums["h4_window_checksum"],
        "m5_range_points_12": float(m5["range_recent"]), "m5_range_points_48": float(m5["range_baseline"]), "m5_avg_true_range_12": float(m5["avg_true_recent"]), "m5_avg_true_range_48": float(m5["avg_true_baseline"]), "m5_expansion_ratio": float(m5["expansion_ratio"]), "m5_chop_proxy": float(m5["chop_proxy"]), "m5_spike_ratio": float(m5["spike_ratio"]), "m5_close_position_pct": float(m5["close_position_pct"]),
        "m15_range_points_16": float(m15["range_recent"]), "m15_range_points_64": float(m15["range_baseline"]), "m15_avg_true_range_16": float(m15["avg_true_recent"]), "m15_avg_true_range_64": float(m15["avg_true_baseline"]), "m15_expansion_ratio": float(m15["expansion_ratio"]), "m15_chop_proxy": float(m15["chop_proxy"]), "m15_spike_ratio": float(m15["spike_ratio"]), "m15_close_position_pct": float(m15["close_position_pct"]),
        "h1_range_points_24": float(h1["range_recent"]), "h1_range_points_72": float(h1["range_baseline"]), "h1_avg_true_range_24": float(h1["avg_true_recent"]), "h1_avg_true_range_72": float(h1["avg_true_baseline"]), "h1_expansion_ratio": float(h1["expansion_ratio"]), "h1_chop_proxy": float(h1["chop_proxy"]), "h1_spike_ratio": float(h1["spike_ratio"]), "h1_close_position_pct": float(h1["close_position_pct"]),
        "h4_range_points_6": float(h4["range_recent"]), "h4_range_points_30": float(h4["range_baseline"]), "h4_avg_true_range_6": float(h4["avg_true_recent"]), "h4_avg_true_range_30": float(h4["avg_true_baseline"]), "h4_expansion_ratio": float(h4["expansion_ratio"]), "h4_context": h4_context,
        "single_bar_spike_risk": spike_risk, "range_position_extreme": extreme_count > 0, "reason": _bounded_reason(";".join(reasons)), "trade_permission": "false", "selection_runtime": "false",
    }


def _write_ranked_csv(scored: List[Dict[str, str | float | int | bool]]) -> str:
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


def _top20_text(scored: List[Dict[str, str | float | int | bool]]) -> str:
    lines = ["LAYER 8 - MOVEMENT / RANGE RANKING - TOP 20", "----------------------------------------", f"Generated UTC: {utc_stamp()}", "Trade Permission: FALSE", "Selection Runtime: FALSE", f"Model Version: {L8_MODEL_VERSION}", "Policy: Movement/range ranking only; no direction, entry, selection, or permission.", "Source: Runtime 1 Shared OHLC Fast Windows + L8 symbol metadata", "", "rank|symbol|score|bucket|state|regime|ohlc_checksum|reason"]
    for index, row in enumerate(scored[:20], start=1):
        lines.append(f"{index}|{row['symbol']}|{float(row['movement_score']):.2f}|{row['movement_bucket']}|{row['rank_state']}|{row['movement_regime']}|{row['ohlc_fast_window_checksum']}|{_bounded_reason(str(row['reason']))}")
    lines.append("")
    return "\n".join(lines)


def _symbol_rank_text(rank_index: int, row: Dict[str, str | float | int | bool]) -> str:
    symbol = str(row["symbol"])
    lines = ["schema_name=l8_symbol_rank", "schema_version=3", "layer_id=8", f"layer_name={L8_LAYER_NAME}", f"owner_name={L8_OWNER}", f"job_type={L8_JOB_TYPE}", f"l8_model_version={L8_MODEL_VERSION}", f"rank_index={rank_index}", f"symbol={symbol}", f"symbol_rank_filename_mode={L8_SYMBOL_RANK_FILENAME_MODE}", f"symbol_rank_filename={_symbol_rank_filename(symbol)}", f"symbol_rank_checksum={_symbol_checksum(symbol)}"]
    for key in OUTPUT_FIELDS:
        if key in {"rank_index", "symbol", "layer_id", "layer_name"}:
            continue
        if key in row:
            lines.append(f"{key}={_format_value(row[key])}")
    lines += ["authority=calculation_support_only", "trade_permission=false", "selection_runtime=false", f"source_owner={L8_SOURCE_OWNER}", "true_range_policy=uses_max_high_low_abs_high_prev_close_abs_low_prev_close", f"generated_utc={utc_stamp()}", f"generated_unix={unix_time()}", ""]
    return "\n".join(lines)


def _manifest(summary: L8RankSummary, input_path: Path, fast_root: Path) -> str:
    summary.reason = _bounded_reason(summary.reason)
    source_counts_ok = summary.source_input_manifest_present and summary.input_count == summary.source_input_manifest_row_count
    source_l5_ok = summary.source_l5_gate_pass <= 0 or summary.input_count == summary.source_l5_gate_pass
    input_manifest_checksum_ok = summary.source_input_payload_checksum in {"not_available", ""} or summary.source_input_payload_checksum == summary.input_payload_checksum
    symbol_files_ok = summary.symbol_rank_files_written == summary.row_count and summary.symbol_rank_files_actual == summary.row_count
    return "\n".join([
        "schema_name=layer_ranked_symbols_manifest", "schema_version=3", "layer_id=8", f"layer_name={L8_LAYER_NAME}", f"owner_name={L8_OWNER}", f"job_type={L8_JOB_TYPE}", f"l8_model_version={L8_MODEL_VERSION}", f"status={summary.status}", f"reason={summary.reason}",
        f"input_csv_path={input_path}", f"shared_ohlc_fast_window_root={fast_root}", f"source_input_manifest_present={'true' if summary.source_input_manifest_present else 'false'}", f"source_input_manifest_row_count={summary.source_input_manifest_row_count}", f"source_l5_gate_pass={summary.source_l5_gate_pass}",
        f"source_input_payload_checksum={summary.source_input_payload_checksum}", f"input_payload_checksum={summary.input_payload_checksum}", f"input_payload_checksum_after_rank={summary.input_payload_checksum_after_rank}", f"input_generation_stable={'true' if summary.input_generation_stable else 'false'}",
        f"input_payload_checksum_matches_source_manifest={'true' if input_manifest_checksum_ok else 'false'}", f"input_csv_count_matches_input_manifest={'true' if source_counts_ok else 'false'}", f"input_csv_count_matches_source_l5_gate_pass={'true' if source_l5_ok else 'false'}",
        f"ohlc_fast_window_payload_checksum={summary.ohlc_fast_window_payload_checksum}", f"ohlc_window_files_seen={summary.ohlc_window_files_seen}", f"ohlc_window_files_missing={summary.ohlc_window_files_missing}",
        f"ranked_csv_path={summary.ranked_csv_path}", f"ranked_manifest_path={summary.manifest_path}", f"top20_path={summary.top20_path}", f"symbol_rank_folder_path={summary.symbol_rank_folder_path}", f"symbol_rank_filename_mode={summary.symbol_rank_filename_mode}",
        f"symbol_rank_files_written={summary.symbol_rank_files_written}", f"symbol_rank_files_actual={summary.symbol_rank_files_actual}", f"symbol_rank_file_count_ok={'true' if symbol_files_ok else 'false'}", f"stale_tmp_files_removed={summary.stale_tmp_files_removed}", f"stale_tmp_files_failed={summary.stale_tmp_files_failed}", f"stale_final_files_removed={summary.stale_final_files_removed}", f"stale_final_files_failed={summary.stale_final_files_failed}",
        f"input_count={summary.input_count}", f"row_count={summary.row_count}", f"ranked_count={summary.ranked_count}", f"ranked_partial_count={summary.ranked_partial_count}", f"ranked_degraded_count={summary.ranked_degraded_count}", f"not_rankable_quality_count={summary.not_rankable_quality_count}", f"elite_movement_range_count={summary.elite_count}", f"strong_movement_range_count={summary.strong_count}", f"acceptable_movement_range_count={summary.acceptable_count}", f"weak_movement_range_count={summary.weak_count}", f"poor_movement_range_count={summary.poor_count}",
        f"payload_checksum={summary.payload_checksum}", "authority=calculation_support_only", "trade_permission=false", "ranking_runtime=true", "selection_runtime=false", "publication_order=recompute_from_current_ohlc_windows_write_outputs_then_manifest_last", "movement_range_policy=ranking_only_no_direction_no_entry_no_selection_no_execution", f"source_owner={L8_SOURCE_OWNER}", "true_range_policy=uses_max_high_low_abs_high_prev_close_abs_low_prev_close", "reuse_policy=disabled_until_ohlc_window_checksum_exists", f"reason_max_parts={L8_REASON_MAX_PARTS}", f"reason_max_chars={L8_REASON_MAX_CHARS}", f"generated_utc={utc_stamp()}", f"generated_unix={unix_time()}", "",
    ])


def publish_l8_movement_range_rankings(outbox: Path) -> L8RankSummary:
    layer_dir = outbox / "Layers" / L8_LAYER_FOLDER
    input_path = layer_dir / L8_INPUT_NAME
    input_manifest_path = layer_dir / L8_INPUT_MANIFEST_NAME
    ranked_path = layer_dir / L8_RANKED_NAME
    manifest_path = layer_dir / L8_MANIFEST_NAME
    top20_path = layer_dir / L8_TOP20_NAME
    symbol_rank_dir = layer_dir / L8_SYMBOL_RANK_FOLDER
    fast_root = _shared_ohlc_fast_window_root(outbox)
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
    sr_removed, sr_failed = _cleanup_symbol_rank_tmp(symbol_rank_dir)
    summary.stale_tmp_files_removed += removed + sr_removed
    summary.stale_tmp_files_failed += failed + sr_failed

    if not input_path.exists():
        atomic_write_text(manifest_path, _manifest(summary, input_path, fast_root))
        return summary

    text = read_text(input_path)
    summary.input_payload_checksum = _csv_payload_checksum(text)
    rows = [row for row in csv.DictReader(io.StringIO(text.replace("\r\n", "\n")))]
    summary.input_count = len(rows)
    scored = [_score_row(row, fast_root) for row in rows]
    scored.sort(key=lambda row: (BUCKET_ORDER.get(str(row["movement_bucket"]), 0), float(row["movement_score"]), float(row["expansion_compression_score"]), float(row["multi_timeframe_agreement_score"]), str(row["symbol"])), reverse=True)

    text_after_rank = read_text(input_path)
    summary.input_payload_checksum_after_rank = _csv_payload_checksum(text_after_rank)
    after_rows = [row for row in csv.DictReader(io.StringIO(text_after_rank.replace("\r\n", "\n")))]
    summary.input_generation_stable = summary.input_payload_checksum == summary.input_payload_checksum_after_rank and summary.input_count == len(after_rows)
    if not summary.input_generation_stable:
        summary.status = "input_changed_during_rank"
        summary.reason = f"l8 input changed while ranking; before_count={summary.input_count}; after_count={len(after_rows)}; before_checksum={summary.input_payload_checksum}; after_checksum={summary.input_payload_checksum_after_rank}; ranked outputs intentionally not refreshed"
        atomic_write_text(manifest_path, _manifest(summary, input_path, fast_root))
        return summary

    summary.ohlc_fast_window_payload_checksum = payload_checksum([str(row["symbol"]) + "=" + str(row["ohlc_fast_window_checksum"]) for row in scored])
    summary.ohlc_window_files_seen = sum(int(row["ohlc_window_files_seen"]) for row in scored)
    summary.ohlc_window_files_missing = sum(int(row["ohlc_window_files_missing"]) for row in scored)

    ranked_csv = _write_ranked_csv(scored)
    ranked_lines = [line for line in ranked_csv.replace("\r\n", "\n").splitlines() if line.strip()]
    summary.payload_checksum = payload_checksum(ranked_lines)
    summary.status = "complete"
    summary.reason = "recomputed true-range model rows from stable L8 symbol metadata and current Runtime 1 shared OHLC fast windows"
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
    if summary.ohlc_window_files_missing > 0 and summary.status == "complete":
        summary.status = "input_degraded"
        summary.reason = f"OHLC fast-window files missing for L8 calculation; missing={summary.ohlc_window_files_missing}; seen={summary.ohlc_window_files_seen}"

    ranked_ok = atomic_write_text(ranked_path, ranked_csv)
    top20_ok = atomic_write_text(top20_path, _top20_text(scored))
    expected_names = [_symbol_rank_filename(str(row["symbol"])) for row in scored]
    files_written = 0
    for index, row in enumerate(scored, start=1):
        if atomic_write_text(symbol_rank_dir / _symbol_rank_filename(str(row["symbol"])), _symbol_rank_text(index, row)):
            files_written += 1
    stale_removed, stale_failed = _delete_stale_symbol_rank_files(symbol_rank_dir, expected_names)
    summary.stale_final_files_removed += stale_removed
    summary.stale_final_files_failed += stale_failed
    summary.symbol_rank_files_written = files_written
    summary.symbol_rank_files_actual = _final_symbol_rank_txt_count(symbol_rank_dir)

    if not ranked_ok or not top20_ok or files_written != len(scored) or summary.symbol_rank_files_actual != len(scored):
        summary.status = "write_degraded"
        summary.reason = "ranked CSV, top20, or per-symbol rank write failed; sidecar proof may be partial"
    atomic_write_text(manifest_path, _manifest(summary, input_path, fast_root))
    return summary
