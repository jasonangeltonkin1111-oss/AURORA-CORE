$ErrorActionPreference = "Stop"

$Root = "C:\Users\Jason\AppData\Roaming\MetaQuotes\Terminal\Common\Files\Aurora Core\Upcomers-Server\18503"
$WorkerExe = Join-Path $Root "Workbench\External Worker\AuroraWorker\AuroraWorker.exe"

if (!(Test-Path $WorkerExe)) {
    throw "AuroraWorker.exe not found at $WorkerExe. Run build_worker.ps1 then install_worker_for_18503.ps1 first."
}

Write-Host "Starting AuroraWorker daemon..."
Write-Host "Worker: $WorkerExe"
Write-Host "Root:   $Root"
& $WorkerExe --root $Root --mode daemon --poll-seconds 1
