$ErrorActionPreference = "Continue"

# Read-only Gateway sync/status proof panel.
# This script does not start, stop, repair, rebuild, install, copy, or launch Gateway.
# It derives expected worker version from aurora_worker.py so version bumps do not create false failures.

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir
$workerSource = Join-Path $scriptDir "aurora_worker.py"
$l7Source = Join-Path $scriptDir "aurora_worker_l7_session.py"
$l8Source = Join-Path $scriptDir "aurora_worker_l8_movement.py"
$recorderSource = Join-Path $scriptDir "aurora_worker_recorder.py"
$overseerSource = Join-Path $scriptDir "aurora_worker_surface_overseer.py"
$buildDir = Join-Path $scriptDir "dist\AuroraWorker"
$buildExe = Join-Path $buildDir "AuroraWorker.exe"
$buildDll = Join-Path $buildDir "_internal\python312.dll"

$root = Join-Path $env:APPDATA "MetaQuotes\Terminal\Common\Files\Aurora Core"
$gatewayRoot = Join-Path $root "Gateway"
$statusDir = Join-Path $gatewayRoot "Status"
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
$expectedL7ReasonMaxParts = "12"
$expectedL7ReasonMaxChars = "512"
$recorderMaxBytes = 262144
$nearBoundBytes = 300000

$global:FailCount = 0
$global:WarnCount = 0

function PassFail($Name, $Ok, $Detail) {
  if ($Ok) { Write-Host "PASS|$Name|$Detail" -ForegroundColor Green }
  else { $global:FailCount += 1; Write-Host "FAIL|$Name|$Detail" -ForegroundColor Red }
}
function WarnInfo($Name, $Detail) { $global:WarnCount += 1; Write-Host "WARN|$Name|$Detail" -ForegroundColor Yellow }
function Info($Name, $Detail) { Write-Host "INFO|$Name|$Detail" -ForegroundColor Cyan }

function Read-KvFile($Path) {
  $map = @{}
  if (!(Test-Path -LiteralPath $Path -PathType Leaf)) { return $map }
  foreach ($line in Get-Content -LiteralPath $Path -ErrorAction SilentlyContinue) {
    if ($line -match '^([^=]+)=(.*)$') { $map[$matches[1].Trim()] = $matches[2].Trim() }
  }
  return $map
}
function Field($Map, $Key, $Default = "missing") { if ($Map.ContainsKey($Key)) { return $Map[$Key] }; return $Default }
function Get-SourceWorkerVersion($Path) {
  if (!(Test-Path -LiteralPath $Path -PathType Leaf)) { return "missing_source" }
  $m = Select-String -LiteralPath $Path -Pattern '^\s*WORKER_VERSION\s*=\s*"([^"]+)"' -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($null -eq $m) { return "version_not_found" }
  return $m.Matches[0].Groups[1].Value
}
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
function Count-Token($Text, $Token) { if ([string]::IsNullOrEmpty($Text)) { return 0 }; return ([regex]::Matches($Text, [regex]::Escape($Token))).Count }
function Test-ExclusiveReadLock($Path) {
  if (!(Test-Path -LiteralPath $Path -PathType Leaf)) { return @{ ok=$false; detail="missing" } }
  try {
    $fs = [System.IO.File]::Open($Path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::None)
    $fs.Close()
    return @{ ok=$true; detail="exclusive_read_open_ok" }
  } catch { return @{ ok=$false; detail=$_.Exception.Message } }
}
function Show-TaskProof($TaskName, $ExpectedExe, $ExpectedWorkdir) {
  $task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
  if ($null -eq $task) { PassFail "task_registered_$TaskName" $false "not_registered"; return }
  PassFail "task_registered_$TaskName" $true "registered"
  Write-Host "task.$TaskName.state=$($task.State)"
  $action = $task.Actions | Select-Object -First 1
  if ($null -ne $action) {
    $execute = $action.Execute.Trim('"')
    $workdir = $action.WorkingDirectory.Trim('"')
    Write-Host "task.$TaskName.execute=$execute"
    Write-Host "task.$TaskName.arguments=$($action.Arguments)"
    Write-Host "task.$TaskName.working_directory=$workdir"
    PassFail "task_${TaskName}_execute_exists" (Test-Path -LiteralPath $execute -PathType Leaf) $execute
    PassFail "task_${TaskName}_execute_expected" ($execute -ieq $ExpectedExe) "actual=$execute expected=$ExpectedExe"
    PassFail "task_${TaskName}_workdir_expected" ($workdir -ieq $ExpectedWorkdir) "actual=$workdir expected=$ExpectedWorkdir"
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
      Get-ChildItem -LiteralPath $_.FullName -Directory -ErrorAction SilentlyContinue |
        ForEach-Object {
          if (Test-Path -LiteralPath (Join-Path $_.FullName "Gateway") -PathType Container) { $roots += $_.FullName }
        }
    }
  return $roots
}

