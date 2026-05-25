from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Sequence
import csv
import io
import re

from aurora_worker_io import WorkerPaths, atomic_write_text, read_text, utc_stamp, unix_time

L11_LAYER_FOLDER = "Layer_11_Symbol_Ranking_Inside_Ranking_Group"
TOP5_TARGET_COUNT = 5
GLOBAL_TOP10_TARGET_COUNT = 10

ASSET_TOP5_FIELDS = [
    "asset_class_top5_rank", "symbol", "canonical_symbol", "asset_class", "market_group", "market_segment", "ranking_group",
    "ranking_group_rank", "rankable_count", "l11_group_score", "rank_state", "leader_flag", "backup_flag",
    "l5_gate_state", "l6_score", "l6_state", "l7_score", "l7_state", "l8_score", "l8_state", "l9_score", "l9_state",
    "risk_review_flag", "reason", "selection_runtime", "trade_permission", "entry_signal", "execution", "generated_utc",
]

GLOBAL_DOSSIER_FIELDS = [
    "global_top10_rank", "symbol", "canonical_symbol", "asset_class", "market_group", "market_segment", "ranking_group",
    "l16_primary_score", "selection_tier", "clean_diversified", "max_corr_to_selected", "max_corr_pair_symbol",
    "source_dossier_path", "target_dossier_path", "copy_status", "meaning", "trade_permission", "entry_signal", "execution", "generated_utc",
]


@dataclass(frozen=True)
class SelectionShortcutSummary:
    status: str
    reason: str
    shortcut_type: str = "not_available"
    files_written: int = 0
    files_expected: int = 0
    dossier_copies_written: int = 0
    dossier_copies_expected: int = 0
    dossier_sources_missing: int = 0
    stale_files_removed: int = 0
    write_failed_count: int = 0
    status_path: str = "not_available"


EMPTY_SELECTION_SHORTCUT_SUMMARY = SelectionShortcutSummary("pending", "selection_shortcut_not_run")


def _sanitize(value: str) -> str:
    safe = str(value or "").strip() or "Unknown"
    safe = safe.replace("&", "and")
    safe = re.sub(r"[\\/:*?\"<>|]+", "_", safe)
    safe = re.sub(r"\s+", "_", safe)
    safe = re.sub(r"_+", "_", safe).strip("_.")
    return safe or "Unknown"


def _display(value: str) -> str:
    return str(value or "").strip() or "Unknown"


def _num(value: str | None, default: float = -1.0) -> float:
    try:
        return float(str(value or "").strip())
    except ValueError:
        return default


def _int(value: str | None, default: int = 999999) -> int:
    try:
        return int(float(str(value or str(default)).strip()))
    except ValueError:
        return default


def _csv_rows(path: Path) -> List[Dict[str, str]]:
    if not path.exists():
        return []
    text = read_text(path).replace("\r\n", "\n")
    if not text.strip():
        return []
    reader = csv.DictReader(io.StringIO(text))
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


def _account_root(root: Path) -> Path:
    return WorkerPaths.from_root(root).outbox.parents[2]


def _selection_desk(root: Path) -> Path:
    return _account_root(root) / "Selection Desk"


def _asset_classes_dir(root: Path) -> Path:
    return _selection_desk(root) / "02_Asset_Classes"


def _clean_global_top10_dir(root: Path) -> Path:
    return _selection_desk(root) / "01_Global" / "Top_10"


def _ranked_symbols_path(root: Path) -> Path:
    return WorkerPaths.from_root(root).outbox / "Layers" / L11_LAYER_FOLDER / "ranked_symbols_by_group.csv"


def _legacy_global_top10_csv(root: Path) -> Path:
    return _selection_desk(root) / "Global" / "current_top10.csv"


def _candidate_dossier_paths(account_root: Path, symbol: str) -> List[Path]:
    clean_symbol = str(symbol or "").strip()
    if clean_symbol == "":
        return []
    safe_symbol = _sanitize(clean_symbol)
    names: List[str] = []
    for base in (clean_symbol, safe_symbol):
        names.extend([base, f"{base}.txt"])
    unique_names: List[str] = []
    seen = set()
    for name in names:
        if name not in seen:
            unique_names.append(name)
            seen.add(name)
    candidates: List[Path] = []
    for state in ("Open", "Closed", "Unknown"):
        folder = account_root / "Dossiers" / state
        for name in unique_names:
            candidates.append(folder / name)
    return candidates


