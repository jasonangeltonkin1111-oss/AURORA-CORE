from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

from aurora_worker_io import WorkerPaths, atomic_write_text, read_text, payload_checksum, unix_time, utc_stamp
from aurora_worker_l11 import L11PublishSummary, publish_l11_symbol_ranking_inside_group
from aurora_worker_l11_current_gate_guard import guard_l11_with_current_dossier_gate
from aurora_worker_l11_cleanup import cleanup_l11_stale_symbol_rank_sidecars
from aurora_worker_l11_dossier_copy import EMPTY_L11_DOSSIER_COPY_SUMMARY, L11DossierCopySummary, copy_l11_tree_rank_files_from_dossiers
from aurora_worker_l11_tree import L11TreeSummary, publish_l11_selection_desk_taxonomy_tree
from aurora_worker_selection_surface_shortcuts_ux import EMPTY_SELECTION_SHORTCUT_SUMMARY, SelectionShortcutSummary, publish_l11_asset_class_shortcuts
from aurora_worker_selection_surface_groups import publish_l11_shallow_group_shortcuts
from aurora_worker_selection_surface_root_index import EMPTY_SELECTION_ROOT_INDEX_SUMMARY, SelectionRootIndexSummary, publish_selection_desk_root_operator_index

EMPTY_TREE_SUMMARY = L11TreeSummary("pending", "l11_taxonomy_tree_not_run")


@dataclass(frozen=True)
class L11ManifestGuardSummary:
    status: str
    reason: str
    manifests_written: int = 0
    manifests_expected: int = 0
    write_failed_count: int = 0
    status_path: str = "not_available"


EMPTY_MANIFEST_GUARD_SUMMARY = L11ManifestGuardSummary("pending", "l11_manifest_guard_not_run")


def _selection_groups_dir(outbox: Path) -> Path:
    return outbox.parents[2] / "Selection Desk" / "Groups"


