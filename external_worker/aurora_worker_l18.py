from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Sequence, Tuple
import re

from aurora_worker_io import WorkerPaths, atomic_write_text, read_text, unix_time, utc_stamp

SELECTION_DEEP_START = "========== SELECTION-ONLY DEEP EVIDENCE START =========="
SELECTION_DEEP_END = "========== SELECTION-ONLY DEEP EVIDENCE END =========="
L18_START = "----- L18 RAW OHLC BAR PACK START -----"
L18_END = "----- L18 RAW OHLC BAR PACK END -----"

# L18 reads existing Runtime 1 Shared OHLC Store seed files only.
# These are the active L18 display caps from blueprint/03_LOGICAL_LAYER_BLUEPRINT.md.
DISPLAY_BARS: Dict[str, int] = {
    "M1": 300,
    "M5": 300,
    "M15": 350,
    "M30": 250,
    "H1": 300,
    "H4": 200,
    "D1": 250,
    "W1": 104,
}
RANKED_DOSSIER_RE = re.compile(r"^\d{2}_(.+)\.txt$")


@dataclass(frozen=True)
class L18PublishSummary:
    status: str
    reason: str
    selected_dossiers_seen: int = 0
    selected_dossiers_decorated: int = 0
    selected_dossiers_missing_symbol: int = 0
    source_files_expected: int = 0
    source_files_found: int = 0
    source_files_missing: int = 0
    source_files_partial: int = 0
    source_decode_errors: int = 0
    rows_printed_to_dossiers: int = 0
    write_failed_count: int = 0
    m1_completed_symbols: int = 0
    m1_partial_symbols: int = 0
    m1_missing_symbols: int = 0
    m5_completed_symbols: int = 0
    m5_partial_symbols: int = 0
    m5_missing_symbols: int = 0
    m15_completed_symbols: int = 0
    m15_partial_symbols: int = 0
    m15_missing_symbols: int = 0
    m30_completed_symbols: int = 0
    m30_partial_symbols: int = 0
    m30_missing_symbols: int = 0
    h1_completed_symbols: int = 0
    h1_partial_symbols: int = 0
    h1_missing_symbols: int = 0
    h4_completed_symbols: int = 0
    h4_partial_symbols: int = 0
    h4_missing_symbols: int = 0
    d1_completed_symbols: int = 0
    d1_partial_symbols: int = 0
    d1_missing_symbols: int = 0
    w1_completed_symbols: int = 0
    w1_partial_symbols: int = 0
    w1_missing_symbols: int = 0
    selected_route_dossiers_seen: int = 0
    selected_route_dossiers_decorated: int = 0
    selected_unique_symbols_seen: int = 0
    selected_duplicate_route_copies: int = 0
    latest_bar_age_max_seconds: int = -1
    freshness_fresh_count: int = 0
    freshness_aging_count: int = 0
    freshness_stale_count: int = 0
    freshness_unknown_count: int = 0
    freshness_status: str = "unknown"
    freshness_policy: str = "derived_from_existing_shared_ohlc_seed_latest_bar_time_read_once"
    status_path: str = "not_available"
    board_path: str = "not_available"
    layer_folder: str = "not_available"


EMPTY_L18_SUMMARY = L18PublishSummary("pending", "l18_not_run")


@dataclass(frozen=True)
class OhlcSeedPacket:
    path: Path
    status: str
    meta: Dict[str, str]
    rows: List[List[str]]
    decode_error: bool = False
    error_text: str = ""


def _account_root(root: Path) -> Path:
    return WorkerPaths.from_root(root).outbox.parents[2]


def _selection_desk(root: Path) -> Path:
    return _account_root(root) / "Selection Desk"


def _shared_ohlc_symbols(root: Path) -> Path:
    return _account_root(root).parent / "Shared Market Data" / "OHLC Store" / "Symbols"


