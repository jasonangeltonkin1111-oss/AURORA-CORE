from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Iterable, List, Tuple
import csv
import io

from aurora_worker_io import atomic_write_text, payload_checksum, read_text, utc_stamp, unix_time
from aurora_worker_l9_boundary import calculate_boundary_quality, weighted_boundary_quality
from aurora_worker_l9_contract import (
    L9_AUTHORITY,
    L9_INPUT_MANIFEST_NAME,
    L9_INPUT_NAME,
    L9_JOB_TYPE,
    L9_LAYER_FOLDER,
    L9_LAYER_NAME,
    L9_MANIFEST_NAME,
    L9_MODEL_VERSION,
    L9_OUTPUT_FIELDS,
    L9_OWNER,
    L9_POLICY,
    L9_RANKED_NAME,
    L9_SCORE_WEIGHTS,
    L9_SOURCE_OWNER,
    L9_SYMBOL_RANK_FILENAME_MODE,
    L9_SYMBOL_RANK_FOLDER,
    L9_TF_WEIGHTS,
    L9_TOP20_NAME,
)
from aurora_worker_l9_event_zone import classify_l9_event_zone
from aurora_worker_l9_price_basis import resolve_l9_price_basis
from aurora_worker_l9_room import calculate_room_profile
from aurora_worker_l9_tf_location import calculate_tf_location, weighted_location_score
from aurora_worker_l9_windows import L9WindowPacket, load_l9_window_packet

LOOKBACKS = {"M15": 80, "H1": 80, "H4": 42, "D1": 30}


@dataclass
class L9FinalSummary:
    status: str
    reason: str
    input_count: int = 0
    row_count: int = 0
    ranked_count: int = 0
    ranked_partial_count: int = 0
    ranked_risk_review_count: int = 0
    not_rankable_quality_count: int = 0
    elite_count: int = 0
    strong_count: int = 0
    acceptable_count: int = 0
    weak_count: int = 0
    low_attention_count: int = 0
    near_high_event_zone_count: int = 0
    near_low_event_zone_count: int = 0
    midrange_low_attention_count: int = 0
    compression_at_boundary_count: int = 0
    symbol_rank_files_written: int = 0
    symbol_rank_files_actual: int = 0
    symbol_rank_filename_mode: str = L9_SYMBOL_RANK_FILENAME_MODE
    payload_checksum: str = "not_available"
    ranked_csv_path: str = "not_available"
    manifest_path: str = "not_available"
    top20_path: str = "not_available"
    symbol_rank_folder_path: str = "not_available"


def _safe_float(value: object, default: float = 0.0) -> float:
    try:
        text = "" if value is None else str(value).strip()
        if text == "" or text.lower() in {"nan", "inf", "-inf", "not_available", "pending", "partial"}:
            return default
        return float(text)
    except (TypeError, ValueError):
        return default


def _safe_text(row: Dict[str, str], key: str, default: str = "not_available") -> str:
    value = row.get(key, default)
    return default if value is None or str(value).strip() == "" else str(value).strip()


def _format(value: object) -> str:
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, float):
        return f"{value:.6f}"
    return str(value).replace("\r", " ").replace("\n", " ").replace(",", "_")


def _join_reason(parts: Iterable[str]) -> str:
    clean: List[str] = []
    seen = set()
    for raw in parts:
        part = str(raw or "").replace("\r", " ").replace("\n", " ").strip()
        if not part or part in seen:
            continue
        seen.add(part)
        clean.append(part)
        if len(clean) >= 24:
            break
    text = ";".join(clean) if clean else "not_available"
    return text[:900]


def _sanitize_path_part(value: str) -> str:
    safe = str(value).strip() or "unknown"
    for ch in ['\\', '/', ':', '*', '?', '"', '<', '>', '|', ' ']:
        safe = safe.replace(ch, "_")
    return safe


def _symbol_checksum(symbol: str) -> str:
    return payload_checksum([str(symbol).strip() or "unknown"])


def _symbol_rank_filename(symbol: str) -> str:
    return f"{_sanitize_path_part(symbol)}__{_symbol_checksum(symbol)}.txt"


def _layer_dir(outbox: Path) -> Path:
    return outbox / "Layers" / L9_LAYER_FOLDER


def _read_csv(path: Path) -> Tuple[List[Dict[str, str]], str]:
    if not path.exists():
        return [], "not_available"
    text = read_text(path)
    rows = list(csv.DictReader(io.StringIO(text)))
    checksum = payload_checksum([line for line in text.replace("\r\n", "\n").splitlines() if line.strip()])
    return rows, checksum