def _find_dossier(account_root: Path, symbol: str) -> Optional[Path]:
    for path in _candidate_dossier_paths(account_root, symbol):
        if path.exists() and path.is_file():
            return path
    dossiers_root = account_root / "Dossiers"
    if not dossiers_root.exists():
        return None
    clean_symbol = str(symbol or "").strip()
    safe_symbol = _sanitize(clean_symbol)
    wanted = {clean_symbol.lower(), f"{clean_symbol}.txt".lower(), safe_symbol.lower(), f"{safe_symbol}.txt".lower()}
    for path in dossiers_root.rglob("*.txt"):
        if path.name.lower() in wanted:
            return path
    return None


def _shortcut_overlay_text(symbol: str, overlay_lines: Sequence[str] | None, source_path: str, source_missing: bool) -> str:
    lines = [
        "AURORA CURRENT SELECTION SHORTCUT TRUTH",
        "----------------------------------------",
        f"symbol={symbol}",
        "shortcut_truth_owner=selection_surface_shortcut_copy_bridge",
        "shortcut_truth_priority=current_selection_overlay_over_base_dossier_body",
        "base_dossier_body_policy=historical_body_may_lag_current_selection_overlay",
        f"source_dossier_path={source_path}",
        f"source_dossier_missing={'true' if source_missing else 'false'}",
    ]
    if overlay_lines:
        for line in overlay_lines:
            clean = str(line).strip()
            if clean:
                lines.append(clean)
    lines.extend([
        "selection_runtime=false",
        "trade_permission=false",
        "entry_signal=false",
        "execution=false",
        f"shortcut_generated_utc={utc_stamp()}",
        f"shortcut_generated_unix={unix_time()}",
        "",
        "STALE-SECTION WARNING",
        "Base dossier content below may be older than this current shortcut overlay if the bounded dossier renderer has not refreshed this symbol yet.",
        "Read the overlay above as the current Selection Desk truth for this shortcut file.",
        "----------------------------------------",
        "",
    ])
    return "\n".join(lines)


def _global_shortcut_overlay(row: Dict[str, str], rank: int) -> List[str]:
    return [
        "shortcut_type=global_top10_dossier_copy",
        "current_selection_source=Selection Desk/Global/current_top10.csv",
        "current_selection_member=true",
        f"current_l16_rank={rank}",
        f"current_l16_symbol={row.get('symbol', 'not_available')}",
        f"current_l16_selection_tier={row.get('selection_tier', 'not_available')}",
        f"current_l16_clean_diversified={row.get('clean_diversified', 'false')}",
        f"current_l16_primary_score={row.get('l16_primary_score', 'not_available')}",
        f"current_l16_max_corr_to_selected={row.get('max_corr_to_selected', 'not_available')}",
        f"current_l16_max_corr_pair_symbol={row.get('max_corr_pair_symbol', 'not_available')}",
        f"current_ranking_group={row.get('ranking_group', 'Unknown')}",
        f"current_asset_class={row.get('asset_class', 'Unknown')}",
        f"current_market_group={row.get('market_group', 'Unknown')}",
        f"current_market_segment={row.get('market_segment', 'Unknown')}",
        "current_l16_meaning=global_top10_inspection_basket_only_not_trade_permission",
    ]


def _asset_shortcut_overlay(row: Dict[str, str], asset: str, rank: int) -> List[str]:
    return [
        "shortcut_type=asset_class_top5_dossier_copy",
        "current_selection_source=L11 ranked_symbols_by_group.csv",
        "current_selection_member=true",
        f"current_asset_class_top5_rank={rank}",
        f"current_asset_class={asset}",
        f"current_symbol={row.get('symbol', 'not_available')}",
        f"current_l11_group_score={row.get('l11_group_score', 'not_available')}",
        f"current_ranking_group={row.get('ranking_group', 'Unknown')}",
        f"current_market_group={row.get('market_group', 'Unknown')}",
        f"current_market_segment={row.get('market_segment', 'Unknown')}",
        "current_l11_meaning=asset_class_inspection_shortcut_only_not_trade_permission",
    ]


