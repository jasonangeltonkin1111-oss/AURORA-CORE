#ifndef AC_EXTERNAL_WORKER_SNAPSHOT_EXPORT_MQH
#define AC_EXTERNAL_WORKER_SNAPSHOT_EXPORT_MQH

static string AC_L10_LAST_RUNTIME2_INPUT_UPSTREAM_KEY = "not_exported";
static string AC_L10_LAST_RUNTIME2_INPUT_EXPORT_STATUS = "not_exported";
static string AC_L10_LAST_RUNTIME2_INPUT_MANIFEST_STATUS = "not_exported";
static string AC_L10_LAST_RUNTIME2_INPUT_PAYLOAD_CHECKSUM = "not_available";
static int    AC_L10_LAST_RUNTIME2_INPUT_ROWS = 0;
static ulong  AC_L10_LAST_RUNTIME2_INPUT_SIZE = 0;

string AC_L10Runtime2UniverseInputPath()
{
   return AC_ExternalWorkerOutboxFolder() + "\\Layers\\Layer_10_Taxonomy_Classification\\l10_runtime2_universe_rows.psv";
}

string AC_L10Runtime2UniverseInputManifestPath()
{
   return AC_ExternalWorkerOutboxFolder() + "\\Layers\\Layer_10_Taxonomy_Classification\\l10_runtime2_universe_rows.manifest";
}

string AC_L10Runtime2UniverseInputRows()
{
   string text = "server|broker_file|broker_symbol|canonical_symbol|asset_class|market_group|market_segment|ranking_group|strict_rank_allowed|public_research_rank_allowed|review_lane|classification_confidence|evidence_rank|runtime_permission|evidence_status|source_status|block_reason\r\n";
   int total = AC_UniverseLoadedRowCount();
   for(int idx = 0; idx < total; idx++)
   {
      string row = AC_UniverseGeneratedRowByIndex(idx);
      if(row == "") continue;
      text += row + "\r\n";
   }
   return text;
}

string AC_L10Runtime2UniverseInputUpstreamKey()
{
   return "generated_schema=" + AC_UNIVERSE_GENERATED_SCHEMA_VERSION
      + "|source_sha256=" + AC_UNIVERSE_SOURCE_FILE_SHA256
      + "|row_schema_sha256=" + AC_UNIVERSE_ROW_SCHEMA_SHA256
      + "|loaded_rows=" + IntegerToString(AC_UniverseLoadedRowCount())
      + "|strict=" + IntegerToString(AC_UniverseStrictRankAllowedCount())
      + "|public_research=" + IntegerToString(AC_UniversePublicResearchRankAllowedCount())
      + "|review_only=" + IntegerToString(AC_UniverseReviewOnlyCount())
      + "|blocked=" + IntegerToString(AC_UniverseBlockedCount())
      + "|contract=" + AC_UniverseContractStatus()
      + "|runtime_permission=" + AC_UniverseRuntimePermission();
}