def _bucket(score: float) -> str:
    if score >= 85.0:
        return "elite_structure_watch"
    if score >= 70.0:
        return "strong_structure_watch"
    if score >= 55.0:
        return "acceptable_structure_watch"
    if score >= 35.0:
        return "weak_structure_watch"
    return "low_attention_structure"


def _score_quality(rank_state: str, packet: L9WindowPacket, price_basis: str) -> str:
    if rank_state == "not_rankable_quality":
        return "not_rankable_missing_price_or_windows"
    if packet.required_missing > 0:
        return "partial_required_priority_windows_missing"
    if price_basis != "fresh_mid":
        return "ranked_degraded_price_basis"
    return "usable_structure_location_priority_window_model"


def _score_row(row: Dict[str, str], outbox: Path) -> Dict[str, object]:
    symbol = _safe_text(row, "symbol")
    point = _safe_float(row.get("point"), 0.0)
    packet = load_l9_window_packet(outbox, symbol)
    latest_close_price = (packet.latest_close_i * point) if point > 0.0 and packet.latest_close_i > 0 else None
    price = resolve_l9_price_basis(row, latest_close_price)
    price_i = int(round(price.price_used / point)) if point > 0.0 and price.price_used > 0.0 else 0

    locations = []
    for tf, weight in L9_TF_WEIGHTS.items():
        locations.append(calculate_tf_location(tf, packet.windows.get(tf, []), price_i, weight, LOOKBACKS.get(tf, 30)))

    boundaries = [calculate_boundary_quality(loc.timeframe, packet.windows.get(loc.timeframe, []), loc.nearest_boundary, LOOKBACKS.get(loc.timeframe, 30)) for loc in locations]
    room = calculate_room_profile(locations)
    event = classify_l9_event_zone(locations, boundaries, room)

    location_score = weighted_location_score(locations)
    boundary_score = weighted_boundary_quality(boundaries, L9_TF_WEIGHTS)
    room_score = room.room_quality_score
    event_score = event.event_zone_quality_score
    quote_score = 100.0 if price.price_basis == "fresh_mid" else (65.0 if price.price_basis == "stale_mid" else (45.0 if price.price_basis == "ohlc_close_fallback" else 0.0))
    data_score = 100.0 if packet.required_missing == 0 else max(0.0, (packet.required_seen / max(1, len(L9_TF_WEIGHTS))) * 100.0)

    structure_score = max(0.0, min(100.0,
        event_score * 0.35
        + location_score * 0.20
        + boundary_score * 0.15
        + room_score * 0.15
        + data_score * 0.10
        + quote_score * 0.05
    ))

    rank_state = "ranked"
    if price.price_basis == "unavailable" or packet.required_seen == 0:
        rank_state = "not_rankable_quality"
    elif packet.required_missing > 0 or price.price_basis != "fresh_mid":
        rank_state = "ranked_partial"
    if event.risk_review and rank_state == "ranked":
        rank_state = "ranked_risk_review"

    bucket = _bucket(structure_score)
    primary = {loc.timeframe.lower(): loc for loc in locations}
    d1 = primary.get("d1")
    h4 = primary.get("h4")
    h1 = primary.get("h1")
    m15 = primary.get("m15")
    nearest_boundary = room.nearest_boundary
    reason = _join_reason([
        event.reason,
        price.reason,
        packet.reason,
        f"structure_score={structure_score:.2f}",
        f"rank_state={rank_state}",
        L9_POLICY,
    ])

    def loc_value(loc, attr: str, default=0.0):
        return getattr(loc, attr, default) if loc is not None else default

    return {
        "symbol": symbol,
        "layer_id": "9",
        "layer_name": L9_LAYER_NAME,
        "l9_model_version": L9_MODEL_VERSION,
        "structure_watchlist_score": structure_score,
        "structure_bucket": bucket,
        "rank_state": rank_state,
        "score_quality": _score_quality(rank_state, packet, price.price_basis),
        "geometry_regime": event.watchlist_state,
        "event_zone": event.dominant_event_zone,
        "watchlist": event.watchlist,
        "entry_signal": "false",
        "trade_permission": "false",
        "selection_runtime": "false",
        "asset_class": _safe_text(row, "asset_class"),
        "ranking_group": _safe_text(row, "ranking_group"),
        "market_state": _safe_text(row, "market_state"),
        "quote_quality": _safe_text(row, "quote_quality"),
        "surface_quality": _safe_text(row, "surface_quality"),
        "tick_age_seconds": price.tick_age_seconds,
        "spread_bps": _safe_float(row.get("spread_bps"), 0.0),
        "price_basis": price.price_basis,
        "price_basis_quality": price.price_basis_quality,
        "price_used": price.price_used,
        "structure_proximity_score": location_score,
        "multi_timeframe_confluence_score": event.confluence_score,
        "available_room_asymmetry_score": room.room_quality_score,
        "boundary_quality_score": boundary_score,
        "location_clarity_score": location_score,
        "trigger_zone_freshness_score": event.event_zone_quality_score,
        "quote_data_quality_score": quote_score,
        "m15_position_pct": loc_value(m15, "position_pct"),
        "m15_zone_state": loc_value(m15, "zone_state", "not_available"),
        "m15_distance_to_high_atr": loc_value(m15, "distance_to_high_atr"),
        "m15_distance_to_low_atr": loc_value(m15, "distance_to_low_atr"),
        "m15_score_component": loc_value(m15, "component_score"),
        "h1_position_pct": loc_value(h1, "position_pct"),
        "h1_zone_state": loc_value(h1, "zone_state", "not_available"),
        "h1_distance_to_high_atr": loc_value(h1, "distance_to_high_atr"),
        "h1_distance_to_low_atr": loc_value(h1, "distance_to_low_atr"),
        "h1_score_component": loc_value(h1, "component_score"),
        "h4_position_pct": loc_value(h4, "position_pct"),
        "h4_zone_state": loc_value(h4, "zone_state", "not_available"),
        "h4_distance_to_high_atr": loc_value(h4, "distance_to_high_atr"),
        "h4_distance_to_low_atr": loc_value(h4, "distance_to_low_atr"),
        "h4_score_component": loc_value(h4, "component_score"),
        "d1_position_pct": loc_value(d1, "position_pct"),
        "d1_zone_state": loc_value(d1, "zone_state", "not_available"),
        "d1_distance_to_high_atr": loc_value(d1, "distance_to_high_atr"),
        "d1_distance_to_low_atr": loc_value(d1, "distance_to_low_atr"),
        "d1_score_component": loc_value(d1, "component_score"),
        "nearest_boundary": nearest_boundary,
        "nearest_boundary_distance_atr": room.nearest_boundary_distance_atr,
        "room_up_atr": room.room_up_atr,
        "room_down_atr": room.room_down_atr,
        "room_profile": room.room_profile,
        "near_high_event_zone": event.high_event_zone_count > 0,
        "near_low_event_zone": event.low_event_zone_count > 0,
        "midrange_trap": room.midrange_trap,
        "compression_at_boundary": event.compression_at_boundary,
        "boundary_touch_count": max((b.nearest_touch_count for b in boundaries), default=0),
        "boundary_age_bars": min((b.nearest_age_bars for b in boundaries if b.nearest_age_bars >= 0), default=-1),
        "boundary_cleanliness_state": max(boundaries, key=lambda b: b.boundary_quality_score).boundary_state if boundaries else "not_available",
        "ohlc_priority_window_checksum": packet.aggregate_checksum,
        "ohlc_window_files_seen": packet.files_seen,
        "ohlc_window_files_missing": packet.files_missing,
        "reason": reason,
    }


