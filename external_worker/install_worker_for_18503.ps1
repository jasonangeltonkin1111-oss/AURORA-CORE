$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BuiltWorker = Join-Path $ScriptDir "dist\AuroraWorker"
$SharedRoot = "C:\Users\Jason\AppData\Roaming\MetaQuotes\Terminal\Common\Files\Aurora Core"
$SharedExternalWorker = Join-Path $SharedRoot "External Worker"
$SharedWorkerRoot = Join-Path $SharedExternalWorker "AuroraWorker"
$SharedExeFlat = Join-Path $SharedExternalWorker "AuroraWorker.exe"
$SharedStatus = Join-Path $SharedExternalWorker "Status"
$SharedInstallStatusPath = Join-Path $SharedStatus "shared_worker_install_status.txt"
$AccountRoot = Join-Path $SharedRoot "Upcomers-Server\18503"
$AccountStatus = Join-Path $AccountRoot "Workbench\External Worker\Status"
$AccountInstallStatusPath = Join-Path $AccountStatus "worker_install_status.txt"
$TaskName = "AuroraWorker_Global"

if (!(Test-Path $BuiltWorker)) {
    throw "Built worker folder not found: $BuiltWorker. Run build_worker.ps1 first."
}

New-Item -ItemType Directory -Force -Path $SharedWorkerRoot | Out-Null
New-Item -ItemType Directory -Force -Path $SharedStatus | Out-Null
New-Item -ItemType Directory -Force -Path $AccountStatus | Out-Null
Copy-Item -Path (Join-Path $BuiltWorker "*") -Destination $SharedWorkerRoot -Recurse -Force

$BuiltExe = Join-Path $SharedWorkerRoot "AuroraWorker.exe"
if (!(Test-Path $BuiltExe)) {
    throw "Install failed: AuroraWorker.exe missing after copy."
}

# Flat shared copy remains diagnostic only. Packaged exe is the task target.
Copy-Item -Path $BuiltExe -Destination $SharedExeFlat -Force

$ScheduledTaskRegistered = $false
$ScheduledTaskState = "not_registered"
$ScheduledTaskError = "none"
try {
    $Action = New-ScheduledTaskAction -Execute $BuiltExe -Argument "--shared-root `"$SharedRoot`" --mode shared-daemon --poll-seconds 1" -WorkingDirectory $SharedWorkerRoot
    $Trigger = New-ScheduledTaskTrigger -AtLogOn
    $Settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Days 0) -RestartCount 999 -RestartInterval (New-TimeSpan -Minutes 1) -MultipleInstances IgnoreNew -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
    Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Settings $Settings -Description "Aurora shared external worker daemon. Supervises all registered Aurora Core account roots. Calculation support only; no trade permission." -Force | Out-Null
    $Task = Get-ScheduledTask -TaskName $TaskName -ErrorAction Stop
    $ScheduledTaskRegistered = $true
    $ScheduledTaskState = $Task.State.ToString()
} catch {
    $ScheduledTaskRegistered = $false
    $ScheduledTaskState = "registration_failed"
    $ScheduledTaskError = ($_.Exception.Message -replace "\r?\n", " ")
}

$FlatPresent = Test-Path $SharedExeFlat
$PackagedPresent = Test-Path $BuiltExe
$Now = [DateTimeOffset]::UtcNow
$NowUnix = $Now.ToUnixTimeSeconds()
$NowUtc = $Now.UtcDateTime.ToString("yyyy-MM-dd HH:mm:ss UTC")
$InstallText = @"
schema_name=aurora_worker_install_status
schema_version=3
installed=true
install_method=shared_packaged_worker_plus_global_windows_scheduled_task
worker_version=0.3.0
shared_daemon=true
shared_root=$SharedRoot
account_root=$AccountRoot
flat_exe_present=$($FlatPresent.ToString().ToLowerInvariant())
packaged_exe_present=$($PackagedPresent.ToString().ToLowerInvariant())
flat_exe_path=$SharedExeFlat
packaged_exe_path=$BuiltExe
daemon_install_method=windows_scheduled_task_shared_daemon
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

Set-Content -Path $SharedInstallStatusPath -Value $InstallText -Encoding ASCII
Set-Content -Path $AccountInstallStatusPath -Value $InstallText -Encoding ASCII

Write-Host "Installed shared worker folder: $SharedWorkerRoot"
Write-Host "Flat EXE copy for diagnostic detection: $SharedExeFlat"
Write-Host "Shared install status proof: $SharedInstallStatusPath"
Write-Host "Account install status proof: $AccountInstallStatusPath"
Write-Host "Scheduled task: $TaskName ($ScheduledTaskState)"
if (!$ScheduledTaskRegistered) {
    Write-Host "Scheduled task registration warning: $ScheduledTaskError"
}
