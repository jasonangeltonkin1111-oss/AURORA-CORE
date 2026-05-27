# 02 MASTER REPO FILE INDEX

## Purpose
Complete navigation index for important repository files, ownership boundaries, and current status.

This index maps the AURORA CORE trading-intelligence system. It must not make the repo front door revolve around overseer, parallel worker, or branch-process language.

## Owns / Does Not Own
**Owns:** repository navigation, must-read pointers, folder-by-folder file map, authority labels.

**Does not own:** runtime implementation truth, strategy/trading permission, compile/runtime proof claims.

## Mandatory startup path for new chats
1. `AGENTS.md`
2. `README.md`
3. `control/02_MASTER_REPO_FILE_INDEX.md`
4. `control/00_CONTROL_INDEX.md`
5. `control/01_CONTROL_GOVERNANCE.md`
6. Relevant top-level folder index
7. Relevant real content file

## Source authority levels used here
- **L1:** Active MT5 source files and active external-worker source files (implementation truth)
- **L2:** Runtime/generated evidence samples (when explicitly present)
- **L3:** `README.md` + `AGENTS.md`
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
| `AGENTS.md` | Canonical repo agent law and system identity guardrails | Active | yes | L3 | Trading-system identity, owner law, proof law, chain-flow law. |
| `README.md` | Repo front door and system-chain overview | Active | yes | L3 | Must describe Aurora as trading-intelligence system, not process-management system. |
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
| `docs/09_BUCKET_UNIVERSE_TAXONOMY_GUIDEBOOK.md` | Taxonomy naming contract with historical bucket terminology | Active | yes | L5 | Active EA-facing naming uses `asset_class`, `market_group`, `market_segment`, `ranking_group`, `symbol`. |
| `docs/10_SELECTION_BASKET_CONSTRUCTION_GUIDEBOOK.md` | Selection Desk parent-route contract doctrine | Active | yes | L5 | Stable parent routes contract. |
| `docs/15_ANTI_DRIFT_SOURCE_OF_TRUTH_GUIDEBOOK.md` | Source-of-truth anti-drift doctrine | Active | yes | L5 | Authority/boundary doctrine. |
| `docs/02_TIMING_HEARTBEAT_BREATHING_SPINE_GUIDEBOOK.md` .. `docs/14_MT5_FUNCTION_GUIDEBOOK.md` | Runtime doctrines by domain | Active | no | L5 | Task-specific doctrine set. |
| `docs/20_SYMBOL_UNIVERSE_IMPORT_CONTRACT.md` .. `docs/25_SHARED_OHLC_RAW_STORAGE_OWNER.md` | Quality/import/OHLC contracts | Active | no | L5 | Contract and process addenda. |
| `docs/26_L10_TAXONOMY_CLASSIFICATION_CONTROL.md` | L10 taxonomy / ranking_group map control | Active | task-specific | L5 | Current L10 control contract. |
| `docs/30_L12_RANKING_GROUP_HEAT_QUALITY_CONTROL.md` | L12 ranking_group heat / quality control | Active | task-specific | L5 | Current L12 control contract. |
| `docs/32_L13_DYNAMIC_RANKING_GROUP_SELECTION_CONTROL.md` | L13 dynamic ranking_group selection control | Active | task-specific | L5 | Current L13 control contract. |
| `docs/33_L14_RANKING_GROUP_LEADER_CANDIDATE_POOL_CONTROL.md` | L14 ranking_group leader candidate pool control | Active | task-specific | L5 | Current L14 control contract. |
| `docs/34_L15_CORRELATION_DIVERSITY_SELECTION_CONTROL.md` | L15 correlation / diversity scoring control | Active | task-specific | L5 | Current L15 control contract. |
| `docs/35_L16_GLOBAL_TOP10_BUILDER_CONTROL.md` | L16 Global Top 10 inspection basket control | Active | task-specific | L5 | Held visible basket + fallback labels; no trade permission. |
| `docs/36_L17_DEEP_EVIDENCE_SELECTION_SPLIT_CONTROL.md` | L17 Deep Evidence Selection Split control | Active | task-specific | L5 | Consumes L16 held visible display rows only; no evidence collection/trade permission. |
| `docs/37_OPERATOR_WORKFLOW_AND_UX_RUNBOOK.md` | Operator workflow and UX runbook | Active | task-specific | L5 | First-click workflow, export safety, overtrading guardrails, and runtime visual-output test gate. |
| `docs/39_AURORA_COMPLETION_EPOCH_CONTROL.md` | Chain currentness, completion epoch, and future-layer weave control | Active | task-specific | L5 | L14-L19 currentness, core/deep completion split, L15 M15/M5 correlation contract, and L20-L23 future-safe scaffolds. |
| `docs/27_RUNTIME_5_TO_7_FUTURE_LAYER_PLAYBOOK.md` .. `docs/33_L13_CLOSEOUT_AND_L14_HANDOFF.md` | Runtime/layer implementation notes and handoffs | Active | task-specific | L5 | Check exact file before using as active source; current source/config still outranks docs. |