def _layer_folder(root: Path) -> Path:
    return WorkerPaths.from_root(root).outbox / "Layers" / "Layer_18_Selected_Raw_OHLC_Bar_Pack"


def _write(path: Path, text: str, failed: List[Path]) -> bool:
    ok = atomic_write_text(path, text)
    if not ok:
        failed.append(path)
    return ok


def _selected_dossier_paths(root: Path) -> List[Path]:
    desk = _selection_desk(root)
    candidates: List[Path] = []
    candidates.extend((desk / "01_Global" / "Top_10").glob("*.txt"))
    candidates.extend((desk / "02_Asset_Classes").glob("*/01_Top_5_All_*/*.txt"))
    candidates.extend((desk / "02_Asset_Classes").glob("*/02_Groups/*/*.txt"))

    unique: List[Path] = []
    seen = set()
    for path in candidates:
        if path.name.startswith("00_") or not RANKED_DOSSIER_RE.match(path.name):
            continue
        key = str(path)
        if key in seen:
            continue
        seen.add(key)
        unique.append(path)
    return sorted(unique)


def _symbol_from_dossier(path: Path) -> str:
    match = RANKED_DOSSIER_RE.match(path.name)
    return match.group(1) if match else ""


def _ohlc_path(root: Path, symbol: str, timeframe: str) -> Path:
    return _shared_ohlc_symbols(root) / symbol / f"{timeframe}.seed.csv"


def _parse_header_and_rows(text: str) -> Tuple[Dict[str, str], List[List[str]]]:
    meta: Dict[str, str] = {}
    rows: List[List[str]] = []
    for raw in text.replace("\r\n", "\n").splitlines():
        line = raw.strip()
        if not line:
            continue
        if line.startswith("#"):
            payload = line[1:]
            if "=" in payload:
                key, value = payload.split("=", 1)
                meta[key.strip()] = value.strip()
            continue
        if line.startswith("bar_time,"):
            continue
        parts = [p.strip() for p in line.split(",")]
        if len(parts) >= 8:
            rows.append(parts[:8])
    return meta, rows


def _read_seed_packet(root: Path, symbol: str, timeframe: str) -> OhlcSeedPacket:
    path = _ohlc_path(root, symbol, timeframe)
    if not path.exists():
        return OhlcSeedPacket(path=path, status="missing", meta={}, rows=[])
    try:
        meta, rows = _parse_header_and_rows(read_text(path))
        return OhlcSeedPacket(path=path, status="present", meta=meta, rows=rows)
    except Exception as exc:
        safe_error = str(exc).replace("\n", " ").replace("\r", " ")
        return OhlcSeedPacket(path=path, status="decode_error", meta={}, rows=[], decode_error=True, error_text=f"{type(exc).__name__}:{safe_error}")


def _decode_price(raw_value: str, point: float | None, digits: int | None) -> str:
    try:
        value = int(float(raw_value))
        if point is None or point <= 0:
            return str(value)
        price = value * point
        return f"{price:.{digits}f}" if digits is not None and digits >= 0 else f"{price:.8f}".rstrip("0").rstrip(".")
    except ValueError:
        return "decode_error"


def _latest_age_seconds_from_rows(rows: Sequence[Sequence[str]]) -> int:
    if not rows:
        return -1
    try:
        bar_time = int(float(rows[-1][0]))
        if bar_time <= 0:
            return -1
        return max(0, unix_time() - bar_time)
    except Exception:
        return -1


