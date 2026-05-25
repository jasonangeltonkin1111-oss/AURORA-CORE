from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Iterable, List, Tuple
import csv
import io
import math
import os

from aurora_worker_io import atomic_write_text, payload_checksum, read_text, unix_time, utc_stamp

L15_LAYER_FOLDER = "Layer_15_Correlation_Diversity_Selection"
L15_OWNER = "Runtime 5 - Taxonomy / Ranking Group Owner"
L15_AUTHORITY = "correlation_diversity_scoring_only"
L15_SCHEMA_NAME = "l15_correlation_diversity_selection"
L15_TIMEFRAME = "H1"
L15_LOOKBACK_BARS = 168
L15_MIN_ALIGNED_RETURNS = 80
L15_DEFAULT_MAX_CORR_ABS = 0.30
L15_DEFAULT_MAX_CANDIDATES = 80
L15_DEFAULT_MAX_OHLC_FILE_SCAN = 5000

SCORE_FIELDS = [
    "candidate_pool_rank", "symbol", "canonical_symbol", "ranking_group", "ranking_group_slug", "asset_class", "market_group", "market_segment",
    "l14_candidate_priority_score", "leader_or_backup", "candidate_source", "base_currency", "quote_currency", "pair_count", "corr_pair_count",
    "corr_unavailable_count", "corr_to_pool_max_abs", "corr_to_pool_avg_abs", "corr_pair_max_symbol", "correlation_state",
    "correlation_reject_reason", "currency_overlap_score", "ranking_group_overlap_score", "diversity_score", "diversity_state",
    "correlation_method", "correlation_timeframe", "correlation_lookback_bars", "correlation_sample_count", "correlation_confidence",
    "l16_constraint_hint", "meaning", "selection_runtime", "trade_permission", "entry_signal", "execution", "generated_utc",
]

PAIR_FIELDS = [
    "symbol_a", "symbol_b", "ranking_group_a", "ranking_group_b", "base_currency_a", "quote_currency_a", "base_currency_b", "quote_currency_b",
    "same_ranking_group", "shared_currency_count", "shared_currency_reason", "correlation_value", "correlation_abs", "correlation_state",
    "correlation_sample_count", "correlation_method", "correlation_timeframe", "correlation_lookback_bars", "data_quality_reason",
    "currency_overlap_score", "ranking_group_overlap_score", "pair_diversity_risk_score", "meaning", "trade_permission", "entry_signal", "execution", "generated_utc",
]

GROUP_FIELDS = [
    "ranking_group", "ranking_group_slug", "candidate_count", "leader_count", "backup_count", "max_pair_corr_abs", "avg_pair_corr_abs",
    "high_corr_pair_count", "correlation_unavailable_pair_count", "currency_overlap_pair_count", "group_diversity_score", "group_diversity_state",
    "top_candidate", "meaning", "trade_permission", "entry_signal", "execution", "generated_utc",
]


@dataclass(frozen=True)
class L15PublishSummary:
    status: str
    reason: str
    candidate_pool_size: int = 0
    candidate_scored_count: int = 0
    pairwise_pair_count: int = 0
    corr_pair_count: int = 0
    high_corr_pair_count: int = 0
    corr_unavailable_count: int = 0
    group_count: int = 0
    write_failed_count: int = 0
    top_diversity_candidate: str = "not_available"
    max_pair_corr_abs: str = "not_available"
    output_path: str = "not_available"
    summary_path: str = "not_available"
    selection_desk_summary_path: str = "not_available"
    candidate_input_count: int = 0
    candidate_pool_capped: str = "false"
    candidate_pool_cap: int = L15_DEFAULT_MAX_CANDIDATES
    ohlc_scan_file_limit: int = L15_DEFAULT_MAX_OHLC_FILE_SCAN
    ohlc_scan_file_count: int = 0
    threshold_source: str = "default"
    max_allowed_pairwise_correlation_abs: str = "0.30"


EMPTY_L15_SUMMARY = L15PublishSummary("pending", "l15_not_run")


def _env_int(name: str, default: int, minimum: int, maximum: int) -> int:
    raw = os.environ.get(name, "").strip()
    if not raw:
        return default
    try:
        value = int(float(raw))
    except ValueError:
        return default
    return max(minimum, min(maximum, value))


