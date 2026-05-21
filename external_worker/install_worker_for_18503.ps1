$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BuiltWorker = Join-Path $ScriptDir "dist\AuroraWorker"
$TargetRoot = "C:\Users\Jason\AppData\Roaming\MetaQuotes\Terminal\Common\Files\Aurora Core\Upcomers-Server\18503"
$TargetExternalWorker = Join-Path $TargetRoot "Workbench\External Worker"
$TargetWorkerRoot = Join-Path $TargetExternalWorker "AuroraWorker"
$TargetExeFlat = Join-Path $TargetExternalWorker "AuroraWorker.exe"
$TargetStatus = Join-Path $TargetExternalWorker "Status"
$InstallStatusPath = Join-Path $TargetStatus "worker_install_status.txt"
$TaskName = "AuroraWorker_Upcomers_Server_18503"

if (!(Test-Path $BuiltWorker)) {
    throw "Built worker folder not found: $BuiltWorker. Run build_worker.ps1 first."
}

New-Item -ItemType Directory -Force -Path $TargetWorkerRoot | Out-Null
New-Item -ItemType Directory -Force -Path $TargetStatus | Out-Null
Copy-Item -Path (Join-Path $BuiltWorker "*") -Destination $TargetWorkerRoot -Recurse -Force

$BuiltExe = Join-Path $TargetWorkerRoot "AuroraWorker.exe"
if (!(Test-Path $BuiltExe)) {
    throw "Install failed: AuroraWorker.exe missing after copy."
}

# Flat copy remains for diagnostic compatibility. Runtime truth comes from worker_install_status.txt.
Copy-Item -Path $BuiltExe -Destination $TargetExeFlat -Force

$ScheduledTaskRegistered = $false
$ScheduledTaskState = "not_registered"
$ScheduledTaskError = "none"
try {
    $Action = New-ScheduledTaskAction -Execute $BuiltExe -Argument "--root `"$TargetRoot`" --mode daemon --poll-seconds 1" -WorkingDirectory $TargetWorkerRoot
    $Trigger = New-ScheduledTaskTrigger -AtLogOn
    $Settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Days 0) -RestartCount 999 -RestartInterval (New-TimeSpan -Minutes 1) -MultipleInstances IgnoreNew -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
    Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Settings $Settings -Description "Aurora external worker daemon for Upcomers-Server 18503. Calculation support only; no trade permission." -Force | Out-Null
    $Task = Get-ScheduledTask -TaskName $TaskName -ErrorAction Stop
    $ScheduledTaskRegistered = $true
    $ScheduledTaskState = $Task.State.ToString()
} catch {
    $ScheduledTaskRegistered = $false
    $ScheduledTaskState = "registration_failed"
    $ScheduledTaskError = ($_.Exception.Message -replace "\r?\n", " ")
}

$FlatPresent = Test-Path $TargetExeFlat
$PackagedPresent = Test-Path $BuiltExe
$Now = [DateTimeOffset]::UtcNow
$NowUnix = $Now.ToUnixTimeSeconds()
$NowUtc = $Now.UtcDateTime.ToString("yyyy-MM-dd HH:mm:ss UTC")
$InstallText = @"
schema_name=aurora_worker_install_status
schema_version=2
installed=true
install_method=local_packaged_worker_plus_windows_scheduled_task
worker_version=0.2.1
flat_exe_present=$($FlatPresent.ToString().ToLowerInvariant())
packaged_exe_present=$($PackagedPresent.ToString().ToLowerInvariant())
flat_exe_path=$TargetExeFlat
packaged_exe_path=$BuiltExe
daemon_install_method=windows_scheduled_task
scheduled_task_name=$TaskName
scheduled_task_registered=$($ScheduledTaskRegistered.ToString().ToLowerInvariant())
scheduled_task_state=$ScheduledTaskState
scheduled_task_error=$ScheduledTaskError
auto_start_configured=$($ScheduledTaskRegistered.ToString().ToLowerInvariant())
generated_unix=$NowUnix
generated_utc=$NowUtc
authority=calculation_support_only
trade_permission=false
"@

Set-Content -Path $InstallStatusPath -Value $InstallText -Encoding ASCII

Write-Host "Installed worker folder: $TargetWorkerRoot"
Write-Host "Flat EXE copy for diagnostic detection: $TargetExeFlat"
Write-Host "Install status proof: $InstallStatusPath"
Write-Host "Scheduled task: $TaskName ($ScheduledTaskState)"
if (!$ScheduledTaskRegistered) {
    Write-Host "Scheduled task registration warning: $ScheduledTaskError"
}
