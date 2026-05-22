$ErrorActionPreference = "Continue"
$sharedRoot = "$env:APPDATA\MetaQuotes\Terminal\Common\Files\Aurora Core"
$exe = Join-Path $sharedRoot "External Worker\AuroraWorker\AuroraWorker.exe"
$daemonTask = "AuroraWorker_Global"

$proc = Get-Process AuroraWorker -ErrorAction SilentlyContinue
if (-not $proc) {
    Start-ScheduledTask -TaskName $daemonTask -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
}

if (Test-Path $exe) {
    & $exe --shared-root "$sharedRoot" --watchdog | Out-Null
}