def _env_float(name: str, default: float, minimum: float, maximum: float) -> Tuple[float, str]:
    raw = os.environ.get(name, "").strip()
    if not raw:
        return default, "default"
    try:
        value = float(raw)
    except ValueError:
        return default, "invalid_env_defaulted"
    if math.isnan(value) or math.isinf(value):
        return default, "invalid_env_defaulted"
    return max(minimum, min(maximum, value)), "env"


def l15_max_corr_abs() -> float:
    return _env_float("AURORA_L15_MAX_CORR_ABS", L15_DEFAULT_MAX_CORR_ABS, 0.05, 0.95)[0]


def l15_threshold_source() -> str:
    return _env_float("AURORA_L15_MAX_CORR_ABS", L15_DEFAULT_MAX_CORR_ABS, 0.05, 0.95)[1]


def l15_max_candidates() -> int:
    return _env_int("AURORA_L15_MAX_CANDIDATES", L15_DEFAULT_MAX_CANDIDATES, 10, 250)


def l15_max_ohlc_file_scan() -> int:
    return _env_int("AURORA_L15_MAX_OHLC_FILE_SCAN", L15_DEFAULT_MAX_OHLC_FILE_SCAN, 100, 100000)


def _text(row: Dict[str, str], key: str, default: str = "not_available") -> str:
    value = str(row.get(key, default) or "").strip()
    return value if value else default


def _num(value: str | None, default: float = 0.0) -> float:
    try:
        number = float(str(value or "").strip())
        return default if math.isnan(number) or math.isinf(number) else number
    except ValueError:
        return default


def _int(value: str | None) -> int:
    try:
        return int(float(str(value or "0").strip()))
    except ValueError:
        return 0


def _csv(path: Path) -> List[Dict[str, str]]:
    return [{str(k): "" if v is None else str(v) for k, v in row.items()} for row in csv.DictReader(io.StringIO(read_text(path).replace("\r\n", "\n")))]


def _csv_text(rows: List[Dict[str, str]], fields: List[str]) -> str:
    out = io.StringIO(newline="")
    writer = csv.DictWriter(out, fieldnames=fields, extrasaction="ignore", lineterminator="\n")
    writer.writeheader()
    for row in rows:
        writer.writerow({field: row.get(field, "not_available") for field in fields})
    return out.getvalue()


def _kv(path: Path) -> Dict[str, str]:
    data: Dict[str, str] = {}
    for raw in read_text(path).replace("\r\n", "\n").splitlines():
        if "=" in raw and not raw.strip().startswith("#"):
            k, v = raw.split("=", 1)
            data[k.strip()] = v.strip()
    return data


def _safe_slug(value: str) -> str:
    safe = value.strip() or "unknown"
    for ch in ['\\', '/', ':', '*', '?', '"', '<', '>', '|', ' ']:
        safe = safe.replace(ch, "_")
    return safe or "unknown"


def _root_from_outbox(outbox: Path) -> Path:
    return outbox.parents[2]


def _select_dir(outbox: Path) -> Path:
    return outbox.parents[2] / "Selection Desk" / "Groups"


def _write(path: Path, text: str, failed: List[Path]) -> None:
    if not atomic_write_text(path, text):
        failed.append(path)


def _symbol_root(symbol: str) -> str:
    return symbol.split(".", 1)[0].upper().replace("_", "").replace("-", "")


def _base_quote(symbol: str) -> Tuple[str, str]:
    root = _symbol_root(symbol)
    for quote in ["USDT", "USD", "EUR", "GBP", "JPY", "AUD", "CAD", "CHF", "NZD", "BTC", "ETH", "ZAR"]:
        if root.endswith(quote) and len(root) > len(quote):
            return root[:-len(quote)], quote
    return root, "not_available"


def _shared_currency(a_base: str, a_quote: str, b_base: str, b_quote: str) -> Tuple[int, str]:
    a = {x for x in (a_base, a_quote) if x and x != "not_available"}
    b = {x for x in (b_base, b_quote) if x and x != "not_available"}
    shared = sorted(a.intersection(b))
    return len(shared), ",".join(shared) if shared else "none"


def _ohlc_store_roots(root: Path) -> List[Path]:
    candidates = [
        root / "Shared Market Data" / "OHLC Store",
        root.parent / "Shared Market Data" / "OHLC Store",
        root.parent.parent / "Shared Market Data" / "OHLC Store" if len(root.parents) > 1 else root.parent / "Shared Market Data" / "OHLC Store",
    ]
    return [p for p in candidates if p.exists() and p.is_dir()]


