# AURORA CORE - SYMBOL OMIT AND CALCULATION MODE CONTROL

**System:** AURORA CORE  
**Status:** Mandatory quality control.  
**Evidence:** Operator MT5 screenshots, 2026-05-20.

---

## 0. Purpose

Aurora must not keep publishing known unusable broker symbols in normal operator outputs just because they exist in an import sheet or Market Watch.

Aurora also must not do value, margin, pip, tick, or profit/loss math until the symbol calculation mode and required broker spec fields are captured.

---

## 1. Operator Omit Set

The following symbols were marked by the operator as unusable/dead from MT5 evidence and must be omitted from normal Aurora outputs until manually cleared with new evidence:

```text
11.xhkg
1186.xhkg
1800.xhkg
3188.xhkg
728.xhkg
762.xhkg
883.xhkg
941.xhkg
INCUSD.c
SGCSGD.c
TWCUSD.c
813.xhkg
2007.xhkg
410.xhkg
272.xhkg
```

Required handling:

```text
omit_from_normal_outputs=true
omit_reason=operator_marked_unusable_from_mt5_marketwatch_evidence
```

They may appear only in an audit/suppressed-symbol report that explains they were omitted.

---

## 2. Runtime Import Rule

Runtime 2 must apply the omit set during universe import and diagnostics.

Required future diagnostics:

```text
source_row_count
loaded_row_count
operator_omit_count
eligible_lookup_row_count
strict_rank_allowed_count
public_research_rank_allowed_count
review_only_count
blocked_count
review_or_blocked_count
duplicate_primary_key_count
```

A symbol in the omit set must not become a normal eligible lookup row.

---

## 3. Calculation Mode Control

Every symbol spec/Dossier surface must capture calculation mode before true value math is trusted.

Required fields:

```text
SYMBOL_TRADE_CALC_MODE
calculation_mode_name
SYMBOL_TRADE_CONTRACT_SIZE
SYMBOL_TRADE_TICK_SIZE
SYMBOL_TRADE_TICK_VALUE
SYMBOL_TRADE_TICK_VALUE_PROFIT
SYMBOL_TRADE_TICK_VALUE_LOSS
SYMBOL_POINT
SYMBOL_DIGITS
SYMBOL_CURRENCY_BASE
SYMBOL_CURRENCY_PROFIT
SYMBOL_CURRENCY_MARGIN
SYMBOL_MARGIN_INITIAL
SYMBOL_MARGIN_MAINTENANCE
SYMBOL_MARGIN_HEDGED
SYMBOL_SPREAD_FLOAT
SYMBOL_TRADE_MODE
SYMBOL_TRADE_EXEMODE
SYMBOL_FILLING_MODE
SYMBOL_ORDER_MODE
```

Required checks:

```text
OrderCalcMargin check
OrderCalcProfit check
SymbolInfoMarginRate check where available
calculation_mode_missing warning
unsupported_calculation_mode warning
missing_tick_value warning
invalid_contract_size warning
currency_conversion_needed warning
```

Aurora must not assume all instruments calculate like Forex. Operator screenshots show different calculation modes such as CFD Index, Forex, and Crypto Currency.

---

## 4. Output Quality Order

Future symbol Dossiers and broker-spec outputs should show:

```text
1. symbol identity
2. open/closed/unknown status
3. operator omit status
4. calculation mode
5. contract/tick/currency fields
6. quote freshness and Market Watch fields
7. margin/profit validation checks
8. ranking/selection eligibility
9. trade_permission=false until separately proven
```

---

## 5. Falsifiers

Hold the patch if:

```text
operator-omitted symbols appear in normal output surfaces
calculation mode is missing from broker-spec truth
Forex-style value math is applied to CFD/crypto/index symbols without calculation-mode proof
OrderCalcMargin or OrderCalcProfit failure is hidden
missing tick/contract/currency data is hidden
```

---

## 6. Current State

```text
control_doc_created
runtime2_import_not_yet_landed
operator_omit_not_yet_compiled_into_ea
calculation_mode_not_yet_runtime_observed
trade_permission=false
```

Decision:

```text
TEST FIRST
```
