$ErrorActionPreference = "Stop"

$TaskName = "AuroraWorker_Upcomers_Server_18503"
$Root = "C:\Users\Jason\AppData\Roaming\MetaQuotes\Terminal\Common\Files\Aurora Core\Upcomers-Server\18503"
$WorkerExe = Join-Path $Root "Workbench\External Worker\AuroraWorker\AuroraWorker.exe"

if (!(Test-Path $WorkerExe)) {
    throw "AuroraWorker.exe not found at $WorkerExe. Run build_worker.ps1 then install_worker_for_18503.ps1 first."
}

$Task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if ($Task) {
    Start-ScheduledTask -TaskName $TaskName
    Start-Sleep -Seconds 2
    $Task = Get-ScheduledTask -TaskName $TaskName
    Write-Host "Scheduled task started/requested: $TaskName ($($Task.State))"
} else {
    Write-Host "Scheduled task not found. Starting foreground daemon instead. Run install_worker_for_18503.ps1 to register the task."
    & $WorkerExe --root $Root --mode daemon --poll-seconds 1
}
