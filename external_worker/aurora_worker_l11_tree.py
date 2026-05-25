from __future__ import annotations

from collections import defaultdict
from dataclasses import dataclass
from pathlib import Path
import csv
import io
import re
from typing import Dict, Iterable, List, Sequence, Tuple

from aurora_worker_io import WorkerPaths, atomic_write_text, payload_checksum, read_text, unix_time, utc_stamp

L11_LAYER_FOLDER = "Layer_11_Symbol_Ranking_Inside_Ranking_Group"
TREE_SCHEMA_NAME = "l11_selection_desk_taxonomy_tree"
TREE_SCHEMA_VERSION = "1"
TREE_AUTHORITY = "intra_group_inspection_priority_only"
TREE_INDEX_FIELDS = [
    "asset_class", "market_group", "market_segment", "ranking_group",
    "asset_class_slug", "market_group_slug", "market_segment_slug", "ranking_group_slug",
    "group_symbol_count", "rankable_count", "not_rankable_count", "top5_available",
    "leader_symbol", "leader_score", "risk_review_count", "tree_folder", "summary_file",
    "ranked_symbols_file", "top5_text_file", "top5_csv_file", "rank_card_count",
    "selection_runtime", "trade_permission", "entry_signal", "execution", "source_checksum",
]
TOP5_FIELDS = [
    "ranking_group", "symbol", "ranking_group_rank", "rankable_count", "ranking_group_rank_percentile",
    "l11_group_score", "rank_state", "leader_flag", "backup_flag", "in_top5_per_ranking_group",
    "asset_class", "market_group", "market_segment", "l5_gate_state", "l6_score", "l6_state",
    "l7_score", "l7_state", "l8_score", "l8_state", "l9_score", "l9_state",
    "missing_layer_count", "stale_layer_count", "risk_review_flag", "reason",
    "selection_runtime", "trade_permission", "entry_signal", "execution", "source_checksum",
]

@dataclass(frozen=True)
class L11TreeSummary:
    status: str
    reason: str
    taxonomy_tree_rows: int = 0
    taxonomy_tree_files_written: int = 0
    taxonomy_tree_files_expected: int = 0
    taxonomy_tree_rank_cards_written: int = 0
    taxonomy_tree_rank_cards_expected: int = 0
    stale_rank_cards_removed: int = 0
    write_failed_count: int = 0
    taxonomy_tree_index_path: str = "not_available"
    taxonomy_tree_csv_path: str = "not_available"


def _sanitize(value: str) -> str:
    safe = str(value or "").strip() or "Unknown"
    safe = safe.replace("&", "and")
    safe = re.sub(r"[\\/:*?\"<>|]+", "_", safe)
    safe = re.sub(r"\s+", "_", safe)
    safe = re.sub(r"_+", "_", safe).strip("_.")
    return safe or "Unknown"


def _display(value: str) -> str:
    return str(value or "").strip() or "Unknown"


def _csv_rows(text: str) -> List[Dict[str, str]]:
    reader = csv.DictReader(io.StringIO(text.replace("\r\n", "\n")))
    return [{str(k): ("" if v is None else str(v)) for k, v in row.items()} for row in reader]


def _csv_text(rows: Sequence[Dict[str, str]], fields: Sequence[str]) -> str:
    buffer = io.StringIO(newline="")
    writer = csv.DictWriter(buffer, fieldnames=list(fields), extrasaction="ignore", lineterminator="\n")
    writer.writeheader()
    for row in rows:
        writer.writerow({field: str(row.get(field, "not_available")) for field in fields})
    return buffer.getvalue()


def _write(path: Path, text: str, failed: List[Path]) -> bool:
    ok = atomic_write_text(path, text)
    if not ok:
        failed.append(path)
    return ok


def _selection_groups_dir(root: Path) -> Path:
    paths = WorkerPaths.from_root(root)
    # outbox = <account>/Workbench/Gateway/Outbox
    account_root = paths.outbox.parents[2]
    return account_root / "Selection Desk" / "Groups"