def _manifest_text(schema_name: str, payload_path: Path, payload_text: str, reason: str) -> str:
    return "\n".join([
        f"schema_name={schema_name}_manifest",
        "schema_version=2",
        "layer_id=11",
        "layer_name=Layer 11 - Symbol Ranking Inside Ranking Group",
        "owner=Runtime 3 calculation support / L11 intra-group ranking output proof",
        "authority=manifest_proof_only_no_ranking_authority",
        f"payload_path={payload_path}",
        f"payload_checksum={payload_checksum(payload_text.splitlines())}",
        f"payload_size_bytes={len(payload_text.encode('utf-8'))}",
        f"reason={reason}",
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


def _write_manifest_for_payload(payload_path: Path, manifest_path: Path, schema_name: str, reason: str) -> bool:
    if not payload_path.exists():
        return False
    payload_text = read_text(payload_path)
    return atomic_write_text(manifest_path, _manifest_text(schema_name, payload_path, payload_text, reason))


def publish_l11_manifest_guard(root: Path) -> L11ManifestGuardSummary:
    """Backfill manifests for L11 outputs that downstream tools read directly.

    This does not rank, rerank, select, permit, alert, execute, or own FileIO routes.
    It only writes proof sidecars for already-published L11 CSV surfaces.
    """
    paths = WorkerPaths.from_root(root)
    outbox = paths.outbox
    layer = outbox / "Layers" / "Layer_11_Symbol_Ranking_Inside_Ranking_Group"
    visible = _selection_groups_dir(outbox)
    status_path = layer / "l11_manifest_guard_status.txt"
    targets = [
        (
            layer / "ranked_symbols_by_group.csv",
            layer / "ranked_symbols_by_group.manifest",
            "l11_ranked_symbols_by_group",
            "l11_ranked_symbols_payload_manifested_for_l12_l14_contract",
        ),
        (
            layer / "ranked_symbols_by_group.csv",
            layer / "ranked_symbols.manifest",
            "l11_ranked_symbols_compatibility",
            "compatibility_manifest_for_auditors_expecting_ranked_symbols_manifest",
        ),
        (
            layer / "ranking_group_top5.csv",
            layer / "ranking_group_top5.manifest",
            "l11_ranking_group_top5",
            "l11_top5_payload_manifested_for_l12_l14_contract",
        ),
        (
            visible / "00_Group_Index.csv",
            visible / "00_Group_Index.manifest",
            "l11_selection_desk_group_index",
            "l11_visible_group_index_manifested_for_operator_and_downstream_contract",
        ),
    ]
    written = 0
    failed = 0
    missing_payloads = []
    for payload_path, manifest_path, schema_name, reason in targets:
        if not payload_path.exists():
            failed += 1
            missing_payloads.append(str(payload_path))
            continue
        if _write_manifest_for_payload(payload_path, manifest_path, schema_name, reason):
            written += 1
        else:
            failed += 1
    status = "accepted" if failed == 0 else "write_degraded"
    reason = "l11_manifest_guard_completed" if failed == 0 else "one_or_more_l11_manifest_guard_outputs_failed_or_missing_payload"
    summary = L11ManifestGuardSummary(status, reason, written, len(targets), failed, str(status_path))
    report = "\n".join([
        "schema_name=l11_manifest_guard_status",
        "schema_version=2",
        f"status={summary.status}",
        f"reason={summary.reason}",
        f"manifests_written={summary.manifests_written}",
        f"manifests_expected={summary.manifests_expected}",
        f"write_failed_count={summary.write_failed_count}",
        f"missing_payloads={';'.join(missing_payloads) if missing_payloads else 'none'}",
        "ranked_symbols_by_group_manifest_required=true",
        "ranked_symbols_compatibility_manifest_required=true",
        "authority=manifest_proof_only_no_ranking_authority",
        "selection_runtime=false",
        "trade_permission=false",
        "entry_signal=false",
        "execution=false",
        f"generated_utc={utc_stamp()}",
        f"generated_unix={unix_time()}",
        "",
    ])
    if not atomic_write_text(status_path, report):
        return L11ManifestGuardSummary(
            "write_degraded",
            "l11_manifest_guard_status_write_failed" if failed == 0 else "one_or_more_l11_manifest_guard_outputs_failed_or_missing_payload_or_status_failed",
            written,
            len(targets),
            failed + 1,
            str(status_path),
        )
    return summary


def l11_result_lines(summary: L11PublishSummary, duration_ms: int, stale_sidecars_removed: int = 0, tree: L11TreeSummary = EMPTY_TREE_SUMMARY, dossier_copy: L11DossierCopySummary = EMPTY_L11_DOSSIER_COPY_SUMMARY, asset_shortcuts: SelectionShortcutSummary = EMPTY_SELECTION_SHORTCUT_SUMMARY, shallow_groups: SelectionShortcutSummary = EMPTY_SELECTION_SHORTCUT_SUMMARY, root_index: SelectionRootIndexSummary = EMPTY_SELECTION_ROOT_INDEX_SUMMARY, manifest_guard: L11ManifestGuardSummary = EMPTY_MANIFEST_GUARD_SUMMARY) -> str:
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
        f"l11_shallow_group_shortcut_status={shallow_groups.status}",
        f"l11_shallow_group_shortcut_reason={shallow_groups.reason}",
        f"l11_shallow_group_shortcut_files_written={shallow_groups.files_written}",
        f"l11_shallow_group_shortcut_files_expected={shallow_groups.files_expected}",
        f"l11_shallow_group_shortcut_dossier_copies_written={shallow_groups.dossier_copies_written}",
        f"l11_shallow_group_shortcut_dossier_copies_expected={shallow_groups.dossier_copies_expected}",
        f"l11_shallow_group_shortcut_sources_missing={shallow_groups.dossier_sources_missing}",
        f"l11_shallow_group_shortcut_status_path={shallow_groups.status_path}",
        f"l11_selection_root_index_status={root_index.status}",
        f"l11_selection_root_index_reason={root_index.reason}",
        f"l11_selection_root_index_files_written={root_index.files_written}",
        f"l11_selection_root_index_files_expected={root_index.files_expected}",
        f"l11_selection_root_index_write_failed_count={root_index.write_failed_count}",
        f"l11_selection_root_index_path={root_index.index_path}",
        f"l11_manifest_guard_status={manifest_guard.status}",
        f"l11_manifest_guard_reason={manifest_guard.reason}",
        f"l11_manifest_guard_manifests_written={manifest_guard.manifests_written}",
        f"l11_manifest_guard_manifests_expected={manifest_guard.manifests_expected}",
        f"l11_manifest_guard_write_failed_count={manifest_guard.write_failed_count}",
        f"l11_manifest_guard_status_path={manifest_guard.status_path}",
        "l11_selection_surface_ux_wrapper=active_pointer_over_stale_mirror_and_overlay_trust_rule",
        "l11_meaning=intra_group_inspection_priority_only_current_l5_guarded",
        "l11_asset_class_shortcut_meaning=asset_class_review_shortcuts_only_existing_l11_score",
        "l11_shallow_group_shortcut_meaning=ranking_group_review_shortcuts_only_existing_l11_rank",
        "l11_selection_root_index_meaning=operator_navigation_index_only_no_scoring_authority",
        "l11_manifest_guard_meaning=manifest_proof_only_no_ranking_authority",
        "l11_directional_validity=false",
        "l11_expectancy_validated=false",
        "l11_selection_runtime=false",
        "l11_trade_permission=false",
        "l11_entry_signal=false",
        "l11_execution=false",
        "",
    ])


