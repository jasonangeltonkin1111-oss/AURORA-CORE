# AURORA CORE — PUBLICATION SURFACE BLUEPRINT

Status: ENRICHED BLUEPRINT — publication surfaces are display/proof services, not trading truth owners.

## 0. Purpose
- Publication surfaces display and prove owner truth.
- Publication surfaces must not compute hidden truth.
- Broken/degraded truth may block review or trading, but must not hide physical files.
- File existence proves publication attempt/result only, not data correctness, edge, or permission.
- Operator-facing surfaces must show known, partial, stale, unavailable, degraded, blocked, and failed states.

## 1. What This Blueprint Owns
This blueprint owns:
- publication surface roles,
- Board / Operator Cockpit contract,
- Dossier contract,
- Selection Desk contract,
- Workbench / Diagnostics contract,
- Governance / Manifest / Telemetry publication contract,
- Atomic Update Overview contract,
- heatmap publication contract,
- publication state vocabulary,
- ownership boundaries between truth owners and renderers,
- no-hidden-compute rules,
- no-trading-permission rules.

## 2. What This Blueprint Must Not Own
This blueprint must not own:
- MT5 source implementation,
- FileIO code,
- route implementation,
- score formulas,
- ranking computation,
- ranking_group classification,
- Global Top 10 construction,
- selected evidence computation,
- permission decisions,
- validation outcomes,
- strategy edge claims,
- trading execution,
- prop-firm readiness.

## 3. Publication Architecture Split
Truth Owners produce truth. System Services publish/render/prove truth.

Trading/System Truth Owners to publication surfaces:
- Foundation Truth Owner → Board summary, Dossier foundation sections, Workbench/Governance proof.
- Surface Scoring Owner → Board summary, Dossier scoring sections, score/evidence registry.
- Taxonomy / Ranking Group Owner → Board taxonomy/ranking_group summary, Dossier taxonomy section, Selection Desk group views.
- Basket Selection Owner → Board Global Top 10 summary, Dossier selection state, Selection Desk global view.
- Selected Evidence Owner → Board selected evidence progress, Dossier deep evidence sections, evidence completeness heatmap.
- Permission / Alert Owner → Board permission/alert state, Dossier permission section, alert ledger.
- Validation / Outcome Owner → validation ledgers, outcome summaries, hypothesis/experiment records.

System Services:
- Publication / FileIO / Route Service writes files and reports write state.
- Board Renderer displays compact operator overview.
- Dossier Renderer displays symbol-level white-box truth.
- Governance / Manifest / Telemetry Service records proof rows.
- Workbench / Diagnostics Service records deeper runtime/proof/failure detail.

Current source may include early publication support so files can print. That support is implementation service support, not a market-intelligence trading layer.

## 4. Board / Operator Cockpit Contract
Board is a compact operator overview.

Board answers:
- Is Aurora alive?
- Is Aurora current?
- What is done, pending, degraded, stale, blocked, failed?
- Which symbols/ranking_groups deserve attention?
- What selected evidence is complete or pending?
- What warnings require human action?
- Is review/trade/alert permission blocked?

Board should show:
1. Header / system identity:
   - system_name, build/version label (if available), server, account, cycle_id, heartbeat_id, generated_at, runtime_state, publication_state.
2. Runtime health:
   - heartbeat age, timer duration, over-budget flag, oldest starved task age, degraded/failure counts, publication age.
3. Atomic Update Overview:
   - Foundation Truth complete/partial/pending/degraded/failed counts,
   - Surface Scoring complete/partial/pending/degraded/failed counts,
   - Taxonomy/ranking_group classified/unknown/review/omitted counts,
   - Basket Selection candidate_pool/global_top10/backup/reject status,
   - Selected Evidence OHLC/wick/tick/indicator/liquidity/DOM proxy progress,
   - Heatmaps available/partial/stale/unavailable,
   - Permission review_allowed/trade_allowed/alert_allowed/blocked reasons.
4. Account / risk snapshot:
   - account currency, balance/equity/margin/free margin (if available), drawdown/risk state (if available), prop-rule profile state, open/pending exposure summary (if available).
5. Foundation truth summary:
   - symbol universe count, open/closed/unknown/unavailable counts, stale quote count, missing spec count, calculation mode coverage, Market Watch freshness.
6. Taxonomy / ranking_group summary:
   - asset_class completion, market_group completion, market_segment completion, ranking_group completion, unknown classification count, review-only count, omitted count.
7. Surface scoring summary:
   - cost/friction state, session relevance state, movement/range state, structure/location state, score completeness, score degraded reasons.
8. Ranking group heat/status:
   - ranking_group leader count, ranking_group quality/heat state, dynamic selected ranking_groups, unstable/thin/unknown group warnings.
9. Global Top 10 inspection basket:
   - rank rows, symbol, ranking_group, asset_class, reason selected, score components summary, correlation/diversity notes, backup fill notes, not-a-trade-list warning.