def _rank_sort_key(row: Dict[str, object]) -> tuple:
    state_bonus = {"ranked": 3, "ranked_risk_review": 2, "ranked_partial": 1, "not_rankable_quality": 0}.get(str(row.get("rank_state")), 0)
    return (state_bonus, float(row.get("structure_watchlist_score", 0.0)))


def _csv_text(rows: List[Dict[str, object]]) -> str:
    output = io.StringIO(newline="")
    writer = csv.DictWriter(output, fieldnames=L9_OUTPUT_FIELDS)
    writer.writeheader()
    for index, row in enumerate(rows, start=1):
        out = {field: "" for field in L9_OUTPUT_FIELDS}
        out.update({key: _format(value) for key, value in row.items() if key in out})
        out["rank_index"] = str(index)
        writer.writerow(out)
    return output.getvalue().replace("\r\n", "\n").replace("\n", "\r\n")


def _symbol_rank_text(rank_index: int, row: Dict[str, object]) -> str:
    lines = [
        "schema_name=l9_symbol_rank",
        "schema_version=1",
        "layer_id=9",
        f"layer_name={L9_LAYER_NAME}",
        f"owner_name={L9_OWNER}",
        f"job_type={L9_JOB_TYPE}",
        f"l9_model_version={L9_MODEL_VERSION}",
        f"rank_index={rank_index}",
    ]
    for field in L9_OUTPUT_FIELDS:
        if field == "rank_index":
            continue
        if field in row:
            lines.append(f"{field}={_format(row[field])}")
    lines += [
        f"authority={L9_AUTHORITY}",
        "trade_permission=false",
        "selection_runtime=false",
        "entry_signal=false",
        f"source_owner={L9_SOURCE_OWNER}",
        f"generated_utc={utc_stamp()}",
        f"generated_unix={unix_time()}",
        "",
    ]
    return "\n".join(lines)