def _render_timeframe_from_packet(packet: OhlcSeedPacket, timeframe: str, requested: int) -> Tuple[str, str, int, bool, int]:
    if packet.status == "missing":
        return (f"[{timeframe}] source_status=missing path={packet.path}\n", "missing", 0, False, -1)
    if packet.status == "decode_error":
        return (f"[{timeframe}] source_status=decode_error error={packet.error_text} path={packet.path}\n", "decode_error", 0, True, -1)
    try:
        point_raw = packet.meta.get("point", "")
        digits_raw = packet.meta.get("digits", "")
        point = float(point_raw) if point_raw else None
        digits = int(float(digits_raw)) if digits_raw else None
        selected = packet.rows[-requested:] if len(packet.rows) > requested else packet.rows
        selected = list(reversed(selected))
        status = "complete" if len(selected) >= requested else "partial"
        price_fields_label = "open|high|low|close" if point is not None and point > 0 else "open_i|high_i|low_i|close_i"
        price_policy = "decoded_price" if point is not None and point > 0 else "raw_integer_points_no_point_metadata"
        lines = [
            f"[{timeframe}] source_status={status} rows_shown={len(selected)} requested_display_bars={requested} source_rows_available={len(packet.rows)} price_policy={price_policy} source_path={packet.path}",
            f"idx | broker_time_unix | {price_fields_label} | tick_volume | spread | real_volume_if_available | bar_complete_flag",
        ]
        decode_error = False
        for idx, row in enumerate(selected):
            bar_time, open_i, high_i, low_i, close_i, tick_volume, spread, real_volume = row
            decoded = [_decode_price(v, point, digits) for v in (open_i, high_i, low_i, close_i)]
            if "decode_error" in decoded:
                decode_error = True
            lines.append(f"{idx} | {bar_time} | {decoded[0]} | {decoded[1]} | {decoded[2]} | {decoded[3]} | {tick_volume} | {spread} | {real_volume} | closed_seed_contract")
        lines.append("")
        return ("\n".join(lines), status, len(selected), decode_error, _latest_age_seconds_from_rows(packet.rows))
    except Exception as exc:
        safe_error = str(exc).replace("\n", " ").replace("\r", " ")
        return (f"[{timeframe}] source_status=decode_error error={type(exc).__name__}:{safe_error} path={packet.path}\n", "decode_error", 0, True, -1)


def _extract_block(text: str, start_marker: str, end_marker: str) -> str:
    normalized = (text or "").replace("\r\n", "\n")
    start = normalized.find(start_marker)
    if start < 0:
        return ""
    end = normalized.find(end_marker, start)
    if end < 0:
        return ""
    end += len(end_marker)
    return normalized[start:end].strip() + "\n"


def _replace_l18_in_deep_section(existing_text: str, l18_block: str) -> str:
    normalized = (existing_text or "").replace("\r\n", "\n").rstrip()
    deep = _extract_block(normalized, SELECTION_DEEP_START, SELECTION_DEEP_END)
    if not deep:
        deep = "\n".join([SELECTION_DEEP_START, SELECTION_DEEP_END]) + "\n"
        base = normalized
    else:
        base = normalized.replace(deep.strip(), "").rstrip()
    old_l18 = _extract_block(deep, L18_START, L18_END)
    if old_l18:
        deep = deep.replace(old_l18.strip(), l18_block.strip())
    else:
        deep = deep.replace(SELECTION_DEEP_END, l18_block.strip() + "\n\n" + SELECTION_DEEP_END)
    return base.rstrip() + "\n\n" + deep.strip() + "\n"


def _empty_tf_counts() -> Dict[str, Dict[str, int]]:
    return {tf: {"complete": 0, "partial": 0, "missing": 0, "decode_error": 0} for tf in DISPLAY_BARS}


def _display_profile_csv(sep: str = ",") -> str:
    return sep.join(f"{tf}={bars}" for tf, bars in DISPLAY_BARS.items())


