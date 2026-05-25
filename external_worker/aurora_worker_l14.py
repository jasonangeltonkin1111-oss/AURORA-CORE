from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Tuple
import csv
import io
import math

from aurora_worker_io import atomic_write_text, payload_checksum, read_text, unix_time, utc_stamp

L14_LAYER_FOLDER = "Layer_14_Ranking_Group_Leader_Candidate_Pool"
L14_OWNER = "Runtime 5 - Taxonomy / Ranking Group Owner"
L14_SCHEMA_NAME = "l14_ranking_group_leader_candidate_pool"
L14_AUTHORITY = "candidate_pool_sourcing_only"
L14_FORMULA_VERSION = "l14_formula_v2_canonical_lookup_review_truth"

CANDIDATE_FIELDS = [
    "candidate_pool_rank","symbol","canonical_symbol","ranking_group","ranking_group_slug","asset_class","market_group","market_segment",
    "candidate_source","leader_or_backup","backup_included_flag","candidate_reason","review_excluded_flag",
    "l14_candidate_priority_score","l11_group_score","l11_top_rank","l11_rank_state","risk_review_flag",
    "source_group_selection_rank","source_group_selection_state","source_group_selection_tier","source_group_fallback_used",
    "source_group_fallback_reason","source_group_selection_score","source_group_strength","source_group_heat","source_group_quality",
    "source_l11_checksum","source_l12_checksum","source_l13_checksum","meaning","candidate_pool_runtime","trade_permission",
    "entry_signal","execution","generated_utc",
    "broker_symbol","l14_quality_state","source_l11_top5_checksum","source_l11_ranked_symbols_checksum",
    "source_l14_formula_checksum","canonical_source","canonical_resolution_state"
]

@dataclass(frozen=True)
class L14PublishSummary:
    status: str
    reason: str
    selected_group_count: int = 0
    candidate_pool_size: int = 0
    leader_candidate_count: int = 0
    backup_candidate_count: int = 0
    review_candidate_count: int = 0
    thin_fallback_candidate_count: int = 0
    source_group_fallback_count: int = 0
    canonical_missing_count: int = 0
    write_failed_count: int = 0
    top_candidate: str = "not_available"
    quality_state: str = "pending"
    candidate_pool_path: str = "not_available"
    summary_path: str = "not_available"
    selection_desk_candidate_pool_path: str = "not_available"
    source_l11_top5_checksum: str = "not_available"
    source_l11_ranked_symbols_checksum: str = "not_available"
    source_l12_checksum: str = "not_available"
    source_l13_checksum: str = "not_available"

EMPTY_L14_SUMMARY = L14PublishSummary("pending", "l14_not_run")


def _text(row: Dict[str, str], key: str, default: str = "not_available") -> str:
    value = str(row.get(key, default) or "").strip()
    return value if value else default


def _num(value: str | None) -> float:
    try:
        number = float(str(value or "").strip())
        return 0.0 if math.isnan(number) or math.isinf(number) else max(0.0, min(100.0, number))
    except ValueError:
        return 0.0


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
    for ch in ['\\','/',':','*','?','"','<','>','|',' ']:
        safe = safe.replace(ch, "_")
    return safe or "unknown"


def _select_dir(outbox: Path) -> Path:
    return outbox.parents[2] / "Selection Desk" / "Groups"


def _write(path: Path, text: str, failed: List[Path]) -> None:
    if not atomic_write_text(path, text):
        failed.append(path)


def _formula_checksum() -> str:
    return str(payload_checksum([L14_FORMULA_VERSION]))


def _quality_state(review_count: int, thin_count: int, fallback_count: int, canonical_missing_count: int) -> str:
    if canonical_missing_count > 0:
        return "accepted_with_missing_canonical_truth"
    if review_count > 0 or thin_count > 0 or fallback_count > 0:
        return "accepted_with_review_or_fallback"
    return "accepted_clean"


