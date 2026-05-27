from __future__ import annotations

from pathlib import Path
import csv
import io
import time

from aurora_worker_io import WorkerPaths, atomic_write_text, payload_checksum, read_text, read_kv, unix_time, utc_stamp
from aurora_worker_l15 import L15PublishSummary, publish_l15_correlation_diversity_selection

L15_LAYER_FOLDER = "Layer_15_Correlation_Diversity_Selection"
L15_SCORE_FILE = "l15_candidate_diversity_scores.csv"
L15_PAIR_FILE = "l15_candidate_correlation_matrix.csv"
L15_GROUP_FILE = "l15_group_diversity_summary.csv"
L15_MANIFEST_FILE = "l15_correlation_diversity.manifest"
L15_DEGRADED_SCORE_CAP = 54.99


def _l15_diversity_state(score: float) -> str:
    if score >= 75:
        return "DIVERSITY_CLEAN"
    if score >= 55:
        return "DIVERSITY_WARNING"
    if score >= 35:
        return "DIVERSITY_CONSTRAINED"
    return "DIVERSITY_HIGH_RISK"


def _l15_float(value: str, default: float = 0.0) -> float:
    try:
        return float(str(value or "").strip())
    except ValueError:
        return default


def _l15_csv_text(rows: list[dict[str, str]], fieldnames: list[str]) -> str:
    out = io.StringIO(newline="")
    writer = csv.DictWriter(out, fieldnames=fieldnames, extrasaction="ignore", lineterminator="\n")
    writer.writeheader()
    for row in rows:
        writer.writerow({field: row.get(field, "not_available") for field in fieldnames})
    return out.getvalue()


def _read_csv(path: Path) -> list[dict[str, str]]:
    if not path.exists():
        return []
    text = read_text(path).replace("\r\n", "\n")
    if not text.strip():
        return []
    return [{str(k): "" if v is None else str(v) for k, v in row.items()} for row in csv.DictReader(io.StringIO(text))]


def _replace_manifest_checksum(manifest_text: str, checksum: str) -> str:
    lines = manifest_text.replace("\r\n", "\n").splitlines()
    replaced = False
    out: list[str] = []
    for line in lines:
        if line.startswith("payload_checksum="):
            out.append(f"payload_checksum={checksum}")
            replaced = True
        else:
            out.append(line)
    if not replaced:
        out.append(f"payload_checksum={checksum}")
    return "\n".join(out).rstrip() + "\n"


def _result_latest_kv(outbox: Path) -> dict[str, str]:
    result_path = outbox / "result_latest.txt"
    if not result_path.exists():
        return {}
    return read_kv(result_path)


def _l14_current_chain_valid(outbox: Path) -> tuple[bool, str]:
    kv = _result_latest_kv(outbox)
    value = str(kv.get("l14_current_chain_valid", "unknown")).strip().lower()
    downstream = str(kv.get("l14_downstream_allowed", "false")).strip().lower()
    status = str(kv.get("l14_candidate_pool_status", "unknown")).strip()
    reason = str(kv.get("l14_currentness_reason", kv.get("l14_candidate_pool_reason", "not_available"))).strip()
    if value == "true" and downstream == "true" and status == "accepted":
        return True, f"l14_current_chain_valid=true;downstream_allowed=true;status={status};reason={reason}"
    return False, f"l14_current_chain_valid={value};downstream_allowed={downstream};status={status};reason={reason}"


def _blocked_l15_summary(reason: str) -> L15PublishSummary:
    return L15PublishSummary(
        status="blocked_upstream_currentness",
        reason=reason,
        candidate_pool_size=0,
        candidate_scored_count=0,
        pairwise_pair_count=0,
        corr_pair_count=0,
        high_corr_pair_count=0,
        corr_unavailable_count=0,
        group_count=0,
        write_failed_count=0,
        top_diversity_candidate="not_available",
        max_pair_corr_abs="not_available",
        output_path="not_written_latest_l14_invalid",
        summary_path="not_written_latest_l14_invalid",
        selection_desk_summary_path="not_written_latest_l14_invalid",
        candidate_input_count=0,
        candidate_pool_capped="false",
        candidate_pool_cap=0,
        main_lane_candidate_count=0,
        deferred_candidate_count=0,
        soft_cap_policy="blocked_before_l15_due_to_l14_currentness",
        ohlc_scan_file_limit=0,
        ohlc_scan_file_count=0,
        threshold_source="not_evaluated",
        max_allowed_pairwise_correlation_abs="not_evaluated",
    )


