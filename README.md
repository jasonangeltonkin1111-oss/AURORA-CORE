# AURORA CORE

**Native MT5 Market Intelligence, Runtime Ownership, and Truth Publication System**

AURORA CORE is a native MetaTrader 5 / MQL5 trading-system foundation built to observe broker truth, classify the market universe, rank symbols intelligently, route expensive evidence only where it matters, and publish operator truth without fake confidence.

It is not a finished trading edge.

It is not an auto-trading permission system.

It is not a signal seller.

AURORA CORE is the core runtime spine for building a disciplined market-intelligence engine that can later support validated strategy research, alerts, and execution modules only after evidence proves they deserve permission.

---

## Core Mission

AURORA CORE exists to answer:

```text
What does the broker/account/market actually say?
Which symbols are usable right now?
Which symbols deserve attention?
Which ranking groups are strongest?
Which candidates form a diversified inspection basket?
Which selected symbols deserve deep evidence?
What is complete, degraded, stale, blocked, or still filling?
What is allowed, and what is not allowed?
```

---

## Current Selection Desk Contract

The current professional folder contract is:

```text
Aurora Core/<server>/<account>/Selection Desk/Ranking Group Top 5/
Aurora Core/<server>/<account>/Selection Desk/Global Top 10/
```

The Dossiers contract remains separate and must not be renamed by Selection Desk work:

```text
Aurora Core/<server>/<account>/Dossiers/
Aurora Core/<server>/<account>/Dossiers/Open/
Aurora Core/<server>/<account>/Dossiers/Closed/
Aurora Core/<server>/<account>/Dossiers/Unknown/
```

Current Selection Desk files are structure placeholders only until a later ranking owner exists. Placeholder publication must not imply ranked symbols, selected candidates, trade permission, edge, or prop-firm readiness.

---

## Taxonomy Naming Contract

Use the professional hierarchy:

```text
asset_class -> market_group -> market_segment -> symbol
ranking_group = EA selection/cap/diversification bucket
```

Retired active names:

```text
major_bucket
minor_bucket
aggregation_group
bucket_top5
sub_bucket_top5
```

These old names may appear only as historical references. They must not be used as active source fields, route names, or operator-facing publication labels.

---

## Runtime Ownership Rules

- Runtime 7 Publication Owner owns folder routes and FileIO boundaries.
- Do not create duplicate route owners or shadow writers.
- Do not block physical publication just because truth is partial, stale, degraded, or review-unsafe.
- Broken truth may block review, ranking, selection, trading, and permission; it must not hide expected files.
- Every placeholder must be honest: structure-only means no runtime truth yet.

---

## Proof Discipline

Compile success proves build compatibility only.

Runtime file output proves only observed publication behavior under the observed terminal/account/server conditions.

Selection is attention, not permission.

No live trading, prop-firm readiness, strategy edge, or execution approval exists in this repository until evidence specifically proves it.