def _manifest(name: str, rows: List[Dict[str, str]], payload: str, summary: L14PublishSummary) -> str:
    return "\n".join([
        f"schema_name={name}_manifest",
        "schema_version=2",
        "layer_id=14",
        "layer_name=Layer 14 - Ranking Group Leader Candidate Pool",
        f"owner={L14_OWNER}",
        f"authority={L14_AUTHORITY}",
        f"row_count={len(rows)}",
        f"payload_checksum={payload_checksum(payload.splitlines())}",
        f"l14_quality_state={summary.quality_state}",
        f"review_candidate_count={summary.review_candidate_count}",
        f"thin_fallback_candidate_count={summary.thin_fallback_candidate_count}",
        f"source_group_fallback_count={summary.source_group_fallback_count}",
        f"canonical_missing_count={summary.canonical_missing_count}",
        f"source_l11_top5_checksum={summary.source_l11_top5_checksum}",
        f"source_l11_ranked_symbols_checksum={summary.source_l11_ranked_symbols_checksum}",
        f"source_l12_checksum={summary.source_l12_checksum}",
        f"source_l13_checksum={summary.source_l13_checksum}",
        f"source_l14_formula_checksum={_formula_checksum()}",
        "candidate_pool_runtime=false",
        "trade_permission=false",
        "entry_signal=false",
        "execution=false",
        f"generated_utc={utc_stamp()}",
        f"generated_unix={unix_time()}",
        "",
    ])


def _summary(summary: L14PublishSummary) -> str:
    return "\n".join([
        f"schema_name={L14_SCHEMA_NAME}",
        "schema_version=2",
        f"owner_name={L14_OWNER}",
        f"authority={L14_AUTHORITY}",
        "layer_id=14",
        "layer_name=Layer 14 - Ranking Group Leader Candidate Pool",
        f"status={summary.status}",
        f"reason={summary.reason}",
        f"l14_quality_state={summary.quality_state}",
        "input_source=L13_selected_groups+L11_top5+L11_ranked_symbols_canonical_lookup+L12_group_heat_quality",
        f"selected_group_count={summary.selected_group_count}",
        f"candidate_pool_size={summary.candidate_pool_size}",
        f"leader_candidate_count={summary.leader_candidate_count}",
        f"backup_candidate_count={summary.backup_candidate_count}",
        f"review_candidate_count={summary.review_candidate_count}",
        f"thin_fallback_candidate_count={summary.thin_fallback_candidate_count}",
        f"source_group_fallback_count={summary.source_group_fallback_count}",
        f"canonical_missing_count={summary.canonical_missing_count}",
        f"top_candidate={summary.top_candidate}",
        f"write_failed_count={summary.write_failed_count}",
        f"candidate_pool_path={summary.candidate_pool_path}",
        f"selection_desk_candidate_pool_path={summary.selection_desk_candidate_pool_path}",
        f"source_l11_top5_checksum={summary.source_l11_top5_checksum}",
        f"source_l11_ranked_symbols_checksum={summary.source_l11_ranked_symbols_checksum}",
        f"source_l12_checksum={summary.source_l12_checksum}",
        f"source_l13_checksum={summary.source_l13_checksum}",
        f"source_l14_formula_checksum={_formula_checksum()}",
        "meaning=raw_candidate_pool_only_not_diversified_not_global_top10",
        "candidate_pool_runtime=false",
        "trade_permission=false",
        "entry_signal=false",
        "execution=false",
        f"generated_utc={utc_stamp()}",
        f"generated_unix={unix_time()}",
        "",
    ])


def _candidate_score(l11_score: float, l13_score: float, l12_strength: float, top_rank: int) -> float:
    if top_rank <= 1:
        rank_adjust = 5.0
    else:
        rank_adjust = -2.0 * min(4, top_rank - 1)
    return max(0.0, min(100.0, l11_score * 0.60 + l13_score * 0.25 + l12_strength * 0.10 + rank_adjust))


def _canonical_lookup(ranked_rows: List[Dict[str, str]]) -> Dict[Tuple[str, str], str]:
    lookup: Dict[Tuple[str, str], str] = {}
    for row in ranked_rows:
        symbol = _text(row, "symbol", "")
        group = _text(row, "ranking_group", "")
        canonical = _text(row, "canonical_symbol", "")
        if symbol and canonical:
            lookup[(group, symbol)] = canonical
            lookup[("", symbol)] = canonical
    return lookup


