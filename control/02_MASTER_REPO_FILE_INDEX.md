# 02 MASTER REPO FILE INDEX

## Purpose
Complete navigation index for important repository files, ownership boundaries, and current status.

## Owns / Does Not Own
**Owns:** repository navigation, must-read pointers, folder-by-folder file map, authority labels.

**Does not own:** runtime implementation truth, strategy/trading permission, compile/runtime proof claims.

## Mandatory startup path for new chats
1. `README.md`
2. `control/01_CONTROL_GOVERNANCE.md`
3. Relevant top-level folder index

## Source authority levels used here
- **L1:** Active MT5 source files and active external-worker source files (implementation truth)
- **L2:** Runtime/generated evidence samples (when explicitly present)
- **L3:** README + `control/01_CONTROL_GOVERNANCE.md`
- **L4:** Control router/index files
- **L5:** Docs guidebooks
- **L6:** Blueprint contracts
- **L7:** Governance schemas/registries/examples
- **L8:** Research and prompts
- **L9:** Historical/archive context

---

## Root
| path | role | status | must-read? | source authority level | notes |
|---|---|---|---|---|---|
| `README.md` | Repo front door and direction | Active | yes | L3 | Must be read before guidebook memory. |
| `.gitignore` | Repository ignore policy baseline | Active | no | L4 | Repo hygiene only; not runtime authority. |

## control
| path | role | status | must-read? | source authority level | notes |
|---|---|---|---|---|---|
| `control/00_CONTROL_INDEX.md` | Control navigation index | Active | yes | L4 | Active control file router. |
| `control/01_CONTROL_GOVERNANCE.md` | Active control governance law | Active | yes | L4 | Source-truth order, run gates, naming locks. |
| `control/02_MASTER_REPO_FILE_INDEX.md` | Master navigation index | Active | yes | L4 | This file. |

## docs
| path | role | status | must-read? | source authority level | notes |
|---|---|---|---|---|---|
| `docs/00_AURORA_CORE_MAIN_PAGE_GUIDEBOOK.md` | Guidebook front door | Active | yes | L5 | Doctrine, not source implementation authority. |
| `docs/01_AURORA_CORE_HANDOFF_CONTINUITY_GUIDEBOOK.md` | Continuity/handoff | Active | yes | L5 | Startup continuity for new chats. |
| `docs/09_BUCKET_UNIVERSE_TAXONOMY_GUIDEBOOK.md` | Taxonomy naming contract (contains historical bucket terminology) | Active | yes | L5 | Active scaffold naming lock uses `ranking_group` in control files. |
| `docs/10_SELECTION_BASKET_CONSTRUCTION_GUIDEBOOK.md` | Selection Desk parent-route contract doctrine | Active | yes | L5 | Stable parent routes contract. |
| `docs/15_ANTI_DRIFT_SOURCE_OF_TRUTH_GUIDEBOOK.md` | Source-of-truth anti-drift doctrine | Active | yes | L5 | Authority/boundary doctrine. |
| `docs/02_TIMING_HEARTBEAT_BREATHING_SPINE_GUIDEBOOK.md` .. `docs/14_MT5_FUNCTION_GUIDEBOOK.md` | Runtime doctrines by domain | Active | no | L5 | Task-specific doctrine set. |
| `docs/20_SYMBOL_UNIVERSE_IMPORT_CONTRACT.md` .. `docs/25_SHARED_OHLC_RAW_STORAGE_OWNER.md` | Quality/import/OHLC contracts | Active | no | L5 | Contract and process addenda. |
| `docs/26_L10_TAXONOMY_CLASSIFICATION_CONTROL.md` | L10 active taxonomy / ranking_group map control | Active | task-specific | L5 | Current L10 control contract. |
| `docs/30_L12_RANKING_GROUP_HEAT_QUALITY_CONTROL.md` | L12 ranking_group heat / quality control | Active | task-specific | L5 | Current L12 control contract. |
| `docs/32_L13_DYNAMIC_RANKING_GROUP_SELECTION_CONTROL.md` | L13 dynamic ranking_group selection control | Active | task-specific | L5 | Current L13 control contract. |
| `docs/33_L14_RANKING_GROUP_LEADER_CANDIDATE_POOL_CONTROL.md` | L14 raw candidate pool control | Active | task-specific | L5 | Current L14 control contract. |
| `docs/34_L15_CORRELATION_DIVERSITY_SELECTION_CONTROL.md` | L15 correlation / diversity scoring control | Active | task-specific | L5 | Current L15 control contract. |
| `docs/35_L16_GLOBAL_TOP10_BUILDER_CONTROL.md` | L16 Global Top 10 inspection basket control | Active | task-specific | L5 | Current L16 control contract; held visible basket + fallback labels; no trade permission. |
| `docs/36_L17_DEEP_EVIDENCE_SELECTION_SPLIT_CONTROL.md` | L17 Deep Evidence Selection Split control | Active | task-specific | L5 | Current L17 control contract; consumes L16 held visible display rows only; no evidence collection/trade permission. |
| `docs/27_RUNTIME_5_TO_7_FUTURE_LAYER_PLAYBOOK.md` .. `docs/33_L13_CLOSEOUT_AND_L14_HANDOFF.md` | Runtime/layer implementation notes and handoffs | Active | task-specific | L5 | Check exact file before using as active source; current source/config still outranks docs. |