def _clamp_l15_degraded_score_outputs(outbox: Path) -> tuple[str, int]:
    layer = outbox / "Layers" / L15_LAYER_FOLDER
    score_path = layer / L15_SCORE_FILE
    if not score_path.exists():
        return "score_file_missing", 0
    score_text = read_text(score_path).replace("\r\n", "\n")
    reader = csv.DictReader(io.StringIO(score_text))
    fieldnames = list(reader.fieldnames or [])
    if not fieldnames:
        return "score_file_no_header", 0
    rows = [{str(k): "" if v is None else str(v) for k, v in row.items()} for row in reader]
    changed = 0
    for row in rows:
        corr_pair_count = str(row.get("corr_pair_count", "0")).strip()
        confidence = str(row.get("correlation_confidence", "")).strip()
        state = str(row.get("correlation_state", "")).strip()
        no_usable_corr = corr_pair_count in {"", "0", "0.0"}
        degraded = confidence in {"degraded_unavailable", "deferred_not_scored_yet"} or state in {"CORRELATION_UNAVAILABLE", "DEFERRED_SOFT_CAP_SLOW_LANE"}
        if not (no_usable_corr or degraded):
            continue
        old_score = _l15_float(row.get("diversity_score", "0"), 0.0)
        new_score = min(old_score, L15_DEGRADED_SCORE_CAP)
        if new_score != old_score or row.get("l16_constraint_hint") == "clean_context":
            row["diversity_score"] = f"{new_score:.2f}"
            row["diversity_state"] = _l15_diversity_state(new_score)
            row["l16_constraint_hint"] = "constrained"
            if not str(row.get("correlation_reject_reason", "")).strip() or row.get("correlation_reject_reason") == "none":
                row["correlation_reject_reason"] = "correlation_unavailable_degraded"
            changed += 1
    if changed <= 0:
        return "no_change_needed", 0
    updated_score_text = _l15_csv_text(rows, fieldnames)
    if not atomic_write_text(score_path, updated_score_text):
        return "score_write_failed", changed
    visible_score_path = outbox.parents[2] / "Selection Desk" / "Groups" / "00_Correlation_Diversity_Summary.csv"
    if visible_score_path.exists():
        atomic_write_text(visible_score_path, updated_score_text)
    pair_text = read_text(layer / L15_PAIR_FILE) if (layer / L15_PAIR_FILE).exists() else ""
    group_text = read_text(layer / L15_GROUP_FILE) if (layer / L15_GROUP_FILE).exists() else ""
    manifest_path = layer / L15_MANIFEST_FILE
    if manifest_path.exists():
        checksum = payload_checksum((updated_score_text + pair_text + group_text).splitlines())
        atomic_write_text(manifest_path, _replace_manifest_checksum(read_text(manifest_path), checksum))
    return "applied", changed


def _safe_rank_key(row: dict[str, str]) -> tuple[int, str]:
    try:
        rank = int(float(str(row.get("candidate_pool_rank", "999999") or "999999")))
    except ValueError:
        rank = 999999
    return rank, str(row.get("symbol", ""))