def _top20_text(rows: List[Dict[str, object]]) -> str:
    lines = [
        "LAYER 9 - STRUCTURE / LOCATION GEOMETRY - TOP 20",
        "----------------------------------------",
        f"Generated UTC: {utc_stamp()}",
        "Trade Permission: FALSE",
        "Selection Runtime: FALSE",
        "Entry Signal: FALSE",
        f"Model Version: {L9_MODEL_VERSION}",
        f"Policy: {L9_POLICY}",
        "Source: Runtime 1 Shared OHLC Priority Windows + L9 input primitives",
        "",
        "rank|symbol|score|bucket|state|event_zone|reason",
    ]
    for index, row in enumerate(rows[:20], start=1):
        lines.append(f"{index}|{row['symbol']}|{float(row['structure_watchlist_score']):.2f}|{row['structure_bucket']}|{row['rank_state']}|{row['event_zone']}|{row['reason']}")
    lines.append("")
    return "\n".join(lines)


def _manifest(summary: L9FinalSummary, input_checksum: str, ranked_checksum: str) -> str:
    return "\n".join([
        "schema_name=layer_ranked_symbols_manifest",
        "schema_version=2",
        "layer_id=9",
        f"layer_name={L9_LAYER_NAME}",
        f"owner_name={L9_OWNER}",
        f"job_type={L9_JOB_TYPE}",
        f"l9_model_version={L9_MODEL_VERSION}",
        f"status={summary.status}",
        f"reason={summary.reason}",
        f"input_count={summary.input_count}",
        f"row_count={summary.row_count}",
        f"ranked_count={summary.ranked_count}",
        f"ranked_partial_count={summary.ranked_partial_count}",
        f"ranked_risk_review_count={summary.ranked_risk_review_count}",
        f"not_rankable_quality_count={summary.not_rankable_quality_count}",
        f"elite_structure_watch_count={summary.elite_count}",
        f"strong_structure_watch_count={summary.strong_count}",
        f"acceptable_structure_watch_count={summary.acceptable_count}",
        f"weak_structure_watch_count={summary.weak_count}",
        f"low_attention_structure_count={summary.low_attention_count}",
        f"near_high_event_zone_count={summary.near_high_event_zone_count}",
        f"near_low_event_zone_count={summary.near_low_event_zone_count}",
        f"midrange_low_attention_count={summary.midrange_low_attention_count}",
        f"compression_at_boundary_count={summary.compression_at_boundary_count}",
        f"symbol_rank_filename_mode={summary.symbol_rank_filename_mode}",
        f"symbol_rank_files_written={summary.symbol_rank_files_written}",
        f"symbol_rank_files_actual={summary.symbol_rank_files_actual}",
        f"symbol_rank_file_count_ok={'true' if summary.symbol_rank_files_written == summary.row_count and summary.symbol_rank_files_actual == summary.row_count else 'false'}",
        f"input_payload_checksum={input_checksum}",
        f"ranked_payload_checksum={ranked_checksum}",
        f"payload_checksum={summary.payload_checksum}",
        f"ranked_csv_path={summary.ranked_csv_path}",
        f"ranked_manifest_path={summary.manifest_path}",
        f"top20_path={summary.top20_path}",
        f"symbol_rank_folder_path={summary.symbol_rank_folder_path}",
        f"authority={L9_AUTHORITY}",
        "trade_permission=false",
        "selection_runtime=false",
        "entry_signal=false",
        f"structure_location_policy={L9_POLICY}",
        f"source_owner={L9_SOURCE_OWNER}",
        f"score_weights={','.join(f'{k}:{v:g}' for k, v in L9_SCORE_WEIGHTS.items())}",
        f"timeframe_weights={','.join(f'{k}:{v:g}' for k, v in L9_TF_WEIGHTS.items())}",
        f"generated_utc={utc_stamp()}",
        f"generated_unix={unix_time()}",
        "",
    ])


