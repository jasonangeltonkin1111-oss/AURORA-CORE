# 00 REPORTS INDEX

## Purpose
Navigation for review reports, specialist pressure-test handoffs, and non-runtime audit evidence.

## Authority boundary
Reports are historical/audit evidence only. They do not override active source, control files, compile proof, runtime output, MT5 visual proof, or trading permission.

## Active reports
| path | role | status | notes |
|---|---|---|---|
| `reports/specialist_trading_journal_account_report_pressure_test_pr54.md` | Trading journal / account report specialist pressure-test for PR #54 | Active audit handoff | Non-runtime report; no source authority; no merge permission. |
| `reports/2026-05-25_git_landing_proof_ledger.md` | Git landing proof ledger | Active audit ledger | Separates branch/PR/main landing/proof classes for worker and overseer reconciliation. |

## No-go rules
- Do not treat reports as implementation truth.
- Do not claim compile, runtime, prop-firm, edge, or trading readiness from a report.
- Do not add generated runtime outputs here.
- Do not duplicate layer owners or prescribe hidden authority.

## Update rules
Update this index when a report is added, removed, or superseded.
