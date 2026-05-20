#ifndef AC_MARKET_UNIVERSE_MQH
#define AC_MARKET_UNIVERSE_MQH

// Runtime 2 - Market Universe / Taxonomy Lookup Owner
// Skeleton only. No 1703-row universe copy is imported in this step.
// Dependencies are included by mt5/AuroraCore.mq5 using root includes.

static const string AC_RUNTIME2_OWNER = "Runtime 2 - Market Universe / Taxonomy Lookup Owner";
static const string AC_UNIVERSE_SCHEMA_VERSION = "universe_lookup_contract_v0.1";
static const string AC_UNIVERSE_SOURCE_WORKBOOK = "Aurora_Bucket_System_Hierarchy_EA_READY_PUBLIC_RESEARCH_FIXED.xlsx";
static const string AC_UNIVERSE_SOURCE_SHEET = "EA Export Safe";
static const int    AC_UNIVERSE_EXPECTED_ROWS = 1703;
static const int    AC_UNIVERSE_EXPECTED_STRICT_RANK_ALLOWED = 1294;
static const int    AC_UNIVERSE_EXPECTED_PUBLIC_RESEARCH_RANK_ALLOWED = 224;
static const int    AC_UNIVERSE_EXPECTED_REVIEW_ONLY = 184;
static const int    AC_UNIVERSE_EXPECTED_BLOCKED = 1;

string AC_UniverseLookupKeySchema()
{
   return "server|broker_file|broker_symbol";
}

string AC_UniverseTaxonomyContract()
{
   return "asset_class -> market_group -> market_segment -> symbol; ranking_group is selection/cap/diversification grouping field";
}

string AC_UniverseRuntimePermission()
{
   return "LOOKUP_ONLY_NOT_TRADE_PERMISSION";
}

int AC_UniverseLoadedRowCount()
{
   // Step 2 skeleton only. The generated 1703-row copy is intentionally not landed yet.
   return 0;
}

int AC_UniverseStrictRankAllowedCount()
{
   return 0;
}

int AC_UniversePublicResearchRankAllowedCount()
{
   return 0;
}

int AC_UniverseReviewOnlyCount()
{
   return 0;
}

int AC_UniverseBlockedCount()
{
   return 0;
}

bool AC_UniverseRowsGenerated()
{
   return false;
}

string AC_UniverseContractStatus()
{
   return AC_UniverseRowsGenerated() ? "generated_copy_present" : "skeleton_only_rows_not_imported";
}

string AC_UniverseDiagnosticsText()
{
   string text = "";
   text += "schema_name=market_universe_lookup\r\n";
   text += "schema_version=" + AC_UNIVERSE_SCHEMA_VERSION + "\r\n";
   text += "source_owner=" + AC_RUNTIME2_OWNER + "\r\n";
   text += "source_workbook=" + AC_UNIVERSE_SOURCE_WORKBOOK + "\r\n";
   text += "source_sheet=" + AC_UNIVERSE_SOURCE_SHEET + "\r\n";
   text += "source_row_count_expected=" + IntegerToString(AC_UNIVERSE_EXPECTED_ROWS) + "\r\n";
   text += "loaded_row_count=" + IntegerToString(AC_UniverseLoadedRowCount()) + "\r\n";
   text += "strict_rank_allowed_count=" + IntegerToString(AC_UniverseStrictRankAllowedCount()) + "\r\n";
   text += "public_research_rank_allowed_count=" + IntegerToString(AC_UniversePublicResearchRankAllowedCount()) + "\r\n";
   text += "review_only_count=" + IntegerToString(AC_UniverseReviewOnlyCount()) + "\r\n";
   text += "blocked_count=" + IntegerToString(AC_UniverseBlockedCount()) + "\r\n";
   text += "expected_strict_rank_allowed_count=" + IntegerToString(AC_UNIVERSE_EXPECTED_STRICT_RANK_ALLOWED) + "\r\n";
   text += "expected_public_research_rank_allowed_count=" + IntegerToString(AC_UNIVERSE_EXPECTED_PUBLIC_RESEARCH_RANK_ALLOWED) + "\r\n";
   text += "expected_review_only_count=" + IntegerToString(AC_UNIVERSE_EXPECTED_REVIEW_ONLY) + "\r\n";
   text += "expected_blocked_count=" + IntegerToString(AC_UNIVERSE_EXPECTED_BLOCKED) + "\r\n";
   text += "lookup_key_schema=" + AC_UniverseLookupKeySchema() + "\r\n";
   text += "taxonomy_contract=" + AC_UniverseTaxonomyContract() + "\r\n";
   text += "translation_contract_status=" + AC_UniverseContractStatus() + "\r\n";
   text += "old_field_names_active=false\r\n";
   text += "runtime_permission=" + AC_UniverseRuntimePermission() + "\r\n";
   text += "ranking_group_runtime=false\r\n";
   text += "selection_logic_runtime=false\r\n";
   text += "trade_permission=false\r\n";
   return text;
}

string AC_UniverseStatusRow()
{
   return "schema_name=market_universe_lookup_status|schema_version=" + AC_UNIVERSE_SCHEMA_VERSION
      + "|source_owner=" + AC_RUNTIME2_OWNER
      + "|source_workbook=" + AC_UNIVERSE_SOURCE_WORKBOOK
      + "|source_sheet=" + AC_UNIVERSE_SOURCE_SHEET
      + "|expected_rows=" + IntegerToString(AC_UNIVERSE_EXPECTED_ROWS)
      + "|loaded_rows=" + IntegerToString(AC_UniverseLoadedRowCount())
      + "|contract_status=" + AC_UniverseContractStatus()
      + "|old_field_names_active=false"
      + "|runtime_permission=" + AC_UniverseRuntimePermission();
}

#endif
