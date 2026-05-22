$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SharedRoot = "C:\Users\Jason\AppData\Roaming\MetaQuotes\Terminal\Common\Files\Aurora Core"
$WorkerExe = Join-Path $SharedRoot "External Worker\AuroraWorker\AuroraWorker.exe"
if (!(Test-Path $WorkerExe)) { throw "Missing worker exe: $WorkerExe" }
& $WorkerExe --shared-root $SharedRoot --watchdog