def _build(selected: List[Dict[str, str]], top5: List[Dict[str, str]], ranked: List[Dict[str, str]], heat: List[Dict[str, str]], checksums: Dict[str, str]) -> List[Dict[str, str]]:
    selected_by_group = {_text(row, "ranking_group", "Unknown"): row for row in selected}
    heat_by_group = {_text(row, "ranking_group", "Unknown"): row for row in heat}
    canonical_by_group_symbol = _canonical_lookup(ranked)
    formula_checksum = _formula_checksum()
    out: List[Dict[str, str]] = []

    for row in top5:
        group = _text(row, "ranking_group", "Unknown")
        selected_row = selected_by_group.get(group)
        if selected_row is None:
            continue

        symbol = _text(row, "symbol")
        canonical = canonical_by_group_symbol.get((group, symbol), canonical_by_group_symbol.get(("", symbol), "not_available"))
        canonical_resolution_state = "from_l11_ranked_symbols" if canonical != "not_available" else "missing_from_l11_ranked_symbols"
        heat_row = heat_by_group.get(group, {})
        top_rank = _int(row.get("top_rank"))
        l11_score = _num(row.get("l11_group_score"))
        l13_score = _num(selected_row.get("l13_group_selection_score"))
        l12_strength = _num(heat_row.get("ranking_group_strength"))
        leader = top_rank == 1 or _text(row, "leader_flag", "false").lower() == "true"
        risk_review = _text(row, "risk_review_flag", "false").lower() == "true"
        tier = _text(selected_row, "selection_quality_tier", "not_available")
        state = _text(selected_row, "group_selection_state", "not_available")
        fallback_used = _text(selected_row, "fallback_used", "false")
        candidate_source = "ranking_group_leader" if leader else "ranking_group_backup"
        reason_parts = ["from_l13_selected_group", f"group_state={state}", f"tier={tier}", f"top_rank={top_rank}"]
        if risk_review:
            reason_parts.append("risk_review_visible_not_excluded")
        if "thin" in tier.lower() or "thin" in state.lower():
            reason_parts.append("thin_fallback_context_preserved")
        if fallback_used.lower() == "true":
            reason_parts.append("source_group_fallback_visible")
        if canonical == "not_available":
            reason_parts.append("canonical_symbol_missing_not_faked")

        out.append({
            "candidate_pool_rank": "0",
            "symbol": symbol,
            "canonical_symbol": canonical,
            "ranking_group": group,
            "ranking_group_slug": _text(row, "ranking_group_slug", _safe_slug(group)),
            "asset_class": _text(selected_row, "asset_class", _text(heat_row, "asset_class", "Unknown")),
            "market_group": _text(selected_row, "market_group", _text(heat_row, "market_group", "Unknown")),
            "market_segment": _text(selected_row, "market_segment", _text(heat_row, "market_segment", "Unknown")),
            "candidate_source": candidate_source,
            "leader_or_backup": "leader" if leader else "backup",
            "backup_included_flag": "false" if leader else "true",
            "candidate_reason": ";".join(reason_parts),
            "review_excluded_flag": "false",
            "l14_candidate_priority_score": f"{_candidate_score(l11_score, l13_score, l12_strength, top_rank):.2f}",
            "l11_group_score": f"{l11_score:.2f}",
            "l11_top_rank": str(top_rank),
            "l11_rank_state": _text(row, "rank_state"),
            "risk_review_flag": "true" if risk_review else "false",
            "source_group_selection_rank": _text(selected_row, "selection_rank"),
            "source_group_selection_state": state,
            "source_group_selection_tier": tier,
            "source_group_fallback_used": fallback_used,
            "source_group_fallback_reason": _text(selected_row, "fallback_reason", "not_required"),
            "source_group_selection_score": f"{l13_score:.2f}",
            "source_group_strength": f"{l12_strength:.2f}",
            "source_group_heat": f"{_num(heat_row.get('ranking_group_heat')):.2f}",
            "source_group_quality": f"{_num(heat_row.get('ranking_group_quality_score')):.2f}",
            "source_l11_checksum": checksums.get("l11_top5", "not_available"),
            "source_l12_checksum": checksums.get("l12", "not_available"),
            "source_l13_checksum": checksums.get("l13", "not_available"),
            "meaning": "raw_candidate_pool_only_not_diversified_not_global_top10",
            "candidate_pool_runtime": "false",
            "trade_permission": "false",
            "entry_signal": "false",
            "execution": "false",
            "generated_utc": utc_stamp(),
            "broker_symbol": symbol,
            "l14_quality_state": "pending_until_summary_counted",
            "source_l11_top5_checksum": checksums.get("l11_top5", "not_available"),
            "source_l11_ranked_symbols_checksum": checksums.get("l11_ranked", "not_available"),
            "source_l14_formula_checksum": formula_checksum,
            "canonical_source": "L11 ranked_symbols_by_group.csv",
            "canonical_resolution_state": canonical_resolution_state,
        })

    out.sort(key=lambda r: (-float(r["l14_candidate_priority_score"]), int(r["source_group_selection_rank"] or "999"), int(r["l11_top_rank"] or "999"), r["symbol"]))
    for idx, row in enumerate(out, 1):
        row["candidate_pool_rank"] = str(idx)
    return out


