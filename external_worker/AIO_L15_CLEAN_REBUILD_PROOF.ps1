$ErrorActionPreference = "Stop"

$StartedUtc = (Get-Date).ToUniversalTime()
$TargetWorkerVersion = "0.6.15_l15_correlation_diversity"

function Read-Kv {
  param([string]$Path, [string]$Key)
  if (!(Test-Path -LiteralPath $Path)) { return "MISSING" }
  $line = Get-Content -LiteralPath $Path -ErrorAction SilentlyContinue |
    Where-Object { $_ -match ('^\s*' + [regex]::Escape($Key) + '\s*=') } |
    Select-Object -First 1
  if (!$line) { return "MISSING" }
  return (($line -split '=', 2)[1]).Trim()
}

function Contains-Text {
  param([string]$Path, [string]$Needle)
  if (!(Test-Path -LiteralPath $Path)) { return $false }
  return Select-String -LiteralPath $Path -Pattern $Needle -SimpleMatch -Quiet -ErrorAction SilentlyContinue
}

function Hash-File {
  param([string]$Path)
  if (!(Test-Path -LiteralPath $Path)) { return "MISSING" }
  return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
}

function Fresh-After {
  param([string]$Path, [datetime]$Time)
  if (!(Test-Path -LiteralPath $Path)) { return $false }
  return ((Get-Item -LiteralPath $Path).LastWriteTimeUtc -ge $Time)
}

function Assert-NoConflictMarkers {
  param([string[]]$Paths)
  $bad = @()
  foreach ($p in $Paths) {
    if (!(Test-Path -LiteralPath $p)) { continue }
    $text = Get-Content -LiteralPath $p -Raw -ErrorAction SilentlyContinue
    if ($text -match "<<<<<<<|=======|>>>>>>>") { $bad += $p }
  }
  if ($bad.Count -gt 0) {
    Write-Host "MERGE CONFLICT MARKERS FOUND" -ForegroundColor Red
    foreach ($p in $bad) { Write-Host "- $p" -ForegroundColor Red }
    throw "Conflict markers found. Refusing rebuild."
  }
}

function Set-WorkerVersion {
  param([string]$Path, [string]$Version)
  $text = Get-Content -LiteralPath $Path -Raw
  $pattern = '(?m)^\s*WORKER_VERSION\s*=\s*"[^"]+"\s*$'
  if ($text -notmatch $pattern) { throw "WORKER_VERSION not found in $Path" }

  $old = ([regex]::Match($text, 'WORKER_VERSION\s*=\s*"([^"]+)"')).Groups[1].Value
  if ($old -ne $Version) {
    $text = $text -replace $pattern, ('WORKER_VERSION = "' + $Version + '"')
    Set-Content -LiteralPath $Path -Value $text -Encoding UTF8
    Write-Host "patched_worker_version=$old->$Version" -ForegroundColor Green
  } else {
    Write-Host "worker_version_already=$Version" -ForegroundColor Green
  }
}

function Compile-Py {
  param([string]$Path)
  python -m py_compile $Path
  if ($LASTEXITCODE -ne 0) { throw "Python compile failed: $Path" }
}

function Stop-Workers {
  foreach ($task in @("AuroraWorker_Global_Watchdog", "AuroraWorker_Global")) {
    Stop-ScheduledTask -TaskName $task -ErrorAction SilentlyContinue
  }

  Start-Sleep -Seconds 2

  $procs = @(Get-CimInstance Win32_Process -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -eq "AuroraWorker.exe" -and $_.CommandLine -match "Aurora Core" })

  foreach ($p in $procs) {
    Write-Host "killing_worker_pid=$($p.ProcessId)"
    Stop-Process -Id $p.ProcessId -Force -ErrorAction SilentlyContinue
  }

  Start-Sleep -Seconds 3

  $left = @(Get-CimInstance Win32_Process -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -eq "AuroraWorker.exe" -and $_.CommandLine -match "Aurora Core" })

  if ($left.Count -gt 0) { throw "Workers still alive after stop. Refusing rebuild." }
  Write-Host "workers_stopped_cleanly=true" -ForegroundColor Green
}

