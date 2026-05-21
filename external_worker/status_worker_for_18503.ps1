$ErrorActionPreference = "Continue"

$TaskName = "AuroraWorker_Global"
$SharedRoot = "C:\Users\Jason\AppData\Roaming\MetaQuotes\Terminal\Common\Files\Aurora Core"
$SharedStatusFolder = Join-Path $SharedRoot "External Worker\Status"
$SharedStatus = Join-Path $SharedStatusFolder "shared_worker_status.txt"
$InstallStatus = Join-Path $SharedStatusFolder "shared_worker_install_status.txt"

Write-Host "=== Aurora Shared Worker Task ==="
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

Write-Host "=== Shared Install Status ==="
if (Test-Path $InstallStatus) {
    Get-Content $InstallStatus | Select-String "schema_version|installed=|worker_version|shared_daemon|shared_root|scheduled_task_name|scheduled_task_registered|scheduled_task_state|scheduled_task_error|auto_start_configured|authority|trade_permission"
} else {
    Write-Host "shared_worker_install_status.txt missing"
}

Write-Host "=== Shared Supervisor Status ==="
if (Test-Path $SharedStatus) {
    Get-Content $SharedStatus | Select-String "worker_version|mode=|loop_count|discovered_root_count|processed_root_count|accepted_root_count|degraded_root_count|authority|trade_permission"
} else {
    Write-Host "shared_worker_status.txt missing"
}
