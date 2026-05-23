#ifndef AC_SHARED_OHLC_LEGACY_ALIASES_MQH
#define AC_SHARED_OHLC_LEGACY_ALIASES_MQH

// Runtime 1 Shared OHLC compatibility aliases.
// Purpose: keep older renderer/source-key references compiling while the active owner terminology is now priority-window based.
// These aliases do not create a second owner or second storage surface.

#define AC_SHARED_OHLC_L8_FAST_READY AC_SHARED_OHLC_WINDOW_READY
#define AC_SHARED_OHLC_L8_FAST_TOTAL AC_SHARED_OHLC_WINDOW_TOTAL
#define AC_SHARED_OHLC_L8_FAST_ATTEMPTED AC_SHARED_OHLC_WINDOW_ATTEMPTED
#define AC_SHARED_OHLC_L8_FAST_ERROR AC_SHARED_OHLC_WINDOW_ERROR

#endif
