$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BuiltWorker = Join-Path $ScriptDir "dist\AuroraWorker"
$TargetWorkerRoot = "C:\Users\Jason\AppData\Roaming\MetaQuotes\Terminal\Common\Files\Aurora Core\Upcomers-Server\18503\Workbench\External Worker\AuroraWorker"
$TargetExeFlat = "C:\Users\Jason\AppData\Roaming\MetaQuotes\Terminal\Common\Files\Aurora Core\Upcomers-Server\18503\Workbench\External Worker\AuroraWorker.exe"

if (!(Test-Path $BuiltWorker)) {
    throw "Built worker folder not found: $BuiltWorker. Run build_worker.ps1 first."
}

New-Item -ItemType Directory -Force -Path $TargetWorkerRoot | Out-Null
Copy-Item -Path (Join-Path $BuiltWorker "*") -Destination $TargetWorkerRoot -Recurse -Force

$BuiltExe = Join-Path $TargetWorkerRoot "AuroraWorker.exe"
if (!(Test-Path $BuiltExe)) {
    throw "Install failed: AuroraWorker.exe missing after copy."
}

# Flat copy for the current EA-side FileIsExist check. Later the launch bridge can prefer the folder path.
Copy-Item -Path $BuiltExe -Destination $TargetExeFlat -Force

Write-Host "Installed worker folder: $TargetWorkerRoot"
Write-Host "Flat EXE copy for EA detection: $TargetExeFlat"
