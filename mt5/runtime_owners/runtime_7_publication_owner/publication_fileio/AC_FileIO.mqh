#ifndef AC_FILEIO_MQH
#define AC_FILEIO_MQH

#include "../../../core/AC_CommonTypes.mqh"
#include "../publication_routes/AC_ServerPaths.mqh"

string AC_WriteStatusFromResult(const AC_WriteResult &result)
{
   if(result.ok)
      return "file_written_clean";
   if(!result.temp_open_ok)
      return "temp_open_failed";
   if(!result.temp_write_ok)
      return "temp_write_failed";
   if(!result.move_ok)
      return "move_failed";
   if(!result.final_exists)
      return "verify_failed";
   return "failed";
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
   result.final_size = -1;
   result.error_code = 0;
   result.status = "attempted";
   result.detail = "";
   result.final_path = final_path;
   result.temp_path = final_path + ".tmp";

   ResetLastError();
   int handle = FileOpen(result.temp_path, AC_FileFlags() | FILE_WRITE | FILE_REWRITE);
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
   if(written < StringLen(content))
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

   ResetLastError();
   if(!FileMove(result.temp_path, 0, result.final_path, FILE_REWRITE | (AC_USE_COMMON_FILES ? FILE_COMMON : 0)))
   {
      result.error_code = GetLastError();
      result.status = "move_failed";
      result.detail = "FileMove temp to final failed";
      return result;
   }
   result.move_ok = true;

   ResetLastError();
   result.final_exists = FileIsExist(result.final_path, AC_USE_COMMON_FILES ? FILE_COMMON : 0);
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
      result.final_size = -1;
   }

   result.ok = true;
   result.status = "file_written_clean";
   result.detail = "write_verified";
   return result;
}

string AC_WriteResultLine(const string surface, const AC_WriteResult &result)
{
   return surface
      + "|status=" + AC_WriteStatusFromResult(result)
      + "|ok=" + (result.ok ? "true" : "false")
      + "|final_exists=" + (result.final_exists ? "true" : "false")
      + "|final_size=" + IntegerToString((int)result.final_size)
      + "|error=" + IntegerToString(result.error_code)
      + "|final_path=" + result.final_path;
}

#endif
