from pathlib import Path
import shutil
import datetime

ROOT = Path.cwd()
STAMP = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
BACKUP = ROOT / f"_aurora_packaging_fix_backup_{STAMP}"
BACKUP.mkdir(exist_ok=True)

def backup(path):
    p = Path(path)
    if p.exists():
        shutil.copy2(p, BACKUP / p.name)
        print(f"[backup] {p.name}")

def write(path, text):
    Path(path).write_text(text, encoding="utf-8", newline="\n")
    print(f"[write] {path}")

helper = ROOT / "register_watchdog_safe.ps1"
installer = ROOT / "install_worker_global.ps1"

backup(helper)
backup(installer)

helper_text = r'''$ErrorActionPreference = "Stop"

$sharedRoot = "$env:APPDATA\MetaQuotes\Terminal\Common\Files\Aurora Core"
$watchdogTask = "AuroraWorker_Global_Watchdog"
$daemonTask = "AuroraWorker_Global"
$statusFolder = Join-Path $sharedRoot "External Worker\Status"
$installStatus = Join-Path $statusFolder "shared_worker_install_status.txt"

# IMPORTANT:
# PyInstaller is currently built as one-folder, so runtime EXE must stay beside _internal.
# Do NOT use the flat External Worker\AuroraWorker.exe as runtime authority.
$watchdogExe = Join-Path $sharedRoot "External Worker\AuroraWorker\AuroraWorker.exe"
$watchdogWorkdir = Join-Path $sharedRoot "External Worker\AuroraWorker"

New-Item -ItemType Directory -Force -Path $statusFolder | Out-Null

Unregister-ScheduledTask -TaskName $watchdogTask -Confirm:$false -ErrorAction SilentlyContinue

if (!(Test-Path $watchdogExe)) {
    throw "Missing packaged watchdog executable: $watchdogExe"
}
if (!(Test-Path (Join-Path $watchdogWorkdir "_internal"))) {
    throw "Missing PyInstaller _internal folder beside packaged executable: $watchdogWorkdir\_internal"
}

$escapedExe = [System.Security.SecurityElement]::Escape($watchdogExe)
$escapedArgs = [System.Security.SecurityElement]::Escape("--shared-root `"$sharedRoot`" --watchdog")
$escapedWorkdir = [System.Security.SecurityElement]::Escape($watchdogWorkdir)
$start = (Get-Date).AddMinutes(1).ToString("yyyy-MM-ddTHH:mm:ss")

$xml = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Description>Aurora global worker watchdog repair task</Description>
  </RegistrationInfo>
  <Triggers>
    <TimeTrigger>
      <Repetition>
        <Interval>PT1M</Interval>
        <StopAtDurationEnd>false</StopAtDurationEnd>
      </Repetition>
      <StartBoundary>$start</StartBoundary>
      <Enabled>true</Enabled>
    </TimeTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <LogonType>InteractiveToken</LogonType>
      <RunLevel>LeastPrivilege</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>true</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <Enabled>true</Enabled>
    <Hidden>true</Hidden>
    <ExecutionTimeLimit>PT5M</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>$escapedExe</Command>
      <Arguments>$escapedArgs</Arguments>
      <WorkingDirectory>$escapedWorkdir</WorkingDirectory>
    </Exec>
  </Actions>
</Task>
"@

Register-ScheduledTask -TaskName $watchdogTask -Xml $xml -Force | Out-Null

$daemon = Get-ScheduledTask -TaskName $daemonTask -ErrorAction SilentlyContinue
$watchdog = Get-ScheduledTask -TaskName $watchdogTask -ErrorAction SilentlyContinue

$daemonRegistered = if ($daemon) { "true" } else { "false" }
$daemonState = if ($daemon) { $daemon.State.ToString() } else { "not_registered" }
$watchdogRegistered = if ($watchdog) { "true" } else { "false" }
$watchdogState = if ($watchdog) { $watchdog.State.ToString() } else { "not_registered" }
$operatorRequired = if ($daemonRegistered -eq "true" -and $watchdogRegistered -eq "true") { "false" } else { "true" }

if (Test-Path $installStatus) {
    $text = Get-Content $installStatus -Raw
    $pairs = @{
        "scheduled_task_registered" = $daemonRegistered
        "scheduled_task_state" = $daemonState
        "watchdog_task_registered" = $watchdogRegistered
        "watchdog_task_state" = $watchdogState
        "watchdog_task_error" = "none"
        "operator_cmd_required" = $operatorRequired
        "flat_exe_runtime_authority" = "false"
        "packaged_exe_runtime_authority" = "true"
    }
    foreach ($key in $pairs.Keys) {
        if ($text -match "(?m)^$key=") {
            $text = $text -replace "(?m)^$key=.*$", "$key=$($pairs[$key])"
        } else {
            $text += "`r`n$key=$($pairs[$key])"
        }
    }
    Set-Content -Path $installStatus -Value $text -Encoding ASCII
}

Write-Host "Watchdog registered=$watchdogRegistered state=$watchdogState operator_cmd_required=$operatorRequired"
'''

write(helper, helper_text)

# Patch installer proof language. Keep flat copy only diagnostic.
text = installer.read_text(encoding="utf-8")
text = text.replace(
    'Copy-Item -Path $BuiltExe -Destination $SharedExeFlat -Force',
    '# Flat EXE copy retained for diagnostic visibility only. Runtime tasks must use packaged EXE beside _internal.\nCopy-Item -Path $BuiltExe -Destination $SharedExeFlat -Force'
)
text = text.replace(
    'watchdog_install_method=windows_scheduled_task_repair_lane',
    'watchdog_install_method=windows_scheduled_task_repair_lane_packaged_exe'
)
text = text.replace(
    'flat_exe_path=$SharedExeFlat',
    'flat_exe_path=$SharedExeFlat\nflat_exe_runtime_authority=false'
)
text = text.replace(
    'packaged_exe_path=$BuiltExe',
    'packaged_exe_path=$BuiltExe\npackaged_exe_runtime_authority=true'
)
write(installer, text)

print("Packaging path fix complete.")
print(f"Backups: {BACKUP}")
