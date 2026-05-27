# AURORA CORE — PERMISSION AND VALIDATION BLUEPRINT

Status: ENRICHED BLUEPRINT — permission remains blocked unless evidence gates are satisfied.

## 0. Purpose
- Permission controls what Aurora may display, alert, review, or trade.
- Validation controls how claims are tested, promoted, killed, or kept in quarantine.
- Permission consumes proof; it does not create proof.
- Validation measures outcomes; it does not directly grant live trading.
- Architecture, clean files, rankings, selected evidence, and heatmaps are not edge proof.

## 1. What This Blueprint Owns
This blueprint owns:
- permission state model,
- publication/review/trade/auto-trade separation,
- alert classes,
- setup/strategy quarantine,
- validation lifecycle,
- hypothesis registry,
- experiment registry,
- outcome ledger contract,
- score validation,
- setup validation,
- edge promotion/kill rules,
- prop-firm rule profile requirements,
- risk blocks,
- news/session/holding restrictions,
- permission no-go rules.

## 2. What This Blueprint Must Not Own
This blueprint must not own:
- trade execution logic,
- MQL5 order placement code,
- broker truth computation,
- score formulas,
- ranking construction,
- Dossier rendering,
- Board rendering,
- FileIO/routes,
- live/funded approval without evidence,
- strategy fantasy.

## 3. Permission State Separation
Separate states:
- publication_allowed
- review_allowed
- class_1_alert_allowed
- class_2_setup_alert_allowed
- directional_alert_allowed
- trade_allowed
- auto_trade_allowed
- live_allowed
- prop_firm_allowed

Hard law:
- publication_allowed ≠ review_allowed
- review_allowed ≠ trade_allowed
- trade_allowed ≠ auto_trade_allowed
- validation_passed ≠ prop_firm_allowed

Default states:
- publication_allowed=true if FileIO works, even degraded
- review_allowed=false until evidence completeness and integrity allow review
- class_1_alert_allowed may be true only for system/risk/integrity alerts
- class_2_setup_alert_allowed=false
- directional_alert_allowed=false
- trade_allowed=false
- auto_trade_allowed=false
- live_allowed=false
- prop_firm_allowed=false

## 4. Alert Classes
Class 1 — System / Risk / Integrity Alerts (allowed when actionable).
Examples:
- terminal disconnected
- publication failed
- route missing
- fake-alive runtime risk
- selected evidence stuck
- prop-rule danger
- drawdown danger
- stale quote critical
- manifest failed
- file write failed

Class 2 — Setup / Strategy Alerts (blocked by default).
Examples:
- possible breakout
- possible reversal
- VWAP touch
- Bollinger Band touch
- liquidity sweep
- FVG reaction
- wick rejection
- order-flow shift

Class 3 — Execution / Auto-Trade (blocked).
Examples:
- open trade
- close trade
- modify stop
- place pending order
- scale in/out
- auto-trade action

## 5. Setup / Strategy Quarantine
Every setup idea starts in QUARANTINE.

Quarantine applies to VWAP setup, Bollinger Band setup, liquidity sweep, FVG, SMC, wick rejection, breakout/retest, order-flow proxy, DOM imbalance proxy, volatility expansion, session open pattern, and any external/guru/book/video/AI idea.

Quarantine requirements before testing:
- hypothesis_id
- exact rule definition
- instrument universe
- sessions
- timeframes
- required evidence fields
- entry condition if simulated
- invalidation condition
- stop model
- target/exit model
- cost model
- spread model
- slippage model
- null model
- sample-size requirement
- regime/session segmentation
- kill condition
- promotion condition
- owner
- status

No vague setup may reach alerting.

## 6. Validation Lifecycle
Lifecycle:
1. IDEA / QUARANTINE
2. TEST DESIGN
3. BACKTESTED
4. OUT-OF-SAMPLE / WALK-FORWARD
5. DEMO FORWARD
6. SMALL LIVE
7. MULTI-REGIME LIVE
8. PRODUCTION-OBSERVED

