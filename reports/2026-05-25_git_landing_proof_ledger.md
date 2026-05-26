# 2026-05-25 Git Landing Proof Ledger

## Purpose
This ledger separates **claimed work**, **branch/PR presence**, **main landing**, and **proof class** for AURORA CORE worker/overseer reconciliation.

It exists because a worker branch, open PR, draft PR, merged PR, source patch, compile proof, package rebuild, MT5 runtime proof, and trading permission are different evidence classes.

## Scope
- Repository: `jasonangeltonkin1111-oss/AURORA-CORE`
- Base branch inspected: `main`
- Main SHA anchor at ledger creation: `1252494c277476b8ed78127064f06d62a747ffd9`
- Ledger owner: specialist Git landing proof audit worker
- Patch authority: report-only system-wide audit support

## Evidence class ladder
| Class | Meaning | What it does not prove |
|---|---|---|
| BRANCH_EXISTS | A named branch exists on GitHub. | Does not prove main contains it. |
| PR_OPEN_DRAFT | A draft PR exists and is not merged. | Does not prove landed work. |
| PR_OPEN_READY | A non-draft open PR exists. | Does not prove landed work. |
| PR_MERGED | GitHub records the PR as merged. | Does not prove compile/runtime/MT5 proof. |
| SOURCE_WIRED | Source files were changed/created. | Does not prove syntax, compile, runtime, or trading readiness. |
| PY_SYNTAX_PROVEN | Python syntax/import proof was run and passed. | Does not prove packaged worker or MT5 runtime behavior. |
| MQL_STATIC_SNIFF | MQL source was manually/static inspected. | Does not prove MetaEditor compile. |
| METAEDITOR_COMPILE_PROVEN | MetaEditor compile proof exists. | Does not prove runtime output or trading permission. |
| RUNTIME_OUTPUT_PROVEN | MT5/worker runtime produced expected files/output. | Does not prove trading edge or prop-firm safety. |
| MT5_VISUAL_PROVEN | Board/Dossier/Workbench visible output was inspected. | Does not prove trading edge or prop-firm safety. |
| TRADING_PERMISSION_PROVEN | Explicit validation/permission evidence exists. | Not currently granted by these worker PRs. |

## Current landing snapshot from RUN 1/5 and RUN 2/5
| Area | Branch / PR | Landing state | Proof class observed | Risk / blocker | Overseer action |
|---|---|---|---|---|---|
| L1 account history budget | `worker/layer-01-account-history-budget`, PR #54 | OPEN DRAFT, not merged | SOURCE_WIRED only per PR body | Diverged from main; compile/runtime proof missing | Rebase/reconcile, MetaEditor compile, runtime smoke before merge. |
| L6 cost/friction honesty | `worker/layer-06-surface-cost-friction`, PR #55 | MERGED | SOURCE_WIRED only per PR body | Python/runtime proof missing; downstream RenderIndex/L11 compatibility needs proof | Run Python syntax and worker fixture/output checks. |
| L17 deep evidence split duplicate guard | `worker/layer-17-deep-evidence-split`, PR #56 | MERGED | SOURCE_WIRED only per PR body | Runtime proof missing | Runtime fixture/output proof before promotion. |
| L23 trader review export permission lock | `worker/layer-23-trader-review-export-permission-state`, PR #57 | MERGED | SOURCE_WIRED only per PR body | MT5 compile/runtime proof missing | Compile and visual proof before claiming accepted surface. |
| L11 manifest guard | `worker/layer-11-symbol-ranking`, PR #53 | OPEN DRAFT, not merged | SOURCE_WIRED only per PR body | Python/runtime proof missing; blocks L12+ chain | Prove L11 first before L12-L16. |
| L12 ranking group heat | `worker/layer-12-ranking-group-heat`, PR #58 | OPEN DRAFT, not merged | SOURCE_WIRED only per PR body | Depends on L11 proof | HOLD until L11 final contract/proof. |
| L13 dynamic ranking group selection | `worker/layer-13-dynamic-ranking-group-selection`, PR #59 | OPEN DRAFT, not merged | SOURCE_WIRED only per PR body | Depends on L12/L11 proof | HOLD until upstream proof. |
| L14 candidate pool | `worker/layer-14-candidate-pool`, PR #60 | OPEN DRAFT, not merged | SOURCE_WIRED only per PR body | Depends on L11-L13 proof; shared envelope risk | HOLD until upstream proof and manifest compatibility. |
| L15 correlation diversity | `worker/layer-15-correlation-diversity`, PR #61 | OPEN DRAFT, not merged | SOURCE_WIRED only per PR body | Requires synthetic correlation tests and L14 final contract | HOLD / TEST FIRST. |
| L16 global top10 | `worker/layer-16-global-top10`, PR #62 | OPEN DRAFT, not merged | SOURCE_WIRED only per PR body | Depends on L15 proof; touches shared external worker index | HOLD / overseer reconcile shared index. |

## Git landing law for future worker claims
Before saying **updated**, **patched**, **committed**, **pushed**, **created**, or **commented**, include at least one of:
- commit SHA,
- PR number,
- GitHub comment ID / URL,
- branch head SHA after the change.

If no such proof exists, the correct phrase is:

```text
NOT LANDED / PROPOSED ONLY
```

## Merge safety law
Open draft PRs are not landed on `main`.
Merged PRs are not runtime proof.
Runtime proof is not trading permission.

## Current decision
HOLD broad merges until overseer reconciles the open PR chain and proof classes.