AC_WriteResult AC_ExportLayer10Runtime2UniverseInput()
{
   string upstream_key = AC_L10Runtime2UniverseInputUpstreamKey();
   if(AC_L10_LAST_RUNTIME2_INPUT_UPSTREAM_KEY == upstream_key
      && AC_L10_LAST_RUNTIME2_INPUT_EXPORT_STATUS != "not_exported"
      && AC_L10_LAST_RUNTIME2_INPUT_MANIFEST_STATUS != "not_exported"
      && AC_L10_LAST_RUNTIME2_INPUT_PAYLOAD_CHECKSUM != "not_available")
   {
      return AC_MakeSyntheticWriteResult(AC_L10Runtime2UniverseInputPath(), true, "unchanged_cached", AC_L10_LAST_RUNTIME2_INPUT_SIZE, "l10_runtime2_universe_input_unchanged_no_row_build_no_psv_rewrite|key=" + upstream_key);
   }

   string rows = AC_L10Runtime2UniverseInputRows();
   string payload_checksum = AC_ExternalWorkerPayloadChecksum(rows);
   AC_WriteResult input_write = AC_WriteTextFile(AC_L10Runtime2UniverseInputPath(), rows);
   string manifest = "schema_name=l10_runtime2_universe_rows_manifest\r\n"
      + "schema_version=1\r\n"
      + "source_owner=Runtime 2 - Market Universe / Taxonomy Lookup Owner\r\n"
      + "export_owner=Runtime 3 - Gateway Support Export\r\n"
      + "consumer_layer=Layer 10 - Taxonomy / Ranking Group Map\r\n"
      + "input_file=l10_runtime2_universe_rows.psv\r\n"
      + "row_schema=server|broker_file|broker_symbol|canonical_symbol|asset_class|market_group|market_segment|ranking_group|strict_rank_allowed|public_research_rank_allowed|review_lane|classification_confidence|evidence_rank|runtime_permission|evidence_status|source_status|block_reason\r\n"
      + "row_count=" + IntegerToString(AC_UniverseLoadedRowCount()) + "\r\n"
      + "payload_checksum=" + payload_checksum + "\r\n"
      + "upstream_key=" + upstream_key + "\r\n"
      + "write_status=" + input_write.status + "\r\n"
      + "write_ok=" + (input_write.ok ? "true" : "false") + "\r\n"
      + "runtime2_contract_status=" + AC_UniverseContractStatus() + "\r\n"
      + "runtime_permission=" + AC_UniverseRuntimePermission() + "\r\n"
      + "authority=calculation_support_only\r\n"
      + "ranking_runtime=false\r\n"
      + "selection_runtime=false\r\n"
      + "trade_permission=false\r\n";
   AC_WriteResult manifest_write = AC_WriteTextFile(AC_L10Runtime2UniverseInputManifestPath(), manifest);
   AC_L10_LAST_RUNTIME2_INPUT_EXPORT_STATUS = input_write.status;
   AC_L10_LAST_RUNTIME2_INPUT_MANIFEST_STATUS = manifest_write.status;
   if(input_write.ok && manifest_write.ok)
   {
      AC_L10_LAST_RUNTIME2_INPUT_UPSTREAM_KEY = upstream_key;
      AC_L10_LAST_RUNTIME2_INPUT_PAYLOAD_CHECKSUM = payload_checksum;
      AC_L10_LAST_RUNTIME2_INPUT_ROWS = AC_UniverseLoadedRowCount();
      AC_L10_LAST_RUNTIME2_INPUT_SIZE = input_write.final_size;
   }
   if(input_write.ok && manifest_write.ok)
      return input_write;
   if(input_write.ok && !manifest_write.ok)
      return AC_MakeSyntheticWriteResult(AC_L10Runtime2UniverseInputManifestPath(), false, manifest_write.status, manifest_write.final_size, "l10_runtime2_input_manifest_write_failed");
   return input_write;
}