def _rank_value(row: Dict[str, str]) -> int:
    try:
        return int(str(row.get("ranking_group_rank", "999999")).strip())
    except ValueError:
        return 999999


def _is_top5(row: Dict[str, str]) -> bool:
    return str(row.get("in_top5_per_ranking_group", "")).strip().lower() == "true" and _rank_value(row) <= 5


def _rank_card_name(row: Dict[str, str]) -> str:
    rank = _rank_value(row)
    symbol = _sanitize(row.get("symbol", "unknown"))
    return f"{rank:02d}_{symbol}.txt" if rank < 999999 else f"not_rankable_{symbol}.txt"


def _rank_card_text(row: Dict[str, str], dossier_hint: str) -> str:
    return "\n".join([
        "L11 RANK CARD",
        "----------------------------------------",
        "Layer: 11",
        "Meaning: intra_group_inspection_priority_only",
        f"Symbol: {row.get('symbol', 'not_available')}",
        f"Asset Class: {row.get('asset_class', 'Unknown')}",
        f"Market Group: {row.get('market_group', 'Unknown')}",
        f"Market Segment: {row.get('market_segment', 'Unknown')}",
        f"Ranking Group: {row.get('ranking_group', 'Unknown')}",
        f"Rank: {row.get('ranking_group_rank', 'not_available')} / {row.get('rankable_count', 'not_available')}",
        f"Group Percentile: {row.get('ranking_group_rank_percentile', 'not_available')}",
        f"L11 Score: {row.get('l11_group_score', 'not_available')}",
        f"Rank State: {row.get('rank_state', 'not_available')}",
        f"Leader Flag: {row.get('leader_flag', 'false')}",
        f"Backup Flag: {row.get('backup_flag', 'false')}",
        f"Risk Review: {row.get('risk_review_flag', 'false')}",
        "Components:",
        f"  L6 Cost/Friction: {row.get('l6_score', 'not_available')} state={row.get('l6_state', 'not_available')}",
        f"  L7 Session: {row.get('l7_score', 'not_available')} state={row.get('l7_state', 'not_available')}",
        f"  L8 Movement: {row.get('l8_score', 'not_available')} state={row.get('l8_state', 'not_available')}",
        f"  L9 Structure: {row.get('l9_score', 'not_available')} state={row.get('l9_state', 'not_available')}",
        f"Reason: {row.get('reason', 'not_available')}",
        f"Dossier Source: {dossier_hint}",
        "Selection Runtime: FALSE",
        "Trade Permission: FALSE",
        "Entry Signal: FALSE",
        "Execution: FALSE",
        f"Generated UTC: {utc_stamp()}",
        "",
    ])


def _group_summary_text(group: str, rows: List[Dict[str, str]], top5: List[Dict[str, str]], folder: Path) -> str:
    leader = top5[0] if top5 else {}
    not_rankable = [r for r in rows if str(r.get("rank_state", "")).startswith("not_rankable")]
    risk_review = [r for r in rows if str(r.get("risk_review_flag", "")).lower() == "true"]
    lines = [
        "L11 - SYMBOL RANKING INSIDE RANKING GROUP",
        "----------------------------------------",
        f"Ranking Group: {group}",
        f"Asset Class: {_display(leader.get('asset_class') or rows[0].get('asset_class')) if rows else 'Unknown'}",
        f"Market Group: {_display(leader.get('market_group') or rows[0].get('market_group')) if rows else 'Unknown'}",
        f"Market Segment: {_display(leader.get('market_segment') or rows[0].get('market_segment')) if rows else 'Unknown'}",
        f"Tree Folder: {folder}",
        f"Group Symbol Count: {len(rows)}",
        f"Rankable Symbols: {len(rows) - len(not_rankable)}",
        f"Not Rankable: {len(not_rankable)}",
        f"Risk Review Symbols: {len(risk_review)}",
        "Top 5 per ranking_group:",
    ]
    for row in top5:
        lines.append(f"#{row.get('ranking_group_rank')} {row.get('symbol')} score={row.get('l11_group_score')} state={row.get('rank_state')} leader={row.get('leader_flag')} backup={row.get('backup_flag')}")
    if not top5:
        lines.append("not_available")
    lines += [
        "Policy: intra_group_inspection_priority_only",
        "Selection Runtime: FALSE",
        "Trade Permission: FALSE",
        "Entry Signal: FALSE",
        "Execution: FALSE",
        "Source: L10 + L6-L9",
        f"Generated UTC: {utc_stamp()}",
        "Main Blocker: none" if top5 else "Main Blocker: no_rankable_top5_rows",
        "",
    ]
    return "\n".join(lines)


