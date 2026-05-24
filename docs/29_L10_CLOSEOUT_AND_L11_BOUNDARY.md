# Layer 10 Closeout and Layer 11 Boundary

This note records the runtime boundary for Layer 10 taxonomy closeout.

## Layer 10 (Runtime 5) scope

- Layer 10 may publish taxonomy/ranking-group truth and review artifacts:
  - `taxonomy_symbols.csv`
  - `ranking_groups.csv`
  - `symbol_path_index.csv` / `.txt`
  - `taxonomy_summary.txt`
  - `SymbolTaxonomy/<symbol>.txt`
  - `Groups/<ranking_group_slug>.summary.txt`
  - `Groups/<ranking_group_slug>.members.csv`
- Layer 10 group member CSVs are **review lists of all members in a ranking group**.
- Layer 10 must **not** publish Top 5 copied Dossiers or Global Top 10 copied Dossiers.

## Downstream ownership

- Layer 11 owns **Top 5 per ranking_group** after ranking/selection logic is applied.
- Layer 16 owns **Global Top 10** outputs.

## Copied Dossier law

- Selection Desk copied files must remain **byte-identical** copies of source Dossiers.
- Rank/selection explanation belongs in manifests, index files, board/workbench summaries, and routing metadata — not inside copied Dossier content.
