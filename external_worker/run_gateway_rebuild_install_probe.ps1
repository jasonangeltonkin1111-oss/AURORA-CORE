param(
  [string]$SharedRoot = (Join-Path $env:APPDATA 'MetaQuotes\Terminal\Common\Files\Aurora Core'),
  [switch]$SkipGitPull,
  [switch]$SkipPipInstall
)

$ErrorActionPreference = 'Continue'
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Resolve-Path (Join-Path $ScriptDir '..')
$InstallScript = Join-Path $ScriptDir 'install_worker_global.ps1'
$SharedGateway = Join-Path $SharedRoot 'Gateway'
$WorkerExe = Join-Path $SharedGateway 'AuroraWorker\AuroraWorker.exe'
$SharedStatus = Join-Path $SharedGateway 'Status\shared_worker_status.txt'
$InstallStatus = Join-Path $SharedGateway 'Status\shared_worker_install_status.txt'

function Resolve-AuroraGitCommand {
  $cmd = Get-Command git -ErrorAction SilentlyContinue
  if ($null -ne $cmd -and $cmd.Source) { return $cmd.Source }
  $candidates = @(
    (Join-Path $env:ProgramFiles 'Git\cmd\git.exe'),
    (Join-Path ${env:ProgramFiles(x86)} 'Git\cmd\git.exe'),
    'C:\Program Files\Git\cmd\git.exe',
    'C:\Program Files\Git\bin\git.exe'
  )
  foreach ($candidate in $candidates) {
    if ($candidate -and (Test-Path -LiteralPath $candidate -PathType Leaf)) { return $candidate }
  }
  return $null
}

function Is-Admin {
  $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = New-Object Security.Principal.WindowsPrincipal($identity)
  return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Read-KvValue([string]$Path, [string]$Key) {
  if (!(Test-Path -LiteralPath $Path)) { return 'missing_file' }
  $line = Get-Content -LiteralPath $Path -ErrorAction SilentlyContinue | Where-Object { $_ -match ('^' + [regex]::Escape($Key) + '=') } | Select-Object -First 1
  if ($null -eq $line) { return 'missing_key' }
  return ($line -replace ('^' + [regex]::Escape($Key) + '='), '').Trim()
}

function Get-AuroraAccountRoots([string]$Root) {
  if (!(Test-Path -LiteralPath $Root)) { return @() }
  $requiredFiles = Get-ChildItem -LiteralPath $Root -Recurse -Filter 'worker_required.txt' -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -match '\\Gateway\\Status\\worker_required\.txt$' }
  $roots = @()
  foreach ($file in $requiredFiles) {
    $status = Split-Path -Parent $file.FullName
    $gateway = Split-Path -Parent $status
    $accountRoot = Split-Path -Parent $gateway
    if ($accountRoot -and ($roots -notcontains $accountRoot)) { $roots += $accountRoot }
  }
  return $roots
}

Write-Host 'AURORA GATEWAY REBUILD / INSTALL / PROBE' -ForegroundColor Cyan
Write-Host "RepoRoot=$RepoRoot"
Write-Host "SharedRoot=$SharedRoot"
Write-Host "Admin=$((Is-Admin).ToString().ToLowerInvariant())"
if (!(Is-Admin)) {
  Write-Host 'WARNING: not running as Administrator. Scheduled-task enable/start may fail with Access Denied. Direct status probe will still run.' -ForegroundColor Yellow
}

if (!(Test-Path -LiteralPath $InstallScript)) {
  throw "Missing installer script: $InstallScript"
}

