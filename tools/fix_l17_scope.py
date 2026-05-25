from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def patch_file(path: Path, replacements: list[tuple[str, str]]) -> None:
    text = path.read_text(encoding="utf-8-sig")
    original = text
    for old, new in replacements:
        if old not in text:
            raise RuntimeError(f"Pattern not found in {path}: {old[:120]!r}")
        text = text.replace(old, new, 1)
    if text != original:
        path.write_text(text, encoding="utf-8", newline="\n")
        print(f"PATCHED {path.relative_to(ROOT)}")
    else:
        print(f"UNCHANGED {path.relative_to(ROOT)}")


def patch_l17() -> None:
    path = ROOT / "external_worker" / "aurora_worker_l17.py"
    replacements = [
        (
            'DEPTH_SUMMARY_FIELDS = ["depth_assignment", "count", "meaning", "generated_utc"]\n',
            'DEPTH_SUMMARY_FIELDS = ["depth_assignment", "count", "meaning", "generated_utc"]\n'
            'FULL_SPLIT_FIELDS = SELECTED_FIELDS\n',
        ),
        (
            '        "heavy_data_allowed": "true",\n'
            '        "meaning": "l17_evidence_budget_queue_split_only_not_evidence_collection_not_trade_permission",\n',
            '        "heavy_data_allowed": "false" if assignment.get("depth_assignment") == "fallback_limited_review_request" else "true",\n'
            '        "meaning": "l17_evidence_budget_queue_split_only_not_evidence_collection_not_trade_permission",\n',
        ),
        (
            'def _depth_summary(rows: List[Dict[str, str]], rejected: List[Dict[str, str]]) -> List[Dict[str, str]]:\n',
            'def _full_split_rows(selected: List[Dict[str, str]], rejected: List[Dict[str, str]]) -> List[Dict[str, str]]:\n'
            '    rows: List[Dict[str, str]] = list(selected)\n'
            '    for row in rejected:\n'
            '        rows.append({\n'
            '            "deep_evidence_rank": "not_selected",\n'
            '            "symbol": row.get("symbol", "not_available"),\n'
            '            "canonical_symbol": row.get("canonical_symbol", row.get("symbol", "not_available")),\n'
            '            "source_l16_display_rank": row.get("visible_rank", "not_available"),\n'
            '            "source_l16_global_rank": row.get("visible_rank", "not_available"),\n'
            '            "source_l16_selection_tier": row.get("source_l16_selection_tier", "not_available"),\n'
            '            "source_l16_clean_diversified": row.get("source_l16_clean_diversified", "false"),\n'
            '            "source_l16_fallback_fill_used": row.get("source_l16_fallback_fill_used", "false"),\n'
            '            "source_l16_fallback_reason": "not_selected",\n'
            '            "source_l16_hold_state": "not_available",\n'
            '            "source_l16_hold_visible": "true",\n'
            '            "source_l16_visible_surface_state": "visible_watch_only",\n'
            '            "ranking_group": row.get("ranking_group", "not_available"),\n'
            '            "asset_class": "not_available",\n'
            '            "market_group": "not_available",\n'
            '            "market_segment": "not_available",\n'
            '            "l16_primary_score": row.get("l16_primary_score", "not_available"),\n'
            '            "max_corr_to_selected": "not_available",\n'
            '            "max_corr_pair_symbol": "not_available",\n'
            '            "correlation_state": "not_available",\n'
            '            "correlation_clean_flag": "false",\n'
            '            "deep_evidence_selected": "false",\n'
            '            "visible_only": "true",\n'
            '            "alert_eligible_candidate": "false",\n'
            '            "depth_assignment": "visible_watch_only_no_expensive_collection",\n'
            '            "evidence_budget_class": "watch_only_no_heavy_budget",\n'
            '            "ohlc_depth": "none",\n'
            '            "tick_depth": "none",\n'
            '            "indicator_depth": "none",\n'
            '            "liquidity_depth": "none",\n'
            '            "selection_reason": row.get("reject_reason", "outside_l17_deep_budget"),\n'
            '            "selection_source": "l17_visible_rejected_rows",\n'
            '            "evidence_collection_scope": "no_expensive_collection_visible_only",\n'
            '            "heavy_data_allowed": "false",\n'
            '            "meaning": "visible_watch_only_not_deep_evidence_not_trade_permission",\n'
            '            "deep_evidence_runtime": "false",\n'
            '            "trade_permission": "false",\n'
            '            "entry_signal": "false",\n'
            '            "execution": "false",\n'
            '            "generated_utc": row.get("generated_utc", utc_stamp()),\n'
            '        })\n'
            '    return rows\n\n\n'
            'def _depth_summary(rows: List[Dict[str, str]], rejected: List[Dict[str, str]]) -> List[Dict[str, str]]:\n',
        ),
        (
            '        depth_text = _csv_text(_depth_summary(selected, rejected), DEPTH_SUMMARY_FIELDS)\n',
            '        depth_text = _csv_text(_depth_summary(selected, rejected), DEPTH_SUMMARY_FIELDS)\n'
            '        full_split_text = _csv_text(_full_split_rows(selected, rejected), FULL_SPLIT_FIELDS)\n',
        ),
        (
            '        _write(layer / "l17_deep_evidence_selection_split.csv", selected_text, failed)\n',
            '        _write(layer / "l17_deep_evidence_selection_split.csv", full_split_text, failed)\n',
        ),
        (
            '        _write(visible / "current_deep_evidence_split.csv", selected_text, failed)\n',
            '        _write(visible / "current_deep_evidence_split.csv", full_split_text, failed)\n',
        ),
    ]
    patch_file(path, replacements)


