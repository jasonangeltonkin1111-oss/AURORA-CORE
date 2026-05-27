from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import List

from aurora_worker_io import WorkerPaths, atomic_write_text, utc_stamp, unix_time

L21_STATUS = "design_hold_l20_required"
L21_REASON = "L21 is design-only until L20 is accepted and stable on main."
L21_LAYER_FOLDER_NAME = "Layer_21_Selected_Indicator_Reference_Pack"


@dataclass(frozen=True)
class L21PublishSummary:
    status: str
    reason: str
    selected_dossiers_seen: int = 0
    selected_dossiers_decorated: int = 0
    selected_dossiers_missing_symbol: int = 0
    selected_route_dossiers_seen: int = 0
    selected_route_dossiers_decorated: int = 0
    selected_unique_symbols_seen: int = 0
    selected_duplicate_route_copies: int = 0
    source_files_expected: int = 0
    source_files_found: int = 0
    source_files_missing: int = 0
    source_files_partial: int = 0
    source_decode_errors: int = 0
    timeframe_packets_rendered: int = 0
    indicator_complete_packets: int = 0
    indicator_degraded_packets: int = 0
    indicator_missing_packets: int = 0
    vwap_real_volume_packets: int = 0
    vwap_tick_volume_proxy_packets: int = 0
    vwap_unavailable_packets: int = 0
    write_failed_count: int = 0
    latest_bar_age_max_seconds: int = -1
    freshness_status: str = "blocked_design_only"
    status_path: str = "not_available"
    board_path: str = "not_available"
    layer_folder: str = "not_available"


EMPTY_L21_SUMMARY = L21PublishSummary("pending", "l21_not_run")


def _account_root(root: Path) -> Path:
    return WorkerPaths.from_root(root).outbox.parents[2]


def _layer_folder(root: Path) -> Path:
    return WorkerPaths.from_root(root).outbox / "Layers" / L21_LAYER_FOLDER_NAME


def _board_path(root: Path) -> Path:
    return _account_root(root) / "Selection Desk" / "91_Layer_Summaries" / "L21_Selected_Indicator_Reference_Pack" / "00_L21_Board_Overview.txt"


def _summary(root: Path, status: str = L21_STATUS, reason: str = L21_REASON) -> L21PublishSummary:
    layer_folder = _layer_folder(root)
    return L21PublishSummary(
        status=status,
        reason=reason,
        status_path=str(layer_folder / "l21_status.txt"),
        board_path=str(_board_path(root)),
        layer_folder=str(layer_folder),
    )


def _status_text(summary: L21PublishSummary) -> str:
    return "\n".join([
        "schema_name=l21_selected_indicator_reference_pack_status",
        "schema_version=3",
        "layer_id=L21",
        "layer_name=selected_indicator_reference_pack",
        f"status={summary.status}",
        f"reason={summary.reason}",
        "design_status=design_scaffold_only",
        "merge_allowed=false",
        "merge_blocker=L20_not_accepted_and_stable_on_main",
        "runtime_activation_allowed=false_until_L20_accepted_and_stable",
        "selected_scope_only=true",
        "upstream_required=L20_selected_rolling_tick_pack",
        "indicator_pack_module_law=one_indicator_pack_one_module_one_deep_research_run",
        "core_role=reference_context_indicators_only",
        "realistic_fields=atr_value,atr_percentile,sma_50_value,sma_200_value,sma_context_state,donchian_period,donchian_high,donchian_low,donchian_breakout_candidate,bollinger_width,bollinger_position,vwap_value,vwap_session_basis,vwap_distance_pips,volume_source_type",
        "copyrates_by_l21=false",
        "copyticks_by_l21=false",
        "private_ohlc_cache=false",
        "all_symbol_deep_evidence=false",
        "raw_ohlc_store_writes=false",
        "base_dossiers_touched=false",
        "indicator_meaning=reference_context_only_not_signal",
        "trade_permission=false",
        "entry_signal=false",
        "execution=false",
        "expectancy_validated=false",
        f"status_path={summary.status_path}",
        f"board_path={summary.board_path}",
        f"generated_utc={utc_stamp()}",
        f"generated_unix={unix_time()}",
        "",
    ])


def _board_text(summary: L21PublishSummary) -> str:
    return "\n".join([
        "L21 SELECTED INDICATOR / REFERENCE PACK",
        "Status: DESIGN HOLD",
        "Reason: L20 must be accepted and stable on main before L21 can publish indicator reference values.",
        "Purpose: selected-symbol reference/context indicators only",
        "Merge Allowed: FALSE",
        "Runtime Activation: FALSE until L20 accepted/stable",
        "Module Law: one pack / one module / one deep research run",
        "Style: simple, objective, explainable",
        "CopyRates By L21: FALSE",
        "CopyTicks By L21: FALSE",
        "Private OHLC Cache: FALSE",
        "All-Symbol Deep Scan: FALSE",
        "Trade Permission: FALSE",
        "Entry Signal: FALSE",
        "Execution: FALSE",
        "Expectancy Validated: FALSE",
        "",
        "Realistic Field Set:",
        "ATR: atr_value, atr_percentile",
        "SMA: sma_50_value, sma_200_value, sma_context_state",
        "Donchian: donchian_period, donchian_high, donchian_low, donchian_breakout_candidate",
        "Bollinger: bollinger_width, bollinger_position",
        "VWAP: vwap_value, vwap_session_basis, vwap_distance_pips",
        "Volume: volume_source_type",
        "",
        "Forbidden: indicator stacking nonsense, MACD crossover trading, RSI overbought=sell, indicator-only permission",
        "Meaning: context only, not signal authority",
        "",
        f"Generated UTC: {utc_stamp()}",
        "",
    ])


def _write(path: Path, text: str, failures: List[Path]) -> None:
    if not atomic_write_text(path, text):
        failures.append(path)


def publish_l21_indicator_reference_pack(root: Path) -> L21PublishSummary:
    summary = _summary(root)
    failures: List[Path] = []
    layer_folder = _layer_folder(root)
    layer_folder.mkdir(parents=True, exist_ok=True)
    _board_path(root).parent.mkdir(parents=True, exist_ok=True)
    _write(layer_folder / "l21_status.txt", _status_text(summary), failures)
    _write(_board_path(root), _board_text(summary), failures)
    if failures:
        return _summary(root, "design_hold_write_failed", "L21 design scaffold write failed for one or more status surfaces.")
    return summary
