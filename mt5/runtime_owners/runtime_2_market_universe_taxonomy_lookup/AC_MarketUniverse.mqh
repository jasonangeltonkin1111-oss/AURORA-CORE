#ifndef AC_MARKET_UNIVERSE_MQH
#define AC_MARKET_UNIVERSE_MQH

// Runtime 2 - Market Universe / Taxonomy Lookup Owner
// Generated lookup rows are present as static lookup source.
// Runtime 2 remains lookup-only; this is not ranking runtime, not selection runtime, and not trade permission.
// Compile/runtime loading remains unproven until MetaEditor/runtime evidence exists.
// Dependencies are included by mt5/AuroraCore.mq5 using root includes.

#include "AC_MarketUniverseRows.mqh"

static const string AC_RUNTIME2_OWNER = "Runtime 2 - Market Universe / Taxonomy Lookup Owner";
static const string AC_UNIVERSE_SCHEMA_VERSION = "universe_lookup_contract_v0.2";
static const string AC_UNIVERSE_SOURCE_WORKBOOK = "Aurora_Bucket_System_Hierarchy_EA_READY_PUBLIC_RESEARCH_FIXED.xlsx";
static const string AC_UNIVERSE_SOURCE_SHEET = "EA Export Safe";
static const int    AC_UNIVERSE_EXPECTED_ROWS = 1703;
static const int    AC_UNIVERSE_EXPECTED_STRICT_RANK_ALLOWED = 1294;
static const int    AC_UNIVERSE_EXPECTED_PUBLIC_RESEARCH_RANK_ALLOWED = 224;
static const int    AC_UNIVERSE_EXPECTED_REVIEW_ONLY = 184;
static const int    AC_UNIVERSE_EXPECTED_BLOCKED = 1;

string AC_UniverseLookupKeySchema()
{
   return AC_UNIVERSE_LOOKUP_KEY_SCHEMA;
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
   return AC_UNIVERSE_GENERATED_ROW_COUNT;
}

int AC_UniverseStrictRankAllowedCount()
{
   return AC_UNIVERSE_GENERATED_STRICT_RANK_ALLOWED;
}

int AC_UniversePublicResearchRankAllowedCount()
{
   return AC_UNIVERSE_GENERATED_PUBLIC_RESEARCH_RANK_ALLOWED;
}

int AC_UniverseReviewOnlyCount()
{
   return AC_UNIVERSE_GENERATED_REVIEW_ONLY;
}

int AC_UniverseBlockedCount()
{
   return AC_UNIVERSE_GENERATED_BLOCKED;
}

bool AC_UniverseRowsGenerated()
{
   return true;
}

string AC_UniverseGeneratedRowByIndex(const int index)
{
   if(index < 0 || index >= AC_UNIVERSE_GENERATED_ROW_COUNT)
      return "";
   return AC_UniverseGeneratedRow(index);
}

string AC_UniverseContractStatus()
{
   return "generated_copy_present_lookup_only";
}

