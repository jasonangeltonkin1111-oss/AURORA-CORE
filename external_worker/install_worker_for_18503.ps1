$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BuiltWorker = Join-Path $ScriptDir "dist\AuroraWorker"
$TargetExternalWorker = "C:\Users\Jason\AppData\Roaming\MetaQuotes\Terminal\Common\Files\Aurora Core\Upcomers-Server\18503\Workbench\External Worker"
$TargetWorkerRoot = Join-Path $TargetExternalWorker "AuroraWorker"
$TargetExeFlat = Join-Path $TargetExternalWorker "AuroraWorker.exe"
$TargetStatus = Join-Path $TargetExternalWorker "Status"
$InstallStatusPath = Join-Path $TargetStatus "worker_install_status.txt"

if (!(Test-Path $BuiltWorker)) {
    throw "Built worker folder not found: $BuiltWorker. Run build_worker.ps1 first."
}

New-Item -ItemType Directory -Force -Path $TargetWorkerRoot | Out-Null
New-Item -ItemType Directory -Force -Path $TargetStatus | Out-Null
Copy-Item -Path (Join-Path $BuiltWorker "*") -Destination $TargetWorkerRoot -Recurse -Force

$BuiltExe = Join-Path $TargetWorkerRoot "AuroraWorker.exe"
if (!(Test-Path $BuiltExe)) {
    throw "Install failed: AuroraWorker.exe missing after copy."
}

# Flat copy remains for diagnostic compatibility. Runtime truth comes from worker_install_status.txt.
Copy-Item -Path $BuiltExe -Destination $TargetExeFlat -Force

$FlatPresent = Test-Path $TargetExeFlat
$PackagedPresent = Test-Path $BuiltExe
$Now = [DateTimeOffset]::UtcNow
$NowUnix = $Now.ToUnixTimeSeconds()
$NowUtc = $Now.UtcDateTime.ToString("yyyy-MM-dd HH:mm:ss UTC")
$InstallText = @"
schema_name=aurora_worker_install_status
schema_version=1
installed=true
install_method=local_packaged_worker
worker_version=0.2.0
flat_exe_present=$($FlatPresent.ToString().ToLowerInvariant())
packaged_exe_present=$($PackagedPresent.ToString().ToLowerInvariant())
flat_exe_path=$TargetExeFlat
packaged_exe_path=$BuiltExe
generated_unix=$NowUnix
generated_utc=$NowUtc
authority=calculation_support_only
trade_permission=false
"@

Set-Content -Path $InstallStatusPath -Value $InstallText -Encoding ASCII

Write-Host "Installed worker folder: $TargetWorkerRoot"
Write-Host "Flat EXE copy for diagnostic detection: $TargetExeFlat"
Write-Host "Install status proof: $InstallStatusPath"
