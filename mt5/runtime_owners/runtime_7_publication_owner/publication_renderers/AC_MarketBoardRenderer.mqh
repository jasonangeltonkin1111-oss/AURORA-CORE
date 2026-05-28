#ifndef AC_MARKET_BOARD_RENDERER_MQH
#define AC_MARKET_BOARD_RENDERER_MQH

string AC_BoardTraderSelectionOverviewSection();

string AC_BoardHealthTag(const string status)
{
   if(StringFind(status, "Incremental") >= 0 || StringFind(status, "incremental") >= 0 ||
      StringFind(status, "Updating") >= 0 || StringFind(status, "updating") >= 0 ||
      StringFind(status, "bounded") >= 0 || StringFind(status, "Bounded") >= 0)
      return "UPDATING";
   if(StringFind(status, "Review") >= 0 || StringFind(status, "review") >= 0 ||
      StringFind(status, "warning") >= 0 || StringFind(status, "Warning") >= 0)
      return "REVIEW";
   if(StringFind(status, "Drift") >= 0 || StringFind(status, "drift") >= 0)
      return "DRIFT";
   if(StringFind(status, "history_limited") >= 0 || StringFind(status, "History Limited") >= 0)
      return "PARTIAL";
   if(StringFind(status, "Degraded") >= 0 || StringFind(status, "degraded") >= 0 ||
      StringFind(status, "Expired") >= 0 || StringFind(status, "expired") >= 0)
      return "DEGRADED";
   if(StringFind(status, "Pending") >= 0 || StringFind(status, "pending") >= 0)
      return "PENDING";
   if(StringFind(status, "seed") >= 0 || StringFind(status, "Seed") >= 0)
      return "SEEDING";
   if(StringFind(status, "Accepted") >= 0 || StringFind(status, "accepted") >= 0 ||
      StringFind(status, "Complete") >= 0 || StringFind(status, "complete") >= 0 ||
      StringFind(status, "Ready") >= 0 || StringFind(status, "ready") >= 0)
      return "ACCEPTED";
   return "CHECK";
}

bool AC_BoardStatusNeedsWarning(const string status)
{
   string tag = AC_BoardHealthTag(status);
   return !(tag == "ACCEPTED" || tag == "UPDATING" || tag == "SEEDING");
}

string AC_BoardWarningText()
{
   string text = "";
   if(AC_BoardStatusNeedsWarning(AC_L6_STATUS)) text += "L6=" + AC_L6_STATUS + "; ";
   if(AC_BoardStatusNeedsWarning(AC_L7_STATUS)) text += "L7=" + AC_L7_STATUS + "; ";
   if(AC_BoardStatusNeedsWarning(AC_L8_STATUS)) text += "L8=" + AC_L8_STATUS + "; ";
   if(AC_BoardStatusNeedsWarning(AC_L9_STATUS)) text += "L9=" + AC_L9_STATUS + "; ";
   if(AC_BoardStatusNeedsWarning(AC_L10_STATUS)) text += "L10=" + AC_L10_STATUS + "; ";
   if(AC_BoardStatusNeedsWarning(AC_L15_STATUS)) text += "L15=" + AC_L15_STATUS + "; ";
   if(AC_BoardStatusNeedsWarning(AC_L16_STATUS)) text += "L16=" + AC_L16_STATUS + "; ";
   if(AC_BoardStatusNeedsWarning(AC_L17_STATUS)) text += "L17=" + AC_L17_STATUS + "; ";
   if(text == "") return "none";
   return text;
}

void AC_BoardRefreshSurfacePackets()
{
   // Existing owner refresh only. This prevents Board/Workbench top text from printing stale
   // surface status while later detail sections refresh newer sidecar truth in the same render pass.
   AC_RefreshLayer6RankedSidecar();
   AC_L7RefreshRankedSidecar();
   AC_L8RefreshRankedSidecar();
   AC_L9RefreshRankedSidecar();
   AC_L10RefreshTaxonomySummary();
   AC_L11RefreshSummary();
   AC_L12RefreshSummary();
   AC_L13RefreshSummary();
   AC_L14RefreshSummary();
   AC_L15RefreshSummary();
   AC_L16RefreshSummary();
   AC_L17RefreshSummary();
   AC_L18L19RefreshStatus();
}

string AC_BoardOverviewRow(const string surface,
                           const string state,
                           const string health,
                           const string progress,
                           const string blocker,
                           const string owner,
                           const string meaning)
{
   return surface + " | " + state + " | " + health + " | " + progress + " | " + blocker + " | " + owner + " | " + meaning + "\r\n";
}

string AC_BoardGatewayState()
{
   if(AC_EXTERNAL_WORKER_STATUS.accepted_result && AC_EXTERNAL_WORKER_STATUS.heartbeat_validation_status == "Fresh")
      return "ACCEPTED";
   if(AC_EXTERNAL_WORKER_STATUS.heartbeat_present && AC_EXTERNAL_WORKER_STATUS.result_validation_status == "Rejected")
      return "REVIEW";
   if(AC_EXTERNAL_WORKER_STATUS.heartbeat_present)
      return AC_EXTERNAL_WORKER_STATUS.heartbeat_validation_status == "Fresh" ? "PENDING" : "DEGRADED";
   if(AC_EXTERNAL_WORKER_STATUS.worker_installed)
      return "PENDING";
   return "DEGRADED";
}

string AC_BoardGatewayProgress()
{
   return "heartbeat=" + AC_EXTERNAL_WORKER_STATUS.heartbeat_validation_status
      + ";result=" + AC_EXTERNAL_WORKER_STATUS.result_validation_status
      + ";accepted=" + (AC_EXTERNAL_WORKER_STATUS.accepted_result ? "true" : "false");
}

string AC_BoardGatewayCycleStatusPath()
{
   return AC_ExternalWorkerStatusFolder() + "\\gateway_cycle_status.txt";
}

string AC_BoardGatewayCycleText()
{
   return AC_L16ReadSmallTextFile(AC_BoardGatewayCycleStatusPath(), 20000);
}

string AC_BoardHeaderSection(const AC_Runtime0Snapshot &snapshot,
                             const AC_Layer0StatusPacket &status)
{
   string text = "";
   text += "AURORA CORE - MARKET BOARD\r\n";
   text += "==================================================\r\n";
   text += "Build Version:    " + AC_BUILD_VERSION + "\r\n";
   text += "Heartbeat ID:     " + IntegerToString((int)snapshot.heartbeat_id) + "\r\n";
   text += "Generated At:     " + snapshot.generated_at + "\r\n";
   text += "Current Broker Time: " + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS) + "\r\n";
   text += "State:            " + status.status + "\r\n";
   text += "Trust:            " + status.trust_state + "\r\n";
   text += "Layer 0 Final State: L0.1=" + snapshot.layer_0_1_status + " | L0.2=" + snapshot.layer_0_2_status + " | L0.4=" + snapshot.layer_0_4_status + " | owner=" + snapshot.owner_status + "\r\n";
   text += "Dossier Batch Status: " + status.status + " | ready=" + IntegerToString(status.dossier_shells_ready) + "/" + IntegerToString(status.broker_symbols_total) + " | failed=" + IntegerToString(status.failed_symbol_count) + "\r\n";
   text += "Manifest Status:  " + snapshot.manifest_status + "\r\n";
   text += "Diagnostics Status: " + snapshot.diagnostics_status + "\r\n";
   text += "Worker Status:    " + AC_EXTERNAL_WORKER_STATUS.worker_status + " | result=" + AC_EXTERNAL_WORKER_STATUS.result_validation_status + " | heartbeat=" + AC_EXTERNAL_WORKER_STATUS.heartbeat_validation_status + "\r\n";
   text += "L6 Status:        " + AC_L6_STATUS + "\r\n";
   text += "L7 Status:        " + AC_L7_STATUS + "\r\n";
   text += "Timer Duration ms: " + IntegerToString((int)snapshot.timer_duration_ms) + "\r\n";
   text += "Timer Pressure State: " + snapshot.timer_pressure_state + "\r\n";
   text += "Trade Permission: FALSE\r\n";
   text += "Auto Trading:     FALSE\r\n";
   return text;
}