def _build_l18_block(symbol: str, rendered_sections: Sequence[str], tf_statuses: Dict[str, str], rows_printed: int) -> str:
    lines = [
        L18_START,
        "Layer:                  L18 Selected Raw OHLC Bar Pack",
        "Scope:                  Selection copied dossier only",
        "Source Owner:           Runtime 1 Shared OHLC Raw Storage Owner",
        "Source Policy:          read_existing_shared_ohlc_seed_files_only",
        f"Display Profile:        {_display_profile_csv(', ')}",
        "Price Policy:           decoded when point metadata exists; otherwise raw integer points",
        "Bar Complete Policy:    closed_seed_contract_from_shared_ohlc_owner_not_live_forming_bar_claim",
        "CopyRates By L18:       false",
        "Private OHLC Cache:     false",
        "Base Dossier Touched:   false",
        f"Symbol:                 {symbol}",
        f"Rows Printed:           {rows_printed}",
        "",
        "Mini Overview",
    ]
    for tf, requested in DISPLAY_BARS.items():
        lines.append(f"{tf}: {tf_statuses.get(tf, 'missing')} | display_bars={requested}")
    lines.extend(["", "RAW OHLC DATA"])
    lines.extend(rendered_sections)
    lines.append(L18_END)
    return "\n".join(lines) + "\n"


def _tf_summary_lines(summary: L18PublishSummary) -> List[str]:
    denom = summary.selected_dossiers_seen
    return [
        f"M1:   completed_symbols={summary.m1_completed_symbols}/{denom} partial_symbols={summary.m1_partial_symbols} missing_symbols={summary.m1_missing_symbols}",
        f"M5:   completed_symbols={summary.m5_completed_symbols}/{denom} partial_symbols={summary.m5_partial_symbols} missing_symbols={summary.m5_missing_symbols}",
        f"M15:  completed_symbols={summary.m15_completed_symbols}/{denom} partial_symbols={summary.m15_partial_symbols} missing_symbols={summary.m15_missing_symbols}",
        f"M30:  completed_symbols={summary.m30_completed_symbols}/{denom} partial_symbols={summary.m30_partial_symbols} missing_symbols={summary.m30_missing_symbols}",
        f"H1:   completed_symbols={summary.h1_completed_symbols}/{denom} partial_symbols={summary.h1_partial_symbols} missing_symbols={summary.h1_missing_symbols}",
        f"H4:   completed_symbols={summary.h4_completed_symbols}/{denom} partial_symbols={summary.h4_partial_symbols} missing_symbols={summary.h4_missing_symbols}",
        f"D1:   completed_symbols={summary.d1_completed_symbols}/{denom} partial_symbols={summary.d1_partial_symbols} missing_symbols={summary.d1_missing_symbols}",
        f"W1:   completed_symbols={summary.w1_completed_symbols}/{denom} partial_symbols={summary.w1_partial_symbols} missing_symbols={summary.w1_missing_symbols}",
    ]


def _board_text(summary: L18PublishSummary) -> str:
    lines = [
        "L18 — SELECTED RAW OHLC BAR PACK",
        "--------------------------------------------------",
        "Purpose:                Selected raw OHLC from Shared OHLC Store",
        "Scope:                  Canonical Selection Desk copied dossiers only",
        f"Display Profile:        {_display_profile_csv(', ')}",
        "Source Owner:           Runtime 1 Shared OHLC Raw Storage Owner",
        "CopyRates By L18:       FALSE",
        "Private OHLC Cache:     FALSE",
        "Base Dossiers Touched:  FALSE",
        "",
        "Selection Coverage",
        f"Selected Dossiers Seen:       {summary.selected_dossiers_seen}",
        f"Selected Dossiers Decorated:  {summary.selected_dossiers_decorated}",
        f"Selected Missing Symbol:      {summary.selected_dossiers_missing_symbol}",
        f"Unique Symbols Seen:          {summary.selected_unique_symbols_seen}",
        f"Duplicate Route Copies:       {summary.selected_duplicate_route_copies}",
        "",
        "OHLC Source Coverage",
    ]
    lines.extend(_tf_summary_lines(summary))
    lines.extend([
        "",
        "Latest L18 Update",
        f"Status:                       {summary.status}",
        f"Reason:                       {summary.reason}",
        f"Source Files Found:           {summary.source_files_found} / {summary.source_files_expected}",
        f"Source Files Missing:         {summary.source_files_missing}",
        f"Source Files Partial:         {summary.source_files_partial}",
        f"Source Decode Errors:         {summary.source_decode_errors}",
        f"Rows Printed To Dossiers:     {summary.rows_printed_to_dossiers}",
        f"Write Failed Count:           {summary.write_failed_count}",
        f"Freshness Status:             {summary.freshness_status}",
        f"Latest Bar Age Max Seconds:   {summary.latest_bar_age_max_seconds}",
        f"Freshness Counts:             fresh={summary.freshness_fresh_count} aging={summary.freshness_aging_count} stale={summary.freshness_stale_count} unknown={summary.freshness_unknown_count}",
        f"Generated UTC:                {utc_stamp()}",
        "",
    ])
    return "\n".join(lines)


