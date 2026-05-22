param([switch]$ForegroundFallback)
$ErrorActionPreference = "Stop"
$SharedRoot = Join-Path $env:APPDATA "MetaQuotes\Terminal\Common\Files\Aurora Core"
$WorkerExe = Join-Path $SharedRoot "External Worker\AuroraWorker\AuroraWorker.exe"
$TaskName = "AuroraWorker_Global"
if (!(Test-Path $WorkerExe)) { throw "Missing packaged worker exe: $WorkerExe" }
$Task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if ($Task) {
  Start-ScheduledTask -TaskName $TaskName
  Start-Sleep -Seconds 2
  $Task = Get-ScheduledTask -TaskName $TaskName
  Write-Host "Daemon task state: $($Task.State)"
} elseif ($ForegroundFallback) {
  Write-Host "Task missing; using foreground fallback"
  & $WorkerExe --shared-root "$SharedRoot" --mode shared-daemon --poll-seconds 1
} else { throw "Task $TaskName not found. Run install_worker_global.ps1" }
Write-Host "AuroraWorker process count: $(@(Get-Process AuroraWorker -ErrorAction SilentlyContinue).Count)"