def _candidate_ohlc_files(root: Path, symbols: Iterable[str]) -> Tuple[Dict[str, Path], int]:
    stores = _ohlc_store_roots(root)
    if not stores:
        return {}, 0

    wanted = {_symbol_root(s): s for s in symbols}
    found: Dict[str, Path] = {}

    patterns = []
    for root_symbol in wanted:
        patterns.extend([
            f"*{root_symbol}*{L15_TIMEFRAME}*.csv",
            f"*{root_symbol}*{L15_TIMEFRAME}*.txt",
            f"*{root_symbol}*.{L15_TIMEFRAME}*.csv",
            f"*{root_symbol}*.{L15_TIMEFRAME}*.txt",
        ])
    for store in stores:
        for pattern in patterns:
            try:
                for path in store.rglob(pattern):
                    if not path.is_file():
                        continue
                    upper = str(path).upper()
                    if L15_TIMEFRAME not in upper:
                        continue
                    for root_symbol, original in wanted.items():
                        if original not in found and root_symbol in upper:
                            found[original] = path
                    if len(found) >= len(wanted):
                        return found, 0
            except OSError:
                continue

    scanned = 0
    max_scan = l15_max_ohlc_file_scan()
    for store in stores:
        try:
            for path in store.rglob("*"):
                scanned += 1
                if scanned > max_scan:
                    return found, scanned
                if not path.is_file() or path.suffix.lower() not in {".csv", ".txt"}:
                    continue
                upper = str(path).upper()
                if L15_TIMEFRAME not in upper:
                    continue
                for root_symbol, original in wanted.items():
                    if original not in found and root_symbol in upper:
                        found[original] = path
                if len(found) >= len(wanted):
                    return found, scanned
        except OSError:
            continue
    return found, scanned


def _read_close_series(path: Path) -> List[Tuple[str, float]]:
    text = read_text(path).replace("\r\n", "\n").strip()
    if not text:
        return []
    rows: List[Tuple[str, float]] = []
    first = text.splitlines()[0].lower()
    if "," in first and ("time" in first or "close" in first or "bar_time" in first):
        for row in csv.DictReader(io.StringIO(text)):
            time_key = "bar_time" if "bar_time" in row else ("time" if "time" in row else "timestamp")
            close_key = "close" if "close" in row else ("close_i" if "close_i" in row else "Close")
            t = str(row.get(time_key, "")).strip()
            c = _num(row.get(close_key), default=float("nan"))
            if t and not math.isnan(c) and c > 0:
                rows.append((t, c))
    else:
        for line in text.splitlines():
            parts = [p.strip() for p in line.split(",")]
            if len(parts) >= 5:
                c = _num(parts[4], default=float("nan"))
                if parts[0] and not math.isnan(c) and c > 0:
                    rows.append((parts[0], c))
    return rows[-L15_LOOKBACK_BARS:]


def _returns_by_time(series: List[Tuple[str, float]]) -> Dict[str, float]:
    out: Dict[str, float] = {}
    for idx in range(1, len(series)):
        t, c = series[idx]
        prev = series[idx - 1][1]
        if prev > 0 and c > 0:
            out[t] = math.log(c / prev)
    return out


def _pearson(a: Dict[str, float], b: Dict[str, float]) -> Tuple[str, float | None, int, str]:
    keys = sorted(set(a).intersection(b))
    n = len(keys)
    if n < L15_MIN_ALIGNED_RETURNS:
        return "not_available", None, n, "insufficient_aligned_returns"
    xs = [a[k] for k in keys]
    ys = [b[k] for k in keys]
    mx = sum(xs) / n
    my = sum(ys) / n
    vx = sum((x - mx) ** 2 for x in xs)
    vy = sum((y - my) ** 2 for y in ys)
    if vx <= 0.0 or vy <= 0.0:
        return "not_available", None, n, "zero_variance_returns"
    cov = sum((xs[i] - mx) * (ys[i] - my) for i in range(n))
    corr = max(-1.0, min(1.0, cov / math.sqrt(vx * vy)))
    return f"{corr:.6f}", abs(corr), n, "ok"


