# AURORA CORE — RANKING LOCK AND SELECTED MICRO-UPDATE GUIDEBOOK

**System:** AURORA CORE  
**Role:** ranking-cycle lock doctrine, Top 10 / Top 5 per ranking_group publication rules, selected-symbol micro-update boundary, Board/Dossier/Workbench split.  
**Status:** Future implementation guidebook. No ranking runtime exists yet.

---

## 0. Purpose

This guidebook prevents Aurora from becoming a noisy live-reranking machine.

Ranking lists must be stable products of a completed ranking cycle.

Layer 3 / MarketWatch micro-updates must keep selected symbols fresh without mutating Top lists mid-lock.

Core law:

```text
Top lists are cycle-locked products, not live streams.
MarketWatch micro-updates are live streams, but only for selected/risk symbols after selection lock.
Board shows compact snapshot status.
Dossiers show per-symbol detail.
Workbench shows debug and failed packets.
```

---

## 1. Ranking Lock Law

When ranking layers eventually exist, Top lists may publish only after the required ranking layers reach 100% completion and pass verification.

Required sequence:

```text
ranking_cycle_start
all required ranking layers compute
ranking_completion_pct=100
verification_passed=true
Top 10 built
Top 5 per ranking_group built
selection snapshot published
ranking_status=locked
ranking_lock_minutes=20
rerank_allowed=false
```

During the 20-minute lock:

```text
Top 10 membership is static.
Top 10 order is static.
Top 5 per ranking_group membership is static.
Top 5 per ranking_group order is static.
No tick, spread, quote, micro-update, or minor score movement may reshuffle the published lists.
```

After 20 minutes:

```text
ranking_status=lock_expired
rerank_allowed=true
ranking runtime restarts from the beginning
new ranking_cycle_id is required
```

---

## 2. Publication Fields

Every locked Top list must include:

```text
ranking_cycle_id
ranking_status
ranking_complete
ranking_completion_pct
verification_passed
locked_at
lock_expires_at
lock_minutes
lock_remaining_seconds
rerank_allowed
selected_symbol_count
global_top10_count
top5_ranking_group_count
source_layers_complete
trade_permission=false
```

Allowed states:

```text
idle
building
complete_verifying
locked
lock_expired
rebuilding
degraded_locked
failed
```

No list may label itself true/fresh if the ranking cycle is incomplete.

---

## 3. Top 10 / Top 5 Meaning Law

Global Top 10 means:

```text
diversified inspection basket
```

Top 5 per ranking_group means:

```text
best currently ranked alternatives inside that ranking_group for inspection visibility
```

Forbidden meanings:

```text
best trades
trade signals
permission list
probability-marketing list
prop-firm ready basket
auto-trade candidates
```

Selection is attention.

Selection is not permission.

---

## 4. No Live Rerank During Lock

Layer 3 / MarketWatch may detect:

```text
quote stale
spread widened
tick age too high
selected symbol degraded
selected quote unavailable
```

Layer 3 / MarketWatch may not:

```text
replace a Top 10 symbol
insert a new Top 5 symbol
change rank order
rerun scoring
silently mutate selection membership
```

If a selected symbol degrades during the lock, mark the locked list degraded.

Do not secretly replace it unless a future emergency invalidation owner is explicitly built and audited.

Default behavior:

```text
bad selected symbol -> degraded_locked / review_blocked
not -> silent replacement
```

---

## 5. Selected Micro-Update Set

After the ranking snapshot locks, Layer 3 / MarketWatch micro-updates only this unique set:

```text
selected_micro_set = unique(
  Global Top 10
  + Top 5 per ranking_group
  + open position symbols
  + pending order symbols
  + manual pinned risk/watch symbols later
)
```

Open/pending exposure symbols remain in the micro-update set even if they are not part of the locked Top lists.

Reason:

```text
risk symbols require fresh quote truth even when not selected for inspection.
```

