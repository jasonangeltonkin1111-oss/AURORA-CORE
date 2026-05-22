$ErrorActionPreference = "Continue"

$sharedRoot = "$env:APPDATA\MetaQuotes\Terminal\Common\Files\Aurora Core"
$watchdogTask = "AuroraWorker_Global_Watchdog"
$daemonTask = "AuroraWorker_Global"
$runner = Join-Path $PSScriptRoot "watchdog_runner_global.ps1"
$statusFolder = Join-Path $sharedRoot "External Worker\Status"
$installStatus = Join-Path $statusFolder "shared_worker_install_status.txt"

New-Item -ItemType Directory -Force -Path $statusFolder | Out-Null

$runnerText = @"
`$ErrorActionPreference = "Continue"
`$sharedRoot = "`$env:APPDATA\MetaQuotes\Terminal\Common\Files\Aurora Core"
`$exe = Join-Path `$sharedRoot "External Worker\AuroraWorker\AuroraWorker.exe"
`$daemonTask = "AuroraWorker_Global"

`$proc = Get-Process AuroraWorker -ErrorAction SilentlyContinue
if (-not `$proc) {
    Start-ScheduledTask -TaskName `$daemonTask -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
}

if (Test-Path `$exe) {
    & `$exe --shared-root "`$sharedRoot" --watchdog | Out-Null
}
"@

Set-Content -Path $runner -Value $runnerText -Encoding UTF8

Unregister-ScheduledTask -TaskName $watchdogTask -Confirm:$false -ErrorAction SilentlyContinue

$xmlSharedRoot = [System.Security.SecurityElement]::Escape($sharedRoot)
$xmlRunner = [System.Security.SecurityElement]::Escape($runner)
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
    <Hidden>false</Hidden>
    <ExecutionTimeLimit>PT5M</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>powershell.exe</Command>
      <Arguments>-NoProfile -ExecutionPolicy Bypass -File "$xmlRunner"</Arguments>
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
        "operator_cmd_required" = $operatorRequired
    }

    foreach ($key in $pairs.Keys) {
        if ($text -match "(?m)^$key=") {
            $text = $text -replace "(?m)^$key=.*$", "$key=$($pairs[$key])"
        } else {
            $text += "`r`n$key=$($pairs[$key])"
        }
    }

    Set-Content -Path $installStatus -Value $text -Encoding UTF8
}

Write-Host "Watchdog registered=$watchdogRegistered state=$watchdogState operator_cmd_required=$operatorRequired"