string AC_BoardSystemCockpitSection(const AC_Layer0StatusPacket &status)
{
   string text = "";
   text += "\r\nSYSTEM COCKPIT\r\n";
   text += "--------------------------------------------------\r\n";
   text += "Runtime Mode:        Publication + inspection ranking\r\n";
   text += "Selection Surface:   L16 visible basket + L17 deep-evidence split; inspection only\r\n";
   text += "Permission Stage:    Not active\r\n";
   string cycle = AC_BoardGatewayCycleText();
   text += "Chain State:         " + AC_L16KvValue(cycle, "chain_state", "not_runtime_proven") + "\r\n";
   text += "Core Completion:     " + AC_L16KvValue(cycle, "core_completion_state", "not_runtime_proven") + "\r\n";
   text += "Deep Completion:     " + AC_L16KvValue(cycle, "deep_completion_state", "not_runtime_proven") + "\r\n";
   text += "Static Hold:         " + AC_L16KvValue(cycle, "accepted_epoch_static_hold_active", "false") + " remaining=" + AC_L16KvValue(cycle, "accepted_epoch_static_remaining_seconds", "0") + "s\r\n";
   text += "Retry Cycle:         " + AC_L16KvValue(cycle, "retry_cycle_count", "0") + "/" + AC_L16KvValue(cycle, "retry_cycle_limit", "5") + "\r\n";
   text += "Chain Blocker:       " + AC_L16KvValue(cycle, "main_blocker_owner", "not_runtime_proven") + " | " + AC_L16KvValue(cycle, "main_blocker_reason", "not_runtime_proven") + "\r\n";
   text += "L8 Strict State:     " + AC_L8_STATUS + "\r\n";
   text += "L15 Correlation:     " + AC_L15_STATUS + "\r\n";
   text += "L17 Currentness:     " + AC_L16KvValue(cycle, "l17_current_chain_valid", "see_gateway_result") + "\r\n";
   text += "L18/L19 Deep Fill:   L18=" + AC_L18_STATUS + " L19=" + AC_L19_STATUS + "\r\n";
   text += "Primary Warning:     " + AC_BoardWarningText() + "\r\n";
   text += "Main Blocker:        " + status.main_blocker + "\r\n";
   return text;
}

string AC_BoardOperatorActionSection()
{
   string text = "";
   text += "\r\nOPERATOR ACTION VIEW\r\n";
   text += "--------------------------------------------------\r\n";
   text += "Use For Trading:      NO\r\n";
   text += "Use For Inspection:   YES\r\n";
   text += "Use For Selection:    L16/L17 inspection surfaces only; no trade permission\r\n";
   text += "Best Current Use:     Review L17 deep-selected symbols first, then rejected/watch-only rows and dossiers\r\n";
   text += "Do Not Do:            No trade, no alert, no execution, no prop-firm safety claim\r\n";
   return text;
}

string AC_BoardUniverseSnapshotSection(const AC_Layer0StatusPacket &status)
{
   string text = "";
   text += "\r\nUNIVERSE SNAPSHOT\r\n";
   text += "--------------------------------------------------\r\n";
   text += "Broker Symbols Seen:       " + IntegerToString(status.broker_symbols_total) + "\r\n";
   text += "Dossier Generation:        " + IntegerToString(status.dossier_shells_ready) + " / " + IntegerToString(status.broker_symbols_total) + " = " + AC_PercentText(status.dossier_shells_ready, status.broker_symbols_total) + "\r\n";
   text += "Open / Closed Known:       " + IntegerToString(AC_L2_OPEN_COUNT) + " / " + IntegerToString(AC_L2_CLOSED_COUNT) + "\r\n";
   text += "L5 Pass / Blocked:         " + IntegerToString(AC_L5_GATE_PASS) + " / " + IntegerToString(AC_L5_GATE_BLOCKED) + "\r\n";
   text += "L14 Candidate Pool:        " + IntegerToString(AC_L14_CANDIDATE_POOL_SIZE) + "\r\n";
   text += "L14 Top Candidate:         " + AC_L14_TOP_CANDIDATE + "\r\n";
   text += "L15 Candidates Scored:     " + IntegerToString(AC_L15_CANDIDATE_SCORED_COUNT) + "\r\n";
   text += "L15 Top Diversity:         " + AC_L15_TOP_DIVERSITY_CANDIDATE + "\r\n";
   text += "L16 Selected:              " + IntegerToString(AC_L16_SELECTED_COUNT) + " / 10\r\n";
   text += "L16 Top Symbol:            " + AC_L16_TOP_SYMBOL + "\r\n";
   text += "L17 Deep Selected:         " + IntegerToString(AC_L17_DEEP_SELECTED_COUNT) + " / 5\r\n";
   text += "L17 Clean / Fallback:      " + IntegerToString(AC_L17_CLEAN_SELECTED_COUNT) + " / " + IntegerToString(AC_L17_FALLBACK_SELECTED_COUNT) + "\r\n";
   text += "L17 Top Deep Symbol:       " + AC_L17_TOP_SYMBOL + "\r\n";
   return text;
}