string AC_ExternalWorkerSnapshotHeader(const string snapshot_id, const string job_id, const int rows, const string payload_checksum)
{
   string text = "";
   text += "schema_name=aurora_external_worker_snapshot\r\n";
   text += "schema_version=6\r\n";
   text += "snapshot_id=" + snapshot_id + "\r\n";
   text += "job_bus_schema_version=" + AC_EXTERNAL_WORKER_JOB_BUS_SCHEMA_VERSION + "\r\n";
   text += "job_id=" + job_id + "\r\n";
   text += "job_type=" + AC_EXTERNAL_WORKER_DEFAULT_JOB_TYPE + "\r\n";
   text += "job_resource_class=" + AC_EXTERNAL_WORKER_JOB_RESOURCE_CLASS + "\r\n";
   text += "job_max_runtime_ms=" + IntegerToString(AC_EXTERNAL_WORKER_JOB_MAX_RUNTIME_MS) + "\r\n";
   text += "job_requested_layer=R3_GATEWAY\r\n";
   text += "job_expected_output=snapshot_validation_plus_l6_l7_l8_l9_input_primitives\r\n";
   text += "gateway_job_scope=snapshot_validation_plus_l6_l7_l8_l9_input_primitives_no_layer5_advisory_no_selection_no_permission\r\n";
   text += "system_name=" + AC_SYSTEM_NAME + "\r\n";
   text += "build_version=" + AC_BUILD_VERSION + "\r\n";
   text += "upgrade_id=" + AC_UPGRADE_ID + "\r\n";
   text += "source_owner=MT5_Runtime_3_Gateway_from_Runtime_1_L1_L5_packets\r\n";
   text += "worker_owner=" + AC_RUNTIME3_OWNER + "\r\n";
   text += "authority=" + AC_EXTERNAL_WORKER_AUTHORITY + "\r\n";
   text += "server=" + AC_ServerNameForRoute() + "\r\n";
   text += "account=" + AC_AccountForRoute() + "\r\n";
   text += "source_layers=L1,L2,L3,L4,L5_GATE_SUMMARY\r\n";
   text += "layer5_status=basic_system_gate_source_only\r\n";
   text += "row_count=" + IntegerToString(rows) + "\r\n";
   text += "payload_checksum=" + payload_checksum + "\r\n";
   text += "snapshot_complete=true\r\n";
   text += "trade_permission=false\r\n";
   text += "ranking_runtime=false\r\n";
   text += "selection_runtime=false\r\n\r\n";
   return text;
}

string AC_ExternalWorkerSnapshotRows()
{
   string text = "symbol|market_state|l3_ready|l4_ready|quote_quality|surface_quality|bid|ask|spread_points|spread_bps|daily_change_pct|tick_age_seconds|trade_permission\r\n";
   int total = SymbolsTotal(false);
   int rows = 0;
   for(int idx = 0; idx < total; idx++)
   {
      string symbol = SymbolName(idx, false);
      if(symbol == "") continue;
      string market_state = AC_L2MarketStateForSymbol(symbol);
      int l4_index = AC_L4FindIndex(symbol);
      string quote_quality = "not_available";
      string surface_quality = "not_available";
      double bid = 0.0;
      double ask = 0.0;
      double spread_points = 0.0;
      double spread_bps = 0.0;
      double daily_change_pct = 0.0;
      double tick_age_seconds = 0.0;
      if(l4_index >= 0)
      {
         quote_quality = AC_L4_SYMBOLS[l4_index].quote_quality;
         surface_quality = AC_L4_SYMBOLS[l4_index].surface_quality;
         bid = AC_L4_SYMBOLS[l4_index].bid;
         ask = AC_L4_SYMBOLS[l4_index].ask;
         spread_points = AC_L4_SYMBOLS[l4_index].spread_points_live;
         spread_bps = AC_L4_SYMBOLS[l4_index].spread_bps_live;
         daily_change_pct = AC_L4_SYMBOLS[l4_index].daily_change_pct;
         tick_age_seconds = AC_L4_SYMBOLS[l4_index].tick_age_seconds;
      }
      text += symbol + "|" + market_state + "|" + (AC_L3_READY ? "true" : "false") + "|" + (l4_index >= 0 ? "true" : "false") + "|" + quote_quality + "|" + surface_quality + "|" + DoubleToString(bid, 8) + "|" + DoubleToString(ask, 8) + "|" + DoubleToString(spread_points, 2) + "|" + DoubleToString(spread_bps, 4) + "|" + DoubleToString(daily_change_pct, 4) + "|" + DoubleToString(tick_age_seconds, 1) + "|false\r\n";
      rows++;
   }
   AC_EXTERNAL_WORKER_LAST_SNAPSHOT_ROWS = rows;
   return text;
}

