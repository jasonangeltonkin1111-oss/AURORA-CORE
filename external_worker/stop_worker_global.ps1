param([switch]$StopWatchdog)
$ErrorActionPreference = "Stop"
$daemonTask = "AuroraWorker_Global"
$watchTask = "AuroraWorker_Global_Watchdog"
Stop-ScheduledTask -TaskName $daemonTask -ErrorAction SilentlyContinue
if($StopWatchdog){ Stop-ScheduledTask -TaskName $watchTask -ErrorAction SilentlyContinue }
Get-Process AuroraWorker -ErrorAction SilentlyContinue | Stop-Process -Force
$d = Get-ScheduledTask -TaskName $daemonTask -ErrorAction SilentlyContinue
$w = Get-ScheduledTask -TaskName $watchTask -ErrorAction SilentlyContinue
Write-Host "Daemon task state: $($d.State)"
Write-Host "Watchdog task state: $($w.State)"
Write-Host "AuroraWorker process count: $(@(Get-Process AuroraWorker -ErrorAction SilentlyContinue).Count)"
if(-not $StopWatchdog){ Write-Host "Note: watchdog may restart daemon unless -StopWatchdog is supplied." }