## blueprint
| path | role | status | must-read? | source authority level | notes |
|---|---|---|---|---|---|
| `blueprint/00_BLUEPRINT_INDEX.md` | Blueprint navigation front door | Active | yes | L6 | Structural contracts router. |
| `blueprint/01_SYSTEM_IDENTITY_AND_MISSION.md` | Identity/mission blueprint | Active | no | L6 | Structure, not runtime proof. |
| `blueprint/02_RUNTIME_OWNER_BLUEPRINT.md` | Runtime owner + system service boundaries | Active | no | L6 | Architecture map. |
| `blueprint/03_LOGICAL_LAYER_BLUEPRINT.md` | Active 23-layer trading/system layer map | Active | no | L6 | Layer structure contract. |
| `blueprint/04_BUILD_PHASE_BLUEPRINT.md` | Build phase contract | Active | no | L6 | Phase/evidence gates. |
| `blueprint/05_PUBLICATION_SURFACE_BLUEPRINT.md` | Publication surface blueprint | Active | no | L6 | Enriched publication surface contract. |
| `blueprint/06_PERMISSION_AND_VALIDATION_BLUEPRINT.md` | Permission/validation structure | Active | no | L6 | Enriched permission and validation contract. |
| `blueprint/07_FILEIO_ROUTE_OWNERSHIP_CONTRACT.md` | Route and FileIO ownership | Active | no | L6 | Runtime 7 ownership contract. |
| `blueprint/08_MT5_SOURCE_FOLDER_CONTRACT.md` | MT5 source placement contract | Active | no | L6 | Source folder structure. |

## governance
| path | role | status | must-read? | source authority level | notes |
|---|---|---|---|---|---|
| `governance/00_GOVERNANCE_INDEX.md` | Governance index | Active | no | L7 | Governance navigation spine. |
| `governance/registries/00_REGISTRY_INDEX.md` | Registry index | Active | no | L7 | Registry navigation. |
| `governance/examples/00_EXAMPLES_INDEX.md` | Example index | Active | no | L7 | Sample schemas/rows. |

## governance/schemas
| path | role | status | must-read? | source authority level | notes |
|---|---|---|---|---|---|
| `governance/schemas/00_SCHEMA_INDEX.md` | Schema index | Active | no | L7 | Schema navigation. |
| `governance/schemas/01_MINIMUM_GOVERNANCE_SCHEMA_CONTRACTS.md` | Minimum schema contracts | Active | no | L7 | Contract-level constraints. |

## research
| path | role | status | must-read? | source authority level | notes |
|---|---|---|---|---|---|
| `research/00_RESEARCH_INDEX.md` | Research index | Active | no | L8 | Research routing. |
| `research/mt5_official_docs/00_MT5_OFFICIAL_DOCS_INDEX.md` | MT5 official docs anchors | Active | no | L8 | Primary-source links. |
| `research/validation_methods/00_VALIDATION_METHODS_INDEX.md` | Validation methods index | Active | no | L8 | Validation references. |
| `research/external_worker/00_EXTERNAL_WORKER_RESEARCH_INDEX.md` | External worker research index | Active | no | L8 | Design-stage only. |
| `research/order_flow_limits/00_ORDER_FLOW_LIMITS_INDEX.md` | Order-flow limits research index | Active | no | L8 | Cautionary research references. |
| `research/prop_firm_rules/00_PROP_FIRM_RULES_INDEX.md` | Prop-rule research index | Active | no | L8 | Research only, no permission grant. |

