from __future__ import annotations

from pathlib import Path

from aurora_worker_io import WorkerPaths, atomic_write_text, read_text, payload_checksum, unix_time, utc_stamp
from aurora_worker_l11 import L11PublishSummary, publish_l11_symbol_ranking_inside_group
from aurora_worker_l11_cleanup import cleanup_l11_stale_symbol_rank_sidecars
from aurora_worker_l11_dossier_copy import EMPTY_L11_DOSSIER_COPY_SUMMARY, L11DossierCopySummary, copy_l11_tree_rank_files_from_dossiers
from aurora_worker_l11_tree import L11TreeSummary, publish_l11_selection_desk_taxonomy_tree
from aurora_worker_selection_surface_shortcuts import EMPTY_SELECTION_SHORTCUT_SUMMARY, SelectionShortcutSummary, publish_l11_asset_class_shortcuts

EMPTY_TREE_SUMMARY = L11TreeSummary("pending", "l11_taxonomy_tree_not_run")


def l11_result_lines(summary: L11PublishSummary, duration_ms: int, stale_sidecars_removed: int = 0, tree: L11TreeSummary = EMPTY_TREE_SUMMARY, dossier_copy: L11DossierCopySummary = EMPTY_L11_DOSSIER_COPY_SUMMARY, asset_shortcuts: SelectionShortcutSummary = EMPTY_SELECTION_SHORTCUT_SUMMARY) -> str:
    return "\n".join([
        f"l11_symbol_ranking_status={summary.status}",
        f"l11_symbol_ranking_reason={summary.reason}",
        f"l11_symbol_ranking_duration_ms={duration_ms}",
        f"l11_stale_symbol_rank_sidecars_removed={stale_sidecars_removed}",
        f"l11_input_symbol_count={summary.input_symbol_count}",
        f"l11_ranking_group_count={summary.ranking_group_count}",
        f"l11_ranked_symbol_count={summary.ranked_symbol_count}",
        f"l11_ranked_partial_count={summary.ranked_partial_count}",
        f"l11_risk_review_count={summary.risk_review_count}",
        f"l11_not_rankable_taxonomy_count={summary.not_rankable_taxonomy_count}",
        f"l11_not_rankable_quality_count={summary.not_rankable_quality_count}",
        f"l11_top5_group_count={summary.top5_group_count}",
        f"l11_top5_symbol_count={summary.top5_symbol_count}",
        f"l11_visible_selection_desk_groups_written={summary.visible_selection_desk_groups_written}",
        f"l11_visible_selection_desk_groups_expected={summary.visible_selection_desk_groups_expected}",
        f"l11_visible_group_files_written={summary.visible_group_files_written}",
        f"l11_visible_group_files_expected={summary.visible_group_files_expected}",
        f"l11_symbol_rank_files_written={summary.symbol_rank_files_written}",
        f"l11_symbol_rank_files_actual={summary.symbol_rank_files_actual}",
        f"l11_write_failed_count={summary.write_failed_count}",
        f"l11_ranked_symbols_by_group_path={summary.ranked_symbols_by_group_path}",
        f"l11_ranking_group_top5_path={summary.ranking_group_top5_path}",
        f"l11_visible_group_index_path={summary.visible_group_index_path}",
        f"l11_taxonomy_tree_status={tree.status}",
        f"l11_taxonomy_tree_reason={tree.reason}",
        f"l11_taxonomy_tree_rows={tree.taxonomy_tree_rows}",
        f"l11_taxonomy_tree_files_written={tree.taxonomy_tree_files_written}",
        f"l11_taxonomy_tree_files_expected={tree.taxonomy_tree_files_expected}",
        f"l11_taxonomy_tree_rank_cards_written={tree.taxonomy_tree_rank_cards_written}",
        f"l11_taxonomy_tree_rank_cards_expected={tree.taxonomy_tree_rank_cards_expected}",
        f"l11_taxonomy_tree_stale_rank_cards_removed={tree.stale_rank_cards_removed}",
        f"l11_taxonomy_tree_write_failed_count={tree.write_failed_count}",
        f"l11_taxonomy_tree_index_path={tree.taxonomy_tree_index_path}",
        f"l11_taxonomy_tree_csv_path={tree.taxonomy_tree_csv_path}",
        f"l11_dossier_copy_status={dossier_copy.status}",
        f"l11_dossier_copy_reason={dossier_copy.reason}",
        f"l11_dossier_copies_written={dossier_copy.dossier_copies_written}",
        f"l11_dossier_copies_expected={dossier_copy.dossier_copies_expected}",
        f"l11_dossier_sources_missing={dossier_copy.dossier_sources_missing}",
        f"l11_dossier_stale_rank_files_removed={dossier_copy.stale_dossier_rank_files_removed}",
        f"l11_dossier_copy_write_failed_count={dossier_copy.write_failed_count}",
        f"l11_dossier_copy_status_path={dossier_copy.status_path}",
        f"l11_asset_class_shortcut_status={asset_shortcuts.status}",
        f"l11_asset_class_shortcut_reason={asset_shortcuts.reason}",
        f"l11_asset_class_shortcut_files_written={asset_shortcuts.files_written}",
        f"l11_asset_class_shortcut_files_expected={asset_shortcuts.files_expected}",
        f"l11_asset_class_shortcut_dossier_copies_written={asset_shortcuts.dossier_copies_written}",
        f"l11_asset_class_shortcut_dossier_copies_expected={asset_shortcuts.dossier_copies_expected}",
        f"l11_asset_class_shortcut_sources_missing={asset_shortcuts.dossier_sources_missing}",
        f"l11_asset_class_shortcut_status_path={asset_shortcuts.status_path}",
        "l11_meaning=intra_group_inspection_priority_only",
        "l11_asset_class_shortcut_meaning=asset_class_review_shortcuts_only_existing_l11_score",
        "l11_directional_validity=false",
        "l11_expectancy_validated=false",
        "l11_selection_runtime=false",
        "l11_trade_permission=false",
        "l11_entry_signal=false",
        "l11_execution=false",
        "",
    ])


