$ErrorActionPreference = "Continue"
$root = Join-Path $env:APPDATA "MetaQuotes\Terminal\Common\Files\Aurora Core"
$statusDir = Join-Path $root "External Worker\Status"
$install = Join-Path $statusDir "shared_worker_install_status.txt"
$shared = Join-Path $statusDir "shared_worker_status.txt"
$daemonTask = "AuroraWorker_Global"; $watchTask = "AuroraWorker_Global_Watchdog"

Write-Host "=== Scheduled Tasks ==="
$daemonRegistered = $false
$watchdogRegistered = $false
$daemonState = "not_registered"
$watchdogState = "not_registered"
foreach($t in @($daemonTask,$watchTask)){
  $task = Get-ScheduledTask -TaskName $t -ErrorAction SilentlyContinue
  if($task){
    if($t -eq $daemonTask){ $daemonRegistered = $true; $daemonState = $task.State.ToString() }
    if($t -eq $watchTask){ $watchdogRegistered = $true; $watchdogState = $task.State.ToString() }
    Write-Host "$t registered=true state=$($task.State)"; Get-ScheduledTaskInfo -TaskName $t | Format-List LastRunTime,LastTaskResult,NextRunTime
  }
  else { Write-Host "$t registered=false state=not_registered" }
}
$procCount = @(Get-Process AuroraWorker -ErrorAction SilentlyContinue).Count
$operatorRequired = if($daemonRegistered -and $watchdogRegistered -and $procCount -ge 1){"false"}else{"true"}
Write-Host "AuroraWorker processes: $procCount"
Write-Host "operator_cmd_required(actual)=$operatorRequired"

function Show-Fields($path,$fields){ if(Test-Path $path){$c=Get-Content $path; foreach($f in $fields){$m=$c|Where-Object{$_ -like "$f=*"}|Select-Object -First 1; if($m){Write-Host $m}else{Write-Host "$f=not_found"}} } else {Write-Host "missing: $path"}}
Write-Host "=== Install Proof ==="
Show-Fields $install @('schema_version','installed','worker_version','scheduled_task_registered','scheduled_task_state','watchdog_task_registered','watchdog_task_state','operator_cmd_required','authority','trade_permission')
Write-Host "=== Shared Status ==="
Show-Fields $shared @('schema_version','worker_version','daemon_task_registered','daemon_task_state','watchdog_task_registered','watchdog_task_state','watchdog_last_check_utc','watchdog_last_action','watchdog_last_reason','watchdog_restart_attempted','watchdog_restart_result','operator_cmd_required','cpu_logical_count','cpu_used_percent','memory_total_mb','memory_available_mb','memory_used_percent','memory_limit_percent','cpu_limit_percent','terminal_process_count','aurora_worker_process_count','registered_root_count','resource_throttle_active','resource_throttle_reason','recommended_parallel_jobs','authority','trade_permission')
