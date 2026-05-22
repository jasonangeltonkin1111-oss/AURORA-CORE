from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Iterable, List, Tuple
import csv
import io
import math

from aurora_worker_io import atomic_write_text, payload_checksum, read_text, unix_time, utc_stamp

L7_LAYER_FOLDER = "Layer_7_Session_Relevance_Ranking"
L7_INPUT_NAME = "l7_input_primitives.csv"
L7_INPUT_MANIFEST_NAME = "l7_input_primitives.manifest"
L7_RANKED_NAME = "ranked_symbols.csv"
L7_MANIFEST_NAME = "ranked_symbols.manifest"
L7_TOP20_NAME = "ranked_symbols_top20.txt"
L7_SYMBOL_RANK_FOLDER = "SymbolRanks"
L7_SYMBOL_RANK_FILENAME_MODE = "sanitized_symbol__payload_checksum"
L7_JOB_TYPE = "L7_SESSION_RELEVANCE_RANKING_V1"
L7_LAYER_NAME = "Layer 7 - Session Relevance Ranking"
L7_OWNER = "Runtime 4 - Surface Scoring Owner"
OFF_SESSION_DEAD_TIME = "Off_Session_Dead_Time"

SESSION_BUCKET_ORDER = {
    "poor_session_relevance": 0,
    "weak_session_relevance": 1,
    "acceptable_session_relevance": 2,
    "strong_session_relevance": 3,
    "elite_session_relevance": 4,
}

OUTPUT_FIELDS = [
    "rank_index", "symbol", "layer_id", "layer_name", "session_score", "session_bucket",
    "rank_state", "score_quality", "current_session", "session_definition_source", "session_time_basis",
    "time_basis_confidence", "symbol_session_fit_score", "live_activity_quality_score",
    "quote_freshness_quality_score", "spread_session_safety_score", "asset_class", "ranking_group",
    "market_state", "quote_quality", "surface_quality", "tick_age_seconds", "spread_bps",
    "daily_change_pct", "zero_spread_state", "reason", "trade_permission", "selection_runtime",
]


@dataclass
class L7RankSummary:
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
    ranked_degraded_count: int = 0
    not_rankable_quality_count: int = 0
    elite_count: int = 0
    strong_count: int = 0
    acceptable_count: int = 0
    weak_count: int = 0
    poor_count: int = 0
    symbol_rank_files_written: int = 0
    symbol_rank_files_actual: int = 0
    symbol_rank_filename_mode: str = L7_SYMBOL_RANK_FILENAME_MODE
    stale_tmp_files_removed: int = 0
    stale_tmp_files_failed: int = 0
    stale_final_files_removed: int = 0
    stale_final_files_failed: int = 0
    payload_checksum: str = "not_available"
    ranked_csv_path: str = "not_available"
    manifest_path: str = "not_available"
    top20_path: str = "not_available"
    symbol_rank_folder_path: str = "not_available"


def _safe_float(value: str | None, default: float = 0.0) -> float:
    try:
        if value is None:
            return default
        text = str(value).strip()
        if text == "" or text.lower() in {"nan", "inf", "-inf", "not_available", "pending"}:
            return default
        number = float(text)
        return default if math.isnan(number) or math.isinf(number) else number
    except ValueError:
        return default


def _safe_int(value: str | None, default: int = 0) -> int:
    try:
        if value is None:
            return default
        text = str(value).strip()
        if text == "" or text.lower() in {"nan", "inf", "-inf", "not_available", "pending"}:
            return default
        return int(float(text))
    except ValueError:
        return default


def _safe_text(row: Dict[str, str], key: str, default: str = "not_available") -> str:
    value = row.get(key, default)
    return default if value is None or str(value).strip() == "" else str(value).strip()


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


def _session_from_seconds(seconds: int) -> str:
    # Static Gateway profile v1. Descriptive context only: not broker-open truth and not edge proof.
    if 0 <= seconds < 7 * 3600:
        return "Asia"
    if 7 * 3600 <= seconds < 12 * 3600:
        return "London"
    if 12 * 3600 <= seconds < 16 * 3600:
        return "London_NewYork_Overlap"
    if 16 * 3600 <= seconds < 21 * 3600:
        return "NewYork"
    if 21 * 3600 <= seconds < 24 * 3600:
        return OFF_SESSION_DEAD_TIME
    return "Unknown"