L17_SCOPE_HELPERS = '''\n\ndef _l17_selected_symbols(root: Path) -> set[str]:\n    path = WorkerPaths.from_root(root).outbox / "Layers" / "Layer_17_Deep_Evidence_Selection_Split" / "l17_deep_evidence_selected.csv"\n    if not path.exists():\n        return set()\n    selected: set[str] = set()\n    try:\n        for row in csv.DictReader(io.StringIO(read_text(path))):\n            symbol = (row.get("symbol") or "").strip()\n            canonical = (row.get("canonical_symbol") or symbol).strip()\n            deep_selected = (row.get("deep_evidence_selected") or "").strip().lower() == "true"\n            visible_only = (row.get("visible_only") or "").strip().lower() == "true"\n            if deep_selected and not visible_only:\n                if symbol:\n                    selected.add(symbol)\n                if canonical:\n                    selected.add(canonical)\n    except Exception:\n        return set()\n    return selected\n\n\ndef _filter_l17_selected_dossiers(root: Path, dossiers: List[Path]) -> List[Path]:\n    allowed_symbols = _l17_selected_symbols(root)\n    if not allowed_symbols:\n        return []\n    return [path for path in dossiers if _symbol_from_dossier(path) in allowed_symbols]\n'''


def patch_l18() -> None:
    path = ROOT / "external_worker" / "aurora_worker_l18.py"
    replacements = [
        (
            'from typing import Dict, List, Sequence\nimport re\n',
            'from typing import Dict, List, Sequence\nimport csv\nimport io\nimport re\n',
        ),
        (
            'def _symbol_from_dossier(path: Path) -> str:\n    match = RANKED_DOSSIER_RE.match(path.name)\n    return match.group(1) if match else ""\n',
            'def _symbol_from_dossier(path: Path) -> str:\n    match = RANKED_DOSSIER_RE.match(path.name)\n    return match.group(1) if match else ""\n'
            + L17_SCOPE_HELPERS,
        ),
        (
            '    dossiers = _selected_dossier_paths(root)\n',
            '    route_dossiers = _selected_dossier_paths(root)\n'
            '    dossiers = _filter_l17_selected_dossiers(root, route_dossiers)\n',
        ),
        (
            '    route_seen = len(dossiers)\n',
            '    route_seen = len(route_dossiers)\n',
        ),
        (
            '        "Scope:                  Selection copied dossier only",\n',
            '        "Scope:                  L17 deep-selected copied dossier only",\n',
        ),
        (
            '        "Purpose:                Copy selected raw OHLC from Shared OHLC Store into selected dossiers",\n'
            '        "Scope:                  Canonical Selection Desk copied dossiers only",\n',
            '        "Purpose:                Copy selected raw OHLC from Shared OHLC Store into L17 deep-selected dossiers",\n'
            '        "Scope:                  L17 deep-selected Selection Desk copied dossiers only",\n',
        ),
        (
            '        "scope=canonical_selection_shortcut_dossiers_only",\n',
            '        "scope=l17_deep_selected_selection_shortcut_dossiers_only",\n',
        ),
    ]
    patch_file(path, replacements)


def patch_l19() -> None:
    path = ROOT / "external_worker" / "aurora_worker_l19.py"
    replacements = [
        (
            'from typing import Dict, List, Sequence, Tuple\nimport math\nimport re\nimport time\n',
            'from typing import Dict, List, Sequence, Tuple\nimport csv\nimport io\nimport math\nimport re\nimport time\n',
        ),
        (
            'def _symbol_from_dossier(path: Path) -> str:\n    match = RANKED_DOSSIER_RE.match(path.name)\n    return match.group(1) if match else ""\n',
            'def _symbol_from_dossier(path: Path) -> str:\n    match = RANKED_DOSSIER_RE.match(path.name)\n    return match.group(1) if match else ""\n'
            + L17_SCOPE_HELPERS,
        ),
        (
            '    dossiers = _selected_dossier_paths(root)\n',
            '    route_dossiers = _selected_dossier_paths(root)\n'
            '    dossiers = _filter_l17_selected_dossiers(root, route_dossiers)\n',
        ),
        (
            '    route_seen = len(dossiers)\n',
            '    route_seen = len(route_dossiers)\n',
        ),
        (
            '        "Scope:                  Selection copied dossier only",\n',
            '        "Scope:                  L17 deep-selected copied dossier only",\n',
        ),
        (
            '        "Purpose:                Calculate candle geometry plus Wave 1/2/3 candle structures from selected raw OHLC",\n'
            '        "Scope:                  Canonical Selection Desk copied dossiers only",\n',
            '        "Purpose:                Calculate candle geometry plus Wave 1/2/3 candle structures from L17-selected raw OHLC",\n'
            '        "Scope:                  L17 deep-selected Selection Desk copied dossiers only",\n',
        ),
        (
            '        "scope=canonical_selection_shortcut_dossiers_only",\n',
            '        "scope=l17_deep_selected_selection_shortcut_dossiers_only",\n',
        ),
    ]
    patch_file(path, replacements)


def main() -> None:
    patch_l17()
    patch_l18()
    patch_l19()
    print("DONE: L17 now owns deep-evidence selection scope; L18/L19 consume L17-selected symbols only.")


if __name__ == "__main__":
    main()
