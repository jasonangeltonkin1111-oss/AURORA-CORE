from __future__ import annotations

from collections import defaultdict
from pathlib import Path
from typing import Dict, List

from aurora_worker_io import utc_stamp, unix_time
from aurora_worker_selection_surface_shortcuts import (
    SelectionShortcutSummary,
    _account_root,
    _cleanup_ranked_txt,
    _copy_dossier_or_placeholder,
    _csv_rows,
    _csv_text,
    _display,
    _ranked_file_name,
    _ranked_symbols_path,
    _sanitize,
    _selection_desk,
    _shortcut_status_text,
    _write,
)

GROUP_TOP5_FIELDS = [
    "group_shortcut_rank", "symbol", "canonical_symbol", "asset_class", "market_group", "market_segment", "ranking_group",
    "ranking_group_rank", "rankable_count", "l11_group_score", "rank_state", "leader_flag", "backup_flag",
    "l5_gate_state", "l6_score", "l6_state", "l7_score", "l7_state", "l8_score", "l8_state", "l9_score", "l9_state",
    "risk_review_flag", "reason", "source_dossier_path", "target_dossier_path", "copy_status",
    "selection_runtime", "trade_permission", "entry_signal", "execution", "generated_utc",
]


def _rank_value(row: Dict[str, str]) -> int:
    try:
        return int(float(str(row.get("ranking_group_rank", "999999")).strip()))
    except ValueError:
        return 999999


def _is_top5(row: Dict[str, str]) -> bool:
    return str(row.get("in_top5_per_ranking_group", "")).strip().lower() == "true" and _rank_value(row) <= 5


def _shallow_group_folder(root: Path, asset_class: str, ranking_group: str) -> Path:
    return _selection_desk(root) / "02_Asset_Classes" / _sanitize(asset_class) / "02_Groups" / _sanitize(ranking_group)


def _group_text(asset_class: str, ranking_group: str, rows: List[Dict[str, str]], folder: Path) -> str:
    market_groups = sorted({_display(r.get("market_group")) for r in rows})
    market_segments = sorted({_display(r.get("market_segment")) for r in rows})
    lines = [
        "L11 SHALLOW RANKING GROUP TOP 5",
        "----------------------------------------",
        "meaning=ranking_group_inspection_shortcut_only",
        "source=L11 ranked_symbols_by_group.csv existing ranks",
        "score_owner=Layer 11 Symbol Ranking Inside Ranking Group",
        "dossier_policy=copied_from_source_dossier_when_available",
        f"asset_class={asset_class}",
        f"ranking_group={ranking_group}",
        f"market_groups={';'.join(market_groups) if market_groups else 'not_available'}",
        f"market_segments={';'.join(market_segments) if market_segments else 'not_available'}",
        f"folder={folder}",
        f"selected_count={len(rows)}",
        "selection_runtime=false",
        "trade_permission=false",
        "entry_signal=false",
        "execution=false",
        "",
        "TOP 5 PER RANKING GROUP",
    ]
    for row in rows:
        lines.append(
            f"#{row['group_shortcut_rank']} {row['symbol']} score={row.get('l11_group_score','not_available')} "
            f"rank={row.get('ranking_group_rank','not_available')} market_group={row.get('market_group','Unknown')} segment={row.get('market_segment','Unknown')} copy={row.get('copy_status','not_available')}"
        )
    if not rows:
        lines.append("not_available")
    lines.extend(["", f"generated_utc={utc_stamp()}", ""])
    return "\n".join(lines)


def _asset_group_index_text(asset_class: str, rows: List[Dict[str, str]]) -> str:
    lines = [
        f"SHALLOW RANKING GROUP INDEX - {asset_class}",
        "----------------------------------------",
        "meaning=asset_class_group_shortcut_index_only",
        "source=L11 ranked_symbols_by_group.csv existing ranks",
        "selection_runtime=false",
        "trade_permission=false",
        "entry_signal=false",
        "execution=false",
        "",
    ]
    for row in rows:
        lines.append(f"{row['ranking_group']} -> {row['folder']} selected={row['selected_count']} top={row['top_symbol']}")
    lines.extend(["", f"generated_utc={utc_stamp()}", ""])
    return "\n".join(lines)


