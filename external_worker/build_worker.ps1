$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptDir

Write-Host "AuroraWorker build starting..."
Write-Host "Worker source: $ScriptDir"

$python = "python"
try {
    & $python --version
} catch {
    Write-Host "python command not available. Run this script from a PowerShell session where Python is on PATH, or edit `$python to your full Python.exe path."
    throw
}

& $python -m pip install --upgrade pip
& $python -m pip install -r requirements.txt
& $python -m PyInstaller --noconfirm --clean AuroraWorker.spec

$distExe = Join-Path $ScriptDir "dist\AuroraWorker\AuroraWorker.exe"
if (!(Test-Path $distExe)) {
    throw "Build failed: $distExe not found"
}

Write-Host "Build complete: $distExe"
Write-Host "Next: run install_worker_for_18503.ps1, then start_worker_for_18503.ps1 for packaged daemon proof."