def _symbol_family(symbol: str, asset_class: str, ranking_group: str) -> str:
    s = symbol.upper()
    ac = asset_class.lower()
    rg = ranking_group.lower()
    if "CRYPTO" in s or "crypto" in ac or "crypto" in rg:
        return "crypto"
    if "XAU" in s or "GOLD" in s:
        return "gold"
    if "OIL" in s or "BRENT" in s or "WTI" in s:
        return "oil"
    if "index" in ac or "index" in rg or "indices" in ac:
        if any(token in s for token in ["US", "NAS", "SP", "DOW", "DJ", "NQ"]):
            return "us_indices"
        if any(token in s for token in ["DE", "DAX", "UK", "FTSE", "EU", "FR", "CAC"]):
            return "eu_uk_indices"
        return "indices"
    if "forex" in ac or "fx" in rg or len(s) >= 6:
        if any(ccy in s for ccy in ["AUD", "NZD"]):
            return "aud_nzd_fx"
        if "JPY" in s:
            return "jpy_fx"
        if any(ccy in s for ccy in ["EUR", "GBP"]):
            return "eur_gbp_fx"
        if any(pair in s for pair in ["USD", "CAD", "CHF"]):
            return "fx_major"
    return "unknown"


SESSION_FIT = {
    "fx_major": {"Asia": 55, "London": 85, "NewYork": 80, "London_NewYork_Overlap": 95, OFF_SESSION_DEAD_TIME: 5, "Unknown": 25},
    "eur_gbp_fx": {"Asia": 40, "London": 90, "NewYork": 75, "London_NewYork_Overlap": 95, OFF_SESSION_DEAD_TIME: 5, "Unknown": 25},
    "jpy_fx": {"Asia": 80, "London": 65, "NewYork": 60, "London_NewYork_Overlap": 70, OFF_SESSION_DEAD_TIME: 5, "Unknown": 25},
    "aud_nzd_fx": {"Asia": 85, "London": 55, "NewYork": 45, "London_NewYork_Overlap": 60, OFF_SESSION_DEAD_TIME: 5, "Unknown": 25},
    "gold": {"Asia": 45, "London": 80, "NewYork": 85, "London_NewYork_Overlap": 95, OFF_SESSION_DEAD_TIME: 5, "Unknown": 30},
    "us_indices": {"Asia": 20, "London": 50, "NewYork": 90, "London_NewYork_Overlap": 85, OFF_SESSION_DEAD_TIME: 5, "Unknown": 25},
    "eu_uk_indices": {"Asia": 20, "London": 90, "NewYork": 55, "London_NewYork_Overlap": 80, OFF_SESSION_DEAD_TIME: 5, "Unknown": 25},
    "indices": {"Asia": 30, "London": 70, "NewYork": 75, "London_NewYork_Overlap": 80, OFF_SESSION_DEAD_TIME: 5, "Unknown": 25},
    "oil": {"Asia": 35, "London": 70, "NewYork": 85, "London_NewYork_Overlap": 85, OFF_SESSION_DEAD_TIME: 5, "Unknown": 25},
    "crypto": {"Asia": 55, "London": 55, "NewYork": 55, "London_NewYork_Overlap": 55, OFF_SESSION_DEAD_TIME: 20, "Unknown": 35},
    "unknown": {"Asia": 35, "London": 35, "NewYork": 35, "London_NewYork_Overlap": 35, OFF_SESSION_DEAD_TIME: 5, "Unknown": 20},
}


def _quality_score(text: str, good_words: Tuple[str, ...], warning_words: Tuple[str, ...], severe_words: Tuple[str, ...]) -> Tuple[float, str]:
    lower = text.lower()
    if any(word in lower for word in severe_words):
        return 15.0, f"severe_{text}"
    if any(word in lower for word in warning_words):
        return 55.0, f"warning_{text}"
    if any(word in lower for word in good_words):
        return 90.0, f"ok_{text}"
    if text in {"not_available", "missing", "pending"}:
        return 30.0, f"unknown_{text}"
    return 60.0, f"review_{text}"


