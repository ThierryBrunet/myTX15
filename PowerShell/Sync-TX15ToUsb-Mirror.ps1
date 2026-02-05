<#
.SYNOPSIS
    Force exact clone sync from TX15 Drive to USB Drive.

.DESCRIPTION
    Uses robocopy with /MIR flag to create an exact mirror of TX Drive on USB Drive.
    WARNING: This will DELETE files from USB Drive that don't exist on TX Drive!
    The destination (USB Drive) will be made identical to the source (TX Drive).

.PARAMETER TxDrivePath
    Path to TX Drive (e.g. E:\ or a path). If not set, the script tries to find a volume with label "TX Drive".

.PARAMETER UsbDrivePath
    Path to USB drive (default D:).

.PARAMETER WhatIf
    Show what would be synced without copying.

.EXAMPLE
    .\Sync-TX15ToUsb-Mirror.ps1
    .\Sync-TX15ToUsb-Mirror.ps1 -TxDrivePath "E:\" -UsbDrivePath "D:\"
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [string] $TxDrivePath = "C:\Users\thier\OneDrive\Workspaces\ExpressLRS\RadioMaster TX15\myTX15\TX15_Drive",
    [string] $UsbDrivePath = "D:\",
    [switch] $WhatIfx
)

$ErrorActionPreference = "Stop"

# Ensure paths end with backslash for robocopy
$UsbDrivePath = $UsbDrivePath.TrimEnd('\') + '\'

function Get-TxDriveByLabel {
    $vol = Get-Volume | Where-Object { $_.FileSystemLabel -eq "TX Drive" } | Select-Object -First 1
    if ($vol) {
        $root = $vol.DriveLetter
        if ($root) { return "${root}:\" }
    }
    return $null
}

# Resolve TX Drive path
if ([string]::IsNullOrWhiteSpace($TxDrivePath)) {
    $TxDrivePath = Get-TxDriveByLabel
    if (-not $TxDrivePath) {
        Write-Error "TX Drive not found. Plug in the RadioMaster TX15 in file transfer mode, or pass -TxDrivePath (e.g. -TxDrivePath 'E:\')."
        exit 1
    }
}
$TxDrivePath = $TxDrivePath.TrimEnd('\') + '\'

# Validate both paths exist
foreach ($entry in @{ "TX Drive" = $TxDrivePath; "USB Drive" = $UsbDrivePath }.GetEnumerator()) {
    $name = $entry.Key
    $path = $entry.Value
    if (-not (Test-Path -LiteralPath $path -PathType Container)) {
        Write-Error "$name path does not exist or is not accessible: $path"
        exit 1
    }
}

Write-Host "FORCE CLONE SYNC: TX Drive -> USB Drive (EXACT MIRROR)" -ForegroundColor Red
Write-Host "  WARNING: Files on USB Drive that don't exist on TX Drive will be DELETED!" -ForegroundColor Yellow
Write-Host "  Source (TX Drive): $TxDrivePath"
Write-Host "  Destination (USB Drive): $UsbDrivePath"
Write-Host ""

# Confirm destructive operation
if (-not $WhatIfx) {
    $confirmation = Read-Host "This will make USB Drive identical to TX Drive. Continue? (yes/no)"
    if ($confirmation -ne "yes") {
        Write-Host "Operation cancelled." -ForegroundColor Yellow
        exit 0
    }
}

$robocopyArgs = @(
    "/MIR",    # mirror - delete files in dest that don't exist in source
    "/R:2",    # retries
    "/W:5",    # wait between retries (sec)
    "/MT:8",   # multi-threaded (faster)
    "/NP",     # no progress percentage (cleaner log)
    "/NDL",    # no directory list
    "/NFL"     # no file list (optional; remove for verbose)
)

if ($WhatIfx) {
    Write-Host "WhatIf: would run robocopy (no files copied)." -ForegroundColor Yellow
    Write-Host "  robocopy `"$TxDrivePath`" `"$UsbDrivePath`" $($robocopyArgs -join ' ')"
    exit 0
}

Write-Host "Starting force clone sync (this may take a while)..." -ForegroundColor Green

$argList = @(
    [string]::Format('"{0}"', $TxDrivePath.TrimEnd('\')),
    [string]::Format('"{0}"', $UsbDrivePath.TrimEnd('\'))
) + $robocopyArgs

$rc = Start-Process -FilePath "robocopy" -ArgumentList $argList -Wait -NoNewWindow -PassThru

# Robocopy exit codes: 0–7 = success (with different copy counts), 8+ = errors
if ($rc.ExitCode -ge 8) {
    Write-Error "Robocopy failed with exit code $($rc.ExitCode). Check for permission issues or disk space."
    exit $rc.ExitCode
}
else {
    Write-Host "Force clone sync completed successfully (robocopy code: $($rc.ExitCode))." -ForegroundColor Green
    Write-Host "USB Drive is now an exact mirror of TX Drive." -ForegroundColor Green
}