function Find-AccountRoot {
  param([string]$SharedRoot)
  $hits = Get-ChildItem -LiteralPath $SharedRoot -Directory -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -ne "Gateway" } |
    ForEach-Object {
      Get-ChildItem -LiteralPath $_.FullName -Directory -ErrorAction SilentlyContinue |
        ForEach-Object {
          $status = Join-Path $_.FullName "Workbench\Gateway\Status\worker_process_status.txt"
          if (Test-Path -LiteralPath $status) {
            [pscustomobject]@{
              AccountRoot = $_.FullName
              ModifiedUtc = (Get-Item -LiteralPath $status).LastWriteTimeUtc
            }
          }
        }
    } |
    Sort-Object ModifiedUtc -Descending

  if (@($hits).Count -eq 0) { return $null }
  return $hits[0].AccountRoot
}

$terminalBase = Join-Path $env:APPDATA "MetaQuotes\Terminal"
$repo = Get-ChildItem -LiteralPath $terminalBase -Directory -ErrorAction SilentlyContinue |
  ForEach-Object { Join-Path $_.FullName "MQL5\Include\AURORA-CORE" } |
  Where-Object { Test-Path -LiteralPath (Join-Path $_ "external_worker\aurora_worker.py") } |
  Select-Object -First 1

if (!$repo) { throw "AURORA-CORE repo not found." }

$external = Join-Path $repo "external_worker"
$workerPy = Join-Path $external "aurora_worker.py"
$entrypoint = Join-Path $external "aurora_worker_entrypoint.py"
$installScript = Join-Path $external "install_worker_global.ps1"
$watchdogScript = Join-Path $external "register_watchdog_safe.ps1"
$spec = Join-Path $external "AuroraWorker.spec"

$buildRoot = Join-Path $external "build\AuroraWorker"
$distRoot = Join-Path $external "dist\AuroraWorker"
$distExe = Join-Path $distRoot "AuroraWorker.exe"
$distDll = Join-Path $distRoot "_internal\python312.dll"

$sharedRoot = Join-Path $env:APPDATA "MetaQuotes\Terminal\Common\Files\Aurora Core"
$runtimeRoot = Join-Path $sharedRoot "Gateway\AuroraWorker"
$runtimeExe = Join-Path $runtimeRoot "AuroraWorker.exe"
$runtimeDll = Join-Path $runtimeRoot "_internal\python312.dll"
$installStatus = Join-Path $sharedRoot "Gateway\Status\shared_worker_install_status.txt"

Write-Host ""
Write-Host "AURORA CORE L15 CLEAN AIO / REBUILD / RUNTIME PROOF" -ForegroundColor Cyan
Write-Host "repo=$repo"
Write-Host "external=$external"

$sourceFiles = @(Get-ChildItem -LiteralPath $external -File -ErrorAction SilentlyContinue |
  Where-Object {
    $_.Name -eq "aurora_worker.py" -or
    $_.Name -eq "aurora_worker_entrypoint.py" -or
    $_.Name -eq "AuroraWorker.spec" -or
    $_.Name -like "aurora_worker_l*.py"
  } |
  ForEach-Object { $_.FullName })

Assert-NoConflictMarkers $sourceFiles

foreach ($required in @(
  "aurora_worker_l14.py",
  "aurora_worker_l14_dispatch.py",
  "aurora_worker_l15.py",
  "aurora_worker_l15_dispatch.py"
)) {
  $p = Join-Path $external $required
  if (!(Test-Path -LiteralPath $p)) { throw "missing_required_file=$p" }
}

Write-Host ""
Write-Host "VERIFY SOURCE CONTRACT" -ForegroundColor Green

Set-WorkerVersion $workerPy $TargetWorkerVersion