def _copy_dossier_or_placeholder(account_root: Path, symbol: str, target: Path, failed: List[Path], overlay_lines: Sequence[str] | None = None) -> tuple[bool, bool, str]:
    source = _find_dossier(account_root, symbol)
    if source is None:
        text = _shortcut_overlay_text(symbol, overlay_lines, "not_available", True) + "\n".join([
            "AURORA SELECTION SURFACE DOSSIER COPY PLACEHOLDER",
            "----------------------------------------",
            f"symbol={symbol}",
            "status=degraded",
            "reason=source_dossier_missing",
            "source_owner=Runtime 7 Dossier publication owner output",
            "copy_bridge=selection_surface_shortcut_copy_only",
            "dossier_rerendered=false",
            "selection_runtime=false",
            "trade_permission=false",
            "entry_signal=false",
            "execution=false",
            f"generated_utc={utc_stamp()}",
            f"generated_unix={unix_time()}",
            "",
        ])
        if not _write(target, text, failed):
            return False, False, "not_available"
        return False, True, "not_available"
    try:
        target.parent.mkdir(parents=True, exist_ok=True)
        source_text = read_text(source)
        text = _shortcut_overlay_text(symbol, overlay_lines, str(source), False) + source_text
        if not text.endswith("\n"):
            text += "\n"
        if not _write(target, text, failed):
            return False, False, str(source)
        return True, False, str(source)
    except OSError:
        failed.append(target)
        return False, False, str(source)


def _cleanup_ranked_txt(folder: Path, expected_names: Iterable[str]) -> int:
    expected = set(expected_names)
    removed = 0
    if not folder.exists():
        return 0
    for path in folder.glob("*.txt"):
        if path.name.startswith("00_"):
            continue
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


def _ranked_file_name(rank: int, symbol: str) -> str:
    return f"{rank:02d}_{_sanitize(symbol)}.txt"


def _asset_top5_text(asset_class: str, rows: List[Dict[str, str]], folder: Path) -> str:
    lines = [
        f"L11 ASSET CLASS TOP 5 - {asset_class}",
        "----------------------------------------",
        "meaning=asset_class_inspection_shortcut_only",
        "source=L11 ranked_symbols_by_group.csv existing scores",
        "score_owner=Layer 11 Symbol Ranking Inside Ranking Group",
        "dossier_policy=copied_from_source_dossier_with_current_shortcut_overlay_when_available",
        f"folder={folder}",
        f"selected_count={len(rows)}",
        "selection_runtime=false",
        "trade_permission=false",
        "entry_signal=false",
        "execution=false",
        "",
        "TOP 5 ALL ASSET CLASS",
    ]
    for row in rows:
        lines.append(
            f"#{row['asset_class_top5_rank']} {row['symbol']} score={row.get('l11_group_score','not_available')} "
            f"group={row.get('ranking_group','Unknown')} market_group={row.get('market_group','Unknown')} segment={row.get('market_segment','Unknown')}"
        )
    if not rows:
        lines.append("not_available")
    lines.extend(["", f"generated_utc={utc_stamp()}", ""])
    return "\n".join(lines)


def _root_readme_text() -> str:
    return "\n".join([
        "AURORA SELECTION DESK",
        "----------------------------------------",
        "01_Global/Top_10 = Global Top 10 inspection basket with copied dossier files plus current shortcut overlays.",
        "02_Asset_Classes/<asset_class>/01_Top_5_All_<asset_class> = top 5 shortcut for the whole asset class.",
        "02_Asset_Classes/<asset_class>/<market_group>/<market_segment>/<ranking_group> = original deep Top 5 per ranking_group system.",
        "90_System_Indexes = root indexes and taxonomy proof surfaces.",
        "91_Layer_Summaries = layer summary copies for operator review.",
        "All shortcut folders are copy/view surfaces only. They do not calculate trade permission, entry signal, or execution.",
        "Shortcut file overlays are current Selection Desk truth and outrank stale base dossier body text below them.",
        f"generated_utc={utc_stamp()}",
        "",
    ])


