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
L7_SCHEMA_VERSION = "5"
L7_SESSION_PROFILE_SOURCE = "aurora_static_fx_session_profile_v1"
OFF_SESSION_DEAD_TIME = "Off_Session_Dead_Time"
L7_REASON_MAX_PARTS = 10
L7_REASON_MAX_CHARS = 384
NOT_AVAILABLE_RANGE_STATUS = "not_available_no_l7_range_owner"

SESSION_WINDOWS = (
    ("Asia", 0, 7 * 3600),
    ("London", 7 * 3600, 12 * 3600),
    ("London_NewYork_Overlap", 12 * 3600, 16 * 3600),
    ("NewYork", 16 * 3600, 21 * 3600),
    (OFF_SESSION_DEAD_TIME, 21 * 3600, 24 * 3600),
)
SESSION_BUCKET_ORDER = {"poor_session_relevance": 0, "weak_session_relevance": 1, "acceptable_session_relevance": 2, "strong_session_relevance": 3, "elite_session_relevance": 4}
RANK_STATE_ORDER = {"ranked": 4, "ranked_partial": 3, "ranked_degraded": 2, "not_rankable_quality": 0}

OUTPUT_FIELDS = [
    "rank_index", "session_relevance_rank", "symbol", "layer_id", "layer_name", "session_score",
    "current_session_relevance_score", "session_relevance_score", "session_relevance_confidence",
    "session_bucket", "rank_state", "score_quality", "current_session", "current_session_name",
    "session_minutes_elapsed", "session_minutes_remaining", "session_definition_source", "session_time_basis",
    "time_basis_confidence", "symbol_session_fit_score", "session_activity_score", "live_activity_quality_score",
    "quote_freshness_quality_score", "session_spread_score", "spread_session_safety_score", "session_range_score",
    "session_range_score_status", "asset_class", "ranking_group", "market_state", "quote_quality", "surface_quality",
    "tick_age_seconds", "spread_bps", "daily_change_pct", "zero_spread_state", "reason", "trade_permission", "selection_runtime", "execution",
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
    reused_current_output: bool = False


def _safe_float(value: str | None, default: float = 0.0) -> float:
    try:
        text = "" if value is None else str(value).strip()
        if text == "" or text.lower() in {"nan", "inf", "-inf", "not_available", "pending"}:
            return default
        number = float(text)
        return default if math.isnan(number) or math.isinf(number) else number
    except ValueError:
        return default


def _safe_int(value: str | None, default: int = 0) -> int:
    try:
        text = "" if value is None else str(value).strip()
        if text == "" or text.lower() in {"nan", "inf", "-inf", "not_available", "pending"}:
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
        if len(parts) >= L7_REASON_MAX_PARTS:
            break
    text = ";".join(parts) if parts else "not_available"
    if len(text) > L7_REASON_MAX_CHARS:
        text = text[: max(0, L7_REASON_MAX_CHARS - 18)].rstrip("; ") + ";reason_truncated"
    return text


def _parse_kv_text(text: str) -> Dict[str, str]:
    data: Dict[str, str] = {}
    for raw_line in text.replace("\r\n", "\n").splitlines():
        line = raw_line.strip()
        if line and not line.startswith("#") and "=" in line:
            key, value = line.split("=", 1)
            data[key.strip()] = value.strip()
    return data


def _sanitize_path_part(value: str) -> str:
    safe = str(value).strip() or "unknown"
    for ch in ["\\", "/", ":", "*", "?", '"', "<", ">", "|", " "]:
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
    if folder.exists():
        for path in folder.glob(pattern):
            r, f = _remove_file_if_exists(path)
            removed += r
            failed += f
    return removed, failed


def _clear_transient_files(layer_dir: Path, symbol_rank_dir: Path) -> Tuple[int, int]:
    removed = failed = 0
    for folder in (layer_dir, symbol_rank_dir):
        for pattern in ("*.tmp", "*.write_failed.txt"):
            r, f = _cleanup_glob(folder, pattern)
            removed += r
            failed += f
    return removed, failed


def _final_symbol_rank_txt_count(symbol_rank_dir: Path) -> int:
    return sum(1 for p in symbol_rank_dir.glob("*.txt") if p.is_file()) if symbol_rank_dir.exists() else 0


def _delete_stale_symbol_rank_files(symbol_rank_dir: Path, expected_names: Iterable[str]) -> Tuple[int, int]:
    expected = set(expected_names)
    removed = failed = 0
    if symbol_rank_dir.exists():
        for path in symbol_rank_dir.glob("*.txt"):
            if path.name not in expected:
                r, f = _remove_file_if_exists(path)
                removed += r
                failed += f
    return removed, failed


def _csv_payload_checksum(text: str) -> str:
    return payload_checksum([line for line in text.replace("\r\n", "\n").splitlines() if line.strip()])


def _session_from_seconds(seconds: int) -> str:
    for name, start, end in SESSION_WINDOWS:
        if start <= seconds < end:
            return name
    return "Unknown"


def _session_minutes(seconds: int, session_name: str) -> Tuple[int, int]:
    for name, start, end in SESSION_WINDOWS:
        if name == session_name:
            return int(max(0, seconds - start) // 60), int(max(0, end - seconds) // 60)
    return -1, -1


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
    if lower in {"not_available", "missing", "pending"}:
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


def _time_basis_confidence(session_time_basis: str, session_definition_source: str) -> float:
    text = session_time_basis.lower()
    if "l4_refresh_time" in text:
        confidence = 65.0
    elif "timecurrent_fallback" in text or "timecurrent" in text:
        confidence = 45.0
    else:
        confidence = 30.0
    if "static" in session_definition_source.lower():
        confidence = min(confidence, 60.0)
    return confidence


def _confidence(score: float, time_basis_confidence: float, current_session: str, family: str, rank_state: str) -> float:
    conf = min(100.0, (score * 0.55) + (time_basis_confidence * 0.45))
    if current_session == "Unknown" or family == "unknown":
        conf = min(conf, 35.0)
    if rank_state == "ranked_degraded":
        conf = min(conf, 50.0)
    if rank_state == "not_rankable_quality":
        conf = min(conf, 20.0)
    return max(0.0, conf)


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
    raw_session_source = _safe_text(row, "session_definition_source", L7_SESSION_PROFILE_SOURCE)
    session_definition_source = L7_SESSION_PROFILE_SOURCE if raw_session_source == "pending_gateway_static_profile" else raw_session_source
    current_session = _session_from_seconds(seconds)
    minutes_elapsed, minutes_remaining = _session_minutes(seconds, current_session)
    family = _symbol_family(symbol, asset_class, ranking_group)
    fit_score = float(SESSION_FIT.get(family, SESSION_FIT["unknown"]).get(current_session, 20))
    quote_score, quote_reason = _quality_score(quote_quality, ("fresh", "ok", "usable"), ("aging", "warning", "partial"), ("missing", "stale", "invalid"))
    activity_score, activity_reason = _activity_score(tick_age, surface_quality, daily_change)
    spread_score, spread_reason = _spread_safety_score(spread_bps)
    time_basis_confidence = _time_basis_confidence(session_time_basis, session_definition_source)
    score = max(0.0, min(100.0, (fit_score * 0.35) + (activity_score * 0.25) + (quote_score * 0.20) + (spread_score * 0.10) + (time_basis_confidence * 0.10)))
    rank_state = "ranked_partial" if session_definition_source == L7_SESSION_PROFILE_SOURCE else "ranked"
    score_quality = "usable_with_static_session_profile_uncertainty"
    reasons: List[str] = ["ok_L5Pass", f"session={current_session}", f"session_family={family}", quote_reason, activity_reason, spread_reason, "time_basis_marketwatch_caveat", "static_session_profile_not_edge_proof"]
    if current_session == OFF_SESSION_DEAD_TIME:
        cap = _dead_time_cap(family)
        score = min(score, cap)
        rank_state = "ranked_degraded"
        score_quality = "off_session_dead_time_caution"
        reasons.append(f"off_session_dead_time_score_capped_at_{cap:.0f}")
    elif current_session == "Unknown" or family == "unknown":
        rank_state = "ranked_degraded"
        score_quality = "degraded_session_basis"
        reasons.append("unknown_session_or_family")
    elif quote_score < 40.0 or activity_score < 35.0:
        rank_state = "ranked_degraded"
        score_quality = "degraded_live_activity_or_quote"
    if market_state != "open":
        score = 0.0
        rank_state = "not_rankable_quality"
        score_quality = "not_rankable_market_not_open"
        reasons.append(f"market_state={market_state}")
    session_confidence = _confidence(score, time_basis_confidence, current_session, family, rank_state)
    return {
        "symbol": symbol, "session_score": score, "current_session_relevance_score": score, "session_relevance_score": score,
        "session_relevance_confidence": session_confidence, "session_bucket": _bucket_from_score(score), "rank_state": rank_state,
        "score_quality": score_quality, "current_session": current_session, "current_session_name": current_session,
        "session_minutes_elapsed": float(minutes_elapsed), "session_minutes_remaining": float(minutes_remaining),
        "session_definition_source": session_definition_source, "session_time_basis": session_time_basis, "time_basis_confidence": time_basis_confidence,
        "symbol_session_fit_score": fit_score, "session_activity_score": activity_score, "live_activity_quality_score": activity_score,
        "quote_freshness_quality_score": quote_score, "session_spread_score": spread_score, "spread_session_safety_score": spread_score,
        "session_range_score": "not_available", "session_range_score_status": NOT_AVAILABLE_RANGE_STATUS, "asset_class": asset_class,
        "ranking_group": ranking_group, "market_state": market_state, "quote_quality": quote_quality, "surface_quality": surface_quality,
        "tick_age_seconds": tick_age, "spread_bps": spread_bps, "daily_change_pct": daily_change, "zero_spread_state": zero_spread_state,
        "reason": _bounded_reason(";".join(reasons)), "trade_permission": "false", "selection_runtime": "false", "execution": "false",
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
        out["session_relevance_rank"] = str(index)
        out["layer_id"] = "7"
        out["layer_name"] = L7_LAYER_NAME
        writer.writerow(out)
    return output.getvalue().replace("\r\n", "\n").replace("\n", "\r\n")


def _top20_text(scored: List[Dict[str, str | float]]) -> str:
    lines = ["LAYER 7 - SESSION RELEVANCE RANKING - TOP 20", "Generated UTC: " + utc_stamp(), "rank|symbol|score|confidence|bucket|state|session|elapsed_min|remaining_min|reason"]
    for index, row in enumerate(scored[:20], start=1):
        lines.append(f"{index}|{row['symbol']}|{float(row['session_score']):.2f}|{float(row['session_relevance_confidence']):.2f}|{row['session_bucket']}|{row['rank_state']}|{row['current_session']}|{int(float(row['session_minutes_elapsed']))}|{int(float(row['session_minutes_remaining']))}|{_bounded_reason(str(row['reason']))}")
    lines.append("")
    return "\n".join(lines)


def _symbol_rank_text(rank_index: int, row: Dict[str, str | float]) -> str:
    symbol = str(row["symbol"])
    fields = {
        "schema_name": "l7_symbol_rank", "schema_version": L7_SCHEMA_VERSION, "layer_id": "7", "layer_name": L7_LAYER_NAME,
        "owner_name": L7_OWNER, "job_type": L7_JOB_TYPE, "rank_index": str(rank_index), "session_relevance_rank": str(rank_index),
        "symbol": symbol, "symbol_rank_filename_mode": L7_SYMBOL_RANK_FILENAME_MODE, "symbol_rank_filename": _symbol_rank_filename(symbol),
        "symbol_rank_checksum": _symbol_checksum(symbol), "session_score": f"{float(row['session_score']):.6f}",
        "current_session_relevance_score": f"{float(row['current_session_relevance_score']):.6f}", "session_relevance_score": f"{float(row['session_relevance_score']):.6f}",
        "session_relevance_confidence": f"{float(row['session_relevance_confidence']):.6f}", "session_bucket": str(row["session_bucket"]),
        "rank_state": str(row["rank_state"]), "score_quality": str(row["score_quality"]), "current_session": str(row["current_session"]),
        "current_session_name": str(row["current_session_name"]), "session_minutes_elapsed": str(int(float(row["session_minutes_elapsed"]))),
        "session_minutes_remaining": str(int(float(row["session_minutes_remaining"]))), "session_definition_source": str(row["session_definition_source"]),
        "session_time_basis": str(row["session_time_basis"]), "time_basis_confidence": f"{float(row['time_basis_confidence']):.6f}",
        "symbol_session_fit_score": f"{float(row['symbol_session_fit_score']):.6f}", "session_activity_score": f"{float(row['session_activity_score']):.6f}",
        "quote_freshness_quality_score": f"{float(row['quote_freshness_quality_score']):.6f}", "session_spread_score": f"{float(row['session_spread_score']):.6f}",
        "session_range_score": str(row["session_range_score"]), "session_range_score_status": str(row["session_range_score_status"]),
        "market_state": str(row["market_state"]), "quote_quality": str(row["quote_quality"]), "surface_quality": str(row["surface_quality"]),
        "tick_age_seconds": f"{float(row['tick_age_seconds']):.6f}", "spread_bps": f"{float(row['spread_bps']):.6f}",
        "reason": _format_value(_bounded_reason(str(row["reason"]))), "authority": "calculation_support_only", "trade_permission": "false",
        "selection_runtime": "false", "execution": "false", "generated_utc": utc_stamp(), "generated_unix": str(unix_time()),
    }
    return "\n".join(f"{key}={value}" for key, value in fields.items()) + "\n"


def _manifest(summary: L7RankSummary, input_path: Path) -> str:
    summary.reason = _bounded_reason(summary.reason)
    source_counts_ok = summary.source_input_manifest_present and summary.input_count == summary.source_input_manifest_row_count
    source_l5_ok = summary.source_l5_gate_pass <= 0 or summary.input_count == summary.source_l5_gate_pass
    input_manifest_checksum_ok = summary.source_input_payload_checksum in {"not_available", ""} or summary.source_input_payload_checksum == summary.input_payload_checksum
    symbol_files_ok = summary.symbol_rank_files_written == summary.row_count and summary.symbol_rank_files_actual == summary.row_count
    fields = {
        "schema_name": "layer_ranked_symbols_manifest", "schema_version": L7_SCHEMA_VERSION, "layer_id": "7", "layer_name": L7_LAYER_NAME,
        "owner_name": L7_OWNER, "job_type": L7_JOB_TYPE, "status": summary.status, "reason": summary.reason, "input_csv_path": str(input_path),
        "source_input_manifest_present": "true" if summary.source_input_manifest_present else "false", "source_input_manifest_row_count": str(summary.source_input_manifest_row_count),
        "source_l5_gate_pass": str(summary.source_l5_gate_pass), "source_input_payload_checksum": summary.source_input_payload_checksum,
        "input_payload_checksum": summary.input_payload_checksum, "input_payload_checksum_after_rank": summary.input_payload_checksum_after_rank,
        "input_generation_stable": "true" if summary.input_generation_stable else "false", "input_payload_checksum_matches_source_manifest": "true" if input_manifest_checksum_ok else "false",
        "input_csv_count_matches_input_manifest": "true" if source_counts_ok else "false", "input_csv_count_matches_source_l5_gate_pass": "true" if source_l5_ok else "false",
        "ranked_csv_path": summary.ranked_csv_path, "ranked_manifest_path": summary.manifest_path, "top20_path": summary.top20_path,
        "symbol_rank_folder_path": summary.symbol_rank_folder_path, "symbol_rank_filename_mode": summary.symbol_rank_filename_mode,
        "symbol_rank_files_written": str(summary.symbol_rank_files_written), "symbol_rank_files_actual": str(summary.symbol_rank_files_actual),
        "symbol_rank_file_count_ok": "true" if symbol_files_ok else "false", "stale_tmp_files_removed": str(summary.stale_tmp_files_removed),
        "stale_tmp_files_failed": str(summary.stale_tmp_files_failed), "stale_final_files_removed": str(summary.stale_final_files_removed),
        "stale_final_files_failed": str(summary.stale_final_files_failed), "input_count": str(summary.input_count), "row_count": str(summary.row_count),
        "ranked_count": str(summary.ranked_count), "ranked_degraded_count": str(summary.ranked_degraded_count), "not_rankable_quality_count": str(summary.not_rankable_quality_count),
        "elite_session_relevance_count": str(summary.elite_count), "strong_session_relevance_count": str(summary.strong_count),
        "acceptable_session_relevance_count": str(summary.acceptable_count), "weak_session_relevance_count": str(summary.weak_count), "poor_session_relevance_count": str(summary.poor_count),
        "payload_checksum": summary.payload_checksum, "authority": "calculation_support_only", "trade_permission": "false", "ranking_runtime": "true", "selection_runtime": "false", "execution": "false",
        "reused_current_output": "true" if summary.reused_current_output else "false",
        "publication_order": "write_outputs_delete_stale_manifest_last", "session_profile_source": L7_SESSION_PROFILE_SOURCE,
        "session_range_score_policy": "not_available_until_non_l7_range_owner_provides_source", "reason_max_parts": str(L7_REASON_MAX_PARTS),
        "reason_max_chars": str(L7_REASON_MAX_CHARS), "generated_utc": utc_stamp(), "generated_unix": str(unix_time()),
    }
    return "\n".join(f"{key}={value}" for key, value in fields.items()) + "\n"


def _summary_from_ranked_manifest(manifest_text: str, fallback: L7RankSummary) -> L7RankSummary:
    data = _parse_kv_text(manifest_text)
    return L7RankSummary(status=data.get("status", fallback.status), reason=_bounded_reason(data.get("reason", fallback.reason)), input_count=_safe_int(data.get("input_count"), fallback.input_count), source_input_manifest_present=data.get("source_input_manifest_present", "false").lower() == "true", source_input_manifest_row_count=_safe_int(data.get("source_input_manifest_row_count"), fallback.source_input_manifest_row_count), source_l5_gate_pass=_safe_int(data.get("source_l5_gate_pass"), fallback.source_l5_gate_pass), source_input_payload_checksum=data.get("source_input_payload_checksum", fallback.source_input_payload_checksum), input_payload_checksum=data.get("input_payload_checksum", fallback.input_payload_checksum), input_payload_checksum_after_rank=data.get("input_payload_checksum_after_rank", fallback.input_payload_checksum_after_rank), input_generation_stable=data.get("input_generation_stable", "false").lower() == "true", row_count=_safe_int(data.get("row_count"), fallback.row_count), ranked_count=_safe_int(data.get("ranked_count"), fallback.ranked_count), ranked_degraded_count=_safe_int(data.get("ranked_degraded_count"), fallback.ranked_degraded_count), not_rankable_quality_count=_safe_int(data.get("not_rankable_quality_count"), fallback.not_rankable_quality_count), elite_count=_safe_int(data.get("elite_session_relevance_count"), fallback.elite_count), strong_count=_safe_int(data.get("strong_session_relevance_count"), fallback.strong_count), acceptable_count=_safe_int(data.get("acceptable_session_relevance_count"), fallback.acceptable_count), weak_count=_safe_int(data.get("weak_session_relevance_count"), fallback.weak_count), poor_count=_safe_int(data.get("poor_session_relevance_count"), fallback.poor_count), symbol_rank_files_written=_safe_int(data.get("symbol_rank_files_written"), fallback.symbol_rank_files_written), symbol_rank_files_actual=_safe_int(data.get("symbol_rank_files_actual"), fallback.symbol_rank_files_actual), symbol_rank_filename_mode=data.get("symbol_rank_filename_mode", fallback.symbol_rank_filename_mode), stale_tmp_files_removed=fallback.stale_tmp_files_removed, stale_tmp_files_failed=fallback.stale_tmp_files_failed, stale_final_files_removed=fallback.stale_final_files_removed, stale_final_files_failed=fallback.stale_final_files_failed, payload_checksum=data.get("payload_checksum", fallback.payload_checksum), ranked_csv_path=fallback.ranked_csv_path, manifest_path=fallback.manifest_path, top20_path=fallback.top20_path, symbol_rank_folder_path=fallback.symbol_rank_folder_path, reused_current_output=data.get("reused_current_output", "false").lower() == "true")


def _try_reuse_unchanged_rank_outputs(summary: L7RankSummary, manifest_path: Path, ranked_path: Path, top20_path: Path, symbol_rank_dir: Path) -> L7RankSummary | None:
    if not summary.source_input_manifest_present or summary.source_input_payload_checksum in {"", "not_available"} or summary.input_payload_checksum != summary.source_input_payload_checksum:
        return None
    if not manifest_path.exists() or not ranked_path.exists() or not top20_path.exists():
        return None
    manifest_text = read_text(manifest_path)
    manifest_data = _parse_kv_text(manifest_text)
    if manifest_data.get("schema_version") != L7_SCHEMA_VERSION:
        return None
    existing = _summary_from_ranked_manifest(manifest_text, summary)
    actual_symbol_rank_files = _final_symbol_rank_txt_count(symbol_rank_dir)
    if existing.status not in {"complete", "input_degraded"} or existing.symbol_rank_filename_mode != L7_SYMBOL_RANK_FILENAME_MODE or not existing.input_generation_stable:
        return None
    if existing.input_payload_checksum != summary.input_payload_checksum or existing.input_payload_checksum_after_rank != summary.input_payload_checksum or existing.source_input_payload_checksum != summary.source_input_payload_checksum:
        return None
    if existing.input_count <= 0 or existing.row_count != existing.input_count or existing.symbol_rank_files_written != existing.row_count or actual_symbol_rank_files != existing.row_count:
        return None
    existing.reason = _bounded_reason("skipped_unchanged_input_reused_existing_ranked_outputs;" + existing.reason)
    existing.stale_tmp_files_removed = summary.stale_tmp_files_removed
    existing.stale_tmp_files_failed = summary.stale_tmp_files_failed
    existing.symbol_rank_files_actual = actual_symbol_rank_files
    existing.reused_current_output = True
    return existing


def _layer_paths(outbox: Path) -> Tuple[Path, Path, Path, Path, Path, Path]:
    layer_dir = outbox / "Layers" / L7_LAYER_FOLDER
    return layer_dir, layer_dir / L7_INPUT_NAME, layer_dir / L7_INPUT_MANIFEST_NAME, layer_dir / L7_RANKED_NAME, layer_dir / L7_MANIFEST_NAME, layer_dir / L7_TOP20_NAME


def publish_l7_session_relevance_rankings(outbox: Path) -> L7RankSummary:
    layer_dir, input_path, input_manifest_path, ranked_path, manifest_path, top20_path = _layer_paths(outbox)
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
    removed, failed = _clear_transient_files(layer_dir, symbol_rank_dir)
    summary.stale_tmp_files_removed += removed
    summary.stale_tmp_files_failed += failed
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
    scored.sort(key=lambda row: (RANK_STATE_ORDER.get(str(row["rank_state"]), 0), SESSION_BUCKET_ORDER.get(str(row["session_bucket"]), 0), float(row["session_score"]), float(row["symbol_session_fit_score"]), float(row["live_activity_quality_score"]), str(row["symbol"])), reverse=True)
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
    if summary.source_input_manifest_present and summary.source_input_payload_checksum not in {"", "not_available"} and summary.source_input_payload_checksum != summary.input_payload_checksum:
        summary.status = "input_degraded"
        summary.reason = f"input CSV payload checksum {summary.input_payload_checksum} differs from source input manifest payload_checksum {summary.source_input_payload_checksum}"
    elif summary.source_input_manifest_present and summary.source_input_manifest_row_count != summary.input_count:
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
