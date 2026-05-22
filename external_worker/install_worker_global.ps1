$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BuiltWorker = Join-Path $ScriptDir "dist\AuroraWorker"
$SharedRoot = Join-Path $env:APPDATA "MetaQuotes\Terminal\Common\Files\Aurora Core"
$SharedExternalWorker = Join-Path $SharedRoot "External Worker"
$SharedWorkerRoot = Join-Path $SharedExternalWorker "AuroraWorker"
$SharedExeFlat = Join-Path $SharedExternalWorker "AuroraWorker.exe"
$SharedStatus = Join-Path $SharedExternalWorker "Status"
$SharedInstallStatusPath = Join-Path $SharedStatus "shared_worker_install_status.txt"
$DaemonTaskName = "AuroraWorker_Global"
$WatchdogTaskName = "AuroraWorker_Global_Watchdog"

if (!(Test-Path $BuiltWorker)) { throw "Built worker folder not found: $BuiltWorker. Run build_worker.ps1 first." }
New-Item -ItemType Directory -Force -Path $SharedWorkerRoot,$SharedStatus | Out-Null
Copy-Item -Path (Join-Path $BuiltWorker "*") -Destination $SharedWorkerRoot -Recurse -Force
$BuiltExe = Join-Path $SharedWorkerRoot "AuroraWorker.exe"
if (!(Test-Path $BuiltExe)) { throw "Install failed: AuroraWorker.exe missing after copy." }
Copy-Item -Path $BuiltExe -Destination $SharedExeFlat -Force

$daemonRegistered=$false; $daemonState="not_registered"; $daemonError="none"
$watchRegistered=$false; $watchState="not_registered"; $watchError="none"
try {
  $daemonAction = New-ScheduledTaskAction -Execute $BuiltExe -Argument "--shared-root `"$SharedRoot`" --mode shared-daemon --poll-seconds 1" -WorkingDirectory $SharedWorkerRoot
  $daemonTrigger = New-ScheduledTaskTrigger -AtLogOn
  $daemonSettings = New-ScheduledTaskSettingsSet -MultipleInstances IgnoreNew -ExecutionTimeLimit (New-TimeSpan -Days 3650) -RestartCount 999 -RestartInterval (New-TimeSpan -Minutes 1) -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
  Register-ScheduledTask -TaskName $DaemonTaskName -Action $daemonAction -Trigger $daemonTrigger -Settings $daemonSettings -Description "Aurora shared external worker daemon." -Force | Out-Null
  $daemonTask = Get-ScheduledTask -TaskName $DaemonTaskName -ErrorAction Stop
  $daemonRegistered = $true; $daemonState = $daemonTask.State.ToString()
} catch { $daemonError = ($_.Exception.Message -replace "\r?\n", " "); $daemonState="registration_failed" }

try {
  $watchAction = New-ScheduledTaskAction -Execute $BuiltExe -Argument "--shared-root `"$SharedRoot`" --watchdog" -WorkingDirectory $SharedWorkerRoot
  $watchTrigger = New-ScheduledTaskTrigger -Once -At (Get-Date).Date
  $watchTrigger.RepetitionInterval = (New-TimeSpan -Minutes 1)
  $watchTrigger.RepetitionDuration = (New-TimeSpan -Days 3650)
  $watchSettings = New-ScheduledTaskSettingsSet -MultipleInstances IgnoreNew -ExecutionTimeLimit (New-TimeSpan -Minutes 2) -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
  Register-ScheduledTask -TaskName $WatchdogTaskName -Action $watchAction -Trigger $watchTrigger -Settings $watchSettings -Description "Aurora watchdog repair lane." -Force | Out-Null
  $watchTask = Get-ScheduledTask -TaskName $WatchdogTaskName -ErrorAction Stop
  $watchRegistered = $true; $watchState = $watchTask.State.ToString()
} catch { $watchError = ($_.Exception.Message -replace "\r?\n", " "); $watchState="registration_failed" }

$FlatPresent = Test-Path $SharedExeFlat
$PackagedPresent = Test-Path $BuiltExe
$authority = "calculation_support_only"; $tradePermission="false"
$operatorCmdRequired = if($daemonRegistered -and $watchRegistered -and $FlatPresent -and $PackagedPresent -and $authority -eq "calculation_support_only" -and $tradePermission -eq "false"){"false"}else{"true"}
$autoStartConfigured = if($daemonRegistered -and $watchRegistered){"true"}else{"false"}
$Now = [DateTimeOffset]::UtcNow
$InstallText = @"
schema_name=aurora_worker_install_status
schema_version=4
installed=$((($FlatPresent -and $PackagedPresent)).ToString().ToLowerInvariant())
install_method=shared_global_worker_plus_daemon_and_watchdog_tasks
worker_version=0.5.0
shared_daemon=true
shared_root=$SharedRoot
flat_exe_present=$($FlatPresent.ToString().ToLowerInvariant())
packaged_exe_present=$($PackagedPresent.ToString().ToLowerInvariant())
flat_exe_path=$SharedExeFlat
packaged_exe_path=$BuiltExe
daemon_install_method=windows_scheduled_task_shared_daemon
scheduled_task_name=$DaemonTaskName
scheduled_task_registered=$($daemonRegistered.ToString().ToLowerInvariant())
scheduled_task_state=$daemonState
scheduled_task_error=$daemonError
watchdog_install_method=windows_scheduled_task_repair_lane
watchdog_task_name=$WatchdogTaskName
watchdog_task_registered=$($watchRegistered.ToString().ToLowerInvariant())
watchdog_task_state=$watchState
watchdog_task_error=$watchError
auto_start_configured=$autoStartConfigured
operator_cmd_required=$operatorCmdRequired
generated_unix=$($Now.ToUnixTimeSeconds())
generated_utc=$($Now.UtcDateTime.ToString("yyyy-MM-dd HH:mm:ss UTC"))
authority=calculation_support_only
trade_permission=false
"@
Set-Content -Path $SharedInstallStatusPath -Value $InstallText -Encoding ASCII
Write-Host "Installed global worker and task proofs at $SharedInstallStatusPath"

# Aurora local patch: safe watchdog registration for paths with spaces.
powershell -ExecutionPolicy Bypass -File "$PSScriptRoot\register_watchdog_safe.ps1"

