from __future__ import annotations

import tempfile
import time
import unittest
from pathlib import Path

from aurora_worker_io import payload_checksum
from aurora_worker_l7_session import publish_l7_session_relevance_rankings


L7_FOLDER = "Layer_7_Session_Relevance_Ranking"


def _write(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def _kv(path: Path) -> dict[str, str]:
    data: dict[str, str] = {}
    for raw in path.read_text(encoding="utf-8").splitlines():
        if raw and "=" in raw:
            key, value = raw.split("=", 1)
            data[key] = value
    return data


def _input_csv() -> str:
    return "\n".join([
        "symbol,l5_gate_status,l5_gate_reason,asset_class,ranking_group,market_state,server_time_unix,server_day_of_week,server_time_of_day_seconds,session_time_basis,session_definition_source,quote_quality,surface_quality,bid,ask,spread_points,spread_bps,daily_change_pct,tick_age_seconds,zero_spread_state,trade_permission",
        "EURUSD,pass,ok,FX,Forex Majors,open,1760000000,2,46800,broker_server_time_of_day_from_L4_refresh_time_marketwatch_caveat,pending_gateway_static_profile,Fresh,Surface Usable,1.1000000000,1.1001000000,1.000000,1.000000,0.100000,1.000000,normal,false",
        "USDJPY,pass,ok,FX,Forex Majors,open,1760000000,2,46800,broker_server_time_of_day_from_L4_refresh_time_marketwatch_caveat,pending_gateway_static_profile,Fresh,Surface Usable,150.0000000000,150.0100000000,1.000000,1.000000,0.100000,1.000000,normal,false",
        "",
    ])


def _checksum(text: str) -> str:
    return payload_checksum([line for line in text.replace("\r\n", "\n").splitlines() if line.strip()])


def _seed_input(outbox: Path, *, row_count: int = 2, checksum: str | None = None) -> Path:
    layer = outbox / "Layers" / L7_FOLDER
    csv_text = _input_csv()
    _write(layer / "l7_input_primitives.csv", csv_text)
    manifest_checksum = checksum if checksum is not None else _checksum(csv_text)
    _write(layer / "l7_input_primitives.manifest", "\n".join([
        "schema_name=l7_session_relevance_input_primitives_manifest",
        "schema_version=4",
        f"row_count={row_count}",
        "l5_gate_pass=2",
        "write_ok=true",
        f"payload_checksum={manifest_checksum}",
        "session_time_basis=broker_server_time_of_day_from_L4_refresh_time_marketwatch_caveat",
        "authority=calculation_support_only",
        "trade_permission=false",
        "ranking_runtime=false",
        "selection_runtime=false",
        "execution=false",
        "",
    ]))
    return layer


class L7SessionRelevanceTests(unittest.TestCase):
    def test_l7_ranks_stable_input_and_writes_symbol_rank_count(self) -> None:
        with tempfile.TemporaryDirectory() as td:
            outbox = Path(td) / "Gateway" / "Outbox"
            layer = _seed_input(outbox)

            summary = publish_l7_session_relevance_rankings(outbox)
            manifest = _kv(layer / "ranked_symbols.manifest")

            self.assertEqual(summary.status, "complete")
            self.assertEqual(summary.row_count, 2)
            self.assertTrue((layer / "ranked_symbols.csv").exists())
            self.assertTrue((layer / "ranked_symbols_top20.txt").exists())
            self.assertEqual(summary.symbol_rank_files_actual, summary.row_count)
            self.assertEqual(manifest["symbol_rank_file_count_ok"], "true")

    def test_l7_degrades_mismatched_manifest_row_count_or_checksum(self) -> None:
        with tempfile.TemporaryDirectory() as td:
            outbox = Path(td) / "Gateway" / "Outbox"
            layer = _seed_input(outbox, row_count=3)
            row_summary = publish_l7_session_relevance_rankings(outbox)
            row_manifest = _kv(layer / "ranked_symbols.manifest")

            self.assertEqual(row_summary.status, "input_degraded")
            self.assertIn("row count", row_summary.reason)
            self.assertEqual(row_manifest["status"], "input_degraded")

        with tempfile.TemporaryDirectory() as td:
            outbox = Path(td) / "Gateway" / "Outbox"
            layer = _seed_input(outbox, checksum="bad_checksum")
            checksum_summary = publish_l7_session_relevance_rankings(outbox)
            checksum_manifest = _kv(layer / "ranked_symbols.manifest")

            self.assertEqual(checksum_summary.status, "input_degraded")
            self.assertIn("payload checksum", checksum_summary.reason)
            self.assertEqual(checksum_manifest["input_payload_checksum_matches_source_manifest"], "false")

    def test_l7_reused_unchanged_output_refreshes_manifest_proof(self) -> None:
        with tempfile.TemporaryDirectory() as td:
            outbox = Path(td) / "Gateway" / "Outbox"
            layer = _seed_input(outbox)

            first = publish_l7_session_relevance_rankings(outbox)
            first_manifest = _kv(layer / "ranked_symbols.manifest")
            time.sleep(1.1)
            second = publish_l7_session_relevance_rankings(outbox)
            second_manifest = _kv(layer / "ranked_symbols.manifest")

            self.assertEqual(first.status, "complete")
            self.assertEqual(second.status, "complete")
            self.assertTrue(second.reason.startswith("skipped_unchanged_input_reused_existing_ranked_outputs;"))
            self.assertEqual(second_manifest["reused_current_output"], "true")
            self.assertNotEqual(first_manifest["generated_unix"], second_manifest["generated_unix"])

    def test_l7_outputs_never_grant_permission_selection_or_execution(self) -> None:
        with tempfile.TemporaryDirectory() as td:
            outbox = Path(td) / "Gateway" / "Outbox"
            layer = _seed_input(outbox)

            publish_l7_session_relevance_rankings(outbox)
            combined = "\n".join([
                (layer / "ranked_symbols.manifest").read_text(encoding="utf-8"),
                (layer / "ranked_symbols.csv").read_text(encoding="utf-8"),
                "\n".join(path.read_text(encoding="utf-8") for path in (layer / "SymbolRanks").glob("*.txt")),
            ])

            self.assertNotIn("trade_permission=true", combined)
            self.assertNotIn("selection_runtime=true", combined)
            self.assertNotIn("execution=true", combined)
            self.assertIn("trade_permission=false", combined)
            self.assertIn("selection_runtime=false", combined)
            self.assertIn("execution=false", combined)


if __name__ == "__main__":
    unittest.main()
