$ErrorActionPreference = "Continue"

# Read-only Gateway status/proof panel.
# This script does not start, stop, repair, rebuild, install, or launch Gateway.
# It reports scheduled task paths, live process paths, install proof, shared daemon proof,
# account result proof, and REC-001 recorder evidence.

$root = Join-Path $env:APPDATA "MetaQuotes\Terminal\Common\Files\Aurora Core"
$gatewayRoot = Join-Path $root "Gateway"
$statusDir = Join-Path $gatewayRoot "Status"
$legacyStatusDir = Join-Path $root "External Worker\Status"
if (!(Test-Path -LiteralPath $statusDir -PathType Container) -and (Test-Path -LiteralPath $legacyStatusDir -PathType Container)) { $statusDir = $legacyStatusDir }

$install = Join-Path $statusDir "shared_worker_install_status.txt"
$shared = Join-Path $statusDir "shared_worker_status.txt"
$runtimeDir = Join-Path $gatewayRoot "AuroraWorker"
$runtimeExe = Join-Path $runtimeDir "AuroraWorker.exe"
$runtimeDll = Join-Path $runtimeDir "_internal\python312.dll"
$binDir = Join-Path $gatewayRoot "Bin"
$binExe = Join-Path $binDir "AuroraWorker.exe"
$binDll = Join-Path $binDir "_internal\python312.dll"
$daemonTask = "AuroraWorker_Global"
$watchTask = "AuroraWorker_Global_Watchdog"
$expectedWorkerVersion = "0.6.6_l7_session_relevance_sidecar"
$recorderMaxBytes = 262144
$nearBoundBytes = 300000

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

function Info($Name, $Detail) { Write-Host "INFO|$Name|$Detail" -ForegroundColor Cyan }
function WarnInfo($Name, $Detail) { Write-Host "INFO|$Name|$Detail" -ForegroundColor Yellow }

function Show-FileProof($Label, $Path) {
  if (Test-Path -LiteralPath $Path -PathType Leaf) {
    $item = Get-Item -LiteralPath $Path
    Write-Host "$Label.path=$($item.FullName)"
    Write-Host "$Label.exists=true"
    Write-Host "$Label.size_bytes=$($item.Length)"
    Write-Host "$Label.modified=$($item.LastWriteTime)"
  } else {
    Write-Host "$Label.path=$Path"
    Write-Host "$Label.exists=false"
  }
}

function Show-Fields($Path, $Fields, $Prefix) {
  $kv = Read-KvFile $Path
  if ($kv.Count -eq 0) {
    Write-Host "missing_or_empty: $Path"
    return $kv
  }
  foreach ($f in $Fields) { Write-Host "$Prefix$f=$(Field $kv $f)" }
  return $kv
}

function Get-TaskActionPath($TaskName) {
  $task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
  if ($null -eq $task) { return "not_registered" }
  $action = $task.Actions | Select-Object -First 1
  if ($null -eq $action -or !$action.Execute) { return "missing_action" }
  return $action.Execute.Trim('"')
}

function Show-TaskProof($TaskName, $ExpectedExe, $ExpectedWorkdir) {
  $task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
  if ($null -eq $task) {
    PassFail "task_registered_$TaskName" $false "not_registered"
    return
  }
  PassFail "task_registered_$TaskName" $true "registered"
  Write-Host "task.$TaskName.state=$($task.State)"
  $idx = 0
  foreach ($action in $task.Actions) {
    $idx += 1
    $execute = $action.Execute.Trim('"')
    $workdir = $action.WorkingDirectory.Trim('"')
    Write-Host "task.$TaskName.action_$idx.execute=$execute"
    Write-Host "task.$TaskName.action_$idx.arguments=$($action.Arguments)"
    Write-Host "task.$TaskName.action_$idx.working_directory=$workdir"
    PassFail "task_${TaskName}_execute_exists" (Test-Path -LiteralPath $execute -PathType Leaf) $execute
    if ($ExpectedExe -ne "") { PassFail "task_${TaskName}_execute_expected" ($execute -ieq $ExpectedExe) "actual=$execute expected=$ExpectedExe" }
    if ($ExpectedWorkdir -ne "") { PassFail "task_${TaskName}_workdir_expected" ($workdir -ieq $ExpectedWorkdir) "actual=$workdir expected=$ExpectedWorkdir" }
  }
  $info = Get-ScheduledTaskInfo -TaskName $TaskName -ErrorAction SilentlyContinue
  if ($null -ne $info) {
    Write-Host "task.$TaskName.last_run_time=$($info.LastRunTime)"
    Write-Host "task.$TaskName.last_task_result=$($info.LastTaskResult)"
    Write-Host "task.$TaskName.next_run_time=$($info.NextRunTime)"
  }
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
          if (Test-Path -LiteralPath $gateway -PathType Container) { $roots += $accountDir.FullName }
        }
    }
  return $roots
}

