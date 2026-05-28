$ErrorActionPreference = "Continue"

# Read-only proof script for Gateway surface overseer evidence.
# This script does not start, stop, repair, rebuild, install, copy, or launch Gateway.
# It verifies the existing Gateway EXE has published layer-agnostic sidecar alignment proof.

$Root = Join-Path $env:APPDATA "MetaQuotes\Terminal\Common\Files\Aurora Core"
$ExpectedSchema = "aurora_gateway_surface_overseer_status"
$ExpectedAuthority = "calculation_support_only"

function Read-KvFile($Path) {
    $map = @{}
    if (!(Test-Path -LiteralPath $Path -PathType Leaf)) { return $map }
    foreach ($line in Get-Content -LiteralPath $Path -ErrorAction SilentlyContinue) {
        if ($line -match '^([^=]+)=(.*)$') {
            $map[$matches[1].Trim()] = $matches[2].Trim()
        }
    }
    return $map
}

function Field($Map, $Key, $Default = "missing") {
    if ($Map.ContainsKey($Key)) { return $Map[$Key] }
    return $Default
}

function PassFail($Name, $Ok, $Detail) {
    if ($Ok) { Write-Host "PASS|$Name|$Detail" -ForegroundColor Green }
    else { Write-Host "FAIL|$Name|$Detail" -ForegroundColor Red }
}

function WarnInfo($Name, $Detail) {
    Write-Host "WARN|$Name|$Detail" -ForegroundColor Yellow
}

function Find-AccountRoots($RootPath) {
    $roots = @()
    if (!(Test-Path -LiteralPath $RootPath -PathType Container)) { return $roots }
    Get-ChildItem -LiteralPath $RootPath -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -notin @("Gateway", "External Worker") } |
        ForEach-Object {
            $serverDir = $_
            Get-ChildItem -LiteralPath $serverDir.FullName -Directory -ErrorAction SilentlyContinue |
                ForEach-Object {
                    $accountDir = $_
                    $gateway = Join-Path $accountDir.FullName "Workbench\Gateway"
                    if (Test-Path -LiteralPath $gateway -PathType Container) {
                        $roots += $accountDir.FullName
                    }
                }
        }
    return $roots
}

Write-Host "=== Aurora Gateway Surface Overseer Proof ==="
Write-Host "mode=read_only_no_start_no_stop_no_repair_no_install_no_rebuild_no_launch"
Write-Host "root=$Root"

$accounts = Find-AccountRoots $Root
PassFail "account_root_discovered" ($accounts.Count -gt 0) "count=$($accounts.Count)"

