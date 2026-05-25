from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List
from collections import defaultdict
import csv
import io
import math
import statistics

from aurora_worker_io import atomic_write_text, payload_checksum, read_text, unix_time, utc_stamp

L12_LAYER_FOLDER = "Layer_12_Ranking_Group_Heat_Quality"
L12_OWNER = "Runtime 5 - Taxonomy / Ranking Group Owner"
L12_SCHEMA_NAME = "l12_ranking_group_heat_quality"
L12_AUTHORITY = "ranking_group_attention_quality_only"
L12_FIELDS = ["ranking_group","ranking_group_slug","asset_class","market_group","market_segment","group_state","ranking_group_heat_rank","ranking_group_quality_rank","ranking_group_strength_rank","ranking_group_heat","ranking_group_quality_score","ranking_group_strength","group_symbol_count","rankable_count","not_rankable_count","risk_review_count","top5_symbol_count","backup_depth","top_symbol","top_symbol_score","top5_avg_score","top5_median_score","l6_avg_score","l7_avg_score","l8_avg_score","l9_avg_score","component_completeness_avg","thin_group_flag","thin_group_reason","rank_stability","rank_change","prior_cycle_available","meaning","directional_validity","expectancy_validated","selection_runtime","trade_permission","entry_signal","execution","reason","source_l11_checksum","generated_utc"]

@dataclass(frozen=True)
class L12PublishSummary:
    status: str
    reason: str
    ranking_group_count: int = 0
    accepted_group_count: int = 0
    thin_group_count: int = 0
    risk_review_group_count: int = 0
    write_failed_count: int = 0
    heat_quality_path: str = "not_available"
    summary_path: str = "not_available"
    selection_desk_heat_index_path: str = "not_available"
    top_heat_group: str = "not_available"
    top_quality_group: str = "not_available"
    top_strength_group: str = "not_available"
    thin_rankable_group_count: int = 0
    no_rankable_group_count: int = 0
    input_l11_ranked_manifest_checksum: str = "not_available"
    input_l11_ranked_payload_checksum: str = "not_available"
    input_contract_status: str = "not_available"

EMPTY_L12_SUMMARY = L12PublishSummary("pending", "l12_not_run")

def _text(row: Dict[str, str], key: str, default: str = "not_available") -> str:
    value = str(row.get(key, default) or "").strip()
    return value if value else default

def _num(value: str | None) -> float | None:
    try:
        number = float(str(value or "").strip())
        return None if math.isnan(number) or math.isinf(number) else max(0.0, min(100.0, number))
    except ValueError:
        return None

def _int_text(value: str | None, fallback: int = 0) -> int:
    try:
        return int(float(str(value or "").strip()))
    except ValueError:
        return fallback

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

def _rankable(row: Dict[str, str]) -> bool:
    return _text(row, "rank_state", "").lower() in {"ranked", "ranked_partial", "risk_review"}

def _risk(row: Dict[str, str]) -> bool:
    return _text(row, "risk_review_flag", "false").lower() == "true" or _text(row, "rank_state", "").lower() == "risk_review"

def _avg(vals: List[float]) -> float:
    return sum(vals) / len(vals) if vals else 0.0

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

def _rankable_l12_row(row: Dict[str, str]) -> bool:
    return _int_text(row.get("rankable_count"), 0) > 0

def _rank_sort_value(row: Dict[str, str], key: str) -> tuple[int, float, str]:
    if not _rankable_l12_row(row):
        return (1, 0.0, row["ranking_group"])
    return (0, -float(row[key]), row["ranking_group"])

def _top_ranked_group(rows: List[Dict[str, str]], rank_key: str) -> str:
    ranked = [row for row in rows if row.get(rank_key, "not_available") != "not_available"]
    if not ranked:
        return "not_available"
    return min(ranked, key=lambda row: int(row[rank_key]))["ranking_group"]

def _visible_rank(row: Dict[str, str], key: str) -> str:
    value = row.get(key, "not_available")
    return f"#{value}" if value != "not_available" else "NA"