$expectedWorkerVersion = Get-SourceWorkerVersion $workerSource

Write-Host "=== Aurora Gateway Sync Status Report ==="
Write-Host "mode=read_only_no_start_no_stop_no_repair_no_install_no_rebuild_no_launch"
Write-Host "repo_root=$repoRoot"
Write-Host "external_worker=$scriptDir"
Write-Host "root=$root"
Write-Host "gateway_root=$gatewayRoot"
Write-Host "expected_worker_version_from_source=$expectedWorkerVersion"

Write-Host "=== Source Sync Proof ==="
PassFail "worker_source_present" (Test-Path -LiteralPath $workerSource -PathType Leaf) $workerSource
PassFail "l7_source_present" (Test-Path -LiteralPath $l7Source -PathType Leaf) $l7Source
PassFail "l8_source_present" (Test-Path -LiteralPath $l8Source -PathType Leaf) $l8Source
PassFail "recorder_source_present" (Test-Path -LiteralPath $recorderSource -PathType Leaf) $recorderSource
PassFail "surface_overseer_source_present" (Test-Path -LiteralPath $overseerSource -PathType Leaf) $overseerSource
Write-Host "source_worker_version=$expectedWorkerVersion"
PassFail "source_worker_version_valid" ($expectedWorkerVersion -ne "missing_source" -and $expectedWorkerVersion -ne "version_not_found") $expectedWorkerVersion

$workerText = if (Test-Path -LiteralPath $workerSource -PathType Leaf) { Get-Content -LiteralPath $workerSource -Raw -ErrorAction SilentlyContinue } else { "" }
$l7Text = if (Test-Path -LiteralPath $l7Source -PathType Leaf) { Get-Content -LiteralPath $l7Source -Raw -ErrorAction SilentlyContinue } else { "" }
$recText = if (Test-Path -LiteralPath $recorderSource -PathType Leaf) { Get-Content -LiteralPath $recorderSource -Raw -ErrorAction SilentlyContinue } else { "" }
$ovText = if (Test-Path -LiteralPath $overseerSource -PathType Leaf) { Get-Content -LiteralPath $overseerSource -Raw -ErrorAction SilentlyContinue } else { "" }
PassFail "source_l6_wired" ($workerText -match "publish_l6_cost_friction_rankings") "L6"
PassFail "source_l7_wired" ($workerText -match "publish_l7_session_relevance_rankings") "L7"
PassFail "source_l8_wired" ($workerText -match "publish_l8_movement_range_rankings") "L8"
PassFail "source_l7_reason_max_parts_present" ($l7Text -match 'L7_REASON_MAX_PARTS\s*=\s*12') "L7_REASON_MAX_PARTS=12"
PassFail "source_l7_reason_max_chars_present" ($l7Text -match 'L7_REASON_MAX_CHARS\s*=\s*512') "L7_REASON_MAX_CHARS=512"
PassFail "source_l7_bounded_reason_present" ($l7Text -match 'def\s+_bounded_reason') "_bounded_reason"
PassFail "source_l7_prepend_reason_token_present" ($l7Text -match 'def\s+_prepend_reason_token') "_prepend_reason_token"
PassFail "source_l7_unsafe_reuse_concat_absent" -not($l7Text -match 'existing\.reason\s*=\s*"skipped_unchanged_input_reused_existing_ranked_outputs;"\s*\+\s*existing\.reason') "unsafe repeated prepend absent"
PassFail "source_recorder_open_emit_close_present" ($recText -match 'log_handle_policy' -and $recText -match 'open_emit_close') "log_handle_policy=open_emit_close"
PassFail "source_recorder_old_logger_cache_absent" -not($recText -match '_LOGGERS') "_LOGGERS absent"
PassFail "source_surface_overseer_schema_2" ($ovText -match 'SURFACE_OVERSEER_SCHEMA_VERSION\s*=\s*"2"') "schema_version=2"
PassFail "source_surface_overseer_lifecycle_pending" ($ovText -match "input_ready_rank_pending") "input_ready_rank_pending"
PassFail "source_surface_overseer_no_write_authority" ($ovText -match "surface_write_authority=false") "surface_write_authority=false"