def _publish_root_scaffold(root: Path, failed: List[Path]) -> int:
    desk = _selection_desk(root)
    written = 0
    for folder in [desk / "01_Global", desk / "02_Asset_Classes", desk / "90_System_Indexes", desk / "91_Layer_Summaries"]:
        folder.mkdir(parents=True, exist_ok=True)
    if _write(desk / "00_Read_Me.txt", _root_readme_text(), failed):
        written += 1
    legacy_index = desk / "Selection Index.txt"
    if legacy_index.exists():
        if _write(desk / "00_Selection_Index.txt", read_text(legacy_index), failed):
            written += 1
    else:
        if _write(desk / "00_Selection_Index.txt", "status=pending\nreason=legacy_selection_index_missing\ntrade_permission=false\n", failed):
            written += 1

    groups = desk / "Groups"
    system_targets = {
        "00_Group_Index.txt": desk / "90_System_Indexes" / "00_Group_Index.txt",
        "00_Group_Index.csv": desk / "90_System_Indexes" / "00_Group_Index.csv",
        "00_Taxonomy_Tree.txt": desk / "90_System_Indexes" / "00_Taxonomy_Tree.txt",
        "00_Taxonomy_Tree.csv": desk / "90_System_Indexes" / "00_Taxonomy_Tree.csv",
        "00_Taxonomy_Tree_Status.txt": desk / "90_System_Indexes" / "00_Taxonomy_Tree_Status.txt",
        "00_Dossier_Copy_Status.txt": desk / "90_System_Indexes" / "00_Dossier_Copy_Status.txt",
    }
    for src_name, dst in system_targets.items():
        src = groups / src_name
        if src.exists():
            if _write(dst, read_text(src), failed):
                written += 1

    summary_targets = {
        "00_Group_Heat_Quality_Index.txt": desk / "91_Layer_Summaries" / "L12_Group_Heat_Quality" / "00_Group_Heat_Quality_Index.txt",
        "00_Group_Heat_Quality_Index.csv": desk / "91_Layer_Summaries" / "L12_Group_Heat_Quality" / "00_Group_Heat_Quality_Index.csv",
        "00_Selected_Ranking_Groups.txt": desk / "91_Layer_Summaries" / "L13_Selected_Ranking_Groups" / "00_Selected_Ranking_Groups.txt",
        "00_Selected_Ranking_Groups.csv": desk / "91_Layer_Summaries" / "L13_Selected_Ranking_Groups" / "00_Selected_Ranking_Groups.csv",
        "00_Ranking_Group_Leader_Candidate_Pool.txt": desk / "91_Layer_Summaries" / "L14_Candidate_Pool" / "00_Ranking_Group_Leader_Candidate_Pool.txt",
        "00_Ranking_Group_Leader_Candidate_Pool.csv": desk / "91_Layer_Summaries" / "L14_Candidate_Pool" / "00_Ranking_Group_Leader_Candidate_Pool.csv",
        "00_Correlation_Diversity_Summary.txt": desk / "91_Layer_Summaries" / "L15_Correlation_Diversity" / "00_Correlation_Diversity_Summary.txt",
        "00_Correlation_Diversity_Summary.csv": desk / "91_Layer_Summaries" / "L15_Correlation_Diversity" / "00_Correlation_Diversity_Summary.csv",
    }
    for src_name, dst in summary_targets.items():
        src = groups / src_name
        if src.exists():
            dst.parent.mkdir(parents=True, exist_ok=True)
            if _write(dst, read_text(src), failed):
                written += 1
    return written