def _degraded_result_latest_stub(reason: str) -> str:
    return "\n".join([
        "schema_name=aurora_worker_result",
        "schema_version=7",
        "worker_version=unknown_l11_dispatch_survivor",
        "worker_mode=l11_dispatch_survivor",
        "authority=calculation_support_only",
        "trade_permission=false",
        "job_status=rejected",
        "result_status=degraded",
        f"result_reason={reason}",
        "source_snapshot_id=not_available",
        "job_bus_schema_version=not_available",
        "job_id=not_available",
        "job_type=not_available",
        "job_resource_class=not_available",
        "job_max_runtime_ms=not_available",
        "row_count=0",
        "open_count=0",
        "closed_count=0",
        "l4_ready_count=0",
        "stale_or_missing_quote_rows=0",
        "payload_checksum=not_available",
        f"generated_utc={utc_stamp()}",
        f"generated_unix={unix_time()}",
        "notes=degraded_truth_file_created_by_l11_dispatch_because_base_result_latest_was_missing_no_trade_permission",
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
    summary = guard_l11_with_current_dossier_gate(paths.outbox, summary)
    tree_summary = publish_l11_selection_desk_taxonomy_tree(root)
    dossier_copy_summary = copy_l11_tree_rank_files_from_dossiers(root)
    asset_shortcuts_summary = publish_l11_asset_class_shortcuts(root)
    shallow_groups_summary = publish_l11_shallow_group_shortcuts(root)
    root_index_summary = publish_selection_desk_root_operator_index(root)
    manifest_guard_summary = publish_l11_manifest_guard(root)
    result_path = paths.outbox / "result_latest.txt"
    if result_path.exists():
        text = read_text(result_path)
    else:
        text = _degraded_result_latest_stub("base_result_latest_missing_before_l11_dispatch_created_degraded_truth")
    updated = _replace_or_append_l11_block(text, l11_result_lines(summary, duration_ms, stale_sidecars_removed, tree_summary, dossier_copy_summary, asset_shortcuts_summary, shallow_groups_summary, root_index_summary, manifest_guard_summary))
    atomic_write_text(result_path, updated)
    manifest_path = paths.outbox / "result_latest.manifest"
    manifest = "\n".join([
        "schema_name=aurora_worker_result_manifest",
        "schema_version=12",
        "worker_l11_append_status=appended_by_l11_dispatch",
        "base_result_latest_survivor_created=" + ("false" if result_path.exists() else "true"),
        f"l11_symbol_ranking_status={summary.status}",
        f"l11_selection_root_index_status={root_index_summary.status}",
        f"l11_manifest_guard_status={manifest_guard_summary.status}",
        f"result_size={len(updated.encode('utf-8'))}",
        f"payload_checksum={payload_checksum(updated.splitlines())}",
        "authority=calculation_support_only",
        "trade_permission=false",
        "entry_signal=false",
        "execution=false",
        f"generated_utc={utc_stamp()}",
        f"generated_unix={unix_time()}",
        "",
    ])
    atomic_write_text(manifest_path, manifest)
    return summary


def run_l11_after_render_index(root: Path) -> L11PublishSummary:
    return run_l11_after_core(root)