string AC_BoardLayerHealthMatrixSection(const AC_Layer0StatusPacket &status)
{
   string text = "";
   text += "\r\nSURFACE OVERVIEW\r\n";
   text += "--------------------------------------------------\r\n";
   text += "Surface | State | Health | Progress | Blocker | Owner | Meaning\r\n";
   text += AC_BoardOverviewRow("Dossiers Physical Route", AC_DOSSIER_PHYSICAL_MATCH_OK ? "ACCEPTED" : "DEGRADED", AC_DOSSIER_PHYSICAL_MATCH_OK ? "clean" : "mismatch", "open " + IntegerToString(AC_DOSSIER_PHYSICAL_OPEN_FILES) + "/" + IntegerToString(AC_DOSSIER_EXPECTED_OPEN_FILES) + ", closed " + IntegerToString(AC_DOSSIER_PHYSICAL_CLOSED_FILES) + "/" + IntegerToString(AC_DOSSIER_EXPECTED_CLOSED_FILES), AC_DOSSIER_PHYSICAL_MATCH_OK ? "physical_route_clean" : "physical_route_mismatch", "Runtime7 Dossier publication", "physical route truth only");
   text += AC_BoardOverviewRow("L0 Publication / Dossier", AC_BoardHealthTag(status.status), status.trust_state, IntegerToString(status.dossier_shells_ready) + "/" + IntegerToString(status.broker_symbols_total) + " generated", status.main_blocker, "Board / Dossier Renderer Service", "publication status only");
   text += AC_BoardOverviewRow("L1 Account / Portfolio", AC_L1_READY ? "ACCEPTED" : "PENDING", AC_L1_READY ? "available" : "pending", "history/account surfaces", AC_L1_READY ? "none" : "account_truth_pending", "Runtime1 Foundation Truth", "account and portfolio truth");
   text += AC_BoardOverviewRow("L2 Market Open / Closed", AC_BoardHealthTag(AC_L2_SCAN_STATUS), AC_L2_SCAN_STATUS, "open " + IntegerToString(AC_L2_OPEN_COUNT) + " / closed " + IntegerToString(AC_L2_CLOSED_COUNT), "none", "Runtime1 Foundation Truth", "market state truth");
   text += AC_BoardOverviewRow("L3 Broker Specs / Value", AC_BoardHealthTag(AC_L3_SCAN_STATUS), AC_L3_SCAN_STATUS, "specs/value/margin", AC_L3_READY ? "none" : "spec_truth_pending", "Runtime1 Foundation Truth", "broker specs truth");
   text += AC_BoardOverviewRow("L4 Quote / Spread", AC_BoardHealthTag(AC_L4_SCAN_STATUS), AC_L4_SCAN_STATUS, "fresh " + IntegerToString(AC_L4_FRESH_QUOTES) + " / stale " + IntegerToString(AC_L4_STALE_QUOTES), AC_L4_READY ? "quote_quality_visible" : "quote_truth_pending", "Runtime1 Foundation Truth", "live quote truth");
   text += AC_BoardOverviewRow("L5 Basic System Gate", AC_BoardHealthTag(AC_L5_STATUS), AC_L5_STATUS, "pass " + IntegerToString(AC_L5_GATE_PASS) + " / blocked " + IntegerToString(AC_L5_GATE_BLOCKED), AC_L5_STATUS == "Complete" ? "none" : "gate_pending", "Runtime1 Foundation Truth", "eligibility gate only");
   text += AC_BoardOverviewRow("L6 Cost / Friction", AC_BoardHealthTag(AC_L6_STATUS), AC_L6_STATUS, "rows accepted=" + (AC_L6_RANKED_ACCEPTED ? "true" : "false"), AC_L6_RANKED_ACCEPTED ? "none" : "ranked_sidecar_not_current_accepted", "Runtime3 worker readback", "inspection ranking only");
   text += AC_BoardOverviewRow("L7 Session Relevance", AC_BoardHealthTag(AC_L7_STATUS), AC_L7_STATUS, "rows " + IntegerToString(AC_L7_RANKED_ROWS_RENDERED), AC_L7_RANKED_ACCEPTED ? "none" : "epoch_or_count_contract_pending", "Runtime3 worker readback", "session relevance ranking only");
   text += AC_BoardOverviewRow("L8 Movement / Range", AC_BoardHealthTag(AC_L8_STATUS), AC_L8_STATUS, "rows " + IntegerToString(AC_L8_RANKED_ROWS_RENDERED) + ";ohlc_min=" + IntegerToString(AC_L8_OHLC_MIN_READY_RENDERED), AC_L8_RANKED_ACCEPTED ? "none" : "ohlc_or_epoch_contract_degraded", "Runtime3 worker readback", "movement/range scoring only");
   text += AC_BoardOverviewRow("L9 Structure / Location", AC_BoardHealthTag(AC_L9_STATUS), AC_L9_STATUS, "rows " + IntegerToString(AC_L9_RANKED_ROWS_RENDERED) + ";quality=" + AC_L9_GEOMETRY_QUALITY_STATE, AC_L9_RANKED_ACCEPTED ? "none" : "structure_or_ohlc_contract_degraded", "Runtime3 worker readback", "structure/location context only");
   text += AC_BoardOverviewRow("L10 Taxonomy / Ranking Group", AC_BoardHealthTag(AC_L10_STATUS), AC_L10_STATUS, "symbols " + IntegerToString(AC_L10_SYMBOL_COUNT), AC_L10_ACCEPTED ? "none" : "taxonomy_summary_pending", "Runtime3 worker readback", "classification only");
   text += AC_BoardOverviewRow("L11 Symbol Rank in Group", AC_BoardHealthTag(AC_L11_STATUS), AC_L11_STATUS, "ranked " + IntegerToString(AC_L11_RANKED_SYMBOL_COUNT), AC_L11_ACCEPTED ? "none" : "group_rank_pending", "Runtime3 worker readback", "intra-group ranking only");
   text += AC_BoardOverviewRow("L12 Group Heat / Quality", AC_BoardHealthTag(AC_L12_STATUS), AC_L12_STATUS, "groups " + IntegerToString(AC_L12_GROUP_COUNT), AC_L12_ACCEPTED ? "none" : "group_heat_pending", "Runtime3 worker readback", "group quality only");
   text += AC_BoardOverviewRow("L13 Group Selection", AC_BoardHealthTag(AC_L13_STATUS), AC_L13_STATUS, "selected groups " + IntegerToString(AC_L13_SELECTED_GROUP_COUNT), AC_L13_ACCEPTED ? "none" : "group_selection_pending", "Runtime3 worker readback", "attention selection only");
   text += AC_BoardOverviewRow("L14 Candidate Pool", AC_BoardHealthTag(AC_L14_STATUS), AC_L14_STATUS, "pool " + IntegerToString(AC_L14_CANDIDATE_POOL_SIZE), AC_L14_ACCEPTED ? "none" : "candidate_pool_pending", "Runtime3 worker readback", "candidate pool only");
   text += AC_BoardOverviewRow("L15 Correlation / Diversity", AC_BoardHealthTag(AC_L15_STATUS), AC_L15_STATUS, "scored " + IntegerToString(AC_L15_CANDIDATE_SCORED_COUNT), AC_L15_ACCEPTED ? "none" : "correlation_pending", "Runtime3 worker readback", "diversity scoring only");
   text += AC_BoardOverviewRow("L16 Global Top 10 Basket", AC_BoardHealthTag(AC_L16_STATUS), AC_L16_STATUS, "selected " + IntegerToString(AC_L16_SELECTED_COUNT) + "/10 fallback=" + IntegerToString(AC_L16_FALLBACK_COUNT), AC_L16_MAIN_BLOCKER, "Runtime3 worker readback", "inspection basket only");
   text += AC_BoardOverviewRow("L17 Deep Evidence Split", AC_BoardHealthTag(AC_L17_STATUS), AC_L17_STATUS, "deep " + IntegerToString(AC_L17_DEEP_SELECTED_COUNT) + "/5 fallback=" + IntegerToString(AC_L17_FALLBACK_SELECTED_COUNT), AC_L17_MAIN_BLOCKER, "Runtime3 worker readback", "evidence budget split only");
   text += AC_BoardOverviewRow("L18 Raw OHLC Bar Pack", AC_SurfaceStateFromStatus(AC_L18_STATUS), AC_L18_FRESHNESS_STATUS, "found " + IntegerToString(AC_L18_SOURCE_FILES_FOUND) + "/" + IntegerToString(AC_L18_SOURCE_FILES_EXPECTED) + ";missing=" + IntegerToString(AC_L18_SOURCE_FILES_MISSING), AC_L18_REASON, "Runtime3 worker status surface", "selected raw OHLC display only");
   text += AC_BoardOverviewRow("L19 Wick / Candle Geometry", AC_SurfaceStateFromStatus(AC_L19_STATUS), AC_L19_FRESHNESS_STATUS, "geometry_rows=" + IntegerToString(AC_L19_VALID_GEOMETRY_ROWS) + ";stale=" + IntegerToString(AC_L19_FRESHNESS_STALE_COUNT), AC_L19_REASON, "Runtime3 worker status surface", "wick/candle geometry only");
   text += AC_BoardOverviewRow("L20 Rolling Tick Pack", "NOT_ACTIVE", "design_hold", "feed_quality_proxy_scaffold;mt5_proxy_caveat", "not_runtime_active", "Design hold", "future selected-symbol tick/feed quality evidence only");
   text += AC_BoardOverviewRow("L21 Indicator / Reference Pack", "NOT_ACTIVE", "design_hold", "explainable_reference_scaffold", "not_runtime_active", "Design hold", "future ATR/VWAP/Bollinger/Donchian context only");
   text += AC_BoardOverviewRow("L22 Liquidity / DOM Proxy", "NOT_ACTIVE", "design_hold", "evidence_scaffold_poi_liquidity_proxy", "not_runtime_active", "Design hold", "future evidence structures only, no buy/sell wording");
   text += AC_BoardOverviewRow("L23 Setup / Permission State", "BLOCKED", "trade_permission_false", "entry_signal=false execution=false auto_trade_allowed=false alert_allowed=false", "strategy_validation_status=not_validated", "Design hold", "validation scaffold only; no setup, alert, permission, or execution");
   text += AC_BoardOverviewRow("OHLC Shared Raw Store", AC_BoardHealthTag(AC_SHARED_OHLC_STATUS), AC_SHARED_OHLC_STATUS, "tf=8 pending=" + IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_PENDING) + ";topup=" + IntegerToString(AC_SHARED_OHLC_TOPUP_ATTEMPTED), "supported_timeframes=M1,M5,M15,M30,H1,H4,D1,W1", "Runtime1 Shared OHLC Raw Storage", "raw storage only");
   text += AC_BoardOverviewRow("Gateway / External Worker", AC_BoardGatewayState(), AC_EXTERNAL_WORKER_STATUS.worker_status, AC_BoardGatewayProgress(), AC_EXTERNAL_WORKER_STATUS.result_validation_reason, "Runtime3 Calculation Gateway", "worker liveness and result acceptance are separate");
   text += AC_BoardOverviewRow("Selection Desk", AC_BoardHealthTag(AC_SelectionDeskScaffoldStatus()), AC_SelectionDeskScaffoldStatus(), "L16=" + IntegerToString(AC_L16_SELECTED_COUNT) + ";L17=" + IntegerToString(AC_L17_DEEP_SELECTED_COUNT) + ";dup_l18=" + IntegerToString(AC_L18_SELECTED_DUPLICATE_ROUTE_COPIES), AC_SelectionDeskBlockerSummary(), "Runtime3 worker selection publishers", "operator navigation only");
   return text;
}

