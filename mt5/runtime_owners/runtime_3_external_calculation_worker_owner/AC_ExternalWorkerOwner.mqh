#ifndef AC_EXTERNAL_WORKER_OWNER_MQH
#define AC_EXTERNAL_WORKER_OWNER_MQH

// Runtime 3 / Calculation Gateway Owner.
// Legacy AC_ExternalWorker* filenames and symbols are retained for compile-safe compatibility.
// Operator-facing surfaces should call this Gateway.
// Owns only Gateway relationship/control/status/snapshot export/result validation.

#include "AC_ExternalWorkerTypes.mqh"
#include "AC_ExternalWorkerState.mqh"
#include "AC_ExternalWorkerSnapshot.mqh"
#include "AC_ExternalWorkerResult.mqh"
#include "AC_ExternalWorkerResultEnvelope.mqh"
#include "AC_ExternalWorkerRender.mqh"
#include "AC_ExternalWorkerSharedRender.mqh"
#include "AC_ExternalWorkerControl.mqh"

#endif