AC_WriteResult AC_ExportExternalWorkerSnapshot()
{
   AC_WriteResult l10_runtime2_input_write = AC_ExportLayer10Runtime2UniverseInput();
   AC_WriteResult l6_input_write = AC_ExportLayer6CostFrictionInputPrimitives();
   AC_WriteResult l7_input_write = AC_ExportLayer7SessionRelevanceInputPrimitives();
   AC_WriteResult l8_input_write = AC_ExportLayer8MovementRangeInputPrimitives();
   AC_WriteResult l9_input_write = AC_ExportLayer9StructureLocationInputPrimitives();

   string upstream_key = AC_ExternalWorkerSnapshotUpstreamKey();
   if(AC_EXTERNAL_WORKER_LAST_SNAPSHOT_ID != "not_exported"
      && AC_EXTERNAL_WORKER_LAST_SNAPSHOT_UPSTREAM_KEY == upstream_key
      && AC_EXTERNAL_WORKER_LAST_SNAPSHOT_PAYLOAD_CHECKSUM != "not_available")
   {
      AC_EXTERNAL_WORKER_LAST_SNAPSHOT_STATUS = "unchanged_cached";
      AC_EXTERNAL_WORKER_LAST_SNAPSHOT_MANIFEST_STATUS = "unchanged_cached";
      AC_EXTERNAL_WORKER_LAST_JOB_STATUS = "unchanged_cached";
      return AC_MakeSyntheticWriteResult(AC_ExternalWorkerSnapshotPath(), true, "unchanged_cached", AC_EXTERNAL_WORKER_LAST_SNAPSHOT_SIZE, "snapshot_upstream_unchanged_no_row_build_no_checksum_no_rewrite|l10_runtime2_input=" + l10_runtime2_input_write.status + "|key=" + upstream_key + "|l6_input=" + l6_input_write.status + "|l7_input=" + l7_input_write.status + "|l8_input=" + l8_input_write.status + "|l9_input=" + l9_input_write.status);
   }

   string rows = AC_ExternalWorkerSnapshotRows();
   string payload_checksum = AC_ExternalWorkerPayloadChecksum(rows);
   if(AC_EXTERNAL_WORKER_LAST_SNAPSHOT_ID != "not_exported"
      && AC_EXTERNAL_WORKER_LAST_SNAPSHOT_PAYLOAD_CHECKSUM == payload_checksum)
   {
      AC_EXTERNAL_WORKER_LAST_SNAPSHOT_STATUS = "unchanged_cached";
      AC_EXTERNAL_WORKER_LAST_SNAPSHOT_MANIFEST_STATUS = "unchanged_cached";
      AC_EXTERNAL_WORKER_LAST_JOB_STATUS = "unchanged_cached";
      AC_EXTERNAL_WORKER_LAST_SNAPSHOT_UPSTREAM_KEY = upstream_key;
      return AC_MakeSyntheticWriteResult(AC_ExternalWorkerSnapshotPath(), true, "unchanged_cached", AC_EXTERNAL_WORKER_LAST_SNAPSHOT_SIZE, "snapshot_payload_unchanged_no_rewrite|l10_runtime2_input=" + l10_runtime2_input_write.status + "|l6_input=" + l6_input_write.status + "|l7_input=" + l7_input_write.status + "|l8_input=" + l8_input_write.status + "|l9_input=" + l9_input_write.status);
   }

   string snapshot_id = AC_ExternalWorkerSnapshotId();
   string job_id = AC_ExternalWorkerJobId(snapshot_id);
   string snapshot = AC_ExternalWorkerSnapshotHeader(snapshot_id, job_id, AC_EXTERNAL_WORKER_LAST_SNAPSHOT_ROWS, payload_checksum) + rows;
   AC_WriteResult snapshot_write = AC_WriteTextFile(AC_ExternalWorkerSnapshotPath(), snapshot);
   string manifest = "schema_name=aurora_external_worker_snapshot_manifest\r\nschema_version=7\r\nsnapshot_id=" + snapshot_id + "\r\njob_bus_schema_version=" + AC_EXTERNAL_WORKER_JOB_BUS_SCHEMA_VERSION + "\r\njob_id=" + job_id + "\r\njob_type=" + AC_EXTERNAL_WORKER_DEFAULT_JOB_TYPE + "\r\njob_requested_layer=R3_GATEWAY\r\njob_expected_output=snapshot_validation_plus_l6_l7_l8_l9_input_primitives\r\ngateway_job_scope=snapshot_validation_plus_l6_l7_l8_l9_input_primitives_no_layer5_advisory_no_selection_no_permission\r\njob_resource_class=" + AC_EXTERNAL_WORKER_JOB_RESOURCE_CLASS + "\r\njob_max_runtime_ms=" + IntegerToString(AC_EXTERNAL_WORKER_JOB_MAX_RUNTIME_MS) + "\r\nwrite_status=" + snapshot_write.status + "\r\nwrite_ok=" + (snapshot_write.ok ? "true" : "false") + "\r\nupstream_key=" + upstream_key + "\r\nrow_count=" + IntegerToString(AC_EXTERNAL_WORKER_LAST_SNAPSHOT_ROWS) + "\r\npayload_checksum=" + payload_checksum + "\r\nauthority=" + AC_EXTERNAL_WORKER_AUTHORITY + "\r\ntrade_permission=false\r\nranking_runtime=false\r\nselection_runtime=false\r\nl10_runtime2_input_status=" + l10_runtime2_input_write.status + "\r\nl10_runtime2_input_rows=" + IntegerToString(AC_UniverseLoadedRowCount()) + "\r\nl10_runtime2_input_path=" + AC_L10Runtime2UniverseInputPath() + "\r\nl6_input_primitives_status=" + l6_input_write.status + "\r\nl6_input_primitives_rows=" + IntegerToString(AC_L6_LAST_INPUT_ROWS) + "\r\nl6_input_primitives_path=" + AC_L6FrictionInputCsvPath() + "\r\nl7_input_primitives_status=" + l7_input_write.status + "\r\nl7_input_primitives_rows=" + IntegerToString(AC_L7_LAST_INPUT_ROWS) + "\r\nl7_input_primitives_path=" + AC_L7SessionInputCsvPath() + "\r\nl8_input_primitives_status=" + l8_input_write.status + "\r\nl8_input_primitives_rows=" + IntegerToString(AC_L8_LAST_INPUT_ROWS) + "\r\nl8_input_primitives_path=" + AC_L8InputCsvPath() + "\r\nl9_input_primitives_status=" + l9_input_write.status + "\r\nl9_input_primitives_rows=" + IntegerToString(AC_L9_LAST_INPUT_ROWS) + "\r\nl9_input_primitives_path=" + AC_L9InputCsvPath() + "\r\n";
   AC_WriteResult manifest_write = AC_WriteTextFile(AC_ExternalWorkerSnapshotManifestPath(), manifest);
   AC_EXTERNAL_WORKER_LAST_SNAPSHOT_ID = snapshot_id;
   AC_EXTERNAL_WORKER_LAST_JOB_ID = job_id;
   AC_EXTERNAL_WORKER_LAST_JOB_TYPE = AC_EXTERNAL_WORKER_DEFAULT_JOB_TYPE;
   AC_EXTERNAL_WORKER_LAST_JOB_STATUS = snapshot_write.ok && manifest_write.ok ? "exported" : "degraded";
   AC_EXTERNAL_WORKER_LAST_SNAPSHOT_STATUS = snapshot_write.status;
   AC_EXTERNAL_WORKER_LAST_SNAPSHOT_MANIFEST_STATUS = manifest_write.status;
   AC_EXTERNAL_WORKER_LAST_SNAPSHOT_PAYLOAD_CHECKSUM = payload_checksum;
   AC_EXTERNAL_WORKER_LAST_SNAPSHOT_UPSTREAM_KEY = upstream_key;
   AC_EXTERNAL_WORKER_LAST_SNAPSHOT_SIZE = snapshot_write.final_size;
   return snapshot_write;
}

#endif
