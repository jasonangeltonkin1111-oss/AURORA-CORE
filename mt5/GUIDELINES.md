# MT5 Guidelines

## Prime directive

Keep MT5 lightweight. MT5 is the live broker-truth conveyor, not the heavy analysis brain.

## Allowed

MT5 may:

```text
collect broker/account/symbol/spec/quote/OHLC/tick raw truth
publish compact packets
maintain Atlas Bench and Atlas Surfaces
handoff compact inputs to Gateway
validate Gateway outputs
keep Vault fail-closed state
```

## Forbidden

MT5 must not:

```text
own Gateway analysis calculations
create duplicate FileIO/path/timer owners
read back every file on the hot path
rewrite unchanged packet/surface files
scan folders every pulse
build shadow route systems
call Gateway outputs permission
place auto trades without explicit future execution authority
```

## Source size law

```text
source file target: 150-350 lines
source file hard review point: 500 lines
function target: 10-40 lines
function hard review point: 80 lines
```

Split files by owner/responsibility before growth continues.

## Layer source rule

Each layer folder should start with 3-5 source files maximum:

```text
Types / schema
Collect or process owner
Packet builder
Diagnostics, only if needed
```

Do not create generic `Utils`, `Helpers`, `CommonLogic`, `V2`, `Final`, or `Backup` files.

## FileIO rule

All FileIO must go through the single FileIO owner. No direct `FileOpen`, `FileWrite`, `FileFlush`, or `FileMove` outside that owner once implementation exists.

## Surface rule

Board, Dossier, Slate, Bench, Ledger, and Vault render accepted packet summaries. They do not recalculate owner truth.

## Proof rule

Do not claim compile/runtime/live readiness unless actual compile/runtime evidence exists.