def _spread_safety_score(spread_bps: float) -> Tuple[float, str]:
    if spread_bps >= 100.0:
        return 5.0, "spread_bps_ge_100"
    if spread_bps >= 50.0:
        return 20.0, "spread_bps_ge_50"
    if spread_bps >= 20.0:
        return 40.0, "spread_bps_ge_20"
    if spread_bps >= 10.0:
        return 60.0, "spread_bps_ge_10"
    if spread_bps >= 5.0:
        return 75.0, "spread_bps_ge_5"
    if spread_bps >= 2.0:
        return 88.0, "spread_bps_ge_2"
    return 95.0, "spread_bps_clean"


def _activity_score(tick_age: float, surface_quality: str, daily_change_pct: float) -> Tuple[float, str]:
    score = 85.0
    reasons: List[str] = []
    if tick_age > 60.0:
        score -= 55.0
        reasons.append("tick_age_gt_60s")
    elif tick_age > 20.0:
        score -= 35.0
        reasons.append("tick_age_gt_20s")
    elif tick_age > 5.0:
        score -= 12.0
        reasons.append("tick_age_gt_5s")
    else:
        reasons.append("tick_age_usable")
    surface_score, surface_reason = _quality_score(surface_quality, ("usable", "fresh", "ok"), ("warning", "partial", "aging"), ("missing", "stale", "invalid"))
    score = (score * 0.70) + (surface_score * 0.30)
    reasons.append(surface_reason)
    if abs(daily_change_pct) > 0.0:
        score = min(100.0, score + 3.0)
        reasons.append("daily_change_nonzero")
    return max(0.0, min(100.0, score)), ";".join(reasons)


def _dead_time_cap(family: str) -> float:
    return 54.0 if family == "crypto" else 34.0


def _bucket_from_score(score: float) -> str:
    if score >= 85.0:
        return "elite_session_relevance"
    if score >= 70.0:
        return "strong_session_relevance"
    if score >= 55.0:
        return "acceptable_session_relevance"
    if score >= 35.0:
        return "weak_session_relevance"
    return "poor_session_relevance"