def _write_l15_correlation_diagnostics(outbox: Path, summary: L15PublishSummary, l14_gate_valid: bool, l14_gate_reason: str) -> tuple[str, str]:
    layer = outbox / "Layers" / L15_LAYER_FOLDER
    score_rows = _read_csv(layer / L15_SCORE_FILE)
    pair_rows = _read_csv(layer / L15_PAIR_FILE)
    visible = outbox.parents[2] / "Selection Desk" / "Groups"
    diagnostics_path = layer / "l15_ohlc_correlation_diagnostics.txt"
    visible_path = visible / "00_Correlation_Diversity_Diagnostics.txt"
    reason_counts: dict[str, int] = {}
    for row in pair_rows:
        reason = str(row.get("data_quality_reason", "not_available") or "not_available")
        reason_counts[reason] = reason_counts.get(reason, 0) + 1
    candidate_lines: list[str] = []
    for row in sorted(score_rows, key=_safe_rank_key):
        candidate_lines.append(" | ".join([
            f"rank={row.get('candidate_pool_rank','not_available')}",
            f"symbol={row.get('symbol','not_available')}",
            f"group={row.get('ranking_group','not_available')}",
            f"corr_pair_count={row.get('corr_pair_count','not_available')}",
            f"corr_unavailable_count={row.get('corr_unavailable_count','not_available')}",
            f"correlation_state={row.get('correlation_state','not_available')}",
            f"correlation_confidence={row.get('correlation_confidence','not_available')}",
            f"correlation_sample_count={row.get('correlation_sample_count','not_available')}",
            f"reject_reason={row.get('correlation_reject_reason','not_available')}",
            f"l16_hint={row.get('l16_constraint_hint','not_available')}",
        ]))
    pair_problem_lines: list[str] = []
    for row in pair_rows:
        reason = str(row.get("data_quality_reason", "") or "")
        if reason == "ok":
            continue
        pair_problem_lines.append(" | ".join([
            f"{row.get('symbol_a','?')}->{row.get('symbol_b','?')}",
            f"reason={reason or 'not_available'}",
            f"sample={row.get('correlation_sample_count','not_available')}",
            f"state={row.get('correlation_state','not_available')}",
        ]))
    lines = [
        "L15 OHLC / CORRELATION DIAGNOSTICS",
        "----------------------------------------",
        "schema_name=l15_ohlc_correlation_diagnostics",
        "schema_version=1",
        "owner=Runtime 5 - Taxonomy / Ranking Group Owner",
        "authority=diagnostic_readback_only_no_scoring_authority",
        f"l15_status={summary.status}",
        f"l15_reason={summary.reason}",
        f"l14_gate_valid={'true' if l14_gate_valid else 'false'}",
        f"l14_gate_reason={l14_gate_reason}",
        f"candidate_scored_count={summary.candidate_scored_count}",
        f"pairwise_pair_count={summary.pairwise_pair_count}",
        f"corr_pair_count={summary.corr_pair_count}",
        f"corr_unavailable_count={summary.corr_unavailable_count}",
        f"ohlc_scan_file_limit={summary.ohlc_scan_file_limit}",
        f"ohlc_scan_file_count={summary.ohlc_scan_file_count}",
        "primary_timeframe=M15",
        "secondary_timeframe=M5",
        "reference_timeframe=H1_optional_not_primary_blocker",
        "lookback_bars=351",
        "minimum_aligned_returns=64",
        "diagnostic_meaning=if M15/M5 correlation is unavailable, fix reachable OHLC path/coverage/alignment before tuning thresholds",
        "",
        "PAIR DATA QUALITY COUNTS",
    ]
    for reason, count in sorted(reason_counts.items()):
        lines.append(f"{reason}={count}")
    lines.extend(["", "CANDIDATE CORRELATION READBACK"])
    lines.extend(candidate_lines or ["no_candidate_rows_available"])
    lines.extend(["", "PAIR PROBLEMS FIRST 80"])
    lines.extend(pair_problem_lines[:80] or ["no_pair_problems_or_pair_file_missing"])
    lines.extend(["", "selection_runtime=false", "trade_permission=false", "entry_signal=false", "execution=false", f"generated_utc={utc_stamp()}", f"generated_unix={unix_time()}", ""])
    text = "\n".join(lines)
    ok1 = atomic_write_text(diagnostics_path, text)
    ok2 = atomic_write_text(visible_path, text)
    status = "published" if ok1 and ok2 else "write_degraded"
    return status, str(diagnostics_path)


def _l15_currentness_fields(summary: L15PublishSummary, l14_gate_valid: bool, l14_gate_reason: str) -> list[str]:
    current = "true" if summary.status == "accepted" and l14_gate_valid and summary.candidate_scored_count > 0 else "false"
    downstream_allowed = current
    if not l14_gate_valid:
        visible_source = "blocked"
        reason = "latest_l14_invalid_do_not_consume_held_l14_outputs"
    elif current == "true":
        visible_source = "latest"
        reason = "latest_l15_built_from_current_l14"
    else:
        visible_source = "blocked"
        reason = "latest_l15_failed_or_empty"
    return [
        f"l15_current_chain_valid={current}",
        f"l15_latest_current={current}",
        f"l15_downstream_allowed={downstream_allowed}",
        f"l15_visible_output_source={visible_source}",
        f"l15_currentness_reason={reason}",
        f"l15_upstream_l14_gate={l14_gate_reason}",
    ]


