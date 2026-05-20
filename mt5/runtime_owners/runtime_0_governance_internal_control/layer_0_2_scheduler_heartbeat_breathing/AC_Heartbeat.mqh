#ifndef AC_HEARTBEAT_MQH
#define AC_HEARTBEAT_MQH

#include "../../../core/AC_Config.mqh"
#include "../../../core/AC_CommonTypes.mqh"

long AC_HEARTBEAT_ID = 0;

void AC_HeartbeatBegin(AC_Runtime0Snapshot &snapshot)
{
   AC_HEARTBEAT_ID++;
   snapshot.heartbeat_id = AC_HEARTBEAT_ID;
   snapshot.timer_started_ms = GetTickCount();
   snapshot.generated_at = TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS);
   snapshot.runtime_state = "heartbeat_started";
}

void AC_HeartbeatFinish(AC_Runtime0Snapshot &snapshot)
{
   snapshot.timer_finished_ms = GetTickCount();
   snapshot.timer_duration_ms = snapshot.timer_finished_ms - snapshot.timer_started_ms;
   snapshot.over_budget = (snapshot.timer_duration_ms > AC_TIMER_BUDGET_MS);
   snapshot.runtime_state = snapshot.over_budget ? "heartbeat_over_budget" : "heartbeat_ok";
}

string AC_HeartbeatStatusText(const AC_Runtime0Snapshot &snapshot)
{
   string text = "";
   text += "heartbeat_id=" + IntegerToString((int)snapshot.heartbeat_id) + "\r\n";
   text += "timer_duration_ms=" + IntegerToString((int)snapshot.timer_duration_ms) + "\r\n";
   text += "timer_budget_ms=" + IntegerToString((int)AC_TIMER_BUDGET_MS) + "\r\n";
   text += "over_budget_flag=" + (snapshot.over_budget ? "true" : "false") + "\r\n";
   return text;
}

#endif