def _corr_state(corr_abs: float | None, reason: str) -> str:
    if reason != "ok" or corr_abs is None:
        return "INSUFFICIENT_SAMPLE" if reason == "insufficient_aligned_returns" else "CORRELATION_UNAVAILABLE"
    if corr_abs <= l15_max_corr_abs():
        return "LOW_CORRELATION"
    if corr_abs <= 0.50:
        return "MODERATE_CORRELATION"
    if corr_abs <= 0.75:
        return "HIGH_CORRELATION"
    return "EXTREME_CORRELATION"


def _diversity_state(score: float) -> str:
    if score >= 75:
        return "DIVERSITY_CLEAN"
    if score >= 55:
        return "DIVERSITY_WARNING"
    if score >= 35:
        return "DIVERSITY_CONSTRAINED"
    return "DIVERSITY_HIGH_RISK"


def _ranked_candidate_window(candidates: List[Dict[str, str]]) -> Tuple[List[Dict[str, str]], bool]:
    cap = l15_max_candidates()
    ranked = sorted(candidates, key=lambda r: (_int(_text(r, "candidate_pool_rank", "999999")), -_num(_text(r, "l14_candidate_priority_score", "0")), _text(r, "symbol")))
    return ranked[:cap], len(ranked) > cap


def _build(root: Path, candidates: List[Dict[str, str]]) -> Tuple[List[Dict[str, str]], List[Dict[str, str]], List[Dict[str, str]], int, bool]:
    candidates, capped = _ranked_candidate_window(candidates)
    symbols = [_text(r, "symbol") for r in candidates if _text(r, "symbol") != "not_available"]
    ohlc_files, scanned_count = _candidate_ohlc_files(root, symbols)
    returns: Dict[str, Dict[str, float]] = {}
    for symbol, path in ohlc_files.items():
        try:
            returns[symbol] = _returns_by_time(_read_close_series(path))
        except Exception:
            continue

    meta: Dict[str, Dict[str, str]] = {}
    for row in candidates:
        symbol = _text(row, "symbol")
        base, quote = _base_quote(symbol)
        new = dict(row)
        new["base_currency"] = base
        new["quote_currency"] = quote
        meta[symbol] = new

    pair_rows: List[Dict[str, str]] = []
    for i in range(len(symbols)):
        for j in range(i + 1, len(symbols)):
            a, b = symbols[i], symbols[j]
            ra, rb = meta.get(a, {}), meta.get(b, {})
            same_group = _text(ra, "ranking_group") == _text(rb, "ranking_group")
            shared_count, shared_reason = _shared_currency(_text(ra, "base_currency"), _text(ra, "quote_currency"), _text(rb, "base_currency"), _text(rb, "quote_currency"))
            if a in returns and b in returns:
                corr_text, corr_abs, sample_count, reason = _pearson(returns[a], returns[b])
            else:
                corr_text, corr_abs, sample_count, reason = "not_available", None, 0, "missing_ohlc"
            pair_risk = (corr_abs * 60.0 if corr_abs is not None else 20.0) + shared_count * 15.0 + (20.0 if same_group else 0.0)
            pair_rows.append({
                "symbol_a": a, "symbol_b": b, "ranking_group_a": _text(ra, "ranking_group"), "ranking_group_b": _text(rb, "ranking_group"),
                "base_currency_a": _text(ra, "base_currency"), "quote_currency_a": _text(ra, "quote_currency"),
                "base_currency_b": _text(rb, "base_currency"), "quote_currency_b": _text(rb, "quote_currency"),
                "same_ranking_group": "true" if same_group else "false", "shared_currency_count": str(shared_count), "shared_currency_reason": shared_reason,
                "correlation_value": corr_text, "correlation_abs": f"{corr_abs:.6f}" if corr_abs is not None else "not_available",
                "correlation_state": _corr_state(corr_abs, reason), "correlation_sample_count": str(sample_count),
                "correlation_method": "pearson_log_returns_from_shared_ohlc_store", "correlation_timeframe": L15_TIMEFRAME,
                "correlation_lookback_bars": str(L15_LOOKBACK_BARS), "data_quality_reason": reason,
                "currency_overlap_score": f"{min(100.0, shared_count * 35.0):.2f}", "ranking_group_overlap_score": "100.00" if same_group else "0.00",
                "pair_diversity_risk_score": f"{max(0.0, min(100.0, pair_risk)):.2f}",
                "meaning": "candidate_pair_correlation_context_only_not_selection_not_trade", "trade_permission": "false", "entry_signal": "false", "execution": "false", "generated_utc": utc_stamp(),
            })

    threshold = l15_max_corr_abs()
    score_rows: List[Dict[str, str]] = []
    for row in candidates:
        symbol = _text(row, "symbol")
        related = [p for p in pair_rows if p["symbol_a"] == symbol or p["symbol_b"] == symbol]
        ok = [p for p in related if p["data_quality_reason"] == "ok" and p["correlation_abs"] != "not_available"]
        unavailable = [p for p in related if p["data_quality_reason"] != "ok"]
        corr_values = [_num(p["correlation_abs"]) for p in ok]
        max_corr = max(corr_values) if corr_values else None
        avg_corr = sum(corr_values) / len(corr_values) if corr_values else None
        max_pair = "not_available"
        if ok and max_corr is not None:
            worst = max(ok, key=lambda p: _num(p["correlation_abs"]))
            max_pair = worst["symbol_b"] if worst["symbol_a"] == symbol else worst["symbol_a"]
        shared_hits = sum(1 for p in related if _int(p["shared_currency_count"]) > 0)
        same_group_hits = sum(1 for p in related if p["same_ranking_group"] == "true")
        diversity = 100.0 - ((max_corr * 45.0) if max_corr is not None else 20.0) - min(25.0, shared_hits * 3.0) - min(20.0, same_group_hits * 5.0) - min(20.0, len(unavailable) * 2.0)
        diversity = max(0.0, min(100.0, diversity))
        reason = "none"
        if max_corr is None:
            reason = "correlation_unavailable_degraded"
        elif max_corr > threshold:
            reason = "above_untested_default_corr_threshold"
        elif shared_hits > 0:
            reason = "currency_overlap_warning"
        if capped and reason == "none":
            reason = "candidate_pool_capped_for_budget"
        score_rows.append({
            "candidate_pool_rank": _text(row, "candidate_pool_rank"), "symbol": symbol, "canonical_symbol": _text(row, "canonical_symbol", symbol),
            "ranking_group": _text(row, "ranking_group"), "ranking_group_slug": _text(row, "ranking_group_slug", _safe_slug(_text(row, "ranking_group"))),
            "asset_class": _text(row, "asset_class"), "market_group": _text(row, "market_group"), "market_segment": _text(row, "market_segment"),
            "l14_candidate_priority_score": _text(row, "l14_candidate_priority_score"), "leader_or_backup": _text(row, "leader_or_backup"), "candidate_source": _text(row, "candidate_source"),
            "base_currency": _text(meta.get(symbol, {}), "base_currency"), "quote_currency": _text(meta.get(symbol, {}), "quote_currency"),
            "pair_count": str(len(related)), "corr_pair_count": str(len(ok)), "corr_unavailable_count": str(len(unavailable)),
            "corr_to_pool_max_abs": f"{max_corr:.6f}" if max_corr is not None else "not_available", "corr_to_pool_avg_abs": f"{avg_corr:.6f}" if avg_corr is not None else "not_available",
            "corr_pair_max_symbol": max_pair, "correlation_state": _corr_state(max_corr, "ok" if max_corr is not None else "missing_ohlc"),
            "correlation_reject_reason": reason, "currency_overlap_score": f"{min(100.0, shared_hits * 8.0):.2f}",
            "ranking_group_overlap_score": f"{min(100.0, same_group_hits * 20.0):.2f}", "diversity_score": f"{diversity:.2f}", "diversity_state": _diversity_state(diversity),
            "correlation_method": "pearson_log_returns_from_shared_ohlc_store", "correlation_timeframe": L15_TIMEFRAME, "correlation_lookback_bars": str(L15_LOOKBACK_BARS),
            "correlation_sample_count": str(max((_int(p["correlation_sample_count"]) for p in ok), default=0)), "correlation_confidence": "usable" if ok else "degraded_unavailable",
            "l16_constraint_hint": "constrained" if reason != "none" or diversity < 55 else "clean_context", "meaning": "correlation_diversity_scoring_only_not_global_top10_not_trade_permission",
            "selection_runtime": "false", "trade_permission": "false", "entry_signal": "false", "execution": "false", "generated_utc": utc_stamp(),
        })

    score_rows.sort(key=lambda r: (-_num(r["diversity_score"]), _int(r["candidate_pool_rank"]), r["symbol"]))
    grouped: Dict[str, List[Dict[str, str]]] = {}
    for row in score_rows:
        grouped.setdefault(row["ranking_group"], []).append(row)

    group_rows: List[Dict[str, str]] = []
    for group, members in grouped.items():
        member_symbols = {m["symbol"] for m in members}
        group_pairs = [p for p in pair_rows if p["symbol_a"] in member_symbols or p["symbol_b"] in member_symbols]
        ok = [p for p in group_pairs if p["data_quality_reason"] == "ok" and p["correlation_abs"] != "not_available"]
        corr_values = [_num(p["correlation_abs"]) for p in ok]
        scores = [_num(m["diversity_score"]) for m in members]
        group_diversity = sum(scores) / len(scores) if scores else 0.0
        group_rows.append({
            "ranking_group": group, "ranking_group_slug": members[0]["ranking_group_slug"], "candidate_count": str(len(members)),
            "leader_count": str(sum(1 for m in members if m["leader_or_backup"] == "leader")), "backup_count": str(sum(1 for m in members if m["leader_or_backup"] == "backup")),
            "max_pair_corr_abs": f"{max(corr_values):.6f}" if corr_values else "not_available", "avg_pair_corr_abs": f"{(sum(corr_values)/len(corr_values)):.6f}" if corr_values else "not_available",
            "high_corr_pair_count": str(sum(1 for p in ok if _num(p["correlation_abs"]) > threshold)),
            "correlation_unavailable_pair_count": str(sum(1 for p in group_pairs if p["data_quality_reason"] != "ok")),
            "currency_overlap_pair_count": str(sum(1 for p in group_pairs if _int(p["shared_currency_count"]) > 0)),
            "group_diversity_score": f"{group_diversity:.2f}", "group_diversity_state": _diversity_state(group_diversity),
            "top_candidate": sorted(members, key=lambda m: _int(m["candidate_pool_rank"]))[0]["symbol"],
            "meaning": "ranking_group_diversity_context_only_not_selection_not_trade", "trade_permission": "false", "entry_signal": "false", "execution": "false", "generated_utc": utc_stamp(),
        })
    group_rows.sort(key=lambda r: (-_num(r["group_diversity_score"]), r["ranking_group"]))
    return score_rows, pair_rows, group_rows, scanned_count, capped


