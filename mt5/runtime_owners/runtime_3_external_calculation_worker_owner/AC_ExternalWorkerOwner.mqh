#ifndef AC_EXTERNAL_WORKER_OWNER_MQH
#define AC_EXTERNAL_WORKER_OWNER_MQH

// Runtime 3 / Calculation Gateway Owner.
// Legacy AC_ExternalWorker* filenames and symbols are retained for compile-safe compatibility.
// Operator-facing surfaces should call this Gateway. Physical External Worker folders remain
// legacy-compatible until a separate folder migration is runtime-proven.
// Owns only Gateway relationship/control/status/snapshot export/result validation. It never owns broker truth,
// FileIO internals, Board/Dossier rendering authority, ranking, selection,
// trade permission, execution, WebRequest, or Python live broker authority.

#include "AC_ExternalWorkerTypes.mqh"
#include "AC_ExternalWorkerState.mqh"
#include "AC_ExternalWorkerSnapshot.mqh"
#include "AC_ExternalWorkerResult.mqh"
#include "AC_ExternalWorkerRender.mqh"
#include "AC_ExternalWorkerSharedRender.mqh"
#include "AC_ExternalWorkerControl.mqh"

#endif