Write-Host "=== Aurora Gateway Status Proof ==="
Write-Host "mode=read_only_no_start_no_stop_no_repair_no_install_no_rebuild_no_launch"
Write-Host "root=$root"
Write-Host "gateway_root=$gatewayRoot"
Write-Host "expected_worker_version=$expectedWorkerVersion"

Write-Host "=== Runtime Package Proof ==="
PassFail "runtime_folder_present" (Test-Path -LiteralPath $runtimeDir -PathType Container) $runtimeDir
PassFail "runtime_exe_present" (Test-Path -LiteralPath $runtimeExe -PathType Leaf) $runtimeExe
PassFail "runtime_internal_python_dll_present" (Test-Path -LiteralPath $runtimeDll -PathType Leaf) $runtimeDll
Show-FileProof "runtime_exe" $runtimeExe
Show-FileProof "runtime_python312_dll" $runtimeDll

Write-Host "=== Non-authoritative Bin Proof ==="
PassFail "bin_folder_non_authoritative_present_or_absent" $true "bin_folder_runtime_authority=false path=$binDir"
Show-FileProof "bin_exe_non_authoritative" $binExe
Show-FileProof "bin_python312_dll_non_authoritative" $binDll

Write-Host "=== Gateway Scheduled Tasks ==="
Show-TaskProof $daemonTask $runtimeExe $runtimeDir
Show-TaskProof $watchTask $runtimeExe $runtimeDir

$procCount = @(Get-Process AuroraWorker -ErrorAction SilentlyContinue).Count
Write-Host "aurora_worker_process_count=$procCount"
$procs = @(Get-Process AuroraWorker -ErrorAction SilentlyContinue)
foreach ($proc in $procs) {
  Write-Host "process.pid=$($proc.Id)"
  Write-Host "process.path=$($proc.Path)"
  Write-Host "process.start_time=$($proc.StartTime)"
  if ($proc.Path) { PassFail "process_path_expected_runtime" ($proc.Path -ieq $runtimeExe) "actual=$($proc.Path) expected=$runtimeExe" }
}

Write-Host "=== Gateway Install Proof ==="
PassFail "install_status_present" (Test-Path -LiteralPath $install -PathType Leaf) $install
$installKv = Show-Fields $install @('schema_version','installed','worker_version','expected_worker_version','runtime_folder','runtime_folder_authority','runtime_exe_path','bin_folder_runtime_authority','packaged_exe_present','packaged_internal_python_dll_present','scheduled_task_registered','scheduled_task_state','watchdog_task_registered','watchdog_task_state','watchdog_proof_scope','operator_cmd_required','authority','trade_permission') "install_"
if ($installKv.Count -gt 0) {
  PassFail "install_worker_version_expected" ((Field $installKv 'worker_version') -eq $expectedWorkerVersion) ("worker_version=" + (Field $installKv 'worker_version'))
  PassFail "install_runtime_authority_true" ((Field $installKv 'runtime_folder_authority') -eq 'true') ("runtime_folder_authority=" + (Field $installKv 'runtime_folder_authority'))
  PassFail "install_bin_authority_false" ((Field $installKv 'bin_folder_runtime_authority') -eq 'false' -or (Field $installKv 'bin_folder_runtime_authority') -eq 'missing') ("bin_folder_runtime_authority=" + (Field $installKv 'bin_folder_runtime_authority'))
  PassFail "install_authority_safe" ((Field $installKv 'authority') -eq 'calculation_support_only') ("authority=" + (Field $installKv 'authority'))
  PassFail "install_trade_permission_false" ((Field $installKv 'trade_permission') -eq 'false') ("trade_permission=" + (Field $installKv 'trade_permission'))
}