def publish_l11_asset_class_shortcuts(root: Path) -> SelectionShortcutSummary:
    failed: List[Path] = []
    scaffold_written = _publish_root_scaffold(root, failed)
    ranked_path = _ranked_symbols_path(root)
    status_path = _asset_classes_dir(root) / "00_Asset_Class_Top5_Status.txt"
    if not ranked_path.exists():
        summary = SelectionShortcutSummary("pending", f"missing_ranked_symbols_by_group:{ranked_path}", "asset_class_top5", scaffold_written, scaffold_written, 0, 0, 0, 0, len(failed), str(status_path))
        _write(status_path, _shortcut_status_text(summary), failed)
        return summary

    rows = _csv_rows(ranked_path)
    if not rows:
        summary = SelectionShortcutSummary("pending", "ranked_symbols_by_group_empty", "asset_class_top5", scaffold_written, scaffold_written, 0, 0, 0, 0, len(failed), str(status_path))
        _write(status_path, _shortcut_status_text(summary), failed)
        return summary

    account_root = _account_root(root)
    by_asset: Dict[str, List[Dict[str, str]]] = {}
    for row in rows:
        symbol = str(row.get("symbol", "")).strip()
        if not symbol:
            continue
        rank_state = str(row.get("rank_state", "")).lower()
        if rank_state.startswith("not_rankable"):
            continue
        asset = _display(row.get("asset_class"))
        by_asset.setdefault(asset, []).append(row)

    written = scaffold_written
    expected = scaffold_written
    copied = 0
    copy_expected = 0
    missing = 0
    stale_removed = 0
    index_rows: List[Dict[str, str]] = []

    for asset, asset_rows in sorted(by_asset.items()):
        asset_slug = _sanitize(asset)
        folder = _asset_classes_dir(root) / asset_slug / f"01_Top_5_All_{asset_slug}"
        folder.mkdir(parents=True, exist_ok=True)
        selected = sorted(asset_rows, key=lambda r: (-_num(r.get("l11_group_score"), -1.0), _int(r.get("ranking_group_rank")), str(r.get("symbol", ""))))[:TOP5_TARGET_COUNT]
        output_rows: List[Dict[str, str]] = []
        expected_names: List[str] = []
        for rank, row in enumerate(selected, 1):
            symbol = str(row.get("symbol", "")).strip()
            target_name = _ranked_file_name(rank, symbol)
            expected_names.append(target_name)
            target = folder / target_name
            copy_expected += 1
            ok, source_missing, source_path = _copy_dossier_or_placeholder(account_root, symbol, target, failed, _asset_shortcut_overlay(row, asset, rank))
            if ok:
                copied += 1
            if source_missing:
                missing += 1
            output_rows.append({
                "asset_class_top5_rank": str(rank),
                "symbol": symbol,
                "canonical_symbol": row.get("canonical_symbol", symbol),
                "asset_class": asset,
                "market_group": row.get("market_group", "Unknown"),
                "market_segment": row.get("market_segment", "Unknown"),
                "ranking_group": row.get("ranking_group", "Unknown"),
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
                "reason": row.get("reason", "asset_class_top5_existing_l11_score"),
                "selection_runtime": "false", "trade_permission": "false", "entry_signal": "false", "execution": "false",
                "generated_utc": utc_stamp(),
            })
        stale_removed += _cleanup_ranked_txt(folder, expected_names)
        for path, text in [
            (folder / f"00_Top_5_All_{asset_slug}.txt", _asset_top5_text(asset, output_rows, folder)),
            (folder / f"00_Top_5_All_{asset_slug}.csv", _csv_text(output_rows, ASSET_TOP5_FIELDS)),
        ]:
            expected += 1
            if _write(path, text, failed):
                written += 1
        index_rows.append({
            "asset_class": asset,
            "asset_class_slug": asset_slug,
            "top5_folder": str(folder),
            "selected_count": str(len(output_rows)),
            "top_symbol": output_rows[0]["symbol"] if output_rows else "not_available",
            "trade_permission": "false",
            "entry_signal": "false",
            "execution": "false",
        })

    index_fields = ["asset_class", "asset_class_slug", "top5_folder", "selected_count", "top_symbol", "trade_permission", "entry_signal", "execution"]
    for path, text in [
        (_asset_classes_dir(root) / "00_Asset_Class_Top5_Index.csv", _csv_text(index_rows, index_fields)),
        (_asset_classes_dir(root) / "00_Asset_Class_Top5_Index.txt", _asset_index_text(index_rows)),
    ]:
        expected += 1
        if _write(path, text, failed):
            written += 1

    status = "accepted" if not failed and missing == 0 and copied == copy_expected else "write_degraded"
    reason = "asset_class_top5_shortcuts_published" if status == "accepted" else "one_or_more_asset_class_shortcuts_missing_or_failed"
    summary = SelectionShortcutSummary(status, reason, "asset_class_top5", written, expected, copied, copy_expected, missing, stale_removed, len(failed), str(status_path))
    _write(status_path, _shortcut_status_text(summary), failed)
    return summary