$checks = @{
  "entrypoint_imports_l15" = Contains-Text $entrypoint "from aurora_worker_l15_dispatch import run_l15_after_l14"
  "entrypoint_gate_l15" = Contains-Text $entrypoint "ENABLE_L15_RUNTIME = True"
  "entrypoint_calls_l15" = Contains-Text $entrypoint "run_l15_after_l14(root)"
  "entrypoint_reads_l15_status" = Contains-Text $entrypoint "l15_correlation_diversity_status"
  "entrypoint_l15_runtime_enabled" = Contains-Text $entrypoint "l15_runtime_enabled"
  "entrypoint_schema_v6_or_v7" = ((Contains-Text $entrypoint "schema_version=6") -or (Contains-Text $entrypoint "schema_version=7"))
  "spec_has_l15_worker" = Contains-Text $spec "'aurora_worker_l15'"
  "spec_has_l15_dispatch" = Contains-Text $spec "'aurora_worker_l15_dispatch'"
  "install_expected_l15" = Contains-Text $installScript '$ExpectedWorkerVersion = "0.6.15_l15_correlation_diversity"'
  "l15_worker_has_publisher" = Contains-Text (Join-Path $external "aurora_worker_l15.py") "publish_l15_correlation_diversity_selection"
  "l15_dispatch_has_runner" = Contains-Text (Join-Path $external "aurora_worker_l15_dispatch.py") "run_l15_after_l14"
  "l15_dispatch_has_status" = Contains-Text (Join-Path $external "aurora_worker_l15_dispatch.py") "l15_correlation_diversity_status"
}

foreach ($k in $checks.Keys) {
  Write-Host "$k=$($checks[$k])"
  if (!$checks[$k]) { throw "static_check_failed=$k" }
}

Write-Host ""
Write-Host "PYTHON COMPILE" -ForegroundColor Green

$compileFiles = Get-ChildItem -LiteralPath $external -File -ErrorAction SilentlyContinue |
  Where-Object {
    $_.Name -eq "aurora_worker.py" -or
    $_.Name -eq "aurora_worker_entrypoint.py" -or
    $_.Name -eq "aurora_worker_io.py" -or
    $_.Name -eq "aurora_worker_render_index.py" -or
    $_.Name -eq "aurora_worker_surface_overseer.py" -or
    $_.Name -like "aurora_worker_l6*.py" -or
    $_.Name -like "aurora_worker_l7*.py" -or
    $_.Name -like "aurora_worker_l8*.py" -or
    $_.Name -like "aurora_worker_l9*.py" -or
    $_.Name -like "aurora_worker_l10*.py" -or
    $_.Name -like "aurora_worker_l11*.py" -or
    $_.Name -like "aurora_worker_l12*.py" -or
    $_.Name -like "aurora_worker_l13*.py" -or
    $_.Name -like "aurora_worker_l14*.py" -or
    $_.Name -like "aurora_worker_l15*.py"
  }

foreach ($f in $compileFiles) {
  Compile-Py $f.FullName
  Write-Host "$($f.Name)=PASS"
}

$tokens = $null; $errors = $null
[System.Management.Automation.Language.Parser]::ParseFile($installScript, [ref]$tokens, [ref]$errors) | Out-Null
if ($errors.Count -gt 0) { throw "install_worker_global.ps1 parse failed: $($errors[0].Message)" }

$tokens = $null; $errors = $null
[System.Management.Automation.Language.Parser]::ParseFile($watchdogScript, [ref]$tokens, [ref]$errors) | Out-Null
if ($errors.Count -gt 0) { throw "register_watchdog_safe.ps1 parse failed: $($errors[0].Message)" }

Write-Host "powershell_parse=PASS"

Write-Host ""
Write-Host "REBUILD PACKAGE" -ForegroundColor Green

Stop-Workers

foreach ($generated in @($buildRoot, $distRoot)) {
  if (Test-Path -LiteralPath $generated) {
    Remove-Item -LiteralPath $generated -Recurse -Force
    Write-Host "removed_generated=$generated"
  }
}

Push-Location $external
pyinstaller --noconfirm ".\AuroraWorker.spec"
$pyExit = $LASTEXITCODE
Pop-Location

if ($pyExit -ne 0) { throw "PyInstaller failed exit=$pyExit" }
if (!(Test-Path -LiteralPath $distExe)) { throw "dist exe missing" }
if (!(Test-Path -LiteralPath $distDll)) { throw "dist dll missing" }

$distExeHash = Hash-File $distExe
$distDllHash = Hash-File $distDll