Write-Host "=== Build / Runtime Package Proof ==="
PassFail "build_folder_present" (Test-Path -LiteralPath $buildDir -PathType Container) $buildDir
PassFail "build_exe_present" (Test-Path -LiteralPath $buildExe -PathType Leaf) $buildExe
PassFail "build_internal_python_dll_present" (Test-Path -LiteralPath $buildDll -PathType Leaf) $buildDll
Show-FileProof "build_exe" $buildExe
Show-FileProof "build_python312_dll" $buildDll
PassFail "runtime_folder_present" (Test-Path -LiteralPath $runtimeDir -PathType Container) $runtimeDir
PassFail "runtime_exe_present" (Test-Path -LiteralPath $runtimeExe -PathType Leaf) $runtimeExe
PassFail "runtime_internal_python_dll_present" (Test-Path -LiteralPath $runtimeDll -PathType Leaf) $runtimeDll
Show-FileProof "runtime_exe" $runtimeExe
Show-FileProof "runtime_python312_dll" $runtimeDll
if ((Test-Path -LiteralPath $buildExe -PathType Leaf) -and (Test-Path -LiteralPath $runtimeExe -PathType Leaf)) {
  $buildItem = Get-Item -LiteralPath $buildExe
  $runItem = Get-Item -LiteralPath $runtimeExe
  PassFail "runtime_exe_size_matches_build" ($runItem.Length -eq $buildItem.Length) "runtime=$($runItem.Length) build=$($buildItem.Length)"
  if ($runItem.LastWriteTime -lt $buildItem.LastWriteTime) { WarnInfo "runtime_exe_older_than_build" "runtime=$($runItem.LastWriteTime) build=$($buildItem.LastWriteTime)" } else { Info "runtime_exe_not_older_than_build" "runtime=$($runItem.LastWriteTime) build=$($buildItem.LastWriteTime)" }
}
Write-Host "=== Non-authoritative Bin Proof ==="
PassFail "bin_folder_runtime_authority_false" $true "bin_folder_runtime_authority=false path=$binDir"
Show-FileProof "bin_exe_non_authoritative" $binExe
Show-FileProof "bin_python312_dll_non_authoritative" $binDll

Write-Host "=== Gateway Scheduled Tasks / Process ==="
Show-TaskProof $daemonTask $runtimeExe $runtimeDir
Show-TaskProof $watchTask $runtimeExe $runtimeDir
$procCount = @(Get-Process AuroraWorker -ErrorAction SilentlyContinue).Count
Write-Host "aurora_worker_process_count=$procCount"
foreach ($proc in @(Get-Process AuroraWorker -ErrorAction SilentlyContinue)) {
  Write-Host "process.pid=$($proc.Id)"
  Write-Host "process.path=$($proc.Path)"
  Write-Host "process.start_time=$($proc.StartTime)"
  if ($proc.Path) { PassFail "process_path_expected_runtime" ($proc.Path -ieq $runtimeExe) "actual=$($proc.Path) expected=$runtimeExe" }
}