def l15_result_lines(summary: L15PublishSummary, duration_ms: int, clamp_status: str = "not_run", clamp_count: int = 0, l14_gate_valid: bool = True, l14_gate_reason: str = "not_checked", diagnostics_status: str = "not_run", diagnostics_path: str = "not_available") -> str:
    return "\n".join([
        f"l15_correlation_diversity_status={summary.status}",
        f"l15_correlation_diversity_reason={summary.reason}",
        f"l15_correlation_diversity_duration_ms={duration_ms}",
        *_l15_currentness_fields(summary, l14_gate_valid, l14_gate_reason),
        f"l15_diagnostics_status={diagnostics_status}",
        f"l15_diagnostics_path={diagnostics_path}",
        f"l15_degraded_score_clamp_status={clamp_status}",
        f"l15_degraded_score_clamp_count={clamp_count}",
        f"l15_candidate_input_count={summary.candidate_input_count}",
        f"l15_candidate_pool_size={summary.candidate_pool_size}",
        f"l15_candidate_scored_count={summary.candidate_scored_count}",
        f"l15_candidate_pool_capped={summary.candidate_pool_capped}",
        f"l15_candidate_pool_cap={summary.candidate_pool_cap}",
        f"l15_main_lane_candidate_count={summary.main_lane_candidate_count}",
        f"l15_deferred_candidate_count={summary.deferred_candidate_count}",
        f"l15_soft_cap_policy={summary.soft_cap_policy}",
        f"l15_pairwise_pair_count={summary.pairwise_pair_count}",
        f"l15_corr_pair_count={summary.corr_pair_count}",
        f"l15_high_corr_pair_count={summary.high_corr_pair_count}",
        f"l15_corr_unavailable_count={summary.corr_unavailable_count}",
        f"l15_group_count={summary.group_count}",
        f"l15_top_diversity_candidate={summary.top_diversity_candidate}",
        f"l15_max_pair_corr_abs={summary.max_pair_corr_abs}",
        f"l15_ohlc_scan_file_limit={summary.ohlc_scan_file_limit}",
        f"l15_ohlc_scan_file_count={summary.ohlc_scan_file_count}",
        f"l15_write_failed_count={summary.write_failed_count}",
        f"l15_output_path={summary.output_path}",
        f"l15_summary_path={summary.summary_path}",
        f"l15_selection_desk_summary_path={summary.selection_desk_summary_path}",
        f"l15_max_allowed_pairwise_correlation_abs={summary.max_allowed_pairwise_correlation_abs}",
        "l15_threshold_status=untested_default_not_holy_law",
        f"l15_threshold_source={summary.threshold_source}",
        "l15_meaning=correlation_diversity_scoring_only_not_global_top10",
        "l15_selection_runtime=false",
        "l15_trade_permission=false",
        "l15_entry_signal=false",
        "l15_execution=false",
        "",
    ])


def _replace_or_append_l15_block(result_text: str, lines: str) -> str:
    marker = "l15_correlation_diversity_status="
    normalized = result_text.replace("\r\n", "\n")
    if marker not in normalized:
        return normalized.rstrip() + "\n" + lines
    before, _sep, tail = normalized.partition(marker)
    kept_tail = []
    for line in tail.splitlines():
        if line.startswith("l15_"):
            continue
        kept_tail.append(line)
    suffix = "\n".join(kept_tail).strip()
    return before.rstrip() + "\n" + lines + (suffix + "\n" if suffix else "")


def run_l15_after_l14(root: Path) -> L15PublishSummary:
    paths = WorkerPaths.from_root(root)
    paths.ensure()
    start_ns = time.perf_counter_ns()
    l14_gate_valid, l14_gate_reason = _l14_current_chain_valid(paths.outbox)
    if l14_gate_valid:
        summary = publish_l15_correlation_diversity_selection(paths.outbox)
        clamp_status, clamp_count = _clamp_l15_degraded_score_outputs(paths.outbox)
    else:
        summary = _blocked_l15_summary("l15_blocked_because_latest_l14_current_chain_invalid;" + l14_gate_reason)
        clamp_status, clamp_count = "blocked_l14_invalid", 0
    diagnostics_status, diagnostics_path = _write_l15_correlation_diagnostics(paths.outbox, summary, l14_gate_valid, l14_gate_reason)
    duration_ms = max(0, (time.perf_counter_ns() - start_ns) // 1_000_000)
    result_path = paths.outbox / "result_latest.txt"
    if result_path.exists():
        text = read_text(result_path)
        updated = _replace_or_append_l15_block(text, l15_result_lines(summary, duration_ms, clamp_status, clamp_count, l14_gate_valid, l14_gate_reason, diagnostics_status, diagnostics_path))
        atomic_write_text(result_path, updated)
        manifest_path = paths.outbox / "result_latest.manifest"
        manifest = "\n".join([
            "schema_name=aurora_worker_result_manifest",
            "schema_version=15",
            "worker_l15_append_status=appended_by_l15_dispatch",
            *_l15_currentness_fields(summary, l14_gate_valid, l14_gate_reason),
            f"l15_diagnostics_status={diagnostics_status}",
            f"l15_diagnostics_path={diagnostics_path}",
            f"l15_degraded_score_clamp_status={clamp_status}",
            f"l15_degraded_score_clamp_count={clamp_count}",
            f"l15_main_lane_candidate_count={summary.main_lane_candidate_count}",
            f"l15_deferred_candidate_count={summary.deferred_candidate_count}",
            f"l15_soft_cap_policy={summary.soft_cap_policy}",
            f"result_size={len(updated.encode('utf-8'))}",
            f"payload_checksum={payload_checksum(updated.splitlines())}",
            "authority=calculation_support_only",
            "candidate_pool_runtime=false",
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
