# Specialist Pressure-Test Handoff — Trading Journal / Account Report Lane

## Scope
Specialist lane: Trading Journal and Account Report Audit Worker.

Target reviewed: PR #54, branch `worker/layer-01-account-history-budget`.

This report is a non-runtime audit handoff. It is not source authority, compile proof, runtime proof, trading permission, prop-firm proof, or edge validation.

## Source anchor
- Repository: `jasonangeltonkin1111-oss/AURORA-CORE`
- Default branch at specialist branch creation: `main`
- Main SHA at specialist branch creation: `bada2d9fa9d805b0d01acdf6277774403411af97`
- Specialist branch: `specialist/trading-journal-account-report`
- Layer branch reviewed: `worker/layer-01-account-history-budget`
- PR reviewed: #54 `Worker L1 account history budget guard`

## Current finding summary
PR #54 is directionally correct but not merge-ready.

The PR attempts to bound Layer 1 selected-history reconstruction and surface budget-limited truth instead of pretending complete account history. That is the right intent for Aurora's capital-preservation and truth-publication discipline.

The blocker is proof and reconciliation, not concept.

## Key findings
| ID | Class | Finding | Required action |
|---|---|---|---|
| TJAR-SPT-001 | SHARED-FILE COLLISION / MERGE RISK | PR #54 branch is diverged from current `main`. | Overseer must rebase/reconcile before merge. |
| TJAR-SPT-002 | COMPILE RISK | MQL5 signature/state changes are source-reviewed only. | Worker must run MetaEditor compile after reconciliation. |
| TJAR-SPT-003 | PERFORMANCE RISK NOT PROVEN | Budget guard exists in source, but runtime timing proof is missing. | Worker must run MT5 smoke proof with Workbench timing rows. |
| TJAR-SPT-004 | PROOF GAP | No runtime output or MT5 visual proof attached. | Keep PR draft/HOLD until proof exists. |
| TJAR-SPT-005 | SAFETY WORDING | Selected-history labels were improved to prevent edge/profit/prop-firm misread. | Preserve labels during conflict resolution. |
| TJAR-SPT-006 | DUPLICATE AUTHORITY WATCH | Trade Journal support appears downstream-only, but must never become an independent history owner. | Overseer must confirm no own `HistorySelect`, no `CopyRates`, no permission claims. |

## Labels that must survive reconciliation
The following account-report labels are safety-critical:

- `L1_RESULTS`: selected-history metrics; account supervision only, not edge proof.
- `L1_SYMBOL_PERFORMANCE_BASE`: selected-history symbol performance; not strategy validation.
- `L1_DAILY_PERFORMANCE_BASE`: selected closed-trade close-date grouping; not prop-firm daily-loss basis.
- `L1_DIRECTION_SUMMARY_BASE`: selected-history buy/sell result summary; not directional edge proof.

## Required verification gates before merge
1. Rebase or reconcile PR #54 against current `main`.
2. Confirm final compare is not unexpectedly broad.
3. Run MetaEditor compile.
4. Run one full publication cycle.
5. Run one board-only publication cycle.
6. Capture Workbench/status evidence for:
   - `history_scan_budget_ms`
   - `history_scan_duration_ms`
   - `history_budget_abort_count`
   - `history_status`
   - `render_duration_ms`
   - `total_refresh_duration_ms`
   - `trade_permission=false`
   - `edge_validated=false`
   - `prop_firm_ready=false`
7. If budget abort occurs, surfaces must show partial/degraded selected-history truth, not complete account history.
8. Confirm trade journal forensics remains downstream-only:
   - no independent `HistorySelect`
   - no `CopyRates`
   - no trade permission
   - no execution permission
   - no prop-firm safety claim

## Debloat / surface guidance
- Board may show one compact history-budget line.
- Full budget proof belongs in Workbench/status rows.
- Account Status may contain richer selected-history explanations.
- Do not repeat long warnings across every Dossier or Board section.

## Affected PRs / layers
- PR #54: Layer 1 account-history budget guard.
- Runtime 1 / Layer 1 account portfolio prop-rule truth.
- Runtime 1 Trade Journal / Trade Forensics support owner, downstream-only watch.

## Verification performed by specialist
- Git branch/PR inspection.
- Compare inspection.
- Mandatory source/control index review.
- L1 account-history source review.
- Trade Journal support owner boundary review.
- PR comment added with exact worker/overseer instructions.

## Verification missing
- MetaEditor compile.
- Runtime output proof.
- MT5 visual proof.
- Actual Workbench readback.
- Rebase/reconciliation proof.

## Rollback path
- If only specialist report is rejected, delete this report and update `reports/00_REPORTS_INDEX.md`.
- If PR #54 is rejected, close/reset the L1 branch or cherry-pick only proven commits after reconciliation.
- Do not merge PR #54 without proof gates.

## Final decision
HOLD