---

## 6. Layer 3 / MarketWatch Micro-Update Boundary

Layer 3 owns quote packet truth only.

Allowed selected-symbol fields:

```text
bid
ask
last
spread_points
spread_pips
spread_pct
tick_time
tick_age_seconds
quote_valid_flag
quote_freshness_state
selected_micro_update_status
worst_selected_tick_age
```

Official MT5 source:

```text
SymbolInfoTick(symbol, tick)
```

Official behavior summary:

```text
SymbolInfoTick returns current prices and last price update time for a specified symbol in MqlTick.
```

No-go:

```text
SymbolInfoTick does not prove ranking.
SymbolInfoTick does not prove edge.
SymbolInfoTick does not authorize replacement.
SymbolInfoTick does not make a trade signal.
```

---

## 7. Board Display Rule

Board shows compact ranking lock and selected micro-update status.

Board may show:

```text
ranking_status
ranking_cycle_id
lock_remaining
Global Top 10 ready true/false
Top 5 group lists ready true/false
selected_micro_symbols_count
selected_micro_update_status
worst_selected_tick_age
rerank_allowed
main_blocker
trade_permission=false
```

Board must not show:

```text
full per-symbol quote table
full correlation matrix
full ranking ledger
full failed packet list
all group alternatives
```

Full details go to Dossiers, Selection Desk, or Workbench.

---

## 8. Selection Desk Publication Rule

Selection Desk parent folders stay stable:

```text
Selection Desk/Groups/
Selection Desk/Global/
Selection Desk/Selection Index.txt
```

Do not create parent folders named after Top-N ranks or cycle IDs.

Child files/rows may carry:

```text
ranking_cycle_id
rank
symbol
ranking_group
locked_at
lock_expires_at
status
reason
```

Top list files should write only when:

```text
new cycle locks
lock state changes meaningfully
list degrades
lock expires
```

Do not rewrite Top list files for every tick.

---

## 9. Dossier Update Rule

Dossiers are per-symbol truth bodies.

During ranking lock:

```text
Dossier ranking/selection section remains static except lock-status/degradation fields.
Dossier MarketWatch section may update for selected_micro_set symbols only.
Dossier sections should be rendered from owner packets and written only when section/file content changes.
```

No all-symbol micro-update storm.

No all-symbol deep evidence update.

---

## 10. Workbench / Addendum Rule

Workbench may carry:

```text
ranking cycle timing
completion checklist
verification failures
selected micro-update packet failures
stale selected symbols
failed SymbolInfoTick calls
cycle lock/degrade reasons
```

Failed packets are logged as addendum/proof rows, not as Board clutter.

---

## 11. Timer / Performance Law

High-resolution timers are allowed only when the OnTimer handler stays bounded.

Official MQL5 timer behavior:

```text
EventSetMillisecondTimer creates timer events more frequently than once per second.
If a Timer event is already queued or processing, a new Timer event is not added.
```

Aurora consequence:

```text
near-instant Board refresh must be light.
Top list locks must prevent rerank churn.
selected micro updates must be scoped to selected/risk symbols.
heavy ranking cycles must not run every timer tick.
```

---

## 12. Acceptance Criteria

This guidebook is satisfied only if future ranking code obeys:

```text
Top 10 and Top 5 per ranking_group publish only after 100% ranking completion and verification.
Published Top lists lock for 20 minutes.
No reranking occurs during the lock.
Layer 3 selected micro-updates run only for selected/risk symbols after lock.
Selected quote degradation marks status; it does not silently replace symbols.
Board shows compact lock/micro status only.
Dossiers carry per-symbol detail.
Workbench carries failures and timing.
All publication uses write-if-changed behavior where feasible.
```

---

## 13. Final Law

```text
Rank slowly and truthfully.
Lock the result.
Update selected truth quickly.
Never let micro-ticks rewrite the selection story.
```
