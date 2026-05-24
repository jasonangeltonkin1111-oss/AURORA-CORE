$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BuiltWorker = Join-Path $ScriptDir "dist\AuroraWorker"
$WorkerSource = Join-Path $ScriptDir "aurora_worker.py"
$SharedRoot = Join-Path $env:APPDATA "MetaQuotes\Terminal\Common\Files\Aurora Core"
$SharedExternalWorker = Join-Path $SharedRoot "Gateway"
$SharedWorkerRoot = Join-Path $SharedExternalWorker "AuroraWorker"
$SharedExeFlat = Join-Path $SharedExternalWorker "AuroraWorker.exe"
$SharedBinRoot = Join-Path $SharedExternalWorker "Bin"
$SharedStatus = Join-Path $SharedExternalWorker "Status"
$SharedInstallStatusPath = Join-Path $SharedStatus "shared_worker_install_status.txt"
$DaemonTaskName = "AuroraWorker_Global"
$WatchdogTaskName = "AuroraWorker_Global_Watchdog"
$WatchdogHelper = Join-Path $ScriptDir "register_watchdog_safe.ps1"
$ExpectedWorkerVersion = "0.6.17_l17_deep_evidence_selection_split"
$WorkerVersion = $ExpectedWorkerVersion

if (Test-Path $WorkerSource) {
  $versionLine = Select-String -LiteralPath $WorkerSource -Pattern '^\s*WORKER_VERSION\s*=\s*"([^"]+)"' -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($null -ne $versionLine) { $WorkerVersion = $versionLine.Matches[0].Groups[1].Value }
}

if ($WorkerVersion -ne $ExpectedWorkerVersion) {
  Write-Host "WARNING: source worker version differs from expected current version. source=$WorkerVersion expected=$ExpectedWorkerVersion" -ForegroundColor Yellow
}

if (!(Test-Path $BuiltWorker)) { throw "Built Gateway folder not found: $BuiltWorker. Rebuild the PyInstaller one-folder worker from current source before installing. No packaged readiness is claimed by source alone." }
New-Item -ItemType Directory -Force -Path $SharedWorkerRoot,$SharedStatus | Out-Null
Copy-Item -Path (Join-Path $BuiltWorker "*") -Destination $SharedWorkerRoot -Recurse -Force
$BuiltExe = Join-Path $SharedWorkerRoot "AuroraWorker.exe"
$BuiltInternalDll = Join-Path $SharedWorkerRoot "_internal\python312.dll"
if (!(Test-Path $BuiltExe)) { throw "Install failed: AuroraWorker.exe missing after copy." }
if (!(Test-Path $BuiltInternalDll)) { throw "Install failed: packaged Python DLL missing after copy: $BuiltInternalDll" }

# Flat EXE copy is retained only for diagnostic visibility.
# Runtime task authority must use the packaged one-folder EXE beside _internal.
Copy-Item -Path $BuiltExe -Destination $SharedExeFlat -Force

