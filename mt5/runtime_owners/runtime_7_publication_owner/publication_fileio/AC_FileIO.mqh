#ifndef AC_FILEIO_MQH
#define AC_FILEIO_MQH

// Dependencies are included by mt5/AuroraCore.mq5 using root includes.
// Publication / FileIO / Route Service owns atomic file writes, unchanged-skip writes, and safe file cleanup only.
// It does not own routes, types, or trading truth.

string AC_WriteStatusFromResult(const AC_WriteResult &result)
{
   if(result.ok)
      return result.status;
   if(result.status == "flush_failed")
      return "flush_failed";
   if(result.status == "unchanged_no_write")
      return "unchanged_no_write";
   if(!result.temp_open_ok)
      return "temp_open_failed";
   if(!result.temp_write_ok)
      return "temp_write_failed";
   if(!result.move_ok)
      return "move_failed";
   if(!result.final_exists)
      return "verify_failed";
   if(result.status != "")
      return result.status;
   return "failed";
}

AC_WriteResult AC_MakeSyntheticWriteResult(const string surface_path,
                                           const bool ok,
                                           const string status,
                                           const ulong final_size,
                                           const string detail)
{
   AC_WriteResult result;
   result.attempted = true;
   result.ok = ok;
   result.temp_open_ok = ok;
   result.temp_write_ok = ok;
   result.move_ok = ok;
   result.final_exists = ok;
   result.final_size = final_size;
   result.error_code = 0;
   result.status = status;
   result.detail = detail;
   result.final_path = surface_path;
   result.temp_path = "";
   return result;
}

string AC_ReadTextFileBounded(const string path, const int max_chars = 300000)
{
   int common_flag = AC_USE_COMMON_FILES ? FILE_COMMON : 0;
   if(!FileIsExist(path, common_flag)) return "";
   ResetLastError();
   int handle = FileOpen(path, AC_FileFlags() | FILE_READ);
   if(handle == INVALID_HANDLE) return "";
   string text = "";
   while(!FileIsEnding(handle) && StringLen(text) < max_chars)
   {
      string line = FileReadString(handle);
      text += line;
      if(!FileIsEnding(handle)) text += "\r\n";
   }
   FileClose(handle);
   if(StringLen(text) > max_chars) text = StringSubstr(text, 0, max_chars);
   return text;
}

AC_WriteResult AC_WriteTextFile(const string final_path, const string content)
{
   AC_WriteResult result;
   result.attempted = true;
   result.ok = false;
   result.temp_open_ok = false;
   result.temp_write_ok = false;
   result.move_ok = false;
   result.final_exists = false;
   result.final_size = 0;
   result.error_code = 0;
   result.status = "attempted";
   result.detail = "";
   result.final_path = final_path;
   result.temp_path = final_path + ".tmp";

   ResetLastError();
   int handle = FileOpen(result.temp_path, AC_FileFlags() | FILE_WRITE);
   if(handle == INVALID_HANDLE)
   {
      result.error_code = GetLastError();
      result.status = "temp_open_failed";
      result.detail = "FileOpen temp failed";
      return result;
   }
   result.temp_open_ok = true;

   ResetLastError();
   uint written = FileWriteString(handle, content);
   uint expected = (uint)StringLen(content);
   if(written < expected)
   {
      result.error_code = GetLastError();
      result.status = "temp_write_failed";
      result.detail = "FileWriteString short write";
      FileClose(handle);
      return result;
   }
   result.temp_write_ok = true;

   ResetLastError();
   FileFlush(handle);
   int flush_error = GetLastError();
   FileClose(handle);

   if(flush_error != 0)
   {
      result.error_code = flush_error;
      result.status = "flush_failed";
      result.detail = "FileFlush reported error";
      return result;
   }

   int common_flag = AC_USE_COMMON_FILES ? FILE_COMMON : 0;

   ResetLastError();
   if(!FileMove(result.temp_path, common_flag, result.final_path, FILE_REWRITE | common_flag))
   {
      result.error_code = GetLastError();
      result.status = "move_failed";
      result.detail = "FileMove temp to final failed";
      return result;
   }
   result.move_ok = true;

   ResetLastError();
   result.final_exists = FileIsExist(result.final_path, common_flag);
   if(!result.final_exists)
   {
      result.error_code = GetLastError();
      result.status = "verify_failed";
      result.detail = "Final file does not exist after move";
      return result;
   }

   ResetLastError();
   int read_handle = FileOpen(result.final_path, AC_FileFlags() | FILE_READ);
   if(read_handle != INVALID_HANDLE)
   {
      result.final_size = FileSize(read_handle);
      FileClose(read_handle);
   }
   else
   {
      result.error_code = GetLastError();
      result.final_size = 0;
   }

   result.ok = true;
   result.status = "file_written_clean";
   result.detail = "write_verified";
   return result;
}