def _status_text(summary: L18PublishSummary) -> str:
    lines = [
        "schema_name=l18_selected_raw_ohlc_bar_pack_status",
        "schema_version=3",
        f"status={summary.status}",
        f"reason={summary.reason}",
        "scope=canonical_selection_shortcut_dossiers_only",
        "source_owner=Runtime 1 Shared OHLC Raw Storage Owner",
        "source_policy=read_existing_shared_ohlc_seed_files_only",
        f"display_profile={_display_profile_csv()}",
        "bar_complete_policy=closed_seed_contract_from_shared_ohlc_owner_not_live_forming_bar_claim",
        "copyrates_by_l18=false",
        "private_ohlc_cache=false",
        "base_dossiers_touched=false",
        f"selected_dossiers_seen={summary.selected_dossiers_seen}",
        f"selected_route_dossiers_seen={summary.selected_route_dossiers_seen}",
        f"selected_route_dossiers_decorated={summary.selected_route_dossiers_decorated}",
        f"selected_unique_symbols_seen={summary.selected_unique_symbols_seen}",
        f"selected_duplicate_route_copies={summary.selected_duplicate_route_copies}",
        f"selected_dossiers_decorated={summary.selected_dossiers_decorated}",
        f"selected_dossiers_missing_symbol={summary.selected_dossiers_missing_symbol}",
        f"source_files_expected={summary.source_files_expected}",
        f"source_files_found={summary.source_files_found}",
        f"source_files_missing={summary.source_files_missing}",
        f"source_files_partial={summary.source_files_partial}",
        f"source_decode_errors={summary.source_decode_errors}",
        f"rows_printed_to_dossiers={summary.rows_printed_to_dossiers}",
        f"write_failed_count={summary.write_failed_count}",
        f"latest_bar_age_max_seconds={summary.latest_bar_age_max_seconds}",
        f"freshness_fresh_count={summary.freshness_fresh_count}",
        f"freshness_aging_count={summary.freshness_aging_count}",
        f"freshness_stale_count={summary.freshness_stale_count}",
        f"freshness_unknown_count={summary.freshness_unknown_count}",
        f"freshness_status={summary.freshness_status}",
        f"freshness_policy={summary.freshness_policy}",
        f"m1_completed_symbols={summary.m1_completed_symbols}",
        f"m1_partial_symbols={summary.m1_partial_symbols}",
        f"m1_missing_symbols={summary.m1_missing_symbols}",
        f"m5_completed_symbols={summary.m5_completed_symbols}",
        f"m5_partial_symbols={summary.m5_partial_symbols}",
        f"m5_missing_symbols={summary.m5_missing_symbols}",
        f"m15_completed_symbols={summary.m15_completed_symbols}",
        f"m15_partial_symbols={summary.m15_partial_symbols}",
        f"m15_missing_symbols={summary.m15_missing_symbols}",
        f"m30_completed_symbols={summary.m30_completed_symbols}",
        f"m30_partial_symbols={summary.m30_partial_symbols}",
        f"m30_missing_symbols={summary.m30_missing_symbols}",
        f"h1_completed_symbols={summary.h1_completed_symbols}",
        f"h1_partial_symbols={summary.h1_partial_symbols}",
        f"h1_missing_symbols={summary.h1_missing_symbols}",
        f"h4_completed_symbols={summary.h4_completed_symbols}",
        f"h4_partial_symbols={summary.h4_partial_symbols}",
        f"h4_missing_symbols={summary.h4_missing_symbols}",
        f"d1_completed_symbols={summary.d1_completed_symbols}",
        f"d1_partial_symbols={summary.d1_partial_symbols}",
        f"d1_missing_symbols={summary.d1_missing_symbols}",
        f"w1_completed_symbols={summary.w1_completed_symbols}",
        f"w1_partial_symbols={summary.w1_partial_symbols}",
        f"w1_missing_symbols={summary.w1_missing_symbols}",
        f"status_path={summary.status_path}",
        f"board_path={summary.board_path}",
        "trade_permission=false",
        "entry_signal=false",
        "execution=false",
        f"generated_utc={utc_stamp()}",
        f"generated_unix={unix_time()}",
        "",
    ]
    return "\n".join(lines)


