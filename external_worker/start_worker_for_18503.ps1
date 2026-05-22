$ErrorActionPreference = "Stop"
Write-Host "Compatibility wrapper delegates to global Runtime 3B script."
& (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "start_worker_global.ps1")