10. Selected evidence progress:
   - selected symbols count, OHLC pack status, wick/candle geometry status, rolling tick pack status, indicator/reference pack status, liquidity/DOM proxy status, evidence completeness state.
11. Heatmap status:
   - Global Top 10 correlation heatmap,
   - ranking_group strength/quality heatmap,
   - session relevance heatmap,
   - cost vs movement heatmap,
   - evidence completeness heatmap.
12. Publication status:
   - Board write state, Dossier write state, Selection Desk write state, Workbench write state, Governance/Manifest write state, last write failures, route verification state.
13. Permission / Alert state:
   - class_1_system_alert_allowed,
   - class_2_setup_alert_allowed,
   - directional_alert_allowed,
   - review_allowed,
   - trade_allowed,
   - auto_trade_allowed,
   - blocked reasons.
14. Warnings / action needed:
   - stale data, missing specs, prop-rule profile missing, file publication failure, fake-alive risk, selected evidence stuck, validation missing, permission blocked.

Board must not show:
- full raw OHLC tables,
- full rolling tick dumps,
- full symbol universe dumps,
- full governance ledgers,
- full formula derivations,
- strategy hype,
- trade recommendations,
- auto-trade instructions,
- secret computed truth.

## 5. Atomic Update Overview Contract
Atomic Update Overview is compact Board progress only.

It consumes owner/layer status. It does not compute owner truth.

Required fields:
- owner_name
- layer_or_section
- status
- complete_count
- partial_count
- pending_count
- stale_count
- degraded_count
- failed_count
- blocked_count
- last_success_at
- last_attempt_at
- freshness_state
- degraded_reason
- blocked_reason
- next_expected_update

It must remain compact and must not become a full ledger.

## 6. Dossier Contract
Dossier is per-symbol white-box truth.

Dossier answers:
- What is this symbol?
- What is known?
- What is missing?
- What is stale?
- What is degraded?
- Why selected/rejected/ignored?
- What selected evidence exists?
- What permission state applies?

Dossier contains the 23-layer story:
1. Symbol Header: symbol, broker_symbol, canonical_symbol, server, account, asset_class, market_group, market_segment, ranking_group, generated_at, cycle_id, heartbeat_id.
2. Layer 1 — Account / Portfolio / Prop Rule Context: account currency, risk state, prop-rule profile state, exposure relevance, no permission claim.
3. Layer 2 — Market Open / Closed Truth: market_state, session state, open/closed/unknown/unavailable, session time basis, reason.
4. Layer 3 — Symbol + Broker Specs Truth: digits, point, tick size, tick value, contract size, trade mode, calculation mode, volume min/max/step, stops level, freeze level, margin/profit currencies, SymbolInfo* source status, missing/degraded fields.
5. Layer 4 — Market Watch Truth: bid, ask, last, spread, spread points, tick time, quote freshness, zero-spread handling, quote flags if available.
6. Layer 5 — Basic System Gate: eligible_for_review, eligible_for_scoring, blocked_reason, degraded_reason, not trade permission.
7. Layer 6 — Surface Cost / Friction Ranking: spread cost, spread-to-range if available, spread-to-ATR if available, commission/unknown commission status, friction score, descriptive only.
8. Layer 7 — Session Relevance Ranking: active session match, expected liquidity window, broker session state, local/server/session time basis, session score, descriptive only.
9. Layer 8 — Surface Movement / Range Ranking: recent range, ATR/range proxy, daily range if available, movement score, descriptive only.
10. Layer 9 — Surface Structure / Location Geometry: price location, distance to recent high/low, distance to range boundary, structure notes, no setup claim.
11. Layer 10 — Taxonomy Classification: asset_class, market_group, market_segment, ranking_group, classification source, classification confidence, unknown/review/omitted state.
12. Layer 11 — Symbol Ranking Inside Ranking Group: rank inside ranking_group, rank score summary, rank completeness, not a trade signal.
13. Layer 12 — Ranking Group Heat / Quality: group quality state, group member count, thin-group warning, heat descriptive status.
14. Layer 13 — Dynamic Ranking Group Selection: selected ranking_group flag, selection reason, group cap state, group omitted/review state.
15. Layer 14 — Ranking Group Leader Candidate Pool: candidate_pool_flag, leader/backup/rejected state, candidate reason, reject reason.
16. Layer 15 — Correlation / Diversity Selection: correlation proxy state, overlap warning, diversity accept/reject state, backup fill reason.
17. Layer 16 — Global Top 10 Builder: global_rank if selected, global_top10_flag, inspection basket status, not-a-trade-list warning.
18. Layer 17 — Deep Evidence Selection Split: selected_for_deep_evidence, reason selected/not selected, evidence budget status, selected-only rule.
19. Layer 18 — Selected Raw OHLC Bar Pack: timeframes, bar count, newest bar time, stale/missing state, OHLC completeness.
20. Layer 19 — Selected Wick / Candle Geometry Pack: body size, upper wick, lower wick, range, close location, candle geometry status, no signal claim.
21. Layer 20 — Selected Rolling Tick Pack: tick window length, tick count, bid/ask movement summary, spread behavior, stale/partial status.
22. Layer 21 — Selected Indicator / Reference Pack: ATR, Bollinger Bands, VWAP, moving averages if later used, reference pack availability, no standalone signal.
23. Layer 22 — Deep Market Evidence / Liquidity / MT5 Order-Flow Proxy Pack: liquidity map, swing high/low liquidity zones, spread/liquidity warnings, MT5 DOM availability, MarketBookAdd/MarketBookGet state if used later, order-flow proxy label, FVG/sweep/reclaim as quarantined future hypothesis only if mentioned.
24. Layer 23 — Setup / Strategy / Permission / Alert State: setup_state, hypothesis_id if any, validation_state, review_allowed, class_1_alert_allowed, class_2_setup_alert_allowed, directional_alert_allowed, trade_allowed, auto_trade_allowed, blocked reasons.