Promotion requires evidence.
Regression to earlier stages is allowed when performance/regime/execution/prop-rule conditions degrade.

Stage definitions:
- IDEA / QUARANTINE: concept exists only; no alerts; no permission; no optimization.
- TEST DESIGN: explicit hypothesis and falsifier exist; data requirements known; costs defined; null model defined.
- BACKTESTED: historical result exists; not live edge proof; includes spread/slippage/commission assumptions.
- OUT-OF-SAMPLE / WALK-FORWARD: unseen-data validation exists; still not live proof.
- DEMO FORWARD: demo evidence exists under observed broker/session conditions; still not funded proof.
- SMALL LIVE: small-live evidence exists; limited confidence only.
- MULTI-REGIME LIVE: live evidence across sessions/regimes; stronger but not permanent proof.
- PRODUCTION-OBSERVED: operational history exists with failure logs, drawdown boundaries, and regression records.

## 7. Evidence Rank Model
Evidence ranks:
0. Idea / claim
1. AI reasoning
2. screenshot/user report
3. source file inspection
4. compile/static validation
5. backtest
6. out-of-sample/walk-forward
7. demo forward
8. small live
9. multi-regime live
10. production-observed

Rules:
- AI reasoning proves no edge.
- Compile proves build compatibility only.
- Backtest profit does not prove live edge.
- OOS does not prove execution robustness alone.
- Demo does not prove funded readiness.
- Small live does not prove robustness.
- No claim may be upgraded above its evidence rank.

## 8. Hypothesis Registry Contract
Required fields:
- hypothesis_id
- hypothesis_name
- claim
- owner
- source_tier
- setup_or_score
- intended_use
- out_of_scope_use
- instruments
- sessions
- timeframes
- required_data
- entry_rule_if_simulated
- exit_rule_if_simulated
- invalidation_rule
- cost_model
- spread_model
- slippage_model
- null_model
- sample_size_requirement
- regime_split
- kill_condition
- promotion_condition
- status
- evidence_rank

## 9. Experiment Registry Contract
Required fields:
- experiment_id
- hypothesis_id
- experiment_type
- symbols
- sessions
- time_range
- broker/data_source
- timeframe
- spread_assumption
- slippage_assumption
- commission_assumption
- execution_assumption
- null_model
- sample_size
- in_sample_period
- out_of_sample_period
- walk_forward_method
- metrics
- kill_condition
- promotion_condition
- result_status
- reproducibility_notes

## 10. Outcome Ledger Contract
Required fields:
- outcome_id
- experiment_id
- hypothesis_id
- cycle_id
- symbol
- asset_class
- market_group
- market_segment
- ranking_group
- rank_at_time
- global_top10_flag
- selected_evidence_complete_flag
- setup_candidate_flag
- direction_if_any
- timestamp
- session
- regime_label
- entry_price_if_simulated
- stop_model
- target_model
- spread_at_event
- slippage_model
- commission_model
- mfe
- mae
- time_to_mfe
- time_to_mae
- target_hit
- stop_hit
- expired
- net_r_after_cost
- null_model_result
- pass_fail
- notes

## 11. Score Validation
Scores are descriptive until validated.

Scores requiring validation:
- cost/friction score
- session relevance score
- movement/range score
- structure/location score
- ranking_group quality score
- candidate pool score
- global inspection basket rank
- heatmap metrics

Every score defines:
- score_owner
- formula_version
- input fields
- output field
- normalization method
- missing input behavior
- stale input behavior
- sample window
- intended use
- out-of-scope use
- validation status
- evidence rank

## 12. Selected Evidence Does Not Equal Permission
Selected evidence may include OHLC, wick/candle geometry, rolling ticks, ATR, Bollinger Bands, VWAP, liquidity maps, and MT5 DOM/order-flow proxy.