def _asset_index_text(rows: List[Dict[str, str]]) -> str:
    lines = [
        "ASSET CLASS TOP 5 INDEX",
        "----------------------------------------",
        "meaning=asset_class_review_shortcuts_only",
        "source=L11 ranked_symbols_by_group.csv existing scores",
        "selection_runtime=false",
        "trade_permission=false",
        "entry_signal=false",
        "execution=false",
        "",
    ]
    for row in rows:
        lines.append(f"{row['asset_class']}/ top5={row['top5_folder']} selected={row['selected_count']} top={row['top_symbol']}")
    lines.extend(["", f"generated_utc={utc_stamp()}", ""])
    return "\n".join(lines)


def publish_l16_global_top10_shortcuts(root: Path) -> SelectionShortcutSummary:
    failed: List[Path] = []
    scaffold_written = _publish_root_scaffold(root, failed)
    csv_path = _legacy_global_top10_csv(root)
    folder = _clean_global_top10_dir(root)
    folder.mkdir(parents=True, exist_ok=True)
    status_path = folder / "00_Global_Top_10_Copy_Status.txt"
    if not csv_path.exists():
        text = "\n".join([
            "L16 GLOBAL TOP 10 DOSSIER SHORTCUTS",
            "----------------------------------------",
            "status=pending",
            f"reason=missing_current_top10_csv:{csv_path}",
            "global_top10_runtime=false",
            "trade_permission=false",
            "entry_signal=false",
            "execution=false",
            "",
        ])
        _write(folder / "00_Global_Top_10.txt", text, failed)
        _write(folder / "00_Global_Top_10.csv", _csv_text([], GLOBAL_DOSSIER_FIELDS), failed)
        summary = SelectionShortcutSummary("pending", f"missing_current_top10_csv:{csv_path}", "global_top10_dossier_copy", scaffold_written + 2, scaffold_written + 2, 0, 0, 0, 0, len(failed), str(status_path))
        _write(status_path, _shortcut_status_text(summary), failed)
        return summary

    rows = _csv_rows(csv_path)[:GLOBAL_TOP10_TARGET_COUNT]
    account_root = _account_root(root)
    copied = 0
    expected_copies = 0
    missing = 0
    output_rows: List[Dict[str, str]] = []
    expected_names: List[str] = []
    for idx, row in enumerate(rows, 1):
        symbol = str(row.get("symbol", "")).strip()
        if not symbol:
            continue
        rank = _int(row.get("global_top10_rank"), idx)
        target_name = _ranked_file_name(rank, symbol)
        expected_names.append(target_name)
        target = folder / target_name
        expected_copies += 1
        ok, source_missing, source_path = _copy_dossier_or_placeholder(account_root, symbol, target, failed, _global_shortcut_overlay(row, rank))
        if ok:
            copied += 1
        if source_missing:
            missing += 1
        output_rows.append({
            "global_top10_rank": str(rank),
            "symbol": symbol,
            "canonical_symbol": row.get("canonical_symbol", symbol),
            "asset_class": row.get("asset_class", "Unknown"),
            "market_group": row.get("market_group", "Unknown"),
            "market_segment": row.get("market_segment", "Unknown"),
            "ranking_group": row.get("ranking_group", "Unknown"),
            "l16_primary_score": row.get("l16_primary_score", "not_available"),
            "selection_tier": row.get("selection_tier", "not_available"),
            "clean_diversified": row.get("clean_diversified", "false"),
            "max_corr_to_selected": row.get("max_corr_to_selected", "not_available"),
            "max_corr_pair_symbol": row.get("max_corr_pair_symbol", "not_available"),
            "source_dossier_path": source_path,
            "target_dossier_path": str(target),
            "copy_status": "source_copied_with_current_overlay" if ok else ("source_missing_placeholder_with_current_overlay_written" if source_missing else "copy_failed"),
            "meaning": "global_top10_dossier_shortcut_only_not_trade_permission",
            "trade_permission": "false", "entry_signal": "false", "execution": "false",
            "generated_utc": utc_stamp(),
        })
    stale_removed = _cleanup_ranked_txt(folder, expected_names)
    files_written = scaffold_written
    files_expected = scaffold_written
    for path, text in [
        (folder / "00_Global_Top_10.txt", _global_top10_text(output_rows, folder)),
        (folder / "00_Global_Top_10.csv", _csv_text(output_rows, GLOBAL_DOSSIER_FIELDS)),
    ]:
        files_expected += 1
        if _write(path, text, failed):
            files_written += 1
    status = "accepted" if not failed and missing == 0 and copied == expected_copies else "write_degraded"
    reason = "global_top10_dossier_shortcuts_published_with_current_overlays" if status == "accepted" else "one_or_more_global_top10_dossier_copies_missing_or_failed"
    summary = SelectionShortcutSummary(status, reason, "global_top10_dossier_copy", files_written, files_expected, copied, expected_copies, missing, stale_removed, len(failed), str(status_path))
    _write(status_path, _shortcut_status_text(summary), failed)
    return summary


