$ErrorActionPreference = "Stop"

$Root = "C:\Users\Jason\AppData\Roaming\MetaQuotes\Terminal\Common\Files\Aurora Core\Upcomers-Server\18503"
$SharedRoot = Join-Path $env:APPDATA "MetaQuotes\Terminal\Common\Files\Aurora Core"
$WorkerExe = Join-Path $SharedRoot "Gateway\AuroraWorker\AuroraWorker.exe"

if (!(Test-Path $WorkerExe)) {
    throw "Gateway executable not found at $WorkerExe. Run build_worker.ps1 then install_worker_global.ps1 first."
}

Write-Host "Starting Gateway account daemon..."
Write-Host "Gateway: $WorkerExe"
Write-Host "Root:    $Root"
& $WorkerExe --root $Root --mode daemon --poll-seconds 1