def _freshness_bucket(tf: str, age_seconds: int) -> str:
    caps = {
        "M1": (180, 600),
        "M5": (900, 1800),
        "M15": (1800, 3600),
        "M30": (3600, 7200),
        "H1": (7200, 14400),
        "H4": (21600, 43200),
        "D1": (172800, 345600),
        "W1": (1209600, 2419200),
    }
    fresh_cap, aging_cap = caps.get(tf, (1800, 3600))
    if age_seconds < 0:
        return "unknown"
    if age_seconds <= fresh_cap:
        return "fresh"
    if age_seconds <= aging_cap:
        return "aging"
    return "stale"


def _tf_summary_kwargs(tf_counts: Dict[str, Dict[str, int]]) -> Dict[str, int]:
    kwargs: Dict[str, int] = {}
    for tf in DISPLAY_BARS:
        prefix = tf.lower()
        counts = tf_counts[tf]
        kwargs[f"{prefix}_completed_symbols"] = counts["complete"]
        kwargs[f"{prefix}_partial_symbols"] = counts["partial"] + counts["decode_error"]
        kwargs[f"{prefix}_missing_symbols"] = counts["missing"]
    return kwargs


def publish_l18_selected_raw_ohlc_bar_pack(root: Path) -> L18PublishSummary:
    failed: List[Path] = []
    layer_dir = _layer_folder(root)
    layer_dir.mkdir(parents=True, exist_ok=True)
    status_path = layer_dir / "l18_status.txt"
    board_path = _selection_desk(root) / "91_Layer_Summaries" / "L18_Selected_Raw_OHLC_Bar_Pack" / "00_L18_Board_Overview.txt"

    dossiers = _selected_dossier_paths(root)
    tf_counts = _empty_tf_counts()
    decorated = 0
    missing_symbol = 0
    route_seen = len(dossiers)
    route_decorated = 0
    unique_symbols = set()
    freshness = {"fresh": 0, "aging": 0, "stale": 0, "unknown": 0}
    latest_max_age = -1
    source_expected = len(dossiers) * len(DISPLAY_BARS)
    source_found = 0
    source_missing = 0
    source_partial = 0
    decode_errors = 0
    rows_total = 0

    for dossier in dossiers:
        symbol = _symbol_from_dossier(dossier)
        if not symbol:
            missing_symbol += 1
            continue

        unique_symbols.add(symbol)
        rendered: List[str] = []
        tf_statuses: Dict[str, str] = {}
        dossier_rows = 0
        for tf, requested in DISPLAY_BARS.items():
            packet = _read_seed_packet(root, symbol, tf)
            section, status, rows, decode_error, age = _render_timeframe_from_packet(packet, tf, requested)
            rendered.append(section)
            tf_statuses[tf] = status
            dossier_rows += rows

            if status == "missing":
                source_missing += 1
                tf_counts[tf]["missing"] += 1
            else:
                source_found += 1
                if status == "complete":
                    tf_counts[tf]["complete"] += 1
                elif status == "partial":
                    source_partial += 1
                    tf_counts[tf]["partial"] += 1
                else:
                    tf_counts[tf]["decode_error"] += 1

            if decode_error:
                decode_errors += 1

            bucket = _freshness_bucket(tf, age)
            freshness[bucket] += 1
            if age > latest_max_age:
                latest_max_age = age

        try:
            existing = read_text(dossier)
            updated = _replace_l18_in_deep_section(existing, _build_l18_block(symbol, rendered, tf_statuses, dossier_rows))
            if _write(dossier, updated, failed):
                decorated += 1
                route_decorated += 1
                rows_total += dossier_rows
        except Exception:
            failed.append(dossier)

    hard_errors = bool(failed) or source_missing > 0 or decode_errors > 0 or decorated == 0
    history_limited = source_partial > 0
    freshness_bad = freshness["stale"] > 0 or freshness["unknown"] > 0
    if not dossiers:
        status = "pending"
    elif hard_errors:
        status = "partial"
    elif history_limited or freshness_bad:
        status = "degraded"
    else:
        status = "accepted"

    if status == "accepted":
        reason = "selected_dossiers_decorated_with_contract_timeframes_and_freshness_proof"
    elif status == "degraded":
        reason = "selected_dossiers_decorated_with_limited_history_or_stale_freshness"
    elif status == "pending":
        reason = "no_canonical_selected_dossiers_found"
    else:
        reason = "one_or_more_sources_missing_invalid_or_write_failed"

    freshness_sample_count = sum(freshness.values())
    if freshness_sample_count == 0:
        freshness_status = "unknown"
    elif freshness["unknown"] and not (freshness["fresh"] or freshness["aging"] or freshness["stale"]):
        freshness_status = "unknown"
    elif freshness["stale"] and not (freshness["fresh"] or freshness["aging"]):
        freshness_status = "stale"
    elif sum(1 for v in freshness.values() if v > 0) > 1:
        freshness_status = "mixed"
    elif freshness["fresh"] > 0:
        freshness_status = "fresh"
    else:
        freshness_status = "aging"

    summary = L18PublishSummary(
        status=status,
        reason=reason,
        selected_dossiers_seen=len(dossiers),
        selected_dossiers_decorated=decorated,
        selected_dossiers_missing_symbol=missing_symbol,
        source_files_expected=source_expected,
        source_files_found=source_found,
        source_files_missing=source_missing,
        source_files_partial=source_partial,
        source_decode_errors=decode_errors,
        rows_printed_to_dossiers=rows_total,
        write_failed_count=len(failed),
        selected_route_dossiers_seen=route_seen,
        selected_route_dossiers_decorated=route_decorated,
        selected_unique_symbols_seen=len(unique_symbols),
        selected_duplicate_route_copies=max(0, route_seen - len(unique_symbols)),
        latest_bar_age_max_seconds=latest_max_age,
        freshness_fresh_count=freshness["fresh"],
        freshness_aging_count=freshness["aging"],
        freshness_stale_count=freshness["stale"],
        freshness_unknown_count=freshness["unknown"],
        freshness_status=freshness_status,
        freshness_policy="derived_from_existing_shared_ohlc_seed_latest_bar_time_read_once",
        status_path=str(status_path),
        board_path=str(board_path),
        layer_folder=str(layer_dir),
        **_tf_summary_kwargs(tf_counts),
    )
    _write(status_path, _status_text(summary), failed)
    _write(board_path, _board_text(summary), failed)
    return summary
