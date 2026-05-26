$ErrorActionPreference = "Stop"

$sharedRoot = "$env:APPDATA\MetaQuotes\Terminal\Common\Files\Aurora Core"
$watchdogTask = "AuroraWorker_Global_Watchdog"
$daemonTask = "AuroraWorker_Global"
$statusFolder = Join-Path $sharedRoot "Gateway\Status"
$installStatus = Join-Path $statusFolder "shared_worker_install_status.txt"

# PyInstaller one-folder build: runtime EXE must stay beside _internal.
$watchdogWorkdir = Join-Path $sharedRoot "Gateway\AuroraWorker"
$watchdogExe = Join-Path $watchdogWorkdir "AuroraWorker.exe"
$watchdogDll = Join-Path $watchdogWorkdir "_internal\python312.dll"

New-Item -ItemType Directory -Force -Path $statusFolder | Out-Null

Unregister-ScheduledTask -TaskName $watchdogTask -Confirm:$false -ErrorAction SilentlyContinue

if (!(Test-Path $watchdogExe)) {
    throw "Missing packaged Gateway executable: $watchdogExe"
}
if (!(Test-Path $watchdogDll)) {
    throw "Missing packaged Python DLL: $watchdogDll"
}

$action = New-ScheduledTaskAction `
  -Execute $watchdogExe `
  -Argument "--shared-root `"$sharedRoot`" --watchdog" `
  -WorkingDirectory $watchdogWorkdir

# Use the ScheduledTasks cmdlet's supported repetition parameters instead of mutating
# $trigger.Repetition.Interval. Some Windows/PowerShell builds return a trigger
# object whose Repetition child does not expose settable Interval/StopAtDurationEnd
# properties, causing watchdog registration to fail even though the daemon is valid.
$trigger = New-ScheduledTaskTrigger `
  -Once `
  -At (Get-Date).AddMinutes(1) `
  -RepetitionInterval (New-TimeSpan -Minutes 1) `
  -RepetitionDuration (New-TimeSpan -Days 3650)

$settings = New-ScheduledTaskSettingsSet `
  -MultipleInstances IgnoreNew `
  -ExecutionTimeLimit (New-TimeSpan -Minutes 5) `
  -AllowStartIfOnBatteries `
  -DontStopIfGoingOnBatteries `
  -StartWhenAvailable

Register-ScheduledTask `
  -TaskName $watchdogTask `
  -Action $action `
  -Trigger $trigger `
  -Settings $settings `
  -Description "Aurora global Gateway watchdog repair task" `
  -Force | Out-Null

$daemon = Get-ScheduledTask -TaskName $daemonTask -ErrorAction SilentlyContinue
$watchdog = Get-ScheduledTask -TaskName $watchdogTask -ErrorAction SilentlyContinue

$daemonRegistered = if ($daemon) { "true" } else { "false" }
$daemonState = if ($daemon) { $daemon.State.ToString() } else { "not_registered" }
$watchdogRegistered = if ($watchdog) { "true" } else { "false" }
$watchdogState = if ($watchdog) { $watchdog.State.ToString() } else { "not_registered" }
$packagedExePresent = if (Test-Path $watchdogExe) { "true" } else { "false" }
$packagedDllPresent = if (Test-Path $watchdogDll) { "true" } else { "false" }
$daemonRunnable = $daemonRegistered -eq "true" -and $daemonState -ne "Disabled" -and $daemonState -ne "registration_failed"
$watchdogRunnable = $watchdogRegistered -eq "true" -and $watchdogState -ne "Disabled" -and $watchdogState -ne "registration_failed"

# This is install/autostart configuration proof only.
# It is not stale/missing daemon recovery proof. Runtime closeout still requires
# shared status freshness plus watchdog recovery evidence from the Gateway status file.
$operatorRequired = if ($daemonRunnable -and $watchdogRunnable -and $packagedExePresent -eq "true" -and $packagedDllPresent -eq "true") { "false" } else { "true" }

if (Test-Path $installStatus) {
    $text = Get-Content $installStatus -Raw
    $pairs = @{
        "schema_version" = "8"
        "scheduled_task_registered" = $daemonRegistered
        "scheduled_task_state" = $daemonState
        "scheduled_task_runnable" = if ($daemonRunnable) { "true" } else { "false" }
        "watchdog_task_registered" = $watchdogRegistered
        "watchdog_task_state" = $watchdogState
        "watchdog_task_runnable" = if ($watchdogRunnable) { "true" } else { "false" }
        "watchdog_task_error" = "none"
        "watchdog_default_enabled" = if ($watchdogRunnable) { "true" } else { "false" }
        "operator_cmd_required" = $operatorRequired
        "auto_start_configured" = if ($operatorRequired -eq "false") { "true" } else { "false" }
        "packaged_exe_present" = $packagedExePresent
        "packaged_internal_python_dll_present" = $packagedDllPresent
        "flat_exe_runtime_authority" = "false"
        "packaged_exe_runtime_authority" = "true"
        "watchdog_proof_scope" = "registration_only_not_recovery_proof"
        "package_staleness_policy" = "rebuild_required_after_worker_source_change_no_source_only_runtime_claim"
    }
    foreach ($key in $pairs.Keys) {
        if ($text -match "(?m)^$key=") {
            $text = $text -replace "(?m)^$key=.*$", "$key=$($pairs[$key])"
        } else {
            $text += "`r`n$key=$($pairs[$key])"
        }
    }
    Set-Content -Path $installStatus -Value $text -Encoding ASCII
}

Write-Host "Gateway watchdog registered=$watchdogRegistered state=$watchdogState operator_cmd_required=$operatorRequired proof_scope=registration_only_not_recovery_proof"
