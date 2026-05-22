$ErrorActionPreference = "Continue"

# Read-only proof script for REC-001 Gateway addendum recorder.
# This script does not start, stop, repair, rebuild, install, or launch Gateway.
# It only reads current Common\Files Gateway proof files and prints PASS/FAIL evidence.

$Root = Join-Path $env:APPDATA "MetaQuotes\Terminal\Common\Files\Aurora Core"
$GatewayStatusDir = Join-Path $Root "Gateway\Status"
$SharedStatus = Join-Path $GatewayStatusDir "shared_worker_status.txt"
$RecorderMaxBytes = 262144
$NearBoundBytes = 300000

function Read-KvFile($Path) {
    $map = @{}
    if (!(Test-Path -LiteralPath $Path -PathType Leaf)) { return $map }
    foreach ($line in Get-Content -LiteralPath $Path -ErrorAction SilentlyContinue) {
        if ($line -match '^([^=]+)=(.*)$') {
            $map[$matches[1].Trim()] = $matches[2].Trim()
        }
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

function Info($Name, $Detail) {
    Write-Host "INFO|$Name|$Detail" -ForegroundColor Cyan
}

function WarnInfo($Name, $Detail) {
    Write-Host "INFO|$Name|$Detail" -ForegroundColor Yellow
}

function Find-AccountRoots($RootPath) {
    $roots = @()
    if (!(Test-Path -LiteralPath $RootPath -PathType Container)) { return $roots }
    Get-ChildItem -LiteralPath $RootPath -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -notin @("Gateway", "External Worker") } |
        ForEach-Object {
            $serverDir = $_
            Get-ChildItem -LiteralPath $serverDir.FullName -Directory -ErrorAction SilentlyContinue |
                ForEach-Object {
                    $accountDir = $_
                    $gateway = Join-Path $accountDir.FullName "Workbench\Gateway"
                    $result = Join-Path $gateway "Outbox\result_latest.txt"
                    if (Test-Path -LiteralPath $gateway -PathType Container) {
                        $roots += $accountDir.FullName
                    } elseif (Test-Path -LiteralPath $result -PathType Leaf) {
                        $roots += $accountDir.FullName
                    }
                }
        }
    return $roots
}

function Count-MatchingLines($Lines, $Pattern) {
    return @($Lines | Where-Object { $_ -match $Pattern }).Count
}

function Get-FirstMatch($Lines, $Pattern) {
    $match = $Lines | Where-Object { $_ -match $Pattern } | Select-Object -First 1
    if ($null -eq $match) { return "not_found" }
    return $match
}

Write-Host "=== Aurora Gateway Recorder Proof ==="
Write-Host "mode=read_only_no_start_no_stop_no_repair_no_install_no_rebuild_no_launch"
Write-Host "root=$Root"
Write-Host "shared_status=$SharedStatus"
Write-Host "recorder_max_bytes=$RecorderMaxBytes"
Write-Host "near_bound_bytes=$NearBoundBytes"

$shared = Read-KvFile $SharedStatus
PassFail "shared_status_present" (Test-Path -LiteralPath $SharedStatus -PathType Leaf) $SharedStatus
if ($shared.Count -gt 0) {
    Write-Host ("shared_worker_version=" + (Field $shared "worker_version"))
    Write-Host ("shared_mode=" + (Field $shared "mode"))
    Write-Host ("shared_loop_count=" + (Field $shared "loop_count"))
    Write-Host ("shared_authority=" + (Field $shared "authority"))
    Write-Host ("shared_trade_permission=" + (Field $shared "trade_permission"))
    Write-Host ("shared_resource_throttle_active=" + (Field $shared "resource_throttle_active"))
    Write-Host ("shared_resource_throttle_reason=" + (Field $shared "resource_throttle_reason"))
    PassFail "shared_authority_safe" ((Field $shared "authority") -eq "calculation_support_only") ("authority=" + (Field $shared "authority"))
    PassFail "shared_trade_permission_false" ((Field $shared "trade_permission") -eq "false") ("trade_permission=" + (Field $shared "trade_permission"))
}

$accountRoots = Find-AccountRoots $Root
PassFail "account_root_discovered" ($accountRoots.Count -gt 0) ("count=" + $accountRoots.Count)

foreach ($acct in $accountRoots) {
    $gateway = Join-Path $acct "Workbench\Gateway"
    $statusDir = Join-Path $gateway "Status"
    $outbox = Join-Path $gateway "Outbox"
    $logsDir = Join-Path $gateway "Logs"
    $resultPath = Join-Path $outbox "result_latest.txt"
    $manifestPath = Join-Path $outbox "result_latest.manifest"
    $processPath = Join-Path $statusDir "worker_process_status.txt"
    $heartbeatPath = Join-Path $statusDir "worker_heartbeat.txt"
    $recorderLog = Join-Path $logsDir "gateway_addendum.log"

    Write-Host "--- account_root=$acct ---"
    PassFail "result_latest_present" (Test-Path -LiteralPath $resultPath -PathType Leaf) $resultPath
    PassFail "result_manifest_present" (Test-Path -LiteralPath $manifestPath -PathType Leaf) $manifestPath
    PassFail "process_status_present" (Test-Path -LiteralPath $processPath -PathType Leaf) $processPath
    PassFail "heartbeat_present" (Test-Path -LiteralPath $heartbeatPath -PathType Leaf) $heartbeatPath
    PassFail "recorder_log_present" (Test-Path -LiteralPath $recorderLog -PathType Leaf) $recorderLog

    $result = Read-KvFile $resultPath
    $proc = Read-KvFile $processPath
    $heartbeat = Read-KvFile $heartbeatPath

    if ($result.Count -gt 0) {
        Write-Host ("result_worker_version=" + (Field $result "worker_version"))
        Write-Host ("result_status=" + (Field $result "result_status"))
        Write-Host ("result_reason=" + (Field $result "result_reason"))
        Write-Host ("result_authority=" + (Field $result "authority"))
        Write-Host ("result_trade_permission=" + (Field $result "trade_permission"))
        Write-Host ("l6_rank_status=" + (Field $result "l6_rank_status"))
        Write-Host ("l6_rank_duration_ms=" + (Field $result "l6_rank_duration_ms"))
        Write-Host ("l6_rank_reused_existing_outputs=" + (Field $result "l6_rank_reused_existing_outputs"))
        Write-Host ("l7_rank_status=" + (Field $result "l7_rank_status"))
        Write-Host ("l7_rank_duration_ms=" + (Field $result "l7_rank_duration_ms"))
        PassFail "result_authority_safe" ((Field $result "authority") -eq "calculation_support_only") ("authority=" + (Field $result "authority"))
        PassFail "result_trade_permission_false" ((Field $result "trade_permission") -eq "false") ("trade_permission=" + (Field $result "trade_permission"))
    }

    if ($proc.Count -gt 0) {
        Write-Host ("process_worker_version=" + (Field $proc "worker_version"))
        Write-Host ("process_mode=" + (Field $proc "mode"))
        Write-Host ("process_loop_count=" + (Field $proc "loop_count"))
        Write-Host ("process_last_run_exit_code=" + (Field $proc "last_run_exit_code"))
        Write-Host ("process_last_validation_status=" + (Field $proc "last_validation_status"))
        PassFail "process_trade_permission_false" ((Field $proc "trade_permission") -eq "false") ("trade_permission=" + (Field $proc "trade_permission"))
    }

    if ($heartbeat.Count -gt 0) {
        Write-Host ("heartbeat_worker_status=" + (Field $heartbeat "worker_status"))
        Write-Host ("heartbeat_last_validation_status=" + (Field $heartbeat "last_validation_status"))
    }

    if (!(Test-Path -LiteralPath $recorderLog -PathType Leaf)) {
        WarnInfo "recorder_missing_hint" "If Gateway just started, let it run 2-3 daemon cycles and rerun. If result boundaries are publishing and this stays missing, REC-001 is not live."
        continue
    }

    $logItem = Get-Item -LiteralPath $recorderLog
    $logSize = $logItem.Length
    $logTail = @(Get-Content -LiteralPath $recorderLog -Tail 200 -ErrorAction SilentlyContinue)
    $allLogLines = @(Get-Content -LiteralPath $recorderLog -ErrorAction SilentlyContinue)
    $rotationFiles = @(Get-ChildItem -LiteralPath $logsDir -Filter "gateway_addendum.log.*" -File -ErrorAction SilentlyContinue)

    Write-Host "recorder_log_path=$recorderLog"
    Write-Host "recorder_log_size_bytes=$logSize"
    Write-Host "recorder_log_modified=$($logItem.LastWriteTime)"
    Write-Host "recorder_log_line_count=$($allLogLines.Count)"
    Write-Host "recorder_rotation_file_count=$($rotationFiles.Count)"

    foreach ($rot in $rotationFiles | Sort-Object Name) {
        Write-Host "rotation_file=$($rot.Name)|size=$($rot.Length)|modified=$($rot.LastWriteTime)"
    }

    $hasSchema = $logTail | Select-String -Pattern "schema_name=aurora_gateway_addendum_log" -Quiet
    $hasBoundary = $logTail | Select-String -Pattern "event=gateway_result_boundary" -Quiet
    $hasAuthority = $logTail | Select-String -Pattern "authority=calculation_support_only" -Quiet
    $hasTradeFalse = $logTail | Select-String -Pattern "trade_permission=false" -Quiet
    $hasCurrentWorker = $logTail | Select-String -Pattern "worker_version=0\.6\.6_l7_session_relevance_sidecar" -Quiet

    PassFail "recorder_schema_present" $hasSchema "schema_name=aurora_gateway_addendum_log"
    PassFail "recorder_boundary_event_present" $hasBoundary "event=gateway_result_boundary"
    PassFail "recorder_authority_safe" $hasAuthority "authority=calculation_support_only"
    PassFail "recorder_trade_permission_false" $hasTradeFalse "trade_permission=false"
    PassFail "recorder_current_worker_version_seen" $hasCurrentWorker "worker_version=0.6.6_l7_session_relevance_sidecar"

    $sizeOk = ($logSize -le $NearBoundBytes) -or ($rotationFiles.Count -gt 0)
    PassFail "recorder_size_near_bound_or_rotated" $sizeOk "size=$logSize maxBytes=$RecorderMaxBytes nearBound=$NearBoundBytes rotation_count=$($rotationFiles.Count)"

    $boundaryLines = @($logTail | Where-Object { $_ -match "event=gateway_result_boundary" })
    $exceptionLines = @($logTail | Where-Object { $_ -match "event=gateway_run_once_exception" })
    $uniqueBoundaryLines = @($boundaryLines | Sort-Object -Unique)

    Write-Host "recent_boundary_line_count=$($boundaryLines.Count)"
    Write-Host "recent_unique_boundary_line_count=$($uniqueBoundaryLines.Count)"
    Write-Host "recent_exception_line_count=$($exceptionLines.Count)"

    $loopText = Field $shared "loop_count" "0"
    $loopCount = 0
    if ($loopText -match '^[0-9]+$') { $loopCount = [int]$loopText }
    if ($loopCount -gt 20 -and $boundaryLines.Count -gt ($loopCount / 2)) {
        PassFail "recorder_no_obvious_boundary_spam" $false "recent_boundary_lines=$($boundaryLines.Count) shared_loop_count=$loopCount"
    } else {
        PassFail "recorder_no_obvious_boundary_spam" $true "recent_boundary_lines=$($boundaryLines.Count) shared_loop_count=$loopCount"
    }

    $duplicateRunLength = 0
    $last = ""
    $maxDuplicateRunLength = 0
    foreach ($line in $boundaryLines) {
        if ($line -eq $last) {
            $duplicateRunLength += 1
        } else {
            $duplicateRunLength = 1
            $last = $line
        }
        if ($duplicateRunLength -gt $maxDuplicateRunLength) { $maxDuplicateRunLength = $duplicateRunLength }
    }
    PassFail "recorder_no_identical_consecutive_boundary_spam" ($maxDuplicateRunLength -le 3) "max_identical_consecutive_boundary_lines=$maxDuplicateRunLength"

    Write-Host "first_boundary_sample=$(Get-FirstMatch $logTail 'event=gateway_result_boundary')"
    Write-Host "first_exception_sample=$(Get-FirstMatch $logTail 'event=gateway_run_once_exception')"

    Write-Host "---- recorder tail sample ----"
    $logTail | Select-Object -Last 10 | ForEach-Object { Write-Host $_ }
}

Write-Host "=== End recorder proof ==="