## prompts
| path | role | status | must-read? | source authority level | notes |
|---|---|---|---|---|---|
| `prompts/00_PROMPTS_INDEX.md` | Prompt system index | Active | no | L8 | Prompt navigation. |
| `prompts/universal/00_UNIVERSAL_PROMPTS_INDEX.md` | Universal prompt index | Active | no | L8 | Generic run templates. |
| `prompts/universal/01_AURORA_CORE_NEXT_CHAT_HANDOVER_PROMPT.md` | New-chat handover prompt | Active | no | L8 | Must point to active control files first. |
| `prompts/workers/00_WORKER_PROMPTS_INDEX.md` | Worker prompt index | Active | no | L8 | Worker prompt routing. |
| `prompts/codex/00_CODEX_PROMPTS_INDEX.md` | Codex-specific prompt index | Active | no | L8 | Codex run controls. |
| `prompts/audits/00_AUDIT_PROMPTS_INDEX.md` | Audit prompt index | Active | no | L8 | Audit-specific prompts. |

## reports
| path | role | status | must-read? | source authority level | notes |
|---|---|---|---|---|---|
| `reports/00_REPORTS_INDEX.md` | Reports navigation index | Active | no | L9 | Source-controlled report router; reports are audit evidence only, not runtime source truth. |
| `reports/2026-05-25_git_landing_proof_ledger.md` | Git landing proof ledger | Active | task-specific | L9 | Separates branch/PR/main landing/proof classes for worker and overseer reconciliation. |

## mt5
| path | role | status | must-read? | source authority level | notes |
|---|---|---|---|---|---|
| `mt5/00_MT5_SOURCE_INDEX.md` | MT5 source navigation | Active | yes | L1 | Source gateway. |
| `mt5/00_RUNTIME0_GOVERNANCE_INTERNAL_CONTROL_SOURCE_PLAN_AND_TESTS.md` | Runtime 0 source plan/tests | Active | no | L1/L4 | Planning+tests for active owner. |
| `mt5/01_LAYER1_ACCOUNT_PORTFOLIO_PROP_RULE_TRUTH_SOURCE_PLAN_AND_TESTS.md` | Runtime 1 Layer 1 plan/tests | Active | no | L1/L4 | Layer 1 scope. |
| `mt5/02_SEED_SENTINEL_INHERITANCE_AUDIT.md` | Seed/sentinel audit notes | Active | no | L1/L4 | Audit/contract note. |
| `mt5/AuroraCore.mq5` | Main EA source | Active | yes | L1 | Current implementation truth. |

## mt5/core
| path | role | status | must-read? | source authority level | notes |
|---|---|---|---|---|---|
| `mt5/core/AC_Config.mqh` | Build/runtime contract constants | Active | yes | L1 | Upgrade scope/truth contract. |
| `mt5/core/AC_CommonTypes.mqh` | Shared runtime structs/types | Active | no | L1 | Core shared data model. |

## mt5/runtime_owners
| path | role | status | must-read? | source authority level | notes |
|---|---|---|---|---|---|
| `mt5/runtime_owners/00_RUNTIME_OWNERS_SOURCE_INDEX.md` | Runtime owners source index | Active | yes | L1/L4 | Source owner map. |

## mt5/runtime_owners/runtime_0_governance_internal_control
| path | role | status | must-read? | source authority level | notes |
|---|---|---|---|---|---|
| `.../layer_0_1_startup_runtime_identity/AC_RuntimeIdentity.mqh` | Runtime identity owner code | Active | yes | L1 | Runtime 0 layer owner. |
| `.../layer_0_2_scheduler_heartbeat_breathing/AC_Heartbeat.mqh` | Timer/heartbeat owner code | Active | yes | L1 | Bounded heartbeat contract. |
| `.../layer_0_4_governance_manifest_telemetry/AC_GovernanceRows.mqh` | Manifest/telemetry rows owner | Active | yes | L1 | Governance publication support. |

## mt5/runtime_owners/runtime_1_foundation_truth_owner
| path | role | status | must-read? | source authority level | notes |
|---|---|---|---|---|---|
| `.../layer_1_account_portfolio_prop_rule_truth/AC_AccountTruth.mqh` | Account truth snapshot owner | Active | yes | L1 | Read-only account truth layer. |

