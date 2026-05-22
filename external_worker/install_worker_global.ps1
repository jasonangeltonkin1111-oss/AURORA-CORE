$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BuiltWorker = Join-Path $ScriptDir "dist\AuroraWorker"
$SharedRoot = "C:\Users\Jason\AppData\Roaming\MetaQuotes\Terminal\Common\Files\Aurora Core"
$SharedExternalWorker = Join-Path $SharedRoot "External Worker"
$SharedWorkerRoot = Join-Path $SharedExternalWorker "AuroraWorker"
$SharedExeFlat = Join-Path $SharedExternalWorker "AuroraWorker.exe"
$SharedStatus = Join-Path $SharedExternalWorker "Status"
$SharedInstallStatusPath = Join-Path $SharedStatus "shared_worker_install_status.txt"
$DaemonTaskName = "AuroraWorker_Global"
$WatchdogTaskName = "AuroraWorker_Global_Watchdog"
$MemoryLimitPercent = 80
$CpuLimitPercent = 80

if (!(Test-Path $BuiltWorker)) {
    throw "Built worker folder not found: $BuiltWorker. Run build_worker.ps1 first."
}

New-Item -ItemType Directory -Force -Path $SharedWorkerRoot | Out-Null
New-Item -ItemType Directory -Force -Path $SharedStatus | Out-Null
Copy-Item -Path (Join-Path $BuiltWorker "*") -Destination $SharedWorkerRoot -Recurse -Force

$BuiltExe = Join-Path $SharedWorkerRoot "AuroraWorker.exe"
if (!(Test-Path $BuiltExe)) {
    throw "Install failed: AuroraWorker.exe missing after copy."
}

Copy-Item -Path $BuiltExe -Destination $SharedExeFlat -Force

function Register-AuroraTaskSafe {
    param(
        [string]$TaskName,
        [string]$Arguments,
        [string]$Description,
        [object]$Trigger
    )
    try {
        $Action = New-ScheduledTaskAction -Execute $BuiltExe -Argument $Arguments -WorkingDirectory $SharedWorkerRoot
        $Settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Days 0) -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1) -MultipleInstances IgnoreNew -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
        Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Settings $Settings -Description $Description -Force | Out-Null
        $Task = Get-ScheduledTask -TaskName $TaskName -ErrorAction Stop
        return @{ registered = $true; state = $Task.State.ToString(); error = "none" }
    } catch {
        return @{ registered = $false; state = "registration_failed"; error = ($_.Exception.Message -replace "\r?\n", " ") }
    }
}

$DaemonTrigger = New-ScheduledTaskTrigger -AtLogOn
$DaemonArgs = "--shared-root `"$SharedRoot`" --mode shared-daemon --poll-seconds 1 --memory-limit-percent $MemoryLimitPercent --cpu-limit-percent $CpuLimitPercent"
$Daemon = Register-AuroraTaskSafe -TaskName $DaemonTaskName -Arguments $DaemonArgs -Description "Aurora shared external worker daemon. Supervises all registered Aurora Core account roots. Calculation support only; no trade permission." -Trigger $DaemonTrigger

$WatchdogTrigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionInterval (New-TimeSpan -Minutes 1)
$WatchdogArgs = "--shared-root `"$SharedRoot`" --watchdog --memory-limit-percent $MemoryLimitPercent --cpu-limit-percent $CpuLimitPercent"
$Watchdog = Register-AuroraTaskSafe -TaskName $WatchdogTaskName -Arguments $WatchdogArgs -Description "Aurora external worker watchdog. Restarts stale or missing global daemon. Calculation support only; no trade permission." -Trigger $WatchdogTrigger

$FlatPresent = Test-Path $SharedExeFlat
$PackagedPresent = Test-Path $BuiltExe
$Now = [DateTimeOffset]::UtcNow
$NowUnix = $Now.ToUnixTimeSeconds()
$NowUtc = $Now.UtcDateTime.ToString("yyyy-MM-dd HH:mm:ss UTC")
$OperatorCmdRequired = -not ($Daemon.registered -and $Watchdog.registered)

$InstallText = @"
schema_name=aurora_worker_install_status
schema_version=4
installed=true
install_method=global_packaged_worker_plus_global_windows_scheduled_task_and_watchdog
worker_version=0.4.0
shared_daemon=true
shared_root=$SharedRoot
flat_exe_present=$($FlatPresent.ToString().ToLowerInvariant())
packaged_exe_present=$($PackagedPresent.ToString().ToLowerInvariant())
flat_exe_path=$SharedExeFlat
packaged_exe_path=$BuiltExe
daemon_install_method=windows_scheduled_task_shared_daemon
daemon_task_name=$DaemonTaskName
daemon_task_registered=$($Daemon.registered.ToString().ToLowerInvariant())
daemon_task_state=$($Daemon.state)
daemon_task_error=$($Daemon.error)
watchdog_install_method=windows_scheduled_task_repair_watchdog
watchdog_task_name=$WatchdogTaskName
watchdog_task_registered=$($Watchdog.registered.ToString().ToLowerInvariant())
watchdog_task_state=$($Watchdog.state)
watchdog_task_error=$($Watchdog.error)
scheduled_task_name=$DaemonTaskName
scheduled_task_registered=$($Daemon.registered.ToString().ToLowerInvariant())
scheduled_task_state=$($Daemon.state)
scheduled_task_error=$($Daemon.error)
auto_start_configured=$((($Daemon.registered -and $Watchdog.registered)).ToString().ToLowerInvariant())
operator_cmd_required=$($OperatorCmdRequired.ToString().ToLowerInvariant())
memory_limit_percent=$MemoryLimitPercent
cpu_limit_percent=$CpuLimitPercent
generated_unix=$NowUnix
generated_utc=$NowUtc
authority=calculation_support_only
trade_permission=false
"@

Set-Content -Path $SharedInstallStatusPath -Value $InstallText -Encoding ASCII

Write-Host "Installed shared worker folder: $SharedWorkerRoot"
Write-Host "Flat EXE copy for diagnostic detection: $SharedExeFlat"
Write-Host "Shared install status proof: $SharedInstallStatusPath"
Write-Host "Daemon task: $DaemonTaskName ($($Daemon.state))"
Write-Host "Watchdog task: $WatchdogTaskName ($($Watchdog.state))"
Write-Host "operator_cmd_required=$($OperatorCmdRequired.ToString().ToLowerInvariant())"
if (!$Daemon.registered) { Write-Host "Daemon task registration warning: $($Daemon.error)" }
if (!$Watchdog.registered) { Write-Host "Watchdog task registration warning: $($Watchdog.error)" }