def _taxonomy_tree_text(index_rows: List[Dict[str, str]]) -> str:
    unique_ranking_groups = len({row.get("ranking_group", "Unknown") for row in index_rows})
    lines = [
        "L11 SELECTION DESK TAXONOMY TREE",
        "----------------------------------------",
        f"schema_name={TREE_SCHEMA_NAME}",
        f"schema_version={TREE_SCHEMA_VERSION}",
        "authority=intra_group_inspection_priority_only",
        f"taxonomy_tree_rows={len(index_rows)}",
        f"unique_ranking_group_count={unique_ranking_groups}",
        "selection_runtime=false",
        "trade_permission=false",
        "entry_signal=false",
        "execution=false",
        "",
    ]
    current_asset = current_group = current_segment = None
    for row in sorted(index_rows, key=lambda r: (r["asset_class"], r["market_group"], r["market_segment"], r["ranking_group"])):
        if row["asset_class"] != current_asset:
            current_asset = row["asset_class"]
            current_group = current_segment = None
            lines.append(f"{current_asset}/")
        if row["market_group"] != current_group:
            current_group = row["market_group"]
            current_segment = None
            lines.append(f"  {current_group}/")
        if row["market_segment"] != current_segment:
            current_segment = row["market_segment"]
            lines.append(f"    {current_segment}/")
        lines.append(f"      {row['ranking_group']}/ leader={row['leader_symbol']} score={row['leader_score']} top5={row['top5_available']}")
    lines.append("")
    return "\n".join(lines)


def _index_text(summary: L11TreeSummary) -> str:
    return "\n".join([
        "L11 SELECTION DESK TAXONOMY TREE STATUS",
        "----------------------------------------",
        f"schema_name={TREE_SCHEMA_NAME}",
        f"schema_version={TREE_SCHEMA_VERSION}",
        f"status={summary.status}",
        f"reason={summary.reason}",
        f"taxonomy_tree_rows={summary.taxonomy_tree_rows}",
        f"taxonomy_tree_files_written={summary.taxonomy_tree_files_written}",
        f"taxonomy_tree_files_expected={summary.taxonomy_tree_files_expected}",
        f"taxonomy_tree_rank_cards_written={summary.taxonomy_tree_rank_cards_written}",
        f"taxonomy_tree_rank_cards_expected={summary.taxonomy_tree_rank_cards_expected}",
        f"stale_rank_cards_removed={summary.stale_rank_cards_removed}",
        f"write_failed_count={summary.write_failed_count}",
        "selection_runtime=false",
        "trade_permission=false",
        "entry_signal=false",
        "execution=false",
        f"generated_utc={utc_stamp()}",
        f"generated_unix={unix_time()}",
        "",
    ])