def _threshold_lines() -> List[str]:
    return [
        f"max_allowed_pairwise_correlation_abs={l15_max_corr_abs():.2f}",
        "threshold_status=untested_default_not_holy_law",
        f"threshold_source={l15_threshold_source()}",
        f"candidate_pool_cap={l15_max_candidates()}",
        f"ohlc_scan_file_limit={l15_max_ohlc_file_scan()}",
    ]


def _manifest(payload: str, row_count: int) -> str:
    return "\n".join([
        "schema_name=l15_correlation_diversity_manifest", "schema_version=2", "layer_id=15", "layer_name=Layer 15 - Correlation / Diversity Selection",
        f"owner={L15_OWNER}", f"authority={L15_AUTHORITY}", f"row_count={row_count}", f"payload_checksum={payload_checksum(payload.splitlines())}",
        *_threshold_lines(),
        "selection_runtime=false", "trade_permission=false", "entry_signal=false", "execution=false", f"generated_utc={utc_stamp()}", f"generated_unix={unix_time()}", "",
    ])


def _summary(summary: L15PublishSummary) -> str:
    return "\n".join([
        f"schema_name={L15_SCHEMA_NAME}", "schema_version=2", f"owner_name={L15_OWNER}", "layer_id=15", "layer_name=Layer 15 - Correlation / Diversity Selection",
        f"status={summary.status}", f"reason={summary.reason}", "input_source=L14_candidate_pool+L13_selected_groups+Shared_OHLC_Store_when_available",
        f"candidate_input_count={summary.candidate_input_count}", f"candidate_pool_size={summary.candidate_pool_size}", f"candidate_scored_count={summary.candidate_scored_count}",
        f"candidate_pool_capped={summary.candidate_pool_capped}", f"candidate_pool_cap={summary.candidate_pool_cap}",
        f"pairwise_pair_count={summary.pairwise_pair_count}", f"corr_pair_count={summary.corr_pair_count}", f"high_corr_pair_count={summary.high_corr_pair_count}", f"corr_unavailable_count={summary.corr_unavailable_count}",
        f"group_count={summary.group_count}", f"max_pair_corr_abs={summary.max_pair_corr_abs}", f"top_diversity_candidate={summary.top_diversity_candidate}",
        f"ohlc_scan_file_limit={summary.ohlc_scan_file_limit}", f"ohlc_scan_file_count={summary.ohlc_scan_file_count}",
        f"write_failed_count={summary.write_failed_count}", f"output_path={summary.output_path}", f"summary_path={summary.summary_path}", f"selection_desk_summary_path={summary.selection_desk_summary_path}",
        *_threshold_lines(),
        "meaning=correlation_diversity_scoring_only_not_global_top10_not_trade_permission", "selection_runtime=false", "trade_permission=false", "entry_signal=false", "execution=false",
        f"generated_utc={utc_stamp()}", f"generated_unix={unix_time()}", "",
    ])