string AC_BoardSurfaceScoringSnapshotSection()
{
   string text = "";
   text += "\r\nSURFACE SCORING SNAPSHOT\r\n";
   text += "--------------------------------------------------\r\n";
   text += "Layer 6 Cost/Friction:       " + AC_L6_STATUS + "\r\n";
   text += "Layer 7 Session Relevance:   " + AC_L7_STATUS + "\r\n";
   text += "Layer 8 Movement/Range:      " + AC_L8_STATUS + "\r\n";
   text += "Layer 9 Structure/Location:  " + AC_L9_STATUS + " | quality=" + AC_L9_GEOMETRY_QUALITY_STATE + "\r\n";
   text += "Meaning:                    ranking/inspection only; no direction, setup, alert, or permission\r\n";
   return text;
}

string AC_BoardSurfaceCoherenceProofSection()
{
   string text = "";
   text += "\r\nSURFACE COHERENCE PROOF - L6 TO L9\r\n";
   text += "--------------------------------------------------\r\n";
   text += "Refresh Source: owner packets refreshed before top Board/Workbench text\r\n";
   text += "L6 Status: " + AC_L6_STATUS + " | checksum=" + AC_L6_MANIFEST_PAYLOAD_CHECKSUM + " | accepted=" + (AC_L6_RANKED_ACCEPTED ? "true" : "false") + "\r\n";
   text += "L7 Status: " + AC_L7_STATUS + " | rows=" + IntegerToString(AC_L7_RANKED_ROWS_RENDERED) + " | input=" + AC_L7_INPUT_PAYLOAD_CHECKSUM_RENDERED + " | ranked=" + AC_L7_RANKED_PAYLOAD_CHECKSUM_RENDERED + " | accepted=" + (AC_L7_RANKED_ACCEPTED ? "true" : "false") + "\r\n";
   text += "L8 Status: " + AC_L8_STATUS + " | rows=" + IntegerToString(AC_L8_RANKED_ROWS_RENDERED) + " | input=" + AC_L8_INPUT_PAYLOAD_CHECKSUM_RENDERED + " | ranked=" + AC_L8_RANKED_PAYLOAD_CHECKSUM_RENDERED + " | accepted=" + (AC_L8_RANKED_ACCEPTED ? "true" : "false") + "\r\n";
   text += "L9 Status: " + AC_L9_STATUS + " | quality=" + AC_L9_GEOMETRY_QUALITY_STATE + " | rows=" + IntegerToString(AC_L9_RANKED_ROWS_RENDERED) + " | input=" + AC_L9_INPUT_PAYLOAD_CHECKSUM_RENDERED + " | ranked=" + AC_L9_RANKED_PAYLOAD_CHECKSUM_RENDERED + " | accepted=" + (AC_L9_RANKED_ACCEPTED ? "true" : "false") + "\r\n";
   text += "Meaning: this is render-time proof only; it does not grant setup, alert, selection, or trade permission\r\n";
   return text;
}

string AC_BoardSelectionPipelineSnapshotSection()
{
   string text = "";
   text += "\r\nSELECTION PIPELINE SNAPSHOT\r\n";
   text += "--------------------------------------------------\r\n";
   text += "L10 Taxonomy:             " + AC_L10_STATUS + "\r\n";
   text += "L11 Intra-group Ranking:  " + AC_L11_STATUS + "\r\n";
   text += "L12 Group Heat/Quality:   " + AC_L12_STATUS + "\r\n";
   text += "L13 Group Selection:      " + AC_L13_STATUS + "\r\n";
   text += "L14 Candidate Pool:       " + AC_L14_STATUS + " | size=" + IntegerToString(AC_L14_CANDIDATE_POOL_SIZE) + "\r\n";
   text += "L15 Correlation Filter:   " + AC_L15_STATUS + " | scored=" + IntegerToString(AC_L15_CANDIDATE_SCORED_COUNT) + " | high_corr_pairs=" + IntegerToString(AC_L15_HIGH_CORR_PAIR_COUNT) + "\r\n";
   text += "L16 Global Top 10:        " + AC_L16_STATUS + " | selected=" + IntegerToString(AC_L16_SELECTED_COUNT) + "/10 | unfilled=" + IntegerToString(AC_L16_UNFILLED_SLOTS_COUNT) + " | corr_rejects=" + IntegerToString(AC_L16_CORRELATION_REJECT_COUNT) + "\r\n";
   text += "L17 Deep Evidence Split:  " + AC_L17_STATUS + " | deep=" + IntegerToString(AC_L17_DEEP_SELECTED_COUNT) + "/5 | clean=" + IntegerToString(AC_L17_CLEAN_SELECTED_COUNT) + " | fallback=" + IntegerToString(AC_L17_FALLBACK_SELECTED_COUNT) + " | watch=" + IntegerToString(AC_L17_WATCH_ONLY_COUNT) + "\r\n";
   text += "L23 Trade Permission:     false\r\n";
   text += "Pipeline Meaning:         inspection/evidence-budget candidates only; no alert, execution, or trade permission\r\n";
   return text;
}

