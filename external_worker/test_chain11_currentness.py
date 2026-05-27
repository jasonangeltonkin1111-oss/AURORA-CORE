from __future__ import annotations

import tempfile
import time
import unittest
from pathlib import Path

import aurora_worker as core
import aurora_worker_entrypoint as entrypoint
from aurora_worker_l6_friction import publish_l6_cost_friction_rankings
from aurora_worker_l15 import publish_l15_correlation_diversity_selection
from aurora_worker_l17 import publish_l17_deep_evidence_selection_split
from aurora_worker_l18 import DISPLAY_BARS as L18_DISPLAY_BARS
from aurora_worker_l18 import publish_l18_selected_raw_ohlc_bar_pack
from aurora_worker_l19 import DISPLAY_BARS as L19_DISPLAY_BARS
from aurora_worker_l19 import publish_l19_candle_geometry_and_structure


def _account_root(tmp: Path) -> Path:
    root = tmp / "Aurora Core" / "Upcomers-Server" / "18503"
    (root / "Gateway" / "Outbox").mkdir(parents=True)
    (root / "Gateway" / "Status").mkdir(parents=True)
    return root


def _write(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def _seed_csv(rows: int = 70) -> str:
    now = int(time.time())
    lines = ["bar_time,open_i,high_i,low_i,close_i,tick_volume,spread,real_volume"]
    start = now - rows * 60
    for idx in range(rows):
        base = 100000 + idx * 10
        lines.append(f"{start + idx * 60},{base},{base + 5},{base - 5},{base + 2},100,1,0")
    return "\n".join(lines) + "\n"


def _zero_range_seed_csv(rows: int = 5) -> str:
    now = int(time.time())
    lines = ["bar_time,open_i,high_i,low_i,close_i,tick_volume,spread,real_volume"]
    start = now - rows * 60
    for idx in range(rows):
        price = 100000
        lines.append(f"{start + idx * 60},{price},{price},{price},{price},100,1,0")
    return "\n".join(lines) + "\n"


def _invalid_seed_csv(rows: int = 5) -> str:
    now = int(time.time())
    lines = ["bar_time,open_i,high_i,low_i,close_i,tick_volume,spread,real_volume"]
    start = now - rows * 60
    for idx in range(rows):
        lines.append(f"{start + idx * 60},100000,99900,100100,100000,100,1,0")
    return "\n".join(lines) + "\n"


def _selected_dossier(root: Path, symbol: str = "EURUSD") -> Path:
    path = root / "Selection Desk" / "01_Global" / "Top_10" / f"01_{symbol}.txt"
    _write(path, f"Symbol: {symbol}\nBASE BODY\n")
    return path


def _complete_result_latest(overrides: dict[str, str] | None = None) -> str:
    data = {
        "l6_rank_status": "complete",
        "l7_rank_status": "complete",
        "l8_rank_status": "complete",
        "l9_rank_status": "complete",
        "l11_symbol_ranking_status": "accepted",
        "l12_group_heat_quality_status": "accepted",
        "l13_dynamic_group_selection_status": "accepted",
        "l14_candidate_pool_status": "accepted",
        "l14_current_chain_valid": "true",
        "l14_downstream_allowed": "true",
        "l15_correlation_diversity_status": "accepted",
        "l15_current_chain_valid": "true",
        "l15_downstream_allowed": "true",
        "l16_global_top10_status": "accepted",
        "l16_current_chain_valid": "true",
        "l16_downstream_allowed": "true",
        "l17_deep_evidence_selection_status": "accepted",
        "l17_current_chain_valid": "true",
        "l17_downstream_allowed": "true",
        "l18_selected_raw_ohlc_status": "complete_history_limited",
        "l18_current_chain_valid": "true",
        "l18_downstream_allowed": "true",
        "l19_candle_geometry_status": "complete_history_limited",
        "l19_current_chain_valid": "true",
        "l19_downstream_allowed": "true",
    }
    if overrides:
        data.update(overrides)
    return "\n".join(f"{key}={value}" for key, value in data.items()) + "\n"


class Chain11CurrentnessTests(unittest.TestCase):
    def test_shared_daemon_discovers_account_gateway_worker_required(self) -> None:
        with tempfile.TemporaryDirectory() as td:
            shared = Path(td) / "Aurora Core"
            account_root = shared / "Upcomers-Server" / "18503"
            _write(account_root / "Gateway" / "Status" / "worker_required.txt", "required=true\n")
            _write(account_root / "Workbench" / "Gateway" / "Control" / "worker_required.txt", "legacy=true\n")

            self.assertEqual(core.discover_roots(shared), [account_root])

    def test_l6_missing_input_manifest_is_not_accepted(self) -> None:
        with tempfile.TemporaryDirectory() as td:
            outbox = Path(td) / "Gateway" / "Outbox"
            layer = outbox / "Layers" / "Layer_6_Cost_Friction_Ranking"
            _write(layer / "l6_input_primitives.csv", "symbol,spread_bps,spread_points,trade_permission\nEURUSD,1,1,false\n")

            summary = publish_l6_cost_friction_rankings(outbox)
            manifest = (layer / "ranked_symbols.manifest").read_text(encoding="utf-8")

            self.assertEqual(summary.status, "input_degraded")
            self.assertIn("l6_input_primitives.manifest missing", summary.reason)
            self.assertIn("status=input_degraded", manifest)
            self.assertTrue((layer / "ranked_symbols.csv").exists())

    def test_l6_positive_effective_cost_scores_without_type_error(self) -> None:
        with tempfile.TemporaryDirectory() as td:
            outbox = Path(td) / "Gateway" / "Outbox"
            layer = outbox / "Layers" / "Layer_6_Cost_Friction_Ranking"
            rows = "\n".join([
                "symbol,spread_bps,spread_points,spread_cost_worst_minlot_account,value_formula_spread_cost_minlot_account,tickvalue_spread_cost_minlot_account,contract_spread_cost_minlot_raw,contract_cost_status,cost_model_compare_status,cost_model_mismatch_ratio,account_cost_zero_nonzero_spread_suspicious,volume_model_quality,commission_model_status,quote_quality,surface_quality,value_quality,margin_quality,trade_permission",
                "EURUSD,1,1,0.70,0.60,0.65,0.55,raw_account_currency_ok,aligned,1.0,false,normal,known_machine_verified,Fresh,Surface Usable,Value Formula Ready,Margin Formula Ready,false",
                "",
            ])
            checksum = core.payload_checksum([line for line in rows.splitlines() if line.strip()])
            _write(layer / "l6_input_primitives.csv", rows)
            _write(layer / "l6_input_primitives.manifest", f"row_count=1\nl5_gate_pass=1\npayload_checksum={checksum}\n")

            summary = publish_l6_cost_friction_rankings(outbox)
            ranked = (layer / "ranked_symbols.csv").read_text(encoding="utf-8")

            self.assertEqual(summary.status, "complete")
            self.assertIn("effective_cost_minlot_account", ranked)
            self.assertIn("0.700000", ranked)

    def test_l17_refuses_stale_l16_csv(self) -> None:
        with tempfile.TemporaryDirectory() as td:
            root = _account_root(Path(td))
            outbox = root / "Gateway" / "Outbox"
            _write(outbox / "result_latest.txt", "\n".join([
                "l16_global_top10_status=accepted",
                "l16_current_chain_valid=false",
                "l16_downstream_allowed=false",
                "l16_visible_output_source=held_previous",
                "l16_currentness_reason=synthetic_stale_l16",
                "",
            ]))
            _write(outbox / "Layers" / "Layer_16_Global_Top10_Builder" / "l16_global_top10_summary.txt", "status=accepted\n")
            _write(outbox / "Layers" / "Layer_16_Global_Top10_Builder" / "l16_global_top10.csv", "display_slot_rank,symbol,canonical_symbol,selection_tier,clean_diversified,fallback_fill_used,l16_primary_score\n1,EURUSD,EURUSD,CLEAN,true,false,99\n")

            summary = publish_l17_deep_evidence_selection_split(outbox)

            self.assertEqual(summary.status, "pending")
            self.assertEqual(summary.latest_current, "false")
            self.assertEqual(summary.downstream_allowed, "false")
            self.assertEqual(summary.deep_selected_count, 0)

    def test_l18_and_l19_wait_for_upstream_currentness(self) -> None:
        with tempfile.TemporaryDirectory() as td:
            root = _account_root(Path(td))
            dossier = _selected_dossier(root)
            outbox = root / "Gateway" / "Outbox"
            _write(outbox / "result_latest.txt", "\n".join([
                "l17_deep_evidence_selection_status=accepted",
                "l17_current_chain_valid=false",
                "l17_downstream_allowed=false",
                "l18_selected_raw_ohlc_status=accepted",
                "l18_current_chain_valid=false",
                "l18_downstream_allowed=false",
                "",
            ]))

            l18 = publish_l18_selected_raw_ohlc_bar_pack(root)
            l19 = publish_l19_candle_geometry_and_structure(root)

            self.assertEqual(l18.status, "pending")
            self.assertEqual(l18.latest_current, "false")
            self.assertEqual(l19.status, "pending")
            self.assertEqual(l19.latest_current, "false")
            self.assertNotIn("L18 RAW OHLC", dossier.read_text(encoding="utf-8"))
            self.assertNotIn("L19 WICK CANDLE", dossier.read_text(encoding="utf-8"))

    def test_static_epoch_rejects_write_degraded(self) -> None:
        with tempfile.TemporaryDirectory() as td:
            root = _account_root(Path(td))
            outbox = root / "Gateway" / "Outbox"
            _write(outbox / "result_latest.txt", _complete_result_latest({
                "l15_correlation_diversity_status": "write_degraded",
                "l15_current_chain_valid": "false",
                "l15_downstream_allowed": "false",
            }))
            result = core.ValidationResult(True, "accepted", "ok", snapshot_id="s1", payload_checksum="p1", row_count=2)

            written = entrypoint._write_surface_epoch_if_accepted(root, result, True, True, True, True, True, True, True)

            self.assertFalse(written)
            self.assertFalse((outbox / "surface_accepted_epoch.manifest").exists())

    def test_static_epoch_rejects_incomplete_source_states(self) -> None:
        bad_states = ["pending", "partial", "missing", "stale", "decode_error", "write_failed"]
        for state in bad_states:
            with self.subTest(state=state), tempfile.TemporaryDirectory() as td:
                root = _account_root(Path(td))
                outbox = root / "Gateway" / "Outbox"
                _write(outbox / "result_latest.txt", _complete_result_latest({
                    "l15_correlation_diversity_status": state,
                    "l15_current_chain_valid": "false",
                    "l15_downstream_allowed": "false",
                }))
                result = core.ValidationResult(True, "accepted", "ok", snapshot_id="s1", payload_checksum="p1", row_count=2)

                written = entrypoint._write_surface_epoch_if_accepted(root, result, True, True, True, True, True, True, True)

                self.assertFalse(written)
                self.assertFalse((outbox / "surface_accepted_epoch.manifest").exists())

    def test_static_epoch_requires_downstream_allowed(self) -> None:
        with tempfile.TemporaryDirectory() as td:
            root = _account_root(Path(td))
            outbox = root / "Gateway" / "Outbox"
            _write(outbox / "result_latest.txt", _complete_result_latest({
                "l17_downstream_allowed": "false",
                "l17_visible_output_source": "held_previous",
            }))
            result = core.ValidationResult(True, "accepted", "ok", snapshot_id="s1", payload_checksum="p1", row_count=2)

            written = entrypoint._write_surface_epoch_if_accepted(root, result, True, True, True, True, True, True, True)

            self.assertFalse(written)
            self.assertFalse((outbox / "surface_accepted_epoch.manifest").exists())

    def test_static_epoch_accepts_strict_core_and_invalidates_on_snapshot_change(self) -> None:
        with tempfile.TemporaryDirectory() as td:
            root = _account_root(Path(td))
            outbox = root / "Gateway" / "Outbox"
            _write(outbox / "result_latest.txt", _complete_result_latest())
            result = core.ValidationResult(True, "accepted", "ok", snapshot_id="s1", payload_checksum="p1", row_count=2)

            written = entrypoint._write_surface_epoch_if_accepted(root, result, True, True, True, True, True, True, True)
            static_ok, reason, remaining = entrypoint._accepted_epoch_static_state(root, result, int(time.time()))
            changed = core.ValidationResult(True, "accepted", "ok", snapshot_id="s2", payload_checksum="p2", row_count=2)
            changed_ok, changed_reason, changed_remaining = entrypoint._accepted_epoch_static_state(root, changed, int(time.time()))

            self.assertTrue(written)
            self.assertTrue(static_ok)
            self.assertEqual(reason, "strict_accepted_epoch_static_hold_active")
            self.assertGreater(remaining, 0)
            self.assertFalse(changed_ok)
            self.assertEqual(changed_reason, "accepted_epoch_snapshot_changed")
            self.assertEqual(changed_remaining, 0)

    def test_l15_uses_m15_without_h1(self) -> None:
        with tempfile.TemporaryDirectory() as td:
            root = _account_root(Path(td))
            outbox = root / "Gateway" / "Outbox"
            l13 = outbox / "Layers" / "Layer_13_Dynamic_Ranking_Group_Selection"
            l14 = outbox / "Layers" / "Layer_14_Ranking_Group_Leader_Candidate_Pool"
            _write(l13 / "l13_selected_ranking_groups.csv", "ranking_group\nfx_major\n")
            _write(l14 / "l14_candidate_pool_summary.txt", "status=accepted\n")
            _write(l14 / "l14_candidate_pool.manifest", "status=accepted\n")
            _write(l14 / "l14_candidate_pool.csv", "\n".join([
                "candidate_pool_rank,symbol,canonical_symbol,ranking_group,ranking_group_slug,asset_class,market_group,market_segment,l14_candidate_priority_score,leader_or_backup,candidate_source",
                "1,EURUSD,EURUSD,fx_major,fx_major,FX,majors,spot,100,leader,test",
                "2,GBPUSD,GBPUSD,fx_major,fx_major,FX,majors,spot,90,leader,test",
                "",
            ]))
            shared = root.parent / "Shared Market Data" / "OHLC Store" / "Symbols"
            _write(shared / "EURUSD" / "M15.seed.csv", _seed_csv(70))
            _write(shared / "GBPUSD" / "M15.seed.csv", _seed_csv(70))

            summary = publish_l15_correlation_diversity_selection(outbox)

            self.assertEqual(summary.status, "accepted")
            self.assertGreater(summary.corr_pair_count, 0)
            pair_text = (outbox / "Layers" / "Layer_15_Correlation_Diversity_Selection" / "l15_candidate_correlation_matrix.csv").read_text(encoding="utf-8")
            self.assertIn("M15", pair_text)

    def test_l18_history_limited_is_current_but_labeled(self) -> None:
        with tempfile.TemporaryDirectory() as td:
            root = _account_root(Path(td))
            _selected_dossier(root)
            outbox = root / "Gateway" / "Outbox"
            _write(outbox / "result_latest.txt", "\n".join([
                "l17_deep_evidence_selection_status=accepted",
                "l17_current_chain_valid=true",
                "l17_downstream_allowed=true",
                "",
            ]))
            shared = root.parent / "Shared Market Data" / "OHLC Store" / "Symbols" / "EURUSD"
            for timeframe in L18_DISPLAY_BARS:
                _write(shared / f"{timeframe}.seed.csv", _seed_csv(5))

            summary = publish_l18_selected_raw_ohlc_bar_pack(root)

            self.assertEqual(summary.status, "complete_history_limited")
            self.assertEqual(summary.latest_current, "true")
            self.assertEqual(summary.downstream_allowed, "true")

    def test_l19_zero_range_is_flagged_not_fake_valid_geometry(self) -> None:
        with tempfile.TemporaryDirectory() as td:
            root = _account_root(Path(td))
            _selected_dossier(root)
            outbox = root / "Gateway" / "Outbox"
            _write(outbox / "result_latest.txt", "\n".join([
                "l17_deep_evidence_selection_status=accepted",
                "l17_current_chain_valid=true",
                "l17_downstream_allowed=true",
                "l18_selected_raw_ohlc_status=accepted",
                "l18_current_chain_valid=true",
                "l18_downstream_allowed=true",
                "",
            ]))
            shared = root.parent / "Shared Market Data" / "OHLC Store" / "Symbols" / "EURUSD"
            for timeframe in L19_DISPLAY_BARS:
                _write(shared / f"{timeframe}.seed.csv", _zero_range_seed_csv(5))

            summary = publish_l19_candle_geometry_and_structure(root)

            self.assertEqual(summary.status, "accepted")
            self.assertEqual(summary.zero_range_rows, 25)
            self.assertEqual(summary.valid_geometry_rows, 0)
            self.assertEqual(summary.invalid_geometry_rows, 0)
            self.assertEqual(summary.latest_current, "true")

    def test_l19_invalid_ohlc_fails_closed(self) -> None:
        with tempfile.TemporaryDirectory() as td:
            root = _account_root(Path(td))
            _selected_dossier(root)
            outbox = root / "Gateway" / "Outbox"
            _write(outbox / "result_latest.txt", "\n".join([
                "l17_deep_evidence_selection_status=accepted",
                "l17_current_chain_valid=true",
                "l17_downstream_allowed=true",
                "l18_selected_raw_ohlc_status=accepted",
                "l18_current_chain_valid=true",
                "l18_downstream_allowed=true",
                "",
            ]))
            shared = root.parent / "Shared Market Data" / "OHLC Store" / "Symbols" / "EURUSD"
            for timeframe in L19_DISPLAY_BARS:
                _write(shared / f"{timeframe}.seed.csv", _invalid_seed_csv(5))

            summary = publish_l19_candle_geometry_and_structure(root)

            self.assertEqual(summary.status, "partial")
            self.assertEqual(summary.latest_current, "false")
            self.assertEqual(summary.downstream_allowed, "false")
            self.assertGreater(summary.invalid_geometry_rows, 0)


if __name__ == "__main__":
    unittest.main()