$daemonRegistered=$false; $daemonState="not_registered"; $daemonError="none"; $daemonStartAttempted=$false; $daemonStartError="none"
try {
  $daemonAction = New-ScheduledTaskAction -Execute $BuiltExe -Argument "--shared-root `"$SharedRoot`" --mode shared-daemon --poll-seconds 1" -WorkingDirectory $SharedWorkerRoot
  $daemonTrigger = New-ScheduledTaskTrigger -AtLogOn
  $daemonSettings = New-ScheduledTaskSettingsSet -MultipleInstances IgnoreNew -ExecutionTimeLimit (New-TimeSpan -Days 3650) -RestartCount 999 -RestartInterval (New-TimeSpan -Minutes 1) -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
  Register-ScheduledTask -TaskName $DaemonTaskName -Action $daemonAction -Trigger $daemonTrigger -Settings $daemonSettings -Description "Aurora shared Gateway daemon." -Force | Out-Null
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
$BinPresent = Test-Path $SharedBinRoot
$authority = "calculation_support_only"; $tradePermission="false"
$operatorCmdRequired = if($daemonRegistered -and $watchRegistered -and $PackagedPresent -and $PackagedInternalPresent -and $authority -eq "calculation_support_only" -and $tradePermission -eq "false"){"false"}else{"true"}
$autoStartConfigured = if($daemonRegistered -and $watchRegistered -and $PackagedPresent -and $PackagedInternalPresent){"true"}else{"false"}
$Now = [DateTimeOffset]::UtcNow
$InstallText = @"
schema_name=aurora_gateway_install_status
schema_version=8
installed=$((($PackagedPresent -and $PackagedInternalPresent)).ToString().ToLowerInvariant())
install_method=shared_global_gateway_plus_daemon_and_watchdog_tasks
worker_version=$WorkerVersion
expected_worker_version=$ExpectedWorkerVersion
worker_version_source=external_worker/aurora_worker.py
package_source=external_worker/dist/AuroraWorker
package_staleness_policy=rebuild_required_after_worker_source_change_no_source_only_runtime_claim
shared_daemon=true
shared_root=$SharedRoot
gateway_root=$SharedExternalWorker
runtime_folder=$SharedWorkerRoot
runtime_folder_authority=true
runtime_exe_path=$BuiltExe
runtime_internal_python_dll_path=$BuiltInternalDll
flat_exe_present=$($FlatPresent.ToString().ToLowerInvariant())
flat_exe_path=$SharedExeFlat
flat_exe_runtime_authority=false
bin_folder_present=$($BinPresent.ToString().ToLowerInvariant())
bin_folder_path=$SharedBinRoot
bin_folder_runtime_authority=false
packaged_exe_present=$($PackagedPresent.ToString().ToLowerInvariant())
packaged_internal_python_dll_present=$($PackagedInternalPresent.ToString().ToLowerInvariant())
packaged_exe_path=$BuiltExe
packaged_exe_runtime_authority=true
daemon_install_method=windows_scheduled_task_shared_daemon
daemon_runtime_exe=$BuiltExe
daemon_runtime_working_directory=$SharedWorkerRoot
scheduled_task_name=$DaemonTaskName
scheduled_task_registered=$($daemonRegistered.ToString().ToLowerInvariant())
scheduled_task_state=$daemonState
scheduled_task_error=$daemonError
daemon_start_attempted=$($daemonStartAttempted.ToString().ToLowerInvariant())
daemon_start_error=$daemonStartError
watchdog_install_method=windows_scheduled_task_lightweight_repair_lane_packaged_exe
watchdog_task_name=$WatchdogTaskName
watchdog_task_registered=$($watchRegistered.ToString().ToLowerInvariant())
watchdog_task_state=$watchState
watchdog_task_error=$watchError
watchdog_default_enabled=$($watchRegistered.ToString().ToLowerInvariant())
watchdog_disabled_to_prevent_popup_loop=false
watchdog_expected_runtime_mode=lightweight_probe_no_layer_dispatch
watchdog_proof_scope=registration_only_plus_expected_lightweight_probe_runtime_not_recovery_proof
auto_start_configured=$autoStartConfigured
operator_cmd_required=$operatorCmdRequired
generated_unix=$($Now.ToUnixTimeSeconds())
generated_utc=$($Now.UtcDateTime.ToString("yyyy-MM-dd HH:mm:ss UTC"))
authority=calculation_support_only
trade_permission=false
"@
Set-Content -Path $SharedInstallStatusPath -Value $InstallText -Encoding ASCII
Write-Host "Installed Gateway and task proofs at $SharedInstallStatusPath"
Write-Host "Worker version source=$WorkerVersion expected=$ExpectedWorkerVersion"
Write-Host "Runtime folder authority=$SharedWorkerRoot"
Write-Host "Daemon registered=$($daemonRegistered.ToString().ToLowerInvariant()) state=$daemonState"
Write-Host "Watchdog registered=$($watchRegistered.ToString().ToLowerInvariant()) state=$watchState operator_cmd_required=$operatorCmdRequired lightweight_expected=true"