Write-Host "dist_exe_hash=$distExeHash"
Write-Host "dist_dll_hash=$distDllHash"

Write-Host ""
Write-Host "INSTALL RUNTIME" -ForegroundColor Green

Push-Location $external
powershell -NoProfile -ExecutionPolicy Bypass -File ".\install_worker_global.ps1"
$installExit = $LASTEXITCODE
Pop-Location

if ($installExit -ne 0) { throw "install_worker_global failed exit=$installExit" }
if (!(Test-Path -LiteralPath $runtimeExe)) { throw "runtime exe missing" }
if (!(Test-Path -LiteralPath $runtimeDll)) { throw "runtime dll missing" }

$runtimeExeHash = Hash-File $runtimeExe
$runtimeDllHash = Hash-File $runtimeDll

if ($runtimeExeHash -ne $distExeHash) { throw "runtime exe hash mismatch" }
if ($runtimeDllHash -ne $distDllHash) { throw "runtime dll hash mismatch" }

$accountRoot = Find-AccountRoot $sharedRoot
if (!$accountRoot) { throw "account root not found before force once" }

Write-Host "force_once_root=$accountRoot"
& $runtimeExe --root $accountRoot --mode once
$onceExit = $LASTEXITCODE
Write-Host "force_once_exit=$onceExit"
if ($onceExit -ne 0) { throw "force once failed exit=$onceExit" }

Start-ScheduledTask -TaskName "AuroraWorker_Global" -ErrorAction SilentlyContinue
Start-Sleep -Seconds 6
Start-ScheduledTask -TaskName "AuroraWorker_Global_Watchdog" -ErrorAction SilentlyContinue
Start-Sleep -Seconds 10

$accountRoot = Find-AccountRoot $sharedRoot
$outbox = Join-Path $accountRoot "Workbench\Gateway\Outbox"
$resultLatest = Join-Path $outbox "result_latest.txt"
$workerStatus = Join-Path $accountRoot "Workbench\Gateway\Status\worker_process_status.txt"
$cycleStatus = Join-Path $accountRoot "Workbench\Gateway\Status\gateway_cycle_status.txt"

for ($i = 0; $i -lt 30; $i++) {
  $l15 = Read-Kv $resultLatest "l15_correlation_diversity_status"
  $workerValidation = Read-Kv $workerStatus "last_validation_status"
  $cycleValidation = Read-Kv $cycleStatus "last_validation_status"

  if (($l15 -eq "accepted" -or $l15 -eq "degraded" -or $l15 -eq "write_degraded") -and $workerValidation -eq "accepted" -and $cycleValidation -eq "accepted") {
    break
  }

  Start-Sleep -Seconds 5
}

$l6 = Read-Kv $resultLatest "l6_rank_status"
$l7 = Read-Kv $resultLatest "l7_rank_status"
$l8 = Read-Kv $resultLatest "l8_rank_status"
$l9 = Read-Kv $resultLatest "l9_rank_status"
$l10 = Read-Kv $resultLatest "l10_taxonomy_status"
$renderIndex = Read-Kv $resultLatest "render_index_status"
$l11 = Read-Kv $resultLatest "l11_symbol_ranking_status"
$l12 = Read-Kv $resultLatest "l12_group_heat_quality_status"
$l13 = Read-Kv $resultLatest "l13_dynamic_group_selection_status"
$l14 = Read-Kv $resultLatest "l14_candidate_pool_status"
$l15 = Read-Kv $resultLatest "l15_correlation_diversity_status"

$l15Reason = Read-Kv $resultLatest "l15_correlation_diversity_reason"
$l15PoolSize = Read-Kv $resultLatest "l15_candidate_pool_size"
$l15Scored = Read-Kv $resultLatest "l15_candidate_scored_count"
$l15Pairs = Read-Kv $resultLatest "l15_pairwise_pair_count"
$l15CorrPairs = Read-Kv $resultLatest "l15_corr_pair_count"
$l15Unavailable = Read-Kv $resultLatest "l15_corr_unavailable_count"
$l15Groups = Read-Kv $resultLatest "l15_group_count"
$l15Top = Read-Kv $resultLatest "l15_top_diversity_candidate"
$l15MaxCorr = Read-Kv $resultLatest "l15_max_pair_corr_abs"
$l15Runtime = Read-Kv $resultLatest "l15_selection_runtime"
$l15Trade = Read-Kv $resultLatest "l15_trade_permission"
$l15Entry = Read-Kv $resultLatest "l15_entry_signal"
$l15Execution = Read-Kv $resultLatest "l15_execution"

