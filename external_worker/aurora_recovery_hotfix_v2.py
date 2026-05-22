from pathlib import Path
import re
import shutil
import subprocess
import datetime
import os

ROOT = Path.cwd()
STAMP = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
SAFETY_BACKUP = ROOT / f"_aurora_recovery_backup_{STAMP}"
SAFETY_BACKUP.mkdir(exist_ok=True)

def ps(cmd: str):
    print(f"\n[PS] {cmd}")
    subprocess.run(
        ["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", cmd],
        check=False,
    )

def backup(path: Path):
    if path.exists():
        target = SAFETY_BACKUP / path.name
        shutil.copy2(path, target)
        print(f"[backup] {path.name} -> {target}")

def write(path: Path, text: str):
    path.write_text(text, encoding="utf-8", newline="\n")
    print(f"[write] {path}")

print("==== EMERGENCY STOP / CLEAN ====")
ps('Stop-ScheduledTask -TaskName "AuroraWorker_Global_Watchdog" -ErrorAction SilentlyContinue')
ps('Stop-ScheduledTask -TaskName "AuroraWorker_Global" -ErrorAction SilentlyContinue')
ps('Unregister-ScheduledTask -TaskName "AuroraWorker_Global_Watchdog" -Confirm:$false -ErrorAction SilentlyContinue')
ps('Unregister-ScheduledTask -TaskName "AuroraWorker_Global" -Confirm:$false -ErrorAction SilentlyContinue')
ps('taskkill /F /IM AuroraWorker.exe /T 2>$null')
ps(r'''Get-CimInstance Win32_Process |
  Where-Object { $_.Name -match "powershell" -and $_.CommandLine -match "Aurora|AuroraWorker|watchdog|external_worker" } |
  ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }''')

worker = ROOT / "aurora_worker.py"
spec = ROOT / "AuroraWorker.spec"
helper = ROOT / "register_watchdog_safe.ps1"
installer = ROOT / "install_worker_global.ps1"

print("\n==== RESTORE aurora_worker.py FROM LATEST HOTFIX BACKUP ====")
backup(worker)

backup_dirs = sorted(
    [p for p in ROOT.glob("_aurora_hotfix_backup_*") if (p / "aurora_worker.py").exists()],
    key=lambda p: p.stat().st_mtime,
    reverse=True,
)

if not backup_dirs:
    raise SystemExit("FAILED: no _aurora_hotfix_backup_* folder with aurora_worker.py found.")

restore_src = backup_dirs[0] / "aurora_worker.py"
shutil.copy2(restore_src, worker)
print(f"[restore] {worker} <- {restore_src}")

text = worker.read_text(encoding="utf-8")

print("\n==== PATCH aurora_worker.py SAFELY ====")
text = re.sub(
    r'WORKER_VERSION = ".*?"',
    'WORKER_VERSION = "0.5.1_hotfix_no_powershell_daemon"',
    text,
    count=1,
)

powershell_pattern = re.compile(
    r'def _powershell\(command: str, timeout: int = 8\) -> Tuple\[bool, str\]:\n'
    r'.*?\n\n'
    r'def _get_task_state',
    re.S,
)

powershell_replacement = '''def _powershell(command: str, timeout: int = 8) -> Tuple[bool, str]:
    """
    One-shot Windows helper for repair/watchdog paths only.
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
        return False, str(exc).replace("\\\\r", " ").replace("\\\\n", " ")


def _get_task_state'''

text, n = powershell_pattern.subn(lambda _m: powershell_replacement, text)
print(f"[patch] _powershell replacement count={n}")
if n != 1:
    raise SystemExit("FAILED: _powershell replacement did not match exactly once.")

build_pattern = re.compile(
    r'def build_shared_status\(shared_root: Path, loop_count: int, roots: List\[Path\], results: List\[Tuple\[Path, int, ValidationResult\]\], watchdog: WatchdogProof \| None = None, repair_success: bool = False\) -> str:\n'
    r'.*?\n\n'
    r'def write_shared_status',
    re.S,
)

build_replacement = '''def build_shared_status(shared_root: Path, loop_count: int, roots: List[Path], results: List[Tuple[Path, int, ValidationResult]], watchdog: WatchdogProof | None = None, repair_success: bool = False) -> str:
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
    return "\\\\n".join(lines)


def write_shared_status'''

text, n = build_pattern.subn(lambda _m: build_replacement, text)
print(f"[patch] build_shared_status replacement count={n}")
if n != 1:
    raise SystemExit("FAILED: build_shared_status replacement did not match exactly once.")

write(worker, text)

print("\n==== PATCH AuroraWorker.spec WINDOWLESS ====")
backup(spec)
spec_text = spec.read_text(encoding="utf-8")
spec_text = spec_text.replace("console=True", "console=False")
spec_text = spec_text.replace("disable_windowed_traceback=False", "disable_windowed_traceback=True")
write(spec, spec_text)

print("\n==== PATCH PS FILES VERSION / HIDDEN SAFETY ====")
for p in [helper, installer]:
    backup(p)

if helper.exists():
    helper_text = helper.read_text(encoding="utf-8")
    helper_text = helper_text.replace("<Hidden>false</Hidden>", "<Hidden>true</Hidden>")
    # enforce direct EXE command expectation only as a warning, not blind rewrite
    if "watchdog_runner_global.ps1" in helper_text:
        print("[WARN] register_watchdog_safe.ps1 still mentions watchdog_runner_global.ps1")
    if "<Interval>PT1M</Interval>" not in helper_text:
        print("[WARN] register_watchdog_safe.ps1 does not show PT1M interval")
    write(helper, helper_text)

if installer.exists():
    inst_text = installer.read_text(encoding="utf-8")
    inst_text = inst_text.replace("worker_version=0.5.0", "worker_version=0.5.1_hotfix_no_powershell_daemon")
    inst_text = inst_text.replace("powershell -ExecutionPolicy Bypass", "powershell -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass")
    write(installer, inst_text)

print("\n==== VERIFY PYTHON SYNTAX ====")
subprocess.run(["python", "-m", "py_compile", str(worker)], check=True)
print("[PASS] aurora_worker.py syntax ok")

print("\n==== VERIFY IMPORTANT SOURCE LINES ====")
for pattern in [
    "WORKER_VERSION",
    "not_checked_by_daemon",
    "operator_cmd_required=not_available_in_daemon_status",
    "CREATE_NO_WINDOW",
]:
    print(f"\n-- {pattern} --")
    for line in worker.read_text(encoding="utf-8").splitlines():
        if pattern in line:
            print(line)

print("\n==== BUILD WINDOWLESS WORKER ====")
subprocess.run(
    ["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", str(ROOT / "build_worker.ps1")],
    check=True,
)

print("\n==== DO NOT INSTALL / DO NOT START ====")
print("Patch and build completed. Tasks remain removed. No daemon started.")
print(f"Safety backups: {SAFETY_BACKUP}")

print("\n==== FINAL SAFE CHECK ====")
ps('Get-ScheduledTask -TaskName "AuroraWorker_Global","AuroraWorker_Global_Watchdog" -ErrorAction SilentlyContinue | Select-Object TaskName,State')
ps('Get-Process AuroraWorker -ErrorAction SilentlyContinue | Select-Object Id,ProcessName,Path,StartTime')
ps(r'''Get-CimInstance Win32_Process |
  Where-Object { $_.Name -match "powershell" -and $_.CommandLine -match "Aurora|AuroraWorker|watchdog|external_worker" } |
  Select-Object ProcessId,Name,CommandLine''')
