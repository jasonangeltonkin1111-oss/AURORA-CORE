#ifndef AC_SHARED_OHLC_MANIFEST_MQH
#define AC_SHARED_OHLC_MANIFEST_MQH

// Manifest/status text helpers for Shared OHLC Raw Storage.
// Manifest proves storage-owner state only. It does not calculate market features.

string AC_SharedOhlcManifestText()
{
   string text = "schema_name=shared_ohlc_raw_storage_manifest\r\n";
   text += "schema_version=" + AC_SHARED_OHLC_SCHEMA_VERSION + "\r\n";
   text += "owner=" + AC_SHARED_OHLC_OWNER_NAME + "\r\n";
   text += "authority=" + AC_SHARED_OHLC_AUTHORITY + "\r\n";
   text += "source_api=" + AC_SHARED_OHLC_SOURCE_API + "\r\n";
   text += "server=" + AC_ServerNameForRoute() + "\r\n";
   text += "route_root=" + AC_SharedOhlcRootFolder() + "\r\n";
   text += "status=" + AC_SHARED_OHLC_STATUS + "\r\n";
   text += "mode=" + AC_SHARED_OHLC_MODE + "\r\n";
   text += "boot_seed_complete=" + (AC_SHARED_OHLC_BOOT_SEED_COMPLETE ? "true" : "false") + "\r\n";
   text += "append_mode_active=" + (AC_SHARED_OHLC_APPEND_MODE_ACTIVE ? "true" : "false") + "\r\n";
   text += "target_seed_bars=" + IntegerToString(AC_SHARED_OHLC_TARGET_SEED_BARS) + "\r\n";
   text += "symbols_total=" + IntegerToString(AC_SHARED_OHLC_SYMBOLS_TOTAL) + "\r\n";
   text += "timeframes_enabled=" + IntegerToString(AC_SHARED_OHLC_TIMEFRAMES_ENABLED) + "\r\n";
   text += "symbol_tf_total=" + IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_TOTAL) + "\r\n";
   text += "symbol_tf_seeded=" + IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_SEEDED) + "\r\n";
   text += "symbol_tf_partial=" + IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_PARTIAL) + "\r\n";
   text += "symbol_tf_pending=" + IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_PENDING) + "\r\n";
   text += "symbol_tf_error=" + IntegerToString(AC_SHARED_OHLC_SYMBOL_TF_ERROR) + "\r\n";
   text += "priority_p1_open_or_pending=" + IntegerToString(AC_SHARED_OHLC_APPEND_BACKLOG_P1) + "\r\n";
   text += "priority_p2_l5_pass=" + IntegerToString(AC_SHARED_OHLC_APPEND_BACKLOG_P2) + "\r\n";
   text += "priority_p3_future_candidate=" + IntegerToString(AC_SHARED_OHLC_APPEND_BACKLOG_P3) + "\r\n";
   text += "priority_p4_other_open=" + IntegerToString(AC_SHARED_OHLC_APPEND_BACKLOG_P4) + "\r\n";
   text += "priority_p5_closed_blocked_unknown=" + IntegerToString(AC_SHARED_OHLC_APPEND_BACKLOG_P5) + "\r\n";
   text += "raw_bars_board_dump=false\r\n";
   text += "raw_bars_dossier_dump=false\r\n";
   text += "future_layers_private_copyrates_allowed=false\r\n";
   text += "gateway_direct_broker_history_fetch_allowed=false\r\n";
   text += "calculation_owner=none_raw_storage_only\r\n";
   text += "trade_permission=false\r\n";
   return text;
}

AC_WriteResult AC_SharedOhlcPublishStatusFiles()
{
   AC_WriteTextFileFastAtomic(AC_SharedOhlcStatusPath(), AC_SharedOhlcStatusRow());
   return AC_WriteTextFileFastAtomic(AC_SharedOhlcManifestPath(), AC_SharedOhlcManifestText());
}

#endif
