$ErrorActionPreference = "Continue"

# Gateway watchdog recovery proof.
# This is an intentional recovery test: it stops the daemon task and kills AuroraWorker once,
# then waits for the registered watchdog lane to restart the daemon.
# It does not rebuild, reinstall, modify source, repair files, or touch EA/MT5.
# Expected worker version is derived from aurora_worker.py, not hardcoded.

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$WorkerSource = Join-Path $ScriptDir "aurora_worker.py"
$Root = Join-Path $env:APPDATA "MetaQuotes\Terminal\Common\Files\Aurora Core"
$GatewayRoot = Join-Path $Root "Gateway"
$RuntimeDir = Join-Path $GatewayRoot "AuroraWorker"
$RuntimeExe = Join-Path $RuntimeDir "AuroraWorker.exe"
$SharedStatus = Join-Path $GatewayRoot "Status\shared_worker_status.txt"
$DaemonTask = "AuroraWorker_Global"
$WatchdogTask = "AuroraWorker_Global_Watchdog"
$MaxWaitSeconds = 150

function Read-KvFile($Path) {
    $map = @{}
    if (!(Test-Path -LiteralPath $Path -PathType Leaf)) { return $map }
    foreach ($line in Get-Content -LiteralPath $Path -ErrorAction SilentlyContinue) {
        if ($line -match '^([^=]+)=(.*)$') { $map[$matches[1].Trim()] = $matches[2].Trim() }
    }
    return $map
}

function Field($Map, $Key, $Default = "missing") {
    if ($Map.ContainsKey($Key)) { return $Map[$Key] }
    return $Default
}

function PassFail($Name, $Ok, $Detail) {
    if ($Ok) { Write-Host "PASS|$Name|$Detail" -ForegroundColor Green }
    else { Write-Host "FAIL|$Name|$Detail" -ForegroundColor Red }
}

function Get-SourceWorkerVersion($Path) {
    if (!(Test-Path -LiteralPath $Path -PathType Leaf)) { return "missing_source" }
    $m = Select-String -LiteralPath $Path -Pattern '^\s*WORKER_VERSION\s*=\s*"([^"]+)"' -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($null -eq $m) { return "version_not_found" }
    return $m.Matches[0].Groups[1].Value
}

function Show-TaskAction($TaskName) {
    $task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($null -eq $task) {
        PassFail "task_registered_$TaskName" $false "not_registered"
        return $false
    }
    PassFail "task_registered_$TaskName" $true "registered"
    Write-Host "task.$TaskName.state=$($task.State)"
    $action = $task.Actions | Select-Object -First 1
    if ($null -ne $action) {
        $execute = $action.Execute.Trim('"')
        $workdir = $action.WorkingDirectory.Trim('"')
        Write-Host "task.$TaskName.execute=$execute"
        Write-Host "task.$TaskName.arguments=$($action.Arguments)"
        Write-Host "task.$TaskName.working_directory=$workdir"
        PassFail "task_${TaskName}_execute_expected_runtime" ($execute -ieq $RuntimeExe) "actual=$execute expected=$RuntimeExe"
        PassFail "task_${TaskName}_workdir_expected_runtime" ($workdir -ieq $RuntimeDir) "actual=$workdir expected=$RuntimeDir"
    }
    return $true
}

$ExpectedWorkerVersion = Get-SourceWorkerVersion $WorkerSource

Write-Host "=== Aurora Gateway Watchdog Recovery Proof ==="
Write-Host "mode=intentional_daemon_kill_recovery_test"
Write-Host "root=$Root"
Write-Host "runtime_exe=$RuntimeExe"
Write-Host "expected_worker_version=$ExpectedWorkerVersion"
Write-Host "max_wait_seconds=$MaxWaitSeconds"

PassFail "expected_worker_version_valid" ($ExpectedWorkerVersion -ne "missing_source" -and $ExpectedWorkerVersion -ne "version_not_found") $ExpectedWorkerVersion
PassFail "runtime_exe_present" (Test-Path -LiteralPath $RuntimeExe -PathType Leaf) $RuntimeExe
$daemonOk = Show-TaskAction $DaemonTask
$watchdogOk = Show-TaskAction $WatchdogTask

