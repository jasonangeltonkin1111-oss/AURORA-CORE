from pathlib import Path
import urllib.request
import subprocess
import shutil
import datetime
import os

ROOT = Path.cwd()
STAMP = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
BACKUP = ROOT / f"_aurora_full_repair_backup_{STAMP}"
BACKUP.mkdir(exist_ok=True)

RAW_BASE = "https://raw.githubusercontent.com/jasonangeltonkin1111-oss/AURORA-CORE/main/external_worker"

def ps(cmd: str):
    print(f"\n[PS] {cmd}")
    subprocess.run(
        ["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", cmd],
        check=False,
    )

def backup(path: Path):
    if path.exists():
        target = BACKUP / path.name
        shutil.copy2(path, target)
        print(f"[backup] {path.name} -> {target}")

def write(path: Path, text: str):
    path.write_text(text, encoding="utf-8", newline="\n")
    print(f"[write] {path}")

def fetch_raw(name: str) -> str:
    url = f"{RAW_BASE}/{name}"
    print(f"[fetch] {url}")
    with urllib.request.urlopen(url, timeout=30) as r:
        return r.read().decode("utf-8")

def replace_between(text: str, start_marker: str, end_marker: str, new_block: str) -> str:
    start = text.find(start_marker)
    if start < 0:
        raise RuntimeError(f"start marker not found: {start_marker}")
    end = text.find(end_marker, start)
    if end < 0:
        raise RuntimeError(f"end marker not found after {start_marker}: {end_marker}")
    return text[:start] + new_block + text[end:]

print("==== 0) EMERGENCY SAFE STOP ====")
ps('Stop-ScheduledTask -TaskName "AuroraWorker_Global_Watchdog" -ErrorAction SilentlyContinue')
ps('Stop-ScheduledTask -TaskName "AuroraWorker_Global" -ErrorAction SilentlyContinue')
ps('Unregister-ScheduledTask -TaskName "AuroraWorker_Global_Watchdog" -Confirm:$false -ErrorAction SilentlyContinue')
ps('Unregister-ScheduledTask -TaskName "AuroraWorker_Global" -Confirm:$false -ErrorAction SilentlyContinue')
ps('taskkill /F /IM AuroraWorker.exe /T 2>$null')
ps(r'''Get-CimInstance Win32_Process |
  Where-Object { $_.Name -match "powershell" -and $_.CommandLine -match "Aurora|AuroraWorker|watchdog|external_worker" } |
  ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }''')

print("\n==== 1) RESTORE CLEAN aurora_worker.py FROM GITHUB RAW ====")
worker = ROOT / "aurora_worker.py"
backup(worker)
text = fetch_raw("aurora_worker.py")
write(worker, text)

print("\n==== 2) PATCH aurora_worker.py: NO POWERSHELL IN DAEMON HOT LOOP ====")
text = worker.read_text(encoding="utf-8")
text = text.replace('WORKER_VERSION = "0.5.0"', 'WORKER_VERSION = "0.5.1_hotfix_no_powershell_daemon"', 1)

powershell_block = '''def _powershell(command: str, timeout: int = 8) -> Tuple[bool, str]:
    """
    One-shot Windows helper for watchdog/repair paths only.
    MUST NOT be called from the hot shared-daemon loop.
    Runs hidden to prevent visible PowerShell popup storms.
    """
    try:
        kwargs = {
            "text": True,
            "stderr": subprocess.STDOUT,
            "timeout": timeout,
        }

        if os.name == "nt":
            startupinfo = subprocess.STARTUPINFO()
            startupinfo.dwFlags |= subprocess.STARTF_USESHOWWINDOW
            startupinfo.wShowWindow = 0
            kwargs["startupinfo"] = startupinfo
            kwargs["creationflags"] = getattr(subprocess, "CREATE_NO_WINDOW", 0)

        out = subprocess.check_output(
            [
                "powershell",
                "-NoProfile",
                "-WindowStyle",
                "Hidden",
                "-ExecutionPolicy",
                "Bypass",
                "-Command",
                command,
            ],
            **kwargs,
        ).strip()
        return True, out
    except Exception as exc:
        return False, str(exc).replace("\\r", " ").replace("\\n", " ")


'''