def _write_level_indexes(base_dir: Path, rows: List[Dict[str, str]], failed: List[Path]) -> int:
    written = 0
    by_asset: Dict[str, List[Dict[str, str]]] = defaultdict(list)
    for row in rows:
        by_asset[row["asset_class_slug"]].append(row)
    for asset_slug, asset_rows in by_asset.items():
        asset_dir = base_dir / asset_slug
        text = "\n".join(["L11 ASSET CLASS INDEX", "----------------------------------------", f"asset_class={asset_rows[0]['asset_class']}", f"ranking_group_path_count={len(asset_rows)}", "selection_runtime=false", "trade_permission=false", "entry_signal=false", "execution=false", ""])
        if _write(asset_dir / "00_Asset_Class_Index.txt", text, failed):
            written += 1
        by_mg: Dict[str, List[Dict[str, str]]] = defaultdict(list)
        for row in asset_rows:
            by_mg[row["market_group_slug"]].append(row)
        for mg_slug, mg_rows in by_mg.items():
            mg_dir = asset_dir / mg_slug
            text = "\n".join(["L11 MARKET GROUP INDEX", "----------------------------------------", f"asset_class={mg_rows[0]['asset_class']}", f"market_group={mg_rows[0]['market_group']}", f"ranking_group_path_count={len(mg_rows)}", "selection_runtime=false", "trade_permission=false", "entry_signal=false", "execution=false", ""])
            if _write(mg_dir / "00_Market_Group_Index.txt", text, failed):
                written += 1
            by_seg: Dict[str, List[Dict[str, str]]] = defaultdict(list)
            for row in mg_rows:
                by_seg[row["market_segment_slug"]].append(row)
            for seg_slug, seg_rows in by_seg.items():
                seg_dir = mg_dir / seg_slug
                text = "\n".join(["L11 MARKET SEGMENT INDEX", "----------------------------------------", f"asset_class={seg_rows[0]['asset_class']}", f"market_group={seg_rows[0]['market_group']}", f"market_segment={seg_rows[0]['market_segment']}", f"ranking_group_path_count={len(seg_rows)}", "selection_runtime=false", "trade_permission=false", "entry_signal=false", "execution=false", ""])
                if _write(seg_dir / "00_Market_Segment_Index.txt", text, failed):
                    written += 1
    return written


def _cleanup_old_rank_cards(group_folder: Path, expected_names: Iterable[str]) -> int:
    expected = set(expected_names)
    removed = 0
    for path in group_folder.glob("*.txt"):
        if not re.match(r"^\d{2}_.+\.txt$", path.name):
            continue
        if path.name in expected:
            continue
        try:
            path.unlink()
            removed += 1
        except OSError:
            pass
    return removed


