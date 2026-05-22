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
$WatchdogHelper = Join-Path $ScriptDir "register_watchdog_safe.ps1"
$WorkerVersion = "0.6.4_l6_friction_ranked_csv"

if (!(Test-Path $BuiltWorker)) { throw "Built worker folder not found: $BuiltWorker. Rebuild the PyInstaller one-folder worker from current source before installing. No packaged readiness is claimed by source alone." }
New-Item -ItemType Directory -Force -Path $SharedWorkerRoot,$SharedStatus | Out-Null
Copy-Item -Path (Join-Path $BuiltWorker "*") -Destination $SharedWorkerRoot -Recurse -Force
$BuiltExe = Join-Path $SharedWorkerRoot "AuroraWorker.exe"
$BuiltInternalDll = Join-Path $SharedWorkerRoot "_internal\python312.dll"
if (!(Test-Path $BuiltExe)) { throw "Install failed: AuroraWorker.exe missing after copy." }
if (!(Test-Path $BuiltInternalDll)) { throw "Install failed: packaged Python DLL missing after copy: $BuiltInternalDll" }

# Flat EXE copy is retained only for legacy diagnostic visibility.
# Runtime task authority must use the packaged one-folder EXE beside _internal.
Copy-Item -Path $BuiltExe -Destination $SharedExeFlat -Force

$daemonRegistered=$false; $daemonState="not_registered"; $daemonError="none"
try {
  $daemonAction = New-ScheduledTaskAction -Execute $BuiltExe -Argument "--shared-root `"$SharedRoot`" --mode shared-daemon --poll-seconds 1" -WorkingDirectory $SharedWorkerRoot
  $daemonTrigger = New-ScheduledTaskTrigger -AtLogOn
  $daemonSettings = New-ScheduledTaskSettingsSet -MultipleInstances IgnoreNew -ExecutionTimeLimit (New-TimeSpan -Days 3650) -RestartCount 999 -RestartInterval (New-TimeSpan -Minutes 1) -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
  Register-ScheduledTask -TaskName $DaemonTaskName -Action $daemonAction -Trigger $daemonTrigger -Settings $daemonSettings -Description "Aurora shared external worker daemon." -Force | Out-Null
  $daemonTask = Get-ScheduledTask -TaskName $DaemonTaskName -ErrorAction Stop
  $daemonRegistered = $true; $daemonState = $daemonTask.State.ToString()
} catch {
  $daemonError = ($_.Exception.Message -replace "\r?\n", " ")
  $daemonState="registration_failed"
}

$watchRegistered=$false; $watchState="not_registered"; $watchError="none"
if (Test-Path $WatchdogHelper) {
  try {
    powershell -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File $WatchdogHelper | Out-Host
    $watchTask = Get-ScheduledTask -TaskName $WatchdogTaskName -ErrorAction Stop
    $watchRegistered = $true; $watchState = $watchTask.State.ToString(); $watchError = "none"
  } catch {
    $watchError = ($_.Exception.Message -replace "\r?\n", " ")
    $watchState = "registration_failed"
  }
} else {
  $watchError = "register_watchdog_safe.ps1 missing"
  $watchState = "registration_failed"
}

$daemonTaskRefresh = Get-ScheduledTask -TaskName $DaemonTaskName -ErrorAction SilentlyContinue
if ($daemonTaskRefresh) { $daemonRegistered = $true; $daemonState = $daemonTaskRefresh.State.ToString() } else { $daemonRegistered = $false; if($daemonError -eq "none"){ $daemonError = "daemon task not found after registration attempt" } }
$watchTaskRefresh = Get-ScheduledTask -TaskName $WatchdogTaskName -ErrorAction SilentlyContinue
if ($watchTaskRefresh) { $watchRegistered = $true; $watchState = $watchTaskRefresh.State.ToString(); $watchError = "none" } else { $watchRegistered = $false; if($watchError -eq "none"){ $watchError = "watchdog task not found after registration attempt" } }

$FlatPresent = Test-Path $SharedExeFlat
$PackagedPresent = Test-Path $BuiltExe
$PackagedInternalPresent = Test-Path $BuiltInternalDll
$authority = "calculation_support_only"; $tradePermission="false"
$operatorCmdRequired = if($daemonRegistered -and $watchRegistered -and $FlatPresent -and $PackagedPresent -and $PackagedInternalPresent -and $authority -eq "calculation_support_only" -and $tradePermission -eq "false"){"false"}else{"true"}
$autoStartConfigured = if($daemonRegistered -and $watchRegistered -and $PackagedPresent -and $PackagedInternalPresent){"true"}else{"false"}
$Now = [DateTimeOffset]::UtcNow
$InstallText = @"
schema_name=aurora_worker_install_status
schema_version=5
installed=$((($FlatPresent -and $PackagedPresent -and $PackagedInternalPresent)).ToString().ToLowerInvariant())
install_method=shared_global_worker_plus_daemon_and_watchdog_tasks
worker_version=$WorkerVersion
package_source=external_worker/dist/AuroraWorker
package_staleness_policy=rebuild_required_after_worker_source_change_no_source_only_runtime_claim
shared_daemon=true
shared_root=$SharedRoot
flat_exe_present=$($FlatPresent.ToString().ToLowerInvariant())
packaged_exe_present=$($PackagedPresent.ToString().ToLowerInvariant())
packaged_internal_python_dll_present=$($PackagedInternalPresent.ToString().ToLowerInvariant())
flat_exe_path=$SharedExeFlat
flat_exe_runtime_authority=false
packaged_exe_path=$BuiltExe
packaged_exe_runtime_authority=true
daemon_install_method=windows_scheduled_task_shared_daemon
daemon_runtime_exe=$BuiltExe
daemon_runtime_working_directory=$SharedWorkerRoot
scheduled_task_name=$DaemonTaskName
scheduled_task_registered=$($daemonRegistered.ToString().ToLowerInvariant())
scheduled_task_state=$daemonState
scheduled_task_error=$daemonError
watchdog_install_method=windows_scheduled_task_repair_lane_packaged_exe
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
Write-Host "Daemon registered=$($daemonRegistered.ToString().ToLowerInvariant()) state=$daemonState"
Write-Host "Watchdog registered=$($watchRegistered.ToString().ToLowerInvariant()) state=$watchState operator_cmd_required=$operatorCmdRequired"