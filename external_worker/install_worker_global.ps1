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
$ExpectedWorkerVersion = "0.6.18_l19_single_dispatch_cleanup"
$WorkerVersion = $ExpectedWorkerVersion
$SpecPath = Join-Path $ScriptDir "AuroraWorker.spec"
$PyInstallerRebuildAttempted=$false; $PyInstallerRebuildStatus="not_started"; $PyInstallerRebuildError="none"
$PackageExeLastWriteUtc="not_available"; $PackageProbeWorkerVersion="not_checked"; $PackageProbeError="none"; $PackageVersionMatchesSource="false"
$PreinstallStopAttempted=$false; $PreinstallStopStatus="not_started"; $PreinstallStopError="none"; $PreinstallStoppedProcessCount=0

function Stop-AuroraGatewayRuntimeForInstall {
  $script:PreinstallStopAttempted=$true
  $script:PreinstallStopStatus="running"
  $errors = @()

  foreach($taskName in @($WatchdogTaskName, $DaemonTaskName)) {
    try {
      $task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
      if($task -and $task.State.ToString() -eq "Running") {
        Stop-ScheduledTask -TaskName $taskName -ErrorAction Stop | Out-Null
      }
    } catch {
      $errors += ("stop_task_" + $taskName + ": " + ($_.Exception.Message -replace "\r?\n", " "))
    }
  }

  Start-Sleep -Seconds 2

  try {
    $procs = @(Get-Process -Name "AuroraWorker" -ErrorAction SilentlyContinue)
    foreach($proc in $procs) {
      try {
        $script:PreinstallStoppedProcessCount++
        Stop-Process -Id $proc.Id -Force -ErrorAction Stop
      } catch {
        $errors += ("stop_process_" + $proc.Id + ": " + ($_.Exception.Message -replace "\r?\n", " "))
      }
    }
  } catch {
    $errors += ("enumerate_processes: " + ($_.Exception.Message -replace "\r?\n", " "))
  }

  Start-Sleep -Seconds 2

  $remaining = @(Get-Process -Name "AuroraWorker" -ErrorAction SilentlyContinue)
  if($remaining.Count -gt 0) {
    $errors += "aurora_worker_process_still_running_after_stop_attempt_count=$($remaining.Count)"
  }

  if($errors.Count -gt 0) {
    $script:PreinstallStopStatus="failed"
    $script:PreinstallStopError=($errors -join "; ")
    throw "Pre-install Gateway stop failed. Refusing package copy while runtime files may be locked. $script:PreinstallStopError"
  }

  $script:PreinstallStopStatus="succeeded"
  $script:PreinstallStopError="none"
}

if (Test-Path $WorkerSource) {
  $versionLine = Select-String -LiteralPath $WorkerSource -Pattern '^\s*WORKER_VERSION\s*=\s*"([^"]+)"' -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($null -ne $versionLine) { $WorkerVersion = $versionLine.Matches[0].Groups[1].Value }
}

if ($WorkerVersion -ne $ExpectedWorkerVersion) {
  Write-Host "WARNING: source worker version differs from expected current version. source=$WorkerVersion expected=$ExpectedWorkerVersion" -ForegroundColor Yellow
}

try {
  if (!(Test-Path $SpecPath)) { throw "PyInstaller spec missing: $SpecPath" }
  $PyInstallerRebuildAttempted=$true
  $PyInstallerRebuildStatus="running"
  Push-Location $ScriptDir
  try {
    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
      $null = & python -m PyInstaller --clean --noconfirm $SpecPath 2>&1
      $buildExitCode = $LASTEXITCODE
    } finally {
      $ErrorActionPreference = $previousErrorActionPreference
    }
    if ($buildExitCode -ne 0) { throw "python -m PyInstaller exited with code $buildExitCode" }
  } finally {
    Pop-Location
  }
  $PyInstallerRebuildStatus="succeeded"
} catch {
  $PyInstallerRebuildStatus="failed"
  $PyInstallerRebuildError = ($_.Exception.Message -replace "\r?\n", " ")
  throw "PyInstaller rebuild failed. Refusing to install a possibly stale worker package. $PyInstallerRebuildError"
}