def _selection_text(score_rows: List[Dict[str, str]], group_rows: List[Dict[str, str]], summary: L15PublishSummary) -> str:
    lines = [
        "L15 CORRELATION / DIVERSITY SCORING", "----------------------------------------",
        f"status={summary.status}", f"reason={summary.reason}", f"candidate_input_count={summary.candidate_input_count}",
        f"candidate_pool_size={summary.candidate_pool_size}", f"candidate_scored_count={summary.candidate_scored_count}",
        f"candidate_pool_capped={summary.candidate_pool_capped}", f"pairwise_pair_count={summary.pairwise_pair_count}",
        f"corr_pair_count={summary.corr_pair_count}", f"corr_unavailable_count={summary.corr_unavailable_count}",
        *_threshold_lines(), "", "GROUP SUMMARY"
    ]
    for row in group_rows:
        lines.append(f"{row['ranking_group']} candidates={row['candidate_count']} diversity={row['group_diversity_score']} state={row['group_diversity_state']} max_corr={row['max_pair_corr_abs']} unavailable_pairs={row['correlation_unavailable_pair_count']}")
    lines.append("")
    lines.append("CANDIDATE SUMMARY")
    for row in sorted(score_rows, key=lambda r: _int(r["candidate_pool_rank"])):
        lines.append(f"#{row['candidate_pool_rank']} {row['symbol']} group={row['ranking_group']} diversity={row['diversity_score']} corr_state={row['correlation_state']} reason={row['correlation_reject_reason']} l16_hint={row['l16_constraint_hint']}")
    lines.extend(["", "selection_runtime=false", "trade_permission=false", "entry_signal=false", "execution=false", ""])
    return "\n".join(lines)


