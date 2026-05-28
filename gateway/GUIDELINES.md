# Gateway Guidelines

## Prime directive

Gateway does the heavy work. MT5 stays light.

Gateway reads declared MT5 input packets, performs declared analysis chains, writes compact output packets, and never becomes a hidden broker-truth or execution authority.

## Allowed

Gateway may:

```text
read declared input packets
cache heavy intermediate state
calculate friction/session/movement/structure/taxonomy/ranking/selection/deep evidence
build Trader Chat Packs
maintain Validation Ledger state
write Gateway output packets
```

## Forbidden

Gateway must not:

```text
own broker/account/quote truth
own MT5 routes or FileIO
write MT5 Board/Dossier/Slate directly
grant auto execution authority
hide fallback data sources
silently accept stale or mismatched input
create broad shared helper dumping grounds
```

## Chain rule

Each Gateway layer must declare:

```text
reads
writes
cache key
dirty trigger
status values
maximum work expectation
failure/degraded behavior
```

Join layers may read multiple upstream packets only when declared in that layer index.

## Packet rule

Every Gateway output packet must include:

```text
schema_version
layer_name
layer_version
input_hash
input_sequence
server/account scope where applicable
generated_time
status
confidence or evidence_quality where applicable
degraded_reason when applicable
```

## Permission rule

Gateway outputs are evidence, ranking, or review support. Gateway output is not auto-trading permission.

## File-size law

```text
source file target: 150-350 lines
source file hard review point: 500 lines
function target: 10-40 lines
function hard review point: 80 lines
```

Split by layer/engine responsibility before growth continues.
