$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = Join-Path $env:APPDATA "MetaQuotes\Terminal\Common\Files\Aurora Core"
$exe = Join-Path $root "External Worker\AuroraWorker\AuroraWorker.exe"
if (!(Test-Path $exe)) { throw "Missing worker exe: $exe" }
& $exe --shared-root "$root" --repair
$code = $LASTEXITCODE
Write-Host "Repair exit code: $code"
& (Join-Path $scriptDir "status_worker_global.ps1")
exit $code