string AC_BoardDegradationSnapshotSection(const AC_Layer0StatusPacket &status)
{
   string text = "";
   text += "\r\nDEGRADATION / BLOCKER SNAPSHOT\r\n";
   text += "--------------------------------------------------\r\n";
   text += "Hard Trading Block:        permission system not active\r\n";
   text += "Main Runtime Blocker:      " + status.main_blocker + "\r\n";
   text += "Surface Warnings:          " + AC_BoardWarningText() + "\r\n";
   text += "L15 Threshold Status:      " + AC_L15_THRESHOLD_STATUS + "\r\n";
   text += "Max Pair Corr Abs:         " + AC_L15_MAX_PAIR_CORR_ABS + "\r\n";
   text += "L16 Threshold Status:      " + AC_L16_THRESHOLD_STATUS + "\r\n";
   text += "L16 Unfilled Slots:        " + IntegerToString(AC_L16_UNFILLED_SLOTS_COUNT) + "\r\n";
   text += "L17 Fallback Selected:     " + IntegerToString(AC_L17_FALLBACK_SELECTED_COUNT) + "\r\n";
   text += "L17 Watch Only:             " + IntegerToString(AC_L17_WATCH_ONLY_COUNT) + "\r\n";
   text += "Safety Meaning:            publication and inspection may continue; trading remains blocked\r\n";
   return text;
}

string AC_BoardDossierCoverageSection(const AC_Layer0StatusPacket &status)
{
   string text = "";
   text += "\r\nDOSSIER COVERAGE\r\n";
   text += "--------------------------------------------------\r\n";
   text += "Broker Symbols Seen:        " + IntegerToString(status.broker_symbols_total) + "\r\n";
   text += "Current Generation Updated: " + IntegerToString(status.dossier_shells_ready) + " / " + IntegerToString(status.broker_symbols_total) + "\r\n";
   text += "Current Generation Left:    " + IntegerToString(status.dossier_shells_missing) + "\r\n";
   text += "Generation Progress:        " + AC_PercentText(status.dossier_shells_ready, status.broker_symbols_total) + "\r\n";
   text += "Physical Missing:           not_reconciled_by_this_counter\r\n";
   text += "Counter Truth:              ready/left counts are current-generation refresh progress, not physical file count\r\n";
   text += "Failed Current Writes:      " + IntegerToString(status.failed_symbol_count) + "\r\n";
   text += "Dossier Pass Duration:      " + IntegerToString((int)status.batch_duration_ms) + " ms\r\n";
   text += "Dossier Layout Contract:    " + AC_DOSSIER_RENDER_LAYOUT_KEY + "\r\n";
   text += "Cached Layout Contract:     " + AC_L0_CACHED_DOSSIER_RENDER_LAYOUT_KEY + "\r\n";
   text += AC_DossierPhysicalCoverageBoardSection();
   return text;
}

string AC_BoardTradingReadinessSection()
{
   string text = "";
   text += "\r\nTRADING READINESS\r\n";
   text += "--------------------------------------------------\r\n";
   text += "Market State Known: " + ((AC_L2_OPEN_COUNT + AC_L2_CLOSED_COUNT) > 0 ? "Partial or Complete" : "No") + "\r\n";
   text += "Specs Known:        " + (AC_L3_READY ? "See Layer 3 readiness" : "No") + "\r\n";
   text += "Quotes Known:       " + (AC_L4_READY ? "See Layer 4 readiness" : "No") + "\r\n";
   text += "Cost Ranking:       " + AC_L6_STATUS + "\r\n";
   text += "Session Ranking:    " + AC_L7_STATUS + "\r\n";
   text += "Movement Ranking:   " + AC_L8_STATUS + "\r\n";
   text += "Structure Ranking:  " + AC_L9_STATUS + " | quality=" + AC_L9_GEOMETRY_QUALITY_STATE + "\r\n";
   text += "Taxonomy Map:       " + AC_L10_STATUS + "\r\n";
   text += "Symbol Ranking:     " + AC_L11_STATUS + "\r\n";
   text += "Group Heat Quality: " + AC_L12_STATUS + "\r\n";
   text += "Group Selection:    " + AC_L13_STATUS + "\r\n";
   text += "Candidate Pool:     " + AC_L14_STATUS + "\r\n";
   text += "Correlation/Diversity: " + AC_L15_STATUS + "\r\n";
   text += "Global Top 10:      " + AC_L16_STATUS + "\r\n";
   text += "Deep Evidence Split:" + AC_L17_STATUS + "\r\n";
   text += "OHLC Raw Store:     " + AC_SHARED_OHLC_STATUS + "\r\n";
   text += "Selection Active:   L16/L17 inspection and evidence-budget surfaces only; no trade permission\r\n";
   text += "Permission Active:  No\r\n";
   return text;
}

string AC_BoardTrustBlockerSection(const AC_Layer0StatusPacket &status)
{
   string text = "";
   text += "\r\nTRUST BLOCKER\r\n";
   text += "--------------------------------------------------\r\n";
   text += status.main_blocker + "\r\n";
   text += "Layer 6-9 are ranking/scoring only; Layer 10 is taxonomy/ranking_group map only; Layer 11 is intra-group inspection priority only; Layer 12 is group heat/quality only; Layer 13 selects groups for attention only; Layer 14 builds a raw candidate pool only; Layer 15 scores correlation/diversity only; Layer 16 builds the visible inspection basket only; Layer 17 splits future deep-evidence budget only; Layer 5 remains the only hard gate.\r\n";
   text += "Shared OHLC is raw storage only; no strategy, selection, or permission authority.\r\n";
   return text;
}

string AC_BoardActionSection()
{
   string text = "";
   text += "\r\nACTION\r\n";
   text += "--------------------------------------------------\r\n";
   text += "Board refresh is atomic and heartbeat-visible; survival publication may be overwritten by final publication in the same heartbeat.\r\n";
   text += "Latest accepted L16/L17 surfaces may guide inspection order and future evidence budget only; no alerts, execution, or trade permission exists.\r\n";
   return text;
}