if (!(Test-Path $BuiltWorker)) { throw "Built Gateway folder not found after rebuild: $BuiltWorker. No packaged readiness is claimed by source alone." }
New-Item -ItemType Directory -Force -Path $SharedWorkerRoot,$SharedStatus | Out-Null

# The packaged one-folder worker keeps DLLs loaded while the daemon/watchdog are running.
# Stop the existing runtime before replacing the live package, then register/start tasks again below.
Stop-AuroraGatewayRuntimeForInstall

try {
  Copy-Item -Path (Join-Path $BuiltWorker "*") -Destination $SharedWorkerRoot -Recurse -Force -ErrorAction Stop
} catch {
  $copyError = ($_.Exception.Message -replace "\r?\n", " ")
  throw "Package copy failed after stopping Gateway runtime. No install success is claimed. $copyError"
}

$BuiltExe = Join-Path $SharedWorkerRoot "AuroraWorker.exe"
$BuiltInternalDll = Join-Path $SharedWorkerRoot "_internal\python312.dll"
if (!(Test-Path $BuiltExe)) { throw "Install failed: AuroraWorker.exe missing after copy." }
if (!(Test-Path $BuiltInternalDll)) { throw "Install failed: packaged Python DLL missing after copy: $BuiltInternalDll" }

# Flat EXE copy is retained only for diagnostic visibility.
# Runtime task authority must use the packaged one-folder EXE beside _internal.
Copy-Item -Path $BuiltExe -Destination $SharedExeFlat -Force

if (Test-Path $BuiltExe) {
  $PackageExeLastWriteUtc = (Get-Item -LiteralPath $BuiltExe).LastWriteTimeUtc.ToString("yyyy-MM-dd HH:mm:ss UTC")
  try {
    $probe = & $BuiltExe --version 2>&1
    if ($LASTEXITCODE -eq 0 -and $probe) {
      $PackageProbeWorkerVersion = (($probe | Select-Object -First 1).ToString()).Trim()
    } elseif ($LASTEXITCODE -eq 0) {
      $PackageProbeWorkerVersion = $WorkerVersion
      $PackageProbeError = "version_probe_stdout_empty_windowed_exe_version_inferred_from_successful_rebuild_and_copy"
    } else {
      $PackageProbeError = "version probe returned code $LASTEXITCODE"
    }
  } catch {
    $PackageProbeError = ($_.Exception.Message -replace "\r?\n", " ")
  }
}
$PackageVersionMatchesSource = if($PackageProbeWorkerVersion -eq $WorkerVersion){"true"}else{"false"}

$daemonRegistered=$false; $daemonState="not_registered"; $daemonError="none"; $daemonEnableAttempted=$false; $daemonEnableError="none"; $daemonStartAttempted=$false; $daemonStartError="none"
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
if ($daemonRegistered) {
  try {
    $daemonEnableAttempted=$true
    Enable-ScheduledTask -TaskName $DaemonTaskName -ErrorAction Stop | Out-Null
  } catch {
    $daemonEnableError = ($_.Exception.Message -replace "\r?\n", " ")
  }
  try {
    $daemonStartAttempted=$true
    Start-ScheduledTask -TaskName $DaemonTaskName -ErrorAction Stop
    Start-Sleep -Seconds 2
  } catch {
    $daemonStartError = ($_.Exception.Message -replace "\r?\n", " ")
  }
  $daemonTask = Get-ScheduledTask -TaskName $DaemonTaskName -ErrorAction SilentlyContinue
  if ($daemonTask) { $daemonState = $daemonTask.State.ToString() }
}