def _score_row(row: Dict[str, str]) -> Dict[str, str | float]:
    symbol = _safe_text(row, "symbol")
    asset_class = _safe_text(row, "asset_class")
    ranking_group = _safe_text(row, "ranking_group")
    market_state = _safe_text(row, "market_state")
    quote_quality = _safe_text(row, "quote_quality")
    surface_quality = _safe_text(row, "surface_quality")
    spread_bps = _safe_float(row.get("spread_bps"))
    tick_age = _safe_float(row.get("tick_age_seconds"))
    daily_change = _safe_float(row.get("daily_change_pct"))
    zero_spread_state = _safe_text(row, "zero_spread_state")
    seconds = _safe_int(row.get("server_time_of_day_seconds"), -1)
    session_time_basis = _safe_text(row, "session_time_basis")
    session_definition_source = _safe_text(row, "session_definition_source")

    current_session = _session_from_seconds(seconds)
    family = _symbol_family(symbol, asset_class, ranking_group)
    fit_score = float(SESSION_FIT.get(family, SESSION_FIT["unknown"]).get(current_session, 20))
    quote_score, quote_reason = _quality_score(quote_quality, ("fresh", "ok", "usable"), ("aging", "warning", "partial"), ("missing", "stale", "invalid"))
    activity_score, activity_reason = _activity_score(tick_age, surface_quality, daily_change)
    spread_score, spread_reason = _spread_safety_score(spread_bps)
    time_basis_confidence = 65.0 if "TimeCurrent" in session_time_basis else 35.0
    if session_definition_source == "pending_gateway_static_profile":
        time_basis_confidence = min(time_basis_confidence, 60.0)

    score = (fit_score * 0.35) + (activity_score * 0.25) + (quote_score * 0.20) + (spread_score * 0.10) + (time_basis_confidence * 0.10)
    score = max(0.0, min(100.0, score))
    rank_state = "ranked"
    score_quality = "usable_with_session_uncertainty"
    reasons: List[str] = ["ok_L5Pass", f"session={current_session}", f"session_family={family}", quote_reason, activity_reason, spread_reason, "time_basis_marketwatch_caveat", "static_gateway_profile_v1_not_edge_proof"]

    if current_session == OFF_SESSION_DEAD_TIME:
        cap = _dead_time_cap(family)
        if score > cap:
            score = cap
        rank_state = "ranked_degraded"
        score_quality = "off_session_dead_time_caution"
        reasons.append(f"off_session_dead_time_score_capped_at_{cap:.0f}")
        reasons.append("do_not_treat_as_trade_time")
    elif current_session == "Unknown" or family == "unknown":
        rank_state = "ranked_degraded"
        score_quality = "degraded_session_basis"
        reasons.append("unknown_session_or_family")
    elif quote_score < 40.0 or activity_score < 35.0:
        rank_state = "ranked_degraded"
        score_quality = "degraded_live_activity_or_quote"
    elif session_definition_source == "pending_gateway_static_profile":
        rank_state = "ranked_partial"
    if market_state != "open":
        rank_state = "not_rankable_quality"
        score_quality = "not_rankable_market_not_open"
        reasons.append(f"market_state={market_state}")

    return {
        "symbol": symbol, "session_score": score, "session_bucket": _bucket_from_score(score),
        "rank_state": rank_state, "score_quality": score_quality, "current_session": current_session,
        "session_definition_source": session_definition_source, "session_time_basis": session_time_basis,
        "time_basis_confidence": time_basis_confidence, "symbol_session_fit_score": fit_score,
        "live_activity_quality_score": activity_score, "quote_freshness_quality_score": quote_score,
        "spread_session_safety_score": spread_score, "asset_class": asset_class, "ranking_group": ranking_group,
        "market_state": market_state, "quote_quality": quote_quality, "surface_quality": surface_quality,
        "tick_age_seconds": tick_age, "spread_bps": spread_bps, "daily_change_pct": daily_change,
        "zero_spread_state": zero_spread_state, "reason": ";".join(reasons),
        "trade_permission": "false", "selection_runtime": "false",
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
        out["layer_id"] = "7"
        out["layer_name"] = L7_LAYER_NAME
        writer.writerow(out)
    return output.getvalue().replace("\r\n", "\n").replace("\n", "\r\n")


def _top20_text(scored: List[Dict[str, str | float]]) -> str:
    lines = ["LAYER 7 - SESSION RELEVANCE RANKING - TOP 20", "----------------------------------------", f"Generated UTC: {utc_stamp()}", "Trade Permission: FALSE", "Selection Runtime: FALSE", "Policy: Off_Session_Dead_Time is cautionary and score-capped; it is not a trade window.", "", "rank|symbol|score|bucket|state|session|reason"]
    for index, row in enumerate(scored[:20], start=1):
        lines.append(f"{index}|{row['symbol']}|{float(row['session_score']):.2f}|{row['session_bucket']}|{row['rank_state']}|{row['current_session']}|{row['reason']}")
    lines.append("")
    return "\n".join(lines)


def _symbol_rank_text(rank_index: int, row: Dict[str, str | float]) -> str:
    symbol = str(row["symbol"])
    lines = [
        "schema_name=l7_symbol_rank", "schema_version=3", "layer_id=7", f"layer_name={L7_LAYER_NAME}",
        f"owner_name={L7_OWNER}", f"job_type={L7_JOB_TYPE}", f"rank_index={rank_index}", f"symbol={symbol}",
        f"symbol_rank_filename_mode={L7_SYMBOL_RANK_FILENAME_MODE}", f"symbol_rank_filename={_symbol_rank_filename(symbol)}", f"symbol_rank_checksum={_symbol_checksum(symbol)}",
        f"session_score={float(row['session_score']):.6f}", f"session_bucket={row['session_bucket']}", f"rank_state={row['rank_state']}", f"score_quality={row['score_quality']}", f"current_session={row['current_session']}",
        f"session_definition_source={row['session_definition_source']}", f"session_time_basis={row['session_time_basis']}", f"time_basis_confidence={float(row['time_basis_confidence']):.6f}",
        f"symbol_session_fit_score={float(row['symbol_session_fit_score']):.6f}", f"live_activity_quality_score={float(row['live_activity_quality_score']):.6f}", f"quote_freshness_quality_score={float(row['quote_freshness_quality_score']):.6f}",
        f"spread_session_safety_score={float(row['spread_session_safety_score']):.6f}", f"market_state={row['market_state']}", f"quote_quality={row['quote_quality']}", f"surface_quality={row['surface_quality']}",
        f"tick_age_seconds={float(row['tick_age_seconds']):.6f}", f"spread_bps={float(row['spread_bps']):.6f}", f"reason={_format_value(row['reason'])}",
        "authority=calculation_support_only", "trade_permission=false", "selection_runtime=false", f"generated_utc={utc_stamp()}", f"generated_unix={unix_time()}", "",
    ]
    return "\n".join(lines)


def _manifest(summary: L7RankSummary, input_path: Path) -> str:
    source_counts_ok = summary.source_input_manifest_present and summary.input_count == summary.source_input_manifest_row_count
    source_l5_ok = summary.source_l5_gate_pass <= 0 or summary.input_count == summary.source_l5_gate_pass
    input_manifest_checksum_ok = summary.source_input_payload_checksum in {"not_available", ""} or summary.source_input_payload_checksum == summary.input_payload_checksum
    symbol_files_ok = summary.symbol_rank_files_written == summary.row_count and summary.symbol_rank_files_actual == summary.row_count
    return "\n".join([
        "schema_name=layer_ranked_symbols_manifest", "schema_version=3", "layer_id=7", f"layer_name={L7_LAYER_NAME}", f"owner_name={L7_OWNER}", f"job_type={L7_JOB_TYPE}", f"status={summary.status}", f"reason={summary.reason}",
        f"input_csv_path={input_path}", f"source_input_manifest_present={'true' if summary.source_input_manifest_present else 'false'}", f"source_input_manifest_row_count={summary.source_input_manifest_row_count}", f"source_l5_gate_pass={summary.source_l5_gate_pass}",
        f"source_input_payload_checksum={summary.source_input_payload_checksum}", f"input_payload_checksum={summary.input_payload_checksum}", f"input_payload_checksum_after_rank={summary.input_payload_checksum_after_rank}", f"input_generation_stable={'true' if summary.input_generation_stable else 'false'}",
        f"input_payload_checksum_matches_source_manifest={'true' if input_manifest_checksum_ok else 'false'}", f"input_csv_count_matches_input_manifest={'true' if source_counts_ok else 'false'}", f"input_csv_count_matches_source_l5_gate_pass={'true' if source_l5_ok else 'false'}",
        f"ranked_csv_path={summary.ranked_csv_path}", f"ranked_manifest_path={summary.manifest_path}", f"top20_path={summary.top20_path}", f"symbol_rank_folder_path={summary.symbol_rank_folder_path}", f"symbol_rank_filename_mode={summary.symbol_rank_filename_mode}",
        f"symbol_rank_files_written={summary.symbol_rank_files_written}", f"symbol_rank_files_actual={summary.symbol_rank_files_actual}", f"symbol_rank_file_count_ok={'true' if symbol_files_ok else 'false'}",
        f"stale_tmp_files_removed={summary.stale_tmp_files_removed}", f"stale_tmp_files_failed={summary.stale_tmp_files_failed}", f"stale_final_files_removed={summary.stale_final_files_removed}", f"stale_final_files_failed={summary.stale_final_files_failed}",
        f"input_count={summary.input_count}", f"row_count={summary.row_count}", f"ranked_count={summary.ranked_count}", f"ranked_degraded_count={summary.ranked_degraded_count}", f"not_rankable_quality_count={summary.not_rankable_quality_count}",
        f"elite_session_relevance_count={summary.elite_count}", f"strong_session_relevance_count={summary.strong_count}", f"acceptable_session_relevance_count={summary.acceptable_count}", f"weak_session_relevance_count={summary.weak_count}", f"poor_session_relevance_count={summary.poor_count}",
        f"payload_checksum={summary.payload_checksum}", "authority=calculation_support_only", "trade_permission=false", "ranking_runtime=true", "selection_runtime=false", "publication_order=write_expected_outputs_then_delete_stale_then_manifest_last", "session_profile_policy=static_gateway_profile_v2_dead_time_is_cautionary_not_trade_window", f"generated_utc={utc_stamp()}", f"generated_unix={unix_time()}", "",
    ])


def _summary_from_ranked_manifest(manifest_text: str, fallback: L7RankSummary) -> L7RankSummary:
    data = _parse_kv_text(manifest_text)
    return L7RankSummary(
        status=data.get("status", fallback.status), reason=data.get("reason", fallback.reason), input_count=_safe_int(data.get("input_count"), fallback.input_count), source_input_manifest_present=data.get("source_input_manifest_present", "false").lower() == "true",
        source_input_manifest_row_count=_safe_int(data.get("source_input_manifest_row_count"), fallback.source_input_manifest_row_count), source_l5_gate_pass=_safe_int(data.get("source_l5_gate_pass"), fallback.source_l5_gate_pass), source_input_payload_checksum=data.get("source_input_payload_checksum", fallback.source_input_payload_checksum),
        input_payload_checksum=data.get("input_payload_checksum", fallback.input_payload_checksum), input_payload_checksum_after_rank=data.get("input_payload_checksum_after_rank", fallback.input_payload_checksum_after_rank), input_generation_stable=data.get("input_generation_stable", "false").lower() == "true",
        row_count=_safe_int(data.get("row_count"), fallback.row_count), ranked_count=_safe_int(data.get("ranked_count"), fallback.ranked_count), ranked_degraded_count=_safe_int(data.get("ranked_degraded_count"), fallback.ranked_degraded_count), not_rankable_quality_count=_safe_int(data.get("not_rankable_quality_count"), fallback.not_rankable_quality_count),
        elite_count=_safe_int(data.get("elite_session_relevance_count"), fallback.elite_count), strong_count=_safe_int(data.get("strong_session_relevance_count"), fallback.strong_count), acceptable_count=_safe_int(data.get("acceptable_session_relevance_count"), fallback.acceptable_count), weak_count=_safe_int(data.get("weak_session_relevance_count"), fallback.weak_count), poor_count=_safe_int(data.get("poor_session_relevance_count"), fallback.poor_count),
        symbol_rank_files_written=_safe_int(data.get("symbol_rank_files_written"), fallback.symbol_rank_files_written), symbol_rank_files_actual=_safe_int(data.get("symbol_rank_files_actual"), fallback.symbol_rank_files_actual), symbol_rank_filename_mode=data.get("symbol_rank_filename_mode", fallback.symbol_rank_filename_mode),
        stale_tmp_files_removed=fallback.stale_tmp_files_removed, stale_tmp_files_failed=fallback.stale_tmp_files_failed, stale_final_files_removed=fallback.stale_final_files_removed, stale_final_files_failed=fallback.stale_final_files_failed, payload_checksum=data.get("payload_checksum", fallback.payload_checksum),
        ranked_csv_path=fallback.ranked_csv_path, manifest_path=fallback.manifest_path, top20_path=fallback.top20_path, symbol_rank_folder_path=fallback.symbol_rank_folder_path,
    )


def _try_reuse_unchanged_rank_outputs(summary: L7RankSummary, manifest_path: Path, ranked_path: Path, top20_path: Path, symbol_rank_dir: Path) -> L7RankSummary | None:
    if not summary.source_input_manifest_present or summary.source_input_payload_checksum in {"", "not_available"}:
        return None
    if summary.input_payload_checksum != summary.source_input_payload_checksum:
        return None
    if not manifest_path.exists() or not ranked_path.exists() or not top20_path.exists():
        return None
    existing = _summary_from_ranked_manifest(read_text(manifest_path), summary)
    actual_symbol_rank_files = _final_symbol_rank_txt_count(symbol_rank_dir)
    if existing.status not in {"complete", "input_degraded"}:
        return None
    if existing.symbol_rank_filename_mode != L7_SYMBOL_RANK_FILENAME_MODE or not existing.input_generation_stable:
        return None
    if existing.input_payload_checksum != summary.input_payload_checksum or existing.input_payload_checksum_after_rank != summary.input_payload_checksum or existing.source_input_payload_checksum != summary.source_input_payload_checksum:
        return None
    if existing.input_count <= 0 or existing.row_count != existing.input_count or existing.symbol_rank_files_written != existing.row_count or actual_symbol_rank_files != existing.row_count:
        return None
    existing.reason = "skipped_unchanged_input_reused_existing_ranked_outputs;" + existing.reason
    existing.stale_tmp_files_removed = summary.stale_tmp_files_removed
    existing.stale_tmp_files_failed = summary.stale_tmp_files_failed
    existing.symbol_rank_files_actual = actual_symbol_rank_files
    return existing


def publish_l7_session_relevance_rankings(outbox: Path) -> L7RankSummary:
    layer_dir = outbox / "Layers" / L7_LAYER_FOLDER
    input_path = layer_dir / L7_INPUT_NAME
    input_manifest_path = layer_dir / L7_INPUT_MANIFEST_NAME
    ranked_path = layer_dir / L7_RANKED_NAME
    manifest_path = layer_dir / L7_MANIFEST_NAME
    top20_path = layer_dir / L7_TOP20_NAME
    symbol_rank_dir = layer_dir / L7_SYMBOL_RANK_FOLDER
    layer_dir.mkdir(parents=True, exist_ok=True)
    symbol_rank_dir.mkdir(parents=True, exist_ok=True)

    summary = L7RankSummary("missing_input", "l7_input_primitives.csv missing", ranked_csv_path=str(ranked_path), manifest_path=str(manifest_path), top20_path=str(top20_path), symbol_rank_folder_path=str(symbol_rank_dir))
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
        atomic_write_text(manifest_path, _manifest(summary, input_path))
        return summary

    text = read_text(input_path)
    summary.input_payload_checksum = _csv_payload_checksum(text)
    reused = _try_reuse_unchanged_rank_outputs(summary, manifest_path, ranked_path, top20_path, symbol_rank_dir)
    if reused is not None:
        atomic_write_text(manifest_path, _manifest(reused, input_path))
        return reused

    rows = [row for row in csv.DictReader(io.StringIO(text.replace("\r\n", "\n")))]
    summary.input_count = len(rows)
    scored = [_score_row(row) for row in rows]
    scored.sort(key=lambda row: (SESSION_BUCKET_ORDER.get(str(row["session_bucket"]), 0), float(row["session_score"]), float(row["symbol_session_fit_score"]), float(row["live_activity_quality_score"]), str(row["symbol"])), reverse=True)

    text_after_rank = read_text(input_path)
    summary.input_payload_checksum_after_rank = _csv_payload_checksum(text_after_rank)
    after_rows = [row for row in csv.DictReader(io.StringIO(text_after_rank.replace("\r\n", "\n")))]
    summary.input_generation_stable = summary.input_payload_checksum == summary.input_payload_checksum_after_rank and summary.input_count == len(after_rows)
    if not summary.input_generation_stable:
        summary.status = "input_changed_during_rank"
        summary.reason = f"l7 input changed while ranking; before_count={summary.input_count}; after_count={len(after_rows)}; before_checksum={summary.input_payload_checksum}; after_checksum={summary.input_payload_checksum_after_rank}; existing ranked outputs intentionally left untouched"
        atomic_write_text(manifest_path, _manifest(summary, input_path))
        return summary

    ranked_csv = _write_ranked_csv(scored)
    ranked_lines = [line for line in ranked_csv.replace("\r\n", "\n").splitlines() if line.strip()]
    summary.payload_checksum = payload_checksum(ranked_lines)
    summary.status = "complete"
    summary.reason = "ranked all rows present in stable L7 input generation"
    summary.row_count = len(scored)
    summary.ranked_count = sum(1 for row in scored if row["rank_state"] in {"ranked", "ranked_partial"})
    summary.ranked_degraded_count = sum(1 for row in scored if row["rank_state"] == "ranked_degraded")
    summary.not_rankable_quality_count = sum(1 for row in scored if row["rank_state"] == "not_rankable_quality")
    summary.elite_count = sum(1 for row in scored if row["session_bucket"] == "elite_session_relevance")
    summary.strong_count = sum(1 for row in scored if row["session_bucket"] == "strong_session_relevance")
    summary.acceptable_count = sum(1 for row in scored if row["session_bucket"] == "acceptable_session_relevance")
    summary.weak_count = sum(1 for row in scored if row["session_bucket"] == "weak_session_relevance")
    summary.poor_count = sum(1 for row in scored if row["session_bucket"] == "poor_session_relevance")

    if summary.source_input_manifest_present and summary.source_input_manifest_row_count != summary.input_count:
        summary.status = "input_degraded"
        summary.reason = f"input CSV row count {summary.input_count} differs from source input manifest row_count {summary.source_input_manifest_row_count}"
    elif summary.source_l5_gate_pass > 0 and summary.source_l5_gate_pass != summary.input_count:
        summary.status = "input_degraded"
        summary.reason = f"input CSV row count {summary.input_count} differs from source l5_gate_pass {summary.source_l5_gate_pass}"

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
    atomic_write_text(manifest_path, _manifest(summary, input_path))
    return summary