$ErrorActionPreference = "Stop"

$sharedRoot = "$env:APPDATA\MetaQuotes\Terminal\Common\Files\Aurora Core"
$watchdogTask = "AuroraWorker_Global_Watchdog"
$daemonTask = "AuroraWorker_Global"
$statusFolder = Join-Path $sharedRoot "External Worker\Status"
$installStatus = Join-Path $statusFolder "shared_worker_install_status.txt"

# PyInstaller one-folder build: runtime EXE must stay beside _internal.
$watchdogWorkdir = Join-Path $sharedRoot "External Worker\AuroraWorker"
$watchdogExe = Join-Path $watchdogWorkdir "AuroraWorker.exe"

New-Item -ItemType Directory -Force -Path $statusFolder | Out-Null

Unregister-ScheduledTask -TaskName $watchdogTask -Confirm:$false -ErrorAction SilentlyContinue

if (!(Test-Path $watchdogExe)) {
    throw "Missing packaged watchdog executable: $watchdogExe"
}
if (!(Test-Path (Join-Path $watchdogWorkdir "_internal\python312.dll"))) {
    throw "Missing packaged Python DLL: $watchdogWorkdir\_internal\python312.dll"
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
  -Description "Aurora global worker watchdog repair task" `
  -Force | Out-Null

$daemon = Get-ScheduledTask -TaskName $daemonTask -ErrorAction SilentlyContinue
$watchdog = Get-ScheduledTask -TaskName $watchdogTask -ErrorAction SilentlyContinue

$daemonRegistered = if ($daemon) { "true" } else { "false" }
$daemonState = if ($daemon) { $daemon.State.ToString() } else { "not_registered" }
$watchdogRegistered = if ($watchdog) { "true" } else { "false" }
$watchdogState = if ($watchdog) { $watchdog.State.ToString() } else { "not_registered" }
$operatorRequired = if ($daemonRegistered -eq "true" -and $watchdogRegistered -eq "true") { "false" } else { "true" }

if (Test-Path $installStatus) {
    $text = Get-Content $installStatus -Raw
    $pairs = @{
        "scheduled_task_registered" = $daemonRegistered
        "scheduled_task_state" = $daemonState
        "watchdog_task_registered" = $watchdogRegistered
        "watchdog_task_state" = $watchdogState
        "watchdog_task_error" = "none"
        "operator_cmd_required" = $operatorRequired
        "auto_start_configured" = if ($operatorRequired -eq "false") { "true" } else { "false" }
        "flat_exe_runtime_authority" = "false"
        "packaged_exe_runtime_authority" = "true"
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

Write-Host "Watchdog registered=$watchdogRegistered state=$watchdogState operator_cmd_required=$operatorRequired"