def _manifest(name: str, rows: List[Dict[str, str]], payload: str, l11_manifest_checksum: str, l11_ranked_checksum: str) -> str:
    return "\n".join([
        f"schema_name={name}_manifest",
        "schema_version=2",
        "layer_id=12",
        "layer_name=Layer 12 - Ranking Group Heat / Quality",
        f"owner={L12_OWNER}",
        f"authority={L12_AUTHORITY}",
        f"row_count={len(rows)}",
        f"payload_checksum={payload_checksum(payload.splitlines())}",
        f"input_l11_ranked_manifest_checksum={l11_manifest_checksum}",
        f"input_l11_ranked_payload_checksum={l11_ranked_checksum}",
        "input_contract_status=accepted",
        "directional_validity=false",
        "expectancy_validated=false",
        "selection_runtime=false",
        "trade_permission=false",
        "entry_signal=false",
        "execution=false",
        f"generated_utc={utc_stamp()}",
        f"generated_unix={unix_time()}",
        "",
    ])

def _summary(summary: L12PublishSummary) -> str:
    return "\n".join([
        f"schema_name={L12_SCHEMA_NAME}",
        "schema_version=2",
        f"owner_name={L12_OWNER}",
        "layer_id=12",
        "layer_name=Layer 12 - Ranking Group Heat / Quality",
        f"status={summary.status}",
        f"reason={summary.reason}",
        "input_source=L11",
        f"input_l11_ranked_manifest_checksum={summary.input_l11_ranked_manifest_checksum}",
        f"input_l11_ranked_payload_checksum={summary.input_l11_ranked_payload_checksum}",
        f"input_contract_status={summary.input_contract_status}",
        f"ranking_group_count={summary.ranking_group_count}",
        f"accepted_group_count={summary.accepted_group_count}",
        f"thin_group_count={summary.thin_group_count}",
        f"thin_rankable_group_count={summary.thin_rankable_group_count}",
        f"no_rankable_group_count={summary.no_rankable_group_count}",
        f"risk_review_group_count={summary.risk_review_group_count}",
        f"top_heat_group={summary.top_heat_group}",
        f"top_quality_group={summary.top_quality_group}",
        f"top_strength_group={summary.top_strength_group}",
        f"write_failed_count={summary.write_failed_count}",
        "rank_stability=not_available_first_cycle",
        "rank_change=not_available_first_cycle",
        "prior_cycle_available=false",
        "meaning=ranking_group_attention_quality_only",
        "directional_validity=false",
        "expectancy_validated=false",
        "selection_runtime=false",
        "trade_permission=false",
        "entry_signal=false",
        "execution=false",
        f"generated_utc={utc_stamp()}",
        f"generated_unix={unix_time()}",
        "",
    ])

