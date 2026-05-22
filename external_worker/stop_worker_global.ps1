param([switch]$StopWatchdog)
$ErrorActionPreference = "Stop"
$daemonTask = "AuroraWorker_Global"
$watchTask = "AuroraWorker_Global_Watchdog"
Stop-ScheduledTask -TaskName $daemonTask -ErrorAction SilentlyContinue
if($StopWatchdog){ Stop-ScheduledTask -TaskName $watchTask -ErrorAction SilentlyContinue }
Get-Process AuroraWorker -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 1
if($StopWatchdog){
  Get-Process powershell -ErrorAction SilentlyContinue | Where-Object {
    $_.Path -and $_.Path -match "powershell(\.exe)?$"
  } | ForEach-Object {
    try {
      $cmd = (Get-CimInstance Win32_Process -Filter "ProcessId=$($_.Id)" -ErrorAction SilentlyContinue).CommandLine
      if($cmd -and $cmd -match "watchdog_runner_global\.ps1"){ Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue }
    } catch {}
  }
}
$d = Get-ScheduledTask -TaskName $daemonTask -ErrorAction SilentlyContinue
$w = Get-ScheduledTask -TaskName $watchTask -ErrorAction SilentlyContinue
Write-Host "Daemon task state: $($d.State)"
Write-Host "Watchdog task state: $($w.State)"
Write-Host "AuroraWorker process count: $(@(Get-Process AuroraWorker -ErrorAction SilentlyContinue).Count)"
if(-not $StopWatchdog){ Write-Host "Note: watchdog may restart daemon unless -StopWatchdog is supplied." }