## blueprint
| path | role | status | must-read? | source authority level | notes |
|---|---|---|---|---|---|
| `blueprint/00_BLUEPRINT_INDEX.md` | Blueprint navigation front door | Active | yes | L6 | System architecture router, not process-management router. |
| `blueprint/01_SYSTEM_IDENTITY_AND_MISSION.md` | Identity/mission blueprint | Active | no | L6 | Structure, not runtime proof. |
| `blueprint/02_RUNTIME_OWNER_BLUEPRINT.md` | Runtime owner + system service boundaries | Active | no | L6 | Architecture map. |
| `blueprint/03_LOGICAL_LAYER_BLUEPRINT.md` | Active 23-layer trading/system layer map | Active | yes | L6 | Canonical logical chain from L1 foundation truth to L23 review/permission state. |
| `blueprint/04_BUILD_PHASE_BLUEPRINT.md` | Build phase contract | Active | no | L6 | Phase/evidence gates. |
| `blueprint/05_PUBLICATION_SURFACE_BLUEPRINT.md` | Publication surface blueprint | Active | no | L6 | Board, Dossier, Selection Desk, Workbench surface contract. |
| `blueprint/06_PERMISSION_AND_VALIDATION_BLUEPRINT.md` | Permission/validation structure | Active | no | L6 | Permission and validation contract. |
| `blueprint/07_FILEIO_ROUTE_OWNERSHIP_CONTRACT.md` | Route and FileIO ownership | Active | no | L6 | Route/FileIO ownership contract. |
| `blueprint/08_MT5_SOURCE_FOLDER_CONTRACT.md` | MT5 source placement contract | Active | no | L6 | Source folder structure. |
| `blueprint/09_PARALLEL_WORK_AND_MERGE_CONTROL_BLUEPRINT.md` | Retired process-control blueprint | Historical/process-only | no | L9 | Not active system architecture; do not use as front-door system identity. |

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
| `prompts/workers/00_WORKER_PROMPTS_INDEX.md` | Worker prompt index | Historical/task-specific | no | L8 | Prompt history/task routing only; not system architecture. |
| `prompts/codex/00_CODEX_PROMPTS_INDEX.md` | Codex-specific prompt index | Active | no | L8 | Codex run controls. |
| `prompts/audits/00_AUDIT_PROMPTS_INDEX.md` | Audit prompt index | Active | no | L8 | Audit-specific prompts. |

## reports
| path | role | status | must-read? | source authority level | notes |
|---|---|---|---|---|---|
| *(folder currently has no markdown files)* | Historical report sink when present | N/A | no | L9 | Add index only if reports are added. |

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
| `.../publication_renderers/AC_PublicationRenderers.mqh` | Publication renderer composition bridge | Active | yes | L1 | Includes render/readback surfaces without creating calculation authority. |
| `.../publication_renderers/AC_Layer15CorrelationDiversityRenderer.mqh` | L15 render-only readback surface | Active | task-specific | L1 | Reads L15 worker outputs only; no correlation calculation or selection authority. |
| `.../publication_renderers/AC_Layer16GlobalTop10Renderer.mqh` | L16 render-only readback surface | Active | task-specific | L1 | Reads L16 worker outputs only; no basket calculation or trading authority. |