def _build(ranked: List[Dict[str, str]], top5: List[Dict[str, str]], checksum: str) -> List[Dict[str, str]]:
    grouped: Dict[str, List[Dict[str, str]]] = defaultdict(list)
    top_grouped: Dict[str, List[Dict[str, str]]] = defaultdict(list)
    for row in ranked:
        grouped[_text(row, "ranking_group", "Unknown")].append(row)
    for row in top5:
        top_grouped[_text(row, "ranking_group", "Unknown")].append(row)
    out: List[Dict[str, str]] = []
    for group, members in sorted(grouped.items()):
        rankable = [r for r in members if _rankable(r)]
        tops = [r for r in top_grouped.get(group, []) if _rankable(r)] or sorted(rankable, key=lambda r: float(r.get("l11_group_score", "0") or 0), reverse=True)[:5]
        scores = [n for n in [_num(r.get("l11_group_score")) for r in rankable] if n is not None]
        top_scores = [n for n in [_num(r.get("l11_group_score")) for r in tops] if n is not None]
        group_count, rankable_count = len(members), len(rankable)
        risk_count = sum(1 for r in members if _risk(r))
        thin = rankable_count < 3
        state = "NO_RANKABLE_SYMBOLS" if rankable_count <= 0 else ("NO_TOP5" if len(tops) <= 0 else ("THIN_GROUP" if thin else ("ACCEPTED_WITH_REVIEW" if risk_count else "ACCEPTED")))
        l6 = [n for n in [_num(r.get("l6_score")) for r in rankable] if n is not None]
        l7 = [n for n in [_num(r.get("l7_score")) for r in rankable] if n is not None]
        l8 = [n for n in [_num(r.get("l8_score")) for r in rankable] if n is not None]
        l9 = [n for n in [_num(r.get("l9_score")) for r in rankable] if n is not None]
        completeness = 100.0 * (len(l6)+len(l7)+len(l8)+len(l9)) / max(1, rankable_count*4)
        rankable_ratio = 100.0 * rankable_count / max(1, group_count)
        clean_ratio = 100.0 * max(0, rankable_count-risk_count) / max(1, rankable_count)
        backup = max(0, len(tops)-1)
        top_avg = _avg(top_scores)
        top_med = float(statistics.median(top_scores)) if top_scores else 0.0
        top_symbol_score = max(top_scores) if top_scores else (max(scores) if scores else 0.0)
        pct70 = 100.0 * sum(1 for s in scores if s >= 70.0) / max(1, len(scores))
        sep = max(0.0, sorted(top_scores, reverse=True)[0] - sorted(top_scores, reverse=True)[1]) if len(top_scores) >= 2 else 0.0
        quality = max(0.0, min(100.0, rankable_ratio*.25 + clean_ratio*.25 + completeness*.20 + (100 if tops else 0)*.10 + min(100, backup*25)*.10 - min(25, risk_count*5) - min(25, (group_count-rankable_count)*3) - (20 if thin else 0)))
        strength = max(0.0, min(100.0, top_symbol_score*.35 + top_avg*.35 + top_med*.15 + min(100, backup*25)*.10 + min(100, max(0, rankable_count-risk_count)*10)*.05))
        heat = max(0.0, min(100.0, top_avg*.30 + pct70*.20 + sep*.15 + _avg(l7)*.20))
        if rankable_count <= 0:
            heat = quality = strength = 0.0
        first = members[0]
        out.append({"ranking_group":group,"ranking_group_slug":_text(first,"ranking_group_slug",_safe_slug(group)),"asset_class":_text(first,"asset_class","Unknown"),"market_group":_text(first,"market_group","Unknown"),"market_segment":_text(first,"market_segment","Unknown"),"group_state":state,"ranking_group_heat_rank":"not_available","ranking_group_quality_rank":"not_available","ranking_group_strength_rank":"not_available","ranking_group_heat":f"{heat:.2f}","ranking_group_quality_score":f"{quality:.2f}","ranking_group_strength":f"{strength:.2f}","group_symbol_count":str(group_count),"rankable_count":str(rankable_count),"not_rankable_count":str(group_count-rankable_count),"risk_review_count":str(risk_count),"top5_symbol_count":str(len(tops)),"backup_depth":str(backup),"top_symbol":_text(tops[0],"symbol","not_available") if tops else "not_available","top_symbol_score":f"{top_symbol_score:.2f}","top5_avg_score":f"{top_avg:.2f}","top5_median_score":f"{top_med:.2f}","l6_avg_score":f"{_avg(l6):.2f}","l7_avg_score":f"{_avg(l7):.2f}","l8_avg_score":f"{_avg(l8):.2f}","l9_avg_score":f"{_avg(l9):.2f}","component_completeness_avg":f"{completeness:.2f}","thin_group_flag":"true" if thin else "false","thin_group_reason":"no_rankable_symbols" if rankable_count <= 0 else ("rankable_count_below_3" if thin else "not_thin"),"rank_stability":"not_available_first_cycle","rank_change":"not_available_first_cycle","prior_cycle_available":"false","meaning":"ranking_group_attention_quality_only","directional_validity":"false","expectancy_validated":"false","selection_runtime":"false","trade_permission":"false","entry_signal":"false","execution":"false","reason":"l12_no_rankable_symbols_from_guarded_l11" if rankable_count <= 0 else "l12_group_heat_quality_scored","source_l11_checksum":checksum,"generated_utc":utc_stamp()})
    for key, rank_key in [("ranking_group_heat","ranking_group_heat_rank"),("ranking_group_quality_score","ranking_group_quality_rank"),("ranking_group_strength","ranking_group_strength_rank")]:
        rankable_rows = [row for row in sorted(out, key=lambda r: _rank_sort_value(r, key)) if _rankable_l12_row(row)]
        for idx, row in enumerate(rankable_rows, 1):
            row[rank_key] = str(idx)
    return out