def publish_l11_shallow_group_shortcuts(root: Path) -> SelectionShortcutSummary:
    failed: List[Path] = []
    ranked_path = _ranked_symbols_path(root)
    status_path = _selection_desk(root) / "02_Asset_Classes" / "00_Shallow_Group_Top5_Status.txt"
    if not ranked_path.exists():
        summary = SelectionShortcutSummary("pending", f"missing_ranked_symbols_by_group:{ranked_path}", "shallow_group_top5", 0, 0, 0, 0, 0, 0, len(failed), str(status_path))
        _write(status_path, _shortcut_status_text(summary), failed)
        return summary

    rows = [row for row in _csv_rows(ranked_path) if _is_top5(row)]
    if not rows:
        summary = SelectionShortcutSummary("pending", "no_top5_rows_available_for_shallow_group_shortcuts", "shallow_group_top5", 0, 0, 0, 0, 0, 0, len(failed), str(status_path))
        _write(status_path, _shortcut_status_text(summary), failed)
        return summary

    account_root = _account_root(root)
    grouped: Dict[tuple[str, str], List[Dict[str, str]]] = defaultdict(list)
    for row in rows:
        grouped[(_display(row.get("asset_class")), _display(row.get("ranking_group")))].append(row)

    files_written = 0
    files_expected = 0
    copies_written = 0
    copies_expected = 0
    missing = 0
    stale_removed = 0
    by_asset_index: Dict[str, List[Dict[str, str]]] = defaultdict(list)

    for (asset_class, ranking_group), group_rows in sorted(grouped.items()):
        group_rows.sort(key=_rank_value)
        folder = _shallow_group_folder(root, asset_class, ranking_group)
        folder.mkdir(parents=True, exist_ok=True)
        expected_names: List[str] = []
        output_rows: List[Dict[str, str]] = []
        for rank, row in enumerate(group_rows[:5], 1):
            symbol = str(row.get("symbol", "")).strip()
            target_name = _ranked_file_name(rank, symbol)
            expected_names.append(target_name)
            target = folder / target_name
            copies_expected += 1
            ok, source_missing, source_path = _copy_dossier_or_placeholder(account_root, symbol, target, failed)
            if ok:
                copies_written += 1
            if source_missing:
                missing += 1
            output_rows.append({
                "group_shortcut_rank": str(rank),
                "symbol": symbol,
                "canonical_symbol": row.get("canonical_symbol", symbol),
                "asset_class": asset_class,
                "market_group": row.get("market_group", "Unknown"),
                "market_segment": row.get("market_segment", "Unknown"),
                "ranking_group": ranking_group,
                "ranking_group_rank": row.get("ranking_group_rank", "not_available"),
                "rankable_count": row.get("rankable_count", "not_available"),
                "l11_group_score": row.get("l11_group_score", "not_available"),
                "rank_state": row.get("rank_state", "not_available"),
                "leader_flag": row.get("leader_flag", "false"),
                "backup_flag": row.get("backup_flag", "false"),
                "l5_gate_state": row.get("l5_gate_state", "not_available"),
                "l6_score": row.get("l6_score", "not_available"), "l6_state": row.get("l6_state", "not_available"),
                "l7_score": row.get("l7_score", "not_available"), "l7_state": row.get("l7_state", "not_available"),
                "l8_score": row.get("l8_score", "not_available"), "l8_state": row.get("l8_state", "not_available"),
                "l9_score": row.get("l9_score", "not_available"), "l9_state": row.get("l9_state", "not_available"),
                "risk_review_flag": row.get("risk_review_flag", "false"),
                "reason": row.get("reason", "shallow_group_top5_existing_l11_rank"),
                "source_dossier_path": source_path,
                "target_dossier_path": str(target),
                "copy_status": "source_copied" if ok else ("source_missing_placeholder_written" if source_missing else "copy_failed"),
                "selection_runtime": "false", "trade_permission": "false", "entry_signal": "false", "execution": "false",
                "generated_utc": utc_stamp(),
            })
        stale_removed += _cleanup_ranked_txt(folder, expected_names)
        for path, text in [
            (folder / "00_Group_Summary.txt", _group_text(asset_class, ranking_group, output_rows, folder)),
            (folder / "00_Top5_Current.txt", _group_text(asset_class, ranking_group, output_rows, folder)),
            (folder / "00_Top5_Current.csv", _csv_text(output_rows, GROUP_TOP5_FIELDS)),
        ]:
            files_expected += 1
            if _write(path, text, failed):
                files_written += 1
        by_asset_index[asset_class].append({
            "asset_class": asset_class,
            "ranking_group": ranking_group,
            "folder": str(folder),
            "selected_count": str(len(output_rows)),
            "top_symbol": output_rows[0]["symbol"] if output_rows else "not_available",
            "trade_permission": "false",
            "entry_signal": "false",
            "execution": "false",
        })

    index_fields = ["asset_class", "ranking_group", "folder", "selected_count", "top_symbol", "trade_permission", "entry_signal", "execution"]
    for asset_class, index_rows in sorted(by_asset_index.items()):
        asset_dir = _selection_desk(root) / "02_Asset_Classes" / _sanitize(asset_class)
        for path, text in [
            (asset_dir / "02_Groups" / "00_Group_Top5_Index.txt", _asset_group_index_text(asset_class, index_rows)),
            (asset_dir / "02_Groups" / "00_Group_Top5_Index.csv", _csv_text(index_rows, index_fields)),
        ]:
            files_expected += 1
            if _write(path, text, failed):
                files_written += 1

    status = "accepted" if not failed and missing == 0 and copies_written == copies_expected else "write_degraded"
    reason = "shallow_group_top5_shortcuts_published" if status == "accepted" else "one_or_more_shallow_group_top5_shortcuts_missing_or_failed"
    summary = SelectionShortcutSummary(status, reason, "shallow_group_top5", files_written, files_expected, copies_written, copies_expected, missing, stale_removed, len(failed), str(status_path))
    _write(status_path, _shortcut_status_text(summary), failed)
    return summary