## mt5/runtime_owners/runtime_2_market_universe_taxonomy_lookup
| path | role | status | must-read? | source authority level | notes |
|---|---|---|---|---|---|
| `.../AC_MarketUniverse.mqh` | Taxonomy/universe lookup owner + generated rows include when present | Active | yes | L1 | Compile/runtime loading unproven unless explicit evidence exists. |

## mt5/runtime_owners/runtime_7_publication_owner
| path | role | status | must-read? | source authority level | notes |
|---|---|---|---|---|---|
| `.../publication_routes/AC_ServerPaths.mqh` | Route builder owner | Active | yes | L1 | Inherited `runtime_7_publication_owner` folder naming; architecture treats this as Publication/FileIO/Route System Service support, not trading truth ownership. |
| `.../publication_fileio/AC_FileIO.mqh` | FileIO writer owner | Active | yes | L1 | Inherited `runtime_7_publication_owner` folder naming; do not infer trading Runtime Owner status from folder name. |
| `.../publication_renderers/AC_PublicationRenderers.mqh` | Publication renderer composition bridge | Active | yes | L1 | Includes L11-L16 render surfaces without creating calculation authority. |
| `.../publication_renderers/AC_Layer15CorrelationDiversityRenderer.mqh` | L15 render-only readback surface | Active | task-specific | L1 | Reads L15 worker outputs only; no correlation calculation or selection authority. |
| `.../publication_renderers/AC_Layer16GlobalTop10Renderer.mqh` | L16 render-only readback surface | Active | task-specific | L1 | Reads L16 worker outputs only; no basket calculation or trading authority. |

## external_worker
| path | role | status | must-read? | source authority level | notes |
|---|---|---|---|---|---|
| `external_worker/00_EXTERNAL_WORKER_SOURCE_INDEX.md` | External worker source index | Active | yes | L1/L4 | Runtime 3 calculation-support source map. |
| `external_worker/aurora_worker_entrypoint.py` | Active worker entrypoint | Active | yes | L1 | Chains core -> L11 -> L12 -> L13 -> L14 -> L15 -> L16 -> L17. |
| `external_worker/aurora_worker_l15.py` | L15 correlation/diversity worker | Active | task-specific | L1 | Consumes L14 candidate pool and Shared OHLC Store if available; no broker polling. |
| `external_worker/aurora_worker_l15_dispatch.py` | L15 result_latest dispatch | Active | task-specific | L1 | Appends `l15_*` fields to worker result output. |
| `external_worker/aurora_worker_l16.py` | L16 Global Top 10 worker | Active | task-specific | L1 | Consumes L14/L15 outputs only; held visible basket; fallback labels; no raw OHLC/correlation recompute/trading authority. |
| `external_worker/aurora_worker_l16_dispatch.py` | L16 result_latest dispatch | Active | task-specific | L1 | Appends `l16_*` fields to worker result output. |
| `external_worker/aurora_worker_l17.py` | L17 Deep Evidence Selection Split worker | Active | task-specific | L1 | Consumes L16 held visible display rows only; selected/rejected split; no evidence collection/trading authority. |
| `external_worker/aurora_worker_l17_dispatch.py` | L17 result_latest dispatch | Active | task-specific | L1 | Appends `l17_*` fields to worker result output. |

## Archive (historical context only)
| path | role | status | must-read? | source authority level | notes |
|---|---|---|---|---|---|
| `archive/00_ARCHIVE_INDEX.md` and sub-indexes | Superseded drafts/prompts/blueprints | Historical | no | L9 | Never outranks current source/control truth. |


## local_inputs
| path | role | status | must-read? | source authority level | notes |
|---|---|---|---|---|---|
| `local_inputs/00_LOCAL_INPUTS_INDEX.md` | Local staging input index | Active | no | L9 | Staging/support only; never active source truth by itself. |

## tools
| path | role | status | must-read? | source authority level | notes |
|---|---|---|---|---|---|
| `tools/00_TOOLS_INDEX.md` | Utility tools index | Active | no | L9 | Support tooling only; cannot override source-truth hierarchy. |

## When to update this master index
- When root folders are added/removed/repurposed.
- When mandatory startup routing changes.
- When active source owners/files change.
- When archive/local_inputs/tools authority boundaries change.

- separate folder governance files were merged into folder indexes (lean scaffold rule).