def publish_l15_correlation_diversity_selection(outbox_root: Path) -> L15PublishSummary:
    root = _root_from_outbox(outbox_root)
    l13 = outbox_root / "Layers" / "Layer_13_Dynamic_Ranking_Group_Selection"
    l14 = outbox_root / "Layers" / "Layer_14_Ranking_Group_Leader_Candidate_Pool"
    needed = [l13 / "l13_selected_ranking_groups.csv", l14 / "l14_candidate_pool.csv", l14 / "l14_candidate_pool.manifest", l14 / "l14_candidate_pool_summary.txt"]
    missing = [str(p) for p in needed if not p.exists()]
    if missing:
        return L15PublishSummary("pending", "missing_required_l15_source: " + ";".join(missing))
    try:
        l14_status = _kv(l14 / "l14_candidate_pool_summary.txt").get("status", "pending")
        if l14_status not in {"accepted", "write_degraded"}:
            return L15PublishSummary("pending" if l14_status == "pending" else "degraded", "l14_not_accepted_status=" + l14_status)
        candidates = _csv(l14 / "l14_candidate_pool.csv")
        if not candidates:
            return L15PublishSummary("pending", "l14_candidate_pool_empty")

        score_rows, pair_rows, group_rows, ohlc_scan_count, capped = _build(root, candidates)
        layer = outbox_root / "Layers" / L15_LAYER_FOLDER
        groups = layer / "RankingGroups"
        visible = _select_dir(outbox_root)
        for folder in (layer, groups, visible):
            folder.mkdir(parents=True, exist_ok=True)

        failed: List[Path] = []
        score_text = _csv_text(score_rows, SCORE_FIELDS)
        pair_text = _csv_text(pair_rows, PAIR_FIELDS)
        group_text = _csv_text(group_rows, GROUP_FIELDS)
        _write(layer / "l15_candidate_diversity_scores.csv", score_text, failed)
        _write(layer / "l15_candidate_correlation_matrix.csv", pair_text, failed)
        _write(layer / "l15_group_diversity_summary.csv", group_text, failed)
        _write(layer / "l15_correlation_diversity.manifest", _manifest(score_text + pair_text + group_text, len(score_rows)), failed)

        for row in group_rows:
            members = [r for r in score_rows if r["ranking_group"] == row["ranking_group"]]
            txt = "\n".join([
                "L15 CORRELATION / DIVERSITY BY RANKING GROUP", "----------------------------------------",
                f"ranking_group={row['ranking_group']}", f"candidate_count={row['candidate_count']}",
                f"group_diversity_score={row['group_diversity_score']}", f"group_diversity_state={row['group_diversity_state']}",
                f"max_pair_corr_abs={row['max_pair_corr_abs']}", f"correlation_unavailable_pair_count={row['correlation_unavailable_pair_count']}",
                *_threshold_lines(), "",
            ] + [f"#{m['candidate_pool_rank']} {m['symbol']} diversity={m['diversity_score']} corr_state={m['correlation_state']} reason={m['correlation_reject_reason']} l16_hint={m['l16_constraint_hint']}" for m in members] + ["selection_runtime=false", "trade_permission=false", "entry_signal=false", "execution=false", ""])
            _write(groups / (_safe_slug(row["ranking_group"]) + ".correlation.txt"), txt, failed)

        threshold = l15_max_corr_abs()
        corr_pairs = [p for p in pair_rows if p["data_quality_reason"] == "ok" and p["correlation_abs"] != "not_available"]
        corr_values = [_num(p["correlation_abs"]) for p in corr_pairs]
        status = "accepted" if corr_pairs and not capped else ("degraded" if not corr_pairs or capped else "accepted")
        reason = "l15_correlation_diversity_published"
        if not corr_pairs:
            reason = "l15_published_with_correlation_unavailable"
        if capped:
            reason = reason + ";candidate_pool_capped_for_budget"
        if ohlc_scan_count > l15_max_ohlc_file_scan():
            reason = reason + ";ohlc_scan_limited"
        if failed:
            status = "write_degraded"
            reason = "one_or_more_l15_outputs_failed"

        summary = L15PublishSummary(
            status=status,
            reason=reason,
            candidate_input_count=len(candidates),
            candidate_pool_size=len(candidates),
            candidate_scored_count=len(score_rows),
            candidate_pool_capped="true" if capped else "false",
            candidate_pool_cap=l15_max_candidates(),
            pairwise_pair_count=len(pair_rows),
            corr_pair_count=len(corr_pairs),
            high_corr_pair_count=sum(1 for p in corr_pairs if _num(p["correlation_abs"]) > threshold),
            corr_unavailable_count=sum(1 for p in pair_rows if p["data_quality_reason"] != "ok"),
            group_count=len(group_rows),
            write_failed_count=len(failed),
            top_diversity_candidate=score_rows[0]["symbol"] if score_rows else "not_available",
            max_pair_corr_abs=f"{max(corr_values):.6f}" if corr_values else "not_available",
            output_path=str(layer / "l15_candidate_diversity_scores.csv"),
            summary_path=str(layer / "l15_correlation_diversity_summary.txt"),
            selection_desk_summary_path=str(visible / "00_Correlation_Diversity_Summary.txt"),
            ohlc_scan_file_limit=l15_max_ohlc_file_scan(),
            ohlc_scan_file_count=ohlc_scan_count,
            threshold_source=l15_threshold_source(),
            max_allowed_pairwise_correlation_abs=f"{threshold:.2f}",
        )
        _write(layer / "l15_correlation_diversity_summary.txt", _summary(summary), failed)
        _write(visible / "00_Correlation_Diversity_Summary.csv", score_text, failed)
        _write(visible / "00_Correlation_Diversity_Summary.txt", _selection_text(score_rows, group_rows, summary), failed)
        return summary
    except Exception as exc:
        return L15PublishSummary("exception", f"{type(exc).__name__}: {exc}")