# AURORA CORE — ALERTS, PERMISSION & SAFETY GUIDEBOOK

**System:** AURORA CORE  
**Role:** Alert classes, permission gates, review/trade separation, prop/risk/news safety, suppression rules, and anti-noise / anti-danger authority.  
**Status:** Overview guidebook foundation. Exact thresholds and prop profiles may be refined later.

---

## 0. Purpose

This guidebook defines what AURORA CORE is allowed to warn about, display, suppress, block, or permit.

It answers:

```text
What alert class is allowed?
What must never alert?
What blocks review?
What blocks trading?
What requires validation first?
What is suppressed and why?
What cooldown is active?
What prop/risk/news state applies?
```

Core law:

```text
Alerts are not signals.
Permission must be explicit.
Auto-trading is blocked.
```

The enemy:

```text
Aurora becomes noisy, dangerous, or permission-lax.
```

---

## 1. What This Guidebook Owns

This guidebook owns:

```text
Class 1 system alerts
Class 2 future setup alerts
Class 3 execution/auto-trade block
alert cooldowns
alert suppression reasons
permission state
review_allowed
trade_allowed
directional_alert_allowed
auto_trade_allowed
prop rule status
news risk state
manual confirmation later
alert ledger contract
permission block reasons
safety escalation rules
```

---

## 2. What This Guidebook Must Not Own

This guidebook must not own:

```text
raw evidence computation
score formulas
selection construction
outcome validation generation
publication routes
trade execution logic
```

Permission consumes proof.

Permission does not create proof.

---

## 3. Research Foundation

Google SRE monitoring guidance emphasizes that alerting should be simple, comprehensible, and actionable.

Reference:

```text
https://sre.google/sre-book/monitoring-distributed-systems/
```

Aurora translation:

```text
Board may display many states.
Push alerts must be rare and actionable.
```

MQL5 `SendNotification()` has strict operational limits. The official docs state that messages are limited to 255 characters, the function is limited to no more than 2 calls per second and 10 calls per minute, it can be disabled for violations, and it does not work in Strategy Tester.

Reference:

```text
https://www.mql5.com/en/docs/network/sendnotification
```

Aurora translation:

```text
Alert spam is not only bad UX; it can break the notification channel.
```

MQL5 account and margin functions matter for safety. `AccountInfoDouble()` exposes account properties such as balance, equity, margin, and free margin. `OrderCalcMargin()` calculates required margin for a planned trade operation in current market conditions and account currency, but it does not account for current open positions and pending orders.

References:

```text
https://www.mql5.com/en/docs/account/accountinfodouble
https://www.mql5.com/en/docs/trading/ordercalcmargin
```

Aurora translation:

```text
Permission must distinguish current account exposure from planned-order margin checks.
```

---

## 4. Core Permission Law

```text
Selection is not permission.
Alert is not signal.
Review is not trade approval.
Trade approval is not auto-trade approval.
```

Default permission state:

```text
class_1_alert_allowed = true
class_2_setup_alert_allowed = false
directional_alert_allowed = false
auto_trade_allowed = false
live_allowed = false
trade_allowed = false
```

---

## 5. Publication vs Review vs Trade vs Auto-Trade

These are separate states:

```text
publication_allowed ≠ review_allowed
review_allowed ≠ trade_allowed
trade_allowed ≠ auto_trade_allowed
```

Example:

```text
publication_allowed = true
review_allowed = false
trade_allowed = false
reason = evidence_partial
```

Publication may print broken truth.

Review/trading may remain blocked.

---

## 6. Alert Classes

### Class 1 — System / Risk / Integrity Alerts

Allowed now.

Examples:

```text
terminal disconnected
publication failed
manifest failed
route missing
prop rule danger
account risk danger
worker offline if worker outputs required
fake-alive risk
oldest starved task critical
selected evidence stuck
```

### Class 2 — Setup / Strategy Alerts

Blocked by default.

Future only after validation.

Examples that remain blocked:

```text
possible breakout
possible reversal
VWAP touch
liquidity sweep
Bollinger touch
ATR expansion
FVG reaction
```

### Class 3 — Execution / Auto-Trade

Blocked.

```text
auto_trade_allowed = false
live_allowed = false
```

---

## 7. Class 1 System / Risk / Integrity Alerts

Class 1 alerts must be actionable.

Allowed if:

```text
system health is threatened
publication is physically failing
risk/prop state is dangerous
fake-alive runtime is detected
critical dependency is stale/failed
```

Class 1 alerts must not be used for normal progress updates.

---

## 8. Class 2 Setup Alerts — Quarantine

Class 2 setup alerts are future-only.

Required before future enablement:

```text
hypothesis defined
formula defined
evidence complete
cost model defined
null model defined
outcome validation reviewed
prop/risk/news safety defined
permission owner approval
alert cooldown defined
alert ledger fields defined
```

Until then:

```text
class_2_setup_alert_allowed = false
```

---

## 9. Class 3 Execution / Auto-Trade — Blocked

Auto-trading is blocked.

Execution permission cannot be inferred from:

```text
rank
Global Top 10
indicator state
liquidity context
DOM proxy
backtest only
external worker output
```

Default:

```text
auto_trade_allowed = false
live_allowed = false
```

---

## 10. Permission State Contract

Required fields:

```text
review_allowed
trade_allowed
directional_alert_allowed
auto_trade_allowed
live_allowed
class_1_alert_allowed
class_2_setup_alert_allowed
permission_status
permission_block_reasons
permission_source_owner
permission_freshness_state
```

