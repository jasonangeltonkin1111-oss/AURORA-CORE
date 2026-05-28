# Reports Guidelines

## Prime directive

Reports must record evidence honestly. They do not create proof by sounding confident.

## Required report sections

Serious reports should include:

```text
repo/branch
files inspected
files changed
owner affected
evidence used
verification done
verification missing
risks
rollback path
proof level
decision gate
```

## Forbidden

Reports must not:

```text
claim compile proof without compile output
claim runtime proof without runtime output
claim live readiness without live proof
claim edge proof without validation
hide proof gaps
replace source inspection with memory
```

## Index rule

Every report must be listed in `reports/INDEX.md`.