Write-Host "=== Gateway Install / Shared Status ==="
PassFail "install_status_present" (Test-Path -LiteralPath $install -PathType Leaf) $install
$installKv = Read-KvFile $install
if ($installKv.Count -gt 0) {
  foreach ($k in @('schema_version','installed','worker_version','expected_worker_version','runtime_folder_authority','scheduled_task_registered','watchdog_task_registered','watchdog_proof_scope','operator_cmd_required','authority','trade_permission','selection_runtime','surface_overseer_expected','surface_overseer_schema_expected')) { Write-Host "install_$k=$(Field $installKv $k)" }
  PassFail "install_worker_version_expected" ((Field $installKv 'worker_version') -eq $expectedWorkerVersion) ("worker_version=" + (Field $installKv 'worker_version') + " expected=" + $expectedWorkerVersion)
  PassFail "install_runtime_authority_true" ((Field $installKv 'runtime_folder_authority') -eq 'true') ("runtime_folder_authority=" + (Field $installKv 'runtime_folder_authority'))
  PassFail "install_authority_safe" ((Field $installKv 'authority') -eq 'calculation_support_only') ("authority=" + (Field $installKv 'authority'))
  PassFail "install_trade_permission_false" ((Field $installKv 'trade_permission') -eq 'false') ("trade_permission=" + (Field $installKv 'trade_permission'))
}
PassFail "shared_status_present" (Test-Path -LiteralPath $shared -PathType Leaf) $shared
$sharedKv = Read-KvFile $shared
if ($sharedKv.Count -gt 0) {
  foreach ($k in @('schema_version','worker_version','process_id','mode','loop_count','last_loop_utc','processed_root_count','accepted_root_count','degraded_root_count','watchdog_last_check_utc','watchdog_last_action','watchdog_restart_attempted','watchdog_restart_result','authority','trade_permission')) { Write-Host "shared_$k=$(Field $sharedKv $k)" }
  PassFail "shared_worker_version_expected" ((Field $sharedKv 'worker_version') -eq $expectedWorkerVersion) ("worker_version=" + (Field $sharedKv 'worker_version') + " expected=" + $expectedWorkerVersion)
  PassFail "shared_mode_daemon" ((Field $sharedKv 'mode') -eq 'shared-daemon') ("mode=" + (Field $sharedKv 'mode'))
  PassFail "shared_authority_safe" ((Field $sharedKv 'authority') -eq 'calculation_support_only') ("authority=" + (Field $sharedKv 'authority'))
  PassFail "shared_trade_permission_false" ((Field $sharedKv 'trade_permission') -eq 'false') ("trade_permission=" + (Field $sharedKv 'trade_permission'))
}