string AC_BuildTraderBoardText(const AC_Runtime0Snapshot &snapshot,
                               const AC_Layer0StatusPacket &status)
{
   AC_BoardRefreshSurfacePackets();
   // Build existing layer detail first. These existing owner sections refresh their own packets/sidecars.
   // The top-view that follows reads those owner fields; it does not create a second refresh/scoring owner.
   string l1 = AC_Layer1BoardSection();
   string l2 = AC_Layer2BoardSection();
   string l3 = AC_Layer3BoardSection();
   string l4 = AC_Layer4BoardSection();
   string l5 = AC_Layer5BoardSection();
   string l6 = AC_Layer6BoardSection();
   string l7 = AC_Layer7BoardSection();
   string l8 = AC_Layer8BoardSection();
   string l9 = AC_Layer9BoardSection();
   string l10 = AC_Layer10BoardSection();
   string l11 = AC_Layer11BoardSection();
   string l12 = AC_Layer12BoardSection();
   string l13 = AC_Layer13BoardSection();
   string l14 = AC_Layer14BoardSection();
   string l15 = AC_Layer15BoardSection();
   string l16 = AC_Layer16BoardSection();
   string l17 = AC_Layer17BoardSection();
   string ohlc = AC_SharedOhlcRenderBoardSection();

   string text = "";
   text += AC_BoardHeaderSection(snapshot, status);
   text += AC_BoardSystemCockpitSection(status);
   text += AC_BoardOperatorActionSection();
   text += AC_BoardUniverseSnapshotSection(status);
   text += AC_BoardLayerHealthMatrixSection(status);
   text += AC_BoardSurfaceScoringSnapshotSection();
   text += AC_BoardSurfaceCoherenceProofSection();
   text += AC_BoardSelectionPipelineSnapshotSection();
   text += AC_BoardDegradationSnapshotSection(status);
   text += AC_BoardDossierCoverageSection(status);
   text += AC_BoardTraderSelectionOverviewSection();
   text += "\r\nFULL LAYER DETAIL\r\n";
   text += "==================================================\r\n";
   text += l1;
   text += l2;
   text += l3;
   text += l4;
   text += l5;
   text += l6;
   text += l7;
   text += l8;
   text += l9;
   text += l10;
   text += l11;
   text += l12;
   text += l13;
   text += l14;
   text += l15;
   text += l16;
   text += l17;
   text += ohlc;
   text += AC_BoardTradingReadinessSection();
   text += AC_BoardTrustBlockerSection(status);
   text += AC_BoardActionSection();
   return text;
}

string AC_Layer0StatusRow(const AC_Layer0StatusPacket &status)
{
   AC_BoardRefreshSurfacePackets();
   AC_DossierPhysicalRefreshProof();
   return "schema_name=layer_status|schema_version=v0.20|layer_id=L0|layer_name=" + status.layer_name
      + "|source_owner=" + status.owner_name
      + "|status=" + status.status
      + "|trust_state=" + status.trust_state
      + "|broker_symbols_total=" + IntegerToString(status.broker_symbols_total)
      + "|marketwatch_symbols_total=" + IntegerToString(status.marketwatch_symbols_total)
      + "|dossier_current_generation_updated=" + IntegerToString(status.dossier_shells_ready)
      + "|dossier_current_generation_left=" + IntegerToString(status.dossier_shells_missing)
      + "|dossier_physical_open_files=" + IntegerToString(AC_DOSSIER_PHYSICAL_OPEN_FILES)
      + "|dossier_physical_closed_files=" + IntegerToString(AC_DOSSIER_PHYSICAL_CLOSED_FILES)
      + "|dossier_physical_unknown_files=" + IntegerToString(AC_DOSSIER_PHYSICAL_UNKNOWN_FILES)
      + "|dossier_expected_open_files=" + IntegerToString(AC_DOSSIER_EXPECTED_OPEN_FILES)
      + "|dossier_expected_closed_files=" + IntegerToString(AC_DOSSIER_EXPECTED_CLOSED_FILES)
      + "|dossier_expected_unknown_files=" + IntegerToString(AC_DOSSIER_EXPECTED_UNKNOWN_FILES)
      + "|dossier_physical_missing_symbols=" + IntegerToString(AC_DOSSIER_PHYSICAL_MISSING_SYMBOLS)
      + "|dossier_physical_wrong_folder_symbols=" + IntegerToString(AC_DOSSIER_PHYSICAL_WRONG_FOLDER_SYMBOLS)
      + "|dossier_physical_duplicate_symbols=" + IntegerToString(AC_DOSSIER_PHYSICAL_DUPLICATE_SYMBOLS)
      + "|dossier_physical_orphan_files=" + IntegerToString(AC_DOSSIER_PHYSICAL_ORPHAN_FILES)
      + "|dossier_physical_cleanup_pending=" + (AC_DOSSIER_PHYSICAL_CLEANUP_PENDING ? "true" : "false")
      + "|dossier_physical_match=" + (AC_DOSSIER_PHYSICAL_MATCH_OK ? "true" : "false")
      + "|dossier_counter_truth=current_generation_progress_not_physical_file_count"
      + "|failed_current_write_count=" + IntegerToString(status.failed_symbol_count)
      + "|retry_count_total=" + IntegerToString(status.retry_count_total)
      + "|generation_progress=" + AC_PercentText(status.dossier_shells_ready, status.broker_symbols_total)
      + "|pass_start_index=" + IntegerToString(status.batch_start_index)
      + "|pass_end_index=" + IntegerToString(status.batch_end_index)
      + "|symbols_attempted=" + IntegerToString(status.batch_attempted)
      + "|symbols_written=" + IntegerToString(status.batch_written)
      + "|pass_duration_ms=" + IntegerToString((int)status.batch_duration_ms)
      + "|cached_pass_valid=" + (AC_L0_CACHED_PASS_VALID ? "true" : "false")
      + "|dossier_shell_schema_version=" + AC_DOSSIER_SHELL_SCHEMA_VERSION
      + "|dossier_render_layout_key=" + AC_DOSSIER_RENDER_LAYOUT_KEY
      + "|cached_dossier_shell_schema_version=" + AC_L0_CACHED_DOSSIER_SCHEMA_VERSION
      + "|cached_dossier_render_layout_key=" + AC_L0_CACHED_DOSSIER_RENDER_LAYOUT_KEY
      + "|cached_l2_route_generation_key=" + AC_L0_CACHED_L2_ROUTE_GENERATION_KEY
      + "|cached_l3_cache_key=" + AC_L0_CACHED_L3_CACHE_KEY
      + "|cached_l4_cache_key=" + AC_L0_CACHED_L4_CACHE_KEY
      + "|cached_l4_refresh_key=" + AC_L0_CACHED_L4_REFRESH_KEY
      + "|cached_l5_status=" + AC_L0_CACHED_L5_STATUS
      + "|cached_l6_status=" + AC_L0_CACHED_L6_STATUS
      + "|current_l6_status=" + AC_L6_STATUS
      + "|cached_l6_checksum=" + AC_L0_CACHED_L6_CHECKSUM
      + "|current_l6_checksum=" + AC_L6_MANIFEST_PAYLOAD_CHECKSUM
      + "|cached_l7_status=" + AC_L0_CACHED_L7_STATUS
      + "|current_l7_status=" + AC_L7_STATUS
      + "|current_l7_rows=" + IntegerToString(AC_L7_RANKED_ROWS_RENDERED)
      + "|current_l7_input_checksum=" + AC_L7_INPUT_PAYLOAD_CHECKSUM_RENDERED
      + "|current_l7_ranked_checksum=" + AC_L7_RANKED_PAYLOAD_CHECKSUM_RENDERED
      + "|cached_l8_status=" + AC_L0_CACHED_L8_STATUS
      + "|current_l8_status=" + AC_L8_STATUS
      + "|current_l8_rows=" + IntegerToString(AC_L8_RANKED_ROWS_RENDERED)
      + "|current_l8_input_checksum=" + AC_L8_INPUT_PAYLOAD_CHECKSUM_RENDERED
      + "|current_l8_ranked_checksum=" + AC_L8_RANKED_PAYLOAD_CHECKSUM_RENDERED
      + "|cached_l9_status=" + AC_L0_CACHED_L9_STATUS
      + "|current_l9_status=" + AC_L9_STATUS
      + "|current_l9_rows=" + IntegerToString(AC_L9_RANKED_ROWS_RENDERED)
      + "|current_l9_input_checksum=" + AC_L9_INPUT_PAYLOAD_CHECKSUM_RENDERED
      + "|current_l9_ranked_checksum=" + AC_L9_RANKED_PAYLOAD_CHECKSUM_RENDERED
      + "|current_l9_geometry_quality=" + AC_L9_GEOMETRY_QUALITY_STATE
      + "|cached_l10_status=" + AC_L10_STATUS
      + "|cached_l11_status=" + AC_L11_STATUS
      + "|cached_l12_status=" + AC_L12_STATUS
      + "|cached_l13_status=" + AC_L13_STATUS
      + "|cached_l14_status=" + AC_L14_STATUS
      + "|cached_l15_status=" + AC_L15_STATUS
      + "|cached_l16_status=" + AC_L16_STATUS
      + "|cached_l17_status=" + AC_L17_STATUS
      + "|l17_deep_selected_count=" + IntegerToString(AC_L17_DEEP_SELECTED_COUNT)
      + "|l17_clean_selected_count=" + IntegerToString(AC_L17_CLEAN_SELECTED_COUNT)
      + "|l17_fallback_selected_count=" + IntegerToString(AC_L17_FALLBACK_SELECTED_COUNT)
      + "|shared_ohlc_status=" + AC_SHARED_OHLC_STATUS
      + "|shared_ohlc_mode=" + AC_SHARED_OHLC_MODE
      + "|shared_ohlc_seed_complete=" + (AC_SHARED_OHLC_BOOT_SEED_COMPLETE ? "true" : "false")
      + "|main_blocker=" + status.main_blocker
      + "|trade_permission=false|ranking_runtime=" + ((AC_L6_RANKED_ACCEPTED || AC_L7_RANKED_ACCEPTED || AC_L8_RANKED_ACCEPTED || AC_L9_RANKED_ACCEPTED || AC_L10_ACCEPTED || AC_L11_ACCEPTED || AC_L12_ACCEPTED || AC_L13_ACCEPTED || AC_L14_ACCEPTED || AC_L15_ACCEPTED || AC_L16_ACCEPTED || AC_L17_ACCEPTED) ? "true" : "false") + "|selection_runtime=false|entry_signal=false|execution=false|market_state_known=" + (((AC_L2_OPEN_COUNT + AC_L2_CLOSED_COUNT) > 0) ? "true" : "false");
}