$l15Root = Join-Path $outbox "Layers\Layer_15_Correlation_Diversity_Selection"
$selectionGroups = Join-Path $accountRoot "Selection Desk\Groups"

$l15Outputs = @(
  (Join-Path $l15Root "l15_candidate_diversity_scores.csv"),
  (Join-Path $l15Root "l15_candidate_correlation_matrix.csv"),
  (Join-Path $l15Root "l15_group_diversity_summary.csv"),
  (Join-Path $l15Root "l15_correlation_diversity.manifest"),
  (Join-Path $l15Root "l15_correlation_diversity_summary.txt"),
  (Join-Path $selectionGroups "00_Correlation_Diversity_Summary.csv"),
  (Join-Path $selectionGroups "00_Correlation_Diversity_Summary.txt")
)

$flags = @()
$warnings = @()

if ((Read-Kv $installStatus "worker_version") -ne $TargetWorkerVersion) { $flags += "INSTALL_WORKER_VERSION_NOT_TARGET" }
if ((Read-Kv $installStatus "expected_worker_version") -ne $TargetWorkerVersion) { $flags += "INSTALL_EXPECTED_VERSION_NOT_TARGET" }

if (!(Fresh-After $resultLatest $StartedUtc)) { $flags += "RESULT_LATEST_NOT_FRESH" }
if (!(Fresh-After $workerStatus $StartedUtc)) { $flags += "WORKER_STATUS_NOT_FRESH" }
if (!(Fresh-After $cycleStatus $StartedUtc)) { $flags += "CYCLE_STATUS_NOT_FRESH" }

if ($l6 -ne "complete") { $flags += "L6_NOT_COMPLETE" }
if ($l7 -ne "complete") { $flags += "L7_NOT_COMPLETE" }
if ($l8 -ne "complete") { $flags += "L8_NOT_COMPLETE" }
if ($l9 -ne "complete") { $flags += "L9_NOT_COMPLETE" }
if ($l10 -ne "accepted") { $flags += "L10_NOT_ACCEPTED" }
if ($renderIndex -ne "complete") { $flags += "RENDER_INDEX_NOT_COMPLETE" }
if ($l11 -ne "accepted") { $flags += "L11_NOT_ACCEPTED" }
if ($l12 -ne "accepted" -and $l12 -ne "write_degraded") { $flags += "L12_NOT_ACCEPTED_OR_WRITE_DEGRADED" }
if ($l13 -ne "accepted" -and $l13 -ne "write_degraded") { $flags += "L13_NOT_ACCEPTED_OR_WRITE_DEGRADED" }
if ($l14 -ne "accepted" -and $l14 -ne "write_degraded") { $flags += "L14_NOT_ACCEPTED_OR_WRITE_DEGRADED" }
if ($l15 -ne "accepted" -and $l15 -ne "degraded" -and $l15 -ne "write_degraded") { $flags += "L15_NOT_ACCEPTED_OR_DEGRADED" }

if ($l15Runtime -ne "false") { $flags += "L15_SELECTION_RUNTIME_NOT_FALSE" }
if ($l15Trade -ne "false") { $flags += "L15_TRADE_PERMISSION_NOT_FALSE" }
if ($l15Entry -ne "false") { $flags += "L15_ENTRY_SIGNAL_NOT_FALSE" }
if ($l15Execution -ne "false") { $flags += "L15_EXECUTION_NOT_FALSE" }

foreach ($p in $l15Outputs) {
  if (!(Test-Path -LiteralPath $p)) { $flags += "L15_OUTPUT_MISSING:$p" }
}