if (!(Test-Path -LiteralPath $RuntimeExe -PathType Leaf) -or !$daemonOk -or !$watchdogOk -or $ExpectedWorkerVersion -eq "missing_source" -or $ExpectedWorkerVersion -eq "version_not_found") {
    Write-Host "DECISION=HOLD" -ForegroundColor Red
    Write-Host "REASON=Runtime EXE, source version, or scheduled tasks are missing. Rebuild/install/register before recovery proof."
    exit 1
}

Write-Host "--- killing daemon once for watchdog recovery proof ---" -ForegroundColor Yellow
Stop-ScheduledTask -TaskName $DaemonTask -ErrorAction SilentlyContinue | Out-Null
Start-Sleep -Seconds 2

Get-Process AuroraWorker -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host "killing_process.pid=$($_.Id)"
    Write-Host "killing_process.path=$($_.Path)"
    Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
}

Start-Sleep -Seconds 3
$deadCount = @(Get-Process AuroraWorker -ErrorAction SilentlyContinue).Count
PassFail "daemon_dead_before_watchdog_wait" ($deadCount -eq 0) "process_count=$deadCount"

$recovered = $false
$recoveredStep = -1
for ($i = 1; $i -le [int]($MaxWaitSeconds / 2); $i++) {
    Start-Sleep -Seconds 2
    $count = @(Get-Process AuroraWorker -ErrorAction SilentlyContinue).Count
    $daemon = Get-ScheduledTask -TaskName $DaemonTask -ErrorAction SilentlyContinue
    $daemonState = if ($null -ne $daemon) { $daemon.State.ToString() } else { "missing" }
    $kv = Read-KvFile $SharedStatus
    $versionOk = (Field $kv 'worker_version') -eq $ExpectedWorkerVersion
    $modeOk = (Field $kv 'mode') -eq 'shared-daemon'
    $loopSeen = (Field $kv 'loop_count') -match '^[0-9]+$'
    if ($count -ge 1 -and $daemonState -eq 'Running' -and $versionOk -and $modeOk -and $loopSeen) {
        $recovered = $true
        $recoveredStep = $i
        break
    }
    if (($i % 10) -eq 0) {
        Write-Host "waiting.step=$i process_count=$count daemon_state=$daemonState shared_worker_version=$(Field $kv 'worker_version') shared_mode=$(Field $kv 'mode') shared_loop_count=$(Field $kv 'loop_count')"
    }
}

PassFail "watchdog_restarted_daemon" $recovered "recovered=$recovered step=$recoveredStep"

$finalProcs = @(Get-Process AuroraWorker -ErrorAction SilentlyContinue)
Write-Host "final_aurora_worker_process_count=$($finalProcs.Count)"
foreach ($p in $finalProcs) {
    Write-Host "final_process.pid=$($p.Id)"
    Write-Host "final_process.path=$($p.Path)"
    PassFail "final_process_path_expected_runtime" ($p.Path -ieq $RuntimeExe) "actual=$($p.Path) expected=$RuntimeExe"
}

$finalKv = Read-KvFile $SharedStatus
Write-Host "shared_worker_version=$(Field $finalKv 'worker_version')"
Write-Host "shared_mode=$(Field $finalKv 'mode')"
Write-Host "shared_loop_count=$(Field $finalKv 'loop_count')"
Write-Host "shared_watchdog_last_check_utc=$(Field $finalKv 'watchdog_last_check_utc')"
Write-Host "shared_watchdog_last_action=$(Field $finalKv 'watchdog_last_action')"
Write-Host "shared_watchdog_last_reason=$(Field $finalKv 'watchdog_last_reason')"
Write-Host "shared_watchdog_restart_attempted=$(Field $finalKv 'watchdog_restart_attempted')"
Write-Host "shared_watchdog_restart_result=$(Field $finalKv 'watchdog_restart_result')"

if ($recovered) {
    Write-Host "DECISION=PROCEED" -ForegroundColor Green
    Write-Host "REASON=Watchdog recovery is proven: daemon was killed and returned with current shared-daemon status."
    exit 0
}

Write-Host "DECISION=HOLD" -ForegroundColor Red
Write-Host "REASON=Watchdog registration may exist, but recovery was not proven. Start daemon manually and inspect task permissions."
try { Start-ScheduledTask -TaskName $DaemonTask -ErrorAction SilentlyContinue | Out-Null } catch {}
exit 1