string AC_Layer0WorkbenchText(const AC_Layer0StatusPacket &status)
{
   AC_BoardRefreshSurfacePackets();
   AC_DossierPhysicalRefreshProof();
   string l1_workbench = AC_Layer1WorkbenchSection();
   string l2_workbench = AC_Layer2WorkbenchSection();
   string l3_workbench = AC_Layer3WorkbenchSection();
   string l4_workbench = AC_Layer4WorkbenchSection();
   string l5_workbench = AC_Layer5WorkbenchSection();
   string l6_workbench = AC_Layer6WorkbenchSection();
   string l7_workbench = AC_Layer7WorkbenchSection();
   string l8_workbench = AC_Layer8WorkbenchSection();
   string l9_workbench = AC_Layer9WorkbenchSection();
   string l10_workbench = AC_Layer10WorkbenchSection();
   string l11_workbench = AC_Layer11WorkbenchSection();
   string l12_workbench = AC_Layer12WorkbenchSection();
   string l13_workbench = AC_Layer13WorkbenchSection();
   string l14_workbench = AC_Layer14WorkbenchSection();
   string l15_workbench = AC_Layer15WorkbenchSection();
   string l16_workbench = AC_Layer16WorkbenchSection();
   string l17_workbench = AC_Layer17WorkbenchSection();
   string ohlc_workbench = AC_SharedOhlcRenderWorkbenchSection();

   string text = "";
   text += "L0_BOARD_DOSSIER_FOUNDATION\r\n";
   text += "----------------------------------------\r\n";
   text += "layer_id=L0\r\n";
   text += "layer_name=" + status.layer_name + "\r\n";
   text += "owner_name=" + status.owner_name + "\r\n";
   text += "status=" + status.status + "\r\n";
   text += "trust_state=" + status.trust_state + "\r\n";
   text += "broker_symbols_total=" + IntegerToString(status.broker_symbols_total) + "\r\n";
   text += "marketwatch_symbols_total=" + IntegerToString(status.marketwatch_symbols_total) + "\r\n";
   text += "dossier_current_generation_updated=" + IntegerToString(status.dossier_shells_ready) + "\r\n";
   text += "dossier_current_generation_left=" + IntegerToString(status.dossier_shells_missing) + "\r\n";
   text += "dossier_physical_open_files=" + IntegerToString(AC_DOSSIER_PHYSICAL_OPEN_FILES) + "\r\n";
   text += "dossier_physical_closed_files=" + IntegerToString(AC_DOSSIER_PHYSICAL_CLOSED_FILES) + "\r\n";
   text += "dossier_physical_unknown_files=" + IntegerToString(AC_DOSSIER_PHYSICAL_UNKNOWN_FILES) + "\r\n";
   text += "dossier_expected_open_files=" + IntegerToString(AC_DOSSIER_EXPECTED_OPEN_FILES) + "\r\n";
   text += "dossier_expected_closed_files=" + IntegerToString(AC_DOSSIER_EXPECTED_CLOSED_FILES) + "\r\n";
   text += "dossier_expected_unknown_files=" + IntegerToString(AC_DOSSIER_EXPECTED_UNKNOWN_FILES) + "\r\n";
   text += "dossier_physical_missing_symbols=" + IntegerToString(AC_DOSSIER_PHYSICAL_MISSING_SYMBOLS) + "\r\n";
   text += "dossier_physical_wrong_folder_symbols=" + IntegerToString(AC_DOSSIER_PHYSICAL_WRONG_FOLDER_SYMBOLS) + "\r\n";
   text += "dossier_physical_duplicate_symbols=" + IntegerToString(AC_DOSSIER_PHYSICAL_DUPLICATE_SYMBOLS) + "\r\n";
   text += "dossier_physical_orphan_files=" + IntegerToString(AC_DOSSIER_PHYSICAL_ORPHAN_FILES) + "\r\n";
   text += "dossier_physical_cleanup_pending=" + (AC_DOSSIER_PHYSICAL_CLEANUP_PENDING ? "true" : "false") + "\r\n";
   text += "dossier_physical_match=" + (AC_DOSSIER_PHYSICAL_MATCH_OK ? "true" : "false") + "\r\n";
   text += "dossier_physical_proof_key=" + AC_DOSSIER_PHYSICAL_LAST_PROOF_KEY + "\r\n";
   text += "dossier_counter_truth=current_generation_progress_not_physical_file_count\r\n";
   text += "failed_current_write_count=" + IntegerToString(status.failed_symbol_count) + "\r\n";
   text += "retry_count_total=" + IntegerToString(status.retry_count_total) + "\r\n";
   text += "generation_progress=" + AC_PercentText(status.dossier_shells_ready, status.broker_symbols_total) + "\r\n";
   text += "pass_start_index=" + IntegerToString(status.batch_start_index) + "\r\n";
   text += "pass_end_index=" + IntegerToString(status.batch_end_index) + "\r\n";
   text += "symbols_attempted=" + IntegerToString(status.batch_attempted) + "\r\n";
   text += "symbols_written=" + IntegerToString(status.batch_written) + "\r\n";
   text += "pass_duration_ms=" + IntegerToString((int)status.batch_duration_ms) + "\r\n";
   text += "cached_pass_valid=" + (AC_L0_CACHED_PASS_VALID ? "true" : "false") + "\r\n";
   text += "dossier_shell_schema_version=" + AC_DOSSIER_SHELL_SCHEMA_VERSION + "\r\n";
   text += "dossier_render_layout_key=" + AC_DOSSIER_RENDER_LAYOUT_KEY + "\r\n";
   text += "cached_dossier_shell_schema_version=" + AC_L0_CACHED_DOSSIER_SCHEMA_VERSION + "\r\n";
   text += "cached_dossier_render_layout_key=" + AC_L0_CACHED_DOSSIER_RENDER_LAYOUT_KEY + "\r\n";
   text += "l2_route_generation_key=" + AC_L2_ROUTE_GENERATION_KEY + "\r\n";
   text += "cached_l2_route_generation_key=" + AC_L0_CACHED_L2_ROUTE_GENERATION_KEY + "\r\n";
   text += "l3_cache_key=" + AC_L3_CACHE_KEY + "\r\n";
   text += "cached_l3_cache_key=" + AC_L0_CACHED_L3_CACHE_KEY + "\r\n";
   text += "l4_cache_key=" + AC_L4_CACHE_KEY + "\r\n";
   text += "l4_refresh_key=" + AC_L4_REFRESH_KEY + "\r\n";
   text += "cached_l4_cache_key=" + AC_L0_CACHED_L4_CACHE_KEY + "\r\n";
   text += "cached_l4_refresh_key=" + AC_L0_CACHED_L4_REFRESH_KEY + "\r\n";
   text += "cached_l5_status=" + AC_L0_CACHED_L5_STATUS + "\r\n";
   text += "cached_l6_status=" + AC_L0_CACHED_L6_STATUS + "\r\n";
   text += "current_l6_status=" + AC_L6_STATUS + "\r\n";
   text += "cached_l6_checksum=" + AC_L0_CACHED_L6_CHECKSUM + "\r\n";
   text += "current_l6_checksum=" + AC_L6_MANIFEST_PAYLOAD_CHECKSUM + "\r\n";
   text += "cached_l7_status=" + AC_L0_CACHED_L7_STATUS + "\r\n";
   text += "current_l7_status=" + AC_L7_STATUS + "\r\n";
   text += "current_l7_rows=" + IntegerToString(AC_L7_RANKED_ROWS_RENDERED) + "\r\n";
   text += "current_l7_input_checksum=" + AC_L7_INPUT_PAYLOAD_CHECKSUM_RENDERED + "\r\n";
   text += "current_l7_ranked_checksum=" + AC_L7_RANKED_PAYLOAD_CHECKSUM_RENDERED + "\r\n";
   text += "cached_l8_status=" + AC_L0_CACHED_L8_STATUS + "\r\n";
   text += "current_l8_status=" + AC_L8_STATUS + "\r\n";
   text += "current_l8_rows=" + IntegerToString(AC_L8_RANKED_ROWS_RENDERED) + "\r\n";
   text += "current_l8_input_checksum=" + AC_L8_INPUT_PAYLOAD_CHECKSUM_RENDERED + "\r\n";
   text += "current_l8_ranked_checksum=" + AC_L8_RANKED_PAYLOAD_CHECKSUM_RENDERED + "\r\n";
   text += "cached_l9_status=" + AC_L0_CACHED_L9_STATUS + "\r\n";
   text += "current_l9_status=" + AC_L9_STATUS + "\r\n";
   text += "current_l9_rows=" + IntegerToString(AC_L9_RANKED_ROWS_RENDERED) + "\r\n";
   text += "current_l9_input_checksum=" + AC_L9_INPUT_PAYLOAD_CHECKSUM_RENDERED + "\r\n";
   text += "current_l9_ranked_checksum=" + AC_L9_RANKED_PAYLOAD_CHECKSUM_RENDERED + "\r\n";
   text += "current_l9_geometry_quality=" + AC_L9_GEOMETRY_QUALITY_STATE + "\r\n";
   text += "cached_l10_status=" + AC_L10_STATUS + "\r\n";
   text += "cached_l11_status=" + AC_L11_STATUS + "\r\n";
   text += "cached_l12_status=" + AC_L12_STATUS + "\r\n";
   text += "cached_l13_status=" + AC_L13_STATUS + "\r\n";
   text += "cached_l14_status=" + AC_L14_STATUS + "\r\n";
   text += "cached_l15_status=" + AC_L15_STATUS + "\r\n";
   text += "cached_l16_status=" + AC_L16_STATUS + "\r\n";
   text += "cached_l17_status=" + AC_L17_STATUS + "\r\n";
   text += "l17_deep_selected_count=" + IntegerToString(AC_L17_DEEP_SELECTED_COUNT) + "\r\n";
   text += "l17_clean_selected_count=" + IntegerToString(AC_L17_CLEAN_SELECTED_COUNT) + "\r\n";
   text += "l17_fallback_selected_count=" + IntegerToString(AC_L17_FALLBACK_SELECTED_COUNT) + "\r\n";
   text += "main_blocker=" + status.main_blocker + "\r\n";
   text += "first_failure=" + status.first_failure + "\r\n";
   text += "statistics_owner=layer_owner_packet_not_board_calculation\r\n";
   text += "gateway=used_for_L6_L7_L8_L9_L10_L11_L12_L13_L14_L15_L16_L17_surface_taxonomy_ranking_group_selection_candidate_pool_correlation_top10_deep_evidence_split_only_not_for_L0_L1_L2_L3_L4_or_L5\r\n";
   text += "mt5_script_worker=not_used_for_runtime_board_stats\r\n";
   text += "\r\n" + l1_workbench;
   text += l2_workbench;
   text += l3_workbench;
   text += l4_workbench;
   text += l5_workbench;
   text += l6_workbench;
   text += l7_workbench;
   text += l8_workbench;
   text += l9_workbench;
   text += l10_workbench;
   text += l11_workbench;
   text += l12_workbench;
   text += l13_workbench;
   text += l14_workbench;
   text += l15_workbench;
   text += l16_workbench;
   text += l17_workbench;
   text += "\r\n" + ohlc_workbench;
   return text;
}

string AC_Layer0FailureAddendumText()
{
   string text = "";
   text += "L0_L2_L3_L4_L5_L6_L7_L8_L9_L10_L11_L12_L13_L14_L15_L16_L17_FAILED_SYMBOL_PACKET_ADDENDUM\r\n";
   text += "----------------------------------------\r\n";
   if(AC_L0_FAILURE_ADDENDUM == "") text += "none\r\n";
   else text += AC_L0_FAILURE_ADDENDUM;
   return text;
}

#endif
