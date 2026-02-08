# Sync-UsbToTX15.ps1
# Synchronizes EdgeTX configurations from physical radio to digital twin
# Mode: Update new files, preserve existing (incremental sync)

#Requires -Version 5.1

using namespace System.Collections.Generic

<#
.SYNOPSIS
    Synchronizes EdgeTX configurations from RadioMaster TX15 to repository
.DESCRIPTION
    Performs incremental synchronization of EdgeTX files from the physical transmitter
    to the digital twin (repository). Only copies new or modified files,
    preserving existing files in the repository.
.PARAMETER WhatIf
    Show what would be done without making changes
.PARAMETER Force
    Skip confirmation prompts
.PARAMETER Verbose
    Enable verbose logging
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $false)]
    [switch]$WhatIf,

    [Parameter(Mandatory = $false)]
    [switch]$Force,

    [Parameter(Mandatory = $false)]
    [switch]$Verbose
)

# Import common functions
$commonModule = Join-Path $PSScriptRoot "Core\Common.psm1"
if (!(Test-Path $commonModule)) {
    Write-Error "Common module not found at $commonModule"
    exit 1
}
Import-Module $commonModule -Force

# Sync statistics
$syncStats = @{
    FilesCopied = 0
    FilesSkipped = 0
    FilesDeleted = 0
    Errors = 0
    StartTime = Get-Date
    EndTime = $null
    Duration = $null
}

function Main {
    try {
        Write-SyncLog -Message "Starting USB to TX15 synchronization" -Level Info -Context "Sync"

        # Initialize environment
        if (!(Initialize-SyncEnvironment)) {
            throw "Failed to initialize sync environment"
        }

        # Check radio drive accessibility
        if (!(Test-RadioDrive)) {
            throw "Radio drive $($CONFIG.RadioDrive) is not accessible"
        }

        # Validate target directory
        if (!(Test-Path $CONFIG.EdgeTXPath)) {
            throw "Target directory not found: $($CONFIG.EdgeTXPath)"
        }

        # Get confirmation if not forced
        if (!$Force -and !$WhatIf) {
            $message = "Ready to sync files from radio to repository. Continue?"
            $choice = Read-Host -Prompt $message
            if ($choice -notmatch "^(y|yes)$") {
                Write-SyncLog -Message "Synchronization cancelled by user" -Level Info
                return
            }
        }

        # Perform synchronization
        Sync-FromRadio

        # Complete statistics
        $syncStats.EndTime = Get-Date
        $syncStats.Duration = $syncStats.EndTime - $syncStats.StartTime

        # Display summary
        $summary = Format-SyncSummary -Stats (Get-SyncStats -Stats $syncStats) -Operation "Radio to Repository"
        Write-SyncLog -Message $summary -Level Info -Context "Complete"

        # Exit with appropriate code
        if ($syncStats.Errors -gt 0) {
            exit 1
        }

    }
    catch {
        Write-SyncLog -Message "Synchronization failed: $($_.Exception.Message)" -Level Error -Context "Error"
        exit 1
    }
}

<#
.SYNOPSIS
    Performs the actual synchronization from radio to repository
.DESCRIPTION
    Copies new and modified files from radio drive to EdgeTX directory
#>
function Sync-FromRadio {
    Write-SyncLog -Message "Beginning file synchronization" -Level Info -Context "Sync"

    # Define directories to sync
    $syncDirs = @(
        "MODELS",
        "SCRIPTS",
        "RADIO",
        "LOGS"
    )

    foreach ($dir in $syncDirs) {
        $sourceDir = Join-Path $CONFIG.RadioDrive $dir
        $targetDir = Join-Path $CONFIG.EdgeTXPath $dir

        if (!(Test-Path $sourceDir)) {
            Write-SyncLog -Message "Radio directory not found: $sourceDir" -Level Warning -Context "Sync"
            continue
        }

        Write-SyncLog -Message "Syncing directory: $dir" -Level Info -Context "Sync"

        # Get all files in radio directory recursively
        $radioFiles = Get-ChildItem -Path $sourceDir -Recurse -File

        foreach ($radioFile in $radioFiles) {
            try {
                # Calculate relative path from source directory
                $relativePath = $radioFile.FullName -replace [regex]::Escape($sourceDir), ""
                $relativePath = $relativePath.TrimStart("\")
                $targetFile = Join-Path $targetDir $relativePath

                # Skip log files that are auto-generated during sync
                if ($relativePath -like "sync-logs\*" -or $relativePath -like "sync-*.log") {
                    continue
                }

                # Check if target file exists
                if (Test-Path $targetFile) {
                    # Compare file hashes to detect changes
                    $radioHash = Get-FileHash -Path $radioFile.FullName
                    $targetHash = Get-FileHash -Path $targetFile

                    if ($radioHash -eq $targetHash) {
                        Write-SyncLog -Message "Skipping unchanged file: $relativePath" -Level Debug -Context "Sync"
                        $syncStats.FilesSkipped++
                        continue
                    }
                }

                # Copy file
                if ($PSCmdlet.ShouldProcess($targetFile, "Copy from $($radioFile.FullName)")) {
                    if (Copy-FileSafe -Source $radioFile.FullName -Destination $targetFile -Force) {
                        Write-SyncLog -Message "Copied: $relativePath" -Level Info -Context "Sync"
                        $syncStats.FilesCopied++
                    } else {
                        $syncStats.Errors++
                    }
                }

            }
            catch {
                Write-SyncLog -Message "Error processing $($radioFile.FullName): $($_.Exception.Message)" -Level Error -Context "Sync"
                $syncStats.Errors++
            }
        }
    }

    Write-SyncLog -Message "File synchronization completed" -Level Info -Context "Sync"
}

# Execute main function
Main