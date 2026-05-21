$ErrorActionPreference = "Stop"

$TaskName = "AuroraWorker_Global"
$Task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if ($Task) {
    Stop-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    Write-Host "Shared scheduled task stop requested: $TaskName"
}

Get-Process AuroraWorker -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host "Stopping AuroraWorker process PID=$($_.Id) Path=$($_.Path)"
    Stop-Process -Id $_.Id -Force
}