def _replace_or_append_l11_block(result_text: str, lines: str) -> str:
    marker = "l11_symbol_ranking_status="
    normalized = result_text.replace("\r\n", "\n")
    if marker not in normalized:
        return normalized.rstrip() + "\n" + lines
    before, _sep, tail = normalized.partition(marker)
    kept_tail = []
    for line in tail.splitlines():
        if line.startswith("l11_"):
            continue
        kept_tail.append(line)
    suffix = "\n".join(kept_tail).strip()
    return before.rstrip() + "\n" + lines + (suffix + "\n" if suffix else "")


def run_l11_after_core(root: Path, duration_ms: int = 0) -> L11PublishSummary:
    paths = WorkerPaths.from_root(root)
    paths.ensure()
    summary = publish_l11_symbol_ranking_inside_group(paths.outbox)
    stale_sidecars_removed = 0
    if summary.status == "write_degraded" and summary.symbol_rank_files_actual > summary.symbol_rank_files_written:
        stale_sidecars_removed = cleanup_l11_stale_symbol_rank_sidecars(root)
        if stale_sidecars_removed > 0:
            summary = publish_l11_symbol_ranking_inside_group(paths.outbox)
    tree_summary = publish_l11_selection_desk_taxonomy_tree(root)
    dossier_copy_summary = copy_l11_tree_rank_files_from_dossiers(root)
    asset_shortcuts_summary = publish_l11_asset_class_shortcuts(root)
    result_path = paths.outbox / "result_latest.txt"
    if result_path.exists():
        text = read_text(result_path)
        updated = _replace_or_append_l11_block(text, l11_result_lines(summary, duration_ms, stale_sidecars_removed, tree_summary, dossier_copy_summary, asset_shortcuts_summary))
        atomic_write_text(result_path, updated)
        manifest_path = paths.outbox / "result_latest.manifest"
        manifest = "\n".join([
            "schema_name=aurora_worker_result_manifest",
            "schema_version=12",
            "worker_l11_append_status=appended_by_l11_dispatch",
            f"l11_stale_symbol_rank_sidecars_removed={stale_sidecars_removed}",
            f"l11_taxonomy_tree_status={tree_summary.status}",
            f"l11_taxonomy_tree_files_written={tree_summary.taxonomy_tree_files_written}",
            f"l11_taxonomy_tree_files_expected={tree_summary.taxonomy_tree_files_expected}",
            f"l11_dossier_copy_status={dossier_copy_summary.status}",
            f"l11_dossier_copies_written={dossier_copy_summary.dossier_copies_written}",
            f"l11_dossier_copies_expected={dossier_copy_summary.dossier_copies_expected}",
            f"l11_dossier_copy_status_path={dossier_copy_summary.status_path}",
            f"l11_asset_class_shortcut_status={asset_shortcuts_summary.status}",
            f"l11_asset_class_shortcut_files_written={asset_shortcuts_summary.files_written}",
            f"l11_asset_class_shortcut_files_expected={asset_shortcuts_summary.files_expected}",
            f"l11_asset_class_shortcut_status_path={asset_shortcuts_summary.status_path}",
            f"result_size={len(updated.encode('utf-8'))}",
            f"payload_checksum={payload_checksum(updated.splitlines())}",
            "authority=calculation_support_only",
            "selection_runtime=false",
            "trade_permission=false",
            "entry_signal=false",
            "execution=false",
            f"generated_utc={utc_stamp()}",
            f"generated_unix={unix_time()}",
            "",
        ])
        atomic_write_text(manifest_path, manifest)
    return summary