def publish_l9_structure_scores(outbox: Path) -> L9FinalSummary:
    layer_dir = _layer_dir(outbox)
    input_path = layer_dir / L9_INPUT_NAME
    input_manifest_path = layer_dir / L9_INPUT_MANIFEST_NAME
    ranked_path = layer_dir / L9_RANKED_NAME
    manifest_path = layer_dir / L9_MANIFEST_NAME
    top20_path = layer_dir / L9_TOP20_NAME
    symbol_rank_dir = layer_dir / L9_SYMBOL_RANK_FOLDER
    layer_dir.mkdir(parents=True, exist_ok=True)
    symbol_rank_dir.mkdir(parents=True, exist_ok=True)

    summary = L9FinalSummary("missing_input", "l9_input_primitives.csv missing", ranked_csv_path=str(ranked_path), manifest_path=str(manifest_path), top20_path=str(top20_path), symbol_rank_folder_path=str(symbol_rank_dir))
    if not input_path.exists() or not input_manifest_path.exists():
        return summary

    input_rows, input_checksum = _read_csv(input_path)
    scored = [_score_row(row, outbox) for row in input_rows]
    scored.sort(key=_rank_sort_key, reverse=True)

    ranked_text = _csv_text(scored)
    ranked_checksum = payload_checksum([line for line in ranked_text.replace("\r\n", "\n").splitlines() if line.strip()])
    atomic_write_text(ranked_path, ranked_text)
    atomic_write_text(top20_path, _top20_text(scored))

    expected_names = set()
    for index, row in enumerate(scored, start=1):
        name = _symbol_rank_filename(str(row["symbol"]))
        expected_names.add(name)
        atomic_write_text(symbol_rank_dir / name, _symbol_rank_text(index, row))
    for old in symbol_rank_dir.glob("*.txt"):
        if old.name not in expected_names:
            try:
                old.unlink()
            except OSError:
                pass

    summary.status = "complete" if scored else "empty_input"
    summary.reason = "l9 structure/location scores published" if scored else "l9 input exists but contains zero rows"
    summary.input_count = len(input_rows)
    summary.row_count = len(scored)
    summary.ranked_count = sum(1 for r in scored if r["rank_state"] == "ranked")
    summary.ranked_partial_count = sum(1 for r in scored if r["rank_state"] == "ranked_partial")
    summary.ranked_risk_review_count = sum(1 for r in scored if r["rank_state"] == "ranked_risk_review")
    summary.not_rankable_quality_count = sum(1 for r in scored if r["rank_state"] == "not_rankable_quality")
    summary.elite_count = sum(1 for r in scored if r["structure_bucket"] == "elite_structure_watch")
    summary.strong_count = sum(1 for r in scored if r["structure_bucket"] == "strong_structure_watch")
    summary.acceptable_count = sum(1 for r in scored if r["structure_bucket"] == "acceptable_structure_watch")
    summary.weak_count = sum(1 for r in scored if r["structure_bucket"] == "weak_structure_watch")
    summary.low_attention_count = sum(1 for r in scored if r["structure_bucket"] == "low_attention_structure")
    summary.near_high_event_zone_count = sum(1 for r in scored if r["near_high_event_zone"])
    summary.near_low_event_zone_count = sum(1 for r in scored if r["near_low_event_zone"])
    summary.midrange_low_attention_count = sum(1 for r in scored if r["event_zone"] == "midrange_low_attention")
    summary.compression_at_boundary_count = sum(1 for r in scored if r["compression_at_boundary"])
    summary.symbol_rank_files_written = len(scored)
    summary.symbol_rank_files_actual = sum(1 for p in symbol_rank_dir.glob("*.txt") if p.is_file())
    manifest_text = _manifest(summary, input_checksum, ranked_checksum)
    summary.payload_checksum = payload_checksum(manifest_text.splitlines())
    manifest_text = manifest_text.replace("payload_checksum=not_available", f"payload_checksum={summary.payload_checksum}")
    atomic_write_text(manifest_path, manifest_text)
    return summary