def _selection_desk_text(rows: List[Dict[str, str]], summary: L14PublishSummary) -> str:
    lines = [
        "L14 RANKING GROUP LEADER CANDIDATE POOL",
        "----------------------------------------",
        f"status={summary.status}",
        f"l14_quality_state={summary.quality_state}",
        f"candidate_pool_size={summary.candidate_pool_size}",
        f"leader_candidate_count={summary.leader_candidate_count}",
        f"backup_candidate_count={summary.backup_candidate_count}",
        f"review_candidate_count={summary.review_candidate_count}",
        f"thin_fallback_candidate_count={summary.thin_fallback_candidate_count}",
        f"source_group_fallback_count={summary.source_group_fallback_count}",
        f"canonical_missing_count={summary.canonical_missing_count}",
        f"source_l11_top5_checksum={summary.source_l11_top5_checksum}",
        f"source_l11_ranked_symbols_checksum={summary.source_l11_ranked_symbols_checksum}",
        f"source_l12_checksum={summary.source_l12_checksum}",
        f"source_l13_checksum={summary.source_l13_checksum}",
        f"source_l14_formula_checksum={_formula_checksum()}",
        "meaning=raw_candidate_pool_only_not_diversified_not_global_top10",
    ]
    for row in rows:
        lines.append(f"#{row['candidate_pool_rank']} {row['symbol']} canonical={row['canonical_symbol']} group={row['ranking_group']} source={row['candidate_source']} score={row['l14_candidate_priority_score']} quality={row['l14_quality_state']} reason={row['candidate_reason']}")
    lines.extend(["candidate_pool_runtime=false", "trade_permission=false", "entry_signal=false", "execution=false", ""])
    return "\n".join(lines)