## external_worker
| path | role | status | must-read? | source authority level | notes |
|---|---|---|---|---|---|
| `external_worker/00_EXTERNAL_WORKER_SOURCE_INDEX.md` | External calculation-support source index | Active | yes | L1/L4 | Runtime 3 calculation-support source map. |
| `external_worker/aurora_worker.py` | Active worker core | Active | yes | L1 | Runs core snapshot validation plus L6-L10 and RenderIndex support outputs. |
| `external_worker/aurora_worker_entrypoint.py` | Active worker entrypoint | Active | yes | L1 | Chains core then L11-L18; L19 is invoked by L18 dispatch. |
| `external_worker/aurora_worker_l6_friction.py` | L6 cost/friction worker | Active | task-specific | L1 | Consumes L6 primitives; publishes cost/friction score family only; no permission/execution. |
| `external_worker/aurora_worker_l7_session.py` | L7 session relevance worker | Active | task-specific | L1 | Session relevance scoring only; no permission/execution. |
| `external_worker/aurora_worker_l8_movement.py` | L8 movement/range worker | Active | task-specific | L1 | Movement/range scoring only; no permission/execution. |
| `external_worker/aurora_worker_l9_structure.py` | L9 structure/location worker | Active | task-specific | L1 | Structure/location scoring only; no permission/execution. |
| `external_worker/aurora_worker_l10.py` | L10 taxonomy worker | Active | task-specific | L1 | Taxonomy/ranking_group classification support; no permission/execution. |
| `external_worker/aurora_worker_l10_source.py` | L10 source bundle helper | Active | task-specific | L1 | Builds L10 source bundle from upstream packets; no permission/execution. |
| `external_worker/aurora_worker_render_index.py` | Render index support | Active | task-specific | L1 | Indexes prepared sidecars only; must not calculate owner truth. |
| `external_worker/aurora_worker_l11.py` | L11 symbol ranking worker | Active | task-specific | L1 | Consumes L6-L10/render-index context; no permission/execution. |
| `external_worker/aurora_worker_l11_dispatch.py` | L11 result_latest dispatch | Active | task-specific | L1 | Appends `l11_*` fields to worker result output. |
| `external_worker/aurora_worker_l12.py` | L12 ranking_group heat/quality worker | Active | task-specific | L1 | Consumes L11 outputs; no permission/execution. |
| `external_worker/aurora_worker_l12_dispatch.py` | L12 result_latest dispatch | Active | task-specific | L1 | Appends `l12_*` fields to worker result output. |
| `external_worker/aurora_worker_l13.py` | L13 dynamic ranking_group selection worker | Active | task-specific | L1 | Group selection support only; no trade permission/execution. |
| `external_worker/aurora_worker_l13_dispatch.py` | L13 result_latest dispatch | Active | task-specific | L1 | Appends `l13_*` fields to worker result output. |
| `external_worker/aurora_worker_l14.py` | L14 candidate pool worker | Active | task-specific | L1 | Candidate pool support only; no trade permission/execution. |
| `external_worker/aurora_worker_l14_dispatch.py` | L14 result_latest dispatch | Active | task-specific | L1 | Appends `l14_*` fields to worker result output. |
| `external_worker/aurora_worker_l15.py` | L15 correlation/diversity worker | Active | task-specific | L1 | Consumes latest-current L14 candidate pool and Shared OHLC Store M15/M5 recent windows if available; no broker polling. |
| `external_worker/aurora_worker_l15_dispatch.py` | L15 result_latest dispatch | Active | task-specific | L1 | Appends `l15_*` fields to worker result output. |
| `external_worker/aurora_worker_l16.py` | L16 Global Top 10 worker | Active | task-specific | L1 | Consumes L14/L15 outputs only; held visible basket; fallback labels; no raw OHLC/correlation recompute/trading authority. |
| `external_worker/aurora_worker_l16_dispatch.py` | L16 result_latest dispatch | Active | task-specific | L1 | Appends `l16_*` fields to worker result output. |
| `external_worker/aurora_worker_l17.py` | L17 Deep Evidence Selection Split worker | Active | task-specific | L1 | Consumes latest-current L16 only; selected/rejected split; no Selection Desk fallback as current truth; no evidence collection/trade permission. |
| `external_worker/aurora_worker_l17_dispatch.py` | L17 result_latest dispatch | Active | task-specific | L1 | Appends `l17_*` fields to worker result output. |
| `external_worker/aurora_worker_l18.py` | L18 Selected Raw OHLC Bar Pack worker | Active | task-specific | L1 | Reads existing Shared OHLC Store for selected scope only; no broker polling/permission. |
| `external_worker/aurora_worker_l18_dispatch.py` | L18 result_latest dispatch | Active | task-specific | L1 | Appends `l18_*` fields to worker result output and invokes L19 dispatch. |
| `external_worker/aurora_worker_l19.py` | L19 Candle Geometry worker | Active | task-specific | L1 | Selected candle geometry support only; no signals/permission/execution. |
| `external_worker/aurora_worker_l19_dispatch.py` | L19 result_latest dispatch | Active | task-specific | L1 | Appends `l19_*` fields to worker result output. |
| `external_worker/test_chain11_currentness.py` | Chain 11 synthetic tests | Active | test | L1/L4 | Proves stale L16/L17 cannot feed downstream, write-degraded cannot create static epoch, L15 M15 path works without H1, and L18 history-limited state remains explicit. |

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

- Separate folder governance files were merged into folder indexes (lean scaffold rule).