Push-Location $RepoRoot
try {
  if (!$SkipGitPull -and (Test-Path -LiteralPath (Join-Path $RepoRoot '.git'))) {
    Write-Host 'Updating local main from origin/main...'
    $git = Resolve-AuroraGitCommand
    if ($null -eq $git) {
      Write-Host 'WARNING: git executable not found on PATH or standard install locations. Continuing with current checkout.' -ForegroundColor Yellow
    } else {
      & $git checkout main
      & $git pull --ff-only origin main
      if ($LASTEXITCODE -ne 0) { Write-Host 'WARNING: git pull failed or repo has local changes. Continuing with current checkout.' -ForegroundColor Yellow }
    }
  }

  if (!$SkipPipInstall) {
    & python -m PyInstaller --version *> $null
    if ($LASTEXITCODE -ne 0) {
      Write-Host 'PyInstaller missing. Installing/upgrading pyinstaller...' -ForegroundColor Yellow
      & python -m pip install --upgrade pyinstaller
      if ($LASTEXITCODE -ne 0) { throw 'PyInstaller install failed. Install pyinstaller manually or rerun with working Python/pip.' }
    }
  }

  Write-Host 'Running current external worker installer/rebuilder...'
  & powershell -NoProfile -ExecutionPolicy Bypass -File $InstallScript
  $installExit = $LASTEXITCODE
  Write-Host "installer_exit_code=$installExit"

  if (!(Test-Path -LiteralPath $WorkerExe)) {
    throw "Packaged worker exe missing after install: $WorkerExe"
  }

  Write-Host 'Packaged worker version probe:'
  & $WorkerExe --version
  Write-Host "version_probe_exit_code=$LASTEXITCODE"

  Write-Host 'Running direct shared status probe. This does not depend on Task Scheduler.'
  & $WorkerExe --shared-root $SharedRoot --status
  $probeExit = $LASTEXITCODE
  Write-Host "status_probe_exit_code=$probeExit"

  Write-Host ''
  Write-Host 'Shared status proof:' -ForegroundColor Cyan
  foreach ($key in @(
    'worker_version',
    'mode',
    'last_loop_utc',
    'discovered_root_count',
    'processed_root_count',
    'accepted_root_count',
    'degraded_root_count',
    'account_heartbeat_present_count',
    'account_process_status_present_count',
    'account_result_pair_present_count',
    'account_proof_contradiction_count',
    'account_proof_contradiction_reason'
  )) {
    Write-Host "$key=$(Read-KvValue $SharedStatus $key)"
  }

  Write-Host ''
  Write-Host 'Install status proof:' -ForegroundColor Cyan
  foreach ($key in @(
    'worker_version',
    'packaged_worker_version',
    'packaged_worker_version_matches_source',
    'pyinstaller_rebuild_status',
    'scheduled_task_registered',
    'scheduled_task_state',
    'scheduled_task_runnable',
    'scheduled_task_enable_error',
    'daemon_start_error',
    'watchdog_task_registered',
    'watchdog_task_state',
    'watchdog_task_runnable',
    'watchdog_task_enable_error',
    'operator_cmd_required',
    'runtime_proof_ready_for_operator_cmd',
    'runtime_proof_ready_reason'
  )) {
    Write-Host "$key=$(Read-KvValue $InstallStatus $key)"
  }

  Write-Host ''
  Write-Host 'Account-level proof files:' -ForegroundColor Cyan
  $roots = Get-AuroraAccountRoots $SharedRoot
  if ($roots.Count -eq 0) { Write-Host 'no_account_roots_found_from_worker_required_files' -ForegroundColor Yellow }
  $allAccountProofOk = $true
  foreach ($root in $roots) {
    Write-Host "root=$root"
    $gateway = Join-Path $root 'Gateway'
    $checks = @(
      'Status\worker_heartbeat.txt',
      'Status\worker_process_status.txt',
      'Outbox\result_latest.txt',
      'Outbox\result_latest.manifest'
    )
    foreach ($rel in $checks) {
      $full = Join-Path $gateway $rel
      if (Test-Path -LiteralPath $full) {
        $item = Get-Item -LiteralPath $full
        Write-Host "  $rel present=true length=$($item.Length) last_write_utc=$($item.LastWriteTimeUtc.ToString('yyyy-MM-dd HH:mm:ss UTC'))"
      } else {
        $allAccountProofOk = $false
        Write-Host "  $rel present=false" -ForegroundColor Red
      }
    }
  }

  $contradictions = Read-KvValue $SharedStatus 'account_proof_contradiction_count'
  if ($probeExit -eq 0 -and $allAccountProofOk -and $contradictions -eq '0') {
    Write-Host ''
    Write-Host 'DECISION=PROCEED_TO_MT5_RUNTIME_READBACK_SMOKE' -ForegroundColor Green
  } else {
    Write-Host ''
    Write-Host 'DECISION=HOLD_GATEWAY_PROOF_NOT_CLEAN' -ForegroundColor Yellow
  }
} finally {
  Pop-Location
}