def publish_l14_ranking_group_leader_candidate_pool(outbox_root: Path) -> L14PublishSummary:
    l11 = outbox_root / "Layers" / "Layer_11_Symbol_Ranking_Inside_Ranking_Group"
    l12 = outbox_root / "Layers" / "Layer_12_Ranking_Group_Heat_Quality"
    l13 = outbox_root / "Layers" / "Layer_13_Dynamic_Ranking_Group_Selection"
    needed = [
        l13 / "l13_group_selection_summary.txt",
        l13 / "l13_selected_ranking_groups.csv",
        l13 / "l13_selected_ranking_groups.manifest",
        l11 / "ranking_group_top5.csv",
        l11 / "ranked_symbols_by_group.csv",
        l11 / "ranked_symbols_by_group.manifest",
        l12 / "l12_group_heat_quality.csv",
        l12 / "l12_group_heat_quality.manifest",
    ]
    missing = [str(p) for p in needed if not p.exists()]
    if missing:
        return L14PublishSummary("pending", "missing_required_l14_source: " + ";".join(missing))

    try:
        l13_summary = _kv(l13 / "l13_group_selection_summary.txt")
        l13_status = l13_summary.get("status", "pending")
        if l13_status not in {"accepted", "write_degraded"}:
            return L14PublishSummary("pending" if l13_status == "pending" else "degraded", "l13_not_accepted_status=" + l13_status)

        selected_text = read_text(l13 / "l13_selected_ranking_groups.csv")
        top5_text = read_text(l11 / "ranking_group_top5.csv")
        ranked_text = read_text(l11 / "ranked_symbols_by_group.csv")
        heat_text = read_text(l12 / "l12_group_heat_quality.csv")
        checksums = {
            "l13": payload_checksum(selected_text.splitlines()),
            "l11_top5": payload_checksum(top5_text.splitlines()),
            "l11_ranked": payload_checksum(ranked_text.splitlines()),
            "l12": payload_checksum(heat_text.splitlines()),
        }

        selected_rows = _csv(l13 / "l13_selected_ranking_groups.csv")
        rows = _build(
            selected_rows,
            _csv(l11 / "ranking_group_top5.csv"),
            _csv(l11 / "ranked_symbols_by_group.csv"),
            _csv(l12 / "l12_group_heat_quality.csv"),
            checksums,
        )
        if not rows:
            return L14PublishSummary("pending", "no_l14_candidates_from_l13_selected_groups_and_l11_top5")

        leader_count = sum(1 for r in rows if r["leader_or_backup"] == "leader")
        backup_count = sum(1 for r in rows if r["backup_included_flag"] == "true")
        review_count = sum(1 for r in rows if r["risk_review_flag"] == "true")
        thin_count = sum(1 for r in rows if "thin" in r["source_group_selection_tier"].lower() or "thin" in r["source_group_selection_state"].lower())
        fallback_count = sum(1 for r in rows if r["source_group_fallback_used"].lower() == "true")
        canonical_missing_count = sum(1 for r in rows if r["canonical_symbol"] == "not_available")
        quality_state = _quality_state(review_count, thin_count, fallback_count, canonical_missing_count)
        for row in rows:
            row["l14_quality_state"] = quality_state

        layer = outbox_root / "Layers" / L14_LAYER_FOLDER
        groups = layer / "RankingGroups"
        visible = _select_dir(outbox_root)
        for d in (layer, groups, visible):
            d.mkdir(parents=True, exist_ok=True)

        failed: List[Path] = []
        csv_text = _csv_text(rows, CANDIDATE_FIELDS)
        summary = L14PublishSummary(
            status="accepted",
            reason="l14_candidate_pool_published",
            selected_group_count=len({_text(r, "ranking_group") for r in selected_rows}),
            candidate_pool_size=len(rows),
            leader_candidate_count=leader_count,
            backup_candidate_count=backup_count,
            review_candidate_count=review_count,
            thin_fallback_candidate_count=thin_count,
            source_group_fallback_count=fallback_count,
            canonical_missing_count=canonical_missing_count,
            top_candidate=rows[0]["symbol"],
            quality_state=quality_state,
            candidate_pool_path=str(layer / "l14_candidate_pool.csv"),
            summary_path=str(layer / "l14_candidate_pool_summary.txt"),
            selection_desk_candidate_pool_path=str(visible / "00_Ranking_Group_Leader_Candidate_Pool.txt"),
            source_l11_top5_checksum=checksums["l11_top5"],
            source_l11_ranked_symbols_checksum=checksums["l11_ranked"],
            source_l12_checksum=checksums["l12"],
            source_l13_checksum=checksums["l13"],
        )

        _write(layer / "l14_candidate_pool.csv", csv_text, failed)
        _write(layer / "l14_candidate_pool.manifest", _manifest("l14_candidate_pool", rows, csv_text, summary), failed)

        grouped: Dict[str, List[Dict[str, str]]] = {}
        for row in rows:
            grouped.setdefault(row["ranking_group"], []).append(row)
        for group, members in grouped.items():
            slug = _safe_slug(group)
            text = "\n".join([
                "L14 CANDIDATE POOL BY RANKING GROUP",
                "----------------------------------------",
                f"ranking_group={group}",
                f"l14_quality_state={quality_state}",
                f"review_candidate_count={sum(1 for m in members if m['risk_review_flag'] == 'true')}",
                f"thin_fallback_candidate_count={sum(1 for m in members if 'thin' in m['source_group_selection_tier'].lower() or 'thin' in m['source_group_selection_state'].lower())}",
                f"source_group_fallback_count={sum(1 for m in members if m['source_group_fallback_used'].lower() == 'true')}",
            ] + [f"#{m['candidate_pool_rank']} {m['symbol']} canonical={m['canonical_symbol']} source={m['candidate_source']} score={m['l14_candidate_priority_score']} reason={m['candidate_reason']}" for m in members] + ["candidate_pool_runtime=false", "trade_permission=false", "entry_signal=false", "execution=false", ""])
            _write(groups / (slug + ".candidate_pool.txt"), text, failed)

        if failed:
            summary = L14PublishSummary(
                status="write_degraded",
                reason="one_or_more_l14_outputs_failed",
                selected_group_count=summary.selected_group_count,
                candidate_pool_size=summary.candidate_pool_size,
                leader_candidate_count=summary.leader_candidate_count,
                backup_candidate_count=summary.backup_candidate_count,
                review_candidate_count=summary.review_candidate_count,
                thin_fallback_candidate_count=summary.thin_fallback_candidate_count,
                source_group_fallback_count=summary.source_group_fallback_count,
                canonical_missing_count=summary.canonical_missing_count,
                write_failed_count=len(failed),
                top_candidate=summary.top_candidate,
                quality_state=summary.quality_state,
                candidate_pool_path=summary.candidate_pool_path,
                summary_path=summary.summary_path,
                selection_desk_candidate_pool_path=summary.selection_desk_candidate_pool_path,
                source_l11_top5_checksum=summary.source_l11_top5_checksum,
                source_l11_ranked_symbols_checksum=summary.source_l11_ranked_symbols_checksum,
                source_l12_checksum=summary.source_l12_checksum,
                source_l13_checksum=summary.source_l13_checksum,
            )

        _write(layer / "l14_candidate_pool_summary.txt", _summary(summary), failed)
        _write(visible / "00_Ranking_Group_Leader_Candidate_Pool.csv", csv_text, failed)
        _write(visible / "00_Ranking_Group_Leader_Candidate_Pool.txt", _selection_desk_text(rows, summary), failed)
        return summary
    except Exception as exc:
        return L14PublishSummary("exception", f"{type(exc).__name__}: {exc}")