string AC_UniverseDiagnosticsText()
{
   string text = "";
   text += "schema_name=market_universe_lookup\r\n";
   text += "schema_version=" + AC_UNIVERSE_SCHEMA_VERSION + "\r\n";
   text += "source_owner=" + AC_RUNTIME2_OWNER + "\r\n";
   text += "source_workbook=" + AC_UNIVERSE_SOURCE_WORKBOOK + "\r\n";
   text += "source_sheet=" + AC_UNIVERSE_SOURCE_SHEET + "\r\n";
   text += "generated_schema_version=" + AC_UNIVERSE_GENERATED_SCHEMA_VERSION + "\r\n";
   text += "source_row_count_expected=" + IntegerToString(AC_UNIVERSE_EXPECTED_ROWS) + "\r\n";
   text += "source_row_count=" + IntegerToString(AC_UNIVERSE_SOURCE_ROW_COUNT) + "\r\n";
   text += "generated_source_row_count=" + IntegerToString(AC_UNIVERSE_SOURCE_ROW_COUNT) + "\r\n";
   text += "loaded_row_count=" + IntegerToString(AC_UniverseLoadedRowCount()) + "\r\n";
   text += "generated_row_count=" + IntegerToString(AC_UNIVERSE_GENERATED_ROW_COUNT) + "\r\n";
   text += "operator_omit_count=" + IntegerToString(AC_UNIVERSE_OPERATOR_OMIT_COUNT) + "\r\n";
   text += "strict_rank_allowed_count=" + IntegerToString(AC_UniverseStrictRankAllowedCount()) + "\r\n";
   text += "public_research_rank_allowed_count=" + IntegerToString(AC_UniversePublicResearchRankAllowedCount()) + "\r\n";
   text += "review_only_count=" + IntegerToString(AC_UniverseReviewOnlyCount()) + "\r\n";
   text += "blocked_count=" + IntegerToString(AC_UniverseBlockedCount()) + "\r\n";
   text += "generated_strict_rank_allowed=" + IntegerToString(AC_UNIVERSE_GENERATED_STRICT_RANK_ALLOWED) + "\r\n";
   text += "generated_public_research_rank_allowed=" + IntegerToString(AC_UNIVERSE_GENERATED_PUBLIC_RESEARCH_RANK_ALLOWED) + "\r\n";
   text += "generated_review_only=" + IntegerToString(AC_UNIVERSE_GENERATED_REVIEW_ONLY) + "\r\n";
   text += "generated_blocked=" + IntegerToString(AC_UNIVERSE_GENERATED_BLOCKED) + "\r\n";
   text += "generated_duplicate_primary_keys=" + IntegerToString(AC_UNIVERSE_GENERATED_DUPLICATE_PRIMARY_KEYS) + "\r\n";
   text += "expected_strict_rank_allowed_count=" + IntegerToString(AC_UNIVERSE_EXPECTED_STRICT_RANK_ALLOWED) + "\r\n";
   text += "expected_public_research_rank_allowed_count=" + IntegerToString(AC_UNIVERSE_EXPECTED_PUBLIC_RESEARCH_RANK_ALLOWED) + "\r\n";
   text += "expected_review_only_count=" + IntegerToString(AC_UNIVERSE_EXPECTED_REVIEW_ONLY) + "\r\n";
   text += "expected_blocked_count=" + IntegerToString(AC_UNIVERSE_EXPECTED_BLOCKED) + "\r\n";
   text += "row_schema=" + AC_UNIVERSE_ROW_SCHEMA + "\r\n";
   text += "row_schema_sha256=" + AC_UNIVERSE_ROW_SCHEMA_SHA256 + "\r\n";
   text += "source_file_sha256=" + AC_UNIVERSE_SOURCE_FILE_SHA256 + "\r\n";
   text += "lookup_key_schema=" + AC_UniverseLookupKeySchema() + "\r\n";
   text += "taxonomy_contract=" + AC_UniverseTaxonomyContract() + "\r\n";
   text += "generated_copy_present=true\r\n";
   text += "translation_contract_status=" + AC_UniverseContractStatus() + "\r\n";
   text += "old_field_names_active=false\r\n";
   text += "old_bucket_wording_scope=generated_source_provenance_only_not_active_runtime_label\r\n";
   text += "runtime_permission=" + AC_UniverseRuntimePermission() + "\r\n";
   text += "ranking_group_runtime=false\r\n";
   text += "selection_logic_runtime=false\r\n";
   text += "trade_permission=false\r\n";
   text += "compile_proof=false\r\n";
   text += "runtime_loaded_proof=false\r\n";
   return text;
}

string AC_UniverseStatusRow()
{
   return "schema_name=market_universe_lookup_status|schema_version=" + AC_UNIVERSE_SCHEMA_VERSION
      + "|source_owner=" + AC_RUNTIME2_OWNER
      + "|source_workbook=" + AC_UNIVERSE_SOURCE_WORKBOOK
      + "|source_sheet=" + AC_UNIVERSE_SOURCE_SHEET
      + "|generated_schema_version=" + AC_UNIVERSE_GENERATED_SCHEMA_VERSION
      + "|source_row_count=" + IntegerToString(AC_UNIVERSE_SOURCE_ROW_COUNT)
      + "|generated_source_row_count=" + IntegerToString(AC_UNIVERSE_SOURCE_ROW_COUNT)
      + "|generated_row_count=" + IntegerToString(AC_UNIVERSE_GENERATED_ROW_COUNT)
      + "|operator_omit_count=" + IntegerToString(AC_UNIVERSE_OPERATOR_OMIT_COUNT)
      + "|expected_rows=" + IntegerToString(AC_UNIVERSE_EXPECTED_ROWS)
      + "|loaded_rows=" + IntegerToString(AC_UniverseLoadedRowCount())
      + "|generated_strict_rank_allowed=" + IntegerToString(AC_UNIVERSE_GENERATED_STRICT_RANK_ALLOWED)
      + "|generated_public_research_rank_allowed=" + IntegerToString(AC_UNIVERSE_GENERATED_PUBLIC_RESEARCH_RANK_ALLOWED)
      + "|generated_review_only=" + IntegerToString(AC_UNIVERSE_GENERATED_REVIEW_ONLY)
      + "|generated_blocked=" + IntegerToString(AC_UNIVERSE_GENERATED_BLOCKED)
      + "|generated_duplicate_primary_keys=" + IntegerToString(AC_UNIVERSE_GENERATED_DUPLICATE_PRIMARY_KEYS)
      + "|row_schema_sha256=" + AC_UNIVERSE_ROW_SCHEMA_SHA256
      + "|source_file_sha256=" + AC_UNIVERSE_SOURCE_FILE_SHA256
      + "|contract_status=" + AC_UniverseContractStatus()
      + "|old_field_names_active=false"
      + "|generated_copy_present=true"
      + "|runtime_permission=" + AC_UniverseRuntimePermission()
      + "|ranking_group_runtime=false|selection_logic_runtime=false|trade_permission=false|compile_proof=false|runtime_loaded_proof=false";
}

#endif
