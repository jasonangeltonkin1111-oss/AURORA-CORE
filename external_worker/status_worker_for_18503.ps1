$ErrorActionPreference = "Continue"

$TaskName = "AuroraWorker_Upcomers_Server_18503"
$Root = "C:\Users\Jason\AppData\Roaming\MetaQuotes\Terminal\Common\Files\Aurora Core\Upcomers-Server\18503"
$StatusFolder = Join-Path $Root "Workbench\External Worker\Status"
$Heartbeat = Join-Path $StatusFolder "worker_heartbeat.txt"
$ProcessStatus = Join-Path $StatusFolder "worker_process_status.txt"
$InstallStatus = Join-Path $StatusFolder "worker_install_status.txt"

Write-Host "=== Aurora Worker Task ==="
$Task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if ($Task) {
    Write-Host "TaskName=$TaskName"
    Write-Host "TaskState=$($Task.State)"
    Get-ScheduledTaskInfo -TaskName $TaskName | Select-Object LastRunTime, LastTaskResult, NextRunTime, NumberOfMissedRuns | Format-List
} else {
    Write-Host "TaskName=$TaskName"
    Write-Host "TaskState=not_registered"
}

Write-Host "=== AuroraWorker Processes ==="
$Processes = Get-Process AuroraWorker -ErrorAction SilentlyContinue
if ($Processes) {
    $Processes | Select-Object Id, ProcessName, Path, StartTime | Format-List
} else {
    Write-Host "No AuroraWorker process found."
}

Write-Host "=== Install Status ==="
if (Test-Path $InstallStatus) {
    Get-Content $InstallStatus | Select-String "schema_version|installed=|worker_version|scheduled_task_name|scheduled_task_registered|scheduled_task_state|scheduled_task_error|auto_start_configured|authority|trade_permission"
} else {
    Write-Host "worker_install_status.txt missing"
}

Write-Host "=== Process Status ==="
if (Test-Path $ProcessStatus) {
    Get-Content $ProcessStatus | Select-String "worker_version|process_id|mode=|process_start_utc|last_loop_utc|last_loop_unix|loop_count|last_run_exit_code|last_validation_status|last_validation_reason|last_snapshot_id|authority|trade_permission"
} else {
    Write-Host "worker_process_status.txt missing"
}

Write-Host "=== Heartbeat ==="
if (Test-Path $Heartbeat) {
    Get-Content $Heartbeat | Select-String "worker_version|worker_status|last_validation_status|last_validation_reason|last_snapshot_id|generated_utc|generated_unix|authority|trade_permission"
} else {
    Write-Host "worker_heartbeat.txt missing"
}