$watchRegistered=$false; $watchState="not_registered"; $watchError="none"; $watchEnableAttempted=$false; $watchEnableError="none"; $watchStartAttempted=$false; $watchStartError="none"
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
if ($watchRegistered) {
  try {
    $watchEnableAttempted=$true
    Enable-ScheduledTask -TaskName $WatchdogTaskName -ErrorAction Stop | Out-Null
  } catch {
    $watchEnableError = ($_.Exception.Message -replace "\r?\n", " ")
  }
  try {
    $watchStartAttempted=$true
    Start-ScheduledTask -TaskName $WatchdogTaskName -ErrorAction Stop
  } catch {
    $watchStartError = ($_.Exception.Message -replace "\r?\n", " ")
  }
  $watchTask = Get-ScheduledTask -TaskName $WatchdogTaskName -ErrorAction SilentlyContinue
  if ($watchTask) { $watchState = $watchTask.State.ToString() }
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
$daemonRunnable = $daemonRegistered -and ($daemonState -ne "Disabled") -and ($daemonState -ne "registration_failed")
$watchRunnable = $watchRegistered -and ($watchState -ne "Disabled") -and ($watchState -ne "registration_failed")
$SharedWorkerStatusPath = Join-Path $SharedStatus "shared_worker_status.txt"
$RuntimeProofReadyForOperatorCmd=$false
$RuntimeProofReadyReason="fresh_shared_status_with_matching_worker_version_and_account_result_pair_not_observed_by_installer"
if (Test-Path $SharedWorkerStatusPath) {
  try {
    $sharedText = Get-Content -LiteralPath $SharedWorkerStatusPath -Raw
    $runningVersion = if($sharedText -match "(?m)^worker_version=(.+)$"){$Matches[1].Trim()}else{""}
    $resultPairCount = if($sharedText -match "(?m)^account_result_pair_present_count=(\d+)$"){[int]$Matches[1]}else{0}
    $heartbeatCount = if($sharedText -match "(?m)^account_heartbeat_present_count=(\d+)$"){[int]$Matches[1]}else{0}
    $lastLoopUnix = if($sharedText -match "(?m)^last_loop_unix=(\d+)$"){[int64]$Matches[1]}else{0}
    $nowUnix = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
    $fresh = $lastLoopUnix -gt 0 -and (($nowUnix - $lastLoopUnix) -le 120)
    if($runningVersion -eq $WorkerVersion -and $resultPairCount -gt 0 -and $heartbeatCount -gt 0 -and $fresh) {
      $RuntimeProofReadyForOperatorCmd=$true
      $RuntimeProofReadyReason="fresh_shared_status_matches_source_and_account_result_pair_present"
    }
  } catch {
    $RuntimeProofReadyReason = "runtime_proof_check_failed: " + ($_.Exception.Message -replace "\r?\n", " ")
  }
}
$operatorCmdRequired = if($daemonRunnable -and $watchRunnable -and $PackagedPresent -and $PackagedInternalPresent -and $RuntimeProofReadyForOperatorCmd -and $authority -eq "calculation_support_only" -and $tradePermission -eq "false"){"false"}else{"true"}
$autoStartConfigured = if($daemonRunnable -and $watchRunnable -and $PackagedPresent -and $PackagedInternalPresent){"true"}else{"false"}
$watchdogDefaultEnabled = if($watchRunnable){"true"}else{"false"}
$Now = [DateTimeOffset]::UtcNow
$InstallText = @"
schema_name=aurora_gateway_install_status
schema_version=9
installed=$((($PackagedPresent -and $PackagedInternalPresent)).ToString().ToLowerInvariant())
install_method=shared_global_gateway_plus_daemon_and_watchdog_tasks
worker_version=$WorkerVersion
expected_worker_version=$ExpectedWorkerVersion
worker_version_source=external_worker/aurora_worker.py
package_source=external_worker/dist/AuroraWorker
package_staleness_policy=rebuild_required_after_worker_source_change_no_source_only_runtime_claim
preinstall_stop_attempted=$($PreinstallStopAttempted.ToString().ToLowerInvariant())
preinstall_stop_status=$PreinstallStopStatus
preinstall_stop_error=$PreinstallStopError
preinstall_stopped_process_count=$PreinstallStoppedProcessCount
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
pyinstaller_rebuild_attempted=$($PyInstallerRebuildAttempted.ToString().ToLowerInvariant())
pyinstaller_rebuild_status=$PyInstallerRebuildStatus
pyinstaller_rebuild_error=$PyInstallerRebuildError
package_exe_last_write_utc=$PackageExeLastWriteUtc
packaged_worker_version=$PackageProbeWorkerVersion
packaged_worker_version_probe_error=$PackageProbeError
packaged_worker_version_matches_source=$PackageVersionMatchesSource
daemon_install_method=windows_scheduled_task_shared_daemon
daemon_runtime_exe=$BuiltExe
daemon_runtime_working_directory=$SharedWorkerRoot
scheduled_task_name=$DaemonTaskName
scheduled_task_registered=$($daemonRegistered.ToString().ToLowerInvariant())
scheduled_task_state=$daemonState
scheduled_task_runnable=$($daemonRunnable.ToString().ToLowerInvariant())
scheduled_task_error=$daemonError
scheduled_task_enable_attempted=$($daemonEnableAttempted.ToString().ToLowerInvariant())
scheduled_task_enable_error=$daemonEnableError
daemon_start_attempted=$($daemonStartAttempted.ToString().ToLowerInvariant())
daemon_start_error=$daemonStartError
watchdog_install_method=windows_scheduled_task_lightweight_repair_lane_packaged_exe
watchdog_task_name=$WatchdogTaskName
watchdog_task_registered=$($watchRegistered.ToString().ToLowerInvariant())
watchdog_task_state=$watchState
watchdog_task_runnable=$($watchRunnable.ToString().ToLowerInvariant())
watchdog_task_error=$watchError
watchdog_task_enable_attempted=$($watchEnableAttempted.ToString().ToLowerInvariant())
watchdog_task_enable_error=$watchEnableError
watchdog_task_start_attempted=$($watchStartAttempted.ToString().ToLowerInvariant())
watchdog_task_start_error=$watchStartError
watchdog_default_enabled=$watchdogDefaultEnabled
watchdog_disabled_to_prevent_popup_loop=false
watchdog_expected_runtime_mode=lightweight_probe_no_layer_dispatch
watchdog_proof_scope=registration_only_plus_expected_lightweight_probe_runtime_not_recovery_proof
auto_start_configured=$autoStartConfigured
operator_cmd_required=$operatorCmdRequired
runtime_proof_ready_for_operator_cmd=$($RuntimeProofReadyForOperatorCmd.ToString().ToLowerInvariant())
runtime_proof_ready_reason=$RuntimeProofReadyReason
generated_unix=$($Now.ToUnixTimeSeconds())
generated_utc=$($Now.UtcDateTime.ToString("yyyy-MM-dd HH:mm:ss UTC"))
authority=calculation_support_only
trade_permission=false
"@
Set-Content -Path $SharedInstallStatusPath -Value $InstallText -Encoding ASCII
Write-Host "Installed Gateway and task proofs at $SharedInstallStatusPath"
Write-Host "Worker version source=$WorkerVersion expected=$ExpectedWorkerVersion"
Write-Host "Runtime folder authority=$SharedWorkerRoot"
Write-Host "Preinstall stop status=$PreinstallStopStatus stopped_process_count=$PreinstallStoppedProcessCount"
Write-Host "Daemon registered=$($daemonRegistered.ToString().ToLowerInvariant()) state=$daemonState"
Write-Host "Watchdog registered=$($watchRegistered.ToString().ToLowerInvariant()) state=$watchState operator_cmd_required=$operatorCmdRequired lightweight_expected=true"
