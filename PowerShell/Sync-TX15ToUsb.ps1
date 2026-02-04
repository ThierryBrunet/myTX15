<#
.SYNOPSIS
    Bidirectionally syncs "TX Drive" (RadioMaster TX15 in file transfer mode) with USB Drive (D:).

.DESCRIPTION
    Uses robocopy for fast bidirectional sync. When the TX15 is plugged in and in file transfer mode,
    this script copies newer files from TX Drive to D:, then from D: to TX Drive.
    Does not run automatically; execute when ready.

.PARAMETER TxDrivePath
    Path to TX Drive (e.g. E:\ or a path). If not set, the script tries to find a volume with label "TX Drive".

.PARAMETER UsbDrivePath
    Path to USB drive (default D:).

.PARAMETER WhatIf
    Show what would be synced without copying.

.EXAMPLE
    .\Sync-TX15ToUsb.ps1
    .\Sync-TX15ToUsb.ps1 -TxDrivePath "E:\" -UsbDrivePath "D:\"
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [string] $TxDrivePath = "C:\Users\thier\OneDrive\Workspaces\ExpressLRS\RadioMaster TX15\myTX15\TX15 Drive",
    [string] $UsbDrivePath = "D:\",
    [switch] $WhatIf
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
foreach ($name, $path in @{ "TX Drive" = $TxDrivePath; "USB Drive" = $UsbDrivePath }) {
    if (-not (Test-Path -LiteralPath $path -PathType Container)) {
        Write-Error "$name path does not exist or is not accessible: $path"
        exit 1
    }
}

Write-Host "Bidirectional sync: TX Drive <-> USB Drive (D:)" -ForegroundColor Cyan
Write-Host "  TX Drive: $TxDrivePath"
Write-Host "  USB Drive: $UsbDrivePath"
Write-Host ""

$robocopyArgs = @(
    "/E",      # copy subdirs including empty
    "/XO",     # exclude older (only copy when source is newer or missing in dest)
    "/R:2",    # retries
    "/W:5",    # wait between retries (sec)
    "/MT:8",   # multi-threaded (faster)
    "/NP",     # no progress percentage (cleaner log)
    "/NDL",    # no directory list
    "/NFL"     # no file list (optional; remove for verbose)
)

if ($WhatIf) {
    Write-Host "WhatIf: would run robocopy (no files copied)." -ForegroundColor Yellow
    Write-Host "  Phase 1: robocopy `"$TxDrivePath`" `"$UsbDrivePath`" $($robocopyArgs -join ' ')"
    Write-Host "  Phase 2: robocopy `"$UsbDrivePath`" `"$TxDrivePath`" $($robocopyArgs -join ' ')"
    exit 0
}

# Phase 1: TX Drive -> USB Drive (D:)
Write-Host "Phase 1: TX Drive -> USB Drive (D:) ..." -ForegroundColor Green
$rc1 = Start-Process -FilePath "robocopy" -ArgumentList @(
    [string]::Format('"{0}"', $TxDrivePath.TrimEnd('\')),
    [string]::Format('"{0}"', $UsbDrivePath.TrimEnd('\')),
    $robocopyArgs
) -Wait -NoNewWindow -PassThru

# Phase 2: USB Drive (D:) -> TX Drive
Write-Host "Phase 2: USB Drive (D:) -> TX Drive ..." -ForegroundColor Green
$rc2 = Start-Process -FilePath "robocopy" -ArgumentList @(
    [string]::Format('"{0}"', $UsbDrivePath.TrimEnd('\')),
    [string]::Format('"{0}"', $TxDrivePath.TrimEnd('\')),
    $robocopyArgs
) -Wait -NoNewWindow -PassThru

# Robocopy exit codes: 0–7 = success (with different copy counts), 8+ = errors
$maxRc = [Math]::Max($rc1.ExitCode, $rc2.ExitCode)
if ($maxRc -ge 8) {
    Write-Warning "Robocopy reported exit code(s): Phase1=$($rc1.ExitCode), Phase2=$($rc2.ExitCode). Check if any files failed."
}
else {
    Write-Host "Sync completed (robocopy codes: $($rc1.ExitCode), $($rc2.ExitCode))." -ForegroundColor Green
}