Rules:
- VWAP touch is not a signal.
- Bollinger Band touch is not a signal.
- Liquidity sweep is not a signal.
- DOM proxy is not real institutional order-flow proof.
- Wick rejection is not permission.
- FVG is not permission.
- Confluence is not edge without outcome proof.

## 13. Prop-Firm Rule Profile Requirement
No live/funded/prop-firm permission without a firm-specific rule profile.

Required profile fields:
- firm_name
- account_type
- account_size
- challenge/evaluation/live status
- daily_loss_limit
- max_loss_limit
- drawdown_type: static/trailing
- loss_basis: balance/equity/open_pnl
- reset_time
- reset_timezone
- minimum_trading_days
- profit_target
- consistency_rule
- lot_limit
- exposure_limit
- max_open_positions
- news_trading_rule
- weekend_holding_rule
- overnight_holding_rule
- EA_allowed
- third_party_EA_allowed
- copy_trading_rule
- HFT_rule
- arbitrage_rule
- grid_rule
- martingale_rule
- tick_scalping_rule
- latency_rule
- VPS/IP/device_rule
- breach_behavior
- kill_switch_daily_threshold
- kill_switch_total_threshold
- manual_override_rule
- source_url_or_evidence_reference
- last_verified_date
- unknown_fields

Hard rule: unknown prop-firm rules block live/funded permission.

## 14. Risk Blocks
Permission blocks when:
- prop-rule profile missing
- daily loss danger
- max loss danger
- equity/balance basis unknown
- open P/L rule unknown
- news rule conflict
- weekend/overnight rule conflict
- stale quote
- missing broker specs
- missing calculation mode
- margin calculation unavailable
- spread/slippage abnormal
- selected evidence incomplete
- validation missing
- strategy in quarantine
- signal unvalidated
- runtime publication failing
- file manifest failing
- operator manual block active

## 15. Permission Matrix
Permission matrix rows:
- Scaffold exists
- Source compiles
- Runtime files print
- Foundation truth complete
- Ranking complete
- Global Top 10 complete
- Selected evidence complete
- Hypothesis designed
- Backtest passed
- OOS passed
- Demo forward passed
- Small live passed
- Prop rules verified
- Kill switch tested

Columns:
- publication_allowed
- review_allowed
- class_1_alert_allowed
- class_2_setup_alert_allowed
- directional_alert_allowed
- trade_allowed
- auto_trade_allowed
- prop_firm_allowed

Matrix law: trade/auto/prop remain blocked until evidence level is sufficiently high and risk/prop constraints pass.

## 16. Validation / Permission Boundary
Validation may recommend promotion.
Permission decides allowed state.
Prop-firm profile may block even if validation passes.
Operator/manual block may block.
Runtime/data integrity may block.

## 17. No-Go Rules
- No setup alerts from unvalidated scores.
- No directional alerts from ranking.
- No trade permission from Global Top 10.
- No trade permission from selected evidence.
- No trade permission from heatmaps.
- No live/funded permission without prop-rule profile.
- No auto-trading.
- No optimization before falsification.
- No edge claim from architecture.
- No edge claim from clean docs.
- No edge claim from screenshots.
- No edge claim from one profitable backtest.
- No permission bypass by renaming “signal” to “attention.”
- No permission bypass by saying “operator decides.”
- No prop-firm readiness from demo only.
- No hidden execution logic in permission docs.

## 18. Acceptance Criteria
This file is acceptable if:
- it separates publication/review/alert/trade/auto/live/prop states,
- it defines alert classes,
- it defines setup quarantine,
- it defines validation lifecycle,
- it defines evidence ranks,
- it defines hypothesis/experiment/outcome contracts,
- it defines prop-firm rule profile requirements,
- it defines risk blocks,
- it defines permission matrix,
- it blocks fake edge and fake readiness,
- it uses ranking_group terminology,
- it does not claim runtime proof or trading permission.
