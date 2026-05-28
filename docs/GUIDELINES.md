# Docs Guidelines

## Prime directive

Docs must guide source work without pretending to be runtime proof.

## Allowed

Docs may contain:

```text
blueprints
architecture laws
layer contracts
owner maps
build-phase plans
research summaries
validation methods
```

## Forbidden

Docs must not:

```text
claim implementation exists without source proof
claim compile/runtime/live proof without evidence
contradict README.md / AGENTS.md / OVERVIEW_INDEX.md
create competing layer maps without marking status
hide outdated Aurora/Core doctrine as active VA law
```

## Index rule

Every new doc must be listed in `docs/INDEX.md` in the same patch.

## Status labels

Every detailed doc should clearly mark its status:

```text
DRAFT
LOCKED
CANDIDATE
REPLACED_BY
DEPRECATED
```

## Size rule

Prefer short focused docs. If a doc grows beyond safe reading size, split it and update the index.