Write-Host "=== Gateway Shared Status ==="
PassFail "shared_status_present" (Test-Path -LiteralPath $shared -PathType Leaf) $shared
$sharedKv = Show-Fields $shared @('schema_version','worker_version','process_id','mode','loop_count','last_loop_utc','last_loop_unix','processed_root_count','accepted_root_count','degraded_root_count','write_degraded_root_count','watchdog_last_check_utc','watchdog_last_action','watchdog_last_reason','watchdog_restart_attempted','watchdog_restart_result','operator_cmd_required','memory_used_percent','resource_throttle_active','resource_throttle_reason','recommended_parallel_jobs','authority','trade_permission') "shared_"
if ($sharedKv.Count -gt 0) {
  PassFail "shared_worker_version_expected" ((Field $sharedKv 'worker_version') -eq $expectedWorkerVersion) ("worker_version=" + (Field $sharedKv 'worker_version'))
  PassFail "shared_mode_daemon" ((Field $sharedKv 'mode') -eq 'shared-daemon') ("mode=" + (Field $sharedKv 'mode'))
  PassFail "shared_authority_safe" ((Field $sharedKv 'authority') -eq 'calculation_support_only') ("authority=" + (Field $sharedKv 'authority'))
  PassFail "shared_trade_permission_false" ((Field $sharedKv 'trade_permission') -eq 'false') ("trade_permission=" + (Field $sharedKv 'trade_permission'))
}