text = replace_between(
    text,
    "def _powershell(command: str, timeout: int = 8) -> Tuple[bool, str]:",
    "def _get_task_state",
    powershell_block,
)

build_shared_status_block = '''def build_shared_status(shared_root: Path, loop_count: int, roots: List[Path], results: List[Tuple[Path, int, ValidationResult]], watchdog: WatchdogProof | None = None, repair_success: bool = False) -> str:
    """
    Shared daemon hot-loop status writer.

    Critical hotfix:
    - No PowerShell.
    - No Get-ScheduledTask.
    - No Get-Process.
    - No task/process subprocess calls per heartbeat.

    Task truth belongs to install/status scripts and one-shot watchdog/repair only.
    """
    accepted = sum(1 for _r, code, result in results if code == 0 and result.ok)
    degraded = len(results) - accepted
    cpu = os.cpu_count() or 1
    mem_total, mem_avail, mem_used = _windows_memory()

    proof = watchdog or _read_existing_watchdog(shared_root)

    throttle = "false"
    throttle_reason = "none"
    if mem_used.isdigit() and int(mem_used) >= 80:
        throttle = "true"
        throttle_reason = "memory_above_limit"

    lines = [
        "schema_name=aurora_shared_worker_status",
        "schema_version=3",
        f"worker_version={WORKER_VERSION}",
        f"process_id={PROCESS_ID}",
        "mode=shared-daemon",
        f"shared_root={shared_root}",
        f"process_start_utc={PROCESS_START_UTC}",
        f"process_start_unix={PROCESS_START_UNIX}",
        f"last_loop_utc={utc_stamp()}",
        f"last_loop_unix={unix_time()}",
        f"loop_count={loop_count}",
        f"discovered_root_count={len(roots)}",
        f"processed_root_count={len(results)}",
        f"accepted_root_count={accepted}",
        f"degraded_root_count={degraded}",
        "daemon_task_registered=not_checked_by_daemon",
        "daemon_task_state=not_checked_by_daemon",
        "watchdog_task_registered=not_checked_by_daemon",
        "watchdog_task_state=not_checked_by_daemon",
        f"watchdog_last_check_utc={proof.last_check_utc}",
        f"watchdog_last_action={proof.last_action}",
        f"watchdog_last_reason={proof.last_reason}",
        f"watchdog_restart_attempted={proof.restart_attempted}",
        f"watchdog_restart_result={proof.restart_result}",
        "operator_cmd_required=not_available_in_daemon_status",
        f"cpu_logical_count={cpu}",
        "cpu_used_percent=not_available",
        f"memory_total_mb={mem_total}",
        f"memory_available_mb={mem_avail}",
        f"memory_used_percent={mem_used}",
        "memory_limit_percent=80",
        "cpu_limit_percent=80",
        "terminal_process_count=not_checked_by_daemon",
        "aurora_worker_process_count=not_checked_by_daemon",
        f"registered_root_count={len(roots)}",
        f"resource_throttle_active={throttle}",
        f"resource_throttle_reason={throttle_reason}",
        "recommended_parallel_jobs=1",
        "authority=calculation_support_only",
        "trade_permission=false",
        "",
        "root|exit_code|status|reason|snapshot_id|payload_checksum",
    ]
    lines += [f"{root}|{code}|{res.status}|{res.reason}|{res.snapshot_id}|{res.payload_checksum}" for root, code, res in results]
    lines.append("")
    return "\\n".join(lines)


'''

text = replace_between(
    text,
    "def build_shared_status(shared_root: Path, loop_count: int, roots: List[Path], results: List[Tuple[Path, int, ValidationResult]], watchdog: WatchdogProof | None = None, repair_success: bool = False) -> str:",
    "def write_shared_status",
    build_shared_status_block,
)

write(worker, text)

print("\n==== 3) PATCH AuroraWorker.spec WINDOWLESS ====")
spec = ROOT / "AuroraWorker.spec"
backup(spec)
spec_text = spec.read_text(encoding="utf-8")
spec_text = spec_text.replace("console=True", "console=False")
spec_text = spec_text.replace("disable_windowed_traceback=False", "disable_windowed_traceback=True")
write(spec, spec_text)

