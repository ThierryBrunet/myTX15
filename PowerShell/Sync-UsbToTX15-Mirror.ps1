# Sync-UsbToTX15-Mirror.ps1
# Mirrors EdgeTX configurations from physical radio to digital twin
# Mode: Exact copy - removes files not in source (destructive sync)

#Requires -Version 5.1

using namespace System.Collections.Generic

<#
.SYNOPSIS
    Mirrors EdgeTX configurations from RadioMaster TX15 to repository
.DESCRIPTION
    Performs exact mirror synchronization of EdgeTX files from the physical transmitter
    to the digital twin (repository). Copies new/modified files and removes files
    that don't exist on the radio.
.WARNING
    This operation is DESTRUCTIVE - files not on the radio will be deleted from the repository!
.PARAMETER WhatIf
    Show what would be done without making changes
.PARAMETER Force
    Skip confirmation prompts (use with extreme caution)
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
        Write-SyncLog -Message "Starting USB to TX15 MIRROR synchronization" -Level Warning -Context "Mirror"

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

        # DANGER WARNING
        if (!$Force -and !$WhatIf) {
            Write-Host ""
            Write-Host "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" -ForegroundColor Red
            Write-Host "!!!                   DANGER WARNING                     !!!" -ForegroundColor Red
            Write-Host "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" -ForegroundColor Red
            Write-Host ""
            Write-Host "This MIRROR operation will DELETE files from your repository" -ForegroundColor Red
            Write-Host "that do not exist on the radio. This includes any configurations," -ForegroundColor Red
            Write-Host "templates, or files you've added to the digital twin." -ForegroundColor Red
            Write-Host ""
            Write-Host "Make sure you have committed important changes to git first!" -ForegroundColor Yellow
            Write-Host ""

            $commitChoice = Read-Host -Prompt "Have you committed important repository changes? (yes/no)"
            if ($commitChoice -notmatch "^(y|yes)$") {
                Write-SyncLog -Message "Mirror synchronization cancelled - commit not confirmed" -Level Info
                return
            }

            $confirmChoice = Read-Host -Prompt "Type 'MIRROR' to confirm destructive operation"
            if ($confirmChoice -ne "MIRROR") {
                Write-SyncLog -Message "Mirror synchronization cancelled - confirmation failed" -Level Info
                return
            }
        }

        # Perform mirror synchronization
        Mirror-FromRadio

        # Complete statistics
        $syncStats.EndTime = Get-Date
        $syncStats.Duration = $syncStats.EndTime - $syncStats.StartTime

        # Display summary
        $summary = Format-SyncSummary -Stats (Get-SyncStats -Stats $syncStats) -Operation "Radio to Repository (MIRROR)"
        Write-SyncLog -Message $summary -Level Warning -Context "Complete"

        # Exit with appropriate code
        if ($syncStats.Errors -gt 0) {
            exit 1
        }

    }
    catch {
        Write-SyncLog -Message "Mirror synchronization failed: $($_.Exception.Message)" -Level Error -Context "Error"
        exit 1
    }
}

<#
.SYNOPSIS
    Performs mirror synchronization from radio to repository
.DESCRIPTION
    Copies all files from radio to EdgeTX directory and removes extra files
#>
function Mirror-FromRadio {
    Write-SyncLog -Message "Beginning mirror synchronization" -Level Warning -Context "Mirror"

    # Define directories to mirror
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
            Write-SyncLog -Message "Radio directory not found: $sourceDir" -Level Warning -Context "Mirror"
            continue
        }

        Write-SyncLog -Message "Mirroring directory: $dir" -Level Warning -Context "Mirror"

        # Get all radio files
        $radioFiles = Get-ChildItem -Path $sourceDir -Recurse -File
        $radioRelativePaths = $radioFiles | ForEach-Object {
            $_.FullName -replace [regex]::Escape($sourceDir), "" | TrimStart "\"
        }

        # Get all target files
        if (Test-Path $targetDir) {
            $targetFiles = Get-ChildItem -Path $targetDir -Recurse -File
            $targetRelativePaths = $targetFiles | ForEach-Object {
                $_.FullName -replace [regex]::Escape($targetDir), "" | TrimStart "\"
            }
        } else {
            $targetRelativePaths = @()
        }

        # Find files to delete (exist in target but not in radio)
        # Exclude sync logs from deletion as they are generated locally
        $filesToDelete = $targetRelativePaths | Where-Object {
            $_ -notin $radioRelativePaths -and
            $_ -notlike "sync-logs\*" -and
            $_ -notlike "sync-*.log"
        }

        # Delete extra files
        foreach ($fileToDelete in $filesToDelete) {
            $fullPathToDelete = Join-Path $targetDir $fileToDelete
            try {
                if ($PSCmdlet.ShouldProcess($fullPathToDelete, "Delete (mirror operation)")) {
                    Remove-Item -Path $fullPathToDelete -Force
                    Write-SyncLog -Message "Deleted: $fileToDelete" -Level Info -Context "Mirror"
                    $syncStats.FilesDeleted++
                }
            }
            catch {
                Write-SyncLog -Message "Failed to delete $fullPathToDelete`: $($_.Exception.Message)" -Level Error -Context "Mirror"
                $syncStats.Errors++
            }
        }

        # Copy/update files from radio
        foreach ($radioFile in $radioFiles) {
            try {
                $relativePath = $radioFile.FullName -replace [regex]::Escape($sourceDir), "" | TrimStart "\"
                $targetFile = Join-Path $targetDir $relativePath

                # Skip sync log files
                if ($relativePath -like "sync-logs\*" -or $relativePath -like "sync-*.log") {
                    continue
                }

                # Check if file needs updating
                $needsUpdate = $true
                if (Test-Path $targetFile) {
                    $radioHash = Get-FileHash -Path $radioFile.FullName
                    $targetHash = Get-FileHash -Path $targetFile
                    $needsUpdate = $radioHash -ne $targetHash
                }

                if ($needsUpdate) {
                    if ($PSCmdlet.ShouldProcess($targetFile, "Copy (mirror from $($radioFile.FullName))")) {
                        if (Copy-FileSafe -Source $radioFile.FullName -Destination $targetFile -Force) {
                            Write-SyncLog -Message "Copied: $relativePath" -Level Info -Context "Mirror"
                            $syncStats.FilesCopied++
                        } else {
                            $syncStats.Errors++
                        }
                    }
                } else {
                    Write-SyncLog -Message "Unchanged: $relativePath" -Level Debug -Context "Mirror"
                    $syncStats.FilesSkipped++
                }

            }
            catch {
                Write-SyncLog -Message "Error processing $($radioFile.FullName): $($_.Exception.Message)" -Level Error -Context "Mirror"
                $syncStats.Errors++
            }
        }
    }

    Write-SyncLog -Message "Mirror synchronization completed" -Level Warning -Context "Mirror"
}

# Execute main function
Main