if ($l15 -eq "degraded") { $warnings += "L15_DEGRADED_ACCEPTED_USUALLY_CORRELATION_DATA_UNAVAILABLE_OR_INSUFFICIENT" }
if ($l15CorrPairs -eq "0") { $warnings += "L15_NO_USABLE_CORRELATION_PAIRS_CHECK_SHARED_OHLC_STORE" }

$procs = @(Get-CimInstance Win32_Process -ErrorAction SilentlyContinue |
  Where-Object { $_.Name -eq "AuroraWorker.exe" -and $_.CommandLine -match "Aurora Core" })

if ($procs.Count -lt 1) { $flags += "NO_WORKER_PROCESS" }
if ($procs.Count -gt 1) { $warnings += "MULTIPLE_WORKERS_REVIEW" }

Write-Host ""
Write-Host "FINAL L15 CLEAN AIO PASTE-ANYWHERE REPORT" -ForegroundColor Cyan
Write-Host "target_worker_version=$TargetWorkerVersion"
Write-Host "install_worker_version=$(Read-Kv $installStatus 'worker_version')"
Write-Host "install_expected_version=$(Read-Kv $installStatus 'expected_worker_version')"
Write-Host "runtime_exe_hash=$runtimeExeHash"
Write-Host "runtime_dll_hash=$runtimeDllHash"
Write-Host "worker_process_count=$($procs.Count)"
Write-Host "account_root=$accountRoot"
Write-Host "result_latest_fresh=$(Fresh-After $resultLatest $StartedUtc)"
Write-Host "worker_status_fresh=$(Fresh-After $workerStatus $StartedUtc)"
Write-Host "cycle_status_fresh=$(Fresh-After $cycleStatus $StartedUtc)"

Write-Host ""
Write-Host "l6_rank_status=$l6"
Write-Host "l7_rank_status=$l7"
Write-Host "l8_rank_status=$l8"
Write-Host "l9_rank_status=$l9"
Write-Host "l10_taxonomy_status=$l10"
Write-Host "render_index_status=$renderIndex"
Write-Host "l11_symbol_ranking_status=$l11"
Write-Host "l12_group_heat_quality_status=$l12"
Write-Host "l13_dynamic_group_selection_status=$l13"
Write-Host "l14_candidate_pool_status=$l14"
Write-Host "l15_correlation_diversity_status=$l15"
Write-Host "l15_correlation_diversity_reason=$l15Reason"

Write-Host ""
Write-Host "l15_candidate_pool_size=$l15PoolSize"
Write-Host "l15_candidate_scored_count=$l15Scored"
Write-Host "l15_pairwise_pair_count=$l15Pairs"
Write-Host "l15_corr_pair_count=$l15CorrPairs"
Write-Host "l15_corr_unavailable_count=$l15Unavailable"
Write-Host "l15_group_count=$l15Groups"
Write-Host "l15_top_diversity_candidate=$l15Top"
Write-Host "l15_max_pair_corr_abs=$l15MaxCorr"
Write-Host "l15_selection_runtime=$l15Runtime"
Write-Host "l15_trade_permission=$l15Trade"
Write-Host "l15_entry_signal=$l15Entry"
Write-Host "l15_execution=$l15Execution"

Write-Host ""
Write-Host "l15_outputs:"
foreach ($p in $l15Outputs) {
  Write-Host "exists=$(Test-Path -LiteralPath $p) path=$p"
}

Write-Host ""
Write-Host "WARNINGS" -ForegroundColor Yellow
if ($warnings.Count -eq 0) {
  Write-Host "none" -ForegroundColor Green
} else {
  foreach ($w in $warnings) { Write-Host "- $w" -ForegroundColor Yellow }
}

Write-Host ""
Write-Host "FLAGS" -ForegroundColor Yellow
if ($flags.Count -eq 0) {
  Write-Host "none" -ForegroundColor Green
  Write-Host ""
  Write-Host "SYSTEM UPDATED" -ForegroundColor Green
  Write-Host "DECISION: PROCEED" -ForegroundColor Green
} else {
  foreach ($f in $flags) { Write-Host "- $f" -ForegroundColor Red }
  Write-Host ""
  Write-Host "SYSTEM NOT UPDATED" -ForegroundColor Red
  Write-Host "DECISION: HOLD" -ForegroundColor Red
}