print("\n==== 4) REWRITE register_watchdog_safe.ps1 CLEAN DIRECT-EXE ====")
helper = ROOT / "register_watchdog_safe.ps1"
backup(helper)
helper_text = r'''$ErrorActionPreference = "Stop"

$sharedRoot = "$env:APPDATA\MetaQuotes\Terminal\Common\Files\Aurora Core"
$watchdogTask = "AuroraWorker_Global_Watchdog"
$daemonTask = "AuroraWorker_Global"
$statusFolder = Join-Path $sharedRoot "External Worker\Status"
$installStatus = Join-Path $statusFolder "shared_worker_install_status.txt"
$watchdogExe = Join-Path $sharedRoot "External Worker\AuroraWorker.exe"

New-Item -ItemType Directory -Force -Path $statusFolder | Out-Null

Unregister-ScheduledTask -TaskName $watchdogTask -Confirm:$false -ErrorAction SilentlyContinue

if (!(Test-Path $watchdogExe)) {
    throw "Missing shared watchdog executable: $watchdogExe"
}

$escapedExe = [System.Security.SecurityElement]::Escape($watchdogExe)
$escapedArgs = [System.Security.SecurityElement]::Escape("--shared-root `"$sharedRoot`" --watchdog")
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

print("\n==== 5) PATCH install_worker_global.ps1 VERSION + HIDDEN HELPER ====")
installer = ROOT / "install_worker_global.ps1"
backup(installer)
inst_text = installer.read_text(encoding="utf-8")
inst_text = inst_text.replace("worker_version=0.5.0", "worker_version=0.5.1_hotfix_no_powershell_daemon")
inst_text = inst_text.replace(
    "powershell -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File $WatchdogHelper | Out-Host",
    "powershell -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File $WatchdogHelper | Out-Host"
)
inst_text = inst_text.replace(
    "powershell -ExecutionPolicy Bypass -File $WatchdogHelper | Out-Host",
    "powershell -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File $WatchdogHelper | Out-Host"
)
write(installer, inst_text)

print("\n==== 6) VERIFY PYTHON SYNTAX ====")
subprocess.run(["python", "-m", "py_compile", str(worker)], check=True)
print("[PASS] aurora_worker.py syntax ok")

print("\n==== 7) VERIFY PATCH MARKERS ====")
worker_now = worker.read_text(encoding="utf-8")
for needle in [
    'WORKER_VERSION = "0.5.1_hotfix_no_powershell_daemon"',
    "not_checked_by_daemon",
    "operator_cmd_required=not_available_in_daemon_status",
    "CREATE_NO_WINDOW",
]:
    if needle not in worker_now:
        raise SystemExit(f"FAILED: missing marker {needle}")
    print(f"[PASS] found {needle}")

spec_now = spec.read_text(encoding="utf-8")
if "console=False" not in spec_now or "disable_windowed_traceback=True" not in spec_now:
    raise SystemExit("FAILED: spec is not windowless")
print("[PASS] spec windowless markers ok")

helper_now = helper.read_text(encoding="utf-8")
if "watchdog_runner_global.ps1" in helper_now or "<Command>$escapedExe</Command>" not in helper_now or "<Interval>PT1M</Interval>" not in helper_now:
    raise SystemExit("FAILED: watchdog helper is not clean direct-EXE PT1M")
print("[PASS] watchdog helper direct-EXE PT1M ok")

print("\n==== 8) BUILD WINDOWLESS WORKER ====")
subprocess.run(
    ["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", str(ROOT / "build_worker.ps1")],
    check=True,
)

print("\n==== 9) FINAL SAFE CHECK - NO INSTALL / NO START ====")
ps('Get-ScheduledTask -TaskName "AuroraWorker_Global","AuroraWorker_Global_Watchdog" -ErrorAction SilentlyContinue | Select-Object TaskName,State')
ps('Get-Process AuroraWorker -ErrorAction SilentlyContinue | Select-Object Id,ProcessName,Path,StartTime')
ps(r'''Get-CimInstance Win32_Process |
  Where-Object { $_.Name -match "powershell" -and $_.CommandLine -match "Aurora|AuroraWorker|watchdog|external_worker" } |
  Select-Object ProcessId,Name,CommandLine''')

print("\n==== DONE ====")
print("Fixed source + PowerShell files and built windowless worker.")
print("Did NOT install tasks.")
print("Did NOT start daemon.")
print(f"Backups saved in: {BACKUP}")
