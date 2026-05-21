$ErrorActionPreference = "Stop"

$TaskName = "AuroraWorker_Global"
$SharedRoot = "C:\Users\Jason\AppData\Roaming\MetaQuotes\Terminal\Common\Files\Aurora Core"
$WorkerExe = Join-Path $SharedRoot "External Worker\AuroraWorker\AuroraWorker.exe"

if (!(Test-Path $WorkerExe)) {
    throw "AuroraWorker.exe not found at $WorkerExe. Run build_worker.ps1 then install_worker_for_18503.ps1 first."
}

$Task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if ($Task) {
    Start-ScheduledTask -TaskName $TaskName
    Start-Sleep -Seconds 2
    $Task = Get-ScheduledTask -TaskName $TaskName
    Write-Host "Shared scheduled task started/requested: $TaskName ($($Task.State))"
} else {
    Write-Host "Shared scheduled task not found. Starting foreground shared daemon instead. Run install_worker_for_18503.ps1 to register the task."
    & $WorkerExe --shared-root $SharedRoot --mode shared-daemon --poll-seconds 1
}
