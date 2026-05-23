#ifndef AC_SHARED_OHLC_SURFACE_MQH
#define AC_SHARED_OHLC_SURFACE_MQH

// Surface wrappers for Shared OHLC Raw Storage.
// These wrappers lazily initialize the route/status contract before Board, Dossier, or Workbench rendering.
// They do not activate full-universe bar seeding and do not calculate market features.

void AC_SharedOhlcSurfaceEnsureReady()
{
   if(!AC_SHARED_OHLC_READY && AC_SHARED_OHLC_STATUS == "not_started")
   {
      AC_SharedOhlcInit();
      AC_SharedOhlcPublishStatusFiles();
   }
}

string AC_SharedOhlcRenderBoardSection()
{
   AC_SharedOhlcSurfaceEnsureReady();
   return AC_SharedOhlcBoardSection();
}

string AC_SharedOhlcRenderDossierSection(const string symbol)
{
   AC_SharedOhlcSurfaceEnsureReady();
   return AC_SharedOhlcDossierSection(symbol);
}

string AC_SharedOhlcRenderWorkbenchSection()
{
   AC_SharedOhlcSurfaceEnsureReady();
   return AC_SharedOhlcWorkbenchSection();
}

#endif