AC_WriteResult AC_WriteTextFileFastAtomic(const string final_path, const string content)
{
   AC_WriteResult result;
   result.attempted = true;
   result.ok = false;
   result.temp_open_ok = false;
   result.temp_write_ok = false;
   result.move_ok = false;
   result.final_exists = false;
   result.final_size = 0;
   result.error_code = 0;
   result.status = "attempted";
   result.detail = "";
   result.final_path = final_path;
   result.temp_path = final_path + ".tmp";

   ResetLastError();
   int handle = FileOpen(result.temp_path, AC_FileFlags() | FILE_WRITE);
   if(handle == INVALID_HANDLE)
   {
      result.error_code = GetLastError();
      result.status = "temp_open_failed";
      result.detail = "Fast atomic FileOpen temp failed";
      return result;
   }
   result.temp_open_ok = true;

   ResetLastError();
   uint written = FileWriteString(handle, content);
   uint expected = (uint)StringLen(content);
   if(written < expected)
   {
      result.error_code = GetLastError();
      result.status = "temp_write_failed";
      result.detail = "Fast atomic FileWriteString short write";
      FileClose(handle);
      return result;
   }
   result.temp_write_ok = true;
   FileClose(handle);

   int common_flag = AC_USE_COMMON_FILES ? FILE_COMMON : 0;
   ResetLastError();
   if(!FileMove(result.temp_path, common_flag, result.final_path, FILE_REWRITE | common_flag))
   {
      result.error_code = GetLastError();
      result.status = "move_failed";
      result.detail = "Fast atomic FileMove temp to final failed";
      return result;
   }
   result.move_ok = true;

   ResetLastError();
   result.final_exists = FileIsExist(result.final_path, common_flag);
   if(!result.final_exists)
   {
      result.error_code = GetLastError();
      result.status = "verify_failed";
      result.detail = "Fast atomic final file missing after move";
      return result;
   }

   result.ok = true;
   result.status = "file_written_clean";
   result.detail = "fast_atomic_write_verified_exists_no_flush_no_size_probe";
   result.final_size = (ulong)StringLen(content);
   return result;
}

AC_WriteResult AC_WriteTextFileFastAtomicIfChanged(const string final_path,
                                                   const string content,
                                                   const string reason = "content_compare")
{
   int common_flag = AC_USE_COMMON_FILES ? FILE_COMMON : 0;
   if(FileIsExist(final_path, common_flag))
   {
      string existing = AC_ReadTextFileBounded(final_path, MathMax(300000, StringLen(content) + 4096));
      if(existing == content)
         return AC_MakeSyntheticWriteResult(final_path, true, "unchanged_no_write", (ulong)StringLen(content), reason + "|existing_content_identical_atomic_move_skipped");
   }
   return AC_WriteTextFileFastAtomic(final_path, content);
}

AC_WriteResult AC_WriteTextFileIfChanged(const string final_path,
                                         const string content,
                                         string &last_content,
                                         const bool force_write = false)
{
   if(!force_write && last_content == content)
      return AC_MakeSyntheticWriteResult(final_path, true, "unchanged_no_write", (ulong)StringLen(content), "content_unchanged_atomic_move_skipped");

   AC_WriteResult result = AC_WriteTextFile(final_path, content);
   if(result.ok)
      last_content = content;
   return result;
}

AC_WriteResult AC_DeleteFileIfExists(const string final_path)
{
   int common_flag = AC_USE_COMMON_FILES ? FILE_COMMON : 0;
   if(!FileIsExist(final_path, common_flag))
      return AC_MakeSyntheticWriteResult(final_path, true, "not_present_no_delete", 0, "cleanup_not_needed");

   AC_WriteResult result;
   result.attempted = true;
   result.ok = false;
   result.temp_open_ok = true;
   result.temp_write_ok = true;
   result.move_ok = false;
   result.final_exists = true;
   result.final_size = 0;
   result.error_code = 0;
   result.status = "delete_attempted";
   result.detail = "";
   result.final_path = final_path;
   result.temp_path = "";

   ResetLastError();
   if(!FileDelete(final_path, common_flag))
   {
      result.error_code = GetLastError();
      result.status = "delete_failed";
      result.detail = "FileDelete failed";
      return result;
   }

   result.final_exists = FileIsExist(final_path, common_flag);
   result.ok = !result.final_exists;
   result.move_ok = result.ok;
   result.status = result.ok ? "deleted" : "delete_verify_failed";
   result.detail = result.ok ? "file_deleted" : "file_still_exists_after_delete";
   return result;
}

#endif
