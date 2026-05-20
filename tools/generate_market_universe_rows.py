#!/usr/bin/env python3
"""
AURORA CORE - Market Universe Row Generator

Generates the Runtime 2 MQL5 universe row include from:
  Aurora_Bucket_System_Hierarchy_EA_READY_PUBLIC_RESEARCH_FIXED.xlsx / EA Export Safe

Output:
  mt5/runtime_owners/runtime_2_market_universe_taxonomy_lookup/AC_MarketUniverseRows.mqh

This is lookup-only data generation. It does not create ranking runtime,
selection runtime, trade permission, edge proof, or prop-firm readiness.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
import zipfile
from pathlib import Path
from typing import Dict, Iterable, List, Optional
from xml.etree import ElementTree as ET

SOURCE_SHEET = "EA Export Safe"
SCHEMA_VERSION = "universe_rows_v0.1"
EXPECTED = {
    "total_rows": 1703,
    "strict_rank_allowed_rows": 1294,
    "public_research_rank_allowed_rows": 224,
    "review_only_rows": 184,
    "blocked_rows": 1,
}

ROW_SCHEMA = [
    "server",
    "broker_file",
    "broker_symbol",
    "canonical_symbol",
    "asset_class",
    "market_group",
    "market_segment",
    "ranking_group",
    "strict_rank_allowed",
    "public_research_rank_allowed",
    "review_lane",
    "classification_confidence",
    "evidence_rank",
    "runtime_permission",
    "evidence_status",
    "source_status",
    "block_reason",
]

REQUIRED_SOURCE_COLUMNS = [
    "server",
    "broker_file",
    "broker_symbol",
    "canonical_symbol",
    "broker_group",
    "broker_subgroup",
    "instrument_class",
    "instrument_subclass",
    "aggregation_group",
    "strict_rank_allowed",
    "public_research_rank_allowed",
    "review_lane",
    "classification_confidence",
    "evidence_rank",
    "runtime_permission",
    "evidence_status",
    "source_status",
    "block_reason",
]

NS_MAIN = "{http://schemas.openxmlformats.org/spreadsheetml/2006/main}"
NS_REL = "{http://schemas.openxmlformats.org/officeDocument/2006/relationships}"
REL_NS = "{http://schemas.openxmlformats.org/package/2006/relationships}"


def clean(value: object) -> str:
    return str(value or "").replace("\r", " ").replace("\n", " ").strip()


def col_to_index(cell_ref: str) -> int:
    letters = re.sub(r"[^A-Z]", "", cell_ref.upper())
    value = 0
    for char in letters:
        value = value * 26 + (ord(char) - ord("A") + 1)
    return value - 1


def read_shared_strings(zf: zipfile.ZipFile) -> List[str]:
    try:
        raw = zf.read("xl/sharedStrings.xml")
    except KeyError:
        return []
    root = ET.fromstring(raw)
    values: List[str] = []
    for si in root.findall(f"{NS_MAIN}si"):
        parts: List[str] = []
        for t in si.iter(f"{NS_MAIN}t"):
            parts.append(t.text or "")
        values.append("".join(parts))
    return values


def workbook_sheet_path(zf: zipfile.ZipFile, sheet_name: str) -> str:
    workbook = ET.fromstring(zf.read("xl/workbook.xml"))
    rels = ET.fromstring(zf.read("xl/_rels/workbook.xml.rels"))
    rid_to_target: Dict[str, str] = {}
    for rel in rels.findall(f"{REL_NS}Relationship"):
        rid = rel.attrib.get("Id")
        target = rel.attrib.get("Target")
        if rid and target:
            rid_to_target[rid] = target

    for sheet in workbook.findall(f".//{NS_MAIN}sheet"):
        if sheet.attrib.get("name") != sheet_name:
            continue
        rid = sheet.attrib.get(f"{NS_REL}id")
        target = rid_to_target.get(rid or "")
        if not target:
            raise RuntimeError(f"Sheet relationship not found for {sheet_name!r}")
        if target.startswith("/"):
            return target.lstrip("/")
        if target.startswith("xl/"):
            return target
        return "xl/" + target
    raise RuntimeError(f"Sheet not found: {sheet_name!r}")


def read_sheet_rows(xlsx_path: Path, sheet_name: str) -> List[List[str]]:
    with zipfile.ZipFile(xlsx_path) as zf:
        shared = read_shared_strings(zf)
        root = ET.fromstring(zf.read(workbook_sheet_path(zf, sheet_name)))
        rows: List[List[str]] = []
        for row in root.findall(f".//{NS_MAIN}row"):
            values_by_col: Dict[int, str] = {}
            max_col = -1
            for cell in row.findall(f"{NS_MAIN}c"):
                col_idx = col_to_index(cell.attrib.get("r", "A1"))
                max_col = max(max_col, col_idx)
                cell_type = cell.attrib.get("t")
                value_node = cell.find(f"{NS_MAIN}v")
                inline_node = cell.find(f"{NS_MAIN}is/{NS_MAIN}t")
                value = ""
                if cell_type == "s" and value_node is not None:
                    value = shared[int(value_node.text or "0")]
                elif cell_type == "inlineStr" and inline_node is not None:
                    value = inline_node.text or ""
                elif value_node is not None:
                    value = value_node.text or ""
                values_by_col[col_idx] = clean(value)
            if max_col >= 0:
                rows.append([values_by_col.get(i, "") for i in range(max_col + 1)])
        return rows


def load_records(xlsx_path: Path) -> List[Dict[str, str]]:
    rows = read_sheet_rows(xlsx_path, SOURCE_SHEET)
    if not rows:
        raise RuntimeError("No rows found in source sheet")
    headers = [clean(h) for h in rows[0]]
    missing = [col for col in REQUIRED_SOURCE_COLUMNS if col not in headers]
    if missing:
        raise RuntimeError(f"Missing required columns: {missing}")
    records: List[Dict[str, str]] = []
    for raw in rows[1:]:
        padded = raw + [""] * (len(headers) - len(raw))
        record = {headers[i]: clean(padded[i]) for i in range(len(headers))}
        if record.get("broker_symbol"):
            records.append(record)
    return records


def f(row: Dict[str, str], key: str) -> str:
    return clean(row.get(key, ""))


def derive_asset_class(row: Dict[str, str]) -> str:
    instrument_class = f(row, "instrument_class").lower()
    if "forex" in instrument_class:
        return "FX"
    if "crypto" in instrument_class:
        return "Crypto"
    if "commodity" in instrument_class:
        return "Commodities"
    if "index" in instrument_class:
        return "Indices"
    if "rate" in instrument_class or "bond" in instrument_class:
        return "Rates"
    if "stock" in instrument_class or "equity" in instrument_class:
        return "Equities"
    return f(row, "broker_group") or "Unknown"


def derive_market_group(row: Dict[str, str]) -> str:
    asset_class = derive_asset_class(row)
    broker_group = f(row, "broker_group")
    broker_subgroup = f(row, "broker_subgroup")
    public_sector = f(row, "public_research_sector")
    if asset_class == "FX":
        return broker_subgroup or "Forex"
    if asset_class in {"Crypto", "Commodities", "Indices", "Rates"}:
        return broker_subgroup or broker_group or asset_class
    if asset_class == "Equities":
        return public_sector or broker_subgroup or broker_group or "Equities"
    return broker_group or broker_subgroup or "Unknown"


def derive_market_segment(row: Dict[str, str]) -> str:
    asset_class = derive_asset_class(row)
    broker_subgroup = f(row, "broker_subgroup")
    instrument_subclass = f(row, "instrument_subclass")
    public_sector = f(row, "public_research_sector")
    if asset_class == "Equities":
        return broker_subgroup or public_sector or instrument_subclass or "Equity"
    if asset_class == "FX":
        return instrument_subclass.replace("Other / Exotic Pair", "Exotic Pair") or broker_subgroup or "Forex"
    return instrument_subclass or broker_subgroup or "Unknown"


def to_universe_row(row: Dict[str, str]) -> Dict[str, str]:
    return {
        "server": f(row, "server"),
        "broker_file": f(row, "broker_file"),
        "broker_symbol": f(row, "broker_symbol"),
        "canonical_symbol": f(row, "canonical_symbol"),
        "asset_class": derive_asset_class(row),
        "market_group": derive_market_group(row),
        "market_segment": derive_market_segment(row),
        "ranking_group": f(row, "aggregation_group") or derive_market_group(row),
        "strict_rank_allowed": f(row, "strict_rank_allowed") or "NO",
        "public_research_rank_allowed": f(row, "public_research_rank_allowed") or "NO",
        "review_lane": f(row, "review_lane"),
        "classification_confidence": f(row, "classification_confidence"),
        "evidence_rank": f(row, "evidence_rank"),
        "runtime_permission": f(row, "runtime_permission") or "LOOKUP_ONLY_NOT_TRADE_PERMISSION",
        "evidence_status": f(row, "evidence_status"),
        "source_status": f(row, "source_status"),
        "block_reason": f(row, "block_reason") or f(row, "issue_code"),
    }


def validate_counts(rows: List[Dict[str, str]]) -> Dict[str, int]:
    counts = {
        "total_rows": len(rows),
        "strict_rank_allowed_rows": sum(1 for row in rows if f(row, "strict_rank_allowed") == "YES"),
        "public_research_rank_allowed_rows": sum(1 for row in rows if f(row, "public_research_rank_allowed") == "YES"),
        "review_only_rows": sum(1 for row in rows if f(row, "review_lane").startswith("REVIEW_ONLY")),
        "blocked_rows": sum(1 for row in rows if f(row, "review_lane") == "BLOCKED_NOT_RANKABLE"),
    }
    if counts != EXPECTED:
        raise RuntimeError(f"Count mismatch: actual={counts} expected={EXPECTED}")
    return counts


def mql_escape(value: str) -> str:
    return clean(value).replace("|", "/").replace("\\", "\\\\").replace('"', '\\"')


def generate_mql(rows: List[Dict[str, str]]) -> str:
    counts = validate_counts(rows)
    out: List[str] = []
    out.append("#ifndef AC_MARKET_UNIVERSE_ROWS_MQH")
    out.append("#define AC_MARKET_UNIVERSE_ROWS_MQH")
    out.append("")
    out.append("// AUTO-GENERATED FILE. Do not hand edit.")
    out.append("// Source: Aurora_Bucket_System_Hierarchy_EA_READY_PUBLIC_RESEARCH_FIXED.xlsx / EA Export Safe")
    out.append("// Status: lookup-only universe copy; not ranking runtime, not selection runtime, not trade permission.")
    out.append("")
    out.append(f'static const string AC_UNIVERSE_GENERATED_SCHEMA_VERSION = "{SCHEMA_VERSION}";')
    out.append(f'static const string AC_UNIVERSE_ROW_SCHEMA = "{"|".join(ROW_SCHEMA)}";')
    out.append(f"static const int AC_UNIVERSE_GENERATED_ROW_COUNT = {counts['total_rows']};")
    out.append(f"static const int AC_UNIVERSE_GENERATED_STRICT_RANK_ALLOWED = {counts['strict_rank_allowed_rows']};")
    out.append(f"static const int AC_UNIVERSE_GENERATED_PUBLIC_RESEARCH_RANK_ALLOWED = {counts['public_research_rank_allowed_rows']};")
    out.append(f"static const int AC_UNIVERSE_GENERATED_REVIEW_ONLY = {counts['review_only_rows']};")
    out.append(f"static const int AC_UNIVERSE_GENERATED_BLOCKED = {counts['blocked_rows']};")
    out.append("")
    out.append("string AC_UniverseGeneratedRow(const int index)")
    out.append("{")
    out.append("   switch(index)")
    out.append("   {")
    for index, source_row in enumerate(rows):
        row = to_universe_row(source_row)
        row_text = "|".join(mql_escape(row[field]) for field in ROW_SCHEMA)
        out.append(f'      case {index}: return "{row_text}";')
    out.append("      default: return \"\";")
    out.append("   }")
    out.append("}")
    out.append("")
    out.append("#endif")
    out.append("")
    return "\n".join(out)


def write_audit(path: Path, counts: Dict[str, int], out_path: Path) -> None:
    audit = {
        "schema_name": "market_universe_generation_audit",
        "schema_version": SCHEMA_VERSION,
        "source_sheet": SOURCE_SHEET,
        "generated_file": str(out_path).replace("\\", "/"),
        "counts": counts,
        "runtime_permission": "LOOKUP_ONLY_NOT_TRADE_PERMISSION",
        "ranking_runtime": False,
        "selection_runtime": False,
        "trade_permission": False,
    }
    path.write_text(json.dumps(audit, indent=2) + "\n", encoding="utf-8")


def main(argv: Optional[Iterable[str]] = None) -> int:
    parser = argparse.ArgumentParser(description="Generate AURORA CORE Runtime 2 universe rows include")
    parser.add_argument("workbook", type=Path, help="Path to source .xlsx workbook")
    parser.add_argument("--out", type=Path, default=Path("mt5/runtime_owners/runtime_2_market_universe_taxonomy_lookup/AC_MarketUniverseRows.mqh"))
    parser.add_argument("--audit-out", type=Path, default=Path("docs/market_universe_generation_audit.json"))
    args = parser.parse_args(list(argv) if argv is not None else None)

    rows = load_records(args.workbook)
    counts = validate_counts(rows)
    mql = generate_mql(rows)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.audit_out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(mql, encoding="utf-8")
    write_audit(args.audit_out, counts, args.out)
    print(json.dumps({"generated": str(args.out), "audit": str(args.audit_out), "counts": counts}, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