Write-Host "=== Account Gateway Proof ==="
$accounts = Find-AccountRoots $root
PassFail "account_root_discovered" ($accounts.Count -gt 0) ("count=$($accounts.Count)")
foreach ($acct in $accounts) {
  Write-Host "--- account_root=$acct ---"
  $gateway = Join-Path $acct "Workbench\Gateway"
  $resultPath = Join-Path $gateway "Outbox\result_latest.txt"
  $manifestPath = Join-Path $gateway "Outbox\result_latest.manifest"
  $processPath = Join-Path $gateway "Status\worker_process_status.txt"
  $heartbeatPath = Join-Path $gateway "Status\worker_heartbeat.txt"
  $recorderLog = Join-Path $gateway "Logs\gateway_addendum.log"

  PassFail "result_latest_present" (Test-Path -LiteralPath $resultPath -PathType Leaf) $resultPath
  PassFail "result_manifest_present" (Test-Path -LiteralPath $manifestPath -PathType Leaf) $manifestPath
  PassFail "process_status_present" (Test-Path -LiteralPath $processPath -PathType Leaf) $processPath
  PassFail "heartbeat_present" (Test-Path -LiteralPath $heartbeatPath -PathType Leaf) $heartbeatPath

  $resultKv = Show-Fields $resultPath @('worker_version','worker_mode','result_status','result_reason','job_status','row_count','payload_checksum','authority','trade_permission','l6_rank_status','l6_rank_duration_ms','l6_rank_reused_existing_outputs','l6_rank_instrumentation_schema','l7_rank_status','l7_rank_duration_ms','l7_rank_instrumentation_schema') "result_"
  if ($resultKv.Count -gt 0) {
    PassFail "result_worker_version_expected" ((Field $resultKv 'worker_version') -eq $expectedWorkerVersion) ("worker_version=" + (Field $resultKv 'worker_version'))
    PassFail "result_l6_duration_integer" ((Field $resultKv 'l6_rank_duration_ms') -match '^[0-9]+$') ("l6_rank_duration_ms=" + (Field $resultKv 'l6_rank_duration_ms'))
    PassFail "result_l6_reuse_flag" ((Field $resultKv 'l6_rank_reused_existing_outputs') -in @('true','false')) ("l6_rank_reused_existing_outputs=" + (Field $resultKv 'l6_rank_reused_existing_outputs'))
    PassFail "result_l6_schema_1" ((Field $resultKv 'l6_rank_instrumentation_schema') -eq '1') ("l6_rank_instrumentation_schema=" + (Field $resultKv 'l6_rank_instrumentation_schema'))
    PassFail "result_l7_status_present" ((Field $resultKv 'l7_rank_status') -ne 'missing') ("l7_rank_status=" + (Field $resultKv 'l7_rank_status'))
    PassFail "result_l7_duration_present" ((Field $resultKv 'l7_rank_duration_ms') -ne 'missing') ("l7_rank_duration_ms=" + (Field $resultKv 'l7_rank_duration_ms'))
    PassFail "result_l7_schema_1" ((Field $resultKv 'l7_rank_instrumentation_schema') -eq '1') ("l7_rank_instrumentation_schema=" + (Field $resultKv 'l7_rank_instrumentation_schema'))
    PassFail "result_authority_safe" ((Field $resultKv 'authority') -eq 'calculation_support_only') ("authority=" + (Field $resultKv 'authority'))
    PassFail "result_trade_permission_false" ((Field $resultKv 'trade_permission') -eq 'false') ("trade_permission=" + (Field $resultKv 'trade_permission'))
  }

  Write-Host "=== REC-001 Recorder Proof for account ==="
  PassFail "recorder_log_present" (Test-Path -LiteralPath $recorderLog -PathType Leaf) $recorderLog
  if (Test-Path -LiteralPath $recorderLog -PathType Leaf) {
    $logItem = Get-Item -LiteralPath $recorderLog
    $logTail = @(Get-Content -LiteralPath $recorderLog -Tail 200 -ErrorAction SilentlyContinue)
    $rotationFiles = @(Get-ChildItem -LiteralPath (Split-Path -Parent $recorderLog) -Filter 'gateway_addendum.log.*' -File -ErrorAction SilentlyContinue)
    Write-Host "recorder_log_size_bytes=$($logItem.Length)"
    Write-Host "recorder_log_modified=$($logItem.LastWriteTime)"
    Write-Host "recorder_recent_line_count=$($logTail.Count)"
    Write-Host "recorder_rotation_file_count=$($rotationFiles.Count)"
    PassFail "recorder_schema_present" (($logTail | Select-String -Pattern 'schema_name=aurora_gateway_addendum_log' -Quiet)) 'schema_name=aurora_gateway_addendum_log'
    PassFail "recorder_boundary_event_present" (($logTail | Select-String -Pattern 'event=gateway_result_boundary' -Quiet)) 'event=gateway_result_boundary'
    PassFail "recorder_current_worker_seen" (($logTail | Select-String -Pattern 'worker_version=0\.6\.6_l7_session_relevance_sidecar' -Quiet)) 'worker_version=0.6.6_l7_session_relevance_sidecar'
    PassFail "recorder_authority_safe" (($logTail | Select-String -Pattern 'authority=calculation_support_only' -Quiet)) 'authority=calculation_support_only'
    PassFail "recorder_trade_permission_false" (($logTail | Select-String -Pattern 'trade_permission=false' -Quiet)) 'trade_permission=false'
    $sizeOk = ($logItem.Length -le $nearBoundBytes) -or ($rotationFiles.Count -gt 0)
    PassFail "recorder_size_near_bound_or_rotated" $sizeOk "size=$($logItem.Length) maxBytes=$recorderMaxBytes nearBound=$nearBoundBytes rotation_count=$($rotationFiles.Count)"
    $boundaryLines = @($logTail | Where-Object { $_ -match 'event=gateway_result_boundary' })
    $loopText = Field $sharedKv 'loop_count' '0'
    $loopCount = 0
    if ($loopText -match '^[0-9]+$') { $loopCount = [int]$loopText }
    $spamOk = !($loopCount -gt 20 -and $boundaryLines.Count -gt ($loopCount / 2))
    PassFail "recorder_no_obvious_boundary_spam" $spamOk "recent_boundary_lines=$($boundaryLines.Count) shared_loop_count=$loopCount"
  }
}

Write-Host "=== End Gateway Status Proof ==="