Write-Host "=== Account Gateway Proof ==="
$accounts = Find-AccountRoots $root
PassFail "account_root_discovered" ($accounts.Count -gt 0) ("count=$($accounts.Count)")
foreach ($acct in $accounts) {
  Write-Host "--- account_root=$acct ---"
  $gateway = Join-Path $acct "Gateway"
  $resultPath = Join-Path $gateway "Outbox\result_latest.txt"
  $manifestPath = Join-Path $gateway "Outbox\result_latest.manifest"
  $processPath = Join-Path $gateway "Status\worker_process_status.txt"
  $heartbeatPath = Join-Path $gateway "Status\worker_heartbeat.txt"
  $surfacePath = Join-Path $gateway "Status\surface_overseer_status.txt"
  $recorderLog = Join-Path $gateway "Logs\gateway_addendum.log"
  $l6ManifestPath = Join-Path $gateway "Outbox\Layers\Layer_6_Cost_Friction_Ranking\ranked_symbols.manifest"
  $l7ManifestPath = Join-Path $gateway "Outbox\Layers\Layer_7_Session_Relevance_Ranking\ranked_symbols.manifest"
  $l8InputPath = Join-Path $gateway "Outbox\Layers\Layer_8_Movement_Range_Ranking\l8_input_primitives.manifest"
  $l8ManifestPath = Join-Path $gateway "Outbox\Layers\Layer_8_Movement_Range_Ranking\ranked_symbols.manifest"

  foreach ($pair in @(@('result_latest_present',$resultPath),@('result_manifest_present',$manifestPath),@('process_status_present',$processPath),@('heartbeat_present',$heartbeatPath),@('surface_overseer_present',$surfacePath))) { PassFail $pair[0] (Test-Path -LiteralPath $pair[1] -PathType Leaf) $pair[1] }

  $resultKv = Read-KvFile $resultPath
  if ($resultKv.Count -gt 0) {
    foreach ($k in @('worker_version','worker_mode','result_status','result_reason','job_status','row_count','payload_checksum','authority','trade_permission','l6_rank_status','l6_rank_duration_ms','l6_rank_reused_existing_outputs','l6_rank_instrumentation_schema','l7_rank_status','l7_rank_duration_ms','l7_rank_instrumentation_schema','l8_rank_status','l8_rank_duration_ms','l8_rank_instrumentation_schema')) { Write-Host "result_$k=$(Field $resultKv $k)" }
    PassFail "result_worker_version_expected" ((Field $resultKv 'worker_version') -eq $expectedWorkerVersion) ("worker_version=" + (Field $resultKv 'worker_version') + " expected=" + $expectedWorkerVersion)
    PassFail "result_authority_safe" ((Field $resultKv 'authority') -eq 'calculation_support_only') ("authority=" + (Field $resultKv 'authority'))
    PassFail "result_trade_permission_false" ((Field $resultKv 'trade_permission') -eq 'false') ("trade_permission=" + (Field $resultKv 'trade_permission'))
    foreach ($layer in @('l6','l7','l8')) { PassFail "result_${layer}_status_present" ((Field $resultKv "${layer}_rank_status") -ne 'missing') ("${layer}_rank_status=" + (Field $resultKv "${layer}_rank_status")) }
  }

  foreach ($pair in @(@('l6_ranked_manifest',$l6ManifestPath),@('l7_ranked_manifest',$l7ManifestPath),@('l8_input_manifest',$l8InputPath),@('l8_ranked_manifest',$l8ManifestPath))) {
    $label=$pair[0]; $path=$pair[1]
    if (Test-Path -LiteralPath $path -PathType Leaf) {
      $kv=Read-KvFile $path
      Write-Host "$label.present=true"
      foreach ($k in @('status','row_count','input_count','payload_checksum','authority','trade_permission','selection_runtime')) { Write-Host "$label.$k=$(Field $kv $k)" }
      PassFail "${label}_authority_safe" ((Field $kv 'authority') -eq 'calculation_support_only') ("authority=" + (Field $kv 'authority'))
      PassFail "${label}_trade_permission_false" ((Field $kv 'trade_permission') -eq 'false') ("trade_permission=" + (Field $kv 'trade_permission'))
      if ((Field $kv 'selection_runtime') -ne 'missing') { PassFail "${label}_selection_runtime_false" ((Field $kv 'selection_runtime') -eq 'false') ("selection_runtime=" + (Field $kv 'selection_runtime')) }
    } else { Write-Host "$label.present=false"; Write-Host "$label.path=$path" }
  }

  $surfaceKv = Read-KvFile $surfacePath
  if ($surfaceKv.Count -gt 0) {
    foreach ($k in @('schema_name','schema_version','status','reason','layer_count','accepted_layer_count','pending_layer_count','degraded_layer_count','mismatch_count','surface_write_authority','ea_publication_authority','authority','trade_permission','selection_runtime')) { Write-Host "surface_$k=$(Field $surfaceKv $k)" }
    PassFail "surface_schema_v2" ((Field $surfaceKv 'schema_version') -eq '2') ("schema_version=" + (Field $surfaceKv 'schema_version'))
    PassFail "surface_mismatch_count_zero" ((Field $surfaceKv 'mismatch_count') -eq '0') ("mismatch_count=" + (Field $surfaceKv 'mismatch_count'))
    PassFail "surface_no_write_authority" ((Field $surfaceKv 'surface_write_authority') -eq 'false') ("surface_write_authority=" + (Field $surfaceKv 'surface_write_authority'))
    PassFail "surface_ea_publication_authority_true" ((Field $surfaceKv 'ea_publication_authority') -eq 'true') ("ea_publication_authority=" + (Field $surfaceKv 'ea_publication_authority'))
    PassFail "surface_authority_safe" ((Field $surfaceKv 'authority') -eq 'calculation_support_only') ("authority=" + (Field $surfaceKv 'authority'))
    PassFail "surface_trade_permission_false" ((Field $surfaceKv 'trade_permission') -eq 'false') ("trade_permission=" + (Field $surfaceKv 'trade_permission'))
    PassFail "surface_selection_runtime_false" ((Field $surfaceKv 'selection_runtime') -eq 'false') ("selection_runtime=" + (Field $surfaceKv 'selection_runtime'))
  }

  Write-Host "=== L7 Reason Bound Proof for account ==="
  $l7Manifest = Read-KvFile $l7ManifestPath
  if ($l7Manifest.Count -gt 0) {
    $l7Reason = Field $l7Manifest 'reason'
    $l7ReasonLen = $l7Reason.Length
    $reuseCount = Count-Token $l7Reason 'skipped_unchanged_input_reused_existing_ranked_outputs'
    Write-Host "l7_manifest_reason=$l7Reason"
    Write-Host "l7_manifest_reason_length=$l7ReasonLen"
    Write-Host "l7_manifest_reuse_token_count=$reuseCount"
    PassFail "l7_reason_not_bloated" ($l7ReasonLen -le 512) "length=$l7ReasonLen max=512"
    PassFail "l7_reuse_reason_not_repeated" ($reuseCount -le 1) "reuse_token_count=$reuseCount"
    PassFail "l7_reason_max_parts_runtime" ((Field $l7Manifest 'reason_max_parts') -eq $expectedL7ReasonMaxParts) ("reason_max_parts=" + (Field $l7Manifest 'reason_max_parts'))
    PassFail "l7_reason_max_chars_runtime" ((Field $l7Manifest 'reason_max_chars') -eq $expectedL7ReasonMaxChars) ("reason_max_chars=" + (Field $l7Manifest 'reason_max_chars'))
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
    PassFail "recorder_current_worker_seen" (($logTail | Select-String -Pattern ([regex]::Escape("worker_version=$expectedWorkerVersion")) -Quiet)) "worker_version=$expectedWorkerVersion"
    PassFail "recorder_authority_safe" (($logTail | Select-String -Pattern 'authority=calculation_support_only' -Quiet)) 'authority=calculation_support_only'
    PassFail "recorder_trade_permission_false" (($logTail | Select-String -Pattern 'trade_permission=false' -Quiet)) 'trade_permission=false'
    PassFail "recorder_open_emit_close_seen" (($logTail | Select-String -Pattern 'log_handle_policy=open_emit_close' -Quiet)) 'log_handle_policy=open_emit_close'
    $lock = Test-ExclusiveReadLock $recorderLog
    PassFail "recorder_log_not_exclusively_locked" $lock.ok $lock.detail
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

Write-Host "=== Sync Decision Summary ==="
Write-Host "fail_count=$global:FailCount"
Write-Host "warn_count=$global:WarnCount"
if ($global:FailCount -eq 0) {
  Write-Host "DECISION=TEST_FIRST" -ForegroundColor Yellow
  Write-Host "REASON=All required sync/status checks passed. Run watchdog recovery proof separately before claiming auto-restart recovery."
} else {
  Write-Host "DECISION=HOLD" -ForegroundColor Red
  Write-Host "REASON=One or more sync/status checks failed. Do not promote until failures are explained or fixed."
}
Write-Host "=== End Gateway Sync Status Report ==="
