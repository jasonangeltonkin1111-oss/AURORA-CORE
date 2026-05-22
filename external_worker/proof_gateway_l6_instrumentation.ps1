$ErrorActionPreference = "Continue"

# Read-only proof script for EXE-003A instrumentation.
# This script does not start, stop, repair, rebuild, install, or launch Gateway.
# It only reads current Common\Files Gateway proof files and prints PASS/FAIL evidence.

$Root = Join-Path $env:APPDATA "MetaQuotes\Terminal\Common\Files\Aurora Core"
$GatewayStatusDir = Join-Path $Root "Gateway\Status"
$SharedStatus = Join-Path $GatewayStatusDir "shared_worker_status.txt"

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
    if ($Ok) { Write-Host "PASS|$Name|$Detail" }
    else { Write-Host "FAIL|$Name|$Detail" }
}

function Find-AccountRoots($RootPath) {
    $roots = @()
    if (!(Test-Path -LiteralPath $RootPath -PathType Container)) { return $roots }
    Get-ChildItem -LiteralPath $RootPath -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -ne "Gateway" -and $_.Name -ne "External Worker" } |
        ForEach-Object {
            $serverDir = $_
            Get-ChildItem -LiteralPath $serverDir.FullName -Directory -ErrorAction SilentlyContinue |
                ForEach-Object {
                    $accountDir = $_
                    $gateway = Join-Path $accountDir.FullName "Workbench\Gateway"
                    $result = Join-Path $gateway "Outbox\result_latest.txt"
                    if (Test-Path -LiteralPath $result -PathType Leaf) { $roots += $accountDir.FullName }
                }
        }
    return $roots
}

Write-Host "=== Aurora Gateway L6 Instrumentation Proof ==="
Write-Host "mode=read_only_no_start_no_stop_no_repair_no_install"
Write-Host "root=$Root"
Write-Host "shared_status=$SharedStatus"

$shared = Read-KvFile $SharedStatus
PassFail "shared_status_present" (Test-Path -LiteralPath $SharedStatus -PathType Leaf) $SharedStatus
if ($shared.Count -gt 0) {
    Write-Host ("shared_worker_version=" + (Field $shared "worker_version"))
    Write-Host ("shared_mode=" + (Field $shared "mode"))
    Write-Host ("shared_loop_count=" + (Field $shared "loop_count"))
    Write-Host ("shared_trade_permission=" + (Field $shared "trade_permission"))
    PassFail "shared_trade_permission_false" ((Field $shared "trade_permission") -eq "false") ("trade_permission=" + (Field $shared "trade_permission"))
}

$accountRoots = Find-AccountRoots $Root
PassFail "account_root_discovered" ($accountRoots.Count -gt 0) ("count=" + $accountRoots.Count)

foreach ($acct in $accountRoots) {
    $gateway = Join-Path $acct "Workbench\Gateway"
    $statusDir = Join-Path $gateway "Status"
    $outbox = Join-Path $gateway "Outbox"
    $resultPath = Join-Path $outbox "result_latest.txt"
    $manifestPath = Join-Path $outbox "result_latest.manifest"
    $processPath = Join-Path $statusDir "worker_process_status.txt"
    $heartbeatPath = Join-Path $statusDir "worker_heartbeat.txt"
    $l6ManifestPath = Join-Path $outbox "Layers\Layer_6_Cost_Friction_Ranking\ranked_symbols.manifest"

    Write-Host "--- account_root=$acct ---"
    PassFail "result_latest_present" (Test-Path -LiteralPath $resultPath -PathType Leaf) $resultPath
    PassFail "result_manifest_present" (Test-Path -LiteralPath $manifestPath -PathType Leaf) $manifestPath
    PassFail "process_status_present" (Test-Path -LiteralPath $processPath -PathType Leaf) $processPath
    PassFail "heartbeat_present" (Test-Path -LiteralPath $heartbeatPath -PathType Leaf) $heartbeatPath
    PassFail "l6_ranked_manifest_present" (Test-Path -LiteralPath $l6ManifestPath -PathType Leaf) $l6ManifestPath

    $result = Read-KvFile $resultPath
    $proc = Read-KvFile $processPath
    $hb = Read-KvFile $heartbeatPath
    $l6 = Read-KvFile $l6ManifestPath

    $duration = Field $result "l6_rank_duration_ms"
    $reused = Field $result "l6_rank_reused_existing_outputs"
    $schema = Field $result "l6_rank_instrumentation_schema"
    $rankStatus = Field $result "l6_rank_status"
    $rankReason = Field $result "l6_rank_reason"

    Write-Host "result_status=$(Field $result 'result_status')"
    Write-Host "job_status=$(Field $result 'job_status')"
    Write-Host "authority=$(Field $result 'authority')"
    Write-Host "trade_permission=$(Field $result 'trade_permission')"
    Write-Host "l6_rank_status=$rankStatus"
    Write-Host "l6_rank_reason=$rankReason"
    Write-Host "l6_rank_duration_ms=$duration"
    Write-Host "l6_rank_reused_existing_outputs=$reused"
    Write-Host "l6_rank_instrumentation_schema=$schema"
    Write-Host "process_mode=$(Field $proc 'mode')"
    Write-Host "process_loop_count=$(Field $proc 'loop_count')"
    Write-Host "heartbeat_worker_status=$(Field $hb 'worker_status')"
    Write-Host "l6_manifest_status=$(Field $l6 'status')"
    Write-Host "l6_symbol_rank_file_count_ok=$(Field $l6 'symbol_rank_file_count_ok')"

    $durationOk = $duration -match '^[0-9]+$'
    PassFail "l6_duration_present_integer" $durationOk "l6_rank_duration_ms=$duration"
    PassFail "l6_reuse_flag_present" ($reused -eq "true" -or $reused -eq "false") "l6_rank_reused_existing_outputs=$reused"
    PassFail "l6_instrumentation_schema_1" ($schema -eq "1") "l6_rank_instrumentation_schema=$schema"
    PassFail "gateway_result_complete" ((Field $result "result_status") -eq "complete") ("result_status=" + (Field $result "result_status"))
    PassFail "authority_safe" ((Field $result "authority") -eq "calculation_support_only") ("authority=" + (Field $result "authority"))
    PassFail "trade_permission_false" ((Field $result "trade_permission") -eq "false") ("trade_permission=" + (Field $result "trade_permission"))
    PassFail "l6_status_complete_or_truthful" ($rankStatus -eq "complete" -or $rankStatus -eq "input_degraded" -or $rankStatus -eq "write_degraded" -or $rankStatus -eq "input_changed_during_rank") "l6_rank_status=$rankStatus"
}

Write-Host "=== End proof ==="