Dossier must not recompute ranking, Global Top 10, or permission; must not claim edge; and must not hide missing/degraded states.

## 7. Selection Desk Contract
Selection Desk is attention-selection publication.

Stable parent surfaces:
- Selection Desk/Groups/
- Selection Desk/Global/
- Selection Desk/Selection Index.txt

Selection Desk/Groups should contain ranking_group views.
Selection Desk/Global should contain Global Top 10 / global inspection basket views.

Selection Index should explain:
- cycle_id,
- generated_at,
- input source,
- selected ranking_groups,
- candidate pool size,
- correlation/diversity rule status,
- backup fill count,
- reject count,
- global_top_n,
- review_allowed state,
- trade_allowed=false unless future permission explicitly proves otherwise.

No route may be named after changing ranks or Top-N values.
Forbidden route patterns:
- Ranking Group Top 5/
- Global Top 10/
- Rank 1/
- Cycle <number>/
- (historical retired) bucket_top5/
- (historical retired) sub_bucket_top5/

## 8. Workbench / Diagnostics Contract
Workbench contains deeper runtime proof detail:
- heartbeat/timer pressure,
- scheduler backlog,
- publication health,
- route/file existence checks,
- write failure reasons,
- stale/degraded/blocked reasons,
- taxonomy cache status,
- selected evidence backlog,
- heatmap generation state,
- validation/outcome availability,
- diagnostics and recovery notes.

Workbench must not become operator cockpit, Dossier replacement, strategy brain, permission owner, or shadow scorer.

## 9. Governance / Manifest / Telemetry Contract
Governance records proof/state rows:
- manifest rows,
- runtime telemetry rows,
- owner status rows,
- layer status rows,
- score registry rows,
- formula registry rows,
- selection ledger rows,
- evidence integrity rows,
- permission/alert ledger rows,
- validation/outcome rows later,
- contradiction records when needed.

Governance must not create trading truth, approve trading, compute scores, render Board/Dossier, or replace Workbench diagnostics.

## 10. Heatmap Publication Contract
Heatmaps are descriptive visual/summary surfaces.

Planned heatmaps:
1. Global Top 10 Correlation Heatmap: overlap/correlation risk across inspection basket symbols; not a trade signal.
2. Ranking Group Strength / Quality Heatmap: ranking_group quality/heat/completion; not prediction.
3. Session Relevance Heatmap: session availability/relevance by group/symbol; must label time basis.
4. Cost vs Movement Heatmap: friction vs movement/range relationship; not edge proof.
5. Evidence Completeness Heatmap: selected evidence completeness/staleness/degradation; not setup confirmation.

Every heatmap includes:
- source_owner
- input fields
- generated_at
- freshness_state
- completeness_state
- degraded_reason
- descriptive_only=true
- trade_permission=false

## 11. Publication State Vocabulary
Common states:
- not_started
- shell_printed
- filling
- partial
- complete
- complete_with_degraded
- stale
- blocked_for_review
- failed
- unavailable

Clarification: publication_allowed may be true while review_allowed=false and trade_allowed=false.

## 12. No-Go Rules
- Board does not compute Global Top 10.
- Dossier does not recompute ranking.
- Selection Desk does not grant permission.
- Publication does not invent truth.
- Governance does not create trading truth.
- Workbench does not become a strategy brain.
- Heatmaps do not imply edge.
- File existence does not prove data correctness.
- Clean formatting does not prove readiness.
- Selected evidence does not confirm a trade.
- Global Top 10 is not a trade list.
- Permission remains false unless Permission / Alert Owner explicitly allows it after required proof.
- Auto-trading remains blocked.

## 13. Acceptance Criteria
This file is acceptable if:
- it defines every publication surface,
- it separates truth owners from renderers/services,
- it includes Board, Dossier, Selection Desk, Workbench, Governance, and Heatmap contracts,
- it includes the full 23-layer Dossier story,
- it blocks hidden compute and fake permission,
- it uses ranking_group terminology,
- it does not introduce new routes beyond stable parent concepts,
- it does not claim runtime proof.
