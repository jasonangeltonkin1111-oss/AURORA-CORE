$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptDir

Write-Host "AuroraWorker build starting..."
Write-Host "Worker source: $ScriptDir"

$python = "python"
try {
    & $python --version
} catch {
    Write-Host "python command not available. Try running with your full Python path."
    throw
}

& $python -m pip install --upgrade pip
& $python -m pip install pyinstaller
& $python -m PyInstaller --noconfirm --clean AuroraWorker.spec

$distExe = Join-Path $ScriptDir "dist\AuroraWorker\AuroraWorker.exe"
if (!(Test-Path $distExe)) {
    throw "Build failed: $distExe not found"
}

Write-Host "Build complete: $distExe"
Write-Host "Copy the dist\AuroraWorker folder to the MT5 External Worker folder when ready."