foreach ($acct in $accounts) {
    Write-Host "--- account_root=$acct ---"
    $gateway = Join-Path $acct "Workbench\Gateway"
    $statusPath = Join-Path $gateway "Status\surface_overseer_status.txt"
    $layersRoot = Join-Path $gateway "Outbox\Layers"
    $l7Manifest = Join-Path $layersRoot "Layer_7_Session_Relevance_Ranking\ranked_symbols.manifest"
    $l7InputManifest = Join-Path $layersRoot "Layer_7_Session_Relevance_Ranking\l7_input_primitives.manifest"

    PassFail "surface_overseer_status_present" (Test-Path -LiteralPath $statusPath -PathType Leaf) $statusPath
    $kv = Read-KvFile $statusPath
    if ($kv.Count -eq 0) {
        WarnInfo "surface_overseer_not_ready" "Rebuild/reinstall Gateway EXE and let one daemon cycle run after this source patch."
        continue
    }

    Write-Host "surface_status_path=$statusPath"
    Write-Host "surface_schema_name=$(Field $kv 'schema_name')"
    Write-Host "surface_schema_version=$(Field $kv 'schema_version')"
    Write-Host "surface_status=$(Field $kv 'status')"
    Write-Host "surface_reason=$(Field $kv 'reason')"
    Write-Host "surface_layer_count=$(Field $kv 'layer_count')"
    Write-Host "surface_accepted_layer_count=$(Field $kv 'accepted_layer_count')"
    Write-Host "surface_degraded_layer_count=$(Field $kv 'degraded_layer_count')"
    Write-Host "surface_mismatch_count=$(Field $kv 'mismatch_count')"
    Write-Host "surface_newest_manifest_unix=$(Field $kv 'newest_manifest_unix')"
    Write-Host "surface_scope=$(Field $kv 'scope')"
    Write-Host "surface_write_authority=$(Field $kv 'surface_write_authority')"
    Write-Host "surface_ea_publication_authority=$(Field $kv 'ea_publication_authority')"
    Write-Host "surface_authority=$(Field $kv 'authority')"
    Write-Host "surface_trade_permission=$(Field $kv 'trade_permission')"
    Write-Host "surface_selection_runtime=$(Field $kv 'selection_runtime')"

    PassFail "surface_schema_ok" ((Field $kv 'schema_name') -eq $ExpectedSchema) "schema_name=$(Field $kv 'schema_name')"
    PassFail "surface_authority_safe" ((Field $kv 'authority') -eq $ExpectedAuthority) "authority=$(Field $kv 'authority')"
    PassFail "surface_trade_permission_false" ((Field $kv 'trade_permission') -eq 'false') "trade_permission=$(Field $kv 'trade_permission')"
    PassFail "surface_selection_runtime_false" ((Field $kv 'selection_runtime') -eq 'false') "selection_runtime=$(Field $kv 'selection_runtime')"
    PassFail "surface_does_not_write_ea_surfaces" ((Field $kv 'surface_write_authority') -eq 'false') "surface_write_authority=$(Field $kv 'surface_write_authority')"
    PassFail "surface_ea_remains_publication_authority" ((Field $kv 'ea_publication_authority') -eq 'true') "ea_publication_authority=$(Field $kv 'ea_publication_authority')"
    PassFail "surface_layer_count_integer" ((Field $kv 'layer_count') -match '^[0-9]+$') "layer_count=$(Field $kv 'layer_count')"
    PassFail "surface_mismatch_count_integer" ((Field $kv 'mismatch_count') -match '^[0-9]+$') "mismatch_count=$(Field $kv 'mismatch_count')"

    if (Test-Path -LiteralPath $l7Manifest -PathType Leaf) {
        $l7 = Read-KvFile $l7Manifest
        Write-Host "l7_status=$(Field $l7 'status')"
        Write-Host "l7_input_count=$(Field $l7 'input_count')"
        Write-Host "l7_row_count=$(Field $l7 'row_count')"
        Write-Host "l7_symbol_rank_files_actual=$(Field $l7 'symbol_rank_files_actual')"
        Write-Host "l7_authority=$(Field $l7 'authority')"
        Write-Host "l7_trade_permission=$(Field $l7 'trade_permission')"
        Write-Host "l7_selection_runtime=$(Field $l7 'selection_runtime')"
        PassFail "l7_manifest_complete_or_truthful" ((Field $l7 'status') -in @('complete','input_degraded')) "status=$(Field $l7 'status')"
        PassFail "l7_authority_safe" ((Field $l7 'authority') -eq $ExpectedAuthority) "authority=$(Field $l7 'authority')"
        PassFail "l7_trade_permission_false" ((Field $l7 'trade_permission') -eq 'false') "trade_permission=$(Field $l7 'trade_permission')"
        PassFail "l7_selection_runtime_false" ((Field $l7 'selection_runtime') -eq 'false') "selection_runtime=$(Field $l7 'selection_runtime')"
    } else {
        WarnInfo "l7_manifest_missing" $l7Manifest
    }

    if (Test-Path -LiteralPath $l7InputManifest -PathType Leaf) {
        $l7Input = Read-KvFile $l7InputManifest
        Write-Host "l7_input_row_count=$(Field $l7Input 'row_count')"
        Write-Host "l7_input_l5_gate_pass=$(Field $l7Input 'l5_gate_pass')"
        Write-Host "l7_input_payload_checksum=$(Field $l7Input 'payload_checksum')"
    }
}

Write-Host "=== End surface overseer proof ==="