def _global_top10_text(rows: List[Dict[str, str]], folder: Path) -> str:
    lines = [
        "L16 GLOBAL TOP 10 DOSSIER SHORTCUTS",
        "----------------------------------------",
        "meaning=global_top10_inspection_basket_dossier_shortcuts_only",
        "source=Selection Desk/Global/current_top10.csv",
        "dossier_policy=copied_from_source_dossier_with_current_shortcut_overlay_when_available",
        "shortcut_overlay_policy=overlay_is_current_selection_truth_base_dossier_body_may_lag",
        f"folder={folder}",
        f"selected_count={len(rows)}",
        "global_top10_runtime=false",
        "trade_permission=false",
        "entry_signal=false",
        "execution=false",
        "",
        "GLOBAL TOP 10",
    ]
    for row in rows:
        lines.append(
            f"#{row['global_top10_rank']} {row['symbol']} score={row.get('l16_primary_score','not_available')} "
            f"tier={row.get('selection_tier','not_available')} group={row.get('ranking_group','Unknown')} copy={row.get('copy_status','not_available')}"
        )
    if not rows:
        lines.append("not_available")
    lines.extend(["", f"generated_utc={utc_stamp()}", ""])
    return "\n".join(lines)


def _shortcut_status_text(summary: SelectionShortcutSummary) -> str:
    return "\n".join([
        "schema_name=selection_surface_shortcut_status",
        "schema_version=1",
        "owner_name=Runtime 5 - Taxonomy / Ranking Group Owner",
        "support_owner=Runtime 3 external worker copy bridge",
        "source_owner=Runtime 7 Dossier publication owner output",
        "shortcut_truth_policy=current_overlay_above_base_dossier_body",
        f"shortcut_type={summary.shortcut_type}",
        f"status={summary.status}",
        f"reason={summary.reason}",
        f"files_written={summary.files_written}",
        f"files_expected={summary.files_expected}",
        f"dossier_copies_written={summary.dossier_copies_written}",
        f"dossier_copies_expected={summary.dossier_copies_expected}",
        f"dossier_sources_missing={summary.dossier_sources_missing}",
        f"stale_files_removed={summary.stale_files_removed}",
        f"write_failed_count={summary.write_failed_count}",
        "selection_runtime=false",
        "trade_permission=false",
        "entry_signal=false",
        "execution=false",
        f"generated_utc={utc_stamp()}",
        f"generated_unix={unix_time()}",
        "",
    ])