def publish_l12_ranking_group_heat_quality(outbox_root: Path) -> L12PublishSummary:
    l11 = outbox_root / "Layers" / "Layer_11_Symbol_Ranking_Inside_Ranking_Group"
    needed = [l11/"l11_summary.txt", l11/"ranked_symbols_by_group.csv", l11/"ranking_group_top5.csv", l11/"ranked_symbols_by_group.manifest"]
    missing = [str(p) for p in needed if not p.exists()]
    if missing:
        return L12PublishSummary("pending", "missing_required_l12_source: " + ";".join(missing))
    try:
        status = _kv(l11/"l11_summary.txt").get("status", "pending")
        if status not in {"accepted", "write_degraded"}:
            return L12PublishSummary("pending" if status == "pending" else "degraded", "l11_not_accepted_status=" + status)
        ranked_text = read_text(l11/"ranked_symbols_by_group.csv")
        l11_ranked_checksum = payload_checksum(ranked_text.splitlines())
        l11_manifest_checksum = _kv(l11/"ranked_symbols_by_group.manifest").get("payload_checksum", "not_available")
        rows = _build(_csv(l11/"ranked_symbols_by_group.csv"), _csv(l11/"ranking_group_top5.csv"), l11_ranked_checksum)
        if not rows:
            return L12PublishSummary("pending", "no_l12_ranking_groups_to_score")
        layer = outbox_root / "Layers" / L12_LAYER_FOLDER
        groups = layer / "RankingGroups"
        visible = _select_dir(outbox_root)
        for d in (layer, groups, visible):
            d.mkdir(parents=True, exist_ok=True)
        failed: List[Path] = []
        csv_text = _csv_text(rows, L12_FIELDS)
        _write(layer/"l12_group_heat_quality.csv", csv_text, failed)
        _write(layer/"l12_group_heat_quality.manifest", _manifest("l12_group_heat_quality", rows, csv_text, l11_manifest_checksum, l11_ranked_checksum), failed)
        for row in rows:
            _write(groups/(row["ranking_group_slug"]+".heat_quality.txt"), "\n".join([f"{k}={row.get(k,'not_available')}" for k in L12_FIELDS]+[""]), failed)
        _write(visible/"00_Group_Heat_Quality_Index.csv", csv_text, failed)
        _write(visible/"00_Group_Heat_Quality_Index.txt", "\n".join(["L12 GROUP HEAT / QUALITY INDEX", "----------------------------------------"] + [f"{_visible_rank(r, 'ranking_group_heat_rank')} {r['ranking_group']} heat={r['ranking_group_heat']} quality={r['ranking_group_quality_score']} strength={r['ranking_group_strength']} state={r['group_state']}" for r in sorted(rows, key=lambda x:_rank_sort_value(x, 'ranking_group_heat'))] + ["selection_runtime=false", "trade_permission=false", "entry_signal=false", "execution=false", ""]), failed)
        top_heat = _top_ranked_group(rows, "ranking_group_heat_rank")
        top_quality = _top_ranked_group(rows, "ranking_group_quality_rank")
        top_strength = _top_ranked_group(rows, "ranking_group_strength_rank")
        accepted_count = sum(1 for r in rows if r["group_state"].startswith("ACCEPTED"))
        thin_count = sum(1 for r in rows if r["thin_group_flag"]=="true")
        no_rankable_count = sum(1 for r in rows if r["group_state"]=="NO_RANKABLE_SYMBOLS")
        thin_rankable_count = sum(1 for r in rows if r["thin_group_flag"]=="true" and _int_text(r.get("rankable_count"), 0) > 0)
        risk_review_count = sum(1 for r in rows if int(r["risk_review_count"])>0)
        failed_before_summary = len(failed)
        summary = L12PublishSummary(
            "accepted" if failed_before_summary == 0 else "write_degraded",
            "l12_group_heat_quality_published" if failed_before_summary == 0 else "one_or_more_l12_outputs_failed",
            len(rows), accepted_count, thin_count, risk_review_count, failed_before_summary,
            str(layer/"l12_group_heat_quality.csv"), str(layer/"l12_group_heat_quality_summary.txt"), str(visible/"00_Group_Heat_Quality_Index.txt"),
            top_heat, top_quality, top_strength, thin_rankable_count, no_rankable_count,
            l11_manifest_checksum, l11_ranked_checksum, "accepted",
        )
        _write(layer/"l12_group_heat_quality_summary.txt", _summary(summary), failed)
        if len(failed) != failed_before_summary:
            return L12PublishSummary(
                "write_degraded", "one_or_more_l12_outputs_failed", len(rows), accepted_count,
                thin_count, risk_review_count, len(failed), str(layer/"l12_group_heat_quality.csv"),
                str(layer/"l12_group_heat_quality_summary.txt"), str(visible/"00_Group_Heat_Quality_Index.txt"),
                top_heat, top_quality, top_strength, thin_rankable_count, no_rankable_count,
                l11_manifest_checksum, l11_ranked_checksum, "accepted",
            )
        return summary
    except Exception as exc:
        return L12PublishSummary("exception", f"{type(exc).__name__}: {exc}")