Permission states:

```text
allowed
blocked
degraded
unknown
quarantined
```

---

## 11. Review Permission Contract

Review permission asks:

```text
Can a human inspect this state as usable enough for analysis?
```

Review may be blocked by:

```text
missing foundation truth
stale quote
partial evidence
classification_unknown
worker_output_stale if required
permission_dependency_unknown
```

Review permission is not trade permission.

---

## 12. Trade Permission Contract

Trade permission remains false by default.

Trade permission requires, at minimum:

```text
validated setup or strategy later
prop rule profile known
risk state known
news state known where relevant
account exposure known
cost/spread/slippage model known
Permission Owner approval
```

If any required safety state is unknown:

```text
trade_allowed = false
```

---

## 13. Directional Alert Permission Contract

Directional alerts remain blocked until validation.

Blocked examples:

```text
buy setup
sell setup
breakout alert
reversal alert
liquidity sweep alert
```

Allowed now:

```text
system/risk/integrity alerts only
```

---

## 14. Prop-Firm Safety Profile

Prop rules must be profile-driven, not assumed from memory.

Fields:

```text
firm_name
account_phase
daily_loss_basis
max_loss_basis
equity_vs_balance_rule
trailing_drawdown_rule
news_rule
max_lot_rule
max_position_rule
consistency_rule
overnight_weekend_rule
rule_last_verified_at
profile_status
```

If prop profile is unknown:

```text
prop_rule_status = unknown
trade_allowed = false
```

---

## 15. News Risk State

MQL5 has economic calendar functions such as `CalendarValueHistory()`, but news/calendar availability and broker/prop relevance need validation.

Reference:

```text
https://www.mql5.com/en/docs/calendar/calendarvaluehistory
```

Aurora law:

```text
Economic calendar data may inform risk state.
It must not be treated as complete broker/prop news compliance without verification.
```

News states:

```text
clear
caution
restricted
unknown
unavailable
```

If news is unknown and trading permission is involved:

```text
trade_allowed = false
```

---

## 16. Account / Margin / Exposure Safety Checks

Safety checks should distinguish:

```text
current account state
current open exposure
pending order exposure
planned-order margin estimate
symbol-specific margin requirement
portfolio/bucket concentration
```

`OrderCalcMargin()` may help estimate required margin for a planned trade, but it does not include current open positions and pending orders.

Therefore:

```text
margin_estimate ≠ full account safety state
```

---

## 17. Alert Cooldowns and Suppression

Alert suppression fields:

```text
alert_id
alert_class
suppressed_flag
suppression_reason
cooldown_until
last_sent_at
send_count_1m
send_count_1h
terminal_notification_enabled
```

Suppression reasons:

```text
cooldown_active
duplicate_alert
non_actionable
class_blocked
permission_blocked
notification_limit_risk
tester_mode_unavailable
```

Suppression must be logged.

---

## 18. SendNotification Limits and Tester Restrictions

MQL5 `SendNotification()` constraints:

```text
maximum message length = 255 characters
maximum 2 calls per second
maximum 10 calls per minute
can be disabled for restriction violations
does not work in Strategy Tester
```

Aurora rules:

```text
Do not alert every progress event.
Do not alert data-complete events.
Do not alert normal heartbeat.
Throttle and suppress duplicates.
```

---

## 19. Alert Ledger Contract

Alert Ledger fields:

```text
alert_id
cycle_id
alert_class
alert_type
owner
symbol_if_any
fired_flag
suppressed_flag
suppression_reason
cooldown_state
permission_state
created_at
```

Alert Ledger proves what was fired or suppressed.

---

## 20. Safety Failure States

Safety failure states:

```text
risk_state_unknown
prop_rule_unknown
news_state_unknown
permission_dependency_missing
alert_suppressed
cooldown_active
review_blocked
trade_blocked
auto_trade_blocked
```

Unknown safety state should default to blocked, not allowed.

---

## 21. No-Go Patterns

Do not allow:

```text
push alert for every progress event
data-complete alerts become spam
setup alert fires without validation
permission state hidden inside score
prop rules assumed from memory
news state unknown but trade allowed
SendNotification limit violated
Board warning confused with push alert
auto-trade creeps in through “just alerts”
external worker output creates permission
```

---

## 22. Acceptance Criteria

This guidebook is acceptable if permission stays explicit and alerts stay useful.

Acceptance criteria:

```text
Class 1 alerts allowed only for system/risk/integrity.
Class 2 setup alerts blocked until validation.
Auto-trading blocked.
Review/trade/publication permissions separated.
Prop rule unknown blocks trade permission.
News unknown blocks trade permission where relevant.
SendNotification limits respected.
Suppression reasons are logged.
Board warning does not equal push alert.
No permission state hidden in scores or selection.
```

---

## 23. Final Permission Law

```text
Aurora may warn about danger.
It may not manufacture permission from excitement.
```

## Restoration Addendum — Alert/Permission Alignment
- Class 1 system alerts allowed now, but must be rare, actionable, state-change based, and cooldown controlled.
- Class 2 setup alerts remain blocked until validation criteria are met.
- No per-symbol progress alerts and no data-complete spam alerts.
- `SendNotification` rate/size limitations remain mandatory constraints where push alerts are used.
- Future Class 2 requires L18-L22 complete, strategy validation complete, and Layer 1 prop/risk/news pass.
- Defaults remain strict: `class_2_setup_alert_allowed=false`, `directional_alert_allowed=false`, `auto_trade_allowed=false`, `live_allowed=false`, `trade_allowed=false`.