def publish_l11_selection_desk_taxonomy_tree(root: Path) -> L11TreeSummary:
    paths = WorkerPaths.from_root(root)
    layer_dir = paths.outbox / "Layers" / L11_LAYER_FOLDER
    ranked_path = layer_dir / "ranked_symbols_by_group.csv"
    base_dir = _selection_groups_dir(root)
    if not ranked_path.exists():
        return L11TreeSummary("pending", f"missing_ranked_symbols_by_group:{ranked_path}")

    rows = _csv_rows(read_text(ranked_path))
    if not rows:
        return L11TreeSummary("pending", "ranked_symbols_by_group_empty")

    failed: List[Path] = []
    index_rows: List[Dict[str, str]] = []
    files_written = 0
    files_expected = 0
    rank_cards_written = 0
    rank_cards_expected = 0
    stale_removed = 0

    grouped: Dict[Tuple[str, str, str, str], List[Dict[str, str]]] = defaultdict(list)
    for row in rows:
        key = (_display(row.get("asset_class")), _display(row.get("market_group")), _display(row.get("market_segment")), _display(row.get("ranking_group")))
        grouped[key].append(row)

    for (asset_class, market_group, market_segment, ranking_group), group_rows in sorted(grouped.items()):
        group_rows.sort(key=_rank_value)
        top5 = [r for r in group_rows if _is_top5(r)][:5]
        asset_slug = _sanitize(asset_class)
        market_group_slug = _sanitize(market_group)
        market_segment_slug = _sanitize(market_segment)
        ranking_group_slug = _sanitize(ranking_group)
        group_folder = base_dir / asset_slug / market_group_slug / market_segment_slug / ranking_group_slug
        group_folder.mkdir(parents=True, exist_ok=True)

        group_csv = _csv_text(group_rows, TOP5_FIELDS)
        top5_csv = _csv_text(top5, TOP5_FIELDS)
        group_summary = _group_summary_text(ranking_group, group_rows, top5, group_folder)
        top5_text = "\n".join(["L11 TOP 5 CURRENT", "----------------------------------------", f"Ranking Group: {ranking_group}"] + [f"#{r.get('ranking_group_rank')} {r.get('symbol')} score={r.get('l11_group_score')} state={r.get('rank_state')} leader={r.get('leader_flag')} backup={r.get('backup_flag')}" for r in top5] + ["Selection Runtime: FALSE", "Trade Permission: FALSE", "Entry Signal: FALSE", "Execution: FALSE", ""])

        for filename, content in [
            ("00_Group_Summary.txt", group_summary),
            ("00_Group_Ranked_Symbols.csv", group_csv),
            ("00_Top5_Current.txt", top5_text),
            ("00_Top5_Current.csv", top5_csv),
        ]:
            files_expected += 1
            if _write(group_folder / filename, content, failed):
                files_written += 1

        expected_rank_card_names = []
        for row in top5:
            filename = _rank_card_name(row)
            expected_rank_card_names.append(filename)
            rank_cards_expected += 1
            dossier_hint = f"Dossiers/Open/{row.get('symbol', 'not_available')}.txt"
            if _write(group_folder / filename, _rank_card_text(row, dossier_hint), failed):
                rank_cards_written += 1
        stale_removed += _cleanup_old_rank_cards(group_folder, expected_rank_card_names)

        leader = top5[0] if top5 else {}
        not_rankable = [r for r in group_rows if str(r.get("rank_state", "")).startswith("not_rankable")]
        risk_review = [r for r in group_rows if str(r.get("risk_review_flag", "")).lower() == "true"]
        source_checksum = payload_checksum([ranking_group, str(len(group_rows)), str(len(top5))])
        index_rows.append({
            "asset_class": asset_class,
            "market_group": market_group,
            "market_segment": market_segment,
            "ranking_group": ranking_group,
            "asset_class_slug": asset_slug,
            "market_group_slug": market_group_slug,
            "market_segment_slug": market_segment_slug,
            "ranking_group_slug": ranking_group_slug,
            "group_symbol_count": str(len(group_rows)),
            "rankable_count": str(len(group_rows) - len(not_rankable)),
            "not_rankable_count": str(len(not_rankable)),
            "top5_available": "true" if top5 else "false",
            "leader_symbol": leader.get("symbol", "not_available"),
            "leader_score": leader.get("l11_group_score", "not_available"),
            "risk_review_count": str(len(risk_review)),
            "tree_folder": str(group_folder),
            "summary_file": str(group_folder / "00_Group_Summary.txt"),
            "ranked_symbols_file": str(group_folder / "00_Group_Ranked_Symbols.csv"),
            "top5_text_file": str(group_folder / "00_Top5_Current.txt"),
            "top5_csv_file": str(group_folder / "00_Top5_Current.csv"),
            "rank_card_count": str(len(top5)),
            "selection_runtime": "false",
            "trade_permission": "false",
            "entry_signal": "false",
            "execution": "false",
            "source_checksum": source_checksum,
        })

    files_written += _write_level_indexes(base_dir, index_rows, failed)
    tree_csv = _csv_text(index_rows, TREE_INDEX_FIELDS)
    tree_txt = _taxonomy_tree_text(index_rows)
    for path, content in [(base_dir / "00_Taxonomy_Tree.csv", tree_csv), (base_dir / "00_Taxonomy_Tree.txt", tree_txt)]:
        files_expected += 1
        if _write(path, content, failed):
            files_written += 1

    status = "accepted" if not failed and files_written >= files_expected and rank_cards_written >= rank_cards_expected else "write_degraded"
    reason = "l11_selection_desk_taxonomy_tree_published" if status == "accepted" else "one_or_more_l11_taxonomy_tree_outputs_failed"
    summary = L11TreeSummary(status, reason, len(index_rows), files_written, files_expected, rank_cards_written, rank_cards_expected, stale_removed, len(failed), str(base_dir / "00_Taxonomy_Tree.txt"), str(base_dir / "00_Taxonomy_Tree.csv"))
    _write(base_dir / "00_Taxonomy_Tree_Status.txt", _index_text(summary), failed)
    return summary
